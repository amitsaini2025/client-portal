import 'package:client/widgets/webview/universal_webview_web.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class UniversalWebView extends StatelessWidget {
  final String url;
  final String viewId;

  const UniversalWebView({super.key, required this.url, required this.viewId});

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      return Container(
        color: Colors.white,
        child: UniversalWebViewWeb(url: url, viewId: viewId),
      );
    } else {
      final controller = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setBackgroundColor(const Color(0xFFFFFFFF))
        ..loadRequest(Uri.parse(url));

      return Container(
        color: Colors.white,
        child: WebViewWidget(controller: controller),
      );
    }
  }
}
