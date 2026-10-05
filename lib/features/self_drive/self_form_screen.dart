import 'dart:convert';
import 'dart:math';

import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:mahakal/data/datasource/remote/http/httpClient.dart';
import 'package:mahakal/features/self_drive/self_car_screen.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../../main.dart';
import '../../utill/app_constants.dart';
import '../auth/controllers/auth_controller.dart';
import '../order/model/self_driver_ordermodel.dart';
import '../order/screens/track_screens/self_details_screen.dart';
import '../profile/controllers/profile_contrroller.dart';
import '../tour_and_travells/Controller/tour_location_controller.dart';
import 'controller/self_location_widget.dart';
import 'instanthome_page.dart';
import 'widgets/self_location_search_screen.dart';
import 'widgets/dual_location_search_screen.dart';

class TripBookingPage extends StatefulWidget {
  final String type;
  const TripBookingPage({super.key, required this.type});

  @override
  State<TripBookingPage> createState() => _TripBookingPageState();
}

class _TripBookingPageState extends State<TripBookingPage> {
  // Form variables

  String? _currentLeadId;
  bool isBtn = false;
  String _selectedHour = '';
  String _selectedKilometer = '';
  String _tripType = 'one-way'; // 'one-way' or 'two-way or 'local' or 'self'
  String leadBookingType =
      'oneway'; // 'one-way' or 'two-way or 'local' or 'self'
  FocusNode dropFocusNode = FocusNode();
  FocusNode returnFocusNode = FocusNode();

  // String _fromLocation = '';
  // String _toLocation = '';
  // String? _returnLocation;
  DateTime? pickupDateTime;
  DateTime? returnDateTime;
  String? selectedLocation;
  double distanceKm = 0.0;
  double returnDistanceKm = 0.0;
  final TextEditingController _fromLocation = TextEditingController();
  final TextEditingController _toLocation = TextEditingController();
  final TextEditingController _returnLocation = TextEditingController();
  final TextEditingController _manualHourController = TextEditingController();
  double _selfSelectedHours = 0.0;

  // Multiple Drop Locations for Round Trip
  List<TextEditingController> _multiDropControllers = [];
  List<String> _multiDropLats = [];
  List<String> _multiDropLngs = [];

  GoogleMapController? _controller;

  List<SelfList> selfOrderModelList = <SelfList>[];

  String fromLatitude = '';
  String fromLongitude = '';
  String toLongitude = '';
  String toLatitude = '';
  String returnLatitude = '';
  String returnLongitude = '';
  String name = '';
  String phone = '';
  String aadhaar = '';
  String license = '';
  List<String> allowedCities = [];

  Future<void> fetchAllowedCities() async {
    final res = await http.get(Uri.parse(
        'https://sit.resrv.in/api/v1/self-vehicle/allowed-address/vehicle'));

    final data = json.decode(res.body);
    print('Api response for allowed cities $data');
    if (data['status'] == 1) {
      allowedCities = (data['data'] as List)
          .map((e) => e['city'].toString().toLowerCase())
          .toList();
    }
  }

  String formatDateLead(DateTime? date) {
    if (date == null) return '';
    return DateFormat('dd-MM-yyyy hh:mm aa').format(date);
  }

  String formatDate(DateTime? date) {
    if (date == null) return '';
    return DateFormat('dd-MM-yyyy').format(date);
  }

  String formatTime(DateTime? date) {
    if (date == null) return '';
    return DateFormat('hh:mm').format(date); // 10:30
  }

  double calculateTotalTripDistance() {
    if (_tripType == 'one-way') {
      return distanceKm;
    }
    int days = getTotalDays();
    double includedDistance = days * 125.0;

    // Total distance is the sum of pickup to drop1,
    // drop1 to multi-drops, and last point back to pickup.
    double totalCalculated = distanceKm + returnDistanceKm;

    return totalCalculated > includedDistance
        ? totalCalculated
        : includedDistance;
  }

  void getLeadGenerate(String categoryType, double totalDistance) async {
    final prefs = await SharedPreferences.getInstance();
    final String? referralCode = prefs.getString('referral_code');

    Map<String, dynamic> body = {
      'lead_id': _currentLeadId ?? '',
      'booking_type': leadBookingType,
      'phone_number': Provider.of<ProfileController>(
        Get.context!,
        listen: false,
      ).userPHONE,

      'pickup_address': (leadBookingType == 'self_drive' || leadBookingType == 'local') ? (selectedLocation ?? _fromLocation.text) : _fromLocation.text,
      'pickup_lat': fromLatitude,
      'pickup_long': fromLongitude,
      'pickup_date': formatDateLead(pickupDateTime),

      'drop_address': _toLocation.text,
      'drop_lat': toLatitude,
      'drop_long': toLongitude,

      'return_address': _returnLocation.text,
      'return_lat': returnLatitude,
      'return_long': returnLongitude,
      'return_date': formatDateLead(returnDateTime),

      'booking_pick_km': (leadBookingType == 'self_drive' || leadBookingType == 'local') ? totalDistance.toString() : distanceKm.toString(),
      'booking_return_km': returnDistanceKm.toString(),
      'total_trip_distance': totalDistance.toString(),
      if (referralCode != null && referralCode.isNotEmpty)
        "active_agent_code": referralCode,
    };

    List<Map<String, String>> multiAddress = [];

    if (_tripType == 'two-way') {

      // Include first drop
      if (_toLocation.text.isNotEmpty) {
        multiAddress.add({
          "drop_address": _toLocation.text,
          "drop_lat": toLatitude,
          "drop_long": toLongitude,
        });
      }

      // Include additional drops
      for (int i = 0; i < _multiDropControllers.length; i++) {
        if (_multiDropControllers[i].text.isNotEmpty) {
          multiAddress.add({
            "drop_address": _multiDropControllers[i].text,
            "drop_lat": _multiDropLats[i],
            "drop_long": _multiDropLngs[i],
          });
        }
      }
      body["multiaddress"] = multiAddress;
    }

    try {
      var res = await HttpService().postApi(
        '/api/v1/self-vehicle/vehicle-create-lead',
        body,
      );
      print('APi response for lead generate $res');
      if (res['status'] == 1) {
        String newLeadId = res['data']['lead_id'].toString();

        _currentLeadId = newLeadId;

        Navigator.push(
          context,
          CupertinoPageRoute(
            builder: (context) => CarSelectionPage(
              type: _tripType,
              location: selectedLocation ?? _fromLocation.text,
              pickDate: formatDate(pickupDateTime),
              pickTime: formatTime(pickupDateTime),
              dropDate: formatDate(returnDateTime),
              dropTime: formatTime(returnDateTime),
              totalHour: totalDistance,
              categoryType: categoryType,
              leadId: newLeadId,
              city: selectedLocation ?? _fromLocation.text,
              carType: categoryTypeList,
              totalDays: _tripType == "two-way" ? getTotalDays() : 1,
              multiaddress: multiAddress,
            ),
          ),
        );
      } else {
        Fluttertoast.showToast(
            msg: res['message'] ?? 'Lead generation failed',
            backgroundColor: Colors.red);
      }
    } catch (e) {
      print('Error generating lead: $e');
      Fluttertoast.showToast(
          msg: 'Something went wrong. Please try again.',
          backgroundColor: Colors.red);
    } finally {
      if (mounted) {
        setState(() {
          isBtn = false;
        });
      }
    }
  }

