import 'dart:async';
import 'dart:math';
import 'package:audioplayers/audioplayers.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mahakal/features/mandir/api_service/api_service.dart';
import 'package:mahakal/utill/app_constants.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:provider/provider.dart';
import '../../Jaap/screen/jaap.dart';
import '../../donation/controller/lanaguage_provider.dart';
import '../../donation/view/home_page/Donation_Home/donation_home_view.dart';
import '../../offline_pooja/view/OfflinePoojaHome.dart';
import '../../ram_shalakha/ram_shalaka.dart';
import '../../sahitya/view/sahitya_home/sahitya_home.dart';
import '../../sangeet/controller/audio_manager.dart';
import '../../tour_and_travells/view/main_home_tour.dart';
import '../../youtube_vedios/view/dynamic_tabview/grid_view/YoutubeGridView.dart';
import '../controller/music_bar.dart';
import '../model/sangrah_model.dart';
import 'mandir_chadhawa.dart';
import 'sangeet_view.dart';

class MandirHomePage extends StatefulWidget {
  int? id;
  String? hiName;
  String? enName;
  String? thumbNail;
  bool isImage;
  List<String>? images;

  MandirHomePage(
      {super.key,
      this.id,
      this.enName,
      this.hiName,
      this.thumbNail,
      this.images,
      this.isImage = false});

  @override
  State<MandirHomePage> createState() => _MandirHomePageState();
}

