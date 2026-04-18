import 'dart:math';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mahakal/features/blogs_module/Controller/Bookmark%20Provider.dart';
import 'package:mahakal/utill/app_constants.dart';
import 'package:intl/intl.dart';
import 'package:mahakal/utill/loading_datawidget.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'package:share_plus/share_plus.dart';
import '../../../data/datasource/remote/http/httpClient.dart';
import '../../custom_bottom_bar/bottomBar.dart';
import '../../youtube_vedios/view/dynamic_tabview/grid_view/YoutubeGridView.dart';
import '../Controller/ShareScreen.dart';
import '../Controller/language_provider.dart';
import '../model/SubCategory_model.dart';
import 'package:flutter_html/flutter_html.dart';

import '../model/blog_details_model.dart';
import '../no_image_widget.dart';

class BlogDetailsPage extends StatefulWidget {
  final title;
  final List<BlogSubCategoryData> remainingItems;

  const BlogDetailsPage({
    super.key,
    required this.remainingItems,
    required this.title,
  });

  @override
  State<BlogDetailsPage> createState() => _BlogDetailsPageState();
}

class _BlogDetailsPageState extends State<BlogDetailsPage> {
  int initialShowItems = 10; // Limit to 10 items initially
  int _currentIndex = 0;

  bool _isBlackBackground = false;
  bool _isLoading = false;
  bool _isAutoScrolling = false;

  double _scrollSpeed = 5.0; // Set a reasonable default speed
  double _textSizeLevel = 16.0;

  late Timer _scrollTimer;

  final List<Color> _itemColors = [];
  final List<Color> _itemColor = [];
  List<int> bookmarkedIds = [];

