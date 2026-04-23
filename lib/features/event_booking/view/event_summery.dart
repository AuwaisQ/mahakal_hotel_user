import 'dart:convert';
import 'dart:math';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:shimmer/shimmer.dart';
import '../../../data/datasource/remote/http/httpClient.dart';
import '../../../main.dart';
import 'package:http/http.dart' as http;
import '../../../utill/app_constants.dart';
import '../../../utill/completed_order_dialog.dart';
import '../../../utill/flutter_toast_helper.dart';
import '../../../utill/razorpay_screen.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../custom_bottom_bar/bottomBar.dart';
import '../../profile/controllers/profile_contrroller.dart';
import '../../tour_and_travells/Controller/fetch_coupon_controller.dart';
import '../../tour_and_travells/Controller/fetch_wallet_controller.dart';
import '../../tour_and_travells/Controller/lanaguage_provider.dart';
import '../../tour_and_travells/widgets/ApplyCoupon.dart';
import '../controller/event_auditorium_controller.dart';
import '../controller/event_package_controller.dart';
import '../model/event_lead_model.dart';
import '../model/event_package_model.dart';
import '../model/single_details_model.dart' hide Data;
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../model/success_event_amount.dart';
import 'event_payment_screen.dart';
import 'event_layout_screen.dart';
import 'home_page/event_home.dart';

class EventSummery extends StatefulWidget {
  final int eventId;
  final dynamic venueId;
  final String? eventName;
  final String? eventVenue;
  final String? eventhiVenue;
  final String aadharStatus;

  EventSummery(
      {super.key,
      required this.eventName,
      this.eventVenue,
      this.eventhiVenue,
      required this.eventId,
      required this.venueId,
      required this.aadharStatus});

  @override
  State<EventSummery> createState() => _EventSummeryState();
}

class _EventSummeryState extends State<EventSummery> {
  List<Map<String, String>> devotees = [];
  TextEditingController nameController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController phoneController2 = TextEditingController();
  TextEditingController aadharController = TextEditingController();
  TextEditingController aadharController2 = TextEditingController();

  String userId = "";
  String userNAME = "";
  String userEMAIL = "";
  String userPHONE = "";
  String userToken = "";

  int packageQty = 0;
  double walletPay = 0;

  bool isInfoExpanded = false;
  bool isLoading = false;
  bool isverify = false;

  final TextEditingController couponController = TextEditingController();
  final fetchCouponController =
      Provider.of<FetchCouponController>(Get.context!, listen: false);
  final walletController =
      Provider.of<FetchWalletController>(Get.context!, listen: false);

  int selectedDateIndex = 0;
  int auditoriumQuantity = 0;

  Map<int, int> packageQuantity = {};

  double totalAmount = 0;

  EventLeadModel? eventLead;
  SuccessEventAmount? successEventAmount;

  String _formatAadhar(String aadhar) {
    if (aadhar == "N/A") return aadhar;

    // Remove existing hyphens/spaces (if any)
    String cleaned = aadhar.replaceAll(RegExp(r'[-\s]'), '');

    // Add hyphen every 4 digits
    String formatted = '';
    for (int i = 0; i < cleaned.length; i++) {
      if (i > 0 && i % 4 == 0) formatted += '-';
      formatted += cleaned[i];
    }

    return formatted;
  }

  void getAadhar(String aadharNumber, BuildContext context,
      StateSetter modalSetter) async {
    var res = await HttpService().postApi(AppConstants.sendAadharOtp, {
      "aadhaar_number": aadharNumber,
    });
    print("Api response data place order $res");
    if (res["status"] == 1) {
      Navigator.pop(context);
      String id = res["data"]["request_id"].toString();
      Fluttertoast.showToast(
          msg: "Send OTP",
          backgroundColor: Colors.green,
          textColor: Colors.white);
      showOtpVerificationDialog(context, id);
    }
    if (res["status"] == 2) {
      // Navigator.pop(context);
      String name = res["data"]["name"];
      String aadhar = res["data"]["aadhar"].toString();
      setState(() {
        devotees.add({
          'name': name,
          'phone': phoneController2.text.trim(),
          'aadhar': aadhar,
          'aadhar_verify': "1",
        });
      });
      Navigator.pop(context);
      Fluttertoast.showToast(
          msg: "Success",
          backgroundColor: Colors.green,
          textColor: Colors.white);
      phoneController2.clear();
      aadharController2.clear();
      // billAmount = double.parse(widget.billAmount) * devotees.length;
      // walletMinusAmount = max(walletPay - billAmount, 0);
      // finalAmount = (walletPay - billAmount).abs();
    }
    if (res["status"] == 0) {
      Fluttertoast.showToast(
          msg: "Invalid Aadhaar Number",
          backgroundColor: Colors.red,
          textColor: Colors.white);
      modalSetter(() {
        isverify = false;
      });
    }
    print("${res['data']['message']} ${res['status']} Print status");
  }

