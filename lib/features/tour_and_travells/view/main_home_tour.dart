import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mahakal/features/more/screens/more_screen_view.dart';
import 'package:mahakal/features/self_drive/self_form_screen.dart';
import 'package:mahakal/features/tour_and_travells/model/new_tours_model.dart';
import 'package:mahakal/features/tour_and_travells/model/tour_category_model.dart';
import 'package:mahakal/features/tour_and_travells/ui_heliper/search_screen.dart';
import 'package:mahakal/features/tour_and_travells/view/TourDetails.dart';
import 'package:mahakal/features/tour_and_travells/view/tour_packages/statewise_tour.dart';
import 'package:mahakal/features/tour_and_travells/view/view_all_tours.dart';
import 'package:page_animation_transition/animations/bottom_to_top_transition.dart';
import 'package:page_animation_transition/page_animation_transition.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../common/basewidget/not_logged_in_bottom_sheet_widget.dart';
import '../../../data/datasource/remote/http/httpClient.dart';
import '../../../localization/controllers/localization_controller.dart';
import '../../../utill/app_constants.dart';
import '../../../utill/flutter_toast_helper.dart';
import '../../../utill/loading_datawidget.dart';
import '../../auth/controllers/auth_controller.dart';
import '../model/all_state_model.dart';
import '../model/tourimages_model.dart';

// ---------------------------------------------------------------------------
// DESIGN TOKENS — modern travel-app palette
// ---------------------------------------------------------------------------
class _Palette {
  static const Color primary = Color(0xFF2563EB);   // vivid blue
  static const Color primaryDark = Color(0xFF1D4ED8);
  static const Color accent = Color(0xFFFF7A45);    // warm coral accent
  static const Color bgTop = Color(0xFFF4F7FF);
  static const Color bgBottom = Color(0xFFFFFFFF);
  static const Color textDark = Color(0xFF11182B);
  static const Color textMuted = Color(0xFF6B7280);
  static const Color cardShadow = Color(0x1A1F3B73);
  static const Color shimmerBase = Color(0xFFE9EDF5);
  static const Color shimmerHighlight = Color(0xFFF6F8FC);
}

class TourHomePage extends StatefulWidget {
  final ScrollController scrollController;
  const TourHomePage({super.key, required this.scrollController});

  @override
  _TourHomePageState createState() => _TourHomePageState();
}

