// import 'dart:async';
// import 'dart:convert';
// import 'dart:math';
//
// import 'package:auto_size_text/auto_size_text.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:mahakal/features/Jaap/screen/history.dart';
// import 'package:geocoding/geocoding.dart';
// // import 'package:flutter_vibrate/flutter_vibrate.dart';
// // import 'package:just_audio/just_audio.dart';
// import 'package:http/http.dart' as http;
// import 'package:intl/intl.dart';
// import 'package:mahakal/features/Jaap/wallpaper/wallpaper.dart';
// import 'package:provider/provider.dart';
// import 'package:signature/signature.dart';
// import 'package:tdk_bouncingwidget/tdk_bouncingwidget.dart';
//
// import '../../../data/datasource/remote/http/httpClient.dart';
// import '../../../main.dart';
// import '../../../utill/app_constants.dart';
// import '../../auth/controllers/auth_controller.dart';
// import '../jap_database.dart';
// import 'all_mantra.dart';
//
// class JaapView extends StatefulWidget {
//   int initialIndex;
//   JaapView({super.key, this.initialIndex = 0});
//
//   @override
//   State<JaapView> createState() => _JaapViewState();
// }
//
// class Person {
//   String id;
//   String name;
//   final bool isCustom;
//   Person({required this.id, required this.name,this.isCustom = false});
// }
//
// class _JaapViewState extends State<JaapView> with TickerProviderStateMixin {
//   //----------------------JAAP TAB STARTS----------------------------
//
//   Color _mantraColor = Colors.orange; // Default color
//
//   // Add these variables to your state class
//   double _mantraFontSize = 18.0; // Default font size
//   final double _minFontSize = 10.0;
//   final double _maxFontSize = 42.0;
//
//   // Custom mantra variables
//   TextEditingController _customMantraController = TextEditingController();
//   TextEditingController _customMantraNameController = TextEditingController();
//   bool _isPostingMantra = false;
//   String? userToken; // Make sure you have this from your auth
//
//   // Add this variable to your state class
//   bool _isLoadingMantras = false;
//
//   // Add this variable to your state
//   bool _isNavigatingToAllMantras = false;
//
//   // Add these variables to your state
//   int _currentPage = 1;
//   int _itemsPerPage = 8;
//   List<JaapList> _displayedMantras = [];
//
//   // Add these variables to your state class
//   TimeOfDay? _selectedStartTime;
//   TimeOfDay? _selectedEndTime;
//   int _selectedCount = 108;
//   DateTime? _sankalpStartDate;
//   DateTime? _sankalpEndDate;
//
//   // Add this variable to your state class
//   String? _selectedMantraForSankalp;
//   // Add this loading variable to your state class
//   bool _isTakingSankalp = false;
//   JaapList? _currentJaapList; // Add this near your other state variables
//
//
//   // Sankalp variables
//   DateTime? _startDate;
//   DateTime? _endDate;
//   TimeOfDay? _selectedTime;
//   int _targetCount = 108;
//   Duration? _duration;
//   bool _hasSankalp = false;
//   List<JaapList> _customMantras = [];
//
//
//   final Iterable<Duration> pauses = [
//     const Duration(milliseconds: 500),
//     const Duration(milliseconds: 1000),
//     const Duration(milliseconds: 500),
//   ];
//
//   // our jaap app tab controller
//   late TabController _tabController;
//   int tabIndex = 0;
//
//   List<dynamic> myList = [];
//
//   // jaap app background image
//   final String _selectedImage = 'assets/images/jaap/ram_3.png';
//
//   bool _vibrationEnabled = true; // Default vibration state is on
//
//   // setting bottom sheet 3 circle in row
//   int itemColorIndex = 0;
//
//
//   // jaap page mantra list
//   String _selectedItem = '';
//   double getFontSize(String name, num screenwidth) {
//     double fontSizeRatio;
//
//     switch (name) {
//       case 'Ram Naam Jaap(राम नाम जाप)':
//         fontSizeRatio = 0.10;
//         break;
//       case 'Shiv Jaap(शिव जाप)':
//         fontSizeRatio = 0.12;
//         break;
//       case 'Krishna Jaap(कृष्ण जाप)':
//         fontSizeRatio = 0.07;
//         break;
//       case 'Ganesh Jaap(गणेश जाप)':
//         fontSizeRatio = 0.1;
//         break;
//       case 'Gayatri Mantra Jaap(गायत्री मंत्र जाप)':
//         fontSizeRatio = 0.05;
//         break;
//       case 'Vishnu Mantra Jaap(विष्णु मंत्र जाप)':
//         fontSizeRatio = 0.07;
//         break;
//       case 'Ram Jaap(राम जाप)':
//         fontSizeRatio = 0.07;
//         break;
//       case 'Durga Jaap(दुर्गा जाप)':
//         fontSizeRatio = 0.05;
//         break;
//       case 'Vishnu Jaap(विष्णु जाप)':
//         fontSizeRatio = 0.09;
//         break;
//       case 'Laxmi Mantra Jaap(लक्ष्मी मंत्र जाप)':
//         fontSizeRatio = 0.08;
//         break;
//       case 'Mahamrityunjay Jaap(महामृत्युंजय जाप)':
//         fontSizeRatio = 0.05;
//         break;
//       default:
//         fontSizeRatio = 0.08;
//     }
//     return fontSizeRatio * screenwidth;
//   }
//
//   // jaap count animation
//   late AnimationController _animationController;
//   late Animation<double> _animation;
//
//   // jaap page loop count
//   int _loopCounter = 0;
//   // jaap page main big circle count
//   int _tapCounter = 0;
//   // jaap page score count
//   int product = 0;
//   // jaap page loop count from list 11,20,30
//   int _tapsPerLoop = 11;
//   // Track previous loop counter to detect completion
//
//
//   List<JaapList> jaapModelList = <JaapList>[];
//   // Add these to your state variables
//   bool _useHindi = false; // Language preference - you can make this toggleable
//   // Add language state variable at the top of your widget class
//   bool _isHindi = true; // Default to Hindi
//
//
//
//
//   // Update your getJaapMantra method to initialize displayed mantras
//   void getJaapMantra() async {
//     try {
//       print('Fetching jaap mantra...');
//
//       setState(() {
//         _isLoadingMantras = true;
//       });
//
//       var res = await HttpService().getApi('/api/v1/jaap');
//
//       print('Full API Response:');
//       print('Status: ${res['status']}');
//       print('Complete Response JSON:');
//       print(res);
//
//       if (res['status'] == true) {
//         setState(() {
//           List data = res['data'];
//
//           // Clear existing lists
//           jaapModelList.clear();
//           _customMantras.clear();
//
//           // Add all mantras to main list
//           jaapModelList.addAll(data.map((e) => JaapList.fromJson(e)));
//
//           // Get custom mantras
//           _customMantras = jaapModelList.where((mantra) {
//             return mantra.type?.toLowerCase() == 'custom' ||
//                 mantra.type?.toLowerCase().contains('user') == true;
//           }).toList();
//
//           // IMPORTANT: Sort mantras - custom mantras first, then others
//           // This ensures new custom mantras are visible at the top
//           jaapModelList.sort((a, b) {
//             bool aIsCustom = _customMantras.any((custom) => custom.id == a.id);
//             bool bIsCustom = _customMantras.any((custom) => custom.id == b.id);
//
//             if (aIsCustom && !bIsCustom) return -1;
//             if (!aIsCustom && bIsCustom) return 1;
//             return 0;
//           });
//
//           // Reset pagination and display ALL mantras initially
//           _currentPage = 1;
//           // Show more items per page initially to ensure visibility
//           _itemsPerPage = 10; // Increase from default 2
//           _displayedMantras = _getPaginatedMantras();
//
//           _isLoadingMantras = false;
//         });
//
//         print('Successfully loaded ${jaapModelList.length} jaap items');
//         print('Custom mantras: ${_customMantras.length}');
//         print('Displayed mantras: ${_displayedMantras.length}');
//       } else {
//         setState(() {
//           _isLoadingMantras = false;
//         });
//         print('API returned non-true status: ${res['status']}');
//       }
//
//     } catch (error, stackTrace) {
//       setState(() {
//         _isLoadingMantras = false;
//       });
//       print('Error fetching jaap mantra: $error');
//       print('Stack Trace: $stackTrace');
//     }
//   }
//
//   // Helper method to get paginated mantras
//   List<JaapList> _getPaginatedMantras() {
//     int startIndex = (_currentPage - 1) * _itemsPerPage;
//     int endIndex = startIndex + _itemsPerPage;
//
//     if (endIndex > jaapModelList.length) {
//       endIndex = jaapModelList.length;
//     }
//
//     return jaapModelList.sublist(startIndex, endIndex);
//   }
//
//   // Method to load more mantras
//   void _loadMoreMantras() {
//     if ((_currentPage * _itemsPerPage) < jaapModelList.length) {
//       setState(() {
//         _currentPage++;
//         _displayedMantras.addAll(_getPaginatedMantras());
//       });
//     }
//   }
//
//   // Method to check if there are more mantras to load
//   bool _hasMoreMantras() {
//     return (_currentPage * _itemsPerPage) < jaapModelList.length;
//   }
//
//   Future<void> _addCustomMantraToApi(String mantraText, {String? mantraName}) async {
//     try {
//       setState(() {
//         _isPostingMantra = true;
//       });
//
//       print('Adding custom mantra: $mantraText');
//       print('Mantra name (optional): $mantraName');
//
//       // Get user ID - replace with actual user ID from your app
//       int userIdToSend = 252; // Change this to get actual user ID
//
//       // Prepare the request with ALL fields including optional name
//       final Map<String, dynamic> requestBody = {
//         'mantra': mantraText,
//         'user_id': userIdToSend,
//         'name': mantraName?.isNotEmpty == true ? mantraName : "", // Send empty string if no name
//       };
//
//       print('Request body: $requestBody');
//       print('User Token: $userToken');
//
//       // Make the POST request
//       final response = await http.post(
//         Uri.parse('https://sit.resrv.in/api/v1/jaap/add-mantra'),
//         headers: {
//           'Authorization': 'Bearer $userToken',
//           'Content-Type': 'application/json',
//           'Accept': 'application/json',
//         },
//         body: jsonEncode(requestBody),
//       );
//
//       print('Add mantra API response status: ${response.statusCode}');
//       print('Add mantra API response body: ${response.body}');
//
//       // Check for success status codes (200-299)
//       if (response.statusCode >= 200 && response.statusCode < 300) {
//         final data = jsonDecode(response.body);
//
//         if (data['status'] == true) {
//           // Parse the response using your model
//           AddMantraModel addMantraModel = AddMantraModel.fromJson(data);
//
//           // Show success message
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(
//               content: Text('Mantra added successfully!'),
//               backgroundColor: Colors.green,
//               duration: Duration(seconds: 2),
//             ),
//           );
//
//           // Clear the text fields
//           _customMantraNameController.clear();
//           _customMantraController.clear();
//
//           // Create a temporary mantra to show immediately
//           final newMantra = JaapList(
//             id: DateTime.now().millisecondsSinceEpoch, // Temporary ID
//             mantra: mantraText,
//             jaap: mantraName ?? mantraText,
//             type: 'custom',
//             hiName: "",
//             hiMantra: "",
//             image: '',
//             // Add other required properties based on your model
//           );
//
//           setState(() {
//             // Add to beginning of list so it's visible immediately
//             jaapModelList.insert(0, newMantra);
//             _customMantras.insert(0, newMantra);
//             // Refresh displayed mantras
//             _displayedMantras = _getPaginatedMantras();
//           });
//
//           // Close the dialog if it's still open
//           if (Navigator.of(context, rootNavigator: true).canPop()) {
//             Navigator.of(context, rootNavigator: true).pop();
//           }
//
//           // IMPORTANT: Refresh the mantras list from API (without await)
//           // This will fetch fresh data from server
//           getJaapMantra();
//
//         } else {
//           throw Exception(data['message'] ?? 'Failed to add mantra');
//         }
//       } else {
//         // Try to parse error message
//         try {
//           final errorData = jsonDecode(response.body);
//           throw Exception(errorData['message'] ?? 'HTTP Error: ${response.statusCode}');
//         } catch (e) {
//           throw Exception('HTTP Error: ${response.statusCode} - ${response.body}');
//         }
//       }
//
//     } catch (error) {
//       print('Error adding custom mantra: $error');
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('Failed to add mantra: ${error.toString().replaceAll("Exception: ", "")}'),
//           backgroundColor: Colors.red,
//           duration: Duration(seconds: 3),
//         ),
//       );
//     } finally {
//       setState(() {
//         _isPostingMantra = false;
//       });
//     }
//   }
//
//   // Update _takeSankalp function to handle loading state
//   void  _takeSankalp(String mantra, String mantraId) async{
//     var res = await HttpService().postApi("/api/v1/jaap/sankalp", {
//       'sankalp_name': '${mantra.substring(0, min(20, mantra.length))}...',
//       'user_id': 29, // Replace with actual user ID from your app
//       'user_mantras_id': mantraId,
//       'hours': _selectedEndTime!.hour - _selectedStartTime!.hour,
//       'count': _selectedCount,
//       'start_date': DateFormat('yyyy-MM-dd').format(_sankalpStartDate!),
//       'end_date': DateFormat('yyyy-MM-dd').format(_sankalpEndDate!),
//       'start_time': _formatTimeForAPI(_selectedStartTime!),
//       'end_time': _formatTimeForAPI(_selectedEndTime!),
//       'day': _sankalpEndDate!.difference(_sankalpStartDate!).inDays,
//     });
//     print("api sankalp response");
//     if(res['status']){
//       Navigator.pop(context);
//
//       // Show success message
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('Sankalp taken successfully! 🙏'),
//           backgroundColor: Colors.green,
//           duration: Duration(seconds: 3),
//         ),
//       );
//
//       // Update UI state
//       setState(() {
//         _hasSankalp = true;
//         _selectedItem = mantra;
//         _isTakingSankalp = false;
//       });
//
//     }
//   }
//   // Future<void> _takeSankalp(String mantra, String mantraId, BuildContext dialogContext) async {
//   //   try {
//   //     // Prepare request body with proper time formatting
//   //     final Map<String, dynamic> requestBody = {
// //       'sankalp_name': '${mantra.substring(0, min(20, mantra.length))}...',
// //       'user_id': 29, // Replace with actual user ID from your app
// //       'user_mantras_id': mantraId,
// //       'hours': _selectedEndTime!.hour - _selectedStartTime!.hour,
// //       'count': _selectedCount,
// //       'start_date': DateFormat('yyyy-MM-dd').format(_sankalpStartDate!),
// //       'end_date': DateFormat('yyyy-MM-dd').format(_sankalpEndDate!),
// //       'start_time': _formatTimeForAPI(_selectedStartTime!),
// //       'end_time': _formatTimeForAPI(_selectedEndTime!),
// //       'day': _sankalpEndDate!.difference(_sankalpStartDate!).inDays,
//   //     };
//   //
// //     print('Sankalp Request Body: $requestBody');
//   //
//   //     // Make API call
//   //     final response = await http.post(
//   //       Uri.parse('https://sit.resrv.in/api/v1/jaap/sankalp'),
// //       headers: {
//   //         'Authorization': 'Bearer $userToken',
//   //       },
// //       body: jsonEncode(requestBody),
//   //     );
//   //
// //     print('Sankalp API response status: ${response.statusCode}');
// //     print('Sankalp API response body: ${response.body}');
//   //
//   //     if (response.statusCode == 200) {
//   //       final data = jsonDecode(response.body);
//   //
//   //       if (data['status'] == true) {
//   //         // Close the dialog first
//   //         Navigator.of(dialogContext).pop();
//   //
//   //         // Show success message
//   //         ScaffoldMessenger.of(context).showSnackBar(
//   //           SnackBar(
// //             content: Text('Sankalp taken successfully! 🙏'),
// //             backgroundColor: Colors.green,
// //             duration: Duration(seconds: 3),
//   //           ),
//   //         );
//   //
//   //         // Update UI state
//   //         setState(() {
//   //           _hasSankalp = true;
//   //           _selectedItem = mantra;
//   //           _isTakingSankalp = false;
//   //         });
//   //
//   //       } else {
//   //         throw Exception(data['message'] ?? 'Failed to take sankalp');
//   //       }
//   //     } else {
// //       throw Exception('HTTP Error: ${response.statusCode}');
//   //     }
//   //
//   //   } catch (error) {
// //     print('Error taking sankalp: $error');
//   //
//   //     // Reset loading state
//   //     if (mounted) {
//   //       setState(() {
//   //         _isTakingSankalp = false;
//   //       });
//   //     }
//   //
//   //     // Show error message
//   //     ScaffoldMessenger.of(context).showSnackBar(
//   //       SnackBar(
// //         content: Text('Failed to take sankalp: ${error.toString().replaceAll("Exception: ", "")}'),
//   //         backgroundColor: Colors.red,
//   //         duration: Duration(seconds: 3),
//   //       ),
//   //     );
//   //
//   //     // Still show the mantra even if sankalp fails
//   //     if (mounted) {
//   //       setState(() {
//   //         _selectedItem = mantra;
//   //       });
//   //     }
//   //   }
//   // }
//   //
//
//   // Helper function to format time for API (HH:MM format)
//   String _formatTimeForAPI(TimeOfDay time) {
//     final hour = time.hour.toString().padLeft(2, '0');
//     final minute = time.minute.toString().padLeft(2, '0');
//     return '$hour:$minute';
//   }
//
//   void _scrollToLastSignature() {
//     if (signatures.isNotEmpty) {
//       _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
//     }
//   }
//
//   // void getJaapMantra() async{
//   //   var res = await HttpService().getApi('/api/v1/jaap');
//   //   if(res['status'] == 200){
//   //       setState(() {
//   //         List jaap = res['data'];
//   //         jaapModelList.addAll(jaap.map((e)=> JaapList.fromJson(e)));
//   //       });
//   //   }
//   //   print('Api response jaap $res');
//   // }
//
//   void _onButtonTap() {
//     print("Button tapped. Vibration enabled: $_vibrationEnabled"); // Debug
//
//     // पहले count बढ़ाएं
//     setState(() {
//       _tapCounter++;
//       product++;
//     });
//
//     // 1. माला पूर्ण होने की जाँच
//     if (_tapCounter == _tapsPerLoop) {
//       // माला पूर्ण हुई
//       setState(() {
//         _loopCounter++;
//         _tapCounter = 0;
//       });
//
//       // माला पूर्ण होने पर ALWAYS vibration (settings से independent)
//       _triggerMalaCompletionVibration();
//       print("✅ Mala $_loopCounter completed!");
//     }
//     // 2. सामान्य टैप के लिए vibration (अगर enabled है)
//     else if (_vibrationEnabled) {
//       HapticFeedback.heavyImpact();
//       print("📱 Normal tap vibration");
//     }
//
//     // Animation
//     _animationController.forward(from: 0.0);
//     Future.delayed(const Duration(milliseconds: 200), () {
//       _animationController.reverse();
//     });
//   }
//
//   void _triggerMalaCompletionVibration() {
//     print("🎯 Mala completion vibration triggered");
//
//     // Special vibration pattern for mala completion
//     // यह हमेशा चलेगा, चाहे _vibrationEnabled कुछ भी हो
//
// // Pattern 1: Strong
//     HapticFeedback.heavyImpact();
//
// // Pattern 2: Medium (थोड़ी देर बाद)
//     Future.delayed(const Duration(milliseconds: 100), () {
//       HapticFeedback.mediumImpact();
//     });
//
// // Pattern 3: Light (और थोड़ी देर बाद)
//     Future.delayed(const Duration(milliseconds: 200), () {
//       HapticFeedback.lightImpact();
//     });
//
//     // Show message
//     _showMalaCompletionMessage();
//   }
//
//
//   // माला पूर्ण होने का message
//   void _showMalaCompletionMessage() {
//     // आपके पास पहले से यह function है
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(
//           '🙏 माला ${_loopCounter} पूर्ण! 🙏',
//           textAlign: TextAlign.center,
//           style: const TextStyle(
//             fontWeight: FontWeight.bold,
//             fontSize: 16,
//           ),
//         ),
//         backgroundColor: Colors.green,
//         duration: const Duration(seconds: 2),
//         behavior: SnackBarBehavior.floating,
//         margin: const EdgeInsets.all(10),
//       ),
//     );
//   }
//
//   void _showBottomSheets() {
//     showModalBottomSheet(
//       context: context,
//       builder: (BuildContext context) {
//         return SizedBox(
//           height: 220,
//           child: ListView(
//             children: [
//               ListTile(
//                 title: const Text('11', textAlign: TextAlign.center),
//                 onTap: () {
//                   setState(() {
//                     _tapsPerLoop = 11;
//                   });
//                   Navigator.pop(context);
//                 },
//               ),
//               ListTile(
//                 title: const Text('21', textAlign: TextAlign.center),
//                 onTap: () {
//                   setState(() {
//                     _tapsPerLoop = 21;
//                   });
//                   Navigator.pop(context);
//                 },
//               ),
//               ListTile(
//                 title: const Text('51', textAlign: TextAlign.center),
//                 onTap: () {
//                   setState(() {
//                     _tapsPerLoop = 51;
//                   });
//                   Navigator.pop(context);
//                 },
//               ),
//               ListTile(
//                 title: const Text('101', textAlign: TextAlign.center),
//                 onTap: () {
//                   setState(() {
//                     _tapsPerLoop = 101;
//                   });
//                   Navigator.pop(context);
//                 },
//               ),
//               ListTile(
//                 title: const Text('108', textAlign: TextAlign.center),
//                 onTap: () {
//                   setState(() {
//                     _tapsPerLoop = 108;
//                   });
//                   Navigator.pop(context);
//                 },
//               ),
//               ListTile(
//                 title: const Text('1008', textAlign: TextAlign.center),
//                 onTap: () {
//                   setState(() {
//                     _tapsPerLoop = 1008;
//                   });
//                   Navigator.pop(context);
//                 },
//               ),
//               const SizedBox(height: 10),
//             ],
//           ),
//         );
//       },
//     );
//   }
//
//   // jaap total count saved and pass to score page
//   final List<int> _savedCounts = [];
//
//   void _submitCount() {
//     setState(() {
//       _selectedItem;
//       _savedCounts.add(product);
//     });
//   }
//
//   int _counter = 0;
//   void _incrementCounter() {
//     setState(() {
//       _counter++;
//     });
//   }
//
//   final List<dynamic> _pressCounts = [];
//
//   final String _currentTime = '';
//   String totalDuration = '';
//   String totalDurationRam = '';
//   Timer? _timer;
//   DateTime? _startTime;
//   Duration _elapsedTime = Duration.zero;
//   double latiTude = 0.0;
//   double longiTude = 0.0;
//   String _venueAddressController = '';
//
//   List<Map<String, dynamic>> savedData = [];
//
//   void _startTimer() {
//     // Check if the timer is already running
//     if (_timer != null && _timer!.isActive) {
//       return; // Do nothing if the timer is already running
//     }
//
//     // Set the start time and reset the elapsed time
//     setState(() {
//       _startTime = DateTime.now();
//       _elapsedTime = Duration.zero;
//     });
//
//     // Start a new timer
//     _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
//       setState(() {
//         _elapsedTime = DateTime.now().difference(_startTime!);
//       });
//     });
//   }
//
//   // Stop timer and calculate total duration
//   void _stopTimer() {
//     if (_timer != null) {
//       // _elapsedTime = _elapsedTime.toString();
//       _timer!.cancel();
//       setState(() {
//         _timer = null;
//         totalDuration = '${_elapsedTime.inSeconds}s';
//         totalDurationRam = '${_elapsedTime.inSeconds}s';
//         _elapsedTime = Duration.zero;
//       });
//       print('Total Duration: $_elapsedTime $totalDuration');
//     }
//   }
//
//   void _incrementNumber() {
//     setState(() {
//       itemColorIndex =
//           (itemColorIndex + 1) % 3; // Increment and reset to 0 after 3
//     });
//   }
//
//   String extractEnglishName(String input) {
//     // Use regex to match the first part before the opening bracket.
//     RegExp exp = RegExp(r'^[^(]+');
//     Match? match = exp.firstMatch(input);
//
//     if (match != null) {
//       // Trim the result to remove any extra whitespace.
//       return match.group(0)!.trim();
//     } else {
//       // Return the original input if no match is found (in case there is no bracket).
//       return input;
//     }
//   }
//
//   void getLocation(double lat, long) async {
//     List<Placemark> placemarks = await placemarkFromCoordinates(
//       lat,
//       long!,
//     );
//
//     if (placemarks.isNotEmpty) {
//       Placemark place = placemarks.first;
//       // _pincodeController.text = place.postalCode!;
//       // _stateController.text = place.administrativeArea!;
//       // _landMarkController.text = place.street!;
//       _venueAddressController = place.locality!;
//       print('venue store $_venueAddressController ${place.locality}');
//     }
//   }
//
//   Future<void> countSave(String totalCount) async {
//     String name = extractEnglishName(_selectedItem);
//     DateTime now = DateTime.now();
//     String formattedTime = DateFormat('hh:mm:ss').format(now);
//     String formattedDate = DateFormat('dd/MM/yyy').format(now);
//     final response = await http.post(
//       Uri.parse(AppConstants.baseUrl + AppConstants.saveJapCountUrl),
//       headers: {
//         'Authorization': 'Bearer $userToken',
//         'Content-Type': 'application/json',
//       },
//       body: jsonEncode({
//         'type': 'mantra',
//         'name': name,
//         'location': _venueAddressController,
//         'count': totalCount,
//         'duration': totalDuration,
//         'date': formattedDate,
//         'time': formattedTime
//       }),
//     );
//     print('jaap post api: ${response.body}');
//     var data = jsonDecode(response.body);
//     if (data['status'] == 200) {
//       _submitCount();
//       setState(() {
//         tabIndex = 0;
//         _tapCounter = 0;
//         _loopCounter = 0;
//         product = 0;
//         _tabController.animateTo(2);
//         _tabController.index = 3;
//       });
//     } else {
//       print('failed api status 400');
//     }
//   }
//
//   Future<void> ramLekhanSave(String totalCountRam) async {
//     DateTime now = DateTime.now();
//     String formattedTime = DateFormat('hh:mm:ss').format(now);
//     String formattedDate = DateFormat('dd/MM/yyy').format(now);
//     final response = await http.post(
//       Uri.parse(AppConstants.baseUrl + AppConstants.saveRamLekhanUrl),
//       headers: {
//         'Authorization': 'Bearer $userToken',
//         'Content-Type': 'application/json',
//       },
//       body: jsonEncode({
//         'type': 'ram_lekhan',
//         'name': 'ram',
//         'location': _venueAddressController,
//         'count': totalCountRam,
//         'duration': totalDurationRam,
//         'date': formattedDate,
//         'time': formattedTime
//       }),
//     );
//     print('ram lekhan post api: ${response.body}');
//     var data = jsonDecode(response.body);
//     if (data['status'] == 200) {
//       setState(() {
//         tabIndex = 1;
//         _pressCounts.add(_totalPressCount);
//         _totalPressCount = 0;
//         _texts.clear();
//         signatures.clear();
//         _buttonPressCount = 0;
//         _buttonPressCounts = 0;
//         _totalPressCount = 0;
//         _textController.clear();
//         _textstype.clear();
//         _tabController.animateTo(2);
//         _tabController.index = 2;
//       });
//     } else {
//       print('failed api status 400');
//     }
//   }
//
//   Future<void> _checkPreviousData() async {
//     savedData = await DBHelper.instance.getData();
//     if (savedData.isNotEmpty) {
//       WidgetsBinding.instance.addPostFrameCallback((_) {
//         _showResumeDialog();
//       });
//     }
//   }
//
//   void _showResumeDialog() {
//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (_) {
//         return Dialog(
//           backgroundColor: Colors.transparent,
//           insetAnimationDuration: const Duration(milliseconds: 300),
//           insetAnimationCurve: Curves.easeOutQuart,
//           child: Container(
//             padding: const EdgeInsets.all(24),
//             decoration: BoxDecoration(
//               color: Theme.of(context).colorScheme.surface,
//               borderRadius: BorderRadius.circular(20),
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.black.withOpacity(0.2),
//                   blurRadius: 20,
//                   spreadRadius: 2,
//                 )
//               ],
//             ),
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 Icon(
//                   Icons.history_rounded,
//                   size: 48,
//                   color: Theme.of(context).colorScheme.primary,
//                 ),
//                 const SizedBox(height: 16),
//                 Text(
//                   'Resume or Restart?',
//                   style: Theme.of(context).textTheme.headlineSmall?.copyWith(
//                     fontWeight: FontWeight.bold,
//                     color: Theme.of(context).colorScheme.onSurface,
//                   ),
//                 ),
//                 const SizedBox(height: 12),
//                 Text(
//                   'You have saved data. Do you want to continue or reset?',
//                   textAlign: TextAlign.center,
//                   style: Theme.of(context).textTheme.bodyMedium?.copyWith(
//                     color: Theme.of(context)
//                         .colorScheme
//                         .onSurface
//                         .withOpacity(0.8),
//                   ),
//                 ),
//                 const SizedBox(height: 24),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceAround,
//                   children: [
//                     Expanded(
//                       child: OutlinedButton(
//                         onPressed: () async {
//                           await DBHelper.instance.updateData(
//                             savedData[0]['id'],
//                             savedData[0]['str1'],
//                             savedData[0]['str2'],
//                             savedData[0]['str3'],
//                             savedData[0]['str4'],
//                           );
//                           Navigator.pop(context);
//                           setState(() {
//                             _selectedItem = savedData[0]['str1'];
//                             _tapsPerLoop = int.parse(savedData[0]['str2']);
//                             _loopCounter = int.parse(savedData[0]['str3']);
//                             _tapCounter = int.parse(savedData[0]['str4']);
//                           });
//                         },
//                         style: OutlinedButton.styleFrom(
//                           padding: const EdgeInsets.symmetric(vertical: 16),
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(12),
//                           ),
//                           side: BorderSide(
//                             color: Theme.of(context).colorScheme.primary,
//                           ),
//                         ),
//                         child: Text(
//                           'Continue',
//                           style: TextStyle(
//                             color: Theme.of(context).colorScheme.primary,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                       ),
//                     ),
//                     const SizedBox(width: 16),
//                     Expanded(
//                       child: ElevatedButton(
//                         onPressed: () async {
//                           await DBHelper.instance
//                               .deleteData(savedData[0]['id']);
//                           Navigator.pop(context);
//                           setState(() {
//                             savedData = [];
//                             _selectedItem = '';
//                             _tapsPerLoop = 11;
//                             _loopCounter = 0;
//                             _tapCounter = 0;
//                           });
//                         },
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: Colors.deepOrange,
//                           padding: const EdgeInsets.symmetric(vertical: 16),
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(12),
//                           ),
//                           elevation: 0,
//                         ),
//                         child: Text(
//                           'Reset',
//                           style: TextStyle(
//                             color:
//                             Theme.of(context).colorScheme.onErrorContainer,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }
//
//   Future<void> _saveData() async {
//     if (savedData.isEmpty) {
//       await DBHelper.instance.insertData(
//         _selectedItem,
//         '$_tapsPerLoop',
//         '$_loopCounter',
//         '$_tapCounter',
//       );
//     } else {
//       await DBHelper.instance.updateData(
//         savedData[0]['id'],
//         _selectedItem,
//         '$_tapsPerLoop',
//         '$_loopCounter',
//         '$_tapCounter',
//       );
//     }
//     savedData = await DBHelper.instance.getData();
//     setState(() {});
//   }
//   //----------------------JAAP TAB ENDS----------------------------
//
//   //----------------------RAM LEKHAN TAB STARTS----------------------------
//   final ScrollController _scrollController = ScrollController();
//
//   // ram lekhan signature pen decoration
//   final controllers = SignatureController(
//     penColor: Colors.orange,
//     penStrokeWidth: 3,
//     exportPenColor: Colors.orange,
//     exportBackgroundColor: Colors.white,
//   );
//
//   // ram lekhan signature saved here
//   List<Uint8List> signatures = [];
//
//   // ram lekhan ram word saved here
//   final List<Widget> _texts = [];
//   void _addText() {
//     setState(() {
//       _texts.add(Container(
//         decoration: BoxDecoration(
//           border: Border(
//             right: BorderSide(
//               color: Colors.amber.shade200,
//               width: 1.0,
//             ),
//             left: BorderSide(
//               color: Colors.amber.shade200,
//               width: 1.0,
//             ),
//             bottom: BorderSide(
//               color: Colors.amber.shade200,
//               width: 1.0,
//             ),
//           ),
//         ),
//         child: const Padding(
//           padding: EdgeInsets.only(right: 11, left: 11, top: 15, bottom: 15),
//           child: Text(
//             'राम',
//             style: TextStyle(fontSize: 23.7, color: Colors.orange, height: 1),
//           ),
//         ),
//       ));
//     });
//   }
//
//   // ram lekhan keyboard word saved here
//   final List<String> _textstype = [];
//
//   // // ram lekhan Variable to toggle keyboard visibility
//   final bool _showKeyboard = true;
//
//   // ram lekhan Controller for the text field keyboard TextEditingController
//   final TextEditingController _textController = TextEditingController();
//
//   // ram lekhan Variable to toggle signature pad visibility
//   bool _isSignatureVisible = false;
//
//   // ram lekhan total count start
//   int _buttonPressCount = 0;
//   int _buttonPressCounts = 0;
//   int _totalPressCount = 0;
//   final int _currentIndex = 0;
//
//   void _incrementButtonPressCount() {
//     setState(() {
//       _buttonPressCount++;
//       _totalPressCount = _buttonPressCount + _buttonPressCounts;
//     });
//   }
//
//   void _incrementButtonPressCounts() {
//     setState(() {
//       _buttonPressCounts++;
//       _totalPressCount = _buttonPressCount + _buttonPressCounts;
//     });
//   }
//   // ram lekhan total count End
//
//   //----------------------RAM LEKHAN TAB STARTS----------------------------
//
//   // NEW: Add these variables for Program Tab
//   List<Map<String, dynamic>> events = []; // For storing events
//   List<Map<String, dynamic>> programs = []; // For storing programs
//   List<Map<String, dynamic>> programDetails = []; // For storing program details
//   List<Map<String, dynamic>> programImages = []; // For storing program images
//
//   @override
//   void initState() {
//     super.initState();
//     _checkPreviousData();
//     userToken = Provider.of<AuthController>(Get.context!, listen: false).getUserToken();
//     latiTude = Provider.of<AuthController>(Get.context!, listen: false).latitude;
//     longiTude = Provider.of<AuthController>(Get.context!, listen: false).longitude;
//     // यहाँ TabController create करें - length 5 रखें
//     _tabController = TabController(
//         length: 5,
//         vsync: this,
//         initialIndex: widget.initialIndex
//     );
//     // _tabController = TabController(length: 5, vsync: this, initialIndex: widget.initialIndex);
//     _isSignatureVisible = false; // Initialize with true
//     _animationController = AnimationController(
//       duration: const Duration(milliseconds: 500),
//       vsync: this,
//     );
//     _animation = Tween<double>(begin: 1, end: 1.2).animate(_animationController)
//       ..addListener(() {
//         setState(() {});
//       })
//       ..addStatusListener((status) {
//         if (status == AnimationStatus.completed) {
//           _animationController.reverse();
//         }
//       });
//     getLocation(latiTude, longiTude);
//     getJaapMantra();
//   }
//
//   // Add this variable to your state class
//   int _selectedTimeFilter = 3; // Default to "All Time"
//
//   // Sample data for different time periods
//   final Map<String, List<Map<String, dynamic>>> _leaderboardData = {
//     'daily': [
//       {'rank': 1, 'name': 'Hanuman Dev', 'count': '1,250', 'emoji': '🥇', 'avatar': '🙏'},
//       {'rank': 2, 'name': 'Radha Krishna', 'count': '980', 'emoji': '🥈', 'avatar': '🌺'},
//       {'rank': 3, 'name': 'Shiva Shakti', 'count': '850', 'emoji': '🥉', 'avatar': '🕉️'},
//       {'rank': 4, 'name': 'Ram Bhakt', 'count': '720', 'emoji': '🙏', 'avatar': '📿'},
//       {'rank': 5, 'name': 'Ganga Devi', 'count': '680', 'emoji': '🌊', 'avatar': '💧'},
//       {'rank': 6, 'name': 'Krishna Prem', 'count': '550', 'emoji': '🕉️', 'avatar': '🌟'},
//       {'rank': 7, 'name': 'Yoga Nidra', 'count': '480', 'emoji': '🧘', 'avatar': '☮️'},
//       {'rank': 8, 'name': 'Dharma Raj', 'count': '420', 'emoji': '📿', 'avatar': '👑'},
//       {'rank': 9, 'name': 'Moksha Path', 'count': '380', 'emoji': '✨', 'avatar': '🕊️'},
//       {'rank': 10, 'name': 'Shanti Om', 'count': '320', 'emoji': '☮️', 'avatar': '🎵'},
//     ],
//     'weekly': [
//       {'rank': 1, 'name': 'Shiva Shakti', 'count': '8,750', 'emoji': '🥇', 'avatar': '🕉️'},
//       {'rank': 2, 'name': 'Hanuman Dev', 'count': '8,250', 'emoji': '🥈', 'avatar': '🙏'},
//       {'rank': 3, 'name': 'Radha Krishna', 'count': '7,980', 'emoji': '🥉', 'avatar': '🌺'},
//       {'rank': 4, 'name': 'Ganga Devi', 'count': '6,540', 'emoji': '🌊', 'avatar': '💧'},
//       {'rank': 5, 'name': 'Ram Bhakt', 'count': '5,870', 'emoji': '🙏', 'avatar': '📿'},
//       {'rank': 6, 'name': 'Krishna Prem', 'count': '5,450', 'emoji': '🕉️', 'avatar': '🌟'},
//       {'rank': 7, 'name': 'Dharma Raj', 'count': '4,920', 'emoji': '📿', 'avatar': '👑'},
//       {'rank': 8, 'name': 'Yoga Nidra', 'count': '4,380', 'emoji': '🧘', 'avatar': '☮️'},
//       {'rank': 9, 'name': 'Moksha Path', 'count': '3,950', 'emoji': '✨', 'avatar': '🕊️'},
//       {'rank': 10, 'name': 'Shanti Om', 'count': '3,520', 'emoji': '☮️', 'avatar': '🎵'},
//     ],
//     'monthly': [
//       {'rank': 1, 'name': 'Radha Krishna', 'count': '35,870', 'emoji': '🥇', 'avatar': '🌺'},
//       {'rank': 2, 'name': 'Hanuman Dev', 'count': '34,250', 'emoji': '🥈', 'avatar': '🙏'},
//       {'rank': 3, 'name': 'Shiva Shakti', 'count': '32,980', 'emoji': '🥉', 'avatar': '🕉️'},
//       {'rank': 4, 'name': 'Krishna Prem', 'count': '28,450', 'emoji': '🕉️', 'avatar': '🌟'},
//       {'rank': 5, 'name': 'Ram Bhakt', 'count': '25,870', 'emoji': '🙏', 'avatar': '📿'},
//       {'rank': 6, 'name': 'Ganga Devi', 'count': '24,540', 'emoji': '🌊', 'avatar': '💧'},
//       {'rank': 7, 'name': 'Dharma Raj', 'count': '22,920', 'emoji': '📿', 'avatar': '👑'},
//       {'rank': 8, 'name': 'Yoga Nidra', 'count': '20,380', 'emoji': '🧘', 'avatar': '☮️'},
//       {'rank': 9, 'name': 'Moksha Path', 'count': '18,950', 'emoji': '✨', 'avatar': '🕊️'},
//       {'rank': 10, 'name': 'Shanti Om', 'count': '16,520', 'emoji': '☮️', 'avatar': '🎵'},
//     ],
//     'allTime': [
//       {'rank': 1, 'name': 'Hanuman Dev', 'count': '156,870', 'emoji': '🥇', 'avatar': '🙏'},
//       {'rank': 2, 'name': 'Radha Krishna', 'count': '142,540', 'emoji': '🥈', 'avatar': '🌺'},
//       {'rank': 3, 'name': 'Shiva Shakti', 'count': '130,230', 'emoji': '🥉', 'avatar': '🕉️'},
//       {'rank': 4, 'name': 'Ram Bhakt', 'count': '119,870', 'emoji': '🙏', 'avatar': '📿'},
//       {'rank': 5, 'name': 'Krishna Prem', 'count': '108,450', 'emoji': '🕉️', 'avatar': '🌟'},
//       {'rank': 6, 'name': 'Ganga Devi', 'count': '97,890', 'emoji': '🌊', 'avatar': '💧'},
//       {'rank': 7, 'name': 'Yoga Nidra', 'count': '86,540', 'emoji': '🧘', 'avatar': '☮️'},
//       {'rank': 8, 'name': 'Dharma Raj', 'count': '75,670', 'emoji': '📿', 'avatar': '👑'},
//       {'rank': 9, 'name': 'Moksha Path', 'count': '64,320', 'emoji': '✨', 'avatar': '🕊️'},
//       {'rank': 10, 'name': 'Shanti Om', 'count': '53,150', 'emoji': '☮️', 'avatar': '🎵'},
//     ],
//   };
//
//   final Map<String, Map<String, dynamic>> _userStats = {
//     'daily': {'rank': 15, 'count': '450', 'progress': '+25%'},
//     'weekly': {'rank': 18, 'count': '3,240', 'progress': '+15%'},
//     'monthly': {'rank': 22, 'count': '12,450', 'progress': '+8%'},
//     'allTime': {'rank': 25, 'count': '124,240', 'progress': '+5%'},
//   };
//
//   final Map<String, String> _motivationalQuotes = {
//     'daily': 'Start your day with divine chants for inner peace!',
//     'weekly': 'Consistent practice leads to spiritual growth. Well done!',
//     'monthly': 'A month of devotion brings you closer to enlightenment!',
//     'allTime': 'Your spiritual journey inspires others. Keep chanting!',
//   };
//
//   String _getCurrentTimeFilter() {
//     switch (_selectedTimeFilter) {
//       case 0: return 'daily';
//       case 1: return 'weekly';
//       case 2: return 'monthly';
//       case 3: return 'allTime';
//       default: return 'allTime';
//     }
//   }
//
//   String _getTimeFilterSubtitle() {
//     switch (_selectedTimeFilter) {
//       case 0: return "Today's Top Spiritual Performers";
//       case 1: return "This Week's Top Spiritual Performers";
//       case 2: return "This Month's Top Spiritual Performers";
//       case 3: return 'All Time Top Spiritual Performers';
//       default: return 'Top Spiritual Performers';
//     }
//   }
//
//   Map<String, dynamic> _getUserStats() {
//     return _userStats[_getCurrentTimeFilter()]!;
//   }
//
//   String _getMotivationalQuote() {
//     return _motivationalQuotes[_getCurrentTimeFilter()]!;
//   }
//
//   List<Widget> _buildLeaderboardList() {
//     final currentData = _leaderboardData[_getCurrentTimeFilter()]!;
//     // Skip first 3 since they're shown as winners
//     final remainingData = currentData.skip(3).toList();
//
//     return remainingData.map((user) => _buildLeaderboardItem(
//       user['rank'],
//       user['name'],
//       user['count'],
//       user['avatar'],
//     )).toList();
//   }
//
//   Widget _buildTimeTab(String text, int index) {
//     bool isSelected = _selectedTimeFilter == index;
//     return Expanded(
//       child: GestureDetector(
//         onTap: () {
//           setState(() {
//             _selectedTimeFilter = index;
//           });
//         },
//         child: Container(
//           padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
//           decoration: BoxDecoration(
//             color: isSelected ? Colors.orange.shade500 : Colors.transparent,
//             borderRadius: BorderRadius.circular(8),
//           ),
//           child: Text(
//             text,
//             textAlign: TextAlign.center,
//             style: TextStyle(
//               color: isSelected ? Colors.white : Colors.grey.shade700,
//               fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
//               fontSize: 12,
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   List<Widget> _buildTopThreeWinners() {
//     final currentData = _leaderboardData[_getCurrentTimeFilter()]!;
//     final topThree = currentData.take(3).toList();
//
//     // Safe conversion function
//     int safeParseInt(dynamic value) {
//       if (value == null) return 0;
//       if (value is int) return value;
//       if (value is String) {
//         return int.tryParse(value) ?? 0;
//       }
//       return 0;
//     }
//
//     String safeParseString(dynamic value) {
//       if (value == null) return '';
//       return value.toString();
//     }
//
//     return [
//       // Rank 2 (Left side)
//       _buildWinnerCard(
//         rank: safeParseInt(topThree[1]['rank']),
//         name: safeParseString(topThree[1]['name']),
//         count: safeParseInt(topThree[1]['count']),
//         avatar: safeParseString(topThree[1]['emoji']),
//         rankColor: Colors.blue.shade400, // Silver/Blue for 2nd
//         backgroundColor: Colors.blue.shade50,
//         borderColor: Colors.blue.shade200,
//         isFirst: false,
//         onTap: () => _showPerformerDetails(topThree[1]),
//       ),
//
//       // Rank 1 (Center - taller)
//       _buildWinnerCard(
//         rank: safeParseInt(topThree[0]['rank']),
//         name: safeParseString(topThree[0]['name']),
//         count: safeParseInt(topThree[0]['count']),
//         avatar: safeParseString(topThree[0]['emoji']),
//         rankColor: Colors.amber.shade700, // Gold for 1st
//         backgroundColor: Colors.amber.shade50,
//         borderColor: Colors.amber.shade300,
//         isFirst: true,
//         onTap: () => _showPerformerDetails(topThree[0]),
//       ),
//
//       // Rank 3 (Right side)
//       _buildWinnerCard(
//         rank: safeParseInt(topThree[2]['rank']),
//         name: safeParseString(topThree[2]['name']),
//         count: safeParseInt(topThree[2]['count']),
//         avatar: safeParseString(topThree[2]['emoji']),
//         rankColor: Colors.green.shade600, // Bronze/Green for 3rd
//         backgroundColor: Colors.green.shade50,
//         borderColor: Colors.green.shade200,
//         isFirst: false,
//         onTap: () => _showPerformerDetails(topThree[2]),
//       ),
//     ];
//   }
//
//   Widget _buildWinnerCard({
//     required int rank,
//     required String name,
//     required int count,
//     required String avatar,
//     required Color rankColor,
//     required Color backgroundColor,
//     required Color borderColor,
//     bool isFirst = false,
//     VoidCallback? onTap,
//   })
//   {
//     final double cardHeight = isFirst ? 200 : 180; // First place is taller
//     final double cardWidth = 100;
//
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         width: cardWidth,
//         height: cardHeight,
//         margin: EdgeInsets.only(
//           bottom: isFirst ? 0 : 40, // Lower ranks sit lower
//         ),
//         decoration: BoxDecoration(
//           color: backgroundColor,
//           borderRadius: BorderRadius.circular(20),
//           border: Border.all(
//             color: borderColor,
//             width: 2,
//           ),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withOpacity(0.1),
//               blurRadius: 10,
//               offset: const Offset(0, 4),
//             ),
//           ],
//           gradient: LinearGradient(
//             begin: Alignment.topCenter,
//             end: Alignment.bottomCenter,
//             colors: [
//               backgroundColor.withOpacity(0.8),
//               backgroundColor.withOpacity(0.4),
//             ],
//           ),
//         ),
//         child: Stack(
//           children: [
//             // Rank badge at the top
//             Positioned(
//               top: 12,
//               left: 0,
//               right: 0,
//               child: Container(
//                 width: 36,
//                 height: 36,
//                 decoration: BoxDecoration(
//                   color: rankColor,
//                   shape: BoxShape.circle,
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.black.withOpacity(0.2),
//                       blurRadius: 6,
//                       offset: const Offset(0, 2),
//                     ),
//                   ],
//                   border: Border.all(
//                     color: Colors.white,
//                     width: 2,
//                   ),
//                 ),
//                 child: Center(
//                   child: Text(
//                     '#$rank',
//                     style: const TextStyle(
//                       fontSize: 14,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.white,
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//
//             // Crown for first place
//             if (isFirst)
//               Positioned(
//                 top: 0,
//                 left: 0,
//                 right: 0,
//                 child: Center(
//                   child: Container(
//                     width: 40,
//                     height: 40,
//                     decoration: BoxDecoration(
//                       color: Colors.amber.shade700,
//                       shape: BoxShape.circle,
//                       boxShadow: [
//                         BoxShadow(
//                           color: Colors.black.withOpacity(0.3),
//                           blurRadius: 8,
//                           offset: const Offset(0, 3),
//                         ),
//                       ],
//                     ),
//                     child: const Icon(
//                       Icons.emoji_events,
//                       color: Colors.white,
//                       size: 24,
//                     ),
//                   ),
//                 ),
//               ),
//
//             // Podium base
//             Positioned(
//               bottom: 0,
//               left: 0,
//               right: 0,
//               child: Container(
//                 height: 60,
//                 decoration: BoxDecoration(
//                   color: rankColor.withOpacity(0.8),
//                   borderRadius: const BorderRadius.only(
//                     bottomLeft: Radius.circular(18),
//                     bottomRight: Radius.circular(18),
//                   ),
//                   border: Border.all(
//                     color: rankColor.withOpacity(0.9),
//                     width: 1,
//                   ),
//                 ),
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Text(
//                       '${count.toStringAsFixed(1)}', // Show one decimal if needed
//                       style: const TextStyle(
//                         fontSize: 18,
//                         fontWeight: FontWeight.bold,
//                         color: Colors.white,
//                       ),
//                     ),
//                     const SizedBox(height: 4),
//                     const Text(
//                       'Jaaps',
//                       style: TextStyle(
//                         fontSize: 10,
//                         color: Colors.white70,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//
//             // Main content area
//             Positioned(
//               top: 60,
//               left: 0,
//               right: 0,
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   // Avatar/Emoji
//                   Container(
//                     width: 70,
//                     height: 70,
//                     decoration: BoxDecoration(
//                       shape: BoxShape.circle,
//                       color: Colors.white,
//                       border: Border.all(
//                         color: borderColor.withOpacity(0.8),
//                         width: 3,
//                       ),
//                       boxShadow: [
//                         BoxShadow(
//                           color: Colors.black.withOpacity(0.1),
//                           blurRadius: 8,
//                           offset: const Offset(0, 3),
//                         ),
//                       ],
//                     ),
//                     child: Center(
//                       child: Text(
//                         avatar,
//                         style: const TextStyle(
//                           fontSize: 32,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                     ),
//                   ),
//
//                   // const SizedBox(height: 16),
//                   //
//                   // // Name
//                   // Container(
//                   //   padding: const EdgeInsets.symmetric(horizontal: 8),
//                   //   child: Text(
//                   //     name,
//                   //     style: TextStyle(
//                   //       fontSize: 14,
//                   //       fontWeight: FontWeight.bold,
//                   //       color: Colors.grey.shade800,
//                   //     ),
//                   //     maxLines: 2,
//                   //     overflow: TextOverflow.ellipsis,
//                   //     textAlign: TextAlign.center,
//                   //   ),
//                   // ),
//
//                   const SizedBox(height: 8),
//
//                   // Medal icon
//                   Icon(
//                     _getMedalIcon(rank),
//                     size: 20,
//                     color: rankColor,
//                   ),
//
//                   const SizedBox(height: 8),
//
//                   // Rank title
//                   Text(
//                     _getRankTitle(rank),
//                     style: TextStyle(
//                       fontSize: 12,
//                       fontWeight: FontWeight.w600,
//                       color: rankColor,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   // Helper function to get medal icon based on rank
//   IconData _getMedalIcon(int rank) {
//     switch (rank) {
//       case 1:
//         return Icons.emoji_events;
//       case 2:
//         return Icons.military_tech;
//       case 3:
//         return Icons.workspace_premium;
//       default:
//         return Icons.star;
//     }
//   }
//
//   // Helper function to get rank title
//   String _getRankTitle(int rank) {
//     switch (rank) {
//       case 1:
//         return 'CHAMPION';
//       case 2:
//         return 'RUNNER UP';
//       case 3:
//         return 'THIRD PLACE';
//       default:
//         return 'TOP PLAYER';
//     }
//   }
//
//   Color _getRankColor(int rank) {
//     switch (rank) {
//       case 1: return Colors.amber.shade700;
//       case 2: return Colors.grey.shade600;
//       case 3: return Colors.orange.shade700;
//       default: return Colors.blue.shade700;
//     }
//   }
//
//   void _showPerformerDetails(Map<String, dynamic> performer) {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: Row(
//             children: [
//               Text(performer['emoji']),
//               const SizedBox(width: 10),
//               Text(
//                 performer['name'],
//                 style: const TextStyle(fontSize: 18),
//               ),
//             ],
//           ),
//           content: Column(
//             mainAxisSize: MainAxisSize.min,
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 "Rank: #${performer['rank']}",
//                 style: TextStyle(
//                   fontSize: 16,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.orange.shade800,
//                 ),
//               ),
//               const SizedBox(height: 10),
//               Text(
//                 "Tasks Completed: ${performer['count']}",
//                 style: const TextStyle(fontSize: 16),
//               ),
//               const SizedBox(height: 15),
//               Text(
//                 'Performance Details:',
//                 style: TextStyle(
//                   fontWeight: FontWeight.bold,
//                   color: Colors.grey.shade700,
//                 ),
//               ),
//               const SizedBox(height: 5),
//               Text(
//                 '• Excellent task completion rate\n• Consistently high performance\n• Active participant in all activities',
//                 style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
//               ),
//             ],
//           ),
//           actions: [
//             TextButton(
//               onPressed: () {
//                 Navigator.of(context).pop();
//               },
//               child: const Text('Close'),
//             ),
//           ],
//         );
//       },
//     );
//   }
//
//   Widget _buildLeaderboardItem(int rank, String name, String count, String emoji) {
//     return Column(
//       children: [
//         SizedBox(height: 10),
//         Container(
//           padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5), // Increased vertical padding
//           margin: const EdgeInsets.symmetric(horizontal: 8), // Add horizontal margin
//           decoration: BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.circular(10), // Rounded corners for each item
//             border: Border.all(
//               color: Colors.grey.shade200,
//               width: 1,
//             ),
//             boxShadow: [
//               BoxShadow(
//                 color: Colors.grey.withOpacity(0.05),
//                 blurRadius: 4,
//                 offset: const Offset(0, 2),
//               ),
//             ],
//           ),
//           child: Row(
//             children: [
//               // Rank with better styling
//               Container(
//                 width: 36,
//                 height: 36,
//                 decoration: BoxDecoration(
//                   color: _getRankColor(rank),
//                   shape: BoxShape.circle,
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.grey.withOpacity(0.2),
//                       blurRadius: 3,
//                       offset: const Offset(0, 1),
//                     ),
//                   ],
//                 ),
//                 child: Center(
//                   child: Text(
//                     rank.toString(),
//                     style: const TextStyle(
//                       fontWeight: FontWeight.bold,
//                       color: Colors.white,
//                       fontSize: 14, // Slightly larger
//                     ),
//                   ),
//                 ),
//               ),
//               const SizedBox(width: 15),
//
//
//
//               // Name
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       name,
//                       style: const TextStyle(
//                         fontWeight: FontWeight.w600,
//                         fontSize: 14,
//                       ),
//                     ),
//                     const SizedBox(height: 4),
//                     Text(
//                       'Rank #$rank',
//                       style: TextStyle(
//                         fontSize: 11,
//                         color: Colors.grey.shade600,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//
//               // Emoji with container
//               Container(
//                 width: 40,
//                 height: 40,
//                 decoration: BoxDecoration(
//                   color: Colors.orange.shade50,
//                   shape: BoxShape.circle,
//                 ),
//                 child: Center(
//                   child: Text(emoji, style: const TextStyle(fontSize: 18)),
//                 ),
//               ),
//               const SizedBox(width: 12),
//               // Count with better styling
//               Container(
//                 padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//                 decoration: BoxDecoration(
//                   color: Colors.orange.shade50,
//                   borderRadius: BorderRadius.circular(20),
//                   border: Border.all(
//                     color: Colors.orange.shade100,
//                     width: 1,
//                   ),
//                 ),
//                 child: Text(
//                   count,
//                   style: TextStyle(
//                     fontWeight: FontWeight.bold,
//                     color: Colors.orange.shade700,
//                     fontSize: 14,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ],
//     );
//   }
//
// // NEW: Variable to track which event is being edited
//   int? _editingIndex;
//
// // NEW: Function to show Add/Edit Event Dialog
//   void _showEventDialog({int? index}) {
//     // If editing, load existing data, else use defaults
//     String name = '';
//     String group = '';
//     String type = '';
//     String venue = '';
//     String description = '';
//     bool isPublic = true;
//     DateTime startDate = DateTime.now();
//     DateTime endDate = DateTime.now().add(const Duration(days: 1));
//
//     // If editing, load the event data
//     if (index != null && events.length > index) {
//       final event = events[index];
//       name = event['name'] ?? '';
//       group = event['group'] ?? '';
//       type = event['type'] ?? '';
//       venue = event['venue'] ?? '';
//       description = event['description'] ?? '';
//       isPublic = event['isPublic'] ?? true;
//
//       // Parse dates if they exist in string format
//       if (event['startDate'] != null) {
//         final parts = event['startDate'].toString().split('/');
//         if (parts.length == 3) {
//           startDate = DateTime(
//               int.parse(parts[2]),
//               int.parse(parts[1]),
//               int.parse(parts[0])
//           );
//         }
//       }
//
//       if (event['endDate'] != null) {
//         final parts = event['endDate'].toString().split('/');
//         if (parts.length == 3) {
//           endDate = DateTime(
//               int.parse(parts[2]),
//               int.parse(parts[1]),
//               int.parse(parts[0])
//           );
//         }
//       }
//     }
//
//     showDialog(
//       context: context,
//       builder: (context) {
//         return StatefulBuilder(
//           builder: (context, setState) {
//             return AlertDialog(
//               title: Text(index == null ? 'नया कार्यक्रम जोड़ें' : 'कार्यक्रम संपादित करें'),
//               content: SingleChildScrollView(
//                 child: Column(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     // Event Name
//                     TextField(
//                       controller: TextEditingController(text: name),
//                       decoration: const InputDecoration(
//                         labelText: 'कार्यक्रम का नाम *',
//                         border: OutlineInputBorder(),
//                       ),
//                       onChanged: (value) => name = value,
//                     ),
//                     const SizedBox(height: 10),
//
//                     // Group
//                     TextField(
//                       controller: TextEditingController(text: group),
//                       decoration: const InputDecoration(
//                         labelText: 'समूह/कार्यक्रम जोड़े',
//                         border: OutlineInputBorder(),
//                       ),
//                       onChanged: (value) => group = value,
//                     ),
//                     const SizedBox(height: 10),
//
//                     // Public/Private Toggle
//                     Row(
//                       children: [
//                         const Text('सार्वजनिक'),
//                         Switch(
//                           value: isPublic,
//                           onChanged: (value) {
//                             setState(() {
//                               isPublic = value;
//                             });
//                           },
//                         ),
//                         Text(isPublic ? 'हाँ' : 'नहीं'),
//                       ],
//                     ),
//                     const SizedBox(height: 10),
//
//                     // Type
//                     TextField(
//                       controller: TextEditingController(text: type),
//                       decoration: const InputDecoration(
//                         labelText: 'कार्यक्रम का प्रकार',
//                         border: OutlineInputBorder(),
//                       ),
//                       onChanged: (value) => type = value,
//                     ),
//                     const SizedBox(height: 10),
//
//                     // Venue
//                     TextField(
//                       controller: TextEditingController(text: venue),
//                       decoration: const InputDecoration(
//                         labelText: 'आवृत्ति/स्थान',
//                         border: OutlineInputBorder(),
//                       ),
//                       onChanged: (value) => venue = value,
//                     ),
//                     const SizedBox(height: 10),
//
//                     // Start Date
//                     Row(
//                       children: [
//                         const Text('प्रारंभ:'),
//                         TextButton(
//                           onPressed: () async {
//                             final date = await showDatePicker(
//                               context: context,
//                               initialDate: startDate,
//                               firstDate: DateTime.now(),
//                               lastDate: DateTime(2100),
//                             );
//                             if (date != null) {
//                               setState(() {
//                                 startDate = date;
//                               });
//                             }
//                           },
//                           child: Text(
//                             '${startDate.day}/${startDate.month}/${startDate.year}',
//                           ),
//                         ),
//                       ],
//                     ),
//
//                     // End Date
//                     Row(
//                       children: [
//                         const Text('समाप्ति:'),
//                         TextButton(
//                           onPressed: () async {
//                             final date = await showDatePicker(
//                               context: context,
//                               initialDate: endDate,
//                               firstDate: startDate,
//                               lastDate: DateTime(2100),
//                             );
//                             if (date != null) {
//                               setState(() {
//                                 endDate = date;
//                               });
//                             }
//                           },
//                           child: Text(
//                             '${endDate.day}/${endDate.month}/${endDate.year}',
//                           ),
//                         ),
//                       ],
//                     ),
//                     const SizedBox(height: 10),
//
//                     // Description
//                     TextField(
//                       controller: TextEditingController(text: description),
//                       maxLines: 3,
//                       decoration: const InputDecoration(
//                         labelText: 'कार्यक्रम का विवरण',
//                         border: OutlineInputBorder(),
//                       ),
//                       onChanged: (value) => description = value,
//                     ),
//                   ],
//                 ),
//               ),
//               actions: [
//                 if (index != null) // Show delete button only when editing
//                   TextButton(
//                     onPressed: () {
//                       setState(() {
//                         events.removeAt(index);
//                       });
//                       Navigator.pop(context);
//                     },
//                     child: const Text(
//                       'हटाएं',
//                       style: TextStyle(color: Colors.red),
//                     ),
//                   ),
//                 TextButton(
//                   onPressed: () => Navigator.pop(context),
//                   child: const Text('रद्द करें'),
//                 ),
//                 ElevatedButton(
//                   onPressed: () {
//                     if (name.isNotEmpty) {
//                       setState(() {
//                         if (index != null) {
//                           // Update existing event
//                           events[index] = {
//                             'name': name,
//                             'group': group,
//                             'isPublic': isPublic,
//                             'type': type,
//                             'venue': venue,
//                             'startDate':
//                             '${startDate.day}/${startDate.month}/${startDate.year}',
//                             'endDate':
//                             '${endDate.day}/${endDate.month}/${endDate.year}',
//                             'description': description,
//                           };
//                         } else {
//                           // Add new event
//                           events.add({
//                             'name': name,
//                             'group': group,
//                             'isPublic': isPublic,
//                             'type': type,
//                             'venue': venue,
//                             'startDate':
//                             '${startDate.day}/${startDate.month}/${startDate.year}',
//                             'endDate':
//                             '${endDate.day}/${endDate.month}/${endDate.year}',
//                             'description': description,
//                           });
//                         }
//                       });
//                       Navigator.pop(context);
//                     }
//                   },
//                   child: Text(index == null ? 'जोड़ें' : 'अपडेट करें'),
//                 ),
//               ],
//             );
//           },
//         );
//       },
//     );
//   }
//
// // NEW: Function to show Event Details Popup
//   void _showEventDetails(int index) {
//     final event = events[index];
//
//     showDialog(
//       context: context,
//       builder: (context) {
//         return AlertDialog(
//           backgroundColor: Colors.grey[900],
//           title: Row(
//             children: [
//               Icon(
//                 event['isPublic'] ? Icons.public : Icons.lock,
//                 color: event['isPublic'] ? Colors.blue : Colors.purple,
//                 size: 24,
//               ),
//               const SizedBox(width: 10),
//               Expanded(
//                 child: Text(
//                   event['name'],
//                   style: const TextStyle(
//                     color: Colors.white,
//                     fontSize: 20,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//           content: SingleChildScrollView(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 // Group
//                 if (event['group'] != null && event['group'].isNotEmpty)
//                   Padding(
//                     padding: const EdgeInsets.only(bottom: 8),
//                     child: Row(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         const Icon(
//                           Icons.group,
//                           color: Colors.grey,
//                           size: 20,
//                         ),
//                         const SizedBox(width: 10),
//                         Expanded(
//                           child: Text(
//                             event['group'],
//                             style: const TextStyle(
//                               color: Colors.grey,
//                               fontSize: 16,
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//
//                 // Type
//                 if (event['type'] != null && event['type'].isNotEmpty)
//                   Padding(
//                     padding: const EdgeInsets.only(bottom: 8),
//                     child: Row(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         const Icon(
//                           Icons.category,
//                           color: Colors.grey,
//                           size: 20,
//                         ),
//                         const SizedBox(width: 10),
//                         Expanded(
//                           child: Text(
//                             event['type'],
//                             style: const TextStyle(
//                               color: Colors.grey,
//                               fontSize: 16,
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//
//                 // Venue
//                 if (event['venue'] != null && event['venue'].isNotEmpty)
//                   Padding(
//                     padding: const EdgeInsets.only(bottom: 8),
//                     child: Row(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         const Icon(
//                           Icons.location_on,
//                           color: Colors.grey,
//                           size: 20,
//                         ),
//                         const SizedBox(width: 10),
//                         Expanded(
//                           child: Text(
//                             event['venue'],
//                             style: const TextStyle(
//                               color: Colors.grey,
//                               fontSize: 16,
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//
//                 // Dates
//                 Padding(
//                   padding: const EdgeInsets.only(bottom: 8),
//                   child: Row(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       const Icon(
//                         Icons.calendar_today,
//                         color: Colors.orange,
//                         size: 20,
//                       ),
//                       const SizedBox(width: 10),
//                       Expanded(
//                         child: Text(
//                           '${event['startDate']} से ${event['endDate']}',
//                           style: const TextStyle(
//                             color: Colors.orange,
//                             fontSize: 16,
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//
//                 // Description
//                 if (event['description'] != null && event['description'].isNotEmpty)
//                   Padding(
//                     padding: const EdgeInsets.only(bottom: 8),
//                     child: Row(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         const Icon(
//                           Icons.description,
//                           color: Colors.grey,
//                           size: 20,
//                         ),
//                         const SizedBox(width: 10),
//                         Expanded(
//                           child: Text(
//                             event['description'],
//                             style: const TextStyle(
//                               color: Colors.grey,
//                               fontSize: 16,
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//
//                 // Public/Private Status
//                 Container(
//                   margin: const EdgeInsets.only(top: 10),
//                   padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//                   decoration: BoxDecoration(
//                     color: event['isPublic']
//                         ? Colors.blue.withOpacity(0.2)
//                         : Colors.purple.withOpacity(0.2),
//                     borderRadius: BorderRadius.circular(20),
//                   ),
//                   child: Text(
//                     event['isPublic'] ? 'सार्वजनिक' : 'निजी',
//                     style: TextStyle(
//                       color: event['isPublic'] ? Colors.blue : Colors.purple,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.pop(context),
//               child: const Text(
//                 'बंद करें',
//                 style: TextStyle(color: Colors.white),
//               ),
//             ),
//           ],
//         );
//       },
//     );
//   }
//
//   @override
//   void dispose() {
//     controllers.dispose();
//     _scrollController.dispose();
//     _tabController.dispose();
//     _customMantraNameController.dispose();
//     _customMantraController.dispose();
//     _tabController.dispose();
//     _animationController.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     double screenwidth = MediaQuery.sizeOf(context).width;
//     double screenHeight = MediaQuery.of(context).size.height;
//
//     return Scaffold(
//       backgroundColor: Colors.white30,
//       extendBodyBehindAppBar: true,
//       // Updated AppBar with language toggle button
//       appBar: AppBar(
//         automaticallyImplyLeading: false,
//         elevation: 0,
//         backgroundColor: Colors.transparent,
//         centerTitle: true,
//         title: const Text(
//           'Jaap',
//           style: TextStyle(
//               color: Colors.orange,
//               fontSize: 25,
//               fontWeight: FontWeight.bold
//           ),
//         ),
//         flexibleSpace: SafeArea(
//           child: Padding(
//             padding: const EdgeInsets.only(left: 8.0, top: 8.0),
//             child: Row(
//               children: [
//                 IconButton(
//                   onPressed: () {
//                     Navigator.pop(context);
//                   },
//                   icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
//                 ),
//                 IconButton(
//                   onPressed: () {
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                         builder: (context) => const WallpaperScreen(),
//                       ),
//                     );
//                   },
//                   icon: const Icon(Icons.settings, color: Colors.white),
//                 ),
//               ],
//             ),
//           ),
//         ),
//         actions: [
//           // Language Toggle Button - More compact
//           BouncingWidgetInOut(
//             onPressed: _toggleLanguage,
//             child: Container(
//               padding: const EdgeInsets.symmetric(horizontal: 8), // Reduced padding
//               height: 32, // Reduced height
//               decoration: BoxDecoration(
//                   borderRadius: BorderRadius.circular(6.0), // Smaller radius
//                   color: Colors.orange.withOpacity(0.4),
//                   border: Border.all(color: Colors.white, width: 1.5) // Thinner border
//               ),
//               child: Center(
//                 child: Text(
//                   _isHindi ? 'HI' : 'EN',
//                   style: const TextStyle(
//                     color: Colors.white,
//                     fontWeight: FontWeight.bold,
//                     fontSize: 12, // Smaller font
//                   ),
//                 ),
//               ),
//             ),
//           ),
//           const SizedBox(width: 4), // Reduced spacing
//
//           // Vibration Button - More compact
//           BouncingWidgetInOut(
//             onPressed: () {
//               setState(() {
//                 _vibrationEnabled = !_vibrationEnabled;
//                 print("Vibration toggled: $_vibrationEnabled");
//               });
//             },
//             child: Container(
//               padding: const EdgeInsets.symmetric(horizontal: 6), // Reduced padding
//               height: 32, // Reduced height
//               decoration: BoxDecoration(
//                   borderRadius: BorderRadius.circular(6.0), // Smaller radius
//                   color: _vibrationEnabled
//                       ? Colors.orange.withOpacity(0.4)
//                       : Colors.grey.withOpacity(0.4),
//                   border: Border.all(color: Colors.white, width: 1.5) // Thinner border
//               ),
//               child: Icon(
//                 Icons.vibration,
//                 color: _vibrationEnabled ? Colors.white : Colors.grey,
//                 size: 18, // Smaller icon
//               ),
//             ),
//           ),
//           const SizedBox(width: 4), // Reduced spacing
//
//           // Theme/Color Button - More compact
//           BouncingWidgetInOut(
//             onPressed: () {
//               _incrementNumber();
//             },
//             child: Container(
//               padding: const EdgeInsets.symmetric(horizontal: 6), // Reduced padding
//               height: 32, // Reduced height
//               decoration: BoxDecoration(
//                   borderRadius: BorderRadius.circular(6.0), // Smaller radius
//                   color: Colors.orange.withOpacity(0.4),
//                   border: Border.all(color: Colors.white, width: 1.5) // Thinner border
//               ),
//               child: const Icon(
//                 Icons.palette,
//                 color: Colors.white,
//                 size: 18, // Smaller icon
//               ),
//             ),
//           ),
//           const SizedBox(width: 8), // Reduced spacing
//         ],
//       ),
//       body: Container(
//         decoration: BoxDecoration(
//           image: DecorationImage(
//             image: itemColorIndex == 0
//                 ? const AssetImage('assets/images/jaap/ram_3.png')
//                 : itemColorIndex == 1
//                 ? const AssetImage('assets/images/jaap/ram_4.png')
//                 : itemColorIndex == 2
//                 ? const AssetImage('assets/images/jaap/ram_5.png')
//                 : AssetImage('assets/images/jaap/$_selectedImage'),
//             fit: BoxFit.cover,
//           ),
//         ),
//         child: Column(
//           children: [
//             SizedBox(height: screenHeight * 0.11),
//             Padding(
//               padding: const EdgeInsets.only(left: 18, right: 18),
//               child: TabBar(
//                 controller: _tabController,
//                 isScrollable: false,
//                 indicatorSize: TabBarIndicatorSize.tab,
//                 dividerColor: Colors.transparent,
//                 labelColor: Colors.white,
//                 unselectedLabelColor: Colors.white,
//                 indicatorWeight: 1,
//                 indicatorColor: Colors.orange,
//                 onTap: (index) {
//                   setState(() {
//                     _tabController.index = index;
//                   });
//                 },
//                 tabs: [
//                   Tab(
//                     child: Container(
//                       child: Center(
//                           child: Text(
//                             'Jaap',
//                             style: TextStyle(fontSize: screenwidth * 0.028),
//                           )),
//                     ),
//                   ),
//                   Tab(
//                     child: Container(
//                       child: Center(
//                           child: Text(
//                             'Ram Lekhan',
//                             style: TextStyle(fontSize: screenwidth * 0.025),
//                             textAlign: TextAlign.center,
//                           )),
//                     ),
//                   ),
//                   Tab(
//                     child: Container(
//                       child: Center(
//                         child: Text(
//                           'Leader\nboard',
//                           style: TextStyle(fontSize: screenwidth * 0.027),
//                           textAlign: TextAlign.center,
//                         ),
//                       ),
//                     ),
//                   ),
//                   Tab(
//                     child: Container(
//                       child: Center(
//                           child: Text(
//                             'Score',
//                             style: TextStyle(fontSize: screenwidth * 0.027),
//                           )),
//                     ),
//                   ),
//                   // NEW: Program Karyakram Tab
//                   Tab(
//                     child: Container(
//                       child: Center(
//                           child: Text(
//                             'Program',
//                             style: TextStyle(fontSize: screenwidth * 0.023),
//                           )),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             Expanded(
//               child: TabBarView(
//                 controller: _tabController,
//                 physics: NeverScrollableScrollPhysics(),
//                 children: [
//                   // --------------------------------JAAP TAB STARTS------------------------------
//                   SingleChildScrollView(
//                     child: Container(
//                       decoration: const BoxDecoration(
//                           image: DecorationImage(image: AssetImage('assets/images/jaap/animation_1.gif'))),
//                       child: Padding(
//                         padding: const EdgeInsets.all(10.0),
//                         child: Column(
//                           children: [
//                             const SizedBox(
//                               height: 10,
//                             ),
//
//                             GestureDetector(
//                               onTap: _showMantraBottomSheet,
//                               child: Container(
//                                 padding: EdgeInsets.symmetric(
//                                   horizontal: 16,
//                                   vertical: _selectedItem.isEmpty ? 30 : 12,
//                                 ),
//                                 decoration: BoxDecoration(
//                                   color: Colors.white,
//                                   borderRadius: BorderRadius.circular(15), // Softer corners
//                                   border: Border.all(color: _mantraColor.withOpacity(0.5), width: 1.5),
//                                   boxShadow: [
//                                     BoxShadow(
//                                       color: _mantraColor.withOpacity(0.05),
//                                       blurRadius: 10,
//                                       offset: const Offset(0, 4),
//                                     )
//                                   ],
//                                 ),
//                                 height: screenHeight * 0.22, // Increased slightly to fit controls comfortably
//                                 width: double.infinity,
//                                 child: Column(
//                                   children: [
//                                     // --- Main Mantra Display ---
//                                     Expanded(
//                                       child: Center(
//                                         child: _isLoadingMantras
//                                             ? CircularProgressIndicator(color: _mantraColor)
//                                             : _selectedItem.isEmpty
//                                             ? Text('मंत्र चुनें',
//                                             style: TextStyle(color: _mantraColor, fontSize: 20, fontWeight: FontWeight.w600))
//                                             : AutoSizeText(
//                                           _selectedItem,
//                                           style: TextStyle(
//                                             color: _mantraColor, // Dynamic Color applied here
//                                             fontWeight: FontWeight.w600,
//                                             fontSize: _mantraFontSize,
//                                           ),
//                                           textAlign: TextAlign.center,
//                                           maxLines: 4,
//                                         ),
//                                       ),
//                                     ),
//
//                                     if (_selectedItem.isNotEmpty) ...[
//                                       const SizedBox(height: 8),
//                                       // --- Control Row (Font & Color) ---
//                                       Row(
//                                         children: [
//                                           // 1. Color Picker Trigger
//                                           GestureDetector(
//                                             onTap: () => _showColorPickerDialog(context),
//                                             child: Container(
//                                               padding: const EdgeInsets.all(8),
//                                               decoration: BoxDecoration(
//                                                 color: _mantraColor.withOpacity(0.1),
//                                                 shape: BoxShape.circle,
//                                               ),
//                                               child: Icon(Icons.palette_rounded, color: _mantraColor, size: 20),
//                                             ),
//                                           ),
//                                           const SizedBox(width: 12),
//
//                                           // 2. Font Slider
//                                           Expanded(
//                                             child: SliderTheme(
//                                               data: SliderTheme.of(context).copyWith(
//                                                 activeTrackColor: _mantraColor,
//                                                 inactiveTrackColor: _mantraColor.withOpacity(0.2),
//                                                 thumbColor: Colors.white,
//                                                 trackHeight: 3,
//                                               ),
//                                               child: Slider(
//                                                 value: _mantraFontSize,
//                                                 min: _minFontSize,
//                                                 max: _maxFontSize,
//                                                 onChanged: (v) => setState(() => _mantraFontSize = v),
//                                               ),
//                                             ),
//                                           ),
//
//                                           // 3. Size Indicator
//                                           Container(
//                                             width: 35,
//                                             padding: const EdgeInsets.symmetric(vertical: 4),
//                                             decoration: BoxDecoration(
//                                               border: Border.all(color: _mantraColor.withOpacity(0.2)),
//                                               borderRadius: BorderRadius.circular(6),
//                                             ),
//                                             child: Text(
//                                               '${_mantraFontSize.toInt()}',
//                                               textAlign: TextAlign.center,
//                                               style: TextStyle(color: _mantraColor, fontSize: 11, fontWeight: FontWeight.bold),
//                                             ),
//                                           ),
//                                         ],
//                                       ),
//                                     ],
//                                   ],
//                                 ),
//                               ),
//                             ),
//
//
//                             // ----------------------------------0 loop-0  reset---------------------
//                             SizedBox(
//                               height: 15,
//                             ),
//
//                             Row(
//                               children: [
//                                 GestureDetector(
//                                   onTap: _selectedItem.isEmpty
//                                       ? null
//                                       : _showBottomSheets,
//                                   child: Column(
//                                     children: [
//                                       Container(
//                                         width: screenwidth * 0.17,
//                                         height: screenHeight * 0.08,
//                                         decoration: BoxDecoration(
//                                           border: Border.all(
//                                               color: Colors.white, width: 1),
//                                           color: Colors.orange.withOpacity(
//                                               0.4), // highlight color
//                                           borderRadius:
//                                           BorderRadius.circular(300),
//                                         ),
//                                         child: Center(
//                                           child: Text(
//                                             '$_tapsPerLoop',
//                                             style: TextStyle(
//                                                 fontSize: _tapsPerLoop == 1008
//                                                     ? 24
//                                                     : 30,
//                                                 fontWeight: FontWeight.bold,
//                                                 color: Colors.white),
//                                           ),
//                                         ),
//                                       ),
//                                       const SizedBox(
//                                         height: 8,
//                                       ),
//                                       Container(
//                                           padding: const EdgeInsets.symmetric(
//                                               vertical: 2, horizontal: 5),
//                                           decoration: BoxDecoration(
//                                             border: Border.all(
//                                                 color: Colors.white,
//                                                 width: 1),
//                                             color: Colors.orange.withOpacity(
//                                                 0.4), // highlight color
//                                             borderRadius:
//                                             BorderRadius.circular(8),
//                                           ),
//                                           child: Center(
//                                               child: Text(_isHindi ? 'संख्या चुनें' : 'Set Count',
//                                                   style:  TextStyle(
//                                                       color: Colors.white,
//                                                       fontSize: 16)))),
//                                     ],
//                                   ),
//                                 ),
//                                 const Spacer(),
//                                 Text(
//                                   _isHindi ? 'माला : $_loopCounter' : 'Mala : $_loopCounter',
//                                   style: TextStyle(
//                                       fontSize: screenwidth * 0.08,
//                                       fontWeight: FontWeight.bold,
//                                       color: Colors.white),
//                                 ),
//                                 const Spacer(),
//                                 GestureDetector(
//                                   onTap: _selectedItem.isEmpty
//                                       ? null
//                                       : () async {
//                                     // make it async so await works
//                                     setState(() {
//                                       _tapCounter = 0;
//                                       _tapsPerLoop = 11;
//                                       _loopCounter = 0;
//                                       product = 0;
//                                     });
//
//                                     await DBHelper.instance.deleteData(
//                                         1); // deletes row with id=1
//                                     print(
//                                         'Data with id=1 deleted from DB');
//                                   },
//                                   child: Column(
//                                     children: [
//                                       Container(
//                                         width: screenwidth * 0.17,
//                                         height: screenHeight * 0.08,
//                                         decoration: BoxDecoration(
//                                           border: Border.all(
//                                               color: Colors.white, width: 1),
//                                           color:
//                                           Colors.orange.withOpacity(0.4),
//                                           borderRadius:
//                                           BorderRadius.circular(300),
//                                         ),
//                                         child: const Center(
//                                           child: Icon(Icons.restart_alt,
//                                               color: Colors.white, size: 35),
//                                         ),
//                                       ),
//                                       const SizedBox(height: 8),
//                                       Container(
//                                         padding: const EdgeInsets.symmetric(
//                                             vertical: 2, horizontal: 5),
//                                         decoration: BoxDecoration(
//                                           border: Border.all(
//                                               color: Colors.white, width: 1),
//                                           color:
//                                           Colors.orange.withOpacity(0.4),
//                                           borderRadius:
//                                           BorderRadius.circular(8),
//                                         ),
//                                         child: Center(
//                                           child: Text(
//                                             _isHindi ? 'रीसेट करें' : 'Reset',
//                                             style: TextStyle(
//                                                 color: Colors.white,
//                                                 fontSize: 16),
//                                           ),
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                 )
//                               ],
//                             ),
//
//                             GestureDetector(
//                               onTap: () {
//                                 if (_selectedItem.isEmpty) {
//                                   showCupertinoDialog(
//                                     context: context,
//                                     builder: (context) => CupertinoAlertDialog(
//                                       title: const Text('Please select the Jaap'),
//                                       actions: [
//                                         CupertinoDialogAction(
//                                           child: const Text('OK'),
//                                           onPressed: () => Navigator.of(context).pop(),
//                                         ),
//                                       ],
//                                     ),
//                                   );
//                                 } else {
//                                   setState(() {
//                                     _animationController.forward();
//                                     _onButtonTap(); // सारा वाइब्रेशन logic यहीं होगा
//                                     _incrementCounter();
//                                     product == 1 ? _startTimer() : null;
//                                   });
//                                   _saveData();
//                                 }
//                               },
//                               child: Transform.scale(
//                                 scale: _animation.value,
//                                 child: Stack(children: [
//                                   Container(
//                                     width: screenwidth * 0.75,
//                                     height: screenHeight * 0.35,
//                                     decoration: BoxDecoration(
//                                       image: const DecorationImage(
//                                           image: AssetImage(
//                                               'assets/images/jaap/flower.png')),
//                                       border: Border.all(
//                                           color: Colors.transparent,
//                                           width: 3),
//                                       color: Colors.transparent
//                                           .withOpacity(0.01),
//                                       borderRadius:
//                                       BorderRadius.circular(300),
//                                     ),
//                                     child: Center(
//                                       child: Text(
//                                         _tapCounter
//                                             .toString()
//                                             .padLeft(2, '0'),
//                                         style: TextStyle(
//                                           color: Colors.white,
//                                           fontSize: screenwidth * 0.23,
//                                           fontWeight: FontWeight.bold,
//                                         ),
//                                       ),
//                                     ),
//                                   ),
//                                 ]),
//                               ),
//                             ),
//
//                             Row(
//                               mainAxisAlignment: MainAxisAlignment.end,
//                               children: [
//                                 Container(
//                                   width: screenwidth * 0.17,
//                                   height: screenHeight * 0.08,
//                                   decoration: BoxDecoration(
//                                     border: Border.all(
//                                         color: Colors.white, width: 3),
//                                     color: Colors.orange
//                                         .withOpacity(0.5), // highlight color
//                                     borderRadius: BorderRadius.circular(300),
//                                   ),
//                                   child: Center(
//                                     child: TextButton(
//                                       child: Text(
//                                         'Save',
//                                         style: TextStyle(
//                                             fontSize: screenwidth * 0.035,
//                                             fontWeight: FontWeight.bold,
//                                             color: Colors.white),
//                                       ),
//                                       onPressed: () {
//                                         if (_selectedItem.isEmpty) {
//                                           // Show alert message
//                                           showCupertinoDialog(
//                                             context: context,
//                                             builder: (context) =>
//                                                 CupertinoAlertDialog(
//                                                   title: const Text(
//                                                       'Please select the Jaap'),
//                                                   actions: [
//                                                     CupertinoDialogAction(
//                                                       child: const Text(
//                                                         'OK',
//                                                         style: TextStyle(
//                                                             color: Colors
//                                                                 .blueAccent),
//                                                       ),
//                                                       onPressed: () {
//                                                         Navigator.of(context)
//                                                             .pop();
//                                                       },
//                                                     ),
//                                                   ],
//                                                 ),
//                                           );
//                                         } else {
//                                           _stopTimer();
//                                           countSave('$product');
//                                         }
//                                       },
//                                     ),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ),
//
//                   // --------------------------------RAM LEKHAN TAB STARTS------------------------------
//                   SingleChildScrollView(
//                     controller: _scrollController,
//                     physics: const ClampingScrollPhysics(),
//                     child: Container(
//                       height: screenHeight * 0.835,
//                       color: Colors.white,
//                       child: Stack(
//                         children: [
//                           // Pehle text display container ko add karein (background mein)
//                           Positioned.fill(
//                             child: Padding(
//                               padding: EdgeInsets.only(bottom: screenHeight * 0.3), // Signature ke liye space chhodein
//                               child: Container(
//                                 color: Colors.white,
//                                 child: Scrollbar(
//                                   child: SingleChildScrollView(
//                                     child: Column(
//                                       mainAxisAlignment: MainAxisAlignment.start,
//                                       crossAxisAlignment: CrossAxisAlignment.start,
//                                       children: [
//                                         Wrap(
//                                           spacing: 0,
//                                           runSpacing: 0,
//                                           children: [
//                                             // Signatures display
//                                             for (int i = 0; i < signatures.length; i++)
//                                               Container(
//                                                 decoration: BoxDecoration(
//                                                   border: Border(
//                                                     right: BorderSide(
//                                                       color: Colors.amber.shade200,
//                                                       width: 1.0,
//                                                     ),
//                                                     left: BorderSide(
//                                                       color: Colors.amber.shade200,
//                                                       width: 1.0,
//                                                     ),
//                                                     bottom: BorderSide(
//                                                       color: Colors.amber.shade200,
//                                                       width: 1.0,
//                                                     ),
//                                                   ),
//                                                 ),
//                                                 child: Padding(
//                                                   padding: const EdgeInsets.only(right: 8, left: 8),
//                                                   child: Image.memory(
//                                                     signatures[i],
//                                                     width: screenwidth * 0.0959,
//                                                     height: screenHeight * 0.063,
//                                                   ),
//                                                 ),
//                                               ),
//
//                                             // Texts display
//                                             for (var text in _texts) text,
//                                           ],
//                                         ),
//                                         const SizedBox(height: 20),
//                                       ],
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           ),
//
//                           // Signature container (top layer par)
//                           if (_isSignatureVisible)
//                             Positioned(
//                               bottom: 0, // Screen ke bottom par
//                               child: Column(
//                                 children: [
//                                   Container(
//                                     height: screenHeight * 0.26,
//                                     width: screenwidth * 0.999,
//                                     decoration: BoxDecoration(
//                                       color: Colors.red,
//                                       border: Border.all(color: Colors.red, width: 2),
//                                     ),
//                                     child: Signature(
//                                       controller: controllers,
//                                       width: double.infinity,
//                                       backgroundColor: Colors.white,
//                                     ),
//                                   )
//                                 ],
//                               ),
//                             ),
//
//                           // Keyboard input field (agar chahiye toh)
//                           // if (_showKeyboard)
//                           //   Positioned(
//                           //     bottom: screenHeight * 0.26 + 20, // Signature ke upar
//                           //     left: 0,
//                           //     right: 0,
//                           //     child: Padding(
//                           //       padding: const EdgeInsets.symmetric(horizontal: 12),
//                           //       child: SizedBox(
//                           //         width: screenwidth * 0.560,
//                           //         height: screenHeight * 0.06,
//                           //         child: TextFormField(
//                           //           controller: _textController,
//                           //           decoration: InputDecoration(
//                           //             suffixIcon: IconButton(
//                           //               icon: Icon(Icons.send),
//                           //               onPressed: () {
//                           //                 // _updateText(_textController.text);
//                           //                 _textController.clear();
//                           //                 // _toggleKeyboard();
//                           //                 // Scroll to bottom to show new text
//                           //                 WidgetsBinding.instance.addPostFrameCallback((_) {
//                           //                   _scrollController.animateTo(
//                           //                     _scrollController.position.maxScrollExtent,
//                           //                     duration: Duration(milliseconds: 300),
//                           //                     curve: Curves.easeOut,
//                           //                   );
//                           //                 });
//                           //               },
//                           //             ),
//                           //             hintText: 'Type here...',
//                           //             border: OutlineInputBorder(
//                           //               borderRadius: BorderRadius.circular(100),
//                           //             ),
//                           //           ),
//                           //         ),
//                           //       ),
//                           //     ),
//                           //   ),
//                         ],
//                       ),
//                     ),
//                   ),
//                   // --------------------------------RAM LEKHAN TAB ENDS------------------------------
//
//                   // Inside your TabBarView, add this for the Leaderboard tab:
//
//                   SingleChildScrollView(
//                     child: Container(
//                       padding: EdgeInsets.all(16),
//                       child: Column(
//                         children: [
//                           // Header Section
//                           Container(
//                             padding: EdgeInsets.all(10),
//                             decoration: BoxDecoration(
//                               gradient: LinearGradient(
//                                 colors: [Colors.orange.shade700, Colors.orange.shade400],
//                                 begin: Alignment.topLeft,
//                                 end: Alignment.bottomRight,
//                               ),
//                               borderRadius: BorderRadius.circular(20),
//                               boxShadow: [
//                                 BoxShadow(
//                                   color: Colors.orange.withOpacity(0.3),
//                                   blurRadius: 10,
//                                   offset: const Offset(0, 4),
//                                 ),
//                               ],
//                             ),
//                             child: Row(
//                               children: [
//                                 const Icon(Icons.leaderboard, color: Colors.white, size: 30),
//                                 const SizedBox(width: 10),
//                                 Expanded(
//                                   child: Column(
//                                     crossAxisAlignment: CrossAxisAlignment.start,
//                                     children: [
//                                       const Text(
//                                         'Jaap Leaderboard',
//                                         style: TextStyle(
//                                           color: Colors.white,
//                                           fontSize: 20,
//                                           fontWeight: FontWeight.bold,
//                                         ),
//                                       ),
//                                       const SizedBox(height: 5),
//                                       Text(
//                                         _getTimeFilterSubtitle(),
//                                         style: TextStyle(
//                                           color: Colors.white.withOpacity(0.9),
//                                           fontSize: 14,
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//
//                           SizedBox(height: 20),
//
//                           // Time Filter Tabs
//                           Container(
//                             decoration: BoxDecoration(
//                               color: Colors.grey.shade50,
//                               borderRadius: BorderRadius.circular(12),
//                               border: Border.all(color: Colors.grey.shade200),
//                             ),
//                             child: Row(
//                               children: [
//                                 _buildTimeTab('Daily', 0),
//                                 _buildTimeTab('Weekly', 1),
//                                 _buildTimeTab('Monthly', 2),
//                                 _buildTimeTab('All Time', 3),
//                               ],
//                             ),
//                           ),
//
//                           SizedBox(height: 10),
//
//                           // // Top 3 Winners
//                           // Text(
//                           //   'Top Performers',
//                           //   style: TextStyle(
//                           //     fontSize: 18,
//                           //     fontWeight: FontWeight.bold,
//                           //     color: Colors.orange.shade800,
//                           //   ),
//                           // ),
//                           // const SizedBox(height: 35),
//                           Row(
//                             mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                             children: _buildTopThreeWinners(),
//                           ),
//
//                           SizedBox(height: 20),
//
//                           // Leaderboard List
//                           Container(
//                             decoration: BoxDecoration(
//                               color: Colors.transparent,
//                               borderRadius: BorderRadius.circular(15),
//                               boxShadow: [
//                                 BoxShadow(
//                                   color: Colors.grey.withOpacity(0.1),
//                                   blurRadius: 10,
//                                   offset: Offset(0, 2),
//                                 ),
//                               ],
//                             ),
//                             child: Column(
//                               children: [
//                                 // List Header
//                                 Container(
//                                   padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//                                   decoration: BoxDecoration(
//                                     color: Colors.orange.shade50,
//                                     borderRadius: BorderRadius.only(
//                                       topLeft: Radius.circular(15),
//                                       topRight: Radius.circular(15),
//                                     ),
//                                   ),
//                                   child: Row(
//                                     children: [
//                                       Text('Rank', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange.shade800)),
//                                       SizedBox(width: 20),
//                                       Expanded(child: Text('Devotee', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange.shade800))),
//                                       Text('Jaap Count', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange.shade800)),
//                                     ],
//                                   ),
//                                 ),
//
//                                 // Leaderboard Items
//                                 ..._buildLeaderboardList(),
//                               ],
//                             ),
//                           ),
//
//                           const SizedBox(height: 20),
//
//                           // Current User Stats
//                           Container(
//                             padding: const EdgeInsets.all(16),
//                             decoration: BoxDecoration(
//                               gradient: LinearGradient(
//                                 colors: [Colors.deepOrange.shade50, Colors.orange.shade50],
//                                 begin: Alignment.topLeft,
//                                 end: Alignment.bottomRight,
//                               ),
//                               borderRadius: BorderRadius.circular(15),
//                               border: Border.all(color: Colors.orange.shade200),
//                             ),
//                             child: Row(
//                               children: [
//                                 Container(
//                                   padding: const EdgeInsets.all(10),
//                                   decoration: BoxDecoration(
//                                     color: Colors.orange.shade100,
//                                     shape: BoxShape.circle,
//                                   ),
//                                   child: Icon(Icons.person, color: Colors.orange.shade700),
//                                 ),
//                                 const SizedBox(width: 15),
//                                 Expanded(
//                                   child: Column(
//                                     crossAxisAlignment: CrossAxisAlignment.start,
//                                     children: [
//                                       Text(
//                                         'Your Position',
//                                         style: TextStyle(
//                                           color: Colors.orange.shade800,
//                                           fontWeight: FontWeight.bold,
//                                         ),
//                                       ),
//                                       Text(
//                                         "Rank #${_getUserStats()['rank']} • ${_getUserStats()['count']} Jaaps",
//                                         style: TextStyle(
//                                           color: Colors.orange.shade600,
//                                           fontSize: 16,
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                                 Container(
//                                   padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//                                   decoration: BoxDecoration(
//                                     color: Colors.orange.shade100,
//                                     borderRadius: BorderRadius.circular(20),
//                                   ),
//                                   child: Text(
//                                     _getUserStats()['progress'],
//                                     style: TextStyle(
//                                       color: Colors.orange.shade700,
//                                       fontWeight: FontWeight.bold,
//                                       fontSize: 12,
//                                     ),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//
//                           const SizedBox(height: 20),
//
//                           // Motivational Quote
//                           Container(
//                             padding: const EdgeInsets.all(16),
//                             decoration: BoxDecoration(
//                               color: Colors.orange.shade50,
//                               borderRadius: BorderRadius.circular(12),
//                               border: Border.all(color: Colors.orange.shade100),
//                             ),
//                             child: Row(
//                               children: [
//                                 Icon(Icons.lightbulb_outline, color: Colors.orange.shade600),
//                                 const SizedBox(width: 10),
//                                 Expanded(
//                                   child: Text(
//                                     _getMotivationalQuote(),
//                                     style: TextStyle(
//                                       color: Colors.orange.shade700,
//                                       fontStyle: FontStyle.italic,
//                                     ),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//
//                   // Score History
//                   Center(
//                     child: History(
//                       product: product,
//                       data: _savedCounts,
//                       index: tabIndex,
//                       counter: _counter,
//                       pressCounts: _pressCounts,
//                       selectedItem: _selectedItem,
//                       currentTime: _currentTime,
//                     ),
//                   ),
//
//                   // NEW: Program Karyakram Tab Content
//                   Container(
//                     padding: const EdgeInsets.all(16),
//                     child: Stack(
//                       children: [
//                         // Events List
//                         events.isEmpty
//                             ? Center(
//                           child: Column(
//                             mainAxisAlignment: MainAxisAlignment.center,
//                             children: [
//                               const Icon(
//                                 Icons.event_note,
//                                 size: 100,
//                                 color: Colors.white60,
//                               ),
//                               const SizedBox(height: 20),
//                               const Text(
//                                 'कोई कार्यक्रम नहीं है',
//                                 style: TextStyle(
//                                   color: Colors.white60,
//                                   fontSize: 18,
//                                 ),
//                               ),
//                               const SizedBox(height: 10),
//                               const Text(
//                                 'पहला कार्यक्रम जोड़ने के लिए\nनीचे + बटन दबाएं',
//                                 style: TextStyle(
//                                   color: Colors.white54,
//                                   fontSize: 14,
//                                 ),
//                                 textAlign: TextAlign.center,
//                               ),
//                             ],
//                           ),
//                         )
//                             : ListView.builder(
//                           itemCount: events.length,
//                           itemBuilder: (context, index) {
//                             final event = events[index];
//                             return GestureDetector(
//                               onTap: () {
//                                 // Show event details when tapped
//                                 _showEventDetails(index);
//                               },
//                               child: Container(
//                                 margin: const EdgeInsets.only(bottom: 12),
//                                 decoration: BoxDecoration(
//                                   gradient: LinearGradient(
//                                     begin: Alignment.centerLeft,
//                                     end: Alignment.centerRight,
//                                     colors: [
//                                       Colors.black.withOpacity(0.8),
//                                       Colors.grey[900]!.withOpacity(0.8),
//                                     ],
//                                   ),
//                                   borderRadius: BorderRadius.circular(12),
//                                   boxShadow: [
//                                     BoxShadow(
//                                       color: event['isPublic']
//                                           ? Colors.blue.withOpacity(0.3)
//                                           : Colors.purple.withOpacity(0.3),
//                                       blurRadius: 8,
//                                       offset: const Offset(0, 2),
//                                     ),
//                                   ],
//                                   border: Border.all(
//                                     color: event['isPublic']
//                                         ? Colors.blue.withOpacity(0.5)
//                                         : Colors.purple.withOpacity(0.5),
//                                     width: 1,
//                                   ),
//                                 ),
//                                 child: Padding(
//                                   padding: const EdgeInsets.all(12),
//                                   child: Row(
//                                     crossAxisAlignment: CrossAxisAlignment.start,
//                                     children: [
//                                       // Status Icon
//                                       Container(
//                                         width: 40,
//                                         height: 40,
//                                         decoration: BoxDecoration(
//                                           color: event['isPublic']
//                                               ? Colors.blue.withOpacity(0.3)
//                                               : Colors.purple.withOpacity(0.3),
//                                           borderRadius: BorderRadius.circular(8),
//                                         ),
//                                         child: Icon(
//                                           event['isPublic'] ? Icons.public : Icons.lock,
//                                           color: event['isPublic'] ? Colors.blue : Colors.purple,
//                                           size: 20,
//                                         ),
//                                       ),
//                                       const SizedBox(width: 12),
//
//                                       // Event Details
//                                       Expanded(
//                                         child: Column(
//                                           crossAxisAlignment: CrossAxisAlignment.start,
//                                           children: [
//                                             // Event Name
//                                             Text(
//                                               event['name'],
//                                               style: const TextStyle(
//                                                 color: Colors.white,
//                                                 fontWeight: FontWeight.bold,
//                                                 fontSize: 16,
//                                               ),
//                                               maxLines: 1,
//                                               overflow: TextOverflow.ellipsis,
//                                             ),
//                                             const SizedBox(height: 4),
//
//                                             // Group
//                                             if (event['group'] != null && event['group'].isNotEmpty)
//                                               Padding(
//                                                 padding: const EdgeInsets.only(bottom: 2),
//                                                 child: Row(
//                                                   children: [
//                                                     const Icon(
//                                                       Icons.group,
//                                                       color: Colors.grey,
//                                                       size: 14,
//                                                     ),
//                                                     const SizedBox(width: 4),
//                                                     Text(
//                                                       event['group'],
//                                                       style: const TextStyle(
//                                                         color: Colors.grey,
//                                                         fontSize: 12,
//                                                       ),
//                                                     ),
//                                                   ],
//                                                 ),
//                                               ),
//
//                                             // Venue
//                                             if (event['venue'] != null && event['venue'].isNotEmpty)
//                                               Padding(
//                                                 padding: const EdgeInsets.only(bottom: 2),
//                                                 child: Row(
//                                                   children: [
//                                                     const Icon(
//                                                       Icons.location_on,
//                                                       color: Colors.grey,
//                                                       size: 14,
//                                                     ),
//                                                     const SizedBox(width: 4),
//                                                     Text(
//                                                       event['venue'],
//                                                       style: const TextStyle(
//                                                         color: Colors.grey,
//                                                         fontSize: 12,
//                                                       ),
//                                                     ),
//                                                   ],
//                                                 ),
//                                               ),
//
//                                             // Dates
//                                             Row(
//                                               children: [
//                                                 const Icon(
//                                                   Icons.calendar_today,
//                                                   color: Colors.orange,
//                                                   size: 14,
//                                                 ),
//                                                 const SizedBox(width: 4),
//                                                 Text(
//                                                   '${event['startDate']} - ${event['endDate']}',
//                                                   style: const TextStyle(
//                                                     color: Colors.orange,
//                                                     fontSize: 10,
//                                                   ),
//                                                 ),
//                                               ],
//                                             ),
//                                           ],
//                                         ),
//                                       ),
//
//                                       // Action Buttons - SUPER COMPACT
//                                       Row(
//                                         mainAxisSize: MainAxisSize.min,
//                                         children: [
//                                           // Share Button
//                                           GestureDetector(
//                                             onTap: () => _shareEvent(event),
//                                             child: Container(
//                                               padding: const EdgeInsets.all(6),
//                                               margin: const EdgeInsets.only(right: 2),
//                                               decoration: BoxDecoration(
//                                                 color: Colors.green.withOpacity(0.1),
//                                                 borderRadius: BorderRadius.circular(6),
//                                               ),
//                                               child: const Icon(
//                                                 Icons.share,
//                                                 color: Colors.green,
//                                                 size: 19,
//                                               ),
//                                             ),
//                                           ),
//
//                                           // Edit Button
//                                           GestureDetector(
//                                             onTap: () => _showEventDialog(index: index),
//                                             child: Container(
//                                               padding: const EdgeInsets.all(6),
//                                               margin: const EdgeInsets.only(right: 2),
//                                               decoration: BoxDecoration(
//                                                 color: Colors.blue.withOpacity(0.1),
//                                                 borderRadius: BorderRadius.circular(6),
//                                               ),
//                                               child: const Icon(
//                                                 Icons.edit,
//                                                 color: Colors.blue,
//                                                 size: 19,
//                                               ),
//                                             ),
//                                           ),
//
//                                           // Delete Button
//                                           GestureDetector(
//                                             onTap: () {
//                                               showDialog(
//                                                 context: context,
//                                                 builder: (context) => AlertDialog(
//                                                   title: const Text('कार्यक्रम हटाएं'),
//                                                   content: const Text('क्या आप वाकई इस कार्यक्रम को हटाना चाहते हैं?'),
//                                                   actions: [
//                                                     TextButton(
//                                                       onPressed: () => Navigator.pop(context),
//                                                       child: const Text('रद्द करें'),
//                                                     ),
//                                                     TextButton(
//                                                       onPressed: () {
//                                                         setState(() {
//                                                           events.removeAt(index);
//                                                         });
//                                                         Navigator.pop(context);
//                                                       },
//                                                       child: const Text(
//                                                         'हटाएं',
//                                                         style: TextStyle(color: Colors.red),
//                                                       ),
//                                                     ),
//                                                   ],
//                                                 ),
//                                               );
//                                             },
//                                             child: Container(
//                                               padding: const EdgeInsets.all(6),
//                                               decoration: BoxDecoration(
//                                                 color: Colors.red.withOpacity(0.1),
//                                                 borderRadius: BorderRadius.circular(6),
//                                               ),
//                                               child: const Icon(
//                                                 Icons.delete,
//                                                 color: Colors.red,
//                                                 size: 19,
//                                               ),
//                                             ),
//                                           ),
//                                         ],
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                               ),
//                             );
//                           },
//                         ),
//
//                         // Add Event Floating Button
//                         Positioned(
//                           bottom: 20,
//                           right: 20,
//                           child: FloatingActionButton(
//                             onPressed: () => _showEventDialog(),
//                             backgroundColor: Colors.orange,
//                             child: const Icon(Icons.add, color: Colors.white, size: 30),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//       floatingActionButton: _tabController.index == 1
//           ? Stack(
//         children: [
//           _isSignatureVisible
//               ? Positioned(
//             bottom: 10,
//             right: 10,
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.end,
//               children: [
//                 IconButton(
//                   onPressed: () {
//                     setState(() {
//                       _isSignatureVisible =
//                       false; // Toggle the visibility
//                     });
//                   },
//                   icon: Icon(
//                     _isSignatureVisible
//                         ? Icons.cancel
//                         : Icons.edit,
//                     size: 30,
//                   ),
//                 ),
//                 const SizedBox(height: 5),
//                 IconButton(
//                   onPressed: () async {
//                     controllers.clear();
//                     setState(() {});
//                   },
//                   icon: const Icon(Icons.undo),
//                 ),
//                 const SizedBox(height: 5),
//                 IconButton(
//                   onPressed: () async {
//                     Uint8List? newSignature =
//                     await controllers.toPngBytes();
//                     if (newSignature != null) {
//                       signatures.add(newSignature);
//                       setState(() {});
//                     }
//                     _incrementButtonPressCounts();
//                     // Clear the signature pad after saving
//                     controllers.clear();
//                   },
//                   icon: const Icon(Icons.done),
//                 ),
//               ],
//             ),
//           )
//               : Positioned(
//             right: 10,
//             bottom: 10,
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.end,
//               crossAxisAlignment: CrossAxisAlignment.end,
//               children: [
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.start,
//                   children: [
//                     IconButton(
//                       onPressed: () async {
//                         showCupertinoDialog(
//                           context: context,
//                           builder: (BuildContext context) {
//                             return CupertinoAlertDialog(
//                               title: const Text('Clear All'),
//                               actions: [
//                                 CupertinoDialogAction(
//                                   child: const Text(
//                                     'Cancel',
//                                     style: TextStyle(
//                                         color: Colors.blue),
//                                   ),
//                                   onPressed: () {
//                                     Navigator.of(context).pop();
//                                   },
//                                 ),
//                                 CupertinoDialogAction(
//                                   child: const Text(
//                                     'Clear',
//                                     style: TextStyle(
//                                       color: Colors.red,
//                                     ),
//                                   ),
//                                   onPressed: () {
//                                     _texts.clear();
//                                     signatures.clear();
//                                     _buttonPressCount = 0;
//                                     _buttonPressCounts = 0;
//                                     _totalPressCount = 0;
//                                     _textController.clear();
//                                     _textstype.clear();
//                                     setState(() {});
//                                     Navigator.of(context).pop();
//                                   },
//                                 ),
//                               ],
//                             );
//                           },
//                         );
//                       },
//                       icon: Image.network(
//                         'https://w7.pngwing.com/pngs/892/810/png-transparent-computer-icons-eraser-icon-design-graphic-design-eraser-angle-logo-black-thumbnail.png',
//                         width:
//                         24, // adjust the width and height to your liking
//                         height: 24,
//                       ),
//                     ),
//                     const SizedBox(
//                       width: 10.0,
//                     ),
//                     IconButton(
//                       onPressed: () {
//                         setState(() {
//                           _isSignatureVisible =
//                           true; // Toggle the visibility
//                         });
//                       },
//                       icon: Icon(
//                         _isSignatureVisible
//                             ? Icons.done
//                             : Icons.edit,
//                       ),
//                     ),
//                   ],
//                 ),
//
//                 // Score btn Ram btn Count
//                 Column(
//                   children: [
//                     Container(
//                       width: screenwidth * 0.17,
//                       height: screenHeight * 0.08,
//                       decoration: BoxDecoration(
//                         border: Border.all(
//                             color: Colors.purple.shade300,
//                             width: 1),
//                         color: Colors.grey.withOpacity(0.1),
//                         borderRadius: BorderRadius.circular(300),
//                       ),
//                       child: Center(
//                         child: Text(
//                           _totalPressCount
//                               .toString()
//                               .padLeft(2, '0'),
//                           style: TextStyle(
//                               fontSize: screenwidth * 0.070,
//                               fontWeight: FontWeight.bold,
//                               color: Colors.purple.shade300),
//                         ),
//                       ),
//                     ),
//                     const SizedBox(
//                       height: 10,
//                     ),
//                     Container(
//                       width: screenwidth * 0.17,
//                       height: screenHeight * 0.08,
//                       decoration: BoxDecoration(
//                         border: Border.all(
//                             color: Colors.purple.shade300,
//                             width: 1),
//                         color: Colors.grey.withOpacity(0.1),
//                         borderRadius: BorderRadius.circular(300),
//                       ),
//                       child: Center(
//                         child: TextButton(
//                           child: Text(
//                             'Score',
//                             style: TextStyle(
//                                 fontSize: screenwidth * 0.034,
//                                 fontWeight: FontWeight.bold,
//                                 color: Colors.purple.shade300),
//                           ),
//                           onPressed: () {
//                             if (_totalPressCount == 0 &&
//                                 _texts.isEmpty &&
//                                 signatures.isEmpty &&
//                                 _textstype.isEmpty) {
//                               // Show alert message
//                               showCupertinoDialog(
//                                 context: context,
//                                 builder: (context) =>
//                                     CupertinoAlertDialog(
//                                       title: const Text(
//                                           'Please perform some action'),
//                                       actions: [
//                                         CupertinoDialogAction(
//                                           child: const Text(
//                                             'OK',
//                                             style: TextStyle(
//                                                 color: Colors
//                                                     .blueAccent),
//                                           ),
//                                           onPressed: () {
//                                             Navigator.of(context)
//                                                 .pop();
//                                           },
//                                         ),
//                                       ],
//                                     ),
//                               );
//                             } else {
//                               // Navigate to ResultPage and pass the product
//                               // Use DefaultTabController.of(context) to access TabController
//                               _stopTimer();
//                               ramLekhanSave('$_totalPressCount');
//                             }
//                           },
//                         ),
//                       ),
//                     ),
//                     Row(
//                       children: [
//                         SizedBox(height: screenHeight * 0.10),
//                         InkWell(
//                           onTap: () {
//                             setState(() {
//                               if (_vibrationEnabled) {
//                                 HapticFeedback.heavyImpact();
//
//                                 // Vibrate.feedback(FeedbackType
//                                 //     .warning); // Enable vibration
//                               }
//                               _addText();
//                               _incrementButtonPressCount();
//                               _scrollToLastSignature();
//                               _startTimer();
//                             });
//                           },
//                           child: Container(
//                             width: screenwidth * 0.17,
//                             height: screenHeight * 0.08,
//                             decoration: BoxDecoration(
//                               border: Border.all(
//                                   color: Colors.purple.shade300,
//                                   width: 1),
//                               color: Colors.grey.withOpacity(0.1),
//                               borderRadius:
//                               BorderRadius.circular(300),
//                             ),
//                             child: Center(
//                               child: Text(
//                                 'Ram',
//                                 style: TextStyle(
//                                     fontSize: screenwidth * 0.034,
//                                     fontWeight: FontWeight.bold,
//                                     color:
//                                     Colors.purple.shade300),
//                               ),
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           )
//         ],
//       )
//           : const SizedBox(),
//     );
//   }
//
//   void _shareEvent(Map<String, dynamic> event) async {
//     final String shareText = '''
// 🎯 कार्यक्रम: ${event['name']}
// 👥 समूह: ${event['group'] ?? 'नहीं'}
// 📍 स्थान: ${event['venue'] ?? 'नहीं'}
// 📅 तिथि: ${event['startDate']} से ${event['endDate']}
// 📝 विवरण: ${event['description'] ?? 'नहीं'}
// 🔓 स्थिति: ${event['isPublic'] ? 'सार्वजनिक' : 'निजी'}
//   ''';
//
//     // You need to add the share package: flutter pub add share
//     // import 'package:share/share.dart';
//
//     // Share.share(shareText);
//
//     // For now, show a dialog
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('शेयर करें'),
//         content: SelectableText(shareText),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('बंद करें'),
//           ),
//         ],
//       ),
//     );
//   }
//
//   // 2. Add this method to show the BottomSheet
//   void _showMantraBottomSheet() {
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       backgroundColor: Colors.transparent,
//       builder: (context) {
//         double screenHeight = MediaQuery.of(context).size.height;
//
//         return StatefulBuilder(
//           builder: (context, setState) {
//             return Container(
//               height: screenHeight * 0.7,
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.only(
//                   topLeft: Radius.circular(20),
//                   topRight: Radius.circular(20),
//                 ),
//               ),
//               child: Column(
//                 children: [
//                   // Header with title and close button
//                   Container(
//                     padding: EdgeInsets.all(16),
//                     decoration: BoxDecoration(
//                       color: Colors.white,
//                       borderRadius: BorderRadius.only(
//                         topLeft: Radius.circular(20),
//                         topRight: Radius.circular(20),
//                       ),
//                       boxShadow: [
//                         BoxShadow(
//                           color: Colors.black12,
//                           blurRadius: 4,
//                           offset: Offset(0, -2),
//                         ),
//                       ],
//                     ),
//                     child: Stack(
//                       alignment: Alignment.center,
//                       children: [
//                         // Title - Centered
//                         Text(
//                           '                    Select Mantra                           ',
//                           style: TextStyle(
//                             fontSize: 20,
//                             fontWeight: FontWeight.bold,
//                             color: Colors.orange,
//                           ),
//                         ),
//                         // Close button at right end corner
//                         Positioned(
//                           right: 0,
//                           child: IconButton(
//                             icon: Icon(Icons.close, color: Colors.grey, size: 24),
//                             onPressed: () {
//                               Navigator.pop(context);
//                             },
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//
//                   // Divider
//                   Divider(height: 1, color: Colors.grey.shade300),
//
//                   // Check if mantras are loading
//                   if (_isLoadingMantras)
//                     Expanded(
//                       child: Center(
//                         child: Column(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: [
//                             CircularProgressIndicator(
//                               color: Colors.orange,
//                               strokeWidth: 3,
//                             ),
//                             SizedBox(height: 16),
//                             Text(
//                               'Loading mantras...',
//                               style: TextStyle(
//                                 color: Colors.orange,
//                                 fontSize: 16,
//                                 fontWeight: FontWeight.w500,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     )
//                   else if (jaapModelList.isEmpty)
//                     Expanded(
//                       child: Center(
//                         child: Column(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: [
//                             Icon(
//                               Icons.psychology_outlined,
//                               size: 60,
//                               color: Colors.grey.shade400,
//                             ),
//                             SizedBox(height: 16),
//                             Text(
//                               'No mantras available',
//                               style: TextStyle(
//                                 color: Colors.grey.shade600,
//                                 fontSize: 16,
//                                 fontWeight: FontWeight.w500,
//                               ),
//                             ),
//                             SizedBox(height: 8),
//                             Text(
//                               'Try adding a custom mantra',
//                               style: TextStyle(
//                                 color: Colors.grey.shade500,
//                                 fontSize: 14,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     )
//                   else
//                   // Scrollable list of mantras with pagination
//                     Expanded(
//                       child: Scrollbar(
//                         child: ListView.builder(
//                           padding: EdgeInsets.symmetric(horizontal: 16),
//                           itemCount: jaapModelList.length,
//                           itemBuilder: (context, index) {
//                             var j = jaapModelList[index];
//                             bool isCustom = _customMantras.any((customMantra) => customMantra.id == j.id);
//
//                             String displayName = j.jaap?.isNotEmpty == true
//                                 ? j.jaap!
//                                 : (j.mantra?.split(' ').take(3).join(' ') ?? 'Mantra') +
//                                 ((j.mantra?.split(' ').length ?? 0) > 3 ? '...' : '');
//
//                             return GestureDetector(
//                               onTap: () {
//                                 Navigator.pop(context);
//                                 _handleMantraSelectionFromBottomSheet(j, isCustom);
//                               },
//                               child: Container(
//                                 margin: EdgeInsets.only(bottom: 12),
//                                 padding: EdgeInsets.all(16),
//                                 decoration: BoxDecoration(
//                                   color: Colors.white,
//                                   borderRadius: BorderRadius.circular(12),
//                                   border: Border.all(
//                                     color: isCustom ? Colors.green.shade300 : Colors.grey.shade300,
//                                     width: isCustom ? 1.5 : 1,
//                                   ),
//                                   boxShadow: [
//                                     BoxShadow(
//                                       color: isCustom ? Colors.green.shade100 : Colors.black12,
//                                       blurRadius: 2,
//                                       offset: Offset(0, 1),
//                                     ),
//                                   ],
//                                 ),
//                                 child: Column(
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   children: [
//                                     Row(
//                                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                                       children: [
//                                         Text(
//                                           isCustom ? 'My Mantra' : 'Mantra ${j.id}',
//                                           style: TextStyle(
//                                             fontSize: 12,
//                                             fontWeight: FontWeight.w600,
//                                             color: isCustom ? Colors.green : Colors.orange,
//                                           ),
//                                         ),
//                                         if (isCustom)
//                                           Container(
//                                             padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
//                                             decoration: BoxDecoration(
//                                               color: Colors.green.shade50,
//                                               borderRadius: BorderRadius.circular(4),
//                                               border: Border.all(
//                                                   color: Colors.green.shade200, width: 0.5),
//                                             ),
//                                             child: Text(
//                                               'Custom',
//                                               style: TextStyle(
//                                                 fontSize: 10,
//                                                 fontWeight: FontWeight.w500,
//                                                 color: Colors.green.shade700,
//                                               ),
//                                             ),
//                                           ),
//                                       ],
//                                     ),
//                                     SizedBox(height: 8),
//                                     Text(
//                                       displayName,
//                                       style: TextStyle(
//                                         fontSize: 16, // Reduced from 24 for better visibility
//                                         fontWeight: FontWeight.w500,
//                                         color: Colors.grey.shade800,
//                                       ),
//                                       maxLines: 2,
//                                       overflow: TextOverflow.ellipsis,
//                                     ),
//                                     if (j.mantra != null && j.mantra!.length > 100)
//                                       Padding(
//                                         padding: EdgeInsets.only(top: 4),
//                                         child: Text(
//                                           'Tap to view full mantra',
//                                           style: TextStyle(
//                                             fontSize: 12,
//                                             color: Colors.blue,
//                                             fontStyle: FontStyle.italic,
//                                           ),
//                                         ),
//                                       ),
//                                   ],
//                                 ),
//                               ),
//                             );
//                           },
//                         ),
//                       ),
//                     ),
//
//                   // Bottom buttons section - 3 buttons in row
//                   Container(
//                     padding: EdgeInsets.all(16),
//                     decoration: BoxDecoration(
//                       color: Colors.white,
//                       border: Border(
//                         top: BorderSide(color: Colors.grey.shade300, width: 1),
//                       ),
//                     ),
//                     child: Row(
//                       children: [
//                         // View All button
//                         Expanded(
//                           child: ElevatedButton(
//                             onPressed: _isNavigatingToAllMantras
//                                 ? null
//                                 : () {
//                               setState(() {
//                                 _isNavigatingToAllMantras = true;
//                               });
//                               Navigator.pop(context);
//                               _navigateToAllMantrasPage();
//                             },
//                             style: ElevatedButton.styleFrom(
//                               backgroundColor: Colors.blue.shade50,
//                               foregroundColor: Colors.blue.shade800,
//                               shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(10),
//                                 side: BorderSide(color: Colors.blue.shade300),
//                               ),
//                               padding: EdgeInsets.symmetric(vertical: 14),
//                             ),
//                             child: _isNavigatingToAllMantras
//                                 ? SizedBox(
//                               height: 20,
//                               width: 20,
//                               child: CircularProgressIndicator(
//                                 strokeWidth: 2,
//                                 color: Colors.blue.shade800,
//                               ),
//                             )
//                                 : Row(
//                               mainAxisAlignment: MainAxisAlignment.center,
//                               children: [
//                                 Icon(Icons.list_alt, size: 20),
//                                 SizedBox(width: 8),
//                                 Text(
//                                   'View All',
//                                   style: TextStyle(
//                                     fontSize: 15,
//                                     fontWeight: FontWeight.w500,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ),
//
//                         SizedBox(width: 12),
//
//                         // Favorites button (Heart Icon)
//                         Container(
//                           width: 60,
//                           child: ElevatedButton(
//                             onPressed: () {
//                               Navigator.pop(context);
//                               Navigator.push(
//                                 context,
//                                 MaterialPageRoute(
//                                   builder: (context) => FavoriteMantrasPage(),
//                                 ),
//                               );
//                             },
//                             style: ElevatedButton.styleFrom(
//                               backgroundColor: Colors.pink.shade50,
//                               foregroundColor: Colors.pink.shade700,
//                               shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(10),
//                                 side: BorderSide(color: Colors.pink.shade300),
//                               ),
//                               padding: EdgeInsets.symmetric(vertical: 14, horizontal: 8),
//                             ),
//                             child: Column(
//                               mainAxisSize: MainAxisSize.min,
//                               children: [
//                                 Icon(Icons.favorite, size: 20),
//                                 SizedBox(height: 2),
//                                 Text(
//                                   'Saved',
//                                   style: TextStyle(
//                                     fontSize: 11,
//                                     fontWeight: FontWeight.w500,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ),
//
//                         SizedBox(width: 12),
//
//                         // Add Custom button
//                         Expanded(
//                           child: ElevatedButton(
//                             onPressed: () {
//                               Navigator.pop(context);
//                               _showAddCustomMantraDialog();
//                             },
//                             style: ElevatedButton.styleFrom(
//                               backgroundColor: Colors.green.shade50,
//                               foregroundColor: Colors.green.shade800,
//                               shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(10),
//                                 side: BorderSide(color: Colors.green.shade300),
//                               ),
//                               padding: EdgeInsets.symmetric(vertical: 14),
//                             ),
//                             child: Row(
//                               mainAxisAlignment: MainAxisAlignment.center,
//                               children: [
//                                 Icon(Icons.add_circle, size: 20),
//                                 SizedBox(width: 8),
//                                 Text(
//                                   'Add Custom',
//                                   style: TextStyle(
//                                     fontSize: 15,
//                                     fontWeight: FontWeight.w500,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                   SizedBox(height: 30,)
//                 ],
//               ),
//             );
//           },
//         );
//       },
//     );
//   }
//
//   void _handleMantraSelectionFromBottomSheet(JaapList j, bool isCustom) {
//     String? selectedMantra;
//     String? mantraId;
//     String? mantraName;
//
//     try {
//       // Store the current JaapList object
//       _currentJaapList = j;
//
//       // Check language preference and select appropriate mantra
//       if (_isHindi) {
//         selectedMantra = j.hiMantra ?? j.mantra; // Hindi first, fallback to English
//       } else {
//         selectedMantra = j.mantra ?? j.hiMantra; // English first, fallback to Hindi
//       }
//
//       mantraId = j.id.toString();
//       mantraName = j.jaap;
//
//       if (selectedMantra != null) {
//         // Store for later use
//         _selectedMantraForSankalp = selectedMantra;
//
//         // Show confirmation dialog first
//         _showSankalpConfirmationDialog(selectedMantra, mantraId!, mantraName!);
//       }
//     } catch (e) {
//       print('Error selecting mantra: $e');
//       // If error occurs, just set the mantra without sankalp
//       if (selectedMantra != null) {
//         setState(() {
//           _selectedItem = selectedMantra!;
//         });
//       }
//     }
//   }
//
//   void _updateCurrentMantraLanguage() {
//     // Assuming you have access to the current JaapList object
//     // This method would find the current mantra and update _selectedItem
//     if (_currentJaapList != null) {
//       setState(() {
//         if (_isHindi) {
//           _selectedItem = _currentJaapList!.hiMantra ?? _currentJaapList!.mantra;
//         } else {
//           _selectedItem = _currentJaapList!.mantra ?? _currentJaapList!.hiMantra;
//         }
//       });
//     }
//   }
//
//   void _toggleLanguage() {
//     setState(() {
//       _isHindi = !_isHindi;
//     });
//
//     // Update current mantra to selected language
//     _updateCurrentMantraLanguage();
//   }
//
//   // Update the navigate method
//   void _navigateToAllMantrasPage() async {
//     // Add a small delay to show the loading indicator
//     await Future.delayed(Duration(milliseconds: 300));
//
//     // Navigate to All Mantras page
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => AllMantrasPage(),
//       ),
//     ).then((_) {
//       // Reset the navigation flag when returning from the page
//       if (mounted) {
//         setState(() {
//           _isNavigatingToAllMantras = false;
//         });
//       }
//     });
//   }
//
//   void _showAddCustomMantraDialog() {
//     showDialog(
//       context: context,
//       builder: (context) {
//         return AlertDialog(
//           title: Text(
//             'Add Custom Mantra',
//             style: TextStyle(color: Colors.orange),
//           ),
//           content: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               // Mantra Name (Optional)
//               TextField(
//                 controller: _customMantraNameController,
//                 decoration: InputDecoration(
//                   hintText: 'Mantra name (optional)...',
//                   border: OutlineInputBorder(),
//                   filled: true,
//                   fillColor: Colors.grey.shade100,
//                 ),
//               ),
//               SizedBox(height: 12),
//
//               // Mantra Text (Required)
//               TextField(
//                 controller: _customMantraController,
//                 maxLines: 4,
//                 decoration: InputDecoration(
//                   hintText: 'Enter your custom mantra here...',
//                   border: OutlineInputBorder(),
//                   filled: true,
//                   fillColor: Colors.grey.shade100,
//                 ),
//               ),
//               SizedBox(height: 16),
//               if (_isPostingMantra)
//                 CircularProgressIndicator(color: Colors.orange),
//             ],
//           ),
//           actions: [
//             TextButton(
//               onPressed: () {
//                 Navigator.pop(context);
//                 _customMantraNameController.clear();
//                 _customMantraController.clear();
//               },
//               child: Text('Cancel', style: TextStyle(color: Colors.grey)),
//             ),
//             ElevatedButton(
//               onPressed: _isPostingMantra
//                   ? null
//                   : () async {
//                 final mantra = _customMantraController.text.trim();
//                 final mantraName = _customMantraNameController.text.trim();
//
//                 if (mantra.isEmpty) {
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     SnackBar(
//                       content: Text('Please enter a mantra'),
//                       backgroundColor: Colors.red,
//                     ),
//                   );
//                   return;
//                 }
//
//                 Navigator.pop(context);
//                 await _addCustomMantraToApi(mantra, mantraName: mantraName);
//               },
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.orange,
//                 foregroundColor: Colors.white,
//               ),
//               child: Text('Add Mantra'),
//             ),
//           ],
//         );
//       },
//     );
//   }
//
//   // 5. Keep all your sankalp-related methods as they are
//   void _showSankalpConfirmationDialog(String mantra, String mantraId, String mantraName) {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: Row(
//             children: [
//               Icon(Icons.psychology, color: Colors.orange.shade700),
//               SizedBox(width: 8),
//               Text('Take Sankalp?', style: TextStyle(color: Colors.orange.shade700)),
//             ],
//           ),
//           content: Column(
//             mainAxisSize: MainAxisSize.min,
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text('Would you like to take sankalp for this mantra?'),
//               SizedBox(height: 12),
//               Container(
//                 padding: EdgeInsets.all(10),
//                 decoration: BoxDecoration(
//                   color: Colors.orange.shade50,
//                   borderRadius: BorderRadius.circular(8),
//                   border: Border.all(color: Colors.orange.shade200),
//                 ),
//                 child: Text(
//                   mantra.length > 100 ? '${mantra.substring(0, 100)}...' : mantra,
//                   style: TextStyle(fontStyle: FontStyle.italic),
//                   maxLines: 3,
//                   overflow: TextOverflow.ellipsis,
//                 ),
//               ),
//               SizedBox(height: 8),
//               Text(
//                 'A sankalp is a spiritual commitment to chant this mantra regularly.',
//                 style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
//               ),
//             ],
//           ),
//           actions: [
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 TextButton(
//                   onPressed: () {
//                     // When user presses "Just Chant" - show mantra in mantra chune box
//                     setState(() {
//                       _selectedItem = mantra;
//                     });
//                     Navigator.of(context).pop();
//                   },
//                   child: const Text(
//                     'Just Chant',
//                     style: TextStyle(color: Colors.grey),
//                   ),
//                 ),
//                 ElevatedButton(
//                   onPressed: () {
//                     Navigator.of(context).pop();
//                     _showSankalpDialog(mantra, mantraId);
//                   },
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.orange,
//                   ),
//                   child: const Text(
//                     'Take Sankalp',
//                     style: TextStyle(color: Colors.white),
//                   ),
//                 ),
//               ],
//             )
//           ],
//         );
//       },
//     );
//   }
//
//   void _showSankalpDialog(String mantra, String mantraId) {
//     // Reset sankalp values
//     _selectedStartTime = TimeOfDay.now();
//     _selectedEndTime = TimeOfDay(
//       hour: TimeOfDay.now().hour + 1,
//       minute: TimeOfDay.now().minute,
//     );
//     _selectedCount = 108;
//     _sankalpStartDate = DateTime.now();
//     _sankalpEndDate = DateTime.now().add(Duration(days: 7));
//     _isTakingSankalp = false;
//
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       backgroundColor: Colors.transparent,
//       constraints: BoxConstraints(
//         maxHeight: MediaQuery.of(context).size.height * 0.70, // 85% of screen height
//         minHeight: MediaQuery.of(context).size.height * 0.5, // Minimum 50% height
//       ),
//       builder: (BuildContext context) {
//         return StatefulBuilder(
//           builder: (context, setState) {
//             return Container(
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.only(
//                   topLeft: Radius.circular(20),
//                   topRight: Radius.circular(20),
//                 ),
//               ),
//               child: SafeArea(
//                 top: false, // Top SafeArea disable karein
//                 child: Column(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     // Header with draggable indicator
//                     Container(
//                       child: Column(
//                         children: [
//                           // Draggable indicator
//                           Container(
//                             width: 40,
//                             height: 4,
//                             margin: EdgeInsets.symmetric(vertical: 8),
//                             decoration: BoxDecoration(
//                               color: Colors.grey.shade300,
//                               borderRadius: BorderRadius.circular(2),
//                             ),
//                           ),
//                           // Title
//                           Container(
//                             padding: EdgeInsets.only(bottom: 16, left: 20, right: 20),
//                             decoration: BoxDecoration(
//                               border: Border(
//                                 bottom: BorderSide(color: Colors.grey.shade200),
//                               ),
//                             ),
//                             child: Row(
//                               children: [
//                                 Icon(Icons.psychology, color: Colors.orange.shade700),
//                                 SizedBox(width: 12),
//                                 Text(
//                                   'Take Sankalp',
//                                   style: TextStyle(
//                                     fontSize: 18,
//                                     fontWeight: FontWeight.w600,
//                                     color: Colors.orange.shade700,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//
//                     // Scrollable content - Height fixed karein
//                     Expanded(
//                       child: SingleChildScrollView(
//                         physics: ClampingScrollPhysics(),
//                         padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
//                         child: Column(
//                           mainAxisSize: MainAxisSize.min,
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             // Selected Mantra
//                             Container(
//                               width: double.infinity,
//                               padding: EdgeInsets.all(12),
//                               decoration: BoxDecoration(
//                                 color: Colors.orange.shade50,
//                                 borderRadius: BorderRadius.circular(10),
//                                 border: Border.all(color: Colors.orange.shade200),
//                               ),
//                               child: Row(
//                                 children: [
//                                   Icon(Icons.psychology, color: Colors.orange.shade700, size: 20),
//                                   SizedBox(width: 8),
//                                   Expanded(
//                                     child: Text(
//                                       mantra.length > 80 ? '${mantra.substring(0, 80)}...' : mantra,
//                                       style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
//                                       maxLines: 2,
//                                       overflow: TextOverflow.ellipsis,
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                             SizedBox(height: 16),
//
//                             // Time Period
//                             Text(
//                               'Time Period',
//                               style: TextStyle(
//                                 fontSize: 15,
//                                 fontWeight: FontWeight.w600,
//                                 color: Colors.grey.shade800,
//                               ),
//                             ),
//                             SizedBox(height: 8),
//                             Row(
//                               children: [
//                                 Expanded(
//                                   child: GestureDetector(
//                                     onTap: () async {
//                                       final TimeOfDay? picked = await showTimePicker(
//                                         context: context,
//                                         initialTime: _selectedStartTime ?? TimeOfDay.now(),
//                                         builder: (BuildContext context, Widget? child) {
//                                           return Theme(
//                                             data: ThemeData.light().copyWith(
//                                               colorScheme: ColorScheme.light(
//                                                 primary: Colors.orange.shade700,
//                                                 onPrimary: Colors.white,
//                                               ),
//                                               buttonTheme: ButtonThemeData(
//                                                 textTheme: ButtonTextTheme.primary,
//                                               ),
//                                             ),
//                                             child: child!,
//                                           );
//                                         },
//                                       );
//                                       if (picked != null) {
//                                         setState(() => _selectedStartTime = picked);
//                                       }
//                                     },
//                                     child: Container(
//                                       padding: EdgeInsets.symmetric(vertical: 10, horizontal: 14),
//                                       decoration: BoxDecoration(
//                                         border: Border.all(color: Colors.grey.shade300),
//                                         borderRadius: BorderRadius.circular(8),
//                                       ),
//                                       child: Column(
//                                         crossAxisAlignment: CrossAxisAlignment.start,
//                                         children: [
//                                           Text(
//                                             'Start',
//                                             style: TextStyle(
//                                               fontSize: 11,
//                                               color: Colors.grey.shade600,
//                                             ),
//                                           ),
//                                           SizedBox(height: 4),
//                                           Text(
//                                             _selectedStartTime?.format(context) ?? 'Select Time',
//                                             style: TextStyle(
//                                               fontSize: 14,
//                                               fontWeight: FontWeight.w600,
//                                               color: Colors.grey.shade800,
//                                             ),
//                                           ),
//                                         ],
//                                       ),
//                                     ),
//                                   ),
//                                 ),
//                                 SizedBox(width: 10),
//                                 Expanded(
//                                   child: GestureDetector(
//                                     onTap: () async {
//                                       final TimeOfDay? picked = await showTimePicker(
//                                         context: context,
//                                         initialTime: _selectedEndTime ?? TimeOfDay.now(),
//                                         builder: (BuildContext context, Widget? child) {
//                                           return Theme(
//                                             data: ThemeData.light().copyWith(
//                                               colorScheme: ColorScheme.light(
//                                                 primary: Colors.orange.shade700,
//                                                 onPrimary: Colors.white,
//                                               ),
//                                               buttonTheme: ButtonThemeData(
//                                                 textTheme: ButtonTextTheme.primary,
//                                               ),
//                                             ),
//                                             child: child!,
//                                           );
//                                         },
//                                       );
//                                       if (picked != null) {
//                                         setState(() => _selectedEndTime = picked);
//                                       }
//                                     },
//                                     child: Container(
//                                       padding: EdgeInsets.symmetric(vertical: 10, horizontal: 14),
//                                       decoration: BoxDecoration(
//                                         border: Border.all(color: Colors.grey.shade300),
//                                         borderRadius: BorderRadius.circular(8),
//                                       ),
//                                       child: Column(
//                                         crossAxisAlignment: CrossAxisAlignment.start,
//                                         children: [
//                                           Text(
//                                             'End',
//                                             style: TextStyle(
//                                               fontSize: 11,
//                                               color: Colors.grey.shade600,
//                                             ),
//                                           ),
//                                           SizedBox(height: 4),
//                                           Text(
//                                             _selectedEndTime?.format(context) ?? 'Select Time',
//                                             style: TextStyle(
//                                               fontSize: 14,
//                                               fontWeight: FontWeight.w600,
//                                               color: Colors.grey.shade800,
//                                             ),
//                                           ),
//                                         ],
//                                       ),
//                                     ),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                             SizedBox(height: 16),
//
//                             // Count Selection
//                             Text(
//                               'Count',
//                               style: TextStyle(
//                                 fontSize: 15,
//                                 fontWeight: FontWeight.w600,
//                                 color: Colors.grey.shade800,
//                               ),
//                             ),
//                             SizedBox(height: 8),
//                             Container(
//                               padding: EdgeInsets.symmetric(horizontal: 14, vertical: 6),
//                               decoration: BoxDecoration(
//                                 border: Border.all(color: Colors.grey.shade300),
//                                 borderRadius: BorderRadius.circular(8),
//                               ),
//                               child: DropdownButton<int>(
//                                 value: _selectedCount,
//                                 isExpanded: true,
//                                 underline: SizedBox(),
//                                 icon: Icon(Icons.arrow_drop_down, color: Colors.orange.shade700),
//                                 items: [11, 21, 51, 108, 1008].map((int value) {
//                                   return DropdownMenuItem<int>(
//                                     value: value,
//                                     child: Text('$value times', style: TextStyle(fontSize: 14)),
//                                   );
//                                 }).toList(),
//                                 onChanged: (value) {
//                                   setState(() => _selectedCount = value!);
//                                 },
//                               ),
//                             ),
//                             SizedBox(height: 16),
//
//                             // Date Period
//                             Text(
//                               'Date Period',
//                               style: TextStyle(
//                                 fontSize: 15,
//                                 fontWeight: FontWeight.w600,
//                                 color: Colors.grey.shade800,
//                               ),
//                             ),
//                             SizedBox(height: 8),
//                             Row(
//                               children: [
//                                 Expanded(
//                                   child: GestureDetector(
//                                     onTap: () async {
//                                       final DateTime? picked = await showDatePicker(
//                                         context: context,
//                                         initialDate: _sankalpStartDate!,
//                                         firstDate: DateTime.now(),
//                                         lastDate: DateTime.now().add(Duration(days: 365)),
//                                         builder: (BuildContext context, Widget? child) {
//                                           return Theme(
//                                             data: ThemeData.light().copyWith(
//                                               colorScheme: ColorScheme.light(
//                                                 primary: Colors.orange.shade700,
//                                                 onPrimary: Colors.white,
//                                               ),
//                                               buttonTheme: ButtonThemeData(
//                                                 textTheme: ButtonTextTheme.primary,
//                                               ),
//                                             ),
//                                             child: child!,
//                                           );
//                                         },
//                                       );
//                                       if (picked != null) {
//                                         setState(() => _sankalpStartDate = picked);
//                                       }
//                                     },
//                                     child: Container(
//                                       padding: EdgeInsets.symmetric(vertical: 10, horizontal: 14),
//                                       decoration: BoxDecoration(
//                                         border: Border.all(color: Colors.grey.shade300),
//                                         borderRadius: BorderRadius.circular(8),
//                                       ),
//                                       child: Column(
//                                         crossAxisAlignment: CrossAxisAlignment.start,
//                                         children: [
//                                           Text(
//                                             'Start Date',
//                                             style: TextStyle(
//                                               fontSize: 11,
//                                               color: Colors.grey.shade600,
//                                             ),
//                                           ),
//                                           SizedBox(height: 4),
//                                           Text(
//                                             DateFormat('dd MMM yyyy').format(_sankalpStartDate!),
//                                             style: TextStyle(
//                                               fontSize: 14,
//                                               fontWeight: FontWeight.w600,
//                                               color: Colors.grey.shade800,
//                                             ),
//                                           ),
//                                         ],
//                                       ),
//                                     ),
//                                   ),
//                                 ),
//                                 SizedBox(width: 10),
//                                 Expanded(
//                                   child: GestureDetector(
//                                     onTap: () async {
//                                       final DateTime? picked = await showDatePicker(
//                                         context: context,
//                                         initialDate: _sankalpEndDate!,
//                                         firstDate: _sankalpStartDate!,
//                                         lastDate: DateTime.now().add(Duration(days: 365)),
//                                         builder: (BuildContext context, Widget? child) {
//                                           return Theme(
//                                             data: ThemeData.light().copyWith(
//                                               colorScheme: ColorScheme.light(
//                                                 primary: Colors.orange.shade700,
//                                                 onPrimary: Colors.white,
//                                               ),
//                                               buttonTheme: ButtonThemeData(
//                                                 textTheme: ButtonTextTheme.primary,
//                                               ),
//                                             ),
//                                             child: child!,
//                                           );
//                                         },
//                                       );
//                                       if (picked != null) {
//                                         setState(() => _sankalpEndDate = picked);
//                                       }
//                                     },
//                                     child: Container(
//                                       padding: EdgeInsets.symmetric(vertical: 10, horizontal: 14),
//                                       decoration: BoxDecoration(
//                                         border: Border.all(color: Colors.grey.shade300),
//                                         borderRadius: BorderRadius.circular(8),
//                                       ),
//                                       child: Column(
//                                         crossAxisAlignment: CrossAxisAlignment.start,
//                                         children: [
//                                           Text(
//                                             'End Date',
//                                             style: TextStyle(
//                                               fontSize: 11,
//                                               color: Colors.grey.shade600,
//                                             ),
//                                           ),
//                                           SizedBox(height: 4),
//                                           Text(
//                                             DateFormat('dd MMM yyyy').format(_sankalpEndDate!),
//                                             style: TextStyle(
//                                               fontSize: 14,
//                                               fontWeight: FontWeight.w600,
//                                               color: Colors.grey.shade800,
//                                             ),
//                                           ),
//                                         ],
//                                       ),
//                                     ),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                             SizedBox(height: 20),
//
//                             // Loading or Buttons
//                             if (_isTakingSankalp)
//                               Container(
//                                 padding: EdgeInsets.symmetric(vertical: 16),
//                                 child: Center(
//                                   child: CircularProgressIndicator(
//                                     valueColor: AlwaysStoppedAnimation<Color>(Colors.orange.shade700),
//                                   ),
//                                 ),
//                               )
//                             else
//                               Padding(
//                                 padding: EdgeInsets.only(bottom: 16),
//                                 child: Row(
//                                   children: [
//                                     Expanded(
//                                       child: TextButton(
//                                         onPressed: () {
//                                           setState(() {
//                                             _selectedItem = mantra;
//                                           });
//                                           Navigator.of(context).pop();
//                                         },
//                                         style: TextButton.styleFrom(
//                                           padding: EdgeInsets.symmetric(vertical: 12),
//                                           shape: RoundedRectangleBorder(
//                                             borderRadius: BorderRadius.circular(8),
//                                             side: BorderSide(color: Colors.grey.shade300),
//                                           ),
//                                         ),
//                                         child: Text(
//                                           'Cancel',
//                                           style: TextStyle(
//                                             color: Colors.grey.shade700,
//                                             fontSize: 15,
//                                           ),
//                                         ),
//                                       ),
//                                     ),
//                                     SizedBox(width: 10),
//                                     Expanded(
//                                       child: ElevatedButton(
//                                         onPressed: () {
//                                           setState(() {
//                                             _isTakingSankalp = true;
//                                           });
//                                           _takeSankalp(mantra, mantraId);
//                                         },
//                                         style: ElevatedButton.styleFrom(
//                                           backgroundColor: Colors.orange.shade700,
//                                           padding: EdgeInsets.symmetric(vertical: 12),
//                                           shape: RoundedRectangleBorder(
//                                             borderRadius: BorderRadius.circular(8),
//                                           ),
//                                         ),
//                                         child: Text(
//                                           'Take Sankalp',
//                                           style: TextStyle(
//                                             color: Colors.white,
//                                             fontSize: 15,
//                                           ),
//                                         ),
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             );
//           },
//         );
//       },
//     );
//   }
//
//   void _showColorPickerDialog(BuildContext context) {
//     // 2026 Professional Calm Palette
//     final List<Color> availableColors = [
//       const Color(0xFFE67E22), // Deep Orange
//       const Color(0xFF607D8B), // Slate Grey
//       const Color(0xFF8E9775), // Sage Green
//       const Color(0xFF6A11CB), // Calm Purple
//       const Color(0xFFD35400), // Burnt Sienna
//       const Color(0xFF2C3E50), // Midnight Blue
//     ];
//
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Choose Mantra Color', style: TextStyle(fontSize: 16)),
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
//         content: Wrap(
//           spacing: 15,
//           runSpacing: 15,
//           children: availableColors.map((color) {
//             return GestureDetector(
//               onTap: () {
//                 setState(() => _mantraColor = color);
//                 Navigator.pop(context);
//               },
//               child: Container(
//                 width: 45,
//                 height: 45,
//                 decoration: BoxDecoration(
//                   color: color,
//                   shape: BoxShape.circle,
//                   border: Border.all(
//                     color: _mantraColor == color ? Colors.black : Colors.transparent,
//                     width: 2,
//                   ),
//                 ),
//                 child: _mantraColor == color
//                     ? const Icon(Icons.check, color: Colors.white, size: 20)
//                     : null,
//               ),
//             );
//           }).toList(),
//         ),
//       ),
//     );
//   }
//
// }
//
// // Add this extension at the top of your file (outside the class)
// extension TimeOfDayExtension on TimeOfDay {
//   String format(BuildContext context) {
//     final localizations = MaterialLocalizations.of(context);
//     final now = DateTime.now();
//     final dt = DateTime(now.year, now.month, now.day, hour, minute);
//     return localizations.formatTimeOfDay(this, alwaysUse24HourFormat: false);
//   }
// }
//
// class AddMantraModel {
//   bool status;
//   String message;
//   Data data;
//
//   AddMantraModel({
//     required this.status,
//     required this.message,
//     required this.data,
//   });
//
//   factory AddMantraModel.fromJson(Map<String, dynamic> json) => AddMantraModel(
//     status: json["status"],
//     message: json["message"],
//     data: Data.fromJson(json["data"]),
//   );
//
//   Map<String, dynamic> toJson() => {
//     "status": status,
//     "message": message,
//     "data": data.toJson(),
//   };
// }
//
// class Data {
//   int userId;
//   String name; // This is the mantra name field
//   String mantra;
//   DateTime updatedAt;
//   DateTime createdAt;
//   int id;
//   List<dynamic> translations;
//
//   Data({
//     required this.userId,
//     required this.name,
//     required this.mantra,
//     required this.updatedAt,
//     required this.createdAt,
//     required this.id,
//     required this.translations,
//   });
//
//   factory Data.fromJson(Map<String, dynamic> json) => Data(
//     userId: json["user_id"],
//     name: json["name"] ?? "", // Handle null case
//     mantra: json["mantra"],
//     updatedAt: DateTime.parse(json["updated_at"]),
//     createdAt: DateTime.parse(json["created_at"]),
//     id: json["id"],
//     translations: List<dynamic>.from(json["translations"].map((x) => x)),
//   );
//
//   Map<String, dynamic> toJson() => {
//     "user_id": userId,
//     "name": name,
//     "mantra": mantra,
//     "updated_at": updatedAt.toIso8601String(),
//     "created_at": createdAt.toIso8601String(),
//     "id": id,
//     "translations": List<dynamic>.from(translations.map((x) => x)),
//   };
// }
//
// JaapMantraModel jaapMantraModelFromJson(String str) => JaapMantraModel.fromJson(json.decode(str));
//
// String jaapMantraModelToJson(JaapMantraModel data) => json.encode(data.toJson());
//
// class JaapMantraModel {
//   bool status;
//   List<JaapList> data;
//
//   JaapMantraModel({
//     required this.status,
//     required this.data,
//   });
//
//   factory JaapMantraModel.fromJson(Map<String, dynamic> json) => JaapMantraModel(
//     status: json["status"],
//     data: List<JaapList>.from(json["data"].map((x) => JaapList.fromJson(x))),
//   );
//
//   Map<String, dynamic> toJson() => {
//     "status": status,
//     "data": List<dynamic>.from(data.map((x) => x.toJson())),
//   };
// }
//
// class JaapList {
//   int id;
//   String jaap; // English name from API
//   dynamic hiName;
//   String mantra; // English mantra from API
//   dynamic hiMantra;
//   String image;
//   String type;
//
//   JaapList({
//     required this.id,
//     required this.jaap,
//     required this.hiName,
//     required this.mantra,
//     required this.hiMantra,
//     required this.image,
//     required this.type,
//   });
//
//   factory JaapList.fromJson(Map<String, dynamic> json) => JaapList(
//     id: json["id"],
//     jaap: json["jaap"] ?? "", // Handle null case
//     hiName: json["hi_name"],
//     mantra: json["mantra"] ?? "", // Handle null case
//     hiMantra: json["hi_mantra"],
//     image: json["image"] ?? "",
//     type: json["type"] ?? "",
//   );
//
//   Map<String, dynamic> toJson() => {
//     "id": id,
//     "jaap": jaap,
//     "hi_name": hiName,
//     "mantra": mantra,
//     "hi_mantra": hiMantra,
//     "image": image,
//     "type": type,
//   };
// }
//
// class FavoriteMantrasPage extends StatefulWidget {
//   @override
//   _FavoriteMantrasPageState createState() => _FavoriteMantrasPageState();
// }
//
// class _FavoriteMantrasPageState extends State<FavoriteMantrasPage> {
//   // Sample data - In a real app, this would come from a Provider or Bloc
//   List<Map<String, dynamic>> favoriteMantras = [
//     {
//       'id': 1,
//       'title': 'Gayatri Mantra',
//       'text': 'ॐ भूर्भुवः स्वः तत्सवितुर्वरेण्यं भर्गो देवस्य धीमहि धियो यो नः प्रचोदयात्',
//       'meaning': 'The mantra for enlightenment and wisdom',
//       'category': 'Vedic',
//       'accentColor': Colors.orangeAccent,
//     },
//     {
//       'id': 2,
//       'title': 'Mahamrityunjaya',
//       'text': 'ॐ त्र्यम्बकं यजामहे सुगन्धिं पुष्टिवर्धनम् उर्वारुकमिव बन्धनान् मृत्योर्मुक्षीय मामृतात्',
//       'meaning': 'The great death-conquering mantra for healing',
//       'category': 'Healing',
//       'accentColor': Colors.tealAccent,
//     },
//     {
//       'id': 3,
//       'title': 'Om Namah Shivaya',
//       'text': 'ॐ नमः शिवाय',
//       'meaning': 'I bow to Lord Shiva, the auspicious one',
//       'category': 'Divine',
//       'accentColor': Colors.blueAccent,
//     },
//   ];
//
//   void _removeItem(int index) {
//     setState(() {
//       favoriteMantras.removeAt(index);
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFF0F2F5), // Soft grey-blue background
//       body: CustomScrollView(
//         physics: const BouncingScrollPhysics(),
//         slivers: [
//           // --- Minimalist Glassmorphic AppBar ---
//           SliverAppBar(
//             expandedHeight: 180.0,
//             pinned: true,
//             stretch: true,
//             backgroundColor: Colors.white.withOpacity(0.8),
//             flexibleSpace: FlexibleSpaceBar(
//               stretchModes: const [StretchMode.blurBackground, StretchMode.zoomBackground],
//               centerTitle: true,
//               title: const Text(
//                 'Collection',
//                 style: TextStyle(
//                   color: Color(0xFF2D3436),
//                   fontWeight: FontWeight.w800,
//                   letterSpacing: 1.2,
//                 ),
//               ),
//               background: Stack(
//                 fit: StackFit.expand,
//                 children: [
//                   // Decorative Circle Background
//                   Positioned(
//                     top: -50,
//                     right: -50,
//                     child: CircleAvatar(radius: 100, backgroundColor: Colors.orange.withOpacity(0.1)),
//                   ),
//                   const Center(
//                     child: Icon(Icons.auto_awesome, size: 80, color: Colors.orangeAccent),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//
//           // --- Stats Section ---
//           SliverToBoxAdapter(
//             child: Padding(
//               padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
//               child: Text(
//                 '${favoriteMantras.length} MANTRAS SAVED',
//                 style: TextStyle(
//                   fontSize: 12,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.grey.shade600,
//                   letterSpacing: 2.0,
//                 ),
//               ),
//             ),
//           ),
//
//           // --- The List ---
//           favoriteMantras.isEmpty
//               ? _buildEmptyState()
//               : SliverList(
//             delegate: SliverChildBuilderDelegate(
//                   (context, index) {
//                 final mantra = favoriteMantras[index];
//                 return _buildMantraTile(mantra, index);
//               },
//               childCount: favoriteMantras.length,
//             ),
//           ),
//
//           // Padding at bottom for FAB
//           const SliverToBoxAdapter(child: SizedBox(height: 100)),
//         ],
//       ),
// // floatingActionButton: FloatingActionButton.extended(
// //   onPressed: () {},
// //   label: const Text('Practice All'),
// //   icon: const Icon(Icons.play_circle_fill),
// //   backgroundColor: const Color(0xFF2D3436),
//       // ),
//     );
//   }
//
//   Widget _buildMantraTile(Map<String, dynamic> mantra, int index) {
//     return Dismissible(
//       key: Key(mantra['id'].toString()),
//       direction: DismissDirection.endToStart,
//       onDismissed: (direction) => _removeItem(index),
//       background: Container(
//         alignment: Alignment.centerRight,
//         padding: const EdgeInsets.only(right: 20),
//         color: Colors.redAccent,
//         child: const Icon(Icons.delete_outline, color: Colors.white),
//       ),
//       child: Container(
//         margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(24),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.deepOrangeAccent.withOpacity(0.04),
//               blurRadius: 20,
//               offset: const Offset(0, 10),
//             ),
//           ],
//         ),
//         child: ClipRRect(
//           borderRadius: BorderRadius.circular(24),
//           child: IntrinsicHeight(
//             child: Row(
//               children: [
//                 // Color Accent Sidebar
//                 Container(
//                   width: 6,
//                   color: mantra['accentColor'],
//                 ),
//                 Expanded(
//                   child: Padding(
//                     padding: const EdgeInsets.all(20.0),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             Text(
//                               mantra['category'].toUpperCase(),
//                               style: TextStyle(
//                                 fontSize: 10,
//                                 fontWeight: FontWeight.bold,
//                                 color: mantra['accentColor'],
//                                 letterSpacing: 1.5,
//                               ),
//                             ),
//                             const Icon(Icons.more_horiz, color: Colors.grey),
//                           ],
//                         ),
//                         const SizedBox(height: 8),
//                         Text(
//                           mantra['title'],
//                           style: const TextStyle(
//                             fontSize: 18,
//                             fontWeight: FontWeight.bold,
//                             color: Color(0xFF2D3436),
//                           ),
//                         ),
//                         const SizedBox(height: 12),
//                         Text(
//                           mantra['text'],
//                           style: const TextStyle(
//                             fontSize: 16,
//                             color: Colors.black87,
//                             height: 1.5,
//                           ),
//                         ),
//                         const SizedBox(height: 12),
//                         Text(
//                           mantra['meaning'],
//                           style: TextStyle(
//                             fontSize: 13,
//                             color: Colors.grey.shade600,
//                             fontStyle: FontStyle.italic,
//                           ),
//                         ),
//                         const SizedBox(height: 20),
//                         Row(
//                           children: [
//                             _actionButton(Icons.volume_up_rounded, "Listen"),
//                             const SizedBox(width: 12),
//                             _actionButton(Icons.copy_rounded, "Copy"),
//                           ],
//                         )
//                       ],
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _actionButton(IconData icon, String label) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//       decoration: BoxDecoration(
//         color: const Color(0xFFF0F2F5),
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: Row(
//         children: [
//           Icon(icon, size: 16, color: Colors.blueGrey),
//           const SizedBox(width: 6),
//           Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildEmptyState() {
//     return SliverFillRemaining(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Icon(Icons.spa_outlined, size: 100, color: Colors.grey.shade300),
//           const SizedBox(height: 20),
//           const Text(
//             'Peace is a journey.',
//             style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//           ),
//           const SizedBox(height: 8),
//           Text(
//             'Start adding mantras to your collection.',
//             style: TextStyle(color: Colors.grey.shade500),
//           ),
//         ],
//       ),
//     );
//   }
// }


import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mahakal/features/Jaap/screen/history.dart';
import 'package:geocoding/geocoding.dart';
// import 'package:flutter_vibrate/flutter_vibrate.dart';
// import 'package:just_audio/just_audio.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:signature/signature.dart';
import 'package:tdk_bouncingwidget/tdk_bouncingwidget.dart';

import '../../../main.dart';
import '../../../utill/app_constants.dart';
import '../../auth/controllers/auth_controller.dart';
import '../jap_database.dart';
import '../wallpaper/wallpaper.dart';
import '../wallpaper/wallpaper.dart';

class JaapView extends StatefulWidget {
  int initialIndex;
  JaapView({super.key, this.initialIndex = 0});

  @override
  State<JaapView> createState() => _JaapViewState();
}

class Person {
  String id;
  String name;
  Person({required this.id, required this.name});
}

class _JaapViewState extends State<JaapView> with TickerProviderStateMixin {
  //----------------------JAAP TAB STARTS----------------------------

  final Iterable<Duration> pauses = [
    const Duration(milliseconds: 500),
    const Duration(milliseconds: 1000),
    const Duration(milliseconds: 500),
  ];

  // our jaap app tab controller
  late TabController _tabController;
  int tabIndex = 0;

  List<dynamic> myList = [];

  // jaap app background image
  final String _selectedImage = 'assets/images/jaap/ram_3.png';

  bool _vibrationEnabled = true; // Default vibration state is on

  // setting bottom sheet 3 circle in row
  int itemColorIndex = 0;
  void _showsettingsheet() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SizedBox(
          height: 185,
          child: ListView(
            children: [
              ListTile(
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Switch(
                      value: _vibrationEnabled,
                      onChanged: (value) {
                        setState(() {
                          Navigator.pop(context);
                          _vibrationEnabled = value;
                        });
                      },
                      activeColor: Colors.orangeAccent,
                      inactiveTrackColor: Colors.white30,
                    ),
                    const SizedBox(width: 7),
                    Text(
                      _vibrationEnabled ? 'Vibration On' : 'Vibration Off',
                      style: const TextStyle(
                          color: Colors.orange, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              // ListTile(
              //   title: Row(
              //     mainAxisAlignment: MainAxisAlignment.start,
              //     children: [
              //       Switch(
              //         value: _vibrationEnabled,
              //         onChanged: (value) {
              //           setState(() {
              //             Navigator.pop(context);
              //             _vibrationEnabled = value;
              //           });
              //         },
              //       ),
              //       SizedBox(width: 7),
              //       Text(_vibrationEnabled ? 'Sound On' : 'Sound Off',style: TextStyle(color: Colors.deepPurple),),
              //     ],
              //   ),
              // ),
              ListTile(
                title: Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Row(
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.orange, width: 1.5),
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(300),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.edit,
                            size: 30,
                          ),
                        ),
                      ),
                      const SizedBox(width: 15),
                      const Text(
                        "Background",
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(width: 20),
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.orange, width: 1.5),
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(300),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.history,
                            size: 30,
                          ),
                        ),
                      ),
                      const SizedBox(width: 15),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _tabController.animateTo(2);
                          });
                          Navigator.pop(context);
                        },
                        child: const Text(
                          "History",
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w500,
                              color: Colors.black),
                        ),
                      ),
                    ],
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              Padding(
                padding: const EdgeInsets.only(
                  left: 20,
                ),
                child: Row(
                  children: [
                    InkWell(
                      onTap: () {
                        setState(() {
                          itemColorIndex = 0;
                          Navigator.pop(context);
                        });
                      },
                      child: ClipOval(
                        child: Image.asset(
                          'assets/images/jaap/ram_3.png',
                          width: 45, // Set the desired width
                          height: 45, // Set the desired height
                          fit: BoxFit
                              .cover, // Ensures the image fits within the circle
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    InkWell(
                      onTap: () {
                        setState(() {
                          itemColorIndex = 1;
                          Navigator.pop(context);
                        });
                      },
                      child: ClipOval(
                        child: Image.asset(
                          'assets/images/jaap/ram_4.png',
                          width: 45, // Set the desired width
                          height: 45, // Set the desired height
                          fit: BoxFit
                              .cover, // Ensures the image fits within the circle
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    InkWell(
                      onTap: () {
                        setState(() {
                          itemColorIndex = 2;
                          Navigator.pop(context);
                        });
                      },
                      child: ClipOval(
                        child: Image.asset(
                          'assets/images/jaap/ram_5.png',
                          width: 45, // Set the desired width
                          height: 45, // Set the desired height
                          fit: BoxFit
                              .cover, // Ensures the image fits within the circle
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // SizedBox(height: 10),
              // ListTile(
              //   title: Row(
              //     children: [
              //       Container(
              //         child: Center(
              //           child: Icon(
              //             Icons.history,
              //             size: 30,
              //           ),
              //         ),
              //         width: 50,
              //         height: 50,
              //         decoration: BoxDecoration(
              //           border: Border.all(color: Colors.orange, width: 1.5),
              //           color: Colors.white.withOpacity(0.2),
              //           borderRadius: BorderRadius.circular(300),
              //         ),
              //       ),
              //       SizedBox(width: 15),
              //       Text(
              //         "History",
              //         style:
              //             TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
              //       ),
              //     ],
              //   ),
              //   onTap: () {
              //     setState(() {
              //       _tabController.animateTo(2);
              //     });
              //     Navigator.pop(context);
              //   },
              // ),
            ],
          ),
        );
      },
    );
  }

  // jaap page mantra list
  String _selectedItem = '';
  List<Person> people = [
    Person(id: 'राम! राम! राम! राम', name: 'Ram Naam Jaap(राम नाम जाप)'),
    Person(id: 'ॐ नमः शिवाय', name: 'Shiv Jaap(शिव जाप)'),
    Person(
        id: 'हरे कृष्ण हरे कृष्ण, कृष्ण कृष्ण हरे हरे। हरे राम हरे रामा, राम रामा हरे हरे॥',
        name: 'Krishna Jaap(कृष्ण जाप)'),
    Person(id: '!!ॐ गं गणपतये नमः!!', name: 'Ganesh Jaap(गणेश जाप)'),
    Person(
        id: 'ॐ भूर्भुवः स्वः तत्सवितुर्वरेण्यं भर्गो दैवस्य धीमहि। धियो यो नः प्रचोदयात्॥',
        name: 'Gayatri Mantra Jaap(गायत्री मंत्र जाप)'),
    Person(
        id: '!!ओम नमः भगवते वासुदेवाय नमः!!',
        name: 'Vishnu Mantra Jaap(विष्णु मंत्र जाप)'),
    Person(id: '!!श्री राम जय राम जय जय राम!!', name: 'Ram Jaap(राम जाप)'),
    Person(
        id: 'ॐ सर्वमङ्गलमाङ्गल्ये शिवे सर्वार्थसाधिके। शरण्ये त्र्यंबके गौरी नारायणि नमोऽस्तुते॥',
        name: 'Durga Jaap(दुर्गा जाप)'),
    Person(id: 'ॐ नमो नारायणाय!!', name: 'Vishnu Jaap(विष्णु जाप)'),
    Person(
        id: 'ॐ श्रीं महा लक्ष्मीयै नमः!!',
        name: 'Laxmi Mantra Jaap(लक्ष्मी मंत्र जाप)'),
    Person(
        id: 'ॐ हौं जूं सः ॐ भूर्भुवः स्वः ॐ त्र्यम्बकं यजामहे सुगन्धिं पुष्टिवर्धनम् उर्वारुकमिव बन्धनान्मृ त्योर्मुक्षीय मामृतात् ॐ स्वः भुवः भूः ॐ सः जूं हौं ॐ।',
        name: 'Mahamrityunjay Jaap(महामृत्युंजय जाप)'),
  ];
  double getFontSize(String name, num screenwidth) {
    double fontSizeRatio;

    switch (name) {
      case 'Ram Naam Jaap(राम नाम जाप)':
        fontSizeRatio = 0.10;
        break;
      case 'Shiv Jaap(शिव जाप)':
        fontSizeRatio = 0.12;
        break;
      case 'Krishna Jaap(कृष्ण जाप)':
        fontSizeRatio = 0.07;
        break;
      case 'Ganesh Jaap(गणेश जाप)':
        fontSizeRatio = 0.1;
        break;
      case 'Gayatri Mantra Jaap(गायत्री मंत्र जाप)':
        fontSizeRatio = 0.05;
        break;
      case 'Vishnu Mantra Jaap(विष्णु मंत्र जाप)':
        fontSizeRatio = 0.07;
        break;
      case 'Ram Jaap(राम जाप)':
        fontSizeRatio = 0.07;
        break;
      case 'Durga Jaap(दुर्गा जाप)':
        fontSizeRatio = 0.05;
        break;
      case 'Vishnu Jaap(विष्णु जाप)':
        fontSizeRatio = 0.09;
        break;
      case 'Laxmi Mantra Jaap(लक्ष्मी मंत्र जाप)':
        fontSizeRatio = 0.08;
        break;
      case 'Mahamrityunjay Jaap(महामृत्युंजय जाप)':
        fontSizeRatio = 0.05;
        break;
      default:
        fontSizeRatio = 0.10;
    }
    return fontSizeRatio * screenwidth;
  }

  // jaap count animation
  late AnimationController _animationController;
  late Animation<double> _animation;

  // jaap page loop count
  int _loopCounter = 0;
  // jaap page main big circle count
  int _tapCounter = 0;
  // jaap page score count
  int product = 0;
  // jaap page loop count from list 11,20,30
  int _tapsPerLoop = 11;

  void _onButtonTap() {
    setState(() {
      _tapCounter++;
      if (_tapCounter > _tapsPerLoop) {
        _loopCounter++;
        _tapCounter = 1;
      }
      product++;
    });
    _animationController.forward(from: 0.0);
    Future.delayed(const Duration(milliseconds: 200), () {
      _animationController.reverse();
    });
  }

  void _showBottomSheets() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SizedBox(
          height: 220,
          child: ListView(
            children: [
              ListTile(
                title: const Text('11', textAlign: TextAlign.center),
                onTap: () {
                  setState(() {
                    _tapsPerLoop = 11;
                  });
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text('21', textAlign: TextAlign.center),
                onTap: () {
                  setState(() {
                    _tapsPerLoop = 21;
                  });
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text('51', textAlign: TextAlign.center),
                onTap: () {
                  setState(() {
                    _tapsPerLoop = 51;
                  });
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text('101', textAlign: TextAlign.center),
                onTap: () {
                  setState(() {
                    _tapsPerLoop = 101;
                  });
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text('108', textAlign: TextAlign.center),
                onTap: () {
                  setState(() {
                    _tapsPerLoop = 108;
                  });
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text('1008', textAlign: TextAlign.center),
                onTap: () {
                  setState(() {
                    _tapsPerLoop = 1008;
                  });
                  Navigator.pop(context);
                },
              ),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  // jaap total count saved and pass to score page
  final List<int> _savedCounts = [];

  void _submitCount() {
    setState(() {
      _selectedItem;
      _savedCounts.add(product);
    });
  }

  int _counter = 0;
  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }
  //----------------------JAAP TAB ENDS----------------------------

  //----------------------RAM LEKHAN TAB STARTS----------------------------

  final ScrollController _scrollController = ScrollController();

  // ram lekhan signature pen decoration
  final controllers = SignatureController(
    penColor: Colors.orange,
    penStrokeWidth: 3,
    exportPenColor: Colors.orange,
    exportBackgroundColor: Colors.white,
  );

  // ram lekhan signature saved here
  List<Uint8List> signatures = [];

  // ram lekhan ram word saved here
  final List<Widget> _texts = [];
  void _addText() {
    setState(() {
      _texts.add(Container(
        decoration: BoxDecoration(
          border: Border(
            right: BorderSide(
              color: Colors.amber.shade200,
              width: 1.0,
            ),
            left: BorderSide(
              color: Colors.amber.shade200,
              width: 1.0,
            ),
            bottom: BorderSide(
              color: Colors.amber.shade200,
              width: 1.0,
            ),
          ),
        ),
        child: const Padding(
          padding: EdgeInsets.only(right: 11, left: 11, top: 15, bottom: 15),
          child: Text(
            'राम',
            style: TextStyle(fontSize: 23.7, color: Colors.orange, height: 1),
          ),
        ),
      ));
    });
  }

  // ram lekhan keyboard word saved here
  final List<String> _textstype = [];

  // // ram lekhan Variable to toggle keyboard visibility
  // bool _showKeyboard = true;
  // void _toggleKeyboard() {
  //   setState(() {
  //     _showKeyboard = !_showKeyboard; // Toggle the keyboard visibility
  //   });
  // }

  // ram lekhan Controller for the text field keyboard TextEditingController
  final TextEditingController _textController = TextEditingController();
  // String _inputText = ''; // Variable to store the text input
  // void _updateText(String text) {
  //   setState(() {
  //     _inputText = text; // Update the displayed text
  //     _textstype.add(_textController.text);
  //   });
  // }

  // ram lekhan Variable to toggle signature pad visibility
  bool _isSignatureVisible = false;

  // ram lekhan total count start
  int _buttonPressCount = 0;
  int _buttonPressCounts = 0;
  int _totalPressCount = 0;
  final int _currentIndex = 0;

  void _incrementButtonPressCount() {
    setState(() {
      _buttonPressCount++;
      _totalPressCount = _buttonPressCount + _buttonPressCounts;
    });
  }

  void _incrementButtonPressCounts() {
    setState(() {
      _buttonPressCounts++;
      _totalPressCount = _buttonPressCount + _buttonPressCounts;
    });
  }
  // ram lekhan total count End

  //----------------------RAM LEKHAN TAB STARTS----------------------------

  final List<dynamic> _pressCounts = [];

  String _currentTime = '';
  String userToken = '';
  String totalDuration = '';
  String totalDurationRam = '';
  Timer? _timer;
  DateTime? _startTime;
  Duration _elapsedTime = Duration.zero;
  double latiTude = 0.0;
  double longiTude = 0.0;
  String _venueAddressController = '';

  List<Map<String, dynamic>> savedData = [];

  void _startTimer() {
    // Check if the timer is already running
    if (_timer != null && _timer!.isActive) {
      return; // Do nothing if the timer is already running
    }

    // Set the start time and reset the elapsed time
    setState(() {
      _startTime = DateTime.now();
      _elapsedTime = Duration.zero;
    });

    // Start a new timer
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _elapsedTime = DateTime.now().difference(_startTime!);
      });
    });
  }

  // Stop timer and calculate total duration
  void _stopTimer() {
    if (_timer != null) {
      // _elapsedTime = _elapsedTime.toString();
      _timer!.cancel();
      setState(() {
        _timer = null;
        totalDuration = "${_elapsedTime.inSeconds}s";
        totalDurationRam = "${_elapsedTime.inSeconds}s";
        _elapsedTime = Duration.zero;
      });
      print("Total Duration: $_elapsedTime $totalDuration");
    }
  }

  void _incrementNumber() {
    setState(() {
      itemColorIndex =
          (itemColorIndex + 1) % 3; // Increment and reset to 0 after 3
    });
  }

  void _showCurrentTime() {
    final now = DateTime.now();
    String hour;
    if (now.hour > 12) {
      hour = (now.hour - 12).toString();
    } else if (now.hour == 0) {
      hour = '12';
    } else {
      hour = now.hour.toString();
    }
    // String ampm = now.hour > 11 ? 'PM' : 'AM'
    // $ampm
    final formattedTime =
        '$hour:${now.minute.toString().padLeft(2, '0')} , ${now.day} ${_getMonth(now.month)} ${now.year.toString().substring(2)} ';
    setState(() {
      _currentTime = formattedTime;
    });
  }

  String _getMonth(int month) {
    switch (month) {
      case 1:
        return 'Jan';
      case 2:
        return 'Feb';
      case 3:
        return 'Mar';
      case 4:
        return 'Apr';
      case 5:
        return 'May';
      case 6:
        return 'Jun';
      case 7:
        return 'Jul';
      case 8:
        return 'Aug';
      case 9:
        return 'Sep';
      case 10:
        return 'Oct';
      case 11:
        return 'Nov';
      case 12:
        return 'Dec';
      default:
        return '';
    }
  }

  String extractEnglishName(String input) {
    // Use regex to match the first part before the opening bracket.
    RegExp exp = RegExp(r'^[^(]+');
    Match? match = exp.firstMatch(input);

    if (match != null) {
      // Trim the result to remove any extra whitespace.
      return match.group(0)!.trim();
    } else {
      // Return the original input if no match is found (in case there is no bracket).
      return input;
    }
  }

  void getLocation(double lat, long) async {
    List<Placemark> placemarks = await placemarkFromCoordinates(
      lat,
      long!,
    );

    if (placemarks.isNotEmpty) {
      Placemark place = placemarks.first;
      // _pincodeController.text = place.postalCode!;
      // _stateController.text = place.administrativeArea!;
      // _landMarkController.text = place.street!;
      _venueAddressController = place.locality!;
      print("venue store $_venueAddressController ${place.locality}");
    }
  }

  Future<void> countSave(String totalCount) async {
    String name = extractEnglishName(_selectedItem);
    DateTime now = DateTime.now();
    String formattedTime = DateFormat('hh:mm:ss').format(now);
    String formattedDate = DateFormat('dd/MM/yyy').format(now);
    final response = await http.post(
      Uri.parse(AppConstants.baseUrl + AppConstants.saveJapCountUrl),
      headers: {
        'Authorization': 'Bearer $userToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        "type": "mantra",
        "name": name,
        "location": _venueAddressController,
        "count": totalCount,
        "duration": totalDuration,
        "date": formattedDate,
        "time": formattedTime
      }),
    );
    print("jaap post api: ${response.body}");
    var data = jsonDecode(response.body);
    if (data["status"] == 200) {
      _submitCount();
      setState(() {
        tabIndex = 0;
        _tapCounter = 0;
        _loopCounter = 0;
        product = 0;
        _tabController.animateTo(2);
        _tabController.index = 2;
      });
    } else {
      print("failed api status 400");
    }
  }

  Future<void> ramLekhanSave(String totalCountRam) async {
    DateTime now = DateTime.now();
    String formattedTime = DateFormat('hh:mm:ss').format(now);
    String formattedDate = DateFormat('dd/MM/yyy').format(now);
    final response = await http.post(
      Uri.parse(AppConstants.baseUrl + AppConstants.saveRamLekhanUrl),
      headers: {
        'Authorization': 'Bearer $userToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        "type": "ram_lekhan",
        "name": "ram",
        "location": _venueAddressController,
        "count": totalCountRam,
        "duration": totalDurationRam,
        "date": formattedDate,
        "time": formattedTime
      }),
    );
    print("ram lekhan post api: ${response.body}");
    var data = jsonDecode(response.body);
    if (data["status"] == 200) {
      setState(() {
        tabIndex = 1;
        _pressCounts.add(_totalPressCount);
        _totalPressCount = 0;
        _texts.clear();
        signatures.clear();
        _buttonPressCount = 0;
        _buttonPressCounts = 0;
        _totalPressCount = 0;
        _textController.clear();
        _textstype.clear();
        _tabController.animateTo(2);
        _tabController.index = 2;
      });
    } else {
      print("failed api status 400");
    }
  }

  @override
  void initState() {
    super.initState();
    _checkPreviousData();
    userToken =
        Provider.of<AuthController>(Get.context!, listen: false).getUserToken();
    latiTude =
        Provider.of<AuthController>(Get.context!, listen: false).latitude;
    longiTude =
        Provider.of<AuthController>(Get.context!, listen: false).longitude;
    _tabController = TabController(
        length: 3, vsync: this, initialIndex: widget.initialIndex);
    _isSignatureVisible = false; // Initialize with true
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _animation = Tween<double>(begin: 1, end: 1.2).animate(_animationController)
      ..addListener(() {
        setState(() {});
      })
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _animationController.reverse();
        }
      });
    getLocation(latiTude, longiTude);
  }

  Future<void> _checkPreviousData() async {
    savedData = await DBHelper.instance.getData();
    if (savedData.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showResumeDialog();
      });
    }
  }

  void _showResumeDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetAnimationDuration: const Duration(milliseconds: 300),
          insetAnimationCurve: Curves.easeOutQuart,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 20,
                  spreadRadius: 2,
                )
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.history_rounded,
                  size: 48,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: 16),
                Text(
                  "Resume or Restart?",
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  "You have saved data. Do you want to continue or reset?",
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.8),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () async {
                          await DBHelper.instance.updateData(
                            savedData[0]['id'],
                            savedData[0]['str1'],
                            savedData[0]['str2'],
                            savedData[0]['str3'],
                            savedData[0]['str4'],
                          );
                          Navigator.pop(context);
                          setState(() {
                            _selectedItem = savedData[0]['str1'];
                            _tapsPerLoop = int.parse(savedData[0]['str2']);
                            _loopCounter = int.parse(savedData[0]['str3']);
                            _tapCounter = int.parse(savedData[0]['str4']);
                          });
                        },
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          side: BorderSide(
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        child: Text(
                          "Continue",
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          await DBHelper.instance
                              .deleteData(savedData[0]['id']);
                          Navigator.pop(context);
                          setState(() {
                            savedData = [];
                            _selectedItem = '';
                            _tapsPerLoop = 11;
                            _loopCounter = 0;
                            _tapCounter = 0;
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepOrange,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          "Reset",
                          style: TextStyle(
                            color:
                            Theme.of(context).colorScheme.onErrorContainer,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _saveData() async {
    if (savedData.isEmpty) {
      await DBHelper.instance.insertData(
        _selectedItem,
        "$_tapsPerLoop",
        "$_loopCounter",
        "$_tapCounter",
      );
    } else {
      await DBHelper.instance.updateData(
        savedData[0]['id'],
        _selectedItem,
        "$_tapsPerLoop",
        "$_loopCounter",
        "$_tapCounter",
      );
    }
    savedData = await DBHelper.instance.getData();
    setState(() {});
  }

  @override
  void dispose() {
    controllers.dispose();
    _scrollController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenwidth = MediaQuery.sizeOf(context).width;
    double screenHeight = MediaQuery.of(context).size.height;

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: Colors.white30,
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          elevation: 0,
          backgroundColor: Colors.transparent,
          centerTitle: true,
          title: const Text(
            'Jaap',
            style: TextStyle(
                color: Colors.orange,
                fontSize: 25,
                fontWeight: FontWeight.bold),
          ),
          flexibleSpace: SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(left: 8.0, top: 8.0),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                  ),
                  IconButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => WallpaperScreen(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.settings, color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
          // leading: IconButton(
          //   onPressed: () {
          //     Navigator.push(
          //       context,
          //       MaterialPageRoute(
          //         builder: (context) => WallpaperScreen(),
          //       ),
          //     );
          //   },
          //   icon: Icon(
          //     Icons.settings,
          //     size: 18,
          //     color: Colors.white,
          //   ),
          // ),
          actions: [
            // GestureDetector(
            //   onTap: _showsettingsheet,
            //   child: Icon(Icons.settings, color: Colors.white),
            // ),
            // SizedBox(width: 15),
            BouncingWidgetInOut(
              onPressed: () {
                setState(() {
                  _vibrationEnabled = !_vibrationEnabled;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 7),
                height: 40,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8.0),
                    color: _vibrationEnabled
                        ? Colors.orange.withOpacity(0.4)
                        : Colors.transparent,
                    border: Border.all(color: Colors.white, width: 2)),
                child: const Icon(
                  Icons.vibration,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(
              width: 5,
            ),
            BouncingWidgetInOut(
              onPressed: () {
                _incrementNumber();
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 7),
                height: 40,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8.0),
                    color: Colors.orange.withOpacity(0.4),
                    border: Border.all(color: Colors.white, width: 2)),
                child: const Icon(
                  Icons.palette,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(
              width: 10,
            ),
          ],
        ),
        body: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: itemColorIndex == 0
                  ? const AssetImage('assets/images/jaap/ram_3.png')
                  : itemColorIndex == 1
                  ? const AssetImage('assets/images/jaap/ram_4.png')
                  : itemColorIndex == 2
                  ? const AssetImage('assets/images/jaap/ram_5.png')
                  : AssetImage('assets/images/jaap/$_selectedImage'),
              fit: BoxFit.cover,
            ),
          ),
          child: Column(
            children: [
              SizedBox(height: screenHeight * 0.11),
              Padding(
                padding: const EdgeInsets.only(left: 18, right: 18),
                child: TabBar(
                  controller: _tabController,
                  isScrollable: false,
                  indicatorSize: TabBarIndicatorSize.tab,
                  dividerColor: Colors.transparent,
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.white,
                  indicatorWeight: 1,
                  indicatorColor: Colors.orange,
                  onTap: (index) {
                    setState(() {
                      _tabController.index = index;
                    });
                  },
                  tabs: [
                    Tab(
                      child: Container(
                        child: Center(
                            child: Text(
                              "Jaap",
                              style: TextStyle(fontSize: screenwidth * 0.04),
                            )),
                      ),
                    ),
                    Tab(
                      child: Container(
                        child: Center(
                            child: Text(
                              "Ram Lekhan",
                              style: TextStyle(fontSize: screenwidth * 0.034),
                            )),
                      ),
                    ),
                    Tab(
                      child: Container(
                        child: Center(
                            child: Text(
                              "Score",
                              style: TextStyle(fontSize: screenwidth * 0.036),
                            )),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    // --------------------------------JAAP TAB STARTS------------------------------
                    SingleChildScrollView(
                      child: Container(
                        decoration: const BoxDecoration(
                            image: DecorationImage(
                                image: AssetImage(
                                    "assets/images/jaap/animation_1.gif"))),
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Column(
                            children: [
                              const SizedBox(
                                height: 10,
                              ),
                              Container(
                                padding: const EdgeInsets.all(10.0),
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: Colors.orange)),
                                height: screenHeight * 0.18,
                                width: double.infinity,
                                child: Center(
                                  child: DropdownButton<String>(
                                    iconEnabledColor: Colors.orange,
                                    iconDisabledColor: Colors.black,
                                    alignment: Alignment.center,
                                    itemHeight: screenHeight * 0.10,
                                    isExpanded: true,
                                    underline: const SizedBox.shrink(),
                                    hint: Text(
                                      _selectedItem.isEmpty
                                          ? 'मंत्र चुनें'
                                          : people
                                          .firstWhere((person) =>
                                      person.name == _selectedItem)
                                          .id,
                                      style: TextStyle(
                                          color: Colors.orange,
                                          fontSize: getFontSize(
                                              _selectedItem.isEmpty
                                                  ? ''
                                                  : people
                                                  .firstWhere((person) =>
                                              person.name ==
                                                  _selectedItem)
                                                  .name,
                                              screenwidth),
                                          fontWeight: FontWeight.w600),
                                      textAlign: TextAlign.center,
                                    ),
                                    icon: const Icon(
                                        Icons.arrow_drop_down_circle_outlined),
                                    iconSize: 25,
                                    onChanged: (value) {
                                      setState(() {
                                        _selectedItem = people
                                            .firstWhere(
                                                (person) => person.id == value)
                                            .name;
                                        //_selectedItem = people.firstWhere((person) => person.id == value).name;
                                      });
                                    },
                                    items: people.map((person) {
                                      int index = people.indexOf(person);
                                      return DropdownMenuItem<String>(
                                        value: person.id,
                                        child: Text(person.name),
                                      );
                                    }).toList(),
                                  ),
                                ),
                              ),

                              // ----------------------------------0 loop-0  reset---------------------
                              const SizedBox(
                                height: 15,
                              ),
                              Row(
                                children: [
                                  GestureDetector(
                                    onTap: _selectedItem.isEmpty
                                        ? null
                                        : _showBottomSheets,
                                    child: Column(
                                      children: [
                                        Container(
                                          width: screenwidth * 0.17,
                                          height: screenHeight * 0.08,
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                                color: Colors.white, width: 1),
                                            color: Colors.orange.withOpacity(
                                                0.4), // highlight color
                                            borderRadius:
                                            BorderRadius.circular(300),
                                          ),
                                          child: Center(
                                            child: Text(
                                              "$_tapsPerLoop",
                                              style: TextStyle(
                                                  fontSize: _tapsPerLoop == 1008
                                                      ? 24
                                                      : 30,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(
                                          height: 8,
                                        ),
                                        Container(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 2, horizontal: 5),
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                  color: Colors.white,
                                                  width: 1),
                                              color: Colors.orange.withOpacity(
                                                  0.4), // highlight color
                                              borderRadius:
                                              BorderRadius.circular(8),
                                            ),
                                            child: const Center(
                                                child: Text("संख्या चुनें",
                                                    style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 18)))),
                                      ],
                                    ),
                                  ),
                                  const Spacer(),
                                  Text(
                                    'माला : $_loopCounter',
                                    style: TextStyle(
                                        fontSize: screenwidth * 0.08,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white),
                                  ),
                                  const Spacer(),
                                  GestureDetector(
                                    onTap: _selectedItem.isEmpty
                                        ? null
                                        : () async {
                                      // make it async so await works
                                      setState(() {
                                        _tapCounter = 0;
                                        _tapsPerLoop = 11;
                                        _loopCounter = 0;
                                        product = 0;
                                      });

                                      await DBHelper.instance.deleteData(
                                          1); // deletes row with id=1
                                      print(
                                          "Data with id=1 deleted from DB");
                                    },
                                    child: Column(
                                      children: [
                                        Container(
                                          width: screenwidth * 0.17,
                                          height: screenHeight * 0.08,
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                                color: Colors.white, width: 1),
                                            color:
                                            Colors.orange.withOpacity(0.4),
                                            borderRadius:
                                            BorderRadius.circular(300),
                                          ),
                                          child: const Center(
                                            child: Icon(Icons.restart_alt,
                                                color: Colors.white, size: 35),
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 2, horizontal: 5),
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                                color: Colors.white, width: 1),
                                            color:
                                            Colors.orange.withOpacity(0.4),
                                            borderRadius:
                                            BorderRadius.circular(8),
                                          ),
                                          child: const Center(
                                            child: Text(
                                              "रीसेट करें",
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 18),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                ],
                              ),

                              GestureDetector(
                                onTap: () {
                                  if (_selectedItem.isEmpty) {
                                    // Show alert message
                                    showCupertinoDialog(
                                      context: context,
                                      builder: (context) =>
                                          CupertinoAlertDialog(
                                            title: const Text(
                                                'Please select the Jaap'),
                                            //content: Text('You must select a Jaap before tapping'),
                                            actions: [
                                              CupertinoDialogAction(
                                                child: const Text(
                                                  'OK',
                                                  style: TextStyle(
                                                      color: Colors.blueAccent),
                                                ),
                                                onPressed: () {
                                                  Navigator.of(context).pop();
                                                },
                                              ),
                                            ],
                                          ),
                                    );
                                  } else {
                                    setState(() {
                                      if (_vibrationEnabled) {
                                        HapticFeedback.heavyImpact();
                                        // Vibrate.feedback(FeedbackType
                                        //     .warning); // Enable vibration
                                      }
                                      //play();
                                      _animationController.forward();
                                      _onButtonTap();
                                      _incrementCounter();
                                      product == 1 ? _startTimer() : null;
                                    });
                                    print("Save Data Clicked");
                                    _saveData();
                                  }
                                },
                                child: Transform.scale(
                                  scale: _animation.value,
                                  child: Stack(children: [
                                    Container(
                                      width: screenwidth * 0.8,
                                      height: screenHeight * 0.37,
                                      decoration: BoxDecoration(
                                        image: const DecorationImage(
                                            image: AssetImage(
                                                "assets/images/jaap/flower.png")),
                                        border: Border.all(
                                            color: Colors.transparent,
                                            width: 3),
                                        color: Colors.transparent
                                            .withOpacity(0.01),
                                        borderRadius:
                                        BorderRadius.circular(300),
                                      ),
                                      child: Center(
                                        child: Text(
                                          _tapCounter
                                              .toString()
                                              .padLeft(2, '0'),
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: screenwidth * 0.23,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ]),
                                ),
                              ),
                              // ----------------------------------0 loop-0  reset---------------------

                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Container(
                                    width: screenwidth * 0.17,
                                    height: screenHeight * 0.08,
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                          color: Colors.white, width: 3),
                                      color: Colors.orange
                                          .withOpacity(0.5), // highlight color
                                      borderRadius: BorderRadius.circular(300),
                                    ),
                                    child: Center(
                                      child: TextButton(
                                        child: Text(
                                          "Save",
                                          style: TextStyle(
                                              fontSize: screenwidth * 0.035,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white),
                                        ),
                                        onPressed: () {
                                          if (_selectedItem.isEmpty) {
                                            // Show alert message
                                            showCupertinoDialog(
                                              context: context,
                                              builder: (context) =>
                                                  CupertinoAlertDialog(
                                                    title: const Text(
                                                        'Please select the Jaap'),
                                                    actions: [
                                                      CupertinoDialogAction(
                                                        child: const Text(
                                                          'OK',
                                                          style: TextStyle(
                                                              color: Colors
                                                                  .blueAccent),
                                                        ),
                                                        onPressed: () {
                                                          Navigator.of(context)
                                                              .pop();
                                                        },
                                                      ),
                                                    ],
                                                  ),
                                            );
                                          } else {
                                            _stopTimer();
                                            countSave("$product");
                                          }
                                        },
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // --------------------------------RAM LEKHAN TAB STARTS------------------------------
                    SingleChildScrollView(
                      controller: _scrollController,
                      physics:
                      const ClampingScrollPhysics(), // or ClampingScrollPhysics()
                      child: Container(
                        height: screenHeight * 0.835,
                        color: Colors.white,
                        child: Stack(
                          children: [
                            Container(
                              height: screenHeight * 0.5,
                              width: double.infinity,
                              color:
                              Colors.white, // optional, for visualization
                              child: Scrollbar(
                                child: SingleChildScrollView(
                                  controller: _scrollController,
                                  physics:
                                  const ClampingScrollPhysics(), // or ClampingScrollPhysics()
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: [
                                      Wrap(
                                        spacing:
                                        0, // Spacing between items in the same row
                                        runSpacing: 0, // Spacing between rows
                                        children: [
                                          // Display the signatures
                                          for (int i = 0;
                                          i < signatures.length;
                                          i++)
                                            Container(
                                              decoration: BoxDecoration(
                                                  border: Border(
                                                    right: BorderSide(
                                                      color: Colors.amber.shade200,
                                                      width: 1.0,
                                                    ),
                                                    left: BorderSide(
                                                      color: Colors.amber.shade200,
                                                      width: 1.0,
                                                    ),
                                                    bottom: BorderSide(
                                                      color: Colors.amber.shade200,
                                                      width: 1.0,
                                                    ),
                                                  )),
                                              child: Padding(
                                                padding: const EdgeInsets.only(
                                                    right: 8, left: 8),
                                                child: Image.memory(
                                                  signatures[i],
                                                  width: screenwidth * 0.0959,
                                                  height: screenHeight * 0.063,
                                                ),
                                              ),
                                            ),

                                          // for (int i = 0; i < _textstype.length; i++)
                                          //   Padding(
                                          //     padding: const EdgeInsets.all(8.0),
                                          //     child: Text(
                                          //       _textstype[i],
                                          //       style: TextStyle(
                                          //           fontSize: screenwidth * 0.034, color: Colors.red),
                                          //     ),
                                          //   ),

                                          for (var text in _texts) text,
                                        ],
                                      ),
                                      const SizedBox(height: 20),
                                    ],
                                  ),
                                ),
                              ),
                            ),

                            _isSignatureVisible
                                ? Positioned(
                              top: screenHeight * 0.57,
                              child: Column(
                                children: [
                                  // Conditionally show the Signature Container
                                  Container(
                                    height: screenHeight * 0.26,
                                    width: screenwidth * 0.999,
                                    decoration: BoxDecoration(
                                      color: Colors.red,
                                      border: Border.all(
                                          color: Colors.red, width: 2),
                                    ),
                                    child: Signature(
                                      controller: controllers,
                                      //height: 270,
                                      width: double.infinity,
                                      backgroundColor: Colors.white,
                                    ),
                                  )
                                ],
                              ),
                            )
                                : const SizedBox(),

                            // Positioned(
                            //   top: screenHeight * 0.68,
                            //   child: Column(
                            //     children: [
                            //       if (_showKeyboard)
                            //         Padding(
                            //           padding: const EdgeInsets.symmetric(horizontal: 12,),
                            //           child: SizedBox(
                            //             // Add a SizedBox with a specific width
                            //             width: screenwidth * 0.560, //// or any other width you want
                            //             height: screenHeight * 0.06,
                            //             child: TextFormField(
                            //               controller: _textController,
                            //               decoration: InputDecoration(
                            //                 suffixIcon: IconButton(
                            //                   icon: Icon(Icons.send),
                            //                   onPressed: () {
                            //                     _updateText(_textController.text);
                            //                     _textController.clear(); // Clear text field after updating
                            //                     _toggleKeyboard(); // Hide keyboard after input
                            //                   },
                            //                 ),
                            //                 hintText: 'Type here...',
                            //                 border: OutlineInputBorder(
                            //                     borderRadius: BorderRadius.circular(100)),
                            //               ),
                            //             ),
                            //           ),
                            //         ),
                            //     ],
                            //   ),
                            // ),
                          ],
                        ),
                      ),
                    ),

                    // Score History
                    Center(
                      child: History(
                        product: product,
                        data: _savedCounts,
                        index: tabIndex,
                        counter: _counter,
                        pressCounts: _pressCounts,
                        selectedItem: _selectedItem,
                        currentTime: _currentTime,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        floatingActionButton: _tabController.index == 1
            ? Stack(
          children: [
            _isSignatureVisible
                ? Positioned(
              bottom: 10,
              right: 10,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    onPressed: () {
                      setState(() {
                        _isSignatureVisible =
                        false; // Toggle the visibility
                      });
                    },
                    icon: Icon(
                      _isSignatureVisible
                          ? Icons.cancel
                          : Icons.edit,
                      size: 30,
                    ),
                  ),
                  const SizedBox(height: 5),
                  IconButton(
                    onPressed: () async {
                      controllers.clear();
                      setState(() {});
                    },
                    icon: const Icon(Icons.undo),
                  ),
                  const SizedBox(height: 5),
                  IconButton(
                    onPressed: () async {
                      Uint8List? newSignature =
                      await controllers.toPngBytes();
                      if (newSignature != null) {
                        signatures.add(newSignature);
                        setState(() {});
                      }
                      _incrementButtonPressCounts();
                      // Clear the signature pad after saving
                      controllers.clear();
                    },
                    icon: const Icon(Icons.done),
                  ),
                ],
              ),
            )
                : Positioned(
              right: 10,
              bottom: 10,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      IconButton(
                        onPressed: () async {
                          showCupertinoDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return CupertinoAlertDialog(
                                title: const Text('Clear All'),
                                actions: [
                                  CupertinoDialogAction(
                                    child: const Text(
                                      'Cancel',
                                      style: TextStyle(
                                          color: Colors.blue),
                                    ),
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                  CupertinoDialogAction(
                                    child: const Text(
                                      'Clear',
                                      style: TextStyle(
                                        color: Colors.red,
                                      ),
                                    ),
                                    onPressed: () {
                                      _texts.clear();
                                      signatures.clear();
                                      _buttonPressCount = 0;
                                      _buttonPressCounts = 0;
                                      _totalPressCount = 0;
                                      _textController.clear();
                                      _textstype.clear();
                                      setState(() {});
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                ],
                              );
                            },
                          );
                        },
                        icon: Image.network(
                          'https://w7.pngwing.com/pngs/892/810/png-transparent-computer-icons-eraser-icon-design-graphic-design-eraser-angle-logo-black-thumbnail.png',
                          width:
                          24, // adjust the width and height to your liking
                          height: 24,
                        ),
                      ),
                      const SizedBox(
                        width: 10.0,
                      ),
                      IconButton(
                        onPressed: () {
                          setState(() {
                            _isSignatureVisible =
                            true; // Toggle the visibility
                          });
                        },
                        icon: Icon(
                          _isSignatureVisible
                              ? Icons.done
                              : Icons.edit,
                        ),
                      ),
                    ],
                  ),

                  // Score btn Ram btn Count
                  Column(
                    children: [
                      Container(
                        width: screenwidth * 0.17,
                        height: screenHeight * 0.08,
                        decoration: BoxDecoration(
                          border: Border.all(
                              color: Colors.purple.shade300,
                              width: 1),
                          color: Colors.grey.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(300),
                        ),
                        child: Center(
                          child: Text(
                            _totalPressCount
                                .toString()
                                .padLeft(2, '0'),
                            style: TextStyle(
                                fontSize: screenwidth * 0.070,
                                fontWeight: FontWeight.bold,
                                color: Colors.purple.shade300),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Container(
                        width: screenwidth * 0.17,
                        height: screenHeight * 0.08,
                        decoration: BoxDecoration(
                          border: Border.all(
                              color: Colors.purple.shade300,
                              width: 1),
                          color: Colors.grey.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(300),
                        ),
                        child: Center(
                          child: TextButton(
                            child: Text(
                              "Score",
                              style: TextStyle(
                                  fontSize: screenwidth * 0.034,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.purple.shade300),
                            ),
                            onPressed: () {
                              if (_totalPressCount == 0 &&
                                  _texts.isEmpty &&
                                  signatures.isEmpty &&
                                  _textstype.isEmpty) {
                                // Show alert message
                                showCupertinoDialog(
                                  context: context,
                                  builder: (context) =>
                                      CupertinoAlertDialog(
                                        title: const Text(
                                            'Please perform some action'),
                                        actions: [
                                          CupertinoDialogAction(
                                            child: const Text(
                                              'OK',
                                              style: TextStyle(
                                                  color: Colors
                                                      .blueAccent),
                                            ),
                                            onPressed: () {
                                              Navigator.of(context)
                                                  .pop();
                                            },
                                          ),
                                        ],
                                      ),
                                );
                              } else {
                                // Navigate to ResultPage and pass the product
                                // Use DefaultTabController.of(context) to access TabController
                                _stopTimer();
                                ramLekhanSave("$_totalPressCount");
                              }
                            },
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          SizedBox(height: screenHeight * 0.10),
                          InkWell(
                            onTap: () {
                              setState(() {
                                if (_vibrationEnabled) {
                                  HapticFeedback.heavyImpact();

                                  // Vibrate.feedback(FeedbackType
                                  //     .warning); // Enable vibration
                                }
                                _addText();
                                _incrementButtonPressCount();
                                _scrollToLastSignature();
                                _startTimer();
                              });
                            },
                            child: Container(
                              width: screenwidth * 0.17,
                              height: screenHeight * 0.08,
                              decoration: BoxDecoration(
                                border: Border.all(
                                    color: Colors.purple.shade300,
                                    width: 1),
                                color: Colors.grey.withOpacity(0.1),
                                borderRadius:
                                BorderRadius.circular(300),
                              ),
                              child: Center(
                                child: Text(
                                  "Ram",
                                  style: TextStyle(
                                      fontSize: screenwidth * 0.034,
                                      fontWeight: FontWeight.bold,
                                      color:
                                      Colors.purple.shade300),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            )
          ],
        )
            : const SizedBox(),
      ),
    );
  }

  void _scrollToLastSignature() {
    if (signatures.isNotEmpty) {
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    }
  }
}
