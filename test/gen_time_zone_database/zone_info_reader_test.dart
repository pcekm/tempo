@TestOn('!js')
import 'dart:convert';

import 'package:tempo/tempo.dart';
import 'package:tempo/timezone.dart';
import 'package:test/test.dart';

import '../../tool/gen_time_zone_database/zone_info_reader.dart';

// An abbreviated America/Los_Angeles base 64 encoded.
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

// America/Adak has indexes into the middle of a null-termanted string.
var adak = base64Decode("""
VFppZjIAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAQAAAAEAAAAAAAAAVFpp
ZjIAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAABUAAAACgAAACH/////P8L90f////99
h1pe/////8uJRND/////0iP0cP/////SYVBA//////rSVbD//////rhxUP//////qFRAAAAA
AACYU1AAAAAAAYg2QAAAAAACeDVQAAAAAANxUsAAAAAABGFR0AAAAAAFUTTAAAAAAAZBM9AA
AAAABzEWwAAAAAAHjW3QAAAAAAkQ+MAAAAAACa3pUAAAAAAK8NrAAAAAAAvg2dAAAAAADNn3
QAAAAAANwLvQAAAAAA652UAAAAAAD6nYUAAAAAAQmbtAAAAAABGJulAAAAAAEnmdQAAAAAAT
aZxQAAAAABRZf0AAAAAAFUl+UAAAAAAWOWFAAAAAABcpYFAAAAAAGCJ9wAAAAAAZCUJQAAAA
ABoCX8AAAAAAGisiIAAAAAAa8lDAAAAAABviM7AAAAAAHNIywAAAAAAdwhWwAAAAAB6yFMAA
AAAAH6H3sAAAAAAgdkdAAAAAACGB2bAAAAAAIlYpQAAAAAAjavYwAAAAACQ2C0AAAAAAJUrY
MAAAAAAmFe1AAAAAACcqujAAAAAAJ/8JwAAAAAApCpwwAAAAACne68AAAAAAKup+MAAAAAAr
vs3AAAAAACzTmrAAAAAALZ6vwAAAAAAus3ywAAAAAC9+kcAAAAAAMJNesAAAAAAxZ65AAAAA
ADJzQLAAAAAAM0eQQAAAAAA0UyKwAAAAADUnckAAAAAANjMEsAAAAAA3B1RAAAAAADgcITAA
AAAAOOc2QAAAAAA5/AMwAAAAADrHGEAAAAAAO9vlMAAAAAA8sDTAAAAAAD27xzAAAAAAPpAW
wAAAAAA/m6kwAAAAAEBv+MAAAAAAQYTFsAAAAABCT9rAAAAAAENkp7AAAAAARC+8wAAAAABF
RImwAAAAAEXz70ABAgMEAgUGBQYFBgUGBQYFBgUGBQYFBgUGBQYFBgUGBQYFBgcJCAkICQgJ
CAkICQgJCAkICQgJCAkICQgJCAkICQgJCAkICQgJCAkICQgJCAkICQgAAKviAAD//1piAAD/
/2VQAAT//3NgAQj//3NgAQz//2VQABD//3NgART//3NgABj//4FwAR3//3NgABlMTVQATlNU
AE5XVABOUFQAQlNUAEJEVABBSFNUAEhEVAAKSFNUMTBIRFQsTTMuMi4wLE0xMS4xLjAK
"""
    .replaceAll(RegExp(r'\s'), ''));

void main() {
  group('reads ZoneTransition records', () {
    var laTransitions = ZoneInfoReader(losAngeles).read().transitions;

    test('first / default', () {
      var first = laTransitions.first;
      expect(first.offset, NamedZoneOffset('LMT', false, -7, -52, -58));
      expect(first.transitionTime, Instant.minimum);
    });

    test('others', () {
      expect(laTransitions.map((e) => e.offset.name).toSet(),
          {'PST', 'PDT', 'PWT', 'PPT', 'LMT'});
      expect(
          laTransitions,
          contains(ZoneTransition((b) => b
            ..transitionTime =
                OffsetDateTime(ZoneOffset(-8), 2000, 4, 2, 2).asInstant
            ..offset = NamedZoneOffset('PDT', true, -7))));
    });

    test('designation index', () {
      var adakTransitions = ZoneInfoReader(adak).read().transitions;
      expect(adakTransitions.map((e) => e.offset.name).toSet(), {
        'LMT',
        'NST',
        'NWT',
        'NPT',
        'BST',
        'BDT',
        'AHST',
        'HST',
        'HDT'
      }); //containsAll([]));
    });
  });

  test('reads ZoneTransitionRule', () {
    var got = ZoneInfoReader(losAngeles).read();
    expect(
        got.rule,
        ZoneTransitionRule((b) => b
          ..stdName = 'PST'
          ..stdOffset = ZoneOffset(-8)
          ..dstName = 'PDT'
          ..dstStartRule.update((b) => b
            ..month = 3
            ..week = 2
            ..day = Weekday.sunday)
          ..stdStartRule.update((b) => b
            ..month = 11
            ..week = 1
            ..day = Weekday.sunday)));
  });
}
