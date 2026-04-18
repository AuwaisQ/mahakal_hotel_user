import 'dart:async';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:mahakal/localization/language_constrants.dart';
import 'package:mahakal/main.dart';
import 'package:mahakal/utill/app_constants.dart';
import 'package:mahakal/common/basewidget/animated_custom_dialog_widget.dart';
import 'package:mahakal/features/checkout/widgets/order_place_dialog_widget.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';

import '../../custom_bottom_bar/bottomBar.dart';

class DigitalPaymentScreen extends StatefulWidget {
  final String url;
  final bool fromWallet;
  const DigitalPaymentScreen(
      {super.key, required this.url, this.fromWallet = false});

  @override
  DigitalPaymentScreenState createState() => DigitalPaymentScreenState();
}

class DigitalPaymentScreenState extends State<DigitalPaymentScreen> {
  String? selectedUrl;
  double value = 0.0;
  bool _isLoading = true;
  int _progress = 0;
  bool _isWebViewReady = false;
  bool _showAppBar = false;

  WebViewController? _controller;
  PullToRefreshController? pullToRefreshController;
  bool _canRedirect = true;

  @override
  void initState() {
    super.initState();
    selectedUrl = widget.url;
    
    // Check if URL is from a deep link (non-http or specific patterns)
    _showAppBar = _isDeepLink(widget.url);
    
    _initWebView();
  }
  
