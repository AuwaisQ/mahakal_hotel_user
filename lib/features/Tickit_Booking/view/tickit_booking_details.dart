import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/services.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import '../../../main.dart';
import '../../hotels/view/hotel_detail_page.dart';
import '../../profile/controllers/profile_contrroller.dart';
import '../controller/activities_details_controller.dart';
import '../controller/activities_interested_controller.dart';
import 'tickit_summery.dart';

class TicketDetailsPage extends StatefulWidget {
  final String attractionName;
  var isEnglish;

   TicketDetailsPage({Key? key, required this.attractionName, required this.isEnglish})
      : super(key: key);

  @override
  _TicketDetailsPageState createState() => _TicketDetailsPageState();
}

class _TicketDetailsPageState extends State<TicketDetailsPage> {
  final GlobalKey _venuesKey = GlobalKey();
  final ScrollController _scrollController = ScrollController();

  int _currentImageIndex = 0;
  int _selectedVenueIndex = -1;

  String userId = "";
  String selectedVenue = '';

  bool _isVenueInViewport = false;
  bool _hasUserScrolledManually = false;

  // For description expansion
  bool _isDescriptionExpanded = false;

  // For policies expansion
  List<bool> _policyExpandedStates = [false, false, false];

  @override
  void initState() {
    super.initState();
    print("Tickit Slug Data:${widget.attractionName}");
    userId = Provider.of<ProfileController>(Get.context!, listen: false).userID;
    Future.microtask(() async {
      context.read<ActivitiesDetailsController>().fetchActivityDetails(widget.attractionName);
    });
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    // Mark that user has scrolled manually
    if (!_hasUserScrolledManually) {
      _hasUserScrolledManually = true;
    }

    // Check if venues section is in viewport
    final RenderBox? renderBox =
    _venuesKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox != null) {
      final position = renderBox.localToGlobal(Offset.zero);
      final isVisible = position.dy < MediaQuery.of(context).size.height * 0.8;

      if (isVisible != _isVenueInViewport) {
        setState(() {
          _isVenueInViewport = isVisible;
        });
      }
    }
  }

  void _scrollToVenues() async {
    // Provide haptic feedback
    HapticFeedback.selectionClick();

    // Get the venues list
    final venues = context
        .read<ActivitiesDetailsController>()
        .activityDetailsModel
        ?.data
        ?.allVenueData;

    // Check if venues exist
    if (venues == null || venues.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No venues available'),
          backgroundColor: Colors.blue,
        ),
      );
      return;
    }

    // Auto-select the first venue (index 0)
    setState(() {
      _selectedVenueIndex = 0;
      selectedVenue = venues[0].enEventVenue;
    });

    // Only scroll if venues are not in viewport
    if (!_isVenueInViewport) {
      await Future.delayed(Duration(milliseconds: 50));

      final RenderBox? renderBox =
      _venuesKey.currentContext?.findRenderObject() as RenderBox?;

      if (renderBox != null) {
        final position = renderBox.localToGlobal(Offset.zero);

        // Animate to the venues section
        await _scrollController.animateTo(
          position.dy - 100,
          duration: Duration(milliseconds: 600),
          curve: Curves.easeInOut,
        );

        // // Show success message
        // ScaffoldMessenger.of(context).showSnackBar(
        //   SnackBar(
        //     content: Row(
        //       children: [
        //         Icon(Icons.check_circle, color: Colors.white, size: 20),
        //         SizedBox(width: 12),
        //         Expanded(
        //           child: Column(
        //             mainAxisSize: MainAxisSize.min,
        //             crossAxisAlignment: CrossAxisAlignment.start,
        //             children: [
        //               Text(
        //                 'Venue Selected!',
        //                 style: TextStyle(
        //                   fontWeight: FontWeight.bold,
        //                   fontSize: 14,
        //                 ),
        //               ),
        //               Text(
        //                 venues[0].enEventVenue,
        //                 style: TextStyle(fontSize: 12),
        //                 maxLines: 1,
        //                 overflow: TextOverflow.ellipsis,
        //               ),
        //             ],
        //           ),
        //         ),
        //       ],
        //     ),
        //     backgroundColor: Colors.green,
        //     duration: Duration(seconds: 2),
        //     behavior: SnackBarBehavior.floating,
        //     shape: RoundedRectangleBorder(
        //       borderRadius: BorderRadius.circular(12),
        //     ),
        //   ),
        // );
      }
    } else {
      // If already in viewport and venue selected, navigate to booking
      if (_selectedVenueIndex != -1) {
        _navigateToBooking();
      }
    }
  }

  void _navigateToBooking() {
    final controller = Provider.of<ActivitiesDetailsController>(context, listen: false);
    final data = controller.activityDetailsModel?.data;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TickitSummery(
          adventureName: '${data?.enEventName}',
          slug: '${widget.attractionName}',
          venue: '${data?.allVenueData[_selectedVenueIndex].enEventVenue}',
          adharStatus: data?.aadharStatus ?? 0,
          venueId: data!.allVenueData[_selectedVenueIndex].id,
          eventId: data.id,
        ),
      ),
    );
  }

  void _showGalleryBottomSheet(List<String> images) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return GalleryBottomSheet(
          useGalleryImages: false,
          stringImages: images,
          initialIndex: _currentImageIndex,
        );
      },
    );
  }

  // Helper function to get plain text from HTML
  String _getPlainText(String html) {
    return html.replaceAll(RegExp(r'<[^>]*>'), '');
  }

  // Helper function to truncate HTML with ellipsis
  String _truncateHtml(String html, int maxLength) {
    final plainText = _getPlainText(html);
    if (plainText.length <= maxLength) {
      return html;
    }

    // Simple truncation for HTML (in production, use a proper HTML parser)
    // This is a simplified version
    final truncatedText = plainText.substring(0, maxLength);
    // Find last space to avoid cutting words
    final lastSpaceIndex = truncatedText.lastIndexOf(' ');
    final finalText = lastSpaceIndex > maxLength - 30
        ? truncatedText.substring(0, lastSpaceIndex)
        : truncatedText;

    return '$finalText...';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [

          /// ================= IMAGE SLIDER SECTION =================
          Consumer<ActivitiesDetailsController>(
            builder: (context, activitiesDetailsController, child) {
              final model = activitiesDetailsController.activityDetailsModel;
              final bool isLoading =
                  activitiesDetailsController.isLoading || model == null;
              final bool isEmpty = model?.data?.allVenueData.isEmpty ?? true;
              final controller = model;

              if (isLoading) {
                return _buildShimmerHeader();
              }

              if (isEmpty) {
                return _buildEmptyHeader();
              }

              return SliverAppBar(
                expandedHeight: 300,
                floating: false,
                automaticallyImplyLeading: false,
                pinned: false,
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      /// Image Carousel
                      CarouselSlider.builder(
                        options: CarouselOptions(
                          height: 350,
                          viewportFraction: 1.0,
                          autoPlay: true,
                          autoPlayInterval: const Duration(seconds: 5),
                          autoPlayAnimationDuration:
                          const Duration(milliseconds: 800),
                          autoPlayCurve: Curves.fastOutSlowIn,
                          onPageChanged: (index, reason) {
                            setState(() => _currentImageIndex = index);
                          },
                        ),
                        itemCount: controller?.data?.images.length ?? 0,
                        itemBuilder: (context, index, realIndex) {
                          final image = controller?.data?.images[index] ?? "";
                          return Container(
                            decoration: BoxDecoration(
                              image: image.isNotEmpty
                                  ? DecorationImage(
                                image: NetworkImage(image),
                                fit: BoxFit.cover,
                              )
                                  : null,
                            ),
                          );
                        },
                      ),

                      /// Gradient Overlay
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.black.withOpacity(0.4),
                              Colors.transparent,
                              Colors.black.withOpacity(0.1),
                            ],
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                          ),
                        ),
                      ),

                      /// Back Button
                      Positioned(
                        top: 50,
                        left: 20,
                        child: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.9),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: IconButton(
                            icon: const Icon(
                              Icons.arrow_back_ios_new_rounded,
                              size: 20,
                            ),
                            color: Colors.black,
                            onPressed: () => Navigator.pop(context),
                          ),
                        ),
                      ),

                      /// Language Button
                      Positioned(
                        top: 50,
                        right: 20,
                        child: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: IconButton(
                            icon:  Icon(
                              widget.isEnglish ? Icons.language : Icons.translate_sharp,
                              color: Colors.blue,                              size: 20,
                            ),
                            color: Colors.black,
                            onPressed: () {
                              setState(() {
                                widget.isEnglish = !widget.isEnglish;
                              });
                            },
                          ),
                        ),
                      ),

                      /// Image Indicators
                      if ((controller?.data?.images.isNotEmpty ?? false))
                        Positioned(
                          bottom: 20,
                          left: 0,
                          right: 0,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: controller!.data!.images
                                .asMap()
                                .entries
                                .map((entry) {
                              return Container(
                                width: 8,
                                height: 8,
                                margin:
                                const EdgeInsets.symmetric(horizontal: 4),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: _currentImageIndex == entry.key
                                      ? Colors.white
                                      : Colors.white.withOpacity(0.5),
                                ),
                              );
                            }).toList(),
                          ),
                        ),


                      /// Title Overlay
                      /// Title Overlay
                      Positioned(
                        bottom: 10,
                        left: 20,
                        right: 20,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [

                            /// Title
                            Expanded(
                              child: Text(
                                widget.isEnglish
                                    ? controller?.data?.enEventName ?? ""
                                    : controller?.data?.hiEventName ?? "",
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                  shadows: [
                                    Shadow(
                                      color: Colors.black.withOpacity(0.5),
                                      blurRadius: 10,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            const SizedBox(width: 10),

                            /// Gallery Button
                            if ((controller?.data?.images.isNotEmpty ?? false))
                              GestureDetector(
                                onTap: () {
                                  _showGalleryBottomSheet(controller!.data!.images);
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.65),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.photo_library_rounded,
                                        color: Colors.white,
                                        size: 18,
                                      ),
                                      SizedBox(width: 6),
                                      Text(
                                        "Gallery",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
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
          ),

          /// ================= CONTENT SECTION =================
          Consumer<ActivitiesDetailsController>(
            builder: (context, activitiesDetailsController, child) {
              final model = activitiesDetailsController.activityDetailsModel;
              final bool isLoading =
                  activitiesDetailsController.isLoading || model == null;
              final bool isEmpty = model?.data?.allVenueData.isEmpty ?? true;

              if (isLoading) {
                return SliverToBoxAdapter(
                  child: _buildContentShimmer(),
                );
              }

              if (isEmpty) {
                return _buildEmptyContent();
              }

              return SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    if ((model?.data?.images.isNotEmpty ?? false))
                      SizedBox(
                        height: 100,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          itemCount: model!.data!.images.length,
                          itemBuilder: (context, index) {

                            final imageUrl = model.data!.images[index];

                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  _currentImageIndex = index;
                                });
                                _showGalleryBottomSheet(model.data!.images);
                              },
                              child: Container(
                                width: 80,
                                height: 60,
                                margin: const EdgeInsets.only(right: 12),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: _currentImageIndex == index
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

                    const SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: _buildInterestedSection(activitiesDetailsController),
                    ),

                    const SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        children: [
                          _buildDescriptionSection(activitiesDetailsController),
                          const SizedBox(height: 25),
                          _buildSectionTitle('Select Venue', Icons.location_city),
                          const SizedBox(height: 15),
                        ],
                      ),
                    ),

                    Container(key: _venuesKey, child: _buildVenuesSection(activitiesDetailsController)),
                    const SizedBox(height: 30),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        children: [
                          _buildSectionTitle('Policies', Icons.security),
                          const SizedBox(height: 15),
                          _buildPoliciesSection(activitiesDetailsController),
                          const SizedBox(height: 30),
                          _buildSectionTitle('You Might Also Like', Icons.favorite_border),
                          const SizedBox(height: 15),
                        ],
                      ),
                    ),
                    _buildRelatedItems(activitiesDetailsController),

                    const SizedBox(height: 150),
                  ],
                ),
              );
            },
          ),
        ],
      ),

      // Fixed Book Button
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Consumer<ActivitiesDetailsController>(
        builder: (BuildContext context, activitiesDetailsController, child) {
          final isLoading = activitiesDetailsController.isLoading;

          if (isLoading) {
            return Container();
          }

          // Updated condition: Show BOOK NOW if any venue is selected
          // This ensures after auto-selection, the button changes to BOOK NOW
          final bool showBookNow = _selectedVenueIndex != -1;

          return GestureDetector(
            onTap: () {
              if (!showBookNow) {
                // Scroll to venues and auto-select first venue
                _scrollToVenues();
              } else {
                // Navigate to booking
                _navigateToBooking();
              }
            },
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: showBookNow
                      ? [Colors.blue, Colors.blueAccent]
                      : [Colors.blue.shade600, Colors.blue.shade400],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: showBookNow
                        ? Colors.blue.withOpacity(0.4)
                        : Colors.blue.withOpacity(0.4),
                    blurRadius: 15,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      showBookNow ? 'BOOK NOW' : 'SELECT VENUE',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                    SizedBox(width: 10),
                    Icon(
                      showBookNow ? Icons.arrow_circle_right_outlined : Icons.arrow_circle_up_rounded,
                      color: Colors.white,
                      size: 22,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDescriptionSection(ActivitiesDetailsController controller) {
    final description = widget.isEnglish ?  controller.activityDetailsModel?.data?.enEventAbout ?? '' :  controller.activityDetailsModel?.data?.hiEventAbout ?? '';
    final plainText = _getPlainText(description);
    final needViewMore = plainText.length > 300;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('About Activity', Icons.description_outlined),
        SizedBox(height: 12),

        Container(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Html(
                data: needViewMore && !_isDescriptionExpanded
                    ? _truncateHtml(description, 300)
                    : description,
              ),

              if (needViewMore)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _isDescriptionExpanded = !_isDescriptionExpanded;
                      });
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.blue.withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _isDescriptionExpanded ? 'Show Less' : 'Show More',
                            style: TextStyle(
                              color: Colors.blue,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                          SizedBox(width: 6),
                          Icon(
                            _isDescriptionExpanded
                                ? Icons.expand_less_rounded
                                : Icons.expand_more_rounded,
                            size: 18,
                            color: Colors.blue,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPoliciesSection(ActivitiesDetailsController controller) {
    final policies = [
      {
        'icon': Icons.cancel,
        'title': 'Why should you go',
        'description': widget.isEnglish ? controller.activityDetailsModel?.data?.enEventAttend ?? 'Not specified' : controller.activityDetailsModel?.data?.hiEventAttend ?? 'Not specified',
      },
      {
        'icon': Icons.person,
        'title': 'Activity schedule',
        'description': widget.isEnglish ? controller.activityDetailsModel?.data?.enEventSchedule ?? 'Not specified' : controller.activityDetailsModel?.data?.hiEventSchedule ?? 'Not specified',
      },
      {
        'icon': Icons.security,
        'title': 'Terms & Conditions',
        'description': widget.isEnglish ? controller.activityDetailsModel?.data?.enEventTeamCondition ?? 'Not specified' : controller.activityDetailsModel?.data?.hiEventTeamCondition ?? 'Not specified',
      },
    ];

    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: List.generate(policies.length, (index) {
          final policy = policies[index];
          final isExpanded = _policyExpandedStates[index];
          final descriptionText = policy['description'] as String; // Explicit cast
          final plainText = _getPlainText(descriptionText);
          final needViewMore = plainText.length > 150;

          return Column(
            children: [
              if (index > 0) ...[
                SizedBox(height: 16),
                Divider(color: Colors.grey.shade300, height: 1),
                SizedBox(height: 16),
              ],

              GestureDetector(
                onTap: () {
                  if (needViewMore) {
                    setState(() {
                      _policyExpandedStates[index] = !_policyExpandedStates[index];
                    });
                  }
                },
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            policy['title'] as String, // Explicit cast
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1A1A2E),
                            ),
                          ),
                          SizedBox(height: 8),

                          Html(
                            data: needViewMore && !isExpanded
                                ? _truncateHtml(descriptionText, 150)
                                : descriptionText,
                            style: {
                              "body": Style(
                                fontSize: FontSize(14),
                                color: Colors.grey.shade700,
                                lineHeight: LineHeight(1.5),
                              ),
                            },
                          ),

                          if (needViewMore)
                            Padding(
                              padding: const EdgeInsets.only(top: 6),
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _policyExpandedStates[index] = !_policyExpandedStates[index];
                                  });
                                },
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      isExpanded ? 'Show Less' : 'Read More',
                                      style: TextStyle(
                                        color: Colors.blue,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 13,
                                      ),
                                    ),
                                    SizedBox(width: 4),
                                    Icon(
                                      isExpanded
                                          ? Icons.keyboard_arrow_up_rounded
                                          : Icons.keyboard_arrow_down_rounded,
                                      size: 16,
                                      color: Colors.blue,
                                    ),
                                  ],
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
          );
        }),
      ),
    );
  }

  Widget _buildShimmerHeader() {
    return SliverAppBar(
      expandedHeight: 300,
      floating: false,
      pinned: false,
      automaticallyImplyLeading: false,
      flexibleSpace: FlexibleSpaceBar(
        background: Shimmer.fromColors(
          baseColor: Colors.grey.shade300,
          highlightColor: Colors.grey.shade100,
          child: Container(
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyHeader() {
    return SliverAppBar(
      expandedHeight: 250,
      floating: false,
      pinned: false,
      automaticallyImplyLeading: false,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          color: Colors.grey.shade100,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.image_not_supported_outlined,
                    size: 60, color: Colors.grey),
                SizedBox(height: 10),
                Text(
                  "No Images Available",
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContentShimmer() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Shimmer.fromColors(
        baseColor: Colors.grey.shade300,
        highlightColor: Colors.grey.shade100,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 20),

            // Interested Row
            Container(
              height: 20,
              width: 150,
              color: Colors.white,
            ),
            SizedBox(height: 20),

            // Description Title
            Container(
              height: 20,
              width: 120,
              color: Colors.white,
            ),
            SizedBox(height: 10),

            // Description Lines
            Container(height: 15, width: double.infinity, color: Colors.white),
            SizedBox(height: 8),
            Container(height: 15, width: double.infinity, color: Colors.white),
            SizedBox(height: 8),
            Container(height: 15, width: 200, color: Colors.white),
            SizedBox(height: 30),

            // Venue Title
            Container(
              height: 20,
              width: 140,
              color: Colors.white,
            ),
            SizedBox(height: 15),

            // Venue Cards
            SizedBox(
              height: 140,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: 3,
                itemBuilder: (_, __) {
                  return Container(
                    width: 200,
                    margin: EdgeInsets.only(right: 15),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                  );
                },
              ),
            ),

            SizedBox(height: 30),

            // Policies
            Container(
              height: 20,
              width: 100,
              color: Colors.white,
            ),
            SizedBox(height: 15),

            Container(height: 15, width: double.infinity, color: Colors.white),
            SizedBox(height: 8),
            Container(height: 15, width: double.infinity, color: Colors.white),

            SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyContent() {
    return SliverToBoxAdapter(
      child: Container(
        height: 400,
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event_busy_outlined, size: 70, color: Colors.grey),
            SizedBox(height: 15),
            Text("No Activity Details Found",
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInterestedSection(ActivitiesDetailsController controller) {
    return Consumer<ActivitiesInterestController>(
      builder: (context, interestController, child) {
        // Get current interest status from API data
        final apiInterestStatus = controller.activityDetailsModel?.data?.eventInterest ?? 0;

        // Sync the controller's state with API data whenever it changes
        WidgetsBinding.instance.addPostFrameCallback((_) {
          // Only update if the API status is different from current controller state
          if (interestController.isInterested != (apiInterestStatus == 1)) {
            interestController.setInitialStatus(apiInterestStatus);
          }
        });

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 10,
                offset: const Offset(0, 4),
              )
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              /// ================= LEFT SIDE =================
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'People Interested',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          '${controller.activityDetailsModel?.data?.eventInterested ?? 0}',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: Colors.blue.shade800,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Text(
                          "People",
                          style: TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                    const Text(
                      "have shown interest",
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),

              /// ================= DIVIDER =================
              Container(
                width: 1,
                height: 60,
                color: Colors.grey.shade200,
                margin: const EdgeInsets.symmetric(horizontal: 16),
              ),

              /// ================= RIGHT SIDE BUTTON =================
              Column(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: interestController.isInterested
                          ? Colors.green.shade50
                          : Colors.blue.shade50,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: interestController.isInterested
                            ? Colors.green
                            : Colors.blue.shade200,
                        width: 1.5,
                      ),
                    ),
                    child: interestController.isLoading
                        ? const Padding(
                      padding: EdgeInsets.all(14),
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                    )
                        : IconButton(
                      icon: Icon(
                        interestController.isInterested
                            ? Icons.favorite
                            : Icons.favorite_border_rounded,
                        color: interestController.isInterested
                            ? Colors.green
                            : Colors.blue,
                        size: 24,
                      ),
                      onPressed: interestController.isInterested
                          ? null  // Disable if already interested
                          : () async {
                        // Call the interested API
                        await interestController.interestedEvent(
                          eventId: controller
                              .activityDetailsModel
                              ?.data
                              ?.id ??
                              0,
                          userId: int.parse(userId),
                        );
                        await controller.fetchActivityDetails(widget.attractionName);
                      },
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    interestController.isInterested
                        ? "Interested"
                        : "Interest",
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: interestController.isInterested
                          ? Colors.green
                          : Colors.blue,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: Colors.blue, size: 20),
        ),
        SizedBox(width: 12),
        Text(
          title,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: Color(0xFF1A1A2E),
            letterSpacing: -0.5,
          ),
        ),
      ],
    );
  }

  Widget _buildRelatedItems(ActivitiesDetailsController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 12),
        SizedBox(
          height: 250,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 20),
            itemCount:
            controller.activityDetailsModel?.data?.remainingEvent.length ??
                0,
            itemBuilder: (context, index) {
              final event =
              controller.activityDetailsModel?.data?.remainingEvent[index];
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => TicketDetailsPage(
                            attractionName: '${event?.id}', isEnglish: widget.isEnglish,)));
                },
                child: Container(
                  width: 180,
                  margin: EdgeInsets.only(right: 16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: Colors.white,
                    border: Border.all(color: Colors.grey.shade200, width: 1),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Image Container with overlay
                      Expanded(
                        flex: 3,
                        child: Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.vertical(
                                top: Radius.circular(20),
                              ),
                              child: event?.eventImage != null
                                  ? Image.network(
                                event!.eventImage,
                                fit: BoxFit.cover,
                                width: double.infinity,
                                height: double.infinity,
                              )
                                  : Container(
                                color: Colors.grey.shade100,
                                child: Icon(
                                  Icons.event_available_outlined,
                                  size: 40,
                                  color: Colors.grey.shade400,
                                ),
                              ),
                            ),
                            // Price badge
                            Positioned(
                              top: 12,
                              left: 12,
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.blue,
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 4,
                                      offset: Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Text(
                                  '₹${event?.price ?? '0'}',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                            // Gradient overlay
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(20),
                                ),
                                gradient: LinearGradient(
                                  begin: Alignment.bottomCenter,
                                  end: Alignment.topCenter,
                                  colors: [
                                    Colors.black.withOpacity(0.3),
                                    Colors.transparent,
                                  ],
                                  stops: [0.1, 0.6],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Content
                      Expanded(
                        flex: 2,
                        child: Padding(
                          padding: EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.isEnglish ? event?.enEventName ?? 'Event Name' : event?.hiEventName ?? 'Event Name',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF1A1A2E),
                                      height: 1.2,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),

                              // View Details Button
                              Container(
                                width: double.infinity,
                                height: 30,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: Colors.blue.shade50,
                                  border: Border.all(
                                    color: Colors.blue.shade100,
                                    width: 1,
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    'Book Now',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.blue,
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
              );
            },
          ),
        ),
        SizedBox(height: 20),
      ],
    );
  }

  Widget _buildVenuesSection(ActivitiesDetailsController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 12),

        // Single row with list and fixed button
        SizedBox(
          height: 115,
          child: Row(
            children: [
              // Scrollable list of venues
              Expanded(
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: controller.activityDetailsModel?.data?.allVenueData.length ?? 0,
                  padding: EdgeInsets.only(left: 20),
                  physics: BouncingScrollPhysics(),
                  itemBuilder: (context, index) {
                    final venue = controller.activityDetailsModel?.data?.allVenueData[index];
                    bool isSelected = _selectedVenueIndex == index;

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedVenueIndex = index;
                          if (venue != null) {
                            selectedVenue = venue.enEventVenue;
                          }
                        });
                        HapticFeedback.lightImpact();
                      },
                      child: _buildVenueCard(venue, isSelected, index, widget.isEnglish),
                    );
                  },
                ),
              ),

              // Fixed See All button
              Container(
                width: 60,
                margin: EdgeInsets.symmetric(horizontal: 10),
                child: _buildSeeAllButton(controller),
              ),
            ],
          ),
        ),

        // Selected venue details
        if (_selectedVenueIndex != -1 &&
            controller.activityDetailsModel?.data?.allVenueData.isNotEmpty == true &&
            _selectedVenueIndex < controller.activityDetailsModel!.data!.allVenueData.length)
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.blue.shade100,
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 16,
                    color: Colors.blue.shade600,
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Selected: ${controller.activityDetailsModel!.data!.allVenueData[_selectedVenueIndex].enEventVenue}',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.blue.shade800,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

