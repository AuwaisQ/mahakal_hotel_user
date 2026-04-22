import 'package:flutter/cupertino.dart';
import 'package:mahakal/data/datasource/remote/http/httpClient.dart';

import '../model/coupon_model.dart';

class FetchCouponController with ChangeNotifier {
  List<Couponlist> _couponlist = [];
  List<Couponlist> get couponlist => _couponlist;

  Future<void> fetchCoupon(
      {required String type, required String couponUrl}) async {
    Map<String, dynamic> data = {"type": type};
    try {
      final response = await HttpService().postApi(couponUrl, data);

      if (response != null && response['coupons'] != null) {
        // _couponlist.clear();
        List data = response['coupons'];
        _couponlist = data.map((e) => Couponlist.fromJson(e)).toList();
        print("Tour Coupons: ${_couponlist}");
        notifyListeners();
      } else {
        _couponlist = [];
        print("No coupons found or invalid response");
      }
    } catch (e) {
      print("Fetch Coupon Error in $type: $e");
    }
  }
}
