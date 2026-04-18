import 'dart:convert';
import 'dart:io';
import 'package:country_picker/country_picker.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mahakal/data/datasource/remote/http/httpClient.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:mahakal/utill/loading_datawidget.dart';
import 'package:page_animation_transition/animations/right_to_left_transition.dart';
import 'package:page_animation_transition/page_animation_transition.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../main.dart';
import '../../../../utill/app_constants.dart';
import '../../../../utill/flutter_toast_helper.dart';
import '../../../auth/controllers/auth_controller.dart';
import '../../../maha_bhandar/model/city_model.dart';
import '../../../profile/controllers/profile_contrroller.dart';
import '../../../support/screens/support_ticket_screen.dart';
import '../../model/trackdetail_model.dart';
import 'package:http/http.dart' as http;
import 'invoice_view_screen.dart';
import 'tracking_screen_counselling.dart';

class CounsellingTrackOrder extends StatefulWidget {
  final String poojaId;
  const CounsellingTrackOrder({super.key, required this.poojaId});

  @override
  State<CounsellingTrackOrder> createState() => _CounsellingTrackOrderState();
}

class _CounsellingTrackOrderState extends State<CounsellingTrackOrder> {
  String userName = "";
  String userNumber = "";
  String userToken = "";
  TrackDetailModel? trackModelData;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController _suggestionsController = TextEditingController();
  String? latitude;
  String? longitude;
  String? selectedLocation;
  String? timeHour;
  String? timeMinute;
  int _maleValue = 0;
  int _selectedRating = 3;
  String gender = "male";
  bool isLoading = false;
  //model list
  List<CityPickerModel> cityListModel = <CityPickerModel>[];
  final infoFormKey = GlobalKey<FormState>();
  ScrollController scrollController = ScrollController();

  List<String> options = [
    "The online puja was beautifully performed, making me feel connected to the divine right from my home. A truly peaceful and blessed experience! 🙏✨",
    "Did the puja meet your expectations in terms of rituals and authenticity?",
    "Were all your spiritual and religious needs fulfilled during the puja? If not, what more can we do?",
    "Looking for a specific puja or spiritual service? Share your suggestions with us",
    "The Panditji should explain the significance of each step during the puja.",
    "The booking process should be more user-friendly.",
    "I should receive post-puja guidance on what to do next.",
    // ... more options
  ];

  int _selectedIndex = 0; // -1 means no option is selected

