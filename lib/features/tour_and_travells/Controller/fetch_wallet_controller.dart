import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../../../data/datasource/remote/http/httpClient.dart';
import '../../../main.dart';
import '../../../utill/app_constants.dart';
import '../../profile/controllers/profile_contrroller.dart';

class FetchWalletController with ChangeNotifier {
  double _walletPay = 0.0;
  double get walletPay => _walletPay;

  Future<void> fetchWallet() async {
    String userId =
        Provider.of<ProfileController>(Get.context!, listen: false).userID;
    try {
      var res =
          await HttpService().getApi("${AppConstants.tourWalletUrl}$userId");
      print("Wallet Response $res");
      if (res["success"]) {
        _walletPay = double.parse(res["wallet_balance"].toString());
        notifyListeners();
        print("Wallet Balance Fetched $_walletPay");
      }
    } catch (e) {
      print("Error in Fetching wallet Balance in Tour");
    }
  }
}
