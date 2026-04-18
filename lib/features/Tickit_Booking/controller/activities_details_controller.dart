import 'package:flutter/material.dart';
import 'package:mahakal/data/datasource/remote/http/httpClient.dart';
import 'package:mahakal/utill/app_constants.dart';
import '../model/activities_details_model.dart';

class ActivitiesDetailsController with ChangeNotifier{

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  ActivityDetailsModel? _activityDetailsModel;
  ActivityDetailsModel? get activityDetailsModel => _activityDetailsModel;

  Future<void> fetchActivityDetails(String slug) async {
    _setLoading(true);
    try{
      final res = await HttpService().getApi("${AppConstants.activityDetailsUrl}$slug");
      if(res != null){
        _activityDetailsModel = ActivityDetailsModel.fromJson(res);
        _setLoading(false);
      }
    }catch(e){
      _setLoading(false);
      print(e.toString());
    }
  }


  void _setLoading(bool isLoading){
    _isLoading = isLoading;
    notifyListeners();
  }

}