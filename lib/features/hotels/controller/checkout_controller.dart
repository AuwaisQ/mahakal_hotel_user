import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../data/datasource/remote/http/httpClient.dart';
import '../../../utill/app_constants.dart';
import '../model/check_out_model.dart';
import '../view/hotel_form_page.dart';
import 'hotel_user_controller.dart';

class CheckOutController with ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  CheckOutModel? _checkOutModel;
  CheckOutModel? get checkAvailablityModel => _checkOutModel;

  Future<bool> checkOutFetch(
      BuildContext context, {
        required int serviceId,
        required dynamic grandTotal,
        required String serviceType,
        required DateTime checkInDate,
        required DateTime checkOutDate,
        required int adults,
        required bool isSpace,
        required List<Map<String, dynamic>> bookedRooms,
        required List<Map<String, dynamic>> extraPrices,
        int? children,
      }) async {
    _setLoading(true);
    _error = null;
    notifyListeners();

    final DateFormat _dateFormatter = DateFormat('yyyy-MM-dd');

    Map<String, dynamic> bodyHotel = {
      "service_id": "$serviceId",
      "service_type": "$serviceType",
      "start_date": "${_dateFormatter.format(checkInDate)}",
      "end_date": "${_dateFormatter.format(checkOutDate)}",
      "extra_price": extraPrices,
      "adults": "$adults",
      "children": "$children",
      "rooms": bookedRooms,
    };

    Map<String, dynamic> bodySpace = {
      "service_id": "$serviceId",
      "service_type": "$serviceType",
      "start_date": "${_dateFormatter.format(checkInDate)}",
      "end_date": "${_dateFormatter.format(checkOutDate)}",
      "extra_price": extraPrices,
      "adults": "$adults",
      "children": "$children",
    };

    print("CheckOut Body Hotel: ${bodyHotel}");
    print("CheckOut Body Space: ${bodySpace}");

    try {

      final hotelUserController = Provider.of<HotelUserController>(context, listen: false);
      final token = hotelUserController.hotelUserModel?.data?.token;

      print("Hotel Tken is ${token}");

      if (token == null || token.isEmpty) {
        _error = "Hotel user not logged in";
        print("Hotel User : ${_error}");
        _setLoading(false);
        return false;
      }

      final response = await HttpService().postApi(
        '${AppConstants.hotelAddtoCartUrl}',
       isSpace ? bodySpace : bodyHotel,
        isOtherDomain: true,
        userHotelToken: hotelUserController.hotelUserModel!.data!.token,
      );

      print("Hotel _checkOutModel Res: $response");

      if (response != null) {
        final data = CheckOutModel.fromJson(response);
        _checkOutModel = data;
        _setLoading(false);

        if (_checkOutModel?.status == 1) {
          return true; // Success - rooms are available
        } else {
          return false; // Failed - rooms not available or other error
        }
      } else {
        _error = "No response from server";
        _setLoading(false);
        return false;
      }
    }
    catch (e) {
      _error = "Failed to process checkout: ${e.toString()}";
      _setLoading(false);
      print("Error in _checkOutModel: $e");
      return false;
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}