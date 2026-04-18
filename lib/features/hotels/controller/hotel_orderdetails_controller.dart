import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../../../data/datasource/remote/http/httpClient.dart';
import '../../../utill/app_constants.dart';
import '../model/hotel_order_details_model.dart';
import 'hotel_user_controller.dart';

class HotelOrderDetailsController with ChangeNotifier{

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  HotelOrderDetailModel? _hotelOrderDetailModel;
  HotelOrderDetailModel? get hotelOrderDetailModel => _hotelOrderDetailModel;

  Future<void> fetchHotelOrdersDetails(BuildContext context, String code) async {
    _setLoading(true);
    print("Hotel Order Detail Called");

    try {
      final hotelUserController = Provider.of<HotelUserController>(context, listen: false);

      final token = hotelUserController.hotelUserModel?.data?.token;

      if (token == null || token.isEmpty) {
        print("Hotel user token is null or empty");
        _setLoading(false);
        return;
      }

      print("Hotel User Token: $token");

      final response = await HttpService().getApi(
        AppConstants.hotelOrderDetailsUrl + code,
        isOtherDomain: true,
        userHotelToken: "${token}",
      );

      print("Hotel Order Details Res: $response");

      if (response != null) {
         _hotelOrderDetailModel = HotelOrderDetailModel.fromJson(response);
        print("Hotal Order Details Data:${_hotelOrderDetailModel?.booking?.code}");
         _setLoading(false);
      }
    } catch (e, s) {
      print("Hotel Order Details Error: $e");
      print(s);
    } finally {
    }
  }

  /// Set loading state
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}