// filename: deep_link_service.dart

import 'dart:async';
import 'package:app_links/app_links.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../features/pooja_booking/view/pooja_video_player.dart';
import '../utill/web_view.dart';

class DeepLinkRoutes {
  static const String epooja = 'epooja';
  static const String anushthan = 'anushthan';
  static const String vip = 'vip';
  static const String panchang = 'panchang';
  static const String livestream = 'live-stream';
  static const String tour = 'tour'; //  new route
  static const String event = 'event'; //  new route
  static const String blog = 'blog'; //  new route
  static const String donate = 'donate'; //  new route
  static const String product = 'product'; //  new route
  static const String shop = 'shop'; //  new route
  static const String darshan = 'darshan'; //  new route
  static const String offline = 'offline'; //  new route
  static const String kundalipdf = 'kundali-pdf'; //  new route
  static const String templeDetails = 'temple-details'; //  new route
  static const String eventDetails = 'event-details'; //  new route
  static const String counselling = 'counselling'; //  new route
  static const String chadhava = 'chadhava'; //  new route
  static const String donationAds = 'all-donate'; //  new route
  static const String donationTrust = 'donate-trust'; //  new route
  static const String shopViewA1 = 'shopview'; //  new route
  static const String shopViewA2 = 'shopView'; //  new route
  static const String pujaBookNow = 'pujabooknow'; //  new route
  static const String chadhavaBookNow = 'chadhavabooknow'; //  new route
  static const String sangeet = 'sangeet'; //  new route
  static const String sahitya = 'sahitya'; //  new route
  static const String guruji = 'guruji'; //  new route
}

class DeepLinkService {
  StreamSubscription<Uri>? _linkSubscription;
  final GlobalKey<NavigatorState> navigatorKey;

  // Duplicate suppression removed (unused fields)

  DeepLinkService(this.navigatorKey);

  void init() {
    final appLinks = AppLinks();

    // Handle initial link first; some platforms also emit the same link on the stream
    appLinks.getInitialLink().then((uri) {
      if (uri != null) {
        _safeHandleDeepLink(uri);
      }
      // After initial handling, subscribe to stream
      _linkSubscription = appLinks.uriLinkStream.listen(
        (uri) => _safeHandleDeepLink(uri),
        onError: (error) => debugPrint('Deep link stream error: $error'),
      );
    }).catchError((error) {
      debugPrint('Error getting initial link: $error');
      // Still subscribe to stream even if initial fails
      _linkSubscription = appLinks.uriLinkStream.listen(
        (uri) => _safeHandleDeepLink(uri),
        onError: (err) => debugPrint('Deep link stream error: $err'),
      );
    });
  }

  void dispose() {
    _linkSubscription?.cancel();
    _linkSubscription = null;
  }

  bool _isFirebaseAuthLink(Uri uri) {
    // Be conservative: ignore any link that looks like Firebase auth flow
    return uri.scheme.contains('googleusercontent.apps') ||
        uri.host.contains('firebase') ||
        uri.host == 'firebaseauth' ||
        uri.path.contains('/auth/') ||
        uri.path == '/link' ||
        uri.queryParameters.containsKey('deep_link_id') ||
        uri.toString().contains('firebaseauth') ||
        uri.toString().contains('recaptchaToken');
  }

  bool _isAppDeepLink(Uri uri) {
    // Accept https://mahakal.com/... and mahakal://...
    final isHttpsMahakal =
        uri.scheme == 'https' && uri.host.toLowerCase().contains('mahakal.com');
    final isCustomScheme = uri.scheme.toLowerCase() == 'mahakal';
    return isHttpsMahakal || isCustomScheme;
  }

  void _safeHandleDeepLink(Uri uri) {
    try {
      // Ignore Firebase auth intents
      if (_isFirebaseAuthLink(uri)) {
        debugPrint('Ignoring Firebase auth link: $uri');
        return;
      }
      // Only handle app deep links
      if (!_isAppDeepLink(uri)) {
        debugPrint('Ignoring non-app deep link: $uri');
        return;
      }

      // Suppress duplicates (simplified - fields removed)
      handleDeepLink(uri);
    } catch (e, st) {
      debugPrint('❌ Error in _safeHandleDeepLink: $e\n$st');
      // Do not force navigation to splash here; just log.
    }
  }

