import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import '../controller/checkavailablity_controller.dart';
import '../model/checkavaillblity_model.dart';
import '../model/hotel_details_model.dart';
import '../widgets/hotel_uihelper.dart';
import 'booking_summary_page.dart';
import 'hotel_detail_page.dart';
import 'hotels_home_page.dart';

class BookingScreen extends StatefulWidget {
  final HotelDetailsModel hotel;
  const BookingScreen({
    super.key,
    required this.hotel,
  });

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {

  int _adults = 2;
  int _children = 0;
  int _selectedImageIndex = 0;

  // Class level variables define karo
  DateTime checkInDate = DateTime.now().add(const Duration(days: 1));
  DateTime checkOutDate = DateTime.now().add(const Duration(days: 2));

  final DateFormat _dateFormatter = DateFormat('yyyy-MM-dd');
  DateTimeRange? selectedDateRange;

  List<Map<String, dynamic>> _bookedRooms = [];
  List<Room> allRooms = [];

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
              Icon(icon, color: Colors.orange, size: 16),
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

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      Provider.of<CheckavailablityController>(context, listen: false)
          .checkAvailability(
              hotelId: widget.hotel.data!.hotel!.id,
              checkInDate: checkInDate,
              checkOutDate: checkOutDate,
              adults: _adults);
    });
  }

  @override
  Widget build(BuildContext context) {
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
            _roomAvailability(),
            const SizedBox(height: 15),

          ],
        ),
      ),
      bottomNavigationBar:
      _bookedRooms.isNotEmpty ?
      Container(
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
          onPressed:  _showBookingSummary,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.deepOrange,
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 56),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                children: [
                  const Icon(
                    Icons.shopping_cart_outlined,
                    size: 24,
                  ),
                  // if (_bookedRooms.isNotEmpty)
                  //   Positioned(
                  //     right: 0,
                  //     top: 0,
                  //     child: Container(
                  //       padding: const EdgeInsets.all(4),
                  //       decoration: const BoxDecoration(
                  //         color: Colors.white,
                  //         shape: BoxShape.circle,
                  //       ),
                  //       child: Container(
                  //         padding: const EdgeInsets.all(2),
                  //         decoration: const BoxDecoration(
                  //           color: Colors.red,
                  //           shape: BoxShape.circle,
                  //         ),
                  //         child: Text(
                  //           '${_bookedRooms.length}',
                  //           style: const TextStyle(
                  //             fontSize: 9,
                  //             color: Colors.white,
                  //             fontWeight: FontWeight.bold,
                  //             height: 0.8,
                  //           ),
                  //         ),
                  //       ),
                  //     ),
                  //   ),
                ],
              ),
              const SizedBox(width: 12),
              Text(
              'View Booking ${_bookedRooms.length}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.2,
                ),
              ),
            ],
          ),
        ),
      )
          : SizedBox.shrink(),
    );
  }

  void _showBookingSummary() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return BookingSummaryDialog(
          bookedRooms: _bookedRooms,
          hotel: widget.hotel,
          checkInDate: checkInDate,
          checkOutDate: checkOutDate,
          adults: _adults,
          roomsFromAPI: allRooms,
          children: _children,
        );
      },
    );
  }

  void _showGalleryBottomSheet(List<Gallery> gallery) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return GalleryBottomSheet(
          galleryImages: gallery,
          initialIndex: _selectedImageIndex,
          useGalleryImages: true,
        );
      },
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
              image: widget.hotel.data?.hotel?.bannerImage != null
                  ? DecorationImage(
                      image:
                          NetworkImage(widget.hotel.data!.hotel!.bannerImage!),
                      fit: BoxFit.cover,
                    )
                  : null,
              color: AppColors.lightGray,
            ),
            child: widget.hotel.data?.hotel?.bannerImage == null
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
                  "${widget.hotel.data?.hotel?.title ?? "Hotel Name"}",
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
                        double rating;
                        try {
                          // Safely parse the reviewScore
                          String scoreString = "${widget.hotel.data?.hotel?.reviewScore ?? "4.0"}";
                          rating = double.tryParse(scoreString) ?? 4.0;
                        } catch (e) {
                          rating = 4.0; // Fallback if parsing fails
                        }

                        return Icon(
                          Icons.star_rounded,
                          size: 16,
                          color: index < rating ? Colors.orange : Colors.grey[300],
                        );
                      }),
                    ),

                    const SizedBox(width: 6),

                    // Rating Number
                    Text(
                      "${widget.hotel.data?.hotel?.starRate ?? "4.0"}",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[800],
                      ),
                    ),

                    const SizedBox(width: 4),

                    // Review Count
                    Text(
                      "(${widget.hotel.data?.reviews?.data.length ?? 0})",
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
                        "${widget.hotel.data?.hotel?.address ?? "Location"}",
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

  Widget _roomAvailability() {
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
          Text('Available Rooms', style: AppTextStyles.heading4),
          const SizedBox(height: 16),

          GestureDetector(
            onTap: () async{
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
                  onTap: () async{
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
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.arrow_forward,
                      color: Colors.orange, size: 20),
                ),
                _buildDateColumn(
                  icon: Icons.calendar_today,
                  label: 'CHECK-OUT',
                  date: _formatDate(checkOutDate),
                  onTap: () async{
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
                    if (_adults < 10) setState(() => _adults++);
                  },
                  onDecrement: () {
                    if (_adults > 1) setState(() => _adults--);
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildCounter(
                  'Children',
                  _children,
                  onIncrement: () {
                    if (_children < 10) setState(() => _children++);
                  },
                  onDecrement: () {
                    if (_children > 0) setState(() => _children--);
                  },
                ),
              ),
            ],
          ),

          // Check Availability Button
          Container(
            width: double.infinity,
            height: 45,
            margin: const EdgeInsets.symmetric(vertical: 10),
            child: Consumer<CheckavailablityController>(
              builder: (context, controller, child) {
                return ElevatedButton(
                  onPressed: controller.isLoading
                      ? null
                      : () async {
                          print("Hotel id: ${widget.hotel.data?.hotel?.id}");
                          print("Adults: $_adults");
                          print("Children: $_children");
                          print("Check-in date: ${_dateFormatter.format(checkInDate)}");
                          print("Check-out date: ${_dateFormatter.format(checkOutDate)}");
                          print("Nights: ${checkOutDate.difference(checkInDate).inDays}");

                          // CLEAR ALL SELECTED ROOMS
                          setState(() {
                            _bookedRooms.clear();
                          });

                          await controller.checkAvailability(
                            hotelId: widget.hotel.data?.hotel?.id ?? 0,
                            checkInDate: checkInDate,
                            checkOutDate: checkOutDate,
                            adults: _adults,
                            children: _children > 0 ? _children : null,
                          );
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    elevation: 4,
                    shadowColor: Colors.orange.withOpacity(0.3),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    textStyle: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                  child: controller.isLoading
                      ? SizedBox(
                          height: 15,
                          width: 15,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.calendar_today, size: 18),
                            const SizedBox(width: 10),
                            Text('Check Availability'),
                          ],
                        ),
                );
              },
            ),
          ),

          // Show Rooms List or Shimmer
          Consumer<CheckavailablityController>(
            builder: (context, controller, child) {
              if (controller.isLoading) {
                return _buildShimmerEffect();
              }

              if (!controller.isLoading &&
                  controller.availableRooms.isNotEmpty) {
                allRooms = controller.availableRooms ?? [];
                return _buildAvailableRoomsList(controller.availableRooms);
              }

              if (!controller.isLoading &&
                  controller.availableRooms.isEmpty &&
                  controller.checkAvailablityModel != null) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(Icons.hotel, size: 50, color: AppColors.gray),
                        const SizedBox(height: 12),
                        Text(
                          'No rooms available for selected dates',
                          style: TextStyle(
                            color: AppColors.gray,
                            fontSize: 14,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        TextButton(
                          onPressed: () {
                            setState(() {
                              // Reset to default dates
                              checkInDate = DateTime.now();
                              checkOutDate = DateTime.now().add(const Duration(days: 1));
                            });
                          },
                          child: Text(
                            'Try different dates',
                            style: TextStyle(
                              color: Colors.orange,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
    );
  }

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'icofont-wall-clock':
        return Icons.access_time;
      case 'icofont-car-alt-3':
        return Icons.directions_car;
      case 'icofont-bicycle-alt-2':
        return Icons.directions_bike;
      case 'icofont-imac':
        return Icons.tv;
      case 'icofont-recycle-alt':
        return Icons.local_laundry_service;
      case 'icofont-wifi-alt':
        return Icons.wifi;
      case 'icofont-tea':
        return Icons.coffee;
      default:
        return Icons.check_circle;
    }
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

 // Shimmer Effect Widget
  Widget _buildShimmerEffect() {
    return Column(
      children: List.generate(
        3,
        (index) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: Container(
                height: 100,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAvailableRoomsList(List<Room> rooms) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),

        // Room Cards
        ...rooms.map((room) {
          // Extract room data
          final int roomId = room.id ?? 0;
          final String title = room.title ?? '';
          final int price = room.price ?? 0;
          final String roomTag = room.priceText ?? "";
          final int availableRooms = room.number ?? 0;
          int selectedRooms = room.numberSelected ?? 0;
          final String sizeHtml = room.sizeHtml ?? '';
          final String bedsHtml = room.bedsHtml ?? '';
          final String adultsHtml = room.adultsHtml ?? '';
          final String childrenHtml = room.childrenHtml ?? '';
          final String image = room.image ?? '';
          final List<TermFeature> termFeatures = room.termFeatures ?? [];
          final List<Gallery> gallery = room.gallery ?? [];

          // Check if room is already in booked list
          final existingBookingIndex = _bookedRooms.indexWhere(
                  (bookedRoom) => bookedRoom['room_id'] == roomId
          );

          // Update selectedRooms from booked list if exists
          if (existingBookingIndex != -1) {
            selectedRooms = _bookedRooms[existingBookingIndex]['total_room'] ?? 0;
          }

          // Create a stateful builder for each room
          return StatefulBuilder(
            builder: (context, setState) {

              // Function to add/update room in booked list
              void _updateBookedRoomsList() {
                if (selectedRooms > 0) {
                  final bookingData = {
                    'room_id': roomId,
                    'room_title': title,
                    'room_price': price,
                    'total_price': selectedRooms * price,
                    'total_room': selectedRooms,
                    'room_image': image,
                    'size': sizeHtml.replaceAll(RegExp(r'<[^>]*>'), ''),
                    'beds': bedsHtml.replaceAll(RegExp(r'<[^>]*>'), ''),
                    'adults': adultsHtml.replaceAll(RegExp(r'<[^>]*>'), ''),
                    'children': childrenHtml.replaceAll(RegExp(r'<[^>]*>'), ''),
                    'timestamp': DateTime.now().millisecondsSinceEpoch,
                  };

                  // Check if room already exists in booked list
                  final existingIndex = _bookedRooms.indexWhere(
                          (bookedRoom) => bookedRoom['room_id'] == roomId
                  );

                  if (existingIndex != -1) {
                    // Update existing booking
                    _bookedRooms[existingIndex] = bookingData;
                  } else {
                    // Add new booking
                    _bookedRooms.add(bookingData);
                  }
                } else {
                  // Remove from booked list if selectedRooms is 0
                  _bookedRooms.removeWhere((bookedRoom) => bookedRoom['room_id'] == roomId);
                }

                // Print the booked rooms list for debugging
                print('Booked Rooms List:');
                print(_bookedRooms);
                print('Total booked rooms: ${_bookedRooms.length}');
                //print('Total amount: ${_bookedRooms.fold(0, (sum, room) => sum + (room['total_price'] ?? 0))}');
              }

              // Function to show booking menu
              void _showBookingMenu() {
                showModalBottomSheet(
                  context: context,
                  backgroundColor: Colors.white,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                  ),
                  isScrollControlled: true,
                  builder: (context) {
                    return StatefulBuilder(
                      builder: (context, bottomSheetSetState) {
                        return Container(
                          padding: const EdgeInsets.all(16),
                          constraints: BoxConstraints(
                            maxHeight: MediaQuery.of(context).size.height * 0.7,
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Header
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Select Number of Rooms',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    icon: Icon(Icons.close, color: Colors.grey[600]),
                                  ),
                                ],
                              ),

                              // Price per room
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.deepOrange.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: Colors.deepOrange.withOpacity(0.3),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        'Price per room: ',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey[700],
                                        ),
                                      ),
                                      // Text(
                                      //   formatIndianCurrency("$price"),
                                      //   style: TextStyle(
                                      //     fontSize: 16,
                                      //     fontWeight: FontWeight.bold,
                                      //     color: Colors.deepOrange,
                                      //   ),
                                      // ),
                                      Text(
                                        '$roomTag',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey[700],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              // Available rooms count
                              Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: Text(
                                  'Available: $availableRooms rooms',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ),

                              // Rooms list
                              Expanded(
                                child: ListView.builder(
                                  shrinkWrap: true,
                                  itemCount: availableRooms,
                                  itemBuilder: (context, index) {
                                    final roomCount = index + 1;
                                    final totalPrice = roomCount * price;

                                    return Container(
                                      margin: const EdgeInsets.only(bottom: 8),
                                      decoration: BoxDecoration(
                                        color: selectedRooms == roomCount
                                            ? Colors.deepOrange.withOpacity(0.1)
                                            : Colors.grey[50],
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: selectedRooms == roomCount
                                              ? Colors.deepOrange.withOpacity(0.5)
                                              : Colors.grey[200]!,
                                          width: selectedRooms == roomCount ? 2 : 1,
                                        ),
                                      ),
                                      child: ListTile(
                                        leading: Radio(
                                          value: roomCount,
                                          groupValue: selectedRooms,
                                          onChanged: (value) {
                                            bottomSheetSetState(() {
                                              selectedRooms = value as int;
                                            });
                                          },
                                          activeColor: Colors.deepOrange,
                                        ),
                                        title: Text(
                                          '$roomCount Room${roomCount > 1 ? 's' : ''}',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.black87,
                                          ),
                                        ),
                                        subtitle: Text(
                                          '₹${totalPrice.toString()}',
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.deepOrange,
                                          ),
                                        ),
                                        trailing: Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 6,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.deepOrange.withOpacity(0.2),
                                            borderRadius: BorderRadius.circular(20),
                                          ),
                                          child: Text(
                                            '₹$price × $roomCount',
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.deepOrange,
                                            ),
                                          ),
                                        ),
                                        onTap: () {
                                          bottomSheetSetState(() {
                                            selectedRooms = roomCount;
                                          });
                                        },
                                      ),
                                    );
                                  },
                                ),
                              ),

                              // Selected summary
                              if (selectedRooms > 0)
                                Container(
                                  margin: const EdgeInsets.symmetric(vertical: 12),
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.green.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: Colors.green.withOpacity(0.3),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Total for $selectedRooms Room${selectedRooms > 1 ? 's' : ''}',
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.grey[700],
                                            ),
                                          ),
                                          Text(
                                            formatIndianCurrency("${selectedRooms * price}"),
                                            style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.green,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Icon(
                                        Icons.check_circle,
                                        color: Colors.green,
                                        size: 30,
                                      ),
                                    ],
                                  ),
                                ),

                              // Confirm button
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: () {
                                    // Update the main state and booked rooms list
                                      _updateBookedRoomsList();
                                      this.setState(() {});   // parent rebuild
                                      Navigator.pop(context);
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.deepOrange,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                  ),
                                  child: Text(
                                    selectedRooms > 0
                                        ? 'CONFIRM $selectedRooms ROOM${selectedRooms > 1 ? 'S' : ''}'
                                        : 'SELECT ROOMS',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),

                              // Clear selection button
                              if (selectedRooms > 0)
                                Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: SizedBox(
                                    width: double.infinity,
                                    child: TextButton(
                                      onPressed: () {
                                        bottomSheetSetState(() {
                                          selectedRooms = 0;
                                        });
                                      },
                                      style: TextButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(vertical: 12),
                                      ),
                                      child: Text(
                                        'Clear Selection',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.red,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                );
              }

              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.lightGray),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Room Image with Title Overlay
                    if (image.isNotEmpty)
                      Stack(
                        children: [
                          ClipRRect(
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(16),
                              topRight: Radius.circular(16),
                            ),
                            child: Image.network(
                              image,
                              height: 180,
                              width: double.infinity,
                              fit: BoxFit.fill,
                              errorBuilder: (context, error, stackTrace) =>
                                  Container(
                                    height: 180,
                                    color: AppColors.lightGray,
                                    child: const Icon(Icons.image,
                                        size: 50, color: Colors.grey),
                                  ),
                            ),
                          ),

                          // Gradient Overlay
                          Container(
                            height: 180,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(16),
                                topRight: Radius.circular(16),
                              ),
                              gradient: LinearGradient(
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                                colors: [
                                  Colors.black.withOpacity(0.7),
                                  Colors.black.withOpacity(0.3),
                                  Colors.transparent,
                                ],
                              ),
                            ),
                          ),

                          // Title on Image
                          Positioned(
                            left: 10,
                            right: 10,
                            bottom: 10,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                          color: Colors.deepOrange.withOpacity(0.3)),
                                    ),
                                    padding: const EdgeInsets.all(8),
                                    child: Row(
                                      mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                      children: [
                                        // Room Size
                                        _buildRoomDetailItem(
                                          icon: Icons.aspect_ratio,
                                          title: 'Size',
                                          value: sizeHtml.replaceAll(
                                              RegExp(r'<[^>]*>'), ''),
                                        ),

                                        // Beds
                                        _buildRoomDetailItem(
                                          icon: Icons.bed,
                                          title: 'Beds',
                                          value: bedsHtml.replaceAll(
                                              RegExp(r'<[^>]*>'), ''),
                                        ),

                                        // Adults
                                        _buildRoomDetailItem(
                                          icon: Icons.person,
                                          title: 'Adults',
                                          value: adultsHtml.replaceAll(
                                              RegExp(r'<[^>]*>'), ''),
                                        ),

                                        // Children
                                        _buildRoomDetailItem(
                                          icon: Icons.child_care,
                                          title: 'Children',
                                          value: childrenHtml.replaceAll(
                                              RegExp(r'<[^>]*>'), ''),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                InkWell(
                                  onTap: () {
                                    _showGalleryBottomSheet(gallery);
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                          color: Colors.blue.withOpacity(0.3)),
                                    ),
                                    child: _buildRoomDetailItem(
                                      icon: Icons.image_outlined,
                                      title: '',
                                      value: "Gallary",
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                    // Room Details
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Title and Price Row
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Text(
                                  title,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.black87,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Row(
                                children: [
                                  // Text(
                                  //   formatIndianCurrency("$price"),
                                  //   style: const TextStyle(
                                  //     fontSize: 24,
                                  //     fontWeight: FontWeight.bold,
                                  //     color: Colors.deepOrange,
                                  //   ),
                                  // ),
                                  Text(
                                    "${roomTag}",
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.blue,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),

                          // Available rooms count
                          Padding(
                            padding: const EdgeInsets.only(top: 8, bottom: 8),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.meeting_room,
                                  size: 16,
                                  color: Colors.grey[600],
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '$availableRooms rooms available',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                // Show selected rooms count if any
                                if (selectedRooms > 0) ...[
                                  const SizedBox(width: 12),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.green.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(
                                      '${selectedRooms} selected',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.green,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),

                          // Term Features (Amenities)
                          if (termFeatures.isNotEmpty)
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: termFeatures
                                      .take(5)
                                      .map((feature) {
                                    IconData iconData =
                                    _getIconData(feature.icon ?? '');

                                    return Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: Colors.grey[50],
                                        borderRadius:
                                        BorderRadius.circular(8),
                                        border: Border.all(
                                            color: Colors.grey[200]!),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(iconData,
                                              size: 16,
                                              color: Colors.deepOrange),
                                          const SizedBox(width: 6),
                                          Text(
                                            feature.title ?? 'Amenity',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: AppColors.darkGray,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }).toList(),
                                ),

                                // "More amenities" text
                                if (termFeatures.length > 2)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 8),
                                    child: Text(
                                      '+${termFeatures.length - 5} more amenities',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: AppColors.gray,
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                  ),
                              ],
                            ),

                          // Book Now Button
                          const SizedBox(height: 14),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                if (selectedRooms == 0) {
                                  // Show booking menu
                                  _showBookingMenu();
                                } else {
                                  // Proceed with selected rooms
                                  print('Booking $selectedRooms room(s) of $title');
                                  print('Total Price: ₹${selectedRooms * price}');
                                  // Add your booking logic here
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: selectedRooms > 0
                                    ? Colors.green
                                    : Colors.deepOrange,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding: const EdgeInsets.symmetric(vertical: 14),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    selectedRooms > 0
                                        ? 'Booked $selectedRooms Room${selectedRooms > 1 ? 's' : ''}'
                                        : 'Book Now',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  if (selectedRooms > 0)
                                    Padding(
                                      padding: const EdgeInsets.only(left: 8),
                                      child: Text(
                                        '(₹${selectedRooms * price})',
                                        style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  const SizedBox(width: 8),
                                  if (selectedRooms == 0)
                                    Icon(
                                    Icons.arrow_forward_ios,
                                    size: 18,
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // Clear Selection Button
                          if (selectedRooms > 0)
                            Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: SizedBox(
                                width: double.infinity,
                                child: TextButton(
                                  onPressed: () {
                                      selectedRooms = 0;
                                      _updateBookedRoomsList();
                                      this.setState(() {});   // parent rebuild
                                  },
                                  style: TextButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(vertical: 10),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    backgroundColor: Colors.grey[100],
                                  ),
                                  child: Text(
                                    'Clear Selection',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.red,
                                      fontWeight: FontWeight.w500,
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
              );
            },
          );
        }).toList(),
      ],
    );
  }

  Widget _buildRoomDetailItem({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.deepOrange),
        const SizedBox(width: 5),
        Text(
          value,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ],
    );
  }

}
