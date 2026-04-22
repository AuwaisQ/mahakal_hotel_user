import 'dart:convert';
import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:mahakal/main.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:mahakal/features/tour_and_travells/model/lead_generate_model.dart';
import 'package:mahakal/features/tour_and_travells/model/success_amount_model.dart';
import 'package:mahakal/utill/app_constants.dart';
import 'package:intl/intl.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:provider/provider.dart';
import '../../../../data/datasource/remote/http/httpClient.dart';
import '../../../../utill/completed_order_dialog.dart';
import '../../../../utill/payment_process_screen.dart';
import '../../../../utill/razorpay_screen.dart';
import '../../../auth/controllers/auth_controller.dart';
import '../../../custom_bottom_bar/bottomBar.dart';
import '../../../order/screens/order_screen.dart';
import '../../../profile/controllers/profile_contrroller.dart';
import '../../Controller/fetch_coupon_controller.dart';
import '../../Controller/fetch_wallet_controller.dart';
import '../../Controller/success_touramount_controller.dart';
import '../../Controller/tour_lead_controller.dart';
import '../../model/city_details_model.dart';
import '../../model/city_model.dart';
import '../../widgets/ApplyCoupon.dart';
import '../../widgets/backhandler.dart';
import '../../widgets/cab_info_card.dart';
import '../../widgets/info_dialog.dart';
import '../../widgets/person_card_widget.dart';
import '../../widgets/showbeautifulltoast.dart';
import '../../widgets/total_amount_display.dart';

class UseTypeTwo extends StatefulWidget {
  const UseTypeTwo({
    super.key,
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
    required this.locationName,
    required this.pickLat,
    required this.pickLong,
    required this.useDate,
    required this.isPersonUse,
    this.tourGst,
    this.transPortGst,
    required this.extraTransportPrice,
    this.hotelTypeList,
  });

  final List<String>? services;
  final List<PackageList>? packageList;
  final List<HotelTypeList>? hotelTypeList;
  final List<CabList>? cabsquantity;
  final List<PackageList> hotelList;
  final List<PackageList> foodList;
  final List<dynamic>? timeSlot;
  final List<dynamic> extraTransportPrice;
  final String tourId;
  final String? packageId;
  final String locationName;
  final String translateEn;
  final int? exDistance;
  final String tourName;
  final String hiTourName;
  final int packageAmount;
  final String pickLat;
  final String pickLong;
  final String useDate;
  final int isPersonUse;
  final dynamic tourGst;
  final dynamic transPortGst;

  @override
  State<UseTypeTwo> createState() => _UseTypeTwoState();
}

