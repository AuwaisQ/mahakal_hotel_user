import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mahakal/features/parking/controller/parking_controller.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../model/user_vehicle_model.dart';
import 'booking_summary_screen.dart';
import 'package:mahakal/utill/images.dart';
import 'package:flutter_html/flutter_html.dart';

class ParkingDetailsScreen extends StatefulWidget {
  final int addressId;
  final int? userVehicleId;
  final String name;
  final String address;
  final String distance;
  final int slots;
  final int price;
  final String? lat;
  final String? long;
  final List<String>? images;

  const ParkingDetailsScreen({
    super.key,
    required this.addressId,
    this.userVehicleId,
    required this.name,
    required this.address,
    required this.distance,
    required this.slots,
    required this.price,
    this.lat,
    this.long,
    this.images,
  });

  @override
  State<ParkingDetailsScreen> createState() => _ParkingDetailsScreenState();
}

class _ParkingDetailsScreenState extends State<ParkingDetailsScreen> {
  int _currentImageIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      int typeId = 0;
      if (widget.userVehicleId != null) {
        try {
          final controller = Provider.of<ParkingController>(context, listen: false);
          typeId = controller.userVehicleList.firstWhere((v) => v.id == widget.userVehicleId).vehicleId ?? 0;
        } catch (e) {}
      }