  Future<void> fetchSelfDrive() async {
    String userToken =
        Provider.of<AuthController>(Get.context!, listen: false).getUserToken();
    final response = await http.get(
      Uri.parse(AppConstants.baseUrl + AppConstants.selfOrderUrl),
      headers: {
        'Authorization': 'Bearer $userToken',
        'Content-Type': 'application/json',
      },
    );
    print('Api response self driver ${response.body}');
    if (response.statusCode == 200) {
      setState(() {
        selfOrderModelList.clear();
        var data = jsonDecode(response.body);
        List selfList = data['data'];
        selfOrderModelList.addAll(selfList.map((e) => SelfList.fromJson(e)));
      });
    }
  }

  List<SelfLoaction> selfLocations = <SelfLoaction>[];
  final _formKey = GlobalKey<FormState>();
  List<CategoryCar> categoryTypeList = [];
  CategoryCar? _selectedRideType;

  void _updateSelfReturnTime() {
    if (pickupDateTime != null && _selfSelectedHours > 0) {
      returnDateTime = pickupDateTime!
          .add(Duration(minutes: (_selfSelectedHours * 60).toInt()));
    }
  }

  void getType() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? referralCode = prefs.getString('referral_code');

      String url = '/api/v1/self-vehicle/cab-category?status=1&city=$selectedLocation';
      if (referralCode != null && referralCode.isNotEmpty) {
        url += "&active_agent_code=$referralCode";
      }

      var res = await HttpService().getApi(url);

