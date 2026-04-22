import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../../data/datasource/remote/http/httpClient.dart';
import '../../../../utill/app_constants.dart';
import '../../../../utill/flutter_toast_helper.dart';
import '../../../auth/controllers/auth_controller.dart';
import '../../../tour_and_travells/Controller/lanaguage_provider.dart';
import '../../model/banners_model.dart';
import '../../model/subCategory_model.dart';
import '../SeeScreen.dart';
import '../event_details.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:carousel_slider/carousel_slider.dart';

class AllEventScreen extends StatefulWidget {
  final ScrollController scrollController;
  const AllEventScreen({
    super.key,
    required this.scrollController,
  });

  @override
  State<AllEventScreen> createState() => _AllEventScreenState();
}

class _AllEventScreenState extends State<AllEventScreen> {
  bool isLoading = false;
  int _currentIndex = 0;

  // Default values
  String startDate = 'No Start Date';
  String endDate = 'No End Date';
  String fullDate = 'No Date';
  String singleDate = 'No Single Date';

  @override
  void initState() {
    super.initState();
    getEventSubCategory();
    getSunderKandData(10, 6);
    getBanners();
  }

  List<SubData> eventSubCategory = [];
  List<SubData> sunderKandData = [];
  List<SubData> nearbyEvents = [];
  List<SubData> satsangData = [];
  List<SubData> inHouseData = [];

  List<BannersModel> imageList = [];
  List<BannersModel> imageBanner = [];

