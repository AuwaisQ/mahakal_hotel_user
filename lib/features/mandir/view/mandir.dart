import 'dart:async';
import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:provider/provider.dart';
import '../../../main.dart';
import '../../../utill/app_constants.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../youtube_vedios/view/dynamic_tabview/grid_view/YoutubeGridView.dart';
import '../api_service/api_service.dart';
import '../../donation/controller/lanaguage_provider.dart';
import 'package:http/http.dart' as http;
// import '../controller/language_manager.dart';
import '../model/mandir_model.dart';
import 'mandir_home_page.dart';

class Mandir extends StatefulWidget {
  final int tabIndex;
  const Mandir({
    super.key,
    required this.tabIndex,
  });

  @override
  State<Mandir> createState() => _MandirState();
}

class _MandirState extends State<Mandir> with TickerProviderStateMixin {
  late TabController _tabController;
  TabController? tabController;
  late PageController _pageController;
  late Timer _timer;
  int _elapsedSeconds = 0;
  double latiTude = 0.0;
  double longiTude = 0.0;
  String _venueAddressController = "";

  String userToken = "";
  bool isLoading = false;
  late int selectedIndex;
  List<MandirData> mandirTabs = [];
  List<String> images = [
    ""
    //"https://allpngfree.com/apf-prod-storage-api/storag…png-images-download-free-thumbnail-1645706276.jpg"
  ];

  List<MandirData>? cachedMandirTabs;
  DateTime? lastFetchTime;
  Duration cacheValidity = const Duration(minutes: 10);

  @override
  void initState() {
    super.initState();
    selectedIndex = widget.tabIndex;
    tabController = TabController(length: 10, vsync: this);
    userToken =
        Provider.of<AuthController>(Get.context!, listen: false).getUserToken();
    latiTude =
        Provider.of<AuthController>(Get.context!, listen: false).latitude;
    longiTude =
        Provider.of<AuthController>(Get.context!, listen: false).longitude;

    _startTimer();
    _pageController = PageController(viewportFraction: 0.9);
    getLocation(latiTude, longiTude);

    // Use cached data instantly if available
    if (cachedMandirTabs != null && cachedMandirTabs!.isNotEmpty) {
      mandirTabs = cachedMandirTabs!;
      _tabController = TabController(
          length: mandirTabs.length,
          vsync: this,
          initialIndex: widget.tabIndex);
      _pageController = PageController(initialPage: widget.tabIndex);
      selectedIndex = widget.tabIndex;
      addTabListener();
    }

    // Fetch updated data only if cache is old or empty
    if (cachedMandirTabs == null ||
        cachedMandirTabs!.isEmpty ||
        lastFetchTime == null ||
        DateTime.now().difference(lastFetchTime!) > cacheValidity) {
      getTabs(widget.tabIndex);
    }
  }

