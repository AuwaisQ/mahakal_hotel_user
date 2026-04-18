import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/datasource/remote/http/httpClient.dart';
import '../../../main.dart';
import '../../../utill/app_constants.dart';
import '../../../utill/completed_order_dialog.dart';
import '../../custom_bottom_bar/bottomBar.dart';
import '../../profile/controllers/profile_contrroller.dart';
import '../model/success_amount_model.dart';

class SuccessTourAmountController with ChangeNotifier {
  SuccessAmountModel? successAmountModel;

  Future<void> successTourAmount({
    required String tourId,
    required String packageId,
    required String paymentAmount,
    required String qty,
    required String pickupAddress,
    required String pickupDate,
    required String pickupTime,
    required String pickupLat,
    required String pickupLong,
    required String useDate,
    required String transactionId,
    required List<dynamic> bookingPackage,
    required String walletType,
    required String onlinePay,
    required String couponAmount,
    required String couponId,
    required String leadId,
    required BuildContext context,
    required String partPayment,
  }) async {
    print("Success Tour Contoller Opened");
    Map<String, dynamic> data = {
      "user_id":
          Provider.of<ProfileController>(Get.context!, listen: false).userID,
      "tour_id": tourId,
      "leads_id": leadId,
      "package_id": packageId,
      "payment_amount": paymentAmount,
      "qty": 1,
      "pickup_address": pickupAddress,
      "pickup_date": pickupDate,
      "pickup_time": pickupTime,
      "pickup_lat": pickupLat,
      "pickup_long": pickupLong,
      "use_date": useDate,
      "transaction_id": transactionId,
      "booking_package": bookingPackage,
      "wallet_type": walletType,
      "online_pay": onlinePay,
      "coupon_amount": couponAmount,
      "coupon_id": couponId,
      "part_payment": partPayment
    };

    print("Success Tour Data: $data");

    try {
      final res =
          await HttpService().postApi(AppConstants.successTourAmount, data);
      if (res != null) {
        successAmountModel = SuccessAmountModel.fromJson(res);
        notifyListeners();
        Navigator.of(context).pushReplacement(CupertinoPageRoute(builder: (BuildContext context) => const BottomBar(pageIndex: 0)));
        showDialog(
          context: context,
          builder: (context) => bookingSuccessDialog(
            context: context,
            tabIndex: 6,
            title: 'Tour Booked!',
            message: 'If you want to open the order page then click OPEN.',
          ),
          barrierDismissible: true,
        );
        print("Success Payment Response: $res");
      }
    } catch (e) {
      print("Tour Payment Error: $e");
    }
  }
}