  /// Fetch Event SubCategory(AllData, NearByData, InhouseData)
  Future<void> getEventSubCategory() async {
    String endpoint = AppConstants.eventSubCategoryUrl;

    Map<String, dynamic> alldata = {
      "category_id": [],
      "venue_data": [],
      "price": [],
      "language": [],
      "organizer": [],
      "upcoming": 1,
    };

    Map<String, dynamic> nearData = {
      "category_id": [],
      "venue_data": [],
      "price": [],
      "language": [],
      "organizer": [],
      "upcoming": 1,
      // "latitude": Provider.of<AuthController>(context, listen: false).latitude,
      // "longitude": Provider.of<AuthController>(context, listen: false).longitude,
    };

    Map<String, dynamic> inhouseData = {
      "category_id": [],
      "venue_data": [],
      "price": [],
      "language": [],
      "organizer": ["inhouse"],
      "upcoming": 1,
      // "latitude": Provider.of<AuthController>(context, listen: false).latitude,
      // "longitude": Provider.of<AuthController>(context, listen: false).longitude,
    };

    setState(() {
      isLoading = true;
    });

    try {
      final res = await Future.wait([
        HttpService().postApi(endpoint, alldata),
        HttpService().postApi(endpoint, nearData),
        HttpService().postApi(endpoint, inhouseData),
      ]);

      print("My All Data: $res");
      print(
          "My lat: ${Provider.of<AuthController>(context, listen: false).latitude}");
      print(
          "My long: ${Provider.of<AuthController>(context, listen: false).longitude}");

      if (res[0] != null || res[1] != null || res[2] != null) {
        final subCategoryData = SubCategoryModel.fromJson(res[0]);
        final nearbyData = SubCategoryModel.fromJson(res[1]);
        final inhouse = SubCategoryModel.fromJson(res[2]);

        print("Near Events response: $nearbyData");

        setState(() {
          eventSubCategory = subCategoryData.data ?? [];
          nearbyEvents = nearbyData.data ?? [];
          inHouseData = inhouse.data ?? [];

          print("Total SubCategory: ${eventSubCategory.length}");
          print("Total Nearby: ${nearbyEvents.length}");
          print("Total InHouse: ${inHouseData.length}");
        });
      }
    } catch (e) {
      print("Error Occurring: $e");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void dateFormatter(String startToEndDate) {
    // String? startToEndDate = event.startToEndDate;

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

  /// Fetch SunderKandData and SatsangData
  Future<void> getSunderKandData(int categoryId1, int categoryId2) async {
    String endpoint = AppConstants.eventSubCategoryUrl;

    Map<String, dynamic> data1 = {
      "category_id": [categoryId1],
      "venue_data": [],
      "price": [],
      "language": [],
      "organizer": [],
      "upcoming": 1,
    };

    Map<String, dynamic> data2 = {
      "category_id": [categoryId2],
      "venue_data": [],
      "price": [],
      "language": [],
      "organizer": [],
      "upcoming": 1,
    };

    setState(() {
      isLoading = true;
    });

    try {
      final responses = await Future.wait([
        HttpService().postApi(endpoint, data1),
        HttpService().postApi(endpoint, data2),
      ]);

      if (responses[0] != null) {
        final sunderKandData1 = SubCategoryModel.fromJson(responses[0]);
        setState(() {
          sunderKandData.addAll(sunderKandData1.data ?? []);
          print("Total Sunder Kand data items: ${sunderKandData.length}");
        });
      }

      if (responses[1] != null) {
        final mysatsangData = SubCategoryModel.fromJson(responses[1]);
        setState(() {
          satsangData.addAll(mysatsangData.data ?? []);
          print("Total Satsang data items: ${satsangData.length}");
        });
      }
    } catch (e) {
      print("Error fetching data: $e");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  /// Fetch Event Banners
  Future<void> getBanners() async {
    setState(() {
      isLoading = true;
    });

    try {
      final res = await HttpService().getApi(AppConstants.eventBannersUrl);
      print(res);

      // Parse List<dynamic> to List<BannersModel>
      setState(() {
        imageBanner = (res as List<dynamic>)
            .map((json) => BannersModel.fromJson(json as Map<String, dynamic>))
            .toList();

        imageList = imageBanner
            .where((banner) => banner.bannerType == "Events Banner")
            .toList();
      });

      print("My Banner Data Is ${imageBanner.length}");
    } catch (e) {
      print("Event Banner error$e");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var screenHeight = MediaQuery.of(context).size.height;
    var screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
        backgroundColor: Colors.white,
        body: isLoading
            ? const Center(
                child: CircularProgressIndicator(
                color: Colors.orange,
              ))
            : SafeArea(
                child: SingleChildScrollView(
                  controller: widget.scrollController,
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /// Slider and its indicater
                      imageList.isNotEmpty
                          ? CarouselSlider(
                              options: CarouselOptions(
                                viewportFraction: 1,
                                height: 250.0,
                                enableInfiniteScroll: true,
                                animateToClosest: true,
                                autoPlay: true,
                                autoPlayAnimationDuration:
                                    const Duration(milliseconds: 500),
                                onPageChanged: (index, reason) {
                                  setState(() {
                                    _currentIndex = index;
                                  });
                                },
                              ),
                              items: imageList.map((i) {
                                return Builder(
                                  builder: (BuildContext context) {
                                    return SizedBox(
                                      width: double.infinity,
                                      child: ClipRRect(
                                        child: Image.network(
                                          "${AppConstants.baseUrl}/storage/app/public/banner/${i.photo}",
                                          fit: BoxFit.fill,
                                          errorBuilder:
                                              (context, error, stackTrace) =>
                                                  Container(
                                            color: Colors.grey[300],
                                            // Placeholder background color
                                            child: const Center(
                                              child: Icon(Icons.broken_image,
                                                  size: 24,
                                                  color: Colors
                                                      .grey), // Error Icon
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                );
                              }).toList(),
                            )
                          : const SizedBox(),
                      SizedBox(
                        height: screenHeight * 0.01,
                      ),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          for (int i = 0; i < imageList.length; i++)
                            Container(
                              width: 8,
                              height: 8,
                              margin: const EdgeInsets.symmetric(horizontal: 2),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: _currentIndex == i
                                    ? Colors.red
                                    : Colors.grey,
                              ),
                            ),
                        ],
                      ),
                      SizedBox(
                        height: screenHeight * 0.01,
                      ),

                      /// Near By Events shows with listviewBuilder
                      nearbyEvents.isNotEmpty
                          ? Column(children: [
                              Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: screenWidth * 0.02),
                                child: Row(
                                  children: [
                                    Container(
                                      height: 24,
                                      width: screenWidth * 0.01,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(5),
                                        color: Colors.orange,
                                      ),
                                    ),
                                    SizedBox(
                                      width: screenWidth * 0.02,
                                    ),
                                    Consumer<LanguageProvider>(
                                      builder: (BuildContext context,
                                          languageProvider, Widget? child) {
                                        return Text(
                                          languageProvider.language == "english"
                                              ? 'Events Near by You'
                                              : "आपके आस-पास की घटनाएँ",
                                          style: TextStyle(
                                              fontSize: screenWidth * 0.05,
                                              fontWeight: FontWeight.w600),
                                        );
                                      },
                                    ),
                                    const Spacer(),
                                    GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                            context,
                                            CupertinoPageRoute(
                                              builder: (context) => SeeScreen(
                                                eventSubCategory: nearbyEvents,
                                                eventType: "Events Near by You",
                                              ),
                                            ));
                                      },
                                      child: Consumer<LanguageProvider>(
                                        builder: (BuildContext context,
                                            languageProvider, Widget? child) {
                                          return Text(
                                            languageProvider.language ==
                                                    "english"
                                                ? 'See All'
                                                : "सभी देखें",
                                            style: TextStyle(
                                                color: const Color.fromRGBO(
                                                    255, 139, 33, 1),
                                                fontWeight: FontWeight.bold,
                                                fontSize: screenWidth * 0.04),
                                          );
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // add your text here
                              SizedBox(height: screenHeight * 0.02),
                              SizedBox(
                                height: screenHeight * 0.50,
                                child: ListView.separated(
                                  scrollDirection: Axis.horizontal,
                                  padding: EdgeInsets.symmetric(
                                      horizontal: screenWidth * 0.04),
                                  itemCount: nearbyEvents.length > 5
                                      ? 5
                                      : nearbyEvents.length,
                                  separatorBuilder: (_, __) =>
                                      const SizedBox(width: 16),
                                  itemBuilder: (context, index) {
                                    final event = nearbyEvents[index];
                                    final venueData =
                                        event.allVenueData.isNotEmpty == true
                                            ? event.allVenueData.first
                                            : null;
                                    final venueCount =
                                        event.allVenueData.length ?? 0;

                                    dateFormatter(event.startToEndDate ?? '');

                                    return GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          CupertinoPageRoute(
                                            builder: (_) => EventDeatils(
                                              eventId: event.id,
                                            ),
                                          ),
                                        );
                                      },
                                      child: Card(
                                        elevation: 5,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(16),
                                        ),
                                        margin:
                                            const EdgeInsets.only(bottom: 16),
                                        child: Container(
                                          width: screenWidth * 0.78,
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(16),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black12
                                                    .withOpacity(0.1),
                                                blurRadius: 15,
                                                offset: const Offset(0, 8),
                                              ),
                                            ],
                                          ),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              ClipRRect(
                                                borderRadius: const BorderRadius
                                                    .vertical(
                                                    top: Radius.circular(16)),
                                                child: AspectRatio(
                                                  aspectRatio: 16 / 9,
                                                  child: CachedNetworkImage(
                                                    imageUrl:
                                                        event.eventImage ?? '',
                                                    fit: BoxFit.cover,
                                                    placeholder:
                                                        (context, url) =>
                                                            placeholderImage(),
                                                    errorWidget: (context, url,
                                                            error) =>
                                                        const NoImageWidget(),
                                                  ),
                                                ),
                                              ),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.all(14),
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Consumer<LanguageProvider>(
                                                      builder:
                                                          (_, provider, __) =>
                                                              Text(
                                                        provider.language ==
                                                                "english"
                                                            ? event.enEventName ??
                                                                "Event Name"
                                                            : event.hiEventName ??
                                                                "घटना नाम",
                                                        style: const TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 18,
                                                          letterSpacing: 0.3,
                                                        ),
                                                        maxLines: 1,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                    ),
                                                    const SizedBox(height: 5),
                                                    Row(
                                                      children: [
                                                        ...List.generate(5,
                                                            (index) {
                                                          double rating =
                                                              double.tryParse(
                                                                      "${event.reviewAvgStar}") ??
                                                                  0.0;
                                                          //double rating = double.tryParse("3.0") ?? 0.0;

                                                          if (rating >=
                                                              index + 1) {
                                                            return const Icon(
                                                                Icons.star,
                                                                color: Colors
                                                                    .orange,
                                                                size: 22);
                                                          } else if (rating >
                                                                  index &&
                                                              rating <
                                                                  index + 1) {
                                                            return const Icon(
                                                                Icons.star_half,
                                                                color: Colors
                                                                    .orange,
                                                                size: 22);
                                                          } else {
                                                            return const Icon(
                                                                Icons
                                                                    .star_border,
                                                                color: Colors
                                                                    .orange,
                                                                size: 22);
                                                          }
                                                        }),
                                                        const SizedBox(
                                                            width: 6),
                                                        Text(
                                                          "(${(double.tryParse("${event.reviewAvgStar}" ?? "0") ?? 0.0).toStringAsFixed(1)})",
                                                          style:
                                                              const TextStyle(
                                                            fontSize: 16,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color:
                                                                Colors.black87,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    const SizedBox(height: 5),
                                                    Consumer<LanguageProvider>(
                                                      builder:
                                                          (_, provider, __) =>
                                                              Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Text(
                                                            "${provider.language == "english" ? "Start" : "शुरुआत"}: ${event.formattedDate ?? "N/A"}",
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .grey[700],
                                                                fontSize: 13),
                                                          ),
                                                          Text(
                                                            "${provider.language == "english" ? "Time" : "समय"}: ${venueData?.startTime ?? 'N/A'}",
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .grey[700],
                                                                fontSize: 13),
                                                          ),

                                                          // Text(
                                                          //   "${provider.language == "english" ? "Venue" : "स्थान"}: ${provider.language == "english" ? venueData?.enEventVenue ?? 'N/A' : venueData?.hiEventVenue ?? 'N/A'}"
                                                          //   "${venueCount > 1 ? ' + ${venueCount - 1} more' : ''}",
                                                          //   maxLines: 1,
                                                          //   style: TextStyle(
                                                          //       color: Colors
                                                          //           .grey[700],
                                                          //       fontSize: 13),
                                                          // ),
                                                        ],
                                                      ),
                                                    ),
                                                    const SizedBox(height: 14),
                                                    if (venueData?.packageList
                                                            .isNotEmpty ==
                                                        true)
                                                      Consumer<
                                                          LanguageProvider>(
                                                        builder: (BuildContext
                                                                context,
                                                            languageProvider,
                                                            Widget? child) {
                                                          return Container(
                                                            padding:
                                                                const EdgeInsets
                                                                    .symmetric(
                                                                    vertical:
                                                                        10,
                                                                    horizontal:
                                                                        14),
                                                            decoration:
                                                                BoxDecoration(
                                                              color: Colors
                                                                  .deepOrange
                                                                  .withOpacity(
                                                                      0.08),
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          12),
                                                              border: Border.all(
                                                                  color: Colors
                                                                      .deepOrange
                                                                      .shade100),
                                                            ),
                                                            child: Row(
                                                              children: [
                                                                Text(
                                                                  venueData!.packageList[0]
                                                                              .priceNo ==
                                                                          "0"
                                                                      ? "Free Event - "
                                                                      : "₹ ${venueData!.packageList[0].priceNo ?? "N/A"}",
                                                                  style: const TextStyle(
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold),
                                                                ),
                                                                const Spacer(),
                                                                Icon(
                                                                    Icons
                                                                        .event_seat_sharp,
                                                                    size: 18,
                                                                    color: Colors
                                                                        .deepOrange
                                                                        .shade400),
                                                                const SizedBox(
                                                                    width: 6),
                                                                Text(
                                                                  languageProvider
                                                                              .language ==
                                                                          "english"
                                                                      ? "Book Now"
                                                                      : "अभी बुक करें",
                                                                  style:
                                                                      TextStyle(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    color: Colors
                                                                        .deepOrange
                                                                        .shade600,
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          );
                                                        },
                                                      )
                                                    else
                                                      Consumer<
                                                          LanguageProvider>(
                                                        builder: (BuildContext
                                                                context,
                                                            languageProvider,
                                                            Widget? child) {
                                                          return Container(
                                                            padding:
                                                                const EdgeInsets
                                                                    .symmetric(
                                                                    vertical:
                                                                        10,
                                                                    horizontal:
                                                                        14),
                                                            decoration:
                                                                BoxDecoration(
                                                              color: Colors
                                                                  .deepOrange
                                                                  .withOpacity(
                                                                      0.08),
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          12),
                                                              border: Border.all(
                                                                  color: Colors
                                                                      .deepOrange
                                                                      .shade100),
                                                            ),
                                                            child: Row(
                                                              children: [
                                                                Text(
                                                                  languageProvider
                                                                              .language ==
                                                                          "english"
                                                                      ? "About This Event"
                                                                      : "इस कार्यक्रम के बारे में",
                                                                  style:
                                                                      const TextStyle(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    color: Colors
                                                                        .black,
                                                                  ),
                                                                ),
                                                                const Spacer(),
                                                                Icon(
                                                                    Icons
                                                                        .arrow_circle_right,
                                                                    size: 18,
                                                                    color: Colors
                                                                        .deepOrange
                                                                        .shade400),
                                                              ],
                                                            ),
                                                          );
                                                        },
                                                      )
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
                              SizedBox(height: screenHeight * 0.015),
                            ])
                          : const SizedBox.shrink(),

                      /// InHouse Events
                      inHouseData.isNotEmpty
                          ? Column(children: [
                              Container(
                                width: double.infinity, // infinite width
                                height: screenHeight * 0.62, // background color
                                //color: const Color.fromRGBO(255, 236, 208, 1),
                                color: Colors.grey.shade200,
                                child: Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: screenWidth * 0.03,
                                    vertical: screenHeight * 0.01,
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // Title Section
                                      Text(
                                        'Experience divine moments with us!',
                                        style: TextStyle(
                                          fontSize: screenWidth * 0.05,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      Text(
                                        '"हमारे साथ दिव्य क्षणों का अनुभव करें!"',
                                        style: TextStyle(
                                          fontSize: screenWidth * 0.04,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      SizedBox(
                                        height: screenHeight * 0.02,
                                      ),
                                      Consumer<LanguageProvider>(builder:
                                          (context, languageProvider, _) {
                                        return Expanded(
                                          child: ListView.builder(
                                            physics:
                                                const BouncingScrollPhysics(),
                                            scrollDirection: Axis.horizontal,
                                            itemCount: inHouseData.length,
                                            itemBuilder: (context, index) {
                                              final event = inHouseData[index];
                                              final venueList =
                                                  event.allVenueData ?? [];
                                              final hasVenueData =
                                                  venueList.isNotEmpty;

                                              if (inHouseData.isEmpty) {
                                                return Center(
                                                    child: Text(languageProvider
                                                                .language ==
                                                            "english"
                                                        ? "No events available"
                                                        : "कोई इवेंट उपलब्ध नहीं"));
                                              }

                                              final firstVenue = hasVenueData
                                                  ? venueList[0]
                                                  : null;

                                              final eventName = languageProvider
                                                          .language ==
                                                      "english"
                                                  ? (event.enEventName
                                                              .trim()
                                                              .isNotEmpty ==
                                                          true
                                                      ? event.enEventName
                                                      : event.hiEventName
                                                                  .trim()
                                                                  .isNotEmpty ==
                                                              true
                                                          ? event.hiEventName
                                                          : "Event Name")
                                                  : (event.hiEventName
                                                              .trim()
                                                              .isNotEmpty ==
                                                          true
                                                      ? event.hiEventName
                                                      : event.enEventName
                                                                  .trim()
                                                                  .isNotEmpty ==
                                                              true
                                                          ? event.enEventName
                                                          : "इवेंट का नाम");

                                              dateFormatter(
                                                  event.startToEndDate ?? '');

                                              // final rawDate = event.startToEndDate ?? '';
                                              //final formattedDate = _formatDateRange(rawDate);

                                              final startTime = firstVenue
                                                          ?.startTime
                                                          .isNotEmpty ==
                                                      true
                                                  ? firstVenue!.startTime
                                                  : languageProvider.language ==
                                                          "english"
                                                      ? "Time not set"
                                                      : "समय निर्धारित नहीं";

                                              final venueName = languageProvider
                                                          .language ==
                                                      "english"
                                                  ? (firstVenue?.enEventVenue
                                                              .trim()
                                                              .isNotEmpty ==
                                                          true
                                                      ? firstVenue!.enEventVenue
                                                      : firstVenue?.hiEventVenue
                                                                  .trim()
                                                                  .isNotEmpty ==
                                                              true
                                                          ? firstVenue!
                                                              .hiEventVenue
                                                          : "Venue not set")
                                                  : (firstVenue?.hiEventVenue
                                                              .trim()
                                                              .isNotEmpty ==
                                                          true
                                                      ? firstVenue!.hiEventVenue
                                                      : firstVenue?.enEventVenue
                                                                  .trim()
                                                                  .isNotEmpty ==
                                                              true
                                                          ? firstVenue!
                                                              .enEventVenue
                                                          : "स्थान निर्धारित नहीं");

                                              return GestureDetector(
                                                onTap: () {
                                                  Navigator.push(
                                                    context,
                                                    PageRouteBuilder(
                                                      pageBuilder:
                                                          (_, __, ___) =>
                                                              EventDeatils(
                                                        eventId: event.id,
                                                      ),
                                                      transitionsBuilder: (_,
                                                          animation,
                                                          __,
                                                          child) {
                                                        return FadeTransition(
                                                          opacity: animation,
                                                          child: child,
                                                        );
                                                      },
                                                    ),
                                                  );
                                                },
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          left: 15,
                                                          right: 10,
                                                          bottom: 10),
                                                  child: Container(
                                                    width: screenWidth * 0.8,
                                                    decoration: BoxDecoration(
                                                      color: Colors.white,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              20),
                                                      boxShadow: [
                                                        BoxShadow(
                                                          color: Colors.black
                                                              .withOpacity(
                                                                  0.15),
                                                          blurRadius: 15,
                                                          offset: const Offset(
                                                              0, 8),
                                                        ),
                                                      ],
                                                    ),
                                                    child: Stack(
                                                      children: [
                                                        // Image with Orange Gradient Overlay
                                                        ClipRRect(
                                                          borderRadius:
                                                              const BorderRadius
                                                                  .vertical(
                                                                  top: Radius
                                                                      .circular(
                                                                          20)),
                                                          child: SizedBox(
                                                            height:
                                                                screenHeight *
                                                                    0.22,
                                                            width:
                                                                double.infinity,
                                                            child: Stack(
                                                              children: [
                                                                CachedNetworkImage(
                                                                  imageUrl:
                                                                      event.eventImage ??
                                                                          "",
                                                                  fit: BoxFit
                                                                      .cover,
                                                                  errorWidget: (context,
                                                                          url,
                                                                          error) =>
                                                                      const NoImageWidget(),
                                                                ),
                                                                Container(
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    gradient:
                                                                        LinearGradient(
                                                                      begin: Alignment
                                                                          .bottomCenter,
                                                                      end: Alignment
                                                                          .topCenter,
                                                                      colors: [
                                                                        Colors
                                                                            .orange
                                                                            .withOpacity(0.4),
                                                                        Colors
                                                                            .transparent,
                                                                      ],
                                                                    ),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ),

                                                        // Content
                                                        Padding(
                                                          padding: EdgeInsets
                                                              .fromLTRB(
                                                                  16,
                                                                  screenHeight *
                                                                          0.22 -
                                                                      20,
                                                                  16,
                                                                  16),
                                                          child: Container(
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(16),
                                                            decoration:
                                                                BoxDecoration(
                                                              color:
                                                                  Colors.white,
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          16),
                                                              boxShadow: [
                                                                BoxShadow(
                                                                  color: Colors
                                                                      .black
                                                                      .withOpacity(
                                                                          0.2),
                                                                  blurRadius:
                                                                      10,
                                                                  offset:
                                                                      const Offset(
                                                                          0, 4),
                                                                ),
                                                              ],
                                                            ),
                                                            child: Column(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: [
                                                                // Event Name
                                                                Text(
                                                                  eventName ??
                                                                      "N/A",
                                                                  style:
                                                                      TextStyle(
                                                                    fontSize:
                                                                        screenWidth *
                                                                            0.048,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    color: Colors
                                                                        .black87,
                                                                    height: 1.3,
                                                                  ),
                                                                  maxLines: 1,
                                                                  overflow:
                                                                      TextOverflow
                                                                          .ellipsis,
                                                                ),
                                                                const SizedBox(
                                                                    height: 5),

                                                                Row(
                                                                  children: [
                                                                    ...List.generate(
                                                                        5,
                                                                        (index) {
                                                                      double
                                                                          rating =
                                                                          double.tryParse("${event.reviewAvgStar}") ??
                                                                              0.0;
                                                                      //double rating = double.tryParse("3.0") ?? 0.0;

                                                                      if (rating >=
                                                                          index +
                                                                              1) {
                                                                        return const Icon(
                                                                            Icons
                                                                                .star,
                                                                            color:
                                                                                Colors.orange,
                                                                            size: 22);
                                                                      } else if (rating >
                                                                              index &&
                                                                          rating <
                                                                              index + 1) {
                                                                        return const Icon(
                                                                            Icons
                                                                                .star_half,
                                                                            color:
                                                                                Colors.orange,
                                                                            size: 22);
                                                                      } else {
                                                                        return const Icon(
                                                                            Icons
                                                                                .star_border,
                                                                            color:
                                                                                Colors.orange,
                                                                            size: 22);
                                                                      }
                                                                    }),
                                                                    const SizedBox(
                                                                        width:
                                                                            6),
                                                                    Text(
                                                                      "(${(double.tryParse("${event.reviewAvgStar}" ?? "0") ?? 0.0).toStringAsFixed(1)})",
                                                                      style:
                                                                          const TextStyle(
                                                                        fontSize:
                                                                            16,
                                                                        fontWeight:
                                                                            FontWeight.bold,
                                                                        color: Colors
                                                                            .black87,
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                                const SizedBox(
                                                                    height: 5),

                                                                // Full Date (Multi-line if needed)
                                                                Container(
                                                                  padding: const EdgeInsets
                                                                      .symmetric(
                                                                      horizontal:
                                                                          8,
                                                                      vertical:
                                                                          6),
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    color: Colors
                                                                        .orange
                                                                        .shade50,
                                                                    borderRadius:
                                                                        BorderRadius
                                                                            .circular(8),
                                                                  ),
                                                                  child: Text(
                                                                    event
                                                                        .formattedDate,
                                                                    style:
                                                                        TextStyle(
                                                                      color: Colors
                                                                          .orange
                                                                          .shade800,
                                                                      fontSize:
                                                                          12,
                                                                    ),
                                                                    maxLines:
                                                                        2, // Allows date to wrap
                                                                  ),
                                                                ),
                                                                const SizedBox(
                                                                    height: 5),

                                                                // Time & Venue Row
                                                                Row(
                                                                  crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .start,
                                                                  children: [
                                                                    // Time
                                                                    Expanded(
                                                                      child:
                                                                          Column(
                                                                        crossAxisAlignment:
                                                                            CrossAxisAlignment.start,
                                                                        children: [
                                                                          Text(
                                                                            languageProvider.language == "english"
                                                                                ? "TIME"
                                                                                : "समय",
                                                                            style:
                                                                                TextStyle(
                                                                              color: Colors.grey.shade600,
                                                                              fontSize: 11,
                                                                              fontWeight: FontWeight.bold,
                                                                            ),
                                                                          ),
                                                                          const SizedBox(
                                                                              height: 4),
                                                                          Text(
                                                                            startTime,
                                                                            style:
                                                                                const TextStyle(
                                                                              color: Colors.black87,
                                                                              fontSize: 13,
                                                                            ),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    ),

                                                                    // Vertical Divider
                                                                    Container(
                                                                      height:
                                                                          40,
                                                                      width: 1,
                                                                      color: Colors
                                                                          .grey
                                                                          .shade300,
                                                                      margin: const EdgeInsets
                                                                          .symmetric(
                                                                          horizontal:
                                                                              8),
                                                                    ),

                                                                    // Venue
                                                                    Expanded(
                                                                      child:
                                                                          Column(
                                                                        crossAxisAlignment:
                                                                            CrossAxisAlignment.start,
                                                                        children: [
                                                                          Text(
                                                                            languageProvider.language == "english"
                                                                                ? "VENUE"
                                                                                : "स्थान",
                                                                            style:
                                                                                TextStyle(
                                                                              color: Colors.grey.shade600,
                                                                              fontSize: 11,
                                                                              fontWeight: FontWeight.bold,
                                                                            ),
                                                                          ),
                                                                          const SizedBox(
                                                                              height: 4),
                                                                          Text(
                                                                            venueName,
                                                                            style:
                                                                                const TextStyle(
                                                                              color: Colors.black87,
                                                                              fontSize: 13,
                                                                            ),
                                                                            maxLines:
                                                                                2,
                                                                            overflow:
                                                                                TextOverflow.ellipsis,
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                                const SizedBox(
                                                                    height: 10),

                                                                // Orange CTA Button
                                                                Container(
                                                                  width: double
                                                                      .infinity,
                                                                  height: 45,
                                                                  padding: const EdgeInsets
                                                                      .symmetric(
                                                                      vertical:
                                                                          10,
                                                                      horizontal:
                                                                          14),
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    color: Colors
                                                                        .deepOrange
                                                                        .withOpacity(
                                                                            0.08),
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            12),
                                                                    border: Border.all(
                                                                        color: Colors
                                                                            .deepOrange
                                                                            .shade100),
                                                                  ),
                                                                  child: Row(
                                                                    children: [
                                                                      Text(
                                                                        hasVenueData &&
                                                                                venueList[0].packageList.isNotEmpty
                                                                            ? (venueList[0].packageList[0].priceNo != null && venueList[0].packageList[0].priceNo == "0")
                                                                                ? "Free"
                                                                                : "₹${venueList[0].packageList[0].priceNo}"
                                                                            : (languageProvider.language == "english" ? "About This Event" : "इस कार्यक्रम के बारे में"),
                                                                        style:
                                                                            const TextStyle(
                                                                          fontWeight:
                                                                              FontWeight.bold,
                                                                          color:
                                                                              Colors.black,
                                                                        ),
                                                                      ),
                                                                      const Spacer(),
                                                                      Icon(
                                                                          Icons
                                                                              .arrow_circle_right,
                                                                          size:
                                                                              18,
                                                                          color: Colors
                                                                              .deepOrange
                                                                              .shade400),
                                                                    ],
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
                                        );
                                      })
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: screenHeight * 0.02,
                              ),
                            ])
                          : const SizedBox.shrink(),

                      /// SunderKand
                      sunderKandData.isNotEmpty
                          ? Column(
                              children: [
                                Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: screenWidth * 0.02),
                                  child: Row(
                                    children: [
                                      Container(
                                        height: screenHeight * 0.03,
                                        width: screenWidth * 0.01,
                                        color: Colors.deepOrange,
                                      ),
                                      SizedBox(
                                        width: screenWidth * 0.02,
                                      ),
                                      Consumer<LanguageProvider>(
                                        builder: (BuildContext context,
                                            languageProvider, Widget? child) {
                                          return Text(
                                            languageProvider.language ==
                                                    "english"
                                                ? 'Sundar Kand'
                                                : "सुंदर कांड",
                                            style: TextStyle(
                                                fontSize: screenWidth * 0.05,
                                                fontWeight: FontWeight.w600),
                                          );
                                        },
                                      ),
                                      const Spacer(),
                                      GestureDetector(
                                        onTap: () {
                                          Navigator.push(
                                              context,
                                              CupertinoPageRoute(
                                                builder: (context) => SeeScreen(
                                                  eventSubCategory:
                                                      sunderKandData,
                                                  eventType: "Sundar Kand",
                                                ),
                                              ));
                                        },
                                        child: Consumer<LanguageProvider>(
                                          builder: (BuildContext context,
                                              languageProvider, Widget? child) {
                                            return Text(
                                              languageProvider.language ==
                                                      "english"
                                                  ? 'See All'
                                                  : "सभी देखें",
                                              style: TextStyle(
                                                  color: const Color.fromRGBO(
                                                      255, 139, 33, 1),
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: screenWidth * 0.04),
                                            );
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ), // add your text here
                                SizedBox(
                                  height: screenHeight * 0.02,
                                ),

                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(
                                      height: screenHeight * 0.49,
                                      child: ListView.separated(
                                        scrollDirection: Axis.horizontal,
                                        padding: EdgeInsets.symmetric(
                                            horizontal: screenWidth * 0.04),
                                        itemCount: sunderKandData.length > 5
                                            ? 5
                                            : sunderKandData.length,
                                        separatorBuilder: (_, __) =>
                                            const SizedBox(width: 16),
                                        itemBuilder: (context, index) {
                                          final event = sunderKandData[index];
                                          final venueData =
                                              event.allVenueData.isNotEmpty ==
                                                      true
                                                  ? event.allVenueData.first
                                                  : null;
                                          final venueCount =
                                              event.allVenueData.length ?? 0;

                                          dateFormatter(
                                              event.startToEndDate ?? '');

                                          return GestureDetector(
                                            onTap: () {
                                              Navigator.push(
                                                context,
                                                CupertinoPageRoute(
                                                  builder: (_) => EventDeatils(
                                                    eventId: event.id,
                                                  ),
                                                ),
                                              );
                                            },
                                            child: Card(
                                              elevation: 5,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(16),
                                              ),
                                              margin: const EdgeInsets.only(
                                                  bottom: 16),
                                              child: Container(
                                                width: screenWidth * 0.78,
                                                decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  borderRadius:
                                                      BorderRadius.circular(16),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: Colors.black12
                                                          .withOpacity(0.1),
                                                      blurRadius: 15,
                                                      offset:
                                                          const Offset(0, 8),
                                                    ),
                                                  ],
                                                ),
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    ClipRRect(
                                                      borderRadius:
                                                          const BorderRadius
                                                              .vertical(
                                                              top: Radius
                                                                  .circular(
                                                                      16)),
                                                      child: AspectRatio(
                                                        aspectRatio: 16 / 9,
                                                        child:
                                                            CachedNetworkImage(
                                                          imageUrl: event
                                                                  .eventImage ??
                                                              'N/A',
                                                          fit: BoxFit.cover,
                                                          errorWidget: (context,
                                                                  url, error) =>
                                                              const NoImageWidget(),
                                                        ),
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              14),
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Consumer<
                                                              LanguageProvider>(
                                                            builder: (_,
                                                                    provider,
                                                                    __) =>
                                                                Text(
                                                              provider.language ==
                                                                      "english"
                                                                  ? event.enEventName ??
                                                                      "Event Name"
                                                                  : event.hiEventName ??
                                                                      "घटना नाम",
                                                              style:
                                                                  const TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                fontSize: 18,
                                                                letterSpacing:
                                                                    0.3,
                                                              ),
                                                              maxLines: 1,
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                              height: 6),
                                                          Row(
                                                            children: [
                                                              ...List.generate(
                                                                  5, (index) {
                                                                double rating =
                                                                    double.tryParse(
                                                                            "${event.reviewAvgStar}") ??
                                                                        0.0;
                                                                //double rating = double.tryParse("3.0") ?? 0.0;

                                                                if (rating >=
                                                                    index + 1) {
                                                                  return const Icon(
                                                                      Icons
                                                                          .star,
                                                                      color: Colors
                                                                          .orange,
                                                                      size: 22);
                                                                } else if (rating >
                                                                        index &&
                                                                    rating <
                                                                        index +
                                                                            1) {
                                                                  return const Icon(
                                                                      Icons
                                                                          .star_half,
                                                                      color: Colors
                                                                          .orange,
                                                                      size: 22);
                                                                } else {
                                                                  return const Icon(
                                                                      Icons
                                                                          .star_border,
                                                                      color: Colors
                                                                          .orange,
                                                                      size: 22);
                                                                }
                                                              }),
                                                              const SizedBox(
                                                                  width: 6),
                                                              Text(
                                                                "(${(double.tryParse("${event.reviewAvgStar}" ?? "0") ?? 0.0).toStringAsFixed(1)})",
                                                                style:
                                                                    const TextStyle(
                                                                  fontSize: 16,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  color: Colors
                                                                      .black87,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                          const SizedBox(
                                                              height: 6),
                                                          Consumer<
                                                              LanguageProvider>(
                                                            builder: (_,
                                                                    provider,
                                                                    __) =>
                                                                Column(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: [
                                                                Text(
                                                                  "${provider.language == "english" ? "Start" : "शुरुआत"}: ${event.formattedDate ?? 'N/A'}",
                                                                  style: TextStyle(
                                                                      color: Colors
                                                                              .grey[
                                                                          700],
                                                                      fontSize:
                                                                          13),
                                                                ),
                                                                Text(
                                                                  "${provider.language == "english" ? "Time" : "समय"}: ${venueData?.startTime ?? 'N/A'}",
                                                                  style: TextStyle(
                                                                      color: Colors
                                                                              .grey[
                                                                          700],
                                                                      fontSize:
                                                                          13),
                                                                ),
                                                                Text(
                                                                  "${provider.language == "english" ? "Venue" : "स्थान"}: ${provider.language == "english" ? venueData?.enEventVenue ?? 'N/A' : venueData?.hiEventVenue ?? 'N/A'}"
                                                                  "${venueCount > 1 ? ' + ${venueCount - 1} more' : ''}",
                                                                  style: TextStyle(
                                                                      color: Colors
                                                                              .grey[
                                                                          700],
                                                                      fontSize:
                                                                          13),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                              height: 14),
                                                          if (venueData
                                                                  ?.packageList
                                                                  .isNotEmpty ==
                                                              true)
                                                            Consumer<
                                                                LanguageProvider>(
                                                              builder: (BuildContext
                                                                      context,
                                                                  languageProvider,
                                                                  Widget?
                                                                      child) {
                                                                return Container(
                                                                  padding: const EdgeInsets
                                                                      .symmetric(
                                                                      vertical:
                                                                          10,
                                                                      horizontal:
                                                                          14),
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    color: Colors
                                                                        .deepOrange
                                                                        .withOpacity(
                                                                            0.08),
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            12),
                                                                    border: Border.all(
                                                                        color: Colors
                                                                            .deepOrange
                                                                            .shade100),
                                                                  ),
                                                                  child: Row(
                                                                    children: [
                                                                      Text(
                                                                        venueData!.packageList[0].priceNo ==
                                                                                "0"
                                                                            ? "Free Event - "
                                                                            : "₹ ${venueData!.packageList[0].priceNo ?? ''}",
                                                                        style: const TextStyle(
                                                                            fontWeight:
                                                                                FontWeight.bold),
                                                                      ),
                                                                      const Spacer(),
                                                                      Icon(
                                                                          Icons
                                                                              .event_seat_sharp,
                                                                          size:
                                                                              18,
                                                                          color: Colors
                                                                              .deepOrange
                                                                              .shade400),
                                                                      const SizedBox(
                                                                          width:
                                                                              6),
                                                                      Text(
                                                                        languageProvider.language ==
                                                                                "english"
                                                                            ? "Book Now"
                                                                            : "अभी बुक करें",
                                                                        style:
                                                                            TextStyle(
                                                                          fontWeight:
                                                                              FontWeight.bold,
                                                                          color: Colors
                                                                              .deepOrange
                                                                              .shade600,
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                );
                                                              },
                                                            )
                                                          else
                                                            Consumer<
                                                                LanguageProvider>(
                                                              builder: (BuildContext
                                                                      context,
                                                                  languageProvider,
                                                                  Widget?
                                                                      child) {
                                                                return Container(
                                                                  padding: const EdgeInsets
                                                                      .symmetric(
                                                                      vertical:
                                                                          10,
                                                                      horizontal:
                                                                          14),
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    color: Colors
                                                                        .deepOrange
                                                                        .withOpacity(
                                                                            0.08),
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            12),
                                                                    border: Border.all(
                                                                        color: Colors
                                                                            .deepOrange
                                                                            .shade100),
                                                                  ),
                                                                  child: Row(
                                                                    children: [
                                                                      Text(
                                                                        languageProvider.language ==
                                                                                "english"
                                                                            ? "About This Event"
                                                                            : "इस कार्यक्रम के बारे में",
                                                                        style:
                                                                            const TextStyle(
                                                                          fontWeight:
                                                                              FontWeight.bold,
                                                                          color:
                                                                              Colors.black,
                                                                        ),
                                                                      ),
                                                                      const Spacer(),
                                                                      Icon(
                                                                          Icons
                                                                              .arrow_circle_right,
                                                                          size:
                                                                              18,
                                                                          color: Colors
                                                                              .deepOrange
                                                                              .shade400),
                                                                    ],
                                                                  ),
                                                                );
                                                              },
                                                            )
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
                                  ],
                                ),
                                SizedBox(
                                  height: screenHeight * 0.02,
                                ),
                              ],
                            )
                          : const SizedBox.shrink(),

                      /// Satsang Data
                      satsangData.isNotEmpty
                          ? Column(
                              children: [
                                Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: screenWidth * 0.02),
                                  child: Row(
                                    children: [
                                      Container(
                                        height: screenHeight * 0.03,
                                        width: screenWidth * 0.01,
                                        color: Colors.deepOrange,
                                      ),
                                      SizedBox(
                                        width: screenWidth * 0.02,
                                      ),
                                      Consumer<LanguageProvider>(
                                        builder: (BuildContext context,
                                            languageProvider, Widget? child) {
                                          return Text(
                                            languageProvider.language ==
                                                    "english"
                                                ? 'Satsang'
                                                : "सत्संग",
                                            style: TextStyle(
                                                fontSize: screenWidth * 0.05,
                                                fontWeight: FontWeight.w600),
                                          );
                                        },
                                      ),
                                      const Spacer(),
                                      GestureDetector(
                                        onTap: () {
                                          Navigator.push(
                                              context,
                                              CupertinoPageRoute(
                                                builder: (context) => SeeScreen(
                                                    eventSubCategory:
                                                        satsangData,
                                                    eventType: "Satsang"),
                                              ));
                                        },
                                        child: Consumer<LanguageProvider>(
                                          builder: (BuildContext context,
                                              languageProvider, Widget? child) {
                                            return Text(
                                              languageProvider.language ==
                                                      "english"
                                                  ? 'See All'
                                                  : "सभी देखें",
                                              style: TextStyle(
                                                  color: const Color.fromRGBO(
                                                      255, 139, 33, 1),
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: screenWidth * 0.04),
                                            );
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ), // add your text here
                                SizedBox(
                                  height: screenHeight * 0.02,
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(
                                      height: screenHeight * 0.49,
                                      child: ListView.separated(
                                        scrollDirection: Axis.horizontal,
                                        padding: EdgeInsets.symmetric(
                                            horizontal: screenWidth * 0.04),
                                        itemCount: satsangData.length > 5
                                            ? 5
                                            : satsangData.length,
                                        separatorBuilder: (_, __) =>
                                            const SizedBox(width: 16),
                                        itemBuilder: (context, index) {
                                          final event = satsangData[index];
                                          final venueData =
                                              event.allVenueData.isNotEmpty ==
                                                      true
                                                  ? event.allVenueData.first
                                                  : null;
                                          final venueCount =
                                              event.allVenueData.length ?? 0;

                                          dateFormatter(
                                              event.startToEndDate ?? '');

                                          return GestureDetector(
                                            onTap: () {
                                              Navigator.push(
                                                context,
                                                CupertinoPageRoute(
                                                  builder: (_) => EventDeatils(
                                                    eventId: event.id,
                                                  ),
                                                ),
                                              );
                                            },
                                            child: Card(
                                              elevation: 5,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(16),
                                              ),
                                              margin: const EdgeInsets.only(
                                                  bottom: 16),
                                              child: Container(
                                                width: screenWidth * 0.78,
                                                decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  borderRadius:
                                                      BorderRadius.circular(16),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: Colors.black12
                                                          .withOpacity(0.1),
                                                      blurRadius: 15,
                                                      offset:
                                                          const Offset(0, 8),
                                                    ),
                                                  ],
                                                ),
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    ClipRRect(
                                                      borderRadius:
                                                          const BorderRadius
                                                              .vertical(
                                                              top: Radius
                                                                  .circular(
                                                                      16)),
                                                      child: AspectRatio(
                                                        aspectRatio: 16 / 9,
                                                        child:
                                                            CachedNetworkImage(
                                                          imageUrl: event
                                                                  .eventImage ??
                                                              '',
                                                          fit: BoxFit.cover,
                                                          errorWidget: (context,
                                                                  url, error) =>
                                                              const NoImageWidget(),
                                                        ),
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              14),
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Consumer<
                                                              LanguageProvider>(
                                                            builder: (_,
                                                                    provider,
                                                                    __) =>
                                                                Text(
                                                              provider.language ==
                                                                      "english"
                                                                  ? event.enEventName ??
                                                                      "Event Name"
                                                                  : event.hiEventName ??
                                                                      "घटना नाम",
                                                              style:
                                                                  const TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                fontSize: 18,
                                                                letterSpacing:
                                                                    0.3,
                                                              ),
                                                              maxLines: 1,
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                              height: 6),
                                                          Row(
                                                            children: [
                                                              ...List.generate(
                                                                  5, (index) {
                                                                double rating =
                                                                    double.tryParse(
                                                                            "${event.reviewAvgStar}") ??
                                                                        0.0;
                                                                //double rating = double.tryParse("3.0") ?? 0.0;

                                                                if (rating >=
                                                                    index + 1) {
                                                                  return const Icon(
                                                                      Icons
                                                                          .star,
                                                                      color: Colors
                                                                          .orange,
                                                                      size: 22);
                                                                } else if (rating >
                                                                        index &&
                                                                    rating <
                                                                        index +
                                                                            1) {
                                                                  return const Icon(
                                                                      Icons
                                                                          .star_half,
                                                                      color: Colors
                                                                          .orange,
                                                                      size: 22);
                                                                } else {
                                                                  return const Icon(
                                                                      Icons
                                                                          .star_border,
                                                                      color: Colors
                                                                          .orange,
                                                                      size: 22);
                                                                }
                                                              }),
                                                              const SizedBox(
                                                                  width: 6),
                                                              Text(
                                                                "(${(double.tryParse("${event.reviewAvgStar}" ?? "0") ?? 0.0).toStringAsFixed(1)})",
                                                                style:
                                                                    const TextStyle(
                                                                  fontSize: 16,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  color: Colors
                                                                      .black87,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                          const SizedBox(
                                                              height: 6),
                                                          Consumer<
                                                              LanguageProvider>(
                                                            builder: (_,
                                                                    provider,
                                                                    __) =>
                                                                Column(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: [
                                                                Text(
                                                                  "${provider.language == "english" ? "Start" : "शुरुआत"}: $fullDate",
                                                                  style: TextStyle(
                                                                      color: Colors
                                                                              .grey[
                                                                          700],
                                                                      fontSize:
                                                                          13),
                                                                ),
                                                                Text(
                                                                  "${provider.language == "english" ? "Time" : "समय"}: ${venueData?.startTime ?? '-'}",
                                                                  style: TextStyle(
                                                                      color: Colors
                                                                              .grey[
                                                                          700],
                                                                      fontSize:
                                                                          13),
                                                                ),
                                                                Text(
                                                                  "${provider.language == "english" ? "Venue" : "स्थान"}: ${provider.language == "english" ? venueData?.enEventVenue ?? '-' : venueData?.hiEventVenue ?? '-'}"
                                                                  "${venueCount > 1 ? ' + ${venueCount - 1} more' : ''}",
                                                                  style: TextStyle(
                                                                      color: Colors
                                                                              .grey[
                                                                          700],
                                                                      fontSize:
                                                                          13),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                              height: 14),
                                                          if (venueData
                                                                  ?.packageList
                                                                  .isNotEmpty ==
                                                              true)
                                                            Consumer<
                                                                LanguageProvider>(
                                                              builder: (BuildContext
                                                                      context,
                                                                  languageProvider,
                                                                  Widget?
                                                                      child) {
                                                                return Container(
                                                                  padding: const EdgeInsets
                                                                      .symmetric(
                                                                      vertical:
                                                                          10,
                                                                      horizontal:
                                                                          14),
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    color: Colors
                                                                        .deepOrange
                                                                        .withOpacity(
                                                                            0.08),
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            12),
                                                                    border: Border.all(
                                                                        color: Colors
                                                                            .deepOrange
                                                                            .shade100),
                                                                  ),
                                                                  child: Row(
                                                                    children: [
                                                                      Text(
                                                                        venueData!.packageList[0].priceNo ==
                                                                                "0"
                                                                            ? "Free Event - "
                                                                            : "₹ ${venueData!.packageList[0].priceNo ?? ''}",
                                                                        style: const TextStyle(
                                                                            fontWeight:
                                                                                FontWeight.bold),
                                                                      ),
                                                                      const Spacer(),
                                                                      Icon(
                                                                          Icons
                                                                              .event_seat_sharp,
                                                                          size:
                                                                              18,
                                                                          color: Colors
                                                                              .deepOrange
                                                                              .shade400),
                                                                      const SizedBox(
                                                                          width:
                                                                              6),
                                                                      Text(
                                                                        languageProvider.language ==
                                                                                "english"
                                                                            ? "Book Now"
                                                                            : "अभी बुक करें",
                                                                        style:
                                                                            TextStyle(
                                                                          fontWeight:
                                                                              FontWeight.bold,
                                                                          color: Colors
                                                                              .deepOrange
                                                                              .shade600,
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                );
                                                              },
                                                            )
                                                          else
                                                            Consumer<
                                                                LanguageProvider>(
                                                              builder: (BuildContext
                                                                      context,
                                                                  languageProvider,
                                                                  Widget?
                                                                      child) {
                                                                return Container(
                                                                  padding: const EdgeInsets
                                                                      .symmetric(
                                                                      vertical:
                                                                          10,
                                                                      horizontal:
                                                                          14),
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    color: Colors
                                                                        .deepOrange
                                                                        .withOpacity(
                                                                            0.08),
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            12),
                                                                    border: Border.all(
                                                                        color: Colors
                                                                            .deepOrange
                                                                            .shade100),
                                                                  ),
                                                                  child: Row(
                                                                    children: [
                                                                      Text(
                                                                        languageProvider.language ==
                                                                                "english"
                                                                            ? "About This Event"
                                                                            : "इस कार्यक्रम के बारे में",
                                                                        style:
                                                                            const TextStyle(
                                                                          fontWeight:
                                                                              FontWeight.bold,
                                                                          color:
                                                                              Colors.black,
                                                                        ),
                                                                      ),
                                                                      const Spacer(),
                                                                      Icon(
                                                                          Icons
                                                                              .arrow_circle_right,
                                                                          size:
                                                                              18,
                                                                          color: Colors
                                                                              .deepOrange
                                                                              .shade400),
                                                                    ],
                                                                  ),
                                                                );
                                                              },
                                                            )
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
                                    // SizedBox(
                                    //   height: screenHeight * 0.41,
                                    //   // Height for ListView
                                    //   child: ListView.builder(
                                    //     padding: EdgeInsets.zero,
                                    //     shrinkWrap: true,
                                    //     physics:
                                    //         const AlwaysScrollableScrollPhysics(),
                                    //     scrollDirection: Axis.horizontal,
                                    //     itemCount: satsangData.length > 5
                                    //         ? 5
                                    //         : satsangData.length,
                                    //     itemBuilder: (context, index) {
                                    //       var venueLength = satsangData[index]
                                    //           .allVenueData!
                                    //           .length;
                                    //
                                    //       String startToEndDate =
                                    //           "${satsangData[index].allVenueData![0].date}";
                                    //       List<String> dates =
                                    //           startToEndDate.split(" - ");
                                    //
                                    //       // Define the input and output date formats
                                    //       final inputFormat =
                                    //           DateFormat('yyyy-MM-dd');
                                    //       final outputFormat =
                                    //           DateFormat('d MMM yyyy');
                                    //
                                    //       // Parse and format start date
                                    //       String startDate = dates.isNotEmpty
                                    //           ? outputFormat.format(
                                    //               inputFormat.parse(dates[
                                    //                   0])) // "10 Nov 2024"
                                    //           : 'No Start Date';
                                    //
                                    //       // Parse and format end date if available
                                    //       String endDate = dates.length > 1
                                    //           ? outputFormat.format(
                                    //               inputFormat.parse(dates[
                                    //                   1])) // "15 Nov 2024"
                                    //           : 'No End Date';
                                    //
                                    //       return GestureDetector(
                                    //         onTap: () {
                                    //           Navigator.push(
                                    //             context,
                                    //             CupertinoPageRoute(
                                    //               builder: (context) =>
                                    //                   EventDeatils(
                                    //                 eventId:
                                    //                     satsangData[index].id,
                                    //                 eventSubCategory:
                                    //                     eventSubCategory,
                                    //                 hiEventVenue: satsangData[
                                    //                             index]
                                    //                         .allVenueData![0]
                                    //                         .enEventVenue ??
                                    //                     '',
                                    //                 enEventVenue: satsangData[
                                    //                             index]
                                    //                         .allVenueData![0]
                                    //                         .enEventVenue ??
                                    //                     '',
                                    //               ),
                                    //             ),
                                    //           );
                                    //         },
                                    //         child: Padding(
                                    //           padding: const EdgeInsets
                                    //               .symmetric(
                                    //               horizontal:
                                    //                   8), // Adjusted padding
                                    //           child: Container(
                                    //             width: screenWidth * 0.60,
                                    //             decoration: BoxDecoration(
                                    //               border: Border.all(
                                    //                   color:
                                    //                       const Color.fromRGBO(
                                    //                           231,
                                    //                           231,
                                    //                           231,
                                    //                           1)),
                                    //               // Black border
                                    //               borderRadius:
                                    //                   BorderRadius.circular(10),
                                    //             ),
                                    //             child: Column(
                                    //               crossAxisAlignment:
                                    //                   CrossAxisAlignment.start,
                                    //               children: [
                                    //                 SizedBox(
                                    //                   width: double.infinity,
                                    //                   height:
                                    //                       screenHeight * 0.23,
                                    //                   child: ClipRRect(
                                    //                     borderRadius:
                                    //                         BorderRadius.circular(
                                    //                             screenHeight *
                                    //                                 0.01),
                                    //                     // Half of the height
                                    //                     child: Stack(
                                    //                       fit: StackFit.expand,
                                    //                       // Ensures the stack fills the container
                                    //                       children: [
                                    //                         CachedNetworkImage(
                                    //                           imageUrl:
                                    //                               "${satsangData[index].eventImage}",
                                    //                           fit: BoxFit.cover,
                                    //                           errorWidget: (context,
                                    //                                   url,
                                    //                                   error) =>
                                    //                               const Icon(Icons
                                    //                                   .image_not_supported), // Error image
                                    //                         ),
                                    //                         Positioned(
                                    //                           bottom: 10,
                                    //                           left: 10,
                                    //                           child: Consumer<
                                    //                               LanguageProvider>(
                                    //                             builder: (BuildContext
                                    //                                     context,
                                    //                                 languageProvider,
                                    //                                 Widget?
                                    //                                     child) {
                                    //                               return SizedBox(
                                    //                                 width:
                                    //                                     screenWidth *
                                    //                                         0.5,
                                    //                                 child: Text(
                                    //                                   languageProvider.language ==
                                    //                                           "english"
                                    //                                       ? "${satsangData[index].enEventName}"
                                    //                                       : "${satsangData[index].hiEventName}",
                                    //                                   style:
                                    //                                       TextStyle(
                                    //                                     fontSize:
                                    //                                         screenWidth *
                                    //                                             0.05,
                                    //                                     color: Colors
                                    //                                         .white,
                                    //                                     fontWeight:
                                    //                                         FontWeight.w600,
                                    //                                     overflow:
                                    //                                         TextOverflow.ellipsis,
                                    //                                   ),
                                    //                                   textAlign:
                                    //                                       TextAlign
                                    //                                           .start,
                                    //                                   maxLines:
                                    //                                       1,
                                    //                                 ),
                                    //                               );
                                    //                             },
                                    //                           ),
                                    //                         ),
                                    //                       ],
                                    //                     ),
                                    //                   ),
                                    //                 ),
                                    //                 SizedBox(
                                    //                     height: screenHeight *
                                    //                         0.00),
                                    //                 Padding(
                                    //                   padding:
                                    //                       EdgeInsets.symmetric(
                                    //                           horizontal:
                                    //                               screenWidth *
                                    //                                   0.02),
                                    //                   child: Column(
                                    //                     crossAxisAlignment:
                                    //                         CrossAxisAlignment
                                    //                             .start,
                                    //                     children: [
                                    //                       SizedBox(
                                    //                           height:
                                    //                               screenHeight *
                                    //                                   0.01),
                                    //                       Consumer<
                                    //                           LanguageProvider>(
                                    //                         builder: (BuildContext
                                    //                                 context,
                                    //                             languageProvider,
                                    //                             Widget? child) {
                                    //                           return Text.rich(
                                    //                             maxLines: 4,
                                    //                             TextSpan(
                                    //                               children: [
                                    //                                 TextSpan(
                                    //                                   text: languageProvider.language ==
                                    //                                           "english"
                                    //                                       ? "Start Date: "
                                    //                                       : "आरंभ तिथि: ",
                                    //                                   style:
                                    //                                       TextStyle(
                                    //                                     fontWeight:
                                    //                                         FontWeight.bold,
                                    //                                     color: Colors
                                    //                                         .blue,
                                    //                                     fontSize:
                                    //                                         screenWidth *
                                    //                                             0.04,
                                    //                                   ),
                                    //                                 ),
                                    //                                 TextSpan(
                                    //                                     text:
                                    //                                         startDate),
                                    //                                 TextSpan(
                                    //                                   text:
                                    //                                       "\n${languageProvider.language == "english" ? "Start Time: " : "समय: "}",
                                    //                                   style:
                                    //                                       TextStyle(
                                    //                                     fontWeight:
                                    //                                         FontWeight.bold,
                                    //                                     color: Colors
                                    //                                         .blue,
                                    //                                     fontSize:
                                    //                                         screenWidth *
                                    //                                             0.04,
                                    //                                   ),
                                    //                                 ),
                                    //                                 TextSpan(
                                    //                                     text: satsangData[index]
                                    //                                         .allVenueData![0]
                                    //                                         .startTime),
                                    //                                 TextSpan(
                                    //                                   text:
                                    //                                       "\n${languageProvider.language == "english" ? "Venue: " : "स्थान: "}",
                                    //                                   style:
                                    //                                       TextStyle(
                                    //                                     fontWeight:
                                    //                                         FontWeight.bold,
                                    //                                     color: Colors
                                    //                                         .blue,
                                    //                                     fontSize:
                                    //                                         screenWidth *
                                    //                                             0.04,
                                    //                                   ),
                                    //                                 ),
                                    //                                 TextSpan(
                                    //                                   text: languageProvider.language ==
                                    //                                           "english"
                                    //                                       ? satsangData[index]
                                    //                                           .allVenueData![
                                    //                                               0]
                                    //                                           .enEventVenue
                                    //                                       : satsangData[index]
                                    //                                           .allVenueData![0]
                                    //                                           .hiEventVenue,
                                    //                                   style: const TextStyle(
                                    //                                       fontWeight:
                                    //                                           FontWeight.w400),
                                    //                                 ),
                                    //                                 if (venueLength >
                                    //                                     1) ...[
                                    //                                   TextSpan(
                                    //                                     text: languageProvider.language ==
                                    //                                             "english"
                                    //                                         ? " + $venueLength More Venue"
                                    //                                         : " + ${venueLength} अधिक स्थान",
                                    //                                     style: const TextStyle(
                                    //                                         fontWeight:
                                    //                                             FontWeight.w400),
                                    //                                   ),
                                    //                                 ],
                                    //                               ],
                                    //                             ),
                                    //                           );
                                    //                         },
                                    //                       ),
                                    //                       Padding(
                                    //                         padding: EdgeInsets
                                    //                             .symmetric(
                                    //                                 horizontal:
                                    //                                     screenWidth *
                                    //                                         0.0001),
                                    //                         child: SizedBox(
                                    //                           child: Consumer<
                                    //                               LanguageProvider>(
                                    //                             builder: (context,
                                    //                                 languageProvider,
                                    //                                 child) {
                                    //                               // Check if the package list is not empty
                                    //                               if (satsangData[index]
                                    //                                           .allVenueData![
                                    //                                               0]
                                    //                                           .packageList !=
                                    //                                       null &&
                                    //                                   satsangData[
                                    //                                           index]
                                    //                                       .allVenueData![
                                    //                                           0]
                                    //                                       .packageList!
                                    //                                       .isNotEmpty) {
                                    //                                 // Display price and "Book now" button
                                    //                                 return Container(
                                    //                                   width: double
                                    //                                       .infinity,
                                    //                                   padding: const EdgeInsets
                                    //                                       .symmetric(
                                    //                                       horizontal:
                                    //                                           20),
                                    //                                   decoration:
                                    //                                       BoxDecoration(
                                    //                                     borderRadius:
                                    //                                         BorderRadius.circular(5),
                                    //                                     color: Colors
                                    //                                         .orange
                                    //                                         .shade300,
                                    //                                     boxShadow: [
                                    //                                       BoxShadow(
                                    //                                         color:
                                    //                                             Colors.black.withOpacity(0.2),
                                    //                                         spreadRadius:
                                    //                                             2,
                                    //                                         blurRadius:
                                    //                                             5,
                                    //                                         offset:
                                    //                                             const Offset(0, 3),
                                    //                                       ),
                                    //                                     ],
                                    //                                   ),
                                    //                                   child:
                                    //                                       Padding(
                                    //                                     padding: EdgeInsets.symmetric(
                                    //                                         horizontal: screenWidth *
                                    //                                             0.02,
                                    //                                         vertical:
                                    //                                             screenWidth * 0.02),
                                    //                                     child:
                                    //                                         Row(
                                    //                                       children: [
                                    //                                         // Display price
                                    //                                         Text(
                                    //                                           languageProvider.language == "english" ? "Rs : ${satsangData[index].allVenueData![0].packageList![0].priceNo}" : "₹ : ${satsangData[index].allVenueData![0].packageList![0].priceNo}",
                                    //                                           style: const TextStyle(fontWeight: FontWeight.w600),
                                    //                                         ),
                                    //                                         const Spacer(),
                                    //                                         const Text('|',
                                    //                                             style: TextStyle(color: Colors.deepOrange, fontWeight: FontWeight.bold)),
                                    //                                         SizedBox(width: screenWidth * 0.02),
                                    //                                         // Display "Book now" button
                                    //                                         Text(
                                    //                                           languageProvider.language == "english" ? "Book now" : "अभी बुक करें",
                                    //                                           style: const TextStyle(fontWeight: FontWeight.bold),
                                    //                                         ),
                                    //                                       ],
                                    //                                     ),
                                    //                                   ),
                                    //                                 );
                                    //                               } else {
                                    //                                 // If package list is empty, show "Know about the event"
                                    //                                 return Container(
                                    //                                   width: double
                                    //                                       .infinity,
                                    //                                   padding: const EdgeInsets
                                    //                                       .symmetric(
                                    //                                       horizontal:
                                    //                                           20),
                                    //                                   decoration:
                                    //                                       BoxDecoration(
                                    //                                     borderRadius:
                                    //                                         BorderRadius.circular(5),
                                    //                                     color: Colors
                                    //                                         .orange
                                    //                                         .shade300,
                                    //                                     boxShadow: [
                                    //                                       BoxShadow(
                                    //                                         color:
                                    //                                             Colors.black.withOpacity(0.2),
                                    //                                         spreadRadius:
                                    //                                             2,
                                    //                                         blurRadius:
                                    //                                             5,
                                    //                                         offset:
                                    //                                             const Offset(0, 3),
                                    //                                       ),
                                    //                                     ],
                                    //                                   ),
                                    //                                   child:
                                    //                                       Center(
                                    //                                     child:
                                    //                                         Padding(
                                    //                                       padding: const EdgeInsets
                                    //                                           .all(
                                    //                                           5),
                                    //                                       child:
                                    //                                           Text(
                                    //                                         languageProvider.language == "english"
                                    //                                             ? "Know about the Event"
                                    //                                             : "जानिए इवेंट के बारे में",
                                    //                                         style:
                                    //                                             const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                    //                                       ),
                                    //                                     ),
                                    //                                   ),
                                    //                                 );
                                    //                               }
                                    //                             },
                                    //                           ),
                                    //                         ),
                                    //                       ),
                                    //                     ],
                                    //                   ),
                                    //                 ),
                                    //               ],
                                    //             ),
                                    //           ),
                                    //         ),
                                    //       );
                                    //     },
                                    //   ),
                                    // ),
                                  ],
                                ),
                                SizedBox(
                                  height: screenHeight * 0.02,
                                ),
                              ],
                            )
                          : const SizedBox.shrink(),
                    ]),
              )));
  }
}
