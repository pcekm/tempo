/// Contains internal functionality related to time zones.
library zonedb;

import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:collection/collection.dart';
import 'package:goodtime/goodtime.dart';
import 'package:string_scanner/string_scanner.dart';

part 'src/zonedb/posix_tz.dart';
part 'src/zonedb/time_zone.dart';
part 'src/zonedb/zonedb.dart';
part 'src/zonedb/zone_descriptions.dart';
part 'src/zonedb/zone_info_data.dart';
part 'src/zonedb/zone_info_reader.dart';
part 'src/zonedb/zone_info_record.dart';
