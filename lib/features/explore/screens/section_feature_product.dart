import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mahakal/features/home/shimmers/featured_product_shimmer.dart';
import 'package:mahakal/features/product/widgets/featured_product_widget.dart';
import 'package:provider/provider.dart';
import '../../../common/basewidget/title_row_widget.dart';
import '../../../helper/responsive_helper.dart';
import '../../../localization/language_constrants.dart';
import '../../../utill/dimensions.dart';
import '../../product/controllers/product_controller.dart';
import '../../product/enums/product_type.dart';
import '../../product/screens/view_all_product_screen.dart';
import '../exploreScreen.dart';
import '../model/sectionmodel.dart';

class SectionFeatureProduct extends StatelessWidget {
  const SectionFeatureProduct({
    super.key,
    required this.sectionModelList,
    required this.widget,
  });

  final List<Sectionlist> sectionModelList;
  final ExploreScreen widget;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        sectionModelList[21].section.status == "true"
            ? Column(children: [
                const SizedBox(
                  height: 10,
                ),
                Consumer<ProductController>(builder: (context, featured, _) {
                  return featured.featuredProductList != null
                      ? featured.featuredProductList!.isNotEmpty
                          ? Stack(children: [
                              Padding(
                                  padding: const EdgeInsets.only(bottom: 25),
                                  child: Container(
                                    width: MediaQuery.of(context).size.width,
                                    height: ResponsiveHelper.isTab(context)
                                        ? MediaQuery.of(context).size.width / 2
                                        : MediaQuery.of(context).size.width -
                                            50,
                                    decoration: BoxDecoration(
                                        borderRadius: const BorderRadius.only(
                                            topLeft: Radius.circular(
                                                Dimensions.paddingSizeDefault),
                                            bottomLeft: Radius.circular(
                                                Dimensions.paddingSizeDefault)),
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSecondaryContainer),
                                  )),
                              Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: Dimensions
                                                .paddingSizeExtraSmall,
                                            vertical: Dimensions
                                                .paddingSizeExtraSmall),
                                        child: Padding(
                                            padding: const EdgeInsets.only(
                                                top: 20,
                                                bottom: Dimensions
                                                    .paddingSizeSmall),
                                            child: TitleRowWidget(
                                                title: getTranslated(
                                                    'featured_products',
                                                    context),
                                                onTap: () => Navigator.push(
                                                    context,
                                                    CupertinoPageRoute(
                                                        builder: (_) =>
                                                            AllProductScreen(
                                                                productType:
                                                                    ProductType
                                                                        .featuredProduct)))))),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          bottom: Dimensions.homePagePadding),
                                      child: FeaturedProductWidget(
                                        scrollController:
                                            widget.scrollController,
                                        isHome: true,
                                      ),
                                    ),
                                  ])
                            ])
                          : const SizedBox()
                      : const FeaturedProductShimmer();
                }),
                // const SizedBox(height: 120),
              ])
            : const SizedBox.shrink(),
        SizedBox(
          height: 80,
        )
      ],
    );
  }
}
