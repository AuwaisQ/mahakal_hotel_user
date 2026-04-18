import 'dart:async';
import 'dart:math';

import 'package:appbar_animated/appbar_animated.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:mahakal/utill/loading_datawidget.dart';
import 'package:provider/provider.dart';
import 'package:tdk_bouncingwidget/tdk_bouncingwidget.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../data/datasource/remote/http/httpClient.dart';
import '../../main.dart';
import '../profile/controllers/profile_contrroller.dart';
import 'model/RestaurantModel.dart';
import 'model/city_model.dart';
import 'model/hotel_review_model.dart';
import 'model/hotelnear_model.dart';
import 'model/templenearby_model.dart';

class HotelDetailView extends StatefulWidget {
  final String detailId;
  const HotelDetailView({super.key, required this.detailId});

  @override
  State<HotelDetailView> createState() => _hoteldetailState();
}

class _hoteldetailState extends State<HotelDetailView>
    with SingleTickerProviderStateMixin {
  TabController? _tabController;
  final ScrollController scrollController = ScrollController();
  double previousOffset = 0.0;
  bool isAppBarVisible = false;

  final oneKey = GlobalKey();
  final twoKey = GlobalKey();
  final threeKey = GlobalKey();
  final fourKey = GlobalKey();
  final fiveKey = GlobalKey();
  final sixKey = GlobalKey();
  final sevenKey = GlobalKey();
  late double greenHeight;
  late double blueHeight;
  late double orangeHeight;
  late double yellowHeight;
  late double blackHeight;
  late double whiteHeight;
  late double redHeight;

  List<Hotel> hotelModelList = <Hotel>[];
  List<Data> templeModelList = <Data>[];
  List<Restaurant> restaurantModelList = <Restaurant>[];
  List<City> cityModelList = <City>[];

  final CarouselSliderController carouselController =
      CarouselSliderController();
  var currentIndex = 0;

  bool gridList = false;
  String translateEn = 'hi';

  List<String> imageList = [];
  String enName = "";
  String enStateName = "";
  String enDescription = "";
  String enAmenities = "";
  String enRoomAmenities = "";
  String enRoomType = "";
  String enBookingInformation = "";

  String hiName = "";
  String hiStateName = "";
  String hiDescription = "";
  String hiAmenities = "";
  String hiRoomAmenities = "";
  String hiRoomType = "";
  String hiBookingInformation = "";

  String email = "";
  String phoneNo = "";
  String zipCode = "";
  String webLink = "";
  String address = "";
  String userPhone = "";
  String userEmail = "";
  String userId = "";

  final List<String> imageUrls = [
    // Add your image URLs here
    'https://via.placeholder.com/200x300',
    'https://via.placeholder.com/300x400',
    'https://via.placeholder.com/250x250',
    'https://via.placeholder.com/400x200',
    // Add more URLs
  ];

  // review items
  List<Hotelreview> reviewModelList = <Hotelreview>[];
  double averageRating = 0.0;
  TextEditingController reviewController = TextEditingController();
  int getUserRating = 3; // Default rating

  String formatDateString(String dateString) {
    // Parse the input date string to a DateTime object
    DateTime parsedDate = DateTime.parse(dateString);

    // Format the DateTime object into the desired format
    String formattedDate = DateFormat('dd-MMMM-yyyy').format(parsedDate);

    return formattedDate;
  }

  void getHotelReview(String id) async {
    var res = await HttpService()
        .postApi("/api/v1/hotel/gethotelcomment", {"hotel_id": id});

    setState(() {
      reviewModelList.clear();
      List reviewList = res["data"];
      reviewModelList.addAll(reviewList.map((e) => Hotelreview.fromJson(e)));

      if (reviewModelList.isNotEmpty) {
        double totalRating = reviewModelList
            .map((e) => e.star)
            .reduce((a, b) => a + b)
            .toDouble();
        averageRating = totalRating / reviewModelList.length;
      } else {
        averageRating = 0.0;
      }

      print("API Review: $res");
      print("Average Rating: ${averageRating.toStringAsFixed(1)}");
    });
  }

  void setHotelReview(String id) async {
    var res = await HttpService().postApi("/api/v1/hotel/hoteladdcomment", {
      "user_id": userId,
      "hotel_id": id,
      "comment": reviewController.text,
      "star": "$getUserRating",
      "image": ""
    });
    print(res);
    if (res["status"] == 1) {
      Navigator.pop(context);
      Fluttertoast.showToast(
          msg: "Add Comment",
          backgroundColor: Colors.green,
          textColor: Colors.white);
      getHotelReview(widget.detailId);
      reviewController.clear();
    } else {
      Fluttertoast.showToast(
          msg: "Add Failed",
          backgroundColor: Colors.red,
          textColor: Colors.white);
    }
  }

  void showReviewDialog(BuildContext context) {
    double userRating = 3.0;
    // Convert double to int initially
    showCupertinoDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return CupertinoAlertDialog(
              title: const Text("Write a Review"),
              content: Column(
                children: [
                  const SizedBox(height: 10),

                  // Rating Bar
                  RatingBar.builder(
                    initialRating: userRating,
                    minRating: 1,
                    direction: Axis.horizontal,
                    allowHalfRating: true,
                    itemCount: 5,
                    itemSize: 30, // Adjust size
                    itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
                    itemBuilder: (context, _) => const Icon(
                      CupertinoIcons.star_fill,
                      color: CupertinoColors.systemYellow,
                    ),
                    onRatingUpdate: (rating) {
                      setState(() {
                        userRating = rating;
                        getUserRating = userRating.toInt(); // Convert to int
                      });
                      print("Rating: $userRating, Int: $getUserRating");
                    },
                  ),

                  const SizedBox(height: 10),

                  // Review TextField
                  CupertinoTextField(
                    controller: reviewController,
                    maxLines: 3,
                    placeholder: "Enter your review...",
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: CupertinoColors.systemGrey5,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ],
              ),
              actions: [
                // Cancel Button
                CupertinoDialogAction(
                  isDestructiveAction: true,
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text("Cancel"),
                ),

                // Submit Button
                CupertinoDialogAction(
                  isDefaultAction: true,
                  onPressed: () {
                    String reviewText = reviewController.text;
                    print("User Review: $reviewText");
                    print("User Rating: $userRating");

                    if (reviewText.isNotEmpty) {
                      setHotelReview(widget.detailId);
                    }
                  },
                  child: const Text("Submit"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void getHotelDetails(String id) async {
    var res = await HttpService().postApi("/api/v1/hotel/gethotelbyid", {
      "hotel_id": id,
    });
    print("Api response $res");
    setState(() {
      enName = res["data"]["en_hotel_name"];
      email = res["data"]["email_id"];
      phoneNo = res["data"]["phone_no"].toString();
      zipCode = res["data"]["zipcode"].toString();
      webLink = res["data"]["website_link"];
      address = res["data"]["cities"]["city"];
      enStateName = res["data"]["states"]["name"];
      enDescription = res["data"]["en_description"];
      enAmenities = res["data"]["en_amenities"];
      enRoomAmenities = res["data"]["en_room_amenities"];
      enRoomType = res["data"]["en_room_types"];
      enBookingInformation = res["data"]["en_booking_information"];

      hiName = res["data"]["hi_hotel_name"];
      hiStateName = res["data"]["states"]["name"];
      hiDescription = res["data"]["hi_description"];
      hiAmenities = res["data"]["hi_amenities"];
      hiRoomAmenities = res["data"]["hi_room_amenities"];
      hiRoomType = res["data"]["hi_room_types"];
      hiBookingInformation = res["data"]["hi_booking_information"];

      imageList = List<String>.from(res["data"]["image_list"]);
      // enShortDescription = res["data"]["en_short_desc"];
    });
    getHoteldata();
    getRestaurantData();
    getCityData();
    getTempleData();
  }

  void getHoteldata() async {
    var res = await HttpService().postApi("/api/v1/hotel/gethotels",
        {"latitude": "${23.18290189999999}", "longitude": "${75.7682392}"});
    setState(() {
      hotelModelList.clear();
      List hotelList = res["data"];
      hotelModelList.addAll(hotelList.map((e) => Hotel.fromJson(e)));
    });
  }

  void getRestaurantData() async {
    var res = await HttpService().postApi("/api/v1/restaurant/getrestaurant",
        {"latitude": "${23.18290189999999}", "longitude": "${75.7682392}"});
    setState(() {
      restaurantModelList.clear();
      List restaurantList = res["data"];
      restaurantModelList
          .addAll(restaurantList.map((e) => Restaurant.fromJson(e)));
    });
  }

  void getCityData() async {
    var res = await HttpService().postApi("/api/v1/cities/getcities",
        {"latitude": "${23.18290189999999}", "longitude": "${75.7682392}"});
    setState(() {
      cityModelList.clear();
      List cityList = res["data"];
      cityModelList.addAll(cityList.map((e) => City.fromJson(e)));
    });
  }

  void getTempleData() async {
    var res = await HttpService().postApi("/api/v1/temple/gettemple",
        {"latitude": "${23.18290189999999}", "longitude": "${75.7682392}"});
    setState(() {
      templeModelList.clear();
      List templeList = res["data"];
      templeModelList.addAll(templeList.map((e) => Data.fromJson(e)));
    });
  }

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

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getHotelDetails(widget.detailId);
    userId = Provider.of<ProfileController>(Get.context!, listen: false).userID;
    userPhone =
        Provider.of<ProfileController>(Get.context!, listen: false).userPHONE;
    scrollController.addListener(() {
      handleAppBarVisibility();
      addScrollControllerListener();
    });
    _tabController = TabController(length: 3, vsync: this);
    getHotelReview(widget.detailId);
    print("hotel user id ${widget.detailId}");
  }

  // @override
  // Widget build(BuildContext context) {
  //   final double screenHeight = MediaQuery.of(context).size.height;
  //   final double screenWidth = MediaQuery.of(context).size.width;
  //   return Scaffold(
  //     backgroundColor: Colors.white,
  //     body: Stack(children: [
  //       Stack(
  //         children: [
  //           CarouselSlider(
  //             items: imageList
  //                 .map(
  //                   (item) => Image.network(
  //                 item,
  //                 fit: BoxFit.fill,
  //                 width: double.infinity,
  //               ),
  //             )
  //                 .toList(),
  //             carouselController: carouselController,
  //             options: CarouselOptions(
  //               height: 400,
  //               scrollPhysics: const BouncingScrollPhysics(),
  //               autoPlay: true,
  //               viewportFraction: 1,
  //               onPageChanged: (index, reason) {
  //                 setState(() {
  //                   currentIndex = index;
  //                 });
  //               },
  //             ),
  //           ),
  //
  //           Padding(
  //             padding: const EdgeInsets.only(top: 30.0),
  //             child: Row(
  //               children: [
  //                 IconButton(
  //                   onPressed: () {
  //                     Navigator.pop(context);
  //                   },
  //                   icon: Icon(
  //                     Icons.arrow_back,
  //                     size: screenWidth * 0.09,
  //                     color: Colors.white,
  //                   ),
  //                 ),
  //                 Spacer(),
  //                 Icon(
  //                   Icons.send,
  //                   color: Colors.white,
  //                   size: screenWidth * 0.07,
  //                 ),
  //                 IconButton(
  //                   onPressed: () {},
  //                   icon: Icon(
  //                     Icons.more_vert,
  //                     size: screenWidth * 0.09,
  //                     color: Colors.white,
  //                   ),
  //                 ),
  //               ],
  //             ),
  //           ),
  //           SizedBox(
  //             height: 400,
  //             width: double.infinity,
  //             child: Column(
  //               crossAxisAlignment: CrossAxisAlignment.center,
  //               mainAxisAlignment: MainAxisAlignment.center,
  //               children: [
  //                 SizedBox(
  //                   height: 300,
  //                 ),
  //                 Row(
  //                   children: [
  //                     Spacer(),
  //                     InkWell(
  //                       onTap: () {
  //                       },
  //                       child: Container(
  //                         padding:
  //                         EdgeInsets.symmetric(horizontal: 15, vertical: 6.0),
  //                         decoration: BoxDecoration(
  //                           color: Colors.orange,
  //                             border: Border.all(color: Colors.white, width: 2),
  //                             borderRadius: BorderRadius.circular(8.0)),
  //                         child: Row(
  //                           children: [
  //                             Text(
  //                               "Gallery",
  //                               style: TextStyle(
  //                                   fontSize: 20,
  //                                   fontWeight: FontWeight.bold,
  //                                   color: Colors.white),
  //                             ),
  //                             SizedBox(
  //                               height: 8,
  //                             ),
  //                             Icon(Icons.photo,color: Colors.white,)
  //                           ],
  //                         ),
  //                       ),
  //                     ),
  //                     SizedBox(width: 10,),
  //                   ],
  //                 ),
  //               ],
  //             ),
  //           ),
  //         ],
  //       ),
  //
  //       SingleChildScrollView(
  //         child: Padding(
  //           padding: const EdgeInsets.only(top: 380.0),
  //           child: Container(
  //             decoration: BoxDecoration(
  //               color: Colors.grey.shade200,
  //               borderRadius: BorderRadius.only(topRight: Radius.circular(15),topLeft: Radius.circular(15))
  //             ),
  //             child: Column(
  //               children: [
  //
  //                 Container(
  //                   margin: EdgeInsets.all(10.0),
  //                   padding: EdgeInsets.all(10.0),
  //                   decoration: BoxDecoration(
  //                     color: Colors.white,
  //                     border: Border.all(color: Colors.grey.shade400, width: 1.5),
  //                     borderRadius: BorderRadius.circular(8), // Add border radius
  //                   ),
  //                   child: Column(
  //                     children: [
  //                       Row(
  //                         children: [
  //                           Text(
  //                             enName.split(",")[0],
  //                             style: TextStyle(
  //                                 color: Colors.deepOrangeAccent,
  //                                 fontSize: 24,
  //                                 fontWeight: FontWeight.bold),
  //                           ),
  //                           Spacer(),
  //                           BouncingWidgetInOut(
  //                             onPressed: () {
  //                               setState(() {
  //                                 gridList = !gridList;
  //                                 translateEn = gridList ? 'en' : 'hi';
  //                               });
  //                               getHotelDetails(widget.detailId);
  //                               getHoteldata();
  //                             },
  //                             bouncingType: BouncingType.bounceInAndOut,
  //                             child: Container(
  //                               height: 25,
  //                               width: 25,
  //                               decoration: BoxDecoration(
  //                                   borderRadius:
  //                                   BorderRadius.circular(4.0),
  //                                   color: gridList
  //                                       ? Colors.orange
  //                                       : Colors.white,
  //                                   border: Border.all(
  //                                       color: Colors.orange,
  //                                       width: 2)),
  //                               child: Center(
  //                                 child: Icon(
  //                                   Icons.translate,
  //                                   color: gridList
  //                                       ? Colors.white
  //                                       : Colors.orange,
  //                                   size: 18,
  //                                 ),
  //                               ),
  //                             ),
  //                           ),
  //                         ],
  //                       ),
  //
  //                       Row(
  //                         children: [
  //                           Icon(Icons.location_pin,color: Colors.orange,),
  //                           SizedBox(width: 6.0,),
  //                           Text(
  //                             enName.split(',').length > 1 ? enName.split(',')[1].trim() : '',
  //                             style: TextStyle(
  //                                 color: Colors.black,
  //                                 fontSize: 18,
  //                                 fontWeight: FontWeight.bold),
  //                           ),
  //                         ],
  //                       ),
  //
  //                       Row(
  //                         children: [
  //                           Icon(Icons.phone,color: Colors.orange,),
  //                           SizedBox(width: 6.0,),
  //                           Text(
  //                            "+91 000-000-000",
  //                             style: TextStyle(
  //                                 color: Colors.black,
  //                                 fontSize: 18,
  //                                 fontWeight: FontWeight.bold),
  //                           ),
  //                         ],
  //                       ),
  //
  //                       Row(
  //                         children: [
  //                           Icon(Icons.mail,color: Colors.orange,),
  //                           SizedBox(width: 6.0,),
  //                           Text(
  //                             "example@gmail.com",
  //                             style: TextStyle(
  //                                 color: Colors.black,
  //                                 fontSize: 18,
  //                                 fontWeight: FontWeight.bold),
  //                           ),
  //                         ],
  //                       ),
  //                     ],
  //                   ),
  //                 ),
  //
  //                 Container(
  //                   margin: EdgeInsets.all(10.0),
  //                   padding: EdgeInsets.all(10.0),
  //                   decoration: BoxDecoration(
  //                     color: Colors.white,
  //                     border: Border.all(color: Colors.grey.shade400, width: 1.5),
  //                     borderRadius: BorderRadius.circular(8), // Add border radius
  //                   ),
  //                   child: Column(
  //                     children: [
  //                       Html(data: enDescription),
  //                       Html(data: enAmenities),
  //                       Html(data: enRoomAmenities),
  //                     ],
  //                   ),
  //                 ),
  //
  //                 Container(
  //                   margin: EdgeInsets.all(10.0), padding: EdgeInsets.all(10.0), decoration: BoxDecoration(
  //                   color: Colors.white,
  //                   border: Border.all(color: Colors.grey.shade400, width: 1.5),
  //                   borderRadius: BorderRadius.circular(8), // Add border radius
  //                 ),
  //                   child: Column(
  //                     children: [
  //                       Html(data: enRoomType),
  //                       Html(data: enBookingInformation),
  //                     ],
  //                   ),
  //                 ),
  //               ],
  //             ),
  //           ),
  //         ),
  //       )
  //     ]),
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Hotel Details"),
          centerTitle: true,
          actions: [
            BouncingWidgetInOut(
              onPressed: () {
                setState(() {
                  gridList = !gridList;
                  translateEn = gridList ? 'en' : 'hi';
                });
                getHotelDetails(widget.detailId);
                getHoteldata();
              },
              bouncingType: BouncingType.bounceInAndOut,
              child: Container(
                height: 25,
                width: 25,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4.0),
                    color: gridList ? Colors.orange : Colors.white,
                    border: Border.all(color: Colors.orange, width: 2)),
                child: Center(
                  child: Icon(
                    Icons.translate,
                    color: gridList ? Colors.white : Colors.orange,
                    size: 18,
                  ),
                ),
              ),
            ),
          ],
        ),
        body: enName.isEmpty
            ? MahakalLoadingData(onReload: () {})
            : SingleChildScrollView(
                child: Column(
                  children: [
                    Stack(
                      children: [
                        CarouselSlider(
                          items: imageList
                              .map(
                                (item) => Image.network(
                                  item,
                                  fit: BoxFit.fill,
                                  width: double.infinity,
                                ),
                              )
                              .toList(),
                          carouselController: carouselController,
                          options: CarouselOptions(
                            height: 400,
                            scrollPhysics: const BouncingScrollPhysics(),
                            autoPlay: true,
                            viewportFraction: 1,
                            onPageChanged: (index, reason) {
                              setState(() {
                                currentIndex = index;
                              });
                            },
                          ),
                        ),
                        Positioned(
                          left: 0,
                          right: 0,
                          bottom: 20,
                          child: Row(
                            children: [
                              const Spacer(),
                              InkWell(
                                onTap: () {
                                  showModalBottomSheet(
                                      context: context,
                                      isScrollControlled: true,
                                      builder: (context) {
                                        return SizedBox(
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height /
                                              1.2,
                                          width:
                                              MediaQuery.of(context).size.width,
                                          child: Padding(
                                            padding: const EdgeInsets.all(10.0),
                                            child: SingleChildScrollView(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  //Title
                                                  Container(
                                                    padding:
                                                        const EdgeInsets.all(5),
                                                    margin:
                                                        const EdgeInsets.all(5),
                                                    width:
                                                        MediaQuery.of(context)
                                                            .size
                                                            .width,
                                                    decoration: BoxDecoration(
                                                      color: Colors.orange
                                                          .withOpacity(0.1),
                                                      border: Border.all(
                                                          color: Colors.orange,
                                                          width: 2),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8),
                                                    ),
                                                    child: const Text(
                                                      "✤ Suggestions ✤",
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: TextStyle(
                                                          fontSize: 20.0,
                                                          fontWeight:
                                                              FontWeight.w500),
                                                    ),
                                                  ),
                                                  const SizedBox(height: 10),
                                                  GridView.builder(
                                                    shrinkWrap: true,
                                                    physics:
                                                        const BouncingScrollPhysics(),
                                                    gridDelegate:
                                                        SliverGridDelegateWithFixedCrossAxisCount(
                                                      crossAxisCount:
                                                          2, // Number of columns
                                                      mainAxisSpacing: 8.0,
                                                      crossAxisSpacing: 8.0,
                                                      childAspectRatio: (Random()
                                                              .nextDouble() +
                                                          0.75), // Random aspect ratio
                                                    ),
                                                    itemCount: 20,
                                                    itemBuilder:
                                                        (context, index) {
                                                      return ClipRRect(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8),
                                                        child: Image.network(
                                                          "https://i0.wp.com/picjumbo.com/wp-content/uploads/amazing-stone-path-in-forest-free-image.jpg?w=600&quality=80",
                                                          fit: BoxFit.cover,
                                                        ),
                                                      );
                                                    },
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        );
                                      });
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 4.0),
                                  decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(0.4),
                                      border: Border.all(
                                          color: Colors.white38, width: 2),
                                      borderRadius: BorderRadius.circular(5.0)),
                                  child: const Row(
                                    children: [
                                      Icon(
                                        Icons.photo,
                                        color: Colors.white,
                                      ),
                                      SizedBox(
                                        width: 4,
                                      ),
                                      Text(
                                        "Gallery",
                                        style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    Container(
                      key: oneKey,
                      margin: const EdgeInsets.symmetric(
                          horizontal: 12.0, vertical: 8.0),
                      padding: const EdgeInsets.all(20.0),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.white,
                            Colors.orange.shade50,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.orange.withOpacity(0.2),
                            blurRadius: 15,
                            offset: const Offset(0, 6),
                            spreadRadius: 1,
                          ),
                        ],
                        border: Border.all(
                          color: Colors.orange.shade200,
                          width: 1.5,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Enhanced Title Row
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.orange.shade100.withOpacity(0.3),
                                  Colors.deepOrange.shade100.withOpacity(0.2),
                                ],
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  height: 50,
                                  width: 50,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.deepOrange.shade400,
                                        Colors.orange.shade600,
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.orange.withOpacity(0.3),
                                        blurRadius: 8,
                                        offset: const Offset(2, 2),
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    Icons.storefront_rounded,
                                    color: Colors.white,
                                    size: 28,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    translateEn == "en"
                                        ? enName.split(",")[0]
                                        : hiName.split(",")[0],
                                    style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.deepOrange.shade800,
                                      letterSpacing: 0.5,
                                      shadows: [
                                        Shadow(
                                          color: Colors.orange.withOpacity(0.1),
                                          blurRadius: 2,
                                          offset: const Offset(1, 1),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 20),

                          // Information Section with improved cards
                          Column(
                            children: [
                              _enhancedInfoRow(
                                icon: Icons.location_on_rounded,
                                label: "Address",
                                value: address,
                                iconColor: Colors.red.shade400,
                              ),
                              const SizedBox(height: 12),
                              _enhancedInfoRow(
                                icon: Icons.email_rounded,
                                label: "Email",
                                value: email,
                                iconColor: Colors.blue.shade400,
                              ),
                              const SizedBox(height: 12),
                              _enhancedInfoRow(
                                icon: Icons.phone_rounded,
                                label: "Phone",
                                value: phoneNo,
                                iconColor: Colors.green.shade400,
                              ),
                              const SizedBox(height: 12),
                              _enhancedInfoRow(
                                icon: Icons.local_post_office_rounded,
                                label: "Zip Code",
                                value: zipCode,
                                iconColor: Colors.purple.shade400,
                              ),
                              const SizedBox(height: 12),
                              _enhancedInfoRow(
                                icon: Icons.link_rounded,
                                label: "Website",
                                value: webLink,
                                isLink: true,
                                iconColor: Colors.cyan.shade400,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Container(
                      key: twoKey,
                      margin: const EdgeInsets.all(10.0),
                      padding: const EdgeInsets.all(10.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border:
                            Border.all(color: Colors.grey.shade400, width: 1.5),
                        borderRadius:
                            BorderRadius.circular(8), // Add border radius
                      ),
                      child: Column(
                        children: [
                          Html(
                              data: translateEn == "en"
                                  ? enDescription
                                  : hiDescription),
                          Html(
                              data: translateEn == "en"
                                  ? enAmenities
                                  : hiAmenities),
                          Html(
                              data: translateEn == "en"
                                  ? enRoomAmenities
                                  : hiRoomAmenities),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Title Row
                          Row(
                            children: [
                              Container(
                                height: 24,
                                width: 4,
                                decoration: BoxDecoration(
                                  color: Colors.orange.shade700,
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                "Reviews",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontFamily: 'Roboto',
                                  fontWeight: FontWeight.w700,
                                  color: Colors.black,
                                ),
                              ),
                              const Spacer(),
                              TextButton(
                                onPressed: () {
                                  showModalBottomSheet(
                                    context: context,
                                    isScrollControlled: true,
                                    backgroundColor: Colors.transparent,
                                    builder: (context) {
                                      return DraggableScrollableSheet(
                                        expand: false,
                                        initialChildSize: 0.9,
                                        minChildSize: 0.6,
                                        maxChildSize: 1.0,
                                        builder: (context, scrollController) {
                                          return Container(
                                            decoration: const BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.vertical(
                                                      top: Radius.circular(20)),
                                            ),
                                            child: Column(
                                              children: [
                                                const SizedBox(height: 12),

                                                // Drag Handle
                                                Container(
                                                  width: 60,
                                                  height: 5,
                                                  decoration: BoxDecoration(
                                                    color: Colors.grey.shade300,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10),
                                                  ),
                                                ),

                                                const SizedBox(height: 18),

                                                // Header Row
                                                Padding(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 16.0),
                                                  child: Row(
                                                    children: [
                                                      IconButton(
                                                        onPressed: () =>
                                                            Navigator.pop(
                                                                context),
                                                        icon: const Icon(
                                                          Icons
                                                              .arrow_back_ios_new_rounded,
                                                          color: Colors.orange,
                                                          size: 22,
                                                        ),
                                                      ),
                                                      const SizedBox(width: 6),
                                                      const Text(
                                                        "All Reviews",
                                                        style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.w700,
                                                          fontSize: 18,
                                                          color: Colors.black,
                                                        ),
                                                      ),
                                                      const Spacer(),
                                                      Text(
                                                        "${reviewModelList.length} Reviews",
                                                        style: const TextStyle(
                                                          fontSize: 14,
                                                          color: Colors.grey,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),

                                                const SizedBox(height: 8),
                                                Divider(
                                                    color: Colors.grey.shade300,
                                                    thickness: 1),

                                                // Scrollable Review List
                                                Expanded(
                                                  child: ListView.builder(
                                                    controller:
                                                        scrollController,
                                                    physics:
                                                        const BouncingScrollPhysics(),
                                                    padding:
                                                        const EdgeInsets.all(
                                                            12.0),
                                                    itemCount:
                                                        reviewModelList.length,
                                                    itemBuilder:
                                                        (context, index) {
                                                      final review =
                                                          reviewModelList[
                                                              index];
                                                      return Container(
                                                        margin: const EdgeInsets
                                                            .only(bottom: 12),
                                                        padding:
                                                            const EdgeInsets
                                                                .all(12),
                                                        decoration:
                                                            BoxDecoration(
                                                          color: Colors.white,
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(10),
                                                          border: Border.all(
                                                            color: Colors
                                                                .grey.shade300,
                                                            width: 1,
                                                          ),
                                                          boxShadow: [
                                                            BoxShadow(
                                                              color: Colors.grey
                                                                  .shade200,
                                                              blurRadius: 4,
                                                              offset:
                                                                  const Offset(
                                                                      0, 2),
                                                            ),
                                                          ],
                                                        ),
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Row(
                                                              children: [
                                                                ClipRRect(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              50),
                                                                  child: Image
                                                                      .network(
                                                                    review
                                                                        .userImage,
                                                                    height: 48,
                                                                    width: 48,
                                                                    fit: BoxFit
                                                                        .cover,
                                                                  ),
                                                                ),
                                                                const SizedBox(
                                                                    width: 10),
                                                                Expanded(
                                                                  child: Text(
                                                                    "@${review.userName}",
                                                                    style:
                                                                        const TextStyle(
                                                                      fontSize:
                                                                          16,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                      color: Colors
                                                                          .black,
                                                                    ),
                                                                  ),
                                                                ),
                                                                const Icon(
                                                                    Icons
                                                                        .more_vert,
                                                                    color: Colors
                                                                        .grey,
                                                                    size: 22),
                                                              ],
                                                            ),
                                                            const SizedBox(
                                                                height: 6),
                                                            Row(
                                                              children: [
                                                                Row(
                                                                  children: List
                                                                      .generate(
                                                                    5,
                                                                    (starIndex) =>
                                                                        Icon(
                                                                      Icons
                                                                          .star_rounded,
                                                                      color: starIndex <
                                                                              review
                                                                                  .star
                                                                          ? Colors
                                                                              .orange
                                                                          : Colors
                                                                              .grey
                                                                              .shade300,
                                                                      size: 20,
                                                                    ),
                                                                  ),
                                                                ),
                                                                const SizedBox(
                                                                    width: 8),
                                                                Text(
                                                                  formatDateString(
                                                                      "${review.createdAt}"),
                                                                  style:
                                                                      const TextStyle(
                                                                    fontSize:
                                                                        13,
                                                                    color: Colors
                                                                        .grey,
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                            const Divider(
                                                                height: 18,
                                                                color: Colors
                                                                    .grey),
                                                            Text(
                                                              review.comment,
                                                              style:
                                                                  const TextStyle(
                                                                fontSize: 15,
                                                                color: Colors
                                                                    .black87,
                                                                height: 1.4,
                                                              ),
                                                            ),
                                                          ],
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
                                    },
                                  );
                                },
                                child: const Text(
                                  "See All",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: Colors.orange,
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 8),

                          // Rating summary row
                          Row(
                            children: [
                              Text.rich(
                                TextSpan(
                                  children: [
                                    TextSpan(
                                      text: averageRating.toStringAsFixed(1),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w800,
                                        fontSize: 36,
                                        fontFamily: 'Roboto',
                                        color: Colors.black,
                                      ),
                                    ),
                                    const TextSpan(
                                      text: '/5',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 18,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 10),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: List.generate(
                                  5,
                                  (index) => Icon(
                                    Icons.star_rounded,
                                    color: index < averageRating
                                        ? Colors.orange
                                        : Colors.grey.shade300,
                                    size: 26,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 4),
                          Text(
                            "Based on ${reviewModelList.length} reviews",
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),

                          const SizedBox(height: 12),

                          // Review Cards
                          ListView.builder(
                            physics: const NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: reviewModelList.length > 2
                                ? 2
                                : reviewModelList.length,
                            itemBuilder: (context, index) {
                              final review = reviewModelList[index];
                              return Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.shade200,
                                      blurRadius: 6,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                  border: Border.all(
                                      color: Colors.grey.shade300, width: 1),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(50),
                                          child: Image.network(
                                            review.userImage,
                                            height: 48,
                                            width: 48,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            "@${review.userName}",
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w700,
                                              color: Colors.black,
                                            ),
                                          ),
                                        ),
                                        const Icon(Icons.more_vert,
                                            color: Colors.grey, size: 20),
                                      ],
                                    ),

                                    const SizedBox(height: 6),

                                    // Stars + date
                                    Row(
                                      children: [
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: List.generate(
                                            5,
                                            (starIndex) => Icon(
                                              Icons.star_rounded,
                                              color: starIndex < review.star
                                                  ? Colors.orange
                                                  : Colors.grey.shade300,
                                              size: 20,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          formatDateString(
                                              "${review.createdAt}"),
                                          style: const TextStyle(
                                            fontSize: 13,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ],
                                    ),

                                    const Divider(
                                        height: 18, color: Colors.grey),

                                    Text(
                                      review.comment,
                                      style: const TextStyle(
                                        fontSize: 15,
                                        color: Colors.black87,
                                        height: 1.4,
                                      ),
                                      maxLines: 3,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),

                          const SizedBox(height: 10),

                          // Add Comment Button
                          Center(
                            child: OutlinedButton.icon(
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.orange,
                                side: BorderSide(
                                    color: Colors.orange.shade400, width: 1.5),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 12),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10)),
                              ),
                              onPressed: () {
                                showReviewDialog(context);
                              },
                              icon: const Icon(Icons.edit_note_rounded),
                              label: const Text(
                                "Add Comment",
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      key: threeKey,
                      margin: const EdgeInsets.all(10.0),
                      padding: const EdgeInsets.all(10.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border:
                            Border.all(color: Colors.grey.shade400, width: 1.5),
                        borderRadius:
                            BorderRadius.circular(8), // Add border radius
                      ),
                      child: Column(
                        children: [
                          Html(
                              data: translateEn == "en"
                                  ? enRoomType
                                  : hiRoomType),
                          Html(
                              data: translateEn == "en"
                                  ? enBookingInformation
                                  : hiBookingInformation),
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                  ],
                ),
              ));
  }

  // Enhanced info row method
  Widget _enhancedInfoRow({
    required IconData icon,
    required String label,
    required String value,
    bool isLink = false,
    Color iconColor = Colors.deepOrange,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: Colors.grey.shade200,
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade600,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 2),
                isLink
                    ? GestureDetector(
                        onTap: () {
                          // Add your link handling logic here
                        },
                        child: Text(
                          value,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.blue.shade600,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      )
                    : Text(
                        value,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey.shade800,
                        ),
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _appBar(BuildContext context, ColorAnimated colorAnimated) {
    return PreferredSize(
      preferredSize: Size.fromHeight(isAppBarVisible
          ? kToolbarHeight + kTextTabBarHeight
          : kToolbarHeight),
      child: AppBar(
        backgroundColor: colorAnimated.background,
        elevation: 0,
        title: !isAppBarVisible
            ? Text(
                "Hotel Detail",
                style: TextStyle(color: colorAnimated.color),
              )
            : null,
        leading: InkWell(
          onTap: () {
            Navigator.pop(context);
          },
          child: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: !isAppBarVisible ? colorAnimated.color : Colors.transparent,
          ),
        ),
        bottom: isAppBarVisible
            ? TabBar(
                controller: _tabController,
                tabAlignment: TabAlignment.start,
                indicatorSize: TabBarIndicatorSize.tab,
                labelColor: Colors.orange,
                indicatorColor: Colors.orange,
                isScrollable: true,
                onTap: (index) {
                  // Handle tab tap
                  print('Tapped tab: $index');
                  Timer(const Duration(milliseconds: 500), () {
                    BuildContext? context;
                    switch (index) {
                      case 0:
                        context = oneKey.currentContext;
                        break;
                      case 1:
                        context = twoKey.currentContext;
                        break;
                      case 2:
                        context = threeKey.currentContext;
                        break;
                      case 3:
                        context = fourKey.currentContext;
                        break;
                      case 4:
                        context = fiveKey.currentContext;
                        break;
                      case 5:
                        context = sixKey.currentContext;
                        break;
                      case 6:
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
                tabs: const [
                  Tab(text: "Section 1"),
                  Tab(text: 'Section 2'),
                  Tab(text: 'Section 3'),
                ],
              )
            : null,
      ),
    );
  }
}
