import 'dart:async';

import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mahakal/features/self_drive/socket_instant/instant_socket_page.dart';
import 'package:provider/provider.dart';

import '../../data/datasource/remote/http/httpClient.dart';
import '../../utill/app_constants.dart';
import '../profile/controllers/profile_contrroller.dart';
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
  Set<Marker> _markers = {};


  Set<Polyline> _polylines = {};
  int selectedTip = 0;
  bool isTrip = true;
  int isScreen = 0;
  // Location strings
  String? fromLatitude;
  String? fromLongitude;
  Timer? _timer;
  bool isAccept = false;
  Map<String, dynamic>? orderData;
  LatLng get pickupLatLng => LatLng(
    double.tryParse(widget.fromLatitude) ?? 0,
    double.tryParse(widget.fromLongitude) ?? 0,
  );
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
      double driverLat = double.tryParse(orderData!['driver_lat'].toString()) ?? 0;
      double driverLng = double.tryParse(orderData!['driver_long'].toString()) ?? 0;

      updateDriverLocation(driverLat, driverLng); // 🔥 yaha call karo
      isScreen = 1;
      // Navigator.push(
      //   context,
      //   MaterialPageRoute(
      //     builder: (_) => DriverFoundScreen(orderData: orderData,),
      //   ),
      // );
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

  Future<void> updatePolyline(LatLng from, LatLng to) async {
    PolylinePoints polylinePoints = PolylinePoints();

    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      googleApiKey: AppConstants.googleApiKey,
      request: PolylineRequest(
        origin: PointLatLng(
          double.parse(from.latitude.toString()),
          double.parse(from.longitude.toString()),
        ),
        destination: PointLatLng(
          double.parse(to.latitude.toString()),
          double.parse(to.longitude.toString()),
        ),
        mode: TravelMode.driving,
      ),
    );

    if (result.points.isNotEmpty) {
      List<LatLng> polylineCoordinates = result.points
          .map((point) => LatLng(point.latitude, point.longitude))
          .toList();

      setState(() {
        _polylines = {
          Polyline(
            polylineId: const PolylineId('route'),
            color: Colors.blue,
            width: 4,
            points: polylineCoordinates,
          ),
        };
      });
    }
  }

  void updateDriverLocation(double lat, double lng) {
    final driverLatLng = LatLng(lat, lng);
    final pickup = pickupLatLng;

    final driverMarker = Marker(
      markerId: const MarkerId('driver'),
      position: driverLatLng,
      icon: driverIcon ?? BitmapDescriptor.defaultMarker,
    );

    final pickupMarker = Marker(
      markerId: const MarkerId('pickup'),
      position: pickup,
      icon: BitmapDescriptor.defaultMarkerWithHue(
          BitmapDescriptor.hueBlue),
    );

    setState(() {
      _markers = {pickupMarker, driverMarker};
    });

    /// 🔥 polyline update
    updatePolyline(driverLatLng, pickup);

    /// camera adjust
    _controller?.animateCamera(
      CameraUpdate.newLatLng(driverLatLng),
    );
  }

  Future<void> animateMarker(
      LatLng from, LatLng to) async {
    const int steps = 20;

    for (int i = 0; i <= steps; i++) {
      final lat = from.latitude + (to.latitude - from.latitude) * (i / steps);
      final lng = from.longitude + (to.longitude - from.longitude) * (i / steps);

      updateDriverLocation(lat, lng);
      await Future.delayed(Duration(milliseconds: 100));
    }
  }

  BitmapDescriptor? driverIcon;

  void loadCustomMarker() async {
    driverIcon = await getResizedMarker(
      'assets/planet/driver_bike.png',
      40, // 👈 size control (try 60–100)
    );
    setState(() {});
  }
  Future<BitmapDescriptor> getResizedMarker(String path, int width) async {
    final ByteData data = await rootBundle.load(path);
    final codec = await ui.instantiateImageCodec(
      data.buffer.asUint8List(),
      targetWidth: width,
      targetHeight: width,
    );
    final frame = await codec.getNextFrame();
    final byteData =
    await frame.image.toByteData(format: ui.ImageByteFormat.png);

    return BitmapDescriptor.fromBytes(byteData!.buffer.asUint8List());
  }


  Future<void> bookTipNow() async {
    String orderId = widget.orderId;
    var res = await HttpService()
        .postApi('/api/v1/self-vehicle/add-tip-amount-order', {
      'id': orderId,
      'tip_amount': '$selectedTip',
    });

    print('api tip add booking response $res');

    /// ✅ Success check
    if (res != null && res['status'] == 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Booking confirmed!')),
      );
      InstantSocketService().addTipAmount(orderId: orderId, price: '$selectedTip');
      setState(() {
        isTrip = false;
      });
    } else {
      /// ❌ Failed case
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(res?['message'] ?? 'Booking failed!'),
        ),
      );
    }
  }

  final List<String> cancelReasons = [
    'Wrong pickup location',
    'Wrong drop location',
    'Booked by mistake',
    'Driver not moving',
    'Estimated time is too long',
    'Other'
  ];

  final TextEditingController _otherReasonController = TextEditingController();

  void showCancelBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 18,
                right: 18,
                top: 14,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    'Cancel Ride',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Please select a reason for cancellation',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                  ),
                  const SizedBox(height: 18),
                  ...cancelReasons.map((reason) {
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(reason),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                      onTap: () {
                        if (reason == 'Other') {
                          // Stay on sheet to show text field or handle differently
                          setModalState(() {});
                        } else {
                          Navigator.pop(context);
                          showConfirmCancelDialog(reason);
                        }
                      },
                    );
                  }).toList(),
                  if (_otherReasonController.text.isNotEmpty || cancelReasons.last == 'Other')
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: TextField(
                        controller: _otherReasonController,
                        decoration: InputDecoration(
                          hintText: 'Type your reason...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onSubmitted: (value) {
                          if (value.isNotEmpty) {
                            Navigator.pop(context);
                            showConfirmCancelDialog(value);
                          }
                        },
                      ),
                    ),
                  if (cancelReasons.last == 'Other')
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        if (_otherReasonController.text.isNotEmpty) {
                          Navigator.pop(context);
                          showConfirmCancelDialog(_otherReasonController.text);
                        } else {
                          Fluttertoast.showToast(msg: 'Please enter a reason');
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Confirm Reason', style: TextStyle(color: Colors.white)),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void showConfirmCancelDialog(String reason) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Are you sure?'),
        content: Text('Reason: $reason\n\nDo you really want to cancel this ride?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('No', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              cancelRideApi(reason);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Yes, Cancel', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> cancelRideApi(String reason) async {
    // Show loader
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(child: CircularProgressIndicator()));

    try {
      var res = await HttpService().postApi('/api/v1/self-vehicle/cancel-ride', {
        'id': widget.orderId,
        'message': reason,
      });
      final userId = Provider.of<ProfileController>(context, listen: false).userID;
      print('api cancel booking response $res');
      Navigator.pop(context); // hide loader

      if (res != null && res['status'] == 1) {
        InstantSocketService().cancelOrder(orderId: widget.orderId, userId: userId, reason: reason);
        Fluttertoast.showToast(msg: 'Ride Cancelled Successfully');
        Navigator.pop(context); // return to home
      } else {
        Fluttertoast.showToast(msg: res?['message'] ?? 'Failed to cancel ride');
      }
    } catch (e) {
      Navigator.pop(context); // hide loader
      Fluttertoast.showToast(msg: 'Something went wrong');
    }
  }


  @override
  void initState() {
    super.initState();
    _markers = widget.markers ?? {};
    _polylines = widget.polylines ?? {};
    startPolling();
    loadCustomMarker();
  }
  @override
  void dispose() {
    _timer?.cancel();
    _otherReasonController.dispose();
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
            markers: _markers,
            polylines: _polylines,
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
          child: isScreen == 1
              ? DriverFoundScreen(orderData: orderData!)
              : Padding(
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
                  'Looking for your ride',
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
                if(isTrip)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      if (selectedTip != 0) {
                        // ✅ Confirm Ride with Tip
                        // confirmRideWithTip();
                        bookTipNow();
                      } else {
                        // ❌ Cancel Ride - Show Bottom Sheet
                        showCancelBottomSheet();
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
                ),

                if(!isTrip)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                          // ❌ Cancel Ride - Show Bottom Sheet
                          showCancelBottomSheet();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor:Colors.red,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: Text( 'Cancel Ride',
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