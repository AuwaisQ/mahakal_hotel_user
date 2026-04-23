import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:avatar_stack/avatar_stack.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:mahakal/features/tour_and_travells/view/tour_packages/special_tour_type.dart';
import 'package:mahakal/features/tour_and_travells/view/tour_packages/usetypethree.dart';
import 'package:mahakal/features/tour_and_travells/view/tour_packages/myfourthtour.dart';
import 'package:mahakal/features/tour_and_travells/view/tour_packages/user_selection_tour.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tdk_bouncingwidget/tdk_bouncingwidget.dart';
import '../../../data/datasource/remote/http/httpClient.dart';
import '../../../utill/app_constants.dart';
import '../../../utill/devotees_count_widget.dart';
import '../../../utill/flutter_toast_helper.dart';
import '../../../utill/full_screen_image_slider.dart';
import '../../../utill/loading_datawidget.dart';
import '../../order/screens/track_screens/invoice_view_screen.dart';
import '../Controller/tour_share_controller.dart';
import '../model/city_details_model.dart';
import '../model/tour_reviews_model.dart';
import '../model/travellers_model.dart';
import '../ui_heliper/scaffold_layout_builder.dart';
import '../widgets/OverAllProductRating.dart';
import '../widgets/PRatingBarIndicater.dart';
import '../widgets/UserReviewCard.dart';
import 'tour_packages/city_tour_type.dart';

class TourDetails extends StatefulWidget {
  final dynamic productId;

  const TourDetails({
    super.key,
    required this.productId,
  });

  @override
  _TourDetailsState createState() => _TourDetailsState();
}

