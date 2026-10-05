
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/datasource/remote/http/httpClient.dart';
import '../../main.dart';
import '../../utill/app_constants.dart';
import '../../utill/completed_order_dialog.dart';
import '../../utill/payment_process_screen.dart';
import '../../utill/razorpay_screen.dart';
import '../custom_bottom_bar/bottomBar.dart';
import '../profile/controllers/profile_contrroller.dart';

class BookingConfirmationPage extends StatefulWidget {
  final String type;
  final String carName;
  final String location;
  final double hour;
  final String pickupDate;
  final String price;
  final int? finalAmount;
  final int? gstAmount;
  final int? driverLocal;
  final int? driverRound;
  final String vehicleId;
  final String leadId;
  final int totalDays;
  final List<dynamic> multiaddress;
  const BookingConfirmationPage({super.key,
    required this.type,
    required this.carName,
    required this.location,
    required this.hour,
    required this.pickupDate,
    required this.price,
    required this.finalAmount,
    required this.vehicleId,
    required  this.leadId,
    required this.gstAmount,
    required this.driverLocal,
    required this.driverRound,
    required this.totalDays,
    required this.multiaddress,
  });

  @override
  State<BookingConfirmationPage> createState() => _BookingConfirmationPageState();
}

class _BookingConfirmationPageState extends State<BookingConfirmationPage> {
  bool _isAadhaarVerified = false;
  bool isVerify = false;
  bool isBTN = false;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _aadhaarController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final razorpayService = RazorpayPaymentService();
  bool isLoading = false;
  Map<String, dynamic>? _aadhaarData;

  void getAadhar(String aadharNumber, BuildContext context) async {
    var res = await HttpService().postApi(AppConstants.sendAadharOtp, {
      'aadhaar_number': aadharNumber,
    });
    setState(() => isBTN = false);
    if (res['status'] == 1) {
      String id = res['data']['request_id'].toString();
      Fluttertoast.showToast(msg: 'Send OTP', backgroundColor: Colors.green, textColor: Colors.white);
      showOtpVerificationDialog(context, id);
    } else if (res['status'] == 2) {
      setState(() {
        _aadhaarData = res['data'];
        
        // If data is present, update. If null or empty, keep existing value.
        String? newName = res['data']['name'];
        if (newName != null && newName.isNotEmpty) {
          _nameController.text = newName;
        }
        
        String phone = res['data']['phone']?.toString() ?? '';
        if (phone.isNotEmpty) {
          if (phone.startsWith('+91')) {
            phone = phone.substring(3);
          }
          _mobileController.text = phone;
        }
        
        String? newAadhar = res['data']['aadhar']?.toString();
        if (newAadhar != null && newAadhar.isNotEmpty) {
          _aadhaarController.text = newAadhar;
        }
        
        var addr = res['data']['address'];
        if (addr is Map) {
          _addressController.text = [
            addr['house'], addr['street'], addr['landmark'], addr['loc'], 
            addr['vtc'], addr['po'], addr['subdist'], addr['dist'], 
            addr['state'], addr['country']
          ].where((e) => e != null && e.toString().trim().isNotEmpty).join(', ');
        } else if (addr != null && addr.toString().isNotEmpty) {
          _addressController.text = addr.toString();
        }
        
        _isAadhaarVerified = true;
        isVerify = true;
        isBTN = false;
      });
      Fluttertoast.showToast(msg: 'Success', backgroundColor: Colors.green, textColor: Colors.white);
    } else {
      Fluttertoast.showToast(msg: 'Invalid Aadhaar Number', backgroundColor: Colors.red, textColor: Colors.white);
      setState(() {
        _isAadhaarVerified = false;
        isVerify = false;
        isBTN = false;
      });
    }
  }

