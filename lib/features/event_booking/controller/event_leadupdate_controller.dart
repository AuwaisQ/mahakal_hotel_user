import 'dart:convert';
import 'package:flutter/material.dart';
import '../../../data/datasource/remote/http/httpClient.dart';
import '../../../utill/app_constants.dart';

class EventLeadUpdateController with ChangeNotifier {

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _message;
  String? get message => _message;

  Future<bool> updateLead({
    required String leadId,
    required int noOfSeats,
    required String amount,
    required List<Map<String, dynamic>> members,
  }) async {

    _setLoading(true);

    try {

      Map<String, dynamic> data = {
        "lead_id": leadId,
        "no_of_seats": noOfSeats.toString(),
        "amount": amount,
        "member": jsonEncode(members),
      };

      print(" Event Lead Update Data: ${jsonEncode(data)}");

      final res = await HttpService().postApi(
        AppConstants.upDateLeadUrl,
        data,
      );

      if (res != null && res["status"] == 1) {

        _message = res["message"];

        print("Message: $_message");

        _setLoading(false);
        return true;
      }

      _setLoading(false);
      return false;

    } catch (e) {

      print("Error in Update Lead API: $e");
      _setLoading(false);
      return false;

    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}