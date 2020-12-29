import 'package:audioplayers/audio_cache.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rebirth_hero/data/model/bonus.dart';
import 'package:rebirth_hero/screen/game_over.dart';
import 'package:rebirth_hero/widgets/button.dart';
import 'package:rebirth_hero/widgets/hit_box.dart';
import 'package:rebirth_hero/widgets/money_system.dart';
import 'package:rebirth_hero/widgets/redirection.dart';
import 'package:rebirth_hero/widgets/scroll.dart';
import '../widgets/setup.dart';
import 'accueil.dart';

class Game extends StatefulWidget {
  const Game({Key key}): super(key: key);

  @override
  _GameState createState() => _GameState();
}

// ignore: prefer_mixin
class _GameState extends State<Game> with TickerProviderStateMixin, WidgetsBindingObserver {
  AnimationController controller;
  var tap = false;
  var xAxis = 0.0;
  var yAxis = 0.0;
  int temps = 1000 * 30;
  int tempsBackup;
  var argent = 0;
  var argentGagne = false;
  var niveau = 1;
  static AudioCache musiqueCache;
  static AudioPlayer instance;
  var musicEnCours = false;
  Color clockColor = Colors.white;
  static var multiplicateur = 1.0;
  static var vieDefaut = 980.0;
  static var barreVie = vieDefaut;
  static var degatJoueur = 30.0;
  static var tempsSupplementaire = 1000 * 10;
  VoidCallback onEarnTime;
  var gameOver = false;


  final _gamepadTouched = false;

  static String cielAsset() => 'assets/images/map/sky.png';
  static String areneAsset() => 'assets/images/map/ruins.png';
  static String heroAsset () => 'assets/images/elements/hero.png';


  //Definition de la liste de boss
  var listBoss = Setup.getBoss();

  //Definitation de la liste de bonus
  var listBonus = Setup.getBonus();
  var bossIndex = 0;

  String get timer {
    // je me sers de animation controller afin de definir le chrono du jeu
    final duration = controller.duration * controller.value;
    return '${(duration.inMinutes).toString().padLeft(2, '0')}:${(duration.inSeconds % 60).toString().padLeft(2, '0')}';
  }

  Future<AudioPlayer> lectureMusique() async {
    musiqueCache = AudioCache(prefix: 'audio/');
    return instance = await musiqueCache.loop('battle_musique.mp3');
  }

  Future<AudioPlayer> gameOverMusique() async {
    musiqueCache = AudioCache(prefix: 'audio/');
    return instance = await musiqueCache.loop('game_over.mp3');
  }