  void addTabListener() {
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        setState(() {
          selectedIndex = _tabController.index;
          _pageController.jumpToPage(_tabController.index);
        });
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    _tabController.dispose();
    _pageController.dispose();
    timeCounting();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _elapsedSeconds++;
      });
    });
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
      // // _landMarkController.text = place.street!;
      _venueAddressController = place.locality!;
      print("venue address $_venueAddressController");
    }
  }

  Future<void> timeCounting() async {
    final response = await http.post(
      Uri.parse(AppConstants.baseUrl + AppConstants.bhagwanUrl),
      headers: {
        'Authorization': 'Bearer $userToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(
        {
          "location": _venueAddressController,
          "count": "0",
          "duration": "${_elapsedSeconds}s",
        },
      ),
    );
    print("mandir count post api: ${response.body}");
    var data = jsonDecode(response.body);
    if (data["status"] == 200) {
    } else {
      print("failed api status 400");
    }
  }

  Future<void> getTabs(int tabIndex) async {
    setState(() => isLoading = true);

    try {
      final res = await ApiService()
          .getData("${AppConstants.baseUrl}${AppConstants.mandirTabsUrl}");

      // if (res != null) {
      //   final tabsCategory = MandirModel.fromJson(res);
      //
      //   if (tabsCategory.data != null) {
      //     setState(() {
      //       mandirTabs = tabsCategory.data;
      //       cachedMandirTabs = mandirTabs; // 🔁 cache the data
      //       lastFetchTime = DateTime.now(); // ⏱️ track freshness
      //
      //       _tabController = TabController(
      //         length: mandirTabs.length,
      //         vsync: this,
      //         initialIndex: tabIndex,
      //       );
      //
      //       _pageController = PageController(initialPage: tabIndex);
      //       selectedIndex = tabIndex;
      //
      //       addTabListener();
      //     });
      //   }
      // }

      if (res != null) {
        final tabsCategory = MandirModel.fromJson(res);

        final today = DateTime.now();
        final formattedToday =
            "${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}";

        // 🔁 Temporary list to store matching and non-matching tabs
        List<MandirData> matchingTabs = [];
        List<MandirData> otherTabs = [];

        for (var tab in tabsCategory.data) {
          if (tab.date == formattedToday && tab.eventImage != null) {
            // 🖼️ Insert event_image at top of images
            tab.images.insert(0, tab.eventImage!);
            matchingTabs.add(tab); // Add to top list
          } else {
            otherTabs.add(tab); // ➕ Keep in normal order
          }
        }

        // Combine lists: matching first, then others
        final sortedTabs = [...matchingTabs, ...otherTabs];

        setState(() {
          mandirTabs = sortedTabs;
          cachedMandirTabs = mandirTabs;
          lastFetchTime = DateTime.now();

          _tabController = TabController(
            length: mandirTabs.length,
            vsync: this,
            initialIndex: tabIndex,
          );

          print("My Mandir Image ${mandirTabs[0].images}");

          _pageController = PageController(initialPage: tabIndex);
          selectedIndex = tabIndex;

          addTabListener();
        });
      }
    } catch (e) {
      print('Error fetching tabs: $e');
    } finally {
      setState(() => isLoading = false);
    }
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
                height: 700,
                padding: const EdgeInsets.all(10),
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20)),
                  color: Colors.white,
                ),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Container(
                        height: 4,
                        width: 100,
                        margin: const EdgeInsets.all(10),
                        color: Colors.grey,
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      GridView.builder(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 4,
                          crossAxisSpacing: 4,
                          childAspectRatio: 0.85,
                        ),
                        itemCount: mandirTabs.length,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        padding: EdgeInsets.symmetric(
                            horizontal: screenWidth * 0.02),
                        itemBuilder: (context, index) {
                          return GestureDetector(
                              onTap: () {
                                modalSetter(() {
                                  selectedIndex = index;
                                });
                                // Update the PageController to jump to the selected tab's page
                                _pageController.jumpToPage(index);
                                getTabs(index);
                                Navigator.pop(context);
                              },
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: selectedIndex == index
                                        ? [
                                            Colors.orange.shade50,
                                            Colors.orange.shade100
                                          ]
                                        : [Colors.white, Colors.grey.shade50],
                                  ),
                                  border: Border.all(
                                    color: selectedIndex == index
                                        ? Colors.deepOrange.shade400
                                        : Colors.grey.shade300,
                                    width: selectedIndex == index ? 1.5 : 1,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.15),
                                      blurRadius: 15,
                                      spreadRadius: 2,
                                      offset: const Offset(0, 6),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    // Image with elegant frame
                                    Container(
                                      height: 130,
                                      width: 180,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(12),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.orange.withOpacity(
                                                selectedIndex == index
                                                    ? 0.3
                                                    : 0.1),
                                            blurRadius: 12,
                                            spreadRadius: 3,
                                          )
                                        ],
                                      ),
                                      child: Stack(
                                        children: [
                                          // Main Image with overlay
                                          ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            child: Stack(
                                              children: [
                                                Image.network(
                                                  mandirTabs[index].thumbnail,
                                                  fit: BoxFit.cover,
                                                  width: double.infinity,
                                                  height: double.infinity,
                                                  loadingBuilder: (context,
                                                      child, loadingProgress) {
                                                    if (loadingProgress ==
                                                        null) {
                                                      return child;
                                                    }
                                                    return Container(
                                                      decoration: BoxDecoration(
                                                        gradient:
                                                            LinearGradient(
                                                          begin: Alignment
                                                              .topCenter,
                                                          end: Alignment
                                                              .bottomCenter,
                                                          colors: [
                                                            Colors
                                                                .grey.shade100,
                                                            Colors.grey.shade200
                                                          ],
                                                        ),
                                                      ),
                                                      child: Center(
                                                        child:
                                                            CircularProgressIndicator(
                                                          value: loadingProgress
                                                                      .expectedTotalBytes !=
                                                                  null
                                                              ? loadingProgress
                                                                      .cumulativeBytesLoaded /
                                                                  loadingProgress
                                                                      .expectedTotalBytes!
                                                              : null,
                                                          strokeWidth: 2,
                                                          color: Colors.orange,
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                  errorBuilder: (context, error,
                                                          stackTrace) =>
                                                      Container(
                                                    decoration: BoxDecoration(
                                                      gradient: LinearGradient(
                                                        begin:
                                                            Alignment.topCenter,
                                                        end: Alignment
                                                            .bottomCenter,
                                                        colors: [
                                                          Colors.grey.shade200,
                                                          Colors.grey.shade300
                                                        ],
                                                      ),
                                                    ),
                                                    child: const Icon(
                                                        Icons.temple_hindu,
                                                        size: 50,
                                                        color: Colors.orange),
                                                  ),
                                                ),
                                                Container(
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            12),
                                                    gradient: LinearGradient(
                                                      begin:
                                                          Alignment.topCenter,
                                                      end: Alignment
                                                          .bottomCenter,
                                                      colors: [
                                                        Colors.black
                                                            .withOpacity(0.1),
                                                        Colors.black
                                                            .withOpacity(0.05),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),

                                          // Golden border overlay when selected
                                          if (selectedIndex == index)
                                            Container(
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                                border: Border.all(
                                                  color: Colors.orange
                                                      .withOpacity(0.8),
                                                  width: 2.5,
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),

                                    const SizedBox(height: 14),

                                    // Temple Name with language support
                                    Consumer<LanguageProvider>(
                                      builder: (context, languageProvider, _) {
                                        return Column(
                                          children: [
                                            Text(
                                              languageProvider.language ==
                                                      "english"
                                                  ? mandirTabs[index].enName
                                                  : mandirTabs[index].hiName,
                                              style: TextStyle(
                                                fontWeight: FontWeight.w600,
                                                fontSize: screenWidth * 0.042,
                                                color:
                                                    Colors.deepOrange.shade900,
                                                height: 1.2,
                                              ),
                                              textAlign: TextAlign.center,
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            const SizedBox(height: 4),
                                            Container(
                                              width: 40,
                                              height: 3,
                                              decoration: BoxDecoration(
                                                color: selectedIndex == index
                                                    ? Colors.deepOrange.shade400
                                                    : Colors.orange.shade200,
                                                borderRadius:
                                                    BorderRadius.circular(3),
                                              ),
                                            ),
                                          ],
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ));
                        },
                      ),
                    ],
                  ),
                ),
              );
            }));
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    List<Widget> tabs = [
      ...mandirTabs.map((cat) => Tab(
            child: Container(
              height: 40,
              width: 40,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                border: selectedIndex == mandirTabs.indexOf(cat)
                    ? Border.all(color: Colors.black, width: 3)
                    : Border.all(color: Colors.white),
                color: Colors.white,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: CachedNetworkImage(
                  imageUrl: cat.thumbnail,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => placeholderImage(),
                  errorWidget: (context, url, error) => placeholderImage(),
                ),
              ),
            ),
          )),
    ];

    return PopScope(
        canPop: true,
        onPopInvoked: (bool didPop) async {
          timeCounting(); // Action to perform on back pressed
        },
        child: Scaffold(
            //backgroundColor: Colors.white,
            appBar: AppBar(
              backgroundColor: Theme.of(context).primaryColor,
              centerTitle: true,
              title: Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: Colors.grey.withOpacity(0.5)),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: screenWidth * 0.03,
                      vertical: screenWidth * 0.01),
                  child: Consumer<LanguageProvider>(
                    builder: (BuildContext context, languageProvider,
                        Widget? child) {
                      return mandirTabs.isNotEmpty
                          ? Text(
                              languageProvider.language == "english"
                                  ? mandirTabs[selectedIndex].enName
                                  : mandirTabs[selectedIndex].hiName,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  fontSize: screenWidth * 0.05),
                            )
                          : const Text(
                              "Mandir",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white),
                            );
                    },
                  ),
                ),
              ),
              leading: InkWell(
                  onTap: () {
                    timeCounting();
                    Navigator.pop(context);
                  },
                  child: Icon(
                    CupertinoIcons.house_fill,
                    size: 27,
                    color: Theme.of(context).cardColor,
                  )),
              actions: [
                Consumer<LanguageProvider>(
                  builder:
                      (BuildContext context, languageProvider, Widget? child) {
                    return IconButton(
                      onPressed: () {
                        // timeCounting();
                        languageProvider.toggleLanguage();
                      },
                      icon: Icon(
                        Icons.translate,
                        color: languageProvider.language == "english"
                            ? Colors.black
                            : Colors.white,
                      ),
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(
                    Icons.grid_view,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    showBottomSheet();
                  },
                ),
              ],
              bottom: mandirTabs.isNotEmpty
                  ? TabBar(
                      controller: _tabController,
                      tabAlignment: TabAlignment.start,
                      splashFactory: NoSplash.splashFactory,
                      isScrollable: true,
                      indicatorColor: Colors.black,
                      dividerColor: Colors.transparent,
                      labelPadding: const EdgeInsets.symmetric(horizontal: 8.0),
                      tabs: tabs)
                  : TabBar(
                      controller: tabController,
                      tabAlignment: TabAlignment.start,
                      splashFactory: NoSplash.splashFactory,
                      isScrollable: true,
                      indicatorColor: Colors.black,
                      dividerColor: Colors.transparent,
                      labelPadding: const EdgeInsets.symmetric(horizontal: 8.0),
                      tabs: List.generate(
                          10,
                          (index) => Tab(
                                child: Container(
                                  height: 40,
                                  width: 40,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle, //  Make it circular
                                    border: Border.all(color: Colors.white),
                                  ),
                                  clipBehavior: Clip
                                      .antiAlias, //  Ensures child is clipped in circle
                                  child: placeholderImage(),
                                ),
                              )),
                    ),
            ),
            body: mandirTabs.isNotEmpty
                ? PageView.builder(
                    controller: _pageController,
                    scrollDirection: Axis.horizontal,
                    onPageChanged: (index) {
                      // Looping Logic
                      if (index == mandirTabs.length) {
                        // Scrolled past the last tab, loop to the first
                        Future.delayed(const Duration(milliseconds: 300), () {
                          _pageController.animateToPage(0,
                              duration: const Duration(seconds: 1),
                              curve: Curves
                                  .bounceInOut); // Jump back to the first page
                          _tabController.animateTo(0); // Sync the TabBar
                        });
                      } else if (index == -1) {
                        // Scrolled before the first tab, loop to the last
                        Future.delayed(const Duration(milliseconds: 300), () {
                          _pageController.jumpToPage(
                              mandirTabs.length - 1); // Jump to the last page
                          _tabController.animateTo(
                              mandirTabs.length - 1); // Sync the TabBar
                        });
                      } else {
                        // Normal scroll behavior
                        _tabController.animateTo(
                            index % mandirTabs.length); // Sync TabBar
                        setState(() {
                          selectedIndex = index % mandirTabs.length;
                        });
                      }
                    },
                    itemCount:
                        mandirTabs.length + 1, // Add +1 for the looping logic
                    itemBuilder: (context, index) {
                      // Handle extra index for looping
                      final displayIndex = index % mandirTabs.length;
                      final tab = mandirTabs[displayIndex];

                      // Return the content for each tab
                      return MandirHomePage(
                        hiName: tab.hiName,
                        enName: tab.enName,
                        id: tab.id,
                        images: tab.images,
                        thumbNail: tab.thumbnail,
                        isImage: true,
                      );
                    },
                  )
                : MandirHomePage(
                    hiName: "",
                    enName: "",
                    id: 2,
                    images: images,
                    thumbNail: "",
                    isImage: false,
                  )
            //: const Text("No Data")

            ));
  }
}

