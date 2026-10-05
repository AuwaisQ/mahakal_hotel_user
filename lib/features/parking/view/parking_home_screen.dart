import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:mahakal/features/location/controllers/location_controller.dart';
import 'package:mahakal/features/parking/controller/parking_controller.dart';
import 'package:mahakal/features/parking/model/near_parking_model.dart';
import 'package:mahakal/features/parking/model/user_vehicle_model.dart';
import 'package:mahakal/features/profile/controllers/profile_contrroller.dart';
import 'package:mahakal/features/self_drive/controller/self_location_widget.dart';
import 'package:provider/provider.dart';
import 'package:mahakal/features/parking/view/widgets/add_vehicle_bottom_sheet.dart';
import 'parking_bookings_screen.dart';
import 'parking_details_screen.dart';
import 'parking_order_details_screen.dart';
import '../model/parking_order_model.dart';
import 'package:intl/intl.dart';

class ParkingHomeScreen extends StatefulWidget {
  const ParkingHomeScreen({super.key});

  @override
  State<ParkingHomeScreen> createState() => _ParkingHomeScreenState();
}

class _ParkingHomeScreenState extends State<ParkingHomeScreen> {
  final TextEditingController _locationSearchController = TextEditingController();
  final LocationSearchController _searchController = LocationSearchController();
  
  String _currentLat = "23.1793"; // Default Ujjain
  String _currentLong = "75.7784";
  int? _selectedUserVehicleId;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  void _initializeData() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final parkingController = Provider.of<ParkingController>(context, listen: false);
      parkingController.getVehicleTypeList();
      parkingController.getParkingOrderList();
      
      await parkingController.getUserVehicleList();
      
      if (parkingController.userVehicleList.isNotEmpty && _selectedUserVehicleId == null) {
        setState(() {
          _selectedUserVehicleId = parkingController.userVehicleList[0].id;
        });
      }
      
