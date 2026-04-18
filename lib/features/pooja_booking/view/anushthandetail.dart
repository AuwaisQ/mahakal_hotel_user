import 'dart:async';
import 'dart:convert';
import 'package:appbar_animated/appbar_animated.dart';
import 'package:avatar_stack/avatar_stack.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mahakal/features/pooja_booking/view/tabbarview_screens/askquestions.dart';
import 'package:mahakal/utill/app_constants.dart';
import 'package:intl/intl.dart';
import 'package:mahakal/utill/loading_datawidget.dart';
import 'package:provider/provider.dart';
import 'package:tdk_bouncingwidget/tdk_bouncingwidget.dart';
import 'dart:math' as math;
import '../../../main.dart';
import '../../../utill/devotees_count_widget.dart';
import '../../profile/controllers/profile_contrroller.dart';
import '../model/packagesmodel.dart';
import '../model/productsmodel.dart';
import 'newbilldetails.dart';
import 'tabbarview_screens/listreview.dart';
import 'package:http/http.dart' as http;

class SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  SliverAppBarDelegate({
    required this.minHeight,
    required this.maxHeight,
    required this.child,
  });
  final double minHeight;
  final double maxHeight;
  final Widget child;

  @override
  double get minExtent => minHeight;
  @override
  double get maxExtent => math.max(maxHeight, minHeight);
  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return SizedBox.expand(child: child);
  }

  @override
  bool shouldRebuild(SliverAppBarDelegate oldDelegate) {
    return maxHeight != oldDelegate.maxHeight ||
        minHeight != oldDelegate.minHeight ||
        child != oldDelegate.child;
  }
}

class AnushthanDetails extends StatefulWidget {
  final String idNumber;
  final String typePooja;
  const AnushthanDetails(
      {super.key, required this.idNumber, required this.typePooja});

  @override
  _AnushthanDetailsState createState() => _AnushthanDetailsState();
}

