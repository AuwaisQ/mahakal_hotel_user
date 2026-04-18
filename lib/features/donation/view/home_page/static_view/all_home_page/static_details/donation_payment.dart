import 'dart:convert';
import 'dart:math';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../../../../../data/datasource/remote/http/httpClient.dart';
import '../../../../../../../main.dart';
import '../../../../../../../utill/app_constants.dart';
import '../../../../../../../utill/completed_order_dialog.dart';
import '../../../../../../../utill/razorpay_screen.dart';
import '../../../../../../blogs_module/no_image_widget.dart';
import '../../../../../../custom_bottom_bar/bottomBar.dart';
import '../../../../../../explore/payment_process_screen.dart';
import '../../../../../../profile/controllers/profile_contrroller.dart';
import '../../../../../../tour_and_travells/Controller/fetch_wallet_controller.dart';
import '../../../../../../wallet/controllers/wallet_controller.dart';
import '../../../../../../youtube_vedios/view/dynamic_tabview/grid_view/YoutubeGridView.dart';
import '../../../../../model/donation_update_lead_model.dart';
import '../../../../../model/donationpage_model.dart';
import '../../../../../model/lead_details_model.dart';
import '../../../../../model/success_amount.dart'; // Import Razorpay

class DonationPayment extends StatefulWidget {
  final String engname;
  final String hinname;
  final String image;
  final String setAmount;
  final String myId;
  final String donationType;
  final String userId;
  final String userPhone;
  final String userName;
  final String userEmail;
  final String setTitle;
  final String setUnit;
  final String setNumber;
  final int autoPayStaus;
  final List<ProductList> productList;

  const DonationPayment(
      {super.key,
      required this.engname,
      required this.hinname,
      required this.image,
      required this.setAmount,
      required this.myId,
      required this.userId,
      required this.userPhone,
      required this.userName,
      required this.userEmail,
      required this.donationType,
      required this.setTitle,
      required this.setUnit,
      required this.setNumber,
      required this.autoPayStaus,
      required this.productList});

  @override
  _DonationPaymentState createState() => _DonationPaymentState();
}

enum PanVerifyState { idle, verifying, success, failed }

