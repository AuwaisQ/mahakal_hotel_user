import 'dart:math';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mahakal/features/tour_and_travells/view/vendors_page.dart';
import 'package:provider/provider.dart';
import 'package:tdk_bouncingwidget/tdk_bouncingwidget.dart';
import '../../../../data/datasource/remote/http/httpClient.dart';
import '../../../../localization/controllers/localization_controller.dart';
import '../../../../utill/app_constants.dart';
import '../../../../utill/flutter_toast_helper.dart';
import '../../Controller/tour_share_controller.dart';
import '../../model/city_wise_tour_model.dart';
import '../TourDetails.dart';

class CityWiseTour extends StatefulWidget {
  String citiesName;
  String stateName;
  String enCityName;
  String hiCityName;
  String specialType;

  CityWiseTour({
    super.key,
    required this.citiesName,
    required this.stateName,
    required this.specialType,
    required this.enCityName,
    required this.hiCityName,
  });

  @override
  State<CityWiseTour> createState() => _CityWiseTourState();
}

class _CityWiseTourState extends State<CityWiseTour>
    with SingleTickerProviderStateMixin {
  bool isLoading = false;
  bool hasError = false;

  int selecTectedIndex = 0;
  String errorMessage = '';
  bool isGridView = true;
  bool isEngView = true;

  final bool _visible = true;
  TabController? _tabController;
  bool isTabControllerInitialized = false;

  final shareTour = ShareTourController();

  final List<List<Color>> _itemGradients = [];
  List<CityData> cityWiseData = [];
  List<CityData> personUseList = []; // is_person_use == 1
  List<CityData> normalUseList = []; // is_person_use == 0

  @override
  void initState() {
    super.initState();
    getCityWiseData();
    print("Special Type:${widget.specialType}");
    print("Cities Name:${widget.citiesName}");
    print("State Name:${widget.stateName}");
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  Color getPlanTypeColor(String hexColor) {
    // Remove # if present
    hexColor = hexColor.replaceAll("#", "");

    // Parse hex to integer and add FF for full opacity
    return Color(int.parse("FF$hexColor", radix: 16));
  }

  Future<void> getCityWiseData() async {
    setState(() => isLoading = true);

    Map<String, dynamic> data = {
      "special_type": widget.specialType,
      "cities_name": widget.citiesName,
      "state_name": widget.stateName,
    };

    try {
      final res = await HttpService().postApi(AppConstants.tourStateUrl, data);

      if (res != null) {
        final getCityData = CityWiseTourModel.fromJson(res);

        cityWiseData = getCityData.data ?? [];
        personUseList =
            cityWiseData.where((e) => e.isPersonUse.toString() == '1').toList();

        normalUseList =
            cityWiseData.where((e) => e.isPersonUse.toString() == '0').toList();

        print("My Person list:${personUseList}");
        print("My Cab List:${normalUseList}");

        // Determine tab count
        int tabLength = 0;
        if (personUseList.isNotEmpty && normalUseList.isNotEmpty) {
          tabLength = 2;
        } else if (personUseList.isNotEmpty || normalUseList.isNotEmpty) {
          tabLength = 1;
        }

        // Only create TabController if tabLength > 0
        if (tabLength > 0) {
          int initialTabIndex = 0;

          // Dispose previous controller if exists
          _tabController?.dispose();

          _tabController = TabController(
            length: tabLength,
            vsync: this,
            initialIndex: initialTabIndex,
          );

          _tabController!.addListener(() {
            if (mounted) {
              setState(() {
                selecTectedIndex = _tabController!.index;
              });

              print("Tab Selected Index:${_tabController!.index}");
            }
          });
          isTabControllerInitialized = true;
        } else {
          _tabController?.dispose();
          _tabController = null;
          isTabControllerInitialized = false;
        }
        setUpTabs();
      }
    } catch (e) {
      print("Error in getCityWiseData: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  String formatDateRange(String dateRange) {
    List<String> dates = dateRange.split(' - ');
    if (dates.length != 2) return 'Invalid date range';

    try {
      DateTime startDate = DateTime.parse(dates[0]);
      DateTime endDate = DateTime.parse(dates[1]);
      String formattedStartDate = DateFormat('d MMM').format(startDate);
      String formattedEndDate = DateFormat('d MMM').format(endDate);
      return '$formattedStartDate to $formattedEndDate';
    } catch (e) {
      return 'Invalid date';
    }
  }

  String formatIndianCurrency(dynamic amount) {
    num parsedAmount = 0;

    // Try to safely parse any input type
    if (amount is num) {
      parsedAmount = amount;
    } else if (amount is String) {
      parsedAmount = num.tryParse(amount.replaceAll(',', '')) ?? 0;
    }

    final format = NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹',
      decimalDigits: 0,
    );

    return format.format(parsedAmount);
  }

  Widget _buildTourItemList(
    CityData tour,
  ) {
    //  Filter valid cabs with numeric price
    final validCabs = tour.cabList
        .where((cab) => cab.price != null && int.tryParse(cab.price!) != null)
        .toList();

    int minPriceIndex = 0; // default (not found)

    if (validCabs.isNotEmpty) {
      int minPrice = int.parse(validCabs.first.price!);

      for (int i = 0; i < validCabs.length; i++) {
        int currentPrice = int.parse(validCabs[i].price!);
        if (currentPrice < minPrice) {
          minPrice = currentPrice;
          minPriceIndex = i;
        }
      }
    }

    return GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            CupertinoPageRoute(
              builder: (context) => TourDetails(productId: tour.id.toString()),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ---------------- LEFT IMAGE ----------------
                Container(
                  height: 150,
                  width: 190,
                  padding: const EdgeInsets.all(8),
                  margin:
                      const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: Colors.grey.shade300, // Border color
                      width: 1.5, // Border thickness
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius:
                        BorderRadius.circular(10), // Image bhi rounded ho
                    child: Stack(
                      children: [
                        // Background Image
                        Positioned.fill(
                          child: CachedNetworkImage(
                            imageUrl: tour.tourImage,
                            fit: BoxFit.fill,
                            placeholder: (context, url) => placeholderImage(),
                            errorWidget: (context, url, error) =>
                                const NoImageWidget(),
                          ),
                        ),

                        // Gradient
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: [
                                Colors.black.withOpacity(0.6),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),

                        // lABLE Badge
                        Positioned(
                          top: 16, // thoda andar niche
                          left: -40, // bahar nikal diya taki diagonal fit ho
                          child: Transform.rotate(
                            angle: -0.785, // -45 degrees
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 45, vertical: 5),
                              color: getPlanTypeColor(
                                  "${tour.planTypeColor}"), // OR tour.planTypeColor
                              child: Text(
                                "${tour.planTypeName.toUpperCase()}",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 10,
                                  letterSpacing: 1,
                                ),
                              ),
                            ),
                          ),
                        ),

                        /// Days Badge
                        Positioned(
                          top: 8,
                          right: 8,
                          child: Consumer<LocalizationController>(
                            builder: (context, localizationController, child) {
                              String currentLang =
                                  localizationController.locale.languageCode;
                              String numberOfDay = currentLang == "hi"
                                  ? tour.hiNumberOfDay ?? ""
                                  : tour.enNumberOfDay ?? "";

                              return Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  numberOfDay,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),

                        /// Percentage Off
                        tour.percentageOff == 0
                            ? SizedBox()
                            : Positioned(
                                bottom: 5,
                                right: 5,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 5),
                                  decoration: BoxDecoration(
                                    color: Colors.green[700],
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.3),
                                        blurRadius: 6,
                                        offset: const Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.local_offer,
                                        size: 16,
                                        color: Colors.white,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        "${tour.percentageOff}% OFF",
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                      ],
                    ),
                  ),
                ),

                // ---------------- RIGHT CONTENT ----------------
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Location
                        if (tour.pickupLocation.isNotEmpty)
                          Row(
                            children: [
                              Icon(Icons.location_on,
                                  size: 14, color: Colors.orange),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  tour.pickupLocation ?? "",
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade600,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        const SizedBox(height: 4),

                        // Tour Name
                        Consumer<LocalizationController>(
                          builder: (context, localizationController, child) {
                            String currentLang =
                                localizationController.locale.languageCode;
                            return Text(
                              currentLang == "hi"
                                  ? tour.hiTourName
                                  : tour.enTourName,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            );
                          },
                        ),
                        const SizedBox(height: 4),

                        // Tags row (services)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Services
                            if (tour.services.isNotEmpty ?? false)
                              Wrap(
                                spacing: 8,
                                children: (tour.services ?? []).map((service) {
                                  String? imagePath;
                                  if (service.toUpperCase() == "TRANSPORT") {
                                    imagePath = 'assets/image/tour_vehicle.png';
                                  } else if (service.toUpperCase() == "FOOD") {
                                    imagePath = 'assets/image/tour_meal.png';
                                  } else if (service.toUpperCase() == "HOTEL") {
                                    imagePath = 'assets/image/tour_hotel.png';
                                  }
                                  return imagePath != null
                                      ? Container(
                                          padding: const EdgeInsets.all(4),
                                          decoration: BoxDecoration(
                                            color:
                                                Colors.orange.withOpacity(0.25),
                                            borderRadius:
                                                BorderRadius.circular(6),
                                          ),
                                          child: Image.asset(
                                            imagePath,
                                            width: 20,
                                            height: 20,
                                            color: Colors.black,
                                          ),
                                        )
                                      : const SizedBox();
                                }).toList(),
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),

                        (double.tryParse(tour.reviewAvgStar ?? "0") ?? 0.0) > 0
                            ? Row(
                                children: [
                                  ...List.generate(5, (index) {
                                    double rating = double.tryParse(
                                            tour.reviewAvgStar ?? "0") ??
                                        0.0;

                                    if (rating >= index + 1) {
                                      return const Icon(Icons.star,
                                          color: Colors.orange, size: 20);
                                    } else if (rating > index &&
                                        rating < index + 1) {
                                      return const Icon(Icons.star_half,
                                          color: Colors.orange, size: 20);
                                    } else {
                                      return const Icon(Icons.star_border,
                                          color: Colors.orange, size: 20);
                                    }
                                  }),
                                  const SizedBox(width: 6),
                                  Text(
                                    "(${(double.tryParse(tour.reviewAvgStar ?? "0") ?? 0.0).toStringAsFixed(1)})",
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ],
                              )
                            : const SizedBox.shrink(),

                        // Rating + Price
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (tour.percentageOff != 0)
                              Text(
                                '\₹${tour.cabList[minPriceIndex].minPrice}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey,
                                  decoration: TextDecoration.lineThrough,
                                ),
                              ),
                            if (tour.cabList[minPriceIndex].price != null)
                              Text.rich(
                                TextSpan(
                                  children: [
                                    TextSpan(
                                      text:
                                          "₹${tour.cabList[minPriceIndex].price}",
                                      style: const TextStyle(
                                        fontSize: 25,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blue,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ));
  }

  Widget _buildTourItemGrid(
    CityData tour,
  ) {
    String formattedDateRange = formatDateRange(tour.date);

//  Filter valid cabs with numeric price
    final validCabs = tour.cabList
        .where((cab) => cab.price != null && int.tryParse(cab.price!) != null)
        .toList();

    int minPriceIndex = 0; // default (not found)

    if (validCabs.isNotEmpty) {
      int minPrice = int.parse(validCabs.first.price!);

      for (int i = 0; i < validCabs.length; i++) {
        int currentPrice = int.parse(validCabs[i].price!);
        if (currentPrice < minPrice) {
          minPrice = currentPrice;
          minPriceIndex = i;
        }
      }
    }

    return GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            CupertinoPageRoute(
              builder: (context) => TourDetails(productId: tour.id.toString()),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.only(left: 15, right: 10, bottom: 10),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ---------------- IMAGE + OVERLAYS ----------------
                ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(16)),
                  child: SizedBox(
                    height: MediaQuery.of(context).size.height * 0.25,
                    width: double.infinity,
                    child: Stack(
                      children: [
                        // Background Image
                        Positioned.fill(
                          child: CachedNetworkImage(
                            imageUrl: tour.tourImage,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => placeholderImage(),
                            errorWidget: (context, url, error) =>
                                const NoImageWidget(),
                          ),
                        ),

                        // Gradient
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: [
                                Colors.black.withOpacity(0.6),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),

                        // Premium Sticker
                        Positioned(
                          top: 16, // thoda andar niche
                          left: -40, // bahar nikal diya taki diagonal fit ho
                          child: Transform.rotate(
                            angle: -0.785, // -45 degrees
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 45, vertical: 6),
                              color: getPlanTypeColor(
                                  "${tour.planTypeColor}"), // OR tour.planTypeColor
                              child: Text(
                                "${tour.planTypeName.toUpperCase()}",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                  letterSpacing: 1,
                                ),
                              ),
                            ),
                          ),
                        ),

                        //  No of day
                        Positioned(
                            bottom: 60,
                            left: 20,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 6,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Text(
                                isEngView
                                    ? tour.enNumberOfDay
                                    : tour.hiNumberOfDay,
                                style: const TextStyle(
                                  color: Colors.black87,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            )),

                        // Services + Date badge
                        Positioned(
                          left: 12,
                          right: 12,
                          bottom: 12,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Services
                              if (tour.services.isNotEmpty ?? false)
                                Wrap(
                                  spacing: 8,
                                  children:
                                      (tour.services ?? []).map((service) {
                                    String? imagePath;
                                    if (service.toUpperCase() == "TRANSPORT") {
                                      imagePath =
                                          'assets/image/tour_vehicle.png';
                                    } else if (service.toUpperCase() ==
                                        "FOOD") {
                                      imagePath = 'assets/image/tour_meal.png';
                                    } else if (service.toUpperCase() ==
                                        "HOTEL") {
                                      imagePath = 'assets/image/tour_hotel.png';
                                    }
                                    return imagePath != null
                                        ? Container(
                                            padding: const EdgeInsets.all(5),
                                            decoration: BoxDecoration(
                                              color: Colors.white
                                                  .withOpacity(0.25),
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                            ),
                                            child: Image.asset(
                                              imagePath,
                                              width: 30,
                                              height: 30,
                                              color: Colors.white,
                                            ),
                                          )
                                        : const SizedBox();
                                  }).toList(),
                                ),

                              // Date Badge
                              if (tour.date?.isNotEmpty ?? false)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 5),
                                  decoration: BoxDecoration(
                                    color: Colors.orange.shade700,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    formattedDateRange,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),

                        // Per Off
                        tour.percentageOff == 0
                            ? SizedBox()
                            : Positioned(
                                top: 10,
                                right: 10,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: Colors.green[700],
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.3),
                                        blurRadius: 6,
                                        offset: const Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.local_offer,
                                        size: 14,
                                        color: Colors.white,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        "${tour.percentageOff}% OFF",
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                      ],
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            flex: 1,
                            child: Text(
                              isEngView ? tour.enTourName : tour.hiTourName,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                                height: 1.3,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              shareTour.shareTour(
                                context,
                                "${tour.shareLink}",
                                "${tour.tourImage}",
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                border: Border.all(
                                    color: Colors.blueGrey, width: 0.5),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.08),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.share,
                                color: Colors.black,
                                size: 18,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      //  Services Tags
                      if (tour.services.isNotEmpty)
                        Wrap(
                          spacing: 6,
                          runSpacing: -6,
                          children: (tour.services ?? []).map((service) {
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade200,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                service.toUpperCase(),
                                style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.red,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.6),
                              ),
                            );
                          }).toList(),
                        ),

                      const SizedBox(height: 12),

                      //  Rating + Price Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Left Side - Special Badge + Rating
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // 🔖 Special Tour Badge
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 5),
                                decoration: BoxDecoration(
                                  color: Colors.deepOrange,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  "${tour.tourType.toUpperCase()}",
                                  style: const TextStyle(
                                    // <-- Changed to const
                                    fontSize: 12,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 6),

                              // ⭐ Rating
                              (double.tryParse(tour.reviewAvgStar ?? "0") ?? 0.0) > 0
                                  ? Row(
                                children: [
                                  ...List.generate(5, (index) {
                                    double rating = double.tryParse(
                                        tour.reviewAvgStar ?? "0") ??
                                        0.0;

                                    if (rating >= index + 1) {
                                      return const Icon(Icons.star,
                                          color: Colors.orange, size: 20);
                                    } else if (rating > index &&
                                        rating < index + 1) {
                                      return const Icon(Icons.star_half,
                                          color: Colors.orange, size: 20);
                                    } else {
                                      return const Icon(Icons.star_border,
                                          color: Colors.orange, size: 20);
                                    }
                                  }),
                                  const SizedBox(width: 6),
                                  Text(
                                    "(${(double.tryParse(tour.reviewAvgStar ?? "0") ?? 0.0).toStringAsFixed(1)})",
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ],
                              )
                                  : const SizedBox.shrink(),
                            ],
                          ),

                          // Right Side - Pricing
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              if (tour.percentageOff != 0 &&
                                  tour.cabList[minPriceIndex].minPrice != null)
                                Text(
                                  formatIndianCurrency("${tour.cabList[minPriceIndex].minPrice}"),
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                    decoration: TextDecoration.lineThrough,
                                  ),
                                ),
                              if (tour.cabList[minPriceIndex].price != null)
                                Text(
                                  formatIndianCurrency("${tour.cabList[minPriceIndex].price}"),
                                 // "₹${tour.cabList[minPriceIndex].price}",
                                  style: const TextStyle(
                                    color: Colors.blue,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      Container(
                        width: double.infinity,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.deepOrange,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Text(
                            'Explore Tour',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
        ));
  }

  final List<Tab> _tabs = [];

  List<Widget> get _tabViews {
    List<Widget> views = [];
    if (personUseList.isNotEmpty) {
      views.add(buildPersonList());
    }
    if (normalUseList.isNotEmpty) {
      views.add(buildCabList());
    }
    return views;
  }

  void setUpTabs() {
    _tabs.clear();
    int index = 0;

    if (personUseList.isNotEmpty) {
      _tabs.add(
        buildCustomTab(
          title: "Person Group",
          imagePath: "assets/image/tour_vehicle.png",
          tabIndex: index,
        ),
      );
      index++;
    }

    if (normalUseList.isNotEmpty) {
      _tabs.add(
        buildCustomTab(
          title: "By Cab",
          imagePath: "assets/image/tour_vehicle.png",
          tabIndex: index,
        ),
      );
    }

    setState(() {});
  }

  Widget buildPersonList() {
    return personUseList.isEmpty
        ? const Center(child: Text('No tours available'))
        : ListView.builder(
            itemCount: personUseList.length,
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.zero,
            itemBuilder: (context, index) {
              return isGridView
                  ? _buildTourItemGrid(personUseList[index])
                  : _buildTourItemList(personUseList[index]);
            },
          );
  }

  Widget buildCabList() {
    return normalUseList.isEmpty
        ? const Center(child: Text('No tours available'))
        : ListView.builder(
            itemCount: normalUseList.length,
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.zero,
            itemBuilder: (context, index) {
              return isGridView
                  ? _buildTourItemGrid(normalUseList[index])
                  : _buildTourItemList(normalUseList[index]);
              },
          );
  }

// In the buildCustomTab method
  Tab buildCustomTab({required String title, required int tabIndex, required String imagePath}) {

    final bool isSelected = _tabController != null && _tabController!.index == tabIndex;

    print("Selected $isSelected");
    return Tab(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 3),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.orange : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? Colors.orange : Colors.grey.shade400,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.orange.withOpacity(0.3),
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                  )
                ]
              : [],
        ),
        child: Center(
          child: Row(
            children: [
              Image.asset(
                imagePath,
                color: isSelected ? Colors.white : Colors.black,
              ),
              SizedBox(width: 10),
              Text(
                title,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    setUpTabs();
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.deepOrange,
        title: Text(
          isEngView
              ? widget.enCityName
              : widget.hiCityName,
          style: const TextStyle(
              fontWeight: FontWeight.bold, color: Colors.white),
        ),
        leading: InkWell(
            onTap: () => {
                  Navigator.pop(context) // This will navigate back
                },
            child: const Icon(
              Icons.arrow_back_ios,
              color: Colors.white,
            )),
        //centerTitle: true,
        actions: [
          BouncingWidgetInOut(
            onPressed: () {
              setState(() {
                isEngView = !isEngView;
              });
            },
            child: Container(
              padding: const EdgeInsets.all(2.0),
              height: 35,
              width: 35,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.0),
                  color: isEngView ? Colors.white : Colors.transparent,
                  border: Border.all(
                      color: isEngView ? Colors.transparent : Colors.white,
                      width: 2)),
              child: Icon(
                isEngView ? Icons.translate : Icons.language_outlined,
                color: isEngView ? Colors.black : Colors.white,
              ),
            ),
          ),
          SizedBox(
            width: 15,
          ),
          GestureDetector(
            onTap: () {
              Navigator.push(
                  context,
                  CupertinoPageRoute(
                      builder: (context) => VendorsPage(
                            isEngView: isEngView,
                          )));
            },
            child: Container(
              padding: const EdgeInsets.all(2.0),
              height: 35,
              width: 35,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.0),
                  color: isGridView ? Colors.white : Colors.transparent,
                  border: Border.all(
                      color: isGridView ? Colors.transparent : Colors.white,
                      width: 2)),
              child: Icon(
                Icons.all_inbox_outlined,
                color: Colors.black,
              ),
            ),
          ),
          SizedBox(
            width: 18,
          ),
          BouncingWidgetInOut(
            onPressed: () {
              setState(() {
                isGridView = !isGridView;
              });
            },
            child: Container(
              padding: const EdgeInsets.all(2.0),
              height: 35,
              width: 35,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.0),
                  color: isGridView ? Colors.white : Colors.transparent,
                  border: Border.all(
                      color: isGridView ? Colors.transparent : Colors.white,
                      width: 2)),
              child: Icon(
                isGridView ? Icons.grid_view : Icons.list,
                color: isGridView ? Colors.black : Colors.white,
              ),
            ),
          ),
          SizedBox(
            width: 18,
          )
        ],
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(
              color: Colors.orange,
            ))
          : cityWiseData.isEmpty
              ? const Text("No Data")
              : Column(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.orange, width: 0.5),
                      ),
                      margin: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: TabBar(
                            controller: _tabController,
                            dividerColor: Colors.transparent,
                            splashFactory: NoSplash.splashFactory,
                            tabs: _tabs,
                            indicator: const BoxDecoration(
                              color: Colors.transparent,
                            ),
                            labelPadding: EdgeInsets.zero,
                            onTap: (index) => {
                                  setState(() {
                                    selecTectedIndex = index;
                                  }),
                                  print("Index Selected $selecTectedIndex")
                                }),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: Divider(color: Colors.grey.shade300),
                    ),
                    const SizedBox(height: 5),
                    Expanded(
                      child: TabBarView(
                          controller: _tabController,
                          //physics: const NeverScrollableScrollPhysics(),
                          children: _tabViews),
                    ),
                    const SizedBox(height: 15),
                  ],
                ),
    );
  }
}
