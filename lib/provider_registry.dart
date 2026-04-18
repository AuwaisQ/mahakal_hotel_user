import 'package:mahakal/features/astrotalk/controller/astrotalk_controller.dart';
import 'package:mahakal/theme/controllers/theme_controller.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

import 'call_service/call_service.dart';
import 'di_container.dart' as di;
import 'features/Tickit_Booking/controller/activites_order_details_controller.dart';
import 'features/Tickit_Booking/controller/activities_category_controller.dart';
import 'features/Tickit_Booking/controller/activities_details_controller.dart';
import 'features/Tickit_Booking/controller/activities_genlead_controller.dart';
import 'features/Tickit_Booking/controller/activities_interested_controller.dart';
import 'features/Tickit_Booking/controller/activities_list_controller.dart';
import 'features/Tickit_Booking/controller/activities_location_controller.dart';
import 'features/Tickit_Booking/controller/activity_order_list_controller.dart';
import 'features/Tickit_Booking/controller/activity_pass_controller.dart';
import 'features/Tickit_Booking/controller/tickit_availablity_controller.dart';
import 'features/Tickit_Booking/controller/tickit_booking_controller.dart';
import 'features/Tickit_Booking/controller/tickit_leadupdate_controller.dart';
import 'features/Tickit_Booking/controller/tickit_summery_controller.dart';
import 'features/address/controllers/address_controller.dart';
import 'features/auth/controllers/auth_controller.dart';
import 'features/banner/controllers/banner_controller.dart';
import 'features/blogs_module/Controller/Bookmark Provider.dart';
import 'features/blogs_module/Controller/ShareScreen.dart';
import 'features/blogs_module/Controller/language_provider.dart';
import 'features/brand/controllers/brand_controller.dart';
import 'features/cart/controllers/cart_controller.dart';
import 'features/category/controllers/category_controller.dart';
import 'features/chat/controllers/chat_controller.dart';
import 'features/checkout/controllers/checkout_controller.dart';
import 'features/compare/controllers/compare_controller.dart';
import 'features/contact_us/controllers/contact_us_controller.dart';
import 'features/coupon/controllers/coupon_controller.dart';
import 'features/deal/controllers/featured_deal_controller.dart';
import 'features/deal/controllers/flash_deal_controller.dart';
import 'features/donation/controller/lanaguage_provider.dart';
import 'features/event_booking/controller/event_auditorium_controller.dart';
import 'features/event_booking/controller/event_booking_controller.dart';
import 'features/event_booking/controller/event_leadupdate_controller.dart';
import 'features/event_booking/controller/event_package_controller.dart';
import 'features/hotels/controller/check_order_status_Controller.dart';
import 'features/hotels/controller/checkavailablity_controller.dart';
import 'features/hotels/controller/checkout_controller.dart';
import 'features/hotels/controller/featured_hotel_controller.dart';
import 'features/hotels/controller/form_submission_controller.dart';
import 'features/hotels/controller/hotel_details_controller.dart';
import 'features/hotels/controller/hotel_orderdetails_controller.dart';
import 'features/hotels/controller/hotel_orders_controller.dart';
import 'features/hotels/controller/hotel_user_controller.dart';
import 'features/hotels/controller/location_list_controller.dart';
import 'features/hotels/controller/share_hotel_controller.dart';
import 'features/hotels/controller/space_details_controller.dart';
import 'features/hotels/controller/spaces_list_controller.dart';
import 'features/hotels/controller/view_allhotel_controller.dart';
import 'features/hotels/controller/view_allspace_controller.dart';
import 'features/location/controllers/location_controller.dart';
import 'features/loyaltyPoint/controllers/loyalty_point_controller.dart';
import 'features/maha_bhandar/controller/hora_controller.dart';
import 'features/maha_bhandar/controller/share_panchang_controller.dart';
import 'features/mandir/controller/share_controller.dart';
import 'features/notification/controllers/notification_controller.dart';
import 'features/onboarding/controllers/onboarding_controller.dart';
import 'features/order/controllers/order_controller.dart';
import 'features/order_details/controllers/order_details_controller.dart';
import 'features/product/controllers/product_controller.dart';
import 'features/product/controllers/seller_product_controller.dart';
import 'features/product_details/controllers/product_details_controller.dart';
import 'features/profile/controllers/profile_contrroller.dart';
import 'features/refund/controllers/refund_controller.dart';
import 'features/reorder/controllers/re_order_controller.dart';
import 'features/review/controllers/review_controller.dart';
import 'features/sahitya/controller/audio_controller.dart';
import 'features/sahitya/controller/bookmark_provider.dart';
import 'features/sahitya/controller/settings_controller.dart';
import 'features/sahitya/controller/share_verse.dart';
import 'features/sahitya/view/hanuman_chalisa/chalisa_player.dart';
import 'features/sahitya/view/hanuman_chalisa/list_chalisa_player.dart';
import 'features/sahitya/view/hanuman_chalisa/share_hanumanchalisa.dart';
import 'features/sangeet/controller/audio_manager.dart';
import 'features/sangeet/controller/favourite_manager.dart';
import 'features/sangeet/controller/language_manager.dart';
import 'features/search_product/controllers/search_product_controller.dart';
import 'features/shipping/controllers/shipping_controller.dart';
import 'features/shop/controllers/shop_controller.dart';
import 'features/splash/controllers/splash_controller.dart';
import 'features/support/controllers/support_ticket_controller.dart';
import 'features/tour_and_travells/Controller/fetch_coupon_controller.dart';
import 'features/tour_and_travells/Controller/fetch_wallet_controller.dart';
import 'features/tour_and_travells/Controller/success_touramount_controller.dart';
import 'features/tour_and_travells/Controller/tour_lead_controller.dart';
import 'features/wallet/controllers/wallet_controller.dart';
import 'features/wishlist/controllers/wishlist_controller.dart';
import 'localization/controllers/localization_controller.dart';

