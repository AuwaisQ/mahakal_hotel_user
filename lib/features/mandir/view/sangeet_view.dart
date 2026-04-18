import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../utill/app_constants.dart';
import '../../sangeet/controller/audio_manager.dart';
import '../../sangeet/controller/favourite_manager.dart';
import '../../sangeet/model/sangeet_model.dart';
import '../api_service/api_service.dart';
import '../../donation/controller/lanaguage_provider.dart';
import '../controller/share_controller.dart';
import '../model/mandir_sangeet_model.dart';
import 'custom_colors.dart';
import 'lyrics_bhajan.dart';
import 'sangeet_view_bhajan.dart';

class SangeetView extends HookWidget {
  const SangeetView(
    this.godNameHindi, {
    super.key,
    required this.godName,
  });

  final String godName;
  final String godNameHindi;

  @override
  Widget build(BuildContext context) {
    //  AudioPlayerManager audioManager = AudioPlayerManager();
    AudioPlayerManager audioManager = AudioPlayerManager();

    // State variables
    // Inside your widget or HookWidget build method

    final isLoading = useState<bool>(false);
    final mandirBhajan = useState<List<Subcategory>>([]);
    final bhajanDataList = useState<List<Sangeet>>([]);
    final allcategorymodel = useState<List<Sangeet>>([]);
    final categoryData = useState<Category?>(null);

    Future<void> fetchBhajanData() async {
      String currentLanguage = context.read<LanguageProvider>().language;
      final audioManager =
          Provider.of<AudioPlayerManager>(context, listen: false);

      print("🎧 Fetching Bhajan Data in Language: $currentLanguage");

      isLoading.value = true;

      try {
        final musicListResponse = await ApiService().getData(
          "${AppConstants.baseUrl}${AppConstants.mandirSangeetDataUrl}${1}&subcategory_id=${2}&language=$currentLanguage",
        );

        print("🎵 My dynamic bhajan $musicListResponse");

        if (musicListResponse != null &&
            musicListResponse is Map<String, dynamic>) {
          final sangeetModel = SangeetModel.fromJson(musicListResponse);

          // Filter only valid (status == 1) bhajans
          bhajanDataList.value =
              sangeetModel.sangeet.where((item) => item.status == 1).toList();

          audioManager.setPlaylist(bhajanDataList.value);

          print("✅ Bhajan list fetched: ${bhajanDataList.value.length} items");
        } else {
          print("⚠️ Error: Invalid or null music list response");
          bhajanDataList.value = [];
        }
      } catch (error) {
        print("❌ Failed to fetch music data: $error");
        bhajanDataList.value = [];
      } finally {
        isLoading.value = false;
      }
    }

    Future<void> getAllCategoryData() async {
      String currentLanguage = context.read<LanguageProvider>().language;
      final audioManager =
          Provider.of<AudioPlayerManager>(context, listen: false);

      print("📂 Fetching All Category Bhajan Data...");

      isLoading.value = true;

      try {
        final res = await ApiService().getData(
          "${AppConstants.baseUrl}${AppConstants.mandirSangeetDataUrl}${1}&subcategory_id=all&language=$currentLanguage",
        );

        print("🎶 My All Bhajan Response: $res");

        if (res is Map<String, dynamic> && res.containsKey('sangeet')) {
          final List<dynamic> dataList = res['sangeet'];

          final List<Sangeet> categoryList =
              dataList.map((e) => Sangeet.fromJson(e)).toList();

          allcategorymodel.value =
              categoryList.where((item) => item.status == 1).toList();

          audioManager.setPlaylistAll(allcategorymodel.value);

          print("✅ All category model count: ${allcategorymodel.value.length}");
        } else {
          print("⚠️ Unexpected response format: $res");
          allcategorymodel.value = [];
        }
      } catch (error) {
        print("❌ Failed to fetch all category data: $error");
        allcategorymodel.value = [];
      } finally {
        isLoading.value = false;
      }
    }

    Future<void> getBhajanData() async {
      print("🙏 Fetching Mandir Bhajan Data...");
      print("God Name: $godName | Hindi: $godNameHindi");

      final Map<String, dynamic> requestData = {
        "category_name": godName,
      };

      isLoading.value = true;

      try {
        final res = await ApiService().postData(
          "${AppConstants.baseUrl}${AppConstants.getBhajanByGodUrl}",
          requestData,
        );

        if (res == null) {
          print("⚠️ API returned null. Check endpoint or parameters.");
          mandirBhajan.value = [];
          categoryData.value = null;
          return;
        }

        final mandirBhajanModel = MandirBhajanModel.fromJson(res);

        categoryData.value = mandirBhajanModel.category;
        mandirBhajan.value = mandirBhajanModel.subcategories;

        print(
            "📘 Category: ${categoryData.value?.name}, ID: ${categoryData.value?.id}");
        print("📗 Subcategories fetched: ${mandirBhajan.value.length}");

        // Fetch both Bhajan data sets after main category is loaded
        await fetchBhajanData();
        await getAllCategoryData();
      } catch (e) {
        print("❌ Error in mandir bhajan: $e");
        mandirBhajan.value = [];
        categoryData.value = null;
      } finally {
        isLoading.value = false;
      }
    }

    useEffect(() {
      getBhajanData();
      return null;
    }, []);

    /*final isLoading = useState<bool>(false);
    final mandirBhajan = useState<List<Subcategory>>([]);
    final bhajanDataList = useState<List<Sangeet>>([]);
    final allcategorymodel = useState<List<Sangeet>>([]);

    final categoryData = useState<Category?>(null); // To store the category details

    Future<void> fetchBhajanData() async {
      String currentLanguage = context.read<LanguageProvider>().language;

      audioManager = Provider.of<AudioPlayerManager>(context, listen: false);

      print(" My Current Selected Language Is $currentLanguage");

      isLoading.value = true;

      try {
        final musicListResponse = await ApiService().getData(
            "${AppConstants.baseUrl}${AppConstants.mandirSangeetDataUrl}${1}&subcategory_id=${2}&language=$currentLanguage"
            //'${AppConstants.baseUrl}/api/v1/sangeet/sangeet-details?subcategory_id=${widget.subCategoryId}&language=$currentLanguage',
            );

        print("My dynamic bhajan $musicListResponse");

        //  print(" My Coming Language is ${LanguageProvider.selectedLanguage}");
        if (musicListResponse != null) {
          final sangeetModel = SangeetModel.fromJson(musicListResponse);

          bhajanDataList.value.clear();
          bhajanDataList.value =
              sangeetModel.sangeet.where((item) => item.status == 1).toList();
          audioManager.setPlaylist(bhajanDataList.value);
          isLoading.value = false;

          print(bhajanDataList.value.length);
        } else {
          print("Error: The response is null or improperly formatted.");

          isLoading.value = false;
        }
      } catch (error) {
        print("Failed to fetch music data: $error");
        isLoading.value = false;
        //_noData = true;
      }
    }

    Future<void> getAllCategoryData() async {
      String currentLanguage = context.read<LanguageProvider>().language;

      print("My category from this ${categoryData.value!.id}");

      isLoading.value = true;

      try {
        final res = await ApiService().getData(
          "${AppConstants.baseUrl}${AppConstants.mandirSangeetDataUrl}${categoryData.value!.id}&subcategory_id=all&language=$currentLanguage",
        );

        print("My All Bhajan $res");

        // Ensure the response is a map and contains the expected list
        if (res is Map<String, dynamic> && res.containsKey('sangeet')) {
          final List<dynamic> dataList = res['sangeet'];

          final List<Sangeet> categoryList =
              dataList.map((e) => Sangeet.fromJson(e)).toList();

          allcategorymodel.value =
              categoryList.where((item) => item.status == 1).toList();
          audioManager.setPlaylistAll(allcategorymodel.value);

          // audioManager.playMusic(allcategorymodel.value[0]);

          //audioManager.playMusic(allcategorymodel.value[0]);

          print("all cat model ${allcategorymodel.value.length}");
        } else {
          isLoading.value = false;

          print("Unexpected response format: $res");
          allcategorymodel.value = []; // Clear data if response is invalid
        }
      } catch (error) {
        isLoading.value = false;

        print("Failed to fetch all category data: $error");
        allcategorymodel.value = []; // Clear data on error
      }
    }

    // API call function
    Future<void> getBhajanData() async {
      print(godName);
      print(godNameHindi);

      final Map<String, dynamic> requestData = {
        //"category_name": "shiv ji",
        "category_name": godName,
      };

      isLoading.value = true;

      try {
        // API Call
        final res = await ApiService().postData(
          "${AppConstants.baseUrl}${AppConstants.getBhajanByGodUrl}",
          requestData,
        );

        print(res);
        if (res == null) {
          print("API returned null response. Check your endpoint or parameters.");
          mandirBhajan.value = [];
          categoryData.value = null;
          return;
        }

        // Parse the response using MandirBhajanModel
        final mandirBhajanModel = MandirBhajanModel.fromJson(res);

        // Update the `mandirBhajan` with the list of subcategories and category
        categoryData.value = mandirBhajanModel.category;
        mandirBhajan.value = mandirBhajanModel.subcategories;

         fetchBhajanData();
         getAllCategoryData();

        print(
            "Category: ${categoryData.value?.name}, ID: ${categoryData.value?.id}");
        print(mandirBhajan.value.length);
      } catch (e) {
        isLoading.value = false;
        print("Error in mandir bhajan: $e");
        mandirBhajan.value = []; // Clear data on error
        categoryData.value = null; // Clear category on error
      } finally {
        isLoading.value = false;
      }
    }

    useEffect(() {
      getBhajanData();

      return null; // Cleanup not required in this case
    }, []); // Empty dependency ensures it runs only once on screen load

    */

    var expandedBarHeight = MediaQuery.of(context).size.height * 0.62;
    var collapsedBarHeight = MediaQuery.of(context).size.height * 0.12;

    final selectedIndex = useState(0);
    final scrollController = useScrollController();
    final isCollapsed = useState(false);
    final didAddFeedback = useState(false);

    var screenWidth = MediaQuery.of(context).size.width;

    final List<Widget> tabs = [
      Tab(
        height: 25,
        child: Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              border: Border.all(
                color:
                    selectedIndex.value == 0 ? Colors.transparent : Colors.grey,
              )),
          child: Padding(
            padding: EdgeInsets.symmetric(
                horizontal: screenWidth * 0.06, vertical: screenWidth * 0.009),
            child: Consumer<LanguageProvider>(
              builder: (BuildContext context, languageProvider, Widget? child) {
                return Text(
                  languageProvider.language == 'english' ? "All" : "सभी",
                  style: TextStyle(
                      fontSize: screenWidth * 0.03,
                      fontWeight: FontWeight.bold),
                );
              },
            ),
          ),
        ),
      ),

