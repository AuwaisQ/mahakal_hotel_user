import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mahakal/features/explore/exploreScreen.dart';
import 'package:mahakal/features/explore/rashifalModel.dart';
import 'package:mahakal/features/pooja_booking/model/categorymodel.dart';
import 'package:mahakal/features/pooja_booking/view/pooja_home.dart';
import 'package:mahakal/localization/language_constrants.dart';
import 'package:mahakal/utill/dimensions.dart';
import '../../self_drive/self_form_screen.dart';
import '../model/sectionmodel.dart';

class SectionPoojaBooking extends StatelessWidget {
  const SectionPoojaBooking({
    super.key,
    required this.sectionModelList,
    required this.widget,
    required this.size,
    required this.categoryPoojaModelList,
    required this.poojaBookingImages,
    required this.shimmer,
  });

  final List<Sectionlist> sectionModelList;
  final ExploreScreen widget;
  final Size size;
  final List<GetPoojaCategory> categoryPoojaModelList;
  final List<Rashi> poojaBookingImages;
  final Widget shimmer;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        sectionModelList[9].section.status == 'true'
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
                          getTranslated('book_pooja', context) ??
                              'Pooja Booking',
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
                                  builder: (context) => PoojaHomeView(
                                    tabIndex: 0,
                                    scrollController: widget.scrollController,
                                  ),
                                ),
                              );
                            },
                            child: Text(
                              getTranslated('VIEW_ALL', context) ??
                                  'Pooja Booking',
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
                    height: size.width * 0.6,
                    width: size.width,
                    child: categoryPoojaModelList.isEmpty
                        ? shimmer
                        : ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: categoryPoojaModelList.length,
                            itemBuilder: (BuildContext ctx, index) {
                              return InkWell(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    CupertinoPageRoute(
                                      builder: (context) => PoojaHomeView(
                                        tabIndex: index + 1,
                                        scrollController:
                                            widget.scrollController,
                                      ),
                                    ),
                                  );
                                },
                                child: Container(
                                  margin: const EdgeInsets.only(right: 10),
                                  decoration: BoxDecoration(
                                    border:
                                        Border.all(color: Colors.grey.shade300),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                          flex: 2,
                                          child: ClipRRect(
                                              borderRadius:
                                                  const BorderRadius.only(
                                                      topLeft:
                                                          Radius.circular(10),
                                                      topRight:
                                                          Radius.circular(10)),
                                              child: Image.asset(
                                                  poojaBookingImages[index]
                                                      .image))),
                                      Expanded(
                                        flex: 1,
                                        child: Padding(
                                          padding: const EdgeInsets.only(
                                              left: 10, top: 5),
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                categoryPoojaModelList[index]
                                                    .hiName,
                                                style: const TextStyle(
                                                    fontSize: 20,
                                                    fontWeight:
                                                        FontWeight.w400),
                                              ),
                                              SizedBox(
                                                width: size.width * 0.5,
                                                child: Text(
                                                  poojaBookingImages[index]
                                                      .name,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                      fontSize: Dimensions
                                                          .fontSizeSmall,
                                                      fontWeight:
                                                          FontWeight.w500),
                                                  maxLines: 2,
                                                ),
                                              ),
                                              const SizedBox(height: 5.0),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
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


Widget lowestWidget({
  required String name,
  required String description,
  required String discount,
  required double ht,
  required double imageHt,
  required String image,
  required Color color,
  required VoidCallback onTap,
}) {
  return InkWell(
    onTap: onTap,
    child: Container(
      height: ht,
      width: 95,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withOpacity(0.98),
            color.withOpacity(0.85),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          stops: const [0.2, 0.9], // More controlled gradient
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            /// 🌟 Enhanced Background Effects
            // Primary glow
            Positioned(
              top: -30,
              right: -30,
              child: Container(
                height: 140,
                width: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      Colors.white.withOpacity(0.25),
                      Colors.white.withOpacity(0.05),
                    ],
                    stops: const [0.3, 1.0],
                  ),
                ),
              ),
            ),

            // Secondary glow for depth
            Positioned(
              bottom: -20,
              left: -20,
              child: Container(
                height: 100,
                width: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      color.withOpacity(0.3),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),

            /// 🔹 Main Content
            Padding(
              padding: const EdgeInsets.all(6.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  /// 🔹 Title + Description with improved typography
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name.toUpperCase(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: 0.5,
                          height: 1.2,
                          shadows: [
                            Shadow(
                              color: Colors.black26,
                              offset: Offset(0, 2),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        width: 40,
                        height: 2,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.white,
                              Colors.white.withOpacity(0.3),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.white70,
                          fontWeight: FontWeight.w400,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            /// 🔹 Enhanced Floating Icon with animation support
            Positioned(
              bottom: 0,
              right: 0,
              left: 0,
              child: Image.asset(
                image,
                height: imageHt,
                fit: BoxFit.fill,
                errorBuilder: (context, error, stackTrace) => Icon(
                  Icons.broken_image,
                  size: imageHt,
                  color: color.withOpacity(0.5),
                ),
              ),
            ),

          ],
        ),
      ),
    ),
  );
}
