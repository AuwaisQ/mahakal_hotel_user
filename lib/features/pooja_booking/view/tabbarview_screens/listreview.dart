import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../data/datasource/remote/http/httpClient.dart';
import '../../model/review_pooja_model.dart';

class PoojaReviewList extends StatefulWidget {
  final String dataUrl;
  final String translate;

  const PoojaReviewList(
      {super.key, required this.dataUrl, required this.translate});

  @override
  _PoojaReviewListState createState() => _PoojaReviewListState();
}

class _PoojaReviewListState extends State<PoojaReviewList> {
  int readAll = 2;
  double averageRating = 0.0;
  bool likeBtn = false;
  bool disLikeBtn = false;

  List<Poojareviewlist> reviewModelList = <Poojareviewlist>[];

  // void getReviewData(String name) async {
  //   try {
  //     print("name of url: $name");
  //
  //     var res = await HttpService().getApi("/api/v1/pooja/$name");
  //
  //     if (res["success"]) {
  //       setState(() {
  //         reviewModelList.clear();
  //
  //         List reviewList = res["review_summary"]["list"];
  //         reviewModelList.addAll(reviewList.map((e) => Poojareviewlist.fromJson(e)),);
  //
  //         // Calculate average rating
  //         if (reviewModelList.isNotEmpty) {
  //           double totalRating = reviewModelList
  //               .map((e) => e.rating)
  //               .reduce((a, b) => a + b)
  //               .toDouble();
  //           averageRating = totalRating / reviewModelList.length;
  //         } else {
  //             averageRating = 0.0;
  //         }
  //       });
  //       print("Review count: ${reviewModelList.length}, Average rating: $averageRating");
  //     } else {
  //       print("Error fetching review");
  //     }
  //   } catch (e) {
  //     print("Error fetching review data: $e");
  //   }
  // }

  Future<void> getReviewData(String name) async {
    try {
      print("Requesting reviews for: $name");

      var res = await HttpService().getApi("/api/v1/pooja/$name");
      print("Review API Response $res");

      // Check if response is null
      if (res == null) {
        print("API returned null response");
        setState(() {
          reviewModelList.clear();
          averageRating = 0.0;
        });
        return;
      }

      // Check if response contains 'success' field
      if (res["success"] == true) {
        // Check if review_summary exists and has list
        if (res["review_summary"] != null &&
            res["review_summary"]["list"] != null) {
          List reviewList = res["review_summary"]["list"];

          setState(() {
            reviewModelList.clear();
            reviewModelList.addAll(
                reviewList.map((e) => Poojareviewlist.fromJson(e)).toList());

            // Calculate average rating safely
            if (reviewModelList.isNotEmpty) {
              double totalRating = reviewModelList
                  .where((e) => e.rating != null) // Filter out null ratings
                  .map((e) => e.rating!)
                  .fold(0.0, (sum, rating) => sum + rating);

              averageRating = totalRating / reviewModelList.length;
            } else {
              averageRating = 0.0;
            }
          });

          print("Successfully loaded ${reviewModelList.length} reviews");
          print("Average rating: $averageRating");
        } else {
          print("Review data not found in response");
          setState(() {
            reviewModelList.clear();
            averageRating = 0.0;
          });
        }
      } else {
        print("API request not successful");
        setState(() {
          reviewModelList.clear();
          averageRating = 0.0;
        });
      }
    } catch (e) {
      print("Error fetching review data: $e");
      setState(() {
        reviewModelList.clear();
        averageRating = 0.0;
      });
      // Consider showing error to user
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(content: Text("Failed to load reviews"))
      // );
    }
  }

  String formatDateString(String dateString) {
    // Parse the input date string to a DateTime object
    DateTime parsedDate = DateTime.parse(dateString);

    // Format the DateTime object into the desired format
    String formattedDate = DateFormat('dd-MMMM-yyyy').format(parsedDate);

    return formattedDate;
  }

  @override
  void initState() {
    super.initState();
    print("Api response review ${widget.dataUrl}");
    // getReviewData(widget.dataUrl);
  }

