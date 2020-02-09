import 'package:deep_seed/constants.dart';
import 'package:deep_seed/model/model.dart';
import 'package:deep_seed/ui/home/bottom_bar_screen.dart';
import 'package:deep_seed/ui/image_detail/image_editor.dart';
import 'package:flutter/material.dart';

class Router {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case bottomBarRoute:
        return MaterialPageRoute(builder: (_) => BottomBarScreen());
      case detailRoute:
        var data = settings.arguments as Map<String, dynamic>;

        return MaterialPageRoute(
            builder: (_) => ImageEditor(data["urls"], data["index"]));
      default:
        return MaterialPageRoute(
            builder: (_) => Scaffold(
                  body: Center(
                      child: Text('No route defined for ${settings.name}')),
                ));
    }
  }
}