  void verifyOtp(String otp, String id, StateSetter modalSetter,
      BuildContext context) async {
    var res = await HttpService().postApi(
        AppConstants.sendAadharOtpVerify, {"otp": otp, "request_id": id});
    print("Api response data verify otp $res");
    if (res["status"] == 1) {
      String name = res["data"]["data"]["full_name"];
      String aadhar = res["data"]["data"]["aadhaar_number"];
      Navigator.pop(context);
      setState(() {
        devotees.add({
          'name': name,
          'phone': phoneController2.text.trim(),
          'aadhar': aadhar,
          'aadhar_verify': "1",
        });
      });
      Fluttertoast.showToast(
          msg: "Success",
          backgroundColor: Colors.green,
          textColor: Colors.white);
      phoneController2.clear();
      aadharController2.clear();
      // billAmount = double.parse(widget.billAmount) * devotees.length;
      // walletMinusAmount = max(walletPay - billAmount, 0);
      // finalAmount = (walletPay - billAmount).abs();
      modalSetter(() {
        isverify = false;
      });
    } else {
      modalSetter(() {
        isverify = false;
      });
      Fluttertoast.showToast(
          msg: "Invalid request",
          backgroundColor: Colors.red,
          textColor: Colors.white);
    }
  }

  void _showAddDevoteeDialog(BuildContext context) {
    int _verificationStatus = 1;

    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (context) {
          return StatefulBuilder(
            builder: (BuildContext context, StateSetter modalSetter) {
              return Padding(
                padding: MediaQuery.of(context).viewInsets,
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(16),
                        topRight: const Radius.circular(16)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Dialog Header
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Add New Devotee',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close, size: 24),
                              onPressed: () {
                                modalSetter(() {
                                  isverify = false;
                                });
                                Navigator.pop(context);
                              },
                            ),
                          ],
                        ),
                        Divider(
                          color: Colors.grey.shade300,
                        ),

                        Row(
                          children: [
                            widget.aadharStatus == "1"
                                ? Expanded(
                                    child: Container(
                                      margin: EdgeInsets.only(right: 8),
                                      decoration: BoxDecoration(
                                        color: _verificationStatus == 1
                                            ? Colors.blue.withOpacity(0.1)
                                            : Colors.grey.withOpacity(0.05),
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: _verificationStatus == 1
                                              ? Colors.blue
                                              : Colors.grey.withOpacity(0.3),
                                          width: 1,
                                        ),
                                      ),
                                      child: RadioListTile<int>(
                                        dense: true,
                                        contentPadding:
                                            EdgeInsets.symmetric(horizontal: 8),
                                        activeColor: Colors.blue,
                                        title: Text(
                                          "Verified Aadhaar",
                                          style: TextStyle(
                                            fontWeight: _verificationStatus == 1
                                                ? FontWeight.bold
                                                : FontWeight.normal,
                                          ),
                                        ),
                                        value: 1,
                                        groupValue: _verificationStatus,
                                        onChanged: (int? value) {
                                          modalSetter(() {
                                            _verificationStatus = value!;
                                          });
                                        },
                                      ),
                                    ),
                                  )
                                : Expanded(
                                    child: Container(
                                      margin: EdgeInsets.only(left: 8),
                                      decoration: BoxDecoration(
                                        color: _verificationStatus == 0
                                            ? Colors.blue.withOpacity(0.1)
                                            : Colors.grey.withOpacity(0.05),
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: _verificationStatus == 0
                                              ? Colors.blue
                                              : Colors.grey.withOpacity(0.3),
                                          width: 1,
                                        ),
                                      ),
                                      child: RadioListTile<int>(
                                        dense: true,
                                        contentPadding:
                                            EdgeInsets.symmetric(horizontal: 8),
                                        activeColor: Colors.blue,
                                        title: Text(
                                          "Non-Verified Aadhaar",
                                          style: TextStyle(
                                            fontWeight: _verificationStatus == 0
                                                ? FontWeight.bold
                                                : FontWeight.normal,
                                          ),
                                        ),
                                        value: 0,
                                        groupValue: _verificationStatus,
                                        onChanged: (int? value) {
                                          modalSetter(() {
                                            _verificationStatus = value!;
                                          });
                                        },
                                      ),
                                    ),
                                  ),
                          ],
                        ),
                        SizedBox(height: 20),

