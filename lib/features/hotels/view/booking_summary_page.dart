import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../utill/app_constants.dart';
import '../../../utill/completed_order_dialog.dart';
import '../../../utill/razorpay_screen.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../custom_bottom_bar/bottomBar.dart';
import '../../location/controllers/location_controller.dart';
import '../../profile/controllers/profile_contrroller.dart';
import '../controller/checkout_controller.dart';
import '../controller/form_submission_controller.dart';
import '../controller/hotel_user_controller.dart';
import '../model/checkavaillblity_model.dart';
import '../model/hotel_details_model.dart';
import '../widgets/hotel_uihelper.dart';
import 'hotel_form_page.dart';

class BookingSummaryDialog extends StatefulWidget {
  final List<Map<String, dynamic>> bookedRooms;
  final HotelDetailsModel hotel;
  final List<Room> roomsFromAPI;
  int adults;
  int children;
  DateTime checkInDate;
  DateTime checkOutDate;
  //final Function(List<HotelExtraPrice> selectedExtras, dynamic grandTotal) onProceedToPayment;

  BookingSummaryDialog({
    Key? key,
    required this.bookedRooms,
    required this.hotel,
    //required this.onProceedToPayment,
    required this.checkInDate,
    required this.checkOutDate,
    required this.adults,
    required this.children,
    required this.roomsFromAPI,
  }) : super(key: key);

  @override
  State<BookingSummaryDialog> createState() => _BookingSummaryDialogState();
}

class _BookingSummaryDialogState extends State<BookingSummaryDialog> {
  List<bool> _selectedExtras = [];
  List<Map<String, dynamic>> selectedExtraPriceList = [];
  List<Map<String, dynamic>> allRooms = [];

  String token = "";

  @override
  void initState() {
    super.initState();
    final extraPrices = widget.hotel.data?.hotel?.extraPrice ?? [];
    _selectedExtras = List.generate(extraPrices.length, (index) => false);
    _prepareAllRoomsForApi();

    final hotelUserController = Provider.of<HotelUserController>(context, listen: false);
    token = hotelUserController.hotelUserModel?.data?.token ?? '';
  }

  void _prepareAllRoomsForApi() {
    final hotelRooms = widget.roomsFromAPI!;

    print('Api Rooms ${hotelRooms}');
    print('Booked Rooms ${widget.bookedRooms}');

    allRooms = hotelRooms.map<Map<String, String>>((room) {
      final bookedRoom = widget.bookedRooms.firstWhere(
        (b) => b['room_id'].toString() == room.id.toString(),
        orElse: () => {},
      );

      return {
        "id": room.id.toString(),
        "number_selected": bookedRoom.isNotEmpty
            ? (bookedRoom['total_room'] ?? 0).toString()
            : "0",
      };
    }).toList();

    print('=== FORMATTED ALL ROOMS (API) ===');
    print(allRooms);

    setState(() {});
  }

