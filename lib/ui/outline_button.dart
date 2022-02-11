import 'dart:io';

import 'package:flutter/material.dart';

class FocusedOutlineButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final Key? key;
  final bool enabled;
  final Widget child;

  bool isPressed = false;

  FocusedOutlineButton({
    this.key,
    required this.onPressed,
    required this.child,
    this.enabled = true,
  });

  @override
  State<StatefulWidget> createState() => _RawOutlineButton();
}

class _RawOutlineButton extends State<FocusedOutlineButton> {
  Widget? _child = null;

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    var isDark = theme.brightness == Brightness.dark;
    int color;

    if (isDark) {
      color = widget.isPressed ? 0xffffffff : 0xff999999;
    } else {
      color = widget.isPressed ? 0xff000000 : 0xff444444;
    }

    var button = RawMaterialButton(
      splashColor: Color(0),
      child: widget.child,
      onPressed: widget.onPressed,
      fillColor: theme.cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(150)),
        side: BorderSide(color: Color(color), width: widget.isPressed ? 2 : 1),
      ),
    );

    return GestureDetector(
      child: button,
      onTapDown: (details) {
        setState(() {
          widget.isPressed = true;
        });
      },
      onTapUp: (details) {
        setState(() {
          widget.isPressed = false;
        });
      },
      onTapCancel: () {
        setState(() {
          widget.isPressed = false;
        });
      },
    );
  }
}
