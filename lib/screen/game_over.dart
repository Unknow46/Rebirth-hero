import 'package:audioplayers/audio_cache.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:rebirth_hero/data/model/boss.dart';
import 'package:rebirth_hero/widgets/button.dart';
import 'package:rebirth_hero/widgets/redirection.dart';

import 'accueil.dart';

// ignore: must_be_immutable
class GameOver extends StatelessWidget {

  GameOver({Key key, this.musiqueCache, this.instance, this.gameOver, this.musicEnCours,
  this.listBoss, this.bossIndex})
      :super(key: key);

  AudioCache musiqueCache;
  AudioPlayer instance;
  dynamic gameOver;
  dynamic musicEnCours;
  List<Boss> listBoss;
  int bossIndex;

  double widthGame(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }

  Future<AudioPlayer> gameOverMusique() async {
    musiqueCache = AudioCache(prefix: 'audio/');
    return instance = await musiqueCache.loop('game_over.mp3');
  }

  @override
  Widget build(BuildContext context) {
      if(gameOver) {
        if (musicEnCours && instance != null) {
          instance.stop();
          musicEnCours = false;
        }
        if (!musicEnCours) {
          musicEnCours = true;
          gameOverMusique();
        }
        return Stack(
          children: <Widget>[
            Container(
              color: Colors.black,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Image.asset(
                    listBoss[bossIndex].img,
                  ),
                  Text(
                    'Tué par ${listBoss[bossIndex].nom}' , style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold
                  ),
                  ),
                  Text(
                    listBoss[bossIndex].taunt , style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold
                  ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          FancyButton(
                            size: widthGame(context) /10,
                            color: Colors.redAccent,
                            onPressed: () {
                              Navigator.of(context).pushReplacement(Redirection(const Accueil()));
                            },
                            child: Text(
                              'GAME OVER',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: widthGame(context) /12,
                                  fontFamily: 'Gameplay'
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Text(
                    'Tu vas abandonner seulement maintenant ?',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: widthGame(context) /12,
                        fontFamily: 'Gameplay'
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      } else {
        return Container();
      }
    }
  }