  final DateFormat _dateFormatter = DateFormat('dd-MM-yyyy');

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
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                const Icon(Icons.error_outline, color: Colors.white, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    message,
                    style: const TextStyle(
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
    Future.delayed(const Duration(seconds: 3), () {
      if (overlayEntry.mounted) {
        overlayEntry.remove();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final hasBookedRooms = widget.bookedRooms.isNotEmpty;

    // Calculate totals
    int totalBookedRooms = 0;
    int basePrice = 0;
    int priceForPercent = 0;
    final roomBreakdown = <Map<String, dynamic>>[];

    if (hasBookedRooms) {
      for (var room in widget.bookedRooms) {
        int rooms = room['total_room'] ?? 0;
        int price = room['room_price'] ?? 0;
        int total = rooms * price;

        totalBookedRooms += rooms;
        basePrice += total;

        roomBreakdown.add({
          'title': room['room_title'],
          'rooms': rooms,
          'price': price,
          'total': total,
        });
      }
    }

    /// Calculation for  Extra prices
    final enableExtraPrice = widget.hotel.data?.hotel?.enableExtraPrice == 1;
    final extraPrices = widget.hotel.data?.hotel?.extraPrice ?? [];

    // Calculate extras total
    int extrasTotal = 0;
    for (int i = 0; i < extraPrices.length; i++) {
      if (_selectedExtras[i]) {
        final priceStr = extraPrices[i].price ?? '0';
        final price = int.tryParse(priceStr) ?? 0;
        final type = extraPrices[i].type;
        final perPersonExtra = extraPrices[i].perPerson == "on";

        int extraAmount = 0;
        if (type == "per_day") {
          extraAmount = price *
              (widget.checkOutDate.difference(widget.checkInDate).inDays);
        } else if (type == "one_time") {
          extraAmount = price;
        } else {
          extraAmount = price;
        }

        if (perPersonExtra) {
          extraAmount *= widget.adults + widget.children;
        }

        extrasTotal += extraAmount;
      }
    }

    priceForPercent = basePrice + extrasTotal;
    print("Price of Total ${priceForPercent}");

    /// Calculation for Extra Service Fee
    final enableServiceFee = widget.hotel.data?.hotel?.enableServiceFee == 1;
    final extraService = widget.hotel.data?.hotel?.serviceFee ?? [];

    int includeServiceTotal = 0;

    for (int i = 0; i < extraService.length; i++) {
      final service = extraService[i];

      final int price = int.tryParse(service.price ?? '0') ?? 0;
      final String unit = service.unit ?? 'fixed';
      final String type = service.type ?? 'one_time';
      final bool perPerson = service.perPerson == 'on';

      int serviceAmount = 0;

      int totalPersons = widget.adults + widget.children;
      int totalNights =
          widget.checkOutDate.difference(widget.checkInDate).inDays;

      ///  STEP 1: Percent logic
      if (unit == "percent") {
        //"₹${(((priceForPercent * price) / 100) * widget.adults).round()}"
        serviceAmount = ((priceForPercent * price) / 100).round();
        //serviceAmount = (((priceForPercent * price) / 100) * widget.adults).round();
      }

      ///  STEP 2: Fixed logic
      else {
        serviceAmount = price;
      }

      ///  STEP 3: Type logic
      if (type == "per_day") {
        serviceAmount *= totalNights;
      }

      ///  STEP 4: Per person logic
      if (perPerson) {
        serviceAmount *= totalPersons;
      }

      includeServiceTotal += serviceAmount;

      print("Service: ${service.name} => $serviceAmount");
    }

    print("Total Service Amount: $includeServiceTotal");

    final serviceFeeTotal = enableServiceFee ? includeServiceTotal : 0;

    //final grandTotal = basePrice + extrasTotal + serviceFeeTotal.toInt();
    final grandTotal = priceForPercent + serviceFeeTotal.toInt();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20), topRight: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        children: [
          const SizedBox(
            height: 40,
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.withOpacity(0.08),
                    blurRadius: 15,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Back Button with stylish design
                  InkWell(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.grey[200]!,
                          width: 1.5,
                        ),
                      ),
                      child: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: Colors.black87,
                        size: 20,
                      ),
                    ),
                  ),

                  // Title with gradient
                  Expanded(
                    child: Center(
                      child: Column(
                        children: [
                          Text(
                            'Booking Summary',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                              fontSize: 16,
                              letterSpacing: -0.5,
                              shadows: [
                                Shadow(
                                  color: Colors.blue.withOpacity(0.1),
                                  blurRadius: 3,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 2),
                          Container(
                            width: 40,
                            height: 3,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [
                                  Colors.blue,
                                  Colors.blue,
                                ],
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              ),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Rooms Badge (only show if rooms booked)
                  if (hasBookedRooms)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.blue,
                            Colors.blue.shade400,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blue.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.meeting_room_rounded,
                            color: Colors.white,
                            size: 14,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '$totalBookedRooms',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Room${totalBookedRooms > 1 ? 's' : ''}',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    // Placeholder for alignment
                    const SizedBox(width: 60),
                ],
              ),
            ),
          ),
          hasBookedRooms
              ? Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Hotel Check In / Check Out
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Colors.white,
                                Colors.grey[50]!,
                              ],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 20,
                                offset: const Offset(0, 4),
                              ),
                            ],
                            border: Border.all(
                              color: Colors.grey[100]!,
                              width: 1.5,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Hotel Name and Location
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 4,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          Colors.blue,
                                          Colors.blue.shade400,
                                        ],
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                      ),
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '${widget.hotel.data?.hotel?.title}',
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black87,
                                            letterSpacing: -0.3,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.location_on_outlined,
                                              size: 14,
                                              color: Colors.grey[500],
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              '${widget.hotel.data?.hotel?.location?.name}',
                                              style: TextStyle(
                                                fontSize: 13,
                                                color: Colors.grey[600],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),