// Function to get the current day of the week
//   String getCurrentDay() {
//     final now = DateTime.now();
//     return ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'][now.weekday % 7];
//   }

// Function to reorder data based on the current day
//   List<MandirData> reorderDataByDay(List<MandirData> data) {
//     // Map for deity names associated with each day
//     Map<String, String> deityForDay = {
//       'Monday': 'Shiv',
//       'Tuesday': 'Hanuman',
//       'Wednesday': 'Ganesh',
//       'Thursday': 'Vishnu',
//       'Friday': 'Laxmi',
//       'Saturday': 'Shani',
//       'Sunday': 'Ram', // Assuming you want to add a deity for Sunday
//     };
//
//     // Get the deity for the current day
//     String currentDay = getCurrentDay();
//     String currentDeity = deityForDay[currentDay] ?? '';
//
//     // Separate the current day's deity content from the rest
//     List<MandirData> currentDayContent = data.where((item) {
//       return item.enName.toLowerCase().contains(currentDeity.toLowerCase());
//     }).toList();
//
//     // Prepare the reordered list
//     List<MandirData> reorderedList = [];
//
//     // If there is a current day's deity and it has an event_image
//     if (currentDayContent.isNotEmpty) {
//       // Check if the event_image is not null
//       if (currentDayContent[0].eventImage != null) {
//         // Add the event_image to the images list
//         currentDayContent[0].images.insert(0, currentDayContent[0].eventImage!);
//       }
//
//       // Add the current day's deity to the reordered list
//       reorderedList.add(currentDayContent[0]);
//     }
//
//     // Prepare the other content
//     List<MandirData> otherContent = data.where((item) {
//       return !item.enName.toLowerCase().contains(currentDeity.toLowerCase());
//     }).toList();
//
//     // Add the other content to the reordered list
//     reorderedList.addAll(otherContent);
//
//     // Return the final reordered list
//     return reorderedList;
//   }

