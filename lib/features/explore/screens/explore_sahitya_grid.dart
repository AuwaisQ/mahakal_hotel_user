import 'package:flutter/material.dart';
import 'package:mahakal/features/explore/exploreScreen.dart';
import 'package:mahakal/features/explore/model/categorylist_model.dart';
import 'package:mahakal/localization/language_constrants.dart';
import 'package:page_animation_transition/animations/right_to_left_transition.dart';
import 'package:page_animation_transition/page_animation_transition.dart';
import '../../sahitya/view/gita_chapter/gitastatic.dart';

class ExploreSahityaGrid extends StatelessWidget {
  ExploreSahityaGrid({
    super.key,
    required this.sahityaCategoryList,
    required this.address2,
    required this.address1,
    required this.lat,
    required this.long,
  });

  final List<CategoryListModel> sahityaCategoryList;
  final String address2;
  final String address1;
  final dynamic lat;
  final dynamic long;

  List<String> bookNameList = [
    "Geeta",
    "Upnishad",
    "Mahabharat",
    "ShivPuran",
    "Ramayan"
  ];

  void showComingSoonDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Coming Soon!"),
        content: const Text("This feature is currently in development."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  void handleNavActions(String bookName, BuildContext context) {
    switch (bookName) {
      case 'Geeta':
        Navigator.push(
            context,
            PageAnimationTransition(
                page: const SahityaChapters(),
                pageAnimationType: RightToLeftTransition()));
        break;
      case 'Upnishad':
        showComingSoonDialog(context);
        break;
      case 'Mahabharat':
        showComingSoonDialog(context);
        break;
      case 'ShivPuran':
        showComingSoonDialog(context);
        break;
      case 'Ramayan':
        showComingSoonDialog(context);
        break;
      default:
        showComingSoonDialog(context);
        break;
    }
  }

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
              "Sahitya",
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
            itemCount: sahityaCategoryList.length, // Number of items
            itemBuilder: (BuildContext context, int index) {
              String bookType = bookNameList[index];

              return InkWell(
                  onTap: () {
                    handleNavActions(bookType, context);
                    // Navigator.push(
                    //     context,
                    //     PageAnimationTransition(
                    //         page: GitaStatic(),
                    //
                    //         // MahaBhandar(
                    //         //   tab: 1,
                    //         //   cityName: address2,
                    //         //   stateName: address1,
                    //         //   default_lat: lat,
                    //         //   default_long: long,
                    //         // ),
                    //         pageAnimationType: RightToLeftTransition()));
                  },
                  child: AllCategroyWidgetExplore(
                      image: sahityaCategoryList[index].images,
                      name: getTranslated(
                              sahityaCategoryList[index].name, context) ??
                          'Panchang',
                      color: Colors.black));
            },
          ),
        ],
      ),
    );
  }
}
