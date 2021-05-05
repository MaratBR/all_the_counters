import 'package:flutter/material.dart';

class RoundedListItemButton extends StatelessWidget {
  final VoidCallback onPressed;
  final VoidCallback? onLongPress;
  final Widget? child;

  RoundedListItemButton({
    required this.onPressed,
    this.onLongPress,
    this.child
  });

  @override
  Widget build(BuildContext context) {
    return RawMaterialButton(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(30))),
      fillColor: Theme.of(context).cardColor,
      elevation: 0,
      highlightElevation: 0,
      onPressed: onPressed,
      onLongPress: onLongPress,
      child: child
    );
  }

}