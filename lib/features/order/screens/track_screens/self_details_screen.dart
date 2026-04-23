// screens/cab_booking_details_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../../main.dart';
import '../../../../utill/app_constants.dart';
import '../../../auth/controllers/auth_controller.dart';
import '../../model/self_drive_details_model.dart';
import 'package:http/http.dart' as http;


class CabBookingDetailsScreen extends StatefulWidget {
  final String id;

  const CabBookingDetailsScreen({
    super.key,
    required this.id,
  });

  @override
  State<CabBookingDetailsScreen> createState() => _CabBookingDetailsScreenState();
}

class _CabBookingDetailsScreenState extends State<CabBookingDetailsScreen> {
  bool _isExpanded = false;

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.blue;
      case 'confirmed':
        return Colors.green;
      case 'completed':
        return Colors.blue;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String convertDate(String? date) {
    if (date == null || date.isEmpty) {
      return 'Invalid date'; // Or any default message you prefer
    }

    try {
      final dateTime = DateFormat('yyyy-MM-dd').parse(date);
      final formattedDate = DateFormat('dd-MMMM-yyyy').format(dateTime);
      return formattedDate;
    } catch (e) {
      return 'Invalid format'; // Handle parsing errors
    }
  }

  String _formatDate(String dateTimeString) {
    try {
      if (dateTimeString.isEmpty) return 'Not scheduled';
      // Parse the date string (format: "02-02-2026 02:50 PM")
      final parts = dateTimeString.split(' ');
      if (parts.length >= 3) {
        final dateParts = parts[0].split('-');
        if (dateParts.length == 3) {
          final day = int.parse(dateParts[0]);
          final month = int.parse(dateParts[1]);
          final year = int.parse(dateParts[2]);
          final time = parts[1];
          final period = parts[2];

          final date = DateTime(year, month, day);
          return '${DateFormat('dd MMM yyyy').format(date)} at $time $period';
        }
      }
      return dateTimeString;
    } catch (e) {
      return dateTimeString;
    }
  }

  CabBookingModel? bookingData;

