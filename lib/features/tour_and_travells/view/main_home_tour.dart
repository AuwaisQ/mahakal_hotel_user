import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:mahakal/features/tour_and_travells/model/new_tours_model.dart';
import 'package:mahakal/features/tour_and_travells/model/tour_category_model.dart';
import 'package:mahakal/features/tour_and_travells/ui_heliper/search_screen.dart';
import 'package:mahakal/features/tour_and_travells/view/TourDetails.dart';
import 'package:mahakal/features/tour_and_travells/view/tour_packages/statewise_tour.dart';
import 'package:mahakal/features/tour_and_travells/view/view_all_tours.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../data/datasource/remote/http/httpClient.dart';
import '../../../localization/controllers/localization_controller.dart';
import '../../../utill/app_constants.dart';
import '../../../utill/flutter_toast_helper.dart';
import '../../../utill/loading_datawidget.dart';
import '../model/all_state_model.dart';
import '../model/tourimages_model.dart';

class TourHomePage extends StatefulWidget {
  final ScrollController scrollController;
  const TourHomePage({super.key, required this.scrollController});

  @override
  _TourHomePageState createState() => _TourHomePageState();
}

class _TourHomePageState extends State<TourHomePage>
    with SingleTickerProviderStateMixin {
  TabController? _tabController;

  // State variables
  bool isAnimatedOpacityVisible = false;
  bool isCollapsed = false;
  bool isLoading = false;
  //final List<double> sectionHeights = [600.0, 600.0, 600.0, 600.0];
  late double expandedBarHeight;
  late double collapsedBarHeight;
  String translateEn = "en";
  int selectedTabIndex = 0;

  @override
  void initState() {
    super.initState();
    getTourTabs();
    // Initialize ScrollControllere
    widget.scrollController.addListener(_onScroll);
    getAllState();
  }

  List<TourTabs> tourTabs = [];
  List<TourAllState> stateNames = [];

  Future<void> getTourTabs() async {
    setState(() {
      isLoading = true;
    });

    try {
      const url = AppConstants.tourCategoryUrl;
      final res = await HttpService().getApi(url);
      print(res);

      if (res != null) {
        final category = TourCategoryModel.fromJson(res);
        setState(() {
          tourTabs = category.data;
          print(tourTabs.length);
          _tabController =
              TabController(length: tourTabs.length + 1, vsync: this);
        });
      }
    } catch (e) {
      print("Error in fetching tour tabs: $e");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Initialize expandedBarHeight and collapsedBarHeight after MediaQuery is available
    expandedBarHeight = MediaQuery.of(context).size.height * 0.60; //63
    collapsedBarHeight = MediaQuery.of(context).size.height * 0.12;
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  void _onScroll() {
    setState(() {
      isAnimatedOpacityVisible =
          widget.scrollController.offset > (expandedBarHeight - collapsedBarHeight);
    });
  }

  /// Get All State
  Future<void> getAllState() async {
    try {
      final res = await HttpService().getApi(AppConstants.tourAllStateUrl);
      print("My All State Res: $res");

      if (res != null) {
        final stateRes = TourAllStateModel.fromJson(res);
        setState(() {
          stateNames = stateRes.data;
        });
      }
    } catch (e) {
      print("Tour All State Error: $e");
    }
  }

  void _showStateBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      isScrollControlled: true,
      builder: (_) => DraggableScrollableSheet(
        expand: false,
        maxChildSize: 0.9,
        initialChildSize: 0.7,
        builder: (context, scrollController) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16),
          child: Column(
            children: [
              // Drag handle
              Container(
                height: 5,
                width: 50,
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),

              // Header
              const Text(
                "All States of India",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 16),

              Expanded(
                child: GridView.builder(
                  controller: scrollController,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.8,
                  ),
                  itemCount: stateNames.length,
                  itemBuilder: (context, index) {
                    final state = stateNames[index];

                    return InkWell(
                      borderRadius: BorderRadius.circular(14),
                      onTap: () {
                        Navigator.push(
                          context,
                          CupertinoPageRoute(
                            builder: (context) => ViewAllTours(
                              stateName: state.name ?? "",
                              tourSlug: "",
                            ),
                          ),
                        );
                      },
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [

                          /// Image circle
                          Container(
                            width: 55,
                            height: 55,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.blue.withOpacity(0.25),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                )
                              ],
                            ),
                            child: ClipOval(
                              child: CachedNetworkImage(
                                imageUrl: state.logo,
                                fit: BoxFit.cover,
                                placeholder: (c, u) => placeholderImage(),
                                errorWidget: (c, u, e) => const NoImageWidget(),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),

                          /// Name tag
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade100.withOpacity(0.4),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              state.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          )
                        ],
                      ),
                    );
                  },
                ),
              )

            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var screenWidth = MediaQuery.of(context).size.width;
    var screenHeight = MediaQuery.of(context).size.height;
    return isLoading
        ? MahakalLoadingData(onReload: () => getTourTabs)
        : tourTabs.isEmpty
            ? Scaffold(
                backgroundColor: Colors.white,
                appBar: AppBar(
                  automaticallyImplyLeading: true,
                ),
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
                                  getTourTabs();
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
                floatingActionButton: FloatingActionButton(
                  onPressed: () {
                    _showStateBottomSheet(context);
                    //Navigator.pop(context);
                  },
                  backgroundColor: Colors.white,
                  elevation: 8,
                  highlightElevation: 12,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.blue.shade600,
                          Colors.blue.shade400,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blue.withOpacity(0.4),
                          blurRadius: 10,
                          spreadRadius: 2,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.location_off_outlined,
                      size: 28,
                      color: Colors.white,
                    ),
                  ),
                ),
                appBar: AppBar(
                  backgroundColor: isAnimatedOpacityVisible
                      ? Colors.white
                      : Colors.transparent,
                  title: AnimatedOpacity(
                    duration: const Duration(milliseconds: 200),
                    opacity: isAnimatedOpacityVisible ? 1.0 : 0.0,
                    child: const MainCollapsedContent(selectedIndex: 0),
                  ),
                  automaticallyImplyLeading: false,
                ),
                extendBodyBehindAppBar: true,
                body: DefaultTabController(
                  length: tourTabs.length + 1,
                  child: Stack(
                    children: [
                      isLoading
                          ? const Center(
                              child: CircularProgressIndicator(
                              color: Colors.blue,
                            ))
                          : NestedScrollView(
                              controller: widget.scrollController,
                              headerSliverBuilder:
                                  (context, innerBoxIsScrolled) {
                                return [
                                  SliverAppBar(
                                    expandedHeight: expandedBarHeight,
                                    floating: true,
                                    pinned: true,
                                    stretch: true,
                                    automaticallyImplyLeading: false,
                                    elevation: 0,
                                    backgroundColor: isAnimatedOpacityVisible
                                        ? Colors.transparent
                                        : Colors.transparent,
                                    flexibleSpace: const FlexibleSpaceBar(
                                      background: MainExpandContent(),
                                    ),
                                    bottom: PreferredSize(
                                      preferredSize: const Size.fromHeight(
                                          48), // height of TabBar
                                      child: Container(
                                        color: isAnimatedOpacityVisible
                                            ? Colors.white
                                            : Colors.transparent,
                                        child: TabBar(
                                          isScrollable: true,
                                          controller: _tabController,
                                          tabAlignment: TabAlignment.start,
                                          indicatorColor: Colors.transparent,
                                          indicatorSize:
                                              TabBarIndicatorSize.tab,
                                          indicatorPadding:
                                              const EdgeInsets.symmetric(
                                                  horizontal: 5, vertical: 4),
                                          labelPadding:
                                              const EdgeInsets.symmetric(
                                                  horizontal: 6),
                                          onTap: (index) {
                                            setState(() {
                                              selectedTabIndex = index;
                                            });
                                          },
                                          tabs: [
                                            // 1️⃣ Static All Tab
                                            Tab(
                                              child: AnimatedContainer(
                                                duration: const Duration(
                                                    milliseconds: 300),
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 14,
                                                        vertical: 9),
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(25),
                                                  color: selectedTabIndex == 0
                                                      ? Colors.blue
                                                      : Colors.blueGrey[100],
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: Colors.black
                                                          .withOpacity(0.05),
                                                      blurRadius: 4,
                                                      offset:
                                                          const Offset(0, 2),
                                                    ),
                                                  ],
                                                ),
                                                child: Text(
                                                  "All",
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w600,
                                                    color: selectedTabIndex == 0
                                                        ? Colors.white
                                                        : Colors.black87,
                                                  ),
                                                ),
                                              ),
                                            ),

                                            // 2️⃣ Dynamic Tabs from API
                                            ...tourTabs.reversed
                                                .toList()
                                                .asMap()
                                                .entries
                                                .map((entry) {
                                              final index = entry.key;
                                              final tabNames = entry.value;
                                              final isSelected =
                                                  selectedTabIndex ==
                                                      index + 1; // shift +1

                                              return Tab(
                                                child: AnimatedContainer(
                                                  duration: const Duration(
                                                      milliseconds: 300),
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 14,
                                                      vertical: 9),
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            25),
                                                    color: isSelected
                                                        ? Colors.blue
                                                        : Colors.blueGrey[100],
                                                    boxShadow: [
                                                      BoxShadow(
                                                        color: Colors.black
                                                            .withOpacity(0.05),
                                                        blurRadius: 4,
                                                        offset:
                                                            const Offset(0, 2),
                                                      ),
                                                    ],
                                                  ),
                                                  child: Consumer<
                                                      LocalizationController>(
                                                    builder: (context,
                                                        localizationController,
                                                        child) {
                                                      String currentLang =
                                                          localizationController
                                                              .locale
                                                              .languageCode;
                                                      return Text(
                                                        currentLang == 'hi'
                                                            ? tabNames.hiName ??
                                                                "N/A"
                                                            : tabNames.enName ??
                                                                "N/A",
                                                        style: TextStyle(
                                                          fontSize: 14,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          color: isSelected
                                                              ? Colors.white
                                                              : Colors.black87,
                                                        ),
                                                      );
                                                    },
                                                  ),
                                                ),
                                              );
                                            }).toList(),
                                          ],
                                          overlayColor: WidgetStateProperty.all(
                                              Colors.transparent),
                                          splashFactory: NoSplash.splashFactory,
                                          dividerColor: Colors.transparent,
                                        ),
                                      ),
                                    ),
                                  ),
                                ];
                              },
                              body: TabBarView(
                                controller: _tabController,
                                physics:
                                    const NeverScrollableScrollPhysics(), // Prevents swipe
                                children: [
                                  // 1️⃣ First Page for "All"
                                  StateWiseTour(
                                    stateSlug: "", // empty or handle as "All"
                                  ),

                                  // 2️⃣ Dynamic Pages from API
                                  ...tourTabs.reversed.map((cat) {
                                    return StateWiseTour(
                                      stateSlug: cat.slug,
                                    );
                                  }).toList(),
                                ],
                              ),
                            )
                    ],
                  ),
                ),
              );
  }
}

