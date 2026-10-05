import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mahakal/features/parking/controller/parking_controller.dart';
import 'package:mahakal/main.dart';
import 'package:mahakal/utill/app_constants.dart';
import 'package:mahakal/utill/completed_order_dialog.dart';
import 'package:mahakal/utill/razorpay_screen.dart';
import 'package:mahakal/features/parking/model/parking_details_model.dart';
import 'package:mahakal/features/parking/model/user_vehicle_model.dart';
import 'package:provider/provider.dart';

import '../../custom_bottom_bar/bottomBar.dart';

class BookingSummaryScreen extends StatefulWidget {
  final int addressId;
  final UserVehicle vehicle;
  final String parkingName;
  final double fee;
  final List<Slabs>? slabs;

  const BookingSummaryScreen({
    super.key,
    required this.addressId,
    required this.vehicle,
    required this.parkingName,
    required this.fee,
    this.slabs,
  });

  @override
  State<BookingSummaryScreen> createState() => _BookingSummaryScreenState();
}

class _BookingSummaryScreenState extends State<BookingSummaryScreen> {
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _startTime = TimeOfDay.now();
  TimeOfDay _endTime = TimeOfDay(hour: TimeOfDay.now().hour + 3, minute: TimeOfDay.now().minute);
  
  double _totalAmount = 0;
  int _totalHours = 1;
  Slabs? _activeSlab;
  final TextEditingController _manualDurationController = TextEditingController();

  bool _isLoading = false;
  final RazorpayPaymentService _razorpayService = RazorpayPaymentService();

  @override
  void initState() {
    super.initState();
    _calculateAmount();
  }

  @override
  void dispose() {
    _razorpayService.dispose();
    _manualDurationController.dispose();
    super.dispose();
  }

  void _calculateAmount() {
    final start = DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day, _startTime.hour, _startTime.minute);
    
    // Update end time based on total hours
    final endDateTime = start.add(Duration(hours: _totalHours));
    _endTime = TimeOfDay(hour: endDateTime.hour, minute: endDateTime.minute);
    
    double calculatedAmount = 0;
    Slabs? matchedSlab;

    if (widget.slabs != null && widget.slabs!.isNotEmpty) {
      // Slab based calculation
      bool slabFound = false;
      
      // Sort slabs by 'to' value to ensure logical matching
      List<Slabs> sortedSlabs = List.from(widget.slabs!);
      sortedSlabs.sort((a, b) => (int.tryParse(a.to ?? '0') ?? 0).compareTo(int.tryParse(b.to ?? '0') ?? 0));

      for (var slab in sortedSlabs) {
        final to = int.tryParse(slab.to ?? '0') ?? 0;
        final price = double.tryParse(slab.price ?? '0') ?? 0;

        if (_totalHours <= to) {
          calculatedAmount = price;
          matchedSlab = slab;
          slabFound = true;
          break;
        }
      }
      
      // If duration exceeds all slabs, use the last slab's price as a base
      if (!slabFound) {
        matchedSlab = sortedSlabs.last;
        calculatedAmount = double.tryParse(matchedSlab.price ?? '0') ?? (_totalHours * widget.fee);
      }
    } else {
      // Fallback to hourly fee
      calculatedAmount = _totalHours * widget.fee;
    }


