import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mahakal/features/explore/exploreScreen.dart';
import 'package:mahakal/localization/language_constrants.dart';
import 'package:mahakal/utill/dimensions.dart';
import '../../offline_pooja/model/category_model.dart';
import '../../offline_pooja/view/OfflinePoojaHome.dart';
import '../model/sectionmodel.dart';

class SectionPanditBooking extends StatelessWidget {
  const SectionPanditBooking({
    super.key,
    required this.sectionModelList,
    required this.widget,
    required this.size,
    required this.categoryPanditModelList,
    required this.shimmer,
  });

  final List<Sectionlist> sectionModelList;
  final ExploreScreen widget;
  final Size size;
  final List<OfflineCategory> categoryPanditModelList;
  final Widget shimmer;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        sectionModelList[9].section.status == "true"
            ? Column(children: [
                Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(7),
                    margin: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
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
                          getTranslated('book_pandit', context) ??
                              "Pandit Booking",
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
                                  builder: (context) => OfflinePoojaHome(
                                    tabIndex: 0,
                                  ),
                                ),
                              );
                            },
                            child: Text(
                              getTranslated('VIEW_ALL', context) ??
                                  "Pandit Booking",
                              style: TextStyle(
                                  color: Colors.orange,
                                  fontSize: Dimensions.fontSizeLarge,
                                  fontWeight: FontWeight.bold),
                            )),
                      ],
                    )),
                const SizedBox(height: 5),
                Padding(
                  padding: const EdgeInsets.only(left: 10, top: 3),
                  child: SizedBox(
                    height: size.height * 0.3,
                    child: categoryPanditModelList.isEmpty
                        ? shimmer
                        : ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: categoryPanditModelList.length,
                            itemBuilder: (BuildContext ctx, index) {
                              return InkWell(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      CupertinoPageRoute(
                                        builder: (context) => OfflinePoojaHome(
                                          tabIndex: index + 1,
                                        ),
                                      ),
                                    );
                                  },
                                  child: Container(
                                    width:
                                        180, // Slightly wider for better content display
                                    margin: const EdgeInsets.only(right: 15),
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                            color: Colors.grey, width: 0.2)
                                        // gradient: const LinearGradient(
                                        //   colors: [
                                        //     Color(0xFFFFF3E0), // Light orange
                                        //     Color(0xFFFFE0B2), // Medium light orange
                                        //     Color(0xFFFFCC80), // Medium orange
                                        //   ],
                                        //   begin: Alignment.topLeft,
                                        //   end: Alignment.bottomRight,
                                        // ),
                                        ),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          flex: 2,
                                          child: ClipRRect(
                                            borderRadius:
                                                const BorderRadius.only(
                                              topLeft: Radius.circular(12),
                                              topRight: Radius.circular(12),
                                            ),
                                            child: Container(
                                              decoration: const BoxDecoration(
                                                gradient: LinearGradient(
                                                  colors: [
                                                    Color(0xFFFFF8E1),
                                                    Color(0xFFFFECB3),
                                                  ],
                                                  begin: Alignment.topCenter,
                                                  end: Alignment.bottomCenter,
                                                ),
                                              ),
                                              child: Stack(
                                                children: [
                                                  Image.network(
                                                    categoryPanditModelList[
                                                            index]
                                                        .image,
                                                    fit: BoxFit.fill,
                                                    width: double.infinity,
                                                    errorBuilder: (context,
                                                            error,
                                                            stackTrace) =>
                                                        Center(
                                                      child: Icon(
                                                        Icons.image,
                                                        size: 40,
                                                        color:
                                                            Colors.orange[300],
                                                      ),
                                                    ),
                                                  ),
                                                  Positioned(
                                                    top: 8,
                                                    right: 8,
                                                    child: Container(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              6),
                                                      decoration: BoxDecoration(
                                                        color: Colors.deepOrange
                                                            .withOpacity(0.8),
                                                        shape: BoxShape.circle,
                                                      ),
                                                      child: const Icon(
                                                        Icons
                                                            .arrow_forward_ios_outlined,
                                                        color: Colors.white,
                                                        size: 18,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          flex: 1,
                                          child: Padding(
                                            padding: const EdgeInsets.all(12),
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  categoryPanditModelList[index]
                                                      .hiName,
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.w700,
                                                    color:
                                                        Colors.deepOrange[900],
                                                  ),
                                                ),
                                                const SizedBox(height: 3),
                                                Text(
                                                  categoryPanditModelList[index]
                                                      .enName,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                    fontSize: Dimensions
                                                        .fontSizeSmall,
                                                    fontWeight: FontWeight.w500,
                                                    color:
                                                        Colors.deepOrange[800],
                                                  ),
                                                  maxLines: 2,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ));
                            },
                          ),
                  ),
                ),
                const SizedBox(height: 15),
              ])
            : const SizedBox.shrink(),
      ],
    );
  }
}
