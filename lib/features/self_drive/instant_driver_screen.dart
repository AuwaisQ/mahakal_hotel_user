import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../data/datasource/remote/http/httpClient.dart';

class DriverFoundScreen extends StatefulWidget {
  final Map<String, dynamic>? orderData;

  const DriverFoundScreen({super.key, required this.orderData});

  @override
  State<DriverFoundScreen> createState() => _DriverFoundScreenState();
}

class _DriverFoundScreenState extends State<DriverFoundScreen> {

  Map<String, dynamic>? orderData;

  @override
  void initState() {
    super.initState();
    orderData = widget.orderData;
    loadCustomMarker();
  }

  BitmapDescriptor? driverIcon;

  void loadCustomMarker() async {
    driverIcon = await getResizedMarker(
      'assets/planet/driver_bike.png',
      120, // 👈 size control (try 60–100)
    );
    setState(() {});
  }
  Future<BitmapDescriptor> getResizedMarker(String path, int width) async {
    final ByteData data = await rootBundle.load(path);
    final codec = await ui.instantiateImageCodec(
      data.buffer.asUint8List(),
      targetWidth: width, // 👈 yaha size control hota hai
    );
    final frame = await codec.getNextFrame();
    final byteData =
    await frame.image.toByteData(format: ui.ImageByteFormat.png);

    return BitmapDescriptor.fromBytes(byteData!.buffer.asUint8List());
  }
  // /// ✅ API CALL
  // Future<void> getOrderDetails() async {
  //   String url =
  //       '/api/v1/self-vehicle/get-order-information/${widget.orderId}';
  //
  //   var res = await HttpService().getApi(url);
  //
  //   print("Driver Details Response: $res");
  //
  //   if (res['status'] == 1) {
  //     orderData = res['data'];
  //   }
  //
  //   setState(() {
  //     isLoading = false;
  //   });
  // }

