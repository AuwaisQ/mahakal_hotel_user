import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../../../data/datasource/remote/http/httpClient.dart';
import '../../../main.dart';
import '../../../utill/app_constants.dart';
import '../../profile/controllers/profile_contrroller.dart';
import '../model/lead_generate_model.dart';

class TourLeadController with ChangeNotifier {
  LeadGenerateModel? leadGenerateModel;

  Future<void> generateTourLead({
    required String tourId,
    required String packageId,
    required String amount,
  }) async {
    Map<String, dynamic> data = {
      "tour_id": tourId,
      "package_id": packageId,
      "user_id": Provider.of<ProfileController>(Get.context!, listen: false).userID,
      "amount": amount
    };

    try {
      final res = await HttpService().postApi(AppConstants.tourLeadUrl, data);

      if (res != null) {
        leadGenerateModel = LeadGenerateModel.fromJson(res);
        notifyListeners();
        print("Lead Data: ${leadGenerateModel!.data.insertId}");
      }
    } catch (e) {
      print("Tour Lead Generate Error");
    }
  }
}
