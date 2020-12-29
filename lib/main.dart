import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'screen/accueil.dart';
dynamic main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]).then((_) {
    runApp(const RebirthHero());
  });
}
class RebirthHero extends StatefulWidget {

  const RebirthHero({Key key}):super(key: key);

  @override
  _RebirthHeroState createState() => _RebirthHeroState();
}

class _RebirthHeroState extends State<RebirthHero> {

  @override
  Widget build(BuildContext context) {

    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Accueil(),
    );
  }
}