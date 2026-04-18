import 'dart:convert';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mahakal/features/explore/payment_process_screen.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:provider/provider.dart';

import '../../data/datasource/remote/http/httpClient.dart';
import '../../main.dart';
import '../../utill/app_constants.dart';
import '../../utill/completed_order_dialog.dart';
import '../../utill/razorpay_screen.dart';
import '../auth/controllers/auth_controller.dart';
import '../custom_bottom_bar/bottomBar.dart';

import '../profile/controllers/profile_contrroller.dart';

class paymentDetailView extends StatefulWidget {
  final String leadId;
  final String date;
  final String time;
  final String billAmount;
  final String name;
  final String aadharStatus;
  const paymentDetailView(
      {super.key,
      required this.billAmount,
      required this.name,
      required this.leadId,
      required this.date,
      required this.time,
      required this.aadharStatus});

  @override
  _paymentDetailViewState createState() => _paymentDetailViewState();
}

class _paymentDetailViewState extends State<paymentDetailView> {
  List<Map<String, String>> devotees = [];
  TextEditingController nameController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController phoneController2 = TextEditingController();
  TextEditingController aadharController = TextEditingController();
  TextEditingController aadharController2 = TextEditingController();

  double walletPay = 0.0;
  double walletMinusAmount = 0.0;
  double finalAmount = 0.0;
  double billAmount = 0.0;
  String userId = '';
  String userNAME = '';
  String userEMAIL = '';
  String userPHONE = '';
  String userToken = '';
  String pay_requestKey = '';
  bool isLoading = false;
  bool isverify = false;

  final razorpayService = RazorpayPaymentService();

  void walletAmount() async {
    var res = await HttpService().getApi(AppConstants.poojaWalletUrl + userId);
    print(res);
    if (res['success']) {
      setState(() {
        walletPay = double.parse(res['wallet_balance'].toString());
        walletMinusAmount = max(walletPay - int.parse(widget.billAmount), 0);
        finalAmount = (walletPay - int.parse(widget.billAmount)).abs();
        billAmount = double.parse(widget.billAmount);
      });
    }
  }

  void updateLead(
      String id, String date, String time, String price, String qty) async {
    DateTime bookDate = DateTime.parse(date);
    String formatedDate = DateFormat('dd-MM-yyyy').format(bookDate);
    String userInfoJsonString = jsonEncode(devotees);
    print(
        'data \n $id \n $formatedDate \n $time \n $price \n $qty \n $userInfoJsonString');
    var res =
        await HttpService().postApi(AppConstants.packageTempleLeadUpdate, {
      'lead_id': id,
      'date': formatedDate, //27-04-2025
      'time': time, //08:09 PM - 10:09 PM
      'price': price,
      'qty': qty,
      'user_information': userInfoJsonString,
    });
    print('Api response data $res');
    if (res['status'] == 1) {
      setState(() {
        pay_requestKey = res['data'];
      });
    }
  }

  void placeOrder(String requestId, String method, String transactionId,
      String walletType) async {
    print(
        'Api data response print $requestId $method $transactionId $walletType ${walletMinusAmount == 0 ? finalAmount : 0}');
    var res = await HttpService().postApi(AppConstants.placeOrderTemple, {
      'payment_request_id': requestId,
      'payment_method': method,
      'transaction_id': transactionId,
      'wallet_type': walletType,
      'online_pay': '${walletMinusAmount == 0 ? finalAmount : 0}',
    });
    print('Api response data place order $res');
    if (res['status'] == 1) {
      // Navigator.pop(context);
      Navigator.of(context).pushReplacement(CupertinoPageRoute(
          builder: (BuildContext context) => const BottomBar(pageIndex: 0)));
      showDialog(
        context: context,
        builder: (context) => bookingSuccessDialog(
          context: context,
          tabIndex: 10,
          title: 'Darshan Booked!',
          message:
              'Your mandir darshan has been successfully booked. Please arrive at the temple on your selected date and time.',
        ),
        barrierDismissible: true,
      );
    }
  }

