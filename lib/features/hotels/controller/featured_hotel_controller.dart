import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:mahakal/data/datasource/remote/http/httpClient.dart';
import '../../../utill/app_constants.dart';
import '../model/features_hotel_model.dart';

class FeaturedHotelController with ChangeNotifier {

  FeaturesHotelModel? _featuresHotelModel;
  FeaturesHotelModel get featuresHotelModel => _featuresHotelModel!;

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  Future<void> fetchFeaturedHotels() async {
    print("Method Called");
    _setLoading(true);
    try{
      final response = await HttpService().getApi('${AppConstants.featuredHotelsUrl}', isOtherDomain: true);
      print("Features Res: $response");

      if(response != null) {
        final data = FeaturesHotelModel.fromJson(response);
        _featuresHotelModel = data;
        _setLoading(false);
        print("Featured Hotel Data${_featuresHotelModel!.data!.hotels}");
      }
   }
    catch(e){
      print("Error in Featured Hotel $e");
      _setLoading(false);
    }
  }


  /// Set loading state
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

}