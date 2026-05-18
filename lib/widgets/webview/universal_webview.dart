import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../../config/theme_config.dart';
import '../../services/auth_service.dart';
import '../../utils/app_loader.dart';
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
        ..setJavaScriptMode(JavaScriptMode.unrestricted);

      // ❗ FIX: macOS crash (DO NOT call setBackgroundColor on macOS)
      if (!Platform.isMacOS) {
        _controller.setBackgroundColor(const Color(0xFFFFFFFF));
      }

      _controller
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
              Future.delayed(const Duration(milliseconds: 400), () {
                if (mounted) setState(() => _isLoading = false);
              });
            },
          ),
        )
        ..loadRequest(Uri.parse(widget.url));
    }
  }

  void _updateProgress(int newProgress) {
    final newValue = (newProgress.clamp(0, 100)) / 100;

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

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      return Scaffold(
        appBar: CommonAppBar(
          titleName: widget.title,
          matterID: AuthService.selectedMatterId,
        ),
        body: _WebFallbackView(url: widget.url, title: widget.title),
      );
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
          Positioned.fill(
            child: WebViewWidget(controller: _controller),
          ),

          if (_isLoading)
            Positioned.fill(
              child: Container(
                color: Colors.white,
                child: Center(
                  child: Platform.isMacOS
                      ? _buildMacOSLoader(scale, smoothValue)
                      : AnimatedOpacity(
                    opacity: 1.0,
                    duration: const Duration(milliseconds: 300),
                    child: _buildLoader(scale, smoothValue),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLoader(double scale, double smoothValue) {
    return Transform.scale(
      scale: scale,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            height: 110,
            width: 110,
            child: AppLoader(),
          ),
          Image.asset(
            'assets/icons/app_icon.png',
            height: 40,
          ),
        ],
      ),
    );
  }

  Widget _buildMacOSLoader(double scale, double smoothValue) {
    return Transform.scale(
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
            height: 40,
          ),
        ],
      ),
    );
  }
}

class _WebFallbackView extends StatefulWidget {
  final String url;
  final String title;

  const _WebFallbackView({required this.url, required this.title});

  @override
  State<_WebFallbackView> createState() => _WebFallbackViewState();
}

class _WebFallbackViewState extends State<_WebFallbackView> {
  bool _launching = false;

  Future<void> _openInBrowser() async {
    setState(() => _launching = true);
    try {
      final uri = Uri.parse(widget.url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Could not open the link.')),
          );
        }
      }
    } finally {
      if (mounted) setState(() => _launching = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: ThemeConfig.successColor.withValues(alpha:0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.open_in_browser_rounded,
                size: 56,
                color: ThemeConfig.successColor,
              ),
            ),
            const SizedBox(height: 28),
            Text(
              widget.title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'This page needs to open in your browser.\nYour session and data will be kept secure.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 14,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 36),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: _launching
                    ? const SizedBox(
                  height: 18,
                  width: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
                    : const Icon(Icons.launch_rounded),
                label: Text(_launching ? 'Opening...' : 'Open in Browser'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: ThemeConfig.successColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: _launching ? null : _openInBrowser,
              ),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Go Back',
                style: TextStyle(color: Colors.grey.shade600),
              ),
            ),
          ],
        ),
      ),
    );
  }
}