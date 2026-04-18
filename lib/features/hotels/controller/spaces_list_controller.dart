import 'package:flutter/cupertino.dart';
import 'package:mahakal/data/datasource/remote/http/httpClient.dart';
import 'package:mahakal/utill/app_constants.dart';
import '../model/spaces_list_model.dart';

class SpacesListController with ChangeNotifier{

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  SpacesListModel? _spacesListModel;
  SpacesListModel? get spacesListModel => _spacesListModel;

  Future<void> fetchSpaces() async {
    _setLoading(true);

    try{
      final res = await HttpService().getApi(AppConstants.hotelSpacesUrl,isOtherDomain: true);
      if(res != null){
        _spacesListModel = SpacesListModel.fromJson(res);
        print("Spaces List: ${_spacesListModel?.data}");
        _setLoading(false);
      }
    } catch(e){
      print("Spaces Error $e");
      _setLoading(false);

    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

}