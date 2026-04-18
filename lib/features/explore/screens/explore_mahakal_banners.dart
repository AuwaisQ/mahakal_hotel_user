import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mahakal/common/basewidget/custom_image_widget.dart';
import 'package:mahakal/features/banner/controllers/banner_controller.dart';
import 'package:mahakal/features/banner/widgets/banner_shimmer.dart';
import 'package:mahakal/features/donation/view/home_page/static_view/all_home_page/static_details/Donationpage.dart';
import 'package:mahakal/features/mandir_darshan/mandirdetails_mandir.dart';
import 'package:mahakal/features/splash/controllers/splash_controller.dart';
import 'package:mahakal/features/you_tube_widgets/youtube_player/youtube_screen.dart';
import 'package:mahakal/theme/controllers/theme_controller.dart';
import 'package:mahakal/utill/app_constants.dart';
import 'package:mahakal/utill/dimensions.dart';
import 'package:provider/provider.dart';

import '../../astrology/component/astrodetailspage.dart';
import '../../event_booking/view/event_details.dart';
import '../../offline_pooja/view/offline_details.dart';
import '../../pooja_booking/view/anushthandetail.dart';
import '../../pooja_booking/view/chadhavadetails.dart';
import '../../pooja_booking/view/silvertabbar.dart';
import '../../pooja_booking/view/vipdetails.dart';
import '../../product/screens/brand_and_category_product_screen.dart';
import '../../product/screens/porduct_list_screen.dart';
import '../../product_details/screens/product_details_screen.dart';
import '../../tour_and_travells/view/TourDetails.dart';
import '../model/sectionmodel.dart';

class ExploreMahakalBanners extends StatefulWidget {
  List<Sectionlist>? sectionModelList;
  ExploreMahakalBanners({
    super.key,
    required this.sectionModelList,
  });

  @override
  State<ExploreMahakalBanners> createState() => _ExploreMahakalBannersState();
}

