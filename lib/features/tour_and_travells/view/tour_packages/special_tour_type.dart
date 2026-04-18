import 'dart:convert';
import 'dart:math';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:mahakal/main.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:mahakal/features/tour_and_travells/model/success_amount_model.dart';
import 'package:mahakal/utill/app_constants.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../data/datasource/remote/http/httpClient.dart';
import '../../../../utill/razorpay_screen.dart';
import '../../../auth/controllers/auth_controller.dart';
import '../../../donation/ui_helper/custom_colors.dart';
import '../../../explore/payment_process_screen.dart';
import '../../../profile/controllers/profile_contrroller.dart';
import '../../Controller/fetch_coupon_controller.dart';
import '../../Controller/fetch_wallet_controller.dart';
import '../../Controller/success_touramount_controller.dart';
import '../../Controller/tour_lead_controller.dart';
import '../../model/city_details_model.dart';
import '../../model/distance_model.dart';
import '../../model/tour_availibility_model.dart';
import '../../widgets/ApplyCoupon.dart';
import '../../widgets/backhandler.dart';
import '../../widgets/cab_info_card.dart';
import '../../widgets/info_dialog.dart';
import '../../widgets/person_card_widget.dart';
import '../../widgets/showbeautifulltoast.dart';
import '../../widgets/total_amount_display.dart';

class SpecialTourType extends StatefulWidget {
  const SpecialTourType(
      {super.key,
      required this.services,
      required this.cabsquantity,
      required this.hotelList,
      required this.foodList,
      required this.tourId,
      required this.packageId,
      required this.packageAmount,
      required this.translateEn,
      required this.pickTime,
      required this.exDistance,
      required this.useDate,
      required this.isPersonUse,
      required this.tourGst,
      required this.transPortGst,
      required this.tourName,
      this.hotelTypeList,
      required this.locationName,
      required this.customizedType,
      required this.customizedDates,
      required this.extraTransportPrice,
      required this.pickLat,
      required this.pickLong,
      required this.tourDate});

  final List<String>? services;
  final List<HotelTypeList>? hotelTypeList;
  final List<CabList>? cabsquantity;
  final List<PackageList> hotelList;
  final List<PackageList> foodList;
  final String pickTime;
  final String pickLat;
  final String pickLong;
  final String tourDate;
  final String tourId;
  final String? packageId;
  final int packageAmount;
  final String translateEn;
  final int? exDistance;
  final String useDate;
  final int isPersonUse;
  final dynamic tourGst;
  final dynamic transPortGst;
  final String tourName;
  final String locationName;
  final List<String>? customizedDates;
  final String customizedType;
  final List<dynamic> extraTransportPrice;

  @override
  State<SpecialTourType> createState() => _SpecialTourTypeState();
}

