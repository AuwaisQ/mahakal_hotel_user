import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import '../../order/screens/track_screens/track_hotel_orderdetails.dart';
import '../controller/hotel_orders_controller.dart';

class HotelOrderListScreen extends StatefulWidget {

  final ScrollController? scrollController;

   HotelOrderListScreen({super.key,this.scrollController,});

  @override
  State<HotelOrderListScreen> createState() => _HotelOrderListScreenState();
}

class _HotelOrderListScreenState extends State<HotelOrderListScreen> {

  @override
  void initState() {
    super.initState();
    // Use WidgetsBinding to avoid calling Provider during build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchOrders();
    });
  }

  Future<void> _fetchOrders() async {
    if (!mounted) return;
    final orderController = Provider.of<HotelOrderController>(context, listen: false);
    await orderController.fetchHotelOrders(context);
  }

  Widget buildOrderDesign({
    required String image,
    required String name,
    required Color color,
    required String date,
    required String price,
    required String orderId,
    required String status,
    String subscriptionId = "",
    String Ordertype = "",
    String? type,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: Colors.grey.shade200, width: 1),
      ),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Image Section with Stack for Badge
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.deepOrange.shade200, width: 1),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(7),
                    child: Image.network(
                      image,
                      width: 90,
                      height: 70,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        width: 90,
                        height: 70,
                        color: Colors.grey.shade100,
                        child: Icon(
                          Icons.hotel,
                          color: Colors.deepOrange.shade300,
                          size: 30,
                        ),
                      ),
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          width: 90,
                          height: 70,
                          color: Colors.grey.shade100,
                          child: Center(
                            child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes!
                                  : null,
                              strokeWidth: 2,
                              color: Colors.deepOrange,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),

                /// Type Badge on Image (if type exists)
                if (type != null && type.isNotEmpty)
                  Positioned(
                    top: -5,
                    right: -5,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.deepOrange,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white, width: 1.5),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.deepOrange.withOpacity(0.3),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        type.toUpperCase().replaceAll("_", " "),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),

            const SizedBox(width: 12),

            /// Text Section
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  /// Name with Subscription Badge
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          name,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),

                      /// Subscription Verified Badge
                      if (Ordertype == "donation" && subscriptionId != "one_time")
                        Container(
                          margin: const EdgeInsets.only(left: 4),
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: Colors.green,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 1),
                          ),
                          child: const Icon(
                            Icons.verified,
                            size: 12,
                            color: Colors.white,
                          ),
                        ),
                    ],
                  ),

                  const SizedBox(height: 4),

                  /// Order ID
                  Row(
                    children: [
                      Icon(Icons.receipt_outlined, size: 12, color: Colors.grey.shade500),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          '#$orderId',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 11,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 2),

                  /// Date
                  Row(
                    children: [
                      Icon(Icons.calendar_today, size: 10, color: Colors.grey.shade500),
                      const SizedBox(width: 4),
                      Text(
                        formatBookingDate(date),
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 6),

                  /// Price and Status
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      /// Price with border
                      Text(
                        price == "0" || price == "0.0"
                            ? "Free"
                            : '₹ ${double.parse(price).toStringAsFixed(0)}',
                        style: const TextStyle(
                          color: Colors.deepOrange,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),

                      /// Status Badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.1),
                          border: Border.all(color: color, width: 0.5),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          status.toUpperCase(),
                          style: TextStyle(
                            color: color,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.3,
                          ),
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
    );
  }

  // Helper function for date formatting (add this in your class)
  String formatBookingDate(String date) {
    try {
      final DateTime parsedDate = DateTime.parse(date);
      return '${parsedDate.day}/${parsedDate.month}/${parsedDate.year}';
    } catch (e) {
      return date;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text(
          'My Bookings',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.deepOrange,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        foregroundColor: Colors.deepOrange,
      ),
      body: Consumer<HotelOrderController>(
        builder: (context, controller, child) {
          if (controller.isLoading) {
            // Shimmer Loading Effect
            return ListView.builder(
              itemCount: 10,
              padding: EdgeInsets.all(12),
              itemBuilder: (context, index) {
                return Shimmer.fromColors(
                  baseColor: Colors.grey.shade300,
                  highlightColor: Colors.grey.shade100,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    height: 140,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                );
              },
            );
          }

          if (controller.hotelOrderList.isEmpty) {

            // Empty State
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.hotel_outlined,
                    size: 80,
                    color: Colors.deepOrange.shade200,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No Orders Yet',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.deepOrange.shade700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Your hotel bookings will appear here',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            );
          }

          // Hotel Order List
          return RefreshIndicator(
            color: Colors.deepOrange,
            onRefresh: _fetchOrders,
            child: ListView.builder(
              controller: widget.scrollController,
              itemCount: controller.hotelOrderList.length,
              itemBuilder: (context, index) {
                final order = controller.hotelOrderList[index];

                return InkWell(
                  onTap: (){
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => HotelOrderDetailsScreen(
                              orderId: '${order.code}',
                            )));
                  },
                  child: buildOrderDesign(
                      image: '',
                      name: order.firstName ?? '',
                      color: order.status == 'paid' ? Colors.green : Colors.red,
                      date: '${order.createdAt}',
                      price: order.paid ?? '',
                      orderId: order.objectModel.toUpperCase() ?? '',
                      status: order.status ?? '',
                    ),
                );
                },
            ),
          );
        },
      ),
    );
  }
}