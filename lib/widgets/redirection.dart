import 'package:flutter/material.dart';

class Redirection extends PageRoute<dynamic> {

  Redirection(this.child);

  final Widget child;

  @override
  Color get barrierColor => Colors.black;

  @override
  String get barrierLabel => null;

  @override
  bool get maintainState => true;

  @override
  Duration get transitionDuration => const Duration(milliseconds: 250);

  @override
  Widget buildPage(BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation) {
    return FadeTransition(opacity: animation, child: child);
  }
}