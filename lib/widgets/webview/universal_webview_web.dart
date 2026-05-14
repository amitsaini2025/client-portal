// universal_webview_web.dart
//
// NOTE: This file is only used if you have OTHER urls that allow iframe
// embedding. For sites like immi.homeaffairs.gov.au that block iframes,
// the fallback in UniversalWebView handles it automatically on web.

import 'dart:ui_web' as ui;
import 'package:flutter/material.dart';
import 'package:web/web.dart';

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

    // Guard against duplicate registration (causes black screen crash)
    if (!_registeredViewIds.contains(widget.viewId)) {
      _registeredViewIds.add(widget.viewId);
      ui.platformViewRegistry.registerViewFactory(
        widget.viewId,
            (int id) {
          final iframe = HTMLIFrameElement()
            ..src = widget.url
            ..style.border = 'none'
            ..style.width = '100%'
            ..style.height = '100%'
            ..allow = 'fullscreen';
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
