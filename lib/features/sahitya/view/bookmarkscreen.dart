import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mahakal/features/sahitya/view/share_screen.dart';
import 'package:provider/provider.dart';
import '../../blogs_module/Controller/language_provider.dart';
import '../controller/bookmark_provider.dart';
import '../controller/settings_controller.dart';
import '../ui_helpers/custom_colors.dart';
import 'detail_gita_shlok/gita_screen.dart';

class BookMark extends StatefulWidget {
  const BookMark({super.key});

  @override
  State<BookMark> createState() => _BookMarkState();
}

class _BookMarkState extends State<BookMark> {
  @override
  Widget build(BuildContext context) {
    var screenWidth = MediaQuery.of(context).size.width;

    return DefaultTabController(
      length: 1,
      child: Scaffold(
          backgroundColor: CustomColors.clrwhite,
          appBar: AppBar(
            leading: IconButton(
              icon: Icon(
                Icons.arrow_back,
                color: CustomColors.clrwhite,
                size: screenWidth * 0.06,
              ),
              onPressed: () {
                Navigator.of(context).pop(); // Navigate back
              },
            ),
            title: Text('Bookmark',
                style: TextStyle(
                    color: CustomColors.clrwhite,
                    fontFamily: 'Roboto',
                    fontWeight: FontWeight.w600,
                    fontSize: screenWidth * 0.06)),
            backgroundColor: Theme.of(context).primaryColor,
          ),
          body: Column(
            children: [
              const TabBar(
                  unselectedLabelColor: Colors.grey,
                  labelColor: CustomColors.clrblack,
                  labelStyle:
                      TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  indicatorColor: CustomColors.clrorange,
                  dividerColor: Colors.transparent,
                  splashFactory: NoSplash.splashFactory,
                  indicatorSize: TabBarIndicatorSize.tab,
                  tabs: [
                    Tab(text: "❀❀❀ - Bhagvat Geeta Shlok - ❀❀❀"),
                    //Tab(text: "Chapter",),
                  ]),
              Expanded(
                  child: TabBarView(
                children: [
                  BookMarkShlOk(parentContext: context),
                  //  const BookMarkChapter()
                ],
              ))
            ],
          )),
    );
  }
}

class BookMarkShlOk extends StatefulWidget {
  final BuildContext parentContext;
  const BookMarkShlOk({super.key, required this.parentContext});

  @override
  State<BookMarkShlOk> createState() => _BookMarkShlOkState();
}

