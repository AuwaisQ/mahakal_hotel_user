import 'package:flutter/cupertino.dart';
import '../../../data/datasource/remote/http/httpClient.dart';
import '../../../utill/app_constants.dart';

class EventBookingController with ChangeNotifier {

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _message;
  String? get message => _message;

  /// Event Booking Success API
  Future<bool> eventBooking({
    required String userId,
    required String eventId,
    required String venueId,
    required String packageId,
    required int noOfSeats,
    required String amount,
    required String leadId,
    required String walletType,
    required String transactionId,
    required String onlineAmount,
    required String couponAmount,
    required String couponId,
  }) async {

    _setLoading(true);
    print("Event Booking Method Called");

    try {

      Map<String, dynamic> data = {
        "user_id": userId,
        "event_id": eventId,
        "venue_id": venueId,
        "package_id": packageId,
        "no_of_seats": noOfSeats,
        "amount": amount,
        "lead_id": leadId,
        "wallet_type": walletType,
        "transaction_id": transactionId,
        "online_amount": onlineAmount,
        "coupon_amount": couponAmount,
        "coupon_id": couponId
      };

      print("Event Booking Data: $data");

      final res = await HttpService().postApi(
        AppConstants.orderSuccessUrl,
        data,
      );

      if (res != null && res["status"] == 1) {
        _message = res["message"];
        print("Event Booking Message: $_message");
        _setLoading(false);
        return true;
      }

      _setLoading(false);
      return false;

    } catch (e) {
      print("Error in Event Booking API: $e");
      _setLoading(false);
      return false;
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}