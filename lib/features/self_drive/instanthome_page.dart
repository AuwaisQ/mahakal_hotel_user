import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/datasource/remote/http/httpClient.dart';
import '../tour_and_travells/Controller/tour_location_controller.dart';
import 'instant_detail_screen.dart';
import 'instant_parcel_screen.dart';

class InstantHomePage extends StatefulWidget {
  const InstantHomePage({super.key});

  @override
  State<InstantHomePage> createState() => _InstantHomePageState();
}

class _InstantHomePageState extends State<InstantHomePage> {

  final TextEditingController _fromLocation = TextEditingController();
  final TextEditingController _toLocation = TextEditingController();

  GoogleMapController? _mapController;

  String? fromLatitude;
  String? fromLongitude;
  String? toLatitude;
  String? toLongitude;
  double distanceKm = 0.0;

  String selectedTripType = 'One';
  List<RecentLocation> recentList = [];

  void getDistance(Map<String, dynamic> data) async {
    try {
      var res = await HttpService().postApi('/api/v1/self-vehicle/get-distance',data);
      print('Api response for distance $res');
        if (res['status'] == 1 && res['data'] != null) {
          setState(() {
            var distanceValue = res['data']['distance_km'];

            distanceKm = (distanceValue is String)
                ? double.parse(distanceValue)
                : (distanceValue as num).toDouble();
          });
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => InstantDetailPage(
              pickupAddress:_fromLocation.text,
              pickupLat: fromLatitude!,
              pickupLong: fromLongitude!,
              dropAddress: _toLocation.text,
              dropLat: toLatitude!,
              dropLong: toLongitude!,
              bookingPickKm: distanceKm,
              bookingType: 'cab',)),
          );
      }

    } catch (e) {
      print('Error fetching categories: $e');
    }
  }

  Future<void> getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return;

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.deniedForever) return;

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      double lat = position.latitude;
      double lng = position.longitude;

      String address = 'Fetching address...';

      try {
        /// 🔥 INNER TRY (important)
        List<Placemark> placemarks =
        await placemarkFromCoordinates(lat, lng);

        if (placemarks.isNotEmpty) {
          final place = placemarks.first;
          address = [
            place.name,                 // shop/building name (near wala feel deta)
            place.subLocality,          // area
            place.thoroughfare,         // road
            place.locality,             // city
            place.administrativeArea
          ].where((e) => e != null && e.isNotEmpty).join(', ');
        }
      } catch (e) {
        print('❌ Geocoding failed: $e');

        /// fallback
        address = 'Lat: $lat, Lng: $lng';
      }

      setState(() {
        _fromLocation.text = address;
        fromLatitude = lat.toString();
        fromLongitude = lng.toString();
      });

    } catch (e) {
      print('❌ Location error: $e');
    }
  }



  void loadRecent() async {
    recentList = await getRecentLocations();
    setState(() {});
    getCurrentLocation();
    print("function has started");
  }
  Future<void> saveRecentLocation(RecentLocation newLocation) async {
    final prefs = await SharedPreferences.getInstance();

    List<String> list = prefs.getStringList('recent_locations') ?? [];

    /// decode
    List<RecentLocation> locations = list
        .map((e) => RecentLocation.fromJson(jsonDecode(e)))
        .toList();

    /// 🔥 duplicate remove (same lat/lng)
    locations.removeWhere((loc) =>
    loc.lat == newLocation.lat && loc.lng == newLocation.lng);

    /// 🔥 new add at top
    locations.insert(0, newLocation);

    /// 🔥 keep only 4
    if (locations.length > 4) {
      locations = locations.sublist(0, 4);
    }

    /// encode
    List<String> updatedList =
    locations.map((e) => jsonEncode(e.toJson())).toList();

    await prefs.setStringList('recent_locations', updatedList);
  }
  Future<List<RecentLocation>> getRecentLocations() async {
    final prefs = await SharedPreferences.getInstance();

    List<String> list = prefs.getStringList('recent_locations') ?? [];

    return list
        .map((e) => RecentLocation.fromJson(jsonDecode(e)))
        .toList();
  }

  void showSearchSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      enableDrag: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return StatefulBuilder(
          builder: (context, modalSetState) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
              ),
              child: Column(
                children: [

                  const SizedBox(height: 15),

                  /// HEADER
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back),
                      ),
                      const Text(
                        'Drop',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const Spacer(),

                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Row(
                          children: const [
                            Text('For me'),
                            Icon(Icons.keyboard_arrow_down)
                          ],
                        ),
                      )
                    ],
                  ),

                  const SizedBox(height: 15),

                  /// 📍 TOP LOCATION BOX (LIKE IMAGE)
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        Column(
                          children: [
                            Icon(Icons.my_location,color: Colors.green,),
                            Text('|'),
                            Text('|'),
                            Text('|'),
                            Icon(Icons.location_on_outlined,color: Colors.red,),
                          ],
                        ),
                        SizedBox(width: 10,),
                        Expanded(
                          child: Column(
                            children: [

                              /// PICKUP
                              LocationSearchWidget(
                                hintText: 'Your Current location',
                                mapController: _mapController,
                                controller: _fromLocation,
                                onLocationSelected: (lat, lng, address) {
                                  setState(() {
                                    fromLatitude = lat.toString();
                                    fromLongitude = lng.toString();
                                  });
                                },
                              ),

                              Divider(color: Colors.grey.shade200,),

                              /// DROP SEARCH
                              LocationSearchWidget(
                                hintText: 'Drop location',
                                mapController: _mapController,
                                controller: _toLocation,
                                onLocationSelected: (lat, lng, address) {
                                  setState(() {
                                    toLatitude = lat.toString();
                                    toLongitude = lng.toString();
                                  });
                                  saveRecentLocation(
                                    RecentLocation(
                                      lat: lat,
                                      lng: lng,
                                      address: address,
                                    ),
                                  );
                                  Map<String, dynamic> data = {
                                    'pick_lat':fromLatitude,
                                    'pick_long':fromLongitude,
                                    'drop_lat':toLatitude,
                                    'drop_long':toLongitude
                                  };
                                  getDistance(data);
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 15),

                  /// ACTION BUTTONS
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.map),
                          label: const Text('Select on map'),
                          style: OutlinedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.add),
                          label: const Text('Add stops'),
                          style: OutlinedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 15),

                  /// 🔥 RECENT LIST (SCROLLABLE)
                  Expanded(
                    child: recentList.isEmpty
                        ? Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [

                          /// 📍 ICON
                          Container(
                            height: 60,
                            width: 60,
                            decoration: BoxDecoration(
                              color: Colors.orange.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.location_off,
                              color: Colors.orange,
                              size: 30,
                            ),
                          ),

                          const SizedBox(height: 14),

                          /// TITLE
                          const Text(
                            "No Recent Locations",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),

                          const SizedBox(height: 6),

                          /// SUBTITLE
                          Text(
                            "Your searched or selected locations will appear here.",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade600,
                            ),
                          ),

                          const SizedBox(height: 16),

                          // /// BUTTON (optional)
                          // ElevatedButton(
                          //   onPressed: () {
                          //     // 👉 open search or get current location
                          //     getCurrentLocation();
                          //   },
                          //   style: ElevatedButton.styleFrom(
                          //     backgroundColor: Colors.black,
                          //     shape: RoundedRectangleBorder(
                          //       borderRadius: BorderRadius.circular(30),
                          //     ),
                          //   ),
                          //   child: const Text("Use Current Location"),
                          // )
                        ],
                      ),
                    )
                        : ListView.builder(
                      shrinkWrap: true,
                      padding: EdgeInsets.zero,
                      itemCount: recentList.length,
                      itemBuilder: (context, index) {
                        final item = recentList[index];

                        return GestureDetector(
                          onTap: () {
                            _toLocation.text = item.address;
                            toLatitude = item.lat.toString();
                            toLongitude = item.lng.toString();
                            Map<String, dynamic> data = {
                              'pick_lat':fromLatitude,
                              'pick_long':fromLongitude,
                              'drop_lat':toLatitude,
                              'drop_long':toLongitude
                            };
                            getDistance(data);
                            // Navigator.push(
                            //   context,
                            //   MaterialPageRoute(builder: (_) => InstantDetailPage(
                            //     pickupAddress:_fromLocation.text,
                            //     pickupLat: fromLatitude!,
                            //     pickupLong: fromLongitude!,
                            //     dropAddress: _toLocation.text,
                            //     dropLat: toLatitude!,
                            //     dropLong: toLongitude!,
                            //     bookingPickKm: distanceKm,bookingType: 'cab')),
                            // );
                          },
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Row(
                              children: [

                                /// 📍 ICON
                                Container(
                                  width: 42,
                                  height: 42,
                                  decoration: BoxDecoration(
                                    color: Colors.orange.withOpacity(0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.history,
                                    color: Colors.orange,
                                    size: 20,
                                  ),
                                ),

                                const SizedBox(width: 12),

                                /// 📄 TEXT
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.address,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),

                                      const SizedBox(height: 4),

                                      Text(
                                        "Recent location",
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                /// ➡️ ARROW
                                const Icon(
                                  Icons.arrow_forward_ios,
                                  size: 14,
                                  color: Colors.grey,
                                ),
                              ],
                            ),
                          ),
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

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadRecent();
  }
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          const SizedBox(height: 30),

          /// 🔍 SEARCH BAR
          GestureDetector(
            onTap: () {
             showSearchSheet();
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(30),
              ),
              child: const Row(
                children: [
                  Icon(Icons.search, color: Colors.black54),
                  SizedBox(width: 10),
                  Text('Where are you going?'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          recentList.isEmpty
              ? Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [

          /// 📍 ICON
          Container(
            height: 60,
            width: 60,
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.location_off,
              color: Colors.orange,
              size: 30,
            ),
          ),

          const SizedBox(height: 14),

          /// TITLE
          const Text(
            "No Recent Locations",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 6),

          /// SUBTITLE
          Text(
            "Your searched or selected locations will appear here.",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade600,
            ),
          ),

          const SizedBox(height: 16),

          // /// BUTTON (optional)
          // ElevatedButton(
          //   onPressed: () {
          //     // 👉 open search or get current location
          //     getCurrentLocation();
          //   },
          //   style: ElevatedButton.styleFrom(
          //     backgroundColor: Colors.black,
          //     shape: RoundedRectangleBorder(
          //       borderRadius: BorderRadius.circular(30),
          //     ),
          //   ),
          //   child: const Text("Use Current Location"),
          // )
        ],
      ),
    )
              : ListView.builder(
            shrinkWrap: true,
            padding: EdgeInsets.zero,
            itemCount: recentList.length,
            itemBuilder: (context, index) {
              final item = recentList[index];

              return GestureDetector(
                onTap: () {
                  _toLocation.text = item.address;
                  toLatitude = item.lat.toString();
                  toLongitude = item.lng.toString();
                  Map<String, dynamic> data = {
                    'pick_lat':fromLatitude,
                    'pick_long':fromLongitude,
                    'drop_lat':toLatitude,
                    'drop_long':toLongitude
                  };
                  getDistance(data);
                  // Navigator.push(
                  //   context,
                  //   MaterialPageRoute(builder: (_) => InstantDetailPage(
                  //     pickupAddress:_fromLocation.text,
                  //     pickupLat: fromLatitude!,
                  //     pickupLong: fromLongitude!,
                  //     dropAddress: _toLocation.text,
                  //     dropLat: toLatitude!,
                  //     dropLong: toLongitude!,
                  //     bookingPickKm: distanceKm,bookingType: 'cab')),
                  // );
                },
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Row(
                    children: [

                      /// 📍 ICON
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.history,
                          color: Colors.orange,
                          size: 20,
                        ),
                      ),

                      const SizedBox(width: 12),

                      /// 📄 TEXT
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.address,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),

                            const SizedBox(height: 4),

                            Text(
                              "Recent location",
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),

                      /// ➡️ ARROW
                      const Icon(
                        Icons.arrow_forward_ios,
                        size: 14,
                        color: Colors.grey,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: 15),

          Text('Services', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),

          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _serviceItem(Icons.inventory_2_outlined, 'Parcel'),
              _serviceItem(Icons.electric_rickshaw, 'Auto'),
              _serviceItem(Icons.local_taxi_outlined, 'Cab'),
              _serviceItem(Icons.two_wheeler, 'Bike'),
            ],
          ),
        ],
      ),
    );
  }

  /// 🚀 SERVICE ITEM
  Widget _serviceItem(IconData icon, String title) {
    return InkWell(
      onTap: () {
        // getCurrentLocation();
        if(title == 'Parcel') {
          Navigator.push(context,
              MaterialPageRoute(builder: (_)=> ParcelLocationPage(
                recentList: recentList,
                currentLocation: _fromLocation.text.isEmpty ? '' : _fromLocation.text,
                fromLatitude: fromLatitude!,
                fromLongitude: fromLongitude!,
              )));
        }else{
        showSearchSheet();
        }

      },
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.deepOrange, Colors.amber],
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white),
          ),
          const SizedBox(height: 8),
          Text(title),
        ],
      ),
    );
  }
}

class RecentLocation {
  final double lat;
  final double lng;
  final String address;

  RecentLocation({
    required this.lat,
    required this.lng,
    required this.address,
  });

  Map<String, dynamic> toJson() => {
    'lat': lat,
    'lng': lng,
    'address': address,
  };

  factory RecentLocation.fromJson(Map<String, dynamic> json) {
    return RecentLocation(
      lat: json['lat'],
      lng: json['lng'],
      address: json['address'],
    );
  }
}