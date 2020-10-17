

import 'package:audioplayers/audio_cache.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'setup.dart';

class Game extends StatefulWidget {
  @override
  _GameState createState() => _GameState();
}

class _GameState extends State<Game> with WidgetsBindingObserver, TickerProviderStateMixin {
  AnimationController controller;
  var tap = false;
  var xAxis = 0.0;
  var yAxis = 0.0;
  int temps = 1000 * 30;
  int tempsBackup;
  var argent = 0;
  var argentGagne = false;
  var niveau = 1;
  AudioPlayer hitJoueur;
  AudioCache hitCache;
  AudioPlayer argentJoueur;
  AudioCache argentCache;
  static AudioCache musiqueCache;
  static AudioPlayer instance;
  var musicEnCours = false;
  Color clockColor = Colors.white;
  static var multiplicateur = 1.0;
  static var degatDefaut = 980.0;
  static var barreDegat = degatDefaut;
  static var degatJoeur = 30.0;
  static var tempsSupplementaire = 1000 * 10;
  VoidCallback onEarnTime;
  var gameOver = false;

  //Definition de la liste de boss
  var listBoss = Setup.getBoss();

  //Definitation de la liste de bonus
  var listBonus = Setup.getBonus();
  var bossIndex = 0;


  String get timer {
    // je me sers de animation controller afin de definir le chrono du jeu
    Duration duration = controller.duration * controller.value;
    return '${(duration.inMinutes).toString().padLeft(2, '0')}:${(duration.inSeconds % 60).toString().padLeft(2, '0')}';
  }

  void initJoueur() {
    hitJoueur = AudioPlayer();
    hitCache = AudioCache(fixedPlayer: hitJoueur);

    argentJoueur = AudioPlayer();
    argentCache = AudioCache(fixedPlayer: argentJoueur);
  }

  void lectureMusique() async {
    musiqueCache = AudioCache(prefix: 'audio/');
    instance = await musiqueCache.loop('battle_musique.mp3');
    await instance.setVolume(0.5);
  }

  void gameOverMusique() async {
    musiqueCache = AudioCache(prefix: 'audio/');
    instance = await musiqueCache.loop('game_over.mp3');
    await instance.setVolume(0.5);
  }

  void degat(TapDownDetails details) {
    setState(() {
      if (details != null) {
        xAxis = details.globalPosition.dx - 40.0;
        yAxis = details.globalPosition.dy - 80.0;
      }
      tap = true;
      //Si le joueur parvient a tuer le boss :
      if (barreDegat - degatJoeur <= 0) {
        argent = argent + 40;
        // definitation du multiplicateur (pour la barre de vie du boss)
        multiplicateur = (bossIndex + 1 >= listBoss.length)
            ? multiplicateur * 1.5
            : multiplicateur;
        niveau = (bossIndex + 1 >= listBoss.length) ? ++niveau : niveau;
        // augmentation du temps supplementaire
        tempsSupplementaire =
        (bossIndex + 1 >= listBoss.length) ? 1000 * 20 : 1000 * 10;
        //passage au prochain boss
        bossIndex = (bossIndex + 1 >= listBoss.length) ? 0 : ++bossIndex;
        //reinitialisation de la barre de degat (barre de bie du boss)
        barreDegat = listBoss[bossIndex].vie.toDouble() * multiplicateur;
        argentGagne = true;
        onEarnTime?.call();
        Future.delayed(const Duration(seconds: 1), () {
          setState(() {
            argentGagne = false;
          });
        });
      } else {
        barreDegat = barreDegat - degatJoeur;
      }
    });
  }

  void cache(TapUpDetails details) {
    setState(() {
      tap = false;
    });
  }

  double widthGame(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }

  double heightGame(BuildContext context) {
    return widthGame(context) >= 700 ? heightGame(context) : heightGame(context) / 2.8;
  }

  double listItemHeight(BuildContext context) {
    return widthGame(context) >= 700 ? heightGame(context) : heightGame(context) / 2.8;
  }

  void achatBonus(int index) {
    setState(() {
      if (argent >= listBonus[index].argent) {
        argent = argent - listBonus[index].argent;
        listBonus[index].achete = true;
        degatJoeur = degatJoeur * listBonus[index].multDgt;
      }
    });
  }

  //Mise en place du widget pour afficher l argent (img)
  Widget visibiliteArgent(bool achete) {
    if (achete) {
      return Container();
    } else {
      return Padding(
        padding: const EdgeInsets.only(right: 4.0),
        child: Image.asset(
          'assets/elements/argent.png',
          width: 10,
          height: 10,
        ),
      );
    }
  }

