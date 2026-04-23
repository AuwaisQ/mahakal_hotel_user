import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:mahakal/main.dart';
import 'package:mahakal/utill/app_constants.dart';
import 'package:mahakal/utill/flutter_toast_helper.dart';
import 'package:mahakal/utill/razorpay_screen.dart';
import 'package:mahakal/features/auth/controllers/auth_controller.dart';
import 'package:mahakal/features/tour_and_travells/Controller/fetch_coupon_controller.dart';
import 'package:mahakal/features/tour_and_travells/Controller/fetch_wallet_controller.dart';
import 'package:mahakal/features/tour_and_travells/widgets/ApplyCoupon.dart';
import 'package:provider/provider.dart';
import '../../../utill/completed_order_dialog.dart';
import '../../Tickit_Booking/controller/tickit_booking_controller.dart';
import '../../Tickit_Booking/controller/tickit_leadupdate_controller.dart';
import '../../custom_bottom_bar/bottomBar.dart';
import '../../profile/controllers/profile_contrroller.dart';
import '../controller/event_booking_controller.dart';
import '../controller/event_leadupdate_controller.dart';

class EventPaymentScreen extends StatefulWidget {
  final String packageName;
  final String eventName;
  final String eventDate;
  final String eventTime;
  final String eventVenue;
  final int personCount;
  final List<String> seatNumbers;
  final double totalAmount;
  final double amount;
  final String eventId;
  final String venueId;
  final String leadId;
  final String packageId;
  final List<Map<String, String>> devotees;
  final double walletPay;

  const EventPaymentScreen({
    super.key,
    required this.packageName,
    required this.eventName,
    required this.eventDate,
    required this.eventTime,
    required this.eventVenue,
    required this.personCount,
    required this.seatNumbers,
    required this.totalAmount,
    required this.eventId,
    required this.venueId,
    required this.leadId,
    required this.packageId,
    required this.devotees,
    required this.amount,
    required this.walletPay,
  });

  @override
  State<EventPaymentScreen> createState() => _EventPaymentScreenState();
}

class _EventPaymentScreenState extends State<EventPaymentScreen> {
  final razorpayService = RazorpayPaymentService();

  double walletMinusAmount = 0;
  double remainingAmount = 0;
  double finalAmount = 0;
  double deducatedFromWallet = 0;
  int successAmountStatus = 0;
  int naviGateRazorpay = 3;

  // Coupon variables
  bool isCouponApplied = false;
  int couponId = 0;
  int couponAmount = 0;
  double amtAfterDiscount = 0;
  final TextEditingController couponController = TextEditingController();

  // UI state
  bool circularIndicator = false;
  bool walletEnabled = false;

  // User info
  String userId = "";
  String userToken = "";
  String userName = "";
  String userEmail = "";
  String userPhone = "";

  final fetchCouponController =
      Provider.of<FetchCouponController>(Get.context!, listen: false);
  final walletController =
      Provider.of<FetchWalletController>(Get.context!, listen: false);

  List<Map<String, dynamic>> finalDevoteesList = [];

  @override
  void initState() {
    super.initState();
    fetchCouponController.fetchCoupon(
        type: "event", couponUrl: "${AppConstants.tourCouponUrl}");

    // Get user info
    userId = Provider.of<ProfileController>(Get.context!, listen: false).userID;
    userToken =
        Provider.of<AuthController>(Get.context!, listen: false).getUserToken();
    userName =
        Provider.of<ProfileController>(Get.context!, listen: false).userNAME;
    userEmail =
        Provider.of<ProfileController>(Get.context!, listen: false).userEMAIL;
    userPhone =
        Provider.of<ProfileController>(Get.context!, listen: false).userPHONE;

    prepareFinalDevotees();
    calculateAmounts();
  }

  void prepareFinalDevotees() {
    finalDevoteesList.clear();

    int seatLength = widget.seatNumbers.length;
    int devoteeLength = widget.devotees.length;

    int loopLength =
        seatLength > 0 ? seatLength : devoteeLength; // priority seats ko

    for (int i = 0; i < loopLength; i++) {
      Map<String, String>? devotee =
          i < devoteeLength ? widget.devotees[i] : null;

      String row = "";
      String seat = "";

      if (seatLength > 0 && i < seatLength) {
        if (widget.seatNumbers[i].contains("-")) {
          final parts = widget.seatNumbers[i].split("-");
          row = parts[0];
          seat = parts[1];
        }
      }

      finalDevoteesList.add({
        "name": devotee?["name"] ?? "Guest",
        "phone": devotee?["phone"] ?? "",
        "aadhar": devotee?["aadhar"] ?? "",
        "aadhar_verify_status": devotee?["aadhar_verify"] ?? "0",
        "row": row,
        "seat": seat,
      });
    }

    print("Final Devotees List: $finalDevoteesList");
  }

