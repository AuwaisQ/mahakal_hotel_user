import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mahakal/features/loyaltyPoint/controllers/loyalty_point_controller.dart';
import 'package:mahakal/features/profile/controllers/profile_contrroller.dart';
import 'package:mahakal/features/profile/screens/profile_screen.dart';
import 'package:mahakal/features/support/screens/support_ticket_screen.dart';
import 'package:mahakal/features/wallet/controllers/wallet_controller.dart';
import 'package:mahakal/utill/app_constants.dart';
import 'package:mahakal/features/more/widgets/logout_confirm_bottom_sheet_widget.dart';
import 'package:mahakal/features/auth/screens/auth_screen.dart';
import 'package:mahakal/features/chat/screens/inbox_screen.dart';
import 'package:mahakal/localization/language_constrants.dart';
import 'package:mahakal/features/auth/controllers/auth_controller.dart';
import 'package:mahakal/features/splash/controllers/splash_controller.dart';
import 'package:mahakal/utill/custom_themes.dart';
import 'package:mahakal/utill/dimensions.dart';
import 'package:mahakal/utill/images.dart';
import 'package:mahakal/features/category/screens/category_screen.dart';
import 'package:mahakal/features/compare/screens/compare_product_screen.dart';
import 'package:mahakal/features/contact_us/screens/contact_us_screen.dart';
import 'package:mahakal/features/coupon/screens/coupon_screen.dart';
import 'package:mahakal/features/more/screens/html_screen_view.dart';
import 'package:mahakal/features/more/widgets/profile_info_section_widget.dart';
import 'package:mahakal/features/more/widgets/more_horizontal_section_widget.dart';
import 'package:mahakal/features/notification/screens/notification_screen.dart';
import 'package:mahakal/features/address/screens/address_list_screen.dart';
import 'package:mahakal/features/setting/screens/settings_screen.dart';
import 'package:provider/provider.dart';
import 'faq_screen_view.dart';
import 'package:mahakal/features/more/widgets/title_button_widget.dart';

class MoreScreen extends StatefulWidget {
  final ScrollController scrollController;
  const MoreScreen({super.key, required this.scrollController});
  @override
  State<MoreScreen> createState() => _MoreScreenState();
}

class _MoreScreenState extends State<MoreScreen> {
  late bool isGuestMode;
  String? version;
  bool singleVendor = false;
  final ScrollController scrollController = ScrollController();

