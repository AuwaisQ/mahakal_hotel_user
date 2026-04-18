import 'package:flutter/cupertino.dart';
import '../../../data/datasource/remote/http/httpClient.dart';
import '../../../utill/app_constants.dart';
import '../model/event_package_model.dart';

class EventPackageController with ChangeNotifier {

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _message;
  String? get message => _message;

  EventPackageModel? _eventPackageModel;
  EventPackageModel? get eventPackageModel => _eventPackageModel;


  /// EVENT PACKAGE API (POST)
  Future<bool> getEventPackage({
    required String eventId,
    required String eventVenue,
  }) async {

    _setLoading(true);

    try {

      Map<String, dynamic> data = {
        "en_event_venue": eventVenue,
      };

      final res = await HttpService().postApi(
        "${AppConstants.eventPackageUrl}$eventId",
        data,
      );

      if (res != null && res["status"] == 1) {

        _eventPackageModel = EventPackageModel.fromJson(res);
        _message = res["message"];

        print("Auditoram Status:${_eventPackageModel?.data.auditorium}");
        _setLoading(false);
        return true;

      }

      _setLoading(false);
      return false;

    } catch (e) {

      print("Event Package API Error: $e");

      _setLoading(false);
      return false;

    }

  }


  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

}