class _TourDetailsState extends State<TourDetails>
    with TickerProviderStateMixin {
  bool isLoading = false; // Loading state
  bool _isLoading = false;
  bool _isReveiwLoading = false;
  final oneKey = GlobalKey();
  final twoKey = GlobalKey();
  final threeKey = GlobalKey();
  final fourKey = GlobalKey();
  final fiveKey = GlobalKey();
  final sixKey = GlobalKey();
  final sevenKey = GlobalKey();
  final eightKey = GlobalKey();
  final nineKey = GlobalKey();

  final shareTour = ShareTourController();
  final ScrollController scrollController = ScrollController();
  double previousOffset = 0.0;
  bool isAppBarVisible = false;
  TabController? _tabController;

  late PageController _pageController;
  late AnimationController _animationController;
  late Animation<double> _opacityAnimation;

  late double greenHeight;
  late double blueHeight;
  late double orangeHeight;
  late double yellowHeight;
  late double blackHeight;
  late double whiteHeight;
  late double redHeight;
  late double purpleHeight;
  late double brownHeight;

  int _currentPage = 0;

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
      if (eightKey.currentContext != null) {
        purpleHeight = eightKey.currentContext!.size!.height;
      }
      if (nineKey.currentContext != null) {
        brownHeight = nineKey.currentContext!.size!.height;
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
            _tabController?.animateTo(i);
            break;
          }
        }
      } else if (scrollController.position.userScrollDirection ==
          ScrollDirection.forward) {
        for (int i = 0; i < cumulativeHeights.length; i++) {
          if (offset < cumulativeHeights[i]) {
            _tabController?.animateTo(i);
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

// Declare model and controller
  CityDetailsModel? delhiModal;
  TravellersModel? travellerInfo;
  TourReviewsModel? commentList;

  String enName = "";
  String enAboutDetails = "";
  String enBenefitsDetails = "";
  String enProcessDetails = "";
  String enTempleDetails = "";
  String enVenue = "";
  String hiName = "";
  String hiAboutDetails = "";
  String hiBenefitsDetails = "";
  String hiProcessDetails = "";
  String hiTempleDetails = "";
  String hiVenue = "";

  double _avgRating = 0.0;
  Map<int, int> _starCounts = {
    1: 0,
    2: 0,
    3: 0,
    4: 0,
    5: 0,
  };

  int serviceId = 0;
  String productType = "";
  String thumbnail = "";
  String targetDays = "";
  String translateEn = 'hi';
  String filePath = "";

  bool isTravler = false; // Flag to control the countdown
  bool isCountingDown = true; // Flag to control the countdown
  bool gridList = false;
  bool _visible = true;

  late Duration timeRemaining = Duration.zero;
  late String countdownText;

  late Timer timer;
  late int days;
  late int hours;
  late int minutes;
  late int seconds;

  String dateforTimer = '';
  String dateOneDayEarlier = "";
  String? localFilePath;

  Timer? countdownTimer;
  Timer? sliderTimer;
  Timer? blinkTimer;
  bool isDisposed = false;

  @override
  void initState() {
    super.initState();

    getTravellersInfo();
    fetchTourData();
    fetchComment();

    print("My tour slug:${widget.productId}");

    _tabController = TabController(length: 9, vsync: this);
    _pageController = PageController(initialPage: _currentPage);

    // 🔥 Auto Scroll Slider Timer (Safe)
    sliderTimer = Timer.periodic(const Duration(seconds: 2), (_) {
      if (!mounted || isDisposed) return;
      if (delhiModal == null || delhiModal!.data == null) return;
      if (delhiModal!.data!.imageList.isEmpty) return;

      if (_currentPage < delhiModal!.data!.imageList.length - 1) {
        _currentPage++;
      } else {
        _currentPage = 0;
      }

      if (_pageController.hasClients) {
        _pageController.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeIn,
        );
      }
    });

    // 🔥 Blinking Animation
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);

    _opacityAnimation = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    // 🔥 Blinking text toggle timer
    blinkTimer = Timer.periodic(const Duration(milliseconds: 500), (_) {
      if (!mounted || isDisposed) return;
      setState(() {
        _visible = !_visible;
      });
    });

    // 🔥 Scroll listener
    scrollController.addListener(() {
      if (!mounted || isDisposed) return;
      handleAppBarVisibility();
      addScrollControllerListener();
    });
  }

  /// UpDate CountDown
  void updateCountdown() {
    print("Date For Timre:$dateOneDayEarlier");
    DateTime myCorrectDate = DateFormat("dd MMM yyyy").parseUtc(dateOneDayEarlier);
    DateTime currentTime = DateTime.now().toUtc();

    timeRemaining = myCorrectDate.difference(currentTime);

    // Calculate the remaining time in days, hours, minutes, and seconds
    if (timeRemaining.isNegative) {
      countdownText = "Event has started!";
      isCountingDown = false; // Stop the countdown
    } else {
      days = timeRemaining.inDays;
      hours = timeRemaining.inHours % 24;
      minutes = timeRemaining.inMinutes % 60;
      seconds = timeRemaining.inSeconds % 60;
      // countdownText = "$days days, $hours hours, $minutes minutes, $seconds seconds";
    }
  }
  void _updateCountdownEverySecond() {
    countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return; // 💯 CRASH PROOF
      if (!isCountingDown) {
        timer.cancel();
        return;
      }

      setState(() {
        updateCountdown();
      });
    });
  }

  /// Fetch Travllers Info
  Future<void> getTravellersInfo() async {
    Map<String, dynamic> data = {"tour_id": widget.productId};

    setState(() {
      _isLoading = true;
    });

    try {
      final res =
          await HttpService().postApi(AppConstants.tourTravellersInfoUrl, data);
      print(res);

      if (res != null && res["status"] == 1) {
        final travellerResponse = TravellersModel.fromJson(res);

        setState(() {
          travellerInfo = travellerResponse;
        });

        print("Traveller Info:${travellerInfo?.data?.enCompanyName}");
      } else {
        print("Traveller info not found or status != 1");
      }
    } catch (e) {
      print("Error fetching traveller info: $e");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// Fetch Comments
  Future<void> fetchComment() async {
    Map<String, dynamic> data = {"tour_id": widget.productId};

    setState(() {
      _isReveiwLoading = true;
    });

    try {
      final res =
          await HttpService().postApi(AppConstants.fetchCommentUrl, data);
      print(res);

      if (res != null && res["status"] == 1) {
        final commentResponse = TourReviewsModel.fromJson(res);

        List<TourReviewList> comments = commentResponse.data ?? [];

        Map<int, int> starCounts = calculateStarCounts(comments);
        double avgRating = calculateAverage(comments);

        setState(() {
          commentList = commentResponse;
          _starCounts = starCounts;
          _avgRating = avgRating;
        });
      } else {
        print("No comments or status != 1");
      }
    } catch (e) {
      print("Error fetching comments: $e");

      setState(() {
        commentList = TourReviewsModel(data: [], tourStar: "", recode: 0);
        _starCounts = {1: 0, 2: 0, 3: 0, 4: 0, 5: 0};
        _avgRating = 0.0;
      });
    } finally {
      setState(() {
        _isReveiwLoading = false;
      });
    }
  }

  Map<int, int> calculateStarCounts(List<TourReviewList> comments) {
    Map<int, int> counts = {1: 0, 2: 0, 3: 0, 4: 0, 5: 0};

    for (var comment in comments) {
      if (counts.containsKey(comment.star)) {
        counts[comment.star!] = counts[comment.star]! + 1;
      }
    }
    return counts;
  }

  double calculateAverage(List<TourReviewList> comments) {
    if (comments.isEmpty) return 0.0;

    int totalStars = comments.fold(0, (sum, item) => sum + item.star!);
    return totalStars / comments.length;
  }

  Map<String, List<PackageList>> filterPackagesByType(List<PackageList> packageList) {
    List<PackageList> hotelList =
        packageList.where((package) => package.type == "hotel").toList();
    List<PackageList> foodList =
        packageList.where((package) => package.type == "foods").toList();
    return {
      "hotels": hotelList,
      "foods": foodList,
    };
  }

  List<bool> isExpandedList = [];
  List<PackageList> foodList = [];
  List<PackageList> hotelList = [];

  void _showItineraryBottomsheet() {
    List<int> currentImageIndex = [];
    Timer? imageTimer;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter modalSetter) {
            var itineraryList = delhiModal?.data?.itineraryPlace ?? [];

            // Ensure isExpandedList is initialized
            if (isExpandedList.isEmpty ||
                isExpandedList.length != itineraryList.length) {
              isExpandedList = List.filled(itineraryList.length, false);
            }

            // Initialize image index
            if (currentImageIndex.isEmpty) {
              currentImageIndex = List.filled(itineraryList.length, 0);
            }

            // Function to start image slideshow
            void startImageSlideshow() {
              imageTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
                if (!context.mounted) {
                  timer.cancel();
                  return;
                }
                modalSetter(() {
                  for (int i = 0; i < itineraryList.length; i++) {
                    var place = itineraryList[i];
                    if (place.image.isNotEmpty) {
                      currentImageIndex[i] =
                          (currentImageIndex[i] + 1) % place.image.length;
                    }
                  }
                });
              });
            }

            if (imageTimer == null) startImageSlideshow();

            return SizedBox(
              height: MediaQuery.of(context).size.height,
              child: Stack(
                children: [
                  /// Scrollable content
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        children: [
                          const SizedBox(height: 30),
                          Row(
                            children: [
                              IconButton(
                                onPressed: () {
                                  imageTimer?.cancel();
                                  Navigator.pop(context);
                                },
                                icon: const Icon(
                                  CupertinoIcons.chevron_back,
                                  color: Colors.red,
                                ),
                              ),
                              const SizedBox(width: 15),
                              const Text("Back"),
                              const Spacer(),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 15),
                            child: Row(
                              children: [
                                Expanded(
                                  flex: 1,
                                  child: Text(
                                    translateEn == "en"
                                        ? delhiModal?.data?.enTourName ?? ""
                                        : delhiModal?.data?.hiTourName ?? "",
                                    style: const TextStyle(
                                      color: Colors.blue,
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    maxLines: 1,
                                  ),
                                ),
                                if (delhiModal!.data!.itineraryUpload != "")
                                  Expanded(
                                  flex: 0,
                                  child: GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        CupertinoPageRoute(
                                          builder: (context) => InvoiceViewer(
                                              pdfPath: filePath ?? '',
                                              invoiceUrl: delhiModal!
                                                  .data!.itineraryUpload,
                                              typeText: 'View Itinerary',
                                              tourLink:
                                                  "${delhiModal!.data!.shareLink}",
                                              isTour: true,
                                              tourId: widget.productId,
                                              hotelList: hotelList,
                                              foodList: foodList,
                                              translateEn: translateEn,
                                              delhiModal: delhiModal),
                                        ),
                                      );
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.blue.withOpacity(0.3),
                                            blurRadius: 8,
                                            offset: const Offset(2, 4),
                                          ),
                                        ],
                                      ),
                                      child: Icon(
                                        Icons.picture_as_pdf_rounded,
                                        color: Colors.blue,
                                        size: 28,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Divider(color: Colors.grey.shade300),

                          /// Itinerary List
                          ListView.builder(
                            padding: const EdgeInsets.all(5),
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: itineraryList.length,
                            itemBuilder: (context, index) {
                              var place = itineraryList[index];
                              bool hasImages = place.image.isNotEmpty;

                              return Card(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                elevation: 4,
                                margin: const EdgeInsets.only(bottom: 20),
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // Image slideshow
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(5),
                                        child: hasImages
                                            ? Image.network(
                                                place.image[
                                                    currentImageIndex[index]],
                                                height: 210,
                                                width: double.infinity,
                                                fit: BoxFit.fill,
                                                errorBuilder: (context, error,
                                                        stackTrace) =>
                                                    Container(
                                                  height: 210,
                                                  width: double.infinity,
                                                  color: Colors.grey[300],
                                                  child: const Center(
                                                    child: Text(
                                                        "Image not available"),
                                                  ),
                                                ),
                                              )
                                            : Container(
                                                height: 110,
                                                width: double.infinity,
                                                color: Colors.grey[300],
                                                child: const Center(
                                                    child: Text("No Images")),
                                              ),
                                      ),
                                      const SizedBox(height: 10),

                                      // Name & Time
                                      Text(
                                        translateEn == "en"
                                            ? place.enName ?? ""
                                            : place.hiName ?? "",
                                        style: const TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black87,
                                        ),
                                      ),
                                      const SizedBox(height: 5),
                                      Text(
                                        translateEn == "en"
                                            ? place.enTime ?? ""
                                            : place.hiTime ?? "",
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.blueGrey,
                                        ),
                                      ),
                                      const SizedBox(height: 10),

                                      /// View More Button
                                      Row(
                                        children: [
                                          GestureDetector(
                                            onTap: () {
                                              modalSetter(() {
                                                isExpandedList[index] =
                                                    !isExpandedList[index];
                                              });
                                            },
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: [
                                                Text(
                                                  isExpandedList[index]
                                                      ? "View Less"
                                                      : "View More",
                                                  style: const TextStyle(
                                                    fontSize: 15,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.blue,
                                                  ),
                                                ),
                                                Icon(
                                                  isExpandedList[index]
                                                      ? Icons.keyboard_arrow_up
                                                      : Icons
                                                          .keyboard_arrow_down,
                                                  color: Colors.blue,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),

                                      /// Description
                                      if (isExpandedList[index]) ...[
                                        Html(
                                          data: translateEn == "en"
                                              ? place.enDescription ?? ""
                                              : place.hiDescription ?? "",
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                          const SizedBox(
                              height: 100), // space for bottom button
                        ],
                      ),
                    ),
                  ),

                  /// Fixed Book Now button
                  Positioned(
                    left: 12,
                    right: 12,
                    bottom: 20,
                    child: GestureDetector(
                      onTap: () {
                        handleAction("${delhiModal!.data!.useDate ?? ""}");
                        //Navigator.pop(context);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.blue,
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 6,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    translateEn == "en"
                                        ? "BOOK NOW"
                                        : "अभी बुक करें",
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'Roboto',
                                      color: Colors.white,
                                    ),
                                  ),
                                  SizedBox(
                                    width: double.infinity,
                                    child: Text(
                                      translateEn == "en"
                                          ? delhiModal!.data!.enTourName ??
                                              'N/A'
                                          : delhiModal!.data!.hiTourName ??
                                              'N/A',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontFamily: 'Roboto',
                                        color: Colors.white,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(
                              Icons.arrow_forward_ios,
                              color: Colors.white,
                              size: 16,
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    ).whenComplete(() {
      imageTimer?.cancel(); // Stop timer when bottom sheet closes
    });
  }

  void _showReviewsBottomsheet() {
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
                        const SizedBox(height: 30),
                        Row(
                          children: [
                            IconButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              icon: const Icon(
                                CupertinoIcons.chevron_back,
                                color: Colors.red,
                              ),
                            ),
                            const SizedBox(width: 15),
                            const Text("Back"),
                            const Spacer(),
                          ],
                        ),
                        const SizedBox(height: 10),
                        SingleChildScrollView(
                          child: Column(
                            children: [
                              const Text(
                                "Reviews",
                                style: TextStyle(
                                  color: Colors.blue,
                                  fontSize: 22,
                                  fontFamily: 'Roboto',
                                  fontWeight: FontWeight.bold,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                maxLines: 1,
                              ),
                              Divider(color: Colors.grey.shade300),

                              // Show only top 5 comments
                              ...commentList!.data!.map((comment) => Container(
                                  margin: const EdgeInsets.all(5),
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      color: Colors.grey.shade100),
                                  child: UserReviewCard(comment: comment))),

                              // ListView.builder(
                              //   padding: const EdgeInsets.all(2),
                              //   shrinkWrap: true,
                              //   physics: const NeverScrollableScrollPhysics(),
                              //   itemCount: commentList!.data!.length,
                              //   itemBuilder: (context, index) {
                              //     return Container(
                              //       margin: const EdgeInsets.all(5),
                              //       padding: const EdgeInsets.all(10),
                              //       decoration: BoxDecoration(
                              //         color: Colors.grey.shade200,
                              //         borderRadius: BorderRadius.circular(16),
                              //         boxShadow: [
                              //           BoxShadow(
                              //             color: Colors.black.withOpacity(0.05),
                              //             blurRadius: 10,
                              //             spreadRadius: 2,
                              //           ),
                              //         ],
                              //       ),
                              //       child: Column(
                              //         crossAxisAlignment:
                              //             CrossAxisAlignment.start,
                              //         children: [
                              //           // Latest review
                              //           Row(
                              //             crossAxisAlignment:
                              //                 CrossAxisAlignment.start,
                              //             children: [
                              //               // User image
                              //               CircleAvatar(
                              //                 radius: 24,
                              //                 backgroundImage: NetworkImage(
                              //                   commentList!.data![index]
                              //                           .userImage ??
                              //                       '',
                              //                 ),
                              //                 backgroundColor:
                              //                     Colors.grey.shade200,
                              //               ),
                              //               const SizedBox(width: 12),
                              //
                              //               // User info and comment
                              //               Expanded(
                              //                 child: Column(
                              //                   crossAxisAlignment:
                              //                       CrossAxisAlignment.start,
                              //                   children: [
                              //                     // Name and Date
                              //                     Row(
                              //                       mainAxisAlignment:
                              //                           MainAxisAlignment
                              //                               .spaceBetween,
                              //                       children: [
                              //                         Text(
                              //                           commentList!
                              //                                   .data![index]
                              //                                   .userName ??
                              //                               '',
                              //                           style: const TextStyle(
                              //                             fontWeight:
                              //                                 FontWeight.bold,
                              //                             fontSize: 16,
                              //                           ),
                              //                         ),
                              //                         Text(
                              //                           formatDate("${commentList!.data![index].createdAt}"),
                              //                           style: TextStyle(
                              //                             fontSize: 12,
                              //                             color: Colors
                              //                                 .grey.shade600,
                              //                           ),
                              //                         ),
                              //                       ],
                              //                     ),
                              //                     const SizedBox(height: 4),
                              //
                              //                     // Star Rating (per review)
                              //                     RatingBarIndicator(
                              //                       rating: (double.parse(
                              //                           "${commentList!.data![index].star ?? ''}")),
                              //                       itemBuilder:
                              //                           (context, index) =>
                              //                               const Icon(
                              //                         Icons.star,
                              //                         color: Colors.amber,
                              //                       ),
                              //                       itemCount: 5,
                              //                       itemSize: 16.0,
                              //                       direction: Axis.horizontal,
                              //                     ),
                              //                     const SizedBox(height: 8),
                              //
                              //                     // Comment
                              //                     ReadMoreText(
                              //                       "${commentList!.data![index].comment ?? ''}",
                              //                       trimLines: 2,
                              //                       colorClickableText:
                              //                           Colors.blue,
                              //                       trimMode: TrimMode.Line,
                              //                       trimCollapsedText:
                              //                           'Read more',
                              //                       trimExpandedText:
                              //                           'Read less',
                              //                       style: const TextStyle(
                              //                         fontSize: 14,
                              //                         color: Colors.black87,
                              //                       ),
                              //                       moreStyle: const TextStyle(
                              //                         fontSize: 14,
                              //                         fontWeight:
                              //                             FontWeight.bold,
                              //                         color: Colors.blue,
                              //                       ),
                              //                       lessStyle: const TextStyle(
                              //                         fontSize: 14,
                              //                         fontWeight:
                              //                             FontWeight.bold,
                              //                         color: Colors.blue,
                              //                       ),
                              //                     ),
                              //                   ],
                              //                 ),
                              //               ),
                              //             ],
                              //           ),
                              //         ],
                              //       ),
                              //     );
                              //   },
                              // ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  String formatDate(String date) {
    try {
      DateTime parsedDate = DateTime.parse(date);
      return DateFormat("d MMMM yyyy").format(parsedDate); // 1 March 2025
    } catch (e) {
      print("Date Parsing Error: $e");
      return "Invalid Date";
    }
  }

  @override
  void dispose() {
    isDisposed = true;

    sliderTimer?.cancel();
    blinkTimer?.cancel();
    countdownTimer?.cancel(); // 🔥 IMPORTANT — FIXES CRASH

    _animationController.dispose();
    _pageController.dispose();
    scrollController.dispose();

    super.dispose();
  }

  /// Handle Navigation actions(using use Date)
  void handleAction(String value) {
    switch (value) {

      /// City Tour(Per Person Done)   GST Correction Completed
      case "0":
        Navigator.push(
            context,
            CupertinoPageRoute(
              builder: (context) => CityTourType(
                services: delhiModal!.data!.services,
                cabsquantity: delhiModal!.data!.cabList,
                hotelList: hotelList,
                foodList: foodList,
                tourId: widget.productId,
                packageId: delhiModal!.data!.packageList.isNotEmpty
                    ? delhiModal!.data!.packageList[0].packageId
                    : "0",
                translateEn: translateEn,
                timeSlot: delhiModal?.data?.timeSlot,
                exDistance: delhiModal?.data?.exDistance,
                useDate: "${delhiModal?.data?.useDate}",
                isPersonUse: delhiModal!.data!.isPersonUse,
                tourGst: delhiModal?.data?.tourGst,
                transPortGst: delhiModal?.data?.transportGst,
                tourName: translateEn == "en"
                    ? delhiModal!.data!.enTourName
                    : delhiModal!.data!.hiTourName,
                hotelTypeList: delhiModal!.data!.hotelTypeList.isNotEmpty
                    ? delhiModal!.data!.hotelTypeList
                    : [],
                locationName: '${delhiModal?.data?.citiesName}',
              ),
            ));
        break;

      /// Special Tour (Ye Sahi h) GST Calculation Completed (Customize Also) (Weekly Monthly Yearly)
      case "1":
        Navigator.push(
            context,
            CupertinoPageRoute(
              builder: (context) =>
                  SpecialTourType(
                services: delhiModal!.data!.services,
                cabsquantity: delhiModal!.data!.cabList,
                extraTransportPrice: delhiModal?.data!.exTransportPrice ?? [],
                hotelList: hotelList,
                foodList: foodList,
                tourId: widget.productId,
                packageId: delhiModal!.data!.packageList.isNotEmpty
                    ? delhiModal!.data!.packageList[0].packageId
                    : "0",
                translateEn: translateEn,
                    pickTime: delhiModal?.data?.pickupTime ?? '',
                pickLat: delhiModal?.data?.pickupLat ?? '',
                pickLong: delhiModal?.data?.pickupLong ?? '',
                exDistance: delhiModal?.data?.exDistance,
                    packageAmount: delhiModal!.data!.tourPackageTotalPrice ?? 0,
                    useDate: "${delhiModal?.data?.useDate}",
                isPersonUse: delhiModal!.data!.isPersonUse,
                tourGst: delhiModal?.data?.tourGst,
                transPortGst: delhiModal?.data?.transportGst,
                tourName: translateEn == "en"
                    ? delhiModal!.data!.enTourName
                    : delhiModal!.data!.hiTourName,
                hotelTypeList: delhiModal!.data!.hotelTypeList.isNotEmpty
                    ? delhiModal!.data!.hotelTypeList
                    : [],
                locationName: '${delhiModal?.data?.pickupLocation}',
                customizedDates: delhiModal?.data!.customizedDates ?? [],
                customizedType: delhiModal?.data!.customizedType ?? '',
                    tourDate: delhiModal?.data!.date ?? '',
              ),
            ));
        break;

      /// User Selection Tour(Also Done by Per person ) (Pick and Drop also) (Customize Also)
      case "2":
        Navigator.push(
            context,
            CupertinoPageRoute(
              builder: (context) => UseTypeTwo(
                services: delhiModal!.data!.services,
                packageList: delhiModal!.data!.packageList.isNotEmpty
                    ? delhiModal!.data!.packageList
                    : [],
                cabsquantity: delhiModal!.data!.cabList,
                hotelList: hotelList,
                foodList: foodList,
                tourId: widget.productId,
                packageId: delhiModal!.data!.packageList.isNotEmpty
                    ? delhiModal!.data!.packageList[0].packageId
                    : "0",
                translateEn: translateEn,
                timeSlot: delhiModal?.data!.timeSlot,
                exDistance: delhiModal!.data!.exDistance,
                tourName: delhiModal!.data!.enTourName,
                hiTourName: delhiModal!.data!.hiTourName,
                packageAmount: delhiModal!.data!.tourPackageTotalPrice ?? 0,
                locationName: delhiModal!.data!.pickupLocation ?? '',
                pickLong: delhiModal!.data!.pickupLong ?? '',
                pickLat: delhiModal!.data!.pickupLat ?? '',
                useDate: "${delhiModal?.data!.useDate}",
                isPersonUse: delhiModal!.data!.isPersonUse,
                tourGst: delhiModal?.data!.tourGst,
                transPortGst: delhiModal?.data!.transportGst,
                extraTransportPrice: delhiModal?.data!.exTransportPrice ?? [],
                hotelTypeList: delhiModal!.data!.hotelTypeList.isNotEmpty
                    ? delhiModal!.data!.hotelTypeList
                    : [],
              ),
            ));
        break;

      /// My FistTour(This Alos Done there is no per person) (There is Route Type One Way & Two Way Types)
      case "3":
        Navigator.push(
            context,
            CupertinoPageRoute(
              builder: (context) => UseTypeThree(
                services: delhiModal!.data!.services,
                packageList: delhiModal!.data!.packageList.isNotEmpty
                    ? delhiModal!.data!.packageList
                    : [],
                cabsquantity: delhiModal!.data!.cabList,
                hotelList: hotelList,
                foodList: foodList,
                tourId: widget.productId,
                packageId: delhiModal!.data!.packageList.isNotEmpty
                    ? delhiModal!.data!.packageList[0].packageId
                    : "0",
                translateEn: translateEn,
                timeSlot: delhiModal?.data!.timeSlot,
                exDistance: delhiModal!.data!.exDistance,
                tourName: delhiModal?.data!.enTourName ?? '',
                hiTourName: delhiModal!.data!.hiTourName,
                packageAmount: delhiModal!.data!.tourPackageTotalPrice ?? 0,
                useDate: "${delhiModal?.data!.useDate}",
                locationName: "${delhiModal?.data!.pickupLocation}",
                transPortGst: delhiModal?.data!.transportGst,
                tourGst: delhiModal?.data!.tourGst,
              ),
            ));
        break;

      /// GST Calculation Complete
      /// Fourth type Tour(Per person done)(Date and Time User dega , No, of person Increase hoga, Address ayega ) (Pick and Drop also) (Customize Also)
      case "4":
        Navigator.push(
            context,
            CupertinoPageRoute(
              builder: (context) => UseTypeFour(
                services: delhiModal!.data!.services,
                packageList: delhiModal!.data!.packageList,
                cabsquantity: delhiModal!.data!.cabList,
                hotelList: hotelList,
                foodList: foodList,
                tourId: widget.productId,
                packageId: delhiModal!.data!.packageList.isNotEmpty
                    ? delhiModal!.data!.packageList[0].packageId
                    : "0",
                translateEn: translateEn,
                timeSlot: delhiModal?.data!.timeSlot,
                exDistance: delhiModal!.data!.exDistance,
                tourName: delhiModal!.data!.enTourName,
                hiTourName: delhiModal!.data!.hiTourName,
                packageAmount: delhiModal!.data!.tourPackageTotalPrice ?? 0,
                locationName: delhiModal!.data!.pickupLocation ?? '',
                pickLat: delhiModal!.data!.pickupLat ?? '',
                pickLong: delhiModal!.data!.pickupLong ?? '',
                useDate: "${delhiModal?.data!.useDate}",
                isPersonUse: delhiModal!.data!.isPersonUse,
                tourGst: delhiModal?.data!.tourGst,
                transPortGst: delhiModal?.data!.transportGst,
                extraTransportPrice: delhiModal?.data!.exTransportPrice ?? [],
                hotelTypeList: delhiModal!.data!.hotelTypeList.isNotEmpty
                    ? delhiModal!.data!.hotelTypeList
                    : [],
              ),
            ));
        break;
    }
  }

  void _showTravelAgentDetails() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(25),
            topRight: Radius.circular(25),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(25),
                  topRight: Radius.circular(25),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.travel_explore,
                    color: Colors.blue,
                    size: 24,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    translateEn == "en"
                        ? "Travel Agent Details"
                        : "यात्रा एजेंट की पूरी जानकारी",
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: Colors.blue),
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    /// Profile Image with Verified Badge
                    Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        CircleAvatar(
                          radius: 55,
                          backgroundColor: Colors.blue.shade100,
                          backgroundImage: travellerInfo?.data?.image != null &&
                                  travellerInfo!.data!.image.isNotEmpty
                              ? NetworkImage(travellerInfo!.data!.image)
                              : const AssetImage(
                                      "assets/images/placeholder.png")
                                  as ImageProvider,
                        ),
                        if (travellerInfo?.data?.verifiedStatus == 1)
                          Container(
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            padding: const EdgeInsets.all(2),
                            child: const Icon(
                              Icons.verified,
                              color: Colors.blue,
                              size: 30,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    /// Owner Name (Big Text)
                    Text(
                      translateEn == "en"
                          ? travellerInfo?.data?.enOwnerName ?? "N/A"
                          : travellerInfo?.data?.hiOwnerName ?? "N/A",
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),

                    /// Company Name
                    Text(
                      translateEn == "en"
                          ? travellerInfo?.data?.enCompanyName ?? "N/A"
                          : travellerInfo?.data?.hiCompanyName ?? "N/A",
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 20),

                    /// Info Cards
                    _buildDetailItem(Icons.credit_card, "GST Number",
                        travellerInfo?.data?.gstNo ?? "N/A"),

                    _buildDetailItem(Icons.star, "Rating",
                        "${travellerInfo?.data?.rating ?? 0}"),

                    _buildDetailItem(Icons.work, "Experience",
                        "${travellerInfo?.data?.experience ?? 0} + Years"),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem(IconData icon, String title, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: Colors.blue.withOpacity(0.1),
            child: Icon(icon, color: Colors.blue, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 1️⃣ FETCH TOUR DATA & DOWNLOAD PDF
  Future<void> fetchTourData() async {
    final String url =
        '${AppConstants.baseUrl}${AppConstants.tourDetailsUrl}${widget.productId}';

    try {
      setState(() => isLoading = true);

      final response = await http.post(Uri.parse(url));
      print("API Response: ${response.body}");

      if (response.statusCode == 200) {
        delhiModal = CityDetailsModel.fromJson(json.decode(response.body));

        // OPEN PDF AFTER FETCH
        await openTourInvoice(context, delhiModal?.data?.itineraryUpload);

        // Process hotel/food lists
        List<PackageList> packageList = delhiModal!.data!.packageList.isNotEmpty
            ? delhiModal!.data!.packageList
            : [];

        Map<String, List<PackageList>> filteredLists = filterPackagesByType(packageList);

        hotelList = filteredLists['hotels'] ?? [];
        foodList = filteredLists['foods'] ?? [];

        // Date processing
        processTourDates(delhiModal!.data!.date);

        updateCountdown();
        _updateCountdownEverySecond();
        Future.delayed(const Duration(seconds: 1), _updateCountdownEverySecond);

        isExpandedList = List.generate(delhiModal!.data?.itineraryPlace?.length ?? 0, (index) => false);
      } else {
        print('Failed to load data: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  /// Fetch Tour Invoice and save to local path
  Future<void> openTourInvoice(
      BuildContext context, String? tourInvoiceUrl) async {
    if (tourInvoiceUrl == null || tourInvoiceUrl.isEmpty) {
      // ScaffoldMessenger.of(context).showSnackBar(
      //   const SnackBar(
      //     content: Text("Invoice URL not available!"),
      //     backgroundColor: Colors.blue,
      //   ),
      // );
      return;
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      final savedUrl = prefs.getString('savedInvoiceUrl');
      final savedFilePath = prefs.getString('savedInvoicePath');

      // USE CACHED FILE IF AVAILABLE
      if (tourInvoiceUrl == savedUrl &&
          savedFilePath != null &&
          File(savedFilePath).existsSync()) {
        print("Using cached PDF at $savedFilePath");
        filePath = savedFilePath;
      } else {
        print("Downloading PDF...");
        final response = await Dio().get(
          tourInvoiceUrl,
          options: Options(
            responseType: ResponseType.bytes,
          ),
        );

        if (response.statusCode == 200) {
          final pdfBytes = List<int>.from(response.data);

          Directory tempDir = await getTemporaryDirectory();
          filePath =
              '${tempDir.path}/tour_invoice_${DateTime.now().millisecondsSinceEpoch}.pdf';
          File file = File(filePath);
          await file.writeAsBytes(pdfBytes, flush: true);
          print("Saved PDF at: $filePath");

          await prefs.setString('savedInvoiceUrl', tourInvoiceUrl);
          await prefs.setString('savedInvoicePath', filePath);
        } else {
          throw Exception(
              "Failed to download PDF: HTTP ${response.statusCode}");
        }
      }
    } catch (e) {
      print("Error opening PDF: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to open tour invoice: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void processTourDates(String? startToEndDate) {
    dateforTimer = 'No Start Date';
    dateOneDayEarlier = 'No Start Date';

    if (startToEndDate != null && startToEndDate.trim().isNotEmpty) {
      try {
        if (startToEndDate.contains(" - ")) {
          List<String> dates = startToEndDate.split(" - ");
          String startDateStr = dates[0].trim();

          if (startDateStr.isNotEmpty) {
            final inputFormat = DateFormat('yyyy-MM-dd');
            final outputFormat = DateFormat('d MMM yyyy');

            DateTime originalDate = inputFormat.parseStrict(startDateStr);
            dateforTimer = outputFormat.format(originalDate);

            DateTime newDate = originalDate.subtract(const Duration(days: 1));
            dateOneDayEarlier = outputFormat.format(newDate);
          }
        }
      } catch (e) {
        print("Date parsing error: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    var screenHeight = MediaQuery.of(context).size.height;
    var screenWidth = MediaQuery.of(context).size.width;

    return (isLoading)
        ? MahakalLoadingData(onReload: () {}) // Show loader
        : Scaffold(
            body: ScaffoldLayoutBuilder(
              backgroundColorAppBar:
                  const ColorBuilder(Colors.transparent, Colors.white),
              textColorAppBar: const ColorBuilder(Colors.black),
              appBarBuilder: _appBar,
              child: Stack(
                children: [
                  /// Images Changing AutoMatically
                  Stack(
                    children: [
                      ///  **Image Slider with Error Handling**
                      SizedBox(
                        height: 250,
                        width: double.infinity,
                        child: PageView.builder(
                          controller: _pageController,
                          scrollDirection: Axis.horizontal,
                          itemCount: delhiModal!.data!.imageList.length ?? 0,
                          itemBuilder: (context, index) {
                            return ClipRRect(
                              //borderRadius: BorderRadius.circular(8),
                              // Rounded corners
                              child: CachedNetworkImage(
                                  imageUrl:
                                      delhiModal!.data!.imageList[index] ?? "",
                                  fit: BoxFit.fill,
                                  width: double.infinity,
                                  height: 250,
                                  errorWidget: (context, url, error) =>
                                      const NoImageWidget()),
                            );
                          },
                        ),
                      ),
                    ],
                  ),

                  SingleChildScrollView(
                    controller: scrollController,
                    child: Stack(
                      children: [
                        Container(
                          decoration: const BoxDecoration(
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(50),
                            ),
                            color: Colors.white,
                          ),
                          margin: const EdgeInsets.only(
                            top: 236,
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

                                    /// Name and button for Hindi and English
                                    const SizedBox(height: 5),
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            translateEn == "en"
                                                ? delhiModal
                                                        ?.data?.enTourName ??
                                                    'N/A'
                                                : delhiModal
                                                        ?.data?.hiTourName ??
                                                    'N/A',
                                            style: const TextStyle(
                                              color: Colors.blue,
                                              fontSize: 22,
                                              fontFamily: 'Roboto',
                                              fontWeight: FontWeight.bold,
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow
                                                .ellipsis, // 👈 ensures overflow is handled
                                          ),
                                        ),

                                        const SizedBox(width: 8),
                                        // spacing between text and button
                                        BouncingWidgetInOut(
                                          onPressed: () {
                                            setState(() {
                                              fetchTourData();
                                              gridList = !gridList;
                                              translateEn =
                                                  gridList ? 'en' : 'hi';
                                            });
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
                                                  ? Colors.blue
                                                  : Colors.white,
                                              border: Border.all(
                                                  color: Colors.blue,
                                                  width: 2),
                                            ),
                                            child: Icon(
                                              Icons.translate,
                                              color: gridList
                                                  ? Colors.white
                                                  : Colors.blue,
                                              size: 18,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),

                                    /// Location
                                    if (delhiModal!.data!.pickupLocation.isNotEmpty)
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        // Aligns icon & text at top
                                        children: [
                                          Expanded(
                                            child: Text(
                                              translateEn == "en"
                                                  ? delhiModal!.data!
                                                          .pickupLocation ??
                                                      'N/A'
                                                  : delhiModal!.data!
                                                          .pickupLocation ??
                                                      'N/A',
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w400,
                                                fontFamily: 'Roboto',
                                                color: Colors.black,
                                              ),
                                              maxLines: 3,
                                              overflow: TextOverflow
                                                  .ellipsis, //  correct placement
                                            ),
                                          ),
                                        ],
                                      ),
                                    const SizedBox(
                                      height: 10,
                                    ),

                                    (delhiModal?.data?.customizedType == "1" || delhiModal?.data?.customizedType == "2" || delhiModal?.data?.customizedType == "3") && delhiModal?.data?.useDate == "1"
                                   ? Column(
                                      children: [
                                        delhiModal!.data!.date.isEmpty
                                            ? const SizedBox.shrink()
                                            : Column(
                                          children: [
                                            /// CountDown
                                            delhiModal!.data!.date.isEmpty
                                                ? const SizedBox.shrink()
                                                : Row(
                                              children: [
                                                const Icon(
                                                    Icons
                                                        .calendar_month_outlined,
                                                    color:
                                                    Colors.blue,
                                                    size: 25),
                                                SizedBox(
                                                    width: screenWidth *
                                                        0.02),
                                                Text.rich(
                                                    TextSpan(children: [
                                                      TextSpan(
                                                          text: translateEn ==
                                                              "en"
                                                              ? "Booking will close: "
                                                              : "बुकिंग बंद हो जाएगी: ",
                                                          style: TextStyle(
                                                              fontWeight:
                                                              FontWeight
                                                                  .w600,
                                                              fontSize:
                                                              screenWidth *
                                                                  0.04)),
                                                      TextSpan(
                                                          text: timeRemaining ==
                                                              Duration
                                                                  .zero
                                                              ? "No Time"
                                                              : (timeRemaining
                                                              .isNegative
                                                              ? "Closed"
                                                              : dateOneDayEarlier),
                                                          style: TextStyle(
                                                              color: timeRemaining
                                                                  .isNegative
                                                                  ? Colors
                                                                  .red
                                                                  : Colors
                                                                  .green,
                                                              fontWeight:
                                                              FontWeight
                                                                  .bold))
                                                    ]))
                                              ],
                                            ),
                                            SizedBox(height: screenHeight * 0.01),

                                            timeRemaining == Duration.zero
                                                ? Container()
                                                : (timeRemaining.isNegative
                                                ? Container()
                                                : Row(
                                              crossAxisAlignment:
                                              CrossAxisAlignment
                                                  .center,
                                              mainAxisAlignment:
                                              MainAxisAlignment
                                                  .center,
                                              children: [
                                                Container(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        horizontal:
                                                        10,
                                                        vertical:
                                                        5),
                                                    decoration: BoxDecoration(
                                                        borderRadius:
                                                        BorderRadius
                                                            .circular(
                                                            5),
                                                        color: const Color
                                                            .fromRGBO(
                                                            255,
                                                            238,
                                                            211,
                                                            1)),
                                                    child: Text(
                                                      "${timeRemaining.inDays} Days",
                                                      style: const TextStyle(
                                                          fontSize:
                                                          20,
                                                          fontWeight:
                                                          FontWeight
                                                              .bold,
                                                          fontFamily:
                                                          'Roboto',
                                                          color: Colors
                                                              .orange,
                                                          overflow:
                                                          TextOverflow
                                                              .ellipsis),
                                                    )),
                                                const Padding(
                                                  padding:
                                                  EdgeInsets
                                                      .all(2),
                                                  child: Text(
                                                    ":",
                                                    style: TextStyle(
                                                        fontSize:
                                                        18,
                                                        fontFamily:
                                                        'Roboto',
                                                        fontWeight:
                                                        FontWeight
                                                            .w400),
                                                  ),
                                                ),
                                                Container(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        horizontal:
                                                        10,
                                                        vertical:
                                                        5),
                                                    decoration: BoxDecoration(
                                                        borderRadius:
                                                        BorderRadius
                                                            .circular(
                                                            5),
                                                        color: const Color
                                                            .fromRGBO(
                                                            255,
                                                            238,
                                                            211,
                                                            1)),
                                                    child: Text(
                                                      "${timeRemaining.inHours % 24} Hour",
                                                      style: const TextStyle(
                                                          fontSize:
                                                          20,
                                                          fontWeight:
                                                          FontWeight
                                                              .bold,
                                                          fontFamily:
                                                          'Roboto',
                                                          color: Colors
                                                              .orange,
                                                          overflow:
                                                          TextOverflow
                                                              .ellipsis),
                                                    )),
                                                const Padding(
                                                  padding:
                                                  EdgeInsets
                                                      .all(2),
                                                  child: Text(
                                                    ":",
                                                    style: TextStyle(
                                                        fontSize:
                                                        18,
                                                        fontFamily:
                                                        'Roboto',
                                                        fontWeight:
                                                        FontWeight
                                                            .w400,
                                                        color: Colors
                                                            .black),
                                                  ),
                                                ),
                                                Container(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        horizontal:
                                                        10,
                                                        vertical:
                                                        5),
                                                    decoration: BoxDecoration(
                                                        borderRadius:
                                                        BorderRadius
                                                            .circular(
                                                            5),
                                                        color: const Color
                                                            .fromRGBO(
                                                            255,
                                                            238,
                                                            211,
                                                            1)),
                                                    child: Text(
                                                      "${timeRemaining.inMinutes % 60} Mint",
                                                      style: const TextStyle(
                                                          fontSize:
                                                          20,
                                                          fontWeight:
                                                          FontWeight
                                                              .bold,
                                                          fontFamily:
                                                          'Roboto',
                                                          color: Colors
                                                              .orange,
                                                          overflow:
                                                          TextOverflow
                                                              .ellipsis),
                                                    )),
                                                const Padding(
                                                  padding:
                                                  EdgeInsets
                                                      .all(2),
                                                  child: Text(
                                                    ":",
                                                    style: TextStyle(
                                                        fontSize:
                                                        18,
                                                        fontFamily:
                                                        'Roboto',
                                                        fontWeight:
                                                        FontWeight
                                                            .w400,
                                                        color: Colors
                                                            .black),
                                                  ),
                                                ),
                                                Container(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        horizontal:
                                                        10,
                                                        vertical:
                                                        5),
                                                    decoration: BoxDecoration(
                                                        borderRadius:
                                                        BorderRadius
                                                            .circular(
                                                            5),
                                                        color: const Color
                                                            .fromRGBO(
                                                            255,
                                                            238,
                                                            211,
                                                            1)),
                                                    child: Text(
                                                      "${timeRemaining.inSeconds % 60} Sec",
                                                      style: const TextStyle(
                                                          fontSize:
                                                          20,
                                                          fontWeight:
                                                          FontWeight
                                                              .bold,
                                                          fontFamily:
                                                          'Roboto',
                                                          color: Colors
                                                              .orange,
                                                          overflow:
                                                          TextOverflow
                                                              .ellipsis),
                                                    )),
                                              ],
                                            )),
                                            SizedBox(
                                              height: screenHeight * 0.02,
                                            ),
                                          ],
                                        ),
                                      ],
                                    ) : SizedBox(),

                                    /// Participated People
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
DevoteesCountWidget(),
                                        Text.rich(
                                          TextSpan(
                                            text: translateEn == "en"
                                                ? 'Till now,'
                                                : "अब तक ",
                                            style: const TextStyle(
                                                fontSize: 16,
                                                color: Colors.black),
                                            children: <TextSpan>[
                                              TextSpan(
                                                text:
                                                    '${delhiModal!.data!.userBookingCount! + 10000}+ ',
                                                style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.blue,
                                                    fontSize: 16),
                                              ),
                                              TextSpan(
                                                text: translateEn == "en"
                                                    ? 'Customers have already booked their tours through '
                                                    : "ग्राहकों ने ",
                                                style: const TextStyle(
                                                    fontSize: 16,
                                                    color: Colors.black),
                                              ),
                                              const TextSpan(
                                                text: 'Mahakal.com ',
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.blue,
                                                    fontSize: 16),
                                              ),
                                              TextSpan(
                                                text: translateEn == "en"
                                                    ? 'trusting us for a hassle-free and spiritually enriching travel experience.'
                                                    : "के माध्यम से अपनी यात्राएँ बुक की हैं, हम पर भरोसा करते हुए एक सहज और आध्यात्मिक रूप से समृद्ध यात्रा अनुभव प्राप्त किया है।",
                                                style: const TextStyle(
                                                    fontSize: 16,
                                                    color: Colors.black),
                                              ),
                                            ],
                                          ),
                                          textAlign: TextAlign.start,
                                        ),
                                      ],
                                    )
                                  ],
                                ),
                              ),

                              /// Itinerary details
                              (delhiModal!.data!.itineraryPlace.isNotEmpty ||
                                      delhiModal!
                                          .data!.itineraryUpload!.isNotEmpty)
                                  ? Column(
                                      children: [
                                        const SizedBox(height: 10),

                                        // Main Card
                                        InkWell(
                                          onTap: delhiModal!.data!
                                                  .itineraryPlace.isNotEmpty
                                              ? _showItineraryBottomsheet
                                              : null, // Disable tap if list is empty
                                          borderRadius:
                                              BorderRadius.circular(20),
                                          child: Container(
                                            padding: const EdgeInsets.all(8),
                                            margin: const EdgeInsets.symmetric(
                                                horizontal: 12, vertical: 6),
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                begin: Alignment.topLeft,
                                                end: Alignment.bottomRight,
                                                colors: [
                                                  Colors.blue.shade300
                                                      .withOpacity(0.9),
                                                  Colors.blue.shade100,
                                                  Colors.white,
                                                ],
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.blue
                                                      .withOpacity(0.25),
                                                  blurRadius: 10,
                                                  offset: const Offset(0, 5),
                                                ),
                                              ],
                                            ),
                                            child: Row(
                                              children: [
                                                // Left Icon Section (PDF)
                                                if (delhiModal!.data!.itineraryUpload != "") //  show only if not empty

                                                FadeTransition(
                                                    opacity: _opacityAnimation,
                                                    child: ScaleTransition(
                                                      scale: Tween<double>(
                                                              begin: 0.9,
                                                              end: 1.0)
                                                          .animate(
                                                        CurvedAnimation(
                                                          parent:
                                                              _animationController,
                                                          curve:
                                                              Curves.easeInOut,
                                                        ),
                                                      ),
                                                      child: GestureDetector(
                                                        onTap: () {
                                                          Navigator.push(
                                                            context,
                                                            CupertinoPageRoute(
                                                              builder: (context) => InvoiceViewer(
                                                                  pdfPath:
                                                                      filePath ??
                                                                          '',
                                                                  invoiceUrl: delhiModal!
                                                                      .data!
                                                                      .itineraryUpload,
                                                                  typeText:
                                                                      'View Itinerary',
                                                                  tourLink:
                                                                      "${delhiModal!.data!.shareLink}",
                                                                  isTour: true,
                                                                  tourId: widget
                                                                      .productId,
                                                                  hotelList:
                                                                      hotelList,
                                                                  foodList:
                                                                      foodList,
                                                                  translateEn:
                                                                      translateEn,
                                                                  delhiModal:
                                                                      delhiModal),
                                                            ),
                                                          );
                                                        },
                                                        child: Container(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(12),
                                                          decoration:
                                                              BoxDecoration(
                                                            color: Colors.white,
                                                            shape:
                                                                BoxShape.circle,
                                                            border: Border.all(
                                                                color: Colors
                                                                    .deepOrange,
                                                                width: 2),
                                                            boxShadow: [
                                                              BoxShadow(
                                                                color: Colors
                                                                    .orange
                                                                    .withOpacity(
                                                                        0.3),
                                                                blurRadius: 8,
                                                                offset:
                                                                    const Offset(
                                                                        2, 4),
                                                              ),
                                                            ],
                                                          ),
                                                          child: const Icon(
                                                            Icons
                                                                .picture_as_pdf_rounded,
                                                            color: Colors.black,
                                                            size: 28,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                const SizedBox(width: 14),

                                                // Title and Subtitle
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        translateEn == "en"
                                                            ? "Itinerary Place Details"
                                                            : "यात्रा विवरण (Itinerary Place)",
                                                        style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.w800,
                                                          color: Colors
                                                              .orange.shade900,
                                                          fontSize: 18,
                                                        ),
                                                      ),
                                                      const SizedBox(height: 4),
                                                      Text(
                                                        translateEn == "en"
                                                            ? "View your trip’s full details and schedule"
                                                            : "अपनी यात्रा के विवरण और कार्यक्रम देखें",
                                                        style: TextStyle(
                                                          color: Colors
                                                              .orange.shade700
                                                              .withOpacity(0.8),
                                                          fontSize: 13,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                const SizedBox(width: 10),

                                                // "View All" Button — show only if itineraryPlace is not empty
                                                if (delhiModal!.data!
                                                    .itineraryPlace.isNotEmpty)
                                                  InkWell(
                                                    onTap:
                                                        _showItineraryBottomsheet,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            24),
                                                    child: AnimatedContainer(
                                                      duration: const Duration(
                                                          milliseconds: 600),
                                                      curve: Curves.easeInOut,
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          horizontal: 10,
                                                          vertical: 5),
                                                      decoration: BoxDecoration(
                                                        gradient:
                                                            LinearGradient(
                                                          colors: [
                                                            Colors.blueAccent
                                                                .shade400,
                                                            Colors
                                                                .blue.shade300,
                                                          ],
                                                          begin:
                                                              Alignment.topLeft,
                                                          end: Alignment
                                                              .bottomRight,
                                                        ),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(24),
                                                        boxShadow: [
                                                          BoxShadow(
                                                            color: Colors
                                                                .blueAccent
                                                                .withOpacity(
                                                                    0.3),
                                                            blurRadius: 8,
                                                            offset:
                                                                const Offset(
                                                                    0, 4),
                                                          ),
                                                        ],
                                                      ),
                                                      child: AnimatedBuilder(
                                                        animation:
                                                            _animationController,
                                                        builder:
                                                            (context, child) {
                                                          return Opacity(
                                                            opacity:
                                                                _opacityAnimation
                                                                    .value,
                                                            child: child,
                                                          );
                                                        },
                                                        child: Row(
                                                          children: [
                                                            Text(
                                                              translateEn ==
                                                                      "en"
                                                                  ? "View All"
                                                                  : "सभी देखें",
                                                              style:
                                                                  const TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                color: Colors
                                                                    .white,
                                                                fontSize: 15,
                                                              ),
                                                            ),
                                                            const SizedBox(
                                                                width: 6),
                                                            const Icon(
                                                              Icons
                                                                  .arrow_forward_rounded,
                                                              color:
                                                                  Colors.white,
                                                              size: 18,
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    )
                                  : const SizedBox(),

                              /// Travellers Info
                              (travellerInfo?.status ?? 0) == 0
                                  ? const SizedBox.shrink()
                                  : Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10.0, vertical: 8.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Divider(
                                            color: Colors.grey.shade400,
                                          ),
                                          const SizedBox(height: 5),
                                          Row(
                                            children: [
                                              Text(
                                                translateEn == "en"
                                                    ? "Travel agent's info"
                                                    : "यात्रा एजेंट की जानकारी",
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.blue,
                                                  fontSize: 20,
                                                ),
                                              ),
                                              const Spacer(),
                                              GestureDetector(
                                                onTap: () {
                                                  _showTravelAgentDetails();
                                                },
                                                child: const Icon(
                                                  Icons.report_gmailerrorred,
                                                  color: Colors.black,
                                                  size: 22,
                                                ),
                                              )
                                            ],
                                          ),
                                          // const SizedBox(height: 12),
                                          // Container(
                                          //   width: double.infinity,
                                          //   margin: const EdgeInsets.all(5),
                                          //   padding: const EdgeInsets.all(16),
                                          //   decoration: BoxDecoration(
                                          //     borderRadius: BorderRadius.circular(16),
                                          //     color: Colors.white,
                                          //     boxShadow: [
                                          //       BoxShadow(
                                          //         color: Colors.grey.shade300,
                                          //         offset: const Offset(0, 4),
                                          //         blurRadius: 10,
                                          //         spreadRadius: 1,
                                          //       ),
                                          //     ],
                                          //     border: Border.all(
                                          //       color: Colors.blue.shade100,
                                          //       width: 1.5,
                                          //     ),
                                          //   ),
                                          //   child: Column(
                                          //     children: [
                                          //       Row(
                                          //         crossAxisAlignment: CrossAxisAlignment.start,
                                          //         children: [
                                          //           // Profile Image with Verified Badge
                                          //           Stack(
                                          //             children: [
                                          //               Container(
                                          //                 height: 80,
                                          //                 width: 80,
                                          //                 decoration: BoxDecoration(
                                          //                   borderRadius: BorderRadius.circular(100),
                                          //                   border: Border.all(
                                          //                     color: Colors.blue.shade300,
                                          //                     width: 2,
                                          //                   ),
                                          //                   gradient: LinearGradient(
                                          //                     colors: [
                                          //                       Colors.blue.shade100,
                                          //                       Colors.blue.shade50,
                                          //                     ],
                                          //                     begin: Alignment.topCenter,
                                          //                     end: Alignment.bottomCenter,
                                          //                   ),
                                          //                 ),
                                          //                 child: ClipRRect(
                                          //                   borderRadius: BorderRadius.circular(100),
                                          //                   child: CachedNetworkImage(
                                          //                     imageUrl: travellerInfo?.data?.image ?? '',
                                          //                     fit: BoxFit.cover,
                                          //                     errorWidget: (context, url, error) => Icon(
                                          //                       Icons.person,
                                          //                       size: 40,
                                          //                       color: Colors.blue.shade300,
                                          //                     ),
                                          //                     placeholder: (context, url) => Center(
                                          //                       child: CircularProgressIndicator(
                                          //                         color: Colors.blue.shade300,
                                          //                       ),
                                          //                     ),
                                          //                   ),
                                          //                 ),
                                          //               ),
                                          //               // Verified Badge
                                          //               travellerInfo?.data?.verifiedStatus == 1 ?  Positioned(
                                          //                 bottom: 2,
                                          //                 right: 2,
                                          //                 child: Container(
                                          //                   padding: const EdgeInsets.all(4),
                                          //                   decoration: BoxDecoration(
                                          //                     color: Colors.green,
                                          //                     borderRadius: BorderRadius.circular(20),
                                          //                     border: Border.all(
                                          //                       color: Colors.white,
                                          //                       width: 2,
                                          //                     ),
                                          //                   ),
                                          //                   child: const Icon(
                                          //                     Icons.verified,
                                          //                     color: Colors.white,
                                          //                     size: 16,
                                          //                   ),
                                          //                 ),
                                          //               ) : const SizedBox.shrink(),
                                          //             ],
                                          //           ),
                                          //           const SizedBox(width: 16),
                                          //
                                          //           // Agent Information
                                          //           Expanded(
                                          //             child: Column(
                                          //               crossAxisAlignment: CrossAxisAlignment.start,
                                          //               children: [
                                          //                 // Name with verification
                                          //                 Row(
                                          //                   children: [
                                          //                     Text(
                                          //                       translateEn == "en"
                                          //                           ? travellerInfo?.data?.enOwnerName ?? "N/A"
                                          //                           : travellerInfo?.data?.hiOwnerName ?? "N/A",
                                          //                       style: const TextStyle(
                                          //                         fontSize: 18,
                                          //                         fontWeight: FontWeight.bold,
                                          //                         color: Colors.black87,
                                          //                       ),
                                          //                     ),
                                          //                     const SizedBox(width: 6),
                                          //                     if(travellerInfo?.data?.verifiedStatus == 1) Icon(
                                          //                       Icons.verified,
                                          //                       color: Colors.green.shade600,
                                          //                       size: 18,
                                          //                     ),
                                          //                   ],
                                          //                 ),
                                          //                 const SizedBox(height: 8),
                                          //
                                          //                 // Company Name
                                          //                 Row(
                                          //                   children: [
                                          //                     Icon(
                                          //                       Icons.business,
                                          //                       size: 18,
                                          //                       color: Colors.blue.shade600,
                                          //                     ),
                                          //                     const SizedBox(width: 6),
                                          //                     Expanded(
                                          //                       child: Text(
                                          //                         translateEn == "en"
                                          //                             ? travellerInfo?.data?.enCompanyName ?? 'Not available'
                                          //                             : travellerInfo?.data?.hiCompanyName ?? 'Not available',
                                          //                         style: TextStyle(
                                          //                           color: Colors.blue.shade700,
                                          //                           fontWeight: FontWeight.w600,
                                          //                           fontSize: 16,
                                          //                           overflow: TextOverflow.ellipsis,
                                          //                         ),
                                          //                         maxLines: 2,
                                          //                       ),
                                          //                     ),
                                          //                   ],
                                          //                 ),
                                          //                 const SizedBox(height: 8),
                                          //
                                          //                 // Rating/Experience (you can add more fields here)
                                          //                 Row(
                                          //                   children: [
                                          //                     Icon(
                                          //                       Icons.star,
                                          //                       size: 18,
                                          //                       color: Colors.amber.shade600,
                                          //                     ),
                                          //                     const SizedBox(width: 6),
                                          //                     Text(
                                          //                       "${travellerInfo?.data?.rating} • ${travellerInfo?.data?.experience}+ Years Experience",
                                          //                       style: TextStyle(
                                          //                         color: Colors.grey.shade700,
                                          //                         fontSize: 14,
                                          //                       ),
                                          //                     ),
                                          //                   ],
                                          //                 ),
                                          //               ],
                                          //             ),
                                          //           ),
                                          //         ],
                                          //       ),
                                          //
                                          //       const SizedBox(height: 16),
                                          //
                                          //       // View Details Button
                                          //       // Container(
                                          //       //   width: double.infinity,
                                          //       //   height: 45,
                                          //       //   decoration: BoxDecoration(
                                          //       //     gradient: LinearGradient(
                                          //       //       colors: [
                                          //       //         Colors.blue.shade500,
                                          //       //         Colors.blue.shade700,
                                          //       //       ],
                                          //       //       begin: Alignment.centerLeft,
                                          //       //       end: Alignment.centerRight,
                                          //       //     ),
                                          //       //     borderRadius: BorderRadius.circular(12),
                                          //       //     boxShadow: [
                                          //       //       BoxShadow(
                                          //       //         color: Colors.blue.shade300,
                                          //       //         offset: const Offset(0, 2),
                                          //       //         blurRadius: 4,
                                          //       //       ),
                                          //       //     ],
                                          //       //   ),
                                          //       //   child: Material(
                                          //       //     color: Colors.transparent,
                                          //       //     borderRadius: BorderRadius.circular(12),
                                          //       //     child: InkWell(
                                          //       //       borderRadius: BorderRadius.circular(12),
                                          //       //       onTap: () {
                                          //       //         _showTravelAgentDetails();
                                          //       //       },
                                          //       //       child: Center(
                                          //       //         child: Row(
                                          //       //           mainAxisAlignment: MainAxisAlignment.center,
                                          //       //           children: [
                                          //       //             Icon(
                                          //       //               Icons.info_outline,
                                          //       //               color: Colors.white,
                                          //       //               size: 20,
                                          //       //             ),
                                          //       //             const SizedBox(width: 8),
                                          //       //             Text(
                                          //       //               translateEn == "en"
                                          //       //                   ? "View Full Details"
                                          //       //                   : "पूरी जानकारी देखें",
                                          //       //               style: const TextStyle(
                                          //       //                 color: Colors.white,
                                          //       //                 fontWeight: FontWeight.w600,
                                          //       //                 fontSize: 16,
                                          //       //               ),
                                          //       //             ),
                                          //       //           ],
                                          //       //         ),
                                          //       //       ),
                                          //       //     ),
                                          //       //   ),
                                          //       // ),
                                          //     ],
                                          //   ),
                                          // ),
                                        ],
                                      ),
                                    ),

                              const SizedBox(
                                height: 10,
                              ),
                              Container(
                                color: Colors.blue.shade100,
                                width: double.infinity,
                                height: 5,
                              ),

                              /// Descreaption
                              Container(
                                key: oneKey,
                                margin: const EdgeInsets.all(10),
                                child: Column(
                                  children: [
                                    Html(
                                        data: translateEn == "en"
                                            ? delhiModal?.data!.enDescription ??
                                                'N/A'
                                            : delhiModal?.data!.hiDescription ??
                                                'N/A'),
                                  ],
                                ),
                              ),
                              Container(
                                color: Colors.blue.shade100,
                                width: double.infinity,
                                height: 5,
                              ),

                              /// HighLights
                              Container(
                                key: twoKey,
                                margin: const EdgeInsets.all(10),
                                child: Column(
                                  children: [
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    Html(
                                        data: translateEn == "en"
                                            ? delhiModal?.data!.enHighlights ??
                                                'N/A'
                                            : delhiModal?.data!.hiHighlights ??
                                                'N/A'),
                                  ],
                                ),
                              ),
                              Container(
                                color: Colors.blue.shade100,
                                width: double.infinity,
                                height: 5,
                              ),

                              /// Inclusion
                              Container(
                                key: threeKey,
                                margin: const EdgeInsets.all(10),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      translateEn == "en"
                                          ? "Inclusion"
                                          : "सम्मिलित",
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 26,
                                          color:
                                              Color.fromRGBO(128, 0, 0, 0.8)),
                                    ),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    Html(
                                        data: translateEn == "en"
                                            ? delhiModal?.data!.enInclusion ??
                                                'N/A'
                                            : delhiModal?.data!.hiInclusion ??
                                                'N/A'),
                                  ],
                                ),
                              ),
                              Container(
                                color: Colors.blue.shade100,
                                width: double.infinity,
                                height: 5,
                              ),

                              /// Exclusion
                              Container(
                                key: fourKey,
                                margin: const EdgeInsets.all(10),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      translateEn == "en"
                                          ? "Exclusion"
                                          : "सम्मिलन नहीं",
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 26,
                                          color:
                                              Color.fromRGBO(128, 0, 0, 0.8)),
                                    ),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    Html(
                                        data: translateEn == "en"
                                            ? delhiModal?.data!.enExclusion ??
                                                "N/A"
                                            : delhiModal?.data!.hiExclusion ??
                                                "N/A"),
                                  ],
                                ),
                              ),
                              Container(
                                color: Colors.blue.shade100,
                                width: double.infinity,
                                height: 5,
                              ),

                              /// Terms And Policy
                              Container(
                                key: fiveKey,
                                margin: const EdgeInsets.all(10),
                                child: Column(
                                  children: [
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    Html(
                                        data: translateEn == "en"
                                            ? delhiModal?.data!
                                                    .enTermsAndConditions ??
                                                "N/A"
                                            : delhiModal?.data!
                                                    .hiTermsAndConditions ??
                                                "N/A"),
                                  ],
                                ),
                              ),
                              Container(
                                color: Colors.blue.shade100,
                                width: double.infinity,
                                height: 5,
                              ),

                              /// Cancellation
                              Container(
                                key: sixKey,
                                margin: const EdgeInsets.all(10),
                                child: Column(
                                  children: [
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    Html(
                                        data: translateEn == "en"
                                            ? delhiModal?.data!
                                                    .enCancellationPolicy ??
                                                "N/A"
                                            : delhiModal?.data!
                                                    .hiCancellationPolicy ??
                                                "N/A"),
                                  ],
                                ),
                              ),
                              Container(
                                color: Colors.blue.shade100,
                                width: double.infinity,
                                height: 5,
                              ),

                              /// Notes
                              Container(
                                key: sevenKey,
                                child: Column(
                                  children: [
                                    const SizedBox(height: 10),
                                    Html(
                                        data: translateEn == "en"
                                            ? delhiModal?.data!.enNotes ?? "N/A"
                                            : delhiModal?.data!.hiNotes ??
                                                "N/A"),
                                  ],
                                ),
                              ),
                              Container(
                                color: Colors.blue.shade100,
                                width: double.infinity,
                                height: 5,
                              ),

                              /// Reviews Section
                              _isReveiwLoading
                                  ? const SizedBox()
                                  : (commentList != null &&
                                          commentList!.data != null &&
                                          commentList!.data!.isNotEmpty
                                      ? Column(
                                          key: eightKey,
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.all(8),
                                              child: Row(
                                                children: [
                                                  Container(
                                                    height: 20,
                                                    width: 3,
                                                    color: Colors.blue,
                                                  ),
                                                  const SizedBox(
                                                    width: 5,
                                                  ),
                                                  Text(
                                                    translateEn == "en"
                                                        ? "Reviews"
                                                        : "रिव्यु",
                                                    style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 16),
                                                  ),
                                                  const Spacer(),
                                                  InkWell(
                                                      onTap: () {
                                                        _showReviewsBottomsheet();
                                                      },
                                                      child: Text(
                                                        translateEn == "en"
                                                            ? "See All"
                                                            : "सभी देखें",
                                                        style: const TextStyle(
                                                            color:
                                                                Colors.blue,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize: 14),
                                                      )),
                                                ],
                                              ),
                                            ),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.all(15.0),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    translateEn == "en"
                                                        ? "Ratings and reviews below are from real users who booked this tour using their mobile."
                                                        : "नीचे दी गई रेटिंग और समीक्षाएं उन उपयोगकर्ताओं की हैं जिन्होंने अपने मोबाइल से यह टूर बुक किया है।",
                                                    style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.w500),
                                                  ),
                                                  const SizedBox(
                                                    height: 10,
                                                  ),

                                                  commentList != null
                                                      ? Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            OverAllProductRating(
                                                              starCounts:
                                                                  _starCounts,
                                                              avgRating:
                                                                  _avgRating,
                                                            ),
                                                            PRatingBarIndicater(
                                                                rating: double.parse(
                                                                    commentList!
                                                                        .tourStar
                                                                        .toString())),
                                                            const SizedBox(
                                                              height: 10,
                                                            ),
                                                          ],
                                                        )
                                                      : const CircularProgressIndicator(),

                                                  // Show only top 5 comments
                                                  ...commentList!.data!
                                                      .take(5)
                                                      .map((comment) => Container(
                                                          margin:
                                                              const EdgeInsets.all(
                                                                  5),
                                                          padding:
                                                              const EdgeInsets.all(
                                                                  8),
                                                          decoration: BoxDecoration(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          10),
                                                              color: Colors.grey
                                                                  .shade100),
                                                          child: UserReviewCard(
                                                              comment: comment))),
                                                ],
                                              ),
                                            ),
                                          ],
                                        )
                                      : Container(
                                          margin: const EdgeInsets.symmetric(
                                              horizontal: 16, vertical: 24),
                                          padding: const EdgeInsets.all(24),
                                          decoration: BoxDecoration(
                                            color: Colors.blue.shade50,
                                            borderRadius:
                                                BorderRadius.circular(16),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black
                                                    .withOpacity(0.05),
                                                blurRadius: 10,
                                                offset: const Offset(0, 4),
                                              ),
                                            ],
                                          ),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              Icon(
                                                Icons.rate_review_outlined,
                                                color: Colors.blue.shade400,
                                                size: 48,
                                              ),
                                              const SizedBox(height: 12),
                                              const Text(
                                                "No Reviews Yet!",
                                                style: TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.black87,
                                                ),
                                              ),
                                              const SizedBox(height: 8),
                                              Text(
                                                "Be the first one to share your thoughts.",
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.grey.shade600,
                                                ),
                                                textAlign: TextAlign.center,
                                              ),
                                            ],
                                          ),
                                        )),
                              Container(
                                color: Colors.blue.shade100,
                                width: double.infinity,
                                height: 5,
                              ),

                              /// FAQ's
                              // Container(
                              //   key: nineKey,
                              //   child: Askquestions(
                              //       type: 'Tour', translateEn: translateEn),
                              // ),
                              const SizedBox(
                                height: 50,
                              ),
                            ],
                          ),
                        ),
                        Positioned(
                          top: 190,
                          right: 10,
                          child: InkWell(
                            onTap: () {
                              showModalBottomSheet(
                                  context: context,
                                  isScrollControlled: true,
                                  builder: (context) {
                                    return FullScreenImageSlider(
                                      images: delhiModal!.data!.imageList,
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
                                      15, // Slightly more horizontal padding
                                  vertical: 5, // More vertical padding
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
            floatingActionButtonLocation:
                FloatingActionButtonLocation.centerDocked,
            floatingActionButton: (isLoading)
                ? const SizedBox.shrink()
                : Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // SHARE BUTTON (Square)
                        Expanded(
                          flex: 0,
                          child: GestureDetector(
                            onTap: () {
                              shareTour.shareTour(
                                context,
                                delhiModal!.data!.shareLink,
                                delhiModal!.data!.image,
                              );
                            },
                            child: Container(
                              height: 60,
                              width: 65,
                              decoration: BoxDecoration(
                                color: Colors.blueAccent,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.blue.withOpacity(0.15),
                                    blurRadius: 6,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: const Center(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.share_rounded,
                                      size: 25,
                                      color: Colors.white,
                                    ),
                                    Text(
                                      "Share",
                                      style: TextStyle(color: Colors.white),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),

                        // BOOK NOW BUTTON
                        Expanded(
                          flex: 1,
                          child: GestureDetector(
                            onTap: () {
                              handleAction("${delhiModal!.data!.useDate ?? ""}");
                            },
                            child: Container(
                              height: 60,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                color: Colors.blue,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    blurRadius: 6,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              padding: const EdgeInsets.symmetric(
                                  vertical: 4, horizontal: 16),
                              child: Row(
                                children: [
                                  // Text content
                                  Expanded(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          translateEn == "en"
                                              ? "BOOK NOW"
                                              : "अभी बुक करें",
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            fontFamily: 'Roboto',
                                            color: Colors.white,
                                          ),
                                        ),
                                        SizedBox(
                                          width: double.infinity,
                                          child: Text(
                                            translateEn == "en"
                                                ? delhiModal!
                                                        .data!.enTourName ??
                                                    'N/A'
                                                : delhiModal!
                                                        .data!.hiTourName ??
                                                    'N/A',
                                            style: const TextStyle(
                                              fontSize: 14,
                                              fontFamily: 'Roboto',
                                              color: Colors.white,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  // Arrow icon
                                  Container(
                                    width: 28,
                                    height: 28,
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.white24,
                                    ),
                                    child: const Icon(
                                      Icons.arrow_forward_rounded,
                                      size: 20,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
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
                    "Tour Details",
                    style: TextStyle(color: Colors.white),
                  ),
                  const Spacer(),
                ],
              ),
            )
          : null,
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
                    case 8:
                      context = eightKey.currentContext;
                      break;
                    case 9:
                      context = nineKey.currentContext;
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
              labelColor: Colors.blue,
              controller: _tabController,
              unselectedLabelStyle: const TextStyle(fontSize: 18),
              labelStyle: const TextStyle(fontSize: 20),
              tabs: [
                Tab(text: translateEn == "en" ? "Description" : "विवरण"),
                Tab(text: translateEn == "en" ? "Highlights" : "हाइलाइट"),
                Tab(text: translateEn == "en" ? "Inclusion" : "सम्मिलित"),
                Tab(text: translateEn == "en" ? "Exclusion" : "सम्मिलित नहीं"),
                Tab(
                    text: translateEn == "en"
                        ? "Terms & Policy"
                        : "शर्तें एवं नीति"),
                Tab(text: translateEn == "en" ? "Cancellation" : "रद्द करना"),
                Tab(text: translateEn == "en" ? "Note's" : "टिप्पणियाँ"),
                Tab(text: translateEn == "en" ? "Reviews" : "रिव्यु"),
                Tab(
                    text: translateEn == "en"
                        ? "FAQ's"
                        : "पूछे जाने वाले प्रश्न"),
              ],
              indicatorSize: TabBarIndicatorSize.tab,
            )
          : null,
    );
  }
}
