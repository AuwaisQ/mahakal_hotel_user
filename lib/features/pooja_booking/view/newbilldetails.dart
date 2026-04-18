import 'dart:convert';
import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:mahakal/data/datasource/remote/http/httpClient.dart';
import 'package:mahakal/features/pooja_booking/view/persondetails.dart';
import 'package:mahakal/utill/app_constants.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import '../../../main.dart';
import '../../../utill/flutter_toast_helper.dart';
import '../../../utill/razorpay_screen.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../explore/payment_process_screen.dart';
import '../../profile/controllers/profile_contrroller.dart';
import '../model/coupon_model.dart';
import '../model/productsmodel.dart';

class Newbilldetails extends StatefulWidget {
  String billAmount;
  String typePooja;
  String packageName;
  String poojaName;
  String poojaVenue;
  String date;
  int orderId;
  List<ProductsModel> product;
  int? personCount;
  int leadId;
  int packageId;
  int serviceId;
  String couponType;
  Newbilldetails({
    super.key,
    required this.billAmount,
    required this.poojaName,
    required this.poojaVenue,
    required this.date,
    required this.packageName,
    required this.orderId,
    required this.typePooja,
    required this.product,
    required this.personCount,
    required this.leadId,
    required this.packageId,
    required this.serviceId,
    required this.couponType,
  });

  @override
  State<Newbilldetails> createState() => _NewbilldetailsState();
}

class _NewbilldetailsState extends State<Newbilldetails> {
  // final List<bool> _isAdded = List.generate(5, (index) => true);
  final List<int> quantity = List.generate(10, (index) => 0);
  List<int> productAmounts = [];
  List<Map<String, dynamic>> charityList = [];
  List<Map<String, dynamic>> items = [];
  final TextEditingController couponController = TextEditingController();

  List<Couponlist> couponModelList = <Couponlist>[];

  bool _showText = false;
  bool circularIndicator = false;
  bool isFunction = false;
  bool isCouponApplyed = false;
  bool isLoading = false;
  double listSumAmount = 0.0;
  double totalAmount = 0.0;
  int couponDiscountAmount = 0;
  double couponTotalAmount = 0.0;
  double couponTotalRupe = 0.0;
  double couponTotalPer = 0.0;
  double couponBillRupe = 0.0;
  double couponBillPerc = 0.0;
  double walletPay = 0.0;
  double walletMinusAmount = 0.0;
  double finalAmount = 0.0;
  String couponCode = "";
  String couponType = "";
  String orderIdPooja = "";
  String serviceCouponType = "";
  int maxDiscount = 0;
  bool maxDiscountCheck = false;
  var checkMess = "";
  String userId = "";
  String userNAME = "";
  String userEMAIL = "";
  String userPHONE = "";
  String userToken = "";
  final razorpayService = RazorpayPaymentService();

  void resetQuantities() {
    setState(() {
      // Reset all quantities to their initial state (0 or a default value)
      for (int i = 0; i < quantity.length; i++) {
        quantity[i] = 0; // Reset all quantities to 0
      }

      // Clear product amounts and reset related calculations
      productAmounts.clear();
      // Clear charity list and items
      charityList.clear();
      items.clear();

      // Update any flags or conditions
      isFunction = false;
    });
  }

  void incrementQuantity(int index, String productId, int quantityProduct) {
    setState(() {
      if (quantity[index] < 10) {
        if (walletPay == 0) {
          print("if increment");
          quantity[index]++;
          productAmounts.add(widget.product[index].price);
          // listSumAmount = double.parse(widget.billAmount);
          // couponBillRupe = 0; // Reset couponBillRupe before recalculating
          listSumAmount =
              productAmounts.fold(0, (prev, element) => prev + element);
          // couponBillRupe += listSumAmount; // This seems incorrect, should be based on discounts
          // couponBillRupe = listSumAmount; // If no discount, it's just the listSumAmount
          // totalAmount = 0;
          // totalAmount = listSumAmount + int.parse(widget.billAmount);
          quantity[index] == 0 ? isFunction = false : isFunction = true;
          walletMinusAmount = max(walletPay - listSumAmount, 0);
          finalAmount = (walletPay - listSumAmount).abs();
        } else {
          print("else increment");
          quantity[index]++;
          productAmounts.add(widget.product[index].price);
          // listSumAmount = double.parse(widget.billAmount);
          // couponBillRupe = 0; // Reset couponBillRupe before recalculating
          listSumAmount =
              productAmounts.fold(0, (prev, element) => prev + element);
          // couponBillRupe += listSumAmount; // This seems incorrect, should be based on discounts
          // couponBillRupe = listSumAmount; // If no discount, it's just the listSumAmount
          // totalAmount = 0;
          // totalAmount = listSumAmount + int.parse(widget.billAmount);
          quantity[index] == 0 ? isFunction = false : isFunction = true;
          walletMinusAmount = max(walletPay - listSumAmount, 0);
          finalAmount = (walletPay - listSumAmount).abs();
        }
      }
      // listSumAmount += int.parse(widget.billAmount);
      // Create a new product entry
      var newProduct = {"product_id": productId, "quantity": quantityProduct};
      // Check if the product already exists in the list
      int existingIndex = charityList
          .indexWhere((product) => product["product_id"] == productId);

      if (existingIndex != -1) {
        // Replace the existing product with the new one
        charityList[existingIndex] = newProduct;
      } else {
        // Add the new product if it doesn't exist
        charityList.add(newProduct);
      }
    });
  }

  void decrementQuantity(int index, String productId, int quantityProduct) {
    setState(() {
      if (quantity[index] > 0) {
        quantity[index]--;
        productAmounts.remove(widget.product[index].price);
        listSumAmount = 0;
        // couponBillRupe = 0; // Reset couponBillRupe before recalculating
        listSumAmount =
            productAmounts.fold(0, (prev, element) => prev + element);
        // couponBillRupe = listSumAmount; // If no discount, it's just the listSumAmount
        // totalAmount = 0;
        // totalAmount = listSumAmount + int.parse(widget.billAmount);
        quantity[index] == 0 ? isFunction = false : isFunction = true;
        walletMinusAmount = max(walletPay - listSumAmount, 0);
        finalAmount = (walletPay - listSumAmount).abs();
      }
      // Create a new product entry
      // var newProduct = {
      //   "product_id": productId,
      //   "quantity": quantityProduct
      // };

      for (int i = charityList.length - 1; i >= 0; i--) {
        if (charityList[i]["product_id"] == productId) {
          // Decrement the quantity
          charityList[i]["quantity"]--;
          items[i]['quantity']--;
          // If quantity becomes 0, remove the product
          if (charityList[i]["quantity"] <= 0) {
            charityList.removeAt(i); // Remove the product with quantity 0
            items.removeAt(i);
          }
          break; // Exit the loop after handling the product
        }
      }
    });
  }

