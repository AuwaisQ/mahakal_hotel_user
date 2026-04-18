import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:mahakal/data/datasource/remote/http/httpClient.dart';
import 'package:provider/provider.dart';
import '../../../../../../main.dart';
import '../../../../../../utill/app_constants.dart';
import '../../../../../../utill/loading_datawidget.dart';
import '../../../../../pooja_booking/view/tabbarview_screens/askquestions.dart';
import '../../../../../profile/controllers/profile_contrroller.dart';
import '../../../../controller/lanaguage_provider.dart';
import '../../../../model/detailspage_model.dart';
import '../../static_view/all_home_page/static_details/donation_payment.dart';

class DetailsPage extends StatefulWidget {
  dynamic myId;
  String? image;

  DetailsPage({
    super.key,
    required this.myId,
    this.image,
  });

  @override
  State<DetailsPage> createState() => _DetailsPageState();
}

class _DetailsPageState extends State<DetailsPage> {
  bool _isLoading = false;
  bool _isExpanded = false;
  int _currentIndex = 0;

  String userId = "";
  String userName = "";
  String userEmail = "";
  String userPhone = "";
  bool isCorrected = false;
  DetailsModel? singleDetails;

  @override
  void initState() {
    super.initState();
    print("my donation trust ${widget.myId}");
    getSingleDetails();
    userId = Provider.of<ProfileController>(Get.context!, listen: false).userID;
    userName =
        Provider.of<ProfileController>(Get.context!, listen: false).userNAME;
    userPhone =
        Provider.of<ProfileController>(Get.context!, listen: false).userPHONE;
    userEmail =
        Provider.of<ProfileController>(Get.context!, listen: false).userEMAIL;
  }

