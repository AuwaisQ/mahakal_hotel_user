import 'package:flutter/material.dart';
import 'package:mahakal/features/explore/exploreScreen.dart';
import 'package:mahakal/localization/language_constrants.dart';
import 'package:mahakal/utill/color_resources.dart';
import 'package:mahakal/utill/dimensions.dart';
import 'package:page_animation_transition/animations/right_to_left_transition.dart';
import 'package:page_animation_transition/page_animation_transition.dart';
import '../../../utill/completed_order_dialog.dart';
import '../../maha_bhandar/screen/maha_bhandar_screen.dart';
import '../model/sectionmodel.dart';

class SectionPanchang extends StatelessWidget {
  const SectionPanchang({
    super.key,
    required this.sectionModelList,
    required this.tithiName,
    required this.size,
    required this.address2,
    required this.address1,
    required this.lat,
    required this.long,
  });

  final List<Sectionlist> sectionModelList;
  final String tithiName;
  final Size size;
  final String address2;
  final String address1;
  final dynamic lat;
  final dynamic long;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        sectionModelList[0].section.status == "true"
            ? Column(
                children: [
                  Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(7),
                        margin: const EdgeInsets.symmetric(horizontal: 10),
                        decoration: BoxDecoration(
                            color: Theme.of(context)
                                .primaryColor
                                .withOpacity(0.15),
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
                            const SizedBox(width: 5),
                            Text(
                              getTranslated('view_panchang', context) ??
                                  "Panchang",
                              style: TextStyle(
                                  fontSize: Dimensions.fontSizeLarge,
                                  fontWeight: FontWeight.bold),
                            ),
                            const Spacer(),
                            Text(
                              tithiName,
                              style: TextStyle(
                                  fontSize: Dimensions.fontSizeLarge,
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        )),

                  Container(
                    margin: const EdgeInsets.all(7),
                    padding: const EdgeInsets.all(7),
                    height: size.width * 0.56,
                    width: double.infinity,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          //Today's Tab
                          InkWell(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  PageAnimationTransition(
                                      page: const MahaBhandar(tab: 0),
                                      pageAnimationType:
                                          RightToLeftTransition()));
                            },
                            child: SizedBox(
                              // height: size.width * 0.50,
                              width: size.width * 0.52,
                              child: Card(
                                child: ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: Image.asset(
                                      'assets/animated/panchang-poster.gif',
                                      fit: BoxFit.cover,
                                    )),
                              ),
                            ),
                          ),

                          //Other Tabs
                          SizedBox(
                            width: size.width * 0.8,
                            child: Card(
                              surfaceTintColor: Colors.white,
                              // elevation: 10,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    // crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Flexible(
                                          child: CategroyWidgetExplore(
                                        image:
                                            'assets/images/allcategories/Subh_muhurt_b.png',
                                        name: getTranslated(
                                                'shubh_muhrat_title',
                                                context) ??
                                            'Muhurt',
                                        color: Colors.black,
                                        onTap: () {
                                          Navigator.push(
                                              context,
                                              PageAnimationTransition(
                                                  page:
                                                      const MahaBhandar(tab: 5),
                                                  pageAnimationType:
                                                      RightToLeftTransition()));
                                        },
                                      )),
                                      Flexible(
                                        child: Container(
                                          height: size.width * 0.25,
                                          width: 0.7,
                                          color: Colors.grey,
                                        ),
                                      ),
                                      Flexible(
                                          child: CategroyWidgetExplore(
                                        image:
                                            'assets/images/allcategories/Vrat Icon.png',
                                        name: getTranslated('fast', context) ??
                                            'Fast',
                                        color: Colors.black,
                                        onTap: () {
                                          Navigator.push(
                                              context,
                                              PageAnimationTransition(
                                                  page:
                                                      const MahaBhandar(tab: 6),
                                                  pageAnimationType:
                                                      RightToLeftTransition()));
                                        },
                                      )),
                                      Flexible(
                                        child: Container(
                                          height: size.width * 0.25,
                                          width: 0.7,
                                          color: Colors.grey,
                                        ),
                                      ),
                                      Flexible(
                                          child: CategroyWidgetExplore(
                                        image:
                                            'assets/images/allcategories/animate/Hora icon animation.gif',
                                        name: getTranslated('hora', context) ??
                                            'Hora',
                                        color: Colors.black,
                                        onTap: () {
                                          Navigator.push(
                                              context,
                                              PageAnimationTransition(
                                                  page:
                                                      const MahaBhandar(tab: 3),
                                                  pageAnimationType:
                                                      RightToLeftTransition()));
                                        },
                                      )),
                                    ],
                                  ),
                                  const Divider(
                                    height: 0,
                                    color: ColorResources.grey,
                                    thickness: 3,
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    // crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Flexible(
                                          child: CategroyWidgetExplore(
                                        image:
                                            'assets/images/allcategories/animate/Panchang_icon_animated_1.gif',
                                        name: getTranslated(
                                                'panchang', context) ??
                                            'Panchang',
                                        color: Colors.black,
                                        onTap: () {
                                          Navigator.push(
                                              context,
                                              PageAnimationTransition(
                                                  page:
                                                      const MahaBhandar(tab: 1),
                                                  pageAnimationType:
                                                      RightToLeftTransition()));
                                        },
                                      )),
                                      Flexible(
                                        child: Container(
                                          height: size.width * 0.25,
                                          width: 0.7,
                                          color: Colors.grey,
                                        ),
                                      ),
                                      Flexible(
                                          child: CategroyWidgetExplore(
                                        image:
                                            'assets/images/allcategories/Festival icon.png',
                                        name: getTranslated(
                                                'festival', context) ??
                                            'Festival',
                                        color: Colors.black,
                                        onTap: () {
                                          Navigator.push(
                                              context,
                                              PageAnimationTransition(
                                                  page:
                                                      const MahaBhandar(tab: 7),
                                                  pageAnimationType:
                                                      RightToLeftTransition()));
                                        },
                                      )),
                                      Flexible(
                                        child: Container(
                                          height: size.width * 0.25,
                                          width: 0.7,
                                          color: Colors.grey,
                                        ),
                                      ),
                                      Flexible(
                                          child: CategroyWidgetExplore(
                                        image:
                                            'assets/images/allcategories/Choghadiya icon.png',
                                        name: getTranslated(
                                                'choghadiya', context) ??
                                            'Choghadiya',
                                        color: Colors.black,
                                        onTap: () {
                                          Navigator.push(
                                              context,
                                              PageAnimationTransition(
                                                  page:
                                                      const MahaBhandar(tab: 2),
                                                  pageAnimationType:
                                                      RightToLeftTransition()));
                                        },
                                      )),
                                      // categoryWidget(image: 'assets/images/mahakal_logo_circle.png', name: 'See\nMore',color: Colors.black),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
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