  void calculateAmounts() {
    double baseAmount = widget.totalAmount;

    // Apply coupon discount first
    if (isCouponApplied) {
      baseAmount = amtAfterDiscount;
    }

    ///  WALLET LOGIC (Only if Apply Wallet is ON)
    if (walletEnabled) {
      deducatedFromWallet =
          widget.walletPay >= baseAmount ? baseAmount : widget.walletPay;
    } else {
      deducatedFromWallet = 0;
    }

    remainingAmount = baseAmount - deducatedFromWallet;

    ///  PAYMENT TYPE LOGIC
    if (walletEnabled && remainingAmount == 0) {
      // Only Wallet Used
      successAmountStatus = 1;
      naviGateRazorpay = 1;
    } else if (walletEnabled && deducatedFromWallet > 0) {
      // Wallet + Online
      successAmountStatus = 1;
      naviGateRazorpay = 2;
    } else {
      // Only Online
      successAmountStatus = 0;
      naviGateRazorpay = 3;
    }

    setState(() {});
  }

  Future<void> applyCoupon(String code) async {
    final response = await http.post(
      Uri.parse("${AppConstants.baseUrl}${AppConstants.eventCouponApplyUrl}"),
      headers: {
        'Authorization': 'Bearer $userToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        "user_id": userId,
        "coupon_code": code,
        "amount": widget.totalAmount.toString(),
      }),
    );

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);

      if (data["status"] == 1) {
        setState(() {
          couponAmount = data["data"]["coupon_amount"];
          amtAfterDiscount = (data["data"]["final_amount"] as num).toDouble();
          couponId = data["data"]["coupon_id"];
          isCouponApplied = true;
        });

        Navigator.pop(context);
        ToastHelper.showSuccess("Coupon Applied Successfully! 👍");
        calculateAmounts();
      } else {
        ToastHelper.showError("${data["message"]}");
      }
    } else {
      ToastHelper.showError("Something went wrong. Please try again.");
    }
  }

  void showCouponSheet() {
    showCouponBottomSheet(
      context: context,
      couponController: couponController,
      couponModelList: fetchCouponController.couponlist,
      selectedCabTotalAmount: widget.totalAmount.toString(),
      onApplyCoupon: (code, amount) {
        applyCoupon(couponController.text);
      },
      onCouponTap: (code, type) {
        // Handle coupon type selection if needed
      },
    );
  }

  void removeCoupon() {
    setState(() {
      isCouponApplied = false;
      couponAmount = 0;
      amtAfterDiscount = 0;
    });
    calculateAmounts();
  }

  Future<void> processPayment() async {
    final bookingController =
    Provider.of<EventBookingController>(context, listen: false);

    // Wallet Only Payment
    if (remainingAmount == 0 && widget.walletPay >= widget.totalAmount) {
      setState(() => circularIndicator = true);

      print("Wallet Only Payment $successAmountStatus");

      bool success = await bookingController.eventBooking(
        userId: userId,
        eventId: widget.eventId.toString(),
        venueId: widget.venueId.toString(),
        packageId: widget.packageId.toString(),
        noOfSeats: widget.personCount,
        amount: widget.totalAmount.toString(),
        leadId: widget.leadId.toString(),
        walletType: "$successAmountStatus",
        transactionId: "wallet",
        onlineAmount: "0", couponAmount: "$couponAmount", couponId: "$couponId",
      );

      setState(() => circularIndicator = false);

      if (success) {
        ToastHelper.showSuccess("Booking Successful");

        Navigator.of(context).pushReplacement(
          CupertinoPageRoute(
              builder: (BuildContext context) =>
              const BottomBar(pageIndex: 0)),
        );

        showDialog(
          context: context,
          builder: (context) => bookingSuccessDialog(
            context: context,
            tabIndex: 5,
            title: 'Event Booked!',
            message: 'Your Event tickets have been successfully booked.',
          ),
          barrierDismissible: true,
        );
      } else {
        ToastHelper.showError("Booking Failed");
      }
    }

    // Wallet + Online Payment
    else if (naviGateRazorpay == 2) {
      print("Wallet + Online Payment $successAmountStatus");

      razorpayService.openCheckout(
        amount: remainingAmount,
        razorpayKey: AppConstants.razorpayLive,
        onSuccess: (response) async {
          setState(() => circularIndicator = true);

          bool success = await bookingController.eventBooking(
            userId: userId,
            eventId: widget.eventId.toString(),
            venueId: widget.venueId.toString(),
            packageId: widget.packageId.toString(),
            noOfSeats: widget.personCount,
            amount: widget.totalAmount.toString(),
            leadId: widget.leadId.toString(),
            walletType: "$successAmountStatus",
            transactionId: response.paymentId ?? "",
            onlineAmount: remainingAmount.toString(), couponAmount: '$couponAmount', couponId: '$couponId',
          );

          setState(() => circularIndicator = false);

          if (success) {
            ToastHelper.showSuccess("Booking Successful");

            Navigator.of(context).pushReplacement(
              CupertinoPageRoute(
                  builder: (BuildContext context) =>
                  const BottomBar(pageIndex: 0)),
            );

            showDialog(
              context: context,
              builder: (context) => bookingSuccessDialog(
                context: context,
                tabIndex: 5,
                title: 'Event Booked!',
                message: 'Your Event tickets have been successfully booked.',
              ),
              barrierDismissible: true,
            );
          } else {
            ToastHelper.showError("Booking Failed");
          }
        },
        onFailure: (response) {
          setState(() => circularIndicator = false);
          ToastHelper.showError("Payment failed. Please try again.");
        },
        onExternalWallet: (response) {
          print("Wallet: ${response.walletName}");
        },
        description: 'Event Ticket Booking',
      );
    }

    // Online Only Payment
    else {
      print("Online Only Payment $successAmountStatus");

      razorpayService.openCheckout(
        amount: remainingAmount,
        razorpayKey: AppConstants.razorpayLive,
        onSuccess: (response) async {
          setState(() => circularIndicator = true);

          bool success = await bookingController.eventBooking(
            userId: userId,
            eventId: widget.eventId.toString(),
            venueId: widget.venueId.toString(),
            packageId: widget.packageId.toString(),
            noOfSeats: widget.personCount,
            amount: widget.totalAmount.toString(),
            leadId: widget.leadId.toString(),
            walletType: "$successAmountStatus",
            transactionId: response.paymentId ?? "",
            onlineAmount: remainingAmount.toString(), couponAmount: '$couponAmount', couponId: '$couponId',
          );

          setState(() => circularIndicator = false);

          if (success) {
            ToastHelper.showSuccess("Booking Successful");

            Navigator.of(context).pushReplacement(
              CupertinoPageRoute(
                  builder: (BuildContext context) =>
                  const BottomBar(pageIndex: 0)),
            );

            showDialog(
              context: context,
              builder: (context) => bookingSuccessDialog(
                context: context,
                tabIndex: 5,
                title: 'Event Booked!',
                message: 'Your Event tickets have been successfully booked.',
              ),
              barrierDismissible: true,
            );
          } else {
            ToastHelper.showError("Booking Failed");
          }
        },
        onFailure: (response) {
          setState(() => circularIndicator = false);
          ToastHelper.showError("Payment failed. Please try again.");
        },
        onExternalWallet: (response) {
          print("Wallet: ${response.walletName}");
        },
        description: 'Event Booking',
      );
    }
  }

  void showPaymentConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            "Confirm Payment",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
          content: Text(
            remainingAmount == 0
                ? "Total Amount: ${NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0).format(deducatedFromWallet)}"
                : "Total Amount: ${NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0).format(remainingAmount)}",
            style: const TextStyle(fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              style: TextButton.styleFrom(
                foregroundColor: Colors.grey[700],
              ),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                processPayment();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text("Pay Now"),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTicketInfoCard() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 8,
            spreadRadius: 2,
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Event Name
          Text(
            widget.eventName,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
          const SizedBox(height: 12),

          // Package Name
          Row(
            children: [
              const Icon(Icons.confirmation_number,
                  size: 20, color: Colors.green),
              const SizedBox(width: 8),
              Text(
                widget.packageName,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Date and Time
          Row(
            children: [
              const Icon(Icons.calendar_today, size: 20, color: Colors.blue),
              const SizedBox(width: 8),
              Text(
                widget.eventDate,
                style: const TextStyle(fontSize: 14),
              ),
              const SizedBox(width: 16),
              const Icon(Icons.access_time, size: 20, color: Colors.blue),
              const SizedBox(width: 8),
              Text(
                widget.eventTime,
                style: const TextStyle(fontSize: 14),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Venue
          Row(
            children: [
              const Icon(Icons.location_on, size: 20, color: Colors.red),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  widget.eventVenue,
                  style: const TextStyle(fontSize: 14),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          Divider(color: Colors.grey.shade300),
          const SizedBox(height: 8),

          // Person Count and Seats
          Row(
            children: [
              const Icon(Icons.people, size: 20, color: Colors.purple),
              const SizedBox(width: 8),
              Text(
                "${widget.personCount} Person${widget.personCount > 1 ? 's' : ''}",
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              if (widget.seatNumbers.isNotEmpty)
                Row(
                  children: [
                    const Icon(Icons.chair, size: 20, color: Colors.purple),
                    const SizedBox(width: 8),
                    Text(
                      "${widget.seatNumbers.length} Seat${widget.seatNumbers.length > 1 ? 's' : ''}",
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                )
            ],
          ),

          // Seat Numbers
          if (widget.seatNumbers.isNotEmpty) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: widget.seatNumbers.map((seat) {
                return Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.blue.shade100),
                  ),
                  child: Text(
                    seat,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Colors.blue,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCouponSection() {
    return isCouponApplied
        ? InkWell(
            onTap: () => removeCoupon(),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.green.shade50,
                border: Border.all(color: Colors.green.shade300, width: 1.5),
              ),
              child: Row(
                children: [
                  const Icon(Icons.discount, color: Colors.green),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Coupon Applied",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                        Text(
                          "₹$couponAmount Discount Applied",
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => removeCoupon(),
                    icon: const Icon(Icons.close, color: Colors.green),
                  ),
                ],
              ),
            ),
          )
        : InkWell(
            onTap: () => showCouponSheet(),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.white,
                border: Border.all(color: Colors.blue, width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.shade100,
                    blurRadius: 4,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: Row(
                children: [
                  const Icon(Icons.discount_outlined, color: Colors.blue),
                  const SizedBox(width: 12),
                  const Text(
                    "Apply Coupon",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.blue,
                    ),
                  ),
                  const Spacer(),
                  const Text(
                    "Add",
                    style: TextStyle(color: Colors.blue, fontSize: 14),
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.add, color: Colors.blue, size: 20),
                ],
              ),
            ),
          );
  }

  Widget _buildBillDetails() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 8,
            spreadRadius: 2,
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Bill Details",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
          const SizedBox(height: 16),

          // Base Amount
          Row(
            children: [
              const Text(
                "Ticket Amount",
                style: TextStyle(fontSize: 16),
              ),
              const Spacer(),
              Text(
                "${widget.personCount} x ₹${widget.amount.toStringAsFixed(0)}",
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          Row(
            children: [
              const Text(
                "Total Ticket Amount",
                style: TextStyle(fontSize: 16),
              ),
              const Spacer(),
              Text(
                "${NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0).format(widget.totalAmount)}",
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Coupon Discount
          if (isCouponApplied) ...[
            Row(
              children: [
                const Text(
                  "Coupon Discount",
                  style: TextStyle(fontSize: 16),
                ),
                const Spacer(),
                Text(
                  "- ${NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0).format(couponAmount)}",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],

          // Wallet Balance
          if(walletEnabled)
            Column(
              children: [
                Row(
                  children: [
                    const Text(
                      "Wallet Balance",
                      style: TextStyle(fontSize: 16),
                    ),
                    const Spacer(),
                    Text(
                      "${NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0).format(widget.walletPay)}",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
              ],
            ),

          // Amount from Wallet
          if (deducatedFromWallet > 0) ...[
            Row(
              children: [
                const Text(
                  "Paid via Wallet",
                  style: TextStyle(fontSize: 16),
                ),
                const Spacer(),
                Text(
                  "- ${NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0).format(deducatedFromWallet)}",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.red,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],

          Divider(color: Colors.grey.shade300),
          const SizedBox(height: 8),

          // Total Payable
          if (remainingAmount != 0)
            Row(
              children: [
                const Text(
                  "Total Payable",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Text(
                  "${NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0).format(remainingAmount)}",
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildPaymentButton() {
    return Container(
      height: 80,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            blurRadius: 10,
            spreadRadius: 2,
            offset: const Offset(0, -2),
          ),
        ],
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: Row(
        children: [
          if (remainingAmount != 0)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "${NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0).format(remainingAmount)}",
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                  Text(
                    widget.packageName,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          //const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton(
              onPressed: () async {
                print("Button Clicked");

                final updateController = Provider.of<EventLeadUpdateController>(
                    context,
                    listen: false);

                print("lead id: ${widget.leadId}");
                print("Seats: ${widget.personCount}");
                print("Amount: ${widget.totalAmount}");

                bool success = await updateController.updateLead(
                  leadId: widget.leadId.toString(),
                  noOfSeats: widget.personCount,
                  amount: widget.totalAmount.toString(),
                  members: finalDevoteesList,
                );

                if (success) {
                  showPaymentConfirmationDialog();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Failed to update lead")),
                  );
                }
              },
              // onPressed: () async {
              //
              //     print("Button Clicked");
              //     final updateController = Provider.of<UpdateLeadController>(context, listen: false);
              //
              //     print("lead id: ${widget.leadId}");
              //     print("package id: ${widget.packageId}");
              //     print("venuew id: ${widget.venueId}");
              //     print("Qty: ${widget.personCount}");
              //     print("amount: ${widget.amount}");
              //     print("coupon amount: $couponAmount");
              //     print("coupon id: ${couponId}");
              //     print("date: ${widget.eventDate}");
              //     print("formate date: ${DateFormat("dd MMM").parse(widget.eventDate)}");
              //
              //     DateTime parsedDate =
              //     DateFormat("dd MMM yyyy").parse(widget.eventDate);
              //
              //     String finalDate =
              //     DateFormat("dd/MM/yyyy").format(parsedDate);
              //
              //     print(finalDate); // 12/02/2026
              //
              //     bool success = await updateController.updateLead(
              //       leadId: widget.leadId,
              //       packageId: widget.packageId,
              //       venueId: widget.venueId,
              //       qty: widget.personCount,
              //       amount: widget.amount,
              //       couponAmount: double.parse(couponAmount.toString()),
              //       couponId: "${couponId}",
              //       totalAmount: isCouponApplied ? amtAfterDiscount : widget.totalAmount,
              //       date: finalDate,
              //       userInformation: finalDevoteesList,
              //     );
              //
              //     if (success) {
              //       showPaymentConfirmationDialog();
              //     } else {
              //       ScaffoldMessenger.of(context).showSnackBar(
              //         const SnackBar(content: Text("Failed to update lead")),
              //       );
              //     }
              //   },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 16),
                elevation: 4,
              ),
              child: circularIndicator
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          remainingAmount == 0 ? "Pay From Wallet" : "Pay Now",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(width: 8),
                        Icon(Icons.arrow_forward, size: 18),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWalletButton() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          /// LEFT TEXT
          const Text(
            "Apply Wallet",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),

          /// RIGHT SWITCH
          Transform.scale(
            scale: 1.1,
            child: Switch(
              value: walletEnabled,
              activeColor: Colors.white,
              activeTrackColor: const Color(0xFFFF6B00), // Deep Orange
              inactiveThumbColor: Colors.white,
              inactiveTrackColor: Colors.grey.shade300,
              onChanged: (value) {
                setState(() {
                  walletEnabled = value;
                });
                calculateAmounts();
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: _buildPaymentButton(),
      appBar: AppBar(
        backgroundColor: Colors.blue,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Payment Summary',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        elevation: 0,
      ),
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Ticket Information
                  _buildTicketInfoCard(),
                  const SizedBox(height: 20),

                  // Coupon Section
                  _buildCouponSection(),
                  const SizedBox(height: 20),

                  if (widget.walletPay > 0)
                    Column(
                      children: [
                        _buildWalletButton(),
                        const SizedBox(height: 20),
                      ],
                    ),

                  // Bill Details
                  _buildBillDetails(),
                  const SizedBox(height: 100), // Space for bottom button
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
