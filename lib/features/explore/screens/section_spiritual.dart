import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mahakal/features/youtube_vedios/model/subcategory_model.dart';
import 'package:mahakal/features/youtube_vedios/view/dynamic_tabview/Youtube_Home_Page.dart';
import 'package:mahakal/features/youtube_vedios/view/tabsscreenviews/Playlist_Tab_Screen.dart';
import 'package:mahakal/localization/language_constrants.dart';
import 'package:mahakal/utill/app_constants.dart';
import 'package:mahakal/utill/color_resources.dart';
import 'package:mahakal/utill/custom_themes.dart';
import 'package:mahakal/utill/dimensions.dart';
import 'package:page_animation_transition/animations/right_to_left_transition.dart';
import 'package:page_animation_transition/page_animation_transition.dart';
import '../model/sectionmodel.dart';

class SectionSpiritual extends StatelessWidget {
  const SectionSpiritual({
    super.key,
    required this.sectionModelList,
    required this.size,
    required this.subcategory,
  });

  final List<Sectionlist> sectionModelList;
  final Size size;
  final List<KathaModel> subcategory;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        sectionModelList[15].section.status == "true"
            ? Column(children: [
                Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(7),
                    margin: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 6.0),
                    decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(10)),
                    child: Row(
                      children: [
                        Container(
                          height: 15,
                          width: 4,
                          decoration: BoxDecoration(
                              color: Colors.orange,
                              borderRadius: BorderRadius.circular(20)),
                        ),
                        const SizedBox(
                          width: 5,
                        ),
                        Text(
                          getTranslated('spritiual', context) ?? "view All",
                          style: TextStyle(
                              fontSize: Dimensions.fontSizeLarge,
                              fontWeight: FontWeight.bold),
                        ),
                        const Spacer(),
                        InkWell(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  PageAnimationTransition(
                                      page: const YoutubeHomePage(
                                        tabIndex: 0,
                                      ),
                                      pageAnimationType:
                                          RightToLeftTransition()));
                            },
                            child: Text(
                              getTranslated('VIEW_ALL', context) ?? "view All",
                              style: TextStyle(
                                  color: Colors.orange,
                                  fontSize: Dimensions.fontSizeLarge,
                                  fontWeight: FontWeight.bold),
                            )),
                      ],
                    )),
                const SizedBox(height: 5),
                Container(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5.0),
                  padding: const EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.shade300,
                          blurRadius: 6,
                          spreadRadius: 4,
                        )
                      ]),
                  child: SizedBox(
                    height: size.width / 3.1,
                    child: ListView.builder(
                      padding: EdgeInsets.zero,
                      scrollDirection: Axis.horizontal,
                      itemCount: subcategory.length,
                      shrinkWrap: true,
                      itemBuilder: (BuildContext context, int index) {
                        return InkWell(
                            splashColor: Colors.transparent,
                            highlightColor: Colors.transparent,
                            onTap: () {
                              Navigator.push(
                                  context,
                                  CupertinoPageRoute(
                                      builder: (context) => PlaylistTabScreen(
                                            subCategoryId:
                                                subcategory[index].id,
                                            categoryName: "Spritual Guru",
                                          )));
                            },
                            child: Column(children: [
                              Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 6.0, horizontal: 10.0),
                                  child: CircleAvatar(
                                    backgroundColor:
                                        Theme.of(context).primaryColor,
                                    radius: 35,
                                    child: CircleAvatar(
                                      radius: 34,
                                      backgroundColor: Colors.white,
                                      backgroundImage:
                                          CachedNetworkImageProvider(
                                        "${AppConstants.baseUrl}/storage/app/public/video-subcategory-img//${subcategory[index].image}",
                                      ),
                                    ),
                                  )),
                              Center(
                                  child: SizedBox(
                                      width: size.width / 6.2,
                                      child: Text(subcategory[index].name,
                                          textAlign: TextAlign.center,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: textRegular.copyWith(
                                              fontWeight: FontWeight.w500,
                                              letterSpacing: 0.7,
                                              fontSize:
                                                  Dimensions.fontSizeSmall,
                                              color:
                                                  ColorResources.getTextTitle(
                                                      context)))))
                            ]));
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 15),
              ])
            : const SizedBox.shrink(),
      ],
    );
  }
}
