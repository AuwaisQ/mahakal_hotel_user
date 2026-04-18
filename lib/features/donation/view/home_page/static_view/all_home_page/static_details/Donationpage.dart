import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:provider/provider.dart';
import '../../../../../../../data/datasource/remote/http/httpClient.dart';
import '../../../../../../../main.dart';
import '../../../../../../../utill/app_constants.dart';
import '../../../../../../../utill/loading_datawidget.dart';
import '../../../../../../pooja_booking/view/tabbarview_screens/askquestions.dart';
import '../../../../../../profile/controllers/profile_contrroller.dart';
import '../../../../../controller/lanaguage_provider.dart';
import '../../../../../model/donationpage_model.dart';
import 'donation_payment.dart';

class Donationpage extends StatefulWidget {
  dynamic myId;

  Donationpage({super.key, required this.myId});

  @override
  State<Donationpage> createState() => _DonationpageState();
}

class _DonationpageState extends State<Donationpage> {
  String userId = '';
  String userPhone = '';
  String userName = '';
  String userEmail = '';

  bool _isExpanded = false;
  bool _isLoading = false;

  DonationPageModel? donationDetails;

  Future<void> getDonationDetails() async {
    Map<String, dynamic> data = {
      "type": "ads", // ads,trust
      "id": "${widget.myId}"
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
        final detailsPageModel = DonationPageModel.fromJson(res);
        setState(() {
          donationDetails = detailsPageModel;
          print("Donation Ads Data is ${donationDetails?.data}");
        });
      } else {
        print("Error in Single  Ads Data");
      }
    } catch (e) {
      print("Error is $e");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    print("my donation ads ${widget.myId}");
    getDonationDetails();
    userId = Provider.of<ProfileController>(Get.context!, listen: false).userID;
    userPhone = Provider.of<ProfileController>(Get.context!, listen: false).userPHONE;
    userName = Provider.of<ProfileController>(Get.context!, listen: false).userNAME;
    userEmail = Provider.of<ProfileController>(Get.context!, listen: false).userEMAIL;
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
                donationDetails?.data != null
                    ? languageProvider.language == "english"
                        ? (donationDetails?.data?.enName.isNotEmpty == true
                            ? donationDetails!.data!.enName
                            : "N/A")
                        : (donationDetails?.data?.hiName.isNotEmpty == true
                            ? donationDetails!.data!.hiName
                            : "N/A")
                    : "N/A",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontSize: screenWidth * 0.05,
                  fontFamily: 'Roboto',
                ),
              );
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
          ? MahakalLoadingData(onReload: () => getDonationDetails())
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
                        Container(
                          height: screenHeight * 0.27,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            image: (donationDetails?.data?.image != null &&
                                    donationDetails!.data!.image.isNotEmpty)
                                ? DecorationImage(
                                    image: CachedNetworkImageProvider(
                                        donationDetails!.data!.image),
                                    fit: BoxFit.fill,
                                  )
                                : null,
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Text(
                          (languageProvider.language == "english"
                              ? (donationDetails?.data?.enName != null &&
                                      donationDetails
                                              ?.data?.enName.isNotEmpty ==
                                          true
                                  ? donationDetails!.data!.enName
                                  : "N/A")
                              : (donationDetails?.data?.hiName != null &&
                                      donationDetails
                                              ?.data?.hiName.isNotEmpty ==
                                          true
                                  ? donationDetails!.data!.hiName
                                  : "N/A")),
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: screenWidth * 0.04,
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Consumer<LanguageProvider>(
                          builder: (BuildContext context, languageProvider,
                              Widget? child) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Html(
                                    data: languageProvider.language == "english"
                                        ? (donationDetails
                                                        ?.data?.enDescription !=
                                                    null &&
                                                donationDetails
                                                        ?.data
                                                        ?.enDescription
                                                        .isNotEmpty ==
                                                    true
                                            ? donationDetails!
                                                .data!.enDescription
                                            : "N/A")
                                        : (donationDetails
                                                        ?.data?.hiDescription !=
                                                    null &&
                                                donationDetails
                                                        ?.data
                                                        ?.hiDescription
                                                        .isNotEmpty ==
                                                    true
                                            ? donationDetails!
                                                .data!.hiDescription
                                            : "N/A"))
                              ],
                            );
                          },
                        ),
                        Consumer<LanguageProvider>(
                          builder: (BuildContext context, languageProvider,
                              Widget? child) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
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
                  Navigator.push(
                    context,
                    CupertinoPageRoute(
                      builder: (context) => DonationPayment(
                        engname: donationDetails!.data!.enName,
                        hinname: donationDetails!.data!.hiName,
                        image: donationDetails!.data!.image,
                        setAmount: '${donationDetails!.data!.setAmount}',
                        myId: '${donationDetails?.data?.id}',
                        userId: userId,
                        userPhone: userPhone,
                        userName: userName,
                        userEmail: userEmail,
                        donationType: 'ads',
                        setTitle: donationDetails!.data!.setTitle,
                        setUnit: donationDetails!.data!.setUnit,
                        setNumber: '${donationDetails!.data!.setNumber}',
                        autoPayStaus: donationDetails!.data!.autoPaySetStatus,
                        productList: donationDetails!.data!.productList,
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