class _BookMarkShlOkState extends State<BookMarkShlOk> {
  @override
  Widget build(BuildContext context) {
    var screenWidth = MediaQuery.of(context).size.width;

    return Consumer<SettingsProvider>(
      builder: (BuildContext context, settingsProvider, Widget? child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: settingsProvider.isOn ? ThemeData.dark() : ThemeData.light(),
          home: Consumer<BookmarkProvider>(
            builder: (BuildContext context, bookmarkProvider, Widget? child) {
              return Scaffold(
                body: bookmarkProvider.bookMarkedShlokes.isEmpty
                    ? Column(
                        children: [
                          SizedBox(
                            height: screenWidth * 0.2,
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: screenWidth * 0.1),
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: Colors.grey),
                              ),
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                  vertical: screenWidth * 0.05,
                                ),
                                child: Consumer<BlogLanguageProvider>(
                                  builder: (BuildContext context,
                                      languageProvider, Widget? child) {
                                    return Column(
                                      children: [
                                        SizedBox(
                                          height: screenWidth * 0.03,
                                        ),
                                        Container(
                                          height: 100,
                                          width: 100,
                                          decoration: const BoxDecoration(
                                              image: DecorationImage(
                                                  image: NetworkImage(
                                                      "https://i2.pngimg.me/thumb/f/720/m2i8A0d3d3N4m2b1.jpg"))),
                                        ),
                                        SizedBox(
                                          height: screenWidth * 0.02,
                                        ),
                                        Padding(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: screenWidth * 0.14),
                                          child: Text(
                                            languageProvider.isEnglish
                                                ? "You haven't liked any verse yet!"
                                                : "आपने अभी तक कोई श्लोक पसंद नहीं किया है!",
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                                fontSize: screenWidth * 0.04,
                                                color: Colors.black,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                        SizedBox(
                                          height: screenWidth * 0.05,
                                        ),
                                        Padding(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: screenWidth * 0.06),
                                          child: Text(
                                            languageProvider.isEnglish
                                                ? "Please go to the Geeta collection and list your favorite verse!"
                                                : "कृपाया श्लोक संग्रह में जाए और अपने पसंदीदा श्लोक की सूची बनाएं!",
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontSize: screenWidth * 0.04,
                                              color:
                                                  Colors.black.withOpacity(0.5),
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          height: screenWidth * 0.02,
                                        ),
                                        Padding(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: screenWidth * 0.2),
                                          child: GestureDetector(
                                            onTap: () {
                                              Navigator.pushReplacement(
                                                widget
                                                    .parentContext, // Use the parent context here
                                                CupertinoPageRoute(
                                                    builder: (context) =>
                                                        GitaScreen(
                                                          verseCount: 47,
                                                          myId: 1,
                                                        )),
                                              );
                                            },
                                            child: Container(
                                              decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(20),
                                                  border: Border.all(
                                                      color: Colors.grey)),
                                              child: Padding(
                                                padding: EdgeInsets.symmetric(
                                                    vertical:
                                                        screenWidth * 0.02,
                                                    horizontal:
                                                        screenWidth * 0.03),
                                                child: Consumer<
                                                    BlogLanguageProvider>(
                                                  builder:
                                                      (BuildContext context,
                                                          languageProvider,
                                                          Widget? child) {
                                                    return Row(
                                                      children: [
                                                        const Icon(
                                                          Icons
                                                              .add_box_outlined,
                                                          color: CupertinoColors
                                                              .activeBlue,
                                                        ),
                                                        SizedBox(
                                                          width: screenWidth *
                                                              0.03,
                                                        ),
                                                        Text(
                                                            languageProvider
                                                                    .isEnglish
                                                                ? "like Verse"
                                                                : "श्लोक पसंद करे"
                                                            // languageManager.selectedLanguage == 'English' ? "like Music" : "ब्लॉग पसंद करे"
                                                            ,
                                                            style: const TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                color: CupertinoColors
                                                                    .activeBlue))
                                                      ],
                                                    );
                                                  },
                                                ),
                                              ),
                                            ),
                                          ),
                                        )
                                      ],
                                    );
                                  },
                                ),
                              ),
                            ),
                          )
                        ],
                      )
                    : ListView.builder(
                        shrinkWrap: true,
                        physics: const AlwaysScrollableScrollPhysics(),
                        itemCount: bookmarkProvider.bookMarkedShlokes.length,
                        itemBuilder: (context, index) {
                          final shloka =
                              bookmarkProvider.bookMarkedShlokes[index];

                          return GestureDetector(
                            onTap: () {
                              Navigator.pushReplacement(
                                widget
                                    .parentContext, // Use the parent context here
                                CupertinoPageRoute(
                                    builder: (context) => GitaScreen(
                                          verseCount: 47,
                                          myId: 1,
                                        )),
                              );
                            },
                            child: Column(
                              children: [
                                Consumer<SettingsProvider>(
                                  builder: (BuildContext context,
                                      settingsProvider, Widget? child) {
                                    return Container(
                                      color: settingsProvider.isOn
                                          ? CustomColors.clrblack
                                          : CustomColors.clrskin,
                                      child: Padding(
                                        padding: EdgeInsets.symmetric(
                                            vertical: screenWidth * 0.04,
                                            horizontal: screenWidth * 0.03),
                                        child: Column(
                                          children: [
                                            Container(
                                              decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  border: Border.all(
                                                      color:
                                                          settingsProvider.isOn
                                                              ? CustomColors
                                                                  .clrwhite
                                                              : CustomColors
                                                                  .clrblack)),
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(8),
                                                child: Text(
                                                  "${shloka.verse}",
                                                  style: const TextStyle(
                                                      fontSize: 14),
                                                ),
                                              ),
                                            ),
                                            Consumer<SettingsProvider>(
                                              builder: (BuildContext context,
                                                  settingsProvider,
                                                  Widget? child) {
                                                return Text(
                                                  "${shloka.verseData?.verseData?.sanskrit}",
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                    fontSize: settingsProvider
                                                        .fontSize,
                                                    color: settingsProvider.isOn
                                                        ? settingsProvider
                                                            .textColor
                                                        : CustomColors.clrblack,
                                                    fontFamily: settingsProvider
                                                        .selectedFont,
                                                  ),
                                                );
                                              },
                                            ),
                                            Padding(
                                                padding: EdgeInsets.symmetric(
                                                    horizontal:
                                                        screenWidth * 0.07,
                                                    vertical:
                                                        screenWidth * 0.05),
                                                child: Row(
                                                  children: [
                                                    GestureDetector(
                                                        onTap: () {
                                                          Navigator
                                                              .pushReplacement(
                                                            widget
                                                                .parentContext, // Use the parent context here
                                                            CupertinoPageRoute(
                                                                builder:
                                                                    (context) =>
                                                                        ShareScreen(
                                                                          gitaShlok:
                                                                              "${shloka.verseData?.verseData?.sanskrit}",
                                                                          shlokMeaning:
                                                                              "${shloka.verseData?.verseData?.hindi}",
                                                                          detailsModel:
                                                                              shloka,
                                                                        )),
                                                          );
                                                        },
                                                        child: Icon(
                                                          Icons.share_outlined,
                                                          color:
                                                              settingsProvider
                                                                      .isOn
                                                                  ? CustomColors
                                                                      .clrwhite
                                                                  : CustomColors
                                                                      .clrbrown,
                                                          size: screenWidth *
                                                              0.07,
                                                        )),
                                                    SizedBox(
                                                      width: screenWidth * 0.03,
                                                    ),
                                                    Consumer<BookmarkProvider>(
                                                      builder:
                                                          (BuildContext context,
                                                              bookmarkProvider,
                                                              Widget? child) {
                                                        final isBookmarked = bookmarkProvider
                                                            .bookMarkedShlokes
                                                            .any((bookmarked) =>
                                                                bookmarked
                                                                    .verseData
                                                                    ?.audioUrl ==
                                                                shloka.verseData
                                                                    ?.audioUrl);

                                                        return GestureDetector(
                                                          onTap: () {
                                                            bookmarkProvider
                                                                .toggleBookmark(
                                                                    shloka);
                                                          },
                                                          child: Icon(
                                                            isBookmarked
                                                                ? Icons.bookmark
                                                                : Icons
                                                                    .bookmark_border,
                                                            color: settingsProvider
                                                                    .isOn
                                                                ? CustomColors
                                                                    .clrwhite
                                                                : CustomColors
                                                                    .clrbrown,
                                                            size: screenWidth *
                                                                0.07,
                                                          ),
                                                        );
                                                      },
                                                    ),
                                                    const Spacer(),
                                                  ],
                                                )
                                                //   },
                                                // )
                                                )
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                                Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: screenWidth * 0.02,
                                      vertical: screenWidth * 0.002),
                                  child: Consumer<SettingsProvider>(
                                    builder: (BuildContext context,
                                        settingsProvider, Widget? child) {
                                      return Column(
                                        children: [
                                          Visibility(
                                            visible:
                                                settingsProvider.showHindiText,
                                            child: Column(
                                              children: [
                                                Text(
                                                  settingsProvider
                                                      .displayedText,
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                      fontSize: settingsProvider
                                                          .fontSize,
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      fontFamily: 'Roboto',
                                                      color: Colors.blue),
                                                ),
                                                Container(
                                                  height: screenWidth * 0.03,
                                                )
                                              ],
                                            ),
                                          ),
                                          Visibility(
                                            visible: settingsProvider
                                                .showEnglishText,
                                            child: Column(
                                              children: [
                                                Text(
                                                  "${shloka.verseData?.verseData?.english}",
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                      fontSize: settingsProvider
                                                          .fontSize,
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      fontFamily: 'Roboto'),
                                                ),
                                                Divider(
                                                  color: settingsProvider.isOn
                                                      ? CustomColors.clrorange
                                                      : CustomColors.clrblack,
                                                )
                                              ],
                                            ),
                                          ),
                                        ],
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              );
            },
          ),
        );
      },
    );
  }
}

// class BookMarkChapter extends StatelessWidget {
//   const BookMarkChapter({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return const Column(
//       children: [
//
//       ],
//     );
//   }
// }
