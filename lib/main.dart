import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'pages/accueil.dart';
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]).then((_) {
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