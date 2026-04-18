import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mahakal/features/category/controllers/category_controller.dart';
import 'package:mahakal/features/category/widgets/category_shimmer_widget.dart';
import 'package:mahakal/features/product/screens/brand_and_category_product_screen.dart';
import 'package:mahakal/features/splash/controllers/splash_controller.dart';
import 'package:mahakal/utill/custom_themes.dart';
import 'package:mahakal/utill/dimensions.dart';
import 'package:provider/provider.dart';

class ExploreShopCategroyGrid extends StatefulWidget {
  const ExploreShopCategroyGrid({super.key});

  @override
  State<ExploreShopCategroyGrid> createState() =>
      _ExploreShopCategroyGridState();
}

class _ExploreShopCategroyGridState extends State<ExploreShopCategroyGrid> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CategoryController>(
      builder: (context, categoryProvider, child) {
        return categoryProvider.categoryAllList.isNotEmpty
            ? Container(
                padding: const EdgeInsets.all(10),
                margin: const EdgeInsets.all(4),
                width: double.infinity,
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Colors.orange.shade50,
                      blurRadius: 10.0,
                      spreadRadius: 2,
                    ),
                  ],
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(left: 10.0),
                      child: Text(
                        "Shop",
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 10),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 4,
                        mainAxisSpacing: 8,
                        crossAxisSpacing: 8,
                      ),
                      itemCount: categoryProvider.categoryAllList.length,
                      itemBuilder: (BuildContext context, int index) {
                        var baseController = Provider.of<SplashController>(
                            context,
                            listen: false);
                        return InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              CupertinoPageRoute(
                                builder: (_) => BrandAndCategoryProductScreen(
                                  isBrand: false,
                                  id: categoryProvider.categoryAllList[index].id
                                      .toString(),
                                  name: categoryProvider
                                      .categoryAllList[index].name,
                                ),
                              ),
                            );
                          },
                          child: SizedBox(
                            height: 100,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: CachedNetworkImage(
                                      imageUrl:
                                          '${baseController.baseUrls?.categoryImageUrl}/${categoryProvider.categoryAllList[index].icon}',
                                      height: 35,
                                      width: 35,
                                      errorWidget: (context, url, error) =>
                                          const Icon(
                                        Icons.broken_image,
                                        color: Colors.grey,
                                        size: 24,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Expanded(
                                  child: Text(
                                    categoryProvider
                                            .categoryAllList[index].name ??
                                        '',
                                    textAlign: TextAlign.center,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: titleHeader.copyWith(
                                      color: Colors.black,
                                      fontSize: Dimensions.fontSizeSmall,
                                      letterSpacing: 0.5,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              )
            : const CategoryShimmerWidget();
      },
    );
  }
}
