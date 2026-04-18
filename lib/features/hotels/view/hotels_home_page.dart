import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:intl/intl.dart';
import 'package:mahakal/features/hotels/controller/hotel_user_controller.dart';
import 'package:mahakal/features/hotels/view/see_alllocations_screen.dart';
import 'package:mahakal/features/hotels/view/spcae_details_page.dart';
import 'package:mahakal/features/hotels/view/view_allhotel_page.dart'
    hide Hotel;
import 'package:mahakal/features/hotels/view/view_allspaces_page.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import '../../../main.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../blogs_module/no_image_widget.dart';
import '../../youtube_vedios/view/dynamic_tabview/grid_view/YoutubeGridView.dart';
import '../controller/check_order_status_Controller.dart';
import '../controller/featured_hotel_controller.dart';
import '../controller/location_list_controller.dart';
import '../controller/spaces_list_controller.dart';
import '../model/check_order_status_model.dart';
import '../model/dummy_data_model.dart';
import '../model/features_hotel_model.dart';
import '../model/hotel_model.dart' hide Hotel;
import '../model/spaces_list_model.dart';
import '../widgets/hotel_uihelper.dart';
import 'hotel_detail_page.dart';
import 'hotel_form_page.dart';

class HotelHomeScreen extends StatefulWidget {
  final ScrollController? scrollController;

   HotelHomeScreen({super.key,this.scrollController,});

  @override
  State<HotelHomeScreen> createState() => _HotelHomeScreenState();
}

class _HotelHomeScreenState extends State<HotelHomeScreen> {

  // Variables
  TextEditingController _locationTextController = TextEditingController();

  DateTime checkInDate = DateTime.now().add(const Duration(days: 1));
  DateTime checkOutDate = DateTime.now().add(const Duration(days: 2));

  final DateFormat _dateFormatter = DateFormat('dd/MM/yyyy');

  DateTimeRange? selectedDateRange;

  bool _showDraftBanner = true;
  bool showGuestDetails = false;
  int rooms = 1;
  int adults = 2;
  int children = 0;
  int locationId = 0;

  String _selectedLocation = '';
  bool _showLocationList = false;

  int _currentImageIndex = 0;
  late PageController _pageController;
  Timer? _autoSlideTimer;

  final List<String> _hotelImages = [
    "https://img.freepik.com/free-photo/umbrella-deck-chair-around-outdoor-swimming-pool-hotel-resort-with-sea-ocean-beach-coconut-palm-tree_74190-14083.jpg?semt=ais_hybrid&w=740&q=80",
    "https://cdn.sanity.io/images/ocl5w36p/prod5/6f75cf8dbebc57ea7badba6d2c0077a0ce4e1928-640x885.jpg?w=380",
    "https://cdn2.paraty.es/fives-corpo/images/86dd9eb380daa37",
    "https://img.freepik.com/premium-photo/beautiful-beach-view-tropical-island-sea-beach-with-palms-around-holiday-vacation-concept_663265-1429.jpg",
    "https://img.freepik.com/free-photo/umbrella-deck-chair-around-outdoor-swimming-pool-hotel-resort-with-sea-ocean-beach-coconut-palm-tree_74190-14083.jpg?semt=ais_hybrid&w=740&q=80",
    "https://cdn.sanity.io/images/ocl5w36p/prod5/6f75cf8dbebc57ea7badba6d2c0077a0ce4e1928-640x885.jpg?w=380",
    "https://cdn2.paraty.es/fives-corpo/images/86dd9eb380daa37",
    "https://img.freepik.com/premium-photo/beautiful-beach-view-tropical-island-sea-beach-with-palms-around-holiday-vacation-concept_663265-1429.jpg",
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
    _startAutoSlide();
    // Fetch locations on init
    Future.microtask(() async {
      context.read<LocationListController>().fetchLocations();
      context.read<FeaturedHotelController>().fetchFeaturedHotels();
      context.read<SpacesListController>().fetchSpaces();

      await context.read<CheckOrderStatusController>().fetchDraftOrders(context);
    });
    //
    // final city = Provider.of<AuthController>(
    //   context,
    //   listen: false,
    // ).city ?? '';

    //_locationTextController = TextEditingController(text: city);
  }

  @override
  void dispose() {
    _pageController.dispose();
    _autoSlideTimer?.cancel();
    super.dispose();
  }

