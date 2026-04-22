import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../../data/datasource/remote/http/httpClient.dart';
import '../../../../utill/app_constants.dart';
import '../../../../utill/flutter_toast_helper.dart';
import '../../../tour_and_travells/Controller/lanaguage_provider.dart';
import '../../model/subCategory_model.dart';
import '../event_details.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class EventMain extends StatefulWidget {
  int? categoryId;
  final ScrollController scrollController;
  EventMain({super.key, this.categoryId, required this.scrollController});

  @override
  State<EventMain> createState() => _EventMainState();
}

class _EventMainState extends State<EventMain> {
  final ScrollController _scrollController = ScrollController();

  bool isLoading = false;
  int currentPage = 1; // Current page for pagination

  // Default values
  String startDate = 'No Start Date';
  String endDate = 'No End Date';
  String fullDate = 'No Date';
  String singleDate = 'No Single Date';

  @override
  void initState() {
    super.initState();
    print('My ID is ${widget.categoryId}');
    getEventSubCategory(widget.categoryId!);
  }

  List<SubData> eventSubCategory = [];

  /// Fetch Event SubCategory
  Future<void> getEventSubCategory(int categoryId) async {
    String endpoint = AppConstants.eventSubCategoryUrl;

    Map<String, dynamic> data = {
      'category_id': [categoryId],
      'venue_data': [],
      'price': [],
      'language': [],
      'organizer': [],
      'upcoming': '1',
    };

    setState(() {
      isLoading = true;
    });

    try {
      final res = await HttpService().postApi(endpoint, data);
      print(res);

      if (res != null) {
        final subCategoryData = SubCategoryModel.fromJson(res);

        setState(() {
          eventSubCategory.addAll(subCategoryData.data ?? []);
          print('Total Length is ${eventSubCategory.length}');
          if (eventSubCategory.isNotEmpty) {
            print(
                'First item startToEndDate: ${eventSubCategory[0].startToEndDate}');
          }
        });
      }
    } catch (e) {
      print('Error fetching event subcategory: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void dateFormatter(String startToEndDate) {
    if (startToEndDate.isNotEmpty) {
      List<String> dates = startToEndDate.contains(' - ')
          ? startToEndDate.split(' - ')
          : [startToEndDate];

      final inputFormat = DateFormat('yyyy-MM-dd');
      final outputFormat = DateFormat('d MMMM yyyy'); // 10 March 2025 format

      try {
        // Start date format
        startDate = outputFormat.format(inputFormat.parse(dates[0]));

        if (dates.length > 1) {
          // End date format (if range is given)
          endDate = outputFormat.format(inputFormat.parse(dates[1]));
          fullDate = '$startDate - $endDate';
        } else {
          // Single date case
          singleDate = startDate;
          fullDate = startDate;
        }
      } catch (e) {
        print('Date Parsing Error: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    var screenwidth = MediaQuery.of(context).size.width;

    return Scaffold(
        backgroundColor: Colors.white,
        body: isLoading
            ? const Center(
                child: CircularProgressIndicator(
                color: Colors.orange,
              ))
            : (eventSubCategory.isEmpty
                ? const Center(child: Text('No Data'))
                : SafeArea(
                    child: SingleChildScrollView(
                      controller: widget.scrollController,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ListView.builder(
                                padding: EdgeInsets.symmetric(
                                    vertical: screenwidth * 0.03),
                                physics: const NeverScrollableScrollPhysics(),
                                scrollDirection: Axis.vertical,
                                shrinkWrap: true,
                                itemCount: eventSubCategory.length,
                                itemBuilder: (context, index) {
                                  final currentEvent = eventSubCategory[index];
                                  final venueData =
                                      currentEvent.allVenueData ?? [];
                                  final hasVenueData = venueData.isNotEmpty;
                                  final firstVenue =
                                      hasVenueData ? venueData[0] : null;

                                  if (!hasVenueData) {
                                    return const SizedBox.shrink();
                                  }

                                  dateFormatter(
                                      currentEvent.startToEndDate ?? '');

                                  return Consumer<LanguageProvider>(
                                    builder: (context, languageProvider, _) {
                                      return GestureDetector(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            CupertinoPageRoute(
                                              builder: (context) =>
                                                  EventDeatils(
                                                eventId: currentEvent.id,
                                              ),
                                            ),
                                          );
                                        },
                                        child: Container(
                                          margin: const EdgeInsets.symmetric(
                                            horizontal: 4,
                                            vertical: 3,
                                          ),
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black
                                                    .withOpacity(0.1),
                                                blurRadius: 10,
                                                offset: const Offset(0, 4),
                                              ),
                                            ],
                                          ),
                                          child: Card(
                                            elevation: 0,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            child: Padding(
                                              padding: EdgeInsets.all(
                                                  screenwidth * 0.03),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  // Image and Details Row
                                                  Row(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      // Event Image with Gradient Overlay
                                                      Container(
                                                        width:
                                                            screenwidth * 0.45,
                                                        height:
                                                            screenwidth * 0.29,
                                                        decoration:
                                                            BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(10),
                                                          boxShadow: [
                                                            BoxShadow(
                                                              color: Colors
                                                                  .black
                                                                  .withOpacity(
                                                                      0.1),
                                                              blurRadius: 6,
                                                              offset:
                                                                  const Offset(
                                                                      0, 3),
                                                            ),
                                                          ],
                                                        ),
                                                        child: ClipRRect(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(10),
                                                          child: Stack(
                                                            children: [
                                                              CachedNetworkImage(
                                                                  imageUrl:
                                                                      currentEvent
                                                                              .eventImage ??
                                                                          '',
                                                                  fit: BoxFit
                                                                      .fill,
                                                                  width: double
                                                                      .infinity,
                                                                  height: double
                                                                      .infinity,
                                                                  placeholder: (context,
                                                                          url) =>
                                                                      placeholderImage(),
                                                                  errorWidget: (_,
                                                                          __,
                                                                          ___) =>
                                                                      const NoImageWidget()),
                                                            ],
                                                          ),
                                                        ),
                                                      ),

                                                      SizedBox(
                                                          width: screenwidth *
                                                              0.03),

                                                      // Event Details Column
                                                      Expanded(
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            // Event Name
                                                            Text(
                                                              languageProvider
                                                                          .language ==
                                                                      'english'
                                                                  ? currentEvent
                                                                          .enEventName ??
                                                                      currentEvent
                                                                          .hiEventName ??
                                                                      'Event'
                                                                  : currentEvent
                                                                          .hiEventName ??
                                                                      currentEvent
                                                                          .enEventName ??
                                                                      'इवेंट',
                                                              style: TextStyle(
                                                                fontSize:
                                                                    screenwidth *
                                                                        0.045,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                color: Colors
                                                                    .black87,
                                                              ),
                                                              maxLines: 1,
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                            ),
                                                            SizedBox(
                                                                height:
                                                                    screenwidth *
                                                                        0.02),

                                                            // Date Row
                                                            Row(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: [
                                                                Icon(
                                                                  Icons
                                                                      .calendar_today,
                                                                  size:
                                                                      screenwidth *
                                                                          0.04,
                                                                  color: Colors
                                                                      .orange
                                                                      .shade600,
                                                                ),
                                                                SizedBox(
                                                                    width:
                                                                        screenwidth *
                                                                            0.02),
                                                                Expanded(
                                                                  child:
                                                                      RichText(
                                                                    maxLines: 1,
                                                                    overflow:
                                                                        TextOverflow
                                                                            .ellipsis,
                                                                    text:
                                                                        TextSpan(
                                                                      children: [
                                                                        TextSpan(
                                                                          text: '${currentEvent.formattedDate}' ??
                                                                              'N/A',
                                                                          style:
                                                                              TextStyle(
                                                                            color:
                                                                                Colors.grey.shade600,
                                                                            fontSize:
                                                                                screenwidth * 0.035,
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                            SizedBox(
                                                                height:
                                                                    screenwidth *
                                                                        0.015),

                                                            // Time Row
                                                            Row(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: [
                                                                Icon(
                                                                  Icons
                                                                      .access_time,
                                                                  size:
                                                                      screenwidth *
                                                                          0.04,
                                                                  color: Colors
                                                                      .orange
                                                                      .shade600,
                                                                ),
                                                                SizedBox(
                                                                    width:
                                                                        screenwidth *
                                                                            0.02),
                                                                Expanded(
                                                                  child:
                                                                      RichText(
                                                                    maxLines: 1,
                                                                    overflow:
                                                                        TextOverflow
                                                                            .ellipsis,
                                                                    text:
                                                                        TextSpan(
                                                                      children: [
                                                                        TextSpan(
                                                                          text: firstVenue?.startTime ??
                                                                              (languageProvider.language == 'english' ? 'Not specified' : 'निर्दिष्ट नहीं'),
                                                                          style:
                                                                              TextStyle(
                                                                            color:
                                                                                Colors.grey.shade600,
                                                                            fontSize:
                                                                                screenwidth * 0.035,
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                            SizedBox(
                                                                height:
                                                                    screenwidth *
                                                                        0.015),

                                                            // Venue Row
                                                            Row(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: [
                                                                Icon(
                                                                  Icons
                                                                      .location_on,
                                                                  size:
                                                                      screenwidth *
                                                                          0.04,
                                                                  color: Colors
                                                                      .orange
                                                                      .shade600,
                                                                ),
                                                                SizedBox(
                                                                    width:
                                                                        screenwidth *
                                                                            0.02),
                                                                Expanded(
                                                                  child:
                                                                      RichText(
                                                                    maxLines: 1,
                                                                    overflow:
                                                                        TextOverflow
                                                                            .ellipsis,
                                                                    text:
                                                                        TextSpan(
                                                                      children: [
                                                                        TextSpan(
                                                                          text: languageProvider.language == 'english'
                                                                              ? firstVenue?.enEventVenue ?? firstVenue?.hiEventVenue ?? (languageProvider.language == 'english' ? 'Not specified' : 'निर्दिष्ट नहीं')
                                                                              : firstVenue?.hiEventVenue ?? firstVenue?.enEventVenue ?? 'निर्दिष्ट नहीं',
                                                                          style:
                                                                              TextStyle(
                                                                            color:
                                                                                Colors.grey.shade600,
                                                                            fontSize:
                                                                                screenwidth * 0.035,
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                            //
                                                            // if (venueData.length > 1)
                                                            //   Padding(
                                                            //     padding: EdgeInsets.only(
                                                            //         top: screenwidth *
                                                            //             0.01),
                                                            //     child: Text(
                                                            //       "+ ${venueData.length - 1} ${languageProvider.language == "english" ? "more venues" : "अधिक स्थान"}",
                                                            //       style:
                                                            //           TextStyle(
                                                            //         fontSize:
                                                            //             screenwidth *
                                                            //                 0.03,
                                                            //         color: Colors
                                                            //             .blue,
                                                            //         fontStyle:
                                                            //             FontStyle
                                                            //                 .italic,
                                                            //       ),
                                                            //     ),
                                                            //   ),

                                                            Row(
                                                              children: [
                                                                ...List.generate(
                                                                    5, (index) {
                                                                  double
                                                                      rating =
                                                                      double.tryParse(
                                                                              '${currentEvent.reviewAvgStar}') ??
                                                                          0.0;
                                                                  //double rating = double.tryParse("3.0") ?? 0.0;

                                                                  if (rating >=
                                                                      index +
                                                                          1) {
                                                                    return const Icon(
                                                                        Icons
                                                                            .star,
                                                                        color: Colors
                                                                            .orange,
                                                                        size:
                                                                            22);
                                                                  } else if (rating >
                                                                          index &&
                                                                      rating <
                                                                          index +
                                                                              1) {
                                                                    return const Icon(
                                                                        Icons
                                                                            .star_half,
                                                                        color: Colors
                                                                            .orange,
                                                                        size:
                                                                            22);
                                                                  } else {
                                                                    return const Icon(
                                                                        Icons
                                                                            .star_border,
                                                                        color: Colors
                                                                            .orange,
                                                                        size:
                                                                            22);
                                                                  }
                                                                }),
                                                                const SizedBox(
                                                                    width: 6),
                                                                Text(
                                                                  "(${(double.tryParse("${currentEvent.reviewAvgStar}" ?? "0") ?? 0.0).toStringAsFixed(1)})",
                                                                  style:
                                                                      const TextStyle(
                                                                    fontSize:
                                                                        16,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    color: Colors
                                                                        .black87,
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  SizedBox(
                                                      height:
                                                          screenwidth * 0.03),

                                                  // Replace your current button section with this:
                                                  if (firstVenue?.packageList
                                                          .isNotEmpty ==
                                                      true)
                                                    Container(
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                        vertical:
                                                            screenwidth * 0.02,
                                                        horizontal:
                                                            screenwidth * 0.04,
                                                      ),
                                                      decoration: BoxDecoration(
                                                        color: Colors.deepOrange
                                                            .withOpacity(0.08),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(12),
                                                        border: Border.all(
                                                          color: Colors
                                                              .deepOrange
                                                              .shade100,
                                                          width: 1.5,
                                                        ),
                                                      ),
                                                      child: Row(
                                                        children: [
                                                          Text(
                                                            firstVenue!
                                                                        .packageList[
                                                                            0]
                                                                        .priceNo ==
                                                                    '0'
                                                                ? 'Free Event - '
                                                                : "₹ ${firstVenue!.packageList[0].priceNo ?? 'N/A'}",
                                                            style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              fontSize:
                                                                  screenwidth *
                                                                      0.04,
                                                              color: Colors
                                                                  .deepOrange
                                                                  .shade800,
                                                            ),
                                                          ),
                                                          const Spacer(),
                                                          Icon(
                                                            Icons
                                                                .event_seat_sharp,
                                                            size: screenwidth *
                                                                0.05,
                                                            color: Colors
                                                                .deepOrange
                                                                .shade400,
                                                          ),
                                                          SizedBox(
                                                              width:
                                                                  screenwidth *
                                                                      0.02),
                                                          Text(
                                                            languageProvider
                                                                        .language ==
                                                                    'english'
                                                                ? 'Book Now'
                                                                : 'अभी बुक करें',
                                                            style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              fontSize:
                                                                  screenwidth *
                                                                      0.04,
                                                              color: Colors
                                                                  .deepOrange
                                                                  .shade600,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    )
                                                  else
                                                    Container(
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                        vertical:
                                                            screenwidth * 0.02,
                                                        horizontal:
                                                            screenwidth * 0.04,
                                                      ),
                                                      decoration: BoxDecoration(
                                                        color: Colors.deepOrange
                                                            .withOpacity(0.08),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(12),
                                                        border: Border.all(
                                                          color: Colors
                                                              .deepOrange
                                                              .shade100,
                                                          width: 1.5,
                                                        ),
                                                      ),
                                                      child: Row(
                                                        children: [
                                                          Text(
                                                            languageProvider
                                                                        .language ==
                                                                    'english'
                                                                ? 'About This Event'
                                                                : 'इस कार्यक्रम के बारे में',
                                                            style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              fontSize:
                                                                  screenwidth *
                                                                      0.04,
                                                              color: Colors
                                                                  .black87,
                                                            ),
                                                          ),
                                                          const Spacer(),
                                                          Icon(
                                                            Icons
                                                                .arrow_circle_right,
                                                            size: screenwidth *
                                                                0.05,
                                                            color: Colors
                                                                .deepOrange
                                                                .shade400,
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
                                    },
                                  );
                                },
                              )
                            ],
                          ),
                        ],
                      ),
                    ),
                  )));
  }
}
