import 'package:flutter/cupertino.dart';
import 'package:path/path.dart';
import 'package:provider/provider.dart';
import '../../../data/datasource/remote/http/httpClient.dart';
import '../../../utill/app_constants.dart';
import '../model/check_order_status_model.dart';
import '../model/hotel_order_list.dart';
import 'hotel_user_controller.dart';

class CheckOrderStatusController with ChangeNotifier{

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  List<DraftHotelOrder> _draftOrderList = [];
  List<DraftHotelOrder> get draftOrderList => _draftOrderList;

  Future<void> fetchDraftOrders(BuildContext context) async {
    _setLoading(true);
    print("Hotel Order Called");

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
        AppConstants.drafthotelOrdersUrl,
        isOtherDomain: true,
        userHotelToken: "${token}",
      );

      print("Hotel Order Res: $response");

      if (response != null) {
        final data = CheckOrderStatusModel.fromJson(response);
        _draftOrderList = data.data?.bookings?.data ?? [];
        print("Hotal Order Data:${_draftOrderList}");
      }
    } catch (e, s) {
      print("❌ Hotel Order Error: $e");
      print(s);
    } finally {
      _setLoading(false);
    }
  }

  /// Set loading state
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}