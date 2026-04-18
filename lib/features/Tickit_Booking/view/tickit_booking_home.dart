import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:mahakal/features/Tickit_Booking/view/tickit_booking_details.dart';
import 'package:mahakal/features/blogs_module/no_image_widget.dart';
import 'package:mahakal/features/donation/view/home_page/Donation_Home/donation_home_view.dart';
import 'package:mahakal/features/event_booking/view/home_page/event_home.dart';
import 'package:mahakal/features/youtube_vedios/view/dynamic_tabview/grid_view/YoutubeGridView.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import '../../hotels/view/hotel_bottom_bar.dart';
import '../../tour_and_travells/view/main_home_tour.dart';
import '../controller/activities_category_controller.dart';
import '../controller/activities_list_controller.dart';
import '../controller/activities_location_controller.dart';
import '../model/activities_category_model.dart';
import '../model/activities_list_model.dart';

class TickitBookingHome extends StatefulWidget {
  const TickitBookingHome({super.key});

  @override
  State<TickitBookingHome> createState() => _TickitBookingHomeState();
}

class _TickitBookingHomeState extends State<TickitBookingHome> {
  final ScrollController _scrollController = ScrollController();

  bool _initialDataLoaded = false; // Add this flag
  bool isGridView = false;
  bool isEnglish = true;
  int selectedCategory = 0; //
  String selectedCity = ''; //

  // Filtered cities based on search
  List<String> filteredCities = [];

