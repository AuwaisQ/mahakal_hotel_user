import 'package:expandable_bottom_sheet/expandable_bottom_sheet.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mahakal/features/parking/view/parking_home_screen.dart';
import 'package:hidable/hidable.dart';
import 'package:page_animation_transition/animations/bottom_to_top_transition.dart';
import 'package:page_animation_transition/page_animation_transition.dart';
import 'package:provider/provider.dart';
import '../../common/basewidget/not_logged_in_bottom_sheet_widget.dart';
import '../Tickit_Booking/view/tickit_booking_home.dart';
import '../auth/controllers/auth_controller.dart';
import '../hotels/view/hotels_home_page.dart';
import '../self_drive/self_form_screen.dart';
import '../tour_and_travells/view/main_home_tour.dart';

class BottomBar extends StatefulWidget {
  final int pageIndex;

  const BottomBar({super.key, required this.pageIndex});

  State<BottomBar> createState() => _BottomBarState();
}

class _BottomBarState extends State<BottomBar> {
  PageController? _pageController;
  final ScrollController tourScrollController = ScrollController();
  final ScrollController orderScrollController = ScrollController();
  final ScrollController parkingScrollController = ScrollController();
  final ScrollController hotelScrollController = ScrollController();
  final ScrollController eventScrollController = ScrollController();
  ScrollController? activeScrollController;
  int _pageIndex = 0;
  late List<Widget> _screens;
  String? currentUuid;

  @override
  void initState() {
    super.initState();
    _pageIndex = widget.pageIndex;
    _pageController = PageController(initialPage: widget.pageIndex);
    _screens = [
      TourHomePage(scrollController: tourScrollController),
      TickitBookingHome(scrollController: eventScrollController),
      const SizedBox(),
      HotelHomeScreen(scrollController: hotelScrollController),
      const ParkingHomeScreen(),
    ];
    _updateActiveScrollController();
  }

  void _updateActiveScrollController() {
    switch (_pageIndex) {
      case 0:
        activeScrollController = tourScrollController;
        break;
      case 1:
        activeScrollController = eventScrollController;
        break;
      case 3:
        activeScrollController = hotelScrollController;
        break;
      case 4:
        activeScrollController = parkingScrollController;
        break;
      default:
        activeScrollController = null;
    }
  }


  @override
  Widget build(BuildContext context) {
    bool isGuestMode =
        !Provider.of<AuthController>(context, listen: false).isLoggedIn();
    return PopScope(
      canPop: _pageIndex == 0,
      onPopInvoked: (didPop) {
        if (!didPop && _pageIndex != 0) {
          _setPage(0);
        }
      },
      child: Scaffold(
        body: ExpandableBottomSheet(
          background: Stack(
            children: [
              PageView.builder(
                controller: _pageController,
                itemCount: _screens.length,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (index) {
                  setState(() {
                    _pageIndex = index;
                    _updateActiveScrollController();
                  });
                },
                itemBuilder: (context, index) => _screens[index],
              ),

              /// **Modern Floating Bottom Bar**
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Hidable(
                  controller: activeScrollController ?? ScrollController(),
                  preferredWidgetSize: const Size.fromHeight(100),
                  child: Container(
                    margin: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                    height: 70,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(35),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.12),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _ModernNavItem(
                          title: 'Tour',
                          iconData: Icons.travel_explore_rounded,
                          isSelected: _pageIndex == 0,
                          onTap: () {
                            if (isGuestMode) {
                              showModalBottomSheet(
                                  backgroundColor: Colors.transparent,
                                  context: context,
                                  builder: (_) => const NotLoggedInBottomSheetWidget());
                            } else {
                              _setPage(0);
                            }
                          },
                        ),
                        _ModernNavItem(
                          title: 'Activity',
                          iconData: Icons.confirmation_number_rounded,
                          isSelected: _pageIndex == 1,
                          onTap: () => _setPage(1),
                        ),
                        
                        // Center Premium FAB
                        GestureDetector(
                          onTap: () {
                            if (isGuestMode) {
                              showModalBottomSheet(
                                  backgroundColor: Colors.transparent,
                                  context: context,
                                  builder: (_) => const NotLoggedInBottomSheetWidget());
                            } else {
                              Navigator.push(
                                context,
                                PageAnimationTransition(
                                  page: const TripBookingPage(type: 'one-way'),
                                  pageAnimationType: BottomToTopTransition(),
                                ),
                              );
                            }
                          },
                          child: Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Colors.blueAccent, Colors.indigoAccent],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.blueAccent.withOpacity(0.4),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: const Icon(CupertinoIcons.car_detailed, color: Colors.white, size: 28),
                          ),
                        ),

                        _ModernNavItem(
                          title: 'Hotel',
                          iconData: Icons.location_city_rounded,
                          isSelected: _pageIndex == 3,
                          onTap: () {
                            if (isGuestMode) {
                              showModalBottomSheet(
                                  backgroundColor: Colors.transparent,
                                  context: context,
                                  builder: (_) => const NotLoggedInBottomSheetWidget());
                            } else {
                              _setPage(3);
                            }
                          },
                        ),
                        _ModernNavItem(
                          title: 'Parking',
                          iconData: Icons.local_parking_rounded,
                          isSelected: _pageIndex == 4,
                          onTap: () {
                            if (isGuestMode) {
                              showModalBottomSheet(
                                  backgroundColor: Colors.transparent,
                                  context: context,
                                  builder: (_) => const NotLoggedInBottomSheetWidget());
                            } else {
                              _setPage(4);
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          enableToggle: false,
          expandableContent: const SizedBox(height: 300),
        ),
      ),
    );
  }

  void _setPage(int pageIndex) {
    setState(() {
      _pageController!.jumpToPage(pageIndex);
      _pageIndex = pageIndex;
      _updateActiveScrollController();
    });
  }
}

class _ModernNavItem extends StatelessWidget {
  final IconData iconData;
  final String title;
  final VoidCallback onTap;
  final bool isSelected;

  const _ModernNavItem({
    required this.iconData,
    required this.title,
    required this.onTap,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blueAccent.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              iconData,
              color: isSelected ? Colors.blueAccent : Colors.grey.shade400,
              size: isSelected ? 24 : 22,
            ),
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                title,
                style: TextStyle(
                  color: isSelected ? Colors.blueAccent : Colors.grey.shade500,
                  fontSize: 10,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
