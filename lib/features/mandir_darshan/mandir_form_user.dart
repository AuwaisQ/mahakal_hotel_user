import 'dart:convert';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import '../../utill/app_constants.dart';
import '../../utill/completed_order_dialog.dart';
import '../../utill/flutter_toast_helper.dart';
import '../../utill/razorpay_screen.dart';
import '../custom_bottom_bar/bottomBar.dart';
import '../explore/payment_process_screen.dart';
import 'model/mandir_user_form_model.dart';
import '../../data/datasource/remote/http/httpClient.dart';

class TempleBookingScreen extends StatefulWidget {
  final String id;
  const TempleBookingScreen({super.key, required this.id});

  @override
  State<TempleBookingScreen> createState() => _TempleBookingScreenState();
}

class _TempleBookingScreenState extends State<TempleBookingScreen> {
  UserFormModel? modelData;

  List<Map<String, dynamic>> savedForms = [];
  List<Map<String, dynamic>> apiForms = [];
  List<Slote> timeSlotsList = <Slote>[];
  List<UserAadhar> memberList = [];
  // Global variable add karein class ke top par
  List<FormMemberModel> savedMemberList = [];

  // Yajman Info
  bool isNri = false;
  bool isLoading = true;
  bool isRotating = false;
  TextEditingController aadhaarController = TextEditingController();
  TextEditingController passportController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController mobileQTYController = TextEditingController();
  TextEditingController luggageController = TextEditingController();
  TextEditingController phoneController2 = TextEditingController();
  TextEditingController aadharController2 = TextEditingController();
  String fullPhone = '';
  PageController pageController = PageController();
  final razorpayService = RazorpayPaymentService();
  int currentPage = 0;
  bool formComplete = false;
  bool isverify = false;

  Bhojan? selectedVariant;
  Purohit? selectedPurohit;
  String? selectedDate;
  Slote? selectedTimeSlot;

  String? selectedService;
  String? selectedPackageId;

  @override
  void initState() {
    super.initState();
    pageController = PageController(initialPage: 0);
    getTempleData(widget.id);
  }

