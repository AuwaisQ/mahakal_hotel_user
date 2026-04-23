import 'dart:convert';
import 'dart:math';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mahakal/features/location/screens/select_location_screen.dart';
import 'package:mahakal/features/location/widgets/location_search_dialog_widget.dart';
import 'package:mahakal/features/tour_and_travells/Controller/tour_location_controller.dart';
import 'package:mahakal/main.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:mahakal/features/tour_and_travells/model/lead_generate_model.dart';
import 'package:mahakal/features/tour_and_travells/model/success_amount_model.dart';
import 'package:mahakal/utill/app_constants.dart';
import 'package:intl/intl.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:provider/provider.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
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
import '../../model/distance_model.dart';
import '../../widgets/ApplyCoupon.dart';
import '../../widgets/backhandler.dart';
import '../../widgets/cab_info_card.dart';
import '../../widgets/info_dialog.dart';
import '../../widgets/person_card_widget.dart';
import '../../widgets/showbeautifulltoast.dart';
import '../../widgets/total_amount_display.dart';

class CityTourType extends StatefulWidget {
  const CityTourType({
    super.key,
    required this.services,
    required this.cabsquantity,
    required this.hotelList,
    required this.foodList,
    required this.tourId,
    required this.packageId,
    required this.translateEn,
    required this.timeSlot,
    required this.exDistance,
    required this.useDate,
    required this.isPersonUse,
    required this.tourGst,
    required this.transPortGst,
    required this.tourName,
    this.hotelTypeList,
    required this.locationName,
  });

  final List<String>? services;
  final List<HotelTypeList>? hotelTypeList;
  final List<CabList>? cabsquantity;
  final List<PackageList> hotelList;
  final List<PackageList> foodList;
  final List<dynamic>? timeSlot;
  final String tourId;
  final String? packageId;
  final String translateEn;
  final int? exDistance;
  final String useDate;
  final int isPersonUse;
  final dynamic tourGst;
  final dynamic transPortGst;
  final String tourName;
  final String locationName;

  @override
  State<CityTourType> createState() => _CityTourTypeState();
}

class _CityTourTypeState extends State<CityTourType> with SingleTickerProviderStateMixin {
  final razorpayService = RazorpayPaymentService();
  final TextEditingController countryController = TextEditingController();
  final TextEditingController couponController = TextEditingController();
  final ValueNotifier<bool> _distanceValidNotifier = ValueNotifier<bool>(true);
  final leadController =
      Provider.of<TourLeadController>(Get.context!, listen: false);
  final successAmountController =
      Provider.of<SuccessTourAmountController>(Get.context!, listen: false);
  final fetchCouponController =
      Provider.of<FetchCouponController>(Get.context!, listen: false);
  final walletController =
      Provider.of<FetchWalletController>(Get.context!, listen: false);
  final Map<String, ScrollController> _scrollControllers = {
    'transport': ScrollController(),
    'foods': ScrollController(),
    'hotel': ScrollController(),
  };

  List<CityPickerModel> cityListModel = <CityPickerModel>[];
  final List<int> quantity = List.generate(10, (index) => 0);
  List<Map<String, dynamic>> items = [];

  String userId = "";
  String userNAME = "";
  String userEMAIL = "";
  String userPHONE = "";
  String userToken = "";
  String couponType = "";
  String orderIdPooja = "";
  String serviceCouponType = "";
  String latiTude = "";
  String longiTude = "";
  //String _selectedOption = 'pickup';
  String? selectedCabId;
  String? _selectedDate;
  String? _selectedTime;
  String? showingDate;
  String? currentSelectedTab;

  double amtByWallet = 0.0;
  double walletPay = 0.0;
  double walletMinusAmount = 0.0;
  double remainingAmount = 0.0;
  double finalAmount = 0.0;

  int selectOrder = 0;
  int listSumAmount = 0;
  int? successAmountStatus;
  int? naviGateRazorpay;
  int selectedCabQuantity = 0;
  int couponId = 0;
  int? personQuantity;
  int selectedIndex = -1;

