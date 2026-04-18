import 'dart:math';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:mahakal/utill/loading_datawidget.dart';
import 'package:provider/provider.dart';
import 'package:tdk_bouncingwidget/tdk_bouncingwidget.dart';
import '../../data/datasource/remote/http/httpClient.dart';
import '../../main.dart';
import '../profile/controllers/profile_contrroller.dart';
import 'model/RestaurantModel.dart';
import 'model/city_model.dart';
import 'model/hotelnear_model.dart';
import 'model/restaurant_review_model.dart';
import 'model/templenearby_model.dart';

class RestaurantDetailView extends StatefulWidget {
  final String detailId;
  const RestaurantDetailView({super.key, required this.detailId});

  @override
  State<RestaurantDetailView> createState() => _RestaurantdetailState();
}

class _RestaurantdetailState extends State<RestaurantDetailView>
    with SingleTickerProviderStateMixin {
  List<Hotel> hotelModelList = <Hotel>[];
  List<Data> templeModelList = <Data>[];
  List<Restaurant> restaurantModelList = <Restaurant>[];
  List<City> cityModelList = <City>[];

  final CarouselSliderController carouselController =
      CarouselSliderController();
  var currentIndex = 0;

  bool gridList = false;
  String translateEn = 'hi';
  String userId = '';

  List<String> imageList = [];
  String latitude = "";
  String longitude = "";
  String phoneNo = "";
  String openTime = "";
  String closeTime = "";
  String emailId = "";

  String enName = "";
  String enStateName = "";
  String enDescription = "";
  String enMenuHighlights = "";
  String enMoreDetails = "";

  String hiName = "";
  String hiStateName = "";
  String hiDescription = "";
  String hiMenuHighlights = "";
  String hiMoreDetails = "";

  // review items
  List<Restaurantreview> reviewModelList = <Restaurantreview>[];
  double averageRating = 0.0;
  TextEditingController reviewController = TextEditingController();
  int getUserRating = 0; // Default rating

  String formatDateString(String dateString) {
    // Parse the input date string to a DateTime object
    DateTime parsedDate = DateTime.parse(dateString);

    // Format the DateTime object into the desired format
    String formattedDate = DateFormat('dd-MMMM-yyyy').format(parsedDate);

    return formattedDate;
  }

  void getRestaurantReview(String id) async {
    var res = await HttpService().postApi(
        "/api/v1/restaurant/getrestaurantcomment", {"restaurant_id": id});

    setState(() {
      reviewModelList.clear();
      List reviewList = res["data"];
      reviewModelList
          .addAll(reviewList.map((e) => Restaurantreview.fromJson(e)));

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

  void setRestaurantReview(String id) async {
    var res =
        await HttpService().postApi("/api/v1/restaurant/restaurantaddcomment", {
      "user_id": userId,
      "restaurant_id": id,
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
      getRestaurantReview(widget.detailId);
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
                      setRestaurantReview(widget.detailId);
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

  void getRestraurantDetails(String id) async {
    var res =
        await HttpService().postApi("/api/v1/restaurant/getrestaurantbyid", {
      "restaurant_id": id,
    });
    print("Api response $res");
    setState(() {
      enName = res["data"]["en_restaurant_name"];
      enStateName = res["data"]["states"]["name"];
      enDescription = res["data"]["en_description"];
      enMenuHighlights = res["data"]["en_menu_highlights"];
      enMoreDetails = res["data"]["en_more_details"];

      hiName = res["data"]["hi_restaurant_name"];
      hiStateName = res["data"]["states"]["name"];
      hiDescription = res["data"]["hi_description"];
      hiMenuHighlights = res["data"]["hi_menu_highlights"];
      hiMoreDetails = res["data"]["hi_more_details"];

      phoneNo = res["data"]["phone_no"].toString();
      emailId = res["data"]["email_id"];
      latitude = res["data"]["latitude"];
      longitude = res["data"]["longitude"];
      openTime = res["data"]["open_time"];
      closeTime = res["data"]["close_time"];
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
        {"latitude": latitude, "longitude": longitude});
    setState(() {
      hotelModelList.clear();
      List hotelList = res["data"];
      hotelModelList.addAll(hotelList.map((e) => Hotel.fromJson(e)));
    });
  }

  void getRestaurantData() async {
    var res = await HttpService().postApi("/api/v1/restaurant/getrestaurant",
        {"latitude": latitude, "longitude": longitude});
    setState(() {
      restaurantModelList.clear();
      List restaurantList = res["data"];
      restaurantModelList
          .addAll(restaurantList.map((e) => Restaurant.fromJson(e)));
    });
  }

  void getCityData() async {
    var res = await HttpService().postApi("/api/v1/cities/getcities",
        {"latitude": latitude, "longitude": longitude});
    setState(() {
      cityModelList.clear();
      List cityList = res["data"];
      cityModelList.addAll(cityList.map((e) => City.fromJson(e)));
    });
  }

  void getTempleData() async {
    var res = await HttpService().postApi("/api/v1/temple/gettemple",
        {"latitude": latitude, "longitude": longitude});
    setState(() {
      templeModelList.clear();
      List templeList = res["data"];
      templeModelList.addAll(templeList.map((e) => Data.fromJson(e)));
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    userId = Provider.of<ProfileController>(Get.context!, listen: false).userID;
    getRestraurantDetails(widget.detailId);
    getRestaurantReview(widget.detailId);
    print("restaurant user id ${widget.detailId}");
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: const Text("Restaurant"),
        centerTitle: true,
        actions: [
          BouncingWidgetInOut(
            onPressed: () {
              setState(() {
                gridList = !gridList;
                translateEn = gridList ? 'en' : 'hi';
              });
              getRestraurantDetails(widget.detailId);
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
      backgroundColor: Colors.white,
      body: enName.isEmpty
          ? MahakalLoadingData(onReload: () {})
          : SingleChildScrollView(
              child: Column(children: [
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
                                      height:
                                          MediaQuery.of(context).size.height /
                                              1.2,
                                      width: MediaQuery.of(context).size.width,
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
                                                margin: const EdgeInsets.all(5),
                                                width: MediaQuery.of(context)
                                                    .size
                                                    .width,
                                                decoration: BoxDecoration(
                                                  color: Colors.orange
                                                      .withOpacity(0.1),
                                                  border: Border.all(
                                                      color: Colors.orange,
                                                      width: 2),
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                                child: const Text(
                                                  "✤ Suggestions ✤",
                                                  textAlign: TextAlign.center,
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
                                                itemBuilder: (context, index) {
                                                  return ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8),
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
                  decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: const BorderRadius.only(
                          topRight: Radius.circular(15),
                          topLeft: Radius.circular(15))),
                  child: Column(
                    children: [
                      Container(
                        margin: const EdgeInsets.all(10.0),
                        padding: const EdgeInsets.all(10.0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(
                              color: Colors.grey.shade400, width: 1.5),
                          borderRadius:
                              BorderRadius.circular(8), // Add border radius
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Text(
                                  enName.split(",")[0],
                                  style: const TextStyle(
                                      color: Colors.deepOrangeAccent,
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                const Icon(
                                  Icons.watch_later_outlined,
                                  color: Colors.orange,
                                ),
                                Text(
                                  "Open & Close : $openTime-$closeTime",
                                  style: const TextStyle(
                                      color: Colors.deepOrangeAccent,
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                const Icon(
                                  Icons.location_pin,
                                  color: Colors.orange,
                                ),
                                const SizedBox(
                                  width: 6.0,
                                ),
                                Text(
                                  enName.split(',').length > 1
                                      ? enName.split(',')[1].trim()
                                      : '',
                                  style: const TextStyle(
                                      color: Colors.black,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                const Icon(
                                  Icons.phone,
                                  color: Colors.orange,
                                ),
                                const SizedBox(
                                  width: 6.0,
                                ),
                                Text(
                                  phoneNo,
                                  style: const TextStyle(
                                      color: Colors.black,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                const Icon(
                                  Icons.mail,
                                  color: Colors.orange,
                                ),
                                const SizedBox(
                                  width: 6.0,
                                ),
                                Text(
                                  emailId,
                                  style: const TextStyle(
                                      color: Colors.black,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.all(10.0),
                        padding: const EdgeInsets.all(10.0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(
                              color: Colors.grey.shade400, width: 1.5),
                          borderRadius:
                              BorderRadius.circular(8), // Add border radius
                        ),
                        child: Column(
                          children: [
                            Html(
                                data: translateEn == "en"
                                    ? enDescription
                                    : hiDescription),
                          ],
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.all(10.0),
                        padding: const EdgeInsets.all(10.0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(
                              color: Colors.grey.shade400, width: 1.5),
                          borderRadius:
                              BorderRadius.circular(8), // Add border radius
                        ),
                        child: Column(
                          children: [
                            Html(
                                data: translateEn == "en"
                                    ? enMoreDetails
                                    : hiMoreDetails),
                            Html(
                                data: translateEn == "en"
                                    ? enMenuHighlights
                                    : hiMenuHighlights),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                //reviews
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            height: 20,
                            width: 3,
                            color: Colors.orange,
                          ),
                          SizedBox(width: screenWidth * 0.03),
                          const Text(
                            "Reviews",
                            style: TextStyle(
                                fontSize: 16,
                                fontFamily: 'Roboto',
                                fontWeight: FontWeight.w700,
                                color: Colors.black),
                          ),
                          const Spacer(),
                          TextButton(
                              onPressed: () {
                                showModalBottomSheet(
                                    context: context,
                                    isScrollControlled: true,
                                    builder: (context) {
                                      return StatefulBuilder(builder:
                                          (BuildContext context,
                                              StateSetter modalSetter) {
                                        return SizedBox(
                                          height: MediaQuery.of(context)
                                              .size
                                              .height,
                                          child: Padding(
                                            padding: MediaQuery.of(context)
                                                .viewInsets,
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(16.0),
                                              child: SingleChildScrollView(
                                                physics:
                                                    const BouncingScrollPhysics(),
                                                child: Column(
                                                  children: [
                                                    const SizedBox(
                                                      height: 30,
                                                    ),
                                                    Row(
                                                      children: [
                                                        IconButton(
                                                            onPressed: () =>
                                                                Navigator.pop(
                                                                    context),
                                                            icon: const Icon(
                                                              CupertinoIcons
                                                                  .chevron_back,
                                                              color: Colors.red,
                                                            )),
                                                        const SizedBox(
                                                          width: 15,
                                                        ),
                                                        const Text(
                                                            "Read All Review"),
                                                        const Spacer(),
                                                      ],
                                                    ),
                                                    const SizedBox(
                                                      height: 30,
                                                    ),
                                                    SingleChildScrollView(
                                                      child: Column(
                                                        children: [
                                                          Text(
                                                            "Based on ${reviewModelList.length} Reviews",
                                                            style: const TextStyle(
                                                                color: Color
                                                                    .fromRGBO(
                                                                        176,
                                                                        176,
                                                                        176,
                                                                        1),
                                                                fontSize: 15,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500,
                                                                fontFamily:
                                                                    'Roboto'),
                                                          ),
                                                          Divider(
                                                            color: Colors
                                                                .grey.shade300,
                                                          ),
                                                          ListView.builder(
                                                            physics:
                                                                const NeverScrollableScrollPhysics(),
                                                            shrinkWrap: true,
                                                            itemCount:
                                                                reviewModelList
                                                                    .length,
                                                            itemBuilder:
                                                                (context,
                                                                    index) {
                                                              return Container(
                                                                margin:
                                                                    const EdgeInsets
                                                                        .only(
                                                                        top:
                                                                            10),
                                                                padding:
                                                                    const EdgeInsets
                                                                        .all(
                                                                        10),
                                                                decoration:
                                                                    BoxDecoration(
                                                                  color: Colors
                                                                      .grey
                                                                      .shade400,
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              8.0),
                                                                ),
                                                                child: Column(
                                                                  crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .start,
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .start,
                                                                  children: [
                                                                    Row(
                                                                      children: [
                                                                        SizedBox(
                                                                          height:
                                                                              50,
                                                                          width:
                                                                              50,
                                                                          child: ClipRRect(
                                                                              borderRadius: BorderRadius.circular(100.0),
                                                                              child: Image.network(
                                                                                reviewModelList[index].userImage,
                                                                                fit: BoxFit.cover,
                                                                              )),
                                                                        ),
                                                                        const SizedBox(
                                                                          width:
                                                                              5,
                                                                        ),
                                                                        Text(
                                                                          "@${reviewModelList[index].userName}",
                                                                          style: const TextStyle(
                                                                              fontSize: 20,
                                                                              fontWeight: FontWeight.bold,
                                                                              color: Colors.white),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                    const SizedBox(
                                                                      height: 8,
                                                                    ),
                                                                    Row(
                                                                      children: [
                                                                        Row(
                                                                          mainAxisSize:
                                                                              MainAxisSize.min,
                                                                          children:
                                                                              List.generate(
                                                                            5,
                                                                            // Total number of stars
                                                                            (starIndex) =>
                                                                                Icon(
                                                                              Icons.star,
                                                                              color: starIndex < reviewModelList[index].star ? Colors.amber : Colors.white,
                                                                              size: 18, // Yellow for filled stars, grey for unfilled
                                                                            ),
                                                                          ),
                                                                        ),
                                                                        const SizedBox(
                                                                          width:
                                                                              5,
                                                                        ),
                                                                        Text(
                                                                          formatDateString(
                                                                              "${reviewModelList[index].createdAt}"),
                                                                          style: const TextStyle(
                                                                              fontSize: 16,
                                                                              color: Colors.blueGrey),
                                                                        )
                                                                      ],
                                                                    ),
                                                                    // SizedBox(height: 10,),
                                                                    const Divider(
                                                                      color: Colors
                                                                          .grey,
                                                                    ),
                                                                    Text(
                                                                      reviewModelList[
                                                                              index]
                                                                          .comment,
                                                                      style: const TextStyle(
                                                                          fontSize:
                                                                              18,
                                                                          color:
                                                                              Colors.black),
                                                                    )
                                                                  ],
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
                              },
                              child: const Text(
                                "See All",
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  color: Colors.orange,
                                  fontSize: 15,
                                ),
                              ))
                        ],
                      ),
                      Row(
                        children: [
                          Text.rich(
                            TextSpan(
                              children: [
                                TextSpan(
                                    text: averageRating.toStringAsFixed(1),
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 35,
                                        fontFamily: 'Roboto',
                                        color: Color.fromRGBO(0, 0, 0, 1))),
                                const TextSpan(
                                  text: '/',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 20,
                                      color: Color.fromRGBO(0, 0, 0, 1)),
                                ),
                                const TextSpan(
                                    text: ' 5',
                                    style: TextStyle(
                                        color: Color.fromRGBO(176, 176, 176, 1),
                                        fontSize: 20)),
                              ],
                            ),
                          ),

                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: List.generate(
                              5,
                              (index) => Icon(
                                Icons.star,
                                color: index < averageRating
                                    ? Colors.amber
                                    : Colors.grey,
                                size: 25,
                              ),
                            ),
                          ),
                          // RatingBar.builder(
                          //   initialRating: highestRating,
                          //   minRating: 1,
                          //   direction: Axis.horizontal,
                          //   allowHalfRating: true,
                          //   itemCount: 5,
                          //   maxRating: 5,
                          //   itemPadding: EdgeInsets.symmetric(horizontal: screenWidth * 0.01),
                          //   itemBuilder: (context, _) => Icon(
                          //     Icons.star,
                          //     color: Colors.amber,
                          //   ),
                          //   onRatingUpdate: (value) {
                          //     setState(() {
                          //       highestRating = value;
                          //     });
                          //   },
                          // ),
                        ],
                      ),
                      Text(
                        "Based on ${reviewModelList.length} Reviews",
                        style: const TextStyle(
                            color: Color.fromRGBO(176, 176, 176, 1),
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            fontFamily: 'Roboto'),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      ListView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: reviewModelList.length > 2
                            ? 2
                            : reviewModelList.length,
                        itemBuilder: (context, index) {
                          return Container(
                            margin: const EdgeInsets.only(top: 10),
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade400,
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    SizedBox(
                                      height: 50,
                                      width: 50,
                                      child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(100.0),
                                          child: Image.network(
                                            reviewModelList[index].userImage,
                                            fit: BoxFit.cover,
                                          )),
                                    ),
                                    const SizedBox(
                                      width: 5,
                                    ),

                                    Text(
                                      "@${reviewModelList[index].userName}",
                                      style: const TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white),
                                    ),
                                    const Spacer(),
                                    // InkWell(
                                    //   onTap: (){
                                    //     setState(() {
                                    //       likeBtn = !likeBtn;
                                    //     });
                                    //   },
                                    //   child: Container(
                                    //     padding: EdgeInsets.all(4),
                                    //     decoration: BoxDecoration(
                                    //       border: Border.all(color: Colors.white,width: 1.5),
                                    //       borderRadius: BorderRadius.circular(100),
                                    //       color: likeBtn ? Colors.transparent : Colors.black38,
                                    //     ),
                                    //     child: Icon(
                                    //       likeBtn
                                    //           ? Icons.thumb_up :
                                    //       Icons.thumb_up_alt_outlined,
                                    //       color: likeBtn ? Colors.red : Colors.white,size: 18,),
                                    //   ),
                                    // ),
                                    // SizedBox(width: 10,),
                                    // InkWell(
                                    //   onTap: (){
                                    //     setState(() {
                                    //       disLikeBtn = !disLikeBtn;
                                    //     });
                                    //   },
                                    //   child: Container(
                                    //     padding: EdgeInsets.all(4),
                                    //     decoration: BoxDecoration(
                                    //       border: Border.all(color: Colors.white,width: 1.5),
                                    //       borderRadius: BorderRadius.circular(100),
                                    //       color: disLikeBtn ? Colors.transparent : Colors.black38,
                                    //     ),
                                    //     child: Icon(
                                    //       disLikeBtn
                                    //           ? Icons.thumb_down :
                                    //       Icons.thumb_down_alt_outlined,
                                    //       color: disLikeBtn ? Colors.blue : Colors.white,size: 18),
                                    //   ),
                                    // ),
                                    // SizedBox(width: 10,),
                                    const Icon(
                                      Icons.more_vert,
                                      color: Colors.white,
                                      size: 24,
                                    )
                                  ],
                                ),
                                const SizedBox(
                                  height: 8,
                                ),
                                Row(
                                  children: [
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: List.generate(
                                        5, // Total number of stars
                                        (starIndex) => Icon(
                                          Icons.star,
                                          color: starIndex <
                                                  reviewModelList[index].star
                                              ? Colors.amber
                                              : Colors.white,
                                          size:
                                              22, // Yellow for filled stars, grey for unfilled
                                        ),
                                      ),
                                    ),
                                    const SizedBox(
                                      width: 5,
                                    ),
                                    Text(
                                      formatDateString(
                                          "${reviewModelList[index].createdAt}"),
                                      style: const TextStyle(
                                          fontSize: 15, color: Colors.blueGrey),
                                    )
                                  ],
                                ),
                                // SizedBox(height: 10,),
                                const Divider(
                                  color: Colors.grey,
                                ),
                                Text(
                                  reviewModelList[index].comment,
                                  style: const TextStyle(
                                      fontSize: 18,
                                      color: Colors.black,
                                      overflow: TextOverflow.ellipsis),
                                  maxLines: 3,
                                )
                              ],
                            ),
                          );
                        },
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Container(
                        decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(
                                color: Colors.grey.shade400, width: 2),
                            borderRadius: BorderRadius.circular(8.0)),
                        child: Center(
                          child: TextButton(
                            onPressed: () {
                              // setState(() {
                              //    = !readalltrue;
                              //   readAll = 4;
                              // });
                              showReviewDialog(context);
                            },
                            child: const Text(
                              "Add Comment",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ]),
            ),
    );
  }
}
