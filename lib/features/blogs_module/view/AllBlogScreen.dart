import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mahakal/utill/app_constants.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../data/datasource/remote/http/httpClient.dart';
import '../../product/enums/product_type.dart';
import '../../product/screens/view_all_product_screen.dart';
import '../../product/widgets/featured_product_widget.dart';
import '../Controller/Bookmark Provider.dart';
import '../Controller/ShareScreen.dart';
import '../Controller/language_provider.dart';
import '../model/SubCategory_model.dart';
import '../no_image_widget.dart';
import 'BlogDetailsPage.dart';
import 'BlogBookmarkScreen.dart';
import 'ViewAllBlogScreen.dart';

class AllBlogScreen extends StatefulWidget {
  const AllBlogScreen({super.key});

  @override
  State<AllBlogScreen> createState() => _AllBlogScreentate();
}

class _AllBlogScreentate extends State<AllBlogScreen> {
  // late CarouselController _carouselController;

  bool _isLoading = false;
  bool showAll = false;
  int _currentIndex = 0;

  final BlogSaveProvider blogSaveProvider = BlogSaveProvider();
  final shareMusic = ShareBlogs();

  List<int> bookmarkedIds = [];

  late BlogLanguageProvider languageProvider;

  @override
  void initState() {
    super.initState();
    languageProvider =
        Provider.of<BlogLanguageProvider>(context, listen: false);

    // Call once initially
    _loadBlogData();
    // Add listener to detect changes
    languageProvider.addListener(() {
      _loadBlogData();
    });
  }

  @override
  void dispose() {
    languageProvider.removeListener(() {
      _loadBlogData();
    });
    super.dispose();
  }

  void _nextPage() {
    print("Clicked next");
    // _carouselController.nextPage();
  }

  void _prevPage() {
    print("Clicked previous");
    // _carouselController.previousPage();
  }

  String formatDate(DateTime? date) {
    if (date == null) return 'Unknown';
    return DateFormat("dd-MMM-yyyy").format(date);
  }

  /// Get Blogs SubCategory
  List<BlogSubCategoryData> subCategoryList = [];
  List<BlogSubCategoryData> latestBlogs = [];
  List<BlogSubCategoryData> reversedBlogs = [];

