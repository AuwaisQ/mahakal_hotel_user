import 'package:flutter/cupertino.dart';
import 'package:mahakal/features/Tickit_Booking/model/tickit_summery_model.dart';
import 'package:mahakal/utill/app_constants.dart';
import '../../../data/datasource/remote/http/httpClient.dart';

class TickitSummeryController with ChangeNotifier{

  TickitSummeryModel? _tickitSummeryModel;
  TickitSummeryModel? get tickitSummeryModel => _tickitSummeryModel;

  bool _isLoading = false;
  bool get loading => _isLoading;

  Future<void> getTickitSummery(String slug, String venue) async {

    _setLoading(true);

    try{
      Map<String,dynamic> data = {
        "en_event_venue":"$venue",
      };

      final res = await HttpService().postApi("${AppConstants.activitySummeryUrl}${slug}", data);

      if(res != null){
        _tickitSummeryModel = TickitSummeryModel.fromJson(res);
        _setLoading(false);
      }
    } catch(e){
      print("Error in Tickit Summery $e");
      _setLoading(false);
    }
  }

  void _setLoading(bool value){
    _isLoading = value;
    notifyListeners();
  }

}