  /// Get Trust Details
  Future<void> getSingleDetails() async {
    Map<String, dynamic> data = {
      "type": "trust", // ads,trust
      "id": widget.myId
    };

    setState(() {
      _isLoading = true;
    });

    try {
      final res = await HttpService()
          .postApi(AppConstants.donationTrustDetailsUrl, data);
      print(res);

      if (res.containsKey('status') &&
          res.containsKey('message') &&
          res.containsKey('data') &&
          res['data'] != null) {
        final detailsPageModel = DetailsModel.fromJson(res);
        setState(() {
          singleDetails = detailsPageModel;
        });
        print("Donation Trust Data is ${singleDetails?.data}");
      } else {
        print("Error in Single Data: Data field is missing or null");
      }
    } catch (e) {
      print(" Type null is $e");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var screenWidth = MediaQuery.of(context).size.width;
    var screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
          elevation: 0,
          shadowColor: Colors.transparent,
          backgroundColor: Colors.deepOrange,
          title: Consumer<LanguageProvider>(
            builder: (BuildContext context, languageProvider, Widget? child) {
              return Text(
                  singleDetails != null
                      ? languageProvider.language == "english"
                          ? singleDetails?.data?.enTrustName != null &&
                                  singleDetails?.data?.enTrustName.isNotEmpty ==
                                      true
                              ? singleDetails!.data!.enTrustName
                              : "N/A"
                          : singleDetails?.data?.hiTrustName != null &&
                                  singleDetails?.data?.hiTrustName.isNotEmpty ==
                                      true
                              ? singleDetails!.data!.hiTrustName
                              : "N/A"
                      : "",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: screenWidth * 0.05,
                      fontFamily: 'Roboto'));
            },
          ),
          centerTitle: true,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios,
              color: Colors.white,
              size: screenWidth * 0.06,
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          )),
      body: _isLoading
          ? MahakalLoadingData(onReload: () => getSingleDetails())
          : Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.03,
                  vertical: screenHeight * 0.01),
              child: SingleChildScrollView(
                child: Consumer<LanguageProvider>(
                  builder:
                      (BuildContext context, languageProvider, Widget? child) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CarouselSlider(
                          options: CarouselOptions(
                            viewportFraction: 1,
                            height: screenHeight * 0.27,
                            enableInfiniteScroll: true,
                            animateToClosest: true,
                            autoPlay: true,
                            autoPlayAnimationDuration:
                                const Duration(microseconds: 500),
                            onPageChanged: (index, reason) {
                              setState(() {
                                _currentIndex = index;
                              });
                            },
                          ),
                          items: [singleDetails?.data?.image[_currentIndex]]
                              .map((i) {
                            return Builder(
                              builder: (BuildContext context) {
                                return Container(
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    color: Colors.grey.shade400,
                                    image: DecorationImage(
                                      image:
                                          CachedNetworkImageProvider(i ?? ""),
                                      fit: BoxFit.fill,
                                    ),
                                  ),
                                );
                              },
                            );
                          }).toList(),
                        ),
                        Consumer<LanguageProvider>(
                          builder: (BuildContext context, languageProvider,
                              Widget? child) {
                            return Html(
                                data: languageProvider.language == "english"
                                    ? singleDetails?.data?.enDescription !=
                                                null &&
                                            singleDetails?.data?.enDescription
                                                    .isNotEmpty ==
                                                true
                                        ? singleDetails?.data?.enDescription
                                        : "N/A"
                                    : singleDetails?.data?.hiDescription !=
                                                null &&
                                            singleDetails?.data?.hiDescription
                                                    .isNotEmpty ==
                                                true
                                        ? singleDetails?.data?.hiDescription
                                        : "N/A");
                          },
                        ),
                        Consumer<LanguageProvider>(
                          builder: (BuildContext context, languageProvider,
                              Widget? child) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Note 1

                                Text(
                                  languageProvider.language == "english"
                                      ? '* Note:-'
                                      : "टिप्पणी:",
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontSize: screenWidth * 0.04,
                                      fontWeight: FontWeight.bold),
                                ),

                                SizedBox(
                                  height: screenWidth * 0.01,
                                ),
                                Text.rich(
                                  TextSpan(
                                    children: [
                                      TextSpan(
                                        text: "1)",
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: screenWidth * 0.04,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      TextSpan(
                                        text: languageProvider.language ==
                                                "english"
                                            ? " Avail tz exemption on 50% of the amount you donate under section 80G of the Income Tax Act. Our NGO partners may retain a portion of the donated amount to cover their costs. However, you will receive the 80G certificate for the total amount donated."
                                            : " आयकर अधिनियम की धारा 80जी के तहत आपके द्वारा दान की गई राशि के 50% पर छूट का लाभ उठाएं। हमारे एनजीओ भागीदार अपनी लागत को कवर करने के लिए दान की गई राशि का एक हिस्सा अपने पास रख सकते हैं। हालाँकि, आपको दान की गई कुल राशि के लिए 80G प्रमाणपत्र प्राप्त होगा।",
                                        style: TextStyle(
                                            color: const Color.fromRGBO(
                                                79, 79, 79, 1),
                                            fontSize: screenWidth * 0.04,
                                            fontWeight: FontWeight.w500),
                                      ),
                                    ],
                                  ),
                                  maxLines: _isExpanded ? null : 2,
                                  overflow: _isExpanded
                                      ? TextOverflow.visible
                                      : TextOverflow.ellipsis,
                                ),

                                SizedBox(
                                  height: screenWidth * 0.01,
                                ),
                                Text.rich(
                                  TextSpan(
                                    children: [
                                      TextSpan(
                                        text: "2)",
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: screenWidth * 0.04,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      TextSpan(
                                        text: languageProvider.language ==
                                                "english"
                                            ? " Donations once processed cannot be canceled or refunded."
                                            : " एक बार  दान होने के बाद इसे रद्द या वापस नहीं किया जा सकता है।",
                                        style: TextStyle(
                                            color: const Color.fromRGBO(
                                                79, 79, 79, 1),
                                            fontSize: screenWidth * 0.04,
                                            fontWeight: FontWeight.w500),
                                      ),
                                    ],
                                  ),
                                  maxLines: _isExpanded ? null : 1,
                                  overflow: _isExpanded
                                      ? TextOverflow.visible
                                      : TextOverflow.ellipsis,
                                ),

                                SizedBox(height: screenHeight * 0.01),

                                // Show more / Show less button
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _isExpanded = !_isExpanded;
                                    });
                                  },
                                  child: Text(
                                    _isExpanded ? "Show less" : "Show more",
                                    style: TextStyle(
                                      color: Colors.blue,
                                      fontSize: screenWidth * 0.04,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                        Divider(
                          color: Colors.grey.shade300,
                        ),
                        Consumer<LanguageProvider>(
                          builder: (BuildContext context, languageProvider,
                              Widget? child) {
                            return Askquestions(
                                type: 'donate',
                                translateEn:
                                    languageProvider.language == "english"
                                        ? "en"
                                        : "hi");
                          },
                        ),
                        const SizedBox(
                          height: 50,
                        )
                      ],
                    );
                  },
                ),
              ),
            ),
      floatingActionButton: _isLoading
          ? Container()
          : Padding(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: GestureDetector(
                onTap: () {
                  final data = {
                    'engname': singleDetails?.data?.enTrustName ?? "",
                    'hinname': singleDetails?.data?.hiTrustName ?? "",
                    'image': (singleDetails?.data?.image.isNotEmpty ?? false)
                        ? singleDetails?.data?.image[0]
                        : '',
                    'setAmount': '',
                    'myId': '${singleDetails?.data?.id}',
                    'userId': userId,
                    'userPhone': userPhone,
                    'userName': userName,
                    'userEmail': userEmail,
                    'donationType': 'trust',
                    'setTitle': "",
                    'setUnit': '',
                    'setNumber': '',
                    'autoPayStatus': singleDetails?.data?.autoStatus ?? '',
                  };

                  print("Final Data $data");

                  Navigator.push(
                    context,
                    CupertinoPageRoute(
                      builder: (context) => DonationPayment(
                        engname: singleDetails?.data?.enTrustName ?? "",
                        hinname: singleDetails?.data?.hiTrustName ?? "",
                        image: singleDetails?.data?.image[0] ?? '',
                        setAmount: '',
                        // myId: '${widget.myId}',
                        myId: '${singleDetails?.data?.id}',
                        userId: userId,
                        userPhone: userPhone,
                        userName: userName,
                        userEmail: userEmail,
                        donationType: 'trust',
                        setTitle: "",
                        setUnit: '',
                        setNumber: '',
                        autoPayStaus: singleDetails!.data!.autoStatus, productList: [],
                      ),
                    ),
                  );
                },
                child: Consumer<LanguageProvider>(
                  builder:
                      (BuildContext context, languageProvider, Widget? child) {
                    return Container(
                      height: 45, // Slightly increased height
                      width: double.infinity,
                      margin: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8), // Better margin
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFFFFA726), // Light orange
                            Color(0xFFFB8C00), // Orange
                            Color(0xFFE6421C), // Deep orange
                          ],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        borderRadius:
                            BorderRadius.circular(12), // Slightly more rounded
                        boxShadow: [
                          BoxShadow(
                            color: Colors.orange.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              languageProvider.language == "english"
                                  ? "Donate Now"
                                  : "अभी दान करें",
                              style: TextStyle(
                                fontSize: screenWidth *
                                    0.045, // Slightly smaller font
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5, // Added letter spacing
                              ),
                            ),
                            SizedBox(width: screenWidth * 0.03),
                            const Icon(
                              Icons.volunteer_activism,
                              color: Colors.white,
                              size: 28, // Slightly larger icon
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
