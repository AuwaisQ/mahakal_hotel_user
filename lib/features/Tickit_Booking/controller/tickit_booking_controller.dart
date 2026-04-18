import 'package:flutter/cupertino.dart';
import '../../../data/datasource/remote/http/httpClient.dart';
import '../../../utill/app_constants.dart';

class TickitBookingController with ChangeNotifier {

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _message;
  String? get message => _message;

  /// Booking Success API
  Future<bool> bookingSuccess({
    required String leadId,
    required String walletType,
    required String transactionId,
    required String onlineAmount,
  }) async {

    _setLoading(true);
    print("Booking Success Method Called");

    try {

      Map<String, dynamic> data = {
        "lead_id": leadId,
        "wallet_type": walletType,
        "transaction_id": transactionId,
        "online_amount": onlineAmount,
      };

      print("Booking Success Data: $data");

      final res = await HttpService().postApi(
        AppConstants.activityBookingSuccessUrl, // Make sure this constant exists
        data,
      );

      if (res != null && res["status"] == 1) {
        _message = res["message"];
        print("Booking Success Message $_message");
        _setLoading(false);
        return true;
      }

      _setLoading(false);
      return false;

    } catch (e) {
      print("Error in Booking Success API: $e");
      _setLoading(false);
      return false;
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
