import 'dart:async';
import 'dart:convert';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:mahakal/features/mandir_darshan/packagedetails.dart';
import 'package:mahakal/features/mandir_darshan/restaurant_details.dart';

import 'package:fluttertoast/fluttertoast.dart';
import 'package:hidable/hidable.dart';
import 'package:intl/intl.dart';
import 'package:mahakal/utill/loading_datawidget.dart';
import 'package:provider/provider.dart';
import 'package:tdk_bouncingwidget/tdk_bouncingwidget.dart';
import '../../data/datasource/remote/http/httpClient.dart';
import '../../main.dart';
import '../../utill/app_constants.dart';
import '../../utill/full_screen_image_slider.dart';
import '../auth/controllers/auth_controller.dart';
import '../donation/view/home_page/dynamic_view/dynamic_details/Detailspage.dart';
import '../profile/controllers/profile_contrroller.dart';
import 'city_details.dart';
import 'hotel_details.dart';
import 'model/RestaurantModel.dart';
import 'model/city_model.dart';
import 'model/hotelnear_model.dart';
import 'model/temple_review_model.dart';
import 'model/templenearby_model.dart';
import 'model/vippackage_list_model.dart';

class MandirDetailView extends StatefulWidget {
  String detailId;
  MandirDetailView({super.key, required this.detailId});

  @override
  _mandirState createState() => _mandirState();
}

class _mandirState extends State<MandirDetailView> {
  final PageController _pageController = PageController();
  final ScrollController scrollController = ScrollController();
  final CarouselSliderController carouselController =
      CarouselSliderController();
  Timer? _timer;
  var currentIndex = 0;
  int readAll = 2;
  bool readalltrue = false;
  bool gridList = false;
  String translateEn = 'hi';
  String userId = '';

  // english data
  String enName = "";
  String enMoreDetail = "";
  String enShortDescription = "";
  String enExpectDetails = "";
  String enTipsDetails = "";
  String enDetails = "";
  String enTempleKnowMore = "";
  String enTipsRestiction = "";
  String enFacilities = "";
  String enTempleServices = "";
  String enTempleAarti = "";
  String enTouristPlace = "";
  String enTempleLocalFood = "";

  // hindi data
  String hiName = "";
  String hiMoreDetail = "";
  String hiShortDescription = "";
  String hiExpectDetails = "";
  String hiTipsDetails = "";
  String hiDetails = "";
  String hiTempleKnowMore = "";
  String hiTipsRestiction = "";
  String hiFacilities = "";
  String hiTempleServices = "";
  String hiTempleAarti = "";
  String hiTouristPlace = "";
  String hiTempleLocalFood = "";

  String leadId = "";
  String templeId = "";
  String latitude = "";
  String longitude = "";
  String timingOpen = "";
  String timingClose = "";
  String requireTime = "";
  String entryFee = "";
  int vipDarshanStatus = 0;
  int trustId = 0;
  int highestRating = 0;

  List<String> imageList = [];
  List<Hotel> hotelModelList = <Hotel>[];
  List<Data> templeModelList = <Data>[];
  List<Restaurant> restaurantModelList = <Restaurant>[];
  List<City> cityModelList = <City>[];
  List<VipBookingPackage> vipPackageModel = <VipBookingPackage>[];

  // review items
  List<Templereview> reviewModelList = <Templereview>[];
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