  // Inside DeepLinkService
  void handleDeepLink(Uri uri) {
    final navigator = navigatorKey.currentState;
    if (navigator == null) {
      debugPrint('Navigator not ready; deferring deep link: $uri');
      return;
    }

    final segments = uri.pathSegments.where((s) => s.isNotEmpty).toList();
    if (segments.isEmpty) {
      debugPrint('No path segments in deep link: $uri');
      return;
    }

    final first = segments.first.toLowerCase();
    print('check firt segment $first');
    switch (first) {
      case DeepLinkRoutes.epooja:
        _handleEpoojaRoute(segments, navigator);
        break;

      case DeepLinkRoutes.panchang:
        _handlePanchangRoute(navigator);
        break;

      case DeepLinkRoutes.livestream:
        _handleLiveStreamRoute(segments, navigator);
        break;

      case DeepLinkRoutes.tour:
        _handleTourRoute(segments, navigator); // ✅ new handler
        break;

      case DeepLinkRoutes.event:
        _handleEventRoute(segments, navigator);
        break;

      case DeepLinkRoutes.blog:
        _handleBlogRoute(segments, navigator);
        break;

      case DeepLinkRoutes.donate:
        _handleDonationRoute(segments, navigator);
        break;

      case DeepLinkRoutes.anushthan:
        _handleAnushthanRoute(segments, navigator);
        break;

      case DeepLinkRoutes.vip:
        _handleVipRoute(segments, navigator);
        break;

      case DeepLinkRoutes.product:
        _handleEcomRoute(segments, navigator);
        break;

      case DeepLinkRoutes.shop:
        _handleShopRoute(navigator);
        break;

      case DeepLinkRoutes.darshan:
        _handleDarshanRoute(segments, navigator);
        break;

      case DeepLinkRoutes.offline:
        _handleOfflineRoute(segments, navigator);
        break;

      case DeepLinkRoutes.kundalipdf:
        _handleKundaliPdfRoute(segments, navigator);
        break;

      case DeepLinkRoutes.templeDetails:
        _handleTempleDetailsRoute(segments, navigator);
        break;

      case DeepLinkRoutes.eventDetails:
        _handleEventDetailsRoute(segments, navigator);
        break;

      case DeepLinkRoutes.counselling:
        _handleCounsellingRoute(segments, navigator);
        break;

      case DeepLinkRoutes.chadhava:
        _handleChadhavaRoute(segments, navigator);
        break;

      case DeepLinkRoutes.donationAds:
        _handleAdsDonationRoute(segments, navigator);
        break;

      case DeepLinkRoutes.donationTrust:
        _handleTrustDonationRoute(segments, navigator);
        break;

      case DeepLinkRoutes.shopViewA1:
        _handleShopViewRoute(segments, navigator);
        break;

      case DeepLinkRoutes.shopViewA2:
        _handleShopViewRoute(segments, navigator);
        break;

      case DeepLinkRoutes.pujaBookNow:
        _handlePoojaBookFormRoute(segments, navigator);
        break;

      case DeepLinkRoutes.chadhavaBookNow:
        _handleChadhavaBookFormRoute(segments, navigator);
        break;

      case DeepLinkRoutes.sangeet:
        _handleSangeetRoute(segments, navigator);
        break;

      case DeepLinkRoutes.sahitya:
        _handleSahityaRoute(segments, navigator);
        break;

      case DeepLinkRoutes.guruji:
        _handleGurujiRoute(segments, navigator);
        break;

      default:
        _handleUnknownRoute(uri);
        break;
    }
  }