  //Mise en place widget affichage argent gagne
  Widget argentGagneWidget() {
    if (argentGagne) {
      return Padding(
        padding: const EdgeInsets.only(left: 5.0),
        child: Material(
          color: Colors.transparent,
          child: Text(
            '+40',
          ),
        ),
      );
    } else {
      return Container(
        width: 0.0,
        height: 0.0,
      );
    }
  }

  //Mise en place hitbox du joueur
  Widget hitBox() {
    if(tap) {
      return Positioned(
        top: yAxis,
        left: xAxis,
        child: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(bottom: 20.0),
            child: Material(
              color: Colors.transparent,
              child: DegatJoueurText(
                '-${degatJoeur.toInt().toString()}',
                tailleFont: 14.0,
                familleFont: 'Gameplay',
                color: Colors.red,
                degatCouleur: Colors.black,
                degatWidth: 1.0,
              ),
            ),
          ),
          Image.asset(
            'assets/elements/hit_player.png',
            fit: BoxFit.fill,
            height: 80.0,
            width: 80.0,
          )
        ],
        ),
      );
    } else {
      return Container();
    }
  }

  void changementMusique() {
    lectureMusique();
    musicEnCours = true;
  }

  Widget moteurDeJeu(BuildContext context) {
    return widthGame(context) >= 700
        ? Row(
      children: <Widget>[
        jeu(),
       // autres(),
      ],
    )
        : Column(
      children: <Widget>[
        jeu(),
       // autres(),
      ],
    );
  }

  //Mise en place de la vue du jeu, situe sur la partie haute de l ecran
  Widget jeu() {
    return Align(
      alignment: Alignment.topCenter,
      child: Container(
        color: Colors.transparent,
        height: widthGame(context) >= 700 ? heightGame(context) : heightGame(context) - listItemHeight(context),
        width: widthGame(context) >= 700
            ? widthGame(context) >= 700 && widthGame(context) <= 900 ? 400 : widthGame(context) - 400
            : widthGame(context),
        ),
      );
  }

  //Mise en place des elements du jeu (bonus)
  Widget autres() {

  }

  Widget affichageGameOver() {

  }


  // mise en place du chrono pour la partie
  void initClock({int add}) {
    if (controller == null) {
      //si le controller est null je defini le temps backup a mon temps actuel
      tempsBackup  = temps;
    } else {
      //calcul du temps actuel lors de la fin d'une manche
      Duration tempsActuel = controller.duration * controller.value;
      tempsBackup = tempsActuel.inMilliseconds;
      controller.stop();
    }

    // reinitialisation du controller en ajoutant le temps supplementaire
    controller = null;
    controller = AnimationController(vsync: this, duration: Duration(milliseconds: tempsBackup + add));
    controller.reverse(from: controller.value == 0.0 ? 1.0 : controller.value);
    controller.addListener(() {
      setState(() {
        timer;

        //calcul du temps actuel
        Duration duration = controller.duration * controller.value;

        if (duration.inSeconds >= 0 && (duration.inSeconds % 60) > 20) {
          clockColor = Colors.white;
        }

        if (duration.inSeconds == 0 && (duration.inSeconds % 60) < 20) {
          clockColor = Colors.yellowAccent;
        }

        if (duration.inSeconds == 0 && (duration.inSeconds % 60) < 10) {
          clockColor = Colors.red;
        }
      });
    });
    //si le temps se termine alors la partie est termine
    controller.addStatusListener((status) {
      if (status == AnimationStatus.dismissed) {
        setState(() {
          gameOver = true;
        });
      }
    });
  }

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    super.initState();
    if (!musicEnCours) {
       musicEnCours = true;
       lectureMusique();
    }
    // au debut de la partie pas de temps suppl
    initClock(add: 0);
    //quand le joueur arrive a finir la manche dans le temps impartis
    //ajout du temps supplementaire
    onEarnTime = () {
      initClock(add: tempsSupplementaire);
    };
    barreDegat = listBoss[bossIndex].vie.toDouble() * multiplicateur;
  }

  @override
  void dispose() {
      if (musicEnCours && instance != null) {
        instance.stop();
        musicEnCours = false;
    }
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }



  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return Material(
        child: Stack(
          children: <Widget>[
            moteurDeJeu(context),
            affichageGameOver(),
          ],
        ),
      );
    });
  }
}