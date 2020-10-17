import 'package:flutter/material.dart';

import 'bonus.dart';
import 'boss.dart';

class Setup {


  static List<Bonus> getBonus() {
    var listBonus = List<Bonus>();
    
    listBonus.add(Bonus('Blunt sword', 2.0, false, 25));
    listBonus.add(Bonus('Knight sword', 2.5, false, 100));
    listBonus.add(Bonus('Holy sword', 3.25, false, 200));
    listBonus.add(Bonus('Master sword', 3.75, false, 450));
    listBonus.add(Bonus('Light Saber', 4.5, false, 700));
    listBonus.add(Bonus('Rebellion', 6, false, 1000));
    listBonus.add(Bonus('Alastor', 6, false, 2000));

    return listBonus;
  }

  static List<Boss> getBoss() {
    var listBoss = List<Boss>();
    
    listBoss.add(Boss('Unknown',9000, 'assets/background/boss/final_boss_1.jpg'));

    return listBoss;
  }
  

}

class DegatJoueurText extends StatelessWidget {

  final String text;
  final double tailleFont;
  final FontWeight poidsFont;
  final Color color;
  final Color degatCouleur;
  final double degatWidth;
  final String familleFont;

  const DegatJoueurText(this.text,{Key key, this.tailleFont, this.poidsFont,
    this.color, this.degatCouleur, this.degatWidth, this.familleFont})
      : super(key: key);


  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Text(
          text,
          style: TextStyle(
            fontSize: tailleFont,
            fontWeight: poidsFont,
            fontFamily: familleFont,
            color: color,
          ),
        ),
        Text(
          text,
          style: TextStyle(
            fontSize: tailleFont,
            fontWeight: poidsFont,
            fontFamily: familleFont,
            foreground: Paint()
              ..strokeWidth = degatWidth
              ..color = degatCouleur
              ..style = PaintingStyle.stroke,
          ),
        )
      ],
    );
  }
}