import 'dart:async';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mahakal/utill/app_constants.dart';
import 'package:shimmer/shimmer.dart';
import 'dart:ui' as ui;
import '../../data/datasource/remote/http/httpClient.dart';
import 'instant_booking_page.dart';
import 'model/instantcarmodel.dart';

class InstantDetailPage extends StatefulWidget {
  final String pickupAddress;
  final String pickupLat;
  final String pickupLong;
  final String dropAddress;
  final String dropLat;
  final String dropLong;
  final double bookingPickKm;
  final String bookingType;
  const InstantDetailPage({super.key,
    required this.pickupAddress,
    required this.pickupLat,
    required this.pickupLong,
    required this.dropAddress,
    required this.dropLat,
    required this.dropLong,
    required this.bookingPickKm,
    required this.bookingType,
  });

  @override
  State<InstantDetailPage> createState() => _InstantDetailPageState();
}

class _InstantDetailPageState extends State<InstantDetailPage> {
  Position? _currentPosition;
  GoogleMapController? _controller;
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};
 int currentIndex = 0;

  // Text controllers
  final TextEditingController _fromLocation = TextEditingController();
  final TextEditingController _toLocation = TextEditingController();

  // Location strings
  String? fromLatitude;
  String? fromLongitude;
  String? toLatitude;
  String? toLongitude;
  String leadId = '';
  double distanceKm = 0.0;
  bool isLoading = true;
  int selectedVehicleIndex = 0; // 0: Bike, 1: Auto, 2: Cab Economy, 3: E-Rickshaw
  Timer? _bikeTimer;
  // Vehicle data
  List<CarAvailable> vehiclesList = <CarAvailable>[];
  List<BikeLocation> vehiclesMarks = <BikeLocation>[];

  void getVehicleList() async{
    String type = widget.bookingType == 'cab' ? 'get-instant-booking-cabs' : 'get-parcel-booking-cabs';
    var res = await HttpService().postApi('/api/v1/self-vehicle/$type', {
      'pickup_address': widget.pickupAddress,
      'pickup_lat': widget.pickupLat,
      'pickup_long': widget.pickupLong,
      'drop_address': widget.dropAddress,
      'drop_lat': widget.dropLat,
      'drop_long': widget.dropLong,
      'booking_pick_km': widget.bookingPickKm,
      'lead_id':''
    });
    print('Api response instant data $res');
    if(res['status'] == 1){
     setState(() {
      List data = res['data']['data'];
      vehiclesList.addAll(data.map((e)=> CarAvailable.fromJson(e)));
      isLoading = false;
     });
    }
    leadId = res['data']['lead_id'].toString();
    getMarkersBike(leadId);
  }

  Future<void> bookNow(Map<String, dynamic> data) async {
    if (isLoading) return;

    setState(() => isLoading = true);

    var res = await HttpService()
        .postApi('/api/v1/self-vehicle/instant-booking-now', data);

    print('api booking response $res');

    /// ✅ Success check
    if (res != null && res['status'] == 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Booking confirmed!')),
      );
      String id = res['data']['order_id'].toString();
      Navigator.push(context, MaterialPageRoute(builder: (_)=>
          SearchingRideScreen(
            markers: _markers,
            polylines: _polylines,
            fromLatitude: fromLatitude!,
            fromLongitude: fromLongitude!,
              orderId:id,
          )));
      // 👉 optional: navigate ya next step
      // Get.to(() => SuccessPage());

    } else {
      /// ❌ Failed case
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(res?['message'] ?? 'Booking failed!'),
        ),
      );
    }

    setState(() => isLoading = false);
  }
  @override
  void initState() {
    super.initState();

    _init(); // 🔥 clean init
  }

  Future<void> _init() async {
    await loadBikeIcon();

    _setInitialLocations();

    /// 🔥 wait until map ready (important)
    Future.delayed(const Duration(milliseconds: 500), () {
      _setMarkers();
    });

    getVehicleList();

    /// 🔥 polyline after small delay
    Future.delayed(const Duration(seconds: 1), () {
      _getPolyline();
    });
  }

  void _setInitialLocations() {
    // Set some default locations for demo
    fromLatitude = widget.pickupLat;
    fromLongitude = widget.pickupLong;
    toLatitude = widget.dropLat;
    toLongitude = widget.dropLong;
    distanceKm = widget.bookingPickKm;
    _fromLocation.text = widget.pickupAddress;
    _toLocation.text = widget.dropAddress;
  }

  BitmapDescriptor? bikeIcon;

  Future<void> loadBikeIcon() async {
    bikeIcon = await getCustomMarker('assets/planet/driver_bike.png', 120); // 🔥 size control
  }

  Future<BitmapDescriptor> getCustomMarker(String path, int width) async {
    final ByteData data = await rootBundle.load(path);
    final Uint8List bytes = data.buffer.asUint8List();

    final ui.Codec codec = await ui.instantiateImageCodec(
      bytes,
      targetWidth: width, // 🔥 control size here
    );

    final ui.FrameInfo fi = await codec.getNextFrame();

    final Uint8List resizedBytes =
    (await fi.image.toByteData(format: ui.ImageByteFormat.png))!
        .buffer
        .asUint8List();

    return BitmapDescriptor.fromBytes(resizedBytes);
  }
  void _setMarkers() {
    if (_controller == null) return; // 🔥 MOST IMPORTANT FIX

    _markers.clear();

    double lat = double.tryParse(widget.pickupLat) ?? 0;
    double lng = double.tryParse(widget.pickupLong) ?? 0;

    /// 🔥 camera always pickup pe
    _controller!.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(lat, lng),
          zoom: 15,
        ),
      ),
    );

    /// pickup
    _markers.add(
      Marker(
        markerId: const MarkerId('pickup'),
        position: LatLng(lat, lng),
        infoWindow: const InfoWindow(title: 'Pickup'),
        icon: BitmapDescriptor.defaultMarkerWithHue(
          BitmapDescriptor.hueBlue, // 👈 color change
        ),
      ),
    );

    /// drop
    if (toLatitude != null && toLongitude != null) {
      _markers.add(
        Marker(
          markerId: const MarkerId('drop'),
          position: LatLng(
            double.tryParse(toLatitude!) ?? 0,
            double.tryParse(toLongitude!) ?? 0,
          ),
          infoWindow: const InfoWindow(title: 'Drop'),
        ),
      );
    }

    setState(() {});
  }

  Future<void> _getPolyline() async {
    if (fromLatitude == null || toLatitude == null) return;

    PolylinePoints polylinePoints = PolylinePoints();

    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      googleApiKey: AppConstants.googleApiKey,
      request: PolylineRequest(
        origin: PointLatLng(
          double.parse(fromLatitude!),
          double.parse(fromLongitude!),
        ),
        destination: PointLatLng(
          double.parse(toLatitude!),
          double.parse(toLongitude!),
        ),
        mode: TravelMode.driving,
      ),
    );

    if (result.points.isEmpty) return;

    List<LatLng> polylineCoordinates =
    result.points.map((p) => LatLng(p.latitude, p.longitude)).toList();

    _polylines.clear();

    _polylines.add(
      Polyline(
        polylineId: const PolylineId('route'),
        points: polylineCoordinates,
        width: 5,
        color: Colors.blue,
      ),
    );

    setState(() {});
  }

  void addDriverMarkers(List<BikeLocation> drivers) {
    _markers.removeWhere((m) => m.markerId.value.startsWith('driver_'));

    for (int i = 0; i < drivers.length; i++) {
      final latStr = drivers[i].latitude;
      final lngStr = drivers[i].longitude;

      if (latStr == null || lngStr == null) continue;

      final lat = double.tryParse(latStr.trim());
      final lng = double.tryParse(lngStr.trim());

      /// ❌ skip invalid
      if (lat == null || lng == null) {
        print('❌ Invalid latlng: $latStr , $lngStr');
        continue;
      }

      print('✅ Driver: $lat , $lng');

      _markers.add(
        Marker(
          markerId: MarkerId('driver_$i'),
          position: LatLng(lat, lng),
          icon: bikeIcon ?? BitmapDescriptor.defaultMarker,
          // icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
        ),
      );
    }

    setState(() {});
  }

  void getMarkersBike(String id) async {
    var res = await HttpService()
        .getApi('/api/v1/self-vehicle/get-near-vehicles/$id');

    print("API DATA 👉 ${res['data']}"); // 🔥 MUST

    if (res['status'] == 1 && res['data'] != null) {
      vehiclesMarks.clear();

      vehiclesMarks = (res['data'] as List)
          .map((e) => BikeLocation.fromJson(e))
          .toList();

      addDriverMarkers(vehiclesMarks);
    }
  }

  void showOfferBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        return ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.95),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: Padding(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        margin: const EdgeInsets.only(top: 12, bottom: 8),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          /// Header
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                '🎁 Exclusive Offers',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,

                                ),
                              ),
                              GestureDetector(
                                onTap: () => Navigator.pop(context),
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade200,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.close, size: 20),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),

                          /// Coin Card
                          _buildModernCoinCard(),
                          const SizedBox(height: 16),

                          /// Coupon Input
                          _buildCouponInput(),
                          const SizedBox(height: 16),

                          /// Coupon List
                          _buildCouponCard(
                            code: 'SAVE30',
                            discount: '₹30',
                            description: 'Save upto ₹30 on this ride',
                            validity: 'Valid for limited time',
                            color: Colors.green,
                          ),
                          const SizedBox(height: 12),

                          _buildCouponCard(
                            code: 'FIRSTRIDE',
                            discount: '20%',
                            description: 'Get 20% off on first ride',
                            validity: 'Valid for new users only',
                            color: Colors.blue,
                          ),
                          const SizedBox(height: 12),

                          _buildCouponCard(
                            code: 'WEEKEND',
                            discount: '₹50',
                            description: 'Weekend special discount',
                            validity: 'Valid on Sat & Sun',
                            color: Colors.purple,
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void showPaymentBottomSheet(BuildContext context) {
    // Add state management inside the bottom sheet
    String selectedPaymentMethod = 'cash'; // ✅ bahar define karo
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context,StateSetter setState) {

            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /// 🔹 Drag Handle
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          margin: const EdgeInsets.only(top: 12, bottom: 8),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),

                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            /// 🔹 Headline with close button
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Select Payment Method',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF1A1A1A),
                                    letterSpacing: -0.5,
                                  ),
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade100,
                                    shape: BoxShape.circle,
                                  ),
                                  child: IconButton(
                                    icon: const Icon(Icons.close),
                                    onPressed: () => Navigator.pop(context),
                                    iconSize: 20,
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                    style: IconButton.styleFrom(
                                      padding: const EdgeInsets.all(8),
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 20),

                            /// 💰 Enhanced Total Fare Card
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.deepOrange.shade400,
                                    Colors.orange.shade800,
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.blue.shade300.withOpacity(0.3),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Total Fare',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.white70,
                                        ),
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        'Including taxes & fees',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: Colors.white60,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const Text(
                                    '₹120',
                                    style: TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      letterSpacing: -0.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 16),

                            /// ℹ️ Enhanced Note
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.amber.shade50,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.amber.shade200,
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.info_outline,
                                    size: 18,
                                    color: Colors.amber.shade800,
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      'Pay directly to your captain through Cash or UPI',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.amber.shade900,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 24),

                            /// 🔹 Other Options Section
                            _buildSectionHeader('Payment Options'),
                            const SizedBox(height: 12),

                            /// 💵 Cash Option with Radio
                            _buildRadioPaymentTile(
                              value: 'cash',
                              groupValue: selectedPaymentMethod,
                              onChanged: (value) {
                                setState(() {
                                  selectedPaymentMethod = value;
                                });
                              },
                              icon: Icons.money,
                              iconColor: Colors.green,
                              iconBgColor: Colors.green.shade50,
                              title: 'Cash',
                              subtitle: 'Pay directly to captain',
                              extra: null,
                            ),

                            /// 💳 UPI Option with Radio
                            _buildRadioPaymentTile(
                              value: 'upi',
                              groupValue: selectedPaymentMethod,
                              onChanged: (value) {
                                setState(() {
                                  selectedPaymentMethod = value;
                                });
                              },
                              icon: Icons.qr_code_scanner,
                              iconColor: Colors.purple,
                              iconBgColor: Colors.purple.shade50,
                              title: 'UPI',
                              subtitle: 'Google Pay, PhonePe, Paytm',
                              extra: Container(
                                margin: const EdgeInsets.only(top: 8),
                                child: Row(
                                  children: [
                                    _buildUPIIcon('assets/gpay.png', 'GPay'),
                                    _buildUPIIcon('assets/phonepe.png', 'PhonePe'),
                                    _buildUPIIcon('assets/paytm.png', 'Paytm'),
                                  ],
                                ),
                              ),
                            ),

                            const SizedBox(height: 20),

                            /// 🔹 Wallets Section
                            _buildSectionHeader('Wallets'),
                            const SizedBox(height: 12),

                            /// Mahakal Ride Wallet
                            _buildRadioPaymentTile(
                              value: 'wallet',
                              groupValue: selectedPaymentMethod,
                              onChanged: (value) {
                                setState(() {
                                  selectedPaymentMethod = value;
                                });
                              },
                              icon: Icons.account_balance_wallet,
                              iconColor: Colors.orange,
                              iconBgColor: Colors.orange.shade50,
                              title: 'Mahakal Ride Wallet',
                              subtitle: 'Balance: ₹200',
                              extra: Container(
                                margin: const EdgeInsets.only(top: 6),
                                child: Text(
                                  'Available balance: ₹200',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.green.shade700,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),

                            /// Amazon Pay
                            _buildRadioPaymentTile(
                              value: 'amazon',
                              groupValue: selectedPaymentMethod,
                              onChanged: (value) {
                                setState(() {
                                  selectedPaymentMethod = value;
                                });
                              },
                              icon: Icons.account_balance,
                              iconColor: Colors.blue,
                              iconBgColor: Colors.blue.shade50,
                              title: 'Amazon Pay',
                              subtitle: 'Fast & secure payment',
                              extra: null,
                            ),

                            const SizedBox(height: 20),

                            /// 🔹 Pay Later Section
                            _buildSectionHeader('Pay Later'),
                            const SizedBox(height: 12),

                            /// Pay & Drop
                            _buildRadioPaymentTile(
                              value: 'pay_later',
                              groupValue: selectedPaymentMethod,
                              onChanged: (value) {
                                setState(() {
                                  selectedPaymentMethod = value;
                                });
                              },
                              icon: Icons.timer,
                              iconColor: Colors.red,
                              iconBgColor: Colors.red.shade50,
                              title: 'Pay & Drop',
                              subtitle: 'Pay after ride completion',
                              extra: Container(
                                margin: const EdgeInsets.only(top: 6),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.security,
                                      size: 12,
                                      color: Colors.grey.shade600,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      'No extra charges',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            const SizedBox(height: 24),

                            /// 🔹 Confirm Payment Button
                            SizedBox(
                              width: double.infinity,
                              height: 54,
                              child: ElevatedButton(
                                onPressed: () {
                                  // Handle payment selection
                                  Navigator.pop(context, selectedPaymentMethod);
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF1F2937),
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  textStyle: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                  ),
                                ),
                                child: const Text('Confirm Payment'),
                              ),
                            ),

                            const SizedBox(height: 12),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

// Helper Widget: Section Header
  Widget _buildSectionHeader(String title) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 20,
          decoration: BoxDecoration(
            color: const Color(0xFF2563EB),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1A1A1A),
            letterSpacing: -0.3,
          ),
        ),
      ],
    );
  }

