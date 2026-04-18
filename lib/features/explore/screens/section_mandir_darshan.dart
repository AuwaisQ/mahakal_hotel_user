import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:mahakal/features/mandir_darshan/mandirhome.dart';
import 'package:mahakal/localization/language_constrants.dart';
import 'package:page_animation_transition/animations/right_to_left_transition.dart';
import 'package:page_animation_transition/page_animation_transition.dart';
import '../../../utill/dimensions.dart';
import '../../blogs_module/no_image_widget.dart';
import '../../mandir_darshan/model/darshan_category_model.dart';
import '../model/sectionmodel.dart';

class SectionMandirDarshan extends StatelessWidget {
  const SectionMandirDarshan({
    super.key,
    required this.sectionModelList,
    required this.h,
    required this.darshanCategoryModelList,
  });

  final List<Sectionlist> sectionModelList;
  final double h;
  final List<DarshanData> darshanCategoryModelList;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        sectionModelList[17].section.status == "true"
            ? Column(children: [
                Container(
                  color: Colors.purple.shade50,
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
                                  color: Colors.purple,
                                  borderRadius: BorderRadius.circular(20)),
                            ),
                            const SizedBox(width: 5),
                            Text(
                              getTranslated('mandir_darshan', context) ??
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
                                        page: const MandirDarshan(
                                          tabIndex: 0,
                                        ),
                                        pageAnimationType:
                                            RightToLeftTransition()));
                              },
                              child: Text(
                                getTranslated('VIEW_ALL', context) ??
                                    "view All",
                                style: TextStyle(
                                    fontSize: Dimensions.fontSizeLarge,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.purple),
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
                                          "assets/images/allcategories/animate/mandir_darshan_animation.gif"),
                                      fit: BoxFit.fill)),
                            ),
                            const SizedBox(
                              width: 6,
                            ),
                            SizedBox(
                              height: 210,
                              child: ListView.builder(
                                physics: const BouncingScrollPhysics(),
                                itemCount: darshanCategoryModelList.length,
                                shrinkWrap: true,
                                scrollDirection: Axis.horizontal,
                                itemBuilder: (context, index) {
                                  final mandirList =
                                      darshanCategoryModelList[index];
                                  return InkWell(
                                      onTap: () {
                                        Navigator.push(
                                            context,
                                            PageAnimationTransition(
                                                page: MandirDarshan(
                                                    tabIndex: index + 1),
                                                pageAnimationType:
                                                    RightToLeftTransition()));
                                      },
                                      child: Container(
                                        margin: const EdgeInsets.only(
                                            right: 8, bottom: 12),
                                        padding: EdgeInsets.all(5),
                                        width: 150,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: Container(
                                          height: 140,
                                          width: double.infinity,
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            child: CachedNetworkImage(
                                              imageUrl: "${mandirList.image}",
                                              fit: BoxFit.cover,
                                              width: double.infinity,
                                              height: double.infinity,
                                              errorWidget:
                                                  (context, url, error) =>
                                                      const NoImageWidget(),
                                            ),
                                          ),
                                        ),
                                      )
                                      // Container(
                                      //   margin: const EdgeInsets.only(
                                      //       right: 5, bottom: 10),
                                      //   width: 140,
                                      //   decoration: BoxDecoration(
                                      //       color: Colors.white,
                                      //       border: Border.all(
                                      //           color: Colors.grey.shade300,
                                      //           width: 1.5),
                                      //       borderRadius:
                                      //           BorderRadius.circular(8.0)),
                                      //   child: Padding(
                                      //     padding: const EdgeInsets.all(4.0),
                                      //     child: Column(
                                      //       crossAxisAlignment:
                                      //           CrossAxisAlignment.start,
                                      //       children: [
                                      //         Expanded(
                                      //             flex: 1,
                                      //             child: Container(
                                      //               height: 130,
                                      //               width: 130,
                                      //               decoration: BoxDecoration(
                                      //                 borderRadius:
                                      //                     BorderRadius.circular(
                                      //                         8),
                                      //                 color: Colors.grey.shade300,
                                      //               ),
                                      //               child: ClipRRect(
                                      //                 borderRadius:
                                      //                     BorderRadius.circular(
                                      //                         6),
                                      //                 child: CachedNetworkImage(
                                      //                   imageUrl:
                                      //                       "${mandirList.image}",
                                      //                   fit: BoxFit.cover,
                                      //                   errorWidget: (context,
                                      //                           url, error) =>
                                      //                       const NoImageWidget(),
                                      //                 ),
                                      //               ),
                                      //             )),
                                      //         Expanded(
                                      //             flex: 0,
                                      //             child: Text(
                                      //               "${mandirList.enName}",
                                      //               style: const TextStyle(
                                      //                   fontSize: 16,
                                      //                   color: Colors.black),
                                      //               maxLines: 2,
                                      //             )),
                                      //
                                      //         // Text.rich(
                                      //         // TextSpan(
                                      //         // children: [
                                      //         // TextSpan(
                                      //         // text:'₹${muhuratModelList[index].counsellingSellingPrice} ',style: const TextStyle(fontSize: 14,fontWeight: FontWeight.bold,color:Colors.blue)
                                      //         // ),
                                      //         // TextSpan(
                                      //         // text:'₹${muhuratModelList[index].counsellingMainPrice}',style: const TextStyle(fontSize: 14,fontWeight: FontWeight.bold,color: Colors.black,decoration: TextDecoration.lineThrough)
                                      //         // ),
                                      //         // ]
                                      //         // )
                                      //         // )
                                      //       ],
                                      //     ),
                                      //   ),
                                      // ),
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
