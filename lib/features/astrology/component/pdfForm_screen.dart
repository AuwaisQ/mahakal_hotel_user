import 'dart:convert';
import 'dart:math';

import 'package:country_picker/country_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import '../../../data/datasource/remote/http/httpClient.dart';
import '../../../main.dart';
import '../../../utill/app_constants.dart';
import '../../../utill/completed_order_dialog.dart';
import '../../../utill/flutter_toast_helper.dart';
import '../../../utill/razorpay_screen.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../custom_bottom_bar/bottomBar.dart';
import '../../explore/payment_process_screen.dart';
import '../../maha_bhandar/model/city_model.dart';
import '../../profile/controllers/profile_contrroller.dart';

class PdfFormView extends StatefulWidget {
  final String pageCount;
  final String amount;
  final String pdfDetail;
  final String birthJournalId;
  final String leadId;
  const PdfFormView(
      {super.key,
      required this.pageCount,
      required this.amount,
      required this.pdfDetail,
      required this.birthJournalId,
      required this.leadId});

  @override
  State<PdfFormView> createState() => _PdfFormViewState();
}

class _PdfFormViewState extends State<PdfFormView> {
  final kundaliKey = GlobalKey<FormState>();
  final List<String> chartOptions = ['South Chart', 'Nothern Chart'];
  final List<String> langOptions = [
    'Hindi',
    'English',
    'Bengali',
    "Marathi",
    "Kannada",
    "Malayalam",
    "Telogu",
    "Tamil"
  ];
  double walletPay = 0.0;
  double walletMinusAmount = 0.0;
  double finalAmount = 0.0;
  int screenIndex = 0;
  int _maleValue = 1;
  String timeHour = "";
  String timeMinute = "";
  String dateDay = "";
  String dateMonth = "";
  String dateYear = "";
  String latiTude = "";
  String longiTude = "";
  String kundliLang = "";
  String? _selecteChart;
  String? _selecteLang;
  String? selectecountryId;
  bool isLoading = false;

  //controllers
  String userToken = "";
  String userId = "";
  String userNAME = "";
  String userEMAIL = "";
  String userPHONE = "";

  final razorpayService = RazorpayPaymentService();
  TextEditingController _nameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();
  final TextEditingController countryController = TextEditingController();

  List<CityPickerModel> cityListModel = <CityPickerModel>[];

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

  //Serach box
  bool searchbox = false;
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

  // country picker api
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

