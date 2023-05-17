part of '../zonedb.dart';

abstract class LocalTimeTypeBlock
    implements Built<LocalTimeTypeBlock, LocalTimeTypeBlockBuilder> {
  static Serializer<LocalTimeTypeBlock> get serializer =>
      _$localTimeTypeBlockSerializer;

  ZoneOffset get utOffset;
  bool get isDst;
  int get index;

  LocalTimeTypeBlock._();
  factory LocalTimeTypeBlock(
          [void Function(LocalTimeTypeBlockBuilder) updates]) =
      _$LocalTimeTypeBlock;
}
