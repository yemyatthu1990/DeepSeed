import 'dart:math';

import 'package:deep_seed/constants.dart';
import 'package:deep_seed/navigation/Router.dart';
import 'package:deep_seed/ui/home/bottom_bar_screen.dart';
import 'package:deep_seed/ui/image_detail/image_editor.dart';
import 'package:deep_seed/util/Analytics.dart';
import 'package:deep_seed/util/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/rendering.dart';

void main() {
  // Set `enableInDevMode` to true to see reports while in debug mode
  // This is only to be used for confirming that reports are being
  // submitted as expected. It is not intended to be used for everyday
  // development.
  Crashlytics.instance.enableInDevMode = true;

  // Pass all uncaught errors from the framework to Crashlytics.
  FlutterError.onError = Crashlytics.instance.recordFlutterError;
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
          FocusScopeNode currentFocus = FocusScope.of(context);

          if (!currentFocus.hasPrimaryFocus) {
            currentFocus.unfocus();
          }
        },
        child: MaterialApp(
            title: 'Flutter Demo',
            onGenerateRoute: Router.generateRoute,
            initialRoute: bottomBarRoute,
            theme: ThemeData(
                // This is the theme of your application.
                //
                // Try running your application with "flutter run". You'll see the
                // application has a blue toolbar. Then, without quitting the app, try
                // changing the primarySwatch below to Colors.green and then invoke
                // "hot reload" (press "r" in the console where you ran "flutter run",
                // or simply save your changes to "hot reload" in a Flutter IDE).
                // Notice that the counter didn't reset back to zero; the application
                // is not restarted.
               cupertinoOverrideTheme: CupertinoThemeData(
                 primaryColor: Colors.white
                 ),




    // for others(Android, Fuchsia)
                cursorColor: Colors.white,
                primarySwatch: Colors.grey),
            home: Scaffold(
              body: BottomBarScreen(),
            )));
  }
}
