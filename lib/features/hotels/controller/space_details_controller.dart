import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:mahakal/data/datasource/remote/http/httpClient.dart';
import '../../../utill/app_constants.dart';
import '../model/space_details_model.dart';

class SpaceDetailsController with ChangeNotifier {

  SpaceDetailsModel? _spaceDetailsModel;
  SpaceDetailsModel get spaceDetailsModel => _spaceDetailsModel!;

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  Future<void> fetchSpaceDetails(int spaceId) async {
    _setLoading(true);
    try{
      final response = await HttpService().getApi('${AppConstants.spaceDetailsUrl}${spaceId}', isOtherDomain: true);
      print("Space Details Res: $response");

      if(response != null) {
        final data = SpaceDetailsModel.fromJson(response);
        _spaceDetailsModel = data;
        _setLoading(false);
        print("Space Details Data${_spaceDetailsModel!.data!.space}");
      }
    }
    catch(e){
      print("Error in Space Details$e");
      _setLoading(false);
    }
  }


  /// Set loading state
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

}