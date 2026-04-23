import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mahakal/features/profile/controllers/profile_contrroller.dart';
import 'package:provider/provider.dart';
import '../../../utill/app_constants.dart';
import '../../../utill/completed_order_dialog.dart';
import '../../../utill/razorpay_screen.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../custom_bottom_bar/bottomBar.dart';
import '../../location/controllers/location_controller.dart';
import '../controller/form_submission_controller.dart';
import '../controller/hotel_user_controller.dart';

class HotelForm extends StatefulWidget {
  dynamic grandTotal;
  String bookingCode = "";
  bool isDraft = false;
   HotelForm(this.grandTotal,this.bookingCode,this.isDraft,{super.key,});

  @override
  _HotelFormState createState() => _HotelFormState();
}

class _HotelFormState extends State<HotelForm> {
  final _formKey = GlobalKey<FormState>();
  final razorpayService = RazorpayPaymentService();

  // Form controllers
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressLine1Controller = TextEditingController();
  final TextEditingController _addressLine2Controller = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();
  final TextEditingController _zipController = TextEditingController();
  final TextEditingController _countryController = TextEditingController();
  final TextEditingController _specialRequirementController = TextEditingController();

  // Validation regex
  final RegExp _emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
  final RegExp _phoneRegex = RegExp(r'^(?:\+91|91|0)?[6-9][0-9]{9}$');
  final RegExp _zipRegex = RegExp(r'^[0-9]{5,6}$');

  @override
  void initState() {
    final profileUserController = Provider.of<ProfileController>(context, listen: false);
    final authUserController = Provider.of<AuthController>(context, listen: false);
    final locationUserController = Provider.of<LocationController>(context, listen: false);

    _firstNameController.text = profileUserController.userNAME;
    _lastNameController.text = profileUserController.userNAME;
    _emailController.text = profileUserController.userEMAIL;
    _phoneController.text = profileUserController.userPHONE;

    _cityController.text = authUserController.city!;
    _stateController.text = authUserController.state!;
    _countryController.text = authUserController.country!;
    _zipController.text = locationUserController.postalCode ?? '';
    print("ZIP Code:${_zipController.text}");

    super.initState();
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressLine1Controller.dispose();
    _addressLine2Controller.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _zipController.dispose();
    _countryController.dispose();
    _specialRequirementController.dispose();
    super.dispose();
  }

  void _submitForm() async {
   // if (!_formKey.currentState!.validate()) return;

    final controller = Provider.of<FormSubmissionController>(context, listen: false);

    // final success = await controller.fromSubmissionUser(
    //   context,
    //   _phoneController.text.trim(),
    //   _emailController.text.trim(),
    //   _lastNameController.text.trim(),
    //   _firstNameController.text.trim(),
    //   _addressLine1Controller.text.trim(),
    //   _cityController.text.trim(),
    //   _stateController.text.trim(),
    //   _zipController.text.trim(),
    //   _countryController.text.trim(),
    //   _specialRequirementController.text.trim(),
    //   widget.bookingCode,
    //   widget.isDraft
    // );

    //if (!mounted) return;
   // print("Form Submission status: ${success}");

   // if (success) {

      razorpayService.openCheckout(
        amount: widget.grandTotal, // ₹100
        razorpayKey: AppConstants.razorpayLive,
        onSuccess: (response) async{

          final success = await controller.fromSubmissionUser(
              context,
              _phoneController.text.trim(),
              _emailController.text.trim(),
              _lastNameController.text.trim(),
              _firstNameController.text.trim(),
              "",
              //_addressLine1Controller.text.trim(),
              _cityController.text.trim(),
              _stateController.text.trim(),
             "",
             // _zipController.text.trim(),
              _countryController.text.trim(),
              _specialRequirementController.text.trim(),
              widget.bookingCode,
              widget.isDraft
          );
          if (success)
          Navigator.of(context).pushReplacement(CupertinoPageRoute(builder: (BuildContext context) => const BottomBar(pageIndex: 0)));
          showDialog(
            context: context,
            builder: (context) => bookingSuccessDialog(
              context: context,
              tabIndex: 12,
              title: 'Hotel Booked!',
              message: 'If you want to open the order page then click OPEN.',
            ),
            barrierDismissible: true,
          );
        },
        onFailure: (response) {
          setState(() {
            //isPaymentProcessing = false;
          });
        },
        onExternalWallet: (response) {
          print("Wallet: ${response.walletName}");
        },
        description: 'Hotel Booking',
      );

   // }
  }

