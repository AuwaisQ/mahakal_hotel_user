import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:url_launcher/url_launcher.dart';

class InAppWebViewPage extends StatefulWidget {
  final Uri url;
  final Future<Null> Function(dynamic u)? onOpenExternally;
  final void Function(String url)? onPaymentRedirect;
  final String? successPattern;
  final String? failurePattern;
  final String? cancelPattern;
  final String? baseUrl;

  const InAppWebViewPage({
    Key? key,
    required this.url,
    this.onOpenExternally,
    this.onPaymentRedirect,
    this.successPattern,
    this.failurePattern,
    this.cancelPattern,
    this.baseUrl,
  }) : super(key: key);

  @override
  State<InAppWebViewPage> createState() => _InAppWebViewPageState();
}

class _InAppWebViewPageState extends State<InAppWebViewPage> {
  late final WebViewController _controller;
  bool _isLoading = true;
  int _progress = 0;
  bool _canRedirect = true;

  @override
  void initState() {
    super.initState();
    _initWebView();
  }

  void _initWebView() {
    // 🔹 Configure Android-specific settings (only needed on Android)
    late final PlatformWebViewControllerCreationParams params;
    if (WebViewPlatform.instance is AndroidWebViewPlatform) {
      params = const PlatformWebViewControllerCreationParams();
      AndroidWebViewController.enableDebugging(true);
    } else {
      params = const PlatformWebViewControllerCreationParams();
    }

    final controller = WebViewController.fromPlatformCreationParams(params)
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (progress) => setState(() => _progress = progress),
          onPageStarted: (_) => setState(() => _isLoading = true),
          onPageFinished: (_) => setState(() => _isLoading = false),
          onNavigationRequest: (request) async {
            String url = request.url;

            // Handle external schemes (e.g. tel:, mailto:, upi:, gpay:, phonepe:, paytm:) in system browser
            // This is crucial for UPI payments to open payment apps
            if (!url.startsWith('http')) {
              if (widget.onOpenExternally != null) {
                await widget.onOpenExternally!(url);
              } else {
                await launchUrl(Uri.parse(url),
                    mode: LaunchMode.externalApplication);
              }
              return NavigationDecision.prevent;
            }

            // Handle payment redirects
            if (_canRedirect && widget.onPaymentRedirect != null) {
              _checkPaymentRedirect(url);
            }

            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(widget.url);

    // 🔹 Enable media playback for WebView (required for some payment flows)
    if (controller.platform is AndroidWebViewController) {
      (controller.platform as AndroidWebViewController)
          .setMediaPlaybackRequiresUserGesture(false);
    }

    _controller = controller;
  }

  void _checkPaymentRedirect(String url) {
    bool isSuccess = widget.successPattern != null &&
        widget.baseUrl != null &&
        url.contains(widget.successPattern!) &&
        url.contains(widget.baseUrl!);
    bool isFailed = widget.failurePattern != null &&
        widget.baseUrl != null &&
        url.contains(widget.failurePattern!) &&
        url.contains(widget.baseUrl!);
    bool isCancel = widget.cancelPattern != null &&
        widget.baseUrl != null &&
        url.contains(widget.cancelPattern!) &&
        url.contains(widget.baseUrl!);

    if (isSuccess || isFailed || isCancel) {
      _canRedirect = false;
      widget.onPaymentRedirect!(url);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: WebViewWidget(controller: _controller),
    );
  }
}