  void _handleTourRoute(List<String> segments, NavigatorState navigator) {
    // Example routes:
    // /tour/vendor-tour/7                → Vendor Tour Details
    // /tour/all-vendor                   → All Vendor Page
    // /tour/visit/haridwar-rishikesh...  → Tour Visit Details (slug)
    // /tour                              → Tour Home Page

    if (segments.isEmpty) return;

    // /tour/vendor-tour/7 → Vendor Tour Details
    if (segments.length >= 3 && segments[1].toLowerCase() == 'vendor-tour') {
      final vendorId = segments[2];
      debugPrint('🧭 Navigating to Vendor Tour Details with ID: $vendorId');
      navigator.pushNamed(
        '/vendor-tour-details',
        arguments: {'id': vendorId},
      );
      return;
    }

    // /tour/all-vendor → All Vendor Page
    if (segments.length >= 2 && segments[1].toLowerCase() == 'all-vendor') {
      debugPrint('🧭 Navigating to All Vendor Page');
      navigator.pushNamed('/all-vendor');
      return;
    }

    // 🟢 Example link: https://sit.rizrv.com/tour/1-day-ujjain-tour-7e5zPC
    if (segments.length >= 2 && segments[0].toLowerCase() == 'tour') {
      final productSlug = Uri.decodeComponent(segments[1]);
      debugPrint(
          '🧭 Navigating to Tour Details with productSlug: $productSlug');

      navigator.pushNamed(
        '/tour-details',
        arguments: {'productSlug': productSlug},
      );
      return;
    }

    // /tour → Tour Home Page
    debugPrint('🧭 Navigating to Tour Home Page');
    navigator.pushNamed('/tour-home');
  }

  void _handleEventRoute(List<String> segments, NavigatorState navigator) {
    // Example: https://mahakal.com/event-details/133
    if (segments.isNotEmpty &&
        segments[0].toLowerCase() == 'event-details' &&
        segments.length > 1 &&
        segments[1].isNotEmpty) {
      final eventId = segments[1];
      debugPrint('Navigating to Event Details with ID: $eventId');
      navigator.pushNamed(
        '/event-details',
        arguments: {'id': eventId},
      );
      return;
    }

    // Example: https://mahakal.com/event
    debugPrint('Navigating to Event Home Page');
    navigator.pushNamed('/event-home');
  }

  void _handleBlogRoute(List<String> segments, NavigatorState navigator) {
    // Example URLs:
    // https://mahakal.com/blog                  → BlogHomePage
    // https://mahakal.com/blog/<slug>           → BlogDetailsPage(title: <slug>)
    // https://mahakal.com/blog/en/<slug>        → English BlogDetailsPage

    String safeDecode(String input) {
      try {
        return Uri.decodeComponent(input);
      } catch (e) {
        debugPrint('⚠️ URI decode error for $input: $e');
        return input; // fallback if invalid percent encoding
      }
    }

    if (segments.isEmpty) return;

    if (segments.length == 1) {
      // /blog
      debugPrint('🧭 Navigating to Blog Home Page');
      navigator.pushNamed('/blog-home');
    } else if (segments.length == 2) {
      // /blog/<slug>
      final blogSlug = safeDecode(segments[1]);
      debugPrint('🧭 Navigating to BlogDetailsPage with slug: $blogSlug');
      navigator.pushNamed(
        '/blog-details',
        arguments: {'title': blogSlug},
      );
    } else if (segments.length >= 3 && segments[1] == 'en') {
      // /blog/en/<slug> → English blogs
      final blogSlug = safeDecode(segments[2]);
      debugPrint(
          '🧭 Navigating to English BlogDetailsPage with slug: $blogSlug');
      navigator.pushNamed(
        '/blog-details',
        arguments: {'title': blogSlug},
      );
    } else {
      debugPrint('❌ Invalid blog deep link: $segments');
    }
  }

  void _handleDonationRoute(List<String> segments, NavigatorState navigator) {
    debugPrint('Navigating to Donation Home Page');
    navigator.pushNamed('/donation-home');
  }