  void verifyOtp(String otp, String id,
      BuildContext context) async {
    var res = await HttpService().postApi(
        AppConstants.sendAadharOtpVerify, {'otp': otp, 'request_id': id});
    print(res);
    if (res['status'] == 1) {
      setState(() {
        _aadhaarData = res['data']['data'];
        
        String? newName = _aadhaarData?['full_name'];
        if (newName != null && newName.isNotEmpty) {
          _nameController.text = newName;
        }
        
        String phone = _aadhaarData?['phone']?.toString() ?? '';
        if (phone.isNotEmpty) {
          if (phone.startsWith('+91')) {
            phone = phone.substring(3);
          }
          _mobileController.text = phone;
        }
        
        String? newAadhar = _aadhaarData?['aadhaar_number']?.toString();
        if (newAadhar != null && newAadhar.isNotEmpty) {
          _aadhaarController.text = newAadhar;
        }
        
        var addr = _aadhaarData?['address'];
        if (addr is Map) {
          _addressController.text = [
            addr['house'], addr['street'], addr['landmark'], addr['loc'], 
            addr['vtc'], addr['po'], addr['subdist'], addr['dist'], 
            addr['state'], addr['country']
          ].where((e) => e != null && e.toString().trim().isNotEmpty).join(', ');
        } else if (addr != null && addr.toString().isNotEmpty) {
          _addressController.text = addr.toString();
        }

        _isAadhaarVerified = true;
        isVerify = true;
        isBTN = false;
      });
      Navigator.pop(context);
      Fluttertoast.showToast(msg: 'Success', backgroundColor: Colors.green, textColor: Colors.white);
    } else {
      setState(() {
        _isAadhaarVerified = false;
        isVerify = false;
        isBTN = false;
      });
      Fluttertoast.showToast(msg: 'Invalid request', backgroundColor: Colors.red, textColor: Colors.white);
    }
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
                            getAadhar(_aadhaarController.text, context);
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
                            verifyOtp(otpController.text, requestId,context);
                          } : null,
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
                          child: _isAadhaarVerified
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

