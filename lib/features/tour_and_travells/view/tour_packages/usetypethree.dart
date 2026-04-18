import 'dart:convert';
import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:mahakal/main.dart';
import 'package:http/http.dart' as http;
import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:mahakal/utill/app_constants.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../../data/datasource/remote/http/httpClient.dart';
import '../../../../utill/razorpay_screen.dart';
import '../../../auth/controllers/auth_controller.dart';
import '../../../donation/ui_helper/custom_colors.dart';
import '../../../explore/payment_process_screen.dart';
import '../../../maha_bhandar/model/city_model.dart';
import '../../../profile/controllers/profile_contrroller.dart';
import '../../Controller/fetch_coupon_controller.dart';
import '../../Controller/fetch_wallet_controller.dart';
import '../../Controller/success_touramount_controller.dart';
import '../../Controller/tour_lead_controller.dart';
import '../../model/city_details_model.dart';
import '../../model/distance_model.dart';
import '../../widgets/ApplyCoupon.dart';
import '../../widgets/backhandler.dart';
import '../../widgets/cab_info_card.dart';
import '../../widgets/info_dialog.dart';
import '../../widgets/showbeautifulltoast.dart';
import '../../widgets/total_amount_display.dart';

class UseTypeThree extends StatefulWidget {
  const UseTypeThree(
      {super.key,
      required this.services,
      required this.packageList,
      required this.cabsquantity,
      required this.hotelList,
      required this.foodList,
      required this.tourId,
      required this.packageId,
      required this.translateEn,
      required this.timeSlot,
      required this.exDistance,
      required this.tourName,
      required this.hiTourName,
      required this.packageAmount,
      required this.useDate,
      required this.locationName,
      this.tourGst,
      this.transPortGst});

  final List<String>? services;
  final List<PackageList>? packageList;
  final List<CabList>? cabsquantity;

  final List<PackageList> hotelList;
  final List<PackageList> foodList;
  final List<dynamic>? timeSlot;
  final String tourId;
  final String? packageId;
  final String translateEn;
  final int? exDistance;
  final String tourName;
  final String hiTourName;
  final int packageAmount;
  final String useDate;
  final String locationName;
  final dynamic tourGst;
  final dynamic transPortGst;

  @override
  State<UseTypeThree> createState() => _UseTypeThreeState();
}

class _UseTypeThreeState extends State<UseTypeThree> {
  final razorpayService = RazorpayPaymentService();
  final TextEditingController countryController = TextEditingController();
  final TextEditingController couponController = TextEditingController();
  final leadController =
      Provider.of<TourLeadController>(Get.context!, listen: false);
  final successAmountController =
      Provider.of<SuccessTourAmountController>(Get.context!, listen: false);
  final fetchCouponController =
      Provider.of<FetchCouponController>(Get.context!, listen: false);
  final walletController =
      Provider.of<FetchWalletController>(Get.context!, listen: false);
  final List<GlobalKey> itemKeys = [];

  List<CityPickerModel> cityListModel = <CityPickerModel>[];
  List<Map<String, dynamic>> packageItems = [];
  List<Map<String, dynamic>> distanceArray = [];
  List<Map<String, dynamic>> mergedArrayList = [];

  List<int> selectedIndexes = [0];
  List<int> cabFinalAmount = [];

  late List<int> cabsQuantity;

  String userId = "";
  String userNAME = "";
  String userEMAIL = "";
  String userPHONE = "";
  String userToken = "";
  String latiTude = "";
  String serviceCouponType = "";
  String longiTude = "";
  String _selectedOption = 'pickup'; // Default selected option
  String? _selectedDate;
  String? _selectedTime;
  String? showingDate;

  int selectOrder = 0;
  int selectedAmountIndex = 0;
  int listSumAmount = 0;
  int? successAmountStatus;
  int? naviGateRazorpay;
  int couponId = 0;
  int? personQuantity;
  int selectedIndex = -1;
  int selectedCabQuantity = 0;

  bool circularIndicator = false;
  bool searchbox = false;
  bool timeBox = false;
  final bool _isLoading = false;
  bool extraDistBox = false;
  bool isCouponApplyed = false;
  bool isLoading = false;
  bool iswalletLaoding = false;

  double halfAmount = 0.0;
  double? packageAll;
  double? selectedCabTotalAmount;
  double? extraAddFromListView;
  double cabsPackageAmount = 0.0;
  double extraCharge = 0.0;
  double finalDoubleDistance = 0.0;
  double pickupAmount = 0.0;
  double pickupBothAmount = 0.0;
  double doubleCharge = 0.0;
  double distance = 0.0;
  double doubleDistance = 0.0;
  double finalDistance = 0.0;
  double couponAmount = 0.0;
  double amtAfterDis = 0.0;
  double amtByWallet = 0.0;
  double walletPay = 0.0;
  double walletMinusAmount = 0.0;
  double remainingAmount = 0.0;

  dynamic taxAmount = 0;
  dynamic amountAfterTax = 0;
  dynamic addTourTaxAmount = 0;
  dynamic specificCabTotal = 0;
  dynamic addTransportTaxAmount = 0;
  dynamic totalTax = 0;
  double totalFinalPrice = 0.0; // Store final amount

  //Country Picker
  final Country _selectedCountry = Country(
    phoneCode: "91",
    countryCode: "IN",
    e164Sc: 0,
    geographic: true,
    level: 1,
    name: "India",
    example: "9123456789",
    displayName: "India",
    displayNameNoCountryCode: "India",
    e164Key: "91-IN-0",
  );

  void updateValue(String value) {
    // Implement your logic here - e.g., print the value, perform validation, etc.
    print('Entered value: $value');
    getCityPick();
    searchBox();
  }

  /// Search Box
  void searchBox() {
    if (countryController.text.length > 1) {
      setState(() {
        searchbox = true;
      });
    } else if (countryController.text.isEmpty) {
      setState(() {
        searchbox = false;
      });
    }
    print("serchbox $searchbox");
  }

  void getCityPick() async {
    print("object");
    cityListModel.clear();
    var response = await http.post(
      Uri.parse('https://geo.vedicrishi.in/places/'),
      body: {
        "country": _selectedCountry.name,
        "name": countryController.text,
      },
    );
    if (response.statusCode == 200) {
      setState(() {
        var result = json.decode(response.body);
        print("Api response $result");
        List listLocation = result;
        cityListModel
            .addAll(listLocation.map((e) => CityPickerModel.fromJson(e)));
      });
    } else {
      print("Failed Api Rresponse");
    }
  }