    setState(() {
      _totalAmount = calculatedAmount;
      _activeSlab = matchedSlab;
    });
  }

  Future<void> _selectDate() async {
    if (_isLoading) return;
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 7)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: Colors.blue),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
      _calculateAmount();
    }
  }

  Future<void> _selectTime(bool isStart) async {
    if (_isLoading) return;
    if (!isStart) return; // End time is disabled

    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _startTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: Colors.blue),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _startTime = picked;
      });
      _calculateAmount();
    }
  }

  void _updateDuration(int hours) {
    if (_isLoading) return;
    setState(() {
      _totalHours = hours;
      _manualDurationController.clear();
    });
    _calculateAmount();
  }

  void _showSlabDetails() {
    if (_isLoading) return;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Parking Charges Slabs",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.black87),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
              const Text(
                "Flat rates applied based on the duration of your stay.",
                style: TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 20),
              ...?widget.slabs?.map((slab) {
                final bool isActive = _activeSlab != null && _activeSlab!.id == slab.id && _activeSlab!.from == slab.from && _activeSlab!.to == slab.to;
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isActive ? Colors.blue.withOpacity(0.05) : Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isActive ? Colors.blue : Colors.grey.shade200,
                      width: isActive ? 1.5 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "${slab.from} to ${slab.to} hours",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: isActive ? Colors.blue : Colors.black87,
                            ),
                          ),
                          if (isActive)
                            const Text(
                              "CURRENTLY APPLIED",
                              style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.blue, letterSpacing: 0.5),
                            ),
                        ],
                      ),
                      const Spacer(),
                      Text(
                        "₹${slab.price}",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: isActive ? Colors.blue : Colors.black87,
                        ),
                      ),
                    ],
                  ),
                );
              }),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  void _handlePayNow() async {
    if (_isLoading) return;
    final parkingController = Provider.of<ParkingController>(context, listen: false);
    
    setState(() {
      _isLoading = true;
    });

    try {
      final formatter = DateFormat('yyyy-MM-dd HH:mm:ss');
      final start = DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day, _startTime.hour, _startTime.minute);
      final end = start.add(Duration(hours: _totalHours));

      // 1. Create Lead with FINAL amount and duration
      final leadId = await parkingController.createParkingLead(
        addressId: widget.addressId,
        vehicleId: widget.vehicle.vehicleId ?? 0,
        cabName: widget.vehicle.cabName ?? "Vehicle",
        cabRegisterNumber: widget.vehicle.cabRegisterNumber ?? "N/A",
        color: widget.vehicle.color ?? "N/A",
        aadhar: widget.vehicle.aadhar ?? "",
        pickupDateTime: formatter.format(start),
        dropDateTime: formatter.format(end),
        totalHours: _totalHours,
        totalAmount: _totalAmount,
      );

      if (leadId == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to initialize booking. Please try again.')),
          );
          setState(() {
            _isLoading = false;
          });
        }
        return;
      }

      // 2. Open Razorpay
      _razorpayService.openCheckout(
        amount: _totalAmount,
        description: "Parking booking at ${widget.parkingName}",
        razorpayKey: AppConstants.razorpayLive,
        onSuccess: (response) async {
          if (mounted) {
            setState(() {
              _isLoading = true;
            });
          }

          try {
            final success = await parkingController.parkingBookingSuccess(
              leadId: leadId,
              onlineAmount: _totalAmount,
              transactionId: response.paymentId ?? "N/A",
            );

            if (success && context.mounted) {
              if (mounted) {
                setState(() {
                  _isLoading = false;
                });
              }
              Navigator.pushAndRemoveUntil(
                context, 
                MaterialPageRoute(builder: (context) => const BottomBar(pageIndex: 0)), 
                (route) => false
              );
              
              showDialog(
                context: Get.context!,
                barrierDismissible: false,
                builder: (context) => bookingSuccessDialog(
                  context: context,
                  title: 'Booking Success',
                  message: 'Your parking spot at ${widget.parkingName} has been booked successfully!',
                  openButtonText: 'My Bookings',
                  cancelButtonText: 'Home',
                  tabIndex: 111,
                ),
              );
            } else {
              if (mounted) {
                setState(() {
                  _isLoading = false;
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Failed to confirm booking. Please contact support.')),
                );
              }
            }
          } catch (e) {
            debugPrint("Error processing booking success: $e");
            if (mounted) {
              setState(() {
                _isLoading = false;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Failed to confirm booking. Please contact support.')),
              );
            }
          }
        },
        onFailure: (response) {
          if (mounted) {
            setState(() {
              _isLoading = false;
            });
          }
        },
      );
    } catch (e) {
      debugPrint("Error in _handlePayNow: $e");
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_isLoading,
      child: Stack(
        children: [
          Scaffold(
            backgroundColor: const Color(0xFFF0F2F5),
            appBar: AppBar(
              centerTitle: true,
              elevation: 0,
              backgroundColor: Colors.transparent,
              flexibleSpace: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFFE65100), Color(0xFFFF8A65)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
              title: const Text(
                'Booking Summary',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 0.5),
              ),
              leading: Padding(
                padding: const EdgeInsets.all(8.0),
                child: IconButton(
                  onPressed: _isLoading ? null : () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.white.withOpacity(0.2),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 30),
        child: Column(
          children: [
            // Ticket View
            Container(
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  )
                ],
              ),
              child: ClipPath(
                clipper: TicketClipper(),
                child: Container(
                  color: Colors.white,
                  child: Column(
                    children: [
                      // Top part of ticket
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text("PARKING SPOT", style: TextStyle(fontSize: 9, color: Colors.grey, fontWeight: FontWeight.bold, letterSpacing: 1)),
                                    const SizedBox(height: 2),
                                    Text(widget.parkingName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
                                  ],
                                ),
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.blue.withOpacity(0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.local_parking, color: Colors.blue, size: 20),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                _ticketInfoItem("VEHICLE NO", widget.vehicle.cabRegisterNumber?.toUpperCase() ?? "N/A"),
                                const SizedBox(width: 30),
                                _ticketInfoItem("TYPE", widget.vehicle.cabName?.toUpperCase() ?? "VEHICLE"),
                              ],
                            ),
                          ],
                        ),
                      ),
                      
                      // Dashed Line
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: CustomPaint(
                          size: const Size(double.infinity, 1),
                          painter: DashedLinePainter(),
                        ),
                      ),
                      
                      // Bottom part of ticket
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Date selection
                            _editableTicketRow(
                              icon: Icons.calendar_today_rounded,
                              label: "Date",
                              value: DateFormat('dd MMM, yyyy').format(_selectedDate),
                              onTap: _selectDate,
                            ),
                            const SizedBox(height: 12),
                            // Time selection
                            Row(
                              children: [
                                Expanded(
                                  child: _editableTicketRow(
                                    icon: Icons.access_time_rounded,
                                    label: "Start Time",
                                    value: _startTime.format(context),
                                    onTap: () => _selectTime(true),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: _editableTicketRow(
                                    icon: Icons.update_rounded,
                                    label: "End Time",
                                    value: _endTime.format(context),
                                    onTap: () {}, // Disabled
                                    isEditable: false,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),

                            const Text(
                              "Select Duration",
                              style: TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                            ),
                            const SizedBox(height: 10),
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: [1, 2, 3, 6, 12, 24].map((hour) {
                                  final isSelected = _totalHours == hour;
                                  return Padding(
                                    padding: const EdgeInsets.only(right: 8),
                                    child: InkWell(
                                      onTap: () => _updateDuration(hour),
                                      borderRadius: BorderRadius.circular(8),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: isSelected ? Colors.blue : Colors.white,
                                          borderRadius: BorderRadius.circular(8),
                                          border: Border.all(color: isSelected ? Colors.blue : Colors.grey.shade300),
                                        ),
                                        child: Text(
                                          "$hour Hrs",
                                          style: TextStyle(
                                            color: isSelected ? Colors.white : Colors.black87,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                            
                            /*
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              child: Row(
                                children: [
                                  Expanded(child: Divider(color: Colors.grey.shade300, endIndent: 10)),
                                  const Text("OR", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
                                  Expanded(child: Divider(color: Colors.grey.shade300, indent: 10)),
                                ],
                              ),
                            ),

                            Row(
                              children: [
                                Expanded(
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10),
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade50,
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(color: Colors.grey.shade200),
                                    ),
                                    child: TextField(
                                      controller: _manualDurationController,
                                      keyboardType: TextInputType.number,
                                      decoration: const InputDecoration(
                                        hintText: "Enter manual hours",
                                        hintStyle: TextStyle(fontSize: 11, color: Colors.grey),
                                        border: InputBorder.none,
                                        isDense: true,
                                        icon: Icon(Icons.edit_note_rounded, size: 18, color: Colors.blue),
                                      ),
                                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                                      onChanged: (value) {
                                        if (value.isNotEmpty) {
                                          final hours = int.tryParse(value);
                                          if (hours != null && hours > 0) {
                                            setState(() {
                                              _totalHours = hours;
                                            });
                                            _calculateAmount();
                                          }
                                        }
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            */
                            const SizedBox(height: 16),
                            
                            // Pricing logic summary
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF8F9FA),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.grey.shade200),
                              ),
                              child: Column(
                                children: [
                                  if (widget.slabs != null && widget.slabs!.isNotEmpty)
                                    ...[
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          const Row(
                                            children: [
                                              Icon(Icons. analytics_outlined, size: 14, color: Colors.grey),
                                              SizedBox(width: 4),
                                              Text("Applied Slab Rate", style: TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.bold)),
                                            ],
                                          ),
                                          InkWell(
                                            onTap: _showSlabDetails,
                                            child: Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                              decoration: BoxDecoration(
                                                color: Colors.blue.withOpacity(0.1),
                                                borderRadius: BorderRadius.circular(6),
                                              ),
                                              child: const Row(
                                                children: [
                                                  Text("View Slabs", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.blue)),
                                                  SizedBox(width: 4),
                                                  Icon(Icons.info_outline_rounded, size: 12, color: Colors.blue),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                    ],
                                  _priceBreakdownRow(
                                    "Rate Details", 
                                    _activeSlab != null 
                                      ? "₹${_activeSlab!.price} (${_activeSlab!.from}-${_activeSlab!.to}h Slab)" 
                                      : "₹${widget.fee.toStringAsFixed(0)} / hr"
                                  ),
                                  const SizedBox(height: 6),
                                  _priceBreakdownRow("Total Hours", "$_totalHours ${_totalHours > 1 ? 'hrs' : 'hr'}"),
                                  const Padding(
                                    padding: EdgeInsets.symmetric(vertical: 8),
                                    child: Divider(height: 1),
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text("Total Amount", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                      Text(
                                        "₹${_totalAmount.toStringAsFixed(0)}",
                                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.blue),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      // Bottom bar code look-alike or spacer
                      Container(
                        height: 20,
                        width: double.infinity,
                        color: Colors.blue.withOpacity(0.05),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 25),
            
            // Confirm Button
            Container(
              width: double.infinity,
              height: 54,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: const LinearGradient(
                  colors: [Color(0xFFE65100), Color(0xFFFF8A65)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  )
                ],
              ),
              child: ElevatedButton(
                onPressed: _isLoading ? null : _handlePayNow,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: _isLoading 
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Text(
                      'Confirm & Pay Now',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white),
                    ),
              ),
            ),
            
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.security_rounded, size: 12, color: Colors.grey.shade400),
                const SizedBox(width: 4),
                Text(
                  "Secure SSL Encrypted Payment",
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 10, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
    if (_isLoading)
      AbsorbPointer(
        absorbing: true,
        child: Container(
          color: Colors.black.withOpacity(0.5),
          width: double.infinity,
          height: double.infinity,
          child: Center(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 32),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  )
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  SizedBox(
                    height: 48,
                    width: 48,
                    child: CircularProgressIndicator(
                      color: Colors.blue,
                      strokeWidth: 3.5,
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    "Processing Booking...",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "Please wait while we confirm your parking spot...",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.black54,
                      height: 1.3,
                    ),
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

  Widget _ticketInfoItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 9, color: Colors.grey, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
        const SizedBox(height: 2),
        Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Colors.black87)),
      ],
    );
  }

  Widget _editableTicketRow({required IconData icon, required String label, required String value, required VoidCallback onTap, bool isEditable = true}) {
    return InkWell(
      onTap: isEditable ? onTap : null,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: isEditable ? Colors.white : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            Icon(icon, size: 16, color: isEditable ? Colors.blue : Colors.grey),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: const TextStyle(fontSize: 9, color: Colors.grey, fontWeight: FontWeight.bold)),
                  Text(value, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: isEditable ? Colors.black87 : Colors.grey.shade600)),
                ],
              ),
            ),
            if (isEditable) const Icon(Icons.edit_rounded, size: 12, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _priceBreakdownRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: Colors.grey.shade600, fontSize: 12, fontWeight: FontWeight.w500)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
      ],
    );
  }
}


class TicketClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    double radius = 15;
    double cutoutRadius = 12;
    double cutoutPosition = size.height * 0.45; // Approximately where the dashed line is

    path.lineTo(0, cutoutPosition - cutoutRadius);
    path.arcToPoint(
      Offset(0, cutoutPosition + cutoutRadius),
      radius: Radius.circular(cutoutRadius),
      clockwise: true,
    );
    path.lineTo(0, size.height - radius);
    path.arcToPoint(Offset(radius, size.height), radius: Radius.circular(radius));
    path.lineTo(size.width - radius, size.height);
    path.arcToPoint(Offset(size.width, size.height - radius), radius: Radius.circular(radius));
    
    path.lineTo(size.width, cutoutPosition + cutoutRadius);
    path.arcToPoint(
      Offset(size.width, cutoutPosition - cutoutRadius),
      radius: Radius.circular(cutoutRadius),
      clockwise: true,
    );
    path.lineTo(size.width, radius);
    path.arcToPoint(Offset(size.width - radius, 0), radius: Radius.circular(radius));
    path.lineTo(radius, 0);
    path.arcToPoint(Offset(0, radius), radius: Radius.circular(radius));
    
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class DashedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    double dashWidth = 5, dashSpace = 5, startX = 0;
    final paint = Paint()
      ..color = Colors.grey.shade300
      ..strokeWidth = 1;
    while (startX < size.width) {
      canvas.drawLine(Offset(startX, 0), Offset(startX + dashWidth, 0), paint);
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