class _SpecialTourTypeState extends State<SpecialTourType>
    with SingleTickerProviderStateMixin {
  final razorpayService = RazorpayPaymentService();
  final TextEditingController couponController = TextEditingController();
  final leadController =
      Provider.of<TourLeadController>(Get.context!, listen: false);
  final successAmountController =
      Provider.of<SuccessTourAmountController>(Get.context!, listen: false);
  final fetchCouponController =
      Provider.of<FetchCouponController>(Get.context!, listen: false);
  final walletController =
      Provider.of<FetchWalletController>(Get.context!, listen: false);

  //List<CityPickerModel> cityListModel = <CityPickerModel>[];
  //final List<int> quantity = List.generate(10, (index) => 0);
  //List<Map<String, dynamic>> items = [];

  String userId = "";
  String userNAME = "";
  String userEMAIL = "";
  String userPHONE = "";
  String userToken = "";
  String? currentSelectedTab;
  String? selectedPickAirport;
  String? finalSelectedDate;
  String? selectedDropAirport;
  DateTime? startDate;
  DateTime? endDate;

  double amtByWallet = 0.0;
  double walletPay = 0.0;
  double walletMinusAmount = 0.0;
  double remainingAmount = 0.0;
  double finalAmount = 0.0;
  double halfAmount = 0.0;

  int selectOrder = 0;
  int? successAmountStatus;
  int? naviGateRazorpay;
  int selectedCabQuantity = 0;
  int couponId = 0;
  int? personQuantity;
  int selectedIndex = -1;
  int selectedAmountIndex = 0;

  dynamic itemTotalAmount = 0;
  dynamic taxAmount = 0;
  dynamic amountAfterTax = 0;
  dynamic specificCabTotal = 0;
  dynamic specificFoodTotal = 0;
  dynamic specificHotelTotal = 0;
  dynamic selectedExPrice = "0";

  late List<int> hotelQuantity;
  late List<int> cabsQuantity;
  late dynamic finalPrice;
  late dynamic PackagePrice;
  late dynamic totalFinalTax;

  bool dateSelection = false;
  bool isCouponApplyed = false;
  bool circularIndicator = false;
  bool isCustomSelected = false; // state variable
  bool isPickFixedLocation = true; // Box 1 (default selected)
  bool isPickAirport = false; // Box 2
  bool isDropFixedLocation = true; // Box 3 (default selected)
  bool isDropAirport = false; // Box 4
  bool onlyPickUp = false;
  bool onlyDrop = false;
  bool both = false;

  final List<GlobalKey> itemKeys = [];
  List<Map<String, dynamic>> packageItems = [];
  List<Map<String, dynamic>> distanceArray = [];
  List<Map<String, dynamic>> mergedArrayList = [];
  List<int> selectedIndexes = [0];
  List<int> foodQuantity = [];
  List<int> cabFinalAmount = [];
  List<int> foodFinalAmount = [];
  List<int> hotelFinalAmount = [];
  List<PackageList> filteredHotelList = [];

  double selectedCabTotalAmount = 0;
  double couponAmount = 0;
  double amtAfterDis = 0;
  double totalExtraPrice = 0;
  double cabPrice = 0.0;
  dynamic cabId = "0";

  /// Next Page
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
      }
    }
  }

  /// Previous Page
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
      }
    }
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

    print("My Tax Amount is: ${taxAmount}");
    print("My Amount After Tax: ${amountAfterTax}");

    return {
      'taxAmount': taxAmount,
      'amountAfterTax': amountAfterTax,
    };
  }

  SuccessAmountModel? successAmountData;
  bool hasNonZeroQuantity(List<int> foodQuantity) {
    return foodQuantity.any((quantity) => quantity > 0);
  }

  /// AddPerson
  void addPersonQuantity(int index) {
    setState(() {
      // Reset all quantities to 0 except the selected one
      for (int i = 0; i < cabsQuantity.length; i++) {
        if (i != index) {
          cabsQuantity[i] = 0;
        }
      }

      cabFinalAmount.clear();
      for (int i = 0; i < widget.cabsquantity!.length; i++) {
        int currentPrice =
            int.tryParse(widget.cabsquantity![i].price ?? '0') ?? 0;
        cabFinalAmount.add(currentPrice);
      }

      // Set selected index quantity
      int minQuantity =
          int.tryParse(widget.cabsquantity![index].min ?? '1') ?? 1;
      cabsQuantity[index] = minQuantity;
      selectedCabQuantity = minQuantity;

      int currentPrice =
          int.tryParse(widget.cabsquantity![index].price ?? '0') ?? 0;
      cabFinalAmount[index] = currentPrice * minQuantity;
      calculateGst(cabFinalAmount[index], widget.tourGst);
      specificCabTotal = cabFinalAmount[index];
    });
  }

  void decreasePersonQuantity(int index, int currentPrice) {
    if (index < 0 || index >= cabsQuantity.length) return;

    // Get min quantity from cab data
    int minQuantity = int.tryParse(widget.cabsquantity?[index].min ?? '1') ?? 1;

    // Show toast if trying to go below min
    if (cabsQuantity[index] <= minQuantity) {
      BeautifulToast.show(
        context,
        "You must book at least ${widget.cabsquantity?[index].min} for this unit",
        backgroundColor: Colors.red.shade600,
        icon: Icons.warning_amber_rounded,
      );
      return;
    }

    // Normal -1 decrease
    cabsQuantity[index]--;
    cabFinalAmount[index] = currentPrice * cabsQuantity[index];
    calculateGst(cabFinalAmount[index], widget.tourGst);
    specificCabTotal = cabFinalAmount[index];
  }

  void increasePersonQuantity(int index, int currentPrice) {
    if (index < 0 || index >= cabsQuantity.length) return;

    // Get max from cab data
    int? maxQuantity = widget.cabsquantity?[index].max != null
        ? int.tryParse(widget.cabsquantity![index].max!)
        : null;

    // Show toast if trying to exceed max
    if (maxQuantity != null && cabsQuantity[index] >= maxQuantity) {
      BeautifulToast.show(
        context,
        "Maximum ${widget.cabsquantity?[index].max} units allowed",
        backgroundColor: Colors.orange.shade600,
        icon: Icons.info_outline,
      );
      return;
    }

    // Normal +1 increase
    cabsQuantity[index]++;
    cabFinalAmount[index] = currentPrice * cabsQuantity[index];
    calculateGst(cabFinalAmount[index], widget.tourGst);
    specificCabTotal = cabFinalAmount[index];
  }

  /// Add Cab Peron Quantity
  void addCabPersonQuantity(int index, int amount) {
    setState(() {
      // Reset all quantities to 0 except the selected one
      for (int i = 0; i < cabsQuantity.length; i++) {
        if (i != index) {
          cabsQuantity[i] = 0;
        }
      }
      cabId = widget.cabsquantity![index].cabId.toString();
      cabsQuantity[index] = 1; // Set selected item quantity to 1
      calculateCabPrice(index);
    });
  }

  void increaseCabPersonQuantity(int index, int resmainingSeat, int amount) {
    setState(() {
      if (cabsQuantity[index] < resmainingSeat) {
        cabsQuantity[index]++;
        selectedCabIndex = index; // Update selected cab
        cabId = widget.cabsquantity![index].cabId.toString();
        calculateCabPrice(index);
      } else {
        BeautifulToast.show(
          context,
          "Currently $resmainingSeat seat are available",
          backgroundColor: Colors.red.shade600,
          icon: Icons.event_seat,
        );
      }
    });
  }

  void decreaseCabPersonQuantity(int index, int amount) {
    setState(() {
      if (cabsQuantity[index] > 1) {
        cabsQuantity[index]--;
        cabId = widget.cabsquantity![index].cabId.toString();
        calculateCabPrice(index);
      }
    });
  }

  void calculateCabPrice(int cabIndex) {
    if (cabIndex < 0 || cabIndex >= widget.cabsquantity!.length) return;

    cabPrice =
        double.tryParse(widget.cabsquantity![cabIndex].price ?? '0') ?? 0.0;
    selectedCabQuantity = cabsQuantity[cabIndex];
    selectedCabTotalAmount =
        (cabPrice + widget.packageAmount) * selectedCabQuantity;

    addFoodItem(
        widget.cabsquantity![cabIndex].enCabName ?? '', // name
        selectedCabTotalAmount, // amount
        cabsQuantity[cabIndex], // quantity
        "Cab", // itemTitle (seats)
        widget.cabsquantity![cabIndex].image ?? '', // image
        "cab", // type
        widget.cabsquantity![cabIndex].cabId.toString(), // id
        widget.cabsquantity![cabIndex].seats ?? '', // seats
        "",
        "",
        "" // tax_price (default)
        );

    print(
        "Selected Cab: $cabIndex | Price: $cabPrice | Qty: $selectedCabQuantity  | All Total $selectedCabTotalAmount");
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
    dynamic tax_price,
  ) {
    setState(() {
      // Special handling for food items - don't remove existing ones
      if (itemTitle != "Food") {
        // Remove existing items of the same type (for non-food items)
        packageItems.removeWhere((item) => item['title'] == itemTitle);
      } else {
        // For food items, check if this exact item already exists
        int existingIndex = packageItems.indexWhere(
            (item) => item['title'] == itemTitle && item['id'] == id);

        if (existingIndex != -1) {
          // Update existing food item instead of adding new one
          packageItems[existingIndex] = {
            'name': name,
            'price': amount,
            'qty': quantity,
            'image': image,
            'id': id,
            "seats": seats,
            "pprice": pprice,
            "tax": tax,
            "tax_price": tax_price,
            "type": type,
            "title": itemTitle
          };
          return;
        }
      }

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
        "tax_price": tax_price,
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
        "tax_price": tax_price,
        "type": type,
        "title": itemTitle
      });
    });
  }

  /// Remove/Update Item from Package List by Title
  void updateItemQuantity(String itemTitle, int amount, int quantity,
      {String? itemId}) {
    setState(() {
      // For food items, we need to find by both title AND ID
      int existingIndex = packageItems.indexWhere((item) =>
          item['title'] == itemTitle &&
          (itemTitle != "Food" || item['id'] == itemId));

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

  DistanceModel? distanceModel;

  void sumTotal() {
    finalPrice = 0.0;
    PackagePrice = 0.0;
    totalFinalTax = 0.0;
    for (var item in packageItems) {
      final price = item["price"];

      if (price is List<int>) {
        PackagePrice += price.fold(0, (sum, p) => sum + p);
      } else if (price is int) {
        PackagePrice += price;
      } else if (price is double) {
        PackagePrice += price;
      }
    }

    PackagePrice += totalExtraPrice;

    calculateGst(PackagePrice, widget.tourGst);

    finalPrice = PackagePrice + taxAmount;
    totalFinalTax = taxAmount;
    halfAmount = finalPrice / 2;

    walletMinusAmount = max(
        walletPay -
            (isCouponApplyed
                ? amtAfterDis
                : (selectedAmountIndex == 0 ? finalPrice : halfAmount)),
        0);
    amtByWallet = walletPay - walletMinusAmount;

    /// Logic for cutting amt from wallet
    if (walletPay >=
        (isCouponApplyed
            ? amtAfterDis
            : (selectedAmountIndex == 0 ? finalPrice : halfAmount))) {
      remainingAmount = 0;
    } else {
      remainingAmount = (isCouponApplyed
              ? amtAfterDis
              : (selectedAmountIndex == 0 ? finalPrice : halfAmount)) -
          walletPay;
    }

    /// Logic for Payment Status (Wallet status , 1 or 0)
    if (walletPay >=
        (isCouponApplyed
            ? amtAfterDis
            : (selectedAmountIndex == 0 ? finalPrice : halfAmount))) {
      successAmountStatus = 1;
      naviGateRazorpay = 1;
    } else if (walletPay > 0 &&
        walletPay <
            (isCouponApplyed
                ? amtAfterDis
                : (selectedAmountIndex == 0 ? finalPrice : halfAmount))) {
      successAmountStatus = 1;
      naviGateRazorpay = 2;
    } else {
      successAmountStatus = 0;
      naviGateRazorpay = 3;
    }
  }

  void sumFoodAndHotel() {
    specificHotelTotal = 0;
    specificFoodTotal = 0;

    for (int i = 0; i < widget.foodList.length; i++) {
      int currentPrice = int.tryParse("${widget.foodList[i].price}") ?? 0;

      // Ensure foodFinalAmount has correct length
      if (i >= foodFinalAmount.length) {
        foodFinalAmount.add(currentPrice);
      } else {
        foodFinalAmount[i] = currentPrice;
      }

      // Add total for this item to specificFoodTotal
      specificFoodTotal += foodFinalAmount[i] * foodQuantity[i];
    }

    for (int i = 0; i < widget.hotelList.length; i++) {
      int currentPrice = int.tryParse("${widget.hotelList[i].price}") ?? 0;

      // Ensure foodFinalAmount has correct length
      if (i >= hotelFinalAmount.length) {
        hotelFinalAmount.add(currentPrice);
      } else {
        hotelFinalAmount[i] = currentPrice;
      }

      // Add total for this item to specificFoodTotal
      specificHotelTotal += hotelFinalAmount[i] * hotelQuantity[i];
    }
  }

  /// Place Tour Order
  void successPayment(String trxId) {
    final leadId = leadController.leadGenerateModel?.data?.insertId;

    print("successPayment() called");
    print("My Tour Packages: ${mergedArrayList}");
    print("leadGenerateModel: ${leadController.leadGenerateModel}");
    print("leadGenerateModel.data: ${leadController.leadGenerateModel?.data}");
    print("leadId: $leadId");

    if (leadId == null) {
      print("❌ ERROR: leadId is null! Aborting API call.");
      return;
    }

    successAmountController.successTourAmount(
        tourId: "${widget.tourId}",
        packageId: "${widget.packageId}",
        paymentAmount:
            "${isCouponApplyed ? amtAfterDis : selectedAmountIndex == 0 ? finalPrice : halfAmount}",
        qty: "${personQuantity}",
        pickupAddress: "${widget.locationName}",
        pickupDate: widget.customizedType == "0"
            ? "${startDate}"
            : "${DateFormat("yyyy-MM-dd").format(DateFormat("dd-MM-yyyy").parse("$finalSelectedDate}"))}",
        pickupTime: "${widget.pickTime}",
        pickupLat: "${widget.pickLat}",
        pickupLong: "${widget.pickLong}",
        useDate: "${widget.useDate}",
        transactionId: "$trxId",
        bookingPackage: mergedArrayList,
        walletType: "$successAmountStatus",
        onlinePay: "$remainingAmount",
        couponAmount: "$couponAmount",
        couponId: "$couponId",
        leadId: "$leadId", // This will now always be non-null
        context: context,
        partPayment: selectedAmountIndex == 0 ? "full" : "part");
  }

  /// Apply Coupon
  Future<void> applyCoupon(String code, int finalPackageAmount) async {
    final response = await http.post(
      Uri.parse("${AppConstants.baseUrl}${AppConstants.tourApplyCouponUrl}"),
      headers: {
        'Authorization': 'Bearer $userToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        "user_id": userId,
        "coupon_code": code,
        "amount": finalPackageAmount,
      }),
    );

    print("Response Code: ${response.statusCode}");
    print("Response Body: ${response.body}");

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);

      if (data["status"] == 1) {
        // Update UI
        setState(() {
          couponAmount = double.parse(data["data"]["coupon_amount"].toString());
          amtAfterDis = double.parse(data["data"]["final_amount"].toString());
          couponId = data["data"]["coupon_id"];
          isCouponApplyed = true;
          walletMinusAmount = 0;
          walletMinusAmount = max(walletPay - amtAfterDis, 0);
          // finalAmount = (walletPay - amtAfterDis.toInt()).abs();
        });

        Navigator.pop(context);
        // ✅ Move Snackbar outside setState()
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
  }

  void showCouponSheet() {
    showCouponBottomSheet(
      context: context,
      couponController: couponController,
      couponModelList: fetchCouponController.couponlist,
      selectedCabTotalAmount: "$finalPrice",
      onApplyCoupon: (code, amount) {
        applyCoupon(couponController.text, finalPrice.toInt());
      },
      onCouponTap: (String code, String couponType) {},
    );
  }

  /// Payment Confirmation Dialog
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

  String _getUnitLabel(dynamic title) {
    if (title == "Per Head" || title == "Hotel" || title == "Food") {
      return "Person";
    } else if (title == "Cab") {
      return "Cab";
    } else {
      return "";
    }
  }

  void getSelectedPrice() {
    if (widget.isPersonUse == 0) {
      return; // Don't proceed if isPersonUse is not 1
    }

    debugPrint("Person Quantity: $personQuantity");
    debugPrint("Price Data: ${widget.extraTransportPrice}");

    String? newPrice;
    String? routeTypeUser;
    String selectedPrice = "";

    // Check which condition is active
    if (onlyPickUp) {
      routeTypeUser = "pickup";
    } else if (onlyDrop) {
      routeTypeUser = "drop";
    } else if (both) {
      routeTypeUser = "both";
    } else {
      // Both fixed locations selected - free
      setState(() {
        totalExtraPrice = 0;
        selectedExPrice = 0;
      });
      return;
    }

    for (var priceRange in widget.extraTransportPrice) {
      dynamic min = priceRange.min;
      dynamic max = priceRange.max;

      if (personQuantity != null &&
          personQuantity! >= int.parse(min) &&
          personQuantity! <= int.parse(max)) {
        if (onlyPickUp) {
          newPrice = "${priceRange.pick}";
        } else if (onlyDrop) {
          newPrice = "${priceRange.drop}";
        } else if (both) {
          newPrice = "${priceRange.both}";
        }
        break;
      }
    }

    setState(() {
      selectedPrice = newPrice ?? "0";
      selectedExPrice = (int.tryParse(newPrice ?? "0") ?? 0);
      totalExtraPrice = selectedExPrice.toDouble();
    });

    calculateGst(selectedExPrice, widget.transPortGst);
    addDistanceArray(
      routeType: routeTypeUser,
      exDistancePrice: '${selectedExPrice.toStringAsFixed(1)}',
      exDistanceQty: '${personQuantity}',
    );

    print("MY PRICE $selectedExPrice");
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

  List<HotelTypeList> hotelTabs = [];
  List<PackageList> hotelList = [];
  int selectedTabIndex = 0;
  late TabController _tabController;

  int? selectedCabIndex;
  List<int> remainingCabSeats = [];

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();

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
    userToken =
        Provider.of<AuthController>(Get.context!, listen: false).getUserToken();
    fetchCouponController.fetchCoupon(
        type: "tour", couponUrl: "${AppConstants.tourCouponUrl}");

    // Initialize keys for each service and one extra for "Payment".
    for (int i = 0; i < widget.services!.length + 2; i++) {
      itemKeys.add(GlobalKey());
    }

    cabPrice = double.tryParse(widget.cabsquantity![0].price ?? "") ?? 0.0;
    cabId = widget.cabsquantity![0].cabId;

    hotelQuantity = List.generate(widget.hotelList.length, (index) => 0);
    foodQuantity = List.generate(widget.foodList.length, (index) => 0);
    cabsQuantity = List.generate(
      widget.cabsquantity!.length,
      (index) {
        if (index == 0) {
          final minStr = widget.cabsquantity![index].min;
          final isValid = minStr != null && minStr.toString().trim().isNotEmpty;
          return isValid ? int.tryParse(minStr.toString()) ?? 1 : 1;
        }
        return 0;
      },
    );

    filteredHotelList =
        widget.hotelList.where((item) => item.includedStatus == 1).toList();
    print("Filtered Hotel List: ${filteredHotelList.length}");

    hotelList = widget.hotelList ?? [];
    if (widget.isPersonUse == 1) {
      addPersonQuantity(0);
      calculateGst(cabFinalAmount[0], widget.tourGst);
      addFoodItem(
        'Group of', // name
        cabFinalAmount[0], // amount
        cabsQuantity[0], // quantity
        "Per Head", // itemTitle
        '', // image
        "per_head", // type
        widget.cabsquantity![0].cabId.toString(), // id
        '', // seats
        "0",
        "0",
        "0",
      );
      syncIncludedFoodsWithCabQty(0);
    } else {
      _initializeCabData();
    }

    filterTabs();
    _tabController = TabController(length: hotelTabs.length, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        setState(() {
          selectedTabIndex = _tabController.index;
        });
      }
    });
  }

  TourAvailibilityModel? tourDateAwailable;

  Future<void> fetchDatesAvailiblity() async {
    Map<String, dynamic> data = {
      "tour_id": "${widget.tourId}",
      "cab_id": "${cabId}"
    };

    setState(() {
      _isLoading = true;
    });

    try {
      final res = await HttpService().postApi(AppConstants.tourDatesUrl, data);
      print("Tour Dates $res");

      if (res != null && res["status"] == 1) {
        final datesResponse = TourAvailibilityModel.fromJson(res);

        setState(() {
          tourDateAwailable = datesResponse;
          _isLoading = false;
        });

        print("Tour Dates:${tourDateAwailable?.data}");
      }
    } catch (e) {
      print("Error fetching Tour Dates: $e");
      setState(() {
        _isLoading = false;
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void filterTabs() {
    hotelTabs = (widget.hotelTypeList ?? []).where((tab) {
      return hotelList.any((pkg) =>
          pkg.hotelType.toString() == tab.hotelType.toString() &&
          pkg.includedStatus != 1);
    }).toList();
    print("Hotel Tabs: ${hotelTabs.length}");
  }

  int parseDynamicToInt(dynamic value) {
    if (value is int) return value; // If already int, return as is
    if (value is String)
      return int.tryParse(value) ?? 0; // Convert String to int safely
    return 0; // Default fallback if null or other types
  }

  void _initializeCabData() {
    // Initialize remaining seats and quantities
    remainingCabSeats = widget.cabsquantity!.map((cab) {
      return parseDynamicToInt(cab.totalSeats) -
          parseDynamicToInt(cab.totalBookingSeats);
    }).toList();

    cabsQuantity = List.filled(widget.cabsquantity!.length, 0);

    // Find first available cab
    selectedCabIndex = remainingCabSeats.indexWhere((seats) => seats > 0);
    if (selectedCabIndex != -1) {
      cabsQuantity[selectedCabIndex!] = 1; // Select 1 cab by default
      calculateCabPrice(selectedCabIndex!);
      fetchDatesAvailiblity();
    }
  }

  void syncIncludedFoodsWithCabQty(int index) {
    final int cabQty = (cabsQuantity.isNotEmpty ? cabsQuantity[index] : 1);

    print("Cab for food $cabQty");

    for (var i = 0; i < widget.foodList.length; i++) {
      final food = widget.foodList[i];

      if (food.includedStatus == 1) {
        // foodQuantity  amount  cabQty  overwrite
        if (i < foodQuantity.length) {
          foodQuantity[i] = cabQty;
        }

        // addFoodItem
        addFoodItem(
          food.enPackageName ?? '',
          00,
          cabQty,
          "Food",
          food.image ?? '',
          "other",
          food.packageId.toString(),
          '',
          00,
          00,
          00,
        );
      }
    }

    if (filteredHotelList.isNotEmpty)
      addFoodItem(
        filteredHotelList[0].enPackageName ?? '',
        00,
        "${cabQty}",
        "Hotel",
        filteredHotelList[0].image ?? '',
        "other",
        filteredHotelList[0].packageId.toString(),
        '',
        00,
        00,
        00,
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

  String _getBookingTitle(String type) {
    switch (type) {
      case "0":
        return "Your Tour Date";
      case "1":
        return "Select Your Weekly Booking Date";
      case "2":
        return "Select Your Monthly Booking Date";
      case "3":
        return "Select Your Yearly Booking Date";
      default:
        return "Select Your Booking Date";
    }
  }

  String formatDateRangeWithTo(String dateRange) {
    try {
      if (dateRange.isEmpty || !dateRange.contains("-")) return dateRange;

      final dates = dateRange.split(" - ");
      if (dates.length != 2) return dateRange;

      final startDateStr = dates[0].trim();
      final endDateStr = dates[1].trim();

      startDate = DateTime.parse(startDateStr);
      endDate = DateTime.parse(endDateStr);

      // Format: 09 Jan 2026 To 11 Jan 2026
      final startFormatted = DateFormat('dd MMM yyyy').format(startDate!);
      final endFormatted = DateFormat('dd MMM yyyy').format(endDate!);

      return "$startFormatted To $endFormatted";
    } catch (e) {
      return dateRange;
    }
  }

  // Helper functions
  Color _getDayColor(String day) {
    final now = DateTime.now();
    final today = DateFormat('EEEE').format(now);
    return today == day ? Colors.blue.shade100 : Colors.white;
  }

  Color _getDayTextColor(String day) {
    final now = DateTime.now();
    final today = DateFormat('EEEE').format(now);
    return today == day ? Colors.blue.shade800 : Colors.grey.shade800;
  }

  String _getTranslatedDay(String englishDay) {
    if (widget.translateEn != "en") {
      final hindiDays = {
        'Monday': 'सोमवार',
        'Tuesday': 'मंगलवार',
        'Wednesday': 'बुधवार',
        'Thursday': 'गुरुवार',
        'Friday': 'शुक्रवार',
        'Saturday': 'शनिवार',
        'Sunday': 'रविवार',
      };
      return hindiDays[englishDay] ?? englishDay;
    }
    return englishDay;
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var screenWidth = MediaQuery.of(context).size.width;
    sumFoodAndHotel();
    sumTotal();
    return WillPopScope(
      onWillPop: () {
        return BackHandler.handle(
          context: context,
          showDialog: selectOrder == widget.services!.length + 1,
        );
      },
      child: circularIndicator
          ? MahakalPaymentProcessing()
          : Scaffold(
              backgroundColor: Colors.white,
              appBar: AppBar(
                leading: GestureDetector(
                  onTap: () {
                    BackHandler.handle(
                      context: context,
                      showDialog: selectOrder == widget.services!.length + 1,
                    );
                  },
                  child: const Icon(Icons.arrow_back_ios),
                ),
                backgroundColor: Colors.white,
                title: Text(
                  "${widget.tourName}",
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
                            itemCount: widget.services!.length + 2,
                            itemBuilder: (context, index) {
                              if (index < widget.services!.length) {
                                final serviceName = widget.services![index];
                                return Row(
                                  key: itemKeys[index],
                                  children: [
                                    Container(
                                      height: 40,
                                      width: 40,
                                      decoration: BoxDecoration(
                                        color: selectedIndexes.contains(index)
                                            ? Colors.grey.shade400
                                            : Colors.deepOrange
                                                .withOpacity(0.07),
                                        borderRadius: BorderRadius.circular(5),
                                      ),
                                      child: Center(
                                          child: serviceName == "transport"
                                              ? (selectedIndexes.contains(index)
                                                  ? ClipRRect(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              5),
                                                      child: Image.asset(
                                                          "assets/animated/vehicle_animation.gif"),
                                                    )
                                                  : Icon(
                                                      Icons.two_wheeler,
                                                      color: Colors
                                                          .purple.shade400,
                                                      size: 25,
                                                    ))
                                              : serviceName == "foods"
                                                  ? (selectedIndexes
                                                          .contains(index)
                                                      ? hasNonZeroQuantity(
                                                                  foodQuantity) ==
                                                              false
                                                          ? const Icon(
                                                              Icons.restaurant,
                                                              color: Colors
                                                                  .white, // Default color if quantity is not 0
                                                              size: 25,
                                                            )
                                                          : ClipRRect(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          5),
                                                              child: Image.asset(
                                                                  "assets/animated/food_animation.gif"),
                                                            )
                                                      : const Icon(
                                                          Icons.restaurant,
                                                          color: Colors
                                                              .blue, // Default color if quantity is not 0
                                                          size: 25,
                                                        ))
                                                  : serviceName == "hotel"
                                                      ? (selectedIndexes
                                                              .contains(index)
                                                          ? hasNonZeroQuantity(
                                                                      hotelQuantity) ==
                                                                  false
                                                              ? const Icon(
                                                                  Icons.hotel,
                                                                  color: Colors
                                                                      .white, // Default color if quantity is not 0
                                                                  size: 25,
                                                                )
                                                              : ClipRRect(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              5),
                                                                  child: Image
                                                                      .asset(
                                                                          "assets/animated/hotel_animation.gif"),
                                                                )
                                                          : const Icon(
                                                              Icons.hotel,
                                                              color: Colors.red,
                                                              size: 25,
                                                            ))
                                                      : Icon(
                                                          Icons.two_wheeler,
                                                          color: selectedIndexes
                                                                  .contains(
                                                                      index)
                                                              ? Colors.white
                                                              : Colors.red,
                                                          size: 25,
                                                        )),
                                    ),
                                    if (index <=
                                        2) // Show separator for the first two items.
                                      Container(
                                        height: 1.5,
                                        width: 40,
                                        color: selectedIndexes.contains(index)
                                            ? Colors.orange
                                            : Colors.grey,
                                      ),
                                  ],
                                );
                              } else if (index == widget.services!.length) {
                                // Render the static "Payment" tab.
                                return Row(
                                  children: [
                                    Container(
                                      height: 40,
                                      width: 40,
                                      decoration: BoxDecoration(
                                        color: selectedIndexes.contains(index)
                                            ? Colors.deepOrange
                                            : Colors.deepOrange
                                                .withOpacity(0.07),
                                        borderRadius: BorderRadius.circular(5),
                                      ),
                                      child: Center(
                                        child: selectedIndexes.contains(index)
                                            ? ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(5),
                                                child: Image.asset(
                                                    "assets/animated/info_animation.gif"))
                                            : const Icon(
                                                Icons.perm_device_info,
                                                color: Colors.purple,
                                              ),
                                      ),
                                    ),
                                    if (index <=
                                        3) // Show separator for the first two items.
                                      Container(
                                        height: 1.5,
                                        width: 40,
                                        color: selectedIndexes.contains(index)
                                            ? Colors.orange
                                            : Colors.grey,
                                      ),
                                  ],
                                );
                              } else {
                                // Render the new static tab.
                                return Container(
                                  height: 40,
                                  width: 40,
                                  decoration: BoxDecoration(
                                    color: selectedIndexes.contains(index)
                                        ? Colors.deepOrange
                                        : Colors.deepOrange.withOpacity(0.07),
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  child: Center(
                                    child: selectedIndexes.contains(index)
                                        ? ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(5),
                                            child: Image.asset(
                                                "assets/animated/payment_animation.gif"))
                                        : const Icon(
                                            Icons.currency_rupee,
                                            color: Colors.green,
                                          ),
                                  ),
                                );
                              }
                            },
                          )),
                    ]),
                  ),
                ),
              ),
              body: IndexedStack(
                index: selectOrder,
                children: [
                  ...widget.services!.map((service) {
                    if (service == "transport") {
                      return widget.isPersonUse == 1

                          /// Per Person Group
                          ? Padding(
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
                                                begin: Alignment
                                                    .topLeft, // Starting point of the gradient
                                                end: Alignment
                                                    .bottomRight, // Ending point of the gradient
                                              ),
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                            child: Text(
                                          widget.translateEn == "en"
                                              ? 'Select Group'
                                              : "Group का चयन करें",
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
                                              begin: Alignment
                                                  .topLeft, // Starting point of the gradient
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
                                      physics: const BouncingScrollPhysics(),
                                      itemBuilder: (context, index) {
                                        // Calculate prices (optimize outside builder if possible)
                                        for (int i = 0;
                                            i < widget.cabsquantity!.length;
                                            i++) {
                                          int currentPrice = int.tryParse(widget
                                                      .cabsquantity![i].price ??
                                                  '0') ??
                                              0;
                                          cabFinalAmount.add(currentPrice);
                                        }
                                        return PersonCardWidget(
                                          quantity: cabsQuantity[index],
                                          minGroup:
                                              widget.cabsquantity![index].min ??
                                                  "",
                                          maxGroup:
                                              widget.cabsquantity![index].max ??
                                                  "",
                                          price:
                                              "${widget.cabsquantity![index].price}",
                                          finalAmount: cabFinalAmount[index],
                                          onAddPressed: () {
                                            setState(() {
                                              addPersonQuantity(index);
                                              addFoodItem(
                                                'Group of',
                                                cabFinalAmount[index],
                                                cabsQuantity[index],
                                                "Per Head",
                                                '',
                                                "per_head",
                                                widget
                                                    .cabsquantity![index].cabId
                                                    .toString(),
                                                "",
                                                "0",
                                                "0",
                                                "0",
                                              );
                                            });
                                            syncIncludedFoodsWithCabQty(index);
                                          },
                                          onIncreasePressed: () {
                                            setState(() {
                                              increasePersonQuantity(
                                                  index,
                                                  int.parse(
                                                      "${widget.cabsquantity![index].price}"));
                                              addFoodItem(
                                                'Group of',
                                                cabFinalAmount[index],
                                                cabsQuantity[index],
                                                "Per Head",
                                                '',
                                                "per_head",
                                                widget
                                                    .cabsquantity![index].cabId
                                                    .toString(),
                                                "",
                                                "0",
                                                "0",
                                                "0",
                                              );
                                            });
                                            syncIncludedFoodsWithCabQty(index);
                                          },
                                          onDecreasePressed: () {
                                            setState(() {
                                              if (cabsQuantity[index] > 1) {
                                                decreasePersonQuantity(
                                                    index,
                                                    int.parse(
                                                        "${widget.cabsquantity![index].price}"));
                                                updateItemQuantity(
                                                  "Per Head",
                                                  int.tryParse(
                                                          "${cabFinalAmount[index]}") ??
                                                      0,
                                                  cabsQuantity[index],
                                                );
                                              } else {
                                                // Optional: showToast("Minimum 1 person required");
                                              }
                                            });
                                            syncIncludedFoodsWithCabQty(index);
                                          },
                                          onInfoTap: () {
                                            InfoDialog.show(
                                              context: context,
                                              description:
                                                  widget.translateEn == "en"
                                                      ? widget
                                                          .cabsquantity![index]
                                                          .enDescription
                                                      : widget
                                                          .cabsquantity![index]
                                                          .hiDescription,
                                              languageCode: widget.translateEn,
                                            );
                                          },
                                          isInfoView: widget
                                              .cabsquantity![index]
                                              .hiDescription,
                                        );
                                      },
                                    ),
                                    const SizedBox(
                                      height: 80,
                                    )
                                  ],
                                ),
                              ),
                            )

                          /// Cab Wise
                          : Padding(
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
                                                begin: Alignment
                                                    .topLeft, // Starting point of the gradient
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
                                              begin: Alignment
                                                  .topLeft, // Starting point of the gradient
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
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      itemBuilder: (context, index) {
                                        double cabsPackageAmount = (double.parse(
                                                "${widget.cabsquantity![index].price}") +
                                            widget.packageAmount);
                                        return Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 10, vertical: 10),
                                          margin: const EdgeInsets.symmetric(
                                              vertical: 8),
                                          decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              border: Border.all(
                                                  color: Colors.grey.shade300),
                                              color: Colors.white,
                                              boxShadow: [
                                                BoxShadow(
                                                    color: Colors.grey.shade400,
                                                    blurRadius: 10,
                                                    spreadRadius: 1)
                                              ]),
                                          child: Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: [
                                                Expanded(
                                                  flex: 0,
                                                  child: Column(
                                                    children: [
                                                      Container(
                                                          padding:
                                                              const EdgeInsets
                                                                  .only(top: 5),
                                                          height: 80,
                                                          width: 120,
                                                          decoration:
                                                              BoxDecoration(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        8),
                                                            color: Colors
                                                                .grey.shade300,
                                                            border: Border.all(
                                                                color: Colors
                                                                    .grey
                                                                    .shade300),
                                                            image:
                                                                DecorationImage(
                                                              image: CachedNetworkImageProvider(widget
                                                                      .cabsquantity![
                                                                          index]
                                                                      .image ??
                                                                  ''),
                                                              fit: BoxFit.fill,
                                                            ),
                                                          )),
                                                      const SizedBox(
                                                        height: 5,
                                                      ),
                                                      if (cabsQuantity[index] ==
                                                          0)
                                                        const Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .only(
                                                                  left: 8.0),
                                                          child: Text(
                                                            "₹000.0",
                                                            style: const TextStyle(
                                                                fontSize: 20,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                fontFamily:
                                                                    'Roboto',
                                                                color: Colors
                                                                    .grey),
                                                          ),
                                                        )
                                                      else
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .only(
                                                                  left: 8.0),
                                                          child: Text(
                                                            "₹${cabsPackageAmount * cabsQuantity[index]}",
                                                            style: const TextStyle(
                                                                fontSize: 20,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                fontFamily:
                                                                    'Roboto',
                                                                color:
                                                                    Colors.red),
                                                          ),
                                                        ),
                                                    ],
                                                  ),
                                                ),
                                                const SizedBox(
                                                  width: 6,
                                                ),
                                                Expanded(
                                                  flex: 1,
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .only(
                                                                left: 8.0),
                                                        child: Text(
                                                          widget.translateEn ==
                                                                  "en"
                                                              ? widget
                                                                      .cabsquantity![
                                                                          index]
                                                                      .enCabName ??
                                                                  ''
                                                              : widget
                                                                      .cabsquantity![
                                                                          index]
                                                                      .hiCabName ??
                                                                  '',
                                                          style: const TextStyle(
                                                              fontSize: 20,
                                                              fontFamily:
                                                                  'Roboto',
                                                              color:
                                                                  Colors.black,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500,
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis),
                                                          maxLines: 1,
                                                        ),
                                                      ),
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .only(
                                                                left: 8.0),
                                                        child: Text(
                                                          widget.translateEn ==
                                                                  "en"
                                                              ? "Total Vehicle: ${widget.cabsquantity![index].totalSeatsMessage}"
                                                              : "कुल वाहन:${widget.cabsquantity![index].totalSeatsMessage}",
                                                          style: const TextStyle(
                                                              fontSize: 16,
                                                              fontFamily:
                                                                  'Roboto',
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w400,
                                                              color:
                                                                  Colors.black,
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis),
                                                          maxLines: 1,
                                                        ),
                                                      ),
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .only(
                                                                left: 8.0),
                                                        child: Text(
                                                          widget.translateEn ==
                                                                  "en"
                                                              ? "Total Seat: ${widget.cabsquantity![index].totalSeatsMessage} : ${widget.cabsquantity![index].totalSeats}"
                                                              : "कुल सीट:${widget.cabsquantity![index].totalSeats}",
                                                          style: const TextStyle(
                                                              fontSize: 16,
                                                              fontFamily:
                                                                  'Roboto',
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w400,
                                                              color:
                                                                  Colors.black,
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis),
                                                          maxLines: 1,
                                                        ),
                                                      ),
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .only(
                                                                left: 8.0),
                                                        child: Text(
                                                          widget.translateEn ==
                                                                  "en"
                                                              ? "Remaining Seat: ${remainingCabSeats[index]}"
                                                              : "शेष सीट: ${remainingCabSeats[index]}",
                                                          style: const TextStyle(
                                                              fontSize: 16,
                                                              fontFamily:
                                                                  'Roboto',
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w400,
                                                              color:
                                                                  Colors.black,
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis),
                                                          maxLines: 1,
                                                        ),
                                                      ),
                                                      const SizedBox(
                                                        height: 5,
                                                      ),

                                                      // Add Button
                                                      Row(
                                                        children: [
                                                          const Spacer(),
                                                          remainingCabSeats[index] ==
                                                                      null ||
                                                                  remainingCabSeats[
                                                                          index] <=
                                                                      0
                                                              ? Container(
                                                                  height: 35,
                                                                  width: 100,
                                                                  decoration: BoxDecoration(
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              4),
                                                                      border: Border.all(
                                                                          color: Colors
                                                                              .grey
                                                                              .shade300),
                                                                      color: Colors
                                                                          .red),
                                                                  child: Center(
                                                                    child: Text(
                                                                      widget.translateEn ==
                                                                              "en"
                                                                          ? "Seat Full"
                                                                          : "Seat Full",
                                                                      style: const TextStyle(
                                                                          fontSize:
                                                                              18,
                                                                          fontWeight: FontWeight
                                                                              .w700,
                                                                          fontFamily:
                                                                              'Roboto',
                                                                          color:
                                                                              Colors.white),
                                                                    ),
                                                                  ))
                                                              : Row(
                                                                  children: [
                                                                    if (cabsQuantity[
                                                                            index] ==
                                                                        0)
                                                                      InkWell(
                                                                        onTap:
                                                                            () {
                                                                          setState(
                                                                              () {
                                                                            addCabPersonQuantity(index,
                                                                                cabsPackageAmount.toInt());
                                                                          });
                                                                        },
                                                                        child: Container(
                                                                            height: 35,
                                                                            width: 100,
                                                                            decoration: BoxDecoration(borderRadius: BorderRadius.circular(4), border: Border.all(color: Colors.grey.shade300), color: Colors.orange),
                                                                            child: Center(
                                                                              child: Text(
                                                                                widget.translateEn == "en" ? "Add" : "जोड़ें",
                                                                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, fontFamily: 'Roboto', color: Colors.white),
                                                                              ),
                                                                            )),
                                                                      )
                                                                    else
                                                                      Row(
                                                                          children: [
                                                                            Container(
                                                                              height: 35,
                                                                              width: 30,
                                                                              decoration: BoxDecoration(borderRadius: const BorderRadius.only(topLeft: Radius.circular(4), bottomLeft: Radius.circular(4)), border: Border.all(color: Colors.orange)),
                                                                              child: GestureDetector(
                                                                                  onTap: () {
                                                                                    setState(() {
                                                                                      if (cabsQuantity[index] == 1) {
                                                                                        print("decreased");
                                                                                      } else {
                                                                                        decreaseCabPersonQuantity(index, cabsPackageAmount.toInt());
                                                                                      }
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
                                                                              width: 40,
                                                                              decoration: BoxDecoration(border: Border.all(color: Colors.orange), color: Colors.orange),
                                                                              child: Center(
                                                                                  child: Text(
                                                                                "${cabsQuantity[index]}",
                                                                                style: const TextStyle(color: Colors.white, fontSize: 20),
                                                                              )),
                                                                            ),
                                                                            Container(
                                                                              height: 35,
                                                                              width: 30,
                                                                              decoration: BoxDecoration(borderRadius: const BorderRadius.only(topRight: Radius.circular(4), bottomRight: Radius.circular(4)), border: Border.all(color: Colors.orange)),
                                                                              child: GestureDetector(
                                                                                  onTap: () {
                                                                                    setState(() {
                                                                                      increaseCabPersonQuantity(index, remainingCabSeats[index].toInt(), cabsPackageAmount.toInt());
                                                                                    });
                                                                                  },
                                                                                  child: const Icon(
                                                                                    Icons.add,
                                                                                    size: 20,
                                                                                  )),
                                                                            ),
                                                                          ]),
                                                                  ],
                                                                )
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                InkWell(
                                                    onTap: () {
                                                      showDialog(
                                                        useSafeArea: false,
                                                        barrierDismissible:
                                                            true,
                                                        traversalEdgeBehavior:
                                                            TraversalEdgeBehavior
                                                                .leaveFlutterView,
                                                        context: context,
                                                        builder: (BuildContext
                                                            context) {
                                                          return AlertDialog(
                                                            alignment: Alignment
                                                                .bottomCenter,
                                                            backgroundColor:
                                                                Colors
                                                                    .transparent,
                                                            elevation: 0,
                                                            shadowColor: Colors
                                                                .transparent,
                                                            shape: RoundedRectangleBorder(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            15)),
                                                            contentPadding:
                                                                EdgeInsets.zero,
                                                            clipBehavior:
                                                                Clip.hardEdge,
                                                            insetPadding:
                                                                const EdgeInsets
                                                                    .only(
                                                                    bottom: 20,
                                                                    left: 15,
                                                                    right: 15),
                                                            content:
                                                                SingleChildScrollView(
                                                              child: Column(
                                                                mainAxisSize:
                                                                    MainAxisSize
                                                                        .min,
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .end,
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .end,
                                                                children: [
                                                                  Material(
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            10),
                                                                    color: Colors
                                                                        .white,
                                                                    child:
                                                                        Padding(
                                                                      padding: const EdgeInsets
                                                                          .symmetric(
                                                                          vertical:
                                                                              10,
                                                                          horizontal:
                                                                              15),
                                                                      child:
                                                                          Text(
                                                                        "hELOO",
                                                                        //HtmlParser.parseHTML("${widget.translateEn == "en" ? widget.cabsquantity![index].enDescription : widget.cabsquantity![index].hiDescription}").text,
                                                                        style: const TextStyle(
                                                                            fontSize:
                                                                                20),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  const SizedBox(
                                                                      height:
                                                                          6), // Replacing VerticalSpace with SizedBox
                                                                  InkWell(
                                                                    onTap: () {
                                                                      Navigator.pop(
                                                                          context);
                                                                    },
                                                                    child:
                                                                        Container(
                                                                      height:
                                                                          40,
                                                                      width: double
                                                                          .infinity,
                                                                      decoration: BoxDecoration(
                                                                          color: Colors
                                                                              .grey,
                                                                          borderRadius:
                                                                              BorderRadius.circular(8.0)),
                                                                      child: Center(
                                                                          child: Text(
                                                                        widget.translateEn ==
                                                                                "en"
                                                                            ? "Got it"
                                                                            : "ठीक है",
                                                                        style: const TextStyle(
                                                                            fontSize:
                                                                                18,
                                                                            color:
                                                                                Colors.white),
                                                                      )),
                                                                    ),
                                                                  )
                                                                  // punkGuideButton(context),
                                                                ],
                                                              ),
                                                            ),
                                                          );
                                                        },
                                                      );
                                                    },
                                                    child: const Icon(
                                                      Icons
                                                          .report_gmailerrorred,
                                                      color: Colors.orange,
                                                      size: 22,
                                                    )),
                                              ]),
                                        );
                                      },
                                    ),

                                    // ListView.builder(
                                    //   shrinkWrap: true,
                                    //   itemCount: widget.cabsquantity!.length,
                                    //   physics: const NeverScrollableScrollPhysics(),
                                    //   itemBuilder: (context, index) {
                                    //     //Calculate prices (move outside builder if possible)
                                    //     for (int i = 0;
                                    //     i < widget.cabsquantity!.length;
                                    //     i++) {
                                    //       int currentPrice = int.tryParse(widget
                                    //           .cabsquantity![i].price ??
                                    //           '0') ??
                                    //           0;
                                    //       cabFinalAmount.add(currentPrice);
                                    //     }
                                    //     return CabInfoCard(
                                    //       imageUrl: widget
                                    //           .cabsquantity![index].image ??
                                    //           '',
                                    //       cabName: widget.translateEn == "en"
                                    //           ? widget.cabsquantity![index]
                                    //           .enCabName ??
                                    //           ''
                                    //           : widget.cabsquantity![index]
                                    //           .hiCabName ??
                                    //           '',
                                    //       seatsText: widget.translateEn == "en"
                                    //           ? "${widget.cabsquantity![index].seats} Seater"
                                    //           : "${widget.cabsquantity![index].seats} सीटर",
                                    //       unitPrice: widget
                                    //           .cabsquantity![index].price ??
                                    //           '',
                                    //       totalLabel: "Total",
                                    //       totalPrice: cabsQuantity[index] == 0
                                    //           ? "00"
                                    //           : "${cabFinalAmount[index]}",
                                    //       quantity: cabsQuantity[index],
                                    //       isEnglish: widget.translateEn == "en",
                                    //       personInCab: false,
                                    //       widgetIndex: index,
                                    //       selectedIndex: selectedIndex,
                                    //       isSelected: selectedIndex == index,
                                    //       isPersonWise: false,
                                    //       onSelect: () {
                                    //         setState(() {
                                    //           selectedIndex = index;
                                    //         });
                                    //       },
                                    //       onAddTap: () => addCabQuantity(index),
                                    //       onIncreaseTap: () => increaseQuantity(
                                    //           index,
                                    //           int.parse(
                                    //               "${widget.cabsquantity![index].price}")),
                                    //       onDecreaseTap: () => decreaseQuantity(
                                    //           index,
                                    //           int.parse(
                                    //               "${widget.cabsquantity![index].price}")),
                                    //       onClearTap: () {
                                    //         setState(() {
                                    //           cabsQuantity[index] =
                                    //           0; // Reset your quantity state variable
                                    //           selectedIndex = -1;
                                    //           selectedCabQuantity = 0;
                                    //           updateItemQuantity(
                                    //             "Cab",
                                    //             cabFinalAmount[index],
                                    //             cabsQuantity[index],
                                    //           );
                                    //         });
                                    //       },
                                    //       onInfoTap: () {
                                    //         InfoDialog.show(
                                    //           context: context,
                                    //           description:
                                    //           widget.translateEn == "en"
                                    //               ? widget
                                    //               .cabsquantity![index]
                                    //               .enDescription
                                    //               : widget
                                    //               .cabsquantity![index]
                                    //               .hiDescription,
                                    //           languageCode: widget.translateEn,
                                    //         );
                                    //       },
                                    //     );
                                    //   },
                                    // ),

                                    const SizedBox(
                                      height: 80,
                                    )
                                  ],
                                ),
                              ),
                            );
                    } else if (service == "foods") {
                      return widget.isPersonUse == 1

                          /// Per Person Group
                          ? Padding(
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
                                              begin: Alignment
                                                  .topLeft, // Starting point of the gradient
                                              end: Alignment
                                                  .bottomRight, // Ending point of the gradient
                                            ),
                                          ),
                                        )),
                                        Expanded(
                                            child: Text(
                                          widget.translateEn == "en"
                                              ? "Select Food"
                                              : "भोजन चुनें",
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
                                              begin: Alignment
                                                  .topLeft, // Starting point of the gradient
                                              end: Alignment
                                                  .bottomRight, // Ending point of the gradient
                                            ),
                                          ),
                                        )),
                                      ],
                                    ),
                                    ListView.builder(
                                      shrinkWrap: true,
                                      itemCount: widget.foodList.length,
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      itemBuilder: (context, index) {
                                        // Calculate prices (optimize outside builder if possible)
                                        for (int i = 0;
                                            i < widget.foodList.length;
                                            i++) {
                                          int currentPrice = int.tryParse(
                                                  "${widget.foodList[i].price}") ??
                                              0;
                                          if (i >= foodFinalAmount.length) {
                                            foodFinalAmount.add(currentPrice);
                                          } else {
                                            foodFinalAmount[i] = currentPrice;
                                          }
                                        }

                                        return CabInfoCard(
                                          imageUrl:
                                              widget.foodList[index].image ??
                                                  '',
                                          cabName: widget.translateEn == "en"
                                              ? widget.foodList[index]
                                                      .enPackageName ??
                                                  ''
                                              : widget.foodList[index]
                                                      .hiPackageName ??
                                                  '',
                                          seatsText: widget.translateEn == "en"
                                              ? widget.foodList[index].title ??
                                                  ''
                                              : widget.foodList[index].title ??
                                                  '',
                                          unitPrice:
                                              "${widget.foodList[index].price}",
                                          totalLabel: widget.translateEn == "en"
                                              ? "Total"
                                              : "कुल",
                                          totalPrice: foodQuantity[index] == 0
                                              ? "00"
                                              : "${foodFinalAmount[index] * foodQuantity[index]}",
                                          quantity: foodQuantity[index],
                                          isEnglish: widget.translateEn == "en",
                                          onInfoTap: () {
                                            InfoDialog.show(
                                              context: context,
                                              description:
                                                  widget.translateEn == "en"
                                                      ? widget.foodList[index]
                                                          .enDescription
                                                      : widget.foodList[index]
                                                          .hiDescription,
                                              languageCode: widget.translateEn,
                                            );
                                          },
                                          onAddTap: () {
                                            setState(() {
                                              foodQuantity[index]++;
                                              print(
                                                  "My Food:${foodFinalAmount[index] * foodQuantity[index] + taxAmount}");
                                              addFoodItem(
                                                widget.foodList[index]
                                                        .enPackageName ??
                                                    '',
                                                foodFinalAmount[index] *
                                                    foodQuantity[index],
                                                foodQuantity[index],
                                                "Food",
                                                widget.foodList[index].image ??
                                                    '',
                                                "other",
                                                widget.foodList[index].packageId
                                                    .toString(),
                                                '',
                                                "0",
                                                "0",
                                                "0",
                                              );
                                            });
                                          },
                                          onIncreaseTap: () {
                                            setState(() {
                                              foodQuantity[index]++;
                                              addFoodItem(
                                                widget.foodList[index]
                                                        .enPackageName ??
                                                    '',
                                                foodFinalAmount[index] *
                                                    foodQuantity[index],
                                                foodQuantity[index],
                                                "Food",
                                                widget.foodList[index].image ??
                                                    '',
                                                "other",
                                                widget.foodList[index].packageId
                                                    .toString(),
                                                '',
                                                "0",
                                                "0",
                                                "0",
                                              );
                                            });
                                          },
                                          onDecreaseTap: () {
                                            setState(() {
                                              foodQuantity[index]--;
                                              updateItemQuantity(
                                                "Food",
                                                foodFinalAmount[index] *
                                                    foodQuantity[index],
                                                foodQuantity[index],
                                                itemId: widget
                                                    .foodList[index].packageId
                                                    .toString(), // Add this line
                                              );
                                            });
                                          },
                                          personInCab: true,
                                          includedStatus: widget
                                              .foodList[index].includedStatus,
                                          //hotelTypeList: [],
                                        );
                                      },
                                    ),
                                    const SizedBox(
                                      height: 80,
                                    )
                                  ],
                                ),
                              ),
                            )

                          /// Cab Wise
                          : Padding(
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
                                              begin: Alignment
                                                  .topLeft, // Starting point of the gradient
                                              end: Alignment
                                                  .bottomRight, // Ending point of the gradient
                                            ),
                                          ),
                                        )),
                                        Expanded(
                                            child: Text(
                                          widget.translateEn == "en"
                                              ? "Select Food"
                                              : "भोजन चुनें",
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
                                              begin: Alignment
                                                  .topLeft, // Starting point of the gradient
                                              end: Alignment
                                                  .bottomRight, // Ending point of the gradient
                                            ),
                                          ),
                                        )),
                                      ],
                                    ),
                                    ListView.builder(
                                      shrinkWrap: true,
                                      itemCount: widget.foodList.length,
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      itemBuilder: (context, index) {
                                        // Calculate prices (optimize outside builder if possible)
                                        for (int i = 0;
                                            i < widget.foodList.length;
                                            i++) {
                                          int currentPrice = int.tryParse(
                                                  "${widget.foodList[i].price}") ??
                                              0;
                                          if (i >= foodFinalAmount.length) {
                                            foodFinalAmount.add(currentPrice);
                                          } else {
                                            foodFinalAmount[i] = currentPrice;
                                          }
                                        }

                                        return CabInfoCard(
                                          imageUrl:
                                              widget.foodList[index].image ??
                                                  '',
                                          cabName: widget.translateEn == "en"
                                              ? widget.foodList[index]
                                                      .enPackageName ??
                                                  ''
                                              : widget.foodList[index]
                                                      .hiPackageName ??
                                                  '',
                                          seatsText: widget.translateEn == "en"
                                              ? widget.foodList[index].title ??
                                                  ''
                                              : widget.foodList[index].title ??
                                                  '',
                                          unitPrice:
                                              "${widget.foodList[index].price}",
                                          totalLabel: widget.translateEn == "en"
                                              ? "Total"
                                              : "कुल",
                                          totalPrice: foodQuantity[index] == 0
                                              ? "00"
                                              : "${foodFinalAmount[index] * foodQuantity[index]}",
                                          quantity: foodQuantity[index],
                                          isEnglish: widget.translateEn == "en",
                                          onInfoTap: () {
                                            InfoDialog.show(
                                              context: context,
                                              description:
                                                  widget.translateEn == "en"
                                                      ? widget.foodList[index]
                                                          .enDescription
                                                      : widget.foodList[index]
                                                          .hiDescription,
                                              languageCode: widget.translateEn,
                                            );
                                          },
                                          onAddTap: () {
                                            setState(() {
                                              foodQuantity[index]++;
                                              addFoodItem(
                                                widget.foodList[index]
                                                        .enPackageName ??
                                                    '',
                                                foodFinalAmount[index] *
                                                    foodQuantity[index],
                                                foodQuantity[index],
                                                "Food",
                                                widget.foodList[index].image ??
                                                    '',
                                                "other",
                                                widget.foodList[index].packageId
                                                    .toString(),
                                                '',
                                                "0",
                                                "0",
                                                "0",
                                              );
                                            });
                                          },
                                          onIncreaseTap: () {
                                            setState(() {
                                              foodQuantity[index]++;
                                              addFoodItem(
                                                widget.foodList[index]
                                                        .enPackageName ??
                                                    '',
                                                foodFinalAmount[index] *
                                                    foodQuantity[index],
                                                foodQuantity[index],
                                                "Food",
                                                widget.foodList[index].image ??
                                                    '',
                                                "other",
                                                widget.foodList[index].packageId
                                                    .toString(),
                                                '',
                                                "0",
                                                "0",
                                                "0",
                                              );
                                            });
                                          },
                                          onDecreaseTap: () {
                                            setState(() {
                                              foodQuantity[index]--;
                                              updateItemQuantity(
                                                "Food",
                                                foodFinalAmount[index] *
                                                    foodQuantity[index],
                                                foodQuantity[index],
                                                itemId: widget
                                                    .foodList[index].packageId
                                                    .toString(), // Add this line
                                              );
                                            });
                                          },
                                          personInCab: true,
                                        );
                                      },
                                    ),
                                    const SizedBox(
                                      height: 80,
                                    )
                                  ],
                                ),
                              ),
                            );
                    } else if (service == "hotel") {
                      return widget.isPersonUse == 1

                          /// Per Person Group
                          ? Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: SingleChildScrollView(
                                child: Column(
                                  children: [
                                    const SizedBox(height: 15),

                                    if (!isCustomSelected &&
                                        filteredHotelList.isNotEmpty)
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Container(
                                              height: 2,
                                              decoration: const BoxDecoration(
                                                gradient: LinearGradient(
                                                  colors: [
                                                    Colors.red,
                                                    Colors.yellow
                                                  ],
                                                  begin: Alignment.topLeft,
                                                  end: Alignment.bottomRight,
                                                ),
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            child: Text(
                                              widget.translateEn == "en"
                                                  ? "Select Hotel"
                                                  : "होटल चुनें",
                                              style: const TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.orange,
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                          Expanded(
                                            child: Container(
                                              height: 2,
                                              decoration: const BoxDecoration(
                                                gradient: LinearGradient(
                                                  colors: [
                                                    Colors.yellow,
                                                    Colors.red
                                                  ],
                                                  begin: Alignment.topLeft,
                                                  end: Alignment.bottomRight,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),

                                    // Agar filtered empty hai ya customization mode ON hai -> Tabs show karenge
                                    if (filteredHotelList.isEmpty ||
                                        isCustomSelected) ...[
                                      Column(
                                        children: [
                                          // Back button sirf tab dikhana hai jab included hotels exist karte ho
                                          if (filteredHotelList.isNotEmpty)
                                            SizedBox(
                                              width: double.infinity,
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(30),
                                                  gradient:
                                                      const LinearGradient(
                                                    colors: [
                                                      Color(0xFFFF5722),
                                                      Color(0xFFFF9800)
                                                    ],
                                                    begin: Alignment.centerLeft,
                                                    end: Alignment.centerRight,
                                                  ),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: Colors.deepOrange
                                                          .withOpacity(0.4),
                                                      blurRadius: 8,
                                                      offset:
                                                          const Offset(0, 4),
                                                    ),
                                                  ],
                                                ),
                                                child: ElevatedButton.icon(
                                                  onPressed: () {
                                                    setState(() {
                                                      isCustomSelected = false;
                                                      addFoodItem(
                                                        filteredHotelList[0]
                                                                .enPackageName ??
                                                            '',
                                                        00,
                                                        filteredHotelList[0]
                                                            .title,
                                                        "Hotel",
                                                        filteredHotelList[0]
                                                                .image ??
                                                            '',
                                                        "other",
                                                        filteredHotelList[0]
                                                            .packageId
                                                            .toString(),
                                                        '',
                                                        00,
                                                        00,
                                                        00,
                                                      );
                                                    });
                                                  },
                                                  icon: const Icon(
                                                      Icons.arrow_back_ios,
                                                      size: 18),
                                                  label: const Text(
                                                      "Go to Included",
                                                      style: TextStyle(
                                                          fontSize: 16)),
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                    backgroundColor:
                                                        Colors.transparent,
                                                    foregroundColor:
                                                        Colors.white,
                                                    shadowColor:
                                                        Colors.transparent,
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        vertical: 8,
                                                        horizontal: 20),
                                                    shape:
                                                        RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              30),
                                                    ),
                                                    textStyle: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.w700,
                                                      letterSpacing: 0.5,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          const SizedBox(height: 20),

                                          // TabBar
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 5, horizontal: 16),
                                            decoration: BoxDecoration(
                                              color: Colors.grey.shade100,
                                              borderRadius:
                                                  BorderRadius.circular(30),
                                            ),
                                            child: TabBar(
                                              tabAlignment: TabAlignment.start,
                                              controller: _tabController,
                                              isScrollable: true,
                                              labelColor: Colors.white,
                                              unselectedLabelColor:
                                                  Colors.black,
                                              splashFactory:
                                                  NoSplash.splashFactory,
                                              dividerColor: Colors.transparent,
                                              indicator: BoxDecoration(
                                                gradient: const LinearGradient(
                                                  colors: [
                                                    Color(0xFFFF5722),
                                                    Color(0xFFFF9800)
                                                  ],
                                                  begin: Alignment.topCenter,
                                                  end: Alignment.bottomCenter,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(25),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.deepOrange
                                                        .withOpacity(0.3),
                                                    blurRadius: 6,
                                                    offset: const Offset(0, 2),
                                                  ),
                                                ],
                                              ),
                                              indicatorSize:
                                                  TabBarIndicatorSize.tab,
                                              labelStyle: const TextStyle(
                                                fontWeight: FontWeight.w600,
                                                fontSize: 14,
                                              ),
                                              unselectedLabelStyle:
                                                  const TextStyle(
                                                fontWeight: FontWeight.w500,
                                                fontSize: 14,
                                              ),
                                              tabs: hotelTabs
                                                  .map(
                                                    (tab) => Container(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          horizontal: 10,
                                                          vertical: 12),
                                                      child: Text(tab.hotelType,
                                                          textAlign:
                                                              TextAlign.center),
                                                    ),
                                                  )
                                                  .toList(),
                                            ),
                                          ),
                                          const SizedBox(height: 20),

                                          // TabBarView
                                          SizedBox(
                                            height: 480,
                                            child: TabBarView(
                                              controller: _tabController,
                                              children: hotelTabs.map((tab) {
                                                final packagesForTab = hotelList
                                                    .where((pkg) =>
                                                        pkg.hotelType ==
                                                            tab.hotelType &&
                                                        pkg.includedStatus != 1)
                                                    .toList();

                                                if (packagesForTab.isEmpty) {
                                                  return Center(
                                                    child: Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        Icon(
                                                          Icons.search_off,
                                                          size: 80,
                                                          color: Colors
                                                              .grey.shade400,
                                                        ),
                                                        const SizedBox(
                                                            height: 20),
                                                        Text(
                                                          "No Packages Available",
                                                          style: TextStyle(
                                                            fontSize: 20,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color: Colors
                                                                .grey.shade700,
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                            height: 10),
                                                        Text(
                                                          "Please check again later or try a different option",
                                                          textAlign:
                                                              TextAlign.center,
                                                          style: TextStyle(
                                                            fontSize: 16,
                                                            color: Colors
                                                                .grey.shade500,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  );
                                                }

                                                return ListView.builder(
                                                  // shrinkWrap: true,
                                                  itemCount:
                                                      packagesForTab.length,
                                                  padding: EdgeInsets.only(
                                                      bottom: 20),
                                                  itemBuilder:
                                                      (context, index) {
                                                    final package =
                                                        packagesForTab[index];
                                                    int originalIndex =
                                                        hotelList.indexWhere(
                                                      (p) =>
                                                          p.packageId ==
                                                          package.packageId,
                                                    );

                                                    return CabInfoCard(
                                                      imageUrl:
                                                          package.image ?? '',
                                                      cabName: widget.translateEn ==
                                                              "en"
                                                          ? package
                                                                  .enPackageName ??
                                                              ''
                                                          : package
                                                                  .hiPackageName ??
                                                              '',
                                                      seatsText:
                                                          "${package.title ?? ''}\n1 x ₹${package.price}",
                                                      unitPrice:
                                                          "${package.price}",
                                                      totalLabel:
                                                          widget.translateEn ==
                                                                  "en"
                                                              ? "Total"
                                                              : "कुल",
                                                      totalPrice: hotelQuantity[
                                                                  originalIndex] ==
                                                              0
                                                          ? "00"
                                                          : "${hotelFinalAmount[originalIndex] * hotelQuantity[originalIndex]}",
                                                      quantity: hotelQuantity[
                                                          originalIndex],
                                                      isEnglish:
                                                          widget.translateEn ==
                                                              "en",
                                                      onInfoTap: () {
                                                        InfoDialog.show(
                                                          context: context,
                                                          description: widget
                                                                      .translateEn ==
                                                                  "en"
                                                              ? package
                                                                  .enDescription
                                                              : package
                                                                  .hiDescription,
                                                          languageCode: widget
                                                              .translateEn,
                                                        );
                                                      },
                                                      onAddTap: () {
                                                        setState(() {
                                                          if (currentSelectedTab !=
                                                              tab.hotelType) {
                                                            for (int i = 0;
                                                                i <
                                                                    hotelQuantity
                                                                        .length;
                                                                i++) {
                                                              hotelQuantity[i] =
                                                                  0;
                                                            }
                                                            currentSelectedTab =
                                                                tab.hotelType;
                                                          }

                                                          hotelQuantity[
                                                              originalIndex]++;
                                                          addFoodItem(
                                                            package.enPackageName ??
                                                                '',
                                                            hotelFinalAmount[
                                                                    originalIndex] *
                                                                hotelQuantity[
                                                                    originalIndex],
                                                            hotelQuantity[
                                                                originalIndex],
                                                            "Hotel",
                                                            package.image ?? '',
                                                            "other",
                                                            package.packageId
                                                                .toString(),
                                                            '',
                                                            "0",
                                                            "0",
                                                            "0",
                                                          );
                                                        });
                                                      },
                                                      onIncreaseTap: () {
                                                        setState(() {
                                                          hotelQuantity[
                                                              originalIndex]++;
                                                          addFoodItem(
                                                            package.enPackageName ??
                                                                '',
                                                            hotelFinalAmount[
                                                                    originalIndex] *
                                                                hotelQuantity[
                                                                    originalIndex],
                                                            hotelQuantity[
                                                                originalIndex],
                                                            "Hotel",
                                                            package.image ?? '',
                                                            "other",
                                                            package.packageId
                                                                .toString(),
                                                            '',
                                                            "0",
                                                            "0",
                                                            "0",
                                                          );
                                                        });
                                                      },
                                                      onDecreaseTap: () {
                                                        setState(() {
                                                          hotelQuantity[
                                                              originalIndex]--;
                                                          updateItemQuantity(
                                                            "Hotel",
                                                            hotelFinalAmount[
                                                                    originalIndex] *
                                                                hotelQuantity[
                                                                    originalIndex],
                                                            hotelQuantity[
                                                                originalIndex],
                                                          );
                                                        });
                                                      },
                                                      personInCab: true,
                                                    );
                                                  },
                                                );
                                              }).toList(),
                                            ),
                                          ),
                                        ],
                                      )
                                    ]
                                    // Agar included hotels available hai aur customization off hai
                                    else ...[
                                      ListView.builder(
                                        shrinkWrap: true,
                                        itemCount: filteredHotelList.length,
                                        physics:
                                            const NeverScrollableScrollPhysics(),
                                        itemBuilder: (context, index) {
                                          final hotelItem =
                                              filteredHotelList[index];
                                          return CabInfoCard(
                                            imageUrl: hotelItem.image ?? '',
                                            cabName: widget.translateEn == "en"
                                                ? hotelItem.enPackageName ?? ''
                                                : hotelItem.hiPackageName ?? '',
                                            seatsText:
                                                "${hotelItem.title ?? ''}",
                                            unitPrice: "${hotelItem.price}",
                                            totalLabel:
                                                widget.translateEn == "en"
                                                    ? "Total"
                                                    : "कुल",
                                            totalPrice: hotelQuantity[index] ==
                                                    0
                                                ? "00"
                                                : "${hotelFinalAmount[index] * hotelQuantity[index]}",
                                            quantity: hotelQuantity[index],
                                            isEnglish:
                                                widget.translateEn == "en",
                                            onInfoTap: () {
                                              InfoDialog.show(
                                                context: context,
                                                description: widget
                                                            .translateEn ==
                                                        "en"
                                                    ? hotelItem.enDescription
                                                    : hotelItem.hiDescription,
                                                languageCode:
                                                    widget.translateEn,
                                              );
                                            },
                                            onAddTap: () {
                                              setState(() {
                                                hotelQuantity[index]++;
                                                addFoodItem(
                                                  hotelItem.enPackageName ?? '',
                                                  hotelFinalAmount[index] *
                                                      hotelQuantity[index],
                                                  hotelQuantity[index],
                                                  "Hotel",
                                                  hotelItem.image ?? '',
                                                  "other",
                                                  hotelItem.packageId
                                                      .toString(),
                                                  '',
                                                  "0",
                                                  "0",
                                                  "0",
                                                );
                                              });
                                            },
                                            onIncreaseTap: () {
                                              setState(() {
                                                hotelQuantity[index]++;
                                                addFoodItem(
                                                  hotelItem.enPackageName ?? '',
                                                  hotelFinalAmount[index] *
                                                      hotelQuantity[index],
                                                  hotelQuantity[index],
                                                  "Hotel",
                                                  hotelItem.image ?? '',
                                                  "other",
                                                  hotelItem.packageId
                                                      .toString(),
                                                  '',
                                                  "0",
                                                  "0",
                                                  "0",
                                                );
                                              });
                                            },
                                            onDecreaseTap: () {
                                              setState(() {
                                                hotelQuantity[index]--;
                                                updateItemQuantity(
                                                  "Hotel",
                                                  hotelFinalAmount[index] *
                                                      hotelQuantity[index],
                                                  hotelQuantity[index],
                                                );
                                              });
                                            },
                                            personInCab: true,
                                            includedStatus:
                                                hotelItem.includedStatus,
                                          );
                                        },
                                      ),

                                      // Customization button
                                      hotelTabs.isEmpty
                                          ? SizedBox()
                                          : SizedBox(
                                              width: double.infinity,
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(30),
                                                  gradient:
                                                      const LinearGradient(
                                                    colors: [
                                                      Color(0xFFFF5722),
                                                      Color(0xFFFF9800)
                                                    ],
                                                    begin: Alignment.centerLeft,
                                                    end: Alignment.centerRight,
                                                  ),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: Colors.deepOrange
                                                          .withOpacity(0.4),
                                                      blurRadius: 8,
                                                      offset:
                                                          const Offset(0, 4),
                                                    ),
                                                  ],
                                                ),
                                                child: ElevatedButton.icon(
                                                  onPressed: () {
                                                    setState(() {
                                                      isCustomSelected = true;
                                                    });
                                                  },
                                                  label: const Text(
                                                      "Customization",
                                                      style: TextStyle(
                                                          fontSize: 16)),
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                    backgroundColor:
                                                        Colors.transparent,
                                                    foregroundColor:
                                                        Colors.white,
                                                    shadowColor:
                                                        Colors.transparent,
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        vertical: 12,
                                                        horizontal: 20),
                                                    shape:
                                                        RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              30),
                                                    ),
                                                    textStyle: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.w700,
                                                      letterSpacing: 0.5,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                    ],
                                  ],
                                ),
                              ),
                            )

                          /// Cab Wise
                          : Padding(
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
                                              begin: Alignment
                                                  .topLeft, // Starting point of the gradient
                                              end: Alignment
                                                  .bottomRight, // Ending point of the gradient
                                            ),
                                          ),
                                        )),
                                        Expanded(
                                            child: Text(
                                          widget.translateEn == "en"
                                              ? "Select Hotel"
                                              : "होटल चुनें",
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
                                                begin: Alignment
                                                    .topLeft, // Starting point of the gradient
                                                end: Alignment
                                                    .bottomRight, // Ending point of the gradient
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    ListView.builder(
                                      shrinkWrap: true,
                                      itemCount: widget.hotelList.length,
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      itemBuilder: (context, index) {
                                        // Calculate prices (optimize outside builder if possible)
                                        for (int i = 0;
                                            i < widget.hotelList.length;
                                            i++) {
                                          int currentPrice = int.tryParse(
                                                  widget.hotelList[i].price ??
                                                      '0') ??
                                              0;
                                          if (i >= hotelFinalAmount.length) {
                                            hotelFinalAmount.add(currentPrice);
                                          } else {
                                            hotelFinalAmount[i] = currentPrice;
                                          }
                                        }

                                        return CabInfoCard(
                                          imageUrl:
                                              widget.hotelList[index].image ??
                                                  '',
                                          cabName: widget.translateEn == "en"
                                              ? widget.hotelList[index]
                                                      .enPackageName ??
                                                  ''
                                              : widget.hotelList[index]
                                                      .hiPackageName ??
                                                  '',
                                          seatsText: widget.translateEn == "en"
                                              ? "${widget.hotelList[index].title ?? ''}\n1 x ₹${widget.hotelList[index].price}"
                                              : "${widget.hotelList[index].title ?? ''}\n1 x ₹${widget.hotelList[index].price}",
                                          unitPrice:
                                              "${widget.hotelList[index].price}",
                                          totalLabel: widget.translateEn == "en"
                                              ? "Total"
                                              : "कुल",
                                          totalPrice: hotelQuantity[index] == 0
                                              ? "00"
                                              : "${hotelFinalAmount[index] * hotelQuantity[index]}",
                                          quantity: hotelQuantity[index],
                                          isEnglish: widget.translateEn == "en",
                                          onInfoTap: () {
                                            InfoDialog.show(
                                              context: context,
                                              description:
                                                  widget.translateEn == "en"
                                                      ? widget.hotelList[index]
                                                          .enDescription
                                                      : widget.hotelList[index]
                                                          .hiDescription,
                                              languageCode: widget.translateEn,
                                            );
                                          },
                                          onAddTap: () {
                                            setState(() {
                                              hotelQuantity[index]++;
                                              addFoodItem(
                                                widget.hotelList[index]
                                                        .enPackageName ??
                                                    '',
                                                hotelFinalAmount[index] *
                                                    hotelQuantity[index],
                                                hotelQuantity[index],
                                                "Hotel",
                                                widget.hotelList[index].image ??
                                                    '',
                                                "other",
                                                widget
                                                    .hotelList[index].packageId
                                                    .toString(),
                                                '',
                                                "0",
                                                "0",
                                                "0",
                                              );
                                            });
                                          },
                                          onIncreaseTap: () {
                                            setState(() {
                                              hotelQuantity[index]++;
                                              addFoodItem(
                                                widget.hotelList[index]
                                                        .enPackageName ??
                                                    '',
                                                hotelFinalAmount[index] *
                                                    hotelQuantity[index],
                                                hotelQuantity[index],
                                                "Hotel",
                                                widget.hotelList[index].image ??
                                                    '',
                                                "other",
                                                widget
                                                    .hotelList[index].packageId
                                                    .toString(),
                                                '',
                                                "0",
                                                "0",
                                                "0",
                                              );
                                            });
                                          },
                                          onDecreaseTap: () {
                                            setState(() {
                                              hotelQuantity[index]--;
                                              updateItemQuantity(
                                                "Hotel",
                                                hotelFinalAmount[index] *
                                                    hotelQuantity[index],
                                                hotelQuantity[index],
                                              );
                                            });
                                          },
                                          personInCab:
                                              true, // Changed to true to show person icon
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            );
                    } else {
                      return const Text(
                          "empty"); // Fallback for unknown services
                    }
                  }).toList(),

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
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Icon(
                                      Icons.calendar_month,
                                      color: Colors.orange,
                                      size: 22,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      _getBookingTitle(widget.customizedType),
                                      style: const TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 15,
                                      ),
                                    ),
                                  ],
                                ),

                                // Show date ONLY for Single Day (0)
                                if (widget.customizedType == "0") ...[
                                  const SizedBox(height: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: Colors.transparent,
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                          color: Colors.blue.shade200,
                                          width: 1.5),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.calendar_month,
                                          size: 26,
                                          color: Colors.deepOrange,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          formatDateRangeWithTo(
                                              widget.tourDate),
                                          style: TextStyle(
                                            color: Colors.blue.shade900,
                                            fontSize: 20,
                                            fontWeight: FontWeight.w600,
                                            letterSpacing: 0.3,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],

                                widget.customizedType == "0"
                                    ? SizedBox()
                                    : Column(children: [
                                        if (widget.customizedType == "1" &&
                                            widget.customizedDates != null &&
                                            widget.customizedDates!
                                                .isNotEmpty) ...[
                                          const SizedBox(height: 12),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              SizedBox(
                                                height: 30,
                                                child: ListView.separated(
                                                  scrollDirection:
                                                      Axis.horizontal,
                                                  itemCount: widget
                                                      .customizedDates!.length,
                                                  separatorBuilder: (context,
                                                          index) =>
                                                      const SizedBox(width: 8),
                                                  itemBuilder:
                                                      (context, index) {
                                                    final day =
                                                        widget.customizedDates![
                                                            index];
                                                    return Container(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          horizontal: 15,
                                                          vertical: 5),
                                                      decoration: BoxDecoration(
                                                        color:
                                                            _getDayColor(day),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(10),
                                                        border: Border.all(
                                                          color: Colors
                                                              .blue.shade200,
                                                          width: 1.5,
                                                        ),
                                                        boxShadow: [
                                                          BoxShadow(
                                                            color: Colors
                                                                .grey.shade200,
                                                            blurRadius: 4,
                                                            offset:
                                                                const Offset(
                                                                    0, 2),
                                                          ),
                                                        ],
                                                      ),
                                                      child: Center(
                                                        child: Text(
                                                          _getTranslatedDay(
                                                              day),
                                                          style: TextStyle(
                                                            fontSize: 14,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color:
                                                                _getDayTextColor(
                                                                    day),
                                                          ),
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                        GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              dateSelection = !dateSelection;
                                            });
                                          },
                                          child: Container(
                                            margin: const EdgeInsets.symmetric(
                                                vertical: 8),
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 10, vertical: 5),
                                            decoration: BoxDecoration(
                                              color: Colors.white
                                                  .withOpacity(0.95),
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.blueGrey
                                                      .withOpacity(0.2),
                                                  blurRadius: 12,
                                                  offset: const Offset(0, 4),
                                                ),
                                              ],
                                              border: Border.all(
                                                  color: Colors.blueGrey
                                                      .withOpacity(0.25)),
                                            ),
                                            child: Row(
                                              children: [
                                                Container(
                                                  padding:
                                                      const EdgeInsets.all(10),
                                                  decoration: BoxDecoration(
                                                    color: Colors.blueGrey
                                                        .withOpacity(0.12),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            12),
                                                  ),
                                                  child: const Icon(
                                                      Icons.calendar_month,
                                                      color: Colors.blueGrey,
                                                      size: 20),
                                                ),
                                                const SizedBox(width: 14),
                                                Expanded(
                                                  child: Text(
                                                    finalSelectedDate == null
                                                        ? (widget.translateEn ==
                                                                "en"
                                                            ? "Select Date"
                                                            : "तारीख चुनें")
                                                        : finalSelectedDate!,
                                                    style: const TextStyle(
                                                      fontSize: 17,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color: Colors.black87,
                                                    ),
                                                  ),
                                                ),
                                                AnimatedRotation(
                                                  turns:
                                                      dateSelection ? 0.5 : 0,
                                                  duration: const Duration(
                                                      milliseconds: 300),
                                                  child: const Icon(
                                                    Icons
                                                        .keyboard_arrow_down_rounded,
                                                    size: 28,
                                                    color: Colors.blueGrey,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        if (dateSelection)
                                          CustomCalendar(
                                            customizedType: "${widget.customizedType}",
                                            customizedDates: widget.customizedDates ?? [],
                                            selectedSeats: selectedCabQuantity,
                                            totalSeats: tourDateAwailable?.data?.totalSeats ?? 0,
                                            availableSeatsByDate: tourDateAwailable?.data?.availableSeatsByDate ?? {"2026-01-06": 4,},
                                            bookingAllowedMonths: 2,
                                            selectedDate: finalSelectedDate,
                                            onDateSelected: (date) {
                                              setState(() {
                                                finalSelectedDate =
                                                    date; // date show in card
                                              });
                                              print("Selected: $date");
                                            },
                                            isPersonUse: widget.isPersonUse,
                                            isLoading: _isLoading,
                                          )
                                      ]),

                                SizedBox(
                                  height: 10,
                                ),
                                widget.isPersonUse == 0
                                    ? Column(
                                      children: [
                                        Row(
                                            children: [
                                              const Icon(
                                                Icons.location_on_outlined,
                                                color: Colors.orange,
                                              ),
                                              Text(
                                                  widget.translateEn == "en"
                                                      ? 'Pickup Location'
                                                      : "पिकअप स्थान",
                                                  style: const TextStyle(
                                                      fontSize: 16,
                                                      color: Colors.black,
                                                      fontFamily: 'Roboto',
                                                      fontWeight:
                                                      FontWeight.bold)),
                                            ],
                                          ),
                                        SizedBox(
                                          width: 310,
                                          child: Text(
                                            widget.locationName,
                                            style: const TextStyle(
                                                fontSize: 16,
                                                color: Colors.grey,
                                                overflow:
                                                TextOverflow.ellipsis,
                                                fontFamily: 'Roboto',
                                                fontWeight:
                                                FontWeight.w400),
                                            maxLines: 3,
                                          ),
                                        ),
                                      ],
                                    )
                                    : Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          // Pickup Section
                                          Row(
                                            children: [
                                              const Icon(
                                                Icons.car_crash_sharp,
                                                color: Colors.orange,
                                                size: 20,
                                              ),
                                              const SizedBox(width: 5),
                                              Text(
                                                "Pick From",
                                                style: const TextStyle(
                                                    color: Colors.black,
                                                    fontWeight: FontWeight.w500,
                                                    fontSize: 16),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 5),
                                          Row(
                                            children: [
                                              // Fixed Location Radio Button (1)
                                              Expanded(
                                                child: InkWell(
                                                  onTap: () {
                                                    setState(() {
                                                      isPickFixedLocation =
                                                          true;
                                                      isPickAirport = false;
                                                      selectedPickAirport =
                                                          null;

                                                      if (isDropFixedLocation) {
                                                        onlyPickUp = false;
                                                        onlyDrop = false;
                                                        both = false;
                                                      } else if (isDropAirport) {
                                                        onlyPickUp = false;
                                                        onlyDrop = true;
                                                        both = false;
                                                      }
                                                      getSelectedPrice();
                                                    });
                                                  },
                                                  child: Container(
                                                    margin:
                                                        const EdgeInsets.all(2),
                                                    padding:
                                                        const EdgeInsets.all(2),
                                                    decoration: BoxDecoration(
                                                      color: isPickFixedLocation
                                                          ? Colors.blue[50]
                                                          : Colors.grey[50],
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              12),
                                                      border: Border.all(
                                                        color:
                                                            isPickFixedLocation
                                                                ? Colors.blue
                                                                : Colors.grey,
                                                        width: 2,
                                                      ),
                                                    ),
                                                    child: Row(
                                                      children: [
                                                        Radio<bool>(
                                                          value: true,
                                                          groupValue:
                                                              isPickFixedLocation,
                                                          onChanged: (value) {
                                                            setState(() {
                                                              isPickFixedLocation =
                                                                  value!;
                                                              isPickAirport =
                                                                  !value;
                                                              if (value)
                                                                selectedPickAirport =
                                                                    null;

                                                              if (isDropFixedLocation) {
                                                                onlyPickUp =
                                                                    false;
                                                                onlyDrop =
                                                                    false;
                                                                both = false;
                                                              } else if (isDropAirport) {
                                                                onlyPickUp =
                                                                    false;
                                                                onlyDrop = true;
                                                                both = false;
                                                              }
                                                              getSelectedPrice();
                                                            });
                                                          },
                                                          activeColor:
                                                              Colors.blue,
                                                        ),
                                                        const SizedBox(
                                                            width: 4),
                                                        Column(
                                                          children: [
                                                            const Text(
                                                              "FIxed Location",
                                                              style: TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  fontSize: 12),
                                                            ),
                                                            Text(
                                                              "Free",
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .green,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600,
                                                                  fontSize: 11),
                                                            ),
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),

                                              // Airport Radio Button (2)
                                              Expanded(
                                                child: InkWell(
                                                  onTap: () {
                                                    setState(() {
                                                      isPickAirport = true;
                                                      isPickFixedLocation =
                                                          false;

                                                      if (isDropFixedLocation) {
                                                        onlyPickUp = true;
                                                        onlyDrop = false;
                                                        both = false;
                                                      } else if (isDropAirport) {
                                                        onlyPickUp = false;
                                                        onlyDrop = false;
                                                        both = true;
                                                      }
                                                      getSelectedPrice();
                                                    });
                                                  },
                                                  child: Container(
                                                    margin:
                                                        const EdgeInsets.all(2),
                                                    padding:
                                                        const EdgeInsets.all(2),
                                                    decoration: BoxDecoration(
                                                      color: isPickAirport
                                                          ? Colors.orange[50]
                                                          : Colors.grey[50],
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              12),
                                                      border: Border.all(
                                                        color: isPickAirport
                                                            ? Colors.orange
                                                            : Colors.grey,
                                                        width: 2,
                                                      ),
                                                    ),
                                                    child: Row(
                                                      children: [
                                                        Radio<bool>(
                                                          value: true,
                                                          groupValue:
                                                              isPickAirport,
                                                          onChanged: (value) {
                                                            setState(() {
                                                              isPickAirport =
                                                                  value!;
                                                              isPickFixedLocation =
                                                                  !value;

                                                              if (isDropFixedLocation) {
                                                                onlyPickUp =
                                                                    true;
                                                                onlyDrop =
                                                                    false;
                                                                both = false;
                                                              } else if (isDropAirport) {
                                                                onlyPickUp =
                                                                    false;
                                                                onlyDrop =
                                                                    false;
                                                                both = true;
                                                              }
                                                              getSelectedPrice();
                                                            });
                                                          },
                                                          activeColor:
                                                              Colors.orange,
                                                        ),
                                                        const SizedBox(
                                                            width: 4),
                                                        Icon(
                                                          Icons
                                                              .airplanemode_active,
                                                          color: isPickAirport
                                                              ? Colors.orange
                                                              : Colors.grey,
                                                          size: 24,
                                                        ),
                                                        const SizedBox(
                                                            width: 8),
                                                        Column(
                                                          children: [
                                                            const Text(
                                                              "Airport",
                                                              style: TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  fontSize: 14),
                                                            ),
                                                            Text(
                                                              "Paid",
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .red,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600),
                                                            ),
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),

                                          // Show selected pickup location if fixed location is selected
                                          if (isPickFixedLocation) ...[
                                            const SizedBox(height: 10),
                                            Row(
                                              children: [
                                                const Icon(
                                                  Icons.location_on_outlined,
                                                  color: Colors.orange,
                                                ),
                                                const SizedBox(width: 8),
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        widget.translateEn ==
                                                                "en"
                                                            ? 'Pickup Location'
                                                            : "पिकअप स्थान",
                                                        style: const TextStyle(
                                                          fontSize: 16,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                      Text(
                                                        widget.locationName,
                                                        style: const TextStyle(
                                                          fontSize: 14,
                                                          color: Colors.grey,
                                                        ),
                                                        maxLines: 2,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                          const SizedBox(height: 16),

                                          // Drop Section
                                          Row(
                                            children: [
                                              const Icon(
                                                Icons.car_crash_sharp,
                                                color: Colors.orange,
                                                size: 20,
                                              ),
                                              const SizedBox(width: 5),
                                              Text(
                                                "Drop To",
                                                style: const TextStyle(
                                                    color: Colors.black,
                                                    fontWeight: FontWeight.w500,
                                                    fontSize: 16),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 5),
                                          Row(
                                            children: [
                                              // Fixed Location Radio Button (3)
                                              Expanded(
                                                child: InkWell(
                                                  onTap: () {
                                                    setState(() {
                                                      isDropFixedLocation =
                                                          true;
                                                      isDropAirport = false;
                                                      selectedDropAirport =
                                                          null;

                                                      if (isPickFixedLocation) {
                                                        onlyPickUp = false;
                                                        onlyDrop = false;
                                                        both = false;
                                                      } else if (isPickAirport) {
                                                        onlyPickUp = true;
                                                        onlyDrop = false;
                                                        both = false;
                                                      }
                                                      getSelectedPrice();
                                                    });
                                                  },
                                                  child: Container(
                                                    margin:
                                                        const EdgeInsets.all(2),
                                                    padding:
                                                        const EdgeInsets.all(2),
                                                    decoration: BoxDecoration(
                                                      color: isDropFixedLocation
                                                          ? Colors.blue[50]
                                                          : Colors.grey[50],
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              12),
                                                      border: Border.all(
                                                        color:
                                                            isDropFixedLocation
                                                                ? Colors.blue
                                                                : Colors.grey,
                                                        width: 2,
                                                      ),
                                                    ),
                                                    child: Row(
                                                      children: [
                                                        Radio<bool>(
                                                          value: true,
                                                          groupValue:
                                                              isDropFixedLocation,
                                                          onChanged: (value) {
                                                            setState(() {
                                                              isDropFixedLocation =
                                                                  value!;
                                                              isDropAirport =
                                                                  !value;
                                                              if (value)
                                                                selectedDropAirport =
                                                                    null;

                                                              if (isPickFixedLocation) {
                                                                onlyPickUp =
                                                                    false;
                                                                onlyDrop =
                                                                    false;
                                                                both = false;
                                                              } else if (isPickAirport) {
                                                                onlyPickUp =
                                                                    true;
                                                                onlyDrop =
                                                                    false;
                                                                both = false;
                                                              }
                                                              getSelectedPrice();
                                                            });
                                                          },
                                                          activeColor:
                                                              Colors.blue,
                                                        ),
                                                        const SizedBox(
                                                            width: 4),
                                                        Column(
                                                          children: [
                                                            const Text(
                                                              "Fixed Location",
                                                              style: TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  fontSize: 12),
                                                            ),
                                                            Text(
                                                              "Free",
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .green,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600,
                                                                  fontSize: 11),
                                                            ),
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),

                                              // Airport Radio Button (4)
                                              Expanded(
                                                child: InkWell(
                                                  onTap: () {
                                                    setState(() {
                                                      isDropAirport = true;
                                                      isDropFixedLocation =
                                                          false;
                                                      if (isPickFixedLocation) {
                                                        onlyPickUp = false;
                                                        onlyDrop = true;
                                                        both = false;
                                                      } else if (isPickAirport) {
                                                        onlyPickUp = false;
                                                        onlyDrop = false;
                                                        both = true;
                                                      }
                                                      getSelectedPrice();
                                                    });
                                                  },
                                                  child: Container(
                                                    margin:
                                                        const EdgeInsets.all(2),
                                                    padding:
                                                        const EdgeInsets.all(2),
                                                    decoration: BoxDecoration(
                                                      color: isDropAirport
                                                          ? Colors.orange[50]
                                                          : Colors.grey[50],
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              12),
                                                      border: Border.all(
                                                        color: isDropAirport
                                                            ? Colors.orange
                                                            : Colors.grey,
                                                        width: 2,
                                                      ),
                                                    ),
                                                    child: Row(
                                                      children: [
                                                        Radio<bool>(
                                                          value: true,
                                                          groupValue:
                                                              isDropAirport,
                                                          onChanged: (value) {
                                                            setState(() {
                                                              isDropAirport =
                                                                  value!;
                                                              isDropFixedLocation =
                                                                  !value;
                                                              if (isPickFixedLocation) {
                                                                onlyPickUp =
                                                                    false;
                                                                onlyDrop = true;
                                                                both = false;
                                                              } else if (isPickAirport) {
                                                                onlyPickUp =
                                                                    false;
                                                                onlyDrop =
                                                                    false;
                                                                both = true;
                                                              }
                                                              getSelectedPrice();
                                                            });
                                                          },
                                                          activeColor:
                                                              Colors.orange,
                                                        ),
                                                        const SizedBox(
                                                            width: 4),
                                                        Transform.rotate(
                                                          angle:
                                                              3.14, // 180 degrees in radians
                                                          child: Icon(
                                                            Icons
                                                                .airplanemode_active,
                                                            color: isDropAirport
                                                                ? Colors.orange
                                                                : Colors.grey,
                                                            size: 24,
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                            width: 8),
                                                        Column(
                                                          children: [
                                                            const Text(
                                                              "Airport",
                                                              style: TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  fontSize: 14),
                                                            ),
                                                            Text(
                                                              "Paid",
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .red,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600),
                                                            ),
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),

                                          // Show selected drop location if fixed location is selected
                                          if (isDropFixedLocation) ...[
                                            const SizedBox(height: 5),
                                            Row(
                                              children: [
                                                const Icon(
                                                  Icons.location_on_outlined,
                                                  color: Colors.orange,
                                                ),
                                                const SizedBox(width: 8),
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        widget.translateEn ==
                                                                "en"
                                                            ? 'Drop Location'
                                                            : "ड्रॉप स्थान",
                                                        style: const TextStyle(
                                                          fontSize: 16,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                      Text(
                                                        widget.locationName,
                                                        style: const TextStyle(
                                                          fontSize: 14,
                                                          color: Colors.grey,
                                                        ),
                                                        maxLines: 2,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],

                                          // Show total price only when isPersonUse == 1
                                          if (widget.isPersonUse == 1) ...[
                                            const SizedBox(height: 20),

                                            //totalExtraPrice == 0 ? Text("Free") :

                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Text(
                                                  onlyPickUp
                                                      ? 'Pickup Price: '
                                                      : onlyDrop
                                                          ? 'Drop Price: '
                                                          : both
                                                              ? 'Both Price: '
                                                              : 'Total Price: ',
                                                  style: const TextStyle(
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.green,
                                                  ),
                                                ),
                                                Text(
                                                  '${formatIndianCurrency(totalExtraPrice)}',
                                                  style: const TextStyle(
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.red,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
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
                    padding: const EdgeInsets.all(10.0),
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          /// Packages List
                          ListView.builder(
                            shrinkWrap: true,
                            itemCount: packageItems.length,
                            physics: const NeverScrollableScrollPhysics(),
                            itemBuilder: (context, index) {
                              itemTotalAmount = packageItems[index]["price"];
                              personQuantity =
                                  int.tryParse("${packageItems[index]["qty"]}");
                              return Container(
                                margin: const EdgeInsets.only(bottom: 5),
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
                                          Text(
                                            "${packageItems[index]["qty"]} ${_getUnitLabel(packageItems[index]["title"])}",
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w500,
                                              color: Colors.black,
                                            ),
                                          ),
                                          Text(
                                              itemTotalAmount == 0
                                                  ? "INCLUDED"
                                                  : "Total: ${formatIndianCurrency(itemTotalAmount)}",
                                              style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w500,
                                                  color: itemTotalAmount == 0
                                                      ? Colors.red
                                                      : Colors.blue)),
                                        ],
                                      ),
                                    ),
                                    packageItems[index]["image"] != ""
                                        ? Expanded(
                                            flex: 0,
                                            child: Container(
                                              height: 85,
                                              width: 125,
                                              decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                  border: Border.all(
                                                      color: Colors.grey),
                                                  image: DecorationImage(
                                                      image: NetworkImage(
                                                          "${packageItems[index]["image"]}"),
                                                      fit: BoxFit.fill)),
                                            ),
                                          )
                                        : const SizedBox(),
                                  ],
                                ),
                              );
                            },
                          ),

                          /// User Extra Distance Info
                          if (onlyPickUp || onlyDrop || both)
                            ListView.builder(
                              shrinkWrap: true,
                              itemCount: distanceArray.length,
                              physics: const NeverScrollableScrollPhysics(),
                              itemBuilder: (context, index) {
                                return Container(
                                  margin: const EdgeInsets.all(5),
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
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
                                          Text(
                                            distanceArray[index]["price"] ==
                                                    "pickup"
                                                ? "Route Type: Only Pickup"
                                                : distanceArray[index]
                                                            ["price"] ==
                                                        "both"
                                                    ? "Route Type: Both"
                                                    : distanceArray[index]
                                                                ["price"] ==
                                                            "drop"
                                                        ? "Route Type: Only Drop"
                                                        : "Extra Distance Amount: ${formatIndianCurrency(distanceArray[index]["pprice"])}",
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w500,
                                              color: distanceArray[index]
                                                          ["price"] ==
                                                      "pickup"
                                                  ? Colors.red
                                                  : distanceArray[index]
                                                              ["price"] ==
                                                          "both"
                                                      ? Colors.red
                                                      : distanceArray[index]
                                                                  ["price"] ==
                                                              "drop"
                                                          ? Colors.red
                                                          : Colors.blue,
                                            ),
                                          ),
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
                                      setState(() {
                                        selectedAmountIndex = 0;
                                      });
                                    },
                                    child: Container(
                                      margin: EdgeInsets.all(8),
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
                                      setState(() {
                                        selectedAmountIndex = 1;
                                        isCouponApplyed = false;
                                      });
                                    },
                                    child: Container(
                                      margin: EdgeInsets.all(8),
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
                          const SizedBox(height: 10),

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
                              : SizedBox(),

                          const SizedBox(
                            height: 10,
                          ),

                          /// Total Bill Information
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                  color: Colors.grey.shade300, width: 1.2),
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.1),
                                  spreadRadius: 1,
                                  blurRadius: 5,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Bill Header
                                Text(
                                  widget.translateEn == "en"
                                      ? "Bill details"
                                      : "बिल विवरण",
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Roboto',
                                    color: Colors.deepOrange,
                                  ),
                                ),
                                const SizedBox(height: 12),

                                // Package Price
                                Row(
                                  children: [
                                    Text(
                                      widget.translateEn == "en"
                                          ? "Package Price"
                                          : "पैकेज राशि",
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                        fontFamily: 'Roboto',
                                        color: Colors.black87,
                                      ),
                                    ),
                                    const Spacer(),
                                    Text(
                                      "${formatIndianCurrency(PackagePrice)}",
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontFamily: 'Roboto',
                                        fontWeight: FontWeight.w500,
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
                                        fontWeight: FontWeight.w500,
                                        fontFamily: 'Roboto',
                                        color: Colors.black87,
                                      ),
                                    ),
                                    const Spacer(),
                                    Text(
                                      //"₹${totalFinalTax}",
                                      "${formatIndianCurrency(totalFinalTax)}",
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontFamily: 'Roboto',
                                        fontWeight: FontWeight.w500,
                                        color: Colors.red,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),

                                // Divider
                                const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 6),
                                  child: Divider(
                                      height: 1,
                                      thickness: 1,
                                      color: Colors.grey),
                                ),

                                // Total Price
                                Row(
                                  children: [
                                    Text(
                                      widget.translateEn == "en"
                                          ? "Total Price"
                                          : "कुल राशि",
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        fontFamily: 'Roboto',
                                        color: Colors.black87,
                                      ),
                                    ),
                                    const Spacer(),
                                    Text(
                                      // "₹${finalPrice.toStringAsFixed(2)}",
                                      "${formatIndianCurrency(finalPrice)}",
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontFamily: 'Roboto',
                                        fontWeight: FontWeight.w600,
                                        color: Colors.green,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),

                                // Discount Section
                                Column(
                                  children: [
                                    const Padding(
                                      padding:
                                          EdgeInsets.symmetric(vertical: 6),
                                      child: Divider(
                                          height: 1,
                                          thickness: 1,
                                          color: Colors.grey),
                                    ),
                                    Row(
                                      children: [
                                        Text(
                                          widget.translateEn == "en"
                                              ? "Special Discount"
                                              : "विशेष छूट",
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500,
                                            fontFamily: 'Roboto',
                                            color: Colors.black87,
                                          ),
                                        ),
                                        const Spacer(),
                                        Text(
                                          isCouponApplyed
                                              //? "- ₹${couponAmount.toStringAsFixed(2)}"
                                              ? "- ${formatIndianCurrency(couponAmount)}"
                                              : "- ₹0.00",
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontFamily: 'Roboto',
                                            fontWeight: FontWeight.w500,
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

                                // Wallet Section
                                Column(
                                  children: [
                                    const Padding(
                                      padding:
                                          EdgeInsets.symmetric(vertical: 6),
                                      child: Divider(
                                          height: 1,
                                          thickness: 1,
                                          color: Colors.grey),
                                    ),

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
                                                    //"₹${walletPay.toStringAsFixed(2)}",
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
                                const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 6),
                                  child: Divider(
                                      height: 1,
                                      thickness: 1,
                                      color: Colors.grey),
                                ),
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
                                      // "₹${remainingAmount.toStringAsFixed(2)}",
                                      "${formatIndianCurrency(remainingAmount)}",
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'Roboto',
                                        color: Colors.deepOrange,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                              ],
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),

                          /// Partial Alert
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
              bottomNavigationBar: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // -------------------- Seat Check --------------------
                  remainingCabSeats == null
                      ? Container(
                          height: 50,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          margin: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12.0),
                            gradient: const LinearGradient(
                              colors: [Colors.redAccent, Colors.red],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.red.withOpacity(0.4),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              widget.translateEn == "en"
                                  ? "No Seats Available (Tour Already Booked)"
                                  : "कोई सीट उपलब्ध नहीं है (यात्रा पहले से बुक है)",
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        )
                      : ((widget.isPersonUse == 1
                              ? remainingCabSeats.isNotEmpty &&
                                  remainingCabSeats.every((seat) => seat <= 0)
                              : remainingCabSeats.isNotEmpty &&
                                  remainingCabSeats.every((seat) => seat <= 0))
                          ? Container(
                              height: 50,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20),
                              margin: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12.0),
                                gradient: const LinearGradient(
                                  colors: [Colors.redAccent, Colors.red],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.red.withOpacity(0.4),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Text(
                                  widget.translateEn == "en"
                                      ? "No Seats Available (Tour Already Booked)"
                                      : "कोई सीट उपलब्ध नहीं है (यात्रा पहले से बुक है)",
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            )
                          : const SizedBox()),

                  // -------------------- Seats Available & Quantity Selected --------------------
                  if (remainingCabSeats != null && selectedCabQuantity != 0)
                    Container(
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
                          // Total Amount Box
                          if (selectOrder != widget.services!.length + 1)
                            totalAmountDisplay(
                              amount: widget.isPersonUse == 1
                                  ? "${specificCabTotal + specificFoodTotal + specificHotelTotal + (int.tryParse("$selectedExPrice") ?? 0)}"
                                  : "${selectedCabTotalAmount}",
                            ),
                          const SizedBox(height: 10),

                          // Buttons Row
                          selectOrder == widget.services!.length + 1
                              ? Row(
                                  children: [
                                    // Back Arrow
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
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(8.0),
                                          color: Colors.red,
                                        ),
                                        child: const Icon(
                                            Icons.arrow_circle_left,
                                            color: Colors.white),
                                      ),
                                    ),
                                    const SizedBox(width: 10),

                                    // Pay Now Button
                                    Expanded(
                                      child: GestureDetector(
                                        onTap: () {
                                          leadController.generateTourLead(
                                            tourId: widget.tourId,
                                            packageId:
                                                widget.packageId.toString(),
                                            amount:
                                                '${remainingAmount == 0 ? finalPrice : remainingAmount}',
                                          );

                                          if (naviGateRazorpay == 2 ||
                                              naviGateRazorpay == 3) {
                                            razorpayService.openCheckout(
                                              amount: remainingAmount,
                                              razorpayKey:
                                                  AppConstants.razorpayLive,
                                              onSuccess: (response) {
                                                setState(() {
                                                  circularIndicator = true;
                                                });
                                                successPayment(
                                                    response.paymentId!);
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
                                              description: 'City Tour',
                                            );
                                          } else if (naviGateRazorpay == 1) {
                                            showPaymentDialog(context);
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
                                    // Previous Button
                                    Expanded(
                                      child: GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            finalSelectedDate =
                                                null; //  reset date
                                            mergedArrayList.clear();
                                          });
                                          //mergedArrayList.clear();
                                          previousPage();
                                        },
                                        child: Container(
                                          height: 45,
                                          margin:
                                              const EdgeInsets.only(right: 5),
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
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),

                                    Expanded(
                                      child: GestureDetector(
                                        onTap: () {
                                          if (widget.customizedType != "0") {
                                            final isDateEmpty =
                                                finalSelectedDate?.isEmpty ??
                                                    true;

                                            if (selectOrder ==
                                                    widget.services!.length &&
                                                isDateEmpty) {
                                              BeautifulToast.show(
                                                context,
                                                widget.translateEn == "en"
                                                    ? "Please select a date to continue!"
                                                    : "जारी रखने के लिए कृपया तारीख चुनें!",
                                                backgroundColor: Colors.red,
                                                icon: Icons.error,
                                              );
                                              return;
                                            }
                                          }

                                          if (selectOrder ==
                                              widget.services!.length) {
                                            setState(() {
                                              mergedArrayList
                                                  .addAll(packageItems);
                                              mergedArrayList
                                                  .addAll(distanceArray);
                                            });
                                            sumTotal();
                                            nextPage();
                                          } else {
                                            nextPage();
                                            if (onlyPickUp ||
                                                onlyDrop ||
                                                both) {
                                              getSelectedPrice();
                                            }
                                          }
                                          if(widget.isPersonUse == 1){
                                            print("Person Type");
                                          } else {
                                            fetchDatesAvailiblity();
                                          }
                                        },
                                        child: Container(
                                          height: 45,
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
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                        ],
                      ),
                    ),
                ],
              )

              // selectedCabQuantity != 0
              //     ? Container(
              //   padding: const EdgeInsets.only(
              //       top: 10, left: 15, right: 15, bottom: 15),
              //   decoration: const BoxDecoration(
              //     color: Colors.white,
              //     boxShadow: [
              //       BoxShadow(
              //         color: Colors.black12,
              //         blurRadius: 6,
              //         offset: Offset(0, -1),
              //       ),
              //     ],
              //   ),
              //   child: Column(
              //     mainAxisSize: MainAxisSize.min,
              //     children: [
              //
              //       // 💰 Total Amount Box
              //       selectOrder == widget.services!.length + 1
              //           ? SizedBox()
              //           : totalAmountDisplay(
              //         amount: "${specificCabTotal + specificFoodTotal + specificHotelTotal +  (int.tryParse("$selectedExPrice"))}",
              //       ),
              //       const SizedBox(height: 10),
              //
              //       //  Buttons Row
              //       selectOrder == widget.services!.length + 1
              //           ? Row(
              //         children: [
              //           GestureDetector(
              //             onTap: () {
              //               mergedArrayList.clear();
              //               previousPage();
              //               setState(() {
              //                 isCouponApplyed = false;
              //               });
              //             },
              //             child: Container(
              //               height: 45,
              //               width: 45,
              //               decoration: BoxDecoration(
              //                 borderRadius:
              //                 BorderRadius.circular(8.0),
              //                 color: Colors.red,
              //               ),
              //               child: const Icon(
              //                   Icons.arrow_circle_left,
              //                   color: Colors.white),
              //             ),
              //           ),
              //           const SizedBox(width: 10),
              //           Expanded(
              //             child: GestureDetector(
              //               onTap: () {
              //                 leadController.generateTourLead(
              //                   tourId: widget.tourId,
              //                   packageId: widget.packageId.toString(),
              //                   amount: '${remainingAmount == 0 ? finalPrice : remainingAmount}',
              //                 );
              //                 if (naviGateRazorpay == 2) {
              //                   razorpayService.openCheckout(
              //                     amount: remainingAmount, // ₹100
              //                     razorpayKey: AppConstants.razorpayLive,
              //                     onSuccess: (response) {
              //                       setState(() {
              //                         circularIndicator = true;
              //                       });
              //                       successPayment(
              //                           response.paymentId!);
              //                     },
              //                     onFailure: (response) {
              //                       setState(() {
              //                         circularIndicator = false;
              //                       });
              //                     },
              //                     onExternalWallet: (response) {
              //                       print("Wallet: ${response.walletName}");
              //                     },
              //                     description: 'City Tour',
              //                   );
              //                 } else if (naviGateRazorpay == 1) {
              //                   showPaymentDialog(context);
              //                 } else if (naviGateRazorpay == 3) {
              //                   razorpayService.openCheckout(
              //                     amount: remainingAmount, // ₹100
              //                     razorpayKey:
              //                     AppConstants.razorpayLive,
              //                     onSuccess: (response) {
              //                       setState(() {
              //                         circularIndicator = true;
              //                       });
              //                       successPayment(
              //                           response.paymentId!);
              //                     },
              //                     onFailure: (response) {
              //                       setState(() {
              //                         circularIndicator = false;
              //                       });
              //                     },
              //                     onExternalWallet: (response) {
              //                       print("Wallet: ${response.walletName}");
              //                     },
              //                     description: 'City Tour',
              //                   );
              //                 }
              //               },
              //               child: Container(
              //                 height: 45,
              //                 margin: const EdgeInsets.all(5),
              //                 decoration: BoxDecoration(
              //                   borderRadius:
              //                   BorderRadius.circular(8.0),
              //                   color: Colors.green,
              //                 ),
              //                 child: Center(
              //                   child: Text(
              //                     widget.translateEn == "en"
              //                         ? "Pay Now"
              //                         : "भुगतान करे",
              //                     style: const TextStyle(
              //                       fontSize: 18,
              //                       fontWeight: FontWeight.bold,
              //                       color: Colors.white,
              //                     ),
              //                   ),
              //                 ),
              //               ),
              //             ),
              //           ),
              //         ],
              //       )
              //           : Row(
              //         children: [
              //           Expanded(
              //             child: GestureDetector(
              //               onTap: (){
              //                 mergedArrayList.clear();
              //                 previousPage();
              //               },
              //               child: Container(
              //                 height: 45,
              //                 margin:
              //                 const EdgeInsets.only(right: 5),
              //                 decoration: BoxDecoration(
              //                   borderRadius:
              //                   BorderRadius.circular(8.0),
              //                   color: selectOrder == 0
              //                       ? Colors.grey
              //                       : Colors.orange,
              //                 ),
              //                 child: Center(
              //                   child: Text(
              //                     widget.translateEn == "en"
              //                         ? "Previous"
              //                         : "पिछला",
              //                     style: const TextStyle(
              //                       fontSize: 18,
              //                       color: Colors.white,
              //                       fontWeight: FontWeight.bold,
              //                     ),
              //                   ),
              //                 ),
              //               ),
              //             ),
              //           ),
              //           Expanded(
              //             child: GestureDetector(
              //               // onTap: () {
              //               //
              //               //   final isDateEmpty = finalSelectedDate?.isEmpty ?? true;
              //               //
              //               //   if (selectOrder ==
              //               //       widget.services!.length &&
              //               //       (isDateEmpty)) {
              //               //     BeautifulToast.show(
              //               //       context,
              //               //       widget.translateEn == "en"
              //               //           ? "Form fields Required!"
              //               //           : "फॉर्म फ़ील्ड आवश्यक!",
              //               //       backgroundColor: Colors.red,
              //               //       icon: Icons.error,
              //               //     );
              //               //   } else {
              //               //     nextPage();
              //               //   }
              //               // },
              //               onTap: () {
              //
              //                 final isDateEmpty = finalSelectedDate?.isEmpty ?? true;
              //
              //                 // Info page validation
              //                 if (selectOrder == widget.services!.length) {
              //                   if (isDateEmpty) {
              //                     BeautifulToast.show(
              //                       context,
              //                       widget.translateEn == "en"
              //                           ? "Form fields Required !"
              //                           : "फॉर्म फ़ील्ड आवश्यक!",
              //                       backgroundColor: Colors.red,
              //                       icon: Icons.error,
              //                     );
              //                     return;
              //                   }
              //
              //                   // State update (ONLY data)
              //                   setState(() {
              //                     mergedArrayList.addAll(packageItems);
              //                     mergedArrayList.addAll(distanceArray);
              //                   });
              //
              //                   sumTotal(); // outside setState
              //                   nextPage(); // outside setState
              //                   print("Button clicked");
              //
              //                 } else {
              //                   nextPage();
              //                   if (onlyPickUp || onlyDrop || both) {
              //                     getSelectedPrice();
              //                   }
              //                 }
              //               },
              //               child: Container(
              //                 height: 45,
              //                 decoration: BoxDecoration(
              //                   borderRadius:
              //                   BorderRadius.circular(8.0),
              //                   color: Colors.orange,
              //                 ),
              //                 child: Center(
              //                   child: Text(
              //                     widget.translateEn == "en"
              //                         ? "Next"
              //                         : "अगला",
              //                     style: const TextStyle(
              //                       fontSize: 18,
              //                       color: Colors.white,
              //                       fontWeight: FontWeight.bold,
              //                     ),
              //                   ),
              //                 ),
              //               ),
              //             ),
              //           ),
              //         ],
              //       ),
              //     ],
              //   ),
              // )
              //     : null,
              ),
    );
  }
}


class CustomCalendar extends StatefulWidget {
  final String customizedType; // "1" = weekly, "2" = date-wise, "3" = yearly
  final List<String> customizedDates; // Allowed days/dates
  final Function(String) onDateSelected;
  final String? selectedDate;
  final bool isLoading;

  // Booking data
  final int selectedSeats; // Seats user wants to book
  final int totalSeats; // Total cab seats
  final Map<String, int> availableSeatsByDate; // Date-wise availability
  final int bookingAllowedMonths; // e.g., 2 months max

  final int isPersonUse; // 0 = seat-based logic, !=0 = old logic

  CustomCalendar(
      {required this.customizedType,
      required this.customizedDates,
      required this.onDateSelected,
      this.selectedDate,
      required this.selectedSeats,
      required this.totalSeats,
      required this.availableSeatsByDate,
      required this.bookingAllowedMonths,
      required this.isPersonUse,
      this.isLoading = true});

  @override
  _CustomCalendarState createState() => _CustomCalendarState();
}

class _CustomCalendarState extends State<CustomCalendar> {
  late DateTime currentMonth;
  String? selectedDateLocal; // track selected date inside widget

  @override
  void initState() {
    super.initState();
    currentMonth = DateTime(DateTime.now().year, DateTime.now().month);
    selectedDateLocal = widget.selectedDate;
    print("Date Awailabe: ${widget.availableSeatsByDate}");
  }

  @override
  void didUpdateWidget(covariant CustomCalendar oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Agar parent se selectedDate change ho
    if (oldWidget.selectedDate != widget.selectedDate) {
      setState(() {
        selectedDateLocal = widget.selectedDate;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Check if we should show shimmer or not
    final shouldShowShimmer = widget.isPersonUse != 1 && widget.isLoading;

    if (shouldShowShimmer) {
      return _buildShimmerCalendar();
    }

    return Column(
      children: [
        _buildHeader(),
        _buildWeekDaysRow(),
        _buildCalendar(),
        SizedBox(height: 10),
      ],
    );
  }

  // HEADER
  Widget _buildHeader() {
    DateTime now = DateTime.now();
    DateTime firstMonth = DateTime(now.year, now.month);
    DateTime maxMonth =
        DateTime(now.year, now.month + widget.bookingAllowedMonths);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          icon: Icon(Icons.arrow_back_ios),
          onPressed: currentMonth.isAfter(firstMonth)
              ? () {
                  setState(() {
                    currentMonth =
                        DateTime(currentMonth.year, currentMonth.month - 1);
                  });
                }
              : null,
        ),
        Text(
          DateFormat("MMMM yyyy").format(currentMonth),
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        IconButton(
          icon: Icon(Icons.arrow_forward_ios),
          onPressed: currentMonth.isBefore(maxMonth)
              ? () {
                  setState(() {
                    currentMonth =
                        DateTime(currentMonth.year, currentMonth.month + 1);
                  });
                }
              : null,
        ),
      ],
    );
  }

  // WEEK DAYS ROW
  Widget _buildWeekDaysRow() {
    final days = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: days
          .map((d) => Expanded(
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  alignment: Alignment.center,
                  child: Text(d,
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                ),
              ))
          .toList(),
    );
  }

 // MAIN CALENDAR GRID
 //  Widget _buildCalendar() {
 //    final firstDayOfMonth = DateTime(currentMonth.year, currentMonth.month, 1);
 //    final daysInMonth =
 //        DateUtils.getDaysInMonth(currentMonth.year, currentMonth.month);
 //    int startIndex = (firstDayOfMonth.weekday + 6) % 7; // Monday = 0
 //
 //    return GridView.builder(
 //      shrinkWrap: true,
 //      physics: NeverScrollableScrollPhysics(),
 //      itemCount: daysInMonth + startIndex,
 //      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
 //        crossAxisCount: 7,
 //        childAspectRatio: 1,
 //      ),
 //      itemBuilder: (context, index) {
 //        if (index < startIndex) return Container();
 //
 //        final day = index - startIndex + 1;
 //        final date = DateTime(currentMonth.year, currentMonth.month, day);
 //        final formatted = DateFormat("dd-MM-yyyy").format(date);
 //
 //        bool enabled;
 //        int seatsAvailable = 0;
 //
 //        Color bgColor = Colors.white;
 //        Color borderColor = Colors.orange;
 //        Color textColor = Colors.black;
 //        String seatText = "";
 //
 //        if (widget.isPersonUse == 0) {
 //          // Seat-based logic
 //          enabled = _isEnabled(date);
 //          //seatsAvailable = widget.availableSeatsByDate[formatted] ?? widget.totalSeats;
 //
 //          seatsAvailable = widget.availableSeatsByDate[formatted] ??
 //              widget.availableSeatsByDate[
 //                  formatted.replaceFirst(RegExp(r'^0'), '')] ??
 //              widget.totalSeats;
 //
 //          // 1️⃣ FULL BOOKED → RED
 //          if (seatsAvailable == 0) {
 //            bgColor = Colors.red;
 //            borderColor = Colors.red;
 //            textColor = Colors.white;
 //            enabled = false;
 //          }
 //          // 2️⃣ SELECTED → GREEN
 //          else if (selectedDateLocal == formatted) {
 //            bgColor = Colors.green;
 //            borderColor = Colors.green;
 //            textColor = Colors.white;
 //          }
 //          // 3️⃣ PARTIAL SEATS → ORANGE
 //          else if (seatsAvailable < widget.totalSeats) {
 //            bgColor = Colors.orange.shade300;
 //            borderColor = Colors.orange;
 //            textColor = Colors.black;
 //            seatText = "$seatsAvailable seats";
 //          }
 //          // 4️⃣ AVAILABLE → WHITE
 //          else {
 //            bgColor = Colors.white;
 //            borderColor = Colors.orange;
 //            textColor = Colors.black;
 //          }
 //
 //          // Disable if date is past / not allowed
 //          if (!_isEnabled(date)) {
 //            enabled = false;
 //            bgColor = Colors.grey.shade300;
 //            borderColor = Colors.grey;
 //            textColor = Colors.grey;
 //          }
 //        } else {
 //          // Old logic (without seat booking)
 //          enabled = _isEnabledOldLogic(date);
 //          if (!enabled) {
 //            bgColor = Colors.grey.shade300;
 //            borderColor = Colors.grey;
 //            textColor = Colors.grey;
 //          } else if (selectedDateLocal == formatted) {
 //            bgColor = Colors.green;
 //            borderColor = Colors.green;
 //            textColor = Colors.white;
 //          } else {
 //            bgColor = Colors.white;
 //            borderColor = Colors.orange;
 //            textColor = Colors.black;
 //          }
 //        }
 //
 //        return GestureDetector(
 //          onTap: enabled
 //              ? () {
 //                  if (widget.isPersonUse == 0 &&
 //                      widget.selectedSeats > seatsAvailable) {
 //                    ScaffoldMessenger.of(context).showSnackBar(
 //                      SnackBar(
 //                        content: Text("Only $seatsAvailable seats available"),
 //                      ),
 //                    );
 //                    return;
 //                  }
 //                  setState(() {
 //                    selectedDateLocal = formatted;
 //                  });
 //                  widget.onDateSelected(formatted);
 //                }
 //              : null,
 //          child: Container(
 //            margin: EdgeInsets.all(2),
 //            decoration: BoxDecoration(
 //              color: bgColor,
 //              borderRadius: BorderRadius.circular(8),
 //              border: Border.all(color: borderColor),
 //            ),
 //            alignment: Alignment.center,
 //            child: Column(
 //              mainAxisAlignment: MainAxisAlignment.center,
 //              children: [
 //                Text(
 //                  "$day",
 //                  style: TextStyle(
 //                    fontWeight: FontWeight.bold,
 //                    color: textColor,
 //                    fontSize: MediaQuery.of(context).size.width * 0.030, // responsive
 //                  ),
 //                ),
 //                if (seatText.isNotEmpty)
 //                  Text(
 //                    seatText,
 //                    style: TextStyle(
 //                      fontSize: MediaQuery.of(context).size.width * 0.028, // responsive
 //                      fontWeight: FontWeight.bold,
 //                      color: textColor,
 //                    ),
 //                  ),
 //              ],
 //            ),
 //          ),
 //        );
 //      },
 //    );
 //  }

  Widget _buildCalendar() {
    final firstDayOfMonth = DateTime(currentMonth.year, currentMonth.month, 1);
    final daysInMonth =
    DateUtils.getDaysInMonth(currentMonth.year, currentMonth.month);
    int startIndex = (firstDayOfMonth.weekday + 6) % 7; // Monday = 0

    return GridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: daysInMonth + startIndex,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        childAspectRatio: 1,
      ),
      itemBuilder: (context, index) {
        if (index < startIndex) return Container();

        final day = index - startIndex + 1;
        final date = DateTime(currentMonth.year, currentMonth.month, day);
        final formatted = DateFormat("dd-MM-yyyy").format(date);
        final now = DateTime.now();
        final today = DateTime(now.year, now.month, now.day);

        bool enabled;
        int seatsAvailable = 0;

        Color bgColor = Colors.white;
        Color borderColor = Colors.orange;
        Color textColor = Colors.black;
        String seatText = "";
        bool showRedCross = false; // Flag for today's date with seats but not selectable

        if (widget.isPersonUse == 0) {
          // Seat-based logic
          enabled = _isEnabled(date);

          seatsAvailable = widget.availableSeatsByDate[formatted] ??
              widget.availableSeatsByDate[
              formatted.replaceFirst(RegExp(r'^0'), '')] ??
              widget.totalSeats;

          // Check if it's TODAY's date AND has available seats BUT is not enabled
          final bool isToday = date.isAtSameMomentAs(today);
          final bool hasAvailableSeats = seatsAvailable > 0;
          final bool isNotEnabled = !enabled;

          // Show red cross for TODAY if it has seats but is not selectable
          showRedCross = isToday && hasAvailableSeats && isNotEnabled;

          // 1️⃣ FULL BOOKED → RED (0 seats)
          if (seatsAvailable == 0) {
            bgColor = Colors.red.shade100;
            borderColor = Colors.red;
            textColor = Colors.red.shade900;
            enabled = false;
          }

          // 2️⃣ SELECTED → GREEN
          else if (selectedDateLocal == formatted) {
            bgColor = Colors.green;
            borderColor = Colors.green;
            textColor = Colors.white;
          }
          // 3️⃣ PARTIAL SEATS → ORANGE
          else if (seatsAvailable < widget.totalSeats) {
            bgColor = Colors.orange.shade300;
            borderColor = Colors.orange;
            textColor = Colors.black;
            seatText = "$seatsAvailable seats";
          }
          // 4️⃣ AVAILABLE → WHITE
          else {
            bgColor = Colors.white;
            borderColor = Colors.orange;
            textColor = Colors.black;
          }

          // Disable if date is past / not allowed (but preserve today's red cross case)
          if (!enabled && !showRedCross) {
            bgColor = Colors.grey.shade300;
            borderColor = Colors.grey;
            textColor = Colors.grey;
            // For 0 seats, keep red color, don't change to grey
            if (seatsAvailable == 0) {
              bgColor = Colors.red;
              borderColor = Colors.red;
              textColor = Colors.white;
            }
          }
        } else {
          // Old logic (without seat booking)
          enabled = _isEnabledOldLogic(date);
          if (!enabled) {
            bgColor = Colors.grey.shade300;
            borderColor = Colors.grey;
            textColor = Colors.grey;
          } else if (selectedDateLocal == formatted) {
            bgColor = Colors.green;
            borderColor = Colors.green;
            textColor = Colors.white;
          } else {
            bgColor = Colors.white;
            borderColor = Colors.orange;
            textColor = Colors.black;
          }
        }

        return GestureDetector(
          onTap: enabled
              ? () {
            if (widget.isPersonUse == 0 &&
                widget.selectedSeats > seatsAvailable) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text("Only $seatsAvailable seats available"),
                ),
              );
              return;
            }
            setState(() {
              selectedDateLocal = formatted;
            });
            widget.onDateSelected(formatted);
          }
              : null,
          child: Stack(
            children: [
              Container(
                margin: EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: borderColor),
                ),
                alignment: Alignment.center,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "$day",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: textColor,
                        fontSize: MediaQuery.of(context).size.width * 0.030,
                      ),
                    ),
                    if (seatText.isNotEmpty && seatsAvailable > 0)
                      Text(
                        seatText,
                        style: TextStyle(
                          fontSize: MediaQuery.of(context).size.width * 0.028,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                  ],
                ),
              ),

              // Red cross for TODAY's date with seats but not selectable
              // (Only show if seats are > 0, not for 0 seats)
              if (showRedCross && seatsAvailable > 0)
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.white.withOpacity(0.7),
                    ),
                    child: Center(
                      child: Container(
                        padding: EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.red.withOpacity(0.9),
                        ),
                        child: Icon(
                          Icons.close_rounded,
                          color: Colors.white,
                          size: MediaQuery.of(context).size.width * 0.04,
                        ),
                      ),
                    ),
                  ),
                ),

            ],
          ),
        );
      },
    );
  }

  bool _isEnabled(DateTime date) {
    final today = DateTime.now();
    DateTime dateOnly = DateTime(date.year, date.month, date.day);
    DateTime todayOnly = DateTime(today.year, today.month, today.day);

    if (!dateOnly.isAfter(todayOnly)) return false;

    switch (widget.customizedType) {
      case "1": // weekly
        String day = DateFormat("EEEE").format(date);
        return widget.customizedDates!.contains(day);
      case "2": // monthly
        String day = date.day.toString().padLeft(2, '0');
        return widget.customizedDates!.contains(day);
      case "3": // yearly
        String formatted = DateFormat("dd-MM").format(date);
        return widget.customizedDates!.contains(formatted);
    }
    return false;
  }

  bool _isEnabledOldLogic(DateTime date) {
    final today = DateTime.now();
    DateTime dateOnly = DateTime(date.year, date.month, date.day);
    DateTime todayOnly = DateTime(today.year, today.month, today.day);

    if (!dateOnly.isAfter(todayOnly)) return false;

    switch (widget.customizedType) {
      case "1": // weekly
        String day = DateFormat("EEEE").format(date);
        return widget.customizedDates!.contains(day);
      case "2": // monthly
        String day = date.day.toString().padLeft(2, '0');
        return widget.customizedDates!.contains(day);
      case "3": // yearly
        String formatted = DateFormat("dd-MM").format(date);
        return widget.customizedDates!.contains(formatted);
    }
    return false;
  }

  Widget _buildShimmerCalendar() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Column(
        children: [
          // Header shimmer
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _shimmerBox(30, 30),
              _shimmerBox(120, 20),
              _shimmerBox(30, 30),
            ],
          ),
          SizedBox(height: 10),

          // Weekdays shimmer
          Row(
            children: List.generate(
              7,
              (index) => Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: _shimmerBox(double.infinity, 16),
                ),
              ),
            ),
          ),
          SizedBox(height: 10),

          // Calendar grid shimmer (6 rows × 7 columns)
          GridView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: 42,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              childAspectRatio: 1,
            ),
            itemBuilder: (_, __) {
              return Padding(
                padding: const EdgeInsets.all(4),
                child: _shimmerBox(double.infinity, double.infinity),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _shimmerBox(double width, double height) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }
}
