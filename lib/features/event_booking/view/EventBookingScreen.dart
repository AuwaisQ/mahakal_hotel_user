import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class EventBookingScreen extends StatefulWidget {
  @override
  _EventBookingScreenState createState() => _EventBookingScreenState();
}

class _EventBookingScreenState extends State<EventBookingScreen> {
  int _currentStep = 0; // 0: Venue, 1: Date & Time, 2: Tickets
  int? _selectedVenueIndex;
  int? _selectedDateIndex;
  int? _selectedTicketIndex;

  // Sample data
  final List<Map<String, String>> venues = [
    {
      "en_event_venue": "Ujjain, Madhya Pradesh, India",
      "en_event_venue_full_address": "Mahakal Ground",
      "en_event_country": "India",
      "en_event_state": "Madhya Pradesh",
    },
    {
      "en_event_venue": "Indore, Madhya Pradesh, India",
      "en_event_venue_full_address": "Brilliant Convention Center",
      "en_event_country": "India",
      "en_event_state": "Madhya Pradesh",
    },
    {
      "en_event_venue": "Bhopal, Madhya Pradesh, India",
      "en_event_venue_full_address": "Lake View Resort",
      "en_event_country": "India",
      "en_event_state": "Madhya Pradesh",
    },
  ];

  final List<Map<String, dynamic>> dates = [
    {
      "date": "15 OCT",
      "day": "Tuesday",
      "times": ["10:00 AM", "2:00 PM", "6:00 PM"]
    },
    {
      "date": "16 OCT",
      "day": "Wednesday",
      "times": ["11:00 AM", "3:00 PM", "7:00 PM"]
    },
    {
      "date": "17 OCT",
      "day": "Thursday",
      "times": ["10:30 AM", "2:30 PM", "6:30 PM"]
    },
    {
      "date": "18 OCT",
      "day": "Friday",
      "times": ["12:00 PM", "4:00 PM", "8:00 PM"]
    },
  ];

