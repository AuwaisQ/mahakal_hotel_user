import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mahakal/features/youtube_vedios/view/dynamic_tabview/grid_view/YoutubeGridView.dart';
import 'package:mahakal/utill/app_constants.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../data/datasource/remote/http/httpClient.dart';
import '../Controller/Bookmark Provider.dart';
import '../Controller/ShareScreen.dart';
import '../Controller/language_provider.dart';
import '../model/SubCategory_model.dart';
import '../no_image_widget.dart';
import 'BlogDetailsPage.dart';

class BlogSubCategoryScreen extends StatefulWidget {
  final int myId;
  const BlogSubCategoryScreen({super.key, required this.myId});

  @override
  State<BlogSubCategoryScreen> createState() => _BlogSubCategoryScreenState();
}

class _BlogSubCategoryScreenState extends State<BlogSubCategoryScreen> {
  final shareMusic = ShareBlogs();

  bool _isLoading = false;
  bool showAll = false;

  List<BlogSubCategoryData> subCategoryList = [];

  // List to track bookmarked item IDs
  List<int> bookmarkedIds = [];
  late BlogLanguageProvider languageProvider;

  @override
  void initState() {
    super.initState();
    languageProvider =
        Provider.of<BlogLanguageProvider>(context, listen: false);

    // Call once initially
    getSubCategory();

    // Add listener to detect changes
    languageProvider.addListener(() {
      getSubCategory();
    });
  }

  @override
  void dispose() {
    languageProvider.removeListener(() {
      getSubCategory();
    });
    super.dispose();
  }

  String formatDate(String date) {
    try {
      DateTime parsedDate = DateTime.parse(date);
      return DateFormat("d MMMM yyyy").format(parsedDate); // 1 March 2025
    } catch (e) {
      print("Date Parsing Error: $e");
      return "Invalid Date";
    }
  }

  Future<void> getSubCategory() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final url =
          "${AppConstants.blogsSubCategoryUrl}${languageProvider.isEnglish ? 1 : 2}&categoryId=${widget.myId}";

      // Call your HttpService
      final Map<String, dynamic> res =
          await HttpService().getApi(url) as Map<String, dynamic>;