class _ExploreMahakalBannersState extends State<ExploreMahakalBanners> {
  void routeScreeen(String id, String slug, String name, String date) {
    print("date formate : $date");
    switch (name) {
      case "pooja":
        Navigator.push(
            context,
            CupertinoDialogRoute(
                builder: (context) => SliversExample(
                      slugName: slug,
                      // nextDatePooja: date,
                    ),
                context: context));
        break;
      case "anushthan":
        Navigator.push(
            context,
            CupertinoDialogRoute(
                builder: (context) => AnushthanDetails(
                      idNumber: slug,
                      typePooja: 'anushthan',
                    ),
                context: context));
        break;
      case "vip":
        Navigator.push(
            context,
            CupertinoDialogRoute(
                builder: (context) => VipDetails(
                      idNumber: slug,
                      typePooja: 'vip',
                    ),
                context: context));
        break;
      case "chadhava":
        Navigator.push(
            context,
            CupertinoDialogRoute(
                builder: (context) => ChadhavaDetailView(
                      idNumber: id,
                      // nextDatePooja: "${DateTime.parse(date)}",
                    ),
                context: context));
        break;
      case "tour":
        Navigator.push(
            context,
            CupertinoDialogRoute(
                builder: (context) => TourDetails(
                      productId: id,
                    ),
                context: context));
        break;
      case "event":
        Navigator.push(
            context,
            CupertinoDialogRoute(
                builder: (context) => EventDeatils(
                      eventId: int.parse(id),
                    ),
                context: context));
        break;
      case "temple":
        Navigator.push(
            context,
            CupertinoPageRoute(
                builder: (context) => MandirDetailView(
                      detailId: id,
                    )));
        break;
      case "offlinepooja":
        Navigator.push(
            context,
            CupertinoPageRoute(
              builder: (context) => OfflinePoojaDetails(
                slugName: slug,
              ),
            ));
        break;
      case "donation":
        Navigator.push(
            context,
            CupertinoPageRoute(
              builder: (context) => Donationpage(
                myId: int.parse(id),
              ),
            ));
        break;
      case "counselling":
        Navigator.push(
            context,
            CupertinoPageRoute(
                builder: (context) => AstroDetailsView(
                      productId: int.parse(id),
                      isProduct: false,
                    )));
        break;
      case "pro":
        Navigator.push(context,
            CupertinoPageRoute(builder: (context) => ProductListPage()));
        break;
      default:
        // Fluttertoast.showToast(
        //     msg: "Please Try Again!",
        //     backgroundColor: Colors.red,
        //     textColor: Colors.white);
      print("bhag beee");
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<BannerController>(
      builder: (context, bannerProvider, child) {
        double width = MediaQuery.of(context).size.width;
        return Stack(
          children: [
            bannerProvider.mahakalBannerList != null
                ? bannerProvider.mahakalBannerList!.isNotEmpty
                    ? SizedBox(
                        height: width * 0.5,
                        width: width,
                        child: Column(
                          children: [
                            SizedBox(
                              height: width * 0.45,
                              width: width,
                              child: CarouselSlider.builder(
                                options: CarouselOptions(
                                    aspectRatio: 4 / 1,
                                    viewportFraction: 0.8,
                                    autoPlay: true,
                                    pauseAutoPlayOnTouch: true,
                                    pauseAutoPlayOnManualNavigate: true,
                                    pauseAutoPlayInFiniteScroll: true,
                                    enlargeFactor: .2,
                                    enlargeCenterPage: true,
                                    disableCenter: true,
                                    onPageChanged: (index, reason) {
                                      Provider.of<BannerController>(context,
                                              listen: false)
                                          .setCurrentIndex(index);
                                    }),
                                itemCount: bannerProvider
                                        .mahakalBannerList!.isEmpty
                                    ? 1
                                    : bannerProvider.mahakalBannerList?.length,
                                itemBuilder: (context, index, _) {
                                  return InkWell(
                                      onTap: () {
                                        final item = bannerProvider
                                            .mahakalBannerList![index]
                                            .mahakalApp;
                                        print(bannerProvider
                                            .mahakalBannerList![index].url);
                                        (bannerProvider
                                                        .mahakalBannerList?[
                                                            index]
                                                        .url !=
                                                    null &&
                                                bannerProvider
                                                    .mahakalBannerList![index]
                                                    .url!
                                                    .isNotEmpty)
                                            ? Navigator.push(
                                                context,
                                                CupertinoPageRoute(
                                                  builder: (_) => YoutubeScreen(
                                                    url: bannerProvider
                                                        .mahakalBannerList![
                                                            index]
                                                        .url!,
                                                  ),
                                                ),
                                              )
                                            : (bannerProvider
                                                        .mahakalBannerList![
                                                            index]
                                                        .resourceType ==
                                                    'product')
                                                ? Navigator.push(
                                                    context,
                                                    CupertinoPageRoute(
                                                      builder: (_) =>
                                                          ProductDetails(
                                                        productId: bannerProvider
                                                            .mahakalBannerList![
                                                                index]
                                                            .product
                                                            ?.id,
                                                        slug: bannerProvider
                                                            .mahakalBannerList![
                                                                index]
                                                            .product
                                                            ?.slug,
                                                      ),
                                                    ),
                                                  )
                                                : (bannerProvider
                                                            .mahakalBannerList![
                                                                index]
                                                            .resourceType ==
                                                        'category')
                                                    ? Navigator.push(
                                                        context,
                                                        CupertinoPageRoute(
                                                          builder: (_) =>
                                                              BrandAndCategoryProductScreen(
                                                            isBrand: false,
                                                            id: "${bannerProvider.mahakalBannerList![index].resourceId}",
                                                            name:
                                                                "Product Category",
                                                          ),
                                                        ),
                                                      )
                                                    : routeScreeen(
                                                        "${item?.id}",
                                                        "${item?.slug}",
                                                        "${item?.type}",
                                                        "${item?.nextPoojaDate}",
                                                      );

                                        // bannerProvider.mahakalBannerList![index].url != null
                                        //     ? Navigator.push(
                                        //         context,
                                        //         CupertinoPageRoute(
                                        //             builder: (_) => YoutubeScreen(
                                        //                   url: bannerProvider
                                        //                       .mahakalBannerList![
                                        //                           index]
                                        //                       .url!,
                                        //                 )))
                                        //     : routeScreeen("${item?.id}", "${item?.slug}",
                                        //     "${item?.type}", "${item?.nextPoojaDate}");
                                        //
                                        // // e-commerce banners
                                        // if (widget.sectionModelList?[1].rightBottom?.appSectionResourceType == 'product'
                                        // || widget.sectionModelList?[1].rightBottom?.appSectionResourceType == 'category' ) {
                                        //   if (widget.sectionModelList?[1].rightBottom?.product != null) {
                                        //     Navigator.push(
                                        //         context,
                                        //         CupertinoPageRoute(
                                        //             builder: (_) => ProductDetails(
                                        //               productId: widget.sectionModelList?[1].rightBottom?.product!.id,
                                        //               slug: widget.sectionModelList?[1].rightBottom?.product!.slug,
                                        //             )));
                                        //   }
                                        // } else {
                                        //   Navigator.push(
                                        //       context,
                                        //       CupertinoPageRoute(
                                        //           builder: (_) => BrandAndCategoryProductScreen(
                                        //               isBrand: false,
                                        //               id: "${widget.sectionModelList?[1].rightBottom?.category!.id}",
                                        //               name: widget.sectionModelList?[1].rightBottom?.category!.name)));
                                        // }

                                        print(
                                            "${item?.id} \n ${item?.slug} \n ${item?.type} \n ${item?.nextPoojaDate} \n ");
                                      },
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(
                                            Dimensions.paddingSizeSmall),
                                        child: Container(
                                            decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        Dimensions
                                                            .paddingSizeSmall),
                                                color:
                                                    Provider.of<ThemeController>(
                                                                context,
                                                                listen: false)
                                                            .darkTheme
                                                        ? Theme.of(context)
                                                            .primaryColor
                                                            .withOpacity(1)
                                                        : Theme.of(context)
                                                            .primaryColor
                                                            .withOpacity(.05)),
                                            child: Stack(
                                              children: [
                                                CustomImageWidget(
                                                  image:
                                                      '${Provider.of<SplashController>(context, listen: false).baseUrls?.bannerImageUrl}'
                                                      '/${bannerProvider.mahakalBannerList?[index].photo}',
                                                  width: double.infinity,
                                                  fit: BoxFit.fill,
                                                ),
                                                if (AppConstants.baseUrl ==
                                                    "https://sit.resrv.in")
                                                  Positioned(
                                                    bottom: 12,
                                                    left: 12,
                                                    child: Container(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          horizontal: 10,
                                                          vertical: 6),
                                                      decoration: BoxDecoration(
                                                        color: Colors.black
                                                            .withOpacity(
                                                                0.6), // semi-transparent bg
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8),
                                                        boxShadow: [
                                                          BoxShadow(
                                                            color: Colors.black
                                                                .withOpacity(
                                                                    0.4),
                                                            blurRadius: 6,
                                                            offset:
                                                                const Offset(
                                                                    2, 2),
                                                          ),
                                                        ],
                                                      ),
                                                      child: Text(
                                                        "${bannerProvider.mahakalBannerList?[index].mahakalApp?.type} - ${bannerProvider.mahakalBannerList?[index].resourceType}",
                                                        style: const TextStyle(
                                                          fontSize: 18,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: Colors
                                                              .amberAccent, // highlighted text
                                                          shadows: [
                                                            Shadow(
                                                              blurRadius: 4,
                                                              color:
                                                                  Colors.black,
                                                              offset:
                                                                  Offset(1, 1),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                              ],
                                            )),
                                      ));
                                },
                              ),
                            ),
                          ],
                        ),
                      )
                    : const SizedBox()
                : const BannerShimmer(),

            // if(bannerProvider.mainBannerList != null &&  bannerProvider.mainBannerList!.isNotEmpty)
            //   Positioned(
            //     bottom: 25, left: 0, right: 0,
            //     child: Row(
            //       mainAxisAlignment: MainAxisAlignment.center, children: [
            //         Row(
            //           mainAxisAlignment: MainAxisAlignment.center,
            //           children: bannerProvider.mainBannerList!.map((banner) {
            //             int index = bannerProvider.mainBannerList!.indexOf(banner);
            //             return index == bannerProvider.currentIndex ?
            //             Container(
            //               padding: const EdgeInsets.symmetric(horizontal: 15,vertical: 1),
            //               margin: const EdgeInsets.symmetric(horizontal: 6.0),
            //               decoration: BoxDecoration(
            //                 color:  Theme.of(context).primaryColor ,
            //                 borderRadius: BorderRadius.circular(100)),
            //               child:  Text("${bannerProvider.mainBannerList!.indexOf(banner) + 1}",
            //                 style: const TextStyle(color: Colors.white,fontSize: 12),),
            //             ):const SizedBox();
            //           }).toList(),
            //         ),
            //       ],),
            //   ),
          ],
        );
      },
    );
  }
}