  final List<Map<String, dynamic>> tickets = [
    {
      "type": "Golden",
      "price": "₹ 1500",
      "booked": 120,
      "remaining": 30,
      "total": 150,
      "sold_out": false,
      "description":
          "Front row seats with the best view of the event. Includes complimentary refreshments."
    },
    {
      "type": "Silver",
      "price": "₹ 1000",
      "booked": 200,
      "remaining": 50,
      "total": 250,
      "sold_out": false,
      "description":
          "Great view from the middle section. Comfortable seating with good visibility."
    },
    {
      "type": "Bronze",
      "price": "₹ 600",
      "booked": 280,
      "remaining": 20,
      "total": 300,
      "sold_out": true,
      "description":
          "Economy seating with decent view. Perfect for those on a budget."
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Event Booking Packages',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 22,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.deepOrange,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.deepOrange.shade50,
              Colors.orange.shade50,
            ],
          ),
        ),
        child: Column(
          children: [
            // Stepper Header
            _buildStepperHeader(),
            Divider(height: 1, thickness: 1, color: Colors.grey.shade300),

            // Content based on current step
            Expanded(
              child: _buildStepContent(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepperHeader() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildStep(0, "Venue"),
          Container(
            height: 1,
            width: 30,
            color: Colors.grey.shade300,
          ),
          _buildStep(1, "Date & Time"),
          Container(
            height: 1,
            width: 30,
            color: Colors.grey.shade300,
          ),
          _buildStep(2, "Tickets"),
        ],
      ),
    );
  }

  Widget _buildStep(int stepIndex, String title) {
    bool isActive = _currentStep == stepIndex;
    bool isCompleted = _currentStep > stepIndex;
    bool isEnabled = isActive || isCompleted || stepIndex == _currentStep + 1;

    return GestureDetector(
      onTap: isEnabled
          ? () {
              setState(() {
                _currentStep = stepIndex;
              });
            }
          : null,
      child: Opacity(
        opacity: isEnabled ? 1.0 : 0.5,
        child: Column(
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: isActive
                        ? Colors.deepOrange
                        : isCompleted
                            ? Colors.green
                            : Colors.grey.shade300,
                    shape: BoxShape.circle,
                    boxShadow: isActive
                        ? [
                            BoxShadow(
                              color: Colors.deepOrange.withOpacity(0.3),
                              spreadRadius: 2,
                              blurRadius: 6,
                              offset: Offset(0, 2),
                            )
                          ]
                        : [],
                  ),
                  child: Center(
                    child: isCompleted
                        ? Icon(Icons.check, color: Colors.white, size: 20)
                        : Text(
                            (stepIndex + 1).toString(),
                            style: TextStyle(
                              color: isActive
                                  ? Colors.white
                                  : Colors.grey.shade700,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                  ),
                ),
                if (isActive)
                  CircularProgressIndicator(
                    value: 1.0,
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                        Colors.deepOrange.shade700),
                    backgroundColor: Colors.deepOrange.shade100,
                  ),
              ],
            ),
            SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                color: isActive ? Colors.deepOrange : Colors.grey.shade700,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepContent() {
    switch (_currentStep) {
      case 0:
        return _buildVenueStep();
      case 1:
        return _buildDateTimeStep();
      case 2:
        return _buildTicketsStep();
      default:
        return _buildVenueStep();
    }
  }

  Widget _buildVenueStep() {
    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: venues.length,
      itemBuilder: (context, index) {
        final venue = venues[index];
        final isSelected = _selectedVenueIndex == index;

        return Card(
          elevation: 4,
          margin: EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: isSelected
                ? BorderSide(color: Colors.deepOrange, width: 2)
                : BorderSide.none,
          ),
          child: ListTile(
            leading: Icon(
              Icons.location_on,
              color: isSelected ? Colors.deepOrange : Colors.grey,
              size: 28,
            ),
            title: Text(
              venue["en_event_venue"]!,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
                color: isSelected ? Colors.deepOrange : Colors.black87,
              ),
            ),
            subtitle: Text(
              venue["en_event_venue_full_address"]!,
              style: TextStyle(
                color: isSelected
                    ? Colors.deepOrange.shade600
                    : Colors.grey.shade600,
              ),
            ),
            trailing: isSelected
                ? Icon(Icons.check_circle, color: Colors.deepOrange)
                : null,
            onTap: () {
              setState(() {
                _selectedVenueIndex = index;
                _currentStep = 1; // Move to next step
              });
            },
          ),
        );
      },
    );
  }

  Widget _buildDateTimeStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            "Select Date",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.deepOrange.shade800,
            ),
          ),
        ),
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              // Calculate number of columns based on screen width
              final crossAxisCount = constraints.maxWidth > 400 ? 4 : 3;

              return GridView.builder(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount:
                      crossAxisCount, // More columns for smaller boxes
                  crossAxisSpacing: 8, // Reduced spacing
                  mainAxisSpacing: 8, // Reduced spacing
                  childAspectRatio: 0.9, // Proper aspect ratio for small boxes
                ),
                itemCount: dates.length,
                itemBuilder: (context, index) {
                  final date = dates[index];
                  final isSelected = _selectedDateIndex == index;

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedDateIndex = index;
                        _currentStep = 2; // Move to next step
                      });
                    },
                    child: Container(
                      padding: EdgeInsets.all(8), // Reduced padding
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.deepOrange : Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isSelected
                              ? Colors.deepOrange
                              : Colors.grey.shade300,
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.2),
                            spreadRadius: 1,
                            blurRadius: 3,
                            offset: Offset(0, 1),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            date["date"],
                            style: TextStyle(
                              fontSize: 14, // Smaller font
                              fontWeight: FontWeight.bold,
                              color:
                                  isSelected ? Colors.white : Colors.deepOrange,
                            ),
                          ),
                          SizedBox(height: 2), // Reduced spacing
                          Text(
                            date["day"],
                            style: TextStyle(
                              fontSize: 10, // Smaller font
                              color: isSelected
                                  ? Colors.white
                                  : Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTicketsStep() {
    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: tickets.length,
      itemBuilder: (context, index) {
        final ticket = tickets[index];
        final isSelected = _selectedTicketIndex == index;
        final isSoldOut = ticket["sold_out"];

        return Card(
          elevation: 4,
          margin: EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: isSelected
                ? BorderSide(color: Colors.deepOrange, width: 2)
                : BorderSide.none,
          ),
          child: Column(
            children: [
              ListTile(
                leading: Icon(
                  Icons.confirmation_number,
                  color: isSoldOut ? Colors.grey : Colors.deepOrange,
                  size: 28,
                ),
                title: Text(
                  "${ticket["type"]} Ticket",
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: isSoldOut ? Colors.grey : Colors.black87,
                  ),
                ),
                subtitle: Text(
                  ticket["price"],
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: isSoldOut ? Colors.grey : Colors.deepOrange,
                  ),
                ),
                trailing: isSoldOut
                    ? Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.red.shade100,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          "SOLD OUT",
                          style: TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      )
                    : null,
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Booked: ${ticket["booked"]}",
                      style:
                          TextStyle(fontSize: 12, color: Colors.grey.shade600),
                    ),
                    Text(
                      "Remaining: ${ticket["remaining"]}",
                      style:
                          TextStyle(fontSize: 12, color: Colors.grey.shade600),
                    ),
                    Text(
                      "Total: ${ticket["total"]}",
                      style:
                          TextStyle(fontSize: 12, color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: IconButton(
                        icon:
                            Icon(Icons.info_outline, color: Colors.deepOrange),
                        onPressed: () {
                          setState(() {
                            _selectedTicketIndex =
                                _selectedTicketIndex == index ? null : index;
                          });
                        },
                      ),
                    ),
                    if (!isSoldOut)
                      ElevatedButton(
                        onPressed: () {
                          // Navigate to payment page
                          print(
                              "Proceed to payment for ${ticket["type"]} ticket");
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepOrange,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: Text(
                          "Book Now",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                  ],
                ),
              ),
              if (_selectedTicketIndex == index)
                Padding(
                  padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: Text(
                    ticket["description"],
                    style: TextStyle(
                      color: Colors.grey.shade700,
                      fontSize: 14,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
