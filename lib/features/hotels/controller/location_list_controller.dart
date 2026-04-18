import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../../../data/datasource/remote/http/httpClient.dart';
import '../../../main.dart';
import '../../../utill/app_constants.dart';
import '../../auth/controllers/auth_controller.dart';
import '../model/hotel_location_model.dart';

class LocationListController with ChangeNotifier {
  bool _isLoading = true;
  bool get isLoading => _isLoading;

  String _lat = "";
  String get lat => _lat;

  String _long = "";
  String get long => _long;

  List<HotelLocation> _locations = [];
  List<HotelLocation> get locations => _locations;

  List<HotelLocation> _filteredLocations = [];
  List<HotelLocation> get filteredLocations => _filteredLocations;

  String _searchLocation = "";
  String get searchLocation => _searchLocation;

  List<HotelLocation> _nearRestLocations = [];
  List<HotelLocation> get nearRestLocations => _nearRestLocations;

  // User's current location
  double? _userLat;
  double? _userLong;

  Future<void> fetchLocations() async {
    _setLoading(true);

    try {
      // Get user's current location from AuthController
      final authController = Provider.of<AuthController>(
          Get.context!,
          listen: false
      );

      // Store user's current location
      _userLat = double.tryParse(authController.latitude.toString());
      _userLong = double.tryParse(authController.longitude.toString());

      print("User Location - Lat: $_userLat, Long: $_userLong");

      final response = await HttpService().getApi(
          '${AppConstants.hotelLocationsUrl}',
          isOtherDomain: true
      );

      print("Hotel Location Res: $response");

      if (response != null) {
        final data = HotelLocationModel.fromJson(response);
        _locations = data.data?.locations ?? [];
        _filteredLocations = _locations;

        // Calculate nearest locations if user location is available
        if (_userLat != null && _userLong != null) {
          _calculateNearRestLocations();
        }

        // Set first location as default (if available)
        if (_locations.isNotEmpty) {
          _lat = _locations[0].mapLat;
          _long = _locations[0].mapLng;
        }

        _setLoading(false);
        print("Total Locations: ${_locations.length}");
        print("Near Rest Locations: ${_nearRestLocations.length}");
      }
    } catch (e) {
      print("Error fetching locations: $e");
      _setLoading(false);
    }
  }

  void filterLocations(String query) {
    _searchLocation = query;

    if (query.isEmpty) {
      _filteredLocations = _locations;
    } else {
      _filteredLocations = _locations
          .where((location) =>
          (location.name ?? '')
              .toLowerCase()
              .contains(query.toLowerCase()))
          .toList();
    }

    notifyListeners(); //
  }

  /// Calculate nearest locations based on user's current location
  void _calculateNearRestLocations() {
    if (_userLat == null || _userLong == null || _locations.isEmpty) {
      _nearRestLocations = [];
      return;
    }

    // Create a list of locations with distance
    final locationDistances = _locations.map((location) {
      final lat = double.tryParse(location.mapLat);
      final lng = double.tryParse(location.mapLng);

      if (lat == null || lng == null) {
        return _LocationWithDistance(location, double.infinity);
      }

      final distance = _calculateDistance(
          _userLat!, _userLong!,
          lat, lng
      );

      return _LocationWithDistance(location, distance);
    }).toList();

    // Sort by distance (nearest first)
    locationDistances.sort((a, b) => a.distance.compareTo(b.distance));

    // Take top 5 nearest locations (or all if less than 5)
    final nearestCount = locationDistances.length > 5 ? 5 : locationDistances.length;
    _nearRestLocations = locationDistances
        .sublist(0, nearestCount)
        .map((ld) => ld.location)
        .toList();
  }

  /// Calculate distance between two coordinates in kilometers
  /// Using Haversine formula
  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const earthRadius = 6371.0; // Earth's radius in kilometers

    // Convert degrees to radians
    final dLat = _toRadians(lat2 - lat1);
    final dLon = _toRadians(lon2 - lon1);

    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRadians(lat1)) * cos(_toRadians(lat2)) *
            sin(dLon / 2) * sin(dLon / 2);

    final c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return earthRadius * c; // Distance in kilometers
  }

  double _toRadians(double degrees) {
    return degrees * pi / 180;
  }

  /// Set loading state
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}

/// Helper class to store location with its distance
class _LocationWithDistance {
  final HotelLocation location;
  final double distance;

  _LocationWithDistance(this.location, this.distance);
}