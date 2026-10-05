import 'package:flutter/material.dart';
import 'package:mahakal/data/datasource/remote/http/httpClient.dart';
import 'package:mahakal/features/parking/model/near_parking_model.dart';
import 'package:mahakal/features/parking/model/parking_details_model.dart';
import 'package:mahakal/features/parking/model/parking_order_model.dart';
import 'package:mahakal/features/parking/model/user_vehicle_model.dart';
import 'package:mahakal/features/parking/model/vehicle_type_model.dart';
import 'package:mahakal/features/profile/controllers/profile_contrroller.dart';
import 'package:mahakal/main.dart';
import 'package:mahakal/utill/app_constants.dart';
import 'package:provider/provider.dart';

class ParkingController extends ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<VehicleType> _vehicleTypeList = [];
  List<VehicleType> get vehicleTypeList => _vehicleTypeList;

  List<UserVehicle> _userVehicleList = [];
  List<UserVehicle> get userVehicleList => _userVehicleList;

  List<NearParking> _nearParkingList = [];
  List<NearParking> get nearParkingList => _nearParkingList;

  ParkingDetails? _parkingDetails;
  ParkingDetails? get parkingDetails => _parkingDetails;

  List<ParkingOrder> _parkingOrderList = [];
  List<ParkingOrder> get parkingOrderList => _parkingOrderList;

  ParkingOrderDetails? _orderDetails;
  ParkingOrderDetails? get orderDetails => _orderDetails;

  Future<void> getParkingOrderList() async {
    _isLoading = true;
    notifyListeners();
    try {
      final profile = Provider.of<ProfileController>(Get.context!, listen: false);
      String userIdStr = profile.userID;

      final Map<String, dynamic> body = {
        'user_id': userIdStr,
      };

      print("Request Body for parking-order-list: $body");
      final response = await HttpService().postApi(AppConstants.parkingOrderListUri, body);
      print("Response for parking-order-list: $response");

      if (response != null && response['status'] == true) {
        ParkingOrderModel model = ParkingOrderModel.fromJson(response);
        _parkingOrderList = model.data ?? [];
        print("Loaded ${_parkingOrderList.length} parking orders");
      }
    } catch (e) {
      debugPrint("Error fetching parking order list: $e");
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> getParkingOrderDetails(int orderId) async {
    _isLoading = true;
    _orderDetails = null;
    notifyListeners();
    try {
      final Map<String, dynamic> body = {
        'order_id': orderId.toString(),
      };

      print("Request Body for parking-order-details: $body");
      final response = await HttpService().postApi(AppConstants.parkingOrderDetailsUri, body);
      print("Response for parking-order-details: $response");

      if (response != null && response['status'] == true) {
        ParkingOrderDetailsModel model = ParkingOrderDetailsModel.fromJson(response);
        _orderDetails = model.data;
      }
    } catch (e) {
      debugPrint("Error fetching parking order details: $e");
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> getVehicleTypeList() async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await HttpService().getApi(AppConstants.vehicleListUri);
      print("Response for vehicle-list (types): $response");
      
      if (response != null && (response['success'] == true || response['status'] == true)) {
        VehicleTypeModel model = VehicleTypeModel.fromJson(response);
        _vehicleTypeList = model.data ?? [];
        print("Loaded ${_vehicleTypeList.length} vehicle types");
      }
    } catch (e) {
      debugPrint("Error fetching vehicle type list: $e");
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> getUserVehicleList() async {
    _isLoading = true;
    notifyListeners();
    try {
      final profile = Provider.of<ProfileController>(Get.context!, listen: false);
      String userIdStr = profile.userID;
      
      // Force refresh user info if not available
      if (userIdStr == "-1" || userIdStr == "null" || userIdStr.isEmpty) {
        print("User ID not available yet. Attempting to fetch user info in ParkingController...");
        await profile.getUserInfo(Get.context!);
        userIdStr = profile.userID;
      }

      print("Fetching vehicle list for User ID: $userIdStr");

      final Map<String, dynamic> body = {
        'user_id': userIdStr,
      };
      
      print("Request Body for user-vehicle-list: $body");
      final response = await HttpService().postApi(AppConstants.userVehicleListUri, body);
      print("Response for user-vehicle-list: $response");

      if (response != null && (response['status'] == true || response['success'] == true)) {
        UserVehicleModel model = UserVehicleModel.fromJson(response);
        _userVehicleList = model.data ?? [];
        print("Loaded ${_userVehicleList.length} user vehicles");
      } else {
        print("Failed to fetch user vehicle list or status/success is false");
      }
    } catch (e) {
      debugPrint("Error fetching user vehicle list: $e");
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> addVehicle({
    required int? vehicleId,
    required String cabName,
    required String cabRegisterNumber,
    required String color,
    required String aadhar,
  }) async {
    _isLoading = true;
    notifyListeners();
    try {
      final profile = Provider.of<ProfileController>(Get.context!, listen: false);
      String userIdStr = profile.userID;
      
      if (userIdStr == "-1" || userIdStr == "null" || userIdStr.isEmpty) {
        await profile.getUserInfo(Get.context!);
        userIdStr = profile.userID;
      }

      String userName = profile.userNAME;
      String userPhone = profile.userPHONE;

      final Map<String, dynamic> body = {
        'user_id': int.tryParse(userIdStr) ?? userIdStr,
        'cab_name': cabName,
        'vehicle_id': vehicleId,
        'cab_register_number': cabRegisterNumber,
        'color': color,
        'user_name': userName,
        'user_phone': userPhone,
        'aadhar': aadhar,
      };
      
      print("Request Body for user-vehicle-add: $body");
      final response = await HttpService().postApi(AppConstants.addVehicleUri, body);
      print("Response for user-vehicle-add: $response");

      if (response != null && (response['status'] == true || response['success'] == true)) {
        await getUserVehicleList(); // Refresh list
        return true;
      }
    } catch (e) {
      debugPrint("Error adding vehicle: $e");
    }
    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<void> getNearParkingList({
    required String lat,
    required String long,
    int? vehicleId,
  }) async {
    _isLoading = true;
    notifyListeners();
    try {
      final Map<String, dynamic> body = {
        'lat': lat,
        'long': long,
        'vehicle_id': vehicleId,
      };
      
      print("Request Body for get-all-near-parking: $body");
      final response = await HttpService().postApi(AppConstants.nearParkingUri, body);
      print("Response for get-all-near-parking: $response");

      if (response != null && response['status'] == true) {
        NearParkingModel model = NearParkingModel.fromJson(response);
        _nearParkingList = model.data ?? [];
        print("Loaded ${_nearParkingList.length} near parking locations");
      } else {
        print("Failed to fetch near parking list or status is false");
        _nearParkingList = [];
      }
    } catch (e) {
      debugPrint("Error fetching near parking list: $e");
      _nearParkingList = [];
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> getParkingDetails({
    required int addressId,
    required int vehicleId,
  }) async {
    _isLoading = true;
    _parkingDetails = null; // Clear previous details
    notifyListeners();
    try {
      final Map<String, dynamic> body = {
        'address_id': addressId,
        'vehicle_id': vehicleId,
      };
      
      print("Request Body for parking-details: $body");
      final response = await HttpService().postApi(AppConstants.parkingDetailsUri, body);
      print("Response for parking-details: $response");

      if (response != null && response['success'] == true) {
        ParkingDetailsModel model = ParkingDetailsModel.fromJson(response);
        _parkingDetails = model.data;
        print("Loaded parking details for: ${_parkingDetails?.parkingNameEn}");
      } else {
        print("Failed to fetch parking details");
      }
    } catch (e) {
      debugPrint("Error fetching parking details: $e");
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<int?> createParkingLead({
    required int addressId,
    required int vehicleId,
    required String cabName,
    required String cabRegisterNumber,
    required String color,
    required String aadhar,
    required String pickupDateTime,
    required String dropDateTime,
    required int totalHours,
    required double totalAmount,
  }) async {
    _isLoading = true;
    notifyListeners();
    try {
      final profile = Provider.of<ProfileController>(Get.context!, listen: false);
      String userIdStr = profile.userID;
      
      final Map<String, dynamic> body = {
        'user_id': userIdStr,
        'address_id': addressId.toString(),
        'vehicle_id': vehicleId.toString(),
        'cab_name': cabName,
        'cab_register_number': cabRegisterNumber,
        'color': color,
        'user_name': profile.userNAME,
        'user_phone': profile.userPHONE,
        'aadhar': aadhar,
        'pickup_date_time': pickupDateTime,
        'drop_date_time': dropDateTime,
        'total_hours': totalHours.toString(),
        'total_amount': totalAmount.toString(),
      };
      
      print("Request Body for parking-lead-create: $body");
      final response = await HttpService().postApi(AppConstants.createParkingLeadUri, body);
      print("Response for parking-lead-create: $response");

      if (response != null && (response['status'] == true || response['success'] == true)) {
        _isLoading = false;
        notifyListeners();
        
        // Handle different response formats for lead ID
        if (response['lead_id'] != null) {
          return int.tryParse(response['lead_id'].toString());
        } else if (response['data'] is int) {
          return response['data'];
        } else if (response['data'] is Map && response['data']['id'] != null) {
          return int.tryParse(response['data']['id'].toString());
        }
        
        // If status is true but we can't find an ID, return a default or log error
        debugPrint("Parking lead created but ID not found in response: $response");
        return null;
      }
    } catch (e) {
      debugPrint("Error creating parking lead: $e");
    }
    _isLoading = false;
    notifyListeners();
    return null;
  }

  Future<bool> parkingBookingSuccess({
    required int leadId,
    required double onlineAmount,
    required String transactionId,
  }) async {
    _isLoading = true;
    notifyListeners();
    try {
      final Map<String, dynamic> body = {
        'lead_id': leadId,
        'online_amount': onlineAmount,
        'wallet_type': 0,
        'payment_mode': 'online',
        'transaction_id': transactionId,
      };
      
      print("Request Body for parking-booking-success: $body");
      final response = await HttpService().postApi(AppConstants.parkingBookingSuccessUri, body);
      print("Response for parking-booking-success: $response");

      if (response != null && (response['status'] == true || response['success'] == true)) {
        _isLoading = false;
        notifyListeners();
        return true;
      }
    } catch (e) {
      debugPrint("Error updating booking success: $e");
    }
    _isLoading = false;
    notifyListeners();
    return false;
  }
}
