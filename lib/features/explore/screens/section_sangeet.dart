import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:mahakal/features/sangeet/model/category_model.dart';
import 'package:mahakal/features/sangeet/view/sangeet_home/sangit_home.dart';
import 'package:mahakal/localization/language_constrants.dart';
import 'package:mahakal/utill/color_resources.dart';
import 'package:mahakal/utill/custom_themes.dart';
import 'package:mahakal/utill/dimensions.dart';
import 'package:page_animation_transition/animations/right_to_left_transition.dart';
import 'package:page_animation_transition/page_animation_transition.dart';
import '../model/sectionmodel.dart';

class SectionSangeet extends StatelessWidget {
  const SectionSangeet({
    super.key,
    required this.sectionModelList,
    required this.sangeetModelList,
  });

  final List<Sectionlist> sectionModelList;
  final List<SangeetCategory> sangeetModelList;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        sectionModelList[13].section.status == "true"
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
                          getTranslated('devotional_music', context) ??
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
                                      page: const SangitHome(
                                        tabiIndex: 1,
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
                const SizedBox(height: 10),
                SizedBox(
                  height: 120,
                  child: ListView.builder(
                    padding: EdgeInsets.zero,
                    scrollDirection: Axis.horizontal,
                    itemCount: sangeetModelList.length,
                    shrinkWrap: true,
                    itemBuilder: (BuildContext context, int index) {
                      return InkWell(
                          splashColor: Colors.transparent,
                          highlightColor: Colors.transparent,
                          onTap: () {
                            Navigator.push(
                                context,
                                PageAnimationTransition(
                                    page: SangitHome(
                                      tabiIndex: index + 1,
                                    ),
                                    pageAnimationType:
                                        RightToLeftTransition()));
                          },
                          child: Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 5.0),
                            child: Column(children: [
                              Padding(
                                padding: const EdgeInsets.all(4.0),
                                child: CircleAvatar(
                                  backgroundColor:
                                      Theme.of(context).primaryColor,
                                  radius: 35,
                                  child: CircleAvatar(
                                    radius: 34,
                                    backgroundColor: Colors.white,
                                    backgroundImage: CachedNetworkImageProvider(
                                      sangeetModelList[index].image,
                                    ),
                                  ),
                                ),
                              ),
                              Center(
                                  child: Text(sangeetModelList[index].enName,
                                      textAlign: TextAlign.center,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: textRegular.copyWith(
                                          fontWeight: FontWeight.w500,
                                          letterSpacing: 0.7,
                                          fontSize: Dimensions.fontSizeSmall,
                                          color: ColorResources.getTextTitle(
                                              context))))
                            ]),
                          ));
                    },
                  ),
                ),
              ])
            : const SizedBox.shrink(),
      ],
    );
  }
}
