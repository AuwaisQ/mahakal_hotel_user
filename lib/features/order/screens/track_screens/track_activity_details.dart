import 'dart:convert';
import 'dart:io';
import 'dart:ui';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:mahakal/features/order/screens/track_screens/invoice_view_screen.dart';
import 'package:mahakal/features/order/screens/track_screens/track_event_details.dart';
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
import '../../../Tickit_Booking/controller/activites_order_details_controller.dart';
import '../../../auth/controllers/auth_controller.dart';
import '../../../profile/controllers/profile_contrroller.dart';
import '../../../support/screens/support_ticket_screen.dart';
import 'package:http/http.dart' as http;
import 'activity_pass_screen.dart';

class TrackActivityDetails extends StatefulWidget {
  final int orderId;

  const TrackActivityDetails({
    super.key,
    required this.orderId,
  });

  @override
  State<TrackActivityDetails> createState() => _TrackActivityDetailsState();
}

class _TrackActivityDetailsState extends State<TrackActivityDetails> {
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

  String? filePath;
  String invoicePdfUrl = "";

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
    print("My Activity Order Id:${widget.orderId}");
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final controller = context.read<ActivitiesOrderDetailController>();
      controller.clearData(); // Clear old data first
      controller.fetchActivitiesOrderDetail(orderId: widget.orderId.toString());
    });

    // Get user data from ProfileController
    final profileController =
        Provider.of<ProfileController>(Get.context!, listen: false);
    userId = profileController.userID;
    userName = profileController.userNAME;
    userNumber = profileController.userPHONE;
    userToken =
        Provider.of<AuthController>(Get.context!, listen: false).getUserToken();
    userEmail = profileController.userEMAIL;
    _initializeData();
  }

  Future<void> _initializeData() async {
    await fetchActivityInvoice(context, widget.orderId.toString(), userToken);
  }

  void _handleCheckboxChange(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void setReviewData(StateSetter modalSetter) async {
    final controller =
        Provider.of<ActivitiesOrderDetailController>(context, listen: false);

    final url = Uri.parse(AppConstants.baseUrl +
        AppConstants.addEventCommentUrl); // Replace with your API endpoint
    final Map<String, dynamic> data = {
      "user_id": userId,
      "event_id": "${controller.orderData?.eventId ?? ''}",
      "order_id": "${controller.orderData?.id ?? widget.orderId}",
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

        // Refresh order details to get updated review status
        await controller.fetchActivitiesOrderDetail(
            orderId: widget.orderId.toString());

        Fluttertoast.showToast(
            msg: "Thank you for your feedback!",
            backgroundColor: Colors.green,
            textColor: Colors.white);
      } else {
        Fluttertoast.showToast(
            msg: "Add Failed",
            backgroundColor: Colors.red,
            textColor: Colors.white);
      }
    } catch (error) {
      print('Error posting data: $error');
      Fluttertoast.showToast(
          msg: "Something went wrong",
          backgroundColor: Colors.red,
          textColor: Colors.white);
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
                                  value: _selectedIndex == index,
                                  onChanged: (value) {
                                    if (value == true) {
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
                                setReviewData(modalSetter);
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

        String filePath = "${directory.path}/activity_pass_${index + 1}.png";
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
            msg: "✅ Pass Downloaded: activity_pass_${index + 1}.png");
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

  Future<void> fetchActivityInvoice(
      BuildContext context, String invoiceId, String userToken) async {
    invoicePdfUrl =
        AppConstants.baseUrl + AppConstants.activityInvoiceUrl + invoiceId;
    print(" api url ${invoicePdfUrl}");

    try {
      Response response = await Dio().get(
        invoicePdfUrl,
        options: Options(
          responseType: ResponseType.bytes,
          headers: {"Authorization": "Bearer $userToken"},
        ),
      );

      if (response.statusCode == 200) {
        final pdfBytes = List<int>.from(response.data);

        if (!String.fromCharCodes(pdfBytes).startsWith('%PDF')) {
          throw Exception("Invalid PDF file received");
        }

        Directory tempDir = await getTemporaryDirectory();

        String savedPath = '${tempDir.path}/activity_invoice_$invoiceId.pdf';

        File file = File(savedPath);
        await file.writeAsBytes(pdfBytes, flush: true);

        setState(() {
          filePath = savedPath; // Correct
        });

        // String filePath = '${tempDir.path}/activity_invoice_$invoiceId.pdf';
        //
        // File file = File(filePath);
        // await file.writeAsBytes(pdfBytes, flush: true);
        //
        // setState(() {
        //   filePath = filePath;
        // });
        print("Saved at: $filePath");
      } else {
        throw Exception("HTTP ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching invoice: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Failed to fetch invoice"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> openActivityInvoice(BuildContext context) async {
    if (filePath == null || !File(filePath!).existsSync()) {
      print("File path: $filePath");
      print(
          "Exists: ${filePath != null ? File(filePath!).existsSync() : false}");

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please download the invoice first!"),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (context) => InvoiceViewer(
          pdfPath: filePath ?? '',
          invoiceUrl: invoicePdfUrl ?? '',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ActivitiesOrderDetailController>(
      builder: (context, controller, child) {
        final isLoading = controller.isLoading;
        final orderData = controller.orderData;

        if (isLoading && orderData == null) {
          return const Scaffold(
              backgroundColor: Colors.white,
              body: Center(
                  child: CircularProgressIndicator(
                color: Colors.orange,
              )));
        }

        if (orderData == null) {
          return Scaffold(
            appBar: AppBar(
              title: const Text("Order Details"),
            ),
            body: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 60, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    "Failed to load order details",
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.grey.shade50,
            title: Column(
              children: [
                Text.rich(TextSpan(children: [
                  const TextSpan(
                      text: "Order -",
                      style: TextStyle(color: Colors.black, fontSize: 18)),
                  TextSpan(
                      text: " #${orderData.orderNo ?? ''}",
                      style: const TextStyle(
                          color: Colors.black,
                          fontSize: 20,
                          fontWeight: FontWeight.bold)),
                ])),
                const SizedBox(
                  height: 5,
                ),
                Text.rich(TextSpan(children: [
                  const TextSpan(
                      text: " Your Order is - ",
                      style: TextStyle(color: Colors.black, fontSize: 18)),
                  TextSpan(
                      text: orderData.amountStatus == 1 ? "Success" : "Pending",
                      style: TextStyle(
                          color: orderData.amountStatus == 1
                              ? Colors.green
                              : Colors.orange,
                          fontSize: 20,
                          fontWeight: FontWeight.bold)),
                ])),
                const SizedBox(
                  height: 5,
                ),
                Text(
                    formatDateTime("${orderData.eventDate ?? ''}",
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
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerFloat,
          floatingActionButton: InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ActivityPassScreen(
                    eventOrderId: "${orderData.id}",
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
          body: RefreshIndicator(
            onRefresh: () async {
              await controller.fetchActivitiesOrderDetail(
                  orderId: widget.orderId.toString());
            },
            color: Colors.white,
            backgroundColor: Colors.deepOrange,
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
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Colors.white,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(15),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
                                    Text("${orderData.userName ?? ''}",
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
                                    Text("${orderData.userEmail ?? ''}",
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
                                    Text("${orderData.userPhone ?? ''}",
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

                        /// Pass Button
                        // const SizedBox(height: 10),
                        // InkWell(
                        //   onTap: () {
                        //     // Navigate to EventPassScreen
                        //     Navigator.push(
                        //       context,
                        //       MaterialPageRoute(
                        //         builder: (context) => ActivityPassScreen(
                        //           eventOrderId:
                        //               "${orderData.id}", // Your order ID
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
                        //           crossAxisAlignment: CrossAxisAlignment.start,
                        //           children: [
                        //             Text(
                        //               "Your Activity Pass",
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
                        //                 fontSize: 12,
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
                        /// your product
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
                                          "${orderData.enEventName ?? ''}",
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
                                                  "${orderData.eventDate ?? ''},",
                                                  returnDate: true),
                                              style: GoogleFonts.poppins(
                                                  fontSize: 14,
                                                  color: Colors.black),
                                            ),
                                            const SizedBox(width: 5),
                                            Text(
                                              formatDateTime(
                                                  "${orderData.eventDate ?? ''}",
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
                                                "${orderData.enEventName ?? ''}",
                                                style: GoogleFonts.poppins(
                                                    fontSize: 14,
                                                    color: Colors.black),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
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
                                                "${orderData.enEventVenue ?? ''}",
                                                style: GoogleFonts.poppins(
                                                    fontSize: 14,
                                                    color: Colors.black),
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 10),
                                      ],
                                    ),
                                  ),

                                  /// **Event Image**
                                  Container(
                                    height: 90,
                                    width: 155,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(5),
                                      border: Border.all(
                                          color: Colors.grey, width: 0.5),
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(5),
                                      child: Image.network(
                                        "${orderData.eventImage ?? ''}",
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
                                ],
                              ),

                              const Divider(
                                color: Colors.grey,
                              ),

                              /// **Event Name**
                              Text(
                                "${orderData.enEventName ?? ''}",
                                style: GoogleFonts.poppins(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.orange,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),

                              /// & Total Seats**
                              Text(
                                "Total Seats: ${orderData.totalSeats ?? 0}",
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
                                          "${NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0).format(double.tryParse("${orderData.totalAmount ?? '0'}") ?? 0)}",
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

                        /// Payment Info Card
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(15),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 4,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: const [
                                      Icon(Icons.payment, color: Colors.blue),
                                      SizedBox(width: 10),
                                      Text(
                                        "Payment info",
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.blue,
                                        ),
                                      ),
                                    ],
                                  ),
                                  TextButton.icon(
                                    onPressed: () {
                                      openActivityInvoice(context);
                                    },
                                    icon: const Icon(Icons.receipt_long_rounded,
                                        size: 18),
                                    label: const Text("View Invoice"),
                                    style: TextButton.styleFrom(
                                      foregroundColor: Colors.blue,
                                    ),
                                  ),
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
                                      "${NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0).format(double.tryParse("${orderData.totalAmount ?? '0'}") ?? 0)}",
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
                                      "${NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0).format(double.tryParse("${orderData.couponAmount ?? '0'}") ?? 0)}",
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
                                      "${NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0).format((double.tryParse("${orderData.totalAmount ?? '0'}") ?? 0) - (double.tryParse("${orderData.couponAmount ?? '0'}") ?? 0))}",
                                      style: const TextStyle(
                                          fontSize: 18,
                                          overflow: TextOverflow.ellipsis)),
                                ],
                              ),
                            ],
                          ),
                        ),

                        /// Review Section
                        Column(
                          children: [
                            const SizedBox(
                              height: 15,
                            ),
                            orderData.reviewStatus == 1
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
                                      _suggestionsController.text = options[0];
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

                        const SizedBox(
                          height: 25,
                        ),
                        const Text(
                            "For any assistance or support with activity bookings, please feel free to contact us!",
                            style: TextStyle(fontSize: 14, color: Colors.grey)),
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
                  ),

                  SizedBox(height: 80,),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}



// Widget build(BuildContext context) {
//   return Scaffold(
//     appBar: AppBar(
//       title: Text(
//         widget.isEnglish ? "Activity Passes" : "एक्टिविटी पास",
//         style: const TextStyle(
//           color: Colors.orange,
//           fontWeight: FontWeight.bold,
//         ),
//       ),
//       backgroundColor: Colors.white,
//       elevation: 0,
//       iconTheme: const IconThemeData(color: Colors.black),
//     ),
//     body: Consumer<ActivitiesPassController>(
//       builder: (context, controller, child) {
//         if (controller.isLoading) {
//           return const MahakalLoadingData(onReload: null);
//         }
//
//         if (!controller.hasPasses) {
//           return Center(
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Icon(
//                   Icons.confirmation_number_outlined,
//                   size: 80,
//                   color: Colors.grey.shade400,
//                 ),
//                 const SizedBox(height: 16),
//                 Text(
//                   widget.isEnglish
//                       ? "No passes available"
//                       : "कोई पास उपलब्ध नहीं है",
//                   style: TextStyle(
//                     fontSize: 18,
//                     color: Colors.grey.shade600,
//                     fontWeight: FontWeight.w500,
//                   ),
//                 ),
//                 const SizedBox(height: 24),
//                 ElevatedButton(
//                   onPressed: _fetchPasses,
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.orange,
//                     foregroundColor: Colors.white,
//                     padding: const EdgeInsets.symmetric(
//                       horizontal: 32,
//                       vertical: 12,
//                     ),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(30),
//                     ),
//                   ),
//                   child: Text(
//                     widget.isEnglish ? "Retry" : "पुनः प्रयास करें",
//                     style: const TextStyle(fontSize: 16),
//                   ),
//                 ),
//               ],
//             ),
//           );
//         }
//
//         // Initialize pass keys if needed
//         if (_passKeys.length != controller.totalPasses) {
//           _passKeys = List.generate(controller.totalPasses, (index) => GlobalKey());
//         }
//
//         return ListView.builder(
//           padding: const EdgeInsets.all(16),
//           itemCount: controller.totalPasses,
//           itemBuilder: (context, index) {
//             final passData = controller.getPassDataByIndex(index);
//             if (passData == null) return const SizedBox();
//
//             int passNumber = index + 1;
//             String eventName = controller.getEventName(passData, isEnglish: widget.isEnglish);
//             String venueName = controller.getVenueName(passData, isEnglish: widget.isEnglish);
//             String passHolderName = controller.getPassHolderName(passData);
//             String seatNumber = _formatSeatNumber(passData);  //  "D-1", "D-2"
//
//             return Padding(
//               padding: const EdgeInsets.only(bottom: 16),
//               child: GestureDetector(
//                 onTap: () => _showPassDialog(context, passData),
//                 child: RepaintBoundary(
//                   key: _passKeys[index],
//                   child: Container(
//                     decoration: BoxDecoration(
//                       borderRadius: BorderRadius.circular(20),
//                       gradient: const LinearGradient(
//                         colors: [
//                           Color(0xFFFF6B6B),
//                           Color(0xFFFF8E53),
//                         ],
//                         begin: Alignment.topLeft,
//                         end: Alignment.bottomRight,
//                       ),
//                       boxShadow: [
//                         BoxShadow(
//                           color: Colors.black.withOpacity(0.15),
//                           blurRadius: 10,
//                           offset: const Offset(0, 5),
//                         ),
//                       ],
//                     ),
//                     child: Padding(
//                       padding: const EdgeInsets.all(16),
//                       child: Row(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           /// Left Side - Pass Info
//                           Expanded(
//                             flex: 2,
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 // Pass Number Badge
//                                 Container(
//                                   padding: const EdgeInsets.symmetric(
//                                     horizontal: 12,
//                                     vertical: 6,
//                                   ),
//                                   decoration: BoxDecoration(
//                                     color: Colors.white.withOpacity(0.2),
//                                     borderRadius: BorderRadius.circular(20),
//                                   ),
//                                   child: Text(
//                                     widget.isEnglish
//                                         ? "Pass #$passNumber"
//                                         : "पास #$passNumber",
//                                     style: const TextStyle(
//                                       color: Colors.white,
//                                       fontWeight: FontWeight.bold,
//                                       fontSize: 12,
//                                     ),
//                                   ),
//                                 ),
//                                 const SizedBox(height: 12),
//
//                                 // Pass Holder Name
//                                 Row(
//                                   children: [
//                                     const Icon(
//                                       Icons.person_outline,
//                                       color: Colors.white,
//                                       size: 16,
//                                     ),
//                                     const SizedBox(width: 8),
//                                     Expanded(
//                                       child: Text(
//                                         passHolderName,
//                                         style: const TextStyle(
//                                           color: Colors.white,
//                                           fontWeight: FontWeight.w600,
//                                           fontSize: 14,
//                                         ),
//                                         maxLines: 1,
//                                         overflow: TextOverflow.ellipsis,
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                                 const SizedBox(height: 8),
//
//                                 // Event Name - One line
//                                 Row(
//                                   children: [
//                                     const Icon(
//                                       Icons.event,
//                                       color: Colors.white,
//                                       size: 16,
//                                     ),
//                                     const SizedBox(width: 8),
//                                     Expanded(
//                                       child: Text(
//                                         eventName,
//                                         style: const TextStyle(
//                                           color: Colors.white,
//                                           fontSize: 13,
//                                           fontWeight: FontWeight.w500,
//                                         ),
//                                         maxLines: 1,
//                                         overflow: TextOverflow.ellipsis,
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                                 const SizedBox(height: 8),
//
//                                 // Venue - One line
//                                 Row(
//                                   children: [
//                                     const Icon(
//                                       Icons.location_on,
//                                       color: Colors.white,
//                                       size: 16,
//                                     ),
//                                     const SizedBox(width: 8),
//                                     Expanded(
//                                       child: Text(
//                                         venueName,
//                                         style: const TextStyle(
//                                           color: Colors.white70,
//                                           fontSize: 12,
//                                         ),
//                                         maxLines: 1,
//                                         overflow: TextOverflow.ellipsis,
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                                 const SizedBox(height: 8),
//
//                                 // 🔥 Seat Number - "D-1", "D-2" format mein
//                                 Row(
//                                   children: [
//                                     const Icon(
//                                       Icons.event_seat,
//                                       color: Colors.white,
//                                       size: 16,
//                                     ),
//                                     const SizedBox(width: 8),
//                                     Expanded(
//                                       child: Text(
//                                         widget.isEnglish
//                                             ? "Seat: $seatNumber"
//                                             : "सीट: $seatNumber",
//                                         style: const TextStyle(
//                                           color: Colors.white,
//                                           fontSize: 12,
//                                           fontWeight: FontWeight.bold,
//                                         ),
//                                         maxLines: 1,
//                                         overflow: TextOverflow.ellipsis,
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ],
//                             ),
//                           ),
//
//                           /// Right Side - QR Code & Share
//                           Column(
//                             children: [
//                               Container(
//                                 width: 90,
//                                 height: 90,
//                                 decoration: BoxDecoration(
//                                   color: Colors.white,
//                                   borderRadius: BorderRadius.circular(12),
//                                   border: Border.all(
//                                     color: Colors.white.withOpacity(0.3),
//                                     width: 2,
//                                   ),
//                                 ),
//                                 child: ClipRRect(
//                                   borderRadius: BorderRadius.circular(10),
//                                   child: Image.network(
//                                     passData.passUrl,
//                                     fit: BoxFit.cover,
//                                     errorBuilder: (context, error, stackTrace) {
//                                       return Column(
//                                         mainAxisAlignment: MainAxisAlignment.center,
//                                         children: [
//                                           Icon(
//                                             Icons.qr_code,
//                                             size: 40,
//                                             color: Colors.orange.shade700,
//                                           ),
//                                           Text(
//                                             "QR",
//                                             style: TextStyle(
//                                               fontSize: 10,
//                                               color: Colors.orange.shade700,
//                                               fontWeight: FontWeight.bold,
//                                             ),
//                                           ),
//                                         ],
//                                       );
//                                     },
//                                   ),
//                                 ),
//                               ),
//                               const SizedBox(height: 8),
//                               Container(
//                                 decoration: BoxDecoration(
//                                   color: Colors.white.withOpacity(0.2),
//                                   shape: BoxShape.circle,
//                                 ),
//                                 child: IconButton(
//                                   onPressed: () => _sharePass(index, passData),
//                                   icon: const Icon(
//                                     Icons.share,
//                                     color: Colors.white,
//                                     size: 20,
//                                   ),
//                                   constraints: const BoxConstraints(
//                                     minWidth: 40,
//                                     minHeight: 40,
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//             );
//           },
//         );
//       },
//     ),
//   );
// }