      if (res.containsKey('status') &&
          res.containsKey('data') &&
          res['data'] != null) {
        final categoryData = BlogSubCategoryModel.fromJson(res);
        setState(() {
          subCategoryList = categoryData.data;
        });
      } else {
        print("Error in Blog SubCategory: ${res['message']}");
      }
    } catch (error) {
      print("Error fetching Blog subcategories: $error");
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

    return Scaffold(
        body: _isLoading // Show loading indicator if loading
            ? const Center(
                child: CircularProgressIndicator(
                color: Colors.orange,
              ))
            : (subCategoryList.isNotEmpty
                ? SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ListView.builder(
                          padding: const EdgeInsets.all(10),
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: subCategoryList.length,
                          itemBuilder: (context, index) {
                            final subCategoryItem = subCategoryList[index];
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 5),
                              child: GestureDetector(
                                onTap: () {
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
                                child: Container(
                                  padding: const EdgeInsets.all(5),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.07),
                                        blurRadius: 8,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                    border:
                                        Border.all(color: Colors.grey.shade300),
                                  ),
                                  child: Row(
                                    children: [
                                      // Left side: Image
                                      ClipRRect(
                                        borderRadius:
                                            const BorderRadius.horizontal(
                                                left: Radius.circular(12)),
                                        child: CachedNetworkImage(
                                          imageUrl:
                                              subCategoryItem.imageBig ?? '',
                                          width: screenWidth * 0.38,
                                          height: screenWidth * 0.28,
                                          fit: BoxFit.fill,
                                          placeholder: (context, url) =>
                                              placeholderImage(),
                                          errorWidget: (context, url, error) =>
                                              const NoImageWidget(),
                                        ),
                                      ),

                                      // Right side: Details + Button
                                      Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              // Title + Bookmark icon row
                                              Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Expanded(
                                                    child: Text(
                                                      subCategoryItem.title ??
                                                          '',
                                                      maxLines: 2,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: const TextStyle(
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.w700,
                                                        color: Colors.black87,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              SizedBox(
                                                  height: screenHeight * 0.01),

                                              // Meta Info row
                                              Row(
                                                children: [
                                                  Icon(
                                                      Icons
                                                          .calendar_today_outlined,
                                                      size: 14,
                                                      color: Colors.grey[600]),
                                                  const SizedBox(width: 5),
                                                  Text(
                                                    formatDate(subCategoryItem
                                                        .createdAt
                                                        .toString()),
                                                    style: TextStyle(
                                                        fontSize: 12,
                                                        color:
                                                            Colors.grey[600]),
                                                  ),
                                                  const SizedBox(width: 10),
                                                  Icon(
                                                      Icons
                                                          .remove_red_eye_outlined,
                                                      size: 14,
                                                      color: Colors.grey[600]),
                                                  const SizedBox(width: 5),
                                                  Text(
                                                    "${subCategoryItem.hit}",
                                                    style: TextStyle(
                                                        fontSize: 12,
                                                        color:
                                                            Colors.grey[600]),
                                                  ),
                                                ],
                                              ),

                                              // Read More button aligned bottom-left
                                              SizedBox(
                                                  height: screenHeight * 0.01),
                                              Row(
                                                children: [
                                                  SizedBox(
                                                    height: 30,
                                                    child: ElevatedButton(
                                                      onPressed: () {
                                                        Navigator.push(
                                                          context,
                                                          CupertinoPageRoute(
                                                            builder: (context) =>
                                                                BlogDetailsPage(
                                                              remainingItems:
                                                                  subCategoryList,
                                                              title:
                                                                  subCategoryItem
                                                                      .titleSlug,
                                                            ),
                                                          ),
                                                        );
                                                      },
                                                      style: ElevatedButton
                                                          .styleFrom(
                                                        backgroundColor: Colors
                                                            .deepOrange
                                                            .shade700,
                                                        // padding: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                                                        shape:
                                                            RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(10),
                                                        ),
                                                      ),
                                                      child: const Row(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        children: [
                                                          Text(
                                                            "Read More",
                                                            style: TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600,
                                                                color: Colors
                                                                    .white),
                                                          ),
                                                          SizedBox(width: 8),
                                                          Icon(
                                                            Icons
                                                                .arrow_forward_ios_sharp,
                                                            size: 18,
                                                            color: Colors.white,
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                  const Spacer(),
                                                  Consumer<BlogSaveProvider>(
                                                    builder: (context,
                                                        bookmarkProvider,
                                                        child) {
                                                      final isBookmarked =
                                                          bookmarkProvider
                                                              .bookMarkedBlogs
                                                              .any(
                                                        (b) =>
                                                            b.title ==
                                                            subCategoryItem
                                                                .title,
                                                      );
                                                      return InkWell(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(30),
                                                        onTap: () =>
                                                            bookmarkProvider
                                                                .toggleBookmark(
                                                                    subCategoryItem),
                                                        child: Container(
                                                          margin:
                                                              const EdgeInsets
                                                                  .only(
                                                                  left: 8),
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(6),
                                                          decoration:
                                                              BoxDecoration(
                                                            shape:
                                                                BoxShape.circle,
                                                            color: Colors.orange
                                                                .withOpacity(
                                                                    0.15),
                                                          ),
                                                          child: Icon(
                                                            isBookmarked
                                                                ? Icons.bookmark
                                                                : Icons
                                                                    .bookmark_border,
                                                            size: 22,
                                                            color: Colors
                                                                .orange[800],
                                                          ),
                                                        ),
                                                      );
                                                    },
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  )
                : const Center(child: Text("No Data"))));
  }
}