// @override
// void initState() {
//   super.initState();
//   selectedIndex = widget.tabIndex;
//   tabController = TabController(length: 10, vsync: this);
//   userToken = Provider.of<AuthController>(Get.context!, listen: false).getUserToken();
//   latiTude = Provider.of<AuthController>(Get.context!, listen: false).latitude;
//   longiTude = Provider.of<AuthController>(Get.context!, listen: false).longitude;
//   print(">>>> token order $userToken");
//   _startTimer(); // Fetch data after initializing
//   getTabs(widget.tabIndex); // Fetch data after initializing
//   _pageController = PageController(viewportFraction: 0.9);
//   getLocation(latiTude, longiTude);
// }

// Future<void> getTabs(int tabIndex) async {
//   setState(() {
//     isLoading = true; // Show loading indicator
//   });
//
//   try {
//     // Fetch data from the API
//     final res = await ApiService().getData("${AppConstants.baseUrl}${AppConstants.mandirTabsUrl}");
//     print('Response: $res');
//
//     if (res != null) {
//       final tabsCategory = MandirModel.fromJson(res);
//
//       // Check if the response contains data
//       if (tabsCategory.data != null) {
//         // Get current day and reorder data
//        // List<MandirData> reorderedTabs = reorderDataByDay(tabsCategory.data!);
//
//         // Update state with reordered data
//         setState(() {
//          // mandirTabs = reorderedTabs;
//           mandirTabs = tabsCategory.data;
//
//           // Initialize the TabController with initialIndex
//           _tabController = TabController(length: mandirTabs.length, vsync: this, initialIndex: tabIndex);
//
//           _pageController = PageController(initialPage: tabIndex);
//
//           // TabController listener for tab updates
//           _tabController!.addListener(() {
//             // Ensure the index is updated only when it's changing
//             if (_tabController!.indexIsChanging) {
//               setState(() {
//                 selectedIndex = _tabController!.index;  // Update selectedIndex based on the TabController index
//                 _pageController.jumpToPage(_tabController!.index); // Sync the PageController with the TabController
//               });
//             }
//           });
//         });
//       } else {
//         print('Error: Received null or empty data.');
//       }
//     } else {
//       print('Error: Received null response from API.');
//     }
//   } catch (e) {
//     // Log and handle any exceptions
//     print('Error fetching tabs: $e');
//   } finally {
//     // Reset loading state
//     setState(() {
//       isLoading = false;
//     });
//   }
// }
