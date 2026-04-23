import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../Tickit_Booking/controller/activities_details_controller.dart';
import '../../../Tickit_Booking/view/tickit_booking_details.dart';
import '../../../hotels/controller/hotel_orderdetails_controller.dart';
import '../../../hotels/model/hotel_order_details_model.dart';

class HotelOrderDetailsScreen extends StatefulWidget {
  final String orderId;

  const HotelOrderDetailsScreen({Key? key, required this.orderId})
      : super(key: key);

  @override
  State<HotelOrderDetailsScreen> createState() =>
      _HotelOrderDetailsScreenState();
}

class _HotelOrderDetailsScreenState extends State<HotelOrderDetailsScreen> {
  var duration = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadOrderDetails();
    });

    Future.microtask(() async {
      context.read<ActivitiesDetailsController>().fetchActivityDetails("mamleshwar-omkareshwar-jyotirlinga-boating-ride-eNZYfh");
    });
  }

  Future<void> _loadOrderDetails() async {
    final controller =
        Provider.of<HotelOrderDetailsController>(context, listen: false);
    await controller.fetchHotelOrdersDetails(context, widget.orderId ?? '');
  }

  void showLocationBottomSheet(
    BuildContext context,
    String address,
    String lat,
    String lng,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => SizedBox(
        height: MediaQuery.of(context).size.height * 0.8,
        child: LocationMapScreen(
          address: address,
          lat: lat,
          lng: lng,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Order Details'),
        centerTitle: true,
        elevation: 0,
        leading: InkWell(
            onTap: () {
              Navigator.pop(context);
            },
            child: Icon(Icons.arrow_back_ios)),
      ),
      body: Consumer<HotelOrderDetailsController>(
        builder: (context, controller, child) {
          // Loading state
          if (controller.isLoading) {
            return const Center(
                child: CircularProgressIndicator(
              color: Colors.blue,
            ));
          }

          // Error or empty state
          if (controller.hotelOrderDetailModel == null ||
              controller.hotelOrderDetailModel?.booking == null) {
            return _buildEmptyState();
          }

          // Data loaded successfully
          return _buildOrderDetails(controller.hotelOrderDetailModel!);
        },
      ),
      bottomNavigationBar: Consumer<HotelOrderDetailsController>(
        builder: (BuildContext context, controller, Widget? child) {
          return Padding(
            padding: const EdgeInsets.all(10),
            child: buildViewMapButton(
              context: context,
              address:
                  controller.hotelOrderDetailModel?.booking?.service?.address ??
                      '',
              lat: controller.hotelOrderDetailModel?.booking?.service?.mapLat ??
                  '',
              lng: controller.hotelOrderDetailModel?.booking?.service?.mapLng ??
                  '',
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 24),
          const Text(
            'No Order Details Found',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Unable to load order details. Please try again.',
            style: TextStyle(color: Colors.grey),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _loadOrderDetails,
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderDetails(HotelOrderDetailModel orderDetail) {
    final booking = orderDetail.booking!;
    final service = booking.service;

    return RefreshIndicator(
      onRefresh: _loadOrderDetails,
      color: Colors.blue,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Booking Status Card
            _buildStatusCard(booking),
            const SizedBox(height: 16),

            // Hotel Details Card
            if (service != null) _buildHotelCard(service, booking.address ?? ''),
            if (service != null) const SizedBox(height: 16),

            // Guest Information Card
            _buildGuestInfoCard(booking),
            const SizedBox(height: 16),

            // Booking Dates Card
            _buildDatesCard(booking),
            const SizedBox(height: 16),

            // Price Breakdown Card
            _buildPriceCard(booking),
            const SizedBox(height: 16),

            // Policies Card
            if (service?.policy != null && service!.policy!.isNotEmpty)
              _buildPoliciesCard(service),
            if (service?.policy != null && service!.policy!.isNotEmpty)
              const SizedBox(height: 16),

            _buildSectionTitle('You Might Also Like', Icons.favorite_border),
            const SizedBox(height: 15),

            Consumer<ActivitiesDetailsController>(
              builder: (BuildContext context, activitiesDetailsController,
                  Widget? child) {
                return _buildRelatedItems(activitiesDetailsController);
              },
            ),

            // Action Buttons
            // buildViewMapButton(
            //   context: context,
            //   address: service?.address ?? '',
            //   lat: service?.mapLat ?? '',
            //   lng: service?.mapLng ?? '',
            // ),
            //_buildActionButtons(booking),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard(HotelBooking booking) {
    Color statusColor;
    IconData statusIcon;
    String statusText;

    switch (booking.status) {
      case 'partial_payment':
        statusColor = Colors.blue;
        statusIcon = Icons.payment;
        statusText = 'Partial Payment';
        break;
      case 'completed':
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        statusText = 'Completed';
        break;
      case 'pending':
        statusColor = Colors.blue;
        statusIcon = Icons.pending;
        statusText = 'Pending';
        break;
      case 'cancelled':
        statusColor = Colors.red;
        statusIcon = Icons.cancel;
        statusText = 'Cancelled';
        break;
      default:
        statusColor = Colors.grey;
        statusIcon = Icons.receipt;
        statusText = booking.status ?? 'Unknown';
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: statusColor.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: statusColor,
              shape: BoxShape.circle,
            ),
            child: Icon(statusIcon, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Order #${booking.code?.substring(0, 8) ?? 'N/A'}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: statusColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      statusText,
                      style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: statusColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${booking.paid ?? '0'}',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHotelCard(HotelService service, String address) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  image: const DecorationImage(
                    image: NetworkImage(
                      'https://images.unsplash.com/photo-1566073771259-6a8506099945?ixlib=rb-1.2.1&auto=format&fit=crop&w=1350&q=80',
                    ),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      service.title ?? 'Hotel Name',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.star, color: Colors.amber, size: 18),
                        const SizedBox(width: 4),
                        Text(
                          '${service.starRate ?? 0} • ${service.reviewScore ?? '0.0'}',
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _buildFeatureChip(
                icon: Icons.access_time,
                text: 'Check-in: ${service.checkInTime ?? 'N/A'}',
              ),
              _buildFeatureChip(
                icon: Icons.access_time_filled,
                text: 'Check-out: ${service.checkOutTime ?? 'N/A'}',
              ),
              if (service.starRate != null)
                _buildFeatureChip(
                  icon: Icons.star,
                  text: '${service.starRate} Star',
                ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.location_on,
                        color: Colors.red,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Destination",
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                           address ?? '',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),

                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureChip({required IconData icon, required String text}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.blue),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGuestInfoCard(HotelBooking booking) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.person_outline, color: Colors.blue, size: 22),
              SizedBox(width: 12),
              Text(
                'Guest Information',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildInfoRow(
            title: 'Full Name',
            value: '${booking.firstName} ${booking.lastName}',
          ),
          _buildInfoRow(
            title: 'Email',
            value: booking.email ?? 'N/A',
          ),
          _buildInfoRow(
            title: 'Phone',
            value: booking.phone ?? 'N/A',
          ),
          _buildInfoRow(
            title: 'Address',
            value: _formatAddress(booking),
          ),
          if (booking.customerNotes?.isNotEmpty == true)
            _buildInfoRow(
              title: 'Special Requests',
              value: booking.customerNotes!,
            ),
        ],
      ),
    );
  }

  String _formatAddress(HotelBooking booking) {
    List<String> parts = [];
    if (booking.address?.isNotEmpty == true) parts.add(booking.address!);
    if (booking.city?.isNotEmpty == true) parts.add(booking.city!);
    if (booking.state?.isNotEmpty == true) parts.add(booking.state!);
    if (booking.zipCode?.isNotEmpty == true) parts.add(booking.zipCode!);
    if (booking.country?.isNotEmpty == true) parts.add(booking.country!);
    return parts.join(', ');
  }

  Widget _buildInfoRow({required String title, required String value}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDatesCard(HotelBooking booking) {
    final startDate = booking.startDate != null
        ? DateTime.parse("${booking.startDate}")
        : DateTime.now();
    final endDate = booking.endDate != null
        ? DateTime.parse("${booking.endDate}")
        : DateTime.now().add(const Duration(days: 1));
    duration = endDate.difference(startDate).inDays;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.calendar_today, color: Colors.blue, size: 22),
              SizedBox(width: 12),
              Text(
                'Booking Dates',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildDateBox('Check-in', startDate),
              Container(
                width: 40,
                height: 1,
                color: Colors.grey[300],
                child: const Center(
                  child:
                      Icon(Icons.arrow_forward, size: 20, color: Colors.grey),
                ),
              ),
              _buildDateBox('Check-out', endDate),
            ],
          ),
          const SizedBox(height: 20),
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '$duration night${duration > 1 ? 's' : ''} stay',
                style: const TextStyle(
                  color: Colors.blue,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateBox(String label, DateTime date) {
    return Container(
      width: 130,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.blue,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            DateFormat('MMM dd, yyyy').format(date),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            DateFormat('EEEE').format(date),
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceCard(HotelBooking booking) {
    final service = booking.service;

    final int guestCount = booking.totalGuests ?? 0;

    final RoomBooking? room = booking.roomBooking;

    final List<ExtraPrice> extraPrices = service?.extraPrice ?? [];

    final List<ServicePrice> servicePrices = service?.serviceFee ?? [];

    final bool enableExtra = service?.enableExtraPrice == 1;

    final bool enableServiceFee = service?.enableServiceFee == 1;

    /// ================= ROOM TOTAL =================
    double roomTotal = 0;
    int totalDays = booking.objectModel == "space" ? duration : 1;

    if (room != null) {
      final double price = double.tryParse(room.price ?? "0") ?? 0;

      final int number = room.number ?? 1;

      if (room.startDate != null && room.endDate != null) {
        totalDays = room.endDate!.difference(room.startDate!).inDays;

        if (totalDays <= 0) totalDays = 1;
      }

      ///  FIXED (days added)
      roomTotal = price * number;
    }

    if (booking.objectModel == "space") {
      double price =
          double.tryParse(booking.service?.price.toString() ?? "0") ?? 0;
      roomTotal = price * duration;
    }

    /// ================= EXTRA TOTAL =================
    double extraTotal = 0;
    List<Widget> extraWidgets = [];

    if (enableExtra && extraPrices.isNotEmpty) {
      for (var extra in extraPrices) {
        final double price = double.tryParse(extra.price ?? "0") ?? 0;

        final String type = extra.type ?? "one_time";
        final bool perPerson = extra.perPerson == "on";

        double itemTotal = 0;
        String subtitle = "";

        if (type == "per_day") {
          itemTotal = price * totalDays;
          subtitle = "₹${price.toInt()} × $totalDays days";
        } else {
          itemTotal = price;
          subtitle = "One Time";
        }

        if (perPerson && guestCount > 0) {
          itemTotal *= guestCount;
          subtitle += " × $guestCount guests";
        }

        extraTotal += itemTotal;

        extraWidgets.add(
          _buildPriceRow(
            label: extra.name ?? "Extra",
            subtitle: subtitle,
            amount: itemTotal.toStringAsFixed(0),
          ),
        );
      }
    }

    /// ================= SERVICE FEE =================
    double serviceFeeTotal = 0;
    List<Widget> serviceWidgets = [];

    if (enableServiceFee && servicePrices.isNotEmpty) {
      final double percentBase = roomTotal + extraTotal;

      for (var serviceItem in servicePrices) {
        final double price = double.tryParse(serviceItem.price ?? "0") ?? 0;

        final String type = serviceItem.type ?? "one_time";

        final String unit = serviceItem.unit ?? "fixed";

        final bool perPerson = serviceItem.perPerson == "on";

        double itemTotal = 0;
        String subtitle = "";

        /// ===== PERCENT =====
        if (unit == "percent") {
          itemTotal = (percentBase * price) / 100;
          subtitle = "${price.toInt()}% of ₹${percentBase.toInt()}";
        }

        /// ===== FIXED =====
        else {
          if (type == "per_day") {
            itemTotal = price * totalDays;
            subtitle = "₹${price.toInt()} × $totalDays days";
          } else {
            itemTotal = price;
            subtitle = "One Time";
          }
        }

        if (perPerson && guestCount > 0) {
          itemTotal *= guestCount;
          subtitle += " × $guestCount guests";
        }

        serviceFeeTotal += itemTotal;

        serviceWidgets.add(
          _buildPriceRow(
            label: serviceItem.name ?? "Service",
            subtitle: subtitle,
            amount: itemTotal.toStringAsFixed(0),
          ),
        );
      }
    }

    /// ================= GRAND TOTAL =================
    final double totalPrice = roomTotal + extraTotal + serviceFeeTotal;

    /// ================= UI =================
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// HEADER
          Row(
            children: const [
              Icon(Icons.receipt_long, color: Colors.blue, size: 22),
              SizedBox(width: 10),
              Text(
                "Price Breakdown",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          /// ROOM
          _buildPriceRow(
            label: "Room Charges",
            subtitle: booking.objectModel == "space"
                ? "₹${booking.service?.price ?? "0"} × ${duration} days"
                : "₹${room?.price ?? "0"} × ${room?.number ?? 1} rooms",
            amount: roomTotal.toStringAsFixed(0),
          ),

          ...extraWidgets,
          ...serviceWidgets,

          const Divider(height: 30, thickness: 1.2),

          _buildPriceRow(
            label: "Total Amount",
            amount: totalPrice.toStringAsFixed(0),
            isHighlighted: true,
            isTotal: true,
          ),

          if (booking.status == "partial_payment")
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: _buildPriceRow(
                label: "Amount Due",
                amount: booking.payNow ?? "0",
                isHighlighted: true,
                isDue: true,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPriceRow({
    required String label,
    String? subtitle,
    required String amount,
    bool isHighlighted = false,
    bool isTotal = false,
    bool isDue = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// LEFT SIDE (Label + Subtitle)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// MAIN LABEL
                Text(
                  label,
                  style: TextStyle(
                    fontSize: isTotal ? 16 : 14,
                    fontWeight:
                        isHighlighted ? FontWeight.bold : FontWeight.w500,
                    color: isDue ? Colors.red : Colors.black87,
                  ),
                ),

                /// SUBTITLE (if exists)
                if (subtitle != null && subtitle.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
              ],
            ),
          ),

          /// RIGHT SIDE (Amount)
          Text(
            "₹$amount",
            style: TextStyle(
              fontSize: isTotal ? 16 : 14,
              fontWeight: isHighlighted ? FontWeight.bold : FontWeight.w600,
              color: isDue
                  ? Colors.red
                  : isTotal
                      ? Colors.blue
                      : Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPoliciesCard(HotelService service) {
    final policies = service.policy ?? [];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.policy, color: Colors.blue, size: 22),
              SizedBox(width: 12),
              Text(
                'Hotel Policies',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ...policies.map((policy) => _buildPolicyItem(policy)).toList(),
        ],
      ),
    );
  }

  Widget _buildPolicyItem(HotelPolicy policy) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            policy.title ?? 'Policy',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            policy.content ?? '',
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: Colors.blue, size: 20),
        ),
        SizedBox(width: 12),
        Text(
          title,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: Color(0xFF1A1A2E),
            letterSpacing: -0.5,
          ),
        ),
      ],
    );
  }

  Widget _buildRelatedItems(ActivitiesDetailsController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 12),
        SizedBox(
          height: 250,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 20),
            itemCount:
                controller.activityDetailsModel?.data?.remainingEvent.length ??
                    0,
            itemBuilder: (context, index) {
              final event =
                  controller.activityDetailsModel?.data?.remainingEvent[index];
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => TicketDetailsPage(
                                attractionName: '${event?.id}',
                                isEnglish: true,
                              )));
                },
                child: Container(
                  width: 180,
                  margin: EdgeInsets.only(right: 16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: Colors.white,
                    border: Border.all(color: Colors.grey.shade200, width: 1),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Image Container with overlay
                      Expanded(
                        flex: 3,
                        child: Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.vertical(
                                top: Radius.circular(20),
                              ),
                              child: event?.eventImage != null
                                  ? Image.network(
                                      event!.eventImage,
                                      fit: BoxFit.cover,
                                      width: double.infinity,
                                      height: double.infinity,
                                    )
                                  : Container(
                                      color: Colors.grey.shade100,
                                      child: Icon(
                                        Icons.event_available_outlined,
                                        size: 40,
                                        color: Colors.grey.shade400,
                                      ),
                                    ),
                            ),
                            // Price badge
                            Positioned(
                              top: 12,
                              left: 12,
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.blue,
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 4,
                                      offset: Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Text(
                                  '₹${event?.price ?? '0'}',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                            // Gradient overlay
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(20),
                                ),
                                gradient: LinearGradient(
                                  begin: Alignment.bottomCenter,
                                  end: Alignment.topCenter,
                                  colors: [
                                    Colors.black.withOpacity(0.3),
                                    Colors.transparent,
                                  ],
                                  stops: [0.1, 0.6],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Content
                      Expanded(
                        flex: 2,
                        child: Padding(
                          padding: EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    event?.enEventName ?? '',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF1A1A2E),
                                      height: 1.2,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),

                              // View Details Button
                              Container(
                                width: double.infinity,
                                height: 30,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: Colors.blue.shade50,
                                  border: Border.all(
                                    color: Colors.blue.shade100,
                                    width: 1,
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    'Book Now',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.blue,
                                    ),
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
              );
            },
          ),
        ),
        SizedBox(height: 20),
      ],
    );
  }

  Widget buildViewMapButton({
    required BuildContext context,
    required String address,
    required String lat,
    required String lng,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: GestureDetector(
        onTap: () {
          showLocationBottomSheet(
            context,
            address,
            lat,
            lng,
          );
        },
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFFF5722), Color(0xFFFF9100)],
            ),
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.blue.withOpacity(0.35),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(
                Icons.location_on,
                color: Colors.white,
                size: 22,
              ),
              SizedBox(width: 8),
              Text(
                "View on Map",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class LocationMapScreen extends StatefulWidget {
  final String lat;
  final String lng;
  final String address;

  const LocationMapScreen({
    super.key,
    required this.lat,
    required this.lng,
    required this.address,
  });

  @override
  State<LocationMapScreen> createState() => _LocationMapScreenState();
}

class _LocationMapScreenState extends State<LocationMapScreen> {
  GoogleMapController? mapController;
  LatLng? currentLocation;
  late LatLng destination;
  Set<Marker> markers = {};
  Set<Polyline> polylines = {};
  String distance = "";
  String duration = "";
  bool isMapReady = false;
  bool isRouteLoading = false;
  String? errorMessage;

  final String googleApiKey = "AIzaSyA9WZ75akgvEYdJiPK1UQIpYNhiuStGQhA";

  @override
  void initState() {
    super.initState();
    _parseDestination();
    getCurrentLocation();
  }

  void _parseDestination() {
    try {
      // Parse coordinates with proper error handling
      double lat = double.parse(widget.lat.trim());
      double lng = double.parse(widget.lng.trim());

      // Validate coordinates
      if (lat < -90 || lat > 90 || lng < -180 || lng > 180) {
        throw Exception('Invalid coordinates');
      }

      // Important: Make sure lat/lng are in correct order
      // Some APIs return "lat,lng" while others return "lng,lat"
      // Let's verify if the coordinates make sense for Ujjain
      // Ujjain is approximately at: 23.1765° N, 75.7885° E

      print('Parsed coordinates - Lat: $lat, Lng: $lng'); // Debug print

      // If the coordinates seem swapped (e.g., lat is ~75 and lng is ~23)
      // then we need to swap them
      if (lat > 100 && lng < 100) {
        // Looks like coordinates might be swapped
        print('⚠️ Coordinates might be swapped, swapping them...');
        double temp = lat;
        lat = lng;
        lng = temp;
      }

      destination = LatLng(lat, lng);
      print('Final destination - Lat: ${destination.latitude}, Lng: ${destination.longitude}');

    } catch (e) {
      print('Error parsing coordinates: $e');
      setState(() {
        errorMessage = 'Invalid coordinates provided';
      });
    }
  }

  @override
  void dispose() {
    mapController?.dispose();
    super.dispose();
  }

  Future<void> getCurrentLocation() async {
    // Check if location services are enabled
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() {
        errorMessage = 'Location services are disabled';
      });
      return;
    }

    LocationPermission permission = await Geolocator.requestPermission();

    if (permission == LocationPermission.denied) {
      setState(() {
        errorMessage = 'Location permission denied';
      });
      return;
    }

    if (permission == LocationPermission.deniedForever) {
      setState(() {
        errorMessage = 'Location permissions are permanently denied';
      });
      return;
    }

    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      setState(() {
        currentLocation = LatLng(position.latitude, position.longitude);
      });

      await calculateDistanceAndETA();
      await getRoute();

      setState(() {
        isMapReady = true;
      });

      // Animate camera to show both locations
      if (mapController != null && currentLocation != null) {
        animateToBounds();
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error getting location: $e';
      });
    }
  }

  Future<void> calculateDistanceAndETA() async {
    if (currentLocation == null || destination == null) return;

    double distanceMeters = Geolocator.distanceBetween(
      currentLocation!.latitude,
      currentLocation!.longitude,
      destination.latitude,
      destination.longitude,
    );

    double distanceKm = distanceMeters / 1000;

    // Format distance based on magnitude
    if (distanceKm < 1) {
      distance = "${(distanceMeters).toStringAsFixed(0)} m";
    } else {
      distance = "${distanceKm.toStringAsFixed(2)} km";
    }

    // ETA calculation based on average speed (40 km/h)
    double timeMinutes = (distanceKm / 40) * 60;
    if (timeMinutes < 1) {
      duration = "${(timeMinutes * 60).toStringAsFixed(0)} sec";
    } else if (timeMinutes < 60) {
      duration = "${timeMinutes.toStringAsFixed(0)} min";
    } else {
      double hours = timeMinutes / 60;
      double minutes = timeMinutes % 60;
      duration = "${hours.toStringAsFixed(0)}h ${minutes.toStringAsFixed(0)}m";
    }
  }

  Future<void> getRoute() async {
    if (currentLocation == null || destination == null) return;

    setState(() {
      isRouteLoading = true;
    });

    try {
      PolylinePoints polylinePoints = PolylinePoints();
      PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
        googleApiKey: googleApiKey,
        request: PolylineRequest(
          origin: PointLatLng(
            currentLocation!.latitude,
            currentLocation!.longitude,
          ),
          destination: PointLatLng(
            destination.latitude,
            destination.longitude,
          ),
          mode: TravelMode.driving,
        ),
      );

      if (result.points.isNotEmpty) {
        List<LatLng> routePoints = result.points
            .map((point) => LatLng(point.latitude, point.longitude))
            .toList();

        setState(() {
          polylines = {
            Polyline(
              polylineId: const PolylineId("route"),
              points: routePoints,
              color: Colors.blue,
              width: 6,
              patterns: [
                PatternItem.dash(20),
              ],
            ),
          };

          // Create markers with custom icons for better visibility
          markers = {
            Marker(
              markerId: const MarkerId("current"),
              position: currentLocation!,
              icon: BitmapDescriptor.defaultMarkerWithHue(
                BitmapDescriptor.hueAzure,
              ),
              infoWindow: const InfoWindow(title: "Your Location"),
            ),
            Marker(
              markerId: const MarkerId("destination"),
              position: destination,
              icon: BitmapDescriptor.defaultMarkerWithHue(
                BitmapDescriptor.hueRed,
              ),
              infoWindow: InfoWindow(
                title: "Destination",
                snippet: widget.address,
              ),
            ),
          };
        });
      } else {
        print('No route points found');
      }
    } catch (e) {
      print('Error getting route: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading route: $e')),
      );
    } finally {
      setState(() {
        isRouteLoading = false;
      });
    }
  }

  void animateToBounds() {
    if (currentLocation == null || mapController == null || destination == null) return;

    // Create bounds that include both current location and destination
    double southLat = min(currentLocation!.latitude, destination.latitude);
    double northLat = max(currentLocation!.latitude, destination.latitude);
    double westLng = min(currentLocation!.longitude, destination.longitude);
    double eastLng = max(currentLocation!.longitude, destination.longitude);

    // Add some padding
    southLat = southLat - 0.01;
    northLat = northLat + 0.01;
    westLng = westLng - 0.01;
    eastLng = eastLng + 0.01;

    LatLngBounds bounds = LatLngBounds(
      southwest: LatLng(southLat, westLng),
      northeast: LatLng(northLat, eastLng),
    );

    mapController!.animateCamera(
      CameraUpdate.newLatLngBounds(bounds, 100),
    );
  }

  void centerOnCurrentLocation() {
    if (currentLocation != null && mapController != null) {
      mapController!.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: currentLocation!,
            zoom: 16,
          ),
        ),
      );
    }
  }

  void centerOnDestination() {
    if (mapController != null && destination != null) {
      mapController!.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: destination,
            zoom: 16,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Show error if any
    if (errorMessage != null) {
      return Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  color: Colors.red,
                  size: 48,
                ),
                const SizedBox(height: 16),
                Text(
                  errorMessage!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      errorMessage = null;
                    });
                    getCurrentLocation();
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (currentLocation == null || !isMapReady) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text(
                isRouteLoading ? "Getting route..." : "Loading map...",
                style: const TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: currentLocation!,
              zoom: 14,
            ),
            onMapCreated: (controller) {
              mapController = controller;
              animateToBounds();
            },
            markers: markers,
            polylines: polylines,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            compassEnabled: true,
            mapToolbarEnabled: true,
            trafficEnabled: false,
            buildingsEnabled: true,
            indoorViewEnabled: true,
            zoomGesturesEnabled: true,
            scrollGesturesEnabled: true,
            rotateGesturesEnabled: true,
            tiltGesturesEnabled: true,
          ),

          // Top Info Card
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            left: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.location_on,
                          color: Colors.red,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Destination",
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              widget.address,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),

                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.blue.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.directions_car,
                              color: Colors.blue,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Distance",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                              Text(
                                distance,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.blue.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.access_time,
                              color: Colors.blue,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "ETA",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                              Text(
                                duration,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Control Buttons
          Positioned(
            bottom: MediaQuery.of(context).padding.bottom + 20,
            right: 16,
            child: Column(
              children: [
                // Recenter button
                FloatingActionButton(
                  heroTag: "recenter",
                  mini: true,
                  onPressed: centerOnCurrentLocation,
                  backgroundColor: Colors.white,
                  child: const Icon(
                    Icons.my_location,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(height: 10),

                // Zoom in button
                FloatingActionButton(
                  heroTag: "zoomin",
                  mini: true,
                  onPressed: () => mapController?.animateCamera(
                    CameraUpdate.zoomIn(),
                  ),
                  backgroundColor: Colors.white,
                  child: const Icon(
                    Icons.add,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 10),

                // Zoom out button
                FloatingActionButton(
                  heroTag: "zoomout",
                  mini: true,
                  onPressed: () => mapController?.animateCamera(
                    CameraUpdate.zoomOut(),
                  ),
                  backgroundColor: Colors.white,
                  child: const Icon(
                    Icons.remove,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),

          // Show Both Locations Button
          Positioned(
            bottom: MediaQuery.of(context).padding.bottom + 20,
            left: 16,
            child: FloatingActionButton(
              heroTag: "showboth",
              mini: true,
              onPressed: animateToBounds,
              backgroundColor: Colors.white,
              child: const Icon(
                Icons.fullscreen,
                color: Colors.blue,
              ),
            ),
          ),

          // Loading indicator for route
          if (isRouteLoading)
            Positioned(
              top: MediaQuery.of(context).padding.top + 100,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      SizedBox(width: 12),
                      Text("Loading route..."),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}