  @override
  Widget build(BuildContext context) {
    var screenWidth = MediaQuery.of(context).size.width;
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Row(
                children: [
                  // Circular badge with icon
                  Container(
                    width: 25,
                    height: 25,
                    decoration: BoxDecoration(
                      color: Colors.orange.shade400,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.orange.withOpacity(0.3),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.rate_review_outlined,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ),

                  const SizedBox(width: 8),

                  // Headline with animated underline
                  Stack(
                    children: [
                      Text(
                        widget.translate == "en" ? "Reviews" : "रिव्यु",
                        style: TextStyle(
                          fontSize: 18,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w700,
                          color: Colors.grey[800],
                        ),
                      ),
                      Positioned(
                        bottom: -4,
                        left: 0,
                        right: 0,
                        child: Container(
                          height: 3,
                          width: 40,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(2),
                            gradient: LinearGradient(
                              colors: [
                                Colors.orange.shade400,
                                Colors.orange.shade200,
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              // Container(
              //   height: 20,
              //   width: 3,
              //   color: Colors.orange,
              // ),
              // SizedBox(width: screenWidth * 0.03),
              // Text(
              //   widget.translate == "en" ? "Reviews" : "रिव्यु",
              //   style: const TextStyle(
              //       fontSize: 16,
              //       fontFamily: 'Roboto',
              //       fontWeight: FontWeight.w700,
              //       color: Colors.black),
              // ),
              const Spacer(),
              reviewModelList.isEmpty
                  ? const SizedBox.shrink()
                  : TextButton(
                      onPressed: () {
                        showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            builder: (context) {
                              return StatefulBuilder(builder:
                                  (BuildContext context,
                                      StateSetter modalSetter) {
                                return SizedBox(
                                  height: MediaQuery.of(context).size.height,
                                  child: Padding(
                                    padding: MediaQuery.of(context).viewInsets,
                                    child: Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: SingleChildScrollView(
                                        physics: const BouncingScrollPhysics(),
                                        child: Column(
                                          children: [
                                            const SizedBox(
                                              height: 30,
                                            ),
                                            Row(
                                              children: [
                                                IconButton(
                                                    onPressed: () =>
                                                        Navigator.pop(context),
                                                    icon: const Icon(
                                                      CupertinoIcons
                                                          .chevron_back,
                                                      color: Colors.red,
                                                    )),
                                                const SizedBox(
                                                  width: 15,
                                                ),
                                                const Text("Read All Reviews"),
                                                const Spacer(),
                                              ],
                                            ),
                                            const SizedBox(
                                              height: 30,
                                            ),
                                            SingleChildScrollView(
                                              child: Column(
                                                children: [
                                                  Text(
                                                    "Based on ${reviewModelList.length} Reviews",
                                                    style: const TextStyle(
                                                        color: Color.fromRGBO(
                                                            176, 176, 176, 1),
                                                        fontSize: 15,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        fontFamily: 'Roboto'),
                                                  ),
                                                  Divider(
                                                    color: Colors.grey.shade300,
                                                  ),
                                                  ListView.builder(
                                                    physics:
                                                        const BouncingScrollPhysics(),
                                                    scrollDirection:
                                                        Axis.vertical,
                                                    shrinkWrap: true,
                                                    itemCount:
                                                        reviewModelList.length,
                                                    itemBuilder:
                                                        (context, index) {
                                                      final review =
                                                          reviewModelList[
                                                              index];
                                                      final userImage = review
                                                          .userData?.image;
                                                      final userName = review
                                                              .userData?.name ??
                                                          "Guest";

                                                      return Container(
                                                        width: double.infinity,
                                                        margin: const EdgeInsets
                                                            .only(top: 8),
                                                        padding:
                                                            const EdgeInsets
                                                                .all(16),
                                                        decoration:
                                                            BoxDecoration(
                                                          color: Colors.white,
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(12),
                                                          boxShadow: [
                                                            BoxShadow(
                                                              color: Colors.grey
                                                                  .withOpacity(
                                                                      0.1),
                                                              blurRadius: 10,
                                                              spreadRadius: 2,
                                                              offset:
                                                                  const Offset(
                                                                      0, 4),
                                                            ),
                                                          ],
                                                        ),
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            // User Info Row
                                                            Row(
                                                              children: [
                                                                Container(
                                                                  height: 50,
                                                                  width: 50,
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    shape: BoxShape
                                                                        .circle,
                                                                    border: Border.all(
                                                                        color: Colors
                                                                            .grey
                                                                            .shade200,
                                                                        width:
                                                                            1),
                                                                  ),
                                                                  child:
                                                                      ClipRRect(
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            100.0),
                                                                    child: userImage != null &&
                                                                            userImage
                                                                                .isNotEmpty
                                                                        ? CachedNetworkImage(
                                                                            imageUrl:
                                                                                userImage,
                                                                            fit:
                                                                                BoxFit.cover,
                                                                            placeholder: (context, url) =>
                                                                                Container(
                                                                              color: Colors.grey.shade100,
                                                                              child: Icon(Icons.person, color: Colors.grey.shade400),
                                                                            ),
                                                                            errorWidget: (context, url, error) =>
                                                                                Container(
                                                                              color: Colors.grey.shade100,
                                                                              child: Icon(Icons.person, color: Colors.grey.shade400),
                                                                            ),
                                                                          )
                                                                        : Icon(
                                                                            Icons
                                                                                .person,
                                                                            size:
                                                                                30,
                                                                            color:
                                                                                Colors.grey.shade400),
                                                                  ),
                                                                ),
                                                                const SizedBox(
                                                                    width: 12),
                                                                Column(
                                                                  crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .start,
                                                                  children: [
                                                                    Text(
                                                                      userName,
                                                                      style:
                                                                          const TextStyle(
                                                                        fontSize:
                                                                            16,
                                                                        fontWeight:
                                                                            FontWeight.w600,
                                                                        color: Colors
                                                                            .black87,
                                                                      ),
                                                                    ),
                                                                    const SizedBox(
                                                                        height:
                                                                            4),
                                                                    Text(
                                                                      formatDateString(
                                                                          "${review.createdAt}"),
                                                                      style: TextStyle(
                                                                          fontSize:
                                                                              12,
                                                                          color: Colors
                                                                              .grey
                                                                              .shade600),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ],
                                                            ),

                                                            const SizedBox(
                                                                height: 12),

                                                            // Rating Row
                                                            Row(
                                                              children: [
                                                                Row(
                                                                  mainAxisSize:
                                                                      MainAxisSize
                                                                          .min,
                                                                  children: List
                                                                      .generate(
                                                                    5,
                                                                    (starIndex) =>
                                                                        Icon(
                                                                      Icons
                                                                          .star,
                                                                      color: starIndex <
                                                                              (review.rating ??
                                                                                  0)
                                                                          ? Colors
                                                                              .amber
                                                                          : Colors
                                                                              .grey
                                                                              .shade300,
                                                                      size: 20,
                                                                    ),
                                                                  ),
                                                                ),
                                                                const SizedBox(
                                                                    width: 8),
                                                                Text(
                                                                  "${review.rating ?? 0}.0",
                                                                  style:
                                                                      TextStyle(
                                                                    fontSize:
                                                                        14,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w500,
                                                                    color: Colors
                                                                        .grey
                                                                        .shade700,
                                                                  ),
                                                                ),
                                                              ],
                                                            ),

                                                            const SizedBox(
                                                                height: 12),
                                                            Divider(
                                                                height: 1,
                                                                color: Colors
                                                                    .grey
                                                                    .shade200),
                                                            const SizedBox(
                                                                height: 12),

                                                            // Review Text (no Expanded here)
                                                            Text(
                                                              review.comment ??
                                                                  'No review text provided',
                                                              style: TextStyle(
                                                                fontSize: 15,
                                                                color: Colors
                                                                    .grey
                                                                    .shade800,
                                                                height: 1.4,
                                                              ),
                                                              maxLines: 4,
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                            ),
                                                          ],
                                                        ),
                                                      );
                                                    },
                                                  ),
                                                ],
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              });
                            });
                      },
                      child: const Text(
                        "See All",
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: Colors.orange,
                          fontSize: 15,
                        ),
                      ))
            ],
          ),

          Row(
            children: [
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                        text: averageRating.toStringAsFixed(1),
                        style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 35,
                            fontFamily: 'Roboto',
                            color: Color.fromRGBO(0, 0, 0, 1))),
                    const TextSpan(
                      text: '/',
                      style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 20,
                          color: Color.fromRGBO(0, 0, 0, 1)),
                    ),
                    const TextSpan(
                        text: ' 5',
                        style: TextStyle(
                            color: Color.fromRGBO(176, 176, 176, 1),
                            fontSize: 20)),
                  ],
                ),
              ),

              Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(
                  5,
                  (index) => Icon(
                    Icons.star,
                    color: index < averageRating ? Colors.amber : Colors.grey,
                    size: 25,
                  ),
                ),
              ),
              // RatingBar.builder(
              //   initialRating: averageRating,
              //   minRating: 1,
              //   direction: Axis.horizontal,
              //   allowHalfRating: true,
              //   itemCount: 5,
              //   maxRating: 5,
              //   itemPadding: EdgeInsets.symmetric(horizontal: screenWidth * 0.01),
              //   itemBuilder: (context, _) => Icon(
              //     Icons.star,
              //     color: Colors.amber,
              //   ),
              //   onRatingUpdate: (value) {
              //     setState(() {
              //       averageRating = value;
              //     });
              //   },
              // ),
            ],
          ),

          Text(
            "Based on ${reviewModelList.length} Reviews",
            style: const TextStyle(
                color: Color.fromRGBO(176, 176, 176, 1),
                fontSize: 15,
                fontWeight: FontWeight.w500,
                fontFamily: 'Roboto'),
          ),
          const SizedBox(
            height: 10,
          ),
          reviewModelList.isEmpty
              ? const SizedBox.shrink()
              : SizedBox(
                  height: 200,
                  child: ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    scrollDirection: Axis.horizontal,
                    shrinkWrap: true,
                    itemCount: reviewModelList.length,
                    itemBuilder: (context, index) {
                      final review = reviewModelList[index];
                      final userImage = review.userData?.image;
                      final userName = review.userData?.name ?? "Guest";

                      return Container(
                        width: 370,
                        margin:
                            const EdgeInsets.only(right: 16, top: 8, bottom: 8),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.1),
                              blurRadius: 10,
                              spreadRadius: 2,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // User Info Row
                            Row(
                              children: [
                                Container(
                                  height: 50,
                                  width: 50,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                        color: Colors.grey.shade200, width: 1),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(100.0),
                                    child: userImage != null &&
                                            userImage.isNotEmpty
                                        ? CachedNetworkImage(
                                            imageUrl: userImage,
                                            fit: BoxFit.cover,
                                            placeholder: (context, url) =>
                                                Container(
                                              color: Colors.grey.shade100,
                                              child: Icon(Icons.person,
                                                  color: Colors.grey.shade400),
                                            ),
                                            errorWidget:
                                                (context, url, error) =>
                                                    Container(
                                              color: Colors.grey.shade100,
                                              child: Icon(Icons.person,
                                                  color: Colors.grey.shade400),
                                            ),
                                          )
                                        : Icon(Icons.person,
                                            size: 30,
                                            color: Colors.grey.shade400),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      userName,
                                      style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.black87),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      formatDateString("${review.createdAt}"),
                                      style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey.shade600),
                                    ),
                                  ],
                                ),
                              ],
                            ),

                            const SizedBox(height: 12),

                            // Rating Row
                            Row(
                              children: [
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: List.generate(
                                    5,
                                    (starIndex) => Icon(
                                      Icons.star,
                                      color: starIndex < (review.rating ?? 0)
                                          ? Colors.amber
                                          : Colors.grey.shade300,
                                      size: 20,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  "${review.rating ?? 0}.0",
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.grey.shade700),
                                ),
                              ],
                            ),

                            const SizedBox(height: 12),
                            Divider(height: 1, color: Colors.grey.shade200),
                            const SizedBox(height: 12),

                            // Review Text
                            Expanded(
                              child: Text(
                                review.comment ?? 'No review text provided',
                                style: TextStyle(
                                  fontSize: 15,
                                  color: Colors.grey.shade800,
                                  height: 1.4,
                                ),
                                maxLines: 4,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),

          // SizedBox(
          //   height: 200,
          //   child: ListView.builder(
          //     physics: const BouncingScrollPhysics(), // Optional: Adds smooth scrolling effect
          //     scrollDirection: Axis.horizontal, // Enables horizontal scrolling
          //     shrinkWrap: true,
          //     itemCount: reviewModelList.length,
          //     itemBuilder: (context, index) {
          //       return Center(
          //         child: Container(
          //           width: 370, // Adjust width as needed
          //           margin: const EdgeInsets.only(right: 8), // Add spacing between items
          //           padding: const EdgeInsets.all(10),
          //           decoration: BoxDecoration(
          //             color: Colors.grey.shade400,
          //             borderRadius: BorderRadius.circular(8.0),
          //           ),
          //           child: Column(
          //             crossAxisAlignment: CrossAxisAlignment.start,
          //             mainAxisAlignment: MainAxisAlignment.start,
          //             children: [
          //               Row(
          //                 children: [
          //                   Container(
          //                     height: 50,
          //                     width: 50,
          //                     child: ClipRRect(
          //                       borderRadius: BorderRadius.circular(100.0),
          //                       child: reviewModelList[index].userData!.image!.isEmpty
          //                           ? Image.network("https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRCoCmZUOoQBtp5gsuviCJYjvN9w8oGtYam3w&s",fit: BoxFit.cover,)
          //                           : Image.network(reviewModelList[index].userData.image,fit: BoxFit.cover,) // Fallback icon
          //                     ),
          //                   ),
          //                   const SizedBox(width: 5),
          //                   Text(
          //                     "@${reviewModelList[index].userData!.name ?? "userName"}",
          //                     style: const TextStyle(
          //                         fontSize: 20,
          //                         fontWeight: FontWeight.bold,
          //                         color: Colors.white),
          //                   ),
          //                   // Spacer(),
          //                   // Icon(Icons.more_vert, color: Colors.white, size: 24),
          //                 ],
          //               ),
          //               const SizedBox(height: 8),
          //               Row(
          //                 children: [
          //                   Row(
          //                     mainAxisSize: MainAxisSize.min,
          //                     children: List.generate(
          //                       5,
          //                           (starIndex) => Icon(
          //                         Icons.star,
          //                         color: starIndex < reviewModelList[index].rating
          //                             ? Colors.amber
          //                             : Colors.white,
          //                         size: 22,
          //                       ),
          //                     ),
          //                   ),
          //                   const SizedBox(width: 5),
          //                   Text(
          //                     formatDateString("${reviewModelList[index].createdAt}"),
          //                     style: const TextStyle(fontSize: 15, color: Colors.blueGrey),
          //                   )
          //                 ],
          //               ),
          //               const Divider(color: Colors.grey),
          //               Text(
          //                 "${reviewModelList[index].comment}",
          //                 style: const TextStyle(
          //                     fontSize: 18,
          //                     color: Colors.black,
          //                     overflow: TextOverflow.ellipsis),
          //                 maxLines: 3,
          //               ),
          //             ],
          //           ),
          //         ),
          //       );
          //     },
          //   ),
          // ),

          const SizedBox(
            height: 10,
          ),
        ],
      ),
    );
  }
}
//
// class ReviewContainer extends StatelessWidget {
//   final int index;
//
//   ReviewContainer(this.index);
//
//   List<Reviewsitems>reviesitems = [
//
//     Reviewsitems(name: "Xyz",date: "12/042024",txt: "erebdfbhdfbhjdfbgjkbgijbgerijbgitrbgtrgibgtibgtrhbghtrbgihtrbghtrbtrhbtrhbrthnjbbjfbhgbhffbfbbfbbfbfbffbbfbbfbfbfbfbfbf",img: ""),
//     Reviewsitems(name: "Abc",date: "12/042024",txt: "erebdfbhdfbhjdfbgjkbgijbgerijbgitrbgtrgibgtibgtrhbghtrbgihtrbghtrbtrhbtrhbrthnjbbjfbhgbhffbfbbfbbfbfbffbbfbbfbfbfbf",img: ""),
//     Reviewsitems(name: "Def",date: "12/042024",txt: "erebdfbhdfbhjdfbgjkbgijbgerijbgitrbgtrgibgtibgtrhbghtrbgihtrbghtrbtrhbtrhbrthnjbbjfbhgbhffbfbbfbbfbfbffbbfbbfbfbfbf",img:""),
//     Reviewsitems(name: "Abc",date: "12/042024",txt: "erebdfbhdfbhjdfbgjkbgijbgerijbgitrbgtrgibgtibgtrhbghtrbgihtrbghtrbtrhbtrhbrthnjbbjfbhgbhffbfbbfbbfbfbffbbfbbfbfbfbf",img: ""),
//     Reviewsitems(name: "Xyz",date: "12/042024",txt: "erebdfbhdfbhjdfbgjkbgijbgerijbgitrbgtrgibgtibgtrhbghtrbgihtrbghtrbtrhbtrhbrthnjbbjfbhgbhffbfbbfbbfbfbffbbfbbfbfbfbf",img: ""),
//     Reviewsitems(name: "Abc",date: "12/042024",txt: "erebdfbhdfbhjdfbgjkbgijbgerijbgitrbgtrgibgtibgtrhbghtrbgihtrbghtrbtrhbtrhbrthnjbbjfbhgbhffbfbbfbbfbfbffbbfbbfbfbfbf",img: ""),
//
//   ];
//
//   @override
//   Widget build(BuildContext context) {
//
//     var screenWidth = MediaQuery.of(context).size.width;
//     var screenHeight = MediaQuery.of(context).size.height;
//
//     return Padding(
//       padding: EdgeInsets.symmetric(vertical: screenWidth * 0.01),
//       child: Container(
//         decoration: BoxDecoration(
//             borderRadius: BorderRadius.circular(10),
//             color: Color.fromRGBO(231, 231, 231, 1)
//         ),
//         child: Column(
//           children: [
//
//             SizedBox(height: screenWidth * 0.02,),
//             Padding(
//               padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.02),
//               child: Row(
//                 children: [
//
//                   Icon(Icons.star,size: 24,color: Colors.amber),
//                   Icon(Icons.star,size: 24,color: Colors.amber),
//                   Icon(Icons.star,size: 24,color: Colors.amber),
//                   Icon(Icons.star,size: 24,color: Colors.amber),
//                   Icon(Icons.star,size: 24,color: Colors.amber),
//                   SizedBox(width: screenWidth * 0.01,),
//                   SizedBox(width: screenWidth * 0.2,child: Text(reviesitems[index].name ?? '',style: TextStyle(fontSize: 18,fontWeight: FontWeight.w400,fontFamily: 'Roboto',color: Color.fromRGBO(0, 0, 0, 1),overflow: TextOverflow.ellipsis),)),
//                   SizedBox(width: screenWidth * 0.05,),
//                   SizedBox(width: screenWidth * 0.3,child: Text(reviesitems[index].date ?? '',style: TextStyle(fontWeight:FontWeight.w500,fontSize: 18,fontFamily: 'Roboto',color: Color.fromRGBO(0, 0, 0, 1),overflow: TextOverflow.ellipsis),))
//
//                 ],
//               ),
//             ),
//
//             SizedBox(height: screenWidth * 0.01,),
//             Padding(
//               padding:EdgeInsets.symmetric(horizontal: screenWidth * 0.02,vertical: screenWidth * 0.02),
//               child: Row(
//                 children: [
//                   Container(
//                        width: screenWidth * 0.6,
//                       decoration: BoxDecoration(
//                           color: Colors.transparent
//                       ),
//                       child: Text(reviesitems[index].txt ?? '',style: TextStyle(fontSize: 14,fontWeight: FontWeight.w400,fontFamily: 'Roboto',color: Color.fromRGBO(0, 0, 0, 1)),)),
//
//                   SizedBox(width: screenWidth * 0.04,),
//                   Container(
//                     height: screenWidth * 0.2,
//                     width: screenWidth * 0.2,
//                     decoration: BoxDecoration(
//                         borderRadius: BorderRadius.circular(10),
//                         color: Colors.white
//                     ),
//                   )
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
