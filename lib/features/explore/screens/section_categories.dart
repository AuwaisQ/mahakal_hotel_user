import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mahakal/features/category/screens/category_screen.dart';
import 'package:mahakal/features/category/widgets/category_list_widget.dart';
import 'package:mahakal/localization/language_constrants.dart';
import 'package:mahakal/utill/dimensions.dart';
import '../model/sectionmodel.dart';

class SectionCategories extends StatelessWidget {
  const SectionCategories({
    super.key,
    required this.sectionModelList,
  });

  final List<Sectionlist> sectionModelList;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        sectionModelList[10].section.status == "true"
            ? Column(children: [
                Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(7),
                    margin: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(10)),
                    child: Row(
                      children: [
                        Container(
                          height: 15,
                          width: 4,
                          decoration: BoxDecoration(
                              color: Colors.orange,
                              borderRadius: BorderRadius.circular(20)),
                        ),
                        const SizedBox(
                          width: 5,
                        ),
                        Text(
                          getTranslated('CATEGORY', context) ?? "Categories",
                          style: TextStyle(
                              fontSize: Dimensions.fontSizeLarge,
                              fontWeight: FontWeight.bold),
                        ),
                        const Spacer(),
                        InkWell(
                          onTap: () {
                            Navigator.push(
                                context,
                                CupertinoPageRoute(
                                    builder: (_) => const CategoryScreen()));
                          },
                          child: Text(
                            getTranslated('VIEW_ALL', context) ?? "view All",
                            style: TextStyle(
                                fontSize: Dimensions.fontSizeLarge,
                                fontWeight: FontWeight.bold,
                                color: Colors.orange),
                          ),
                        ),
                      ],
                    )),
                const SizedBox(height: 15),
                const CategoryListWidget(isHomePage: true),
              ])
            : const SizedBox.shrink(),
      ],
    );
  }
}
