import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controller/audio_controller.dart';
import '../../controller/settings_controller.dart';
import '../../ui_helpers/custom_colors.dart';
import '../bookmarkscreen.dart';
import '../detail_gita_shlok/gita_screen.dart';
import '../../model/gits_static_model.dart';

class SahityaChapters extends StatefulWidget {
  final bool? isToast;

  const SahityaChapters({super.key, this.isToast});

  @override
  State<SahityaChapters> createState() => _SahityaChaptersState();
}

class _SahityaChaptersState extends State<SahityaChapters> {
  late AudioPlayerManagerSahitya audioManager = AudioPlayerManagerSahitya();

  bool isLoading = true;

  List<GitaItems> gitaItems = [
    GitaItems(
        enName: "ARJUN VISHAD YOGA",
        hiName: "अर्जुन विषद योग",
        serailNumber: 1,
        totalCount: 47),
    GitaItems(
        enName: "SANKHYA YOGA",
        hiName: "सांख्य योग",
        serailNumber: 2,
        totalCount: 72),
    GitaItems(
        enName: "KARMA YOGA",
        hiName: "कर्म योग",
        serailNumber: 3,
        totalCount: 43),
    GitaItems(
        enName: "GYAAN KARMA SANNYAAS YOGA",
        hiName: "ज्ञान कर्म संन्यास योग",
        serailNumber: 4,
        totalCount: 42),
    GitaItems(
        enName: "KARMA SANNYASA YOGA",
        hiName: "कर्म संन्यास योग",
        serailNumber: 5,
        totalCount: 29),
    GitaItems(
        enName: "DHYAAN YOGA",
        hiName: "ध्यान योग",
        serailNumber: 6,
        totalCount: 47),
    GitaItems(
        enName: "GYAAN VIGYAAN YOG",
        hiName: "ज्ञान विज्ञान योग",
        serailNumber: 7,
        totalCount: 30),
    GitaItems(
        enName: "AKSHAR BRAHMA YOGA",
        hiName: "अक्षर ब्रह्म योग",
        serailNumber: 8,
        totalCount: 28),
    GitaItems(
        enName: "RAJVIDYA RAJGUHYA YOGA",
        hiName: "राजविद्या राजगुह्य योग",
        serailNumber: 9,
        totalCount: 34),
    GitaItems(
        enName: "VIBHUTI YOGA",
        hiName: "विभूति योग",
        serailNumber: 10,
        totalCount: 42),
    GitaItems(
        enName: "VISHVARUP DARSHAN YOGA",
        hiName: "विश्वरूप दर्शन योग",
        serailNumber: 11,
        totalCount: 55),
    GitaItems(
        enName: "BHAKTIYOGA",
        hiName: "भक्तियोग",
        serailNumber: 12,
        totalCount: 20),
    GitaItems(
        enName: "KSHETR KSHETRAGY VIBHAAG YOGA",
        hiName: "क्षेत्रक्षेत्रविभाग योग",
        serailNumber: 13,
        totalCount: 35),
    GitaItems(
        enName: "GUNATRAY VIBHAG YOGA",
        hiName: "गुणत्रय विभाग योग",
        serailNumber: 14,
        totalCount: 27),
    GitaItems(
        enName: "PURUSHOTTAM YOGA",
        hiName: "पुरूषोत्तम योग",
        serailNumber: 15,
        totalCount: 0),
    GitaItems(
        enName: "DAIVASUR SAMPADA VIBHAG YOGA",
        hiName: "दैवसुर सम्पदा विभाग योग",
        serailNumber: 16,
        totalCount: 46),
    GitaItems(
        enName: "SHRADDHAATRAY VIBHAAG YOGA",
        hiName: "श्रद्धात्रय विभाग योग",
        serailNumber: 17,
        totalCount: 46),
    GitaItems(
        enName: "MOKSHA SANNYASA YOGA",
        hiName: "मोक्ष संन्यास योग",
        serailNumber: 18,
        totalCount: 46),
  ];

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    var screenWidth = MediaQuery.of(context).size.width;