  @override
  void initState() {
    isGuestMode =
        !Provider.of<AuthController>(context, listen: false).isLoggedIn();
    if (Provider.of<AuthController>(context, listen: false).isLoggedIn()) {
      version = Provider.of<SplashController>(context, listen: false)
              .configModel!
              .softwareVersion ??
          'version';
      Provider.of<ProfileController>(context, listen: false)
          .getUserInfo(context);
      if (Provider.of<SplashController>(context, listen: false)
              .configModel!
              .walletStatus ==
          1) {
        Provider.of<WalletController>(context, listen: false)
            .getTransactionList(context, 1, 'all');
      }
      if (Provider.of<SplashController>(context, listen: false)
              .configModel!
              .loyaltyPointStatus ==
          1) {
        Provider.of<LoyaltyPointController>(context, listen: false)
            .getLoyaltyPointList(context, 1);
      }
    }
    singleVendor = Provider.of<SplashController>(context, listen: false)
            .configModel!
            .businessMode ==
        "single";

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var splashController =
        Provider.of<SplashController>(context, listen: false);
    var authController = Provider.of<AuthController>(context, listen: false);
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: CustomScrollView(
        controller: widget.scrollController,
        slivers: [
          SliverAppBar(
              floating: true,
              elevation: 0,
              expandedHeight: 180,
              pinned: true,
              centerTitle: false,
              automaticallyImplyLeading: false,
              backgroundColor: Theme.of(context).primaryColor,
              collapsedHeight: 60,
              flexibleSpace: const FlexibleSpaceBar(
                background: ProfileInfoSectionWidget(),
              )),
          SliverToBoxAdapter(
            child: Container(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                        padding: EdgeInsets.only(top: Dimensions.paddingSizeDefault),
                        child: Center(child: MoreHorizontalSection())),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(
                          Dimensions.paddingSizeDefault,
                          Dimensions.paddingSizeLarge,
                          Dimensions.paddingSizeDefault,
                          Dimensions.paddingSizeSmall),
                      child: Text(
                        getTranslated('general', context) ?? '',
                        style: textBold.copyWith(
                            fontSize: Dimensions.fontSizeLarge,
                            color: Theme.of(context).primaryColor),
                      ),
                    ),
                    Padding(
                        padding:
                            const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
                        child: Container(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
                                boxShadow: [
                                  BoxShadow(
                                      color: Colors.black.withOpacity(0.05),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4))
                                ],
                                color: Theme.of(context).cardColor),
                            child: Column(children: [
                              if (Provider.of<AuthController>(context,
                                      listen: false)
                                  .isLoggedIn())
                                MenuButtonWidget(
                                    image: Images.user,
                                    title: getTranslated('profile', context),
                                    navigateTo: const ProfileScreen()),

                              MenuButtonWidget(
                                  image: Images.address,
                                  title: getTranslated('addresses', context),
                                  navigateTo: const AddressListScreen()),

                              MenuButtonWidget(
                                  image: Images.coupon,
                                  title: getTranslated('coupons', context),
                                  navigateTo: const CouponList()),

                              MenuButtonWidget(
                                  image: Images.category,
                                  title: getTranslated('CATEGORY', context),
                                  navigateTo: const CategoryScreen()),

                              if (splashController.configModel!.activeTheme !=
                                      "default" &&
                                  authController.isLoggedIn())
                                MenuButtonWidget(
                                    image: Images.compare,
                                    title: getTranslated(
                                        'compare_products', context),
                                    navigateTo: const CompareProductScreen()),

                              MenuButtonWidget(
                                  image: Images.notification,
                                  title: getTranslated(
                                    'notification',
                                    context,
                                  ),
                                  isNotification: true,
                                  navigateTo: const NotificationScreen()),

                              MenuButtonWidget(
                                  image: Images.settings,
                                  title: getTranslated('settings', context),
                                  navigateTo: const SettingsScreen())
                            ]))),
                    Padding(
                        padding: const EdgeInsets.fromLTRB(
                            Dimensions.paddingSizeDefault,
                            Dimensions.paddingSizeLarge,
                            Dimensions.paddingSizeDefault,
                            Dimensions.paddingSizeSmall),
                        child: Text(
                            getTranslated('help_and_support', context) ?? '',
                            style: textBold.copyWith(
                                fontSize: Dimensions.fontSizeLarge,
                                color: Theme.of(context).primaryColor)),),
                    Padding(
                        padding:
                            const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
                        child: Container(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
                                boxShadow: [
                                  BoxShadow(
                                      color: Colors.black.withOpacity(0.05),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4))
                                ],
                                color: Theme.of(context).cardColor),
                            child: Column(children: [
                              singleVendor
                                  ? const SizedBox()
                                  : MenuButtonWidget(
                                      image: Images.chats,
                                      title: getTranslated('inbox', context),
                                      navigateTo: InboxScreen(
                                        scrollController: scrollController,
                                      )),
                              MenuButtonWidget(
                                  image: Images.callIcon,
                                  title: getTranslated('contact_us', context),
                                  navigateTo: const ContactUsScreen()),
                              MenuButtonWidget(
                                  image: Images.preference,
                                  title:
                                      getTranslated('support_ticket', context),
                                  navigateTo: const SupportTicketScreen()),
                              MenuButtonWidget(
                                  image: Images.termCondition,
                                  title:
                                      getTranslated('terms_condition', context),
                                  navigateTo: HtmlViewScreen(
                                    title: getTranslated(
                                        'terms_condition', context),
                                    url: Provider.of<SplashController>(context,
                                            listen: false)
                                        .configModel!
                                        .termsConditions,
                                  )),
                              MenuButtonWidget(
                                  image: Images.privacyPolicy,
                                  title:
                                      getTranslated('privacy_policy', context),
                                  navigateTo: HtmlViewScreen(
                                    title: getTranslated(
                                        'privacy_policy', context),
                                    url: Provider.of<SplashController>(context,
                                            listen: false)
                                        .configModel!
                                        .privacyPolicy,
                                  )),
                              if (Provider.of<SplashController>(context,
                                          listen: false)
                                      .configModel!
                                      .refundPolicy!
                                      .status ==
                                  1)
                                MenuButtonWidget(
                                    image: Images.termCondition,
                                    title:
                                        getTranslated('refund_policy', context),
                                    navigateTo: HtmlViewScreen(
                                      title: getTranslated(
                                          'refund_policy', context),
                                      url: Provider.of<SplashController>(
                                              context,
                                              listen: false)
                                          .configModel!
                                          .refundPolicy!
                                          .content,
                                    )),
                              if (Provider.of<SplashController>(context,
                                          listen: false)
                                      .configModel!
                                      .returnPolicy!
                                      .status ==
                                  1)
                                MenuButtonWidget(
                                    image: Images.termCondition,
                                    title:
                                        getTranslated('return_policy', context),
                                    navigateTo: HtmlViewScreen(
                                      title: getTranslated(
                                          'return_policy', context),
                                      url: Provider.of<SplashController>(
                                              context,
                                              listen: false)
                                          .configModel!
                                          .returnPolicy!
                                          .content,
                                    )),
                              if (Provider.of<SplashController>(context,
                                          listen: false)
                                      .configModel!
                                      .cancellationPolicy!
                                      .status ==
                                  1)
                                MenuButtonWidget(
                                    image: Images.termCondition,
                                    title: getTranslated(
                                        'cancellation_policy', context),
                                    navigateTo: HtmlViewScreen(
                                      title: getTranslated(
                                          'cancellation_policy', context),
                                      url: Provider.of<SplashController>(
                                              context,
                                              listen: false)
                                          .configModel!
                                          .cancellationPolicy!
                                          .content,
                                    )),
                              MenuButtonWidget(
                                  image: Images.faq,
                                  title: getTranslated('faq', context),
                                  navigateTo: FaqScreen(
                                    title: getTranslated('faq', context),
                                  )),
                              MenuButtonWidget(
                                  image: Images.user,
                                  title: getTranslated('about_us', context),
                                  navigateTo: HtmlViewScreen(
                                    title: getTranslated('about_us', context),
                                    url: Provider.of<SplashController>(context,
                                            listen: false)
                                        .configModel!
                                        .aboutUs,
                                  ))
                            ]))),

                    const SizedBox(height: Dimensions.paddingSizeDefault),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
                      child: InkWell(
                        onTap: () {
                          if (isGuestMode) {
                            Navigator.push(
                                context,
                                CupertinoPageRoute(
                                    builder: (context) => const AuthScreen()));
                          } else {
                            showModalBottomSheet(
                                backgroundColor: Colors.transparent,
                                context: context,
                                builder: (_) =>
                                const LogoutCustomBottomSheetWidget());
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            color: isGuestMode ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                isGuestMode ? Icons.login : Icons.logout,
                                color: isGuestMode ? Colors.green : Colors.red,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                isGuestMode
                                    ? getTranslated('sign_in', context)!
                                    : getTranslated('sign_out', context)!,
                                style: textBold.copyWith(
                                  fontSize: Dimensions.fontSizeLarge,
                                  color: isGuestMode ? Colors.green : Colors.red,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Padding(
                        padding: const EdgeInsets.only(
                            bottom: Dimensions.paddingSizeDefault),
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                  '${getTranslated('version', context)} ${AppConstants.appVersion}',
                                  style: textRegular.copyWith(
                                      fontSize: Dimensions.fontSizeLarge,
                                      color: Theme.of(context).hintColor))
                            ]))
                  ]),
            ),
          )
        ],
      ),
    );
  }
}
