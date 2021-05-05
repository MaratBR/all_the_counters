import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class BasicUI extends StatelessWidget {
  final Widget child;

  const BasicUI({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context ) {
    return SafeArea(
      child: Material(
        child: child,
      ),
    );
  }
}