import 'dart:async';
import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mahakal/features/event_booking/model/event_lead_model.dart';
import '../../../data/datasource/remote/http/httpClient.dart';
import '../../../main.dart';
import '../../../utill/app_constants.dart';
import '../../../utill/full_screen_image_slider.dart';
import '../../../utill/loading_datawidget.dart';
import '../../profile/controllers/profile_contrroller.dart';
import '../../tour_and_travells/Controller/lanaguage_provider.dart';
import '../../tour_and_travells/widgets/OverAllProductRating.dart';
import '../../tour_and_travells/widgets/PRatingBarIndicater.dart';
import '../model/event_reviewmodel.dart';
import '../model/single_details_model.dart';
import '../model/subCategory_model.dart';
import '../widgets/EventReviewCard.dart';
import 'EventBookingScreen.dart';
import 'event_payment_screen.dart';
import 'package:intl/intl.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:provider/provider.dart';

import 'event_summery.dart';

class EventDeatils extends StatefulWidget {
  final dynamic? eventId;
  EventDeatils({
    super.key,
    this.eventId,
  });

  @override
  State<EventDeatils> createState() => _EventDeatilsState();
}

class _EventDeatilsState extends State<EventDeatils> {
  late PageController _pageController;
  final GlobalKey _venuesKey = GlobalKey();

  Duration? timeRemaining;
  bool isCountingDown = true;
  String countdownText = "";
  String dateforTimer = "";
  int days = 0, hours = 0, minutes = 0, seconds = 0;

  bool _isReveiwLoading = false;
  bool isExpanded = false;
  bool isLoading = false;
  int isInterested = 0;

  String venueSelected = "";
  String venuehindiSelected = "";
  String selectStartDate = "";
  String selectEndTime = "";
  String selectTime = "";

  // Default values
  String startDate = 'No Start Date';
  String endDate = 'No End Date';
  String fullDate = 'No Date';
  String singleDate = 'No Single Date';

  String userId = "";
  int venueId = 0;

  String eventDuration = "";

  double _avgRating = 0.0;
  Map<int, int> _starCounts = {
    1: 0,
    2: 0,
    3: 0,
    4: 0,
    5: 0,
  };

  Data? singleEventData;
  Data? selectedEventData;
  EventReviewModel? commentList;

  List<EventAllVenueData> allVenueData = [];
  var selectedPackageList = <SinglePackageList>[];

  int _currentPage = 0;
  Timer? _timer;

  bool isReachedTarget = false;

  int _selectedVenueIndex = -1;
  String? selectedVenue;

  @override
  void initState() {
    super.initState();
    userId = Provider.of<ProfileController>(Get.context!, listen: false).userID;
    getSingleEventData(widget.eventId!);
    _pageController = PageController(initialPage: _currentPage);
    fetchComment();
    //Start a timer to auto-scroll every 2 seconds
    _timer = Timer.periodic(const Duration(seconds: 2), (Timer timer) {
      if (_currentPage < singleEventData!.images.length) {
        _currentPage++;
      } else {
        _currentPage = 0;
      }
      _pageController.animateToPage(
        _currentPage,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeIn,
      );
    });
  }

  void dateFormatter(String startToEndDate) {

    if (startToEndDate.isNotEmpty) {
      List<String> dates = startToEndDate.contains(" - ")
          ? startToEndDate.split(" - ")
          : [startToEndDate];

      final inputFormat = DateFormat('yyyy-MM-dd');
      final outputFormat = DateFormat('d MMMM yyyy'); // 10 March 2025 format

      try {
        // Start date format
        startDate = outputFormat.format(inputFormat.parse(dates[0]));

        if (dates.length > 1) {
          // End date format (if range is given)
          endDate = outputFormat.format(inputFormat.parse(dates[1]));
          fullDate = "$startDate - $endDate";
        } else {
          // Single date case
          singleDate = startDate;
          fullDate = startDate;
        }
      } catch (e) {
        print("Date Parsing Error: $e");
      }
    }
  }

  /// show Event Details
  void showEventDetails(Data eventData) {
    setState(() {
      selectedEventData = eventData; // Set the selected event data
    });
  }

