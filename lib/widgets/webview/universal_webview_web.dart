import 'dart:ui_web' as ui;
import 'package:flutter/material.dart';
import 'package:web/web.dart' as web;

class UniversalWebViewWeb extends StatefulWidget {
  final String url;
  final String viewId;

  const UniversalWebViewWeb({
    super.key,
    required this.url,
    required this.viewId,
  });

  @override
  State<UniversalWebViewWeb> createState() => _UniversalWebViewWebState();
}

class _UniversalWebViewWebState extends State<UniversalWebViewWeb> {
  static final Set<String> _registeredViewIds = {};

  @override
  void initState() {
    super.initState();

    if (!_registeredViewIds.contains(widget.viewId)) {
      _registeredViewIds.add(widget.viewId);

      ui.platformViewRegistry.registerViewFactory(
        widget.viewId,
            (int viewId) {
          final iframe = web.HTMLIFrameElement()
            ..src = widget.url
            ..style.border = 'none'
            ..style.width = '100%'
            ..style.height = '100%'
            ..allowFullscreen = true
            ..style.overflow = 'hidden';

          return iframe;
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return HtmlElementView(viewType: widget.viewId);
  }
}