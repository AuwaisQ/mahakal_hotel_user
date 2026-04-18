import 'package:flutter/material.dart';
import 'package:mahakal/features/explore/rashifalModel.dart';
import 'package:mahakal/features/rashi_fal/rsahi_fal_screen.dart';
import 'package:mahakal/localization/language_constrants.dart';
import 'package:mahakal/utill/color_resources.dart';
import 'package:mahakal/utill/custom_themes.dart';
import 'package:mahakal/utill/dimensions.dart';
import 'package:page_animation_transition/animations/right_to_left_transition.dart';
import 'package:page_animation_transition/page_animation_transition.dart';
import 'package:provider/provider.dart';
import '../../../localization/controllers/localization_controller.dart';
import '../model/sectionmodel.dart';

class SectionRashifal extends StatelessWidget {
  const SectionRashifal({
    super.key,
    required this.sectionModelList,
    required this.size,
    required this.rashiList,
    required this.rashiListName,
  });

  final List<Sectionlist> sectionModelList;
  final Size size;
  final List<Rashi> rashiList;
  final List<String> rashiListName;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        sectionModelList[3].section.status == "true"
            ? Column(
                children: [
                  Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(7),
                      margin: const EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                          color:
                              Theme.of(context).primaryColor.withOpacity(0.15),
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
                            getTranslated('rashifal', context) ?? "Rashifal",
                            style: TextStyle(
                                fontSize: Dimensions.fontSizeLarge,
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      )),
                  const SizedBox(
                    height: 10,
                  ),
                  SizedBox(
                    height: size.width / 3.7,
                    child: ListView.builder(
                      padding: EdgeInsets.zero,
                      scrollDirection: Axis.horizontal,
                      itemCount: rashiList.length,
                      shrinkWrap: true,
                      itemBuilder: (BuildContext context, int index) {
                        return InkWell(
                            splashColor: Colors.transparent,
                            highlightColor: Colors.transparent,
                            onTap: () {
                              Navigator.push(
                                  context,
                                  PageAnimationTransition(
                                      page: RashiFallView(
                                        rashiName: rashiListName[index],
                                        rashiNameList: rashiList,
                                        index: index,
                                        context: context,
                                      ),
                                      pageAnimationType:
                                          RightToLeftTransition()));
                            },
                            child: Column(children: [
                              Padding(
                                padding: const EdgeInsets.all(3.0),
                                child: CircleAvatar(
                                  backgroundColor:
                                      Theme.of(context).primaryColor,
                                  radius: 31,
                                  child: CircleAvatar(
                                      radius: 30,
                                      backgroundColor: Colors.white,
                                      backgroundImage:
                                          AssetImage(rashiList[index].image)),
                                ),
                              ),
                              const SizedBox(
                                  height:
                                      Dimensions.paddingSizeExtraExtraSmall),
                              Center(
                                  child: SizedBox(
                                      width: size.width / 6.4,
                                      child: Text(rashiList[index].name,
                                          textAlign: TextAlign.center,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: textRegular.copyWith(
                                              fontWeight:
                                                  Provider.of<LocalizationController>(
                                                                  context)
                                                              .locale
                                                              .languageCode ==
                                                          'hi'
                                                      ? FontWeight.bold
                                                      : FontWeight.w500,
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
                  const SizedBox(
                    height: 5,
                  ),
                ],
              )
            : const SizedBox.shrink(),
      ],
    );
  }
}
