import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class Money {

  Widget argentGagneWidget(dynamic argentGagne) {
    if (argentGagne) {
      return const Padding(
        padding:  EdgeInsets.only(left: 5),
        child: Material(
          color: Colors.transparent,
          child: Text(
            '+20',
            style: TextStyle(
                color: Colors.green
            ),
          ),
        ),
      );
    } else {
      return Container(
        width: 0,
        height: 0,
      );
    }
  }
}