  void _handleAnushthanRoute(List<String> segments, NavigatorState navigator) {
    // Example: [ "anushthan", "anushthan", "shani-dosh-nivaran-anusthaan" ]
    //https://sit.resrv.in/anushthan/anushthan/shani-dosh-nivaran-anusthaan
    if (segments.length >= 3 && segments[2].isNotEmpty) {
      final anushthanSlug = segments[2];

      navigator.pushNamed(
        '/anushthan',
        arguments: {
          'slugName': anushthanSlug,
          'type': "anushthan",
        },
      );
    } else {
      // If slug missing → show main anushthan page
      navigator.pushNamed('/pooja-home');
    }
  }

  void _handleVipRoute(List<String> segments, NavigatorState navigator) {
    debugPrint('Handling VIP route: $segments');
    //https://sit.resrv.in/vip/vippooja/kaal-sarp-dosh-shanti-puja
    if (segments.length >= 3 && segments[2].isNotEmpty) {
      // This means we have a specific pooja slug, e.g. vippooja/vish-dosh-nivaran-puja
      final vipSlug = segments[2];
      debugPrint('Navigating to Epooja for: $vipSlug');
      navigator.pushNamed(
        '/vip',
        arguments: {
          'slugName': vipSlug,
          'type': "vip",
        },
      );
    } else {
      // Otherwise go to the VIP Pooja home page
      debugPrint('Navigating to VIP Pooja Home');
      navigator.pushNamed('/pooja-home');
    }
  }

  void _handleLiveStreamRoute(List<String> segments, NavigatorState navigator) {
    if (segments.length >= 2 && segments[1].isNotEmpty) {
      final streamKey = segments[1];
      navigator.push(MaterialPageRoute(
        builder: (_) =>
            PoojaVideoPlayer(streamKey: streamKey, isRecorded: false),
      ));
    } else {
      // Insufficient info: do nothing instead of forcing splash
      debugPrint('Live stream deep link missing stream key: $segments');
    }
  }

  void _handleEpoojaRoute(List<String> segments, NavigatorState navigator) {
    final dateFormat = DateFormat('yyyy-MM-dd HH:mm:ss.SSS');
    if (segments.length >= 2 && segments[1].isNotEmpty) {
      final poojaSlug = segments[1];
      navigator.pushNamed(
        '/epooja',
        arguments: {
          'slugName': poojaSlug,
          'nextDatePooja': dateFormat.format(DateTime.now().add(const Duration(days: 7))),
        },
      );
      debugPrint('Pooja Date Next: ${dateFormat.format(DateTime.now().add(const Duration(days: 7)))}');
    } else {
      // If no slug, prefer showing the pooja home explicitly
      navigator.pushNamed('/pooja-home');
    }
  }

  void _handlePanchangRoute(NavigatorState navigator) {
    navigator.pushNamed('/panchang');
  }

  void _handleEcomRoute(List<String> segments, NavigatorState navigator) {
    // Example: https://mahakal.com/product/black-tourmaline-bracelet-|-24-beads-|-elastic-stretch-design
    // segments = ["product", "black-tourmaline-bracelet-|-24-beads-|-elastic-stretch-design"]

    if (segments.length >= 2) {
      final productSlug = Uri.decodeComponent(
          segments[1]); // decode in case slug has special chars

      navigator.pushNamed(
        '/product-details',
        arguments: {
          'productId': 0, // default or from API later if needed
          'slug': productSlug,
        },
      );
    } else {
      debugPrint("❌ Invalid product deep link: $segments");
    }
  }

  void _handleShopRoute(NavigatorState navigator) {
    debugPrint("🧭 Navigating to Shop (HomePage)");
    navigator.pushNamed('/shop');
  }

  void _handleDarshanRoute(List<String> segments, NavigatorState navigator) {
    // Example: https://mahakal.com/darshan
    // segments = ["darshan"]

    if (segments.length == 1) {
      debugPrint("🧭 Navigating to MandirDarshan(tabIndex: 0)");
      navigator.pushNamed('/darshan');
    } else {
      debugPrint("❌ Invalid darshan deep link: $segments");
    }
  }

