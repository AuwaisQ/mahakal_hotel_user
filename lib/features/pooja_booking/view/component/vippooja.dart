import 'dart:async';

import 'package:delayed_display/delayed_display.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mahakal/features/pooja_booking/view/vipdetails.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';

import '../../model/homepage_model.dart';

class VipPoojaView extends StatefulWidget {
  final bool isGridList;
  final String translate;
  final List<Subcategory> vipModelList;
  final ScrollController scrollController;
  const VipPoojaView({
    super.key,
    required this.isGridList,
    required this.translate,
    required this.vipModelList,
    required this.scrollController,
  });

  @override
  State<VipPoojaView> createState() => _VipPoojaViewState();
}

class _VipPoojaViewState extends State<VipPoojaView> {
  @override
  void initState() {
    super.initState();
    vipPoojaModelList = widget.vipModelList;
    // getVipPooja();
  }

  List<Subcategory> vipPoojaModelList = <Subcategory>[];
  String slug = "";
  String targetDays = '';
  DateTime targetDate = DateTime.now();
  Duration countdownDuration = Duration.zero;
  Timer? countdownTimer;

  // void getVipPooja() async{
  //   print("start function");
  //   var res = await HttpService().getApi(AppConstants.vipHomeUrl);
  //   print("print response for pooja $res");
  //   if(res["status"] == 200){
  //     setState(() {
  //       List vipList = res["data"];
  //       vipPoojaModelList.addAll(vipList.map((e) => Subcategory.fromJson(e)));
  //     });
  //   }
  // }

  // Helper function outside your widget
  String _getFormattedDate(String? dateString, String language) {
    if (dateString == null || dateString.isEmpty) {
      return language == "en"
          ? "You can choose puja date"
          : "आप पूजा की तिथि चुन सकते हैं";
    }

    try {
      final date = DateFormat('yyyy-MM-dd').parse(dateString);
      return DateFormat('dd-MMMM-yyyy').format(date);
    } catch (e) {
      // If parsing fails, return the default text
      return language == "en"
          ? "You can choose puja date"
          : "आप पूजा की तिथि चुन सकते हैं";
    }
  }

  // Function to format a DateTime into a string
  String formatDate(DateTime date) {
    final DateFormat formatter =
        DateFormat('dd-MMMM-yyyy'); // Adjust format as needed
    return formatter.format(date);
  }

