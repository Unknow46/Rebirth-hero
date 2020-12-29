import 'package:flutter/material.dart';
import 'package:rebirth_hero/data/model/boss.dart';
import '../data/model/bonus.dart';

class Setup {



  static List<Bonus> getBonus() {
    final listBonus = <Bonus>[];
    
    // ignore: cascade_invocations
    listBonus.add(Bonus('Blunt sword', 2, false, 25));
    // ignore: cascade_invocations
    listBonus.add(Bonus('Knight sword', 2.5, false, 100));
    // ignore: cascade_invocations
    listBonus.add(Bonus('Holy sword', 3.25, false, 200));
    // ignore: cascade_invocations
    listBonus.add(Bonus('Master sword', 3.75, false, 450));
    // ignore: cascade_invocations
    listBonus.add(Bonus('Light Saber', 4.5, false, 700));
    // ignore: cascade_invocations
    listBonus.add(Bonus('Rebellion', 6, false, 1000));
    // ignore: cascade_invocations
    listBonus.add(Bonus('Alastor', 6, false, 2000));

    return listBonus;
  }

  static List<Boss> getBoss() {
    final listBoss = <Boss>[];

    // ignore: cascade_invocations
    listBoss.add(Boss('Magicien sombre',900, 'assets/images/boss/final_boss_1.jpg', 'tu es si faible que ça ?'));
    // ignore: cascade_invocations
    listBoss.add(Boss('Magicien démonisé',1800, 'assets/images/boss/final_boss_2.png', 'tu es si faible que ça ?'));
    // ignore: cascade_invocations
    listBoss.add(Boss('Le Démon',2700, 'assets/images/boss/final_boss_3.png', 'tu es si faible que ça ?'));
    // ignore: cascade_invocations
    listBoss.add(Boss("L'oublié",3600, 'assets/images/boss/boss3.png', 'tu es si faible que ça ?'));
    return listBoss;
  }




  static TextStyle textStyle(double size, {Color color = Colors.white}) {
    return TextStyle(
      color: color,
      fontFamily: 'EXXA-GAME',
      fontSize: size,
    );
  }


}

class DegatJoueurText extends StatelessWidget {
  const DegatJoueurText(this.text,{Key key, this.tailleFont, this.poidsFont,
    this.color, this.degatCouleur, this.degatWidth, this.familleFont})
      : super(key: key);

  final String text;
  final double tailleFont;
  final FontWeight poidsFont;
  final Color color;
  final Color degatCouleur;
  final double degatWidth;
  final String familleFont;



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