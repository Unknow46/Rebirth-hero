import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:rebirth_hero/widgets/setup.dart';

class HitBox{

  Widget hitBox(dynamic tap, dynamic yAxis, dynamic xAxis, dynamic degatJoueur) {
    if(tap) {
      return Positioned(
        top: yAxis,
        left: xAxis,
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Material(
                color: Colors.transparent,
                child: DegatJoueurText(
                  '-${degatJoueur.toInt().toString()}',
                  tailleFont: 26,
                  familleFont: 'Gameplay',
                  color: Colors.red,
                  degatCouleur: Colors.black,
                  degatWidth: 1,
                ),
              ),
            ),
            Image.asset(
              'assets/images/elements/hit_player.png',
              fit: BoxFit.fill,
              height: 80,
              width: 80,
            )
          ],
        ),
      );
    } else {
      return Container();
    }
  }


}