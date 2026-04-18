import 'package:flutter/cupertino.dart';
import 'package:mahakal/utill/app_constants.dart';
import '../../../data/datasource/remote/http/httpClient.dart';
import '../model/event_auditorium_model.dart';

class EventAuditoriumController  with ChangeNotifier {

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  EventAuditoriumModel? _eventAuditoriumModel;
  EventAuditoriumModel? get eventAuditoriumModel => _eventAuditoriumModel;

  Future<void> getAuditoriumData(String eventId, int venueId) async{

    setLoading(true);

    Map<String, dynamic> data = {
      "venue_id": "${venueId}"
    };

    try{
      final res = await HttpService().postApi("${AppConstants.eventAuditoriumUrl}${eventId}",data);

      if(res != null){
        _eventAuditoriumModel = EventAuditoriumModel.fromJson(res);
        setLoading(false);

        print("Audi data $_eventAuditoriumModel");
      }
    } catch(e){
      print("Error on Audi Data:${e}");
      setLoading(false);
    }
  }

  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }


}


