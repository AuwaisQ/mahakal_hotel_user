import 'package:flutter/cupertino.dart';
import 'package:mahakal/data/datasource/remote/http/httpClient.dart';
import 'package:mahakal/utill/app_constants.dart';
import '../model/activities_category_model.dart';

class ActivitiesCategoryController with ChangeNotifier{

  ActivitiesCategoryModel? _activitiesCategoryModel;
  ActivitiesCategoryModel get activitiesCategoryModel => _activitiesCategoryModel!;

  List<AcitivityCategoryList> _activitiesCategoryList = [];
  List<AcitivityCategoryList> get activitiesCategoryList => _activitiesCategoryList;

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  Future<void> getActivitiesCategory() async {
    setLoading(true);
    try{
      final res = await HttpService().getApi("${AppConstants.activityCategoryUrl}");

      if(res != null){
        _activitiesCategoryModel = ActivitiesCategoryModel.fromJson(res);
        _activitiesCategoryList = _activitiesCategoryModel!.data;
        setLoading(false);
      }
    } catch(e){
      setLoading(false);
    }
  }


  void setLoading(bool value){
    _isLoading = value;
    notifyListeners();
  }


}