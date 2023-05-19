import 'package:built_value/built_value.dart';
import 'package:tempo/tempo.dart';

part 'local_time_type_block.g.dart';

abstract class LocalTimeTypeBlock
    implements Built<LocalTimeTypeBlock, LocalTimeTypeBlockBuilder> {
  ZoneOffset get utOffset;
  bool get isDst;
  int get index;

  LocalTimeTypeBlock._();
  factory LocalTimeTypeBlock(
          [void Function(LocalTimeTypeBlockBuilder) updates]) =
      _$LocalTimeTypeBlock;
}
