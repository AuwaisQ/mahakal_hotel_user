import 'dart:convert';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import '../../self_drive/widgets/google_search_screen.dart';

class LocationSearchWidget extends StatefulWidget {
  final GoogleMapController? mapController;
  final TextEditingController controller;
  final Function(double lat, double lng, String address) onLocationSelected;
  final String hintText;
  final FocusNode? focusNode; // 👈 add this (optional)
  final VoidCallback? onTap;
  const LocationSearchWidget({
    Key? key,
    required this.hintText,
    required this.mapController,
    required this.controller,
    required this.onLocationSelected,
    this.focusNode,
    this.onTap,
  }) : super(key: key);

  @override
  State<LocationSearchWidget> createState() => _LocationSearchWidgetState();
}

class _LocationSearchWidgetState extends State<LocationSearchWidget> {
  void _openSearchScreen() async {
    FocusManager.instance.primaryFocus?.unfocus();
    final result = await Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (context) => GoogleSearchScreen(
          hintText: widget.hintText,
        ),
      ),
    );

    if (result != null && result is Map<String, dynamic>) {
      double lat = result['lat'];
      double lng = result['lng'];
      String address = result['address'];
      String description = result['description'];

      // Move Google Map to location
      widget.mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(LatLng(lat, lng), 14),
      );

      // update text
      widget.controller.text = description;

      // pass values back
      widget.onLocationSelected(lat, lng, address);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap ?? _openSearchScreen,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.grey.shade300, width: 1),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: AbsorbPointer(
          child: TextFormField(
            controller: widget.controller,
            focusNode: widget.focusNode,
            readOnly: true,
            showCursor: false,
            style: const TextStyle(fontSize: 16, color: Colors.black87),
            decoration: InputDecoration(
              hintText: widget.hintText,
              hintStyle: TextStyle(color: Colors.grey.shade500),
              prefixIcon: const Icon(Icons.search, color: Colors.blue),
              suffixIcon: widget.controller.text.isEmpty
                  ? const Icon(Icons.location_on_outlined,
                      size: 20, color: Colors.blue)
                  : InkWell(
                      onTap: () {
                        widget.controller.clear();
                        setState(() {});
                      },
                      child: const Icon(Icons.cancel,
                          size: 22, color: Colors.blue)),
              border: InputBorder.none,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
          ),
        ),
      ),
    );
  }
}

class AppLocationData {
  static String selectedCityProduct = '';
}


class LocationSearchController extends ChangeNotifier {
  final String apiKey = 'AIzaSyA9WZ75akgvEYdJiPK1UQIpYNhiuStGQhA';

  List<Map<String, String>> suggestions = [];
  bool isLoading = false;

  Future<void> searchLocation(String input) async {
    if (input.isEmpty) {
      suggestions = [];
      notifyListeners();
      return;
    }

    isLoading = true;
    notifyListeners();

    final url =
        'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$input&key=$apiKey&components=country:in';

    try {
      final res = await http.get(Uri.parse(url));
      final data = json.decode(res.body);

      if (data['status'] == 'OK') {
        suggestions = (data['predictions'] as List)
            .map((p) => {
          'description': p['description'].toString(),
          'placeId': p['place_id'].toString(),
        })
            .toList();
      } else {
        suggestions = [];
      }
    } catch (e) {
      suggestions = [];
    }

    isLoading = false;
    notifyListeners();
  }

  Future<Map<String, dynamic>?> getPlaceDetails(String placeId) async {
    final url =
        'https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&key=$apiKey';

    final res = await http.get(Uri.parse(url));
    final data = json.decode(res.body);

    if (data['status'] == 'OK') {
      return data['result'];
    }
    return null;
  }

  void clear() {
    suggestions = [];
    notifyListeners();
  }
}

class CustomLocationField extends StatelessWidget {
  final TextEditingController controller;
  final LocationSearchController searchController;
  final Function(double, double, String) onSelected;

  const CustomLocationField({
    super.key,
    required this.controller,
    required this.searchController,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        /// 🔹 Compact Dotted Input
        DottedBorder(
          borderType: BorderType.RRect,
          radius: const Radius.circular(25),
          dashPattern: const [5, 3],
          color: Colors.grey.shade400,
          strokeWidth: 1,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [

                const Icon(Icons.search, size: 18, color: Colors.grey),

                const SizedBox(width: 8),

                /// 🔥 TextField
                Expanded(
                  child: TextField(
                    controller: controller,
                    onChanged: (val) {
                      searchController.searchLocation(val);
                      searchController.notifyListeners(); // 👈 refresh UI
                    },
                    style: const TextStyle(fontSize: 14),
                    decoration: const InputDecoration(
                      hintText: "Search location",
                      border: InputBorder.none,
                      isDense: true,
                    ),
                  ),
                ),

                /// 🔥 Right Icon Logic
                AnimatedBuilder(
                  animation: searchController,
                  builder: (_, __) {

                    /// 👉 Loading
                    if (searchController.isLoading) {
                      return const SizedBox(
                        height: 16,
                        width: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      );
                    }

                    /// 👉 Show CLEAR button when text filled
                    if (controller.text.isNotEmpty) {
                      return GestureDetector(
                        onTap: () {
                          controller.clear();
                          searchController.clear();
                          searchController.notifyListeners();
                        },
                        child: const Icon(Icons.close,
                            size: 18, color: Colors.grey),
                      );
                    }

                    /// 👉 Default icon
                    return const Icon(Icons.location_on_outlined,
                        size: 18, color: Colors.grey);
                  },
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 6),

        /// 🔹 Suggestions (More Compact)
        AnimatedBuilder(
          animation: searchController,
          builder: (_, __) {
            return searchController.suggestions.isEmpty
                ? const SizedBox()
                : Container(
              margin: const EdgeInsets.only(top: 4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  )
                ],
              ),
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: searchController.suggestions.length,
                separatorBuilder: (_, __) => Divider(
                  height: 1,
                  color: Colors.grey.shade200,
                ),
                itemBuilder: (context, index) {
                  final item =
                  searchController.suggestions[index];

                  return InkWell(
                    onTap: () async {
                      final details =
                      await searchController.getPlaceDetails(
                          item['placeId']!);

                      if (details != null) {
                        final loc = details['geometry']['location'];
                        onSelected(
                          loc['lat'],
                          loc['lng'],
                          details['formatted_address'],
                        );
                      }

                      controller.text = item['description']!;
                      searchController.clear();
                      searchController.notifyListeners();
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 10),
                      child: Row(
                        children: [
                          Icon(Icons.location_on,
                              size: 16,
                              color: Colors.grey.shade500),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              item['description']!,
                              style: const TextStyle(fontSize: 13),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ],
    );
  }
}