  // final double _scaleIncrement = 0.1;
  final shareMusic = ShareBlogs();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    if (widget.title != null && widget.title.toString().trim().isNotEmpty) {
      debugPrint("📰 Blog Slug: ${widget.title}");
      getDetails(widget.title);
    } else {
      debugPrint("⚠️ Blog Slug is null or empty!");
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("invalid link.${widget.title}"),
            backgroundColor: Colors.red,
          ),
        );

      });
    }
  }

  void _generateRandomColors() {
    // Assuming yourDataList is the data for ListView
    for (int i = 0; i < subCategoryDataDetils!.mostViewedBlogs.length; i++) {
      _itemColors.add(_getRandomColor());
    }

    for (int i = 0; i < subCategoryDataDetils!.latestBlogs.length; i++) {
      _itemColor.add(_getRandomColor());
    }

  }

  // Function to generate a random color
  Color _getRandomColor() {
    Random random = Random();
    return Color.fromARGB(
      255,
      random.nextInt(256),
      random.nextInt(256),
      random.nextInt(256),
    );
  }

  String formatDate(DateTime? date) {
    if (date == null) return 'Unknown';
    return DateFormat("dd-MMM-yyyy").format(date);
  }

  @override
  void dispose() {
    _scrollTimer.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _shareContent(String? myData) async {
    String parsedContent = HtmlParser.parseHTML(myData ?? '').text.trim();
    String shortContent = parsedContent.length > 500
        ? "${parsedContent.substring(0, 500)}..."
        : parsedContent;

    String shareUrl = '';
    shareUrl = "${AppConstants.baseUrl}/download";

    // Final share message
    String shareText = "📜 *${shortContent ?? 'महाकाल ब्लॉग'}* 🙏✨\n"
        "$shortContent\n\n"
        "पूरा ब्लॉग पढ़ें सिर्फ Mahakal.com ऐप पर 🔱🔥\n"
        "अभी डाउनलोड करें और जुड़ें आस्था के इस सफर में 📲💖\n\n"
        "🔹Download App Now: $shareUrl";

    try {
      await Share.share(
        shareText,
        subject: '📖 धार्मिक ज्ञान और व्रत कथाएं',
        sharePositionOrigin: Rect.fromLTWH(0, 0, 1, 1),
      );
    } catch (e) {
      print('Share failed: $e');
      // Optionally show a snackbar to the user
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to share: $e')),
        );
      }
    }
  }

  void _toggleAutoScroll() {
    setState(() {
      _isAutoScrolling = !_isAutoScrolling;

      if (_isAutoScrolling) {
        _scrollTimer =
            Timer.periodic(const Duration(milliseconds: 100), (timer) {
          if (_scrollController.position.pixels <
              _scrollController.position.maxScrollExtent) {
            _scrollController.animateTo(
              _scrollController.position.pixels + _scrollSpeed,
              duration: const Duration(milliseconds: 100),
              curve: Curves.linear,
            );
          } else {
            _scrollController.jumpTo(0);
          }
        });
      } else {
        _scrollTimer.cancel();
      }
    });
  }

  void _onBottomNavTap(int index) {
    if (index != 4) {
      if (_isAutoScrolling) {
        _toggleAutoScroll();
      }
    }

    setState(() {
      _currentIndex = index;

      if (index == 0) {
        _isBlackBackground = !_isBlackBackground;
      } else if (index == 1) {
        _increaseTextSize();
      } else if (index == 2) {
        _decreaseTextSize();
      } else if (index == 3) {
        _shareContent(subCategoryDataDetils!.data!.content).catchError((e) {
          print('Share error: $e');
        });
      } else if (index == 4) {
        _toggleAutoScroll();
      }
    });
  }

  void _increaseTextSize() {
    setState(() {
      if (_textSizeLevel < 30) {
        _textSizeLevel += 2; // increase text size by 2
        print(_textSizeLevel);
      } else {
        print("Maximum text size reached");
      }
    });
  }

  void _decreaseTextSize() {
    setState(() {
      if (_textSizeLevel > 12) {
        _textSizeLevel -= 2; // decrease text size by 2
        print(_textSizeLevel);
      } else {
        print("Minimum text size reached");
      }
    });
  }

  /// Fetch Details
  BlogDetailsModel? subCategoryDataDetils;

  Future<void> getDetails(String title) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final String url = "${AppConstants.blogsDetailsUrl}$title";

      final Map<String, dynamic>? res =
          await HttpService().getApi(url) as Map<String, dynamic>?;

      print(res);

      if (res != null &&
          res.containsKey("status") &&
          res.containsKey("data") &&
          res["data"] != null) {
        final blogDetails = BlogDetailsModel.fromJson(res);
        subCategoryDataDetils = blogDetails;

        print(blogDetails.data!.title);
        _generateRandomColors();

      }
    } catch (e) {
      print("Error blog details: $e");
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

    return _isLoading
        ? MahakalLoadingData(
            onReload: () => getDetails(widget.title),
          )
        : Scaffold(
            appBar: AppBar(
              backgroundColor:
                  _isBlackBackground ? Colors.black : Colors.deepOrange,
              title: Text(
                "Blogs",
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                  fontSize: screenWidth * 0.06,
                  fontFamily: 'Roboto',
                ),
              ),
              centerTitle: true,
              leading: IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: const Icon(
                    Icons.arrow_back_ios,
                    color: Colors.white,
                  )),
              actions: [
                IconButton(
                    onPressed: () {
                      Navigator.of(context).pushReplacement(CupertinoPageRoute(
                          builder: (BuildContext context) =>
                              const BottomBar(pageIndex: 0)));
                    },
                    icon: const Icon(
                      Icons.home,
                      color: Colors.white,
                    )),
                const SizedBox(width: 15)
              ],
            ),
            backgroundColor: _isBlackBackground ? Colors.black : Colors.white,
            body: SingleChildScrollView(
              controller: _scrollController,
              child: Consumer<BlogLanguageProvider>(
                builder:
                    (BuildContext context, languageProvider, Widget? child) {
                  return Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: screenWidth * 0.02),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(
                          height: 10,
                        ),
                        Container(
                          width: double.infinity,
                          height: screenHeight * 0.24,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: CachedNetworkImage(
                              imageUrl:
                                  "${AppConstants.baseUrl}/blog/${subCategoryDataDetils!.data!.imageBig}",
                              fit: BoxFit.fill,
                              width: double.infinity,
                              height: screenHeight * 0.24,
                              placeholder: (context, url) => placeholderImage(),
                              errorWidget: (context, url, error) =>
                                  const NoImageWidget(),
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            color: _isBlackBackground
                                ? Colors.orange[900]
                                : Colors.orange[100],
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 6,
                                offset: Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.date_range,
                                size: 16,
                                color: _isBlackBackground
                                    ? Colors.white70
                                    : Colors.black87,
                              ),
                              SizedBox(width: screenWidth * 0.015),
                              SizedBox(
                                width: screenWidth * 0.35,
                                child: Text(
                                  formatDate(
                                      subCategoryDataDetils!.data!.createdAt),
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: _isBlackBackground
                                        ? Colors.white70
                                        : Colors.black87,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              ),
                              const Spacer(),
                              Icon(
                                Icons.remove_red_eye_outlined,
                                size: 16,
                                color: _isBlackBackground
                                    ? Colors.white70
                                    : Colors.black87,
                              ),
                              SizedBox(width: screenWidth * 0.015),
                              Text(
                                "${subCategoryDataDetils!.data!.hit}",
                                style: TextStyle(
                                  fontSize: 13,
                                  color: _isBlackBackground
                                      ? Colors.white70
                                      : Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          subCategoryDataDetils?.data?.title ?? '',
                          style: TextStyle(
                              fontSize: screenWidth * 0.05,
                              fontWeight: FontWeight.bold,
                              color: _isBlackBackground
                                  ? Colors.white
                                  : Colors.black),
                        ),
                        Html(
                          data: subCategoryDataDetils!.data!.content,
                          style: {
                            "body": Style(
                              color: _isBlackBackground
                                  ? Colors.white
                                  : Colors.black,
                              alignment: Alignment.topCenter,
                            ),
                            'p': Style(fontSize: FontSize(_textSizeLevel)),
                            'li': Style(fontSize: FontSize(_textSizeLevel)),
                            'ul': Style(fontSize: FontSize(_textSizeLevel)),
                            'span': Style(fontSize: FontSize(_textSizeLevel)),
                            'strong': Style(fontSize: FontSize(_textSizeLevel)),
                          },
                        ),

                        Column(
                                children: [

                                  /// Populer Post
                                  SizedBox(
                                    height: screenHeight * 0.02,
                                  ),
                                  Consumer<BlogLanguageProvider>(
                                    builder: (BuildContext context,
                                        languageProvider, Widget? child) {
                                      return Row(
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
                                                ? "Popular Post"
                                                : "लोकप्रिय पोस्ट",
                                            style: TextStyle(
                                                color: _isBlackBackground
                                                    ? Colors.white
                                                    : Colors.black87,
                                                fontWeight: FontWeight.w700,
                                                fontSize: screenWidth * 0.04),
                                          ),
                                          const Spacer(),
                                        ],
                                      );
                                    },
                                  ),
                                  SizedBox(
                                    height: screenHeight * 0.02,
                                  ),
                                  SizedBox(
                                    height: screenHeight * 0.17,
                                    child: ListView.builder(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10),
                                      physics: const BouncingScrollPhysics(),
                                      scrollDirection: Axis.horizontal,
                                      itemCount: subCategoryDataDetils?.mostViewedBlogs.length,
                                      itemBuilder: (context, index) {
                                        final item =  subCategoryDataDetils?.mostViewedBlogs[index];
                                        final color1 = _itemColors[index];
                                        final titleWords =
                                            item?.title?.split(' ');
                                        final safeTake = titleWords!.length > 2
                                            ? titleWords!.length - 2
                                            : 1;

                                        return GestureDetector(
                                          onTap: () {
                                            getDetails(item?.titleSlug ?? '');
                                          },
                                          child: Container(
                                            width: screenWidth * 0.8,
                                            margin: const EdgeInsets.only(
                                                right: 10),
                                            padding: const EdgeInsets.all(10),
                                            decoration: BoxDecoration(
                                              color: _isBlackBackground
                                                  ? Colors.grey[850]
                                                  : Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              boxShadow: const [
                                                BoxShadow(
                                                  color: Colors.black12,
                                                  blurRadius: 4,
                                                  offset: Offset(0, 2),
                                                )
                                              ],
                                              border: Border.all(
                                                  color: const Color(0xFFE7E7E7)),
                                            ),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                /// TITLE AND IMAGE
                                                Row(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    /// TITLE
                                                    Expanded(
                                                      child: RichText(
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        maxLines: 3,
                                                        text: TextSpan(
                                                          style: TextStyle(
                                                            fontSize:
                                                                screenWidth *
                                                                    0.036,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color:
                                                                _isBlackBackground
                                                                    ? Colors
                                                                        .white
                                                                    : Colors
                                                                        .black,
                                                          ),
                                                          children: [
                                                            TextSpan(
                                                              text: titleWords
                                                                  .take(
                                                                      safeTake)
                                                                  .join(' '),
                                                              style: TextStyle(
                                                                  color:
                                                                      color1),
                                                            ),
                                                            TextSpan(
                                                              text:
                                                                  ' ${titleWords.length > 1 ? titleWords.last : ''} ${titleWords.length > 2 ? titleWords[safeTake] : ''}',
                                                              style: TextStyle(
                                                                color: _isBlackBackground
                                                                    ? Colors
                                                                        .white
                                                                    : Colors
                                                                        .black,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                    const SizedBox(width: 10),

                                                    /// IMAGE
                                                    ClipRRect(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8),
                                                      child: CachedNetworkImage(
                                                        imageUrl:
                                                            item?.imageBig ?? '',
                                                        width:
                                                            screenWidth * 0.3,
                                                        height:
                                                            screenWidth * 0.2,
                                                        fit: BoxFit.fill,
                                                        placeholder: (context,
                                                                url) =>
                                                            placeholderImage(),
                                                        errorWidget: (context,
                                                                url, error) =>
                                                            const NoImageWidget(),
                                                      ),
                                                    ),
                                                  ],
                                                ),

                                                /// METADATA & ACTIONS
                                                Row(
                                                  children: [
                                                    const Icon(
                                                        Icons.calendar_month,
                                                        color: Colors.grey,
                                                        size: 14),
                                                    const SizedBox(width: 4),
                                                    Text(
                                                      formatDate(
                                                          item?.createdAt),
                                                      style: const TextStyle(
                                                          fontSize: 12,
                                                          color: Colors.grey),
                                                    ),
                                                    const SizedBox(width: 10),
                                                    const Icon(
                                                        Icons
                                                            .remove_red_eye_outlined,
                                                        size: 14,
                                                        color: Colors.grey),
                                                    const SizedBox(width: 4),
                                                    Text("${item?.hit}",
                                                        style: const TextStyle(
                                                            fontSize: 12,
                                                            color:
                                                                Colors.grey)),
                                                  ],
                                                ),
                                                Divider(
                                                  color: Colors.grey.shade300,
                                                ),

                                                // Row(
                                                //   children: [
                                                //
                                                //     // Bookmark
                                                //     Consumer<BlogSaveProvider>(
                                                //       builder: (context,
                                                //           bookmarkProvider,
                                                //           child) {
                                                //         final bookmarked =
                                                //             bookmarkProvider
                                                //                 .bookMarkedBlogs
                                                //                 .any(
                                                //           (b) =>
                                                //               b.title ==
                                                //               item?.title,
                                                //         );
                                                //         return InkWell(
                                                //           borderRadius:
                                                //               BorderRadius
                                                //                   .circular(30),
                                                //           onTap: () {
                                                //             bookmarkProvider.toggleBookmark();
                                                //           },
                                                //           child: Container(
                                                //             padding:
                                                //                 const EdgeInsets
                                                //                     .all(6),
                                                //             decoration:
                                                //                 BoxDecoration(
                                                //               shape: BoxShape
                                                //                   .circle,
                                                //               color: Colors
                                                //                   .orange
                                                //                   .withOpacity(
                                                //                       0.1),
                                                //             ),
                                                //             child: Icon(
                                                //               bookmarked
                                                //                   ? Icons
                                                //                       .bookmark
                                                //                   : Icons
                                                //                       .bookmark_border,
                                                //               color: bookmarked
                                                //                   ? Colors
                                                //                       .blueAccent
                                                //                   : Colors.grey,
                                                //             ),
                                                //           ),
                                                //         );
                                                //       },
                                                //     ),
                                                //     const Spacer(),
                                                //
                                                //     // Optional: Add a small label like "Read More →"
                                                //     Text(
                                                //       "Read Blog →",
                                                //       style: TextStyle(
                                                //         fontSize:
                                                //             screenWidth * 0.035,
                                                //         fontWeight:
                                                //             FontWeight.w500,
                                                //         color: Colors
                                                //             .green.shade700,
                                                //       ),
                                                //     ),
                                                //   ],
                                                // ),

                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                  SizedBox(
                                    height: screenHeight * 0.02,
                                  ),


                                  /// Trending Post
                                  Consumer<BlogLanguageProvider>(
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
                                                      ? "Trending"
                                                      : "ट्रेंडिंग",
                                                  style: TextStyle(
                                                      color: _isBlackBackground
                                                          ? Colors.white
                                                          : Colors.black87,
                                                      fontWeight:
                                                          FontWeight.w700,
                                                      fontSize:
                                                          screenWidth * 0.04),
                                                ),
                                                const Spacer(),
                                              ],
                                            );
                                          },
                                        ),
                                  SizedBox(
                                    height: screenHeight * 0.02,
                                  ),
                                  SizedBox(
                                    height: screenHeight * 0.17,
                                          child: ListView.builder(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 10),
                                            physics:
                                                const BouncingScrollPhysics(),
                                            scrollDirection: Axis.horizontal,
                                            itemCount: subCategoryDataDetils?.latestBlogs.length,
                                            itemBuilder: (context, index) {
                                              final subCategoryItem = subCategoryDataDetils?.latestBlogs[index];
                                              final isBookmarked = bookmarkedIds
                                                  .contains(subCategoryItem?.id);

                                              final randomColor1 =
                                                  _itemColor[index];
                                              final randomColor2 =
                                                  _getRandomColor();

                                              final words = subCategoryItem?.title?.split(' ');
                                              final safeLength = words?.length;

                                              final firstPart = (safeLength! > 2)
                                                  ? words?.take(safeLength! - 2)
                                                      .join(' ')
                                                  : words?.first;
                                              final secondLast =
                                                  (safeLength > 1)
                                                      ? words![safeLength - 2]
                                                      : '';
                                              final last = (safeLength > 0)
                                                  ? words!.last
                                                  : '';

                                              return GestureDetector(
                                                onTap: () {
                                                  getDetails(subCategoryItem?.titleSlug ?? '');
                                                },
                                                child: Container(
                                                  width: screenWidth * 0.8,
                                                  margin: const EdgeInsets.only(
                                                      right: 10),
                                                  padding:
                                                      const EdgeInsets.all(10),
                                                  decoration: BoxDecoration(
                                                    color: _isBlackBackground
                                                        ? Colors.grey[850]
                                                        : Colors.white,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10),
                                                    boxShadow: const [
                                                      BoxShadow(
                                                        color: Colors.black12,
                                                        blurRadius: 4,
                                                        offset: Offset(0, 2),
                                                      )
                                                    ],
                                                    border: Border.all(
                                                        color: const Color(
                                                            0xFFE7E7E7)),
                                                  ),
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      /// TITLE AND IMAGE
                                                      Row(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          /// TITLE
                                                          Expanded(
                                                            child: RichText(
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                              maxLines: 3,
                                                              text: TextSpan(
                                                                style:
                                                                    TextStyle(
                                                                  fontSize:
                                                                      screenWidth *
                                                                          0.036,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  color: _isBlackBackground
                                                                      ? Colors
                                                                          .white
                                                                      : Colors
                                                                          .black,
                                                                ),
                                                                children: [
                                                                  TextSpan(
                                                                    text:
                                                                        firstPart,
                                                                    style: TextStyle(
                                                                        color:
                                                                            randomColor1),
                                                                  ),
                                                                  TextSpan(
                                                                    text:
                                                                        ' $last $secondLast',
                                                                    style:
                                                                        TextStyle(
                                                                      color: _isBlackBackground
                                                                          ? Colors
                                                                              .white
                                                                          : Colors
                                                                              .black,
                                                                    ),
                                                                  ),
                                                                  // TextSpan(
                                                                  //   text: subCategoryItem.title.split(' ').take(subCategoryItem.title!.split(' ').length - 2).join(' ') ?? '',
                                                                  //   style: TextStyle(color: randomColor1),
                                                                  // ),
                                                                  // TextSpan(
                                                                  //   text: ' ${subCategoryItem.title.split(' ').last} ${subCategoryItem.title.split(' ')[subCategoryItem.title!.split(' ').length - 2]}',
                                                                  //   style: TextStyle(
                                                                  //     color: _isBlackBackground ? Colors.white : Colors.black,
                                                                  //   ),
                                                                  // ),
                                                                ],
                                                              ),
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                              width: 10),

                                                          /// IMAGE
                                                          ClipRRect(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        8),
                                                            child:
                                                                CachedNetworkImage(
                                                              imageUrl:
                                                                  subCategoryItem?.imageBig ??
                                                                      '',
                                                              width:
                                                                  screenWidth *
                                                                      0.3,
                                                              height:
                                                                  screenWidth *
                                                                      0.2,
                                                              fit: BoxFit.cover,
                                                              placeholder: (context,
                                                                      url) =>
                                                                  placeholderImage(),
                                                              errorWidget: (context,
                                                                      url,
                                                                      error) =>
                                                                  const NoImageWidget(),
                                                            ),
                                                          ),
                                                        ],
                                                      ),

                                                      /// METADATA & ACTIONS
                                                      Row(
                                                        children: [
                                                          const Icon(
                                                              Icons
                                                                  .calendar_month,
                                                              color:
                                                                  Colors.grey,
                                                              size: 14),
                                                          const SizedBox(
                                                              width: 4),
                                                          Text(
                                                            formatDate(
                                                                subCategoryItem?.createdAt),
                                                            style:
                                                                const TextStyle(
                                                                    fontSize:
                                                                        12,
                                                                    color: Colors
                                                                        .grey),
                                                          ),
                                                          const SizedBox(
                                                              width: 10),
                                                          const Icon(
                                                              Icons
                                                                  .remove_red_eye_outlined,
                                                              size: 14,
                                                              color:
                                                                  Colors.grey),
                                                          const SizedBox(
                                                              width: 4),
                                                          Text(
                                                              "${subCategoryItem?.hit}",
                                                              style: const TextStyle(
                                                                  fontSize: 12,
                                                                  color: Colors
                                                                      .grey)),
                                                        ],
                                                      ),
                                                      Divider(
                                                        color: Colors
                                                            .grey.shade300,
                                                      ),
                                                      // Row(
                                                      //   children: [
                                                      //     Consumer<
                                                      //         BlogSaveProvider>(
                                                      //       builder: (context,
                                                      //           bookmarkProvider,
                                                      //           child) {
                                                      //         final bookmarked =
                                                      //             bookmarkProvider
                                                      //                 .bookMarkedBlogs
                                                      //                 .any(
                                                      //           (b) =>
                                                      //               b.title ==
                                                      //               subCategoryItem?.title,
                                                      //         );
                                                      //         return InkWell(
                                                      //           borderRadius:
                                                      //               BorderRadius
                                                      //                   .circular(
                                                      //                       30),
                                                      //           onTap: () {
                                                      //             // bookmarkProvider.toggleBookmark(subCategoryItem);
                                                      //           },
                                                      //           child:
                                                      //               Container(
                                                      //             padding:
                                                      //                 const EdgeInsets
                                                      //                     .all(
                                                      //                     6),
                                                      //             decoration:
                                                      //                 BoxDecoration(
                                                      //               shape: BoxShape
                                                      //                   .circle,
                                                      //               color: Colors
                                                      //                   .orange
                                                      //                   .withOpacity(
                                                      //                       0.1),
                                                      //             ),
                                                      //             child: Icon(
                                                      //               bookmarked
                                                      //                   ? Icons
                                                      //                       .bookmark
                                                      //                   : Icons
                                                      //                       .bookmark_border,
                                                      //               color: bookmarked
                                                      //                   ? Colors
                                                      //                       .blueAccent
                                                      //                   : Colors
                                                      //                       .grey,
                                                      //             ),
                                                      //           ),
                                                      //         );
                                                      //       },
                                                      //     ),
                                                      //
                                                      //     const Spacer(),
                                                      //
                                                      //     // Optional: Add a small label like "Read More →"
                                                      //     Text(
                                                      //       "Read Blog →",
                                                      //       style: TextStyle(
                                                      //         fontSize:
                                                      //             screenWidth *
                                                      //                 0.035,
                                                      //         fontWeight:
                                                      //             FontWeight
                                                      //                 .w500,
                                                      //         color: Colors
                                                      //             .green
                                                      //             .shade700,
                                                      //       ),
                                                      //     ),
                                                      //   ],
                                                      // ),
                                                    ],
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                  SizedBox(
                                    height: screenHeight * 0.02,
                                  ),

                                ],
                              )
                      ],
                    ),
                  );
                },
              ),
            ),
            bottomNavigationBar: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_currentIndex == 4)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 8.0),
                    child: Column(
                      children: [
                        Text(
                          "Adjust Scroll Speed",
                          style: TextStyle(
                              color: _isBlackBackground
                                  ? Colors.white
                                  : Colors.black,
                              fontWeight: FontWeight.bold),
                        ),
                        Slider(
                          value: _scrollSpeed,
                          min: 1.0,
                          max: 10.0, // Maximum speed set to a reasonable value
                          divisions: 9,
                          label: _scrollSpeed.round().toString(),
                          onChanged: (double value) {
                            setState(() {
                              _scrollSpeed = value;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                BottomNavigationBar(
                  currentIndex: _currentIndex,
                  onTap: _onBottomNavTap,
                  selectedItemColor: Colors.orange,
                  selectedLabelStyle:
                      const TextStyle(fontWeight: FontWeight.bold),
                  items: const [
                    BottomNavigationBarItem(
                      icon: Icon(Icons.sunny, color: Colors.black),
                      label: 'Home',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.text_increase_outlined,
                          color: Colors.black),
                      label: 'Zoom In',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.text_decrease, color: Colors.black),
                      label: 'Zoom Out',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.share_outlined, color: Colors.black),
                      label: 'Share',
                    ),
                    // BottomNavigationBarItem(
                    //   icon: Icon(Icons.save, color: Colors.black),
                    //   label: 'Copy',
                    // ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.slideshow, color: Colors.black),
                      label: 'Slide',
                    ),
                  ],
                ),
              ],
            ),
          );
  }
}
