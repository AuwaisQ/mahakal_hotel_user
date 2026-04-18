import 'package:flutter/material.dart';
import 'package:mahakal/features/explore/exploreScreen.dart';
import 'package:mahakal/features/explore/model/categorylist_model.dart';
import 'package:mahakal/features/maha_bhandar/screen/maha_bhandar_screen.dart';
import 'package:mahakal/localization/language_constrants.dart';
import 'package:page_animation_transition/animations/right_to_left_transition.dart';
import 'package:page_animation_transition/page_animation_transition.dart';

class ExplorePanchangGrid extends StatelessWidget {
  const ExplorePanchangGrid({
    super.key,
    required this.panchangCategoryList,
    required this.address2,
    required this.address1,
    required this.lat,
    required this.long,
  });

  final List<CategoryListModel> panchangCategoryList;
  final String address2;
  final String address1;
  final dynamic lat;
  final dynamic long;

  //All category Widget

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      margin: const EdgeInsets.all(4),
      width: double.infinity,
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
              color: Colors.orange.shade50, blurRadius: 10.0, spreadRadius: 2),
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
              "Panchang",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4, // Number of columns
              mainAxisSpacing: 8, // Spacing between rows
              crossAxisSpacing: 8, // Spacing between columns
            ),
            itemCount: panchangCategoryList.length, // Number of items
            itemBuilder: (BuildContext context, int index) {
              return InkWell(
                  onTap: () {
                    Navigator.push(
                        context,
                        PageAnimationTransition(
                            page: MahaBhandar(tab: index + 1),
                            pageAnimationType: RightToLeftTransition()));
                  },
                  child: AllCategroyWidgetExplore(
                      image: panchangCategoryList[index].images,
                      name: getTranslated(
                              panchangCategoryList[index].name, context) ??
                          'Panchang',
                      color: Colors.black));
            },
          ),
        ],
      ),
    );
  }
}