final List<SingleChildWidget> providers = [
  ChangeNotifierProvider(create: (context) => di.sl<CallServiceProvider>()),
  ChangeNotifierProvider(create: (context) => di.sl<ProfileController>()),
  ChangeNotifierProvider(create: (context) => di.sl<LocationListController>()),
  ChangeNotifierProvider(create: (context) => di.sl<FeaturedHotelController>()),
  ChangeNotifierProvider(create: (context) => di.sl<ViewAllHotelController>()),
  ChangeNotifierProvider(create: (context) => di.sl<HotelDetailsController>()),
  ChangeNotifierProvider(create: (context) => di.sl<CheckavailablityController>()),
  ChangeNotifierProvider(create: (context) => di.sl<CheckOutController>()),
  ChangeNotifierProvider(create: (context) => di.sl<HotelUserController>()),
  ChangeNotifierProvider(create: (context) => di.sl<FormSubmissionController>()),
  ChangeNotifierProvider(create: (context) => di.sl<HotelOrderController>()),
  ChangeNotifierProvider(create: (context) => di.sl<SpacesListController>()),
  ChangeNotifierProvider(create: (context) => di.sl<ViewAllSpaceController>()),
  ChangeNotifierProvider(create: (context) => di.sl<SpaceDetailsController>()),
  ChangeNotifierProvider(create: (context) => di.sl<CheckOrderStatusController>()),
  ChangeNotifierProvider(create: (context) => di.sl<HotelOrderDetailsController>()),
  ChangeNotifierProvider(create: (context) => di.sl<ShareHotelController>()),
  ChangeNotifierProvider(create: (context) => di.sl<ActivitiesCategoryController>()),
  ChangeNotifierProvider(create: (context) => di.sl<ActivitiesLocationController>()),
  ChangeNotifierProvider(create: (context) => di.sl<ActivitiesListController>()),
  ChangeNotifierProvider(create: (context) => di.sl<ActivitiesDetailsController>()),
  ChangeNotifierProvider(create: (context) => di.sl<TickitSummeryController>()),
  ChangeNotifierProvider(create: (context) => di.sl<TickitAvailablityController>()),
  ChangeNotifierProvider(create: (context) => di.sl<LeadGenerateController>()),
  ChangeNotifierProvider(create: (context) => di.sl<UpdateLeadController>()),
  ChangeNotifierProvider(create: (context) => di.sl<TickitBookingController>()),
  ChangeNotifierProvider(create: (context) => di.sl<ActivitiesInterestController>()),
  ChangeNotifierProvider(create: (context) => di.sl<ActivitiesOrderController>()),
  ChangeNotifierProvider(create: (context) => di.sl<ActivitiesOrderDetailController>()),
  ChangeNotifierProvider(create: (context) => di.sl<ActivitiesPassController>()),
  ChangeNotifierProvider(create: (context) => di.sl<EventPackageController>()),
  ChangeNotifierProvider(create: (context) => di.sl<EventAuditoriumController>()),
  ChangeNotifierProvider(create: (context) => di.sl<EventLeadUpdateController>()),
  ChangeNotifierProvider(create: (context) => di.sl<EventBookingController>()),


  ChangeNotifierProvider(create: (context) => di.sl<BookmarkProvider>()),
  ChangeNotifierProvider(create: (context) => di.sl<SettingsProvider>()),
  ChangeNotifierProvider(create: (context) => di.sl<ShareVerse>()),
  ChangeNotifierProvider(create: (context) => di.sl<AudioPlayerManagerSahitya>()),
  ChangeNotifierProvider(create: (context) => di.sl<HoraController>()),
  ChangeNotifierProvider(create: (context) => di.sl<TourLeadController>()),
  ChangeNotifierProvider(create: (context) => di.sl<SuccessTourAmountController>()),
  ChangeNotifierProvider(create: (context) => di.sl<FetchCouponController>()),
  ChangeNotifierProvider(create: (context) => di.sl<FetchWalletController>()),
  ChangeNotifierProvider(create: (context) => di.sl<AudioPlayerManager>()),
  ChangeNotifierProvider(create: (context) => di.sl<BlogSaveProvider>()),
  ChangeNotifierProvider(create: (context) => di.sl<ShareBlogs>()),
  ChangeNotifierProvider(create: (context) => di.sl<BlogLanguageProvider>()),
  ChangeNotifierProvider(create: (context) => di.sl<FavouriteProvider>()),
  ChangeNotifierProvider(create: (context) => di.sl<LanguageManager>()),
  ChangeNotifierProvider(create: (context) => di.sl<LanguageProvider>()),
  ChangeNotifierProvider(create: (context) => di.sl<CategoryController>()),
  ChangeNotifierProvider(create: (context) => di.sl<ShopController>()),
  ChangeNotifierProvider(create: (context) => di.sl<FlashDealController>()),
  ChangeNotifierProvider(create: (context) => di.sl<FeaturedDealController>()),
  ChangeNotifierProvider(create: (context) => di.sl<BrandController>()),
  ChangeNotifierProvider(create: (context) => di.sl<ProductController>()),
  ChangeNotifierProvider(create: (context) => di.sl<BannerController>()),
  ChangeNotifierProvider(create: (context) => di.sl<ProductDetailsController>()),
  ChangeNotifierProvider(create: (context) => di.sl<OnBoardingController>()),
  ChangeNotifierProvider(create: (context) => di.sl<AuthController>()),
  ChangeNotifierProvider(create: (context) => di.sl<SearchProductController>()),
  ChangeNotifierProvider(create: (context) => di.sl<CouponController>()),
  ChangeNotifierProvider(create: (context) => di.sl<ChatController>()),
  ChangeNotifierProvider(create: (context) => di.sl<OrderController>()),
  ChangeNotifierProvider(create: (context) => di.sl<NotificationController>()),
  ChangeNotifierProvider(create: (context) => di.sl<WishListController>()),
  ChangeNotifierProvider(create: (context) => di.sl<SplashController>()),
  ChangeNotifierProvider(create: (context) => di.sl<CartController>()),
  ChangeNotifierProvider(create: (context) => di.sl<SupportTicketController>()),
  ChangeNotifierProvider(create: (context) => di.sl<LocalizationController>()),
  ChangeNotifierProvider(create: (context) => di.sl<ThemeController>()),
  ChangeNotifierProvider(create: (context) => di.sl<AddressController>()),
  ChangeNotifierProvider(create: (context) => di.sl<WalletController>()),
  ChangeNotifierProvider(create: (context) => di.sl<CompareController>()),
  ChangeNotifierProvider(create: (context) => di.sl<CheckoutController>()),
  ChangeNotifierProvider(create: (context) => di.sl<LoyaltyPointController>()),
  ChangeNotifierProvider(create: (context) => di.sl<LocationController>()),
  ChangeNotifierProvider(create: (context) => di.sl<ContactUsController>()),
  ChangeNotifierProvider(create: (context) => di.sl<ShippingController>()),
  ChangeNotifierProvider(create: (context) => di.sl<OrderDetailsController>()),
  ChangeNotifierProvider(create: (context) => di.sl<RefundController>()),
  ChangeNotifierProvider(create: (context) => di.sl<ReOrderController>()),
  ChangeNotifierProvider(create: (context) => di.sl<ReviewController>()),
  ChangeNotifierProvider(create: (context) => di.sl<SellerProductController>()),
  ChangeNotifierProvider(create: (context) => di.sl<ShareMusic>()),
  ChangeNotifierProvider(create: (context) => di.sl<ShareHanumanChalisa>()),
  ChangeNotifierProvider(create: (context) => di.sl<ChalisaPlayer>()),
  ChangeNotifierProvider(create: (context) => di.sl<ListChalisaPlayer>()),
  ChangeNotifierProvider(create: (context) => di.sl<SharePachangController>()),
  ChangeNotifierProvider(create: (context) => di.sl<SocketController>()),
];
