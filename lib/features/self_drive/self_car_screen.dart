import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mahakal/features/self_drive/self_form_screen.dart';
import 'package:mahakal/features/self_drive/self_payment_screen.dart';

import '../../data/datasource/remote/http/httpClient.dart';
import '../../utill/loading_datawidget.dart';
import 'model/car_category_model.dart';
import 'model/carlist_model.dart';
import 'self_drive_details.dart';

class CarSelectionPage extends StatefulWidget {
  final String type;
  final String categoryType;
  final String location;
  final String pickDate;
  final String pickTime;
  final String dropDate;
  final String dropTime;
  final double? totalHour;
  final String leadId;
  final List<CategoryCar> carType;
  const CarSelectionPage({
    super.key,
    required this.type,
    required this.categoryType,
    required this.location,
    required this.pickDate,
    required this.pickTime,
    required this.dropDate,
    required this.dropTime,
    required this.totalHour,
    required this.leadId,
    required this.carType,
  });

  @override
  State<CarSelectionPage> createState() => _CarSelectionPageState();
}

class _CarSelectionPageState extends State<CarSelectionPage>
    with TickerProviderStateMixin {
  final List<CarList> categoryList = <CarList>[];
  final List<CarsDatum> carModelList = <CarsDatum>[];
  TabController? _tabController;
  String? selectedImage;
  bool isGrid = false;
  int? selectedCarIndex;

  void getCategorySelf(String type) async {
    String option = widget.type == 'self' ? 'hour' : 'km';
    var res = await HttpService().getApi(
        '/api/v1/self-vehicle/cab-category?status=0&type=$type&self_tour_type=$option');

    print('api car category $res');

    if (res['status'] == 1 && res['data'] != null) {
      setState(() {
        categoryList.clear();
        carModelList.clear();
        List carList = res['data'];
        categoryList.addAll(carList.map((e) => CarList.fromJson(e)));
        _tabController = TabController(
          length: categoryList.length,
          vsync: this,
        );
      });
    }
  }

  void showCarTypeDialog() {
    final searchController = TextEditingController();
    String searchQuery = '';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      backgroundColor: Colors.white,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            // Filtered list based on search
            List<dynamic> filteredCarTypes = searchQuery.isEmpty
                ? widget.carType
                : widget.carType.where((car) {
                    return car.enBrandName
                        .toLowerCase()
                        .contains(searchQuery.toLowerCase());
                  }).toList();

            return Container(
              padding: const EdgeInsets.all(20),
              height: MediaQuery.of(context).size.height * 0.7,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// Header with better styling
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Select Vehicle Type",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A1A1A),
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.grey.shade200,
                        ),
                        child: IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.close, color: Colors.black54),
                          constraints: const BoxConstraints(
                            minWidth: 40,
                            minHeight: 40,
                          ),
                          padding: EdgeInsets.zero,
                        ),
                      )
                    ],
                  ),

                  const SizedBox(height: 16),

                  /// Search Bar
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: TextField(
                      controller: searchController,
                      onChanged: (value) {
                        setModalState(() {
                          searchQuery = value;
                        });
                      },
                      decoration: InputDecoration(
                        hintText: "Search car type...",
                        hintStyle: TextStyle(color: Colors.grey.shade500),
                        prefixIcon:
                            Icon(Icons.search, color: Colors.grey.shade600),
                        suffixIcon: searchQuery.isNotEmpty
                            ? IconButton(
                                icon: Icon(Icons.clear,
                                    color: Colors.grey.shade600, size: 20),
                                onPressed: () {
                                  searchController.clear();
                                  setModalState(() {
                                    searchQuery = '';
                                  });
                                },
                              )
                            : null,
                        border: InputBorder.none,
                        contentPadding:
                            const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  /// Section header with count
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Available Types",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          "${filteredCarTypes.length} found",
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: Colors.blue.shade800,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  /// List with empty state handling
                  Expanded(
                    child: filteredCarTypes.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.no_crash_outlined,
                                  size: 64,
                                  color: Colors.grey.shade400,
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  "No car types found",
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "Try searching with different keywords",
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey.shade500,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            itemCount: filteredCarTypes.length,
                            itemBuilder: (context, index) {
                              final originalIndex = widget.carType
                                  .indexOf(filteredCarTypes[index]);
                              bool isSelected =
                                  selectedCarIndex == originalIndex;

                              return GestureDetector(
                                onTap: () {
                                  setModalState(() {
                                    selectedCarIndex = originalIndex;
                                  });

                                  /// Haptic feedback for better UX
                                  // HapticFeedback.selectionClick();
                                },
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  margin:
                                      const EdgeInsets.symmetric(vertical: 6),
                                  padding: const EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? Colors.blue.withOpacity(0.1)
                                        : Colors.grey.shade50,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: isSelected
                                          ? Colors.blue
                                          : Colors.transparent,
                                      width: 1.5,
                                    ),
                                    boxShadow: isSelected
                                        ? [
                                            BoxShadow(
                                              color: Colors.blue
                                                  .withOpacity(0.2),
                                              blurRadius: 8,
                                              offset: const Offset(0, 2),
                                            )
                                          ]
                                        : null,
                                  ),
                                  child: Row(
                                    children: [
                                      /// Icon with gradient background
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: isSelected
                                              ? Colors.blue
                                              : Colors.grey.shade200,
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        child: Icon(
                                          Icons.directions_car,
                                          color: isSelected
                                              ? Colors.white
                                              : Colors.grey.shade700,
                                          size: 22,
                                        ),
                                      ),

                                      const SizedBox(width: 14),

                                      /// Name and optional subtitle
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              filteredCarTypes[index]
                                                  .enBrandName,
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600,
                                                color: isSelected
                                                    ? Colors.blue.shade700
                                                    : const Color(0xFF1A1A1A),
                                              ),
                                            ),
                                            if (isSelected)
                                              const SizedBox(height: 2),
                                            if (isSelected)
                                              Text(
                                                "Selected",
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.blue.shade400,
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),

                                      /// Radio button style
                                      Container(
                                        width: 24,
                                        height: 24,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: isSelected
                                                ? Colors.blue
                                                : Colors.grey.shade400,
                                            width: 2,
                                          ),
                                        ),
                                        child: isSelected
                                            ? Container(
                                                margin: const EdgeInsets.all(4),
                                                decoration: const BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  color: Colors.blue,
                                                ),
                                              )
                                            : null,
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                  ),

                  const SizedBox(height: 16),

                  /// Apply Button with counter
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: selectedCarIndex == null
                              ? null
                              : () {
                                  final selectedCar =
                                      widget.carType[selectedCarIndex!];

                                  /// 🔥 BottomSheet close
                                  Navigator.pop(context);

                                  /// 🔥 Find index in current tabs
                                  int tabIndex = categoryList.indexWhere(
                                    (e) =>
                                        e.enBrandName ==
                                        selectedCar.enBrandName,
                                  );

                                  /// 🔥 Agar tab mil gaya
                                  if (tabIndex != -1 &&
                                      _tabController != null) {
                                    _tabController!.animateTo(tabIndex);
                                  }

                                  /// 🔥 Agar tab nahi mila → API reload
                                  else {
                                    getCategorySelf(selectedCar.enBrandName);
                                  }

                                  /// Optional SnackBar (safe)
                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                            "${selectedCar.enBrandName} selected"),
                                      ),
                                    );
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            disabledBackgroundColor: Colors.grey.shade300,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            elevation: 0,
                          ),
                          child: Text(
                            selectedCarIndex != null
                                ? "Apply Selection"
                                : "Select a car type",
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<List<CarsDatum>> getCarAvailable(String id) async {
    String option = widget.type == 'self' ? 'hour' : 'km';
    Map<String, dynamic> data = {
      'category_id': id,
      'lead_id': widget.leadId,
    };
    var res = await HttpService().postApi(
      '/api/v1/self-vehicle/get-available-cab-list',
      data,
    );
    print('api body data $res');
    // print('${widget.type}\n ${widget.location}\n ${widget.pickDate}\n ${widget.pickTime}\n ${widget.dropDate}\n ${widget.dropTime}');
    if (res['status'] == 1 && res['data'] != null) {
      return (res['data'] as List).map((e) => CarsDatum.fromJson(e)).toList();
    }

    return [];
  }

  final Map<String, Future<List<CarsDatum>>> _carFutureMap = {};

  Future<List<CarsDatum>> _getCars(String categoryId) {
    if (!_carFutureMap.containsKey(categoryId)) {
      _carFutureMap[categoryId] = getCarAvailable(categoryId);
    }
    return _carFutureMap[categoryId]!;
  }

  @override
  void initState() {
    super.initState();
    getCategorySelf(widget.categoryType);
  }

  @override
  void dispose() {
    super.dispose();
    _tabController?.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(locale: 'en_IN', symbol: '₹');
    String dayType = widget.type == 'self' ? 'hour' : 'km';
    return categoryList.isEmpty
        ? MahakalLoadingData(onReload: () {})
        : Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              title: Text(
                'Select your cab',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              actions: [
                /// Grid Toggle
                IconButton(
                  onPressed: () {
                    setState(() {
                      isGrid = !isGrid;
                    });
                  },
                  icon: Icon(
                    isGrid ? Icons.grid_view_rounded : Icons.view_list_rounded,
                    color: Colors.black87,
                  ),
                ),

                /// Filter Button (Premium Look)
                widget.type != 'self'
                    ? SizedBox()
                    : GestureDetector(
                        onTap: () {
                          showCarTypeDialog();
                        },
                        child: Container(
                          margin: EdgeInsets.only(right: 12, left: 6),
                          padding:
                              EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Colors.blue, Colors.blue],
                            ),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.blue.withOpacity(0.3),
                                blurRadius: 6,
                                offset: Offset(0, 3),
                              )
                            ],
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.tune, color: Colors.white, size: 18),
                              SizedBox(width: 6),
                              Text(
                                "Filter",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
              ],
            ),
            body: Column(
              children: [
                Container(
                  color: Colors.white,
                  child: TabBar(
                    controller: _tabController,
                    dividerColor: Colors.transparent,
                    isScrollable: true,
                    tabAlignment: TabAlignment.start,
                    indicatorColor: Colors.transparent, // custom selection UI
                    labelPadding: const EdgeInsets.symmetric(horizontal: 12),
                    tabs: List.generate(
                      categoryList.length,
                      (index) {
                        return AnimatedBuilder(
                          animation: _tabController!,
                          builder: (context, _) {
                            final bool selected =
                                _tabController?.index == index;

                            return Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                /// IMAGE CIRCLE
                                AnimatedContainer(
                                  duration: const Duration(milliseconds: 250),
                                  height: 64,
                                  width: 64,
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.grey.shade200,
                                    border: Border.all(
                                      color: selected
                                          ? Colors.blue
                                          : Colors.grey.shade400,
                                      width: selected ? 2 : 1,
                                    ),
                                  ),
                                  child: ClipOval(
                                    child: Image.network(
                                      categoryList[index].image ?? '',
                                      fit: BoxFit.cover,
                                      loadingBuilder:
                                          (context, child, loadingProgress) {
                                        if (loadingProgress == null)
                                          return child;
                                        return const Center(
                                          child: SizedBox(
                                            height: 18,
                                            width: 18,
                                            child: CircularProgressIndicator(
                                                strokeWidth: 2),
                                          ),
                                        );
                                      },
                                      errorBuilder: (_, __, ___) {
                                        return const Icon(
                                          Icons.directions_car,
                                          size: 28,
                                          color: Colors.grey,
                                        );
                                      },
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 6),

                                /// BRAND NAME
                                AnimatedDefaultTextStyle(
                                  duration: const Duration(milliseconds: 250),
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: selected ? 16 : 14,
                                    color: selected
                                        ? Colors.blue
                                        : Colors.black87,
                                  ),
                                  child: SizedBox(
                                    width: 70,
                                    child: Text(
                                      categoryList[index].enBrandName ?? '',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 6),
                              ],
                            );
                          },
                        );
                      },
                    ),
                  ),
                ),
                // Car selection cards
                Expanded(
                  child: TabBarView(controller: _tabController, children: [
                    ...categoryList.map((CarList) {
                      return FutureBuilder<List<CarsDatum>>(
                        future: _getCars(CarList.id.toString()),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                              child: CircularProgressIndicator(
                                  color: Colors.blue),
                            );
                          }

                          if (snapshot.hasError) {
                            return const Center(
                              child: Text('Data Not Available',
                                  style: TextStyle(color: Colors.red)),
                            );
                          }

                          if (!snapshot.hasData || snapshot.data!.isEmpty) {
                            return _noCarAvailableWidget();
                          }

                          final subcategory = snapshot.data!;
                          return ListView.builder(
                            itemCount: subcategory.length,
                            physics: const BouncingScrollPhysics(),
                            shrinkWrap: true,
                            itemBuilder: (context, index) {
                              // DateTime now = DateTime.now();
                              // DateTime nextDate = findNextDate(now, "${itemweekDays}");
                              // String formattedDate = formatDate(nextDate);
                              return Column(
                                children: subcategory.map((car) {
                                  return InkWell(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        CupertinoPageRoute(
                                          builder: (_) => CarSelfDetails(
                                            slug: '${car.slug}',
                                            type: widget.type,
                                            location: widget.location,
                                            totalHour: widget.totalHour ?? 0,
                                            date:
                                                '${widget.pickDate} : ${widget.pickTime}',
                                            leadId: widget.leadId,
                                          ),
                                        ),
                                      );
                                    },
                                    child: isGrid
                                        ? Container(
                                            margin: const EdgeInsets.symmetric(
                                                horizontal: 14, vertical: 6),
                                            padding: const EdgeInsets.all(10),
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black
                                                      .withOpacity(0.06),
                                                  blurRadius: 10,
                                                  offset: const Offset(0, 4),
                                                ),
                                              ],
                                            ),
                                            child: Row(
                                              children: [
                                                /// CAR IMAGE
                                                ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                  child: CachedNetworkImage(
                                                    imageUrl:
                                                        car.thumbnail ?? '',
                                                    height: 70,
                                                    width: 90,
                                                    fit: BoxFit.cover,
                                                    placeholder:
                                                        (context, url) =>
                                                            Container(
                                                      height: 70,
                                                      width: 90,
                                                      alignment:
                                                          Alignment.center,
                                                      child:
                                                          const CircularProgressIndicator(
                                                              strokeWidth: 2),
                                                    ),
                                                    errorWidget: (context, url,
                                                            error) =>
                                                        const Icon(
                                                            Icons
                                                                .directions_car,
                                                            size: 40),
                                                  ),
                                                ),

                                                const SizedBox(width: 12),

                                                /// DETAILS
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      /// NAME
                                                      Text(
                                                        car.enCabName ??
                                                            "Car Name",
                                                        style: const TextStyle(
                                                          fontSize: 16,
                                                          fontWeight:
                                                              FontWeight.w700,
                                                        ),
                                                      ),

                                                      const SizedBox(height: 4),

                                                      /// FEATURES
                                                      Row(
                                                        children: [
                                                          _DetailIcon(
                                                              Icons.settings,
                                                              car.carType ??
                                                                  'Manual',
                                                              Colors.green),
                                                          const SizedBox(
                                                              width: 8),
                                                          _DetailIcon(
                                                              Icons.event_seat,
                                                              '${car.cabSeat ?? 4}',
                                                              Colors
                                                                  .deepOrange),
                                                          const SizedBox(
                                                              width: 8),
                                                          _DetailIcon(
                                                              Icons
                                                                  .local_gas_station,
                                                              car.fuelType ??
                                                                  'Petrol',
                                                              Colors.blue),
                                                        ],
                                                      ),

                                                      const SizedBox(height: 4),

                                                      /// RATING
                                                      Row(
                                                        children: [
                                                          const Icon(Icons.star,
                                                              size: 16,
                                                              color:
                                                                  Colors.amber),
                                                          const Icon(Icons.star,
                                                              size: 16,
                                                              color:
                                                                  Colors.amber),
                                                          const Icon(Icons.star,
                                                              size: 16,
                                                              color:
                                                                  Colors.amber),
                                                          const Icon(Icons.star,
                                                              size: 16,
                                                              color:
                                                                  Colors.amber),
                                                          const Icon(Icons.star,
                                                              size: 16,
                                                              color:
                                                                  Colors.amber),
                                                          const SizedBox(
                                                              width: 3),
                                                          Text(
                                                            '${car.rating ?? 4.5}',
                                                            style: const TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600),
                                                          ),

                                                          Spacer(),

                                                          /// PRICE
                                                          Text(
                                                            '₹${car.basicPrice ?? 0}',
                                                            style:
                                                                const TextStyle(
                                                              fontSize: 16,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              color: Colors
                                                                  .deepOrange,
                                                            ),
                                                          ),
                                                          Text(
                                                            '/$dayType',
                                                            style: TextStyle(
                                                              fontSize: 12,
                                                              color: Colors.grey
                                                                  .shade600,
                                                            ),
                                                          )
                                                        ],
                                                      )
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          )
                                        : Container(
                                            margin: const EdgeInsets.symmetric(
                                                horizontal: 14, vertical: 10),
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black
                                                      .withOpacity(0.08),
                                                  blurRadius: 20,
                                                  offset: const Offset(0, 10),
                                                ),
                                              ],
                                            ),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                /// IMAGE
                                                Stack(
                                                  children: [
                                                    ClipRRect(
                                                      borderRadius:
                                                          const BorderRadius
                                                              .only(
                                                        topLeft:
                                                            Radius.circular(20),
                                                        topRight:
                                                            Radius.circular(20),
                                                      ),
                                                      child: CachedNetworkImage(
                                                        imageUrl:
                                                            car.thumbnail ?? '',
                                                        height: 220,
                                                        width: double.infinity,
                                                        fit: BoxFit.cover,
                                                        placeholder:
                                                            (context, url) =>
                                                                Container(
                                                          height: 220,
                                                          alignment:
                                                              Alignment.center,
                                                          color: Colors
                                                              .grey.shade200,
                                                          child:
                                                              const CircularProgressIndicator(
                                                            strokeWidth: 2,
                                                            color: Colors
                                                                .deepOrange,
                                                          ),
                                                        ),
                                                        errorWidget: (context,
                                                                url, error) =>
                                                            Container(
                                                          height: 220,
                                                          color: Colors
                                                              .grey.shade200,
                                                          child: Icon(
                                                            Icons
                                                                .directions_car_rounded,
                                                            size: 60,
                                                            color: Colors
                                                                .grey.shade400,
                                                          ),
                                                        ),
                                                      ),
                                                    ),

                                                    /// Gradient
                                                    Positioned.fill(
                                                      child: Container(
                                                        decoration:
                                                            BoxDecoration(
                                                          gradient:
                                                              LinearGradient(
                                                            begin: Alignment
                                                                .bottomCenter,
                                                            end: Alignment
                                                                .topCenter,
                                                            colors: [
                                                              Colors.black
                                                                  .withOpacity(
                                                                      0.55),
                                                              Colors
                                                                  .transparent,
                                                              Colors
                                                                  .transparent,
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                    ),

                                                    /// Rating
                                                    Positioned(
                                                      bottom: 14,
                                                      right: 10,
                                                      child: Container(
                                                        padding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                                horizontal: 10,
                                                                vertical: 6),
                                                        decoration:
                                                            BoxDecoration(
                                                          gradient:
                                                              LinearGradient(
                                                            colors: [
                                                              Colors.black
                                                                  .withOpacity(
                                                                      0.75),
                                                              Colors.black
                                                                  .withOpacity(
                                                                      0.55),
                                                            ],
                                                            begin: Alignment
                                                                .topLeft,
                                                            end: Alignment
                                                                .bottomRight,
                                                          ),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(14),
                                                          boxShadow: [
                                                            BoxShadow(
                                                              color: Colors
                                                                  .black
                                                                  .withOpacity(
                                                                      0.25),
                                                              blurRadius: 6,
                                                              offset:
                                                                  const Offset(
                                                                      0, 3),
                                                            ),
                                                          ],
                                                        ),
                                                        child: Row(
                                                          mainAxisSize:
                                                              MainAxisSize.min,
                                                          children: [
                                                            ...List.generate(5,
                                                                (index) {
                                                              return Icon(
                                                                index <
                                                                        car.rating!
                                                                            .round()
                                                                    ? Icons
                                                                        .star_rounded
                                                                    : Icons
                                                                        .star_border_rounded,
                                                                color: Colors
                                                                    .amber,
                                                                size: 16,
                                                              );
                                                            }),
                                                            Text(
                                                              '/${car.rating}',
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .white,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold),
                                                            )
                                                          ],
                                                        ),
                                                      ),
                                                    ),

                                                    Positioned(
                                                      bottom: 10,
                                                      left: 5,
                                                      child: Row(
                                                        children: List.generate(
                                                          car.images!.length,
                                                          (index) {
                                                            return InkWell(
                                                              onTap: () {
                                                                setState(() {
                                                                  selectedImage =
                                                                      car.images![
                                                                          index];
                                                                });
                                                              },
                                                              child: Container(
                                                                margin: EdgeInsets
                                                                    .only(
                                                                        left:
                                                                            5),
                                                                width: 45,
                                                                height: 45,
                                                                decoration:
                                                                    BoxDecoration(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              10),
                                                                  border: Border.all(
                                                                      color: Colors
                                                                          .white60,
                                                                      width:
                                                                          1.5),
                                                                  boxShadow: [
                                                                    BoxShadow(
                                                                      color: Colors
                                                                          .black
                                                                          .withOpacity(
                                                                              0.25),
                                                                      blurRadius:
                                                                          6,
                                                                    ),
                                                                  ],
                                                                ),
                                                                child:
                                                                    ClipRRect(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              8),
                                                                  child: Image
                                                                      .network(
                                                                    car.images![
                                                                        index],
                                                                    fit: BoxFit
                                                                        .cover,
                                                                    errorBuilder: (_,
                                                                            __,
                                                                            ___) =>
                                                                        const Icon(
                                                                            Icons
                                                                                .directions_car,
                                                                            color:
                                                                                Colors.white),
                                                                  ),
                                                                ),
                                                              ),
                                                            );
                                                          },
                                                        ),
                                                      ),
                                                    )
                                                  ],
                                                ),

                                                /// CONTENT
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.fromLTRB(
                                                          16, 14, 16, 18),
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      /// NAME + PRICE
                                                      Row(
                                                        children: [
                                                          Expanded(
                                                            child: Text(
                                                              car.enCabName ??
                                                                  'Car Name',
                                                              maxLines: 1,
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                              style:
                                                                  const TextStyle(
                                                                fontSize: 20,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w800,
                                                              ),
                                                            ),
                                                          ),
                                                          Text(
                                                            '₹${car.basicPrice ?? 0}/$dayType',
                                                            style:
                                                                const TextStyle(
                                                              fontSize: 18,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w800,
                                                              color: Colors
                                                                  .deepOrange,
                                                            ),
                                                          ),
                                                        ],
                                                      ),

                                                      const SizedBox(height: 6),

                                                      /// subtle divider
                                                      Divider(
                                                          color: Colors
                                                              .grey.shade200),

                                                      /// FEATURES (no boxes, clean row)
                                                      Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: [
                                                          _DetailIcon(
                                                              Icons.settings,
                                                              car.carType ??
                                                                  'Manual',
                                                              Colors.green),
                                                          _DetailIcon(
                                                              Icons.event_seat,
                                                              '${car.cabSeat ?? 4} Seats',
                                                              Colors
                                                                  .deepOrangeAccent),
                                                          _DetailIcon(
                                                              Icons
                                                                  .local_gas_station,
                                                              car.fuelType ??
                                                                  'Petrol',
                                                              Colors
                                                                  .deepOrangeAccent),
                                                        ],
                                                      ),

                                                      const SizedBox(
                                                          height: 12),

                                                      /// AC STATUS (soft strip)
                                                      Container(
                                                        padding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                                horizontal: 14,
                                                                vertical: 10),
                                                        decoration:
                                                            BoxDecoration(
                                                          color: car.airConditioning ==
                                                                  1
                                                              ? Colors.blue
                                                                  .withOpacity(
                                                                      0.08)
                                                              : Colors.blue
                                                                  .withOpacity(
                                                                      0.08),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(14),
                                                        ),
                                                        child: Row(
                                                          children: [
                                                            Icon(
                                                              Icons
                                                                  .ac_unit_rounded,
                                                              size: 18,
                                                              color:
                                                                  Colors.blue,
                                                            ),
                                                            const SizedBox(
                                                                width: 8),
                                                            Text(
                                                              'Ac & Non-AC  Both Available',
                                                              style: TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600,
                                                                color:
                                                                    Colors.blue,
                                                              ),
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
                                }).toList(),
                              );
                            },
                          );
                        },
                      );
                    }),
                  ]),
                ),
              ],
            ),
          );
  }

  Widget _noCarAvailableWidget() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              /// ICON
              Container(
                height: 90,
                width: 90,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.blue.withOpacity(0.12),
                ),
                child: const Icon(
                  Icons.directions_car_outlined,
                  size: 48,
                  color: Colors.blue,
                ),
              ),

              const SizedBox(height: 18),

              /// TITLE
              const Text(
                'No Cars Available',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              /// MESSAGE
              const Text(
                'Sorry! There are no cars available for your selected location and time.\nPlease try again later or change your booking details.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.black54,
                  height: 1.4,
                ),
              ),

              const SizedBox(height: 20),

              /// CONFIRM BUTTON
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 12,
                  ),
                ),
                onPressed: () {
                  // optional: refresh / go back
                },
                child: const Text(
                  'OK, Got it',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _DetailIcon(IconData icon, String text, Color color) {
    return Row(
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey.shade700,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class Category {
  final int id;
  final String enBrandName;
  final String hiBrandName;
  final String image;

  Category({
    required this.id,
    required this.enBrandName,
    required this.hiBrandName,
    required this.image,
  });

  // Factory constructor to create Category from JSON
  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] ?? 0,
      enBrandName: json['en_brand_name'] ?? '',
      hiBrandName: json['hi_brand_name'] ?? '',
      image: json['image'] ?? '',
    );
  }

  // Convert Category to JSON if needed
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'en_brand_name': enBrandName,
      'hi_brand_name': hiBrandName,
      'image': image,
    };
  }
}
