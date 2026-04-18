import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mahakal/features/sangeet/model/sangeet_model.dart';
import 'package:provider/provider.dart';
import '../../../utill/app_constants.dart';
import '../../sangeet/controller/audio_manager.dart';
import '../../sangeet/controller/favourite_manager.dart';
import '../api_service/api_service.dart';
import '../../donation/controller/lanaguage_provider.dart';
import '../controller/share_controller.dart';
import 'custom_colors.dart';
import 'lyrics_bhajan.dart';

class SangeetViewBhajan extends StatefulWidget {
  SangeetViewBhajan(
    this.subCategoryId,
    // this.subCategoryModel,
    // this.godName,
    // this.godNameHindi,
    {
    super.key,
    required this.categoryId,
    //   required this.isToggle,
    required this.isFixedTab,
    required this.isAllTab,
    //   required this.isMusicBarVisible,
    //
  });

  int subCategoryId;
//   final List subCategoryModel;
  // final String godName;
  // final String godNameHindi;
  final int categoryId;
  // final bool isToggle;
  final bool isAllTab;
  final bool isFixedTab;
  // final bool isMusicBarVisible;

  @override
  State<SangeetViewBhajan> createState() => _SangeetViewBhajanState();
}

class _SangeetViewBhajanState extends State<SangeetViewBhajan>
    with SingleTickerProviderStateMixin {
  late AudioPlayerManager audioManager;
  late bool _isMusicBarVisible;

  int? currentlyPlayingCategoryId;

  bool _isLoading = true;
  bool isLoading = true;
  final shareMusic = ShareMusic();

  @override
  void initState() {
    super.initState();

    //   By default, assume the fixed tab is selected
    if (widget.isFixedTab) {
      // Call the method to fetch data for the fixed tab
      getAllCategoryData();
      //  getAllCategoryData();// Replace this with your specific method for the fixed tab
      print("Fetching data for Fixed Tab.");
    } else if (widget.isAllTab) {
      // Call the method to fetch data for the all tab
      fetchBhajanData(); // Replace this with your specific method for the all tab
      print("Fetching data for All Tab.");
    }

    // Handle refresh if needed
    _handleRefresh();

    // Set visibility based on the toggle parameter
    // _isMusicBarVisible =  true;
    // print("SubModel Length Is ${widget.subCategoryModel.length}");

    // Get all category data as required
    getAllCategoryData();

    print("My SubCategory Id Is ${widget.subCategoryId}");
  }

  Future<void> _handleRefresh() async {
    setState(() {
      _isLoading = true;
    });

    // Call your method to fetch data again or refresh the content
    await Future.wait([fetchBhajanData(), getAllCategoryData()]);

    setState(() {
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    audioManager = Provider.of<AudioPlayerManager>(context);
  }

  // Dynamic Tabs Music List

  List<Sangeet> bhajanDataList = [];

  Future<void> fetchBhajanData() async {
    String currentLanguage = context.read<LanguageProvider>().language;

    print(" My Current Selected Language Is $currentLanguage");

    print("My category Id ${widget.categoryId}");
    print("My SubCategoryId ${widget.subCategoryId}");
    print(
        "My Bhajan Url ${AppConstants.baseUrl}${AppConstants.mandirSangeetDataUrl}${widget.categoryId}&subcategory_id=${widget.subCategoryId}&language=$currentLanguage");

    try {
      final musicListResponse = await ApiService().getData(
          "${AppConstants.baseUrl}${AppConstants.mandirSangeetDataUrl}${widget.categoryId}&subcategory_id=${widget.subCategoryId}&language=$currentLanguage"
          //'${AppConstants.baseUrl}/api/v1/sangeet/sangeet-details?subcategory_id=${widget.subCategoryId}&language=$currentLanguage',
          );

      //  print(" My Coming Language is ${LanguageProvider.selectedLanguage}");
      if (musicListResponse != null) {
        final sangeetModel = SangeetModel.fromJson(musicListResponse);

        setState(() {
          bhajanDataList.clear();
          bhajanDataList =
              sangeetModel.sangeet.where((item) => item.status == 1).toList();
          audioManager.setPlaylist(bhajanDataList);
          _isLoading = false;

          print(bhajanDataList.length);
        });
      } else {
        print("Error: The response is null or improperly formatted.");
        setState(() {
          _isLoading = false;
        });
      }
    } catch (error) {
      print("Failed to fetch music data: $error");
      setState(() {
        _isLoading = false;
        //_noData = true;
      });
    }
  }

  // All(Fixed Tab) Music List

  List<Sangeet> allcategorymodel = [];

  Future<void> getAllCategoryData() async {
    String currentLanguage = context.read<LanguageProvider>().language;

    setState(() {
      _isLoading = true;
    });
    try {
      final res = await ApiService().getData(
        "${AppConstants.baseUrl}${AppConstants.mandirSangeetDataUrl}${widget.categoryId}&subcategory_id=all&language=$currentLanguage",
      );

      // Ensure the response is a map and contains the expected list
      if (res is Map<String, dynamic> && res.containsKey('sangeet')) {
        final List<dynamic> dataList = res['sangeet'];

        final List<Sangeet> categoryList =
            dataList.map((e) => Sangeet.fromJson(e)).toList();

        // setState(() {
        //   allcategorymodel =
        //       categoryList.where((item) => item.status == 1).toList();
        //   print("all cat model ${allcategorymodel.length}");
        //
        //
        //   WidgetsBinding.instance.addPostFrameCallback((_) {
        //     if (widget.isFixedTab && allcategorymodel.isNotEmpty) {
        //
        //       if(audioManager.isPlaying){
        //         print("Is PLaying");
        //       }
        //
        //       audioManager.playMusic(allcategorymodel.first);
        //
        //
        //     } else if (widget.isAllTab && bhajanDataList.isNotEmpty) {
        //       audioManager.playMusic(bhajanDataList.first);
        //     }
        //
        //     print("My SubCategory Id Is ${widget.subCategoryId}");
        //   });
        //
        //
        //
        // });

        setState(() {
          allcategorymodel =
              categoryList.where((item) => item.status == 1).toList();
          audioManager.setPlaylistAll(allcategorymodel);

          print("all cat model ${allcategorymodel.length}");

          WidgetsBinding.instance.addPostFrameCallback((_) {
            // If the player is already playing and the current category matches, don't play the first music
            if (audioManager.isPlaying &&
                currentlyPlayingCategoryId == widget.categoryId) {
              print("Music already playing for this category, skipping play.");
              return;
            }

            // If music is not playing, play the first music
            if (!audioManager.isPlaying && allcategorymodel.isNotEmpty) {
              audioManager.playMusic(allcategorymodel.first, true);
              currentlyPlayingCategoryId =
                  widget.categoryId; // Update the category
              print("Playing first music of the category.");
            } else if (audioManager.isPlaying &&
                currentlyPlayingCategoryId != widget.categoryId) {
              print(
                  "Switching category while music is playing. Keeping the current music.");
              // Ensure the current playing music continues
              currentlyPlayingCategoryId = widget.categoryId;
            }
          });
        });
      } else {
        print("Unexpected response format: $res");
        setState(() {
          _isLoading = false;
          allcategorymodel = []; // Clear data if response is invalid
        });
      }
    } catch (error) {
      print("Failed to fetch all category data: $error");
      setState(() {
        _isLoading = false;
        allcategorymodel = []; // Clear data on error
      });
    }
  }

  void playMusic(int index) {
    Sangeet? selectedMusic;
    bool? isFix;

    if (widget.isFixedTab) {
      // Assuming allcategorymodel contains Sangeet objects
      selectedMusic = allcategorymodel[index];
      isFix = true;
    } else if (widget.isAllTab) {
      selectedMusic = bhajanDataList[index];
      isFix = false;
    }
    // else {
    //   // Assuming subCategoryModel contains Sangeet objects
    //   selectedMusic = widget.subCategoryModel[index];
    // }

    audioManager.playMusic(selectedMusic!, isFix).then((_) {
      setState(() {
        //_isMusicBarVisible = widget.isToggle;
      });
    }).catchError((error) {
      print('Error playing music: $error');
    });
  }

  // void _toggleMusicBarVisibility() {
  //   setState(() {
  //     _isMusicBarVisible = !_isMusicBarVisible;
  //   });
  // }

  Widget _buildMusicList() {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    if (_isLoading) {
      // Show loading indicator
      return const Center(child: CircularProgressIndicator());
    }

    // Check if there's data in the relevant lists based on the tab type
    bool hasData;
    if (widget.isFixedTab) {
      hasData = allcategorymodel.isNotEmpty;
      print(
          "Fixed Tab - Data Available: $hasData, Count: ${allcategorymodel.length}");
    } else if (widget.isAllTab) {
      hasData = bhajanDataList.isNotEmpty;
      print(
          "All Tab - Data Available: $hasData, Count: ${bhajanDataList.length}");
    }
    // else {
    //   hasData = widget.subCategoryModel.isNotEmpty; // For other tab types
    //   print("Subcategory Tab - Data Available: $hasData, Count: ${widget.subCategoryModel.length}");
    // }

    // If no data is available, show the "No Data Here" message
    // if (!hasData) {
    //   return Center(child: Text("No Data Here"));
    // }

    // Display the list if there is data
    return Material(
      color: Colors.white,
      child: ListView.builder(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount:
            widget.isFixedTab ? allcategorymodel.length : bhajanDataList.length,
        // : widget.isAllTab
        // ? bhajanDataList.length
        //  : widget.subCategoryModel.length,
        padding: EdgeInsets.symmetric(vertical: screenWidth * 0.03),
        itemBuilder: (context, index) {
          final itemData = widget.isFixedTab
              ? allcategorymodel[index]
              : bhajanDataList[index];
          // : widget.isAllTab
          // ? bhajanDataList[index]
          // : widget.subCategoryModel[index];

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
                      Icons.offline_share_sharp,
                      color: Colors.orange,
                      size: screenWidth * 0.06,
                    ),
                    onPressed: () {
                      shareMusic.shareSong(itemData);
                    },
                  ),
                  GestureDetector(
                    onTap: () => _showBottomSheet(index),
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
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var screenWidth = MediaQuery.of(context).size.width;

    return Consumer<AudioPlayerManager>(
      builder: (context, audioManager, child) {
        return _isLoading
            ? Scaffold(
                backgroundColor: Colors.white,
                body: const Center(
                  child: CircularProgressIndicator(
                    color: Colors.orange,
                  ),
                ),
              )
            : _buildMusicList();

        //   Scaffold(
        //   backgroundColor: CustomColors.clrwhite,
        //   body: Stack(
        //     children: [
        //       _isLoading
        //           ? const Center(
        //               child: CircularProgressIndicator(
        //                 color: CustomColors.clrblack,
        //               ),
        //             )
        //           : _buildMusicList(),
        //     ],
        //   ),
        // );
      },
    );
  }

  String getFavouriteText(bool isFavourite, languageProvider) {
    if (languageProvider.language == 'English') {
      return isFavourite ? "Remove from Favourite" : "Add to Favourite";
    } else {
      return isFavourite ? "पसंदीदा से हटाएँ" : "पसंदीदा में जोड़ें";
    }
  }

  void _showBottomSheet(int index) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    showModalBottomSheet(
      context: context,
      backgroundColor: CustomColors.clrwhite,
      builder: (BuildContext context) {
        return SizedBox(
          height: 200,
          child: Padding(
            padding: EdgeInsets.all(screenWidth * 0.05),
            child: Consumer<FavouriteProvider>(
              builder:
                  (BuildContext context, favouriteProvider, Widget? child) {
                final isFavourite = favouriteProvider.favouriteBhajan.any(
                    (favourite) =>
                        favourite.audio ==
                        (widget.isFixedTab
                            ? allcategorymodel[index].audio
                            : bhajanDataList[index].audio));

                return Consumer<LanguageProvider>(
                  builder:
                      (BuildContext context, languageProvider, Widget? child) {
                    return Column(
                      children: [
                        Row(
                          children: [
                            Container(
                              height: screenHeight * 0.05,
                              width: screenWidth * 0.1,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(6),
                                image: DecorationImage(
                                  image: CachedNetworkImageProvider(
                                    widget.isFixedTab
                                        ? allcategorymodel[index].image
                                        : bhajanDataList[index].image,
                                  ),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: screenWidth * 0.03),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    width: screenWidth * 0.4,
                                    child: Text(
                                      (widget.isFixedTab
                                          ? allcategorymodel[index].title
                                          //: widget.isAllTab
                                          : bhajanDataList[index].title
                                      //  : widget.subCategoryModel[index]
                                      // .title
                                      ),
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
                                      (widget.isFixedTab
                                          ? allcategorymodel[index].singerName
                                          //    : widget.isAllTab
                                          : bhajanDataList[index].singerName
                                      //  : widget.subCategoryModel[index]
                                      //.singerName
                                      ),
                                      style: TextStyle(
                                        color: CustomColors.clrblack,
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
                            GestureDetector(
                              onTap: () {
                                Navigator.pop(context);
                              },
                              child: Icon(
                                Icons.cancel_presentation,
                                size: screenWidth * 0.06,
                                color: CustomColors.clrblack,
                              ),
                            ),
                          ],
                        ),
                        const Divider(),
                        SizedBox(
                          height: screenWidth * 0.04,
                        ),

                        // GestureDetector(
                        //   onTap: () {
                        //     if (index < bhajanDataList.length) {
                        //       favouriteProvider.toggleBookmark(bhajanDataList[index]);
                        //       print("Added to favourite");
                        //     } else {
                        //       print("Invalid index");
                        //     }
                        //   },
                        //   child: Row(
                        //     children: [
                        //       Icon(
                        //         isFavourite ? Icons.favorite : Icons.favorite_border_sharp,
                        //         size: screenWidth * 0.06,
                        //         color: CustomColors.clrorange,
                        //       ),
                        //       SizedBox(width: screenWidth * 0.04),
                        //       Text(
                        //            "${ isFavourite ? "Remove from Favourite" : "Move to Favourite"}",
                        //            style: TextStyle(
                        //           fontSize: screenWidth * 0.04,
                        //           fontWeight: FontWeight.bold,
                        //         ),
                        //       ),
                        //     ],
                        //   ),
                        // ),

                        GestureDetector(
                          onTap: () {
                            favouriteProvider.toggleBookmark(
                                widget.isFixedTab
                                    ? allcategorymodel[index]
                                    : bhajanDataList[index],
                                isFixedTab: widget.isFixedTab);
                            print("Added to favourite");
                          },
                          child: Row(
                            children: [
                              Icon(
                                isFavourite
                                    ? Icons.favorite
                                    : Icons.favorite_border_sharp,
                                size: screenWidth * 0.06,
                                color: CustomColors.clrorange,
                              ),
                              SizedBox(width: screenWidth * 0.04),
                              Text(
                                getFavouriteText(isFavourite, languageProvider),
                                style: TextStyle(
                                  fontSize: screenWidth * 0.04,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: screenWidth * 0.04),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                                context,
                                CupertinoPageRoute(
                                  builder: (context) => Lyricsbhajan(
                                      musicLyrics: widget.isFixedTab
                                          ? allcategorymodel[index].lyrics
                                          : widget.isAllTab
                                              ? bhajanDataList[index].lyrics
                                              : bhajanDataList[index].lyrics,
                                      musicName: widget.isFixedTab
                                          ? allcategorymodel[index].title
                                          : widget.isAllTab
                                              ? bhajanDataList[index].title
                                              : bhajanDataList[index].title),
                                ));
                          },
                          child: Row(
                            children: [
                              Icon(
                                Icons.menu_book_outlined,
                                size: screenWidth * 0.06,
                                color: CustomColors.clrorange,
                              ),
                              SizedBox(width: screenWidth * 0.04),
                              Text(
                                languageProvider.language == 'English'
                                    ? "View Lyrics of the Music"
                                    : "संगीत के बोल देखें",
                                style: TextStyle(
                                  fontSize: screenWidth * 0.04,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }
}
