import 'package:flutter/material.dart';
import 'package:mahakal/features/explore/exploreScreen.dart';
import 'package:mahakal/features/explore/model/categorylist_model.dart';
import 'package:mahakal/localization/language_constrants.dart';

class ExploreAstrologyGrid extends StatelessWidget {
  const ExploreAstrologyGrid({
    super.key,
    required this.astrologyCategoryList,
  });

  final List<CategoryListModel> astrologyCategoryList;

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
              "Astrology",
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
            itemCount: astrologyCategoryList.length, // Number of items
            itemBuilder: (BuildContext context, int index) {
              return InkWell(
                  onTap: () {
                    Navigator.push(context, astrologyCategoryList[index].route);
                  },
                  child: AllCategroyWidgetExplore(
                      image: astrologyCategoryList[index].images,
                      name: getTranslated(
                              astrologyCategoryList[index].name, context) ??
                          'Panchang',
                      color: Colors.black));
            },
          ),
        ],
      ),
    );
  }
}
