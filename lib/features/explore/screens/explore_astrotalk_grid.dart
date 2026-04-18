import 'package:flutter/material.dart';
import 'package:mahakal/features/explore/exploreScreen.dart';
import 'package:mahakal/features/explore/model/categorylist_model.dart';
import 'package:mahakal/localization/language_constrants.dart';

class ExploreAstroTalkGrid extends StatelessWidget {
  const ExploreAstroTalkGrid({
    super.key,
    required this.astrotalkCategoryList,
  });

  final List<CategoryListModel> astrotalkCategoryList;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          margin: const EdgeInsets.all(4),
          width: double.infinity,
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                  color: Colors.orange.shade50,
                  blurRadius: 10.0,
                  spreadRadius: 2),
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
                  "Astrologers Talk",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4, // Number of columns
                  mainAxisSpacing: 8, // Spacing between rows
                  crossAxisSpacing: 8, // Spacing between columns
                ),
                itemCount: astrotalkCategoryList.length, // Number of items
                itemBuilder: (BuildContext context, int index) {
                  return InkWell(
                      onTap: () {
                        //   Navigator.push(
                        //       context,
                        //       PageAnimationTransition(
                        //           page: MahaBhandar(
                        //             tab: 1,
                        //             cityName: address2,
                        //             stateName: address1,
                        //             default_lat: lat,
                        //             default_long: long,
                        //           ),
                        //           pageAnimationType: RightToLeftTransition()));
                      },
                      child: AllCategroyWidgetExplore(
                          image: astrotalkCategoryList[index].images,
                          name: getTranslated(
                                  astrotalkCategoryList[index].name, context) ??
                              'Panchang',
                          color: Colors.black));
                },
              ),
            ],
          ),
        ),
        Container(
            height: 230,
            padding: const EdgeInsets.all(10),
            margin: const EdgeInsets.all(4),
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.black38,
              borderRadius: BorderRadius.circular(15),
            ),
            child: const Center(
                child: Text(
              "Coming Soon...",
              style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ))),
      ],
    );
  }
}
