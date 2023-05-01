part of '../../zonedb.dart';

class ZoneInfoFormatException implements Exception {
  final String message;
  final int? offset;

  ZoneInfoFormatException(this.message, [this.offset]);

  @override
  String toString() => ['Invalid zoneinfo file', offset, message]
      .where((x) => x != null)
      .join(': ');
}

/// Reads a zoneinfo file.
///
/// The zoneinfo format is described in the
/// [tzfile(5)](https://linux.die.net/man/5/tzfile) manpage, and in
/// [RFC 8536](https://www.rfc-editor.org/rfc/rfc8536.html).
class ZoneInfoReader {
  final String _zoneName;
  final UnmodifiableUint8ListView _bytes;
  final UnmodifiableByteDataView _data;

  int _pos = 0;

  ZoneInfoReader(String zoneName, Uint8List bytes)
      : _zoneName = zoneName,
        _bytes = UnmodifiableUint8ListView(bytes),
        _data = UnmodifiableByteDataView(ByteData.sublistView(bytes));

  ZoneInfoRecord read() {
    _pos = 0;

    _skipV1Part();
    return _readV2Part();
  }

  // Skips over the first part of the file, which is there for backwards
  // compatibility with old readers.
  void _skipV1Part() {
    var header = _Header.read(this);
    if (header.version < _Header.version2) {
      throw ZoneInfoFormatException(
          'Unsupported zoneinfo version ${header.version.toRadixString(16)}');
    }

    // Skip the v1 data block:
    _pos += header.timeCnt * 4 +
        header.timeCnt +
        header.typeCnt * 6 +
        header.charCnt +
        header.leapCnt * 8 +
        header.isStdCnt +
        header.isUtCnt;
  }

  // Reads the V2+ part of the file.
  ZoneInfoRecord _readV2Part() {
    // Read the v2+v3 header.
    var header = _Header.read(this);
    if (header.version < _Header.version2) {
      throw ZoneInfoFormatException(
          'Unsupported zoneinfo version ${header.version.toRadixString(16)}');
    }

    // Read the data block.
    var transitionTimes = _nextInt64List(header.timeCnt)
        .map((t) => Instant.fromUnix(Timespan(seconds: t)))
        .toList();
    var transitionTypes = _nextUint8List(header.timeCnt);
    var localTimeTypes = _nextLocalTimeTypeList(header.typeCnt);
    var designations = _nextTimeZoneDesignations(header.charCnt);
    _pos += header.leapCnt;
    _pos += header.isStdCnt;
    _pos += header.isUtCnt;

    // Read the footer.
    ++_pos;
    var tzString = _nextString(_bytes.length, 0x0a);

    return ZoneInfoRecord(
      _zoneName,
      transitionTimes,
      transitionTypes,
      localTimeTypes,
      designations,
      PosixTz(tzString),
    );
  }

  int _thenAdvance(int n) {
    var old = _pos;
    _pos += n;
    return old;
  }

  int _nextUint8() => _data.getUint8(_thenAdvance(1));
  int _nextUint32() => _data.getUint32(_thenAdvance(4));
  int _nextInt32() => _data.getInt32(_thenAdvance(4));
  int _nextInt64() => _data.getInt64(_thenAdvance(8));

  Uint8List _nextUint8List(int len) =>
      Uint8List.sublistView(_data, _pos, _pos += len);

  Int64List _nextInt64List(int len) {
    // Don't just create a view on _bytes. That would not fix the byte order.
    var list = Int64List(len);
    for (int i = 0; i < len; ++i) {
      list[i] = _nextInt64();
    }
    return list;
  }

  List<_LocalTimeTypeBlock> _nextLocalTimeTypeList(int len) =>
      List.generate(len, (i) => _nextLocalTimeTypeBlock());

  Map<int, String> _nextTimeZoneDesignations(int charCnt) {
    var result = <int, String>{};
    final int start = _pos;
    final int end = _pos + charCnt;
    while (_pos < end) {
      int idx = _pos - start;
      result[idx] = _nextString(end);
    }
    return result;
  }

  String _nextString(int maxIndex, [int terminator = 0]) {
    var stringBytes =
        _bytes.sublist(_pos, maxIndex).takeWhile((c) => c != terminator);
    _pos += stringBytes.length + 1;
    return AsciiDecoder(allowInvalid: true).convert(stringBytes.toList());
  }

  _LocalTimeTypeBlock _nextLocalTimeTypeBlock() => _LocalTimeTypeBlock(
        ZoneOffset(0, 0, _nextInt32()),
        _nextUint8() == 1,
        _nextUint8(),
      );

  @override
  String toString() => 'ZoneInfoReader(pos=$_pos, $_bytes)';
}

class _Header {
  static const int tzifMagic = 0x545a6966; // 'TZif'

  static const int version1 = 0;
  static const int version2 = 0x32;
  static const int version3 = 0x33;

  final int magic;
  final int version;
  final int isUtCnt;
  final int isStdCnt;
  final int leapCnt;
  final int timeCnt;
  final int typeCnt;
  final int charCnt;

  _Header._(this.magic, this.version, this.isUtCnt, this.isStdCnt, this.leapCnt,
      this.timeCnt, this.typeCnt, this.charCnt);

  factory _Header.read(ZoneInfoReader reader) {
    var magic = reader._nextUint32();
    var version = reader._nextUint8();
    reader._pos += 15;
    var isUtCnt = reader._nextUint32();
    var isStdCnt = reader._nextUint32();
    var leapCnt = reader._nextUint32();
    var timeCnt = reader._nextUint32();
    var typeCnt = reader._nextUint32();
    var charCnt = reader._nextUint32();
    if (magic != tzifMagic) {
      throw ZoneInfoFormatException(
          'Invalid header id; not a TZif file $magic');
    }
    return _Header._(
        magic, version, isUtCnt, isStdCnt, leapCnt, timeCnt, typeCnt, charCnt);
  }

  @override
  String toString() => [
        magic,
        version,
        isUtCnt,
        isStdCnt,
        leapCnt,
        timeCnt,
        typeCnt,
        charCnt,
      ].toString();
}