  void degat(TapDownDetails details) {
    setState(() {
      if (details != null) {
        xAxis = details.globalPosition.dx - 40.0;
        yAxis = details.globalPosition.dy - 80.0;
      }
      tap = true;
      //Si le joueur parvient a tuer le boss :
      if (barreVie - degatJoueur <= 0) {
        argent = argent + 20;
        // definitation du multiplicateur (pour la barre de vie du boss)
        multiplicateur = (bossIndex + 1 >= listBoss.length)
            ? multiplicateur * 1.5
            : multiplicateur;
        niveau = (bossIndex + 1 >= listBoss.length) ? ++niveau : niveau;
        // augmentation du temps supplementaire (30 sec en plus)
        tempsSupplementaire =
        (bossIndex + 1 >= listBoss.length) ? 1000 * 20 : 1000 * 10;
        //passage au prochain boss
        bossIndex = (bossIndex + 1 >= listBoss.length) ? 0 : ++bossIndex;
        //reinitialisation de la barre de degat (barre de bie du boss)
        barreVie = listBoss[bossIndex].vie.toDouble() * multiplicateur;
        argentGagne = true;
        onEarnTime?.call();
        Future.delayed(const Duration(seconds: 1), () {
          setState(() {
            argentGagne = false;
          });
        });
      } else {
        barreVie = barreVie - degatJoueur;
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
    return MediaQuery.of(context).size.height;
  }

  double listItemHeight(BuildContext context) {
    return widthGame(context) >= 700 ? heightGame(context) : heightGame(context) / 2.8;
  }

  void achatBonus(int index) {
    setState(() {
      if (argent >= listBonus[index].argent) {
        argent = argent - listBonus[index].argent;
        listBonus[index].achete = true;
        degatJoueur = degatJoueur * listBonus[index].multDgt;
      }
    });
  }

  //Mise en place du widget pour afficher l argent (img)

  Widget visibiliteArgent(dynamic achete) {
    if (achete) {
      return Container();
    } else {
      return Padding(
        padding: const EdgeInsets.only(right: 4),
        child: Image.asset(
          'assets/images/elements/gold_coin.png',
          width: 20,
          height: 20,
        ),
      );
    }
  }

  //Mise en place widget affichage argent gagne

  //Mise en place hitbox du joueur
  
  void changementMusique() {

    if (musicEnCours && instance != null){
      instance.pause();
      musicEnCours = false;
    }else {
      lectureMusique();
      musicEnCours = true;
    }
  }

  Widget moteurDeJeu(BuildContext context) {
    //Disposition du jeu en colonne
    return  Column(
              children: <Widget>[
                  game(),
                  shop(),
              ],
    );
  }
  
  //Mise en place de la vue du game, situe sur la partie haute de l ecran
  Widget game() {
    return Align(
      alignment: Alignment.topCenter,
      child: Container(
        color: Colors.transparent,
        //la zone restante sera l'emplacement du shop
        height: heightGame(context) - listItemHeight(context),
        width: widthGame(context),
        child: Stack(
          children: <Widget>[
            SizedBox.expand(
              child: Image.asset(
                cielAsset(),
              fit: BoxFit.cover
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Image.asset(
                areneAsset(),
                alignment: Alignment.bottomCenter,
                fit:BoxFit.fitWidth
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 60),
                child: Image.asset(
                  listBoss[bossIndex].img,
                  height: widthGame(context) / 2.5,
                  fit: BoxFit.fill,
                  color: tap ?  Colors.redAccent : null,
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Image.asset(
                  heroAsset(),
                  height: widthGame(context) / 6 < 160 ? widthGame(context) / 6 : 160,
                  fit: BoxFit.fill,
                  alignment: Alignment.bottomCenter,
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(vertical: 10),
              child: SafeArea(
                child: Align(
                  alignment: Alignment.topCenter,
                  child: Column(
                    children: <Widget>[
                      Align(
                        alignment: Alignment.topRight,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 10, bottom: 20, right: 15),
                          child: Stack(children: <Widget>[
                            FancyButton(size: 20, color: Colors.green,
                              child: Text(
                                '         $timer', style: const TextStyle(
                                fontSize: 20,
                                color: Colors.black,),)
                                ),
                            FancyButton( size: 20, color: clockColor, child: const Icon(
                                  Icons.watch_later,
                                  color: Colors.black45,
                                  size: 20,
                                  ),)
                          ],),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Text(
                          '${listBoss[bossIndex].nom}   LVL $niveau',
                          style: Setup.textStyle(15)
                        ),
                      ),
                      FancyButton(
                          size: 18, color: Colors.red,
                          child: Text(
                          'POINT DE VIE: ${barreVie.toInt().toString()}',
                          style: Setup.textStyle(18),
                          ),),
                      Padding(
                          padding: const EdgeInsets.all(8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text(
                              'Argent :   ',
                              style: Setup.textStyle(10),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 5),
                              child: Text(
                                '$argent   ',
                                style: Setup.textStyle(10),
                              ),
                            ),
                            Image.asset(
                              'assets/images/elements/gold_coin.png',
                              height: 16.2,
                            ),
                            Money().argentGagneWidget(argentGagne)
                          ],
                        )
                      )
                    ],
                  ),
                ),
              ),
            ),
            GestureDetector(
              onTapDown: degat,
              onTapUp: (TapUpDetails details) => cache(null),
              onTapCancel: () => cache(null),
            ),
            if (_gamepadTouched) Container() else HitBox().hitBox(tap, yAxis, xAxis, degatJoueur),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 15),
                child: Row(
                  children: <Widget>[
                    FancyButton(size: 25, color: Colors.red,
                                onPressed: () {
                      Navigator.of(context).pushReplacement(Redirection(const Accueil()));
                    },
                    child: const Text(
                    'X',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontFamily: 'EXXA-GAME',
                    ),
                    ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 10),
                      child: FancyButton( size: 25, color: Colors.green, onPressed: () {
                        changementMusique();
                      },
                      child: Icon(
                      Icons.music_note,
                      size: 20,
                      color: musicEnCours ? Colors.white : Colors.black12,
                      ),),
                    )
                  ],
                ),
              ),
            )
          ]
        ),
        ),
      );
  }

  //Mise en place des elements du jeu (item bonus)
  Widget shop() {
    return Container(
      color: Colors.black,
      height: listItemHeight(context),
      width: widthGame(context),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(child: Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 15),
                  child: Text(
                    'Item Shop',
                    style: Setup.textStyle(12),
                  ),
                ),
              )
              )
            ],
          ),
          Expanded(
            child: ScrollConfiguration(
              behavior: Scrolling(),
              child: ListView.builder(
                padding: const EdgeInsets.only(bottom: 20, left: 10, right: 10),
                itemCount: listBonus.length,
                itemBuilder: (context, position) {
                  final bonus = listBonus[position];
                  final bgColor = !bonus.achete && argent >= bonus.argent ?
                  Colors.amberAccent : !bonus.achete ? Colors.grey: Colors.green;
                  return itemEnable(bgColor, bonus, position);
                },
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget itemEnable(Color bgColor, Bonus bonus, int position) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 5,
      ),
      child: Container(
        height: 70,
        child: Card(
          color: bgColor,
          child: Row(
            children: <Widget>[
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    bonus.nom,
                    style: Setup.textStyle(13, color: !bonus.achete ? Colors.black : Colors.indigo),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
                child: FancyButton
                  (size: 20,
                    color: !bonus.achete && argent >= bonus.argent
                           ? Colors.green
                           : Colors.red,
                    onPressed: !bonus.achete && argent >= bonus.argent ? () => achatBonus(position) : null,
                    child: Row(
                    children: <Widget>[
                    Padding(padding: const EdgeInsets.only(left: 10, bottom: 2, top:2),
                      child: Text(
                          !bonus.achete ? 'ACHETER' : 'POSSEDE',
                          style:
                          Setup.textStyle(13, color: !bonus.achete ? Colors.white : Colors.black),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 8, right: !bonus.achete ? 2.0 : 0.0),
                      child: Text(
                        !bonus.achete ? bonus.argent.toString(): '',
                        style: Setup.textStyle(13),
                      ),
                    ),
                    visibiliteArgent(bonus.achete)
                    ],
                  ),
                )
              )
            ],
          ),
        ),
      ),
    );
  }

  // mise en place du chrono pour la partie
  void initClock({int add}) {
    if (controller == null) {
      //si le controller est null je defini le temps backup a mon temps actuel
      tempsBackup  = temps;
    } else {
      //calcul du temps actuel lors de la fin d'une manche
      final tempsActuel = controller.duration * controller.value;
      tempsBackup = tempsActuel.inMilliseconds;
      controller.stop();
    }

    // reinitialisation du controller en ajoutant le temps supplementaire
    controller = null;
    controller = AnimationController(vsync: this, duration: Duration(milliseconds: tempsBackup + add));
    controller.reverse(from: controller.value == 0.0 ? 1.0 : controller.value);

    // ignore: cascade_invocations
    controller.addListener(() {
      setState(() {
        timer;

        //calcul du temps actuel
        final duration = controller.duration * controller.value;

        if (duration.inSeconds > 20) {
          clockColor = Colors.white;
        }

        if (duration.inSeconds  < 20) {
          clockColor = Colors.yellowAccent;
        }

        if (duration.inSeconds  < 10) {
          clockColor = Colors.red;
        }
      });
    });


    //si le temps se termine alors la partie est termine
    // ignore: cascade_invocations
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
    barreVie = listBoss[bossIndex].vie.toDouble() * multiplicateur;
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
      if (musicEnCours && instance != null) {
        instance.stop();
        musicEnCours = false;
    }
    WidgetsBinding.instance.removeObserver(this);
    controller.dispose();
    resetStat();
    super.dispose();
  }
  void resetStat() {
    degatJoueur = 30.0;
    niveau = 1;
    multiplicateur = 1.0;
  }

  @override
  Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
    super.didChangeAppLifecycleState(state);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return Material(
        child: Stack(
          children: <Widget>[
            moteurDeJeu(context),
            GameOver(musiqueCache: musiqueCache, instance: instance, gameOver: gameOver, musicEnCours: musicEnCours, listBoss: listBoss, bossIndex: bossIndex)
          ],
        ),
      );
    });
  }
  
}