class _TourHomePageState extends State<TourHomePage>
    with SingleTickerProviderStateMixin {
  late PageController _bannerPageController;
  Timer? _bannerTimer;

  // State variables
  bool isAnimatedOpacityVisible = false;
  bool isLoading = false;
  int _currentBannerPage = 0;

  // Section-level loading flags power the shimmer skeletons.
  bool _bannerLoading = true;
  bool _toursLoading = true;

  List<TourTabs> tourTabs = [];
  List<TourAllState> stateNames = [];
  List<String> _recentSearches = [];
  List<NewToursData> _newToursList = [];
  TourImagesModel? tourImagesList;

  final List<String> _defaultSearches = [
    "Ujjain",
    "Indore",
    "Omkareshwar",
    "Mahakaleshwar"
  ];

  @override
  void initState() {
    super.initState();
    _bannerPageController = PageController(initialPage: 0, viewportFraction: 0.92);
    _loadEverything();
    widget.scrollController.addListener(_onScroll);
  }

  Future<void> _loadEverything() async {
    await Future.wait([
      getTourTabs(),
      getAllState(),
      _loadRecentSearches(),
      fetchNewTours(),
      fetchToursImages(),
    ]);
  }

  void _onScroll() {
    if (!mounted) return;
    setState(() {
      isAnimatedOpacityVisible = widget.scrollController.offset > 300;
    });
  }

  Future<void> _loadRecentSearches() async {
    final prefs = await SharedPreferences.getInstance();
    final savedSearches = prefs.getStringList('recentSearches') ?? [];
    if (!mounted) return;
    setState(() {
      _recentSearches = {..._defaultSearches, ...savedSearches}.toList();
    });
  }

  Future<void> fetchNewTours() async {
    setState(() => _toursLoading = true);
    try {
      const url = AppConstants.newTourDataUrl;
      final res = await HttpService().getApi(url);
      if (res != null) {
        final newToursList = NewToursModel.fromJson(res);
        if (!mounted) return;
        setState(() {
          _newToursList = newToursList.data ?? [];
        });
      }
    } catch (e) {
      debugPrint("Error fetching new tours: $e");
    } finally {
      if (mounted) setState(() => _toursLoading = false);
    }
  }

  Future<void> fetchToursImages() async {
    setState(() => _bannerLoading = true);
    try {
      const url = AppConstants.tourImagesUrl;
      final res = await HttpService().getApi(url);
      if (res != null) {
        final tourImages = TourImagesModel.fromJson(res);
        if (!mounted) return;
        setState(() {
          tourImagesList = tourImages;
          _startBannerTimer();
        });
      }
    } catch (e) {
      debugPrint("Error fetching tour images: $e");
    } finally {
      if (mounted) setState(() => _bannerLoading = false);
    }
  }

  void _startBannerTimer() {
    _bannerTimer?.cancel();
    if (tourImagesList != null && tourImagesList!.data.isNotEmpty) {
      _bannerTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
        if (_currentBannerPage < (tourImagesList?.data.length ?? 1) - 1) {
          _currentBannerPage++;
        } else {
          _currentBannerPage = 0;
        }

        if (_bannerPageController.hasClients) {
          _bannerPageController.animateToPage(
            _currentBannerPage,
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeInOut,
          );
        }
      });
    }
  }

  Future<void> getTourTabs() async {
    setState(() => isLoading = true);
    try {
      const url = AppConstants.tourCategoryUrl;
      final res = await HttpService().getApi(url);
      if (res != null) {
        final category = TourCategoryModel.fromJson(res);
        if (!mounted) return;
        setState(() {
          tourTabs = category.data;
        });
      }
    } catch (e) {
      debugPrint("Error in fetching tour tabs: $e");
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  void dispose() {
    _bannerPageController.dispose();
    _bannerTimer?.cancel();
    super.dispose();
  }

  /// Get All State
  Future<void> getAllState() async {
    try {
      final res = await HttpService().getApi(AppConstants.tourAllStateUrl);
      if (res != null) {
        final stateRes = TourAllStateModel.fromJson(res);
        if (!mounted) return;
        setState(() {
          stateNames = stateRes.data;
        });
      }
    } catch (e) {
      debugPrint("Tour All State Error: $e");
    }
  }

  // ---------------------------------------------------------------------
  // GREETING — time-of-day aware
  // ---------------------------------------------------------------------
  String _greetingText() {
    final hour = DateTime.now().hour;
    if (hour < 12) return "Good Morning";
    if (hour < 17) return "Good Afternoon";
    return "Good Evening";
  }

  String _greetingEmoji() {
    final hour = DateTime.now().hour;
    if (hour < 12) return "☀️";
    if (hour < 17) return "🌤️";
    return "🌙";
  }

  void _showStateBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      isScrollControlled: true,
      builder: (_) => DraggableScrollableSheet(
        expand: false,
        maxChildSize: 0.9,
        initialChildSize: 0.72,
        builder: (context, scrollController) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16),
          child: Column(
            children: [
              Container(
                height: 5,
                width: 44,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: _Palette.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(Icons.public_rounded, color: _Palette.primary),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    "All States of India",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: _Palette.textDark,
                      letterSpacing: -0.3,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Expanded(
                child: stateNames.isEmpty
                    ? const _EmptyState(
                  icon: Icons.map_outlined,
                  title: "No states found",
                  subtitle: "Please check your connection and try again.",
                )
                    : GridView.builder(
                  controller: scrollController,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    crossAxisSpacing: 14,
                    mainAxisSpacing: 18,
                    childAspectRatio: 0.78,
                  ),
                  itemCount: stateNames.length,
                  itemBuilder: (context, index) {
                    final state = stateNames[index];
                    return InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () {
                        Navigator.pop(context);
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
                          Container(
                            width: 58,
                            height: 58,
                            padding: const EdgeInsets.all(3),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: const LinearGradient(
                                colors: [_Palette.primary, Color(0xFF60A5FA)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: _Palette.primary.withOpacity(0.28),
                                  blurRadius: 12,
                                  offset: const Offset(0, 6),
                                )
                              ],
                            ),
                            child: ClipOval(
                              child: Container(
                                color: Colors.white,
                                child: CachedNetworkImage(
                                  imageUrl: state.logo,
                                  fit: BoxFit.cover,
                                  placeholder: (c, u) => placeholderImage(),
                                  errorWidget: (c, u, e) => const NoImageWidget(),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            state.name,
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w600,
                              color: _Palette.textDark,
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
    return isLoading
        ? MahakalLoadingData(onReload: () => getTourTabs())
        : Scaffold(
      backgroundColor: _Palette.bgTop,
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () => _showStateBottomSheet(context),
      //   backgroundColor: _Palette.primary,
      //   elevation: 4,
      //   shape: RoundedRectangleBorder(
      //     borderRadius: BorderRadius.circular(18),
      //   ),
      //   child: const Icon(Icons.map_rounded, color: Colors.white),
      // ),
      body: RefreshIndicator(
        color: _Palette.primary,
        onRefresh: _loadEverything,
        child: NestedScrollView(
          controller: widget.scrollController,
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              SliverToBoxAdapter(
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [_Palette.bgTop, _Palette.bgBottom],
                    ),
                  ),
                  padding: EdgeInsets.only(
                    top: MediaQuery.of(context).padding.top + 6,
                    bottom: 10,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(),
                      _buildSearchBar(),
                      if (_recentSearches.isNotEmpty) _buildRecentSearches(),
                      _buildCategoriesGrid(),
                      _buildTrendingSection(),
                    ],
                  ),
                ),
              ),
            ];
          },
          body: StateWiseTour(stateSlug: ""),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------
  // HEADER — time-aware greeting + notification bell
  // ---------------------------------------------------------------------
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(_greetingEmoji(), style: const TextStyle(fontSize: 15)),
                  const SizedBox(width: 6),
                  Text(
                    "${_greetingText()}, Traveler!",
                    style: TextStyle(
                      fontSize: 13.5,
                      color: _Palette.textMuted,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.1,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  colors: [_Palette.textDark, _Palette.primaryDark],
                ).createShader(bounds),
                child: const Text(
                  "Where to next?",
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: -0.5,
                  ),
                ),
              ),
            ],
          ),
          Row(
            children: [
              InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    CupertinoPageRoute(
                      builder: (context) => MoreScreen(scrollController: ScrollController()),
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(11),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: _Palette.cardShadow,
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.menu_rounded, color: _Palette.primary, size: 22),
                ),
              ),
              const SizedBox(width: 10),
              InkWell(
                onTap: () => _showStateBottomSheet(context),
                child: Container(
                  padding: const EdgeInsets.all(11),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: _Palette.cardShadow,
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      const Icon(Icons.location_city_rounded, color: _Palette.primary, size: 22),
                      Positioned(
                        top: -2,
                        right: -2,
                        child: Container(
                          width: 9,
                          height: 9,
                          decoration: const BoxDecoration(
                            color: _Palette.accent,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------
  // SEARCH BAR — soft elevated pill
  // ---------------------------------------------------------------------
  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () {
          Navigator.push(
            context,
            CupertinoPageRoute(
              builder: (context) => const TourSearchScreen(recentName: ''),
            ),
          ).then((_) => _loadRecentSearches());
        },
        child: Container(
          height: 56,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: _Palette.cardShadow,
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: _Palette.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.search_rounded, color: _Palette.primary, size: 19),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Consumer<LocalizationController>(
                  builder: (context, loc, child) {
                    return Text(
                      loc.locale.languageCode == 'hi'
                          ? 'अपनी अगली यात्रा खोजें...'
                          : 'Search your next trip...',
                      style: TextStyle(
                        color: _Palette.textMuted,
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    );
                  },
                ),
              ),
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: _Palette.accent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.tune_rounded, color: _Palette.accent, size: 18),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------
  // RECENT SEARCHES — pill chips
  // ---------------------------------------------------------------------
  Widget _buildRecentSearches() {
    return Container(
      height: 38,
      // margin: const EdgeInsets.only(bottom: 6),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: _recentSearches.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () {
                Navigator.push(
                  context,
                  CupertinoPageRoute(
                    builder: (context) => TourSearchScreen(recentName: _recentSearches[index]),
                  ),
                ).then((_) => _loadRecentSearches());
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: _Palette.primary.withOpacity(0.14)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.history_rounded, size: 13, color: _Palette.primary),
                    const SizedBox(width: 5),
                    Text(
                      _recentSearches[index],
                      style: const TextStyle(
                        fontSize: 12.5,
                        color: _Palette.textDark,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ---------------------------------------------------------------------
  // CATEGORIES — soft rounded tiles with icon badges
  // ---------------------------------------------------------------------
  Widget _buildCategoriesGrid() {
    if (tourTabs.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 26, 20, 14),
          child: Text(
            "Explore Categories",
            style: TextStyle( 
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: _Palette.textDark,
              letterSpacing: -0.2,
            ),
          ),
        ),
        SizedBox(
          height: 104,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 15),
            itemCount: tourTabs.length,
            itemBuilder: (context, index) {
              final cat = tourTabs[index];
              return InkWell(
                borderRadius: BorderRadius.circular(18),
                onTap: () {
                  Navigator.push(
                    context,
                    CupertinoPageRoute(
                      builder: (context) => ViewAllTours(
                        stateName: "", // Filter by category only across all states
                        tourSlug: cat.slug,
                        title: cat.enName,
                      ),
                    ),
                  );
                },
                child: Container(
                  width: 82,
                  margin: const EdgeInsets.symmetric(horizontal: 6),
                  child: Column(
                    children: [
                      Container(
                          width: 62,
                        height: 62,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              _Palette.primary.withOpacity(0.10),
                              _Palette.accent.withOpacity(0.10),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Icon(
                          _getCategoryIcon(cat.enName),
                          color: _Palette.primary,
                          size: 26,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Consumer<LocalizationController>(
                        builder: (context, loc, child) {
                          return Text(
                            loc.locale.languageCode == 'hi' ? cat.hiName ?? "" : cat.enName ?? "",
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: _Palette.textDark,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  IconData _getCategoryIcon(String? name) {
    if (name == null) return Icons.explore_rounded;
    name = name.toLowerCase();
    if (name.contains('temple') || name.contains('spiritual')) return Icons.temple_hindu_rounded;
    if (name.contains('nature')) return Icons.nature_people_rounded;
    if (name.contains('adventure')) return Icons.directions_bike_rounded;
    if (name.contains('beach')) return Icons.beach_access_rounded;
    return Icons.explore_rounded;
  }

  // ---------------------------------------------------------------------
  // TRENDING PACKAGES — polished cards with price-style badge
  // ---------------------------------------------------------------------
  Widget _buildTrendingSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 14),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Trending Packages",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: _Palette.textDark,
                  letterSpacing: -0.2,
                ),
              ),
              if (!_toursLoading && _newToursList.isNotEmpty)
                InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () {
                    Navigator.push(context, CupertinoPageRoute(builder: (context) => const ViewAllTours(stateName: "", tourSlug: "")));
                  },
                  child: Row(
                    children: const [
                      Text(
                        "See All",
                        style: TextStyle(
                          color: _Palette.primary,
                          fontWeight: FontWeight.w700,
                          fontSize: 13.5,
                        ),
                      ),
                      Icon(Icons.arrow_forward_ios_rounded, size: 12, color: _Palette.primary),
                    ],
                  ),
                ),
            ],
          ),
        ),
        SizedBox(
          height: 240,
          child: _toursLoading
              ? ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 15),
            itemCount: 3,
            itemBuilder: (context, index) => const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: _ShimmerCard(width: 205),
            ),
          )
              : _newToursList.isEmpty
              ? const _EmptyState(
            icon: Icons.card_travel_outlined,
            title: "No packages yet",
            subtitle: "New tour packages will show up here soon.",
            compact: true,
          )
              : ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            itemCount: _newToursList.length,
            itemBuilder: (context, index) {
              final tour = _newToursList[index];
              return InkWell(
                borderRadius: BorderRadius.circular(18),
                onTap: () {
                  Navigator.push(
                    context,
                    CupertinoPageRoute(
                      builder: (context) => TourDetails(productId: tour.id.toString()),
                    ),
                  );
                },
                child: Container(
                  width: 205,
                  margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: Colors.grey.shade200),
                    // boxShadow: [
                    //   BoxShadow(
                    //     color: _Palette.cardShadow,
                    //     blurRadius: 16,
                    //     offset: const Offset(0, 8),
                    //   ),
                    // ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Stack(
                        children: [
                          ClipRRect(
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
                            child: CachedNetworkImage(
                              imageUrl: tour.image ?? '',
                              height: 128,
                              width: 205,
                              fit: BoxFit.cover,
                              placeholder: (c, u) => Container(color: Colors.grey.shade200),
                              errorWidget: (c, u, e) => const NoImageWidget(),
                            ),
                          ),
                          Positioned(
                            top: 10,
                            left: 10,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                              decoration: BoxDecoration(
                                color: _Palette.accent,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.local_fire_department_rounded, size: 12, color: Colors.white),
                                  SizedBox(width: 3),
                                  Text(
                                    "Trending",
                                    style: TextStyle(
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Positioned(
                            top: 10,
                            right: 10,
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.92),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.favorite_border_rounded, size: 15, color: _Palette.primary),
                            ),
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Consumer<LocalizationController>(
                              builder: (context, loc, child) {
                                return Text(
                                  loc.locale.languageCode == 'hi' ? tour.hiTourName ?? '' : tour.enTourName ?? '',
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 14.5,
                                    color: _Palette.textDark,
                                  ),
                                );
                              },
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(Icons.location_on_rounded, size: 14, color: _Palette.primary),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    "Premium Experience",
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(fontSize: 12, color: _Palette.textMuted, fontWeight: FontWeight.w500),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Small reusable data holder for quick action items.
// ---------------------------------------------------------------------------
class _QuickAction {
  final IconData icon;
  final String label;
  final Color color;
  const _QuickAction({required this.icon, required this.label, required this.color});
}

// ---------------------------------------------------------------------------
// SHIMMER — lightweight skeleton loader (no external package required)
// ---------------------------------------------------------------------------
class _ShimmerBox extends StatefulWidget {
  final double height;
  final double? width;
  final double borderRadius;
  const _ShimmerBox({required this.height, this.width, this.borderRadius = 16});

  @override
  State<_ShimmerBox> createState() => _ShimmerBoxState();
}

class _ShimmerBoxState extends State<_ShimmerBox> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          height: widget.height,
          width: widget.width ?? double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            gradient: LinearGradient(
              begin: Alignment(-1 + _controller.value * 3, 0),
              end: Alignment(0 + _controller.value * 3, 0),
              colors: const [
                _Palette.shimmerBase,
                _Palette.shimmerHighlight,
                _Palette.shimmerBase,
              ],
              stops: const [0.35, 0.5, 0.65],
            ),
          ),
        );
      },
    );
  }
}

/// A shimmer version of the trending-package card, used while data loads.
class _ShimmerCard extends StatelessWidget {
  final double width;
  const _ShimmerCard({required this.width});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: _Palette.cardShadow,
            blurRadius: 10,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _ShimmerBox(height: 128, borderRadius: 0),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _ShimmerBox(height: 14, width: width * 0.6, borderRadius: 6),
                const SizedBox(height: 10),
                _ShimmerBox(height: 11, width: width * 0.4, borderRadius: 6),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// EMPTY STATE — friendly placeholder for empty/failed sections
// ---------------------------------------------------------------------------
class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool compact;
  const _EmptyState({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: compact ? 12 : 24, horizontal: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: _Palette.primary.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: compact ? 26 : 34, color: _Palette.primary),
            ),
            const SizedBox(height: 10),
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 14,
                color: _Palette.textDark,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12, color: _Palette.textMuted),
            ),
          ],
        ),
      ),
    );
  }
}
