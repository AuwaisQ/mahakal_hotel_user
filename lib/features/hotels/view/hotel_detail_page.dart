import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:html/parser.dart' as html_parser;
import 'package:intl/intl.dart';
import 'package:mahakal/features/hotels/controller/hotel_details_controller.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import '../controller/share_hotel_controller.dart';
import '../model/checkavaillblity_model.dart';
import '../model/hotel_details_model.dart';
import '../widgets/hotel_uihelper.dart';
import 'booking_screen.dart';
import 'hotels_home_page.dart';

class HotelDetailScreen extends StatefulWidget {
  final int hotelId;

  const HotelDetailScreen({super.key, required this.hotelId});

  @override
  State<HotelDetailScreen> createState() => _HotelDetailScreenState();
}

class _HotelDetailScreenState extends State<HotelDetailScreen> {
  Timer? _autoScrollTimer;

  int _selectedImageIndex = 0;

  final PageController _pageController = PageController();
  final ScrollController _scrollController = ScrollController();

  late YoutubePlayerController _ytController;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<HotelDetailsController>().fetchHotelDetails(widget.hotelId);
    });
  }

  Future<void> initializeYoutubePlayer(String videoUrl) async {
    final videoId = YoutubePlayer.convertUrlToId(videoUrl) ?? '';

    _ytController = YoutubePlayerController(
      initialVideoId: videoId,
      flags: const YoutubePlayerFlags(
        autoPlay: true,
        mute: true,
        disableDragSeek: true,
        hideControls: true,
        loop: true,
        enableCaption: false,
        hideThumbnail: true,
        controlsVisibleAtStart: false,
        forceHD: false,
        showLiveFullscreenButton: false,
      ),
    );
  }

  @override
  void dispose() {
    _autoScrollTimer?.cancel();
    _pageController.dispose();
    _scrollController.dispose();
    _ytController.dispose();
    super.dispose();
  }

  // Gallery Bottom Sheet Function
  void _showGalleryBottomSheet() {
    final hotel = context.read<HotelDetailsController>().hotelDetailsModel?.data?.hotel;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return GalleryBottomSheet(
          useGalleryImages: false,
          stringImages: hotel?.gallery ?? [],
          initialIndex: _selectedImageIndex,
        );
      },
    );
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

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Education':
        return const Color(0xFF4CAF50);
      case 'Healthcare':
        return const Color(0xFFF44336);
      case 'Transport':
        return const Color(0xFF2196F3);
      case 'Spiritual':
        return const Color(0xFF9C27B0);
      case 'Shopping':
        return const Color(0xFFFF9800);
      default:
        return const Color(0xFF607D8B);
    }
  }

  String _getCategory(String name) {
    if (name.contains('Institute') || name.contains('College')) {
      return 'Education';
    } else if (name.contains('Hospital') || name.contains('Clinic')) {
      return 'Healthcare';
    } else if (name.contains('Bus') || name.contains('Station')) {
      return 'Transport';
    } else if (name.contains('Temple') || name.contains('Shri')) {
      return 'Spiritual';
    } else if (name.contains('Market') || name.contains('Mall')) {
      return 'Shopping';
    }
    return 'Landmark';
  }

  // Helper function to parse HTML
  String _parseHtmlToPlainText(String htmlString) {
    try {
      final document = html_parser.parse(htmlString);
      return document.body?.text ?? htmlString;
    } catch (e) {
      return htmlString;
    }
  }

  // Helper function to extract list items from HTML
  List<String> _extractListItems(String htmlContent) {
    try {
      final List<String> items = [];
      final document = html_parser.parse(htmlContent);
      final liElements = document.querySelectorAll('li');

      for (var li in liElements) {
        items.add(li.text.trim());
      }

      return items;
    } catch (e) {
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    final hotelDetailsController = context.watch<HotelDetailsController>();

    // Loading State
    if (hotelDetailsController.isLoading) {
      return HotelDetailsShimmer(); //
    }

    // Error State
    if (hotelDetailsController.hotelDetailsModel?.data == null ||
        hotelDetailsController.hotelDetailsModel?.data?.hotel == null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 50,
                color: Colors.red,
              ),
              const SizedBox(height: 20),
              Text(
                'Failed to load hotel details',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  hotelDetailsController.fetchHotelDetails(widget.hotelId);
                },
                child: Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    final hotel = hotelDetailsController.hotelDetailsModel?.data?.hotel!;
    final reviews = hotelDetailsController.hotelDetailsModel?.data?.reviews!;
    final relatedHotels =
        hotelDetailsController.hotelDetailsModel?.data?.relatedHotels;
    final surroundings =
        hotelDetailsController.hotelDetailsModel?.data?.hotel?.surrounding;
    final facilities = hotelDetailsController
        .hotelDetailsModel?.data?.hotel?.termsByAttributeInListingPage;

    initializeYoutubePlayer(hotel!.video);

    return Scaffold(
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          SliverAppBar(
            expandedHeight: 190, // Height increase for video
            floating: false,
            pinned: true,
            snap: false,
            stretch: true,
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  height: 40,
                  width: 40,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 2,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back_ios,
                        size: 18, color: Colors.black),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    padding: EdgeInsets.zero,
                  ),
                ),
                Container(
                  height: 40,
                  width: 40,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 2,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.share_outlined,
                        size: 18, color: Colors.black),
                    onPressed: () {
                      context.read<ShareHotelController>().shareHotel(
                            context,
                            "", // Your hotel share link
                            hotel.bannerImage, // Your hotel image URL
                          );
                    },
                    padding: EdgeInsets.zero,
                  ),
                ),
              ],
            ),
            automaticallyImplyLeading: false,
            flexibleSpace: FlexibleSpaceBar(
              stretchModes: const [
                StretchMode.zoomBackground,
              ],
              background: Stack(
                fit: StackFit.expand,
                children: [
                  ///  FULL WIDTH + FULL HEIGHT YOUTUBE VIDEO
                  Positioned.fill(
                    child: YoutubePlayerBuilder(
                      player: YoutubePlayer(
                        controller: _ytController,
                      ),
                      builder: (context, player) {
                        return SizedBox.expand(child: player);
                      },
                    ),
                  ),

                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            Colors.black.withOpacity(0.8),
                            Colors.transparent,
                            Colors.black.withOpacity(0.2),
                          ],
                          stops: const [0.0, 0.4, 1.0],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            elevation: 0,
            shadowColor: Colors.transparent,
          ),

          //Main Content
          SliverToBoxAdapter(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 20,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),

                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.grey[200]!,
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        children: [
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.blue.shade100,
                                  Colors.blue.shade50,
                                ],
                              ),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.blue.withOpacity(0.3),
                                width: 1.5,
                              ),
                            ),
                            child: const Icon(
                              Icons.location_on_rounded,
                              size: 16,
                              color: Colors.blue,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  hotel?.title ?? 'Hotel Name',
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 18,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  'Location',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey[500],
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  hotel?.address ?? 'Location not available',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey[800],
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          GestureDetector(
                            onTap: _showGalleryBottomSheet,
                            child: Container(
                              width: 56,
                              height: 56,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(28),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    blurRadius: 10,
                                    spreadRadius: 1,
                                  ),
                                ],
                              ),
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  // Gallery Icon
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.photo_library_rounded,
                                        size: 24,
                                        color: Colors.blue,
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        'Gallery',
                                        style: TextStyle(
                                          fontSize: 9,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.blue,
                                        ),
                                      ),
                                    ],
                                  ),

                                  // Image Count Badge
                                  if (hotel?.gallery != null &&
                                      hotel!.gallery.isNotEmpty)
                                    Positioned(
                                      top: 2,
                                      right: 2,
                                      child: Container(
                                        width: 18,
                                        height: 18,
                                        decoration: BoxDecoration(
                                          color: Colors.blue,
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: Colors.white,
                                            width: 2,
                                          ),
                                        ),
                                        child: Center(
                                          child: Text(
                                            '${hotel.gallery.length}',
                                            style: const TextStyle(
                                              fontSize: 9,
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    if(hotel.gallery.isNotEmpty)
                    SizedBox(
                      height: 100,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        itemCount: hotel.gallery.length,
                        itemBuilder: (context, index) {

                          final imageUrl = hotel.gallery[index];
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedImageIndex = index;
                              });
                              _showGalleryBottomSheet();
                            },
                            child: Container(
                              width: 80,
                              height: 50,
                              margin: const EdgeInsets.only(right: 12),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: _selectedImageIndex == index
                                      ? Colors.blue
                                      : Colors.transparent,
                                  width: 3,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 5,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(9),
                                child: Image.network(
                                  imageUrl,
                                  fit: BoxFit.cover,
                                  loadingBuilder: (context, child, loadingProgress) {
                                    if (loadingProgress == null) return child;

                                    return Container(
                                      color: Colors.grey[200],
                                    );
                                  },
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      color: Colors.grey[200],
                                      child: const Icon(
                                        Icons.broken_image,
                                        color: Colors.grey,
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    Container(
                      height: 120,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 5),
                        itemCount: facilities?.length,
                        itemBuilder: (context, index) {
                          final facility = facilities?[index];
                          return FacilityCard(
                            icon: facility?.icon ?? 'icofont-star',
                            name: facility?.name ?? 'Facility',
                            color: _getColorForIndex(index),
                          );
                        },
                      ),
                    ),

                    /// Description
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Simple Header
                        Row(
                          children: [
                            Container(
                              width: 4,
                              height: 20,
                              decoration: BoxDecoration(
                                color: Colors.blue,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Description',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Description Content
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.grey[300]!,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Parse HTML and display as plain text
                              Text(
                                _parseHtmlToPlainText(hotel?.content ??
                                    'No description available'),
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[800],
                                  height: 1.6,
                                  letterSpacing: 0.2,
                                ),
                              ),

                              // If there are lists in HTML, show them specially
                              if (hotel?.content?.contains('<li>') ??
                                  false) ...[
                                const SizedBox(height: 16),
                                const Divider(height: 1),
                                const SizedBox(height: 16),

                                Text(
                                  'Highlights',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.blue[800],
                                  ),
                                ),
                                const SizedBox(height: 12),

                                // Extract list items
                                ..._extractListItems(hotel!.content!)
                                    .map((item) {
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 8),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Icon(
                                          Icons.check_circle,
                                          size: 16,
                                          color: Colors.green,
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            item,
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.grey[700],
                                              height: 1.4,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                              ]
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // First check if policies exist
                    if (hotel?.policy != null && hotel!.policy!.isNotEmpty)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Policies Header
                          Row(
                            children: [
                              Container(
                                width: 4,
                                height: 20,
                                decoration: BoxDecoration(
                                  color: Colors.blue,
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Hotel Polices',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          // Policies List
                          ListView.builder(
                            physics: const NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            padding: EdgeInsets.zero,
                            itemCount: hotel.policy!.length,
                            itemBuilder: (context, index) {
                              final policy = hotel.policy![index];
                              return _buildPolicyCard(policy, index);
                            },
                          ),
                          const SizedBox(height: 24),
                        ],
                      ),

                    /// Reviews
                    if (reviews != null && reviews.data.isNotEmpty)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Divider(color: Colors.grey.shade200, height: 0.5),
                          const SizedBox(height: 20),

                          // Reviews Header with Rating
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.1),
                                  blurRadius: 15,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            Colors.blue.shade500,
                                            Colors.blue.shade700,
                                          ],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: const Icon(
                                        Icons.reviews_rounded,
                                        size: 22,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Guest Reviews',
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.w800,
                                              color: Colors.grey[900],
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            'What our guests say',
                                            style: TextStyle(
                                              fontSize: 13,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16, vertical: 8),
                                      decoration: BoxDecoration(
                                        color: Colors.grey[50],
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(
                                          color: Colors.grey[200]!,
                                        ),
                                      ),
                                      child: Text(
                                        '${reviews.data.length} Reviews',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.blue,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),

                                // Average Rating (if available)
                                const SizedBox(height: 16),
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: Colors.blue.shade50,
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.star_rounded,
                                            size: 16,
                                            color: Colors.blue,
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            '4.8',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w800,
                                              color: Colors.grey[900],
                                            ),
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            '/5',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        'Overall Rating',
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: Colors.grey[700],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 20),

                          // First Review (Featured)
                          _buildReviewCard(reviews.data.first),
                          // "View All Reviews" Button
                          if (reviews.data.length > 1) ...[
                            const SizedBox(height: 16),
                            Container(
                              width: double.infinity,
                              height: 48,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.blue,
                                  width: 1.5,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.blue.withOpacity(0.1),
                                    blurRadius: 10,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Material(
                                color: Colors.transparent,
                                borderRadius: BorderRadius.circular(12),
                                child: InkWell(
                                  onTap: () {
                                    _showAllReviewsBottomSheet(
                                        context, reviews.data);
                                  },
                                  borderRadius: BorderRadius.circular(12),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        'View All ${reviews.data.length} Reviews',
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.blue,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Icon(
                                        Icons.arrow_forward_rounded,
                                        size: 18,
                                        color: Colors.blue,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    const SizedBox(height: 24),

                    /// Related Hotels
                    relatedHotels!.isEmpty
                        ? SizedBox.shrink()
                        : Column(
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 4,
                                    height: 20,
                                    decoration: BoxDecoration(
                                      color: Colors.blue,
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Related Hotels',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              SizedBox(
                                height: 295,
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: relatedHotels?.length ?? 0,
                                  itemBuilder: (context, index) {
                                    return GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                HotelDetailScreen(
                                              hotelId: relatedHotels![index].id,
                                            ),
                                          ),
                                        );
                                      },
                                      child: RelatedHotelCard(
                                          relatedHotels ?? [], index),
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(height: 24),
                            ],
                          ),

                    /// Near Places
                    surroundings!.isEmpty
                        ? SizedBox.shrink()
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 4,
                                    height: 20,
                                    decoration: BoxDecoration(
                                      color: Colors.blue,
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Nearby Places',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 24,
                              ),
                              SizedBox(
                                height: 200,
                                child: GridView.builder(
                                  shrinkWrap: true,
                                  padding: EdgeInsets.zero,
                                  scrollDirection: Axis.horizontal,
                                  gridDelegate:
                                      const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 1,
                                    crossAxisSpacing: 16,
                                    mainAxisSpacing: 16,
                                    childAspectRatio: 1.1,
                                  ),
                                  itemCount:
                                      surroundings?.length, // Handle null case
                                  itemBuilder: (context, index) {
                                    if (surroundings == null)
                                      return const SizedBox
                                          .shrink(); // Handle null

                                    final key = (index + 1).toString();
                                    final place = surroundings[index];

                                    // Also handle if place is null
                                    if (place == null)
                                      return const SizedBox.shrink();

                                    return _PlaceCard(
                                      key,
                                      place.name,
                                      '${place.value} ${place.type.toString().split('.').last.toLowerCase()}',
                                      place.content,
                                      _getCategory(place.name),
                                    );
                                  },
                                ),
                              ),
                              SizedBox(
                                height: 80,
                              )
                            ],
                          )
                  ],
                ),
              ),
            ),
          ),
        ],
      ),

      // Bottom Booking Bar - Modern Design
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(
              color: Colors.grey[300]!,
              width: 1,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 25,
              spreadRadius: 2,
              offset: const Offset(0, -8),
            ),
          ],
        ),
        child: SafeArea(
          child: Row(
            children: [
              // Price Section
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Per Night Price
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '₹${hotel?.price}',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: Colors.grey[900],
                            letterSpacing: -0.5,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 2, bottom: 2),
                          child: Text(
                            '/night',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),

                    // Rating
                    Row(
                      children: [
                        Icon(
                          Icons.star_rounded,
                          size: 14,
                          color: Colors.blue,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${hotel?.starRate?.toStringAsFixed(1) ?? '4.5'} • ',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[700],
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          'reviews',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 5),

              // Check Availability Button
              Expanded(
                flex: 2,
                child: Container(
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.green.shade600,
                        Colors.green.shade700,
                        Colors.green.shade800,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      stops: const [0.0, 0.5, 1.0],
                    ),
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.green.withOpacity(0.4),
                        blurRadius: 20,
                        spreadRadius: 3,
                        offset: const Offset(0, 8),
                      ),
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(18),
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => BookingScreen(
                              hotel: hotelDetailsController.hotelDetailsModel!,
                            ),
                          ),
                        );
                      },
                      borderRadius: BorderRadius.circular(18),
                      highlightColor: Colors.white.withOpacity(0.2),
                      splashColor: Colors.white.withOpacity(0.3),
                      child: Stack(
                        children: [
                          // Animated Background
                          Positioned.fill(
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(18),
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.green.shade500,
                                    Colors.green.shade600,
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                              ),
                            ),
                          ),

                          // Content
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Icon
                              Container(
                                width: 30,
                                height: 30,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.calendar_today_rounded,
                                  size: 14,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(width: 8),

                              // Text
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'CHECK AVAILABILITY',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white,
                                      letterSpacing: 0.8,
                                      shadows: [
                                        Shadow(
                                          color: Colors.black.withOpacity(0.2),
                                          blurRadius: 2,
                                          offset: const Offset(0, 1),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Text(
                                    'Book Your Hotel...',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.white.withOpacity(0.9),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),

                              // Arrow
                              const SizedBox(width: 10),
                              Container(
                                width: 26,
                                height: 26,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 5,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  Icons.arrow_forward_rounded,
                                  size: 16,
                                  color: Colors.green.shade700,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
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

  Color _getColorForIndex(int index) {
    final colors = [
      const Color(0xFF667EEA), // Blue
      const Color(0xFFF093FB), // Pink
      const Color(0xFF4FD1C5), // Teal
      const Color(0xFFF6AD55), // Orange
      const Color(0xFF9F7AEA), // Purple
      const Color(0xFF4299E1), // Light Blue
      const Color(0xFF48BB78), // Green
      const Color(0xFFED8936), // Dark Orange
    ];
    return colors[index % colors.length];
  }

  Widget FacilityCard(
      {required Color color, required String icon, required String name}) {
    return Container(
      width: 90,
      margin: const EdgeInsets.only(right: 10),
      child: Column(
        children: [
          // Icon Circle
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
              border: Border.all(
                color: color.withOpacity(0.2),
                width: 1.5,
              ),
            ),
            child: Center(
              child: Icon(
                _getIconFromString(icon),
                color: color,
                size: 25,
              ),
            ),
          ),
          const SizedBox(height: 8),

          // Facility Name
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
            decoration: BoxDecoration(
              color: color.withOpacity(0.05),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              name,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: color,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _PlaceCard(String number, String name, String distance,
      String description, String category) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
        border: Border.all(
          color: Colors.grey[200]!,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with number and category
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: _getCategoryColor(category).withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: _getCategoryColor(category),
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    number,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    category,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: _getCategoryColor(category),
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getCategoryColor(category).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    distance,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: _getCategoryColor(category),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Expanded(
                    child: Text(
                      description,
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey[600],
                        height: 1.4,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget RelatedHotelCard(List<RelatedHotel> relatedHotel, int index) {
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
                  relatedHotel[index].bannerImage,
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
                  relatedHotel[index].title,
                  style: AppTextStyles.heading4
                      .copyWith(fontWeight: FontWeight.w700),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        relatedHotel[index].address,
                        style: TextStyle(color: Colors.grey, fontSize: 12),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
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
                            relatedHotel[index].starRate.toString(),
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
                      '(${relatedHotel[index].reviewScore} reviews)',
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
                            text: formatIndianCurrency(
                                "${relatedHotel[index].price}"),
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

  Widget _buildPolicyCard(Policy policy, int index) {
    // Different icons for different policy types
    final Map<String, IconData> policyIcons = {
      'guarantee': Icons.credit_card_rounded,
      'children': Icons.child_care_rounded,
      'cancellation': Icons.cancel_rounded,
      'late': Icons.access_time_rounded,
      'checkin': Icons.login_rounded,
      'checkout': Icons.logout_rounded,
      'payment': Icons.payment_rounded,
      'general': Icons.info_rounded,
    };

    // Determine icon based on title
    IconData getIconForPolicy(String title) {
      final lowerTitle = title.toLowerCase();
      if (lowerTitle.contains('guarantee') || lowerTitle.contains('credit')) {
        return policyIcons['guarantee']!;
      } else if (lowerTitle.contains('children') ||
          lowerTitle.contains('child')) {
        return policyIcons['children']!;
      } else if (lowerTitle.contains('cancellation') ||
          lowerTitle.contains('amendment')) {
        return policyIcons['cancellation']!;
      } else if (lowerTitle.contains('late') ||
          lowerTitle.contains('check-out')) {
        return policyIcons['late']!;
      } else if (lowerTitle.contains('check-in')) {
        return policyIcons['checkin']!;
      } else if (lowerTitle.contains('payment')) {
        return policyIcons['payment']!;
      } else {
        return policyIcons['general']!;
      }
    }

    // Color based on policy type
    Color getColorForPolicy(String title) {
      final lowerTitle = title.toLowerCase();
      if (lowerTitle.contains('cancellation') || lowerTitle.contains('late')) {
        return Colors.red;
      } else if (lowerTitle.contains('children')) {
        return Colors.green;
      } else if (lowerTitle.contains('guarantee')) {
        return Colors.blue;
      } else {
        return Colors.blue;
      }
    }

    final icon = getIconForPolicy(policy.title ?? '');
    final color = getColorForPolicy(policy.title ?? '');

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        elevation: 5,
        shadowColor: Colors.black.withOpacity(0.05),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.grey[200]!,
              width: 1.5,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Policy Header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                  border: Border(
                    bottom: BorderSide(
                      color: color.withOpacity(0.2),
                      width: 1.5,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: color.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Icon(
                        icon,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Text(
                          //   policy.title?.toUpperCase() ?? 'POLICY',
                          //   style: TextStyle(
                          //     fontSize: 12,
                          //     fontWeight: FontWeight.w800,
                          //     color: color,
                          //     letterSpacing: 0.8,
                          //   ),
                          // ),
                          // const SizedBox(height: 2),
                          Text(
                            policy.title ?? 'Policy',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: Colors.grey[900],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: color.withOpacity(0.3),
                        ),
                      ),
                      child: Text(
                        '${index + 1}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: color,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Policy Content
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Parse content with bullet points
                    ..._parsePolicyContent(policy.content ?? '').map((point) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              margin: const EdgeInsets.only(top: 6, right: 12),
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: color,
                                shape: BoxShape.circle,
                              ),
                            ),
                            Expanded(
                              child: Text(
                                point.trim(),
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[700],
                                  height: 1.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),

                    // Important Note
                    if (policy.title?.toLowerCase().contains('cancellation') ??
                        false)
                      Container(
                        margin: const EdgeInsets.only(top: 12),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: Colors.red.withOpacity(0.2),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.warning_amber_rounded,
                              size: 16,
                              color: Colors.red,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Important: Please read cancellation policy carefully',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.red[700],
                                  fontWeight: FontWeight.w600,
                                ),
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
      ),
    );
  }

// Parse policy content into bullet points
  List<String> _parsePolicyContent(String content) {
    // Split by dash or bullet points
    final points = content
        .split('\r\n')
        .where((point) => point.trim().isNotEmpty)
        .toList();

    if (points.isEmpty) {
      // If no line breaks, split by dashes
      return content
          .split('-')
          .where((point) => point.trim().isNotEmpty)
          .toList();
    }

    return points.map((point) => point.replaceFirst('-', '').trim()).toList();
  }

  Widget _buildReviewCard(ReviewsDatum review) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey[200]!,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Review Header
          Row(
            children: [
              // User Avatar
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.blue.shade100,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.blue.withOpacity(0.3),
                    width: 2,
                  ),
                ),
                child: Center(
                  child: Text(
                    review.title?.substring(0, 1).toUpperCase() ?? 'G',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Colors.blue.shade700,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // User Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.title ?? 'Anonymous Guest',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Colors.grey[900],
                      ),
                    ),
                    const SizedBox(height: 4),

                    // Rating and Date
                    Row(
                      children: [
                        // Stars
                        Row(
                          children: List.generate(5, (index) {
                            return Icon(
                              index < (review.rateNumber ?? 5)
                                  ? Icons.star_rounded
                                  : Icons.star_border_rounded,
                              size: 14,
                              color: Colors.blue,
                            );
                          }),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          width: 4,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.grey[400],
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _formatReviewDate("22/09/2025"),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Verified Badge
              // if (review.author!. == "approved")
              //   Container(
              //     padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              //     decoration: BoxDecoration(
              //       color: Colors.green.withOpacity(0.1),
              //       borderRadius: BorderRadius.circular(6),
              //       border: Border.all(
              //         color: Colors.green.withOpacity(0.3),
              //       ),
              //     ),
              //     child: Row(
              //       children: [
              //         Icon(
              //           Icons.verified_rounded,
              //           size: 12,
              //           color: Colors.green,
              //         ),
              //         const SizedBox(width: 4),
              //         Text(
              //           'Verified',
              //           style: TextStyle(
              //             fontSize: 10,
              //             fontWeight: FontWeight.w600,
              //             color: Colors.green,
              //           ),
              //         ),
              //       ],
              //     ),
              //   ),
            ],
          ),

          const SizedBox(height: 16),

          // Review Content
          Text(
            review.content ?? 'No review content',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
              height: 1.6,
            ),
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
          ),

          // Read More Button if content is long
          // if ((review.content?.length ?? 0) > 200)
          //   Align(
          //     alignment: Alignment.centerRight,
          //     child: TextButton(
          //       onPressed: () {
          //         // Show full review
          //       },
          //       style: TextButton.styleFrom(
          //         minimumSize: Size.zero,
          //         padding: EdgeInsets.zero,
          //         tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          //       ),
          //       child: Text(
          //         'Read more',
          //         style: TextStyle(
          //           fontSize: 13,
          //           fontWeight: FontWeight.w600,
          //           color: Colors.blue,
          //         ),
          //       ),
          //     ),
          //   ),

          // const SizedBox(height: 16),
          // Row(
          //   children: [
          //     // Helpful Button
          //     Container(
          //       padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          //       decoration: BoxDecoration(
          //         color: Colors.grey[50],
          //         borderRadius: BorderRadius.circular(20),
          //       ),
          //       child: Row(
          //         children: [
          //           Icon(
          //             Icons.thumb_up_rounded,
          //             size: 14,
          //             color: Colors.grey[600],
          //           ),
          //           const SizedBox(width: 6),
          //           Text(
          //             'Helpful',
          //             style: TextStyle(
          //               fontSize: 12,
          //               color: Colors.grey[600],
          //               fontWeight: FontWeight.w500,
          //             ),
          //           ),
          //         ],
          //       ),
          //     ),
          //
          //     const Spacer(),
          //
          //     // Share Button
          //     Container(
          //       padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          //       decoration: BoxDecoration(
          //         color: Colors.grey[50],
          //         borderRadius: BorderRadius.circular(20),
          //       ),
          //       child: Row(
          //         children: [
          //           Icon(
          //             Icons.share_rounded,
          //             size: 14,
          //             color: Colors.grey[600],
          //           ),
          //           const SizedBox(width: 6),
          //           Text(
          //             'Share',
          //             style: TextStyle(
          //               fontSize: 12,
          //               color: Colors.grey[600],
          //               fontWeight: FontWeight.w500,
          //             ),
          //           ),
          //         ],
          //       ),
          //     ),
          //   ],
          // ),
        ],
      ),
    );
  }

// Date Format Function
  String _formatReviewDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) return 'Recently';

    try {
      final date = DateTime.parse(dateString);
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inDays > 365) {
        return '${(difference.inDays / 365).floor()}y ago';
      } else if (difference.inDays > 30) {
        return '${(difference.inDays / 30).floor()}mo ago';
      } else if (difference.inDays > 0) {
        return '${difference.inDays}d ago';
      } else if (difference.inHours > 0) {
        return '${difference.inHours}h ago';
      } else {
        return 'Just now';
      }
    } catch (e) {
      return 'Recently';
    }
  }

  IconData _getIconFromString(String iconName) {
    // Map icofont icons to Flutter Icons
    final iconMap = {
      'icofont-wall-clock': Icons.access_time,
      'icofont-car-alt-3': Icons.directions_car,
      'icofont-bicycle-alt-2': Icons.pedal_bike,
      'icofont-imac': Icons.tv,
      'icofont-recycle-alt': Icons.local_laundry_service,
      'icofont-wifi-alt': Icons.wifi,
      'icofont-tea': Icons.local_cafe,
      'icofont-bed': Icons.bed,
      'icofont-bathtub': Icons.bathtub,
      'icofont-swimmer': Icons.pool,
      'icofont-restaurant': Icons.restaurant,
    };

    return iconMap[iconName] ?? Icons.star;
  }

  void _showAllReviewsBottomSheet(
      BuildContext context, List<ReviewsDatum> reviews) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.9,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(25),
              topRight: Radius.circular(25),
            ),
          ),
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(25),
                    topRight: Radius.circular(25),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.reviews_rounded,
                          color: Colors.blue,
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'All Reviews',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                color: Colors.grey[900],
                              ),
                            ),
                            Text(
                              '${reviews.length} total reviews',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(
                        Icons.close_rounded,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),

              // Reviews List
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: reviews.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: _buildReviewCard(reviews[index]),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}


// Gallery Bottom Sheet Widget
class GalleryBottomSheet extends StatefulWidget {
  final List<String>? stringImages;
  final List<Gallery>? galleryImages;
  final int initialIndex;
  final bool useGalleryImages; // true = galleryImages, false = stringImages

  const GalleryBottomSheet({
    super.key,
    this.stringImages,
    this.galleryImages,
    this.initialIndex = 0,
    required this.useGalleryImages,
  }) : assert(
          (stringImages != null &&
                  galleryImages == null &&
                  !useGalleryImages) ||
              (galleryImages != null &&
                  stringImages == null &&
                  useGalleryImages),
          'Either provide stringImages or galleryImages based on useGalleryImages flag',
        );

  @override
  State<GalleryBottomSheet> createState() => _GalleryBottomSheetState();
}

class _GalleryBottomSheetState extends State<GalleryBottomSheet> {
  late PageController _pageController;
  int _currentIndex = 0;

  // Get total images count
  int get _totalImages {
    if (widget.useGalleryImages && widget.galleryImages != null) {
      return widget.galleryImages!.length;
    } else if (!widget.useGalleryImages && widget.stringImages != null) {
      return widget.stringImages!.length;
    }
    return 0;
  }

  // Get image URL by index
  String _getImageUrl(int index) {
    if (widget.useGalleryImages && widget.galleryImages != null) {
      return widget.galleryImages![index].large;
    } else if (!widget.useGalleryImages && widget.stringImages != null) {
      return widget.stringImages![index];
    }
    return '';
  }

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.60,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(25),
          topRight: Radius.circular(25),
        ),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(25),
                topRight: Radius.circular(25),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Gallery',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.grey[800],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(
                    Icons.close,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),

          // Image Counter
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              '${_currentIndex + 1} / $_totalImages',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.blue,
              ),
            ),
          ),

          // Main Image Viewer
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              itemCount: _totalImages,
              onPageChanged: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.all(16),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      _getImageUrl(index),
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;

                        // Shimmer effect while loading
                        return Shimmer.fromColors(
                          baseColor: Colors.grey[300]!,
                          highlightColor: Colors.grey[100]!,
                          child: Container(
                            width: double.infinity,
                            height: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey[200],
                          child: const Center(
                            child: Icon(
                              Icons.broken_image,
                              size: 50,
                              color: Colors.grey,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
            ),
          ),

          // Thumbnail Strip with shimmer
          if (_totalImages > 1)
            SizedBox(
              height: 100,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                itemCount: _totalImages,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      _pageController.animateToPage(
                        index,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    },
                    child: Container(
                      width: 80,
                      height: 80,
                      margin: const EdgeInsets.only(right: 12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _currentIndex == index
                              ? Colors.blue
                              : Colors.transparent,
                          width: 3,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 5,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(9),
                        child: Image.network(
                          _getImageUrl(index),
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;

                            return Shimmer.fromColors(
                              baseColor: Colors.grey[300]!,
                              highlightColor: Colors.grey[100]!,
                              child: Container(
                                width: 80,
                                height: 80,
                                color: Colors.white,
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.grey[200],
                              child: const Icon(
                                Icons.broken_image,
                                color: Colors.grey,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

          // Select Button
          Padding(
            padding: const EdgeInsets.all(20),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context, _currentIndex);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 5,
                  shadowColor: Colors.blue.withOpacity(0.3),
                ),
                child: const Text(
                  'Select Image',
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
    );
  }
}

class HotelDetailsShimmer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App Bar Shimmer
          SliverAppBar(
            expandedHeight: 320,
            floating: false,
            pinned: true,
            stretch: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Shimmer.fromColors(
                baseColor: Colors.grey[300]!,
                highlightColor: Colors.grey[100]!,
                child: Container(
                  color: Colors.white,
                ),
              ),
            ),
            leading: Padding(
              padding: const EdgeInsets.only(left: 8),
              child: Shimmer.fromColors(
                baseColor: Colors.grey[300]!,
                highlightColor: Colors.grey[100]!,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
            actions: [
              Shimmer.fromColors(
                baseColor: Colors.grey[300]!,
                highlightColor: Colors.grey[100]!,
                child: Container(
                  width: 40,
                  height: 40,
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              Shimmer.fromColors(
                baseColor: Colors.grey[300]!,
                highlightColor: Colors.grey[100]!,
                child: Container(
                  width: 40,
                  height: 40,
                  margin: const EdgeInsets.only(right: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),

          // Main Content Shimmer
          SliverList(
            delegate: SliverChildListDelegate([
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Hotel Name & Rating Shimmer
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Shimmer.fromColors(
                          baseColor: Colors.grey[300]!,
                          highlightColor: Colors.grey[100]!,
                          child: Container(
                            width: 200,
                            height: 28,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                        Shimmer.fromColors(
                          baseColor: Colors.grey[300]!,
                          highlightColor: Colors.grey[100]!,
                          child: Container(
                            width: 60,
                            height: 24,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Location Shimmer
                    Shimmer.fromColors(
                      baseColor: Colors.grey[300]!,
                      highlightColor: Colors.grey[100]!,
                      child: Container(
                        width: 180,
                        height: 18,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Price & Booking Button Shimmer
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Shimmer.fromColors(
                              baseColor: Colors.grey[300]!,
                              highlightColor: Colors.grey[100]!,
                              child: Container(
                                width: 120,
                                height: 16,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Shimmer.fromColors(
                              baseColor: Colors.grey[300]!,
                              highlightColor: Colors.grey[100]!,
                              child: Container(
                                width: 80,
                                height: 20,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ],
                        ),
                        Shimmer.fromColors(
                          baseColor: Colors.grey[300]!,
                          highlightColor: Colors.grey[100]!,
                          child: Container(
                            width: 120,
                            height: 45,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Divider
                    Container(
                      height: 1,
                      color: Colors.grey[200],
                    ),
                    const SizedBox(height: 24),

                    // Overview Section Shimmer
                    _buildSectionShimmer("Overview"),
                    const SizedBox(height: 16),

                    // Overview Content Shimmer
                    Column(
                      children: List.generate(
                        4,
                        (index) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Shimmer.fromColors(
                            baseColor: Colors.grey[300]!,
                            highlightColor: Colors.grey[100]!,
                            child: Container(
                              width: double.infinity,
                              height: 14,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),

                    // Amenities Section Shimmer
                    _buildSectionShimmer("Amenities"),
                    const SizedBox(height: 16),

                    // Amenities Grid Shimmer
                    GridView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 1.2,
                      ),
                      itemCount: 6,
                      itemBuilder: (context, index) {
                        return Shimmer.fromColors(
                          baseColor: Colors.grey[300]!,
                          highlightColor: Colors.grey[100]!,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Shimmer.fromColors(
                                  baseColor: Colors.grey[300]!,
                                  highlightColor: Colors.grey[100]!,
                                  child: Container(
                                    width: 30,
                                    height: 30,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Shimmer.fromColors(
                                  baseColor: Colors.grey[300]!,
                                  highlightColor: Colors.grey[100]!,
                                  child: Container(
                                    width: 50,
                                    height: 12,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 30),

                    // Rooms Section Shimmer
                    _buildSectionShimmer("Available Rooms"),
                    const SizedBox(height: 16),

                    // Rooms List Shimmer
                    ListView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: 3,
                      itemBuilder: (context, index) {
                        return Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.1),
                                blurRadius: 10,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: Shimmer.fromColors(
                            baseColor: Colors.grey[300]!,
                            highlightColor: Colors.grey[100]!,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Room Image Shimmer
                                Container(
                                  height: 180,
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(16),
                                      topRight: Radius.circular(16),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // Room Name Shimmer
                                      Container(
                                        width: 150,
                                        height: 20,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                      ),
                                      const SizedBox(height: 8),

                                      // Room Features Shimmer
                                      Row(
                                        children: List.generate(
                                          3,
                                          (index) => Expanded(
                                            child: Container(
                                              height: 12,
                                              margin: EdgeInsets.only(
                                                right: index < 2 ? 8 : 0,
                                              ),
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 16),

                                      // Price & Button Shimmer
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Container(
                                            width: 80,
                                            height: 18,
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                          ),
                                          Container(
                                            width: 100,
                                            height: 36,
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(12),
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
                      },
                    ),
                    const SizedBox(height: 30),

                    // Reviews Section Shimmer
                    _buildSectionShimmer("Guest Reviews"),
                    const SizedBox(height: 16),

                    // Reviews List Shimmer
                    ListView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: 2,
                      itemBuilder: (context, index) {
                        return Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.1),
                                blurRadius: 10,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: Shimmer.fromColors(
                            baseColor: Colors.grey[300]!,
                            highlightColor: Colors.grey[100]!,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          width: 120,
                                          height: 16,
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Container(
                                          width: 80,
                                          height: 12,
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const Spacer(),
                                    Container(
                                      width: 60,
                                      height: 20,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                Column(
                                  children: List.generate(
                                    3,
                                    (index) => Padding(
                                      padding: const EdgeInsets.only(bottom: 8),
                                      child: Container(
                                        width: double.infinity,
                                        height: 12,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(8),
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
                    ),
                    const SizedBox(height: 30),

                    // Location Section Shimmer
                    _buildSectionShimmer("Location"),
                    const SizedBox(height: 16),

                    // Map Placeholder Shimmer
                    Shimmer.fromColors(
                      baseColor: Colors.grey[300]!,
                      highlightColor: Colors.grey[100]!,
                      child: Container(
                        height: 200,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Address Shimmer
                    Container(
                      width: double.infinity,
                      height: 14,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: 180,
                      height: 14,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    const SizedBox(height: 40),

                    // Policies Section Shimmer
                    _buildSectionShimmer("Hotel Policies"),
                    const SizedBox(height: 16),

                    // Policies List Shimmer
                    Column(
                      children: List.generate(
                        4,
                        (index) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Row(
                            children: [
                              Container(
                                width: 20,
                                height: 20,
                                margin: const EdgeInsets.only(right: 12),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              Expanded(
                                child: Container(
                                  height: 14,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ]),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionShimmer(String title) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Container(
            width: 150,
            height: 22,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Container(
            width: 60,
            height: 14,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ],
    );
  }
}
