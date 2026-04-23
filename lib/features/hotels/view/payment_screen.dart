import 'package:flutter/material.dart';

import '../model/hotel_model.dart';
import '../widgets/hotel_uihelper.dart';


class PaymentScreen extends StatefulWidget {
  final Hotel hotel;
  final Room room;
  final DateTime checkIn;
  final DateTime checkOut;
  final int guests;
  final double totalPrice;

  const PaymentScreen({
    super.key,
    required this.hotel,
    required this.room,
    required this.checkIn,
    required this.checkOut,
    required this.guests,
    required this.totalPrice,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  int _selectedPaymentMethod = 0;
  final TextEditingController _cardNumberController = TextEditingController();
  final TextEditingController _expiryController = TextEditingController();
  final TextEditingController _cvvController = TextEditingController();
  final TextEditingController _cardNameController = TextEditingController();
  bool _saveCard = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Payment', style: AppTextStyles.heading4),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Order Summary
            _buildOrderSummary(),
            const SizedBox(height: 24),

            // Payment Methods
            _buildPaymentMethods(),
            const SizedBox(height: 24),

            // Card Details (if selected)
            if (_selectedPaymentMethod == 0) _buildCardDetails(),
            const SizedBox(height: 24),

            // Security Badge
            _buildSecurityInfo(),
            const SizedBox(height: 80),
          ],
        ),
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.white,
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: () => _showPaymentSuccessDialog(),
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, 56),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: Text('Pay Now', style: AppTextStyles.captionLarge),
        ),
      ),
    );
  }

  Widget _buildOrderSummary() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.lightGray,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Order Summary', style: AppTextStyles.heading4),
          const SizedBox(height: 12),
          _buildSummaryRow('Hotel', widget.hotel.name),
          _buildSummaryRow('Room', widget.room.type),
          _buildSummaryRow(
            'Dates',
            '${widget.checkIn.day}/${widget.checkIn.month} - ${widget.checkOut.day}/${widget.checkOut.month}',
          ),
          _buildSummaryRow('Guests', '${widget.guests} persons'),
          const Divider(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total Amount', style: AppTextStyles.heading4),
              Text(
                '₹${widget.totalPrice.toInt()}',
                style: AppTextStyles.priceLarge,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTextStyles.captionSmall),
          Text(value, style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildPaymentMethods() {
    final methods = [
      {'icon': Icons.credit_card, 'title': 'Credit/Debit Card', 'subtitle': 'Pay with your card'},
      {'icon': Icons.account_balance_wallet, 'title': 'UPI', 'subtitle': 'Google Pay, PhonePe, etc.'},
      {'icon': Icons.account_balance, 'title': 'Net Banking', 'subtitle': 'All major banks'},
      {'icon': Icons.wallet, 'title': 'Wallet', 'subtitle': 'Paytm, Amazon Pay'},
      {'icon': Icons.payments, 'title': 'Cash at Hotel', 'subtitle': 'Pay when you arrive'},
    ];

    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.lightGray),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Payment Method', style: AppTextStyles.heading4),
          const SizedBox(height: 16),
          Column(
            children: List.generate(
              methods.length,
                  (index) => GestureDetector(
                onTap: () => setState(() => _selectedPaymentMethod = index),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _selectedPaymentMethod == index
                        ? AppColors.blue.withOpacity(0.05)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _selectedPaymentMethod == index
                          ? AppColors.blue
                          : AppColors.lightGray,
                      width: _selectedPaymentMethod == index ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: _selectedPaymentMethod == index
                              ? AppColors.blue
                              : AppColors.lightGray,
                          shape: BoxShape.circle,
                        ),
                        padding: const EdgeInsets.all(8),
                        child: Icon(
                          methods[index]['icon'] as IconData,
                          size: 20,
                          color: _selectedPaymentMethod == index
                              ? AppColors.white
                              : AppColors.darkGray,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              methods[index]['title'] as String,
                              style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600),
                            ),
                            Text(
                              methods[index]['subtitle'] as String,
                              style: AppTextStyles.captionSmall,
                            ),
                          ],
                        ),
                      ),
                      Radio(
                        value: index,
                        groupValue: _selectedPaymentMethod,
                        onChanged: (value) => setState(() => _selectedPaymentMethod = value!),
                        activeColor: AppColors.blue,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardDetails() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.lightGray),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Card Details', style: AppTextStyles.heading4),
          const SizedBox(height: 16),

          // Card Preview
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.blue, AppColors.yellow],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Icon(Icons.credit_card, color: AppColors.white, size: 32),
                    Text(
                      'VISA',
                      style: TextStyle(
                        color: AppColors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                const Text(
                  '1234 5678 9012 3456',
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('CARD HOLDER', style: TextStyle(color: AppColors.white, fontSize: 10)),
                        const SizedBox(height: 4),
                        Text(
                          _cardNameController.text.isEmpty
                              ? 'YOUR NAME'
                              : _cardNameController.text.toUpperCase(),
                          style: const TextStyle(
                            color: AppColors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('VALID THRU', style: TextStyle(color: AppColors.white, fontSize: 10)),
                        const SizedBox(height: 4),
                        Text(
                          _expiryController.text.isEmpty ? 'MM/YY' : _expiryController.text,
                          style: const TextStyle(
                            color: AppColors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Card Form
          TextField(
            controller: _cardNumberController,
            decoration: InputDecoration(
              labelText: 'Card Number',
              hintText: '1234 5678 9012 3456',
              labelStyle: TextStyle(color: AppColors.gray),
              prefixIcon: Icon(Icons.credit_card, color: AppColors.gray),
            ),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _expiryController,
                  decoration: InputDecoration(
                    labelText: 'Expiry Date',
                    hintText: 'MM/YY',
                    labelStyle: TextStyle(color: AppColors.gray),
                    prefixIcon: Icon(Icons.calendar_today, color: AppColors.gray),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _cvvController,
                  decoration: InputDecoration(
                    labelText: 'CVV',
                    hintText: '123',
                    labelStyle: TextStyle(color: AppColors.gray),
                    prefixIcon: Icon(Icons.lock, color: AppColors.gray),
                  ),
                  keyboardType: TextInputType.number,
                  obscureText: true,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _cardNameController,
            decoration: InputDecoration(
              labelText: 'Cardholder Name',
              hintText: 'Enter name as on card',
              labelStyle: TextStyle(color: AppColors.gray),
              prefixIcon: Icon(Icons.person, color: AppColors.gray),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Checkbox(
                value: _saveCard,
                onChanged: (value) => setState(() => _saveCard = value!),
                activeColor: AppColors.blue,
              ),
              Text('Save card for future payments', style: AppTextStyles.bodySmall),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSecurityInfo() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.lightGray,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Icon(Icons.lock, color: AppColors.green, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Secure Payment', style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
                Text(
                  'Your payment information is encrypted and secure',
                  style: AppTextStyles.captionSmall,
                ),
              ],
            ),
          ),
          Image.network(
            'https://upload.wikimedia.org/wikipedia/commons/thumb/2/2a/Razorpay_logo.svg/1200px-Razorpay_logo.svg.png',
            height: 30,
          ),
        ],
      ),
    );
  }

  void _showPaymentSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.green.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.check, size: 48, color: AppColors.green),
              ),
              const SizedBox(height: 24),
              Text('Payment Successful!', style: AppTextStyles.heading3),
              const SizedBox(height: 16),
              Text(
                'Your booking has been confirmed. You will receive a confirmation email shortly.',
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyMedium.copyWith(color: AppColors.gray),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.popUntil(context, (route) => route.isFirst);
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text('Back to Home', style: AppTextStyles.captionLarge),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}