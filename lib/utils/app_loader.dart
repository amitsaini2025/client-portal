import 'dart:io';

import 'package:flutter/foundation.dart'; // ✅ replaces dart:io
import 'package:flutter/material.dart';
import '../config/theme_config.dart';

class AppLoader extends StatelessWidget {
  final double size;
  final double scale;
  final double? value;
  final bool isOverlay;
  final bool animate;

  const AppLoader({
    super.key,
    this.size = 80,
    this.scale = 1.0,
    this.value,
    this.isOverlay = false,
    this.animate = true,
  });

  @override
  Widget build(BuildContext context) {
    final double iconSize = size * 0.4;
    final double strokeWidth = size * 0.05;

    Widget loader = Transform.scale(
      scale: scale,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            height: size,
            width: size,
            child: CircularProgressIndicator(
              value: value,
              strokeWidth: strokeWidth,
              color: ThemeConfig.successColor,
              backgroundColor: Colors.grey.shade200,
            ),
          ),
          Image.asset(
            'assets/icons/app_icon.png',
            height: iconSize,
          ),
        ],
      ),
    );

    if (!kIsWeb && !Platform.isMacOS && animate) {
      loader = AnimatedOpacity(
        opacity: 1.0,
        duration: const Duration(milliseconds: 300),
        child: loader,
      );
    }

    if (isOverlay) {
      return Positioned.fill(
        child: Container(
          color: Colors.white,
          child: Center(child: loader),
        ),
      );
    }

    return Center(child: loader);
  }
}