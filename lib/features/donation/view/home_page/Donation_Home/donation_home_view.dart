import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tdk_bouncingwidget/tdk_bouncingwidget.dart';
import '../../../../../data/datasource/remote/http/httpClient.dart';
import '../../../../../utill/app_constants.dart';
import '../../../../../utill/loading_datawidget.dart';
import '../../../../sangeet/ui_helper/custom_colors.dart';
import '../../../controller/lanaguage_provider.dart';
import '../../../model/donationcategory_model.dart';
import '../dynamic_view/dynamic_grid/daangrid.dart';
import '../dynamic_view/dynamic_list/daanlist.dart';
import '../in_house_view/in_house_page/inhouse_home.dart';
import '../static_view/all_home_page/allscreen_home.dart';

class DonationHomeView extends StatefulWidget {
  const DonationHomeView({super.key});

  @override
  State<DonationHomeView> createState() => _DonationHomeViewState();
}

class _DonationHomeViewState extends State<DonationHomeView>
    with SingleTickerProviderStateMixin {
  bool _isGridView = true;
  bool _isTranslate = true;
  bool _isLoading = false;
  int selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    getDonationTabs();
  }

  List<DonationTabs> donationCategory = [];

  Future<void> getDonationTabs() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Make POST request using HttpService
      final Map<String, dynamic> res =
          await HttpService().getApi(AppConstants.donationCategoryUrl);
      print(res);

      // Validate and parse response
      if (res.containsKey('status') &&
          res.containsKey('message') &&
          res.containsKey('data') &&
          res['data'] != null) {
        final donationTabs = DonationCategoryModel.fromJson(res);

        setState(() {
          donationCategory = donationTabs.data;
          print(donationCategory.length);
        });
      } else {
        print("Error: 'status' or 'data' key is missing or null in response.");
      }
    } catch (e) {
      print('Error donation tabs $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var screenHeight = MediaQuery.of(context).size.height;
    var screenWidth = MediaQuery.of(context).size.width;

    final List<Widget> tabs = [
      buildDonationTabItem(
        context: context,
        imagePathOrUrl: 'assets/donation/ads.png',
        englishName: 'Ads',
        hindiName: 'विज्ञापन',
        isNetworkImage: false,
        screenWidth: screenWidth,
        screenHeight: screenHeight,
      ),
      ...donationCategory.asMap().entries.map((entry) {
        var cat = entry.value;
        return buildDonationTabItem(
          context: context,
          imagePathOrUrl: cat.image ?? '',
          englishName: cat.enName ?? 'N/A',
          hindiName: cat.hiName ?? 'N/A',
          isNetworkImage: true,
          screenWidth: screenWidth,
          screenHeight: screenHeight,
        );
      }),
      buildDonationTabItem(
        context: context,
        imagePathOrUrl: 'assets/donation/house.png',
        englishName: 'InHouse',
        hindiName: 'इन-हाउस',
        isNetworkImage: false,
        screenWidth: screenWidth,
        screenHeight: screenHeight,
      ),
    ];
    final List<Widget> tabViews = [
      _isGridView
          ? AllScreenHome(
              isGrid: true,
            )
          : AllScreenHome(
              isGrid: false,
            ),
      ...donationCategory.map(
        (cat) => _isGridView
            ? DaanGrid(
                myId: cat.id,
              )
            : DaanList(
                myId: cat.id,
              ),
      ),
      _isGridView
          ? InHouseHome(
              isGrid: true,
            )
          : InHouseHome(
              isGrid: false,
            ),
    ];

    return _isLoading
        ? Scaffold(
            backgroundColor: CustomColors.clrwhite,
            body: MahakalLoadingData(onReload: () => getDonationTabs()))
        : DefaultTabController(
            length: donationCategory.length + 2,
            child: Scaffold(
              backgroundColor: Colors.white,
              appBar: AppBar(
                backgroundColor: Colors.deepOrange,
                title: Consumer<LanguageProvider>(
                  builder: (BuildContext context, languageProvider, child) {
                    return Text(
                      languageProvider.language == 'english'
                          ? 'Donation'
                          : 'दान',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontSize: screenWidth * 0.06,
                          fontFamily: 'Roboto'),
                    );
                  },
                ),
                centerTitle: true,
                leading: IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(Icons.arrow_back_ios,
                      color: Colors.white, size: screenWidth * 0.06),
                ),
                actions: [
                  BouncingWidgetInOut(
                    onPressed: () {
                      setState(() {
                        _isGridView = !_isGridView;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.all(2.0),
                      height: 35,
                      width: 35,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8.0),
                          color:
                              _isGridView ? Colors.white : Colors.transparent,
                          border: Border.all(
                              color: _isGridView
                                  ? Colors.transparent
                                  : Colors.white,
                              width: 2)),
                      child: Icon(
                        _isGridView ? Icons.grid_view : Icons.list,
                        color: _isGridView ? Colors.black : Colors.white,
                      ),
                    ),
                  ),
                  Consumer<LanguageProvider>(
                    builder: (BuildContext context, languageProvider,
                        Widget? child) {
                      return BouncingWidgetInOut(
                        onPressed: () {
                          setState(() {
                            _isTranslate = !_isTranslate;
                            languageProvider.toggleLanguage();
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.all(2.0),
                          height: 35,
                          width: 35,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8.0),
                              color: _isTranslate
                                  ? Colors.white
                                  : Colors.transparent,
                              border: Border.all(
                                  color: _isTranslate
                                      ? Colors.transparent
                                      : Colors.white,
                                  width: 2)),
                          child: Icon(
                            Icons.translate,
                            color: _isTranslate ? Colors.black : Colors.white,
                          ),
                        ),
                      );
                    },
                  ),
                ],
                bottom: TabBar(
                    isScrollable: true,
                    indicatorColor: Colors.white,
                    labelColor: Colors.white,
                    unselectedLabelColor: Colors.black,
                    dividerColor: Colors.transparent,
                    indicatorSize: TabBarIndicatorSize.tab,
                    tabAlignment: TabAlignment.start,
                    padding: EdgeInsets.symmetric(
                        horizontal: 10, vertical: screenWidth * 0.03),
                    splashFactory: NoSplash.splashFactory,
                    indicatorPadding:
                        EdgeInsets.symmetric(horizontal: screenWidth * 0.02),
                    labelStyle: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'Roboto'),
                    tabs: tabs),
              ),
              body: SafeArea(
                child: Column(
                  children: [
                    Expanded(
                      child: TabBarView(children: tabViews),
                    ),
                  ],
                ),
              ),
            ));
  }

  Widget buildDonationTabItem({
    required BuildContext context,
    required String imagePathOrUrl,
    required String englishName,
    bool isNetworkImage = false,
    String? hindiName,
    double? screenWidth,
    double? screenHeight,
  }) {
    final width = screenWidth ?? MediaQuery.of(context).size.width;
    final height = screenHeight ?? MediaQuery.of(context).size.height;

    return Tab(
      height: width / 6.1,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            height: width * 0.09,
            width: width * 0.09,
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6),
              color: Colors.white,
              border: Border.all(color: Colors.white),
            ),
            child: isNetworkImage
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: CachedNetworkImage(
                      imageUrl: imagePathOrUrl,
                      fit: BoxFit.cover,
                      errorWidget: (context, url, error) => const Center(
                          child: Icon(Icons.broken_image, size: 16)),
                    ),
                  )
                : Image.asset(imagePathOrUrl, fit: BoxFit.cover),
          ),
          const SizedBox(height: 5),
          SizedBox(
            width: height * 0.08,
            child: Consumer<LanguageProvider>(
              builder: (context, languageProvider, child) {
                final text = languageProvider.language == "english"
                    ? englishName
                    : (hindiName ?? englishName);

                return Text(
                  text,
                  style: TextStyle(
                    fontSize: width * 0.04,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    overflow: TextOverflow.ellipsis,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
