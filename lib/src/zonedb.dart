/// Contains internal functionality related to time zones.
library zonedb;

import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:built_value/built_value.dart';
import 'package:built_collection/built_collection.dart';
import 'package:built_value/serializer.dart';
import 'package:collection/collection.dart';
import 'package:string_scanner/string_scanner.dart';
import 'package:tempo/tempo.dart';

part 'zonedb.g.dart';
part 'zonedb/change_time.dart';
part 'zonedb/local_time_type_block.dart';
part 'zonedb/posix_tz.dart';
part 'zonedb/time_zone.dart';
part 'zonedb/zone_description_table.dart';
part 'zonedb/zone_description.dart';
part 'zonedb/zone_info_data.dart';
part 'zonedb/zone_info_reader.dart';
part 'zonedb/zone_info_record.dart';
part 'zonedb/zonedb.dart';
