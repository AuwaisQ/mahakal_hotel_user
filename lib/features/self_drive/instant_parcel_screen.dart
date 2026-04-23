import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mahakal/features/tour_and_travells/Controller/tour_location_controller.dart';
import 'package:provider/provider.dart';

import '../../data/datasource/remote/http/httpClient.dart';
import '../../main.dart';
import '../profile/controllers/profile_contrroller.dart';
import 'instant_detail_screen.dart';
import 'instanthome_page.dart';

class ParcelLocationPage extends StatefulWidget {
  final List<RecentLocation> recentList;
  final String currentLocation;
  final String fromLatitude;
  final String fromLongitude;
  const ParcelLocationPage({super.key, required this.recentList, required this.currentLocation, required this.fromLatitude, required this.fromLongitude});

  @override
  State<ParcelLocationPage> createState() => _ParcelLocationPageState();
}

class _ParcelLocationPageState extends State<ParcelLocationPage> with SingleTickerProviderStateMixin{

  final TextEditingController _fromLocation = TextEditingController();
  final TextEditingController _toLocation = TextEditingController();
  final TextEditingController dropNameController = TextEditingController();
  final TextEditingController dropPhoneController = TextEditingController();
  final TextEditingController houseNoController = TextEditingController();

  final LocationSearchController searchController = LocationSearchController();
  String userName = '';
  String userPhone = '';
  late AnimationController _controller;

  GoogleMapController? _mapController;