      Provider.of<ParkingController>(context, listen: false).getParkingDetails(
        addressId: widget.addressId,
        vehicleId: typeId,
      );
    });
  }

  Future<void> _openGoogleMaps(String? lat, String? long) async {
    final String? finalLat = (lat != null && lat.isNotEmpty) ? lat : widget.lat;
    final String? finalLong = (long != null && long.isNotEmpty) ? long : widget.long;

    if (finalLat == null || finalLong == null || finalLat.isEmpty || finalLong.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Location coordinates not available')),
      );
      return;
    }

    final Uri geoUri = Uri.parse('geo:$finalLat,$finalLong?q=$finalLat,$finalLong');
    final Uri googleUrl = Uri.parse('https://www.google.com/maps/search/?api=1&query=$finalLat,$finalLong');

    try {
      if (await canLaunchUrl(geoUri)) {
        await launchUrl(geoUri);
      } else {
        await launchUrl(googleUrl, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      debugPrint("Error launching maps: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ParkingController>(
      builder: (context, controller, child) {
        final details = controller.parkingDetails;
        
        return Scaffold(
          backgroundColor: Colors.white,
          body: controller.isLoading && details == null
              ? const Center(child: CircularProgressIndicator(color: Colors.blue))
              : CustomScrollView(
                  slivers: [
                    SliverAppBar(
                      expandedHeight: 280,
                      pinned: true,
                      elevation: 0,
                      backgroundColor: Colors.blue,
                      leading: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: InkWell(
                          onTap: () => Navigator.pop(context),
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 18),
                          ),
                        ),
                      ),
                      actions: [
                        Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: IconButton(
                            icon: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.2),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.directions_outlined, color: Colors.white, size: 20),
                            ),
                            onPressed: () => _openGoogleMaps(details?.parkingLat, details?.parkingLong),
                          ),
                        ),
                      ],
                      flexibleSpace: FlexibleSpaceBar(
                        background: Stack(
                          fit: StackFit.expand,
                          children: [
                            widget.images != null && widget.images!.isNotEmpty
                                ? PageView.builder(
                                    itemCount: widget.images!.length,
                                    onPageChanged: (index) {
                                      setState(() {
                                        _currentImageIndex = index;
                                      });
                                    },
                                    itemBuilder: (context, index) {
                                      return Image.network(
                                        widget.images![index],
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) => Container(
                                          decoration: const BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: [Color(0xFFE65100), Color(0xFFFF8A65)],
                                              begin: Alignment.topLeft,
                                              end: Alignment.bottomRight,
                                            ),
                                          ),
                                          child: Center(
                                            child: Icon(
                                              Icons.local_parking_rounded,
                                              size: 140,
                                              color: Colors.white.withOpacity(0.15),
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  )
                                : Container(
                                    decoration: const BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [Color(0xFFE65100), Color(0xFFFF8A65)],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                    ),
                                    child: Center(
                                      child: Icon(
                                        Icons.local_parking_rounded,
                                        size: 140,
                                        color: Colors.white.withOpacity(0.15),
                                      ),
                                    ),
                                  ),
                            Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.black.withOpacity(0.3),
                                    Colors.transparent,
                                    Colors.black.withOpacity(0.7),
                                  ],
                                ),
                              ),
                            ),
                            if (widget.images != null && widget.images!.length > 1)
                              Positioned(
                                bottom: 85,
                                right: 20,
                                child: Row(
                                  children: List.generate(
                                    widget.images!.length,
                                    (index) => Container(
                                      margin: const EdgeInsets.symmetric(horizontal: 3),
                                      width: _currentImageIndex == index ? 16 : 6,
                                      height: 6,
                                      decoration: BoxDecoration(
                                        color: _currentImageIndex == index ? Colors.white : Colors.white.withOpacity(0.5),
                                        borderRadius: BorderRadius.circular(3),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            Positioned(
                              bottom: 25,
                              left: 20,
                              right: 20,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.2),
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                        child: const Row(
                                          children: [
                                            Icon(Icons.star_rounded, color: Colors.amber, size: 16),
                                            SizedBox(width: 4),
                                            Text("4.8", style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: Colors.green.withOpacity(0.8),
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                        child: const Text("Verified", style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    details?.parkingNameEn ?? widget.name,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 26,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: Colors.blue.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(Icons.location_on_rounded, color: Colors.blue, size: 24),
                                ),
                                const SizedBox(width: 15),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Address",
                                        style: TextStyle(color: Colors.grey.shade500, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        details?.parkingAddress ?? widget.address,
                                        style: const TextStyle(color: Colors.black87, fontSize: 15, fontWeight: FontWeight.w600, height: 1.4),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: Colors.blue.shade50,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    widget.distance,
                                    style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.w800, fontSize: 11),
                                  ),
                                ),
                              ],
                            ),
                            
                            const SizedBox(height: 32),
                            
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _buildQuickInfo(Icons.access_time_filled_rounded, "Hours", "24/7"),
                                _buildQuickInfo(Icons.local_parking_rounded, "Total Slots", "50+"),
                                _buildQuickInfo(Icons.verified_user_rounded, "Safety", "High"),
                              ],
                            ),
                            
                            const SizedBox(height: 40),
                            
                            const Text(
                              "Pricing Slabs",
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.black87),
                            ),
                            const SizedBox(height: 16),

                            if (details?.slabs != null && details!.slabs!.isNotEmpty)
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade50,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: Colors.grey.shade200),
                                ),
                                child: Column(
                                  children: details!.slabs!.asMap().entries.map((entry) {
                                    final index = entry.key;
                                    final slab = entry.value;
                                    final from = slab.from ?? '0';
                                    final to = slab.to ?? '0';
                                    final price = slab.price ?? '0';
                                    final isLast = index == details.slabs!.length - 1;

                                    return Column(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.all(20),
                                          child: Row(
                                            children: [
                                              const Icon(Icons.timer_outlined, size: 20, color: Colors.black54),
                                              const SizedBox(width: 15),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      "$from to $to Hours",
                                                      style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: Colors.black),
                                                    ),
                                                    Text(
                                                      "Parking duration rate",
                                                      style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Text(
                                                "₹$price",
                                                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Colors.black),
                                              ),
                                            ],
                                          ),
                                        ),
                                        if (!isLast)
                                          Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 20),
                                            child: Divider(height: 1, color: Colors.grey.shade300),
                                          ),
                                      ],
                                    );
                                  }).toList(),
                                ),
                              )
                            else
                              Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade50,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: Colors.grey.shade200),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.timer_outlined, size: 20, color: Colors.black54),
                                    const SizedBox(width: 15),
                                    const Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text("Standard Rate", style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: Colors.black)),
                                        Text("Best value for short stay", style: TextStyle(fontSize: 11, color: Colors.grey)),
                                      ],
                                    ),
                                    const Spacer(),
                                    Text(
                                      "₹${widget.price}",
                                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Colors.black),
                                    ),
                                    const Text(" /hr", style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              ),

                            if (details?.servicesEn != null && details!.servicesEn!.isNotEmpty) ...[
                              const SizedBox(height: 40),
                              const Text(
                                "Services & Amenities",
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.black87),
                              ),
                              const SizedBox(height: 16),
                              Wrap(
                                spacing: 10,
                                runSpacing: 10,
                                children: details!.servicesEn!.split(',').where((s) => s.trim().isNotEmpty).map((service) {
                                  final trimmedService = service.trim();
                                  final bool isHtml = trimmedService.toLowerCase().startsWith('<p>') || 
                                                      (trimmedService.length >= 3 && trimmedService.substring(0, 3).toLowerCase().contains('<p>')) ||
                                                      trimmedService.toLowerCase().contains('<p>');

                                  return Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: Colors.blue.withOpacity(0.05),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: Colors.blue.withOpacity(0.1)),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(Icons.check_circle_rounded, size: 16, color: Colors.blue),
                                        const SizedBox(width: 8),
                                        isHtml
                                            ? Html(
                                                data: trimmedService,
                                                style: {
                                                  "body": Style(
                                                    margin: Margins.zero,
                                                    padding: HtmlPaddings.zero,
                                                    fontSize: FontSize(13),
                                                    fontWeight: FontWeight.w600,
                                                    color: Colors.blue,
                                                  ),
                                                  "p": Style(
                                                    margin: Margins.zero,
                                                    padding: HtmlPaddings.zero,
                                                    fontSize: FontSize(13),
                                                    fontWeight: FontWeight.w600,
                                                    color: Colors.blue,
                                                  ),
                                                },
                                              )
                                            : Text(
                                                trimmedService,
                                                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.blue),
                                              ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                              ),
                            ],
                            
                            const SizedBox(height: 40),
                            const Text(
                              "Location Map",
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.black87),
                            ),
                            const SizedBox(height: 16),
                            GestureDetector(
                              onTap: () => _openGoogleMaps(details?.parkingLat, details?.parkingLong),
                              child: Container(
                                height: 180,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(24),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.05),
                                      blurRadius: 15,
                                      offset: const Offset(0, 5),
                                    ),
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(24),
                                  child: Stack(
                                    children: [
                                      Positioned.fill(
                                        child: ImageFiltered(
                                          imageFilter: ImageFilter.blur(sigmaX: 2.5, sigmaY: 2.5),
                                          child: Image.asset(
                                            Images.mapBg,
                                            fit: BoxFit.fill,
                                          ),
                                        ),
                                      ),
                                      Positioned.fill(
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: Colors.black.withOpacity(0.2),
                                          ),
                                        ),
                                      ),
                                      Center(
                                        child: Container(
                                          padding: const EdgeInsets.all(12),
                                          decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                                          child: const Icon(Icons.directions_rounded, color: Colors.blue, size: 30),
                                        ),
                                      ),
                                      const Positioned(
                                        bottom: 15,
                                        right: 15,
                                        child: Text(
                                          "Tap to Navigate",
                                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 12),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 140),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
          bottomSheet: details == null && controller.isLoading
            ? null
            : Container(
                padding: const EdgeInsets.fromLTRB(20, 15, 20, 25),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 25,
                      offset: const Offset(0, -5),
                    )
                  ],
                ),
                child: SafeArea(
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("STARTING FROM", style: TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 1)),
                            const SizedBox(height: 2),
                            Text(
                              "₹${details?.slabs?.isNotEmpty == true ? details!.slabs![0].price : widget.price}.00",
                              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Colors.black),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        flex: 2,
                        child: Container(
                          height: 56,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(18),
                            gradient: const LinearGradient(
                              colors: [Color(0xFFE65100), Color(0xFFFF8A65)],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.blue.withOpacity(0.3),
                                blurRadius: 12,
                                offset: const Offset(0, 6),
                              )
                            ],
                          ),
                          child: ElevatedButton(
                            onPressed: widget.slots > 0 && !controller.isLoading
                                ? () async {
                                    UserVehicle? vehicle;
                                    if (widget.userVehicleId != null) {
                                      try {
                                        vehicle = controller.userVehicleList.firstWhere((v) => v.id == widget.userVehicleId);
                                      } catch (e) {}
                                    }
                                    
                                    vehicle ??= controller.userVehicleList.isNotEmpty ? controller.userVehicleList[0] : null;

                                    if (vehicle == null) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Please select or add a vehicle first')),
                                      );
                                      return;
                                    }

                                    final now = DateTime.now();
                                    final nextHour = now.add(const Duration(hours: 1));
                                    final formatter = DateFormat('yyyy-MM-dd HH:mm:ss');

                                    final double fee = widget.price.toDouble();

                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => BookingSummaryScreen(
                                          addressId: widget.addressId,
                                          vehicle: vehicle!,
                                          parkingName: details?.parkingNameEn ?? widget.name,
                                          fee: fee,
                                          slabs: details?.slabs,
                                        ),
                                      ),
                                    );
                                  }
                                : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              padding: const EdgeInsets.symmetric(vertical: 0),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                            ),
                            child: controller.isLoading 
                              ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                              : const Text(
                                  "Book Now",
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 0.5),
                                ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
        );
      },
    );
  }

  Widget _buildQuickInfo(IconData icon, String title, String value) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              )
            ],
          ),
          child: Icon(icon, color: Colors.blue, size: 24),
        ),
        const SizedBox(height: 10),
        Text(title, style: TextStyle(color: Colors.grey.shade500, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
        const SizedBox(height: 2),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: Colors.black87)),
      ],
    );
  }
}