  Future<void> fetchSelfDrive() async {
    String userToken = Provider.of<AuthController>(Get.context!, listen: false).getUserToken();
    final response = await http.get(Uri.parse('${AppConstants.baseUrl}/api/v1/self-vehicle/order-details/${widget.id}'),
      headers: {
        'Authorization': 'Bearer $userToken',
        'Content-Type': 'application/json',
      },
    );
    print('Api response self driver ${response.body}');
    if (response.statusCode == 200) {
      setState(() {
        bookingData = cabBookingModelFromJson(response.body);
      });
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchSelfDrive();
  }

  @override
  Widget build(BuildContext context) {
    final data = bookingData?.data;

    return data == null ? Container(
        color: Colors.white,
        child: Center(child: CircularProgressIndicator(color: Colors.blue,))) : Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.grey.shade50,
        title: Column(
          children: [
            Text.rich(TextSpan(children: [
              const TextSpan(
                  text: 'Order -',
                  style: TextStyle(color: Colors.black, fontSize: 18)),
              TextSpan(
                  text: ' #${data?.orderId}',
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
                  text: ' Your Order is - ',
                  style: TextStyle(color: Colors.black, fontSize: 18)),
              TextSpan(
                  text: '${data?.orderStatus}',
                  style: TextStyle(
                      color: _getStatusColor(
                          '${data?.orderStatus}'),
                      fontSize: 20,
                      fontWeight: FontWeight.bold)),
            ])),
            const SizedBox(
              height: 5,
            ),
            Text(convertDate('${00-00-0000}'),
                style: const TextStyle(
                    fontSize: 18,
                    overflow: TextOverflow.ellipsis,
                    color: Colors.black)),
          ],
        ),
        centerTitle: true,
        toolbarHeight: 100,
      ),
      body: data == null ? CircularProgressIndicator(color: Colors.white,) : SingleChildScrollView(
        child: Column(
          children: [
            // Status Banner
            // Container(
            //   width: double.infinity,
            //   padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            //   color: _getStatusColor('${data.orderStatus}').withOpacity(0.1),
            //   child: Row(
            //     children: [
            //       Container(
            //         padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            //         decoration: BoxDecoration(
            //           color: _getStatusColor('${data.orderStatus}'),
            //           borderRadius: BorderRadius.circular(20),
            //         ),
            //         child: Text(
            //           data.orderStatus!.toUpperCase(),
            //           style: TextStyle(
            //             color: Colors.white,
            //             fontWeight: FontWeight.bold,
            //             fontSize: 12,
            //           ),
            //         ),
            //       ),
            //       SizedBox(width: 12),
            //       Expanded(
            //         child: Text(
            //           'Order ID: ${data.orderId}',
            //           style: TextStyle(
            //             fontWeight: FontWeight.w500,
            //             color: Colors.grey[700],
            //           ),
            //         ),
            //       ),
            //     ],
            //   ),
            // ),

            // Main Content
            Padding(
              padding: EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Cab Info Card
                  _buildCabInfoCard(data),
                  SizedBox(height: 10),

                  // Trip Details Card
                  _buildTripDetailsCard(data),
                  SizedBox(height: 10),

                  // Customer Info Card
                  _buildCustomerInfoCard(data),
                  SizedBox(height: 10),

                  // OTP & Security Card
                  _buildOTPAndSecurityCard(data),
                  SizedBox(height: 10),

                  // Pricing Card
                  _buildPricingCard(data),
                  SizedBox(height: 10),

                  // Action Buttons
                  // _buildActionButtons(data),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCabInfoCard(Data data) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            children: [

              /// 🚗 CAB IMAGE
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Stack(
                  children: [
                    Image.network(
                      data.thumbnail ?? '',
                      width: 140,
                      height: 90,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 140,
                          height: 90,
                          color: Colors.grey[200],
                          child: const Icon(
                            Icons.directions_car,
                            size: 40,
                            color: Colors.grey,
                          ),
                        );
                      },
                    ),

                    /// 🔥 Small Gradient Overlay
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        height: 30,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.black.withOpacity(0.6),
                              Colors.transparent,
                            ],
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 16),

              /// 📄 CAB DETAILS
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    /// Cab Name
                    Text(
                      data.cabName ?? '',
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.3,
                      ),
                    ),

                    const SizedBox(height: 6),

                    /// Service Name
                    Text(
                      data.serviceName ?? '',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 13,
                      ),
                    ),

                    const SizedBox(height: 10),

                    /// AC / Non AC Badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: data.bookingCabAc == 'AC'
                              ? [Colors.grey.shade400, Colors.grey.shade600]
                              : [Colors.blue.shade400, Colors.blue.shade600]
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            data.bookingCabAc == 'AC'
                                ? Icons.ac_unit
                                : Icons.air,
                            size: 14,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            data.bookingCabAc?.isNotEmpty == true
                                ? data.bookingCabAc!
                                : 'AC',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
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
  }


