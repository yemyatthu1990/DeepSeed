import 'package:deep_seed/constants.dart';
import 'package:deep_seed/ui/home/bottom_bar_screen.dart';
import 'package:deep_seed/ui/image_detail/image_editor.dart';
import 'package:deep_seed/ui/profile/profile_detail.dart';
import 'package:flutter/material.dart';

class Router {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case bottomBarRoute:
        return MaterialPageRoute(builder: (_) => BottomBarScreen());
      case detailRoute:
        var data = settings.arguments as Map<String, dynamic>;
        return ScaleRoute(
            page: ImageEditor(
                data["urls"],
                data["photographer_name"],
                data["username"],
                data["index"],
                data["temp_file_url"],
                data["file_url"],
                data["hero_tag"]));

      case profileDetailRoute:
        var data = settings.arguments as Map<String, dynamic>;
        return ScaleRoute(
            page: ProfileDetailDialog(
          filePath: data["file_url"],
          heroTag: data["hero_tag"],
        ));

      default:
        return MaterialPageRoute(
            builder: (_) => Scaffold(
                  body: Center(
                      child: Text('No route defined for ${settings.name}')),
                ));
    }
  }
}

class ScaleRoute extends PageRouteBuilder {
  final Widget page;

  ScaleRoute({this.page})
      : super(
            pageBuilder: (
              BuildContext context,
              Animation<double> animation,
              Animation<double> secondaryAnimation,
            ) =>
                page,
            transitionsBuilder: (
              BuildContext context,
              Animation<double> animation,
              Animation<double> secondaryAnimation,
              Widget child,
            ) =>
                FadeTransition(
                  opacity: animation,
                  child: child,
                ));
}
