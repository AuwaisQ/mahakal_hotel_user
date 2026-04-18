import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mahakal/features/blogs_module/model/SubCategory_model.dart';
import 'package:mahakal/features/blogs_module/no_image_widget.dart';
import 'package:mahakal/features/blogs_module/view/BlogHomePage.dart';
import 'package:page_animation_transition/animations/right_to_left_transition.dart';
import 'package:page_animation_transition/page_animation_transition.dart';
import '../../../localization/language_constrants.dart';
import '../../../utill/dimensions.dart';
import '../../blogs_module/view/BlogDetailsPage.dart';
import '../model/sectionmodel.dart';

class SectionReadBlogs extends StatelessWidget {
  const SectionReadBlogs({
    super.key,
    required this.sectionModelList,
    required this.h,
    required this.screenHeight,
    required this.subCategoryList,
    required this.screenWidth,
  });

  final List<Sectionlist> sectionModelList;
  final double h;
  final double screenHeight;
  final List<BlogSubCategoryData> subCategoryList;
  final double screenWidth;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        sectionModelList[2].section.status == "true"
            ? Column(
                children: [
                  // Title Tile
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(7),
                    margin:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        Container(
                          height: 15,
                          width: 4,
                          decoration: BoxDecoration(
                            color: Colors.orange,
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          getTranslated('read_blogs', context) ?? "Read Blogs",
                          style: TextStyle(
                            fontSize: Dimensions.fontSizeLarge,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              PageAnimationTransition(
                                page: const BlogHomePage(),
                                pageAnimationType: RightToLeftTransition(),
                              ),
                            );
                          },
                          child: Text(
                            getTranslated('VIEW_ALL', context) ?? "View All",
                            style: TextStyle(
                              fontSize: Dimensions.fontSizeLarge,
                              fontWeight: FontWeight.bold,
                              color: Colors.orange,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Blog List View
                  Padding(
                    padding: const EdgeInsets.only(left: 10, top: 3),
                    child: SizedBox(
                      height: screenHeight * 0.3,
                      child: ListView.builder(
                        physics: const AlwaysScrollableScrollPhysics(),
                        scrollDirection: Axis.horizontal,
                        itemCount: subCategoryList.length > 5
                            ? 10
                            : subCategoryList.length,
                        itemBuilder: (context, index) {
                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                CupertinoPageRoute(
                                  builder: (context) => BlogDetailsPage(
                                    remainingItems: subCategoryList,
                                    title: subCategoryList[index].titleSlug,
                                  ),
                                ),
                              );
                            },
                            child: Container(
                              margin: const EdgeInsets.all(5),
                              width: screenWidth * 0.45,
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: const Color.fromRGBO(231, 231, 231, 1),
                                ),
                                borderRadius: BorderRadius.circular(10),
                                color: Colors.white,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: double.infinity,
                                    height: 125,
                                    padding: const EdgeInsets.all(5),
                                    child: ClipRRect(
                                      borderRadius: const BorderRadius.all(
                                        Radius.circular(10),
                                      ),
                                      child: CachedNetworkImage(
                                        imageUrl:
                                            subCategoryList[index].imageBig,
                                        fit: BoxFit.fill,
                                        errorWidget: (context, url, error) =>
                                            const NoImageWidget(),
                                      ),
                                    ),
                                  ),
                                  // const Spacer(),
                                  Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: screenWidth * 0.02,
                                      vertical: 10,
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          subCategoryList[index].title,
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Colors.black,
                                            fontWeight: FontWeight.bold,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          textAlign: TextAlign.start,
                                          maxLines: 2,
                                        ),
                                        Divider(color: Colors.grey.shade200),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 14,
                                            vertical: 5,
                                          ),
                                          decoration: BoxDecoration(
                                            color:
                                                Theme.of(context).primaryColor,
                                            borderRadius:
                                                BorderRadius.circular(6),
                                          ),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              Text(
                                                getTranslated(
                                                        'read_now', context) ??
                                                    "Read Now",
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.w600,
                                                  color: Colors.white,
                                                  fontSize: 14,
                                                ),
                                              ),
                                              const SizedBox(width: 6),
                                              const Icon(
                                                Icons.arrow_circle_right,
                                                color: Colors.white,
                                                size: 18,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
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
