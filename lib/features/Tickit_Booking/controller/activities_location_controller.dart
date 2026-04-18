import 'package:flutter/cupertino.dart';
import '../../../data/datasource/remote/http/httpClient.dart';
import '../../../utill/app_constants.dart';
import '../model/activities_location_model.dart';

class ActivitiesLocationController with ChangeNotifier{

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  ActivitiesLocationListModel? _activitiesLocationListModel;
  ActivitiesLocationListModel? get activitiesLocationListModel => _activitiesLocationListModel;

  Future<void> getActivitiesLocationList() async {
    _setLoading(true);
    try{
      final res = await HttpService().getApi("${AppConstants.activityLocationUrl}");
      if(res != null){
        _activitiesLocationListModel = ActivitiesLocationListModel.fromJson(res);
        _setLoading(false);
      }
    } catch(e){
      _setLoading(false);
    }
  }

  void _setLoading(bool value){
    _isLoading = value;
    notifyListeners();
  }

}