  void openInGoogleMaps(double lat, double lng) async {
    final url = 'https://www.google.com/maps/search/?api=1&query=$lat,$lng';

    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    }
  }

  void openMapBottomSheet(double lat, double lng) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SizedBox(
          height: MediaQuery.of(context).size.height * 0.7,
          child: Column(
            children: [

              /// Drag Handle
              const SizedBox(height: 10),
              Container(
                width: 50,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),

              const SizedBox(height: 10),

              /// Title
              const Text(
                'Driver Location 📍',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),

              const SizedBox(height: 10),

              /// MAP
              Expanded(
                child: GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: LatLng(lat, lng),
                    zoom: 14,
                  ),
                  markers: {
                    Marker(
                      markerId: const MarkerId('driver'),
                      position: LatLng(lat, lng),
                      icon: driverIcon ?? BitmapDescriptor.defaultMarker,
                      infoWindow: const InfoWindow(title: 'Driver Here'),
                    ),
                  },
                ),
              ),

              /// Optional button → open in Google Maps App
              Padding(
                padding: const EdgeInsets.all(12),
                child: ElevatedButton(
                  onPressed: () {
                    openInGoogleMaps(lat, lng);
                  },
                  child: const Text('Open in Google Maps'),
                ),
              )
            ],
          ),
        );
      },
    );
  }


  Future<void> callDriver(String phone) async {
    final Uri url = Uri(scheme: 'tel', path: phone);

    if (await canLaunchUrl(url)) {
      await launchUrl(
        url,
        mode: LaunchMode.externalApplication,);
    } else {
      print("Could not launch $url");
    }
  }

  @override
  Widget build(BuildContext context) {

    if (orderData == null) {
      return const Scaffold(
        body: Center(child: Text('No Data Found')),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              /// 🚗 DRIVER CARD
              const SizedBox(height: 20),
              Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 15,
                    offset: const Offset(0, 4),
                  ),
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// Header with back button and menu
                  Padding(
                    padding: const EdgeInsets.fromLTRB(8, 12, 12, 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        /// Back button with improved styling
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.grey.shade50,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 4,
                                offset: const Offset(0, 1),
                              ),
                            ],
                          ),
                          child: IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: Icon(Icons.arrow_back_ios_new, size: 16, color: Colors.grey.shade700),
                            padding: const EdgeInsets.all(10),
                            constraints: const BoxConstraints(),
                          ),
                        ),

                        /// Status badge
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: Colors.green.shade50,
                            border: Border.all(color: Colors.green.shade200, width: 0.5),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 6,
                                height: 6,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.green.shade600,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                "ON THE WAY",
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.green.shade700,
                                  letterSpacing: 0.8,
                                ),
                              ),
                            ],
                          ),
                        ),

                        /// Menu button
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.grey.shade50,
                          ),
                          child: IconButton(
                            onPressed: () {
                              // Show more options
                            },
                            icon: Icon(Icons.more_vert, size: 20, color: Colors.grey.shade700),
                            padding: const EdgeInsets.all(10),
                            constraints: const BoxConstraints(),
                          ),
                        ),
                      ],
                    ),
                  ),

                  /// Driver info section with enhanced design
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        /// Driver avatar with online indicator
                        Stack(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  colors: [Colors.blue.shade400, Colors.blue.shade700],
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.blue.shade200.withOpacity(0.5),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Container(
                                padding: const EdgeInsets.all(2),
                                child: CircleAvatar(
                                  radius: 32,
                                  backgroundImage: NetworkImage(orderData!['user_profile']),
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 2,
                              right: 2,
                              child: Container(
                                padding: const EdgeInsets.all(3),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white,
                                ),
                                child: Container(
                                  width: 10,
                                  height: 10,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.green.shade500,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(width: 16),

                        /// Driver details
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              /// Name and verification badge
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      orderData!['driver_name'] ?? 'Driver',
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.blue.shade50,
                                    ),
                                    child: Icon(
                                      Icons.verified,
                                      size: 14,
                                      color: Colors.blue.shade600,
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 8),

                              /// Rating with progress bar style
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  color: Colors.amber.shade50,
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    ...List.generate(5, (index) {
                                      if (index < 4) {
                                        return Icon(Icons.star, size: 14, color: Colors.amber.shade600);
                                      } else {
                                        return Icon(Icons.star_half, size: 14, color: Colors.amber.shade600);
                                      }
                                    }),
                                    const SizedBox(width: 6),
                                    Text(
                                      '4.8',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.amber.shade800,
                                      ),
                                    ),
                                    Text(
                                      ' (128 rides)',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 8),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  Divider(height: 1, thickness: 1, color: Colors.grey.shade100),

                  /// Action buttons row with enhanced styling
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
                    child: Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              callDriver(orderData!['driver_phone']);
                            },
                            icon: const Icon(Icons.call, size: 18),
                            label: const Text('Call Driver', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green.shade600,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              openMapBottomSheet(
                                double.parse(orderData!['driver_lat']),
                                double.parse(orderData!['driver_long']),
                              );
                            },
                            icon: const Icon(Icons.navigation, size: 18),
                            label: const Text('Navigate', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.grey.shade700,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              side: BorderSide(color: Colors.grey.shade300, width: 1.5),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),


                  /// 🔐 OTP + ROUTE CARD
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      color: Colors.black,
                    ),
                    child: Column(
                      children: [

                        /// OTP ROW
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: const [
                                Icon(Icons.lock_outline, size: 18, color: Colors.greenAccent),
                                SizedBox(width: 6),
                                Text(
                                  "OTP",
                                  style: TextStyle(
                                    color: Colors.white60,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                color: Colors.greenAccent.withOpacity(0.15),
                              ),
                              child: Text(
                                "${orderData!['pickup_otp']}",
                                style: const TextStyle(
                                  fontSize: 20,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 2,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 10),

                        Divider(color: Colors.white.withOpacity(0.1), height: 1),

                        const SizedBox(height: 10),

                        /// ROUTE
                        Row(
                          children: [
                            Column(
                              children: [
                                Icon(Icons.radio_button_checked, size: 12, color: Colors.greenAccent),
                                Container(
                                  height: 16,
                                  width: 1,
                                  color: Colors.white60,
                                ),
                                Icon(Icons.location_on, size: 16, color: Colors.redAccent),
                              ],
                            ),
                            const SizedBox(width: 10),

                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    orderData!['pickup_address'],
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    orderData!['droup_address'] == ''
                                        ? 'Drop not set'
                                        : orderData!['droup_address'],
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.white70,
                                    ),
                                  ),
                                ],
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
          


              /// 💰 PAYMENT DETAILS - Enhanced card
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  gradient: LinearGradient(
                    colors: [
                      Colors.blue.shade50,
                      Colors.white,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.withOpacity(0.08),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    )
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [


                    /// 💰 PAYMENT HEADER
                    Row(
                      children: [
                        Icon(Icons.receipt_long, size: 16, color: Colors.blue.shade700),
                        const SizedBox(width: 6),
                        Text(
                          "Payment",
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.blue.shade900,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    /// 💳 PAYMENT CARD
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.white,
                        border: Border.all(color: Colors.blue.shade100),
                      ),
                      child: Column(
                        children: [
                          rowItem('Fare', orderData!['order_amount']),
                          rowItem('Discount', '₹0', isDiscount: true),

                          const SizedBox(height: 4),

                          Divider(height: 10, color: Colors.grey.shade200),

                          rowItem('Total', orderData!['final_amount'], isFinal: true),
                          rowItem('Remaining', orderData!['remain_amount'], isRemaining: true),
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


  /// 🔹 reusable row
  Widget rowItem(String label, String amount, {
    bool isTotal = false,
    bool isFinal = false,
    bool isRemaining = false,
    bool isDiscount = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isTotal || isFinal || isRemaining ? 14 : 13,
              fontWeight: isTotal || isFinal || isRemaining ? FontWeight.w600 : FontWeight.normal,
              color: isDiscount ? Colors.red.shade700 : Colors.grey.shade700,
            ),
          ),
          Text(
            amount,
            style: TextStyle(
              fontSize: isTotal || isFinal || isRemaining ? 16 : 14,
              fontWeight: isFinal || isRemaining ? FontWeight.bold : FontWeight.w500,
              color: isDiscount
                  ? Colors.red.shade700
                  : isRemaining
                  ? Colors.orange.shade700
                  : isFinal
                  ? Colors.green.shade700
                  : Colors.grey.shade800,
            ),
          ),
        ],
      ),
    );
  }
}