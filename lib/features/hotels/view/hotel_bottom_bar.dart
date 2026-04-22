import 'package:expandable_bottom_sheet/expandable_bottom_sheet.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hidable/hidable.dart';
import 'package:mahakal/features/hotels/view/view_allhotel_page.dart';
import 'package:mahakal/features/hotels/view/view_allspaces_page.dart';
import 'package:mahakal/features/profile/controllers/profile_contrroller.dart';
import 'package:mahakal/main.dart';
import 'package:page_animation_transition/animations/bottom_to_top_transition.dart';
import 'package:page_animation_transition/page_animation_transition.dart';
import 'package:provider/provider.dart';
import '../../../common/basewidget/not_logged_in_bottom_sheet_widget.dart';
import '../../../utill/dimensions.dart';


/// ==========================
/// NoDataScreen Widget
/// ==========================
import 'package:flutter/material.dart';

import '../../custom_bottom_bar/bottomNamItem.dart';
import '../../custom_bottom_bar/customPainter.dart';
import 'hotel_orderlist_screen.dart';
import 'hotels_home_page.dart';

/// HotelBottomBar StatefulWidget
class HotelBottomBar extends StatefulWidget {
  final int pageIndex;

  const HotelBottomBar({
    super.key,
    required this.pageIndex,
  });

  @override
  State<HotelBottomBar> createState() => _HotelBottomBarState();
}

class _HotelBottomBarState extends State<HotelBottomBar> {
  PageController? _pageController;
  final ScrollController poojaScrollController = ScrollController();
  final ScrollController counsellingScrollController = ScrollController();
  final ScrollController chatScrollController = ScrollController();
  final ScrollController shopScrollController = ScrollController();
  final ScrollController eventScrollController = ScrollController();
  ScrollController? activeScrollController;
  int _pageIndex = 0;
  late List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    Provider.of<ProfileController>(Get.context!, listen: false)
        .getUserInfo(context);

    _pageIndex = widget.pageIndex;
    _pageController = PageController(initialPage: widget.pageIndex);

    /// Screens with ID checks
    _screens = [

      // Hotel Home Screen
      HotelHomeScreen(scrollController: poojaScrollController),

      // All Hotel Screen
      AllHotelsScreen(scrollController: counsellingScrollController),

      // Chat / Placeholder
      const SizedBox(),

      // Shop Screen
      AllSpacesScreen(scrollController: shopScrollController),

      // Event Screen
      HotelOrderListScreen(scrollController:eventScrollController)
      //BookingsScreen(scrollController: poojaScrollController),

    ];
    _updateActiveScrollController();
  }

  void _updateActiveScrollController() {
    switch (_pageIndex) {
      case 0:
        activeScrollController = poojaScrollController;
        break;
      case 1:
        activeScrollController = counsellingScrollController;
        break;
      case 3:
        activeScrollController = shopScrollController;
        break;
      case 4:
        activeScrollController = eventScrollController;
        break;
      default:
        activeScrollController = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return WillPopScope(
      onWillPop: () async {
        if (_pageIndex != 0) {
          _setPage(0);
          return false;
        }
        return false;
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
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
                        Center(
                          heightFactor: 0.6,
                          child: FloatingActionButton(
                            shape: CircleBorder(
                              side: BorderSide(
                                width: 2,
                                color: _pageIndex == 5
                                    ? Theme.of(context).cardColor
                                    : Theme.of(context).primaryColor,
                              ),
                            ),
                            backgroundColor: _pageIndex == 5
                                ? Theme.of(context).primaryColor
                                : Theme.of(context).cardColor,
                            onPressed: () {
                              Navigator.push(
                                context,
                                PageAnimationTransition(
                                  page: DraftOrdersPage(scrollController: chatScrollController),
                                  pageAnimationType: BottomToTopTransition(),
                                ),
                              );

                            },
                            elevation: 10,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(100),
                              child: Icon(
                                Icons.drafts,
                                color: _pageIndex == 5
                                    ? Theme.of(context).cardColor
                                    : Theme.of(context).primaryColor,
                                size: 30,
                              ),
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
                                  title: 'Home',
                                  iconData: Icons.home,
                                  isSelected: _pageIndex == 0,
                                  onTap: () => _setPage(0),
                                ),
                                BottomNavItem(
                                  title: 'Hotels',
                                  iconData: Icons.hotel,
                                  isSelected: _pageIndex == 1,
                                  onTap: () => _setPage(1),
                                ),
                                BottomNavItem(
                                  title: 'Draft',
                                  iconData: CupertinoIcons.minus,
                                  isSelected: _pageIndex == 5,
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      PageAnimationTransition(
                                        page: DraftOrdersPage(scrollController: chatScrollController),
                                        pageAnimationType: BottomToTopTransition(),
                                      ),
                                    );
                                  },
                                ),
                                BottomNavItem(
                                  title: 'Spaces',
                                  iconData: CupertinoIcons.sparkles,
                                  isSelected: _pageIndex == 3,
                                  onTap: () => _setPage(3),
                                ),
                                BottomNavItem(
                                  title: 'Bookings',
                                  iconData: Icons.bookmark_border,
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


class BookingsScreen extends StatelessWidget {
  final ScrollController? scrollController;

  const BookingsScreen({
    super.key,
    this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          controller: scrollController,
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'My Bookings',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E1E2C),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Your upcoming stays',
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xFF8E8E98),
                  ),
                ),
                const SizedBox(height: 40),
                Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.calendar_month_rounded,
                        size: 80,
                        color: Theme.of(context).primaryColor.withOpacity(0.5),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'No Bookings Yet',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1E1E2C),
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Book your first hotel stay',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF8E8E98),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}