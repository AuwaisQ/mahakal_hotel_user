import 'dart:async';
import 'dart:convert';
import 'package:avatar_stack/avatar_stack.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mahakal/features/mandir/view/mandir.dart';
import 'package:mahakal/features/sahitya/view/gita_chapter/gitastatic.dart';
import 'package:mahakal/features/sangeet/view/sangeet_home/sangit_home.dart';
import 'package:mahakal/utill/app_constants.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:tdk_bouncingwidget/tdk_bouncingwidget.dart';
import 'package:http/http.dart' as http;

import '../donation/view/home_page/Donation_Home/donation_home_view.dart';

class AkhandDiyaScreen extends StatefulWidget {
  final String? userId;

  const AkhandDiyaScreen({
    super.key,
    required this.userId,
  });

  @override
  _AkhandDiyaScreenState createState() => _AkhandDiyaScreenState();
}

class _AkhandDiyaScreenState extends State<AkhandDiyaScreen> {
  late Timer _timer;
  Duration _remainingTime = const Duration(hours: 24);
  bool _isRunning = false;
  bool _showStartButton = true;
  double _oilLoader = 1.0; // Percentage loader
  Map<String, dynamic> _activeJyotiData = {};
  Map<String, bool> _weekdays = {};
  int _akhandJyotiCount = 0;
  int _totalUsersCount = 0;
  bool showGif = false;
  String userId = "";
  bool gridList = false;
  String translateEn = 'hi';
  bool isLoading = false;

  // Calculate the total time in seconds
// 24 hours in seconds

  @override
  void initState() {
    super.initState();
    //  _initializeUserId();
    userId = widget.userId!;
    _fetchInitialData();
  }

  // /// Load the user ID correctly before fetching data
  // Future<void> _initializeUserId() async {
  //   await loadUserId(); // Load user ID from SharedPreferences
  //   if (userId == "-1") {
  //     // If not found, get it from Provider and save it
  //     userId = Provider.of<ProfileController>(context, listen: false).userID;
  //     await saveUserId(userId);
  //   }
  //   _fetchInitialData(); // Fetch data after userId is initialized
  // }
  // Future<void> saveUserId(String id) async{
  //   final prefs = await SharedPreferences.getInstance();
  //   await prefs.setString("user_Id", id);
  // }
  // Future<void> loadUserId() async{
  //   final prefs = await SharedPreferences.getInstance();
  //   setState(() {
  //     userId = prefs.getString("user_Id") ?? "-1";
  //   });
  // }

  void playGif() {
    setState(() {
      showGif = true;
    });

    // Hide the GIF after 3 seconds
    Timer(const Duration(seconds: 5), () {
      setState(() {
        showGif = false;
      });
    });
  }

  Future<void> _fetchInitialData() async {
    await _checkDiyaStatus();
    await _fetchJyotiListData();
  }

  Future<void> _checkDiyaStatus() async {
    final response = await http.get(Uri.parse(
        '${AppConstants.baseUrl}/api/v1/akhand/jyoti/get/status?customer_id=$userId'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['status'] && data['akhandJyoti']) {
        _loadPersistentData();
        setState(() {
          _isRunning = true;
          _showStartButton = false;
        });
      }
    }
  }

  Future<void> _fetchJyotiListData() async {
    final response = await http.get(Uri.parse(
        '${AppConstants.baseUrl}/api/v1/akhand/jyoti/list?customer_id=$userId'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['status']) {
        setState(() {
          _activeJyotiData = data['activeAkhandJyoti'] ?? {};
          _weekdays = Map<String, bool>.from(data['weekdays']);
          _akhandJyotiCount = data['akhanJyotiCount'] ?? 0;
          _totalUsersCount = data['totalUsersCount'] ?? 0;
          if (_activeJyotiData.isNotEmpty) {
            DateTime.parse(_activeJyotiData['start_datetime']);
            final endTime = DateTime.parse(_activeJyotiData['end_datetime']);
            _remainingTime = endTime.difference(DateTime.now());
            _oilLoader = _remainingTime.inSeconds / (24 * 3600);
          }
        });
      }
    }
  }

