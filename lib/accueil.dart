import 'dart:ui';
import 'package:rebirth_hero/game.dart';
import 'package:rebirth_hero/redirection.dart';
import 'button.dart';
import 'package:rebirth_hero/particles.dart';

import 'package:audioplayers/audio_cache.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';


class Accueil extends StatefulWidget {
  @override
  _AccueilState createState() => _AccueilState();
}

class _AccueilState extends State<Accueil> with WidgetsBindingObserver, TickerProviderStateMixin {
  // var to check if the player clicked on the screen to start the game
  var tapPlay = false;

  static AudioCache musicCache;
  static AudioPlayer instance;

  static final String background = "assets/background/map/arena3.jpg";
  static final String boss = "assets/background/boss/final_boss_1.jpg";
  static final String hero = "assets/background/elements/hero.png";
  static final String logo = "assets/background/logo_fges.jpg";

  static var musicPlaying = false;

  var heroYPosition = 0.0;
  var bossYPosition = 1.0;

  var tapAlpha = 0.0;

  AnimationController _controller;
  Animation _animationHero;
  Animation _animationBoss;

  AnimationController _tapController;
  Animation _tapAnimation;

  AnimationController _fadeController;
  Animation _fadeAnimation;

  var fade = Colors.transparent;


  void initGame() {
    if (tapPlay) _fadeController.forward();
  }

  void playMusic() async {
    musicCache = AudioCache(prefix: "audio/");
    instance = await musicCache.loop("theme.mp3");
  }
  void switchMusic() {
      if (musicPlaying && instance != null) {
        instance.pause();
        musicPlaying = false;
      } else {
        playMusic();
        musicPlaying = true;
      }
  }
  @override
  void didChangeDependencies() {
      if (!musicPlaying) {
        musicPlaying = true;
        playMusic();
    }
    super.didChangeDependencies();
  }

  void initAnimation() {
    _controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 5));
    _animationHero = Tween(begin: 1.0, end: 0.8).animate(
        CurvedAnimation(parent: _controller, curve: Curves.decelerate))
      ..addStatusListener((state) {
        if (state == AnimationStatus.completed) {
          setState(() {
            tapPlay = true;
          });
          _tapController.forward();
        }
      })
      ..addListener(() {
        setState(() {
          heroYPosition = _animationHero.value;
        });
      });
    _animationBoss = Tween(begin: 1.0, end: 0.6).animate(
        CurvedAnimation(parent: _controller, curve: Curves.decelerate))
      ..addListener(() {
        setState(() {
          bossYPosition = _animationBoss.value;
        });
      });

    _controller.forward();
  }

  void initTapAnimation() {
    _tapController = AnimationController(vsync: this, duration: const Duration(seconds: 1));
    _tapAnimation =
    Tween(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _tapController, curve: Curves.decelerate))
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _tapController.reverse();
        } else if (status == AnimationStatus.dismissed) {
          _tapController.forward();
        }
      })
      ..addListener(() {
        setState(() {
          tapAlpha = _tapAnimation.value;
        });
      });


    _fadeController = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _fadeAnimation = ColorTween(begin: Colors.transparent, end: Colors.black)
        .animate(CurvedAnimation(parent: _fadeController, curve: Curves.decelerate))
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          Navigator.pushReplacement(context,Redirection(Game()));
        }
      })
      ..addListener(() {
        fade = _fadeAnimation.value;
      });
  }
  @override

  void initState() {
    WidgetsBinding.instance.addObserver(this);
    super.initState();
    initTapAnimation();
    initAnimation();
  }
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
      if (state == AppLifecycleState.inactive && instance != null) {
        if (musicPlaying) {
          instance.stop();
          musicPlaying = false;
        }
      } else if (state == AppLifecycleState.resumed) {
        if (!musicPlaying) {
          musicPlaying = true;
          playMusic();
        }
      }
  }

  void disposeAnimations() {
    _controller.dispose();
    _tapController.dispose();
    _fadeController.dispose();
  }
  @override
  void dispose() {
    disposeAnimations();
    if (musicPlaying && instance != null) {
      instance.stop();
      musicPlaying = false;
    }

    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

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
          Positioned.fill(child: Particles(25)),
          Align(
            alignment: Alignment.center,
            child: Align(
              alignment: Alignment(0.0, -1.0),
              heightFactor: bossYPosition,
              child: Image.asset(
                boss,
                width: size /2,
                height: size /2,
                fit: BoxFit.cover,
              ),
            ),
          ),
          BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: 4.0,
              sigmaY: 4.0,
            ),
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Align(
                alignment: Alignment.bottomCenter,
                heightFactor: heroYPosition,
                child: Image.asset(
                  hero,
                  width: size / 2,
                  height: size / 2,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
          SafeArea(
            bottom: false,
            child: Container(
              alignment: Alignment.topCenter,
              padding: EdgeInsets.only(top: constraints.maxHeight * 0.04, left: 15.0, right: 15.0),
              child: Image.asset(
                logo,
                height: 150.0 /2,
                fit: BoxFit.contain,
              ),
            ),
          ),
          SafeArea(
            child: Opacity(
              opacity: 1.0,
              child: Container(
                alignment: Alignment.bottomCenter,
                padding: EdgeInsets.only(bottom: constraints.maxHeight * 0.10),
                child: Image.asset(
                  "assets/background/elements/tapstart.jpg",
                  height: size,
                  width: size,
                ),
              ),
            ),
          ),
          AnimatedContainer(
            duration: Duration(seconds: 2),
            child: GestureDetector(
              onTap: initGame,
              child: Container(
                color: fade,
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 20, horizontal: 15),
              child: FancyButton(
                child: Icon(
                  Icons.music_note,
                  size: 20,
                  color: musicPlaying ? Colors.white : Colors.black54,
                ),
                size: 25,
                color: Color(0xFF67AC5B),
                onPressed: () {
                  switchMusic();
                },
              ),
            ),
          ),
        ],
      );
    });
  }

}