class MainCollapsedContent extends StatelessWidget {
  final int selectedIndex;

  const MainCollapsedContent({
    super.key,
    required this.selectedIndex,
  });

  @override
  Widget build(BuildContext context) {
    var screenWidth = MediaQuery.of(context).size.width;
    var screenHeight = MediaQuery.of(context).size.height;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: screenWidth * 0.05),
      child: InkWell(
        onTap: () {
          Navigator.push(
              context,
              CupertinoPageRoute(
                builder: (context) => const TourSearchScreen(
                  recentName: '',
                ),
              ));
        },
        child: Container(
          height: screenHeight * 0.05,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.grey),
            color: Colors.white,
          ),
          child: Center(
            child: Padding(
              padding:
              EdgeInsets.symmetric(horizontal: screenWidth * 0.02),
              child: Row(
                children: [
                  const Icon(Icons.search),
                  Consumer<LocalizationController>(
                    builder: (context, localizationController, child) {
                      String currentLang =
                          localizationController.locale.languageCode;
                      return Text(
                        currentLang == 'hi'
                            ? 'स्थान खोजे'
                            : 'Search destinations',
                        style: TextStyle(
                          fontSize: screenWidth * 0.04,
                          color: Colors.black,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class MainExpandContent extends StatefulWidget {
  const MainExpandContent({super.key});

  @override
  State<MainExpandContent> createState() => _MainExpandContentState();
}

class _MainExpandContentState extends State<MainExpandContent> {
  late PageController _pageController;
  int _currentPage = 0;
  Timer? _timer;

  final List<String> _defaultSearches = [
    "Ujjain",
    "Indore",
    "Omkareshwar",
    "Mahakaleshwar"
  ];

  List<String> _recentSearches = [];
  List<NewToursData> _newToursList = [];
  TourImagesModel? tourImagesList;

  @override
  void initState() {
    super.initState();

    _pageController = PageController(initialPage: 0);

    fetchToursImages().then((_) {
      if (tourImagesList?.data.isNotEmpty ?? false) {
        _timer = Timer.periodic(const Duration(seconds: 2), (timer) {
          if (_currentPage < (tourImagesList?.data.length ?? 1) - 1) {
            _currentPage++;
          } else {
            _currentPage = 0;
          }

          if (_pageController.hasClients) {
            _pageController.animateToPage(
              _currentPage,
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeInOut,
            );
          }
        });
      }
    });

    _loadRecentSearches();
    fetchNewTours();
  }

  /// Fetch New Tours
  Future<void> fetchNewTours() async {
    try {
      const url = AppConstants.newTourDataUrl;
      final res = await HttpService().getApi(url);

      if (res != null) {
        final newToursList = NewToursModel.fromJson(res);
        setState(() {
          _newToursList = newToursList.data ?? [];
        });
      } else {
        setState(() {
          _newToursList = [];
        });
      }
    } catch (e) {
      print("Error fetching new tours: $e");
    }
  }

  /// Fetch Tour Images
  Future<void> fetchToursImages() async {
    try {
      const url = AppConstants.tourImagesUrl;
      final res = await HttpService().getApi(url);

      if (res != null) {
        final tourImages = TourImagesModel.fromJson(res);
        setState(() {
          tourImagesList = tourImages;
        });
      }
    } catch (e) {
      print("Error fetching tour images: $e");
    }
  }

  /// Load recent searches
  Future<void> _loadRecentSearches() async {
    final prefs = await SharedPreferences.getInstance();
    final savedSearches = prefs.getStringList('recentSearches') ?? [];

    setState(() {
      _recentSearches = {..._defaultSearches, ...savedSearches}.toList();
    });
  }

  /// Remove a search item
  Future<void> _removeSearch(int index) async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      _recentSearches.removeAt(index);
    });

    final onlyUserSearches = _recentSearches
        .where((item) => !_defaultSearches.contains(item))
        .toList();

    await prefs.setStringList('recentSearches', onlyUserSearches);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var screenWidth = MediaQuery.of(context).size.width;
    var screenHeight = MediaQuery.of(context).size.height;

    return Stack(
      children: [
        // Background Slider
        if ((tourImagesList?.data.isNotEmpty ?? false))
          PageView.builder(
            controller: _pageController,
            itemCount: tourImagesList?.data.length ?? 0,
            itemBuilder: (context, index) {
              final imageUrl = tourImagesList?.data[index] ?? '';
              return Image.network(
                imageUrl,
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
                errorBuilder: (_, __, ___) => Container(
                  color: Colors.grey.shade300,
                  child: const Center(child: Icon(Icons.image, size: 50)),
                ),
              );
            },
          )
        else
          Container(
            color: Colors.grey.shade200,
            child: const Center(
                child: CircularProgressIndicator(
              color: Colors.transparent,
            )),
          ),

        // Top gradient overlay
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.3),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),

        // Bottom white gradient overlay
        Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            height: 150,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [
                  Colors.white.withOpacity(1),
                  Colors.white.withOpacity(0),
                ],
              ),
            ),
          ),
        ),

        // Foreground content
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: screenWidth * 0.24),

            // App Bar with Back & Search
            Padding(
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
              child:  InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    CupertinoPageRoute(
                      builder: (context) =>
                      const TourSearchScreen(recentName: ''),
                    ),
                  );
                  _loadRecentSearches();
                },
                child: Container(
                  height: screenHeight * 0.05,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  padding: EdgeInsets.symmetric(
                      horizontal: screenWidth * 0.03),
                  child: Row(
                    children: [
                      const Icon(Icons.search, color: Colors.black54),
                      const SizedBox(width: 8),
                      Consumer<LocalizationController>(
                        builder:
                            (context, localizationController, child) {
                          String currentLang = localizationController
                              .locale.languageCode;
                          return Text(
                            currentLang == 'hi'
                                ? 'स्थान खोजे'
                                : 'Search destinations',
                            style: TextStyle(
                              fontSize: screenWidth * 0.04,
                              color: Colors.black,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(height: screenWidth * 0.04),

            // Recent Searches Horizontal Chips
            if(_recentSearches.isNotEmpty)
            Container(
                height: 36,
                padding: const EdgeInsets.only(left: 16),
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _recentSearches.length,
                  itemBuilder: (context, index) {
                    return Container(
                      margin: const EdgeInsets.only(right: 10),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white24),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                CupertinoPageRoute(
                                  builder: (context) => TourSearchScreen(
                                    recentName: _recentSearches[index],
                                  ),
                                ),
                              );
                              _loadRecentSearches();
                            },
                            child: Text(
                              _recentSearches[index],
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: screenWidth * 0.035,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          GestureDetector(
                            onTap: () => _removeSearch(index),
                            child: const Icon(
                              Icons.close,
                              color: Colors.white70,
                              size: 16,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

            SizedBox(height: screenWidth * 0.04),

            // Subtitle Text
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25),
              child: Consumer<LocalizationController>(
                builder: (context, localizationController, child) {
                  String currentLang =
                      localizationController.locale.languageCode;
                  return Text(
                    currentLang == 'hi'
                        ? "तीर्थ यात्रा, मंदिर दर्शन और अधिक, नवीनतम जानकारी यहां देखें...!"
                        : "Check out the latest on pilgrimages, temple visits and more...!",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  );
                },
              ),
            ),

            SizedBox(height: screenWidth * 0.04),

            // Horizontal New Tours List
            if (_newToursList.isNotEmpty)
              Container(
                height: 210,
                padding: EdgeInsets.only(left: screenWidth * 0.03),
                child: ListView.builder(
                  itemCount: _newToursList.length,
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (context, index) {
                    final tour = _newToursList[index];
                    return InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          CupertinoPageRoute(
                            builder: (context) => TourDetails(
                              productId: tour.id.toString(),
                            ),
                          ),
                        );
                      },
                      child: Container(
                        width: 150,
                        margin: EdgeInsets.only(right: screenWidth * 0.025),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Stack(
                            children: [
                              CachedNetworkImage(
                                imageUrl: tour.image ?? '',
                                height: 230,
                                fit: BoxFit.cover,
                                placeholder: (context, url) =>
                                    placeholderImage(),
                                errorWidget: (context, url, error) =>
                                    const NoImageWidget(),
                              ),
                              Positioned.fill(
                                child: Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.bottomCenter,
                                      end: Alignment.topCenter,
                                      colors: [
                                        Colors.black.withOpacity(0.65),
                                        Colors.transparent,
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              Consumer<LocalizationController>(
                                builder:
                                    (context, localizationController, child) {
                                  String currentLang = localizationController
                                      .locale.languageCode;
                                  return Positioned(
                                    bottom: 12,
                                    left: 10,
                                    right: 10,
                                    child: Text(
                                      currentLang == 'hi'
                                          ? tour.hiTourName ?? ''
                                          : tour.enTourName ?? '',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                        fontSize: screenWidth * 0.04,
                                      ),
                                      textAlign: TextAlign.center,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ],
    );
  }
}

// class MainExpandContent extends StatefulWidget {
//   const MainExpandContent({super.key});
//
//   @override
//   State<MainExpandContent> createState() => _MainExpandContentState();
// }
//
// class _MainExpandContentState extends State<MainExpandContent> {
//   // late PageController _pageController;
//   // int _currentPage = 0;
//   // Timer? _timer;
//   //
//   // @override
//   // void initState() {
//   //   fetchToursImages();
//   //   _loadRecentSearches();
//   //   fetchNewTours();
//   //
//   //   _pageController = PageController(initialPage: 0);
//   //   _timer = Timer.periodic(
//   //     const Duration(milliseconds: 2000),
//   //     (timer) {
//   //       if (_currentPage < tourImagesList!.data.length - 1) {
//   //         _currentPage++;
//   //       } else {
//   //         _currentPage = 0;
//   //       }
//   //
//   //       if (_pageController.hasClients) {
//   //         _pageController.jumpToPage(
//   //           _currentPage,
//   //         );
//   //       }
//   //     },
//   //   );
//   //
//   //   super.initState();
//   // }
//   //
//   // final List<String> _defaultSearches = [
//   //   "Ujjain",
//   //   "Indore",
//   //   "Omkareshwar",
//   //   "Mahakaleshwar"
//   // ];
//   //
//   // // Recent Searches (Dynamic)
//   // List<String> _recentSearches = [];
//   //
//   // // List<String> _recentSearches = ["Ujjain","Indore","Omkareshwar","Mahakaleshwar"];
//   // List<NewToursData> _newToursList = [];
//   // TourImagesModel? tourImagesList;
//   //
//   // /// Fetch New Tour
//   // Future<void> fetchNewTours() async {
//   //   try {
//   //     const url = AppConstants.newTourDataUrl;
//   //     final res = await HttpService().getApi(url);
//   //
//   //     if (res != null) {
//   //       final newToursList = NewToursModel.fromJson(res);
//   //
//   //       setState(() {
//   //         _newToursList = newToursList.data ?? [];
//   //       });
//   //
//   //       print("${_newToursList.length}");
//   //     } else {
//   //       print("Response is null");
//   //       setState(() {
//   //         _newToursList = [];
//   //       });
//   //     }
//   //   } catch (e) {
//   //     print("fetching new tours $e");
//   //   }
//   // }
//   //
//   // Future<void> fetchToursImages() async{
//   //   try{
//   //     const url = AppConstants.tourImagesUrl;
//   //     final res = await HttpService().getApi(url);
//   //
//   //     if(res != null) {
//   //      final tourImages = TourImagesModel.fromJson(res);
//   //       setState(() {
//   //         tourImagesList = tourImages;
//   //       });
//   //
//   //      // _pageController = PageController(initialPage: 0);
//   //      // _timer = Timer.periodic(
//   //      //   const Duration(milliseconds: 2000),
//   //      //       (timer) {
//   //      //     if (_currentPage < tourImagesList!.data.length - 1) {
//   //      //       _currentPage++;
//   //      //     } else {
//   //      //       _currentPage = 0;
//   //      //     }
//   //      //
//   //      //     if (_pageController.hasClients) {
//   //      //       _pageController.jumpToPage(
//   //      //         _currentPage,
//   //      //       );
//   //      //     }
//   //      //   },
//   //      // );
//   //
//   //     }
//   //   } catch(e){
//   //     print("Error in Tour Images $e");
//   //   }
//   // }
//   //
//   // Future<void> _loadRecentSearches() async {
//   //   SharedPreferences prefs = await SharedPreferences.getInstance();
//   //   List<String>? savedSearches = prefs.getStringList('recentSearches');
//   //
//   //   setState(() {
//   //     // Merge default + saved searches without duplicates
//   //     _recentSearches = <dynamic>{..._defaultSearches, ...(savedSearches ?? [])}
//   //         .toList()
//   //         .cast<String>();
//   //   });
//   // }
//   //
//   // // Remove search item]
//   // Future<void> _removeSearch(int index) async {
//   //   SharedPreferences prefs = await SharedPreferences.getInstance();
//   //
//   //   setState(() {
//   //     _recentSearches.removeAt(index);
//   //   });
//   //
//   //   // Remove only user-added searches before saving
//   //   List<String> onlyUserSearches =
//   //   _recentSearches.where((item) => !_defaultSearches.contains(item)).toList();
//   //
//   //   await prefs.setStringList('recentSearches', onlyUserSearches);
//   // }
//   //
//   // @override
//   // void dispose() {
//   //   _timer?.cancel();
//   //   _pageController.dispose();
//   //   super.dispose();
//   // }
//
//   late PageController _pageController;
//   int _currentPage = 0;
//   Timer? _timer;
//
//   final List<String> _defaultSearches = [
//     "Ujjain",
//     "Indore",
//     "Omkareshwar",
//     "Mahakaleshwar"
//   ];
//
//   List<String> _recentSearches = [];
//   List<NewToursData> _newToursList = [];
//   TourImagesModel? tourImagesList;
//
//   @override
//   void initState() {
//     super.initState();
//
//     _pageController = PageController(initialPage: 0);
//
//     fetchToursImages().then((_) {
//       // Start timer only after images are loaded
//       if (tourImagesList != null && tourImagesList!.data.isNotEmpty) {
//         _timer = Timer.periodic(const Duration(seconds: 2), (timer) {
//           if (_currentPage < tourImagesList!.data.length - 1) {
//             _currentPage++;
//           } else {
//             _currentPage = 0;
//           }
//
//           if (_pageController.hasClients) {
//             _pageController.animateToPage(
//               _currentPage,
//               duration: const Duration(milliseconds: 500),
//               curve: Curves.easeInOut,
//             );
//           }
//         });
//       }
//     });
//
//     _loadRecentSearches();
//     fetchNewTours();
//   }
//
//   /// Fetch New Tours
//   Future<void> fetchNewTours() async {
//     try {
//       const url = AppConstants.newTourDataUrl;
//       final res = await HttpService().getApi(url);
//
//       if (res != null) {
//         final newToursList = NewToursModel.fromJson(res);
//         setState(() {
//           _newToursList = newToursList.data ?? [];
//         });
//       } else {
//         setState(() {
//           _newToursList = [];
//         });
//       }
//     } catch (e) {
//       print("Error fetching new tours: $e");
//     }
//   }
//
//   /// Fetch Tour Images
//   Future<void> fetchToursImages() async {
//     try {
//       const url = AppConstants.tourImagesUrl;
//       final res = await HttpService().getApi(url);
//
//       if (res != null) {
//         final tourImages = TourImagesModel.fromJson(res);
//         setState(() {
//           tourImagesList = tourImages;
//         });
//       }
//     } catch (e) {
//       print("Error fetching tour images: $e");
//     }
//   }
//
//   /// Load recent searches
//   Future<void> _loadRecentSearches() async {
//     final prefs = await SharedPreferences.getInstance();
//     final savedSearches = prefs.getStringList('recentSearches') ?? [];
//
//     setState(() {
//       // Merge default + saved searches without duplicates
//       _recentSearches = {..._defaultSearches, ...savedSearches}.toList();
//     });
//   }
//
//   /// Remove a search item
//   Future<void> _removeSearch(int index) async {
//     final prefs = await SharedPreferences.getInstance();
//
//     setState(() {
//       _recentSearches.removeAt(index);
//     });
//
//     final onlyUserSearches =
//     _recentSearches.where((item) => !_defaultSearches.contains(item)).toList();
//
//     await prefs.setStringList('recentSearches', onlyUserSearches);
//   }
//
//   @override
//   void dispose() {
//     _timer?.cancel();
//     _pageController.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     var screenWidth = MediaQuery.of(context).size.width;
//     var screenHeight = MediaQuery.of(context).size.height;
//
//     return Container(
//       child: Stack(children: [
//         // Background Slider
//         PageView.builder(
//           controller: _pageController,
//           itemCount: tourImagesList?.data.length,
//           itemBuilder: (context, index) {
//             return Image.network(
//               tourImagesList!.data[index],
//               fit: BoxFit.cover,
//               width: double.infinity,
//               height: double.infinity,
//             );
//           },
//         ),
//
//         Positioned.fill(
//           child: Container(
//             decoration: BoxDecoration(
//               gradient: LinearGradient(
//                 begin: Alignment.topCenter,
//                 end: Alignment.bottomCenter,
//                 colors: [
//                   Colors.black.withOpacity(0.3), // Top side color
//                   Colors.white.withOpacity(0.3), // Bottom side white gradient
//                 ],
//               ),
//             ),
//           ),
//         ),
//
//         Align(
//           alignment: Alignment.bottomCenter,
//           child: Container(
//             height: 150, // Adjust height as needed
//             decoration: BoxDecoration(
//               gradient: LinearGradient(
//                 begin: Alignment.bottomCenter,
//                 end: Alignment.topCenter,
//                 colors: [
//                   Colors.white.withOpacity(1), // Strong white at bottom
//                   Colors.white.withOpacity(1), // Strong white at bottom
//                   Colors.white.withOpacity(0.0), // Transparent at top
//                 ],
//               ),
//             ),
//           ),
//         ),
//         Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             SizedBox(height: screenWidth * 0.24),
//
//             /// App Bar with Back and Search
//             Padding(
//               padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
//               child: Row(
//                 children: [
//                   InkWell(
//                     onTap: () => Navigator.pop(context),
//                     child: const Icon(Icons.arrow_back_ios_new_rounded,
//                         color: Colors.white, size: 24),
//                   ),
//                   SizedBox(width: screenWidth * 0.02),
//                   Expanded(
//                     child: InkWell(
//                       onTap: () {
//                         Navigator.push(
//                           context,
//                           CupertinoPageRoute(
//                             builder: (context) =>
//                                 const TourSearchScreen(recentName: ''),
//                           ),
//                         );
//                         _loadRecentSearches();
//                       },
//                       child: Container(
//                         height: screenHeight * 0.05,
//                         decoration: BoxDecoration(
//                           color: Colors.white,
//                           borderRadius: BorderRadius.circular(20),
//                           border: Border.all(color: Colors.grey.shade300),
//                         ),
//                         padding: EdgeInsets.symmetric(
//                             horizontal: screenWidth * 0.03),
//                         child: Row(
//                           children: [
//                             const Icon(Icons.search, color: Colors.black54),
//                             const SizedBox(width: 8),
//                             Consumer<LocalizationController>(
//                               builder:
//                                   (context, localizationController, child) {
//                                 String currentLang =
//                                     localizationController.locale.languageCode;
//                                 return Text(
//                                   currentLang == 'hi'
//                                       ? 'स्थान खोजे'
//                                       : 'Search destinations',
//                                   style: TextStyle(
//                                     fontSize: screenWidth * 0.04,
//                                     color: CustomColors.clrggreytxt,
//                                   ),
//                                 );
//                               },
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             SizedBox(height: screenWidth * 0.04),
//
//             /// Recent Searches Horizontal Chips
//             Container(
//               height: 36,
//               padding: const EdgeInsets.only(left: 16),
//               child: ListView.builder(
//                 scrollDirection: Axis.horizontal,
//                 itemCount: _recentSearches.length,
//                 itemBuilder: (context, index) {
//                   return Container(
//                     margin: const EdgeInsets.only(right: 10),
//                     padding:
//                         const EdgeInsets.symmetric(horizontal: 14, vertical: 3),
//                     decoration: BoxDecoration(
//                       color: Colors.white24,
//                       borderRadius: BorderRadius.circular(20),
//                       border: Border.all(color: Colors.white24),
//                     ),
//                     child: Row(
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         // Search Name
//                         GestureDetector(
//                           onTap: () {
//                             Navigator.push(
//                               context,
//                               CupertinoPageRoute(
//                                 builder: (context) => TourSearchScreen(
//                                   recentName: _recentSearches[index],
//                                 ),
//                               ),
//                             );
//                             _loadRecentSearches();
//                           },
//                           child: Text(
//                             _recentSearches[index],
//                             style: TextStyle(
//                               color: Colors.white,
//                               fontSize: screenWidth * 0.035,
//                             ),
//                           ),
//                         ),
//                         const SizedBox(width: 6),
//
//                         // Cross Button to Remove Search
//                         GestureDetector(
//                           onTap: () => _removeSearch(index),
//                           child: const Icon(
//                             Icons.close,
//                             color: Colors.white70,
//                             size: 16,
//                           ),
//                         ),
//                       ],
//                     ),
//                   );
//                 },
//               ),
//             ),
//             SizedBox(height: screenWidth * 0.04),
//
//             /// Subtitle Text
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 25),
//               child: Consumer<LocalizationController>(
//                 builder: (context, localizationController, child) {
//                   String currentLang =
//                       localizationController.locale.languageCode;
//                   return Text(
//                     currentLang == 'hi'
//                         ? "तीर्थ यात्रा, मंदिर दर्शन और अधिक, नवीनतम जानकारी यहां देखें...!"
//                         : "Check out the latest on pilgrimages, temple visits and more...!",
//                     style: const TextStyle(
//                       fontSize: 18,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.white,
//                     ),
//                   );
//                 },
//               ),
//             ),
//             SizedBox(height: screenWidth * 0.04),
//
//             /// Horizontal New Tours List
//             Container(
//               height: 210,
//               padding: EdgeInsets.only(left: screenWidth * 0.03),
//               child: ListView.builder(
//                 itemCount: _newToursList.length,
//                 scrollDirection: Axis.horizontal,
//                 itemBuilder: (context, index) {
//                   return InkWell(
//                     onTap: () {
//                       Navigator.push(
//                         context,
//                         CupertinoPageRoute(
//                           builder: (context) => TourDetails(
//                             productId: _newToursList[index].id.toString(),
//                           ),
//                         ),
//                       );
//                     },
//                     child: Container(
//                       width: 150,
//                       margin: EdgeInsets.only(right: screenWidth * 0.025),
//                       decoration: BoxDecoration(
//                         borderRadius: BorderRadius.circular(16),
//                         boxShadow: [
//                           BoxShadow(
//                             color: Colors.black.withOpacity(0.2),
//                             blurRadius: 8,
//                             offset: const Offset(0, 4),
//                           ),
//                         ],
//                       ),
//                       child: ClipRRect(
//                         borderRadius: BorderRadius.circular(16),
//                         child: Stack(
//                           children: [
//                             /// Image with fallback
//                             CachedNetworkImage(
//                               imageUrl: _newToursList[index].image ?? '',
//                               height: 230,
//                               fit: BoxFit.cover,
//                               placeholder: (context, url) => placeholderImage(),
//                               errorWidget: (context, url, error) =>
//                                   const NoImageWidget(),
//                             ),
//
//                             /// Gradient overlay
//                             Positioned.fill(
//                               child: Container(
//                                 decoration: BoxDecoration(
//                                   gradient: LinearGradient(
//                                     begin: Alignment.bottomCenter,
//                                     end: Alignment.topCenter,
//                                     colors: [
//                                       Colors.black.withOpacity(0.65),
//                                       Colors.transparent,
//                                     ],
//                                   ),
//                                 ),
//                               ),
//                             ),
//
//                             /// Tour title
//                             Consumer<LocalizationController>(
//                               builder:
//                                   (context, localizationController, child) {
//                                 String currentLang =
//                                     localizationController.locale.languageCode;
//                                 return Positioned(
//                                   bottom: 12,
//                                   left: 10,
//                                   right: 10,
//                                   child: Text(
//                                     currentLang == 'hi'
//                                         ? _newToursList[index].hiTourName ?? ''
//                                         : _newToursList[index].enTourName ?? '',
//                                     style: TextStyle(
//                                       color: Colors.white,
//                                       fontWeight: FontWeight.w600,
//                                       fontSize: screenWidth * 0.04,
//                                     ),
//                                     textAlign: TextAlign.center,
//                                     maxLines: 2,
//                                     overflow: TextOverflow.ellipsis,
//                                   ),
//                                 );
//                               },
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                   );
//                 },
//               ),
//             ),
//           ],
//         ),
//       ]),
//     );
//   }
// }
