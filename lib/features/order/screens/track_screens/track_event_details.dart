import 'dart:convert';
import 'dart:io';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:mahakal/utill/loading_datawidget.dart';
import 'package:page_animation_transition/animations/right_to_left_transition.dart';
import 'package:page_animation_transition/page_animation_transition.dart';
import 'package:path_provider/path_provider.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../data/datasource/remote/http/httpClient.dart';
import '../../../../main.dart';
import '../../../../utill/app_constants.dart';
import '../../../auth/controllers/auth_controller.dart';
import '../../../profile/controllers/profile_contrroller.dart';
import '../../../support/screens/support_ticket_screen.dart';
import '../../model/event_order_details_model.dart';
import 'package:http/http.dart' as http;

import '../../model/event_pass_model.dart';

class TrackEventDetails extends StatefulWidget {
  final int orderId;

  const TrackEventDetails({
    super.key,
    required this.orderId,
  });

  @override
  State<TrackEventDetails> createState() => _TrackEventDetailsState();
}

class _TrackEventDetailsState extends State<TrackEventDetails> {
  String userName = "";
  String userNumber = "";
  String userId = "";
  String userEmail = "";
  String? latitude;
  String? longitude;
  String? selectedLocation;
  String? timeHour;
  String? timeMinute;
  String userToken = "";
  int _selectedRating = 3;
  bool isLoading = true;
  int _selectedIndex = 0;

  String formatDateTime(String dateWithTime, {bool returnDate = true}) {
    List<String> parts = dateWithTime.split(" ");

    if (parts.length < 5) return "Invalid Date Format"; // Safety check

    String eventDate = "${parts[0]} ${parts[1]} ${parts[2]}"; // "29 Mar 2025"
    String eventTime = "${parts[3]} ${parts[4]}"; // "08:00 AM"

    return returnDate ? eventDate : eventTime;
  }

  final TextEditingController _suggestionsController = TextEditingController();
  List<String> options = [
    "The event coordinator was knowledgeable and provided detailed assistance throughout the booking.",
    "The booking experience was well-organized and included all necessary details about the event.",
    "The ticket booking process was smooth and easy to complete.",
    "I liked that I could select events based on my personal interests.",
    "The overall experience was hassle-free, and I received timely updates and support after booking.",
    // ... more options
  ];

  @override
  void initState() {
    print("My Event Order Id:${widget.orderId}");
    // TODO: implement initState
    super.initState();
    userId = Provider.of<ProfileController>(Get.context!, listen: false).userID;
    userName =
        Provider.of<ProfileController>(Get.context!, listen: false).userNAME;
    userNumber =
        Provider.of<ProfileController>(Get.context!, listen: false).userPHONE;
    userToken =
        Provider.of<AuthController>(Get.context!, listen: false).getUserToken();
    userEmail =
        Provider.of<ProfileController>(Get.context!, listen: false).userEMAIL;
    getEventOrderDetails();
  }

  EventOrderDetailsModel? eventOrderData;