  Future<void> _clearReferralCodes() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('referral_code');
      await prefs.remove('active_agent_code');
      debugPrint('🧹 Referral codes cleared from SharedPreferences (Self Vehicle)');
    } catch (e) {
      debugPrint('Error clearing referral codes: $e');
    }
  }

  void orderPlace(Map<String, dynamic> data) async{
    final prefs = await SharedPreferences.getInstance();
    final String? referralCode = prefs.getString('referral_code');

    if (referralCode != null && referralCode.isNotEmpty) {
      data["active_agent_code"] = referralCode;
    }

    var res = await HttpService().postApi('/api/v1/self-vehicle/vehicle-booking-success', data);
    if(res['status'] == 1){
      String msg = widget.type == "self" ? "self-drive" : "cab" ;
      Navigator.of(context).pushReplacement(CupertinoPageRoute(
          builder: (BuildContext context) => const BottomBar(pageIndex: 0)));
      showDialog(
        context: context,
        builder: (context) => bookingSuccessDialog(
          context: context,
          tabIndex: 14,
          title: 'Cab Booked!',
          message:
          'Your $msg has been successfully booked. Please reach the pickup location on your selected date and time with valid ID proof.',
        ),
        barrierDismissible: true,
      );
      setState(() {
        isLoading = false;
      });
    }
    print('Api response data place order $res');
    print('body data  $data');
  }

  void getLeadGenerate(Map<String, dynamic> leadData) async {
    final prefs = await SharedPreferences.getInstance();
    final String? referralCode = prefs.getString('referral_code');

    if (referralCode != null && referralCode.isNotEmpty) {
      leadData["active_agent_code"] = referralCode;
    }

    var res = await HttpService().postApi('/api/v1/self-vehicle/vehicle-create-lead',leadData);
    print('api response for lead generate $res, body data $leadData');
    if (res['status'] == 1) {
    }
  }


    @override
  void initState() {
    // TODO: implement initState
    String phone = Provider.of<ProfileController>(Get.context!, listen: false).userPHONE;
    if (phone.startsWith('+91')) {
      phone = phone.substring(3);
    }
    setState(() {
      _nameController.text = Provider.of<ProfileController>(Get.context!, listen: false).userNAME;
      _emailController.text = Provider.of<ProfileController>(Get.context!, listen: false).userEMAIL;
      _mobileController.text = phone;
    });

    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    double baseAmount =
        widget.hour.ceil() * double.parse(widget.price);

    double driverAmount = 0;

    if (widget.type == 'local') {
      driverAmount =
          (double.tryParse(widget.driverLocal.toString()) ?? 0) *
              (widget.totalDays ?? 1);
    } else if (widget.type == 'two-way' ||
        widget.type == 'one-way') {
      driverAmount =
          (double.tryParse(widget.driverRound.toString()) ?? 0) *
              (widget.totalDays ?? 1);
    }

    /// ✅ TOTAL BEFORE GST
    double subTotal = baseAmount + driverAmount;

    /// ✅ GST ON TOTAL (base + driver)
    double gstValue =
        (subTotal * (widget.gstAmount ?? 0)) / 100;

    /// ✅ FINAL AMOUNT
    double finalAmount = subTotal + gstValue;
    return isLoading
        ? const MahakalPaymentProcessing()
        :  Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: (widget.type == 'self' && !_isAadhaarVerified)
          ? const SizedBox()
          : Container(
        height: 70,
        margin: const EdgeInsets.symmetric(horizontal: 10),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF2196F3),
              Color(0xFF1565C0),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.blue.withOpacity(0.35),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            /// PRICE
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Total Amount',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 2),
               Text(
                 '₹${widget.finalAmount}',
                 style: const TextStyle(
                   fontSize: 20,
                   fontWeight: FontWeight.bold,
                   color: Colors.white,
                 ),
               )
              ],
            ),

            const Spacer(),

            /// CTA BUTTON
            InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () {
                setState(() {
                  isLoading = true;
                });
                String phoneNumber = _mobileController.text;
                if (!phoneNumber.startsWith('+91')) {
                  phoneNumber = '+91$phoneNumber';
                }

                Map<String, dynamic> leadData = {
                  'lead_id': widget.leadId,
                  'id': widget.vehicleId,
                  'price': widget.finalAmount,
                  'wallet_type': '0', // example
                  'aadhaar_number': _aadhaarController.text,
                  'f_name': _nameController.text,
                  'phone_number': phoneNumber,
                  'address': _addressController.text,
                'multiaddress': widget.multiaddress,
                  'booking_cab_ac': 'ac',
                };
                getLeadGenerate(leadData);
                // TODO: Book Now action
                _clearReferralCodes();
                razorpayService.openCheckout(
                  amount: widget.finalAmount,
                  razorpayKey: AppConstants.razorpayLive,
                  onSuccess: (response) {
                    Map<String, dynamic> data = {
                      'wallet_type': '0',  //0,1
                      'lead_id':widget.leadId,
                      'transaction_id':response.paymentId.toString(),
                      'online_pay': widget.finalAmount,
                    };
                    orderPlace(data);
                  },
                  onFailure: (response) {
                    setState(() {
                      isLoading = false;
                    });
                  },
                  onExternalWallet: (response) {}, description: 'Self driving',
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                decoration: BoxDecoration(
                  color:  Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Row(
                  children: [
                    Text(
                      'BOOK NOW',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: Colors.blue,
                      ),
                    ),
                    SizedBox(width: 6),
                    Icon(
                      Icons.arrow_forward_rounded,
                      color: Colors.blue,
                      size: 20,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),

      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFF42A5F5),
                Color(0xFF1E3A8A),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.vertical(
              bottom: Radius.circular(22),
            ),
          ),
        ),
        title: const Text('Booking Confirmation',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Colors.white,
            letterSpacing: 0.5,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Contact & Pickup Details
              _buildContactDetailsInfo(),
              const SizedBox(height: 20),

              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    /// LOCATION
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(7),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.location_on,
                              color: Colors.blue, size: 18),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            widget.location,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),
                    Divider(color: Colors.grey.shade200, height: 1),

                    const SizedBox(height: 8),

                    /// DETAILS (Compact spacing)
                    _infoRow(
                      icon: Icons.directions_car,
                      label: 'Car',
                      value: "${widget.carName} • ${widget.type}",
                      color: Colors.blue,
                    ),

                    _infoRow(
                      icon: Icons.calendar_month,
                      label: 'Pickup',
                      value: widget.pickupDate,
                      color: Colors.black87,
                    ),
                    //
                    // _infoRow(
                    //   icon: widget.type == 'self'
                    //       ? Icons.schedule
                    //       : Icons.add_road,
                    //   label: widget.type == 'self'
                    //       ? 'Duration'
                    //       : 'Distance',
                    //   value:
                    //   '${widget.hour.ceil()} ${widget.type == 'self' ? 'Hr' : 'Km'}',
                    //   color: Colors.black87,
                    // ),
                    //
                    // const SizedBox(height: 6),
                    //
                    // /// BASE
                    // _infoRow(
                    //   icon: Icons.currency_rupee,
                    //   label: 'Base',
                    //   value:
                    //   '${widget.hour.ceil()} x ₹${widget.price} = ₹${baseAmount.toInt()}',
                    //   color: Colors.green,
                    // ),
                    //
                    // /// DRIVER
                    // if (driverAmount > 0)
                    //   _infoRow(
                    //     icon: Icons.person,
                    //     label: 'Driver',
                    //     value: '+ ₹${driverAmount.toInt()}',
                    //     color: Colors.green,
                    //   ),
                    //
                    // /// GST
                    // _infoRow(
                    //   icon: Icons.receipt,
                    //   label: 'GST ${widget.gstAmount}%',
                    //   value: '+ ₹${gstValue.toInt()}',
                    //   color: Colors.orange,
                    // ),
                    //
                    // const SizedBox(height: 12),
                    //
                    // /// TOTAL (More premium)
                    // Container(
                    //   padding: EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                    //   decoration: BoxDecoration(
                    //     borderRadius: BorderRadius.circular(12),
                    //     gradient: LinearGradient(
                    //       colors: [
                    //         Colors.blue,
                    //         Colors.orange.shade400,
                    //       ],
                    //     ),
                    //   ),
                    //   child: Row(
                    //     children: [
                    //       const Text(
                    //         'Total',
                    //         style: TextStyle(
                    //           color: Colors.white70,
                    //           fontSize: 13,
                    //         ),
                    //       ),
                    //       const Spacer(),
                    //       Row(
                    //         children: [
                    //           const Icon(Icons.currency_rupee,
                    //               color: Colors.white, size: 16),
                    //           Text(
                    //             '${finalAmount * widget.totalDays}',
                    //             style: const TextStyle(
                    //               fontSize: 17,
                    //               fontWeight: FontWeight.bold,
                    //               color: Colors.white,
                    //             ),
                    //           ),
                    //         ],
                    //       ),
                    //     ],
                    //   ),
                    // ),
                    Container(
                      margin: const EdgeInsets.only(top: 10),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Column(
                        children: [

                          /// BASE
                          _priceRow(
                            'Base Fare',
                            '${widget.hour.ceil()}${widget.type == 'self' ? 'Hr' : 'Km'} × ₹${widget.price}',
                            '₹${baseAmount.toInt()}',
                          ),

                          /// DRIVER
                          if (driverAmount > 0)
                            _priceRow(
                              'Driver Charge',
                              '',
                              '₹${driverAmount.toInt()}',
                            ),

                          /// SUBTOTAL
                          _priceRow(
                            'Subtotal',
                            '',
                            '₹${(baseAmount + driverAmount).toInt()}',
                          ),

                          /// GST
                          _priceRow(
                            'GST (${widget.gstAmount}%)',
                            '',
                            '₹${gstValue.toInt()}',
                          ),

                          Divider(height: 20,color: Colors.grey.shade300,),

                          /// TOTAL PER DAY
                          _priceRow(
                            'Total / Day',
                            '',
                            '₹${finalAmount.toInt()}',
                            isBold: true,
                          ),

                          /// TOTAL DAYS
                          _priceRow(
                            'Days',
                            '',
                            '× ${widget.totalDays}',
                          ),

                           Divider(height: 20,color: Colors.grey.shade300,),

                          /// FINAL TOTAL
                          _priceRow(
                            'Final Amount',
                            '',
                            '₹${finalAmount}',
                            isBold: true,
                            isHighlight: true,
                          ),
                        ],
                      ),
                    )

                  ],
                ),
              ),

              SizedBox(height: 100,)
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoRow({
    required IconData icon,
    required Color color,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 16, color: color),
          ),

          const SizedBox(width: 10),

          /// LABEL + VALUE
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _priceRow(
      String title,
      String subtitle,
      String amount, {
        bool isBold = false,
        bool isHighlight = false,
      }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight:
                    isBold ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
                if (subtitle.isNotEmpty)
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey[600],
                    ),
                  ),
              ],
            ),
          ),
          Text(
            amount,
            style: TextStyle(
              fontSize: isHighlight ? 16 : 14,
              fontWeight:
              isHighlight ? FontWeight.bold : FontWeight.w600,
              color: isHighlight
                  ? Colors.blue
                  : Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _aadhaarVerifyCard({
    required TextEditingController aadhaarController,
    required VoidCallback onVerify,
    bool isVerified = false,
  }) {
    return  Container(
      height: 62,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isVerified
              ? [
            Colors.green.shade100,
            Colors.green.shade50,
          ]
              : [
            Colors.orange.shade200.withOpacity(0.9),
            Colors.amber.shade50.withOpacity(0.9),
          ],
        ),
        border: Border.all(
          color: isVerified
              ? Colors.green.shade600
              : Colors.blue.shade700.withOpacity(0.7),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          /// ICON
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isVerified ? Colors.green : Colors.blue,
            ),
            child: Icon(
              isVerified
                  ? Icons.verified_rounded
                  : Icons.fingerprint_rounded,
              color: Colors.white,
              size: 20,
            ),
          ),

          const SizedBox(width: 12),

          /// AADHAAR INPUT
          Expanded(
            child: TextField(
              controller: aadhaarController,
              keyboardType: TextInputType.number,
              maxLength: 12,
              enabled: !isVerified,
              decoration: InputDecoration(
                counterText: '',
                hintText: 'Enter Aadhaar Number',
                hintStyle: TextStyle(
                  fontSize: 15,
                  color: Colors.grey.shade600,
                ),
                border: InputBorder.none,
              ),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.2,
              ),
            ),
          ),

          /// VERIFY BUTTON / STATUS
          isVerified
              ? const Row(
            children: [
              Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 20,
              ),
              SizedBox(width: 4),
              Text(
                'Verified',
                style: TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          )
              : ElevatedButton(
            onPressed: aadhaarController.text.length == 12 ? onVerify : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: aadhaarController.text.length == 12 ? Colors.blue : Colors.grey.shade300,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              padding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              elevation: 0,
            ),
            child: isVerify ? const CircularProgressIndicator(color: Colors.white,) :  const Text(
              'VERIFY',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                letterSpacing: 0.4,
                color: Colors.white
              ),
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildContactDetailsInfo() {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// TITLE ROW
          Row(
            children: [
              Text(
                'User Information',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade900,
                ),
              ),
              const Spacer(),
              Icon(
                Icons.verified_user,
                size: 18,
                color: Colors.blue.shade400,
              ),
            ],
          ),

          const SizedBox(height: 6),

          /// ORANGE LINE
          Container(
            height: 2,
            width: 28,
            decoration: BoxDecoration(
              color: Colors.blue.shade300,
              borderRadius: BorderRadius.circular(4),
            ),
          ),

          const SizedBox(height: 14),
          if(widget.type == 'self')
            Container(
              height: 62,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isVerify
                      ? [
                    Colors.green.shade100,
                    Colors.green.shade50,
                  ]
                      : [
                    Colors.orange.shade200.withOpacity(0.9),
                    Colors.amber.shade50.withOpacity(0.9),
                  ],
                ),
                border: Border.all(
                  color: isVerify
                      ? Colors.green.shade600
                      : Colors.blue.shade700.withOpacity(0.7),
                  width: 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  /// ICON
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isVerify ? Colors.green : Colors.blue,
                    ),
                    child: Icon(
                      isVerify
                          ? Icons.verified_rounded
                          : Icons.fingerprint_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),

                  const SizedBox(width: 12),

                  /// AADHAAR INPUT
                  Expanded(
                    child: TextField(
                      controller: _aadhaarController,
                      keyboardType: TextInputType.number,
                      maxLength: 12,
                      enabled: !isVerify,
                      decoration: InputDecoration(
                        counterText: '',
                        hintText: 'Enter Aadhaar Number',
                        hintStyle: TextStyle(
                          fontSize: 15,
                          color: Colors.grey.shade600,
                        ),
                        border: InputBorder.none,
                      ),
                      onChanged: (value) {
                        setState(() {});
                        if (value.length == 12) {
                          FocusScope.of(context).unfocus(); // 🔥 keyboard close
                        }
                      },
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),

                  /// VERIFY BUTTON / STATUS
                  isVerify
                      ? const Row(
                    children: [
                      Icon(
                        Icons.check_circle,
                        color: Colors.green,
                        size: 20,
                      ),
                      SizedBox(width: 4),
                      Text(
                        'Verified',
                        style: TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  )
                      : ElevatedButton(
                    onPressed: _aadhaarController.text.length == 12 ? (){
                      setState(() => isBTN = true);
                      getAadhar(_aadhaarController.text,context);
                    } : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _aadhaarController.text.length == 12 ? Colors.blue : Colors.grey.shade300,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                      padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      elevation: 0,
                    ),
                    child: isBTN ? const CircularProgressIndicator(color: Colors.white,) :  const Text(
                      'VERIFY',
                      style: TextStyle(
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.4,
                          color: Colors.white
                      ),
                    ),
                  ),
                ],
              ),
            ),

          const SizedBox(height: 10),
          _inputTileCompact(
            icon: Icons.person_outline,
            label: 'Name',
            controller: _nameController,
          ),

          const SizedBox(height: 10),

          _inputTileCompact(
            icon: Icons.phone,
            label: 'Mobile',
            controller: _mobileController,
            keyboardType: TextInputType.phone,
            prefix: '+91 ',
          ),
        ],
      ),
    );
  }

  Widget _inputTileCompact({
    required IconData icon,
    required String label,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    String? prefix,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.blue.shade400),
          const SizedBox(width: 8),
          Text('$label : ',
              style: TextStyle(
                  fontSize: 12, color: Colors.blue.shade400)),
          Expanded(
            child: TextField(
              controller: controller,
              keyboardType: keyboardType,
              maxLines: maxLines,
              minLines: 1,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              decoration: InputDecoration(
                border: InputBorder.none,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 8),
                prefixText: prefix,
                prefixStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black87),
              ),
            ),
          ),
        ],
      ),
    );
  }
  Widget _infoTileCompact({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.blue.shade400),
          const SizedBox(width: 5),
          Text('$label : ', style: TextStyle(fontSize: 12, color: Colors.blue.shade400)),
          Expanded(child: Text(value, overflow: TextOverflow.ellipsis,style: const TextStyle(fontWeight: FontWeight.bold),)),
        ],
      ),
    );
  }
}