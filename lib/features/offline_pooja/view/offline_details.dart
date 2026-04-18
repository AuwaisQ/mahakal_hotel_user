import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:appbar_animated/appbar_animated.dart';
import 'package:avatar_stack/avatar_stack.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mahakal/features/offline_pooja/model/return_policy_model.dart';
import 'package:mahakal/features/pooja_booking/view/tabbarview_screens/askquestions.dart';
import 'package:mahakal/utill/app_constants.dart';
import 'package:intl/intl.dart';
import 'package:mahakal/utill/loading_datawidget.dart';
import 'package:provider/provider.dart';
import 'package:tdk_bouncingwidget/tdk_bouncingwidget.dart';
import 'dart:math' as math;
import 'package:http/http.dart' as http;
import '../../../data/datasource/remote/http/httpClient.dart';
import '../../../main.dart';
import '../../../utill/devotees_count_widget.dart';
import '../../../utill/full_screen_image_slider.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../profile/controllers/profile_contrroller.dart';
import '../model/OfflinePackageModel.dart';
import '../model/offline_review_model.dart';
import 'offline_amount_screen.dart';

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

class OfflinePoojaDetails extends StatefulWidget {
  final String slugName;
  const OfflinePoojaDetails({super.key, required this.slugName});

  @override
  _OfflinePoojaDetailsState createState() => _OfflinePoojaDetailsState();
}