  void addItem(String name, int amount, int quantity) {
    // Check if an item with the same name and amount already exists
    int existingIndex = items
        .indexWhere((item) => item['name'] == name && item['amount'] == amount);

    setState(() {
      if (existingIndex != -1) {
        // If the item exists, replace the quantity
        items[existingIndex]['quantity'] = quantity;
      } else {
        // Add the new item if it doesn't exist with the provided quantity
        items.add({
          'name': name,
          'amount': amount,
          'quantity': quantity, // Set initial quantity
        });
      }
    });
  }

  void oderPlacePooja(String payId, bool isCoupon) async {
    // String payAmount =  walletMinusAmount == 0
    //     ? "$finalAmount"
    //     : "$listSumAmount";
    //  String couponPayAmount =   couponTotalAmount == 0 ?
    //  couponType == "amount" ? "$couponBillRupe" : "$couponBillPerc"
    //      : "$couponTotalAmount";
    String couponPayAmount = couponType == "amount"
        ? "$couponDiscountAmount"
        : maxDiscountCheck
            ? "$maxDiscount"
            : "${(int.parse(widget.billAmount) * couponDiscountAmount / 100)}";
    // : ((couponDiscountAmount / 100) * finalAmount).toStringAsFixed(0);
    String finalTotal = isCoupon
        ? couponTotalAmount == 0
            ? couponType == "amount"
                ? "$couponBillRupe"
                : "$couponBillPerc"
            : "$couponTotalAmount"
        : "$listSumAmount";
    String couponTotal = isCoupon ? couponPayAmount : "";
    DateTime parsedDate =
        DateTime.parse(widget.date); // Parse the string to DateTime
    String formattedDate = DateFormat("yyyy-MM-dd").format(parsedDate);
    print("final check: $finalTotal");
    // int transactionAmount = (finalAmount - double.parse(finalTotal)).abs().toInt();
    // String walletBalance = walletMinusAmount == 0 ? "$transactionAmount" : finalTotal;
    String walletBalance =
        walletMinusAmount == 0 ? "$walletPay" : "$listSumAmount";
    String payAmount = walletMinusAmount == 0 ? finalTotal : walletBalance;
    String PayAmountFinal =
        "${walletMinusAmount == 0 ? (walletPay + finalAmount) : payAmount}";
    double sumProduct =
        productAmounts.sublist(1).fold(0, (prev, element) => prev + element);
    print("discount amount $couponTotal ");
    print("bill code  -- ${couponController.text} -- $couponCode ");
    print("bill amount $couponPayAmount");
    print("transection_amount: ${walletMinusAmount == 0 ? "$finalAmount" : 0}");
    print("wallet_balance: $walletMinusAmount");
    print("balance: $walletMinusAmount"); // wallet se jo amount kate ga
    print(
        "pay amount:  -- $PayAmountFinal  --  pSUM ${double.parse(widget.billAmount) + sumProduct}");
    print("debit: $walletBalance"); // wallet se jo amount kate ga

    final data = {
      "customer_id": userId,
      "service_id": "${widget.serviceId}",
      "type": widget.typePooja,
      "leads_id": "${widget.leadId}",
      "package_id": "${widget.packageId}",
      "package_price": widget.billAmount,
      "booking_date": formattedDate,
      "coupon_amount": couponTotal,
      "coupon_code": couponCode,
      "payment_id": payId,
      "payment_amount": isCoupon
          ? "${double.parse(widget.billAmount) + sumProduct}"
          : PayAmountFinal,
      "transection_amount": walletMinusAmount == 0 ? "$finalAmount" : "0",
      "wallet_balance": "$walletMinusAmount",
      "balance": "$walletMinusAmount",
      "debit": walletBalance,
    };
    print("Api response check krna h $data");
    var res = await HttpService().postApi(AppConstants.poojaOrderPlaceUrl, {
      "customer_id": userId,
      "service_id": "${widget.serviceId}",
      "type": widget.typePooja,
      "leads_id": "${widget.leadId}",
      "package_id": "${widget.packageId}",
      "package_price": widget.billAmount,
      "booking_date": formattedDate,
      "coupon_amount": couponTotal,
      "coupon_code": couponCode,
      "payment_id": payId,
      "payment_amount": isCoupon
          ? "${double.parse(widget.billAmount) + sumProduct}"
          : PayAmountFinal,
      "transection_amount": walletMinusAmount == 0 ? "$finalAmount" : "0",
      "wallet_balance": "$walletMinusAmount",
      "balance": "$walletMinusAmount",
      "debit": walletBalance,
    });
    print(finalTotal);
    print(walletMinusAmount == 0 ? "$finalAmount" : "0");
    print(walletBalance);
    print("Api response amount $finalTotal");
    print("Api response data pooja $res");
    if (res['status']) {
      setState(() {
        orderIdPooja = res['order_id'];
        isLoading = false;
      });
      print("total coupon discount $couponTotal");
      String billAmount = "₹$listSumAmount";
      Navigator.pop(context);
      Navigator.pushReplacement(
          context,
          CupertinoPageRoute(
              builder: (context) => PersonDetails(
                    billAmount: billAmount,
                    personCount: widget.personCount!,
                    typePooja: widget.typePooja,
                    pjIdOrder: orderIdPooja,
                    packageName: widget.packageName,
                    poojaName: widget.poojaName,
                    poojaVenue: widget.poojaVenue,
                    date: widget.date,
                  )));
      walletAmount();
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  String formatExpireDate(String dateString) {
    // Parse the input string into a DateTime object
    DateTime parsedDate = DateTime.parse(dateString);

    // Format the DateTime object into the desired format
    String formattedDate =
        DateFormat('dd-MMM-yyyy').format(parsedDate); // Example: 2024-12-30

    return formattedDate;
  }

  Future<void> sendCharityStoreRequest() async {
    var url = Uri.parse(AppConstants.baseUrl + AppConstants.charityProductdUrl);

    // Body of the POST request, including the dynamic charity list
    var body = {"lead_id": widget.leadId, "charity": charityList};

    try {
      var response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(body),
      );

      if ([200, 201].contains(response.statusCode)) {
        print('Request successful charity product: ${response.body}');
      } else {
        print('Request failed with status: ${response.statusCode}');
      }
    } catch (e) {
      print('Error occurred: $e');
    }
  }

  Future<void> fetchCoupon(String couponType) async {
    print("Coupon Type is $couponType");

    final response = await http.get(
      Uri.parse(
          AppConstants.baseUrl + AppConstants.fetchPoojaCouponUrl + couponType),
      headers: {
        'Authorization': 'Bearer $userToken',
        'Content-Type': 'application/json',
      },
    );
    print("Api response coupon ${response.body}");
    if (response.statusCode == 200) {
      setState(() {
        couponModelList.clear();
        var data = jsonDecode(response.body);
        List couponList = data['list'];
        couponModelList.addAll(couponList.map((e) => Couponlist.fromJson(e)));
      });
    }
  }

  Future<void> applyCoupon(String code, String serviceType, int maxDis) async {
    final response = await http.post(
      Uri.parse(AppConstants.baseUrl + AppConstants.applyPoojaCouponUrl),
      headers: {
        'Authorization': 'Bearer $userToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({"coupon_code": code, "service_type": serviceType}),
    );
    print("coupon post api: $code $serviceType");
    var data = jsonDecode(response.body);
    if (data["status"]) {
      print("coupon type $couponType ");
      Navigator.pop(context);
      if (couponType == "amount") {
        amountDiscount();
      } else {
        percentDiscount(maxDis);
      }
      setState(() {
        if (walletPay == 0) {
          isCouponApplyed = true;
          double couponMinus = couponTotalAmount == 0
              ? couponType == "amount"
                  ? couponBillRupe
                  : couponBillPerc
              : couponTotalAmount;

          int amountPer =
              (int.parse(widget.billAmount) * couponDiscountAmount / 100)
                  .round();
          print("coupon check amount $couponMinus $amountPer");
          productAmounts[0] = couponType == "amount"
              ? int.parse(widget.billAmount) - couponDiscountAmount.round()
              : maxDiscountCheck
                  ? int.parse(widget.billAmount) - maxDiscount.round()
                  : int.parse(widget.billAmount) - amountPer;
          // productAmounts[0] = finalAmount.round();
          print("check karna he ${maxDiscountCheck ? "true" : "false"}");
          finalAmount = (walletPay - couponMinus).abs();
          listSumAmount = (walletPay - couponMinus).abs();
          walletMinusAmount = max(walletPay - listSumAmount, 0);
          if (maxDiscountCheck == false) {
            finalAmount =
                productAmounts.fold(0, (prev, element) => prev + element);
            print("check karna he amount yrr");
          }
          print(
              "if coupon conditon $couponMinus ${listSumAmount = productAmounts.fold(0, (prev, element) => prev + element)}");
        } else {
          isCouponApplyed = true;
          // double couponMinus = couponTotalAmount == 0 ?
          // couponType == "amount" ? couponBillRupe : couponBillPerc
          //     : couponTotalAmount;
          // listSumAmount = (walletPay - couponMinus).abs();
          double couponMinus = couponTotalAmount == 0
              ? couponType == "amount"
                  ? couponBillRupe
                  : couponBillPerc
              : couponTotalAmount;
          print(
              "coupon check amount $couponDiscountAmount $couponMinus ${maxDiscountCheck ? "$maxDiscount" : couponMinus}");

          finalAmount -= maxDiscountCheck
              ? maxDiscount
              : couponType == "amount"
                  ? couponDiscountAmount
                  : int.parse(widget.billAmount) *
                      couponDiscountAmount.round() ~/
                      100;
          listSumAmount -= maxDiscountCheck
              ? maxDiscount
              : couponType == "amount"
                  ? couponDiscountAmount
                  : int.parse(widget.billAmount) *
                      couponDiscountAmount.round() ~/
                      100;
          walletMinusAmount = max(walletPay - listSumAmount, 0);
          // productAmounts[0] = listSumAmount.round();

          listSumAmount =
              productAmounts.fold(0, (prev, element) => prev + element);
          print("else coupon conditon ");
        }

        if (walletPay == 0) {
          double bill = double.parse(widget.billAmount);
          int roundedBill = bill.round();
          if (productAmounts.isNotEmpty && productAmounts[0] == roundedBill) {
            productAmounts[0] = finalAmount.round();
          }
          print("check if condition");
        } else {
          double bill = double.parse(widget.billAmount);
          int roundedBill = bill.round();
          double minusDis = couponType == "amount"
              ? couponDiscountAmount.toDouble()
              : maxDiscountCheck
                  ? maxDiscount.toDouble()
                  : couponDiscountAmount.toDouble();
          double discountAmount =
              (minusDis / 100) * int.parse(widget.billAmount);
          if (productAmounts.isNotEmpty && productAmounts[0] == roundedBill) {
            couponType == "amount"
                ? productAmounts[0] =
                    int.parse(widget.billAmount) - minusDis.round()
                : maxDiscountCheck
                    ? productAmounts[0] =
                        int.parse(widget.billAmount) - minusDis.round()
                    : productAmounts[0] =
                        int.parse(widget.billAmount) - discountAmount.round();
          }
          listSumAmount = double.parse("${productAmounts[0]}");

          print("check else condition ${discountAmount.round()}");
        }

        // print(couponMinus);
        print("success api status 200 ");

// For general toast
        ToastHelper.showSuccess("Applied Coupon 👍");
      });
    } else {
      String message = data["message"];

// For general toast
      ToastHelper.showError(message);
    }
  }

  void amountDiscount() {
    // couponTotalRupe = totalAmount - couponDiscountAmount;
    setState(() {
      couponBillRupe = 0;
      couponBillRupe = finalAmount - couponDiscountAmount;
      // couponBillRupe =  double.parse(widget.billAmount) - couponDiscountAmount;
    });
    print("total rupe $couponTotalRupe");
    print("bill rupe $couponBillRupe");
  }

  void percentDiscount(int maxDis) {
    double checkAmount =
        double.parse(widget.billAmount) * couponDiscountAmount / 100;
    // couponTotalPer = totalAmount - totalAmount * couponDiscountAmount ~/ 100;
    print("check amount percent $checkAmount > $maxDis");
    if (checkAmount < maxDis) {
      setState(() {
        couponBillPerc = 0;
        // couponBillPerc = finalAmount - finalAmount * couponDiscountAmount ~/ 100;
        couponBillPerc = double.parse(widget.billAmount) -
            double.parse(widget.billAmount) * couponDiscountAmount ~/ 100;
        maxDiscountCheck = false;
      });
    } else {
      setState(() {
        couponBillPerc = 0;
        couponBillPerc = finalAmount - maxDis;
        maxDiscountCheck = true;
        // couponBillPerc = double.parse(widget.billAmount) - double.parse(widget.billAmount) * couponDiscountAmount ~/ 100;
      });
    }
    print(" total $couponTotalPer");
    print(" bill $couponBillPerc");
  }

  // void couponIncrementQuantity(int index , String productId, int quantityProduct) {
  //   setState(() {
  //     if (quantity[index] < 10){
  //       quantity[index]++;
  //       productAmounts.add(widget.product[index].price!);
  //       listSumAmount = 0;
  //       listSumAmount = productAmounts.fold(0, (prev, element) => prev + element);
  //       double plusAmount = couponType == "amount" ? couponBillRupe : couponBillPerc;
  //       couponTotalAmount = plusAmount + listSumAmount;
  //       quantity[index] == 0 ? isFunction = false : isFunction = true;
  //       double couponMinus = couponTotalAmount == 0 ?
  //       couponType == "amount" ? couponBillRupe : couponBillPerc
  //           : couponTotalAmount;
  //       walletMinusAmount = max(walletPay - couponMinus, 0);
  //       finalAmount = (walletPay - couponMinus).abs();
  //       print("$couponMinus");
  //     }
  //     // listSumAmount += int.parse(widget.billAmount);
  //     // Create a new product entry
  //     var newProduct = {
  //       "product_id": productId,
  //       "quantity": quantityProduct
  //     };
  //     // Check if the product already exists in the list
  //     int existingIndex = charityList.indexWhere((product) => product["product_id"] == productId);
  //
  //     if (existingIndex != -1) {
  //       // Replace the existing product with the new one
  //       charityList[existingIndex] = newProduct;
  //     } else {
  //       // Add the new product if it doesn't exist
  //       charityList.add(newProduct);
  //     }
  //   });
  // }
  // void couponDecrementQuantity(int index, String productId, int quantityProduct) {
  //   setState(() {
  //     if (quantity[index] > 0) {
  //       quantity[index]--;
  //       productAmounts.remove(widget.product[index].price);
  //       listSumAmount = 0;
  //       listSumAmount = productAmounts.fold(0, (prev, element) => prev + element);
  //       double plusAmount = couponType == "amount" ? couponBillRupe : couponBillPerc;
  //       couponTotalAmount =  plusAmount + listSumAmount;
  //       quantity[index] == 0 ? isFunction = false : isFunction = true;
  //       double couponMinus = couponTotalAmount == 0 ?
  //       couponType == "amount" ? couponBillRupe : couponBillPerc
  //           : couponTotalAmount;
  //       walletMinusAmount = max(walletPay - couponMinus, 0);
  //       finalAmount = (walletPay - couponMinus).abs();
  //       print(couponMinus);
  //     }
  //     // Create a new product entry
  //     // var newProduct = {
  //     //   "product_id": productId,
  //     //   "quantity": quantityProduct
  //     // };
  //
  //     for (int i = charityList.length - 1; i >= 0; i--) {
  //       if (charityList[i]["product_id"] == productId) {
  //         // Decrement the quantity
  //         charityList[i]["quantity"]--;
  //         items[i]['quantity']--;
  //         // If quantity becomes 0, remove the product
  //         if (charityList[i]["quantity"] <= 0) {
  //           charityList.removeAt(i); // Remove the product with quantity 0
  //           items.removeAt(i);
  //         }
  //         break; // Exit the loop after handling the product
  //       }
  //     }
  //   });
  // }

  void checkAmount(int amount, int index) {
    // int checkAmount =  walletMinusAmount == 0 ? int.parse(widget.billAmount) : int.parse(widget.bookingAmount);
    int checkAmount = int.parse(widget.billAmount);
    if (checkAmount >= amount) {
      setState(() {
        couponType = couponModelList[index].discountType;
        couponDiscountAmount = couponModelList[index].discount;
        couponController.text = couponModelList[index].code;
        couponCode = couponModelList[index].code;
        Clipboard.setData(ClipboardData(text: couponModelList[index].code));
        serviceCouponType = couponModelList[index].couponType;
        maxDiscount = couponModelList[index].maxDiscount;
      });
      // print("coupon discount $couponTotal -- $couponPayAmount -- $finalTotal");
      // print("coupon discount $couponDiscountAmount -- $couponPayAmount");
      print("coupon code ${couponController.text}");
      print("coupon code $couponCode}");
    } else {
// For general toast
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
                                // resetQuantities();
                                couponController.text.isEmpty
                                    ? Fluttertoast.showToast(
                                        msg: "Enter Your Code",
                                        backgroundColor: Colors.red,
                                        textColor: Colors.white)
                                    : applyCoupon(couponController.text,
                                        serviceCouponType, maxDiscount);
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
                                          couponModelList[index].discountType ==
                                                  "amount"
                                              ? "On All Shop"
                                              : "UP to ₹${couponModelList[index].maxDiscount}",
                                          style: const TextStyle(
                                              color: Colors.blue, fontSize: 16),
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
                                        Text(
                                          "Valid till ${formatExpireDate("${couponModelList[index].expireDate}")}",
                                          style: const TextStyle(
                                              color: Colors.black,
                                              fontSize: 16),
                                        ),
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
    var res = await HttpService().getApi(AppConstants.poojaWalletUrl + userId);
    print(res);
    if (res["success"]) {
      setState(() {
        walletPay = double.parse(res["wallet_balance"].toString());
        walletMinusAmount = max(walletPay - int.parse(widget.billAmount), 0);
        finalAmount = (walletPay - int.parse(widget.billAmount)).abs();
        listSumAmount =
            productAmounts.fold(0, (prev, element) => prev + element);
        if (walletMinusAmount == 0) {
          finalAmount = listSumAmount - walletPay;
        }
      });
    }
  }

  @override
  void initState() {
    super.initState();
    print(">>> token id ${widget.typePooja} date - ${widget.date}");
    userId = Provider.of<ProfileController>(Get.context!, listen: false).userID;
    userNAME =
        Provider.of<ProfileController>(Get.context!, listen: false).userNAME;
    userEMAIL =
        Provider.of<ProfileController>(Get.context!, listen: false).userEMAIL;
    userPHONE =
        Provider.of<ProfileController>(Get.context!, listen: false).userPHONE;
    userToken =
        Provider.of<AuthController>(Get.context!, listen: false).getUserToken();
    productAmounts.add(int.parse(widget.billAmount));
    listSumAmount = double.parse(widget.billAmount);
    walletAmount();
    // final productItem = widget.product[0];
    // incrementQuantity(
    //     0,
    //     productItem.productId,
    //     quantity[0] + 1);
    // addItem(
    //     productItem.enName,
    //     productItem.price,
    //     quantity[0]);
    fetchCoupon(widget.couponType);
  }

  @override
  Widget build(BuildContext context) {
    var screenHeight = MediaQuery.of(context).size.height;
    var screenWidth = MediaQuery.of(context).size.width;
    DateTime bookingDate = DateTime.parse(widget.date);
    return circularIndicator
        ? const MahakalPaymentProcessing()
        : Scaffold(
            appBar: AppBar(
              title: const Text(
                "Pooja Booking",
                style: TextStyle(color: Colors.orange),
              ),
              centerTitle: true,
            ),
            floatingActionButtonLocation:
                FloatingActionButtonLocation.centerDocked,
            floatingActionButton: walletMinusAmount == 0
                ? walletPay == double.parse(widget.billAmount)
                    ? GestureDetector(
                        onTap: () {
                          // _showBottomSheets();
                          if (isLoading) {
                            print("null value");
                          } else {
                            charityList.isEmpty
                                ? null
                                : sendCharityStoreRequest();
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
                                      oderPlacePooja(
                                          "pay_wallet", isCouponApplyed);
                                      setState(() {
                                        isLoading = true;
                                      });
                                      // Add your payment logic here
                                    },
                                  ),
                                ],
                              ),
                            );
                          }
                          // print(totalAmount);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 2, horizontal: 10),
                          margin: const EdgeInsets.all(10),
                          height: 60,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            gradient: const LinearGradient(
                              colors: [Colors.deepOrange, Colors.amber],
                              begin: Alignment.bottomLeft,
                              end: Alignment.topRight,
                            ),
                          ),
                          child: isLoading
                              ? const Center(
                                  child: CircularProgressIndicator(
                                  color: Colors.white,
                                ))
                              : Row(
                                  children: [
                                    Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          "Via Wallet",
                                          style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                              fontFamily: 'Roboto',
                                              color: Colors.white),
                                        ),
                                        Text(
                                          widget.packageName,
                                          style: const TextStyle(
                                              fontSize: 18,
                                              fontFamily: 'Roboto',
                                              color: Colors.white),
                                        ),
                                      ],
                                    ),
                                    const Spacer(),
                                    const Text(
                                      "Pay",
                                      style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          fontFamily: 'Roboto',
                                          color: Colors.white),
                                    ),
                                    const SizedBox(
                                      width: 5,
                                    ),
                                    const Icon(
                                      Icons.arrow_circle_right_outlined,
                                      size: 30,
                                      color: Colors.white,
                                    )
                                  ],
                                ),
                        ),
                      ) // wallet
                    : GestureDetector(
                        onTap: () {
                          charityList.isEmpty
                              ? null
                              : sendCharityStoreRequest();
                          razorpayService.openCheckout(
                            amount: finalAmount, // ₹100
                            razorpayKey: AppConstants.razorpayLive,
                            onSuccess: (response) {
                              oderPlacePooja(
                                  "${response.paymentId}", isCouponApplyed);
                            },
                            onFailure: (response) {
                              setState(() {
                                circularIndicator = false;
                              });
                            },
                            onExternalWallet: (response) {
                              print("Wallet: ${response.walletName}");
                            },
                            description: 'Online Pooja Booking',
                          );
                          setState(() {
                            circularIndicator = true;
                            isLoading = false;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 2, horizontal: 10),
                          margin: const EdgeInsets.all(10),
                          height: 60,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            gradient: const LinearGradient(
                              colors: [Colors.deepOrange, Colors.amber],
                              begin: Alignment.bottomLeft,
                              end: Alignment.topRight,
                            ),
                          ),
                          child: isLoading
                              ? const Center(
                                  child: CircularProgressIndicator(
                                  color: Colors.white,
                                ))
                              : Row(
                                  children: [
                                    Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        isCouponApplyed
                                            ? Text(
                                                "₹$finalAmount",
                                                // couponTotalAmount == 0 ?
                                                // couponType == "amount" ? "₹$couponBillRupe.0" : "₹$couponBillPerc.0"
                                                //     : "₹$couponTotalAmount.0",
                                                style: const TextStyle(
                                                    fontSize: 20,
                                                    fontWeight: FontWeight.bold,
                                                    fontFamily: 'Roboto',
                                                    color: Colors.white),
                                              )
                                            : Text(
                                                "₹$finalAmount",
                                                style: const TextStyle(
                                                    fontSize: 20,
                                                    fontWeight: FontWeight.bold,
                                                    fontFamily: 'Roboto',
                                                    color: Colors.white),
                                              ),
                                        Text(
                                          widget.packageName,
                                          style: const TextStyle(
                                              fontSize: 18,
                                              fontFamily: 'Roboto',
                                              color: Colors.white),
                                        ),
                                      ],
                                    ),
                                    const Spacer(),
                                    const Text(
                                      "Pay",
                                      style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          fontFamily: 'Roboto',
                                          color: Colors.white),
                                    ),
                                    const SizedBox(
                                      width: 5,
                                    ),
                                    const Icon(
                                      Icons.arrow_circle_right_outlined,
                                      size: 30,
                                      color: Colors.white,
                                    )
                                  ],
                                ),
                        ),
                      ) // razor pay
                : GestureDetector(
                    onTap: () {
                      // _showBottomSheets();
                      if (isLoading) {
                        print("null value");
                      } else {
                        charityList.isEmpty ? null : sendCharityStoreRequest();
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
                                  oderPlacePooja("pay_wallet", isCouponApplyed);
                                  setState(() {
                                    isLoading = true;
                                  });
                                  // Add your payment logic here
                                },
                              ),
                            ],
                          ),
                        );
                      }
                      // print(totalAmount);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 2, horizontal: 10),
                      margin: const EdgeInsets.all(10),
                      height: 60,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        gradient: const LinearGradient(
                          colors: [Colors.deepOrange, Colors.amber],
                          begin: Alignment.bottomLeft,
                          end: Alignment.topRight,
                        ),
                      ),
                      child: isLoading
                          ? const Center(
                              child: CircularProgressIndicator(
                              color: Colors.white,
                            ))
                          : Row(
                              children: [
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      "Via Wallet",
                                      style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          fontFamily: 'Roboto',
                                          color: Colors.white),
                                    ),
                                    Text(
                                      widget.packageName,
                                      style: const TextStyle(
                                          fontSize: 18,
                                          fontFamily: 'Roboto',
                                          color: Colors.white),
                                    ),
                                  ],
                                ),
                                const Spacer(),
                                const Text(
                                  "Pay",
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'Roboto',
                                      color: Colors.white),
                                ),
                                const SizedBox(
                                  width: 5,
                                ),
                                const Icon(
                                  Icons.arrow_circle_right_outlined,
                                  size: 30,
                                  color: Colors.white,
                                )
                              ],
                            ),
                    ),
                  ), // wallet
            body: SafeArea(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    children: [
                      Container(
                        margin: const EdgeInsets.all(5),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                                color: Colors.grey.shade300, width: 1.5),
                            color: Colors.white),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.poojaName,
                              style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black),
                            ),
                            Text(
                              widget.packageName,
                              style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.blueGrey),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            Row(
                              children: [
                                Text(
                                  "₹${widget.billAmount}",
                                  style: const TextStyle(
                                      fontSize: 20,
                                      fontFamily: 'Roboto',
                                      fontWeight: FontWeight.bold,
                                      color: Colors.orange),
                                ),
                                const Spacer(),
                                GestureDetector(
                                  child: Icon(
                                    _showText
                                        ? Icons.keyboard_arrow_up
                                        : Icons.keyboard_arrow_down,
                                    size: 30,
                                    color: Colors.orange,
                                  ),
                                  onTap: () {
                                    setState(() {
                                      _showText = !_showText;
                                    });
                                  },
                                )
                              ],
                            ),
                            _showText
                                // _showMore
                                ? Column(
                                    children: [
                                      const Divider(
                                        color: Colors.grey,
                                      ),
                                      Row(
                                        children: [
                                          const Icon(
                                            Icons.calendar_month,
                                            color: Colors.orange,
                                            size: 20,
                                          ),
                                          const SizedBox(
                                            width: 5,
                                          ),
                                          SizedBox(
                                              width: screenWidth * 0.7,
                                              child: Text(
                                                DateFormat('dd-MMM-yyyy,')
                                                    .format(bookingDate),
                                                style: const TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w400,
                                                    fontFamily: 'Roboto',
                                                    overflow:
                                                        TextOverflow.ellipsis),
                                                maxLines: 1,
                                              )),
                                        ],
                                      ),
                                      SizedBox(height: screenWidth * 0.01),
                                      Row(
                                        children: [
                                          const Icon(
                                            Icons.location_pin,
                                            color: Colors.orange,
                                            size: 20,
                                          ),
                                          const SizedBox(
                                            width: 5,
                                          ),
                                          SizedBox(
                                              width: screenWidth * 0.7,
                                              child: Text(
                                                widget.poojaVenue,
                                                style: const TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w400,
                                                    fontFamily: 'Roboto',
                                                    overflow:
                                                        TextOverflow.ellipsis),
                                                maxLines: 2,
                                              )),
                                        ],
                                      ),
                                    ],
                                  )
                                : Container(),
                          ],
                        ),
                      ),
                      Row(
                        children: [
                          Container(
                            margin: const EdgeInsets.symmetric(vertical: 10),
                            height: 20,
                            width: 3,
                            decoration:
                                const BoxDecoration(color: Colors.orange),
                          ),
                          SizedBox(width: screenWidth * 0.02),
                          const Expanded(
                            child: Text(
                              "Add more offering items",
                              style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 20),
                            ),
                          ),
                        ],
                      ),
                      ListView.builder(
                        shrinkWrap: true,
                        itemCount: widget.product.length,
                        physics: const BouncingScrollPhysics(),
                        itemBuilder: (context, index) {
                          final productItem = widget.product[index];
                          return Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 10),
                            margin: const EdgeInsets.symmetric(vertical: 4),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                  color: Colors.grey.shade300, width: 1.5),
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
                            child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Expanded(
                                    flex: 0,
                                    child: Container(
                                        padding: const EdgeInsets.only(top: 5),
                                        height: 100,
                                        width: 110,
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            color: Colors.grey.shade300,
                                            border: Border.all(
                                                color: Colors.grey.shade300),
                                            image: DecorationImage(
                                                image: NetworkImage(
                                                    productItem.thumbnail),
                                                fit: BoxFit.cover))),
                                  ),
                                  const SizedBox(
                                    width: 6,
                                  ),
                                  Expanded(
                                    flex: 1,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(left: 8.0),
                                          child: Text(
                                            productItem.enName,
                                            style: const TextStyle(
                                                fontSize: 16,
                                                fontFamily: 'Roboto',
                                                color: Colors.black,
                                                overflow:
                                                    TextOverflow.ellipsis),
                                            maxLines: 2,
                                          ),
                                        ),

                                        //Add button
                                        const SizedBox(
                                          height: 15,
                                        ),
                                        Row(
                                          children: [
                                            // Spacer(),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 8.0),
                                              child: Text(
                                                "₹${productItem.price}",
                                                style: const TextStyle(
                                                    fontSize: 20,
                                                    fontWeight: FontWeight.bold,
                                                    fontFamily: 'Roboto',
                                                    color: Colors.blueAccent),
                                              ),
                                            ),
                                            const Spacer(),
                                            if (quantity[index] == 0)
                                              InkWell(
                                                onTap: () {
                                                  setState(() {
                                                    // isCouponApplyed
                                                    //     ? couponIncrementQuantity(index , "${productItem.productId}", quantity[index] + 1)
                                                    //     : incrementQuantity(index , "${productItem.productId}", quantity[index] + 1);
                                                    incrementQuantity(
                                                        index,
                                                        productItem.productId,
                                                        quantity[index] + 1);
                                                    addItem(
                                                        productItem.enName,
                                                        productItem.price,
                                                        quantity[index]);
                                                  });
                                                },
                                                child: Container(
                                                    height: 35,
                                                    width: 140,
                                                    decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(4),
                                                        border: Border.all(
                                                            color: Colors
                                                                .grey.shade300),
                                                        color: Colors.orange),
                                                    child: Row(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .center,
                                                        children: [
                                                          const Spacer(),
                                                          const Center(
                                                            child: Text(
                                                              "ADD",
                                                              style: TextStyle(
                                                                  fontSize: 18,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w700,
                                                                  fontFamily:
                                                                      'Roboto',
                                                                  color: Colors
                                                                      .white),
                                                            ),
                                                          ),
                                                          const Spacer(),
                                                          Container(
                                                            height: 35,
                                                            width: screenWidth *
                                                                0.1,
                                                            decoration: const BoxDecoration(
                                                                color: Colors
                                                                    .white,
                                                                borderRadius: BorderRadius.only(
                                                                    topRight: Radius
                                                                        .circular(
                                                                            4),
                                                                    bottomRight:
                                                                        Radius.circular(
                                                                            3))),
                                                            child: const Icon(
                                                              Icons.add,
                                                              color:
                                                                  Colors.black,
                                                              size: 25,
                                                            ),
                                                          )
                                                        ])),
                                              )
                                            else
                                              Row(children: [
                                                Container(
                                                  height: 35,
                                                  width: 40,
                                                  decoration: BoxDecoration(
                                                      borderRadius:
                                                          const BorderRadius
                                                              .only(
                                                              topLeft: Radius
                                                                  .circular(4),
                                                              bottomLeft: Radius
                                                                  .circular(4)),
                                                      border: Border.all(
                                                          color:
                                                              Colors.orange)),
                                                  child: GestureDetector(
                                                      onTap: () {
                                                        setState(() {
                                                          listSumAmount = quantity[
                                                                  index] *
                                                              double.parse(
                                                                  "${productItem.price}");
                                                          // isCouponApplyed
                                                          //     ? couponDecrementQuantity(index, productItem.productId!, quantity[index])
                                                          //     : decrementQuantity(index, productItem.productId!, quantity[index]);
                                                          decrementQuantity(
                                                              index,
                                                              productItem
                                                                  .productId,
                                                              quantity[index]);
                                                        });
                                                      },
                                                      child: const Icon(
                                                        Icons.remove,
                                                        size: 20,
                                                        color: Colors.black,
                                                      )),
                                                ),
                                                Container(
                                                  height: 35,
                                                  width: 60,
                                                  decoration: BoxDecoration(
                                                      border: Border.all(
                                                          color: Colors.orange),
                                                      color: Colors.orange),
                                                  child: Center(
                                                      child: Text(
                                                    "${quantity[index]}",
                                                    style: const TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 20),
                                                  )),
                                                ),
                                                Container(
                                                  height: 35,
                                                  width: 40,
                                                  decoration: BoxDecoration(
                                                      borderRadius:
                                                          const BorderRadius
                                                              .only(
                                                              topRight: Radius
                                                                  .circular(4),
                                                              bottomRight:
                                                                  Radius
                                                                      .circular(
                                                                          4)),
                                                      border: Border.all(
                                                          color:
                                                              Colors.orange)),
                                                  child: GestureDetector(
                                                      onTap: () {
                                                        setState(() {
                                                          listSumAmount = quantity[
                                                                  index] *
                                                              double.parse(
                                                                  "${productItem.price}");
                                                          // isCouponApplyed
                                                          // ? couponIncrementQuantity(index , "${productItem.productId}", quantity[index] + 1)
                                                          // : incrementQuantity(index , "${productItem.productId}", quantity[index] + 1);
                                                          incrementQuantity(
                                                              index,
                                                              productItem
                                                                  .productId,
                                                              quantity[index] +
                                                                  1);
                                                          addItem(
                                                              productItem
                                                                  .enName,
                                                              productItem.price,
                                                              quantity[index]);
                                                        });
                                                      },
                                                      child: const Icon(
                                                        Icons.add,
                                                        size: 20,
                                                      )),
                                                ),
                                              ]),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  InkWell(
                                      onTap: () {
                                        showDialog(
                                          useSafeArea: false,
                                          barrierDismissible: true,
                                          traversalEdgeBehavior:
                                              TraversalEdgeBehavior
                                                  .leaveFlutterView,
                                          context: context,
                                          builder: (BuildContext context) {
                                            return AlertDialog(
                                              alignment: Alignment.bottomCenter,
                                              backgroundColor:
                                                  Colors.transparent,
                                              elevation: 0,
                                              shadowColor: Colors.transparent,
                                              shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          15)),
                                              contentPadding: EdgeInsets.zero,
                                              clipBehavior: Clip.hardEdge,
                                              insetPadding:
                                                  const EdgeInsets.only(
                                                      bottom: 20,
                                                      left: 15,
                                                      right: 15),
                                              content: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                mainAxisAlignment:
                                                    MainAxisAlignment.end,
                                                children: [
                                                  Material(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10),
                                                    color: Colors.white,
                                                    child: Padding(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          vertical: 10,
                                                          horizontal: 15),
                                                      child: Text(
                                                        HtmlParser.parseHTML(
                                                                productItem
                                                                    .hiDetails)
                                                            .text,
                                                        style: const TextStyle(
                                                            fontSize: 20),
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(
                                                      height:
                                                          6), // Replacing VerticalSpace with SizedBox
                                                  InkWell(
                                                    onTap: () {
                                                      Navigator.pop(context);
                                                    },
                                                    child: Container(
                                                      height: 40,
                                                      width: double.infinity,
                                                      decoration: BoxDecoration(
                                                          color: Colors.grey,
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      8.0)),
                                                      child: const Center(
                                                          child: Text(
                                                        "Got it",
                                                        style: TextStyle(
                                                            fontSize: 18,
                                                            color:
                                                                Colors.white),
                                                      )),
                                                    ),
                                                  )
                                                  // punkGuideButton(context),
                                                ],
                                              ),
                                            );
                                          },
                                        );
                                      },
                                      child: const Icon(
                                        Icons.report_gmailerrorred,
                                        color: Colors.deepOrange,
                                        size: 22,
                                      )),
                                ]),
                          );
                        },
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      isCouponApplyed
                          ? Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 12),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Colors.green.shade800,
                                    Colors.green.shade400
                                  ],
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color:
                                        Colors.green.shade200.withOpacity(0.5),
                                    blurRadius: 8,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  // Checkmark icon and text
                                  Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.2),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.check_rounded,
                                      size: 20,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(width: 12),

                                  // Coupon text
                                  const Expanded(
                                    child: Text(
                                      "Coupon Applied Successfully",
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                        letterSpacing: 0.3,
                                      ),
                                    ),
                                  ),

                                  // Remove button
                                  InkWell(
                                    onTap: () {
                                      setState(() {
                                        if (walletPay == 0) {
                                          isCouponApplyed = false;
                                          listSumAmount =
                                              double.parse(widget.billAmount);
                                          productAmounts[0] =
                                              listSumAmount.round();
                                          listSumAmount = productAmounts.fold(
                                              0,
                                              (prev, element) =>
                                                  prev + element);
                                          finalAmount = listSumAmount;
                                          if (walletPay == 0) {
                                            null;
                                            print("if null condition");
                                          } else {
                                            walletMinusAmount = max(
                                                walletPay - listSumAmount, 0);
                                            print("else null condition");
                                          }
                                          print("if not correct");
                                        } else {
                                          isCouponApplyed = false;
                                          finalAmount = listSumAmount;
                                          listSumAmount =
                                              double.parse(widget.billAmount);
                                          productAmounts[0] =
                                              listSumAmount.round();
                                          listSumAmount = productAmounts.fold(
                                              0,
                                              (prev, element) =>
                                                  prev + element);
                                          walletMinusAmount = max(
                                              walletPay -
                                                  int.parse(widget.billAmount),
                                              0);
                                          finalAmount = (walletPay -
                                                  int.parse(widget.billAmount))
                                              .abs();
                                          listSumAmount = productAmounts.fold(
                                              0,
                                              (prev, element) =>
                                                  prev + element);
                                          if (walletMinusAmount == 0) {
                                            finalAmount =
                                                listSumAmount - walletPay;
                                          }
                                          print("else condition");
                                        }
                                      });
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.all(6),
                                      decoration: BoxDecoration(
                                        color: Colors.white24,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            "Remove",
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                              color: Colors.white,
                                            ),
                                          ),
                                          SizedBox(width: 4),
                                          Icon(
                                            Icons.close_rounded,
                                            size: 18,
                                            color: Colors.white,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : Container(
                              height: 56,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                color: Colors.transparent,
                                border: Border.all(
                                  color: Colors.orange.shade300,
                                  width: 1.5,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color:
                                        Colors.orange.shade100.withOpacity(0.4),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  // Coupon icon
                                  Icon(
                                    Icons.local_offer_outlined,
                                    color: Colors.orange.shade600,
                                    size: 24,
                                  ),
                                  const SizedBox(width: 12),

                                  // Text
                                  const Expanded(
                                    child: Text(
                                      "Apply Coupon Code",
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.orange,
                                        letterSpacing: 0.3,
                                      ),
                                    ),
                                  ),

                                  // Add button
                                  InkWell(
                                    onTap: () {
                                      showCouponSheet();
                                    },
                                    borderRadius: BorderRadius.circular(20),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: Colors.orange.shade50,
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            "Apply",
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.orange.shade800,
                                            ),
                                          ),
                                          const SizedBox(width: 4),
                                          Icon(
                                            Icons.arrow_forward_rounded,
                                            size: 18,
                                            color: Colors.orange.shade800,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                      const SizedBox(
                        height: 10,
                      ),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: Colors.grey.shade300, width: 1.5),
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
                                  "Bill Details",
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
                              title: "Pooja Total",
                              value: "₹${widget.billAmount}.0",
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

                            const SizedBox(height: 12),

                            // Items List
                            ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: items.length,
                              separatorBuilder: (context, index) =>
                                  const SizedBox(height: 8),
                              itemBuilder: (context, index) {
                                final totalPay = items[index]['quantity'] *
                                    items[index]['amount'];
                                return _buildBillRow(
                                  title: items[index]['name'],
                                  value:
                                      "₹${items[index]['amount']} x ${items[index]['quantity']} = ₹$totalPay.0",
                                  titleStyle: const TextStyle(
                                    fontSize: 15,
                                    color: Colors.black87,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  valueStyle: TextStyle(
                                    fontSize: 15,
                                    color: Colors.blue.shade700,
                                  ),
                                  maxLines: 1,
                                );
                              },
                            ),

                            const Divider(
                                height: 24, thickness: 1, color: Colors.grey),

                            // Wallet Section
                            _buildBillRow(
                              title: "Wallet Balance",
                              value: "₹$walletPay",
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
                              title: "Wallet Remaining",
                              value: "₹$walletMinusAmount",
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
                              title: "Amount Paid (via Wallet)",
                              value: walletMinusAmount == 0
                                  ? "- ₹$walletPay"
                                  : "- ₹$listSumAmount",
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

                            // Discount Section
                            isCouponApplyed
                                ? _buildBillRow(
                                    title: "Special Discount",
                                    value: couponType == "amount"
                                        ? "- ₹$couponDiscountAmount.0"
                                        : maxDiscountCheck
                                            ? "- ₹$maxDiscount.0"
                                            : "- $couponDiscountAmount%",
                                    titleStyle: const TextStyle(
                                      fontSize: 16,
                                      color: Colors.black87,
                                    ),
                                    valueStyle: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.red.shade700,
                                    ),
                                  )
                                : _buildBillRow(
                                    title: "Special Discount",
                                    value: "- ₹0.0",
                                    titleStyle: const TextStyle(
                                      fontSize: 16,
                                      color: Colors.black87,
                                    ),
                                    valueStyle: const TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey,
                                    ),
                                  ),

                            const Divider(
                                height: 24, thickness: 1, color: Colors.grey),

                            // Total Amount
                            _buildBillRow(
                              title: "Total Amount",
                              value: walletMinusAmount == 0
                                  ? "₹$finalAmount"
                                  : "₹0.0",
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

                            const SizedBox(height: 20),

                            // Information Box
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                color: Colors.orange.shade50,
                                border:
                                    Border.all(color: Colors.orange.shade100),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.info_outline,
                                      color: Colors.orange.shade700, size: 20),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      "Name, Gotra & Address will be asked after Payment",
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.orange.shade700,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 80,
                      ),
                    ],
                  ),
                ),
              ),
            ));
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
