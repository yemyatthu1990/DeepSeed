import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:flutter/painting.dart' as pt;

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

  static Future<List> shareImage(String path, String shareText) async {
    try {
      final channel =
          const MethodChannel('channel:co.deepseed.deep_seed/share');
      return channel.invokeListMethod(
          'shareFile', {"path": path, "shareText": shareText});
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

  static bool useWhiteForeground(Color color) {
    return 1.05 / (color.computeLuminance() + 0.05) > 4.5 && color.alpha > 120;
  }

  /// reference: https://en.wikipedia.org/wiki/HSL_and_HSV#HSV_to_HSL
  static HSLColor hsvToHsl(HSVColor color) {
    double s = 0.0;
    double l = 0.0;
    l = (2 - color.saturation) * color.value / 2;
    if (l != 0) {
      if (l == 1)
        s = 0.0;
      else if (l < 0.5)
        s = color.saturation * color.value / (l * 2);
      else
        s = color.saturation * color.value / (2 - l * 2);
    }
    return HSLColor.fromAHSL(color.alpha, color.hue, s, l);
  }

  /// reference: https://en.wikipedia.org/wiki/HSL_and_HSV#HSL_to_HSV
  static HSVColor hslToHsv(HSLColor color) {
    double s = 0.0;
    double v = 0.0;

    v = color.lightness +
        color.saturation *
            (color.lightness < 0.5 ? color.lightness : 1 - color.lightness);
    if (v != 0) {
      s = 2 - 2 * color.lightness / v;
    }

    return HSVColor.fromAHSV(color.alpha, color.hue, s, v);
  }

  static bool isUnicode() {
    final String text = "\u1000\u1039\u1000";
    final Size txtSize = _getTextSize(text);
    final Size secondTxtSize = _getTextSize("\u1000");
    return txtSize.width == secondTxtSize.width;
  }

  static Size _getTextSize(String text) {
    final TextPainter textPainter = TextPainter(
        text: TextSpan(text: text),
        maxLines: 1,
        textDirection: pt.TextDirection.ltr)
      ..layout(minWidth: 0, maxWidth: double.infinity);
    return textPainter.size;
  }
}
