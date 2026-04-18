import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mahakal/features/youtube_vedios/model/subcategory_model.dart';
import 'package:mahakal/features/youtube_vedios/view/dynamic_tabview/Youtube_Home_Page.dart';
import 'package:mahakal/features/youtube_vedios/view/tabsscreenviews/Playlist_Tab_Screen.dart';
import 'package:mahakal/localization/language_constrants.dart';
import 'package:mahakal/utill/app_constants.dart';
import 'package:mahakal/utill/dimensions.dart';
import 'package:page_animation_transition/animations/right_to_left_transition.dart';
import 'package:page_animation_transition/page_animation_transition.dart';
import '../../blogs_module/no_image_widget.dart';
import '../model/sectionmodel.dart';

class SectionDevotionalMovies extends StatelessWidget {
  const SectionDevotionalMovies({
    super.key,
    required this.sectionModelList,
    required this.subcategoryMovies,
  });

  final List<Sectionlist> sectionModelList;
  final List<KathaModel> subcategoryMovies;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        sectionModelList[16].section.status == "true"
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
                          getTranslated('devotional_movies', context) ??
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
                    itemCount: subcategoryMovies.length,
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
                                              subcategoryMovies[index].id,
                                          categoryName: "Movies",
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
                                    "${AppConstants.baseUrl}/storage/app/public/video-subcategory-img//${subcategoryMovies[index].image}",
                                fit: BoxFit.fill,
                                width: double.infinity,
                                height: double.infinity,
                                errorWidget: (context, url, error) =>
                                    const NoImageWidget(),
                              ),
                            ),
                          ));
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
