import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mahakal/features/blogs_module/no_image_widget.dart';
import 'package:mahakal/features/youtube_vedios/model/subcategory_model.dart';
import 'package:mahakal/features/youtube_vedios/view/dynamic_tabview/Youtube_Home_Page.dart';
import 'package:mahakal/features/youtube_vedios/view/tabsscreenviews/Playlist_Tab_Screen.dart';
import 'package:mahakal/utill/app_constants.dart';
import 'package:page_animation_transition/animations/right_to_left_transition.dart';
import 'package:page_animation_transition/page_animation_transition.dart';
import '../../../localization/language_constrants.dart';
import '../../../utill/dimensions.dart';
import '../model/sectionmodel.dart';

class SectionVideoSerials extends StatelessWidget {
  const SectionVideoSerials({
    super.key,
    required this.sectionModelList,
    required this.subcategorySerials,
  });

  final List<Sectionlist> sectionModelList;
  final List<KathaModel> subcategorySerials;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        sectionModelList[14].section.status == "true"
            ? Column(children: [
                Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(7),
                    margin: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 6.0),
                    decoration: BoxDecoration(
                        color: Colors.purple.shade50,
                        borderRadius: BorderRadius.circular(10)),
                    child: Row(
                      children: [
                        Container(
                          height: 15,
                          width: 4,
                          decoration: BoxDecoration(
                              color: Colors.purple,
                              borderRadius: BorderRadius.circular(20)),
                        ),
                        const SizedBox(
                          width: 5,
                        ),
                        Text(
                          getTranslated('devotional_serials', context) ??
                              "view All",
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
                                  color: Colors.purple,
                                  fontSize: Dimensions.fontSizeLarge,
                                  fontWeight: FontWeight.bold),
                            )),
                      ],
                    )),
                const SizedBox(height: 5),
                SizedBox(
                  height: 200,
                  child: ListView.builder(
                    padding: const EdgeInsets.only(left: 10),
                    physics: const BouncingScrollPhysics(),
                    itemCount: subcategorySerials.length,
                    shrinkWrap: true,
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (context, index) {
                      return InkWell(
                          onTap: () {
                            Navigator.push(
                                context,
                                CupertinoPageRoute(
                                    builder: (context) => PlaylistTabScreen(
                                          subCategoryId:
                                              subcategorySerials[index].id,
                                          categoryName: "Serials",
                                        )));
                          },
                          child: Container(
                            margin: const EdgeInsets.all(5),
                            //padding: EdgeInsets.all(5),
                            width: 145,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: CachedNetworkImage(
                                imageUrl:
                                    "${AppConstants.baseUrl}/storage/app/public/video-subcategory-img//${subcategorySerials[index].image}",
                                fit: BoxFit.fill,
                                width: double.infinity,
                                height: double.infinity,
                                errorWidget: (context, url, error) =>
                                    const NoImageWidget(),
                              ),
                            ),
                          )

                          // Container(
                          //   margin: const EdgeInsets.only(right: 5, bottom: 10),
                          //   width: 140,
                          //   decoration: BoxDecoration(
                          //       color: Colors.white,
                          //       border: Border.all(
                          //           color: Colors.grey.shade300, width: 1.5),
                          //       borderRadius: BorderRadius.circular(8.0)),
                          //   child: Padding(
                          //     padding: const EdgeInsets.all(4.0),
                          //     child: Column(
                          //       crossAxisAlignment: CrossAxisAlignment.start,
                          //       children: [
                          //         Expanded(
                          //             flex: 2,
                          //             child: Container(
                          //               height: 130,
                          //               width: 130,
                          //               decoration: BoxDecoration(
                          //                 borderRadius: BorderRadius.circular(8),
                          //                 color: Colors.grey.shade300,
                          //               ),
                          //               child: ClipRRect(
                          //                 borderRadius: const BorderRadius.only(
                          //                   topRight: Radius.circular(6),
                          //                   topLeft: Radius.circular(6),
                          //                 ),
                          //                 child: CachedNetworkImage(
                          //                   imageUrl:
                          //                       "${AppConstants.baseUrl}/storage/app/public/video-subcategory-img//${subcategorySerials[index].image}",
                          //                   fit: BoxFit.fill,
                          //                   errorWidget: (context, url, error) =>
                          //                       const NoImageWidget(),
                          //                 ),
                          //               ),
                          //             )),
                          //         Expanded(
                          //             flex: 0,
                          //             child: Padding(
                          //               padding: const EdgeInsets.symmetric(
                          //                   vertical: 2, horizontal: 4),
                          //               child: Row(
                          //                 mainAxisAlignment:
                          //                     MainAxisAlignment.spaceEvenly,
                          //                 children: [
                          //                   Expanded(
                          //                       flex: 1,
                          //                       child: Text(
                          //                         subcategorySerials[index].name,
                          //                         style: const TextStyle(
                          //                             fontWeight: FontWeight.w400,
                          //                             fontSize: 16),
                          //                         maxLines: 1,
                          //                       )),
                          //                   const SizedBox(
                          //                     width: 3,
                          //                   ),
                          //                   const Expanded(
                          //                       flex: 0,
                          //                       child: Icon(
                          //                         Icons.play_circle,
                          //                         color: Colors.orange,
                          //                       ))
                          //                 ],
                          //               ),
                          //             )),
                          //       ],
                          //     ),
                          //   ),
                          // ),
                          );
                    },
                  ),
                ),
                const SizedBox(height: 15),
              ])
            : const SizedBox.shrink(),
      ],
    );
  }
}
