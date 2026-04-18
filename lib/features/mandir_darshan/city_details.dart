import 'dart:ui';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:mahakal/utill/loading_datawidget.dart';
import 'package:provider/provider.dart';
import 'package:tdk_bouncingwidget/tdk_bouncingwidget.dart';
import '../../data/datasource/remote/http/httpClient.dart';
import '../../main.dart';
import '../../utill/app_constants.dart';
import '../../utill/full_screen_image_slider.dart';
import '../profile/controllers/profile_contrroller.dart';
import 'aboutujjain.dart';
import 'hotel_details.dart';
import 'mandirdetails_mandir.dart';
import 'model/RestaurantModel.dart';
import 'model/city_model.dart';
import 'model/citydetail_model.dart';
import 'model/hotelnear_model.dart';
import 'model/city_review_model.dart';
import 'model/templenearby_model.dart';
import 'restaurant_details.dart';

class CitydarshanView extends StatefulWidget {
  final String detailId;

  const CitydarshanView({super.key, required this.detailId});

  @override
  State<CitydarshanView> createState() => _citydarshanState();
}

class _citydarshanState extends State<CitydarshanView>
    with SingleTickerProviderStateMixin {
  final CarouselSliderController carouselController =
      CarouselSliderController();
  var currentIndex = 0;

  List<Product> products = [
    Product(
        image: Uri.parse(
            'https://s3-alpha-sig.figma.com/img/1fb5/6f97/acad14e27de9b9d7bafb40feb3c111c3?Expires=1721001600&Key-Pair-Id=APKAQ4GOSFWCVNEHN3O4&Signature=beD6nYGaa4gGJAdiE6Nn44P5wHgLtiy~cyq2BDScea2POEjggL67BZym0sto18dwfTf2oCVc19yBd4Xs-kMTQ6tu1mWZZDO092iE~gn1-r~qzAXjrJWjjtNMMrB2C476g7wBQuhNo4MMy7qRp3~rbwRUp7MG5Zp794h9xu5DmTpyc3r~7BSROawi1hfZrQ0ycOtbMq6mukkBE3BrfiXTj1ONGuNSq3adLCq7MIFl~7iZE0C8pO9fxaam09OBHmYK8oTb-8MdG9ovuI6~HBsrI27UPAgG6Awe-vTIKLxarER2H2G2739ppnl3l~RgR8lGFsna-x2hzjUQ7uAl0wyFdQ__'),
        name: 'Mahakal',
        title: '2',
        distance: '1'),
    Product(
        image: Uri.parse(
            'https://s3-alpha-sig.figma.com/img/584e/a553/2019ae90c566b579888992b126053c6d?Expires=1721001600&Key-Pair-Id=APKAQ4GOSFWCVNEHN3O4&Signature=FpWjMWk2Uf-3XHArjYvbl7qhV0GRhSd-uH1srROUN7PGzG03k7Yzq5nxPvApe05H4fq-Ptqu056e4NsjmOYmWilBDnTmiLfP7Ap2OTXCxuDONdNfDuz~SwhqcpMYKxbbu6qwTbrEN4xbZnu1kqs25unG0X-XMI549O2yxa3Rr~t29z9tHmJkaqGYTScv1Ia25XnnAl6RkBg9vq737vUQOitnnMO9rELdObqfGBJ8hdQjxeNIxvZuJuIb1SxO9kCTdMX~S5j3LZNW0F6dkwlANVvP2smY5OPwS30Cia5DdqkxtvETgcsQ0bsjjmxKHImvFRia-yYWY8dGZTkCCltDmQ__'),
        name: ' Sandipani Ashram',
        title: '',
        distance: '1'),
    Product(
        image: Uri.parse(
            'https://s3-alpha-sig.figma.com/img/e2c6/8f74/7d0ec76c687ee62d968d4105590719a6?Expires=1721001600&Key-Pair-Id=APKAQ4GOSFWCVNEHN3O4&Signature=DA7EsXAhsFeHr4iNWKwD3-7fNKYbq6WhbxAilp-RazH4Y2rC-rYofKvXmloja~psNCwlXFTnQLQWzf1Bo3hVD3pA3M1XHWELY1rOS8JBUyZIuMCJ9q0H5Ty~l6hblrsQvUxufkIv1vI91I9wmhhGp1yhbAzFu491DxkVWh4LdwXnttZMaiOUGTrdOq2jHTRZmieVGlYeKHXtPu5rlfMwP~3iQpmZ-Hcb43M6Xgk3FqQk61Sv-cby64KfgmDkbr5U0Bsr1GaVK-uqmMpd0HfbSm1Vnpd18bFmcccZ-TRiGViunYZ4D7WEmAAYgbQvlAvS1jm7ZL7pBrNrsO4vjNstSg__'),
        name: 'Ram Ghat',
        title: 'The Ghat of KH Simhast',
        distance: '1'),
    Product(
        image: Uri.parse(
            'https://s3-alpha-sig.figma.com/img/f890/16ac/8244568e4f9671d46ba420324274f2f1?Expires=1721001600&Key-Pair-Id=APKAQ4GOSFWCVNEHN3O4&Signature=oUcX2Z2ucOByXT5llXgwaMc2e86KR6VcuVXokWJ~2wyi5MUrayqtk9zifgxKxrPWjt1B0mk17Uj~W5P3uD2Eh0DkIUMjiBOcn9ayXDj7EnBF2T49Q3xb9gg~Gvmzgfwadl~Gzp5ZFQjZSETlhRYIVVJmjzU8eeZCJxi3JFU6116BoN2CFqxyJhTug1WoTo22lMZCnHwmqQcCCgW34N0qW8xkpq0jnWJ3OxF7UxhaZwf0QaIzeTX-8Udo4djoWbL2cybQKhJcHaMzp0kFrxoxZ8llQIZzWCZPRZ9jw6EluaQfy0cid17tvWo~fPCjG99OITRAlFP-xBzmBaN58YguTQ__'),
        name: 'Harsiddhi Temple ',
        title: 'Gurukul Of The Gods',
        distance: '1'),
    Product(
        image: Uri.parse(
            'https://www.templepurohit.com/wp-content/uploads/2016/01/chintamani-ganesh-temple.jpg'),
        name: 'Chintaman Ganesh  ',
        title: ' ',
        distance: '1'),
    Product(
        image: Uri.parse(
            'https://s3-alpha-sig.figma.com/img/4e48/c43e/845f0c5463f483f18ac8abe50cef52df?Expires=1721001600&Key-Pair-Id=APKAQ4GOSFWCVNEHN3O4&Signature=Xw39sCjIEXObrSlg7QIkTG-M7WlVd3litrapBKQHisiyL5YYpMABkifgfNFIs9RcjioAkiUebr7LwCJAWk020htDWpsMH8ALV0RSI481NYhf3pLfrbR9my0-N1rdgPphvvZ7gqToegNX8HD9ef0dNzkE3uE0qNtsUP6LYXUh1xv1a09ppUuwTNJLV0WqaEN4Fu7AEuZLNVtQAqe43HkfHZVfH5tvzyYlm6CUXarm8OUpXhsKohN6qa3mMEZ7skFooUcTaugtsxLuWrFjEjLdcLYSVPJpDgHwjINXK-TpCx0~62D1cmQSH2D02Q6QaHJOd9SlwCnDxsIp2f1G9hplBQ__'),
        name: 'ISKON ',
        title: '',
        distance: '1'),
  ];

  List<Hotel> hotelModelList = <Hotel>[];
  List<Data> templeModelList = <Data>[];
  List<Restaurant> restaurantModelList = <Restaurant>[];
  List<City> cityModelList = <City>[];
  List<Visits> visitModelList = <Visits>[];

  late TabController _tabController;
  final ScrollController scrollController = ScrollController();
  final double appBarHeight = 150.0;

  // Create GlobalKeys for each section
  final GlobalKey section1Key = GlobalKey();
  final GlobalKey section2Key = GlobalKey();
  final GlobalKey section3Key = GlobalKey();

  late double greenHeight;
  late double blueHeight;
  late double orangeHeight;

  final List<GlobalKey> _tabKeys = [
    GlobalKey(),
    GlobalKey(),
    GlobalKey(),
  ];

  bool gridList = false;
  String translateEn = 'hi';
  String userId = '';
  String userIMG = '';

  String enName = "";
  String enStateName = "";
  String enDescription = "";
  String enShortDescription = "";
  String enFestivalEvent = "";
  String enFamousFor = "";

  String hiName = "";
  String hiStateName = "";
  String hiDescription = "";
  String hiShortDescription = "";
  String hiFestivalEvent = "";
  String hiFamousFor = "";

  List<String> imageList = [];
  List<String> placesImageList = [];
  String latitude = "";
  String longitude = "";

  List<Data> darshanCategoryModelList = <Data>[];

  // review items
  List<Cityreview> reviewModelList = <Cityreview>[];
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

  void getCityReview(String id) async {
    var res = await HttpService()
        .postApi("/api/v1/cities/getcitycomment", {"cities_id": id});

    setState(() {
      reviewModelList.clear();
      List reviewList = res["data"];
      reviewModelList.addAll(reviewList.map((e) => Cityreview.fromJson(e)));

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

  void setCityReview(String id) async {
    var res = await HttpService().postApi("/api/v1/cities/citiesaddcomment", {
      "user_id": userId,
      "cities_id": id,
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
      getCityReview(widget.detailId);
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
                      setCityReview(widget.detailId);
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

  void getCategoryTab() async {
    var res = await HttpService().getApi(AppConstants.darshanCategoryUrl);
    print(res);
    setState(() {
      darshanCategoryModelList.clear();
      List categoryList = res["data"];
      darshanCategoryModelList
          .addAll(categoryList.map((e) => Data.fromJson(e)));
    });
  }

  void getCityDetails(String id) async {
    var res = await HttpService().postApi("/api/v1/cities/getcitiesbyid", {
      "citie_id": id,
    });
    print("My Id Is  $id");

    print("Api response $res");
    setState(() {
      enName = res["data"]["hi_city"];
      enStateName = res["data"]["states"]["name"];
      enDescription = res["data"]["hi_description"];
      enShortDescription = res["data"]["hi_short_desc"];
      enFestivalEvent = res["data"]["hi_festivals_and_events"];
      enFamousFor = res["data"]["hi_famous_for"];

      hiName = res["data"]["hi_city"];
      hiStateName = res["data"]["states"]["name"];
      hiDescription = res["data"]["hi_description"];
      hiShortDescription = res["data"]["hi_short_desc"];
      hiFestivalEvent = res["data"]["hi_festivals_and_events"];
      hiFamousFor = res["data"]["hi_famous_for"];

      visitModelList.clear();
      List<dynamic> visitList = res["data"]["visits"] ?? "";
      visitModelList.addAll(visitList.map((e) => Visits.fromJson(e)));
      placesImageList = List<String>.from(res["data"]["image_list"]);
      imageList = List<String>.from(res["data"]["slider_list"]);
      latitude = res["data"]["latitude"];
      longitude = res["data"]["longitude"];
    });
    getCategoryTab();
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

  bool isAppBarVisible = true;
  double previousOffset = 0.0;

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

  void addScrollControllerListener() {
    scrollController.addListener(() {
      // Update heights of keys if their contexts are available
      for (int i = 0; i < _tabKeys.length; i++) {
        if (_tabKeys[i].currentContext != null) {
          double height = _tabKeys[i].currentContext!.size!.height;
          switch (i) {
            case 0:
              greenHeight = height;
              break;
            case 1:
              blueHeight = height;
              break;
            case 2:
              orangeHeight = height;
              break;
          }
        }
      }

      // Calculate cumulative heights
      List<double> cumulativeHeights = [];
      double cumulativeHeight = 0;
      for (int i = 0; i < _tabKeys.length; i++) {
        if (_tabKeys[i].currentContext != null) {
          cumulativeHeight += _tabKeys[i].currentContext!.size!.height;
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

  @override
  void initState() {
    super.initState();
    userId = Provider.of<ProfileController>(Get.context!, listen: false).userID;
    userIMG =
        Provider.of<ProfileController>(Get.context!, listen: false).userIMAGE;
    getCityDetails(widget.detailId);
    getCityReview(widget.detailId);
    _tabController = TabController(length: 3, vsync: this);
    scrollController.addListener(() {
      handleAppBarVisibility();
    });
    addScrollControllerListener();
    print("city id ${widget.detailId} $userIMG");
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: const Text("City details"),
        centerTitle: true,
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
                    Container(
                      height: 400,
                      width: double.infinity,
                      color: Colors.black38,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(
                            height: 30,
                          ),
                          Text(
                            translateEn == 'en' ? enName : hiName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 35,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Text(
                              translateEn == 'en'
                                  ? enShortDescription
                                  : hiShortDescription,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          InkWell(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  CupertinoPageRoute(
                                      builder: (context) => AboutDetailsView(
                                            name: translateEn == 'en'
                                                ? enName
                                                : hiName,
                                            details: translateEn == 'en'
                                                ? enShortDescription
                                                : hiShortDescription,
                                            templeModelList: templeModelList,
                                            femousDetails: translateEn == 'en'
                                                ? enFamousFor
                                                : hiFamousFor,
                                            templeLocation: LatLng(
                                                double.parse(latitude),
                                                double.parse(longitude)),
                                          )));
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 5.0),
                              decoration: BoxDecoration(
                                  border:
                                      Border.all(color: Colors.white, width: 2),
                                  borderRadius: BorderRadius.circular(4.0)),
                              child: Text(
                                "About ${translateEn == 'en' ? enName : hiName}",
                                style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white),
                              ),
                            ),
                          ),
                        ],
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
                                  images: placesImageList,
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
                Container(
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        key: _tabKeys[0],
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              margin: const EdgeInsets.all(10),
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8.0),
                                  color: Colors.orange.shade50),
                              child: Row(
                                children: [
                                  Text(
                                    enStateName,
                                    style: TextStyle(
                                        color: Colors.deepOrangeAccent,
                                        fontSize: screenWidth * 0.05,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  const Spacer(),
                                  BouncingWidgetInOut(
                                    onPressed: () {
                                      setState(() {
                                        gridList = !gridList;
                                        translateEn = gridList ? 'en' : 'hi';
                                      });
                                      getCityDetails(widget.detailId);
                                      getCategoryTab();
                                      getHoteldata();
                                      getRestaurantData();
                                      getCityData();
                                      getTempleData();
                                    },
                                    bouncingType: BouncingType.bounceInAndOut,
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
                                              color: Colors.orange, width: 2)),
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
                                ],
                              ),
                            ),
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  children: List.generate(
                                    templeModelList.length,
                                    (index) => GestureDetector(
                                      onTap: () {
                                        // Navigator.push(
                                        //   context,
                                        //   CupertinoPageRoute(
                                        //     builder: (context) => const mandir(),
                                        //   ),
                                        // );
                                      },
                                      child: Stack(
                                        children: [
                                          Container(
                                            margin: const EdgeInsets.all(4.0),
                                            height: 200,
                                            width: 140,
                                            child: ClipRRect(
                                              borderRadius:
                                                  const BorderRadius.only(
                                                topLeft: Radius.circular(10.0),
                                                topRight: Radius.circular(10.0),
                                                bottomRight:
                                                    Radius.circular(10.0),
                                                bottomLeft:
                                                    Radius.circular(10.0),
                                              ),
                                              child: Image.network(
                                                templeModelList[index]
                                                    .image
                                                    .toString(),
                                                fit: BoxFit.fill,
                                              ),
                                            ),
                                          ),
                                          Container(
                                            padding: const EdgeInsets.all(10),
                                            margin: const EdgeInsets.all(4.0),
                                            decoration: BoxDecoration(
                                                color: Colors.black
                                                    .withOpacity(0.3),
                                                borderRadius:
                                                    BorderRadius.circular(10)),
                                            height: 200,
                                            width: 140,
                                            child: Center(
                                              child: Text(
                                                "${translateEn == "en" ? templeModelList[index].enName : templeModelList[index].hiName}",
                                                textAlign: TextAlign.center,
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.bold,
                                                ),
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
                            Container(
                              margin: const EdgeInsets.all(10.0),
                              padding: const EdgeInsets.all(10.0),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                border:
                                    Border.all(color: Colors.grey, width: 1.5),
                                borderRadius: BorderRadius.circular(
                                    8), // Add border radius
                              ),
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.location_on_outlined,
                                        color: Colors.orange,
                                        size: 25,
                                      ),
                                      Text(
                                        enName,
                                        style: const TextStyle(
                                            color: Colors.black,
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold),
                                      )
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 6,
                                  ),
                                  Text(
                                    translateEn == 'en'
                                        ? enFamousFor
                                        : hiFamousFor,
                                    style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),

                            //best time to vists
                            const SizedBox(height: 10),
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 10),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(
                                    Icons.sunny,
                                    color: Colors.orange,
                                  ),
                                  SizedBox(width: 6.0),
                                  Text(
                                    'Best Time to Visit',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                  children: List.generate(
                                      growable: true,
                                      visitModelList.length,
                                      (index) => Stack(
                                            children: [
                                              Container(
                                                margin: const EdgeInsets.all(5),
                                                width: 260,
                                                decoration: BoxDecoration(
                                                  gradient: LinearGradient(
                                                    colors: [
                                                      Colors.red.shade300,
                                                      Colors.blue.shade400,
                                                    ],
                                                    begin: Alignment.topLeft,
                                                    end: Alignment.bottomRight,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(15),
                                                  image: DecorationImage(
                                                    image: NetworkImage(
                                                        '${visitModelList[index].image}'),
                                                    fit: BoxFit.cover,
                                                  ),
                                                ),
                                                child: ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                  child: BackdropFilter(
                                                    filter: ImageFilter.blur(
                                                        sigmaX: 6.0,
                                                        sigmaY: 6.0),
                                                    // Adjust the blur intensity as needed
                                                    child: Container(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              10),
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Row(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .center,
                                                            children: [
                                                              const Icon(
                                                                Icons
                                                                    .calendar_month,
                                                                color: Colors
                                                                    .white,
                                                                size: 18,
                                                              ),
                                                              const SizedBox(
                                                                width: 6.0,
                                                              ),
                                                              Text(
                                                                "${translateEn == 'en' ? visitModelList[index].enMonthName : visitModelList[index].hiMonthName}",
                                                                style:
                                                                    const TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  fontSize: 20,
                                                                  color: Colors
                                                                      .white,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                          const SizedBox(
                                                            height: 8,
                                                          ),
                                                          Container(
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(4.0),
                                                            decoration:
                                                                BoxDecoration(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          5.0),
                                                              color: Colors
                                                                  .black
                                                                  .withOpacity(
                                                                      0.6),
                                                            ),
                                                            child: Text(
                                                              '${translateEn == 'en' ? visitModelList[index].enSeason : visitModelList[index].hiSeason}',
                                                              style: const TextStyle(
                                                                  fontSize: 18,
                                                                  color: Colors
                                                                      .orange,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  overflow:
                                                                      TextOverflow
                                                                          .ellipsis),
                                                              maxLines: 2,
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                            height: 10,
                                                          ),
                                                          Row(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              const Icon(
                                                                Icons
                                                                    .person_outline_outlined,
                                                                color: Colors
                                                                    .white,
                                                                size: 20,
                                                              ),
                                                              const SizedBox(
                                                                width: 5.0,
                                                              ),
                                                              Expanded(
                                                                child: Text(
                                                                  '${translateEn == 'en' ? visitModelList[index].enCrowd : visitModelList[index].hiCrowd}',
                                                                  style: const TextStyle(
                                                                      color: Colors
                                                                          .white,
                                                                      fontSize:
                                                                          16,
                                                                      overflow:
                                                                          TextOverflow
                                                                              .ellipsis),
                                                                  maxLines: 1,
                                                                ),
                                                              )
                                                            ],
                                                          ),
                                                          const SizedBox(
                                                            height: 6.0,
                                                          ),
                                                          Row(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              const Icon(
                                                                Icons.sunny,
                                                                color: Colors
                                                                    .white,
                                                                size: 20,
                                                              ),
                                                              const SizedBox(
                                                                width: 5.0,
                                                              ),
                                                              Expanded(
                                                                child: Text(
                                                                  '${translateEn == 'en' ? visitModelList[index].enWeather : visitModelList[index].hiWeather}',
                                                                  style: const TextStyle(
                                                                      color: Colors
                                                                          .white,
                                                                      fontSize:
                                                                          16,
                                                                      overflow:
                                                                          TextOverflow
                                                                              .ellipsis),
                                                                  maxLines: 1,
                                                                ),
                                                              )
                                                            ],
                                                          ),
                                                          const SizedBox(
                                                            height: 6.0,
                                                          ),
                                                          Row(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              const Icon(
                                                                Icons
                                                                    .thumb_up_off_alt_outlined,
                                                                color: Colors
                                                                    .white,
                                                                size: 20,
                                                              ),
                                                              const SizedBox(
                                                                width: 5.0,
                                                              ),
                                                              Expanded(
                                                                child: Text(
                                                                  '${translateEn == 'en' ? visitModelList[index].enSight : visitModelList[index].hiSight}',
                                                                  style: const TextStyle(
                                                                      color: Colors
                                                                          .white,
                                                                      fontSize:
                                                                          16,
                                                                      overflow:
                                                                          TextOverflow
                                                                              .ellipsis),
                                                                  maxLines: 1,
                                                                ),
                                                              )
                                                            ],
                                                          ),
                                                        ],
                                                      ), // Adjust the opacity as needed
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ))),
                            ),

                            // festivals and events
                            const SizedBox(
                              height: 10,
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 10),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(
                                    Icons.festival,
                                    color: Colors.orange,
                                  ),
                                  SizedBox(width: 6.0),
                                  Text(
                                    "Festival's & Event's",
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              decoration: const BoxDecoration(
                                image: DecorationImage(
                                  image: NetworkImage(
                                      'https://t4.ftcdn.net/jpg/05/60/58/67/360_F_560586710_VmIHNuH6TcdLHIn3cEuIDDAcCYBhkIL0.jpg'),
                                  // Replace with your image asset
                                  fit: BoxFit.cover,
                                ),
                              ),
                              child: ClipRRect(
                                child: BackdropFilter(
                                  filter: ImageFilter.blur(
                                      sigmaX: 4.0,
                                      sigmaY:
                                          6.0), // Adjust the blur intensity as needed
                                  child: Container(
                                    margin: const EdgeInsets.all(6),
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: Colors.white,
                                        width: 2,
                                      ),
                                      color: Colors.white.withOpacity(0.9),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Html(data: enFestivalEvent),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(
                        height: 10,
                      ),
                      Container(
                        key: _tabKeys[1],
                        child: Column(
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
                                            padding: const EdgeInsets.all(8),
                                            margin: const EdgeInsets.all(10),
                                            decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius:
                                                    BorderRadius.circular(8.0)),
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
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                Spacer(),
                                                Text(
                                                  'See All',
                                                  style: TextStyle(
                                                    color: Colors.orange,
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          SingleChildScrollView(
                                            scrollDirection: Axis.horizontal,
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
                                                              builder: (context) =>
                                                                  MandirDetailView(
                                                                    detailId:
                                                                        "${templeModelList[index].id}",
                                                                  )));
                                                      // Navigator.push(context, CupertinoPageRoute(builder: (context) => TestScreen()));
                                                    },
                                                    child: Container(
                                                      height: 180,
                                                      width: 150,
                                                      margin: const EdgeInsets
                                                          .symmetric(
                                                          horizontal: 5.0),
                                                      decoration: BoxDecoration(
                                                          color: Colors.white,
                                                          border: Border.all(
                                                              color: Colors.grey
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
                                                            child:
                                                                Image.network(
                                                              "${templeModelList[index].image}",
                                                              height: 100,
                                                              width: double
                                                                  .infinity,
                                                              fit: BoxFit.cover,
                                                            ),
                                                          ),
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .only(
                                                                    top: 10,
                                                                    left: 5.0),
                                                            child: Text(
                                                              "${translateEn == "en" ? templeModelList[index].enName : templeModelList[index].hiName}",
                                                              style: const TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  fontSize: 16),
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
                                            padding: const EdgeInsets.all(8),
                                            margin: const EdgeInsets.all(10),
                                            decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius:
                                                    BorderRadius.circular(8.0)),
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
                                                    fontWeight: FontWeight.bold,
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
                                            scrollDirection: Axis.horizontal,
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
                                                            builder: (context) =>
                                                                HotelDetailView(
                                                                  detailId:
                                                                      "${hotelModelList[index].id}",
                                                                )),
                                                      );
                                                    },
                                                    child: Container(
                                                      height: 120,
                                                      width: 260,
                                                      margin: const EdgeInsets
                                                          .symmetric(
                                                          horizontal: 5.0),
                                                      decoration: BoxDecoration(
                                                          border: Border.all(
                                                              color: Colors.grey
                                                                  .shade300),
                                                          color: Colors.white,
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
                                                                      .all(5.0),
                                                              child: Column(
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                children: [
                                                                  Text(
                                                                    translateEn ==
                                                                            "en"
                                                                        ? hotelModelList[index]
                                                                            .enHotelName
                                                                        : hotelModelList[index]
                                                                            .hiHotelName,
                                                                    style:
                                                                        const TextStyle(
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                      color: Colors
                                                                          .black,
                                                                      fontSize:
                                                                          16,
                                                                      overflow:
                                                                          TextOverflow
                                                                              .ellipsis,
                                                                    ),
                                                                    maxLines: 4,
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
                                                            child: ClipRRect(
                                                              borderRadius: const BorderRadius
                                                                  .only(
                                                                  bottomRight: Radius
                                                                      .circular(
                                                                          10),
                                                                  topRight: Radius
                                                                      .circular(
                                                                          10)),
                                                              child:
                                                                  Image.network(
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
                                            padding: const EdgeInsets.all(8),
                                            margin: const EdgeInsets.all(10),
                                            decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius:
                                                    BorderRadius.circular(8.0)),
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
                                                    fontWeight: FontWeight.bold,
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
                                            scrollDirection: Axis.horizontal,
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Row(
                                                children: List.generate(
                                                  restaurantModelList.length,
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
                                                      margin: const EdgeInsets
                                                          .symmetric(
                                                          horizontal: 5.0),
                                                      decoration: BoxDecoration(
                                                          color: Colors.white,
                                                          border: Border.all(
                                                              color: Colors.grey
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
                                                                      .all(5.0),
                                                              child: Column(
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                children: [
                                                                  Text(
                                                                    translateEn ==
                                                                            "en"
                                                                        ? restaurantModelList[index]
                                                                            .enRestaurantName
                                                                        : restaurantModelList[index]
                                                                            .hiRestaurantName,
                                                                    style: const TextStyle(
                                                                        fontWeight:
                                                                            FontWeight
                                                                                .bold,
                                                                        fontSize:
                                                                            16,
                                                                        overflow:
                                                                            TextOverflow.ellipsis),
                                                                    maxLines: 4,
                                                                  ),
                                                                  const SizedBox(
                                                                    height: 10,
                                                                  ),
                                                                  // Text(restaurantModelList[index].title,style: TextStyle(fontSize: 12),),
                                                                ],
                                                              ),
                                                            ),
                                                          ),
                                                          Expanded(
                                                            child: ClipRRect(
                                                              borderRadius: const BorderRadius
                                                                  .only(
                                                                  bottomRight: Radius
                                                                      .circular(
                                                                          10),
                                                                  topRight: Radius
                                                                      .circular(
                                                                          10)),
                                                              child:
                                                                  Image.network(
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
                                              padding: const EdgeInsets.all(8),
                                              margin: const EdgeInsets.all(10),
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
                                              scrollDirection: Axis.horizontal,
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Row(
                                                  children: List.generate(
                                                    cityModelList.length,
                                                    (index) => InkWell(
                                                      onTap: () {
                                                        Navigator.push(
                                                          context,
                                                          CupertinoPageRoute(
                                                            builder: (context) =>
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
                                                        margin: const EdgeInsets
                                                            .symmetric(
                                                            horizontal: 5.0),
                                                        decoration: BoxDecoration(
                                                            color: Colors.white,
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
                                                                          ? cityModelList[index]
                                                                              .enCity
                                                                          : cityModelList[index]
                                                                              .hiCity,
                                                                      style: const TextStyle(
                                                                          fontWeight: FontWeight
                                                                              .bold,
                                                                          fontSize:
                                                                              18),
                                                                    ),
                                                                    const SizedBox(
                                                                      height:
                                                                          10,
                                                                    ),
                                                                    Text(
                                                                      translateEn ==
                                                                              "en"
                                                                          ? cityModelList[index]
                                                                              .enShortDesc
                                                                          : cityModelList[index]
                                                                              .hiShortDesc,
                                                                      style: const TextStyle(
                                                                          fontSize:
                                                                              12,
                                                                          overflow:
                                                                              TextOverflow.ellipsis),
                                                                      maxLines:
                                                                          3,
                                                                    ),
                                                                    // Text(travels[index].distance,style: TextStyle(fontSize: 12),),
                                                                  ],
                                                                ),
                                                              ),
                                                            ),
                                                            Expanded(
                                                              child: ClipRRect(
                                                                borderRadius: const BorderRadius
                                                                    .only(
                                                                    bottomRight:
                                                                        Radius.circular(
                                                                            10),
                                                                    topRight: Radius
                                                                        .circular(
                                                                            10)),
                                                                child: Image
                                                                    .network(
                                                                  cityModelList[
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
                                                  padding:
                                                      MediaQuery.of(context)
                                                          .viewInsets,
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            16.0),
                                                    child:
                                                        SingleChildScrollView(
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
                                                                  icon:
                                                                      const Icon(
                                                                    CupertinoIcons
                                                                        .chevron_back,
                                                                    color: Colors
                                                                        .red,
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
                                                                      color: Color.fromRGBO(
                                                                          176,
                                                                          176,
                                                                          176,
                                                                          1),
                                                                      fontSize:
                                                                          15,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w500,
                                                                      fontFamily:
                                                                          'Roboto'),
                                                                ),
                                                                Divider(
                                                                  color: Colors
                                                                      .grey
                                                                      .shade300,
                                                                ),
                                                                ListView
                                                                    .builder(
                                                                  physics:
                                                                      const NeverScrollableScrollPhysics(),
                                                                  shrinkWrap:
                                                                      true,
                                                                  itemCount:
                                                                      reviewModelList
                                                                          .length,
                                                                  itemBuilder:
                                                                      (context,
                                                                          index) {
                                                                    return Container(
                                                                      margin: const EdgeInsets
                                                                          .only(
                                                                          top:
                                                                              10),
                                                                      padding: const EdgeInsets
                                                                          .all(
                                                                          10),
                                                                      decoration:
                                                                          BoxDecoration(
                                                                        color: Colors
                                                                            .grey
                                                                            .shade400,
                                                                        borderRadius:
                                                                            BorderRadius.circular(8.0),
                                                                      ),
                                                                      child:
                                                                          Column(
                                                                        crossAxisAlignment:
                                                                            CrossAxisAlignment.start,
                                                                        mainAxisAlignment:
                                                                            MainAxisAlignment.start,
                                                                        children: [
                                                                          Row(
                                                                            children: [
                                                                              SizedBox(
                                                                                height: 50,
                                                                                width: 50,
                                                                                child: ClipRRect(
                                                                                    borderRadius: BorderRadius.circular(100.0),
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
                                                                                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                                                                              ),
                                                                            ],
                                                                          ),
                                                                          const SizedBox(
                                                                            height:
                                                                                8,
                                                                          ),
                                                                          Row(
                                                                            children: [
                                                                              Row(
                                                                                mainAxisSize: MainAxisSize.min,
                                                                                children: List.generate(
                                                                                  5,
                                                                                  // Total number of stars
                                                                                  (starIndex) => Icon(
                                                                                    Icons.star,
                                                                                    color: starIndex < reviewModelList[index].star ? Colors.amber : Colors.white,
                                                                                    size: 18, // Yellow for filled stars, grey for unfilled
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                              const SizedBox(
                                                                                width: 5,
                                                                              ),
                                                                              Text(
                                                                                formatDateString("${reviewModelList[index].createdAt}"),
                                                                                style: const TextStyle(fontSize: 16, color: Colors.blueGrey),
                                                                              )
                                                                            ],
                                                                          ),
                                                                          // SizedBox(height: 10,),
                                                                          const Divider(
                                                                            color:
                                                                                Colors.grey,
                                                                          ),
                                                                          Text(
                                                                            reviewModelList[index].comment,
                                                                            style:
                                                                                const TextStyle(fontSize: 18, color: Colors.black),
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
                                          text:
                                              averageRating.toStringAsFixed(1),
                                          style: const TextStyle(
                                              fontWeight: FontWeight.w700,
                                              fontSize: 35,
                                              fontFamily: 'Roboto',
                                              color:
                                                  Color.fromRGBO(0, 0, 0, 1))),
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          SizedBox(
                                            height: 50,
                                            width: 50,
                                            child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        100.0),
                                                child: Image.network(
                                                  reviewModelList[index]
                                                      .userImage,
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
                                                        reviewModelList[index]
                                                            .star
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
                                                fontSize: 15,
                                                color: Colors.blueGrey),
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

                      //details
                      Container(
                        key: _tabKeys[2],
                        padding: const EdgeInsets.all(10),
                        color: Colors.white,
                        child: Html(data: enDescription),
                      ),
                    ],
                  ),
                ),

                // isAppBarVisible
                //     ? Hidable(
                //   preferredWidgetSize: Size.fromHeight(appBarHeight),
                //     controller: scrollController,
                //     enableOpacityAnimation: false,
                //   child: Container(
                //     color: Colors.white,
                //     child: Column(
                //       children: [
                //         SizedBox(height: 40,),
                //         Padding(
                //           padding: const EdgeInsets.symmetric(horizontal: 20.0),
                //           child: Row(
                //               children: [
                //                 Icon(Icons.arrow_back),
                //                 Spacer(),
                //                 Text("$isAppBarVisible"),
                //                 Icon(Icons.favorite),
                //
                //               ],
                //           ),
                //         ),
                //
                //       ],
                //     ),
                //   ),
                // )
                // : SizedBox(),
              ]),
            ),
    );
  }
}

class Product {
  Uri image;
  String name;
  String title;
  String distance;

  Product({
    required this.image,
    required this.name,
    required this.title,
    required this.distance,
  });
}
