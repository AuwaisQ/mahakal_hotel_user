import 'dart:math';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../Controller/Bookmark Provider.dart';
import '../Controller/language_provider.dart';
import '../model/SubCategory_model.dart';
import 'BlogDetailsPage.dart';

class ViewAllBlogScreen extends StatefulWidget {
  List<BlogSubCategoryData> subCategoryData;
  ViewAllBlogScreen({super.key, required this.subCategoryData});

  @override
  State<ViewAllBlogScreen> createState() => _ViewAllBlogScreenState();
}

class _ViewAllBlogScreenState extends State<ViewAllBlogScreen> {
  List<BlogSubCategoryData> subData = [];

  @override
  void initState() {
    super.initState();
    subData = widget.subCategoryData;
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
    return Scaffold(
      appBar: AppBar(
        leading: GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: const Icon(Icons.arrow_back, color: Colors.black87, size: 25),
        ),
        title: Consumer<BlogLanguageProvider>(
          builder: (BuildContext context, languageProvider, Widget? child) {
            return Text(
              languageProvider.isEnglish ? "All Blogs" : "सभी ब्लॉग",
              style: TextStyle(
                color: Colors.deepOrange,
                fontWeight: FontWeight.bold,
                fontSize: screenWidth * 0.05,
              ),
            );
          },
        ),
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: screenHeight * 0.90, // Height for ListView
              child: ListView.builder(
                padding: EdgeInsets.zero,
                scrollDirection: Axis.vertical,
                itemCount: subData.length,
                // itemCount: widget.remainingItems.length > 10 ? 10 : widget.remainingItems.length,
                itemBuilder: (context, index) {
                  final subCategoryItem = subData[index];
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
                            remainingItems: subData,
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
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              /// -------- TITLE & IMAGE --------
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Title
                                  Expanded(
                                    child: RichText(
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 3,
                                      text: TextSpan(
                                        style: const TextStyle(
                                          fontSize: 16,
                                          height: 1.4,
                                          color: Colors.black,
                                          fontWeight: FontWeight.w600,
                                        ),
                                        children: [
                                          TextSpan(
                                            text: subCategoryItem.title
                                                    .split(' ')
                                                    .take(subCategoryItem.title
                                                            .split(' ')
                                                            .length -
                                                        1)
                                                    .join(' ') ??
                                                '',
                                            style: TextStyle(
                                                color: Colors.teal.shade700),
                                          ),
                                          TextSpan(
                                            text:
                                                ' ${subCategoryItem.title.split(' ').last}',
                                            style: const TextStyle(
                                              color: Colors.deepOrange,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),

                                  const SizedBox(width: 12),

                                  // Image
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Container(
                                      height: 100,
                                      width: 160,
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                            color: Colors.grey.shade300),
                                      ),
                                      child: CachedNetworkImage(
                                        imageUrl:
                                            subCategoryItem.imageBig ?? '',
                                        fit: BoxFit.fill,
                                        errorWidget: (context, url, error) =>
                                            const Center(
                                                child:
                                                    Icon(Icons.broken_image)),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 14),

                              /// -------- META INFO --------
                              Row(
                                children: [
                                  Icon(Icons.calendar_month_outlined,
                                      size: 16, color: Colors.grey.shade600),
                                  const SizedBox(width: 4),
                                  Text(
                                    formatDate(
                                        "${subCategoryItem.createdAt ?? ""}"),
                                    style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.grey.shade700),
                                  ),

                                  const SizedBox(width: 16),
                                  Icon(Icons.visibility_outlined,
                                      size: 16, color: Colors.grey.shade600),
                                  const SizedBox(width: 4),
                                  Text(
                                    "${subCategoryItem.hit}",
                                    style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.grey.shade700),
                                  ),

                                  // const SizedBox(width: 16),
                                  // Icon(Icons.new_releases_outlined, size: 16, color: Colors.grey.shade600),
                                  // const SizedBox(width: 4),
                                  // Text("120", style: TextStyle(fontSize: 13, color: Colors.grey.shade700)),
                                ],
                              ),
                              Divider(color: Colors.grey.shade300),

                              /// -------- ACTIONS: SAVE & SHARE --------
                              Row(
                                children: [
                                  // Share
                                  InkWell(
                                    borderRadius: BorderRadius.circular(30),
                                    onTap: () {
                                      // shareMusic.shareSong(bookMarkedBlogs[index], context);
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.all(6),
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.blue.withOpacity(0.1),
                                      ),
                                      child: const Icon(Icons.share_outlined,
                                          size: 20, color: Colors.blue),
                                    ),
                                  ),

                                  const SizedBox(width: 16),

                                  // Bookmark
                                  Consumer<BlogSaveProvider>(
                                    builder: (BuildContext context,
                                        bookmarkProvider, Widget? child) {
                                      final isBookmarked = bookmarkProvider
                                          .bookMarkedBlogs
                                          .any((bookmarked) =>
                                              bookmarked.title ==
                                              subData[index].title);

                                      return InkWell(
                                        borderRadius: BorderRadius.circular(30),
                                        onTap: () {
                                          bookmarkProvider
                                              .toggleBookmark(subData[index]);
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.all(6),
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color:
                                                Colors.orange.withOpacity(0.1),
                                          ),
                                          child: Icon(
                                            isBookmarked
                                                ? Icons.bookmark
                                                : Icons.bookmark_border,
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
                                      fontSize: screenWidth * 0.035,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.green.shade700,
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

                  //   GestureDetector(
                  //   onTap: () {
                  //     Navigator.push(
                  //       context,
                  //       CupertinoPageRoute(
                  //         builder: (context) => DetailsPage(
                  //           remainingItems: subData, title: subCategoryItem.titleSlug, imageTop: subData[index].imageBig ?? '',
                  //         ),
                  //       ),
                  //     );
                  //   },
                  //   child: Padding(
                  //     padding: EdgeInsets.symmetric(horizontal: 9,vertical: screenWidth * 0.01), // Adjusted padding
                  //     child: Container(
                  //       width: screenWidth * 0.9,
                  //       decoration: BoxDecoration(
                  //         border: Border.all(
                  //           color: Colors.transparent
                  //             //color: Color.fromRGBO(231, 231, 231, 1)
                  //         ), // Black border
                  //         borderRadius: BorderRadius.circular(5),
                  //       ),
                  //       child: Column(
                  //         crossAxisAlignment:
                  //         CrossAxisAlignment.start,
                  //         children: [
                  //
                  //           Padding(
                  //             padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.03,vertical: screenWidth * 0.02),
                  //             child: Row(
                  //                 crossAxisAlignment: CrossAxisAlignment.start,
                  //                 mainAxisAlignment: MainAxisAlignment.start,
                  //                 children: [
                  //
                  //
                  //                   SizedBox(
                  //                     width: screenWidth * 0.4,
                  //                     child: RichText(
                  //                       overflow: TextOverflow.ellipsis,
                  //                       maxLines: 3,
                  //                       text: TextSpan(
                  //                         style: TextStyle(
                  //                           fontSize: screenWidth * 0.036,
                  //                           color: Colors.black,
                  //                           fontWeight: FontWeight.bold,
                  //                         ),
                  //                         children: [
                  //                           TextSpan(
                  //                             text: subCategoryItem.title?.split(' ').take(subCategoryItem.title!.split(' ').length - 1).join(' ') ?? '',
                  //                             style: TextStyle(
                  //                                 color: randomColor1
                  //                               // color:  _isBlackBackground ? Colors.blue : Colors.red, // Color for the preceding words
                  //                             ),
                  //                           ),
                  //                           TextSpan(
                  //                             text: ' ${subCategoryItem.title?.split(' ').last} ${subCategoryItem.title?.split(' ')[subCategoryItem.title!.split(' ').length - 1]}',
                  //                             style: TextStyle(
                  //                                 color: Colors.black // Change to your desired color
                  //                             ),
                  //                           ),
                  //                         ],
                  //                       ),
                  //                     ),
                  //                   ),
                  //
                  //
                  //                   // SizedBox(
                  //                   //   width: screenWidth * 0.4,
                  //                   //   child: Text(
                  //                   //        subCategoryItem.title ?? '',
                  //                   //        overflow: TextOverflow
                  //                   //            .ellipsis, // Add this line
                  //                   //        maxLines: 3, // Add this line
                  //                   //        style: TextStyle(
                  //                   //          fontSize: screenWidth * 0.04,
                  //                   //          color:  _isBlackBackground ? Colors.white : Colors.black,
                  //                   //          fontWeight: FontWeight.bold,
                  //                   //        ),
                  //                   //      ),
                  //                   // ),
                  //
                  //                   Spacer(),
                  //
                  //                   Container(
                  //                     height: screenWidth * 0.2,
                  //                     width: screenWidth * 0.4,
                  //                     decoration: BoxDecoration(
                  //                         borderRadius: BorderRadius.circular(5),
                  //                         image: DecorationImage(
                  //                           image: CachedNetworkImageProvider(subCategoryItem.imageBig ?? ''),
                  //                           fit: BoxFit.cover,
                  //                         ),
                  //                     ),
                  //                   )
                  //                 ]
                  //             ),
                  //           ),
                  //
                  //           Padding(
                  //               padding: EdgeInsets.symmetric(
                  //                   horizontal: screenWidth * 0.02),
                  //               child: Row(
                  //                 children: [
                  //                   Icon(
                  //                     Icons.calendar_month,
                  //                     color:  Color.fromRGBO(128, 128, 128, 1),
                  //                     size: screenWidth * 0.04,
                  //                   ),
                  //                   SizedBox(
                  //                     width: screenWidth * 0.01,
                  //                   ),
                  //                   Text(
                  //                     formatDate("${subCategoryItem.createdAt ?? ""}"),
                  //                     overflow: TextOverflow.ellipsis,
                  //                     maxLines: 1,
                  //                     style: TextStyle(
                  //                       color: Color.fromRGBO(128, 128, 128, 1),
                  //                       fontWeight: FontWeight.w500,
                  //                       fontSize: screenWidth * 0.03,
                  //                     ),
                  //                   ),
                  //                   // Spacer(),
                  //                   SizedBox(width: screenWidth * 0.01,),
                  //
                  //                   Icon(Icons.new_releases_outlined,size: screenWidth * 0.04,color:  Color.fromRGBO(128, 128, 128, 1),),
                  //
                  //                   SizedBox(
                  //                     width: screenWidth * 0.01,
                  //                   ),
                  //                   Text(
                  //                     '120',
                  //                     style: TextStyle(
                  //                       color: Color.fromRGBO(128, 128, 128, 1),
                  //                       fontWeight: FontWeight.w500,
                  //                       fontSize: screenWidth * 0.03,
                  //                     ),
                  //                   ),
                  //
                  //                   SizedBox(
                  //                     width: screenWidth * 0.01,
                  //                   ),
                  //
                  //                   Icon(Icons.remove_red_eye_outlined,size: screenWidth * 0.04,
                  //                     color:  Color.fromRGBO(128, 128, 128, 1),
                  //                   ),
                  //
                  //                   SizedBox(
                  //                     width: screenWidth * 0.01,
                  //                   ),
                  //                   Text(
                  //                     "${subCategoryItem.hit}",
                  //                     style: TextStyle(
                  //                       color:  Color.fromRGBO(128, 128, 128, 1),
                  //                       fontWeight: FontWeight.w500,
                  //                       fontSize: screenWidth * 0.03,
                  //                     ),
                  //                   ),
                  //
                  //                   Spacer(),
                  //
                  //                   Consumer<BlogSaveProvider>(
                  //                     builder: (BuildContext context, bookmarkProvider, Widget? child) {
                  //                       final isBookmarked = bookmarkProvider.bookMarkedBlogs.any((bookmarked) => bookmarked.title == subData[index].title);
                  //
                  //                       return GestureDetector(
                  //                         onTap: () {
                  //                           bookmarkProvider.toggleBookmark(subData[index]);
                  //                         },
                  //                         child: Consumer<BlogLanguageProvider>(
                  //                           builder: (BuildContext context, languageProvider, Widget? child) {
                  //                             return Row(
                  //                               children: [
                  //                                 Icon(
                  //                                   isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                  //                                   size: screenWidth * 0.07,
                  //                                   color:  Color.fromRGBO(128, 128, 128, 1),
                  //
                  //                                 ),
                  //                                 Text(languageProvider.isEnglish ? "Save" : "सेव",style: TextStyle(
                  //                                   color:  Color.fromRGBO(128, 128, 128, 1),
                  //
                  //                                 ),)
                  //                               ],
                  //                             );
                  //                           },
                  //                         ),
                  //                       );
                  //                     },
                  //                   ),
                  //
                  //                   SizedBox(width: screenWidth * 0.02,),
                  //                   IconButton(
                  //                     color: Colors.transparent,
                  //                     highlightColor:
                  //                     Colors.transparent,
                  //                     icon: Consumer<BlogLanguageProvider>(
                  //                       builder: (BuildContext context, languageProvider, Widget? child) {
                  //                         return Row(
                  //                           children: [
                  //                             Icon(
                  //                               Icons.share_outlined,
                  //                               color: Color.fromRGBO(128, 128, 128, 1),
                  //                             ),
                  //                             Text(languageProvider.isEnglish ? "Share" : "शेयर",style: TextStyle(
                  //                               color:  Color.fromRGBO(128, 128, 128, 1),
                  //                             ),)
                  //                           ],
                  //                         );
                  //                       },
                  //                     ), onPressed: () {  },
                  //                     // onPressed: () {
                  //                     //   shareMusic.shareSong(
                  //                     //       widget.remainingItems[index]);
                  //                     // },
                  //                   ), //
                  //
                  //
                  //                 ],
                  //               )
                  //           ),
                  //
                  //           Divider()
                  //
                  //         ],
                  //       ),
                  //     ),
                  //   ),
                  // );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
