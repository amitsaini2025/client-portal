import 'package:flutter/material.dart';

// Stub for Mobile/Desktop; WebView is handled in main wrapper
class UniversalWebViewWeb extends StatelessWidget {
  final String url;
  final String viewId;

  const UniversalWebViewWeb({super.key, required this.url, required this.viewId});

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}
