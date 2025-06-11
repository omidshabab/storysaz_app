import 'dart:ui';

import 'package:flutter/material.dart';

// ignore: must_be_immutable
class AppIconButton extends StatelessWidget {
  IconData icon;
  VoidCallback onPressed;
  Color? color;
  Color? borderColor;

  AppIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.color,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(100),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 20.0),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.transparent,
            border: Border.all(
                width: 1, color: borderColor ?? Colors.black.withOpacity(0.1)),
            borderRadius: BorderRadius.circular(50),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(50),
            hoverColor: Colors.black.withOpacity(0.01),
            splashColor: Colors.black.withOpacity(0.01),
            focusColor: Colors.black.withOpacity(0.01),
            highlightColor: Colors.black.withOpacity(0.5),
            onTap: onPressed,
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Icon(
                icon,
                color: color ?? Colors.black,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
