/// TODO: Describe me.
library tzdb;

import 'dart:async';
import 'dart:convert';
import 'dart:ffi';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:collection/collection.dart';
import 'package:goodtime/goodtime.dart';
import 'package:string_scanner/string_scanner.dart';

part 'src/tzdb/posix_tz.dart';
part 'src/tzdb/tzdb.dart';
part 'src/tzdb/zone_info_data.dart';
part 'src/tzdb/zone_info_reader.dart';
part 'src/tzdb/zone_info_record.dart';