  void _handleOfflineRoute(List<String> segments, NavigatorState navigator) {
    // Example URLs:
    // https://mahakal.com/offline/pooja/all       → OfflinePoojaHome(tabIndex: 0)
    // https://mahakal.com/offline/pooja/<tab>     → OfflinePoojaHome(tabIndex: <index>)
    // https://mahakal.com/offline/pooja/detail/<slug> → OfflinePoojaDetails(slugName: <slug>)

    if (segments.isEmpty) return;

    if (segments.length >= 3 &&
        segments[0] == 'offline' &&
        segments[1] == 'pooja') {
      //final tabParam = segments[2].toLowerCase();
      //int tabIndex = 0;

      // You can map tab names to index values here if needed:
      // if (tabParam == 'all') {
      //   tabIndex = 0;
      // } else if (tabParam == 'completed') {
      //   tabIndex = 1;
      // } else if (tabParam == 'pending') {
      //   tabIndex = 2;
      // }

      // 🟢 Handle detail route
      if (segments[2] == 'detail' && segments.length >= 4) {
        final slug = Uri.decodeComponent(segments[3]);
        debugPrint('🧭 Navigating to OfflinePoojaDetails with slug: $slug');
        navigator.pushNamed(
          '/offline-pooja-details',
          arguments: {'slugName': slug},
        );
        return;
      }

      debugPrint('🧭 Navigating to OfflinePoojaHome');

      navigator.pushNamed(
        '/offline-pooja',
        arguments: {'tabIndex': 0},
      );
    } else {
      debugPrint('❌ Invalid offline pooja deep link: $segments');
    }
  }

  void _handleKundaliPdfRoute(List<String> segments, NavigatorState navigator) {
    // Example URLs:
    // https://mahakal.com/kundali-pdf
    // https://mahakal.com/kundali-pdf/kundali/2
    // https://mahakal.com/kundali-pdf/kundali_milan/3

    if (segments.isEmpty) return;

    // 🧭 Case 1: /kundali-pdf → AstrologyView
    if (segments.length == 1 && segments[0] == 'kundali-pdf') {
      debugPrint('🧭 Navigating to AstrologyView');
      navigator.pushNamed('/astrology');
      return;
    }

    // 🧭 Case 2: /kundali-pdf/<pdfType>/<pdfId> → PdfDetailsView
    if (segments.length >= 3 && segments[0] == 'kundali-pdf') {
      final pdfType = segments[1];
      final pdfId = segments[2];

      debugPrint('🧭 Navigating to PdfDetailsView → type=$pdfType, id=$pdfId');

      navigator.pushNamed(
        '/pdf-details',
        arguments: {
          'pdfId': pdfId,
          'pdfType': pdfType,
        },
      );
      return;
    }

    debugPrint('❌ Invalid kundali-pdf deep link: $segments');
  }

  void _handleTempleDetailsRoute(
      List<String> segments, NavigatorState navigator) {
    // Example:
    // https://mahakal.com/temple-details/mangalnath-mandir-A5yrIj

    if (segments.isEmpty) return;

    if (segments.length >= 2 && segments[0] == 'temple-details') {
      final detailId = Uri.decodeComponent(segments[1]);

      debugPrint('🧭 Navigating to MandirDetailView → detailId: $detailId');

      navigator.pushNamed(
        '/mandir-details',
        arguments: {
          'detailId': detailId,
        },
      );
      return;
    }

    debugPrint('❌ Invalid temple-details deep link: $segments');
  }

  void _handleEventDetailsRoute(
      List<String> segments, NavigatorState navigator) {
    // Example:
    // https://mahakal.com/event-details/shrimad-bhagwat-katha-vrindavan-dham-AVo3qJ

    if (segments.isEmpty) return;

    if (segments.length >= 2 && segments[0] == 'event-details') {
      final eventSlug = Uri.decodeComponent(segments[1]);

      debugPrint('🧭 Navigating to EventDetails → eventId: $eventSlug');

      navigator.pushNamed(
        '/event-details',
        arguments: {'eventSlug': eventSlug},
      );
      return;
    }

    debugPrint('❌ Invalid event-details deep link: $segments');
  }

