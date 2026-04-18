import 'package:flutter/cupertino.dart';

import '../../../data/datasource/remote/http/httpClient.dart';
import '../../../utill/app_constants.dart';
import '../model/tickit_availiblity_model.dart';

class TickitAvailablityController with ChangeNotifier {

  TickitAvailiblityModel? _tickitAvailiblityModel;
  TickitAvailiblityModel? get tickitAvailiblityModel => _tickitAvailiblityModel;

  bool _isLoading = false; //  CHANGE TO FALSE - Initially loading nahi hona chahiye
  bool get isLoading => _isLoading;

  bool _hasCheckedAvailability = false; //  Add yeh flag
  bool get hasCheckedAvailability => _hasCheckedAvailability;

  Future<void> getTickitAvailiblity(String slug, String date, String id) async {

    _setLoading(true);
    _hasCheckedAvailability = false; //  Reset kar do

    try {
      Map<String, dynamic> data = {
        "date": date, //  User selected date use karo
        "time_id": int.tryParse(id) ?? 1, //  Convert string to int
      };

      final res = await HttpService().postApi(
          "${AppConstants.activityAvailUrl}${slug}",
          data
      );

      if (res != null) {
        _tickitAvailiblityModel = TickitAvailiblityModel.fromJson(res);
        _hasCheckedAvailability = true; //  Availability checked mark karo
      }
    } catch (e) {
      print("Error in Check Tickit Ava : $e");
      _hasCheckedAvailability = true; //  Error mein bhi checked mark karo
    } finally {
      _setLoading(false); //  FINALLY mein loading false karo
    }
  }

  void resetAvailability() {
    _tickitAvailiblityModel = null;
    _hasCheckedAvailability = false;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}