import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:mahakal/common/basewidget/show_custom_snakbar_widget.dart';
import 'package:mahakal/data/datasource/remote/http/httpClient.dart';

import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:mahakal/utill/loading_datawidget.dart';
import 'package:page_animation_transition/animations/right_to_left_transition.dart';
import 'package:page_animation_transition/page_animation_transition.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../main.dart';
import '../../../../utill/app_constants.dart';
import '../../../../utill/flutter_toast_helper.dart';
import '../../../../utill/full_screen_image_slider.dart';
import '../../../auth/controllers/auth_controller.dart';
import '../../../maha_bhandar/model/city_model.dart';
import '../../../profile/controllers/profile_contrroller.dart';
import '../../../support/screens/support_ticket_screen.dart';
import '../../model/refund_tour_model.dart';
import '../../model/tour_order__model.dart';
import 'package:http/http.dart' as http;
import 'invoice_view_screen.dart';

class TrackTourDetails extends StatefulWidget {
  final String orderId;
  const TrackTourDetails({
    super.key,
    required this.orderId,
  });

  @override
  State<TrackTourDetails> createState() => _TrackTourDetailsState();
}

class _TrackTourDetailsState extends State<TrackTourDetails> {
  final billFormKey = GlobalKey<FormState>();

  List<CityPickerModel> cityListModel = <CityPickerModel>[];

  int _selectedRating = 3; // Initially all options are unchecked
  int noPerson = 0;
  double latiTude = 0.0;
  double longiTude = 0.0;

  double walletPay = 0.0;
  // int walletMinusAmount = 0;
  double finalAmount = 0.0;
  String userId = "";
  String userName = "";
  String userEmail = "";
  String userNumber = "";
  String userToken = "";
  double refundAmount = 0.0;
  double sheduleAmount = 0.0;
  final String _selectedDate = "";

  final bool _showText = false;
  bool isYesNo = false;
  bool isChecked = false;
  bool isLoading = false;
  bool isWalletApplied = false;
  int _selectedIndex = 0; // -1 means no option is selected

  final _razorpay = Razorpay();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    userId = Provider.of<ProfileController>(Get.context!, listen: false).userID;
    userName =
        Provider.of<ProfileController>(Get.context!, listen: false).userNAME;
    userEmail =
        Provider.of<ProfileController>(Get.context!, listen: false).userEMAIL;
    userNumber =
        Provider.of<ProfileController>(Get.context!, listen: false).userPHONE;
    userToken =
        Provider.of<AuthController>(Get.context!, listen: false).getUserToken();
    getOrderDetails();
    fetchInvoice(context, userId, widget.orderId);
    walletAmount();
    getRefundPolicy();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  double? amountAfterWallet;
  int? successAmountStatus;
  int? naviGateRazorpay;
  double payingRemainAmount = 0;
  double? deducatedFromWallet;

  final TextEditingController _suggestionsController = TextEditingController();
  List<String> options = [
    "The tour guide was knowledgeable and provided detailed insights at every location.",
    "The itinerary was well-planned and covered all major attractions comfortably.",
    "The booking process was smooth and easy to follow.",
    "I liked that I could choose the type of tour based on my interests.",
    "The overall experience was hassle-free, and post-tour assistance was also provided.",
    // ... more options
  ];