      print("api location category $res");
      if (res['status'] == 1 && res['data'] != null) {
        setState(() {
          categoryTypeList = List<CategoryCar>.from(
            res['data'].map((x) => CategoryCar.fromJson(x)),
          );

          // Default select first or clear selection
          if (categoryTypeList.isNotEmpty) {
            _selectedRideType = categoryTypeList.first;
          } else {
            _selectedRideType = null;
          }
        });
      } else {
        setState(() {
          categoryTypeList = [];
          _selectedRideType = null;
        });
      }
    } catch (e) {
      print('Error fetching categories: $e');
      setState(() {
        categoryTypeList = [];
        _selectedRideType = null;
      });
    }
  }

  Future<double> fetchDistanceValue(
      String pLat, String pLng, String dLat, String dLng) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? referralCode = prefs.getString('referral_code');

      Map<String, dynamic> data = {
        'pick_lat': pLat,
        'pick_long': pLng,
        'drop_lat': dLat,
        'drop_long': dLng,
        if (referralCode != null && referralCode.isNotEmpty)
          "active_agent_code": referralCode,
      };

      var res = await HttpService().postApi('/api/v1/self-vehicle/get-distance', data);
      if (res['status'] == 1 && res['data'] != null) {
        var val = res['data']['distance_km'];
        return (val is String) ? double.parse(val) : (val as num).toDouble();
      }
    } catch (e) {
      print('Error fetching segment distance: $e');
    }
    return 0.0;
  }

  Future<void> updateTotalDistances() async {
    if (fromLatitude.isEmpty || toLatitude.isEmpty) return;

    double forwardTotal = 0.0;

    // Segment 1: Pickup to Drop 1
    double d1 = await fetchDistanceValue(
        fromLatitude, fromLongitude, toLatitude, toLongitude);
    forwardTotal += d1;

    // Intermediate segments: Drop 1 to Multi 1, Multi 1 to Multi 2...
    String prevLat = toLatitude;
    String prevLng = toLongitude;

    for (int i = 0; i < _multiDropLats.length; i++) {
      if (_multiDropLats[i].isNotEmpty && _multiDropLngs[i].isNotEmpty) {
        double d = await fetchDistanceValue(
            prevLat, prevLng, _multiDropLats[i], _multiDropLngs[i]);
        forwardTotal += d;
        prevLat = _multiDropLats[i];
        prevLng = _multiDropLngs[i];
      }
    }

    if (mounted) {
      setState(() {
        distanceKm = forwardTotal;
      });
    }

    if (_tripType == 'two-way') {
      // Return Segment: Last Point back to Pickup
      double dr = await fetchDistanceValue(
          prevLat, prevLng, fromLatitude, fromLongitude);
      if (mounted) {
        setState(() {
          returnDistanceKm = dr;
        });
      }
    } else {
      if (mounted) {
        setState(() {
          returnDistanceKm = 0.0;
        });
      }
    }
  }

  void getDistance(Map<String, dynamic> data, bool isReturn) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? referralCode = prefs.getString('referral_code');

      if (referralCode != null && referralCode.isNotEmpty) {
        data["active_agent_code"] = referralCode;
      }

      var res = await HttpService()
          .postApi('/api/v1/self-vehicle/get-distance', data);
      print('Api response for distance $res');
      if (isReturn) {
        if (res['status'] == 1 && res['data'] != null) {
          setState(() {
            var distanceValue = res['data']['distance_km'];

            returnDistanceKm = (distanceValue is String)
                ? double.parse(distanceValue)
                : (distanceValue as num).toDouble();
          });
        }
      } else {
        if (res['status'] == 1 && res['data'] != null) {
          setState(() {
            var distanceValue = res['data']['distance_km'];

            distanceKm = (distanceValue is String)
                ? double.parse(distanceValue)
                : (distanceValue as num).toDouble();
          });
        }
      }
    } catch (e) {
      print('Error fetching categories: $e');
    }
  }

  void getLocationSelf() async {
    final prefs = await SharedPreferences.getInstance();
    final String? referralCode = prefs.getString('referral_code');

    String url = '/api/v1/self-vehicle/get-location?self_tour_type=hour';
    if (referralCode != null && referralCode.isNotEmpty) {
      url += "&active_agent_code=$referralCode";
    }

    var res = await HttpService().getApi(url);

    print('api response for location $res');

    if (res['status'] == 1 && res['data'] != null) {
      setState(() {
        List location = res['data'];
        selfLocations.addAll(location.map((e) => SelfLoaction.fromJson(e)));
      });
    }
  }

  void _openLocationSheet(BuildContext context) async {
    final result = await Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (context) => SelfLocationSearchScreen(
          locations: selfLocations,
          hintText: 'Select Pickup Location',
        ),
      ),
    );

    if (result != null && result is SelfLoaction) {
      setState(() {
        selectedLocation = result.city;
        _fromLocation.text = result.city ?? '';
        fromLatitude = result.lat.toString();
        fromLongitude = result.lng.toString();
      });
      getType();
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatTime(DateTime date) {
    final hour = date.hour > 12 ? date.hour - 12 : date.hour;
    final period = date.hour >= 12 ? 'PM' : 'AM';
    return '${hour == 0 ? 12 : hour}:${date.minute.toString().padLeft(2, '0')} $period';
  }

  double calculateTotalHours({
    required DateTime pickDateTime,
    required DateTime dropDateTime,
  }) {
    final duration = dropDateTime.difference(pickDateTime);

    if (duration.isNegative) return 0;

    return duration.inMinutes / 60;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _tripType = widget.type;
    
    // Sync leadBookingType with initial trip type
    if (_tripType == 'self') {
      leadBookingType = 'self_drive';
    } else if (_tripType == 'local') {
      leadBookingType = 'local';
    } else if (_tripType == 'two-way') {
      leadBookingType = 'round';
    } else if (_tripType == 'one-way') {
      leadBookingType = 'oneway';
    } else {
      leadBookingType = _tripType;
    }

    getLocationSelf();
    fetchSelfDrive();
    fetchAllowedCities();
  }

  String getTripTypeName(String tripType) {
    switch (tripType) {
      case 'self':
        return 'Self Driving';
      case 'local':
        return 'Local Booking';
      case 'order':
        return 'Trip Booking';
      case 'two-way':
        return 'Round Trip';
      case 'one-way':
        return 'One Way Trip';
      default:
        return 'Booking';
    }
  }

  void _openDualLocationSearch({bool focusDrop = false}) async {
    final result = await Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (context) => DualLocationSearchScreen(
          allowedPickupCities: allowedCities,
          initialPickup: _fromLocation.text,
          initialDrop: _toLocation.text,
          focusDrop: focusDrop,
        ),
      ),
    );

    if (result != null && result is Map<String, dynamic>) {
      final pickup = result['pickup'];
      final drop = result['drop'];

      setState(() {
        if (pickup != null) {
          _fromLocation.text = pickup['description'];
          selectedLocation = pickup['description'];
          fromLatitude = pickup['lat'].toString();
          fromLongitude = pickup['lng'].toString();
          distanceKm = 0.0;
          returnDistanceKm = 0.0;
        }
        if (drop != null) {
          _toLocation.text = drop['description'];
          toLatitude = drop['lat'].toString();
          toLongitude = drop['lng'].toString();

          if (_tripType != 'one-way') {
            _returnLocation.text = _fromLocation.text;
          }
        }
      });

      updateTotalDistances();

      // Update Map
      if (pickup != null) {
        _controller?.animateCamera(CameraUpdate.newLatLngZoom(
            LatLng(pickup['lat'], pickup['lng']), 14));
      } else if (drop != null) {
        _controller?.animateCamera(
            CameraUpdate.newLatLngZoom(LatLng(drop['lat'], drop['lng']), 14));
      }
    }
  }

  String _formatOrderDate(String dateStr) {
    if (dateStr.isEmpty) return 'N/A';
    try {
      DateTime dt = DateTime.parse(dateStr);
      return DateFormat('dd MMM yy').format(dt);
    } catch (e) {
      return dateStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    double totalHours = 0;
    if (pickupDateTime != null && returnDateTime != null) {
      totalHours = calculateTotalHours(
        pickDateTime: pickupDateTime!,
        dropDateTime: returnDateTime!,
      );
    }

    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
        margin: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.12),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _fabTab(
                icon: Icons.trending_flat,
                label: 'One',
                type: 'one-way',
                leadType: 'oneway'),
            // _fabTab(
            //     icon: Icons.swap_horiz,
            //     label: 'Round',
            //     type: 'two-way',
            //     leadType: 'round'
            // ),
            _fabTab(
                icon: Icons.location_city,
                label: 'Local',
                type: 'local',
                leadType: 'local'),
            _fabTab(
                icon: Icons.directions_car,
                label: 'Self',
                type: 'self',
                leadType: 'self_drive'),
            _fabTab(
                icon: Icons.flash_on_outlined,
                label: 'Instant',
                type: 'instant',
                leadType: 'instant'),
            _fabTab(
                icon: Icons.article,
                label: 'Order',
                type: 'order',
                leadType: 'order'),
          ],
        ),
      ),
      appBar: _tripType == 'instant'
          ? null
          : AppBar(
              centerTitle: true,
              elevation: 0,
              backgroundColor: Colors.transparent,
              flexibleSpace: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFF2196F3),
                      Color(0xFF1565C0),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.vertical(
                    bottom: Radius.circular(22),
                  ),
                ),
              ),
              title: Text(
                getTripTypeName(_tripType),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: 0.5,
                ),
              ),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded,
                    color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ),
      body: _tripType == 'instant'
          ? InstantHomePage()
          : _tripType == 'order'
              ? ListView.builder(
                  physics: BouncingScrollPhysics(),
                  shrinkWrap: true,
                  padding:
                      const EdgeInsets.only(left: 10, right: 10, bottom: 100),
                  itemCount: selfOrderModelList.length,
                  itemBuilder: (context, index) {
                    final order = selfOrderModelList[index];

                    return buildOrderCard(
                      image: order.thumbnail ?? '',
                      name: order.serviceName ?? '',
                      date: order.createdAt ?? '',
                      price: '${order.price}',
                      orderId: order.orderId?.toUpperCase() ?? '',
                      status: order.orderStatus ?? '',
                      statusColor: getStatusColor('${order.orderStatus}'),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CabBookingDetailsScreen(
                                id: order.id.toString()),
                          ),
                        );
                      },
                    );
                  },
                )
              : Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  margin: const EdgeInsets.fromLTRB(12, 12, 12, 140),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (_tripType == 'one-way' || _tripType == 'two-way') ...[
                          buildTripTypeSelector(
                            selectedType: _tripType,
                            onChanged: (value) {
                              setState(() {
                                _tripType = value;
                              });
                            },
                          ),
                          const SizedBox(height: 16),
                          Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                /// 📍 ROUTE SECTION
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade50,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(color: Colors.grey.shade100),
                                  ),
                                  child: Column(
                                    children: [
                                      Row(
                                        children: [
                                          _buildRouteIcon(isStart: true),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: LocationSelfWidget(
                                              hintText: 'Pickup Location',
                                              mapController: _controller,
                                              controller: _fromLocation,
                                              onTap: () => _openDualLocationSearch(focusDrop: false),
                                              onLocationSelected: (lat, lng, address) {
                                                setState(() {
                                                  fromLatitude = lat.toString();
                                                  fromLongitude = lng.toString();
                                                  distanceKm = 0.0;
                                                  returnDistanceKm = 0.0;
                                                  _toLocation.clear();
                                                  if (_tripType == 'two-way') {
                                                    _returnLocation.text = _fromLocation.text;
                                                    returnLatitude = fromLatitude;
                                                    returnLongitude = fromLongitude;
                                                  }
                                                });
                                                updateTotalDistances();
                                              },
                                              allowedCities: allowedCities,
                                            ),
                                          ),
                                        ],
                                      ),
                                      
                                      Row(
                                        children: [
                                          Container(
                                            width: 24,
                                            height: 30,
                                            alignment: Alignment.center,
                                            child: Container(width: 2, color: Colors.grey.shade300),
                                          ),
                                          const SizedBox(width: 12),
                                          Text(
                                            '${distanceKm.toStringAsFixed(1)} KM',
                                            style: TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.blue.shade400,
                                            ),
                                          ),
                                        ],
                                      ),

                                      Row(
                                        children: [
                                          _buildRouteIcon(isStart: false),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: LocationSearchWidget(
                                              hintText: 'Drop Location',
                                              mapController: _controller,
                                              controller: _toLocation,
                                              focusNode: dropFocusNode,
                                              onTap: () => _openDualLocationSearch(focusDrop: true),
                                              onLocationSelected: (lat, lng, address) {
                                                setState(() {
                                                  toLatitude = lat.toString();
                                                  toLongitude = lng.toString();
                                                  if (_tripType != 'one-way') {
                                                    _returnLocation.text = _fromLocation.text;
                                                    returnLatitude = fromLatitude;
                                                    returnLongitude = fromLongitude;
                                                  }
                                                });
                                                updateTotalDistances();
                                              },
                                            ),
                                          ),
                                        ],
                                      ),

                                      if (_tripType == 'two-way') ...[
                                        ...List.generate(_multiDropControllers.length, (index) {
                                          return Column(
                                            children: [
                                              Row(
                                                children: [
                                                  Container(width: 24, height: 10, alignment: Alignment.center, child: Container(width: 2, color: Colors.grey.shade300)),
                                                  const SizedBox(width: 12),
                                                ],
                                              ),
                                              Row(
                                                children: [
                                                  _buildRouteIcon(isMid: true),
                                                  const SizedBox(width: 12),
                                                  Expanded(
                                                    child: LocationSearchWidget(
                                                      hintText: 'Additional Stop',
                                                      mapController: _controller,
                                                      controller: _multiDropControllers[index],
                                                      onLocationSelected: (lat, lng, address) {
                                                        setState(() {
                                                          _multiDropLats[index] = lat.toString();
                                                          _multiDropLngs[index] = lng.toString();
                                                        });
                                                        updateTotalDistances();
                                                      },
                                                    ),
                                                  ),
                                                  IconButton(
                                                    onPressed: () {
                                                      setState(() {
                                                        _multiDropControllers.removeAt(index);
                                                        _multiDropLats.removeAt(index);
                                                        _multiDropLngs.removeAt(index);
                                                      });
                                                      updateTotalDistances();
                                                    },
                                                    icon: const Icon(Icons.remove_circle_outline, color: Colors.red, size: 20),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          );
                                        }),
                                        const SizedBox(height: 8),
                                        TextButton.icon(
                                          onPressed: () {
                                            setState(() {
                                              _multiDropControllers.add(TextEditingController());
                                              _multiDropLats.add('');
                                              _multiDropLngs.add('');
                                            });
                                          },
                                          icon: const Icon(Icons.add_location_alt_outlined, size: 18),
                                          label: const Text('Add Stop', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                                          style: TextButton.styleFrom(
                                            foregroundColor: Colors.blue,
                                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                            minimumSize: Size.zero,
                                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),

                                const SizedBox(height: 16),

                                /// 📅 SCHEDULE SECTION
                                Row(
                                  children: [
                                    Expanded(
                                      child: _dateTimeTileCompact(
                                        title: 'Pickup',
                                        value: pickupDateTime,
                                        onTap: () => _selectDateTime(context: context, isPickup: true),
                                      ),
                                    ),
                                    if (_tripType == 'two-way') ...[
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: _dateTimeTileCompact(
                                          title: 'Return',
                                          value: returnDateTime,
                                          onTap: () => _selectDateTime(context: context, isPickup: false),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),

                                if (_tripType == 'two-way' && returnDistanceKm > 0)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 8, left: 4),
                                    child: Text(
                                      'Return: ${returnDistanceKm.toStringAsFixed(1)} KM extra included',
                                      style: TextStyle(fontSize: 11, color: Colors.grey.shade600, fontStyle: FontStyle.italic),
                                    ),
                                  ),

                                const SizedBox(height: 24),

                                /// SUBMIT BUTTON
                                if (_isFormReady())
                                  _buildSubmitButton()
                                else
                                  _buildDisabledButton(),
                              ],
                            ),
                          )
                        ],

                        if (_tripType == 'local') _buildLocalTripForm(context),
                        if (_tripType == 'self') _buildSelfDrivingForm(totalHours),
                      ],
                    ),
                  ),
                ),
    );
  }

  Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.blue;
      case 'cancel':
        return Colors.red;
      case 'rejected':
        return Colors.red;
      case 'confirmed':
        return Colors.green;
      default:
        return Colors.orange; // Default color for unknown statuses
    }
  }

  Widget _fabTab({
    required IconData icon,
    required String label,
    required String type,
    required String leadType,
  }) {
    final bool isActive = _tripType == type;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _tripType = type;
            leadBookingType = leadType;
            // _fromLocation.clear();
            // _toLocation.clear();
            //  _returnLocation.clear();
            //  pickupDateTime = null;
            //  returnDateTime = null;
            distanceKm = 0.0;
            returnDistanceKm = 0.0;
            _selfSelectedHours = 0.0;
            _manualHourController.clear();
            for (var controller in _multiDropControllers) {
                controller.dispose();
              }
              _multiDropControllers.clear();
              _multiDropLats.clear();
              _multiDropLngs.clear();
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isActive
                ? Colors.blue.withOpacity(0.08)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon with scale animation
              AnimatedScale(
                scale: isActive ? 1.1 : 1.0,
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOutBack,
                child: Icon(
                  icon,
                  size: 24,
                  color: isActive ? Colors.blue : Colors.grey.shade600,
                ),
              ),

              const SizedBox(height: 6),

              // Label
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isActive ? Colors.blue : Colors.grey.shade700,
                ),
                child: Text(label),
              ),

              const SizedBox(height: 6),

              // Bottom indicator
              AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOut,
                height: 3,
                width: isActive ? 24 : 0,
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildOrderCard({
    required String image,
    required String name,
    required String price,
    required String orderId,
    required String date,
    required String status,
    required Color statusColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey.shade100),
          gradient: LinearGradient(
            colors: [
              Colors.white,
              Colors.grey.shade50,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            /// 🚗 IMAGE
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.network(
                image,
                width: 130,
                height: 90,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 130,
                    height: 90,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.directions_car,
                      size: 36,
                      color: Colors.grey,
                    ),
                  );
                },
              ),
            ),

            const SizedBox(width: 16),

            /// 📄 DETAILS
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// 🔤 Service Name
                  Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.3,
                      color: Colors.black87,
                    ),
                  ),

                  const SizedBox(height: 8),

                  /// 🆔 Order ID
                  Text(
                    'Order ID: $orderId',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.5,
                      color: Colors.grey.shade600,
                    ),
                  ),

                  /// 🆔 Order ID\
                   const SizedBox(height: 8),
                  Text(
                    'Date: ${_formatOrderDate(date)}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.5,
                      color: Colors.grey.shade600,
                    ),
                  ),

                  const SizedBox(height: 12),

                  /// 💰 Price + Status
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      /// Price
                      Text(
                        '₹$price',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.4,
                          color: Colors.blue,
                        ),
                      ),

                      /// Status Badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              statusColor.withOpacity(0.25),
                              statusColor.withOpacity(0.10),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(
                            color: statusColor.withOpacity(0.4),
                          ),
                        ),
                        child: Text(
                          status.toUpperCase(),
                          style: TextStyle(
                            color: statusColor,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.8,
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

  Widget _selfHourTab(String label, double hours) {
    final bool isActive = _selectedHour == label;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedHour = label;
            _selfSelectedHours = hours;
            _manualHourController.clear();
            _updateSelfReturnTime();
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            gradient: isActive
                ? const LinearGradient(
                    colors: [
                      Color(0xFFFE844F),
                      Color(0xFFFEC300),
                    ],
                  )
                : null,
            color: isActive ? null : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(12),
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: Colors.orange.withOpacity(0.35),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : [],
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: isActive ? Colors.white : Colors.grey.shade700,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSelfDrivingForm(double? totalHours) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// Label
        Text(
          'Pickup Location',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () => _openLocationSheet(context),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Row(
              children: [
                const Icon(Icons.location_on_outlined,
                    color: Colors.blue),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    selectedLocation ?? 'Select Location',
                    style: TextStyle(
                      fontSize: 16,
                      color: selectedLocation == null
                          ? Colors.grey.shade600
                          : Colors.blue.shade900,
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const Icon(Icons.keyboard_arrow_down, color: Colors.blue),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),

        GestureDetector(
          onTap: () => _selectDateTime(context: context, isPickup: true),
          child: _dateTimeTile(
            title: 'Pickup Date & Time',
            value: pickupDateTime,
            icon: Icons.login,
          ),
        ),

        const SizedBox(height: 20),
        Text(
          'Select Duration',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            _selfHourTab('4 HRS', 4.0),
            const SizedBox(width: 6),
            _selfHourTab('8 HRS', 8.0),
            const SizedBox(width: 6),
            _selfHourTab('12 HRS', 12.0),
          ],
        ),

        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: TextField(
            controller: _manualHourController,
            keyboardType: TextInputType.number,
            style: const TextStyle(fontWeight: FontWeight.bold),
            onChanged: (val) {
              setState(() {
                _selectedHour = 'manual';
                _selfSelectedHours = double.tryParse(val) ?? 0.0;
                _updateSelfReturnTime();
              });
            },
            decoration: InputDecoration(
              hintText: 'Enter manual hours...',
              hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
              prefixIcon: const Icon(Icons.edit_calendar_outlined, size: 20),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ),

        const SizedBox(height: 12),
        if (returnDateTime != null)
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.05),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.logout_rounded,
                      size: 16, color: Colors.blue),
                  const SizedBox(width: 8),
                  Text(
                    'Return: ${DateFormat('dd MMM, hh:mm aa').format(returnDateTime!)}',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Colors.blue,
                    ),
                  ),
                ],
              ),
            ),
          ),

        categoryTypeList.isEmpty
            ? SizedBox.shrink()
            :  SizedBox(height: 15),
        categoryTypeList.isEmpty
            ? SizedBox.shrink()
            : SizedBox(
                height: 46,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: categoryTypeList.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (context, index) {
                    final item = categoryTypeList[index];
                    final bool selected = _selectedRideType?.id == item.id;

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedRideType = item;
                        });
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        decoration: BoxDecoration(
                          gradient: selected
                              ? LinearGradient(
                                  colors: [
                                    Colors.blue.shade400,
                                    Colors.blue.shade600,
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                )
                              : null,
                          color: selected ? null : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: selected
                                ? Colors.blue
                                : Colors.grey.shade300,
                          ),
                          boxShadow: selected
                              ? [
                                  BoxShadow(
                                    color: Colors.blue.withOpacity(0.25),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ]
                              : [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.04),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            /// TEXT
                            Text(
                              item.enBrandName,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: selected ? Colors.white : Colors.black87,
                              ),
                            ),

                            const SizedBox(width: 10),

                            /// SMOOTH RADIO DOT
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 250),
                              width: 16,
                              height: 16,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: selected ? Colors.white : Colors.grey,
                                  width: 2,
                                ),
                              ),
                              child: selected
                                  ? Center(
                                      child: Container(
                                        width: 8,
                                        height: 8,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Colors.white,
                                          boxShadow: [
                                            BoxShadow(
                                              color:
                                                  Colors.white.withOpacity(0.8),
                                              blurRadius: 6,
                                            ),
                                          ],
                                        ),
                                      ),
                                    )
                                  : null,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
        const SizedBox(
          height: 20,
        ),
        if (returnDateTime != null &&
            pickupDateTime != null &&
            selectedLocation != null &&
            categoryTypeList.isNotEmpty)
          _buildSubmitButton(totalHours: _selfSelectedHours),
        if (returnDateTime == null ||
            pickupDateTime == null ||
            selectedLocation == null ||
            categoryTypeList.isEmpty)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.grey, // warm orange
                  Colors.grey.shade300, // deep orange
                ],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.35),
                  blurRadius: 14,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: const Center(
              child: Text(
                'Book Trip',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _hourTab(String label, double kilo) {
    final bool isActive = _selectedHour == label;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedHour = label;
            distanceKm = kilo;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            gradient: isActive
                ? const LinearGradient(
              colors: [
                Color(0xFF2196F3),
                Color(0xFF1565C0),
              ],
                  )
                : null,
            color: isActive ? null : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(12),
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: Colors.orange.withOpacity(0.35),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : [],
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: isActive ? Colors.white : Colors.grey.shade700,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLocalTripForm(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // From Location
          // Pickup Location
          // _buildLocationField(
          //   label: 'Pickup Location',
          //   icon: Icons.my_location_rounded,
          //   value: _toLocation,
          //   onChanged: (val) {
          //     setState(() {
          //       _toLocation = val;
          //     });
          //   },
          //   onSaved: (val) => _toLocation = val ?? '',
          // ),
          Text(
            'Pickup Location',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 8),
          LocationSelfWidget(
            hintText: 'Pickup Location',
            mapController: _controller,
            controller: _fromLocation,
            onLocationSelected: (lat, lng, address) {
              setState(() {
                fromLatitude = lat.toString();
                fromLongitude = lng.toString();
                distanceKm = 0.0;
                returnDistanceKm = 0.0;
                _toLocation.clear();
              });

              // onLocationSelect();
            }, allowedCities: allowedCities,
          ),
          // _buildLocationField(
          //   label: 'From Location',
          //   icon: Icons.location_on_outlined,
          //   value: _fromLocation,
          //   onChanged: (value) {
          //     setState(() {
          //       _fromLocation = value;
          //     });
          //   },
          //   onSaved: (value) {
          //     _fromLocation = value ?? '';
          //   },
          // ),

          // To location
          // const SizedBox(height: 5),
          // Center(
          //   child: Row(
          //     mainAxisSize: MainAxisSize.min,
          //     children: [
          //       const Icon(
          //         Icons.arrow_upward,
          //         size: 16,
          //         color: Colors.blue,
          //       ),
          //       Text(
          //         '${distanceKm.toStringAsFixed(2)} km',
          //         style: const TextStyle(
          //           fontSize: 14,
          //           fontWeight: FontWeight.w700,
          //           color: Colors.blue,
          //         ),
          //       ),
          //       const Icon(
          //         Icons.arrow_downward,
          //         size: 16,
          //         color: Colors.blue,
          //       ),
          //     ],
          //   ),
          // ),
          // const SizedBox(height: 10),
          //
          // LocationSelfWidget(
          //   hintText: 'Drop Location',
          //   mapController: _controller,
          //   controller: _toLocation,
          //   onLocationSelected: (lat, lng, address) {
          //     setState(() {
          //       toLatitude = lat.toString();
          //       toLongitude = lng.toString();
          //       double fromLat = double.tryParse(fromLatitude) ?? 0.0;
          //       double fromLng = double.tryParse(fromLongitude) ?? 0.0;
          //       double toLat   = double.tryParse(toLatitude) ?? 0.0;
          //       double toLng   = double.tryParse(toLongitude) ?? 0.0;
          //       distanceKm = calculateDistanceKm(
          //         startLat: fromLat,
          //         startLng: fromLng,
          //         endLat: toLat,
          //         endLng: toLng,
          //       );
          //       _returnLocation.text = _toLocation.text;
          //     });
          //     // onLocationSelect();
          //   },
          // ),

          const SizedBox(height: 10),

          // Date & Time Row
          GestureDetector(
            onTap: () => _selectDateTime(context: context, isPickup: true),
            child: _dateTimeTile(
              title: 'Pickup Date & Time',
              value: pickupDateTime,
              icon: Icons.login,
            ),
          ),

          const SizedBox(height: 20),
          Row(
            children: [
              _hourTab('4 HRS | 40KM', 40.00),
              const SizedBox(width: 6),
              _hourTab('8 HRS | 80KM', 80.00),
              const SizedBox(width: 6),
              _hourTab('12 HRS | 120KM', 120.00),
            ],
          ),

          const SizedBox(height: 20),
          // Submit Button
          if (pickupDateTime != null &&
              _fromLocation.text.isNotEmpty &&
              _selectedHour.isNotEmpty)
            SizedBox(
              width: double.infinity,
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    isBtn = true;
                  });
                  getLeadGenerate('CAR', distanceKm);
                  // if((int.tryParse(_selectedKilometer) ?? 0) <= distanceKm.round()){
                  //   Navigator.push(
                  //     context,
                  //     CupertinoPageRoute(
                  //       builder: (context) => CarSelectionPage(
                  //         type: _tripType,
                  //         location: _toLocation.text,
                  //         pickDate: formatDate(pickupDateTime),
                  //         pickTime: formatTime(pickupDateTime),
                  //         dropDate: formatDate(returnDateTime),
                  //         dropTime: formatTime(returnDateTime),
                  //         totalHour: distanceKm,
                  //         categoryType: 'CAR',
                  //       ),
                  //     ),
                  //   );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFF2196F3),
                        Color(0xFF1565C0),
                      ],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blue.withOpacity(0.35),
                        blurRadius: 14,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Center(
                    child: isBtn
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            'Book Trip',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              letterSpacing: 0.5,
                            ),
                          ),
                  ),
                ),
              ),
            ),

          if (pickupDateTime == null ||
              _fromLocation.text.isEmpty ||
              _selectedHour.isEmpty)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.grey, // warm orange
                    Colors.grey.shade300, // deep orange
                  ],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.35),
                    blurRadius: 14,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Center(
                child: Text(
                  'Book Trip',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // Submit button
  Widget _buildSubmitButton({double? totalHours}) {
    return SizedBox(
      width: double.infinity,
      child: GestureDetector(
        onTap: () {
          setState(() {
            isBtn = true;
          });
          if (_tripType == 'self') {
            getLeadGenerate(
                '${_selectedRideType?.enBrandName}', totalHours ?? 0);
          } else {
            getLeadGenerate('CAR', calculateTotalTripDistance());
          }
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                Color(0xFF2196F3),
                Color(0xFF1565C0),
              ],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.blue.withOpacity(0.35),
                blurRadius: 14,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Center(
            child: isBtn
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text(
                    'Book Trip',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  bool _isFormReady() {
    if (_tripType == 'one-way') {
      return pickupDateTime != null && _toLocation.text.isNotEmpty && _fromLocation.text.isNotEmpty;
    } else if (_tripType == 'two-way') {
      return pickupDateTime != null && returnDateTime != null && _toLocation.text.isNotEmpty && _fromLocation.text.isNotEmpty;
    }
    return false;
  }

  Widget _buildDisabledButton() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Center(
        child: Text(
          'Book Trip',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildRouteIcon({bool isStart = false, bool isMid = false}) {
    return Column(
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isStart ? Colors.green.shade100 : (isMid ? Colors.amber.shade100 : Colors.red.shade100),
            border: Border.all(
              color: isStart ? Colors.green : (isMid ? Colors.amber : Colors.red),
              width: 2,
            ),
          ),
          child: Center(
            child: Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isStart ? Colors.green : (isMid ? Colors.amber : Colors.red),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _dateTimeTileCompact({
    required String title,
    required DateTime? value,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.calendar_today_outlined, size: 14, color: Colors.blue.shade400),
                const SizedBox(width: 6),
                Text(
                  title,
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey.shade600),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              value == null ? 'Select' : DateFormat('dd MMM, hh:mm aa').format(value),
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w900,
                color: value == null ? Colors.grey.shade400 : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Date selection method
  Widget _dateTimeTile({
    required String title,
    required DateTime? value,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.blue),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 13,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value == null
                    ? 'Select date & time'
                    : '${_formatDate(value)} • ${_formatTime(value)}',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildTripTypeSelector({
    required String selectedType,
    required Function(String) onChanged,
  }) {
    Widget button(String value, String text) {
      final isSelected = selectedType == value;
      return Expanded(
        child: GestureDetector(
          onTap: () {
            onChanged(value);
            returnDistanceKm = 0.0;
            distanceKm = 0.0;
            _selfSelectedHours = 0.0;
            _manualHourController.clear();
            _toLocation.clear();
            _returnLocation.clear();
            _selectedHour = '';
            leadBookingType = value == 'one-way' ? "oneway" : "round";

            if (value == 'one-way') {
              for (var controller in _multiDropControllers) {
                controller.dispose();
              }
              _multiDropControllers.clear();
              _multiDropLats.clear();
              _multiDropLngs.clear();
            }
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isSelected ? Colors.blue : Colors.transparent,
              borderRadius: BorderRadius.circular(30),
            ),
            child: Text(
              text,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.black,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      );
    }

    return Container(
      height: 50,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        children: [
          button('one-way', 'One Way'),
          button('two-way', 'Round Trip'),
        ],
      ),
    );
  }

  int getTotalDays() {
    if (pickupDateTime == null || returnDateTime == null) {
      return 1;
    }

    DateTime pickupDate = DateTime(
      pickupDateTime!.year,
      pickupDateTime!.month,
      pickupDateTime!.day,
    );

    DateTime returnDate = DateTime(
      returnDateTime!.year,
      returnDateTime!.month,
      returnDateTime!.day,
    );

    int days = returnDate.difference(pickupDate).inDays + 1;

    return days;
  }

  // Time selection method
  Future<void> _selectDateTime({
    required BuildContext context,
    required bool isPickup,
  }) async {

    DateTime now = DateTime.now();

    DateTime firstDate = isPickup
        ? now
        : (pickupDateTime ?? now);

    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: firstDate,
      firstDate: firstDate,
      lastDate: now.add(const Duration(days: 365)),
    );

    if (pickedDate == null) return;

    TimeOfDay? pickedTime;
    DateTime finalDateTime;

    while (true) {

      /// ✅ SINGLE TIME PICKER (with theme)
      pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              timePickerTheme: const TimePickerThemeData(
                backgroundColor: Colors.white,
                hourMinuteTextColor: Colors.blue,
                dayPeriodTextColor: Colors.blue,
                dialHandColor: Colors.blue,
                dialBackgroundColor: Color(0xFFFFE0B2),
                hourMinuteColor: Color(0xFFFFF3E0),
                entryModeIconColor: Colors.blue,
              ),
              colorScheme: const ColorScheme.light(
                primary: Colors.blue,
                secondary: Colors.blue, // 🔥 important
                onPrimary: Colors.white,
                onSurface: Colors.black,
              ),
            ),
            child: child!,
          );
        },
      );

      if (pickedTime == null) return;

      finalDateTime = DateTime(
        pickedDate.year,
        pickedDate.month,
        pickedDate.day,
        pickedTime.hour,
        pickedTime.minute,
      );

      /// 🔥 VALIDATION
      if (isPickup) {

        /// ❌ Past time
        if (finalDateTime.isBefore(now)) {
          Fluttertoast.showToast(
              msg: 'Past time',
              backgroundColor: Colors.red,
              textColor: Colors.white);
          continue;
        }

        /// ❌ Same time (optional safety)
        if (pickupDateTime != null &&
            finalDateTime.isAtSameMomentAs(pickupDateTime!)) {
          Fluttertoast.showToast(
              msg: 'Same time',
              backgroundColor: Colors.red,
              textColor: Colors.white);
          continue;
        }

      } else {

        /// ❌ Return must be after pickup (same day allowed)
        if (pickupDateTime != null &&
            !finalDateTime.isAfter(pickupDateTime!)) {
          Fluttertoast.showToast(
              msg: 'Please select a return time after the pickup time',
              backgroundColor: Colors.red,
              textColor: Colors.white);
          continue;
        }
      }

      break;
    }

    /// ✅ SET STATE
    setState(() {
      if (isPickup) {
        pickupDateTime = finalDateTime;

        if (_tripType == 'self') {
          _updateSelfReturnTime();
        } else {
          /// reset return if invalid
          if (returnDateTime != null &&
              !returnDateTime!.isAfter(pickupDateTime!)) {
            returnDateTime = null;
          }
        }
      } else {
        returnDateTime = finalDateTime;
      }
    });
  }
}

class CategoryCar {
  final int id;
  final String enBrandName;
  final String hiBrandName;
  final String image;

  CategoryCar({
    required this.id,
    required this.enBrandName,
    required this.hiBrandName,
    required this.image,
  });

  // Factory constructor to create Category from JSON
  factory CategoryCar.fromJson(Map<String, dynamic> json) {
    return CategoryCar(
      id: json['id'] ?? 0,
      enBrandName: json['en_brand_name'] ?? '',
      hiBrandName: json['hi_brand_name'] ?? '',
      image: json['image'] ?? '',
    );
  }

  // Convert Category to JSON if needed
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'en_brand_name': enBrandName,
      'hi_brand_name': hiBrandName,
      'image': image,
    };
  }
}

class SelfLoaction {
  String? city;
  double? lat;
  double? lng;

  SelfLoaction({
    this.city,
    this.lat,
    this.lng,
  });

  factory SelfLoaction.fromJson(Map<String, dynamic> json) => SelfLoaction(
        city: json["city"],
        lat: json["lat"]?.toDouble(),
        lng: json["lng"]?.toDouble(),
      );

  Map<String, dynamic> toJson() => {
        "city": city,
        "lat": lat,
        "lng": lng,
      };
}
