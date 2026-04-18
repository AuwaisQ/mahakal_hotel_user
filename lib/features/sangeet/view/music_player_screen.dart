import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../controller/all_audiocontroller.dart';
import '../controller/audio_manager.dart';
import '../controller/favourite_manager.dart';
import '../controller/language_manager.dart';
import '../controller/share_music.dart';
import '../model/sangeet_model.dart';
import '../ui_helper/custom_colors.dart';
import 'bhajantab_view/bhajan_list/bhajanlist_screen.dart';
import 'bhajantab_view/lyrics/lyricsbhajan.dart';

class MusicPlayer extends HookWidget {
  const MusicPlayer(
    this.godNameHindi, {
    required this.musicData,
    required this.categoryId,
    required this.subCategoryId,
    required this.allcategorymodel,
    required this.MyCurrentIndex,
    required this.subCategoryModel,
    required this.godName,
  });

  final int MyCurrentIndex;
  final List subCategoryModel;
  //final List allCategoryModel;
  final List<Sangeet> allcategorymodel;
  final String godName;
  final String godNameHindi;
  final List<Sangeet> musicData;
  final int categoryId;
  final int subCategoryId;

  //  bool isToggle = false;

  @override
  Widget build(BuildContext context) {
    var expandedBarHeight = MediaQuery.of(context).size.height * 0.63;
    var collapsedBarHeight = MediaQuery.of(context).size.height * 0.12;

    final selectedIndex = useState(0);
    final scrollController = useScrollController();
    final isCollapsed = useState(false);
    final didAddFeedback = useState(false);

    var screenWidth = MediaQuery.of(context).size.width;

    List filteredCategories =
        subCategoryModel.where((cat) => cat.status != 0).toList();

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
            child: Consumer<LanguageManager>(
              builder: (BuildContext context, languageManager, Widget? child) {
                return Text(
                  languageManager.selectedLanguage == 'English' ? "All" : "सभी",
                  style: TextStyle(
                      fontSize: screenWidth * 0.03,
                      fontWeight: FontWeight.bold),
                );
              },
            ),
          ),
        ),
      ),
      ...filteredCategories.map((cat) {
        int index = filteredCategories.indexOf(cat) + 1;
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
              child: Consumer<LanguageManager>(
                builder:
                    (BuildContext context, languageManager, Widget? child) {
                  return Text(
                    languageManager.selectedLanguage == 'English'
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
      }),
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
          child: DefaultTabController(
            length: filteredCategories.length + 1,
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
                              musicData: musicData,
                              allcategorymodel: allcategorymodel,
                              selectedIndex:
                                  selectedIndex.value, // Cast to List<Sangeet>
                            )),
                        elevation: 0,
                        backgroundColor: isCollapsed.value
                            ? Theme.of(context).primaryColor
                            : Colors.transparent,
                        flexibleSpace: FlexibleSpaceBar(
                          background: ExpandedAppBarContent(
                            audioManager: audioManager,
                            allcategorymodel: allcategorymodel,
                            musicData: musicData,
                            selectedIndex: selectedIndex.value,
                            musicIndex: MyCurrentIndex,
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
                                  child: Consumer<LanguageManager>(
                                    builder: (BuildContext context,
                                        languageManager, Widget? child) {
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
                                            languageManager.selectedLanguage ==
                                                    'English'
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
                                  unselectedLabelColor: CustomColors.clrblack,
                                  labelColor: CustomColors.clrwhite,
                                  indicatorWeight: 0.1,
                                  tabAlignment: TabAlignment.start,
                                  indicator: BoxDecoration(
                                      color: Colors.orange,
                                      borderRadius: BorderRadius.circular(5)),
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
                      BhajanList(
                        subCategoryId,
                        subCategoryModel,
                        godName,
                        godNameHindi,
                        categoryId: categoryId,
                        isToggle: false,
                        isFixedTab: true,
                        isAllTab: false,
                        isMusicBarVisible: false,
                      ),
                      ...filteredCategories.map((cat) => BhajanList(
                            cat.id,
                            filteredCategories,
                            godName,
                            godNameHindi,
                            categoryId: categoryId,
                            isToggle: false,
                            isFixedTab: false,
                            isAllTab: true,
                            isMusicBarVisible: false,
                          ))
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
}

class CollapsedAppBarContent extends StatefulWidget {
  final AudioPlayerManager audioManager;
  final List<Sangeet> allcategorymodel;
  final List musicData;
  final int selectedIndex;

  CollapsedAppBarContent({
    required this.audioManager,
    required this.musicData,
    required this.allcategorymodel,
    required this.selectedIndex,
  });

  @override
  State<CollapsedAppBarContent> createState() => _CollapsedAppBarContentState();
}

class _CollapsedAppBarContentState extends State<CollapsedAppBarContent> {
  void playMusic(int index) {
    if (widget.audioManager != null) {
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
  }

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
                    // Skip Previous Button
                    GestureDetector(
                      onTap: () {
                        if (audioManager != null) {
                          if (widget.selectedIndex == 0) {
                            // Fixed tab logic

                            Sangeet? currentMusic = audioManager.currentMusic;

                            if (currentMusic != null) {
                              int currentIndex =
                                  widget.allcategorymodel.indexOf(currentMusic);

                              print("Current $currentIndex");
                              //if (currentIndex != -1) {
                              // if (currentIndex > 0) {

                              // Play the previous song

                              if (audioManager.fixedTabMusic) {
                                audioManager.skipPrevious(
                                    isFix: true); //playMusic(currentIndex + 1);
                              } else {
                                playMusic(currentIndex - 1);
                              }
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
                                audioManager.playMusic(
                                    widget.allcategorymodel.last, true);
                              } else {
                                print("No music available in the list");
                              }
                            }
                          } else {
                            print(
                                "skip next is working for dynamic ddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd");

                            // Dynamic tab logic
                            audioManager.skipPrevious(
                                isFix:
                                    false); // Skip to previous song in the dynamic list
                          }
                        }
                      },
                      child: Icon(
                        Icons.skip_previous,
                        color: CustomColors.clrwhite,
                        size: screenWidth * 0.08,
                      ),
                    ),

                    SizedBox(
                      width: screenWidth * 0.05,
                    ),
                    // Toggle Play/Pause Button
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

                    // Skip Next Button
                    // GestureDetector(
                    //   onTap: () {
                    //     if (audioManager != null) {
                    //       if (widget.selectedIndex == 0) {
                    //         print("selected index == 0");
                    //         // Fixed tab logic
                    //         Sangeet? currentMusic = audioManager.currentMusic;
                    //
                    //         if (currentMusic != null) {
                    //           print("selected index == 0");
                    //           int currentIndex = widget.allcategorymodel.indexOf(currentMusic);
                    //
                    //           //  if (currentIndex != -1) {
                    //           if (currentIndex < widget.allcategorymodel.length - 1) {
                    //
                    //             if(audioManager.fixedTabMusic){
                    //               audioManager.skipNext(true);
                    //             } else{
                    //               playMusic(currentIndex + 1);
                    //             }
                    //           } else {
                    //             // Loop back to the first song
                    //             audioManager.playMusic(widget.allcategorymodel.first,true);
                    //           }
                    //
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
                    //         print("Dynamic Skip is working");
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

                    GestureDetector(
                      onTap: () {
                        if (audioManager != null) {
                          if (widget.selectedIndex == 0) {
                            // Fixed tab logic
                            print("Skip Next for");
                            Sangeet? currentMusic = audioManager.currentMusic;

                            if (currentMusic != null) {
                              print("Skip Next");

                              int currentIndex =
                                  widget.allcategorymodel.indexOf(currentMusic);

                              //  if (currentIndex != -1) {
                              if (currentIndex <
                                  widget.allcategorymodel.length - 1) {
                                print("Skip Next");

                                // Play the next song

                                if (audioManager.fixedTabMusic) {
                                  audioManager.skipNext(
                                      true); //playMusic(currentIndex + 1);
                                } else {
                                  playMusic(currentIndex + 1);
                                }
                                //  audioManager.skipNext(true);
                                // audioManager.playMusic(widget.allcategorymodel[currentIndex + 1],true);
                              } else {
                                // Loop back to the first song
                                audioManager.playMusic(
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
                                audioManager.playMusic(
                                    widget.allcategorymodel.first, true);
                              } else {
                                print("No music available in the list");
                              }
                            }
                          } else {
                            // Dynamic tab logic
                            print("Skip Next for");
                            audioManager.skipNext(
                                false); // Skip to next song in the dynamic list
                          }
                        }
                      },
                      child: Icon(
                        Icons.skip_next,
                        color: CustomColors.clrwhite,
                        size: screenWidth * 0.08,
                      ),
                    ),
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

  const BlurredBackdropImage({required this.audioManager});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: MediaQuery.of(context).size.height / 1.5,
      child: Stack(
        fit: StackFit.expand,
        children: [
          CachedNetworkImage(
            imageUrl: audioManager.currentMusic?.image ?? "default_image_url",
            fit: BoxFit.cover,
            errorWidget: (context, url, error) =>
                Icon(Icons.broken_image, size: 50, color: Colors.grey),
          ),

          // Black Transparent Overlay
          Container(
            color:
                Colors.black.withOpacity(0.5), // Black overlay with 50% opacity
          ),
        ],
      ),
    );
  }
}

class ExpandedAppBarContent extends StatefulWidget {
  final AudioPlayerManager audioManager;
  final List<Sangeet> allcategorymodel;
  final List<Sangeet> musicData;
  final int selectedIndex;
  final int musicIndex;

  ExpandedAppBarContent(
      {required this.audioManager,
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

  void playMusic(int index) {
    if (widget.audioManager != null) {
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
                    .any((favourite) => favourite!.audio == currentMusic.audio);

                return Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: screenWidth * 0.10),
                    Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: screenWidth * 0.02, vertical: 12),
                      child: Container(
                        padding:
                            EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.65),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 10,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            /// Back Button
                            GestureDetector(
                              onTap: () {
                                Navigator.pop(context);
                              },
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.arrow_back_ios_new_rounded,
                                      color: Colors.white,
                                      size: screenWidth * 0.07),
                                  const SizedBox(height: 4),
                                  const Text("Back",
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 12)),
                                ],
                              ),
                            ),

                            /// Share Button
                            GestureDetector(
                              onTap: () {
                                shareMusic.shareSong(
                                    audiomanager.currentMusic!, context);
                              },
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.share,
                                      color: Colors.white,
                                      size: screenWidth * 0.07),
                                  const SizedBox(height: 4),
                                  const Text("Share",
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 12)),
                                ],
                              ),
                            ),

                            /// Lyrics Button
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  CupertinoPageRoute(
                                    builder: (context) => Lyricsbhajan(
                                      musicLyrics:
                                          audiomanager.currentMusic!.lyrics,
                                      musicName:
                                          audiomanager.currentMusic!.title,
                                    ),
                                  ),
                                );
                              },
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.article,
                                      color: Colors.white,
                                      size: screenWidth * 0.07),
                                  const SizedBox(height: 4),
                                  const Text("Lyrics",
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 12)),
                                ],
                              ),
                            ),
                          ],
                        ),
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
                          /// Shuffle Button
                          GestureDetector(
                              onTap: () => _showShuffleOptionsDialog(
                                  context, audiomanager),
                              child: Icon(Icons.shuffle,
                                  size: screenWidth * 0.08,
                                  color: CustomColors.clrwhite)),
                          SizedBox(width: screenHeight * 0.07),

                          /// Skip Previous
                          GestureDetector(
                            onTap: () {
                              if (audiomanager != null) {
                                if (widget.selectedIndex == 0) {
                                  // Fixed tab logic

                                  Sangeet? currentMusic =
                                      audiomanager.currentMusic;

                                  if (currentMusic != null) {
                                    int currentIndex = widget.allcategorymodel
                                        .indexOf(currentMusic);

                                    print("Current $currentIndex");

                                    if (audiomanager.fixedTabMusic) {
                                      audiomanager.skipPrevious(
                                          isFix:
                                              true); //playMusic(currentIndex + 1);
                                    } else {
                                      playMusic(currentIndex - 1);
                                    }
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
                              }
                            },
                            child: Icon(
                              Icons.skip_previous,
                              color: CustomColors.clrwhite,
                              size: screenWidth * 0.08,
                            ),
                          ),

                          /// Toggle Paly Pause
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
                              if (audiomanager != null) {
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
                                      } else {
                                        playMusic(currentIndex + 1);
                                      }
                                    } else {
                                      // Loop back to the first song
                                      audiomanager.playMusic(
                                          widget.allcategorymodel.first, true);
                                    }
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
                              }
                            },
                            child: Icon(
                              Icons.skip_next,
                              color: CustomColors.clrwhite,
                              size: screenWidth * 0.08,
                            ),
                          ),

                          Spacer(),

                          /// Favourite
                          GestureDetector(
                            onTap: () {
                              favouriteProvider.toggleBookmark(currentMusic!);
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
                return const Center(child: Text("No music selected"));
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
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 10),
                  height: 2,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.yellow, // Start color
                        Colors.red, // Start color
                        Colors.yellow, // End color
                      ],
                      begin:
                          Alignment.topLeft, // Starting point of the gradient
                      end:
                          Alignment.bottomRight, // Ending point of the gradient
                    ),
                  ),
                ),
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
                      Spacer(),
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