  void _handleCheckboxChange(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void setReviewData(StateSetter modalSetter) async {
    final url = Uri.parse(
        '${AppConstants.baseUrl}${AppConstants.addCommentUrl}'); // Replace with your API endpoint
    final Map<String, dynamic> data = {
      "user_id": userId,
      "tour_id": tourOrderData!.data!.tourId,
      "star": _selectedRating,
      "comment": _suggestionsController.text,
      "order_id": "${tourOrderData!.data!.id}",
      "type": "add"
    };

    print("userid$userId");
    print("tour id${tourOrderData!.data!.tourId}");
    print("star$_selectedRating");
    print("comment$_suggestionsController");
    print("order id${tourOrderData!.data!.id}");

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

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    print("Success Payment: ${response.paymentId}");

    setState(() {
      _isLoading = true; // Show the progress bar
    });

    await remainingAmount(
        response.paymentId.toString(), amountAfterWallet == 0 ? 1 : 0);

    setState(() {
      _isLoading = false; // Show the progress bar
    });

    // Show success message to the user
    ToastHelper.showSuccess("Success");
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    print("Error Payment: ${response.code} - ${response.message}");
    // Show error message to the user
    ToastHelper.showError("Payment Failed!");
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    // Do something when an external wallet was selected
  }
  void _openPaymentGateway(String amt) async {
    int amountInPaise = (double.parse(amt) * 100).toInt();

    var options = {
      'key': AppConstants.razorpayLive,
      'amount': amountInPaise,
      'name': userName,
      'description': "",
      'prefill': {
        'contact': userNumber,
        'email': userEmail,
      },
      'theme': {
        'color': '#FFA500', // Orange color in HEX
        'textColor': '#FFFFFF'
      }
    };
    try {
      _razorpay.open(options);
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> remainingAmount(String paymentId, int paymentStatus) async {
    // final url ='${AppConstants.baseUrl}${AppConstants.remainingAmountUrl}'; // Replace with your API endpoint
    final Map<String, dynamic> data = {
      "user_id": userId,
      "order_id": widget.orderId,
      "wallet_type": paymentStatus,
      "payment_amount": tourOrderData?.data!.remainingAmount, // Paid Amount
      "transaction_id": paymentId,
      //"online_pay": payingRemainAmount // Total Amount (Razopay)
      "online_pay": payingRemainAmount // Total Amount (Razopay)
    };

    try {
      final res =
          await HttpService().postApi(AppConstants.remainingAmountUrl, data);
      //final res = await ApiServiceDonate().getAdvertise(url, data);
      print(res);
      if (res != null) {
        final String remainingMessage = res["message"];
        getOrderDetails();
        fetchInvoice(context, userId, widget.orderId);
        walletAmount();
        getRefundPolicy();
        Navigator.pop(context);
        Fluttertoast.showToast(
            msg: remainingMessage,
            backgroundColor: Colors.green,
            textColor: Colors.white);
      } else {
        Fluttertoast.showToast(
            msg: "Payment Failed!",
            backgroundColor: Colors.green,
            textColor: Colors.white);
      }
    } catch (e) {
      Fluttertoast.showToast(
          msg: "$e", backgroundColor: Colors.green, textColor: Colors.white);
    }
  }

  String? message;

  /// Cancal Tour
  Future<void> cancelTour(String cancalReason) async {
    //String url = AppConstants.baseUrl + AppConstants.cancalTourUrl;

    Map<String, dynamic> data = {
      "user_id": userId,
      "order_id": widget.orderId,
      "msg": cancalReason
    };

    try {
      final res = await HttpService().postApi(AppConstants.cancalTourUrl, data);
      //final res = await ApiServiceDonate().getAdvertise(url, data);

      if (res != null && res["status"] == 1) {
        message = res["message"]; // Store message
        print("Tour cancelled successfully: $message");

        getOrderDetails();
        ToastHelper.showSuccess("$message");
      } else {
        print("Cancellation failed: ${res?["message"] ?? "Unknown error"}");
      }
    } catch (e) {
      ToastHelper.showError("$e");
      print("Error cancelling tour: $e");
    }
  }

  static String? savedInvoicePath; // Invoice ka path store karega

  /// **Invoice fetch Method**
  static Future<void> fetchInvoice(
      BuildContext context, String userId, String orderId) async {
    try {
      String apiUrl =
          "${AppConstants.baseUrl}${AppConstants.tourBookingInvoiceUrl}$orderId?user_id=$userId";

      // API GET Request
      Response response = await Dio().get(
        apiUrl,
        options: Options(responseType: ResponseType.bytes), // PDF Response
      );

      if (response.statusCode == 200) {
        Directory tempDir = await getTemporaryDirectory();
        String filePath = '${tempDir.path}/invoice_$orderId.pdf';

        File file = File(filePath);
        await file.writeAsBytes(response.data);
        savedInvoicePath = filePath; // Store Path
      } else {
        print('Failed to download. Status code: ${response.statusCode}');
      }
    } catch (error) {
      print("Error downloading invoice: $error");
    }
  }

  /// **Invoice Open Method**
  static Future<void> openInvoice(BuildContext context, String url) async {
    if (savedInvoicePath == null || !File(savedInvoicePath!).existsSync()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content:
                Text("⚠ No invoice found at: ${savedInvoicePath ?? 'NULL'}")),
      );
      print("File does not exist: ${savedInvoicePath ?? 'NULL'}");
      return;
    }

    print("Opening PDF: $savedInvoicePath");

    Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (context) => InvoiceViewer(
          pdfPath: savedInvoicePath!,
          invoiceUrl: url,
        ),
      ),
    );
  }

  /// **Invoice Share Method**
  static Future<void> shareInvoice(BuildContext context) async {
    if (savedInvoicePath != null && File(savedInvoicePath!).existsSync()) {
      String shareUrl = '';
      shareUrl = "${AppConstants.baseUrl}/download";

      // Share message
      String shareText = "📜 **आपका टूर इनवॉइस** ✨\n\n"
          "अब देखें Mahakal.com ऐप पर! 🔱💖\n"
          "📲 **डाउनलोड करें और यात्रा का लाभ उठाएं!** 🙏\n\n"
          "🔹Download App Now: $shareUrl";

      // **Step 1: Pehle PDF share karo**
      await Share.shareXFiles([XFile(savedInvoicePath!)]);

      // **Step 2: Phir Text + URL share karo**
      await Share.share(shareText, subject: "📜 आपका टूर इनवॉइस");
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("⚠ Please download the invoice first!")),
      );
    }
  }

  /// Date Formatter
  String formatDate(String date) {
    try {
      DateTime parsedDate = DateTime.parse(date);
      return DateFormat("d MMMM yyyy").format(parsedDate); // 1 March 2025
    } catch (e) {
      print("Date Parsing Error: $e");
      return "Invalid Date";
    }
  }

  /// Show cancal Dialog
  void showCancelDialog(BuildContext context, dynamic refundAmount) {
    TextEditingController reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: const Row(
            children: [
              Icon(Icons.cancel, color: Colors.red),
              SizedBox(width: 10),
              Text(
                "Cancel Tour",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Please enter a reason for cancellation:",
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: reasonController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: "Write your reason here...",
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                "Refund Amount: ₹${double.parse(refundAmount.toString()).toStringAsFixed(2)}",
                style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.green),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Cancel", style: TextStyle(color: Colors.red)),
            ),
            ElevatedButton(
              onPressed: () {
                String reason = reasonController.text.trim();
                if (reason.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Please enter a reason")),
                  );
                  return;
                }
                cancelTour(reason);
                // Process the cancellation logic here
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text("Cancellation request sent successfully!")),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
              child: const Text(
                "Send",
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }

  DateTime? targetDate;
  TourOrderDetails? tourOrderData;
  RefundPolicyModel? refundPolicyList;

  bool _isLoading = true;

  /// Get Details
  Future<void> getOrderDetails() async {
    // String url = AppConstants.baseUrl + AppConstants.tourOrderDetailsUrl;

    Map<String, dynamic> data = {"user_id": userId, "order_id": widget.orderId};

    setState(() {
      _isLoading = true;
    });

    try {
      final res =
          await HttpService().postApi(AppConstants.tourOrderDetailsUrl, data);
      // final res = await ApiServiceDonate().getAdvertise(url, data); // Await response
      print("API Response: $res");

      if (res != null) {
        setState(() {
          tourOrderData = TourOrderDetails.fromJson(res);
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
        print("Error: API response is null");
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ToastHelper.showError("$e");

      print("Error fetching order details: $e");
    }
  }

  /// Get Refund Data
  Future<void> getRefundPolicy() async {
    // String url = AppConstants.baseUrl + AppConstants.tourBookingPolicyUrl;

    Map<String, dynamic> data = {"user_id": userId, "order_id": widget.orderId};

    setState(() {
      _isLoading = true;
    });

    try {
      final res =
          await HttpService().postApi(AppConstants.tourBookingPolicyUrl, data);
      //final res = await ApiServiceDonate().getAdvertise(url, data); // Await response
      print("API Response: $res");

      if (res != null) {
        setState(() {
          refundPolicyList = RefundPolicyModel.fromJson(res);
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
        print("Error: API response is null");
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        refundPolicyList = RefundPolicyModel(data: []); //
      });

      // showTopSnackBar(Overlay.of(context), showCustomSnackBar("${e}", context));

      print("Error fetching policy: $e");
    }
  }

  /// Show Payment Dialog
  void showPaymentDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            "Confirm Payment",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          content: const Text(
            "Are you sure you want to proceed with the payment?",
            style: TextStyle(fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.grey[700],
              ),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                remainingAmount("wallet", 1);
                Navigator.of(context).pop(); // Close the dialog
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange, // Primary color
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text("Confirm Payment"),
            ),
          ],
        );
      },
    );
  }

  /// Show Refund Policy Sheet
  void showRefundPolicyBottomSheet(
    BuildContext context,
  ) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
      ),
      backgroundColor: Colors.white,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Refund Policy",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                const Divider(),
                refundPolicyList!.data!.isNotEmpty
                    ? ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: refundPolicyList!.data!.length,
                        itemBuilder: (context, index) {
                          final item = refundPolicyList!.data![index];
                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 6),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 4,
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Html(data: item.hiMessage),
                                  const SizedBox(height: 5),
                                  Text(
                                    "Refund Percentage: ${item.percentage}",
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.green),
                                  ),
                                  Text(
                                    "Refund Amount: ₹${item.amount}",
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blue),
                                  ),
                                  Text(
                                    "Date: ${item.date}",
                                    style: const TextStyle(color: Colors.grey),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      )
                    : const Center(child: Text("No data"))
              ],
            ),
          ),
        );
      },
    );
  }

  /// review bottom sheet
  void showFeedbackBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
            builder: (BuildContext context, StateSetter modalSetter) {
          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context)
                  .viewInsets
                  .bottom, // 👈 keyboard padding
            ),
            child: DraggableScrollableSheet(
              expand: false,
              initialChildSize: 0.95,
              maxChildSize: 0.95,
              minChildSize: 0.3,
              builder: (context, scrollController) {
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
                              style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                            ),
                          ),

                          const SizedBox(
                            height: 30,
                          ),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(10),
                            decoration:
                                const BoxDecoration(color: Colors.white),
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
                            decoration:
                                const BoxDecoration(color: Colors.white),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "How many stars will you give us for your Tour booking on Mahakal.com",
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold),
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
                            decoration:
                                const BoxDecoration(color: Colors.white),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "What can we improve ?",
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 8),
                                Column(
                                  children:
                                      List.generate(options.length, (index) {
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
                            decoration:
                                const BoxDecoration(color: Colors.white),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Please provide your suggestions",
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
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
                                      floatingLabelBehavior:
                                          FloatingLabelBehavior.never),
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
                                    getOrderDetails();
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
                //   Container(
                //   padding: const EdgeInsets.symmetric(horizontal: 10),
                //   decoration: BoxDecoration(
                //     color: Colors.grey.shade100,
                //     borderRadius: const BorderRadius.only(
                //       topLeft: Radius.circular(16),
                //       topRight: Radius.circular(16),
                //     ),
                //   ),
                //   child: SingleChildScrollView(
                //     controller: scrollController,
                //     child: Column(
                //       children: [
                //         const SizedBox(height: 30),
                //         AppBar(
                //           backgroundColor: Colors.transparent,
                //           elevation: 0,
                //           centerTitle: true,
                //           leading: IconButton(
                //             onPressed: () => Navigator.pop(context),
                //             icon: const Icon(CupertinoIcons.chevron_back, color: Colors.red),
                //           ),
                //           title: const Text(
                //             'Please provide your feedback',
                //             style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                //           ),
                //         ),
                //         const SizedBox(height: 30),
                //
                //         // User Info
                //         Container(
                //           width: double.infinity,
                //           padding: const EdgeInsets.all(10),
                //           color: Colors.white,
                //           child: Column(
                //             crossAxisAlignment: CrossAxisAlignment.start,
                //             children: [
                //               Text(
                //                 "$userName",
                //                 style: const TextStyle(
                //                   fontSize: 20,
                //                   fontWeight: FontWeight.bold,
                //                   color: Colors.orange,
                //                 ),
                //               ),
                //               Text(
                //                 "$userEmail",
                //                 style: const TextStyle(
                //                   fontSize: 14,
                //                   fontWeight: FontWeight.w500,
                //                   color: Colors.blueGrey,
                //                 ),
                //               ),
                //             ],
                //           ),
                //         ),
                //
                //         // Star Rating
                //         const SizedBox(height: 10),
                //         Container(
                //           padding: const EdgeInsets.all(10),
                //           color: Colors.white,
                //           child: Column(
                //             crossAxisAlignment: CrossAxisAlignment.start,
                //             children: [
                //               const Text(
                //                 "How many stars will you give us for your Tour booking on Mahakal.com",
                //                 style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                //               ),
                //               Divider(color: Colors.grey.shade300),
                //               Row(
                //                 mainAxisAlignment: MainAxisAlignment.center,
                //                 children: List.generate(5, (index) {
                //                   return IconButton(
                //                     icon: Icon(
                //                       index < _selectedRating ? Icons.star : Icons.star_border,
                //                       color: Colors.amber,
                //                       size: 40,
                //                     ),
                //                     onPressed: () {
                //                       modalSetter(() {
                //                         _selectedRating = index + 1;
                //                       });
                //                     },
                //                   );
                //                 }),
                //               ),
                //               Center(
                //                 child: Text(
                //                   _selectedRating == 1
                //                       ? "Poor"
                //                       : _selectedRating == 2
                //                       ? "Below Average"
                //                       : _selectedRating == 3
                //                       ? "Average"
                //                       : _selectedRating == 4
                //                       ? "Good"
                //                       : "Excellent",
                //                   style: const TextStyle(
                //                     fontSize: 20,
                //                     fontWeight: FontWeight.bold,
                //                     color: Colors.amber,
                //                   ),
                //                 ),
                //               ),
                //             ],
                //           ),
                //         ),
                //
                //         // Improvement Options
                //         const SizedBox(height: 10),
                //         Container(
                //           padding: const EdgeInsets.all(10),
                //           color: Colors.white,
                //           child: Column(
                //             crossAxisAlignment: CrossAxisAlignment.start,
                //             children: [
                //               const Text(
                //                 "What can we improve?",
                //                 style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                //               ),
                //               const SizedBox(height: 8),
                //               Column(
                //                 children: List.generate(options.length, (index) {
                //                   return CheckboxListTile(
                //                     checkColor: Colors.white,
                //                     activeColor: Colors.orange,
                //                     title: Text(
                //                       options[index],
                //                       style: const TextStyle(fontSize: 14),
                //                     ),
                //                     value: _selectedIndex == index,
                //                     onChanged: (value) {
                //                       if (value == true) {
                //                         modalSetter(() {
                //                           _handleCheckboxChange(index);
                //                           _suggestionsController.text = options[index];
                //                         });
                //                       }
                //                     },
                //                   );
                //                 }),
                //               ),
                //             ],
                //           ),
                //         ),
                //
                //         // Suggestions
                //         const SizedBox(height: 10),
                //         Container(
                //           padding: const EdgeInsets.all(10),
                //           color: Colors.white,
                //           child: Column(
                //             crossAxisAlignment: CrossAxisAlignment.start,
                //             children: [
                //               const Text(
                //                 "Please provide your suggestions",
                //                 style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                //               ),
                //               const SizedBox(height: 8),
                //               TextFormField(
                //                 controller: _suggestionsController,
                //                 maxLines: 4,
                //                 decoration: const InputDecoration(
                //                   border: OutlineInputBorder(
                //                       borderSide: BorderSide(color: Colors.orange)),
                //                   enabledBorder: OutlineInputBorder(
                //                       borderSide: BorderSide(color: Colors.orange)),
                //                   hintText: "Write here...",
                //                   floatingLabelBehavior: FloatingLabelBehavior.never,
                //                 ),
                //               ),
                //               const SizedBox(height: 16),
                //             ],
                //           ),
                //         ),
                //
                //         // Submit Button
                //         isLoading
                //             ? Container(
                //           margin: const EdgeInsets.all(10),
                //           height: 45,
                //           width: double.infinity,
                //           decoration: BoxDecoration(
                //             borderRadius: BorderRadius.circular(8),
                //             color: Colors.orange.shade400,
                //           ),
                //           child: const Center(
                //             child: CircularProgressIndicator(color: Colors.white),
                //           ),
                //         )
                //             : GestureDetector(
                //           onTap: () {
                //             modalSetter(() {
                //               isLoading = true;
                //             });
                //             print("Rating: $_selectedRating");
                //             print("Suggestions: ${_suggestionsController.text}");
                //             setReviewData(modalSetter);
                //             getOrderDetails();
                //           },
                //           child: Container(
                //             padding: const EdgeInsets.all(10),
                //             margin: const EdgeInsets.all(10),
                //             decoration: BoxDecoration(
                //               borderRadius: BorderRadius.circular(8),
                //               color: Colors.orange,
                //             ),
                //             child: const Center(
                //               child: Text(
                //                 "Submit",
                //                 style: TextStyle(fontSize: 16, color: Colors.white),
                //               ),
                //             ),
                //           ),
                //         ),
                //       ],
                //     ),
                //   ),
                // );
              },
            ),
          );
        });
      },
    );
  }

  /// Fetch Wallet Amount
  void walletAmount() async {
    try {
      var res = await HttpService().getApi(AppConstants.tourWalletUrl + userId);
      print("Wallet Response $res");
      if (res["success"]) {
        setState(() {
          walletPay = double.parse(res["wallet_balance"].toString());
        });
      }
    } catch (e) {
      print("Error in Fetching wallet Balance");
    } finally {}
  }

  /// Apply wallet
  void applywallet() {
    // Check if tourOrderData or its children are null
    // final payAmount = (tourOrderData?.data?.payAmount ?? 0).round();
    final payAmount = (tourOrderData?.data?.remainingAmount ?? 0).round();
    double amountToPay = double.parse(payAmount.toString());
    double walletBalance = walletPay;

    if (amountToPay <= 0) {
      print("Invalid amount: $amountToPay");
      return;
    }

    amountAfterWallet = max(walletBalance - amountToPay, 0);
    deducatedFromWallet = (walletPay ?? 0) - (amountAfterWallet ?? 0);

    if (walletBalance >= amountToPay) {
      payingRemainAmount = 0.0;
    } else {
      payingRemainAmount = amountToPay - walletBalance;
    }

    print(
        "Total Paying Tour (Remain): $amountToPay, Wallet Balance: $walletBalance");
    print(
        "Amount After Wallet: $amountAfterWallet, Remaining Donation Amount: $payingRemainAmount");

    if (isWalletApplied && walletPay >= amountToPay) {
      successAmountStatus = 1;
      naviGateRazorpay = 1;
    } else if (isWalletApplied && walletPay > 0 && walletPay < amountToPay) {
      successAmountStatus = 1;
      naviGateRazorpay = 2;
    } else {
      successAmountStatus = 0;
      naviGateRazorpay = 3;
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  List<bool> isExpandedList = [];

  void _showItineraryBottomsheet() {
    List<dynamic> currentImageIndex = [];
    Timer? imageTimer;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter modalSetter) {
            var itineraryList = tourOrderData?.data?.itineraryPlace ?? [];

            ///  Ensure `isExpandedList` is properly initialized
            if (isExpandedList.isEmpty ||
                isExpandedList.length != itineraryList.length) {
              isExpandedList = List.filled(itineraryList.length, false);
            }

            // Initialize image index list
            if (currentImageIndex.isEmpty) {
              currentImageIndex = List.filled(itineraryList.length, 0);
            }

            // Function to start image slideshow
            void startImageSlideshow() {
              imageTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
                if (!context.mounted) {
                  timer.cancel();
                  return;
                }
                modalSetter(() {
                  for (int i = 0; i < itineraryList.length; i++) {
                    var place = itineraryList[i];
                    if (place.image.isNotEmpty) {
                      currentImageIndex[i] =
                          (currentImageIndex[i] + 1) % place.image.length;
                    }
                  }
                });
              });
            }

            if (imageTimer == null) {
              startImageSlideshow();
            }

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
                        const SizedBox(height: 30),
                        Row(
                          children: [
                            IconButton(
                              onPressed: () {
                                imageTimer?.cancel();
                                Navigator.pop(context);
                              },
                              icon: const Icon(
                                CupertinoIcons.chevron_back,
                                color: Colors.red,
                              ),
                            ),
                            const SizedBox(width: 15),
                            const Text("Back"),
                            const Spacer(),
                          ],
                        ),
                        const SizedBox(height: 10),
                        SingleChildScrollView(
                          child: Column(
                            children: [
                              Text(
                                // translateEn == "en"
                                //?
                                tourOrderData?.data?.enTourName ?? "",
                                //  : delhiModal?.data?.hiTourName ?? "",
                                style: const TextStyle(
                                  color: Colors.orange,
                                  fontSize: 22,
                                  fontFamily: 'Roboto',
                                  fontWeight: FontWeight.bold,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                maxLines: 1,
                              ),
                              Divider(color: Colors.grey.shade300),
                              ListView.builder(
                                padding: const EdgeInsets.all(5),
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: itineraryList.length,
                                itemBuilder: (context, index) {
                                  var place = itineraryList[index];
                                  bool hasImages = place.image.isNotEmpty;

                                  return Card(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    elevation: 4,
                                    margin: const EdgeInsets.only(bottom: 20),
                                    child: Padding(
                                      padding: const EdgeInsets.all(8),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          GestureDetector(
                                            onTap: () {
                                              if (hasImages) {
                                                showModalBottomSheet(
                                                    context: context,
                                                    isScrollControlled: true,
                                                    builder: (context) {
                                                      return FullScreenImageSlider(
                                                        images: place.image,
                                                      );
                                                    });
                                              }
                                            },
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(5),
                                              child: hasImages
                                                  ? Image.network(
                                                      place.image[
                                                          currentImageIndex[
                                                              index]],
                                                      height: 110,
                                                      width: double.infinity,
                                                      fit: BoxFit.cover,
                                                      errorBuilder: (context,
                                                              error,
                                                              stackTrace) =>
                                                          Container(
                                                        height: 110,
                                                        width: double.infinity,
                                                        color: Colors.grey[300],
                                                        child: const Center(
                                                            child: Text(
                                                                "Image not available")),
                                                      ),
                                                    )
                                                  : Container(
                                                      height: 110,
                                                      width: double.infinity,
                                                      color: Colors.grey[300],
                                                      child: const Center(
                                                          child: Text(
                                                              "No Images")),
                                                    ),
                                            ),
                                          ),

                                          // ClipRRect(
                                          //   borderRadius: BorderRadius.circular(5),
                                          //   child: hasImages
                                          //       ? Image.network(
                                          //     place.image![currentImageIndex[index]],
                                          //     height: 110,
                                          //     width: double.infinity,
                                          //     fit: BoxFit.cover,
                                          //     errorBuilder: (context, error, stackTrace) =>
                                          //         Container(
                                          //           height: 110,
                                          //           width: double.infinity,
                                          //           color: Colors.grey[300],
                                          //           child: const Center(child: Text("Image not available")),
                                          //         ),
                                          //   )
                                          //       : Container(
                                          //     height: 110,
                                          //     width: double.infinity,
                                          //     color: Colors.grey[300],
                                          //     child: const Center(child: Text("No Images")),
                                          //   ),
                                          // ),
                                          const SizedBox(height: 10),
                                          Text(
                                            // translateEn == "en" ?
                                            place.enName ?? "",
                                            //   : place.hiName ?? "",
                                            style: const TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black87,
                                            ),
                                          ),
                                          const SizedBox(height: 5),
                                          Text(
                                            //translateEn == "en" ?
                                            place.enTime ?? "",
                                            //: place.hiTime ?? "",
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.blueGrey,
                                            ),
                                          ),
                                          const SizedBox(height: 10),

                                          /// View More Button
                                          GestureDetector(
                                            onTap: () {
                                              modalSetter(() {
                                                isExpandedList[index] =
                                                    !isExpandedList[index];
                                              });
                                            },
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: [
                                                Text(
                                                  isExpandedList[index]
                                                      ? "View Less"
                                                      : "View More",
                                                  style: const TextStyle(
                                                    fontSize: 15,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.blue,
                                                  ),
                                                ),
                                                Icon(
                                                  isExpandedList[index]
                                                      ? Icons.keyboard_arrow_up
                                                      : Icons
                                                          .keyboard_arrow_down,
                                                  color: Colors.blue,
                                                ),
                                              ],
                                            ),
                                          ),

                                          /// Description (Show only when View More is clicked)
                                          if (isExpandedList[index]) ...[
                                            Html(
                                                data:
                                                    //translateEn == "en"
                                                    //  ?
                                                    place.enDescription ?? ""
                                                // : place.hiDescription ?? "",
                                                ),
                                          ],
                                        ],
                                      ),
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
                ),
              ),
            );
          },
        );
      },
    ).whenComplete(() {
      imageTimer?.cancel(); // Close hone par Timer stop karna zaroori hai
    });
  }

  @override
  Widget build(BuildContext context) {
    var screenHeight = MediaQuery.of(context).size.height;
    var screenWidth = MediaQuery.of(context).size.width;

    return tourOrderData?.data!.orderId == null
        ? MahakalLoadingData(onReload: () {})
        : Scaffold(
            floatingActionButtonLocation:
                FloatingActionButtonLocation.centerDocked,
            floatingActionButton: Row(
              children: [
                tourOrderData?.data!.partPayment == "full"
                    ? const SizedBox.shrink()
                    : tourOrderData?.data!.refundStatus == 1
                        ? const SizedBox.shrink()
                        : Expanded(
                            child: InkWell(
                              onTap: () {
                                applywallet();

                                showModalBottomSheet(
                                    context: context,
                                    isScrollControlled: true,
                                    builder: (context) {
                                      return StatefulBuilder(builder:
                                          (BuildContext context,
                                              StateSetter modalSetter) {
                                        return Container(
                                          padding: const EdgeInsets.all(10),
                                          margin: const EdgeInsets.all(10),
                                          child: SingleChildScrollView(
                                            child: Padding(
                                              padding: EdgeInsets.only(
                                                  bottom: MediaQuery.of(context)
                                                      .viewInsets
                                                      .bottom),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  const SizedBox(
                                                    height: 10,
                                                  ),
                                                  Container(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            10),
                                                    decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8),
                                                        border: Border.all(
                                                            color:
                                                                Colors.grey)),
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        const Text(
                                                          "Bill details",
                                                          style: TextStyle(
                                                              fontSize: 18,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              fontFamily:
                                                                  'Roboto',
                                                              color: Colors
                                                                  .orange),
                                                        ),
                                                        const SizedBox(
                                                          height: 10,
                                                        ),

                                                        /// Package Total
                                                        Row(
                                                          children: [
                                                            const Text(
                                                              "Package Total",
                                                              style: TextStyle(
                                                                  fontSize: 18,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w400,
                                                                  fontFamily:
                                                                      'Roboto',
                                                                  color: Colors
                                                                      .black),
                                                            ),
                                                            const Spacer(),
                                                            Text(
                                                              "₹${tourOrderData?.data!.totalAmount}.0",
                                                              style: const TextStyle(
                                                                  fontSize: 18,
                                                                  fontFamily:
                                                                      'Roboto',
                                                                  color: Colors
                                                                      .green),
                                                            )
                                                          ],
                                                        ),

                                                        /// Paid Amount
                                                        Row(
                                                          children: [
                                                            const Text(
                                                              "Paid Amount",
                                                              style: TextStyle(
                                                                  fontSize: 18,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w400,
                                                                  fontFamily:
                                                                      'Roboto',
                                                                  color: Colors
                                                                      .black),
                                                            ),
                                                            const Spacer(),
                                                            Text(
                                                              "₹${tourOrderData?.data!.paidAmount}.0",
                                                              style: const TextStyle(
                                                                  fontSize: 18,
                                                                  fontFamily:
                                                                      'Roboto',
                                                                  color: Colors
                                                                      .green),
                                                            )
                                                          ],
                                                        ),
                                                        const Divider(),

                                                        isWalletApplied
                                                            ? Column(
                                                                children: [
                                                                  /// Wallet Balance
                                                                  Row(
                                                                    children: [
                                                                      const Text(
                                                                        "Wallet Balance : ",
                                                                        style: TextStyle(
                                                                            fontSize:
                                                                                18,
                                                                            color:
                                                                                Colors.black,
                                                                            fontWeight: FontWeight.bold),
                                                                      ),
                                                                      const Spacer(),
                                                                      Text(
                                                                        "₹${walletPay.toStringAsFixed(2)}",
                                                                        style:
                                                                            const TextStyle(
                                                                          fontSize:
                                                                              18,
                                                                          fontWeight:
                                                                              FontWeight.w400,
                                                                          fontFamily:
                                                                              'Roboto',
                                                                          color:
                                                                              Colors.blue, // Default color for all text
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),

                                                                  /// Walllet Remmaining
                                                                  Row(
                                                                    children: [
                                                                      RichText(
                                                                        text:
                                                                            TextSpan(
                                                                          style:
                                                                              const TextStyle(
                                                                            fontSize:
                                                                                18,
                                                                            fontWeight:
                                                                                FontWeight.w400,
                                                                            fontFamily:
                                                                                'Roboto',
                                                                            color:
                                                                                Colors.black, // Default color for all text
                                                                          ),
                                                                          children: [
                                                                            const TextSpan(text: "Wallet remaining ("),
                                                                            TextSpan(
                                                                              text: "₹${double.parse(amountAfterWallet.toString()).toStringAsFixed(2)}",
                                                                              style: const TextStyle(
                                                                                color: Colors.green,
                                                                                // Custom color for walletPay
                                                                                fontWeight: FontWeight.bold, // Optional, for emphasis
                                                                              ),
                                                                            ),
                                                                            const TextSpan(text: ")"),
                                                                          ],
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),

                                                                  /// Amount paid view wallet
                                                                  Row(
                                                                    children: [
                                                                      const Text(
                                                                        "Amount Paid (via Wallet)",
                                                                        style: TextStyle(
                                                                            fontSize:
                                                                                18,
                                                                            fontWeight: FontWeight
                                                                                .w400,
                                                                            fontFamily:
                                                                                'Roboto',
                                                                            color:
                                                                                Colors.black),
                                                                      ),
                                                                      const Spacer(),
                                                                      Text(
                                                                        "- ₹${double.parse(deducatedFromWallet.toString()).toStringAsFixed(2)}",
                                                                        style: const TextStyle(
                                                                            fontSize:
                                                                                18,
                                                                            fontFamily:
                                                                                'Roboto',
                                                                            color:
                                                                                Colors.red),
                                                                      )
                                                                    ],
                                                                  ),
                                                                  const Divider(),
                                                                  const SizedBox(
                                                                    height: 5,
                                                                  ),
                                                                ],
                                                              )
                                                            : const SizedBox
                                                                .shrink(),

                                                        walletPay == 0
                                                            ? const SizedBox
                                                                .shrink()
                                                            : Row(
                                                                children: [
                                                                  const Icon(
                                                                    Icons
                                                                        .wallet,
                                                                    color: Colors
                                                                        .orange,
                                                                    size: 30,
                                                                  ),
                                                                  const SizedBox(
                                                                    width: 5,
                                                                  ),
                                                                  isWalletApplied
                                                                      ? const Text(
                                                                          "Applied",
                                                                          style: TextStyle(
                                                                              fontWeight: FontWeight.bold,
                                                                              fontSize: 18,
                                                                              color: Colors.green),
                                                                        )
                                                                      : const Text(
                                                                          "Apply Wallet",
                                                                          style: TextStyle(
                                                                              fontWeight: FontWeight.bold,
                                                                              fontSize: 18),
                                                                        ),
                                                                  const Spacer(),
                                                                  Checkbox(
                                                                    checkColor:
                                                                        Colors
                                                                            .green,
                                                                    fillColor:
                                                                        WidgetStateColor
                                                                            .transparent,
                                                                    value:
                                                                        isWalletApplied,
                                                                    onChanged:
                                                                        (bool?
                                                                            newValue) {
                                                                      modalSetter(
                                                                          () {
                                                                        isWalletApplied =
                                                                            !isWalletApplied;
                                                                      });
                                                                    },
                                                                  )
                                                                ],
                                                              ),

                                                        /// Total Amount
                                                        Padding(
                                                          padding: EdgeInsets
                                                              .symmetric(
                                                                  horizontal:
                                                                      screenWidth *
                                                                          0.02),
                                                          child: Container(
                                                            width:
                                                                double.infinity,
                                                            decoration:
                                                                BoxDecoration(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          8),
                                                              color:
                                                                  Colors.white,
                                                              border: Border.all(
                                                                  color: Colors
                                                                      .orange),
                                                            ),
                                                            child: Padding(
                                                              padding: EdgeInsets
                                                                  .symmetric(
                                                                horizontal:
                                                                    screenWidth *
                                                                        0.02,
                                                                vertical:
                                                                    screenHeight *
                                                                        0.02,
                                                              ),
                                                              child: Column(
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                children: [
                                                                  Text(
                                                                    "Total Amount: ₹${(isWalletApplied ? payingRemainAmount : tourOrderData!.data!.remainingAmount).toStringAsFixed(2)}",
                                                                    style:
                                                                        TextStyle(
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                      color: Colors
                                                                          .black,
                                                                      fontSize:
                                                                          screenWidth *
                                                                              0.05,
                                                                    ),
                                                                  )
                                                                ],
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                          height: 10,
                                                        ),

                                                        /// Continue Button
                                                        Container(
                                                          width:
                                                              double.infinity,
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(10),
                                                          decoration:
                                                              BoxDecoration(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        5),
                                                            color: const Color
                                                                .fromRGBO(255,
                                                                245, 236, 1),
                                                          ),
                                                          child: const Center(
                                                            child: Text(
                                                              "Continue Now & Pay the Due Amount",
                                                              style: TextStyle(
                                                                  fontSize: 14,
                                                                  letterSpacing:
                                                                      0.5,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500,
                                                                  fontFamily:
                                                                      'Roboto',
                                                                  color: Colors
                                                                      .orange),
                                                            ),
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                          height: 10,
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  const SizedBox(
                                                    height: 20,
                                                  ),
                                                  isWalletApplied
                                                      ? Container(
                                                          width:
                                                              double.infinity,
                                                          height: 40,
                                                          margin:
                                                              const EdgeInsets
                                                                  .all(10),
                                                          child: ElevatedButton(
                                                            style:
                                                                ElevatedButton
                                                                    .styleFrom(
                                                              backgroundColor:
                                                                  Colors.green,
                                                              shape:
                                                                  RoundedRectangleBorder(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            10),
                                                              ),
                                                              textStyle:
                                                                  const TextStyle(
                                                                color: Colors
                                                                    .white,
                                                              ),
                                                            ),
                                                            onPressed: () {
                                                              amountAfterWallet ==
                                                                      0
                                                                  ? _openPaymentGateway(
                                                                      "$payingRemainAmount",
                                                                    )
                                                                  : showPaymentDialog(
                                                                      context);
                                                            },
                                                            child: const Row(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .center,
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .center,
                                                              children: [
                                                                Text(
                                                                  "Pay Now",
                                                                  style:
                                                                      TextStyle(
                                                                    color: Colors
                                                                        .white,
                                                                    fontSize:
                                                                        18,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        )
                                                      : Container(
                                                          width:
                                                              double.infinity,
                                                          height: 40,
                                                          margin:
                                                              const EdgeInsets
                                                                  .all(10),
                                                          child: ElevatedButton(
                                                            style:
                                                                ElevatedButton
                                                                    .styleFrom(
                                                              backgroundColor:
                                                                  Colors.green,
                                                              shape:
                                                                  RoundedRectangleBorder(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            10),
                                                              ),
                                                              textStyle:
                                                                  const TextStyle(
                                                                color: Colors
                                                                    .white,
                                                              ),
                                                            ),
                                                            onPressed: () {
                                                              _openPaymentGateway(
                                                                  "${tourOrderData!.data!.remainingAmount}");
                                                            },
                                                            child: Row(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .center,
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .center,
                                                              children: [
                                                                const Text(
                                                                  "Proceed to Pay",
                                                                  style:
                                                                      TextStyle(
                                                                    color: Colors
                                                                        .white,
                                                                    fontSize:
                                                                        18,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                  ),
                                                                ),
                                                                SizedBox(
                                                                    width:
                                                                        screenWidth *
                                                                            0.03),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                  const SizedBox(
                                                    height: 20.0,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        );
                                      });
                                    });
                              },
                              child: Container(
                                margin: const EdgeInsets.all(10),
                                height: 45,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8.0),
                                  color: Colors.orange,
                                ),
                                child: Center(
                                  child: Text(
                                    "Pay Now: ${double.parse(tourOrderData?.data!.remainingAmount.toString() ?? '').toStringAsFixed(2)}",
                                    style: const TextStyle(
                                        fontSize: 18, color: Colors.white),
                                  ),
                                ),
                              ),
                            ),
                          ),
                Expanded(
                  child: InkWell(
                    onTap: () {
                      tourOrderData?.data!.refundStatus == 1
                          ? const SizedBox.shrink()
                          : showCancelDialog(
                              context,
                              tourOrderData!.data!.cancelRefundAmountGiven ??
                                  0);
                    },
                    child: Container(
                      margin: const EdgeInsets.all(10),
                      height: 45,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8.0),
                        color: tourOrderData?.data!.refundStatus == 1
                            ? Colors.grey.shade500
                            : Colors.red,
                      ),
                      child: Center(
                        child: Text(
                          tourOrderData?.data!.refundStatus == 1
                              ? "Cancalled"
                              : "Cancel",
                          style: const TextStyle(
                              fontSize: 18, color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                )
              ],
            ),
            appBar: AppBar(
              backgroundColor: Colors.grey.shade50,
              title: Text(
                "Tour & Travell's",
                style: const TextStyle(color: Colors.black, fontSize: 18,fontWeight: FontWeight.bold),
                maxLines: 2,
              ),

              // Column(
              //   children: [
              //
              //     Text.rich(TextSpan(children: [
              //       const TextSpan(
              //           text: "Order -",
              //           style: TextStyle(color: Colors.black, fontSize: 18)),
              //       TextSpan(
              //           text: " #${tourOrderData?.data!.orderId}",
              //           style: const TextStyle(
              //               color: Colors.black,
              //               fontSize: 20,
              //               fontWeight: FontWeight.bold)),
              //     ])),
              //     const SizedBox(
              //       height: 5,
              //     ),
              //     Text.rich(
              //         TextSpan(
              //             children: [
              //               const TextSpan(text: " Your Order is - ",style: TextStyle(color: Colors.black,fontSize: 18)),
              //               TextSpan(text:tourOrderData?.data!.refundStatus == 0 ? (tourOrderData?.data!.amountStatus == 1 ? "Success" : "Failed") : "Canceled",style: TextStyle(color: tourOrderData?.data!.refundStatus == 0 ? Colors.green : Colors.red ,fontSize: 20,fontWeight: FontWeight.bold)),
              //             ]
              //         )
              //     ),
              //     const SizedBox(height: 5,),
              //     Text("${tourOrderData?.data!.bookingTime}",
              //         style: const TextStyle(
              //             fontSize: 18,
              //             overflow: TextOverflow.ellipsis,
              //             color: Colors.black)),
              //   ],
              // ),
              centerTitle: true,
              //toolbarHeight: 100,
            ),
            body: RefreshIndicator(
              onRefresh: () async {
                getOrderDetails();
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
                          /// UserInfo
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
                                      Text("Order Details",
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
                                        Icons.star_border,
                                        color: Colors.deepOrange.shade200,
                                      ),
                                      const SizedBox(
                                        width: 10,
                                      ),
                                      Text.rich(TextSpan(children: [
                                        const TextSpan(
                                            text: "Order -",
                                            style: TextStyle(
                                                color: Colors.black,
                                                fontSize: 18)),
                                        TextSpan(
                                            text:
                                                " #${tourOrderData?.data!.orderId}",
                                            style: const TextStyle(
                                                color: Colors.black,
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold)),
                                      ])),
                                      // Text("${userName}",
                                      //     style: const TextStyle(
                                      //         fontSize: 16,
                                      //         overflow: TextOverflow.ellipsis))
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.important_devices,
                                        color: Colors.deepOrange.shade200,
                                      ),
                                      const SizedBox(
                                        width: 10,
                                      ),
                                      Text.rich(
                                        TextSpan(children: [
                                          const TextSpan(
                                              text: "Order status - ",
                                              style: TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 18)),
                                          // TextSpan(
                                          //     text: tourOrderData?.data!
                                          //                 .refundStatus ==
                                          //             0
                                          //         ? (tourOrderData?.data!
                                          //                     .amountStatus ==
                                          //                 1
                                          //             ? "Success"
                                          //             : "Failed")
                                          //         : "Canceled",
                                          //     style: TextStyle(
                                          //         color: tourOrderData?.data!
                                          //                     .refundStatus ==
                                          //                 0
                                          //             ? Colors.green
                                          //             : Colors.red,
                                          //         fontSize: 20,
                                          //         fontWeight: FontWeight.bold)),

                                          TextSpan(
                                            text: (() {
                                              final data = tourOrderData?.data;
                                              if (data == null) return "";

                                              if (data.refundStatus == 1) {
                                                return "Refunded";
                                              } else if (data.partPayment ==
                                                  "part") {
                                                return "Partially Paid";
                                              } else if (data.partPayment ==
                                                  "full") {
                                                return "Fully Paid";
                                              } else if (data.partPayment ==
                                                  "custom") {
                                                return "Custom Payment";
                                              } else if (data.amountStatus ==
                                                  1) {
                                                return "Success";
                                              } else {
                                                return "Failed";
                                              }
                                            })(),
                                            style: TextStyle(
                                              color: (() {
                                                final data =
                                                    tourOrderData?.data;
                                                if (data == null)
                                                  return Colors.grey;

                                                if (data.refundStatus == 1) {
                                                  return Colors.red;
                                                } else if (data.partPayment ==
                                                    "part") {
                                                  return Colors.blue;
                                                } else if (data.partPayment ==
                                                    "full") {
                                                  return Colors.green;
                                                } else if (data.partPayment ==
                                                    "custom") {
                                                  return Colors.orange;
                                                } else if (data.amountStatus ==
                                                    1) {
                                                  return Colors.green;
                                                } else {
                                                  return Colors.red;
                                                }
                                              })(),
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ]),
                                      )
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.date_range,
                                        color: Colors.deepOrange.shade200,
                                      ),
                                      const SizedBox(
                                        width: 10,
                                      ),
                                      Text(
                                          "${tourOrderData?.data!.bookingTime}",
                                          style: const TextStyle(
                                              fontSize: 18,
                                              overflow: TextOverflow.ellipsis,
                                              color: Colors.black)),
                                      // Text("${userNumber}",
                                      //     style: const TextStyle(
                                      //         fontSize: 16,
                                      //         overflow: TextOverflow.ellipsis)),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          // const SizedBox(
                          //   height: 15,
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

                          // your Packages
                          const Row(
                            children: [
                              Icon(
                                Icons.redeem,
                                color: Colors.deepOrange,
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Text("Your Packages",
                                  style: TextStyle(
                                      fontSize: 20,
                                      overflow: TextOverflow.ellipsis,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.deepOrange)),
                            ],
                          ),
                          const SizedBox(
                            height: 15,
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
                                  blurRadius: 4,
                                  spreadRadius: 1,
                                ),
                              ],
                            ),
                            child: tourOrderData!.data!.bookingPackages.isEmpty
                                ? const Center(child: Text("Not-Available"))
                                : ListView.builder(
                                    itemCount: tourOrderData!
                                        .data!.bookingPackages.length,
                                    shrinkWrap: true,
                                    physics: const BouncingScrollPhysics(),
                                    itemBuilder: (context, index) {
                                      final package = tourOrderData!
                                          .data!.bookingPackages[index];
                                      final isRoute =
                                          package.enName.toLowerCase() ==
                                              "route";
                                      final isExDistance =
                                          package.enName.toLowerCase() ==
                                              "ex distance";

                                      // Check if this item should be visible
                                      if (isRoute &&
                                          (package.price == null ||
                                              package.price
                                                  .toString()
                                                  .isEmpty)) {
                                        return const SizedBox.shrink();
                                      }
                                      if (isExDistance &&
                                          ((package.price == null ||
                                                  package.price == 0) &&
                                              (package.qty == null ||
                                                  package.qty == 0))) {
                                        return const SizedBox.shrink();
                                      }

                                      // Helper function to parse values safely
                                      double? tryParse(dynamic value) {
                                        if (value == null) return null;
                                        if (value is num) {
                                          return value.toDouble();
                                        }
                                        return double.tryParse(
                                            value.toString());
                                      }

                                      // Route Type Label
                                      String getRouteTypeLabel(String? price) {
                                        if (price == null) return "";
                                        switch (price.toLowerCase()) {
                                          case "one_way":
                                            return "One Way";
                                          case "two_way":
                                            return "Two Way";
                                          case "both":
                                            return "Both Ways";
                                          default:
                                            return price; // Return as-is if not a known type
                                        }
                                      }

                                      // Determine if we should show border
                                      final showBorder =
                                          !isRoute && !isExDistance;

                                      return Container(
                                        margin:
                                            const EdgeInsets.only(bottom: 10),
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          color: Colors.white,
                                          border: Border.all(
                                            color: showBorder
                                                ? Colors.grey.shade300
                                                : Colors.transparent,
                                          ),
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.all(10.0),
                                          child: Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              // Image only for normal packages with image
                                              if (!isRoute &&
                                                  !isExDistance &&
                                                  package.image.isNotEmpty ==
                                                      true)
                                                Container(
                                                  width: 120,
                                                  height: 80,
                                                  decoration: BoxDecoration(
                                                    borderRadius: BorderRadius.circular(
                                                            8),
                                                    image: DecorationImage(
                                                      image: NetworkImage(
                                                          package.image),
                                                      fit: BoxFit.cover,
                                                    ),
                                                  ),
                                                )
                                              else if (!isRoute &&
                                                  !isExDistance)
                                                Container(
                                                  width: 120,
                                                  height: 80,
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8),
                                                    color: Colors.grey.shade200,
                                                  ),
                                                  child: const Icon(Icons.image,
                                                      color: Colors.grey),
                                                ),

                                              if (!isRoute && !isExDistance)
                                                const SizedBox(width: 12),

                                              // Package Details
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    // Title for all items
                                                    Text(
                                                      package.enName.toUpperCase() ??
                                                          'Unnamed',
                                                      style: TextStyle(
                                                        fontSize: isRoute ||
                                                                isExDistance
                                                            ? 16
                                                            : 18,
                                                        fontWeight: isRoute ||
                                                                isExDistance
                                                            ? FontWeight.w500
                                                            : FontWeight.bold,
                                                        color: isRoute ||
                                                                isExDistance
                                                            ? Colors
                                                                .blue.shade700
                                                            : Colors.black,
                                                      ),
                                                    ),
                                                    const SizedBox(height: 4),

                                                    // Show details based on package type
                                                    if (isRoute)
                                                      Text(
                                                        "Route Type: ${getRouteTypeLabel(package.price?.toString())}",
                                                        style: const TextStyle(
                                                          fontSize: 15,
                                                          color: Colors.grey,
                                                        ),
                                                      ),

                                                    if (isExDistance) ...[
                                                      if (tryParse(package
                                                                  .price) !=
                                                              null &&
                                                          tryParse(package
                                                                  .price)! >
                                                              0)
                                                        Text(
                                                          "Extra Distance Amount: ₹${tryParse(package.price)!.toStringAsFixed(2)}",
                                                          style:
                                                              const TextStyle(
                                                            fontSize: 15,
                                                            color: Colors.grey,
                                                          ),
                                                        ),
                                                      if (tryParse(package
                                                                  .qty) !=
                                                              null &&
                                                          tryParse(package
                                                                  .qty)! >
                                                              0)
                                                        Text(
                                                          "Extra Distance: ${tryParse(package.qty)!.toStringAsFixed(1)} km",
                                                          style:
                                                              const TextStyle(
                                                            fontSize: 15,
                                                            color: Colors.grey,
                                                          ),
                                                        ),
                                                    ],

                                                    if (!isRoute &&
                                                        !isExDistance) ...[
                                                      if (package.price != null)

                                                        Text(
                                                          package.price == 0 ? "Included" : "Price: ₹${package.price}",
                                                          style:
                                                               TextStyle(
                                                            fontSize: 15,
                                                            color: package.price == 0 ? Colors.red : Colors.grey,
                                                          ),
                                                        ),
                                                      if (package.qty != null)
                                                        Text(
                                                          "Quantity: ${package.qty}",
                                                          style:
                                                              const TextStyle(
                                                            fontSize: 15,
                                                            color: Colors.grey,
                                                          ),
                                                        ),
                                                    ],
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

                          const SizedBox(
                            height: 15,
                          ),

                          /// Payment Info
                          Row(
                            children: [
                              const Icon(Icons.article,
                                  color: Colors.deepOrange),
                              const SizedBox(width: 10),
                              const Text(
                                "Payment Info",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.deepOrange,
                                ),
                              ),
                              const Spacer(),
                              InkWell(
                                onTap: () {
                                  _showItineraryBottomsheet();
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 8, horizontal: 8),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    color: Colors.orange, // Background color
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.red.shade100,
                                        blurRadius: 4,
                                        spreadRadius: 2,
                                        offset: const Offset(2, 2),
                                      ),
                                    ],
                                  ),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.temple_buddhist_sharp,
                                          color: Colors.white,
                                          size: 16), // Refund policy icon
                                      SizedBox(width: 4), // Spacing
                                      Text(
                                        "Itinerary",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      //SizedBox(width: 5),
                                      //Icon(Icons.arrow_forward_ios, color: Colors.white, size: 12), // Arrow icon
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 15,
                          ),

                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              color: Colors.white,
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 4,
                                  spreadRadius: 1,
                                  offset: Offset(2, 2),
                                ),
                              ],
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(15),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(Icons.payment,
                                          color: Colors.grey.shade600,
                                          size: 18),
                                      const SizedBox(width: 8),
                                      const Text(
                                        "Payment Status: ",
                                        style: TextStyle(
                                            color: Colors.grey,
                                            fontWeight: FontWeight.w600),
                                      ),
                                      Text(
                                        tourOrderData?.data!.amountStatus == 1
                                            ? "Paid"
                                            : "Pending",
                                        style: TextStyle(
                                          color: tourOrderData
                                                      ?.data!.amountStatus ==
                                                  1
                                              ? Colors.green
                                              : Colors.red,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      if (tourOrderData?.data!.partPayment !=
                                          "full")
                                        const Text(
                                          " / Partially",
                                          style: TextStyle(
                                              color: Colors.blue,
                                              fontWeight: FontWeight.w600),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),

                                  // Payment Method
                                  Row(
                                    children: [
                                      const Icon(Icons.credit_card,
                                          color: Colors.orange, size: 18),
                                      const SizedBox(width: 8),
                                      const Text(
                                        "Payment Method: ",
                                        style: TextStyle(
                                            color: Colors.grey,
                                            fontWeight: FontWeight.w600),
                                      ),
                                      Text(
                                        tourOrderData?.data!.transactionId ==
                                                "wallet"
                                            ? "Wallet"
                                            : "Online",
                                        style: const TextStyle(
                                            color: Colors.blue,
                                            fontWeight: FontWeight.w600),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),

                                  // Refund Status (Only Show if Refunded)
                                  if (tourOrderData?.data!.refundStatus == 1)
                                    const Row(
                                      children: [
                                        Icon(Icons.receipt,
                                            color: Colors.orange, size: 18),
                                        SizedBox(width: 8),
                                        Text(
                                          "Refund Status: ",
                                          style: TextStyle(
                                              color: Colors.grey,
                                              fontWeight: FontWeight.w600),
                                        ),
                                        Text(
                                          "Refunded",
                                          style: TextStyle(
                                              color: Colors.orange,
                                              fontWeight: FontWeight.w600),
                                        ),
                                      ],
                                    ),
                                  const SizedBox(height: 10),

                                  // Tour Details
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "${tourOrderData?.data!.enTourName}",
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w500,
                                                color: Colors.black,
                                                fontSize: 14,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              maxLines: 1,
                                            ),
                                            const SizedBox(height: 5),
                                            Row(
                                              children: [
                                                const Icon(Icons.date_range,
                                                    color: Colors.orange,
                                                    size: 16),
                                                const SizedBox(width: 5),
                                                Text(
                                                  "${tourOrderData?.data!.pickupDate} | ${tourOrderData?.data!.pickupTime}",
                                                  //"${formatDate("${tourOrderData?.data!.pickupDate}")}  |  ${tourOrderData?.data!.pickupTime}",
                                                  style: const TextStyle(
                                                      color: Colors.grey,
                                                      fontWeight:
                                                          FontWeight.w600),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 8),

                                            // Pickup Address
                                            Row(
                                              children: [
                                                const Icon(Icons.location_on,
                                                    color: Colors.red,
                                                    size: 16),
                                                const SizedBox(width: 5),
                                                Expanded(
                                                  child: Text(
                                                    "${tourOrderData?.data!.pickupAddress}",
                                                    style: const TextStyle(
                                                        color: Colors.black87,
                                                        fontSize: 12),
                                                    maxLines: 2,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),

                                  const SizedBox(height: 10),
                                  Divider(
                                    color: Colors.grey.shade300,
                                  ),
                                  const SizedBox(height: 5),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      // Share Button (Only Show if Not Refunded)
                                      if (tourOrderData?.data!.refundStatus !=
                                          1)
                                        InkWell(
                                          onTap: () {
                                            shareInvoice(context);
                                          },
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 8, horizontal: 8),
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                  color: Colors.green),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              color: Colors
                                                  .white, // Background color                                        borderRadius: BorderRadius.circular(8), // Rounded corners
                                              // boxShadow: [
                                              //   BoxShadow(
                                              //     color: Colors.green.shade100,
                                              //     blurRadius: 4,
                                              //     spreadRadius: 2,
                                              //     offset: const Offset(2, 2),
                                              //   ),
                                              // ],
                                            ),
                                            child: const Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(Icons.share,
                                                    color: Colors.black,
                                                    size:
                                                        16), // Refund policy icon
                                                SizedBox(width: 4), // Spacing
                                                Text(
                                                  "Share",
                                                  style: TextStyle(
                                                    color: Colors.green,
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                                //SizedBox(width: 5),
                                                // Icon(Icons.arrow_forward_ios, color: Colors.white, size: 12), // Arrow icon
                                              ],
                                            ),
                                          ),
                                        ),
                                      const SizedBox(
                                        width: 5,
                                      ),
                                      // Share Button (Only Show if Not Refunded)
                                      if (tourOrderData?.data!.refundStatus !=
                                          1)
                                        InkWell(
                                          onTap: () {
                                            openInvoice(context, "${tourOrderData?.data?.invoiceUrl}");
                                          },
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 8, horizontal: 8),
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                  color: Colors.blue),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              color: Colors
                                                  .white, // Background color                                        borderRadius: BorderRadius.circular(8), // Rounded corners
                                              // boxShadow:  [
                                              //   BoxShadow(
                                              //     color: Colors.blue.shade100,
                                              //     blurRadius: 4,
                                              //     spreadRadius: 2,
                                              //     offset: const Offset(2, 2),
                                              //   ),
                                              // ],
                                            ),
                                            child: const Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(Icons.remove_red_eye,
                                                    color: Colors.black,
                                                    size:
                                                        16), // Refund policy icon
                                                SizedBox(width: 4), // Spacing
                                                Text(
                                                  "View Invoice",
                                                  style: TextStyle(
                                                    color: Colors.blue,
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                                //SizedBox(width: 5),
                                                // Icon(Icons.arrow_forward_ios, color: Colors.white, size: 12), // Arrow icon
                                              ],
                                            ),
                                          ),
                                        ),
                                      const SizedBox(
                                        width: 5,
                                      ),
                                      tourOrderData?.data!.refundStatus == 1
                                          ? const SizedBox()
                                          : InkWell(
                                              onTap: () {
                                                showRefundPolicyBottomSheet(
                                                    context);
                                              },
                                              child: Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 8,
                                                        horizontal: 8),
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                  border: Border.all(
                                                      color: Colors.red),
                                                  color: Colors
                                                      .white, // Background color
                                                  // boxShadow:  [
                                                  //   BoxShadow(
                                                  //     color: Colors.red.shade100,
                                                  //     blurRadius: 4,
                                                  //     spreadRadius: 2,
                                                  //     offset: const Offset(2, 2),
                                                  //   ),
                                                  // ],
                                                ),
                                                child: const Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    Icon(Icons.policy,
                                                        color: Colors.black,
                                                        size:
                                                            16), // Refund policy icon
                                                    SizedBox(
                                                        width: 4), // Spacing
                                                    Text(
                                                      "Refund",
                                                      style: TextStyle(
                                                        color: Colors.red,
                                                        fontSize: 14,
                                                        fontWeight: FontWeight.w600,
                                                      ),
                                                    ),
                                                    //SizedBox(width: 5),
                                                    //Icon(Icons.arrow_forward_ios, color: Colors.white, size: 12), // Arrow icon
                                                  ],
                                                ),
                                              ),
                                            ),
                                    ],
                                  )
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(
                            height: 10,
                          ),
                          const Row(
                            children: [
                              Icon(
                                Icons.pending_actions_rounded,
                                color: Colors.deepOrange,
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Text("Bill Details",
                                  style: TextStyle(
                                      fontSize: 20,
                                      overflow: TextOverflow.ellipsis,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.deepOrange)),
                            ],
                          ),
                          const SizedBox(
                            height: 15,
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
                                Row(
                                  children: [
                                    const Text("Total Amount",
                                        style: TextStyle(
                                            fontSize: 16,
                                            overflow: TextOverflow.ellipsis,
                                            color: Colors.green)),
                                    const Spacer(),
                                    Text(
                                        "₹${((tourOrderData!.data!.totalAmount ?? 0).toStringAsFixed(2))}",
                                        style: const TextStyle(
                                            fontSize: 18,
                                            overflow: TextOverflow.ellipsis,
                                            color: Colors.green)),
                                  ],
                                ),
                                const Divider(
                                  color: Colors.grey,
                                ),
                                const SizedBox(
                                  height: 5,
                                ),
                                Row(
                                  children: [
                                    const Text("Coupon Discount",
                                        style: TextStyle(
                                            fontSize: 16,
                                            overflow: TextOverflow.ellipsis,
                                            color: Colors.red)),
                                    const Spacer(),
                                    Text(
                                      "- ₹${double.parse(tourOrderData!.data!.couponAmount.toString()).toStringAsFixed(2)}",
                                      style: const TextStyle(
                                        fontSize: 18,
                                        overflow: TextOverflow.ellipsis,
                                        color: Colors.red,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(
                                  height: 5,
                                ),
                                Row(
                                  children: [
                                    const Text("Amount Paid",
                                        style: TextStyle(
                                            fontSize: 16,
                                            overflow: TextOverflow.ellipsis,
                                            color: Colors.black)),
                                    const Spacer(),
                                    Text(
                                      "₹${double.parse(tourOrderData!.data!.payAmount.toString()).toStringAsFixed(2)}",
                                      style: const TextStyle(
                                        fontSize: 18,
                                        overflow: TextOverflow.ellipsis,
                                        color: Colors.red,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(
                                  height: 5,
                                ),
                                const Divider(
                                  color: Colors.grey,
                                ),
                                tourOrderData!.data!.partPayment == "full"
                                    ? const SizedBox.shrink()
                                    : Row(
                                        children: [
                                          const Text("Remaining amount",
                                              style: TextStyle(
                                                  fontSize: 18,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.bold)),
                                          const Spacer(),
                                          Text(
                                              "₹${double.parse(tourOrderData!.data!.remainingAmount.toString()).toStringAsFixed(2)}",
                                              style: const TextStyle(
                                                  fontSize: 18,
                                                  overflow:
                                                      TextOverflow.ellipsis)),
                                        ],
                                      ),
                                tourOrderData?.data!.refundStatus == 1
                                    ? Row(
                                        children: [
                                          const Text("Refunded amount",
                                              style: TextStyle(
                                                  fontSize: 18,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.bold)),
                                          const Spacer(),
                                          Text(
                                              "₹${double.parse(tourOrderData!.data!.refundAmount.toString()).toStringAsFixed(2)}",
                                              style: const TextStyle(
                                                  fontSize: 18,
                                                  overflow:
                                                      TextOverflow.ellipsis)),
                                        ],
                                      )
                                    : const SizedBox()
                              ],
                            ),
                          ),

                          const SizedBox(
                            height: 5,
                          ),

                          tourOrderData?.data!.amountStatus == 1
                              ? Column(
                                  children: [
                                    const SizedBox(
                                      height: 15,
                                    ),
                                    tourOrderData?.data!.reviewStatus == 1
                                        ? Container(
                                            height: 50,
                                            width: double.infinity,
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 5, horizontal: 10),
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(8),
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
                                                CupertinoIcons
                                                    .checkmark_circle_fill,
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
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 5,
                                                      horizontal: 10),
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
                                                      fontWeight:
                                                          FontWeight.w400),
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
                                )
                              : const SizedBox.shrink(),

                          const SizedBox(
                            height: 25,
                          ),
                          const Text(
                              "If you need any kind of help or support regarding Tour booking kindly contact us.",
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
                              child: InkWell(
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
                                          color: Colors.deepOrange)))),
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