      //  ...filteredCategories.map((cat) {int index = filteredCategories.indexOf(cat) + 1;

      ...mandirBhajan.value.map(
        (cat) {
          int index = mandirBhajan.value.indexOf(cat) + 1;
          return Tab(
            height: 25,
            child: Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  border: Border.all(
                    color: selectedIndex.value == index
                        ? Colors.transparent
                        : Colors.grey,
                  )),
              child: Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: screenWidth * 0.06,
                    vertical: screenWidth * 0.009),
                child: Consumer<LanguageProvider>(
                  builder:
                      (BuildContext context, languageProvider, Widget? child) {
                    return Text(
                      languageProvider.language == 'english'
                          ? cat.enName
                          : cat.hiName,
                      style: TextStyle(
                          fontSize: screenWidth * 0.03,
                          fontWeight: FontWeight.bold),
                    );
                  },
                ),
              ),
            ),
          );
        },
      )
    ];

    return Consumer<AudioPlayerManager>(
      builder: (BuildContext context, audioManager, Widget? child) {
        return NotificationListener<ScrollNotification>(
          onNotification: (notification) {
            isCollapsed.value = scrollController.hasClients &&
                scrollController.offset >
                    (expandedBarHeight - collapsedBarHeight);
            if (isCollapsed.value && !didAddFeedback.value) {
              HapticFeedback.mediumImpact();
              didAddFeedback.value = true;
            } else if (!isCollapsed.value) {
              didAddFeedback.value = false;
            }
            return false;
          },
          child: isLoading.value
              ? const Scaffold(
                  body: Center(
                      child: CircularProgressIndicator(
                  color: Colors.orange,
                )))
              : DefaultTabController(
                  length: mandirBhajan.value.length + 1,
                  child: Stack(
                    children: [
                      BlurredBackdropImage(
                        audioManager: audioManager,
                      ),
                      NestedScrollView(
                        controller: scrollController,
                        headerSliverBuilder:
                            (BuildContext context, bool innerBoxIsScrolled) {
                          return <Widget>[
                            SliverAppBar(
                              expandedHeight: expandedBarHeight,
                              collapsedHeight: collapsedBarHeight,
                              centerTitle: false,
                              automaticallyImplyLeading: false,
                              pinned: true,
                              title: AnimatedOpacity(
                                  duration: const Duration(milliseconds: 200),
                                  opacity: isCollapsed.value ? 1 : 0,
                                  child: CollapsedAppBarContent(
                                    audioManager: audioManager,
                                    //musicData: bhajanDataList.value,
                                    allcategorymodel: allcategorymodel.value,
                                    selectedIndex: selectedIndex
                                        .value, // Cast to List<Sangeet>
                                  )),
                              elevation: 0,
                              backgroundColor: isCollapsed.value
                                  ? Theme.of(context).primaryColor
                                  : Colors.transparent,
                              flexibleSpace: FlexibleSpaceBar(
                                background: ExpandedAppBarContent(
                                  audioManager: audioManager,
                                  allcategorymodel: allcategorymodel.value,
                                  musicData: bhajanDataList.value,
                                  selectedIndex: selectedIndex.value,
                                  musicIndex: 0,
                                ),
                              ),
                              bottom: PreferredSize(
                                preferredSize: const Size.fromHeight(80.0),
                                child: Container(
                                  width: double.infinity,
                                  decoration: const BoxDecoration(
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(20),
                                      topRight: Radius.circular(20),
                                    ),
                                    color: CustomColors.clrwhite,
                                  ),
                                  child: Column(
                                    children: [
                                      SizedBox(
                                        height: screenWidth * 0.05,
                                      ),
                                      Center(
                                        child: Consumer<LanguageProvider>(
                                          builder: (BuildContext context,
                                              languageProvider, Widget? child) {
                                            return Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Icon(
                                                  Icons.all_inclusive_outlined,
                                                  size: screenWidth * 0.05,
                                                  color: CustomColors.clrorange,
                                                ),
                                                SizedBox(
                                                  width: screenWidth * 0.02,
                                                ),
                                                Text(
                                                  languageProvider.language ==
                                                          'english'
                                                      ? "Divine Music of $godName"
                                                      : "संगीत संग्रह $godNameHindi",
                                                  style: const TextStyle(
                                                    color: Colors.black,
                                                    fontSize: 20,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                SizedBox(
                                                  width: screenWidth * 0.02,
                                                ),
                                                Icon(
                                                  Icons.all_inclusive_outlined,
                                                  size: screenWidth * 0.05,
                                                  color: CustomColors.clrorange,
                                                ),
                                              ],
                                            );
                                          },
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 30,
                                      ),
                                      TabBar(
                                        onTap: (index) {
                                          selectedIndex.value = index;
                                        },
                                        isScrollable: true,
                                        dividerColor: Colors.transparent,
                                        padding: EdgeInsets.symmetric(
                                            horizontal: screenWidth * 0.02),
                                        unselectedLabelColor:
                                            CustomColors.clrblack,
                                        labelColor: CustomColors.clrwhite,
                                        indicatorWeight: 0.1,
                                        tabAlignment: TabAlignment.start,
                                        indicator: BoxDecoration(
                                            color: Colors.orange,
                                            borderRadius:
                                                BorderRadius.circular(5)),
                                        tabs: tabs,
                                      ),
                                      const Divider(),
                                    ],
                                  ),
                                ),
                              ),
                            )
                          ];
                        },
                        body: TabBarView(
                          physics: const NeverScrollableScrollPhysics(),
                          children: [
                            SangeetViewBhajan(
                              0,
                              isFixedTab: true,
                              isAllTab: false,
                              categoryId: categoryData.value!.id,
                            ),
                            ...mandirBhajan.value.map(
                              (cat) => SangeetViewBhajan(
                                cat.id,
                                isAllTab: true,
                                isFixedTab: false,
                                categoryId: categoryData.value!.id,
                              ),
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
        );
      },
    );
  }

  Widget buildBhajanview(
    BuildContext context,
    bool isLoading,
    bool isFixedTab,
    bool isAllTab,
    List<Sangeet> allcategorymodel,
    AudioPlayerManager audioManager,
    int subId,
  ) {
    var screenWidth = MediaQuery.of(context).size.width;

    List<Sangeet> bhajanDataList = [];

    // Future<void> fetchBhajanData() async {
    //   String currentLanguage = context.read<LanguageProvider>().language;
    //
    //   audioManager = Provider.of<AudioPlayerManager>(context);
    //
    //   print(" My Current Selected Language Is $currentLanguage");
    //
    //   // print("My category Id ${widget.categoryId}");
    //   //  print("My SubCategoryId ${widget.subCategoryId}");
    //
    //   try {
    //     final musicListResponse = await ApiService().getData(
    //         "${AppConstants.baseUrl}/api/v1/bhagwan/bhagwan-sangeet?category_id=${1}&subcategory_id=${subId}&language=$currentLanguage"
    //     );
    //
    //     print("My dynamic bhajan $musicListResponse");
    //
    //     //  print(" My Coming Language is ${LanguageProvider.selectedLanguage}");
    //     if (musicListResponse != null) {
    //       final sangeetModel = SangeetModel.fromJson(musicListResponse);
    //
    //
    //       bhajanDataList.clear();
    //       bhajanDataList = sangeetModel.sangeet.where((item) => item.status == 1).toList();
    //       // audioManager.setPlaylist(bhajanDataList);
    //       _isLoading = false;
    //
    //       print(bhajanDataList.length);
    //
    //     } else {
    //       print("Error: The response is null or improperly formatted.");
    //
    //       _isLoading = false;
    //     }
    //   } catch (error) {
    //     print("Failed to fetch music data: $error");
    //     _isLoading = false;
    //     //_noData = true;
    //   }
    // }

    void playMusic(int index) {
      Sangeet? selectedMusic;
      bool? isFix;

      if (isFixedTab) {
        // Assuming allcategorymodel contains Sangeet objects
        selectedMusic = allcategorymodel[index];
        isFix = true;
      } else if (isAllTab) {
        selectedMusic = bhajanDataList[index];
        isFix = false;
      }
      audioManager
          .playMusic(selectedMusic!, isFix)
          .then((_) {})
          .catchError((error) {
        print('Error playing music: $error');
      });
    }

    Widget buildMusicList() {
      final screenHeight = MediaQuery.of(context).size.height;
      final screenWidth = MediaQuery.of(context).size.width;

      if (isLoading) {
        // Show loading indicator
        return const Center(child: CircularProgressIndicator());
      }

      // Check if there's data in the relevant lists based on the tab type
      bool hasData;
      if (isFixedTab) {
        hasData = allcategorymodel.isNotEmpty;
        print(
            "Fixed Tab - Data Available: $hasData, Count: ${allcategorymodel.length}");
      } else if (isAllTab) {
        hasData = bhajanDataList.isNotEmpty;
        print(
            "All Tab - Data Available: $hasData, Count: ${bhajanDataList.length}");
      }

      // Display the list if there is data
      return ListView.builder(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: isFixedTab ? allcategorymodel.length : bhajanDataList.length,
        padding: EdgeInsets.symmetric(vertical: screenWidth * 0.03),
        itemBuilder: (context, index) {
          final itemData =
              isFixedTab ? allcategorymodel[index] : bhajanDataList[index];

          return InkWell(
            onTap: () => playMusic(index),
            child: Padding(
              padding: EdgeInsets.symmetric(
                vertical: screenWidth * 0.01,
                horizontal: screenWidth * 0.04,
              ),
              child: Row(
                children: [
                  // Show the image with a play indicator if the music is currently playing
                  audioManager.currentMusic != null &&
                          audioManager.isPlaying &&
                          audioManager.currentMusic!.id == itemData.id
                      ? Container(
                          height: screenHeight * 0.05,
                          width: screenWidth * 0.1,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(6),
                            image: DecorationImage(
                              image: CachedNetworkImageProvider(itemData.image),
                              fit: BoxFit.cover,
                            ),
                          ),
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(6),
                              color: Colors.black.withOpacity(0.5),
                            ),
                            child: const Image(
                              image: NetworkImage(
                                "https://cdn.pixabay.com/animation/2023/10/22/03/31/03-31-40-761_512.gif",
                              ),
                              color: Colors.white,
                            ),
                          ),
                        )
                      : Container(
                          height: screenHeight * 0.05,
                          width: screenWidth * 0.1,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(6),
                            image: DecorationImage(
                              image: CachedNetworkImageProvider(itemData.image),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                  Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: screenWidth * 0.03),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: screenWidth * 0.4,
                          child: Text(
                            itemData.title,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: screenWidth * 0.04,
                              overflow: TextOverflow.ellipsis,
                            ),
                            maxLines: 1,
                          ),
                        ),
                        SizedBox(
                          width: screenWidth * 0.3,
                          child: Text(
                            itemData.singerName,
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: screenWidth * 0.03,
                              overflow: TextOverflow.ellipsis,
                            ),
                            maxLines: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: Icon(
                      Icons.share,
                      color: Colors.orange,
                      size: screenWidth * 0.06,
                    ),
                    onPressed: () {
                      // shareMusic.shareSong(itemData);
                    },
                  ),
                  GestureDetector(
                    // onTap: () => _showBottomSheet(index),
                    child: Icon(
                      Icons.more_vert_rounded,
                      color: Colors.orange,
                      size: screenWidth * 0.07,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    }

    return Consumer<AudioPlayerManager>(
      builder: (context, audioManager, child) {
        return Scaffold(
          backgroundColor: CustomColors.clrwhite,
          body: Stack(
            children: [
              isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: CustomColors.clrblack,
                      ),
                    )
                  : buildMusicList(),
            ],
          ),
        );
      },
    );
  }
}

class CollapsedAppBarContent extends StatefulWidget {
  final AudioPlayerManager audioManager;
  //final List<Sangeet> allcategorymodel;
  final List<Sangeet> allcategorymodel;
  //final List musicData;
  final int selectedIndex;

  const CollapsedAppBarContent({
    super.key,
    required this.audioManager,
    // required this.musicData,
    required this.allcategorymodel,
    required this.selectedIndex,
  });

  @override
  State<CollapsedAppBarContent> createState() => _CollapsedAppBarContentState();
}

class _CollapsedAppBarContentState extends State<CollapsedAppBarContent> {
  // void playMusic(int index) {
  //   if (widget.audioManager != null) {
  //     Sangeet selectedMusic;
  //     bool isFix;
  //     if (widget.selectedIndex == 0) {
  //       selectedMusic = widget.allcategorymodel[index];
  //       isFix = true;
  //     } else {
  //       selectedMusic = widget.musicData[index];
  //       isFix = false;
  //     }
  //     widget.audioManager.playMusic(selectedMusic,isFix);
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    var screenWidth = MediaQuery.of(context).size.width;
    var screenHeight = MediaQuery.of(context).size.height;

    return Consumer<AudioPlayerManager>(
      builder: (BuildContext context, audioManager, Widget? child) {
        return Padding(
          padding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.01, vertical: screenWidth * 0.08),
          child: Column(
            children: [
              Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Container(
                  height: screenHeight * 0.05,
                  width: screenWidth * 0.1,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6),
                    image: DecorationImage(
                      image: NetworkImage(audioManager.currentMusic?.image ??
                          'default_image_url'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                SizedBox(
                  width: screenWidth * 0.05,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: screenWidth * 0.40,
                      child: Text(
                        audioManager.currentMusic?.title ?? 'No Title',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: screenWidth * 0.04,
                            overflow: TextOverflow.ellipsis,
                            color: CustomColors.clrwhite),
                        maxLines: 1,
                      ),
                    ),
                    SizedBox(
                      width: screenWidth * 0.3,
                      child: Text(
                        audioManager.currentMusic?.singerName ?? 'No Singer',
                        style: TextStyle(
                            color: CustomColors.clrwhite,
                            fontSize: screenWidth * 0.03,
                            fontWeight: FontWeight.bold,
                            overflow: TextOverflow.ellipsis),
                        maxLines: 1,
                      ),
                    ),
                  ],
                ),

                // SizedBox(width: screenWidth * 0.01,),
                Row(
                  children: [
                    //Skip Previous Button Mandir
                    GestureDetector(
                      onTap: () {
                        if (widget.selectedIndex == 0) {
                          // Fixed tab logic
                          Sangeet? currentMusic = audioManager.currentMusic;

                          if (currentMusic != null) {
                            int currentIndex =
                                widget.allcategorymodel.indexOf(currentMusic);

                            if (currentIndex != -1) {
                              if (currentIndex > 0) {
                                // Play the previous song
                                audioManager.playMusic(
                                    widget.allcategorymodel[currentIndex - 1],
                                    true);
                              } else {
                                // Loop back to the last song
                                audioManager.playMusic(
                                    widget.allcategorymodel.last, true);
                              }
                            } else {
                              // Handle case where currentMusic is not in the list
                              if (widget.allcategorymodel.isNotEmpty) {
                                audioManager.playMusic(
                                    widget.allcategorymodel.last, true);
                              } else {
                                print("No music available in the list");
                              }
                            }
                          } else {
                            // Handle case where currentMusic is null
                            if (widget.allcategorymodel.isNotEmpty) {
                              audioManager.playMusic(
                                  widget.allcategorymodel.last, true);
                            } else {
                              print("No music available in the list");
                            }
                          }
                        } else {
                          // Dynamic tab logic
                          audioManager.skipPrevious(
                              isFix:
                                  false); // Skip to previous song in the dynamic list
                        }
                      },
                      child: Icon(
                        Icons.skip_previous,
                        color: CustomColors.clrwhite,
                        size: screenWidth * 0.08,
                      ),
                    ),
                    // GestureDetector(
                    //   onTap: () {
                    //     if (audioManager != null) {
                    //       if (widget.selectedIndex == 0) {
                    //         // Fixed tab logic
                    //
                    //         Sangeet? currentMusic = audioManager.currentMusic;
                    //
                    //         if (currentMusic != null) {
                    //
                    //           int currentIndex = widget.allcategorymodel.indexOf(currentMusic);
                    //
                    //           print("Current $currentIndex");
                    //           //if (currentIndex != -1) {
                    //           // if (currentIndex > 0) {
                    //
                    //           // Play the previous song
                    //
                    //           if(audioManager.fixedTabMusic){
                    //             audioManager.skipPrevious(isFix: true);                                            //playMusic(currentIndex + 1);
                    //           } else{
                    //             playMusic(currentIndex - 1);
                    //           }
                    //           // audioManager.playMusic(widget.allcategorymodel[currentIndex - 1],true);
                    //           // } else {
                    //           //   // Loop back to the last song
                    //           //   audioManager.playMusic(widget.allcategorymodel.last,true);
                    //           // }
                    //           // }
                    //           // else {
                    //           //   // Handle case where currentMusic is not in the list
                    //           //   if (widget.allcategorymodel.isNotEmpty) {
                    //           //     audioManager.playMusic(widget.allcategorymodel.last,true);
                    //           //   } else {
                    //           //     print("No music available in the list");
                    //           //   }
                    //           // }
                    //         } else {
                    //           // Handle case where currentMusic is null
                    //           if (widget.allcategorymodel.isNotEmpty) {
                    //             audioManager.playMusic(widget.allcategorymodel.last,true);
                    //           } else {
                    //             print("No music available in the list");
                    //           }
                    //         }
                    //       } else {
                    //         print("skip next is working for dynamic ddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd");
                    //
                    //         // Dynamic tab logic
                    //         audioManager.skipPrevious(isFix: false); // Skip to previous song in the dynamic list
                    //       }
                    //     }
                    //   },
                    //   child: Icon(
                    //     Icons.skip_previous,
                    //     color: CustomColors.clrwhite,
                    //     size: screenWidth * 0.08,
                    //   ),
                    // ),

                    SizedBox(
                      width: screenWidth * 0.05,
                    ),
                    //  Toggle Play/Pause Button
                    GestureDetector(
                      onTap: () => audioManager.togglePlayPause(),
                      child: Icon(
                        audioManager.isPlaying
                            ? Icons.pause_circle
                            : Icons.play_circle,
                        size: screenWidth * 0.08,
                        color: CustomColors.clrwhite,
                      ),
                    ),

                    SizedBox(
                      width: screenWidth * 0.05,
                    ),

                    //Skip Next Button Mandir
                    GestureDetector(
                      onTap: () {
                        if (widget.selectedIndex == 0) {
                          // Fixed tab logic
                          Sangeet? currentMusic = audioManager.currentMusic;

                          if (currentMusic != null) {
                            int currentIndex =
                                widget.allcategorymodel.indexOf(currentMusic);

                            if (currentIndex != -1) {
                              if (currentIndex <
                                  widget.allcategorymodel.length - 1) {
                                // Play the next song
                                audioManager.playMusic(
                                    widget.allcategorymodel[currentIndex + 1],
                                    true);
                              } else {
                                // Loop back to the first song
                                audioManager.playMusic(
                                    widget.allcategorymodel.first, true);
                              }
                            } else {
                              // Handle case where currentMusic is not in the list
                              if (widget.allcategorymodel.isNotEmpty) {
                                audioManager.playMusic(
                                    widget.allcategorymodel.first, true);
                              } else {
                                print("No music available in the list");
                              }
                            }
                          } else {
                            // Handle case where currentMusic is null
                            if (widget.allcategorymodel.isNotEmpty) {
                              audioManager.playMusic(
                                  widget.allcategorymodel.first, true);
                            } else {
                              print("No music available in the list");
                            }
                          }
                        } else {
                          // Dynamic tab logic
                          audioManager.skipNext(
                              false); // Skip to next song in the dynamic list
                        }
                      },
                      child: Icon(
                        Icons.skip_next,
                        color: CustomColors.clrwhite,
                        size: screenWidth * 0.08,
                      ),
                    ),
                    // GestureDetector(
                    //   onTap: () {
                    //     if (audioManager != null) {
                    //       if (widget.selectedIndex == 0) {
                    //         // Fixed tab logic
                    //         print("Skip Next for");
                    //         Sangeet? currentMusic = audioManager.currentMusic;
                    //
                    //         if (currentMusic != null) {
                    //           print("Skip Next");
                    //
                    //           int currentIndex = widget.allcategorymodel.indexOf(currentMusic);
                    //
                    //           //  if (currentIndex != -1) {
                    //           if (currentIndex < widget.allcategorymodel.length - 1) {
                    //             print("Skip Next");
                    //
                    //             // Play the next song
                    //
                    //             if(audioManager.fixedTabMusic){
                    //               audioManager.skipPrevious(isFix: true);                                            //playMusic(currentIndex + 1);
                    //             } else{
                    //               playMusic(currentIndex + 1);
                    //             }
                    //             //  audioManager.skipNext(true);
                    //             // audioManager.playMusic(widget.allcategorymodel[currentIndex + 1],true);
                    //           } else {
                    //             // Loop back to the first song
                    //             audioManager.playMusic(widget.allcategorymodel.first,true);
                    //           }
                    //           //  }
                    //           // else {
                    //           //   // Handle case where currentMusic is not in the list
                    //           //   if (widget.allcategorymodel.isNotEmpty) {
                    //           //     audioManager.playMusic(widget.allcategorymodel.first,true);
                    //           //   } else {
                    //           //     print("No music available in the list");
                    //           //   }
                    //           // }
                    //         } else {
                    //           // Handle case where currentMusic is null
                    //           if (widget.allcategorymodel.isNotEmpty) {
                    //             audioManager.playMusic(widget.allcategorymodel.first,true);
                    //           } else {
                    //             print("No music available in the list");
                    //           }
                    //         }
                    //       } else {
                    //         // Dynamic tab logic
                    //         print("Skip Next for");
                    //         audioManager.skipNext(false); // Skip to next song in the dynamic list
                    //       }
                    //     }
                    //   },
                    //   child: Icon(
                    //     Icons.skip_next,
                    //     color: CustomColors.clrwhite,
                    //     size: screenWidth * 0.08,
                    //   ),
                    // ),
                  ],
                )
              ]),
            ],
          ),
        );
      },
    );
  }
}

class BlurredBackdropImage extends StatelessWidget {
  final AudioPlayerManager audioManager;

  const BlurredBackdropImage({
    super.key,
    required this.audioManager,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: audioManager, // Listen for changes in the AudioPlayerManager
      builder: (context, child) {
        return SizedBox(
          width: double.infinity,
          height: MediaQuery.of(context).size.height / 1.5,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // The background image
              CachedNetworkImage(
                imageUrl: audioManager.currentMusic?.image ??
                    'https://thumbs.dreamstime.com/b/no-thumbnail-image-placeholder-forums-blogs-websites-148010362.jpg',
                fit: BoxFit.cover,
                errorWidget: (context, url, error) => const Icon(
                    Icons.broken_image,
                    size: 50,
                    color: Colors.grey), // Error Icon
              ),
              // The blur effect
              Container(
                color: Colors.black
                    .withOpacity(0.5), // Black overlay with 50% opacity
              ),
            ],
          ),
        );
      },
    );
  }
}