  Future<void> _startDiya() async {
    final response = await http.post(
      Uri.parse('${AppConstants.baseUrl}/api/v1/akhand/jyoti/create'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({"customer_id": userId}),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['status']) {
        setState(() {
          _isRunning = true;
          _showStartButton = false;
        });
        _fetchInitialData();
        _startTimer();
        playGif();
      }
    }
  }

  Future<void> _applyOil() async {
    final today = DateFormat('EEEE').format(DateTime.now());

    final response = await http.post(
      Uri.parse('${AppConstants.baseUrl}/api/v1/akhand/jyoti/update'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({"customer_id": userId}),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['status']) {
        setState(() {
          // Reset the timer to exactly 24 hours (24:00:00)
          _remainingTime = const Duration(hours: 24);
          _oilLoader = 1.0; // Full loader

          playGif();

          // Ensure weekdays map updates correctly
          _weekdays[today] = true;
        });
      }
    }
  }

  Future<void> _startTimer() async {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingTime.inSeconds > 0) {
        setState(() {
          _remainingTime -= const Duration(seconds: 1);
          _oilLoader = _remainingTime.inSeconds / (24 * 3600);
        });
      } else {
        _timer.cancel();
        _updateRemainingTimeOnServer(); // Stop the diya when the timer ends
      }
    });
  }

  Future<void> _loadPersistentData() async {
    final response = await http.get(Uri.parse(
        '${AppConstants.baseUrl}/api/v1/akhand/jyoti/list?customer_id=$userId'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        if (data['activeAkhandJyoti'] != null) {
          final activeJyoti = data['activeAkhandJyoti'];
          final endTime = DateTime.parse(activeJyoti['end_datetime']);
          final now = DateTime.now();

          _remainingTime = endTime.difference(now);

          // Ensure remaining time does not exceed 24 hours
          if (_remainingTime.inSeconds > 24 * 3600) {
            _remainingTime = const Duration(hours: 24);
          }

          _isRunning = _remainingTime.inSeconds > 0;

          if (_isRunning) {
            _startTimer();
          } else {
            _showStartButton = true;
          }
        } else {
          _showStartButton = true;
          _remainingTime = const Duration(hours: 24);
          _isRunning = false;
        }

        _activeJyotiData = data['activeAkhandJyoti'] ?? {};
        _weekdays = Map<String, bool>.from(data['weekdays']);
        _akhandJyotiCount = data['akhanJyotiCount'] ?? 0;
        _totalUsersCount = data['totalUsersCount'] ?? 0;
      });
    }
  }

  String _getDiyaImage() {
    final hoursElapsed = 24 - _remainingTime.inHours;
    if (!_isRunning) return 'assets/diya/diya_smoke_3.gif';
    if (hoursElapsed < 6) return 'assets/diya/diya_animation_1.gif';
    if (hoursElapsed < 12) return 'assets/diya/diya_animation_2.gif';
    if (hoursElapsed < 18) return 'assets/diya/diya_animation_3.gif';
    if (hoursElapsed == 18) return 'assets/diya/diya_animation_4.gif';
    if (hoursElapsed == 19) return 'assets/diya/diya_animation_5.gif';
    if (hoursElapsed == 20) return 'assets/diya/diya_animation_6.gif';
    if (hoursElapsed == 21) return 'assets/diya/diya_animation_7.gif';
    if (hoursElapsed == 22) return 'assets/diya/diya_animation_8.gif';
    if (hoursElapsed == 23) return 'assets/diya/diya_animation_9.gif';
    if (hoursElapsed == 24) return 'assets/diya/diya_animation_9.gif';
    return 'assets/diya/Diya.png';
  }

  Future<void> _updateRemainingTimeOnServer() async {
    // Call API to update the remaining time
    final response = await http.post(
      Uri.parse('${AppConstants.baseUrl}/api/v1/akhand/jyoti/update'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        "customer_id": userId, // Use the appropriate customer ID
      }),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['status']) {
        // Successfully updated the remaining time
        print("Remaining time updated successfully.");
      } else {
        // Handle error if needed
        print("Failed to update remaining time.");
      }
    } else {
      // Handle HTTP error
      print("Error: ${response.statusCode}");
    }
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  String twoDigits(int n) => n.toString().padLeft(2, '0');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: InkWell(
            onTap: () {
              Navigator.pop(context);
            },
            child: const Icon(Icons.arrow_back)),
        title: const Text(
          "Akhand Jyoti",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        actions: [
          Expanded(
            flex: 0,
            child: BouncingWidgetInOut(
              onPressed: () {
                setState(() {
                  gridList = !gridList;
                  translateEn = gridList ? 'en' : 'hi';
                });
              },
              bouncingType: BouncingType.bounceInAndOut,
              child: Container(
                height: 30,
                width: 30,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4.0),
                    color: gridList ? Colors.orange : Colors.white,
                    border: Border.all(color: Colors.orange, width: 2)),
                child: Center(
                  child: Icon(
                    Icons.translate,
                    color: gridList ? Colors.white : Colors.orange,
                    size: 18,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10)
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      color: Colors.orange,
                      height: 20,
                      width: 3,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      translateEn == "en"
                          ? "Longest Continuous Deep Prajwalana"
                          : "दीप प्रज्वलन की सबसे लंबी निरंतरता",
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const Spacer(),
                    const Icon(
                      Icons.report_gmailerrorred_sharp,
                      color: Colors.orange,
                    ),
                  ],
                ),

                const SizedBox(height: 10),
                Container(
                  height: 435,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    image: const DecorationImage(
                      image: AssetImage("assets/diya/diya_baground.jpg"),
                      fit: BoxFit.cover,
                    ),
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        spreadRadius: 1,
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Stack(
                    // Wrap everything inside a Stack
                    children: [
                      if (showGif)
                        Stack(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                color: Colors.white24,
                              ),
                            ),
                            Image.asset("assets/diya/sparcle_animation.gif",
                                height: 1000, width: 500, fit: BoxFit.fill),
                            Image.asset("assets/diya/sparcle_animation.gif",
                                height: 800, width: 400, fit: BoxFit.fill),
                            Image.asset("assets/diya/sparcle_animation.gif",
                                height: 400, width: 200, fit: BoxFit.fill),
                          ],
                        ),
                      Padding(
                        padding: const EdgeInsets.all(10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Use Row instead of Positioned
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      translateEn == "en"
                                          ? "$_akhandJyotiCount Days"
                                          : "$_akhandJyotiCount दिन",
                                      style: const TextStyle(
                                          fontSize: 40,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white),
                                    ),
                                    const SizedBox(height: 10),
                                    SizedBox(
                                      width: 150,
                                      child: Text(
                                        translateEn == "en"
                                            ? "You have been Prajwalit Deep (Akand Jyoti) daily at the designated time for the past $_akhandJyotiCount days."
                                            : "आपने पिछले $_akhandJyotiCount दिनों से नित्य निर्धारित समय पर दीप प्रज्वलित किया है।",
                                        style: const TextStyle(
                                            fontSize: 18,
                                            color: Colors.white,
                                            fontWeight: FontWeight.w400),
                                        maxLines: 10,
                                      ),
                                    ),
                                    const SizedBox(height: 5),
                                  ],
                                ),
                                const Spacer(),
                                Column(
                                  children: [
                                    Container(
                                      height: 230,
                                      width: 190,
                                      decoration: const BoxDecoration(
                                        image: DecorationImage(
                                          image: AssetImage(
                                              "assets/diya/diya_cover.png"),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.only(
                                            top: 65, left: 25, right: 20),
                                        child: Center(
                                          child: Image.asset(
                                            _getDiyaImage(),
                                            height: 85,
                                            width: 85,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),

                            const SizedBox(height: 15),

                            // Move Positioned Widgets Inside Stack
                            Expanded(
                              child: Stack(
                                children: [
                                  Positioned(
                                    bottom: 100,
                                    child: SizedBox(
                                      width: 300,
                                      child: Text(
                                        translateEn == "en"
                                            ? "There is this much time left before the oil in your diya runs out."
                                            : "आपके दीये में तेल खत्म होने के लिए इतना समय शेष है।",
                                        style: const TextStyle(
                                            fontSize: 17,
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold),
                                        maxLines: 2,
                                      ),
                                    ),
                                  ),
                                  if (_isRunning)
                                    Positioned(
                                      left: 0,
                                      right: 0,
                                      bottom: 55,
                                      child: Row(
                                        children: [
                                          _buildTimeContainer(
                                              '${twoDigits(_remainingTime.inHours)} Hours'),
                                          _buildColon(),
                                          _buildTimeContainer(
                                              '${twoDigits(_remainingTime.inMinutes.remainder(60))} Mins'),
                                          _buildColon(),
                                          _buildTimeContainer(
                                              '${twoDigits(_remainingTime.inSeconds.remainder(60))} Sec'),
                                          //_buildTimeContainer('${userId} userid'),
                                        ],
                                      ),
                                    ),
                                  Positioned(
                                    bottom: 0,
                                    left: 0,
                                    right: 0,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        SizedBox(
                                          width: 270,
                                          child: LinearProgressIndicator(
                                            value: _oilLoader,
                                            borderRadius:
                                                BorderRadius.circular(20),
                                            minHeight: 15,
                                            color: Colors.green,
                                          ),
                                        ),
                                        const SizedBox(width: 5.0),
                                        if (!_showStartButton && _isRunning)
                                          _buildActionButton(_applyOil,
                                              "Apply Oil", "तेल चढ़ाए"),
                                        if (_showStartButton)
                                          _buildActionButton(_startDiya,
                                              "Light a Lamp", "दिया जलाये"),
                                      ],
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
                ),

                const SizedBox(height: 20),

                Container(
                  decoration: BoxDecoration(
                      // color: Colors.orange.shade100,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.grey)),
                  padding: const EdgeInsets.only(
                      top: 10, bottom: 10, right: 1, left: 1),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 10.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(
                              translateEn == "en"
                                  ? 'Continuity Tracker'
                                  : 'नियमितता का रिकॉर्ड',
                              style: const TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),

                            // SizedBox(width: 8),
                            // Padding(
                            //     padding: EdgeInsets.only(bottom: 5.0),
                            //     child: IconButton(onPressed: _decreaseTime, icon: Icon(Icons.minimize))
                            // ),
                            //
                            // Padding(
                            //     padding: EdgeInsets.only(bottom: 5.0),
                            //     child: IconButton(onPressed: _increaseTime, icon: Icon(Icons.add))
                            // ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 7),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: _weekdays.entries.map((entry) {
                          String dayName = entry.key;
                          bool isActive = entry.value;

                          return Column(
                            children: [
                              Container(
                                width: 40.0, // Set the desired width
                                height: 40.0, // Set the desired height
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  image: DecorationImage(
                                    image: AssetImage(
                                      isActive
                                          ? 'assets/diya/diya_animation_1.gif' // Active image
                                          : 'assets/diya/Diya.png', // Inactive image
                                    ),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              Text(
                                dayName.substring(0,
                                    3), // Get the first three letters of the day
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // People Section
                Row(
                  children: [
                    Container(
                      color: Colors.orange,
                      height: 20,
                      width: 3,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      flex: 1,
                      child: Text(
                        translateEn == "en"
                            ? "Those Sanatanis who Prajwalit Deep (Akand Jyoti) daily with devotion."
                            : "जो सनातनी भक्ति भाव से प्रतिदिन दीप (अखण्ड ज्योति) प्रज्वलित करते हैं।",
                        style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            overflow: TextOverflow.ellipsis),
                        maxLines: 2,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Container(
                  decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(10)),
                  child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          /// Participated People
                          AvatarStack(
                            borderColor: Colors.orange,
                            width: 250,
                            height: 30,
                            avatars: [
                              for (var n = 0; n < _totalUsersCount; n++)
                                NetworkImage(
                                    'https://i.pravatar.cc/150?img=$n'),
                            ],
                          ),

                          Text.rich(
                            TextSpan(
                              text: 'Till now',
                              style: const TextStyle(
                                  fontSize: 16, color: Colors.black),
                              children: <TextSpan>[
                                TextSpan(
                                  text: ' $_totalUsersCount+ Devotees ',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.orange,
                                      fontSize: 16),
                                ),
                                const TextSpan(
                                  text:
                                      'have participated in Akhand Jyoti Sankalp oraganized by',
                                  style: TextStyle(
                                      fontSize: 16, color: Colors.black),
                                ),
                                const TextSpan(
                                  text: ' Mahakal.com',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.orange,
                                      fontSize: 16),
                                ),
                              ],
                            ),
                            textAlign: TextAlign.start,
                          ),
                        ],
                      )),
                ),
                const SizedBox(height: 20),

                // Tasks Section
                Row(
                  children: [
                    Container(
                      color: Colors.orange,
                      height: 20,
                      width: 3,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      translateEn == "en"
                          ? "Some task for you"
                          : "आपके लिए कुछ कार्य",
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const Spacer(),
                    const Icon(
                      Icons.report_gmailerrorred_sharp,
                      color: Colors.orange,
                    )
                  ],
                ),
                const SizedBox(height: 10),
                Column(
                  children: [
                    TaskTile(
                      title: translateEn == "en"
                          ? "Perform Aarti in temple"
                          : "मंदिर में आरती करें",
                      image:
                          'assets/images/allcategories/animate/mandir_darshan_animation.gif',
                      size: 55,
                      onPressed: () => Navigator.push(
                          context,
                          CupertinoPageRoute(
                            builder: (context) => const Mandir(tabIndex: 0),
                          )),
                    ),
                    TaskTile(
                      title: translateEn == "en"
                          ? "Listen to Religious music"
                          : "धार्मिक संगीत सुनें",
                      image: 'assets/testImage/categories/sangeet_Icon.png',
                      onPressed: () => Navigator.push(
                          context,
                          CupertinoPageRoute(
                            builder: (context) =>
                                const SangitHome(tabiIndex: 1),
                          )),
                    ),
                    TaskTile(
                      title: translateEn == "en"
                          ? "Help the Needy People by Donation"
                          : "दान द्वारा जरूरतमंद लोगों की मदद करें",
                      image:
                          'assets/images/allcategories/animate/Daanicon animation.gif',
                      onPressed: () => Navigator.push(
                          context,
                          CupertinoPageRoute(
                            builder: (context) => const DonationHomeView(),
                          )),
                    ),
                    TaskTile(
                      title: translateEn == "en"
                          ? "Gain Knowledge of Geeta"
                          : "गीता का ज्ञान प्राप्त करें",
                      image: 'assets/testImage/categories/shaitya_icon.png',
                      onPressed: () => Navigator.push(
                          context,
                          CupertinoPageRoute(
                            builder: (context) => const SahityaChapters(),
                          )),
                    ),
                    TaskTile(
                      title: translateEn == "en"
                          ? "Offer Flowers to the temple"
                          : "मंदिर में फूल चढ़ाएं",
                      image: 'assets/mandir_images/flowerbuttonanimation.gif',
                      size: 35,
                      onPressed: () => Navigator.push(
                          context,
                          CupertinoPageRoute(
                            builder: (context) => const Mandir(tabIndex: 0),
                          )),
                    ),
                    TaskTile(
                      title: translateEn == "en"
                          ? "Blow Conch in the temple"
                          : "मंदिर में शंख बजाएं",
                      image: 'assets/mandir_images/shank.png',
                      size: 50,
                      onPressed: () => Navigator.push(
                          context,
                          CupertinoPageRoute(
                            builder: (context) => const Mandir(tabIndex: 0),
                          )),
                    ),
                    TaskTile(
                      title: translateEn == "en"
                          ? "Make Offerings in the temple"
                          : "मंदिर में चढ़ावा चढ़ाइये",
                      image:
                          'assets/images/allcategories/animate/chadhava_animation.gif',
                      size: 55,
                      onPressed: () => Navigator.push(
                          context,
                          CupertinoPageRoute(
                            builder: (context) => const Mandir(tabIndex: 0),
                          )),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Invite Section
                Row(
                  children: [
                    Container(
                      color: Colors.orange,
                      height: 20,
                      width: 3,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      translateEn == "en"
                          ? "Invite your friends and family"
                          : "अपने मित्रों और परिवार को आमंत्रित करें",
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const Spacer(),
                    const Icon(
                      Icons.report_gmailerrorred_sharp,
                      color: Colors.orange,
                    )
                  ],
                ),
                const SizedBox(height: 10),

                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        Text(
                          translateEn == "en"
                              ? "Connect your friends and family with Mahakal.com"
                              : "अपने दोस्तों और परिवार को mahakal.com से जोड़ें",
                          style: const TextStyle(
                              fontSize: 17, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          translateEn == "en"
                              ? "For Every member you Earn Punya and your friends and family also earn punya"
                              : "प्रत्येक सदस्य के लिए आप पुण्य अर्जित करते हैं और आपके मित्र और परिवार भी पुण्य अर्जित करते हैं",
                          style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: FloatingActionButton(
                            backgroundColor: Colors.blueGrey.shade600,
                            onPressed: () async {
                              await Share.share(
                                  'Check out this awesome Flutter package!');
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  translateEn == "en"
                                      ? "Share It"
                                      : "इसे शेयर करें",
                                  style: const TextStyle(
                                      fontSize: 19, color: Colors.white),
                                ),
                                const SizedBox(width: 10),
                                const Icon(Icons.share, color: Colors.white),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTimeContainer(String text) {
    return Container(
      height: 40,
      width: 80,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(9),
        color: const Color.fromRGBO(255, 238, 211, 1),
      ),
      child: Center(
        child: Text(
          text,
          style:
              const TextStyle(color: Colors.black, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }

  Widget _buildColon() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 3),
      child: Text(
        ':',
        style: TextStyle(
            color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18),
      ),
    );
  }

  Widget _buildActionButton(VoidCallback onTap, String enText, String hiText) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 70,
        height: 70,
        decoration: BoxDecoration(
          color: Colors.orange,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.black, width: 2),
        ),
        padding: const EdgeInsets.all(5),
        child: Center(
          child: Text(
            translateEn == "en" ? enText : hiText,
            style: const TextStyle(
                color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
            textAlign: TextAlign.center,
            maxLines: 3,
          ),
        ),
      ),
    );
  }
}

class TaskTile extends StatelessWidget {
  final String title;
  final String image;
  final double size;
  final VoidCallback onPressed;

  const TaskTile(
      {super.key,
      required this.title,
      required this.image,
      this.size = 36.0,
      required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      child: Container(
        decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(10)),
        child: Padding(
          padding: const EdgeInsets.only(top: 6, bottom: 6),
          child: ListTile(
            leading: SizedBox(
              width: 70,
              child: Image.asset(
                image,
                height: size,
                width: size,
              ),
            ),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      overflow: TextOverflow.ellipsis),
                  maxLines: 2,
                ),
                // Text(
                //   titles,
                //   style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                //   maxLines: 1,
                // ),
              ],
            ),
            trailing: ElevatedButton(
              onPressed: onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
              ),
              child: const Text(
                "Click Here",
                style: TextStyle(
                    fontSize: 12,
                    color: Colors.white,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
