import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../data/datasource/remote/http/httpClient.dart';
import '../../../utill/app_constants.dart';
import '../../profile/controllers/profile_contrroller.dart';
import '../model/check_out_model.dart';
import '../model/form_submission_model.dart';
import '../model/hotel_user_model.dart';
import 'check_order_status_Controller.dart';
import 'checkout_controller.dart';
import 'hotel_user_controller.dart';

class FormSubmissionController with ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  FormSubmissionModel? _formSubmissionModel;
  FormSubmissionModel? get formSubmissionModel => _formSubmissionModel;

  Future<bool> fromSubmissionUser(
      BuildContext context,
      String phone,
      String email,
      String lastName,
      String firstName,
      String addressfirst,
      String city,
      String state,
      String zipCode,
      String country,
      String customerNotes,
      String bookingCode,
      bool isDraft
      ) async {
    _setLoading(true);
    _error = null;

    try {

      final hotelCheckOutController = Provider.of<CheckOutController>(context, listen: false);
      final hotelUserController = Provider.of<HotelUserController>(context, listen: false);

      String? code = isDraft ? bookingCode : hotelCheckOutController.checkAvailablityModel?.bookingCode;

      print("Booking Code:${code}");

      final response = await HttpService().postApi(
        AppConstants.hotelBookUrl,
        {
          "code": code,
          "first_name": firstName,
          "last_name": lastName,
          "email": email,
          "phone": phone,
          "address_line_1": addressfirst,
          "city": city,
          "state": state,
          "zip_code": zipCode,
          "country": country,
          "customer_notes": customerNotes,
          "term_conditions": "on",
          "coupon_code": "",
          "credit": "0"
        },
        isOtherDomain: true,
        userHotelToken: hotelUserController.hotelUserModel!.data!.token,
      );

      if (response != null) {
        _formSubmissionModel = FormSubmissionModel.fromJson(response);
        print("Hotel Order Success:${_formSubmissionModel?.data?.detailUrl}");
        print("Hotel Order Success:${_formSubmissionModel?.data?.status}");
        print("Hotel Order Success:${_formSubmissionModel?.data?.bookingId}");
        return true; //  SUCCESS
      }

      _error = "No response";
      return false;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }


  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}