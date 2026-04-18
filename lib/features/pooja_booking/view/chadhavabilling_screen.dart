import 'dart:convert';
import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:mahakal/data/datasource/remote/http/httpClient.dart';
import 'package:mahakal/utill/app_constants.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import '../../../main.dart';
import '../../../utill/razorpay_screen.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../explore/payment_process_screen.dart';
import '../../profile/controllers/profile_contrroller.dart';
import '../model/productsmodel.dart';
import 'chadhavapersondetails.dart';

class ChadhavaBilldetails extends StatefulWidget {
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
  ChadhavaBilldetails({
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
  });

  @override
  State<ChadhavaBilldetails> createState() => _ChadhavabilldetailsState();
}

class _ChadhavabilldetailsState extends State<ChadhavaBilldetails> {
  // final List<bool> _isAdded = List.generate(5, (index) => true);
  List<int> quantity = [];
  // List<int> quantity = List.generate(widget.product.length, (index) => 0);
  List<int> productAmounts = [];
  List<Map<String, dynamic>> charityList = [];
  List<Map<String, dynamic>> items = [];
  final TextEditingController couponController = TextEditingController();

  bool isLoading = false;
  bool _showText = false;
  bool isPayMethod = false;
  bool circularIndicator = false;
  bool isFunction = false;
  bool isCouponApplyed = false;
  int listSumAmount = 0;
  double totalAmount = 0.0;
  double finalAmount = 0.0;
  double walletMinusAmount = 0.0;
  double walletPay = 0.0;
  String couponType = "";
  String orderIdPooja = "";
  String serviceCouponType = "";
  var checkMess = "";
  final razorpayService = RazorpayPaymentService();

