import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../data/datasource/remote/http/httpClient.dart';
import '../../../../localization/controllers/localization_controller.dart';
import '../../../../utill/app_constants.dart';
import '../../../blogs_module/no_image_widget.dart';
import '../../../youtube_vedios/view/dynamic_tabview/grid_view/YoutubeGridView.dart';
import '../../model/state_wise_tour_model.dart';
import '../view_all_tours.dart';
import 'citywise_tours.dart';

class StateWiseTour extends StatefulWidget {
  String stateSlug;

  StateWiseTour({
    super.key,
    required this.stateSlug,
  });

  @override
  State<StateWiseTour> createState() => _StateWiseTourState();
}

class _StateWiseTourState extends State<StateWiseTour> {
  bool isLoading = false;

  TextEditingController stateSearchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    print(widget.stateSlug);
    getStateWiseData(widget.stateSlug);
  }

  List<StateData> stateWiseData = [];

  /// Get Tour State wise data
  Future<void> getStateWiseData(String slug) async {
    Map<String, dynamic> data = {"special_type": widget.stateSlug};

    setState(() {
      isLoading = true;
    });

    try {
      final res = await HttpService().postApi(AppConstants.tourStateUrl, data);
      print(res);
      if (res != null) {
        final getStateData = StateWiseTourModel.fromJson(res);
        setState(() {
          stateWiseData = getStateData.data;
          print(stateWiseData.length);
        });
      }
    } catch (e) {
      print("error in fetch stateWise Data $e");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? const Center(
            child: CircularProgressIndicator(
            color: Colors.orange,
          ))
        : stateWiseData.isNotEmpty
            ? ListView.builder(
                itemCount: stateWiseData.length,
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.zero,
                itemBuilder: (context, index) {
                  final stateData =
                      stateWiseData[index]; // Ensure this is the correct type
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // State Header with Neumorphic Design
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        child: Row(
                          children: [
                            // State Indicator with Animated Border
                            Container(
                              height: 24,
                              width: 24,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.orange.withOpacity(0.8),
                                  width: 2,
                                ),
                              ),
                              child: Center(
                                child: Container(
                                  height: 12,
                                  width: 12,
                                  decoration: const BoxDecoration(
                                    color: Colors.orange,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            // State Name with Gradient Text
                            Consumer<LocalizationController>(
                              builder:
                                  (context, localizationController, child) {
                                String currentLang =
                                    localizationController.locale.languageCode;
                                String stateName = currentLang == 'hi'
                                    ? stateData.hiStateName ?? ''
                                    : stateData.enStateName ?? '';
                                return ShaderMask(
                                  shaderCallback: (bounds) => LinearGradient(
                                    colors: [
                                      Colors.orange.shade700,
                                      Colors.deepOrange.shade400
                                    ],
                                    begin: Alignment.centerLeft,
                                    end: Alignment.centerRight,
                                  ).createShader(bounds),
                                  child: Text(
                                    stateName,
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                    ),
                                  ),
                                );
                              },
                            ),
                            const Spacer(),
                            // View All Button with Micro Interaction
                            Consumer<LocalizationController>(
                              builder:
                                  (context, localizationController, child) {
                                String currentLang =
                                    localizationController.locale.languageCode;
                                return InkWell(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      CupertinoPageRoute(
                                        builder: (context) => ViewAllTours(
                                          stateName:
                                              stateData.enStateName ?? "",
                                          tourSlug: widget.stateSlug,
                                        ),
                                      ),
                                    );
                                  },
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: Colors.orange.withOpacity(0.3),
                                        width: 1.5,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          currentLang == 'hi'
                                              ? 'सभी देखें'
                                              : 'View All',
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.orange.shade700,
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        Icon(
                                          Icons.arrow_forward_rounded,
                                          size: 16,
                                          color: Colors.orange.shade700,
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            )
                          ],
                        ),
                      ),

                      // City List with Parallax Effect
                      SizedBox(
                        height: 125,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: stateData
                              .list.length, // Ensure this is the correct type
                          padding: const EdgeInsets.only(left: 16, right: 8),
                          itemBuilder: (context, cityIndex) {
                            final city = stateData.list[
                                cityIndex]; // Ensure this is the correct type
                            return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  PageRouteBuilder(
                                    transitionDuration:
                                        const Duration(milliseconds: 500),
                                    pageBuilder: (_, __, ___) => CityWiseTour(
                                      citiesName: city.citiesName ?? '',
                                      stateName: stateData.enStateName ?? '',
                                      specialType: "${widget.stateSlug}",
                                      enCityName: '${city.enCitiesName}',
                                      hiCityName: '${city.hiCitiesName}',
                                    ),
                                  ),
                                );
                              },
                              child: Padding(
                                padding: const EdgeInsets.only(
                                    right: 12, bottom: 12),
                                child: AspectRatio(
                                  aspectRatio: 1.3,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(16),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.1),
                                          blurRadius: 12,
                                          spreadRadius: 2,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(16),
                                      child: Stack(
                                        children: [
                                          // Image with Parallax Effect
                                          Positioned.fill(
                                            child: Hero(
                                              tag: 'city_${city.enCitiesName}',
                                              child: CachedNetworkImage(
                                                imageUrl: city.tourImage ?? "",
                                                fit: BoxFit.fill,
                                                alignment: Alignment.center,
                                                placeholder: (context, url) =>
                                                    placeholderImage(),
                                                errorWidget:
                                                    (context, url, error) =>
                                                        const NoImageWidget(),
                                              ),
                                            ),
                                          ),

                                          // Bottom gradient overlay
                                          Positioned(
                                            bottom: 0,
                                            left: 0,
                                            right: 0,
                                            child: IgnorePointer(
                                              child: Container(
                                                height: 80,
                                                decoration: BoxDecoration(
                                                  gradient: LinearGradient(
                                                    begin: const Alignment(
                                                        0.0, 0.8),
                                                    end: Alignment.topCenter,
                                                    colors: [
                                                      Colors.black
                                                          .withOpacity(0.7),
                                                      Colors.transparent,
                                                    ],
                                                    stops: const [0.0, 0.8],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),

                                          // City Name with Floating Effect
                                          Positioned(
                                            bottom: 5,
                                            left: 5,
                                            right: 5,
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                // Hindi City Name
                                                Text(
                                                  city.hiCitiesName ?? "",
                                                  style: const TextStyle(
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.w700,
                                                    color: Colors.white,
                                                    shadows: [
                                                      Shadow(
                                                        blurRadius: 6,
                                                        color: Colors.black45,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                const SizedBox(height: 2),
                                                // English City Name (Subtle)
                                                Text(
                                                  city.enCitiesName ?? "",
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    color: Colors.white
                                                        .withOpacity(0.9),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),

                      // Divider with Gradient
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Divider(
                          height: 24,
                          thickness: 1,
                          color: Colors.grey.withOpacity(0.1),
                        ),
                      ),
                    ],
                  );
                },
              )
            : const Center(child: Text("No Data"));
  }
}
