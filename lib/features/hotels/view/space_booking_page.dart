import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mahakal/features/hotels/view/payment_screen.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import '../../../utill/app_constants.dart';
import '../../../utill/completed_order_dialog.dart';
import '../../../utill/razorpay_screen.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../custom_bottom_bar/bottomBar.dart';
import '../../location/controllers/location_controller.dart';
import '../../profile/controllers/profile_contrroller.dart';
import '../controller/checkavailablity_controller.dart';
import '../controller/checkout_controller.dart';
import '../controller/form_submission_controller.dart';
import '../model/checkavaillblity_model.dart';
import '../model/hotel_details_model.dart';
import '../model/space_details_model.dart';
import '../widgets/hotel_uihelper.dart';
import 'booking_summary_page.dart';
import 'hotel_form_page.dart';
import 'hotels_home_page.dart';

class SpaceBookingPage extends StatefulWidget {
  final SpaceDetailsModel space;
  const SpaceBookingPage({
    super.key,
    required this.space,
  });

  @override
  State<SpaceBookingPage> createState() => _SpaceBookingPageState();
}

class _SpaceBookingPageState extends State<SpaceBookingPage> {
  int days = 0;
  int _adults = 2;
  int _children = 0;
  int totalPrice = 0;
  int pricePerDay = 0;

  List<bool> _selectedExtras = [];
  List<Map<String, dynamic>> selectedExtraPriceList = [];

  DateTimeRange? selectedDateRange;
  DateTime checkInDate = DateTime.now().add(const Duration(days: 1));
  DateTime checkOutDate = DateTime.now().add(const Duration(days: 2));

