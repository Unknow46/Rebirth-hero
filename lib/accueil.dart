import 'dart:ui';

import 'package:audioplayers/audio_cache.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

class Accueil extends StatefulWidget {
  @override
  _AccueilState createState() => _AccueilState();
}

class _AccueilState extends State<Accueil> with WidgetsBindingObserver, TickerProviderStateMixin {
  static AudioCache musicCache;
  static AudioPlayer instance;

  static final String background = "assets/background/arena.jpg";
  static final String boss = "assets/background/demon.jpg";
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final size = constraints.biggest.longestSide;
      return Stack(
        children: <Widget>[
          SizedBox.expand(
            child: Image.asset(
              background,
              fit: BoxFit.cover,
            ),
          ),
          Align(
            alignment: Alignment.center,
            child: Align(
              alignment: Alignment(0.0, -1.0),
              //heightFactor: bossYAxis,
              child: Image.asset(
                boss,
                width: size/2,
                height: size/2,
                fit: BoxFit.cover,
              ),
            ),
          ),
        ],
      );
    });
  }

}