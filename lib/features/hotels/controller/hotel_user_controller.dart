import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../data/datasource/remote/http/httpClient.dart';
import '../../../utill/app_constants.dart';
import '../../profile/controllers/profile_contrroller.dart';
import '../model/hotel_user_model.dart';

class HotelUserController with ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  HotelUserModel? _hotelUserModel;
  HotelUserModel? get hotelUserModel => _hotelUserModel;

  static const String _hotelUserTokenKey = 'hotel_user_token';
  static const String _hotelUserDataKey = 'hotel_user_data';

  /// ================= INIT =================
  Future<void> initHotelUser(BuildContext context) async {
    print("=== INIT HOTEL USER ===");

    await _loadStoredHotelUserData();

    //  If token exists → use it
    if (_hotelUserModel != null &&
        _hotelUserModel?.data?.token != null &&
        _hotelUserModel!.data!.token!.isNotEmpty) {
      print("Using Stored Token: ${_hotelUserModel!.data!.token}");
      return;
    }

    //  No token → login API call
    print("No stored token found → Calling API");
    await loginHotelUser(context);
  }

  /// ================= LOGIN =================
  Future<void> loginHotelUser(BuildContext context) async {
    print("=== LOGIN HOTEL USER ===");

    _setLoading(true);

    final profileController = Provider.of<ProfileController>(context, listen: false);

    Map<String, dynamic> body = {
      "first_name": profileController.userNAME.split(" ").first,
      "last_name": profileController.userNAME.split(" ").length > 1
          ? profileController.userNAME.split(" ").last
          : "",
      "email": profileController.userEMAIL,
      "password": profileController.sipPass,
      "phone": profileController.userPHONE,
    };

    try {
      final response = await HttpService().postApi(
        AppConstants.hotelUserUrl,
        body,
        isOtherDomain: true,
      );

      if (response != null) {
        _hotelUserModel = HotelUserModel.fromJson(response);
        print(" New Token From API: ${_hotelUserModel?.data?.token}");
        await _storeHotelUserData(_hotelUserModel!);
      }
    } catch (e) {
      print("Login Error: $e");
    }

    _setLoading(false);
  }

  /// ================= STORE =================
  Future<void> _storeHotelUserData(HotelUserModel model) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(_hotelUserTokenKey, model.data?.token ?? '');
    await prefs.setString(
      _hotelUserDataKey,
      jsonEncode(model.toJson()),
    );

    print("Token Stored Successfully");
  }

  /// ================= LOAD =================
  Future<void> _loadStoredHotelUserData() async {
    final prefs = await SharedPreferences.getInstance();

    final storedUserData = prefs.getString(_hotelUserDataKey);

    if (storedUserData != null && storedUserData.isNotEmpty) {
      final jsonData = jsonDecode(storedUserData);
      _hotelUserModel = HotelUserModel.fromJson(jsonData);

      print("Loaded Stored Token: ${_hotelUserModel?.data?.token}");
    } else {
      print("No Stored User Found");
    }
  }

  /// ================= CLEAR (CALL ON LOGOUT) =================
  Future<void> clearHotelUserData() async {
    print("=== CLEAR HOTEL USER ===");

    final prefs = await SharedPreferences.getInstance();

    await prefs.remove(_hotelUserTokenKey);
    await prefs.remove(_hotelUserDataKey);

    _hotelUserModel = null;

    print("Token Cleared Successfully");

    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}