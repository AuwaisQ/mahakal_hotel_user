import 'dart:math';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../Controller/Bookmark Provider.dart';
import '../Controller/language_provider.dart';
import 'BlogDetailsPage.dart';
import 'BlogHomePage.dart';

class BlogBookmarkScreen extends StatefulWidget {
  const BlogBookmarkScreen({super.key});

  @override
  State<BlogBookmarkScreen> createState() => _BlogBookmarkScreenState();
}

class _BlogBookmarkScreenState extends State<BlogBookmarkScreen> {
  @override
  void initState() {
    super.initState();
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

  @override
  Widget build(BuildContext context) {
    var screenHeight = MediaQuery.of(context).size.height;
    var screenWidth = MediaQuery.of(context).size.width;
    return Consumer<BlogSaveProvider>(
      builder: (BuildContext context, bookmarkProvider, Widget? child) {
        return Scaffold(
          appBar: AppBar(
            leading: GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
              child:
                  const Icon(Icons.arrow_back, color: Colors.black87, size: 25),
            ),
            title: Consumer<BlogLanguageProvider>(
              builder: (BuildContext context, languageProvider, Widget? child) {
                return Text(
                  languageProvider.isEnglish
                      ? "Bookmarked Blogs"
                      : "बुकमार्क किए गए ब्लॉग",
                  style: TextStyle(
                    color: Colors.deepOrange,
                    fontWeight: FontWeight.bold,
                    fontSize: screenWidth * 0.05,
                  ),
                );
              },
            ),
          ),
          body: bookmarkProvider.bookMarkedBlogs.isEmpty
              ? Column(
                  children: [
                    SizedBox(
                      height: screenWidth * 0.2,
                    ),
                    Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: screenWidth * 0.1),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.grey),
                        ),
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            vertical: screenWidth * 0.05,
                          ),
                          child: Consumer<BlogLanguageProvider>(
                            builder: (BuildContext context, languageProvider,
                                Widget? child) {
                              return Column(
                                children: [
                                  SizedBox(
                                    height: screenWidth * 0.03,
                                  ),
                                  Container(
                                    height: 100,
                                    width: 100,
                                    decoration: const BoxDecoration(
                                      image: DecorationImage(
                                        image: CachedNetworkImageProvider(
                                            "https://i2.pngimg.me/thumb/f/720/m2i8A0d3d3N4m2b1.jpg"),
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    height: screenWidth * 0.02,
                                  ),
                                  Padding(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: screenWidth * 0.14),
                                    child: Text(
                                      languageProvider.isEnglish
                                          ? "You haven't liked any blogs yet!"
                                          : "आपने अभी तक कोई ब्लॉग पसंद नहीं किया है!",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          fontSize: screenWidth * 0.04,
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  SizedBox(
                                    height: screenWidth * 0.05,
                                  ),
                                  Padding(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: screenWidth * 0.06),
                                    child: Text(
                                      languageProvider.isEnglish
                                          ? "Please go to the blogs collection and list your favorite music!"
                                          : "कृपाया ब्लॉग संग्रह में जाए और अपने पसंदीदा ब्लॉग की सूची बनाएं!",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: screenWidth * 0.04,
                                        color: Colors.black.withOpacity(0.5),
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    height: screenWidth * 0.02,
                                  ),
                                  Padding(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: screenWidth * 0.2),
                                    child: GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                            context,
                                            CupertinoPageRoute(
                                              builder: (context) =>
                                                  const BlogHomePage(),
                                            ));
                                      },
                                      child: Container(
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(20),
                                            border:
                                                Border.all(color: Colors.grey)),
                                        child: Padding(
                                          padding: EdgeInsets.symmetric(
                                              vertical: screenWidth * 0.02,
                                              horizontal: screenWidth * 0.03),
                                          child: Consumer<BlogLanguageProvider>(
                                            builder: (BuildContext context,
                                                languageProvider,
                                                Widget? child) {
                                              return Row(
                                                children: [
                                                  const Icon(
                                                    Icons.add_box_outlined,
                                                    color: CupertinoColors
                                                        .activeBlue,
                                                  ),
                                                  SizedBox(
                                                    width: screenWidth * 0.03,
                                                  ),
                                                  Text(
                                                      languageProvider.isEnglish
                                                          ? "like Blog"
                                                          : "ब्लॉग पसंद करे"
                                                      // languageManager.selectedLanguage == 'English' ? "like Music" : "ब्लॉग पसंद करे"
                                                      ,
                                                      style: const TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: CupertinoColors
                                                              .activeBlue))
                                                ],
                                              );
                                            },
                                          ),
                                        ),
                                      ),
                                    ),
                                  )
                                ],
                              );
                            },
                          ),
                        ),
                      ),
                    )
                  ],
                )
              : SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: screenHeight * 0.90, // Height for ListView
                        child: Consumer<BlogSaveProvider>(
                          builder: (BuildContext context, bookmarkProvider,
                              Widget? child) {
                            return ListView.builder(
                              padding: EdgeInsets.zero,
                              scrollDirection: Axis.vertical,
                              itemCount:
                                  bookmarkProvider.bookMarkedBlogs.length,
                              itemBuilder: (context, index) {
                                final subCategoryItem =
                                    bookmarkProvider.bookMarkedBlogs[index];
                                // final isBookmarked = bookmarkedIds.contains(subCategoryItem.id); // Check if item is bookmarked

                                final randomColor1 =
                                    _getRandomColor(); // Color for preceding words
                                final randomColor2 = _getRandomColor();

                                return GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      CupertinoPageRoute(
                                        builder: (context) => BlogDetailsPage(
                                          remainingItems: const [],
                                          title: subCategoryItem.titleSlug,
                                        ),
                                      ),
                                    );
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 10),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(16),
                                        boxShadow: const [
                                          BoxShadow(
                                            color: Colors.black12,
                                            blurRadius: 10,
                                            offset: Offset(0, 4),
                                          ),
                                        ],
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(16),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            /// -------- TITLE & IMAGE --------
                                            Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                // Title
                                                Expanded(
                                                  child: RichText(
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    maxLines: 3,
                                                    text: TextSpan(
                                                      style: const TextStyle(
                                                        fontSize: 16,
                                                        height: 1.4,
                                                        color: Colors.black,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                      ),
                                                      children: [
                                                        TextSpan(
                                                          //bookmarkProvider.bookMarkedBlogs[index].title ?.split(' ').take(bookmarkProvider.bookMarkedBlogs[index].title!.split(' ').length - 1).join(' ') ?? '',
                                                          text: subCategoryItem
                                                                  .title
                                                                  .split(' ')
                                                                  .take(subCategoryItem
                                                                          .title
                                                                          .split(
                                                                              ' ')
                                                                          .length -
                                                                      1)
                                                                  .join(' ') ??
                                                              '',
                                                          style: TextStyle(
                                                              color: Colors.teal
                                                                  .shade700),
                                                        ),
                                                        TextSpan(
                                                          text:
                                                              ' ${subCategoryItem.title.split(' ').last}',
                                                          style:
                                                              const TextStyle(
                                                            color: Colors
                                                                .deepOrange,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(width: 12),

                                                // Image
                                                ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                  child: Container(
                                                    height: 100,
                                                    width: 160,
                                                    decoration: BoxDecoration(
                                                      border: Border.all(
                                                          color: Colors
                                                              .grey.shade300),
                                                    ),
                                                    child: CachedNetworkImage(
                                                      imageUrl: subCategoryItem
                                                              .imageBig ??
                                                          '',
                                                      fit: BoxFit.fill,
                                                      errorWidget: (context,
                                                              url, error) =>
                                                          const Center(
                                                              child: Icon(Icons
                                                                  .broken_image)),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 14),

                                            /// -------- META INFO --------
                                            Row(
                                              children: [
                                                Icon(
                                                    Icons
                                                        .calendar_month_outlined,
                                                    size: 16,
                                                    color:
                                                        Colors.grey.shade600),
                                                const SizedBox(width: 4),
                                                Text(
                                                  formatDate(
                                                      "${subCategoryItem.createdAt ?? ""}"),
                                                  style: TextStyle(
                                                      fontSize: 13,
                                                      color:
                                                          Colors.grey.shade700),
                                                ),

                                                const SizedBox(width: 16),
                                                Icon(Icons.visibility_outlined,
                                                    size: 16,
                                                    color:
                                                        Colors.grey.shade600),
                                                const SizedBox(width: 4),
                                                Text(
                                                  "${subCategoryItem.hit}",
                                                  style: TextStyle(
                                                      fontSize: 13,
                                                      color:
                                                          Colors.grey.shade700),
                                                ),

                                                // const SizedBox(width: 16),
                                                // Icon(Icons.new_releases_outlined, size: 16, color: Colors.grey.shade600),
                                                // const SizedBox(width: 4),
                                                // Text("120", style: TextStyle(fontSize: 13, color: Colors.grey.shade700)),
                                              ],
                                            ),
                                            Divider(
                                                color: Colors.grey.shade300),

                                            /// -------- ACTIONS: SAVE & SHARE --------
                                            Row(
                                              children: [
                                                // Share
                                                InkWell(
                                                  borderRadius:
                                                      BorderRadius.circular(30),
                                                  onTap: () {
                                                    // shareMusic.shareSong(bookMarkedBlogs[index], context);
                                                  },
                                                  child: Container(
                                                    padding:
                                                        const EdgeInsets.all(6),
                                                    decoration: BoxDecoration(
                                                      shape: BoxShape.circle,
                                                      color: Colors.blue
                                                          .withOpacity(0.1),
                                                    ),
                                                    child: const Icon(
                                                        Icons.share_outlined,
                                                        size: 20,
                                                        color: Colors.blue),
                                                  ),
                                                ),

                                                const SizedBox(width: 16),

                                                // Bookmark
                                                Consumer<BlogSaveProvider>(
                                                  builder:
                                                      (BuildContext context,
                                                          bookmarkProvider,
                                                          Widget? child) {
                                                    final isBookmarked =
                                                        bookmarkProvider
                                                            .bookMarkedBlogs
                                                            .any((bookmarked) =>
                                                                bookmarked
                                                                    .title ==
                                                                bookmarkProvider
                                                                    .bookMarkedBlogs[
                                                                        index]
                                                                    .title);
                                                    return InkWell(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              30),
                                                      onTap: () {
                                                        bookmarkProvider
                                                            .toggleBookmark(
                                                                bookmarkProvider
                                                                        .bookMarkedBlogs[
                                                                    index]);
                                                      },
                                                      child: Container(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(6),
                                                        decoration:
                                                            BoxDecoration(
                                                          shape:
                                                              BoxShape.circle,
                                                          color: Colors.orange
                                                              .withOpacity(0.1),
                                                        ),
                                                        child: Icon(
                                                          isBookmarked
                                                              ? Icons.bookmark
                                                              : Icons
                                                                  .bookmark_border,
                                                          size: 20,
                                                          color: Colors.orange,
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                ),

                                                const Spacer(),

                                                // Optional: Add a small label like "Read More →"
                                                Text(
                                                  "Read More →",
                                                  style: TextStyle(
                                                    fontSize:
                                                        screenWidth * 0.035,
                                                    fontWeight: FontWeight.w500,
                                                    color:
                                                        Colors.green.shade700,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
        );
      },
    );
  }
}