  DateTime findNextDate(DateTime startDate, String weekDays) {
    // Convert the comma-separated weekDays string into a List<String>
    List<String> weekDayStrings = weekDays.split(',');

    // Convert the List<String> into a List<int>
    List<int> weekDayNumbers =
        weekDayStrings.map((day) => dayToNumber(day)).toList();

    for (int i = 1; i <= 7; i++) {
      DateTime nextDate = startDate.add(Duration(days: i));
      if (weekDayNumbers.contains(nextDate.weekday)) {
        return nextDate;
      }
    }

    // In case of an error (which shouldn't happen)
    return startDate;
  }

// Convert day string to weekday number
  int dayToNumber(String day) {
    switch (day.trim()) {
      case "Monday":
        return 1;
      case "Tuesday":
        return 2;
      case "Wednesday":
        return 3;
      case "Thursday":
        return 4;
      case "Friday":
        return 5;
      case "Saturday":
        return 6;
      case "Sunday":
        return 7;
      default:
        throw ArgumentError("Invalid day: $day");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: vipPoojaModelList.isEmpty
          ? Center(
            child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 12,
                spreadRadius: 2,
                offset: Offset(0, 4),
              ),
            ],
                    ),
                    child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.hourglass_empty_rounded,
                size: 60,
                color: Colors.orange,
              ),
              SizedBox(height: 15),
              Text(
                'Coming Soon',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange,
                ),
              ),
              SizedBox(height: 6),
              Text(
                'Pooja details will be available soon.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black54,
                ),
              ),
            ],
                    ),
                  ),
          )
          : DelayedDisplay(
              child: SingleChildScrollView(
                controller: widget.scrollController,
                child: Column(
                  children: [
                    const SizedBox(
                      height: 10,
                    ),
                    if (widget.isGridList)
                      ListView.builder(
                        itemCount: vipPoojaModelList.length,
                        physics: const BouncingScrollPhysics(),
                        shrinkWrap: true,
                        itemBuilder: (context, index) {
                          // DateTime now = DateTime.now();
                          // DateTime nextDate = findNextDate(now, "${vipPoojaModelList[index].weekDays}");
                          // String formattedDate = formatDate(nextDate);
                          return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    CupertinoPageRoute(
                                      builder: (context) => VipDetails(
                                        idNumber: vipPoojaModelList[index].slug,
                                        typePooja: 'vip',
                                      ),
                                    ));
                              },
                              child: Container(
                                height: 500,
                                margin: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(10),
                                    boxShadow: const [
                                      BoxShadow(
                                          color: Colors.grey,
                                          spreadRadius: 0.5,
                                          blurRadius: 1.5,
                                          offset: Offset(0, 0.5))
                                    ]),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Stack(
                                      children: [
                                        Shimmer.fromColors(
                                          baseColor: Colors.grey[300]!,
                                          highlightColor: Colors.grey[100]!,
                                          child: Container(
                                            width: double.infinity,
                                            height:
                                                230.0, // Set appropriate height
                                            decoration: const BoxDecoration(
                                              borderRadius: BorderRadius.only(
                                                  topLeft: Radius.circular(8.0),
                                                  topRight:
                                                      Radius.circular(8.0)),
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                        ClipRRect(
                                          borderRadius: const BorderRadius.only(
                                              topLeft: Radius.circular(8.0),
                                              topRight: Radius.circular(8.0)),
                                          child: Image.network(
                                            vipPoojaModelList[index].thumbnail,
                                            fit: BoxFit.fill,
                                            width: double.infinity,
                                            height:
                                                230.0, // Set appropriate height
                                            loadingBuilder:
                                                (BuildContext context,
                                                    Widget child,
                                                    ImageChunkEvent?
                                                        loadingProgress) {
                                              if (loadingProgress == null) {
                                                // Once the image is fully loaded, stop the shimmer effect
                                                return child;
                                              } else {
                                                // Continue showing shimmer while loading
                                                return Stack(
                                                  children: [
                                                    Shimmer.fromColors(
                                                      baseColor:
                                                          Colors.grey[300]!,
                                                      highlightColor:
                                                          Colors.grey[100]!,
                                                      child: Container(
                                                        width: double.infinity,
                                                        height: 230.0,
                                                        decoration:
                                                            BoxDecoration(
                                                          color: Colors.white,
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(10),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                );
                                              }
                                            },
                                            errorBuilder:
                                                (context, error, stackTrace) {
                                              // Show an error widget in case the image fails to load
                                              return const Center(
                                                child: Icon(Icons.error,
                                                    color: Colors.red),
                                              );
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(10.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Center(
                                              child: Text(
                                            widget.translate == "en"
                                                ? vipPoojaModelList[index]
                                                    .enPoojaHeading
                                                : vipPoojaModelList[index]
                                                    .hiPoojaHeading,
                                            style: const TextStyle(
                                                fontSize: 20,
                                                fontFamily: 'Roboto',
                                                color: Colors.orange,
                                                overflow:
                                                    TextOverflow.ellipsis),
                                            maxLines: 1,
                                          )),
                                          Container(
                                            margin: const EdgeInsets.symmetric(
                                                vertical: 4),
                                            height: 2,
                                            width: double.infinity,
                                            decoration: const BoxDecoration(
                                              gradient: LinearGradient(
                                                colors: [
                                                  Colors.yellow, // Start color
                                                  Colors.red, // Start color
                                                  Colors.yellow, // End color
                                                ],
                                                begin: Alignment
                                                    .topLeft, // Starting point of the gradient
                                                end: Alignment
                                                    .bottomRight, // Ending point of the gradient
                                              ),
                                            ),
                                          ),
                                          Text(
                                            " ✤ ${widget.translate == "en" ? vipPoojaModelList[index].enName : vipPoojaModelList[index].hiName}",
                                            style: const TextStyle(
                                                fontSize: 22,
                                                fontWeight: FontWeight.bold,
                                                fontFamily: 'Roboto',
                                                color: Colors.black,
                                                overflow:
                                                    TextOverflow.ellipsis),
                                            maxLines: 1,
                                          ),
                                          const SizedBox(
                                            height: 6,
                                          ),
                                          Text(
                                            widget.translate == "en"
                                                ? vipPoojaModelList[index]
                                                    .enShortBenifits
                                                : vipPoojaModelList[index]
                                                    .hiShortBenifits,
                                            style: const TextStyle(
                                                fontSize: 16,
                                                fontFamily: 'Roboto',
                                                color: Colors.black87,
                                                overflow:
                                                    TextOverflow.ellipsis),
                                            maxLines: 2,
                                          ),

                                          const SizedBox(
                                            height: 6,
                                          ),
                                          Row(
                                            children: [
                                              const Expanded(
                                                  flex: 0,
                                                  child: Icon(
                                                    Icons.location_pin,
                                                    size: 18,
                                                    color: Colors.orange,
                                                  )),
                                              const SizedBox(
                                                width: 6,
                                              ),
                                              Expanded(
                                                child: Text(
                                                  widget.translate == "en"
                                                      ? "Updated soon"
                                                      : "जल्द ही अपडेट किया जाएगा",
                                                  style: const TextStyle(
                                                      fontSize: 17,
                                                      fontFamily: 'Roboto',
                                                      color: Colors.black),
                                                  maxLines: 1,
                                                ),
                                              ),
                                            ],
                                          ),

                                          const SizedBox(
                                            height: 3,
                                          ),

                                          Row(
                                            children: [
                                              const Icon(Icons.calendar_month,
                                                  size: 18,
                                                  color: Colors.orange),
                                              const SizedBox(width: 6),
                                              Text(
                                                _getFormattedDate(
                                                    "${vipPoojaModelList[index].nextPoojaDate}",
                                                    widget.translate),
                                                style: const TextStyle(
                                                  fontSize: 17,
                                                  fontFamily: 'Roboto',
                                                  color: Colors.black,
                                                ),
                                              ),
                                            ],
                                          ),

                                          // Row(
                                          //   children: [
                                          //     const Icon(Icons.calendar_month,size: 18,color: Colors.orange,),
                                          //     const SizedBox(width: 6,),
                                          //     Text(vipPoojaModelList[index].nextPoojaDate != null
                                          //         ? DateFormat('dd-MMMM-yyyy').format(DateFormat('yyyy-MM-dd').parse("${vipPoojaModelList[index].nextPoojaDate}"))
                                          //         :  widget.translate == "en"
                                          //         ? "You can choose puja date" : "आप पूजा की तिथि चुन सकते हैं",
                                          //       style: const TextStyle(
                                          //           fontSize: 17,
                                          //           fontFamily: 'Roboto',
                                          //           color: Colors.black),
                                          //     ),
                                          //   ],
                                          // ),
                                        ],
                                      ),
                                    ),
                                    const Spacer(),
                                    Container(
                                      height: 45,
                                      decoration: const BoxDecoration(
                                        borderRadius: BorderRadius.only(
                                            bottomLeft: Radius.circular(8.0),
                                            bottomRight: Radius.circular(8.0)),
                                        gradient: LinearGradient(
                                          colors: [
                                            Colors.orange, // Start color
                                            Colors.red, // Start color
                                            Colors.orange, // End color
                                          ],
                                          begin: Alignment
                                              .topLeft, // Starting point of the gradient
                                          end: Alignment
                                              .bottomRight, // Ending point of the gradient
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            widget.translate == "en"
                                                ? "Book now"
                                                : "बुक करें",
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
                                                letterSpacing: 1,
                                                fontSize: 16),
                                          ),
                                          const SizedBox(
                                            width: 6,
                                          ),
                                          const Icon(
                                            Icons.arrow_circle_right,
                                            color: Colors.white,
                                          ),
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                              ));
                        },
                      )
                    else
                      ListView.builder(
                        itemCount: vipPoojaModelList.length,
                        physics: const BouncingScrollPhysics(),
                        shrinkWrap: true,
                        itemBuilder: (context, index) {
                          // DateTime now = DateTime.now();
                          // DateTime nextDate = findNextDate(now, "${vipPoojaModelList[index].weekDays}");
                          // String formattedDate = formatDate(nextDate);
                          return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    CupertinoPageRoute(
                                      builder: (context) => VipDetails(
                                        idNumber: vipPoojaModelList[index].slug,
                                        typePooja: 'vip',
                                      ),
                                    ));
                              },
                              child: Container(
                                padding: const EdgeInsets.all(5),
                                margin: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 5),
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                        color: Colors.grey.shade300,
                                        width: 1.5)),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      flex: 0,
                                      child: Container(
                                        height: 80,
                                        width: 120,
                                        decoration: BoxDecoration(
                                            color: Colors.grey.shade300,
                                            borderRadius:
                                                BorderRadius.circular(6),
                                            image: DecorationImage(
                                                image: NetworkImage(
                                                    vipPoojaModelList[index]
                                                        .thumbnail),
                                                fit: BoxFit.fill)),
                                      ),
                                    ),
                                    const SizedBox(
                                      width: 10,
                                    ),
                                    Expanded(
                                      flex: 1,
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            widget.translate == 'en'
                                                ? vipPoojaModelList[index]
                                                    .enName
                                                : vipPoojaModelList[index]
                                                    .hiName,
                                            style: const TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold,
                                                fontFamily: 'Roboto',
                                                color: Colors.black,
                                                overflow:
                                                    TextOverflow.ellipsis),
                                            maxLines: 2,
                                          ),
                                          Row(
                                            children: [
                                              const Icon(
                                                Icons.temple_buddhist,
                                                size: 18,
                                                color: Colors.orange,
                                              ),
                                              const SizedBox(
                                                width: 6,
                                              ),
                                              Text(
                                                widget.translate == "en"
                                                    ? "Updated soon"
                                                    : "जल्द ही अपडेट किया जाएगा",
                                                style: const TextStyle(
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.bold,
                                                    fontFamily: 'Roboto',
                                                    color: Colors.black),
                                              ),
                                              const Spacer(),
                                              Container(
                                                padding:
                                                    const EdgeInsets.all(1),
                                                decoration: const BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  color: Colors.deepOrange,
                                                ),
                                                child: const Icon(
                                                  Icons.arrow_circle_right,
                                                  color: Colors.white,
                                                  size: 20,
                                                ),
                                              )
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ));
                        },
                      ),
                  ],
                ),
              ),
            ),
    );
  }
}
