import 'package:client/widgets/webview/universal_webview_web.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../../config/theme_config.dart';

class UniversalWebView extends StatefulWidget {
  final String url;
  final String viewId;
  final String title;

  const UniversalWebView({
    super.key,
    required this.url,
    required this.viewId,
    this.title = "Health Insurance",
  });

  @override
  State<UniversalWebView> createState() => _UniversalWebViewState();
}

class _UniversalWebViewState extends State<UniversalWebView> {
  late final WebViewController _controller;
  int _progress = 0;

  @override
  void initState() {
    super.initState();

    if (!kIsWeb) {
      _controller = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setBackgroundColor(const Color(0xFFFFFFFF))
        ..setNavigationDelegate(
          NavigationDelegate(
            onProgress: (int progress) {
              setState(() {
                _progress = progress;
              });
            },
          ),
        )
        ..loadRequest(Uri.parse(widget.url));
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget webview;

    if (kIsWeb) {
      webview = UniversalWebViewWeb(
        url: widget.url,
        viewId: widget.viewId,
      );
    } else {
      webview = WebViewWidget(controller: _controller);
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: ThemeConfig.goldenYellow,
        title: Text(
          widget.title,
          style: const TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Stack(
        children: [
          Positioned.fill(child: webview),

          // Linear progress indicator for mobile only
          if (!kIsWeb && _progress < 100)
            LinearProgressIndicator(
              value: _progress / 100,
              color: ThemeConfig.successColor,
              backgroundColor: Colors.grey.shade200,
            ),
        ],
      ),
    );
  }
}
