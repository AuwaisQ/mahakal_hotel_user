import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mahakal/features/explore/exploreScreen.dart';
import 'package:mahakal/features/pooja_booking/model/categorymodel.dart';
import 'package:mahakal/features/pooja_booking/view/pooja_home.dart';

class ExplorePoojaGrid extends StatelessWidget {
  const ExplorePoojaGrid({
    super.key,
    required this.categoryPoojaModelList,
    required this.widget,
    required this.poojaCategoryList,
  });

  final List<GetPoojaCategory> categoryPoojaModelList;
  final ExploreScreen widget;
  final List<String> poojaCategoryList;

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
              "Pooja Booking",
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
            itemCount: categoryPoojaModelList.length, // Number of items
            itemBuilder: (BuildContext context, int index) {
              return InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      CupertinoPageRoute(
                        builder: (context) => PoojaHomeView(
                          tabIndex: index + 1,
                          scrollController: widget.scrollController,
                        ),
                      ),
                    );
                  },
                  child: AllCategroyWidgetExplore(
                      image: poojaCategoryList[index],
                      name: categoryPoojaModelList[index].enName,
                      color: Colors.black));
            },
          ),
        ],
      ),
    );
  }
}