  void _handleCheckboxChange(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

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

  //Serach box
  bool searchbox = false;
  void searchBox() {
    if (cityController.text.length > 1) {
      setState(() {
        searchbox = true;
      });
    } else if (cityController.text.isEmpty) {
      setState(() {
        searchbox = false;
      });
    }
    print("serchbox $searchbox");
  }

  // country picker api
  void getCityPick() async {
    print("object");
    cityListModel.clear();
    var response = await http.post(
      Uri.parse('https://geo.vedicrishi.in/places/'),
      body: {
        "country": _selectedCountry.name,
        "name": cityController.text,
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

  void submitForm(StateSetter modalSetter, String addUpdate) {
    modalSetter(() {
      isLoading = true;
    });
    if (_nameController.text.isEmpty ||
        _mobileController.text.isEmpty ||
        _dateController.text.isEmpty ||
        _timeController.text.isEmpty ||
        cityController.text.isEmpty) {
      // billFormKey.currentState!.validate();

// For general toast
      ToastHelper.showToast(message: "Form fields required!");
      modalSetter(() {
        isLoading = false;
      });
    } else {
      addUpdate == "add"
          ? getSankalpdata("${trackModelData?.order?.orderId}")
          : getUpdateSankalpData("${trackModelData?.order?.orderId}");
      modalSetter(() {
        isLoading = false;
      });
    }
  }

  Future<void> getSankalpdata(String orderId) async {
    // Define the API endpoint
    const String apiUrl = AppConstants.baseUrl + AppConstants.getSankalpDataUrl;

    // Create the data payload
    Map<String, dynamic> data = {
      "order_id": orderId,
      "name": _nameController.text,
      "gender": gender,
      "mobile": _mobileController.text,
      "dob": _dateController.text,
      "time": "$timeHour:$timeMinute",
      "country": _selectedCountry.name,
      "city": cityController.text
    };

    // Make the POST request
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(data),
      );

      if ([200, 201].contains(response.statusCode)) {
        // Handle success
        print('Booking successful pooja ${response.body}');
        Navigator.pop(context);
        setState(() {
          isLoading = false;
        });
        getTrackData(widget.poojaId);
      } else {
        // Handle error
        print('Failed to book pooja: ${response.statusCode}');
        print(response.body);
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      // Handle exception
      print('An error occurred: $e');
    }
  }

  Future<void> getUpdateSankalpData(String orderId) async {
    // Define the API endpoint
    String apiUrl =
        AppConstants.baseUrl + AppConstants.upDateSankalpDataUrl + orderId;

    // Create the data payload
    Map<String, dynamic> data = {
      "name": _nameController.text,
      "gender": gender,
      "mobile": _mobileController.text,
      "dob": _dateController.text,
      "time": "$timeHour:$timeMinute",
      "country": _selectedCountry.name,
      "city": cityController.text
    };

    // Make the POST request
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(data),
      );

      if ([200, 201].contains(response.statusCode)) {
        // Handle success
        print('Booking successful pooja ${response.body}');
        Navigator.pop(context);
        setState(() {
          isLoading = false;
        });
        getTrackData(widget.poojaId);
      } else {
        // Handle error
        print('Failed to book pooja: ${response.statusCode}');
        print(response.body);
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      // Handle exception
      print('An error occurred: $e');
    }
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
          DateFormat('dd-MMMM-yyyy').format(dateTime).toLowerCase();

      return formattedDate; // Return the formatted date
    } catch (e) {
      // Handle invalid input gracefully
      return "Invalid date";
    }
  }

  void showInfoBottomSheet(String checkUpdate) {
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
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
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
                          title: Text(
                            checkUpdate == "add"
                                ? 'Add Details'
                                : 'Update Details',
                            style: const TextStyle(
                                fontSize: 18.0, fontWeight: FontWeight.bold),
                          ),
                        ),
                        SingleChildScrollView(
                          child: Form(
                            key: infoFormKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                const SizedBox(
                                  height: 10.0,
                                ),
                                // name
                                const Text(
                                  " Name",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                TextField(
                                  cursorColor: Colors.orange,
                                  controller: _nameController,
                                  style: const TextStyle(
                                      fontFamily: 'Roboto-Regular'),
                                  decoration: InputDecoration(
                                    hintText: "Enter Your Name",
                                    hintStyle:
                                        const TextStyle(color: Colors.grey),
                                    contentPadding: const EdgeInsets.symmetric(
                                        vertical: 10.0, horizontal: 10.0),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: const BorderSide(
                                          color: Colors.grey, width: 1),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: const BorderSide(
                                          color: Colors.grey, width: 1),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: const BorderSide(
                                          color: Colors.orange, width: 1),
                                    ),
                                    suffixIcon: const Icon(Icons.person_outline,
                                        color: Colors.grey, size: 30),
                                  ),
                                ),
                                const SizedBox(height: 15.0),

                                const Text(
                                  " Mobile No.",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                TextFormField(
                                  cursorColor: Colors.orange,
                                  inputFormatters: [
                                    FilteringTextInputFormatter
                                        .digitsOnly, // Allow only digits
                                    LengthLimitingTextInputFormatter(
                                        10), // Limit to 10 digits
                                  ],
                                  controller: _mobileController,
                                  style: const TextStyle(
                                      fontFamily: 'Roboto-Regular'),
                                  decoration: InputDecoration(
                                    hintText: "Mobile Number",
                                    hintStyle:
                                        const TextStyle(color: Colors.grey),
                                    contentPadding: const EdgeInsets.symmetric(
                                        vertical: 10.0, horizontal: 10.0),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: const BorderSide(
                                          color: Colors.grey, width: 1),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: const BorderSide(
                                          color: Colors.grey, width: 1),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: const BorderSide(
                                          color: Colors.orange, width: 1),
                                    ),
                                    suffixIcon: const Icon(Icons.phone,
                                        color: Colors.grey, size: 30),
                                  ),
                                ),
                                const SizedBox(height: 15.0),

                                const Text("Gender"),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Radio(
                                      materialTapTargetSize:
                                          MaterialTapTargetSize.shrinkWrap,
                                      activeColor: Colors.orange,
                                      value: 1, // Value assigned to "Male"
                                      groupValue: _maleValue,
                                      onChanged: (value) {
                                        modalSetter(() {
                                          _maleValue = value as int;
                                          gender =
                                              "male"; // Cast as int for safety
                                        });
                                      },
                                    ),
                                    const Text('Male '),
                                    Radio(
                                      materialTapTargetSize:
                                          MaterialTapTargetSize.shrinkWrap,
                                      value: 2, // Value assigned to "Female"
                                      activeColor: Colors.orange,
                                      groupValue: _maleValue,
                                      onChanged: (value) {
                                        modalSetter(() {
                                          print(_maleValue);
                                          _maleValue = value as int;
                                          gender =
                                              "female"; // Cast as int for safety
                                        });
                                      },
                                    ),
                                    const Text('Female '),
                                  ],
                                ),
                                // Birth Date
                                const Text(
                                  " Birth Date",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                Container(
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: Colors.grey),
                                  ),
                                  child: TextButton(
                                    onPressed: () async {
                                      DateTime? pickedDate =
                                          await showDatePicker(
                                        context: context,
                                        initialDate: DateTime.now(),
                                        firstDate: DateTime(1900),
                                        lastDate: DateTime.now(),
                                        builder: (BuildContext context,
                                            Widget? child) {
                                          return Theme(
                                            data: ThemeData.light().copyWith(
                                              colorScheme:
                                                  const ColorScheme.light(
                                                primary: Colors.white,
                                                onPrimary: Colors.orange,
                                                surface: Color(0xFFFFF7EC),
                                                onSurface: Colors.orange,
                                              ),
                                              textButtonTheme:
                                                  TextButtonThemeData(
                                                style: TextButton.styleFrom(
                                                  foregroundColor:
                                                      Colors.orange,
                                                  backgroundColor: Colors.white,
                                                ),
                                              ),
                                              dialogTheme:
                                                  const DialogThemeData(
                                                      backgroundColor:
                                                          Color(0xFFFFF7EC)),
                                            ),
                                            child: child!,
                                          );
                                        },
                                      );
                                      if (pickedDate != null) {
                                        modalSetter(() {
                                          _dateController.text =
                                              DateFormat('yyyy-MM-dd')
                                                  .format(pickedDate);
                                        });
                                      }
                                    },
                                    style: TextButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10.0),
                                      alignment: Alignment.centerLeft,
                                      backgroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        _dateController.text.isEmpty
                                            ? const Text(
                                                "Select Date",
                                                style: TextStyle(
                                                    fontSize: 16,
                                                    color: Colors.grey,
                                                    fontFamily:
                                                        'Roboto-Regular'),
                                              )
                                            : Text(
                                                _dateController.text,
                                                style: const TextStyle(
                                                    fontSize: 16,
                                                    color: Colors.black,
                                                    fontFamily:
                                                        'Roboto-Regular'),
                                              ),
                                        const Icon(
                                            Icons.calendar_month_outlined,
                                            color: Colors.grey,
                                            size: 30),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 15.0),

