import 'dart:convert';

import 'package:goodtime/goodtime.dart';
import 'package:goodtime/src/zonedb.dart';
import 'package:test/test.dart';

// America/Los_Angeles in version 2023c:
var losAngeles = base64Decode("""
VFppZjIAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAQAAAAEAAAAAAAAAVFpp
ZjIAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAB9AAAABQAAABT/////XgQawP////+e
pkig/////5+7FZD/////oIYqoP////+hmveQ/////8uJGqD/////0iP0cP/////SYSYQ////
/9b+dFz/////2ICtkP/////a/sOQ/////9vAkBD/////3N6lkP/////dqayQ/////96+h5D/
////34mOkP/////gnmmQ/////+FpcJD/////4n5LkP/////jSVKQ/////+ReLZD/////5Sk0
kP/////mR0oQ/////+cSURD/////6CcsEP/////o8jMQ/////+oHDhD/////6tIVEP/////r
5vAQ/////+yx9xD/////7cbSEP/////ukdkQ/////++v7pD/////8HG7EP/////xj9CQ////
//J/wZD/////82+ykP/////0X6OQ//////VPlJD/////9j+FkP/////3L3aQ//////goohD/
////+Q9YkP/////6CIQQ//////r4gyD/////++hmEP/////82GUg//////3ISBD//////rhH
IP//////qCoQAAAAAACYKSAAAAAAAYgMEAAAAAACeAsgAAAAAANxKJAAAAAABGEnoAAAAAAF
UQqQAAAAAAZBCaAAAAAABzDskAAAAAAHjUOgAAAAAAkQzpAAAAAACa2/IAAAAAAK8LCQAAAA
AAvgr6AAAAAADNnNEAAAAAANwJGgAAAAAA65rxAAAAAAD6muIAAAAAAQmZEQAAAAABGJkCAA
AAAAEnlzEAAAAAATaXIgAAAAABRZVRAAAAAAFUlUIAAAAAAWOTcQAAAAABcpNiAAAAAAGCJT
kAAAAAAZCRggAAAAABoCNZAAAAAAGvI0oAAAAAAb4heQAAAAABzSFqAAAAAAHcH5kAAAAAAe
sfigAAAAAB+h25AAAAAAIHYrIAAAAAAhgb2QAAAAACJWDSAAAAAAI2raEAAAAAAkNe8gAAAA
ACVKvBAAAAAAJhXRIAAAAAAnKp4QAAAAACf+7aAAAAAAKQqAEAAAAAAp3s+gAAAAACrqYhAA
AAAAK76xoAAAAAAs036QAAAAAC2ek6AAAAAALrNgkAAAAAAvfnWgAAAAADCTQpAAAAAAMWeS
IAAAAAAycySQAAAAADNHdCAAAAAANFMGkAAAAAA1J1YgAAAAADYy6JAAAAAANwc4IAAAAAA4
HAUQAAAAADjnGiAAAAAAOfvnEAAAAAA6xvwgAAAAADvbyRAAAAAAPLAYoAAAAAA9u6sQAAAA
AD6P+qAAAAAAP5uNEAAAAABAb9ygAAAAAEGEqZAAAAAAQk++oAAAAABDZIuQAAAAAEQvoKAA
AAAARURtkAAAAABF89MgAgECAQIDBAIBAgECAQIBAgECAQIBAgECAQIBAgECAQIBAgECAQIB
AgECAQIBAgECAQIBAgECAQIBAgECAQIBAgECAQIBAgECAQIBAgECAQIBAgECAQIBAgECAQIB
AgECAQIBAgECAQIBAgECAQIBAgECAQIBAgECAQIBAgH//5EmAAD//52QAQT//4+AAAj//52Q
AQz//52QARBMTVQAUERUAFBTVABQV1QAUFBUAApQU1Q4UERULE0zLjIuMCxNMTEuMS4wCg==
"""
    .replaceAll(RegExp(r'\s'), ''));

void main() {
  var zi = ZoneInfoReader('America/Los Angeles', losAngeles).read();

  test('name', () {
    expect(zi.name, 'America/Los Angeles');
  });

  group('timeZoneFor()', () {
    test('standard time', () {
      var tz = zi.timeZoneFor(OffsetDateTime(ZoneOffset(-8), 2000, 1, 1));
      expect(tz.designation, 'PST');
      expect(tz.isDst, false);
      expect(tz.offset, ZoneOffset(-8));
    });

    test('daylight savings', () {
      var tz = zi.timeZoneFor(OffsetDateTime(ZoneOffset(-7), 2000, 6, 1));
      expect(tz.designation, 'PDT');
      expect(tz.isDst, true);
      expect(tz.offset, ZoneOffset(-7));
    });

    test('before table falls back to posix TZ - std time', () {
      var tz = zi.timeZoneFor(OffsetDateTime(ZoneOffset(-8), 1500, 1, 1));
      expect(tz.designation, 'PST');
      expect(tz.isDst, false);
      expect(tz.offset, ZoneOffset(-8));
    });

    test('before table falls back to posix TZ - dst', () {
      var tz = zi.timeZoneFor(OffsetDateTime(ZoneOffset(-8), 1500, 6, 1));
      expect(tz.designation, 'PDT');
      expect(tz.isDst, true);
      expect(tz.offset, ZoneOffset(-7));
    });

    test('after table falls back to posix TZ - std time', () {
      var tz = zi.timeZoneFor(OffsetDateTime(ZoneOffset(-8), 2500, 1, 1));
      expect(tz.designation, 'PST');
      expect(tz.isDst, false);
      expect(tz.offset, ZoneOffset(-8));
    });

    test('after table falls back to posix TZ - dst', () {
      var tz = zi.timeZoneFor(OffsetDateTime(ZoneOffset(-8), 2500, 6, 1));
      expect(tz.designation, 'PDT');
      expect(tz.isDst, true);
      expect(tz.offset, ZoneOffset(-7));
    });
  });
}