class _DonationPaymentState extends State<DonationPayment>
    with SingleTickerProviderStateMixin {
  PanVerifyState _panState = PanVerifyState.idle;

  final TextEditingController _panCardController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _customAmountController = TextEditingController();
  // final walletController = Provider.of<FetchWalletController>(Get.context!, listen: false);
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final razorpayService = RazorpayPaymentService();
  final FocusNode _amountFocusNode = FocusNode();

  bool _isEditingPan = false;
  bool _isLoading = false;
  bool circularIndicator = false;
  bool isCustomAmount = false;
  bool isWalletApplied = false;
  bool gettingData = true;
  bool _isGridView = true;

  String _selectedAmount = '101';
  final List<String> _amounts = [
    '101',
    "151",
    '501',
    '551',
    '5001',
    '11000',
    '21000',
    '51000',
    '151000',
  ];
  final List<String> frequencies = [
    'One Time',
    'Weekly',
    'Monthly',
    'Quarterly',
    'Yearly',
  ];
  final List<String> frequencyKeys = [
    'one_time',
    'weekly',
    'monthly',
    'quarterly',
    'yearly',
  ];

  double totalPackagePrice = 0.0;
  List<int> counts = [];
  List<Map<String, dynamic>> productAdded = [];

  int selectedIndex = 2;
  double walletPay = 0;
  double remainDonateAmount = 0;
  double increasedAmount = 101;

  int? naviGateRazorpay;
  int? successAmountStatus;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    print("My Id: ${widget.myId}");

    counts = List<int>.filled(widget.productList.length, 0);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        // Access providers safely after the widget is built
        final profileController =
            Provider.of<ProfileController>(context, listen: false);
        final walletController =
            Provider.of<FetchWalletController>(context, listen: false);

        // Fetch wallet data
        await walletController.fetchWallet();

        // Assign values to controllers
        _phoneController.text = profileController.userPHONE;
        _nameController.text = profileController.userNAME;

        // Update walletPay
        setState(() {
          walletPay = walletController.walletPay;
          gettingData = false; // ✅ Data loaded successfully
        });

        print("✅ Wallet Amount: $walletPay");
        print("✅ User Name: ${profileController.userNAME}");
        print("✅ User Phone: ${profileController.userPHONE}");

        // Fetch lead details
        getLeadDetails();
      } catch (e) {
        print("⚠️ Error loading data: $e");
        setState(() {
          gettingData = false; // stop loader even on error
        });
      }
    });

    // Listener for custom amount input
    _customAmountController.addListener(() {
      final text = _customAmountController.text;
      if (text.isEmpty) return;

      final value = double.tryParse(text);
      if (value == null || value <= 0) {
        _customAmountController.clear();
      }
    });

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.95, end: 1).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutBack,
      ),
    );

    _animationController.forward();
  }

  SuccessAmount? successAmount;
  LeadDetailsModel? leadDetails;
  DonationUpdateLeadModel? leadUpateDetails;
  double? amountAfterWallet;
  double? walletDeducatedAmount;

  void addOrUpdateItem(int index) {
    final item = widget.productList[index];
    if (item == null) return;

    int quantity = counts[index];
    int price = int.tryParse(item.setAmount ?? '0') ?? 0;

    // Find item in selected list
    int selIndex =
        productAdded.indexWhere((e) => e['id'] == item.id.toString());

    if (selIndex >= 0) {
      if (quantity == 0) {
        // remove item
        productAdded.removeAt(selIndex);
      } else {
        // update item (RECALCULATE, not add)
        productAdded[selIndex]['qty'] = quantity;
        productAdded[selIndex]['fullamount'] = quantity * price;
      }
    } else {
      if (quantity > 0) {
        // add new item
        productAdded.add({
          'id': item.id.toString(),
          'title': item.enSetTitle,
          'subtitle': item.enSetTitle,
          'amount': price,
          'qty': quantity,
          'fullamount': quantity * price,
        });
      }
    }

    // Recalculate grand total from scratch
    totalPackagePrice = productAdded.fold(
      0,
      (sum, e) => sum + (e['fullamount'] as int),
    );

    print("Selected Items:");
    for (var i in productAdded) {
      print("${i['title']} | Qty: ${i['qty']} | Total: ${i['fullamount']}");
    }

    print("Grand Total: $totalPackagePrice");
  }

  void applywallet() {
    double donationAmount;

    // Handle custom amount input safely
    if (isCustomAmount) {
      String customText = _customAmountController.text.trim();

      if (customText.isEmpty) {
        print("Custom amount is empty");
        return;
      }

      try {
        donationAmount = double.parse(customText) + totalPackagePrice;
      } catch (e) {
        print("Invalid custom amount entered: $customText");
        return;
      }
    } else {
      donationAmount = increasedAmount + totalPackagePrice;
    }

    double walletBalance = walletPay;

    // Validate amount
    if (donationAmount <= 0) {
      print("Invalid donation amount: $donationAmount");
      return;
    }

    // Calculate amount after wallet deduction
    amountAfterWallet = max(walletBalance - donationAmount, 0);

    walletDeducatedAmount = walletPay - amountAfterWallet!;

    // Calculate remaining donation amount
    if (walletBalance >= donationAmount) {
      remainDonateAmount = 0;
    } else {
      remainDonateAmount = donationAmount - walletBalance;
    }

    print("Total Donation: $donationAmount, Wallet Balance: $walletBalance");
    print(
        "Amount After Wallet: $amountAfterWallet, Remaining Donation Amount: $remainDonateAmount");

    // Set payment method status
    if (isWalletApplied && walletPay >= donationAmount) {
      successAmountStatus = 1;
      naviGateRazorpay = 1;
    } else if (isWalletApplied && walletPay > 0 && walletPay < donationAmount) {
      successAmountStatus = 1;
      naviGateRazorpay = 2;
    } else {
      successAmountStatus = 0;
      naviGateRazorpay = 3;
    }
  }

  Future<void> getLeadDetails() async {
    print("user id: ${widget.userId}");
    print("type: ${widget.donationType}");
    print("amount: ${widget.setAmount}");
    print("id: ${widget.myId}");
    print("user name: ${widget.userName}");
    print("user phone: ${widget.userPhone}");

    final Map<String, dynamic> data = {
      "user_id": widget.userId,
      "type": widget.donationType,
      "amount": widget.setAmount.isEmpty ? 0 : widget.setAmount,
      "id": widget.myId,
      "name": widget.userName,
      "phone": widget.userPhone,
    };

    setState(() {
      _isLoading = true;
    });

    try {
      // Use the new HttpService to make the POST request
      final res =
          await HttpService().postApi("${AppConstants.donationLeadUrl}", data);

      print("Lead Data: $res");

      if (res.containsKey('status') &&
          res.containsKey('message') &&
          res.containsKey('data')) {
        final leadDetailsModel = LeadDetailsModel.fromJson(res);

        setState(() {
          leadDetails = leadDetailsModel;
          print("Lead ID: ${leadDetails?.data?.id}");
        });
      } else {
        print("Error in Single Ads Data: Invalid response structure");
      }
    } catch (e) {
      print("Error in Lead Data: $e");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> updateLeadDetails() async {
    print("user id: ${widget.userId}");
    print("type: ${widget.donationType}");
    print("frequencuy: ${frequencyKeys[selectedIndex]}");
    print("amount: ${widget.setAmount}");
    print("id: ${widget.myId}");
    print("user name: ${widget.userName}");
    print("user phone: ${widget.userPhone}");

    final Map<String, dynamic> data = {
      "id": "${leadDetails?.data?.id}",
      "frequency": "${frequencyKeys[selectedIndex]}",
      "amount":
          "${isCustomAmount ? _customAmountController.text : increasedAmount}",
      "user_name": "${_nameController.text}",
      "user_phone": "${_phoneController.text}",
      "pan_card:   ": "${_panCardController.text}"
    };

    setState(() {
      _isLoading = true;
    });

    try {
      // Use the new HttpService to make the POST request
      final res = await HttpService()
          .postApi("${AppConstants.donationLeadUpdateUrl}", data);

      print("Lead Update Data: $res");

      if (res.containsKey('status') &&
          res.containsKey('message') &&
          res.containsKey('data')) {
        final leadDetailsModel = DonationUpdateLeadModel.fromJson(res);

        setState(() {
          leadUpateDetails = leadDetailsModel;
          print("Subscription Id : ${leadUpateDetails?.data?.subscriptionId}");
        });
        showPaymentDialog(context);
      } else {
        print("Error in Lead Upate");
      }
    } catch (e) {
      print("Error in Lead Data: $e");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void showLoadingDialog(BuildContext context) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: const Row(
          children: [
            // Orange Circular Loader
            CircularProgressIndicator(
              color: Colors.orange,
              strokeWidth: 3,
            ),
            SizedBox(width: 20),
            // Text Section
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Please wait...",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    "Processing your booking...",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> getSuccessDetails(String transactionId) async {
    print("--------- DONATION SUCCESS METHOD ---------");
    print("Products Added: $productAdded");
    print("Transaction ID: $transactionId");
    print("Increased Amount: $increasedAmount");
    print("Wallet Type Status: $successAmountStatus");
    print("Online Pay Remaining: $remainDonateAmount");
    print("Lead ID: ${leadDetails?.data?.id}");

    /// ----- Calculate final amount -----
    double customAmount =
        double.tryParse(_customAmountController.text.trim()) ?? 0;
    double baseAmount = isCustomAmount ? customAmount : increasedAmount;
    double finalTotalAmount = baseAmount + totalPackagePrice;

    double onlinePayAmount = isWalletApplied
        ? remainDonateAmount
        : (isCustomAmount
                ? double.tryParse(_customAmountController.text.trim()) ?? 0
                : increasedAmount) +
            totalPackagePrice;

    print("Final Amount To Pay: $onlinePayAmount");
    print("Final Total Amount: $finalTotalAmount");

    /// ----- Prepare Request Body -----
    Map<String, dynamic> data = {
      "id": leadDetails?.data?.id,
      "amount": finalTotalAmount,
      "transaction_id": transactionId,
      "payment_method": successAmountStatus == 0 ? "razor_pay" : "wallet",
      "wallet_type": successAmountStatus,
      "online_pay": onlinePayAmount,
      "pan_card": _panCardController.text.trim(),
      "user_name": _nameController.text.trim(),
      "user_phone": _phoneController.text.trim(),
      "information":
          jsonEncode(productAdded), // Enable this when backend supports it
    };

    print("REQUEST BODY => $data");

    setState(() => _isLoading = true);

    try {
      final res = await HttpService().postApi(AppConstants.donationAmountSuccessUrl, data);

      print("API RESPONSE => $res");

      if (res["status"] != null &&
          res["message"] != null &&
          res["data"] != null) {
        final successAmountModel = SuccessAmount.fromJson(res);

        setState(() {
          successAmount = successAmountModel;
        });

        print("SUCCESS MESSAGE => ${successAmount?.message}");

        /// Navigate to Home
        Navigator.of(context).pushReplacement(
          CupertinoPageRoute(builder: (_) => const BottomBar(pageIndex: 0)),
        );

        /// Show success dialog
        showDialog(
          context: context,
          barrierDismissible: true,
          builder: (dialogContext) => bookingSuccessDialog(
            context: dialogContext, //  CORRECT
            tabIndex: 8,
            title: 'Donation Successful!',
            message: 'If you want to open the order page then click OPEN.',
          ),
        );
      } else {
        print("ERROR: Unexpected API response format.");
      }
    } catch (e, s) {
      print("EXCEPTION: $e");
      print("STACKTRACE: $s");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  showToast(String msg) {
    Fluttertoast.showToast(
      msg: msg,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.TOP,
      timeInSecForIosWeb: 20,
      backgroundColor: Colors.black54,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }

  void showPaymentDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            "Confirm Payment",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          content: const Text(
            "Are you sure you want to proceed with the payment?",
            style: TextStyle(fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.grey[700],
              ),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop(); // Close the confirmation dialog

                final amount = isWalletApplied
                    ? remainDonateAmount
                    : (isCustomAmount
                            ? double.tryParse(
                                    _customAmountController.text.trim()) ??
                                0
                            : increasedAmount) +
                        totalPackagePrice;

                // (isCustomAmount
                //         ? double.parse(_customAmountController.text.trim())
                //         : increasedAmount);

                // ✅ Check Razorpay condition before proceeding
                if (naviGateRazorpay == 2 || naviGateRazorpay == 3) {
                  //  Proceed with Razorpay payment
                  razorpayService.openCheckout(
                    amount: amount,
                    subscriptionId: "${leadUpateDetails!.data!.subscriptionId}",
                    isSubscription: "${leadUpateDetails!.status}",
                    razorpayKey: AppConstants.razorpayLive,
                    onSuccess: (resp) {
                      setState(() => circularIndicator = true);
                      getSuccessDetails(resp.paymentId!);
                    },
                    onFailure: (_) => setState(() => circularIndicator = false),
                    onExternalWallet: (resp) =>
                        print("Wallet: ${resp.walletName}"),
                    description: 'Donation',
                  );
                } else if (naviGateRazorpay == 1) {
                  // 🔸 Show wallet payment dialog
                  showLoadingDialog(context); // Show loading dialog
                  await getSuccessDetails(
                      "wallet"); // Wait for API or function to complete
                } else {
                  // 🔸 Fallback (if no matching condition)
                  //showToastMessage("Invalid payment option selected");
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text("Confirm Payment"),
            ),
          ],
        );
      },
    );
  }

  Future<bool> _showExitDialog(BuildContext context) async {
    return await showCupertinoDialog(
          context: context,
          builder: (context) => CupertinoAlertDialog(
            title: const Text("Confirm Exit"),
            content: const Text("Are you sure you want to go back?"),
            actions: [
              CupertinoDialogAction(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text("Cancel"),
              ),
              CupertinoDialogAction(
                onPressed: () => Navigator.of(context).pop(true),
                isDestructiveAction: true, // Red color for emphasis
                child: const Text("Yes"),
              ),
            ],
          ),
        ) ??
        false;
  }

  @override
  void dispose() {
    _panCardController.dispose();
    _customAmountController.dispose();
    _animationController.dispose();
    _amountFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    applywallet();
    return gettingData
        ? Scaffold(
            backgroundColor: Colors.white,
            body: const Center(
              child: CircularProgressIndicator(
                color: Colors.deepOrange,
                strokeWidth: 3,
              ),
            ),
          )
        : circularIndicator
            ? const MahakalPaymentProcessing()
            : GestureDetector(
                onTap: () {
                  _amountFocusNode.unfocus();
                },
                child: Scaffold(
                  backgroundColor: Colors.grey[50],
                  appBar: _buildAppBar(theme),
                  body: ScaleTransition(
                    scale: _scaleAnimation,
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                height: 15,
                              ),

                              widget.productList.isNotEmpty
                                  ? Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [

                                        // Grid View (when _isGridView is true)
                                        _isGridView
                                            ? GridView.builder(
                                                gridDelegate:
                                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                                  crossAxisCount: 2,
                                                  crossAxisSpacing: 10,
                                                  mainAxisSpacing: 10,
                                                  childAspectRatio: 0.76,
                                                ),
                                                itemCount: widget.productList.length,
                                                physics: const NeverScrollableScrollPhysics(),
                                                shrinkWrap: true,
                                                padding: EdgeInsets.zero,
                                                itemBuilder: (context, index) {
                                                  final item =
                                                      widget.productList[index];
                                                  if (item == null)
                                                    return const SizedBox();

                                                  return Container(
                                                      decoration: BoxDecoration(
                                                        color: Colors.white,
                                                        borderRadius: BorderRadius.circular(20),
                                                        boxShadow: [
                                                          BoxShadow(
                                                            color: Colors.grey.withOpacity(0.15),
                                                            blurRadius: 20,
                                                            offset: const Offset(0, 8),
                                                          ),
                                                        ],
                                                        border: Border.all(
                                                          color: counts[index] > 0
                                                              ? Colors.green.withOpacity(0.3)
                                                              : Colors.orange.withOpacity(0.3),
                                                          width: 1,
                                                        ),
                                                      ),
                                                      child: Column(
                                                        children: [
                                                          // Image Section with Gradient Overlay
                                                          Stack(
                                                            children: [
                                                              ClipRRect(
                                                                borderRadius: const BorderRadius.only(
                                                                  topLeft: Radius.circular(20),
                                                                  topRight: Radius.circular(20),
                                                                ),
                                                                child: CachedNetworkImage(
                                                                  imageUrl: item.image ?? '',
                                                                  width: double.infinity,
                                                                  height: 100,
                                                                  fit: BoxFit.fill,
                                                                  placeholder: (context, url) => Container(
                                                                    height: 100,
                                                                    decoration: BoxDecoration(
                                                                      gradient: LinearGradient(
                                                                        begin: Alignment.topLeft,
                                                                        end: Alignment.bottomRight,
                                                                        colors: [
                                                                          Colors.grey[200]!,
                                                                          Colors.grey[100]!,
                                                                        ],
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  errorWidget: (context, url, error) => Container(
                                                                    height: 100,
                                                                    decoration: BoxDecoration(
                                                                      gradient: LinearGradient(
                                                                        begin: Alignment.topLeft,
                                                                        end: Alignment.bottomRight,
                                                                        colors: [
                                                                          Colors.grey[200]!,
                                                                          Colors.grey[100]!,
                                                                        ],
                                                                      ),
                                                                    ),
                                                                    child: const Center(
                                                                      child: Icon(
                                                                        Icons.image_search,
                                                                        color: Colors.grey,
                                                                        size: 40,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),

                                                              // Gradient Overlay
                                                              Container(
                                                                height: 100,
                                                                decoration: BoxDecoration(
                                                                  borderRadius: const BorderRadius.only(
                                                                    topLeft: Radius.circular(20),
                                                                    topRight: Radius.circular(20),
                                                                  ),
                                                                  gradient: LinearGradient(
                                                                    begin: Alignment.bottomCenter,
                                                                    end: Alignment.topCenter,
                                                                    colors: [
                                                                      Colors.black.withOpacity(0.3),
                                                                      Colors.transparent,
                                                                    ],
                                                                  ),
                                                                ),
                                                              ),

                                                              // Quantity Badge (if added)
                                                              if (counts[index] > 0)
                                                              Positioned(
                                                                  top: 12,
                                                                  left: 12,
                                                                  child: Container(
                                                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                                                    decoration: BoxDecoration(
                                                                      color: Colors.green,
                                                                      borderRadius: BorderRadius.circular(12),
                                                                      boxShadow: [
                                                                        BoxShadow(
                                                                          color: Colors.green.withOpacity(0.3),
                                                                          blurRadius: 6,
                                                                          offset: const Offset(0, 3),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                    child: Text(
                                                                      "${counts[index]}",
                                                                      style: const TextStyle(
                                                                        fontSize: 12,
                                                                        fontWeight: FontWeight.bold,
                                                                        color: Colors.white,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),

                                                              Positioned(
                                                                bottom: 8,
                                                                left: 10,
                                                                child: Text(
                                                                  item.enSetTitle ?? '',
                                                                  style: const TextStyle(
                                                                    fontSize: 15,
                                                                    fontWeight: FontWeight.w700,
                                                                    color: Colors.white,
                                                                    height: 1.3,
                                                                  ),
                                                                  maxLines: 1,
                                                                  overflow: TextOverflow.ellipsis,
                                                                ),
                                                              ),

                                                            ],
                                                          ),

                                                          // Product Details
                                                          Expanded(
                                                            child: Padding(
                                                              padding: const EdgeInsets.all(10),
                                                              child: Column(
                                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                children: [

                                                                  // Package Info
                                                                  Row(
                                                                    children: [
                                                                      Icon(
                                                                        Icons.inventory_2,
                                                                        size: 14,
                                                                        color: Colors.grey[600],
                                                                      ),
                                                                      const SizedBox(width: 4),
                                                                      Expanded(
                                                                        child: Text(
                                                                          "${item.setNumber} ${item.setUnit}",
                                                                          style: TextStyle(
                                                                            fontSize: 12,
                                                                            color: Colors.grey[600],
                                                                            fontWeight: FontWeight.w500,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),

                                                                  Container(
                                                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                                      decoration: BoxDecoration(
                                                                        color: Colors.green.shade50,
                                                                        borderRadius: BorderRadius.circular(6),
                                                                        border: Border.all(color: Colors.green.shade100),
                                                                      ),
                                                                      child: Row(
                                                                        mainAxisSize: MainAxisSize.min,
                                                                        children: [
                                                                          Text(
                                                                            "Total: ",
                                                                            style: TextStyle(
                                                                              fontSize: 11,
                                                                              color: Colors.grey[700],
                                                                            ),
                                                                          ),
                                                                          Text(
                                                                            "₹${counts[index] * int.parse(item.setAmount ?? '0')}",
                                                                            style: const TextStyle(
                                                                              fontSize: 13,
                                                                              fontWeight: FontWeight.bold,
                                                                              color: Colors.green,
                                                                            ),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    ),

                                                                  // Add/Remove Button
                                                                  counts[index] == 0
                                                                      ? Container(
                                                                    height: 35,
                                                                    decoration: BoxDecoration(
                                                                      gradient: LinearGradient(
                                                                        colors: [
                                                                          Colors.orange.shade500,
                                                                          Colors.orange.shade700,
                                                                        ],
                                                                        begin: Alignment.topLeft,
                                                                        end: Alignment.bottomRight,
                                                                      ),
                                                                      borderRadius: BorderRadius.circular(10),
                                                                      boxShadow: [
                                                                        BoxShadow(
                                                                          color: Colors.orange.withOpacity(0.3),
                                                                          blurRadius: 8,
                                                                          offset: const Offset(0, 4),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                    child: Material(
                                                                      color: Colors.transparent,
                                                                      child: InkWell(
                                                                        onTap: () {
                                                                          setState(() {
                                                                            counts[index] = 1;
                                                                            addOrUpdateItem(index);
                                                                          });
                                                                        },
                                                                        borderRadius: BorderRadius.circular(10),
                                                                        child: Center(
                                                                          child: Row(
                                                                            mainAxisAlignment: MainAxisAlignment.center,
                                                                            children: [
                                                                              const Icon(
                                                                                Icons.add_circle_outline,
                                                                                color: Colors.white,
                                                                                size: 18,
                                                                              ),
                                                                              const SizedBox(width: 6),
                                                                              const Text(
                                                                                "Add to Donate",
                                                                                style: TextStyle(
                                                                                  color: Colors.white,
                                                                                  fontWeight: FontWeight.w600,
                                                                                  fontSize: 13,
                                                                                ),
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  )
                                                                      : Container(
                                                                    height: 35,
                                                                    decoration: BoxDecoration(
                                                                      color: Colors.white,
                                                                      borderRadius: BorderRadius.circular(10),
                                                                      border: Border.all(
                                                                        color: Colors.green,
                                                                        width: 1,
                                                                      ),
                                                                      boxShadow: [
                                                                        BoxShadow(
                                                                          color: Colors.green.withOpacity(0.1),
                                                                          blurRadius: 6,
                                                                          offset: const Offset(0, 3),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                    child: Row(
                                                                      children: [
                                                                        // Minus Button
                                                                        Expanded(
                                                                          child: InkWell(
                                                                            onTap: () {
                                                                              setState(() {
                                                                                if (counts[index] > 0) counts[index]--;
                                                                                addOrUpdateItem(index);
                                                                              });
                                                                            },
                                                                            borderRadius: const BorderRadius.only(
                                                                              topLeft: Radius.circular(10),
                                                                              bottomLeft: Radius.circular(10),
                                                                            ),
                                                                            child: Container(
                                                                              decoration: BoxDecoration(
                                                                                color: Colors.green.shade50,
                                                                                borderRadius: const BorderRadius.only(
                                                                                  topLeft: Radius.circular(10),
                                                                                  bottomLeft: Radius.circular(10),
                                                                                ),
                                                                              ),
                                                                              child: const Center(
                                                                                child: Icon(
                                                                                  Icons.remove,
                                                                                  color: Colors.black,
                                                                                  size: 22,
                                                                                ),
                                                                              ),
                                                                            ),
                                                                          ),
                                                                        ),

                                                                        // Quantity Display
                                                                        Expanded(
                                                                          child: Container(
                                                                            color: Colors.green.shade50,
                                                                            child: Center(
                                                                              child: Text(
                                                                                "${counts[index]}",
                                                                                style: const TextStyle(
                                                                                  fontSize: 16,
                                                                                  fontWeight: FontWeight.bold,
                                                                                  color: Colors.green,
                                                                                ),
                                                                              ),
                                                                            ),
                                                                          ),
                                                                        ),

                                                                        // Plus Button
                                                                        Expanded(
                                                                          child: InkWell(
                                                                            onTap: () {
                                                                              setState(() {
                                                                                counts[index]++;
                                                                                addOrUpdateItem(index);
                                                                              });
                                                                            },
                                                                            borderRadius: const BorderRadius.only(
                                                                              topRight: Radius.circular(10),
                                                                              bottomRight: Radius.circular(10),
                                                                            ),
                                                                            child: Container(
                                                                              decoration: BoxDecoration(
                                                                                color: Colors.green.shade50,
                                                                                borderRadius: const BorderRadius.only(
                                                                                  topRight: Radius.circular(10),
                                                                                  bottomRight: Radius.circular(10),
                                                                                ),
                                                                              ),
                                                                              child: const Center(
                                                                                child: Icon(
                                                                                  Icons.add,
                                                                                  color: Colors.black,
                                                                                  size: 22,
                                                                                ),
                                                                              ),
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    );
                                                },
                                              )
                                            : ListView.builder(
                                                itemCount: widget.productList.length,
                                                physics: const NeverScrollableScrollPhysics(),
                                                shrinkWrap: true,
                                                padding: EdgeInsets.zero,
                                                itemBuilder: (context, index) {
                                                  final item = widget.productList[index];
                                                  if (item == null) return const SizedBox();

                                                  return Container(
                                                    margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 2),
                                                    height: 120,
                                                    decoration: BoxDecoration(
                                                      color: Colors.white,
                                                      borderRadius: BorderRadius.circular(16),
                                                      boxShadow: [
                                                        BoxShadow(
                                                          color: Colors.grey.withOpacity(0.15),
                                                          blurRadius: 12,
                                                          offset: const Offset(0, 6),
                                                        ),
                                                      ],
                                                      border: Border.all(
                                                        color: counts[index] == 0
                                                            ? Colors.deepOrange.withOpacity(0.3)
                                                            : Colors.green.withOpacity(0.3),
                                                        width: 1.5,
                                                      ),
                                                    ),
                                                    child: Material(
                                                      color: Colors.transparent,
                                                      borderRadius: BorderRadius.circular(16),
                                                      child: InkWell(
                                                        borderRadius: BorderRadius.circular(16),
                                                        onTap: () {
                                                          // Optional: Add item on tap
                                                        },
                                                        child: Padding(
                                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                                          child: Row(
                                                            children: [
                                                              // Image with Badge
                                                              Stack(
                                                                children: [
                                                                  Container(
                                                                    width: 80,
                                                                    height: 80,
                                                                    decoration: BoxDecoration(
                                                                      borderRadius: BorderRadius.circular(12),
                                                                      boxShadow: [
                                                                        BoxShadow(
                                                                          color: Colors.black.withOpacity(0.1),
                                                                          blurRadius: 6,
                                                                          offset: const Offset(0, 3),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                    child: ClipRRect(
                                                                      borderRadius: BorderRadius.circular(12),
                                                                      child: CachedNetworkImage(
                                                                        imageUrl: item.image ?? '',
                                                                        width: 80,
                                                                        height: 80,
                                                                        fit: BoxFit.cover,
                                                                        placeholder: (context, url) => Container(
                                                                          width: 80,
                                                                          height: 80,
                                                                          decoration: BoxDecoration(
                                                                            gradient: LinearGradient(
                                                                              colors: [
                                                                                Colors.grey[200]!,
                                                                                Colors.grey[100]!,
                                                                              ],
                                                                            ),
                                                                            borderRadius: BorderRadius.circular(12),
                                                                          ),
                                                                          child: const Center(
                                                                            child: CircularProgressIndicator(
                                                                              color: Colors.orange,
                                                                              strokeWidth: 2,
                                                                            ),
                                                                          ),
                                                                        ),
                                                                        errorWidget: (context, url, error) => Container(
                                                                          width: 80,
                                                                          height: 80,
                                                                          decoration: BoxDecoration(
                                                                            gradient: LinearGradient(
                                                                              colors: [
                                                                                Colors.grey[200]!,
                                                                                Colors.grey[100]!,
                                                                              ],
                                                                            ),
                                                                            borderRadius: BorderRadius.circular(12),
                                                                          ),
                                                                          child: const Center(
                                                                            child: Icon(
                                                                              Icons.image_search,
                                                                              color: Colors.grey,
                                                                              size: 30,
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ),

                                                                  // Quantity Badge (if added)
                                                                  if (counts[index] > 0)
                                                                    Positioned(
                                                                      top: 2,
                                                                      right: 2,
                                                                      child: Container(
                                                                        padding: const EdgeInsets.all(6),
                                                                        decoration: const BoxDecoration(
                                                                          color: Colors.green,
                                                                          shape: BoxShape.circle,
                                                                          boxShadow: [
                                                                            BoxShadow(
                                                                              color: Colors.green,
                                                                              blurRadius: 4,
                                                                            ),
                                                                          ],
                                                                        ),
                                                                        child: Text(
                                                                          counts[index].toString(),
                                                                          style: const TextStyle(
                                                                            fontSize: 10,
                                                                            fontWeight: FontWeight.bold,
                                                                            color: Colors.white,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                ],
                                                              ),
                                                              const SizedBox(width: 10),

                                                              // Product Details
                                                              Expanded(
                                                                child: Column(
                                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                                  children: [
                                                                    // Title
                                                                    Text(
                                                                      item.enSetTitle ?? '',
                                                                      style: TextStyle(
                                                                        fontWeight: FontWeight.w700,
                                                                        color: Colors.deepOrange.shade800,
                                                                        fontSize: 13,
                                                                        height: 1.3,
                                                                      ),
                                                                      maxLines: 1,
                                                                      overflow: TextOverflow.ellipsis,
                                                                    ),
                                                                    const SizedBox(height: 4),

                                                                    // Price and Unit Info
                                                                    Row(
                                                                      children: [
                                                                        Container(
                                                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                                                          decoration: BoxDecoration(
                                                                            color: Colors.deepOrange.withOpacity(0.1),
                                                                            borderRadius: BorderRadius.circular(6),
                                                                            border: Border.all(
                                                                              color: Colors.deepOrange.withOpacity(0.2),
                                                                            ),
                                                                          ),
                                                                          child: Row(
                                                                            mainAxisSize: MainAxisSize.min,
                                                                            children: [
                                                                              Text(
                                                                                "₹",
                                                                                style: TextStyle(
                                                                                  fontSize: 12,
                                                                                  fontWeight: FontWeight.bold,
                                                                                  color: Colors.deepOrange.shade700,
                                                                                ),
                                                                              ),
                                                                              const SizedBox(width: 2),
                                                                              Text(
                                                                                NumberFormat('#,##0').format(int.tryParse(item.setAmount ?? '0') ?? 0),
                                                                                style: const TextStyle(
                                                                                  fontSize: 14,
                                                                                  fontWeight: FontWeight.bold,
                                                                                  color: Colors.black87,
                                                                                ),
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        ),
                                                                        const SizedBox(width: 3),

                                                                        Text(
                                                                          "/",
                                                                          style: TextStyle(
                                                                            color: Colors.grey[400],
                                                                            fontSize: 16,
                                                                          ),
                                                                        ),
                                                                        const SizedBox(width: 1),

                                                                        Text(
                                                                          "${item.setNumber} ${item.setUnit}",
                                                                          style: TextStyle(
                                                                            fontSize: 12,
                                                                            color: Colors.grey[600],
                                                                            fontWeight: FontWeight.w500,
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),

                                                                    const SizedBox(height: 6),

                                                                      Container(
                                                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                                        decoration: BoxDecoration(
                                                                          color: Colors.green.withOpacity(0.1),
                                                                          borderRadius: BorderRadius.circular(6),
                                                                          border: Border.all(
                                                                            color: Colors.green.withOpacity(0.2),
                                                                          ),
                                                                        ),
                                                                        child: Row(
                                                                          mainAxisSize: MainAxisSize.min,
                                                                          children: [
                                                                            Text(
                                                                              "Total: ",
                                                                              style: TextStyle(
                                                                                fontSize: 11,
                                                                                color: Colors.grey[700],
                                                                              ),
                                                                            ),
                                                                            Text(
                                                                              "₹${counts[index] * int.parse(item.setAmount ?? '0')}",
                                                                              style: const TextStyle(
                                                                                fontSize: 13,
                                                                                fontWeight: FontWeight.bold,
                                                                                color: Colors.green,
                                                                              ),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                      ),
                                                                  ],
                                                                ),
                                                              ),
                                                              const SizedBox(width: 10),

                                                              // Add/Remove Button
                                                              counts[index] == 0
                                                                  ? Container(
                                                                height: 40,
                                                                padding: EdgeInsets.all(10),
                                                                decoration: BoxDecoration(
                                                                  gradient: LinearGradient(
                                                                    colors: [
                                                                      Colors.deepOrange,
                                                                      Colors.orange,
                                                                    ],
                                                                    begin: Alignment.topLeft,
                                                                    end: Alignment.bottomRight,
                                                                  ),
                                                                  borderRadius: BorderRadius.circular(10),
                                                                  boxShadow: [
                                                                    BoxShadow(
                                                                      color: Colors.orange.withOpacity(0.3),
                                                                      blurRadius: 8,
                                                                      offset: const Offset(0, 4),
                                                                    ),
                                                                  ],
                                                                ),
                                                                child: Material(
                                                                  color: Colors.transparent,
                                                                  child: InkWell(
                                                                    onTap: () {
                                                                      setState(() {
                                                                        counts[index] = 1;
                                                                        addOrUpdateItem(index);
                                                                      });
                                                                    },
                                                                    borderRadius: BorderRadius.circular(10),
                                                                    child: Center(
                                                                      child: Row(
                                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                                        children: [
                                                                          const Icon(
                                                                            Icons.add,
                                                                            color: Colors.white,
                                                                            size: 16,
                                                                          ),
                                                                          const SizedBox(width: 4),
                                                                          const Text(
                                                                            "Add Donate",
                                                                            style: TextStyle(
                                                                              color: Colors.white,
                                                                              fontWeight: FontWeight.w600,
                                                                              fontSize: 12,
                                                                            ),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                              )
                                                                  : Container(
                                                                width: 110,
                                                                height: 40,
                                                                decoration: BoxDecoration(
                                                                  color: Colors.white,
                                                                  borderRadius: BorderRadius.circular(10),
                                                                  border: Border.all(
                                                                    color: Colors.green,
                                                                    width: 1,
                                                                  ),
                                                                ),
                                                                child: Row(
                                                                  children: [
                                                                    // Minus Button
                                                                    Expanded(
                                                                      child: InkWell(
                                                                        onTap: () {
                                                                          setState(() {
                                                                            if (counts[index] > 0) counts[index]--;
                                                                            addOrUpdateItem(index);
                                                                          });
                                                                        },
                                                                        borderRadius: const BorderRadius.only(
                                                                          topLeft: Radius.circular(10),
                                                                          bottomLeft: Radius.circular(10),
                                                                        ),
                                                                        child: Container(
                                                                          decoration:  BoxDecoration(
                                                                            color: Colors.green.shade50,
                                                                            borderRadius: BorderRadius.only(
                                                                              topLeft: Radius.circular(10),
                                                                              bottomLeft: Radius.circular(10),
                                                                            ),
                                                                          ),
                                                                          child: const Center(
                                                                            child: Icon(
                                                                              Icons.remove,
                                                                              color: Colors.black,
                                                                              size: 18,
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ),

                                                                    // Quantity Display
                                                                    Expanded(
                                                                      child: Container(
                                                                        color: Colors.green.shade50,
                                                                        child: Center(
                                                                          child: Text(
                                                                            "${counts[index]}",
                                                                            style: const TextStyle(
                                                                              fontSize: 15,
                                                                              fontWeight: FontWeight.bold,
                                                                              color: Colors.green,
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ),

                                                                    // Plus Button
                                                                    Expanded(
                                                                      child: InkWell(
                                                                        onTap: () {
                                                                          setState(() {
                                                                            counts[index]++;
                                                                            addOrUpdateItem(index);
                                                                          });
                                                                        },
                                                                        borderRadius: const BorderRadius.only(
                                                                          topRight: Radius.circular(10),
                                                                          bottomRight: Radius.circular(10),
                                                                        ),
                                                                        child: Container(
                                                                          decoration:  BoxDecoration(
                                                                            color:  Colors.green.shade50,
                                                                            borderRadius: BorderRadius.only(
                                                                              topRight: Radius.circular(10),
                                                                              bottomRight: Radius.circular(10),
                                                                            ),
                                                                          ),
                                                                          child: const Center(
                                                                            child: Icon(
                                                                              Icons.add,
                                                                              color: Colors.black,
                                                                              size: 18,
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  );
                                                },
                                              ),

                                        const SizedBox(height: 24),
                                      ],
                                    )
                                  : const SizedBox.shrink(),

                              _buildAmountSelectionSection(),
                              SizedBox(height: 24),

                              // Wallet Section
                              walletPay == 0
                                  ? SizedBox()
                                  : Column(
                                      children: [
                                        _buildWalletSection(),
                                        SizedBox(height: 24),
                                      ],
                                    ),

                              widget.autoPayStaus == 1
                                  ? Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "Frequencies",
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 10),
                                        SizedBox(
                                          height: 50,
                                          child: ListView.builder(
                                            itemCount: frequencies.length,
                                            scrollDirection: Axis.horizontal,
                                            itemBuilder: (context, index) {
                                              bool isSelected =
                                                  selectedIndex == index;

                                              // agar wallet applied hai aur index 0 nahi hai to disable kar do
                                              bool isDisabled =
                                                  isWalletApplied && index != 0;

                                              return GestureDetector(
                                                onTap: isDisabled
                                                    ? null // ❌ disable click
                                                    : () {
                                                        setState(() {
                                                          selectedIndex = index;
                                                        });
                                                      },
                                                child: AnimatedContainer(
                                                  duration: const Duration(
                                                      milliseconds: 300),
                                                  curve: Curves.easeInOut,
                                                  margin: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 5,
                                                      vertical: 4),
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 10,
                                                      vertical: 1),
                                                  decoration: BoxDecoration(
                                                    color: isDisabled
                                                        ? Colors.grey
                                                            .shade300 // blur effect when disabled
                                                        : isSelected
                                                            ? Colors.orange
                                                            : Colors
                                                                .grey.shade100,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8),
                                                    border: Border.all(
                                                      color: isSelected
                                                          ? Colors.black
                                                          : Colors
                                                              .deepOrange.shade300,
                                                      width: 1,
                                                    ),
                                                  ),
                                                  child: isDisabled
                                                      ? Row(
                                                          children: [
                                                            Text(
                                                              frequencies[
                                                                  index],
                                                              style: TextStyle(
                                                                fontSize: 16,
                                                                color: isDisabled
                                                                    ? Colors.grey // faded text when disabled
                                                                    : isSelected
                                                                        ? Colors.white
                                                                        : Colors.black87,
                                                                fontWeight: isSelected
                                                                    ? FontWeight
                                                                        .bold
                                                                    : FontWeight
                                                                        .w500,
                                                              ),
                                                            ),
                                                            Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .only(
                                                                      left:
                                                                          8.0),
                                                              child: Icon(
                                                                Icons.lock,
                                                                color:
                                                                    Colors.red,
                                                                size: 20,
                                                              ),
                                                            ),
                                                          ],
                                                        )
                                                      : Row(
                                                          children: [
                                                            Text(
                                                              frequencies[
                                                                  index],
                                                              style: TextStyle(
                                                                fontSize: 16,
                                                                color: isDisabled
                                                                    ? Colors.grey // faded text when disabled
                                                                    : isSelected
                                                                        ? Colors.white
                                                                        : Colors.black87,
                                                                fontWeight: isSelected
                                                                    ? FontWeight
                                                                        .bold
                                                                    : FontWeight
                                                                        .w500,
                                                              ),
                                                            ),
                                                            if (isSelected)
                                                              Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                        .only(
                                                                        left:
                                                                            8.0),
                                                                child: Icon(
                                                                  Icons
                                                                      .check_circle_rounded,
                                                                  color: isDisabled
                                                                      ? Colors
                                                                          .grey
                                                                      : Colors
                                                                          .white,
                                                                  size: 20,
                                                                ),
                                                              ),
                                                          ],
                                                        ),
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                        SizedBox(height: 20),
                                      ],
                                    )
                                  : SizedBox(),
                              SizedBox(height: 24),

                              // User Details Form
                              _buildUserDetailsForm(),
                              SizedBox(height: 24),

                              // Total Amount
                              _buildTotalAmountSection(),
                              SizedBox(height: 24),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  bottomNavigationBar: _buildPaymentButton(context),
                ),
              );
  }

  AppBar _buildAppBar(ThemeData theme) {
    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
        onPressed: () async {
          if (await _showExitDialog(context)) {
            Navigator.pop(context);
          }
        },
      ),
      backgroundColor: Colors.deepOrange,
      title: Column(
        children: [
          Text(
            "Make your Donatiion",
            style: theme.textTheme.titleLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            "${widget.engname}",
            style: TextStyle(fontSize: 14,color: Colors.white),
          ),
        ],
      ),
      elevation: 0,
      centerTitle: true,
      actions: [
        // Single toggle button
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: InkWell(
            onTap: () {
              setState(() {
                _isGridView = !_isGridView;
              });
            },
            borderRadius: BorderRadius.circular(12),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: _isGridView ? Colors.deepOrange : Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Icon with animation
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    transitionBuilder: (child, animation) {
                      return ScaleTransition(
                        scale: animation,
                        child: child,
                      );
                    },
                    child: _isGridView
                        ? Icon(
                      Icons.list,
                      color: Colors.white,
                      size: 22,
                    )
                        : Icon(
                      Icons.grid_view,
                      color: Colors.deepOrange,
                      size: 22,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        SizedBox(width: 10,)
      ],
    );
  }

  Widget _buildAmountSelectionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Choose Amount',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _amounts.map((amount) {
            final isSelected = _selectedAmount == amount;

            return ChoiceChip(
              label: Text(
                "${NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0).format(double.tryParse("$amount") ?? 0)}",
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
              selected: isSelected,
              onSelected: (_) {
                setState(() {
                  // If same item tapped again → deselect
                  if (_selectedAmount == amount) {
                    _selectedAmount = "";
                    increasedAmount = 0;
                  } else {
                    // Select new amount
                    isCustomAmount = false;
                    _customAmountController.clear();
                    _selectedAmount = amount;
                    increasedAmount = double.parse(amount);
                  }
                });
              },
              selectedColor: Colors.orange,
              backgroundColor: Colors.white,
              shape: StadiumBorder(
                side: BorderSide(
                  color: isSelected ? Colors.orange.shade900 : Colors.black,
                  width: isSelected ? 0 : 1,
                ),
              ),
              elevation: 0,
              pressElevation: 0,
            );
          }).toList(),
        ),
        const SizedBox(height: 16),

        // OR Divider
        const Row(
          children: [
            Expanded(child: Divider()),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                "OR",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
            ),
            Expanded(child: Divider()),
          ],
        ),

        const SizedBox(height: 16),

        // Custom Amount
        const Text(
          'Enter Custom Amount',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),

        TextField(
          focusNode: _amountFocusNode,
          controller: _customAmountController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
          ],
          onTap: () {
            setState(() {
              isCustomAmount = true;
              _customAmountController.clear();
              _selectedAmount = "";
              increasedAmount = 0;
            });
          },
          onChanged: (value) {
            setState(() {
              isCustomAmount = true;
              _selectedAmount = "";
              increasedAmount = 0;
            });
          },
          decoration: InputDecoration(
            hintText: "Enter amount in ₹",
            prefixIcon:
                const Icon(Icons.currency_rupee, color: Colors.deepOrange),
            filled: true,
            fillColor: Colors.grey[100],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  const BorderSide(color: Colors.deepOrange, width: 1.5),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ],
    );
  }

  Widget _buildWalletSection() {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 6,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: SwitchListTile(
            value: isWalletApplied,
            onChanged: (value) {
              setState(() {
                isWalletApplied = value;
                if (value) {
                  selectedIndex = 0; //  only when turned ON
                }
              });
            },
            title: const Text(
              "Apply Wallet Balance",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            secondary: const Icon(Icons.wallet, color: Colors.deepOrange),
            activeColor: Colors.deepOrange,
          ),
        ),
        if (isWalletApplied) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 6,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Payment Summary",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepOrange,
                  ),
                ),
                SizedBox(height: 12),
                Divider(height: 1),
                SizedBox(height: 12),
                _buildPaymentDetailRow(
                  "Wallet Balance",
                  "${NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0).format(double.tryParse("$amountAfterWallet") ?? 0)}",
                  isPositive: true,
                ),
                _buildPaymentDetailRow(
                  "Amount Deducted",
                  "- ${NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0).format(double.tryParse("$walletDeducatedAmount") ?? 0)}",
                  isNegative: true,
                ),
                SizedBox(height: 8),
                Divider(height: 1),
                SizedBox(height: 8),
                _buildPaymentDetailRow(
                  "Remaining Amount",
                  "${NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0).format(double.tryParse("$remainDonateAmount") ?? 0)}",
                  isBold: true,
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildPaymentDetailRow(
    String label,
    String value, {
    bool isPositive = false,
    bool isNegative = false,
    bool isBold = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              color: isPositive
                  ? Colors.green
                  : isNegative
                      ? Colors.red
                      : Colors.black,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserDetailsForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Your Details",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildDetailTextField(
            controller: _nameController,
            label: "Full Name",
            icon: Icons.person_outline,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter your name';
              } else if (value.trim().length < 3) {
                return 'Name must be at least 3 characters';
              } else if (!RegExp(r'^[a-zA-Z ]+$').hasMatch(value.trim())) {
                return 'Only alphabets and spaces allowed';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          _buildDetailTextField(
            controller: _phoneController,
            label: "Mobile Number",
            icon: Icons.phone_android_outlined,
            keyboardType: TextInputType.phone,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter your phone number';
              }
              final trimmed = value.trim().replaceAll(' ', '');
              final cleaned =
                  trimmed.startsWith('+91') ? trimmed.substring(3) : trimmed;
              if (!RegExp(r'^[0-9]{10}$').hasMatch(cleaned)) {
                return 'Enter a valid 10-digit number';
              }
              return null;
            },
          ),

          SizedBox(height: 16),

          _buildPanField()
        ],
      ),
    );
  }

  Widget _buildPanField() {
    return Row(
      children: [
        // PAN input
        Expanded(
          child: TextFormField(
            controller: _panCardController,
            textCapitalization: TextCapitalization.characters,
            readOnly: _panState == PanVerifyState.success && !_isEditingPan,
            onChanged: (value) {
              setState(() {}); // To rebuild verify button
            },
            validator: (value) {
              if (value != null && value.trim().isNotEmpty) {
                final reg = RegExp(r'^[A-Z]{5}[0-9]{4}[A-Z]{1}$');
                if (!reg.hasMatch(value.trim().toUpperCase())) {
                  return "Invalid PAN format (e.g., ABCDE1234F)";
                }
              }
              return null;
            },
            decoration: InputDecoration(
              labelText: "PAN Card (Optional)",
              prefixIcon: const Icon(Icons.credit_card_outlined,
                  color: Colors.deepOrange),
              suffixIcon: _panState == PanVerifyState.success
                  ? IconButton(
                      icon: const Icon(Icons.edit, color: Colors.deepOrange),
                      onPressed: () {
                        setState(() {
                          _isEditingPan = true;
                          _panState = PanVerifyState.failed; // reset state
                        });
                      },
                    )
                  : null,
              filled: true,
              fillColor: Colors.grey[100],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide:
                    const BorderSide(color: Colors.deepOrange, width: 1.5),
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              errorStyle: const TextStyle(height: 0.8),
            ),
          ),
        ),

        const SizedBox(width: 8),

        // Verify / Status button
        _buildVerifyButton(),
      ],
    );
  }

  Widget _buildVerifyButton() {
    switch (_panState) {
      case PanVerifyState.verifying:
        return const SizedBox(
          width: 80,
          height: 44,
          child: Center(
            child: SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
        );
      case PanVerifyState.success:
        return _statusButton("Verified", Colors.green, null);
      case PanVerifyState.failed:
        return _statusButton("Retry", Colors.red, _verifyPan);
      default:
        return _statusButton(
          "Verify",
          Colors.deepOrange,
          _panCardController.text.trim().isEmpty ? null : _verifyPan,
        );
    }
  }

  Widget _statusButton(String label, Color color, VoidCallback? onPressed) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(80, 44),
        backgroundColor: color,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      onPressed: onPressed,
      child: Text(label, style: const TextStyle(fontSize: 13)),
    );
  }

  Future<void> _verifyPan() async {
    debugPrint("Verify Button Clicked");

    setState(() {
      _isEditingPan = false;
    });

    final pan = _panCardController.text.trim().toUpperCase();
    if (!RegExp(r'^[A-Z]{5}[0-9]{4}[A-Z]{1}$').hasMatch(pan)) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Invalid PAN format"),
        backgroundColor: Colors.red,
      ));
      return;
    }

    setState(() => _panState = PanVerifyState.verifying);

    try {
      final res = await HttpService().postApi(
        AppConstants.donationPanUrl,
        {"pancard": pan},
      );

      debugPrint("PAN API Response: $res");

      final bool ok = res != null && (res['status'] == 1);

      if (ok) {
        setState(() => _panState = PanVerifyState.success);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(res['message'] ?? "PAN verified"),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        setState(() => _panState = PanVerifyState.failed);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(res?['message'] ?? "PAN verification failed"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      debugPrint("PAN verify error: $e");
      setState(() => _panState = PanVerifyState.failed);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Error verifying PAN"),
        backgroundColor: Colors.red,
      ));
    }
  }

  Widget _buildDetailTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String? Function(String?) validator,
    TextInputType? keyboardType,
    TextCapitalization textCapitalization = TextCapitalization.none,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      textCapitalization: textCapitalization,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.deepOrange),
        filled: true,
        fillColor: Colors.grey[100],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.deepOrange, width: 1.5),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        errorStyle: const TextStyle(height: 0.8),
      ),
    );
  }

  Widget _buildTotalAmountSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(Icons.payment, color: Colors.deepOrange, size: 28),
          SizedBox(width: 12),
          Text(
            "Total Amount",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          Spacer(),
          Text(
            NumberFormat.currency(
              locale: 'en_IN',
              symbol: '₹',
              decimalDigits: 0,
            ).format(
              isWalletApplied
                  ? remainDonateAmount
                  : ((isCustomAmount
                          ? double.tryParse(
                                  _customAmountController.text.trim()) ??
                              0
                          : increasedAmount) +
                      totalPackagePrice),
            ),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.deepOrange,
            ),
          )
        ],
      ),
    );
  }

  Widget _buildPaymentButton(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.deepOrange,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16),
          elevation: 0,
        ),
        onPressed: _isLoading ? null : _handlePayment,
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          transitionBuilder: (child, animation) =>
              FadeTransition(opacity: animation, child: child),
          child: _isLoading
              ? const SizedBox(
                  key: ValueKey('loader'),
                  height: 22,
                  width: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: Colors.white,
                  ),
                )
              : Row(
                  key: const ValueKey('text'),
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const SizedBox(width: 12),

                    // Amount Text
                    Text(
                      NumberFormat.currency(
                        locale: 'en_IN',
                        symbol: '₹ ',
                        decimalDigits: 0,
                      ).format(
                        isWalletApplied
                            ? remainDonateAmount
                            : ((isCustomAmount
                                    ? double.tryParse(
                                          _customAmountController.text.trim(),
                                        ) ??
                                        0
                                    : increasedAmount) +
                                totalPackagePrice),
                      ),
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Spacer(),

                    // Text "Proceed to Pay"
                    const Text(
                      "PROCEED TO PAY",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Arrow Icon
                    const Icon(Icons.arrow_forward_ios, color: Colors.white),
                    const SizedBox(width: 15),
                  ],
                ),
        ),
      ),
    );
  }

  void _handlePayment() {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Please fill all details correctly"),
        backgroundColor: Colors.red,
      ));
      return;
    }

    if (isCustomAmount && _customAmountController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Please Enter Amount to Donate"),
        backgroundColor: Colors.red,
      ));
      return;
    }

    final pan = _panCardController.text.trim().toUpperCase();

    if (pan.isNotEmpty && _panState != PanVerifyState.success) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Please verify PAN before proceeding"),
        backgroundColor: Colors.red,
      ));
      return;
    }

    updateLeadDetails();
  }
}
