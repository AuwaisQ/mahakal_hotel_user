import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:mahakal/features/banner/controllers/banner_controller.dart';
import 'package:mahakal/features/explore/exploreScreen.dart';
import 'package:mahakal/features/janm_kundli/screens/kundliForm.dart';
import 'package:mahakal/features/kundli_milan/kundalimatching.dart';
import 'package:mahakal/features/lalkitab/lalkitabform.dart';
import 'package:mahakal/features/numerology/numerohome.dart';
import 'package:mahakal/localization/language_constrants.dart';
import 'package:mahakal/utill/color_resources.dart';
import 'package:mahakal/utill/dimensions.dart';
import 'package:page_animation_transition/animations/right_to_left_transition.dart';
import 'package:page_animation_transition/page_animation_transition.dart';
import 'package:provider/provider.dart';
import '../model/sectionmodel.dart';

class SectionAstrology extends StatelessWidget {
  const SectionAstrology({
    super.key,
    required this.sectionModelList,
    required this.size,
  });

  final List<Sectionlist> sectionModelList;
  final Size size;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        sectionModelList[2].section.status == "true"
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
                            getTranslated('vaidik_astrology', context) ??
                                "Vaidik Astrology",
                            style: TextStyle(
                                fontSize: Dimensions.fontSizeLarge,
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      )),
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                            flex: 1,
                            child: Card(
                              surfaceTintColor: Colors.white,
                              elevation: 10,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    // crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      CategroyWidgetExplore(
                                        image:
                                            'assets/testImage/categories/janamKundli.png',
                                        name: getTranslated(
                                                'janm_kundli', context) ??
                                            'Jnama\nKundli',
                                        color: Colors.black,
                                        onTap: () {
                                          Navigator.push(
                                              context,
                                              PageAnimationTransition(
                                                  page: const KundliForm(),
                                                  pageAnimationType:
                                                      RightToLeftTransition()));
                                        },
                                      ),
                                      Container(
                                        height: size.width * 0.235,
                                        width: 0.7,
                                        color: Colors.grey,
                                      ),
                                      CategroyWidgetExplore(
                                        image:
                                            'assets/images/allcategories/animate/Kundli_milan_icon animation.gif',
                                        name: getTranslated(
                                                'kundli_milan', context) ??
                                            'Kundli\nMilan',
                                        color: Colors.black,
                                        onTap: () {
                                          Navigator.push(
                                              context,
                                              PageAnimationTransition(
                                                  page:
                                                      const KundaliMatchingView(),
                                                  pageAnimationType:
                                                      RightToLeftTransition()));
                                        },
                                      ),
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
                                      SizedBox(
                                          width: size.width * 0.115,
                                          child: CategroyWidgetExplore(
                                            image:
                                                'assets/images/allcategories/Newmrology.png',
                                            name: getTranslated(
                                                    'numerology', context) ??
                                                'Numerology',
                                            color: Colors.black,
                                            onTap: () {
                                              Navigator.push(
                                                  context,
                                                  PageAnimationTransition(
                                                      page:
                                                          const NumeroFormView(),
                                                      pageAnimationType:
                                                          RightToLeftTransition()));
                                            },
                                          )),
                                      Container(
                                        height: size.width * 0.22,
                                        width: 0.7,
                                        color: Colors.grey,
                                      ),
                                      SizedBox(
                                          width: size.width * 0.115,
                                          child: CategroyWidgetExplore(
                                            image:
                                                'assets/images/allcategories/LalKitab_icon.png',
                                            name: 'Laal Kitab',
                                            color: Colors.black,
                                            onTap: () {
                                              Navigator.push(
                                                  context,
                                                  PageAnimationTransition(
                                                      page:
                                                          const LalKitabForm(),
                                                      pageAnimationType:
                                                          RightToLeftTransition()));
                                            },
                                          )),
                                    ],
                                  ),
                                ],
                              ),
                            )),
                        const SizedBox(
                          height: 10,
                        ),
                        Expanded(
                            flex: 1,
                            child: Consumer<BannerController>(
                              builder: (context, bannerProvider, child) {
                                double width =
                                    MediaQuery.of(context).size.width;
                                return Container(
                                  width: size.width * 0.45,
                                  height: size.width * 0.45,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    color: Colors.white,
                                  ),
                                  child: CarouselSlider(
                                    options: CarouselOptions(
                                      viewportFraction: 1.0,
                                      enlargeCenterPage: false,
                                      autoPlay: true,
                                      autoPlayInterval:
                                          const Duration(seconds: 3),
                                      enableInfiniteScroll: true,
                                    ),
                                    items: List.generate(
                                        sectionModelList[2].banners.length,
                                        (index) {
                                      return ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          child: CachedNetworkImage(
                                            fit: BoxFit.cover,
                                            imageUrl: sectionModelList[2]
                                                .banners[index]
                                                .photo,
                                            placeholder: (context, url) =>
                                                Image.asset(
                                              'assets/images/mahakal_logo_circle.png',
                                              width: size.width,
                                              fit: BoxFit.cover,
                                            ),
                                          ));
                                    }),
                                  ),
                                );
                              },
                            )),
                      ],
                    ),
                  ),
                  const SizedBox(height: 5),
                ],
              )
            : const SizedBox.shrink(),
      ],
    );
  }
}
