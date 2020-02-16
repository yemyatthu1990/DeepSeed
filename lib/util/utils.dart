import 'dart:math';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class Utils {
  static Map<String, int> randomColor(String value) {
    var sum = 0;
    for (var i = 0; i < value.length; i++) {
      sum += value.codeUnitAt(i);
    }
    int r = (double.parse('0.' + sin(sum + 1).toString().substring(6)) * 256)
        .floor();

    int g = (double.parse('0.' + sin(sum + 2).toString().substring(6)) * 256)
        .floor();

    int b = (double.parse('0.' + sin(sum + 3).toString().substring(6)) * 256)
        .floor();
    return {"r": r, "g": g, "b": b};
  }

  static shareImage(String path) async {
    try {
      final channel =
          const MethodChannel('channel:co.deepseed.deep_seed/share');
      channel.invokeMethod('shareFile', path);
    } catch (e) {
      print('Share error: $e');
    }
  }

  static String readTimestamp(int timestamp) {
    var now = DateTime.now();
    var format = DateFormat('HH:mm a');
    var date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    var diff = now.difference(date);
    var time = '';

    if (diff.inSeconds <= 0 ||
        diff.inSeconds > 0 && diff.inMinutes == 0 ||
        diff.inMinutes > 0 && diff.inHours == 0 ||
        diff.inHours > 0 && diff.inDays == 0) {
      time = "Today, " + format.format(date);
    } else if (diff.inDays > 0 && diff.inDays < 7) {
      if (diff.inDays == 1) {
        time = diff.inDays.toString() + ' DAY AGO';
      } else {
        time = diff.inDays.toString() + ' DAYS AGO';
      }
    } else {
      if (diff.inDays == 7) {
        time = (diff.inDays / 7).floor().toString() + ' WEEK AGO';
      } else {
        time = (diff.inDays / 7).floor().toString() + ' WEEKS AGO';
      }
    }

    return time;
  }
}
