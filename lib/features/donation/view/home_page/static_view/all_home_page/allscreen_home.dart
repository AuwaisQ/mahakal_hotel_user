import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../../data/datasource/remote/http/httpClient.dart';
import '../../../../../../utill/app_constants.dart';
import '../../../../controller/lanaguage_provider.dart';
import '../../../../model/advertisement_model.dart';
import '../../../../model/getpurpose_model.dart';
import '../../../../ui_helper/custom_colors.dart';

import 'all_grid_data/all_screen_griddata.dart';
import 'all_list_data/allscreen_listdata.dart';

class AllScreenHome extends StatefulWidget {
  bool isGrid;

  AllScreenHome({super.key, required this.isGrid});

  @override
  State<AllScreenHome> createState() => _AllScreenHomeState();
}

class _AllScreenHomeState extends State<AllScreenHome> {
  bool _isLoading = false;
  int _selectedIndex = 0;

  List<GetPurpose> getPurpose = [];
  List<AdvertiseMent> getAds = [];

  @override
  void initState() {
    super.initState();
    getPurposeData();
    getAdvertiseMent();
  }

  Future<void> getPurposeData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Make the POST request
      final res = await HttpService().getApi(AppConstants.donationPurposeUrl);

      // Check for required keys and parse the data
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
        print("Error: 'status' or 'data' key is missing or null in response.");
      }
    } catch (e) {
      print("Error in getPurposeData: $e");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> getAdvertiseMent() async {
    final Map<String, dynamic> data = {
      "type": "ads",
      "trust_category_id": '',
    };
    setState(() {
      _isLoading = true;
    });

    try {
      // Use postApi to make the request
      final res =
          await HttpService().postApi(AppConstants.donationAdsUrl, data);
      print(res);

      // Check for valid response structure
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
        print(
            "Error: Advertisement response missing required fields or data is null.");
      }
    } catch (e) {
      print("Error in getAdvertiseMent: $e");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
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
                      const Image(
                        image: AssetImage("assets/donation/all.png"),
                        height: 20,
                      ),
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
                        Image(image: NetworkImage(cat.image ?? ''), height: 20),
                        SizedBox(
                          width: screenWidth * 0.02,
                        ),
                        Text(
                          languageProvider.language == "english"
                              ? (cat.enName.isNotEmpty == true
                                  ? cat.enName
                                  : "N/A")
                              : (cat.hiName.isNotEmpty == true
                                  ? cat.hiName
                                  : "N/A"),
                          //  languageManager.nameLanguage == 'English' ? "All" : "सभी",
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
          ? AllScreenGridData(
              purposeId: "",
              type: "ads",
            )
          : AllScreenListData(
              purposeId: "",
              type: "ads",
            ),
      ...getPurpose.map((cat) => widget.isGrid
          ? AllScreenGridData(
              purposeId: cat.id.toString(),
              type: "ads",
            )
          : AllScreenListData(
              purposeId: cat.id.toString(),
              type: "ads",
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
          : (getPurpose.isEmpty ?? true) && (getAds.isEmpty ?? true)
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
                                _selectedIndex = index;
                              });
                            },
                            isScrollable: true,
                            labelColor: Colors.black,
                            padding: const EdgeInsets.symmetric(
                                vertical: 12, horizontal: 10),
                            splashFactory: NoSplash.splashFactory,
                            dividerColor: Colors.transparent,
                            tabAlignment: TabAlignment.start,
                            indicatorSize: TabBarIndicatorSize.tab,
                            indicator: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: Colors.orange)),
                            tabs: tabs),
                      ),
                      body: Column(
                        children: [
                          const SizedBox(
                            height: 10,
                          ),
                          Expanded(
                            child: TabBarView(
                                physics: const NeverScrollableScrollPhysics(),
                                children: tabViews),
                          ),
                        ],
                      ))),
    );
  }
}