  @override
  void initState() {
    super.initState();

    // Initialize with default values
    selectedCategory = 0;
    selectedCity = '';

    // Fetch data when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ActivitiesLocationController>().getActivitiesLocationList();
      context.read<ActivitiesCategoryController>().getActivitiesCategory();

      // Reset to default on init
      _resetToDefault();
    });

    // Add scroll listener for pagination
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      // Load more when reaching bottom
      _loadMoreActivities();
    }
  }

  void onNavigate(BuildContext context, String type) {
    switch (type) {
      case 'hotel':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => HotelBottomBar(pageIndex: 0,)),
        );
        break;

      case 'tour':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => TourHomePage()),
        );
        break;

      case 'donate':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => DonationHomeView()),
        );
        break;

      case 'event':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => EventHome()),
        );
        break;
      //
      // case 'mandir':
      //   Navigator.push(
      //     context,
      //     MaterialPageRoute(builder: (context) => Mandir()),
      //   );
      //   break;

      default:
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid navigation type')),
        );
    }
  }

  Future<void> _loadMoreActivities() async {
    await context.read<ActivitiesListController>().loadMoreActivities();
  }

  Future<void> _refreshActivities() async {
    await context.read<ActivitiesListController>().refreshActivities();
  }

  void _showCitySelectionBottomSheet() {
    final cities = context
        .read<ActivitiesLocationController>()
        .activitiesLocationListModel
        ?.data ??
        [];

    filteredCities = List<String>.from(cities); // initialize properly

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return _buildCitySelectionSheet(setSheetState);
          },
        );
      },
    );
  }

  Widget _buildCitySelectionSheet(void Function(void Function()) setSheetState) {
    return Consumer<ActivitiesLocationController>(
      builder: (BuildContext context, locationController, child) {
        final isLoading = locationController.isLoading;
        final cities = locationController.activitiesLocationListModel?.data ?? [];

        if (isLoading) {
          return _buildCitiesShimmer();
        }

        return Container(
          height: MediaQuery.of(context).size.height * 0.75,
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const SizedBox(height: 10),

              const Text(
                'Select City',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepOrange,
                ),
              ),
              const SizedBox(height: 20),

              ///  Search Field
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.grey),
                ),
                child: TextField(
                  onChanged: (value) {
                    setSheetState(() {
                      if (value.isEmpty) {
                        filteredCities = List<String>.from(cities);
                      } else {
                        filteredCities = cities
                            .where((city) => city
                            .toLowerCase()
                            .contains(value.toLowerCase()))
                            .toList();
                      }
                    });
                  },
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Search City...',
                    prefixIcon: const Icon(Icons.search, color: Colors.deepOrange),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        setSheetState(() {
                          filteredCities = List<String>.from(cities);
                        });
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 25),

              ///  Grid
              Expanded(
                child: GridView.builder(
                  gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    crossAxisSpacing: 15,
                    mainAxisSpacing: 15,
                    childAspectRatio: 0.9,
                  ),
                  itemCount: filteredCities.length + 1, // +1 for All Cities
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return _buildCityGridItem(
                        '',
                        setSheetState,
                        isAll: true,
                      );
                    }

                    final city = filteredCities[index - 1];

                    return _buildCityGridItem(
                      city,
                      setSheetState,
                    );
                  },
                ),
              ),

              ///  Close Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepOrange,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: const Text("Close"),
                ),
              )
            ],
          ),
        );
      },
    );
  }

  Widget _buildCityGridItem(
      String city,
      void Function(void Function()) setSheetState, {
        bool isAll = false,
      }) {
    return GestureDetector(
      onTap: () {
        _debugFilters();
        final controller = context.read<ActivitiesListController>();

        // FIX: Send null for All Cities instead of empty string
        controller.applyFilters(
          city: isAll ? null : city, // Change this line
          categoryIds: selectedCategory > 0
              ? [
            context
                .read<ActivitiesCategoryController>()
                .activitiesCategoryList[selectedCategory - 1]
                .id
                .toString()
          ]
              : [],
        );

        setState(() {
          selectedCity = isAll ? '' : city;
        });
        print("City Selection: isAll=$isAll, city=$city, sending to API: ${isAll ? 'null' : city}");
        Navigator.pop(context);
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: (selectedCity == city) ||
                (isAll && selectedCity.isEmpty)
                ? Colors.deepOrange
                : Colors.grey,
            width: (selectedCity == city) ||
                (isAll && selectedCity.isEmpty)
                ? 2
                : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: isAll
                    ? Colors.grey[100]
                    : Colors.orange.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isAll ? Icons.public : Icons.location_city,
                size: 28,
                color: isAll ? Colors.grey : Colors.deepOrange,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              isAll ? "All Cities" : city,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: (selectedCity == city) ||
                    (isAll && selectedCity.isEmpty)
                    ? Colors.deepOrange
                    : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCitiesShimmer() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Center(
            child: Container(
              width: 120,
              height: 24,
              color: Colors.grey[300],
            ),
          ),
          const SizedBox(height: 20),
          Container(
            height: 50,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(15),
            ),
          ),
          const SizedBox(height: 25),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                crossAxisSpacing: 15,
                mainAxisSpacing: 15,
                childAspectRatio: 0.9,
              ),
              itemCount: 12,
              itemBuilder: (context, index) {
                return Shimmer.fromColors(
                  baseColor: Colors.grey[300]!,
                  highlightColor: Colors.grey[100]!,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Container(
                          width: 60,
                          height: 12,
                          color: Colors.white,
                        ),
                      ],
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

  // Apply category filter
  void _applyCategoryFilter(int? categoryId) {
    final controller = context.read<ActivitiesListController>();

    setState(() {
      selectedCategory = categoryId ?? 0;
    });

    if (categoryId == null || categoryId == 0) {
      // All categories selected
      controller.applyFilters(
        categoryIds: [],
        city: selectedCity.isNotEmpty ? selectedCity : null,
      );
    } else {
      final categories = context.read<ActivitiesCategoryController>().activitiesCategoryList;

      if (categoryId <= categories.length) {
        final category = categories[categoryId - 1];

        controller.applyFilters(
          categoryIds: [category.id.toString()],
          city: selectedCity.isNotEmpty ? selectedCity : null,
        );
      }
    }

    print("Applied category filter: categoryId=$categoryId, city='$selectedCity'");
  }

  void _resetToDefault() {
    final controller = context.read<ActivitiesListController>();

    // Clear all filters
    controller.applyFilters(
      city: null,
      categoryIds: [],
    );

    setState(() {
      selectedCategory = 0;
      selectedCity = '';
    });

    print("Reset to default: All Cities, All Categories");
  }

  void _debugFilters() {
    final controller = context.read<ActivitiesListController>();
    print("""
    Current Filters:
    - Selected City: '$selectedCity'
    - Selected Category Index: $selectedCategory
    - Controller City: '${controller.selectedCity}'
    - Controller Categories: ${controller.selectedCategoryIds}
  """);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      floatingActionButton: FloatingActionButton(
        onPressed: _showCitySelectionBottomSheet,
        backgroundColor: Colors.deepOrange,
        elevation: 6,
        child: const Icon(
          Icons.location_city,
          color: Colors.white,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
        ),
        title: GestureDetector(
          onTap: _showCitySelectionBottomSheet,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text(
                    'Around You',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.white),
                ],
              ),
              const SizedBox(height: 2),
              Consumer<ActivitiesListController>(
                builder: (context, controller, child) {
                  return Text(
                    selectedCity.isEmpty ? 'All Cities' : selectedCity,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.white70,
                    ),
                  );
                },
              ),
            ],
          ),
        ),
        actions: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: IconButton(
              icon: Icon(
                isEnglish ? Icons.language : Icons.translate_sharp,
                color: Colors.deepOrange,
              ),
              onPressed: () {
                setState(() {
                  isEnglish = !isEnglish;
                });
              },
            ),
          ),
          const SizedBox(width: 10),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: IconButton(
              icon: Icon(
                isGridView ? Icons.list : Icons.grid_view,
                color: Colors.deepOrange,
              ),
              onPressed: () {
                setState(() {
                  isGridView = !isGridView;
                });
              },
            ),
          ),
          const SizedBox(width: 12),
        ],
        elevation: 0,
        backgroundColor: Colors.deepOrange,
      ),
      body: Consumer<ActivitiesListController>(
        builder: (context, activitiesController, child) {

          // Ensure default filters are applied on first load
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!_initialDataLoaded) {
              activitiesController.applyFilters(
                city: null,
                categoryIds: [],
              );
              _initialDataLoaded = true;
            }
          });

          final activities = activitiesController.allActivities;
          final isLoading = activitiesController.isLoading;
          final isLoadingMore = activitiesController.isLoadingMore;
          final hasMorePages = activitiesController.hasMorePages;

          return RefreshIndicator(
            color: Colors.orange,
            onRefresh: _refreshActivities,
            child: CustomScrollView(
              controller: _scrollController,
              slivers: [
                // Explore by Category Section
                // SliverToBoxAdapter(
                //   child: Container(
                //     margin: const EdgeInsets.only(top: 8, bottom: 16),
                //     color: Colors.white,
                //     child: Column(
                //       crossAxisAlignment: CrossAxisAlignment.start,
                //        children: [
                //          const SizedBox(height: 16),
                //         SizedBox(
                //           height: 90,
                //           child: ListView.builder(
                //             scrollDirection: Axis.horizontal,
                //             padding: const EdgeInsets.only(left: 10),
                //             itemCount: 5,
                //             itemBuilder: (context, index) {
                //               final categories = [
                //                 _buildCategoryItem(Icons.car_crash_sharp, 'Tour', const Color(0xFFF72585),"tour"),
                //                 _buildCategoryItem(Icons.hotel_outlined, 'Hotels', const Color(0xFF06D6A0),"hotel"),
                //                 _buildCategoryItem(Icons.beach_access_outlined, 'Donation', const Color(0xFF4CC9F0),"donate"),
                //                 _buildCategoryItem(Icons.event, 'Event', const Color(0xFF7209B7),"event"),
                //                 _buildCategoryItem(Icons.temple_hindu, 'Mandir Darshan', const Color(0xFFF8961E),"mandir"),
                //                 _buildCategoryItem(Icons.terrain_outlined, 'Mountain', const Color(0xFF38B000),""),
                //               ];
                //               return categories[index];
                //             },
                //           ),
                //         ),
                //       ],
                //     ),
                //   ),
                // ),

                // Sticky Category Filter Header
                SliverPersistentHeader(
                  pinned: true,
                  delegate: _StickyHeaderDelegate(
                    minHeight: 100,
                    maxHeight:100,
                    child: _buildCategoryHeader(),
                  ),
                ),

                // Content Grid/List
                if (isLoading && activities.isEmpty)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(6),
                      child: _buildLoadMoreIndicator()
                    ),
                  )
                else if (activities.isEmpty)
                  SliverToBoxAdapter(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(40),
                        child: Column(
                          children: [
                            Icon(
                              Icons.search_off,
                              size: 80,
                              color: Colors.grey[300],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No activities found',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Try changing your filters',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                else if (isGridView)
                    _buildSliverGridView(activities, isLoadingMore, hasMorePages)
                  else
                    _buildSliverListView(activities, isLoadingMore, hasMorePages),

                SliverToBoxAdapter(child: SizedBox(height: 50,)),
              ],
            ),
          );
        },
      ),
    );
  }

  // Widget _buildCategoryItem(IconData icon, String label, Color color, String type) {
  //   return GestureDetector(
  //     onTap: () {
  //       onNavigate(context,type);
  //     },
  //     child: Container(
  //       width: 65, // Compact width
  //       margin: const EdgeInsets.only(right: 12),
  //       child: Column(
  //         mainAxisSize: MainAxisSize.min,
  //         children: [
  //           // Icon with a soft background glow
  //           Container(
  //             padding: const EdgeInsets.all(12), // Icon ke charo taraf space
  //             decoration: BoxDecoration(
  //               color: color.withOpacity(0.08), // Halka sa color touch bina border ke
  //               shape: BoxShape.circle, // Pure circle for a soft look
  //             ),
  //             child: Icon(
  //               icon,
  //               size: 26,
  //               color: color, // Icon ka original color yahan chamkega
  //             ),
  //           ),
  //           const SizedBox(height: 10),
  //           // Label - Clean & Sharp
  //           Text(
  //             label,
  //             style: TextStyle(
  //               fontSize: 11,
  //               fontWeight: FontWeight.w600,
  //               color: Colors.grey.shade800, // Professional dark grey
  //               letterSpacing: 0.1,
  //             ),
  //             textAlign: TextAlign.center,
  //             maxLines: 1,
  //             overflow: TextOverflow.ellipsis,
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  Widget _buildSliverListView(List<Datum> activities, bool isLoadingMore, bool hasMorePages) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
            (context, index) {
          if (index >= activities.length) {
            if (isLoadingMore && hasMorePages) {
              return _buildLoadMoreIndicator();
            }
            return const SizedBox();
          }
          return _buildListItem(activities[index]);
        },
        childCount: activities.length + (isLoadingMore && hasMorePages ? 1 : 0),
      ),
    );
  }

  Widget _buildSliverGridView(List<Datum> activities, bool isLoadingMore, bool hasMorePages) {
    return SliverGrid(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 5,
        childAspectRatio: 0.8,
      ),
      delegate: SliverChildBuilderDelegate(
            (context, index) {
          if (index >= activities.length) {
            if (isLoadingMore && hasMorePages) {
              return _buildLoadMoreIndicator();
            }
            return const SizedBox();
          }
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 7),
            child: _buildGridItem(activities[index]),
          );
        },
        childCount: activities.length + (isLoadingMore && hasMorePages ? 1 : 0),
      ),
    );
  }

  Widget _buildGridItem(Datum activity) {
    return GestureDetector(
      onTap: () => _showActivityDetails(activity),
      child: Container(
        margin: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF2C3E50).withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- Image Section ---
              Expanded(
                flex: 3,
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: Hero(
                        tag: 'activity-${activity.id}', // Smooth transition if you use Hero
                        child: Image.network(
                          activity.eventImage.isNotEmpty ? activity.eventImage : 'https://via.placeholder.com/150',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    // Bottom Shadow Overlay for text readability
                    Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            stops: const [0.0, 0.5, 1.0],
                            colors: [
                              Colors.black.withOpacity(0.2),
                              Colors.transparent,
                              Colors.black.withOpacity(0.6),
                            ],
                          ),
                        ),
                      ),
                    ),


                    // Attractive Discount Badge
                    if (activity.percentageOff > 0)
                      Positioned(
                        top: 12,
                        right: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.redAccent,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.redAccent.withOpacity(0.4),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              )
                            ],
                          ),
                          child: Text(
                            "${activity.percentageOff}% OFF",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              // --- Content Section ---
              Expanded(
                flex: 4,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      Text(
                        isEnglish ? activity.enEventName : activity.hiEventName,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF2D3436),
                          height: 1.2,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 3),

                      // Rating Section
                      Row(
                        children: [
                          _buildStars(double.parse(activity.reviewAvgStar)),
                          const SizedBox(width: 4),
                          Text(
                            "(${activity.reviewCount})",
                            style: TextStyle(
                              color: Colors.grey.shade500,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),

                      // Price and Action Button
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [

                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (activity.percentageOff > 0)
                                Text(
                                  "₹ ${activity.minPrice}",
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey.shade400,
                                    decoration: TextDecoration.lineThrough,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                RichText(
                                text: TextSpan(
                                  children: [
                                    const TextSpan(
                                      text: "₹ ",
                                      style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.deepOrangeAccent,
                                          fontWeight: FontWeight.w900
                                      ),
                                    ),
                                    TextSpan(
                                      text: activity.price,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w900,
                                        color: Color(0xFF2D3436),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          SizedBox(width: 3,),

                          // Action Button: View/Add
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFFFF5722), Color(0xFFFF9100)],
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Text(
                              "Book Now",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold
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
      ),
    );
  }

  Widget _buildStars(double rating) {
    int fullStars = rating.floor();
    bool hasHalfStar = (rating - fullStars) >= 0.5;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        if (index < fullStars) {
          return const Icon(
            Icons.star_rounded,
            size: 16,
            color: Color(0xFFFFC107),
          );
        } else if (index == fullStars && hasHalfStar) {
          return const Icon(
            Icons.star_half_rounded,
            size: 16,
            color: Color(0xFFFFC107),
          );
        } else {
          return const Icon(
            Icons.star_border_rounded,
            size: 16,
            color: Color(0xFFFFC107),
          );
        }
      }),
    );
  }

  Widget _buildListItem(Datum activity) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => _showActivityDetails(activity),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            ///  Top Image Section
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                  child: CachedNetworkImage(
                    imageUrl: activity.eventImage.isNotEmpty
                        ? activity.eventImage
                        : 'https://via.placeholder.com/400',
                    height: 150,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),

                /// Discount Badge
                if (activity.percentageOff > 0)
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.redAccent,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        "${activity.percentageOff}% OFF",
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
              ],
            ),

            /// 🔥 Content Section
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  /// Title
                  Text(
                    isEnglish
                        ? activity.enEventName
                        : activity.hiEventName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1A1A2E),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),

                  /// Rating Row
                  Row(
                    children: [
                      _buildStars(
                          double.parse(activity.reviewAvgStar)),
                      const SizedBox(width: 6),
                      Text(
                        "(${activity.reviewCount} reviews)",
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  /// Price + Button
                  Row(
                    mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,
                    children: [

                      /// Price Column
                      Column(
                        crossAxisAlignment:
                        CrossAxisAlignment.start,
                        children: [
                          if (activity.percentageOff > 0)
                            Text(
                              "₹ ${activity.minPrice}",
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey.shade400,
                                decoration:
                                TextDecoration.lineThrough,
                              ),
                            ),

                          Row(
                            children: [
                              const Text(
                                "₹ ",
                                style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.deepOrange),
                              ),
                              Text(
                                activity.price,
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w900,
                                  color: Color(0xFF2D3436),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),

                      /// 🔥 Book Now Button
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 12),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              Color(0xFFFF5722),
                              Color(0xFFFF9100)
                            ],
                          ),
                          borderRadius:
                          BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.deepOrange
                                  .withOpacity(0.3),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Text(
                          "Book Now",
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold),
                        ),
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

  void _showActivityDetails(Datum activity) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TicketDetailsPage(
          attractionName: activity.slug, isEnglish: isEnglish,
        ),
      ),
    );
  }

  Widget _buildLoadMoreIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: Column(
        children: List.generate(8, (index) => _buildListItemShimmer()),
      ),
    );
  }

  Widget _buildListItemShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: Colors.grey.shade200,
            width: 1,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // Left Column with Image Shimmer
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Image container shimmer
                  Container(
                    width: 150,
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.white,
                        width: 3,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Price shimmer
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        width: 15,
                        height: 15,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 2),
                      Container(
                        width: 60,
                        height: 24,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 4),
                      Container(
                        width: 40,
                        height: 12,
                        color: Colors.white,
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(width: 18),

              // Right Column Details Shimmer
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Badge shimmer
                    Container(
                      width: 100,
                      height: 30,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    const SizedBox(height: 10),
                    // Title shimmer
                    Container(
                      width: double.infinity,
                      height: 20,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 6),
                    Container(
                      width: 150,
                      height: 16,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 8),
                    // Divider
                    Container(
                      height: 1,
                      width: double.infinity,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 12),
                    // Button shimmer
                    Container(
                      width: double.infinity,
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryHeader() {
    return Consumer<ActivitiesCategoryController>(
      builder: (context, controller, child) {
        final isLoading = controller.isLoading;
        final categories = controller.activitiesCategoryList;

        return Container(
          height: 100,
          color: Colors.white,
          child: Column(
            children: [
              Container(
                height: 100,
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: _buildCategoryList(isLoading, categories),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCategoryList(
      bool isLoading,
      List<AcitivityCategoryList> categories,
      ) {
    if (isLoading) {
      return _buildCategoryShimmer();
    }

    if (categories.isEmpty) {
      return const Center(
        child: Text(
          'No categories found',
          style: TextStyle(color: Colors.grey, fontSize: 12),
        ),
      );
    }

    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: categories.length + 1, // +1 for "All"
        itemBuilder: (context, index) {

          ///  ALL CATEGORY
          if (index == 0) {
            return _buildCategoryItem(
              imageUrl: "", // No image
              label: isEnglish ? "All" : "सभी",
              index: 0,
            );
          }

          final category = categories[index - 1];

          return _buildCategoryItem(
            imageUrl: category.image ?? "",
            label: isEnglish
                ? category.enCategoryName
                : category.hiCategoryName ?? "Category",
            index: index,
          );
        },
      ),
    );
  }

  Widget _buildCategoryItem({
    required String imageUrl,
    required String label,
    required int index,
  }) {
    final bool isSelected = selectedCategory == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedCategory = index;
        });
        _applyCategoryFilter(index);
      },
      child: Container(
        width: 75,
        margin: const EdgeInsets.only(right: 14),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [

            ///  Circular Image with Glow Effect
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: isSelected
                    ? Border.all(color: Colors.deepOrange, width: 2)
                    : null,
                boxShadow: [
                  if (isSelected)
                    BoxShadow(
                      color: Colors.deepOrange.withOpacity(0.3),
                      blurRadius: 10,
                      spreadRadius: 1,
                    ),
                ],
              ),
              child: CircleAvatar(
                radius: 25,
                backgroundColor: Colors.grey.shade100,
                backgroundImage:
                imageUrl.isNotEmpty ? NetworkImage(imageUrl) : null,
                child: imageUrl.isEmpty
                    ? const Icon(Icons.grid_view, color: Colors.deepOrange)
                    : null,
              ),
            ),

            const SizedBox(height: 8),

            ///  Label
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected
                    ? Colors.deepOrange
                    : Colors.grey.shade800,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryChip(
      String title,
      int index,
      IconData icon,
      Color color, {
        required bool isSelected,
        required VoidCallback onTap,
      }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(right: 10, top: 1, bottom: 1),
        padding: const EdgeInsets.symmetric(horizontal: 16,),
        decoration: BoxDecoration(
          // Selected hone par subtle white background, warna bilkul transparent
          color: isSelected ? Colors.white : const Color(0xFFF1F2F6),
          borderRadius: BorderRadius.circular(10), // Perfect Round
          border: Border.all(
            // Selected par main color ki border, warna light grey
            color: isSelected ? color : Colors.transparent,
            width: 1.5,
          ),
          boxShadow: isSelected
              ? [
            BoxShadow(
              color: color.withOpacity(0.15),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ]
              : [],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Dot indicator ya Icon
            Icon(
              icon,
              size: 18,
              color: isSelected ? color : Colors.grey.shade600,
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                color: isSelected ? Colors.black : Colors.grey.shade600,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryShimmer() {
    return ListView(
      scrollDirection: Axis.horizontal,
      children: List.generate(6, (index) {
        return Padding(
          padding: EdgeInsets.only(left: index > 0 ? 8 : 0),
          child: Container(
            height: 32,
            constraints: BoxConstraints(
              minWidth: 80,
              maxWidth: 110,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.explore, size: 14, color: Colors.grey[400]),
                const SizedBox(width: 6),
                Container(
                  width: 40,
                  height: 8,
                  color: Colors.grey[400],
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  // Helper method to get icon based on category name
  IconData _getCategoryIcon(String? categoryName) {
    if (categoryName == null) return Icons.category;

    final name = categoryName.toLowerCase();
    if (name.contains('ropeway') || name.contains('cable')) {
      return Icons.cable;
    } else if (name.contains('boat') || name.contains('sailing')) {
      return Icons.sailing;
    } else if (name.contains('mountain') || name.contains('hiking')) {
      return Icons.terrain;
    } else if (name.contains('beach') || name.contains('sea')) {
      return Icons.beach_access;
    } else if (name.contains('city') || name.contains('urban')) {
      return Icons.location_city;
    } else if (name.contains('adventure')) {
      return Icons.sports;
    } else if (name.contains('nature')) {
      return Icons.nature;
    } else if (name.contains('culture')) {
      return Icons.museum;
    } else if (name.contains('food')) {
      return Icons.restaurant;
    } else if (name.contains('shopping')) {
      return Icons.shopping_bag;
    }
    return Icons.explore;
  }

  // Helper method to get color based on category name
  Color _getCategoryColor(String? categoryName) {
    if (categoryName == null) return const Color(0xFF4361EE);

    final name = categoryName.toLowerCase();
    if (name.contains('ropeway') || name.contains('cable')) {
      return const Color(0xFF4CC9F0);
    } else if (name.contains('boat') || name.contains('sailing')) {
      return const Color(0xFF06D6A0);
    } else if (name.contains('mountain') || name.contains('hiking')) {
      return const Color(0xFF38B000);
    } else if (name.contains('beach') || name.contains('sea')) {
      return const Color(0xFFF72585);
    } else if (name.contains('city') || name.contains('urban')) {
      return const Color(0xFF7209B7);
    } else if (name.contains('adventure')) {
      return const Color(0xFFFF9E00);
    } else if (name.contains('nature')) {
      return const Color(0xFF2A9D8F);
    } else if (name.contains('culture')) {
      return const Color(0xFFE63946);
    } else if (name.contains('food')) {
      return const Color(0xFFF4A261);
    } else if (name.contains('shopping')) {
      return const Color(0xFF9B5DE5);
    }
    return const Color(0xFF4361EE);
  }
}

class _StickyHeaderDelegate extends SliverPersistentHeaderDelegate {
  final double minHeight;
  final double maxHeight;
  final Widget child;

  _StickyHeaderDelegate({
    required this.minHeight,
    required this.maxHeight,
    required this.child,
  });

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return SizedBox.expand(child: child);
  }

  @override
  double get maxExtent => maxHeight;

  @override
  double get minExtent => minHeight;

  @override
  bool shouldRebuild(_StickyHeaderDelegate oldDelegate) {
    return maxHeight != oldDelegate.maxHeight ||
        minHeight != oldDelegate.minHeight ||
        child != oldDelegate.child;
  }
}