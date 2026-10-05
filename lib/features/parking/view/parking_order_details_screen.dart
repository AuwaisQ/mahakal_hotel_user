import 'package:flutter/material.dart';
import 'package:mahakal/features/parking/controller/parking_controller.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class ParkingOrderDetailsScreen extends StatefulWidget {
  final int orderId;

  const ParkingOrderDetailsScreen({super.key, required this.orderId});

  @override
  State<ParkingOrderDetailsScreen> createState() => _ParkingOrderDetailsScreenState();
}

class _ParkingOrderDetailsScreenState extends State<ParkingOrderDetailsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ParkingController>(context, listen: false).getParkingOrderDetails(widget.orderId);
    });
  }

  Future<void> _openGoogleMaps(String? lat, String? long) async {
    if (lat == null || long == null || lat.isEmpty || long.isEmpty) return;
    final Uri googleUrl = Uri.parse('https://www.google.com/maps/search/?api=1&query=$lat,$long');
    if (await canLaunchUrl(googleUrl)) {
      await launchUrl(googleUrl, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFE65100), Color(0xFFFF8A65)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: const Text(
          'Booking Details',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 1),
        ),
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: InkWell(
            onTap: () => Navigator.pop(context),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 18),
            ),
          ),
        ),
      ),
      body: Consumer<ParkingController>(
        builder: (context, controller, child) {
          if (controller.isLoading) {
            return const Center(child: CircularProgressIndicator(color: Colors.blue));
          }

          final order = controller.orderDetails;
          if (order == null) {
            return const Center(child: Text("Details not found"));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // Ticket with QR Code
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      )
                    ],
                  ),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          children: [
                            if (order.qrcode != null && order.qrcode!.isNotEmpty) ...[
                              QrImageView(
                                data: order.qrcode!,
                                version: QrVersions.auto,
                                size: 180.0,
                                foregroundColor: Colors.black87,
                              ),
                              const SizedBox(height: 10),
                              Text(
                                order.qrcode!,
                                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16, letterSpacing: 2),
                              ),
                              const SizedBox(height: 5),
                              const Text(
                                "Show this QR code at the entrance",
                                style: TextStyle(color: Colors.grey, fontSize: 12),
                              ),
                            ] else ...[
                              const Icon(Icons.qr_code_2, size: 150, color: Colors.grey),
                              const Text("QR Code not available"),
                            ],
                          ],
                        ),
                      ),
                      
                      // Dashed line
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          children: List.generate(
                              30,
                              (index) => Expanded(
                                    child: Container(
                                      color: index % 2 == 0 ? Colors.transparent : Colors.grey.shade300,
                                      height: 1,
                                    ),
                                  )),
                        ),
                      ),

                      Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          children: [
                            _detailRow("Parking Location", order.parkingName ?? "N/A"),
                            const SizedBox(height: 15),
                            _detailRow("Vehicle", "${order.cabName} (${order.cabRegisterNumber})"),
                            const SizedBox(height: 15),
                            _detailRow("Arrival Time", order.arrivalTime ?? "N/A"),
                            const SizedBox(height: 15),
                            _detailRow("Departure Time", order.depatureTime ?? "N/A"),
                            const SizedBox(height: 15),
                            _detailRow("Status", order.status?.toUpperCase() ?? "N/A", 
                              valueColor: order.status?.toLowerCase() == 'pending' ? Colors.blue : Colors.green),
                            const SizedBox(height: 15),
                            _detailRow("Total Amount", "₹${order.amount}", isBold: true, valueColor: Colors.blue),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 30),
                
                // Navigate Button
                if (order.parkingLat != null && order.parkingLong != null)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _openGoogleMaps(order.parkingLat, order.parkingLong),
                    icon: const Icon(Icons.directions),
                    label: const Text("Navigate to Parking"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _detailRow(String label, String value, {bool isBold = false, Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: Colors.grey.shade600, fontSize: 13, fontWeight: FontWeight.w500)),
        Text(
          value,
          style: TextStyle(
            fontWeight: isBold ? FontWeight.w900 : FontWeight.w700,
            fontSize: 14,
            color: valueColor ?? Colors.black87,
          ),
        ),
      ],
    );
  }
}