class _MandirHomePageState extends State<MandirHomePage>
    with TickerProviderStateMixin {
  late PageController _pageController;

  final firstBellPlayer = AudioPlayer();
  final secondBellPlayer = AudioPlayer();
  final artiPlayer = AudioPlayer();
  final shankPlayer = AudioPlayer();

  final bool _isFlowerVisible = false;
  bool _isThaliGifVisible = false;
  bool _animateBell = false;
  bool _showGif = false;
  bool _showGifs = false;
  bool isLoading = false;
  bool isPlaying = false;
  bool isShankPlaying = false;

  Offset _offset = Offset.zero;

  int _currentBackgroundIndex = 0;
  int _currentToranIndex = 0;
  int selectedIndex = 0;

  // BELL-11111   L
  final String bellImage = 'assets/mandir_images/Bell_1.png';
  final String bellGif = 'assets/mandir_images/bell_video.gif';
  final String bellImages = 'assets/mandir_images/bell_2.png';
  final String bellGifs = 'assets/mandir_images/bell_video.gif';

  // Background images list
  List<String> backgroundImages = [
    'assets/mandir_images/mandirfirst.jpg',
    'assets/mandir_images/mandirsecond.jpg',
    'assets/mandir_images/mandirthird.jpg',
    'assets/mandir_images/mandirfourth.jpg',
  ];

  // Toran images list
  List<String> toranImages = [
    'assets/mandir_images/toranfirst.png',
    'assets/mandir_images/toranthird.png',
    'assets/mandir_images/toranfourth.png',
    'assets/mandir_images/toranfifth.png',
  ];

  void _toggleImage(bool isToggle) {
    setState(() {
      _showGif = isToggle; // Show the GIF
    });

    // Start a timer to switch back to the bell image after 1 second
    Timer(const Duration(milliseconds: 1000), () {
      setState(() {
        _showGif = false; // Switch back to the bell image
      });
    });
  }

  void _toggleImages(bool isToggle) {
    setState(() {
      _showGifs = isToggle; // Show the GIF
    });

    // Start a timer to switch back to the bell image after 1 second
    Timer(const Duration(milliseconds: 1000), () {
      setState(() {
        _showGifs = false; // Switch back to the bell image
      });
    });
  }

  Future<void> playShank() async {
    String audiopath = "mandir_images/_shank.mp3";

    if (isShankPlaying) {
      // Stop the audio if it's currently playing
      await shankPlayer.stop();
      setState(() {
        isShankPlaying = false;
      });
    } else {
      // Play the audio if it's not playing
      await shankPlayer.play(AssetSource(audiopath));
      setState(() {
        isShankPlaying = true;
      });
    }
  }

  Future<void> playBellFirst() async {
    String audiopath = "mandir_images/mybell.mp3";
    await firstBellPlayer.stop(); // Stop the current playback
    await firstBellPlayer.play(AssetSource(audiopath)); // Restart the sound
  }

  Future<void> playBellSecond() async {
    String audiopath = "mandir_images/mybell.mp3";
    await secondBellPlayer.stop(); // Stop the current playback
    await secondBellPlayer.play(AssetSource(audiopath)); // Restart the sound
  }

  // Add these variables to your state class
  bool _isArtiRunning = false;
  Timer? _artiTimer;

  Future<void> toggleArti() async {
    String audioPath = "mandir_images/arti_audio.mp3";

    if (isPlaying) {
      // Stop arti and flower rain
      setState(() {
        _isThaliGifVisible = false;
        _isArtiRunning = false;
        isPlaying = false;
        _animateBell = false;
      });

      _artiTimer?.cancel();
      await artiPlayer.stop();
    } else {
      // Start arti and flower rain
      setState(() {
        _isThaliGifVisible = true;
        _isArtiRunning = true;
        isPlaying = true;
        _animateBell = true;
      });

      _artiTimer = Timer(const Duration(minutes: 3), () {
        toggleArti();
      });

      try {
        await artiPlayer.setReleaseMode(ReleaseMode.loop); //  Loop mode set
        await artiPlayer.play(AssetSource(audioPath));
      } catch (e) {
        print("Error playing audio: $e");
      }
    }
  }

  final Map<int, List<Flower>> _flowerBatches = {};
  int _batchCounter = 0;
  int flowerCount = 0;
  bool isRaining = false; // Add this flag
  Timer? _rainTimer; // Add this timer
  final List<String> flowerTypes = [
    'rose',
    'lotus',
    'marigold',
    'jasmine',
    'bluejasmine',
    'pinkjasmine',
    'redjasmine',
    'redrose',
    'yellowjasmine'
  ];

// Add these variables to your state class
  DateTime? _lastButtonPressTime;
  int _rapidPressCount = 0;
  int rapidPressThreshold = 3; // Number of quick presses to consider as "rapid"
  Duration rapidPressWindow =
      const Duration(milliseconds: 500); // Time window for rapid presses

  int _currentFlowerTypeIndex = 0; // Add this to track current flower type

  void handleButtonPress() {
    final now = DateTime.now();
    final isRapidPress = _lastButtonPressTime != null &&
        now.difference(_lastButtonPressTime!) < rapidPressWindow;

    setState(() {
      if (isRapidPress) {
        _rapidPressCount++;
      } else {
        _rapidPressCount = 1;
        // Only increment flower type on new press (not rapid press)
        _currentFlowerTypeIndex =
            (_currentFlowerTypeIndex + 1) % flowerTypes.length;
      }

      // Determine flower count based on rapid presses
      final flowerCount = _rapidPressCount >= rapidPressThreshold ? 25 : 20;

      // Create new batch immediately using only the current flower type
      _batchCounter++;
      _flowerBatches[_batchCounter] = _generateFlowers(
          flowerCount,
          MediaQuery.of(context).size.width,
          flowerTypes[_currentFlowerTypeIndex] // Pass the current flower type
          );

      _lastButtonPressTime = now;
      isRaining = true;
    });
  }

  List<Flower> _generateFlowers(
      int count, double screenWidth, String flowerType) {
    final random = Random();
    return List.generate(
        count,
        (_) => Flower(
              type: flowerType,
              left: random.nextDouble() * screenWidth,
              top: -100 - random.nextDouble() * 50,
              speed: 1 + random.nextDouble() * 3, // Slower fall
              swingSpeed: 0.2 + random.nextDouble() * 0.5, // Gentler swing
              size: 20 + random.nextDouble() * 30,
            ));
  }

  @override
  void initState() {
    super.initState();
    simulateLoading();
    getMandirChadhava();
    _pageController = PageController(initialPage: 0);
    // Listen to when the audio has completed playing
    artiPlayer.onPlayerComplete.listen((event) {
      // Automatically stop the player and toggle the state
      artiPlayer.play(AssetSource("mandir_images/arti_audio.mp3"));
      _toggleImage(true);
      _toggleImages(true);
    });
  }

  String imageChadhava = "";
  String enNameChadhava = "";
  String hiNameChadhava = "";

  Future<void> getMandirChadhava() async {
    try {
      // Fetch data from the API
      final response = await ApiService().getData(
        "${AppConstants.baseUrl}${AppConstants.mandirChadhavaUrl}${widget.id}",
      );

      if (response == null) {
        print("API response is null.");
        return;
      }

      // Extract "data" from the response
      final data = response["data"];
      if (data == null) {
        print("No data found in the response.");
        return;
      }

      // Access product information
      final product = data["products"];
      if (product != null) {
        imageChadhava = product["thumbnail"];
        enNameChadhava = product["en_name"];
        hiNameChadhava = product["hi_name"];
      } else {
        print("Product information is missing.");
      }
    } catch (error, stackTrace) {
      print("Error fetching data: $error");
      print("Stack trace: $stackTrace");
    }
  }

  void simulateLoading() async {
    // Simulate loading process
    await Future.delayed(const Duration(seconds: 3));

    // Check if the widget is still mounted before calling setState
    if (mounted) {
      setState(() {
        // Update state here
        isLoading = true;
      });
    }
  }

  var sangrahList = <SangrahModel>[
    SangrahModel("Jaap", "assets/mandir_images/sangrah_jaap.gif"),
    SangrahModel("Sahitya", "assets/mandir_images/sangrah_sahitya.png"),
    SangrahModel("Ram Shalaka", "assets/mandir_images/sangrah_ram_shalakha.png"),
    SangrahModel("Donation", "assets/mandir_images/sangrah_donation.png"),
    SangrahModel("Book Pandit", "assets/mandir_images/sangrah_pandit.png"),
    SangrahModel("Tour", "assets/mandir_images/sangrah_tour.png"),
  ];

  void handleActions(String screenName) {
    switch (screenName) {
      case "Jaap":
        Navigator.push(
            context,
            CupertinoPageRoute(
              builder: (context) => JaapView(),
            ));
        break;

      case "Ram Shalaka":
        Navigator.push(
            context,
            CupertinoPageRoute(
              builder: (context) => const RamShalaka(),
            ));
        break;

      case "Sahitya":
        Navigator.push(
            context,
            CupertinoPageRoute(
              builder: (context) => const SahityaHome(),
            ));
        break;

      case "Donation":
        Navigator.push(
            context,
            CupertinoPageRoute(
              builder: (context) => const DonationHomeView(),
            ));
        break;

      case "Book Pandit":
        Navigator.push(
            context,
            CupertinoPageRoute(
              builder: (context) => OfflinePoojaHome(
                tabIndex: 0,
              ),
            ));
        break;

      case "Tour":
        Navigator.push(
            context,
            CupertinoPageRoute(
              builder: (context) => const TourHomePage(),
            ));
        break;
    }
  }

  @override
  void dispose() {
    _rainTimer?.cancel(); // Important to prevent memory leaks

    // Dispose other resources
    firstBellPlayer.dispose();
    shankPlayer.dispose();
    artiPlayer.dispose();
    secondBellPlayer.dispose();
    _pageController.dispose();

    super.dispose();
  }

  void showBottomSheet() {
    showMaterialModalBottomSheet(
        backgroundColor: Colors.transparent,
        expand: false,
        context: context,
        builder: (context) => StatefulBuilder(
                builder: (BuildContext context, StateSetter modalSetter) {
              var screenWidth = MediaQuery.of(context).size.width;

              return Container(
                height: 450,
                padding: const EdgeInsets.all(10),
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20)),
                  color: Colors.white,
                ),
                child: SingleChildScrollView(
                  child: Consumer<LanguageProvider>(
                    builder: (BuildContext context, languageProvider,
                        Widget? child) {
                      return Column(
                        children: [
                          Container(
                            height: 3,
                            width: 100,
                            margin: const EdgeInsets.all(10),
                            color: Colors.grey.shade300,
                          ),
                          const SizedBox(
                            height: 15,
                          ),
                          Text(
                            languageProvider.language == "english"
                                ? "Mahakal.com Collection"
                                : "महाकाल.कॉम संग्रह",
                            style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                                color: Colors.orange),
                          ),
                          Text(
                            languageProvider.language == "english"
                                ? "Your Ultimate Source for All Dharmic Information"
                                : "आपकी आध्यात्मिक जानकारी का परम स्रोत",
                            style: const TextStyle(
                                color: Colors.grey,
                                fontWeight: FontWeight.w400,
                                fontSize: 14),
                          ),
                          const SizedBox(
                            height: 15,
                          ),
                          GridView.builder(
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              mainAxisSpacing: 12,
                              crossAxisSpacing: 12,
                              childAspectRatio: 1.9,
                            ),
                            itemCount: sangrahList.length,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            padding: EdgeInsets.symmetric(
                                horizontal: screenWidth * 0.02, vertical: 2),
                            itemBuilder: (context, index) {
                              return GestureDetector(
                                onTap: () {
                                  handleActions(sangrahList[index].screenName);
                                },
                                child: Container(
                                  width: 155,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(5),
                                    //color: Colors.orange,
                                    image: DecorationImage(
                                        image: AssetImage(
                                            sangrahList[index].imageUrl),
                                        fit: BoxFit.contain),
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      );
                    },
                  ),
                ),
              );
            }));
  }

  @override
  Widget build(BuildContext context) {
    var imagesList = widget.images;

    var screenHeight = MediaQuery.of(context).size.height;
    var screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      //backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            // Background Container
            Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(backgroundImages[_currentBackgroundIndex]),
                  fit: BoxFit.cover,
                ),
              ),
              height: double.infinity,
              width: double.infinity,
            ),

            // Gradient Overlay
            Positioned.fill(
              child: Stack(
                children: [
                  // Bottom to Top gradient
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          Colors.black.withOpacity(0.90), // sabse niche dark
                          Colors.black.withOpacity(0.6), // medium dark
                          //Colors.black.withOpacity(0.35), // thoda light
                          Colors.white.withOpacity(0.20), // aur light
                          Colors.transparent, // top transparent
                        ],
                        stops: const [0.0, 0.25, 0.75, 1.0],
                      ),
                    ),
                  ),

                  // Left to Right gradient
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [
                          Colors.black.withOpacity(0.4), // left dark
                          Colors.transparent, // center clear
                          Colors.black.withOpacity(0.4), // right dark
                        ],
                        stops: const [0.0, 0.5, 1.0],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // God Images
            PageView.builder(
              controller: _pageController,
              physics: const BouncingScrollPhysics(),
              pageSnapping: true,
              scrollDirection: Axis.vertical,
              onPageChanged: (index) {
                // No explicit jump logic needed for seamless infinite scrolling
                final actualIndex = index % imagesList!.length;
                print("Currently displaying image at index: $actualIndex");
              },
              itemBuilder: (context, index) {
                // Calculate the display index dynamically
                final displayIndex = index % imagesList!.length;

                return Stack(
                  children: [
                    // Display the image
                    imagesList.isEmpty
                        ? const Center(
                            child: CircularProgressIndicator(
                              color: Colors.orange,
                            ),
                          )
                        : widget.isImage
                            ? SizedBox(
                                width: double.infinity,
                                height: double.infinity,
                                child: CachedNetworkImage(
                                  imageUrl: imagesList[displayIndex],
                                  fit: BoxFit.contain,
                                  placeholder: (context, url) => const Center(
                                    child: CircularProgressIndicator(
                                      strokeWidth: 1.5,
                                      color: Colors.orange,
                                    ),
                                  ),
                                  //placeholder: (context, url) => placeholderImage(),
                                  //errorWidget: (context, url, error) => NoImageWidget(),
                                ),
                              )
                            : const SizedBox()
                  ],
                );
              },
            ),

            Center(
                child: Stack(
              children: [
                // Display all active flower batches
                for (final batch in _flowerBatches.values)
                  FlowerRain(
                    flowers: batch,
                    isActive: isRaining,
                  ),

                //Show flower rain either during arti OR when button pressed
                if (_isArtiRunning)
                  FlowerArtiRain(
                    flowerCount: _isArtiRunning
                        ? 50
                        : flowerCount, // More flowers during arti
                    flowerTypes: flowerTypes,
                    isContinuous: _isArtiRunning, // Pass continuous mode flag
                  ),
              ],
            )),

            // Toran at the top
            Positioned(
              top: 0,
              child: SizedBox(
                height: screenHeight * 0.3,
                width: screenWidth,
                child: Image.asset(
                  toranImages[_currentToranIndex],
                  fit: BoxFit.fill,
                ),
              ),
            ),

            // Bells
            if (_animateBell) ...[

              Positioned(
                bottom: screenHeight * 0.520,
                // left: screenWidth * 0.10,
                child: Image.asset(
                  bellGif,
                  height: 100,
                ),
              ),

              Positioned(
                bottom: screenHeight * 0.520,
                left: screenWidth * 0.74,
                child: Image.asset(
                  bellGifs,
                  height: 100,
                ),
              ),

            ] else ...[
              _showGif
                  ? Positioned(
                      bottom: screenHeight * 0.520,
                      // left: screenWidth * 0.10,
                      child: Image.asset(
                        bellGif,
                        height: 100,
                      ))

                  : Positioned(
                      bottom: screenHeight * 0.520,
                      left: screenWidth * 0.10,
                      child: Consumer<AudioPlayerManager>(
                        builder: (BuildContext context, audioManager,
                            Widget? child) {
                          return GestureDetector(
                              onTap: () {
                                _toggleImage(true);
                                playBellFirst();
                                audioManager.pauseMusic();
                              },
                              child: Image.asset(
                                bellImage,
                                height: 100,
                              ));
                        },
                      ),
                    ),
              _showGifs
                  ? Positioned(
                      bottom: screenHeight * 0.520,
                      left: screenWidth * 0.70,
                      child: Image.asset(
                        bellGif,
                        height: 100,
                      ))
                  : Positioned(
                      bottom: screenHeight * 0.520,
                      left: screenWidth * 0.79,
                      child: Consumer<AudioPlayerManager>(
                        builder: (BuildContext context, audioManager,
                            Widget? child) {
                          return GestureDetector(
                              onTap: () {
                                _toggleImages(true);
                                playBellSecond();
                                audioManager.pauseMusic();
                              },
                              child: Image.asset(
                                bellImage,
                                height: 100,
                              ));
                        },
                      ),
                    ),
            ],

            //   Overlay for buttons
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              bottom: 0,
              child: Stack(
                children: [
                  // Round thali
                  Center(
                    child: Padding(
                      padding: EdgeInsets.only(top: screenWidth * 0.2),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _isThaliGifVisible
                              ? Image.asset(
                                  "assets/mandir_images/thali_round.gif",
                                  height: 500,
                                )
                              : Container(),
                        ],
                      ),
                    ),
                  ),

                  // left side buttons
                  Consumer<AudioPlayerManager>(
                    builder:
                        (BuildContext context, audioManager, Widget? child) {
                      return Positioned(
                        left: 5,
                        top: 262,
                        child: Column(
                          children: [
                            // Sangrah Buttons
                            Column(
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    // Change background and images on tap
                                    setState(() {
                                      showBottomSheet();
                                    });
                                  },
                                  child: Container(
                                    width: screenWidth * 0.14,
                                    height: screenWidth * 0.15,
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                          color: Theme.of(context).primaryColor,
                                          width: 2),
                                      color: Colors.orange.withOpacity(0.4),
                                      borderRadius: const BorderRadius.only(
                                        topLeft: Radius.circular(100),
                                        topRight: Radius.circular(100),
                                      ),
                                    ),
                                    child: ClipRRect(
                                      borderRadius: const BorderRadius.only(
                                        topLeft: Radius.circular(100),
                                        topRight: Radius.circular(100),
                                      ),
                                      child: Image.asset(
                                          "assets/mandir_images/sangrah_button.gif"),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Container(
                                  height: screenWidth * 0.06,
                                  width: screenWidth * 0.19,
                                  padding: const EdgeInsets.only(left: 2),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).primaryColor,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Center(
                                    child: Consumer<LanguageProvider>(
                                      builder: (BuildContext context,
                                          languageProvider, Widget? child) {
                                        return AutoScrollText(
                                          text: languageProvider.language ==
                                                  "english"
                                              ? "Mantras, books, Ram Shalaka, donations, priest booking, and spiritual journeys"
                                              : "मंत्र, पुस्तकें, राम शलाका, दान, पंडित बुकिंग और धार्मिक यात्राएँ",
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black,
                                          ),
                                          maxLines: 1,
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(
                              height: 15,
                            ),

                            // Column(
                            //   children: [
                            //     GestureDetector(
                            //       onTap: () {
                            //
                            //       },
                            //       child: Container(
                            //         width: screenWidth * 0.12,
                            //         height: screenWidth * 0.12,
                            //         decoration: BoxDecoration(
                            //           border:
                            //           Border.all(color: Colors.white, width: 1),
                            //           color: Colors.orange.shade800
                            //               .withOpacity(0.4), // highlight color
                            //           borderRadius: BorderRadius.circular(300),
                            //         ),
                            //         child: Image.asset("assets/mandir_images/sangrah_button.gif"),
                            //       ),
                            //     ),
                            //     const SizedBox(height: 3),
                            //     Container(
                            //       height: screenWidth * 0.05,
                            //       width: screenWidth * 0.14,
                            //       decoration: BoxDecoration(
                            //           color: Colors.orangeAccent,
                            //           borderRadius: BorderRadius.circular(6)),
                            //       child: Center(
                            //         child: Consumer<LanguageProvider>(
                            //           builder: (BuildContext context,
                            //               languageProvider, Widget? child) {
                            //             return Text(
                            //               languageProvider.language == "english"
                            //                   ? "Sangrah"
                            //                   : "संग्रह",
                            //               style: const TextStyle(
                            //                   fontWeight: FontWeight.bold,
                            //                   color: Colors.black),
                            //             );
                            //           },
                            //         ),
                            //       ),
                            //     ),
                            //   ],
                            // ),

                            // Flower Button
                            Column(
                              children: [
                                IgnorePointer(
                                  ignoring:
                                      false, // Allow interaction with the buttons
                                  child: Container(
                                      width: screenWidth * 0.12,
                                      height: screenWidth * 0.12,
                                      decoration: BoxDecoration(
                                          border: Border.all(
                                              color: Colors.white, width: 1),
                                          borderRadius:
                                              BorderRadius.circular(300),
                                          image: const DecorationImage(
                                              image: AssetImage(
                                                  "assets/mandir_images/flowerbuttonanimation.gif"))),
                                      child: GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            handleButtonPress();
                                          });
                                        },
                                        child: Container(
                                          height: 20,
                                          width: 30,
                                          color: Colors.transparent,
                                          // color: Colors.green,
                                        ),
                                      )),
                                ),
                                const SizedBox(height: 3),
                                Container(
                                  height: screenWidth * 0.05,
                                  width: screenWidth * 0.14,
                                  decoration: BoxDecoration(
                                      color: Colors.orangeAccent,
                                      borderRadius: BorderRadius.circular(6)),
                                  child: Center(
                                    child: Consumer<LanguageProvider>(
                                      builder: (BuildContext context,
                                          languageProvider, Widget? child) {
                                        return Text(
                                          languageProvider.language == "english"
                                              ? "Flower"
                                              : "पुष्प",
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(
                              height: 15,
                            ),

                            // Arti Button
                            Column(
                              children: [
                                IgnorePointer(
                                  ignoring:
                                      false, // Allow interaction with the buttons
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        audioManager.pauseMusic();
                                        toggleArti();
                                      });
                                    },
                                    child: Container(
                                      width: screenWidth * 0.12,
                                      height: screenWidth * 0.12,
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                            color: Colors.white, width: 1),
                                        color: Colors.orange.shade800
                                            .withOpacity(
                                                0.4), // highlight color
                                        borderRadius:
                                            BorderRadius.circular(300),
                                      ),
                                      child: Image.asset(
                                          "assets/mandir_images/artibuttonanimation.gif"),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Container(
                                  height: screenWidth * 0.05,
                                  width: screenWidth * 0.14,
                                  decoration: BoxDecoration(
                                      color: Colors.orangeAccent,
                                      borderRadius: BorderRadius.circular(6)),
                                  child: Center(
                                    child: Consumer<LanguageProvider>(
                                      builder: (BuildContext context,
                                          languageProvider, Widget? child) {
                                        return Text(
                                          languageProvider.language == "english"
                                              ? "Aarti"
                                              : "आरती",
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(
                              height: 15,
                            ),

                            // Shank Button
                            Column(
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      playShank();
                                    });
                                  },
                                  child: Container(
                                    width: screenWidth * 0.12,
                                    height: screenWidth * 0.12,
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                          color: Colors.white, width: 1),
                                      color: Colors.orange.shade300
                                          .withOpacity(0.4), // highlight color
                                      borderRadius: BorderRadius.circular(300),
                                    ),
                                    child: Image.asset(
                                        "assets/mandir_images/shankbuttonanimation.gif"),
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Container(
                                  height: screenWidth * 0.05,
                                  width: screenWidth * 0.14,
                                  decoration: BoxDecoration(
                                      color: Colors.orangeAccent,
                                      borderRadius: BorderRadius.circular(6)),
                                  child: Center(
                                    child: Consumer<LanguageProvider>(
                                      builder: (BuildContext context,
                                          languageProvider, Widget? child) {
                                        return Text(
                                          languageProvider.language == "english"
                                              ? "Shankh"
                                              : "शंख",
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(
                              height: 15,
                            ),
                          ],
                        ),
                      );
                    },
                  ),

                  // Right side Buttons
                  Positioned(
                    right: 5,
                    top: 262,
                    child: Column(
                      children: [
                        Column(
                          children: [
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  CupertinoPageRoute(
                                    builder: (context) =>
                                        MandirChadhawa(id: "${widget.id}"),
                                  ),
                                );
                              },
                              child: Container(
                                width: screenWidth * 0.14,
                                height: screenWidth * 0.15,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                      color: Theme.of(context).primaryColor,
                                      width: 2),
                                  color: Colors.orange.withOpacity(0.4),
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(100),
                                    topRight: Radius.circular(100),
                                  ),
                                ),
                                child: ClipRRect(
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(100),
                                    topRight: Radius.circular(100),
                                  ),
                                  child: CachedNetworkImage(
                                    imageUrl: imageChadhava,
                                    fit: BoxFit.fill,
                                    placeholder: (context, url) =>
                                        placeholderImage(),
                                    errorWidget: (context, url, error) =>
                                        placeholderImage(),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Container(
                              height: screenWidth * 0.06,
                              width: screenWidth * 0.19,
                              padding: const EdgeInsets.only(left: 2),
                              decoration: BoxDecoration(
                                color: Theme.of(context).primaryColor,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Center(
                                child: Consumer<LanguageProvider>(
                                  builder: (BuildContext context,
                                      languageProvider, Widget? child) {
                                    return AutoScrollText(
                                      text:
                                          languageProvider.language == "english"
                                              ? enNameChadhava
                                              : hiNameChadhava,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                      maxLines: 1,
                                    );
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 15,
                        ),

                        // Sangeet button
                        Column(
                          children: [
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    CupertinoPageRoute(
                                      builder: (context) => SangeetView(
                                        widget.hiName == 13
                                            ? "12 ज्योतिर्लिंग"
                                            : widget.hiName ?? '',
                                        godName:
                                            widget.enName == "12 Jyotirlinga"
                                                ? "Shiv Ji"
                                                : widget.enName ?? '',
                                      ),
                                    ));
                              },
                              child: Container(
                                width: screenWidth * 0.12,
                                height: screenWidth * 0.12,
                                decoration: BoxDecoration(
                                  border:
                                      Border.all(color: Colors.white, width: 1),
                                  color: Colors.orange.shade800
                                      .withOpacity(0.4), // highlight color
                                  borderRadius: BorderRadius.circular(300),
                                ),
                                child: Image.asset(
                                    "assets/mandir_images/bhajanbutton.png"),
                              ),
                            ),
                            const SizedBox(height: 3),
                            Container(
                              height: screenWidth * 0.05,
                              width: screenWidth * 0.14,
                              decoration: BoxDecoration(
                                  color: Colors.orangeAccent,
                                  borderRadius: BorderRadius.circular(6)),
                              child: Center(
                                child: Consumer<LanguageProvider>(
                                  builder: (BuildContext context,
                                      languageProvider, Widget? child) {
                                    return Text(
                                      languageProvider.language == "english"
                                          ? "Bhajan"
                                          : "भजन",
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black),
                                    );
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 15,
                        ),

                        // Toran Button
                        Column(
                          children: [
                            GestureDetector(
                              onTap: () {
                                // Change background and images on tap
                                setState(() {
                                  _currentToranIndex =
                                      (_currentToranIndex + 1) %
                                          toranImages.length;
                                });
                              },
                              child: Container(
                                width: screenWidth * 0.12,
                                height: screenWidth * 0.12,
                                decoration: BoxDecoration(
                                  border:
                                      Border.all(color: Colors.white, width: 1),
                                  color: Colors.orange.shade800
                                      .withOpacity(0.4), // highlight color
                                  borderRadius: BorderRadius.circular(300),
                                ),
                                child: Image.asset(
                                    "assets/mandir_images/buttonanimate.gif"),
                              ),
                            ),
                            const SizedBox(height: 3),
                            Container(
                              height: screenWidth * 0.05,
                              width: screenWidth * 0.14,
                              decoration: BoxDecoration(
                                  color: Colors.orangeAccent,
                                  borderRadius: BorderRadius.circular(6)),
                              child: Center(
                                child: Consumer<LanguageProvider>(
                                  builder: (BuildContext context,
                                      languageProvider, Widget? child) {
                                    return Text(
                                      languageProvider.language == "english"
                                          ? "Toran"
                                          : "तोरण",
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black),
                                    );
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 15,
                        ),

                        // BackGround Button
                        Column(
                          children: [
                            GestureDetector(
                              onTap: () {
                                // Change background and images on tap
                                setState(() {
                                  _currentBackgroundIndex =
                                      (_currentBackgroundIndex + 1) %
                                          backgroundImages.length;
                                });
                              },
                              child: Container(
                                width: screenWidth * 0.12,
                                height: screenWidth * 0.12,
                                decoration: BoxDecoration(
                                  border:
                                      Border.all(color: Colors.white, width: 1),
                                  color: Colors.orange.shade300
                                      .withOpacity(0.4), // highlight color
                                  borderRadius: BorderRadius.circular(300),
                                ),
                                child: Image.asset(
                                    "assets/mandir_images/templebuttonanimation.gif"),
                              ),
                            ),
                            const SizedBox(height: 3),
                            Container(
                              height: screenWidth * 0.05,
                              width: screenWidth * 0.14,
                              decoration: BoxDecoration(
                                  color: Colors.orangeAccent,
                                  borderRadius: BorderRadius.circular(6)),
                              child: Center(
                                child: Consumer<LanguageProvider>(
                                  builder: (BuildContext context,
                                      languageProvider, Widget? child) {
                                    return Text(
                                      languageProvider.language == "english"
                                          ? "Mandir"
                                          : "मंदिर",
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black),
                                    );
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Puja Thali
                  _isThaliGifVisible
                      ? Container()
                      : Consumer<AudioPlayerManager>(
                          builder: (BuildContext context, audioManager,
                              Widget? child) {
                            return Positioned(
                              bottom: audioManager.isMusicBarVisible ? 60 : 90,
                              left: 0,
                              right: 0,
                              child: Center(
                                child: GestureDetector(
                                  onTap: () {}, // Rotate when tapped
                                  child: Draggable(
                                    feedback: Image.asset(
                                      'assets/mandir_images/silverthali.gif',
                                      height: 75,
                                    ),
                                    childWhenDragging: Container(), // Optional
                                    onDragStarted: () {
                                      // Optional callback when drag starts
                                    },
                                    onDragUpdate: (details) {
                                      // Update the position of the image based on the drag update
                                      setState(() {
                                        _offset = details.globalPosition;
                                      });
                                    },
                                    onDragEnd: (details) {
                                      // Optional callback when drag ends
                                    },
                                    child: Image.asset(
                                      "assets/mandir_images/silverthali.gif",
                                      //thaliImages[_currentThaliIndex],
                                      height: 65,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                  // Other buttons...
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Consumer<AudioPlayerManager>(
        builder: (context, audioManager, child) {
          if (audioManager.isMusicBarVisible) {
            return MusicBar(
              enName: widget.enName,
              hiName: widget.hiName,
              animateBell: _animateBell,
            );
          } else {
            return const SizedBox.shrink();
          }
        },
      ),
    );
  }
}

class FlowerRain extends StatefulWidget {
  final List<Flower> flowers;
  final bool isActive;

  const FlowerRain({
    required this.flowers,
    required this.isActive,
    super.key,
  });

  @override
  _FlowerRainState createState() => _FlowerRainState();
}

class _FlowerRainState extends State<FlowerRain>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<Flower> _activeFlowers = [];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..addListener(_updateFlowers);

    // Start with the initial flowers
    _activeFlowers.addAll(widget.flowers);
  }

  @override
  void didUpdateWidget(FlowerRain oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Add new flowers when the widget updates
    if (widget.isActive && widget.flowers != oldWidget.flowers) {
      _activeFlowers.addAll(widget.flowers);
    }

    // Control animation based on activity
    if (widget.isActive) {
      _controller.repeat();
    } else {
      _controller.stop();
    }
  }

  void _updateFlowers() {
    final screenHeight = MediaQuery.of(context).size.height;

    setState(() {
      // Update all flowers
      for (final flower in _activeFlowers) {
        flower.update();
      }

      // Remove flowers that are out of screen
      _activeFlowers
          .removeWhere((flower) => flower.top > screenHeight + flower.size);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: _activeFlowers.map((flower) => flower.build()).toList(),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class Flower {
  final String type;
  double left;
  double top;
  final double speed;
  final double swingSpeed;
  final double size;
  double swingOffset = 0;
  double swingPhase;

  Flower({
    required this.type,
    required this.left,
    required this.top,
    required this.speed,
    required this.swingSpeed,
    required this.size,
  }) : swingPhase = Random().nextDouble() * 2 * pi;

  void update() {
    top += speed;
    swingPhase += swingSpeed * 0.01;
    swingOffset = sin(swingPhase) * 10;
  }

  Widget build() {
    return Positioned(
      left: left + swingOffset,
      top: top,
      child: Image.asset(
        "assets/mandir_images/$type.png",
        width: size,
        height: size,
        fit: BoxFit.contain,
      ),
    );
  }
}

class FlowerArtiRain extends StatefulWidget {
  final int flowerCount;
  final List<String> flowerTypes;
  final bool isContinuous;
  final double speedMultiplier;

  const FlowerArtiRain({
    super.key,
    required this.flowerCount,
    required this.flowerTypes,
    this.isContinuous = false,
    this.speedMultiplier = 3.0,
  });

  @override
  _FlowerArtiRainState createState() => _FlowerArtiRainState();
}

class _FlowerArtiRainState extends State<FlowerArtiRain>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  List<Flower> flowers = [];
  final Random _random = Random();
  late String
      _currentSessionFlowerType; // Stores the flower type for current session

  @override
  void initState() {
    super.initState();
    // Select a random type for this session
    _currentSessionFlowerType =
        widget.flowerTypes[_random.nextInt(widget.flowerTypes.length)];

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeFlowers();
      setState(() {});
    });
  }

  void _initializeFlowers() {
    final screenWidth = MediaQuery.of(context).size.width;
    flowers = List.generate(
      widget.flowerCount,
      (_) => _createFlower(
          screenWidth, _currentSessionFlowerType), // Use the session's type
    );
  }

  Flower _createFlower(double screenWidth, String flowerType) {
    return Flower(
      type: flowerType, // Use the provided type
      left: _random.nextDouble() * screenWidth,
      top: -50 - _random.nextDouble() * 100,
      speed: (1 + _random.nextDouble() * 3) * widget.speedMultiplier,
      swingSpeed: 0.5 + _random.nextDouble() * 1.5,
      size: 20 + _random.nextDouble() * 30,
    );
  }

  @override
  void didUpdateWidget(FlowerArtiRain oldWidget) {
    super.didUpdateWidget(oldWidget);

    // When arti starts (isContinuous becomes true), select a new type for this session
    if (widget.isContinuous && !oldWidget.isContinuous) {
      _currentSessionFlowerType =
          widget.flowerTypes[_random.nextInt(widget.flowerTypes.length)];
      flowers.clear(); // Clear old flowers
      _initializeFlowers(); // Initialize with new type
    }

    if (widget.flowerCount != oldWidget.flowerCount && !widget.isContinuous) {
      final screenWidth = MediaQuery.of(context).size.width;
      final newFlowers = List.generate(
        widget.flowerCount,
        (_) => _createFlower(screenWidth, _currentSessionFlowerType),
      );
      flowers.addAll(newFlowers);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        // For continuous mode, keep adding new flowers of the current session type
        if (widget.isContinuous && flowers.length < widget.flowerCount * 2) {
          final screenWidth = MediaQuery.of(context).size.width;
          flowers.add(_createFlower(screenWidth, _currentSessionFlowerType));
        }

        // Update all flowers
        for (final flower in flowers) {
          flower.update();
        }

        // Remove flowers that have fallen off screen
        flowers
            .removeWhere((flower) => flower.top > screenHeight + flower.size);

        return Stack(
          clipBehavior: Clip.none,
          children: flowers.map((flower) => flower.build()).toList(),
        );
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class AutoScrollText extends StatefulWidget {
  final String text;
  final TextStyle style;
  final int maxLines;

  const AutoScrollText({
    super.key,
    required this.text,
    this.style = const TextStyle(),
    this.maxLines = 1,
  });

  @override
  _AutoScrollTextState createState() => _AutoScrollTextState();
}

class _AutoScrollTextState extends State<AutoScrollText>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  double _containerWidth = 0;
  double _textWidth = 0;
  bool _needsScroll = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 12),
      vsync: this,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _calculateTextDimensions();
    });
  }

  void _calculateTextDimensions() {
    final textPainter = TextPainter(
      text: TextSpan(text: widget.text, style: widget.style),
      textDirection: TextDirection.ltr,
      maxLines: widget.maxLines,
    )..layout(maxWidth: double.infinity);

    _textWidth = textPainter.width;
    _needsScroll = _textWidth > _containerWidth;

    if (_needsScroll) {
      _animation = Tween<double>(
        begin: _containerWidth,
        end: -_textWidth - 20, // add gap
      ).animate(_controller);

      _controller.repeat();
    } else {
      _controller.stop();
    }

    setState(() {});
  }

  @override
  void didUpdateWidget(AutoScrollText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.text != widget.text || oldWidget.style != widget.style) {
      _calculateTextDimensions();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (_containerWidth != constraints.maxWidth) {
          _containerWidth = constraints.maxWidth;
          WidgetsBinding.instance
              .addPostFrameCallback((_) => _calculateTextDimensions());
        }

        return SizedBox(
          width: _containerWidth,
          height: widget.style.fontSize! * 1.5,
          child: ClipRect(
            // ✅ This prevents overflow
            child: _needsScroll
                ? AnimatedBuilder(
                    animation: _animation,
                    builder: (context, child) {
                      return Stack(
                        children: [
                          Positioned(
                            left: _animation.value,
                            child: Text(
                              widget.text,
                              style: widget.style,
                              maxLines: widget.maxLines,
                            ),
                          ),
                          if (_animation.value < -_textWidth / 2)
                            Positioned(
                              left: _animation.value + _textWidth + 20,
                              child: Text(
                                widget.text,
                                style: widget.style,
                                maxLines: widget.maxLines,
                              ),
                            ),
                        ],
                      );
                    },
                  )
                : Text(
                    widget.text,
                    style: widget.style,
                    maxLines: widget.maxLines,
                    overflow: TextOverflow.ellipsis,
                  ),
          ),
        );
      },
    );
  }
}
