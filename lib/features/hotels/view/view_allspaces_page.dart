import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mahakal/features/hotels/view/spcae_details_page.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import '../controller/view_allspace_controller.dart';
import '../model/spaces_list_model.dart';

class AllSpacesScreen extends StatefulWidget {

  final int? locationId;
  final int? adults;
  final int? children;
  final int? rooms;
  final DateTime? checkInDate;
  final DateTime? checkOutDate;
  final ScrollController? scrollController;


  const AllSpacesScreen({
    super.key,
    this.locationId,
    this.adults,
    this.children,
    this.rooms,
    this.checkInDate,
    this.checkOutDate,
    this.scrollController,
  });

  @override
  _AllSpacesScreenState createState() => _AllSpacesScreenState();
}

class _AllSpacesScreenState extends State<AllSpacesScreen> with SingleTickerProviderStateMixin {

  late ScrollController _scrollController;
  late AnimationController _filterController;
  late Animation<Offset> _filterAnimation;
  bool _isFilterOpen = false;
  bool _isGridView = true;

  @override
  void initState() {
    super.initState();

    _scrollController = widget.scrollController ?? ScrollController();

    // Add scroll listener for pagination
    _scrollController.addListener(_onScroll);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final controller = context.read<ViewAllSpaceController>();

      print("🚀 Initializing Space fetch...");
      controller.fetchAllSpaces(
        locationId: widget.locationId,
        checkInDate: widget.checkInDate,
        checkOutDate: widget.checkOutDate,
        rooms: widget.rooms,
        adults: widget.adults,
        children: widget.children,
        loadMore: false,
      );
    });

    _filterController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );

    _filterAnimation = Tween<Offset>(
      begin: Offset(-1, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _filterController,
      curve: Curves.easeInOut,
    ));
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      final controller = context.read<ViewAllSpaceController>();

      if (!controller.isFetchingMore && !controller.isLoading) {
        controller.fetchAllSpaces(
          locationId: widget.locationId,
          checkInDate: widget.checkInDate,
          checkOutDate: widget.checkOutDate,
          rooms: widget.rooms,
          adults: widget.adults,
          children: widget.children,
          loadMore: true, // ✅ IMPORTANT
        );
      }
    }
  }

  @override
  void dispose() {
    if (widget.scrollController == null) {
      _scrollController.dispose();
    } else {
      _scrollController.removeListener(_onScroll);
    }
    _filterController.dispose();
    super.dispose();
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

  void _toggleFilter() {
    setState(() {
      _isFilterOpen = !_isFilterOpen;
      if (_isFilterOpen) {
        _filterController.forward();
      } else {
        _filterController.reverse();
      }
    });
  }

  Widget _buildFilterSection() {
    return Consumer<ViewAllSpaceController>(
      builder: (context, controller, _) {

        if (controller.filters == null) {
          return const SizedBox();
        }

        return SlideTransition(
          position: _filterAnimation,
          child: Container(
            width: 320,
            color: Colors.white,
            child: Column(
              children: [

                /// ================= HEADER =================
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: Colors.grey.shade200),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Filters',
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold),
                      ),
                      Row(
                        children: [
                          if (controller.selectedLocations.isNotEmpty ||
                              controller.selectedStars.isNotEmpty ||
                              controller.selectedTerms.isNotEmpty ||
                              controller.priceRange.start != controller.minPrice ||
                              controller.priceRange.end != controller.maxPrice)
                            TextButton(
                              onPressed: controller.clearFilters,
                              child: const Text(
                                'Clear All',
                                style: TextStyle(color: Colors.red),
                              ),
                            ),
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: _toggleFilter,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                /// ================= BODY =================
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        /// ---------- PRICE RANGE ----------
                        _buildFilterSectionTitle('Price Range'),
                        const SizedBox(height: 16),

                        if (controller.minPrice != 0 ||
                            controller.maxPrice != 0)
                          Column(
                            children: [
                              RangeSlider(
                                min: controller.minPrice,
                                max: controller.maxPrice,
                                values: controller.priceRange,
                                activeColor: Colors.blue,
                                labels: RangeLabels(
                                  '₹${controller.priceRange.start.toInt()}',
                                  '₹${controller.priceRange.end.toInt()}',
                                ),
                                onChanged:
                                controller.updatePriceRange,
                              ),
                              Row(
                                mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '₹${controller.priceRange.start.toInt()}',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        color: Colors.blue),
                                  ),
                                  Text(
                                    '₹${controller.priceRange.end.toInt()}',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        color: Colors.blue),
                                  ),
                                ],
                              ),
                            ],
                          ),

                        const SizedBox(height: 24),

                        /// ---------- HOTEL STAR ----------
                        _buildFilterSectionTitle('Hotel Star'),
                        const SizedBox(height: 12),

                        Column(
                          children: List.generate(5, (index) {
                            final star = index + 1;
                            final isSelected =
                            controller.selectedStars.contains(star);

                            return CheckboxListTile(
                              contentPadding: EdgeInsets.zero,
                              value: isSelected,
                              activeColor: Colors.blue,
                              onChanged: (_) {
                                if (isSelected) {
                                  controller.selectedStars.remove(star);
                                } else {
                                  controller.selectedStars.add(star);
                                }
                                controller.applyFilters();
                              },
                              title: Row(
                                children: List.generate(
                                  star,
                                      (i) => const Icon(
                                    Icons.star,
                                    color: Colors.blue,
                                    size: 20,
                                  ),
                                ),
                              ),
                            );
                          }),
                        ),

                        const SizedBox(height: 24),

                        /// ---------- LOCATIONS ----------
                        _buildFilterSectionTitle('Locations'),
                        const SizedBox(height: 12),

                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: controller.filters!.locations!
                              .map((loc) {
                            final selected = controller
                                .selectedLocations
                                .contains(loc.name);

                            return FilterChip(
                              label: Text(loc.name ?? ''),
                              selected: selected,
                              selectedColor: Colors.blue,
                              onSelected: (_) {
                                if (selected) {
                                  controller.selectedLocations
                                      .remove(loc.name);
                                } else {
                                  controller.selectedLocations
                                      .add(loc.name!);
                                }
                                controller.applyFilters();
                              },
                            );
                          }).toList(),
                        ),

                        const SizedBox(height: 24),

                        /// ---------- ATTRIBUTES ----------
                        ...controller.filters!.attributes!
                            .where((attr) =>
                        attr.name?.toLowerCase() !=
                            'property type')
                            .map((attr) {
                          return Column(
                            crossAxisAlignment:
                            CrossAxisAlignment.start,
                            children: [
                              _buildFilterSectionTitle(attr.name!),
                              const SizedBox(height: 12),

                              if (attr.name == 'Facilities')
                                GridView.builder(
                                  shrinkWrap: true,
                                  physics:
                                  const NeverScrollableScrollPhysics(),
                                  gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 3,
                                    mainAxisSpacing: 8,
                                    crossAxisSpacing: 8,
                                    childAspectRatio: 1.2,
                                  ),
                                  itemCount: attr.terms!.length,
                                  itemBuilder: (context, index) {
                                    final term =
                                    attr.terms![index];
                                    final selected =
                                    controller.selectedTerms
                                        .contains(term.name);

                                    return GestureDetector(
                                      onTap: () {
                                        if (selected) {
                                          controller.selectedTerms
                                              .remove(term.name);
                                        } else {
                                          controller.selectedTerms
                                              .add(term.name!);
                                        }
                                        controller.applyFilters();
                                      },
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: selected
                                              ? Colors.blue
                                              .withOpacity(0.2)
                                              : Colors.grey
                                              .shade100,
                                          borderRadius:
                                          BorderRadius.circular(
                                              12),
                                          border: Border.all(
                                            color: selected
                                                ? Colors.blue
                                                : Colors
                                                .transparent,
                                          ),
                                        ),
                                        child: Column(
                                          mainAxisAlignment:
                                          MainAxisAlignment
                                              .center,
                                          children: [
                                            Icon(
                                              _getIconData(
                                                  term.icon),
                                              color: selected
                                                  ? Colors.blue
                                                  : Colors.grey
                                                  .shade600,
                                            ),
                                            const SizedBox(
                                                height: 8),
                                            Text(
                                              term.name ?? '',
                                              textAlign:
                                              TextAlign.center,
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontWeight:
                                                selected
                                                    ? FontWeight
                                                    .w600
                                                    : FontWeight
                                                    .normal,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                )
                              else
                                ...attr.terms!.map((term) {
                                  final selected =
                                  controller.selectedTerms
                                      .contains(term.name);

                                  return CheckboxListTile(
                                    title:
                                    Text(term.name ?? ''),
                                    subtitle: Text(
                                        '${term.spaceCount} Spaces'),
                                    value: selected,
                                    activeColor: Colors.blue,
                                    onChanged: (_) {
                                      if (selected) {
                                        controller.selectedTerms
                                            .remove(term.name);
                                      } else {
                                        controller.selectedTerms
                                            .add(term.name!);
                                      }
                                      controller.applyFilters();
                                    },
                                  );
                                }).toList(),

                              const SizedBox(height: 24),
                            ],
                          );
                        }).toList(),

                        const SizedBox(height: 80),
                      ],
                    ),
                  ),
                ),

                /// ================= APPLY BUTTON =================
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border(
                        top: BorderSide(
                            color: Colors.grey.shade200)),
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        controller.applyFilters();
                        _toggleFilter();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        padding: const EdgeInsets.symmetric(
                            vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                          BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Apply Filters',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFilterSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    );
  }

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'icofont-wall-clock':
        return Icons.access_time;
      case 'icofont-car-alt-3':
        return Icons.directions_car;
      case 'icofont-bicycle-alt-2':
        return Icons.directions_bike;
      case 'icofont-imac':
        return Icons.tv;
      case 'icofont-recycle-alt':
        return Icons.local_laundry_service;
      case 'icofont-wifi-alt':
        return Icons.wifi;
      case 'icofont-tea':
        return Icons.coffee;
      default:
        return Icons.check_circle;
    }
  }

  Widget _buildSpaceCard(Space space) {
    return InkWell(
      onTap: (){
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SpcaeDetailsPage(
              spacelId: space.id,
            ),
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                  child: Image.network(
                    space.image,
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.fill,
                  ),
                ),
              ],
            ),

            Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          space.title,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.green[50],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.star, size: 16, color: Colors.blue),
                            SizedBox(width: 4),
                            Text(
                              space.reviewScore.toString(),
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Colors.green,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 8),

                  Row(
                    children: [
                      Icon(Icons.location_on, size: 16, color: Colors.grey),
                      SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          space.address,
                          style: TextStyle(color: Colors.grey),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),

                  // SizedBox(height: 12),
                  //
                  // Wrap(
                  //   spacing: 8,
                  //   runSpacing: 8,
                  //   children: [
                  //     _buildHotelFeature('WiFi'),
                  //     _buildHotelFeature('Pool'),
                  //     _buildHotelFeature('Parking'),
                  //     _buildHotelFeature('Breakfast'),
                  //   ],
                  // ),

                  SizedBox(height: 12),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // if (hotel.discount != null)
                          //   Text(
                          //     '\$${hotel.price * 1.2}',
                          //     style: TextStyle(
                          //       color: Colors.grey,
                          //       decoration: TextDecoration.lineThrough,
                          //     ),
                          //   ),
                          Text.rich(
                            TextSpan(
                              children: [
                                TextSpan(
                                  text: formatIndianCurrency("${space.price}"),
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue,
                                  ),
                                ),
                                TextSpan(
                                  text: ' / night',
                                  style: TextStyle(
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      ElevatedButton(
                        onPressed: () {
                          // Book hotel
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SpcaeDetailsPage(
                                spacelId: space.id,
                              ),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text('Book Now',style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHotelShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        margin: EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(height: 20, width: 200, color: Colors.white),
                  SizedBox(height: 8),
                  Container(height: 16, width: 150, color: Colors.white),
                  SizedBox(height: 12),
                  Row(
                    children: [
                      Container(height: 20, width: 50, color: Colors.white),
                      SizedBox(width: 8),
                      Container(height: 20, width: 50, color: Colors.white),
                      SizedBox(width: 8),
                      Container(height: 20, width: 50, color: Colors.white),
                    ],
                  ),
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(height: 24, width: 100, color: Colors.white),
                      Container(height: 40, width: 100, color: Colors.white),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Grid Card Widget
  Widget _buildSpaceGridCard(Space space) {
    return InkWell(
      onTap: (){
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SpcaeDetailsPage(
              spacelId: space.id,
            ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 12,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Section
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                  child: Image.network(
                    space.image,
                    height: 100,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),

                // Favorite Button
                // Positioned(
                //   top: 8,
                //   right: 8,
                //   child: Container(
                //     width: 32,
                //     height: 32,
                //     decoration: BoxDecoration(
                //       color: Colors.white,
                //       shape: BoxShape.circle,
                //       boxShadow: [
                //         BoxShadow(
                //           color: Colors.black.withOpacity(0.1),
                //           blurRadius: 4,
                //         ),
                //       ],
                //     ),
                //     child: Center(
                //       child: Icon(
                //         Icons.favorite_border,
                //         color: Colors.red,
                //         size: 18,
                //       ),
                //     ),
                //   ),
                // ),

                // Star Rating Badge
                Positioned(
                  bottom: 8,
                  left: 8,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 2,
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.star,
                          color: Colors.blue,
                          size: 12,
                        ),
                        SizedBox(width: 2),
                        Text(
                          space.reviewScore.toString(),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // Content Section
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Hotel Name
                    Text(
                      space.title,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        height: 1.3,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),

                    SizedBox(height: 5),

                    // Location
                    Row(
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          size: 12,
                          color: Colors.grey,
                        ),
                        SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            space.address,
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey[600],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 6),

                    // Price & Button
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        // Price
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              formatIndianCurrency("${space.price}"),
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                              ),
                            ),
                            Text(
                              '/night',
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),

                        // Book Button
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: Colors.blue,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: Icon(
                              Icons.arrow_forward,
                              color: Colors.white,
                              size: 16,
                            ),
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
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 20),
          Text(
            'No Spaces Found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your filters or check back later',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

// Grid Shimmer Widget
  Widget _buildSpaceGridShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 140,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(height: 16, width: 100, color: Colors.white),
                  SizedBox(height: 8),
                  Container(height: 12, width: 80, color: Colors.white),
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(height: 20, width: 60, color: Colors.white),
                      Container(height: 32, width: 32, color: Colors.white),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 1,
      leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          }
      ),
      actions: [
        // Single Toggle Button
        Padding(
          padding: EdgeInsets.only(right: 16),
          child: GestureDetector(
            onTap: () {
              setState(() {
                _isGridView = !_isGridView;
              });
            },
            child: AnimatedContainer(
              duration: Duration(milliseconds: 300),
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(23),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.withOpacity(0.3),
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Center(
                child: AnimatedSwitcher(
                  duration: Duration(milliseconds: 300),
                  transitionBuilder: (child, animation) {
                    return ScaleTransition(
                      scale: animation,
                      child: child,
                    );
                  },
                  child: _isGridView
                      ? Icon(
                    Icons.view_list,
                    key: ValueKey('list'),
                    color: Colors.white,
                    size: 24,
                  )
                      : Icon(
                    Icons.grid_view,
                    key: ValueKey('grid'),
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
      title: Consumer<ViewAllSpaceController>(
        builder: (context, controller, child) {
          return Column(
            children: [
              Text(
                'All Spaces',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
              // if (controller. != null && !controller.isLoading)
              //   Text(
              //     '${controller.filteredHotels.length} of ${controller.pagination!.total} hotels',
              //     style: const TextStyle(
              //       fontSize: 12,
              //       fontWeight: FontWeight.normal,
              //     ),
              //   ),
            ],
          );
        },
      ),
      bottom: PreferredSize(
        preferredSize: Size.fromHeight(60),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Consumer<ViewAllSpaceController>(
                    builder: (context, controller, child) {
                      // Use a key to maintain controller instance
                      return _SearchTextField(controller: controller);
                    },
                  ),
                ),
              ),
              SizedBox(width: 12),
              Consumer<ViewAllSpaceController>(
                builder: (context, controller, child) {
                  final hasActiveFilters =
                      controller.selectedLocations.isNotEmpty ||
                          controller.selectedTerms.isNotEmpty ||
                          controller.priceRange.start > controller.minPrice ||
                          controller.priceRange.end < controller.maxPrice;

                  return AnimatedContainer(
                    duration: Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    height: 44,
                    width: 44,
                    decoration: BoxDecoration(
                      color: _isFilterOpen || hasActiveFilters
                          ? Colors.white
                          : Colors.blue,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        if (!_isFilterOpen && !hasActiveFilters)
                          BoxShadow(
                            color: Colors.blue.withOpacity(0.4),
                            blurRadius: 8,
                            offset: Offset(0, 3),
                          ),
                      ],
                      border: Border.all(
                        color: Colors.blue,
                        width: 2,
                      ),
                    ),
                    child: Stack(
                      children: [
                        InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: _toggleFilter,
                          child: Center(
                            child: Icon(
                              Icons.filter_list,
                              color: _isFilterOpen || hasActiveFilters
                                  ? Colors.blue
                                  : Colors.white,
                            ),
                          ),
                        ),
                        if (hasActiveFilters)
                          Positioned(
                            top: 4,
                            right: 4,
                            child: Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                      ],
                    ),
                  );
                },
              )
            ],
          ),
        ),
      ),
    );
  }

  // Load More Indicator for List View
  Widget _buildLoadMoreIndicator(bool isLoadingMore) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Center(
        child: Column(
          children: [
            if (isLoadingMore)
              const CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
              )
            else
              const Text('Load More Spaces'),

            const SizedBox(height: 10),
            Text(
              isLoadingMore ? 'Loading more space...' : 'Tap to load more',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _refreshSpaces() async {
    await context.read<ViewAllSpaceController>().fetchAllSpaces(
      locationId: widget.locationId,
      checkInDate: widget.checkInDate,
      checkOutDate: widget.checkOutDate,
      rooms: widget.rooms,
      adults: widget.adults,
      children: widget.children,
      loadMore: false, // 🔥 reset pagination
    );
  }

  Widget _buildContent(ViewAllSpaceController controller) {
    if (_isGridView) {
      // Grid View with pagination
      return GridView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 0.75,
        ),
        itemCount: controller.filteredSpaces.length +
            (controller.isFetchingMore ? 1 : 0) + // Add 1 for loading indicator
            (controller.isLoading ? 6 : 0), // Initial loading shimmer
        itemBuilder: (context, index) {
          if (controller.isLoading) {
            return _buildSpaceGridShimmer();
          }

          // Show loading indicator at the end
          if (index >= controller.filteredSpaces.length) {
            if (controller.isFetchingMore) {
              return _buildLoadMoreIndicator(controller.isFetchingMore);
            }
            return Container(); // Empty container for safety
          }

          final hotel = controller.filteredSpaces[index];
          return _buildSpaceGridCard(hotel);
        },
      );
    } else {
      // List View with pagination
      return ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(16),
        itemCount: controller.filteredSpaces.length +
            (controller.isFetchingMore ? 1 : 0) + // Add 1 for loading indicator
            (controller.isLoading ? 6 : 0), // Initial loading shimmer
        itemBuilder: (context, index) {
          if (controller.isLoading) {
            return _buildHotelShimmer();
          }

          // Show loading indicator at the end
          if (index >= controller.filteredSpaces.length) {
            if (controller.isFetchingMore) {
              return _buildLoadMoreIndicator(controller.isFetchingMore);
            }
            return Container(); // Empty container for safety
          }

          final hotel = controller.filteredSpaces[index];
          return _buildSpaceCard(hotel);
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: buildAppBar(),
      body: Stack(
        children: [

          Consumer<ViewAllSpaceController>(
            builder: (context, controller, child) {

              // ADD DEBUG PRINT
              print("🎯 UI State:");
              print("   - isLoading: ${controller.isLoading}");
              print("   - filteredSpaces length: ${controller.filteredSpaces.length}");
              print("   - AllSpace length: ${controller.allSpaces.length}");

              final isEmpty = !controller.isLoading && controller.filteredSpaces.isEmpty;

              if (isEmpty) {
                // Show empty state widget covering entire screen
                return _buildEmptyState();
              }

              // Use RefreshIndicator for pull-to-refresh
              return RefreshIndicator(
                color: Colors.blue,
                onRefresh: _refreshSpaces,
                child: _buildContent(controller),
              );
            },
          ),

          // Filter Overlay
          if (_isFilterOpen)
            Container(
              color: Colors.black.withOpacity(0.3),
            ),

          // Filter Panel
          Positioned.fill(
            child: Row(
              children: [
                if(_isFilterOpen)
                  _buildFilterSection(),
                if (_isFilterOpen)
                  Expanded(
                    child: GestureDetector(
                      onTap: _toggleFilter,
                      child: Container(
                        color: Colors.transparent,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          if (_isFilterOpen)
            Container(
              color: Colors.black.withOpacity(0.3),
            ),

          // Filter Panel
          Positioned.fill(
            child: Row(
              children: [
                if(_isFilterOpen)
                  _buildFilterSection(),
                if (_isFilterOpen)
                  Expanded(
                    child: GestureDetector(
                      onTap: _toggleFilter,
                      child: Container(
                        color: Colors.transparent,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchTextField extends StatefulWidget {
  final ViewAllSpaceController controller;

  const _SearchTextField({required this.controller});

  @override
  State<_SearchTextField> createState() => __SearchTextFieldState();
}

class __SearchTextFieldState extends State<_SearchTextField> {
  late TextEditingController _textController;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(text: widget.controller.searchQuery);
  }

  @override
  void didUpdateWidget(_SearchTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Sync text when controller's searchQuery changes from outside
    if (_textController.text != widget.controller.searchQuery) {
      _textController.text = widget.controller.searchQuery;
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _textController,
      onChanged: (value) {
        widget.controller.searchHotels(value);
      },
      style: TextStyle(
        color: Colors.black87,
        fontSize: 16,
        fontWeight: FontWeight.w500,
      ),
      showCursor: false,
      decoration: InputDecoration(
        hintText: 'Search spaces, locations...',
        hintStyle: TextStyle(
          color: Colors.grey[600],
          fontSize: 15,
          fontWeight: FontWeight.w400,
        ),
        border: InputBorder.none,
        prefixIcon: Container(
          padding: EdgeInsets.only(left: 16, right: 12),
          child: Icon(
            Icons.search_rounded,
            color: Color(0xFFF97316), // Orange icon
            size: 24,
          ),
        ),
        suffixIcon: widget.controller.searchQuery.isNotEmpty
            ? Container(
          padding: EdgeInsets.only(right: 8),
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(20),
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () {
                _textController.clear();
                widget.controller.clearSearch();
              },
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.close_rounded,
                  color: Colors.grey[700],
                  size: 20,
                ),
              ),
            ),
          ),
        )
            : null,
        filled: true,
        fillColor: Colors.white,
        contentPadding: EdgeInsets.symmetric(vertical: 16),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
            color: Colors.grey[300]!,
            width: 1.5,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
            color: Color(0xFFF97316), // Orange border on focus
            width: 2.0,
          ),
        ),
        // Add shadow effect
        floatingLabelBehavior: FloatingLabelBehavior.never,
      ),
    );
  }
}