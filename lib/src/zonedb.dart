/// Contains internal functionality related to time zones.
library zonedb;

import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:collection/collection.dart';
import 'package:goodtime/goodtime.dart';
import 'package:string_scanner/string_scanner.dart';

part 'zonedb/posix_tz.dart';
part 'zonedb/time_zone.dart';
part 'zonedb/zonedb.dart';
part 'zonedb/zone_descriptions.dart';
part 'zonedb/zone_info_data.dart';
part 'zonedb/zone_info_reader.dart';
part 'zonedb/zone_info_record.dart';
