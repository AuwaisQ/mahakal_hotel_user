import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class PersonCardWidget extends StatelessWidget {
  final dynamic quantity;
  final dynamic minGroup;
  final dynamic maxGroup;
  final dynamic price;
  final dynamic finalAmount;
  final VoidCallback onAddPressed;
  final VoidCallback onIncreasePressed;
  final VoidCallback onDecreasePressed;
  final VoidCallback onInfoTap;
  final String isInfoView;

  const PersonCardWidget({
    super.key,
    required this.quantity,
    required this.minGroup,
    required this.maxGroup,
    required this.price,
    required this.finalAmount,
    required this.onAddPressed,
    required this.onIncreasePressed,
    required this.onDecreasePressed,
    required this.onInfoTap,
    required this.isInfoView,
  });

  @override
  Widget build(BuildContext context) {
    final bool isFixedGroup = minGroup == maxGroup;
    final bool isSelected = quantity > 0;

// Always show counter when selected
    final bool showCounter = isSelected;

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

    // Color definitions
    const Color deepOrange = Color(0xFFF05E23);
    const Color darkCharcoal = Color(0xFF2D2D2D);
    const Color lightGray = Color(0xFFF5F5F5);
    const Color mediumGray = Color(0xFFE0E0E0);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              spreadRadius: 1,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(
            color: isSelected ? deepOrange.withOpacity(0.6) : mediumGray,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Column(
          children: [

            // Header section
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isSelected ? deepOrange.withOpacity(0.08) : lightGray,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Row(
                children: [
                  // Centered "Per Person" Container
                  Expanded(
                    child: Center(
                      child: Container(
                        constraints: const BoxConstraints(maxWidth: 300),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? deepOrange.withOpacity(0.15)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelected
                                ? Colors.black.withOpacity(0.3)
                                : mediumGray,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.people_alt_outlined,
                              size: 20,
                              color: isSelected
                                  ? Colors.black
                                  : darkCharcoal.withOpacity(0.6),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              isFixedGroup
                                  ? "Up to $minGroup person"
                                  : "Group of $minGroup - $maxGroup",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: isSelected ? Colors.black : Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Info Icon
                  IconButton(
                    onPressed: () {
                      showDescriptionBottomSheet(context, "${isInfoView}");
                    },
                    icon:  Icon(Icons.info_outline,
                        size: 20, color: isSelected ? deepOrange : Colors.grey),
                  ),
                ],
              ),
            ),

            // Total amount (moved above the buttons)
            if (isSelected)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Row(
                  children: [
                    Text(
                      "Total amount",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: deepOrange.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        formatIndianCurrency(finalAmount),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: deepOrange,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            // Main content (buttons)
            Padding(
              padding: EdgeInsets.fromLTRB(16, isSelected ? 0 : 16, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Price and action buttons
                  Row(
                    children: [
                      // Price column
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            formatIndianCurrency(price),
                           // "₹$price",
                            style:  TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                              color: isSelected ? Colors.black : Colors.grey,
                              height: 0.9,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            " Per Person",
                            style: TextStyle(
                              fontSize: 12,
                              color: darkCharcoal.withOpacity(0.6),
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      // Add button or counter
                      if (!isSelected)
                        ElevatedButton(
                          onPressed: onAddPressed,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: deepOrange,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 24, vertical: 12),
                            elevation: 0,
                            shadowColor: deepOrange.withOpacity(0.3),
                          ),
                          child: const Text(
                            "SELECT",
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.5,
                            ),
                          ),
                        )
                      else if (showCounter)
                        Container(
                          decoration: BoxDecoration(
                            color: lightGray,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: mediumGray),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(Icons.remove,
                                    color: darkCharcoal.withOpacity(0.6)),
                                onPressed: onDecreasePressed,
                                splashRadius: 20,
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 4),
                                child: Row(
                                  children: [
                                    Text(
                                      "Person:",
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    SizedBox(width: 5,),
                                    Text(
                                      "$quantity",
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.add, color: deepOrange),
                                onPressed: onIncreasePressed,
                                splashRadius: 20,
                              ),
                            ],
                          ),
                        )
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void showDescriptionBottomSheet(BuildContext context, String description) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.4,
          minChildSize: 0.2,
          maxChildSize: 0.9,
          builder: (_, controller) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Column(
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: SingleChildScrollView(
                      controller: controller,
                      child: Text(
                        description,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.black87,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        "Close",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  )
                ],
              ),
            );
          },
        );
      },
    );
  }
}
