import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:avatar_stack/avatar_stack.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_html/flutter_html.dart';
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
import 'chadhavabilling_screen.dart';
import 'tabbarview_screens/listreview.dart';
import 'package:http/http.dart' as http;

class ChadhavaDetailView extends StatefulWidget {
  final String idNumber;
  ChadhavaDetailView({super.key, required this.idNumber});

  @override
  _ChadhavaDetailViewState createState() => _ChadhavaDetailViewState();
}

class _ChadhavaDetailViewState extends State<ChadhavaDetailView>
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
  List<String> allProductIds = [];

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
    userId = Provider.of<ProfileController>(Get.context!, listen: false).userID;
    userName =
        Provider.of<ProfileController>(Get.context!, listen: false).userNAME;
    userPhone =
        Provider.of<ProfileController>(Get.context!, listen: false).userPHONE;
    print('My Chadhava Slug id${widget.idNumber}');
    print('>>> user id : $userId');
    print('>>> user name : $userName');
    print('>>> user phone : $userPhone');
    super.initState();
    getDetailsData();
    scrollController.addListener(() {
      handleAppBarVisibility();
      addScrollControllerListener();
    });
    _tabController = TabController(length: 7, vsync: this);
    for (var i = 0; i < product.length; i++) {
      allProductIds.add(product[i].productId);
    }
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

  String enName = '';
  String enAboutDetails = '';
  String enBenefitsDetails = '';
  String enProcessDetails = '';
  String enTempleDetails = '';
  String enVenue = '';

  String hiName = '';
  String hiAboutDetails = '';
  String hiBenefitsDetails = '';
  String hiProcessDetails = '';
  String hiTempleDetails = '';
  String hiVenue = '';
  String poojaSlug = '';

  String userId = '';
  String userName = '';
  String userPhone = '';

  int leadId = 0;
  int leadPackageId = 0;
  int leadServiceId = 0;
  String leadBookingDate = '';
  String bookingDate = '';

  List<PackagesModel> package = <PackagesModel>[];
  List<ProductsModel> product = <ProductsModel>[];
  int serviceId = 0;
  int count = 0;
  String productType = '';
  String venue = '';
  String thumbnail = '';
  String targetDays = '';

  bool gridList = false;
  String translateEn = 'hi';

  Future<void> getDetailsData() async {
    try {
      final url = Uri.parse(AppConstants.baseUrl +
          AppConstants.chadhavaDetailUrl +
          widget.idNumber);
      final response = await http.get(url);

      if (response.statusCode == 200) {
        var res = json.decode(response.body);

        setState(() {
          // poojaCategorydata = pooojaCategoryModelFromJson(response.body);

          // English details
          enName = res['data']['en_name'] ?? '';
          enAboutDetails = res['data']['en_details'] ?? '';
          enVenue = res['data']['en_chadhava_venue'] ?? '';

          // Hindi details
          hiName = res['data']['hi_name'] ?? '';
          hiAboutDetails = res['data']['hi_details'] ?? '';
          hiVenue = res['data']['hi_chadhava_venue'] ?? '';

          // Other details
          serviceId = res['data']['id'] ?? 0;
          count = res['data']['count'] ?? 0;
          productType = res['data']['product_type'] ?? '';
          venue = res['data']['venues'] ?? '';
          targetDays = res['data']['week_days'] ?? '';
          thumbnail = res['data']['thumbnail'] ?? '';
          poojaSlug = res['data']['slug'] ?? '';
          bookingDate = res['data']['next_chadhava_date'] ?? '';
          // Products
          List productList = res['data']['products'] ?? [];
          product = productsModelFromJson(jsonEncode(productList));
        });
      } else {
        // Handle non-200 responses
        throw Exception(
            'Failed to load pooja data. Status Code: ${response.statusCode}');
      }
    } catch (e) {
      // Log and handle any other errors (e.g., network errors, JSON parsing errors)
      log('Error fetching pooja details: $e');
      throw Exception('Failed to load pooja data: $e');
    }
  }

  String formatDuration(Duration duration) {
    return '${duration.inHours}:${duration.inMinutes.remainder(60)}:${duration.inSeconds.remainder(60)}';
  }

  List<String> imagePaths = [
    'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSUToy14Ex7F4of_WK0Zr_5Fks_IKhzrICCHQ&s',
    'https://i.pinimg.com/736x/56/de/95/56de95bb1f6ede91b69acdd3ae5072c5.jpg',
    'https://1.bp.blogspot.com/-D93XGu464NM0uYOd_AgB2pPjKOnaQN0hnlGxgVu17DEG1jplL7WqBaeqVML8v3FP0MEJwDSDEJGn5-CSyA',
    'https://pbs.twimg.com/media/FBWq0BIVIAIVpr3.jpg',
    'https://i.pinimg.com/originals/43/a5/b0/43a5b0ea0253b4af61e3d21608b26884.jpg',
    'https://static.wixstatic.com/media/436168_5bcfe5cd6cc24a1cb5dcbd5ae658910a~mv2.jpg/v1/fill/w_560,h_372,al_c,q_80,usm_0.66_1.00_0.01,enc_auto/ujjain-mahakaleshwar-temple.jpg'
  ];

  late Timer timer;

  void _scrollToTarget() {
    // Switch to the tab
    _tabController.animateTo(4); // Switch to the 5th tab (0-based index)

    // Scroll to the target widget after a short delay to ensure tab switch completes
    Timer(const Duration(milliseconds: 500), () {
      final context = fourKey.currentContext;
      if (context != null) {
        Scrollable.ensureVisible(
          context,
          duration: const Duration(milliseconds: 500),
        );
      }
    });
  }

  Future<void> getChadhavaLeadSave(
    int serviceId,
    String type,
    List<String> productIdList,
  ) async {
    // Define the API endpoint
    print('Booking start');
    const String apiUrl =
        '${AppConstants.baseUrl}${AppConstants.chadhavaLeadUrl}';

    // Create the data payload
    Map<String, dynamic> data = {
      'service_id': serviceId,
      'type': type,
      'product_id': productIdList,
      'person_phone': userPhone,
      'person_name': userName,
      'booking_date': bookingDate
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
        print('Booking successful');
        // Optionally, parse the response
        var responseData = jsonDecode(response.body);
        leadId = responseData['lead']['id'];
        leadServiceId = responseData['lead']['service_id'];
        leadBookingDate = responseData['lead']['booking_date'];
        String poojaName = translateEn == 'en' ? enName : hiName;
        Navigator.push(
          context,
          CupertinoPageRoute(
              builder: (context) => ChadhavaBilldetails(
                    billAmount: '0',
                    product: product,
                    personCount: 1,
                    typePooja: 'chadhava',
                    orderId: serviceId,
                    packageName: 'Chadhava',
                    poojaName: poojaName,
                    poojaVenue: enVenue,
                    date: bookingDate,
                    leadId: leadId,
                    packageId: 0,
                    serviceId: leadServiceId,
                  )),
        );

        print(responseData);
      } else {
        // Handle error
        print('Failed to book pooja: ${response.statusCode}');
        print(response.body);
      }
    } catch (e) {
      // Handle exception
      print('An error occurred: $e');
    }
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
    // String dayOfWeek = DateFormat('EEEE').format(bookingDate);
    // String firstTargetDay = targetDays.split(', ').first;
    // DateTime previousDate = targetDate.subtract(const Duration(days: 1));
    var screenHeight = MediaQuery.of(context).size.height;
    var screenWidth = MediaQuery.of(context).size.width;

    return RefreshIndicator(
      onRefresh: () async {
        getDetailsData();
      },
      child: enAboutDetails.isEmpty
          ? MahakalLoadingData(onReload: () {})
          : Scaffold(
              floatingActionButtonLocation:
                  FloatingActionButtonLocation.centerDocked,
              floatingActionButton: GestureDetector(
                onTap: () {
                  // Navigator.push(
                  //   context,
                  //   CupertinoPageRoute(
                  //       builder: (context) => Newbilldetails(
                  //         billAmount: "0",
                  //         product: product,
                  //         personCount: 1,
                  //         typePooja: 'chadhava',
                  //         orderId: serviceId,
                  //         packageName: 'Chadhava',
                  //         poojaName: 'pooja',
                  //         poojaVenue: enVenue,
                  //         date: bookingDate,
                  //         leadId: leadId,
                  //         packageId: leadPackageId,
                  //         serviceId: leadServiceId,
                  //       )),
                  // );
                  getChadhavaLeadSave(
                    serviceId,
                    productType,
                    allProductIds,
                  );
                },
                child: Container(
                  margin: const EdgeInsets.all(10),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    gradient: const LinearGradient(
                      colors: [Colors.deepOrange, Colors.amber],
                      begin: Alignment.bottomLeft,
                      end: Alignment.topRight,
                    ),
                  ),
                  child: const Row(
                    children: [
                      Text(
                        'Chadhava',
                        style: TextStyle(
                            fontFamily: 'Roboto',
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                            color: Colors.white),
                      ),
                      Spacer(),
                      Icon(
                        Icons.arrow_circle_right_outlined,
                        size: 30,
                        color: Colors.white,
                      ),
                    ],
                  ),
                ),
              ),
              appBar: AppBar(
                title: Text('Chadhava Details'),
              ),
              body: SingleChildScrollView(
                controller: scrollController,
                child: Column(
                  children: [
                    SizedBox(
                      height: 280,
                      width: double.infinity,
                      child: Image.network(
                        thumbnail,
                        fit: BoxFit.fill,
                      ),
                    ),
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
                                  translateEn == 'en' ? enName : hiName,
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
                                      translateEn = gridList ? 'en' : 'hi';
                                    });
                                    getDetailsData();
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
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 5,
                          ),
                          Row(
                            children: [
                              const Icon(
                                Icons.calendar_month,
                                size: 20,
                                color: Colors.orange,
                              ),
                              const SizedBox(
                                width: 8,
                              ),
                              Text(
                                "${DateFormat('dd-MMMM-yyyy').format(DateFormat('yyyy-MM-dd').parse(bookingDate))}",
                                style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w400,
                                    fontFamily: 'Roboto',
                                    color: Colors.black),
                              )
                            ],
                          ),
                          const SizedBox(
                            height: 5,
                          ),
                          Row(
                            children: [
                              const Expanded(
                                  flex: 0,
                                  child: Icon(
                                    Icons.location_pin,
                                    size: 20,
                                    color: Colors.orange,
                                  )),
                              const SizedBox(
                                width: 8,
                              ),
                              Expanded(
                                child: Text(
                                  translateEn == 'en' ? enVenue : hiVenue,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w400,
                                    fontFamily: 'Roboto',
                                    color: Colors.black,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 10,
                          ),
DevoteesCountWidget(),
                          const SizedBox(
                            height: 6,
                          ),
                          translateEn == 'en'
                              ? Text.rich(
                                  TextSpan(
                                    text: 'Till now',
                                    style: const TextStyle(
                                        fontSize: 16, color: Colors.black),
                                    children: <TextSpan>[
                                      TextSpan(
                                        text: ' ${count + 10000}+Devotees',
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.orange,
                                            fontSize: 16),
                                      ),
                                      const TextSpan(
                                        text:
                                            ' Have experienced the divine blessings by participating in',
                                        style: TextStyle(
                                            fontSize: 16, color: Colors.black),
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
                                        fontSize: 16, color: Colors.black),
                                    children: <TextSpan>[
                                      TextSpan(
                                        text: ' ${count + 10000}+Devotees',
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.orange,
                                            fontSize: 16),
                                      ),
                                      const TextSpan(
                                        text:
                                            ' ने महाकाल.कॉम की पूजा सेवा के माध्यम से आयोजित पूजा में सहभागी बन चुके हैं।',
                                        style: TextStyle(
                                            fontSize: 16, color: Colors.black),
                                      ),
                                    ],
                                  ),
                                  textAlign: TextAlign.start,
                                ),
                        ],
                      ),
                    ),

                    // about container
                    Container(
                      margin: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          border: Border.all(
                              color: Colors.grey.shade400, width: 1.5),
                          borderRadius: BorderRadius.circular(8.0)),
                      key: oneKey,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(
                            height: 10,
                          ),
                          Html(
                              data: translateEn == 'en'
                                  ? enAboutDetails
                                  : hiAboutDetails),
                          const SizedBox(
                            height: 10,
                          ),
                          const Padding(
                            padding: EdgeInsets.only(left: 8.0),
                            child: Text(
                              'Products',
                              style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black),
                              maxLines: 2,
                            ),
                          ),
                          ListView.builder(
                            physics: const BouncingScrollPhysics(),
                            itemCount: product.length,
                            shrinkWrap: true,
                            itemBuilder: (context, index) {
                              return InkWell(
                                onTap: () {
                                  getChadhavaLeadSave(
                                    serviceId,
                                    productType,
                                    allProductIds,
                                  );
                                  // String poojaName = translateEn == 'en' ? enName : hiName;
                                  // Navigator.push(
                                  //   context,
                                  //   CupertinoPageRoute(
                                  //       builder: (context) => ChadhavaBilldetails(
                                  //         billAmount: "0",
                                  //         product: product,
                                  //         personCount: 1,
                                  //         typePooja: 'chadhava',
                                  //         orderId: serviceId,
                                  //         packageName: 'Chadhava',
                                  //         poojaName: poojaName,
                                  //         poojaVenue: enVenue,
                                  //         date: bookingDate,
                                  //         leadId: leadId,
                                  //         packageId: 0,
                                  //         serviceId: leadServiceId,
                                  //       )),
                                  // );
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            '✤ ${translateEn == "hi" ? product[index].hiName : product[index].enName}',
                                            style: const TextStyle(
                                                fontSize: 18,
                                                color: Colors.black),
                                            maxLines: 2,
                                          ),
                                          const Spacer(),
                                          const Icon(Icons.keyboard_arrow_right)
                                        ],
                                      ),
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(left: 20.0),
                                        child: Text(
                                          '₹${product[index].price}',
                                          style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.blue),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                // Container(
                                //   margin: const EdgeInsets.only(right: 5,bottom: 10),
                                //   width: 140,
                                //   decoration: BoxDecoration(
                                //       color: Colors.white,
                                //       border: Border.all(color :Colors.grey.shade300,width: 1.5),
                                //     borderRadius: BorderRadius.circular(4.0)
                                //   ),
                                //   child: Padding(
                                //     padding: const EdgeInsets.all(8.0),
                                //     child: Column(
                                //       crossAxisAlignment: CrossAxisAlignment.start,
                                //       children: [
                                //         const SizedBox(height: 5,),
                                //         Center(
                                //           child: Container(
                                //             height: 90,
                                //             width: 130,
                                //             decoration: BoxDecoration(
                                //                 borderRadius: BorderRadius.circular(4),
                                //                 color: Colors.grey.shade300
                                //             ),
                                //             child:  Image.network("${muhuratModelList[index].thumbnail}",fit: BoxFit.cover,)
                                //           ),
                                //         ),
                                //
                                //         Spacer(),
                                //         Text('${translateBtn ? muhuratModelList[index].hiName : muhuratModelList[index].enName}',style: const TextStyle(fontSize: 14,fontWeight: FontWeight.bold,color: Colors.black),maxLines: 2,),
                                //
                                //         Spacer(),
                                //         Text.rich(
                                //             TextSpan(
                                //                 children: [
                                //                   TextSpan(
                                //                       text:'₹${muhuratModelList[index].counsellingSellingPrice} ',style: const TextStyle(fontSize: 14,fontWeight: FontWeight.bold,color:Colors.blue)
                                //                   ),
                                //                   TextSpan(
                                //                       text:'₹${muhuratModelList[index].counsellingMainPrice}',style: const TextStyle(fontSize: 14,fontWeight: FontWeight.bold,color: Colors.black,decoration: TextDecoration.lineThrough)
                                //                   ),
                                //                 ]
                                //             )
                                //         )
                                //
                                //       ],
                                //     ),
                                //   ),
                                // ),
                              );
                            },
                          ),
                          const SizedBox(
                            width: 20,
                          ),
                          Container(
                            color: Colors.orange.shade100,
                            width: double.infinity,
                            height: 10,
                          ),
                          // const SizedBox(
                          //   width: 20,
                          // ),
                          // Container(
                          //   key: sixKey,
                          //   child: PoojaReviewList(
                          //     dataUrl: 'ReviewService/$poojaSlug',
                          //     translate: translateEn,
                          //   ),
                          // ),
                          // Container(
                          //   color: Colors.orange.shade100,
                          //   width: double.infinity,
                          //   height: 10,
                          // ),
                          const SizedBox(
                            height: 10,
                          ),
                          Container(
                            child: Askquestions(
                                type: 'chadhava', translateEn: translateEn),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(
                      height: 60,
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