class _AnushthanDetailsState extends State<AnushthanDetails>
    with TickerProviderStateMixin {
  final oneKey = GlobalKey();
  final twoKey = GlobalKey();
  final threeKey = GlobalKey();
  final fourKey = GlobalKey();
  final fiveKey = GlobalKey();
  final sixKey = GlobalKey();
  final sevenKey = GlobalKey();

  final sliverListtKey = GlobalKey();

  // late RenderBox overRender;
  // late RenderBox revRender;
  // late RenderBox menuRender;
  // late RenderBox contactRender;
  // late RenderBox sliverRender;

  final ScrollController scrollController = ScrollController();
  double previousOffset = 0.0;
  bool isAppBarVisible = false;
  late TabController _tabController;
  late TabController _topTabController;

  late double greenHeight;
  late double blueHeight;
  late double orangeHeight;
  late double yellowHeight;
  late double blackHeight;
  late double whiteHeight;
  late double redHeight;

  // final List<GlobalKey> _tabKeys = [
  //   GlobalKey(),
  //   GlobalKey(),
  //   GlobalKey(),
  //   GlobalKey(),
  //   GlobalKey(),
  //   GlobalKey(),
  //   GlobalKey(),
  // ];
  // final List<GlobalKey> _tabKeys = List.generate(7, (index) => GlobalKey());

  @override
  void initState() {
    super.initState();
    print("My Anushrhan id: ${widget.idNumber}");
    print("My Anushrhan id: ${widget.typePooja}");
    getDetailsData();
    // getAnushthanData();
    scrollController.addListener(() {
      handleAppBarVisibility();
      addScrollControllerListener();
    });
    _tabController = TabController(length: 7, vsync: this);
    for (var i = 0; i < product.length; i++) {
      allProductIds.add(product[i].productId);
    }
    userName =
        Provider.of<ProfileController>(Get.context!, listen: false).userNAME;
    userPhone =
        Provider.of<ProfileController>(Get.context!, listen: false).userPHONE;
  }

  Duration countdownDuration = Duration.zero;
  Timer? countdownTimer;

  void addScrollControllerListener() {
    scrollController.addListener(() {
      // Update heights of keys if their contexts are available
      if (oneKey.currentContext != null) {
        greenHeight = oneKey.currentContext!.size!.height;
      }
      if (twoKey.currentContext != null) {
        blueHeight = twoKey.currentContext!.size!.height;
      }
      if (threeKey.currentContext != null) {
        orangeHeight = threeKey.currentContext!.size!.height;
      }
      if (fourKey.currentContext != null) {
        yellowHeight = fourKey.currentContext!.size!.height;
      }
      if (fiveKey.currentContext != null) {
        blackHeight = fiveKey.currentContext!.size!.height;
      }
      if (sixKey.currentContext != null) {
        whiteHeight = sixKey.currentContext!.size!.height;
      }
      if (sevenKey.currentContext != null) {
        redHeight = sevenKey.currentContext!.size!.height;
      }

      // Calculate cumulative heights
      List<double> cumulativeHeights = [];
      double cumulativeHeight = 0;

      // Add height from each key to cumulative height
      for (GlobalKey key in [
        oneKey,
        twoKey,
        threeKey,
        fourKey,
        fiveKey,
        sixKey,
        sevenKey,
      ]) {
        if (key.currentContext != null) {
          cumulativeHeight += key.currentContext!.size!.height;
        }
        cumulativeHeights.add(cumulativeHeight);
      }

      // Handle scroll direction
      double offset = scrollController.offset;
      double buffer = 200; // Buffer for scroll offset

      if (scrollController.position.userScrollDirection ==
          ScrollDirection.reverse) {
        for (int i = 0; i < cumulativeHeights.length; i++) {
          if (offset < cumulativeHeights[i] + buffer) {
            _tabController.animateTo(i);
            break;
          }
        }
      } else if (scrollController.position.userScrollDirection ==
          ScrollDirection.forward) {
        for (int i = 0; i < cumulativeHeights.length; i++) {
          if (offset < cumulativeHeights[i]) {
            _tabController.animateTo(i);
            break;
          }
        }
      }
    });
  }

  void handleAppBarVisibility() {
    double currentOffset = scrollController.offset;

    if (currentOffset > previousOffset) {
      // Scrolling down
      if (!isAppBarVisible) {
        setState(() {
          isAppBarVisible = true; // Hide the AppBar
        });
      }
    } else if (currentOffset < previousOffset) {
      // Scrolling up
      if (isAppBarVisible) {
        setState(() {
          isAppBarVisible = false; // Show the AppBar
        });
      }
    }

    // Update previousOffset for the next scroll event
    previousOffset = currentOffset;
  }

  String poojaSlug = "";
  String enName = "";
  String enAboutDetails = "";
  String enBenefitsDetails = "";
  String enProcessDetails = "";
  String enTempleDetails = "";

  String hiName = "";
  String hiAboutDetails = "";
  String hiBenefitsDetails = "";
  String hiProcessDetails = "";
  String hiTempleDetails = "";

  List<PackagesModel> package = <PackagesModel>[];
  List<ProductsModel> product = <ProductsModel>[];
  int serviceId = 0;
  int count = 0;
  String productType = "";
  String venue = "";
  String thumbnail = "";
  String targetDays = '';
  // DateTime get targetDate => DateTime.parse(widget.nextDatePooja);
  bool gridList = false;
  String translateEn = 'hi';

  // package data
  String userName = '';
  String userPhone = '';
  int leadId = 0;
  int leadPackageId = 0;
  int leadServiceId = 0;
  bool isNext = false;
  List<String> allProductIds = [];
  // AnushthanModel? anushthanData;

  // void getAnushthanData() async{
  //   var res = await HttpService().getApi(AppConstants.anushthanDetailUrl+widget.idNumber);
  //   if(res['status'] == 200){
  //     anushthanData = anushthanModelFromJson(res["data"]);
  //   }
  // }

  Future<void> getDetailsData() async {
    final url = Uri.parse(AppConstants.baseUrl +
        AppConstants.anushthanDetailUrl +
        widget.idNumber);
    print("My Anushthan Url: ${url}");
    final response = await http.get(url);

    if (response.statusCode == 200) {
      var res = json.decode(response.body);

      setState(() {
        // English details
        poojaSlug = res["data"]["slug"] ?? '';
        enName = res["data"]["en_name"] ?? '';
        enAboutDetails = res["data"]["en_details"] ?? '';
        enBenefitsDetails = res["data"]["en_benefits"] ?? '';
        enProcessDetails = res["data"]["en_process"] ?? '';
        enTempleDetails = res["data"]["en_temple_details"] ?? '';

        // Hindi details
        hiName = res["data"]["hi_name"] ?? '';
        hiAboutDetails = res["data"]["hi_details"] ?? '';
        hiBenefitsDetails = res["data"]["hi_benefits"] ?? '';
        hiProcessDetails = res["data"]["hi_process"] ?? '';
        hiTempleDetails = res["data"]["hi_temple_details"] ?? '';

        // Other details
        serviceId = res["data"]["id"] ?? 0;
        count = res["data"]["count"] ?? 0;
        productType = res["data"]["product_type"] ?? '';
        venue = res["data"]["venues"] ?? '';
        targetDays = res["data"]["week_days"] ?? '';
        thumbnail = res["data"]["thumbnail"] ?? '';

        // Packages
        List packagesList = res["data"]["packages"] ?? [];
        package = packagesModelFromJson(jsonEncode(packagesList));

        // Products
        List productList = res["data"]["products"] ?? [];
        product = productsModelFromJson(jsonEncode(productList));

        // Start the countdown
        // startCountdown();
      });
    } else {
      // Handle non-200 responses
      throw Exception(
          'Failed to load pooja data. Status Code: ${response.statusCode}');
    }
  }

  String formatDuration(Duration duration) {
    return '${duration.inHours}:${duration.inMinutes.remainder(60)}:${duration.inSeconds.remainder(60)}';
  }

  List<String> imagePaths = [
    "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSUToy14Ex7F4of_WK0Zr_5Fks_IKhzrICCHQ&s",
    "https://i.pinimg.com/736x/56/de/95/56de95bb1f6ede91b69acdd3ae5072c5.jpg",
    "https://1.bp.blogspot.com/-D93XGu464NM0uYOd_AgB2pPjKOnaQN0hnlGxgVu17DEG1jplL7WqBaeqVML8v3FP0MEJwDSDEJGn5-CSyA",
    "https://pbs.twimg.com/media/FBWq0BIVIAIVpr3.jpg",
    "https://i.pinimg.com/originals/43/a5/b0/43a5b0ea0253b4af61e3d21608b26884.jpg",
    "https://static.wixstatic.com/media/436168_5bcfe5cd6cc24a1cb5dcbd5ae658910a~mv2.jpg/v1/fill/w_560,h_372,al_c,q_80,usm_0.66_1.00_0.01,enc_auto/ujjain-mahakaleshwar-temple.jpg"
  ];

  late Timer timer;

  void _scrollToTarget() {
    // Switch to the tab
    _tabController.animateTo(4); // Switch to the 5th tab (0-based index)
    // Scroll to the target widget after a short delay to ensure tab switch completes
    Timer(const Duration(milliseconds: 500), () {
      final context = fiveKey.currentContext;
      if (context != null) {
        Scrollable.ensureVisible(
          context,
          duration: const Duration(milliseconds: 500),
        );
      }
    });
  }

  Future<void> getAnushthanLeadSave(int index, String date) async {
    // Define the API endpoint
    const String apiUrl =
        '${AppConstants.baseUrl}${AppConstants.anushthanLeadUrl}';
    Map<String, dynamic> data = {
      "service_id": serviceId,
      "type": "anushthan",
      "package_id": package[index].packageId,
      "product_id": allProductIds,
      "package_name": package[index].enPackageName,
      "package_price": package[index].packagePrice,
      "noperson": package[index].person,
      "person_phone": userPhone,
      "person_name": userName,
      "booking_date": date,
    };

    // Make the POST request
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(data),
      );

      if ([200, 201].contains(response.statusCode)) {
        // Handle success
        print('Booking successful vip lead');
        // Optionally, parse the response
        var responseData = jsonDecode(response.body);
        leadId = responseData['lead']['id'];
        leadPackageId = responseData['lead']['package_id'];
        leadServiceId = responseData['lead']['service_id'];
        setState(() {
          isNext = false;
        });
        Navigator.push(
            context,
            CupertinoPageRoute(
              builder: (context) => Newbilldetails(
                billAmount: package[index].packagePrice,
                product: product,
                personCount: 1,
                typePooja: widget.typePooja,
                orderId: serviceId,
                packageName: package[index].enPackageName,
                poojaName: enName,
                poojaVenue: venue,
                date: date,
                leadId: leadId,
                packageId: leadPackageId,
                serviceId: leadServiceId,
                couponType: 'anushthan',
              ),
            ));
        // print(responseData);
      } else {
        // Handle error
        print('Failed to book anushthan: ${response.statusCode}');
        print(response.body);
      }
    } catch (e) {
      // Handle exception
      print('An error occurred: $e');
    }
  }

  String _selectedDate = ""; // Store the selected date here
  Future<DateTime?> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now().add(const Duration(days: 1)),
      lastDate: DateTime(2100),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.orange.shade100,
              onPrimary: Colors.orange,
              surface: const Color(0xFFFFF7EC),
              onSurface: Colors.orange,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Colors.orange,
                backgroundColor: Colors.white,
              ),
            ),
            dialogTheme:
                const DialogThemeData(backgroundColor: Color(0xFFFFF7EC)),
          ),
          child: child!,
        );
      },
    );
    return picked;
  }

  String formatDateString(String dateString) {
    try {
      // Parse the input date string
      DateTime dateTime = DateFormat('yyyy-MM-dd').parse(dateString);
      // Format the parsed DateTime object into the desired format
      return DateFormat('yyyy-MM-dd').format(dateTime);
    } catch (e) {
      // Handle error and return current date as fallback
      print("Error parsing date: $e");
      return DateFormat('yyyy-MM-dd').format(DateTime.now());
    }
  }

  Color hexToColor(String hex) {
    // Add a leading hash if it's not present
    hex = hex.startsWith('#') ? hex : '#$hex';

    // Parse the string as an integer and create a Color object
    return Color(int.parse(hex.replaceFirst('#', '0xff')));
  }

  void showInfo(String description, String color) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withOpacity(0.5),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      builder: (context) {
        return Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.9,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(20),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Draggable handle
              Center(
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade400,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // Header
              Row(
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    color: hexToColor(color),
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Package Details',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: hexToColor(color),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Content
              Expanded(
                child: SingleChildScrollView(
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: hexToColor(color).withOpacity(0.08),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: hexToColor(color).withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    child: Html(
                      data: description,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Close button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: hexToColor(color),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Close',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    // TODO: implement dispose
    // timer.cancel();
    super.dispose();
    _topTabController.dispose();
    scrollController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // String dayOfWeek = DateFormat('EEEE').format(targetDate);
    // String firstTargetDay = targetDays.split(', ').first;
    // DateTime previousDate = targetDate.subtract(Duration(days: 1));
    var screenHeight = MediaQuery.of(context).size.height;
    var screenWidth = MediaQuery.of(context).size.width;

    return RefreshIndicator(
      onRefresh: () async {
        getDetailsData();
      },
      child: enName.isEmpty
          ? MahakalLoadingData(onReload: () {})
          : Scaffold(
              backgroundColor: Colors.white,
              floatingActionButtonLocation:
                  FloatingActionButtonLocation.centerDocked,
              floatingActionButton: GestureDetector(
                onTap: () {
                  _scrollToTarget();
                },
                child: Container(
                  margin: const EdgeInsets.all(10),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    gradient: LinearGradient(
                      colors: [Colors.orange.shade700, Colors.orange.shade400],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.orange.shade800.withOpacity(0.3),
                        blurRadius: 10,
                        spreadRadius: 1,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Text(
                        translateEn == "en" ? "Select Package" : "पैकेज चुनें",
                        style: TextStyle(
                          fontFamily: 'Roboto',
                          fontWeight: FontWeight.w600,
                          fontSize: 20,
                          color: Colors.white,
                          letterSpacing: 0.8,
                          shadows: [
                            Shadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 2,
                              offset: const Offset(1, 1),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.white.withOpacity(0.8),
                              blurRadius: 10,
                              spreadRadius: 1,
                            ),
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.arrow_forward_rounded,
                          size: 22,
                          color: Colors.orange, // Matching the gradient start
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              body: ScaffoldLayoutBuilder(
                backgroundColorAppBar:
                    const ColorBuilder(Colors.transparent, Colors.white),
                textColorAppBar: const ColorBuilder(Colors.black),
                appBarBuilder: _appBar,
                child: Stack(
                  children: [
                    //App Bar
                    SizedBox(
                      height: 320,
                      width: double.infinity,
                      child: Image.network(
                        thumbnail,
                        fit: BoxFit.fill,
                      ),
                    ),

                    SingleChildScrollView(
                      controller: scrollController,
                      child: Container(
                        decoration: const BoxDecoration(
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(15),
                          ),
                          color: Colors.white,
                        ),
                        margin: const EdgeInsets.only(
                          top: 280,
                        ),
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10.0, vertical: 5.0),
                              decoration: const BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(10),
                                      topRight: Radius.circular(10))),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        flex: 1,
                                        child: Text(
                                          translateEn == "en" ? enName : hiName,
                                          style: const TextStyle(
                                              color: Colors.orange,
                                              fontSize: 22,
                                              fontFamily: 'Roboto',
                                              fontWeight: FontWeight.bold,
                                              overflow: TextOverflow.ellipsis),
                                          maxLines: 1,
                                        ),
                                      ),
                                      Expanded(
                                        flex: 0,
                                        child: BouncingWidgetInOut(
                                          onPressed: () {
                                            setState(() {
                                              gridList = !gridList;
                                              translateEn =
                                                  gridList ? 'en' : 'hi';
                                            });
                                            getDetailsData();
                                          },
                                          bouncingType:
                                              BouncingType.bounceInAndOut,
                                          child: Container(
                                            height: 25,
                                            width: 25,
                                            decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(4.0),
                                                color: gridList
                                                    ? Colors.orange
                                                    : Colors.white,
                                                border: Border.all(
                                                    color: Colors.orange,
                                                    width: 2)),
                                            child: Center(
                                              child: Icon(
                                                Icons.translate,
                                                color: gridList
                                                    ? Colors.white
                                                    : Colors.orange,
                                                size: 18,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 5,
                                  ),
DevoteesCountWidget(),
                                  const SizedBox(
                                    height: 6,
                                  ),
                                  translateEn == "en"
                                      ? Text.rich(
                                          TextSpan(
                                            text: 'Till now',
                                            style: const TextStyle(
                                                fontSize: 16,
                                                color: Colors.black),
                                            children: <TextSpan>[
                                              TextSpan(
                                                text:
                                                    ' ${count + 10000}+Devotees',
                                                style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.orange,
                                                    fontSize: 16),
                                              ),
                                              const TextSpan(
                                                text:
                                                    ' Have experienced the divine blessings by participating in',
                                                style: TextStyle(
                                                    fontSize: 16,
                                                    color: Colors.black),
                                              ),
                                              const TextSpan(
                                                text:
                                                    ' Pooja services through Mahakal.com',
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.orange,
                                                    fontSize: 16),
                                              ),
                                            ],
                                          ),
                                          textAlign: TextAlign.start,
                                        )
                                      : Text.rich(
                                          TextSpan(
                                            text: 'अब तक',
                                            style: const TextStyle(
                                                fontSize: 16,
                                                color: Colors.black),
                                            children: <TextSpan>[
                                              TextSpan(
                                                text:
                                                    ' ${count + 10000}+Devotees',
                                                style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.orange,
                                                    fontSize: 16),
                                              ),
                                              const TextSpan(
                                                text:
                                                    ' ने महाकाल.कॉम की पूजा सेवा के माध्यम से आयोजित पूजा में सहभागी बन चुके हैं।',
                                                style: TextStyle(
                                                    fontSize: 16,
                                                    color: Colors.black),
                                              ),
                                            ],
                                          ),
                                          textAlign: TextAlign.start,
                                        ),
                                ],
                              ),
                            ),
                            Divider(
                              color: Colors.grey.shade400,
                            ),

                            // about container
                            Container(
                              key: oneKey,
                              child: Column(
                                children: [
                                  Html(
                                      data: translateEn == "en"
                                          ? enAboutDetails
                                          : hiAboutDetails),
                                ],
                              ),
                            ),
                            _dividerLine(),
                            Container(
                              key: twoKey,
                              child: Column(
                                children: [
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  Html(
                                      data: translateEn == "en"
                                          ? enBenefitsDetails
                                          : hiBenefitsDetails),
                                ],
                              ),
                            ),
                            _dividerLine(),
                            Container(
                              key: threeKey,
                              child: Column(
                                children: [
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  Html(
                                      data: translateEn == "en"
                                          ? enProcessDetails
                                          : hiProcessDetails),
                                ],
                              ),
                            ),
                            _dividerLine(),
                            Container(
                              key: fourKey,
                              child: Column(
                                children: [
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  Html(
                                      data: translateEn == "en"
                                          ? enTempleDetails
                                          : hiTempleDetails),
                                ],
                              ),
                            ),
                            _dividerLine(),
                            Container(
                              key: fiveKey,
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        margin: const EdgeInsets.only(left: 10),
                                        height: 20,
                                        width: screenWidth * 0.008,
                                        color: Colors.orange,
                                      ),
                                      SizedBox(width: screenWidth * 0.03),
                                      const Text(
                                        "Packages",
                                        style: TextStyle(
                                            fontSize: 20,
                                            fontFamily: 'Roboto',
                                            fontWeight: FontWeight.w700,
                                            color: Colors.black),
                                      )
                                    ],
                                  ),
                                  SizedBox(
                                    height: screenWidth * 0.02,
                                  ),
                                  CarouselSlider.builder(
                                    itemCount: package.length,
                                    options: CarouselOptions(
                                      scrollDirection: Axis.horizontal,
                                      enlargeStrategy:
                                          CenterPageEnlargeStrategy.scale,
                                      enlargeCenterPage: true,
                                      height: screenWidth *
                                          1.2, // Slightly reduced height for better proportions
                                      viewportFraction:
                                          0.80, // Better spacing between items
                                      enableInfiniteScroll: package.length > 1,
                                      autoPlay: package.length > 1,
                                      autoPlayInterval:
                                          const Duration(seconds: 5),
                                      autoPlayAnimationDuration:
                                          const Duration(milliseconds: 800),
                                      pauseAutoPlayOnTouch: true,
                                      scrollPhysics:
                                          const BouncingScrollPhysics(),
                                      onPageChanged: (index, reason) {
                                        // Optional: Add any on page change logic
                                      },
                                    ),
                                    itemBuilder: (context, index, realIndex) {
                                      final packageItem = package[index];
                                      final primaryColor =
                                          hexToColor(packageItem.color);
                                      final isEnglish = translateEn == "en";
                                      final ScrollController scrollController =
                                          ScrollController();
                                      return AnimatedScale(
                                        duration:
                                            const Duration(milliseconds: 300),
                                        scale: 1.0,
                                        child: GestureDetector(
                                          onTap: () async {
                                            if (package[index].packageId ==
                                                "7") {
                                              DateTime? pickedDate =
                                                  await _selectDate(context);
                                              if (pickedDate != null) {
                                                setState(() {
                                                  _selectedDate =
                                                      DateFormat("yyyy-MM-dd")
                                                          .format(pickedDate);
                                                });
                                                isNext
                                                    ? null
                                                    : getAnushthanLeadSave(
                                                        index, _selectedDate);
                                                setState(() {
                                                  isNext = true;
                                                });
                                              }
                                            } else {
                                              isNext
                                                  ? null
                                                  : getAnushthanLeadSave(
                                                      index,
                                                      DateFormat("yyyy-MM-dd")
                                                          .format(
                                                              DateTime.now()));
                                              setState(() {
                                                isNext = true;
                                              });
                                            }
                                          },
                                          child: Container(
                                            margin: const EdgeInsets.symmetric(
                                                horizontal: 0, vertical: 8),
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                              gradient: LinearGradient(
                                                begin: Alignment.topCenter,
                                                end: Alignment.bottomCenter,
                                                colors: [
                                                  Colors.white,
                                                  primaryColor
                                                      .withOpacity(0.08),
                                                ],
                                              ),
                                              border: Border.all(
                                                color: primaryColor
                                                    .withOpacity(0.2),
                                                width: 1.5,
                                              ),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black
                                                      .withOpacity(0.05),
                                                  blurRadius: 12,
                                                  offset: const Offset(0, 4),
                                                ),
                                              ],
                                            ),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.stretch,
                                              children: [
                                                // Package Price Ribbon with improved visual hierarchy
                                                Container(
                                                  padding: const EdgeInsets
                                                      .symmetric(vertical: 12),
                                                  decoration: BoxDecoration(
                                                    gradient: LinearGradient(
                                                      begin: Alignment.topLeft,
                                                      end:
                                                          Alignment.bottomRight,
                                                      colors: [
                                                        primaryColor
                                                            .withOpacity(0.15),
                                                        primaryColor
                                                            .withOpacity(0.3),
                                                      ],
                                                    ),
                                                    borderRadius:
                                                        const BorderRadius
                                                            .vertical(
                                                            top:
                                                                Radius.circular(
                                                                    16)),
                                                  ),
                                                  child: Column(
                                                    children: [
                                                      Text(
                                                        isEnglish
                                                            ? "Starting from"
                                                            : "शुरुआती कीमत",
                                                        style: TextStyle(
                                                          fontSize: 12,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          color: primaryColor
                                                              .withOpacity(0.8),
                                                        ),
                                                      ),
                                                      Text(
                                                        "₹${packageItem.packagePrice}",
                                                        textAlign:
                                                            TextAlign.center,
                                                        style:
                                                            GoogleFonts.poppins(
                                                          fontSize: 28,
                                                          fontWeight:
                                                              FontWeight.w800,
                                                          color: primaryColor,
                                                          letterSpacing: 0.5,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),

                                                // Package Content with optimized layout
                                                Expanded(
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            16),
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        // Package Name with better typography
                                                        Row(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Expanded(
                                                              child: Text(
                                                                isEnglish
                                                                    ? packageItem
                                                                        .enPackageName
                                                                    : packageItem
                                                                        .hiPackageName,
                                                                style:
                                                                    GoogleFonts
                                                                        .poppins(
                                                                  fontSize: 18,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w700,
                                                                  color: Colors
                                                                      .black87,
                                                                  height: 1.3,
                                                                ),
                                                              ),
                                                            ),
                                                            const SizedBox(
                                                                width: 8),
                                                            GestureDetector(
                                                              onTap: () =>
                                                                  showInfo(
                                                                isEnglish
                                                                    ? packageItem
                                                                        .enDescription
                                                                    : packageItem
                                                                        .hiDescription,
                                                                packageItem
                                                                    .color,
                                                              ),
                                                              child: Icon(
                                                                Icons
                                                                    .info_outline_rounded,
                                                                color:
                                                                    primaryColor,
                                                                size: 22,
                                                              ),
                                                            ),
                                                          ],
                                                        ),

                                                        const SizedBox(
                                                            height: 8),

                                                        // Person Count with icon
                                                        Row(
                                                          children: [
                                                            Icon(
                                                              Icons
                                                                  .person_outline,
                                                              size: 16,
                                                              color: Colors
                                                                  .grey[600],
                                                            ),
                                                            const SizedBox(
                                                                width: 4),
                                                            Text(
                                                              "Puja for ${packageItem.person} Person${packageItem.person > 1 ? "s" : ""}",
                                                              style: GoogleFonts
                                                                  .poppins(
                                                                fontSize: 14,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500,
                                                                color: Colors
                                                                    .grey[600],
                                                              ),
                                                            ),
                                                          ],
                                                        ),

                                                        const SizedBox(
                                                            height: 12),

                                                        // Description with optimized rendering
                                                        Expanded(
                                                          child: Scrollbar(
                                                            controller:
                                                                scrollController,
                                                            thumbVisibility:
                                                                true,
                                                            radius: const Radius
                                                                .circular(4),
                                                            thickness: 4,
                                                            child:
                                                                SingleChildScrollView(
                                                              controller:
                                                                  scrollController,
                                                              physics:
                                                                  const BouncingScrollPhysics(),
                                                              child: Html(
                                                                data: isEnglish
                                                                    ? packageItem
                                                                        .enDescription
                                                                    : packageItem
                                                                        .hiDescription,
                                                                style: {
                                                                  "body": Style(
                                                                    fontSize:
                                                                        FontSize(
                                                                            14.0),
                                                                    fontFamily:
                                                                        'Poppins',
                                                                    color: Colors
                                                                            .grey[
                                                                        800],
                                                                  ),
                                                                },
                                                              ),
                                                            ),
                                                          ),
                                                        ),

                                                        const SizedBox(
                                                            height: 16),

                                                        // Optimized Book Now Button
                                                        AnimatedContainer(
                                                          duration:
                                                              const Duration(
                                                                  milliseconds:
                                                                      300),
                                                          height: 48,
                                                          child: ElevatedButton(
                                                            onPressed:
                                                                () async {
                                                              if (package[index]
                                                                      .packageId ==
                                                                  "7") {
                                                                DateTime?
                                                                    pickedDate =
                                                                    await _selectDate(
                                                                        context);
                                                                if (pickedDate !=
                                                                    null) {
                                                                  setState(() {
                                                                    _selectedDate = DateFormat(
                                                                            "yyyy-MM-dd")
                                                                        .format(
                                                                            pickedDate);
                                                                  });
                                                                  isNext
                                                                      ? null
                                                                      : getAnushthanLeadSave(
                                                                          index,
                                                                          _selectedDate);
                                                                  setState(() {
                                                                    isNext =
                                                                        true;
                                                                  });
                                                                }
                                                              } else {
                                                                isNext
                                                                    ? null
                                                                    : getAnushthanLeadSave(
                                                                        index,
                                                                        DateFormat("yyyy-MM-dd")
                                                                            .format(DateTime.now()));
                                                                setState(() {
                                                                  isNext = true;
                                                                });
                                                              }
                                                            },
                                                            style:
                                                                ElevatedButton
                                                                    .styleFrom(
                                                              backgroundColor:
                                                                  primaryColor,
                                                              shape:
                                                                  RoundedRectangleBorder(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            12),
                                                              ),
                                                              elevation: 0,
                                                              shadowColor: Colors
                                                                  .transparent,
                                                              padding:
                                                                  const EdgeInsets
                                                                      .symmetric(
                                                                      vertical:
                                                                          12),
                                                            ),
                                                            child: isNext
                                                                ? const Center(
                                                                    child:
                                                                        SizedBox(
                                                                      height:
                                                                          20,
                                                                      width: 20,
                                                                      child:
                                                                          CircularProgressIndicator(
                                                                        strokeWidth:
                                                                            2,
                                                                        color: Colors
                                                                            .white,
                                                                      ),
                                                                    ),
                                                                  )
                                                                : Row(
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .center,
                                                                    children: [
                                                                      Text(
                                                                        isEnglish
                                                                            ? "Book Now"
                                                                            : "बुक करें",
                                                                        style: GoogleFonts
                                                                            .poppins(
                                                                          fontWeight:
                                                                              FontWeight.w600,
                                                                          fontSize:
                                                                              16,
                                                                          letterSpacing:
                                                                              0.5,
                                                                          color:
                                                                              Colors.white,
                                                                        ),
                                                                      ),
                                                                      const SizedBox(
                                                                          width:
                                                                              8),
                                                                      const Icon(
                                                                        Icons
                                                                            .arrow_forward_rounded,
                                                                        size:
                                                                            20,
                                                                        color: Colors
                                                                            .white,
                                                                      ),
                                                                    ],
                                                                  ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),

                            // _dividerLine(),
                            // Container(
                            //   key: sixKey,
                            //   child: PoojaReviewList(
                            //     dataUrl: 'review-anushthan/$poojaSlug',
                            //     translate: translateEn,
                            //   ),
                            // ),
                            _dividerLine(),
                            Container(
                              key: sevenKey,
                              child: Askquestions(
                                type: 'Anushthan',
                                translateEn: translateEn,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _dividerLine() {
    return Container(
      height: 1.5, // Thinner but more elegant
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.transparent,
            Colors.orange.shade300,
            Colors.orange.shade400,
            Colors.orange.shade300,
            Colors.transparent,
          ],
          stops: const [0.0, 0.2, 0.5, 0.8, 1.0],
        ),
      ),
    );
  }

  Widget _appBar(BuildContext context, ColorAnimated colorAnimated) {
    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: colorAnimated.background,
      elevation: 0,
      title: !isAppBarVisible
          ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
              decoration: BoxDecoration(
                  color: Colors.black45,
                  borderRadius: BorderRadius.circular(100)),
              child: Row(
                children: [
                  InkWell(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color:
                          !isAppBarVisible ? Colors.white : Colors.transparent,
                    ),
                  ),
                  const Spacer(),
                  const Text(
                    "Anushthan Details",
                    style: TextStyle(color: Colors.white),
                  ),
                  const Spacer(),
                ],
              ),
            )
          : null,
      // actions: [
      //   BouncingWidgetInOut(
      //     onPressed: () {
      //       setState(() {
      //         gridList = !gridList;
      //         translateEn = gridList ? 'en' : 'hi';
      //       });
      //       getDetailsData();
      //     },
      //     bouncingType: BouncingType.bounceInAndOut,
      //     child: Container(
      //       height: 25,
      //       width: 25,
      //       decoration: BoxDecoration(
      //           borderRadius:
      //           BorderRadius.circular(4.0),
      //           color: gridList
      //               ? Colors.orange
      //               : Colors.white,
      //           border: Border.all(
      //               color: Colors.orange,
      //               width: 2)),
      //       child: Center(
      //         child: Icon(
      //           Icons.translate,
      //           color: gridList
      //               ? Colors.white
      //               : Colors.orange,
      //           size: 18,
      //         ),
      //       ),
      //     ),
      //   ),
      //   SizedBox(width: 10,)
      // ],
      bottom: isAppBarVisible
          ? TabBar(
              onTap: (index) {
                // Handle tab tap
                print('Tapped tab: $index');
                Timer(const Duration(milliseconds: 500), () {
                  BuildContext? context;
                  switch (index + 1) {
                    case 1:
                      context = oneKey.currentContext;
                      break;
                    case 2:
                      context = twoKey.currentContext;
                      break;
                    case 3:
                      context = threeKey.currentContext;
                      break;
                    case 4:
                      context = fourKey.currentContext;
                      break;
                    case 5:
                      context = fiveKey.currentContext;
                      break;
                    case 6:
                      context = sixKey.currentContext;
                      break;
                    case 7:
                      context = sevenKey.currentContext;
                      break;
                  }

                  if (context != null) {
                    Scrollable.ensureVisible(
                      context,
                      duration: const Duration(milliseconds: 500),
                    );
                  }
                });
              },
              dividerColor: Colors.transparent,
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              unselectedLabelColor: Colors.black,
              indicatorColor: Colors.red,
              labelColor: Colors.orange,
              controller: _tabController,
              unselectedLabelStyle: const TextStyle(fontSize: 18),
              labelStyle: const TextStyle(fontSize: 20),
              tabs: const [
                Tab(
                  text: "About Puja",
                ),
                Tab(
                  text: "Benefits",
                ),
                Tab(
                  text: "Process",
                ),
                Tab(
                  text: "Terms & Condition",
                ),
                Tab(
                  text: "Packages",
                ),
                Tab(
                  text: "Reviews",
                ),
                Tab(
                  text: "FAQ's",
                ),
              ],
              indicatorSize: TabBarIndicatorSize.tab,
            )
          : null,
    );
  }
}