  bool _isDeepLink(String url) {
    // Deep links typically have custom schemes or specific patterns
    // Check for non-http schemes or known payment gateway URLs
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      return true;
    }
    // Check for specific deeplink patterns
    return url.contains('deep-link') || url.contains('app://') || url.contains('mahakal://');
  }

  Future<void> _initWebView() async {
    if (Platform.isAndroid) {
      await InAppWebViewController.setWebContentsDebuggingEnabled(true);
      bool swAvailable = await WebViewFeature.isFeatureSupported(
          WebViewFeature.SERVICE_WORKER_BASIC_USAGE);
      bool swInterceptAvailable = await WebViewFeature.isFeatureSupported(
          WebViewFeature.SERVICE_WORKER_SHOULD_INTERCEPT_REQUEST);
      if (swAvailable && swInterceptAvailable) {
        ServiceWorkerController serviceWorkerController =
            ServiceWorkerController.instance();
        await serviceWorkerController
            .setServiceWorkerClient(ServiceWorkerClient(
          shouldInterceptRequest: (request) async {
            if (kDebugMode) {
              print(request);
            }
            return null;
          },
        ));
      }
    }

    // Configure Android-specific settings
    late final PlatformWebViewControllerCreationParams params;
    if (WebViewPlatform.instance is AndroidWebViewPlatform) {
      params = const PlatformWebViewControllerCreationParams();
      AndroidWebViewController.enableDebugging(true);
    } else {
      params = const PlatformWebViewControllerCreationParams();
    }

    final controller = WebViewController.fromPlatformCreationParams(params)
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setUserAgent(
          'Mozilla/5.0 (Linux; Android 14; Pixel 8) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Mobile Safari/537.36')
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (progress) => setState(() {
            _progress = progress;
            if (progress == 100) {
              _isLoading = false;
              pullToRefreshController?.endRefreshing();
            }
          }),
          onPageStarted: (url) => setState(() => _isLoading = true),
          onPageFinished: (url) => setState(() => _isLoading = false),
          onNavigationRequest: (request) async {
            String url = request.url;

            if (kDebugMode) {
              print('\n\nNavigation Request: $url\n\n');
            }

            // Handle external app launches for payment apps (UPI, Google Pay, PhonePe, etc.)
            bool isPaymentApp = url.startsWith('intent:') ||
                url.startsWith('upi://') ||
                url.startsWith('tez://') ||
                url.startsWith('phonepe://') ||
                url.startsWith('paytmmp://') ||
                url.startsWith('gpay://') ||
                url.startsWith('bhim://') ||
                url.startsWith('amazonpay://') ||
                url.startsWith('whatsapp://') ||
                url.startsWith('paytm://') ||
                url.startsWith('mobikwik://') ||
                url.startsWith('freecharge://') ||
                url.startsWith('airtel://') ||
                url.startsWith('myairplane://') ||
                url.startsWith('jio://') ||
                url.startsWith('axispay://') ||
                url.startsWith('hsbc://') ||
                url.startsWith('citi://') ||
                url.startsWith('scb://') ||
                url.startsWith('ybl://') ||
                url.startsWith('okhdfcbank://') ||
                url.startsWith('oksiicbank://') ||
                url.startsWith('khaatipayment://') ||
                url.startsWith('bhimoid://') ||
                url.startsWith('li.loyality://') ||
                url.startsWith('razorpay://') ||
                url.startsWith('jsi://') ||
                url.startsWith('sbi://') ||
                url.startsWith('idfcfirst://') ||
                url.startsWith(' Federal Bank:') ||
                url.startsWith('fedtech://');

            if (isPaymentApp) {
              try {
                final Uri uri = Uri.parse(url);
                final bool canLaunch = await canLaunchUrl(uri);
                
                if (canLaunch) {
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                  return NavigationDecision.prevent;
                } else {
                  // App not installed - show user-friendly message
                  _showAppNotSupportedDialog(url);
                  return NavigationDecision.prevent;
                }
              } on PlatformException catch (e) {
                // App not found or cannot handle the URL
                if (kDebugMode) {
                  print('Error launching payment app: $e');
                }
                _showAppNotSupportedDialog(url);
                return NavigationDecision.prevent;
              } catch (e) {
                if (kDebugMode) {
                  print('Error launching payment app: $e');
                }
                return NavigationDecision.prevent;
              }
            }

            // Open external schemes (tel:, mailto:, etc.) in system browser
            if (!url.startsWith('http')) {
              await launchUrl(Uri.parse(url),
                  mode: LaunchMode.externalApplication);
              return NavigationDecision.prevent;
            }

            // Handle payment redirects
            _handlePageRedirect(url);

            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(selectedUrl ?? ''));

    // Enable additional settings for UPI payments on Android
    if (Platform.isAndroid &&
        controller.platform is AndroidWebViewController) {
      final androidController = controller.platform as AndroidWebViewController;

      // Enable media playback without user gesture for payment audio/video
      await androidController.setMediaPlaybackRequiresUserGesture(false);
    }

    if (mounted) {
      setState(() {
        _controller = controller;
        _isWebViewReady = true;
      });
    }
  }

  void _handlePageRedirect(String url) {
    if (_canRedirect) {
      bool isSuccess =
          url.contains('success') && url.contains(AppConstants.baseUrl);
      bool isFailed =
          url.contains('fail') && url.contains(AppConstants.baseUrl);
      bool isCancel =
          url.contains('cancel') && url.contains(AppConstants.baseUrl);

      if (kDebugMode) {
        print(
            'URL Check - Success: $isSuccess, Failed: $isFailed, Cancel: $isCancel');
        print('URL: $url');
      }

      if (isSuccess || isFailed || isCancel) {
        _canRedirect = false;
      }

      if (isSuccess) {
        Navigator.of(Get.context!).pushAndRemoveUntil(
            CupertinoPageRoute(builder: (_) => const BottomBar(pageIndex: 0)),
            (route) => false);

        showAnimatedDialog(
            Get.context!,
            OrderPlaceDialogWidget(
              icon: Icons.done,
              title: getTranslated('order_placed', Get.context!),
              description: getTranslated('your_order_placed', Get.context!),
            ),
            dismissible: false,
            willFlip: true);
      } else if (isFailed) {
        Navigator.of(Get.context!).pushAndRemoveUntil(
            CupertinoPageRoute(builder: (_) => const BottomBar(pageIndex: 0)),
            (route) => false);

        showAnimatedDialog(
            Get.context!,
            OrderPlaceDialogWidget(
              icon: Icons.clear,
              title: getTranslated('payment_failed', Get.context!),
              description: getTranslated('your_payment_failed', Get.context!),
              isFailed: true,
            ),
            dismissible: false,
            willFlip: true);
      } else if (isCancel) {
        Navigator.of(Get.context!).pushAndRemoveUntil(
            CupertinoPageRoute(builder: (_) => const BottomBar(pageIndex: 0)),
            (route) => false);

        showAnimatedDialog(
            Get.context!,
            OrderPlaceDialogWidget(
              icon: Icons.clear,
              title: getTranslated('payment_cancelled', Get.context!),
              description:
                  getTranslated('your_payment_cancelled', Get.context!),
              isFailed: true,
            ),
            dismissible: false,
            willFlip: true);
      }
    }
  }

  Future<bool> _exitApp() async {
    if (_controller == null) {
      Navigator.of(Get.context!).pushAndRemoveUntil(
          CupertinoPageRoute(builder: (_) => const BottomBar(pageIndex: 0)),
          (route) => false);
      return true;
    }

    if (await _controller!.canGoBack()) {
      _controller!.goBack();
      return false;
    } else {
      Navigator.of(Get.context!).pushAndRemoveUntil(
          CupertinoPageRoute(builder: (_) => const BottomBar(pageIndex: 0)),
          (route) => false);
      showAnimatedDialog(
          Get.context!,
          OrderPlaceDialogWidget(
            icon: Icons.clear,
            title: getTranslated('payment_cancelled', Get.context!),
            description:
                getTranslated('your_payment_cancelled', Get.context!),
            isFailed: true,
          ),
          dismissible: false,
          willFlip: true);
      return true;
    }
  }

  void _showAppNotSupportedDialog(String url) {
    // Extract app name from URL for better user experience
    String appName = _getAppNameFromUrl(url);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('App Not Available'),
        content: Text(
          'The $appName app is not installed on your device. '
          'Please cancle and select a different payment method.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  String _getAppNameFromUrl(String url) {
    // Extract app name from URL scheme
    if (url.contains('gpay') || url.contains('tez') || url.contains('google')) {
      return 'Google Pay';
    } else if (url.contains('phonepe')) {
      return 'PhonePe';
    } else if (url.contains('paytm')) {
      return 'Paytm';
    } else if (url.contains('bhim')) {
      return 'BHIM';
    } else if (url.contains('mobikwik')) {
      return 'MobiKwik';
    } else if (url.contains('amazonpay')) {
      return 'Amazon Pay';
    } else if (url.contains('razorpay')) {
      return 'Razorpay';
    } else if (url.contains('freecharge')) {
      return 'FreeCharge';
    } else if (url.contains('airtel')) {
      return 'Airtel';
    } else if (url.contains('jio')) {
      return 'Jio Pay';
    } else if (url.contains('ybl') || url.contains('okhdfc')) {
      return 'Paytm';
    }
    return 'payment app';
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        _exitApp();
      },
      child: Scaffold(
        appBar: _showAppBar
            ? AppBar(
                title: const Text(''),
                backgroundColor: Theme.of(context).cardColor,
                actions: [
                  IconButton(
                    icon: const Icon(Icons.open_in_browser),
                    onPressed: () {
                      if (selectedUrl != null) {
                        launchUrl(Uri.parse(selectedUrl!),
                            mode: LaunchMode.externalApplication);
                      }
                    },
                  ),
                ],
                bottom: _isLoading
                    ? PreferredSize(
                        preferredSize: const Size.fromHeight(3.0),
                        child: LinearProgressIndicator(value: _progress / 100.0),
                      )
                    : null)
            : null,
        body: !_isWebViewReady || _controller == null
            ? Center(
                child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                        Theme.of(context).primaryColor)))
            : Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _isLoading
                      ? Center(
                          child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                  Theme.of(context).primaryColor)))
                      : const SizedBox.shrink(),
                  Expanded(
                    child: WebViewWidget(controller: _controller!),
                  ),
                ],
              ),
      ),
    );
  }
}

