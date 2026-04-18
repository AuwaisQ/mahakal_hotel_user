import 'dart:convert';
import 'dart:math';
import 'package:flutter_html/flutter_html.dart';
import 'package:http/http.dart' as https;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:provider/provider.dart';
import '../../../data/datasource/remote/http/httpClient.dart';
import '../../../main.dart';
import '../../../utill/app_constants.dart';
import '../../../utill/flutter_toast_helper.dart';
import '../../../utill/razorpay_screen.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../explore/payment_process_screen.dart';

import '../../pooja_booking/model/coupon_model.dart';
import '../../profile/controllers/profile_contrroller.dart';
import 'offline_details.dart';
import 'offlinepersondetails.dart';

class OfflineAmountScreen extends StatefulWidget {
  final String totalAmount;
  final String bookingAmount;
  final String packageName;
  final String imageUrl;
  final String detail;
  final String leadId;
  final String serviceId;
  final String packageId;
  final String translateEn;
  final String id;
  final List<City> citiesModelList;

  const OfflineAmountScreen(
      {super.key,
      required this.totalAmount,
      required this.bookingAmount,
      required this.packageName,
      required this.imageUrl,
      required this.detail,
      required this.leadId,
      required this.serviceId,
      required this.packageId,
      required this.translateEn,
      required this.id,
      required this.citiesModelList});

  @override
  State<OfflineAmountScreen> createState() => _OfflineAmountScreenState();
}

class _OfflineAmountScreenState extends State<OfflineAmountScreen> {
  final List<int> quantity = List.generate(10, (index) => 0);
  List<Map<String, dynamic>> items = [];

  late dynamic finalPrice;
  int totalQuantity = 1;

  // selected city name
  String? selectedCityName;

  String userId = "";
  String userNAME = "";
  String userEMAIL = "";
  String userPHONE = "";
  String userToken = "";

  bool isCouponApplyed = false;
  bool isLoading = false;
  bool circularIndicator = false;
  bool isHalfPay = true;
  int listSumAmount = 0;
  //int totalAmount = 0;
  int couponDiscountAmount = 0;
  double couponTotalAmount = 0.0;
  double couponTotalRupe = 0.0;
  double couponTotalPer = 0.0;
  double couponBillRupe = 0.0;
  double couponBillPerc = 0.0;
  double minusCouponAmount = 0.0;
  double walletPay = 0.0;
  double walletMinusAmount = 0.0;
  double finalAmount = 0.0;
  double couponMinus = 0.0;
  String couponCode = "";
  String couponType = "";
  String serviceCouponType = "";

  List<int> productAmounts = [];
  List<Couponlist> couponModelList = <Couponlist>[];
  final TextEditingController couponController = TextEditingController();

  // EventLeadModel? eventLead;
  // SuccessEventAmount? successEventAmount;

  @override
  void initState() {
    super.initState();
    userId = Provider.of<ProfileController>(Get.context!, listen: false).userID;
    userNAME =
        Provider.of<ProfileController>(Get.context!, listen: false).userNAME;
    userEMAIL =
        Provider.of<ProfileController>(Get.context!, listen: false).userEMAIL;
    userPHONE =
        Provider.of<ProfileController>(Get.context!, listen: false).userPHONE;
    finalPrice = widget.totalAmount;
    userToken =
        Provider.of<AuthController>(Get.context!, listen: false).getUserToken();
    productAmounts.add(int.parse(widget.totalAmount));
    listSumAmount = int.parse(widget.totalAmount);
    fetchCoupon();
    walletAmount();
    checkPayment("full", widget.leadId);
  }

  final razorpayService = RazorpayPaymentService();

  void checkPayment(String payType, String id) async {
    var res = await HttpService().postApi(
        "/api/v1/offlinepooja/lead/payment-type",
        {"id": id, "payment_type": payType});
    print("response api $res");
  }

  Future<void> fetchCoupon() async {
    final response = await https.get(
      Uri.parse("${AppConstants.baseUrl}/api/v1/offlinepooja/coupon/list"),
      headers: {
        'Authorization': 'Bearer $userToken',
        'Content-Type': 'application/json',
      },
    );
    if (response.statusCode == 200) {
      setState(() {
        couponModelList.clear();
        var data = jsonDecode(response.body);
        List couponList = data['list'];
        couponModelList.addAll(couponList.map((e) => Couponlist.fromJson(e)));
      });
    }
  }