  /// Move to Next
  void nextPage() {
    if (selectOrder < widget.services!.length + 1) {
      // Ensure selectOrder does not exceed the maximum limit.
      setState(() {
        selectOrder++;
        if (!selectedIndexes.contains(selectOrder)) {
          selectedIndexes.add(
              selectOrder); // Add selectOrder to selectedIndexes if not already added.
        }
      });

      if (itemKeys[selectOrder].currentContext != null) {
        Scrollable.ensureVisible(
          itemKeys[selectOrder].currentContext!,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      } else {
        // Optionally, handle the case where currentContext is null (e.g., log or show a fallback).
      }
    }
  }

  void previousPage() {
    if (selectOrder > 0) {
      // Ensure selectOrder does not go below 0.
      setState(() {
        if (selectedIndexes.contains(selectOrder) && selectOrder != 0) {
          selectedIndexes.remove(
              selectOrder); // Add selectOrder to selectedIndexes if not already added.
        }
        selectOrder--;
      });

      // Scroll to the previous tab using the key.
      if (itemKeys[selectOrder].currentContext != null) {
        Scrollable.ensureVisible(
          itemKeys[selectOrder].currentContext!,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      } else {}
    }
  }

  bool hasNonZeroQuantity(List<int> foodQuantity) {
    return foodQuantity.any((quantity) => quantity > 0);
  }

  /// Select Date
  Future<DateTime?> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now().add(const Duration(days: 1)),
      lastDate: DateTime(2100),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.orange.shade100,
              onPrimary: Colors.orange,
              surface: const Color(0xFFFFF7EC),
              onSurface: Colors.orange,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Colors.orange,
                backgroundColor: Colors.white,
              ),
            ),
            dialogTheme:
                const DialogThemeData(backgroundColor: Color(0xFFFFF7EC)),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _selectedDate = DateFormat('yyyy-MM-dd').format(picked);
        DateTime date = DateTime.parse("$_selectedDate");
        showingDate = DateFormat("d MMMM y").format(date);
      });
    }
    return null;
  }

  Future<void> _selectTime(BuildContext context) async {
    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            timePickerTheme: TimePickerThemeData(
              dialHandColor: Colors.orange.shade100,
              dialTextColor: Colors.orange,
              dialBackgroundColor: Colors.white,
              dayPeriodColor: Colors.white,
              dayPeriodTextColor: Colors.orange,
              backgroundColor: const Color(0xFFFFF7EC),
              hourMinuteTextColor: Colors.orange,
              hourMinuteColor: Colors.white,
              inputDecorationTheme: const InputDecorationTheme(
                border: InputBorder.none,
                filled: true,
                fillColor: Colors.white,
                hintStyle: TextStyle(color: Colors.orange),
                labelStyle: TextStyle(color: Colors.orange),
              ),
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Colors.orange,
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
            ),
            dialogTheme: const DialogThemeData(backgroundColor: Colors.white),
          ),
          child: child!,
        );
      },
    );
    if (pickedTime != null) {
      setState(() {
        _selectedTime = pickedTime.format(context);
      });
    }
  }

  void addCabQuantity(int index) {
    setState(() {
      // ✅ Step 1: Reset all quantities except selected one
      for (int i = 0; i < cabsQuantity.length; i++) {
        if (i != index) {
          cabsQuantity[i] = 0;
        }
      }

      // ✅ Step 2: Safely build the cabFinalAmount list
      cabFinalAmount.clear();
      for (int i = 0; i < widget.cabsquantity!.length; i++) {
        int currentPrice =
            int.tryParse(widget.cabsquantity![i].price ?? '0') ?? 0;
        int packageAmount = widget.packageAmount.toInt() ?? 0;
        cabFinalAmount.add(currentPrice + packageAmount);
      }

      // ✅ Step 3: All dependent logic happens AFTER the list is safely built
      //calculateGst(cabFinalAmount[index], widget.tourGst);

      cabsQuantity[index] = 1;
      selectedCabQuantity = 1;
      selectedIndex = index;

      addFoodItem(
        widget.cabsquantity![index].enCabName ?? '',
        cabFinalAmount[index],
        cabsQuantity[index],
        "Cab",
        widget.cabsquantity![index].image ?? '',
        "cab",
        widget.cabsquantity![index].cabId.toString(),
        widget.cabsquantity![index].seats ?? '',
        amountAfterTax,
        widget.tourGst ?? '',
        taxAmount,
      );

      sumTotal();
      specificCabTotal = cabFinalAmount[index];
    });
  }

  void increaseQuantity(int index, dynamic currentPrice, dynamic cabSeats) {
    if (cabsQuantity[index] < cabSeats) {
      if (index < 0 || index >= cabsQuantity.length) {
        return; // Prevent out-of-bounds error
      }
      cabsQuantity[index]++; // Increase quantity
      int packageAmount = widget.packageAmount.toInt() ?? 0;
      int finalAmount = (currentPrice + packageAmount);
      cabFinalAmount[index] = finalAmount; // Update the list
      //calculateGst(cabFinalAmount[index], widget.tourGst);
      addFoodItem(
        widget.cabsquantity![index].enCabName ?? '',
        cabFinalAmount[index],
        cabsQuantity[index],
        "Cab",
        widget.cabsquantity![index].image ?? '',
        "cab",
        widget.cabsquantity![index].cabId.toString(),
        widget.cabsquantity![index].seats ?? '',
        amountAfterTax,
        widget.tourGst ?? '',
        taxAmount,
      );
      sumTotal();
      specificCabTotal = cabFinalAmount[index];
    } else {
      BeautifulToast.show(
        context,
        "Currently $cabSeats seat are available",
        backgroundColor: Colors.red.shade600,
        icon: Icons.event_seat,
      );
    }
  }

  void decreaseQuantity(int index, dynamic currentPrice) {
    if (index < 0 || index >= cabsQuantity.length || cabsQuantity[index] <= 0) {
      return; // Prevent below 1
    }

    cabsQuantity[index]--; // Decrease quantity

    int packageAmount = widget.packageAmount.toInt() ?? 0;

    // Calculate new total amount
    int finalAmount = (currentPrice - packageAmount);
    cabFinalAmount[index] = finalAmount; // Update the amount list
    //calculateGst(cabFinalAmount[index], widget.tourGst);
    addFoodItem(
      widget.cabsquantity![index].enCabName ?? '',
      cabFinalAmount[index],
      cabsQuantity[index],
      "Cab",
      widget.cabsquantity![index].image ?? '',
      "cab",
      widget.cabsquantity![index].cabId.toString(),
      widget.cabsquantity![index].seats ?? '',
      amountAfterTax,
      widget.tourGst ?? '',
      taxAmount,
    );
    sumTotal();
    specificCabTotal = cabFinalAmount[index];

    // Reset selection if quantity becomes 0
    if (cabsQuantity[index] == 0) {
      selectedIndex = -1;
      selectedCabQuantity = 0;
    }
  }

  DistanceModel? distanceModel;
  Future<void> fetchDistance(String lat, String longi) async {
    Map<String, dynamic> data = {
      "tour_id": widget.tourId,
      "lat": lat,
      "long": longi
    };

    try {
      final res = await HttpService()
          .postApi(AppConstants.fetchTourDistanceUrl, data); // 🔄 Replaced here

      if (res != null) {
        final distanceData = DistanceModel.fromJson(res);
        setState(() {
          distanceModel = distanceData;
        });
        calculateExtraCharge();
      }
    } catch (e) {
      print("Error fetching distance: $e");
    }
  }

  void calculateExtraCharge() async {
    distance = distanceModel!.data!;
    doubleDistance = distance * 2;

    double extraDriverCharge =
        double.parse(distanceModel!.exChargeAmount.toString());

    double driverPickAmount;
    double driverPickDropAmount;

    if (distance <= 20) {
      // If distance is 10 km or less, no reduction and amount is 0
      finalDistance = 0;
      finalDoubleDistance = 0;
      pickupAmount = 0;
      pickupBothAmount = 0;
    } else {
      // If distance is greater than 10 km, subtract 10 and calculate amount
      finalDistance = distance - 10;
      finalDoubleDistance = doubleDistance - 10;

      // pickupAmount = finalDistance * widget.exDistance!;

      driverPickAmount = finalDistance * widget.exDistance!;
      pickupAmount = driverPickAmount + extraDriverCharge;

      // pickupBothAmount = finalDoubleDistance * widget.exDistance!;
      driverPickDropAmount = finalDoubleDistance * widget.exDistance!;
      pickupBothAmount = driverPickDropAmount + extraDriverCharge;
    }

    setState(() {
      distance > 200 ? extraDistBox = false : extraDistBox = true;
    });
    updatePickupDataIfReady();

    print("Distance: ${finalDistance.toStringAsFixed(2)} km");
    print("Extra Charge: ₹${pickupAmount.toStringAsFixed(2)}");
  }

  void updatePickupDataIfReady() {
    if (_selectedOption == "pickup") {
      //calculateGst(pickupAmount, widget.transPortGst);
      addDistanceArray(
        routeType: 'one_way',
        exDistancePrice: pickupAmount.toStringAsFixed(1),
        exDistanceQty: finalDistance.toStringAsFixed(1),
      );
    }
  }

  /// Add Item to Package List
  void addFoodItem(
    String name,
    dynamic amount,
    dynamic quantity,
    dynamic itemTitle,
    String image,
    String type,
    dynamic id,
    dynamic seats,
    dynamic pprice,
    dynamic tax,
    dynamic taxPrice,
  ) {
    setState(() {
      // Remove existing items of the same type
      packageItems.removeWhere((item) => item['title'] == itemTitle);

      // Add the new item to the list
      packageItems.add({
        'name': name,
        'price': amount,
        'qty': quantity,
        'image': image,
        'id': id,
        "seats": seats,
        "pprice": pprice,
        "tax": tax,
        "tax_price": taxPrice,
        "type": type,
        "title": itemTitle
      });

      print({
        'name': name,
        'price': amount,
        'qty': quantity,
        'image': image,
        'id': id,
        "seats": seats,
        "pprice": pprice,
        "tax": tax,
        "tax_price": taxPrice,
        "type": type,
        "title": itemTitle
      });
    });
  }

  /// Remove/Update Item from Package List by Title
  void updateItemQuantity(String itemTitle, int amount, int quantity) {
    setState(() {
      int existingIndex =
          packageItems.indexWhere((item) => item['title'] == itemTitle);

      if (existingIndex != -1) {
        if (quantity > 0) {
          packageItems[existingIndex]['qty'] = quantity;
          packageItems[existingIndex]['price'] = amount;
          packageItems[existingIndex]['pprice'] = amountAfterTax;
          packageItems[existingIndex]['tax_price'] = taxAmount;
        } else {
          packageItems.removeAt(existingIndex);
        }
      }
    });
  }

  /// Calculate GST
  Map<String, dynamic> calculateGst(dynamic price, dynamic percent) {
    double priceValue = 0.0;
    double percentValue = 0.0;

    // Handle null cases
    if (price == null || percent == null) {
      return {
        'taxAmount': taxAmount,
        'amountAfterTax': amountAfterTax,
      };
    }

    // Convert inputs to double
    try {
      priceValue =
          (price is String) ? double.tryParse(price) ?? 0.0 : price.toDouble();
      percentValue = (percent is String)
          ? double.tryParse(percent) ?? 0.0
          : percent.toDouble();
    } catch (e) {
      return {
        'taxAmount': taxAmount,
        'amountAfterTax': amountAfterTax,
      };
    }

    // Calculate values
    taxAmount = (priceValue * percentValue) / 100;
    amountAfterTax = priceValue - taxAmount;

    return {
      'taxAmount': taxAmount,
      'amountAfterTax': amountAfterTax,
    };
  }

  void addDistanceArray({
    required dynamic routeType,
    required dynamic exDistancePrice,
    required dynamic exDistanceQty,
  }) {
    setState(() {
      // Remove existing 'route' and 'ex_distance' type entries
      distanceArray.removeWhere((element) =>
          element['type'] == 'route' || element['type'] == 'ex_distance');

      // Add new data
      distanceArray.addAll([
        {
          "id": "0",
          "name": "",
          "seats": "",
          "image": "",
          "qty": "",
          "price": routeType,
          "pprice": "",
          "tax": widget.transPortGst,
          "tax_price": "",
          "type": "route",
          "title": "Route"
        },

        {
          "id": "0",
          "name": "",
          "seats": "",
          "image": "",
          "qty": exDistanceQty,
          "price": "",
          "pprice": exDistancePrice,
          "tax": widget.transPortGst,
          "tax_price": taxAmount,
          "type": "ex_distance",
          "title": "Ex Distance"
        },

        // {
        //   "name": "",
        //   "price": exDistancePrice, // e.g. 20
        //   "qty": exDistanceQty,     // e.g. 2
        //   "type": "ex_distance",
        //   "id": 0
        // },
      ]);
    });
  }

  void upSelectedIndex(int index) {
    setState(() {
      selectedAmountIndex = index;
    });
    sumTotal();
  }

  /// Calculating Price According to USE Type
  void sumTotal() {
    //totalTax = addTourTaxAmount + addTransportTaxAmount;

    if (_selectedOption == 'pickup') {
      selectedCabTotalAmount =
          (pickupAmount ?? 0) + (extraAddFromListView ?? 0);
    } else if (_selectedOption == 'pickup_drop') {
      selectedCabTotalAmount =
          (pickupBothAmount ?? 0) + (extraAddFromListView ?? 0);
    }

    calculateGst(selectedCabTotalAmount, widget.tourGst);

    totalFinalPrice = (selectedCabTotalAmount! + taxAmount);

    // Now after updating total, calculate half amount
    halfAmount = totalFinalPrice / 2;

    double payableAmount = isCouponApplyed
        ? amtAfterDis
        : (selectedAmountIndex == 0 ? totalFinalPrice : halfAmount);

    walletMinusAmount = max(walletPay - payableAmount, 0);
    amtByWallet = walletPay - walletMinusAmount;

    /// Logic for cutting amt from wallet
    if (walletPay >= payableAmount) {
      remainingAmount = 0;
    } else {
      remainingAmount = payableAmount - walletPay;
    }

    /// Logic for Payment Status (Wallet status , 1 or 0)
    if (walletPay >= payableAmount) {
      successAmountStatus = 1;
      naviGateRazorpay = 1;
    } else if (walletPay > 0 && walletPay < payableAmount) {
      successAmountStatus = 1;
      naviGateRazorpay = 2;
    } else {
      successAmountStatus = 0;
      naviGateRazorpay = 3;
    }
  }

  /// Place Tour Order
  void successPayment(String trxId) {
    final leadId = leadController.leadGenerateModel?.data.insertId;

    successAmountController.successTourAmount(
        tourId: widget.tourId,
        packageId: "${widget.packageId}",
        paymentAmount:
            "${selectedAmountIndex == 0 ? (isCouponApplyed ? amtAfterDis : totalFinalPrice) : halfAmount}",
        qty: "${personQuantity}",
        pickupAddress: "${countryController.text}",
        pickupDate: "${_selectedDate}",
        pickupTime: "${_selectedTime}",
        pickupLat: "${latiTude}",
        pickupLong: "${longiTude}",
        useDate: "${widget.useDate}",
        transactionId: "${trxId}",
        bookingPackage: mergedArrayList,
        walletType: "$successAmountStatus",
        onlinePay: "$remainingAmount",
        couponAmount: "$couponAmount",
        couponId: "$couponId",
        leadId: "$leadId",
        context: context,
        partPayment: selectedAmountIndex == 0 ? "full" : "part");
  }

  Future<void> applyCoupon(String code, String finalPackageAmount) async {
    try {
      final response = await http.post(
        Uri.parse("${AppConstants.baseUrl}${AppConstants.tourApplyCouponUrl}"),
        headers: {
          'Authorization': 'Bearer $userToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "user_id": userId,
          "coupon_code": code,
          "amount": double.tryParse(finalPackageAmount)?.toInt() ?? 0,
        }),
      );

      print("Response Code: ${response.statusCode}");
      print("Response Body: ${response.body}");

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);

        if (data["status"] == 1) {
          setState(() {
            couponAmount =
                double.parse(data["data"]["coupon_amount"].toString());
            amtAfterDis = double.parse(data["data"]["final_amount"].toString());
            couponId = data["data"]["coupon_id"];
            isCouponApplyed = true;
            walletMinusAmount = 0;
            walletMinusAmount = max(walletPay - amtAfterDis, 0);
            sumTotal();
          });

          Navigator.pop(context);
          BeautifulToast.show(
            context,
            "Applied Coupon 👍",
            backgroundColor: Colors.green,
            icon: Icons.discount,
          );
        } else {
          BeautifulToast.show(
            context,
            "${data["message"]}",
            backgroundColor: Colors.red,
            icon: Icons.error,
          );
        }
      } else {
        BeautifulToast.show(
          context,
          "Something went wrong. Please try again.",
          backgroundColor: Colors.red,
          icon: Icons.error,
        );
      }
    } catch (e) {
      print("$e");
    }
  }

  void showCouponSheet() {
    showCouponBottomSheet(
      context: context,
      couponController: couponController,
      couponModelList: fetchCouponController.couponlist,
      selectedCabTotalAmount: "$totalFinalPrice",
      onApplyCoupon: (code, amount) {
        applyCoupon(couponController.text, "$totalFinalPrice");
      },
      onCouponTap: (code, type) {
        setState(() {
          serviceCouponType = type;
        });
      },
    );
  }

  void showPaymentDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            widget.translateEn == "en"
                ? "Confirm Payment"
                : "भुगतान की पुष्टि करें",
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          content: Text(
            widget.translateEn == "en"
                ? "Are you sure you want to proceed with the payment?"
                : "क्या आप वाकई भुगतान जारी रखना चाहते हैं?",
            style: const TextStyle(fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.grey[700],
              ),
              child: Text(widget.translateEn == "en" ? "Cancel" : "रद्द करना"),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop(); // Close the confirmation dialog
                setState(() {
                  circularIndicator = true;
                });
                successPayment(
                    "wallet"); // Wait for API or function to complete
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange, // Primary color
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child:
                  Text(widget.translateEn == "en" ? "Pay Now" : "भुगतान करे"),
            ),
          ],
        );
      },
    );
  }

  String formatIndianCurrency(dynamic amount) {
    num parsedAmount = 0;

    // Try to safely parse any input type
    if (amount is num) {
      parsedAmount = amount;
    } else if (amount is String) {
      parsedAmount = num.tryParse(amount.replaceAll(',', '')) ?? 0;
    }

    final format = NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹',
      decimalDigits: 0,
    );

    return format.format(parsedAmount);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await walletController.fetchWallet();
      setState(() {
        walletPay = walletController.walletPay;
      });
      print("Wallet Amount$walletPay");
    });

    // User data initialization
    userId = Provider.of<ProfileController>(Get.context!, listen: false).userID;
    userNAME =
        Provider.of<ProfileController>(Get.context!, listen: false).userNAME;
    userEMAIL =
        Provider.of<ProfileController>(Get.context!, listen: false).userEMAIL;
    userPHONE =
        Provider.of<ProfileController>(Get.context!, listen: false).userPHONE;
    userToken =
        Provider.of<AuthController>(Get.context!, listen: false).getUserToken();
    fetchCouponController.fetchCoupon(
        type: "tour", couponUrl: AppConstants.tourCouponUrl);

    // Initialize package amount without cab price
    double cabPrice = double.tryParse(widget.cabsquantity![0].price ?? "") ?? 0.0;
    packageAll = cabPrice + widget.packageAmount;
    selectedCabTotalAmount = packageAll;

    // Initialize keys
    for (int i = 0; i < widget.services!.length + 2; i++) {
      itemKeys.add(GlobalKey());
    }

    // Initialize all cab quantities to 0 (no default selection)
    cabsQuantity = List.generate(widget.cabsquantity!.length, (index) => 0);
  }

  @override
  void dispose() {
    super.dispose();
    countryController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var screenWidth = MediaQuery.of(context).size.width;
    sumTotal();

    return WillPopScope(
      onWillPop: ()  {
        return  BackHandler.handle(
          context: context,
          showDialog: selectOrder == 2,
        );
      },
      child: circularIndicator
          ? const MahakalPaymentProcessing()
          : Scaffold(
              backgroundColor: Colors.white,
              appBar: AppBar(
                leading: GestureDetector(
                    onTap: ()  {
                      BackHandler.handle(
                        context: context,
                        showDialog: selectOrder == 2,
                      );
                    },
                    child: const Icon(Icons.arrow_back_ios)),
                backgroundColor: Colors.white,
                title: Text(
                  widget.translateEn == "en"
                      ? widget.tourName
                      : widget.hiTourName,
                  style: TextStyle(
                      fontSize: screenWidth * 0.06,
                      color: CustomColors.clrorange),
                ),
                centerTitle: true,
                bottom: PreferredSize(
                  preferredSize: const Size(double.infinity, 50),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(children: [
                      SizedBox(
                        height: 40,
                        child: ListView.builder(
                          shrinkWrap: true,
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          itemCount: 3,
                          itemBuilder: (context, index) {
                            String tabName = index == 0
                                ? "transport"
                                : index == 1
                                    ? "info"
                                    : "payment";
                            IconData tabIcon = index == 0
                                ? Icons.two_wheeler
                                : index == 1
                                    ? Icons.perm_device_info
                                    : Icons.currency_rupee;
                            String animationAsset = index == 0
                                ? "assets/animated/vehicle_animation.gif"
                                : index == 1
                                    ? "assets/animated/info_animation.gif"
                                    : "assets/animated/payment_animation.gif";

                            return Row(
                              children: [
                                Container(
                                  height: 40,
                                  width: 40,
                                  decoration: BoxDecoration(
                                    color: selectedIndexes.contains(index)
                                        ? Colors.grey.shade400
                                        : Colors.deepOrange.withOpacity(0.07),
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  child: Center(
                                    child: selectedIndexes.contains(index)
                                        ? ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(5),
                                            child: Image.asset(animationAsset),
                                          )
                                        : Icon(tabIcon,
                                            color: Colors.purple.shade400,
                                            size: 25),
                                  ),
                                ),
                                if (index < 2) // Separator for first two items
                                  Container(
                                    height: 1.5,
                                    width: 40,
                                    color: selectedIndexes.contains(index)
                                        ? Colors.orange
                                        : Colors.grey,
                                  ),
                              ],
                            );
                          },
                        ),
                      )
                    ]),
                  ),
                ),
              ),
              body: IndexedStack(
                index: selectOrder,
                children: [
                  /// Select Cab
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          const SizedBox(
                            height: 15,
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: Container(
                                  height: 2,
                                  decoration: const BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        // Start color
                                        Colors.red, // Middle color
                                        Colors.yellow, // End color
                                      ],
                                      begin: Alignment.topLeft,
                                      // Starting point of the gradient
                                      end: Alignment
                                          .bottomRight, // Ending point of the gradient
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                  child: Text(
                                widget.translateEn == "en"
                                    ? 'Select Cab'
                                    : "कैब चुनें",
                                style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.orange),
                                textAlign: TextAlign.center,
                              )),
                              Expanded(
                                  child: Container(
                                height: 2,
                                decoration: const BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.yellow, // Start color
                                      Colors.red, // Middle color
                                    ],
                                    begin: Alignment.topLeft,
                                    // Starting point of the gradient
                                    end: Alignment
                                        .bottomRight, // Ending point of the gradient
                                  ),
                                ),
                              )),
                            ],
                          ),
                          ListView.builder(
                            shrinkWrap: true,
                            itemCount: widget.cabsquantity!.length,
                            physics: const NeverScrollableScrollPhysics(),
                            itemBuilder: (context, index) {
                              for (int i = 0;
                                  i < widget.cabsquantity!.length;
                                  i++) {
                                int currentPrice = int.tryParse(
                                        widget.cabsquantity![i].price ?? '0') ??
                                    0; // Null-safe conversion
                                int packageAmount =
                                    widget.packageAmount.toInt() ??
                                        0; // Null safety check
                                cabFinalAmount.add((currentPrice +
                                    packageAmount)); // Safe addition
                              }
                              return CabInfoCard(
                                imageUrl:
                                    widget.cabsquantity![index].image ?? '',
                                cabName: widget.translateEn == "en"
                                    ? widget.cabsquantity![index].enCabName ??
                                        ''
                                    : widget.cabsquantity![index].hiCabName ??
                                        '',
                                seatsText: widget.translateEn == "en"
                                    ? "${widget.cabsquantity![index].seats} Seater"
                                    : "${widget.cabsquantity![index].seats} सीटर",
                                unitPrice:
                                    "${widget.cabsquantity![index].price}",
                                totalLabel: "Total",
                                totalPrice: cabsQuantity[index] == 0
                                    ? "00"
                                    : "${cabFinalAmount[index]}",
                                quantity: cabsQuantity[index],
                                isEnglish: widget.translateEn == "en",
                                personInCab: false,
                                isPersonWise: true,
                                widgetIndex: index,
                                selectedIndex: selectedIndex,
                                isSelected: selectedIndex == index,
                                onSelect: () {
                                  setState(() {
                                    selectedIndex = index;
                                  });
                                },
                                onAddTap: () => addCabQuantity(index),
                                onIncreaseTap: () => increaseQuantity(
                                    index,
                                    int.parse("${cabFinalAmount[index]}"),
                                    widget.cabsquantity![index].seats),
                                onDecreaseTap: () => decreaseQuantity(index,
                                    int.parse("${cabFinalAmount[index]}")),
                                onClearTap: () {
                                  setState(() {
                                    cabsQuantity[index] =
                                        0; // Reset your quantity state variable
                                    selectedIndex = -1;
                                    selectedCabQuantity = 0;
                                    updateItemQuantity(
                                      "Cab",
                                      cabFinalAmount[index],
                                      cabsQuantity[index],
                                    );
                                  });
                                },
                                onInfoTap: () {
                                  InfoDialog.show(
                                    context: context,
                                    description: widget.translateEn == "en"
                                        ? widget
                                            .cabsquantity![index].enDescription
                                        : widget
                                            .cabsquantity![index].hiDescription,
                                    languageCode: widget.translateEn,
                                  );
                                },
                              );
                            },
                          ),
                          const SizedBox(
                            height: 80,
                          )
                        ],
                      ),
                    ),
                  ),

                  /// Info
                  SingleChildScrollView(
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(
                              left: 10.0, right: 10.0, top: 20.0),
                          child: Container(
                            padding: const EdgeInsets.all(15),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5),
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.3),
                                  blurRadius: 10,
                                  offset: const Offset(0, 7),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Column(
                                  children: [
                                    // Location Search Field
                                    Text(
                                      widget.translateEn == "en"
                                          ? 'Pickup Location(Airport, Railway Station, Bus Stand, Hotel etc)'
                                          : "पिकअप स्थान:(हवाई अड्डा, रेलवे स्टेशन, बस स्टैंड, होटल आदि)\nFree up to 20 km there after charges will be payable as per distance",
                                      style: const TextStyle(
                                          fontSize: 16,
                                          color: Colors.black,
                                          fontFamily: 'Roboto',
                                          fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(height: 5),

                                    // TextField with orange/red border
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8.0),
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: distance > 200
                                              ? Colors.red
                                              : Colors.orange,
                                        ),
                                      ),
                                      child: TextFormField(
                                        controller: countryController,
                                        onChanged: (value) =>
                                            updateValue(value),
                                        decoration: InputDecoration(
                                          hintText: widget.translateEn == "en"
                                              ? 'Search City'
                                              : "शहर खोजें",
                                          suffixIcon: Icon(
                                            Icons.location_on_outlined,
                                            size: 28,
                                            color: distance > 200
                                                ? Colors.red
                                                : Colors.orange,
                                          ),
                                          hintStyle: const TextStyle(
                                              color: Colors.grey),
                                          border: InputBorder.none,
                                        ),
                                      ),
                                    ),

                                    // 200 km warning message (now outside TextField container)
                                    if (distance > 200)
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(top: 4.0),
                                        child: Text(
                                          widget.translateEn == "en"
                                              ? 'Please select location within 200 km'
                                              : 'कृपया 200 किमी के भीतर स्थान चुनें',
                                          style: const TextStyle(
                                            color: Colors.red,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),

                                    // Search Results Dropdown
                                    AnimatedContainer(
                                      duration:
                                          const Duration(milliseconds: 300),
                                      curve: Curves.easeInOut,
                                      padding: const EdgeInsets.all(8.0),
                                      height: searchbox ? 160 : 0,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        border: Border.all(
                                          color: searchbox
                                              ? Colors.grey
                                              : Colors.transparent,
                                        ),
                                        borderRadius:
                                            BorderRadius.circular(6.0),
                                        boxShadow: [
                                          BoxShadow(
                                            color:
                                                Colors.black.withOpacity(0.1),
                                            blurRadius: 4,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: ListView.builder(
                                        shrinkWrap: true,
                                        physics: const BouncingScrollPhysics(),
                                        itemCount: cityListModel.length,
                                        itemBuilder:
                                            (BuildContext context, int index) {
                                          return InkWell(
                                            onTap: () async {
                                              // Pehle location set karo
                                              latiTude = cityListModel[index]
                                                  .latitude
                                                  .toString();
                                              longiTude = cityListModel[index]
                                                  .longitude
                                                  .toString();
                                              countryController.text =
                                                  cityListModel[index].place;

                                              // Distance calculate karo
                                              await fetchDistance(
                                                  latiTude, longiTude);

                                              // Agar distance 200km se zyada hai to clear karo
                                              if (distance > 200) {
                                                setState(() {
                                                  countryController.clear();
                                                });
                                              }

                                              setState(() {
                                                searchbox = false;
                                              });
                                            },
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  children: [
                                                    const Icon(Icons
                                                        .location_on_outlined),
                                                    const SizedBox(width: 8),
                                                    Expanded(
                                                      child: Text(
                                                        cityListModel[index]
                                                            .place,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        style: const TextStyle(
                                                          color: Colors.black,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                const Divider(
                                                    color: Colors.grey),
                                              ],
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),

                                _buildRowWithIcon(
                                  context,
                                  icon: Icons.calendar_month,
                                  label: widget.translateEn == "en"
                                      ? "Arrival Date"
                                      : "आगमन तिथि",
                                  onTap: () => _selectDate(context),
                                  content: showingDate ??
                                      (widget.translateEn == "en"
                                          ? "SELECT DATE"
                                          : "तारीख़ चुनें"),
                                ),
                                const SizedBox(height: 20),
                                _buildRowWithIcon(
                                  context,
                                  icon: Icons.watch_later_outlined,
                                  label: widget.translateEn == "en"
                                      ? "Arrival Time"
                                      : "आगमन का समय",
                                  onTap: () {
                                    setState(() {
                                      widget.timeSlot!.isEmpty
                                          ? _selectTime(context)
                                          : timeBox = true;
                                    });
                                  },
                                  content: _selectedTime ??
                                      (widget.translateEn == "en"
                                          ? "SELECT TIME"
                                          : "समय चुनें"),
                                ),

                                const SizedBox(
                                  height: 10.0,
                                ),
                                // location
                                AnimatedContainer(
                                  duration: const Duration(milliseconds: 600),
                                  // Adjust animation duration for smooth transition
                                  curve: Curves.easeInCirc,
                                  // Customize animation curve if needed
                                  padding: const EdgeInsets.all(8.0),
                                  height: timeBox == false ? 0 : 150,
                                  decoration: BoxDecoration(
                                      color: Colors.white,
                                      border: Border.all(color: Colors.grey),
                                      borderRadius: BorderRadius.circular(6.0)),
                                  child: ListView.builder(
                                    shrinkWrap: true,
                                    physics: const BouncingScrollPhysics(),
                                    itemCount: widget.timeSlot!.length,
                                    // Number of items in the list
                                    itemBuilder:
                                        (BuildContext context, int index) {
                                      return SingleChildScrollView(
                                        child: InkWell(
                                          onTap: () {
                                            setState(() {
                                              timeBox = false;
                                              _selectedTime =
                                                  widget.timeSlot![index];
                                            });
                                          },
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  const Icon(Icons
                                                      .watch_later_outlined),
                                                  const SizedBox(
                                                    width: 5,
                                                  ),
                                                  Expanded(
                                                    child: Text(
                                                      widget.timeSlot![index],
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: const TextStyle(
                                                          color: Colors.black,
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const Divider(
                                                color: Colors.grey,
                                              )
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),

                                if (extraDistBox)
                                  Column(
                                    children: [
                                      // Header with Icon
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 16, vertical: 8),
                                        child: Row(
                                          children: [
                                            Icon(Icons.route,
                                                size: 28,
                                                color: Colors.deepOrange[400]),
                                            const SizedBox(width: 12),
                                            Text(
                                              widget.translateEn == "en"
                                                  ? "Select Route Type"
                                                  : "रूट प्रकार चुनें",
                                              style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.grey[800],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),

                                      // Route Type Selector
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 16),
                                        child: Row(
                                          children: [
                                            // One Way Option
                                            Expanded(
                                              child: GestureDetector(
                                                onTap: () {
                                                  setState(() {
                                                    _selectedOption = 'pickup';
                                                    //calculateGst(pickupAmount, widget.transPortGst);
                                                    addDistanceArray(
                                                      routeType: 'one_way',
                                                      exDistancePrice:
                                                          pickupAmount
                                                              .toStringAsFixed(
                                                                  1),
                                                      exDistanceQty:
                                                          finalDistance
                                                              .toStringAsFixed(
                                                                  1),
                                                    );
                                                  });
                                                },
                                                child: Container(
                                                  padding:
                                                      const EdgeInsets.all(12),
                                                  decoration: BoxDecoration(
                                                    color: _selectedOption ==
                                                            'pickup'
                                                        ? Colors.deepOrange[50]
                                                        : Colors.grey[50],
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10),
                                                    border: Border.all(
                                                      color: _selectedOption ==
                                                              'pickup'
                                                          ? Colors
                                                              .deepOrange[300]!
                                                          : Colors.grey[300]!,
                                                      width: 1.5,
                                                    ),
                                                  ),
                                                  child: Column(
                                                    children: [
                                                      Icon(Icons.north_east,
                                                          size: 28,
                                                          color: _selectedOption ==
                                                                  'pickup'
                                                              ? Colors.deepOrange[
                                                                  400]
                                                              : Colors
                                                                  .grey[600]),
                                                      const SizedBox(height: 8),
                                                      Text(
                                                        widget.translateEn ==
                                                                "en"
                                                            ? "One Way"
                                                            : "एक तरफा",
                                                        style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          color: _selectedOption ==
                                                                  'pickup'
                                                              ? Colors.deepOrange[
                                                                  800]
                                                              : Colors
                                                                  .grey[800],
                                                          fontSize: 15,
                                                        ),
                                                      ),
                                                      const SizedBox(height: 4),
                                                      Text(
                                                        widget.translateEn ==
                                                                "en"
                                                            ? "Pickup Only"
                                                            : "केवल पिकअप",
                                                        style: TextStyle(
                                                          color: _selectedOption ==
                                                                  'pickup'
                                                              ? Colors.deepOrange[
                                                                  600]
                                                              : Colors
                                                                  .grey[600],
                                                          fontSize: 13,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),

                                            const SizedBox(width: 16),

                                            // Round Trip Option
                                            Expanded(
                                              child: GestureDetector(
                                                onTap: () {
                                                  setState(() {
                                                    _selectedOption =
                                                        'pickup_drop';
                                                    //calculateGst(pickupBothAmount, widget.transPortGst);
                                                    addDistanceArray(
                                                      routeType: 'two_way',
                                                      exDistancePrice:
                                                          pickupBothAmount
                                                              .toStringAsFixed(
                                                                  1),
                                                      exDistanceQty:
                                                          finalDoubleDistance
                                                              .toStringAsFixed(
                                                                  1),
                                                    );
                                                  });
                                                },
                                                child: Container(
                                                  padding:
                                                      const EdgeInsets.all(12),
                                                  decoration: BoxDecoration(
                                                    color: _selectedOption ==
                                                            'pickup_drop'
                                                        ? Colors.deepOrange[50]
                                                        : Colors.grey[50],
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10),
                                                    border: Border.all(
                                                      color: _selectedOption ==
                                                              'pickup_drop'
                                                          ? Colors
                                                              .deepOrange[300]!
                                                          : Colors.grey[300]!,
                                                      width: 1.5,
                                                    ),
                                                  ),
                                                  child: Column(
                                                    children: [
                                                      Icon(Icons.compare_arrows,
                                                          size: 28,
                                                          color: _selectedOption ==
                                                                  'pickup_drop'
                                                              ? Colors.deepOrange[
                                                                  400]
                                                              : Colors
                                                                  .grey[600]),
                                                      const SizedBox(height: 8),
                                                      Text(
                                                        widget.translateEn ==
                                                                "en"
                                                            ? "Round Trip"
                                                            : "राउंड ट्रिप",
                                                        style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          color: _selectedOption ==
                                                                  'pickup_drop'
                                                              ? Colors.deepOrange[
                                                                  800]
                                                              : Colors
                                                                  .grey[800],
                                                          fontSize: 15,
                                                        ),
                                                      ),
                                                      const SizedBox(height: 4),
                                                      Text(
                                                        widget.translateEn ==
                                                                "en"
                                                            ? "Pickup & Drop"
                                                            : "पिकअप और ड्रॉप",
                                                        style: TextStyle(
                                                          color: _selectedOption ==
                                                                  'pickup_drop'
                                                              ? Colors.deepOrange[
                                                                  600]
                                                              : Colors
                                                                  .grey[600],
                                                          fontSize: 13,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),

                                      const SizedBox(height: 20),

                                      // Distance Summary Card
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 16),
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black
                                                    .withOpacity(0.1),
                                                blurRadius: 10,
                                                offset: const Offset(0, 4),
                                              ),
                                            ],
                                          ),
                                          child: Column(
                                            children: [
                                              // Card Header
                                              Container(
                                                padding:
                                                    const EdgeInsets.all(12),
                                                decoration: BoxDecoration(
                                                  color: Colors.blue[700],
                                                  borderRadius:
                                                      const BorderRadius.only(
                                                    topLeft:
                                                        Radius.circular(12),
                                                    topRight:
                                                        Radius.circular(12),
                                                  ),
                                                ),
                                                child: Row(
                                                  children: [
                                                    Icon(Icons.receipt,
                                                        color: Colors.white
                                                            .withOpacity(0.9)),
                                                    const SizedBox(width: 10),
                                                    Text(
                                                      widget.translateEn == "en"
                                                          ? "Trip Summary"
                                                          : "यात्रा सारांश",
                                                      style: const TextStyle(
                                                        color: Colors.white,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        fontSize: 16,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),

                                              // Distance Details
                                              Padding(
                                                padding:
                                                    const EdgeInsets.all(16),
                                                child: Column(
                                                  children: [
                                                    Row(
                                                      children: [
                                                        Container(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(6),
                                                          decoration:
                                                              BoxDecoration(
                                                            color:
                                                                Colors.blue[50],
                                                            shape:
                                                                BoxShape.circle,
                                                          ),
                                                          child: Icon(
                                                              Icons
                                                                  .social_distance,
                                                              size: 18,
                                                              color: Colors
                                                                  .blue[700]),
                                                        ),
                                                        const SizedBox(
                                                            width: 12),
                                                        Expanded(
                                                          child: Text(
                                                            widget.translateEn ==
                                                                    "en"
                                                                ? "Distance"
                                                                : "दूरी",
                                                            style: TextStyle(
                                                              fontSize: 15,
                                                              color: Colors
                                                                  .grey[700],
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500,
                                                            ),
                                                          ),
                                                        ),
                                                        Text(
                                                          _selectedOption ==
                                                                  'pickup'
                                                              ? "${finalDistance.toStringAsFixed(1)} km"
                                                              : "${finalDoubleDistance.toStringAsFixed(1)} km",
                                                          style: TextStyle(
                                                            fontSize: 15,
                                                            fontWeight:
                                                                FontWeight.w600,
                                                            color: Colors
                                                                .grey[800],
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    const Divider(height: 24),
                                                    Row(
                                                      children: [
                                                        Container(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(6),
                                                          decoration:
                                                              BoxDecoration(
                                                            color:
                                                                Colors.blue[50],
                                                            shape:
                                                                BoxShape.circle,
                                                          ),
                                                          child: Icon(
                                                              Icons
                                                                  .currency_rupee,
                                                              size: 18,
                                                              color: Colors
                                                                  .blue[700]),
                                                        ),
                                                        const SizedBox(
                                                            width: 12),
                                                        Expanded(
                                                          child: Text(
                                                            widget.translateEn ==
                                                                    "en"
                                                                ? "Total Charge"
                                                                : "कुल शुल्क",
                                                            style: TextStyle(
                                                              fontSize: 15,
                                                              color: Colors
                                                                  .grey[700],
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                            ),
                                                          ),
                                                        ),
                                                        Text(
                                                          _selectedOption ==
                                                                  'pickup'
                                                              ? "${formatIndianCurrency(pickupAmount)}"
                                                              : "${formatIndianCurrency(pickupBothAmount)}",
                                                          style: TextStyle(
                                                            fontSize: 15,
                                                            fontWeight:
                                                                FontWeight.w700,
                                                            color: Colors
                                                                .blue[800],
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 70,
                        )
                      ],
                    ),
                  ),

                  /// Payment
                  Padding(
                    padding: const EdgeInsets.only(
                        left: 10.0, right: 10.0, top: 25.0),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          /// Packages List
                          ListView.builder(
                            shrinkWrap: true,
                            itemCount: packageItems.length,
                            physics: const NeverScrollableScrollPhysics(),
                            itemBuilder: (context, index) {
                              extraAddFromListView =
                                  (packageItems[index]["price"] as num?)
                                          ?.toDouble() ??
                                      0.0;
                              addTourTaxAmount =
                                  packageItems[index]["tax_price"];
                              personQuantity = packageItems[index]["qty"];
                              sumTotal();
                              return Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                        color: Colors.grey.shade300,
                                        width: 1.5),
                                    color: Colors.white),
                                child: Row(
                                  children: [
                                    Expanded(
                                      flex: 1,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "${packageItems[index]["name"]}",
                                            style: const TextStyle(
                                                fontSize: 18,
                                                overflow: TextOverflow.ellipsis,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black),
                                            maxLines: 1,
                                          ),
                                          packageItems[index]["type"] == "cab"
                                              ? Text(
                                                  "${packageItems[index]["seats"]} Seats",
                                                  style: const TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      color: Colors.black),
                                                )
                                              : const SizedBox(
                                                  height: 10,
                                                ),
                                          Text(
                                              "${packageItems[index]["qty"]} Person",
                                              style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w500,
                                                  color: Colors.grey)),
                                          Text(
                                             // "Total: ₹ ${packageItems[index]["price"]}",
                                              "Total: ${formatIndianCurrency(packageItems[index]["price"])}",
                                              style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w500,
                                                  color: Colors.blue)),
                                        ],
                                      ),
                                    ),
                                    Expanded(
                                      flex: 0,
                                      child: Container(
                                        height: 85,
                                        width: 125,
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            border:
                                                Border.all(color: Colors.grey),
                                            image: DecorationImage(
                                                image: NetworkImage(
                                                    "${packageItems[index]["image"]}"),
                                                fit: BoxFit.fill)),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),

                          const SizedBox(
                            height: 8,
                          ),

                          finalDistance == 0
                              ? const SizedBox()
                              : ListView.builder(
                                  shrinkWrap: true,
                                  itemCount: distanceArray.length,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemBuilder: (context, index) {
                                    addTransportTaxAmount =
                                        distanceArray[index]["tax_price"];
                                    return Container(
                                      margin: const EdgeInsets.only(bottom: 5),
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          border: Border.all(
                                              color: Colors.grey.shade300,
                                              width: 1.5),
                                          color: Colors.white),
                                      child: Row(
                                        children: [
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              distanceArray[index]["qty"] == ""
                                                  ? const SizedBox()
                                                  : Text(
                                                      "Extra Distance: ${distanceArray[index]["qty"]}",
                                                      style: const TextStyle(
                                                          fontSize: 16,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          color: Colors.black)),
                                              Text(
                                                distanceArray[index]["price"] ==
                                                        "one_way"
                                                    ? "Route Type: One Way"
                                                    : distanceArray[index]
                                                                ["price"] ==
                                                            "two_way"
                                                        ? "Route Type: Two Way"
                                                       // : "Extra Distance Amount: ₹${distanceArray[index]["pprice"]}",
                                                        : "Extra Distance Amount: ${formatIndianCurrency(distanceArray[index]["pprice"])}",
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w500,
                                                  color: distanceArray[index]
                                                              ["price"] ==
                                                          "one_way"
                                                      ? Colors.red
                                                      : distanceArray[index]
                                                                  ["price"] ==
                                                              "two_way"
                                                          ? Colors.red
                                                          : Colors.blue,
                                                ),
                                              ),
                                              // distanceArray[index]
                                              //             ["tax_price"] ==
                                              //         ""
                                              //     ? const SizedBox()
                                              //     : Text(
                                              //         "Tax Price: ₹${distanceArray[index]["tax_price"]}")
                                            ],
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),

                          /// Partial Payment
                          Container(
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
                                      upSelectedIndex(0);
                                    },
                                    child: Container(
                                      margin: const EdgeInsets.all(8),
                                      height: 45,
                                      decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(8.0),
                                        border: Border.all(
                                            color: selectedAmountIndex == 0
                                                ? Colors.orange
                                                : Colors.transparent),
                                        color: selectedAmountIndex == 0
                                            ? Colors.orange
                                            : Colors.grey.shade200,
                                      ),
                                      child: Center(
                                        child: Text(
                                          "Full Payment",
                                          style: TextStyle(
                                            fontSize: 18,
                                            color: selectedAmountIndex == 0
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
                                      upSelectedIndex(1);
                                      isCouponApplyed = false;
                                      sumTotal();
                                    },
                                    child: Container(
                                      margin: const EdgeInsets.all(8),
                                      height: 45,
                                      decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(8.0),
                                        border: Border.all(
                                            color: selectedAmountIndex == 0
                                                ? Colors.transparent
                                                : Colors.orange),
                                        color: selectedAmountIndex == 0
                                            ? Colors.grey.shade200
                                            : Colors.orange,
                                      ),
                                      child: Center(
                                        child: Text(
                                          "Partial Payment",
                                          style: TextStyle(
                                            fontSize: 18,
                                            color: selectedAmountIndex == 0
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

                          /// Applying Coupon
                          selectedAmountIndex == 0
                              ? couponBox(
                                  context: context,
                                  isApplied: isCouponApplyed,
                                  hasCoupons: fetchCouponController
                                      .couponlist.isNotEmpty,
                                  onApply: showCouponSheet,
                                  onRemove: () {
                                    setState(() => isCouponApplyed = false);
                                  },
                                )
                              : const SizedBox(),

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
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Bill Details Heading
                                Text(
                                  widget.translateEn == "en"
                                      ? "Bill details"
                                      : "बिल विवरण",
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Roboto',
                                    color: Theme.of(context).primaryColor,
                                  ),
                                ),
                                const SizedBox(height: 10),

                                // Package Price
                                Row(
                                  children: [
                                    Text(
                                      widget.translateEn == "en"
                                          ? "Package Price"
                                          : "पैकेज राशि",
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w400,
                                        fontFamily: 'Roboto',
                                        color: Colors.black87,
                                      ),
                                    ),
                                    const Spacer(),
                                    Text(
                                      //"₹${selectedCabTotalAmount}",
                                      "${formatIndianCurrency(selectedCabTotalAmount)}",
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontFamily: 'Roboto',
                                        color: Colors.blueGrey,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),

                                // Tax Total
                                Row(
                                  children: [
                                    Text(
                                      widget.translateEn == "en"
                                          ? "Tax Total (${widget.tourGst}% GST)"
                                          : "कुल टैक्स (${widget.tourGst}% GST)",
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w400,
                                        fontFamily: 'Roboto',
                                        color: Colors.black87,
                                      ),
                                    ),
                                    const Spacer(),
                                    Text(
                                      //"₹${taxAmount.toStringAsFixed(2)}",
                                      "${formatIndianCurrency(taxAmount)}",
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontFamily: 'Roboto',
                                        color: Colors.red,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),

                                // Divider
                                Divider(
                                    color: Colors.grey.shade400, thickness: 1),
                                const SizedBox(height: 8),

                                // Total Price
                                Row(
                                  children: [
                                    Text(
                                      widget.translateEn == "en"
                                          ? "Total Price"
                                          : "कुल राशि",
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                        fontFamily: 'Roboto',
                                        color: Colors.black87,
                                      ),
                                    ),
                                    const Spacer(),
                                    Text(
                                      //"₹${totalFinalPrice.toStringAsFixed(2)}",
                                      "${formatIndianCurrency(totalFinalPrice)}",
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontFamily: 'Roboto',
                                        fontWeight: FontWeight.bold,
                                        color: Colors.green,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),

                                // Discount Section
                                Column(
                                  children: [
                                    const Divider(height: 1, thickness: 1),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        Text(
                                          widget.translateEn == "en"
                                              ? "Special Discount"
                                              : "विशेष छूट",
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w400,
                                            fontFamily: 'Roboto',
                                            color: Colors.black87,
                                          ),
                                        ),
                                        const Spacer(),
                                        Text(
                                          isCouponApplyed
                                             // ? "- ₹${couponAmount.toStringAsFixed(2)}"
                                              ? "- ${formatIndianCurrency(couponAmount)}"
                                              : "- ₹0.00",
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontFamily: 'Roboto',
                                            color: isCouponApplyed
                                                ? Colors.red
                                                : Colors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),

                                // Wallet Balance
                                Column(
                                  children: [
                                    const Divider(height: 1, thickness: 1),
                                    const SizedBox(height: 8),

                                    /// Wallet Balance
                                    Row(
                                      children: [
                                        RichText(
                                          text: TextSpan(
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontFamily: 'Roboto',
                                              fontWeight: FontWeight.w400,
                                              color: Colors.black,
                                            ),
                                            children: [
                                              TextSpan(
                                                text: widget.translateEn == "en"
                                                    ? "Wallet Balance ("
                                                    : "वॉलेट राशि (",
                                              ),
                                              TextSpan(
                                                text:
                                                   // "₹${walletPay.toStringAsFixed(2)}",
                                                    "${formatIndianCurrency(walletPay)}",
                                                style: const TextStyle(
                                                  color: Colors.green,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              const TextSpan(text: ")"),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),

                                    /// Wallet Remaining
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            widget.translateEn == "en"
                                                ? "Wallet Remaining"
                                                : "वॉलेट शेष",
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w400,
                                              fontFamily: 'Roboto',
                                              color: Colors.black,
                                            ),
                                          ),
                                        ),
                                        Text(
                                          //"₹${walletMinusAmount.toStringAsFixed(2)}",
                                          "${formatIndianCurrency(walletMinusAmount)}",
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontFamily: 'Roboto',
                                            color: Colors.blue,
                                          ),
                                        )
                                      ],
                                    ),

                                    /// Amount Paid via Wallet
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            widget.translateEn == "en"
                                                ? "Amount Paid (via Wallet)"
                                                : "भुगतान की गयी राशि (वॉलेट से)",
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w400,
                                              fontFamily: 'Roboto',
                                              color: Colors.black,
                                            ),
                                          ),
                                        ),
                                        Text(
                                         // "- ₹${amtByWallet.toStringAsFixed(2)}",
                                          "- ${formatIndianCurrency(amtByWallet)}",
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontFamily: 'Roboto',
                                            color: Colors.red,
                                          ),
                                        )
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                    const Divider(thickness: 1.5),
                                  ],
                                ),
                                const SizedBox(height: 8),

                                // Final Payable Amount
                                Divider(
                                    color: Colors.grey.shade400, thickness: 1),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    Text(
                                      widget.translateEn == "en"
                                          ? "Total Payable Amount"
                                          : "कुल देय राशि",
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'Roboto',
                                        color: Colors.black87,
                                      ),
                                    ),
                                    const Spacer(),
                                    Text(
                                      //"₹${remainingAmount.toStringAsFixed(2)}",
                                      "${formatIndianCurrency(remainingAmount)}",
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'Roboto',
                                        color: Theme.of(context).primaryColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          selectedAmountIndex == 0
                              ? const SizedBox()
                              : Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(5),
                                    color:
                                        const Color.fromRGBO(255, 245, 236, 1),
                                  ),
                                  child: Center(
                                    child: Text(
                                      widget.translateEn == "en"
                                          ? "The remaining Amount must be paid before the tour begins"
                                          : "शेष राशि आपको यात्रा शुरू होने से पहले भुगतान करनी होगी।",
                                      style: const TextStyle(
                                          fontSize: 14,
                                          letterSpacing: 0.5,
                                          fontWeight: FontWeight.w500,
                                          fontFamily: 'Roboto',
                                          color: Colors.orange),
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
                  const SizedBox(
                    height: 50,
                  )
                ],
              ),
              bottomNavigationBar: selectedCabQuantity != 0
                  ? Container(
                      padding: const EdgeInsets.only(
                          top: 10, left: 15, right: 15, bottom: 15),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 6,
                            offset: Offset(0, -1),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // 💰 Total Amount Box
                          selectOrder == 2
                              ? const SizedBox()
                              : totalAmountDisplay(
                                  amount:
                                      "${specificCabTotal + (_selectedOption == 'pickup' ? pickupAmount : pickupBothAmount)}",
                                ),
                          const SizedBox(height: 10),

                          selectOrder == 2
                              ? Row(
                                  children: [
                                    GestureDetector(
                                      onTap: () {
                                        mergedArrayList.clear();
                                        previousPage();
                                        setState(() {
                                          isCouponApplyed = false;
                                        });
                                      },
                                      child: Container(
                                        height: 45,
                                        width: 45,
                                        margin: const EdgeInsets.all(5),
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(8.0),
                                          color: selectOrder == 0
                                              ? Colors.grey
                                              : Colors.blue,
                                        ),
                                        child: const Icon(
                                          Icons.arrow_circle_left,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: GestureDetector(
                                        onTap: () {
                                          leadController.generateTourLead(
                                            tourId: widget.tourId,
                                            packageId:
                                                widget.packageId.toString(),
                                            amount:
                                                '${remainingAmount == 0 ? amtByWallet : (selectedAmountIndex == 0 ? (remainingAmount == 0 ? amtByWallet : remainingAmount) : halfAmount)}',
                                          );

                                          if (naviGateRazorpay == 2) {
                                            razorpayService.openCheckout(
                                              amount: remainingAmount, // ₹100
                                              razorpayKey:
                                                  AppConstants.razorpayLive,
                                              onSuccess: (response) {
                                                setState(() {
                                                  circularIndicator = true;
                                                });
                                                successPayment(
                                                    response.paymentId ?? "");
                                              },
                                              onFailure: (response) {
                                                setState(() {
                                                  circularIndicator = false;
                                                });
                                              },
                                              onExternalWallet: (response) {
                                                print(
                                                    "Wallet: ${response.walletName}");
                                              },
                                              description: 'Tour Screen',
                                            );
                                          } else if (naviGateRazorpay == 1) {
                                            showPaymentDialog(context);
                                          } else if (naviGateRazorpay == 3) {
                                            razorpayService.openCheckout(
                                              amount: remainingAmount, // ₹100
                                              razorpayKey:
                                                  AppConstants.razorpayLive,
                                              onSuccess: (response) {
                                                setState(() {
                                                  circularIndicator = true;
                                                });
                                                successPayment(
                                                    response.paymentId ?? '');
                                              },
                                              onFailure: (response) {
                                                setState(() {
                                                  circularIndicator = false;
                                                });
                                              },
                                              onExternalWallet: (response) {
                                                print(
                                                    "Wallet: ${response.walletName}");
                                              },
                                              description: 'Tour Screen',
                                            );
                                          }
                                        },
                                        child: Container(
                                          height: 45,
                                          margin: const EdgeInsets.all(5),
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(8.0),
                                            color: Colors.green,
                                          ),
                                          child: Center(
                                            child: Text(
                                              widget.translateEn == "en"
                                                  ? "Pay Now"
                                                  : "भुगतान करे",
                                              style: const TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                              : Row(
                                  children: [
                                    Expanded(
                                      child: GestureDetector(
                                        onTap: () {
                                          mergedArrayList.clear();
                                          previousPage();
                                        },
                                        child: Container(
                                          height: 45,
                                          margin: const EdgeInsets.all(5),
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(8.0),
                                            color: selectOrder == 0
                                                ? Colors.grey
                                                : Colors.orange,
                                          ),
                                          child: Center(
                                            child: Text(
                                              widget.translateEn == "en"
                                                  ? "Previous"
                                                  : "पिछला",
                                              style: const TextStyle(
                                                fontSize: 18,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: GestureDetector(
                                        onTap: () {
                                          // If you're on the info page and fields are empty, show a dialog
                                          setState(() {
                                            if (selectOrder == 1) {
                                              // Check if we're on the info page
                                              if (_selectedDate == null ||
                                                  _selectedDate!.isEmpty ||
                                                  _selectedTime == null ||
                                                  _selectedTime!.isEmpty ||
                                                  countryController
                                                      .text.isEmpty) {
                                                // Show dialog if any of the fields are empty
                                                BeautifulToast.show(
                                                  context,
                                                  widget.translateEn == "en"
                                                      ? "Form fields Required !"
                                                      : "फॉर्म फ़ील्ड आवश्यक!",
                                                  backgroundColor: Colors.red,
                                                  icon: Icons.error,
                                                );
                                              } else {
                                                // If fields are not empty, go to the next page
                                                mergedArrayList
                                                    .addAll(packageItems);
                                                mergedArrayList
                                                    .addAll(distanceArray);

                                                nextPage();
                                                // minusWalletTourPrice(finalPrice);
                                              }
                                            } else {
                                              // If we're not on the info page, just go to the next page
                                              nextPage();
                                            }
                                          });
                                        },
                                        child: Container(
                                          height: 45,
                                          margin: const EdgeInsets.all(5),
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(8.0),
                                            color: Colors.orange,
                                          ),
                                          child: Center(
                                            child: Text(
                                              widget.translateEn == "en"
                                                  ? "Next"
                                                  : "अगला",
                                              style: const TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                        ],
                      ))
                  : null),
    );
  }
}

Widget _buildRowWithIcon(BuildContext context,
    {required IconData icon,
    required String label,
    required VoidCallback onTap,
    required String content}) {
  return InkWell(
    onTap: onTap,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 5),
        Container(
          height: 50,
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            // color: Colors.grey.shade100,
            border: Border.all(color: Colors.orange),
          ),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Row(
              children: [
                Text(
                  content,
                  style: const TextStyle(
                    color: Colors.black,
                  ),
                ),
                const Spacer(),
                Icon(icon, color: Colors.orange, size: 28),
                const SizedBox(
                  width: 5,
                )
              ],
            ),
          ),
        ),
      ],
    ),
  );
}
