import 'dart:convert';
import 'package:country_picker/country_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:delayed_display/delayed_display.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mahakal/data/datasource/remote/http/httpClient.dart';
import 'package:mahakal/features/tour_and_travells/view/tour_packages/citywise_tours.dart';
import 'package:tdk_bouncingwidget/tdk_bouncingwidget.dart';
import '../../../utill/app_constants.dart';
import '../../blogs_module/no_image_widget.dart';
import '../../maha_bhandar/model/city_model.dart';
import '../../youtube_vedios/view/dynamic_tabview/grid_view/YoutubeGridView.dart';
import '../model/tour_allcity_model.dart';

class ViewAllTours extends StatefulWidget {
  const ViewAllTours({
    super.key,
    required this.stateName,
    required this.tourSlug,
  });
  final String stateName;
  final String tourSlug;

  @override
  State<ViewAllTours> createState() => _ViewAllToursState();
}

class _ViewAllToursState extends State<ViewAllTours> {
  final TextEditingController _searchController = TextEditingController();
  bool isSearchBox = false;
  bool showTourList = false;
  bool isLoading = true;
  bool isGridView = true;
  List<ListElement>? filteredCategories;
  final _hoverNotifier = ValueNotifier<int>(-1);

  String latitude = "23.179300";
  String longitude = "75.784912";
  String clickCity = "";

  String countryDefault = "Ujjain/Madhya Pradesh";
  final Country selectedCountry = Country(
    phoneCode: "91",
    countryCode: "IN",
    e164Sc: 0,
    geographic: true,
    level: 1,
    name: "India",
    example: "9123456789",
    displayName: "India",
    displayNameNoCountryCode: "India",
    e164Key: "91-IN-0",
  );

  @override
  void initState() {
    super.initState();
    getAllCity();
  }

  Color getPlanTypeColor(String hexColor) {
    // Remove # if present
    hexColor = hexColor.replaceAll("#", "");

    // Parse hex to integer and add FF for full opacity
    return Color(int.parse("FF$hexColor", radix: 16));
  }

  Future<void> getAllCity() async {
    setState(() {
      isLoading = true;
    });

    Map<String, dynamic> data = {
      "special_type": widget.tourSlug,
      "state_name": widget.stateName,
    };

    try {
      final res = await HttpService().postApi(AppConstants.tourStateUrl, data);

      if (res != null) {
        final cityRes = TourAllCityModel.fromJson(res);

        // Combine all list elements from all cities
        List<ListElement> combinedList = [];

        for (var city in cityRes.data) {
          combinedList.addAll(city.list);
        }

        setState(() {
          filteredCategories = combinedList;
          isLoading = false;
        });

        print("Tours fetched: ${filteredCategories?.length}");
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print("Error fetching cities: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  void showNotAvailableDialog(BuildContext context, String cityName) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.orange.withOpacity(0.2),
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header with icon
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.location_off_rounded,
                  size: 40,
                  color: Colors.orange.shade700,
                ),
              ),

              const SizedBox(height: 20),

              // Title
              Text(
                'Currently Unavailable',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange.shade800,
                ),
              ),

              const SizedBox(height: 10),

              // Message
              Text(
                'Tours for $cityName are not available at this time.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade700,
                ),
              ),

              const SizedBox(height: 25),