  Future<void> applyCoupon(String code) async {
    final response = await https.post(
      Uri.parse("${AppConstants.baseUrl}/api/v1/offlinepooja/coupon/apply"),
      headers: {
        'Authorization': 'Bearer $userToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        "coupon_code": code,
      }),
    );
    var data = jsonDecode(response.body);
    if (data["status"]) {
      Navigator.pop(context);
      if (couponType == "amount") {
        amountDiscount();
      } else {
        parcentDiscount();
      }
      setState(() {
        isCouponApplyed = true;
        couponMinus = couponType == "amount" ? couponBillRupe : couponBillPerc;
        walletMinusAmount = max(walletPay - couponMinus, 0);
        finalAmount = (walletPay - couponMinus).abs();
        print("$couponMinus $walletMinusAmount $finalAmount $couponBillPerc");
        ToastHelper.showSuccess("Applied Coupon 👍");
      });
    } else {
      String message = data["message"];
      ToastHelper.showError(message);
    }
  }

  Future<void> poojaPlaceOrder(String payId) async {
    String remainAmt =
        "${double.parse(widget.totalAmount) - double.parse(widget.bookingAmount)}";
    String walletBlnc = walletMinusAmount == 0 ? "0" : widget.bookingAmount;
    String couponPayAmount = couponType == "amount"
        ? "$couponDiscountAmount"
        : ((couponDiscountAmount / 100) * minusCouponAmount).toStringAsFixed(0);
    String couponTotal = isCouponApplyed ? couponPayAmount : "";
    String transectionAmount = isCouponApplyed
        ? "$couponMinus"
        : walletMinusAmount == 0
            ? "$finalAmount"
            : "0";
    final bodyData = {
      "wallet_balance": walletMinusAmount == 0
          ? "$walletPay"
          : isHalfPay
              ? widget.totalAmount
              : widget.bookingAmount,
      "customer_id": userId,
      "service_id": widget.serviceId,
      "leads_id": widget.leadId,
      "package_id": widget.packageId,
      "package_main_price": widget.totalAmount, // 10000
      "package_price": widget.bookingAmount, //1000
      "coupon_amount": couponTotal,
      "coupon_code": couponCode,
      "payment_id": payId,
      "transection_amount": transectionAmount,
      "final_amount":
          isHalfPay ? widget.totalAmount : widget.bookingAmount, //1000,
      "remain_amount": isHalfPay ? 0 : remainAmt,
      "remain_amount_status": isHalfPay ? 1 : 0,
      "city": "$selectedCityName",
    };
    print("all data print $bodyData");
    final response = await https.post(
      Uri.parse("${AppConstants.baseUrl}/api/v1/offlinepooja/placeorder"),
      headers: {
        'Authorization': 'Bearer $userToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(bodyData),
    );
    print(remainAmt);
    print(walletMinusAmount == 0 ? "$finalAmount" : "0");
    print(walletMinusAmount == 0
        ? "$walletPay"
        : isHalfPay
            ? widget.totalAmount
            : widget.bookingAmount); // wallet balance
    var data = jsonDecode(response.body);
    if (data["status"]) {
      setState(() {
        String poojaId = data["orderId"];
        Navigator.pop(context);
        Navigator.of(context).push(CupertinoPageRoute(
            builder: (BuildContext context) => OfflinePersonDetails(
                  billAmount:
                      isHalfPay ? widget.totalAmount : widget.bookingAmount,
                  pjIdOrder: poojaId,
                  id: widget.id,
                  location: "$selectedCityName",
                )));
        walletAmount();
        isLoading = false;
        circularIndicator = false;

        // showCupertinoDialog(
        //   barrierDismissible: true,
        //   context: context,
        //   builder: (context) => CupertinoAlertDialog(
        //     title: const Text('ORDER', style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold, fontSize: 24)),
        //     content: const Text('If you want to open the order page then click OPEN.', style: TextStyle(fontSize: 18, color: Colors.blueGrey)),
        //     actions: <Widget>[
        //       CupertinoDialogAction(
        //         child: const Text('Cancfel'),
        //         onPressed: () => Navigator.pop(context),
        //       ),
        //       CupertinoDialogAction(
        //         isDestructiveAction: true, // Red button style
        //         child: const Text('Open'),
        //         onPressed: () {
        //           Navigator.pop(context);
        //           Navigator.of(context).pushReplacement(CupertinoPageRoute(builder: (BuildContext context) => const BottomBar(pageIndex: 3)));
        //         },
        //       ),
        //     ],
        //   ),
        // );
      });
    } else {
      // For error
      ToastHelper.showError("Response Failed!");
    }
  }

  void amountDiscount() {
    // couponTotalRupe = totalAmount - couponDiscountAmount;
    setState(() {
      couponBillRupe = 0;
      isHalfPay
          ? couponBillRupe =
              double.parse(widget.totalAmount) - couponDiscountAmount
          : couponBillRupe =
              double.parse(widget.bookingAmount) - couponDiscountAmount;
      print("coupon bill amount $couponBillPerc $couponMinus");
    });
  }

  void parcentDiscount() {
    // couponTotalPer = totalAmount - totalAmount * couponDiscountAmount ~/ 100;
    setState(() {
      couponBillPerc = 0;
      isHalfPay
          ? couponBillPerc = double.parse(widget.totalAmount) -
              double.parse(widget.totalAmount) * couponDiscountAmount ~/ 100
          : couponBillPerc = double.parse(widget.bookingAmount) -
              double.parse(widget.bookingAmount) * couponDiscountAmount ~/ 100;
      print("coupon bill amount $couponBillPerc $couponMinus");
    });
  }

  void checkAmount(int amount, int index) {
    int checkAmount = isHalfPay
        ? int.parse(widget.totalAmount)
        : int.parse(widget.bookingAmount);
    if (checkAmount >= amount) {
      setState(() {
        couponType = couponModelList[index].discountType;
        couponDiscountAmount = couponModelList[index].discount;
        couponController.text = couponModelList[index].code;
        couponCode = couponModelList[index].code;
        //  Clipboard.setData(ClipboardData(text: "${couponModelList[index].code}"));
        serviceCouponType = couponModelList[index].couponType;
        String couponPayAmount = couponType == "amount"
            ? "${couponDiscountAmount.toDouble()}"
            : "${(couponDiscountAmount / 100) * minusCouponAmount}";
        print("coupon discount $couponPayAmount");
        print(serviceCouponType);
        print(couponDiscountAmount);
        print(couponType);
      });
    } else {
      // For error
      ToastHelper.showError(
          "Minimum order value: ₹${couponModelList[index].minPurchase}.");
    }
  }

  void showCouponSheet() {
    showMaterialModalBottomSheet(
        backgroundColor: Colors.transparent,
        expand: false,
        context: context,
        builder: (context) => StatefulBuilder(
                builder: (BuildContext context, StateSetter modalSetter) {
              return Container(
                height: 700, // Adjust height as needed
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                        topRight: Radius.circular(20),
                        topLeft: Radius.circular(20)),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.grey, blurRadius: 4.0, spreadRadius: 2)
                    ]),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 8),
                    Container(
                      height: 4,
                      width: 40,
                      color: Colors.grey[300],
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: couponController,
                      decoration: InputDecoration(
                        hintText: 'Enter Coupon',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8)),
                        prefixIcon: const Icon(
                          Icons.sensor_window,
                          color: Colors.grey,
                        ),
                        suffixIcon: Padding(
                          padding: const EdgeInsets.only(right: 5.0),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                            ),
                            onPressed: () {
                              modalSetter(() {
                                couponTotalAmount = 0;
                                applyCoupon(couponController.text);
                              });
                            },
                            child: const Text(
                              'Apply',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Row(
                        children: [
                          Container(
                            height: 20,
                            width: 2,
                            color: Colors.orange,
                          ),
                          const SizedBox(
                            width: 8.0,
                          ),
                          const Text(
                            'Available Promo',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: couponModelList.length,
                        itemBuilder: (context, index) {
                          // final promo = promoCodes[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                children: [
                                  Expanded(
                                    flex: 0,
                                    child: Column(
                                      children: [
                                        couponModelList[index].discountType ==
                                                "amount"
                                            ? Image.network(
                                                "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRkplYL67jiq1MrlCAi-DVdpv77KBfNXtjFJg&s",
                                                height: 30,
                                              )
                                            : Image.network(
                                                "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcT5QKzLihvt9Q_wH8nmDI59oiPiVaeScYHBuQ&s",
                                                height: 30,
                                              ),
                                        const SizedBox(
                                          height: 4,
                                        ),
                                        Text(
                                          couponModelList[index].discountType ==
                                                  "amount"
                                              ? "₹${couponModelList[index].discount}.00"
                                              : "${couponModelList[index].discount}.0 %",
                                          style: const TextStyle(
                                              fontSize: 24,
                                              color: Colors.orange,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        const SizedBox(
                                          height: 4,
                                        ),
                                        Text(
                                          "On All Shop",
                                          style: TextStyle(
                                              color: Colors.grey.shade400,
                                              fontSize: 16),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 20.0,
                                  ),
                                  Container(
                                    height: 80,
                                    width: 2,
                                    decoration: BoxDecoration(
                                        color: Colors.orange,
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                  ),
                                  const SizedBox(
                                    width: 20.0,
                                  ),
                                  Expanded(
                                    flex: 1,
                                    child: Column(
                                      children: [
                                        InkWell(
                                          onTap: () {
                                            checkAmount(
                                                couponModelList[index]
                                                    .minPurchase,
                                                index);
                                            // couponType = couponModelList[index].discountType;
                                            // couponDiscountAmount = couponModelList[index].discount;
                                            // couponController.text = couponModelList[index].code;
                                            // Clipboard.setData(ClipboardData(text: couponModelList[index].code));
                                            // serviceCouponType = couponModelList[index].couponType;
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                    'Copied "${couponModelList[index].code}" to clipboard'),
                                                duration:
                                                    const Duration(seconds: 2),
                                                behavior:
                                                    SnackBarBehavior.floating,
                                                margin: const EdgeInsets.only(
                                                    top: 10,
                                                    left: 16,
                                                    right:
                                                        16), // Position at the top
                                              ),
                                            );
                                          },
                                          child: Container(
                                            padding: const EdgeInsets.all(2.0),
                                            height: 36,
                                            width: 180,
                                            decoration: BoxDecoration(
                                                color: Colors.orange.shade50,
                                                borderRadius:
                                                    BorderRadius.circular(6),
                                                border: Border.all(
                                                    color: Colors.orange)),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Text(
                                                  couponModelList[index].code,
                                                  style: const TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                                const SizedBox(
                                                  width: 10,
                                                ),
                                                const Icon(
                                                  Icons.copy,
                                                  color: Colors.orange,
                                                  size: 18,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        const SizedBox(
                                          height: 5,
                                        ),
                                        //  Text("Valid till ${formatExpireDate("${couponModelList[index].expireDate}")}",style: TextStyle(color: Colors.black,fontSize: 16),),
                                        const SizedBox(
                                          height: 5,
                                        ),
                                        Text(
                                          "Available from minimum purchase \n ₹${couponModelList[index].minPurchase}.00",
                                          style: const TextStyle(
                                              color: Colors.grey, fontSize: 14),
                                          textAlign: TextAlign.center,
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
                  ],
                ),
              );
            })).whenComplete(() {
      // Clear text fields when the bottom sheet is closed
      couponController.clear();
    });
  }

  void walletAmount() async {
    var res =
        await HttpService().getApi("/api/v1/pooja/wallet-balance/$userId");
    if (res["success"]) {
      setState(() {
        walletPay = double.parse(res["wallet_balance"].toString());
        walletMinusAmount =
            max(walletPay - double.parse(widget.totalAmount), 0);
        finalAmount = (walletPay - double.parse(widget.totalAmount)).abs();
        minusCouponAmount = double.parse(widget.totalAmount);
      });
    }
  }

  void resetCoupon() {
    setState(() {
      totalQuantity = 1;
      userId = "";
      userNAME = "";
      userEMAIL = "";
      userPHONE = "";
      userToken = "";
      isCouponApplyed = false;
      isLoading = false;
      listSumAmount = 0;
      couponDiscountAmount = 0;
      couponTotalAmount = 0;
      couponTotalRupe = 0;
      couponTotalPer = 0;
      couponBillRupe = 0;
      couponBillPerc = 0;
      walletMinusAmount = 0;
      finalAmount = 0;
      couponMinus = 0;
      couponType = "";
      serviceCouponType = "";
      productAmounts.clear();
      userId =
          Provider.of<ProfileController>(Get.context!, listen: false).userID;
      userNAME =
          Provider.of<ProfileController>(Get.context!, listen: false).userNAME;
      userEMAIL =
          Provider.of<ProfileController>(Get.context!, listen: false).userEMAIL;
      userPHONE =
          Provider.of<ProfileController>(Get.context!, listen: false).userPHONE;
      finalPrice = widget.totalAmount;
      userToken = Provider.of<AuthController>(Get.context!, listen: false)
          .getUserToken();
      productAmounts.add(int.parse(widget.totalAmount));
      listSumAmount = int.parse(widget.totalAmount);
      fetchCoupon();
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var screenwidth = MediaQuery.of(context).size.width;

    return circularIndicator
        ? const MahakalPaymentProcessing()
        : Scaffold(
            floatingActionButtonLocation:
                FloatingActionButtonLocation.centerDocked,
            floatingActionButton: (selectedCityName == null ||
                    selectedCityName?.toLowerCase() == "other")
                ? Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    margin: const EdgeInsets.all(10),
                    height: 70, // Slightly taller for better touch area
                    decoration: BoxDecoration(
                      borderRadius:
                          BorderRadius.circular(10), // Smoother corners
                      gradient: LinearGradient(
                        colors: [Colors.grey.shade700, Colors.grey.shade400],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.deepOrange.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: isLoading
                        ? const Center(
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 3,
                            ),
                          )
                        : Row(
                            children: [
                              // Left side - Amount & Package Name
                              Expanded(
                                flex: 1,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Select City",
                                      style: const TextStyle(
                                        fontSize: 22, // Slightly larger
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'Roboto',
                                        color: Colors.white,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                    Text(
                                      widget.packageName,
                                      style: const TextStyle(
                                          fontSize: 16, // Slightly smaller
                                          fontFamily: 'Roboto',
                                          color:
                                              Colors.white70, // Subtle contrast
                                          overflow: TextOverflow.ellipsis),
                                      maxLines: 1,
                                    ),
                                  ],
                                ),
                              ),

                              // const Spacer(),
                              SizedBox(
                                width: 10,
                              ),
                              // Enhanced Pay Button
                              Expanded(
                                flex: 0,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(
                                        0.2), // Semi-transparent white
                                    borderRadius:
                                        BorderRadius.circular(20), // Pill shape
                                    border: Border.all(
                                      color: Colors.white.withOpacity(0.4),
                                      width: 1,
                                    ),
                                  ),
                                  child: const Row(
                                    children: [
                                      Text(
                                        "Pay Now", // More descriptive
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w600,
                                          fontFamily: 'Roboto',
                                          color: Colors.white,
                                        ),
                                      ),
                                      SizedBox(width: 8),
                                      Icon(
                                        Icons
                                            .arrow_circle_right_rounded, // More modern icon
                                        size: 24,
                                        color: Colors.white,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                  )
                : walletMinusAmount == 0.0
                    ? walletPay == double.parse(widget.totalAmount)
                        ? GestureDetector(
                            onTap: () {
                              showCupertinoDialog(
                                context: context,
                                builder: (_) => CupertinoAlertDialog(
                                  title: const Text("Confirm Payment"),
                                  content: const Text(
                                      "Are you sure you want to proceed with the payment?"),
                                  actions: [
                                    CupertinoDialogAction(
                                      child: const Text(
                                        "Cancel",
                                        style:
                                            TextStyle(color: Color(0xFFFF5A5A)),
                                      ),
                                      onPressed: () =>
                                          Navigator.of(context).pop(),
                                    ),
                                    CupertinoDialogAction(
                                      isDefaultAction: true,
                                      child: const Text(
                                        "Pay Now",
                                        style: TextStyle(
                                            color: Colors.green), // Deep Orange
                                      ),
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                        isLoading
                                            ? null
                                            : poojaPlaceOrder("pay_wallet");
                                        setState(() {
                                          isLoading = true;
                                        });
                                        // Add your payment logic here
                                      },
                                    ),
                                  ],
                                ),
                              );
                              // _showBottomSheets();
                              // print(totalAmount);
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              margin: const EdgeInsets.all(12),
                              height:
                                  70, // Slightly taller for better touch area
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.orange.shade700,
                                    Colors.orange.shade400
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.green.withOpacity(0.3),
                                    blurRadius: 6,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: isLoading
                                  ? const Center(
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 3,
                                      ),
                                    )
                                  : Row(
                                      children: [
                                        // Left side - Payment Method & Package
                                        Expanded(
                                          flex: 1,
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                widget.translateEn == 'en'
                                                    ? "Via Wallet"
                                                    : "वॉलेट के माध्यम से",
                                                style: const TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.w600,
                                                  fontFamily: 'Roboto',
                                                  color: Colors.white,
                                                  letterSpacing: 0.3,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                widget.packageName,
                                                style: TextStyle(
                                                    fontSize: 16,
                                                    fontFamily: 'Roboto',
                                                    color: Colors.white
                                                        .withOpacity(0.9),
                                                    overflow:
                                                        TextOverflow.ellipsis),
                                                maxLines: 1,
                                              ),
                                            ],
                                          ),
                                        ),

                                        // const Spacer(),
                                        SizedBox(
                                          width: 10,
                                        ),
                                        // Enhanced Pay Button
                                        Expanded(
                                          flex: 0,
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 16, vertical: 8),
                                            decoration: BoxDecoration(
                                              color: Colors.white
                                                  .withOpacity(0.15),
                                              borderRadius:
                                                  BorderRadius.circular(24),
                                              border: Border.all(
                                                color: Colors.white
                                                    .withOpacity(0.3),
                                                width: 1.5,
                                              ),
                                            ),
                                            child: Row(
                                              children: [
                                                Text(
                                                  widget.translateEn == 'en'
                                                      ? "Pay Now"
                                                      : "अभी भुगतान करें",
                                                  style: const TextStyle(
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.w600,
                                                    fontFamily: 'Roboto',
                                                    color: Colors.white,
                                                  ),
                                                ),
                                                const SizedBox(width: 8),
                                                const Icon(
                                                  Icons
                                                      .arrow_circle_right_rounded,
                                                  size: 24,
                                                  color: Colors.white,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                            ),
                          ) //wallet
                        : GestureDetector(
                            onTap: () {
                              razorpayService.openCheckout(
                                amount: finalAmount, // ₹100
                                razorpayKey: AppConstants.razorpayLive,
                                onSuccess: (response) {
                                  setState(() {
                                    circularIndicator = true;
                                  });
                                  print("PaymentSuccess");
                                  poojaPlaceOrder("${response.paymentId}");
                                },
                                onFailure: (response) {
                                  setState(() {
                                    circularIndicator = false;
                                  });
                                },
                                onExternalWallet: (response) {
                                  print("Wallet: ${response.walletName}");
                                },
                                description: 'Offline pooja',
                              );
                              setState(() {
                                isLoading = false;
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              margin: const EdgeInsets.all(10),
                              height:
                                  70, // Slightly taller for better touch area
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(
                                    10), // Smoother corners
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.orange.shade700,
                                    Colors.orange.shade400
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.deepOrange.withOpacity(0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: isLoading
                                  ? const Center(
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 3,
                                      ),
                                    )
                                  : Row(
                                      children: [
                                        // Left side - Amount & Package Name
                                        Expanded(
                                          flex: 1,
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                "₹$finalAmount",
                                                style: const TextStyle(
                                                  fontSize:
                                                      22, // Slightly larger
                                                  fontWeight: FontWeight.bold,
                                                  fontFamily: 'Roboto',
                                                  color: Colors.white,
                                                  letterSpacing: 0.5,
                                                ),
                                              ),
                                              Text(
                                                widget.packageName,
                                                style: const TextStyle(
                                                    fontSize:
                                                        16, // Slightly smaller
                                                    fontFamily: 'Roboto',
                                                    color: Colors
                                                        .white70, // Subtle contrast
                                                    overflow:
                                                        TextOverflow.ellipsis),
                                                maxLines: 1,
                                              ),
                                            ],
                                          ),
                                        ),

                                        // const Spacer(),
                                        SizedBox(
                                          width: 10,
                                        ),
                                        // Enhanced Pay Button
                                        Expanded(
                                          flex: 0,
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 16, vertical: 8),
                                            decoration: BoxDecoration(
                                              color: Colors.white.withOpacity(
                                                  0.2), // Semi-transparent white
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      20), // Pill shape
                                              border: Border.all(
                                                color: Colors.white
                                                    .withOpacity(0.4),
                                                width: 1,
                                              ),
                                            ),
                                            child: const Row(
                                              children: [
                                                Text(
                                                  "Pay Now", // More descriptive
                                                  style: TextStyle(
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.w600,
                                                    fontFamily: 'Roboto',
                                                    color: Colors.white,
                                                  ),
                                                ),
                                                SizedBox(width: 8),
                                                Icon(
                                                  Icons
                                                      .arrow_circle_right_rounded, // More modern icon
                                                  size: 24,
                                                  color: Colors.white,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                            ),
                          ) //razorpay
                    : GestureDetector(
                        onTap: () {
                          showCupertinoDialog(
                            context: context,
                            builder: (_) => CupertinoAlertDialog(
                              title: const Text("Confirm Payment"),
                              content: const Text(
                                  "Are you sure you want to proceed with the payment?"),
                              actions: [
                                CupertinoDialogAction(
                                  child: const Text(
                                    "Cancel",
                                    style: TextStyle(color: Color(0xFFFF5A5A)),
                                  ),
                                  onPressed: () => Navigator.of(context).pop(),
                                ),
                                CupertinoDialogAction(
                                  isDefaultAction: true,
                                  child: const Text(
                                    "Pay Now",
                                    style: TextStyle(
                                        color: Colors.green), // Deep Orange
                                  ),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                    isLoading
                                        ? null
                                        : poojaPlaceOrder("pay_wallet");
                                    setState(() {
                                      isLoading = true;
                                    });
                                    // Add your payment logic here
                                  },
                                ),
                              ],
                            ),
                          );
                          // _showBottomSheets();
                          // print(totalAmount);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          margin: const EdgeInsets.all(12),
                          height: 70, // Slightly taller for better touch area
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            gradient: LinearGradient(
                              colors: [
                                Colors.orange.shade700,
                                Colors.orange.shade400
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.green.withOpacity(0.3),
                                blurRadius: 6,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: isLoading
                              ? const Center(
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 3,
                                  ),
                                )
                              : Row(
                                  children: [
                                    // Left side - Payment Method & Package
                                    Expanded(
                                      flex: 1,
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            widget.translateEn == 'en'
                                                ? "Via Wallet"
                                                : "वॉलेट के माध्यम से",
                                            style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.w600,
                                              fontFamily: 'Roboto',
                                              color: Colors.white,
                                              letterSpacing: 0.3,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            widget.packageName,
                                            style: TextStyle(
                                                fontSize: 16,
                                                fontFamily: 'Roboto',
                                                color: Colors.white
                                                    .withOpacity(0.9),
                                                overflow:
                                                    TextOverflow.ellipsis),
                                            maxLines: 1,
                                          ),
                                        ],
                                      ),
                                    ),

                                    // const Spacer(),
                                    SizedBox(
                                      width: 10,
                                    ),
                                    // Enhanced Pay Button
                                    Expanded(
                                      flex: 0,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 16, vertical: 8),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.15),
                                          borderRadius:
                                              BorderRadius.circular(24),
                                          border: Border.all(
                                            color:
                                                Colors.white.withOpacity(0.3),
                                            width: 1.5,
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            Text(
                                              widget.translateEn == 'en'
                                                  ? "Pay Now"
                                                  : "अभी भुगतान करें",
                                              style: const TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.w600,
                                                fontFamily: 'Roboto',
                                                color: Colors.white,
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            const Icon(
                                              Icons.arrow_circle_right_rounded,
                                              size: 24,
                                              color: Colors.white,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ), // wallet
            appBar: AppBar(
              title: Text(
                widget.translateEn == 'en' ? "Payment details" : "भुगतान विवरण",
                style: const TextStyle(
                    fontWeight: FontWeight.bold, color: Colors.orange),
              ),
              centerTitle: true,
            ),
            body: SafeArea(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(6),
                          color: Colors.white,
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black26,
                              spreadRadius: -10.0,
                              blurRadius: 10.0,
                              offset: Offset(0.0, 10.0),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Expanded(
                                flex: 0,
                                child: ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.network(
                                      widget.imageUrl,
                                      height: 120,
                                    ))),
                            const SizedBox(
                              width: 10,
                            ),
                            Expanded(
                              flex: 1,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget
                                        .packageName, // Replace with dynamic package name
                                    style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.orange),
                                  ),
                                  Html(data: widget.detail),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Adds a line separator
                      // Text(
                      //   "Total Amount: ₹${widget.totalAmount}", // Replace with dynamic amount
                      //   style: TextStyle(
                      //     fontSize: 16,
                      //     fontWeight: FontWeight.w500,
                      //     color: Colors.green[700],
                      //   ),
                      // ),
                      // SizedBox(height: 5),
                      //
                      const SizedBox(
                        height: 10,
                      ),
                      isCouponApplyed
                          ? InkWell(
                              onTap: () {
                                showCouponSheet();
                              },
                              child: Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  color: Colors.green,
                                  border: Border.all(
                                      color: Colors.grey.shade400, width: 1.5),
                                ),
                                child: Row(
                                  children: [
                                    Text(
                                      widget.translateEn == 'en'
                                          ? "Coupon Applied"
                                          : "कूपन लागू करे",
                                      style: const TextStyle(
                                          fontSize: 18,
                                          letterSpacing: 0.5,
                                          fontWeight: FontWeight.w500,
                                          fontFamily: 'Roboto',
                                          color: Colors.white),
                                    ),
                                    const Spacer(),
                                    InkWell(
                                        onTap: () {
                                          setState(() {
                                            isCouponApplyed = false;
                                            if (isHalfPay) {
                                              walletMinusAmount = max(
                                                  walletPay -
                                                      double.parse(
                                                          widget.totalAmount),
                                                  0);
                                              finalAmount = (walletPay -
                                                      double.parse(
                                                          widget.totalAmount))
                                                  .abs();
                                            } else {
                                              walletMinusAmount = max(
                                                  walletPay -
                                                      double.parse(
                                                          widget.bookingAmount),
                                                  0);
                                              finalAmount = (walletPay -
                                                      double.parse(
                                                          widget.bookingAmount))
                                                  .abs();
                                            }
                                          });
                                        },
                                        child: const Icon(
                                          Icons.delete_outline_rounded,
                                          color: Colors.white,
                                          size: 22,
                                        ))
                                  ],
                                ),
                              ),
                            )
                          : Container(
                              height: 50,
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                color: Colors.transparent,
                                border: Border.all(
                                    color: Colors.grey.shade400, width: 1.5),
                              ),
                              child: Row(
                                children: [
                                  Text(
                                    widget.translateEn == 'en'
                                        ? "Add Coupon"
                                        : "कूपन जोड़ें",
                                    style: const TextStyle(
                                        fontSize: 18,
                                        letterSpacing: 0.5,
                                        fontWeight: FontWeight.w500,
                                        fontFamily: 'Roboto',
                                        color: Colors.orange),
                                  ),
                                  const Spacer(),
                                  InkWell(
                                      onTap: () {
                                        showCouponSheet();
                                      },
                                      child: Row(
                                        children: [
                                          Text(
                                            widget.translateEn == 'en'
                                                ? "Add"
                                                : "जोड़ें",
                                            style: const TextStyle(
                                                color: Colors.orange,
                                                fontSize: 16),
                                          ),
                                          const Icon(
                                            Icons.add,
                                            color: Colors.orange,
                                            size: 22,
                                          ),
                                        ],
                                      ))
                                ],
                              ),
                            ),

                      const SizedBox(
                        height: 10,
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(12),
                          border:
                              Border.all(color: Colors.grey.shade400, width: 1),
                        ),
                        child: DropdownButtonFormField<String>(
                          value: selectedCityName,
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                          ),
                          hint: const Text(
                            "Select City",
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          icon: const Icon(Icons.keyboard_arrow_down,
                              color: Colors.black54),
                          isExpanded: true,
                          items: [
                            ...widget.citiesModelList.map((city) {
                              return DropdownMenuItem<String>(
                                value: city.name,
                                child: Text(
                                  city.name,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black87,
                                  ),
                                ),
                              );
                            }).toList(),

                            // 👇 Extra option "Other"
                            const DropdownMenuItem<String>(
                              value: "Other",
                              child: Text(
                                "Other",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.deepOrange,
                                ),
                              ),
                            ),
                          ],
                          onChanged: (value) {
                            setState(() {
                              selectedCityName = value;
                            });

                            if (value == "Other") {
                              // 👇 Show SnackBar message
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content:
                                      Text("New cities will be available soon"),
                                  duration: Duration(seconds: 2),
                                  backgroundColor: Colors.deepOrange,
                                ),
                              );
                            } else {
                              print("Selected City: $selectedCityName");
                            }
                          },
                        ),
                      ),

                      const SizedBox(
                        height: 10,
                      ),
                      isCouponApplyed
                          ? const SizedBox.shrink()
                          : Container(
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey.shade400),
                                borderRadius: BorderRadius.circular(8),
                                color: Colors.white,
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          walletMinusAmount = max(
                                              walletPay -
                                                  double.parse(
                                                      widget.totalAmount),
                                              0);
                                          finalAmount = (walletPay -
                                                  double.parse(
                                                      widget.totalAmount))
                                              .abs();
                                          minusCouponAmount =
                                              double.parse(widget.totalAmount);
                                          isHalfPay =
                                              true; // Select Partial Pay
                                        });
                                        checkPayment("full", widget.leadId);
                                      },
                                      child: Container(
                                        margin: const EdgeInsets.all(8),
                                        height: 45,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(8.0),
                                          border: Border.all(
                                              color: isHalfPay
                                                  ? Colors.orange
                                                  : Colors.transparent),
                                          color: isHalfPay
                                              ? Colors.orange
                                              : Colors.grey.shade200,
                                        ),
                                        child: Center(
                                          child: Text(
                                            "Full Payment",
                                            style: TextStyle(
                                              fontSize: 18,
                                              color: isHalfPay
                                                  ? Colors.white
                                                  : Colors.orange,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          walletMinusAmount = max(
                                              walletPay -
                                                  double.parse(
                                                      widget.bookingAmount),
                                              0);
                                          finalAmount = (walletPay -
                                                  double.parse(
                                                      widget.bookingAmount))
                                              .abs();
                                          minusCouponAmount = double.parse(
                                              widget.bookingAmount);
                                          isHalfPay = false; // Select Full Pay
                                        });
                                        checkPayment("partial", widget.leadId);
                                      },
                                      child: Container(
                                        margin: const EdgeInsets.all(8),
                                        height: 45,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(8.0),
                                          border: Border.all(
                                              color: isHalfPay
                                                  ? Colors.transparent
                                                  : Colors.orange),
                                          color: isHalfPay
                                              ? Colors.grey.shade200
                                              : Colors.orange,
                                        ),
                                        child: Center(
                                          child: Text(
                                            "Partial Payment",
                                            style: TextStyle(
                                              fontSize: 18,
                                              color: isHalfPay
                                                  ? Colors.orange
                                                  : Colors.white,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                      const SizedBox(
                        height: 10,
                      ),
                      isHalfPay
                          ? Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.grey.shade300),
                                color: Colors.white,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.1),
                                    spreadRadius: 1,
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Bill Details Header
                                  Text(
                                    widget.translateEn == 'en'
                                        ? "Bill details"
                                        : "बिल विवरण",
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'Roboto',
                                      color: Colors.orange[700],
                                    ),
                                  ),
                                  const SizedBox(height: 12),

                                  // Amount Rows
                                  _buildBillRow(
                                    context,
                                    label: widget.translateEn == 'en'
                                        ? "Total Amount"
                                        : "कुल राशि",
                                    value: "₹${widget.totalAmount}.0",
                                    valueColor: Colors.green,
                                  ),

                                  _buildBillRow(
                                    context,
                                    label: widget.translateEn == 'en'
                                        ? "Paid Amount"
                                        : "भुगतान राशि",
                                    value: "- ₹${widget.totalAmount}.0",
                                    valueColor: Colors.red,
                                  ),

                                  if (!isHalfPay)
                                    _buildBillRow(
                                      context,
                                      label: widget.translateEn == 'en'
                                          ? "Remaining Amount"
                                          : "शेष राशि",
                                      value:
                                          "₹${int.parse(widget.totalAmount) - int.parse(widget.bookingAmount)}.0",
                                      valueColor: Colors.blue,
                                    ),

                                  Divider(
                                      height: 24,
                                      thickness: 1,
                                      color: Colors.grey.shade200),

                                  // Discount Section
                                  isCouponApplyed
                                      ? _buildBillRow(
                                          context,
                                          label: widget.translateEn == "en"
                                              ? "Special Discount"
                                              : "विशेष छूट",
                                          value: couponType == "amount"
                                              ? "- ₹$couponDiscountAmount.0"
                                              : "- $couponDiscountAmount.0 %",
                                          valueColor: Colors.red,
                                        )
                                      : _buildBillRow(
                                          context,
                                          label: widget.translateEn == "en"
                                              ? "Special Discount"
                                              : "विशेष छूट",
                                          value: "- ₹0.0",
                                          valueColor: Colors.grey,
                                        ),

                                  Divider(
                                      height: 24,
                                      thickness: 1,
                                      color: Colors.grey.shade200),

                                  // Wallet Section
                                  _buildBillRow(
                                    context,
                                    label: widget.translateEn == "en"
                                        ? "Wallet Balance"
                                        : "वॉलेट बैलेंस",
                                    value: "₹$walletPay",
                                    valueColor: Colors.blue,
                                    isBold: true,
                                  ),

                                  Padding(
                                    padding:
                                        const EdgeInsets.symmetric(vertical: 4),
                                    child: RichText(
                                      text: TextSpan(
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontFamily: 'Roboto',
                                          color: Colors.grey.shade700,
                                        ),
                                        children: [
                                          TextSpan(
                                              text: widget.translateEn == "en"
                                                  ? "Wallet remaining ("
                                                  : "वॉलेट शेष बैलेंस ("),
                                          TextSpan(
                                            text: "₹$walletMinusAmount",
                                            style: const TextStyle(
                                              color: Colors.green,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const TextSpan(text: ")"),
                                        ],
                                      ),
                                    ),
                                  ),
                                  _buildBillRow(
                                    context,
                                    label: widget.translateEn == "en"
                                        ? "Amount Paid (via Wallet)"
                                        : "भुगतान की गई राशि (वॉलेट से)",
                                    value: isCouponApplyed
                                        ? "- ₹$couponMinus"
                                        : "- ₹${walletMinusAmount == 0 ? walletPay : (isHalfPay ? widget.totalAmount : widget.bookingAmount)}",
                                    valueColor: Colors.red,
                                  ),

                                  Divider(
                                      height: 24,
                                      thickness: 1,
                                      color: Colors.grey.shade200),

                                  // Total Amount
                                  _buildBillRow(
                                    context,
                                    label: widget.translateEn == 'en'
                                        ? "Total Amount"
                                        : "कुल राशि",
                                    value: walletMinusAmount == 0
                                        ? "₹$finalAmount"
                                        : "₹0.0",
                                    valueColor: Colors.orange,
                                    isBold: true,
                                    fontSize: 18,
                                  ),
                                ],
                              ),
                            )
                          : Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.grey.shade300),
                                color: Colors.white,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.1),
                                    spreadRadius: 1,
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(Icons.receipt,
                                          color: Colors.orange, size: 22),
                                      const SizedBox(width: 8),
                                      Text(
                                        widget.translateEn == 'en'
                                            ? "Bill details"
                                            : "बिल विवरण",
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          fontFamily: 'Roboto',
                                          color: Colors.orange[700],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),

                                  // Amount Summary
                                  _buildBillRow(
                                    context,
                                    label: widget.translateEn == 'en'
                                        ? "Total Amount"
                                        : "कुल राशि",
                                    value: "₹${widget.totalAmount}.0",
                                    valueColor: Colors.green,
                                  ),

                                  _buildBillRow(
                                    context,
                                    label: widget.translateEn == 'en'
                                        ? "Paid Amount"
                                        : "भुगतान राशि",
                                    value: "- ₹${widget.bookingAmount}.0",
                                    valueColor: Colors.red,
                                  ),

                                  _buildBillRow(
                                    context,
                                    label: widget.translateEn == 'en'
                                        ? "Remaining Amount"
                                        : "शेष राशि",
                                    value:
                                        "₹${int.parse(widget.totalAmount) - int.parse(widget.bookingAmount)}.0",
                                    valueColor: Colors.blue,
                                  ),

                                  // Items List
                                  const SizedBox(height: 12),
                                  ListView.builder(
                                    shrinkWrap: true,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    itemCount: items.length,
                                    itemBuilder: (context, index) {
                                      final totalPay = items[index]
                                              ['quantity'] *
                                          items[index]['amount'];
                                      return Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 6),
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                "${items[index]['name']}",
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w400,
                                                  fontFamily: 'Roboto',
                                                  color: Colors.grey.shade800,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            Text(
                                              "${items[index]['quantity']} x ",
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontFamily: 'Roboto',
                                                color: Colors.grey.shade600,
                                              ),
                                            ),
                                            Text(
                                              "₹$totalPay.0",
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontFamily: 'Roboto',
                                                color: Colors.blue,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),

                                  Divider(
                                      height: 24, color: Colors.grey.shade200),

                                  // Discount Section
                                  isCouponApplyed
                                      ? _buildBillRow(
                                          context,
                                          label: widget.translateEn == "en"
                                              ? "Special Discount"
                                              : "विशेष छूट",
                                          value: couponType == "amount"
                                              ? "- ₹$couponDiscountAmount.0"
                                              : "- $couponDiscountAmount.0 %",
                                          valueColor: Colors.red,
                                        )
                                      : _buildBillRow(
                                          context,
                                          label: widget.translateEn == "en"
                                              ? "Special Discount"
                                              : "विशेष छूट",
                                          value: "- ₹0.0",
                                          valueColor: Colors.grey,
                                        ),

                                  Divider(
                                      height: 24, color: Colors.grey.shade200),

                                  // Wallet Section
                                  _buildBillRow(
                                    context,
                                    label: widget.translateEn == "en"
                                        ? "Wallet Balance"
                                        : "वॉलेट बैलेंस",
                                    value: "₹$walletPay",
                                    valueColor: Colors.blue,
                                    isBold: true,
                                  ),

                                  Padding(
                                    padding: const EdgeInsets.only(
                                        top: 4, bottom: 8),
                                    child: RichText(
                                      text: TextSpan(
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontFamily: 'Roboto',
                                          color: Colors.grey.shade700,
                                        ),
                                        children: [
                                          TextSpan(
                                              text: widget.translateEn == "en"
                                                  ? "Wallet remaining ("
                                                  : "वॉलेट शेष बैलेंस ("),
                                          TextSpan(
                                            text: "₹$walletMinusAmount",
                                            style: const TextStyle(
                                              color: Colors.green,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const TextSpan(text: ")"),
                                        ],
                                      ),
                                    ),
                                  ),

                                  _buildBillRow(
                                    context,
                                    label: widget.translateEn == "en"
                                        ? "Amount Paid (via Wallet)"
                                        : "भुगतान की गई राशि (वॉलेट से)",
                                    value: isCouponApplyed
                                        ? "- ₹$couponMinus.0"
                                        : walletMinusAmount == 0
                                            ? "- ₹$walletPay"
                                            : "- ₹${widget.bookingAmount}.0",
                                    valueColor: Colors.red,
                                  ),

                                  Divider(
                                      height: 24, color: Colors.grey.shade200),

                                  // Final Total
                                  _buildBillRow(
                                    context,
                                    label: widget.translateEn == 'en'
                                        ? "Total Amount"
                                        : "कुल राशि",
                                    value: walletMinusAmount == 0
                                        ? "₹$finalAmount"
                                        : "₹0.0",
                                    valueColor: Colors.orange,
                                    isBold: true,
                                    fontSize: 18,
                                  ),
                                ],
                              ),
                            ),

                      const SizedBox(
                        height: 20,
                      ),
                      isHalfPay
                          ? const SizedBox.shrink()
                          : widget.translateEn == 'en'
                              ? Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(
                                      16), // Increased padding for better spacing
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(
                                        8), // Slightly larger radius for modern look
                                    color: Colors.orange.shade50,
                                    border: Border.all(
                                      // Added subtle border for definition
                                      color: Colors.orange.shade100,
                                      width: 1,
                                    ),
                                  ),
                                  child: RichText(
                                    textAlign: TextAlign
                                        .center, // Center align directly in RichText
                                    text: TextSpan(
                                      style: const TextStyle(
                                        color: Colors
                                            .black87, // Slightly softer than pure black
                                        fontSize:
                                            16, // Slightly smaller for better proportions
                                        height:
                                            1.4, // Better line height for readability
                                      ),
                                      children: [
                                        const TextSpan(
                                          text:
                                              "Secure your Puja booking now by depositing the booking amount. Pay the remaining ",
                                        ),
                                        TextSpan(
                                          text:
                                              "₹${int.parse(widget.totalAmount) - int.parse(widget.bookingAmount)}",
                                          style: TextStyle(
                                            color: Colors.orange
                                                .shade700, // Darker orange for better contrast
                                            fontWeight: FontWeight.bold,
                                            fontSize:
                                                18, // Slightly larger than base text
                                          ),
                                        ),
                                        const TextSpan(
                                          text: " later.",
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                              : Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 12), // Better padding
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(
                                        8), // Smoother corners
                                    color: Colors.orange.shade50,
                                    border: Border.all(
                                      color: Colors.orange
                                          .shade200, // Subtle border for better definition
                                      width: 1,
                                    ),
                                  ),
                                  child: RichText(
                                    textAlign: TextAlign
                                        .center, // Center-align the text
                                    text: TextSpan(
                                      style: const TextStyle(
                                        color: Colors
                                            .black87, // Softer than pure black
                                        fontSize:
                                            17, // Slightly adjusted for better Hindi readability
                                        height: 1.5, // Better line spacing
                                      ),
                                      children: [
                                        const TextSpan(
                                          text:
                                              "अभी बुकिंग राशि जमा करें और अपनी पूजा सुनिश्चित करें। शेष ",
                                        ),
                                        TextSpan(
                                          text:
                                              "₹${int.parse(widget.totalAmount) - int.parse(widget.bookingAmount)} ",
                                          style: TextStyle(
                                            color: Colors.orange
                                                .shade700, // Darker orange for better contrast
                                            fontWeight: FontWeight.bold,
                                            fontSize:
                                                19, // Slightly larger for emphasis
                                          ),
                                        ),
                                        const TextSpan(
                                          text: "बाद में भुगतान करें।",
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                      const SizedBox(
                        height: 80,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
  }

// Helper Widget
  Widget _buildBillRow(
    BuildContext context, {
    required String label,
    required String value,
    required Color valueColor,
    bool isBold = false,
    double fontSize = 16,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w400,
              fontFamily: 'Roboto',
              color: Colors.grey.shade700,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
              fontFamily: 'Roboto',
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }
}