                              // Booking Details Grid
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: Colors.grey[200]!,
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    // Check In / Check Out Row
                                    Padding(
                                      padding: const EdgeInsets.all(16),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  children: [
                                                    Container(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          horizontal: 10,
                                                          vertical: 4),
                                                      decoration: BoxDecoration(
                                                        color: Colors.blue
                                                            .withOpacity(0.1),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8),
                                                      ),
                                                      child: Row(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        children: [
                                                          Icon(
                                                            Icons.login_rounded,
                                                            size: 12,
                                                            color: Colors
                                                                .blue.shade600,
                                                          ),
                                                          const SizedBox(
                                                              width: 4),
                                                          Text(
                                                            'CHECK IN',
                                                            style: TextStyle(
                                                              fontSize: 10,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                              color: Colors.blue
                                                                  .shade600,
                                                              letterSpacing:
                                                                  0.5,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(height: 8),
                                                Text(
                                                  "${_dateFormatter.format(widget.checkInDate)}",
                                                  style: const TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w600,
                                                    color: Colors.black87,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Container(
                                            width: 30,
                                            height: 1,
                                            color: Colors.grey[300],
                                            child: Center(
                                              child: Icon(
                                                Icons.arrow_forward_rounded,
                                                size: 16,
                                                color: Colors.grey[400],
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.end,
                                              children: [
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.end,
                                                  children: [
                                                    Container(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          horizontal: 10,
                                                          vertical: 4),
                                                      decoration: BoxDecoration(
                                                        color: Colors.green
                                                            .withOpacity(0.1),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8),
                                                      ),
                                                      child: Row(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        children: [
                                                          Icon(
                                                            Icons
                                                                .logout_rounded,
                                                            size: 12,
                                                            color: Colors
                                                                .green.shade600,
                                                          ),
                                                          const SizedBox(
                                                              width: 4),
                                                          Text(
                                                            'CHECK OUT',
                                                            style: TextStyle(
                                                              fontSize: 10,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                              color: Colors
                                                                  .green
                                                                  .shade600,
                                                              letterSpacing:
                                                                  0.5,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(height: 8),
                                                Text(
                                                  "${_dateFormatter.format(widget.checkOutDate)}",
                                                  style: const TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w600,
                                                    color: Colors.black87,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                    // Divider
                                    Container(
                                      height: 1,
                                      margin: const EdgeInsets.symmetric(
                                          horizontal: 16),
                                      color: Colors.grey[200],
                                    ),

                                    // Nights and Adults
                                    Padding(
                                      padding: const EdgeInsets.all(8),
                                      child: Row(
                                        children: [
                                          /// ---------------- NIGHTS ----------------
                                          Expanded(
                                            child: Container(
                                              padding: const EdgeInsets.all(12),
                                              decoration: BoxDecoration(
                                                color: Colors.blue
                                                    .withOpacity(0.05),
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              child: Column(
                                                children: [
                                                  const Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      Icon(
                                                        Icons.nightlight_round,
                                                        size: 14,
                                                        color:
                                                            Colors.blue,
                                                      ),
                                                      SizedBox(width: 2),
                                                      Text(
                                                        'NIGHTS',
                                                        style: TextStyle(
                                                          fontSize: 10,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          color:
                                                              Colors.blue,
                                                          letterSpacing: 0.5,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  const SizedBox(height: 6),
                                                  Builder(
                                                    builder: (context) {
                                                      int nights = 0;
                                                      try {
                                                        nights = widget
                                                            .checkOutDate
                                                            .difference(widget
                                                                .checkInDate)
                                                            .inDays;
                                                      } catch (e) {
                                                        nights = 0;
                                                      }

                                                      return Text(
                                                        '$nights',
                                                        style: const TextStyle(
                                                          fontSize: 22,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color:
                                                              Colors.blue,
                                                        ),
                                                      );
                                                    },
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 5),

                                          /// ---------------- ADULTS ----------------
                                          Expanded(
                                            child: Container(
                                              padding: const EdgeInsets.all(12),
                                              decoration: BoxDecoration(
                                                color: Colors.blue
                                                    .withOpacity(0.05),
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              child: Column(
                                                children: [
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      Icon(
                                                        Icons.person_outline,
                                                        size: 14,
                                                        color: Colors
                                                            .blue.shade600,
                                                      ),
                                                      const SizedBox(width: 2),
                                                      Text(
                                                        'ADULTS',
                                                        style: TextStyle(
                                                          fontSize: 10,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          color: Colors
                                                              .blue.shade600,
                                                          letterSpacing: 0.5,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  const SizedBox(height: 6),
                                                  Text(
                                                    '${widget.adults}',
                                                    style: TextStyle(
                                                      fontSize: 22,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color:
                                                          Colors.blue.shade600,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 5),

                                          /// ---------------- CHILDREN ----------------
                                          Expanded(
                                            child: Container(
                                              padding: const EdgeInsets.all(12),
                                              decoration: BoxDecoration(
                                                color: Colors.green
                                                    .withOpacity(0.05),
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              child: Column(
                                                children: [
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      Icon(
                                                        Icons.child_care,
                                                        size: 14,
                                                        color: Colors
                                                            .green.shade600,
                                                      ),
                                                      const SizedBox(width: 2),
                                                      Text(
                                                        'CHILDREN',
                                                        style: TextStyle(
                                                          fontSize: 10,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          color: Colors
                                                              .green.shade600,
                                                          letterSpacing: 0.5,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  const SizedBox(height: 6),
                                                  Text(
                                                    '${widget.children}',
                                                    style: TextStyle(
                                                      fontSize: 22,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color:
                                                          Colors.green.shade600,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                              ),
                              const SizedBox(height: 16),
                            ],
                          ),
                        ),

                        // Selected Rooms Breakdown
                        Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey[50],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Selected Rooms',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                  Text(
                                    '${widget.bookedRooms.length} Type${widget.bookedRooms.length > 1 ? 's' : ''}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[500],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              ...roomBreakdown.map((room) {
                                final title = room['title'] ?? '';
                                final rooms = room['rooms'] ?? 0;
                                final price = room['price'] ?? 0;
                                final total = room['total'] ?? 0;

                                return Container(
                                  margin: const EdgeInsets.only(bottom: 8),
                                  child: Column(
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  title,
                                                  style: const TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w500,
                                                    color: Colors.black87,
                                                  ),
                                                ),
                                                Text(
                                                  '${formatIndianCurrency(price.toString())} × $rooms room${rooms > 1 ? 's' : ''}',
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.grey[600],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Text(
                                            '${formatIndianCurrency(total.toString())}',
                                            style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.black87,
                                            ),
                                          ),
                                        ],
                                      ),
                                      if (roomBreakdown.last != room)
                                        const Divider(height: 8),
                                    ],
                                  ),
                                );
                              }).toList(),

                              // Rooms Total
                              Container(
                                margin: const EdgeInsets.only(top: 8),
                                padding: const EdgeInsets.only(top: 8),
                                decoration: BoxDecoration(
                                  border: Border(
                                    top: BorderSide(
                                      color: Colors.grey[300]!,
                                      width: 1,
                                    ),
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      'Rooms Total',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    Text(
                                      '${formatIndianCurrency(basePrice.toString())}',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blue,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Base Price Summary
                        if (hasBookedRooms)
                          Container(
                            margin: const EdgeInsets.only(bottom: 16),
                            padding: const EdgeInsets.all(12),
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
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Base Price',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      ],
                                    ),
                                    Text(
                                      '${formatIndianCurrency(basePrice.toString())}',
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blue,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                        // Extra Prices (if enabled and there are booked rooms)
                        if (hasBookedRooms &&
                            enableExtraPrice &&
                            extraPrices.isNotEmpty)
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
                                  final priceStr = extra.price ?? '0';
                                  final perPerson = extra.perPerson;
                                  final type = extra.type;
                                  final price = int.tryParse(priceStr) ?? 0;
                                  int totalNights = widget.checkOutDate
                                      .difference(widget.checkInDate)
                                      .inDays;

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
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            Checkbox(
                                              value: _selectedExtras[index],
                                              onChanged: (value) {
                                                setState(() {
                                                  _selectedExtras[index] =
                                                      value ?? false;

                                                  final extraItem = {
                                                    "name": extra.name ?? "",
                                                    "price": extra.price ?? "0",
                                                    "type": extra.type ??
                                                        "one_time",
                                                    "number": "0",
                                                    "enable": "1",
                                                    "price_html":
                                                        "\$${extra.price ?? "0"}",
                                                    "price_type":
                                                        extra.perPerson,
                                                  };

                                                  if (_selectedExtras[index]) {
                                                    // ADD if not already exists
                                                    final exists =
                                                        selectedExtraPriceList
                                                            .any(
                                                      (e) =>
                                                          e["name"] ==
                                                          extraItem["name"],
                                                    );
                                                    if (!exists) {
                                                      selectedExtraPriceList
                                                          .add(extraItem);
                                                    }
                                                  } else {
                                                    // REMOVE on uncheck
                                                    selectedExtraPriceList
                                                        .removeWhere(
                                                      (e) =>
                                                          e["name"] ==
                                                          extraItem["name"],
                                                    );
                                                  }
                                                });
                                              },
                                            ),
                                            const SizedBox(width: 8),
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  perPerson == "on"
                                                      ? "$name /Guest"
                                                      : name,
                                                  style: const TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w500,
                                                    color: Colors.black87,
                                                  ),
                                                ),
                                                const SizedBox(
                                                  height: 5,
                                                ),
                                                Text(
                                                  type.toUpperCase(),
                                                  style: const TextStyle(
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
                                                    ? (perPerson == "on"
                                                        ? price *
                                                            totalNights *
                                                            widget.adults
                                                        : price * totalNights)
                                                    : (perPerson == "on"
                                                        ? price * widget.adults
                                                        : price))
                                                .toString(),
                                          ),
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
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            'Extra Total',
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
                        if (hasBookedRooms &&
                            enableServiceFee &&
                            extraService.isNotEmpty)
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
                                  final unitType = extra.unit ?? '';
                                  final priceStr = extra.price ?? '0';
                                  final perPerson = extra.perPerson ?? '0';
                                  final price = int.tryParse(priceStr) ?? 0;

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
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            const SizedBox(width: 8),
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  perPerson == "on"
                                                      ? "${name} /guest"
                                                      : name,
                                                  style: const TextStyle(
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
                                          unitType == "percent"
                                              ? "₹${(((priceForPercent * price) / 100) * widget.adults).round()}"
                                              : '${formatIndianCurrency(price.toString())}',
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
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            'Extra Services Total',
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                          Text(
                                            '${formatIndianCurrency(serviceFeeTotal.toString())}',
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

                        if (hasBookedRooms) const Divider(height: 20),

                        // Grand Total
                        if (hasBookedRooms)
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
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
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

                        // Price Breakdown (only when rooms are selected)
                        // if (hasBookedRooms)
                        //   Container(
                        //     margin: const EdgeInsets.only(bottom: 16),
                        //     child: Column(
                        //       children: [
                        //         Row(
                        //           mainAxisAlignment: MainAxisAlignment.center,
                        //           children: [
                        //             Text(
                        //               'Breakdown: ',
                        //               style: TextStyle(
                        //                 fontSize: 13,
                        //                 color: Colors.grey[600],
                        //               ),
                        //             ),
                        //             Text(
                        //               '${formatIndianCurrency(basePrice.toString())} (Rooms)',
                        //               style: TextStyle(
                        //                 fontSize: 13,
                        //                 color: Colors.grey[600],
                        //               ),
                        //             ),
                        //             if (extrasTotal > 0)
                        //               Text(
                        //                 ' + ${formatIndianCurrency(extrasTotal.toString())} (Extras)',
                        //                 style: TextStyle(
                        //                   fontSize: 13,
                        //                   color: Colors.grey[600],
                        //                 ),
                        //               ),
                        //             if (serviceFeeTotal > 0)
                        //               Text(
                        //                 ' + ${formatIndianCurrency(serviceFeeTotal.toInt().toString())} (Service)',
                        //                 style: TextStyle(
                        //                   fontSize: 13,
                        //                   color: Colors.grey[600],
                        //                 ),
                        //               ),
                        //           ],
                        //         ),
                        //       ],
                        //     ),
                        //   ),
                      ],
                    ),
                  ),
                )
              : Center(
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.hotel_outlined,
                          size: 50,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'No rooms selected',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Please select rooms from the list above',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[500],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
          Consumer<CheckOutController>(
            builder: (BuildContext context, checkOutController, Widget? child) {
              return ElevatedButton(
                onPressed: hasBookedRooms
                    ? () async {
                        /// 2. Debug Logs
                        print('=== BOOKING DETAILS ===');
                        print('Booked Rooms       : ${widget.bookedRooms}');
                        print('All Rooms       : ${allRooms}');
                        print('Total Rooms        : $totalBookedRooms');
                        print('Check-in Date      : ${widget.checkInDate}');
                        print('Check-out Date     : ${widget.checkOutDate}');
                        print('Adults             : ${widget.adults}');
                        print('Children           : ${widget.children}');
                        print(
                            'Base Price         : ${formatIndianCurrency(basePrice)}');
                        print(
                            'Extras Total       : ${formatIndianCurrency(extrasTotal)}');
                        print(
                            'Service Fee        : ${formatIndianCurrency(serviceFeeTotal)}');
                        print(
                            'Grand Total        : ${formatIndianCurrency(grandTotal)}');
                        print('Selected Extras    : $selectedExtraPriceList');

                        /// 3. Call the API
                        final bool isSuccess = await checkOutController.checkOutFetch(context,
                                serviceId: widget.hotel.data!.hotel!.id,
                                serviceType: "hotel",
                                checkInDate: widget.checkInDate,
                                checkOutDate: widget.checkOutDate,
                                adults: widget.adults,
                                bookedRooms: allRooms,
                                children: widget.children,
                                extraPrices: selectedExtraPriceList,
                                grandTotal: grandTotal,
                                isSpace: false);

                        /// 4. Handle the API response
                        if (isSuccess) {
                          // Success: Close bottom sheet and navigate to HotelForm
                          Navigator.pop(context); // Close bottom sheet
                          Navigator.of(context, rootNavigator: true).push(
                            MaterialPageRoute(
                              builder: (context) =>
                                  HotelForm(grandTotal, "", false),
                            ),
                          );
                        } else {
                          print("Showing custom snackbar in bottom sheet");

                          // Get error message
                          String errorMessage = '';
                          if (checkOutController
                                  .checkAvailablityModel?.message !=
                              null) {
                            errorMessage = checkOutController
                                .checkAvailablityModel!.message!;
                          } else if (checkOutController.error != null) {
                            errorMessage = checkOutController.error!;
                          } else {
                            errorMessage =
                                'Rooms not available. Please try again.';
                          }

                          // Show CUSTOM snackbar IN THE BOTTOM SHEET
                          _showTopSnackbarInDialog(context, errorMessage);
                        }
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      hasBookedRooms ? Colors.blue : Colors.grey[400],
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: checkOutController.isLoading
                    ? const Center(
                        child: CircularProgressIndicator(color: Colors.white),
                      )
                    : Text(
                        hasBookedRooms
                            ? 'Continue Checkout : ${formatIndianCurrency(grandTotal)}'
                            : 'Select Rooms to Continue',
                        style: AppTextStyles.captionLarge.copyWith(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              );
            },
          ),
        ],
      ),
    );
  }
}