class _OfflinePoojaDetailsState extends State<OfflinePoojaDetails>
    with TickerProviderStateMixin {
  final oneKey = GlobalKey();
  final twoKey = GlobalKey();
  final threeKey = GlobalKey();
  final fourKey = GlobalKey();
  final fiveKey = GlobalKey();
  final sixKey = GlobalKey();
  final sevenKey = GlobalKey();

  // final sliverListtKey = GlobalKey();

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
    print(widget.slugName);
    //print("date checker ${widget.nextDatePooja}");
    userToken =
        Provider.of<AuthController>(Get.context!, listen: false).getUserToken();
    userNAME =
        Provider.of<ProfileController>(Get.context!, listen: false).userNAME;
    userPHONE =
        Provider.of<ProfileController>(Get.context!, listen: false).userPHONE;
    getDetailsData();
    getReturnPolicy();
    scrollController.addListener(() {
      handleAppBarVisibility();
      addScrollControllerListener();
    });
    _tabController = TabController(length: 7, vsync: this);
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

  Color hexToColor(String hex) {
    // Add a leading hash if it's not present
    hex = hex.startsWith('#') ? hex : '#$hex';

    // Parse the string as an integer and create a Color object
    return Color(int.parse(hex.replaceFirst('#', '0xff')));
  }

  String poojaSlug = "";
  String userToken = "";
  String userNAME = "";
  String userPHONE = "";

  String id = "";
  String enName = "";
  String enAboutDetails = "";
  String enBenefitsDetails = "";
  String enProcessDetails = "";
  String enTempleDetails = "";
  String entermsAndConditiion = "";

  String hiName = "";
  String hiAboutDetails = "";
  String hiBenefitsDetails = "";
  String hiProcessDetails = "";
  String hiTempleDetails = "";
  String hitermsAndConditiion = "";

  // String count = "";

  List<OfflinePackagesModel> package = <OfflinePackagesModel>[];
  List<City> citiesModelList = <City>[];
  // List<ProductsModel> product = <ProductsModel>[];
  int count = 0;
  int serviceId = 0;
  // String productType = "";
  String thumbnail = "";
  // String targetDays = '';
  //DateTime get targetDate => DateTime.parse(widget.nextDatePooja);

  bool gridList = false;
  bool isNext = false;
  String translateEn = 'hi';

  Future<void> getLeadGanerate(
      String packId, String mainAmount, String payableAmount, int index) async {
    final response = await http.post(
      Uri.parse("${AppConstants.baseUrl}/api/v1/offlinepooja/lead/store"),
      headers: {
        'Authorization': 'Bearer $userToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        "service_id": "$serviceId",
        "package_id": packId,
        "package_main_price": mainAmount,
        "package_price": payableAmount,
        "person_name": userNAME,
        "person_phone": userPHONE
      }),
    );

    print("service_id api : ${serviceId}");
    print("package_id api : ${packId}");
    print("package_main_price api : ${mainAmount}");
    print("package_price api : ${payableAmount}");
    print("person_name api : ${userNAME}");
    print("person_phone api : ${userPHONE}");

    var data = jsonDecode(response.body);
    if (data["status"]) {
      int leadId = data["lead_id"];
      Navigator.push(
          context,
          CupertinoPageRoute(
            builder: (context) => OfflineAmountScreen(
              totalAmount: package[index].packagePrice,
              bookingAmount: payableAmount,
              packageName: enName,
              imageUrl: thumbnail,
              detail: enTempleDetails,
              leadId: "$leadId",
              serviceId: "$serviceId",
              packageId: packId,
              translateEn: translateEn,
              id: id,
              citiesModelList: citiesModelList,
            ),
          ));
      setState(() {
        isNext = false;
      });
    } else {
      print("failed api status 400");
    }
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

  Future<void> getDetailsData() async {
    try {
      final url = Uri.parse(AppConstants.baseUrl +
          AppConstants.offlinePoojaSingleDetailUrl +
          widget.slugName);
      final response = await http.get(url);

      if (response.statusCode == 200) {
        var res = json.decode(response.body);

        setState(() {
          // poojaCategorydata = pooojaCategoryModelFromJson(response.body);

          // English details
          id = res["poojaDetails"]["id"].toString();
          poojaSlug = res["poojaDetails"]["slug"];
          enName = res["poojaDetails"]["en_name"] ?? '';
          enAboutDetails = res["poojaDetails"]["en_details"] ?? '';
          enBenefitsDetails = res["poojaDetails"]["en_benefits"] ?? '';
          enProcessDetails = res["poojaDetails"]["en_process"] ?? '';
          enTempleDetails = res["poojaDetails"]["en_short_benifits"] ?? '';
          entermsAndConditiion =
              res["poojaDetails"]["en_terms_conditions"] ?? '';

          // Hindi details
          hiName = res["poojaDetails"]["hi_name"] ?? '';
          hiAboutDetails = res["poojaDetails"]["hi_details"] ?? '';
          hiBenefitsDetails = res["poojaDetails"]["hi_benefits"] ?? '';
          hiProcessDetails = res["poojaDetails"]["hi_process"] ?? '';
          hiTempleDetails = res["poojaDetails"]["hi_short_benifits"] ?? '';
          hitermsAndConditiion =
              res["poojaDetails"]["hi_terms_conditions"] ?? '';
          count = res["poojaDetails"]["count"] ?? 0;

          // Other details
          serviceId = res["poojaDetails"]["id"] ?? 0;
          thumbnail = res["poojaDetails"]["thumbnail"] ?? '';

          // Packages
          List packagesList = res["poojaDetails"]["package_details"] ?? [];
          package = offlinepackagesModelFromJson(jsonEncode(packagesList));

          List cityList = res["poojaDetails"]["cities"] ?? [];
          citiesModelList.addAll(cityList.map((e) => City.fromJson(e)));

          print("api response cities ${citiesModelList.length}");
          // getReviewData("$serviceId");
        });
      } else {
        // Handle non-200 responses
        throw Exception(
            'Failed to load pooja data. Status Code: ${response.statusCode}');
      }
    } catch (e) {
      // Log and handle any other errors (e.g., network errors, JSON parsing errors)
      log("Error fetching pooja details: $e");
      throw Exception('Failed to load pooja data: $e');
    }
  }

  List<RefundListElement> refundList = [];
  List<RefundListElement> sheduleList = [];

  Future<void> getReturnPolicy() async {
    try {
      final res = await HttpService()
          .getApi(AppConstants.panditPolicyUrl); // 🔄 Replaced here

      print(res);

      if (res != null) {
        final refundData = ReturnPolicyModel.fromJson(res);
        setState(() {
          refundList = refundData.refundList;
          sheduleList = refundData.scheduleList;
        });
      }
    } catch (e) {
      print("Return Policy error: $e");
    }
  }

  void _showItineraryBottomsheet() {
    bool isRefundTab = true;

    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (context) {
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter modalSetter) {
            return SizedBox(
              height: MediaQuery.of(context).size.height,
              child: Padding(
                padding: MediaQuery.of(context).viewInsets,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      children: [
                        const SizedBox(
                          height: 30,
                        ),
                        Row(
                          children: [
                            IconButton(
                                onPressed: () => Navigator.pop(context),
                                icon: const Icon(
                                  CupertinoIcons.chevron_back,
                                  color: Colors.red,
                                )),
                            const SizedBox(
                              width: 15,
                            ),
                            Text(translateEn == "en" ? "Back" : "वापस"),
                            const Spacer(),
                          ],
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        SingleChildScrollView(
                          child: Column(
                            children: [
                              // Text(
                              //   "Return Policy Details",
                              //   style: TextStyle(
                              //       color: Color.fromRGBO(176, 176, 176, 1),
                              //       fontSize: 15,
                              //       fontWeight: FontWeight.w500,
                              //       fontFamily: 'Roboto'),
                              // ),

                              const SizedBox(height: 10),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      modalSetter(() {
                                        isRefundTab = true;
                                      });
                                    },
                                    child: Column(
                                      children: [
                                        Text(
                                            translateEn == "en"
                                                ? "Refund Policy"
                                                : "रिफंड पालिसी",
                                            style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold)),
                                        if (isRefundTab)
                                          Container(
                                              height: 2,
                                              width: 80,
                                              color: Colors.red),
                                      ],
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      modalSetter(() {
                                        isRefundTab = false;
                                      });
                                    },
                                    child: Column(
                                      children: [
                                        Text(
                                            translateEn == "en"
                                                ? "Re-Schedule Policy"
                                                : "पुनर्निर्धारण पालिसी",
                                            style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold)),
                                        if (!isRefundTab)
                                          Container(
                                              height: 2,
                                              width: 80,
                                              color: Colors.red),
                                      ],
                                    ),
                                  ),
                                ],
                              ),

                              Divider(
                                color: Colors.grey.shade300,
                              ),
                              isRefundTab
                                  ? ListView.builder(
                                      itemCount: refundList.length,
                                      shrinkWrap: true,
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      itemBuilder: (context, index) {
                                        final item = refundList[index];
                                        return Card(
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          elevation: 3,
                                          margin: const EdgeInsets.symmetric(
                                              vertical: 8, horizontal: 4),
                                          child: ListTile(
                                            contentPadding:
                                                const EdgeInsets.all(10),
                                            leading: CircleAvatar(
                                              backgroundColor: item.percent == 0
                                                  ? Colors.red
                                                  : Colors.orange,
                                              child: Text(
                                                "${item.percent}%",
                                                style: const TextStyle(
                                                    color: Colors.white,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            ),
                                            title: Text(
                                                "${item.days} ${translateEn == "en" ? "Days Before" : "दिन पहले"}"),
                                            subtitle: Text(translateEn == "en"
                                                ? item.enMessage ?? ''
                                                : item.hiMessage ?? ''),
                                          ),
                                        );
                                      },
                                    )
                                  : ListView.builder(
                                      itemCount: sheduleList.length,
                                      shrinkWrap: true,
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      itemBuilder: (context, index) {
                                        final item = sheduleList[index];
                                        return Card(
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          elevation: 3,
                                          margin: const EdgeInsets.symmetric(
                                              vertical: 8, horizontal: 4),
                                          child: ListTile(
                                            contentPadding:
                                                const EdgeInsets.all(10),
                                            leading: CircleAvatar(
                                              backgroundColor: item.percent == 0
                                                  ? Colors.red
                                                  : Colors.orange,
                                              child: Text(
                                                "${item.percent}%",
                                                style: const TextStyle(
                                                    color: Colors.white,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            ),
                                            title: Text(
                                                "${item.days} ${translateEn == "en" ? "Days Before" : "दिन पहले"}"),
                                            subtitle: Text(translateEn == "en"
                                                ? item.enMessage ?? ''
                                                : item.hiMessage ?? ''),
                                          ),
                                        );
                                      },
                                    ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            );
          });
        });
  }

  // void getDetailsData() async {
  //   try {
  //     var res = await HttpService().getApi(AppConstants.poojaSingleDetailUrl + widget.slugName);
  //     if (res["status"] == 200) {
  //
  //     } else {
  //       print("Error: Status is not 200, status: ${res["status"]}");
  //     }
  //   } catch (e) {
  //     print("Error: $e");
  //   }
  // }

  // void startCountdown() {
  //   Timer.periodic(Duration(seconds: 1), (timer) {
  //     DateTime now = DateTime.now();
  //     DateTime targetDate = DateTime.parse(widget.nextDatePooja);
  //     DateTime previousDate = targetDate.subtract(Duration(days: 1));
  //     countdownDuration = previousDate.difference(now);
  //
  //     if (countdownDuration <= Duration.zero) {
  //       // Countdown reached zero, set the next target date
  //       updateNextPoojaDate();
  //     } else {
  //       setState(() {
  //         // Update the UI to show the remaining time
  //       });
  //       // print("Countdown: ${countdownDuration.inHours % 24} Hours, ${countdownDuration.inMinutes % 60} Minutes, ${countdownDuration.inSeconds % 60} Seconds");
  //     }
  //   });
  // }
  //
  // void updateNextPoojaDate() {
  //   setState(() {
  //     DateTime nextDate = DateTime.parse(widget.nextDatePooja).add(Duration(days: 7));
  //     widget.nextDatePooja = nextDate.toIso8601String(); // Update the string with the new date
  //   });
  // }
  //
  // String formatDuration(Duration duration) {
  //   return '${duration.inHours}:${duration.inMinutes.remainder(60)}:${duration.inSeconds.remainder(60)}';
  // }

  // List<String> imagePaths = [
  //   "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSUToy14Ex7F4of_WK0Zr_5Fks_IKhzrICCHQ&s",
  //   "https://i.pinimg.com/736x/56/de/95/56de95bb1f6ede91b69acdd3ae5072c5.jpg",
  //   "https://1.bp.blogspot.com/-D93XGu464NM0uYOd_AgB2pPjKOnaQN0hnlGxgVu17DEG1jplL7WqBaeqVML8v3FP0MEJwDSDEJGn5-CSyA",
  //   "https://pbs.twimg.com/media/FBWq0BIVIAIVpr3.jpg",
  //   "https://i.pinimg.com/originals/43/a5/b0/43a5b0ea0253b4af61e3d21608b26884.jpg",
  //   "https://static.wixstatic.com/media/436168_5bcfe5cd6cc24a1cb5dcbd5ae658910a~mv2.jpg/v1/fill/w_560,h_372,al_c,q_80,usm_0.66_1.00_0.01,enc_auto/ujjain-mahakaleshwar-temple.jpg"
  // ];

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

  // double averageRating = 0.0;
  // List<Offlinereview> reviewModelList = <Offlinereview>[];
  // void getReviewData(String id) async {
  //   print("id of url $id");
  //   var res = await HttpService()
  //       .getApi("/api/v1/offlinepooja/getreviews?serviceId=$id");
  //   if (res["status"]) {
  //     setState(() {
  //       reviewModelList.clear();
  //       List reviewList = res["review"];
  //       reviewModelList
  //           .addAll(reviewList.map((e) => Offlinereview.fromJson(e)));
  //       // Get the highest rating
  //       if (reviewModelList.isNotEmpty) {
  //         double totalRating = reviewModelList
  //             .map((e) => e.rating)
  //             .reduce((a, b) => a + b)
  //             .toDouble();
  //         averageRating = totalRating / reviewModelList.length;
  //       } else {
  //         averageRating = 0.0;
  //       }
  //     });
  //     print("all print review lenght ${reviewModelList.length} $averageRating");
  //   }
  // }

  String formatDateString(String dateString) {
    // Parse the input date string to a DateTime object
    DateTime parsedDate = DateTime.parse(dateString);

    // Format the DateTime object into the desired format
    String formattedDate = DateFormat('dd-MMMM-yyyy').format(parsedDate);

    return formattedDate;
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
      color: Colors.orange,
      onRefresh: () async {
        getDetailsData();
      },
      child: enName.isEmpty
          ? MahakalLoadingData(onReload: () {})
          : Scaffold(
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
                      height: 260,
                      width: double.infinity,
                      child: Image.network(
                        thumbnail,
                        fit: BoxFit.fill,
                      ),
                    ),

                    SingleChildScrollView(
                      controller: scrollController,
                      child: Stack(
                        children: [
                          Container(
                            decoration: const BoxDecoration(
                              borderRadius: BorderRadius.vertical(
                                top: Radius.circular(15),
                              ),
                              color: Colors.white,
                            ),
                            margin: const EdgeInsets.only(
                              top: 260,
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            flex: 1,
                                            child: Text(
                                              translateEn == "en"
                                                  ? enName
                                                  : hiName,
                                              style: const TextStyle(
                                                  color: Colors.orange,
                                                  fontSize: 22,
                                                  fontFamily: 'Roboto',
                                                  fontWeight: FontWeight.bold,
                                                  overflow:
                                                      TextOverflow.ellipsis),
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
                                                        BorderRadius.circular(
                                                            4.0),
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
                                      Html(
                                          data: translateEn == "en"
                                              ? enTempleDetails
                                              : hiTempleDetails),
                                      const SizedBox(
                                        height: 10,
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
                                                        fontWeight:
                                                            FontWeight.bold,
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
                                                        fontWeight:
                                                            FontWeight.bold,
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
                                                        fontWeight:
                                                            FontWeight.bold,
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
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      InkWell(
                                        onTap: _showItineraryBottomsheet,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 13, horizontal: 16),
                                          margin: const EdgeInsets.symmetric(
                                              vertical: 8, horizontal: 0),
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: [
                                                Colors.orange.shade100,
                                                Colors.orange.shade50
                                              ],
                                              begin: Alignment.topLeft,
                                              end: Alignment.bottomRight,
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(15),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.orange.shade100
                                                    .withOpacity(0.6),
                                                spreadRadius: 2,
                                                blurRadius: 6,
                                                offset: const Offset(0, 3),
                                              ),
                                            ],
                                          ),
                                          child: Row(
                                            children: [
                                              const Icon(Icons.policy,
                                                  color: Colors.deepOrange,
                                                  size: 24),
                                              const SizedBox(width: 10),
                                              Text(
                                                translateEn == "en"
                                                    ? "Policies"
                                                    : "नीतियाँ",
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.deepOrange,
                                                  fontSize: 20,
                                                ),
                                              ),
                                              const Spacer(),
                                              InkWell(
                                                onTap:
                                                    _showItineraryBottomsheet,
                                                child: Row(
                                                  children: [
                                                    Text(
                                                      translateEn == "en"
                                                          ? "View All"
                                                          : "सभी देखें",
                                                      style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        color: Colors.blue,
                                                        fontSize: 16,
                                                      ),
                                                    ),
                                                    const SizedBox(width: 4),
                                                    const Icon(
                                                        Icons.arrow_forward_ios,
                                                        size: 14,
                                                        color: Colors.blue),
                                                  ],
                                                ),
                                              )
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Divider(
                                  color: Colors.grey.shade400,
                                ),

                                // About Package
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

                                // Short Benefit
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

                                // Process
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

                                // Terms and Condition
                                Container(
                                  key: fourKey,
                                  child: Column(
                                    children: [
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      Html(
                                          data: translateEn == "en"
                                              ? entermsAndConditiion
                                              : hitermsAndConditiion),
                                    ],
                                  ),
                                ),
                                _dividerLine(),

                                // Package
                                Container(
                                  key: fiveKey,
                                  child: Column(
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            margin:
                                                const EdgeInsets.only(left: 10),
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
                                          enableInfiniteScroll:
                                              package.length > 1,
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
                                        itemBuilder:
                                            (context, index, realIndex) {
                                          String payableAmount = (double.parse(
                                                      package[index]
                                                          .packagePrice
                                                          .toString()) *
                                                  (double.parse(package[index]
                                                          .packagePercent
                                                          .toString()) /
                                                      100))
                                              .toInt()
                                              .toString();

                                          // double payableAmount = double.parse(package[index].packagePrice.toString()) *
                                          //     (double.parse(package[index].packagePercent.toString()) / 100);

                                          final packageItem = package[index];
                                          final primaryColor =
                                              hexToColor(packageItem.color);
                                          final isEnglish = translateEn == "en";
                                          final ScrollController
                                              scrollController =
                                              ScrollController();
                                          return AnimatedScale(
                                            duration: const Duration(
                                                milliseconds: 300),
                                            scale: 1.0,
                                            child: GestureDetector(
                                              onTap: () {
                                                if (!isNext) {
                                                  setState(() => isNext = true);
                                                  getLeadGanerate(
                                                      package[index].packageId,
                                                      package[index]
                                                          .packagePrice,
                                                      payableAmount,
                                                      index);
                                                }
                                                // isNext ? getLeadGanerate(
                                                //     package[index].packageId,
                                                //     package[index].packagePrice,
                                                //     payableAmount,
                                                //     index
                                                // ): null;
                                                // setState(() {
                                                //   isNext = false;
                                                // });
                                              },
                                              child: Container(
                                                margin:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 0,
                                                        vertical: 8),
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
                                                      offset:
                                                          const Offset(0, 4),
                                                    ),
                                                  ],
                                                ),
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment
                                                          .stretch,
                                                  children: [
                                                    // Package Price Ribbon with improved visual hierarchy
                                                    Container(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          vertical: 12),
                                                      decoration: BoxDecoration(
                                                        gradient:
                                                            LinearGradient(
                                                          begin:
                                                              Alignment.topLeft,
                                                          end: Alignment
                                                              .bottomRight,
                                                          colors: [
                                                            primaryColor
                                                                .withOpacity(
                                                                    0.15),
                                                            primaryColor
                                                                .withOpacity(
                                                                    0.3),
                                                          ],
                                                        ),
                                                        borderRadius:
                                                            const BorderRadius
                                                                .vertical(
                                                                top: Radius
                                                                    .circular(
                                                                        16)),
                                                      ),
                                                      child: Column(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .center,
                                                        children: [
                                                          Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .center,
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .center,
                                                            children: [
                                                              Text(
                                                                isEnglish
                                                                    ? "Pooja Amount :"
                                                                    : "पूजा राशि :",
                                                                style:
                                                                    TextStyle(
                                                                  fontSize: 16,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  color: primaryColor
                                                                      .withOpacity(
                                                                          0.8),
                                                                ),
                                                              ),
                                                              Text(
                                                                "₹${packageItem.packagePrice}",
                                                                textAlign:
                                                                    TextAlign
                                                                        .center,
                                                                style:
                                                                    GoogleFonts
                                                                        .poppins(
                                                                  fontSize: 18,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w800,
                                                                  color:
                                                                      primaryColor,
                                                                  letterSpacing:
                                                                      0.5,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                          Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .center,
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .center,
                                                            children: [
                                                              Text(
                                                                isEnglish
                                                                    ? "Booking Amount :"
                                                                    : "बुकिंग राशि :",
                                                                style:
                                                                    TextStyle(
                                                                  fontSize: 18,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  color: primaryColor
                                                                      .withOpacity(
                                                                          0.8),
                                                                ),
                                                              ),
                                                              Text(
                                                                "₹$payableAmount",
                                                                textAlign:
                                                                    TextAlign
                                                                        .center,
                                                                style:
                                                                    GoogleFonts
                                                                        .poppins(
                                                                  fontSize: 20,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w800,
                                                                  color:
                                                                      primaryColor,
                                                                  letterSpacing:
                                                                      0.5,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ],
                                                      ),
                                                    ),

                                                    // Package Content with optimized layout
                                                    Expanded(
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(16),
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
                                                                    style: GoogleFonts
                                                                        .poppins(
                                                                      fontSize:
                                                                          18,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w700,
                                                                      color: Colors
                                                                          .black87,
                                                                      height:
                                                                          1.3,
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
                                                                height: 12),

                                                            // Description with optimized rendering
                                                            Expanded(
                                                              child: Scrollbar(
                                                                controller:
                                                                    scrollController,
                                                                thumbVisibility:
                                                                    true,
                                                                radius:
                                                                    const Radius
                                                                        .circular(
                                                                        4),
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
                                                                      "body":
                                                                          Style(
                                                                        fontSize:
                                                                            FontSize(14.0),
                                                                        fontFamily:
                                                                            'Poppins',
                                                                        color: Colors
                                                                            .grey[800],
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
                                                              child:
                                                                  ElevatedButton(
                                                                onPressed: () {
                                                                  if (!isNext) {
                                                                    setState(() =>
                                                                        isNext =
                                                                            true);
                                                                    getLeadGanerate(
                                                                        package[index]
                                                                            .packageId,
                                                                        package[index]
                                                                            .packagePrice,
                                                                        payableAmount,
                                                                        index);
                                                                  }
                                                                },
                                                                style: ElevatedButton
                                                                    .styleFrom(
                                                                  backgroundColor: isNext
                                                                      ? Colors
                                                                          .grey
                                                                          .shade200
                                                                      : primaryColor,
                                                                  shape:
                                                                      RoundedRectangleBorder(
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            12),
                                                                  ),
                                                                  elevation: 0,
                                                                  shadowColor:
                                                                      Colors
                                                                          .transparent,
                                                                  padding: const EdgeInsets
                                                                      .symmetric(
                                                                      vertical:
                                                                          12),
                                                                ),
                                                                child: isNext
                                                                    ? Center(
                                                                        child:
                                                                            SizedBox(
                                                                          height:
                                                                              20,
                                                                          width:
                                                                              20,
                                                                          child:
                                                                              CircularProgressIndicator(
                                                                            strokeWidth:
                                                                                2,
                                                                            color:
                                                                                primaryColor,
                                                                          ),
                                                                        ),
                                                                      )
                                                                    : Row(
                                                                        mainAxisAlignment:
                                                                            MainAxisAlignment.center,
                                                                        children: [
                                                                          Text(
                                                                            isEnglish
                                                                                ? "Book Now"
                                                                                : "बुक करें",
                                                                            style:
                                                                                GoogleFonts.poppins(
                                                                              fontWeight: FontWeight.w600,
                                                                              fontSize: 16,
                                                                              letterSpacing: 0.5,
                                                                              color: Colors.white,
                                                                            ),
                                                                          ),
                                                                          const SizedBox(
                                                                              width: 8),
                                                                          const Icon(
                                                                            Icons.arrow_forward_rounded,
                                                                            size:
                                                                                20,
                                                                            color:
                                                                                Colors.white,
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
                                _dividerLine(),

                                // Review
                                // Container(
                                //   key: sixKey,
                                //   child: Padding(
                                //     padding: const EdgeInsets.all(10.0),
                                //     child: Column(
                                //       crossAxisAlignment:
                                //           CrossAxisAlignment.start,
                                //       children: [
                                //         Row(
                                //           children: [
                                //             Container(
                                //               height: 20,
                                //               width: 3,
                                //               color: Colors.orange,
                                //             ),
                                //             SizedBox(width: screenWidth * 0.03),
                                //             Text(
                                //               translateEn == "en"
                                //                   ? "Reviews"
                                //                   : "रिव्यु",
                                //               style: const TextStyle(
                                //                   fontSize: 16,
                                //                   fontFamily: 'Roboto',
                                //                   fontWeight: FontWeight.w700,
                                //                   color: Colors.black),
                                //             ),
                                //             const Spacer(),
                                //             reviewModelList.isEmpty
                                //                 ? const SizedBox.shrink()
                                //                 : TextButton(
                                //                     onPressed: () {
                                //                       showModalBottomSheet(
                                //                           context: context,
                                //                           isScrollControlled:
                                //                               true,
                                //                           builder: (context) {
                                //                             return StatefulBuilder(
                                //                                 builder: (BuildContext
                                //                                         context,
                                //                                     StateSetter
                                //                                         modalSetter) {
                                //                               return SizedBox(
                                //                                 height: MediaQuery.of(
                                //                                         context)
                                //                                     .size
                                //                                     .height,
                                //                                 child: Padding(
                                //                                   padding: MediaQuery.of(
                                //                                           context)
                                //                                       .viewInsets,
                                //                                   child:
                                //                                       Padding(
                                //                                     padding:
                                //                                         const EdgeInsets
                                //                                             .all(
                                //                                             16.0),
                                //                                     child:
                                //                                         SingleChildScrollView(
                                //                                       physics:
                                //                                           const BouncingScrollPhysics(),
                                //                                       child:
                                //                                           Column(
                                //                                         children: [
                                //                                           const SizedBox(
                                //                                             height:
                                //                                                 30,
                                //                                           ),
                                //                                           Row(
                                //                                             children: [
                                //                                               IconButton(
                                //                                                   onPressed: () => Navigator.pop(context),
                                //                                                   icon: const Icon(
                                //                                                     CupertinoIcons.chevron_back,
                                //                                                     color: Colors.red,
                                //                                                   )),
                                //                                               const SizedBox(
                                //                                                 width: 15,
                                //                                               ),
                                //                                               const Text("Read All Reviews"),
                                //                                               const Spacer(),
                                //                                             ],
                                //                                           ),
                                //                                           const SizedBox(
                                //                                             height:
                                //                                                 30,
                                //                                           ),
                                //                                           SingleChildScrollView(
                                //                                             child:
                                //                                                 Column(
                                //                                               children: [
                                //                                                 Text(
                                //                                                   "Based on ${reviewModelList.length} Reviews",
                                //                                                   style: const TextStyle(color: Color.fromRGBO(176, 176, 176, 1), fontSize: 15, fontWeight: FontWeight.w500, fontFamily: 'Roboto'),
                                //                                                 ),
                                //                                                 Divider(
                                //                                                   color: Colors.grey.shade300,
                                //                                                 ),
                                //                                                 ListView.builder(
                                //                                                   physics: const BouncingScrollPhysics(),
                                //                                                   scrollDirection: Axis.vertical,
                                //                                                   shrinkWrap: true,
                                //                                                   itemCount: reviewModelList.length,
                                //                                                   itemBuilder: (context, index) {
                                //                                                     final review = reviewModelList[index];
                                //                                                     final userImage = review.userData?.image;
                                //                                                     final userName = review.userData?.name ?? "Guest";
                                //
                                //                                                     return Container(
                                //                                                       width: double.infinity,
                                //                                                       margin: const EdgeInsets.only(top: 8),
                                //                                                       padding: const EdgeInsets.all(16),
                                //                                                       decoration: BoxDecoration(
                                //                                                         color: Colors.white,
                                //                                                         borderRadius: BorderRadius.circular(12),
                                //                                                         boxShadow: [
                                //                                                           BoxShadow(
                                //                                                             color: Colors.grey.withOpacity(0.1),
                                //                                                             blurRadius: 10,
                                //                                                             spreadRadius: 2,
                                //                                                             offset: const Offset(0, 4),
                                //                                                           ),
                                //                                                         ],
                                //                                                       ),
                                //                                                       child: Column(
                                //                                                         crossAxisAlignment: CrossAxisAlignment.start,
                                //                                                         children: [
                                //                                                           // User Info Row
                                //                                                           Row(
                                //                                                             children: [
                                //                                                               Container(
                                //                                                                 height: 50,
                                //                                                                 width: 50,
                                //                                                                 decoration: BoxDecoration(
                                //                                                                   shape: BoxShape.circle,
                                //                                                                   border: Border.all(color: Colors.grey.shade200, width: 1),
                                //                                                                 ),
                                //                                                                 child: ClipRRect(
                                //                                                                   borderRadius: BorderRadius.circular(100.0),
                                //                                                                   child: userImage != null && userImage.isNotEmpty
                                //                                                                       ? CachedNetworkImage(
                                //                                                                           imageUrl: userImage,
                                //                                                                           fit: BoxFit.cover,
                                //                                                                           placeholder: (context, url) => Container(
                                //                                                                             color: Colors.grey.shade100,
                                //                                                                             child: Icon(Icons.person, color: Colors.grey.shade400),
                                //                                                                           ),
                                //                                                                           errorWidget: (context, url, error) => Container(
                                //                                                                             color: Colors.grey.shade100,
                                //                                                                             child: Icon(Icons.person, color: Colors.grey.shade400),
                                //                                                                           ),
                                //                                                                         )
                                //                                                                       : Icon(Icons.person, size: 30, color: Colors.grey.shade400),
                                //                                                                 ),
                                //                                                               ),
                                //                                                               const SizedBox(width: 12),
                                //                                                               Column(
                                //                                                                 crossAxisAlignment: CrossAxisAlignment.start,
                                //                                                                 children: [
                                //                                                                   Text(
                                //                                                                     userName,
                                //                                                                     style: const TextStyle(
                                //                                                                       fontSize: 16,
                                //                                                                       fontWeight: FontWeight.w600,
                                //                                                                       color: Colors.black87,
                                //                                                                     ),
                                //                                                                   ),
                                //                                                                   const SizedBox(height: 4),
                                //                                                                   Text(
                                //                                                                     formatDateString("${review.createdAt}"),
                                //                                                                     style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                                //                                                                   ),
                                //                                                                 ],
                                //                                                               ),
                                //                                                             ],
                                //                                                           ),
                                //
                                //                                                           const SizedBox(height: 12),
                                //
                                //                                                           // Rating Row
                                //                                                           Row(
                                //                                                             children: [
                                //                                                               Row(
                                //                                                                 mainAxisSize: MainAxisSize.min,
                                //                                                                 children: List.generate(
                                //                                                                   5,
                                //                                                                   (starIndex) => Icon(
                                //                                                                     Icons.star,
                                //                                                                     color: starIndex < (review.rating ?? 0) ? Colors.amber : Colors.grey.shade300,
                                //                                                                     size: 20,
                                //                                                                   ),
                                //                                                                 ),
                                //                                                               ),
                                //                                                               const SizedBox(width: 8),
                                //                                                               Text(
                                //                                                                 "${review.rating ?? 0}.0",
                                //                                                                 style: TextStyle(
                                //                                                                   fontSize: 14,
                                //                                                                   fontWeight: FontWeight.w500,
                                //                                                                   color: Colors.grey.shade700,
                                //                                                                 ),
                                //                                                               ),
                                //                                                             ],
                                //                                                           ),
                                //
                                //                                                           const SizedBox(height: 12),
                                //                                                           Divider(height: 1, color: Colors.grey.shade200),
                                //                                                           const SizedBox(height: 12),
                                //
                                //                                                           // Review Text (no Expanded here)
                                //                                                           Text(
                                //                                                             review.comment ?? 'No review text provided',
                                //                                                             style: TextStyle(
                                //                                                               fontSize: 15,
                                //                                                               color: Colors.grey.shade800,
                                //                                                               height: 1.4,
                                //                                                             ),
                                //                                                             maxLines: 4,
                                //                                                             overflow: TextOverflow.ellipsis,
                                //                                                           ),
                                //                                                         ],
                                //                                                       ),
                                //                                                     );
                                //                                                   },
                                //                                                 ),
                                //                                               ],
                                //                                             ),
                                //                                           )
                                //                                         ],
                                //                                       ),
                                //                                     ),
                                //                                   ),
                                //                                 ),
                                //                               );
                                //                             });
                                //                           });
                                //                     },
                                //                     child: const Text(
                                //                       "See All",
                                //                       style: TextStyle(
                                //                         fontWeight:
                                //                             FontWeight.w500,
                                //                         color: Colors.orange,
                                //                         fontSize: 15,
                                //                       ),
                                //                     ))
                                //           ],
                                //         ),
                                //         Row(
                                //           children: [
                                //             Text.rich(
                                //               TextSpan(
                                //                 children: [
                                //                   TextSpan(
                                //                       text: averageRating
                                //                           .toStringAsFixed(1),
                                //                       style: const TextStyle(
                                //                           fontWeight:
                                //                               FontWeight.w700,
                                //                           fontSize: 35,
                                //                           fontFamily: 'Roboto',
                                //                           color: Color.fromRGBO(
                                //                               0, 0, 0, 1))),
                                //                   const TextSpan(
                                //                     text: '/',
                                //                     style: TextStyle(
                                //                         fontWeight:
                                //                             FontWeight.w700,
                                //                         fontSize: 20,
                                //                         color: Color.fromRGBO(
                                //                             0, 0, 0, 1)),
                                //                   ),
                                //                   const TextSpan(
                                //                       text: ' 5',
                                //                       style: TextStyle(
                                //                           color: Color.fromRGBO(
                                //                               176, 176, 176, 1),
                                //                           fontSize: 20)),
                                //                 ],
                                //               ),
                                //             ),
                                //
                                //             Row(
                                //               mainAxisSize: MainAxisSize.min,
                                //               children: List.generate(
                                //                 5,
                                //                 (index) => Icon(
                                //                   Icons.star,
                                //                   color: index < averageRating
                                //                       ? Colors.amber
                                //                       : Colors.grey,
                                //                   size: 25,
                                //                 ),
                                //               ),
                                //             ),
                                //             // RatingBar.builder(
                                //             //   initialRating: averageRating,
                                //             //   minRating: 1,
                                //             //   direction: Axis.horizontal,
                                //             //   allowHalfRating: true,
                                //             //   itemCount: 5,
                                //             //   maxRating: 5,
                                //             //   itemPadding: EdgeInsets.symmetric(horizontal: screenWidth * 0.01),
                                //             //   itemBuilder: (context, _) => Icon(
                                //             //     Icons.star,
                                //             //     color: Colors.amber,
                                //             //   ),
                                //             //   onRatingUpdate: (value) {
                                //             //     setState(() {
                                //             //       averageRating = value;
                                //             //     });
                                //             //   },
                                //             // ),
                                //           ],
                                //         ),
                                //         Text(
                                //           "Based on ${reviewModelList.length} Reviews",
                                //           style: const TextStyle(
                                //               color: Color.fromRGBO(
                                //                   176, 176, 176, 1),
                                //               fontSize: 15,
                                //               fontWeight: FontWeight.w500,
                                //               fontFamily: 'Roboto'),
                                //         ),
                                //         const SizedBox(
                                //           height: 8,
                                //         ),
                                //         reviewModelList.isEmpty
                                //             ? const SizedBox.shrink()
                                //             : SizedBox(
                                //                 height: 200,
                                //                 child: ListView.builder(
                                //                   physics:
                                //                       const BouncingScrollPhysics(),
                                //                   scrollDirection:
                                //                       Axis.horizontal,
                                //                   shrinkWrap: true,
                                //                   itemCount:
                                //                       reviewModelList.length,
                                //                   itemBuilder:
                                //                       (context, index) {
                                //                     final review =
                                //                         reviewModelList[index];
                                //                     final userImage =
                                //                         review.userData?.image;
                                //                     final userName =
                                //                         review.userData?.name ??
                                //                             "Guest";
                                //
                                //                     return Container(
                                //                       width: 370,
                                //                       margin:
                                //                           const EdgeInsets.only(
                                //                               right: 16,
                                //                               top: 8,
                                //                               bottom: 8),
                                //                       padding:
                                //                           const EdgeInsets.all(
                                //                               16),
                                //                       decoration: BoxDecoration(
                                //                         color: Colors.white,
                                //                         borderRadius:
                                //                             BorderRadius
                                //                                 .circular(12),
                                //                         boxShadow: [
                                //                           BoxShadow(
                                //                             color: Colors.grey
                                //                                 .withOpacity(
                                //                                     0.1),
                                //                             blurRadius: 10,
                                //                             spreadRadius: 2,
                                //                             offset:
                                //                                 const Offset(
                                //                                     0, 4),
                                //                           ),
                                //                         ],
                                //                       ),
                                //                       child: Column(
                                //                         crossAxisAlignment:
                                //                             CrossAxisAlignment
                                //                                 .start,
                                //                         children: [
                                //                           // User Info Row
                                //                           Row(
                                //                             children: [
                                //                               Container(
                                //                                 height: 50,
                                //                                 width: 50,
                                //                                 decoration:
                                //                                     BoxDecoration(
                                //                                   shape: BoxShape
                                //                                       .circle,
                                //                                   border: Border.all(
                                //                                       color: Colors
                                //                                           .grey
                                //                                           .shade200,
                                //                                       width: 1),
                                //                                 ),
                                //                                 child:
                                //                                     ClipRRect(
                                //                                   borderRadius:
                                //                                       BorderRadius
                                //                                           .circular(
                                //                                               100.0),
                                //                                   child: userImage !=
                                //                                               null &&
                                //                                           userImage
                                //                                               .isNotEmpty
                                //                                       ? CachedNetworkImage(
                                //                                           imageUrl:
                                //                                               userImage,
                                //                                           fit: BoxFit
                                //                                               .cover,
                                //                                           placeholder: (context, url) =>
                                //                                               Container(
                                //                                             color:
                                //                                                 Colors.grey.shade100,
                                //                                             child:
                                //                                                 Icon(Icons.person, color: Colors.grey.shade400),
                                //                                           ),
                                //                                           errorWidget: (context, url, error) =>
                                //                                               Container(
                                //                                             color:
                                //                                                 Colors.grey.shade100,
                                //                                             child:
                                //                                                 Icon(Icons.person, color: Colors.grey.shade400),
                                //                                           ),
                                //                                         )
                                //                                       : Icon(
                                //                                           Icons
                                //                                               .person,
                                //                                           size:
                                //                                               30,
                                //                                           color: Colors
                                //                                               .grey
                                //                                               .shade400),
                                //                                 ),
                                //                               ),
                                //                               const SizedBox(
                                //                                   width: 12),
                                //                               Column(
                                //                                 crossAxisAlignment:
                                //                                     CrossAxisAlignment
                                //                                         .start,
                                //                                 children: [
                                //                                   Text(
                                //                                     userName,
                                //                                     style: const TextStyle(
                                //                                         fontSize:
                                //                                             16,
                                //                                         fontWeight:
                                //                                             FontWeight
                                //                                                 .w600,
                                //                                         color: Colors
                                //                                             .black87),
                                //                                   ),
                                //                                   const SizedBox(
                                //                                       height:
                                //                                           4),
                                //                                   Text(
                                //                                     formatDateString(
                                //                                         "${review.createdAt}"),
                                //                                     style: TextStyle(
                                //                                         fontSize:
                                //                                             12,
                                //                                         color: Colors
                                //                                             .grey
                                //                                             .shade600),
                                //                                   ),
                                //                                 ],
                                //                               ),
                                //                             ],
                                //                           ),
                                //
                                //                           const SizedBox(
                                //                               height: 12),
                                //
                                //                           // Rating Row
                                //                           Row(
                                //                             children: [
                                //                               Row(
                                //                                 mainAxisSize:
                                //                                     MainAxisSize
                                //                                         .min,
                                //                                 children: List
                                //                                     .generate(
                                //                                   5,
                                //                                   (starIndex) =>
                                //                                       Icon(
                                //                                     Icons.star,
                                //                                     color: starIndex <
                                //                                             (review.rating ??
                                //                                                 0)
                                //                                         ? Colors
                                //                                             .amber
                                //                                         : Colors
                                //                                             .grey
                                //                                             .shade300,
                                //                                     size: 20,
                                //                                   ),
                                //                                 ),
                                //                               ),
                                //                               const SizedBox(
                                //                                   width: 8),
                                //                               Text(
                                //                                 "${review.rating ?? 0}.0",
                                //                                 style: TextStyle(
                                //                                     fontSize:
                                //                                         14,
                                //                                     fontWeight:
                                //                                         FontWeight
                                //                                             .w500,
                                //                                     color: Colors
                                //                                         .grey
                                //                                         .shade700),
                                //                               ),
                                //                             ],
                                //                           ),
                                //
                                //                           const SizedBox(
                                //                               height: 12),
                                //                           Divider(
                                //                               height: 1,
                                //                               color: Colors.grey
                                //                                   .shade200),
                                //                           const SizedBox(
                                //                               height: 12),
                                //
                                //                           // Review Text
                                //                           Expanded(
                                //                             child: Text(
                                //                               review.comment ??
                                //                                   'No review text provided',
                                //                               style: TextStyle(
                                //                                 fontSize: 15,
                                //                                 color: Colors
                                //                                     .grey
                                //                                     .shade800,
                                //                                 height: 1.4,
                                //                               ),
                                //                               maxLines: 4,
                                //                               overflow:
                                //                                   TextOverflow
                                //                                       .ellipsis,
                                //                             ),
                                //                           ),
                                //                         ],
                                //                       ),
                                //                     );
                                //                   },
                                //                 ),
                                //               ),
                                //         const SizedBox(
                                //           height: 10,
                                //         ),
                                //       ],
                                //     ),
                                //   ),
                                // ),
                                // _dividerLine(),

                                // FAQ
                                Container(
                                  key: sevenKey,
                                  child: Askquestions(
                                      type: 'Pandit Booking',
                                      translateEn: translateEn),
                                ),
                                const SizedBox(
                                  height: 40,
                                ),
                              ],
                            ),
                          ),
                          Positioned(
                            top: 200,
                            right: 10,
                            child: InkWell(
                              onTap: () {
                                showModalBottomSheet(
                                    context: context,
                                    isScrollControlled: true,
                                    builder: (context) {
                                      return FullScreenImageSlider(
                                        images: [thumbnail],
                                      );
                                    });
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(
                                      12), // Slightly larger radius for smoother corners
                                  border: Border.all(
                                    color: Colors.white.withOpacity(
                                        0.8), // Slightly transparent for softer look
                                    width: 1.5, // Thicker border
                                  ),
                                  gradient: LinearGradient(
                                    // Subtle gradient for depth
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      Colors.white.withOpacity(0.1),
                                      Colors.white.withOpacity(0.05),
                                    ],
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      // Soft shadow for depth
                                      color: Colors.black.withOpacity(0.2),
                                      blurRadius: 6,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: const Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal:
                                        16, // Slightly more horizontal padding
                                    vertical: 8, // More vertical padding
                                  ),
                                  child: Text(
                                    "Gallery",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16, // Slightly larger font
                                      fontWeight:
                                          FontWeight.w500, // Medium weight
                                      letterSpacing:
                                          0.5, // Slight letter spacing for elegance
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
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
                  Text(
                    translateEn == "en" ? "Pooja Details" : "पूजा विवरण",
                    style: const TextStyle(color: Colors.white),
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

OfflineCitiesModal offlineCitiesModalFromJson(String str) =>
    OfflineCitiesModal.fromJson(json.decode(str));

String offlineCitiesModalToJson(OfflineCitiesModal data) =>
    json.encode(data.toJson());

class OfflineCitiesModal {
  List<City> cities;

  OfflineCitiesModal({
    required this.cities,
  });

  factory OfflineCitiesModal.fromJson(Map<String, dynamic> json) =>
      OfflineCitiesModal(
        cities: List<City>.from(json["cities"].map((x) => City.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "cities": List<dynamic>.from(cities.map((x) => x.toJson())),
      };
}

class City {
  int id;
  String name;
  List<dynamic> translations;

  City({
    required this.id,
    required this.name,
    required this.translations,
  });

  factory City.fromJson(Map<String, dynamic> json) => City(
        id: json["id"],
        name: json["name"],
        translations: List<dynamic>.from(json["translations"].map((x) => x)),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "translations": List<dynamic>.from(translations.map((x) => x)),
      };
}
