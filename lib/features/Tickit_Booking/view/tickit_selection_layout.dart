import 'package:flutter/material.dart';
import 'package:mahakal/features/Tickit_Booking/model/tickit_availiblity_model.dart' hide Row;
import 'package:mahakal/features/Tickit_Booking/view/tickit_payment_summery.dart';

class SeatSelectionScreen extends StatefulWidget {
  final TickitAvailiblityModel ticketData;
  final int personCount;
  final int venueId;
  final int eventId;
  final int leadId;
  final int packageId;
  final List<Map<String, String>> devotees;

  final String eventName;
  final String eventDate;
  final String eventTime;
  final String eventVenue;
  final double walletPay;

  const SeatSelectionScreen({
    super.key,
    required this.ticketData,
    required this.personCount,
    required this.venueId,
    required this.eventId,
    required this.leadId,
    required this.packageId,

    required this.eventName,
    required this.eventDate,
    required this.eventTime,
    required this.eventVenue,
    required this.devotees,
    required this.walletPay,

  });

  @override
  State<SeatSelectionScreen> createState() => _SeatSelectionScreenState();
}

class _SeatSelectionScreenState extends State<SeatSelectionScreen> {
  Auditorium? get venue => widget.ticketData.data?.auditorium;
  late Map<String, dynamic> seatTypes;
  List<Map<String, dynamic>> selectedSeats = [];

  // Track which package is currently being selected
  String? _selectedPackageId;

  final ScrollController _horizontalController = ScrollController();
  final ScrollController _verticalController = ScrollController();
  final ScrollController _seatNumbersTopController = ScrollController();
  final ScrollController _seatNumbersBottomController = ScrollController();

  @override
  void initState() {
    super.initState();
    _initializeSeatTypes();
  }

  void _initializeSeatTypes() {
    seatTypes = {};
    if (venue?.rows != null) {
      for (var row in venue!.rows) {
        String type = row.type;
        if (!seatTypes.containsKey(type)) {
          seatTypes[type] = {
            'color': hexToColor(row.color),
            'price': double.tryParse(row.price) ?? 0.0,
            'name': type.toUpperCase(),
            'package_id': row.packageId.toString(),
          };
        }
      }
    }
  }

  Color hexToColor(String hex) {
    try {
      final buffer = StringBuffer();
      if (hex.startsWith('#')) {
        hex = hex.substring(1);
      }
      if (hex.length == 6 || hex.length == 7) buffer.write('ff');
      buffer.write(hex);
      return Color(int.parse(buffer.toString(), radix: 16));
    } catch (e) {
      print('Error parsing color: $hex');
      return Colors.grey;
    }
  }

  @override
  void dispose() {
    _horizontalController.dispose();
    _verticalController.dispose();
    _seatNumbersTopController.dispose();
    _seatNumbersBottomController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (venue == null) {
      return Scaffold(
        backgroundColor: const Color(0xFF0A0A0A),
        body: Center(
          child: Text(
            'No venue data available',
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _buildAppBar(),
            SizedBox(height: 10,),

            // Screen Area
            _buildScreenArea(),

            // Legend
            _buildLegend(),
            SizedBox(height: 5,),

            // Package Selection Info
            if (_selectedPackageId != null) _buildPackageInfo(),

            // Seat Layout with Dual Scroll
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      const Color(0xFF0A0A0A).withOpacity(0.8),
                      const Color(0xFF1A1A1A),
                    ],
                  ),
                ),
                child: _buildScrollableSeatLayout(),
              ),
            ),