  dynamic totalInlcludePackageAmount = 0.0;
  dynamic itemTotalAmount = 0;
  dynamic taxAmount = 0;
  dynamic amountAfterTax = 0;
  dynamic specificCabTotal = 0;
  dynamic specificFoodTotal = 0;
  dynamic specificHotelTotal = 0;

  late List<int> hotelQuantity;
  late List<int> cabsQuantity;
  late dynamic finalPrice;
  late dynamic PackagePrice;
  late dynamic totalFinalTax;

  bool showTabsDirectly = false;
  bool searchbox = false;
  bool timeBox = false;
  bool extraDistBox = false;
  bool isCouponApplyed = false;
  bool isLoading = false;
  bool iswalletLaoding = false;
  bool isDistanceFetched = false;
  bool circularIndicator = false;
  bool isCustomSelected = false; // state variable

  final List<GlobalKey> itemKeys = [];
  List<Map<String, dynamic>> packageItems = [];
  List<int> selectedIndexes = [0];
  List<int> productAmounts = [];
  List<int> foodQuantity = [];
  List<int> cabFinalAmount = [];
  List<int> foodFinalAmount = [];
  List<int> hotelFinalAmount = [];
  List<PackageList> filteredHotelList = [];

  double couponAmount = 0;
  double amtAfterDis = 0;
  double distance = 0.0;
  GoogleMapController? _controller;