  Future<void> _loadBlogData() async {
    setState(() => _isLoading = true);
    try {
      final languageProvider =
          Provider.of<BlogLanguageProvider>(context, listen: false);
      final url =
          "${AppConstants.blogsSubCategoryUrl}${languageProvider.isEnglish ? 1 : 2}";

      final response = await HttpService().getApi(url);
      print("API Response: $response");

      if ((response['status'] == 200 || response['status'] == true) &&
          response['data'] != null) {
        final categoryData = BlogSubCategoryModel.fromJson(response);
        setState(() {
          subCategoryList = categoryData.data;
          latestBlogs = categoryData.data;
          reversedBlogs = latestBlogs.reversed.take(10).toList();
          print("✅ Blogs loaded: ${latestBlogs.length}");
        });
      } else {
        print("❌ Invalid API structure or status");
      }
    } catch (error) {
      debugPrint("❌ Error fetching blogs: $error");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    var screenHeight = MediaQuery.of(context).size.height;
    var screenWidth = MediaQuery.of(context).size.width;

    return Consumer<BlogLanguageProvider>(
      builder: (BuildContext context, languageProvider, Widget? child) {
        return Scaffold(
            body: _isLoading // Show loading indicator if loading
                ? const Center(
                    child: CircularProgressIndicator(color: Colors.orange))
                : RefreshIndicator(
                    onRefresh: () async {
                      await _loadBlogData();
                    },
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: EdgeInsets.only(top: screenHeight * 0.01),
                        child: Column(
                          children: [
                            Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: screenWidth * 0.02),
                              child: Column(
                                children: [
                                  /// Slider
                                  CarouselSlider(
                                    // carouselController: _carouselController,
                                    options: CarouselOptions(
                                      viewportFraction: 1,
                                      height: 220.0,
                                      enableInfiniteScroll: true,
                                      autoPlay: true,
                                      autoPlayAnimationDuration:
                                          const Duration(milliseconds: 200),
                                      onPageChanged: (index, reason) {
                                        setState(() {
                                          _currentIndex = index;
                                        });
                                      },
                                    ),
                                    items: subCategoryList.map((category) {
                                      return Builder(
                                        builder: (BuildContext context) {
                                          return Container(
                                            width: double.infinity,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              color: Colors.grey.shade400,
                                              image: DecorationImage(
                                                image:
                                                    CachedNetworkImageProvider(
                                                        category.imageSlider ??
                                                            ''),
                                                fit: BoxFit.fill,
                                              ),
                                            ),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          top: 16.0),
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      IconButton(
                                                        icon: const Icon(
                                                            Icons
                                                                .arrow_back_ios,
                                                            color:
                                                                Colors.white),
                                                        onPressed: _prevPage,
                                                      ),
                                                      Center(
                                                        child: GestureDetector(
                                                          onTap: () {
                                                            Navigator.push(
                                                              context,
                                                              CupertinoPageRoute(
                                                                builder:
                                                                    (context) =>
                                                                        BlogDetailsPage(
                                                                  remainingItems:
                                                                      subCategoryList,
                                                                  title: category
                                                                      .titleSlug,
                                                                ),
                                                              ),
                                                            );
                                                          },
                                                          child: Container(
                                                            decoration:
                                                                BoxDecoration(
                                                              color: const Color
                                                                  .fromRGBO(255,
                                                                  118, 10, 1),
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          5),
                                                            ),
                                                            child: Center(
                                                              child: Padding(
                                                                padding: EdgeInsets.symmetric(
                                                                    horizontal:
                                                                        screenWidth *
                                                                            0.03,
                                                                    vertical:
                                                                        screenWidth *
                                                                            0.02),
                                                                child: Text(
                                                                  languageProvider
                                                                          .isEnglish
                                                                      ? "Vrat Katha"
                                                                      : "व्रत कथा",
                                                                  style: const TextStyle(
                                                                      color: Colors
                                                                          .white,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold),
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      IconButton(
                                                        icon: const Icon(
                                                            Icons
                                                                .arrow_forward_ios,
                                                            color:
                                                                Colors.white),
                                                        onPressed: _nextPage,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                Center(
                                                  child: Text(
                                                    category.title,
                                                    textAlign: TextAlign.center,
                                                    style: const TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          );
                                        },
                                      );
                                    }).toList(),
                                  ),
                                  SizedBox(
                                    height: screenHeight * 0.02,
                                  ),

                                  /// latest Post
                                  Container(
                                      width: double.infinity,
                                      height: screenHeight * 0.05,
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(5),
                                          color: const Color.fromRGBO(
                                              255, 238, 238, 1)),
                                      child: Padding(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: screenWidth * 0.02),
                                        child: Consumer<BlogLanguageProvider>(
                                          builder: (BuildContext context,
                                              languageProvider, Widget? child) {
                                            return Row(
                                              children: [
                                                Container(
                                                  height: screenHeight * 0.03,
                                                  width: screenWidth * 0.01,
                                                  decoration:
                                                      const BoxDecoration(
                                                          color: Color.fromRGBO(
                                                              255, 90, 0, 1)),
                                                ),
                                                SizedBox(
                                                  width: screenWidth * 0.02,
                                                ),
                                                Text(
                                                  languageProvider.isEnglish
                                                      ? "Latest Post"
                                                      : "नवीनतम पोस्ट",
                                                  style: TextStyle(
                                                      color: Colors.black,
                                                      fontWeight:
                                                          FontWeight.w700,
                                                      fontSize:
                                                          screenWidth * 0.04),
                                                ),
                                                const Spacer(),
                                                GestureDetector(
                                                  onTap: () {
                                                    Navigator.push(
                                                        context,
                                                        CupertinoPageRoute(
                                                          builder: (context) =>
                                                              ViewAllBlogScreen(
                                                            subCategoryData:
                                                                reversedBlogs,
                                                          ),
                                                        ));
                                                  },
                                                  child: Text(
                                                    languageProvider.isEnglish
                                                        ? "View All"
                                                        : "सभी को देखें",
                                                    style: const TextStyle(
                                                        color: Color.fromRGBO(
                                                            255, 139, 33, 1),
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                )
                                              ],
                                            );
                                          },
                                        ),
                                      )),
                                  SizedBox(
                                    height: screenHeight * 0.02,
                                  ),
                                  SizedBox(
                                    height: screenHeight * 0.38,
                                    child: ListView.builder(
                                        padding: EdgeInsets.zero,
                                        physics: const BouncingScrollPhysics(),
                                        scrollDirection: Axis.horizontal,
                                        itemCount: reversedBlogs.length,
                                        itemBuilder: (context, index) {
                                          final item = reversedBlogs[index];
                                          return blogCardWidget(
                                            context: context,
                                            subCategoryItem: item,
                                            screenWidth: screenWidth,
                                            screenHeight: screenHeight,
                                            subCategoryList: subCategoryList,
                                            isEnglish:
                                                languageProvider.isEnglish,
                                          );
                                        }),
                                  ),
                                  SizedBox(
                                    height: screenHeight * 0.02,
                                  ),

                                  /// Populer Post
                                  Container(
                                      width: double.infinity,
                                      height: screenHeight * 0.05,
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(5),
                                          color: const Color.fromRGBO(
                                              255, 238, 238, 1)),
                                      child: Padding(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: screenWidth * 0.02),
                                        child: Consumer<BlogLanguageProvider>(
                                          builder: (BuildContext context,
                                              languageProvider, Widget? child) {
                                            return Row(
                                              children: [
                                                Container(
                                                  height: screenHeight * 0.03,
                                                  width: screenWidth * 0.01,
                                                  decoration:
                                                      const BoxDecoration(
                                                          color: Color.fromRGBO(
                                                              255, 90, 0, 1)),
                                                ),
                                                SizedBox(
                                                  width: screenWidth * 0.02,
                                                ),
                                                Text(
                                                  languageProvider.isEnglish
                                                      ? "Popular Post"
                                                      : "लोकप्रिय पोस्ट",
                                                  style: TextStyle(
                                                      color: Colors.black,
                                                      fontWeight:
                                                          FontWeight.w700,
                                                      fontSize:
                                                          screenWidth * 0.04),
                                                ),
                                                const Spacer(),
                                                GestureDetector(
                                                  onTap: () {
                                                    Navigator.push(
                                                        context,
                                                        CupertinoPageRoute(
                                                          builder: (context) =>
                                                              ViewAllBlogScreen(
                                                            subCategoryData:
                                                                subCategoryList,
                                                          ),
                                                        ));
                                                  },
                                                  child: Text(
                                                    languageProvider.isEnglish
                                                        ? "View All"
                                                        : "सभी को देखें",
                                                    style: const TextStyle(
                                                        color: Color.fromRGBO(
                                                            255, 139, 33, 1),
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                )
                                              ],
                                            );
                                          },
                                        ),
                                      )),
                                  SizedBox(
                                    height: screenHeight * 0.02,
                                  ),
                                  SizedBox(
                                    height: screenHeight * 0.38,
                                    child: ListView.builder(
                                        padding: EdgeInsets.zero,
                                        physics: const BouncingScrollPhysics(),
                                        scrollDirection: Axis.horizontal,
                                        itemCount: subCategoryList.length > 10
                                            ? 10
                                            : subCategoryList.length,
                                        itemBuilder: (context, index) {
                                          final item = subCategoryList[index];
                                          return blogCardWidget(
                                            context: context,
                                            subCategoryItem: item,
                                            screenWidth: screenWidth,
                                            screenHeight: screenHeight,
                                            subCategoryList: subCategoryList,
                                            isEnglish:
                                                languageProvider.isEnglish,
                                          );
                                        }),
                                  ),
                                  SizedBox(
                                    height: screenHeight * 0.02,
                                  ),

                                  /// Trending Post
                                  Container(
                                      width: double.infinity,
                                      height: screenHeight * 0.05,
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(5),
                                          color: const Color.fromRGBO(
                                              255, 238, 238, 1)),
                                      child: Padding(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: screenWidth * 0.02),
                                        child: Row(
                                          children: [
                                            Container(
                                              height: screenHeight * 0.03,
                                              width: screenWidth * 0.01,
                                              decoration: const BoxDecoration(
                                                  color: Color.fromRGBO(
                                                      255, 90, 0, 1)),
                                            ),
                                            SizedBox(
                                              width: screenWidth * 0.02,
                                            ),
                                            Text(
                                              languageProvider.isEnglish
                                                  ? "Trending"
                                                  : "ट्रेंडिंग",
                                              style: TextStyle(
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.w700,
                                                  fontSize: screenWidth * 0.04),
                                            ),
                                            const Spacer(),
                                            GestureDetector(
                                              onTap: () {
                                                final subCategoryItem =
                                                    subCategoryList[
                                                        _currentIndex];

                                                Navigator.push(
                                                    context,
                                                    CupertinoPageRoute(
                                                      builder: (context) =>
                                                          ViewAllBlogScreen(
                                                        subCategoryData:
                                                            subCategoryList,
                                                      ),
                                                    ));
                                              },
                                              child: Text(
                                                languageProvider.isEnglish
                                                    ? "View All"
                                                    : "सभी को देखें",
                                                style: const TextStyle(
                                                    color: Color.fromRGBO(
                                                        255, 139, 33, 1),
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            )
                                          ],
                                        ),
                                      )),
                                  SizedBox(
                                    height: screenHeight * 0.02,
                                  ),
                                  SizedBox(
                                    height: screenHeight * 0.38,
                                    child: ListView.builder(
                                        padding: EdgeInsets.zero,
                                        physics: const BouncingScrollPhysics(),
                                        scrollDirection: Axis.horizontal,
                                        itemCount: subCategoryList.length > 10
                                            ? subCategoryList.length - 10
                                            : 0,
                                        itemBuilder: (context, index) {
                                          final subCategoryItem =
                                              subCategoryList[index + 10];
                                          return blogCardWidget(
                                            context: context,
                                            subCategoryItem: subCategoryItem,
                                            screenWidth: screenWidth,
                                            screenHeight: screenHeight,
                                            subCategoryList: subCategoryList,
                                            isEnglish:
                                                languageProvider.isEnglish,
                                          );
                                        }),
                                  ),
                                  SizedBox(
                                    height: screenHeight * 0.02,
                                  ),

                                  /// Add Banner
                                  Container(
                                      width: double.infinity,
                                      height: screenHeight * 0.05,
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(5),
                                          color: const Color.fromRGBO(
                                              255, 238, 238, 1)),
                                      child: Padding(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: screenWidth * 0.02),
                                        child: Row(
                                          children: [
                                            Container(
                                              height: screenHeight * 0.03,
                                              width: screenWidth * 0.01,
                                              decoration: const BoxDecoration(
                                                  color: Color.fromRGBO(
                                                      255, 90, 0, 1)),
                                            ),
                                            SizedBox(
                                              width: screenWidth * 0.02,
                                            ),
                                            Text(
                                              languageProvider.isEnglish
                                                  ? "Featured Products"
                                                  : "विशेष रुप से प्रदर्शित प्रोडक्टस",
                                              style: TextStyle(
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.w700,
                                                  fontSize: screenWidth * 0.04),
                                            ),
                                            const Spacer(),
                                            GestureDetector(
                                              onTap: () {
                                                // final subCategoryItem = subCategoryList[_currentIndex];
                                                Navigator.push(
                                                    context,
                                                    CupertinoPageRoute(
                                                        builder: (_) =>
                                                            AllProductScreen(
                                                                productType:
                                                                    ProductType
                                                                        .featuredProduct)));
                                              },
                                              child: Text(
                                                languageProvider.isEnglish
                                                    ? "View All"
                                                    : "सभी को देखें",
                                                style: const TextStyle(
                                                    color: Color.fromRGBO(
                                                        255, 139, 33, 1),
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            )
                                          ],
                                        ),
                                      )),
                                  SizedBox(
                                    height: screenHeight * 0.02,
                                  ),
                                  const FeaturedProductWidget(
                                    isHome: true,
                                  ),

                                  // Container(
                                  //   height: screenHeight * 0.3,
                                  //   width: double.infinity,
                                  //   decoration: BoxDecoration(
                                  //     color: const Color.fromRGBO(
                                  //         209, 209, 209, 1),
                                  //     borderRadius: BorderRadius.circular(10),
                                  //   ),
                                  //   child: Center(
                                  //       child: Text(
                                  //     'Add banner e commerce',
                                  //     style: TextStyle(
                                  //         fontWeight: FontWeight.w700,
                                  //         color: Colors.black,
                                  //         fontSize: screenWidth * 0.05),
                                  //   )),
                                  // ),
                                  SizedBox(
                                    height: screenHeight * 0.02,
                                  ),

                                  /// Random Post
                                  Container(
                                      width: double.infinity,
                                      height: screenHeight * 0.05,
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(5),
                                          color: const Color.fromRGBO(
                                              255, 238, 238, 1)),
                                      child: Padding(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: screenWidth * 0.02),
                                        child: Row(
                                          children: [
                                            Container(
                                              height: screenHeight * 0.03,
                                              width: screenWidth * 0.01,
                                              decoration: const BoxDecoration(
                                                  color: Color.fromRGBO(
                                                      255, 90, 0, 1)),
                                            ),
                                            SizedBox(
                                              width: screenWidth * 0.02,
                                            ),
                                            Text(
                                              languageProvider.isEnglish
                                                  ? "Random Posts"
                                                  : "रैंडम पोस्ट",
                                              style: TextStyle(
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.w700,
                                                  fontSize: screenWidth * 0.04),
                                            ),
                                            const Spacer(),
                                            GestureDetector(
                                              onTap: () {
                                                Navigator.push(
                                                    context,
                                                    CupertinoPageRoute(
                                                      builder: (context) =>
                                                          ViewAllBlogScreen(
                                                        subCategoryData:
                                                            subCategoryList,
                                                      ),
                                                    ));
                                              },
                                              child: Text(
                                                languageProvider.isEnglish
                                                    ? "View All"
                                                    : "सभी को देखें",
                                                style: const TextStyle(
                                                    color: Color.fromRGBO(
                                                        255, 139, 33, 1),
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            )
                                          ],
                                        ),
                                      )),
                                  SizedBox(
                                    height: screenHeight * 0.02,
                                  ),
                                  SizedBox(
                                    height: screenHeight * 0.38,
                                    child: ListView.builder(
                                        padding: EdgeInsets.zero,
                                        physics: const BouncingScrollPhysics(),
                                        scrollDirection: Axis.horizontal,
                                        itemCount: subCategoryList.length > 20
                                            ? subCategoryList.length - 20
                                            : 0,
                                        itemBuilder: (context, index) {
                                          final subCategoryItem =
                                              subCategoryList[index + 20];
                                          return blogCardWidget(
                                            context: context,
                                            subCategoryItem: subCategoryItem,
                                            screenWidth: screenWidth,
                                            screenHeight: screenHeight,
                                            subCategoryList: subCategoryList,
                                            isEnglish:
                                                languageProvider.isEnglish,
                                          );
                                        }),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(
                              height: screenHeight * 0.02,
                            ),
                            blogSaveProvider.bookMarkedBlogs.isEmpty
                                ? Container()
                                : Column(
                                    children: [
                                      Container(
                                        height: screenHeight * 0.46,
                                        width: double.infinity,
                                        decoration: const BoxDecoration(
                                          color:
                                              Color.fromRGBO(235, 248, 255, 1),
                                        ),
                                        child: Padding(
                                          padding: EdgeInsets.symmetric(
                                            vertical: screenHeight * 0.02,
                                          ),
                                          child: Column(
                                            children: [
                                              Padding(
                                                padding: EdgeInsets.symmetric(
                                                    horizontal:
                                                        screenWidth * 0.03),
                                                child: Row(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Container(
                                                      height:
                                                          screenHeight * 0.03,
                                                      width: screenWidth * 0.01,
                                                      decoration:
                                                          const BoxDecoration(
                                                        color: Color.fromRGBO(
                                                            255, 90, 0, 1),
                                                      ),
                                                    ),
                                                    SizedBox(
                                                        width:
                                                            screenWidth * 0.02),
                                                    Text(
                                                      languageProvider.isEnglish
                                                          ? "Favorites"
                                                          : "पसंदीदा",
                                                      style: TextStyle(
                                                        color: Colors.black,
                                                        fontWeight:
                                                            FontWeight.w700,
                                                        fontSize:
                                                            screenWidth * 0.05,
                                                      ),
                                                    ),
                                                    const Spacer(),
                                                    GestureDetector(
                                                      onTap: () {
                                                        // Navigate to the 'View All' page
                                                        Navigator.push(
                                                          context,
                                                          CupertinoPageRoute(
                                                              builder: (context) =>
                                                                  const BlogBookmarkScreen()
                                                              //AllBookmarksScreen(), // Navigate to the new screen
                                                              ),
                                                        );
                                                      },
                                                      child: Text(
                                                        languageProvider
                                                                .isEnglish
                                                            ? "View All"
                                                            : "सभी को देखें",
                                                        style: const TextStyle(
                                                            color:
                                                                Color.fromRGBO(
                                                                    255,
                                                                    139,
                                                                    33,
                                                                    1),
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              SingleChildScrollView(
                                                scrollDirection:
                                                    Axis.horizontal,
                                                child: Padding(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      vertical: 20,
                                                      horizontal: 16),
                                                  child: Consumer<
                                                      BlogSaveProvider>(
                                                    builder: (context,
                                                        blogSaveProvider, _) {
                                                      return Row(
                                                        children: [
                                                          // Static Image (if required)
                                                          Container(
                                                            height: 200,
                                                            width: 150,
                                                            decoration:
                                                                BoxDecoration(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          12),
                                                              image:
                                                                  const DecorationImage(
                                                                image: NetworkImage(
                                                                    "https://r2.erweima.ai/imgcompressed/compressed_9d52c59421e261edb11e06bd19535878.webp"),
                                                                fit: BoxFit
                                                                    .cover,
                                                              ),
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                              width: 12),
                                                          ...List.generate(
                                                              blogSaveProvider
                                                                  .bookMarkedBlogs
                                                                  .length,
                                                              (index) {
                                                            final blog =
                                                                blogSaveProvider
                                                                        .bookMarkedBlogs[
                                                                    index];
                                                            final isBookmarked =
                                                                blogSaveProvider
                                                                    .bookMarkedBlogs
                                                                    .any((b) =>
                                                                        b.title ==
                                                                        blog.title);

                                                            return Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .only(
                                                                      right:
                                                                          12),
                                                              child:
                                                                  GestureDetector(
                                                                onTap: () {
                                                                  Navigator
                                                                      .push(
                                                                    context,
                                                                    CupertinoPageRoute(
                                                                      builder:
                                                                          (context) =>
                                                                              BlogDetailsPage(
                                                                        remainingItems: const [],
                                                                        title: subCategoryList[index]
                                                                            .titleSlug,
                                                                      ),
                                                                    ),
                                                                  );
                                                                },
                                                                child:
                                                                    Container(
                                                                  width: 200,
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    color: Colors
                                                                        .white,
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            16),
                                                                    boxShadow: const [
                                                                      BoxShadow(
                                                                        color: Colors
                                                                            .black12,
                                                                        blurRadius:
                                                                            6,
                                                                        offset: Offset(
                                                                            0,
                                                                            4),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                  child: Column(
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .start,
                                                                    children: [
                                                                      // Blog Image
                                                                      ClipRRect(
                                                                        borderRadius: const BorderRadius
                                                                            .vertical(
                                                                            top:
                                                                                Radius.circular(16)),
                                                                        child:
                                                                            CachedNetworkImage(
                                                                          imageUrl:
                                                                              blog.imageBig ?? '',
                                                                          height:
                                                                              110,
                                                                          width:
                                                                              double.infinity,
                                                                          fit: BoxFit
                                                                              .fill,
                                                                          errorWidget: (context, url, error) =>
                                                                              const NoImageWidget(),
                                                                        ),
                                                                      ),
                                                                      Padding(
                                                                        padding: const EdgeInsets
                                                                            .all(
                                                                            10),
                                                                        child:
                                                                            Column(
                                                                          crossAxisAlignment:
                                                                              CrossAxisAlignment.start,
                                                                          children: [
                                                                            // Blog Title
                                                                            Text(
                                                                              blog.title ?? '',
                                                                              style: const TextStyle(
                                                                                fontSize: 15,
                                                                                fontWeight: FontWeight.bold,
                                                                              ),
                                                                              maxLines: 2,
                                                                              overflow: TextOverflow.ellipsis,
                                                                            ),
                                                                            const SizedBox(height: 6),

                                                                            // Date and Views Row
                                                                            Row(
                                                                              children: [
                                                                                const Icon(Icons.calendar_month, size: 14, color: Colors.grey),
                                                                                const SizedBox(width: 4),
                                                                                Expanded(
                                                                                  child: Text(
                                                                                    formatDate(blog.createdAt),
                                                                                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                                                                                    overflow: TextOverflow.ellipsis,
                                                                                  ),
                                                                                ),
                                                                                const Icon(Icons.remove_red_eye_outlined, size: 14, color: Colors.grey),
                                                                                const SizedBox(width: 2),
                                                                                Text(
                                                                                  "${blog.hit}",
                                                                                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                                                                                ),
                                                                              ],
                                                                            ),
                                                                            Divider(
                                                                              color: Colors.grey.shade300,
                                                                            ),

                                                                            // Action Row
                                                                            Row(
                                                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                              children: [
                                                                                // Read Blog Button
                                                                                ElevatedButton(
                                                                                  style: ElevatedButton.styleFrom(
                                                                                    backgroundColor: Colors.deepOrange,
                                                                                    shape: RoundedRectangleBorder(
                                                                                      borderRadius: BorderRadius.circular(8),
                                                                                    ),
                                                                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                                                                  ),
                                                                                  onPressed: () {
                                                                                    Navigator.push(
                                                                                      context,
                                                                                      CupertinoPageRoute(
                                                                                        builder: (context) => BlogDetailsPage(
                                                                                          remainingItems: const [],
                                                                                          title: subCategoryList[index].titleSlug,
                                                                                        ),
                                                                                      ),
                                                                                    );
                                                                                  },
                                                                                  child: Row(
                                                                                    children: [
                                                                                      const Icon(
                                                                                        Icons.menu_book,
                                                                                        color: Colors.white,
                                                                                        size: 18,
                                                                                      ),
                                                                                      const SizedBox(
                                                                                        width: 5,
                                                                                      ),
                                                                                      Text(
                                                                                        languageProvider.isEnglish ? "Read Blog" : "ब्लॉग पढ़ें",
                                                                                        style: const TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.bold),
                                                                                      ),
                                                                                    ],
                                                                                  ),
                                                                                ),

                                                                                // Share and Bookmark
                                                                                Row(
                                                                                  children: [
                                                                                    // IconButton(
                                                                                    //   icon: const Icon(Icons.share_outlined, size: 18, color: Colors.grey),
                                                                                    //   onPressed: () {
                                                                                    //    //shareMusic.shareSong(subCategoryList[index], context);
                                                                                    //   },
                                                                                    // ),
                                                                                    GestureDetector(
                                                                                      onTap: () {
                                                                                        blogSaveProvider.toggleBookmark(blog);
                                                                                      },
                                                                                      child: Container(
                                                                                        padding: const EdgeInsets.all(6),
                                                                                        decoration: const BoxDecoration(
                                                                                          shape: BoxShape.circle,
                                                                                          color: Colors.white,
                                                                                          boxShadow: [
                                                                                            BoxShadow(
                                                                                              color: Colors.black26,
                                                                                              blurRadius: 4,
                                                                                              offset: Offset(0, 2),
                                                                                            ),
                                                                                          ],
                                                                                        ),
                                                                                        child: Icon(
                                                                                          isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                                                                                          size: 20,
                                                                                          color: Colors.orange[800], // You can adjust color if needed
                                                                                        ),
                                                                                      ),
                                                                                    ),
                                                                                  ],
                                                                                ),
                                                                              ],
                                                                            ),
                                                                          ],
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                              ),
                                                            );
                                                          }),
                                                        ],
                                                      );
                                                    },
                                                  ),
                                                ),
                                              )
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  )
                          ],
                        ),
                      ),
                    ),
                  ));
      },
    );
  }

  Widget blogCardWidget({
    required BuildContext context,
    required BlogSubCategoryData subCategoryItem,
    required double screenWidth,
    required double screenHeight,
    required List<BlogSubCategoryData> subCategoryList,
    required bool isEnglish,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 5),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            CupertinoPageRoute(
              builder: (context) => BlogDetailsPage(
                remainingItems: subCategoryList.reversed.toList(),
                title: subCategoryItem.titleSlug,
              ),
            ),
          );
        },
        child: Container(
          width: screenWidth * 0.6,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
            border: Border.all(color: const Color(0xFFE0E0E0)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  ClipRRect(
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(16)),
                    child: CachedNetworkImage(
                      imageUrl: subCategoryItem.imageBig,
                      height: screenHeight * 0.18,
                      width: double.infinity,
                      fit: BoxFit.fill,
                      errorWidget: (context, url, error) =>
                          const NoImageWidget(),
                    ),
                  ),
                  Positioned(
                    right: 10,
                    top: 10,
                    child: Consumer<BlogSaveProvider>(
                      builder: (context, provider, _) {
                        final isBookmarked = provider.bookMarkedBlogs.any(
                          (b) => b.title == subCategoryItem.title,
                        );
                        return GestureDetector(
                          onTap: () {
                            provider.toggleBookmark(subCategoryItem);
                          },
                          child: Container(
                            padding: const EdgeInsets.all(5),
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black26,
                                  blurRadius: 4,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Icon(
                              isBookmarked
                                  ? Icons.bookmark
                                  : Icons.bookmark_border,
                              color: Colors.orange[800],
                              size: 22,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
              Padding(
                padding: EdgeInsets.all(screenWidth * 0.04),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      subCategoryItem.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: screenWidth * 0.036,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.008),
                    Row(
                      children: [
                        Icon(Icons.calendar_month,
                            size: screenWidth * 0.04, color: Colors.grey),
                        SizedBox(width: screenWidth * 0.01),
                        Text(
                          formatDate(subCategoryItem.createdAt),
                          style: TextStyle(
                              fontSize: screenWidth * 0.032,
                              color: Colors.grey[700]),
                        ),
                        SizedBox(width: screenWidth * 0.03),
                        Icon(Icons.remove_red_eye_outlined,
                            size: screenWidth * 0.04, color: Colors.grey),
                        SizedBox(width: screenWidth * 0.01),
                        Text(
                          "${subCategoryItem.hit}",
                          style: TextStyle(
                              fontSize: screenWidth * 0.032,
                              color: Colors.grey[700]),
                        ),
                      ],
                    ),
                    Divider(color: Colors.grey.shade300),
                    Row(
                      children: [
                        Expanded(
                          flex: 1,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                CupertinoPageRoute(
                                  builder: (context) => BlogDetailsPage(
                                    remainingItems: subCategoryList,
                                    title: subCategoryItem.titleSlug,
                                  ),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              // backgroundColor: const Color(0xFFFF9800),
                              backgroundColor: Colors.deepOrange,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 10),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.menu_book,
                                    color: Colors.white, size: 20),
                                const SizedBox(width: 5),
                                Text(
                                  isEnglish ? "Read Blog" : "ब्लॉग पढ़ें",
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold),
                                ),
                                const Spacer(),
                                const Icon(Icons.arrow_circle_right_outlined,
                                    color: Colors.white),
                              ],
                            ),
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
      ),
    );
  }
}
