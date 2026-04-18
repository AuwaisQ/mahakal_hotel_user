import 'dart:async';
import 'package:delayed_display/delayed_display.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import '../../model/chadhavadetail_model.dart';
import '../chadhavadetails.dart';

class ChadhavaView extends StatefulWidget {
  final bool isGridList;
  final String translate;
  final List<Chadhavadetail> chadhavaList;
  final ScrollController scrollController;
  const ChadhavaView({
    super.key,
    required this.isGridList,
    required this.translate,
    required this.chadhavaList,
    required this.scrollController,
  });

  @override
  State<ChadhavaView> createState() => _ChadhavaViewState();
}

class _ChadhavaViewState extends State<ChadhavaView> {
  @override
  void initState() {
    super.initState();
    chadhavaModelList = widget.chadhavaList;
    // getChadhava();
  }

  List<Chadhavadetail> chadhavaModelList = <Chadhavadetail>[];
  String slug = "";
  String targetDays = '';
  DateTime targetDate = DateTime.now();
  Duration countdownDuration = Duration.zero;
  Timer? countdownTimer;

  // void getChadhava() async{
  //   print("start function");
  //   var res = await HttpService().getApi(AppConstants.chadhavaHomeUrl);
  //   print("print response for pooja $res");
  //   if(res["status"] == 200){
  //     setState(() {
  //       List chadhavaList = res["data"];
  //       chadhavaModelList.addAll(chadhavaList.map((e) => Chadhavadetail.fromJson(e)));
  //     });
  //   }
  // }

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
      backgroundColor: Colors.white,
      body: chadhavaModelList.isEmpty
          ? const Center(
              child: CircularProgressIndicator(
                color: Colors.orange,
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
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const BouncingScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 1,
                          childAspectRatio:
                              MediaQuery.of(context).size.aspectRatio / 0.59,
                        ),
                        itemCount: chadhavaModelList.length,
                        itemBuilder: (context, index) {
                          // DateTime now = DateTime.now();
                          // DateTime nextDate = findNextDate(now, "${chadhavaModelList[index].weekDays}");
                          // String formattedDate = formatDate(nextDate);
                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  CupertinoPageRoute(
                                    builder: (context) => ChadhavaDetailView(
                                      idNumber:
                                          "${chadhavaModelList[index].id}",
                                      // nextDatePooja:
                                      //     '${chadhavaModelList[index].nextChadhavaDate}',
                                    ),
                                  ));
                              print(
                                  "chadhava date ${chadhavaModelList[index].nextChadhavaDate}");
                            },
                            child: Container(
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
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                        ),
                                      ),
                                      ClipRRect(
                                        borderRadius: const BorderRadius.only(
                                            topLeft: Radius.circular(8.0),
                                            topRight: Radius.circular(8.0)),
                                        child: Image.network(
                                          chadhavaModelList[index].thumbnail,
                                          fit: BoxFit.cover,
                                          width: double.infinity,
                                          height:
                                              230.0, // Set appropriate height
                                          loadingBuilder: (BuildContext context,
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
                                                      color: Colors.white,
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
                                        Text(
                                          " ✤ ${widget.translate == 'en' ? chadhavaModelList[index].enName : chadhavaModelList[index].hiName}",
                                          style: const TextStyle(
                                              fontSize: 22,
                                              fontWeight: FontWeight.bold,
                                              fontFamily: 'Roboto',
                                              color: Colors.black,
                                              overflow: TextOverflow.ellipsis),
                                          maxLines: 1,
                                        ),
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
                                        const SizedBox(
                                          height: 5,
                                        ),
                                        Text(
                                          widget.translate == 'en'
                                              ? chadhavaModelList[index]
                                                  .enShortDetails
                                              : chadhavaModelList[index]
                                                  .hiShortDetails,
                                          style: const TextStyle(
                                              fontSize: 16,
                                              fontFamily: 'Roboto',
                                              color: Colors.black87,
                                              overflow: TextOverflow.ellipsis),
                                          maxLines: 2,
                                        ),
                                        const SizedBox(
                                          height: 5,
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
                                                widget.translate == 'en'
                                                    ? chadhavaModelList[index]
                                                        .enChadhavaVenue
                                                    : chadhavaModelList[index]
                                                        .hiChadhavaVenue,
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
                                            const Icon(
                                              Icons.calendar_month,
                                              size: 18,
                                              color: Colors.orange,
                                            ),
                                            const SizedBox(
                                              width: 6,
                                            ),
                                            Text(
                                              chadhavaModelList[index]
                                                          .nextChadhavaDate !=
                                                      null
                                                  ? DateFormat('dd-MMMM-yyyy')
                                                      .format(DateFormat(
                                                              'yyyy-MM-dd')
                                                          .parse(
                                                              "${chadhavaModelList[index].nextChadhavaDate}"))
                                                  : 'Date not available',
                                              style: const TextStyle(
                                                  fontSize: 17,
                                                  fontFamily: 'Roboto',
                                                  color: Colors.black),
                                            ),
                                          ],
                                        ),
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
                            ),
                          );
                        },
                      )
                    else
                      ListView.builder(
                        itemCount: chadhavaModelList.length,
                        physics: const BouncingScrollPhysics(),
                        shrinkWrap: true,
                        itemBuilder: (context, index) {
                          // DateTime now = DateTime.now();
                          // DateTime nextDate = findNextDate(now, "${chadhavaModelList[index].weekDays}");
                          // String formattedDate = formatDate(nextDate);
                          return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    CupertinoPageRoute(
                                      builder: (context) => ChadhavaDetailView(
                                        idNumber:
                                            "${chadhavaModelList[index].id}",
                                        // nextDatePooja:
                                        //     '${chadhavaModelList[index].nextChadhavaDate}',
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
                                                    chadhavaModelList[index]
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
                                                ? chadhavaModelList[index]
                                                    .enName
                                                : chadhavaModelList[index]
                                                    .hiName,
                                            style: const TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold,
                                                fontFamily: 'Roboto',
                                                color: Colors.black,
                                                overflow:
                                                    TextOverflow.ellipsis),
                                            maxLines: 1,
                                          ),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              const Expanded(
                                                  flex: 0,
                                                  child: Icon(
                                                    Icons.temple_buddhist,
                                                    size: 18,
                                                    color: Colors.orange,
                                                  )),
                                              const SizedBox(
                                                width: 6,
                                              ),
                                              Expanded(
                                                child: Text(
                                                  widget.translate == 'en'
                                                      ? chadhavaModelList[index]
                                                          .enChadhavaVenue
                                                      : chadhavaModelList[index]
                                                          .hiChadhavaVenue,
                                                  style: const TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      fontFamily: 'Roboto',
                                                      color: Colors.black),
                                                  maxLines: 1,
                                                ),
                                              ),
                                            ],
                                          ),
                                          Row(
                                            children: [
                                              const Icon(
                                                Icons.calendar_month,
                                                size: 18,
                                                color: Colors.orange,
                                              ),
                                              const SizedBox(
                                                width: 6,
                                              ),
                                              Text(
                                                chadhavaModelList[index]
                                                            .nextChadhavaDate !=
                                                        null
                                                    ? DateFormat('dd-MMMM-yyyy')
                                                        .format(DateFormat(
                                                                'yyyy-MM-dd')
                                                            .parse(
                                                                "${chadhavaModelList[index].nextChadhavaDate}"))
                                                    : 'Date not available',
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