            // Bottom Bar
            _buildBottomBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildPackageInfo() {
    String packageName = '';
    Color packageColor = Colors.blue;

    // Find package details
    for (var entry in seatTypes.entries) {
      if (entry.value['package_id'] == _selectedPackageId) {
        packageName = entry.value['name'];
        packageColor = entry.value['color'] is Color
            ? entry.value['color']
            : hexToColor(entry.value['color'].toString());
        break;
      }
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: packageColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: packageColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: packageColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'You are selecting $packageName seats. All ${widget.personCount} seats must be from the same package.',
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.black.withOpacity(0.9),
            Colors.black.withOpacity(0.7),
          ],
        ),
        border: Border(
          bottom: BorderSide(color: Colors.white.withOpacity(0.1), width: 1),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.all(10),
                child: const Icon(
                  Icons.arrow_back_ios,
                  color: Colors.white,
                  size: 18,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Select Seats",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    venue?.venueName ?? '',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.6),
                      fontSize: 12,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E1E1E),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.white.withOpacity(0.1)),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      Icon(
                        Icons.chair_rounded,
                        color: Colors.white.withOpacity(0.7),
                        size: 16,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        "${venue?.availableSeats ?? 0}",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        "/${venue?.totalSeats ?? 0}",
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.5),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Select up to ${widget.personCount} seats",
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.6),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScreenArea() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          // The Screen Label
          Text(
            "All eyes this way",
            style: TextStyle(
              color: Colors.grey.shade500,
              fontSize: 12,
              fontWeight: FontWeight.w500,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 15),

          // The 3D Curved Screen
          Stack(
            alignment: Alignment.topCenter,
            children: [
              // 1. Perspective Shadow (Floor Reflection)
              Transform(
                transform: Matrix4.identity()
                  ..setEntry(3, 2, 0.001)
                  ..rotateX(0.8),
                alignment: FractionalOffset.center,
                child: Container(
                  height: 40,
                  width: 250,
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blue.withOpacity(0.15),
                        blurRadius: 30,
                        spreadRadius: 10,
                      ),
                    ],
                  ),
                ),
              ),

              // 2. The Curved Screen Line (Main Body)
              ClipPath(
                clipper: ScreenClipper(),
                child: Container(
                  height: 60,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.white.withOpacity(0.4), // Glass Top
                        Colors.white.withOpacity(0.05), // Fade to transparent
                      ],
                    ),
                  ),
                ),
              ),

              // 3. The Bright Glowing Edge (Top Curve)
              CustomPaint(
                size: const Size(double.infinity, 20),
                painter: ScreenCurvePainter(),
              ),

              // 4. Light Ray Effect (Screen se nikalne wali light)
              Container(
                height: 80,
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: const Alignment(0, -1.2),
                    radius: 1.2,
                    colors: [
                      Colors.white.withOpacity(0.15),
                      Colors.transparent,
                    ],
                    stops: const [0.0, 0.8],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildLegend() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _legendItem("Available", Colors.white.withOpacity(0.3), false),
                const SizedBox(width: 16),
                _legendItem("Selected", const Color(0xFF4CAF50), false),
                const SizedBox(width: 16),
                _legendItem("Booked", const Color(0xFFF44336), false),
                const SizedBox(width: 16),
                ...seatTypes.entries.map((entry) {
                  Color color = entry.value['color'] is Color
                      ? entry.value['color']
                      : hexToColor(entry.value['color'].toString());
                  return Padding(
                    padding: const EdgeInsets.only(left: 16),
                    child: _legendItem(
                      entry.value['name'],
                      color,
                      false,
                    ),
                  );
                }).toList(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _legendItem(String label, Color color, bool isWheelchair) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color: Colors.white.withOpacity(0.2),
              width: 0.5,
            ),
          ),
          child: isWheelchair
              ? Icon(
            Icons.accessible_rounded,
            size: 10,
            color: Colors.black.withOpacity(0.7),
          )
              : null,
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildScrollableSeatLayout() {
    if (venue == null) return SizedBox();

    List<LayoutRow> rows = venue!.rows;
    int seatsPerRow = venue!.seatsPerRow;
    List<int> aisle = venue!.aislePositions;
    List<BlockedSeat> blockedSeats = venue!.blockedSeats;

    return Column(
      children: [
        // Top Seat Numbers
        Container(
          height: 30,
          padding: const EdgeInsets.only(left: 30, right: 20),
          child: NotificationListener<ScrollNotification>(
            onNotification: (notification) {
              if (notification is ScrollUpdateNotification) {
                _seatNumbersBottomController
                    .jumpTo(_seatNumbersTopController.offset);
              }
              return false;
            },
            child: SingleChildScrollView(
              controller: _seatNumbersTopController,
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(
                children: _buildSeatNumbers(seatsPerRow, aisle),
              ),
            ),
          ),
        ),

        // Main seat grid
        Expanded(
          child: Scrollbar(
            controller: _verticalController,
            thumbVisibility: true,
            child: SingleChildScrollView(
              controller: _verticalController,
              physics: const BouncingScrollPhysics(),
              child: SingleChildScrollView(
                controller: _horizontalController,
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: _buildSeatGridWithSections(
                        rows, seatsPerRow, aisle, blockedSeats),
                  ),
                ),
              ),
            ),
          ),
        ),

        // Bottom Seat Numbers
        Container(
          height: 30,
          padding: const EdgeInsets.only(left: 30, right: 20),
          child: NotificationListener<ScrollNotification>(
            onNotification: (notification) {
              if (notification is ScrollUpdateNotification) {
                _seatNumbersTopController
                    .jumpTo(_seatNumbersBottomController.offset);
              }
              return false;
            },
            child: SingleChildScrollView(
              controller: _seatNumbersBottomController,
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(
                children: _buildSeatNumbers(seatsPerRow, aisle),
              ),
            ),
          ),
        ),
      ],
    );
  }

  List<Widget> _buildSeatNumbers(int seatsPerRow, List<int> aisle) {
    List<Widget> seatNumbers = [];

    for (int seatNo = 1; seatNo <= seatsPerRow; seatNo++) {
      bool addGap = aisle.contains(seatNo);
      bool addGroupGap = seatNo % 4 == 0 && seatNo != seatsPerRow;

      seatNumbers.add(
        Container(
          width: 28,
          margin: EdgeInsets.only(right: addGroupGap ? 12 : 0),
          child: Center(
            child: Text(
              seatNo.toString(),
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      );

      if (addGap) {
        seatNumbers.add(
          SizedBox(
            width: 25,
            child: Center(
              child: Container(
                height: 1,
                color: Colors.white.withOpacity(0.2),
              ),
            ),
          ),
        );
      }
    }

    return seatNumbers;
  }

  List<Widget> _buildSeatGridWithSections(
      List<LayoutRow> rows, int seatsPerRow, List<int> aisle, List<BlockedSeat> blockedSeats) {
    List<Widget> sections = [];
    String? currentPackage;
    int? currentPackageId;

    for (int rowIndex = 0; rowIndex < rows.length; rowIndex++) {
      LayoutRow row = rows[rowIndex];
      String currentRowPackage = row.type;
      int currentRowPackageId = row.packageId;
      Color rowColor = hexToColor(row.color);

      // Add section header when package changes
      if (currentPackageId != currentRowPackageId) {
        currentPackage = currentRowPackage;
        currentPackageId = currentRowPackageId;
        sections.add(
          Container(
            margin: EdgeInsets.only(top: rowIndex == 0 ? 0 : 20, bottom: 12),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: rowColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(5),
              border: Border.all(
                color: rowColor.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: rowColor,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  currentRowPackage.toUpperCase(),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  "₹${row.price}",
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        );
      }

      // Add seat row
      sections.add(
        SizedBox(
          width: _calculateRowWidth(seatsPerRow, aisle),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Left Row Label
                Container(
                  width: 30,
                  child: Center(
                    child: Text(
                      row.rowname,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        shadows: [
                          Shadow(
                            color: Colors.black.withOpacity(0.5),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Seats with grouping
                Expanded(
                  child: Row(
                    children: _buildSeatRow(
                        row, rowIndex + 1, seatsPerRow, aisle, blockedSeats),
                  ),
                ),

                // Right Row Label
                Container(
                  width: 30,
                  child: Center(
                    child: Text(
                      row.rowname,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        shadows: [
                          Shadow(
                            color: Colors.black.withOpacity(0.5),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return sections;
  }

  double _calculateRowWidth(int seatsPerRow, List<int> aisle) {
    double seatWidth = 26.0;
    double seatMargin = 2.0;
    double groupGap = 12.0;
    double aisleGap = 25.0;
    double labelWidth = 30.0 * 2;

    double totalWidth = labelWidth;

    for (int seatNo = 1; seatNo <= seatsPerRow; seatNo++) {
      bool addGap = aisle.contains(seatNo);
      bool addGroupGap = seatNo % 4 == 0 && seatNo != seatsPerRow;

      totalWidth += seatWidth;
      if (addGroupGap) totalWidth += groupGap;
      if (addGap) totalWidth += aisleGap;
      if (seatNo < seatsPerRow && !addGroupGap) totalWidth += seatMargin;
    }

    return totalWidth + 20;
  }

  List<Widget> _buildSeatRow(
      LayoutRow row, int rowIndex, int seatsPerRow, List<int> aisle, List<BlockedSeat> blockedSeats) {
    List<Widget> seats = [];
    Color seatColor = hexToColor(row.color);
    double seatPrice = double.tryParse(row.price) ?? 0.0;

    for (int seatIndex = 0; seatIndex < seatsPerRow; seatIndex++) {
      int seatNo = seatIndex + 1;
      bool addGap = aisle.contains(seatNo);
      bool addGroupGap = seatNo % 4 == 0 && seatNo != seatsPerRow;

      bool isBlocked = blockedSeats.any((b) => b.row == rowIndex && b.seat == seatNo);

      Widget seat = _buildSeat(
        seatId: "$rowIndex-$seatNo",
        rowIndex: rowIndex,
        seatNo: seatNo,
        isBlocked: isBlocked,
        isSelected: selectedSeats.any((s) => s['id'] == "$rowIndex-$seatNo"),
        color: seatColor,
        rowData: row,
        isWheelchair: false,
        seatPrice: seatPrice,
      );

      seats.add(
        Container(
          width: 26,
          margin: EdgeInsets.only(right: addGroupGap ? 12 : 2),
          child: seat,
        ),
      );

      if (addGap) {
        seats.add(
          SizedBox(
            width: 25,
            child: Center(
              child: Container(
                height: 40,
                width: 1,
                color: Colors.white.withOpacity(0.2),
              ),
            ),
          ),
        );
      }
    }

    return seats;
  }

  Widget _buildSeat({
    required String seatId,
    required int rowIndex,
    required int seatNo,
    required bool isBlocked,
    required bool isSelected,
    required Color color,
    required LayoutRow rowData,
    required bool isWheelchair,
    required double seatPrice,
  }) {
    // Determine if seat is selectable
    bool isSelectable = true;

    if (_selectedPackageId != null) {
      // If a package has already been selected, only allow seats from that package
      isSelectable = rowData.packageId.toString() == _selectedPackageId;
    }

    Color finalColor;

    if (isBlocked) {
      finalColor = const Color(0xFFF44336);
    } else if (!isSelectable) {
      finalColor = Colors.grey.shade700.withOpacity(0.6);
    } else if (isSelected) {
      finalColor = const Color(0xFF4CAF50);
    } else {
      finalColor = color;
    }

    return GestureDetector(
      onTap: (!isBlocked && isSelectable)
          ? () {
        // Check if user can select more seats
        if (!isSelected && selectedSeats.length >= widget.personCount) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'You can only select up to ${widget.personCount} seats',
                style: TextStyle(color: Colors.white),
              ),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 2),
            ),
          );
          return;
        }

        setState(() {
          if (isSelected) {
            selectedSeats.removeWhere((s) => s['id'] == seatId);
            // If no seats selected, reset package selection
            if (selectedSeats.isEmpty) {
              _selectedPackageId = null;
            }
          } else {
            // If this is the first seat being selected, set the package
            if (selectedSeats.isEmpty) {
              _selectedPackageId = rowData.packageId.toString();
            }

            selectedSeats.add({
              "id": seatId,
              "rowname": rowData.rowname,
              "seat": seatNo,
              "price": seatPrice,
              "type": rowData.type,
              "package_id": rowData.packageId.toString(),
            });
          }
        });
      }
          : null,
      child: Container(
        height: 26,
        decoration: BoxDecoration(
          color: finalColor,
          borderRadius: BorderRadius.circular(5),
          border: Border.all(
            color: isSelected
                ? Colors.white.withOpacity(0.8)
                : Colors.white.withOpacity(0.1),
            width: isSelected ? 1.5 : 0.5,
          ),
          boxShadow: [
            if (!isBlocked && isSelectable)
              BoxShadow(
                color: finalColor.withOpacity(0.3),
                blurRadius: isSelected ? 6 : 3,
                spreadRadius: isSelected ? 1 : 0,
              ),
          ],
        ),
        child: Stack(
          children: [
            Center(
              child: Icon(
                isWheelchair ? Icons.accessible_rounded : Icons.chair_rounded,
                size: isWheelchair ? 14 : 12,
                color: isBlocked
                    ? Colors.white.withOpacity(0.3)
                    : (isSelected ? Colors.white : Colors.black.withOpacity(0.7)),
              ),
            ),
            if (isSelected)
              Positioned(
                right: 3,
                top: 3,
                child: Container(
                  padding: const EdgeInsets.all(1),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    size: 8,
                    color: Colors.black,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    double total = selectedSeats.fold(
        0.0, (sum, seat) => sum + (seat['price'] ?? 0.0));

    // Get the selected package name
    String selectedPackageName = '';
    if (selectedSeats.isNotEmpty) {
      selectedPackageName = selectedSeats.first['type'] ?? '';
    }

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.black.withOpacity(0.95),
            Colors.black,
          ],
        ),
        border: Border(
          top: BorderSide(color: Colors.white.withOpacity(0.1), width: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 20,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (selectedPackageName.isNotEmpty)
                        Text(
                          selectedPackageName,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFF4CAF50).withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              "${selectedSeats.length}/${widget.personCount} SEATS",
                              style: const TextStyle(
                                color: Color(0xFF4CAF50),
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            "₹${total.toStringAsFixed(0)}",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      if (selectedSeats.isNotEmpty)
                        SizedBox(
                          height: 20,
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: selectedSeats.map((s) {
                                Color seatColor;
                                dynamic colorData =
                                seatTypes[s['type']]?['color'];
                                if (colorData is Color) {
                                  seatColor = colorData;
                                } else if (colorData is String) {
                                  seatColor = hexToColor(colorData);
                                } else {
                                  seatColor = Colors.grey;
                                }

                                return Padding(
                                  padding: const EdgeInsets.only(right: 8),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: seatColor,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(
                                      '${s['rowname']}${s['seat']}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 20),
                ElevatedButton(
                  onPressed: selectedSeats.isEmpty
                      ? null
                      : () {
                    // Check if user has selected exactly personCount seats
                    if (selectedSeats.length > widget.personCount) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'You can only select up to ${widget.personCount} seats',
                            style: TextStyle(color: Colors.white),
                          ),
                          backgroundColor: Colors.red,
                          duration: const Duration(seconds: 2),
                        ),
                      );
                      return;
                    }

                    // Check if all seats are from the same package
                    final allSamePackage = selectedSeats.every(
                            (seat) => seat['package_id'] == _selectedPackageId);

                    if (!allSamePackage) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'All seats must be from the same package',
                            style: TextStyle(color: Colors.white),
                          ),
                          backgroundColor: Colors.red,
                          duration: const Duration(seconds: 2),
                        ),
                      );
                      return;
                    }

                    // Handle proceed with selected seats
                    print('Selected Package: ${selectedSeats.first['type']}');
                    print('Selected Seats: $selectedSeats');
                    print('Total amount: $total');

                    print("lead id: ${widget.leadId}");
                    print("package id: ${_selectedPackageId}");
                    print("venuew id: ${widget.venueId}");
                    print("Qty: ${widget.personCount}");
                    print("amount: ${total}");
                    print("date: ${widget.eventDate}");

                    // Navigate to next screen or process payment
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TicketPaymentSummary(
                          packageName: "${selectedSeats.first['type']}", // Selected package name
                          eventName: "${widget.eventName}", // Event name
                          eventDate: "${widget.eventDate}", // Formatted date
                          eventTime: "${widget.eventTime}", // Event time
                          eventVenue: "${widget.eventVenue}", // Venue
                          personCount: selectedSeats.length, // Number of persons
                          seatNumbers: selectedSeats.map((s) => '${s['rowname']}-${s['seat']}').toList(), // ["A-2", "D-6"]
                          totalAmount: total, // Total amount
                          eventId: widget.eventId.toString(), // Event ID
                          venueId: widget.venueId.toString(), // Venue ID
                          leadId: widget.leadId.toString(), // Lead ID
                          packageId: _selectedPackageId ?? '',
                          devotees: widget.devotees,
                          amount: selectedSeats.first['price'], walletPay: widget.walletPay, // Package ID
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: selectedSeats.isEmpty
                        ? Colors.grey.shade800
                        : const Color(0xFF4CAF50),
                    foregroundColor: Colors.white,
                    padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 5,
                    shadowColor: const Color(0xFF4CAF50).withOpacity(0.5),
                  ),
                  child: const Text(
                    "PROCEED",
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ],
            ),
            if (selectedSeats.isEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  "Select up to ${widget.personCount} seats to continue",
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.4),
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            if (selectedSeats.isNotEmpty && selectedSeats.length < widget.personCount)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  "You can select ${widget.personCount - selectedSeats.length} more seat(s) from ${selectedSeats.first['type'] ?? 'this package'}",
                  style: TextStyle(
                    color: Colors.yellow.withOpacity(0.8),
                    fontSize: 12,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}


// Painter for that sharp glowing top curve
class ScreenCurvePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..shader = LinearGradient(
        colors: [
          Colors.transparent,
          Colors.white.withOpacity(0.2),
          Colors.white,
          Colors.white.withOpacity(0.2),
          Colors.transparent,
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;

    final Path path = Path();
    path.moveTo(0, size.height);
    path.quadraticBezierTo(size.width / 2, -10, size.width, size.height);

    // Glow Layer
    canvas.drawPath(path, paint..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3));
    // Main White Line
    canvas.drawPath(path, paint..maskFilter = null);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

// Clipper for the glass body below the curve
class ScreenClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();

    path.moveTo(0, 0);
    path.lineTo(0, size.height - 30);

    path.quadraticBezierTo(
      size.width / 2,
      size.height + 20,
      size.width,
      size.height - 30,
    );

    path.lineTo(size.width, 0);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
