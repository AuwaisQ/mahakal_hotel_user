import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

Widget totalAmountDisplay({
  required dynamic amount,
  bool showRupeeSymbol = true,
  double fontSize = 22.0,
  Color backgroundColor = Colors.orange,
  Color amountColor = Colors.green,
}) {

  String formatIndianCurrency(dynamic amount) {
    num parsedAmount = 0;

    // Try to safely parse any input type
    if (amount is num) {
      parsedAmount = amount;
    } else if (amount is String) {
      parsedAmount = num.tryParse(amount.replaceAll(',', '')) ?? 0;
    }

    final format = NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹',
      decimalDigits: 0,
    );

    return format.format(parsedAmount);
  }

  return Container(
    width: 320,
    height: 50,
    decoration: BoxDecoration(
      color: backgroundColor.withOpacity(0.1),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(
        color: backgroundColor.withOpacity(0.3),
      ),
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Total: ',
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        Text(
        formatIndianCurrency(amount),
          //amount.toString(),
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
            color: amountColor,
          ),
        ),
      ],
    ),
  );
}
