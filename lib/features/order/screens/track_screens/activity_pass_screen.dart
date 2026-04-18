import 'dart:typed_data';
import 'dart:ui';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../utill/app_constants.dart';
import '../../../../utill/loading_datawidget.dart';
import '../../../Tickit_Booking/controller/activity_pass_controller.dart';
import '../../../Tickit_Booking/model/activity_pass_model.dart';

class ActivityPassScreen extends StatefulWidget {
  final String eventOrderId;
  final bool isEnglish;

  const ActivityPassScreen({
    super.key,
    required this.eventOrderId,
    this.isEnglish = true,
  });

  @override
  State<ActivityPassScreen> createState() => _ActivityPassScreenState();
}

class _ActivityPassScreenState extends State<ActivityPassScreen> {
  List<GlobalKey> _passKeys = [];

  @override
  void initState() {
    super.initState();
    _fetchPasses();
  }

  Future<void> _fetchPasses() async {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final controller = context.read<ActivitiesPassController>();
      controller.clearData();
      controller.fetchActivitiesPass(orderId: widget.eventOrderId);
    });
  }

  String _formatSeatNumber(Datum passData) {
    if (passData.rows == null || passData.seats == null) {
      return "General Entry";
    }

    if (passData.rows!.isEmpty || passData.seats!.isEmpty) {
      return "General Entry";
    }

    String row = passData.rows!;
    String seat = passData.seats!;

    if (seat.contains(',')) {
      List<String> seatList = seat.split(',');
      List<String> formattedSeats = seatList.map((s) => "$row-$s".trim()).toList();
      return formattedSeats.join(', ');
    } else {
      return "$row-$seat";
    }
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return "TBD";
    return dateStr; // Already in format "28 Feb, 2026 12:00 PM"
  }

  String _getPackageName(Datum passData, bool isEnglish) {
    if (isEnglish) {
      return passData.enPackageName ?? "General Ticket";
    } else {
      return passData.hiPackageName ?? "जनरल टिकट";
    }
  }

  String _getCategoryName(Datum passData, bool isEnglish) {
    if (isEnglish) {
      return passData.enCategoryName ?? "VR Darshan";
    } else {
      return passData.hiCategoryName ?? "VR दर्शन";
    }
  }

  Future<String?> _captureAndSave(int index) async {
    try {
      await WidgetsBinding.instance.endOfFrame;

      RenderRepaintBoundary? boundary = _passKeys[index]
          .currentContext
          ?.findRenderObject() as RenderRepaintBoundary?;

      if (boundary == null) {
        debugPrint("Boundary is null — widget not rendered yet.");
        return null;
      }

      var image = await boundary.toImage(pixelRatio: 4.0);
      ByteData? byteData = await image.toByteData(format: ImageByteFormat.png);
      Uint8List pngBytes = byteData!.buffer.asUint8List();

      final directory = await getApplicationDocumentsDirectory();
      String filePath = '${directory.path}/activity_pass_$index.png';
      File file = File(filePath);
      await file.writeAsBytes(pngBytes);

      return filePath;
    } catch (e) {
      debugPrint("Error capturing image: $e");
      return null;
    }
  }

  Future<void> _sharePass(int index, Datum passData) async {
    String? filePath = await _captureAndSave(index);
    String shareUrl = passData.footerUrl ?? "https://sit.resrv.in";

    String eventName = widget.isEnglish ? passData.enEventName! : passData.hiEventName!;
    String venueName = widget.isEnglish ? passData.enEventVenue! : passData.hiEventVenue!;
    String seatNumber = _formatSeatNumber(passData);
    String packageName = _getPackageName(passData, widget.isEnglish);

    if (filePath != null) {
      if (widget.isEnglish) {
        await Share.shareXFiles([XFile(filePath!)], text: '''
🎟️ **Your ${packageName} Pass is Ready!**  

📅 **Event:** ${eventName}  
📍 **Venue:** ${venueName}  
💺 **Seat:** ${seatNumber}  
💰 **Price:** ₹${passData.amount ?? 0}  

🔗 **Download our app for more amazing events!**  
📲 $shareUrl  

#MahakalDarshan #VRDarshan #Ujjain
        ''');
      } else {
        await Share.shareXFiles([XFile(filePath!)], text: '''
🎟️ **आपका ${packageName} पास तैयार है!**  

📅 **इवेंट:** ${eventName}  
📍 **स्थान:** ${venueName}  
💺 **सीट:** ${seatNumber}  
💰 **मूल्य:** ₹${passData.amount ?? 0}  

🔗 **और शानदार इवेंट्स के लिए हमारा ऐप डाउनलोड करें!**  
📲 $shareUrl  

#महाकालदर्शन #वीआरदर्शन #उज्जैन
        ''');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.isEnglish ? "Activity Passes" : "एक्टिविटी पास",
          style: const TextStyle(
            color: Color(0xFFFF6B4A),
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Consumer<ActivitiesPassController>(
        builder: (context, controller, child) {
          if (controller.isLoading) {
            return const MahakalLoadingData(onReload: null);
          }

          if (!controller.hasPasses) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.confirmation_number_outlined,
                    size: 80,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    widget.isEnglish
                        ? "No passes available"
                        : "कोई पास उपलब्ध नहीं है",
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _fetchPasses,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF6B4A),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: Text(
                      widget.isEnglish ? "Retry" : "पुनः प्रयास करें",
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),
            );
          }

          if (_passKeys.length != controller.totalPasses) {
            _passKeys = List.generate(controller.totalPasses, (index) => GlobalKey());
          }

          return Container(
            height: MediaQuery.of(context).size.height * 0.80,
            margin: const EdgeInsets.symmetric(vertical: 16),
            child: PageView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: controller.totalPasses,
              itemBuilder: (context, index) {
                final passData = controller.getPassDataByIndex(index);
                if (passData == null) return const SizedBox();

                String eventName = widget.isEnglish ? passData.enEventName! : passData.hiEventName!;
                String venueName = widget.isEnglish ? passData.enEventVenue! : passData.hiEventVenue!;
                String passHolderName = passData.passUserName ?? "User";
                String seatNumber = _formatSeatNumber(passData);
                String date = _formatDate(passData.eventDate);
                String packageName = _getPackageName(passData, widget.isEnglish);
                String categoryName = _getCategoryName(passData, widget.isEnglish);
                int amount = passData.amount ?? 0;
                int totalSeats = passData.totalSeats ?? 1;

                String time = "";
                if (passData.eventDate != null && passData.eventDate!.contains(" ")) {
                  List<String> parts = passData.eventDate!.split(" ");
                  if (parts.length > 2) {
                    time = "${parts[2]} ${parts[3] ?? ""}";
                  }
                }

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: RepaintBoundary(
                    key: _passKeys[index],
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.15),
                            blurRadius: 20,
                            offset: const Offset(0, 5),
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          // Top colored strip
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [
                                  Color(0xFFFF6B4A),
                                  Color(0xFFFF8A5C),
                                ],
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              ),
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(20),
                                topRight: Radius.circular(20),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    const Text(
                                      "🕉️",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      widget.isEnglish ? "MAHAKAL DARSHAN" : "महाकाल दर्शन",
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    "${index + 1}/$totalSeats",
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Main content
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                children: [
                                  // Top details section
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // Left side - Event details
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "श्री महाकालेश्वर ज्योतिर्लिंग",
                                              style: TextStyle(
                                                color: Colors.grey.shade600,
                                                fontSize: 11,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              eventName.toUpperCase(),
                                              style: const TextStyle(
                                                color: Color(0xFFFF6B4A),
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                              ),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            const SizedBox(height: 6),
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                              decoration: BoxDecoration(
                                                color: const Color(0xFFFF6B4A).withOpacity(0.1),
                                                borderRadius: BorderRadius.circular(4),
                                              ),
                                              child: Text(
                                                "$packageName • $categoryName",
                                                style: TextStyle(
                                                  color: const Color(0xFFFF6B4A),
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            Row(
                                              children: [
                                                Icon(Icons.calendar_today, size: 11, color: Colors.grey.shade600),
                                                const SizedBox(width: 4),
                                                Text(
                                                  date.split(" ")[0] + " " + date.split(" ")[1],
                                                  style: TextStyle(fontSize: 11, color: Colors.grey.shade800),
                                                ),
                                                const SizedBox(width: 8),
                                                Icon(Icons.access_time, size: 11, color: Colors.grey.shade600),
                                                const SizedBox(width: 4),
                                                Text(
                                                  time.isNotEmpty ? time : "12:00 PM",
                                                  style: TextStyle(fontSize: 11, color: Colors.grey.shade800),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),

                                      // Right side - Devotee name and price
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.end,
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.all(10),
                                              decoration: BoxDecoration(
                                                color: const Color(0xFFFF6B4A).withOpacity(0.05),
                                                borderRadius: BorderRadius.circular(10),
                                              ),
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.end,
                                                children: [
                                                  Text(
                                                    widget.isEnglish ? "DEVOTEE" : "भक्त",
                                                    style: TextStyle(fontSize: 9, color: Colors.grey.shade500),
                                                  ),
                                                  Text(
                                                    passHolderName,
                                                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                                                  ),
                                                  const SizedBox(height: 6),
                                                  Text(
                                                    widget.isEnglish ? "PRICE" : "कीमत",
                                                    style: TextStyle(fontSize: 9, color: Colors.grey.shade500),
                                                  ),
                                                  Text(
                                                    "₹$amount",
                                                    style: const TextStyle(
                                                      fontSize: 16,
                                                      fontWeight: FontWeight.bold,
                                                      color: Color(0xFFFF6B4A),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 20,),

                                  // Center - Big QR Code
                                  Container(
                                    width: 250,
                                    height: 250,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      border: Border.all(
                                        color: const Color(0xFFFF6B4A).withOpacity(0.3),
                                        width: 2,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: const Color(0xFFFF6B4A).withOpacity(0.1),
                                          blurRadius: 15,
                                          spreadRadius: 2,
                                        ),
                                      ],
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(14),
                                      child: Image.network(
                                        passData.passUrl!,
                                        fit: BoxFit.cover,
                                        width: 216,
                                        height: 216,
                                        errorBuilder: (context, error, stackTrace) {
                                          return Icon(
                                            Icons.qr_code,
                                            size: 150,
                                            color: const Color(0xFFFF6B4A).withOpacity(0.3),
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 20,),

                                  // Bottom - Seat number and contact info
                                  Column(
                                    children: [
                                      // Seat number in big display
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFFF6B4A).withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(30),
                                          border: Border.all(
                                            color: const Color(0xFFFF6B4A).withOpacity(0.3),
                                            width: 1.5,
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const Icon(
                                              Icons.event_seat,
                                              color: Color(0xFFFF6B4A),
                                              size: 16,
                                            ),
                                            const SizedBox(width: 10),
                                            Text(
                                              seatNumber,
                                              style: const TextStyle(
                                                color: Color(0xFFFF6B4A),
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 16),

                                      // Contact info
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          if (passData.footerPhone != null) ...[
                                            Icon(Icons.phone, size: 12, color: Colors.grey.shade400),
                                            const SizedBox(width: 4),
                                            Text(
                                              passData.footerPhone!,
                                              style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
                                            ),
                                          ],
                                          if (passData.footerPhone != null && passData.footerEmail != null) ...[
                                            Container(width: 1, height: 12, color: Colors.grey.shade300, margin: const EdgeInsets.symmetric(horizontal: 8)),
                                          ],
                                          if (passData.footerEmail != null) ...[
                                            Icon(Icons.email, size: 12, color: Colors.grey.shade400),
                                            const SizedBox(width: 4),
                                            Text(
                                              passData.footerEmail!,
                                              style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // Bottom share button
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade50,
                              borderRadius: const BorderRadius.only(
                                bottomLeft: Radius.circular(20),
                                bottomRight: Radius.circular(20),
                              ),
                              border: Border(
                                top: BorderSide(color: Colors.grey.shade200, width: 1),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                GestureDetector(
                                  onTap: () => _sharePass(index, passData),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        colors: [Color(0xFFFF6B4A), Color(0xFFFF8A5C)],
                                      ),
                                      borderRadius: BorderRadius.circular(25),
                                      boxShadow: [
                                        BoxShadow(
                                          color: const Color(0xFFFF6B4A).withOpacity(0.3),
                                          blurRadius: 8,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(Icons.share, color: Colors.white, size: 18),
                                        const SizedBox(width: 8),
                                        Text(
                                          widget.isEnglish ? "SHARE PASS" : "पास शेयर करें",
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}