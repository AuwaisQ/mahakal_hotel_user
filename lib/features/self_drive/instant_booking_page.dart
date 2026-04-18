import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../data/datasource/remote/http/httpClient.dart';
import 'instant_driver_screen.dart';


class SearchingRideScreen extends StatefulWidget {
  final Set<Marker>? markers;
  final Set<Polyline>? polylines;
  final String fromLatitude;
  final String fromLongitude;
  final String orderId;
  const SearchingRideScreen({super.key,
    required this.markers,
    required this.polylines,
    required this.fromLatitude,
    required this.fromLongitude,
    required this.orderId,
  });

  @override
  _SearchingRideScreenState createState() => _SearchingRideScreenState();
}

class _SearchingRideScreenState extends State<SearchingRideScreen>
    with SingleTickerProviderStateMixin {
  GoogleMapController? _controller;
  // Set<Marker> _markers = {};
  // Set<Polyline> _polylines = {};
  int selectedTip = 0;
  // Location strings
  String? fromLatitude;
  String? fromLongitude;
  Timer? _timer;
  bool isAccept = false;
  Map<String, dynamic>? orderData;

  final List<int> tips = [10, 15, 20, 25, 35];

  Future<void> getConfirmOrder(String orderId) async {
    String url = '/api/v1/self-vehicle/get-order-information/$orderId';
    var res = await HttpService().getApi(url);

    print('Api Response from Drivers $res');

    if (res['status'] == 1) {
      // Fluttertoast.showToast(msg: 'Booking Accepted');
      Fluttertoast.showToast(
          msg: 'Booking Accepted',
          backgroundColor: Colors.green,
          textColor: Colors.white);
      /// ✅ STOP polling
      _timer?.cancel();

      /// 👉 Next screen ya action
      orderData = res['data'];
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => DriverFoundScreen(orderData: orderData,),
        ),
      );

    } else {
      print('Still waiting...');
    }

    setState(() {});
  }


  void startPolling() {
    _timer = Timer.periodic(Duration(seconds: 6), (timer) async {
      await getConfirmOrder(widget.orderId);
    });
  }

  @override
  void initState() {
    super.initState();
    startPolling();
  }
  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [

          /// 🗺️ Background Map (dummy color)
          // MAP VIEW
          GoogleMap(
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            initialCameraPosition: CameraPosition(
              target: LatLng(
                double.tryParse(widget.fromLatitude) ?? 23.2599,
                double.tryParse(widget.fromLongitude) ?? 77.4126,
              ),
              zoom: 14,
            ),
            onMapCreated: (controller) {
              _controller = controller;

              double lat = double.tryParse(widget.fromLatitude) ?? 0;
              double lng = double.tryParse(widget.fromLongitude) ?? 0;

              _controller!.animateCamera(
                CameraUpdate.newCameraPosition(
                  CameraPosition(
                    target: LatLng(lat, lng),
                    zoom: 15,
                  ),
                ),
              );
            },
            markers: widget.markers!,
            polylines: widget.polylines!,
          ),

          /// 🔻 Bottom Full Panel
      Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          height: MediaQuery.of(context).size.height * 0.58,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 20,
                offset: const Offset(0, -4),
              )
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                /// 🔹 Drag Handle
                Center(
                  child: Container(
                    width: 50,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),

                const SizedBox(height: 18),

                /// 🔹 Pickup & Drop
                Column(
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.circle, color: Colors.green, size: 18),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Pickup Location',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.location_on, color: Colors.red, size: 18),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Drop Location',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 22),

                /// 🔹 Searching Text
                const Text(
                  'Looking for your Bike ride',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 12),

                /// 🔄 Loader (Styled)
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    minHeight: 6,
                    backgroundColor: Colors.grey.shade200,
                    valueColor: AlwaysStoppedAnimation(Colors.blue),
                  ),
                ),

                const SizedBox(height: 22),

                /// 🔹 Ride Card (Improved)
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: Colors.grey.shade50,
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Row(
                    children: [
                      /// Icon
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.two_wheeler, color: Colors.blue),
                      ),

                      const SizedBox(width: 12),

                      /// Text
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              'Bike ride',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              '₹1.0',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),

                      /// Button
                      OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        onPressed: () {},
                        child: const Text('Details'),
                      )
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                /// 🔹 Tip Message
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Captains aren’t accepting at ₹1. Try adding a tip 🚀',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ),
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: Colors.blue.shade50,
                      child: const Icon(Icons.person, size: 16),
                    )
                  ],
                ),

                const SizedBox(height: 16),

                /// 🔹 Tip Options (Modern Chips)
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Wrap(
                    spacing: 10,
                    children: [

                      /// 🔹 NO TIP OPTION
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedTip = 0;
                          });
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          decoration: BoxDecoration(
                            color: selectedTip == 0
                                ? Colors.red.shade100
                                : Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(25),
                          ),
                          child:  Icon(Icons.cancel_outlined, size: 18,
                              color: selectedTip == 0
                                  ? Colors.red
                                  : Colors.grey),
                        ),
                      ),

                      /// 🔹 TIP OPTIONS
                      ...tips.map((tip) {
                        final isSelected = selectedTip == tip;

                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedTip = tip;
                            });
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 10),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? Colors.blue
                                  : Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(25),
                              boxShadow: isSelected
                                  ? [
                                BoxShadow(
                                  color: Colors.blue.withOpacity(0.3),
                                  blurRadius: 8,
                                )
                              ]
                                  : [],
                            ),
                            child: Text(
                              '+ ₹$tip',
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                color: isSelected
                                    ? Colors.white
                                    : Colors.black,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ],
                  ),
                ),

                const Spacer(),

                /// 🔹 Cancel Button (Premium)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      if (selectedTip != 0) {
                        // ✅ Confirm Ride with Tip
                        // confirmRideWithTip();
                      } else {
                        // ❌ Cancel Ride
                        Navigator.pop(context);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                      selectedTip != 0 ? Colors.blue : Colors.red,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: Text(
                      selectedTip != 0 ? 'Confirm with Tip' : 'Cancel Ride',
                    ),
                  ),
                )
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