class _UseTypeTwoState extends State<UseTypeTwo>
    with SingleTickerProviderStateMixin {
  final List<GlobalKey> itemKeys = [];
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

  List<CityPickerModel> cityListModel = <CityPickerModel>[];

  String userId = "";
  String userNAME = "";
  String userEMAIL = "";
  String userPHONE = "";
  String userToken = "";
  String serviceCouponType = "";
  String? _selectedDate;
  String? _selectedTime;
  String? showingDate;
  String? currentSelectedTab;

  double amtByWallet = 0.0;
  double walletPay = 0.0;
  double walletMinusAmount = 0.0;
  double remainingAmount = 0.0;
  double couponAmount = 0.0;
  double amtAfterDis = 0.0;
  double? packageAll;
  double? selectedCabTotalAmount;
  double cabsPackageAmount = 0.0;
  double halfAmount = 0.0;

  int selectOrder = 0;
  int selectedCabQuantity = 0; // Default quantity
  int sumAmount = 0;
  int selectedAmountIndex = 0;
  int? successAmountStatus;
  int? naviGateRazorpay;
  int couponId = 0;
  int? personQuantity;
  int selectedIndex = -1;

  dynamic specificCabTotal = 0;
  dynamic specificFoodTotal = 0;
  dynamic specificHotelTotal = 0;

  bool _isLoading = false;
  bool isCouponApplyed = false;
  bool isLoading = false;
  bool showTabsDirectly = false;
  bool timeBox = false;
  bool circularIndicator = false;
  bool onlyPickUp = false;
  bool onlyDrop = false;
  bool both = false;
  bool isCustomSelected = false; // state variable

  late List<int> cabsQuantity;
  late List<int> hotelQuantity;

  late dynamic totalTax;
  late dynamic finalPrice;
  late dynamic PackagePrice;
  late dynamic totalListPrice;
  late dynamic totalFinalTax;
  //late dynamic addTransportAmount;

  List<Map<String, dynamic>> packageItems = [];
  List<Map<String, dynamic>> distanceArray = [];
  List<Map<String, dynamic>> mergedArrayList = [];

  List<int> selectedIndexes = [0];
  List<int> cabFinalAmount = [];
  List<int> foodQuantity = [];

  List<int> foodFinalAmount = [];
  List<int> hotelFinalAmount = [];
  List<PackageList> filteredHotelList = [];

  dynamic selectedExPrice = "0";
  dynamic taxAmount = 0;
  dynamic amountAfterTax = 0;
  //dynamic specificCabTotal = 0;
  //dynamic addTransportTaxAmount = 0;
  //dynamic addTourTaxAmount = 0;
  //dynamic addTransportAmount = 0;

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

  String _getUnitLabel(dynamic title) {
    if (title == "Per Head" ||
        title == "Cab" ||
        title == "Ex Transport" ||
        title == "Food" ||
        title == "Hotel") {
      return "Person";
    } else if (title == "Cab") {
      return "Cab";
    } else {
      return "";
    }
  }

  List<HotelTypeList> hotelTabs = [];
  List<PackageList> hotelList = [];
  int selectedTabIndex = 0;
  late TabController _tabController;

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

    double cabPrice =
        double.tryParse(widget.cabsquantity![0].price ?? "") ?? 0.0;
    packageAll =
        cabPrice + widget.packageAmount; // Removed cabPrice from initial total
    selectedCabTotalAmount = packageAll;

    // Initialize keys for each service and one extra for "Payment".
    for (int i = 0; i < widget.services!.length + 2; i++) {
      itemKeys.add(GlobalKey());
    }

    // Initialize all cab quantities to 0 (no default selection)
    hotelQuantity = List.generate(widget.hotelList.length, (index) => 0);
    foodQuantity = List.generate(widget.foodList.length, (index) => 0);
    cabsQuantity = List.generate(widget.cabsquantity!.length, (index) => 0);

    filteredHotelList =
        widget.hotelList.where((item) => item.includedStatus == 1).toList();
    showTabsDirectly = filteredHotelList.isEmpty;


    //hotelTabs = widget.hotelTypeList ?? [];
    hotelList = widget.hotelList ?? [];

    // Only initialize person quantity if isPersonUse is 1
    if (widget.isPersonUse == 1) {
      addPersonQuantity(0);
      calculateGst(cabFinalAmount[0], widget.tourGst);
      // Add food item for person only
      addFoodItem(
          'Group of',
          cabFinalAmount[0],
          cabsQuantity[0],
          "Per Head",
          '',
          "per_head",
          widget.cabsquantity![0].cabId.toString(),
          '',
          "",
          "",
          ""
          // "${amountAfterTax}",
          // widget.tourGst ?? '',
          // taxAmount
          );
      syncIncludedFoodsWithCabQty(0);
    }

    print("Hotel Quantity:${hotelQuantity.length}");
    print("Food Quantity:${foodQuantity.length}");
    print("Cabs Quantity:${cabsQuantity.length}");
    print("Hotel Tabs:${hotelTabs.length}");
    print("HotelList:${hotelList.length}");
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

  void filterTabs() {
    hotelTabs = (widget.hotelTypeList ?? []).where((tab) {
      return hotelList.any((pkg) =>
      pkg.hotelType.toString() == tab.hotelType.toString() &&
          pkg.includedStatus != 1);
    }).toList();

    print("Hotel Tabs: ${hotelTabs.length}");
  }

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
            dialogBackgroundColor: const Color(0xFFFFF7EC),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Colors.orange,
                backgroundColor: Colors.white,
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _selectedDate = DateFormat('yyyy-MM-dd').format(picked);
        DateTime date = DateTime.parse("${_selectedDate}");
        showingDate = DateFormat("d MMMM y").format(date);
      });
    }
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
            dialogBackgroundColor: Colors.white,
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Colors.orange,
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
            ),
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

  bool hasNonZeroQuantity(List<int> foodQuantity) {
    return foodQuantity.any((quantity) => quantity > 0);
  }

  /// AddCab
  void addCabQuantity(int index) {
    setState(() {
      // Reset all quantities to 0 except the selected one
      for (int i = 0; i < cabsQuantity.length; i++) {
        if (i != index) {
          cabsQuantity[i] = 0;
        }
      }

      // ✅ Always rebuild cabFinalAmount safely (outside loop)
      cabFinalAmount.clear();
      for (int i = 0; i < widget.cabsquantity!.length; i++) {
        int currentPrice =
            int.tryParse(widget.cabsquantity![i].price ?? '0') ?? 0;
        int packageAmount = widget.packageAmount?.toInt() ?? 0;
        cabFinalAmount.add(currentPrice + packageAmount);
      }

      // ✅ Now it's safe to access index
      calculateGst(cabFinalAmount[index], widget.tourGst);

      cabsQuantity[index] = 1; // Set selected item quantity to 1
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
          "",
          "",
          ""
          // amountAfterTax,
          // widget.tourGst ?? '',
          // taxAmount,
          );

      specificCabTotal = cabFinalAmount[index];
    });
  }

  void increaseQuantity(int index, dynamic currentPrice, dynamic cabSeats) {
    if (cabsQuantity[index] < cabSeats) {
      if (index < 0 || index >= cabsQuantity.length)
        return; // Prevent out-of-bounds error
      cabsQuantity[index]++; // Increase quantity
      int packageAmount = widget.packageAmount?.toInt() ?? 0;
      int finalAmount = (currentPrice + packageAmount);
      cabFinalAmount[index] = finalAmount; // Update the list
      calculateGst(cabFinalAmount[index], widget.tourGst);
      addFoodItem(
          widget.cabsquantity![index].enCabName ?? '',
          cabFinalAmount[index],
          cabsQuantity[index],
          "Cab",
          widget.cabsquantity![index].image ?? '',
          "cab",
          widget.cabsquantity![index].cabId.toString(),
          widget.cabsquantity![index].seats ?? '',
          "",
          "",
          ""
          // amountAfterTax,
          // widget.tourGst ?? '',
          // taxAmount,
          );
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
    if (index < 0 || index >= cabsQuantity.length || cabsQuantity[index] <= 0)
      return; // Prevent below 1

    cabsQuantity[index]--; // Decrease quantity

    int packageAmount = widget.packageAmount?.toInt() ?? 0;

    // Calculate new total amount
    int finalAmount = (currentPrice - packageAmount);
    cabFinalAmount[index] = finalAmount; // Update the amount list
    calculateGst(cabFinalAmount[index], widget.tourGst);
    addFoodItem(
        widget.cabsquantity![index].enCabName ?? '',
        cabFinalAmount[index],
        cabsQuantity[index],
        "Cab",
        widget.cabsquantity![index].image ?? '',
        "cab",
        widget.cabsquantity![index].cabId.toString(),
        widget.cabsquantity![index].seats ?? '',
        "",
        "",
        ""
        // amountAfterTax,
        // widget.tourGst ?? '',
        // taxAmount,
        );
    specificCabTotal = cabFinalAmount[index];

    // Reset selection if quantity becomes 0
    if (cabsQuantity[index] == 0) {
      selectedIndex = -1;
      selectedCabQuantity = 0;
    }
  }

  /// Add Person
  void addPersonQuantity(int index) {
    setState(() {
      // Reset all quantities to 0 except the selected one
      for (int i = 0; i < cabsQuantity.length; i++) {
        if (i != index) {
          cabsQuantity[i] = 0;
        }
      }

      // 🔁 Clear and refill cabFinalAmount properly
      cabFinalAmount.clear();
      for (int i = 0; i < widget.cabsquantity!.length; i++) {
        int currentPrice =
            int.tryParse("${widget.cabsquantity![i].price}") ?? 0;
        cabFinalAmount.add(currentPrice);
      }

      // Get the minimum quantity from cab data or default to 1
      int minQuantity = int.tryParse("${widget.cabsquantity![index].min}") ?? 1;
      selectedCabQuantity = minQuantity;
      cabsQuantity[index] =
          minQuantity; // Set selected item quantity to minimum

      // Update final amount
      int currentPrice =
          int.tryParse("${widget.cabsquantity![index].price}") ?? 0;
      cabFinalAmount[index] = currentPrice * minQuantity;
      personQuantity = minQuantity;
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
    personQuantity = cabsQuantity[index];
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
        backgroundColor: Colors.red.shade600,
        icon: Icons.info_outline,
      );
      return;
    }

    // Normal +1 increase
    cabsQuantity[index]++;
    cabFinalAmount[index] = currentPrice * cabsQuantity[index];
    personQuantity = cabsQuantity[index];
    calculateGst(cabFinalAmount[index], widget.tourGst);
    specificCabTotal = cabFinalAmount[index];
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

  /// Check Select (Drop, Pick, Both)
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

  bool isPickFixedLocation = true; // Box 1 (default selected)
  bool isPickAirport = false; // Box 2
  bool isDropFixedLocation = true; // Box 3 (default selected)
  bool isDropAirport = false; // Box 4

  double totalExtraPrice = 0;
  String? selectedPickAirport;
  String? selectedDropAirport;

  void sumTotal() {
    totalTax = 0.0;
    finalPrice = 0.0;
    PackagePrice = 0.0;
    //addTransportAmount = 0.0;
    //addTourTaxAmount = 0.0;
    //addTransportTaxAmount = 0.0;
    totalFinalTax = 0.0;
    totalListPrice = 0.0;

    for (var item in packageItems) {
      final price = double.tryParse(item["price"].toString().trim()) ?? 0.0;
      totalListPrice += price;
    }

    print("Distanc Array ${distanceArray}");

    // for (var item in distanceArray) {
    //   if (item["type"] != "ex_distance") continue;
    //
    //   final pPrice = double.tryParse(item["pprice"].toString().trim()) ?? 0.0;
    //   //final taxPrice = double.tryParse(item["tax_price"].toString().trim()) ?? 0.0;
    //
    //   addTransportAmount += pPrice;
    //   //addTransportTaxAmount += taxPrice;
    // }

    PackagePrice = totalListPrice + totalExtraPrice;

    print("Distanc Array $distanceArray");
    print("Extra Transport amount:$totalExtraPrice");

    /// Here Calculation GST of final Price
    calculateGst(PackagePrice, widget.tourGst);
    finalPrice = PackagePrice + taxAmount;
    totalFinalTax = taxAmount;

    walletMinusAmount = max(
        walletPay -
            (isCouponApplyed
                ? amtAfterDis
                : (selectedAmountIndex == 0 ? finalPrice : halfAmount)),
        0);
    halfAmount = finalPrice / 2;

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

    amtByWallet = walletPay - walletMinusAmount;

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

  List<Map<String, dynamic>> bookingPackage = [];

  void successPayment(String trxId) {
    final leadId = leadController.leadGenerateModel?.data?.insertId;
    print(" Entered successPayment");
    print(
        "leadController.leadGenerateModel: ${leadController.leadGenerateModel}");
    print(
        "leadController.leadGenerateModel?.data: ${leadController.leadGenerateModel?.data}");
    print("leadId (insertId): $leadId");

    print("tourId: ${widget.tourId}");
    print("packageId: ${widget.packageId}");
    print(
        "paymentAmount: ${selectedAmountIndex == 0 ? (isCouponApplyed ? amtAfterDis : finalPrice) : halfAmount}");
    print("qty: $selectedCabQuantity");
    print("pickupAddress: ${widget.locationName}");
    print("pickupDate: $_selectedDate");
    print("pickupTime: $_selectedTime");
    print("pickupLat: ${widget.pickLat}");
    print("pickupLong: ${widget.pickLong}");
    print("useDate: ${widget.useDate}");
    print("transactionId: $trxId");
    print("bookingPackage: $mergedArrayList");
    print("walletType: $successAmountStatus");
    print("onlinePay: $remainingAmount");
    print("couponAmount: $couponAmount");
    print("couponId: $couponId");
    print("partPayment: ${selectedAmountIndex == 0 ? "full" : "part"}");

    successAmountController.successTourAmount(
      tourId: "${widget.tourId}",
      packageId: "${widget.packageId}",
      paymentAmount:
          "${selectedAmountIndex == 0 ? (isCouponApplyed ? amtAfterDis : finalPrice) : halfAmount}",
      qty: "${selectedCabQuantity}",
      pickupAddress: "${widget.locationName}",
      pickupDate: "$_selectedDate",
      pickupTime: "$_selectedTime",
      pickupLat: "${widget.pickLat}",
      pickupLong: "${widget.pickLong}",
      useDate: "${widget.useDate}",
      transactionId: "$trxId",
      bookingPackage: mergedArrayList,
      walletType: "$successAmountStatus",
      onlinePay: "$remainingAmount",
      couponAmount: "$couponAmount",
      couponId: "$couponId",
      leadId: "$leadId",
      context: context,
      partPayment: selectedAmountIndex == 0 ? "full" : "part",
    );
  }

  Future<void> applyCoupon(String code, String finalPackageAmount) async {
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
        //  Move Snackbar outside setState()
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
      selectedCabTotalAmount: "${finalPrice}",
      onApplyCoupon: (code, amount) {
        applyCoupon(couponController.text, "${finalPrice}");
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

  void syncIncludedFoodsWithCabQty(int index) {
    final int cabQty = (cabsQuantity.isNotEmpty ? cabsQuantity[index] : 1);

    print("Cab for food $cabQty");

    for (var i = 0; i < widget.foodList.length; i++) {
      final food = widget.foodList[i];

      // included_status 1 है तो same quantity set करें
      if (food.includedStatus == 1) {
        // foodQuantity और amount भी cabQty पर overwrite करें
        if (i < foodQuantity.length) {
          foodQuantity[i] = cabQty;
        }

        // addFoodItem कॉल करें
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
        // filteredHotelList[0].title,
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
      onWillPop: ()  {
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
                    onTap: ()  {
                      BackHandler.handle(
                        context: context,
                        showDialog: selectOrder == widget.services!.length + 1,
                      );
                    },
                    child: const Icon(Icons.arrow_back_ios)),
                backgroundColor: Colors.white,
                title: Text(
                  "${widget.tourName}",
                  style: TextStyle(
                      fontSize: screenWidth * 0.06,
                      color: Colors.deepOrange),
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

                          /// Per Person
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
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      itemBuilder: (context, index) {
                                        for (int i = 0;
                                            i < widget.cabsquantity!.length;
                                            i++) {
                                          int currentPrice = int.tryParse(widget
                                                      .cabsquantity![i].price ??
                                                  '0') ??
                                              0; // Null-safe conversion
                                          cabFinalAmount.add(
                                              (currentPrice)); // Safe addition
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
                                                  widget.cabsquantity![index]
                                                      .cabId
                                                      .toString(),
                                                  "",
                                                  "",
                                                  "",
                                                  ""
                                                  // amountAfterTax,
                                                  // widget.tourGst ?? '',
                                                  // taxAmount,
                                                  );
                                              syncIncludedFoodsWithCabQty(
                                                  index);
                                            });
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
                                                  widget.cabsquantity![index]
                                                      .cabId
                                                      .toString(),
                                                  "",
                                                  "",
                                                  "",
                                                  ""
                                                  // amountAfterTax,
                                                  // widget.tourGst ?? '',
                                                  // taxAmount,
                                                  );
                                              syncIncludedFoodsWithCabQty(
                                                  index);
                                            });
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
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      itemBuilder: (context, index) {
                                        for (int i = 0;
                                            i < widget.cabsquantity!.length;
                                            i++) {
                                          int currentPrice = int.tryParse(widget
                                                      .cabsquantity![i].price ??
                                                  '0') ??
                                              0; // Null-safe conversion
                                          int packageAmount =
                                              widget.packageAmount?.toInt() ??
                                                  0; // Null safety check
                                          cabFinalAmount.add((currentPrice +
                                              packageAmount)); // Safe addition
                                        }

                                        return CabInfoCard(
                                          imageUrl: widget
                                                  .cabsquantity![index].image ??
                                              '',
                                          cabName: widget.translateEn == "en"
                                              ? widget.cabsquantity![index]
                                                      .enCabName ??
                                                  ''
                                              : widget.cabsquantity![index]
                                                      .hiCabName ??
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
                                              int.parse(
                                                  "${cabFinalAmount[index]}"),
                                              widget
                                                  .cabsquantity![index].seats),
                                          onDecreaseTap: () => decreaseQuantity(
                                              index,
                                              int.parse(
                                                  "${cabFinalAmount[index]}")),
                                          onClearTap: () {
                                            setState(() {
                                              cabsQuantity[index] = 0; // Reset your quantity state variable
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
                                                "",
                                                '',
                                                "",
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
                                                "",
                                                '',
                                                "",
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
                                                "",
                                                '',
                                                "",
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
                                                "",
                                                '',
                                                "",
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
                                                    });
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

                                          //  TabBarView
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
                                                  shrinkWrap: true,
                                                  itemCount: packagesForTab.length,
                                                  itemBuilder:
                                                      (context, index) {
                                                    final package = packagesForTab[index];
                                                    int originalIndex =
                                                        hotelList.indexWhere(
                                                      (p) =>
                                                          p.packageId ==
                                                          package.packageId,
                                                    );
                                                    return CabInfoCard(
                                                      imageUrl:
                                                          package.image ?? '',
                                                      cabName: widget
                                                                  .translateEn ==
                                                              "en"
                                                          ? "${package.enPackageName}"
                                                          : "${package.hiPackageName}",
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
                                                            "",
                                                            '',
                                                            "",
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
                                                            "",
                                                            '',
                                                            "",
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
                                          // const SizedBox(height: 500),
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
                                                  "",
                                                  '',
                                                  "",
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
                                                  "",
                                                  '',
                                                  "",
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
                                      hotelTabs.isEmpty ? SizedBox() :
                                      SizedBox(
                                        width: double.infinity,
                                        child: Container(
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(30),
                                            gradient: const LinearGradient(
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
                                                offset: const Offset(0, 4),
                                              ),
                                            ],
                                          ),
                                          child: ElevatedButton.icon(
                                            onPressed: () {
                                              setState(() {
                                                isCustomSelected = true;
                                              });
                                            },
                                            label: const Text("Customization",
                                                style: TextStyle(fontSize: 16)),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                                  Colors.transparent,
                                              foregroundColor: Colors.white,
                                              shadowColor: Colors.transparent,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 12,
                                                      horizontal: 20),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(30),
                                              ),
                                              textStyle: const TextStyle(
                                                fontWeight: FontWeight.w700,
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
                                                  "${widget.hotelList[i].price}") ??
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
                                                "",
                                                '',
                                                "",
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
                                                "",
                                                '',
                                                "",
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

                  /// Info Screen
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
                                const SizedBox(
                                  height: 10.0,
                                ),

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
                                      // itemBuilder function returns a widget for each item in the list
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

                                widget.isPersonUse == 0
                                    ? Row(
                                        children: [
                                          const Icon(
                                            Icons.location_on_outlined,
                                            color: Colors.orange,
                                          ),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
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
                                        ],
                                      )
                                    : Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          // Pickup Section
                                          const Text(
                                            "Pick From",
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black,
                                            ),
                                          ),
                                          const SizedBox(height: 10),
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

                                          const SizedBox(height: 20),

                                          // Drop Section
                                          const Text(
                                            "Drop To",
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black,
                                            ),
                                          ),
                                          const SizedBox(height: 10),
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
                                                  //'₹$totalExtraPrice',
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

                  /// Payment Screen
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
                              selectedCabTotalAmount = double.tryParse(
                                      packageItems[index]["price"]
                                          .toString()) ??
                                  0.0;

                              return Container(
                                padding: const EdgeInsets.all(10),
                                margin: const EdgeInsets.only(bottom: 5),
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
                                            maxLines: 1,
                                          ),
                                          Text(
                                              selectedCabTotalAmount == 0
                                                  ? "INCLUDED"
                                                  : "Total: ${formatIndianCurrency(selectedCabTotalAmount)}",
                                              style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w500,
                                                  color:
                                                      selectedCabTotalAmount ==
                                                              0
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

                          if (onlyPickUp || onlyDrop || both)
                            ListView.builder(
                              shrinkWrap: true,
                              itemCount: distanceArray.length,
                              physics: const NeverScrollableScrollPhysics(),
                              itemBuilder: (context, index) {
                                return Container(
                                  padding: const EdgeInsets.all(10),
                                  margin: const EdgeInsets.only(bottom: 5),
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
                                                       // : "Extra Distance Amount: ₹${distanceArray[index]["pprice"]}",
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

                                          // distanceArray[index]["tax_price"] == "" ? const SizedBox() :
                                          // Text("Tax Price: ₹${distanceArray[index]["tax_price"]}")
                                        ],
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          const SizedBox(
                            height: 15,
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
                                      setState(() {
                                        selectedAmountIndex = 1;
                                        isCouponApplyed = false;
                                      });
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

                          /// Applying Coupon
                          selectedAmountIndex == 0
                              ? Column(
                                  children: [
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    couponBox(
                                      context: context,
                                      isApplied: isCouponApplyed,
                                      hasCoupons: fetchCouponController
                                          .couponlist.isNotEmpty,
                                      onApply: showCouponSheet,
                                      onRemove: () {
                                        setState(() => isCouponApplyed = false);
                                      },
                                    ),
                                  ],
                                )
                              : const SizedBox(),
                          const SizedBox(
                            height: 10,
                          ),

                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.grey.shade300),
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
                                    color: Colors.orange,
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
                                      //"₹${(PackagePrice).toStringAsFixed(2)}",
                                      "${formatIndianCurrency(PackagePrice)}",
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
                                        color: Colors.red,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),

                                // Divider
                                const Divider(color: Colors.grey, height: 1),
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
                                      //"₹${finalPrice.toStringAsFixed(2)}",
                                      "${formatIndianCurrency(finalPrice)}",
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontFamily: 'Roboto',
                                        color: Colors.green,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),

                                // Discount Section
                                const Divider(color: Colors.grey, height: 1),
                                const SizedBox(height: 8),
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
                                        color: isCouponApplyed
                                            ? Colors.red
                                            : Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),

                                // Wallet Section
                                const Divider(color: Colors.grey, height: 1),
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
                                      //"- ₹${amtByWallet.toStringAsFixed(2)}",
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

                                // Final Amount
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    Text(
                                      widget.translateEn == "en"
                                          ? "Total Amount"
                                          : "कुल राशि",
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
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'Roboto',
                                        color: Colors.orange,
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
                          selectOrder == widget.services!.length + 1
                              ? SizedBox()
                              : totalAmountDisplay(
                                  amount:
                                      "${specificCabTotal + specificFoodTotal + specificHotelTotal + int.parse("${selectedExPrice}")}",
                                ),
                          const SizedBox(height: 10),

                          selectOrder == widget.services!.length + 1
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
                                                '${remainingAmount == 0 ? selectedCabTotalAmount : remainingAmount}',
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
                                              description: 'Tour screen',
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
                                            if (selectOrder ==
                                                widget.services!.length) {
                                              // Check if we're on the info page
                                              if (_selectedDate == null ||
                                                  _selectedDate!.isEmpty ||
                                                  _selectedTime == null ||
                                                  _selectedTime!.isEmpty) {
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
                                                sumTotal();
                                                nextPage();
                                                print("BUtoon clicked");
                                                // minusWalletTourPrice(finalPrice);
                                              }
                                            } else {
                                              // If we're not on the info page, just go to the next page
                                              nextPage();
                                              if (onlyPickUp ||
                                                  onlyDrop ||
                                                  both) getSelectedPrice();
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