                                // Birth Timing
                                const Text(
                                  " Birth Time",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                Container(
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: Colors.grey),
                                  ),
                                  child: TextButton(
                                    onPressed: () async {
                                      TimeOfDay? pickedTime =
                                          await showTimePicker(
                                        initialTime: TimeOfDay.now(),
                                        context: context,
                                        builder: (BuildContext context,
                                            Widget? child) {
                                          return Theme(
                                            data: ThemeData.light().copyWith(
                                              timePickerTheme:
                                                  const TimePickerThemeData(
                                                dialHandColor: Colors.orange,
                                                dialTextColor: Colors.orange,
                                                dialBackgroundColor:
                                                    Colors.white,
                                                dayPeriodColor: Colors.white,
                                                dayPeriodTextColor:
                                                    Colors.orange,
                                                backgroundColor:
                                                    Color(0xFFFFF7EC),
                                                hourMinuteTextColor:
                                                    Colors.orange,
                                                hourMinuteColor: Colors.white,
                                                inputDecorationTheme:
                                                    InputDecorationTheme(
                                                  border: InputBorder.none,
                                                  filled: true,
                                                  fillColor: Colors.white,
                                                  hintStyle: TextStyle(
                                                      color: Colors.orange),
                                                  labelStyle: TextStyle(
                                                      color: Colors.orange),
                                                ),
                                              ),
                                              textButtonTheme:
                                                  TextButtonThemeData(
                                                style: TextButton.styleFrom(
                                                  foregroundColor:
                                                      Colors.orange,
                                                  backgroundColor: Colors.white,
                                                  shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10)),
                                                ),
                                              ),
                                              dialogTheme:
                                                  const DialogThemeData(
                                                      backgroundColor:
                                                          Colors.white),
                                            ),
                                            child: child!,
                                          );
                                        },
                                      );
                                      if (pickedTime != null) {
                                        modalSetter(() {
                                          _timeController.text =
                                              pickedTime.format(context);
                                          timeHour = pickedTime.hour
                                              .toString()
                                              .padLeft(2, "0");
                                          timeMinute = pickedTime.minute
                                              .toString()
                                              .padLeft(2, "0");
                                        });
                                      }
                                    },
                                    style: TextButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10.0),
                                      alignment: Alignment.centerLeft,
                                      backgroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        _timeController.text.isEmpty
                                            ? const Text(
                                                "Select Time",
                                                style: TextStyle(
                                                    fontSize: 16,
                                                    color: Colors.grey,
                                                    fontFamily:
                                                        'Roboto-Regular'),
                                              )
                                            : Text(
                                                _timeController.text,
                                                style: const TextStyle(
                                                    fontSize: 16,
                                                    color: Colors.black,
                                                    fontFamily:
                                                        'Roboto-Regular'),
                                              ),
                                        const Icon(Icons.timelapse_outlined,
                                            color: Colors.grey, size: 30),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 15.0),

                                Row(
                                  children: [
                                    // country
                                    Expanded(
                                      flex: 1,
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Text('Country',
                                              style: TextStyle(
                                                  fontSize: 16,
                                                  color: Colors.black,
                                                  fontFamily: 'Roboto')),
                                          InkWell(
                                            onTap: () {
                                              showCountryPicker(
                                                context: context,
                                                showPhoneCode:
                                                    false, // optional. Shows phone code before the country name.
                                                onSelect: (country) {
                                                  modalSetter(() {
                                                    _selectedCountry = country;
                                                  });
                                                },
                                              );
                                            },
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 6),
                                              margin: const EdgeInsets.all(2),
                                              decoration: BoxDecoration(
                                                color: Colors.grey.shade100,
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                border: Border.all(
                                                    color: Colors.grey),
                                              ),
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            8.0),
                                                    child: Center(
                                                      child: Text(
                                                        _selectedCountry != null
                                                            ? _selectedCountry
                                                                .flagEmoji
                                                            : 'No country selected',
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                    const SizedBox(
                                      width: 10,
                                    ),
                                    // location
                                    Expanded(
                                      flex: 3,
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Text('City',
                                              style: TextStyle(
                                                  fontSize: 16,
                                                  color: Colors.black,
                                                  fontFamily: 'Roboto')),
                                          Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 8.0),
                                              width: double.infinity,
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                border: Border.all(
                                                    color: Colors.grey),
                                              ),
                                              child: TextFormField(
                                                controller: cityController,
                                                onChanged: (value) {
                                                  modalSetter(() {
                                                    updateValue(value);
                                                  });
                                                },
                                                decoration: const InputDecoration(
                                                    // Add relevant hints or labels for better user experience
                                                    hintText: 'Enter your City',
                                                    border: InputBorder.none),
                                              )),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(
                                  height: 5,
                                ),
                                //location box
                                AnimatedContainer(
                                  duration: const Duration(
                                      milliseconds:
                                          600), // Adjust animation duration for smooth transition
                                  curve: Curves
                                      .easeInCirc, // Customize animation curve if needed
                                  padding: const EdgeInsets.all(8.0),
                                  height: searchbox == false ? 0 : 160,
                                  decoration: BoxDecoration(
                                      color: Colors.white,
                                      border: Border.all(color: Colors.orange),
                                      borderRadius: BorderRadius.circular(6.0)),
                                  child: ListView.builder(
                                    shrinkWrap: true,
                                    physics: const BouncingScrollPhysics(),
                                    itemCount: cityListModel
                                        .length, // Number of items in the list
                                    itemBuilder:
                                        (BuildContext context, int index) {
                                      // itemBuilder function returns a widget for each item in the list
                                      return SingleChildScrollView(
                                        child: InkWell(
                                          onTap: () {
                                            modalSetter(() {
                                              cityController.text =
                                                  cityListModel[index]
                                                      .place
                                                      .toString();
                                              longitude = cityListModel[index]
                                                  .longitude;
                                              latitude =
                                                  cityListModel[index].latitude;
                                              searchbox = false;
                                            });
                                          },
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  const Icon(
                                                      Icons.location_pin),
                                                  Text(
                                                    cityListModel[index].place,
                                                    style: const TextStyle(
                                                        color: Colors.black,
                                                        fontWeight:
                                                            FontWeight.bold),
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
                                const SizedBox(
                                  height: 10,
                                ),
                                // button

                                isLoading
                                    ? Container(
                                        padding: const EdgeInsets.all(4.0),
                                        height: 45,
                                        width: double.infinity,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(8.0),
                                          color: Colors.orange.shade400,
                                        ),
                                        child: const Center(
                                            child: CircularProgressIndicator(
                                          color: Colors.white,
                                        )))
                                    : InkWell(
                                        onTap: () {
                                          submitForm(modalSetter, checkUpdate);
                                        },
                                        child: Container(
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
                              ],
                            ),
                          ),
                        )
                      ],
                    ),
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
                              "${trackModelData?.order?.counsellingUser?.name}",
                              style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.orange),
                            ),
                            Text(
                              "${trackModelData?.order?.type}",
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
                                setReviewData();
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

  void setReviewData() async {
    final url = Uri.parse(AppConstants.baseUrl +
        AppConstants.setReviewDataUrl); // Replace with your API endpoint
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
        setState(() {
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

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getTrackData(widget.poojaId);
    _suggestionsController.text = options[0];
    userName =
        Provider.of<ProfileController>(Get.context!, listen: false).userNAME;
    userNumber = Provider.of<ProfileController>(Get.context!, listen: false)
        .userPHONE
        .substring(3);
    userToken =
        Provider.of<AuthController>(Get.context!, listen: false).getUserToken();
  }

  void getTrackData(String id) async {
    var res = await HttpService().getApi(AppConstants.getTrackDataUrl + id);
    print("api response $res");
    setState(() {
      trackModelData = trackDetailModelFromJson(jsonEncode(res));
      _maleValue = 0;
      _nameController.clear();
      _emailController.clear();
      _mobileController.clear();
      cityController.clear();
      _dateController.clear();
      _timeController.clear();
    });
    fetchInvoice(context, "${trackModelData!.order!.id}", userToken);
  }

  static String? counslingInvoicePath;
  static String? invoicePdfUrl;

  /// **Fetch  Invoice**
  Future<void> fetchInvoice(
      BuildContext context, String invoiceId, String userToken) async {
    String apiUrl =
        AppConstants.baseUrl + AppConstants.getCounsInvoiceUrl + invoiceId;

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
        if (counslingInvoicePath != null &&
            File(counslingInvoicePath!).existsSync()) {
          await File(counslingInvoicePath!).delete();
        }

        File file = File(filePath);
        await file.writeAsBytes(response.data);
        counslingInvoicePath = filePath; //  Save for open/share
      } else {}
    } catch (e) {
      print("Error: $e");
    }
  }

  /// **Open  Invoice**
  static Future<void> openInvoice(BuildContext context, String url) async {
    if (counslingInvoicePath == null ||
        !File(counslingInvoicePath!).existsSync()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("⚠ Invoice not found!")),
      );
      return;
    }

    Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (context) => InvoiceViewer(
          pdfPath: counslingInvoicePath!,
          invoiceUrl: url,
        ),
      ),
    );
  }

  /// **Share  Invoice**
  static Future<void> shareInvoice(BuildContext context) async {
    if (counslingInvoicePath != null &&
        File(counslingInvoicePath!).existsSync()) {
      //
      // var splashController = Provider.of<SplashController>(context, listen: false);
      // String playStoreUrl = splashController.configModel?.userAppVersionControl?.forAndroid?.link ??
      //     "https://play.google.com/store/apps/details?id=manal.mahakal.com";
      // String appStoreUrl = splashController.configModel?.userAppVersionControl?.forIos?.link ??
      //     "https://apps.apple.com/app/idyourappid";

      String shareUrl = '';
      shareUrl = "${AppConstants.baseUrl}/download";

      String shareText = "📅 **आपकी महूर्त बुकिंग कन्फर्म है!** 🎉\n\n"
          "शादी, गृह प्रवेश, वाहन खरीद या नया व्यापार...\n"
          "अब बुक करें शुभ महूर्त Mahakal.com ऐप पर 🙏\n\n"
          "🔹Download App Now: $shareUrl";

      await Share.shareXFiles([XFile(counslingInvoicePath!)], text: shareText);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("⚠ Please download the invoice first!")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return trackModelData?.order?.orderId == null
        ? MahakalLoadingData(onReload: () {})
        : Scaffold(
            floatingActionButtonLocation:
                FloatingActionButtonLocation.centerDocked,
            floatingActionButton: InkWell(
              onTap: () {
                Navigator.push(
                    context,
                    PageAnimationTransition(
                        page: CounsellingTrackingPage(
                          createdDate: "${trackModelData?.order?.createdAt}",
                          status: "${trackModelData?.order?.orderStatus}",
                          orderId: "${trackModelData?.order?.orderId}",
                        ),
                        pageAnimationType: RightToLeftTransition()));
              },
              child: Container(
                margin: const EdgeInsets.all(10),
                height: 45,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.0),
                  color: Theme.of(context).primaryColor,
                ),
                child: const Center(
                  child: Text(
                    "Track Order",
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ),
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
                  Text(formatCreatedAt("${trackModelData?.order?.createdAt}"),
                      style: const TextStyle(
                          fontSize: 18,
                          overflow: TextOverflow.ellipsis,
                          color: Colors.black))
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
                          Container(
                            // padding: EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: Colors.white,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(15),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
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
                                      Text("User Info",
                                          style: TextStyle(
                                              fontSize: 20,
                                              overflow: TextOverflow.ellipsis,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.deepOrange))
                                    ],
                                  ),
                                  const Divider(
                                    color: Colors.grey,
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.person,
                                        color: Colors.deepOrange.shade200,
                                      ),
                                      const SizedBox(
                                        width: 10,
                                      ),
                                      Text(
                                          trackModelData
                                                      ?.order?.customer?.name ==
                                                  null
                                              ? "Not-Available"
                                              : "${trackModelData?.order?.customer?.name}",
                                          style: const TextStyle(
                                              fontSize: 16,
                                              overflow: TextOverflow.ellipsis))
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.email_outlined,
                                        color: Colors.deepOrange.shade200,
                                      ),
                                      const SizedBox(
                                        width: 10,
                                      ),
                                      Text(
                                          "${trackModelData?.order?.customer?.email}",
                                          style: const TextStyle(
                                              fontSize: 16,
                                              overflow: TextOverflow.ellipsis))
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.phone,
                                        color: Colors.deepOrange.shade200,
                                      ),
                                      const SizedBox(
                                        width: 10,
                                      ),
                                      Text(
                                          "${trackModelData?.order?.customer?.phone}",
                                          style: const TextStyle(
                                              fontSize: 16,
                                              overflow: TextOverflow.ellipsis))
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 15,
                          ),
                          trackModelData?.order?.counsellingUser == null
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
                                            Text("Sankalp Details",
                                                style: TextStyle(
                                                    fontSize: 20,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.deepOrange)),
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
                                          "Data Not-Available",
                                          style: TextStyle(
                                              fontSize: 20,
                                              color: Colors.blueGrey),
                                        )),
                                        const SizedBox(
                                          height: 15,
                                        ),
                                        InkWell(
                                          onTap: () {
                                            // setState(() {
                                            //   _maleValue = trackModelData?.order?.counsellingUser?.gender == "male" ? 0 : 1;
                                            //   _nameController.text = "${trackModelData?.order?.counsellingUser?.name}";
                                            //   _emailController.text = "${trackModelData?.order?.customer?.email}";
                                            _mobileController.text = userNumber;
                                            //   cityController.text = "${trackModelData?.order?.counsellingUser?.city}";
                                            //   _dateController.text = "${trackModelData?.order?.counsellingUser?.dob}";
                                            //   _timeController.text = "${trackModelData?.order?.counsellingUser?.time}";
                                            // });
                                            showInfoBottomSheet("add");
                                          },
                                          child: Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 10,
                                                      vertical: 5),
                                              decoration: BoxDecoration(
                                                  color: Colors.deepOrange,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          8.0)),
                                              child: const Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
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
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          color: Colors.white,
                                                          fontWeight:
                                                              FontWeight.bold)),
                                                ],
                                              )),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
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
                                            Text("Sankalp Details",
                                                style: TextStyle(
                                                    fontSize: 20,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.deepOrange))
                                          ],
                                        ),
                                        const Divider(
                                          color: Colors.grey,
                                        ),
                                        const SizedBox(
                                          height: 10,
                                        ),
                                        Row(
                                          children: [
                                            Expanded(
                                                flex: 0,
                                                child: Icon(
                                                  Icons.groups,
                                                  color: Colors
                                                      .deepOrange.shade100,
                                                )),
                                            const SizedBox(
                                              width: 10,
                                            ),
                                            Expanded(
                                                flex: 1,
                                                child: Text(
                                                  "${trackModelData?.order?.counsellingUser?.name}",
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
                                              Icons.phone,
                                              color: Colors.deepOrange.shade100,
                                            ),
                                            const SizedBox(
                                              width: 10,
                                            ),
                                            Text(
                                                "${trackModelData?.order?.counsellingUser?.mobile}",
                                                style: const TextStyle(
                                                    fontSize: 16,
                                                    overflow:
                                                        TextOverflow.ellipsis))
                                          ],
                                        ),
                                        const SizedBox(
                                          height: 10,
                                        ),
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.location_on,
                                              color: Colors.deepOrange.shade100,
                                            ),
                                            const SizedBox(
                                              width: 10,
                                            ),
                                            SizedBox(
                                                width: 230,
                                                child: Text(
                                                  "${trackModelData?.order?.counsellingUser?.city}",
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
                                              color: Colors.deepOrange.shade100,
                                            ),
                                            const SizedBox(
                                              width: 10,
                                            ),
                                            Text(
                                                "${trackModelData?.order?.counsellingUser?.country}",
                                                style: const TextStyle(
                                                    fontSize: 16,
                                                    overflow:
                                                        TextOverflow.ellipsis)),
                                            // SizedBox(width: 120,),
                                            //
                                            // Icon(Icons.location_city,color: Colors.deepOrange.shade100,),
                                            // SizedBox(width: 10,),
                                            // Text("${trackModelData?.order?.pincode}",style: TextStyle(fontSize: 16,overflow: TextOverflow.ellipsis))
                                          ],
                                        ),
                                        const SizedBox(
                                          height: 10,
                                        ),
                                        trackModelData?.order?.counsellingUser
                                                    ?.isUpdate ==
                                                1
                                            ? const SizedBox.shrink()
                                            : InkWell(
                                                onTap: () {
                                                  setState(() {
                                                    _maleValue = trackModelData
                                                                ?.order
                                                                ?.counsellingUser
                                                                ?.gender ==
                                                            "male"
                                                        ? 0
                                                        : 1;
                                                    _nameController.text =
                                                        "${trackModelData?.order?.counsellingUser?.name}";
                                                    _emailController.text =
                                                        "${trackModelData?.order?.customer?.email}";
                                                    _mobileController.text =
                                                        "${trackModelData?.order?.counsellingUser?.mobile}";
                                                    cityController.text =
                                                        "${trackModelData?.order?.counsellingUser?.city}";
                                                    _dateController.text =
                                                        "${trackModelData?.order?.counsellingUser?.dob}";
                                                    _timeController.text =
                                                        "${trackModelData?.order?.counsellingUser?.time}";
                                                  });
                                                  showInfoBottomSheet("update");
                                                },
                                                child: Container(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 10,
                                                        vertical: 5),
                                                    decoration: BoxDecoration(
                                                        color:
                                                            Colors.deepOrange,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8.0)),
                                                    child: const Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        Text("Edit",
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
                                                  child: const Row(
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
                                                        ),
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
                                                  child: const Row(
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
                                                        ),
                                                      ),
                                                      //SizedBox(width: 5),
                                                      // Icon(Icons.arrow_forward_ios, color: Colors.white, size: 12), // Arrow icon
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                            // SizedBox(width: 8,),
                                            //  tourOrderData?.data!.refundStatus == 1
                                            //  ?
                                            //const SizedBox(),
                                            // :
                                            // InkWell(
                                            //   onTap: () {
                                            //     showRefundPolicyBottomSheet(context);
                                            //   },
                                            //   child: Container(
                                            //     padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                                            //     decoration: BoxDecoration(
                                            //       borderRadius: BorderRadius.circular(8),
                                            //       border: Border.all(color: Colors.red),
                                            //       color: Colors.white, // Background color
                                            //       boxShadow:  [
                                            //         BoxShadow(
                                            //           color: Colors.red.shade100,
                                            //           blurRadius: 4,
                                            //           spreadRadius: 2,
                                            //           offset: Offset(2, 2),
                                            //         ),
                                            //       ],
                                            //     ),
                                            //     child: const Row(
                                            //       mainAxisSize: MainAxisSize.min,
                                            //       children: [
                                            //         Icon(Icons.policy, color: Colors.black, size: 16), // Refund policy icon
                                            //         SizedBox(width: 4), // Spacing
                                            //         Text(
                                            //           "Refund Policy",
                                            //           style: TextStyle(
                                            //             color: Colors.red,
                                            //             fontSize: 14,
                                            //             fontWeight: FontWeight.w600,
                                            //           ),
                                            //         ),
                                            //         //SizedBox(width: 5),
                                            //         //Icon(Icons.arrow_forward_ios, color: Colors.white, size: 12), // Arrow icon
                                            //       ],
                                            //     ),
                                            //   ),
                                            // ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
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
                              Text("Your Consultancy",
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
                            child: trackModelData?.order?.services == null
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
                                                "${trackModelData?.order?.services?.thumbnail}",
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
                                              "${trackModelData?.order?.services?.name} ( ${trackModelData?.order?.services?.hiName} )",
                                              style: const TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                  overflow:
                                                      TextOverflow.ellipsis),
                                              maxLines: 2,
                                            ),
                                            Text.rich(
                                              TextSpan(children: [
                                                const TextSpan(
                                                    text: "Price : ",
                                                    style: TextStyle(
                                                        color: Colors.black,
                                                        fontSize: 16)),
                                                trackModelData?.order?.type ==
                                                        "counselling"
                                                    ? TextSpan(
                                                        text:
                                                            "₹${trackModelData?.order?.payAmount}",
                                                        style: const TextStyle(
                                                            color: Colors
                                                                .deepOrange,
                                                            fontSize: 18,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold))
                                                    : TextSpan(
                                                        text:
                                                            "₹${trackModelData?.order?.packagePrice}",
                                                        style: const TextStyle(
                                                            color: Colors
                                                                .deepOrange,
                                                            fontSize: 18,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold)),
                                                const TextSpan(
                                                    text: " (Tax include)",
                                                    style: TextStyle(
                                                        color: Colors.black,
                                                        fontSize: 12)),
                                              ]),
                                            ),
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
                                const Row(
                                  children: [
                                    Icon(
                                      Icons.article,
                                      color: Colors.blue,
                                    ),
                                    SizedBox(
                                      width: 10,
                                    ),
                                    Text("Payment info",
                                        style: TextStyle(
                                            fontSize: 20,
                                            overflow: TextOverflow.ellipsis,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.blue)),
                                  ],
                                ),
                                const Divider(
                                  color: Colors.grey,
                                ),
                                const SizedBox(
                                  height: 15,
                                ),
                                Row(
                                  children: [
                                    const Text("Subtotal",
                                        style: TextStyle(
                                            fontSize: 18,
                                            overflow: TextOverflow.ellipsis,
                                            color: Colors.green)),
                                    const Spacer(),
                                    Text(
                                        "₹${trackModelData?.order?.payAmount}.0",
                                        style: const TextStyle(
                                            fontSize: 18,
                                            overflow: TextOverflow.ellipsis,
                                            color: Colors.green)),
                                  ],
                                ),
                                const SizedBox(
                                  height: 5,
                                ),
                                Row(
                                  children: [
                                    const Text("Coupon discount",
                                        style: TextStyle(
                                            fontSize: 18,
                                            overflow: TextOverflow.ellipsis,
                                            color: Colors.black,
                                            fontWeight: FontWeight.bold)),
                                    const Spacer(),
                                    Text(
                                        "- ₹${trackModelData?.order?.couponAmount ?? '0.0'}",
                                        style: const TextStyle(
                                            fontSize: 18,
                                            overflow: TextOverflow.ellipsis,
                                            color: Colors.red)),
                                  ],
                                ),
                                const Divider(
                                  color: Colors.grey,
                                ),
                                Row(
                                  children: [
                                    const Text("Amount Paid",
                                        style: TextStyle(
                                            fontSize: 18,
                                            overflow: TextOverflow.ellipsis,
                                            color: Colors.black,
                                            fontWeight: FontWeight.bold)),
                                    const Spacer(),
                                    Text(
                                        "₹${trackModelData?.order?.payAmount}.0",
                                        style: const TextStyle(
                                            fontSize: 18,
                                            overflow: TextOverflow.ellipsis)),
                                  ],
                                ),
                              ],
                            ),
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

                          trackModelData?.order?.orderStatus == "Completed"
                              ? Column(
                                  children: [
                                    const SizedBox(
                                      height: 15,
                                    ),
                                    trackModelData?.isReview == 1
                                        ? Container(
                                            height: 50,
                                            width: double.infinity,
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 5, horizontal: 10),
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              border: Border.all(
                                                  color: Colors.grey.shade400,
                                                  width: 2),
                                            ),
                                            child: const Row(children: [
                                              Text(
                                                "Review added successfully ✨",
                                                style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w400,
                                                    color: Colors.grey),
                                              ),
                                              Spacer(),
                                              Center(
                                                  child: Icon(
                                                CupertinoIcons
                                                    .checkmark_circle_fill,
                                                color: Colors.green,
                                              )),
                                            ]),
                                          )
                                        : InkWell(
                                            onTap: () {
                                              showFeedbackBottomSheet();
                                            },
                                            child: Container(
                                              height: 50,
                                              width: double.infinity,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 5,
                                                      horizontal: 10),
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(100),
                                                border: Border.all(
                                                    color: Colors.grey.shade400,
                                                    width: 2),
                                              ),
                                              child: const Row(children: [
                                                Text(
                                                  "Write Your Experience",
                                                  style: TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.w400),
                                                ),
                                                Spacer(),
                                                Center(
                                                    child: Icon(
                                                  CupertinoIcons
                                                      .arrow_right_circle_fill,
                                                  color: Colors.blue,
                                                )),
                                              ]),
                                            ),
                                          ),
                                  ],
                                )
                              : const SizedBox.shrink(),

                          const SizedBox(
                            height: 25,
                          ),
                          const Text(
                              "For any assistance or support with consultancy bookings, please feel free to contact us!",
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
                              child: const Text("Support Center",
                                  style: TextStyle(
                                      fontSize: 16,
                                      overflow: TextOverflow.ellipsis,
                                      color: Colors.deepOrange))),

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