// See All button widget
  Widget _buildSeeAllButton(ActivitiesDetailsController controller) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        _showVenuesBottomSheet(controller);
      },
      child: Container(
        height: 115,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.blue.shade400,
              Colors.blue.shade600,
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.blue.withOpacity(0.3),
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [

            // Content
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.apps_outlined,
                      size: 24,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'See All',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    'Venues',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ),

            // Arrow indicator
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                padding: EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.3),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.arrow_forward_ios,
                  size: 10,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

// Bottom sheet method
  void _showVenuesBottomSheet(ActivitiesDetailsController controller) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: Offset(0, -5),
            ),
          ],
        ),
        child: Column(
          children: [
            // Header
            Container(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: Colors.grey.shade200,
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'All Venues',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A1A2E),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.close,
                        size: 20,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Grid of venues
            Expanded(
              child: GridView.builder(
                padding: EdgeInsets.all(20),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 1.5,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: controller.activityDetailsModel?.data?.allVenueData.length ?? 0,
                itemBuilder: (context, index) {
                  final venue = controller.activityDetailsModel?.data?.allVenueData[index];
                  bool isSelected = _selectedVenueIndex == index;

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedVenueIndex = index;
                        if (venue != null) {
                          selectedVenue = venue.enEventVenue;
                        }
                      });
                      HapticFeedback.lightImpact();
                      Navigator.pop(context);
                    },
                    child: _buildVenueCard(venue, isSelected, index, widget.isEnglish),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

// Venue card widget (extracted to avoid code duplication)
  Widget _buildVenueCard(dynamic venue, bool isSelected, int index, bool isEnglish) {
    return Container(
      width: 200,
      margin: EdgeInsets.only(right: 4),
      decoration: BoxDecoration(
        color: isSelected ? Colors.blue.shade50 :Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isSelected
              ? Colors.blue
              : Colors.grey.shade200,
          width: isSelected ? 2.5 : 1.5,
        ),
      ),
      child: Stack(
        children: [
          // Background pattern for selected state
          if (isSelected)
            Positioned(
              right: 0,
              top: 0,
              child: Opacity(
                opacity: 0.1,
                child: Icon(
                  Icons.location_on,
                  size: 60,
                  color: isSelected ? Colors.black : Colors.white,
                ),
              ),
            ),

            Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // City name with icon
                Row(
                  children: [
                    Icon(
                      Icons.location_city_outlined,
                      size: 16,
                      color: isSelected
                          ? Colors.black
                          : Colors.blue.shade500,
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        isEnglish ? venue?.enEventCities ?? 'City' : venue?.hiEventCities ?? 'City',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: isSelected
                              ? Colors.black
                              : Color(0xFF1A1A2E),
                          height: 1.2,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 6),

                // State with icon
                Row(
                  children: [
                    Icon(
                      Icons.place_outlined,
                      size: 14,
                      color: isSelected
                          ? Colors.black.withOpacity(0.9)
                          : Colors.grey.shade500,
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        isEnglish ? venue?.enEventState ?? 'State' : venue?.hiEventState ?? 'State',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: isSelected
                              ? Colors.black.withOpacity(0.9)
                              : Colors.grey.shade600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Selected indicator
          if (isSelected)
            Positioned(
              top: 10,
              right: 10,
              child: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Center(
                  child: Icon(
                    Icons.check_circle,
                    size: 16,
                    color: Colors.blue,
                  ),
                ),
              ),
            ),

          // Ripple effect overlay
          if (isSelected)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: RadialGradient(
                    center: Alignment(0.8, -0.8),
                    radius: 1.5,
                    colors: [
                      Colors.white.withOpacity(0.3),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

}