  Future<void> getEventOrderDetails() async {
    // String url = AppConstants.baseUrl + AppConstants.eventOrderListUrl;
    Map<String, dynamic> data = {"user_id": userId, "id": widget.orderId};

    setState(() {
      isLoading = true;
    });
    try {
      final res =
          await HttpService().postApi(AppConstants.eventOrderListUrl, data);
      //final res = await ApiServiceDonate().getAdvertise(url, data);
      print("Event Order Details$res");

      if (res != null) {
        setState(() {
          eventOrderData = EventOrderDetailsModel.fromJson(res);
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print("Event Order Error$e");
    }
  }

  void _handleCheckboxChange(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void setReviewData(StateSetter modalSetter) async {
    final url = Uri.parse(AppConstants.baseUrl +
        AppConstants.addEventCommentUrl); // Replace with your API endpoint
    final Map<String, dynamic> data = {
      "user_id": userId,
      "event_id": "${eventOrderData!.data!.eventId}",
      "order_id": "${eventOrderData!.data!.id}",
      "star": _selectedRating,
      "comment": _suggestionsController.text,
      "image": ""
    };

    try {
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $userToken",
        },
        body: jsonEncode(data),
      );
      if (response.statusCode == 200) {
        modalSetter(() {
          isLoading = false;
          _suggestionsController.clear();
        });
        Navigator.pop(context);
        Fluttertoast.showToast(
            msg: "Thank you for your feedback!",
            backgroundColor: Colors.green,
            textColor: Colors.white);
      } else {
        // Handle error response
        Fluttertoast.showToast(
            msg: "Add Failed",
            backgroundColor: Colors.red,
            textColor: Colors.white);
      }
    } catch (error) {
      print('Error posting data: $error');
    }
  }

  /// review bottom sheet
  void showFeedbackBottomSheet() {
    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (context) {
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter modalSetter) {
            return SizedBox(
              height: MediaQuery.of(context).size.height,
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Container(
                  color: Colors.grey.shade100,
                  child: Column(
                    children: [
                      const SizedBox(
                        height: 30,
                      ),
                      AppBar(
                        backgroundColor: Colors.transparent,
                        centerTitle: true,
                        leading: IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(
                              CupertinoIcons.chevron_back,
                              color: Colors.red,
                            )),
                        title: const Text(
                          'Please provide your feedback',
                          style: TextStyle(
                              fontSize: 18.0, fontWeight: FontWeight.bold),
                        ),
                      ),

                      const SizedBox(
                        height: 30,
                      ),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(10),
                        decoration: const BoxDecoration(color: Colors.white),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              userName,
                              style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.orange),
                            ),
                            Text(
                              userEmail,
                              style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.blueGrey),
                            ),
                          ],
                        ),
                      ),

                      // Star Rating
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: const BoxDecoration(color: Colors.white),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "How many stars will you give us for your Tour booking on Mahakal.com",
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            Divider(
                              color: Colors.grey.shade300,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(5, (index) {
                                return IconButton(
                                  icon: Icon(
                                    index < _selectedRating
                                        ? Icons.star
                                        : Icons.star_border,
                                    color: Colors.amber,
                                    size: 40,
                                  ),
                                  onPressed: () {
                                    modalSetter(() {
                                      _selectedRating = index + 1;
                                    });
                                  },
                                );
                              }),
                            ),
                            Center(
                              child: Text(
                                _selectedRating == 1
                                    ? "Poor"
                                    : _selectedRating == 2
                                        ? "Below Average"
                                        : _selectedRating == 3
                                            ? "Average"
                                            : _selectedRating == 4
                                                ? "Good"
                                                : "Excellent",
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.amber,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Improvement Options
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: const BoxDecoration(color: Colors.white),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "What can we improve ?",
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            Column(
                              children: List.generate(options.length, (index) {
                                return CheckboxListTile(
                                  checkColor: Colors.white,
                                  activeColor: Colors.orange,
                                  title: Text(
                                    options[index],
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                  value: _selectedIndex ==
                                      index, // Key change: Compare index
                                  onChanged: (value) {
                                    if (value == true) {
                                      //Only allow selection if value is true. Prevents unchecking
                                      modalSetter(() {
                                        _handleCheckboxChange(index);
                                        _suggestionsController.text =
                                            options[index];
                                        print(
                                            "suggestion controller ${_suggestionsController.text}");
                                      });
                                    }
                                  },
                                );
                              }),
                            ),
                          ],
                        ),
                      ),

                      // Suggestions
                      const SizedBox(height: 10),
                      Container(
                        // margin: EdgeInsets.symmetric(horizontal: 10),
                        padding: const EdgeInsets.all(10),
                        decoration: const BoxDecoration(color: Colors.white),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Please provide your suggestions",
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _suggestionsController,
                              maxLines: 4,
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(
                                    borderSide:
                                        BorderSide(color: Colors.orange)),
                                enabledBorder: OutlineInputBorder(
                                    borderSide:
                                        BorderSide(color: Colors.orange)),
                                hintText: "Write here...",
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],
                        ),
                      ),

                      // Submit Button
                      isLoading
                          ? Container(
                              margin: const EdgeInsets.all(10.0),
                              padding: const EdgeInsets.all(4.0),
                              height: 45,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8.0),
                                color: Colors.orange.shade400,
                              ),
                              child: const Center(
                                  child: CircularProgressIndicator(
                                color: Colors.white,
                              )))
                          : GestureDetector(
                              onTap: () {
                                modalSetter(() {
                                  isLoading = true;
                                });
                                // Submit feedback logic
                                print("Rating: $_selectedRating");
                                // print("Improvements: ${_improvementOptions.toString()}");
                                print(
                                    "Suggestions: ${_suggestionsController.text}");
                                setReviewData(modalSetter);
                                getEventOrderDetails();
                              },
                              child: Container(
                                padding: const EdgeInsets.all(10),
                                margin: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8.0),
                                  color: Colors.orange,
                                ),
                                child: const Center(
                                  child: Text(
                                    "Submit",
                                    style: TextStyle(
                                        fontSize: 16, color: Colors.white),
                                  ),
                                ),
                              ),
                            )
                    ],
                  ),
                ),
              ),
            );
          });
        });
  }

  Future<void> downloadPass(
    String orderId,
    int index,
    List<bool> isDownloading,
    List<double> progressValues,
  ) async {
    const url = AppConstants.baseUrl + AppConstants.eventOrderPassUrl;

    try {
      setState(() {
        isDownloading[index] = true;
        progressValues[index] = 0.0;
      });

      if (Platform.isAndroid) {
        var status = await Permission.storage.request();
        if (!status.isGranted) {
          Fluttertoast.showToast(msg: "❌ Storage Permission Denied!");
          setState(() => isDownloading[index] = false);
          return;
        }
      }

      final response = await http.post(
        Uri.parse(url),
        body: jsonEncode({"order_id": orderId, "num": index + 1}),
        headers: {"Content-Type": "application/json"},
      );

      if (response.statusCode == 200) {
        Uint8List bytes = response.bodyBytes;
        Directory? directory;

        if (Platform.isAndroid) {
          directory = Directory('/storage/emulated/0/Download');
        } else {
          directory = await getApplicationDocumentsDirectory();
        }

        String filePath = "${directory.path}/event_pass_${index + 1}.png";
        File file = File(filePath);

        int totalBytes = bytes.length;
        int downloadedBytes = 0;
        const chunkSize = 4096;

        IOSink sink = file.openWrite();
        for (int i = 0; i < totalBytes; i += chunkSize) {
          int end = (i + chunkSize > totalBytes) ? totalBytes : i + chunkSize;
          sink.add(bytes.sublist(i, end));
          downloadedBytes = end;

          setState(() {
            progressValues[index] = downloadedBytes / totalBytes;
          });
          await Future.delayed(const Duration(milliseconds: 50));
        }

        await sink.close();
        Fluttertoast.showToast(
            msg: "✅ Pass Downloaded: event_pass_${index + 1}.png");
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "❌ Download Failed: $e");
      print("Error: $e");
    }

    setState(() => isDownloading[index] = false);
  }

  void showPassDownloadSheet(
      BuildContext context, String orderId, int totalMembers) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: Colors.white,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, StateSetter modalSetter) {
            List<bool> isDownloading = List.filled(totalMembers, false);
            List<double> progressValues = List.filled(totalMembers, 0.0);

            return Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "Download Your Passes",
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange),
                  ),
                  const SizedBox(height: 10),
                  ListView.builder(
                    shrinkWrap: true,
                    itemCount: totalMembers,
                    itemBuilder: (context, index) {
                      int passNumber = index + 1;
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        child: ListTile(
                          leading: const Icon(Icons.person,
                              color: Colors.blue, size: 28),
                          title: Text(
                            "Pass #$passNumber",
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w500),
                          ),
                          trailing: isDownloading[index]
                              ? CircularPercentIndicator(
                                  radius: 20.0,
                                  lineWidth: 4.0,
                                  percent: progressValues[index],
                                  center: Text(
                                      "${(progressValues[index] * 100).toInt()}%"),
                                  progressColor: Colors.green,
                                )
                              : IconButton(
                                  icon: const Icon(Icons.download,
                                      color: Colors.orange),
                                  onPressed: () async {
                                    await downloadPass(orderId, index,
                                        isDownloading, progressValues);
                                  },
                                ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 10),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Close",
                        style: TextStyle(fontSize: 16, color: Colors.red)),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? const Scaffold(
            backgroundColor: Colors.white,
            body: Center(
                child: CircularProgressIndicator(
              color: Colors.orange,
            )))
        : Scaffold(
          floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
          floatingActionButton: InkWell(
        onTap: () {
          Navigator.push(
            context,
            CupertinoPageRoute(
              builder: (context) => EventPassScreen(
                eventOrderId: '${eventOrderData?.data?.id}',
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: MediaQuery.of(context).size.width * 0.92,
          height: 60,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                Color(0xFFFF6B4A),
                Color(0xFFFF8A5C),
              ],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFFF6B4A).withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
                spreadRadius: 1,
              ),
            ],
          ),
          child: Row(
            children: [
              /// QR CODE ICON with container
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.qr_code_scanner_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),

              /// DOWNLOAD PASS TEXT
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Download Pass",
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      "Your Digital Ticket",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
              ),

              /// DOWNLOAD ICON with arrow
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.arrow_downward_rounded,
                  color: Colors.white,
                  size: 18,
                ),
              ),
            ],
          ),
        ),
      ),
            appBar: AppBar(
              backgroundColor: Colors.grey.shade50,
              title: Column(
                children: [
                  Text.rich(TextSpan(children: [
                    const TextSpan(
                        text: "Order -",
                        style: TextStyle(color: Colors.black, fontSize: 18)),
                    TextSpan(
                        text: " #${eventOrderData?.data?.orderNo}",
                        style: const TextStyle(
                            color: Colors.black,
                            fontSize: 20,
                            fontWeight: FontWeight.bold)),
                  ])),
                  const SizedBox(
                    height: 5,
                  ),
                  const Text.rich(TextSpan(children: [
                    TextSpan(
                        text: " Your Order is - ",
                        style: TextStyle(color: Colors.black, fontSize: 18)),
                    TextSpan(
                        text: "Success",
                        style: TextStyle(
                            color: Colors.green,
                            fontSize: 20,
                            fontWeight: FontWeight.bold)),
                  ])),
                  const SizedBox(
                    height: 5,
                  ),
                  Text(
                      formatDateTime("${eventOrderData?.data?.eventDate}",
                          returnDate: true),
                      style: const TextStyle(
                          fontSize: 18,
                          overflow: TextOverflow.ellipsis,
                          color: Colors.black))
                ],
              ),
              centerTitle: true,
              toolbarHeight: 100,
            ),
            body: RefreshIndicator(
              onRefresh: () async {
                //getTrackData(widget.poojaId);
              },
              color: Colors.white,
              // Progress indicator color
              backgroundColor: Colors.deepOrange,
              // Background color of the refresh indicator
              displacement: 40.0,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 20, horizontal: 10),
                      width: double.infinity,
                      decoration: const BoxDecoration(
                          image: DecorationImage(
                              image: AssetImage("assets/images/map_bg.png"),
                              fit: BoxFit.fill)),
                      child: Column(
                        children: [
                          /// User Info
                          Container(
                            // padding: EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: Colors.white,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(15),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  const Row(
                                    children: [
                                      Icon(
                                        Icons.article,
                                        color: Colors.deepOrange,
                                      ),
                                      SizedBox(
                                        width: 10,
                                      ),
                                      Text("User Info",
                                          style: TextStyle(
                                              fontSize: 20,
                                              overflow: TextOverflow.ellipsis,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.deepOrange))
                                    ],
                                  ),
                                  const Divider(
                                    color: Colors.grey,
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.person,
                                        color: Colors.deepOrange.shade200,
                                      ),
                                      const SizedBox(
                                        width: 10,
                                      ),
                                      Text("${eventOrderData?.data?.userName}",
                                          style: const TextStyle(
                                              fontSize: 16,
                                              overflow: TextOverflow.ellipsis))
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.email_outlined,
                                        color: Colors.deepOrange.shade200,
                                      ),
                                      const SizedBox(
                                        width: 10,
                                      ),
                                      Text("${eventOrderData?.data?.userEmail}",
                                          style: const TextStyle(
                                              fontSize: 16,
                                              overflow: TextOverflow.ellipsis))
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.phone,
                                        color: Colors.deepOrange.shade200,
                                      ),
                                      const SizedBox(
                                        width: 10,
                                      ),
                                      Text("${eventOrderData?.data?.userPhone}",
                                          style: const TextStyle(
                                              fontSize: 16,
                                              overflow: TextOverflow.ellipsis)),
                                      const SizedBox(
                                        width: 15,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // /// Pass Button
                          // const SizedBox(height: 10),
                          // InkWell(
                          //   onTap: () {
                          //     Navigator.push(
                          //       context,
                          //       CupertinoPageRoute(
                          //         builder: (context) => EventPassScreen(
                          //           eventOrderId: '${eventOrderData?.data?.id}',
                          //         ),
                          //       ),
                          //     );
                          //   },
                          //   child: Container(
                          //     width: double.infinity,
                          //     padding: const EdgeInsets.all(16),
                          //     decoration: BoxDecoration(
                          //       color: Colors.white,
                          //       borderRadius: BorderRadius.circular(35),
                          //       boxShadow: [
                          //         BoxShadow(
                          //           color: Colors.orange.withOpacity(0.2),
                          //           blurRadius: 15,
                          //           spreadRadius: 2,
                          //           offset: const Offset(0, 6),
                          //         ),
                          //       ],
                          //       border: Border.all(
                          //         color: Colors.red.withOpacity(0.3),
                          //         width: 1,
                          //       ),
                          //     ),
                          //     child: Row(
                          //       mainAxisSize: MainAxisSize.min,
                          //       children: [
                          //         // Animated Icon Container
                          //         Container(
                          //           padding: const EdgeInsets.all(10),
                          //           decoration: BoxDecoration(
                          //             gradient: const LinearGradient(
                          //               colors: [
                          //                 Color(0xFFFF6B00),
                          //                 Color(0xFFFF8C00)
                          //               ],
                          //               begin: Alignment.topLeft,
                          //               end: Alignment.bottomRight,
                          //             ),
                          //             borderRadius: BorderRadius.circular(12),
                          //             boxShadow: [
                          //               BoxShadow(
                          //                 color: Colors.orange.withOpacity(0.4),
                          //                 blurRadius: 8,
                          //                 offset: const Offset(0, 3),
                          //               ),
                          //             ],
                          //           ),
                          //           child: const Icon(
                          //             Icons.confirmation_number_outlined,
                          //             color: Colors.white,
                          //             size: 24,
                          //           ),
                          //         ),
                          //         const SizedBox(width: 12),
                          //
                          //         // Text Content
                          //         Column(
                          //           crossAxisAlignment:
                          //               CrossAxisAlignment.start,
                          //           children: [
                          //             Text(
                          //               "Your Event Pass",
                          //               style: TextStyle(
                          //                 color: Colors.orange[800],
                          //                 fontSize: 12,
                          //                 fontWeight: FontWeight.w600,
                          //                 letterSpacing: 1.2,
                          //               ),
                          //             ),
                          //             const SizedBox(height: 2),
                          //             Text(
                          //               "Your Ticket to Unforgettable Experiences!",
                          //               style: TextStyle(
                          //                 color: Colors.grey[800],
                          //                 fontSize: 14,
                          //                 fontWeight: FontWeight.w700,
                          //               ),
                          //             ),
                          //           ],
                          //         ),
                          //         const SizedBox(width: 12),
                          //
                          //         // Arrow in circle
                          //         Container(
                          //           padding: const EdgeInsets.all(6),
                          //           decoration: BoxDecoration(
                          //             color: Colors.orange.withOpacity(0.1),
                          //             shape: BoxShape.circle,
                          //             border: Border.all(
                          //               color: Colors.orange.withOpacity(0.3),
                          //               width: 1.5,
                          //             ),
                          //           ),
                          //           child: Icon(
                          //             Icons.arrow_forward_ios_rounded,
                          //             color: Colors.orange[700],
                          //             size: 16,
                          //           ),
                          //         ),
                          //       ],
                          //     ),
                          //   ),
                          // ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(15),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // your product
                          const Row(
                            children: [
                              Icon(
                                Icons.redeem,
                                color: Colors.deepOrange,
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Text("Your Tickets Info",
                                  style: TextStyle(
                                      fontSize: 20,
                                      overflow: TextOverflow.ellipsis,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.deepOrange)),
                            ],
                          ),
                          const SizedBox(
                            height: 5,
                          ),

                          /// **Event Details Card**
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 6,
                                  spreadRadius: 2,
                                  offset: const Offset(2, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 5),

                                /// **Event Image**
                                Container(
                                  height: 150,
                                  width: 320,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(5),
                                    border: Border.all(
                                        color: Colors.grey, width: 0.5),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(5),
                                    child: Image.network(
                                      "${eventOrderData?.data?.artistImage}",
                                      fit: BoxFit.fill,
                                      errorBuilder:
                                          (context, error, stackTrace) =>
                                      const Icon(
                                        Icons.image_not_supported_outlined,
                                        size: 50,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 5),

                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    /// **Event Details**
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          /// **Ticket Name**
                                          Text(
                                            "${eventOrderData?.data?.enEventName}",
                                            style: GoogleFonts.poppins(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.black87,
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),

                                          const SizedBox(height: 5),

                                          /// **Booking Date & Time**
                                          Row(
                                            children: [
                                              const Icon(Icons.date_range,
                                                  color: Colors.blue, size: 18),
                                              const SizedBox(width: 5),
                                              Text(
                                                formatDateTime(
                                                    "${eventOrderData?.data?.eventDate},",
                                                    returnDate: true),
                                                style: GoogleFonts.poppins(
                                                    fontSize: 14,
                                                    color: Colors.black),
                                              ),
                                              const SizedBox(width: 5),
                                              Text(
                                                formatDateTime(
                                                    "${eventOrderData?.data?.eventDate}",
                                                    returnDate: false),
                                                style: GoogleFonts.poppins(
                                                    fontSize: 14,
                                                    color: Colors.black),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 5),

                                          /// **Artist Name**
                                          Row(
                                            children: [
                                              const Icon(Icons.person,
                                                  color: Colors.deepPurple,
                                                  size: 18),
                                              const SizedBox(width: 5),
                                              Expanded(
                                                child: Text(
                                                  "${eventOrderData?.data?.enArtistName}",
                                                  style: GoogleFonts.poppins(
                                                      fontSize: 14,
                                                      color: Colors.black),
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 5),

                                          /// **Event Venue**
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              const Icon(Icons.location_on,
                                                  color: Colors.red, size: 18),
                                              const SizedBox(width: 5),
                                              Expanded(
                                                child: Text(
                                                  "${eventOrderData?.data?.enEventVenue}",
                                                  style: GoogleFonts.poppins(
                                                      fontSize: 14,
                                                      color: Colors.black),
                                                  maxLines: 2,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 10),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const Divider(
                                  color: Colors.grey,
                                ),

                                /// **Event Name**
                                Text(
                                  "${eventOrderData?.data?.enEventName}",
                                  style: GoogleFonts.poppins(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.orange,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),

                                ///& Total Seats**
                                Text(
                                  "Total Seats: ${eventOrderData?.data?.totalSeats}",
                                  style: GoogleFonts.poppins(
                                      fontSize: 16,
                                      color: Colors.blue,
                                      fontWeight: FontWeight.bold),
                                ),

                                /// **Price
                                RichText(
                                  text: TextSpan(
                                    children: [
                                      TextSpan(
                                        text:
                                            "${NumberFormat.currency(
                                                locale: 'en_IN',
                                                symbol: '₹',
                                                decimalDigits: 0)
                                                .format(double.tryParse("${eventOrderData?.data?.amount} ") ??
                                                0)}",
                                        style: GoogleFonts.poppins(
                                          fontSize: 16,
                                          color: Colors.deepOrange,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      TextSpan(
                                        text: "(Tax Included)",
                                        style: GoogleFonts.poppins(
                                          fontSize: 12,
                                          color: Colors.grey,
                                          fontWeight: FontWeight.normal,
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ),

                          const SizedBox(
                            height: 10,
                          ),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(15),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  // Slightly transparent black for better aesthetics
                                  blurRadius: 4,
                                  // Controls the softness of the shadow
                                  spreadRadius:
                                      1, // Spread the shadow a little// X=0 (centered horizontally), Y=4 (downwards)
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                const Row(
                                  children: [
                                    Icon(
                                      Icons.article,
                                      color: Colors.blue,
                                    ),
                                    SizedBox(
                                      width: 10,
                                    ),
                                    Text("Payment info",
                                        style: TextStyle(
                                            fontSize: 20,
                                            overflow: TextOverflow.ellipsis,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.blue)),
                                  ],
                                ),
                                const Divider(
                                  color: Colors.grey,
                                ),
                                const SizedBox(
                                  height: 15,
                                ),
                                Row(
                                  children: [
                                    const Text("Subtotal",
                                        style: TextStyle(
                                            fontSize: 18,
                                            overflow: TextOverflow.ellipsis,
                                            color: Colors.green)),
                                    const Spacer(),
                                    Text(
                                        "${NumberFormat.currency(
                                            locale: 'en_IN',
                                            symbol: '₹',
                                            decimalDigits: 0)
                                            .format(double.tryParse("${eventOrderData?.data?.amount}") ??
                                            0)}",
                                        style: const TextStyle(
                                            fontSize: 18,
                                            overflow: TextOverflow.ellipsis,
                                            color: Colors.green)),
                                  ],
                                ),
                                const SizedBox(
                                  height: 5,
                                ),
                                Row(
                                  children: [
                                    const Text("Coupon discount",
                                        style: TextStyle(
                                            fontSize: 18,
                                            overflow: TextOverflow.ellipsis,
                                            color: Colors.black,
                                            fontWeight: FontWeight.bold)),
                                    const Spacer(),
                                    Text(
                                        "${NumberFormat.currency(
                                            locale: 'en_IN',
                                            symbol: '₹',
                                            decimalDigits: 0)
                                            .format(double.tryParse("${eventOrderData?.data?.couponAmount}") ??
                                            0)}",
                                        style: const TextStyle(
                                            fontSize: 18,
                                            overflow: TextOverflow.ellipsis)),
                                  ],
                                ),
                                const Divider(
                                  color: Colors.grey,
                                ),
                                Row(
                                  children: [
                                    const Text("Amount Paid",
                                        style: TextStyle(
                                            fontSize: 18,
                                            overflow: TextOverflow.ellipsis,
                                            color: Colors.black,
                                            fontWeight: FontWeight.bold)),
                                    const Spacer(),
                                    Text(
                                        "${NumberFormat.currency(
                                            locale: 'en_IN',
                                            symbol: '₹',
                                            decimalDigits: 0)
                                            .format(double.tryParse("${eventOrderData?.data?.amount - eventOrderData?.data?.couponAmount}") ??
                                            0)}",
                                        style: const TextStyle(
                                            fontSize: 18,
                                            overflow: TextOverflow.ellipsis)),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          // tourOrderData?.data!.amountStatus == 1
                          // ?
                          Column(
                            children: [
                              const SizedBox(
                                height: 15,
                              ),
                              eventOrderData?.data?.reviewStatus == 1
                                  ? Container(
                                      height: 50,
                                      width: double.infinity,
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 5, horizontal: 10),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                            color: Colors.grey.shade400,
                                            width: 2),
                                      ),
                                      child: const Row(children: [
                                        Text(
                                          "Review added successfully ✨",
                                          style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w400,
                                              color: Colors.grey),
                                        ),
                                        Spacer(),
                                        Center(
                                            child: Icon(
                                          CupertinoIcons.checkmark_circle_fill,
                                          color: Colors.green,
                                        )),
                                      ]),
                                    )
                                  : InkWell(
                                      onTap: () {
                                        _suggestionsController.text =
                                            options[0];
                                        showFeedbackBottomSheet();
                                      },
                                      child: Container(
                                        height: 50,
                                        width: double.infinity,
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 5, horizontal: 10),
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(100),
                                          border: Border.all(
                                              color: Colors.grey.shade400,
                                              width: 2),
                                        ),
                                        child: const Row(children: [
                                          Text(
                                            "Write Your Experience",
                                            style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w400),
                                          ),
                                          Spacer(),
                                          Center(
                                              child: Icon(
                                            CupertinoIcons
                                                .arrow_right_circle_fill,
                                            color: Colors.blue,
                                          )),
                                        ]),
                                      ),
                                    ),
                            ],
                          ),
                          //: const SizedBox.shrink(),

                          const SizedBox(
                            height: 25,
                          ),
                          const Text(
                              "For any assistance or support with consultancy bookings, please feel free to contact us!",
                              style:
                                  TextStyle(fontSize: 14, color: Colors.grey)),
                          InkWell(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    PageAnimationTransition(
                                        page: const SupportTicketScreen(),
                                        pageAnimationType:
                                            RightToLeftTransition()));
                              },
                              child: const Text("Support Center",
                                  style: TextStyle(
                                      fontSize: 16,
                                      overflow: TextOverflow.ellipsis,
                                      color: Colors.deepOrange))),

                          const SizedBox(
                            height: 80,
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
          );
  }
}

class EventPassScreen extends StatefulWidget {
  final String eventOrderId;

  const EventPassScreen({super.key, required this.eventOrderId});

  @override
  _EventPassScreenState createState() => _EventPassScreenState();
}

class _EventPassScreenState extends State<EventPassScreen> {
  List<GlobalKey> _passKeys = [];
  bool isLoading = false;
  List<EventPass> qrList = [];

  @override
  void initState() {
    super.initState();
    showQR(widget.eventOrderId);
  }

  Future<String?> _captureAndSave(int index) async {
    try {
      await WidgetsBinding.instance.endOfFrame;

      RenderRepaintBoundary? boundary = _passKeys[index]
          .currentContext
          ?.findRenderObject() as RenderRepaintBoundary?;

      if (boundary == null) return null;

      var image = await boundary.toImage(pixelRatio: 4.0);
      ByteData? byteData = await image.toByteData(format: ImageByteFormat.png);
      Uint8List pngBytes = byteData!.buffer.asUint8List();

      final directory = await getApplicationDocumentsDirectory();
      String filePath = '${directory.path}/event_pass_$index.png';
      File file = File(filePath);
      await file.writeAsBytes(pngBytes);

      return filePath;
    } catch (e) {
      print("Error capturing image: $e");
      return null;
    }
  }

  Future<void> _sharePass(int index, EventPass event) async {
    String? filePath = await _captureAndSave(index);
    String shareUrl = "${AppConstants.baseUrl}/download";

    if (filePath != null) {
      await Share.shareXFiles([XFile(filePath!)], text: '''
📢 **आध्यात्मिक प्रवचन में आपका स्वागत है!** 🎟️  

🎫 **Event Pass** - ${event.enPackageName}

📅 **Event:** ${event.enEventName}
🎭 **Performer:** ${event.enArtistName}
📍 **Venue:** ${event.enEventVenue}
📆 **Date & Time:** ${event.eventDate}
👤 **Attendee:** ${event.totalSeats}
💰 **Price:** ₹${event.amount}

🔗 **Download App:** $shareUrl

#${event.enCategoryName?.replaceAll(' ', '')} #SpiritualEvent
      ''');
    }
  }

  // void _showPassDialog(BuildContext context, EventPass event, int index) {
  //   showDialog(
  //     context: context,
  //     builder: (context) => Dialog(
  //       backgroundColor: Colors.transparent,
  //       insetPadding: const EdgeInsets.all(16),
  //       child: RepaintBoundary(
  //         key: _passKeys[index],
  //         child: _buildTicket(event, isFullView: true),
  //       ),
  //     ),
  //   );
  // }

  Widget _buildTicket(EventPass event,int index,{bool isFullView = false}) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 2,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Top Section with Gradient
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFFFF8C42), // Orange
                  Color(0xFFFF6B35), // Deep Orange
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            event.enCategoryName ?? "Event Pass",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            event.enEventName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        event.enPackageName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Main Content
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // Performer
                _buildInfoRow(
                  icon: Icons.star,
                  label: "Performed by",
                  value: event.enArtistName ?? "Unknown",
                  iconColor: const Color(0xFFFF8C42),
                ),
                const SizedBox(height: 12),

                // Venue
                _buildInfoRow(
                  icon: Icons.location_on,
                  label: "Venue",
                  value: event.enEventVenue,
                  iconColor: const Color(0xFFE74C3C),
                ),
                const SizedBox(height: 12),

                // Date & Time
                Row(
                  children: [
                    Expanded(
                      child: _buildInfoRow(
                        icon: Icons.calendar_today,
                        label: "Date",
                        value: event.eventDate.split(' ').sublist(0, 3).join(' '),
                        iconColor: const Color(0xFF3498DB),
                      ),
                    ),
                    Expanded(
                      child: _buildInfoRow(
                        icon: Icons.access_time,
                        label: "Time",
                        value: event.eventDate.split(' ').sublist(3).join(' '),
                        iconColor: const Color(0xFF9B59B6),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Attendee
                _buildInfoRow(
                  icon: Icons.person,
                  label: "Attendee",
                  value: event.totalSeats.toString(),
                  iconColor: const Color(0xFF2ECC71),
                ),
              ],
            ),
          ),

          // Dashed Line
          Container(
            height: 1,
            margin: const EdgeInsets.symmetric(horizontal: 20),
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Flex(
                  direction: Axis.horizontal,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(
                    (constraints.constrainWidth() / 10).floor(),
                        (index) => Container(
                      width: 5,
                      height: 1,
                      color: Colors.grey.shade400,
                    ),
                  ),
                );
              },
            ),
          ),

          // QR Code Section with Curves
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: Color(0xFFF8F9FA),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                // QR Code
                Expanded(
                  flex: 2,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Column(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            event.passUrl,
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                width: 100,
                                height: 100,
                                color: Colors.grey.shade200,
                                child: Icon(
                                  Icons.qr_code,
                                  size: 60,
                                  color: Colors.grey.shade600,
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Pass #${qrList.indexOf(event) + 1}",
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(width: 16),

                // Event Details
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        event.enOrganizerName,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2C3E50),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "📞 ${event.footerPhone}",
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "✉️ ${event.footerEmail}",
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "🌐 ${event.footerUrl}",
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Footer with Copyright
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF2C3E50),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
            ),
            child: Column(
              children: [
                // Contact Info rows (phone, email, website)
                // ... aapki contact info rows yahan hain ...

                const SizedBox(height: 16),

                // Divider
                Container(
                  height: 1,
                  width: double.infinity,
                  color: Colors.white.withOpacity(0.2),
                ),

                const SizedBox(height: 12),

                // Copyright and Share Button in same row
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Copyright Text - 3 lines mein (dynamic se parse karke)
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Pehli line: "Copyright © 2026"
                          Text(
                            _extractCopyrightYear(event.footerCopyright),
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.7),
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 2),

                          // Doosri line: "MAHAKAL.COM"
                          Text(
                            _extractCompanyName(event.footerCopyright),
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 2),

                          // Teesri line: "All rights reserved."
                          Text(
                            _extractRightsText(event.footerCopyright),
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.6),
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 12),

                    // Share Button
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF8C42),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFFF8C42).withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: IconButton(
                        onPressed: () {
                          int eventIndex = qrList.indexOf(event);
                          _sharePass(eventIndex, event);
                        },
                        icon: const Icon(
                          Icons.share,
                          color: Colors.white,
                          size: 18,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 36,
                          minHeight: 36,
                        ),
                        padding: EdgeInsets.zero,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Helper methods for parsing copyright text
  String _extractCopyrightYear(String copyright) {
    try {
      // "Copyright © 2026 MAHAKAL.COM All rights reserved."
      // se "Copyright © 2026" nikalna
      if (copyright.contains('Copyright ©')) {
        if (copyright.contains('MAHAKAL.COM')) {
          return copyright.split('MAHAKAL.COM')[0].trim();
        } else if (copyright.contains('All rights reserved.')) {
          return copyright.split('All rights reserved.')[0].trim();
        }
      }
    } catch (e) {
      print('Error extracting year: $e');
    }
    return 'Copyright © 2026'; // fallback
  }

  String _extractCompanyName(String copyright) {
    try {
      // "MAHAKAL.COM" nikalna
      if (copyright.contains('MAHAKAL.COM')) {
        String company = 'MAHAKAL.COM';
        // Check if there's text before MAHAKAL.COM
        if (copyright.split('MAHAKAL.COM').length > 1) {
          return 'MAHAKAL.COM';
        }
        return company;
      }
    } catch (e) {
      print('Error extracting company: $e');
    }
    return 'MAHAKAL.COM'; // fallback
  }

  String _extractRightsText(String copyright) {
    try {
      // "All rights reserved." nikalna
      if (copyright.contains('All rights reserved.')) {
        return 'All rights reserved.';
      }
    } catch (e) {
      print('Error extracting rights: $e');
    }
    return 'All rights reserved.'; // fallback
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    required Color iconColor,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: iconColor, size: 18),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2C3E50),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> showQR(String id) async {
    Map<String, dynamic> data = {"id": id};

    setState(() => isLoading = true);

    try {
      final res = await HttpService().postApi(AppConstants.eventPassUrl, data);
      if (res != null && res["data"] != null) {
        final response = EventPassModel.fromJson(res);
        qrList = response.data;
        _passKeys = List.generate(qrList.length, (index) => GlobalKey());
      }
    } catch (e) {
      print(e);
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        title: const Text(
          "My Event Pass",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF2C3E50),
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 2,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF2C3E50)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: isLoading
          ? const Center(
        child: CircularProgressIndicator(
          color: Color(0xFFFF8C42),
        ),
      )
          : qrList.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.confirmation_number_outlined,
              size: 80,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              "No Passes Available",
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 16,
              ),
            ),
          ],
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: qrList.length,
        itemBuilder: (context, index) {
          var event = qrList[index];
          return Stack(
            children: [

              // Ticket
              RepaintBoundary(
                key: _passKeys[index],
                child: _buildTicket(event,index),
              ),
            ],
          );
        },
      ),
    );
  }
}