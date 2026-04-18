import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mahakal/features/mandir_darshan/payment_screen.dart';
import 'package:intl/intl.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import '../../main.dart';
import '../../utill/app_constants.dart';
import '../auth/controllers/auth_controller.dart';

class PackageDetailView extends StatefulWidget {
  final String id;
  const PackageDetailView({super.key, required this.id});

  @override
  _PackageDetailViewState createState() => _PackageDetailViewState();
}

class _PackageDetailViewState extends State<PackageDetailView> {
  DateTime? selectedDate;
  String? selectedTime;
  String enTempleName = '';
  String hiTempleName = '';
  String image = '';
  String name = '';
  String price = '';
  String aadharStatus = '';
  List<String> availableTimes = [];
  List<String> include = [];

  Future<void> packageLead(String id) async {
    String userToken =
        Provider.of<AuthController>(Get.context!, listen: false).getUserToken();
    final response = await http.post(
      Uri.parse('${AppConstants.baseUrl}${AppConstants.packageTempleDetail}'),
      headers: {
        'Authorization': 'Bearer $userToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'lead_id': id}),
    );
    print('Response Code check: $id');
    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      setState(() {
        enTempleName = data['data']['en_temple_name'];
        hiTempleName = data['data']['hi_temple_name'];
        image = data['data']['image'];
        name = data['data']['name'];
        price = data['data']['price'];
        availableTimes = List<String>.from(data['data']['time_slot']);
        include = List<String>.from(data['data']['include']);
        aadharStatus = data['data']['aadhaar_verify_status'].toString();
      });
      print('Response Code: ${response.statusCode}');
      print('Response Body: ${response.body} ');
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    packageLead(widget.id);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: image.isEmpty
          ? const Center(
              child: CircularProgressIndicator(
              color: Colors.deepOrange,
            ))
          : CustomScrollView(
              slivers: [
                SliverAppBar(
                  expandedHeight: 300,
                  flexibleSpace: FlexibleSpaceBar(
                    background: Image.network(
                      image,
                      fit: BoxFit.fill,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Image.asset(
                          'assets/images/mahakal.jpeg',
                          fit: BoxFit.fill,
                          width: double.infinity,
                          height: double.infinity,
                        );
                      },
                      errorBuilder: (context, error, stackTrace) => Image.asset(
                        'assets/images/mahakal.jpeg',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  pinned: true,
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Package Name with improved hierarchy
                        Text(
                          enTempleName,
                          style: TextStyle(
                            fontSize: 22,
                            color: Colors.deepOrange.shade800,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 4),

                        // Subtitle with subtle styling
                        Text(
                          name,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.deepOrange.shade600,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Price with better visual prominence
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.deepOrange.shade50,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Text(
                                'Price',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.deepOrange.shade900,
                                ),
                              ),
                              const Spacer(),
                              Text(
                                '₹$price',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.deepOrange.shade900,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'per person',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.blueGrey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // "What's included" section with improved styling
                        Container(
                          padding: const EdgeInsets.only(bottom: 8),
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: Colors.grey.shade300,
                                width: 1,
                              ),
                            ),
                          ),
                          child: Text(
                            'What will it include?',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey.shade800,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Inclusion list with better spacing
                        ListView.builder(
                          padding: EdgeInsets.zero,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: include.length,
                          itemBuilder: (context, index) {
                            return Column(
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(2),
                                      decoration: BoxDecoration(
                                        color: Colors.deepOrange.shade100,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.check_circle,
                                        color: Colors.deepOrange,
                                        size: 20,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Text(
                                        include[index],
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.grey.shade700,
                                          height: 1.4,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 3),
                              ],
                            );
                          },
                        ),
                        const SizedBox(height: 24),

                        // Date selection with enhanced UI
                        Text(
                          'Select Date',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade800,
                          ),
                        ),
                        const SizedBox(height: 12),
                        GestureDetector(
                          onTap: () => _selectDate(context),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.grey.shade300,
                                width: 1.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.1),
                                  spreadRadius: 1,
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.calendar_today,
                                  color: Colors.deepOrange,
                                  size: 24,
                                ),
                                const SizedBox(width: 16),
                                Text(
                                  selectedDate == null
                                      ? 'Choose a date'
                                      : DateFormat('EEE, MMM d, y')
                                          .format(selectedDate!),
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: selectedDate == null
                                        ? Colors.grey.shade500
                                        : Colors.grey.shade800,
                                  ),
                                ),
                                const Spacer(),
                                Icon(
                                  Icons.arrow_forward_ios,
                                  size: 16,
                                  color: Colors.grey.shade500,
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Time selection with better chips
                        if (selectedDate != null) ...[
                          Text(
                            'Select Time Slot',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey.shade800,
                            ),
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            height: 60,
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              itemCount: availableTimes.where((timeRange) {
                                // अगर future date है → सारे slots allow
                                if (selectedDate != null &&
                                    !isSameDate(selectedDate, DateTime.now())) {
                                  return true;
                                }

                                // आज की date है → time check करो
                                final parts = timeRange.split(' - ');
                                if (parts.length != 2) return false;

                                final endTime = _parseTimeOfDay(parts[1]);
                                final now = TimeOfDay.now();

                                return !_isTimeBefore(endTime, now);
                              }).length,
                              separatorBuilder: (context, index) =>
                                  const SizedBox(width: 8),
                              itemBuilder: (context, index) {
                                final validTimes =
                                    availableTimes.where((timeRange) {
                                  if (selectedDate != null &&
                                      !isSameDate(
                                          selectedDate, DateTime.now())) {
                                    return true;
                                  }

                                  final parts = timeRange.split(' - ');
                                  if (parts.length != 2) return false;

                                  final endTime = _parseTimeOfDay(parts[1]);
                                  final now = TimeOfDay.now();

                                  return !_isTimeBefore(endTime, now);
                                }).toList();

                                final timeRange = validTimes[index];

                                return ChoiceChip(
                                  label: Text(
                                    timeRange,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: selectedTime == timeRange
                                          ? Colors.white
                                          : Colors.deepOrange,
                                    ),
                                  ),
                                  selected: selectedTime == timeRange,
                                  selectedColor: Colors.deepOrange,
                                  backgroundColor: Colors.deepOrange.shade50,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    side: BorderSide(
                                      color: selectedTime == timeRange
                                          ? Colors.deepOrange
                                          : Colors.grey.shade300,
                                    ),
                                  ),
                                  onSelected: (selected) {
                                    setState(() {
                                      selectedTime =
                                          selected ? timeRange : null;
                                    });
                                  },
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 30),
                        ],

                        // Continue button with better styling
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: selectedDate != null &&
                                    selectedTime != null
                                ? () {
                                    print(
                                        ' $price \n $name \n ${widget.id} \n $selectedDate \n $selectedTime');
                                    Navigator.push(
                                        context,
                                        CupertinoPageRoute(
                                            builder: (context) =>
                                                paymentDetailView(
                                                  billAmount: price,
                                                  name: name,
                                                  leadId: widget.id,
                                                  date: '$selectedDate',
                                                  time: '$selectedTime',
                                                  aadharStatus: aadharStatus,
                                                )));
                                  }
                                : null,
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 14, horizontal: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              backgroundColor: Colors.deepOrange,
                              disabledBackgroundColor:
                                  Colors.deepOrange.shade100,
                              elevation: 3,
                              shadowColor: Colors.deepOrange.withOpacity(0.3),
                            ),
                            child: const Center(
                              child: Text(
                                'Continue',
                                style: TextStyle(
                                    fontSize: 18, color: Colors.white),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }

// Parse time (07:00 AM → TimeOfDay)
  TimeOfDay _parseTimeOfDay(String time) {
    final format = DateFormat('hh:mm a');
    final dt = format.parse(time);
    return TimeOfDay.fromDateTime(dt);
  }

// Compare 2 times
  bool _isTimeBefore(TimeOfDay t1, TimeOfDay t2) {
    return t1.hour < t2.hour || (t1.hour == t2.hour && t1.minute <= t2.minute);
  }

// Check same date
  bool isSameDate(DateTime? d1, DateTime d2) {
    if (d1 == null) return false;
    return d1.year == d2.year && d1.month == d2.month && d1.day == d2.day;
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.deepOrange, // Header background color
              onPrimary: Colors.white, // Header text color
              onSurface: Colors.black, // Body text color
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Colors.deepOrange, // Button text color
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
        selectedTime = null;
      });
    }
  }
}
