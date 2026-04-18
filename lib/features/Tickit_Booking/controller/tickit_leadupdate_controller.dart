import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../data/datasource/remote/http/httpClient.dart';
import '../../../utill/app_constants.dart';

class UpdateLeadController with ChangeNotifier {

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  int? _id;
  int? get id => _id;

  String? _message;
  String? get message => _message;

  ///  Update Lead API
  Future<bool> updateLead({
    required String leadId,
    required String packageId,
    required String venueId,
    required int qty,
    required double amount,
    required double couponAmount,
    required String couponId,
    required double totalAmount,
    required String date,
    required List<Map<String, dynamic>> userInformation,
  }) async {

    _setLoading(true);

    try {

      Map<String, dynamic> data = {
        "lead_id": leadId,
        "package_id": packageId,
        "venue_id": venueId,
        "qty": qty.toString(),
        "amount": amount.toStringAsFixed(0),
        "coupon_amount": couponAmount.toStringAsFixed(0),
        "coupon_id": couponId,
        "total_amount": totalAmount.toStringAsFixed(0),
        "date": date,
        "user_information": jsonEncode(userInformation),
      };

      print(" Activity Lead Update Data: ${jsonEncode(data)}");

      final res = await HttpService().postApi(
        AppConstants.activityUpdateLeadUrl,
        data,
      );

      if (res != null && res["status"] == 1) {
        _message = res["message"];
        _id = res["id"];

        print("Message $_message");
        print("Id IS $_id");

        _setLoading(false);
        return true;
      }

      _setLoading(false);
      return false;

    } catch (e) {
      print(" Error in Update Lead API: $e");
      _setLoading(false);
      return false;
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