  /// Fetch Event Details
  Future<void> getSingleEventData(dynamic eventDetailsId) async {
    String endpoint = AppConstants.eventDetailsUrl;

    print("Event Details $eventDetailsId");

    Map<String, dynamic> data = {
      "event_id": eventDetailsId,
      "user_id": userId, // Assuming userId is defined in the scope
    };

    setState(() {
      isLoading = true;
    });

    try {
      final res = await HttpService().postApi(endpoint, data);
      print(res);

      if (res != null) {
        final singleData = SingleDetailsModel.fromJson(res);
        setState(() {
          singleEventData = singleData.data;
          allVenueData = singleData.data!.allVenueData ?? [];

          if (allVenueData.isNotEmpty) {
            venueSelected = allVenueData[0].enEventVenue ?? "";
            venueId = allVenueData[0].id;
            venuehindiSelected = allVenueData[0].hiEventVenue ?? "";
          }

          isInterested = singleEventData!.eventInterest!;
          print("My Event Status is $isInterested");
          print(singleEventData?.enEventName ?? 'No event name');
          print("Total Venues: ${allVenueData.length}");
          print("Event Next Date: ${singleEventData?.eventNextDate}");
        });
      }
    } catch (e) {
      print("Error in SingleDetails: $e");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  /// Intreseted API
  Future<void> interestedEvent(int eventId) async {
    String endpoint = AppConstants.eventIntrestedUrl;

    Map<String, dynamic> data = {
      "event_id": eventId,
      "user_id": userId, // Assuming userId is already available
    };

    try {
      final res = await HttpService().postApi(endpoint, data);
      print(res);
    } catch (e) {
      print("Error marking interest in event: $e");
    }
  }

  /// Show Artist Details
  showBottomSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      backgroundColor: Colors.white,
      isScrollControlled: true,
      builder: (context) {
        return Consumer<LanguageProvider>(
          builder: (context, languageProvider, _) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Drag handle
                  Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  // Artist Image
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      singleEventData!.artist!.image ?? "N/A",
                      height: 200,
                      width: 200,
                      fit: BoxFit.cover,
                    ),
                  ),
                  // Description
                  Html(
                    data: languageProvider.language == "english"
                        ? singleEventData!.artist!.enProfession ?? "N/A"
                        : singleEventData!.artist!.hiProfession ?? "N/A",
                    style: {
                      "body": Style(
                        fontSize: FontSize(23),
                        color: Colors.blue,
                        lineHeight: LineHeight.number(1.5),
                        textAlign: TextAlign.center,
                      ),
                    },
                  ),
                  Divider(
                    color: Colors.grey.shade400,
                  ),
                  Html(
                    data: languageProvider.language == "english"
                        ? singleEventData!.artist!.enDescription ?? "N/A"
                        : singleEventData!.artist!.hiDescription ?? "N/A",
                    style: {
                      "body": Style(
                        fontSize: FontSize(18),
                        color: Colors.grey.shade800,
                        lineHeight: LineHeight.number(1.5),
                        textAlign: TextAlign.justify,
                      ),
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  /// Fetch Comments
  Future<void> fetchComment() async {
    Map<String, dynamic> data = {"event_id": widget.eventId};

    setState(() {
      _isReveiwLoading = true;
    });

    try {
      final res =
          await HttpService().postApi(AppConstants.fetchEventCommentUrl, data);
      print(res);

      if (res != null && res["status"] == 1) {
        final commentResponse = EventReviewModel.fromJson(res);

        List<EventListModel> comments = commentResponse.data ?? [];

        Map<int, int> starCounts = calculateStarCounts(comments);
        double avgRating = calculateAverage(comments);

        setState(() {
          commentList = commentResponse;
          _starCounts = starCounts;
          _avgRating = avgRating;
        });
      } else {
        print("No event reviews or status != 1");
      }
    } catch (e) {
      print("Error in fetching Event Review: $e");

      setState(() {
        commentList = EventReviewModel(data: [], eventStar: "", recode: 0);
        _starCounts = {1: 0, 2: 0, 3: 0, 4: 0, 5: 0};
        _avgRating = 0.0;
      });
    } finally {
      setState(() {
        _isReveiwLoading = false;
      });
    }
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
                              ...commentList!.data.map((comment) => Container(
                                  margin: const EdgeInsets.all(5),
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      color: Colors.grey.shade100),
                                  child:
                                      EventUserReviewCard(comment: comment))),
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

  Map<int, int> calculateStarCounts(List<EventListModel> comments) {
    Map<int, int> counts = {1: 0, 2: 0, 3: 0, 4: 0, 5: 0};

    for (var comment in comments) {
      if (counts.containsKey(comment.star)) {
        counts[comment.star] = counts[comment.star]! + 1;
      }
    }
    return counts;
  }

  double calculateAverage(List<EventListModel> comments) {
    if (comments.isEmpty) return 0.0;

    int totalStars = comments.fold(0, (sum, item) => sum + item.star);
    return totalStars / comments.length;
  }

  String formatDateString(String rawDate) {
    try {
      // Fix double dashes if present
      String fixedDate = rawDate.replaceAll('--', '-');

      // Parse the fixed string into DateTime
      DateTime parsedDate = DateTime.parse(fixedDate);

      // Format it as you want - here: Jan 06, 2025
      return DateFormat('MMM dd, yyyy').format(parsedDate);
    } catch (e) {
      // In case of error, just return the raw input or empty string
      return rawDate;
    }
  }

  void _scrollToVenues() async {

    final context = _venuesKey.currentContext;

    if (context != null) {

      await Scrollable.ensureVisible(
        context,
        duration: Duration(milliseconds: 600),
        curve: Curves.easeInOut,
      );

      /// Auto select first venue
      if (_selectedVenueIndex == -1 && allVenueData.isNotEmpty) {

        final venue = allVenueData[0];

        setState(() {
          _selectedVenueIndex = 0;
          venueId = venue.id;
          venueSelected = venue.enEventVenue;
          venuehindiSelected = venue.hiEventVenue;
        });
      }
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    isCountingDown = false; // Stop countdown updates when widget is disposed
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var screenHeight = MediaQuery.of(context).size.height;
    var screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
        backgroundColor: Colors.white,
        body: isLoading
            ? MahakalLoadingData(
                onReload: () => getSingleEventData(widget.eventId!))
            : SafeArea(
                child: RefreshIndicator(
                  onRefresh: () async {
                    getSingleEventData(widget.eventId!);
                  },
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: Column(
                      children: [
                        /// Images Changing AutoMatically
                        Stack(
                          children: [
                            SizedBox(
                              height: 250,
                              width: double.infinity,
                              child: PageView.builder(
                                controller: _pageController,
                                scrollDirection: Axis.horizontal,
                                itemCount: singleEventData?.images?.length,
                                itemBuilder: (context, index) {
                                  return CachedNetworkImage(
                                    imageUrl:
                                        singleEventData?.images?[index] ?? "",
                                    fit: BoxFit.fill,
                                    errorWidget: (context, url, error) =>
                                        const Icon(Icons.broken_image,
                                            size: 50),
                                  );
                                },
                              ),
                            ),
                            Positioned.fill(
                              child: Container(
                                decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.2)),
                              ),
                            ),
                            Positioned(
                                top: screenHeight * 0.03,
                                left: screenWidth * 0.05,
                                child: IconButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    icon: const Icon(
                                      Icons.arrow_back_ios,
                                      color: Colors.white,
                                    ))),
                            Positioned(
                              right: 10,
                              bottom: 10,
                              child: InkWell(
                                onTap: () {
                                  showModalBottomSheet(
                                      context: context,
                                      isScrollControlled: true,
                                      builder: (context) {
                                        return FullScreenImageSlider(
                                          images: singleEventData!.images,
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
                                  child: Padding(
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

                        Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Consumer<LanguageProvider>(
                                builder: (BuildContext context,
                                    languageProvider, Widget? child) {
                                  return Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      /// Event Heading
                                      Text(
                                        languageProvider.language == "english"
                                            ? singleEventData?.enEventName ??
                                                "N/A"
                                            : singleEventData?.hiEventName ??
                                                "N/A",
                                        style: TextStyle(
                                            fontSize: screenWidth * 0.05,
                                            fontWeight: FontWeight.bold,
                                            color: const Color.fromRGBO(
                                                255, 118, 10, 1)),
                                      ),

                                      /// Intrested Button
                                      Container(
                                          width: screenWidth * double.infinity,
                                          margin: const EdgeInsets.symmetric(
                                              vertical: 6),
                                          decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              color: Colors.grey.shade300,
                                              border: Border.all(
                                                  color: Colors
                                                      .blueGrey.shade100)),
                                          child: Padding(
                                            padding: EdgeInsets.all(
                                                screenHeight * 0.02),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  languageProvider.language ==
                                                          "english"
                                                      ? 'Mark intrested to know more about this event'
                                                      : "इस इवेंट के बारे में अपडेट रहने के लिए इच्छुक पर क्लिक करें",
                                                  style: TextStyle(
                                                      fontSize:
                                                          screenWidth * 0.04,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                                SizedBox(
                                                  height: screenWidth * 0.02,
                                                ),
                                                Row(
                                                  children: [
                                                    const Icon(
                                                      Icons.thumb_up,
                                                      color: Colors.green,
                                                    ),
                                                    SizedBox(
                                                      width: screenWidth * 0.02,
                                                    ),
                                                    Text(
                                                      languageProvider
                                                                  .language ==
                                                              "english"
                                                          ? "${singleEventData?.eventInterested ?? "10"} People Intrested"
                                                          : "${singleEventData?.eventInterested ?? "10"} लोगों ने हाल ही में \nरुचि दिखाई है",
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          fontSize:
                                                              screenWidth *
                                                                  0.04),
                                                    ),
                                                    const Spacer(),
                                                    GestureDetector(
                                                      onTap: () {
                                                        setState(() {
                                                          if (isInterested ==
                                                              1) {
                                                            ScaffoldMessenger
                                                                    .of(context)
                                                                .showSnackBar(
                                                              const SnackBar(
                                                                content: Text(
                                                                    "Already Interested"),
                                                                duration:
                                                                    Duration(
                                                                        seconds:
                                                                            2),
                                                                backgroundColor:
                                                                    Colors
                                                                        .orange,
                                                              ),
                                                            );
                                                          } else {
                                                            interestedEvent(
                                                                singleEventData!
                                                                    .id!);
                                                            isInterested = 1;
                                                            getSingleEventData(
                                                                widget
                                                                    .eventId!);
                                                          }
                                                        });
                                                      },
                                                      child: Container(
                                                        width:
                                                            screenWidth * 0.3,
                                                        height:
                                                            screenHeight * 0.05,
                                                        decoration:
                                                            BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(8),
                                                          gradient: isInterested ==
                                                                  1
                                                              ? LinearGradient(
                                                                  colors: [
                                                                      Colors
                                                                          .green
                                                                          .shade400,
                                                                      Colors
                                                                          .green
                                                                          .shade600
                                                                    ])
                                                              : const LinearGradient(
                                                                  colors: [
                                                                      Colors
                                                                          .white,
                                                                      Color.fromRGBO(
                                                                          239,
                                                                          232,
                                                                          221,
                                                                          1.0)
                                                                    ]),
                                                          boxShadow: [
                                                            BoxShadow(
                                                              color: Colors.grey
                                                                  .withOpacity(
                                                                      0.3),
                                                              spreadRadius: 2,
                                                              blurRadius: 5,
                                                              offset:
                                                                  const Offset(
                                                                      0, 3),
                                                            ),
                                                          ],
                                                          border: Border.all(
                                                              color:
                                                                  isInterested ==
                                                                          1
                                                                      ? Colors
                                                                          .green
                                                                      : Colors
                                                                          .red),
                                                        ),
                                                        child: Center(
                                                          child: Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .center,
                                                            children: [
                                                              Text(
                                                                languageProvider
                                                                            .language ==
                                                                        "english"
                                                                    ? (isInterested ==
                                                                            1
                                                                        ? "Interested"
                                                                        : "Interested")
                                                                    : (isInterested ==
                                                                            1
                                                                        ? "इच्छुक"
                                                                        : "इच्छुक"),
                                                                style:
                                                                    TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  color: isInterested ==
                                                                          1
                                                                      ? Colors
                                                                          .white
                                                                      : Colors
                                                                          .red,
                                                                ),
                                                              ),
                                                              const SizedBox(
                                                                  width: 5),
                                                              isInterested == 1
                                                                  ? const Icon(
                                                                      Icons
                                                                          .check_circle,
                                                                      color: Colors
                                                                          .white,
                                                                      size: 18)
                                                                  : const Icon(
                                                                      Icons
                                                                          .help_outline,
                                                                      color: Colors
                                                                          .red,
                                                                      size: 18),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                    )
                                                  ],
                                                ),
                                              ],
                                            ),
                                          )),

                                      /// Location
                                      Row(
                                        children: [
                                          Icon(Icons.location_on_outlined,
                                              color: Colors.blue,
                                              size: screenWidth * 0.05),
                                          SizedBox(width: screenWidth * 0.02),
                                          Expanded(
                                            child:
                                                Text(
                                                    languageProvider.language ==
                                                            "english"
                                                        ? allVenueData[0]
                                                                .enEventVenue ??
                                                            'N/A'
                                                        : allVenueData[0]
                                                                .hiEventVenue ??
                                                            "N/A",
                                                    style: TextStyle(
                                                        color: Colors.black,
                                                        fontSize:
                                                            screenWidth * 0.04,
                                                        fontWeight:
                                                            FontWeight.w600)),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: screenHeight * 0.01),

                                      /// Event CountDown
                                      singleEventData?.informationalStatus == 0
                                          ? EventCountdownWidget(
                                              eventNextDate: singleEventData
                                                      ?.eventNextDate ??
                                                  "")
                                          : SizedBox(),

                                      /// About Event
                                      Html(
                                        data:
                                            languageProvider.language ==
                                                    "english"
                                                ? singleEventData
                                                        ?.enEventAbout ??
                                                    "N/A"
                                                : singleEventData
                                                        ?.hiEventAbout ??
                                                    "N/A",
                                      ),

                                      /// Event Venue
                                      GestureDetector(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    EventBookingScreen()),
                                          );
                                        },
                                        child: Row(
                                          children: [
                                            Container(
                                              height: 20,
                                              width: 3,
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                color: Colors.blue,
                                              ),
                                            ),
                                            SizedBox(width: screenWidth * 0.02),
                                            Text(
                                              languageProvider.language ==
                                                      "english"
                                                  ? "Multiple Venues"
                                                  : "स्थल का पता",
                                              style: TextStyle(
                                                  color: Colors.black,
                                                  fontSize: screenWidth * 0.05,
                                                  fontWeight: FontWeight.w700),
                                            ),
                                          ],
                                        ),
                                      ),

                                      /// My Venue
                                      Container(
                                        key: _venuesKey,
                                        child: _buildVenuesSection(),
                                      ),
                                      SizedBox(height: screenHeight * 0.01),

                                      /// Arstist Information
                                      Consumer<LanguageProvider>(
                                        builder: (BuildContext context,
                                            languageProvider, Widget? child) {
                                          return Row(
                                            children: [
                                              Container(
                                                height: 20,
                                                width: 3,
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                  color: Colors.blue,
                                                ),
                                              ),
                                              SizedBox(
                                                width: screenWidth * 0.02,
                                              ),
                                              Text(
                                                languageProvider.language ==
                                                        "english"
                                                    ? "Artist, Katha Vachak"
                                                    : "कलाकार, कथा वाचक",
                                                style: TextStyle(
                                                    fontSize:
                                                        screenWidth * 0.05,
                                                    fontWeight:
                                                        FontWeight.w600),
                                              ),
                                            ],
                                          );
                                        },
                                      ),
                                      SizedBox(height: screenHeight * 0.01),

                                      Container(
                                        width: double.infinity,
                                        padding: const EdgeInsets.all(16),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(16),
                                          border: Border.all(
                                              color: Colors.grey.shade300),
                                          boxShadow: const [
                                            BoxShadow(
                                              color: Colors.black12,
                                              blurRadius: 6,
                                              offset: Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        child: Consumer<LanguageProvider>(
                                          builder:
                                              (context, languageProvider, _) {
                                            final artist =
                                                singleEventData?.artist;

                                            // Show loader or empty state if data not available
                                            if (artist == null) {
                                              return const Center(
                                                child: Text(
                                                  "Artist details not available",
                                                  style: TextStyle(
                                                      color: Colors.grey),
                                                ),
                                              );
                                            }

                                            return Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    /// Column 1: Image + Artist Name
                                                    Column(
                                                      children: [
                                                        ClipRRect(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(10),
                                                          child:
                                                              CachedNetworkImage(
                                                            imageUrl:
                                                                artist.image ??
                                                                    "",
                                                            height:
                                                                screenWidth *
                                                                    0.28,
                                                            width: screenWidth *
                                                                0.28,
                                                            fit: BoxFit.cover,
                                                            errorWidget: (context,
                                                                    url,
                                                                    error) =>
                                                                const Icon(
                                                                    Icons
                                                                        .person,
                                                                    size: 50,
                                                                    color: Colors
                                                                        .grey),
                                                            placeholder: (context,
                                                                    url) =>
                                                                const CircularProgressIndicator(),
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                            height: 8),
                                                        SizedBox(
                                                          width: screenWidth *
                                                              0.28,
                                                          child: Html(
                                                            data: languageProvider
                                                                        .language ==
                                                                    "english"
                                                                ? (artist
                                                                        .enArtistName ??
                                                                    "N/A")
                                                                : (artist
                                                                        .hiArtistName ??
                                                                    "N/A"),
                                                            style: {
                                                              "body": Style(
                                                                fontSize:
                                                                    FontSize(
                                                                        14),
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                color: Colors
                                                                    .orange
                                                                    .shade800,
                                                                textAlign:
                                                                    TextAlign
                                                                        .center,
                                                                maxLines: 1,
                                                                textOverflow:
                                                                    TextOverflow
                                                                        .ellipsis,
                                                              ),
                                                            },
                                                          ),
                                                        ),
                                                      ],
                                                    ),

                                                    const SizedBox(width: 16),

                                                    /// Column 2: Profession + Description
                                                    Expanded(
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Html(
                                                            data: languageProvider
                                                                        .language ==
                                                                    "english"
                                                                ? (artist
                                                                        .enProfession ??
                                                                    "N/A")
                                                                : (artist
                                                                        .hiProfession ??
                                                                    "N/A"),
                                                            style: {
                                                              "body": Style(
                                                                fontSize:
                                                                    FontSize(
                                                                        14),
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500,
                                                                color: Colors
                                                                    .black87,
                                                                maxLines: 1,
                                                                textOverflow:
                                                                    TextOverflow
                                                                        .ellipsis,
                                                                margin: Margins
                                                                    .only(
                                                                        bottom:
                                                                            6),
                                                              ),
                                                            },
                                                          ),
                                                          Html(
                                                            data: languageProvider
                                                                        .language ==
                                                                    "english"
                                                                ? (artist
                                                                        .enDescription ??
                                                                    "N/A")
                                                                : (artist
                                                                        .hiDescription ??
                                                                    "N/A"),
                                                            style: {
                                                              "body": Style(
                                                                fontSize:
                                                                    FontSize(
                                                                        13),
                                                                color: Colors
                                                                    .grey
                                                                    .shade800,
                                                                maxLines: 4,
                                                                textOverflow:
                                                                    TextOverflow
                                                                        .ellipsis,
                                                              ),
                                                            },
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            );
                                          },
                                        ),
                                      ),

                                      /// Terms And Condition
                                      SizedBox(height: screenHeight * 0.02),
                                      GestureDetector(
                                        onTap: () {
                                          showModalBottomSheet(
                                            context: context,
                                            shape: const RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.vertical(
                                                      top: Radius.circular(
                                                          20.0)),
                                            ),
                                            clipBehavior: Clip.antiAlias,
                                            backgroundColor: Colors.white,
                                            elevation: 10,
                                            isScrollControlled: true,
                                            builder: (context) =>
                                                SingleChildScrollView(
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 20,
                                                        vertical: 16),
                                                child: Column(
                                                  children: [
                                                    // Drag handle
                                                    Container(
                                                      width: 40,
                                                      height: 4,
                                                      decoration: BoxDecoration(
                                                        color: Colors
                                                            .grey.shade300,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(4),
                                                      ),
                                                    ),
                                                    const SizedBox(height: 16),

                                                    // Title
                                                    Row(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .center,
                                                      children: [
                                                        const Icon(Icons.policy,
                                                            color:
                                                                Colors.blue),
                                                        const SizedBox(
                                                            width: 10),
                                                        Expanded(
                                                          child: Text(
                                                            languageProvider
                                                                        .language ==
                                                                    "english"
                                                                ? "Terms & Conditions"
                                                                : "नियम एवं शर्तें",
                                                            style:
                                                                const TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              fontSize: 18,
                                                              color:
                                                                  Colors.black,
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    const SizedBox(height: 16),

                                                    // T&C HTML
                                                    Html(
                                                      data: languageProvider
                                                                  .language ==
                                                              "english"
                                                          ? singleEventData
                                                                  ?.enEventTeamCondition ??
                                                              "N/A"
                                                          : singleEventData
                                                                  ?.hiEventTeamCondition ??
                                                              "N/A",
                                                      style: {
                                                        "body": Style(
                                                          fontSize:
                                                              FontSize(15),
                                                          color: Colors
                                                              .grey.shade800,
                                                          lineHeight:
                                                              LineHeight.number(
                                                                  1.6),
                                                          textAlign:
                                                              TextAlign.justify,
                                                        ),
                                                      },
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                        child: Container(
                                          width: screenWidth * 0.93,
                                          height: screenHeight * 0.05,
                                          padding: EdgeInsets.symmetric(
                                              horizontal: screenWidth * 0.04),
                                          margin: const EdgeInsets.symmetric(
                                              vertical: 10),
                                          decoration: BoxDecoration(
                                            color: Colors.blue.shade50,
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.grey
                                                    .withOpacity(0.1),
                                              ),
                                            ],
                                          ),
                                          child: Row(
                                            children: [
                                              Container(
                                                padding:
                                                    const EdgeInsets.all(6),
                                                decoration: BoxDecoration(
                                                  color: Colors.blue.shade100,
                                                  shape: BoxShape.circle,
                                                ),
                                                child: Icon(
                                                    Icons.policy_rounded,
                                                    color: Colors.blue,
                                                    size: screenWidth * 0.05),
                                              ),
                                              const SizedBox(width: 12),
                                              Expanded(
                                                child: Text(
                                                  languageProvider.language ==
                                                          "english"
                                                      ? 'Terms & Conditions'
                                                      : "नियम एवं शर्तें",
                                                  style: TextStyle(
                                                    fontSize:
                                                        screenWidth * 0.043,
                                                    fontWeight: FontWeight.w600,
                                                    color: Colors.black,
                                                  ),
                                                ),
                                              ),
                                              Icon(
                                                  Icons
                                                      .arrow_forward_ios_rounded,
                                                  size: screenWidth * 0.04,
                                                  color: Colors.blue),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              ),

                              /// You Might Also Like This
                              Consumer<LanguageProvider>(
                                builder: (BuildContext context,
                                    languageProvider, Widget? child) {
                                  return Row(
                                    children: [
                                      Container(
                                        height: 20,
                                        width: 3,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          color: Colors.blue,
                                        ),
                                      ),
                                      SizedBox(
                                        width: screenWidth * 0.02,
                                      ),
                                      Text(
                                        languageProvider.language == "english"
                                            ? 'You might also like'
                                            : "आप इसे भी पसंद कर सकते हैं",
                                        style: TextStyle(
                                            fontSize: screenWidth * 0.05,
                                            fontWeight: FontWeight.w600),
                                      ),
                                    ],
                                  );
                                },
                              ),
                              singleEventData?.remainingEvent == null
                                  ? SizedBox()
                                  : SizedBox(
                                      height: screenHeight *
                                          0.35, // Height for ListView
                                      child: ListView.builder(
                                        padding: EdgeInsets.zero,
                                        physics:
                                            const AlwaysScrollableScrollPhysics(),
                                        scrollDirection: Axis.horizontal,
                                        itemCount: singleEventData
                                            ?.remainingEvent.length,
                                        itemBuilder: (context, index) {
                                          var event = singleEventData
                                              ?.remainingEvent[index];

                                          // Ensure allVenueData is not empty
                                          bool hasVenueData =
                                              event!.venueData.isNotEmpty;
                                          var venueData = hasVenueData
                                              ? event?.venueData[0]
                                              : null;

                                          dateFormatter(
                                              event?.startToEndDate ?? '');

                                          int venueLength =
                                              event!.venueData.length;
                                          return GestureDetector(
                                            onTap: () {
                                              getSingleEventData(
                                                  int.parse("${event?.id}"));
                                            },
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 8),
                                              child: Container(
                                                width: screenWidth * 0.8,
                                                decoration: BoxDecoration(
                                                  border: Border.all(
                                                      color:
                                                          const Color.fromRGBO(
                                                              231,
                                                              231,
                                                              231,
                                                              1)),
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                ),
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    SizedBox(
                                                      width: double.infinity,
                                                      height:
                                                          screenHeight * 0.15,
                                                      child: Stack(
                                                        children: [
                                                          // Event Image with Rounded Corners
                                                          ClipRRect(
                                                            borderRadius:
                                                                const BorderRadius
                                                                    .vertical(
                                                                    top: Radius
                                                                        .circular(
                                                                            12)),
                                                            child:
                                                                CachedNetworkImage(
                                                              imageUrl: event
                                                                      ?.eventImage ??
                                                                  "",
                                                              fit: BoxFit.cover,
                                                              width: double
                                                                  .infinity,
                                                              height: double
                                                                  .infinity,
                                                              errorWidget: (context,
                                                                      url,
                                                                      error) =>
                                                                  const Icon(Icons
                                                                      .broken_image),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    SizedBox(
                                                        height: screenHeight *
                                                            0.00),
                                                    Padding(
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                              horizontal:
                                                                  screenWidth *
                                                                      0.03),
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          SizedBox(
                                                            width: screenWidth *
                                                                0.6,
                                                            child: Consumer<
                                                                LanguageProvider>(
                                                              builder: (context,
                                                                  languageProvider,
                                                                  child) {
                                                                return Text(
                                                                  languageProvider
                                                                              .language ==
                                                                          "english"
                                                                      ? event?.enEventName ??
                                                                          "Event Name"
                                                                      : event?.hiEventName ??
                                                                          "घटना नाम",
                                                                  style:
                                                                      TextStyle(
                                                                    fontSize:
                                                                        screenWidth *
                                                                            0.05,
                                                                    color: Colors
                                                                        .black87,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w500,
                                                                    overflow:
                                                                        TextOverflow
                                                                            .ellipsis,
                                                                  ),
                                                                  textAlign:
                                                                      TextAlign
                                                                          .start,
                                                                  maxLines: 1,
                                                                );
                                                              },
                                                            ),
                                                          ),
                                                          SizedBox(
                                                              height:
                                                                  screenHeight *
                                                                      0.005),
                                                          Consumer<
                                                              LanguageProvider>(
                                                            builder: (context,
                                                                languageProvider,
                                                                child) {
                                                              return Text.rich(
                                                                maxLines: 3,
                                                                TextSpan(
                                                                  children: [
                                                                    TextSpan(
                                                                      text: languageProvider.language ==
                                                                              "english"
                                                                          ? "Start Date: "
                                                                          : "आरंभ करने की तिथि: ",
                                                                      style:
                                                                          TextStyle(
                                                                        fontWeight:
                                                                            FontWeight.bold,
                                                                        color: Colors
                                                                            .blue,
                                                                        fontSize:
                                                                            screenWidth *
                                                                                0.04,
                                                                      ),
                                                                    ),
                                                                    TextSpan(
                                                                      text: formatDateString(
                                                                          "${event.venueData[0].date}"),
                                                                      style: const TextStyle(
                                                                          fontWeight:
                                                                              FontWeight.w400),
                                                                    ),
                                                                    TextSpan(
                                                                      text:
                                                                          "\n${languageProvider.language == "english" ? "Start Time: " : "समय: "}",
                                                                      style:
                                                                          TextStyle(
                                                                        fontWeight:
                                                                            FontWeight.bold,
                                                                        color: Colors
                                                                            .blue,
                                                                        fontSize:
                                                                            screenWidth *
                                                                                0.04,
                                                                      ),
                                                                    ),
                                                                    TextSpan(
                                                                      text: hasVenueData
                                                                          ? venueData
                                                                              ?.startTime
                                                                          : "No Time",
                                                                      style: const TextStyle(
                                                                          fontWeight:
                                                                              FontWeight.w400),
                                                                    ),
                                                                    TextSpan(
                                                                      text:
                                                                          "\n${languageProvider.language == "english" ? "Venue: " : "स्थान: "}",
                                                                      style:
                                                                          TextStyle(
                                                                        fontWeight:
                                                                            FontWeight.bold,
                                                                        color: Colors
                                                                            .blue,
                                                                        fontSize:
                                                                            screenWidth *
                                                                                0.04,
                                                                      ),
                                                                    ),
                                                                    TextSpan(
                                                                      text: hasVenueData
                                                                          ? (languageProvider.language == "english"
                                                                              ? venueData!.enEventVenue ?? "No Venue"
                                                                              : venueData!.hiEventVenue ?? "कोई स्थान नहीं")
                                                                          : "No Venue",
                                                                      style: const TextStyle(
                                                                          fontWeight:
                                                                              FontWeight.w400),
                                                                    ),
                                                                    venueLength >
                                                                            1
                                                                        ? TextSpan(
                                                                            text: languageProvider.language == "english"
                                                                                ? " + ${venueLength - 1} More Venues"
                                                                                : " + ${venueLength - 1} अधिक स्थान",
                                                                            style:
                                                                                const TextStyle(fontWeight: FontWeight.w400),
                                                                          )
                                                                        : const TextSpan(),
                                                                  ],
                                                                ),
                                                              );
                                                            },
                                                          ),
                                                          Padding(
                                                            padding: EdgeInsets
                                                                .symmetric(
                                                                    horizontal:
                                                                        screenWidth *
                                                                            0.0001),
                                                            child: SizedBox(
                                                              height:
                                                                  screenHeight *
                                                                      0.05,
                                                              child: Consumer<
                                                                  LanguageProvider>(
                                                                builder: (context,
                                                                    languageProvider,
                                                                    child) {
                                                                  return event!
                                                                          .venueData
                                                                          .isNotEmpty
                                                                      ? (event!
                                                                              .venueData[0]
                                                                              .packageList
                                                                              .isNotEmpty
                                                                          ? Container(
                                                                              width: double.infinity,
                                                                              padding: const EdgeInsets.symmetric(horizontal: 20),
                                                                              decoration: BoxDecoration(
                                                                                borderRadius: BorderRadius.circular(5),
                                                                                color: Colors.blue.shade300,
                                                                                boxShadow: [
                                                                                  BoxShadow(
                                                                                    color: Colors.black.withOpacity(0.2),
                                                                                    spreadRadius: 2,
                                                                                    blurRadius: 5,
                                                                                    offset: const Offset(0, 3),
                                                                                  ),
                                                                                ],
                                                                              ),
                                                                              child: Padding(
                                                                                padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.02, vertical: screenWidth * 0.02),
                                                                                child: Row(
                                                                                  children: [
                                                                                    // Check if the package list is not empty
                                                                                    // Display price
                                                                                    Text(
                                                                                      venueData!.packageList[0].priceNo == "0"
                                                                                          ? "Free"
                                                                                          : languageProvider.language == "english"
                                                                                              ? "Rs : ${venueData!.packageList[0].priceNo ?? "N/A"}"
                                                                                              : "₹ : ${venueData!.packageList[0].priceNo ?? "N/A"}",
                                                                                      style: const TextStyle(fontWeight: FontWeight.w600),
                                                                                    ),
                                                                                    const Spacer(),
                                                                                    const Text('|', style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
                                                                                    SizedBox(width: screenWidth * 0.02),
                                                                                    // Display "Book now" button
                                                                                    Text(
                                                                                      languageProvider.language == "english" ? "Book now" : "अभी बुक करें",
                                                                                      style: const TextStyle(fontWeight: FontWeight.bold),
                                                                                    ),
                                                                                  ],
                                                                                ),
                                                                              ),
                                                                            )
                                                                          : Container(
                                                                              width: double.infinity,
                                                                              padding: const EdgeInsets.symmetric(horizontal: 20),
                                                                              decoration: BoxDecoration(
                                                                                borderRadius: BorderRadius.circular(5),
                                                                                color: Colors.blue.shade300,
                                                                                boxShadow: [
                                                                                  BoxShadow(
                                                                                    color: Colors.black.withOpacity(0.2),
                                                                                    spreadRadius: 2,
                                                                                    blurRadius: 5,
                                                                                    offset: const Offset(0, 3),
                                                                                  ),
                                                                                ],
                                                                              ),
                                                                              child: Center(
                                                                                child: Padding(
                                                                                  padding: const EdgeInsets.all(5),
                                                                                  child: Text(
                                                                                    languageProvider.language == "english" ? "Know about the Event" : "जानिए इवेंट के बारे में",
                                                                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                            ))
                                                                      : Container(
                                                                          width:
                                                                              double.infinity,
                                                                          padding: const EdgeInsets
                                                                              .symmetric(
                                                                              horizontal: 20),
                                                                          decoration:
                                                                              BoxDecoration(
                                                                            borderRadius:
                                                                                BorderRadius.circular(5),
                                                                            color:
                                                                                Colors.blue.shade300,
                                                                            boxShadow: [
                                                                              BoxShadow(
                                                                                color: Colors.black.withOpacity(0.2),
                                                                                spreadRadius: 2,
                                                                                blurRadius: 5,
                                                                                offset: const Offset(0, 3),
                                                                              ),
                                                                            ],
                                                                          ),
                                                                          child:
                                                                              Center(
                                                                            child:
                                                                                Padding(
                                                                              padding: const EdgeInsets.all(5),
                                                                              child: Text(
                                                                                languageProvider.language == "english" ? "Know about the Event" : "जानिए इवेंट के बारे में",
                                                                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                                                              ),
                                                                            ),
                                                                          ),
                                                                        );
                                                                },
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
                                        },
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

                              /// Reviews Section
                              _isReveiwLoading
                                  ? const SizedBox()
                                  : (commentList != null &&
                                          commentList!.data.isNotEmpty
                                      ? Consumer<LanguageProvider>(
                                          builder: (BuildContext context,
                                              languageProvider, Widget? child) {
                                            return Column(
                                              children: [
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.all(10),
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
                                                        languageProvider
                                                                    .language ==
                                                                "english"
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
                                                            languageProvider
                                                                        .language ==
                                                                    "english"
                                                                ? "See All"
                                                                : "सभी देखें",
                                                            style: const TextStyle(
                                                                color: Colors
                                                                    .orange,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                fontSize: 14),
                                                          )),
                                                    ],
                                                  ),
                                                ),
                                                Padding(
                                                  padding: const EdgeInsets.all(
                                                      15.0),
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        languageProvider
                                                                    .language ==
                                                                "english"
                                                            ? "Ratings and reviews below are from real users who booked this event on their device."
                                                            : "नीचे दी गई रेटिंग और समीक्षाएं उन्हीं उपयोगकर्ताओं की हैं जिन्होंने इस इवेंट को अपने मोबाइल से बुक किया है।",
                                                        style: const TextStyle(
                                                            fontWeight:
                                                                FontWeight
                                                                    .w500),
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
                                                                    rating: double.parse(commentList!
                                                                        .eventStar
                                                                        .toString())),
                                                                // Text(
                                                                //   "${commentList!.recode!}00",
                                                                //   style: Theme.of(context).textTheme.bodySmall,
                                                                // ),

                                                                const SizedBox(
                                                                  height: 10,
                                                                ),
                                                              ],
                                                            )
                                                          : const CircularProgressIndicator(),

                                                      // Show only top 5 comments
                                                      ...commentList!.data.take(5).map((comment) => Container(
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
                                                          child: EventUserReviewCard(
                                                              comment: comment))),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            );
                                          },
                                        )
                                      : Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Container(
                                              margin:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 16,
                                                      vertical: 24),
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
                                                    color:
                                                        Colors.blue.shade400,
                                                    size: 48,
                                                  ),
                                                  const SizedBox(height: 12),
                                                  const Text(
                                                    "No Reviews Yet!",
                                                    style: TextStyle(
                                                      fontSize: 18,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.black87,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 8),
                                                  Text(
                                                    "Be the first one to share your thoughts.",
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                      color:
                                                          Colors.grey.shade600,
                                                    ),
                                                    textAlign: TextAlign.center,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        )),

                              Container(
                                color: Colors.blue.shade100,
                                width: double.infinity,
                                height: 5,
                              ),

                              /// FAQ's
                              const SizedBox(
                                height: 10,
                              ),
                              // Consumer<LanguageProvider>(
                              //   builder: (BuildContext context,
                              //       languageProvider, Widget? child) {
                              //     return Askquestions(
                              //         type: 'event',
                              //         translateEn:
                              //             languageProvider.language == "english"
                              //                 ? "en"
                              //                 : "hi");
                              //   },
                              // ),
                              const SizedBox(
                                height: 80,
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

        /// Floating Action Button
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: isLoading == false
            ? (singleEventData?.informationalStatus == 0
                ? Consumer<LanguageProvider>(
                    builder: (BuildContext context, languageProvider,
                        Widget? child) {
                      return InkWell(
                        onTap: (){
                          if (_selectedVenueIndex == -1) {
                            _scrollToVenues();
                          } else {
                            /// Navigate booking
                            Navigator.push(
                              context,
                              CupertinoPageRoute(
                                builder: (context) => EventSummery(
                                  eventVenue: venueSelected,
                                  eventhiVenue: venuehindiSelected,
                                  eventId: singleEventData!.id!,
                                  venueId: venueId,
                                  eventName: singleEventData?.enEventName,
                                  aadharStatus: "${singleEventData?.aadharStatus ?? '0'}",
                                  //aadharStatus: "0",
                                ),
                              ),
                            );
                          }
                        },
                      child: Container(
                          width: double.infinity,
                          height: 55,
                          padding: const EdgeInsets.symmetric(horizontal: 15),
                          margin: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: Colors.blue,
                              boxShadow: [
                                BoxShadow(
                                  color:
                                      const Color(0xFF000000).withOpacity(0.3),
                                  blurRadius: 10,
                                  spreadRadius: 2,
                                  offset: const Offset(0, 4),
                                )
                              ]),
                          child: Center(
                            child: Row(
                              children: [
                                Text(
                                  _selectedVenueIndex != -1
                                      ? (languageProvider.language == "english"
                                      ? "BOOK NOW"
                                      : "अभी बुक करें")
                                      : (languageProvider.language == "english"
                                      ? "SELECT VENUE"
                                      : "स्थान चुनें"),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    fontSize: 20,
                                  ),
                                ),
                                const Spacer(),
                                Icon(
                                  _selectedVenueIndex != -1
                                      ? Icons.check_circle_outline
                                      : Icons.swipe_up_outlined,
                                  color: Colors.white,
                                  size: 20,
                                )
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  )
                : Container())
            : Container());
  }

  Widget _buildVenuesSection() {
    if (allVenueData.isEmpty) return SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        SizedBox(height: 12),

        SizedBox(
          height: 80,
          child: Row(
            children: [

              /// Horizontal Venue List
              Expanded(
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.only(left: 16),
                  itemCount: allVenueData.length,
                  itemBuilder: (context, index) {

                    final venue = allVenueData[index];
                    bool isSelected = _selectedVenueIndex == index;

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedVenueIndex = index;
                          venueId = venue.id;
                          venueSelected = venue.enEventVenue;
                          venuehindiSelected = venue.hiEventVenue;
                        });
                      },
                      child: _buildVenueCard(
                          venue,
                          isSelected,
                          index
                      ),
                    );
                  },
                ),
              ),
              if(allVenueData.length > 1)

              /// SEE ALL BUTTON
              Container(
                width: 60,
                margin: EdgeInsets.symmetric(horizontal: 10),
                child: _buildSeeAllButton(),
              ),
            ],
          ),
        ),
      ],
    );
  }
  Widget _buildVenueCard(
      EventAllVenueData venue,
      bool isSelected,
      int index,
      ) {
    return Container(
      width: 200,
      margin: EdgeInsets.only(right: 8),
      decoration: BoxDecoration(
        color: isSelected ? Colors.blue.shade50 : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isSelected
              ? Colors.blue
              : Colors.grey.shade200,
          width: isSelected ? 2 : 1,
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            Row(
              children: [
                Icon(
                  Icons.location_city_outlined,
                  size: 16,
                  color: Colors.blue,
                ),

                SizedBox(width: 8),

                Expanded(
                  child: Text(
                    venue.enEventCities ?? "",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            SizedBox(height: 6),

            Row(
              children: [

                Icon(
                  Icons.place_outlined,
                  size: 14,
                  color: Colors.grey,
                ),

                SizedBox(width: 8),

                Expanded(
                  child: Text(
                    venue.enEventState ?? "",
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),

          ],
        ),
      ),
    );
  }
  Widget _buildSeeAllButton() {
    return GestureDetector(
      onTap: () {
        _showVenuesBottomSheet();
      },
      child: Container(
        height: 115,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.blue,
              Colors.blueAccent,
            ],
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [

              Icon(
                Icons.apps_outlined,
                color: Colors.white,
              ),

              SizedBox(height: 4),

              Text(
                "See All",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),

              Text(
                "Venues",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  void _showVenuesBottomSheet() {

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {

        return Container(
          height: MediaQuery.of(context).size.height * 0.85,

          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(30),
            ),
          ),

          child: Column(
            children: [

              /// Drag Handle
              SizedBox(height: 10),

              Container(
                width: 40,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),

              SizedBox(height: 10),

              /// Header
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [

                    Text(
                      "Select Venue",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Container(
                        padding: EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.close,
                          size: 18,
                        ),
                      ),
                    )

                  ],
                ),
              ),

              Divider(),

              /// Grid List
              Expanded(
                child: GridView.builder(
                  padding: EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10
                  ),

                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 1.6,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),

                  itemCount: allVenueData.length,

                  itemBuilder: (context, index) {

                    final venue = allVenueData[index];
                    bool isSelected = _selectedVenueIndex == index;

                    return GestureDetector(

                      onTap: () {
                        setState(() {
                          _selectedVenueIndex = index;
                          venueId = venue.id;
                          venueSelected = venue.enEventVenue;
                          venuehindiSelected = venue.hiEventVenue;
                        });
                        Navigator.pop(context);
                      },

                      child: AnimatedContainer(

                        duration: Duration(milliseconds: 300),

                        decoration: BoxDecoration(

                          color: isSelected
                              ? Colors.blue.shade50
                              : Colors.white,

                          borderRadius: BorderRadius.circular(18),

                          border: Border.all(
                            color: isSelected
                                ? Colors.blue
                                : Colors.grey.shade200,
                            width: isSelected ? 2 : 1,
                          ),

                          boxShadow: [

                            if (!isSelected)
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 6,
                                offset: Offset(0,3),
                              )

                          ],
                        ),

                        child: Padding(
                          padding: EdgeInsets.all(12),

                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [

                              Row(
                                children: [

                                  Icon(
                                    Icons.location_city_outlined,
                                    size: 16,
                                    color: Colors.blue,
                                  ),

                                  SizedBox(width: 6),

                                  Expanded(
                                    child: Text(
                                      venue.enEventCities ?? "",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),

                                ],
                              ),
                              SizedBox(height: 3),

                              Row(
                                children: [

                                  Icon(
                                    Icons.place_outlined,
                                    size: 14,
                                    color: Colors.grey,
                                  ),

                                  SizedBox(width: 6),

                                  Expanded(
                                    child: Text(
                                      venue.enEventState ?? "",
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.grey.shade600,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),

                                ],
                              ),

                              if (isSelected)
                                Padding(
                                  padding: EdgeInsets.only(top: 3),
                                  child: Row(
                                    children: [

                                      Icon(
                                        Icons.check_circle,
                                        color: Colors.blue,
                                        size: 16,
                                      ),

                                      SizedBox(width: 5),

                                      Text(
                                        "Selected",
                                        style: TextStyle(
                                          color: Colors.blue,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      )

                                    ],
                                  ),
                                )
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class EventCountdownWidget extends StatefulWidget {
  final String? eventNextDate; // API से आने वाली date string

  const EventCountdownWidget({super.key, this.eventNextDate});

  @override
  State<EventCountdownWidget> createState() => _EventCountdownWidgetState();
}

class _EventCountdownWidgetState extends State<EventCountdownWidget> {
  DateTime? eventDateTime;
  String dateforTimer = "";
  Duration? timeRemaining;

  int days = 0, hours = 0, minutes = 0, seconds = 0;
  bool isCountingDown = false;

  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _parseEventDate();

    print("Event Booking Closed Date and Time : ${widget.eventNextDate}");
  }

  /// Parse event date from API
  void _parseEventDate() {
    final startToEndDate = widget.eventNextDate;

    if (startToEndDate != null && startToEndDate.isNotEmpty) {
      try {
        if (startToEndDate.contains("AM") || startToEndDate.contains("PM")) {
          // Example: 2025-09-23 02:00 PM
          eventDateTime =
              DateFormat("yyyy-MM-dd hh:mm a").parse(startToEndDate);
        } else {
          // Example: 2025-09-23
          eventDateTime = DateFormat("yyyy-MM-dd").parse(startToEndDate);
        }

        // सिर्फ display के लिए formatted string
        dateforTimer = DateFormat('dd MMM yyyy hh:mm a').format(eventDateTime!);

        isCountingDown = true;
        updateCountdown();
        _updateCountdownEverySecond();
      } catch (e) {
        print("Date parse error: $e");
        dateforTimer = 'No Start Date';
        isCountingDown = false;
      }
    }
  }

  /// Update countdown logic
  void updateCountdown() {
    if (!isCountingDown || eventDateTime == null) {
      timeRemaining = null;
      return;
    }

    DateTime now = DateTime.now();
    Duration diff = eventDateTime!.difference(now);

    if (diff.isNegative) {
      setState(() {
        timeRemaining = Duration.zero;
        isCountingDown = false;
      });
    } else {
      setState(() {
        timeRemaining = diff;
        days = timeRemaining!.inDays;
        hours = timeRemaining!.inHours % 24;
        minutes = timeRemaining!.inMinutes % 60;
        seconds = timeRemaining!.inSeconds % 60;
      });
    }
  }

  /// Auto update every second
  void _updateCountdownEverySecond() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      updateCountdown();
      if (!isCountingDown) timer.cancel();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  /// Small countdown box widget
  Widget _buildCountdownBox(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color.fromRGBO(255, 238, 211, 1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style:
            const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (timeRemaining == null || timeRemaining == Duration.zero) ...[
          Text(
            "Event booking closed",
            style: const TextStyle(
              color: Colors.red,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ] else ...[
          // Date info
          Row(
            children: [
              const Icon(Icons.calendar_month_outlined,
                  color: Colors.blue, size: 20),
              const SizedBox(width: 6),
              Text.rich(
                TextSpan(
                  children: [
                    const TextSpan(
                        text: "Booking will close on: ",
                        style: TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 14)),
                    TextSpan(
                        text: dateforTimer,
                        style: const TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                            fontSize: 15)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Countdown boxes
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildCountdownBox('$days Days'),
              const Text(" : "),
              _buildCountdownBox('$hours Hours'),
              const Text(" : "),
              _buildCountdownBox('$minutes Mins'),
              const Text(" : "),
              _buildCountdownBox('$seconds Sec'),
            ],
          ),
        ],
      ],
    );
  }
}