  Widget hotelBookingSuccessDialog({
    required BuildContext context,
    VoidCallback? onOpen,
    VoidCallback? onCancel,
  }) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      insetPadding: const EdgeInsets.symmetric(horizontal: 20),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            /// ✅ Success Icon
            Container(
              height: 90,
              width: 90,
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 60,
              ),
            ),

            const SizedBox(height: 20),

            /// ✅ Title
            const Text(
              "Booking Successful 🎉",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            /// ✅ Message
            const Text(
              "Your hotel booking has been confirmed.\nWe wish you a pleasant stay!",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),

            const SizedBox(height: 24),

            /// ✅ Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      if (onCancel != null) onCancel();
                    },
                    child: const Text("Cancel"),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      if (onOpen != null) onOpen();
                    },
                    child: const Text("Open"),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(onPressed: (){
          Navigator.pop(context);
        }, icon: Icon(Icons.arrow_back_ios)),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Booking Submission',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'Please fill in your details for booking',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Section
                // Container(
                //   padding: const EdgeInsets.all(10),
                //   margin: const EdgeInsets.only(bottom: 20),
                //   decoration: BoxDecoration(
                //     color: Colors.white,
                //     borderRadius: BorderRadius.circular(16),
                //     boxShadow: [
                //       BoxShadow(
                //         color: Colors.black.withOpacity(0.05),
                //         blurRadius: 15,
                //         offset: const Offset(0, 4),
                //       ),
                //     ],
                //   ),
                //   child: Row(
                //     children: [
                //       Container(
                //         width: 20,
                //         height: 20,
                //         decoration: BoxDecoration(
                //           gradient: LinearGradient(
                //             colors: [
                //               Colors.blue,
                //               Colors.blue.shade400,
                //             ],
                //             begin: Alignment.topLeft,
                //             end: Alignment.bottomRight,
                //           ),
                //           borderRadius: BorderRadius.circular(12),
                //         ),
                //         child: const Icon(
                //           Icons.person_outline_rounded,
                //           color: Colors.white,
                //           size: 18,
                //         ),
                //       ),
                //       const SizedBox(width: 16),
                //
                //     ],
                //   ),
                // ),

                // Form Fields Container
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Section Title
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            Container(
                              width: 4,
                              height: 20,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.blue,
                                    Colors.blue,
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Personal Details',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // First Name & Last Name Row
                      Row(
                        children: [
                          Expanded(
                            child: _buildTextField(
                              controller: _firstNameController,
                              label: 'First Name',
                              hintText: 'John',
                              prefixIcon: Icons.person_outline_rounded,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Please enter first name';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildTextField(
                              controller: _lastNameController,
                              label: 'Last Name',
                              hintText: 'Doe',
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Please enter last name';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Email & Phone Row
                      Row(
                        children: [
                          Expanded(
                            child: _buildTextField(
                              controller: _emailController,
                              label: 'Email Address',
                              hintText: 'john.doe@hotelapp.com',
                              prefixIcon: Icons.email_outlined,
                              keyboardType: TextInputType.emailAddress,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Please enter email';
                                }
                                if (!_emailRegex.hasMatch(value.trim())) {
                                  return 'Enter valid email address';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildTextField(
                              controller: _phoneController,
                              label: 'Phone Number',
                              hintText: '9876543210 or +919876543210',
                              prefixIcon: Icons.phone_outlined,
                              keyboardType: TextInputType.phone,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Please enter phone number';
                                }

                                if (!_phoneRegex.hasMatch(value.trim())) {
                                  return 'Enter valid mobile number';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),

                      // // Address Section
                      // const SizedBox(height: 20),
                      // Padding(
                      //   padding: const EdgeInsets.only(bottom: 8),
                      //   child: Row(
                      //     children: [
                      //       Container(
                      //         width: 4,
                      //         height: 20,
                      //         decoration: BoxDecoration(
                      //           gradient: LinearGradient(
                      //             colors: [
                      //               Colors.blue.shade600,
                      //               Colors.blue.shade400,
                      //             ],
                      //           ),
                      //           borderRadius: BorderRadius.circular(2),
                      //         ),
                      //       ),
                      //       const SizedBox(width: 12),
                      //       Text(
                      //         'Address Details',
                      //         style: TextStyle(
                      //           fontSize: 16,
                      //           fontWeight: FontWeight.w600,
                      //           color: Colors.black87,
                      //         ),
                      //       ),
                      //     ],
                      //   ),
                      // ),
                      //
                      // // Address Line 1
                      // _buildTextField(
                      //   controller: _addressLine1Controller,
                      //   label: 'Address Line 1',
                      //   hintText: '123 Main Street',
                      //   prefixIcon: Icons.home_outlined,
                      //   validator: (value) {
                      //     if (value == null || value.trim().isEmpty) {
                      //       return 'Please enter address';
                      //     }
                      //     return null;
                      //   },
                      // ),
                      //
                      // const SizedBox(height: 16),
                      //
                      // // Address Line 2 (Optional)
                      // _buildTextField(
                      //   controller: _addressLine2Controller,
                      //   label: 'Address Line 2 (Optional)',
                      //   hintText: 'Apartment, suite, building',
                      //   prefixIcon: Icons.apartment_outlined,
                      //   optional: true,
                      // ),
                      //
                      // const SizedBox(height: 20),
                      //
                      // // City, State, ZIP Row
                      // Row(
                      //   children: [
                      //     Expanded(
                      //       child: _buildTextField(
                      //         controller: _cityController,
                      //         label: 'City',
                      //         hintText: 'Mumbai',
                      //         prefixIcon: Icons.location_city_outlined,
                      //         validator: (value) {
                      //           if (value == null || value.trim().isEmpty) {
                      //             return 'Please enter city';
                      //           }
                      //           return null;
                      //         },
                      //       ),
                      //     ),
                      //     const SizedBox(width: 16),
                      //     Expanded(
                      //       child: _buildTextField(
                      //         controller: _stateController,
                      //         label: 'State',
                      //         hintText: 'Maharashtra',
                      //         prefixIcon: Icons.flag_outlined,
                      //         validator: (value) {
                      //           if (value == null || value.trim().isEmpty) {
                      //             return 'Please enter state';
                      //           }
                      //           return null;
                      //         },
                      //       ),
                      //     ),
                      //   ],
                      // ),
                      //
                      // const SizedBox(height: 20),
                      //
                      // Row(
                      //   children: [
                      //     Expanded(
                      //       child: _buildTextField(
                      //         controller: _zipController,
                      //         label: 'ZIP/Postal Code',
                      //         hintText: '400001',
                      //         prefixIcon: Icons.location_on_outlined,
                      //         validator: (value) {
                      //           if (value == null || value.trim().isEmpty) {
                      //             return 'Please enter ZIP';
                      //           }
                      //           if (!_zipRegex.hasMatch(value.trim())) {
                      //             return 'Invalid postal code';
                      //           }
                      //           return null;
                      //         },
                      //       ),
                      //     ),
                      //     const SizedBox(width: 16),
                      //     Expanded(
                      //       child: _buildTextField(
                      //         controller: _countryController,
                      //         label: 'Country',
                      //         hintText: 'India',
                      //         prefixIcon: Icons.public_outlined,
                      //         validator: (value) {
                      //           if (value == null || value.trim().isEmpty) {
                      //             return 'Please enter country';
                      //           }
                      //           return null;
                      //         },
                      //       ),
                      //     ),
                      //   ],
                      // ),

                      // Special Requirements
                      const SizedBox(height: 30),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.amber.shade50,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.amber.shade200,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: Colors.amber.shade100,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(
                                      Icons.star_outline_rounded,
                                      size: 18,
                                      color: Colors.amber.shade800,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    'Special Requirements',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.amber.shade900,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              TextFormField(
                                controller: _specialRequirementController,
                                maxLines: 4,
                                decoration: InputDecoration(
                                  hintText: 'Any special requests, dietary restrictions, accessibility needs, or other requirements?',
                                  hintStyle: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey[600],
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                      color: Colors.amber.shade300,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                      color: Colors.amber.shade500,
                                      width: 1.5,
                                    ),
                                  ),
                                  contentPadding: const EdgeInsets.all(16),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Optional - Please mention any special needs',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey[500],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Submit Button
                      const SizedBox(height: 32),
                      Consumer<FormSubmissionController>(
                        builder: (context, controller, _) {
                          return InkWell(
                            onTap: controller.isLoading ? null : _submitForm,
                            borderRadius: BorderRadius.circular(16),
                            child: Container(
                              height: 60,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: Colors.blue,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Center(
                                child: controller.isLoading
                                    ? const SizedBox(
                                  height: 24,
                                  width: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                )
                                    : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: const [
                                    Icon(
                                      Icons.check_circle_outline_rounded,
                                      color: Colors.white,
                                      size: 22,
                                    ),
                                    SizedBox(width: 10),
                                    Text(
                                      'SUBMIT INFORMATION',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 20),
                      Text(
                        'All fields marked with * are required',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hintText,
    IconData? prefixIcon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
    bool optional = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                ),
              ),
              if (!optional)
                TextSpan(
                  text: ' *',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Colors.red.shade500,
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.grey[300]!,
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            style: TextStyle(
              fontSize: 13,
              color: Colors.black87,
            ),
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: TextStyle(
                fontSize: 13,
                color: Colors.grey[500],
              ),
              border: InputBorder.none,
              prefixIcon: prefixIcon != null
                  ? Padding(
                padding: const EdgeInsets.only(left: 16, right: 12),
                child: Icon(
                  prefixIcon,
                  size: 19,
                  color: Colors.grey[600],
                ),
              )
                  : null,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
              errorStyle: TextStyle(
                fontSize: 11,
                color: Colors.red.shade600,
              ),
            ),
            validator: validator,
          ),
        ),
      ],
    );
  }
}