              // Action button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange.shade600,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                  child: const Text(
                    'UNDERSTOOD',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void locationSheet(BuildContext context, String selectedCountry) {
    TextEditingController countryController = TextEditingController();
    List<CityPickerModel> citylistdata = <CityPickerModel>[];

    void getCityPick(StateSetter modalSetter, [String? initialQuery]) async {
      List<CityPickerModel> citypicket = [];
      var response = await http.post(
        Uri.parse('https://geo.vedicrishi.in/places/'),
        body: {
          "country": selectedCountry,
          "name": initialQuery ?? countryController.text,
        },
      );
      if (response.statusCode == 200) {
        var result = json.decode(response.body);
        print("Api response $result");
        List listLocation = result;
        citypicket.addAll(listLocation.map((e) => CityPickerModel.fromJson(e)));

        modalSetter(() {
          citylistdata.clear();
          citylistdata.addAll(citypicket);
        });
      }
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter modalSetter) {
            // Load cities for the current state when the sheet opens
            WidgetsBinding.instance.addPostFrameCallback((_) {
              getCityPick(modalSetter, widget.stateName);
            });

            return SizedBox(
              height: MediaQuery.of(context).size.height,
              child: Padding(
                padding: MediaQuery.of(context).viewInsets,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SingleChildScrollView(
                      physics: const NeverScrollableScrollPhysics(),
                      child: Column(children: [
                        const SizedBox(height: 50),
                        AppBar(
                          backgroundColor: Colors.transparent,
                          centerTitle: true,
                          leading: IconButton(
                              onPressed: () => Navigator.pop(context),
                              icon: const Icon(
                                CupertinoIcons.chevron_back,
                                color: Colors.red,
                              )),
                          title: const Text(
                            'Search City',
                            style: TextStyle(
                                fontSize: 18.0, fontWeight: FontWeight.bold),
                          ),
                        ),
                        Container(
                          height: 50,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(30)),
                          child: TextFormField(
                            controller: countryController,
                            onChanged: (value) {
                              getCityPick(modalSetter);
                            },
                            decoration: InputDecoration(
                              hintText: 'Search cities in ${widget.stateName}',
                              contentPadding:
                                  const EdgeInsets.only(top: 5, left: 15),
                              labelStyle: TextStyle(
                                  color: Colors.grey.withOpacity(0.5)),
                              suffixIcon: const Icon(
                                CupertinoIcons.search_circle_fill,
                                color: Colors.orange,
                                size: 40,
                              ),
                              counterText: '',
                              alignLabelWithHint: true,
                              focusedErrorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(
                                  color: Colors.red,
                                  width: 2.0,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(
                                  color: Colors.orange,
                                  width: 2.0,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(
                                  color: Colors.grey.shade400,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 15),
                        citylistdata.isEmpty
                            ? const Center(child: CircularProgressIndicator())
                            : ListView.builder(
                                shrinkWrap: true,
                                physics: const BouncingScrollPhysics(),
                                itemCount: citylistdata.length,
                                itemBuilder: (ctx, int index) {
                                  return InkWell(
                                    onTap: () {
                                      final selectedCity = citylistdata[index]
                                          .place
                                          .toLowerCase();
                                      countryController.text = selectedCity;

                                      // Check if any city matches in allTours
                                      final matchingTour =
                                          filteredCategories?.firstWhere(
                                        (tour) =>
                                            tour.enCitiesName
                                                .toLowerCase()
                                                .contains(selectedCity) ||
                                            selectedCity.contains(tour
                                                .enCitiesName
                                                .toLowerCase()),
                                        //orElse: () => null,
                                      );

                                      if (matchingTour != null) {
                                        Navigator.push(
                                          context,
                                          CupertinoPageRoute(
                                            builder: (context) => CityWiseTour(
                                              citiesName: matchingTour.citiesName,
                                              stateName: widget.stateName ?? '',
                                              specialType: widget.tourSlug,
                                              enCityName: '${matchingTour.enCitiesName}',
                                              hiCityName: '${matchingTour.hiCitiesName}',
                                            ),
                                          ),
                                        ).then((_) => Navigator.pop(context));
                                      } else {
                                        showNotAvailableDialog(
                                            context, selectedCity);
                                      }
                                      countryController.clear();
                                    },
                                    // {
                                    //   final selectedCity =
                                    //       citylistdata[index].place.toString();
                                    //   countryController.text = selectedCity;
                                    //
                                    //   // Simple check if any city matches (no need for separate variable)
                                    //   final isAvailable =
                                    //       filteredCategories?.any((category) {
                                    //             final availableCity = category.list[index].enCitiesName?.toLowerCase() ?? '';
                                    //             final searchCity = selectedCity.toLowerCase();
                                    //             return availableCity.contains(searchCity) || searchCity.contains(availableCity);
                                    //           }) ??
                                    //           false;
                                    //
                                    //   if (isAvailable) {
                                    //     // Find the first matching city (we know it exists because isAvailable is true)
                                    //     final matchingCity = filteredCategories!
                                    //         .firstWhere((category) {
                                    //       final availableCity = category
                                    //               .list[index].enCitiesName
                                    //               ?.toLowerCase() ??
                                    //           '';
                                    //       final searchCity =
                                    //           selectedCity.toLowerCase();
                                    //       return availableCity
                                    //               .contains(searchCity) ||
                                    //           searchCity
                                    //               .contains(availableCity);
                                    //     });
                                    //
                                    //     Navigator.push(
                                    //       context,
                                    //       CupertinoPageRoute(
                                    //         builder: (context) => CityWiseTour(
                                    //           citiesName: matchingCity
                                    //                   .list[index]
                                    //                   .enCitiesName ?? selectedCity,
                                    //           stateName: widget.stateName ?? '',
                                    //           specialType: widget.tourSlug ,
                                    //         ),
                                    //       ),
                                    //     ).then((_) => Navigator.pop(context));
                                    //   } else {
                                    //     showNotAvailableDialog(
                                    //         context, selectedCity);
                                    //   }
                                    //   countryController.clear();
                                    // },
                                    child: DelayedDisplay(
                                      delay: const Duration(milliseconds: 500),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              const Icon(Icons.location_pin,
                                                  size: 20,
                                                  color: Colors.black54),
                                              const SizedBox(width: 5),
                                              SizedBox(
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width /
                                                    1.3,
                                                child: Text(
                                                  citylistdata[index].place,
                                                  style: const TextStyle(
                                                    color: Colors.black,
                                                    fontWeight: FontWeight.bold,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    fontSize: 16,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const Divider(color: Colors.grey),
                                        ],
                                      ),
                                    ),
                                  );
                                  //   InkWell(
                                  //   onTap: () {
                                  //     modalSetter(() {
                                  //       final selectedCity = citylistdata[index].place.toString();
                                  //       countryController.text = selectedCity;
                                  //
                                  //       if (_isCityAvailable(selectedCity)) {
                                  //         Navigator.push(
                                  //           context,
                                  //           CupertinoPageRoute(
                                  //             builder: (context) => CityWiseTour(
                                  //               citySlug: '${widget.tourSlug ?? ''}',
                                  //               //citiesName: filteredCategories![index].enCitiesName ?? '',
                                  //               citiesName: clickCity,
                                  //               stateName: widget.stateName ?? '',
                                  //               hiStateName: widget.hiStateName ?? '',
                                  //               tourCategory: widget.tourCategory ?? '',
                                  //               enTourCategory: widget.enTourCategory ?? '',
                                  //             ),
                                  //           ),
                                  //         );
                                  //         Navigator.pop(context);
                                  //       } else {
                                  //         showDialog(
                                  //           context: context,
                                  //           builder: (context) => AlertDialog(
                                  //             title: Text('Not Available'),
                                  //             content: Text('Tours for $selectedCity are not currently available'),
                                  //             actions: [
                                  //               TextButton(
                                  //                 onPressed: () => Navigator.pop(context),
                                  //                 child: Text('OK'),
                                  //               ),
                                  //             ],
                                  //           ),
                                  //         );
                                  //       }
                                  //       countryController.clear();
                                  //     });
                                  //   },
                                  //   child: DelayedDisplay(
                                  //     delay: Duration(milliseconds: 500),
                                  //     child: Column(
                                  //       crossAxisAlignment: CrossAxisAlignment.start,
                                  //       children: [
                                  //         Row(
                                  //           children: [
                                  //             const Icon(Icons.location_pin,
                                  //                 size: 20, color: Colors.black54),
                                  //             const SizedBox(width: 5),
                                  //             SizedBox(
                                  //               width: MediaQuery.of(context).size.width / 1.3,
                                  //               child: Text(
                                  //                 citylistdata[index].place,
                                  //                 style: const TextStyle(
                                  //                     color: Colors.black,
                                  //                     fontWeight: FontWeight.bold,
                                  //                     overflow: TextOverflow.ellipsis,
                                  //                     fontSize: 16),
                                  //               ),
                                  //             ),
                                  //           ],
                                  //         ),
                                  //         const Divider(color: Colors.grey)
                                  //       ],
                                  //     ),
                                  //   ),
                                  // );
                                },
                              ),
                      ])),
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    var screenHeight = MediaQuery.of(context).size.height;
    var screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepOrange,
        title: Text(
          widget.stateName ?? "N/A",
          style: const TextStyle(
              fontWeight: FontWeight.bold, fontSize: 20, color: Colors.white),
        ),
        //centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              isSearchBox ? Icons.close : Icons.search,
              color: Colors.white,
              weight: 2,
              size: 30,
            ),
            onPressed: () {
              locationSheet(context, selectedCountry.name);
            },
          ),
          const SizedBox(width: 10),
          BouncingWidgetInOut(
            onPressed: () {
              setState(() {
                isGridView = !isGridView;
              });
            },
            child: Container(
              height: 35,
              width: 35,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.0),
                  color: isGridView ? Colors.white : Colors.transparent,
                  border: Border.all(
                      color: isGridView ? Colors.transparent : Colors.white,
                      width: 2)),
              child: Icon(
                isGridView ? Icons.grid_view_rounded : Icons.list,
                color: isGridView ? Colors.black : Colors.white,
              ),
            ),
          )
        ],
        leading: InkWell(
          onTap: () {
            Navigator.pop(context); // This will navigate back
          },
          child: const Icon(
            Icons.arrow_back_ios,
            color: Colors.white,
          ),
        ),
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Colors.orange),
            )
          : Column(
              children: [
                Expanded(
                  child: isGridView
                      ? GridView.builder(
                          shrinkWrap: true,
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.all(12),
                          itemCount: filteredCategories?.length ?? 0,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            childAspectRatio: 0.70,
                          ),
                          itemBuilder: (BuildContext context, int index) {
                            final city = filteredCategories?[index];

                            return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  CupertinoPageRoute(
                                    builder: (context) => CityWiseTour(
                                      citiesName: city?.citiesName ?? '',
                                      stateName: widget.stateName,
                                      specialType: widget.tourSlug,
                                      enCityName: '${city?.enCitiesName}',
                                      hiCityName: '${city?.hiCitiesName}',
                                    ),
                                  ),
                                );
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(18),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.08),
                                      blurRadius: 12,
                                      offset: const Offset(0, 6),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // IMAGE WITH GRADIENT
                                    ClipRRect(
                                      borderRadius: const BorderRadius.only(
                                          topLeft: Radius.circular(18),
                                          topRight: Radius.circular(18)),
                                      child: Stack(
                                        children: [
                                          CachedNetworkImage(
                                            imageUrl: city?.tourImage ?? "",
                                            height: 110,
                                            width: double.infinity,
                                            fit: BoxFit.fill,
                                            placeholder: (context, url) =>
                                                Container(
                                                    color:
                                                        Colors.grey.shade200),
                                            errorWidget:
                                                (context, url, error) =>
                                                    const Icon(Icons.image,
                                                        size: 40,
                                                        color: Colors.grey),
                                          ),
                                          // PLAN TYPE CHIP
                                          Positioned(
                                            top: 10,
                                            right: 10,
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 10,
                                                      vertical: 5),
                                              decoration: BoxDecoration(
                                                color: getPlanTypeColor(
                                                    "${city?.planTypeColor}"),
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                              ),
                                              child: Text(
                                                city?.planTypeName
                                                        ?.toUpperCase() ??
                                                    "",
                                                style: const TextStyle(
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                    // CITY DETAILS
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 14, vertical: 12),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          // City Name
                                          Text(
                                            city?.enCitiesName ?? "",
                                            style: TextStyle(
                                              fontSize: screenWidth * 0.045,
                                              fontWeight: FontWeight.w700,
                                              color: Colors.black87,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 5),

                                          // TOUR COUNT TAG
                                          Row(
                                            children: [
                                              const Icon(Icons.tour,
                                                  size: 14,
                                                  color: Colors.deepOrange),
                                              const SizedBox(width: 4),
                                              Text(
                                                "${city?.totalTourCount}+ Tour's available",
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w500,
                                                  color: Colors.grey[700],
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 10),

                                          // EXPLORE BUTTON
                                          Container(
                                            width: double.infinity,
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 10, vertical: 8),
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              gradient: LinearGradient(
                                                colors: [
                                                  Colors.deepOrange.shade500,
                                                  Colors.deepOrange.shade700
                                                ],
                                              ),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.deepOrange
                                                      .withOpacity(0.25),
                                                  blurRadius: 6,
                                                  offset: const Offset(0, 3),
                                                ),
                                              ],
                                            ),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: const [
                                                Text(
                                                  "Explore Tours",
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                SizedBox(width: 6),
                                                Icon(
                                                  CupertinoIcons
                                                      .arrow_right_circle,
                                                  size: 16,
                                                  color: Colors.white,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        )
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.all(5),
                          itemCount: filteredCategories?.length ?? 0,
                          itemBuilder: (BuildContext context, int index) {
                            final city = filteredCategories?[index];
                            return InkWell(
                              onTap: () => {
                                Navigator.push(
                                  context,
                                  CupertinoPageRoute(
                                    builder: (context) => CityWiseTour(
                                      citiesName: city?.citiesName ?? '',
                                      stateName: widget.stateName,
                                      specialType: widget.tourSlug,
                                      enCityName: '${city?.enCitiesName}',
                                      hiCityName: '${city?.hiCitiesName}',
                                    ),
                                  ),
                                )
                              },
                              child: Card(
                                elevation: 8,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                //margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 5),
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        Colors.white,
                                        Colors.grey.shade50
                                      ],
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      // Improved image container with shadow and border
                                      Container(
                                        height: 95,
                                        width: 135,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          boxShadow: [
                                            BoxShadow(
                                              color:
                                                  Colors.black.withOpacity(0.1),
                                              blurRadius: 4,
                                              offset: const Offset(2, 2),
                                            )
                                          ],
                                          image: DecorationImage(
                                            image: NetworkImage(
                                                city?.tourImage ?? ""),
                                            fit: BoxFit.fill,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 16),

                                      // Improved text section with better spacing
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              city?.enCitiesName ?? "",
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w700,
                                                fontSize: 18,
                                                color: Colors.black87,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 1,
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              city?.hiCitiesName ?? "",
                                              style: TextStyle(
                                                color: Colors.grey.shade600,
                                                fontSize: 14,
                                                fontWeight: FontWeight.w500,
                                              ),
                                              maxLines: 1,
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 12),

                                      // Improved icon with container
                                      Container(
                                        padding: const EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          color: Colors.deepOrange.shade100
                                              .withOpacity(0.3),
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.arrow_forward_ios,
                                          color: Colors.deepOrange,
                                          size: 20,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }
}
