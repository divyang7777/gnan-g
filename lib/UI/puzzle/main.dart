import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kon_banega_mokshadhipati/UI/puzzle/config/ui.dart';
import 'package:kon_banega_mokshadhipati/UI/puzzle/play_games.dart';
import 'package:kon_banega_mokshadhipati/UI/puzzle/widgets/game/page.dart';

// class GameOfFifteen extends StatefulWidget {
//   @override
//   State<StatefulWidget> createState() {
//     // TODO: implement createState
//     return GameOfFifteenState();
//   }
// }

class GameOfFifteenState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return PlayGamesContainer(
      child: ConfigUiContainer(
        child: MyApp(),
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final title = 'Game of Fifteen';
    if (Platform.isIOS) {
      return _MyCupertinoApp(title: title);
    } else {
      // Every other OS is based on a material
      // design application.
      return _MyMaterialApp(title: title);
    }
  }
}

/// Base class for all platforms, such as
/// [Platform.isIOS] or [Platform.isAndroid].
abstract class _MyPlatformApp extends StatelessWidget {
  final String title;

  _MyPlatformApp({@required this.title});
}

class _MyMaterialApp extends _MyPlatformApp {
  _MyMaterialApp({@required String title}) : super(title: title);

  @override
  Widget build(BuildContext context) {
    final ui = ConfigUiContainer.of(context);

    // Get current theme from
    // a global state.
    final overlay = ui.useDarkTheme
        ? SystemUiOverlayStyle.light
        : SystemUiOverlayStyle.dark;
    final theme = ui.useDarkTheme ? ThemeData.dark() : ThemeData.light();

    SystemChrome.setSystemUIOverlayStyle(
      overlay.copyWith(
        statusBarColor: Colors.transparent,
      ),
    );

    return MaterialApp(
      title: title,
      theme: theme.copyWith(
        primaryColor: Colors.blue,
        accentColor: Colors.amberAccent,
        accentIconTheme: theme.iconTheme.copyWith(color: Colors.black),
        dialogTheme: const DialogTheme(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(16.0)),
          ),
        ),
      ),
      home: GamePage(),
    );
  }
}

class _MyCupertinoApp extends _MyPlatformApp {
  _MyCupertinoApp({@required String title}) : super(title: title);

  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      title: title,
    );
  }
}
