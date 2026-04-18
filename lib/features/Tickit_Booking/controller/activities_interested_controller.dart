import 'package:flutter/cupertino.dart';
import '../../../data/datasource/remote/http/httpClient.dart';
import '../../../utill/app_constants.dart';

class ActivitiesInterestController with ChangeNotifier {
  bool _isLoading = false;
  bool _isInterested = false;

  bool get isLoading => _isLoading;
  bool get isInterested => _isInterested;

  /// 🔹 Set initial value from API
  void setInitialStatus(int status) {
    _isInterested = status == 1;
    notifyListeners();
  }

  Future<void> interestedEvent({
    required int eventId,
    required int userId,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final res = await HttpService().postApi(
        AppConstants.eventIntrestedUrl,
        {
          "event_id": eventId,
          "user_id": userId,
        },
      );

      if (res['status'] == 200) {
        _isInterested = true;
      }
    } catch (e) {
      print("Interest error: $e");
    }

    _isLoading = false;
    notifyListeners();
  }
}
