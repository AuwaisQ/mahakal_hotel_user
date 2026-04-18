import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:tdk_bouncingwidget/tdk_bouncingwidget.dart';
import '../../../../data/datasource/remote/http/httpClient.dart';
import '../../../../utill/app_constants.dart';
import '../../../../utill/loading_datawidget.dart';
import '../../../donation/controller/lanaguage_provider.dart';
import '../../model/category_model.dart';
import '../static_tab/AllEventScreen.dart';
import 'event_main.dart';
import 'package:provider/provider.dart';

class EventHome extends StatefulWidget {
  const EventHome({super.key});

  @override
  State<EventHome> createState() => _EventHomeState();
}

class _EventHomeState extends State<EventHome> {
  bool isLoading = false;
  bool _isTranslate = false;
  int selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    getEventCategory();
  }

  List<Category> categoryList = [];

  /// Fetch Event Category (Tabs)
  Future<void> getEventCategory() async {
    setState(() {
      isLoading = true;
    });

    try {
      final res = await HttpService().getApi(AppConstants.eventCategoryUrl);

      if (res != null) {
        final getCategory = CategoryModel.fromJson(res);
        setState(() {
          categoryList = getCategory.data ?? [];
        });
      }
    } catch (e) {
      print("Error fetching event categories: $e");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var screenWidth = MediaQuery.of(context).size.width;

    /// TabBar Tabs
    final List<Widget> tabs = [
      _buildTabItem(
        "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRgLwC1Ha0v_FNcR3X2mKGVwYiuMIA3T-JIPw&s",
        "All",
        0,
        "सभी",
      ),
      ...categoryList.asMap().entries.map((entry) {
        final cat = entry.value;
        final index = entry.key + 1; // All tab = 0, isliye +1
        return _buildTabItem(
            cat.image, cat.enCategoryName, index, cat.hiCategoryName);
      }),
    ];

    /// TabBar Views
    final List<Widget> tabView = [
      const AllEventScreen(),
      ...categoryList.map((cat) => EventMain(categoryId: cat.id)),
    ];

    return isLoading
        ? MahakalLoadingData(onReload: () => getEventCategory)
        : categoryList.isEmpty
            ? Scaffold(
                appBar: AppBar(
                  automaticallyImplyLeading: true,
                ),
                backgroundColor: Colors.white,
                body: Column(
                  children: [
                    SizedBox(
                      height: screenWidth * 0.6,
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
                              const SizedBox(
                                height: 100,
                                width: 100,
                                child: Icon(
                                  Icons.hourglass_empty,
                                  size: 50,
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
                                  getEventCategory();
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
                    ),
                  ],
                ))
            : DefaultTabController(
                length: categoryList.length + 1,
                child: Scaffold(
                  appBar: AppBar(
                    leading: IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon:
                          const Icon(Icons.arrow_back_ios, color: Colors.white),
                    ),
                    centerTitle: true,
                    toolbarHeight: 65,
                    backgroundColor: Colors.deepOrange,
                    // backgroundColor: Colors.white,
                    title: Consumer<LanguageProvider>(
                      builder: (BuildContext context, languageProvider, child) {
                        return Text(
                          languageProvider.language == "english"
                              ? "Events"
                              : "इवेंट",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: screenWidth * 0.06,
                              fontWeight: FontWeight.bold),
                        );
                      },
                    ),
                    actions: [
                      Consumer<LanguageProvider>(
                        builder: (context, languageProvider, child) {
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
                                borderRadius: BorderRadius.circular(6.0),
                                color: _isTranslate
                                    ? Colors.white
                                    : Colors.transparent,
                                border: Border.all(
                                    color: _isTranslate
                                        ? Colors.transparent
                                        : Colors.white,
                                    width: 2),
                              ),
                              child: Center(
                                  child: Icon(Icons.translate,
                                      color: _isTranslate
                                          ? Colors.black
                                          : Colors.white,
                                      size: 20)),
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
                      labelStyle: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 20),
                      tabs: tabs,
                    ),
                  ),
                  body: TabBarView(children: tabView),
                ),
              );
  }

  /// Common Tab Item Widget
  Widget _buildTabItem(String imageUrl, String englishName, int index,
      [String? hindiName]) {
    var screenWidth = MediaQuery.of(context).size.width;
    return Tab(
      height: screenWidth / 6.4,
      child: Column(
        children: [
          SizedBox(
            height: screenWidth * 0.09,
            width: screenWidth * 0.09,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: CachedNetworkImage(
                imageUrl: imageUrl ?? '',
                fit: BoxFit.fill,
                errorWidget: (context, url, error) => Container(
                  color: Colors.grey[300], // Placeholder background color
                  child: const Center(
                    child: Icon(Icons.broken_image,
                        size: 16, color: Colors.grey), // Error Icon
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: screenWidth * 0.005),
          SizedBox(
            child: Center(
              child: Consumer<LanguageProvider>(
                builder: (context, languageProvider, child) {
                  return Text(
                    languageProvider.language == "english"
                        ? (englishName ?? '')
                        : (hindiName ?? ''),
                    style: TextStyle(
                      fontSize: screenWidth * 0.04,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      overflow: TextOverflow.ellipsis,
                    ),
                    maxLines: 1,
                  );
                },
              ),
            ),
          )
        ],
      ),
    );
  }
}
