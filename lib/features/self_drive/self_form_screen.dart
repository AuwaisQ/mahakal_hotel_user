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
import 'instant_detail_screen.dart';
import 'instanthome_page.dart';

class TripBookingPage extends StatefulWidget {
  final String type;
  const TripBookingPage({super.key,required this.type});

  @override
  State<TripBookingPage> createState() => _TripBookingPageState();
}

class _TripBookingPageState extends State<TripBookingPage> {
  // Form variables

  bool isBtn = false;
  String _selectedHour = '';
  String _selectedKilometer = '';
  String _tripType = 'one-way'; // 'one-way' or 'two-way or 'local' or 'self'
  String leadBookingType = 'oneway'; // 'one-way' or 'two-way or 'local' or 'self'
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

  void getLeadGenerate(String categoryType , double totalHour) async {
    final prefs = await SharedPreferences.getInstance();
    int? leadId = prefs.getInt('self_lead_id');   // SharedPreferences se id

    var res = await HttpService().postApi(
      '/api/v1/self-vehicle/vehicle-create-lead',
      {
        'lead_id': leadId == 0 ? '' : leadId,   // 🔥 yaha dynamic id
        'booking_type': leadBookingType,
        'person_phone': Provider.of<ProfileController>(Get.context!, listen: false,).userPHONE,

        'pickup_address': _fromLocation.text,
        'pickup_lat': fromLatitude,
        'pickup_long': fromLongitude,
        'pickup_date': formatDateLead(pickupDateTime),

        'drop_address': _toLocation.text,
        'drop_lat': toLatitude,
        'drop_long': toLongitude,

        'return_address': _returnLocation.text,
        'return_lat': returnLatitude,
        'return_long': returnLongitude,
        'return_date': '',

        'booking_pick_km': distanceKm.toString(),
        'booking_return_km': returnDistanceKm.toString(),
        // 'wallet_type': 1,
        // 'order_amount': 20000,
        // 'price': 20000,
        // 'booking_cab_ac': '',
      },
    );
    print('APi response for lead generate $res');
    if (res['status'] == 1) {
      setState(() {

      });
      String newLeadId = res['data']['lead_id'].toString();

      // 🔥 agar naya lead_id aaya hai to update bhi kar sakte ho
      await prefs.setInt('self_lead_id', int.parse(newLeadId));

      Navigator.push(context,
        CupertinoPageRoute(
          builder: (context) => CarSelectionPage(
            type: _tripType,
            location: selectedLocation ?? _fromLocation.text,
            pickDate: formatDate(pickupDateTime),
            pickTime: formatTime(pickupDateTime),
            dropDate: formatDate(returnDateTime),
            dropTime: formatTime(returnDateTime),
            totalHour: totalHour,
            categoryType: categoryType,
            leadId: newLeadId, carType: categoryTypeList,
          ),
        ),
      );
      setState(() {
        isBtn = false;
      });
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


  void getType() async {
    try {
      var res = await HttpService().getApi('/api/v1/self-vehicle/cab-category?status=1');

      if (res['status'] == 1 && res['data'] != null) {
        setState(() {
          categoryTypeList = List<CategoryCar>.from(
            res['data'].map((x) => CategoryCar.fromJson(x)),
          );

          // Default select first
          if (categoryTypeList.isNotEmpty) _selectedRideType = categoryTypeList.first;
        });
      }
    } catch (e) {
      print('Error fetching categories: $e');
    }
  }

  void getDistance(Map<String, dynamic> data,bool isReturn) async {
    try {
      var res = await HttpService().postApi('/api/v1/self-vehicle/get-distance',data);
      print('Api response for distance $res');
      if(isReturn){
        if (res['status'] == 1 && res['data'] != null) {
          setState(() {
            var distanceValue = res['data']['distance_km'];

            returnDistanceKm = (distanceValue is String)
                ? double.parse(distanceValue)
                : (distanceValue as num).toDouble();
          });
        }
      }else{
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
    var res = await HttpService()
        .getApi('/api/v1/self-vehicle/get-location?self_tour_type=hour');

    print('api response for location $res');

    if (res['status'] == 1 && res['data'] != null) {
      setState(() {
        List location = res['data'];
        selfLocations.addAll(location.map((e)=> SelfLoaction.fromJson(e)));
      });
    }
  }

  void _openLocationSheet(BuildContext context) {
    TextEditingController searchCtrl = TextEditingController();
    List<SelfLoaction> filteredList = List.from(selfLocations);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [

                  /// drag handle
                  Container(
                    margin: const EdgeInsets.only(top: 20, bottom: 12),
                    height: 4,
                    width: 40,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),

                  /// SEARCH FIELD
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: TextField(
                      controller: searchCtrl,
                      onChanged: (value) {
                        setSheetState(() {
                          filteredList = selfLocations
                              .where((e) =>
                              (e.city ?? '').toLowerCase().contains(value.toLowerCase()))
                              .toList();
                        });
                      },
                      decoration: InputDecoration(
                        hintText: 'Search location',
                        prefixIcon:
                        const Icon(Icons.search, color: Colors.blue),
                        filled: true,
                        fillColor: Colors.blue.shade50,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  /// LIST
                  Flexible(
                    child: ListView.builder(
                      itemCount: filteredList.length,
                      itemBuilder: (context, index) {
                        final item = filteredList[index];
                        return ListTile(
                          leading: const Icon(Icons.location_on,
                              color: Colors.blue),
                          title: Text(
                            '${item.city}',
                            style: TextStyle(
                              color: Colors.blue.shade900,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          onTap: () {
                            setState(() {
                              selectedLocation = item.city;
                              fromLatitude = item.lat.toString();
                              fromLongitude = item.lng.toString();
                            });
                            Navigator.pop(context);
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
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
    getLocationSelf();
    getType();
    fetchSelfDrive();
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
                leadType: 'oneway'
            ),
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
                leadType: 'local'
            ),
            _fabTab(
                icon: Icons.directions_car,
                label: 'Self',
                type: 'self',
                leadType: 'self_drive'
            ),
            _fabTab(
                icon: Icons.flash_on_outlined,
                label: 'Instant',
                type: 'instant',
                leadType: 'instant'
            ),
            _fabTab(
                icon: Icons.article,
                label: 'Order',
                type: 'order',
                leadType: 'order'
            ),
          ],
        ),
      ),

      appBar: _tripType == 'instant' ? null : AppBar(
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFF18FFFF),
                Color(0xFF2261FF),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.vertical(
              bottom: Radius.circular(22),
            ),
          ),
        ),
        title: Text(getTripTypeName(_tripType),
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Colors.white,
            letterSpacing: 0.5,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),


      body:
      _tripType == 'instant'
          ? AppConstants.baseUrl == 'https://mahakal.com' ?  Center(
            child: Container(
              height: 240,
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF4A90E2), Color(0xFF6A5AE0)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.withOpacity(0.25),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  )
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  /// 🚀 TITLE
                  Row(
                    children: const [
                      Icon(Icons.flash_on, color: Colors.yellow, size: 26),
                      SizedBox(width: 8),
                      Text(
                        "Instant Booking",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  /// 🔥 TAG
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      "Coming Soon 🚀",
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),

                  const SizedBox(height: 16),

                  /// 📄 DESCRIPTION
                  const Text(
                    "Get ready for lightning-fast order assignments with our upcoming Instant Booking feature. "
                        "Accept orders instantly, reduce waiting time, and boost your daily earnings effortlessly.",
                    style: TextStyle(
                      fontSize: 13.5,
                      color: Colors.white,
                      height: 1.4,
                    ),
                  ),

                  const Spacer(),

                ],
              ),
            )
          ) : InstantHomePage() :
      _tripType == 'order'
          ? ListView.builder(
        physics: BouncingScrollPhysics(),
        shrinkWrap: true,
        padding: const EdgeInsets.only(left: 10,right: 10,bottom: 100),
        itemCount: selfOrderModelList.length,
        itemBuilder: (context, index) {
          final order = selfOrderModelList[index];

          return buildOrderCard(
            image: order.thumbnail ?? '',
            name: order.serviceName ?? '',
            price: '${order.price}',
            orderId: order.orderId?.toUpperCase() ?? '',
            status: order.orderStatus ?? '',
            statusColor: getStatusColor('${order.orderStatus}'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      CabBookingDetailsScreen(id: order.id.toString()),
                ),
              );
            },
          );

        },
      )
          : Container(
        padding: const EdgeInsets.all(10),
        margin: const EdgeInsets.only(left: 10,right: 10,top: 15,bottom: 140),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: Colors.grey.shade100,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
               _tripType == 'one-way' || _tripType == 'two-way' ? SizedBox() : Column(
                children: [
                  const SizedBox(height: 10),
                  Row(
                    children: [

                      /// LEFT LINE
                      Expanded(
                        child: Container(
                          height: 2,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.transparent,
                                Colors.blue.withOpacity(0.6),
                              ],
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(width: 10),

                      /// ICON BADGE
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const LinearGradient(
                            colors: [
                              Colors.blue,
                              Colors.blue,
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.blue.withOpacity(0.4),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            )
                          ],
                        ),
                        child: const Icon(
                          CupertinoIcons.car_detailed,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),

                      const SizedBox(width: 10),

                      /// RIGHT LINE
                      Expanded(
                        child: Container(
                          height: 2,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.blue.withOpacity(0.6),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],
              ),




              // Trip type selector
              if (_tripType == 'one-way' || _tripType == 'two-way')...[
                const SizedBox(height: 10),
                buildTripTypeSelector(
                  selectedType: _tripType,
                  onChanged: (value) {
                    setState(() {
                      _tripType = value;
                    });
                  },
                ),
                SizedBox(height: 20,),
                // Main form
                // const SizedBox(height: 30),
                Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // From location
                      Text(
                        'Pickup Location',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      LocationSearchWidget(
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
                          FocusScope.of(context).requestFocus(dropFocusNode); // 👈 cursor move
                          // onLocationSelect();
                        },
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
                      const SizedBox(height: 5),
                        Center(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                                                    const Icon(
                                                      Icons.arrow_upward,
                                                      size: 16,
                                                      color: Colors.blue,
                                                    ),
                                                    Text(
                                                      '${distanceKm.toStringAsFixed(2)} km',
                                                      style: const TextStyle(
                                                        fontSize: 14,
                                                        fontWeight: FontWeight.w700,
                                                        color: Colors.blue,
                                                      ),
                                                    ),
                              const Icon(
                                Icons.arrow_downward,
                                size: 16,
                                color: Colors.blue,
                              ),
                            ],
                          ),
                        ),
                      const SizedBox(height: 10),
          
                      LocationSearchWidget(
                        hintText: 'Drop Location',
                        mapController: _controller,
                        controller: _toLocation,
                        focusNode: dropFocusNode,
                        onLocationSelected: (lat, lng, address) {
                          setState(() {
                            toLatitude = lat.toString();
                            toLongitude = lng.toString();
                            _returnLocation.text = _fromLocation.text;
                          });
                        Map<String, dynamic> data = {
                          'pick_lat':fromLatitude,
                          'pick_long':fromLongitude,
                          'drop_lat':toLatitude,
                          'drop_long':toLongitude
                        };
                          getDistance(data,false);
                          if (_tripType == 'two-way'){
                          returnDistanceKm = distanceKm;
                          FocusScope.of(context).requestFocus(dropFocusNode); // 👈 cursor move
                          }
                          // onLocationSelect();
                        },
                      ),
          
                      // Return location (only for two-way)
                      const SizedBox(height: 10),
                      if (_tripType == 'two-way')...[
                        returnDistanceKm == 0.0 ? const SizedBox.shrink() : Center(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.arrow_upward,
                                size: 16,
                                color: Colors.blue,
                              ),
                              Text(
                                '${returnDistanceKm.toStringAsFixed(2)} km',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.blue,
                                ),
                              ),
                              const Icon(
                                Icons.arrow_downward,
                                size: 16,
                                color: Colors.blue,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Return location',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        LocationSearchWidget(
                          hintText: 'Enter Return Location',
                          mapController: _controller,
                          controller: _returnLocation,
                          focusNode: returnFocusNode,
                          onLocationSelected: (lat, lng, address) {
                            setState(() {
                              returnLatitude = lat.toString();
                              returnLongitude = lng.toString();
                            });
                            Map<String, dynamic> data = {
                              'pick_lat':toLatitude,
                              'pick_long':toLongitude,
                              'drop_lat':returnLatitude,
                              'drop_long':returnLongitude
                            };
                            getDistance(data,true);
                            // onLocationSelect();
                          },
                        ),
                      ],
          
                      // Date and time pickers in a row
                      if (_tripType == 'two-way') const SizedBox(height: 20),
                      GestureDetector(
                        onTap: () => _selectDateTime(context: context, isPickup: true),
                        child: _dateTimeTile(
                          title: 'Pickup Date & Time',
                          value: pickupDateTime,
                          icon: Icons.login,
                        ),
                      ),
          
                      const SizedBox(height: 20),
          
                      // Return date and time (only for two-way)
                      if (_tripType == 'two-way')
                      GestureDetector(
                        onTap: () => _selectDateTime(context: context, isPickup: false),
                        child: _dateTimeTile(
                          title: 'Return Date & Time',
                          value: returnDateTime,
                          icon: Icons.logout,
                        ),
                      ),
          
                      if (_tripType == 'two-way') const SizedBox(height: 30),
          
                      // Submit button
                      if(pickupDateTime != null && _toLocation.text.isNotEmpty && _fromLocation.text.isNotEmpty)
                       _buildSubmitButton(),
          
                      if(pickupDateTime == null || _toLocation.text.isEmpty || _fromLocation.text.isEmpty)
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
                )
              ],
          
              if(_tripType == 'local')
                _buildLocalTripForm(context),
          
              if(_tripType == 'self')
                _buildSelfDrivingForm(totalHours),
          
              // if(_tripType == 'order')
              // ListView.builder(
              //   shrinkWrap: true,
              //   padding: const EdgeInsets.all(10),
              //   itemCount: selfOrderModelList.length,
              //   itemBuilder: (context, index) {
              //     final order = selfOrderModelList[index];
              //
              //     return buildOrderCard(
              //       image: order.thumbnail ?? '',
              //       name: order.serviceName ?? '',
              //       price: '${order.price}',
              //       orderId: order.orderId?.toUpperCase() ?? '',
              //       status: order.orderStatus ?? '',
              //       statusColor: getStatusColor('${order.orderStatus}'),
              //       onTap: () {
              //         Navigator.push(
              //           context,
              //           MaterialPageRoute(
              //             builder: (context) =>
              //                 CabBookingDetailsScreen(id: order.id.toString()),
              //           ),
              //         );
              //       },
              //     );
              //
              //   },
              // )
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
        return Colors.blue; // Default color for unknown statuses
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
                  color: isActive
                      ? Colors.blue
                      : Colors.grey.shade600,
                ),
              ),

              const SizedBox(height: 6),

              // Label
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isActive
                      ? Colors.blue
                      : Colors.grey.shade700,
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

  Widget _buildSelfDrivingForm(double? totalHours) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// Label
        Text('Pickup Location',
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
                const Icon(Icons.keyboard_arrow_down,
                    color: Colors.blue),
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

        const SizedBox(height: 12),
        Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.watch_later_outlined,
                size: 16,
                color: Colors.blue,
              ),
              const SizedBox(width: 8,),
              Text(
                '${totalHours?.toStringAsFixed(2)} - Hours',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(width: 8,),
              const Icon(
                Icons.arrow_downward,
                size: 16,
                color: Colors.blue,
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        GestureDetector(
          onTap: () => _selectDateTime(context: context, isPickup: false),
          child: _dateTimeTile(
            title: 'Return Date & Time',
            value: returnDateTime,
            icon: Icons.logout,
          ),
        ),

        const SizedBox(height: 15),
        SizedBox(
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
                                  color: Colors.white.withOpacity(0.8),
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
        const SizedBox(height: 20,),
        if(returnDateTime != null && pickupDateTime != null && selectedLocation != null)
           _buildSubmitButton(totalHours: totalHours),

        if(returnDateTime == null || pickupDateTime == null || selectedLocation == null)
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

  Widget _hourTab(String label,double kilo) {
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
                color: Colors.blue.withOpacity(0.35),
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
          LocationSearchWidget(
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
            },
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
          // LocationSearchWidget(
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
              _hourTab('4 HRS | 40KM',40.00),
              const SizedBox(width: 6),
              _hourTab('8 HRS | 80KM',80.00),
              const SizedBox(width: 6),
              _hourTab('12 HRS | 120KM',120.00),
            ],
          ),

          const SizedBox(height: 20),
          // Submit Button
          if(pickupDateTime != null && _fromLocation.text.isNotEmpty && _selectedHour.isNotEmpty)
            SizedBox(
            width: double.infinity,
            child: GestureDetector(
              onTap: (){
                setState(() {
                  isBtn = true;
                });
                getLeadGenerate('CAR',distanceKm);
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
                      Color(0xFFFF7A18), // warm orange
                      Color(0xFFFF5722), // deep orange
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
            ),
          ),

          if(pickupDateTime == null || _fromLocation.text.isEmpty || _selectedHour.isEmpty)
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
        onTap: (){
          setState(() {
            isBtn = true;
          });
          if(_tripType == 'self'){
            getLeadGenerate('${_selectedRideType?.enBrandName}',totalHours ?? 0);
            // Navigator.push(
            //   context,
            //   CupertinoPageRoute(
            //     builder: (context) => CarSelectionPage(
            //       type: _tripType,
            //       location: selectedLocation ?? '',
            //       pickDate: formatDate(pickupDateTime),
            //       pickTime: formatTime(pickupDateTime),
            //       dropDate: formatDate(returnDateTime),
            //       dropTime: formatTime(returnDateTime),
            //       totalHour: totalHours ?? 0,
            //       categoryType: '${_selectedRideType?.enBrandName}',
            //     ),
            //   ),
            // );
          }else{
            getLeadGenerate('CAR',distanceKm + returnDistanceKm);
            // Navigator.push(
            //   context,
            //   CupertinoPageRoute(
            //     builder: (context) => CarSelectionPage(
            //       type: _tripType,
            //       location: _toLocation.text,
            //       pickDate: formatDate(pickupDateTime),
            //       pickTime: formatTime(pickupDateTime),
            //       dropDate: formatDate(returnDateTime),
            //       dropTime: formatTime(returnDateTime),
            //       totalHour: distanceKm,
            //       categoryType: 'CAR',
            //     ),
            //   ),
            // );
          }

          // getLeadGenerate();
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                Color(0xFFFF7A18), // warm orange
                Color(0xFFFF5722), // deep orange
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
            child: isBtn ? const CircularProgressIndicator(color: Colors.white) : const Text(
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
          onTap: () => onChanged(value),
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

  // Time selection method
  Future<void> _selectDateTime({
    required BuildContext context,
    required bool isPickup,
  }) async {

    DateTime now = DateTime.now();

    DateTime firstDate;

    if (isPickup) {
      firstDate = now;
    } else {
      if (pickupDateTime != null) {
        firstDate = pickupDateTime!.add(const Duration(days: 1));
      } else {
        firstDate = now;
      }
    }

    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: firstDate,
      firstDate: firstDate,
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.blue,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
            dialogBackgroundColor: Colors.white,
          ),
          child: child!,
        );
      },
    );

    if (pickedDate == null) return;

    TimeOfDay? pickedTime;
    DateTime finalDateTime;

    /// 🔥 LOOP until valid time selected
    while (true) {

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

      /// 🔥 SAME DAY PAST TIME CHECK
      if (pickedDate.year == now.year &&
          pickedDate.month == now.month &&
          pickedDate.day == now.day) {

        if (finalDateTime.isBefore(now)) {
          /// ❌ Invalid → loop again (no message)
          continue;
        }
      }

      /// ✅ Valid → break loop
      break;
    }

    /// 🔥 SET STATE
    setState(() {
      if (isPickup) {
        pickupDateTime = finalDateTime;

        if (returnDateTime != null &&
            returnDateTime!.isBefore(
                pickupDateTime!.add(const Duration(days: 1)))) {
          returnDateTime = null;
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
