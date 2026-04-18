import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mahakal/features/blogs_module/no_image_widget.dart';
import 'package:mahakal/features/donation/controller/lanaguage_provider.dart';
import 'package:mahakal/features/event_booking/model/subCategory_model.dart';
import 'package:mahakal/features/event_booking/view/event_details.dart';
import 'package:mahakal/features/event_booking/view/home_page/event_home.dart';
import 'package:page_animation_transition/animations/right_to_left_transition.dart';
import 'package:page_animation_transition/page_animation_transition.dart';
import 'package:provider/provider.dart';
import '../../../localization/language_constrants.dart';
import '../../../utill/dimensions.dart';
import '../model/sectionmodel.dart';

class SectionUpComingEvent extends StatelessWidget {
  const SectionUpComingEvent({
    super.key,
    required this.sectionModelList,
    required this.h,
    required this.screenHeight,
    required this.nearbyEvents,
    required this.screenWidth,
  });

  final List<Sectionlist> sectionModelList;
  final double h;
  final double screenHeight;
  final List<SubData> nearbyEvents;
  final double screenWidth;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        sectionModelList[19].section.status == "true"
            ? Column(children: [
                Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(7),
                    margin: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 6.0),
                    decoration: BoxDecoration(
                        color: Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(10)),
                    child: Row(
                      children: [
                        Container(
                          height: 15,
                          width: 4,
                          decoration: BoxDecoration(
                              color: Colors.orange,
                              borderRadius: BorderRadius.circular(20)),
                        ),
                        const SizedBox(
                          width: 5,
                        ),
                        Text(
                          getTranslated('up_events', context) ?? "view All",
                          style: TextStyle(
                              fontSize: Dimensions.fontSizeLarge,
                              fontWeight: FontWeight.bold),
                        ),
                        const Spacer(),
                        InkWell(
                          onTap: () {
                            Navigator.push(
                                context,
                                PageAnimationTransition(
                                    page: const EventHome(),
                                    pageAnimationType:
                                        RightToLeftTransition()));
                          },
                          child: Text(
                            getTranslated('VIEW_ALL', context) ?? "view All",
                            style: TextStyle(
                                fontSize: Dimensions.fontSizeLarge,
                                fontWeight: FontWeight.bold,
                                color: Colors.orange),
                          ),
                        ),
                      ],
                    )),
                Padding(
                  padding: const EdgeInsets.only(left: 10, top: 3),
                  child: SizedBox(
                    height: screenHeight * 0.38, // Height for ListView
                    child: ListView.builder(
                      // padding: EdgeInsets.zero,
                      physics: const AlwaysScrollableScrollPhysics(),
                      scrollDirection: Axis.horizontal,
                      itemCount: nearbyEvents.length,
                      itemBuilder: (context, index) {
                        // Ensure the index is within bounds for eventSubCategory
                        if (index >= nearbyEvents.length) {
                          return const SizedBox.shrink();
                        }
                        // Ensure allVenueData is valid
                        var venueData = nearbyEvents[index].allVenueData;
                        if (venueData.isEmpty) {
                          return const SizedBox
                              .shrink(); // Or some placeholder widget
                        }

                        var venueLength =
                            nearbyEvents[index].allVenueData.length - 1;

                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              CupertinoPageRoute(
                                builder: (context) => EventDeatils(
                                  eventId: nearbyEvents[index].id,
                                ),
                              ),
                            );
                          },
                          child: Container(
                            margin: const EdgeInsets.all(5),
                            width: screenWidth * 0.68,
                            decoration: BoxDecoration(
                                border: Border.all(
                                    color: const Color.fromRGBO(
                                        231, 231, 231, 1)), // Black border
                                borderRadius: BorderRadius.circular(10),
                                color: Colors.white),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  width: double.infinity,
                                  height: screenHeight * 0.19,
                                  child: ClipRRect(
                                    borderRadius: const BorderRadius.only(
                                      topRight: Radius.circular(10),
                                      topLeft: Radius.circular(10),
                                    ),
                                    child: CachedNetworkImage(
                                      imageUrl: nearbyEvents[index].eventImage,
                                      fit: BoxFit.fill,
                                      errorWidget: (context, url, error) =>
                                          const NoImageWidget(),
                                    ),
                                  ),
                                ),
                                SizedBox(height: screenHeight * 0.01),
                                Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: screenWidth * 0.02),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Consumer<LanguageProvider>(
                                        builder: (BuildContext context,
                                            languageProvider, Widget? child) {
                                          return Text(
                                            languageProvider.language ==
                                                    "english"
                                                ? nearbyEvents[index]
                                                    .enEventName
                                                : nearbyEvents[index]
                                                    .hiEventName,
                                            style: TextStyle(
                                                fontSize: screenWidth * 0.05,
                                                color: Colors.black,
                                                fontWeight: FontWeight.w400,
                                                overflow:
                                                    TextOverflow.ellipsis),
                                            textAlign: TextAlign.start,
                                            maxLines: 1,
                                          );
                                        },
                                      ),
                                      Consumer<LanguageProvider>(
                                        builder: (BuildContext context,
                                            languageProvider, Widget? child) {
                                          return Text.rich(
                                            maxLines: 2,
                                            TextSpan(
                                              children: [
                                                TextSpan(
                                                  text: languageProvider
                                                              .language ==
                                                          "english"
                                                      ? "Start Date : "
                                                      : "आरंभ तिथि : ",
                                                  style: TextStyle(
                                                      color: Colors.blue,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize:
                                                          screenWidth * 0.04),
                                                ),
                                                TextSpan(
                                                  text:
                                                      DateFormat('dd MMMM yyyy')
                                                          .format(
                                                    DateTime.parse(
                                                        "${nearbyEvents[index].allVenueData[0].date}"),
                                                  ),
                                                ),
                                                TextSpan(
                                                  text:
                                                      "\n${languageProvider.language == "english" ? "Venue : " : "स्थान : "}",
                                                  style: TextStyle(
                                                      color: Colors.blue,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize:
                                                          screenWidth * 0.04),
                                                ),
                                                TextSpan(
                                                  text: languageProvider
                                                              .language ==
                                                          "english"
                                                      ? nearbyEvents[index]
                                                          .allVenueData[0]
                                                          .enEventVenue
                                                      : nearbyEvents[index]
                                                          .allVenueData[0]
                                                          .hiEventVenue,
                                                ),
                                              ],
                                            ),
                                          );
                                        },
                                      ),
                                      Divider(color: Colors.grey.shade200),
                                      Consumer<LanguageProvider>(
                                        builder: (BuildContext context,
                                            languageProvider, Widget? child) {
                                          return nearbyEvents[index]
                                                  .allVenueData[0]
                                                  .packageList
                                                  .isNotEmpty
                                              ? Row(
                                                  children: [
                                                    Text(
                                                      nearbyEvents[index]
                                                                  .allVenueData[
                                                                      0]
                                                                  .packageList[
                                                                      0]
                                                                  .priceNo ==
                                                              "0"
                                                          ? "Free"
                                                          : "₹${nearbyEvents[index].allVenueData[0].packageList[0].priceNo}.0",
                                                      style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 20,
                                                      ),
                                                    ),
                                                    const Spacer(),
                                                    Container(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          horizontal: 15,
                                                          vertical: 4),
                                                      decoration: BoxDecoration(
                                                          color:
                                                              Theme.of(context)
                                                                  .primaryColor,
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(6)),
                                                      child: Row(
                                                        children: [
                                                          Text(
                                                              getTranslated(
                                                                      'book_now',
                                                                      context) ??
                                                                  "Book Now",
                                                              style: const TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600,
                                                                  color: Colors
                                                                      .white,
                                                                  fontSize:
                                                                      17)),
                                                          const SizedBox(
                                                              width: 6),
                                                          const Icon(
                                                              Icons
                                                                  .arrow_circle_right_sharp,
                                                              color:
                                                                  Colors.white,
                                                              size: 17)
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                )
                                              : Container(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 15,
                                                      vertical: 4),
                                                  decoration: BoxDecoration(
                                                      color: Theme.of(context)
                                                          .primaryColor,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              6)),
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center,
                                                    children: [
                                                      Expanded(
                                                        child: Text(
                                                          getTranslated(
                                                                  'know_events',
                                                                  context) ??
                                                              "Know Events",
                                                          style:
                                                              const TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600,
                                                                  color: Colors
                                                                      .white,
                                                                  fontSize: 17),
                                                          maxLines: 1,
                                                        ),
                                                      ),
                                                      const SizedBox(width: 6),
                                                      const Icon(
                                                          Icons.report_rounded,
                                                          color: Colors.white,
                                                          size: 18)
                                                    ],
                                                  ),
                                                );
                                        },
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
                ),
                const SizedBox(height: 5),
              ])
            : const SizedBox.shrink(),
      ],
    );
  }
}
