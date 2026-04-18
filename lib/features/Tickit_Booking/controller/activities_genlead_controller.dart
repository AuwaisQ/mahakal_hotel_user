import 'package:flutter/cupertino.dart';
import '../../../data/datasource/remote/http/httpClient.dart';
import '../../../utill/app_constants.dart';

class LeadGenerateController with ChangeNotifier {

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  int? _leadId;
  int? get leadId => _leadId;

  String? _message;
  String? get message => _message;

  ///  Create Lead API
  Future<bool> createLead({
    required String userId,
    required String eventId,
    required String venueId,
  }) async {

    _setLoading(true);
    print("Lead Method Called");

    try {

      Map<String, dynamic> data = {
        "user_id": userId,
        "event_id": eventId,
        "venue_id": venueId,
      };

      final res = await HttpService().postApi("${AppConstants.activityLeadGenUrl}", data,);

      if (res != null && res["status"] == 1) {
        _leadId = res["id"];
        _message = res["message"];
        print("Activity lead id $_leadId");
        _setLoading(false);
        return true;
      }

      _setLoading(false);
      return false;

    } catch (e) {
      print("Error in Create Lead API: $e");
      _setLoading(false);
      return false;
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
