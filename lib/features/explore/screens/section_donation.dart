import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mahakal/features/donation/controller/lanaguage_provider.dart';
import 'package:mahakal/features/donation/model/advertisement_model.dart';
import 'package:mahakal/features/donation/view/home_page/static_view/all_home_page/static_details/Donationpage.dart';
import 'package:mahakal/localization/language_constrants.dart';
import 'package:mahakal/utill/dimensions.dart';
import 'package:provider/provider.dart';
import '../../donation/ui_helper/custom_colors.dart';
import '../../donation/view/home_page/Donation_Home/donation_home_view.dart';
import '../model/sectionmodel.dart';

class SectionDonation extends StatelessWidget {
  const SectionDonation({
    super.key,
    required this.sectionModelList,
    required this.getAds,
    required this.screenWidth,
  });

  final List<Sectionlist> sectionModelList;
  final List<AdvertiseMent> getAds;
  final double screenWidth;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        sectionModelList[8].section.status == "true"
            ? Column(children: [
                Container(
                  color: Colors.orange.shade50,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10.0, vertical: 6.0),
                        child: Row(
                          children: [
                            Container(
                              height: 15,
                              width: 4,
                              decoration: BoxDecoration(
                                  color: Colors.orange,
                                  borderRadius: BorderRadius.circular(20)),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              getTranslated('donate_now', context) ??
                                  "Donate Now",
                              style: TextStyle(
                                  fontSize: Dimensions.fontSizeLarge,
                                  fontWeight: FontWeight.bold),
                            ),
                            const Spacer(),
                            InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  CupertinoPageRoute(
                                    builder: (context) =>
                                        const DonationHomeView(),
                                  ),
                                );
                              },
                              child: Text(
                                getTranslated('VIEW_ALL', context) ??
                                    "View All",
                                style: TextStyle(
                                    fontSize: Dimensions.fontSizeLarge,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.orange),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            const SizedBox(
                              width: 10,
                            ),
                            Container(
                              height: 190,
                              width: 140,
                              decoration: const BoxDecoration(
                                  image: DecorationImage(
                                      image: AssetImage(
                                          "assets/image/donation_animation.gif"),
                                      fit: BoxFit.fill)),
                            ),
                            const SizedBox(
                              width: 6,
                            ),
                            // chadhavaModelList.isEmpty
                            //     ? shimmerScreenChadhava()
                            //     :
                            SizedBox(
                              height: 210,
                              child: ListView.builder(
                                physics: const BouncingScrollPhysics(),
                                itemCount: getAds.length,
                                shrinkWrap: true,
                                scrollDirection: Axis.horizontal,
                                itemBuilder: (context, index) {
                                  return LayoutBuilder(
                                    builder: (context, constraints) {
                                      return Container(
                                        width: 155,
                                        child: Card(
                                          child: GestureDetector(
                                            onTap: () {
                                              Navigator.push(
                                                  context,
                                                  CupertinoPageRoute(
                                                    builder: (context) =>
                                                        Donationpage(
                                                            myId: getAds[index]
                                                                .id),
                                                  ));
                                            },
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: <Widget>[
                                                Container(
                                                  height: 100,
                                                  width: 155,
                                                  margin:
                                                      const EdgeInsets.all(5),
                                                  child: ClipRRect(
                                                    borderRadius:
                                                        const BorderRadius.only(
                                                      topLeft:
                                                          Radius.circular(8),
                                                      topRight:
                                                          Radius.circular(8),
                                                    ),
                                                    child: CachedNetworkImage(
                                                      imageUrl:
                                                          getAds[index].image,
                                                      fit: BoxFit.fill,
                                                      errorWidget: (context,
                                                              url, error) =>
                                                          Container(
                                                        color: Colors
                                                            .grey.shade300,
                                                        child: const Icon(
                                                            Icons.error),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      SizedBox(
                                                        height:
                                                            screenWidth * 0.01,
                                                      ),
                                                      Padding(
                                                          padding: EdgeInsets
                                                              .symmetric(
                                                                  horizontal:
                                                                      screenWidth *
                                                                          0.01),
                                                          child: SizedBox(child:
                                                              Consumer<
                                                                  LanguageProvider>(
                                                            builder: (BuildContext
                                                                    context,
                                                                languageProvider,
                                                                child) {
                                                              return Text(
                                                                languageProvider
                                                                            .language ==
                                                                        "english"
                                                                    ? getAds[
                                                                            index]
                                                                        .enName
                                                                    : getAds[
                                                                            index]
                                                                        .hiName,
                                                                style: const TextStyle(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w400,
                                                                    fontSize:
                                                                        16,
                                                                    color: CustomColors
                                                                        .clrblack,
                                                                    fontFamily:
                                                                        'Roboto',
                                                                    overflow:
                                                                        TextOverflow
                                                                            .ellipsis),
                                                                maxLines: 2,
                                                              );
                                                            },
                                                          ))),
                                                      const SizedBox(
                                                        height: 5,
                                                      ),
                                                      Container(
                                                        margin: const EdgeInsets
                                                            .symmetric(
                                                            horizontal: 5,
                                                            vertical: 2),
                                                        padding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                                horizontal: 5,
                                                                vertical: 2),
                                                        decoration: BoxDecoration(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        5),
                                                            color: CustomColors
                                                                .clrorange),
                                                        child: Consumer<
                                                            LanguageProvider>(
                                                          builder: (BuildContext
                                                                  context,
                                                              languageProvider,
                                                              child) {
                                                            return Center(
                                                                child: Text(
                                                              languageProvider
                                                                          .language ==
                                                                      "english"
                                                                  ? "Donate Now"
                                                                  : "अभी दान करें",
                                                              textAlign:
                                                                  TextAlign
                                                                      .center,
                                                              style: TextStyle(
                                                                  fontSize:
                                                                      screenWidth *
                                                                          0.040,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500,
                                                                  fontFamily:
                                                                      'Roboto',
                                                                  color: const Color
                                                                      .fromRGBO(
                                                                      255,
                                                                      255,
                                                                      255,
                                                                      1)),
                                                            ));
                                                          },
                                                        ),
                                                      ),
                                                    ]),
                                              ],
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  );
                                },
                              ),
                            ),
                            const SizedBox(
                              width: 10,
                            )
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 15),
              ])
            : const SizedBox.shrink(),
      ],
    );
  }
}