  void _handleCounsellingRoute(
      List<String> segments, NavigatorState navigator) {
    // 🧭 Example URLs:
    // https://mahakal.com/counselling/astrology
    // https://mahakal.com/counselling/details/vehicle-purchase-muhurat

    if (segments.isEmpty) return;

    // Case 1: /counselling/astrology → AstroConsultationView
    if (segments.length >= 2 &&
        segments[0] == 'counselling' &&
        segments[1] == 'astrology') {
      debugPrint('🧭 Navigating to AstroConsultationView');
      navigator.pushNamed('/astro-consultation');
      return;
    }

    // Case 2: /counselling/details/<slug> → AstroDetailsView
    if (segments.length >= 3 &&
        segments[0] == 'counselling' &&
        segments[1] == 'details') {
      final productSlug = Uri.decodeComponent(segments[2]);

      debugPrint(
          '🧭 Navigating to AstroDetailsView with productId: $productSlug');

      navigator.pushNamed(
        '/astro-details',
        arguments: {
          'productId': productSlug,
          'isProduct': true,
        },
      );
      return;
    }

    debugPrint('❌ Invalid counselling deep link: $segments');
  }

  void _handleChadhavaRoute(List<String> segments, NavigatorState navigator) {
    if (segments.isEmpty) return;

    // 🟢 Chadhava Details: /chadhava/details/<slug>
    if (segments.length >= 3 &&
        segments[0] == 'chadhava' &&
        segments[1] == 'details') {
      final idNumber = Uri.decodeComponent(segments[2]);
      debugPrint('🧭 Navigating to ChadhavaDetailView with idNumber: $idNumber');

      navigator.pushNamed(
        '/chadhava-detail',
        arguments: {'idNumber': idNumber},
      );
      return;
    }

    // 🟢 Chadhava Home Tabs: /chadhava/<tab>
    if (segments[0] == 'chadhava') {
      int tabIndex = 7; // default

      debugPrint('🧭 Navigating to OfflinePoojaHome with tabIndex: $tabIndex');
      navigator.pushNamed(
        '/pooja-chadhava',
        arguments: {'tabIndex': tabIndex},
      );
      return;
    }

    debugPrint('❌ Invalid chadhava deep link: $segments');
  }

  void _handleAdsDonationRoute(
      List<String> segments, NavigatorState navigator) {
    // Example: /all-donate/vastradaan-clothing-donation-QEq1pL

    if (segments.isEmpty) return;

    if (segments.length >= 2 && segments[0] == 'all-donate') {
      final myId = Uri.decodeComponent(segments[1]);

      debugPrint('🧭 Navigating to Donationpage with myId: $myId');

      navigator.pushNamed(
        '/donation-ads-details',
        arguments: {'myId': myId},
      );
      return;
    }

    debugPrint('❌ Invalid donation deep link: $segments');
  }

  void _handleTrustDonationRoute(List<String> segments, NavigatorState navigator) {
    // Example:
    // /donate-trust/manal-social-foundation-ZToPyXw

    if (segments.isEmpty) return;

    if (segments.length >= 2 && segments[0] == 'donate-trust') {
      final myId = Uri.decodeComponent(segments[1]);

      debugPrint('🧭 Navigating to Trust DetailsPage with myId: $myId');

      navigator.pushNamed(
        '/trust-details',
        arguments: {'myId': myId},
      );
      return;
    }

    debugPrint('❌ Invalid donate-trust deep link: $segments');
  }

  void _handlePoojaBookFormRoute(List<String> segments, NavigatorState navigator) {
    final dateFormat = DateFormat('yyyy-MM-dd HH:mm:ss.SSS');
    if (segments.length >= 2 && segments[1].isNotEmpty) {
      final poojaFormSlug = segments[1];
      navigator.pushNamed(
        '/epooja',
        arguments: {
          'slugName': poojaFormSlug,
        },
      );
    } else {
      // If no slug, prefer showing the pooja home explicitly
      navigator.pushNamed('/pooja-home');
    }
  }