                        if (widget.aadharStatus == "1") ...[
                          Text(
                            'Phone Number',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey.shade700,
                            ),
                          ),
                          const SizedBox(height: 6),
                          TextField(
                            controller: phoneController2,
                            keyboardType: TextInputType.phone,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.grey.shade50,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 14,
                              ),
                              hintText: ' Enter phone number',
                              prefixIcon: const Icon(
                                Icons.phone_rounded,
                                color: Colors.blue,
                              ),
                              counterText: '',
                            ),
                            maxLength: 10,
                          ),
                          const SizedBox(height: 16),

                          Text(
                            'Aadhar Number',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey.shade700,
                            ),
                          ),
                          const SizedBox(height: 6),
                          TextField(
                            controller: aadharController2,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.grey.shade50,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 14,
                              ),
                              hintText: ' Enter 12-digit Aadhar',
                              prefixIcon: const Icon(
                                Icons.credit_card,
                                color: Colors.blue,
                              ),
                              counterText: '',
                            ),
                            maxLength: 12,
                          ),
                          const SizedBox(height: 24),
                          // verify btn
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                String phone = phoneController2.text.trim();
                                String aadhar = aadharController2.text.trim();

                                // Phone validation
                                if (phone.isEmpty) {
                                  Fluttertoast.showToast(
                                    msg: "Phone number is required",
                                    backgroundColor: Colors.red,
                                    textColor: Colors.white,
                                  );
                                  return;
                                }

                                // Allow either 10 digits OR +91 followed by 10 digits
                                final phoneRegex =
                                    RegExp(r'^(?:\+91)?[0-9]{10}$');

                                if (!phoneRegex.hasMatch(phone)) {
                                  Fluttertoast.showToast(
                                    msg:
                                        "Enter a valid phone number (10 digits or +91XXXXXXXXXX)",
                                    backgroundColor: Colors.red,
                                    textColor: Colors.white,
                                  );
                                  return;
                                }

                                // Aadhar validation
                                if (aadhar.isEmpty) {
                                  Fluttertoast.showToast(
                                    msg: "Aadhar number is required",
                                    backgroundColor: Colors.red,
                                    textColor: Colors.white,
                                  );
                                  return;
                                } else if (aadhar.length != 12 ||
                                    !RegExp(r'^[0-9]+$').hasMatch(aadhar)) {
                                  Fluttertoast.showToast(
                                    msg: "Enter a valid 12-digit Aadhar number",
                                    backgroundColor: Colors.red,
                                    textColor: Colors.white,
                                  );
                                  return;
                                }

                                // Check if Aadhar already exists
                                bool exists = devotees.any(
                                    (devotee) => devotee['aadhar'] == aadhar);
                                if (exists) {
                                  Fluttertoast.showToast(
                                    msg: "This Aadhar number is already added",
                                    backgroundColor: Colors.red,
                                    textColor: Colors.white,
                                  );
                                  return;
                                }

                                // If everything is valid
                                modalSetter(() {
                                  isverify = true;
                                });

                                getAadhar(aadhar, context, modalSetter);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                elevation: 0,
                              ),
                              child: isverify
                                  ? const CircularProgressIndicator(
                                      color: Colors.white)
                                  : const Text(
                                      'Verify',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                            ),
                          ),
                        ],

                        if (widget.aadharStatus == "0") ...[
                          // Name Field (Always shown)
                          Text(
                            'Full Name',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey.shade700,
                            ),
                          ),
                          const SizedBox(height: 6),
                          TextField(
                            controller: nameController,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.grey.shade50,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 14,
                              ),
                              hintText: 'Enter full name',
                              prefixIcon: const Icon(
                                Icons.person,
                                color: Colors.blue,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Phone Field (Only shown if devotees list is not empty)
                          if (devotees.isEmpty) ...[
                            Text(
                              'Phone Number',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey.shade700,
                              ),
                            ),
                            const SizedBox(height: 6),
                            TextField(
                              controller: phoneController,
                              keyboardType: TextInputType.phone,
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.grey.shade50,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide.none,
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 14,
                                ),
                                hintText: 'Enter phone number',
                                prefixIcon: const Icon(
                                  Icons.phone,
                                  color: Colors.blue,
                                ),
                                counterText: '',
                              ),
                              maxLength: 10,
                            ),
                            const SizedBox(height: 16),
                          ],

                          // Aadhar Field (Always shown)
                          Text(
                            'Aadhar Number',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey.shade700,
                            ),
                          ),
                          const SizedBox(height: 6),
                          TextField(
                            controller: aadharController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.grey.shade50,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 14,
                              ),
                              hintText: 'Enter 12-digit Aadhar',
                              prefixIcon: const Icon(
                                Icons.credit_card,
                                color: Colors.blue,
                              ),
                              counterText: '',
                            ),
                            maxLength: 12,
                          ),
                          const SizedBox(height: 24),

                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                String name = nameController.text.trim();
                                String phone = phoneController.text.trim();
                                String aadhar = aadharController.text.trim();

                                // Validation rules
                                final phoneRegex = RegExp(
                                    r'^[0-9]{10}$'); // Only 10 digits (no +91)
                                final aadharRegex =
                                    RegExp(r'^[0-9]{12}$'); // 12 digits only

                                // Name validation
                                if (name.isEmpty) {
                                  Fluttertoast.showToast(
                                    msg: "Full name is required",
                                    backgroundColor: Colors.red,
                                    textColor: Colors.white,
                                  );
                                  return;
                                }

                                // If devotees list is empty → phone is required
                                if (devotees.isEmpty) {
                                  if (phone.isEmpty) {
                                    Fluttertoast.showToast(
                                      msg: "Phone number is required",
                                      backgroundColor: Colors.red,
                                      textColor: Colors.white,
                                    );
                                    return;
                                  }

                                  if (!phoneRegex.hasMatch(phone)) {
                                    Fluttertoast.showToast(
                                      msg:
                                          "Enter a valid 10-digit phone number (without +91)",
                                      backgroundColor: Colors.red,
                                      textColor: Colors.white,
                                    );
                                    return;
                                  }
                                }

                                // Aadhaar validation
                                if (aadhar.isEmpty) {
                                  Fluttertoast.showToast(
                                    msg: "Aadhar number is required",
                                    backgroundColor: Colors.red,
                                    textColor: Colors.white,
                                  );
                                  return;
                                }

                                if (!aadharRegex.hasMatch(aadhar)) {
                                  Fluttertoast.showToast(
                                    msg: "Enter a valid 12-digit Aadhar number",
                                    backgroundColor: Colors.red,
                                    textColor: Colors.white,
                                  );
                                  return;
                                }

                                // Check if Aadhaar already exists
                                bool exists = devotees.any(
                                    (devotee) => devotee['aadhar'] == aadhar);
                                if (exists) {
                                  Fluttertoast.showToast(
                                    msg: "This Aadhar number is already added",
                                    backgroundColor: Colors.red,
                                    textColor: Colors.white,
                                  );
                                  return;
                                }

                                // ✅ If all validations pass
                                Navigator.pop(context);
                                setState(() {
                                  devotees.add({
                                    'name': name,
                                    'phone': devotees.isEmpty ? phone : '',
                                    'aadhar': aadhar,
                                    'aadhar_verify': "0",
                                  });
                                });

                                Fluttertoast.showToast(
                                  msg: "Devotee added successfully",
                                  backgroundColor: Colors.green,
                                  textColor: Colors.white,
                                );

                                print("Devotee list item: $devotees");

                                // Clear fields after success
                                nameController.clear();
                                phoneController.clear();
                                aadharController.clear();
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                elevation: 0,
                              ),
                              child: const Text(
                                'Add Devotee',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ]
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        }).then((value) {
      setState(() {
        isverify = false;
      });
    });
  }

  void showOtpVerificationDialog(BuildContext context, String requestId) {
    final otpController = TextEditingController();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        elevation: 8,
        child: StatefulBuilder(
            builder: (BuildContext context, StateSetter modalSetter) {
          return Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header with icon
                Stack(
                  children: [
                    Align(
                      alignment: Alignment.center,
                      child: Icon(
                        Icons.verified_user_rounded,
                        size: 48,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    Positioned(
                      right: 0,
                      child: IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Title
                Text(
                  'OTP Verification',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                ),

                const SizedBox(height: 8),

                // Subtitle
                Text(
                  'Enter the 6-digit code sent to your mobile',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withOpacity(0.7),
                      ),
                ),

                const SizedBox(height: 24),

                // OTP Input Field
                PinCodeTextField(
                  controller: otpController,
                  length: 6,
                  appContext: context,
                  animationType: AnimationType.scale,
                  pinTheme: PinTheme(
                    shape: PinCodeFieldShape.underline,
                    borderRadius: BorderRadius.circular(4),
                    fieldHeight: 50,
                    fieldWidth: 40,
                    activeFillColor: Theme.of(context).colorScheme.surface,
                    activeColor: Theme.of(context).primaryColor,
                    selectedColor: Theme.of(context).primaryColor,
                    inactiveColor: Colors.grey.shade300,
                    selectedFillColor: Theme.of(context).colorScheme.surface,
                    inactiveFillColor: Theme.of(context).colorScheme.surface,
                  ),
                  textStyle: Theme.of(context).textTheme.headlineSmall,
                  backgroundColor: Colors.transparent,
                  enableActiveFill: true,
                  keyboardType: TextInputType.number,
                  animationDuration: const Duration(milliseconds: 200),
                  onChanged: (value) {},
                  beforeTextPaste: (text) => text?.length == 6,
                ),

                const SizedBox(height: 24),

                // Resend and Verify Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () {
                        // Resend OTP logic
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('OTP resent successfully')),
                        );
                        getAadhar(aadharController2.text, context, modalSetter);
                      },
                      child: Text(
                        'Resend OTP',
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: otpController.text.length == 6
                          ? () {
                              modalSetter(() {
                                isverify = true;
                              });
                              verifyOtp(otpController.text, requestId,
                                  modalSetter, context);
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                      child: isverify
                          ? CircularProgressIndicator(
                              color: Colors.white,
                            )
                          : Text(
                              'Verify',
                              style: TextStyle(color: Colors.white),
                            ),
                    ),
                  ],
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  void calculateTotal() {
    final controller = context.read<EventPackageController>();
    final data = controller.eventPackageModel?.data;

    if (data == null) return;

    totalAmount = 0;

    final packages = data.date[selectedDateIndex].packageList;

    for (int i = 0; i < packages.length; i++) {
      int qty = packageQuantity[i] ?? 0;
      double price = double.parse(packages[i].price);

      totalAmount += price * qty;
    }

    setState(() {});
  }

  void increaseQty(int index, int available) {
    int current = packageQuantity[index] ?? 0;

    if (current < available) {
      packageQuantity[index] = current + 1;
      calculateTotal();
    }
  }

  void decreaseQty(int index) {
    int current = packageQuantity[index] ?? 0;

    if (current > 0) {
      packageQuantity[index] = current - 1;
      calculateTotal();
    }
  }

  Future<void> getLeadDetails(
    bool isAuditorium,
    int personQuantity,
    double totalAmount,
    String packageId,
    DateTime selectedDate,
    String selectedTime,
    String packageName,
    String packageAmount,
  ) async {
    setState(() {
      isLoading = true;
    });

    Map<String, dynamic> data = {
      "user_id": userId,
      "event_id": widget.eventId,
      "venue_id": widget.venueId,
      "package_id": isAuditorium ? "" : packageId,
      "no_of_seats": "$personQuantity",
      "amount": isAuditorium ? "0" : totalAmount,
    };

    try {
      final res =
          await HttpService().postApi("${AppConstants.eventLeadUrl}", data);

      if (res.containsKey('status') && res.containsKey('message')) {
        final eventleadModel = EventLeadModel.fromJson(res);

        setState(() {
          eventLead = eventleadModel;
        });

        if (isAuditorium) {
          final controller = context.read<EventAuditoriumController>();

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EventLayoutScreen(
                ticketData: controller.eventAuditoriumModel!,
                personCount: personQuantity,
                venueId: widget.venueId,
                eventId: widget.eventId,
                leadId: eventLead!.id,
                packageId: 0,
                eventName: widget.eventName.toString(),
                eventDate: DateFormat('d MMM yyyy').format(selectedDate),
                eventTime: selectedTime,
                eventVenue: widget.eventVenue.toString(),
                devotees: devotees,
                walletPay: walletPay,
              ),
            ),
          );
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EventPaymentScreen(
                venueId: widget.venueId.toString(),
                eventId: widget.eventId.toString(),
                leadId: eventLead!.id.toString(),
                packageId: packageId,
                eventName: widget.eventName.toString(),
                eventDate: DateFormat('d MMM yyyy').format(selectedDate),
                eventTime: selectedTime,
                eventVenue: widget.eventVenue.toString(),
                packageName: packageName,
                personCount: personQuantity,
                seatNumbers: [],
                totalAmount: totalAmount,
                amount: double.tryParse(packageAmount) ?? 0,
                devotees: devotees,
                walletPay: walletPay,
              ),
            ),
          );
        }
      }
    } catch (e) {
      print("Error is $e");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      context.read<EventPackageController>().getEventPackage(
          eventId: widget.eventId.toString(),
          eventVenue: widget.eventVenue ?? '');
      context
          .read<EventAuditoriumController>()
          .getAuditoriumData(widget.eventId.toString(), widget.venueId);
    });
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await walletController.fetchWallet();
      setState(() {
        walletPay = walletController.walletPay;
      });
      print("Wallet Amount${walletPay}");
    });

    userId = Provider.of<ProfileController>(Get.context!, listen: false).userID;
    userNAME =
        Provider.of<ProfileController>(Get.context!, listen: false).userNAME;
    userEMAIL =
        Provider.of<ProfileController>(Get.context!, listen: false).userEMAIL;
    userPHONE =
        Provider.of<ProfileController>(Get.context!, listen: false).userPHONE;
    phoneController2 = TextEditingController(text: userPHONE);
    userToken =
        Provider.of<AuthController>(Get.context!, listen: false).getUserToken();
  }

  @override
  void dispose() {
    super.dispose();
    nameController.dispose();
    phoneController.dispose();
    aadharController.dispose();
    phoneController2.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var screenHeight = MediaQuery.of(context).size.height;
    var screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.blue,
        centerTitle: true,
        leading: GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: const Icon(Icons.arrow_back_ios, color: Colors.white),
        ),
        title: Consumer<LanguageProvider>(
          builder: (BuildContext context, languageProvider, Widget? child) {
            return Text(
              languageProvider.language == "english"
                  ? 'Tickets options'
                  : "टिकट के विकल्प",
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: screenWidth * 0.05,
                  color: Colors.white),
            );
          },
        ),
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildEventPackages(),

              // Devotees List
              if (devotees.isNotEmpty) ...[
                ListView.builder(
                  shrinkWrap: true,
                  physics: const BouncingScrollPhysics(),
                  itemCount: devotees.length,
                  itemBuilder: (context, index) {
                    return Container(
                      margin: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            spreadRadius: 1,
                            blurRadius: 3,
                            offset: const Offset(0, 1),
                          ),
                        ],
                        border: Border.all(
                          color: Colors.grey.shade100,
                          width: 1,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Name Row (Compact)
                            Row(
                              children: [
                                Icon(Icons.person,
                                    size: 18,
                                    color: Colors.blue.withOpacity(0.8)),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    "${devotees[index]['name']}",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16,
                                      color: Colors.grey.shade800,
                                    ),
                                  ),
                                ),
                                if (index > 0)
                                  IconButton(
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                    icon: Icon(Icons.delete,
                                        size: 20, color: Colors.red.shade400),
                                    onPressed: () {
                                      setState(() {
                                        devotees.removeAt(index);
                                      });
                                    },
                                  )
                              ],
                            ),

                            // Phone (if exists)
                            if (devotees[index]['phone']?.isNotEmpty ??
                                false) ...[
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  Icon(Icons.phone,
                                      size: 16, color: Colors.green.shade600),
                                  const SizedBox(width: 8),
                                  Text(
                                    "+91 ${devotees[index]['phone']}",
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                            ],

                            // Aadhar
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Icon(Icons.credit_card,
                                    size: 16, color: Colors.blue.shade600),
                                const SizedBox(width: 8),
                                Text(
                                  _formatAadhar("${devotees[index]['aadhar']}"),
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),

                            // Primary Devotee Badge (if index=0)
                            if (index == 0) ...[
                              const SizedBox(height: 6),
                              Text(
                                '( Primary Devotee)',
                                style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.blue,
                                    fontWeight: FontWeight.w500,
                                    fontStyle: FontStyle.italic),
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
              SizedBox(height: 80),
            ],
          ),
        ),
      ),
      floatingActionButton: buildProceedButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  int selectedPackageIndex = -1;

  Widget buildEventPackages() {
    var screenHeight = MediaQuery.of(context).size.height;
    var screenWidth = MediaQuery.of(context).size.width;

    return Consumer<EventPackageController>(
      builder: (context, controller, child) {
        if (controller.isLoading) {
          return bookingShimmer();
        }

        final data = controller.eventPackageModel?.data;
        if (data == null) {
          return const Center(child: Text("No data found"));
        }

        bool isAuditorium = data.auditorium == 1;
        final dateList = data.date;

        List<EventPackageList> packages =
            dateList[selectedDateIndex].packageList;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // if(isAuditorium)...[
            _buildInformationSection(context, screenWidth, screenHeight),
            //  ],

            /// DATE SELECT
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text("Select Date", style: _headerStyle()),
            ),

            SizedBox(
              height: 85,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: dateList.length,
                itemBuilder: (context, index) {
                  bool selected = selectedDateIndex == index;

                  return _buildDateCard(
                    dateList[index],
                    selected,
                    index,
                  );
                },
              ),
            ),
            const SizedBox(height: 10),

            /// PACKAGE SELECT (only when auditorium = 0)
            if (!isAuditorium) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text("Choose Package", style: _headerStyle()),
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 170,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: packages.length,
                  itemBuilder: (context, index) {
                    final pkg = packages[index];

                    bool selected = selectedPackageIndex == index;
                    bool soldOut = int.parse(pkg.available) == 0;
                    return _buildPackageCard(
                      pkg,
                      selected,
                      soldOut,
                      index,
                    );
                  },
                ),
              ),
              const SizedBox(height: 10),
            ],

            /// ACTION AREA
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: buildPackageAction(
                data,
                isAuditorium,
                packages,
              ),
            ),
          ],
        );
      },
    );
  }

  /// --- HELPER WIDGETS FOR CLEANER CODE ---
  TextStyle _headerStyle() => const TextStyle(
      fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 0.5);

  Widget _buildDateCard(dynamic dateData, bool selected, int index) {
    return GestureDetector(
      onTap: () => setState(() {
        selectedDateIndex = index;
        selectedPackageIndex = -1;
        // Reset other states if necessary
      }),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        width: 110, // Slightly narrower for better horizontal flow
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          // Soft tint background on selection, pure white otherwise
          color: selected ? Colors.blue.withOpacity(0.05) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? Colors.blue : Colors.grey.shade300,
            width: selected ? 2.5 : 1.0, // Thicker border when selected
          ),
          boxShadow: [
            BoxShadow(
              color: selected
                  ? Colors.blue.withOpacity(0.1)
                  : Colors.black.withOpacity(0.03),
              blurRadius: 8,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Stack(
          children: [
            // Small Indicator Dot/Icon for selection
            if (selected)
              Positioned(
                top: 6,
                right: 6,
                child: Icon(Icons.check_circle,
                    size: 16, color: Colors.blue),
              ),

            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    DateFormat('EEE').format(dateData.date).toUpperCase(),
                    style: TextStyle(
                      color:
                          selected ? Colors.blue : Colors.grey.shade500,
                      fontSize: 10,
                      letterSpacing: 1.2,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    DateFormat('dd MMM').format(dateData.date),
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 15,
                      fontWeight: selected ? FontWeight.w900 : FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: selected
                          ? Colors.blue.withOpacity(0.1)
                          : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      "${dateData.startTime}",
                      style: TextStyle(
                        color: selected ? Colors.blue : Colors.black54,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPackageCard(
      EventPackageList pkg, bool selected, bool soldOut, int index) {
    return GestureDetector(
      onTap: soldOut
          ? null
          : () {
              setState(() {
                selectedPackageIndex = index;
                //packageQty = 1;
                devotees.clear();
              });
            },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: 240,
        margin: const EdgeInsets.only(left: 8, right: 8, bottom: 12, top: 4),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: selected ? Colors.white : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: selected ? Colors.blue : Colors.transparent,
            width: 2,
          ),
          boxShadow: [
            selected
                ? BoxShadow(
                    color: Colors.blue.withOpacity(0.15),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  )
                : BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
          ],
        ),
        child: Stack(
          children: [
            // Background Accent Icon (Subtle)
            Positioned(
              right: -10,
              bottom: -10,
              child: Icon(
                Icons.confirmation_number_outlined,
                size: 80,
                color: selected
                    ? Colors.blue.withOpacity(0.05)
                    : Colors.grey.withOpacity(0.05),
              ),
            ),

            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Badge for Availability
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 4),
                      decoration: BoxDecoration(
                        color: soldOut
                            ? Colors.red.withOpacity(0.1)
                            : Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        soldOut ? "SOLD OUT" : "${pkg.available} Left",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: soldOut ? Colors.red : Colors.green.shade700,
                        ),
                      ),
                    ),
                    if (selected)
                      const Icon(Icons.check_circle,
                          color: Colors.blue, size: 20),
                  ],
                ),

                const Spacer(),

                // Package Name
                Text(
                  pkg.enPackageName,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: selected ? Colors.black : Colors.black87,
                  ),
                ),

                const SizedBox(height: 12),

                // Price Tag
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      "₹${pkg.price}",
                      style: const TextStyle(
                        fontSize: 24,
                        color: Colors.blue,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.only(left: 4, bottom: 4),
                      child: Text(
                        "/person",
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget buildPackageAction(
    Data data,
    bool isAuditorium,
    List<EventPackageList> packages,
  ) {
    int maxSeats = isAuditorium
        ? 1000
        : (selectedPackageIndex != -1
            ? int.parse(packages[selectedPackageIndex].available)
            : 0);

    int quantity = isAuditorium ? auditoriumQuantity : packageQty;

    if (!isAuditorium && selectedPackageIndex == -1) return const SizedBox();

    bool aadharRequired = data.requiredAadharStatus == 1;

    if (aadharRequired) return _buildAddMemberCard(maxSeats);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Select Quantity",
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
              if (!isAuditorium)
                Text(
                  "$maxSeats slots left",
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                ),
            ],
          ),

          // Custom Styled Counter
          Container(
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Row(
              children: [
                _buildCounterBtn(
                  icon: Icons.remove,
                  onPressed: () {
                    setState(() {
                      if (isAuditorium) {
                        if (auditoriumQuantity > 1) auditoriumQuantity--;
                      } else {
                        if (packageQty > 1) packageQty--;
                      }
                    });
                  },
                ),
                Container(
                  width: 40,
                  alignment: Alignment.center,
                  child: Text(
                    quantity.toString().padLeft(2, '0'),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'monospace', // Gives a digital counter look
                    ),
                  ),
                ),
                _buildCounterBtn(
                  icon: Icons.add,
                  isPrimary: true,
                  onPressed: () {
                    setState(() {
                      if (isAuditorium) {
                        auditoriumQuantity++;
                      } else {
                        if (packageQty < maxSeats) packageQty++;
                      }
                    });
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget bookingShimmer() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// INFORMATION BOX
          Shimmer.fromColors(
            baseColor: Colors.grey.shade300,
            highlightColor: Colors.grey.shade100,
            child: Container(
              height: 120,
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),

          /// DATE TITLE
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: shimmerLine(width: 120),
          ),
          const SizedBox(height: 10),

          /// DATE LIST
          SizedBox(
            height: 85,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 6,
              itemBuilder: (_, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: shimmerBox(width: 70, height: 70),
                );
              },
            ),
          ),
          const SizedBox(height: 20),

          /// PACKAGE TITLE
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: shimmerLine(width: 150),
          ),
          const SizedBox(height: 10),

          /// PACKAGE LIST
          SizedBox(
            height: 170,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 3,
              itemBuilder: (_, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: shimmerBox(width: 220, height: 160),
                );
              },
            ),
          ),
          const SizedBox(height: 20),

          /// INFORMATION BOX
          Shimmer.fromColors(
            baseColor: Colors.grey.shade300,
            highlightColor: Colors.grey.shade100,
            child: Container(
              height: 120,
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),

          /// DATE TITLE
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: shimmerLine(width: 120),
          ),
          const SizedBox(height: 10),

          /// DATE LIST
          SizedBox(
            height: 85,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 6,
              itemBuilder: (_, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: shimmerBox(width: 70, height: 70),
                );
              },
            ),
          ),
          const SizedBox(height: 20),

          /// BUTTON AREA
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: shimmerBox(width: double.infinity, height: 50),
          ),
        ],
      ),
    );
  }

  Widget shimmerBox({double? width, double? height}) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  Widget shimmerLine({double? width}) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Container(
        width: width,
        height: 16,
        color: Colors.white,
      ),
    );
  }

  // Helper for the counter buttons
  Widget _buildCounterBtn(
      {required IconData icon,
      required VoidCallback onPressed,
      bool isPrimary = false}) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isPrimary ? Colors.blue : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isPrimary ? Colors.white : Colors.black),
          boxShadow: [
            if (isPrimary)
              BoxShadow(
                color: Colors.blue.withOpacity(0.3),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
          ],
        ),
        child: Icon(
          icon,
          size: 22,
          color: isPrimary ? Colors.white : Colors.black87,
        ),
      ),
    );
  }

  Widget _buildAddMemberCard(int maxSeats) {
    bool seatsFull = devotees.length >= maxSeats;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: [Colors.white, Colors.blue.shade50.withOpacity(0.3)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: Colors.blue.withOpacity(0.2)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: seatsFull ? null : () => _showAddDevoteeDialog(context),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              // Icon with background
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.person_add_alt_1,
                    color: Colors.blue),
              ),
              const SizedBox(width: 16),

              // Text Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      devotees.isEmpty ? "Add Member Details" : "Members Added",
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      "${devotees.length} of $maxSeats registered",
                      style:
                          TextStyle(color: Colors.grey.shade600, fontSize: 13),
                    ),
                  ],
                ),
              ),

              // Stylish Add Button
              if (!seatsFull)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    "ADD",
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12),
                  ),
                )
              else
                const Icon(Icons.check_circle, color: Colors.green),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInformationSection(
      BuildContext context, double screenWidth, double screenHeight) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Column(
        children: [
          // Header with Toggle Icon
          GestureDetector(
            onTap: () => setState(() => isInfoExpanded = !isInfoExpanded),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: isInfoExpanded
                    ? const BorderRadius.vertical(top: Radius.circular(16))
                    : BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                children: [
                  // Red M-Ticket Dot
                  Container(
                    width: 10,
                    height: 10,
                    decoration: const BoxDecoration(
                        shape: BoxShape.circle, color: Colors.red),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Consumer<LanguageProvider>(
                      builder: (context, lp, _) => Text(
                        lp.language == "english"
                            ? 'Booking Information'
                            : 'बुकिंग की जानकारी',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ),
                  ),
                  // Toggle Icon
                  Icon(
                    isInfoExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: Colors.blue,
                  ),
                ],
              ),
            ),
          ),

          // Expanded Content
          AnimatedCrossFade(
            firstChild:
                const SizedBox(width: double.infinity), // Empty when closed
            secondChild: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius:
                    const BorderRadius.vertical(bottom: Radius.circular(16)),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _infoRow(
                      Icons.sunny,
                      "Save the planet, use your phone as a ticket",
                      Colors.blue),
                  const Divider(height: 24),

                  _detailText("Venue", widget.eventVenue ?? "N/A", isBold: true),
                  const SizedBox(height: 16),

                  // M-Ticket Info Box
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "M-Ticket Info",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, color: Colors.blue),
                        ),
                        const SizedBox(height: 8),
                        _infoText(
                            "1. Total Price is calculated based on quantity."),
                        const SizedBox(height: 4),
                        _infoText("2. Use +/- to manage ticket counts."),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            crossFadeState: isInfoExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 300),
          ),
        ],
      ),
    );
  }