class ExpandedAppBarContent extends StatefulWidget {
  final AudioPlayerManager audioManager;
  final List<Sangeet> allcategorymodel;
  final List<Sangeet> musicData;
  final int selectedIndex;
  final int musicIndex;

  const ExpandedAppBarContent(
      {super.key,
      required this.audioManager,
      required this.allcategorymodel,
      required this.musicData,
      required this.selectedIndex,
      required this.musicIndex});

  @override
  State<ExpandedAppBarContent> createState() => _ExpandedAppBarContentState();
}

class _ExpandedAppBarContentState extends State<ExpandedAppBarContent> {
  String formatDuration(Duration? duration) {
    if (duration == null) return '00:00';
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  final shareMusic = ShareMusic();

  void _showShuffleOptionsDialog(
      BuildContext context, AudioPlayerManager audioManager) {
    showDialog(
      context: context,
      builder: (context) {
        return ShuffleOptionsDialog(
          audioManager: audioManager,
        );
      },
    );
  }

  // void playMusic(int index) {
  //   if (widget.audioManager != null) {
  //     Sangeet selectedMusic;
  //     bool isFix;
  //     if (widget.selectedIndex == 0) {
  //       selectedMusic = widget.allcategorymodel[index];
  //       isFix = true;
  //     } else {
  //       selectedMusic = widget.musicData[index];
  //       isFix = false;
  //     }
  //     widget.audioManager.playMusic(selectedMusic,isFix);
  //   }
  // }

  void playMusic(int index) {
    Sangeet selectedMusic;
    bool isFix;
    if (widget.selectedIndex == 0) {
      selectedMusic = widget.allcategorymodel[index];
      isFix = true;
    } else {
      selectedMusic = widget.musicData[index];
      isFix = false;
    }
    widget.audioManager.playMusic(selectedMusic, isFix);
  }

  @override
  void initState() {
    var allCategoryModel = widget.allcategorymodel;
    print(allCategoryModel);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var screenWidth = MediaQuery.of(context).size.width;
    var screenHeight = MediaQuery.of(context).size.height;

    return Consumer<AudioPlayerManager>(
      builder: (BuildContext context, audiomanager, Widget? child) {
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.02),
          child: Consumer<FavouriteProvider>(
            builder: (BuildContext context, favouriteProvider, Widget? child) {
              Sangeet? currentMusic = audiomanager.currentMusic;
              if (currentMusic != null) {
                final isFavourite = favouriteProvider.favouriteBhajan
                    .any((favourite) => favourite.audio == currentMusic.audio);
                return Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: screenWidth * 0.17),
                    Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: screenWidth * 0.02),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          InkWell(
                            onTap: () {
                              print('backTapped');
                              Navigator.pop(context);
                            },
                            child: Column(
                              children: [
                                Icon(Icons.arrow_back_ios_rounded,
                                    size: screenWidth * 0.06,
                                    color: Colors.white),
                                const Text("Back",
                                    style: TextStyle(color: Colors.white)),
                              ],
                            ),
                          ),
                          SizedBox(width: screenWidth * 0.53),
                          GestureDetector(
                            onTap: () {
                              shareMusic.shareSong(audiomanager.currentMusic!);
                            },
                            child: Padding(
                              padding: EdgeInsets.all(screenWidth * 0.01),
                              child: const Column(
                                children: [
                                  Icon(Icons.share, color: Colors.white),
                                  Text("Share",
                                      style: TextStyle(color: Colors.white)),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(
                              height: screenWidth * 0.05,
                              width: screenWidth * 0.05),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                CupertinoPageRoute(
                                  builder: (context) => Lyricsbhajan(
                                      musicLyrics:
                                          audiomanager.currentMusic!.lyrics,
                                      musicName:
                                          audiomanager.currentMusic!.title),
                                ),
                              );
                            },
                            child: Padding(
                              padding: EdgeInsets.all(screenWidth * 0.01),
                              child: const Column(
                                children: [
                                  Icon(
                                    Icons.article,
                                    color: Colors.white,
                                  ),
                                  //ImageIcon(AssetImage("assets/image/lyrics.png"), color: Colors.white),
                                  Text("Lyrics",
                                      style: TextStyle(color: Colors.white)),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: screenWidth * 0.22),
                    Center(
                      child: Column(
                        children: [
                          SizedBox(
                            width: screenWidth * 0.6,
                            child: Text(
                              audiomanager.currentMusic?.title ?? 'No Title',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: screenWidth * 0.06,
                                fontWeight: FontWeight.bold,
                                color: CustomColors.clrwhite,
                                overflow: TextOverflow.ellipsis,
                              ),
                              maxLines: 1,
                            ),
                          ),
                          SizedBox(
                            width: screenWidth * 0.4,
                            child: Text(
                              audiomanager.currentMusic?.singerName ??
                                  'No Singer',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: screenWidth * 0.05,
                                color: CustomColors.clrwhite,
                                overflow: TextOverflow.ellipsis,
                              ),
                              maxLines: 1,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Additional widget content here...

                    SliderTheme(
                      data: SliderThemeData(
                        activeTrackColor: CustomColors.clrwhite,
                        trackHeight: 1.5,
                        trackShape: const RectangularSliderTrackShape(),
                        inactiveTrackColor:
                            CustomColors.clrwhite.withOpacity(0.5),
                        thumbColor: CustomColors.clrwhite,
                        overlayColor: CustomColors.clrwhite.withOpacity(0.7),
                        valueIndicatorColor: CustomColors.clrwhite,
                      ),
                      child: Slider(
                        min: 0.0,
                        max: audiomanager.duration.inSeconds.toDouble(),
                        value:
                            audiomanager.currentPosition.inSeconds.toDouble(),
                        onChanged: (double value) {
                          audiomanager.seekTo(Duration(seconds: value.toInt()));
                        },
                      ),
                    ),
                    Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
                      child: Row(
                        children: [
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.2,
                            child: Text(
                              formatDuration(audiomanager.currentPosition),
                              style: TextStyle(
                                  color: CustomColors.clrwhite,
                                  fontWeight: FontWeight.bold,
                                  fontSize:
                                      MediaQuery.of(context).size.width * 0.04),
                              maxLines: 1,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            formatDuration(audiomanager.duration),
                            style: TextStyle(
                                color: CustomColors.clrwhite,
                                fontWeight: FontWeight.bold,
                                fontSize:
                                    MediaQuery.of(context).size.width * 0.04),
                            maxLines: 1,
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
                      child: Row(
                        children: [
                          GestureDetector(
                              onTap: () => _showShuffleOptionsDialog(
                                  context, audiomanager),
                              child: Icon(Icons.shuffle,
                                  size: screenWidth * 0.08,
                                  color: CustomColors.clrwhite)),
                          SizedBox(width: screenHeight * 0.07),

                          GestureDetector(
                            onTap: () {
                              if (widget.selectedIndex == 0) {
                                // Fixed tab logic

                                Sangeet? currentMusic =
                                    audiomanager.currentMusic;

                                if (currentMusic != null) {
                                  int currentIndex = widget.allcategorymodel
                                      .indexOf(currentMusic);

                                  print("Current $currentIndex");
                                  //if (currentIndex != -1) {
                                  // if (currentIndex > 0) {

                                  // Play the previous song

                                  if (audiomanager.fixedTabMusic) {
                                    audiomanager.skipPrevious(
                                        isFix:
                                            true); //playMusic(currentIndex + 1);
                                  } else {
                                    playMusic(currentIndex - 1);
                                  }

                                  //  audiomanager.skipPrevious(isFix: true);
                                  // Skip to previous song in the dynamic list
                                  // audioManager.playMusic(widget.allcategorymodel[currentIndex - 1],true);
                                  // } else {
                                  //   // Loop back to the last song
                                  //   audioManager.playMusic(widget.allcategorymodel.last,true);
                                  // }
                                  // }
                                  // else {
                                  //   // Handle case where currentMusic is not in the list
                                  //   if (widget.allcategorymodel.isNotEmpty) {
                                  //     audioManager.playMusic(widget.allcategorymodel.last,true);
                                  //   } else {
                                  //     print("No music available in the list");
                                  //   }
                                  // }
                                } else {
                                  // Handle case where currentMusic is null
                                  if (widget.allcategorymodel.isNotEmpty) {
                                    audiomanager.playMusic(
                                        widget.allcategorymodel.last, true);
                                  } else {
                                    print("No music available in the list");
                                  }
                                }
                              } else {
                                print(
                                    "skip next is working for dynamic ddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd");

                                // Dynamic tab logic
                                audiomanager.skipPrevious(
                                    isFix:
                                        false); // Skip to previous song in the dynamic list
                              }
                            },
                            child: Icon(
                              Icons.skip_previous,
                              color: CustomColors.clrwhite,
                              size: screenWidth * 0.08,
                            ),
                          ),

                          /// Mandir Sangeet
                          // GestureDetector(
                          //   onTap: () {
                          //     if (widget.selectedIndex == 0) {
                          //       print("My Index is ${widget.selectedIndex}");
                          //       // Fixed tab logic for skip previous
                          //       int currentIndex = widget.allcategorymodel
                          //           .indexOf(audiomanager.currentMusic!);
                          //       if (currentIndex > 0) {
                          //         playMusic(currentIndex - 1);
                          //       } else {
                          //         playMusic(widget.allcategorymodel.length -
                          //             1); // Loop back to the last song
                          //       }
                          //     } else {
                          //       print("My dynamic index ${widget.selectedIndex}");
                          //       audiomanager.skipPrevious(); // Assuming you have a skipPrevious method in your audioManager
                          //     }
                          //   },
                          //   child: Icon(Icons.skip_previous,
                          //       size: screenWidth * 0.1,
                          //       color: CustomColors.clrwhite),
                          // ),

                          SizedBox(width: screenWidth * 0.06),
                          GestureDetector(
                            onTap: () => audiomanager.togglePlayPause(),
                            child: Icon(
                              audiomanager.isPlaying
                                  ? Icons.pause_circle
                                  : Icons.play_circle,
                              size: screenHeight * 0.07,
                              color: CustomColors.clrwhite,
                            ),
                          ),
                          SizedBox(width: screenWidth * 0.06),

                          /// Skip Next
                          GestureDetector(
                            onTap: () {
                              if (widget.selectedIndex == 0) {
                                print("selected index == 0");
                                // Fixed tab logic
                                Sangeet? currentMusic =
                                    audiomanager.currentMusic;

                                if (currentMusic != null) {
                                  print("selected index == 0");
                                  int currentIndex = widget.allcategorymodel
                                      .indexOf(currentMusic);

                                  //  if (currentIndex != -1) {
                                  if (currentIndex <
                                      widget.allcategorymodel.length - 1) {
                                    if (audiomanager.fixedTabMusic) {
                                      audiomanager.skipNext(true);
                                      //playMusic(currentIndex + 1);
                                    } else {
                                      playMusic(currentIndex + 1);
                                      // audiomanager.skipNext(true);
                                    }

                                    // Play the next song
                                    // audioManager.playMusic(widget.allcategorymodel[currentIndex + 1],true);
                                  } else {
                                    // Loop back to the first song
                                    audiomanager.playMusic(
                                        widget.allcategorymodel.first, true);
                                  }
                                  //  }
                                  // else {
                                  //   // Handle case where currentMusic is not in the list
                                  //   if (widget.allcategorymodel.isNotEmpty) {
                                  //     audioManager.playMusic(widget.allcategorymodel.first,true);
                                  //   } else {
                                  //     print("No music available in the list");
                                  //   }
                                  // }
                                } else {
                                  // Handle case where currentMusic is null
                                  if (widget.allcategorymodel.isNotEmpty) {
                                    audiomanager.playMusic(
                                        widget.allcategorymodel.first, true);
                                  } else {
                                    print("No music available in the list");
                                  }
                                }
                              } else {
                                // Dynamic tab logic
                                print("Dynamic Skip is working");
                                audiomanager.skipNext(
                                    false); // Skip to next song in the dynamic list
                              }
                            },
                            child: Icon(
                              Icons.skip_next,
                              color: CustomColors.clrwhite,
                              size: screenWidth * 0.08,
                            ),
                          ),

                          /// Mandir Sangeet
                          // GestureDetector(
                          //   onTap: () {
                          //     if (widget.selectedIndex == 0) {
                          //       print("My Index is ${widget.selectedIndex}");
                          //       // Fixed tab logic for skip next
                          //       int currentIndex = widget.allcategorymodel
                          //           .indexOf(audiomanager.currentMusic!);
                          //
                          //       print(" My real Current Index is ${currentIndex}");
                          //
                          //       if (currentIndex <
                          //           widget.allcategorymodel.length - 1) {
                          //         playMusic(currentIndex + 1);
                          //       } else {
                          //         playMusic(0); // Loop back to the first song
                          //       }
                          //     } else {
                          //       print("My dynamic index ${widget.selectedIndex}");
                          //       audiomanager
                          //           .skipNext(false); // Assuming you have a skipNext method in your audioManager
                          //     }
                          //   },
                          //   child: Icon(Icons.skip_next,
                          //       size: screenWidth * 0.1,
                          //       color: CustomColors.clrwhite),
                          // ),

                          const Spacer(),

                          GestureDetector(
                            onTap: () {
                              favouriteProvider.toggleBookmark(currentMusic);
                              print("Added to favourite");
                            },
                            child: Icon(
                              isFavourite
                                  ? Icons.favorite
                                  : Icons.favorite_border_sharp,
                              size: screenWidth * 0.08,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                );
              } else {
                // Handle the case when currentMusic is null
                return const Center(
                    child: CircularProgressIndicator(
                  color: Colors.orange,
                ));
              }
            },
          ),
        );
      },
    );
  }
}

class ShuffleOptionsDialog extends StatefulWidget {
  final AudioPlayerManager audioManager;

  const ShuffleOptionsDialog({
    super.key,
    required this.audioManager,
  });

  @override
  _ShuffleOptionsDialogState createState() => _ShuffleOptionsDialogState();
}

class _ShuffleOptionsDialogState extends State<ShuffleOptionsDialog> {
  int _currentSelectedIndex = 0;

  List<int> indexSelected = [0, 1, 2];

  @override
  void initState() {
    super.initState();
    _loadSelectedIndex();
  }

  _loadSelectedIndex() async {
    final prefs = await SharedPreferences.getInstance();
    int selectedIndex = prefs.getInt('selectedIndex') ?? 0;
    setState(() {
      _currentSelectedIndex = selectedIndex;
    });
  }

  _saveSelectedIndex(int index) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setInt('selectedIndex', index);
  }

  @override
  Widget build(BuildContext context) {
    var screenWidth = MediaQuery.of(context).size.width;

    return BottomSheet(
      onClosing: () {},
      builder: (context) {
        return Container(
          height: 210,
          width: double.infinity,
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20), topRight: Radius.circular(20)),
            color: Colors.white,
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(
                horizontal: screenWidth * 0.05, vertical: screenWidth * 0.02),
            child: Column(
              children: [
                Text(
                  'How to listen to Bhajan or Arti?',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: CustomColors.clrblack,
                      fontSize: screenWidth * 0.05),
                ),
                const Divider(),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.fiber_smart_record_outlined,
                            color: CustomColors.clrorange,
                            size: screenWidth * 0.05),
                        SizedBox(width: screenWidth * 0.05),
                        Text('Play Next',
                            style: TextStyle(
                                fontSize: screenWidth * 0.04,
                                fontWeight: FontWeight.bold,
                                color: CustomColors.clrblack)),
                        const Spacer(),
                        Radio<int>(
                          value: indexSelected[0],
                          groupValue: _currentSelectedIndex,
                          activeColor: CustomColors.clrorange,
                          onChanged: (int? value) {
                            setState(() {
                              _currentSelectedIndex = value!;
                            });
                            _saveSelectedIndex(value!);
                            widget.audioManager
                                .setShuffleMode(ShuffleModeSangeet.playNext);
                            // Navigator.pop(context);
                          },
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Icon(Icons.looks_one_outlined,
                            color: CustomColors.clrorange,
                            size: screenWidth * 0.05),
                        SizedBox(width: screenWidth * 0.05),
                        Text('Play Once and Close',
                            style: TextStyle(
                                fontSize: screenWidth * 0.04,
                                fontWeight: FontWeight.bold,
                                color: CustomColors.clrblack)),
                        const Spacer(),
                        Radio<int>(
                          value: indexSelected[1],
                          groupValue: _currentSelectedIndex,
                          activeColor: CustomColors.clrorange,
                          onChanged: (int? value) {
                            setState(() {
                              _currentSelectedIndex = value!;
                            });
                            _saveSelectedIndex(value!);
                            widget.audioManager.setShuffleMode(
                                ShuffleModeSangeet.playOnceAndClose);
                            // Navigator.pop(context);
                          },
                        ),
                      ],
                    ),
                    Row(children: [
                      Icon(Icons.loop,
                          color: CustomColors.clrorange,
                          size: screenWidth * 0.05),
                      SizedBox(width: screenWidth * 0.05),
                      Text('Play on Loop',
                          style: TextStyle(
                              fontSize: screenWidth * 0.04,
                              fontWeight: FontWeight.bold,
                              color: CustomColors.clrblack)),
                      const Spacer(),
                      Radio<int>(
                        value: indexSelected[2],
                        groupValue: _currentSelectedIndex,
                        activeColor: CustomColors.clrorange,
                        onChanged: (int? value) {
                          setState(() {
                            _currentSelectedIndex = value!;
                          });
                          _saveSelectedIndex(value!);
                          widget.audioManager
                              .setShuffleMode(ShuffleModeSangeet.playOnLoop);
                          //  Navigator.pop(context);
                        },
                      ),
                    ]),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
