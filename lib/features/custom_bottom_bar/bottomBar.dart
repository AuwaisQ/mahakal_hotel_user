import 'package:expandable_bottom_sheet/expandable_bottom_sheet.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mahakal/features/more/screens/more_screen_view.dart';
import 'package:hidable/hidable.dart';
import 'package:page_animation_transition/animations/bottom_to_top_transition.dart';
import 'package:page_animation_transition/page_animation_transition.dart';
import 'package:provider/provider.dart';
import '../../common/basewidget/not_logged_in_bottom_sheet_widget.dart';
import '../../utill/dimensions.dart';
import '../Tickit_Booking/view/tickit_booking_home.dart';
import '../auth/controllers/auth_controller.dart';
import '../dashboard/models/navigation_model.dart';
import '../event_booking/view/home_page/event_home.dart';
import '../hotels/view/hotels_home_page.dart';
import '../self_drive/self_form_screen.dart';
import '../tour_and_travells/view/main_home_tour.dart';
import 'customPainter.dart';
import '../../utill/app_constants.dart';

class BottomBar extends StatefulWidget {
  final int pageIndex;

  const BottomBar({super.key, required this.pageIndex});

  State<BottomBar> createState() => _BottomBarState();
}

class _BottomBarState extends State<BottomBar> {
  PageController? _pageController;
  final ScrollController tourScrollController = ScrollController();
  final ScrollController orderScrollController = ScrollController();
  final ScrollController menuScrollController = ScrollController();
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
      MoreScreen(scrollController: menuScrollController),
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
        activeScrollController = menuScrollController;
        break;
      default:
        activeScrollController = null;
    }
  }


  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
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

              /// **Bottom Bar with Hide/Unhide on Scroll**
              Hidable(
                controller: activeScrollController ?? ScrollController(),
                preferredWidgetSize: MediaQuery.of(context).size,
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: SizedBox(
                    width: size.width,
                    height: 95,
                    child: Stack(
                      children: [
                        CustomPaint(
                          size: Size(size.width, 95),
                          painter: BNBCustomPainter(context: context),
                        ),

                        //Floating Button
                        Center(
                          heightFactor: 0.6,
                          child: SizedBox(
                            height: 65,
                            width: 65,
                            child: FloatingActionButton(
                              shape: CircleBorder(
                                side: BorderSide(
                                  width: 2,
                                  color: _pageIndex == 2
                                      ? Theme.of(context).cardColor
                                      : Theme.of(context).primaryColor,
                                ),
                              ),
                              backgroundColor: _pageIndex == 2
                                  ? Theme.of(context).primaryColor
                                  : Theme.of(context).cardColor,
                              onPressed: () {
                                if (isGuestMode) {
                                  showModalBottomSheet(
                                      backgroundColor: Colors.transparent,
                                      context: context,
                                      builder: (_) =>
                                          const NotLoggedInBottomSheetWidget());
                                } else {
                                  Navigator.push(
                                    context,
                                    PageAnimationTransition(
                                      page:  TripBookingPage(type: 'one-way',),
                                      pageAnimationType:
                                          BottomToTopTransition(),
                                    ),
                                  );
                                }
                              },
                              elevation: 10,
                              child: Icon(CupertinoIcons.car_detailed,size: 30,color: Colors.deepOrange,),
                              // child: ClipRRect(
                              //   borderRadius: BorderRadius.circular(100),
                              //   child: Image.asset(
                              //     'assets/animated/mandirmahakal animation.gif',
                              //     height: 60,
                              //   ),
                              // ),
                            ),
                          ),
                        ),

                        Center(
                          child: Container(
                            margin: const EdgeInsets.only(
                                top: Dimensions.paddingSizeDefault),
                            width: size.width,
                            height: 95,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                BottomNavItem(
                                  title: 'Tour',
                                  iconData: Icons.travel_explore,
                                  isSelected: _pageIndex == 0,
                                  // onTap: () => _setPage(0),
                                  onTap: () {
                                    if (isGuestMode) {
                                      showModalBottomSheet(
                                          backgroundColor: Colors.transparent,
                                          context: context,
                                          builder: (_) =>
                                              const NotLoggedInBottomSheetWidget());
                                    } else {
                                      _setPage(0);
                                    }
                                  },
                                ),
                                BottomNavItem(
                                  title: 'Event',
                                  iconData: Icons.event,
                                  isSelected: _pageIndex == 1,
                                  onTap: ()=> _setPage(1),
                                ),
                                BottomNavItem(
                                  title: 'Cab',
                                  iconData: CupertinoIcons.minus,
                                  isSelected: _pageIndex == 2,
                                  onTap: (){
                                    if (isGuestMode) {
                                      showModalBottomSheet(
                                          backgroundColor: Colors.transparent,
                                          context: context,
                                          builder: (_) =>
                                          const NotLoggedInBottomSheetWidget());
                                    } else {
                                      Navigator.push(
                                        context,
                                        PageAnimationTransition(
                                          page:  const TripBookingPage(type: 'one-way',),
                                          pageAnimationType:
                                          BottomToTopTransition(),
                                        ),
                                      );
                                    }
                                  }
                                ),
                                BottomNavItem(
                                  title: 'Hotel',
                                  iconData: Icons.location_city,
                                  isSelected: _pageIndex == 3,
                                  // onTap: () => _setPage(3),
                                  onTap: () {
                                    if (isGuestMode) {
                                      showModalBottomSheet(
                                          backgroundColor: Colors.transparent,
                                          context: context,
                                          builder: (_) =>
                                              const NotLoggedInBottomSheetWidget());
                                    } else {
                                      _setPage(3);
                                    }
                                  },
                                ),
                                BottomNavItem(
                                  title: 'Menu',
                                  iconData: Icons.menu,
                                  isSelected: _pageIndex == 4,
                                  onTap: () => _setPage(4),
                                ),
                              ],
                            ),
                          ),
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