// Helper: Subtle detail row
  Widget _detailText(String label, String value, {bool isBold = false}) {
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(
              text: "$label: ",
              style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
          TextSpan(
              text: value,
              style: TextStyle(
                  fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
                  color: Colors.black87,
                  fontSize: 13)),
        ],
      ),
    );
  }

// Helper: Info text for blue box
  Widget _infoText(String text) {
    return Text(text,
        style:
            const TextStyle(fontSize: 12, height: 1.4, color: Colors.black54));
  }

// Helper: Row with icon
  Widget _infoRow(IconData icon, String text, Color iconColor) {
    return Row(
      children: [
        Icon(icon, size: 16, color: iconColor),
        const SizedBox(width: 8),
        Expanded(
            child: Text(text,
                style: const TextStyle(fontSize: 12, color: Colors.black87))),
      ],
    );
  }

  Widget? buildProceedButton() {
    return Consumer<EventPackageController>(
      builder: (context, controller, child) {
        final data = controller.eventPackageModel?.data;
        if (data == null) return const SizedBox();

        bool isAuditorium = data.auditorium == 1;
        final dateList = data.date;

        if (selectedDateIndex == -1) return const SizedBox();
        final packages = dateList[selectedDateIndex].packageList;

        DateTime dateSelected = dateList[selectedDateIndex].date;
        String timeSelected = dateList[selectedDateIndex].startTime;

        bool aadharRequired =
            data.requiredAadharStatus == 1; // Set your actual logic here

        int displayQty = aadharRequired ? devotees.length : packageQty;

        // If it's an auditorium, we use the auditorium counter
        if (isAuditorium)
          displayQty = aadharRequired ? devotees.length : auditoriumQuantity;

        // 3. Selection Validation
        bool hasSelectedPackage = isAuditorium || (selectedPackageIndex != -1);

        // Hide button if no one is added or no package selected
        if (displayQty <= 0 || !hasSelectedPackage) {
          return const SizedBox();
        }

        // 4. Calculation Logic
        double totalAmount = 0.0;
        String packageId = "";
        String packageName = "";
        String packageAmount = "";

        if (!isAuditorium) {
          double unitPrice =
              double.tryParse(packages[selectedPackageIndex].price) ?? 0.0;
          // Calculation depends on Aadhar requirement
          totalAmount =
              unitPrice * (aadharRequired ? devotees.length : packageQty);
          packageId = packages[selectedPackageIndex].packageId;
          packageName = packages[selectedPackageIndex].enPackageName;
          packageAmount = packages[selectedPackageIndex].price;
        }

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: FloatingActionButton.extended(
            elevation: 4,
            onPressed: isLoading
                ? null
                : () {
                    if (aadharRequired &&
                        devotees.length != packageQty &&
                        !isAuditorium) {
                      return;
                    }
                    getLeadDetails(
                      isAuditorium,
                      displayQty,
                      totalAmount,
                      packageId,
                      dateSelected,
                      timeSelected,
                      packageName,
                      packageAmount,
                    );
                  },
            label: Container(
              width: MediaQuery.of(context).size.width * 0.88,
              height: 64,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Colors.blue, Color(0xFFFF8C42)],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  )
                ],
              ),
              child: Row(
                children: [
                  const SizedBox(width: 20),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isAuditorium
                            ? "Select Your Seats"
                            : "₹ ${totalAmount.toStringAsFixed(0)}",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      Text(
                        "$displayQty Member${displayQty > 1 ? 's' : ''} Added",
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  isLoading
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 3,
                          ),
                        )
                      : const Text(
                          "PROCEED",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5,
                          ),
                        ),
                  const SizedBox(width: 8),
                  const Icon(Icons.arrow_forward_rounded,
                      color: Colors.white, size: 20),
                  const SizedBox(width: 16),
                ],
              ),
            ),
            backgroundColor: Colors.transparent,
          ),
        );
      },
    );
  }
}