    return Consumer<SettingsProvider>(
      builder: (BuildContext context, settingsProvider, Widget? child) {
        return Scaffold(
          appBar: AppBar(
            backgroundColor: settingsProvider.isOn
                ? CustomColors.clrblack
                : Theme.of(context).primaryColor,
            leading: IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: Icon(Icons.arrow_back_ios,
                    color: CustomColors.clrwhite, size: screenWidth * 0.06)),
            title: Text("Shrimad Bhagwat Geeta",
                style: TextStyle(
                    fontSize: screenWidth * 0.05,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Roboto',
                    color: CustomColors.clrwhite)),
            actions: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.08),
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                        context,
                        CupertinoPageRoute(
                          builder: (context) => const BookMark(),
                        ));
                  },
                  child: Icon(
                    Icons.bookmark,
                    color: CustomColors.clrwhite,
                    size: screenWidth * 0.06,
                  ),
                ),
              ),
            ],
          ),
          body: isLoading
              ? const Center(
                  child: CircularProgressIndicator(
                  color: Colors.orange,
                  backgroundColor: Colors.white,
                ))
              : SingleChildScrollView(
                  child: Column(
                    children: [
                      Container(
                          color: settingsProvider.isOn
                              ? CustomColors.clrwhite
                              : Colors.black,
                          child: Center(
                              child: Padding(
                            padding: EdgeInsets.symmetric(
                                vertical: screenWidth * 0.02),
                            child: Text(
                              'Continue Reading - Arjun Vishad Yog(1)',
                              style: TextStyle(
                                  fontFamily: 'Roboto',
                                  fontSize: screenWidth * 0.04,
                                  fontWeight: FontWeight.w600,
                                  color: settingsProvider.isOn
                                      ? CustomColors.clrblack
                                      : CustomColors.clrwhite),
                            ),
                          ))),
                      ListView.builder(
                        shrinkWrap: true,
                        padding:
                            EdgeInsets.symmetric(vertical: screenWidth * 0.05),
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: gitaItems.length,
                        itemBuilder: (context, index) {
                          final chapter = gitaItems[index];

                          return Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: screenWidth * 0.02,
                                vertical: screenWidth * 0.01),
                            child: Consumer<AudioPlayerManagerSahitya>(
                              builder: (BuildContext context, audioController,
                                  Widget? child) {
                                bool isCurrentSongPlaying =
                                    audioController.isPlaying &&
                                        gitaItems[index] ==
                                            audioController.currentMusic;

                                return Column(
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: screenWidth * 0.02),
                                      child: Row(
                                        children: [
                                          InkWell(
                                            onTap: () {
                                              Navigator.push(
                                                context,
                                                CupertinoPageRoute(
                                                  builder: (context) =>
                                                      GitaScreen(
                                                    myId: chapter.serailNumber,
                                                    verseCount: gitaItems[index].totalCount,
                                                  ),
                                                ),
                                              );
                                            },
                                            child: Consumer<SettingsProvider>(
                                              builder: (BuildContext context,
                                                  settingsProvider,
                                                  Widget? child) {
                                                return Row(
                                                  children: [
                                                    Container(
                                                      height: screenWidth * 0.1,
                                                      width: screenWidth * 0.1,
                                                      decoration:
                                                          const BoxDecoration(
                                                        image: DecorationImage(
                                                            image: AssetImage(
                                                                "assets/image/imagecircle.png"),
                                                            fit: BoxFit.cover),
                                                      ),
                                                      child: Center(
                                                        child: Text(
                                                          "${chapter.serailNumber}",
                                                          style: TextStyle(
                                                              fontSize:
                                                                  screenWidth *
                                                                      0.03,
                                                              fontFamily:
                                                                  'Roboto',
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                        ),
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding: EdgeInsets.only(
                                                          left: screenWidth *
                                                              0.05),
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: [
                                                          SizedBox(
                                                            width: screenWidth *
                                                                0.6,
                                                            child: Text(
                                                              chapter.hiName ??
                                                                  '',
                                                              style: TextStyle(
                                                                fontFamily:
                                                                    'Roboto',
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500,
                                                                fontSize:
                                                                    screenWidth *
                                                                        0.04,
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis,
                                                              ),
                                                              maxLines: 1,
                                                            ),
                                                          ),
                                                          SizedBox(
                                                            width: screenWidth *
                                                                0.6,
                                                            child: Text(
                                                              chapter.enName ??
                                                                  '',
                                                              style: TextStyle(
                                                                fontSize:
                                                                    screenWidth *
                                                                        0.05,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w400,
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis,
                                                              ),
                                                              maxLines: 1,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                );
                                              },
                                            ),
                                          ),
                                          const Spacer(),
                                        ],
                                      ),
                                    ),
                                    SizedBox(height: screenWidth * 0.02),
                                    Divider(
                                      height: screenWidth * 0.002,
                                      color: settingsProvider.isOn
                                          ? Colors.orangeAccent
                                          : CustomColors.clrblack,
                                    ),
                                  ],
                                );
                              },
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
          bottomNavigationBar: Visibility(
            visible: widget.isToast ?? false,
            child: Container(
              padding: const EdgeInsets.all(10.0),
              margin: const EdgeInsets.all(10.0),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.4),
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: const Text(
                "Data Not Found !",
                style: TextStyle(
                  fontSize: 16.0,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        );

        /// );
      },
    );
  }
}
