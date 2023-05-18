import 'dart:convert';
import 'dart:typed_data';

import 'package:tempo/tempo.dart';
import 'package:tempo/timezone.dart';

import 'local_time_type_block.dart';
import 'posix_tz.dart';
import 'zone_info_reader_result.dart';

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
  final UnmodifiableUint8ListView _bytes;
  final UnmodifiableByteDataView _data;

  int _pos = 0;

  ZoneInfoReader(Uint8List bytes)
      : _bytes = UnmodifiableUint8ListView(bytes),
        _data = UnmodifiableByteDataView(ByteData.sublistView(bytes));

  ZoneRules read() {
    _skipV1Part();

    return ZoneRules((b) => b
      ..transitions.addAll(_readZoneTransitions())
      ..rule = _readZoneTransitionRule().toBuilder());
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
  List<ZoneTransition> _readZoneTransitions() {
    // Read the v2+v3 header.
    var header = _Header.read(this);
    if (header.version < _Header.version2) {
      throw ZoneInfoFormatException(
          'Unsupported zoneinfo version ${header.version.toRadixString(16)}');
    }

    // Read the data block.
    var transitionTimes = _nextInstantList(header.timeCnt);
    var transitionTypes = _nextUint8List(header.timeCnt);
    var localTimeTypes = _nextLocalTimeTypeList(header.typeCnt);
    var designations = _nextUint8List(header.charCnt);
    _pos += header.leapCnt;
    _pos += header.isStdCnt;
    _pos += header.isUtCnt;

    return _zoneTransitions(
        transitionTimes, transitionTypes, localTimeTypes, designations);
  }

  List<ZoneTransition> _zoneTransitions(
      List<Instant> transitionTimes,
      Uint8List transitionTypes,
      List<LocalTimeTypeBlock> localTimeTypes,
      Uint8List designations) {
    var first = ZoneTransition((b) => b
      ..transitionTime = Instant.minimum
      ..isDst = localTimeTypes[0].isDst
      ..offset = NamedZoneOffset.fromZoneOffset(
          _nullTermString(designations, localTimeTypes[0].index),
          localTimeTypes[0].isDst,
          localTimeTypes[0].utOffset));
    return [first] +
        List.generate(transitionTimes.length, (i) {
          var ltt = localTimeTypes[transitionTypes[i]];
          var designation = _nullTermString(designations, ltt.index);
          return ZoneTransition((b) => b
            ..transitionTime = transitionTimes[i]
            ..offset = NamedZoneOffset.fromZoneOffset(
                designation, ltt.isDst, ltt.utOffset)
            ..isDst = ltt.isDst);
        });
  }

  /// Reads a null-terminated string starting at [index].
  String _nullTermString(Uint8List bytes, int index, [int terminator = 0]) =>
      // TODO: File a dart SDK bug about _UnmodifiableListMixin null error
      // when omitting the second arg of sublist():
      AsciiDecoder().convert(bytes
          .sublist(index, bytes.length)
          .takeWhile((c) => c != terminator)
          .toList());

  ZoneTransitionRule _readZoneTransitionRule() {
    ++_pos;
    var tz = PosixTz(_nextString(_bytes.length, 0x0a));
    return tz.rule;
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

  List<Instant> _nextInstantList(int len) {
    // Don't just create a view on _bytes. That would not fix the byte order.
    var list = <Instant>[];
    for (int i = 0; i < len; ++i) {
      list.add(Instant.fromUnix(Timespan(seconds: _nextInt64())));
    }
    return list;
  }

  List<LocalTimeTypeBlock> _nextLocalTimeTypeList(int len) =>
      List.generate(len, (i) => _nextLocalTimeTypeBlock());

  String _nextString(int maxIndex, [int terminator = 0]) {
    var stringBytes = _nullTermString(_bytes, _pos, terminator);
    _pos += stringBytes.length + 1;
    return stringBytes;
  }

  LocalTimeTypeBlock _nextLocalTimeTypeBlock() => LocalTimeTypeBlock(
        (b) => b
          ..utOffset = ZoneOffset(0, 0, _nextInt32())
          ..isDst = _nextUint8() == 1
          ..index = _nextUint8(),
      );

  @override
  String toString() => 'ZoneInfoReader(pos=$_pos, $_bytes)';
}

class _Header {
  static const int tzifMagic = 0x545a6966; // 'TZif'
  static const int version2 = 0x32;

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