  void _startAutoSlide() {
    _autoSlideTimer = Timer.periodic(Duration(seconds: 5), (timer) {
      if (_pageController.hasClients) {
        final nextPage = (_currentImageIndex + 1) % _hotelImages.length;
        _pageController.animateToPage(
          nextPage,
          duration: Duration(milliseconds: 800),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentImageIndex = index;
    });
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

  String _getMonthName(int month) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return months[month - 1];
  }
  String _formatDate(DateTime date) {
    return '${date.day} ${_getMonthName(date.month)} ${date.year}';
  }

  // Guest Counter Methods
  void _updateRooms(int value) {
    if (value >= 1) {
      setState(() {
        rooms = value;
      });
    }
  }

  void _updateAdults(int value) {
    if (value >= 1) {
      setState(() {
        adults = value;
      });
    }
  }

  void _updateChildren(int value) {
    if (value >= 0) {
      setState(() {
        children = value;
      });
    }
  }

  void _toggleGuestDetails() {
    setState(() {
      showGuestDetails = !showGuestDetails;
    });
  }

  String _getGuestSummary() {
    return '$adults Adult${adults > 1 ? 's' : ''}, $children Child${children > 1 ? 'ren' : ''}';
  }

  // Widget Build Methods
  Widget _buildCounterRow({
    required String title,
    required int count,
    required IconData icon,
    required VoidCallback onDecrement,
    required VoidCallback onIncrement,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(icon, color: Colors.orange, size: 20),
            SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ],
        ),
        Row(
          children: [
            // Minus Button
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(18),
              ),
              child: IconButton(
                onPressed: onDecrement,
                icon: Icon(Icons.remove, size: 16),
                padding: EdgeInsets.zero,
                color: (title == 'Rooms' && count > 1) ||
                        (title != 'Rooms' && count > 0)
                    ? Colors.black
                    : Colors.grey[400],
              ),
            ),

            SizedBox(width: 16),
            Container(
              width: 40,
              alignment: Alignment.center,
              child: Text(
                '$count',
                style: TextStyle(
                  fontSize: 18,
                ),
              ),
            ),
            SizedBox(width: 16),

            // Plus Button
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.2),
                borderRadius: BorderRadius.circular(18),
              ),
              child: IconButton(
                onPressed: onIncrement,
                icon: Icon(Icons.add, color: Colors.orange, size: 16),
                padding: EdgeInsets.zero,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDateColumn({
    required IconData icon,
    required String label,
    required String date,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.orange, size: 16),
              SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 10,
                ),
              ),
            ],
          ),
          SizedBox(height: 5),
          Text(
            date,
            style: TextStyle(
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SingleChildScrollView(
        controller: widget.scrollController,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Bar
            _buildSearchBar(),

            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildSectionTitle('Featured Hotels'),
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => AllHotelsScreen(),
                                ),
                              );
                            },
                            child: Text(
                              'See All',
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.orange,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Consumer<FeaturedHotelController>(
                        builder: (context, controller, child) {
                          final bool isLoading = controller.isLoading ||
                              controller.featuresHotelModel == null ||
                              controller.featuresHotelModel!.data == null;

                          // Check if data is empty
                          final bool isEmpty = !isLoading &&
                              (controller.featuresHotelModel!.data!.hotels == null ||
                                  controller.featuresHotelModel!.data!.hotels.isEmpty);

                          // Show shimmer only when loading
                          if (isLoading) {
                            return SizedBox(
                              height: 280,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: 3,
                                itemBuilder: (context, index) {
                                  return _buildShimmerItem();
                                },
                              ),
                            );
                          }

                          // Show empty state if no data
                          if (isEmpty) {
                            return _buildEmptyState("No Featured Hotels","Check back later for featured hotels");
                          }

                          // Show data
                          final hotels = controller.featuresHotelModel!.data!.hotels;
                          return SizedBox(
                            height: 280,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: hotels.length,
                              itemBuilder: (context, index) {
                                final hotel = hotels[index];
                                return GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => HotelDetailScreen(
                                          hotelId: hotel.id,
                                        ),
                                      ),
                                    );
                                  },
                                  child: HotelCard(hotels, index),
                                );
                              },
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),

                  // Popular Destinations
                  Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildSectionTitle('Popular Destinations'),
                          Consumer<LocationListController>(
                            builder: (context, locationListController, child) {
                              return TextButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => SeeAllLocationsScreen(
                                        destinations:
                                        locationListController.locations,
                                      ),
                                    ),
                                  );
                                },
                                child: Text(
                                  'See All',
                                  style: AppTextStyles.bodyMedium.copyWith(
                                    color: AppColors.orange,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                      Consumer<LocationListController>(
                        builder: (BuildContext context, locationListController,
                            Widget? child) {
                          final bool isLoading = locationListController.isLoading || locationListController.nearRestLocations == null || locationListController.nearRestLocations.isEmpty;

                          // Check if data is empty
                          final bool isEmpty = !isLoading &&
                              (locationListController.nearRestLocations == null ||
                                  locationListController.nearRestLocations.isEmpty);

                          if(isLoading){
                            return SizedBox(
                              height: 180,
                              child: ListView.builder(
                                  itemCount: 6,
                                  scrollDirection: Axis.horizontal,
                                  itemBuilder: (BuildContext context, int index) {
                                return buildDestinationCardShimmer();
                                  }
                              )
                            );
                          }

                          if(isEmpty){
                            return _buildEmptyState("No Popular Destinations","Check back later for popular destinations");
                          }

                          return SizedBox(
                            height: 180,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: isLoading
                                  ? 5
                                  : locationListController.nearRestLocations.length,
                              itemBuilder: (context, index) {
                                return InkWell(
                                  onTap: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (context) => AllHotelsScreen(locationId: locationListController.nearRestLocations[index].id, isDestination: true)));
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.only(right: 16),
                                    child: DestinationCard(
                                      destination: locationListController.nearRestLocations[index].name,
                                      imageUrl: '${locationListController.nearRestLocations[index].image}',
                                    ),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),

                  // Featured Spaces
                  Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildSectionTitle('Featured Spaces'),
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => AllSpacesScreen(),
                                ),
                              );
                            },
                            child: Text(
                              'See All',
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.orange,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Consumer<SpacesListController>(
                        builder: (context, controller, child) {
                          final bool isLoading = controller.isLoading ||
                              controller.spacesListModel == null ||
                              controller.spacesListModel!.data == null ||
                              controller.spacesListModel!.data!.spaces.isEmpty;

                          final isEmpty = !isLoading &&
                              (controller.spacesListModel!.data!.spaces == null ||
                                  controller.spacesListModel!.data!.spaces.isEmpty);

                          return SizedBox(
                            height: 280,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: isLoading
                                  ? 3
                                  : controller.spacesListModel!.data!.spaces
                                  .length >
                                  5
                                  ? 5
                                  : controller
                                  .spacesListModel!.data!.spaces.length,
                              itemBuilder: (context, index) {
                                if (isLoading) {
                                  return _buildShimmerItem(); //  safe shimmer
                                }

                                if(isEmpty){
                                  return _buildEmptyState("No Featured Spaces","Check back later for featured spaces");
                                }

                                final spaces = controller.spacesListModel!.data!.spaces;
                                return GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => SpcaeDetailsPage(
                                          spacelId: spaces[index].id,
                                        ),
                                      ),
                                    );
                                  },
                                  child: SpaceCard(spaces, index),
                                );
                              },
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 24),
                    ],
                  )

                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget HotelCard(List<Hotel> hotel, int index) {
    return Container(
      width: 280,
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: AppColors.white,
          border: Border.all(color: Colors.grey.shade200)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image with favorite button
          Stack(
            children: [
              ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(20)),
                child: Image.network(
                  hotel[index].bannerImage,
                  height: 140,
                  width: double.infinity,
                  fit: BoxFit.fill,
                ),
              ),
              // Positioned(
              //   top: 12,
              //   right: 12,
              //   child: Container(
              //     decoration: BoxDecoration(
              //       color: AppColors.white.withOpacity(0.9),
              //       shape: BoxShape.circle,
              //     ),
              //     child: IconButton(
              //       icon: Icon(Icons.favorite_border, color: AppColors.red),
              //       onPressed: () {},
              //     ),
              //   ),
              // ),
              // if (hotel.discount != null)
              //   Positioned(
              //     top: 12,
              //     left: 12,
              //     child: Container(
              //       padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              //       decoration: BoxDecoration(
              //         color: AppColors.red,
              //         borderRadius: BorderRadius.circular(8),
              //       ),
              //       child: Text(
              //         '${hotel.discount!.toInt()}% OFF',
              //         style: const TextStyle(
              //           color: AppColors.white,
              //           fontSize: 12,
              //           fontWeight: FontWeight.w600,
              //         ),
              //       ),
              //     ),
              //   ),
            ],
          ),

          // Hotel details
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  hotel[index].title,
                  style: AppTextStyles.heading4
                      .copyWith(fontWeight: FontWeight.w700),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.location_on_outlined,
                        size: 16, color: AppColors.gray),
                    const SizedBox(width: 4),
                    Text(
                      hotel[index].address,
                      style: AppTextStyles.bodySmall
                          .copyWith(color: AppColors.gray),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.yellow.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.star, size: 14, color: AppColors.yellow),
                          const SizedBox(width: 4),
                          Text(
                            hotel[index].starRate.toString(),
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '(${hotel[index].reviewScore} reviews)',
                      style: AppTextStyles.bodySmall
                          .copyWith(color: AppColors.gray),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: formatIndianCurrency("${hotel[index].price}"),
                            style: AppTextStyles.priceMedium,
                          ),
                          TextSpan(
                            text: ' / night',
                            style: AppTextStyles.captionSmall,
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.chevron_right, color: AppColors.gray),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget SpaceCard(List<Space> spaces, int index) {
    final space = spaces[index];

    return Container(
      width: 280,
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: AppColors.white,
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Room image
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: Stack(
              children: [
                CachedNetworkImage(
                  imageUrl: space.image.isNotEmpty ? space.image : '',
                  height: 140,
                  width: double.infinity,
                  fit: BoxFit.fill,
                  placeholder: (context, url) => Container(
                    height: 140,
                    color: Colors.grey[200],
                  ),
                  errorWidget: (context, url, error) => Container(
                    height: 140,
                    color: Colors.grey[200],
                    child: const Icon(Icons.bed, size: 40, color: Colors.grey),
                  ),
                ),

                // // Room type badge
                // Positioned(
                //   top: 12,
                //   left: 12,
                //   child: Container(
                //     padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                //     decoration: BoxDecoration(
                //       color: AppColors.primary.withOpacity(0.9),
                //       borderRadius: BorderRadius.circular(8),
                //     ),
                //     child: Text(
                //       room.roomType.toUpperCase(),
                //       style: const TextStyle(
                //         color: AppColors.white,
                //         fontSize: 10,
                //         fontWeight: FontWeight.w600,
                //       ),
                //     ),
                //   ),
                // ),
              ],
            ),
          ),

          // Room details
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  space.title,
                  style: AppTextStyles.heading4
                      .copyWith(fontWeight: FontWeight.w700),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),

                // Room features
                Row(
                  children: [
                    _buildFeatureIcon(
                      icon: Icons.group,
                      text: '${space.maxGuests} Guests',
                    ),
                    const SizedBox(width: 10),
                    _buildFeatureIcon(
                      icon: Icons.bed,
                      text: '${space.bed} Beds',
                    ),
                    const SizedBox(width: 10),
                    _buildFeatureIcon(
                      icon: Icons.square_foot,
                      text: '${space.square} sqft',
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Price and booking button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          formatIndianCurrency(space.price.toString()),
                          style: AppTextStyles.priceMedium.copyWith(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          '/Day',
                          style: AppTextStyles.captionSmall.copyWith(
                            color: AppColors.gray,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.deepOrange,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Book Now',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureIcon({required IconData icon, required String text}) {
    return Row(
      children: [
        Icon(icon, size: 14, color: AppColors.gray),
        const SizedBox(width: 4),
        Text(
          text,
          style: AppTextStyles.captionSmall,
        ),
      ],
    );
  }

  Widget _buildShimmerItem() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        width: 280,
        margin: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Colors.white,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 140,
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _shimmerLine(180, 20),
                  const SizedBox(height: 8),
                  _shimmerLine(120, 16),
                  const SizedBox(height: 8),
                  _shimmerLine(60, 20),
                  const SizedBox(height: 8),
                  _shimmerLine(100, 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _shimmerLine(double width, double height) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }

  Widget _buildEmptyState(String title, String subTitle) {
    return Container(
      height: 180,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey, width: 1),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.hotel_outlined,
              size: 60,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subTitle,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // Shimmer Widget Method
  Widget _buildLocationShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: ListView.builder(
        padding: EdgeInsets.zero,
        physics: NeverScrollableScrollPhysics(),
        itemCount: 6, // Show 6 shimmer items
        itemBuilder: (context, index) {
          return Container(
            height: 30,
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Container(
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
                SizedBox(width: 12),
                Container(
                  width: 150,
                  height: 16,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      height: 520,
      child: Stack(
        children: [
          // Image Slider
          PageView.builder(
            controller: _pageController,
            onPageChanged: _onPageChanged,
            itemCount: _hotelImages.length,
            itemBuilder: (context, index) {
              return ClipPath(
                clipper: BottomWavyMoonClipper(),
                child: Image.network(
                  _hotelImages[index],
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return _shimmerLine(520, 360);
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey[200],
                      child: Center(
                        child: Icon(
                          Icons.broken_image,
                          color: Colors.grey[400],
                          size: 50,
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          ),

          // Back Button
          Positioned(
            top: 50,
            left: 20,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(20),
              ),
              child: IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: Icon(Icons.arrow_back_ios_new, size: 20),
                padding: EdgeInsets.zero,
              ),
            ),
          ),

          // Text Content
          Positioned(
            top: 100,
            left: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hi, There!',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Where would you like to go?',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          ),

          Positioned(
            bottom: 15,
            left: 20,
            right: 20,
            child: AnimatedContainer(
              duration: Duration(milliseconds: 400),
              height: showGuestDetails
                  ? 340
                  : (_selectedLocation.isEmpty ? 255 : 255),
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.4),
                    blurRadius: 10,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              child: Consumer<LocationListController>(
                builder: (context, locationController, child) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      // Location Search Header
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _showLocationList = true;
                            showGuestDetails = false;
                          });
                        },
                        child: Container(
                          padding:
                              EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.grey[50],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.location_on,
                                  color: Colors.orange, size: 20),
                              SizedBox(width: 8),

                              ///  Search + Selected location field
                              Expanded(
                                child: Container(
                                  height: 30,
                                  child: TextField(
                                    controller: _locationTextController,
                                    readOnly: false,
                                    onTap: () {
                                      setState(() {
                                        _showLocationList = true;
                                      });
                                    },
                                    onChanged: (value) {
                                      context
                                          .read<LocationListController>()
                                          .filterLocations(value);
                                    },
                                    decoration: InputDecoration(
                                      hintText: 'Where are you going?',
                                      border: InputBorder.none,
                                    ),
                                  ),
                                ),
                              ),

                              Icon(
                                _showLocationList
                                    ? Icons.keyboard_arrow_up
                                    : Icons.keyboard_arrow_down,
                                color: Colors.orange,
                                size: 20,
                              ),
                            ],
                          ),
                        ),
                      ),

                      if (_showLocationList)
                        Expanded(
                          child: Container(
                            margin: EdgeInsets.only(top: 12),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey[300]!),
                            ),
                            child: Column(
                              children: [
                                // Locations List
                                Expanded(
                                  child: locationController.isLoading
                                      ? _buildLocationShimmer()
                                      : locationController.locations.isEmpty
                                          ? Center(
                                              child: Text(
                                                'No locations found',
                                                style: TextStyle(
                                                  color: Colors.grey,
                                                ),
                                              ),
                                            )
                                          : ListView.builder(
                                              padding: EdgeInsets.zero,
                                              physics: BouncingScrollPhysics(),
                                              itemCount: locationController
                                                  .filteredLocations.length,
                                              itemBuilder: (context, index) {
                                                final location =
                                                    locationController
                                                            .filteredLocations[
                                                        index];
                                                final locationName =
                                                    location.name ??
                                                        'Unknown Location';
                                                return Container(
                                                  height: 30,
                                                  child: Material(
                                                    color: Colors.transparent,
                                                    child: InkWell(
                                                      onTap: () {
                                                        setState(() {
                                                          _selectedLocation =
                                                              locationName;
                                                          _locationTextController
                                                                  .text =
                                                              locationName;
                                                          locationId =
                                                              location.id;
                                                          _showLocationList =
                                                              false;
                                                        });
                                                        context
                                                            .read<
                                                                LocationListController>()
                                                            .filterLocations(
                                                                "");
                                                        //
                                                        // setState(() {
                                                        //   _selectedLocation =
                                                        //       locationName;
                                                        //   locationId =
                                                        //       location.id;
                                                        //   _showLocationList =
                                                        //       false;
                                                        // });
                                                      },
                                                      child: Padding(
                                                        padding: EdgeInsets
                                                            .symmetric(
                                                                horizontal: 16),
                                                        child: Row(
                                                          children: [
                                                            Icon(
                                                              Icons.location_on,
                                                              color: Colors
                                                                  .grey[600],
                                                              size: 18,
                                                            ),
                                                            SizedBox(width: 12),
                                                            Expanded(
                                                              child: Text(
                                                                locationName,
                                                                style:
                                                                    TextStyle(
                                                                  fontSize: 15,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500,
                                                                ),
                                                              ),
                                                            ),
                                                            if (_selectedLocation ==
                                                                locationName)
                                                              Icon(
                                                                Icons.check,
                                                                color: Colors
                                                                    .orange,
                                                                size: 18,
                                                              ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                );
                                              },
                                            ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        SizedBox(
                        height: 15,
                      ),

                      // Other sections (only show when location list is hidden)
                      if (!_showLocationList) ...[

                        GestureDetector(
                          onTap: () async{
                            await showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            builder: (context) => CustomDateRangePicker(
                              initialStartDate: checkInDate,
                              initialEndDate: checkOutDate,
                              onDateRangeSelected: (range) {
                                setState(() {
                                  selectedDateRange = range;
                                  checkInDate = range.start;
                                  checkOutDate = range.end;
                                });
                              },
                            ),
                            );
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _buildDateColumn(
                                icon: Icons.calendar_today,
                                label: 'CHECK-IN',
                                date: _formatDate(checkInDate),
                                onTap: () async{
                                  await showModalBottomSheet(
                                    context: context,
                                    isScrollControlled: true,
                                    backgroundColor: Colors.transparent,
                                    builder: (context) => CustomDateRangePicker(
                                      initialStartDate: checkInDate,
                                      initialEndDate: checkOutDate,
                                      onDateRangeSelected: (range) {
                                        setState(() {
                                          selectedDateRange = range;
                                          checkInDate = range.start;
                                          checkOutDate = range.end;
                                        });
                                      },
                                    ),
                                  );
                                },
                              ),
                              Container(
                                padding: EdgeInsets.all(5),
                                decoration: BoxDecoration(
                                  color: Colors.orange.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(Icons.arrow_forward,
                                    color: Colors.orange, size: 20),
                              ),
                              _buildDateColumn(
                                icon: Icons.calendar_today,
                                label: 'CHECK-OUT',
                                date: _formatDate(checkOutDate),
                                onTap: () async{
                                  await showModalBottomSheet(
                                    context: context,
                                    isScrollControlled: true,
                                    backgroundColor: Colors.transparent,
                                    builder: (context) => CustomDateRangePicker(
                                      initialStartDate: checkInDate,
                                      initialEndDate: checkOutDate,
                                      onDateRangeSelected: (range) {
                                        setState(() {
                                          selectedDateRange = range;
                                          checkInDate = range.start;
                                          checkOutDate = range.end;
                                        });
                                      },
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                        Divider(
                          color: Colors.grey.shade200,
                        ),

                        // Guest Selector
                        Column(
                          children: [
                            // Compact Guest Summary
                            GestureDetector(
                              onTap: _toggleGuestDetails,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(Icons.person_outline,
                                              color: Colors.orange, size: 18),
                                          SizedBox(width: 8),
                                          Text(
                                            'GUESTS',
                                            style: TextStyle(
                                              color: Colors.grey,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        _getGuestSummary(),
                                        style: TextStyle(
                                          fontSize: 16,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Icon(
                                    showGuestDetails
                                        ? Icons.keyboard_arrow_up
                                        : Icons.keyboard_arrow_down,
                                    color: Colors.orange,
                                    size: 24,
                                  ),
                                ],
                              ),
                            ),

                            // Expanded Guest Details
                            if (showGuestDetails) ...[
                              // Rooms Counter
                              _buildCounterRow(
                                title: 'Rooms',
                                count: rooms,
                                icon: Icons.king_bed,
                                onDecrement: () => _updateRooms(rooms - 1),
                                onIncrement: () => _updateRooms(rooms + 1),
                              ),

                              SizedBox(
                                height: 5,
                              ),

                              // Adults Counter
                              _buildCounterRow(
                                title: 'Adults',
                                count: adults,
                                icon: Icons.person,
                                onDecrement: () => _updateAdults(adults - 1),
                                onIncrement: () => _updateAdults(adults + 1),
                              ),

                              SizedBox(
                                height: 5,
                              ),

                              // Children Counter
                              _buildCounterRow(
                                title: 'Children',
                                count: children,
                                icon: Icons.child_care,
                                onDecrement: () =>
                                    _updateChildren(children - 1),
                                onIncrement: () =>
                                    _updateChildren(children + 1),
                              ),
                            ],
                          ],
                        ),

                        //&& !showGuestDetails
                       // if (_selectedLocation.isNotEmpty) ...[
                          SizedBox(height: 15),
                          Row(
                            children: [
                              Expanded(
                                child: InkWell(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => AllHotelsScreen(
                                          locationId: locationId,
                                          adults: adults,
                                          children: children,
                                          rooms: rooms,
                                          checkInDate: checkInDate,
                                          checkOutDate: checkOutDate,
                                        ),
                                      ),
                                    );
                                    print("Location id $locationId");
                                    print("Adult  $adults");
                                    print("Children  $children");
                                    print("Rooms  $rooms");
                                    print("Check-in date: ${_dateFormatter.format(checkInDate)}");
                                    print("Check-out date: ${_dateFormatter.format(checkOutDate)}");
                                  },
                                  child: Container(
                                    height: 45, // Shorter height
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        colors: [
                                          Color(0xFFFF9966), // Light orange
                                          Color(0xFFFF5E62), // Darker orange/red
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                      borderRadius: BorderRadius.circular(25), // More rounded
                                      boxShadow: [
                                        BoxShadow(
                                          color: const Color(0xFFFF5E62).withOpacity(0.3),
                                          blurRadius: 12,
                                          offset: const Offset(0, 4),
                                          spreadRadius: 0,
                                        ),
                                      ],
                                    ),
                                    child: Center(
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          const Icon(
                                            Icons.hotel_rounded,
                                            color: Colors.white,
                                            size: 18,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            'HOTELS',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 13,
                                              fontWeight: FontWeight.w700,
                                              letterSpacing: 0.8,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12), // Reduced spacing
                              Expanded(
                                child: InkWell(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => AllSpacesScreen(
                                          locationId: locationId,
                                          adults: adults,
                                          children: children,
                                          rooms: rooms,
                                          checkInDate: checkInDate,
                                          checkOutDate: checkOutDate,
                                        ),
                                      ),
                                    );
                                    print("Location id $locationId");
                                    print("Adult  $adults");
                                    print("Children  $children");
                                    print("Rooms  $rooms");
                                    print("Check-in date: ${_dateFormatter.format(checkInDate)}");
                                    print("Check-out date: ${_dateFormatter.format(checkOutDate)}");
                                  },
                                  child: Container(
                                    height: 45, // Shorter height
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        colors: [
                                          Color(0xFF6B8CFF), // Light blue
                                          Color(0xFF4A6CF7), // Darker blue
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                      borderRadius: BorderRadius.circular(25), // More rounded
                                      boxShadow: [
                                        BoxShadow(
                                          color: const Color(0xFF4A6CF7).withOpacity(0.3),
                                          blurRadius: 12,
                                          offset: const Offset(0, 4),
                                          spreadRadius: 0,
                                        ),
                                      ],
                                    ),
                                    child: Center(
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          const Icon(
                                            Icons.meeting_room_rounded,
                                            color: Colors.white,
                                            size: 18,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            'SPACES',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 13,
                                              fontWeight: FontWeight.w700,
                                              letterSpacing: 0.8,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          )
                          // Row(
                          //   children: [
                          //     Expanded(
                          //       child: InkWell(
                          //         onTap: () {
                          //           Navigator.push(
                          //             context,
                          //             MaterialPageRoute(
                          //               builder: (context) => AllHotelsScreen(
                          //                 locationId: locationId,
                          //                 adults: adults,
                          //                 children: children,
                          //                 rooms: rooms,
                          //                 checkInDate: checkInDate,
                          //                 checkOutDate: checkOutDate,
                          //               ),
                          //             ),
                          //           );
                          //           print("Location id $locationId");
                          //           print("Adult  $adults");
                          //           print("Children  $children");
                          //           print("Rooms  $rooms");
                          //           print("Check-in date: ${_dateFormatter.format(checkInDate)}");
                          //           print("Check-out date: ${_dateFormatter.format(checkOutDate)}");
                          //         },
                          //         child: Container(
                          //           width: double.infinity,
                          //           padding: EdgeInsets.symmetric(vertical: 8),
                          //           decoration: BoxDecoration(
                          //             color: Colors.orange,
                          //             borderRadius: BorderRadius.circular(10),
                          //             boxShadow: [
                          //               BoxShadow(
                          //                 color: Colors.orange.withOpacity(0.3),
                          //                 blurRadius: 10,
                          //                 offset: Offset(0, 4),
                          //               ),
                          //             ],
                          //           ),
                          //           child: Center(
                          //             child: Text(
                          //               'SEARCH HOTELS',
                          //               style: TextStyle(
                          //                 color: Colors.white,
                          //                 fontSize: 14,
                          //                 fontWeight: FontWeight.w600,
                          //               ),
                          //             ),
                          //           ),
                          //         ),
                          //       ),
                          //     ),
                          //     SizedBox(width: 15),
                          //     Expanded(
                          //       child: InkWell(
                          //         onTap: () {
                          //           Navigator.push(
                          //             context,
                          //             MaterialPageRoute(
                          //               builder: (context) => AllSpacesScreen(
                          //                 locationId: locationId,
                          //                 adults: adults,
                          //                 children: children,
                          //                 rooms: rooms,
                          //                 checkInDate: checkInDate,
                          //                 checkOutDate: checkOutDate,
                          //               ),
                          //             ),
                          //           );
                          //           print("Location id $locationId");
                          //           print("Adult  $adults");
                          //           print("Children  $children");
                          //           print("Rooms  $rooms");
                          //           print("Check-in date: ${_dateFormatter.format(checkInDate)}");
                          //           print("Check-out date: ${_dateFormatter.format(checkOutDate)}");
                          //         },
                          //         child: Container(
                          //           width: double.infinity,
                          //           padding: EdgeInsets.symmetric(vertical: 8),
                          //           decoration: BoxDecoration(
                          //             color: Colors.orange,
                          //             borderRadius: BorderRadius.circular(10),
                          //             boxShadow: [
                          //               BoxShadow(
                          //                 color: Colors.orange.withOpacity(0.3),
                          //                 blurRadius: 10,
                          //                 offset: Offset(0, 4),
                          //               ),
                          //             ],
                          //           ),
                          //           child: Center(
                          //             child: Text(
                          //               'SEARCH SPACES',
                          //               style: TextStyle(
                          //                 color: Colors.white,
                          //                 fontSize: 14,
                          //                 fontWeight: FontWeight.w600,
                          //               ),
                          //             ),
                          //           ),
                          //         ),
                          //       ),
                          //     ),
                          //   ],
                          // ),
                        //]
                      ],
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        title,
        style: AppTextStyles.heading3.copyWith(fontWeight: FontWeight.w700),
      ),
    );
  }

  Widget buildDestinationCardShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: SizedBox(
        width: 150,
        height: 200, // Add explicit height
        child: Container(
          margin: const EdgeInsets.only(right: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: Colors.white, // Main background color
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Gradient overlay
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withOpacity(0.3), // Lighter opacity for shimmer
                      Colors.transparent,
                    ],
                  ),
                ),
              ),

              // Text placeholders
              Positioned(
                bottom: 16,
                left: 16,
                right: 16,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Destination name placeholder
                    Container(
                      width: 100,
                      height: 20,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // "50+ hotels" placeholder
                    Container(
                      width: 60,
                      height: 12,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        color: Colors.white,
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

}


class CustomDateRangePicker extends StatefulWidget {
  final DateTime initialStartDate;
  final DateTime initialEndDate;
  final ValueChanged<DateTimeRange> onDateRangeSelected;

  const CustomDateRangePicker({
    Key? key,
    required this.initialStartDate,
    required this.initialEndDate,
    required this.onDateRangeSelected,
  }) : super(key: key);

  @override
  State<CustomDateRangePicker> createState() => _CustomDateRangePickerState();
}

class _CustomDateRangePickerState extends State<CustomDateRangePicker> {
  late DateTime _currentMonth;
  late DateTime _startDate;
  late DateTime _endDate;
  DateTime? _tempStartDate;
  bool _isSelecting = false;

  final Color primaryOrange = const Color(0xFFFF7A00);
  final Color lightOrange = const Color(0xFFFFB74D);
  final Color lightBg = const Color(0xFFFFF8F0);

  @override
  void initState() {
    super.initState();
    _currentMonth = DateTime.now();
    _startDate = widget.initialStartDate;
    _endDate = widget.initialEndDate;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag Handle
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Container(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Select your stay',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.5,
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: lightBg,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.close),
                    color: primaryOrange,
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ],
            ),
          ),

          // Selected Dates Display
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [primaryOrange, lightOrange],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: primaryOrange.withOpacity(0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'CHECK-IN',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white70,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _formatDate(_startDate),
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  height: 2,
                  width: 30,
                  color: Colors.white.withOpacity(0.5),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text(
                        'CHECK-OUT',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white70,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _formatDate(_endDate),
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Month Navigator
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildMonthNavButton(
                  icon: Icons.chevron_left,
                  onTap: _previousMonth,
                ),
                Text(
                  '${_getMonthName(_currentMonth.month)} ${_currentMonth.year}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                _buildMonthNavButton(
                  icon: Icons.chevron_right,
                  onTap: _nextMonth,
                ),
              ],
            ),
          ),

          // Calendar Grid
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                // Weekdays
                Row(
                  children: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun']
                      .map((day) => Expanded(
                    child: Text(
                      day,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[600],
                      ),
                    ),
                  ))
                      .toList(),
                ),
                const SizedBox(height: 8),

                // Dates Grid
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 7,
                    childAspectRatio: 1,
                  ),
                  itemCount: _getDaysInMonth().length,
                  itemBuilder: (context, index) {
                    DateTime date = _getDaysInMonth()[index];

                    // Show empty cells for days from other months
                    if (date.month != _currentMonth.month) {
                      return const SizedBox(); // Empty cell for previous/next month days
                    }

                    bool isSelected = _isDateSelected(date);
                    bool isInRange = _isDateInRange(date);
                    bool isStart = isSameDate(date, _startDate);
                    bool isEnd = isSameDate(date, _endDate);
                    bool isToday = isSameDate(date, DateTime.now());

                    return GestureDetector(
                      onTap: () => _onDateTap(date),
                      child: Container(
                        margin: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: isStart || isEnd
                              ? primaryOrange
                              : isInRange
                              ? lightOrange.withOpacity(0.2)
                              : Colors.transparent,
                          borderRadius: _getBorderRadius(isStart, isEnd),
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isStart || isEnd
                                    ? primaryOrange
                                    : isSelected
                                    ? primaryOrange.withOpacity(0.1)
                                    : isToday
                                    ? lightOrange.withOpacity(0.2)
                                    : Colors.transparent,
                              ),
                              child: Center(
                                child: Text(
                                  date.day.toString(),
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: isStart || isEnd
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                    color: isStart || isEnd
                                        ? Colors.white
                                        : isToday
                                        ? primaryOrange
                                        : Colors.black87,
                                  ),
                                ),
                              ),
                            ),
                            if (isToday && !isStart && !isEnd)
                              Positioned(
                                bottom: 4,
                                left: 0,
                                right: 0,
                                child: Center(
                                  child: Container(
                                    width: 4,
                                    height: 4,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: primaryOrange,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),

          // Footer Buttons
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(30)),
              border: Border(
                top: BorderSide(color: Colors.grey[200]!),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.grey[700],
                      side: BorderSide(color: Colors.grey[300]!),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    child: const Text(
                      'CANCEL',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _confirmSelection,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryOrange,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    child: const Text(
                      'DONE',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
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

  // Helper method for border radius
  BorderRadius _getBorderRadius(bool isStart, bool isEnd) {
    if (isStart && isEnd) {
      return BorderRadius.circular(15);
    } else if (isStart) {
      return const BorderRadius.only(
        topLeft: Radius.circular(15),
        bottomLeft: Radius.circular(15),
      );
    } else if (isEnd) {
      return const BorderRadius.only(
        topRight: Radius.circular(15),
        bottomRight: Radius.circular(15),
      );
    } else {
      return BorderRadius.zero;
    }
  }

  Widget _buildMonthNavButton({required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: lightBg,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Icon(
          icon,
          color: primaryOrange,
        ),
      ),
    );
  }

  List<DateTime> _getDaysInMonth() {
    DateTime first = DateTime(_currentMonth.year, _currentMonth.month, 1);
    int daysInMonth = DateTime(_currentMonth.year, _currentMonth.month + 1, 0).day;

    // Get first day of week (Monday = 1, Sunday = 7)
    int firstWeekday = first.weekday;

    List<DateTime> days = [];

    // Add days from previous month
    for (int i = firstWeekday - 1; i > 0; i--) {
      days.add(first.subtract(Duration(days: i)));
    }

    // Add days of current month
    for (int i = 0; i < daysInMonth; i++) {
      days.add(first.add(Duration(days: i)));
    }

    // Add days from next month to complete grid
    int remainingDays = 42 - days.length; // 6 rows × 7 columns
    for (int i = 1; i <= remainingDays; i++) {
      days.add(first.add(Duration(days: daysInMonth - 1 + i)));
    }

    return days;
  }

  void _previousMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1, 1);
    });
  }

  void _nextMonth() {
    DateTime nextMonth = DateTime(_currentMonth.year, _currentMonth.month + 1, 1);
    if (!nextMonth.isAfter(DateTime.now().add(const Duration(days: 60)))) {
      setState(() {
        _currentMonth = nextMonth;
      });
    }
  }

  void _onDateTap(DateTime date) {
    // Don't allow selecting past dates
    if (date.isBefore(DateTime.now().subtract(const Duration(days: 1)))) {
      return;
    }

    if (!_isSelecting) {
      // Start selection
      setState(() {
        _tempStartDate = date;
        _startDate = date;
        _endDate = date;
        _isSelecting = true;
      });
    } else {
      // End selection
      if (date.isBefore(_startDate)) {
        setState(() {
          _startDate = date;
          _endDate = _tempStartDate!;
          _isSelecting = false;
        });
      } else {
        setState(() {
          _endDate = date;
          _isSelecting = false;
        });
      }
    }
  }

  bool _isDateSelected(DateTime date) {
    return (date.isAfter(_startDate.subtract(const Duration(days: 1))) &&
        date.isBefore(_endDate.add(const Duration(days: 1)))) ||
        isSameDate(date, _startDate) ||
        isSameDate(date, _endDate);
  }

  bool _isDateInRange(DateTime date) {
    return date.isAfter(_startDate) && date.isBefore(_endDate);
  }

  bool isSameDate(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  String _getMonthName(int month) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[month - 1];
  }

  String _formatDate(DateTime date) {
    return '${date.day} ${_getMonthName(date.month)} ${date.year}';
  }

  void _confirmSelection() {
    widget.onDateRangeSelected(DateTimeRange(start: _startDate, end: _endDate));
    Navigator.pop(context);
  }
}

// Category Card Widget
class CategoryCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;
  final bool isActive;

  const CategoryCard({
    super.key,
    required this.icon,
    required this.title,
    required this.color,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        color: isActive ? AppColors.orange.withOpacity(0.1) : AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isActive ? AppColors.orange : AppColors.lightGray,
          width: isActive ? 2 : 1,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isActive ? AppColors.orange : AppColors.lightGray,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: isActive ? AppColors.white : color,
              size: 24,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: AppTextStyles.bodySmall.copyWith(
              fontWeight: FontWeight.w600,
              color: isActive ? AppColors.orange : AppColors.black,
            ),
          ),
        ],
      ),
    );
  }
}

class DestinationCard extends StatelessWidget {
  final String destination;
  final String imageUrl;

  const DestinationCard({
    super.key,
    required this.destination,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: CachedNetworkImage(
                imageUrl: imageUrl,
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.fill,
                placeholder: (context, url) => placeholderImage(),
                errorWidget: (context, url, error) => NoImageWidget()),
          ),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [
                  AppColors.black.withOpacity(0.8),
                  Colors.transparent,
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  destination,
                  style: const TextStyle(
                    color: AppColors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
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

class WavyMoonClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();

    path.moveTo(0, 0);
    path.lineTo(size.width, 0);
    path.lineTo(size.width, size.height * 0.7);

    // Create wavy moon shape
    double waveHeight = 40;
    double waveWidth = size.width / 3;

    // First wave
    path.cubicTo(
      size.width,
      size.height * 0.7,
      size.width - waveWidth / 2,
      size.height * 0.7 - waveHeight,
      size.width - waveWidth,
      size.height * 0.7,
    );

    // Second wave (center dip)
    path.cubicTo(
      size.width - waveWidth - waveWidth / 2,
      size.height * 0.7 + waveHeight,
      size.width - 2 * waveWidth,
      size.height * 0.7 - waveHeight,
      size.width - 2 * waveWidth,
      size.height * 0.7,
    );

    // Third wave
    path.cubicTo(
      size.width - 2 * waveWidth - waveWidth / 2,
      size.height * 0.7 + waveHeight,
      0,
      size.height * 0.7 - waveHeight,
      0,
      size.height * 0.7,
    );

    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class BottomWavyMoonClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();

    path.moveTo(0, 0);
    path.lineTo(size.width, 0);
    path.lineTo(size.width, size.height * 0.85); // Changed from 0.7 to 0.85

    // Create wavy moon shape
    double waveHeight = 40;
    double waveWidth = size.width / 3;

    // First wave
    path.cubicTo(
      size.width,
      size.height * 0.85, // Changed here
      size.width - waveWidth / 2,
      size.height * 0.85 - waveHeight, // Changed here
      size.width - waveWidth,
      size.height * 0.85, // Changed here
    );

    // Second wave (center dip)
    path.cubicTo(
      size.width - waveWidth - waveWidth / 2,
      size.height * 0.85 + waveHeight, // Changed here
      size.width - 2 * waveWidth,
      size.height * 0.85 - waveHeight, // Changed here
      size.width - 2 * waveWidth,
      size.height * 0.85, // Changed here
    );

    // Third wave
    path.cubicTo(
      size.width - 2 * waveWidth - waveWidth / 2,
      size.height * 0.85 + waveHeight, // Changed here
      0,
      size.height * 0.85 - waveHeight, // Changed here
      0,
      size.height * 0.85, // Changed here
    );

    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class DraftOrdersPage extends StatefulWidget {
  final ScrollController? scrollController;

  const DraftOrdersPage({super.key,this.scrollController,});

  @override
  State<DraftOrdersPage> createState() => _DraftOrdersPageState();
}

class _DraftOrdersPageState extends State<DraftOrdersPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Draft Bookings',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
        ),
        leading: Container(
          margin: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(10),
          ),
          child: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(Icons.arrow_back_ios_new_rounded, size: 20),
            padding: EdgeInsets.zero,
          ),
        ),
        elevation: 0,
        backgroundColor: Colors.white,
      ),
      backgroundColor: Colors.grey[50],
      body: Consumer<CheckOrderStatusController>(
        builder: (context, controller, child) {
          if (controller.isLoading) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.deepOrange),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Loading drafts...',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            );
          }

          if (controller.draftOrderList.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: Colors.deepOrange[50],
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.drafts_outlined,
                        size: 56,
                        color: Colors.deepOrange,
                      ),
                    ),
                    SizedBox(height: 24),
                    Text(
                      'No Draft Bookings',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: Colors.grey[800],
                      ),
                    ),
                    SizedBox(height: 12),
                    Text(
                      'You don\'t have any draft bookings yet.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                        height: 1.5,
                      ),
                    ),
                    SizedBox(height: 32),
                    ElevatedButton(
                      onPressed: () {
                        // Navigate to create new booking
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepOrange,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        'Create New Booking',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return CustomScrollView(
            controller: widget.scrollController,
            slivers: [
              SliverPadding(
                padding: EdgeInsets.fromLTRB(16, 20, 16, 16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                        (context, index) {
                      final draft = controller.draftOrderList[index];
                      return Container(
                        margin: EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 20,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {
                              Navigator.of(context, rootNavigator: true).push(
                                MaterialPageRoute(
                                  builder: (context) => HotelForm(
                                    double.parse(draft.total.toString()).toInt(),
                                    "${draft.code}",
                                    true,
                                  ),
                                ),
                              );
                            },
                            borderRadius: BorderRadius.circular(16),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Container(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 12, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: Colors.deepOrange.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.hotel_outlined,
                                              size: 14,
                                              color: Colors.deepOrange,
                                            ),
                                            SizedBox(width: 6),
                                            Text(
                                              '${draft.objectModel.toUpperCase()}',
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.deepOrange,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      _buildStatusChip(draft.status),
                                    ],
                                  ),
                                  SizedBox(height: 16),
                                  _buildInfoRow(
                                    Icons.calendar_month_outlined,
                                    '${_formatDate(draft.startDate!)} - ${_formatDate(draft.endDate!)}',
                                  ),
                                  SizedBox(height: 8),
                                  _buildInfoRow(
                                    Icons.people_outline,
                                    '${draft.totalGuests} guests',
                                  ),
                                  SizedBox(height: 20),
                                  Divider(height: 1, color: Colors.grey[200]),
                                  SizedBox(height: 16),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Total Amount',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                          SizedBox(height: 4),
                                          Text(
                                            '₹${draft.total}',
                                            style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.w800,
                                              color: Colors.green[700],
                                            ),
                                          ),
                                        ],
                                      ),
                                      Container(
                                        width: 40,
                                        height: 40,
                                        decoration: BoxDecoration(
                                          color: Colors.deepOrange.withOpacity(0.1),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          Icons.arrow_forward_ios_rounded,
                                          size: 16,
                                          color: Colors.deepOrange,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                    childCount: controller.draftOrderList.length,
                  ),
                ),
              ),
            ],
          );
        },
      ),
      // floatingActionButton: controller.draftOrderList.isNotEmpty
      //     ? FloatingActionButton.extended(
      //   onPressed: () {
      //     // Navigate to create new booking
      //   },
      //   backgroundColor: Colors.deepOrange,
      //   foregroundColor: Colors.white,
      //   elevation: 2,
      //   shape: RoundedRectangleBorder(
      //     borderRadius: BorderRadius.circular(16),
      //   ),
      //   icon: Icon(Icons.add, size: 22),
      //   label: Text(
      //     'New Booking',
      //     style: TextStyle(fontWeight: FontWeight.w600),
      //   ),
      // )
      //     : null,
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(
          icon,
          size: 18,
          color: Colors.grey[600],
        ),
        SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 15,
              color: Colors.grey[700],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusChip(String status) {
    final color = _getStatusColor(status);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: 6),
          Text(
            status.toUpperCase(),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'draft':
        return Colors.orange;
      case 'pending':
        return Colors.blue;
      case 'confirmed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(DateTime date) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}