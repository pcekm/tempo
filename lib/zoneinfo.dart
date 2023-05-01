/// TODO: Describe me.
library tzdb;

import 'dart:async';
import 'dart:convert';
import 'dart:ffi';
import 'dart:html';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:collection/collection.dart';
import 'package:goodtime/goodtime.dart';
import 'package:string_scanner/string_scanner.dart';

part 'src/zoneinfo/posix_tz.dart';
part 'src/zoneinfo/time_zone.dart';
part 'src/zoneinfo/tzdb.dart';
part 'src/zoneinfo/zone_info_data.dart';
part 'src/zoneinfo/zone_info_reader.dart';
part 'src/zoneinfo/zone_info_record.dart';
