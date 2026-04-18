import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:country_picker/country_picker.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mahakal/data/datasource/remote/http/httpClient.dart';
import 'package:mahakal/features/order/screens/track_screens/track_chadhava_screen.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geocoding/geocoding.dart';
import 'package:intl/intl.dart';
import 'package:mahakal/features/order/screens/track_screens/track_donation_details.dart';
import 'package:mahakal/utill/loading_datawidget.dart';
import 'package:page_animation_transition/animations/right_to_left_transition.dart';
import 'package:page_animation_transition/page_animation_transition.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../main.dart';
import '../../../../utill/app_constants.dart';
import '../../../../utill/flutter_toast_helper.dart';
import '../../../../utill/razorpay_screen.dart';
import '../../../auth/controllers/auth_controller.dart';
import '../../../maha_bhandar/model/city_model.dart';
import '../../../offline_pooja/view/offlinepersondetails.dart';
import '../../../profile/controllers/profile_contrroller.dart';
import '../../../support/screens/support_ticket_screen.dart';
import '../../model/trackdOfflinedetail_model.dart';
import 'package:http/http.dart' as http;

import 'invoice_view_screen.dart';

class OfflinePoojaTrackOrder extends StatefulWidget {
  final String poojaId;
  const OfflinePoojaTrackOrder({super.key, required this.poojaId});

  @override
  State<OfflinePoojaTrackOrder> createState() => _OfflinePoojaTrackOrderState();
}

class _OfflinePoojaTrackOrderState extends State<OfflinePoojaTrackOrder> {
  final billFormKey = GlobalKey<FormState>();

  final TextEditingController _venueAddressController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _landMarkController = TextEditingController();
  final TextEditingController _pincodeController = TextEditingController();
  List<CityPickerModel> cityListModel = <CityPickerModel>[];
  final TextEditingController _suggestionsController = TextEditingController();
  final TextEditingController _cancelController = TextEditingController();
  final TextEditingController roleIdController = TextEditingController();

  int _selectedRating = 3; // Initially all options are unchecked
  int noPerson = 0;
  double latiTude = 0.0;
  double longiTude = 0.0;
  double walletPay = 0.0;
  double walletMinusAmount = 0.0;
  double finalAmount = 0.0;
  String userId = "";
  String userName = "";
  String userEmail = "";
  String userNumber = "";
  String userToken = "";
  String refundAmount = "";
  String scheduleAmount = "";
  String _selectedDate = "";
  bool isYesNo = false;
  bool isChecked = false;
  bool isLoading = false;
  // selected city name
  String? selectedTempleId;
  String? selectedCityName;
  int? selectedPincode; // 👈 selected pincode
  String selectedMode = "online"; // default
  String selectedTempleMode = "address"; // default
  // List<Citylist> pcodeListModel = <Citylist>[];
  List<String> textValues = []; // Create a list to store the text values
  List<Temple> templeList =
      <Temple>[]; // Create a list to store the text values

  List<CityDatum> pcodeListModel = [];
  void getCityData(String city, StateSetter modalSetter) async {
    var res = await HttpService()
        .getApi("/api/v1/offlinepooja/city/details?city=$city");
    print("response api $res");
    if (res["status"]) {
      List cityList = res["city_data"];
      modalSetter(() {
        pcodeListModel = cityList.map((e) => CityDatum.fromJson(e)).toList();
        _stateController.text = res["state"]["states"]["name"];
      });
      print("✅ City List Loaded: ${pcodeListModel.length}");
    }
  }

  Future<void> fetchTempleList() async {
    String id = "${trackModelData?.order?.offlinepooja?.id}";
    final response =
        await HttpService().getApi("/api/v1/offlinepooja/temple?id=$id");
    final List data = response['temples'];
    setState(() {
      templeList = data.map((e) => Temple.fromJson(e)).toList();
    });
    print("templeList $templeList");
  }

  OflineTrackdetailModel? trackModelData;
  final razorpayService = RazorpayPaymentService();

  List<String> options = [
    "The Panditji was knowledgeable and well-versed in the rituals.",
    "He explained the significance of each step during the puja.",
    "The booking process was smooth and user-friendly.",
    "I appreciated the option to choose a Panditji based on my preferences.",
    "The experience was seamless, and I received proper post-puja guidance.",
    // ... more options
  ];

  int _selectedIndex = 0; // -1 means no option is selected

  var razorpay = Razorpay();

  void handlePaymentSuccess(
    PaymentSuccessResponse response,
  ) async {
    // charityList.isEmpty ? null : sendCharityStoreRequest();
    remainingAmount("${response.paymentId}");
  }

  void handlePaymentError(PaymentFailureResponse response) {
    Navigator.pop(context);
  }

  void handleExternalWallet(ExternalWalletResponse response) {
    // Do something when an external wallet was selected
  }