  String? toLatitude;
  String? toLongitude;
  double distanceKm = 0.0;


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
      }
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => InstantDetailPage(
            pickupAddress:_fromLocation.text,
            pickupLat: widget.fromLatitude,
            pickupLong: widget.fromLongitude,
            dropAddress: _toLocation.text,
            dropLat: toLatitude!,
            dropLong: toLongitude!,
            bookingPickKm: distanceKm,
            bookingType: 'parcel')),
      );
    } catch (e) {
      print('Error fetching categories: $e');
    }
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
                        'Drop to',
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
                  LocationSearchWidget(
                    hintText: 'Drop location',
                    mapController: _mapController,
                    controller: _toLocation,
                    onLocationSelected: (lat, lng, address) {
                      _toLocation.text = address;
                      toLatitude = lat.toString();
                      toLongitude = lng.toString();
                      Navigator.pop(context);
                      if(dropNameController.text.isEmpty || dropPhoneController.text.isEmpty){
                        showInformation();
                      }else{
                        Map<String, dynamic> data = {
                          'pick_lat':widget.fromLatitude,
                          'pick_long':widget.fromLongitude,
                          'drop_lat':toLatitude,
                          'drop_long':toLongitude
                        };
                        getDistance(data);
                      }
                      setState(() {});
                    },
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
                    child: widget.recentList.isEmpty
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
                              color: Colors.blue.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.location_off,
                              color: Colors.blue,
                              size: 30,
                            ),
                          ),

                          const SizedBox(height: 14),

                          /// TITLE
                          const Text(
                            'No Recent Locations',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),

                          const SizedBox(height: 6),

                          /// SUBTITLE
                          Text(
                            'Your searched or selected locations will appear here.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade600,
                            ),
                          ),

                          const SizedBox(height: 16),

                          /// BUTTON (optional)
                          ElevatedButton(
                            onPressed: () {
                              // 👉 open search or get current location
                              // getCurrentLocation();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            child: const Text('Use Current Location'),
                          )
                        ],
                      ),
                    )
                        : ListView.builder(
                      shrinkWrap: true,
                      padding: EdgeInsets.zero,
                      itemCount: widget.recentList.length,
                      itemBuilder: (context, index) {
                        final item = widget.recentList[index];

                        return GestureDetector(
                          onTap: () {
                            _toLocation.text = item.address;
                            toLatitude = item.lat.toString();
                            toLongitude = item.lng.toString();
                            Navigator.pop(context);
                            if(dropNameController.text.isEmpty || dropPhoneController.text.isEmpty){
                              showInformation();
                            }else{
                              Map<String, dynamic> data = {
                                'pick_lat':widget.fromLatitude,
                                'pick_long':widget.fromLongitude,
                                'drop_lat':toLatitude,
                                'drop_long':toLongitude
                              };
                              getDistance(data);
                            }
                            // Map<String, dynamic> data = {
                            //   'pick_lat':fromLatitude,
                            //   'pick_long':fromLongitude,
                            //   'drop_lat':toLatitude,
                            //   'drop_long':toLongitude
                            // };
                            // getDistance(data);
                            // Navigator.push(
                            //   context,
                            //   MaterialPageRoute(builder: (_) => InstantDetailPage(
                            //     pickupAddress:_fromLocation.text,
                            //     pickupLat: fromLatitude!,
                            //     pickupLong: fromLongitude!,
                            //     dropAddress: _toLocation.text,
                            //     dropLat: toLatitude!,
                            //     dropLong: toLongitude!,
                            //     bookingPickKm: distanceKm,)),
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
                                    color: Colors.blue.withOpacity(0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.history,
                                    color: Colors.blue,
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
                                        'Recent location',
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

  void showInformation(){
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 12,
            bottom: MediaQuery.of(context).viewInsets.bottom + 12,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              /// 🔹 Drag Handle
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),

              /// 🔹 Address Field
              _buildEnhancedTextField(
                hint: 'House no./ Building (optional)',
                icon: Icons.home_outlined, controller: houseNoController,
              ),

              const SizedBox(height: 20),

              /// 🔹 Section Title
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Add contact details',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              /// 🔹 Name Field
              _buildEnhancedTextField(
                hint: 'Full Name*',
                icon: Icons.person_outline, controller: dropNameController,
              ),

              const SizedBox(height: 12),

              /// 🔹 Checkbox - Enhanced
              Row(
                children: [
                  SizedBox(
                    width: 24,
                    height: 24,
                    child: Checkbox(
                      value: false,
                      onChanged: (val) {},
                      activeColor: const Color(0xFF2563EB),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Use my contact for this booking',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF4B5563),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              /// 🔹 Phone Field
              _buildEnhancedTextField(
                hint: 'Phone Number*',
                icon: Icons.phone_outlined,
                keyboardType: TextInputType.phone, controller: dropPhoneController,
              ),

              const SizedBox(height: 20),

              /// 🔹 Favorites Row - Enhanced
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildEnhancedFavItem(Icons.home_filled, 'Home', const Color(0xFF2563EB)),
                  _buildEnhancedFavItem(Icons.work, 'Work', const Color(0xFF7C3AED)),
                  _buildEnhancedFavItem(Icons.fitness_center, 'Gym', const Color(0xFFDC2626)),
                ],
              ),

              const SizedBox(height: 28),

              /// 🔹 Confirm Button - Enhanced
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    Map<String, dynamic> data = {
                      'pick_lat':widget.fromLatitude,
                      'pick_long':widget.fromLongitude,
                      'drop_lat':toLatitude,
                      'drop_long':toLongitude
                    };
                    getDistance(data);
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1F2937),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    textStyle: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  child: const Text('Confirm drop details'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _controller =
    AnimationController(vsync: this, duration: Duration(seconds: 3))
      ..repeat();
    setState(() {
    _fromLocation.text = widget.currentLocation;
    });
    userName = Provider.of<ProfileController>(Get.context!, listen: false).userNAME;
    userPhone = Provider.of<ProfileController>(Get.context!, listen: false).userPHONE;
    _toLocation.addListener(() {
      setState(() {});
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child:Column(
          children: [

            /// Image
            ClipRRect(
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
              child: Image.network(
                'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQccn1dn7KLlmNDxNFcLvMxoNaO9OPsny3u6A&s',
                height: 220,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),

            /// 🔥 Overlap Card (no Stack)
            Transform.translate(
              offset: const Offset(0, -50), // 👈 overlap control
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Material(
                  elevation: 10,
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [

                        /// 🔹 Pickup Field
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            children: [
                              SizedBox(height: 10,),
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(3),
                                    decoration: BoxDecoration(
                                      color: Colors.green.withOpacity(0.1),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.my_location,
                                        color: Colors.green, size: 15),
                                  ),
                                  const SizedBox(width: 10),
                                  Text('Pickup from current location'),
                                ],
                              ),
                              SizedBox(height: 10,),
                              CustomLocationField(
                                controller: _fromLocation,
                                searchController: searchController,
                                onSelected: (lat, lng, address) {
                                  print('Lat: $lat');
                                  print('Lng: $lng');
                                  print('Address: $address');

                                  // 🔥 yaha tu API call ya map move kar sakta hai
                                },
                              ),
                              Row(
                                children: [
                                  Text('Info :'),
                                  Text(' $userName , $userPhone',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 12),),
                                ],
                              ),
                              SizedBox(height: 10,),
                            ],
                          ),
                        ),
                        SizedBox(height: 10,),

                        /// 🔄 Divider + Switch Button (center aligned)
                        Row(
                          children: [
                            Expanded(child: Divider(color: Colors.grey.shade300)),
                            GestureDetector(
                              onTap: () {
                                final temp = _fromLocation.text;
                                _fromLocation.text = _toLocation.text;
                                _toLocation.text = temp;

                                final name = userName;
                                final phone = userPhone;
                                userName = dropNameController.text;
                                userPhone = dropPhoneController.text;
                                dropNameController.text = name;
                                dropPhoneController.text = phone;
                              },
                              child: Container(
                                margin: const EdgeInsets.symmetric(horizontal: 10),
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [Colors.blue, Colors.blue],
                                  ),
                                  border: Border.all(color: Colors.black),
                                  borderRadius: BorderRadius.circular(100)
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.swap_vert,
                                        color: Colors.white, size: 20),
                                    Text('Switch',style: TextStyle(color: Colors.white),)
                                  ],
                                ),
                              ),
                            ),
                            Expanded(child: Divider(color: Colors.grey.shade300)),
                          ],
                        ),

                        const SizedBox(height: 14),

                        /// 🔹 Drop Field
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            children: [
                              SizedBox(height: 10,),
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(5),
                                    decoration: BoxDecoration(
                                      color: Colors.red.withOpacity(0.1),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.location_on,
                                        color: Colors.red, size: 15),
                                  ),
                                  const SizedBox(width: 10),
                                  Text('Drop to'),
                                  Spacer(),
                                  _toLocation.text.isEmpty
                                      ? const SizedBox()
                                      : InkWell(
                                    onTap: () {
                                      showInformation();
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: Colors.green.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(100),
                                      ),
                                      child: Row(
                                        children: [
                                          const Icon(
                                            Icons.edit, // 👉 edit ki jagah close better UX
                                            color: Colors.green,
                                            size: 16,
                                          ),
                                          Text(' Edit',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 13,color: Colors.green),)
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              InkWell(
                                onTap: (){
                                  showSearchSheet();
                                },
                                child: AnimatedBuilder(
                                  animation: _controller,
                                  builder: (_, __) {
                                    return Container(
                                      margin: const EdgeInsets.symmetric(vertical: 15),
                                      padding: const EdgeInsets.all(2),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(100),
                                        gradient: LinearGradient(
                                          colors: const [Colors.blue, Colors.pink, Colors.blue],
                                          stops: [
                                            _controller.value,
                                            _controller.value + 0.2,
                                            _controller.value + 0.4
                                          ],
                                        ),
                                      ),
                                      child: Container(
                                        padding:
                                        const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                                        decoration: BoxDecoration(
                                          color: Colors.grey.shade100,
                                          borderRadius: BorderRadius.circular(100),
                                        ),
                                        child: Row(
                                          children: [
                                            Icon(Icons.search),
                                            SizedBox(width: 10),
                                            Expanded(child: Text(_toLocation.text.isEmpty? 'Search drop address' : _toLocation.text,overflow: TextOverflow.ellipsis,maxLines: 2,)),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              dropNameController.text.isEmpty ? SizedBox() :
                              Row(
                                children: [
                                  Text('Info :'),
                                  Text(' ${dropNameController.text} , ${dropPhoneController.text}',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 12),),
                                ],
                              ),
                              SizedBox(height: 10,),
                            ],
                          ),
                        ),

                      ],
                    ),
                  ),
                ),
              ),
            ),

            Transform.translate(
              offset: const Offset(0, 100), // 👈 overlap control
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: TextStyle(
                      color: Colors.grey.shade700,
                      fontSize: 13,
                    ),
                    children: [

                      /// Line 1
                      const TextSpan(text: 'Read about '),

                      TextSpan(
                        text: 'prohibited items',
                        style: const TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                      const TextSpan(text: '\n\n'),

                      /// Line 2
                      const TextSpan(text: 'By continuing you agree to our '),

                      TextSpan(
                        text: 'T&C',
                        style: const TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),

      ),
    );
  }

  // Enhanced TextField Builder
  Widget _buildEnhancedTextField({
    required String hint,
    required IconData icon,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey.shade200,
          width: 1.5,
        ),
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(
            color: Colors.grey.shade400,
            fontSize: 14,
          ),
          prefixIcon: Icon(
            icon,
            color: Colors.grey.shade500,
            size: 20,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
      ),
    );
  }

// Enhanced Favorite Item Builder
  Widget _buildEnhancedFavItem(IconData icon, String label, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: color,
            size: 24,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Colors.grey.shade700,
          ),
        ),
      ],
    );
  }

}
