import 'package:flutter/material.dart';
import 'accueil.dart';
void main() {

  runApp(RebirthHero());
}
class RebirthHero extends StatefulWidget {

  @override
  _RebirthHeroState createState() => _RebirthHeroState();
}

class _RebirthHeroState extends State<RebirthHero> {

  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Accueil(),
    );
  }
}