  void getAadhar(String aadharNumber, BuildContext context,
      StateSetter modalSetter) async {
    var res = await HttpService().postApi(AppConstants.sendAadharOtp, {
      'aadhaar_number': aadharNumber,
    });
    print('Api response data place order $res');
    if (res['status'] == 1) {
      Navigator.pop(context);
      String id = res['data']['request_id'].toString();
      Fluttertoast.showToast(
          msg: 'Send OTP',
          backgroundColor: Colors.green,
          textColor: Colors.white);
      showOtpVerificationDialog(context, id);
    }
    if (res['status'] == 2) {
      // Navigator.pop(context);
      String name = res['data']['name'];
      String aadhar = res['data']['aadhar'].toString();
      setState(() {
        devotees.add({
          'name': name,
          'phone': phoneController2.text.trim(),
          'aadhar': aadhar,
          'verify': '1',
        });
      });
      Navigator.pop(context);
      Fluttertoast.showToast(
          msg: 'Success',
          backgroundColor: Colors.green,
          textColor: Colors.white);
      phoneController2.clear();
      aadharController2.clear();
      billAmount = double.parse(widget.billAmount) * devotees.length;
      walletMinusAmount = max(walletPay - billAmount, 0);
      finalAmount = (walletPay - billAmount).abs();
    }
    if (res['status'] == 0) {
      Fluttertoast.showToast(
          msg: 'Invalid Aadhaar Number',
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
        AppConstants.sendAadharOtpVerify, {'otp': otp, 'request_id': id});
    print('Api response data verify otp $res');
    if (res['status'] == 1) {
      String name = res['data']['data']['full_name'];
      String aadhar = res['data']['data']['aadhaar_number'];
      Navigator.pop(context);
      setState(() {
        devotees.add({
          'name': name,
          'phone': phoneController2.text.trim(),
          'aadhar': aadhar,
          'verify': '1',
        });
      });
      Fluttertoast.showToast(
          msg: 'Success',
          backgroundColor: Colors.green,
          textColor: Colors.white);
      phoneController2.clear();
      aadharController2.clear();
      billAmount = double.parse(widget.billAmount) * devotees.length;
      walletMinusAmount = max(walletPay - billAmount, 0);
      finalAmount = (walletPay - billAmount).abs();
      modalSetter(() {
        isverify = false;
      });
    } else {
      modalSetter(() {
        isverify = false;
      });
      Fluttertoast.showToast(
          msg: 'Invalid request',
          backgroundColor: Colors.red,
          textColor: Colors.white);
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    userId = Provider.of<ProfileController>(Get.context!, listen: false).userID;
    userNAME =
        Provider.of<ProfileController>(Get.context!, listen: false).userNAME;
    userEMAIL =
        Provider.of<ProfileController>(Get.context!, listen: false).userEMAIL;
    userPHONE =
        Provider.of<ProfileController>(Get.context!, listen: false).userPHONE;
    userToken =
        Provider.of<AuthController>(Get.context!, listen: false).getUserToken();
    phoneController.text = userPHONE.replaceFirst('+91', '');
    phoneController2.text = userPHONE.replaceFirst('+91', '');
    walletAmount();
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? const MahakalPaymentProcessing()
        : Scaffold(
            floatingActionButtonLocation:
                FloatingActionButtonLocation.centerDocked,
            floatingActionButton: devotees.isEmpty
                ? GestureDetector(
                    onTap: () {
                      Fluttertoast.showToast(
                          msg: 'Add Members',
                          textColor: Colors.white,
                          backgroundColor: Colors.red);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 2, horizontal: 10),
                      margin: const EdgeInsets.all(10),
                      height: 70, // Slightly taller for better presence
                      decoration: BoxDecoration(
                        borderRadius:
                            BorderRadius.circular(12), // More rounded corners
                        gradient: LinearGradient(
                          colors: [
                            Colors.grey, // Saffron color
                            Colors.grey.shade400, // Golden color
                          ],
                          begin: Alignment.bottomLeft,
                          end: Alignment.topRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.4),
                            blurRadius: 8,
                            spreadRadius: 2,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          // Temple icon added
                          const Icon(
                            Icons.temple_hindu_rounded,
                            size: 36,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 12),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '₹$billAmount',
                                style: const TextStyle(
                                  fontSize: 22, // Slightly larger
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Roboto',
                                  color: Colors.white,
                                  shadows: [
                                    Shadow(
                                      blurRadius: 2,
                                      color: Colors.black26,
                                      offset: Offset(1, 1),
                                    )
                                  ],
                                ),
                              ),
                              Text(
                                devotees.isEmpty
                                    ? 'Book Now'
                                    : 'Total Members ${devotees.length}',
                                style: TextStyle(
                                  fontSize:
                                      16, // Slightly smaller for hierarchy
                                  fontFamily: 'Roboto',
                                  color: Colors.white,
                                  fontWeight: devotees.isEmpty
                                      ? FontWeight.normal
                                      : FontWeight.bold,
                                  shadows: const [
                                    Shadow(
                                      blurRadius: 2,
                                      color: Colors.black26,
                                      offset: Offset(1, 1),
                                    )
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                vertical: 8, horizontal: 16),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Row(
                              children: [
                                Text(
                                  'Pay', // Changed from "Pay" to "Donate" for temple context
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Roboto',
                                    color: Colors.white,
                                  ),
                                ),
                                SizedBox(width: 8),
                                Icon(
                                  Icons.arrow_circle_right_outlined,
                                  size: 28,
                                  color: Colors.white,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : billAmount == 0
                    ? GestureDetector(
                        onTap: () {
                          isLoading
                              ? null
                              : showCupertinoDialog(
                                  context: context,
                                  builder: (_) => CupertinoAlertDialog(
                                    title: const Text('Confirm Payment'),
                                    content: const Text(
                                        'Are you sure you want to proceed with the payment?'),
                                    actions: [
                                      CupertinoDialogAction(
                                        child: const Text(
                                          'Cancel',
                                          style: TextStyle(
                                              color: Color(0xFFFF5A5A)),
                                        ),
                                        onPressed: () =>
                                            Navigator.of(context).pop(),
                                      ),
                                      CupertinoDialogAction(
                                        isDefaultAction: true,
                                        child: const Text(
                                          'Pay Now',
                                          style: TextStyle(
                                              color:
                                                  Colors.green), // Deep Orange
                                        ),
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                          setState(() {
                                            isLoading = true;
                                          });
                                          placeOrder(pay_requestKey,
                                              'wallet_pay', 'wallet_pay', '1');
                                        },
                                      ),
                                    ],
                                  ),
                                );
                          updateLead(
                            widget.leadId,
                            widget.date,
                            widget.time,
                            '$billAmount',
                            '${devotees.length}',
                          );
                        },
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                              vertical: 2, horizontal: 10),
                          margin: const EdgeInsets.all(10),
                          height: 70, // Slightly taller for better presence
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(
                                12), // More rounded corners
                            gradient: const LinearGradient(
                              colors: [
                                Colors.deepOrange, // Saffron color
                                Colors.amber, // Golden color
                              ],
                              begin: Alignment.bottomLeft,
                              end: Alignment.topRight,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.deepOrange.withOpacity(0.4),
                                blurRadius: 8,
                                spreadRadius: 2,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: isLoading
                              ? const Center(
                                  child: CircularProgressIndicator(
                                  color: Colors.white,
                                ))
                              : Row(
                                  children: [
                                    // Temple icon added
                                    const Icon(
                                      Icons.temple_hindu_rounded,
                                      size: 36,
                                      color: Colors.white,
                                    ),
                                    const SizedBox(width: 12),
                                    Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '₹$billAmount',
                                          style: const TextStyle(
                                            fontSize: 22, // Slightly larger
                                            fontWeight: FontWeight.bold,
                                            fontFamily: 'Roboto',
                                            color: Colors.white,
                                            shadows: [
                                              Shadow(
                                                blurRadius: 2,
                                                color: Colors.black26,
                                                offset: Offset(1, 1),
                                              )
                                            ],
                                          ),
                                        ),
                                        const Text(
                                          'Via Wallet',
                                          style: TextStyle(
                                            fontSize:
                                                16, // Slightly smaller for hierarchy
                                            fontFamily: 'Roboto',
                                            color: Colors.white,
                                            shadows: [
                                              Shadow(
                                                blurRadius: 2,
                                                color: Colors.black26,
                                                offset: Offset(1, 1),
                                              )
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    const Spacer(),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 8, horizontal: 16),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: const Row(
                                        children: [
                                          Text(
                                            'Pay', // Changed from "Pay" to "Donate" for temple context
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              fontFamily: 'Roboto',
                                              color: Colors.white,
                                            ),
                                          ),
                                          SizedBox(width: 8),
                                          Icon(
                                            Icons.arrow_circle_right_outlined,
                                            size: 28,
                                            color: Colors.white,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      )
                    : walletMinusAmount == 0
                        ? GestureDetector(
                            onTap: () {
                              setState(() {
                                isLoading = true;
                              });
                              updateLead(
                                widget.leadId,
                                widget.date,
                                widget.time,
                                '$billAmount',
                                '${devotees.length}',
                              );
                              razorpayService.openCheckout(
                                amount: finalAmount, // ₹100
                                razorpayKey: AppConstants.razorpayLive,
                                onSuccess: (response) {
                                  setState(() {
                                    isLoading = true;
                                  });
                                  placeOrder(pay_requestKey, 'razor_pay',
                                      '${response.paymentId}', '0');
                                },
                                onFailure: (response) {
                                  setState(() {
                                    isLoading = false;
                                  });
                                },
                                onExternalWallet: (response) {
                                  print('Wallet: ${response.walletName}');
                                },
                                description: 'Mandir Darshan',
                              );
                              // _showBottomSheets();
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 2, horizontal: 10),
                              margin: const EdgeInsets.all(10),
                              height: 70, // Slightly taller for better presence
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(
                                    12), // More rounded corners
                                gradient: const LinearGradient(
                                  colors: [
                                    Colors.deepOrange, // Saffron color
                                    Colors.amber, // Golden color
                                  ],
                                  begin: Alignment.bottomLeft,
                                  end: Alignment.topRight,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.deepOrange.withOpacity(0.4),
                                    blurRadius: 8,
                                    spreadRadius: 2,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  // Temple icon added
                                  const Icon(
                                    Icons.temple_hindu_rounded,
                                    size: 36,
                                    color: Colors.white,
                                  ),
                                  const SizedBox(width: 12),
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '₹$finalAmount',
                                        style: const TextStyle(
                                          fontSize: 22, // Slightly larger
                                          fontWeight: FontWeight.bold,
                                          fontFamily: 'Roboto',
                                          color: Colors.white,
                                          shadows: [
                                            Shadow(
                                              blurRadius: 2,
                                              color: Colors.black26,
                                              offset: Offset(1, 1),
                                            )
                                          ],
                                        ),
                                      ),
                                      Text(
                                        devotees.isEmpty
                                            ? 'Book Now'
                                            : 'Total Members ${devotees.length}',
                                        style: TextStyle(
                                          fontSize:
                                              16, // Slightly smaller for hierarchy
                                          fontFamily: 'Roboto',
                                          color: Colors.white,
                                          fontWeight: devotees.isEmpty
                                              ? FontWeight.normal
                                              : FontWeight.bold,
                                          shadows: const [
                                            Shadow(
                                              blurRadius: 2,
                                              color: Colors.black26,
                                              offset: Offset(1, 1),
                                            )
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const Spacer(),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 8, horizontal: 16),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: const Row(
                                      children: [
                                        Text(
                                          'Pay', // Changed from "Pay" to "Donate" for temple context
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            fontFamily: 'Roboto',
                                            color: Colors.white,
                                          ),
                                        ),
                                        SizedBox(width: 8),
                                        Icon(
                                          Icons.arrow_circle_right_outlined,
                                          size: 28,
                                          color: Colors.white,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : GestureDetector(
                            onTap: () {
                              isLoading
                                  ? null
                                  : showCupertinoDialog(
                                      context: context,
                                      builder: (_) => CupertinoAlertDialog(
                                        title: const Text('Confirm Payment'),
                                        content: const Text(
                                            'Are you sure you want to proceed with the payment?'),
                                        actions: [
                                          CupertinoDialogAction(
                                            child: const Text(
                                              'Cancel',
                                              style: TextStyle(
                                                  color: Color(0xFFFF5A5A)),
                                            ),
                                            onPressed: () =>
                                                Navigator.of(context).pop(),
                                          ),
                                          CupertinoDialogAction(
                                            isDefaultAction: true,
                                            child: const Text(
                                              'Pay Now',
                                              style: TextStyle(
                                                  color: Colors
                                                      .green), // Deep Orange
                                            ),
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                              setState(() {
                                                isLoading = true;
                                              });
                                              placeOrder(
                                                  pay_requestKey,
                                                  'wallet_pay',
                                                  'wallet_pay',
                                                  '1');
                                            },
                                          ),
                                        ],
                                      ),
                                    );
                              updateLead(
                                widget.leadId,
                                widget.date,
                                widget.time,
                                '$billAmount',
                                '${devotees.length}',
                              );
                            },
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                  vertical: 2, horizontal: 10),
                              margin: const EdgeInsets.all(10),
                              height: 70, // Slightly taller for better presence
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(
                                    12), // More rounded corners
                                gradient: const LinearGradient(
                                  colors: [
                                    Colors.deepOrange, // Saffron color
                                    Colors.amber, // Golden color
                                  ],
                                  begin: Alignment.bottomLeft,
                                  end: Alignment.topRight,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.deepOrange.withOpacity(0.4),
                                    blurRadius: 8,
                                    spreadRadius: 2,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: isLoading
                                  ? const Center(
                                      child: CircularProgressIndicator(
                                      color: Colors.white,
                                    ))
                                  : Row(
                                      children: [
                                        // Temple icon added
                                        const Icon(
                                          Icons.temple_hindu_rounded,
                                          size: 36,
                                          color: Colors.white,
                                        ),
                                        const SizedBox(width: 12),
                                        Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              '₹$billAmount',
                                              style: const TextStyle(
                                                fontSize: 22, // Slightly larger
                                                fontWeight: FontWeight.bold,
                                                fontFamily: 'Roboto',
                                                color: Colors.white,
                                                shadows: [
                                                  Shadow(
                                                    blurRadius: 2,
                                                    color: Colors.black26,
                                                    offset: Offset(1, 1),
                                                  )
                                                ],
                                              ),
                                            ),
                                            const Text(
                                              'Via Wallet',
                                              style: TextStyle(
                                                fontSize:
                                                    16, // Slightly smaller for hierarchy
                                                fontFamily: 'Roboto',
                                                color: Colors.white,
                                                shadows: [
                                                  Shadow(
                                                    blurRadius: 2,
                                                    color: Colors.black26,
                                                    offset: Offset(1, 1),
                                                  )
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                        const Spacer(),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 8, horizontal: 16),
                                          decoration: BoxDecoration(
                                            color:
                                                Colors.white.withOpacity(0.2),
                                            borderRadius:
                                                BorderRadius.circular(20),
                                          ),
                                          child: const Row(
                                            children: [
                                              Text(
                                                'Pay', // Changed from "Pay" to "Donate" for temple context
                                                style: TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                  fontFamily: 'Roboto',
                                                  color: Colors.white,
                                                ),
                                              ),
                                              SizedBox(width: 8),
                                              Icon(
                                                Icons
                                                    .arrow_circle_right_outlined,
                                                size: 28,
                                                color: Colors.white,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                            ),
                          ),
            appBar: AppBar(
              title: const Text('Add Devotees'),
            ),
            body: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border:
                          Border.all(color: Colors.grey.shade300, width: 1.5),
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          spreadRadius: 2,
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Bill Details Header
                        Row(
                          children: [
                            Icon(Icons.receipt_long_rounded,
                                color: Colors.orange.shade600, size: 24),
                            const SizedBox(width: 8),
                            Text(
                              'Bill Details',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                fontFamily: 'Roboto',
                                color: Colors.orange.shade700,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // Pooja Total
                        _buildBillRow(
                          title: 'Amount',
                          value: '₹$billAmount',
                          titleStyle: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.black87,
                          ),
                          valueStyle: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.green.shade700,
                          ),
                        ),

                        const Divider(
                            height: 24, thickness: 1, color: Colors.grey),

                        // Wallet Section
                        _buildBillRow(
                          title: 'Wallet Balance',
                          value: '₹$walletPay',
                          titleStyle: const TextStyle(
                            fontSize: 16,
                            color: Colors.black87,
                          ),
                          valueStyle: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade700,
                          ),
                        ),

                        const SizedBox(height: 8),

                        _buildBillRow(
                          title: 'Wallet Remaining',
                          value: '₹$walletMinusAmount',
                          titleStyle: const TextStyle(
                            fontSize: 16,
                            color: Colors.black87,
                          ),
                          valueStyle: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.green.shade700,
                          ),
                        ),

                        const SizedBox(height: 8),

                        _buildBillRow(
                          title: 'Amount Paid (via Wallet)',
                          value: walletMinusAmount == 0
                              ? '- ₹$walletPay'
                              : '- ₹$billAmount',
                          titleStyle: const TextStyle(
                            fontSize: 16,
                            color: Colors.black87,
                          ),
                          valueStyle: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.red.shade700,
                          ),
                        ),

                        const Divider(
                            height: 24, thickness: 1, color: Colors.grey),

                        // Total Amount
                        _buildBillRow(
                          title: 'Total Amount',
                          value:
                              walletMinusAmount == 0 ? '₹$finalAmount' : '₹0.0',
                          titleStyle: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                          valueStyle: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.orange.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(
                    height: 10,
                  ),
                  // Add Devotee Button
                  Container(
                    height: 60, // Slightly taller for better touch targets
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    decoration: BoxDecoration(
                      borderRadius:
                          BorderRadius.circular(14), // Smoother corners
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.orange.shade200.withOpacity(0.9),
                          Colors.amber.shade50.withOpacity(0.9),
                        ],
                      ),
                      border: Border.all(
                        color: Colors.deepOrange.shade700.withOpacity(0.7),
                        width: 1.2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.deepOrange.withOpacity(0.15),
                          blurRadius: 10,
                          spreadRadius: 1,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.deepOrange,
                          ),
                          child: const Icon(
                            Icons.group_add_rounded, // More relevant icon
                            color: Colors.white,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          devotees.isEmpty
                              ? 'Add Members' // More engaging text
                              : 'Add Members (${devotees.length})',
                          style: GoogleFonts.poppins(
                            // Using a custom font (add google_fonts package)
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                            color: Colors.deepOrange,
                            letterSpacing: 0.2,
                          ),
                        ),
                        const Spacer(),
                        MouseRegion(
                          // Adds hover effect (if on web/desktop)
                          cursor: SystemMouseCursors.click,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            child: ElevatedButton(
                              onPressed: () => _showAddDevoteeDialog(context),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.deepOrange,
                                foregroundColor: Colors.deepOrange.shade300,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18),
                                  side: BorderSide(
                                    color: Colors.deepOrange.shade600,
                                    width: 1.5,
                                  ),
                                ),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 8),
                                elevation: 0,
                                shadowColor: Colors.transparent,
                              ),
                              onHover: (isHovered) {
                                // Optional: Add hover animation logic
                              },
                              child: Row(
                                children: [
                                  Text(
                                    'ADD', // More action-oriented
                                    style: GoogleFonts.poppins(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 0.5,
                                        color: Colors.white),
                                  ),
                                  const SizedBox(width: 6),
                                  const Icon(
                                    Icons.add_circle_rounded,
                                    size: 18,
                                    color: Colors.white,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Devotees List
                  if (devotees.isNotEmpty) ...[
                    Expanded(
                      child: ListView.builder(
                        shrinkWrap: true,
                        physics: const BouncingScrollPhysics(),
                        itemCount: devotees.length,
                        itemBuilder: (context, index) {
                          return Container(
                            margin: const EdgeInsets.only(bottom: 10),
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
                                          color: Colors.deepOrange
                                              .withOpacity(0.8)),
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
                                              size: 20,
                                              color: Colors.red.shade400),
                                          onPressed: () {
                                            setState(() {
                                              devotees.removeAt(index);
                                              billAmount = double.parse(
                                                      widget.billAmount) *
                                                  devotees.length;
                                              walletMinusAmount = max(
                                                  walletPay - billAmount, 0);
                                              finalAmount =
                                                  (walletPay - billAmount)
                                                      .abs();
                                            });
                                          },
                                        )
                                      else
                                        IconButton(
                                          padding: EdgeInsets.zero,
                                          constraints: const BoxConstraints(),
                                          icon: Icon(Icons.edit,
                                              size: 20,
                                              color: Colors.green.shade500),
                                          onPressed: () {
                                            // Handle edit
                                          },
                                        ),
                                    ],
                                  ),

                                  // Phone (if exists)
                                  if (devotees[index]['phone']?.isNotEmpty ??
                                      false) ...[
                                    const SizedBox(height: 6),
                                    Row(
                                      children: [
                                        Icon(Icons.phone,
                                            size: 16,
                                            color: Colors.green.shade600),
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
                                          size: 16,
                                          color: Colors.blue.shade600),
                                      const SizedBox(width: 8),
                                      Text(devotees[index]['aadhar'] == '' ? '0000-0000-0000' :
                                        _formatAadhar(
                                            "${devotees[index]['aadhar']}"),
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
                                    const Text(
                                      '( Primary Devotee)',
                                      style: TextStyle(
                                          fontSize: 11,
                                          color: Colors.deepOrange,
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
                    ),
                  ],
                  const SizedBox(height: 100),
                ],
              ),
            ),
          );
  }

  String _formatAadhar(String aadhar) {
    if (aadhar == 'N/A') return aadhar;

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

  void _showAddDevoteeDialog(BuildContext context) {
    int verificationStatus = 1;

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
                    borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16)),
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
                            const Text(
                              'Add New Devotee',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.deepOrange,
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

                        // Replace the Column children in the above example with this:
                        widget.aadharStatus == '1'
                            ? const SizedBox.shrink()
                            : Row(
                                children: [
                                  Expanded(
                                    child: Container(
                                      margin: const EdgeInsets.only(right: 8),
                                      decoration: BoxDecoration(
                                        color: verificationStatus == 1
                                            ? Colors.deepOrange.withOpacity(0.1)
                                            : Colors.grey.withOpacity(0.05),
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: verificationStatus == 1
                                              ? Colors.deepOrange
                                              : Colors.grey.withOpacity(0.3),
                                          width: 1,
                                        ),
                                      ),
                                      child: RadioListTile<int>(
                                        dense: true,
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                                horizontal: 8),
                                        activeColor: Colors.deepOrange,
                                        title: Text(
                                          'Verified Aadhaar',
                                          style: TextStyle(
                                            fontWeight: verificationStatus == 1
                                                ? FontWeight.bold
                                                : FontWeight.normal,
                                          ),
                                        ),
                                        value: 1,
                                        groupValue: verificationStatus,
                                        onChanged: (int? value) {
                                          modalSetter(() {
                                            verificationStatus = value!;
                                          });
                                        },
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Container(
                                      margin: const EdgeInsets.only(left: 8),
                                      decoration: BoxDecoration(
                                        color: verificationStatus == 0
                                            ? Colors.deepOrange.withOpacity(0.1)
                                            : Colors.grey.withOpacity(0.05),
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: verificationStatus == 0
                                              ? Colors.deepOrange
                                              : Colors.grey.withOpacity(0.3),
                                          width: 1,
                                        ),
                                      ),
                                      child: RadioListTile<int>(
                                        dense: true,
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                                horizontal: 8),
                                        activeColor: Colors.deepOrange,
                                        title: Text(
                                          'Non-Verified Aadhaar',
                                          style: TextStyle(
                                            fontWeight: verificationStatus == 0
                                                ? FontWeight.bold
                                                : FontWeight.normal,
                                          ),
                                        ),
                                        value: 0,
                                        groupValue: verificationStatus,
                                        onChanged: (int? value) {
                                          modalSetter(() {
                                            verificationStatus = value!;
                                          });
                                        },
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                        const SizedBox(height: 20),

                        if (verificationStatus == 1) ...[
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
                                color: Colors.deepOrange,
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
                                color: Colors.deepOrange,
                              ),
                              counterText: '',
                            ),
                            maxLength: 12,
                          ),
                          const SizedBox(height: 24),
                          // verify btn
                          if (phoneController2.text.isNotEmpty ||
                              aadharController2.text.isNotEmpty)
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () {
                                  String aadhar = aadharController2.text.trim();
                                  // Check if aadhar already exists
                                  bool exists = devotees.any(
                                      (devotee) => devotee['aadhar'] == aadhar);

                                  if (exists) {
                                    // Aadhaar already exists in the list
                                    Fluttertoast.showToast(
                                        msg:
                                            'This Aadhar number is already added',
                                        backgroundColor: Colors.red,
                                        textColor: Colors.white);
                                  } else {
                                    modalSetter(() {
                                      isverify = true;
                                    });
                                    getAadhar(aadharController2.text.trim(),
                                        context, modalSetter);
                                    // showOtpVerificationDialog(context,aadharController2.text.trim());
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.deepOrange,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  elevation: 0,
                                ),
                                child: isverify
                                    ? const CircularProgressIndicator(
                                        color: Colors.white,
                                      )
                                    : const Text(
                                        'Verify',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                              ),
                            )
                          else
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () {},
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.grey,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  elevation: 0,
                                ),
                                child: isverify
                                    ? const CircularProgressIndicator(
                                        color: Colors.white,
                                      )
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

                        if (verificationStatus == 0) ...[
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
                                color: Colors.deepOrange,
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
                                  color: Colors.deepOrange,
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
                                color: Colors.deepOrange,
                              ),
                              counterText: '',
                            ),
                            maxLength: 12,
                          ),
                          const SizedBox(height: 24),

                          // Add Button
                          if (nameController.text.isNotEmpty ||
                              aadharController.text.isNotEmpty)
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () {
                                  if (devotees.isNotEmpty) {
                                    // Only require name and Aadhar when list is empty
                                    if (nameController.text.isNotEmpty) {
                                      Navigator.pop(context);
                                      setState(() {
                                        devotees.add({
                                          'name': nameController.text.trim(),
                                          'phone': '',
                                          'aadhar':
                                              aadharController.text.trim(),
                                          'verify': '0',
                                        });
                                      });
                                      print('devotee list item $devotees');
                                    }
                                  } else {
                                    // Require all fields when list is not empty
                                    if (nameController.text.isNotEmpty &&
                                        phoneController.text.isNotEmpty) {
                                      Navigator.pop(context);
                                      setState(() {
                                        devotees.add({
                                          'name': nameController.text.trim(),
                                          'phone': phoneController.text.trim(),
                                          'aadhar':
                                              aadharController.text.trim(),
                                          'verify': '0',
                                        });
                                      });
                                      print('devotee list item $devotees');
                                    }
                                  }
                                  nameController.clear();
                                  phoneController.clear();
                                  aadharController.clear();
                                  billAmount = double.parse(widget.billAmount) *
                                      devotees.length;
                                  walletMinusAmount =
                                      max(walletPay - billAmount, 0);
                                  finalAmount = (walletPay - billAmount).abs();
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.deepOrange,
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
                            )
                          else
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () {},
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.grey,
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
                          ? const CircularProgressIndicator(
                              color: Colors.white,
                            )
                          : const Text(
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

  // Helper Widget for consistent bill rows
  Widget _buildBillRow({
    required String title,
    required String value,
    required TextStyle titleStyle,
    required TextStyle valueStyle,
    int maxLines = 1,
  }) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: titleStyle,
            maxLines: maxLines,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 10),
        Text(
          value,
          style: valueStyle,
        ),
      ],
    );
  }
}
