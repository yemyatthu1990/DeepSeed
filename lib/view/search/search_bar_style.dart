import 'dart:ui';

import 'package:flutter/material.dart';

class SearchBarStyle {
  final Color backgroundColor;
  final EdgeInsetsGeometry padding;
  final BorderRadius borderRadius;

  const SearchBarStyle(
      {this.backgroundColor = const Color.fromRGBO(142, 142, 147, .15),
      this.padding = const EdgeInsets.only(left: 8, right: 8),
      this.borderRadius: const BorderRadius.all(Radius.circular(5.0))});
}