  void getTempleReview(String id) async {
    var res = await HttpService()
        .postApi(AppConstants.templeCommentUrl, {"temple_id": id});

    setState(() {
      reviewModelList.clear();
      List reviewList = res["data"];
      reviewModelList.addAll(reviewList.map((e) => Templereview.fromJson(e)));

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

  void setTempleReview(String id) async {
    var res = await HttpService().postApi(AppConstants.setTempleReview, {
      "user_id": userId,
      "temple_id": id,
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
      getTempleReview(widget.detailId);
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
                      setTempleReview(widget.detailId);
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

  String convertTimeToAmPm(String time) {
    try {
      final dateTime = DateFormat('HH:mm:ss').parse(time);
      final formattedTime = DateFormat.jm().format(dateTime);
      return formattedTime;
    } catch (e) {
      print('Error parsing time: $e');
      return '';
    }
  }

  void getTemple(String id) async {
    var res = await HttpService().postApi(AppConstants.getTempleDetailUrl, {
      "temple_id": id,
    });
    print("Api response $res");
    setState(() {
      enName = res["data"]["en_name"];
      enDetails = res["data"]["en_details"];
      enMoreDetail = res["data"]["en_more_details"];
      enShortDescription = res["data"]["en_short_description"];
      enExpectDetails = res["data"]["en_expect_details"];
      enTipsDetails = res["data"]["en_tips_details"];
      enTempleKnowMore = res["data"]["en_temple_known"];
      enTipsRestiction = res["data"]["en_tips_restrictions"];
      enFacilities = res["data"]["en_facilities"];
      enTempleServices = res["data"]["en_temple_services"];
      enTempleAarti = res["data"]["en_temple_aarti"];
      enTouristPlace = res["data"]["en_tourist_place"];
      enTempleLocalFood = res["data"]["en_temple_local_food"];

      hiName = res["data"]["hi_name"];
      hiDetails = res["data"]["hi_details"];
      hiMoreDetail = res["data"]["hi_more_details"];
      hiShortDescription = res["data"]["hi_short_description"];
      hiExpectDetails = res["data"]["hi_expect_details"];
      hiTipsDetails = res["data"]["hi_tips_details"];
      hiTempleKnowMore = res["data"]["hi_temple_known"];
      hiTipsRestiction = res["data"]["hi_tips_restrictions"];
      hiFacilities = res["data"]["hi_facilities"];
      hiTempleServices = res["data"]["hi_temple_services"];
      hiTempleAarti = res["data"]["hi_temple_aarti"];
      hiTouristPlace = res["data"]["hi_tourist_place"];
      hiTempleLocalFood = res["data"]["hi_temple_local_food"];

      // templeId = res["data"]["id"].toString();
      latitude = res["data"]["latitude"];
      longitude = res["data"]["longitude"];
      requireTime = res["data"]["require_time"];
      timingOpen = res["data"]["opening_time"];
      timingClose = res["data"]["closeing_time"];
      entryFee = res["data"]["entry_fee"];
      vipDarshanStatus = res["data"]["vip_darshan_status"];
      trustId = res["data"]["trust_id"];
      imageList = List<String>.from(res["data"]["image_list"]);
      List vipList = res["data"]["vip_booking_package"];
      vipPackageModel.addAll(vipList.map((e) => VipBookingPackage.fromJson(e)));
    });
    packageLead(vipPackageModel[0].id.toString(), vipPackageModel[0].price,
        vipPackageModel[0].package, vipPackageModel[0].name, false);
    getHoteldata();
    getRestaurantData();
    getCityData();
    getTempleData();
  }

  void getHoteldata() async {
    var res = await HttpService().postApi(AppConstants.getHotelUrl,
        {"latitude": latitude, "longitude": longitude});
    setState(() {
      hotelModelList.clear();
      List hotelList = res["data"];
      hotelModelList.addAll(hotelList.map((e) => Hotel.fromJson(e)));
    });
  }

  void getRestaurantData() async {
    var res = await HttpService().postApi(AppConstants.getRestaurantUrl,
        {"latitude": latitude, "longitude": longitude});
    setState(() {
      restaurantModelList.clear();
      List restaurantList = res["data"];
      restaurantModelList
          .addAll(restaurantList.map((e) => Restaurant.fromJson(e)));
    });
  }

  void getCityData() async {
    var res = await HttpService().postApi(AppConstants.getCityUrl,
        {"latitude": latitude, "longitude": longitude});
    setState(() {
      cityModelList.clear();
      List cityList = res["data"];
      cityModelList.addAll(cityList.map((e) => City.fromJson(e)));
    });
  }

  void getTempleData() async {
    print("Mandir Darshan Testing latitude: $latitude, longitude: $longitude");
    var res = await HttpService().postApi(AppConstants.getTempleUrl,
        {"latitude": latitude, "longitude": longitude});
    setState(() {
      templeModelList.clear();
      List templeList = res["data"];
      templeModelList.addAll(templeList.map((e) => Data.fromJson(e)));
    });
  }

  Future<void> packageLead(
      String id, price, packageName, name, bool isPackage) async {
    print(
        "check id ${widget.detailId} \n $id \n $name \n $price \n $packageName \n $userId");
    String userToken =
        Provider.of<AuthController>(Get.context!, listen: false).getUserToken();
    final response = await http.post(
      Uri.parse("${AppConstants.baseUrl}${AppConstants.packageTempleLead}"),
      headers: {
        'Authorization': 'Bearer $userToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        "id": id, //package id
        "temple_id": widget.detailId,
        "user_id": userId,
        "price": price,
        "package_name": packageName, //package
        "name": name,
      }),
    );
    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      setState(() {
        leadId = data["data"]["lead_id"].toString();
      });

      if (isPackage) {
        Navigator.push(
            context,
            CupertinoPageRoute(
                builder: (context) => PackageDetailView(id: leadId)));
      }

      print("Response Code: ${response.statusCode} $leadId");
      print("Response Body: ${response.body} ");
      print("Lead Id $leadId");
    }
  }

  // void packageLead(String id,price,packageName,name) async {
  //   print("check id ${widget.detailId} \n ${id} \n $name \n $price \n $packageName \n $userId");
  //   var res = await HttpService().postApi("/api/v1/temple/lead-add",
  //       {
  //         "id":id,    //package id
  //         "temple_id": widget.detailId,
  //         "user_id":userId,
  //         "price":price,
  //         "package_name":packageName,  //package
  //         "name":name,
  //       });
  //
  //   setState(() {
  //     leadId = res["data"]["lead_id"].toString();
  //   });
  //   print("APi response success ");
  // }

  void _showPackageBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 20,
              spreadRadius: 0,
            ),
          ],
        ),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(25)),
              ),
              child: Row(
                children: [
                  Icon(Icons.workspace_premium, color: Colors.orange.shade700),
                  const SizedBox(width: 12),
                  Text(
                    'Available Packages',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange.shade900,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.grey),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            // Package List
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: vipPackageModel.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  return Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.shade200,
                          blurRadius: 8,
                          spreadRadius: 2,
                        ),
                      ],
                      border: Border.all(color: Colors.grey.shade100),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16),
                      leading: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.orange.shade100,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.temple_hindu,
                            color: Colors.orange.shade700),
                      ),
                      title: Text(
                        vipPackageModel[index].package,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          Text(
                            vipPackageModel[index].name,
                            style: TextStyle(color: Colors.grey.shade600),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "₹${vipPackageModel[index].price}",
                            style: TextStyle(
                              color: Colors.orange.shade700,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                      trailing: const Icon(Icons.chevron_right,
                          color: Colors.deepOrange),
                      onTap: () {
                        // Navigator.push(
                        //     context,
                        //     CupertinoPageRoute(builder: (context) =>
                        //         const PackageDetailView()));

                        packageLead(
                            vipPackageModel[index].id.toString(),
                            vipPackageModel[index].price,
                            vipPackageModel[index].package,
                            vipPackageModel[index].name,
                            true);
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    userId = Provider.of<ProfileController>(Get.context!, listen: false).userID;
    getTemple(widget.detailId);
    print("mandir user id ${widget.detailId}");
    getTempleReview(widget.detailId);
  }

  @override
  void dispose() {
    // Dispose of the timer to prevent memory leaks
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;
    return enName.isEmpty
        ? MahakalLoadingData(onReload: () {})
        : Scaffold(
            resizeToAvoidBottomInset: false,
            floatingActionButtonLocation:
                FloatingActionButtonLocation.centerDocked,
            floatingActionButton: Column(
              children: [
                const Spacer(),
                Row(
                  children: [
                    const Spacer(),
                    SizedBox(
                      width: 60,
                      child: Hidable(
                        controller: scrollController,
                        child: FloatingActionButton(
                          onPressed: () {
                            if (scrollController.hasClients) {
                              // ✅ Check if controller is attached
                              scrollController.animateTo(
                                0.0,
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.ease,
                              );
                            } else {
                              print(
                                  "ScrollController is not attached to any scroll view!");
                            }
                          },
                          backgroundColor: Theme.of(context).primaryColor,
                          child: const Icon(
                            Icons.arrow_circle_up_outlined,
                            color: Colors.white,
                            size: 40,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                ),
                vipDarshanStatus == 0
                    ? const SizedBox()
                    : Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Row(
                          children: [
                            // VIP Darshan Button
                            Expanded(
                              child: InkWell(
                                onTap: () {
                                  print("chal rha he");
                                  _showPackageBottomSheet(context);
                                },
                                borderRadius: BorderRadius.circular(14),
                                child: Container(
                                  height: 45,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.deepOrange.shade700,
                                        Colors.orange.shade600,
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius: BorderRadius.circular(14),
                                    boxShadow: [
                                      BoxShadow(
                                        color:
                                            Colors.deepOrange.withOpacity(0.3),
                                        blurRadius: 12,
                                        spreadRadius: 2,
                                        offset: const Offset(0, 6),
                                      )
                                    ],
                                    border: Border.all(
                                      color: Colors.orange.shade300
                                          .withOpacity(0.5),
                                      width: 1,
                                    ),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(6),
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color:
                                                Colors.white.withOpacity(0.2),
                                          ),
                                          child: const Icon(
                                            Icons.workspace_premium_rounded,
                                            size: 20,
                                            color: Colors.white,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          'VIP Darshan',
                                          style: GoogleFonts.poppins(
                                            color: Colors.white,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            letterSpacing: 0.8,
                                            shadows: [
                                              Shadow(
                                                color: Colors.black
                                                    .withOpacity(0.3),
                                                blurRadius: 4,
                                                offset: const Offset(1, 1),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(width: 10),

                            // Donate to Temple Button
                            Expanded(
                              child: InkWell(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    CupertinoPageRoute(
                                      builder: (context) => DetailsPage(
                                        myId: trustId,
                                        image: imageList[0],
                                      ),
                                    ),
                                  );
                                },
                                borderRadius: BorderRadius.circular(14),
                                child: Container(
                                  height: 45,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.blue.shade600,
                                        Colors.indigo.shade400,
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius: BorderRadius.circular(14),
                                    boxShadow: [
                                      BoxShadow(
                                        color:
                                            Colors.deepPurple.withOpacity(0.3),
                                        blurRadius: 12,
                                        spreadRadius: 2,
                                        offset: const Offset(0, 6),
                                      )
                                    ],
                                    border: Border.all(
                                      color: Colors.indigo.shade200
                                          .withOpacity(0.5),
                                      width: 1,
                                    ),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(6),
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color:
                                                Colors.white.withOpacity(0.2),
                                          ),
                                          child: const Icon(
                                            Icons.volunteer_activism_rounded,
                                            size: 20,
                                            color: Colors.white,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          'Donation',
                                          style: GoogleFonts.poppins(
                                            color: Colors.white,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            letterSpacing: 0.8,
                                            shadows: [
                                              Shadow(
                                                color: Colors.black
                                                    .withOpacity(0.3),
                                                blurRadius: 4,
                                                offset: const Offset(1, 1),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
              ],
            ),
            backgroundColor: Colors.white,
            body: SafeArea(
              child: SingleChildScrollView(
                controller: scrollController, // Attach the controller here
                child: Column(
                  children: [
                    Hidable(
                      preferredWidgetSize:
                          const Size.fromHeight(kToolbarHeight),
                      controller:
                          ScrollController(), // Controls the scroll behavior
                      wOpacity:
                          true, // Set to true for fading effect when hiding
                      child: AppBar(
                        title: const Text('Mandir details'),
                        actions: [
                          BouncingWidgetInOut(
                            onPressed: () {
                              setState(() {
                                gridList = !gridList;
                                translateEn = gridList ? 'en' : 'hi';
                              });
                              getTemple(widget.detailId);
                              getHoteldata();
                            },
                            bouncingType: BouncingType.bounceInAndOut,
                            child: Container(
                              height: 25,
                              width: 25,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(4.0),
                                  color:
                                      gridList ? Colors.orange : Colors.white,
                                  border: Border.all(
                                      color: Colors.orange, width: 2)),
                              child: Center(
                                child: Icon(
                                  Icons.translate,
                                  color:
                                      gridList ? Colors.white : Colors.orange,
                                  size: 18,
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
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
                          right: 10,
                          bottom: 10,
                          child: InkWell(
                            onTap: () {
                              showModalBottomSheet(
                                  context: context,
                                  isScrollControlled: true,
                                  builder: (context) {
                                    return FullScreenImageSlider(
                                      images: imageList,
                                    );
                                  });
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.white),
                              ),
                              child: const Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 4),
                                child: Text(
                                  "Gallery",
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                    SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.grey.shade50,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Title with ellipsis for overflow
                                  Text(
                                    translateEn == "en" ? enName : hiName,
                                    style: TextStyle(
                                      color: Colors.orange
                                          .shade800, // Darker orange for better contrast
                                      fontSize:
                                          22, // Slightly reduced for better balance
                                      fontWeight:
                                          FontWeight.w700, // Slightly less bold
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    maxLines: 2, // Allow two lines if needed
                                  ),

                                  const SizedBox(
                                      height:
                                          8), // Add spacing between elements

                                  // Rating row with improved styling
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons
                                            .star_rounded, // Rounded star looks more modern
                                        color: Colors.amber,
                                        size:
                                            24, // Slightly smaller for balance
                                      ),
                                      const SizedBox(width: 6),
                                      const Text(
                                        '4.9',
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize:
                                              18, // Slightly larger for emphasis
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        '(7.37k+ Reviews)',
                                        style: TextStyle(
                                          color: Colors
                                              .grey.shade700, // Softer color
                                          fontSize:
                                              14, // Smaller for secondary info
                                        ),
                                      ),
                                    ],
                                  ),

                                  const SizedBox(
                                      height: 12), // Add spacing before buttons

                                  const SizedBox(
                                    height: 10,
                                  ),
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(8),
                                        boxShadow: const [
                                          BoxShadow(
                                              color: Colors.grey,
                                              blurRadius: 6,
                                              spreadRadius: 1)
                                        ] // Add border radius
                                        ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        // description
                                        Html(
                                            data: translateEn == "en"
                                                ? enShortDescription
                                                : hiShortDescription),
                                        const SizedBox(height: 10),

                                        // Expect
                                        Html(
                                            data: translateEn == "en"
                                                ? enExpectDetails
                                                : hiExpectDetails),
                                        const SizedBox(height: 10),

                                        //Tips
                                        Html(
                                            data: translateEn == "en"
                                                ? enTipsDetails
                                                : hiTipsDetails),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          //near by to reviews screeen
                          Container(
                            decoration: const BoxDecoration(
                              color: Colors.white,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // religious place
                                templeModelList.isEmpty
                                    ? const SizedBox()
                                    : Container(
                                        width: double.infinity,
                                        decoration: BoxDecoration(
                                          color: Colors.orange.shade50,
                                        ),
                                        child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Container(
                                                padding:
                                                    const EdgeInsets.all(8),
                                                margin:
                                                    const EdgeInsets.all(10),
                                                decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8.0)),
                                                child: const Row(
                                                  children: [
                                                    SizedBox(
                                                      width: 10,
                                                    ),
                                                    Text(
                                                      'Religious Places',
                                                      style: TextStyle(
                                                        color: Colors.orange,
                                                        fontSize: 20,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                    Spacer(),
                                                    Text(
                                                      'See All',
                                                      style: TextStyle(
                                                        color: Colors.orange,
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              SingleChildScrollView(
                                                scrollDirection:
                                                    Axis.horizontal,
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: Row(
                                                    children: List.generate(
                                                      templeModelList.length,
                                                      (index) => InkWell(
                                                        onTap: () {
                                                          print("object");
                                                          Navigator.push(
                                                              context,
                                                              CupertinoPageRoute(
                                                                  builder:
                                                                      (context) =>
                                                                          MandirDetailView(
                                                                            detailId:
                                                                                "${templeModelList[index].id}",
                                                                          )));
                                                          // Navigator.push(context, CupertinoPageRoute(builder: (context) => TestScreen()));
                                                        },
                                                        child: Container(
                                                          height: 180,
                                                          width: 150,
                                                          margin:
                                                              const EdgeInsets
                                                                  .symmetric(
                                                                  horizontal:
                                                                      5.0),
                                                          decoration: BoxDecoration(
                                                              color:
                                                                  Colors.white,
                                                              border: Border.all(
                                                                  color: Colors
                                                                      .grey
                                                                      .shade300),
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          8.0)),
                                                          child: Column(
                                                            children: [
                                                              ClipRRect(
                                                                borderRadius: const BorderRadius
                                                                    .only(
                                                                    topLeft: Radius
                                                                        .circular(
                                                                            10),
                                                                    topRight: Radius
                                                                        .circular(
                                                                            10)),
                                                                child: Image
                                                                    .network(
                                                                  "${templeModelList[index].image}",
                                                                  height: 100,
                                                                  width: double
                                                                      .infinity,
                                                                  fit: BoxFit
                                                                      .cover,
                                                                ),
                                                              ),
                                                              Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                        .only(
                                                                        top: 10,
                                                                        left:
                                                                            5.0),
                                                                child: Text(
                                                                  "${translateEn == "en" ? templeModelList[index].enName : templeModelList[index].hiName}",
                                                                  style: const TextStyle(
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                      fontSize:
                                                                          16),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ]),
                                      ),

                                // near by hotel
                                hotelModelList.isEmpty
                                    ? const SizedBox()
                                    : Container(
                                        width: double.infinity,
                                        decoration: BoxDecoration(
                                          color: Colors.blue.shade50,
                                        ),
                                        child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Container(
                                                padding:
                                                    const EdgeInsets.all(8),
                                                margin:
                                                    const EdgeInsets.all(10),
                                                decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8.0)),
                                                child: const Row(
                                                  children: [
                                                    SizedBox(
                                                      width: 10,
                                                    ),
                                                    Text(
                                                      'Near by Hotels',
                                                      style: TextStyle(
                                                        color: Colors.blue,
                                                        fontSize: 20,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                    Spacer(),
                                                    Icon(
                                                      Icons.arrow_forward_ios,
                                                      color: Colors.blue,
                                                    )
                                                  ],
                                                ),
                                              ),
                                              SingleChildScrollView(
                                                scrollDirection:
                                                    Axis.horizontal,
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: Row(
                                                    children: List.generate(
                                                      hotelModelList.length,
                                                      (index) => InkWell(
                                                        onTap: () {
                                                          Navigator.push(
                                                            context,
                                                            CupertinoPageRoute(
                                                                builder:
                                                                    (context) =>
                                                                        HotelDetailView(
                                                                          detailId:
                                                                              "${hotelModelList[index].id}",
                                                                        )),
                                                          );
                                                        },
                                                        child: Container(
                                                          height: 120,
                                                          width: 260,
                                                          margin:
                                                              const EdgeInsets
                                                                  .symmetric(
                                                                  horizontal:
                                                                      5.0),
                                                          decoration: BoxDecoration(
                                                              border: Border.all(
                                                                  color: Colors
                                                                      .grey
                                                                      .shade300),
                                                              color:
                                                                  Colors.white,
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          10)),
                                                          child: Row(
                                                            children: [
                                                              Expanded(
                                                                child: Padding(
                                                                  padding:
                                                                      const EdgeInsets
                                                                          .all(
                                                                          5.0),
                                                                  child: Column(
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .start,
                                                                    children: [
                                                                      Text(
                                                                        translateEn ==
                                                                                "en"
                                                                            ? hotelModelList[index].enHotelName
                                                                            : hotelModelList[index].hiHotelName,
                                                                        style:
                                                                            const TextStyle(
                                                                          fontWeight:
                                                                              FontWeight.bold,
                                                                          color:
                                                                              Colors.black,
                                                                          fontSize:
                                                                              16,
                                                                          overflow:
                                                                              TextOverflow.ellipsis,
                                                                        ),
                                                                        maxLines:
                                                                            4,
                                                                      ),
                                                                      // Text(
                                                                      //   hotelModelList[index].enAmenities,
                                                                      //   style: TextStyle(
                                                                      //     fontSize: 14,
                                                                      //     overflow: TextOverflow.ellipsis,
                                                                      //   ),
                                                                      //   maxLines: 2,
                                                                      // ),
                                                                    ],
                                                                  ),
                                                                ),
                                                              ),
                                                              Expanded(
                                                                child:
                                                                    ClipRRect(
                                                                  borderRadius: const BorderRadius
                                                                      .only(
                                                                      bottomRight:
                                                                          Radius.circular(
                                                                              10),
                                                                      topRight:
                                                                          Radius.circular(
                                                                              10)),
                                                                  child: Image
                                                                      .network(
                                                                    hotelModelList[
                                                                            index]
                                                                        .image,
                                                                    height: 120,
                                                                    width: double
                                                                        .infinity,
                                                                    fit: BoxFit
                                                                        .cover,
                                                                  ),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ]),
                                      ),

                                // near by food
                                restaurantModelList.isEmpty
                                    ? const SizedBox()
                                    : Container(
                                        width: double.infinity,
                                        decoration: BoxDecoration(
                                          color: Colors.green.shade50,
                                        ),
                                        child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Container(
                                                padding:
                                                    const EdgeInsets.all(8),
                                                margin:
                                                    const EdgeInsets.all(10),
                                                decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8.0)),
                                                child: const Row(
                                                  children: [
                                                    SizedBox(
                                                      width: 10,
                                                    ),
                                                    Text(
                                                      'Foodie Hotspot',
                                                      style: TextStyle(
                                                        color: Colors.green,
                                                        fontSize: 20,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                    Spacer(),
                                                    Icon(
                                                      Icons.arrow_forward_ios,
                                                      color: Colors.green,
                                                    )
                                                  ],
                                                ),
                                              ),
                                              SingleChildScrollView(
                                                scrollDirection:
                                                    Axis.horizontal,
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: Row(
                                                    children: List.generate(
                                                      restaurantModelList
                                                          .length,
                                                      (index) => InkWell(
                                                        onTap: () {
                                                          Navigator.push(
                                                            context,
                                                            CupertinoPageRoute(
                                                              builder: (context) =>
                                                                  RestaurantDetailView(
                                                                detailId:
                                                                    "${restaurantModelList[index].id}",
                                                              ),
                                                            ),
                                                          );
                                                        },
                                                        child: Container(
                                                          height: 120,
                                                          width: 260,
                                                          margin:
                                                              const EdgeInsets
                                                                  .symmetric(
                                                                  horizontal:
                                                                      5.0),
                                                          decoration: BoxDecoration(
                                                              color:
                                                                  Colors.white,
                                                              border: Border.all(
                                                                  color: Colors
                                                                      .grey
                                                                      .shade300),
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          10)),
                                                          child: Row(
                                                            children: [
                                                              Expanded(
                                                                child: Padding(
                                                                  padding:
                                                                      const EdgeInsets
                                                                          .all(
                                                                          5.0),
                                                                  child: Column(
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .start,
                                                                    children: [
                                                                      Text(
                                                                        translateEn ==
                                                                                "en"
                                                                            ? restaurantModelList[index].enRestaurantName
                                                                            : restaurantModelList[index].hiRestaurantName,
                                                                        style: const TextStyle(
                                                                            fontWeight: FontWeight
                                                                                .bold,
                                                                            fontSize:
                                                                                16,
                                                                            overflow:
                                                                                TextOverflow.ellipsis),
                                                                        maxLines:
                                                                            4,
                                                                      ),
                                                                      const SizedBox(
                                                                        height:
                                                                            10,
                                                                      ),
                                                                      // Text(restaurantModelList[index].title,style: TextStyle(fontSize: 12),),
                                                                    ],
                                                                  ),
                                                                ),
                                                              ),
                                                              Expanded(
                                                                child:
                                                                    ClipRRect(
                                                                  borderRadius: const BorderRadius
                                                                      .only(
                                                                      bottomRight:
                                                                          Radius.circular(
                                                                              10),
                                                                      topRight:
                                                                          Radius.circular(
                                                                              10)),
                                                                  child: Image
                                                                      .network(
                                                                    restaurantModelList[
                                                                            index]
                                                                        .image
                                                                        .toString(),
                                                                    height: 120,
                                                                    width: double
                                                                        .infinity,
                                                                    fit: BoxFit
                                                                        .cover,
                                                                  ),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ]),
                                      ),

                                // near by cities
                                cityModelList.isEmpty
                                    ? const SizedBox()
                                    : Container(
                                        width: double.infinity,
                                        decoration: BoxDecoration(
                                          color: Colors.purple.shade50,
                                        ),
                                        child: ClipRRect(
                                          borderRadius: const BorderRadius.only(
                                              topLeft: Radius.circular(10),
                                              bottomLeft: Radius.circular(10)),
                                          child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Container(
                                                  padding:
                                                      const EdgeInsets.all(8),
                                                  margin:
                                                      const EdgeInsets.all(10),
                                                  decoration: BoxDecoration(
                                                      color: Colors.white,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8.0)),
                                                  child: const Row(
                                                    children: [
                                                      Text(
                                                        'Near by Places',
                                                        style: TextStyle(
                                                          color: Colors.purple,
                                                          fontSize: 20,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                      Spacer(),
                                                      Icon(
                                                        Icons.arrow_forward_ios,
                                                        color: Colors.purple,
                                                      )
                                                    ],
                                                  ),
                                                ),
                                                SingleChildScrollView(
                                                  scrollDirection:
                                                      Axis.horizontal,
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            8.0),
                                                    child: Row(
                                                      children: List.generate(
                                                        cityModelList.length,
                                                        (index) => InkWell(
                                                          onTap: () {
                                                            Navigator.push(
                                                              context,
                                                              CupertinoPageRoute(
                                                                builder:
                                                                    (context) =>
                                                                        CitydarshanView(
                                                                  detailId:
                                                                      "${cityModelList[index].id}",
                                                                ),
                                                              ),
                                                            );
                                                          },
                                                          child: Container(
                                                            height: 120,
                                                            width: 260,
                                                            margin:
                                                                const EdgeInsets
                                                                    .symmetric(
                                                                    horizontal:
                                                                        5.0),
                                                            decoration: BoxDecoration(
                                                                color: Colors
                                                                    .white,
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            10)),
                                                            child: Row(
                                                              children: [
                                                                Expanded(
                                                                  child:
                                                                      Padding(
                                                                    padding:
                                                                        const EdgeInsets
                                                                            .all(
                                                                            5.0),
                                                                    child:
                                                                        Column(
                                                                      crossAxisAlignment:
                                                                          CrossAxisAlignment
                                                                              .start,
                                                                      children: [
                                                                        Text(
                                                                          translateEn == "en"
                                                                              ? cityModelList[index].enCity
                                                                              : cityModelList[index].hiCity,
                                                                          style: const TextStyle(
                                                                              fontWeight: FontWeight.bold,
                                                                              fontSize: 18),
                                                                        ),
                                                                        const SizedBox(
                                                                          height:
                                                                              10,
                                                                        ),
                                                                        Text(
                                                                          translateEn == "en"
                                                                              ? cityModelList[index].enShortDesc
                                                                              : cityModelList[index].hiShortDesc,
                                                                          style: const TextStyle(
                                                                              fontSize: 12,
                                                                              overflow: TextOverflow.ellipsis),
                                                                          maxLines:
                                                                              3,
                                                                        ),
                                                                        // Text(travels[index].distance,style: TextStyle(fontSize: 12),),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                ),
                                                                Expanded(
                                                                  child:
                                                                      ClipRRect(
                                                                    borderRadius: const BorderRadius
                                                                        .only(
                                                                        bottomRight:
                                                                            Radius.circular(
                                                                                10),
                                                                        topRight:
                                                                            Radius.circular(10)),
                                                                    child: Image
                                                                        .network(
                                                                      cityModelList[
                                                                              index]
                                                                          .image
                                                                          .toString(),
                                                                      height:
                                                                          120,
                                                                      width: double
                                                                          .infinity,
                                                                      fit: BoxFit
                                                                          .cover,
                                                                    ),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ]),
                                        ),
                                      ),

                                //reviews
                                Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                                      return StatefulBuilder(
                                                          builder: (BuildContext
                                                                  context,
                                                              StateSetter
                                                                  modalSetter) {
                                                        return SizedBox(
                                                          height: MediaQuery.of(
                                                                  context)
                                                              .size
                                                              .height,
                                                          child: Padding(
                                                            padding:
                                                                MediaQuery.of(
                                                                        context)
                                                                    .viewInsets,
                                                            child: Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .all(
                                                                      16.0),
                                                              child:
                                                                  SingleChildScrollView(
                                                                physics:
                                                                    const BouncingScrollPhysics(),
                                                                child: Column(
                                                                  children: [
                                                                    const SizedBox(
                                                                      height:
                                                                          30,
                                                                    ),
                                                                    Row(
                                                                      children: [
                                                                        IconButton(
                                                                            onPressed: () =>
                                                                                Navigator.pop(context),
                                                                            icon: const Icon(
                                                                              CupertinoIcons.chevron_back,
                                                                              color: Colors.red,
                                                                            )),
                                                                        const SizedBox(
                                                                          width:
                                                                              15,
                                                                        ),
                                                                        const Text(
                                                                            "Read All Comment"),
                                                                        const Spacer(),
                                                                      ],
                                                                    ),
                                                                    const SizedBox(
                                                                      height:
                                                                          30,
                                                                    ),
                                                                    SingleChildScrollView(
                                                                      child:
                                                                          Column(
                                                                        children: [
                                                                          Text(
                                                                            "Based on ${reviewModelList.length} Reviews",
                                                                            style: const TextStyle(
                                                                                color: Color.fromRGBO(176, 176, 176, 1),
                                                                                fontSize: 15,
                                                                                fontWeight: FontWeight.w500,
                                                                                fontFamily: 'Roboto'),
                                                                          ),
                                                                          Divider(
                                                                            color:
                                                                                Colors.grey.shade300,
                                                                          ),
                                                                          ListView
                                                                              .builder(
                                                                            physics:
                                                                                const NeverScrollableScrollPhysics(),
                                                                            shrinkWrap:
                                                                                true,
                                                                            itemCount:
                                                                                reviewModelList.length,
                                                                            itemBuilder:
                                                                                (context, index) {
                                                                              return Container(
                                                                                margin: const EdgeInsets.only(top: 16),
                                                                                padding: const EdgeInsets.all(16),
                                                                                decoration: BoxDecoration(
                                                                                  color: Colors.white,
                                                                                  borderRadius: BorderRadius.circular(12.0),
                                                                                  boxShadow: [
                                                                                    BoxShadow(
                                                                                      color: Colors.grey.withOpacity(0.1),
                                                                                      spreadRadius: 1,
                                                                                      blurRadius: 6,
                                                                                      offset: const Offset(0, 2),
                                                                                    ),
                                                                                  ],
                                                                                ),
                                                                                child: Column(
                                                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                                                  children: [
                                                                                    // User info row
                                                                                    Row(
                                                                                      children: [
                                                                                        Container(
                                                                                          height: 50,
                                                                                          width: 50,
                                                                                          decoration: BoxDecoration(
                                                                                            shape: BoxShape.circle,
                                                                                            color: Colors.grey.shade200, // Fallback color
                                                                                          ),
                                                                                          child: ClipRRect(
                                                                                            borderRadius: BorderRadius.circular(100.0),
                                                                                            child: Image.network(
                                                                                              reviewModelList[index].userImage,
                                                                                              fit: BoxFit.cover,
                                                                                              errorBuilder: (context, error, stackTrace) => Center(
                                                                                                child: Icon(Icons.person, color: Colors.grey.shade500),
                                                                                              ),
                                                                                            ),
                                                                                          ),
                                                                                        ),
                                                                                        const SizedBox(width: 12),
                                                                                        Expanded(
                                                                                          child: Column(
                                                                                            crossAxisAlignment: CrossAxisAlignment.start,
                                                                                            children: [
                                                                                              Text(
                                                                                                "@${reviewModelList[index].userName}",
                                                                                                style: TextStyle(
                                                                                                  fontSize: 16,
                                                                                                  fontWeight: FontWeight.w600,
                                                                                                  color: Colors.grey.shade800,
                                                                                                ),
                                                                                                overflow: TextOverflow.ellipsis,
                                                                                              ),
                                                                                              const SizedBox(height: 4),
                                                                                              Text(
                                                                                                formatDateString("${reviewModelList[index].createdAt}"),
                                                                                                style: TextStyle(
                                                                                                  fontSize: 13,
                                                                                                  color: Colors.grey.shade600,
                                                                                                ),
                                                                                              ),
                                                                                            ],
                                                                                          ),
                                                                                        ),
                                                                                      ],
                                                                                    ),

                                                                                    const SizedBox(height: 12),

                                                                                    // Rating stars
                                                                                    Row(
                                                                                      children: [
                                                                                        Row(
                                                                                          children: List.generate(
                                                                                            5,
                                                                                            (starIndex) => Icon(
                                                                                              starIndex < reviewModelList[index].star ? Icons.star : Icons.star_border,
                                                                                              color: Colors.amber,
                                                                                              size: 20,
                                                                                            ),
                                                                                          ).expand((widget) => [widget, const SizedBox(width: 2)]).toList()
                                                                                            ..removeLast(),
                                                                                        ),
                                                                                        const SizedBox(width: 8),
                                                                                        Text(
                                                                                          "${reviewModelList[index].star}.0",
                                                                                          style: TextStyle(
                                                                                            fontSize: 15,
                                                                                            color: Colors.grey.shade700,
                                                                                          ),
                                                                                        ),
                                                                                      ],
                                                                                    ),

                                                                                    const SizedBox(height: 12),

                                                                                    // Review text
                                                                                    Text(
                                                                                      reviewModelList[index].comment,
                                                                                      style: TextStyle(
                                                                                        fontSize: 15,
                                                                                        color: Colors.grey.shade800,
                                                                                        height: 1.4,
                                                                                      ),
                                                                                    ),
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
                                                    text: averageRating
                                                        .toStringAsFixed(1),
                                                    style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.w700,
                                                        fontSize: 35,
                                                        fontFamily: 'Roboto',
                                                        color: Color.fromRGBO(
                                                            0, 0, 0, 1))),
                                                const TextSpan(
                                                  text: '/',
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.w700,
                                                      fontSize: 20,
                                                      color: Color.fromRGBO(
                                                          0, 0, 0, 1)),
                                                ),
                                                const TextSpan(
                                                    text: ' 5',
                                                    style: TextStyle(
                                                        color: Color.fromRGBO(
                                                            176, 176, 176, 1),
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
                                            color: Color.fromRGBO(
                                                176, 176, 176, 1),
                                            fontSize: 15,
                                            fontWeight: FontWeight.w500,
                                            fontFamily: 'Roboto'),
                                      ),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      ListView.builder(
                                        physics:
                                            const NeverScrollableScrollPhysics(),
                                        shrinkWrap: true,
                                        itemCount: reviewModelList.length > 2
                                            ? 2
                                            : reviewModelList.length,
                                        itemBuilder: (context, index) {
                                          return Container(
                                            margin:
                                                const EdgeInsets.only(top: 16),
                                            padding: const EdgeInsets.all(16),
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(12.0),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.grey
                                                      .withOpacity(0.1),
                                                  spreadRadius: 1,
                                                  blurRadius: 6,
                                                  offset: const Offset(0, 2),
                                                ),
                                              ],
                                            ),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                // User info row
                                                Row(
                                                  children: [
                                                    Container(
                                                      height: 50,
                                                      width: 50,
                                                      decoration: BoxDecoration(
                                                        shape: BoxShape.circle,
                                                        color: Colors.grey
                                                            .shade200, // Fallback color
                                                      ),
                                                      child: ClipRRect(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(
                                                                    100.0),
                                                        child: Image.network(
                                                          reviewModelList[index]
                                                              .userImage,
                                                          fit: BoxFit.cover,
                                                          errorBuilder: (context,
                                                                  error,
                                                                  stackTrace) =>
                                                              Center(
                                                            child: Icon(
                                                                Icons.person,
                                                                color: Colors
                                                                    .grey
                                                                    .shade500),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    const SizedBox(width: 12),
                                                    Expanded(
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Text(
                                                            "@${reviewModelList[index].userName}",
                                                            style: TextStyle(
                                                              fontSize: 16,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                              color: Colors.grey
                                                                  .shade800,
                                                            ),
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                          ),
                                                          const SizedBox(
                                                              height: 4),
                                                          Text(
                                                            formatDateString(
                                                                "${reviewModelList[index].createdAt}"),
                                                            style: TextStyle(
                                                              fontSize: 13,
                                                              color: Colors.grey
                                                                  .shade600,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),

                                                const SizedBox(height: 12),

                                                // Rating stars
                                                Row(
                                                  children: [
                                                    Row(
                                                      children: List.generate(
                                                        5,
                                                        (starIndex) => Icon(
                                                          starIndex <
                                                                  reviewModelList[
                                                                          index]
                                                                      .star
                                                              ? Icons.star
                                                              : Icons
                                                                  .star_border,
                                                          color: Colors.amber,
                                                          size: 20,
                                                        ),
                                                      )
                                                          .expand((widget) => [
                                                                widget,
                                                                const SizedBox(
                                                                    width: 2)
                                                              ])
                                                          .toList()
                                                        ..removeLast(),
                                                    ),
                                                    const SizedBox(width: 8),
                                                    Text(
                                                      "${reviewModelList[index].star}.0",
                                                      style: TextStyle(
                                                        fontSize: 15,
                                                        color: Colors
                                                            .grey.shade700,
                                                      ),
                                                    ),
                                                  ],
                                                ),

                                                const SizedBox(height: 12),

                                                // Review text
                                                Text(
                                                  reviewModelList[index]
                                                      .comment,
                                                  style: TextStyle(
                                                    fontSize: 15,
                                                    color: Colors.grey.shade800,
                                                    height: 1.4,
                                                  ),
                                                ),
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
                                                color: Colors.grey.shade400,
                                                width: 2),
                                            borderRadius:
                                                BorderRadius.circular(8.0)),
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
                              ],
                            ),
                          ),

                          Container(
                            padding: const EdgeInsets.all(10),
                            color: Colors.grey.shade200,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(
                                        10), // Add border radius
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Html(
                                          data: translateEn == "en"
                                              ? enDetails
                                              : hiDetails),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      Html(
                                          data: translateEn == "en"
                                              ? enMoreDetail
                                              : hiMoreDetail),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      Container(
                                        padding: const EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color: Colors.grey.shade400,
                                            width: 1.5,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                              8), // Add border radius
                                        ),
                                        child: Column(
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                const Expanded(
                                                  child: Text(
                                                    'Temple is know for',
                                                    style: TextStyle(
                                                      color: Colors.orange,
                                                      fontSize: 16,
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(
                                                  width: 10,
                                                ),
                                                Expanded(
                                                  child: Text(
                                                    translateEn == "en"
                                                        ? enTempleKnowMore
                                                        : hiTempleKnowMore,
                                                    style: const TextStyle(
                                                        color: Colors.black,
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Divider(
                                              color: Colors.grey.shade300,
                                            ),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                const Expanded(
                                                  child: Text(
                                                    'Timings',
                                                    style: TextStyle(
                                                      color: Colors.orange,
                                                      fontSize: 16,
                                                    ),
                                                  ),
                                                ),
                                                Expanded(
                                                  child: Text(
                                                    'Open: ${convertTimeToAmPm(timingOpen)} , Close : ${convertTimeToAmPm(timingClose)}',
                                                    style: const TextStyle(
                                                        color: Colors.black,
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Divider(
                                              color: Colors.grey.shade300,
                                            ),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                const Expanded(
                                                  child: Text(
                                                    'Entry Fee',
                                                    style: TextStyle(
                                                      color: Colors.orange,
                                                      fontSize: 16,
                                                    ),
                                                  ),
                                                ),
                                                Expanded(
                                                  child: Text(
                                                    entryFee,
                                                    style: const TextStyle(
                                                        color: Colors.black,
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Divider(
                                              color: Colors.grey.shade300,
                                            ),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                const Expanded(
                                                  child: Text(
                                                    'Tips And Restrictions',
                                                    style: TextStyle(
                                                      color: Colors.orange,
                                                      fontSize: 16,
                                                    ),
                                                  ),
                                                ),
                                                Expanded(
                                                  child: Text(
                                                    translateEn == "en"
                                                        ? enTipsRestiction
                                                        : hiTipsRestiction,
                                                    style: const TextStyle(
                                                        color: Colors.black,
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Divider(
                                              color: Colors.grey.shade300,
                                            ),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                const Expanded(
                                                  child: Text(
                                                    'Facilities',
                                                    style: TextStyle(
                                                      color: Colors.orange,
                                                      fontSize: 16,
                                                    ),
                                                  ),
                                                ),
                                                Expanded(
                                                  child: Text(
                                                    translateEn == "en"
                                                        ? enFacilities
                                                        : hiFacilities,
                                                    style: const TextStyle(
                                                        color: Colors.black,
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Divider(
                                              color: Colors.grey.shade300,
                                            ),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                const Expanded(
                                                  child: Text(
                                                    'Require time',
                                                    style: TextStyle(
                                                      color: Colors.orange,
                                                      fontSize: 16,
                                                    ),
                                                  ),
                                                ),
                                                Expanded(
                                                  child: Text(
                                                    requireTime,
                                                    style: const TextStyle(
                                                        color: Colors.black,
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),

                                      const SizedBox(
                                        height: 10,
                                      ),

                                      // Mahakaleshwar Temple Services
                                      Html(
                                          data: translateEn == "en"
                                              ? enTempleServices
                                              : hiTempleServices),

                                      //Aarti Mahakaleshwar Temple
                                      Html(
                                          data: translateEn == "en"
                                              ? enTempleAarti
                                              : hiTempleAarti),

                                      // Nearby Tourist Places
                                      Html(
                                          data: translateEn == "en"
                                              ? enTouristPlace
                                              : hiTouristPlace),

                                      // Restaurants and Local Food in Mahakaleshwar Temple
                                      Html(
                                          data: translateEn == "en"
                                              ? enTempleLocalFood
                                              : hiTempleLocalFood),
                                    ],
                                  ),
                                ),
                              ],
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
  }
}

class Product {
  Uri image;
  String name;
  String title;
  String distance;

  Product(
      {required this.image,
      required this.name,
      required this.title,
      required this.distance});
}
