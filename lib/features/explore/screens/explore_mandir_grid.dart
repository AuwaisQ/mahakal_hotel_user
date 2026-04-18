import 'package:flutter/material.dart';
import 'package:mahakal/features/mandir_darshan/mandirhome.dart';
import 'package:mahakal/features/mandir_darshan/model/darshan_category_model.dart';
import 'package:mahakal/utill/custom_themes.dart';
import 'package:mahakal/utill/dimensions.dart';
import 'package:page_animation_transition/animations/right_to_left_transition.dart';
import 'package:page_animation_transition/page_animation_transition.dart';

class ExploreMandirGrid extends StatelessWidget {
  const ExploreMandirGrid({
    super.key,
    required this.darshanCategoryModelList,
    required this.mandirCategoryList,
  });

  final List<DarshanData> darshanCategoryModelList;
  final List<String> mandirCategoryList;

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
              "Mandir Darshan",
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
            itemCount: darshanCategoryModelList.length, // Number of items
            itemBuilder: (BuildContext context, int index) {
              return InkWell(
                  onTap: () {
                    Navigator.push(
                        context,
                        PageAnimationTransition(
                            page: MandirDarshan(
                              tabIndex: index + 1,
                            ),
                            pageAnimationType: RightToLeftTransition()));
                  },
                  child: SizedBox(
                    height: 100,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Image.network(
                            darshanCategoryModelList[index].image ?? '',
                            height: 35,
                            width: 35,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Expanded(
                          child: Text(
                            "${darshanCategoryModelList[index].enName}",
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: titleHeader.copyWith(
                                fontSize: Dimensions.fontSizeSmall,
                                letterSpacing: 0.5,
                                fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                  ));
            },
          ),
        ],
      ),
    );
  }
}