  Widget _buildTripDetailsCard(Data data) {
    return Card(
      elevation: 4,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: const [
                Icon(Icons.route, color: Colors.blue),
                SizedBox(width: 8),
                Text(
                  'Trip Details',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            /// ---------------- PICKUP ----------------
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children: [
                    CircleAvatar(
                      radius: 12,
                      backgroundColor: Colors.green.withOpacity(0.15),
                      child: const Icon(
                        Icons.radio_button_checked,
                        color: Colors.green,
                        size: 16,
                      ),
                    ),
                    Container(
                      height: 40,
                      width: 2,
                      color: Colors.grey.shade300,
                    ),
                  ],
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'PICKUP',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.8,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${data.pickupAddress}',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(Icons.calendar_today,
                              size: 14, color: Colors.blue),
                          const SizedBox(width: 6),
                          Text(
                            _formatDate('${data.pickupDate}'),
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.blue.shade700,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      if (data.bookingPickKm!.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            'Pickup KM: ${data.bookingPickKm}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),

            /// ---------------- DROP / RETURN ----------------
            if (data.dropAddress != null || data.returnAddress!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 12,
                      backgroundColor: Colors.blue.withOpacity(0.15),
                      child: const Icon(
                        Icons.location_on,
                        color: Colors.blue,
                        size: 16,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            data.dropAddress != null ? 'DROP' : 'RETURN',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.8,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            data.dropAddress ?? data.returnAddress,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          if (data.returnDate!.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 6),
                              child: Row(
                                children: [
                                  const Icon(Icons.calendar_today,
                                      size: 14, color: Colors.blue),
                                  const SizedBox(width: 6),
                                  Text(
                                    _formatDate('${data.returnDate}'),
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.blue.shade700,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          if (data.bookingReturnKm!.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 6),
                              child: Text(
                                'Return KM: ${data.bookingReturnKm}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                ),
                              ),
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
    );
  }

  Widget _buildCustomerInfoCard(Data data) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              /// 🔷 Header
              Row(
                children: const [
                  Icon(Icons.account_circle, color: Colors.blue),
                  SizedBox(width: 8),
                  Text(
                    'Customer Information',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 18),

              _buildModernInfoRow(Icons.person, 'Name', data.userName ?? ''),
              _buildStyledDivider(),

              if (data.age?.isNotEmpty == true) ...[
                _buildModernInfoRow(Icons.cake, 'Age', data.age!),
                _buildStyledDivider(),
              ],

              _buildModernInfoRow(Icons.phone, 'Phone', data.phoneNumber ?? ''),
              _buildStyledDivider(),

              _buildModernInfoRow(Icons.email, 'Email', data.email ?? ''),
            ],
          ),
        ),
      ),
    );
  }


  Widget _buildOTPAndSecurityCard(Data data) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'OTP & Security',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),

            // Pickup OTP
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Pickup OTP',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                      SizedBox(height: 4),
                      Text('${data.pickupOtp}',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                          color: Colors.blue[800],
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: data.pickupStatus == 1 ? Colors.green : Colors.blue,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      data.pickupStatus == 1 ? 'Verified' : 'Pending',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 12),

            // Drop OTP
            if(data.pickupOtp == 1)
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Drop OTP',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                      SizedBox(height: 4),
                        Text('${data.dropOtp}',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                          color: Colors.green[800],
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: data.dropStatus == 1 ? Colors.green : Colors.blue,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      data.dropStatus == 1 ? 'Verified' : 'Pending',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            if (data.securityDeposit! > 0) ...[
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Security Deposit',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    '₹${data.securityDeposit!.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[800],
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPricingCard(Data data) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Price Details',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _isExpanded = !_isExpanded;
                    });
                  },
                  child: Text(_isExpanded ? 'Show Less' : 'View Details'),
                ),
              ],
            ),

            // Basic price row
            _buildPriceRow('Subtotal', data.subAmount!),

            if (_isExpanded) ...[
              if (data.couponAmount! > 0)
                _buildPriceRow('Coupon Discount', data.couponAmount!),
              if (data.taxAmount! > 0)
                _buildPriceRow('Tax (${data.tax}%)', data.taxAmount!),
              if (data.securityAmount! > 0)
                _buildPriceRow('Security Amount', data.securityAmount!),
              Divider(height: 24),
            ],

            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total Amount',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '₹${data.finalAmount!.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[800],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(Data data) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: () {
              // View invoice
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.blue,
              side: BorderSide(color: Colors.blue),
              padding: EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text('VIEW INVOICE'),
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: ElevatedButton(
            onPressed: () {
              // Contact support
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              padding: EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text('CONTACT SUPPORT'),
          ),
        ),
      ],
    );
  }

  Widget _buildModernInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: Colors.blue),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStyledDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Divider(
        thickness: 1,
        color: Colors.grey.shade200,
      ),
    );
  }
  Widget _buildPriceRow(String label, num amount,
      {bool highlight = false, bool isTotal = false}) {
    final bool isNegative = amount < 0;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: highlight
            ? Colors.blue.withOpacity(0.06)
            : Colors.grey.withOpacity(0.04),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: highlight
              ? Colors.blue.withOpacity(0.3)
              : Colors.grey.withOpacity(0.15),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          /// LABEL
          Row(
            children: [
              Icon(
                isNegative ? Icons.discount_outlined : Icons.receipt_long,
                size: 18,
                color: isNegative ? Colors.green : Colors.grey[700],
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: isTotal ? 15 : 14,
                  fontWeight: isTotal ? FontWeight.w700 : FontWeight.w500,
                  color: Colors.grey[800],
                ),
              ),
            ],
          ),

          /// AMOUNT
          Text(
            '${isNegative ? '-' : ''}₹${amount.abs().toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: isTotal ? 16 : 14,
              fontWeight: FontWeight.bold,
              color: isNegative
                  ? Colors.green
                  : (highlight ? Colors.blue : Colors.black87),
            ),
          ),
        ],
      ),
    );
  }

}