  void incrementQuantity(int index, String productId, int quantityProduct) {
    setState(() {
      if (quantity[index] < 10) {
        quantity[index]++;
        productAmounts.add(widget.product[index].price);
        listSumAmount = 0;
        listSumAmount =
            productAmounts.fold(0, (prev, element) => prev + element);
        totalAmount = 0;
        totalAmount = double.parse("$listSumAmount");
        walletMinusAmount = max(walletPay - totalAmount, 0);
        finalAmount = (walletPay - totalAmount).abs();
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
        listSumAmount =
            productAmounts.fold(0, (prev, element) => prev + element);
        totalAmount = 0;
        totalAmount = double.parse("$listSumAmount");
        walletMinusAmount = max(walletPay - totalAmount, 0);
        finalAmount = (walletPay - totalAmount).abs();
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
    print("$charityList \n $items");
  }

  // void oderPlacePooja(String payId) async{
  //   String payAmount =  listSumAmount == 0
  //       ? widget.billAmount
  //       : "$totalAmount";
  //   DateTime parsedDate = DateTime.parse(widget.date); // Parse the string to DateTime
  //   String formattedDate = DateFormat("yyyy-MM-dd").format(parsedDate);
  //   var res = await HttpService().postApi(
  //       AppConstants.poojaOrderPlaceUrl,
  //       {
  //         "customer_id": userId,
  //         "service_id": "${widget.serviceId}",
  //         "type": widget.typePooja,
  //         "leads_id": "${widget.leadId}",
  //         "package_id": "${widget.packageId}",
  //         "package_price": widget.billAmount,
  //         "booking_date": formattedDate,
  //         "coupon_amount": "",
  //         "coupon_code": "",
  //         "payment_id": payId,
  //         "payment_amount": payAmount,
  //         "wallet_balance": "12300",
  //         "wallet_translation_id" : "hyjhjhjjhyjj7666h",
  //         "balance": "78989",
  //         "debit": "12300"
  //       }
  //   );
  //   print("Api response data pooja $res");
  //   if(res['status'] == 200){
  //
  //   }
  //   setState(() {
  //     orderIdPooja = res['order_id'];
  //   });
  //   Navigator.push(
  //       context,
  //       CupertinoPageRoute(
  //           builder: (context) =>
  //               PersonDetails(
  //                 billAmount:  listSumAmount == 0
  //                     ? "₹${widget.billAmount}.0"
  //                     : "₹$totalAmount.0",
  //                 personCount: widget.personCount!, typePooja: widget.typePooja, pjIdOrder: orderIdPooja, packageName: widget.packageName,))
  //   );
  //
  // }

  void oderPlaceChadhava(String payId) async {
    isLoading = true;
    DateTime parsedDate =
        DateTime.parse(widget.date); // Parse the string to DateTime
    String formattedDate = DateFormat("yyyy-MM-dd").format(parsedDate);
    int transactionAmount =
        (finalAmount - double.parse("$totalAmount")).abs().toInt();
    String walletBalance =
        walletMinusAmount == 0 ? "$transactionAmount" : "$totalAmount";
    print("transection_amount: ${walletMinusAmount == 0 ? finalAmount : 0}");
    print("wallet_balance: $walletMinusAmount");
    print("balanc: $walletMinusAmount");
    print("debit: $walletBalance");
    var data = {
      "customer_id": userId,
      "service_id": "${widget.serviceId}",
      "type": widget.typePooja,
      "leads_id": "${widget.leadId}",
      "booking_date": formattedDate,
      "payment_id": payId,
      "payment_amount": "$totalAmount",
      "wallet_balance": "$walletMinusAmount",
      "balance": "$walletMinusAmount",
      "debit": walletBalance
    };
    // "transection_amount": walletMinusAmount == 0 ? "$finalAmount" : "0",
    print("data $data");
    var res =
        await HttpService().postApi(AppConstants.chadhavaOrderPlaceUrl, data);
    print("Api response data chadhava $res");
    print("chadhav date $formattedDate");
    setState(() {
      orderIdPooja = res['order_id'].toString();
    });
    Navigator.pop(context);
    Navigator.pushReplacement(
        context,
        CupertinoPageRoute(
            builder: (context) => ChadhavaPersonDetails(
                  billAmount: listSumAmount == 0
                      ? "₹${widget.billAmount}.0"
                      : "₹$totalAmount",
                  personCount: widget.personCount!,
                  pjIdOrder: orderIdPooja,
                )));
    walletAmount();
    isLoading = false;
  }

// Function to add a product to the charity list
//   void addProductToCharity(int productId, int quantity) {
//     // Create a new product entry
//     var newProduct = {
//       "product_id": productId,
//       "quantity": quantity
//     };
//
//     // Add the new product to the list
//     charityList.add(newProduct);
//   }

  String formatExpireDate(String dateString) {
    // Parse the input string into a DateTime object
    DateTime parsedDate = DateTime.parse(dateString);

    // Format the DateTime object into the desired format
    String formattedDate =
        DateFormat('dd-MM-yyyy').format(parsedDate); // Example: 2024-12-30

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

  void walletAmount() async {
    var res =
        await HttpService().getApi("/api/v1/pooja/wallet-balance/$userId");
    print(res);
    if (res["success"]) {
      setState(() {
        walletPay = double.parse(res["wallet_balance"].toString());
        walletMinusAmount = max(walletPay - widget.product[0].price, 0);
      });
    }
  }

  String userId = "";
  String userNAME = "";
  String userEMAIL = "";
  String userPHONE = "";
  String userToken = "";

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
    userToken =
        Provider.of<AuthController>(Get.context!, listen: false).getUserToken();
    quantity = List.generate(widget.product.length, (index) => 0);
    walletAmount();
    final productItem = widget.product[0];
    incrementQuantity(0, productItem.productId, quantity[0] + 1);
    addItem(productItem.enName, productItem.price, quantity[0]);
    print(
        ">>> token id : $userId ${widget.serviceId} ${widget.typePooja} ${widget.leadId} ${charityList.length}");
  }

  @override
  Widget build(BuildContext context) {
    var screenHeight = MediaQuery.of(context).size.height;
    var screenWidth = MediaQuery.of(context).size.width;
    return circularIndicator
        ? const MahakalPaymentProcessing()
        : Scaffold(
            appBar: AppBar(
              title: InkWell(
                onTap: () {
                  oderPlaceChadhava("wallet");
                },
                child: const Text(
                  "Chadhava",
                  style: TextStyle(color: Colors.orange),
                ),
              ),
              centerTitle: true,
            ),
            floatingActionButtonLocation:
                FloatingActionButtonLocation.centerDocked,
            floatingActionButton: totalAmount == 0 && widget.billAmount == "0"
                ? Container(
                    padding:
                        const EdgeInsets.symmetric(vertical: 2, horizontal: 16),
                    margin: const EdgeInsets.all(10),
                    height: 70, // Slightly taller for better proportions
                    decoration: BoxDecoration(
                      borderRadius:
                          BorderRadius.circular(12), // More rounded corners
                      gradient: LinearGradient(
                        // Subtle gradient for depth
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.grey.shade500,
                          Colors.grey.shade400,
                        ],
                      ),
                      boxShadow: [
                        // Soft shadow for elevation
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Add Item",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight:
                                    FontWeight.w600, // Slightly less bold
                                fontFamily: 'Roboto',
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              widget.packageName,
                              style: const TextStyle(
                                fontSize: 16, // Slightly smaller
                                fontFamily: 'Roboto',
                                color: Colors
                                    .white70, // Lighter for secondary text
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        Opacity(
                          // Wrapping in Opacity for disabled state
                          opacity: 0.6, // Dimmed appearance for disabled
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text(
                                "Pay",
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: 'Roboto',
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(width: 8), // More spacing
                              Icon(
                                Icons.arrow_circle_right_outlined,
                                size: 28, // Slightly smaller icon
                                color: Colors.white
                                    .withOpacity(0.9), // Slightly transparent
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  )
                : walletMinusAmount == 0
                    ? walletPay == totalAmount
                        ? GestureDetector(
                            onTap: () {
                              // _showBottomSheets();
                              sendCharityStoreRequest();
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
                                            : oderPlaceChadhava("pay_wallet");
                                        setState(() {
                                          isLoading = true;
                                        });
                                        // Add your payment logic here
                                      },
                                    ),
                                  ],
                                ),
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 8, horizontal: 16),
                              margin: const EdgeInsets.all(12),
                              height:
                                  70, // Slightly taller for better proportions
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(
                                    12), // More rounded corners
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFFFF6D00), // More vibrant orange
                                    Color(0xFFFFAB00), // Brighter amber
                                  ],
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                  stops: [
                                    0.2,
                                    0.8
                                  ], // Better gradient distribution
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.deepOrange.withOpacity(0.4),
                                    blurRadius: 6,
                                    spreadRadius: 1,
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
                                        // Wallet Info Column
                                        Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const Text(
                                              "Via Wallet",
                                              style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight
                                                    .w600, // Slightly less bold
                                                fontFamily: 'Roboto',
                                                color: Colors.white,
                                                letterSpacing: 0.3,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              widget.packageName,
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontFamily: 'Roboto',
                                                color: Colors.white38,
                                              ),
                                            ),
                                          ],
                                        ),

                                        const Spacer(),

                                        // Pay Button Section
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 12, vertical: 6),
                                          decoration: BoxDecoration(
                                            color:
                                                Colors.white.withOpacity(0.15),
                                            borderRadius:
                                                BorderRadius.circular(20),
                                            border: Border.all(
                                              color:
                                                  Colors.white.withOpacity(0.3),
                                              width: 1,
                                            ),
                                          ),
                                          child: const Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text(
                                                "Pay",
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
                                                    .arrow_circle_right_rounded,
                                                size: 26,
                                                color: Colors.white,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                            ),
                          ) // wallet
                        : GestureDetector(
                            onTap: () {
                              sendCharityStoreRequest();
                              razorpayService.openCheckout(
                                amount: finalAmount, // ₹100
                                razorpayKey: AppConstants.razorpayLive,
                                onSuccess: (response) {
                                  setState(() {
                                    circularIndicator = true;
                                  });
                                  print(
                                      "Payment Successful TXN: ${response.paymentId}");
                                  oderPlaceChadhava("${response.paymentId}");
                                },
                                onFailure: (response) {
                                  setState(() {
                                    circularIndicator = false;
                                  });
                                },
                                onExternalWallet: (response) {
                                  print("Wallet: ${response.walletName}");
                                },
                                description: 'Chadhava Screen',
                              );
                              Future.delayed(const Duration(milliseconds: 500),
                                  () {
                                setState(() {
                                  circularIndicator = true;
                                });
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 2, horizontal: 16),
                              margin: const EdgeInsets.all(10),
                              width: double.infinity,
                              height: 70, // Slightly increased height
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(
                                    12), // More rounded corners
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFFFF6D00), // More vibrant orange
                                    Color(0xFFFFAB00), // More vibrant amber
                                  ],
                                  begin: Alignment.bottomLeft,
                                  end: Alignment.topRight,
                                  stops: [
                                    0.1,
                                    0.9
                                  ], // Better gradient distribution
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.deepOrange.withOpacity(0.3),
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
                                        strokeWidth: 3,
                                      ),
                                    )
                                  : Row(
                                      children: [
                                        Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "₹$finalAmount",
                                              style: const TextStyle(
                                                fontSize: 22,
                                                fontWeight: FontWeight.bold,
                                                fontFamily: 'Roboto',
                                                color: Colors.white,
                                                letterSpacing: 0.5,
                                              ),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              widget.packageName,
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontFamily: 'Roboto',
                                                color: Colors.white70,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const Spacer(),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 12, vertical: 8),
                                          decoration: BoxDecoration(
                                            color:
                                                Colors.white.withOpacity(0.2),
                                            borderRadius:
                                                BorderRadius.circular(20),
                                          ),
                                          child: const Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text(
                                                "Pay",
                                                style: TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                  fontFamily: 'Roboto',
                                                  color: Colors.white,
                                                ),
                                              ),
                                              SizedBox(width: 6),
                                              Icon(
                                                Icons
                                                    .arrow_circle_right_rounded, // Slightly different icon
                                                size: 28,
                                                color: Colors.white,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                            ),
                          ) // razor pay
                    : GestureDetector(
                        onTap: () {
                          // _showBottomSheets();
                          sendCharityStoreRequest();
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
                                        : oderPlaceChadhava("pay_wallet");
                                    setState(() {
                                      isLoading = true;
                                    });
                                    // Add your payment logic here
                                  },
                                ),
                              ],
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 8, horizontal: 16),
                          margin: const EdgeInsets.all(12),
                          height: 70, // Slightly taller for better proportions
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(
                                12), // More rounded corners
                            gradient: const LinearGradient(
                              colors: [
                                Color(0xFFFF6D00), // More vibrant orange
                                Color(0xFFFFAB00), // Brighter amber
                              ],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                              stops: [0.2, 0.8], // Better gradient distribution
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.deepOrange.withOpacity(0.4),
                                blurRadius: 6,
                                spreadRadius: 1,
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
                                    // Wallet Info Column
                                    Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          "Via Wallet",
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight
                                                .w600, // Slightly less bold
                                            fontFamily: 'Roboto',
                                            color: Colors.white,
                                            letterSpacing: 0.3,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          widget.packageName,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontFamily: 'Roboto',
                                            color: Colors.white38,
                                          ),
                                        ),
                                      ],
                                    ),

                                    const Spacer(),

                                    // Pay Button Section
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.15),
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(
                                          color: Colors.white.withOpacity(0.3),
                                          width: 1,
                                        ),
                                      ),
                                      child: const Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            "Pay",
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              fontFamily: 'Roboto',
                                              color: Colors.white,
                                            ),
                                          ),
                                          SizedBox(width: 8),
                                          Icon(
                                            Icons.arrow_circle_right_rounded,
                                            size: 26,
                                            color: Colors.white,
                                          ),
                                        ],
                                      ),
                                    ),
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
                                listSumAmount == 0
                                    ? Container()
                                    : Text(
                                        "₹$listSumAmount",
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
                                                    .format(DateTime.parse(
                                                        widget.date)),
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
                                                              "Add",
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
                                                          listSumAmount =
                                                              quantity[index] *
                                                                  productItem
                                                                      .price;
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
                                                          listSumAmount =
                                                              quantity[index] *
                                                                  productItem
                                                                      .price;
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
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.end,
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
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: Colors.grey.shade300, width: 1.2),
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.1),
                              blurRadius: 8,
                              spreadRadius: 2,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Bill details",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Roboto',
                                color: Colors.orange,
                              ),
                            ),

                            const SizedBox(height: 16),

                            // Chadhava Amount
                            Row(
                              children: [
                                const Text(
                                  "Chadhava Amount",
                                  style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w500,
                                    fontFamily: 'Roboto',
                                    color: Colors.black87,
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                  "₹$totalAmount",
                                  style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w600,
                                    fontFamily: 'Roboto',
                                    color: Colors.blue.shade700,
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 12),

                            // Items List
                            ListView.builder(
                              shrinkWrap: true,
                              itemCount: items.length,
                              physics: const NeverScrollableScrollPhysics(),
                              itemBuilder: (context, index) {
                                final totalPay = items[index]['quantity'] *
                                    items[index]['amount'];
                                return Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 6),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          "${items[index]['name']}",
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w400,
                                            fontFamily: 'Roboto',
                                            color: Colors.black87,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          maxLines: 1,
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Text(
                                        "${items[index]['quantity']} x ₹${items[index]['amount']} = ₹$totalPay",
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontFamily: 'Roboto',
                                          color: Colors.blue.shade700,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),

                            const Divider(
                                height: 24, thickness: 1, color: Colors.grey),

                            // Wallet Balance
                            Row(
                              children: [
                                const Text(
                                  "Wallet Balance : ",
                                  style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w400,
                                    fontFamily: 'Roboto',
                                    color: Colors.black87,
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                  "₹$walletPay",
                                  style: const TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Roboto',
                                    color: Colors.blue,
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 8),

                            // Wallet Remaining
                            Row(
                              children: [
                                RichText(
                                  text: TextSpan(
                                    style: const TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w400,
                                      fontFamily: 'Roboto',
                                      color: Colors.black87,
                                    ),
                                    children: [
                                      const TextSpan(
                                          text: "Wallet remaining ("),
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
                                const Spacer(),
                              ],
                            ),

                            const SizedBox(height: 8),

                            // Amount Paid via Wallet
                            Row(
                              children: [
                                const Text(
                                  "Amount Paid (via Wallet)",
                                  style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w400,
                                    fontFamily: 'Roboto',
                                    color: Colors.black87,
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                  walletMinusAmount == 0
                                      ? "- ₹$walletPay"
                                      : "- ₹$totalAmount",
                                  style: const TextStyle(
                                    fontSize: 17,
                                    fontFamily: 'Roboto',
                                    color: Colors.red,
                                  ),
                                ),
                              ],
                            ),

                            const Divider(
                                height: 24, thickness: 1, color: Colors.grey),

                            // Total Amount
                            Row(
                              children: [
                                const Text(
                                  "Total Amount",
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w600,
                                    fontFamily: 'Roboto',
                                    color: Colors.black87,
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                  walletMinusAmount == 0
                                      ? "₹$finalAmount"
                                      : "₹0.0",
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w600,
                                    fontFamily: 'Roboto',
                                    color: Colors.orange,
                                  ),
                                ),
                              ],
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

                            const SizedBox(height: 8),
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
}