  void showOtpVerificationDialog(BuildContext context, String requestId) {
    final otpController = TextEditingController();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        elevation: 8,
        child: StatefulBuilder(
            builder: (BuildContext context, StateSetter modalSetter) {
              return Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header with icon
                    Stack(
                      children: [
                        Align(
                          alignment: Alignment.center,
                          child: Icon(
                            Icons.verified_user_rounded,
                            size: 48,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                        Positioned(
                          right: 0,
                          child: IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Title
                    Text(
                      'OTP Verification',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Subtitle
                    Text(
                      'Enter the 6-digit code sent to your mobile',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withOpacity(0.7),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // OTP Input Field
                    PinCodeTextField(
                      controller: otpController,
                      length: 6,
                      appContext: context,
                      animationType: AnimationType.scale,
                      pinTheme: PinTheme(
                        shape: PinCodeFieldShape.underline,
                        borderRadius: BorderRadius.circular(4),
                        fieldHeight: 50,
                        fieldWidth: 40,
                        activeFillColor: Theme.of(context).colorScheme.surface,
                        activeColor: Theme.of(context).primaryColor,
                        selectedColor: Theme.of(context).primaryColor,
                        inactiveColor: Colors.grey.shade300,
                        selectedFillColor: Theme.of(context).colorScheme.surface,
                        inactiveFillColor: Theme.of(context).colorScheme.surface,
                      ),
                      textStyle: Theme.of(context).textTheme.headlineSmall,
                      backgroundColor: Colors.transparent,
                      enableActiveFill: true,
                      keyboardType: TextInputType.number,
                      animationDuration: const Duration(milliseconds: 200),
                      onChanged: (value) {},
                      beforeTextPaste: (text) => text?.length == 6,
                    ),

                    const SizedBox(height: 24),

                    // Resend and Verify Buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton(
                          onPressed: () {
                            // Resend OTP logic
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('OTP resent successfully')),
                            );
                            getAadhar(aadharController2.text, context, modalSetter);
                          },
                          child: Text(
                            'Resend OTP',
                            style: TextStyle(
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: otpController.text.length == 6
                              ? () {
                            modalSetter(() {
                              isverify = true;
                            });
                            verifyOtp(otpController.text, requestId,
                                modalSetter, context);
                          }
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).primaryColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                          ),
                          child: isverify
                              ? const CircularProgressIndicator(
                            color: Colors.white,
                          )
                              : const Text(
                            'Verify',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }),
      ),
    );
  }


  void verifyOtp(String otp, String id, StateSetter modalSetter,
      BuildContext context) async {
    var res = await HttpService().postApi(
        AppConstants.sendAadharOtpVerify, {'otp': otp, 'request_id': id});
    print('Api response data verify otp $res');
    if (res['status'] == 1) {
      String name = res['data']['data']['full_name'];
      String aadhar = res['data']['data']['aadhaar_number'];
      Navigator.pop(context);
      setState(() {
        memberList.add(UserAadhar(
            phone: phoneController2.text.trim(),
            aadhar: aadhar,
            name: name
        ));
      });
      Fluttertoast.showToast(
          msg: 'Success',
          backgroundColor: Colors.green,
          textColor: Colors.white);
      phoneController2.clear();
      aadharController2.clear();
      modalSetter(() {
        isverify = false;
      });
    } else {
      modalSetter(() {
        isverify = false;
      });
      Fluttertoast.showToast(
          msg: 'Invalid request',
          backgroundColor: Colors.red,
          textColor: Colors.white);
    }
  }

  void getAadhar(String aadharNumber, BuildContext context,
      StateSetter modalSetter) async {
    var res = await HttpService().postApi(AppConstants.sendAadharOtp, {
      'aadhaar_number': aadharNumber,
    });
    print('Api response data place order $res');
    if (res['status'] == 1) {
      Navigator.pop(context);
      String id = res['data']['request_id'].toString();
      Fluttertoast.showToast(
          msg: 'Send OTP',
          backgroundColor: Colors.green,
          textColor: Colors.white);
      showOtpVerificationDialog(context, id);
    }
    if (res['status'] == 2) {
      // Navigator.pop(context);
      String name = res['data']['name'];
      String aadhar = res['data']['aadhar'].toString();
      setState(() {
        memberList.add(UserAadhar(
            phone: phoneController2.text.trim(),
            aadhar: aadhar,
            name: name
        ));
      });
      Navigator.pop(context);
      Fluttertoast.showToast(
          msg: 'Success',
          backgroundColor: Colors.green,
          textColor: Colors.white);
      phoneController2.clear();
      aadharController2.clear();
      modalSetter(() {
        isverify = false;
      });
    }
    if (res['status'] == 0) {
      Fluttertoast.showToast(
          msg: 'Invalid Aadhaar Number',
          backgroundColor: Colors.red,
          textColor: Colors.white);
      modalSetter(() {
        isverify = false;
      });
    }
    print("${res['data']['message']} ${res['status']} Print status");
  }

  void updateLead(Map<String, dynamic> data) async{
    var res = await HttpService().postApi('/api/v1/temple/puja-get-booking-leadupdate',data);
    print('form data lead api $data');
    print('Api response leads $res');
  }

  void placeOrder(String paymentMode, String templeId, String transactionId) async{
    var res = await HttpService().postApi('/api/v1/temple/puja-get-booking-all',
    {
      'payment_mode':paymentMode,
      'temple_id':templeId,
      'transaction_id':transactionId,
    });
      print('Api response $res');
    if(res['status'] == 1){
      print('Api response $res');
      Fluttertoast.showToast(
          msg: res['message'],
          backgroundColor: Colors.green,
          textColor: Colors.white);
      Navigator.of(context).pushReplacement(CupertinoPageRoute(
          builder: (BuildContext context) => const BottomBar(pageIndex: 0)));
      showDialog(
        context: context,
        builder: (context) => bookingSuccessDialog(
          context: context,
          tabIndex: 9,
          title: 'Mandir Darshan',
          message:
          'Your darshan has been successfully booked.\n\n📩 You will receive your order on your WhatsApp. Thank you!',
        ),
        barrierDismissible: true,
      );

    }else{
      Fluttertoast.showToast(
          msg: res['message'],
          backgroundColor: Colors.red,
          textColor: Colors.white);

    }
  }

  void getTempleData(String id) async {
    try {
      setState(() {
        isLoading = true;
      });

      var res = await HttpService()
          .getApi('/api/v1/temple/temple-booking-package?temple_id=$id');

      if (res != null && res['status'] == 1) {
        setState(() {
          modelData = UserFormModel.fromJson(res);
          memberList = modelData!.data.userAadhar;
          fullPhone = memberList[0].phone ?? '';
          selectedService = 'yajmaan';
        });
        print('Api response $modelData');
      } else {
        // Handle API error
        ToastHelper.showError('Failed to load temple data');
      }
    } catch (e) {
      ToastHelper.showError('Error: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void getTimeSlot(String date) async {
    if (selectedVariant == null) return;

    try {
      setState(() {
        timeSlotsList.clear();
        selectedTimeSlot = null;
      });

      var res = await HttpService().getApi(
        '/api/v1/temple/temple-time-slot?package_id=${selectedVariant!.id}&date=$date',
      );

      if (res != null && res['status'] == 1) {
        List slot = res['data'] ?? [];
        setState(() {
          timeSlotsList = slot.map((data) => Slote.fromJson(data)).toList();
        });
      } else {
        ToastHelper.showError('No time slots available');
      }
    } catch (e) {
      ToastHelper.showError('Error loading time slots: $e');
    }
  }

  bool isServiceCompleted(String service) {
    return savedForms.any((form) => form['service'] == service);
  }

  String formatTime(String time) {
    final parsedTime = DateFormat('HH:mm:ss').parse(time);
    return DateFormat('hh:mm a').format(parsedTime);
  }


  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: Colors.deepOrange)),
      );
    }

    if (modelData == null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              const Text(
                'Failed to load data',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed:()=> getTempleData(widget.id),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text('Temple Services'),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              showTempleDetailsBottomSheet(context,modelData!);
            },icon: const Icon(CupertinoIcons.info,color: Colors.deepOrange,),),
          SizedBox(width: 10,),
        ],
      ),
      floatingActionButton: _floatingButtons(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Service Buttons
          Padding(
            padding: const EdgeInsets.all(10),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  // Yajmaan button (always first)
                  _serviceButton('yajmaan', isServiceCompleted('yajmaan')),

                  // Dynamic service buttons
                  ...modelData!.data.service.map((service) {
                    bool completed = isServiceCompleted(service);
                    return _serviceButton(service, completed);
                  }).toList(),
                ],
              ),
            ),
          ),

          Expanded(
            child: PageView.builder(
              controller: pageController,
              itemCount: (modelData?.data.service.length ?? 0) + 1,
              onPageChanged: (page) {
                setState(() {
                  currentPage = page;
                  if (page == 0) {
                    selectedService = 'yajmaan';
                  } else {
                    selectedService = modelData!.data.service[page - 1];
                  }
                });
              },
              itemBuilder: (_, index) {
                if (index == 0) {
                  return _buildYajmanInfo();
                }


                // Adjust index for services (since index 0 is yajmaan)
                int serviceIndex = index - 1;
                if (serviceIndex >= modelData!.data.service.length) {
                  return const Center(child: Text('Invalid service'));
                }

                String service = modelData!.data.service[serviceIndex];
                List<Bhojan> variants = [];
                List<Purohit> purohits = [];

                switch (service) {
                  case 'darshan':
                    variants = modelData!.data.darshan;
                    break;
                  case 'puja':
                    variants = modelData!.data.puja;
                    purohits = modelData!.data.purohit;
                    break;
                  case 'bhojan':
                    variants = modelData!.data.bhojan;
                    break;
                  case 'locker':
                    variants = modelData!.data.locker;
                    break;
                  default:
                    variants = [];
                }

                if (isServiceCompleted(service)) {
                  Map<String, dynamic> form =
                  savedForms.firstWhere((f) => f['service'] == service);
                  return _savedFormCard(form);
                }

                return _serviceForm(
                  service: service,
                  variants: variants,
                  purohits: purohits,
                  slots: timeSlotsList,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _serviceButton(String serviceName, bool completed) {
    bool isSelected = serviceName == selectedService;

    return Container(
      margin: const EdgeInsets.only(right: 8), // Spacing between buttons
      child: Material(
        borderRadius: BorderRadius.circular(30),
        elevation: 2,
        child: InkWell(
          onTap: () {
            setState(() {
              selectedService = serviceName;
            });

            int targetPage = serviceName == 'yajmaan'
                ? 0
                : modelData!.data.service.indexOf(serviceName) + 1;

            pageController.jumpToPage(targetPage);
          },
          borderRadius: BorderRadius.circular(30),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              gradient: completed
                  ? const LinearGradient(
                colors: [Color(0xFF2ECC71), Color(0xFF27AE60)],
              )
                  : isSelected
                  ? const LinearGradient(
                colors: [Colors.deepOrange, Colors.orangeAccent],
              )
                  : LinearGradient(
                colors: [Colors.grey.shade400, Colors.grey.shade500],
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  serviceName.toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (completed)
                  const Padding(
                    padding: EdgeInsets.only(left: 6),
                    child: Icon(Icons.check, color: Colors.white, size: 16),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _serviceForm({
    required String service,
    required List<Bhojan> variants,
    required List<Purohit> purohits,
    required List<Slote> slots,
  }) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: ListView(
        children: [
          Text(
            '${service.toUpperCase()} Booking',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.deepOrange,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 25),
          _buildCard(
            child: DropdownButtonFormField<Bhojan>(
              isExpanded: true,
              decoration: const InputDecoration(
                labelText: 'Select Variant',
                labelStyle: TextStyle(color: Colors.black87),
                border: InputBorder.none,
              ),
              items: variants.map((v) => DropdownMenuItem(
                value: v,
                child: Text('${v.varientName} (₹${v.basePrice})'),
              )).toList(),
              value: selectedVariant,
              onChanged: (v) {
                setState(() {
                  selectedVariant = v;
                  timeSlotsList.clear();
                  selectedTimeSlot = null;
                });
              },
            ),
          ),
          const SizedBox(height: 20),
          _buildCard(
            child: InkWell(
              onTap: () async {
                DateTime? picked = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                  builder: (context, child) {
                    return Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        gradient: LinearGradient(
                          colors: [
                            Colors.deepOrange.withOpacity(0.4),
                            Colors.orange.withOpacity(0.3),
                            Colors.black.withOpacity(0.4),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.deepOrange.withOpacity(0.4),
                            blurRadius: 5,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: child,
                    );
                  },
                );

                if (picked != null) {
                  setState(() {
                    selectedDate = '${picked.day}-${picked.month}-${picked.year}';
                    selectedTimeSlot = null;
                  });
                  if (service != 'puja' && service != 'locker'){
                    getTimeSlot(selectedDate!);
                  }
                }
              },
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Select Date',
                  border: InputBorder.none,
                ),
                child: Text(
                  selectedDate ?? 'Choose Date',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          if (service != 'puja' && service != 'locker')
            slots.isNotEmpty
                ? _buildCard(child: DropdownButtonFormField<Slote>(
                isExpanded: true,
                decoration: const InputDecoration(
                  labelText: 'Select Time Slot',
                  border: InputBorder.none,
                ),
                items: slots.map((s) => DropdownMenuItem(
                  value: s,
                  child: Text('${formatTime(s.startTime)} - ${formatTime(s.endTime)}'),
                )).toList(),
                value: selectedTimeSlot,
                onChanged: (v) => setState(() => selectedTimeSlot = v),
              ),)
                : _emptyMessageCard(selectedDate),

          if (service == 'puja')
            _buildCard(
              child: DropdownButtonFormField<Purohit>(
                isExpanded: true,
                decoration: const InputDecoration(
                  labelText: 'Select Purohit',
                  border: InputBorder.none,
                ),
                items: purohits.map((p) => DropdownMenuItem(
                  value: p,
                  child: Text(p.name),
                )).toList(),
                value: selectedPurohit,
                onChanged: (v) => setState(() => selectedPurohit = v),
              ),
            ),

          if(service == 'locker')
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.deepOrange.withOpacity(0.15),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: mobileQTYController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Mobile Qty',
                      labelStyle: TextStyle(color: Colors.deepOrange),
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.deepOrange.withOpacity(0.15),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: luggageController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Luggage',
                      labelStyle: TextStyle(color: Colors.deepOrange),
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: savedMemberList.length,
            itemBuilder: (context, index) {
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.only(bottom: 8),
                child: Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: Colors.grey.shade100, width: 1),
                  ),
                  child: ListTile(
                    leading: GestureDetector(
                      onTap: () {
                        setState(() {
                          // Toggle selection status
                          savedMemberList[index] = FormMemberModel(
                            name: savedMemberList[index].name,
                            phone: savedMemberList[index].phone,
                            idNumber: savedMemberList[index].idNumber,
                            isSelected: !(savedMemberList[index].isSelected ?? false),
                          );
                          print('this is the : ${savedMemberList[index].isSelected}');
                        });
                      },
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: savedMemberList[index].isSelected == true
                                ? [
                              Colors.green.withOpacity(0.2),
                              Colors.greenAccent.withOpacity(0.1),
                            ]
                                : [
                              Colors.deepOrange.withOpacity(0.1),
                              Colors.orange.withOpacity(0.1),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          shape: BoxShape.circle,
                          border: savedMemberList[index].isSelected == true
                              ? Border.all(color: Colors.green, width: 2)
                              : null,
                        ),
                        child: Icon(
                          savedMemberList[index].isSelected == true
                              ? Icons.check_circle_rounded
                              : Icons.radio_button_unchecked_rounded,
                          color: savedMemberList[index].isSelected == true
                              ? Colors.green
                              : Colors.deepOrange,
                          size: 20,
                        ),
                      ),
                    ),
                    title: Text(
                      savedMemberList[index].name,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade800,
                        decoration: savedMemberList[index].isSelected == false
                            ? TextDecoration.lineThrough
                            : TextDecoration.none,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          savedMemberList[index].phone,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade800,
                            decoration: savedMemberList[index].isSelected == false
                                ? TextDecoration.lineThrough
                                : TextDecoration.none,
                          ),
                        ),
                        Text(
                          "${isNri ? 'Passport' : 'Aadhaar'}: ${savedMemberList[index].idNumber}",
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade600,
                            decoration: savedMemberList[index].isSelected == false
                                ? TextDecoration.lineThrough
                                : TextDecoration.none,
                          ),
                        ),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Selection Badge (agar selected hai toh)
                        if (savedMemberList[index].isSelected == true)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.green,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              'Selected',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),

                        const SizedBox(width: 8),

                      ],
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 90),
        ],
      ),
    );
  }

  Widget _buildCard({required Widget child}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.deepOrange.withOpacity(0.08),
            blurRadius: 10,
            spreadRadius: 2,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _emptyMessageCard(String? selectedDate) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: Colors.deepOrange.shade50,
        border: Border.all(color: Colors.deepOrange.shade200),
      ),
      child: Text(
        selectedDate != null
            ? 'No time slots available for the selected date.'
            : 'Please select a date to view available time slots.',
        style: TextStyle(
          color: Colors.deepOrange.shade700,
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _savedFormCard(Map<String, dynamic> form) {
    List formList = form['yajmaan'];

    String calculateTotal() {
      final int count = formList.length;

      // Extract values safely
      final double variantPricePerPerson =
          double.tryParse(form['variant_price'].toString()) ?? 0.0;

      final double platformFeePerPerson =
          double.tryParse(form['platform_fee_percentage'].toString()) ?? 0.0;

      final double receiptFeePerPerson =
          double.tryParse(form['receipt_fee_percentage'].toString()) ?? 0.0;

      final double gstPercentage =
          double.tryParse(form['gst_rate'].toString()) ?? 0.0;

      final String service = form['service']?.toString().toLowerCase() ?? '';

      // 1) Base total
      final double baseTotal = variantPricePerPerson * count;

      // 2) Platform fee = per person × count
      final double platformTotal = platformFeePerPerson * count;

      // 3) Receipt fee = per person × count
      final double receiptTotal = receiptFeePerPerson * count;

      // 4) GST ONLY if service is NOT bhojan or locker
      double gstAmount = 0.0;

      if (service == 'puja' || service == 'darshan') {
        gstAmount = (baseTotal * gstPercentage) / 100.0;
      }

      // 5) Final total
      final double total = baseTotal + gstAmount + platformTotal + receiptTotal;

      return total.toStringAsFixed(2);
    }


    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.deepOrange.withOpacity(0.1),
              blurRadius: 20,
              spreadRadius: 2,
              offset: const Offset(0, 8),
            ),
          ],
          border: Border.all(
            color: Colors.deepOrange.withOpacity(0.1),
            width: 1.5,
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Section
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Colors.deepOrange, Colors.orangeAccent],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.deepOrange.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.celebration_rounded,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "${form['service'].toString().toUpperCase()} BOOKING",
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: Colors.deepOrange,
                            letterSpacing: 0.8,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          form['variant_name'] ?? 'Package',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.green.withOpacity(0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.verified_rounded,
                          color: Colors.green.shade600,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'CONFIRMED',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: Colors.green.shade600,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Booking Details Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: Colors.grey.shade50,
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Booking Details',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildDetailItem(Icons.calendar_today, 'Date', form['date']),
                    if(form['service'] == 'locker')...[
                    _buildDetailItem(Icons.lock, 'Mobile QTY', form['phone']),
                    _buildDetailItem(Icons.luggage, 'Luggage QTY', form['luggage']),
                    ],
                    if (form['service'] != 'locker' && form['service'] != 'puja')
                    _buildDetailItem(Icons.access_time, 'Time Slot', '${formatTime(form['startSlot'])} - ${formatTime(form['endSlot'])}'),
                    if (form['service'] == 'puja')
                      _buildDetailItem(Icons.person, 'Purohit', form['purohit']),
                    _buildDetailItem(Icons.attach_money, 'Package Price', "₹${form['variant_price']}"),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Bill Summary Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  gradient: LinearGradient(
                    colors: [
                      Colors.deepOrange.withOpacity(0.05),
                      Colors.orange.withOpacity(0.05),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  border: Border.all(color: Colors.deepOrange.withOpacity(0.2)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.receipt_long_rounded,
                          color: Colors.deepOrange.shade600,
                          size: 22,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Bill Summary',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: Colors.deepOrange,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Bill Items
                    _buildBillItem('Package Amount', "₹${form['variant_price']}", Colors.black),
                    if (form['service'] == 'puja' || form['service'] == 'darshan') ...[
                      _buildBillItem('GST', "+ ${form['gst_rate']}%", Colors.green),],
                    _buildBillItem('Platform fee', "+ ₹${form['platform_fee_percentage']}", Colors.green),
                    _buildBillItem('Receipt fee', "+ ₹${form['receipt_fee_percentage']}", Colors.green),
                    _buildBillItem('Yajmaan QTY', '${formList.length}', Colors.green),

                    const Divider(height: 24, thickness: 1.2, color: Colors.grey),

                    // Total Amount
                    Row(
                      children: [
                        const Text(
                          'Total Amount',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: Colors.black87,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Colors.deepOrange, Colors.orange],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(calculateTotal(),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // Yajmaan List
              if (formList.isNotEmpty) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: Colors.blue.shade50,
                    border: Border.all(color: Colors.blue.shade100),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.group_rounded,
                            color: Colors.blue.shade700,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Yajmaan (${formList.length})',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Colors.blue.shade700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: List.generate(formList.length, (i) {
                          final yajmaan = formList[i];
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.blue.shade200),
                            ),
                            child: Text(
                              "${i + 1}. ${yajmaan['name']}",
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.blue.shade800,
                              ),
                            ),
                          );
                        }),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 50,),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailItem(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(
            icon,
            size: 18,
            color: Colors.grey.shade600,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade700,
              ),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBillItem(String title, String amount, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade700,
              ),
            ),
          ),
          Text(
            amount,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _floatingButtons() {
    bool canSave = _canSaveCurrentPage();
    bool isLastIndex = currentPage == modelData!.data.service.length;


    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Previous Button - Yajmaan page par disabled
        if(currentPage != 0)
        FloatingActionButton.extended(
          heroTag: 'prevBtn',
          backgroundColor: currentPage == 0 ? Colors.grey.shade300 : Colors.white,
          elevation: currentPage == 0 ? 0 : 4,
          onPressed: currentPage == 0
              ? null
              : () {
            pageController.previousPage(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
          },
          label: const Row(
            children: [
              Icon(Icons.arrow_back, color: Colors.black87),
              SizedBox(width: 6),
              Text(
                'Previous',
                style: TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.w600,
                ),
              )
            ],
          ),
        ),
        const SizedBox(width: 16),

        // Save/Next Button - Yajmaan page par bhi dikhe
        (isLastIndex && formComplete)
            ? FloatingActionButton.extended(
          heroTag: 'saveBtn',
          backgroundColor: Colors.green,
          elevation: 6,
          onPressed: (){
            showTicketBottomSheet(context,savedForms);
            },
          icon: const Icon( Icons.verified, color: Colors.white),
          label: const Text('Complete / Pay now',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        )
            : FloatingActionButton.extended(
          heroTag: 'saveBtn',
          backgroundColor: canSave ? Colors.deepOrange : Colors.grey,
          elevation: 6,
          onPressed:(){
            _saveCurrentForm(widget.id);
          },
          icon: const Icon( Icons.check_circle, color: Colors.white),
          label: Text(
            currentPage == 0 ? 'Next' : canSave ? 'Save / Continue' : 'Skip / Continue',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  void showTicketBottomSheet(BuildContext context, List<Map<String, dynamic>> savedForms) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (_) {
        // Convert values safely
        double calculateFinalSubtotal(Map<String, dynamic> item) {
          int count = item['yajmaan'].length;

          String serviceType = item['service'].toString().toLowerCase();
          double variant = double.tryParse(item['variant_price'].toString()) ?? 0.0;
          double platformFee = double.tryParse(item['platform_fee_percentage'].toString()) ?? 0.0;
          double receiptFee = double.tryParse(item['receipt_fee_percentage'].toString()) ?? 0.0;
          double gstRate = double.tryParse(item['gst_rate'].toString()) ?? 0.0;

          double subtotal = variant * count;

          // 👉 GST only for puja or darshan
          double gstAmount = 0.0;
          if (serviceType == 'puja' || serviceType == 'darshan') {
            gstAmount = (subtotal * gstRate) / 100;
          }

          double platform = platformFee * count;
          double receipt = receiptFee * count;

          double subtotalWithGst = subtotal + gstAmount;

          double finalSubtotal = subtotalWithGst + platform + receipt;

          return finalSubtotal;
        }

        double grandTotal = savedForms.fold(0.0, (sum, item) {
          return sum + calculateFinalSubtotal(item);
        });
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 18),

              // 🎟️ Header with Icon
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  IconButton(onPressed: ()=>Navigator.pop(context), icon: Icon(Icons.keyboard_arrow_left,color: Colors.blueGrey,)),
                  const SizedBox(width: 10),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.deepOrange.shade50,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.confirmation_number,
                      color: Colors.deepOrange.shade700,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Booking Tickets',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.5,
                      color: Color(0xFF333333),
                    ),
                  ),
                ],
              ),
              Text(
                '${savedForms.length} ticket${savedForms.length != 1 ? 's' : ''} selected',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 18),

              // 📋 Tickets List with Fancy Design
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.only(bottom: 16, top: 8),
                  itemCount: savedForms.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 20),
                  itemBuilder: (context, index) {
                    var item = savedForms[index];
                    final serviceType = item['service'].toString();

                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                        gradient: LinearGradient(
                          colors: [
                            _getServiceColor(serviceType).withOpacity(0.95),
                            _getServiceColor(serviceType).withOpacity(0.7),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.white.withOpacity(0.9),
                                Colors.white.withOpacity(0.7),
                              ],
                            ),
                          ),
                          child: Stack(
                            children: [
                              // Decorative corner elements
                              Positioned(
                                top: -120,
                                right: -60,
                                child: Container(
                                  width: 200,
                                  height: 200,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: _getServiceColor(serviceType),
                                  ),
                                ),
                              ),

                              Positioned(
                                bottom: -80,
                                left: -80,
                                child: Container(
                                  width: 300,
                                  height: 300,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: _getServiceColor(serviceType),
                                  ),
                                ),
                              ),


                              Padding(
                                padding: const EdgeInsets.all(22),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // 🔥 Header with Badge
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  Container(
                                                    padding: const EdgeInsets.symmetric(
                                                      horizontal: 12,
                                                      vertical: 6,
                                                    ),
                                                    decoration: BoxDecoration(
                                                      color: _getServiceColor(serviceType).withOpacity(0.1),
                                                      borderRadius: BorderRadius.circular(12),
                                                    ),
                                                    child: Text(
                                                      serviceType.toUpperCase(),
                                                      style: TextStyle(
                                                        fontSize: 12,
                                                        fontWeight: FontWeight.w800,
                                                        color: _getServiceColor(serviceType),
                                                        letterSpacing: 0.8,
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 10),
                                                  Icon(
                                                    _getServiceIcon(serviceType),
                                                    color: _getServiceColor(serviceType),
                                                    size: 18,
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 12),
                                              Text(
                                                item['variant_name'],
                                                style: const TextStyle(
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.w800,
                                                  color: Color(0xFF222222),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Text(
                                          "₹${item['variant_price']}",
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w900,
                                            color: Colors.white,
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                      ],
                                    ),

                                    const SizedBox(height: 20),

                                    // 📋 Details Section
                                    Container(
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.5),
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(
                                          color: Colors.grey.shade100,
                                          width: 1.5,
                                        ),
                                      ),
                                      child: Column(
                                        children: [
                                          // Date & Time Section
                                          _detailRow(
                                            icon: Icons.calendar_today,
                                            label: 'Date',
                                            value: item['date'],
                                            color: Colors.deepOrange,
                                          ),
                                          const SizedBox(height: 12),

                                          // Slot/Purohit based on service
                                          if (item['service'] != 'puja' && item['service'] != 'locker')
                                            _detailRow(
                                              icon: Icons.access_time,
                                              label: 'Slot',
                                              value: "${formatTime(item['startSlot'])} - ${formatTime(item['endSlot'])}",
                                              color: Colors.blue,
                                            ),

                                          if (item['service'] == 'puja')
                                            _detailRow(
                                              icon: Icons.person,
                                              label: 'Purohit',
                                              value: item['purohit'],
                                              color: Colors.green,
                                            ),

                                          const SizedBox(height: 12),

                                          // Members Count
                                          _detailRow(
                                            icon: Icons.people,
                                            label: 'Members',
                                            value: '${item['yajmaan'].length} Persons',
                                            color: Colors.purple,
                                          ),

                                          // Locker specific details
                                          if (item['service'] == 'locker') ...[
                                            const SizedBox(height: 12),
                                            _detailRow(
                                              icon: Icons.phone,
                                              label: 'Phone',
                                              value: item['phone'],
                                              color: Colors.teal,
                                            ),
                                            const SizedBox(height: 12),
                                            _detailRow(
                                              icon: Icons.luggage,
                                              label: 'Luggage',
                                              value: item['luggage'],
                                              color: Colors.brown,
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),

                                    const SizedBox(height: 20),

                                    // 💰 Price Breakdown in Card
                                    Container(
                                      padding: const EdgeInsets.all(18),
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade50,
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(
                                          color: Colors.grey.shade200,
                                        ),
                                      ),
                                      child: Column(
                                        children: [
                                          const Text(
                                            'Price Breakdown',
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w700,
                                              color: Colors.grey,
                                              letterSpacing: 0.5,
                                            ),
                                          ),
                                          const SizedBox(height: 16),

                                          _priceRow(
                                            label: 'Base Price',
                                            value: "₹${item['variant_price']} × ${item['yajmaan'].length}",
                                          ),
                                          const SizedBox(height: 8),

                                          if(item['service'] == 'puja' || item['service'] == 'darshan')...[
                                            _priceRow(
                                              label: 'GST',
                                              value: "+ ${item['gst_rate']}%",
                                              isTax: true,
                                            ),
                                            const SizedBox(height: 8),
                                          ],

                                          _priceRow(
                                            label: 'Platform Fee',
                                            value: "+ ₹${item['platform_fee_percentage']} × ${item['yajmaan'].length}",
                                          ),
                                          const SizedBox(height: 8),

                                          _priceRow(
                                            label: 'Receipt Fee',
                                            value: "+ ₹${item['receipt_fee_percentage']} × ${item['yajmaan'].length}",
                                          ),

                                          const Divider(height: 24, thickness: 1.5),

                                          // Subtotal
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              const Text(
                                                'Subtotal',
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w800,
                                                  color: Color(0xFF333333),
                                                ),
                                              ),
                                              Text(
                                                '₹${calculateFinalSubtotal(item)}',
                                                style: TextStyle(
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.w900,
                                                  color: _getServiceColor(serviceType),
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
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 20),

              // 💰 Total Amount with Glossy Effect
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFFE65100),
                      Color(0xFFFF5722),
                      Color(0xFFFF9800),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.deepOrange.withOpacity(0.4),
                      blurRadius: 20,
                      spreadRadius: 1,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Total Amount',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              '${savedForms.length} items',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white.withOpacity(0.9),
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 15,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.3),
                            ),
                          ),
                          child: Text(
                            '₹${grandTotal.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 25,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Pay Button
                GestureDetector(
                  onTap: () {
                    String selectedPayment = 'online';
                    bool isPayment = false;

                    showDialog(
                      context: context,
                      barrierColor: Colors.black54,
                      builder: (context) {
                        return StatefulBuilder(
                          builder: (context, setState) {
                            return Dialog(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24),
                              ),
                              backgroundColor: Colors.transparent,
                              child: Container(
                                padding: const EdgeInsets.all(18),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(24),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.2),
                                      blurRadius: 28,
                                      offset: const Offset(0, 10),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [

                                    // 🔥 Header
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Payment Method',
                                          style: TextStyle(
                                            fontSize: 22,
                                            fontWeight: FontWeight.w800,
                                            color: Colors.deepOrange.shade700,
                                          ),
                                        ),
                                        InkWell(
                                          onTap: () => Navigator.pop(context),
                                          child: Icon(Icons.close_rounded,
                                              color: Colors.grey.shade600, size: 26),
                                        )
                                      ],
                                    ),

                                    const SizedBox(height: 6),
                                    Text(
                                      'Choose your preferred payment option',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),

                                    const SizedBox(height: 24),

                                    // OPTIONS
                                    Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(color: Colors.grey.shade300),
                                      ),
                                      child: Column(
                                        children: [
                                          paymentOptionTile(
                                            title: 'Pay Online',
                                            subtitle: 'Secure payment via Cards & UPI',
                                            icon: Icons.credit_card_rounded,
                                            highlightColor: Colors.deepOrange,
                                            selectedPayment: selectedPayment,
                                            value: 'online',
                                            onSelect: () {
                                              setState(() => selectedPayment = 'online');
                                            },
                                          ),

                                          Divider(height: 1, color: Colors.grey.shade300),

                                          paymentOptionTile(
                                            title: 'Pay with Cash',
                                            subtitle: 'Pay when you arrive',
                                            icon: Icons.payments_rounded,
                                            highlightColor: Colors.green.shade600,
                                            selectedPayment: selectedPayment,
                                            value: 'cash',
                                            onSelect: () {
                                              setState(() => selectedPayment = 'cash');
                                            },
                                          ),
                                        ],
                                      ),
                                    ),

                                    const SizedBox(height: 30),

                                    // 💰 Total
                                    Container(
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(16),
                                        color: Colors.grey.shade50,
                                        border: Border.all(color: Colors.grey.shade200),
                                      ),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            'Total Amount',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.grey.shade700,
                                            ),
                                          ),
                                          Text(
                                            '₹${grandTotal.toStringAsFixed(2)}',
                                            style: const TextStyle(
                                              fontSize: 28,
                                              fontWeight: FontWeight.w900,
                                              color: Colors.deepOrange,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                    const SizedBox(height: 20),

                                    // 🚀 PAY BUTTON
                                    Material(
                                      borderRadius: BorderRadius.circular(16),
                                      child: InkWell(
                                        borderRadius: BorderRadius.circular(16),
                                        onTap: isPayment
                                            ? null
                                            : () {
                                          setState(() => isPayment = true);

                                          Future.delayed(const Duration(milliseconds: 400), () {
                                            if (selectedPayment == 'online') {
                                              razorpayService.openCheckout(
                                                amount: grandTotal.round(),
                                                razorpayKey: AppConstants.razorpayLive,
                                                onSuccess: (response) {
                                                  placeOrder('online', widget.id, response.paymentId.toString());
                                                },
                                                onFailure: (response) {},
                                                onExternalWallet: (response) {}, description: 'Mandir user form booking',
                                              );
                                            } else {
                                              placeOrder('cash', widget.id, 'cash');
                                            }
                                          });
                                        },
                                        child: AnimatedContainer(
                                          duration: const Duration(milliseconds: 300),
                                          width: double.infinity,
                                          padding: const EdgeInsets.symmetric(vertical: 16),
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: [
                                                Colors.deepOrange.shade600,
                                                Colors.orange.shade500,
                                              ],
                                            ),
                                            borderRadius: BorderRadius.circular(16),
                                          ),
                                          child: Center(
                                            child: isPayment
                                                ? const SizedBox(
                                              height: 22,
                                              width: 22,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 3,
                                                color: Colors.white,
                                              ),
                                            )
                                                : Row(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                Icon(
                                                  selectedPayment == 'online'
                                                      ? Icons.lock_rounded
                                                      : Icons.payments_rounded,
                                                  color: Colors.white,
                                                  size: 20,
                                                ),
                                                const SizedBox(width: 10),
                                                Text(
                                                  selectedPayment == 'online'
                                                      ? 'PAY SECURELY NOW'
                                                      : 'CONFIRM CASH PAYMENT',
                                                  style: const TextStyle(
                                                    fontSize: 15,
                                                    fontWeight: FontWeight.w800,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),

                                    const SizedBox(height: 14),

                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.security_rounded,
                                            size: 14, color: Colors.green.shade600),
                                        const SizedBox(width: 6),
                                        Text(
                                          'Your payment is 100% secure',
                                          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      },
                    );
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.deepOrange.withOpacity(0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Text(
                        'PROCEED TO PAYMENT',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFFE65100),
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  ),
                ),
                ],
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  void showTempleDetailsBottomSheet(BuildContext context, UserFormModel data) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.75,
          maxChildSize: 0.95,
          minChildSize: 0.40,
          builder: (_, controller) {
            return Container(
              padding: const EdgeInsets.all(20),
              child: ListView(
                controller: controller,
                physics: const BouncingScrollPhysics(),
                children: [
                  _buildSectionHeader(
                    icon: Icons.person,
                    title: 'Mandir Information',
                    subtitle: data.data.enTempleName,
                  ),
                  Container(
                    margin: EdgeInsets.symmetric(vertical: 20),
                    height: 1,
                    width: 140,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  // 🌟 Temple Image with Overlay
                  Stack(
                    children: [
                      // Main Image
                      ClipRRect(
                        borderRadius: BorderRadius.circular(22),
                        child: Image.network(
                          data.data.image,
                          height: 260,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Container(
                              height: 260,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade200,
                                borderRadius: BorderRadius.circular(22),
                              ),
                              child: Center(
                                child: CircularProgressIndicator(
                                  value: loadingProgress.expectedTotalBytes != null
                                      ? loadingProgress.cumulativeBytesLoaded /
                                      loadingProgress.expectedTotalBytes!
                                      : null,
                                  color: Colors.deepPurple,
                                ),
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              height: 260,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade200,
                                borderRadius: BorderRadius.circular(22),
                              ),
                              child: const Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.temple_hindu_rounded,
                                    size: 60,
                                    color: Colors.grey,
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'Image Not Available',
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),

                      // Gradient Overlay
                      Container(
                        height: 260,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(22),
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [
                              Colors.black.withOpacity(0.5),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),

                      // Temple Name Overlay
                      Positioned(
                        bottom: 20,
                        left: 18,
                        right: 18,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              data.data.enTempleName ?? '',
                              style: const TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                                letterSpacing: 0.5,
                                shadows: [
                                  Shadow(
                                    blurRadius: 10,
                                    color: Colors.black87,
                                  ),
                                ],
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              data.data.hiTempleName ?? '',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                                shadows: [
                                  Shadow(
                                    blurRadius: 6,
                                    color: Colors.black54,
                                  ),
                                ],
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 28),

                  // ⭐ Verification Badge
                  if (data.data.aadhaarVerifyStatus == 1)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.green.shade200, width: 1.4),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(9),
                            decoration: BoxDecoration(
                              color: Colors.green,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.verified_user,
                              color: Colors.white,
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Aadhaar Verification Required',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.red.shade900,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  'You must verify your Aadhaar to proceed with mandir booking.',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.red.shade700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                  const SizedBox(height: 28),

                  // 📝 Short Description Section
                  _buildSectionCard(
                    title: 'Short Description',
                    icon: Icons.description_rounded,
                    color: Colors.deepPurple,
                    background: Colors.deepPurple.shade50,
                    html: data.data.enShortDescription,
                    emptyText: 'No description available.',
                  ),

                  const SizedBox(height: 28),

                  // 📖 More Details Section
                  _buildSectionCard(
                    title: 'More Details',
                    icon: Icons.info_rounded,
                    color: Colors.blueGrey,
                    background: Colors.blueGrey.shade50,
                    html: data.data.enDetails,
                    emptyText: 'No additional details available.',
                  ),

                  const SizedBox(height: 40),

                  // 📍 Bottom Info Card
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      gradient: LinearGradient(
                        colors: [
                          Colors.deepPurple.shade50,
                          Colors.blue.shade50,
                        ],
                      ),
                      border: Border.all(color: Colors.deepPurple.shade100),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.temple_hindu_rounded,
                          color: Colors.deepPurple.shade700,
                          size: 32,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Sacred Place',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.deepPurple.shade900,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Please maintain sanctity and follow temple guidelines.',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.deepPurple.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 60),
                ],
              ),
            );
          },
        );
      },
    );
  }
  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required Color color,
    required Color background,
    required String? html,
    required String emptyText,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: background.withOpacity(0.6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: background.withOpacity(0.5)),
            ),
            child: Html(
              data: html ?? emptyText,
              style: {
                'body': Style(
                  margin: Margins.zero,
                  fontSize: FontSize(15),
                  lineHeight: LineHeight(1.5),
                  color: Colors.grey.shade800,
                ),
                'p': Style(
                  margin: Margins.only(bottom: 8),
                ),
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget paymentOptionTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color highlightColor,
    required String selectedPayment,
    required String value,
    required VoidCallback onSelect,
  }) {
    final isSelected = selectedPayment == value;

    return InkWell(
      onTap: onSelect,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: highlightColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: highlightColor, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: isSelected ? highlightColor : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(subtitle,
                      style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
                ],
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? highlightColor : Colors.grey.shade400,
                  width: isSelected ? 8 : 2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

// Helper Widgets
  Widget _detailRow({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            size: 16,
            color: color,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey,
            ),
          ),
        ),
        Expanded(
          flex: 2,
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Color(0xFF333333),
            ),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }

  Widget _priceRow({
    required String label,
    required String value,
    bool isTax = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade700,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isTax ? FontWeight.w600 : FontWeight.w500,
            color: isTax ? Colors.red : Colors.grey.shade800,
          ),
        ),
      ],
    );
  }

// Helper functions for service-specific styling
  Color _getServiceColor(String service) {
    switch (service) {
      case 'puja':
        return const Color(0xFF4CAF50);
      case 'bhojan':
        return const Color(0xFF6E21F3);
      case 'locker':
        return const Color(0xFF2196F3);
      default:
        return const Color(0xFFFF9800);
    }
  }

  IconData _getServiceIcon(String service) {
    switch (service) {
      case 'puja':
        return Icons.celebration;
      case 'locker':
        return Icons.lock;
      default:
        return Icons.confirmation_number;
    }
  }

  bool _canSaveCurrentPage() {
    if (currentPage == 0) {
      // Yajmaan page - at least one member required
      return memberList.isNotEmpty;
    } else {
      // Service pages
      String service = modelData!.data.service[currentPage - 1];

      if (service == 'puja') {
        return selectedVariant != null &&
            selectedDate != null &&
            selectedPurohit != null;
      }
      else if (service == 'locker') {
        return selectedVariant != null && selectedDate != null &&
            mobileQTYController.text.isNotEmpty && luggageController.text.isNotEmpty;
      }
      else {
        return selectedVariant != null &&
            selectedDate != null &&
            selectedTimeSlot != null;
      }
    }
  }

  void _saveCurrentForm(String id) {
    if (currentPage == 0) {
      // Yajmaan page - member list ko new list mein save karein aur next page par jayein
      setState(() {
        savedMemberList = memberList.map((member) => FormMemberModel(
          name: member.name,
          phone: member.phone,
          idNumber: member.aadhar,
          isSelected: true,
        )).toList();
      });

      print('savedMemberList: ${savedMemberList.length}');
      // Next page par move karein
      if (pageController.hasClients && modelData!.data.service.isNotEmpty) {
        pageController.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );

      }
      return;
    }

    String service = modelData!.data.service[currentPage - 1];

    // Helper method to get selected members
    List<Map<String, dynamic>> getSelectedYajmaan() {
      try {
        if (savedMemberList.isEmpty) {
          return [];
        }

        return savedMemberList
            .where((member) => member.isSelected == true)
            .map((member) => {
          'name': member.name.trim(),
          'phone': member.phone.trim(),
          'aadhaar': member.idNumber.trim(),
          'aadhar_status': modelData!.data.aadhaarVerifyStatus,
          'id_type': isNri ? 'passport' : 'aadhaar',
        })
            .toList();
      } catch (e) {
        print('Error getting selected yajmaan: $e');
        return [];
      }
    }

// In your _saveCurrentForm method
    List<Map<String, dynamic>> selectedYajmaan = getSelectedYajmaan();


    Map<String, dynamic> apiForm = {
      'temple_id': id,
      'type': service,
      'package_id': selectedVariant?.id ?? '',
      'purohit_id': selectedPurohit?.id ?? '',
      'date': selectedDate ?? '',
      'time_slot_id': selectedTimeSlot?.id ?? '',
      'locker_items': {
        'phone' : mobileQTYController.text,
        'luggage': luggageController.text,
      },
      'yajmaan': selectedYajmaan
    };

    Map<String, dynamic> uiForm = {
      'service': service,
      'variant_name': selectedVariant?.varientName ?? 'Not Selected',
      'variant_price': selectedVariant?.basePrice ?? '0',
      'date': selectedDate ?? 'Not Selected',
      'startSlot': selectedTimeSlot != null ? selectedTimeSlot!.startTime : 'No Slot',
      'endSlot': selectedTimeSlot != null ? selectedTimeSlot!.endTime : 'No Slot',
      'purohit': selectedPurohit != null ? selectedPurohit!.name : 'No Purohit',
      'phone' : mobileQTYController.text,
      'luggage': luggageController.text,
      'platform_fee_percentage': selectedVariant?.platformFeePercentage,
      'receipt_fee_percentage': selectedVariant?.receiptFeePercentage,
      'gst_rate': selectedVariant?.gstRate,
      'yajmaan': selectedYajmaan
    };

    if (service == 'puja') {
      if (selectedPurohit != null && selectedDate != null && selectedVariant != null) {
        setState(() {
          savedForms.add(uiForm);
          apiForms.add(apiForm);
        });
      }
    }
    else if (service == 'locker') {
      if (mobileQTYController.text.isNotEmpty &&
          luggageController.text.isNotEmpty &&
          selectedDate != null &&
          selectedVariant != null) {
        setState(() {
          savedForms.add(uiForm);   // UI Display
          apiForms.add(apiForm);    // API Submit
        });
      }
    }
    else {
      if (selectedTimeSlot != null && selectedDate != null && selectedVariant != null) {
        setState(() {
          savedForms.add(uiForm);
          apiForms.add(apiForm);
        });
      }
    }

    Map<String, dynamic> leadApi = {
      'temple_id': id,
      'customer_qty': '${savedMemberList.length}',
      'package_id': selectedVariant?.id ?? '',
      'type': service ?? '',
      'customers': jsonEncode(selectedYajmaan),
      'date': selectedDate,
    };
    updateLead(leadApi);

    setState(() {
      // Reset form
      selectedVariant = null;
      selectedDate = null;
      selectedTimeSlot = null;
      selectedPurohit = null;
      timeSlotsList.clear();
    });

    // Move to next page if available
    if (currentPage < (modelData!.data.service.length)) {
      pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      ToastHelper.showSuccess('All services booked successfully!');
      print('Final API Data: $apiForms');
      setState(() {formComplete = true;});
    }
  }

  Widget _buildSectionHeader({
    required IconData icon,
    required String title,
    required String subtitle
  }) {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.deepOrange),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepOrange)),
              Text(subtitle,
                  style: const TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildYajmanInfo() {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildSectionHeader(
            icon: Icons.person,
            title: 'Yajman Information',
            subtitle: 'Please provide your details',
          ),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: Colors.deepOrange.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (memberList.isEmpty) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.group_rounded,
                            size: 48,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'No members added yet',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Add members using the form above',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade500,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                  formComplete ? const SizedBox() :
                  Container(
                    width: double.infinity,
                    height: 54,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.deepOrange, Colors.orange.shade700],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.deepOrange.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: const Icon(Icons.add_circle_rounded,
                          color: Colors.white, size: 22),
                      label: const Text(
                        'Add Member',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      onPressed: _showAddMemberBottomSheet,
                    ),
                  ),
                  if (memberList.isNotEmpty) ...[
                    const SizedBox(height: 28),
                    Padding(
                      padding: const EdgeInsets.only(left: 4),
                      child: Row(
                        children: [
                          const Icon(Icons.list_alt_rounded,
                              color: Colors.deepOrange, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'Added Members (${memberList.length})',
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                              color: Colors.deepOrange,
                            ),
                          ),
                          const Spacer(),
                          InkWell(
                            borderRadius: BorderRadius.circular(30),
                            onTap: () {
                              setState(() {
                                isRotating = true;
                                memberList = List.from(memberList);
                              });
                              Future.delayed(const Duration(milliseconds: 600), () {
                                setState(() {
                                  isRotating = false;
                                });
                              });
                            },
                            child: AnimatedRotation(
                              turns: isRotating ? 1 : 0,
                              duration: const Duration(milliseconds: 600),
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.deepOrange.withOpacity(0.1),
                                ),
                                child: const Icon(Icons.refresh,
                                    color: Colors.deepOrange, size: 22),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: memberList.length,
                      itemBuilder: (context, index) {
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: const EdgeInsets.only(bottom: 8),
                          child: Card(
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(color: Colors.grey.shade100, width: 1),
                            ),
                            child: ListTile(
                              leading: Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.deepOrange.withOpacity(0.1),
                                      Colors.orange.withOpacity(0.1),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.person_rounded,
                                  color: Colors.deepOrange,
                                  size: 20,
                                ),
                              ),
                              title: Text(
                                memberList[index].name,
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey.shade800,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    memberList[index].phone,
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.grey.shade800,
                                    ),
                                  ),
                                  Text(
                                    "${isNri ? 'Passport' : 'Aadhaar'}: ${memberList[index].aadhar}",
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                              trailing: index == 0 ? null : IconButton(
                                icon: Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: Colors.red.withOpacity(0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.delete_rounded,
                                    color: Colors.red,
                                    size: 18,
                                  ),
                                ),
                                onPressed: () {
                                  setState(() {
                                    memberList.removeAt(index);
                                  });
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Member removed'),
                                      backgroundColor: Colors.orange,
                                      behavior: SnackBarBehavior.floating,
                                    ),
                                  );
                                },
                              ),
                              contentPadding:
                              const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddMemberBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.85,
          maxChildSize: 0.95,
          minChildSize: 0.5,
          builder: (_, controller) {
            return StatefulBuilder(
                builder: (context, StateSetter bsSetState) {
                  int verificationStatus = modelData!.data.aadhaarVerifyStatus;
                  return Padding(
                    padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom,),
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          children: [
                            Column(
                              children: [
                                Container(
                                    padding: const EdgeInsets.all(20),
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade100,
                                      borderRadius: BorderRadius.circular(100),
                                    ),
                                    child: const Icon(Icons.group,
                                        color: Colors.deepOrange, size: 30)),
                                const SizedBox(width: 8),
                                const Text('Add Members',
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.deepOrange)),
                                const Text('Please provide your details',
                                    style: TextStyle(fontSize: 12, color: Colors.grey)),
                              ],
                            ),
                            Divider(color: Colors.grey.shade300),
                            // ... rest of your bottom sheet content
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.grey.shade50,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.grey.shade200),
                              ),
                              child: SwitchListTile(
                                value: isNri,
                                onChanged: (val) {
                                  bsSetState(() {
                                    isNri = val;
                                    passportController.clear();
                                    aadhaarController.clear();
                                    aadharController2.clear();
                                    phoneController2.clear();
                                  });
                                  HapticFeedback.lightImpact();
                                },
                                contentPadding:
                                const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                dense: true,
                                secondary: Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: isNri
                                        ? Colors.blue.withOpacity(0.1)
                                        : Colors.deepOrange.withOpacity(0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    isNri ? Icons.flight_rounded : Icons.home_rounded,
                                    color: isNri ? Colors.blue : Colors.deepOrange,
                                    size: 20,
                                  ),
                                ),
                                title: Text(
                                  'NRI Yajman',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey.shade800,
                                  ),
                                ),
                                subtitle: Text(
                                  isNri
                                      ? 'Using Passport for identification'
                                      : 'Using Aadhaar for identification',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                                activeColor: Colors.white,
                                activeTrackColor: Colors.blue,
                                inactiveThumbColor: Colors.white,
                                inactiveTrackColor: Colors.grey.shade400,
                                tileColor: Colors.transparent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                            Divider(color: Colors.grey.shade300),

                            if (verificationStatus == 1) ...[
                              const SizedBox(height: 16),
                              TextField(
                                controller: phoneController2,
                                keyboardType: TextInputType.phone,
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: Colors.grey.shade50,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide.none,
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 14,
                                  ),
                                  hintText: ' Enter phone number',
                                  prefixIcon: const Icon(
                                    Icons.phone_rounded,
                                    color: Colors.deepOrange,
                                  ),
                                  counterText: '',
                                ),
                                maxLength: 10,
                              ),
                              const SizedBox(height: 16),

                              TextField(
                                controller: aadharController2,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: Colors.grey.shade50,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide.none,
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 14,
                                  ),
                                  hintText: ' Enter 12-digit Aadhar',
                                  prefixIcon: const Icon(
                                    Icons.credit_card,
                                    color: Colors.deepOrange,
                                  ),
                                  counterText: '',
                                ),
                                maxLength: 12,
                              ),
                              const SizedBox(height: 24),
                              // verify btn
                              if (phoneController2.text.isNotEmpty ||
                                  aadharController2.text.isNotEmpty)
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      String aadhar = aadharController2.text.trim();
                                      // Check if aadhar already exists
                                      bool exists = memberList.any(
                                              (devotee) => devotee.aadhar == aadhar);

                                      if (exists) {
                                        // Aadhaar already exists in the list
                                        Fluttertoast.showToast(
                                            msg:
                                            'This Aadhar number is already added',
                                            backgroundColor: Colors.red,
                                            textColor: Colors.white);
                                      } else {
                                        bsSetState(() {
                                          isverify = true;
                                        });
                                        getAadhar(aadharController2.text.trim(),
                                            context, bsSetState);
                                        // showOtpVerificationDialog(context,aadharController2.text.trim());
                                      }
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.deepOrange,
                                      padding:
                                      const EdgeInsets.symmetric(vertical: 16),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      elevation: 0,
                                    ),
                                    child: isverify
                                        ? const CircularProgressIndicator(
                                      color: Colors.white,
                                    )
                                        : const Text(
                                      'Verify',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                )
                              else
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: () {},
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.grey,
                                      padding:
                                      const EdgeInsets.symmetric(vertical: 16),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      elevation: 0,
                                    ),
                                    child: isverify
                                        ? const CircularProgressIndicator(
                                      color: Colors.white,
                                    )
                                        : const Text(
                                      'Verify',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                            ],



                            if(verificationStatus != 1)...[
                              const SizedBox(height: 16),
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.grey.shade300),
                                ),
                                child: TextField(
                                  controller: nameController,
                                  decoration: InputDecoration(
                                    labelText: 'Enter Name',
                                    labelStyle: TextStyle(color: Colors.grey.shade700),
                                    prefixIcon: Container(
                                      margin: const EdgeInsets.only(left: 8),
                                      child: const Icon(Icons.person, color: Colors.deepOrange),
                                    ),
                                    border: InputBorder.none,
                                    contentPadding:
                                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  ),
                                  style:
                                  const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                                ),
                              ),
                              const SizedBox(height: 10),

                              if(memberList.isEmpty)...[
                                Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: Colors.grey.shade300),
                                  ),
                                  child: IntlPhoneField(
                                    decoration: InputDecoration(
                                      labelText: 'Phone Number',
                                      labelStyle: TextStyle(color: Colors.grey.shade700),
                                      border: InputBorder.none,
                                      contentPadding:
                                      const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                                    ),
                                    disableLengthCheck: true,
                                    style:
                                    const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                                    initialCountryCode: 'IN',
                                    onChanged: (phone) => fullPhone = phone.completeNumber,
                                  ),
                                ),
                                const SizedBox(height: 10)
                              ],

                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.grey.shade300),
                                ),
                                child: TextField(
                                  controller: isNri ? passportController : aadhaarController,
                                  keyboardType: isNri ? TextInputType.text : TextInputType.number,
                                  decoration: InputDecoration(
                                    labelText: isNri ? 'Passport Number' : 'Aadhaar Number (Optional)',
                                    labelStyle: TextStyle(color: Colors.grey.shade700),
                                    prefixIcon: Container(
                                      margin: const EdgeInsets.only(left: 8),
                                      child: Icon(
                                        isNri
                                            ? Icons.airplane_ticket_rounded
                                            : Icons.badge_rounded,
                                        color: Colors.deepOrange,
                                      ),
                                    ),
                                    border: InputBorder.none,
                                    contentPadding:
                                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  ),
                                  style:
                                  const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                                  inputFormatters: !isNri
                                      ? [FilteringTextInputFormatter.digitsOnly]
                                      : [],
                                ),
                              ),
                              const SizedBox(height: 25),
                              Container(
                                width: double.infinity,
                                height: 54,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [Colors.deepOrange, Colors.orange.shade700],
                                    begin: Alignment.centerLeft,
                                    end: Alignment.centerRight,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.deepOrange.withOpacity(0.3),
                                      blurRadius: 8,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.transparent,
                                    shadowColor: Colors.transparent,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  icon: const Icon(Icons.add_circle_rounded,
                                      color: Colors.white, size: 22),
                                  label: const Text(
                                    'Add Member',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  onPressed: () {
                                    if (fullPhone.isEmpty) {
                                      ToastHelper.showError('Please enter phone number!');
                                      return;
                                    }

                                    String id = isNri
                                        ? passportController.text.trim()
                                        : aadhaarController.text.trim();

                                    if (id.isEmpty) {
                                      ToastHelper.showError(
                                          "Please enter valid ${isNri ? 'Passport' : 'Aadhaar'} number");
                                      return;
                                    }

                                    if (nameController.text.trim().isEmpty) {
                                      ToastHelper.showError('Please enter name!');
                                      return;
                                    }

                                    setState(() {
                                      memberList.add(UserAadhar(
                                          phone: fullPhone,
                                          aadhar: id,
                                          name: nameController.text.trim()
                                      ));
                                      passportController.clear();
                                      aadhaarController.clear();
                                      nameController.clear();
                                    });

                                    Navigator.pop(context);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Member added successfully!'),
                                        backgroundColor: Colors.green,
                                        behavior: SnackBarBehavior.floating,
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  );
                }
            );
          },
        );
      },
    );
  }
}

class FormMemberModel {
  String name;
  String phone;
  String idNumber;
  bool isSelected;

  FormMemberModel({
    required this.name,
    required this.phone,
    required this.idNumber,
    required this.isSelected,
  });
}

// class MemberModel {
//   final String name;
//   final String phone;
//   final String idNumber;
//
//   MemberModel({
//     required this.name,
//     required this.phone,
//     required this.idNumber
//   });
// }