  //Country Picker
  Country _selectedCountry = Country(
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
        "country": "${_selectedCountry.name}",
        "name": "${countryController.text}",
      },
    );
    if (response.statusCode == 200) {
      setState(() {
        var result = json.decode(response.body);
        print("Api response $result");
        List listLocation = result;
        cityListModel
            .addAll(listLocation.map((e) => CityPickerModel.fromJson(e)));
        print("City Model :${cityListModel}");
      });
    } else {
      print("Failed Api Rresponse");
    }
  }

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
    //print("My Total Vehical Tax: ${totalVehicleTax}");

    return {
      'taxAmount': taxAmount,
      'amountAfterTax': amountAfterTax,
    };
  }

  SuccessAmountModel? successAmountData;
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
              primary: Colors.blue.shade100,
              onPrimary: Colors.blue,
              surface: const Color(0xFFFFF7EC),
              onSurface: Colors.blue,
            ),
            dialogBackgroundColor: const Color(0xFFFFF7EC),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Colors.blue,
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
        showingDate = DateFormat("d MMMM y").format(date); //
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
              dialHandColor: Colors.blue.shade100,
              dialTextColor: Colors.blue,
              dialBackgroundColor: Colors.white,
              dayPeriodColor: Colors.white,
              dayPeriodTextColor: Colors.blue,
              backgroundColor: const Color(0xFFFFF7EC),
              hourMinuteTextColor: Colors.blue,
              hourMinuteColor: Colors.white,
              inputDecorationTheme: const InputDecorationTheme(
                border: InputBorder.none,
                filled: true,
                fillColor: Colors.white,
                hintStyle: TextStyle(color: Colors.blue),
                labelStyle: TextStyle(color: Colors.blue),
              ),
            ),
            dialogBackgroundColor: Colors.white,
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Colors.blue,
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

  /// AddCab
  void addCabQuantity(int index) {
    setState(() {
      // ✅ Step 1: Reset all other quantities
      for (int i = 0; i < cabsQuantity.length; i++) {
        if (i != index) {
          cabsQuantity[i] = 0;
        }
      }

      // ✅ Step 2: Safely rebuild the cabFinalAmount list
      cabFinalAmount.clear();
      for (int i = 0; i < widget.cabsquantity!.length; i++) {
        int currentPrice =
            int.tryParse(widget.cabsquantity![i].price ?? '0') ?? 0;
        cabFinalAmount.add(currentPrice);
      }

      // ✅ Step 3: Now it is safe to access cabFinalAmount[index]
      cabsQuantity[index] = 1;
      selectedCabQuantity = 1;
      selectedIndex = index;

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
        "0",
        "0",
        "0",
      );

      specificCabTotal = cabFinalAmount[index];
    });
  }

  void increaseQuantity(int index, int currentPrice) {
    if (index < 0 || index >= cabsQuantity.length) {
      return; // Prevent out-of-bounds error
    }

    cabsQuantity[index]++; // Increase quantity
    int finalAmount = (currentPrice * cabsQuantity[index]);
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
      //amountAfterTax,
      "0",
      "0",
      "0",
    );
    specificCabTotal = cabFinalAmount[index];
  }

  void decreaseQuantity(int index, int currentPrice) {
    // Validate index
    if (index < 0 || index >= cabsQuantity.length) return;

    // Decrease quantity (can go to 0)
    if (cabsQuantity[index] > 0) {
      cabsQuantity[index]--;

      // Calculate new total amount
      int finalAmount = (currentPrice * cabsQuantity[index]);
      cabFinalAmount[index] = finalAmount;

      // Update GST calculations
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
        // amountAfterTax,
        "0",
        "0",
        "0",
      );
      specificCabTotal = cabFinalAmount[index];
    }

    // Reset selection if quantity becomes 0
    if (cabsQuantity[index] == 0) {
      selectedIndex = -1;
      selectedCabQuantity = 0;
    }
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
        backgroundColor: Colors.blue.shade600,
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

  /// Fetch Distance and Calculate Extra Charge
  void onLocationSelect() async {
    print("City lat ${latiTude}");
    print("City long ${longiTude}");

    final calculatedDistance = await fetchDistance(latiTude, longiTude);
    print("Fetched Distance: ${calculatedDistance}");

    if (calculatedDistance > 20) {
      // Distance is more than 20 km
      _distanceValidNotifier.value = false;

      // Optionally vibrate for feedback
      HapticFeedback.vibrate();

      // Keep the text in controller but show warning
      // Don't clear automatically
    } else {
      // Distance is valid
      _distanceValidNotifier.value = true;
      searchbox = false;

      // Optional: Show success message briefly
      Future.delayed(const Duration(milliseconds: 300), () {
        BeautifulToast.show(
          context,
          widget.translateEn == "en"
              ? "Location selected successfully!"
              : "स्थान सफलतापूर्वक चयनित!",
          backgroundColor: Colors.green,
          icon: Icons.check_circle_outlined,
        );
      });
    }
  }

  Future<double> fetchDistance(String lat, String longi) async {
    Map<String, dynamic> data = {
      "tour_id": widget.tourId,
      "lat": lat,
      "long": longi
    };

    try {
      setState(() {
        isDistanceFetched = true;
      });

      final res = await HttpService().postApi(
          "${AppConstants.fetchTourDistanceUrl}", data); // 🔄 Replaced here

      if (res != null) {
        final distanceData = DistanceModel.fromJson(res);
        setState(() {
          distanceModel = distanceData;
          distance = distanceModel!.data!; // Make sure this is a double
          print("Tour Distance:${distance}");
        });
        return distance;
      }
    } catch (e) {
      print("Error fetching distance: $e");
    } finally {
      setState(() {
        isDistanceFetched = false;
      });
    }
    return 100; // Default fallback value
  }

  void sumTotal(){
    // print("My List: ${packageItems}");
    finalPrice = 0.0;
    PackagePrice = 0.0;
    totalFinalTax = 0.0;

    // Calculate total amount for all items
    for (var item in packageItems) {
      // finalPrice += item["qty"] * item["price"];
      //finalPrice += item["price"];
      PackagePrice += item["price"];
    }

    /// Here Calculation GST of final Price
    calculateGst(PackagePrice, widget.tourGst);
    finalPrice = PackagePrice + taxAmount;
    totalFinalTax = taxAmount;

    walletMinusAmount =
        max(walletPay - (isCouponApplyed ? amtAfterDis : finalPrice), 0);
    amtByWallet = walletPay - walletMinusAmount;

    /// Logic for cutting amt from wallet
    if (walletPay >= (isCouponApplyed ? amtAfterDis : finalPrice)) {
      // Wallet me pura paisa available hai, to remainingAmount 0 hoga
      remainingAmount = 0;
    } else {
      // Agar wallet me kam paisa hai, to remainingAmount calculate hoga
      remainingAmount =
          (isCouponApplyed ? amtAfterDis : finalPrice) - walletPay;
    }

    /// Logic for Payment Status (Wallet status , 1 or 0)
    if (walletPay >= (isCouponApplyed ? amtAfterDis : finalPrice)) {
      // Pura amount wallet se katega
      successAmountStatus = 1;
      naviGateRazorpay = 1;
    } else if (walletPay > 0 &&
        walletPay < (isCouponApplyed ? amtAfterDis : finalPrice)) {
      // Adha wallet se, adha Razorpay se katega
      successAmountStatus = 1;
      naviGateRazorpay = 2;
    } else {
      // Pura payment Razorpay se hoga
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

    print("✅ successPayment() called");
    print("My Tour Packages: ${packageItems}");
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
        paymentAmount: "${isCouponApplyed ? amtAfterDis : finalPrice}",
        //qty: personQuantity is String ? "1" : personQuantity,
        qty: "${personQuantity}",
        pickupAddress: "${countryController.text}",
        pickupDate: "$_selectedDate",
        pickupTime: "$_selectedTime",
        pickupLat: "$latiTude",
        pickupLong: "$longiTude",
        useDate: "${widget.useDate}",
        transactionId: "$trxId",
        bookingPackage: packageItems,
        walletType: "$successAmountStatus",
        onlinePay: "$remainingAmount",
        couponAmount: "$couponAmount",
        couponId: "$couponId",
        leadId: "$leadId", // This will now always be non-null
        context: context,
        partPayment: "");
  }

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
                backgroundColor: Colors.blue, // Primary color
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

  List<HotelTypeList> hotelTabs = [];
  List<PackageList> hotelList = [];
  int selectedTabIndex = 0;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    print("City Name:${widget.locationName}");
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await walletController.fetchWallet();
      setState(() {
        walletPay = walletController.walletPay;
      });
      print("Wallet Amount${walletPay}");
    });

    userId = Provider.of<ProfileController>(Get.context!, listen: false).userID;
    userNAME = Provider.of<ProfileController>(Get.context!, listen: false).userNAME;
    userEMAIL = Provider.of<ProfileController>(Get.context!, listen: false).userEMAIL;
    userPHONE = Provider.of<ProfileController>(Get.context!, listen: false).userPHONE;
    userToken = Provider.of<AuthController>(Get.context!, listen: false).getUserToken();
    fetchCouponController.fetchCoupon(type: "tour", couponUrl: "${AppConstants.tourCouponUrl}");

    // Initialize keys for each service and one extra for "Payment".
    for (int i = 0; i < widget.services!.length + 2; i++) {
      itemKeys.add(GlobalKey());
    }

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

    filteredHotelList = widget.hotelList.where((item) => item.includedStatus == 1).toList();
    print("Filtered Hotel List: ${filteredHotelList.length}");
    showTabsDirectly = filteredHotelList.isEmpty;

    hotelTabs = widget.hotelTypeList ?? [];
    hotelList = widget.hotelList ?? [];
    _tabController = TabController(length: hotelTabs.length, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        setState(() {
          selectedTabIndex = _tabController.index;
        });
      }
    });

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
        //"${amountAfterTax}",
        //"${cabFinalAmount[0] + taxAmount}",
        //widget.tourGst ?? '', // tax)
        //taxAmount // tax_price
      );

      syncIncludedFoodsWithCabQty(0);
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
    countryController.dispose();
    _distanceValidNotifier.dispose();
    _scrollControllers.values.forEach((controller) => controller.dispose());
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
                      color: Colors.black),
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
                                            : Colors.blue
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
                                            ? Colors.blue
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
                                            ? Colors.blue
                                            : Colors.blue
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
                                            ? Colors.blue
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
                                        ? Colors.blue
                                        : Colors.blue.withOpacity(0.07),
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
                                              color: Colors.blue),
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
                                                //amountAfterTax,
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
                                                //amountAfterTax,
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
                                              color: Colors.blue),
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
                                      //reverse: true,
                                      itemCount: widget.cabsquantity!.length,
                                      physics: const NeverScrollableScrollPhysics(),
                                      itemBuilder: (context, index) {
                                        //Calculate prices (move outside builder if possible)
                                        for (int i = 0;
                                            i < widget.cabsquantity!.length;
                                            i++) {
                                          int currentPrice = int.tryParse(widget
                                                      .cabsquantity![i].price ??
                                                  '0') ??
                                              0;
                                          cabFinalAmount.add(currentPrice);
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
                                          unitPrice: widget
                                                  .cabsquantity![index].price ??
                                              '',
                                          totalLabel: "Total",
                                          totalPrice: cabsQuantity[index] == 0
                                              ? "00"
                                              : "${cabFinalAmount[index]}",
                                          quantity: cabsQuantity[index],
                                          isEnglish: widget.translateEn == "en",
                                          personInCab: false,
                                          widgetIndex: index,
                                          selectedIndex: selectedIndex,
                                          isSelected: selectedIndex == index,
                                          isPersonWise: false,
                                          onSelect: () {
                                            setState(() {
                                              selectedIndex = index;
                                            });
                                          },
                                          onAddTap: () => addCabQuantity(index),
                                          onIncreaseTap: () => increaseQuantity(
                                              index,
                                              int.parse(
                                                  "${widget.cabsquantity![index].price}")),
                                          onDecreaseTap: () => decreaseQuantity(
                                              index,
                                              int.parse(
                                                  "${widget.cabsquantity![index].price}")),
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
                                              color: Colors.blue),
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
                                              color: Colors.blue),
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
                                                color: Colors.blue,
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
                                                      color: Colors.blue
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
                                                    color: Colors.blue
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
                                                color: Colors.blue
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
                                              color: Colors.blue),
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

                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      widget.translateEn == "en"
                                          ? '${widget.locationName} Pickup Location (Railway Station, Bus Stand, Hotel)'
                                          : "${widget.locationName} पिकअप स्थान (रेलवे स्टेशन, बस स्टैंड, होटल)",
                                      style: const TextStyle(
                                        fontSize: 16,
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      maxLines: 2,
                                    ),
                                    const SizedBox(height: 8),

                                    // LocationSearchWidget use
                                    LocationSearchWidget(
                                        hintText: 'Search location',
                                      mapController: _controller,
                                      controller: countryController,
                                      onLocationSelected: (lat, lng, address) {
                                        setState(() {
                                          latiTude = lat.toString();
                                          longiTude = lng.toString();
                                        });
                                        onLocationSelect();
                                      },
                                    ),

                                    // Distance validation message container
                                    ValueListenableBuilder<bool>(
                                      valueListenable: _distanceValidNotifier, // Add this notifier
                                      builder: (context, isDistanceValid, child) {
                                        if (!isDistanceValid && countryController.text.isNotEmpty) {
                                          return AnimatedSwitcher(
                                            duration: const Duration(milliseconds: 300),
                                            child: Container(
                                              key: ValueKey(countryController.text),
                                              margin: const EdgeInsets.only(top: 8),
                                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                              decoration: BoxDecoration(
                                                color: Colors.red.shade50,
                                                borderRadius: BorderRadius.circular(10),
                                                border: Border.all(
                                                  color: Colors.red.shade200,
                                                  width: 1.5,
                                                ),
                                                gradient: LinearGradient(
                                                  begin: Alignment.centerLeft,
                                                  end: Alignment.centerRight,
                                                  colors: [
                                                    Colors.red.shade50,
                                                    Colors.red.shade100.withOpacity(0.5),
                                                  ],
                                                ),
                                              ),
                                              child: Row(
                                                children: [
                                                  Container(
                                                    padding: const EdgeInsets.all(6),
                                                    decoration: BoxDecoration(
                                                      color: Colors.red.shade100,
                                                      shape: BoxShape.circle,
                                                    ),
                                                    child: Icon(
                                                      Icons.location_on_outlined,
                                                      color: Colors.red.shade700,
                                                      size: 18,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 12),
                                                  Expanded(
                                                    child: Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        Text(
                                                          widget.translateEn == "en"
                                                              ? "Location Too Far"
                                                              : "स्थान बहुत दूर है",
                                                          style: TextStyle(
                                                            fontSize: 14,
                                                            fontWeight: FontWeight.w600,
                                                            color: Colors.red.shade800,
                                                          ),
                                                        ),
                                                        const SizedBox(height: 2),
                                                        Text(
                                                          widget.translateEn == "en"
                                                              ? "Pickup allowed only within 20 km (Bus Stand, Railway Station, Hotels)"
                                                              : "पिकअप केवल 20 किमी के भीतर अनुमत है (बस स्टैंड, रेलवे स्टेशन, होटल)",
                                                          style: TextStyle(
                                                            fontSize: 13,
                                                            color: Colors.red.shade700,
                                                            height: 1.4,
                                                          ),
                                                          maxLines: 2,
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  IconButton(
                                                    onPressed: () {
                                                      // Clear the location and hide message
                                                      countryController.clear();
                                                      _distanceValidNotifier.value = true;
                                                    },
                                                    icon: Icon(
                                                      Icons.close_rounded,
                                                      color: Colors.red.shade600,
                                                      size: 20,
                                                    ),
                                                    padding: EdgeInsets.zero,
                                                    constraints: const BoxConstraints(),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          );
                                        }
                                        return const SizedBox.shrink();
                                      },
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
                                  duration: const Duration(
                                      milliseconds:
                                          600), // Adjust animation duration for smooth transition
                                  curve: Curves
                                      .easeInCirc, // Customize animation curve if needed
                                  padding: const EdgeInsets.all(8.0),
                                  height: timeBox == false ? 0 : 150,
                                  decoration: BoxDecoration(
                                      color: Colors.white,
                                      border: Border.all(color: Colors.grey),
                                      borderRadius: BorderRadius.circular(6.0)),
                                  child: ListView.builder(
                                    shrinkWrap: true,
                                    physics: const BouncingScrollPhysics(),
                                    itemCount: widget.timeSlot!
                                        .length, // Number of items in the list
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
                              // totalFinalTax = packageItems[index]["tax_price"];
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
                                                  //: "Total: ₹${itemTotalAmount.toStringAsFixed(2)}",
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

                                    //SizedBox(width: 10,),

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

                          /// Applying Coupon
                          couponBox(
                            context: context,
                            isApplied: isCouponApplyed,
                            hasCoupons:
                                fetchCouponController.couponlist.isNotEmpty,
                            onApply: showCouponSheet,
                            onRemove: () {
                              setState(() => isCouponApplyed = false);
                            },
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.15),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                /// Heading
                                Text(
                                  widget.translateEn == "en"
                                      ? "Bill Details"
                                      : "बिल विवरण",
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Roboto',
                                    color: Colors.blue,
                                  ),
                                ),
                                const SizedBox(height: 16),

                                /// Package Price
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        widget.translateEn == "en"
                                            ? "Package Price"
                                            : "पैकेज राशि",
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w400,
                                          fontFamily: 'Roboto',
                                          color: Colors.black,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      formatIndianCurrency(PackagePrice),
                                      //"₹${(PackagePrice).toStringAsFixed(2)}",
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontFamily: 'Roboto',
                                        color: Colors.blueGrey,
                                      ),
                                    )
                                  ],
                                ),
                                const SizedBox(height: 8),

                                /// Tax
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        widget.translateEn == "en"
                                            ? "Tax Total (${widget.tourGst}% GST)"
                                            : "कुल टैक्स (${widget.tourGst}% GST)",
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w400,
                                          fontFamily: 'Roboto',
                                          color: Colors.black,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      formatIndianCurrency(totalFinalTax),
                                      //"₹${totalFinalTax}",
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontFamily: 'Roboto',
                                        color: Colors.red,
                                      ),
                                    )
                                  ],
                                ),
                                const SizedBox(height: 10),
                                const Divider(thickness: 1),

                                /// Total Price
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        widget.translateEn == "en"
                                            ? "Total Price"
                                            : "कुल राशि",
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w400,
                                          fontFamily: 'Roboto',
                                          color: Colors.black,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      formatIndianCurrency(finalPrice),
                                      //"₹${finalPrice.toStringAsFixed(2)}",
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontFamily: 'Roboto',
                                        color: Colors.green,
                                      ),
                                    )
                                  ],
                                ),
                                const SizedBox(height: 10),

                                /// Special Discount
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        widget.translateEn == "en"
                                            ? "Special Discount"
                                            : "विशेष छूट",
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w400,
                                          fontFamily: 'Roboto',
                                          color: Colors.black,
                                        ),
                                      ),
                                    ),
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
                                    )
                                  ],
                                ),
                                const SizedBox(height: 10),
                                const Divider(thickness: 1),

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

                                /// Final Amount
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        widget.translateEn == "en"
                                            ? "Total Payable Amount"
                                            : "कुल देय राशि",
                                        style: const TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.w600,
                                          fontFamily: 'Roboto',
                                          color: Colors.black,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      //"₹${remainingAmount.toStringAsFixed(2)}",
                                      "${formatIndianCurrency(remainingAmount)}",
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w600,
                                        fontFamily: 'Roboto',
                                        color: Colors.blue,
                                      ),
                                    )
                                  ],
                                ),
                                const SizedBox(height: 10),
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
                          selectOrder == widget.services!.length + 1
                              ? SizedBox()
                              : totalAmountDisplay(
                                  amount: "${specificCabTotal + specificFoodTotal + specificHotelTotal}",
                                ),
                          const SizedBox(height: 10),

                          //  Buttons Row
                          selectOrder == widget.services!.length + 1
                              ? Row(
                                  children: [
                                    GestureDetector(
                                      onTap: () {
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
                                    Expanded(
                                      child: GestureDetector(
                                        onTap: () {
                                          leadController.generateTourLead(
                                            tourId: widget.tourId,
                                            packageId: widget.packageId.toString(),
                                            amount: '${remainingAmount == 0 ? finalPrice : remainingAmount}',
                                          );
                                          if (naviGateRazorpay == 2) {
                                            razorpayService.openCheckout(
                                              amount: remainingAmount, // ₹100
                                              razorpayKey: AppConstants.razorpayLive,
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
                                        onTap: previousPage,
                                        child: Container(
                                          height: 45,
                                          margin:
                                              const EdgeInsets.only(right: 5),
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(8.0),
                                            color: selectOrder == 0
                                                ? Colors.grey
                                                : Colors.blue,
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
                                          final isDateEmpty =
                                              _selectedDate?.isEmpty ?? true;
                                          final isTimeEmpty =
                                              _selectedTime?.isEmpty ?? true;
                                          final isCountryEmpty =
                                              countryController.text
                                                  .trim()
                                                  .isEmpty;

                                          if (selectOrder ==
                                                  widget.services!.length &&
                                              (isDateEmpty ||
                                                  isTimeEmpty ||
                                                  isCountryEmpty)) {
                                            BeautifulToast.show(
                                              context,
                                              widget.translateEn == "en"
                                                  ? "Form fields Required!"
                                                  : "फॉर्म फ़ील्ड आवश्यक!",
                                              backgroundColor: Colors.red,
                                              icon: Icons.error,
                                            );
                                          } else {
                                            nextPage();
                                          }
                                        },
                                        child: Container(
                                          height: 45,
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(8.0),
                                            color: Colors.blue,
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
                    )
                  : null,
            ),
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
            border: Border.all(color: Colors.blue),
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
                Icon(icon, color: Colors.blue, size: 28),
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
