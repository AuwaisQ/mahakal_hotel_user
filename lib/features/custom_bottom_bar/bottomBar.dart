import 'package:expandable_bottom_sheet/expandable_bottom_sheet.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mahakal/features/astrotalk/screen/astro_bottombar.dart';
import 'package:mahakal/features/home/screens/home_screens.dart';
import 'package:mahakal/features/more/screens/more_screen_view.dart';
import 'package:hidable/hidable.dart';
import 'package:page_animation_transition/animations/bottom_to_top_transition.dart';
import 'package:page_animation_transition/page_animation_transition.dart';
import 'package:path/path.dart' as Get;
import 'package:provider/provider.dart';
import '../../common/basewidget/not_logged_in_bottom_sheet_widget.dart';
import '../../utill/dimensions.dart';
import '../auth/controllers/auth_controller.dart';
import '../dashboard/models/navigation_model.dart';
import '../explore/exploreScreen.dart';
import '../mandir/view/mandir.dart';
import '../pooja_booking/view/pooja_home.dart';
import 'customPainter.dart';
import '../../utill/app_constants.dart';

class BottomBar extends StatefulWidget {
  final int pageIndex;

  const BottomBar({super.key, required this.pageIndex});

  State<BottomBar> createState() => _BottomBarState();
}

class _BottomBarState extends State<BottomBar> {
  PageController? _pageController;
  final ScrollController exploreScrollController = ScrollController();
  final ScrollController orderScrollController = ScrollController();
  final ScrollController menuScrollController = ScrollController();
  final ScrollController moreScrollController = ScrollController();
  final ScrollController homeScrollController = ScrollController();
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
      ExploreScreen(scrollController: exploreScrollController),
      const SizedBox(),
      const SizedBox(),
      PoojaHomeView(tabIndex: 0, scrollController: orderScrollController),
      HomePage(scrollController: homeScrollController), // ✅ FIX
    ];
    _updateActiveScrollController();
  }

  void _updateActiveScrollController() {
    switch (_pageIndex) {
      case 0:
        activeScrollController = exploreScrollController;
        break;
      case 1:
        activeScrollController = moreScrollController;
        break;
      case 3:
        activeScrollController = orderScrollController;
        break;
      case 4:
        activeScrollController = homeScrollController;
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
                                  color: _pageIndex == 5
                                      ? Theme.of(context).cardColor
                                      : Theme.of(context).primaryColor,
                                ),
                              ),
                              backgroundColor: _pageIndex == 5
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
                                      page: const Mandir(tabIndex: 0),
                                      pageAnimationType:
                                          BottomToTopTransition(),
                                    ),
                                  );
                                }
                              },
                              elevation: 10,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(100),
                                child: Image.asset(
                                  'assets/animated/mandirmahakal animation.gif',
                                  height: 60,
                                ),
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
                                  title: 'Explore',
                                  iconData: Icons.dashboard,
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
                                  title: 'Astrologer',
                                  iconData: CupertinoIcons.chat_bubble,
                                  isSelected: _pageIndex == 1,
                                  onTap: () {

                                    //<<<------- Direct Navigation to Astro Bottom Bar ----->>>//
                                    // Navigator.push(
                                    //     context,
                                    //     CupertinoPageRoute(
                                    //         builder: (context) =>
                                    //             const AstroBottomBar(
                                    //               pageIndex: 1, initialIndex: 1,
                                    //             )),
                                    //   );

                                    //<<<<------- Conditional Navigation Based on Base URL ----->>>//
                                    if (AppConstants.baseUrl ==
                                            'https://uat.pavtr.in' ||
                                        AppConstants.baseUrl ==
                                            'https://sit.resrv.in') {
                                      Navigator.push(
                                        context,
                                        CupertinoPageRoute(
                                            builder: (context) =>
                                                const AstroBottomBar(
                                                  pageIndex: 1, initialIndex: 1,
                                                )),
                                      );
                                    } else {
                                      showDialog(
                                        context: context,
                                        builder: (context) => AlertDialog(
                                          title:
                                              const Text('Talk To Astorlogers'),
                                          content: const Text(
                                              'This feature is coming soon! Stay tuned for updates.'),
                                          actions: [
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.pop(context),
                                              child: const Text(
                                                'Close',
                                                style: TextStyle(
                                                    color: Colors.deepOrange),
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    }
                                  },
                                ),
                                BottomNavItem(
                                  title: 'Mandir',
                                  iconData: CupertinoIcons.minus,
                                  isSelected: _pageIndex == 5,
                                  onTap: () {
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
                                          page: const Mandir(tabIndex: 0),
                                          pageAnimationType:
                                              BottomToTopTransition(),
                                        ),
                                      );
                                    }
                                  },
                                ),
                                BottomNavItem(
                                  title: 'Pooja',
                                  iconData: Icons.temple_hindu_outlined,
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
                                  title: 'Shop',
                                  iconData: CupertinoIcons.cart_fill,
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
