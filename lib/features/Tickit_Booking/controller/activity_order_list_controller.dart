import 'package:flutter/cupertino.dart';
import '../../../data/datasource/remote/http/httpClient.dart';
import '../../../utill/app_constants.dart';
import '../model/activity_order_list_model.dart';

class ActivitiesOrderController with ChangeNotifier {

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  List<ActivitiesOrders> _activitiesOrderList = [];
  List<ActivitiesOrders> get activitiesOrderList => _activitiesOrderList;

  Future<void> fetchActivitiesOrders(BuildContext context) async {
    _setLoading(true);
    print("Activities Order Called");

    try {
      final response = await HttpService().getApi(
        AppConstants.activityOrderListUrl,
      );

      print("Activities Order Res: $response");

      if (response != null) {
        final data = ActivitiesOrderListModel.fromJson(response);

        _activitiesOrderList = data.data ?? [];
        print("Activities Order Data: $_activitiesOrderList");
      }
    } catch (e) {
      print("Activities Order Error: $e");
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
