import 'dart:math';

import 'package:client/widgets/webview/universal_webview_web.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../../config/theme_config.dart';
import '../../services/auth_service.dart';
import '../common_app_bar.dart';

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

class _UniversalWebViewState extends State<UniversalWebView>
    with SingleTickerProviderStateMixin {
  late final WebViewController _controller;

  int _progress = 0;
  bool _isLoading = true;

  late AnimationController _animationController;
  late Animation<double> _progressAnimation;

  double _targetProgress = 0;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _progressAnimation = Tween<double>(begin: 0, end: 0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    )..addListener(() {
      setState(() {});
    });

    if (!kIsWeb) {
      _controller = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setBackgroundColor(const Color(0xFFFFFFFF))
        ..setNavigationDelegate(
          NavigationDelegate(
            onProgress: (int progress) {
              _updateProgress(progress);
            },
            onPageStarted: (_) {
              _updateProgress(0);
              setState(() => _isLoading = true);
            },
            onPageFinished: (_) {
              _updateProgress(100);
              setState(() => _isLoading = false);
            },
          ),
        )
        ..loadRequest(Uri.parse(widget.url));
    }
  }

  void _updateProgress(int newProgress) {
    final newValue = (newProgress.clamp(0, 100)) / 100;

    _progress = newProgress;

    _progressAnimation = Tween<double>(
      begin: _progressAnimation.value,
      end: newValue,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _animationController.forward(from: 0);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  /*String get loadingText {
    if (_progress < 40) return "Loading...";
    if (_progress < 80) return "Preparing content...";
    if (_progress < 100) return "Almost there...";
    return "Done";
  }*/

  String loadingText = "Loading...";

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

    final double smoothValue = _progressAnimation.value;
    final double scale = 0.85 + (smoothValue * 0.35);

    return Scaffold(
      appBar: CommonAppBar(
        titleName: widget.title,
        matterID: AuthService.selectedMatterId,
      ),
      body: Stack(
        children: [
          Positioned.fill(child: webview),

          /// 🔥 Smooth Loader
          if (!kIsWeb && _isLoading)
            Positioned.fill(
              child: AnimatedOpacity(
                opacity: _isLoading ? 1 : 0,
                duration: const Duration(milliseconds: 300),
                child: Container(
                  color: Colors.white,
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        /// 🎯 Smooth scaling logo + progress
                        Transform.scale(
                          scale: scale,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              SizedBox(
                                height: 110,
                                width: 110,
                                child: CircularProgressIndicator(
                                  value: smoothValue,
                                  strokeWidth: 4,
                                  color: ThemeConfig.successColor,
                                  backgroundColor: Colors.grey.shade200,
                                ),
                              ),

                              Image.asset(
                                'assets/icons/app_icon.png',
                                height: 60,
                              ),
                            ],
                          ),
                        ),

                        /*const SizedBox(height: 24),

                        Text(
                          "${(smoothValue * 100).toInt()}%",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: ThemeConfig.successColor,
                          ),
                        ),

                        const SizedBox(height: 8),

                        Text(
                          loadingText,
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 13,
                          ),
                        ),*/
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}