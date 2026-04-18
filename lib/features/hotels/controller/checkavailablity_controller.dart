import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../data/datasource/remote/http/httpClient.dart';
import '../../../utill/app_constants.dart';
import '../model/checkavaillblity_model.dart';

class CheckavailablityController with ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  CheckAvailablityModel? _checkAvailablityModel;
  CheckAvailablityModel? get checkAvailablityModel => _checkAvailablityModel;

  List<Room> get availableRooms => _checkAvailablityModel?.data?.rooms ?? [];

  Future<void> checkAvailability({
    required int hotelId,
    required DateTime checkInDate,
    required DateTime checkOutDate,
    required int adults,
    int? children,
  }) async {
    _setLoading(true);
    _error = null;
    notifyListeners();

    final DateFormat _dateFormatter = DateFormat('yyyy-MM-dd');

    Map<String, dynamic> body = {
      "hotel_id": hotelId,
      "start_date": _dateFormatter.format(checkInDate),
      "end_date": _dateFormatter.format(checkOutDate),
      "adults": adults,
      if (children != null && children > 0) "children": children,
    };

    try {
      final response = await HttpService().postApi(
        '${AppConstants.hotelAvaliblityCheckUrl}',
        body,
        isOtherDomain: true,
      );

      print("Hotel Availability Res: $response");

      if (response != null) {
        final data = CheckAvailablityModel.fromJson(response);
        _checkAvailablityModel = data;
        _setLoading(false);
        print("Hotel Availability Data Loaded: ${_checkAvailablityModel?.data?.rooms?.length} rooms");
      } else {
        _error = "No response from server";
        _setLoading(false);
      }
    } catch (e) {
      _error = "Failed to check availability: ${e.toString()}";
      _setLoading(false);
      print("Error in checkAvailability: $e");
    }
  }

  void clearData() {
    _checkAvailablityModel = null;
    _error = null;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}