// Helper Widget: Radio Payment Tile
  Widget _buildRadioPaymentTile({
    required String value,
    required String groupValue,
    required Function(String) onChanged,
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required String title,
    required String subtitle,
    Widget? extra,
  }) {
    return GestureDetector(
      onTap: () => onChanged(value),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: groupValue == value ? Colors.blue.shade50 : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: groupValue == value ? Colors.blue.shade300 : Colors.grey.shade200,
            width: groupValue == value ? 2 : 1.5,
          ),
          boxShadow: groupValue == value
              ? [
            BoxShadow(
              color: Colors.blue.shade100.withOpacity(0.4),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ]
              : null,
        ),
        child: Row(
          children: [
            /// Radio Button
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: groupValue == value ? const Color(0xFF2563EB) : Colors.grey.shade400,
                  width: 2,
                ),
              ),
              child: groupValue == value
                  ? Center(
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFF2563EB),
                  ),
                ),
              )
                  : null,
            ),
            const SizedBox(width: 14),

            /// Icon
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: iconBgColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: iconColor,
                size: 24,
              ),
            ),
            const SizedBox(width: 14),

            /// Title & Subtitle
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  if (extra != null) extra,
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

// Helper Widget: UPI Icon
  Widget _buildUPIIcon(String imagePath, String label) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            imagePath,
            height: 20,
            width: 20,
            errorBuilder: (context, error, stackTrace) => Icon(
              Icons.account_balance_wallet,
              size: 20,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernCoinCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.orange.shade400, Colors.deepOrange.shade400],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.shade300.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.monetization_on,
              color: Colors.white,
              size: 30,
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Your Balance',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
                Text(
                  '120 Coins',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30),
            ),
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Text(
                'Use',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.deepOrange,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCouponInput() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          const Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Enter coupon code',
                prefixIcon: Icon(Icons.local_offer_outlined),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
              ),
              borderRadius: BorderRadius.circular(30),
            ),
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: const Text('Apply'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCouponCard({
    required String code,
    required String discount,
    required String description,
    required String validity,
    required Color color,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3), width: 1.5),
        gradient: LinearGradient(
          colors: [color.withOpacity(0.1), color.withOpacity(0.05)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.card_giftcard, color: color, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        code,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          discount,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: color,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: const TextStyle(fontSize: 13),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    validity,
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
            TextButton(
              onPressed: () {},
              style: TextButton.styleFrom(
                foregroundColor: color,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: const Text('Apply'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
        decoration: BoxDecoration(
          color: Colors.white,

          /// 🔥 top rounded + shadow
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, -4),
            ),
          ],
        ),

        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [

              /// 🔥 Top Row (Actions)
              Row(
                children: [
                  Expanded(
                    child: _buildActionButton(
                      Icons.currency_rupee,
                      'Cash',
                      onTap: () {
                        showPaymentBottomSheet(context);
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildActionButton(
                      Icons.local_offer,
                      'Offers',
                      onTap: () {
                        showOfferBottomSheet(context);
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              /// 🔥 Main CTA Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: isLoading
                      ? null // 🔒 disable button
                      : () {
                    Map<String, dynamic> data = {
                      'lead_id': leadId,
                      'vehicle_category_id':
                      '${vehiclesList[selectedVehicleIndex].vehicleId}',
                      'id': '${vehiclesList[selectedVehicleIndex].id}',
                      'price': '${vehiclesList[selectedVehicleIndex].price}',
                      'pre_paid': 0
                    };

                    bookNow(data);
                  },

                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    disabledBackgroundColor: Colors.grey.shade400, // 👈 disabled look
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),

                  child: isLoading
                      ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                      : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.directions_car, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        vehiclesList.isEmpty
                        ? 'Waiting...'
                         :'Book ${vehiclesList[selectedVehicleIndex].vehicleType}',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      body: Stack(
        children: [
          // MAP VIEW
          GoogleMap(
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            initialCameraPosition: const CameraPosition(
              target: LatLng(23.2599, 77.4126),
              zoom: 14,
            ),
            onMapCreated: (controller) {
              _controller = controller;
            },
            markers: _markers,
            polylines: _polylines,
          ),

          // BOTTOM SHEET - VEHICLE OPTIONS & FARE
          Positioned(
              top: 30,
              left: 10,
              child: IconButton(onPressed: ()=> Navigator.pop(context), icon: Icon(Icons.arrow_back_ios))),
          Positioned(
        top: 360,
        bottom: 0,
        left: 0,
        right: 0,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.12),
                blurRadius: 20,
                spreadRadius: 2,
                offset: const Offset(0, -6),
              ),
            ],
          ),
          child: SingleChildScrollView(
            child: Column(
              children: [

                const SizedBox(height: 10),

                /// Vehicle List
                /// vehiclesList.isEmpty ? "No vehicles available" :
                isLoading ? _buildShimmerList() :
                ListView.separated(
                  shrinkWrap: true,
                  padding: EdgeInsets.zero,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: vehiclesList.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final vehicle = vehiclesList[index];
                      final isSelected = selectedVehicleIndex == index;

                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedVehicleIndex = index;
                          });
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          margin: const EdgeInsets.symmetric(horizontal: 16),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isSelected ? Colors.amber.shade50 : Colors.white,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: isSelected ? Colors.amber : Colors.grey.shade200,
                              width: 1.5,
                            ),
                            boxShadow: [
                              if (isSelected)
                                BoxShadow(
                                  color: Colors.amber.withOpacity(0.2),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                            ],
                          ),
                          child: Row(
                            children: [
                              /// 🚗 Vehicle Image
                              Container(
                                width: 55,
                                height: 55,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(14),
                                  color: Colors.grey.shade100,
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(14),
                                  child: Image.network(
                                    vehicle.icon ?? '',
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) =>
                                    const Icon(Icons.directions_car),
                                  ),
                                ),
                              ),

                              const SizedBox(width: 12),

                              /// 📄 Vehicle Info
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    /// Type + Category
                                    Row(
                                      children: [
                                        Text(
                                          vehicle.vehicleType ?? '',
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: isSelected
                                                ? FontWeight.bold
                                                : FontWeight.w600,
                                          ),
                                        ),
                                        const SizedBox(width: 6),

                                        /// Category Badge
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: Colors.blue.withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(5),
                                          ),
                                          child: Text(
                                            vehicle.vehicleCategory ?? '',
                                            style: const TextStyle(
                                              fontSize: 10,
                                              color: Colors.blue,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),

                                    const SizedBox(height: 4),

                                    /// Extra Info
                                    Row(
                                      children: [
                                        Icon(Icons.speed, size: 12, color: Colors.grey[600]),
                                        const SizedBox(width: 4),
                                        Text(
                                          '₹${vehicle.perKmCharge}/km',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey[600],
                                          ),
                                        ),

                                        const SizedBox(width: 10),

                                        Icon(Icons.timer, size: 12, color: Colors.grey[600]),
                                        const SizedBox(width: 4),
                                        Text(
                                          '₹${vehicle.waitingCharge}/min',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),

                              /// 💰 Price Section
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    '₹${vehicle.price}',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: isSelected
                                          ? Colors.orange.shade700
                                          : Colors.black,
                                    ),
                                  ),

                                  /// Optional discount UI
                                  if (index == 0)
                                    Text(
                                      'Best Price',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.green[600],
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    }
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
        ],
      ),
    );
  }

  Widget _buildShimmerList() {
    return ListView.separated(
      shrinkWrap: true,
      padding: EdgeInsets.zero,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 5,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Shimmer.fromColors(
            baseColor: Colors.grey.shade300,
            highlightColor: Colors.grey.shade100,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                color: Colors.white,
              ),
              child: Row(
                children: [
                  /// image box
                  Container(
                    width: 55,
                    height: 55,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      color: Colors.white,
                    ),
                  ),

                  const SizedBox(width: 12),

                  /// text lines
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(height: 14, width: 120, color: Colors.white),
                        const SizedBox(height: 8),
                        Container(height: 12, width: 80, color: Colors.white),
                        const SizedBox(height: 8),
                        Container(height: 12, width: 150, color: Colors.white),
                      ],
                    ),
                  ),

                  /// price
                  Column(
                    children: [
                      Container(height: 16, width: 40, color: Colors.white),
                      const SizedBox(height: 6),
                      Container(height: 12, width: 60, color: Colors.white),
                    ],
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildActionButton(IconData icon, String label, {VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(25),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(25),

          /// 🔥 soft shadow (premium feel)
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],

          /// subtle border
          border: Border.all(color: Colors.grey.shade200),
        ),

        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            /// 🔥 Icon with background circle
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 16,
                color: Colors.black87,
              ),
            ),

            const SizedBox(width: 8),

            /// Text
            Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
            Spacer(),
            Icon(
              Icons.keyboard_arrow_right,
              size: 20,
              color: Colors.black87,
            ),
          ],
        ),
      ),
    );
  }
}


class BikeLocation {
  String? latitude;
  String? longitude;

  BikeLocation({this.latitude, this.longitude});

  factory BikeLocation.fromJson(Map<String, dynamic> json) {
    return BikeLocation(
      latitude: json['latitude']?.toString().trim(),
      longitude: json['longitude']?.toString().trim(),
    );
  }
}
