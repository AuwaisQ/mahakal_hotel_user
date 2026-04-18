import 'dart:convert';

import 'package:country_picker/country_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mahakal/features/maha_bhandar/model/city_model.dart';
import 'package:geocoding/geocoding.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import '../../../data/datasource/remote/http/httpClient.dart';
import '../../../main.dart';
import '../../../utill/app_constants.dart';
import '../../../utill/completed_order_dialog.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../custom_bottom_bar/bottomBar.dart';

class OfflinePersonDetails extends StatefulWidget {
  final String billAmount;
  final String pjIdOrder;
  final String id;
  final String location;
  const OfflinePersonDetails(
      {super.key,
      required this.billAmount,
      required this.pjIdOrder,
      required this.id,
      required this.location});

  @override
  State<OfflinePersonDetails> createState() => _OfflinePersonDetailsState();
}

class _OfflinePersonDetailsState extends State<OfflinePersonDetails> {
  final TextEditingController _venueAddressController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _landMarkController = TextEditingController();
  final TextEditingController _pincodeController = TextEditingController();
  final TextEditingController roleIdController = TextEditingController();
  String? selectedTempleId;
  String selectedMode = 'online'; // default
  String selectedTempleMode = 'address'; // default
  List<CityPickerModel> cityListModel = <CityPickerModel>[];
  // List<Citylist> pcodeListModel = <Citylist>[];
  List<String> textValues = []; // Create a list to store the text values
  List<Temple> templeList =
      <Temple>[]; // Create a list to store the text values
  String mess = '';
  String userToken = '';
  String _selectedDate = '';
  String? _personName;
  String? _personState;
  double latiTude = 0.0;
  double longiTude = 0.0;
  String? _personAddress;
  int? selectedPincode; // 👈 selected pincode

  final billFormKey = GlobalKey<FormState>();
  final bool _showText = false;
  bool isYesNo = false;
  bool isChecked = false;
  bool isLoading = false;

  Future<void> fetchTempleList() async {
    String id = widget.id;
    final response = await HttpService().getApi('/api/v1/offlinepooja/temple?id=$id');

    final List data = response['temples'];
    setState(() {
      templeList = data.map((e) => Temple.fromJson(e)).toList();
    });
    print("${'/api/v1/offlinepooja/temple?id=$id'}\n templeList $templeList");
  }

  /// Select Date
  Future<DateTime?> _selectDate(BuildContext context) async {
    final DateTime today = DateTime.now();

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: today,
      firstDate: today,
      lastDate: DateTime(2100),

      /// 🎨 White + DeepOrange Theme
      builder: (context, child) {
        return Theme(
          data: ThemeData(
            brightness: Brightness.light,
            dialogBackgroundColor: Colors.white,
            colorScheme: const ColorScheme.light(
              primary: Colors.deepOrange, // selected date & header
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.deepOrange, // date text
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Colors.deepOrange, // OK / CANCEL
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
      });
    }

    return picked;
  }



  //button functionality
  void _submitForm() {
    isLoading = true;
    if (selectedTempleMode == 'address') {
      if (_selectedDate.isEmpty ||
          _pincodeController.text.isEmpty ||
          _venueAddressController.text.isEmpty ||
          _landMarkController.text.isEmpty) {
        billFormKey.currentState!.validate();
        Fluttertoast.showToast(
            msg: 'Form fields Required!',
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.red,
            textColor: Colors.white);
        setState(() {
          isLoading = false;
        });
      } else {
        // saveTextValues();
        personDetails(widget.pjIdOrder);
      }
    } else {
      if (templeList.isEmpty) {
        Fluttertoast.showToast(
            msg: 'No preferred temple available!',
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.red,
            textColor: Colors.white);
        setState(() {
          isLoading = false;
        });
      } else {
        personDetails(widget.pjIdOrder);
      }
    }
  }

  List<CityDatum> pcodeListModel = [];
  void getCityData(String orderId) async {
    var res = await HttpService()
        .getApi('/api/v1/offlinepooja/city?order_id=$orderId');
    print('response api ${widget.pjIdOrder} $res');

    if (res['status']) {
      List cityList = res['city_data'];
      setState(() {
        pcodeListModel = cityList.map((e) => CityDatum.fromJson(e)).toList();
        _stateController.text = res['state']['states']['name'];
      });
      print('✅ City List Loaded: ${pcodeListModel.length}');
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
        'order_id': orderId,
        'pooja_method': selectedMode,
        'pooja_venue_type': selectedTempleMode,
        'temple_id': selectedTempleId,
        'venue_address': _venueAddressController.text,
        'state': _stateController.text,
        'city': _cityController.text,
        'pincode': _pincodeController.text,
        'latitude': '$latiTude',
        'longitude': '$longiTude',
        'booking_date': _selectedDate,
        'landmark': _landMarkController.text
      }),
    );

