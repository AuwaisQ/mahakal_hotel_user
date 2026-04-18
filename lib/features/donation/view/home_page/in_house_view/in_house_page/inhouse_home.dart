import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:mahakal/data/datasource/remote/http/httpClient.dart';
import 'package:provider/provider.dart';
import '../../../../../../utill/app_constants.dart';
import '../../../../controller/lanaguage_provider.dart';
import '../../../../model/advertisement_model.dart';
import '../../../../model/getpurpose_model.dart';
import '../../../../ui_helper/custom_colors.dart';

import 'in_house_grid/in_house_griddata.dart';
import 'in_house_list/in_house_list.dart';

class InHouseHome extends StatefulWidget {
  bool isGrid;

  InHouseHome({super.key, required this.isGrid});

  @override
  State<InHouseHome> createState() => _InHouseHomeState();
}

class _InHouseHomeState extends State<InHouseHome> {
  bool _isLoading = false;
  int _selectedIndex = 0;

  List<GetPurpose> getPurpose = [];
  List<AdvertiseMent> getAds = [];

  Future<void> getPurposeData() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final res = await HttpService().getApi(AppConstants.donationPurposeUrl);
      //final Map<String,dynamic> res = await ApiServiceDonate().getData("${AppConstants.baseUrl}${AppConstants.donationPurposeUrl}");
      print(res);

      if (res.containsKey('status') &&
          res.containsKey('message') &&
          res.containsKey('data') &&
          res['data'] != null) {
        final purposeData = GetPurposeModel.fromJson(res);

        setState(() {
          getPurpose = purposeData.data;
        });
        print(getPurpose.length);
      } else {
        print("error in purpose data");
      }
    } catch (e) {
      print(e);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> getAdvertiseMent() async {
    //String url = '${AppConstants.baseUrl}${AppConstants.donationAdsUrl}';
    Map<String, dynamic> data = {
      "type": "ads",
      "trust_category_id": '',
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
        final getAdvertiseData = AdvertisementModel.fromJson(res);

        setState(() {
          getAds = getAdvertiseData.data;
          print("${getAds.length}");
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
    getPurposeData();
    getAdvertiseMent();
  }

  @override
  Widget build(BuildContext context) {
    var screenWidth = MediaQuery.of(context).size.width;
    var screenHeight = MediaQuery.of(context).size.height;

    final List<Widget> tabs = [
      Tab(
        height: 30,
        child: Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: _selectedIndex == 0 ? Colors.transparent : Colors.grey,
              )),
          child: Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.06,
                  vertical: screenWidth * 0.009),
              child: Consumer<LanguageProvider>(
                builder:
                    (BuildContext context, languageProvider, Widget? child) {
                  return Row(
                    children: [
                      const Image(image: AssetImage("assets/donation/all.png")),
                      SizedBox(
                        width: screenWidth * 0.02,
                      ),
                      Text(
                        languageProvider.language == "english" ? "All" : "सभी",
                        //  languageManager.nameLanguage == 'English' ? "All" : "सभी",
                        style: TextStyle(
                            fontSize: screenWidth * 0.04,
                            color: CustomColors.clrorange),
                      ),
                    ],
                  );
                },
              )

              //  },
              //  ),
              ),
        ),
      ),
      ...getPurpose.map(
        (cat) => Tab(
          height: 30,
          child: Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: _selectedIndex == getPurpose.indexOf(cat) + 1
                      ? Colors.transparent
                      : Colors.grey,
                )),
            child: Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: screenWidth * 0.06,
                    vertical: screenWidth * 0.009),
                child: Consumer<LanguageProvider>(
                  builder:
                      (BuildContext context, languageProvider, Widget? child) {
                    return Row(
                      children: [
                        Image(
                          image: CachedNetworkImageProvider(
                              cat.image ?? 'https://via.placeholder.com/150'),
                        ),
                        SizedBox(
                          width: screenWidth * 0.02,
                        ),
                        Text(
                          languageProvider.language == "english"
                              ? (cat.enName.isNotEmpty ? cat.enName : "N/A")
                              : (cat.hiName.isNotEmpty ? cat.hiName : "N/A"),
                          style: TextStyle(
                              fontSize: screenWidth * 0.04,
                              color: CustomColors.clrorange),
                        ),
                      ],
                    );
                  },
                )),
          ),
        ),
      )
    ];

    final List<Widget> tabViews = [
      widget.isGrid
          ? InHouseGridData(
              purposeId: "",
              type: "ads_inhouse",
            )
          : InHouseListData(
              purposeId: "",
              type: "ads_inhouse",
            ),
      ...getPurpose.map((cat) => widget.isGrid
          ? InHouseGridData(
              purposeId: cat.id.toString(),
              type: "ads_inhouse",
            )
          : InHouseListData(
              purposeId: cat.id.toString(),
              type: "ads_inhouse",
            ))
    ];

    return SafeArea(
      child: _isLoading
          ? const Scaffold(
              backgroundColor: CustomColors.clrwhite,
              body: Center(
                  child: CircularProgressIndicator(
                color: Colors.orange,
              )))
          : getPurpose.isEmpty && getAds.isEmpty
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
                                    getPurposeData();
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
              : DefaultTabController(
                  length: getPurpose.length + 1,
                  child: Scaffold(
                      backgroundColor: Colors.white,
                      appBar: AppBar(
                        backgroundColor: Colors.grey.shade50,
                        toolbarHeight: 55,
                        automaticallyImplyLeading: false,
                        flexibleSpace: TabBar(
                            onTap: (index) {
                              setState(() {
                                _selectedIndex =
                                    index; // Update selected index on tap
                              });
                            },
                            isScrollable: true,
                            padding: const EdgeInsets.symmetric(
                              vertical: 12,
                            ),
                            unselectedLabelColor: CustomColors.clrblack,
                            labelColor: Colors.black,
                            indicatorWeight: 0.1,
                            splashFactory: NoSplash.splashFactory,
                            dividerColor: Colors.transparent,
                            tabAlignment: TabAlignment.start,
                            indicator: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: Colors.orange)),
                            tabs: tabs),
                      ),
                      body: TabBarView(
                          physics: const NeverScrollableScrollPhysics(),
                          children: tabViews))),
    );
  }
}