      _getCurrentLocation();
    });
  }

  Future<void> _getCurrentLocation() async {
    final locationController = Provider.of<LocationController>(context, listen: false);
    await locationController.getCurrentLocation(context, true);
    
    if (locationController.position.latitude != 0) {
      setState(() {
        _currentLat = locationController.position.latitude.toString();
        _currentLong = locationController.position.longitude.toString();
        _locationSearchController.text = locationController.address.name ?? "Current Location";
      });
      _fetchNearParking();
    } else {
      _fetchNearParking();
    }
  }

  void _fetchNearParking() {
    final parkingController = Provider.of<ParkingController>(context, listen: false);
    int? typeId;
    if (_selectedUserVehicleId != null) {
      try {
        final vehicle = parkingController.userVehicleList.firstWhere((v) => v.id == _selectedUserVehicleId);
        typeId = vehicle.vehicleId;
      } catch (e) {}
    }

    parkingController.getNearParkingList(
      lat: _currentLat,
      long: _currentLong,
      vehicleId: typeId,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FB), // Even softer modern background
      body: Consumer<ParkingController>(
        builder: (context, parkingController, child) {
          return RefreshIndicator(
            onRefresh: () async {
              await parkingController.getVehicleTypeList();
              await parkingController.getUserVehicleList();
              await parkingController.getParkingOrderList();
              _fetchNearParking();
            },
            color: Colors.blue,
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                _buildCompactAppBar(),
                SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildModernSearchSection(),
                      _buildActiveBookingAlert(parkingController),
                      _buildSectionHeader("Select Vehicle", Icons.directions_car_filled_rounded, 
                          onAction: () => _showAddVehicleBottomSheet(context)),
                      _buildModernVehicleSelector(parkingController),
                      _buildSectionHeader("Nearby Spots", Icons.explore_rounded),
                    ],
                  ),
                ),
                _buildParkingList(parkingController),
                const SliverToBoxAdapter(child: SizedBox(height: 100)),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _getCurrentLocation,
        mini: true,
        backgroundColor: Colors.black,
        elevation: 4,
        child: const Icon(Icons.my_location_rounded, color: Colors.white, size: 20),
      ),
    );
  }

  Widget _buildCompactAppBar() {
    return SliverAppBar(
      expandedHeight: 80.0,
      floating: false,
      pinned: true,
      elevation: 0,
      backgroundColor: Colors.blue,
      stretch: true,
      // leading: Padding(
      //   padding: const EdgeInsets.all(10.0),
      //   child: Container(
      //     decoration: BoxDecoration(
      //       color: Colors.black.withOpacity(0.08),
      //       borderRadius: BorderRadius.circular(10),
      //     ),
      //     child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 16),
      //   ),
      // ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 12, top: 8, bottom: 8),
          child: InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ParkingBookingsScreen()),
              );
            },
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.receipt_long_rounded, color: Colors.white, size: 20),
            ),
          ),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: false,
        titlePadding: const EdgeInsets.only(left: 55, bottom: 16),
        title: const Text(
          "Parking Finder",
          style: TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 18,
            color: Colors.white,
            letterSpacing: -0.5,
          ),
        ),
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFF2196F3),
                Color(0xFF1565C0),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                top: -30,
                right: -20,
                child: CircleAvatar(radius: 70, backgroundColor: Colors.white.withOpacity(0.05)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModernSearchSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(100),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: CustomLocationField(
          controller: _locationSearchController,
          searchController: _searchController,
          onSelected: (lat, lng, address) {
            setState(() {
              _currentLat = lat.toString();
              _currentLong = lng.toString();
              _locationSearchController.text = address;
            });
            _fetchNearParking();
          },
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, {VoidCallback? onAction}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.black54),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.black87, letterSpacing: -0.3),
          ),
          const Spacer(),
          if (onAction != null)
            InkWell(
              onTap: onAction,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.add_rounded, size: 14, color: Colors.blue),
                    SizedBox(width: 2),
                    Text("Add", style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 11)),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildActiveBookingAlert(ParkingController controller) {
    if (controller.parkingOrderList.isEmpty) return const SizedBox.shrink();
    
    final latestOrder = controller.parkingOrderList.first;
    bool isPending = latestOrder.status?.toLowerCase() == 'pending';

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isPending ? Colors.black : Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isPending ? Colors.blue : Colors.blue.withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(
              latestOrder.cabName?.toLowerCase().contains('bike') == true ? Icons.pedal_bike_rounded : Icons.directions_car_filled_rounded,
              color: isPending ? Colors.white : Colors.blue,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isPending ? "ACTIVE RESERVATION" : "LAST BOOKING",
                  style: TextStyle(
                    color: isPending ? Colors.white60 : Colors.grey.shade500,
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  latestOrder.parkingName ?? "Unknown Spot",
                  style: TextStyle(
                    color: isPending ? Colors.white : Colors.black87,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ParkingBookingsScreen()),
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: isPending ? Colors.white.withOpacity(0.15) : Colors.grey.shade50,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                "Manage",
                style: TextStyle(
                  color: isPending ? Colors.white : Colors.black87,
                  fontWeight: FontWeight.w800,
                  fontSize: 12,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernVehicleSelector(ParkingController controller) {
    if (controller.userVehicleList.isEmpty) return _buildEmptyVehiclePrompt();

    return SizedBox(
      height: 95,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        itemCount: controller.userVehicleList.length,
        itemBuilder: (context, index) {
          final vehicle = controller.userVehicleList[index];
          final isSelected = _selectedUserVehicleId == vehicle.id;
          final isBike = vehicle.cabName?.toLowerCase().contains('bike') ?? false;

          return GestureDetector(
            onTap: () {
              setState(() => _selectedUserVehicleId = isSelected ? null : vehicle.id);
              _fetchNearParking();
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              width: 120,
              margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: isSelected ? Colors.blue : Colors.grey.shade100,
                  width: isSelected ? 2 : 1,
                ),
                boxShadow: [
                  if (isSelected)
                    BoxShadow(
                      color: Colors.blue.withOpacity(0.2),
                      blurRadius: 10,
                      spreadRadius: 2,
                    )
                  else
                    BoxShadow(
                      color: Colors.black.withOpacity(0.02),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    isBike ? Icons.pedal_bike_rounded : Icons.directions_car_rounded,
                    color: isSelected ? Colors.blue : Colors.grey.shade400,
                    size: 24,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    vehicle.cabRegisterNumber?.toUpperCase() ?? "N/A",
                    style: TextStyle(
                      color: isSelected ? Colors.blue : Colors.black54,
                      fontWeight: FontWeight.w900,
                      fontSize: 11,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyVehiclePrompt() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Row(
        children: [
          const Icon(Icons.car_rental_rounded, size: 30, color: Colors.grey),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("No Vehicles Added", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                Text("Add vehicle for spot suggestions.", style: TextStyle(color: Colors.grey.shade600, fontSize: 11)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildParkingList(ParkingController controller) {
    if (controller.isLoading && controller.nearParkingList.isEmpty) {
      return const SliverFillRemaining(
        child: Center(child: CircularProgressIndicator(color: Colors.blue)),
      );
    }
    
    if (controller.nearParkingList.isEmpty) {
      return SliverFillRemaining(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.location_off_rounded, size: 60, color: Colors.grey.shade300),
              const SizedBox(height: 12),
              const Text("No spots found nearby", style: TextStyle(color: Colors.grey, fontSize: 14, fontWeight: FontWeight.bold)),
              TextButton(onPressed: _fetchNearParking, child: const Text("Try again")),
            ],
          ),
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final parking = controller.nearParkingList[index];
            return _buildCompactParkingCard(parking);
          },
          childCount: controller.nearParkingList.length,
        ),
      ),
    );
  }

  Widget _buildCompactParkingCard(NearParking parking) {
    final int price = int.tryParse(parking.price?.toString() ?? "0") ?? 0;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
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
                builder: (context) => ParkingDetailsScreen(
                  addressId: parking.id ?? 0,
                  userVehicleId: _selectedUserVehicleId,
                  name: parking.parkingName ?? "N/A",
                  address: parking.parkingAddress ?? "N/A",
                  distance: parking.distance ?? "0 km",
                  slots: 10,
                  price: price,
                  lat: parking.parkingLat,
                  long: parking.parkingLong,
                  images: parking.images,
                ),
              ),
            );
          },
          borderRadius: BorderRadius.circular(18),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                // Larger Image on the left
                Container(
                  height: 100,
                  width: 100,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Image.network(
                      (parking.images != null && parking.images!.isNotEmpty)
                          ? parking.images!.first
                          : "https://img.freepik.com/free-vector/parking-lot-flat-style_23-2147743389.jpg",
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Image.network(
                        "https://img.freepik.com/free-vector/parking-lot-flat-style_23-2147743389.jpg",
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Info in the middle
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        parking.parkingName ?? "N/A",
                        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: Colors.black, letterSpacing: -0.2),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Icon(Icons.location_on_rounded, size: 12, color: Colors.grey.shade400),
                          const SizedBox(width: 3),
                          Expanded(
                            child: Text(
                              parking.parkingAddress ?? "N/A",
                              style: TextStyle(color: Colors.grey.shade500, fontSize: 11, fontWeight: FontWeight.w500),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Text(
                            parking.distance ?? "0 km",
                            style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.w900, fontSize: 10),
                          ),
                          const SizedBox(width: 8),
                          _buildMiniFeature(Icons.security_rounded, "Secure"),
                        ],
                      ),
                    ],
                  ),
                ),
                // Price on the right
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "₹$price",
                      style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.w900, fontSize: 18),
                    ),
                    const Text("per hr", style: TextStyle(color: Colors.grey, fontSize: 9, fontWeight: FontWeight.bold)),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMiniFeature(IconData icon, String label) {
    return Row(
      children: [
        Icon(icon, size: 10, color: Colors.grey.shade400),
        const SizedBox(width: 3),
        Text(label, style: TextStyle(color: Colors.grey.shade500, fontSize: 9, fontWeight: FontWeight.w600)),
      ],
    );
  }

  void _showAddVehicleBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const AddVehicleBottomSheet(),
    );
  }
}
