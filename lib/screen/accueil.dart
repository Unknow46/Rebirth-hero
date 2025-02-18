import 'dart:ui';

import 'package:audioplayers/audio_cache.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:rebirth_hero/widgets/redirection.dart';

import '../widgets/button.dart';
import 'game.dart';


class Accueil extends StatefulWidget {

  const Accueil({Key key}):super(key: key);

  @override
  _AccueilState createState() => _AccueilState();
}



class _AccueilState extends State<Accueil> with TickerProviderStateMixin{
  // var to check if the player clicked on the screen to start the game
  var tapPlay = false;

  static AudioCache musicCache;
  static AudioPlayer instance;

  static const String background = 'assets/images/map/arena3.jpg';
  static const String boss = 'assets/images/boss/final_boss_1.jpg';
  static const String hero = 'assets/images/elements/hero.png';

  static var musicPlaying = false;

  double heroYPosition = 0;
  double bossYPosition = 1;

  double tapAlpha = 0;

  AnimationController _controller;
  Animation<dynamic> _animationHero;
  Animation<dynamic> _animationBoss;

  AnimationController _tapController;
  Animation<dynamic> _tapAnimation;

  AnimationController _fadeController;
  Animation<dynamic> _fadeAnimation;

  var fade = Colors.transparent;


  void initGame() {
    if (tapPlay) {
      _fadeController.forward();
    }
  }

  Future<AudioPlayer> playMusic() async {
    musicCache = AudioCache(prefix: 'audio/');
    return instance = await musicCache.loop('theme.mp3');
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
    _animationHero = Tween(begin: 1, end: 0.6).animate(
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
    _animationBoss = Tween(begin: 1, end: 0.6).animate(
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
    Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: _tapController, curve: Curves.decelerate))
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _tapController.reverse();
        } else if (status == AnimationStatus.dismissed) {
          _tapController.forward();
        }
      })
      ..addListener(() {
        setState(() {
          tapAlpha =  _tapAnimation.value;
        });
      });
    _fadeController = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _fadeAnimation = ColorTween(begin: Colors.transparent, end: Colors.black)
        .animate(CurvedAnimation(parent: _fadeController, curve: Curves.decelerate))
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          Navigator.pushReplacement(context,Redirection(const Game()));
        }
      })
      ..addListener(() {
        fade = _fadeAnimation.value;
      });
  }
  @override

  void initState() {
    super.initState();
    initTapAnimation();
    initAnimation();
  }

  Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
      if (state == AppLifecycleState.inactive && instance != null) {
        if (musicPlaying) {
          await instance.stop();
          musicPlaying = false;
        }
      } else if (state == AppLifecycleState.resumed) {
        if (!musicPlaying) {
          musicPlaying = true;
          await playMusic();
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
          Align(
            child: Align(
              alignment: const Alignment(0, -1),
              heightFactor: bossYPosition,
              child: Column(
                children: <Widget>[
                  Image.asset(
                    boss,
                    width: size /3,
                    height: size /3,
                    fit: BoxFit.cover,
                  ),
                ],
              ),
            ),
          ),
          BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: 4,
              sigmaY: 4,
            ),
            child: Align(
                alignment: Alignment.bottomCenter,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  Opacity(
                    opacity: tapAlpha,
                        child: Container(
                        alignment: Alignment.bottomCenter,
                        child: FancyButton(
                        size: MediaQuery.of(context).size.width / 10,
                        color: Colors.redAccent,
                            child: Text(
                            'TAP TO START',
                            style: TextStyle(
                            color: Colors.white,
                            fontSize:  MediaQuery.of(context).size.width /10,
                            fontFamily: 'EXXA-GAME'
                            ),
                            ),
                        ),
                        ),
                    ),
                  Image.asset(
                    hero,
                    width: size / 3,
                    height: size / 3,
                    fit: BoxFit.contain,
                  ),
                ],
                ),
              ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 15),
              child: FancyButton(
                size: 25,
                color: Colors.green,
                onPressed: () {
                  switchMusic();
                },
                child: Icon(
                  Icons.music_note,
                  size: 20,
                  color: musicPlaying ? Colors.white : Colors.black54,
                ),
              ),
            ),
          ),
          AnimatedContainer(
            duration: const Duration(seconds: 2),
            child: GestureDetector(
              onTap: initGame,
              child: Container(
                color: fade,
              ),
            ),
          ),
        ],
      );
    });
  }

}