  void _handleCheckboxChange(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  String extractNames(String? jsonString) {
    // Handle null input
    if (jsonString == null || jsonString.isEmpty) {
      return ''; // Return an empty string if the input is null or empty
    }

    // Parse JSON and cast to List<String>
    try {
      List<String> names = List<String>.from(jsonDecode(jsonString));
      // Join the names into one string and return
      return names.join(', ');
    } catch (e) {
      // If JSON decoding fails, return an empty string
      print('Error decoding JSON: $e');
      return '';
    }
  }

  Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.blue;
      case 'cancel':
        return Colors.red;
      case 'rejected':
        return Colors.red;
      case 'confirmed':
        return Colors.green;
      default:
        return Colors.orange; // Default color for unknown statuses
    }
  }

  String convertDate(String? date) {
    if (date == null || date.isEmpty) {
      return "Invalid date"; // Or any default message you prefer
    }

    try {
      final dateTime = DateFormat('yyyy-MM-dd').parse(date);
      final formattedDate = DateFormat("dd-MMMM-yyyy").format(dateTime);
      return formattedDate;
    } catch (e) {
      return "Invalid format"; // Handle parsing errors
    }
  }

  String formatCreatedAt(String createdAt) {
    try {
      // Parse the ISO 8601 string to a DateTime object
      DateTime dateTime = DateTime.parse(createdAt);

      // Format the DateTime object to the desired format
      String formattedDate =
          DateFormat('dd-MMM-yyyy').format(dateTime).toLowerCase();

      return formattedDate; // Return the formatted date
    } catch (e) {
      // Handle invalid input gracefully
      return "Invalid date";
    }
  }

  /// Select Date
  Future<DateTime?> _selectDate(
      BuildContext context, StateSetter modalSetter) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
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
      modalSetter(() {
        _selectedDate = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
    return null;
  }

  //button functionality
  void submitForm(StateSetter modalSetter) {
    modalSetter(() {
      isLoading = true;
    });
    if (!isYesNo) {
      if (_selectedDate.isEmpty ||
          _cityController.text.isEmpty ||
          _landMarkController.text.isEmpty) {
        billFormKey.currentState!.validate();

// For general toast
        ToastHelper.showToast(message: "Form fields required!");
        modalSetter(() {
          isLoading = false;
        });
      } else {
        // saveTextValues();
        personDetails("${trackModelData?.order?.orderId}");
        modalSetter(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> personDetails(String orderId) async {
    final response = await http.post(
      Uri.parse(AppConstants.baseUrl + AppConstants.offlinePoojaTrackUrl),
      headers: {
        'Authorization': 'Bearer $userToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        "order_id": orderId,
        "pooja_method": selectedMode,
        "pooja_venue_type": selectedTempleMode,
        "temple_id": selectedTempleId,
        "venue_address": _venueAddressController.text,
        "state": _stateController.text,
        "city": _cityController.text,
        "pincode": _pincodeController.text,
        "latitude": "$latiTude",
        "longitude": "$longiTude",
        "booking_date": _selectedDate,
        "landmark": _landMarkController.text
      }),
    );

    print("Response Code: ${response.statusCode}");
    print("Response Body: ${response.body}");

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);

      if (data["status"]) {
        // Update UI
        setState(() {
          // couponAmount = data["data"]["coupon_amount"];
          // amtAfterDis = data["data"]["final_amount"];
          // isCouponApplyed = true;
          // walletMinusAmount = 0;
          // walletMinusAmount = max(walletPay - amtAfterDis.toInt(), 0);
          // finalAmount = (walletPay - amtAfterDis.toInt()).abs();
        });
        Fluttertoast.showToast(
            msg: "Add Successfully",
            backgroundColor: Colors.green,
            textColor: Colors.white);
        print("Response Body: ${data["status"]}");
        Navigator.of(context).pop();
      } else {}
    }
  }

  void getCancelOrder(String orderId) async {
    var res = await HttpService()
        .getApi(AppConstants.offlinePoojaCancalIdUrl + orderId);
    if (res["status"]) {
      print("api response $res");
      setState(() {
        refundAmount = res["refundPrice"].toString();
      });
      showCancelPoojaBottomSheet();
    } else {
      print("payment error");
    }
  }

  void showCancelPoojaBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Cancel Pooja Order",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 0,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        '${trackModelData?.order?.offlinepooja?.thumbnail}', // Replace with actual image URL
                        fit: BoxFit.cover,
                        height: 150,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 1,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                            "${trackModelData?.order?.offlinepooja?.name} ( ${trackModelData?.order?.offlinepooja?.hiName} ) ",
                            style: const TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 10),
                        const Text(
                          "Payment Information",
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue),
                        ),
                        const SizedBox(height: 4),
                        Text(
                            "Pooja price: ₹${trackModelData?.order?.packageMainPrice}"),
                        Text("You paid: ₹${trackModelData?.order?.payAmount}"),
                        Text(
                          "Refund amount: ₹$refundAmount",
                          style: const TextStyle(color: Colors.green),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text("Cancel Reason",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _cancelController,
                decoration: const InputDecoration(
                  hintText: "Enter your reason",
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepOrange,
                  ),
                  onPressed: () {
                    // Handle submission
                    if (_cancelController.text.isEmpty) {
                      Fluttertoast.showToast(
                          msg: "Required text field",
                          backgroundColor: Colors.red,
                          textColor: Colors.white);
                    } else {
                      cancelOrderId();
                    }
                  },
                  child: const Text("Submit",
                      style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void cancelOrderId() async {
    final url = Uri.parse(AppConstants.baseUrl +
        AppConstants.offlinePoojaCancalUrl); // Replace with your API endpoint
    final Map<String, dynamic> data = {
      "order_id": "${trackModelData?.order?.orderId}",
      "order_canceled_reason": _cancelController.text,
      "refund_amount": refundAmount
    };

    try {
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $userToken",
        },
        body: jsonEncode(data),
      );
      if (response.statusCode == 200) {
        if (_cancelController.text.isEmpty) {
          Fluttertoast.showToast(
              msg: "required text field!",
              backgroundColor: Colors.red,
              textColor: Colors.white);
        } else {
          setState(() {
            isLoading = false;
            _cancelController.clear();
          });
          Navigator.pop(context);
          Fluttertoast.showToast(
              msg: "Cancel Successful!",
              backgroundColor: Colors.green,
              textColor: Colors.white);
          getTrackData(widget.poojaId);
        }
      } else {
        // Handle error response
        Fluttertoast.showToast(
            msg: "Add Failed",
            backgroundColor: Colors.red,
            textColor: Colors.white);
      }
    } catch (error) {
      print('Error posting data: $error');
    }
  }

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

  void updateValue(String value, StateSetter modalSetter) {
    // Implement your logic here - e.g., print the value, perform validation, etc.
    print('Entered value: $value');
    getCityPick(modalSetter);
    if (_cityController.text.length > 1) {
      modalSetter(() {
        searchbox = true;
      });
    } else if (_cityController.text.isEmpty) {
      modalSetter(() {
        searchbox = false;
      });
    }
    print("serchbox $searchbox");
  }

  //Serach box
  bool searchbox = false;

  // country picker api
  void getCityPick(StateSetter modalSetter) async {
    print("object");
    cityListModel.clear();
    var response = await http.post(
      Uri.parse('https://geo.vedicrishi.in/places/'),
      body: {
        "country": _selectedCountry.name,
        "name": _cityController.text,
      },
    );
    if (response.statusCode == 200) {
      modalSetter(() {
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

  void getLocation(double lat, long) async {
    List<Placemark> placemarks = await placemarkFromCoordinates(
      lat,
      long!,
    );

    if (placemarks.isNotEmpty) {
      Placemark place = placemarks.first;
      _pincodeController.text = place.postalCode!;
      _stateController.text = place.administrativeArea!;
      // _landMarkController.text = place.street!;
      _venueAddressController.text = place.street!;
    }
  }

  void showInfoBottomSheet() {
    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (context) {
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter modalSetter) {
            return SizedBox(
              height: MediaQuery.of(context).size.height,
              child: Padding(
                padding: MediaQuery.of(context).viewInsets,
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    children: [
                      const SizedBox(
                        height: 50,
                      ),
                      AppBar(
                        backgroundColor: Colors.transparent,
                        centerTitle: true,
                        leading: IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(
                              CupertinoIcons.chevron_back,
                              color: Colors.red,
                            )),
                        title: const Text(
                          'Update Details',
                          style: TextStyle(
                              fontSize: 18.0, fontWeight: FontWeight.bold),
                        ),
                      ),
                      SingleChildScrollView(
                        child: Form(
                          key: billFormKey,
                          child: Column(
                            children: [
                              const SizedBox(height: 20),
                              Container(
                                margin: const EdgeInsets.all(8),
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  color: Colors.white,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.1),
                                      blurRadius: 8,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    /// Title
                                    Text(
                                      "Select the date on which you wish to perform the Puja",
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        fontFamily: 'Roboto',
                                        color: Colors.black87,
                                      ),
                                    ),

                                    const SizedBox(height: 12),

                                    /// Amount
                                    Text(
                                      "Booking Amount : ₹${trackModelData?.order?.packagePrice}",
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontFamily: 'Roboto',
                                        fontWeight: FontWeight.bold,
                                        color: Colors.deepOrange,
                                      ),
                                    ),

                                    Divider(
                                      color: Colors.grey.shade300,
                                    ),

                                    /// Radio Buttons (Online / Offline)
                                    Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(12),
                                        color: Colors.grey.shade50,
                                        border: Border.all(
                                            color: Colors.grey.shade300),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 8),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: Row(
                                              children: [
                                                Radio<String>(
                                                  value: "online",
                                                  groupValue: selectedMode,
                                                  activeColor:
                                                      Colors.deepOrange,
                                                  onChanged: (value) =>
                                                      modalSetter(() =>
                                                          selectedMode =
                                                              value!),
                                                ),
                                                const Text("Online"),
                                              ],
                                            ),
                                          ),
                                          Container(
                                              width: 1,
                                              height: 24,
                                              color: Colors.grey.shade400),
                                          Expanded(
                                            child: Row(
                                              children: [
                                                Radio<String>(
                                                  value: "offline",
                                                  groupValue: selectedMode,
                                                  activeColor:
                                                      Colors.deepOrange,
                                                  onChanged: (value) =>
                                                      modalSetter(() =>
                                                          selectedMode =
                                                              value!),
                                                ),
                                                const Text("Offline"),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 20),

                                    /// Date Picker
                                    _buildRowWithIcon(
                                      context,
                                      icon: Icons.calendar_today_rounded,
                                      label: "Select Date",
                                      onTap: () =>
                                          _selectDate(context, modalSetter),
                                      content: _selectedDate.isEmpty
                                          ? "Choose Date"
                                          : _selectedDate,
                                    ),

                                    const SizedBox(height: 24),

                                    Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(16),
                                        gradient: LinearGradient(
                                          colors: [
                                            Colors.deepOrange.shade400,
                                            Colors.orange.shade300
                                          ],
                                          begin: Alignment.centerLeft,
                                          end: Alignment.centerRight,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.deepOrange
                                                .withOpacity(0.25),
                                            blurRadius: 8,
                                            offset: const Offset(0, 4),
                                          ),
                                        ],
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 5, vertical: 8),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: InkWell(
                                              onTap: () => modalSetter(() =>
                                                  selectedTempleMode =
                                                      "address"),
                                              child: Row(
                                                children: [
                                                  Radio<String>(
                                                    value: "address",
                                                    groupValue:
                                                        selectedTempleMode,
                                                    activeColor: Colors.white,
                                                    fillColor:
                                                        WidgetStateProperty.all(
                                                            Colors.white),
                                                    onChanged: (value) =>
                                                        modalSetter(() =>
                                                            selectedTempleMode =
                                                                value!),
                                                  ),
                                                  Text(
                                                    "Your Address",
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontWeight:
                                                          selectedTempleMode ==
                                                                  "address"
                                                              ? FontWeight.bold
                                                              : FontWeight.w400,
                                                      fontSize: 16,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          Container(
                                              width: 1,
                                              height: 28,
                                              color: Colors.white
                                                  .withOpacity(0.6)),
                                          Expanded(
                                            child: InkWell(
                                              onTap: () => modalSetter(() =>
                                                  selectedTempleMode =
                                                      "temple"),
                                              child: Row(
                                                children: [
                                                  Radio<String>(
                                                    value: "temple",
                                                    groupValue:
                                                        selectedTempleMode,
                                                    activeColor: Colors.white,
                                                    fillColor:
                                                        WidgetStateProperty.all(
                                                            Colors.white),
                                                    onChanged: (value) =>
                                                        modalSetter(() =>
                                                            selectedTempleMode =
                                                                value!),
                                                  ),
                                                  Text(
                                                    "Preferred Temple",
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontWeight:
                                                          selectedTempleMode ==
                                                                  "temple"
                                                              ? FontWeight.bold
                                                              : FontWeight.w400,
                                                      fontSize: 16,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                    /// Address Title
                                    const SizedBox(height: 20),
                                    InkWell(
                                      onTap: () {
                                        getCityData(
                                            selectedCityName!, modalSetter);
                                      },
                                      child: Text(
                                        "Address",
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.grey.shade800,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 12),

                                    if (selectedTempleMode == "address") ...[
                                      // city pincode
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 16,
                                                      vertical: 4),
                                              decoration: BoxDecoration(
                                                color: Colors.grey.shade100,
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                                border: Border.all(
                                                    color: Colors.grey.shade400,
                                                    width: 1),
                                              ),
                                              child: DropdownButtonFormField<
                                                  String>(
                                                value: selectedCityName,
                                                decoration:
                                                    const InputDecoration(
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
                                                icon: const Icon(
                                                    Icons.keyboard_arrow_down,
                                                    color: Colors.black54),
                                                isExpanded: true,
                                                items: [
                                                  ...(trackModelData
                                                              ?.order?.cities ??
                                                          [])
                                                      .map((city) {
                                                    return DropdownMenuItem<
                                                        String>(
                                                      value: city.name,
                                                      child: Text(
                                                        "${city.name}",
                                                        style: const TextStyle(
                                                          fontSize: 16,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          color: Colors.black87,
                                                        ),
                                                      ),
                                                    );
                                                  }).toList(),

                                                  // 👇 Extra option "Other"
                                                  const DropdownMenuItem<
                                                      String>(
                                                    value: "Other",
                                                    child: Text(
                                                      "Other",
                                                      style: TextStyle(
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        color:
                                                            Colors.deepOrange,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                                onChanged: (value) {
                                                  modalSetter(() {
                                                    selectedCityName = value;
                                                  });
                                                  getCityData(selectedCityName!,
                                                      modalSetter);
                                                  if (value == "Other") {
                                                    // 👇 Show SnackBar message
                                                    ScaffoldMessenger.of(
                                                            context)
                                                        .showSnackBar(
                                                      const SnackBar(
                                                        content: Text(
                                                            "New cities will be available soon"),
                                                        duration: Duration(
                                                            seconds: 2),
                                                        backgroundColor:
                                                            Colors.deepOrange,
                                                      ),
                                                    );
                                                  } else {
                                                    print(
                                                        "Selected City: $selectedCityName");
                                                  }
                                                },
                                              ),
                                            ),
                                          ),
                                          SizedBox(
                                            width: 10,
                                          ),
                                          Expanded(
                                              child: Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 16, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: Colors.grey.shade100,
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              border: Border.all(
                                                  color: Colors.grey.shade400,
                                                  width: 1),
                                            ),
                                            child: DropdownButtonFormField<int>(
                                              value: selectedPincode,
                                              decoration: const InputDecoration(
                                                border: InputBorder.none,
                                              ),
                                              hint: const Text(
                                                "Select Pincode",
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  color: Colors.grey,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                              icon: const Icon(
                                                  Icons.keyboard_arrow_down,
                                                  color: Colors.black54),
                                              isExpanded: true,
                                              items: pcodeListModel.map((city) {
                                                return DropdownMenuItem<int>(
                                                  value: city.pincode,
                                                  child: Text(
                                                    city.pincode.toString(),
                                                    style: const TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      color: Colors.black87,
                                                    ),
                                                  ),
                                                );
                                              }).toList(),
                                              onChanged: (value) {
                                                modalSetter(() {
                                                  selectedPincode = value;
                                                  _pincodeController.text =
                                                      value.toString();

                                                  // latitude & longitude set करना
                                                  CityDatum selectedCity =
                                                      pcodeListModel.firstWhere(
                                                          (c) =>
                                                              c.pincode ==
                                                              value);
                                                  latiTude =
                                                      selectedCity.latitude;
                                                  longiTude =
                                                      selectedCity.longitude;
                                                  _cityController.text =
                                                      selectedCity.name;
                                                });

                                                print(
                                                    "✅ Selected Pincode: $selectedPincode");
                                                // print("📍 Latitude: $latiTude, Longitude: $lonGitude");
                                              },
                                            ),
                                          )),
                                        ],
                                      ),
                                      const SizedBox(height: 16),

                                      /// Venue Address
                                      TextFormField(
                                        controller: _venueAddressController,
                                        // onChanged: (value) => updateValue(value),
                                        decoration: InputDecoration(
                                          hintText: "Venue Address",
                                          prefixIcon: const Icon(
                                              Icons.location_on_outlined,
                                              color: Colors.deepOrange),
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            borderSide: const BorderSide(
                                                color: Colors.deepOrange,
                                                width: 1.5),
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            borderSide: BorderSide(
                                                color: Colors.grey.shade300),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            borderSide: const BorderSide(
                                                color: Colors.deepOrange,
                                                width: 1.5),
                                          ),
                                        ),
                                      ),

                                      /// Landmark
                                      const SizedBox(height: 16),
                                      TextFormField(
                                        controller: _landMarkController,
                                        validator: (value) => value!.isEmpty
                                            ? "Required LandMark"
                                            : null,
                                        decoration: InputDecoration(
                                          hintText: "Landmark",
                                          prefixIcon: const Icon(
                                              Icons.share_location,
                                              color: Colors.deepOrange),
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                        ),
                                      ),

                                      const SizedBox(height: 20),
                                    ],

                                    if (selectedTempleMode == "temple") ...[
                                      /// Dropdown Temple List
                                      templeList.isEmpty
                                          ? const Center(
                                              child: Text(
                                                  "No preferred temple available"),
                                            )
                                          : Container(
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                                color: Colors.grey.shade50,
                                                border: Border.all(
                                                    color:
                                                        Colors.grey.shade300),
                                              ),
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 12,
                                                      vertical: 8),
                                              child:
                                                  DropdownButtonHideUnderline(
                                                child: DropdownButton<String>(
                                                  isExpanded: true,
                                                  value: selectedTempleId,
                                                  icon: const Icon(
                                                      Icons
                                                          .keyboard_arrow_down_rounded,
                                                      color: Colors.deepOrange),
                                                  items: templeList.map((role) {
                                                    return DropdownMenuItem<
                                                        String>(
                                                      value: role.id.toString(),
                                                      child: Text(role.name,
                                                          style:
                                                              const TextStyle(
                                                                  fontSize:
                                                                      16)),
                                                    );
                                                  }).toList(),
                                                  onChanged: (newValue) {
                                                    modalSetter(() {
                                                      selectedTempleId =
                                                          newValue!;
                                                      roleIdController.text =
                                                          newValue;
                                                    });
                                                  },
                                                  hint: Row(
                                                    children: [
                                                      const Icon(
                                                          Icons.temple_buddhist,
                                                          size: 20,
                                                          color: Colors.grey),
                                                      const SizedBox(width: 10),
                                                      Text("Select Temple",
                                                          style: TextStyle(
                                                              color: Colors.grey
                                                                  .shade600)),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                    ]
                                  ],
                                ),
                              ),
                              const SizedBox(
                                height: 20,
                              ),
                              isLoading
                                  ? Container(
                                      margin: const EdgeInsets.all(10),
                                      height: 45,
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(8.0),
                                        color: Colors.orange,
                                      ),
                                      child: const Center(
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                        ),
                                      ),
                                    )
                                  : InkWell(
                                      onTap: () {
                                        submitForm(modalSetter);
                                      },
                                      child: Container(
                                        margin: const EdgeInsets.all(10),
                                        height: 45,
                                        width: double.infinity,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(8.0),
                                          color: Colors.orange,
                                        ),
                                        child: const Center(
                                          child: Text(
                                            "Submit",
                                            style: TextStyle(
                                                fontSize: 16,
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      ),
                                    ),
                              const SizedBox(
                                height: 60,
                              )
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            );
          });
        });
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
          /// Label
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 16,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 6),

          /// Input-style Container
          Container(
            height: 50,
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.white,
              border: Border.all(color: Colors.deepOrange, width: 1.4),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                )
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    content.isEmpty ? "Select $label" : content,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                      color: content.isEmpty ? Colors.grey : Colors.black87,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Icon(icon, color: Colors.deepOrange, size: 26),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void getReschedule(String orderId) async {
    var res =
        await HttpService().getApi(AppConstants.getResheduleUrl + orderId);
    if (res["status"]) {
      print("api response $res");
      setState(() {
        scheduleAmount = res["schedulePrice"].toString();
        walletMinusAmount = max(walletPay - double.parse(scheduleAmount), 0);
        finalAmount =
            (walletPay - (double.tryParse(scheduleAmount) ?? 0)).abs();
      });
      showRescheduleSheet();
    } else {
      print("payment error");
    }
  }

  void scheduleOrderId(String orderId, String wallet, String payAmount,
      StateSetter? modalSeter) async {
    final url = Uri.parse(AppConstants.baseUrl +
        AppConstants.sheduleOrderIdUrl); // Replace with your API endpoint
    final Map<String, dynamic> data = {
      "payment_amount": payAmount,
      "wallet_deduction": wallet,
      "customer_id": userId,
      "order_id": orderId,
      "pooja_method": selectedMode,
      "pooja_venue_type": selectedTempleMode,
      "temple_id": selectedTempleId,
      "venue_address": _venueAddressController.text,
      "state": _stateController.text,
      "city": _cityController.text,
      "pincode": _pincodeController.text,
      "latitude": "$latiTude",
      "longitude": "$longiTude",
      "landmark": _landMarkController.text,
      "booking_date": _selectedDate
    };
    print("response body data $data");
    try {
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $userToken",
        },
        body: jsonEncode(data),
      );
      if (response.statusCode == 200) {
        modalSeter!(() {
          print("payamount $payAmount");
          print("wallet $wallet");
          isLoading = false;
          _venueAddressController.clear();
          _stateController.clear();
          _cityController.clear();
          _pincodeController.clear();
          _landMarkController.clear();
        });
        Navigator.pop(context);
        Fluttertoast.showToast(
            msg: "Reschedule Successful!",
            backgroundColor: Colors.green,
            textColor: Colors.white);
        getTrackData(widget.poojaId);
      } else {
        // Handle error response
        print('Error: $payAmount');
        print('Error: $wallet');
        print('Error: $userId');
        print('Error: $orderId');
        print('Error: ${_venueAddressController.text}');
        print('Error: ${_stateController.text}');
        print('Error: ${_cityController.text}');
        print('Error: ${_pincodeController.text}');
        print('Error: $latiTude');
        print('Error: $longiTude');
        print('Error: ${_landMarkController.text}');
        print('Error: $_selectedDate');

        print('Error: ${response.statusCode}');
        Fluttertoast.showToast(
            msg: "Add Failed",
            backgroundColor: Colors.red,
            textColor: Colors.white);
      }
    } catch (error) {
      print('Error posting data: $error');
    }
  }

  void showRescheduleSheet() {
    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (context) {
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter modalSetter) {
            return SizedBox(
              height: MediaQuery.of(context).size.height,
              child: Padding(
                padding: MediaQuery.of(context).viewInsets,
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    children: [
                      const SizedBox(
                        height: 50,
                      ),
                      AppBar(
                        backgroundColor: Colors.transparent,
                        centerTitle: true,
                        leading: IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(
                              CupertinoIcons.chevron_back,
                              color: Colors.red,
                            )),
                        title: const Text(
                          'Reschedule',
                          style: TextStyle(
                              fontSize: 18.0, fontWeight: FontWeight.bold),
                        ),
                      ),
                      Form(
                        key: billFormKey,
                        child: Column(
                          children: [
                            // 💸 Payment Info Card
                            Container(
                              margin:
                                  const EdgeInsets.symmetric(horizontal: 10),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black12.withOpacity(0.05),
                                    blurRadius: 6,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "Payment Information",
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blueAccent,
                                    ),
                                  ),
                                  Divider(
                                    color: Colors.grey.shade300,
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text("Wallet Balance:"),
                                      Text("₹$walletPay"),
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text("Schedule Pooja Charge:"),
                                      Text("₹$scheduleAmount"),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text("Amount Paid (via Wallet):"),
                                      Text(
                                        walletMinusAmount == 0
                                            ? "- ₹$walletPay"
                                            : "- ₹$scheduleAmount",
                                        style: const TextStyle(
                                            color: Colors.redAccent),
                                      ),
                                    ],
                                  ),
                                  Divider(
                                    color: Colors.grey.shade300,
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text(
                                        "Total Amount:",
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                      Text(
                                        walletMinusAmount == 0
                                            ? "₹$finalAmount"
                                            : "₹0.0",
                                        style: const TextStyle(
                                            color: Colors.green),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 15),
                            Container(
                              margin: const EdgeInsets.all(8),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                color: Colors.white,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.1),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  /// Title
                                  Text(
                                    "Select the date on which you wish to perform the Puja",
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      fontFamily: 'Roboto',
                                      color: Colors.black87,
                                    ),
                                  ),

                                  Divider(
                                    color: Colors.grey.shade300,
                                  ),

                                  /// Radio Buttons (Online / Offline)
                                  Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      color: Colors.grey.shade50,
                                      border: Border.all(
                                          color: Colors.grey.shade300),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 8),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Row(
                                            children: [
                                              Radio<String>(
                                                value: "online",
                                                groupValue: selectedMode,
                                                activeColor: Colors.deepOrange,
                                                onChanged: (value) =>
                                                    modalSetter(() =>
                                                        selectedMode = value!),
                                              ),
                                              const Text("Online"),
                                            ],
                                          ),
                                        ),
                                        Container(
                                            width: 1,
                                            height: 24,
                                            color: Colors.grey.shade400),
                                        Expanded(
                                          child: Row(
                                            children: [
                                              Radio<String>(
                                                value: "offline",
                                                groupValue: selectedMode,
                                                activeColor: Colors.deepOrange,
                                                onChanged: (value) =>
                                                    modalSetter(() =>
                                                        selectedMode = value!),
                                              ),
                                              const Text("Offline"),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 20),

                                  /// Date Picker
                                  _buildRowWithIcon(
                                    context,
                                    icon: Icons.calendar_today_rounded,
                                    label: "Select Date",
                                    onTap: () =>
                                        _selectDate(context, modalSetter),
                                    content: _selectedDate.isEmpty
                                        ? "Choose Date"
                                        : _selectedDate,
                                  ),

                                  const SizedBox(height: 24),

                                  Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(16),
                                      gradient: LinearGradient(
                                        colors: [
                                          Colors.deepOrange.shade400,
                                          Colors.orange.shade300
                                        ],
                                        begin: Alignment.centerLeft,
                                        end: Alignment.centerRight,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.deepOrange
                                              .withOpacity(0.25),
                                          blurRadius: 8,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 5, vertical: 8),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: InkWell(
                                            onTap: () => modalSetter(() =>
                                                selectedTempleMode = "address"),
                                            child: Row(
                                              children: [
                                                Radio<String>(
                                                  value: "address",
                                                  groupValue:
                                                      selectedTempleMode,
                                                  activeColor: Colors.white,
                                                  fillColor:
                                                      WidgetStateProperty.all(
                                                          Colors.white),
                                                  onChanged: (value) =>
                                                      modalSetter(() =>
                                                          selectedTempleMode =
                                                              value!),
                                                ),
                                                Text(
                                                  "Your Address",
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontWeight:
                                                        selectedTempleMode ==
                                                                "address"
                                                            ? FontWeight.bold
                                                            : FontWeight.w400,
                                                    fontSize: 16,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        Container(
                                            width: 1,
                                            height: 28,
                                            color:
                                                Colors.white.withOpacity(0.6)),
                                        Expanded(
                                          child: InkWell(
                                            onTap: () => modalSetter(() =>
                                                selectedTempleMode = "temple"),
                                            child: Row(
                                              children: [
                                                Radio<String>(
                                                  value: "temple",
                                                  groupValue:
                                                      selectedTempleMode,
                                                  activeColor: Colors.white,
                                                  fillColor:
                                                      WidgetStateProperty.all(
                                                          Colors.white),
                                                  onChanged: (value) =>
                                                      modalSetter(() =>
                                                          selectedTempleMode =
                                                              value!),
                                                ),
                                                Text(
                                                  "Preferred Temple",
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontWeight:
                                                        selectedTempleMode ==
                                                                "temple"
                                                            ? FontWeight.bold
                                                            : FontWeight.w400,
                                                    fontSize: 16,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  /// Address Title
                                  const SizedBox(height: 20),
                                  InkWell(
                                    onTap: () {
                                      getCityData(
                                          selectedCityName!, modalSetter);
                                    },
                                    child: Text(
                                      "Address",
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.grey.shade800,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 12),

                                  if (selectedTempleMode == "address") ...[
                                    // city pincode
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 16, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: Colors.grey.shade100,
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              border: Border.all(
                                                  color: Colors.grey.shade400,
                                                  width: 1),
                                            ),
                                            child:
                                                DropdownButtonFormField<String>(
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
                                              icon: const Icon(
                                                  Icons.keyboard_arrow_down,
                                                  color: Colors.black54),
                                              isExpanded: true,
                                              items: [
                                                ...(trackModelData
                                                            ?.order?.cities ??
                                                        [])
                                                    .map((city) {
                                                  return DropdownMenuItem<
                                                      String>(
                                                    value: city.name,
                                                    child: Text(
                                                      "${city.name}",
                                                      style: const TextStyle(
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.w500,
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
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color: Colors.deepOrange,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                              onChanged: (value) {
                                                modalSetter(() {
                                                  selectedCityName = value;
                                                });
                                                getCityData(selectedCityName!,
                                                    modalSetter);
                                                if (value == "Other") {
                                                  // 👇 Show SnackBar message
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(
                                                    const SnackBar(
                                                      content: Text(
                                                          "New cities will be available soon"),
                                                      duration:
                                                          Duration(seconds: 2),
                                                      backgroundColor:
                                                          Colors.deepOrange,
                                                    ),
                                                  );
                                                } else {
                                                  print(
                                                      "Selected City: $selectedCityName");
                                                }
                                              },
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          width: 10,
                                        ),
                                        Expanded(
                                            child: Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 16, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: Colors.grey.shade100,
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            border: Border.all(
                                                color: Colors.grey.shade400,
                                                width: 1),
                                          ),
                                          child: DropdownButtonFormField<int>(
                                            value: selectedPincode,
                                            decoration: const InputDecoration(
                                              border: InputBorder.none,
                                            ),
                                            hint: const Text(
                                              "Select Pincode",
                                              style: TextStyle(
                                                fontSize: 16,
                                                color: Colors.grey,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            icon: const Icon(
                                                Icons.keyboard_arrow_down,
                                                color: Colors.black54),
                                            isExpanded: true,
                                            items: pcodeListModel.map((city) {
                                              return DropdownMenuItem<int>(
                                                value: city.pincode,
                                                child: Text(
                                                  city.pincode.toString(),
                                                  style: const TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w500,
                                                    color: Colors.black87,
                                                  ),
                                                ),
                                              );
                                            }).toList(),
                                            onChanged: (value) {
                                              modalSetter(() {
                                                selectedPincode = value;
                                                _pincodeController.text =
                                                    value.toString();

                                                // latitude & longitude set करना
                                                CityDatum selectedCity =
                                                    pcodeListModel.firstWhere(
                                                        (c) =>
                                                            c.pincode == value);
                                                latiTude =
                                                    selectedCity.latitude;
                                                longiTude =
                                                    selectedCity.longitude;
                                                _cityController.text =
                                                    selectedCity.name;
                                              });

                                              print(
                                                  "✅ Selected Pincode: $selectedPincode");
                                              // print("📍 Latitude: $latiTude, Longitude: $lonGitude");
                                            },
                                          ),
                                        )),
                                      ],
                                    ),
                                    const SizedBox(height: 16),

                                    /// Venue Address
                                    TextFormField(
                                      controller: _venueAddressController,
                                      // onChanged: (value) => updateValue(value),
                                      decoration: InputDecoration(
                                        hintText: "Venue Address",
                                        prefixIcon: const Icon(
                                            Icons.location_on_outlined,
                                            color: Colors.deepOrange),
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          borderSide: const BorderSide(
                                              color: Colors.deepOrange,
                                              width: 1.5),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          borderSide: BorderSide(
                                              color: Colors.grey.shade300),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          borderSide: const BorderSide(
                                              color: Colors.deepOrange,
                                              width: 1.5),
                                        ),
                                      ),
                                    ),

                                    /// Landmark
                                    const SizedBox(height: 16),
                                    TextFormField(
                                      controller: _landMarkController,
                                      validator: (value) => value!.isEmpty
                                          ? "Required LandMark"
                                          : null,
                                      decoration: InputDecoration(
                                        hintText: "Landmark",
                                        prefixIcon: const Icon(
                                            Icons.share_location,
                                            color: Colors.deepOrange),
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                      ),
                                    ),

                                    const SizedBox(height: 20),
                                  ],

                                  if (selectedTempleMode == "temple") ...[
                                    /// Dropdown Temple List
                                    templeList.isEmpty
                                        ? const Center(
                                            child: Text(
                                                "No preferred temple available"),
                                          )
                                        : Container(
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              color: Colors.grey.shade50,
                                              border: Border.all(
                                                  color: Colors.grey.shade300),
                                            ),
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 12, vertical: 8),
                                            child: DropdownButtonHideUnderline(
                                              child: DropdownButton<String>(
                                                isExpanded: true,
                                                value: selectedTempleId,
                                                icon: const Icon(
                                                    Icons
                                                        .keyboard_arrow_down_rounded,
                                                    color: Colors.deepOrange),
                                                items: templeList.map((role) {
                                                  return DropdownMenuItem<
                                                      String>(
                                                    value: role.id.toString(),
                                                    child: Text(role.name,
                                                        style: const TextStyle(
                                                            fontSize: 16)),
                                                  );
                                                }).toList(),
                                                onChanged: (newValue) {
                                                  modalSetter(() {
                                                    selectedTempleId =
                                                        newValue!;
                                                    roleIdController.text =
                                                        newValue;
                                                  });
                                                },
                                                hint: Row(
                                                  children: [
                                                    const Icon(
                                                        Icons.temple_buddhist,
                                                        size: 20,
                                                        color: Colors.grey),
                                                    const SizedBox(width: 10),
                                                    Text("Select Temple",
                                                        style: TextStyle(
                                                            color: Colors.grey
                                                                .shade600)),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                  ]
                                ],
                              ),
                            ),
                            const SizedBox(
                              height: 20,
                            ),

                            // 🔘 Button
                            isLoading
                                ? Container(
                                    margin: const EdgeInsets.all(10),
                                    height: 45,
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8.0),
                                      color: Colors.orange,
                                    ),
                                    child: const Center(
                                        child: CircularProgressIndicator(
                                      color: Colors.white,
                                    )))
                                : InkWell(
                                    onTap: walletMinusAmount == 0
                                        ? () {
                                            String walletAmt =
                                                walletMinusAmount == 0
                                                    ? walletPay.toString()
                                                    : scheduleAmount;
                                            String payment =
                                                walletMinusAmount == 0
                                                    ? finalAmount.toString()
                                                    : "0";
                                            print("wallet amount $walletAmt");
                                            print("pay amount $payment");
                                            if (_selectedDate.isEmpty) {
                                              billFormKey.currentState!
                                                  .validate();
                                              ToastHelper.showToast(
                                                  message:
                                                      "Form fields required!");
                                              setState(() {
                                                isLoading = false;
                                              });
                                            } else {
                                              razorpayService.openCheckout(
                                                amount: finalAmount, // ₹100
                                                razorpayKey:
                                                    AppConstants.razorpayLive,
                                                onSuccess: (response) {
                                                  String walletAmt =
                                                      walletMinusAmount == 0
                                                          ? walletPay.toString()
                                                          : scheduleAmount;
                                                  String payment =
                                                      walletMinusAmount == 0
                                                          ? finalAmount
                                                              .toString()
                                                          : "0";
                                                  print(
                                                      "wallet amount $walletAmt");
                                                  print("pay amount $payment");
                                                  scheduleOrderId(
                                                      "${trackModelData?.order?.orderId}",
                                                      walletAmt,
                                                      payment,
                                                      modalSetter);
                                                },
                                                onFailure: (response) {},
                                                onExternalWallet: (response) {
                                                  print(
                                                      "Wallet: ${response.walletName}");
                                                },
                                                description:
                                                    'Reschedule Offline Pooja',
                                              );
                                              modalSetter(() {
                                                isLoading = false;
                                              });
                                            }
                                          }
                                        : () {
                                            String walletAmt =
                                                walletMinusAmount == 0
                                                    ? walletPay.toString()
                                                    : scheduleAmount;
                                            String payment =
                                                walletMinusAmount == 0
                                                    ? finalAmount.toString()
                                                    : "0";
                                            print("wallet amount $walletAmt");
                                            print("pay amount $payment");
                                            if (_selectedDate.isEmpty) {
                                              billFormKey.currentState!
                                                  .validate();
                                              Fluttertoast.showToast(
                                                  msg: "Form fields Required!",
                                                  backgroundColor: Colors.green,
                                                  textColor: Colors.white);
                                              setState(() {
                                                isLoading = false;
                                              });
                                            } else {
                                              // saveTextValues();

                                              scheduleOrderId(
                                                  "${trackModelData?.order?.orderId}",
                                                  walletAmt,
                                                  payment,
                                                  modalSetter);
                                            }
                                          },
                                    child: Container(
                                      margin: const EdgeInsets.all(10),
                                      height: 45,
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(8.0),
                                        color: Colors.orange,
                                      ),
                                      child: const Center(
                                        child: Text(
                                          "Reschedule",
                                          style: TextStyle(
                                              fontSize: 16,
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ),
                                  ),
                            const SizedBox(
                              height: 60,
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          });
        });
  }

  void showFeedbackBottomSheet() {
    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (context) {
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter modalSetter) {
            return SizedBox(
              height: MediaQuery.of(context).size.height,
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Container(
                  color: Colors.grey.shade100,
                  child: Column(
                    children: [
                      const SizedBox(
                        height: 30,
                      ),
                      AppBar(
                        backgroundColor: Colors.transparent,
                        centerTitle: true,
                        leading: IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(
                              CupertinoIcons.chevron_back,
                              color: Colors.red,
                            )),
                        title: const Text(
                          'Please provide your feedback',
                          style: TextStyle(
                              fontSize: 18.0, fontWeight: FontWeight.bold),
                        ),
                      ),

                      const SizedBox(
                        height: 30,
                      ),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(10),
                        decoration: const BoxDecoration(color: Colors.white),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "${trackModelData?.order?.customer?.name}",
                              style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.orange),
                            ),
                            Text(
                              "${trackModelData?.order?.customer?.email}",
                              style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.blueGrey),
                            ),
                          ],
                        ),
                      ),

                      // Star Rating
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: const BoxDecoration(color: Colors.white),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "How many stars will you give us for your Puja booking on Mahakal.com",
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            Divider(
                              color: Colors.grey.shade300,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(5, (index) {
                                return IconButton(
                                  icon: Icon(
                                    index < _selectedRating
                                        ? Icons.star
                                        : Icons.star_border,
                                    color: Colors.amber,
                                    size: 40,
                                  ),
                                  onPressed: () {
                                    modalSetter(() {
                                      _selectedRating = index + 1;
                                    });
                                  },
                                );
                              }),
                            ),
                            Center(
                              child: Text(
                                _selectedRating == 1
                                    ? "Poor"
                                    : _selectedRating == 2
                                        ? "Below Average"
                                        : _selectedRating == 3
                                            ? "Average"
                                            : _selectedRating == 4
                                                ? "Good"
                                                : "Excellent",
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.amber,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Improvement Options
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: const BoxDecoration(color: Colors.white),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "What can we improve ?",
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            Column(
                              children: List.generate(options.length, (index) {
                                return CheckboxListTile(
                                  checkColor: Colors.white,
                                  activeColor: Colors.orange,
                                  title: Text(
                                    options[index],
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                  value: _selectedIndex ==
                                      index, // Key change: Compare index
                                  onChanged: (value) {
                                    if (value == true) {
                                      //Only allow selection if value is true. Prevents unchecking
                                      modalSetter(() {
                                        _handleCheckboxChange(index);
                                        _suggestionsController.text =
                                            options[index];
                                        print(
                                            "suggestion controller ${_suggestionsController.text}");
                                      });
                                    }
                                  },
                                );
                              }),
                            ),
                            // Column(
                            //   children: [
                            //     "I should get more updates about the Puja",
                            //     "My name and gotra should be taken properly",
                            //     "I should have received the puja video earlier",
                            //     "Panditji should follow the Puja rituals properly",
                            //     "Assistance should be provided to find the right Puja for me",
                            //     "Customer support should be more responsive",
                            //   ].asMap().entries.map((entry) {
                            //     return CheckboxListTile(
                            //       title: Text(entry.value,style: TextStyle(fontSize: 14),),
                            //       value: _improvementOptions[entry.key],
                            //       onChanged: (bool? value) {
                            //         modalSetter(() {
                            //           _improvementOptions[entry.key] = value ?? false;
                            //
                            //         });
                            //       },
                            //     );
                            //   }).toList(),
                            // ),
                          ],
                        ),
                      ),

                      // Suggestions
                      const SizedBox(height: 10),
                      Container(
                        // margin: EdgeInsets.symmetric(horizontal: 10),
                        padding: const EdgeInsets.all(10),
                        decoration: const BoxDecoration(color: Colors.white),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Please provide your suggestions",
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _suggestionsController,
                              maxLines: 4,
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(
                                    borderSide:
                                        BorderSide(color: Colors.orange)),
                                enabledBorder: OutlineInputBorder(
                                    borderSide:
                                        BorderSide(color: Colors.orange)),
                                hintText: "Write here...",
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],
                        ),
                      ),

                      // Submit Button
                      isLoading
                          ? Container(
                              margin: const EdgeInsets.all(10.0),
                              padding: const EdgeInsets.all(4.0),
                              height: 45,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8.0),
                                color: Colors.orange.shade400,
                              ),
                              child: const Center(
                                  child: CircularProgressIndicator(
                                color: Colors.white,
                              )))
                          : GestureDetector(
                              onTap: () {
                                modalSetter(() {
                                  isLoading = true;
                                });
                                // Submit feedback logic
                                print("Rating: $_selectedRating");
                                // print("Improvements: ${_improvementOptions.toString()}");
                                print(
                                    "Suggestions: ${_suggestionsController.text}");
                                setReviewData(modalSetter);
                              },
                              child: Container(
                                padding: const EdgeInsets.all(10),
                                margin: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8.0),
                                  color: Colors.orange,
                                ),
                                child: const Center(
                                  child: Text(
                                    "Submit",
                                    style: TextStyle(
                                        fontSize: 16, color: Colors.white),
                                  ),
                                ),
                              ),
                            )
                    ],
                  ),
                ),
              ),
            );
          });
        });
  }

  void setReviewData(StateSetter modalSetter) async {
    final url = Uri.parse(AppConstants.baseUrl +
        AppConstants.addOfflineReviewUrl); // Replace with your API endpoint
    final Map<String, dynamic> data = {
      "order_id": "${trackModelData?.order?.orderId}",
      "astro_id": "${trackModelData?.order?.pandit?.id}",
      "service_id": "${trackModelData?.order?.serviceId}",
      "comment": _suggestionsController.text,
      "service_type": "${trackModelData?.order?.type}",
      "rating": "$_selectedRating"
    };

    try {
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $userToken",
        },
        body: jsonEncode(data),
      );
      if (response.statusCode == 200) {
        print("Rating: ${trackModelData?.order?.orderId}");
        print("Rating: ${trackModelData?.order?.pandit?.id}");
        print("Rating: ${trackModelData?.order?.serviceId}");
        print("Rating: ${_suggestionsController.text}");
        print("Rating: ${trackModelData?.order?.type}");
        print("Rating: $_selectedRating");
        modalSetter(() {
          isLoading = false;
          _suggestionsController.clear();
        });
        Navigator.pop(context);
        Fluttertoast.showToast(
            msg: "Thank you for your feedback!",
            backgroundColor: Colors.green,
            textColor: Colors.white);
      } else {
        // Handle error response
        Fluttertoast.showToast(
            msg: "Add Failed",
            backgroundColor: Colors.red,
            textColor: Colors.white);
      }
    } catch (error) {
      print('Error posting data: $error');
    }
  }

  void remainingAmount(String paymentId) async {
    String wBalance = walletMinusAmount == 0
        ? walletPay.toString()
        : "${trackModelData?.order?.remainAmount}";
    String onlinePay = finalAmount == 0 ? finalAmount.toString() : "0";
    String orderId = "${trackModelData?.order?.orderId}";
    final url = Uri.parse(AppConstants.baseUrl +
        AppConstants.offlineRemainingPayUrl); // Replace with your API endpoint
    final Map<String, dynamic> data = {
      "wallet_deduction": wBalance,
      "customer_id": userId,
      "order_id": orderId,
      "payment_id": paymentId,
      "payment_amount": onlinePay
    };
    try {
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $userToken",
        },
        body: jsonEncode(data),
      );
      if (response.statusCode == 200) {
        setState(() {
          isLoading = false;
        });
        print('Error: $wBalance');
        print('Error: $onlinePay');
        print("Payment Successfully!");
        getTrackData(widget.poojaId);
        Fluttertoast.showToast(
            msg: "Payment Successfully!",
            backgroundColor: Colors.green,
            textColor: Colors.white);
        Navigator.pop(context);
      } else {
        // Handle error response
        Fluttertoast.showToast(
            msg: "Payment Failed",
            backgroundColor: Colors.red,
            textColor: Colors.white);
      }
    } catch (error) {
      print('Error posting data: $error');
    }
  }

  void walletAmount() async {
    var res =
        await HttpService().getApi(AppConstants.fetchWalletAmount + userId);
    print(res);
    if (res["success"]) {
      setState(() {
        walletPay = double.parse(res["wallet_balance"].toString());
        // walletMinusAmount = max(walletPay - (trackModelData?.order?.remainAmount ?? 0), 0);
        // finalAmount = (walletPay - (trackModelData?.order?.remainAmount ?? 0)).abs();
      });
      print("wallte amount $walletPay - amount $walletMinusAmount");
    }
  }

  static String? bookpanditnvoicePath;
  static String? invoicePdfUrl;

  /// **Fetch  Invoice**
  Future<void> fetchInvoice(
      BuildContext context, String invoiceId, String userToken) async {
    String apiUrl =
        AppConstants.baseUrl + AppConstants.fetchOfflineInvoiceUrl + invoiceId;
    try {
      Response response = await Dio().get(
        apiUrl,
        options: Options(
          responseType: ResponseType.bytes,
          headers: {
            "Authorization": "Bearer $userToken",
          },
        ),
      );
      if (response.statusCode == 200) {
        Directory tempDir = await getTemporaryDirectory();
        String filePath = '${tempDir.path}/invoice_$invoiceId.pdf';
        invoicePdfUrl = apiUrl;
        if (bookpanditnvoicePath != null &&
            File(bookpanditnvoicePath!).existsSync()) {
          await File(bookpanditnvoicePath!).delete();
        }

        File file = File(filePath);
        await file.writeAsBytes(response.data);
        bookpanditnvoicePath = filePath; //  Save for open/share
      } else {}
    } catch (e) {
      print("Error: $e");
    }
  }

  /// **Open  Invoice**
  static Future<void> openInvoice(BuildContext context, String url) async {
    if (bookpanditnvoicePath == null ||
        !File(bookpanditnvoicePath!).existsSync()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("⚠ Invoice not found!")),
      );
      return;
    }

    Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (context) => InvoiceViewer(
          pdfPath: bookpanditnvoicePath!,
          invoiceUrl: url,
        ),
      ),
    );
  }

  /// **Share  Invoice**
  static Future<void> shareInvoice(BuildContext context) async {
    if (bookpanditnvoicePath != null &&
        File(bookpanditnvoicePath!).existsSync()) {
      String shareUrl = '';
      shareUrl = "${AppConstants.baseUrl}/download";

      String shareText = "📿 **पंडित बुकिंग कन्फर्म** 🎉\n\n"
          "अब करें अपनी पूजा की बुकिंग Mahakal.com ऐप पर 🙏\n\n"
          "🔹Download App Now: $shareUrl";

      await Share.shareXFiles([XFile(bookpanditnvoicePath!)], text: shareText);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("⚠ Please download the invoice first!")),
      );
    }
  }

  void showPoojaThankYouDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          backgroundColor: Colors.white,
          child: const Padding(
            padding: EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.auto_awesome_rounded,
                    color: Colors.deepPurple, size: 60),
                SizedBox(height: 16),
                Text(
                  "🙏 Thank You for Booking the Pooja!",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 12),
                Text(
                  "Your pooja has been booked successfully.\nOur team will reach out shortly with the details.\nMay divine blessings be with you always. 🌸",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black54,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void showReviewSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          backgroundColor: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.reviews, color: Colors.orange, size: 60),
                const SizedBox(height: 16),
                const Text(
                  "Review Submitted Successfully! ⭐",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                const Text(
                  "Thank you for your valuable feedback!\nYour review helps others and supports us.",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black54,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    "OK",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getTrackData(widget.poojaId);
    setState(() {
      _suggestionsController.text = options[0];
    });
    userId = Provider.of<ProfileController>(Get.context!, listen: false).userID;
    userName =
        Provider.of<ProfileController>(Get.context!, listen: false).userNAME;
    userEmail =
        Provider.of<ProfileController>(Get.context!, listen: false).userEMAIL;
    userNumber =
        Provider.of<ProfileController>(Get.context!, listen: false).userPHONE;
    userToken =
        Provider.of<AuthController>(Get.context!, listen: false).getUserToken();
    walletAmount();
    // addMemberList();
    razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, handlePaymentSuccess);
    razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, handlePaymentError);
    razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, handleExternalWallet);
  }

  String maskPhoneNumber(String phone) {
    if (phone.length < 4) return phone;
    return phone.replaceRange(2, phone.length - 2, '*' * (phone.length - 4));
  }

  String formatTime(String? timeString) {
    if (timeString == null || timeString.isEmpty) return 'N/A';
    try {
      final parsedTime = DateFormat("HH:mm:ss").parse(timeString);
      return DateFormat("hh:mm a").format(parsedTime); // 04:00 AM format
    } catch (e) {
      return 'Invalid time';
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  void getTrackData(String id) async {
    var res = await HttpService().getApi(AppConstants.getOfflineDataUrl + id);
    print("api response $res");
    setState(() {
      trackModelData = oflineTrackdetailModelFromJson(jsonEncode(res));
      noPerson = int.parse("${trackModelData?.order?.leads?.noperson}");
      print(noPerson);
      selectedCityName = trackModelData?.order?.city;
    });
    fetchInvoice(context, "${trackModelData!.order!.id}", userToken);
    fetchTempleList();
  }

  @override
  Widget build(BuildContext context) {
    return trackModelData?.order?.orderId == null
        ? MahakalLoadingData(onReload: () {})
        : Scaffold(
            floatingActionButtonLocation:
                FloatingActionButtonLocation.centerDocked,
            floatingActionButton: trackModelData?.order?.status == "Complete"
                ? Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () {
                            showPoojaThankYouDialog(context);
                          },
                          child: Container(
                            margin: const EdgeInsets.only(
                                left: 10, right: 5, bottom: 10),
                            height: 45,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8.0),
                              color: Colors.deepOrange,
                            ),
                            child: const Center(
                              child: Text(
                                "Order Completed",
                                style: TextStyle(
                                    fontSize: 18, color: Colors.white),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: InkWell(
                          onTap: () {
                            if (trackModelData?.isReview == 1) {
                              showReviewSuccessDialog(context);
                            } else {
                              showFeedbackBottomSheet();
                            }
                          },
                          child: Container(
                            margin: const EdgeInsets.only(
                                left: 5, right: 10, bottom: 10),
                            height: 45,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8.0),
                              color: Colors.blue,
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.star,
                                  color: Colors.white,
                                  size: 18,
                                ),
                                SizedBox(
                                  width: 4,
                                ),
                                Text(
                                  "Rate Us",
                                  style: TextStyle(
                                      fontSize: 18, color: Colors.white),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                : Row(
                    children: [
                      trackModelData?.order?.remainAmount == 0
                          ? const SizedBox.shrink()
                          : (trackModelData?.order?.status == "Cancel") ^
                                  (trackModelData?.order?.status == "Complete")
                              ? const SizedBox.shrink()
                              : Expanded(
                                  child: InkWell(
                                    onTap: () {
                                      walletMinusAmount = max(
                                          walletPay -
                                              (trackModelData
                                                      ?.order?.remainAmount ??
                                                  0),
                                          0);
                                      finalAmount = (walletPay -
                                              (trackModelData
                                                      ?.order?.remainAmount ??
                                                  0))
                                          .abs();
                                      print(
                                          "wallet amount $walletPay - wallet minus $walletMinusAmount final amount $finalAmount");
                                      showModalBottomSheet(
                                          context: context,
                                          isScrollControlled: true,
                                          builder: (context) {
                                            return StatefulBuilder(builder:
                                                (BuildContext context,
                                                    StateSetter modalSetter) {
                                              return Container(
                                                padding:
                                                    const EdgeInsets.all(10),
                                                margin:
                                                    const EdgeInsets.all(10),
                                                child: SingleChildScrollView(
                                                  child: Padding(
                                                    padding: EdgeInsets.only(
                                                        bottom: MediaQuery.of(
                                                                context)
                                                            .viewInsets
                                                            .bottom),
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      children: [
                                                        const SizedBox(
                                                          height: 10,
                                                        ),
                                                        Container(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(10),
                                                          decoration: BoxDecoration(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          8),
                                                              border: Border.all(
                                                                  color: Colors
                                                                      .grey)),
                                                          child: Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              const Text(
                                                                "Bill details",
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        18,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    fontFamily:
                                                                        'Roboto',
                                                                    color: Colors
                                                                        .orange),
                                                              ),
                                                              const SizedBox(
                                                                height: 10,
                                                              ),
                                                              Row(
                                                                children: [
                                                                  const Text(
                                                                    "Pooja Total",
                                                                    style: TextStyle(
                                                                        fontSize:
                                                                            18,
                                                                        fontWeight:
                                                                            FontWeight
                                                                                .w400,
                                                                        fontFamily:
                                                                            'Roboto',
                                                                        color: Colors
                                                                            .black),
                                                                  ),
                                                                  const Spacer(),
                                                                  Text(
                                                                    "₹${trackModelData?.order?.packageMainPrice}.0",
                                                                    style: const TextStyle(
                                                                        fontSize:
                                                                            18,
                                                                        fontFamily:
                                                                            'Roboto',
                                                                        color: Colors
                                                                            .green),
                                                                  )
                                                                ],
                                                              ),
                                                              Row(
                                                                children: [
                                                                  const Text(
                                                                    "Paid Amount",
                                                                    style: TextStyle(
                                                                        fontSize:
                                                                            18,
                                                                        fontWeight:
                                                                            FontWeight
                                                                                .w400,
                                                                        fontFamily:
                                                                            'Roboto',
                                                                        color: Colors
                                                                            .black),
                                                                  ),
                                                                  const Spacer(),
                                                                  Text(
                                                                    "₹${trackModelData?.order?.packagePrice}.0",
                                                                    style: const TextStyle(
                                                                        fontSize:
                                                                            18,
                                                                        fontFamily:
                                                                            'Roboto',
                                                                        color: Colors
                                                                            .green),
                                                                  )
                                                                ],
                                                              ),
                                                              const Divider(),
                                                              Row(
                                                                children: [
                                                                  const Text(
                                                                    "Wallet Balance : ",
                                                                    style: TextStyle(
                                                                        fontSize:
                                                                            18,
                                                                        color: Colors
                                                                            .black,
                                                                        fontWeight:
                                                                            FontWeight.bold),
                                                                  ),
                                                                  const Spacer(),
                                                                  Text(
                                                                    "₹$walletPay.0",
                                                                    style:
                                                                        const TextStyle(
                                                                      fontSize:
                                                                          18,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w400,
                                                                      fontFamily:
                                                                          'Roboto',
                                                                      color: Colors
                                                                          .blue, // Default color for all text
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                              Row(
                                                                children: [
                                                                  RichText(
                                                                    text:
                                                                        TextSpan(
                                                                      style:
                                                                          const TextStyle(
                                                                        fontSize:
                                                                            18,
                                                                        fontWeight:
                                                                            FontWeight.w400,
                                                                        fontFamily:
                                                                            'Roboto',
                                                                        color: Colors
                                                                            .black, // Default color for all text
                                                                      ),
                                                                      children: [
                                                                        const TextSpan(
                                                                            text:
                                                                                "Wallet remaining ("),
                                                                        TextSpan(
                                                                          text:
                                                                              "₹$walletMinusAmount",
                                                                          style:
                                                                              const TextStyle(
                                                                            color:
                                                                                Colors.green, // Custom color for walletPay
                                                                            fontWeight:
                                                                                FontWeight.bold, // Optional, for emphasis
                                                                          ),
                                                                        ),
                                                                        const TextSpan(
                                                                            text:
                                                                                ")"),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                  // Spacer(),
                                                                  // Text("W/B ₹$walletPay.0",
                                                                  //   style: TextStyle(
                                                                  //       fontSize: 18,
                                                                  //       fontFamily: 'Roboto',
                                                                  //       color: Colors.blue),
                                                                  // )
                                                                ],
                                                              ),
                                                              Row(
                                                                children: [
                                                                  const Text(
                                                                    "Amount Paid (via Wallet)",
                                                                    style: TextStyle(
                                                                        fontSize:
                                                                            18,
                                                                        fontWeight:
                                                                            FontWeight
                                                                                .w400,
                                                                        fontFamily:
                                                                            'Roboto',
                                                                        color: Colors
                                                                            .black),
                                                                  ),
                                                                  const Spacer(),
                                                                  Text(
                                                                    walletMinusAmount ==
                                                                            0
                                                                        ? "- ₹$walletPay"
                                                                        : "- ₹${trackModelData?.order?.remainAmount}.0",
                                                                    style: const TextStyle(
                                                                        fontSize:
                                                                            18,
                                                                        fontFamily:
                                                                            'Roboto',
                                                                        color: Colors
                                                                            .red),
                                                                  )
                                                                ],
                                                              ),
                                                              const Divider(),
                                                              const Row(
                                                                children: [
                                                                  Text(
                                                                    "Special Discount",
                                                                    style: TextStyle(
                                                                        fontSize:
                                                                            18,
                                                                        fontWeight:
                                                                            FontWeight
                                                                                .w400,
                                                                        fontFamily:
                                                                            'Roboto',
                                                                        color: Colors
                                                                            .black),
                                                                  ),
                                                                  Spacer(),
                                                                  Text(
                                                                    "- ₹0.0",
                                                                    style: TextStyle(
                                                                        fontSize:
                                                                            18,
                                                                        fontFamily:
                                                                            'Roboto',
                                                                        color: Colors
                                                                            .grey),
                                                                  )
                                                                ],
                                                              ),
                                                              const Divider(),
                                                              Row(
                                                                children: [
                                                                  const Text(
                                                                    "Total Amount",
                                                                    style: TextStyle(
                                                                        fontSize:
                                                                            22,
                                                                        fontWeight:
                                                                            FontWeight
                                                                                .w500,
                                                                        fontFamily:
                                                                            'Roboto',
                                                                        color: Colors
                                                                            .black),
                                                                  ),
                                                                  const Spacer(),
                                                                  Text(
                                                                    walletMinusAmount ==
                                                                            0
                                                                        ? "₹$finalAmount.0"
                                                                        : "₹0.0",
                                                                    style: const TextStyle(
                                                                        fontSize:
                                                                            22,
                                                                        fontWeight:
                                                                            FontWeight
                                                                                .w500,
                                                                        fontFamily:
                                                                            'Roboto',
                                                                        color: Colors
                                                                            .orange),
                                                                  )
                                                                ],
                                                              ),
                                                              const SizedBox(
                                                                height: 10,
                                                              ),
                                                              Container(
                                                                width: double
                                                                    .infinity,
                                                                padding:
                                                                    const EdgeInsets
                                                                        .all(
                                                                        10),
                                                                decoration:
                                                                    BoxDecoration(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              5),
                                                                  color: const Color
                                                                      .fromRGBO(
                                                                      255,
                                                                      245,
                                                                      236,
                                                                      1),
                                                                ),
                                                                child:
                                                                    const Center(
                                                                  child: Text(
                                                                    "Continue Now & Pay the Due Amount",
                                                                    style: TextStyle(
                                                                        fontSize:
                                                                            14,
                                                                        letterSpacing:
                                                                            0.5,
                                                                        fontWeight:
                                                                            FontWeight
                                                                                .w500,
                                                                        fontFamily:
                                                                            'Roboto',
                                                                        color: Colors
                                                                            .orange),
                                                                  ),
                                                                ),
                                                              ),
                                                              const SizedBox(
                                                                height: 10,
                                                              ),
                                                            ],
                                                          ),
                                                        ),

                                                        const SizedBox(
                                                          height: 20,
                                                        ),
                                                        // button
                                                        walletMinusAmount == 0
                                                            ? ElevatedButton(
                                                                onPressed: () {
                                                                  var options =
                                                                      {
                                                                    'key': AppConstants
                                                                        .razorpayLive,
                                                                    'amount':
                                                                        finalAmount *
                                                                            100, // 50 rupees in paise
                                                                    'name':
                                                                        userName,
                                                                    // 'order_id': 'order_EMBFqjDHEEn80l',
                                                                    'description':
                                                                        "payment",
                                                                    'timeout':
                                                                        300, // in seconds
                                                                    'prefill': {
                                                                      'contact':
                                                                          userNumber, // hardcoded contact number
                                                                      'email':
                                                                          userEmail // hardcoded email
                                                                    },
                                                                    'theme': {
                                                                      'color':
                                                                          '#FFA500', // Orange color in HEX
                                                                      'textColor':
                                                                          '#FFFFFF'
                                                                    }
                                                                  };
                                                                  razorpay.open(
                                                                      options);
                                                                  modalSetter(
                                                                      () {
                                                                    isLoading =
                                                                        false;
                                                                  });
                                                                },
                                                                style: ElevatedButton
                                                                    .styleFrom(
                                                                  foregroundColor:
                                                                      Colors
                                                                          .white,
                                                                  backgroundColor:
                                                                      Colors
                                                                          .black,
                                                                  minimumSize:
                                                                      const Size(
                                                                          double
                                                                              .infinity,
                                                                          50),
                                                                  shape:
                                                                      RoundedRectangleBorder(
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            10),
                                                                  ),
                                                                ),
                                                                child: isLoading
                                                                    ? const CircularProgressIndicator(
                                                                        color: Colors
                                                                            .white,
                                                                      )
                                                                    : const Text(
                                                                        'Continue',
                                                                        style: TextStyle(
                                                                            fontSize:
                                                                                18,
                                                                            fontWeight:
                                                                                FontWeight.bold,
                                                                            letterSpacing: 0.28),
                                                                      ),
                                                              )
                                                            : ElevatedButton(
                                                                onPressed: () {
                                                                  modalSetter(
                                                                      () {
                                                                    isLoading =
                                                                        true;
                                                                  });
                                                                  isLoading
                                                                      ? remainingAmount(
                                                                          "Wallet_pay")
                                                                      : null;
                                                                },
                                                                style: ElevatedButton
                                                                    .styleFrom(
                                                                  foregroundColor:
                                                                      Colors
                                                                          .white,
                                                                  backgroundColor:
                                                                      Colors
                                                                          .black,
                                                                  minimumSize:
                                                                      const Size(
                                                                          double
                                                                              .infinity,
                                                                          50),
                                                                  shape:
                                                                      RoundedRectangleBorder(
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            10),
                                                                  ),
                                                                ),
                                                                child: isLoading
                                                                    ? const CircularProgressIndicator(
                                                                        color: Colors
                                                                            .white,
                                                                      )
                                                                    : const Text(
                                                                        'Continue',
                                                                        style: TextStyle(
                                                                            fontSize:
                                                                                18,
                                                                            fontWeight:
                                                                                FontWeight.bold,
                                                                            letterSpacing: 0.28),
                                                                      ),
                                                              ),
                                                        const SizedBox(
                                                          height: 20.0,
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              );
                                            });
                                          });
                                    },
                                    child: Container(
                                      margin: const EdgeInsets.all(10),
                                      height: 45,
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(8.0),
                                        color: Colors.orange,
                                      ),
                                      child: const Center(
                                        child: Text(
                                          "Pay Now",
                                          style: TextStyle(
                                              fontSize: 18,
                                              color: Colors.white),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                      Expanded(
                        child: InkWell(
                          onTap: () {
                            trackModelData?.order?.status == "Cancel"
                                ? null
                                : getCancelOrder(
                                    "${trackModelData?.order?.orderId}");
                          },
                          child: Container(
                            margin: const EdgeInsets.all(10),
                            height: 45,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8.0),
                              color: trackModelData?.order?.status == "Cancel"
                                  ? Colors.grey
                                  : Colors.red,
                            ),
                            child: Center(
                              child: Text(
                                trackModelData?.order?.status == "Cancel"
                                    ? "Cancelled"
                                    : "Cancel Order",
                                style: const TextStyle(
                                    fontSize: 18, color: Colors.white),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
            appBar: AppBar(
              backgroundColor: Colors.grey.shade50,
              title: Column(
                children: [
                  Text.rich(TextSpan(children: [
                    const TextSpan(
                        text: "Order -",
                        style: TextStyle(color: Colors.black, fontSize: 18)),
                    TextSpan(
                        text: " #${trackModelData?.order?.orderId}",
                        style: const TextStyle(
                            color: Colors.black,
                            fontSize: 20,
                            fontWeight: FontWeight.bold)),
                  ])),
                  const SizedBox(
                    height: 5,
                  ),
                  Text.rich(TextSpan(children: [
                    const TextSpan(
                        text: " Your Order is - ",
                        style: TextStyle(color: Colors.black, fontSize: 18)),
                    TextSpan(
                        text: "${trackModelData?.order?.status}",
                        style: TextStyle(
                            color: getStatusColor(
                                "${trackModelData?.order?.status}"),
                            fontSize: 20,
                            fontWeight: FontWeight.bold)),
                  ])),
                  const SizedBox(
                    height: 5,
                  ),
                  Text(convertDate("${trackModelData?.order?.bookingDate}"),
                      style: const TextStyle(
                          fontSize: 18,
                          overflow: TextOverflow.ellipsis,
                          color: Colors.black)),
                ],
              ),
              centerTitle: true,
              toolbarHeight: 100,
            ),
            body: RefreshIndicator(
              onRefresh: () async {
                getTrackData(widget.poojaId);
              },
              color: Colors.white, // Progress indicator color
              backgroundColor: Colors
                  .deepOrange, // Background color of the refresh indicator
              displacement: 40.0,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 20, horizontal: 10),
                      width: double.infinity,
                      decoration: const BoxDecoration(
                          image: DecorationImage(
                              image: AssetImage("assets/images/map_bg.png"),
                              fit: BoxFit.fill)),
                      child: Column(
                        children: [
                          // Container(
                          //   // padding: EdgeInsets.all(10),
                          //   decoration: BoxDecoration(
                          //     borderRadius: BorderRadius.circular(10),
                          //     color: Colors.white,
                          //   ),
                          //   child: Padding(
                          //     padding: const EdgeInsets.all(15),
                          //     child: Column(
                          //       crossAxisAlignment: CrossAxisAlignment.start,
                          //       mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          //       children: [
                          //
                          //         const Row(children: [
                          //
                          //           Icon(Icons.article,color: Colors.deepOrange,),
                          //           SizedBox(width: 10,),
                          //           Text("User Info",style: TextStyle(fontSize: 20,overflow: TextOverflow.ellipsis,fontWeight: FontWeight.bold,color: Colors.deepOrange))
                          //
                          //         ],),
                          //         const Divider(color: Colors.grey,),
                          //         const SizedBox(height: 10,),
                          //         Row(children: [
                          //           Icon(Icons.person,color: Colors.deepOrange.shade200,),
                          //           const SizedBox(width: 10,),
                          //           Text(trackModelData?.order?.customer?.name == null ? "Not-Available" :"${trackModelData?.order?.customer?.name}",style: const TextStyle(fontSize: 16,overflow: TextOverflow.ellipsis))
                          //
                          //         ],),
                          //
                          //         const SizedBox(height: 10,),
                          //         Row(children: [
                          //           Icon(Icons.email_outlined,color: Colors.deepOrange.shade200,),                              const SizedBox(width: 10,),
                          //           Text("${trackModelData?.order?.customer?.email}",style: const TextStyle(fontSize: 16,overflow: TextOverflow.ellipsis))
                          //         ],),
                          //
                          //         const SizedBox(height: 10,),
                          //         Row(children: [
                          //           Icon(Icons.phone,color: Colors.deepOrange.shade200,),
                          //           const SizedBox(width: 10,),
                          //           Text("${trackModelData?.order?.customer?.phone}",style: const TextStyle(fontSize: 16,overflow: TextOverflow.ellipsis))
                          //         ],),
                          //
                          //       ],
                          //     ),
                          //   ),
                          // ),

                          Container(
                            height: 180,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: Colors.white,
                              boxShadow: const [
                                BoxShadow(
                                    color: Colors.black12,
                                    blurRadius: 8,
                                    offset: Offset(0, 5)),
                              ],
                            ),
                            child: Row(
                              children: [
                                // Left Gradient with Profile Image
                                ClipPath(
                                  // clipper: AsyncSnapshot.waiting(),
                                  child: Container(
                                    padding: const EdgeInsets.all(2),
                                    width: 140,
                                    decoration: const BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          Color(0xFFEF476F),
                                          Color(0xFFF78C6B)
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                    ),
                                    child: Center(
                                      child: CircleAvatar(
                                        radius: 50,
                                        backgroundImage: NetworkImage(trackModelData
                                                    ?.order?.pandit ==
                                                null
                                            ? "https://i.pinimg.com/736x/c0/74/9b/c0749b7cc401421662ae901ec8f9f660.jpg"
                                            : "${trackModelData?.order?.pandit!.image}"),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 20),
                                // Right Text and Icons
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 15.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          "Pandit details",
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 18,
                                              color: Colors.blueGrey),
                                        ),
                                        Divider(
                                          color: Colors.grey.shade300,
                                        ),
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.person,
                                              color: Colors.deepOrange.shade200,
                                            ),
                                            const SizedBox(
                                              width: 5,
                                            ),
                                            Expanded(
                                              child: Text(
                                                trackModelData?.order?.pandit ==
                                                        null
                                                    ? "| *******"
                                                    : "| ${trackModelData?.order?.pandit?.name}",
                                                style: const TextStyle(
                                                    color: Colors.black,
                                                    fontSize: 14,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.phone,
                                              color: Colors.deepOrange.shade200,
                                            ),
                                            const SizedBox(
                                              width: 5,
                                            ),
                                            Text(
                                              trackModelData?.order?.pandit ==
                                                      null
                                                  ? "| *******"
                                                  : "| +91 ${maskPhoneNumber("${trackModelData?.order?.pandit?.mobileNo}")}",
                                              style: const TextStyle(
                                                  fontSize: 15,
                                                  color: Colors.black87),
                                              maxLines: 3,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                        ),
                                        const Spacer(),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            trackModelData?.order?.pandit ==
                                                    null
                                                ? InkWell(
                                                    onTap: () {
                                                      showDialog(
                                                        context: context,
                                                        builder: (BuildContext
                                                            context) {
                                                          return Dialog(
                                                            shape:
                                                                RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          20),
                                                            ),
                                                            backgroundColor:
                                                                Colors.white,
                                                            child: Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .all(
                                                                      24.0),
                                                              child: Column(
                                                                mainAxisSize:
                                                                    MainAxisSize
                                                                        .min,
                                                                children: [
                                                                  const Icon(
                                                                      Icons
                                                                          .info_outline,
                                                                      color: Colors
                                                                          .orange,
                                                                      size: 60),
                                                                  const SizedBox(
                                                                      height:
                                                                          16),
                                                                  const Text(
                                                                    "Pandit Not Yet Assigned 🔔",
                                                                    style:
                                                                        TextStyle(
                                                                      fontSize:
                                                                          20,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                      color: Colors
                                                                          .black87,
                                                                    ),
                                                                    textAlign:
                                                                        TextAlign
                                                                            .center,
                                                                  ),
                                                                  const SizedBox(
                                                                      height:
                                                                          12),
                                                                  const Text(
                                                                    "The call log will be activated once a Pandit is assigned.\nPlease wait for further updates.",
                                                                    style:
                                                                        TextStyle(
                                                                      fontSize:
                                                                          16,
                                                                      color: Colors
                                                                          .black54,
                                                                    ),
                                                                    textAlign:
                                                                        TextAlign
                                                                            .center,
                                                                  ),
                                                                  const SizedBox(
                                                                      height:
                                                                          24),
                                                                  ElevatedButton(
                                                                    onPressed:
                                                                        () {
                                                                      Navigator.pop(
                                                                          context);
                                                                    },
                                                                    style: ElevatedButton
                                                                        .styleFrom(
                                                                      backgroundColor:
                                                                          Colors
                                                                              .orange,
                                                                      shape:
                                                                          RoundedRectangleBorder(
                                                                        borderRadius:
                                                                            BorderRadius.circular(12),
                                                                      ),
                                                                    ),
                                                                    child:
                                                                        const Text(
                                                                      "OK",
                                                                      style: TextStyle(
                                                                          color:
                                                                              Colors.white),
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          );
                                                        },
                                                      );
                                                    },
                                                    child: Container(
                                                      height: 40,
                                                      width: 160,
                                                      decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8.0),
                                                        border: Border.all(
                                                            color:
                                                                Colors.amber),
                                                        gradient:
                                                            LinearGradient(
                                                          colors: [
                                                            Colors.grey,
                                                            Colors.grey.shade300
                                                          ],
                                                          begin:
                                                              Alignment.topLeft,
                                                          end: Alignment
                                                              .bottomRight,
                                                        ),
                                                      ),
                                                      child: const Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: [
                                                          Icon(
                                                            Icons.phone,
                                                            color: Colors.white,
                                                            size: 18,
                                                          ),
                                                          SizedBox(
                                                            width: 8,
                                                          ),
                                                          Text(
                                                            "Call Pandit",
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .white,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold),
                                                          )
                                                        ],
                                                      ),
                                                    ),
                                                  )
                                                : InkWell(
                                                    onTap: () async {
                                                      final Uri launchUri = Uri(
                                                          scheme: 'tel',
                                                          path:
                                                              '${trackModelData?.order?.pandit?.mobileNo}');
                                                      await launchUrl(
                                                          launchUri);
                                                    },
                                                    child: Container(
                                                      height: 40,
                                                      width: 160,
                                                      decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8.0),
                                                        border: Border.all(
                                                            color:
                                                                Colors.amber),
                                                        gradient:
                                                            const LinearGradient(
                                                          colors: [
                                                            Color(0xFFEF476F),
                                                            Color(0xFFF78C6B)
                                                          ],
                                                          begin:
                                                              Alignment.topLeft,
                                                          end: Alignment
                                                              .bottomRight,
                                                        ),
                                                      ),
                                                      child: const Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: [
                                                          Icon(
                                                            Icons.phone,
                                                            color: Colors.white,
                                                            size: 18,
                                                          ),
                                                          SizedBox(
                                                            width: 8,
                                                          ),
                                                          Text(
                                                            "Call Pandit",
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .white,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold),
                                                          )
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                          ],
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(
                            height: 15,
                          ),
                          trackModelData?.order?.templeDetails == null
                              ? trackModelData?.order?.venueAddress == null
                                  ? Container(
                                      // padding: EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        color: Colors.white,
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(15),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          children: [
                                            const Row(
                                              children: [
                                                Icon(
                                                  Icons.article,
                                                  color: Colors.deepOrange,
                                                ),
                                                SizedBox(
                                                  width: 10,
                                                ),
                                                Text("Venue Details",
                                                    style: TextStyle(
                                                        fontSize: 20,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color:
                                                            Colors.deepOrange)),
                                              ],
                                            ),
                                            const Divider(
                                              color: Colors.grey,
                                            ),
                                            const SizedBox(
                                              height: 10,
                                            ),
                                            const Center(
                                                child: Text(
                                              "Please Fill Details For Your Puja",
                                              style: TextStyle(
                                                  fontSize: 20,
                                                  color: Colors.blueGrey),
                                            )),
                                            const SizedBox(
                                              height: 15,
                                            ),
                                            (trackModelData?.order?.status ==
                                                        "Cancel") ^
                                                    (trackModelData
                                                            ?.order?.status ==
                                                        "Complete")
                                                ? Container(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 10,
                                                        vertical: 5),
                                                    decoration: BoxDecoration(
                                                        color: Colors
                                                            .grey.shade300,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8.0)),
                                                    child: const Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        Icon(
                                                          Icons.add,
                                                          color: Colors.white,
                                                        ),
                                                        SizedBox(
                                                          width: 5,
                                                        ),
                                                        Text("Add",
                                                            style: TextStyle(
                                                                fontSize: 18,
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis,
                                                                color: Colors
                                                                    .white,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold)),
                                                      ],
                                                    ))
                                                : InkWell(
                                                    onTap: () {
                                                      // addMemberList();
                                                      showInfoBottomSheet();
                                                    },
                                                    child: Container(
                                                        padding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                                horizontal: 10,
                                                                vertical: 5),
                                                        decoration: BoxDecoration(
                                                            color: Colors
                                                                .deepOrange,
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        8.0)),
                                                        child: const Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .center,
                                                          children: [
                                                            Icon(
                                                              Icons.add,
                                                              color:
                                                                  Colors.white,
                                                            ),
                                                            SizedBox(
                                                              width: 5,
                                                            ),
                                                            Text("Add",
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        18,
                                                                    overflow:
                                                                        TextOverflow
                                                                            .ellipsis,
                                                                    color: Colors
                                                                        .white,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold)),
                                                          ],
                                                        )),
                                                  ),
                                          ],
                                        ),
                                      ),
                                    ) // add button
                                  : Container(
                                      // padding: EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        color: Colors.white,
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(15),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          children: [
                                            const Row(
                                              children: [
                                                Icon(
                                                  Icons.article,
                                                  color: Colors.deepOrange,
                                                ),
                                                SizedBox(
                                                  width: 10,
                                                ),
                                                Text("Venue Details",
                                                    style: TextStyle(
                                                        fontSize: 20,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color:
                                                            Colors.deepOrange))
                                              ],
                                            ),

                                            const Divider(
                                              color: Colors.grey,
                                            ),
                                            // SizedBox(height: 10,),
                                            // Row(children: [
                                            //   Expanded(
                                            //       flex:0,
                                            //       child: Icon(Icons.groups,color: Colors.deepOrange.shade100,)),
                                            //   SizedBox(width: 10,),
                                            //   Expanded(
                                            //       flex:1,
                                            //       child: Text(extractNames("${trackModelData?.order?.members}"),style: TextStyle(fontSize: 16,overflow: TextOverflow.ellipsis),maxLines: 2,))
                                            // ],),

                                            const SizedBox(
                                              height: 10,
                                            ),
                                            Row(
                                              children: [
                                                Icon(
                                                  Icons.location_city,
                                                  color: Colors
                                                      .deepOrange.shade100,
                                                ),
                                                const SizedBox(
                                                  width: 10,
                                                ),
                                                SizedBox(
                                                    width: 230,
                                                    child: Text(
                                                      "${trackModelData?.order?.city} (City)",
                                                      style: const TextStyle(
                                                          fontSize: 16,
                                                          overflow: TextOverflow
                                                              .ellipsis),
                                                      maxLines: 2,
                                                    ))
                                              ],
                                            ),
                                            const SizedBox(
                                              height: 10,
                                            ),
                                            Row(
                                              children: [
                                                Icon(
                                                  Icons.location_on,
                                                  color: Colors
                                                      .deepOrange.shade100,
                                                ),
                                                const SizedBox(
                                                  width: 10,
                                                ),
                                                SizedBox(
                                                    width: 230,
                                                    child: Text(
                                                      "${trackModelData?.order?.venueAddress}",
                                                      style: const TextStyle(
                                                          fontSize: 16,
                                                          overflow: TextOverflow
                                                              .ellipsis),
                                                      maxLines: 2,
                                                    ))
                                              ],
                                            ),

                                            const SizedBox(
                                              height: 10,
                                            ),
                                            Row(
                                              children: [
                                                Icon(
                                                  Icons.share_location,
                                                  color: Colors
                                                      .deepOrange.shade100,
                                                ),
                                                const SizedBox(
                                                  width: 10,
                                                ),
                                                SizedBox(
                                                    width: 230,
                                                    child: Text(
                                                      "${trackModelData?.order?.landmark}",
                                                      style: const TextStyle(
                                                          fontSize: 16,
                                                          overflow: TextOverflow
                                                              .ellipsis),
                                                      maxLines: 2,
                                                    ))
                                              ],
                                            ),

                                            const SizedBox(
                                              height: 10,
                                            ),
                                            Row(
                                              children: [
                                                Icon(
                                                  Icons.date_range,
                                                  color: Colors
                                                      .deepOrange.shade100,
                                                ),
                                                const SizedBox(
                                                  width: 10,
                                                ),
                                                SizedBox(
                                                    width: 230,
                                                    child: Text(
                                                      "Booking Date ( ${formatCreatedAt("${trackModelData?.order?.bookingDate}")} )",
                                                      style: const TextStyle(
                                                          fontSize: 16,
                                                          overflow: TextOverflow
                                                              .ellipsis),
                                                      maxLines: 2,
                                                    ))
                                              ],
                                            ),

                                            const SizedBox(
                                              height: 10,
                                            ),
                                            Row(
                                              children: [
                                                Icon(
                                                  Icons.flag,
                                                  color: Colors
                                                      .deepOrange.shade100,
                                                ),
                                                const SizedBox(
                                                  width: 10,
                                                ),
                                                const Text("India",
                                                    style: TextStyle(
                                                        fontSize: 16,
                                                        overflow: TextOverflow
                                                            .ellipsis)),
                                                const SizedBox(
                                                  width: 120,
                                                ),
                                                Icon(
                                                  Icons.location_city,
                                                  color: Colors
                                                      .deepOrange.shade100,
                                                ),
                                                const SizedBox(
                                                  width: 10,
                                                ),
                                                Text(
                                                    "${trackModelData?.order?.pincode}",
                                                    style: const TextStyle(
                                                        fontSize: 16,
                                                        overflow: TextOverflow
                                                            .ellipsis))
                                              ],
                                            ),
                                            const SizedBox(
                                              height: 15,
                                            ),
                                            trackModelData?.order
                                                        ?.scheduleStatus ==
                                                    1
                                                ? const SizedBox.shrink()
                                                : (trackModelData?.order
                                                                ?.status ==
                                                            "Cancel") ^
                                                        (trackModelData?.order
                                                                ?.status ==
                                                            "Complete")
                                                    ? Container(
                                                        padding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                                horizontal: 10,
                                                                vertical: 5),
                                                        decoration: BoxDecoration(
                                                            color: Colors
                                                                .grey.shade500,
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        8.0)),
                                                        child: const Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .center,
                                                          children: [
                                                            Text("Reschedule",
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        20,
                                                                    overflow:
                                                                        TextOverflow
                                                                            .ellipsis,
                                                                    color: Colors
                                                                        .white,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold)),
                                                            SizedBox(
                                                              width: 8,
                                                            ),
                                                            Icon(
                                                              Icons.edit_square,
                                                              color:
                                                                  Colors.white,
                                                            ),
                                                          ],
                                                        ))
                                                    : InkWell(
                                                        onTap: () {
                                                          // _cityController.text =
                                                          //     "${trackModelData?.order?.city}";
                                                          // _landMarkController.text =
                                                          //     "${trackModelData?.order?.landmark}";
                                                          // sheduleOrderId(
                                                          //     "${trackModelData?.order?.orderId}",
                                                          //     "0",
                                                          //     "0",
                                                          //     null);
                                                          getReschedule(
                                                              "${trackModelData?.order?.orderId}");
                                                        },
                                                        child: Container(
                                                            padding:
                                                                const EdgeInsets
                                                                    .symmetric(
                                                                    horizontal:
                                                                        10,
                                                                    vertical:
                                                                        5),
                                                            decoration: BoxDecoration(
                                                                color: Colors
                                                                    .deepOrange,
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            8.0)),
                                                            child: const Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .center,
                                                              children: [
                                                                Text(
                                                                    "Reschedule",
                                                                    style: TextStyle(
                                                                        fontSize:
                                                                            20,
                                                                        overflow:
                                                                            TextOverflow
                                                                                .ellipsis,
                                                                        color: Colors
                                                                            .white,
                                                                        fontWeight:
                                                                            FontWeight.bold)),
                                                                SizedBox(
                                                                  width: 8,
                                                                ),
                                                                Icon(
                                                                  Icons
                                                                      .edit_square,
                                                                  color: Colors
                                                                      .white,
                                                                ),
                                                              ],
                                                            )),
                                                      ),

                                            Divider(
                                              color: Colors.grey.shade300,
                                            ),
                                            const SizedBox(height: 5),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceEvenly,
                                              children: [
                                                // Share Button (Only Show if Not Refunded)
                                                // if (tourOrderData?.data!.refundStatus != 1)
                                                Expanded(
                                                  child: InkWell(
                                                    onTap: () {
                                                      shareInvoice(context);
                                                    },
                                                    child: Container(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          vertical: 8,
                                                          horizontal: 8),
                                                      decoration: BoxDecoration(
                                                        border: Border.all(
                                                            color:
                                                                Colors.green),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8),
                                                        color: Colors
                                                            .white, // Background color                                        borderRadius: BorderRadius.circular(8), // Rounded corners
                                                        boxShadow: [
                                                          BoxShadow(
                                                            color: Colors
                                                                .green.shade100,
                                                            blurRadius: 4,
                                                            spreadRadius: 2,
                                                            offset:
                                                                const Offset(
                                                                    2, 2),
                                                          ),
                                                        ],
                                                      ),
                                                      child: const Column(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        children: [
                                                          Icon(Icons.share,
                                                              color:
                                                                  Colors.black,
                                                              size:
                                                                  16), // Refund policy icon
                                                          SizedBox(
                                                              width:
                                                                  8), // Spacing
                                                          Text(
                                                            "Share Invoice",
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .green,
                                                                fontSize: 14,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600,
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis),
                                                            maxLines: 2,
                                                          ),
                                                          //SizedBox(width: 5),
                                                          // Icon(Icons.arrow_forward_ios, color: Colors.white, size: 12), // Arrow icon
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(
                                                  width: 5,
                                                ),
                                                // Share Button (Only Show if Not Refunded)
                                                // if (tourOrderData?.data!.refundStatus != 1)
                                                Expanded(
                                                  child: InkWell(
                                                    onTap: () {
                                                      openInvoice(context,
                                                          invoicePdfUrl!);
                                                    },
                                                    child: Container(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          vertical: 8,
                                                          horizontal: 8),
                                                      decoration: BoxDecoration(
                                                        border: Border.all(
                                                            color: Colors.blue),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8),
                                                        color: Colors
                                                            .white, // Background color                                        borderRadius: BorderRadius.circular(8), // Rounded corners
                                                        boxShadow: [
                                                          BoxShadow(
                                                            color: Colors
                                                                .blue.shade100,
                                                            blurRadius: 4,
                                                            spreadRadius: 2,
                                                            offset:
                                                                const Offset(
                                                                    2, 2),
                                                          ),
                                                        ],
                                                      ),
                                                      child: const Column(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        children: [
                                                          Icon(
                                                              Icons
                                                                  .remove_red_eye,
                                                              color:
                                                                  Colors.black,
                                                              size:
                                                                  16), // Refund policy icon
                                                          SizedBox(
                                                              width:
                                                                  8), // Spacing
                                                          Text(
                                                            "View Invoice",
                                                            style: TextStyle(
                                                                color:
                                                                    Colors.blue,
                                                                fontSize: 14,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600,
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis),
                                                            maxLines: 2,
                                                          ),
                                                          //SizedBox(width: 5),
                                                          // Icon(Icons.arrow_forward_ios, color: Colors.white, size: 12), // Arrow icon
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(
                                                  width: 5,
                                                ),
                                                trackModelData?.order?.status ==
                                                        "Complete"
                                                    ? Expanded(
                                                        child: InkWell(
                                                          onTap: () {
                                                            Navigator.push(
                                                              context,
                                                              CupertinoPageRoute(
                                                                builder:
                                                                    (context) =>
                                                                        CertificateViewScreen(
                                                                  certificateImageUrl:
                                                                      '${trackModelData?.order?.poojaCertificate}',
                                                                  issuedDate:
                                                                      '${trackModelData?.order?.bookingDate}',
                                                                  certificateShareMessage:
                                                                      '🌟 आपका प्रमाण पत्र 🌟\n\n'
                                                                      'यह प्रमाण पत्र Mahakal.com ऐप द्वारा आयोजित पूजा में आपकी पवित्र भागीदारी के लिए सम्मानपूर्वक प्रदान किया गया है। 🔱💖\n'
                                                                      'आपकी आस्था और श्रद्धा महादेव की कृपा को सदा बनाए रखे।\n'
                                                                      'हर हर महादेव! 🙏',
                                                                  serviceType:
                                                                      'Pooja',
                                                                ),
                                                              ),
                                                            );
                                                          },
                                                          child: Container(
                                                            padding:
                                                                const EdgeInsets
                                                                    .symmetric(
                                                                    vertical: 8,
                                                                    horizontal:
                                                                        8),
                                                            decoration:
                                                                BoxDecoration(
                                                              border: Border.all(
                                                                  color: Colors
                                                                      .blue),
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          8),
                                                              color: Colors
                                                                  .white, // Background color                                        borderRadius: BorderRadius.circular(8), // Rounded corners
                                                              boxShadow: [
                                                                BoxShadow(
                                                                  color: Colors
                                                                      .orange
                                                                      .shade100,
                                                                  blurRadius: 4,
                                                                  spreadRadius:
                                                                      2,
                                                                  offset:
                                                                      const Offset(
                                                                          2, 2),
                                                                ),
                                                              ],
                                                            ),
                                                            child: const Column(
                                                              mainAxisSize:
                                                                  MainAxisSize
                                                                      .min,
                                                              children: [
                                                                Icon(
                                                                    Icons
                                                                        .document_scanner,
                                                                    color: Colors
                                                                        .black,
                                                                    size:
                                                                        16), // Refund policy icon
                                                                SizedBox(
                                                                    width:
                                                                        8), // Spacing
                                                                Text(
                                                                  "Certificate",
                                                                  style: TextStyle(
                                                                      color: Colors
                                                                          .blue,
                                                                      fontSize:
                                                                          14,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w600,
                                                                      overflow:
                                                                          TextOverflow
                                                                              .ellipsis),
                                                                  maxLines: 2,
                                                                ),
                                                                //SizedBox(width: 5),
                                                                // Icon(Icons.arrow_forward_ios, color: Colors.white, size: 12), // Arrow icon
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                      )
                                                    : const SizedBox()
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ) // adress details
                              : Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    color: Colors.white,
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(15),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Row(
                                          children: [
                                            Icon(Icons.temple_hindu,
                                                color: Colors.deepOrange),
                                            SizedBox(width: 10),
                                            Text(
                                              "Temple Details",
                                              style: TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.deepOrange,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const Divider(color: Colors.grey),

                                        const SizedBox(height: 10),

                                        // Temple Name
                                        Text(
                                          trackModelData?.order?.templeDetails
                                                  ?.name ??
                                              'Temple Name',
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),

                                        const SizedBox(height: 8),
                                        // Booking Date
                                        Row(
                                          children: [
                                            const Icon(
                                              Icons.date_range,
                                              color: Colors.deepOrange,
                                              size: 18,
                                            ),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: Text(
                                                "Booking Date (${formatCreatedAt("${trackModelData?.order?.bookingDate}")})",
                                                style: const TextStyle(
                                                    fontSize: 14),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 10),

                                        // Entry Fee & Timing
                                        Row(
                                          children: [
                                            const Icon(Icons.access_time,
                                                size: 18,
                                                color: Colors.deepOrange),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: Text(
                                                "Timing: ${formatTime(trackModelData?.order?.templeDetails?.openingTime)} - ${formatTime(trackModelData?.order?.templeDetails?.closeingTime)}",
                                                style: const TextStyle(
                                                    fontSize: 14),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 10),

                                        // Facilities
                                        if (trackModelData?.order?.templeDetails
                                                ?.facilities !=
                                            null)
                                          Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              const Icon(Icons.room_service,
                                                  size: 18,
                                                  color: Colors.deepOrange),
                                              const SizedBox(width: 8),
                                              Expanded(
                                                child: Text(
                                                  "Facilities: ${trackModelData?.order?.templeDetails?.facilities}",
                                                  style: const TextStyle(
                                                      fontSize: 14),
                                                  maxLines: 2,
                                                ),
                                              ),
                                            ],
                                          ),
                                        const SizedBox(height: 5),

                                        trackModelData?.order?.scheduleStatus ==
                                                1
                                            ? const SizedBox.shrink()
                                            : (trackModelData?.order?.status ==
                                                        "Cancel") ^
                                                    (trackModelData
                                                            ?.order?.status ==
                                                        "Complete")
                                                ? Container(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 10,
                                                        vertical: 5),
                                                    decoration: BoxDecoration(
                                                        color: Colors
                                                            .grey.shade500,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8.0)),
                                                    child: const Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        Text("Reschedule",
                                                            style: TextStyle(
                                                                fontSize: 20,
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis,
                                                                color: Colors
                                                                    .white,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold)),
                                                        SizedBox(
                                                          width: 8,
                                                        ),
                                                        Icon(
                                                          Icons.edit_square,
                                                          color: Colors.white,
                                                        ),
                                                      ],
                                                    ))
                                                : InkWell(
                                                    onTap: () {
                                                      getReschedule(
                                                          "${trackModelData?.order?.orderId}");
                                                    },
                                                    child: Container(
                                                        padding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                                horizontal: 10,
                                                                vertical: 5),
                                                        decoration: BoxDecoration(
                                                            color: Colors
                                                                .deepOrange,
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        8.0)),
                                                        child: const Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .center,
                                                          children: [
                                                            Text("Reschedule",
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        20,
                                                                    overflow:
                                                                        TextOverflow
                                                                            .ellipsis,
                                                                    color: Colors
                                                                        .white,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold)),
                                                            SizedBox(
                                                              width: 8,
                                                            ),
                                                            Icon(
                                                              Icons.edit_square,
                                                              color:
                                                                  Colors.white,
                                                            ),
                                                          ],
                                                        )),
                                                  ),

                                        Divider(
                                          color: Colors.grey.shade300,
                                        ),
                                        const SizedBox(height: 5),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          children: [
                                            // Share Button (Only Show if Not Refunded)
                                            // if (tourOrderData?.data!.refundStatus != 1)
                                            Expanded(
                                              child: InkWell(
                                                onTap: () {
                                                  shareInvoice(context);
                                                },
                                                child: Container(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      vertical: 8,
                                                      horizontal: 8),
                                                  decoration: BoxDecoration(
                                                    border: Border.all(
                                                        color: Colors.green),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8),
                                                    color: Colors
                                                        .white, // Background color                                        borderRadius: BorderRadius.circular(8), // Rounded corners
                                                    boxShadow: [
                                                      BoxShadow(
                                                        color: Colors
                                                            .green.shade100,
                                                        blurRadius: 4,
                                                        spreadRadius: 2,
                                                        offset:
                                                            const Offset(2, 2),
                                                      ),
                                                    ],
                                                  ),
                                                  child: const Column(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      Icon(Icons.share,
                                                          color: Colors.black,
                                                          size:
                                                              16), // Refund policy icon
                                                      SizedBox(
                                                          width: 8), // Spacing
                                                      Text(
                                                        "Share Invoice",
                                                        style: TextStyle(
                                                            color: Colors.green,
                                                            fontSize: 14,
                                                            fontWeight:
                                                                FontWeight.w600,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis),
                                                        maxLines: 2,
                                                      ),
                                                      //SizedBox(width: 5),
                                                      // Icon(Icons.arrow_forward_ios, color: Colors.white, size: 12), // Arrow icon
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(
                                              width: 5,
                                            ),
                                            // Share Button (Only Show if Not Refunded)
                                            // if (tourOrderData?.data!.refundStatus != 1)
                                            Expanded(
                                              child: InkWell(
                                                onTap: () {
                                                  openInvoice(
                                                      context, invoicePdfUrl!);
                                                },
                                                child: Container(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      vertical: 8,
                                                      horizontal: 8),
                                                  decoration: BoxDecoration(
                                                    border: Border.all(
                                                        color: Colors.blue),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8),
                                                    color: Colors
                                                        .white, // Background color                                        borderRadius: BorderRadius.circular(8), // Rounded corners
                                                    boxShadow: [
                                                      BoxShadow(
                                                        color: Colors
                                                            .blue.shade100,
                                                        blurRadius: 4,
                                                        spreadRadius: 2,
                                                        offset:
                                                            const Offset(2, 2),
                                                      ),
                                                    ],
                                                  ),
                                                  child: const Column(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      Icon(Icons.remove_red_eye,
                                                          color: Colors.black,
                                                          size:
                                                              16), // Refund policy icon
                                                      SizedBox(
                                                          width: 8), // Spacing
                                                      Text(
                                                        "View Invoice",
                                                        style: TextStyle(
                                                            color: Colors.blue,
                                                            fontSize: 14,
                                                            fontWeight:
                                                                FontWeight.w600,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis),
                                                        maxLines: 2,
                                                      ),
                                                      //SizedBox(width: 5),
                                                      // Icon(Icons.arrow_forward_ios, color: Colors.white, size: 12), // Arrow icon
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(
                                              width: 5,
                                            ),
                                            trackModelData?.order?.status ==
                                                    "Complete"
                                                ? Expanded(
                                                    child: InkWell(
                                                      onTap: () {
                                                        Navigator.push(
                                                          context,
                                                          CupertinoPageRoute(
                                                            builder: (context) =>
                                                                CertificateViewScreen(
                                                              certificateImageUrl:
                                                                  '${trackModelData?.order?.poojaCertificate}',
                                                              issuedDate:
                                                                  '${trackModelData?.order?.bookingDate}',
                                                              certificateShareMessage:
                                                                  '🌟 आपका प्रमाण पत्र 🌟\n\n'
                                                                  'यह प्रमाण पत्र Mahakal.com ऐप द्वारा आयोजित पूजा में आपकी पवित्र भागीदारी के लिए सम्मानपूर्वक प्रदान किया गया है। 🔱💖\n'
                                                                  'आपकी आस्था और श्रद्धा महादेव की कृपा को सदा बनाए रखे।\n'
                                                                  'हर हर महादेव! 🙏',
                                                              serviceType:
                                                                  'Pooja',
                                                            ),
                                                          ),
                                                        );
                                                      },
                                                      child: Container(
                                                        padding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                                vertical: 8,
                                                                horizontal: 8),
                                                        decoration:
                                                            BoxDecoration(
                                                          border: Border.all(
                                                              color:
                                                                  Colors.blue),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(8),
                                                          color: Colors
                                                              .white, // Background color                                        borderRadius: BorderRadius.circular(8), // Rounded corners
                                                          boxShadow: [
                                                            BoxShadow(
                                                              color: Colors
                                                                  .orange
                                                                  .shade100,
                                                              blurRadius: 4,
                                                              spreadRadius: 2,
                                                              offset:
                                                                  const Offset(
                                                                      2, 2),
                                                            ),
                                                          ],
                                                        ),
                                                        child: const Column(
                                                          mainAxisSize:
                                                              MainAxisSize.min,
                                                          children: [
                                                            Icon(
                                                                Icons
                                                                    .document_scanner,
                                                                color: Colors
                                                                    .black,
                                                                size:
                                                                    16), // Refund policy icon
                                                            SizedBox(
                                                                width:
                                                                    8), // Spacing
                                                            Text(
                                                              "Certificate",
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .blue,
                                                                  fontSize: 14,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600,
                                                                  overflow:
                                                                      TextOverflow
                                                                          .ellipsis),
                                                              maxLines: 2,
                                                            ),
                                                            //SizedBox(width: 5),
                                                            // Icon(Icons.arrow_forward_ios, color: Colors.white, size: 12), // Arrow icon
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  )
                                                : const SizedBox()
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ) // null temple  temple details,
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(15),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // your product
                          const Row(
                            children: [
                              Icon(
                                Icons.redeem,
                                color: Colors.deepOrange,
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Text("Your Pooja",
                                  style: TextStyle(
                                      fontSize: 20,
                                      overflow: TextOverflow.ellipsis,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.deepOrange)),
                            ],
                          ),
                          const SizedBox(
                            height: 5,
                          ),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(15),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(
                                      0.2), // Slightly transparent black for better aesthetics
                                  blurRadius:
                                      4, // Controls the softness of the shadow
                                  spreadRadius:
                                      1, // Spread the shadow a little// X=0 (centered horizontally), Y=4 (downwards)
                                ),
                              ],
                            ),
                            child: trackModelData?.order?.offlinepooja == null
                                ? const Center(child: Text("Not-Available"))
                                : Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                          flex: 0,
                                          child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(6.0),
                                              child: Image.network(
                                                "${trackModelData?.order?.offlinepooja?.thumbnail}",
                                                fit: BoxFit.fill,
                                                height: 100,
                                              ))),
                                      const SizedBox(
                                        width: 15,
                                      ),
                                      Expanded(
                                        flex: 1,
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "${trackModelData?.order?.offlinepooja?.name} ( ${trackModelData?.order?.offlinepooja?.hiName} )",
                                              style: const TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                  overflow:
                                                      TextOverflow.ellipsis),
                                              maxLines: 2,
                                            ),
                                            Text.rich(TextSpan(children: [
                                              const TextSpan(
                                                  text: "Price : ",
                                                  style: TextStyle(
                                                      color: Colors.black,
                                                      fontSize: 16)),
                                              TextSpan(
                                                  text:
                                                      "₹${trackModelData?.order?.packageMainPrice}",
                                                  style: const TextStyle(
                                                      color: Colors.deepOrange,
                                                      fontSize: 18,
                                                      fontWeight:
                                                          FontWeight.bold)),
                                              const TextSpan(
                                                  text: " (Tax include)",
                                                  style: TextStyle(
                                                      color: Colors.black,
                                                      fontSize: 12)),
                                            ])),
                                          ],
                                        ),
                                      )
                                    ],
                                  ),
                          ),

                          //total bill container
                          const SizedBox(
                            height: 10,
                          ),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(15),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(
                                      0.2), // Slightly transparent black for better aesthetics
                                  blurRadius:
                                      4, // Controls the softness of the shadow
                                  spreadRadius:
                                      1, // Spread the shadow a little// X=0 (centered horizontally), Y=4 (downwards)
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    const Text("Sub total",
                                        style: TextStyle(
                                            fontSize: 16,
                                            overflow: TextOverflow.ellipsis,
                                            color: Colors.green)),
                                    const Spacer(),
                                    Text(
                                        "₹${trackModelData?.order?.packageMainPrice}.0",
                                        style: const TextStyle(
                                            fontSize: 18,
                                            overflow: TextOverflow.ellipsis,
                                            color: Colors.green)),
                                  ],
                                ),
                                const Divider(
                                  color: Colors.grey,
                                ),
                                const SizedBox(
                                  height: 5,
                                ),
                                Row(
                                  children: [
                                    const Text("Coupon Discount",
                                        style: TextStyle(
                                            fontSize: 16,
                                            overflow: TextOverflow.ellipsis,
                                            color: Colors.red)),
                                    const Spacer(),
                                    Text(
                                      trackModelData?.order?.couponAmount ==
                                              null
                                          ? "- ₹0.0"
                                          : "- ₹${trackModelData?.order?.couponAmount}",
                                      style: const TextStyle(
                                        fontSize: 18,
                                        overflow: TextOverflow.ellipsis,
                                        color: Colors.red,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(
                                  height: 5,
                                ),
                                Row(
                                  children: [
                                    const Text("Amount Paid",
                                        style: TextStyle(
                                            fontSize: 16,
                                            overflow: TextOverflow.ellipsis,
                                            color: Colors.black)),
                                    const Spacer(),
                                    Text(
                                      "- ₹${trackModelData?.order?.payAmount}",
                                      style: const TextStyle(
                                        fontSize: 18,
                                        overflow: TextOverflow.ellipsis,
                                        color: Colors.red,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(
                                  height: 5,
                                ),
                                const Divider(
                                  color: Colors.grey,
                                ),
                                trackModelData?.order?.status == "Cancel"
                                    ? Row(
                                        children: [
                                          const Text("Refund amount",
                                              style: TextStyle(
                                                  fontSize: 18,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.bold)),
                                          const Spacer(),
                                          Text(
                                              "₹${trackModelData?.order?.refundAmount}.0",
                                              style: const TextStyle(
                                                  fontSize: 18,
                                                  overflow:
                                                      TextOverflow.ellipsis)),
                                        ],
                                      )
                                    : Row(
                                        children: [
                                          const Text("Remaining amount",
                                              style: TextStyle(
                                                  fontSize: 18,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.bold)),
                                          const Spacer(),
                                          Text(
                                              "₹${trackModelData?.order?.remainAmount}.0",
                                              style: const TextStyle(
                                                  fontSize: 18,
                                                  overflow:
                                                      TextOverflow.ellipsis)),
                                        ],
                                      ),
                              ],
                            ),
                          ),

                          const SizedBox(
                            height: 15,
                          ),
                          trackModelData?.order?.remainAmount == 0
                              ? const SizedBox.shrink()
                              : Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(5),
                                      color: Colors.black12,
                                      border: Border.all(
                                          color: Colors.grey, width: 1.5)),
                                  child: Center(
                                      child: RichText(
                                    text: TextSpan(
                                      text: "",
                                      children: [
                                        TextSpan(
                                          text: trackModelData?.order?.status ==
                                                  "Cancel"
                                              ? "Cancellation Reason : "
                                              : "Important Note : ",
                                          style: const TextStyle(
                                            color: Colors.black,
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            letterSpacing: 0.5,
                                            height: 1.5, // Adjusts line spacing
                                          ),
                                        ),
                                        TextSpan(
                                          text: trackModelData?.order?.status ==
                                                  "Cancel"
                                              ? ""
                                              : "The amount has been deducted from the wallet for Puja advance booking. The remaining ",
                                          style: const TextStyle(
                                            color: Colors.black,
                                            fontSize: 17,
                                            letterSpacing: 0.5,
                                            height: 1.5,
                                          ),
                                        ),
                                        TextSpan(
                                          text: trackModelData?.order?.status ==
                                                  "Cancel"
                                              ? ""
                                              : "₹${trackModelData?.order?.remainAmount ?? '0.0'}",
                                          style: const TextStyle(
                                            color: Colors.orange,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 20,
                                            letterSpacing: 0.5,
                                            height: 1.5,
                                          ),
                                        ),
                                        TextSpan(
                                          text: trackModelData?.order?.status ==
                                                  "Cancel"
                                              ? "${trackModelData?.order?.orderCanceledReason}"
                                              : " must be paid before the Puja starts.",
                                          style: const TextStyle(
                                            color: Colors.black,
                                            fontSize: 17,
                                            letterSpacing: 0.5,
                                            height: 1.5,
                                          ),
                                        ),
                                      ],
                                    ),
                                  )),
                                ),

                          const SizedBox(
                            height: 20,
                          ),
                          Row(
                            children: [
                              const Text("Payment Id",
                                  style: TextStyle(
                                      fontSize: 16,
                                      overflow: TextOverflow.ellipsis,
                                      color: Colors.black)),
                              const Spacer(),
                              Text("${trackModelData?.order?.paymentId}",
                                  style: const TextStyle(
                                      fontSize: 16,
                                      overflow: TextOverflow.ellipsis,
                                      color: Colors.deepOrange,
                                      fontWeight: FontWeight.bold)),
                            ],
                          ),

                          const SizedBox(
                            height: 5,
                          ),
                          // Row(children: [
                          //   Text("Payment platform",style: TextStyle(fontSize: 16,overflow: TextOverflow.ellipsis,color: Colors.black)),
                          //   Spacer(),
                          //   Text("Online Payment",style: TextStyle(fontSize: 16,overflow: TextOverflow.ellipsis,color: Colors.blue,fontWeight: FontWeight.bold)),
                          // ],),

                          // trackModelData?.order?.status == "Complete"
                          // ? Column(
                          //   children: [
                          //     const SizedBox(height: 15 ,),
                          //     trackModelData?.isReview == 1
                          //         ? Container(
                          //           height: 50,
                          //           width: double.infinity,
                          //           padding: const EdgeInsets.symmetric(vertical: 5,horizontal: 10),
                          //           decoration: BoxDecoration(
                          //             borderRadius: BorderRadius.circular(8),
                          //             border: Border.all(color: Colors.grey.shade400,width: 2),
                          //           ),
                          //           child: const Row(
                          //               children: [
                          //                 Text("Review added successfully ✨",style: TextStyle(fontSize: 16,fontWeight: FontWeight.w400,color: Colors.grey),),
                          //                 Spacer(),
                          //                 Center(child: Icon(CupertinoIcons.checkmark_circle_fill,color: Colors.green,)),
                          //               ]
                          //           ),
                          //         )
                          //         : InkWell(
                          //       onTap: (){
                          //         showFeedbackBottomSheet();
                          //       },
                          //       child: Container(
                          //         height: 50,
                          //         width: double.infinity,
                          //         padding: const EdgeInsets.symmetric(vertical: 5,horizontal: 10),
                          //         decoration: BoxDecoration(
                          //           borderRadius: BorderRadius.circular(100),
                          //           border: Border.all(color: Colors.grey.shade400,width: 2),
                          //         ),
                          //         child: const Row(
                          //             children: [
                          //               Text("Write Your Experience",style: TextStyle(fontSize: 16,fontWeight: FontWeight.w400),),
                          //               Spacer(),
                          //               Center(child: Icon(CupertinoIcons.arrow_right_circle_fill,color: Colors.blue,)),
                          //             ]
                          //         ),
                          //       ),
                          //     ),
                          //   ],
                          // ) : const SizedBox.shrink(),

                          const SizedBox(
                            height: 25,
                          ),
                          const Text(
                              "If you need any kind of help or support regarding pandit booking kindly contact us.",
                              style:
                                  TextStyle(fontSize: 14, color: Colors.grey)),
                          InkWell(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    PageAnimationTransition(
                                        page: const SupportTicketScreen(),
                                        pageAnimationType:
                                            RightToLeftTransition()));
                              },
                              child: InkWell(
                                  onTap: () {
                                    Navigator.push(
                                        context,
                                        PageAnimationTransition(
                                            page: const SupportTicketScreen(),
                                            pageAnimationType:
                                                RightToLeftTransition()));
                                  },
                                  child: const Text("Support Center",
                                      style: TextStyle(
                                          fontSize: 16,
                                          overflow: TextOverflow.ellipsis,
                                          color: Colors.deepOrange)))),

                          const SizedBox(
                            height: 80,
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
          );
  }
}

class BlinkingLockOverlay extends StatefulWidget {
  const BlinkingLockOverlay({super.key});

  @override
  State<BlinkingLockOverlay> createState() => _BlinkingLockOverlayState();
}

class _BlinkingLockOverlayState extends State<BlinkingLockOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacity;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(reverse: true);

    _opacity = Tween(begin: 1.0, end: 0.3).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _scale = Tween(begin: 1.0, end: 1.3).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black12, // Semi-transparent black
      child: Center(
        child: FadeTransition(
          opacity: _opacity,
          child: ScaleTransition(
            scale: _scale,
            child: const Icon(
              CupertinoIcons.lock_circle,
              color: Colors.white,
              size: 80,
            ),
          ),
        ),
      ),
    );
  }
}
