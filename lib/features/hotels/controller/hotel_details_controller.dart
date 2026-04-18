import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:mahakal/data/datasource/remote/http/httpClient.dart';
import '../../../utill/app_constants.dart';
import '../model/features_hotel_model.dart';
import '../model/hotel_details_model.dart';

class HotelDetailsController with ChangeNotifier {

  HotelDetailsModel? _hotelDetailsModel;
  HotelDetailsModel? get hotelDetailsModel => _hotelDetailsModel;

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  Future<void> fetchHotelDetails(int hotelId) async {
    _setLoading(true);
   // try{
      final response = await HttpService().getApi('${AppConstants.hotelDetailsUrl}${hotelId}', isOtherDomain: true);
      print("Hotel Details Res: $response");

      if(response != null) {
        final data = HotelDetailsModel.fromJson(response);
        _hotelDetailsModel = data;
        _setLoading(false);
        print("Hotel Details Data${_hotelDetailsModel!.data!.hotel}");
      }
    // }
    // catch(e){
      //print("Error in Hotel Details$e");
      _setLoading(false);
   // }
  }


  /// Set loading state
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

}