    print('Response Code: ${response.statusCode}');
    print('Response Body: ${response.body}');

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);

      if (data['status']) {
        // Update UI
        setState(() {
          // couponAmount = data["data"]["coupon_amount"];
          // amtAfterDis = data["data"]["final_amount"];
          // isCouponApplyed = true;
          // walletMinusAmount = 0;
          // walletMinusAmount = max(walletPay - amtAfterDis.toInt(), 0);
          // finalAmount = (walletPay - amtAfterDis.toInt()).abs();
        });
        print("Response Body: ${data["status"]}");
        Navigator.of(context).pushReplacement(CupertinoPageRoute(
            builder: (BuildContext context) => const BottomBar(pageIndex: 0)));
        showDialog(
          context: context,
          builder: (context) => bookingSuccessDialog(
            context: context,
            tabIndex: 9,
            title: 'Pandit Booked!',
            message:
                'Your pandit has been successfully booked. You will receive further details soon.',
          ),
          barrierDismissible: true,
        );
      } else {}
    }
  }

  //Country Picker
  final Country _selectedCountry = Country(
    phoneCode: '91',
    countryCode: 'IN',
    e164Sc: 0,
    geographic: true,
    level: 1,
    name: 'India',
    example: '9123456789',
    displayName: 'India',
    displayNameNoCountryCode: 'India',
    e164Key: '91-IN-0',
  );

  @override
  void initState() {
    userToken =
        Provider.of<AuthController>(Get.context!, listen: false).getUserToken();
    super.initState();
    fetchTempleList();
    getCityData(widget.pjIdOrder);
  }

  @override
  void dispose() {
    // Dispose controllers to avoid memory leaks
    // for (var controller in textControllers) {
    //   controller.dispose();
    // }
    super.dispose();
  }

  Future<bool> _showExitDialog(BuildContext context) async {
    return await showCupertinoDialog(
          context: context,
          builder: (context) => CupertinoAlertDialog(
            title: const Text('Confirm Exit'),
            content: const Text('Are you sure you want to go back?'),
            actions: [
              CupertinoDialogAction(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              CupertinoDialogAction(
                onPressed: () => Navigator.of(context).pop(true),
                isDestructiveAction: true, // Red color for emphasis
                child: const Text('Yes'),
              ),
            ],
          ),
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    // int numberOfFields = widget.personCount;
    // final List<TextEditingController> textControllers = List.generate(numberOfFields, (index) => TextEditingController());
    var screenWidth = MediaQuery.of(context).size.width;
    var screenHeight = MediaQuery.of(context).size.height;

    return WillPopScope(
      onWillPop: () async {
        bool confirmExit = await _showExitDialog(context);
        return confirmExit;
      },
      child: Scaffold(
        bottomNavigationBar: isLoading
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
                onTap: () {
                  _submitForm();
                },
                child: Container(
                  margin: const EdgeInsets.all(10),
                  height: 45,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8.0),
                    color: Colors.orange,
                  ),
                  child: const Center(
                    child: Text(
                      'Submit',
                      style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: const Text(
            'Booking details',
            style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w400,
                fontFamily: 'Roboto',
                color: Colors.orange),
          ),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          child: Form(
            key: billFormKey,
            child: Column(
              children: [
                const SizedBox(height: 20),
                Container(
                  margin: const EdgeInsets.all(12),
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
                        'Select the date on which you wish to perform the Puja',
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
                        'Booking Amount : ₹${widget.billAmount}',
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
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        child: Row(
                          children: [
                            Expanded(
                              child: Row(
                                children: [
                                  Radio<String>(
                                    value: 'online',
                                    groupValue: selectedMode,
                                    activeColor: Colors.deepOrange,
                                    onChanged: (value) =>
                                        setState(() => selectedMode = value!),
                                  ),
                                  const Text('Online'),
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
                                    value: 'offline',
                                    groupValue: selectedMode,
                                    activeColor: Colors.deepOrange,
                                    onChanged: (value) =>
                                        setState(() => selectedMode = value!),
                                  ),
                                  const Text('Offline'),
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
                        label: 'Select Date',
                        onTap: () => _selectDate(context),
                        content: _selectedDate.isEmpty
                            ? 'Choose Date'
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
                              color: Colors.deepOrange.withOpacity(0.25),
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
                                onTap: () => setState(
                                    () => selectedTempleMode = 'address'),
                                child: Row(
                                  children: [
                                    Radio<String>(
                                      value: 'address',
                                      groupValue: selectedTempleMode,
                                      activeColor: Colors.white,
                                      fillColor:
                                          WidgetStateProperty.all(Colors.white),
                                      onChanged: (value) => setState(
                                          () => selectedTempleMode = value!),
                                    ),
                                    Text(
                                      'Your Address',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight:
                                            selectedTempleMode == 'address'
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
                                color: Colors.white.withOpacity(0.6)),
                            Expanded(
                              child: InkWell(
                                onTap: () => setState(
                                    () => selectedTempleMode = 'temple'),
                                child: Row(
                                  children: [
                                    Radio<String>(
                                      value: 'temple',
                                      groupValue: selectedTempleMode,
                                      activeColor: Colors.white,
                                      fillColor:
                                          WidgetStateProperty.all(Colors.white),
                                      onChanged: (value) => setState(
                                          () => selectedTempleMode = value!),
                                    ),
                                    Text(
                                      'Preferred Temple',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight:
                                            selectedTempleMode == 'temple'
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
                          getCityData(widget.pjIdOrder);
                        },
                        child: Text(
                          'Address',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade800,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      if (selectedTempleMode == 'address') ...[
                        /// Venue Address
                        TextFormField(
                          controller: _venueAddressController,
                          // onChanged: (value) => updateValue(value),
                          decoration: InputDecoration(
                            hintText: 'Venue Address',
                            prefixIcon: const Icon(Icons.location_on_outlined,
                                color: Colors.deepOrange),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(
                                  color: Colors.deepOrange, width: 1.5),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide:
                                  BorderSide(color: Colors.grey.shade300),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(
                                  color: Colors.deepOrange, width: 1.5),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 16),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                      color: Colors.grey.shade400, width: 1),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      CupertinoIcons.location_solid,
                                      color: Colors.deepOrange,
                                    ),
                                    SizedBox(
                                      width: 8,
                                    ),
                                    Text(
                                      '${widget.location}',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.grey,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
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
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                    color: Colors.grey.shade400, width: 1),
                              ),
                              child: DropdownButtonFormField<int>(
                                value: selectedPincode,
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                ),
                                hint: const Text(
                                  'Select Pincode',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                icon: const Icon(Icons.keyboard_arrow_down,
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
                                  setState(() {
                                    selectedPincode = value;
                                    _pincodeController.text = value.toString();

                                    // latitude & longitude set करना
                                    CityDatum selectedCity = pcodeListModel
                                        .firstWhere((c) => c.pincode == value);
                                    latiTude = selectedCity.latitude;
                                    longiTude = selectedCity.longitude;
                                    _cityController.text = selectedCity.name;
                                  });

                                  print('✅ Selected Pincode: $selectedPincode');
                                  // print("📍 Latitude: $latiTude, Longitude: $lonGitude");
                                },
                              ),
                            )),
                          ],
                        ),

                        /// Landmark
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _landMarkController,
                          validator: (value) =>
                              value!.isEmpty ? 'Required LandMark' : null,
                          decoration: InputDecoration(
                            hintText: 'Landmark',
                            prefixIcon: const Icon(Icons.share_location,
                                color: Colors.deepOrange),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),
                      ],

                      if (selectedTempleMode == 'temple') ...[
                        /// Dropdown Temple List
                        templeList.isEmpty
                            ? const Center(
                                child: Text('No preferred temple available'),
                              )
                            : Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  color: Colors.grey.shade50,
                                  border: Border.all(color: Colors.grey.shade300),
                                ),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 8),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<String>(
                                    isExpanded: true,
                                    value: selectedTempleId,
                                    icon: const Icon(
                                        Icons.keyboard_arrow_down_rounded,
                                        color: Colors.deepOrange),
                                    items: templeList.map((role) {
                                      return DropdownMenuItem<String>(
                                        value: role.id.toString(),
                                        child: Text(role.name,
                                            style:
                                                const TextStyle(fontSize: 16)),
                                      );
                                    }).toList(),
                                    onChanged: (newValue) {
                                      setState(() {
                                        selectedTempleId = newValue!;
                                        roleIdController.text = newValue;
                                      });
                                    },
                                    hint: Row(
                                      children: [
                                        const Icon(Icons.temple_buddhist,
                                            size: 20, color: Colors.grey),
                                        const SizedBox(width: 10),
                                        Text('Select Temple',
                                            style: TextStyle(
                                                color: Colors.grey.shade600)),
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
                  height: 60,
                )
              ],
            ),
          ),
        ),
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
                  content.isEmpty ? 'Select $label' : content,
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

class Temple {
  int id;
  String name;
  String enName;
  String hiName;
  List<dynamic> translations;

  Temple({
    required this.id,
    required this.name,
    required this.enName,
    required this.hiName,
    required this.translations,
  });

  factory Temple.fromJson(Map<String, dynamic> json) => Temple(
        id: json['id'],
        name: json['name'],
        enName: json['en_name'],
        hiName: json['hi_name'],
        translations: List<dynamic>.from(json['translations'].map((x) => x)),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'en_name': enName,
        'hi_name': hiName,
        'translations': List<dynamic>.from(translations.map((x) => x)),
      };
}

class CityDatum {
  int id;
  int cityId;
  String name;
  int pincode;
  double latitude;
  double longitude;
  int status;
  String createdAt;
  String updatedAt;
  List<dynamic> translations;

  CityDatum({
    required this.id,
    required this.cityId,
    required this.name,
    required this.pincode,
    required this.latitude,
    required this.longitude,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.translations,
  });

  factory CityDatum.fromJson(Map<String, dynamic> json) => CityDatum(
        id: json['id'],
        cityId: json['city_id'],
        name: json['name'],
        pincode: json['pincode'],
        latitude: (json['latitude'] as num).toDouble(),
        longitude: (json['longitude'] as num).toDouble(),
        status: json['status'],
        createdAt: json['created_at'],
        updatedAt: json['updated_at'],
        translations: List<dynamic>.from(json['translations'].map((x) => x)),
      );
}
