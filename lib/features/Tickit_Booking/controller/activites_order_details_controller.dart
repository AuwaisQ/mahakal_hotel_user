import 'package:flutter/material.dart';
import '../../../data/datasource/remote/http/httpClient.dart';
import '../../../utill/app_constants.dart';
import '../model/activities_order_details_model.dart';

class ActivitiesOrderDetailController with ChangeNotifier {

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  ActivitiesOrderDetailModel? _orderDetailModel;
  ActivitiesOrderDetailModel? get orderDetailModel => _orderDetailModel;

  Data? get orderData => _orderDetailModel?.data;

  /// Fetch Activity Order Detail
  Future<void> fetchActivitiesOrderDetail({
    required String orderId,
  }) async {

    _setLoading(true);
    debugPrint("📦 Activity Order Detail Called: $orderId");

    try {
      final response = await HttpService().getApi(
        "${AppConstants.activityOrderDetailUrl}$orderId",
      );

      debugPrint("📦 Activity Order Detail Response: $response");

      if (response != null) {
        _orderDetailModel = ActivitiesOrderDetailModel.fromJson(response);
      }

    } catch (e, s) {
      debugPrint("❌ Activity Order Detail Error: $e");
      debugPrintStack(stackTrace: s);
    } finally {
      _setLoading(false);
    }
  }

  /// Clear old data (optional but recommended)
  void clearData() {
    _orderDetailModel = null;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
