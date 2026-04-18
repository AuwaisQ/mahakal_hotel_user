import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../../data/datasource/remote/http/httpClient.dart';
import '../../../../../../utill/app_constants.dart';
import '../../../../controller/lanaguage_provider.dart';
import '../../../../model/subTrust_model.dart';
import '../../../../ui_helper/custom_colors.dart';
import '../../../../widgets/donation_gridview.dart';

class DaanGrid extends StatefulWidget {
  dynamic myId;
  DaanGrid({super.key, required this.myId});

  @override
  State<DaanGrid> createState() => _GridSahityaState();
}

class _GridSahityaState extends State<DaanGrid> {
  bool _isLoading = false;

  List<SubTrust> subTrust = [];

  Future<void> getAdvertiseMent() async {
    //String url = '${AppConstants.baseUrl}${AppConstants.donationAdsUrl}';
    Map<String, dynamic> data = {
      "type": "trust",
      "trust_category_id": widget.myId,
    };

    setState(() {
      _isLoading = true;
    });

    print("My Category Id Is ${widget.myId}");

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
          print(" Donation Name Is ${subTrust[0].enTrustName}");
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
                                      color:
                                          Colors.black.withValues(alpha: 0.5)),
                                ),
                                Text(
                                  "Please try again later...",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontSize: screenWidth * 0.04,
                                      color:
                                          Colors.black.withValues(alpha: 0.5)),
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
                      return GridView.builder(
                        shrinkWrap: true,
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.all(12),
                        itemCount: subTrust.length,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 15,
                          mainAxisSpacing: 15,
                          childAspectRatio: 0.75,
                        ),
                        itemBuilder: (context, index) => donationGridView(
                            context,
                            "${subTrust[index].id}",
                            subTrust[index].image,
                            languageProvider.language == 'english'
                                ? subTrust[index].enTrustName
                                : subTrust[index].hiTrustName,
                            false), // ← one‑liner reuse
                      );
                    },
                  ),
                ),
    );
  }
}
