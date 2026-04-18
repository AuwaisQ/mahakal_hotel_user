import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../../data/datasource/remote/http/httpClient.dart';
import '../../../../../../utill/app_constants.dart';
import '../../../../controller/lanaguage_provider.dart';
import '../../../../model/subTrust_model.dart';
import '../../../../ui_helper/custom_colors.dart';

import '../../../../widgets/donation_listview.dart';

class DaanList extends StatefulWidget {
  dynamic myId;
  DaanList({super.key, required this.myId});

  @override
  State<DaanList> createState() => _DaanListState();
}

class _DaanListState extends State<DaanList> {
  bool _isLoading = false;

  List<SubTrust> subTrust = [];

  Future<void> getAdvertiseMent() async {
    String url = '${AppConstants.baseUrl}${AppConstants.donationAdsUrl}';
    Map<String, dynamic> data = {
      "type": "trust",
      "trust_category_id": widget.myId,
    };

    setState(() {
      _isLoading = true;
    });

    try {
      final res =
          await HttpService().postApi(AppConstants.donationAdsUrl, data);
      //final Map<String, dynamic> res = await ApiServiceDonate().getAdvertise(url, data);
      print(res);

      if (res.containsKey('status') &&
          res.containsKey('message') &&
          res.containsKey('data') &&
          res['data'] != null) {
        final getAdvertiseData = SubTrustModel.fromJson(res);

        setState(() {
          subTrust = getAdvertiseData.data;
          print("My Name Is ${subTrust[0].enTrustName}");
          print("My Name Is ${subTrust[0].image}");
          print("My length Is ${subTrust.length}");
        });
      } else {
        print("Error in Advertisement");
      }
    } catch (e) {
      print(e);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    getAdvertiseMent();
  }

  @override
  Widget build(BuildContext context) {
    var screenWidth = MediaQuery.of(context).size.width;
    var screenHeight = MediaQuery.of(context).size.height;

    return SafeArea(
      child: _isLoading
          ? const Scaffold(
              backgroundColor: CustomColors.clrwhite,
              body: Center(
                  child: CircularProgressIndicator(
                color: Colors.orange,
              )))
          : subTrust.isEmpty
              ? Scaffold(
                  backgroundColor: CustomColors.clrwhite,
                  body: Column(
                    children: [
                      SizedBox(
                        height: screenWidth * 0.3,
                      ),
                      Center(
                        child: SizedBox(
                          width: 300,
                          height: 330,
                          child: Card(
                            shadowColor: Colors.black,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(
                                  height: 100,
                                  width: 100,
                                  decoration: const BoxDecoration(
                                    image: DecorationImage(
                                        image: AssetImage(
                                            "assets/image/connection.png"),
                                        fit: BoxFit.cover),
                                    //color: Colors.red
                                  ),
                                ),
                                Text(
                                  "No Data Found !",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontSize: screenWidth * 0.04,
                                      color: Colors.black.withOpacity(0.5)),
                                ),
                                Text(
                                  "Please try again later...",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontSize: screenWidth * 0.04,
                                      color: Colors.black.withOpacity(0.5)),
                                ),
                                SizedBox(
                                  height: screenWidth * 0.05,
                                ),
                                GestureDetector(
                                  onTap: () {
                                    getAdvertiseMent();
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(5),
                                      color: Colors.red.withOpacity(0.7),
                                    ),
                                    child: Padding(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: screenWidth * 0.2,
                                          vertical: screenWidth * 0.03),
                                      child: Text(
                                        "Try Again",
                                        style: TextStyle(
                                            fontSize: screenWidth * 0.04,
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      )
                    ],
                  ))
              : Scaffold(
                  backgroundColor: Colors.white,
                  body: Consumer<LanguageProvider>(
                    builder: (BuildContext context, languageProvider,
                        Widget? child) {
                      return ListView.builder(
                        itemCount: subTrust.isNotEmpty ? subTrust.length : 0,
                        shrinkWrap: true,
                        itemBuilder: (context, index) {
                          return donationListView(
                              context,
                              "${subTrust[index].id}",
                              subTrust[index].image,
                              languageProvider.language == 'english'
                                  ? subTrust[index].enTrustName
                                  : subTrust[index].hiTrustName,
                              false); // ← one‑liner reuse

                          //   Container(
                          //   margin: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          //   padding: EdgeInsets.all(10),
                          //   decoration: BoxDecoration(
                          //       borderRadius: BorderRadius.circular(8),
                          //       color: Colors.white,
                          //       border: Border.all(color: Colors.grey)),
                          //   child: GestureDetector(
                          //     onTap: () {
                          //       Navigator.push(
                          //           context,
                          //           CupertinoPageRoute(
                          //             builder: (context) =>
                          //                 Donationpage(myId: getAds[index].id),
                          //           ));
                          //     },
                          //     child: Row(
                          //       children: [
                          //         Expanded(
                          //           flex: 0,
                          //           child: Container(
                          //             height: screenHeight * 0.11,
                          //             width: screenHeight * 0.17,
                          //             decoration: BoxDecoration(
                          //               borderRadius: BorderRadius.circular(8),
                          //             ),
                          //             child: ClipRRect(
                          //               borderRadius: BorderRadius.circular(8),
                          //               child: CachedNetworkImage(
                          //                 imageUrl: getAds[index].image ?? "",
                          //                 fit: BoxFit.fill,
                          //                 placeholder: (context, url) => placeholderImage(),
                          //                 errorWidget: (context, url, error) => NoImageWidget()
                          //               ),
                          //             ),
                          //           ),
                          //         ),
                          //         SizedBox(
                          //           width: 10,
                          //         ),
                          //         Expanded(
                          //           flex: 1,
                          //           child: Column(
                          //             crossAxisAlignment: CrossAxisAlignment.start,
                          //             children: [
                          //               SizedBox(
                          //                   width: screenWidth * 0.6,
                          //                   child: Consumer<LanguageProvider>(
                          //                     builder: (BuildContext context,
                          //                         languageProvider, child) {
                          //                       return Text(
                          //                         "${languageProvider.language == "english" ? (getAds[index].enName != null && getAds[index].enName?.isNotEmpty == true ? getAds[index].enName : "N/A") : (getAds[index].hiName != null && getAds[index].hiName?.isNotEmpty == true ? getAds[index].hiName : "N/A")}",
                          //                         style: TextStyle(
                          //                             fontWeight: FontWeight.w500,
                          //                             fontSize: screenWidth * 0.04,
                          //                             color: CustomColors.clrblack,
                          //                             fontFamily: 'Roboto',
                          //                             overflow:
                          //                                 TextOverflow.ellipsis),
                          //                         maxLines: 2,
                          //                       );
                          //                     },
                          //                   )),
                          //               SizedBox(
                          //                 height: screenWidth * 0.02,
                          //               ),
                          //               Container(
                          //                 height: 40,
                          //                 decoration: BoxDecoration(
                          //                     borderRadius: BorderRadius.circular(8),
                          //                     color: Colors.deepOrange),
                          //                 child: Consumer<LanguageProvider>(
                          //                   builder: (BuildContext context,
                          //                       languageProvider, Widget? child) {
                          //                     return Row(
                          //                       mainAxisAlignment:
                          //                           MainAxisAlignment.center,
                          //                       children: [
                          //                         Text(
                          //                           "${languageProvider.language == "english" ? "Donate Now" : "अभी दान करें"}",
                          //                           style: TextStyle(
                          //                               fontSize: screenWidth * 0.04,
                          //                               fontWeight: FontWeight.bold,
                          //                               fontFamily: 'Roboto',
                          //                               color: Colors.white),
                          //                         ),
                          //                         SizedBox(
                          //                           width: screenWidth * 0.02,
                          //                         ),
                          //                         Image.asset(
                          //                           "assets/donation/heart1.png",
                          //                           height: 25,
                          //                           color: Colors.white,
                          //                         ),
                          //                       ],
                          //                     );
                          //                   },
                          //                 ),
                          //               ),
                          //             ],
                          //           ),
                          //         ),
                          //       ],
                          //     ),
                          //   ),
                          // );
                        },
                      );
                    },
                  ),
                ),
    );
  }
}