  String _getMonthName(int month) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return months[month - 1];
  }

  String _formatDate(DateTime date) {
    return '${date.day} ${_getMonthName(date.month)} ${date.year}';
  }

  Widget _buildDateColumn({
    required IconData icon,
    required String label,
    required String date,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.blue, size: 16),
              SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 10,
                ),
              ),
            ],
          ),
          SizedBox(height: 5),
          Text(
            date,
            style: TextStyle(
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildDateSelectionRow(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        await showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (context) => CustomDateRangePicker(
            initialStartDate: checkInDate,
            initialEndDate: checkOutDate,
            onDateRangeSelected: (range) {
              setState(() {
                selectedDateRange = range;
                checkInDate = range.start;
                checkOutDate = range.end;
              });
            },
          ),
        );
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildDateColumn(
            icon: Icons.calendar_today,
            label: 'CHECK-IN',
            date: _formatDate(checkInDate),
            onTap: () async {
              await showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (context) => CustomDateRangePicker(
                  initialStartDate: checkInDate,
                  initialEndDate: checkOutDate,
                  onDateRangeSelected: (range) {
                    setState(() {
                      selectedDateRange = range;
                      checkInDate = range.start;
                      checkOutDate = range.end;
                    });
                  },
                ),
              );
            },
          ),
          Container(
            padding: EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.arrow_forward, color: Colors.blue, size: 20),
          ),
          _buildDateColumn(
            icon: Icons.calendar_today,
            label: 'CHECK-OUT',
            date: _formatDate(checkOutDate),
            onTap: () async {
              await showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (context) => CustomDateRangePicker(
                  initialStartDate: checkInDate,
                  initialEndDate: checkOutDate,
                  onDateRangeSelected: (range) {
                    setState(() {
                      selectedDateRange = range;
                      checkInDate = range.start;
                      checkOutDate = range.end;
                    });
                  },
                ),
              );
            },
          ),
        ],
      ),
    );

    //   Container(
    //   decoration: BoxDecoration(
    //     border: Border.all(color: Colors.grey.shade200),
    //     borderRadius: BorderRadius.circular(16),
    //   ),
    //   child: Row(
    //     children: [
    //       // From Date
    //       Expanded(
    //         child: GestureDetector(
    //           onTap: () => _selectCheckInDate(context),
    //           child: Container(
    //             padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
    //             decoration: BoxDecoration(
    //               border: Border(
    //                 right: BorderSide(color: Colors.grey.shade200),
    //               ),
    //             ),
    //             child: Column(
    //               crossAxisAlignment: CrossAxisAlignment.start,
    //               children: [
    //                 Text(
    //                   'FROM',
    //                   style: TextStyle(
    //                     fontSize: 10,
    //                     fontWeight: FontWeight.w600,
    //                     color: Colors.grey.shade600,
    //                     letterSpacing: 0.5,
    //                   ),
    //                 ),
    //                 const SizedBox(height: 4),
    //                 Row(
    //                   children: [
    //                     Icon(
    //                       Icons.calendar_today,
    //                       size: 14,
    //                       color: Colors.blue.shade400,
    //                     ),
    //                     const SizedBox(width: 6),
    //                     Column(
    //                       crossAxisAlignment: CrossAxisAlignment.start,
    //                       children: [
    //                         Text(
    //                           '${_getMonthName(checkInDate.month)} ${checkInDate.day}',
    //                           style: const TextStyle(
    //                             fontSize: 16,
    //                             fontWeight: FontWeight.w600,
    //                           ),
    //                         ),
    //                         Text(
    //                           '${checkInDate.year}',
    //                           style: TextStyle(
    //                             fontSize: 12,
    //                             color: Colors.grey.shade600,
    //                           ),
    //                         ),
    //                       ],
    //                     ),
    //                   ],
    //                 ),
    //               ],
    //             ),
    //           ),
    //         ),
    //       ),
    //
    //       // Arrow Icon
    //       Container(
    //         padding: const EdgeInsets.all(8),
    //         child: Icon(
    //           Icons.arrow_forward,
    //           size: 18,
    //           color: Colors.blue.shade400,
    //         ),
    //       ),
    //
    //       // To Date
    //       Expanded(
    //         child: GestureDetector(
    //           onTap: () => _selectCheckOutDate(context),
    //           child: Container(
    //             padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
    //             child: Column(
    //               crossAxisAlignment: CrossAxisAlignment.start,
    //               children: [
    //                 Text(
    //                   'TO',
    //                   style: TextStyle(
    //                     fontSize: 10,
    //                     fontWeight: FontWeight.w600,
    //                     color: Colors.grey.shade600,
    //                     letterSpacing: 0.5,
    //                   ),
    //                 ),
    //                 const SizedBox(height: 4),
    //                 Row(
    //                   children: [
    //                     Icon(
    //                       Icons.calendar_today,
    //                       size: 14,
    //                       color: Colors.blue.shade400,
    //                     ),
    //                     const SizedBox(width: 6),
    //                     Column(
    //                       crossAxisAlignment: CrossAxisAlignment.start,
    //                       children: [
    //                         Text(
    //                           '${_getMonthName(checkOutDate.month)} ${checkOutDate.day}',
    //                           style: const TextStyle(
    //                             fontSize: 16,
    //                             fontWeight: FontWeight.w600,
    //                           ),
    //                         ),
    //                         Text(
    //                           '${checkOutDate.year}',
    //                           style: TextStyle(
    //                             fontSize: 12,
    //                             color: Colors.grey.shade600,
    //                           ),
    //                         ),
    //                       ],
    //                     ),
    //                   ],
    //                 ),
    //               ],
    //             ),
    //           ),
    //         ),
    //       ),
    //     ],
    //   ),
    // );
  }

  bool isSameDate(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  void _showTopSnackbarInDialog(BuildContext context, String message) {
    // Get the OverlayState for THIS dialog
    final overlay = Overlay.of(context);
    if (overlay == null) return;

    // Create overlay entry
    OverlayEntry overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: 50, // Adjust this value as needed for position
        left: 20,
        right: 20,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 10,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Row(
              children: [
                Icon(Icons.error_outline, color: Colors.white, size: 24),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    message,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    // Insert the overlay
    overlay.insert(overlayEntry);

    // Auto remove after 3 seconds
    Future.delayed(Duration(seconds: 3), () {
      if (overlayEntry.mounted) {
        overlayEntry.remove();
      }
    });
  }

  @override
  void initState() {
    super.initState();
    final extraPrices = widget.space.data?.space?.extraPrice ?? [];
    _selectedExtras = List.generate(extraPrices.length, (_) => false);
    _recalculatePrice(); // initial calculation
  }

  void _recalculatePrice() {
    // Parse price safely
    final rawPrice = widget.space.data?.space?.price ?? '0';
    final cleanedPrice = rawPrice.replaceAll(RegExp(r'[^0-9.]'), '');
    pricePerDay = double.tryParse(cleanedPrice)?.round() ?? 0;

    // Calculate days (INCLUSIVE)
    if (checkOutDate.isAfter(checkInDate) ||
        checkOutDate.isAtSameMomentAs(checkInDate)) {
      days = checkOutDate.difference(checkInDate).inDays;
    } else {
      days = 1;
    }

    if (days <= 0) days = 1;

    // Total price
    totalPrice = pricePerDay * days;

    debugPrint("Price/day: $pricePerDay");
    debugPrint("Days: $days");
    debugPrint("Total: $totalPrice");
  }

  @override
  Widget build(BuildContext context) {
    _recalculatePrice();

    /// Extra prices Calculatiions
    int priceForPercent = 0;
    final extraPrices = widget.space.data?.space?.extraPrice ?? [];
    final enableExtraPrice = widget.space.data?.space?.enableExtraPrice == 1;
    final int maxGuests = widget.space.data?.space?.maxGuests ?? 0;

    int extrasTotal = 0;
    for (int i = 0; i < extraPrices.length; i++) {
      if (_selectedExtras[i]) {
        final service = extraPrices[i];
        final priceStr = extraPrices[i].price ?? '0';
        final price = int.tryParse(priceStr) ?? 0;
        final type = service.type ?? 'fixed';
        final perPerson = service.perPerson == 'on';

        int extraAmount = 0;
        if (type == "per_day") {
          extraAmount = price * (checkOutDate.difference(checkInDate).inDays);
        } else if (type == "one_time") {
          extraAmount = price;
        } else {
          extraAmount = price;
        }

        if (perPerson) {
          extraAmount *= _adults + _children;
        }

        extrasTotal += extraAmount;
      }
    }

    priceForPercent = totalPrice + extrasTotal;
    print("Price of Total ${priceForPercent}");


    /// Extra Service fee Calculations
    /// Extra Service fee Calculations
    final extraService = widget.space.data?.space?.serviceFee ?? [];
    final enableServiceFee =
        widget.space.data?.space?.enableServiceFee == 1;

    int includeServiceTotal = 0;

    for (int i = 0; i < extraService.length; i++) {
      final service = extraService[i];

      final priceStr = service.price ?? '0';
      final price = int.tryParse(priceStr) ?? 0;

      final unit = service.unit ?? 'fixed';
      final type = service.type ?? 'one_time';
      final perPerson = service.perPerson == 'on';

      int extraAmount = 0;

      /// STEP 1: Base Amount Calculate Karo (without person multiply)

      if (unit == "percent") {
        // percent always base price pe lagega
        extraAmount = ((priceForPercent * price) / 100).round();
      } else if (type == "per_day") {
        extraAmount =
            price * checkOutDate.difference(checkInDate).inDays;
      } else if (type == "per_hour") {
        extraAmount =
            price * checkOutDate.difference(checkInDate).inHours;
      } else {
        // one_time
        extraAmount = price;
      }

      /// STEP 2: Agar perPerson hai to yaha multiply karo (only once)
      if (perPerson) {
        extraAmount *= (_adults + _children);
      }

      includeServiceTotal += extraAmount;
    }

    final serviceFeeTotal =
    enableServiceFee ? includeServiceTotal : 0;

    print("Correct Service Fee Total $serviceFeeTotal");

    /// Grand Total
    final grandTotal = totalPrice + extrasTotal + serviceFeeTotal;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Booking Details', style: AppTextStyles.heading4),
        automaticallyImplyLeading: false,
        leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(Icons.arrow_back_ios)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hotel Summary
            _buildHotelSummary(),
            const SizedBox(height: 15),

            // Dates and Guests
            _spaceAvailability(maxGuests),
            const SizedBox(height: 15),

            // Extra Services (if enabled and there are booked rooms)
            if (enableExtraPrice && extraPrices.isNotEmpty)
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Extra Prices',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[700],
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...extraPrices.asMap().entries.map((entry) {
                      final index = entry.key;
                      final extra = entry.value;
                      final name = extra.name ?? '';
                      final type = extra.type ?? '';
                      final perPersonExtra = extra.perPerson;
                      final priceStr = extra.price ?? '0';
                      final price = int.tryParse(priceStr) ?? 0;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: _selectedExtras[index]
                              ? Colors.blue.withOpacity(0.05)
                              : Colors.grey[50],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: _selectedExtras[index]
                                ? Colors.blue.withOpacity(0.3)
                                : Colors.grey[200]!,
                            width: _selectedExtras[index] ? 1.5 : 1,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Checkbox(
                                  value: _selectedExtras[index],
                                  onChanged: (value) {
                                    setState(() {
                                      _selectedExtras[index] = value ?? false;

                                      final extraItem = {
                                        "name": extra.name ?? "",
                                        "price": extra.price ?? "0",
                                        "type": extra.type ?? "one_time",
                                        "number": "0",
                                        "enable": "1",
                                        "price_html": "\$${extra.price ?? "0"}",
                                        "price_type": extra.perPerson,
                                      };

                                      if (_selectedExtras[index]) {
                                        // ADD if not already exists
                                        final exists =
                                            selectedExtraPriceList.any(
                                          (e) => e["name"] == extraItem["name"],
                                        );
                                        if (!exists) {
                                          selectedExtraPriceList.add(extraItem);
                                        }
                                      } else {
                                        // REMOVE on uncheck
                                        selectedExtraPriceList.removeWhere(
                                          (e) => e["name"] == extraItem["name"],
                                        );
                                      }
                                    });
                                  },
                                ),
                                const SizedBox(width: 8),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      perPersonExtra == "on"
                                          ? "${name} /Guest"
                                          : name,
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    SizedBox(
                                      height: 5,
                                    ),
                                    Text(
                                      type.toUpperCase(),
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.red,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),

                            Text(
                              formatIndianCurrency(
                                (type == "per_day"
                                        ? (perPersonExtra == "on"
                                            ? price * days * _adults
                                            : price * days)
                                        : (perPersonExtra == "on"
                                            ? price * _adults
                                            : price))
                                    .toString(),
                              ),
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.blue[700],
                              ),
                            ),

                            // Text(
                            //   '${formatIndianCurrency(price.toString())}',
                            //   style: TextStyle(
                            //     fontSize: 14,
                            //     fontWeight: FontWeight.w600,
                            //     color: Colors.blue[700],
                            //   ),
                            // ),
                          ],
                        ),
                      );
                    }).toList(),
                    if (extrasTotal > 0)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Extra Services Total',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                              Text(
                                '${formatIndianCurrency(extrasTotal.toString())}',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.blue[700],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),

            // Extra Included Services (if enabled and there are booked rooms)
            if (enableServiceFee && extraService.isNotEmpty)
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Extra Services',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[700],
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...extraService.asMap().entries.map((entry) {
                      final extra = entry.value;
                      final name = extra.name ?? '';
                      final priceStr = extra.price ?? '0';
                      final price = int.tryParse(priceStr) ?? 0;
                      final unitType = extra.unit ?? '';
                      final perPerson = extra.perPerson ?? '0';

                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Colors.blue.withOpacity(0.3),
                            width: 1.5,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const SizedBox(width: 8),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      perPerson == "on"
                                          ? "${name} /guest"
                                          : name,
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            Text(
                              "₹${(
                                  unitType == "percent"
                                      ? (perPerson == "on"
                                      ? ((priceForPercent * price) / 100) * _adults
                                      : ((priceForPercent * price) / 100))
                                      : (perPerson == "on"
                                      ? price * _adults
                                      : price)
                              ).round()}",
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.blue[700],
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                    if (includeServiceTotal > 0)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Extra Services Total',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                              Text(
                                '${formatIndianCurrency(includeServiceTotal.toString())}',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.blue[700],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),

            const Divider(height: 20),

            // Grand Total
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.green.withOpacity(0.3),
                  width: 2,
                ),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Grand Total',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      Text(
                        '${formatIndianCurrency(grandTotal.toString())}',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.green[800],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // // Price Breakdown (only when rooms are selected)
            // Container(
            //   margin: const EdgeInsets.only(bottom: 16),
            //   child: Column(
            //     children: [
            //       Row(
            //         mainAxisAlignment: MainAxisAlignment.center,
            //         children: [
            //           Text(
            //             'Breakdown: ',
            //             style: TextStyle(
            //               fontSize: 13,
            //               color: Colors.grey[600],
            //             ),
            //           ),
            //           Text(
            //             '${formatIndianCurrency(totalPrice.toString())} (Days)',
            //             style: TextStyle(
            //               fontSize: 13,
            //               color: Colors.grey[600],
            //             ),
            //           ),
            //           if (extrasTotal > 0)
            //             Text(
            //               ' + ${formatIndianCurrency(extrasTotal.toString())} (Extras)',
            //               style: TextStyle(
            //                 fontSize: 13,
            //                 color: Colors.grey[600],
            //               ),
            //             ),
            //           if (serviceFeeTotal > 0)
            //             Text(
            //               ' + ${formatIndianCurrency(serviceFeeTotal.toInt().toString())} (Service)',
            //               style: TextStyle(
            //                 fontSize: 13,
            //                 color: Colors.grey[600],
            //               ),
            //             ),
            //         ],
            //       ),
            //     ],
            //   ),
            // ),
          ],
        ),
      ),
      bottomNavigationBar: Consumer<CheckOutController>(
        builder: (BuildContext context, checkOutController, Widget? child) {
          return Container(
            height: 80,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 15,
                  offset: const Offset(0, -2),
                ),
              ],
              border: Border(
                top: BorderSide(
                  color: Colors.grey[300]!,
                  width: 0.5,
                ),
              ),
            ),
            child: ElevatedButton(
              onPressed: () async {
                /// 1. Prepare Selected Extras
                // final List<HotelExtraPrice> selectedExtraList = [];
                // for (int i = 0; i < extraPrices.length; i++) {
                //   if (_selectedExtras[i]) {
                //     selectedExtraList.add(extraPrices[i]);
                //   }
                // }

                /// 2. Debug Logs
                print('=== BOOKING DETAILS ===');
                print('Check-in Date      : ${checkInDate}');
                print('Check-out Date     : ${checkOutDate}');
                print('Adults             : ${_adults}');
                print('Children           : ${_children}');
                print('Base Price         : ${pricePerDay}');
                print(
                    'Extras Total       : ${formatIndianCurrency(extrasTotal)}');
                print(
                    'Service Fee        : ${formatIndianCurrency(serviceFeeTotal)}');
                print(
                    'Grand Total        : ${formatIndianCurrency(grandTotal)}');
                print('Selected Extras    : $selectedExtraPriceList');

                /// 3. Call the API
                final bool isSuccess = await checkOutController.checkOutFetch(
                    context,
                    serviceId: widget.space.data!.space!.id,
                    serviceType: "space",
                    checkInDate: checkInDate,
                    checkOutDate: checkOutDate,
                    adults: _adults,
                    children: _children,
                    extraPrices: selectedExtraPriceList,
                    grandTotal: grandTotal,
                    isSpace: true,
                    bookedRooms: []);

                /// 4. Handle the API response
                if (isSuccess) {
                  // Use root navigator to push new screen
                  Navigator.of(context, rootNavigator: true).push(
                    MaterialPageRoute(
                      builder: (context) => HotelForm(grandTotal, "", false),
                    ),
                  );
                } else {
                  print("Showing custom snackbar in bottom sheet");

                  // Get error message
                  String errorMessage = '';
                  if (checkOutController.checkAvailablityModel?.message !=
                      null) {
                    errorMessage =
                        checkOutController.checkAvailablityModel!.message!;
                  } else if (checkOutController.error != null) {
                    errorMessage = checkOutController.error!;
                  } else {
                    errorMessage = 'Rooms not available. Please try again.';
                  }

                  // Show CUSTOM snackbar IN THE BOTTOM SHEET
                  _showTopSnackbarInDialog(context, errorMessage);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              ),
              child: checkOutController.isLoading
                  ? const Center(
                child: CircularProgressIndicator(color: Colors.white),
              )
                  :  Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Stack(
                    children: [
                      const Icon(
                        Icons.paypal,
                        size: 24,
                      ),
                    ],
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Proceed to pay',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.2,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

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

  Widget _buildHotelSummary() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // Hotel Image
          Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              image: widget.space.data?.space?.bannerImage != null
                  ? DecorationImage(
                      image:
                          NetworkImage(widget.space.data!.space!.bannerImage),
                      fit: BoxFit.cover,
                    )
                  : null,
              color: AppColors.lightGray,
            ),
            child: widget.space.data?.space?.bannerImage == null
                ? Icon(
                    Icons.hotel_rounded,
                    size: 30,
                    color: Colors.grey[400],
                  )
                : null,
          ),
          const SizedBox(width: 16),

          // Hotel Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Hotel Name
                Text(
                  "${widget.space.data?.space?.title ?? "Space Name"}",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),

                // Star Rating
                Row(
                  children: [
                    // Stars
                    Row(
                      children: List.generate(5, (index) {
                        double rating = double.tryParse(widget
                                    .space.data?.space?.reviewScore
                                    .toString() ??
                                '0') ??
                            0.0;
                        return Icon(
                          Icons.star_rounded,
                          size: 16,
                          color:
                              index < rating ? Colors.blue : Colors.grey[300],
                        );
                      }),
                    ),

                    //const SizedBox(width: 6),

                    // Rating Number
                    // Text(
                    //   "${widget.hotel.data?.hotel?.starRate ?? "4.0"}",
                    //   style: TextStyle(
                    //     fontSize: 14,
                    //     fontWeight: FontWeight.w600,
                    //     color: Colors.grey[800],
                    //   ),
                    // ),

                    const SizedBox(width: 4),

                    // Review Count
                    Text(
                      "(${widget.space.data?.reviews?.data.length ?? 0})",
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Location
                Row(
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      size: 14,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        "${widget.space.data?.space?.address ?? "Location"}",
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[700],
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _spaceAvailability(int maxGuest) {
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
          Row(
            children: [
              Text('Available from', style: AppTextStyles.heading4),
              SizedBox(
                width: 5,
              ),
              Text(formatIndianCurrency("${widget.space.data?.space?.price}"),
                  style: AppTextStyles.heading4),
            ],
          ),
          const SizedBox(height: 16),

          // Date Selection Row
          Column(
            children: [
              buildDateSelectionRow(context),

              // Row(
              //   children: [
              //     // Check-in Date
              //     Expanded(
              //       child: Column(
              //         crossAxisAlignment: CrossAxisAlignment.start,
              //         children: [
              //           Text('Check-in', style: AppTextStyles.captionSmall),
              //           const SizedBox(height: 4),
              //           GestureDetector(
              //             onTap: () => _selectCheckInDate(context),
              //             child: Container(
              //               padding: const EdgeInsets.all(12),
              //               decoration: BoxDecoration(
              //                 border: Border.all(color: AppColors.lightGray),
              //                 borderRadius: BorderRadius.circular(12),
              //               ),
              //               child: Row(
              //                 children: [
              //                   Icon(Icons.calendar_today,size: 20, color: AppColors.gray),
              //                   const SizedBox(width: 4),
              //                   Text(
              //                     _formatDate(checkInDate),
              //                     style: AppTextStyles.bodyMedium.copyWith(
              //                       fontWeight: FontWeight.w600,
              //                       color: Colors.black,
              //                     ),
              //                   ),
              //                 ],
              //               ),
              //             ),
              //           ),
              //         ],
              //       ),
              //     ),
              //     const SizedBox(width: 16),
              //
              //     // Check-out Date
              //     Expanded(
              //       child: Column(
              //         crossAxisAlignment: CrossAxisAlignment.start,
              //         children: [
              //           Text('Check-out', style: AppTextStyles.captionSmall),
              //           const SizedBox(height: 4),
              //           GestureDetector(
              //             onTap: () => _selectCheckOutDate(context),
              //             child: Container(
              //               padding: const EdgeInsets.all(12),
              //               decoration: BoxDecoration(
              //                 border: Border.all(color: AppColors.lightGray),
              //                 borderRadius: BorderRadius.circular(12),
              //               ),
              //               child: Row(
              //                 children: [
              //                   Icon(Icons.calendar_today,
              //                       size: 20, color: AppColors.gray),
              //                   const SizedBox(width: 4),
              //                   Text(
              //                     _formatDate(checkOutDate),
              //                     style: AppTextStyles.bodyMedium.copyWith(
              //                       fontWeight: FontWeight.w600,
              //                       color: Colors.black,
              //                     ),
              //                   ),
              //                 ],
              //               ),
              //             ),
              //           ),
              //         ],
              //       ),
              //     ),
              //   ],
              // ),

              Container(
                margin: const EdgeInsets.only(bottom: 16, top: 12),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.blue.withOpacity(0.2),
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Price per day',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '₹$pricePerDay × $days day${days > 1 ? 's' : ''}',
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          formatIndianCurrency(totalPrice.toString()),
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Guest Counters
          Row(
            children: [
              Expanded(
                child: _buildCounter(
                  'Adults',
                  _adults,
                  onIncrement: () {
                    if (_adults + _children < maxGuest) {
                      setState(() => _adults++);
                    }
                  },
                  onDecrement: () {
                    if (_adults > 1) {
                      setState(() => _adults--);
                    }
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildCounter(
                  'Children',
                  _children,
                  onIncrement: () {
                    if (_adults + _children < maxGuest) {
                      setState(() => _children++);
                    }
                  },
                  onDecrement: () {
                    if (_children > 0) {
                      setState(() => _children--);
                    }
                  },
                ),
              ),
            ],
          ),

          //  Show only when limit reached
          if (_adults + _children == maxGuest)
            Container(
              margin: const EdgeInsets.only(top: 16),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.red),
                color: AppColors.red.withOpacity(0.05),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    color: AppColors.red,
                    size: 18,
                  ),
                  SizedBox(
                    width: 5,
                  ),
                  Text(
                    "Only $maxGuest guests are allowed",
                    style: const TextStyle(
                      color: AppColors.red,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCounter(
    String title,
    int value, {
    required VoidCallback onIncrement,
    required VoidCallback onDecrement,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppTextStyles.captionSmall),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
          ),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.lightGray),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: onDecrement,
                icon: Container(
                  decoration: BoxDecoration(
                    color: AppColors.lightGray,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(Icons.remove, size: 18),
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              Text(
                '$value',
                style: AppTextStyles.bodyMedium
                    .copyWith(fontWeight: FontWeight.w600),
              ),
              IconButton(
                onPressed: onIncrement,
                icon: Container(
                  decoration: BoxDecoration(
                    color: AppColors.lightGray,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(Icons.add, size: 18),
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
