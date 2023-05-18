import 'package:built_collection/built_collection.dart';
import 'package:built_value/serializer.dart';

import '../../tempo.dart';
import '../../timezone.dart';
import 'zone_info.dart';

part 'serializers.g.dart';

@SerializersFor([
  TimeChangeRule,
  ZoneInfo,
  ZoneRules,
  ZoneTabRow,
  ZoneTransitionRule,
  ZoneTransition,
])
final Serializers serializers = (_$serializers.toBuilder()
      ..addAll([
        _InstantSerializer(),
        _LocalTimeSerializer(),
        _NamedZoneOffsetSerializer(),
        _WeekdaySerializer(),
        _ZoneOffsetSerializer(),
      ]))
    .build();

class _InstantSerializer extends PrimitiveSerializer<Instant> {
  @override
  Instant deserialize(Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      Instant.fromUnix(Timespan(seconds: serialized as int));

  @override
  Object serialize(Serializers serializers, Instant instant,
          {FullType specifiedType = FullType.unspecified}) =>
      instant.unixTimestamp.inSeconds;

  @override
  Iterable<Type> get types => [Instant];

  @override
  String get wireName => 'Instant';
}

class _LocalTimeSerializer extends PrimitiveSerializer<LocalTime> {
  @override
  LocalTime deserialize(Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      LocalTime.parse(serialized as String);

  @override
  Object serialize(Serializers serializers, LocalTime time,
          {FullType specifiedType = FullType.unspecified}) =>
      time.toString();

  @override
  Iterable<Type> get types => [LocalTime];
  @override
  String get wireName => 'LocalTime';
}

class _NamedZoneOffsetSerializer extends PrimitiveSerializer<NamedZoneOffset> {
  @override
  NamedZoneOffset deserialize(Serializers serializers, Object serialized,
      {FullType specifiedType = FullType.unspecified}) {
    var vals = serializers.deserialize(serialized) as BuiltList<dynamic>;
    return NamedZoneOffset.fromTimespan(
        vals[0], vals[1], Timespan(seconds: vals[2]));
  }

  @override
  Object serialize(Serializers serializers, NamedZoneOffset offset,
          {FullType specifiedType = FullType.unspecified}) =>
      serializers.serialize(BuiltList<dynamic>.build((b) => b
        ..add(offset.name)
        ..add(offset.isDst)
        ..add(offset.asTimespan.inSeconds)))!;

  @override
  Iterable<Type> get types => [NamedZoneOffset];

  @override
  String get wireName => 'NamedZoneOffset';
}

class _WeekdaySerializer extends PrimitiveSerializer<Weekday> {
  @override
  Weekday deserialize(Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      Weekday.values[serialized as int];

  @override
  Object serialize(Serializers serializers, Weekday weekday,
          {FullType specifiedType = FullType.unspecified}) =>
      weekday.index;

  @override
  Iterable<Type> get types => [Weekday];

  @override
  String get wireName => 'Weekday';
}

class _ZoneOffsetSerializer extends PrimitiveSerializer<ZoneOffset> {
  @override
  ZoneOffset deserialize(Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      ZoneOffset.fromTimespan(Timespan(seconds: serialized as int));

  @override
  Object serialize(Serializers serializers, ZoneOffset offset,
          {FullType specifiedType = FullType.unspecified}) =>
      offset.asTimespan.inSeconds;

  @override
  Iterable<Type> get types => [ZoneOffset];

  @override
  String get wireName => 'ZoneOffset';
}