  void _handleChadhavaBookFormRoute(List<String> segments, NavigatorState navigator) {
    if (segments.length >= 2 && segments[1].isNotEmpty) {
      final idNumber = segments[1]; // here 'special-offerings-to-lord-hanuman'
      navigator.pushNamed(
        '/chadhava-detail',
        arguments: {'idNumber': idNumber},
      );
    } else {
      // If no slug, navigate to chadhava home or fallback route
      navigator.pushNamed('/chadhava-home');
    }
  }

  void _handleShopViewRoute(List<String> segments, NavigatorState navigator) {
    // Example URL: https://mahakal.com/shopView/mahakalcom-prashadam-dol7oL
    // Segments: ['shopView', 'mahakalcom-prashadam-dol7oL']

    if (segments.isEmpty) return;

    // Validate structure
    if (segments.length >= 2 && segments[0] == 'shopView') {
      // Extract product or shop ID (second part)
      final shopId = Uri.decodeComponent(segments[1]);

      debugPrint('🧭 Navigating to ShopView with shopId: $shopId');

      navigator.pushNamed(
        '/shop-view-details',
        arguments: {'shopId': shopId},
      );
      return;
    }

    debugPrint('❌ Invalid shop deep link: $segments');
  }

  void _handleSangeetRoute(List<String> segments, NavigatorState navigator) {
    // Example URL: /sangeet/category/7
    if (segments.length >= 3 && segments[2].isNotEmpty) {
      final categoryId = segments[2]; // here '7'
      navigator.pushNamed(
        '/sangeet-category',
        arguments: {'categoryId': categoryId},
      );
    } else {
      // If no category id, navigate to sangeet home or fallback route
      navigator.pushNamed('/sangeet-home');
    }
  }

  void _handleSahityaRoute(List<String> segments, NavigatorState navigator) {
    navigator.pushNamed('/sahitya-home');
  }

  void _handleGurujiRoute(List<String> segments, NavigatorState navigator) {
    navigator.pushNamed('/guruji-home');
  }



  Future<void> _handleUnknownRoute(Uri uri) async {
    try {
      final navigator = navigatorKey.currentState;
      if (navigator == null) {
        debugPrint('Navigator not ready; cannot open in-app webview: $uri');
        return;
      }

      // Only handle http(s)
      if (uri.scheme == 'https' || uri.scheme == 'http') {
        navigator.push(
          MaterialPageRoute(
            builder: (_) => InAppWebViewPage(
              url: uri,
              onOpenExternally: (u) async {
                // Pause the deep-link listener so the outgoing browser intent
                // isn't intercepted by app_links.
                debugPrint(
                    '⏸️ Pausing deep link listener for external open: $u');
                _linkSubscription?.pause();

                // Try opening externally
                final opened =
                    await launchUrl(u, mode: LaunchMode.externalApplication);
                debugPrint('Launched externally: $opened');

                // Resume after a short grace period
                Future.delayed(const Duration(seconds: 2), () {
                  if (_linkSubscription?.isPaused ?? false) {
                    _linkSubscription?.resume();
                    debugPrint(
                        '▶️ Resumed deep link listener after external open');
                  }
                });

                // If failed, show a toast/snack using navigator context
                if (!opened && navigator.context.mounted) {
                  ScaffoldMessenger.of(navigator.context).showSnackBar(
                    const SnackBar(
                        content: Text('Could not open in external browser')),
                  );
                }
              },
            ),
          ),
        );
      } else {
        debugPrint('Ignoring non-https unknown route: $uri');
      }
    } catch (e, st) {
      debugPrint('❌ Error opening in-app webview for $uri: $e\n$st');
      // Ensure listener resumed on error
      if (_linkSubscription?.isPaused ?? false) {
        _linkSubscription?.resume();
      }
    }
  }

}
