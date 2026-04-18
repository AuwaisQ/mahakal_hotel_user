import 'package:flutter/material.dart';
import '../../../data/datasource/remote/http/httpClient.dart';
import '../../../utill/app_constants.dart';
import '../model/activity_pass_model.dart';

class ActivitiesPassController with ChangeNotifier {

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  ActivitiesPassModel? _activitiesPassModel;
  ActivitiesPassModel? get activitiesPassModel => _activitiesPassModel;

  List<Datum>? get passDataList => _activitiesPassModel?.data;

  /// Get single pass data by index
  Datum? getPassDataByIndex(int index) {
    if (_activitiesPassModel?.data != null &&
        index < _activitiesPassModel!.data.length) {
      return _activitiesPassModel!.data[index];
    }
    return null;
  }

  /// Get total number of passes
  int get totalPasses => _activitiesPassModel?.data.length ?? 0;

  /// Fetch Activities Pass/QR Code by order ID
  Future<void> fetchActivitiesPass({
    required String orderId,
  }) async {

    _setLoading(true);
    debugPrint("🎫 Activities Pass Fetch Called - Order ID: $orderId");

    try {
      final response = await HttpService().getApi(
        "${AppConstants.activitiesPassUrl}$orderId",
      );

      debugPrint("🎫 Activities Pass Response: $response");

      if (response != null) {
        _activitiesPassModel = ActivitiesPassModel.fromJson(response);
        debugPrint("✅ Activities Pass Fetched Successfully");
        debugPrint("📊 Total Passes: ${_activitiesPassModel?.data.length ?? 0}");
      } else {
        debugPrint("⚠️ Activities Pass Response is null");
      }

    } catch (e, s) {
      debugPrint("❌ Activities Pass Fetch Error: $e");
      debugPrintStack(stackTrace: s);
    } finally {
      _setLoading(false);
    }
  }

  /// Clear pass data
  void clearData() {
    _activitiesPassModel = null;
    notifyListeners();
    debugPrint("🧹 Activities Pass Data Cleared");
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  /// Format event date for display
  String formatEventDate(String dateWithTime) {
    if (dateWithTime.isEmpty) return "Date not available";

    try {
      List<String> parts = dateWithTime.split(" ");
      if (parts.length < 5) return dateWithTime;

      String eventDate = "${parts[0]} ${parts[1]} ${parts[2]}"; // "29 Mar 2025"
      String eventTime = "${parts[3]} ${parts[4]}"; // "08:00 AM"

      return "$eventDate at $eventTime";
    } catch (e) {
      return dateWithTime;
    }
  }

  /// Get event name based on language preference
  String getEventName(Datum passData, {bool isEnglish = true}) {
    return isEnglish ? passData.enEventName : passData.hiEventName;
  }

  /// Get package name based on language preference
  String getPackageName(Datum passData, {bool isEnglish = true}) {
    return isEnglish ? passData.enPackageName : passData.hiPackageName;
  }

  /// Get artist name based on language preference
  String getArtistName(Datum passData, {bool isEnglish = true}) {
    return isEnglish ? passData.enArtistName : passData.hiArtistName;
  }

  /// Get organizer name based on language preference
  String getOrganizerName(Datum passData, {bool isEnglish = true}) {
    return isEnglish ? passData.enOrganizerName : passData.hiOrganizerName;
  }

  /// Get category name based on language preference
  String getCategoryName(Datum passData, {bool isEnglish = true}) {
    return isEnglish ? passData.enCategoryName : passData.hiCategoryName;
  }

  /// Get venue name based on language preference
  String getVenueName(Datum passData, {bool isEnglish = true}) {
    return isEnglish ? passData.enEventVenue : passData.hiEventVenue;
  }

  /// Parse seats string to list
  List<String> parseSeats(String seatsString) {
    if (seatsString.isEmpty) return [];
    return seatsString.split(',').map((seat) => seat.trim()).toList();
  }

  /// Parse rows string to list
  List<String> parseRows(String rowsString) {
    if (rowsString.isEmpty) return [];
    return rowsString.split(',').map((row) => row.trim()).toList();
  }

  /// Get formatted seat numbers
  String getFormattedSeats(Datum passData) {
    if (passData.seats.isEmpty) return "N/A";
    return passData.seats;
  }

  /// Get pass holder name
  String getPassHolderName(Datum passData) {
    return passData.passUserName.isEmpty ? "Guest" : passData.passUserName;
  }

  /// Check if pass is valid
  bool isPassValid(Datum passData) {
    return passData.passUrl.isNotEmpty &&
        passData.amount > 0 &&
        passData.eventDate.isNotEmpty;
  }

  /// Get total amount formatted
  String getFormattedAmount(Datum passData) {
    return "₹ ${passData.amount}";
  }

  /// Validate if order has passes
  bool get hasPasses => _activitiesPassModel?.data.isNotEmpty ?? false;

  /// Get status code
  int get statusCode => _activitiesPassModel?.status ?? 0;

  /// Check if API call was successful
  bool get isSuccess => _activitiesPassModel?.status == 1;
}