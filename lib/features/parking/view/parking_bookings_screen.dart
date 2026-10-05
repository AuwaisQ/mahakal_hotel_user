import 'package:flutter/material.dart';
import 'package:mahakal/features/parking/controller/parking_controller.dart';
import 'package:mahakal/features/parking/model/parking_order_model.dart';
import 'package:mahakal/features/parking/view/parking_order_details_screen.dart';
import 'package:provider/provider.dart';

class ParkingBookingsScreen extends StatelessWidget {
  const ParkingBookingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.blue,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
            style: IconButton.styleFrom(
              backgroundColor: Colors.white.withOpacity(0.2),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
        title: const Text(
          'My Parking Bookings',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.white),
        ),
      ),
      body: Consumer<ParkingController>(
        builder: (context, controller, child) {
          if (controller.isLoading && controller.parkingOrderList.isEmpty) {
            return const Center(child: CircularProgressIndicator(color: Colors.blueAccent));
          }

          if (controller.parkingOrderList.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.history_rounded, size: 60, color: Colors.grey.shade300),
                  const SizedBox(height: 16),
                  const Text(
                    "No bookings found",
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => controller.getParkingOrderList(),
            color: Colors.blue,
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              itemCount: controller.parkingOrderList.length,
              itemBuilder: (context, index) {
                final order = controller.parkingOrderList[index];
                return _buildBookingCard(context, order);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildBookingCard(BuildContext context, ParkingOrder order) {
    bool isPending = order.status?.toLowerCase() == 'pending';
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ParkingOrderDetailsScreen(orderId: order.id ?? 0),
              ),
            );
          },
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(
                    order.cabName?.toLowerCase().contains('bike') == true ? Icons.pedal_bike : Icons.directions_car,
                    color: Colors.blue,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              order.parkingName ?? "Parking Spot",
                              style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: isPending ? Colors.blue.shade50 : Colors.green.shade50,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              order.status?.toUpperCase() ?? "N/A",
                              style: TextStyle(
                                color: isPending ? Colors.blue.shade700 : Colors.green.shade700,
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        "${order.cabName?.toUpperCase()} • ${order.cabRegisterNumber?.toUpperCase()}",
                        style: TextStyle(color: Colors.grey.shade600, fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Icon(Icons.calendar_today_rounded, size: 12, color: Colors.grey.shade400),
                          const SizedBox(width: 6),
                          Text(
                            "${order.arrivalTime}",
                            style: TextStyle(color: Colors.grey.shade500, fontSize: 11, fontWeight: FontWeight.w500),
                          ),
                        ],
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
}