  Future<void> formData(String payId) async {
    final url = Uri.parse(AppConstants.baseUrl +
        AppConstants.createBirthPdfUrl); // Replace with your API endpoint
    String gender = _maleValue == 1 ? "male" : "female";
    final Map<String, dynamic> data = {
      "user_id": userId,
      "leads_id": widget.leadId,
      "wallet_type": 0,
      "transaction_id": payId,
      "birth_journal_id": widget.birthJournalId,
      "name": _nameController.text,
      "email": _emailController.text,
      "gender": gender,
      "phone_no": userPHONE,
      "bod": "$dateYear-$dateMonth-$dateDay",
      "time": "$timeHour:$timeMinute:00",
      "country_id": "101",
      "state": "${countryController.text}, ${_selectedCountry.name}",
      "lat": latiTude,
      "log": longiTude,
      "language": kundliLang,
      "tzone": "5.5",
      "chart_style": _selecteChart,
      "amount": widget.amount
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
        Navigator.of(context).pushReplacement(CupertinoPageRoute(
            builder: (BuildContext context) => const BottomBar(pageIndex: 0)));
        showDialog(
          context: context,
          builder: (context) => bookingSuccessDialog(
            context: context,
            tabIndex: 7,
            title: 'Kundali Generated!',
            message:
                'Your kundali has been successfully generated. You can now download the PDF from your order details below.',
          ),
          barrierDismissible: true,
        );
        print('Data posted successfully: ${response.body}');
      } else {
        // Handle error response
        print('Failed to post data: ${response.statusCode}');
      }
    } catch (error) {
      print('Error posting data: $error');
    }
  }
  // void formData() async {
  //   String gender = _maleValue == 1 ? "male" : _maleValue == 2 ? "female" : "others";
  //
  //   // Create the payload data for the API call
  //   Map<String, dynamic> payload = {
  //     "user_id": "2",
  //     "birth_journal_id": "${widget.birthJournalId}",
  //     "name": "${_nameController.text}",
  //     "email": "${_emailController.text}",
  //     "gender": "$gender",
  //     "phone_no": "9843759895",
  //     "bod": "$dateYear-$dateMonth-$dateDay",
  //     "time": "$timeHour:$timeMinute:00",
  //     "country_id": "101",
  //     "state": "${countryController.text}, ${_selectedCountry.name}",
  //     "lat": "$latiTude",
  //     "log": "$longiTude",
  //     "language": "$_selecteLang",
  //     "tzone": "5.5",
  //     "chart_style": "$_selecteChart",
  //     "amount": "${widget.amount}"
  //   };
  //
  //   try {
  //     var response = await HttpService().postApi("/api/v1/birth_journal/createbirthpdf", payload);
  //     print("Response: $response");
  //   } catch (e) {
  //     print("Error: $e");
  //   }
  //
  //   // Uncomment if you want to update the UI after the response
  //   // setState(() {
  //   //   screenIndex = 1;
  //   // });
  // }

  void walletAmount() async {
    var res = await HttpService().getApi(AppConstants.poojaWalletUrl + userId);
    print(res);
    if (res["success"]) {
      setState(() {
        walletPay = double.parse(res["wallet_balance"].toString());
        // Calculate walletMinusAmount and finalAmount
        walletMinusAmount = max(walletPay - double.parse(widget.amount), 0);
        finalAmount = (walletPay - double.parse(widget.amount)).abs();
        print(walletMinusAmount);
        print(finalAmount);
      });
    }
  }

  void _submitForm() {
    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    print("Submit button pressed");
    if (_nameController.text.isEmpty ||
        _dateController.text.isEmpty ||
        _emailController.text.isEmpty ||
        !_emailController.text.contains('@') ||
        !emailRegex.hasMatch(_emailController.text) ||
        _timeController.text.isEmpty ||
        countryController.text.isEmpty ||
        _nameController.text.trim().isEmpty ||
        _nameController.text.length < 4) {
      kundaliKey.currentState!.validate();
      // For general toast
      ToastHelper.showToast(message: "Form fields required!");
    } else {
      // Navigator.push(
      //   context,
      //   CupertinoPageRoute(
      //       builder: (context) => KundliDetails(
      //         name: _nameController.text,
      //         day: dateDay,
      //         month: dateMonth,
      //         year: dateYear,
      //         hour: "${timeHour.toString()}",
      //         mint: "${timeMinute.toString()}",
      //         country: _selectedCountry.name,
      //         city: countryController.text,
      //         lati: latiTude,
      //         longi: longiTude,
      //       )),
      // );
      setState(() {
        screenIndex = 1;
      });
    }
    String gender = _maleValue == 1
        ? "male"
        : _maleValue == 2
            ? "female"
            : "others";
    print('id: ${widget.birthJournalId}');
    print('Lead id: ${widget.leadId}');
    print('Name: ${_nameController.text.trim()}');
    print('gender: $gender');
    print('Date of Birth: $dateDay/$dateMonth/$dateYear');
    print('Time: $timeHour:$timeMinute');
    print('chart: $_selecteChart');
    print('lang: $_selecteLang');
    print('state: ${_selectedCountry.name}');
    print('country: ${countryController.text}');
    print('late: $latiTude');
    print('long: $longiTude');
    print('amount: ${widget.amount}');
  }

  @override
  void initState() {
    userId = Provider.of<ProfileController>(Get.context!, listen: false).userID;
    userNAME =
        Provider.of<ProfileController>(Get.context!, listen: false).userNAME;
    userEMAIL =
        Provider.of<ProfileController>(Get.context!, listen: false).userEMAIL;
    userPHONE =
        Provider.of<ProfileController>(Get.context!, listen: false).userPHONE;
    userToken =
        Provider.of<AuthController>(Get.context!, listen: false).getUserToken();
    _nameController = TextEditingController(text: userNAME);
    _emailController = TextEditingController(text: userEMAIL);

    print(">>>> token order $userId $userToken");
    walletAmount();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? const MahakalPaymentProcessing()
        : Scaffold(
            floatingActionButtonLocation:
                FloatingActionButtonLocation.centerFloat,
            floatingActionButton: screenIndex == 0
                ? InkWell(
                    onTap: () {
                      _submitForm();
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 10),
                      height: 45,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8.0),
                          color: Colors.orange),
                      child: const Center(
                        child: Text(
                          "Next",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ),
                    ),
                  )
                : screenIndex == 1
                    ? walletMinusAmount == 0
                        ? GestureDetector(
                            onTap: () {
                              setState(() {
                                isLoading = true;
                              });
                              razorpayService.openCheckout(
                                amount: finalAmount, // ₹100
                                razorpayKey: AppConstants.razorpayLive,
                                onSuccess: (response) {
                                  print(
                                      "Payment Successful TXN: ${response.paymentId}");
                                  formData("${response.paymentId}");
                                },
                                onFailure: (response) {},
                                onExternalWallet: (response) {
                                  print("Wallet: ${response.walletName}");
                                },
                                description: 'Kundli PDF',
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 2, horizontal: 10),
                              margin: const EdgeInsets.all(10),
                              height: 60,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  color: Colors.orange),
                              child: Row(
                                children: [
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "₹${widget.amount}.0",
                                        style: const TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                            fontFamily: 'Roboto',
                                            color: Colors.white),
                                      ),
                                      const Text(
                                        "Kundali PDF",
                                        style: TextStyle(
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
                          )
                        : GestureDetector(
                            onTap: () {
                              isLoading ? null : formData("pay_wallet");
                              setState(() {
                                isLoading = true;
                              });
                            },
                            child: isLoading
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
                                : Container(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 2, horizontal: 10),
                                    margin: const EdgeInsets.all(10),
                                    height: 60,
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(8),
                                        color: Colors.orange),
                                    child: const Row(
                                      children: [
                                        Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "Via Wallet",
                                              style: TextStyle(
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.bold,
                                                  fontFamily: 'Roboto',
                                                  color: Colors.white),
                                            ),
                                            Text(
                                              "Kundali PDF",
                                              style: TextStyle(
                                                  fontSize: 18,
                                                  fontFamily: 'Roboto',
                                                  color: Colors.white),
                                            ),
                                          ],
                                        ),
                                        Spacer(),
                                        Text(
                                          "Pay",
                                          style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                              fontFamily: 'Roboto',
                                              color: Colors.white),
                                        ),
                                        SizedBox(
                                          width: 5,
                                        ),
                                        Icon(
                                          Icons.arrow_circle_right_outlined,
                                          size: 30,
                                          color: Colors.white,
                                        )
                                      ],
                                    ),
                                  ),
                          )
                    : const SizedBox(),
            appBar: AppBar(
              title: Text(
                "PDF - ${widget.pageCount} Pages",
                style: const TextStyle(color: Colors.orange),
              ),
              centerTitle: true,
            ),
            body: SafeArea(
                child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: SingleChildScrollView(
                  child: Column(
                children: [
                  screenIndex == 0
                      ? firstWidget()
                      : screenIndex == 1
                          ? secondWidget()
                          : const SizedBox(),
                ],
              )),
            )));
  }

  Widget firstWidget() {
    return SingleChildScrollView(
      child: Form(
        key: kundaliKey,
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x40000000),
                    blurRadius: 4.0,
                    offset: Offset(0, 4), // X, Y
                  ),
                ],
                borderRadius: BorderRadius.circular(10),
              ),
              padding:
                  const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    // name
                    const Text('Name',
                        style: TextStyle(
                            fontSize: 16,
                            color: Colors.black,
                            fontFamily: 'Roboto',
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 3),
                    TextFormField(
                      validator: (val) {
                        if (val!.isEmpty) {
                          return "name is required";
                        }
                        return null;
                      },
                      cursorColor: Colors.orange,
                      controller: _nameController,
                      style: const TextStyle(fontFamily: 'Roboto-Regular'),
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 10.0, horizontal: 15.0),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide:
                              const BorderSide(color: Colors.orange, width: 1),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide:
                              const BorderSide(color: Colors.orange, width: 1),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide:
                              const BorderSide(color: Colors.orange, width: 1),
                        ),
                        suffixIcon: const Icon(Icons.person_outline,
                            color: Colors.grey, size: 30),
                      ),
                    ),
                    const SizedBox(height: 10),

                    // email
                    const Text('Email',
                        style: TextStyle(
                            fontSize: 16,
                            color: Colors.black,
                            fontFamily: 'Roboto',
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 3),
                    TextFormField(
                      validator: (val) {
                        if (val == null || val.isEmpty) {
                          return "Email is required";
                        }
                        // Regular expression for basic email validation
                        final emailRegex =
                            RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
                        if (!emailRegex.hasMatch(val)) {
                          return "Enter a valid email";
                        }
                        return null;
                      },
                      cursorColor: Colors.orange,
                      controller: _emailController,
                      style: const TextStyle(fontFamily: 'Roboto-Regular'),
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 10.0, horizontal: 15.0),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide:
                              const BorderSide(color: Colors.orange, width: 1),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide:
                              const BorderSide(color: Colors.orange, width: 1),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide:
                              const BorderSide(color: Colors.orange, width: 1),
                        ),
                        suffixIcon: const Icon(Icons.mail,
                            color: Colors.grey, size: 30),
                      ),
                    ),
                    const SizedBox(height: 10),

                    const Text(
                      "Gender",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
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
                            setState(() {
                              _maleValue = value!; // Cast as int for safety
                            });
                          },
                        ),
                        const Row(
                          children: [
                            Text('Male'),
                            Icon(
                              Icons.male,
                              size: 15,
                            )
                          ],
                        ),
                        Radio(
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                          value: 2, // Value assigned to "Female"
                          activeColor: Colors.orange,
                          groupValue: _maleValue,
                          onChanged: (value) {
                            setState(() {
                              _maleValue = value!; // Cast as int for safety
                            });
                          },
                        ),
                        const Row(
                          children: [
                            Text('Female'),
                            Icon(
                              Icons.female,
                              size: 15,
                            )
                          ],
                        ),
                        Radio(
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                          value: 3, // Value assigned to "Female"
                          activeColor: Colors.orange,
                          groupValue: _maleValue,
                          onChanged: (value) {
                            setState(() {
                              _maleValue = value!; // Cast as int for safety
                            });
                          },
                        ),
                        const Row(
                          children: [
                            Text('Others'),
                            Icon(
                              Icons.person_2_outlined,
                              size: 15,
                            )
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // Birth Date
                    const Text('Birth Date',
                        style: TextStyle(
                            fontSize: 16,
                            color: Colors.black,
                            fontFamily: 'Roboto',
                            fontWeight: FontWeight.bold)),
                    Container(
                      margin: const EdgeInsets.only(top: 2, bottom: 10),
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.orange),
                      ),
                      child: TextButton(
                        onPressed: () async {
                          DateTime? pickedDate = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime(1900),
                            lastDate: DateTime.now(),
                            builder: (BuildContext context, Widget? child) {
                              return Theme(
                                data: ThemeData.light().copyWith(
                                  colorScheme: const ColorScheme.light(
                                    primary: Colors.white,
                                    onPrimary: Colors.orange,
                                    surface: Color(0xFFFFF7EC),
                                    onSurface: Colors.orange,
                                  ),
                                  textButtonTheme: TextButtonThemeData(
                                    style: TextButton.styleFrom(
                                      foregroundColor: Colors.orange,
                                      backgroundColor: Colors.white,
                                    ),
                                  ),
                                  dialogTheme: const DialogThemeData(
                                      backgroundColor: Color(0xFFFFF7EC)),
                                ),
                                child: child!,
                              );
                            },
                          );
                          if (pickedDate != null) {
                            setState(() {
                              _dateController.text =
                                  DateFormat('dd/MM/yyyy').format(pickedDate);
                              dateDay = DateFormat('dd').format(pickedDate);
                              dateMonth = DateFormat('MM').format(pickedDate);
                              dateYear = DateFormat('yyyy').format(pickedDate);
                            });
                          }
                        },
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 15.0),
                          alignment: Alignment.centerLeft,
                          backgroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _dateController.text,
                              style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.black,
                                  fontFamily: 'Roboto-Regular'),
                            ),
                            const Icon(Icons.calendar_month_outlined,
                                color: Colors.grey, size: 30),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Birth Timing
                    const Text('Birth Timing',
                        style: TextStyle(
                            fontSize: 16,
                            color: Colors.black,
                            fontFamily: 'Roboto',
                            fontWeight: FontWeight.bold)),
                    Container(
                      margin: const EdgeInsets.only(top: 2, bottom: 10),
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.orange),
                      ),
                      child: TextButton(
                        onPressed: () async {
                          TimeOfDay? pickedTime = await showTimePicker(
                            initialTime: TimeOfDay.now(),
                            context: context,
                            builder: (BuildContext context, Widget? child) {
                              return Theme(
                                data: ThemeData.light().copyWith(
                                  timePickerTheme: const TimePickerThemeData(
                                    dialHandColor: Colors.grey,
                                    dialTextColor: Colors.orange,
                                    dialBackgroundColor: Colors.white,
                                    dayPeriodColor: Colors.white,
                                    dayPeriodTextColor: Colors.orange,
                                    backgroundColor: Color(0xFFFFF7EC),
                                    hourMinuteTextColor: Colors.orange,
                                    hourMinuteColor: Colors.white,
                                    inputDecorationTheme: InputDecorationTheme(
                                      border: InputBorder.none,
                                      filled: true,
                                      fillColor: Colors.white,
                                      hintStyle:
                                          TextStyle(color: Colors.orange),
                                      labelStyle:
                                          TextStyle(color: Colors.orange),
                                    ),
                                  ),
                                  textButtonTheme: TextButtonThemeData(
                                    style: TextButton.styleFrom(
                                      foregroundColor: Colors.orange,
                                      backgroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10)),
                                    ),
                                  ),
                                  dialogTheme: const DialogThemeData(
                                      backgroundColor: Colors.white),
                                ),
                                child: child!,
                              );
                            },
                          );
                          if (pickedTime != null) {
                            setState(() {
                              _timeController.text = pickedTime.format(context);
                              timeHour =
                                  pickedTime.hour.toString().padLeft(2, "0");
                              timeMinute =
                                  pickedTime.minute.toString().padLeft(2, "0");
                            });
                          }
                        },
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 15.0),
                          alignment: Alignment.centerLeft,
                          backgroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _timeController.text,
                              style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.black,
                                  fontFamily: 'Roboto-Regular'),
                            ),
                            const Icon(Icons.timelapse_outlined,
                                color: Colors.grey, size: 30),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),

                    // // chart
                    const Text('Select Chart',
                        style: TextStyle(
                            fontSize: 16,
                            color: Colors.black,
                            fontFamily: 'Roboto',
                            fontWeight: FontWeight.bold)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      margin: const EdgeInsets.only(top: 2, bottom: 10),
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.orange),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selecteChart,
                          hint: const Text('Select Chart'),
                          items: chartOptions.map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            setState(() {
                              _selecteChart = newValue;
                            });
                          },
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 10.0,
                    ),

                    // // language
                    const Text('Select Language',
                        style: TextStyle(
                            fontSize: 16,
                            color: Colors.black,
                            fontFamily: 'Roboto',
                            fontWeight: FontWeight.bold)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      margin: const EdgeInsets.only(top: 2, bottom: 10),
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.orange),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selecteLang,
                          hint: const Text('Select Language'),
                          items: langOptions.map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            setState(() {
                              _selecteLang = newValue;
                              kundliLang =
                                  newValue!.substring(0, 2).toLowerCase();
                              print("kundali lang: $kundliLang");
                            });
                          },
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 10.0,
                    ),

                    // country
                    Row(
                      children: [
                        // location
                        Expanded(
                          flex: 1,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Country',
                                  style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.black,
                                      fontFamily: 'Roboto',
                                      fontWeight: FontWeight.bold)),
                              InkWell(
                                onTap: () {
                                  showCountryPicker(
                                    context: context,
                                    showPhoneCode:
                                        false, // optional. Shows phone code before the country name.
                                    onSelect: (Country country) {
                                      setState(() {
                                        _selectedCountry = country;
                                      });
                                    },
                                  );
                                },
                                child: Container(
                                  height: 50,
                                  margin: const EdgeInsets.only(top: 2),
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: Colors.orange),
                                  ),
                                  child: Center(
                                    child: Text(
                                      _selectedCountry != null
                                          ? _selectedCountry.flagEmoji
                                          : 'No country selected',
                                      style: const TextStyle(fontSize: 20),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(
                          width: 6.0,
                        ),
                        // country
                        Expanded(
                          flex: 3,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('City',
                                  style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.black,
                                      fontFamily: 'Roboto',
                                      fontWeight: FontWeight.bold)),
                              Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8.0),
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: Colors.orange),
                                  ),
                                  child: TextFormField(
                                    controller: countryController,
                                    onChanged: (value) => updateValue(value),
                                    decoration: const InputDecoration(
                                        // Add relevant hints or labels for better user experience
                                        hintText: 'Search City',
                                        hintStyle:
                                            TextStyle(color: Colors.grey),
                                        border: InputBorder.none),
                                  )),
                            ],
                          ),
                        ),
                      ],
                    ),
                    // location
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
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(6.0)),
                      child: ListView.builder(
                        shrinkWrap: true,
                        physics: const BouncingScrollPhysics(),
                        itemCount:
                            cityListModel.length, // Number of items in the list
                        itemBuilder: (BuildContext context, int index) {
                          // itemBuilder function returns a widget for each item in the list
                          return SingleChildScrollView(
                            child: InkWell(
                              onTap: () {
                                setState(() {
                                  latiTude =
                                      cityListModel[index].latitude.toString();
                                  longiTude =
                                      cityListModel[index].longitude.toString();
                                  countryController.text =
                                      cityListModel[index].place.toString();
                                  searchbox = false;
                                });
                              },
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(Icons.location_on_outlined),
                                      Expanded(
                                        child: Text(
                                          cityListModel[index].place,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                              color: Colors.black),
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
              height: 50,
            ),
            // button
            // ElevatedButton(
            //   onPressed: _submitForm,
            //   style: ElevatedButton.styleFrom(
            //     foregroundColor: Colors.white,
            //     backgroundColor: Colors.black,
            //     minimumSize: const Size(double.infinity, 50),
            //     shape: RoundedRectangleBorder(
            //       borderRadius: BorderRadius.circular(10),
            //     ),
            //   ),
            //   child: const Text(
            //     'Continue',
            //     style: TextStyle(
            //         fontSize: 18,
            //         fontFamily: 'Roboto',
            //         letterSpacing: 0.28),
            //   ),
            // ),
          ],
        ),
      ),
    );
  }

  Widget secondWidget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
            child: Image.asset(
          "assets/images/kundli_banner.jpg",
          height: 250,
        )),
        Html(data: widget.pdfDetail),
        const SizedBox(
          height: 10,
        ),
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.0),
              color: Colors.white,
              border: Border.all(color: Colors.grey.shade300, width: 2)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Buy Now",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Colors.orange),
              ),
              const SizedBox(
                height: 10,
              ),
              const Row(
                children: [
                  Text(
                    "Special Discount",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Spacer(),
                  Text(
                    "₹0.0",
                    style: TextStyle(
                        color: Colors.red,
                        decoration: TextDecoration.lineThrough),
                  ),
                ],
              ),
              const Divider(),
              Row(
                children: [
                  RichText(
                    text: TextSpan(
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w400,
                        fontFamily: 'Roboto',
                        color: Colors.black, // Default color for all text
                      ),
                      children: [
                        const TextSpan(text: "Wallet balance ("),
                        TextSpan(
                          text: "₹$walletMinusAmount.0",
                          style: const TextStyle(
                            color: Colors.green, // Custom color for walletPay
                            fontWeight:
                                FontWeight.bold, // Optional, for emphasis
                          ),
                        ),
                        const TextSpan(text: ")"),
                      ],
                    ),
                  ),
                  const Spacer(),
                ],
              ),
              Row(
                children: [
                  const Text(
                    "Amount Paid (via Wallet)",
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w400,
                        fontFamily: 'Roboto',
                        color: Colors.black),
                  ),
                  const Spacer(),
                  Text(
                    "- ₹${widget.amount}.0",
                    style: const TextStyle(
                        fontSize: 18, fontFamily: 'Roboto', color: Colors.red),
                  )
                ],
              ),
              const Divider(),
              Row(
                children: [
                  const Text(
                    "PDF Total",
                    style: TextStyle(),
                  ),
                  const Spacer(),
                  walletMinusAmount == 0
                      ? Text(
                          "₹$finalAmount.0",
                          style: const TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                              fontSize: 18),
                        )
                      : const Text(
                          "₹0.0",
                          style: TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                              fontSize: 18),
                        ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(
          height: 100,
        ),
      ],
    );
  }
}
