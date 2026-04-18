import 'dart:async';
import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:country_picker/country_picker.dart';
import 'package:delayed_display/delayed_display.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hidable/hidable.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:mahakal/call_service/call_service.dart';
import 'package:mahakal/common/basewidget/custom_image_widget.dart';
import 'package:mahakal/features/Akhand_jyoti/model/running_jyoti_model.dart';
import 'package:mahakal/features/astrotalk/screen/astro_bottombar.dart';
import 'package:mahakal/features/explore/rashifalModel.dart';
import 'package:mahakal/features/explore/screens/explore_mahakal_banners.dart';
import 'package:mahakal/features/explore/screens/explore_pandit.dart';
import 'package:mahakal/features/explore/screens/explore_shopcategory_grid.dart';
import 'package:mahakal/features/explore/screens/paid_services_grid.dart';
import 'package:mahakal/features/explore/screens/section_feature_product.dart';
import 'package:mahakal/features/explore/screens/section_mandir_darshan.dart';
import 'package:mahakal/features/explore/screens/section_read_blog.dart';
import 'package:mahakal/features/explore/screens/section_upcoming_event.dart';
import 'package:mahakal/features/explore/screens/section_video_serials.dart';
import 'package:mahakal/features/janm_kundli/screens/kundliForm.dart';
import 'package:mahakal/features/maha_bhandar/screen/maha_bhandar_screen.dart';
import 'package:mahakal/features/more/screens/more_screen_view.dart';
import 'package:mahakal/features/pooja_booking/view/pooja_home.dart';
import 'package:mahakal/features/product/domain/models/product_model.dart';
import 'package:mahakal/features/product/enums/product_type.dart';
import 'package:mahakal/features/youtube_vedios/model/subcategory_model.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:page_animation_transition/animations/left_to_right_transition.dart';
import 'package:page_animation_transition/animations/right_to_left_transition.dart';
import 'package:page_animation_transition/page_animation_transition.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import 'package:tdk_bouncingwidget/tdk_bouncingwidget.dart';
import '../../common/basewidget/rating_bar_widget.dart';
import '../../data/datasource/remote/http/httpClient.dart';
import '../../helper/price_converter.dart';
import '../../helper/responsive_helper.dart';
import '../../localization/language_constrants.dart';
import '../../main.dart';
import '../../utill/app_constants.dart';
import '../../utill/color_resources.dart';
import '../../utill/custom_themes.dart';
import '../../utill/dimensions.dart';
import '../../utill/images.dart';
import '../Jaap/screen/jaap.dart';
import '../Tickit_Booking/view/tickit_booking_home.dart';
import '../all_pandit/All_Pandit.dart';
import '../astrology/astrologyview.dart';
import '../astrology/component/astro_consultation.dart';
import '../astrology/component/astrodetailspage.dart';
import '../astrology/component/pdfdata_screen.dart';
import '../astrology/component/shubhmuhurat.dart';
import '../astrology/model/shubhmuhuratmodel.dart';
import '../auth/controllers/auth_controller.dart';
import '../banner/controllers/banner_controller.dart';
import '../blogs_module/model/SubCategory_model.dart';
import '../blogs_module/no_image_widget.dart';
import '../blogs_module/view/BlogHomePage.dart';
import '../cart/controllers/cart_controller.dart';
import '../category/controllers/category_controller.dart';
import '../category/screens/category_screen.dart';
import '../category/widgets/category_shimmer_widget.dart';
import '../donation/model/advertisement_model.dart';
import '../donation/ui_helper/custom_colors.dart';
import '../donation/view/home_page/Donation_Home/donation_home_view.dart';
import '../event_booking/model/subCategory_model.dart';
import '../event_booking/view/home_page/event_home.dart';
import '../home/shimmers/latest_product_shimmer.dart';
import '../hotels/controller/hotel_user_controller.dart';
import '../hotels/view/hotel_bottom_bar.dart';
import '../hotels/view/hotels_home_page.dart';
import '../kundli_milan/kundalimatching.dart';
import '../lalkitab/lalkitabform.dart';
import '../maha_bhandar/model/city_model.dart';
import '../maha_bhandar/screen/panchang_screen.dart';
import '../mandir/api_service/api_service.dart';
import '../mandir_darshan/mandir_form_user.dart';
import '../mandir_darshan/mandirhome.dart';
import '../mandir_darshan/model/darshan_category_model.dart';
import '../notification/controllers/notification_controller.dart';
import '../notification/screens/notification_screen.dart';
import '../numerology/numerohome.dart';
import '../offline_pooja/model/category_model.dart';
import '../offline_pooja/view/OfflinePoojaHome.dart';
import '../pooja_booking/model/categorymodel.dart';
import '../pooja_booking/view/chadhavadetails.dart';
import '../product/controllers/product_controller.dart';
import '../product/screens/brand_and_category_product_screen.dart';
import '../product/screens/view_all_product_screen.dart';
import '../product_details/screens/product_details_screen.dart';
import '../profile/controllers/profile_contrroller.dart';
import '../ram_shalakha/ram_shalaka.dart';
import '../rashi_fal/rsahi_fal_screen.dart';
import '../sahitya/model/sahitya_category_model.dart';
import '../sahitya/view/gita_chapter/gitastatic.dart';
import '../sahitya/view/hanuman_chalisa/hanuman_chalisa_screen.dart';
import '../sahitya/view/sahitya_home/sahitya_home.dart';
import '../sahitya/view/sahitya_pages/bhai_dooj_vrat.dart';
import '../sahitya/view/sahitya_pages/chath_pooja.dart';
import '../sahitya/view/sahitya_pages/dasha_mata.dart';
import '../sahitya/view/sahitya_pages/gangaur_katha.dart';
import '../sahitya/view/sahitya_pages/govardhan_pooja.dart';
import '../sahitya/view/sahitya_pages/hartalika_teej.dart';
import '../sahitya/view/sahitya_pages/haryali_teej.dart';
import '../sahitya/view/sahitya_pages/holi_vrat.dart';
import '../sahitya/view/sahitya_pages/janmaasthami.dart';
import '../sahitya/view/sahitya_pages/kartik_purneema.dart';
import '../sahitya/view/sahitya_pages/karwa_choth.dart';
import '../sahitya/view/sahitya_pages/mangalvar_vrat.dart';
import '../sahitya/view/sahitya_pages/nag_panchmi.dart';
import '../sahitya/view/sahitya_pages/narshima_vrat.dart';
import '../sahitya/view/sahitya_pages/pashupati_vrat.dart';
import '../sahitya/view/sahitya_pages/rishi_panchami.dart';
import '../sahitya/view/sahitya_pages/shanivar_vrat.dart';
import '../sahitya/view/sahitya_pages/sharad_purneema.dart';
import '../sahitya/view/sahitya_pages/sheetla_mata.dart';
import '../sahitya/view/sahitya_pages/shravan_somawar.dart';
import '../sahitya/view/sahitya_pages/shri_suktam.dart';
import '../sahitya/view/sahitya_pages/vaibhav_laxmi.dart';
import '../sahitya/view/sahitya_pages/vat_savitri_katha.dart';
import '../sangeet/model/category_model.dart' hide CategoryModel;
import '../sangeet/view/sangeet_home/sangit_home.dart';
import '../self_drive/self_form_screen.dart';
import '../shop/controllers/shop_controller.dart';
import '../shop/screens/shop_screen.dart';
import '../splash/controllers/splash_controller.dart';
import '../tour_and_travells/model/new_tours_model.dart';
import '../tour_and_travells/view/TourDetails.dart';
import '../tour_and_travells/view/main_home_tour.dart';
import '../wishlist/controllers/wishlist_controller.dart';
import '../youtube_vedios/model/categories_model.dart';
import '../youtube_vedios/model/newtabs_model.dart';
import '../youtube_vedios/view/dynamic_tabview/Youtube_Home_Page.dart';
import '../youtube_vedios/view/tabsscreenviews/Playlist_Tab_Screen.dart';
import 'model/categorylist_model.dart';
import 'model/chadavamodel.dart';
import 'model/pooja_suggestion_model.dart';
import 'model/sectionmodel.dart';
import 'screens/explore_astrology_grid.dart';
import 'screens/explore_astrotalk_grid.dart';
import 'screens/explore_mandir_grid.dart';
import 'screens/explore_music_grid.dart';
import 'screens/explore_panchang_grid.dart';
import 'screens/explore_pooja_grid.dart';
import 'screens/explore_sahitya_grid.dart';
import 'screens/explore_video_grid.dart';
import 'screens/section_astrology.dart';
import 'screens/section_categories.dart';
import 'screens/section_devotional_movies.dart';
import 'screens/section_donation.dart';
import 'screens/section_live_darshan.dart';
import 'screens/section_panchang.dart';
import 'screens/section_pooja_booking.dart';
import 'screens/section_rashifal.dart';
import 'screens/section_sangeet.dart';
import 'screens/section_spiritual.dart';

class ExploreScreen extends StatefulWidget {
  final ScrollController scrollController;

  const ExploreScreen({super.key, required this.scrollController});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  bool _isLoading = false;
  bool isLoading = false;
  bool isTranslate = false;
  bool isPanchang = false;
  DateTime birthDate = DateTime.now();
  String birthHour = '';
  String birthMinute = '';
  String? userId;
  int dialogIndex = 0;
  String orignalNo = '';
  String anukulMantraVar = '';
  String anukulTimeVar = '';
  String subhVratVar = '';
  String anukulDev = '';

  //Rashi namak data
  String rashinamakRashi = '';
  String rashinamakAlphabet = '';

  //Pryayer data
  String poojasuggestion = '';

  //Kaal sarp data
  String kaalSarpDoshline = '';

  // Pitr dosh data
  String pitrConclusion = '';
  String pitrTrueFalse = '';
  String pitrmessage = '';

  //ratna suggestion data life gems
  String lifeGemsName = '';
  String lifeGemsFinger = '';
  String lifeGemsWeight = '';
  String lifeGemsDay = '';
  String lifeGemsDeity = '';
  String lifeGemsMetal = '';

  //ratna suggestion data benefic gems
  String beneficGemsName = '';
  String beneficGemsFinger = '';
  String beneficGemsWeight = '';
  String beneficGemsDay = '';
  String beneficGemsDeity = '';
  String beneficGemsMetal = '';

  //ratna suggestion data lucky gems
  String luckyGemsName = '';
  String luckyGemsFinger = '';
  String luckyGemsWeight = '';
  String luckyGemsDay = '';
  String luckyGemsDeity = '';
  String luckyGemsMetal = '';

  // rudraksha data
  String rudrakshaImage = '';
  String rudrakshaName = '';
  String rudrakshaRecommend = '';
  String rudrakshaDetail = '';

  // Vimshottari data
  String vimshottariPlanet1 = '';
  String vimshottariPlanet2 = '';
  String vimshottariPlanet3 = '';
  String vimshottariPlanet4 = '';
  String vimshottariPlanet5 = '';
  String vimshottariStart1 = '';
  String vimshottariStart2 = '';
  String vimshottariStart3 = '';
  String vimshottariStart4 = '';
  String vimshottariStart5 = '';
  String vimshottariEnd1 = '';
  String vimshottariEnd2 = '';
  String vimshottariEnd3 = '';
  String vimshottariEnd4 = '';
  String vimshottariEnd5 = '';

  final oneKey = GlobalKey();
  final twoKey = GlobalKey();
  final threeKey = GlobalKey();
  final fourKey = GlobalKey();
  final fiveKey = GlobalKey();
  final sixKey = GlobalKey();
  final sevenKey = GlobalKey();
  final eightKey = GlobalKey();
  final nineKey = GlobalKey();
  final tenKey = GlobalKey();
  final elevenKey = GlobalKey();
  final tweleveKey = GlobalKey();
  final thirteenKey = GlobalKey();
  final fourteenKey = GlobalKey();

  //Manglik data
  List manglikBased_on_aspect = [];
  List manglikBased_on_house = [];
  String manglikStatus = '';
  String manglikPercent = '';
  String manglikReport = '';
  String calculatorLat = '';
  String calculatorLong = '';
  String janmJankariLat = '';
  String janmJankariLong = '';
  String countryDefault = '';
  String selectedGender = 'Gender';
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();
  final TextEditingController countryController = TextEditingController();

  List<CityPickerModel> cityListModel = <CityPickerModel>[];
  List<RashiComponentModel> rashiList = <RashiComponentModel>[];
  List<DarshanData> darshanCategoryModelList = <DarshanData>[];
  List<Chadhavadetail> chadhavaModelList = <Chadhavadetail>[];
  List<Sectionlist> sectionModelList = <Sectionlist>[];
  List<Category> categoryModelList = <Category>[];
  List<SangeetCategory> sangeetModelList = <SangeetCategory>[];
  List<GetPoojaCategory> categoryPoojaModelList = <GetPoojaCategory>[];
  List<CategoriesModel> category = [];
  List<DarshanData> consultaionModelList = <DarshanData>[];
  List<Muhurat> muhuratModelList = <Muhurat>[];
  var sahityaList = <SahityaData>[];
  List<OfflineCategory> offlineCategoryList = [];

  /// Get Blogs SubCategory
  List<BlogSubCategoryData> subCategoryList = [];
  List<BlogSubCategoryData> latestBlogs = [];

  /// Fetch New Tours
  List<NewToursData> _newToursList = [];

  /// Donation on Explore
  List<AdvertiseMent> getAds = [];

  /// Fetch Event SubCategory(NearByData)
  List<SubData> nearbyEvents = [];
  // Check Diya Status
  RunningJyotiModel? runningJyotiData;
  DateTime now = DateTime.now();
  bool gridList = false;
  bool isScrolling = false;
  SectionModel? sectionData;
  Category? categoryList;

  /// Live youtube Videos
  DynamicTabs? dynamicTabs;
  List<Video> allVideos = [];
  var lat;
  var long;
  var tithiName = '';
  var address1 = '';
  var address2 = '';
  late StreamSubscription<Position> streamSubscription;

  /// SubCategory API of Youtube videos
  List<KathaModel> subcategory = [];
  List<KathaModel> subcategoryMovies = [];
  List<KathaModel> subcategorySerials = [];
// In your state class
  final ScrollController _scrollController = ScrollController();
  bool _autoScrollActive = true;
  bool _userInteracting = false;
  double _scrollPosition = 0.0;
  int _maleValue = 1;

  Future<void> seactionSwitch() async {
    Provider.of<CategoryController>(context, listen: false)
        .getCategoryList(false);
    var response = await HttpService().getApi(AppConstants.sectionSwitcherUrl);
    List sectionList = response['data'];
    sectionModelList.addAll(sectionList.map((e) => Sectionlist.fromJson(e)));
    setState(() {});
  }

  Future<void> getConsultaionData() async {
    var res = await HttpService().getApi(AppConstants.consultaionUrl);
    if (res['status'] == 200) {
      setState(() {
        // consultaionModelList.clear();
        List consultationList = res['data'];
        consultaionModelList
            .addAll(consultationList.map((e) => DarshanData.fromJson(e)));
      });
    } else {
      print('Failed Api Response');
    }
  }

  Future<void> getmuhuratData() async {
    var res = await HttpService().getApi(AppConstants.shubhmuhuratUrl);
    if (res['status'] == 200) {
      setState(() {
        // muhuratModelList.clear();
        List shubhmuhuratList = res['data'];
        muhuratModelList
            .addAll(shubhmuhuratList.map((e) => Muhurat.fromJson(e)));
      });
    } else {
      print('Failed Api Response');
    }
  }

  int? getIdByNamMuhurat(String name) {
    var matchingItem = muhuratModelList.firstWhere(
      (item) => item.enName == name,
    );
    print(matchingItem.id);
    return matchingItem.id;
  }

  int? getIdByName(String name) {
    var matchingItem = consultaionModelList.firstWhere(
      (item) => item.enName == name,
    );
    print(matchingItem.id);
    return matchingItem.id;
  }

  Future<void> _fetchData() async {
    try {
      final data = await getList(178);
      dynamicTabs = data;
      // Extract videos from dynamicTabs and add to allVideos
      allVideos = _extractVideos(dynamicTabs);
      print('All Videos length is ${allVideos.length}');
      setState(() {});
    } catch (e) {
      print('Error fetching data: $e');
    }
  }

  List<Video> _extractVideos(DynamicTabs? dynamicTabs) {
    List<Video> videos = [];

    if (dynamicTabs != null) {
      for (var category in dynamicTabs.data) {
        // Check if playlistName and listType are null at the category level
        if (category.playlistName == null && category.listType == null) {
          for (var video in category.videos) {
            videos.add(Video(
              title: video.title,
              url: video.url,
              image: video.image,
              urlStatus: video
                  .urlStatus, // Assuming urlStatus is a property in the Video class
            ));
          }
        }
      }
    }
    return videos;
  }

  Future<DynamicTabs> getList(int subCategory) async {
    final url =
        '${AppConstants.baseUrl}${AppConstants.youtubeAllVideosUrl}$subCategory';

    var response = await ApiService().getPlayList(url);
    return DynamicTabs.fromJson(response);
  }

  Future<void> getEventSubCategory() async {
    String url = AppConstants.baseUrl + AppConstants.eventSubCategoryUrl;

    Map<String, dynamic> nearData = {
      'category_id': [],
      'venue_data': [],
      'price': [],
      'language': [],
      'organizer': [],
      'upcoming': 1,
      'latitude': '',
      'longitude': ''
      // "latitude": Provider.of<AuthController>(context, listen: false).latitude,
      // "longitude": Provider.of<AuthController>(context, listen: false).longitude
    };

    try {
      final res = await ApiService().postData(url, nearData);

      if (res != null) {
        final nearbyData = SubCategoryModel.fromJson(res);

        setState(() {
          nearbyEvents = nearbyData.data;
          print('Near Events Data ${nearbyEvents.length}');
        });
      }
    } catch (e) {
      print('Eorror Occuring $e');
    }
  }

  Future<void> getAdvertiseMent() async {
    // String url = '${AppConstants.baseUrl}/api/v1/donate/donatetrust';
    Map<String, dynamic> data = {
      'type': 'ads',
      'trust_category_id': '',
    };

    setState(() {
      _isLoading = true;
    });

    try {
      final res =
          await HttpService().postApi(AppConstants.donationAdsUrl, data);
      // final Map<String, dynamic> res = await ApiServiceDonate().getAdvertise(url, data);

      if (res.containsKey('status') &&
          res.containsKey('message') &&
          res.containsKey('data') &&
          res['data'] != null) {
        final getAdvertiseData = AdvertisementModel.fromJson(res);

        setState(() {
          getAds = getAdvertiseData.data;
          print('${getAds.length}');
        });
      } else {
        print('Error in Advertisement');
      }
    } catch (e) {
      print(e);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  List<String> bookNameList = [
    'Geeta',
    'Upnishad',
    'Mahabharat',
    'ShivPuran',
    'Ramayan'
  ];

  void showComingDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Coming Soon!'),
        content: const Text('This feature is currently in development.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void handleNavActions(String bookName, BuildContext context) {
    switch (bookName) {
      case 'Geeta':
        Navigator.push(
            context,
            PageAnimationTransition(
                page: const SahityaChapters(),
                pageAnimationType: RightToLeftTransition()));
        break;
      case 'Upnishad':
        showComingDialog(context);
        break;
      case 'Mahabharat':
        showComingDialog(context);
        break;
      case 'ShivPuran':
        showComingDialog(context);
        break;
      case 'Ramayan':
        showComingDialog(context);
        break;
      default:
        showComingDialog(context);
        break;
    }
  }

  Future<void> getSubcategoryData(
      int categoryIdFirst, int categoryIdSecond, int categoryIdThird) async {
    try {
      final categoryIds = [categoryIdFirst, categoryIdSecond, categoryIdThird];

      final urls = categoryIds
          .map(
            (id) =>
                '${AppConstants.baseUrl}${AppConstants.youtubeSubCategoryUrl}$id',
          )
          .toList();

      final responses = await Future.wait(urls.map(ApiService().getData));

      final subCategorySpritualData =
          kathaModelFromJson(jsonEncode(responses[0]));
      final subCategoryMoviesData =
          kathaModelFromJson(jsonEncode(responses[1]));
      final subCategorySerialsData =
          kathaModelFromJson(jsonEncode(responses[2]));

      setState(() {
        subcategory = subCategorySpritualData;
        subcategoryMovies = subCategoryMoviesData;
        subcategorySerials = subCategorySerialsData;
      });

      print('Subcategory count: ${subcategory.length}');
    } catch (e) {
      print('Error fetching subcategory data: $e');
    }
  }

  void showOriginalNo() {
    print('object $orignalNo');
    showModalBottomSheet(
        context: context,
        builder: (context) => Container(
              height: 500, // Adjust height as needed
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                      topRight: Radius.circular(20),
                      topLeft: Radius.circular(20)),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.grey, blurRadius: 4.0, spreadRadius: 2)
                  ]),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        const Spacer(),
                        IconButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          icon: const Icon(Icons.close),
                        ),
                      ],
                    ),
                    const Text(
                      'Original Number',
                      style: TextStyle(
                          color: Colors.orange,
                          fontSize: 20,
                          fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Container(
                      height: 80,
                      width: 80,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Center(
                          child: Image.asset(
                              'assets/images/calculator/mulk_ank.png')),
                    ),
                    const SizedBox(
                      height: 25.0,
                    ),
                    Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(10.0),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(8.0),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.blue.withOpacity(0.5),
                              blurRadius: 10,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Center(
                            child: Text(
                                '${_nameController.text} Your Mulank reveals your destiny, guiding you to success! ✨'))),
                    const SizedBox(
                      height: 20.0,
                    ),
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [
                            Colors.amber.shade400,
                            Colors.orange.shade900
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blue.withOpacity(0.5),
                            blurRadius: 10,
                            spreadRadius: 2,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          orignalNo,
                          style: const TextStyle(fontSize: 40),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                  ],
                ),
              ),
            ));
  }

  void showRashi() {
    showModalBottomSheet(
        context: context,
        builder: (context) => Container(
              height: 500, // Adjust height as needed
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                      topRight: Radius.circular(20),
                      topLeft: Radius.circular(20)),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.grey, blurRadius: 4.0, spreadRadius: 2)
                  ]),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        const Spacer(),
                        IconButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          icon: const Icon(Icons.close),
                        ),
                      ],
                    ),
                    const Text(
                      'Rashi Namkshar',
                      style: TextStyle(
                          color: Colors.orange,
                          fontSize: 20,
                          fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Container(
                      height: 80,
                      width: 80,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Center(
                          child: Image.asset(
                              'assets/images/calculator/Rashi_namaakshar.gif')),
                    ),
                    const SizedBox(
                      height: 10.0,
                    ),
                    Text('${_nameController.text} Rashi Namkshar'),
                    const SizedBox(
                      height: 15,
                    ),
                    Container(
                      decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(8.0)),
                      child: Column(
                        children: [
                          Container(
                            margin: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 8.0),
                            height: 40,
                            width: double.infinity,
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(4.0)),
                            child: const Center(
                                child: Text(
                              'Your Raashi',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            )),
                          ),
                          Container(
                            margin: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 8.0),
                            height: 50,
                            width: 100,
                            decoration: BoxDecoration(
                                color: Colors.blue.shade50,
                                borderRadius: BorderRadius.circular(4.0)),
                            child: Center(
                                child: Text(
                              rashinamakRashi,
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            )),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 10.0,
                    ),
                    Container(
                      decoration: BoxDecoration(
                          color: Colors.purple.shade50,
                          borderRadius: BorderRadius.circular(8.0)),
                      child: Column(
                        children: [
                          Container(
                            margin: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 8.0),
                            height: 40,
                            width: double.infinity,
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(4.0)),
                            child: const Center(
                                child: Text(
                              'Your Naamaakshar',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            )),
                          ),
                          Container(
                            margin: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 8.0),
                            height: 50,
                            width: 100,
                            decoration: BoxDecoration(
                                color: Colors.blue.shade50,
                                borderRadius: BorderRadius.circular(4.0)),
                            child: Center(
                                child: Text(
                              rashinamakAlphabet,
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            )),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                  ],
                ),
              ),
            ));
  }

  void showKaalsarp() {
    showModalBottomSheet(
        isDismissible: false,
        enableDrag: false,
        context: context,
        builder: (context) => StatefulBuilder(
                builder: (BuildContext context, StateSetter modalSetter) {
              return Container(
                height: 500, // Adjust height as needed
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                        topRight: Radius.circular(20),
                        topLeft: Radius.circular(20)),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.grey, blurRadius: 4.0, spreadRadius: 2)
                    ]),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Spacer(),
                          IconButton(
                            onPressed: () {
                              _nameController.clear();
                              _dateController.clear();
                              _timeController.clear();
                              countryController.clear();
                              Navigator.pop(context);
                            },
                            icon: const Icon(Icons.close),
                          ),
                          BouncingWidgetInOut(
                            onPressed: () {
                              modalSetter(() {
                                isTranslate = !isTranslate;
                                getKaalsarp(modalSetter);
                              });
                            },
                            child: Container(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 7),
                              height: 30,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8.0),
                                  color: isTranslate
                                      ? Colors.orange
                                      : Colors.transparent,
                                  border: Border.all(
                                      color: isTranslate
                                          ? Colors.transparent
                                          : Colors.orange,
                                      width: 2)),
                              child: Icon(
                                Icons.translate,
                                color:
                                    isTranslate ? Colors.white : Colors.orange,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const Text(
                        'Kaalsarp Dosh',
                        style: TextStyle(
                            color: Colors.orange,
                            fontSize: 20,
                            fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Container(
                        height: 80,
                        width: 80,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: Center(
                            child: Image.asset(
                                'assets/images/calculator/kaal_sarp_dosh.png')),
                      ),
                      const SizedBox(
                        height: 10.0,
                      ),
                      const Text('Kaalsarp dosh'),
                      Container(
                        margin: const EdgeInsets.only(top: 10),
                        padding: const EdgeInsets.all(10.0),
                        decoration: BoxDecoration(
                            color: Colors.green.shade50,
                            borderRadius: BorderRadius.circular(8.0)),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              margin: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 8.0),
                              height: 40,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(4.0)),
                              child: Center(
                                  child: Text(
                                '${_nameController.text} Kaalsarp dosh',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              )),
                            ),
                            const Text(
                              'Is Kalsarpa Dosha Present ?',
                              textAlign: TextAlign.center,
                            ),
                            Text(
                              kaalSarpDoshline,
                              textAlign: TextAlign.center,
                            )
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                    ],
                  ),
                ),
              );
            }));
  }

  void showPitrdosh() {
    showModalBottomSheet(
        context: context,
        builder: (context) => Container(
              height: 500, // Adjust height as needed
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                      topRight: Radius.circular(20),
                      topLeft: Radius.circular(20)),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.grey, blurRadius: 4.0, spreadRadius: 2)
                  ]),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        const Spacer(),
                        IconButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          icon: const Icon(Icons.close),
                        ),
                      ],
                    ),
                    const Text(
                      'Pitr Dosh',
                      style: TextStyle(
                          color: Colors.orange,
                          fontSize: 20,
                          fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Container(
                      height: 80,
                      width: 80,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Center(
                          child: Image.asset(
                              'assets/images/calculator/pitra_dosh.png')),
                    ),
                    const SizedBox(
                      height: 10.0,
                    ),
                    const Text('Pitr dosh'),
                    Container(
                      margin: const EdgeInsets.only(top: 10),
                      padding: const EdgeInsets.all(10.0),
                      decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(8.0)),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            margin: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 8.0),
                            height: 40,
                            width: double.infinity,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(4.0),
                                color: Colors.white),
                            child: Center(
                                child: Text(
                              '${_nameController.text} Pitr dosh',
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            )),
                          ),
                          Text(
                            pitrConclusion,
                            textAlign: TextAlign.center,
                          ),
                          const Divider(
                            color: Colors.grey,
                          ),
                          Text(
                            pitrmessage,
                            textAlign: TextAlign.center,
                          )
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                  ],
                ),
              ),
            ));
  }

  void showManglikdosh() {
    showMaterialModalBottomSheet(
        backgroundColor: Colors.white,
        expand: true,
        context: context,
        builder: (context) => Container(
              height: 600, // Adjust height as needed
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                      topRight: Radius.circular(20),
                      topLeft: Radius.circular(20)),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.grey, blurRadius: 4.0, spreadRadius: 2)
                  ]),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(
                      height: 30,
                    ),
                    Row(
                      children: [
                        const Spacer(),
                        IconButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          icon: const Icon(Icons.close),
                        ),
                      ],
                    ),
                    const Text(
                      'Manglik Dosh',
                      style: TextStyle(
                          color: Colors.orange,
                          fontSize: 20,
                          fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Container(
                      height: 80,
                      width: 80,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Center(
                          child: Image.asset(
                              'assets/images/calculator/mandlik_dosh.gif')),
                    ),
                    const SizedBox(
                      height: 10.0,
                    ),
                    const Text('Manglik dosh'),
                    Container(
                      margin: const EdgeInsets.only(top: 10),
                      padding: const EdgeInsets.all(10.0),
                      decoration: BoxDecoration(
                          color: Colors.green.shade50,
                          borderRadius: BorderRadius.circular(8.0)),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            margin: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 8.0),
                            height: 40,
                            width: double.infinity,
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(4.0)),
                            child: Center(
                                child: Text(
                              '${_nameController.text} Manglik dosh',
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            )),
                          ),
                          Center(
                              child: Text(
                                  'Manglik Dosha Percentage : $manglikPercent')),
                          const SizedBox(
                            height: 20.0,
                          ),
                          const Center(
                              child: Text(
                            'जन्म कुंडली ग्रह भाव पर आधारित',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          )),
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: manglikBased_on_aspect
                                .length, // Number of items in the list
                            itemBuilder: (BuildContext context, int index) {
                              // itemBuilder function returns a widget for each item in the list
                              return Text(manglikBased_on_aspect[index]);
                            },
                          ),
                          const Divider(
                            color: Colors.grey,
                          ),
                          const Center(
                              child: Text(
                            'जन्म कुंडली ग्रह दृष्टि पर आधारित',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          )),
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: manglikBased_on_house
                                .length, // Number of items in the list
                            itemBuilder: (BuildContext context, int index) {
                              // itemBuilder function returns a widget for each item in the list
                              return Text(manglikBased_on_house[index]);
                            },
                          ),
                          const Divider(
                            color: Colors.grey,
                          ),
                          const Center(
                              child: Text(
                            'मांगलिक विश्लेषण',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          )),
                          Text(manglikReport),
                          const Divider(
                            color: Colors.grey,
                          ),
                          const Text(
                            'मांगलिक प्रभाव',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(manglikStatus),
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                  ],
                ),
              ),
            ));
  }

  void showRudraksha() {
    showMaterialModalBottomSheet(
        backgroundColor: Colors.white,
        expand: true,
        context: context,
        builder: (context) => Container(
              height: 600, // Adjust height as needed
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                      topRight: Radius.circular(20),
                      topLeft: Radius.circular(20)),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.grey, blurRadius: 4.0, spreadRadius: 2)
                  ]),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(
                      height: 30,
                    ),
                    Row(
                      children: [
                        const Spacer(),
                        IconButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          icon: const Icon(Icons.close),
                        ),
                      ],
                    ),
                    const Text(
                      'Rudraksha Suggestion',
                      style: TextStyle(
                          color: Colors.orange,
                          fontSize: 20,
                          fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Container(
                      height: 80,
                      width: 80,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Center(
                          child: Image.asset(
                              'assets/images/calculator/rudraksha_suzhav.png')),
                    ),
                    const SizedBox(
                      height: 10.0,
                    ),
                    const Text('Rudraksha Suggestion'),
                    Container(
                      margin: const EdgeInsets.only(top: 10),
                      padding: const EdgeInsets.all(10.0),
                      decoration: BoxDecoration(
                          color: Colors.green.shade50,
                          borderRadius: BorderRadius.circular(8.0)),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            margin: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 8.0),
                            height: 40,
                            width: double.infinity,
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(4.0)),
                            child: Center(
                                child: Text(
                              '${_nameController.text} Rudraksha Suggestion',
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            )),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: SizedBox(
                              height: 100,
                              child: CachedNetworkImage(
                                imageUrl:
                                    'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTqLtZalAz6VmhsVzCyO2GNcZ5oUOTgzA-HMA&s',
                                fit: BoxFit.cover,
                                errorWidget: (context, url, error) =>
                                    const Icon(Icons.broken_image),
                              ),
                            ),
                          ),
                          Text(
                            rudrakshaName,
                            textAlign: TextAlign.center,
                          ),
                          const Text(
                            'You are recommended to wear',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            rudrakshaRecommend,
                            textAlign: TextAlign.center,
                          ),
                          const Divider(
                            color: Colors.grey,
                          ),
                          Text(
                            rudrakshaDetail,
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                  ],
                ),
              ),
            ));
  }

  void showVimshottri() {
    showMaterialModalBottomSheet(
      backgroundColor: Colors.white,
      expand: true,
      context: context,
      builder: (context) => DefaultTabController(
        length: 2,
        child: Column(
          children: [
            const SizedBox(height: 30),
            Row(
              children: [
                const Spacer(),
                IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const Text(
              'Vimshottrai Dasha ',
              style: TextStyle(
                color: Colors.orange,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Container(
              height: 80,
              width: 80,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Center(
                  child: Image.asset(
                      'assets/images/calculator/vishmottri_dasa.gif')),
            ),
            const SizedBox(height: 10.0),
            const Text('Vimshottari Dasha'),
            const SizedBox(height: 10.0), // Added SizedBox for spacing
            const TabBar(
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              dividerColor: Colors.white,
              labelColor: Colors.orange,
              unselectedLabelColor: Colors.black,
              indicatorSize: TabBarIndicatorSize.tab,
              indicatorColor: Colors.orange,
              tabs: [
                Tab(text: 'Vartaman Vimshottari Dasha'),
                Tab(text: 'Vimshottari Maha Dasha'),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        const SizedBox(
                          height: 20,
                        ),
                        Container(
                          margin: const EdgeInsets.only(top: 10),
                          padding: const EdgeInsets.all(10.0),
                          decoration: BoxDecoration(
                              color: Colors.purple.shade50,
                              borderRadius: BorderRadius.circular(8.0)),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                margin: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 8.0),
                                height: 40,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(4.0)),
                                child: Center(
                                    child: Text(
                                  '${_nameController.text} Vimshottri dosh',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                )),
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              Row(
                                children: [
                                  Container(
                                    height: 40,
                                    width: 80,
                                    decoration: BoxDecoration(
                                      color: Colors.orange,
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                    child: Center(
                                        child: Text(
                                      vimshottariPlanet1,
                                      style:
                                          const TextStyle(color: Colors.white),
                                    )),
                                  ),
                                  const SizedBox(
                                    width: 10.0,
                                  ),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Mahadasha',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                      Text(
                                        '$vimshottariStart1 - $vimshottariEnd1',
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(
                                height: 8,
                              ),
                              Row(
                                children: [
                                  Container(
                                    height: 40,
                                    width: 80,
                                    decoration: BoxDecoration(
                                      color: Colors.orange,
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                    child: Center(
                                        child: Text(
                                      vimshottariPlanet2,
                                      style:
                                          const TextStyle(color: Colors.white),
                                    )),
                                  ),
                                  const SizedBox(
                                    width: 10.0,
                                  ),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Mahadasha',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                      Text(
                                        '$vimshottariStart2 - $vimshottariEnd2',
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(
                                height: 8,
                              ),
                              Row(
                                children: [
                                  Container(
                                    height: 40,
                                    width: 80,
                                    decoration: BoxDecoration(
                                      color: Colors.orange,
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                    child: Center(
                                        child: Text(
                                      vimshottariPlanet3,
                                      style:
                                          const TextStyle(color: Colors.white),
                                    )),
                                  ),
                                  const SizedBox(
                                    width: 10.0,
                                  ),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Mahadasha',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                      Text(
                                        '$vimshottariStart3 - $vimshottariEnd3',
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(
                                height: 8,
                              ),
                              Row(
                                children: [
                                  Container(
                                    height: 40,
                                    width: 80,
                                    decoration: BoxDecoration(
                                      color: Colors.orange,
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                    child: Center(
                                        child: Text(
                                      vimshottariPlanet4,
                                      style:
                                          const TextStyle(color: Colors.white),
                                    )),
                                  ),
                                  const SizedBox(
                                    width: 10.0,
                                  ),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Mahadasha',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                      Text(
                                        '$vimshottariStart4 - $vimshottariEnd4',
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(
                                height: 8,
                              ),
                              Row(
                                children: [
                                  Container(
                                    height: 40,
                                    width: 80,
                                    decoration: BoxDecoration(
                                      color: Colors.orange,
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                    child: Center(
                                        child: Text(
                                      vimshottariPlanet5,
                                      style:
                                          const TextStyle(color: Colors.white),
                                    )),
                                  ),
                                  const SizedBox(
                                    width: 10.0,
                                  ),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Mahadasha',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                      Text(
                                        '$vimshottariStart5 - $vimshottariEnd5',
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        const SizedBox(
                          height: 20,
                        ),
                        Container(
                          decoration: BoxDecoration(
                            border:
                                Border.all(color: Colors.orange, width: 1.5),
                            borderRadius: BorderRadius.circular(8.0),
                            image: const DecorationImage(
                                image: AssetImage('assets/images/framebg.png')),
                          ),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 8),
                                      decoration: BoxDecoration(
                                          color: Colors.purple.shade100,
                                          border:
                                              Border.all(color: Colors.orange),
                                          borderRadius: const BorderRadius.only(
                                              topLeft: Radius.circular(7.0))),
                                      child: const Center(
                                          child: Text(
                                        'Planet',
                                        style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold),
                                      )),
                                    ),
                                  ),
                                  Expanded(
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 8),
                                      decoration: BoxDecoration(
                                          color: Colors.orange.shade100,
                                          border:
                                              Border.all(color: Colors.orange)),
                                      child: const Center(
                                          child: Text(
                                        'Start date',
                                        style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold),
                                      )),
                                    ),
                                  ),
                                  Expanded(
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 8),
                                      decoration: BoxDecoration(
                                          color: Colors.orange.shade100,
                                          border:
                                              Border.all(color: Colors.orange),
                                          borderRadius: const BorderRadius.only(
                                              topRight: Radius.circular(7.0))),
                                      child: const Center(
                                          child: Text(
                                        'End Date',
                                        style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold),
                                      )),
                                    ),
                                  )
                                ],
                              ),
                              Row(
                                children: [
                                  Expanded(
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 8),
                                      decoration: BoxDecoration(
                                          border:
                                              Border.all(color: Colors.grey)),
                                      child: const Center(
                                          child: Text(
                                        'Moon',
                                        style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold),
                                      )),
                                    ),
                                  ),
                                  Expanded(
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 8),
                                      decoration: const BoxDecoration(
                                        border: Border.symmetric(
                                            horizontal:
                                                BorderSide(color: Colors.grey)),
                                      ),
                                      child: const Center(
                                          child: Text(
                                        '11-6-2021 11:54',
                                        style: TextStyle(fontSize: 12),
                                      )),
                                    ),
                                  ),
                                  Expanded(
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 8),
                                      decoration: BoxDecoration(
                                          border:
                                              Border.all(color: Colors.grey)),
                                      child: const Center(
                                          child: Text(
                                        '11-6-2021 11:54',
                                        style: TextStyle(fontSize: 12),
                                      )),
                                    ),
                                  )
                                ],
                              ),
                              Row(
                                children: [
                                  Expanded(
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 8),
                                      decoration: BoxDecoration(
                                          border:
                                              Border.all(color: Colors.grey)),
                                      child: const Center(
                                          child: Text(
                                        'Moon',
                                        style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold),
                                      )),
                                    ),
                                  ),
                                  Expanded(
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 8),
                                      decoration: const BoxDecoration(
                                        border: Border.symmetric(
                                            horizontal:
                                                BorderSide(color: Colors.grey)),
                                      ),
                                      child: const Center(
                                          child: Text(
                                        '11-6-2021 11:54',
                                        style: TextStyle(fontSize: 12),
                                      )),
                                    ),
                                  ),
                                  Expanded(
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 8),
                                      decoration: BoxDecoration(
                                          border:
                                              Border.all(color: Colors.grey)),
                                      child: const Center(
                                          child: Text(
                                        '11-6-2021 11:54',
                                        style: TextStyle(fontSize: 12),
                                      )),
                                    ),
                                  )
                                ],
                              ),
                              Row(
                                children: [
                                  Expanded(
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 8),
                                      decoration: BoxDecoration(
                                          border:
                                              Border.all(color: Colors.grey)),
                                      child: const Center(
                                          child: Text(
                                        'Moon',
                                        style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold),
                                      )),
                                    ),
                                  ),
                                  Expanded(
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 8),
                                      decoration: const BoxDecoration(
                                        border: Border.symmetric(
                                            horizontal:
                                                BorderSide(color: Colors.grey)),
                                      ),
                                      child: const Center(
                                          child: Text(
                                        '11-6-2021 11:54',
                                        style: TextStyle(fontSize: 12),
                                      )),
                                    ),
                                  ),
                                  Expanded(
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 8),
                                      decoration: BoxDecoration(
                                          border:
                                              Border.all(color: Colors.grey)),
                                      child: const Center(
                                          child: Text(
                                        '11-6-2021 11:54',
                                        style: TextStyle(fontSize: 12),
                                      )),
                                    ),
                                  )
                                ],
                              ),
                              Row(
                                children: [
                                  Expanded(
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 8),
                                      decoration: BoxDecoration(
                                          border:
                                              Border.all(color: Colors.grey)),
                                      child: const Center(
                                          child: Text(
                                        'Moon',
                                        style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold),
                                      )),
                                    ),
                                  ),
                                  Expanded(
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 8),
                                      decoration: const BoxDecoration(
                                        border: Border.symmetric(
                                            horizontal:
                                                BorderSide(color: Colors.grey)),
                                      ),
                                      child: const Center(
                                          child: Text(
                                        '11-6-2021 11:54',
                                        style: TextStyle(fontSize: 12),
                                      )),
                                    ),
                                  ),
                                  Expanded(
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 8),
                                      decoration: BoxDecoration(
                                          border:
                                              Border.all(color: Colors.grey)),
                                      child: const Center(
                                          child: Text(
                                        '11-6-2021 11:54',
                                        style: TextStyle(fontSize: 12),
                                      )),
                                    ),
                                  )
                                ],
                              ),
                              Row(
                                children: [
                                  Expanded(
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 8),
                                      decoration: BoxDecoration(
                                          border:
                                              Border.all(color: Colors.grey)),
                                      child: const Center(
                                          child: Text(
                                        'Moon',
                                        style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold),
                                      )),
                                    ),
                                  ),
                                  Expanded(
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 8),
                                      decoration: const BoxDecoration(
                                        border: Border.symmetric(
                                            horizontal:
                                                BorderSide(color: Colors.grey)),
                                      ),
                                      child: const Center(
                                          child: Text(
                                        '11-6-2021 11:54',
                                        style: TextStyle(fontSize: 12),
                                      )),
                                    ),
                                  ),
                                  Expanded(
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 8),
                                      decoration: BoxDecoration(
                                          border:
                                              Border.all(color: Colors.grey)),
                                      child: const Center(
                                          child: Text(
                                        '11-6-2021 11:54',
                                        style: TextStyle(fontSize: 12),
                                      )),
                                    ),
                                  )
                                ],
                              ),
                              Row(
                                children: [
                                  Expanded(
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 8),
                                      decoration: BoxDecoration(
                                          border:
                                              Border.all(color: Colors.grey)),
                                      child: const Center(
                                          child: Text(
                                        'Moon',
                                        style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold),
                                      )),
                                    ),
                                  ),
                                  Expanded(
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 8),
                                      decoration: const BoxDecoration(
                                        border: Border.symmetric(
                                            horizontal:
                                                BorderSide(color: Colors.grey)),
                                      ),
                                      child: const Center(
                                          child: Text(
                                        '11-6-2021 11:54',
                                        style: TextStyle(fontSize: 12),
                                      )),
                                    ),
                                  ),
                                  Expanded(
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 8),
                                      decoration: BoxDecoration(
                                          border:
                                              Border.all(color: Colors.grey)),
                                      child: const Center(
                                          child: Text(
                                        '11-6-2021 11:54',
                                        style: TextStyle(fontSize: 12),
                                      )),
                                    ),
                                  )
                                ],
                              ),
                              Row(
                                children: [
                                  Expanded(
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 8),
                                      decoration: BoxDecoration(
                                          border:
                                              Border.all(color: Colors.grey)),
                                      child: const Center(
                                          child: Text(
                                        'Moon',
                                        style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold),
                                      )),
                                    ),
                                  ),
                                  Expanded(
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 8),
                                      decoration: const BoxDecoration(
                                        border: Border.symmetric(
                                            horizontal:
                                                BorderSide(color: Colors.grey)),
                                      ),
                                      child: const Center(
                                          child: Text(
                                        '11-6-2021 11:54',
                                        style: TextStyle(fontSize: 12),
                                      )),
                                    ),
                                  ),
                                  Expanded(
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 8),
                                      decoration: BoxDecoration(
                                          border:
                                              Border.all(color: Colors.grey)),
                                      child: const Center(
                                          child: Text(
                                        '11-6-2021 11:54',
                                        style: TextStyle(fontSize: 12),
                                      )),
                                    ),
                                  )
                                ],
                              ),
                              Row(
                                children: [
                                  Expanded(
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 8),
                                      decoration: BoxDecoration(
                                          border:
                                              Border.all(color: Colors.grey)),
                                      child: const Center(
                                          child: Text(
                                        'Moon',
                                        style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold),
                                      )),
                                    ),
                                  ),
                                  Expanded(
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 8),
                                      decoration: const BoxDecoration(
                                        border: Border.symmetric(
                                            horizontal:
                                                BorderSide(color: Colors.grey)),
                                      ),
                                      child: const Center(
                                          child: Text(
                                        '11-6-2021 11:54',
                                        style: TextStyle(fontSize: 12),
                                      )),
                                    ),
                                  ),
                                  Expanded(
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 8),
                                      decoration: BoxDecoration(
                                          border:
                                              Border.all(color: Colors.grey)),
                                      child: const Center(
                                          child: Text(
                                        '11-6-2021 11:54',
                                        style: TextStyle(fontSize: 12),
                                      )),
                                    ),
                                  )
                                ],
                              ),
                              Row(
                                children: [
                                  Expanded(
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 8),
                                      decoration: BoxDecoration(
                                          border:
                                              Border.all(color: Colors.grey),
                                          borderRadius: const BorderRadius.only(
                                              bottomLeft:
                                                  Radius.circular(7.0))),
                                      child: const Center(
                                          child: Text(
                                        'Moon',
                                        style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold),
                                      )),
                                    ),
                                  ),
                                  Expanded(
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 8),
                                      decoration: const BoxDecoration(
                                        border: Border.symmetric(
                                            horizontal:
                                                BorderSide(color: Colors.grey)),
                                      ),
                                      child: const Center(
                                          child: Text(
                                        '11-6-2021 11:54',
                                        style: TextStyle(fontSize: 12),
                                      )),
                                    ),
                                  ),
                                  Expanded(
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 8),
                                      decoration: BoxDecoration(
                                          border:
                                              Border.all(color: Colors.grey),
                                          borderRadius: const BorderRadius.only(
                                              bottomRight:
                                                  Radius.circular(7.0))),
                                      child: const Center(
                                          child: Text(
                                        '11-6-2021 11:54',
                                        style: TextStyle(fontSize: 12),
                                      )),
                                    ),
                                  )
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(
                          height: 10,
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
    );
  }

  void showRatna() {
    showMaterialModalBottomSheet(
      backgroundColor: Colors.white,
      expand: true,
      context: context,
      builder: (context) => DefaultTabController(
        length: 3,
        child: Column(
          children: [
            const SizedBox(height: 30),
            Row(
              children: [
                const Spacer(),
                IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const Text(
              'Ratna Suggestion',
              style: TextStyle(
                color: Colors.orange,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Container(
              height: 80,
              width: 80,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Center(
                  child:
                      Image.asset('assets/images/calculator/ratna_suzhav.gif')),
            ),
            const SizedBox(height: 10.0),
            const Text('Ratna Suggestion'),
            const SizedBox(height: 10.0), // Added SizedBox for spacing
            const TabBar(
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              dividerColor: Colors.white,
              labelColor: Colors.orange,
              unselectedLabelColor: Colors.black,
              indicatorSize: TabBarIndicatorSize.tab,
              indicatorColor: Colors.orange,
              tabs: [
                Tab(text: 'Life Ratna'),
                Tab(text: 'Profit Ratna'),
                Tab(text: 'Fortune Ratna'),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  Column(
                    children: [
                      const SizedBox(
                        height: 10,
                      ),
                      SizedBox(
                        height: 100,
                        width: 100,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8.0),
                          child: CachedNetworkImage(
                            imageUrl:
                                'https://blog.brilliance.com/wp-content/uploads/2017/06/perfect-diamond-isolated-on-shiny-background.jpg',
                            fit: BoxFit.fill,
                            errorWidget: (context, url, error) => const Icon(
                              Icons.broken_image,
                              color: Colors.grey,
                              size: 40,
                            ),
                          ),
                        ),
                      ),
                      const Text(
                        'Diamond',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 10.0),
                        decoration: BoxDecoration(
                          border:
                              Border.all(color: Colors.grey.shade400, width: 1),
                          borderRadius: BorderRadius.circular(8.0),
                          color: Colors.transparent,
                        ),
                        child: Table(
                          border: const TableBorder(
                            horizontalInside: BorderSide(color: Colors.cyan),
                          ),
                          defaultVerticalAlignment:
                              TableCellVerticalAlignment.middle,
                          columnWidths: const {
                            0: FlexColumnWidth(),
                            1: FlexColumnWidth(),
                          },
                          children: [
                            TableRow(
                              decoration: BoxDecoration(
                                  color: Colors.orange.shade50,
                                  borderRadius: const BorderRadius.only(
                                      topRight: Radius.circular(7.0),
                                      topLeft: Radius.circular(7.0))),
                              children: [
                                const Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 10.0, vertical: 8.0),
                                  child: Text(
                                    'Substitude',
                                    style: TextStyle(
                                      fontSize: 18,
                                    ),
                                  ),
                                ),
                                Row(
                                  children: [
                                    Container(
                                      height: 30,
                                      width: 2,
                                      color: Colors.cyan,
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10.0, vertical: 8.0),
                                      child: Text(
                                        lifeGemsName,
                                        // Assuming you want to display this string.
                                        style: const TextStyle(
                                          fontSize: 18,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            TableRow(
                              decoration: const BoxDecoration(
                                color: Colors.white,
                              ),
                              children: [
                                const Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 10.0, vertical: 8.0),
                                  child: Text(
                                    'Finger',
                                    style: TextStyle(
                                      fontSize: 18,
                                    ),
                                  ),
                                ),
                                Row(
                                  children: [
                                    Container(
                                      height: 30,
                                      width: 2,
                                      color: Colors.cyan,
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10.0, vertical: 8.0),
                                      child: Text(
                                        lifeGemsFinger,
                                        // Assuming you want to display this string.
                                        style: const TextStyle(
                                          fontSize: 18,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            TableRow(
                              decoration: BoxDecoration(
                                color: Colors.orange.shade50,
                              ),
                              children: [
                                const Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 10.0, vertical: 8.0),
                                  child: Text(
                                    'Weight',
                                    style: TextStyle(
                                      fontSize: 18,
                                    ),
                                  ),
                                ),
                                Row(
                                  children: [
                                    Container(
                                      height: 30,
                                      width: 2,
                                      color: Colors.cyan,
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10.0, vertical: 8.0),
                                      child: Text(
                                        lifeGemsWeight,
                                        // Assuming you want to display this string.
                                        style: const TextStyle(
                                          fontSize: 18,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            TableRow(
                              decoration: const BoxDecoration(
                                color: Colors.white,
                              ),
                              children: [
                                const Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 10.0, vertical: 8.0),
                                  child: Text(
                                    'Day',
                                    style: TextStyle(
                                      fontSize: 18,
                                    ),
                                  ),
                                ),
                                Row(
                                  children: [
                                    Container(
                                      height: 30,
                                      width: 2,
                                      color: Colors.cyan,
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10.0, vertical: 8.0),
                                      child: Text(
                                        lifeGemsDay,
                                        // Assuming you want to display this string.
                                        style: const TextStyle(
                                          fontSize: 18,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            TableRow(
                              decoration: BoxDecoration(
                                color: Colors.orange.shade50,
                              ),
                              children: [
                                const Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 10.0, vertical: 8.0),
                                  child: Text(
                                    'Deity',
                                    style: TextStyle(
                                      fontSize: 18,
                                    ),
                                  ),
                                ),
                                Row(
                                  children: [
                                    Container(
                                      height: 30,
                                      width: 2,
                                      color: Colors.cyan,
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10.0, vertical: 8.0),
                                      child: Text(
                                        lifeGemsDeity,
                                        // Assuming you want to display this string.
                                        style: const TextStyle(
                                          fontSize: 18,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            TableRow(
                              decoration: const BoxDecoration(
                                borderRadius: BorderRadius.only(
                                    bottomRight: Radius.circular(7.0),
                                    bottomLeft: Radius.circular(7.0)),
                                color: Colors.white,
                              ),
                              children: [
                                const Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 10.0, vertical: 8.0),
                                  child: Text(
                                    'Metal',
                                    style: TextStyle(
                                      fontSize: 18,
                                    ),
                                  ),
                                ),
                                Row(
                                  children: [
                                    Container(
                                      height: 30,
                                      width: 2,
                                      color: Colors.cyan,
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10.0, vertical: 8.0),
                                      child: Text(
                                        lifeGemsMetal,
                                        // Assuming you want to display this string.
                                        style: const TextStyle(
                                          fontSize: 18,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                  Column(
                    children: [
                      const SizedBox(
                        height: 10,
                      ),
                      SizedBox(
                        height: 100,
                        width: 100,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8.0),
                          child: CachedNetworkImage(
                            imageUrl:
                                'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSEHmTdlvOK1kDEOHR51zFqVO4mQlemylYl4uwJXsJr_w&s',
                            fit: BoxFit.fill,
                            errorWidget: (context, url, error) => const Icon(
                              Icons.broken_image,
                              color: Colors.grey,
                              size: 40,
                            ),
                          ),
                        ),
                      ),
                      const Text(
                        'Diamond',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 10.0),
                        decoration: BoxDecoration(
                          border:
                              Border.all(color: Colors.grey.shade400, width: 1),
                          borderRadius: BorderRadius.circular(8.0),
                          color: Colors.transparent,
                        ),
                        child: Table(
                          border: const TableBorder(
                            horizontalInside: BorderSide(color: Colors.cyan),
                          ),
                          defaultVerticalAlignment:
                              TableCellVerticalAlignment.middle,
                          columnWidths: const {
                            0: FlexColumnWidth(),
                            1: FlexColumnWidth(),
                          },
                          children: [
                            TableRow(
                              decoration: BoxDecoration(
                                  color: Colors.blue.shade50,
                                  borderRadius: const BorderRadius.only(
                                      topRight: Radius.circular(7.0),
                                      topLeft: Radius.circular(7.0))),
                              children: [
                                const Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 10.0, vertical: 8.0),
                                  child: Text(
                                    'Substitude',
                                    style: TextStyle(
                                      fontSize: 18,
                                    ),
                                  ),
                                ),
                                Row(
                                  children: [
                                    Container(
                                      height: 30,
                                      width: 2,
                                      color: Colors.cyan,
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10.0, vertical: 8.0),
                                      child: Text(
                                        beneficGemsName,
                                        // Assuming you want to display this string.
                                        style: const TextStyle(
                                          fontSize: 18,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            TableRow(
                              decoration: const BoxDecoration(
                                color: Colors.white,
                              ),
                              children: [
                                const Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 10.0, vertical: 8.0),
                                  child: Text(
                                    'Finger',
                                    style: TextStyle(
                                      fontSize: 18,
                                    ),
                                  ),
                                ),
                                Row(
                                  children: [
                                    Container(
                                      height: 30,
                                      width: 2,
                                      color: Colors.cyan,
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10.0, vertical: 8.0),
                                      child: Text(
                                        beneficGemsFinger,
                                        // Assuming you want to display this string.
                                        style: const TextStyle(
                                          fontSize: 18,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            TableRow(
                              decoration: BoxDecoration(
                                color: Colors.blue.shade50,
                              ),
                              children: [
                                const Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 10.0, vertical: 8.0),
                                  child: Text(
                                    'Weight',
                                    style: TextStyle(
                                      fontSize: 18,
                                    ),
                                  ),
                                ),
                                Row(
                                  children: [
                                    Container(
                                      height: 30,
                                      width: 2,
                                      color: Colors.cyan,
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10.0, vertical: 8.0),
                                      child: Text(
                                        beneficGemsWeight,
                                        // Assuming you want to display this string.
                                        style: const TextStyle(
                                          fontSize: 18,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            TableRow(
                              decoration: const BoxDecoration(
                                color: Colors.white,
                              ),
                              children: [
                                const Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 10.0, vertical: 8.0),
                                  child: Text(
                                    'Day',
                                    style: TextStyle(
                                      fontSize: 18,
                                    ),
                                  ),
                                ),
                                Row(
                                  children: [
                                    Container(
                                      height: 30,
                                      width: 2,
                                      color: Colors.cyan,
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10.0, vertical: 8.0),
                                      child: Text(
                                        beneficGemsDay,
                                        // Assuming you want to display this string.
                                        style: const TextStyle(
                                          fontSize: 18,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            TableRow(
                              decoration: BoxDecoration(
                                color: Colors.blue.shade50,
                              ),
                              children: [
                                const Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 10.0, vertical: 8.0),
                                  child: Text(
                                    'Deity',
                                    style: TextStyle(
                                      fontSize: 18,
                                    ),
                                  ),
                                ),
                                Row(
                                  children: [
                                    Container(
                                      height: 30,
                                      width: 2,
                                      color: Colors.cyan,
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10.0, vertical: 8.0),
                                      child: Text(
                                        beneficGemsDeity,
                                        // Assuming you want to display this string.
                                        style: const TextStyle(
                                          fontSize: 18,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            TableRow(
                              decoration: const BoxDecoration(
                                borderRadius: BorderRadius.only(
                                    bottomRight: Radius.circular(7.0),
                                    bottomLeft: Radius.circular(7.0)),
                                color: Colors.white,
                              ),
                              children: [
                                const Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 10.0, vertical: 8.0),
                                  child: Text(
                                    'Metal',
                                    style: TextStyle(
                                      fontSize: 18,
                                    ),
                                  ),
                                ),
                                Row(
                                  children: [
                                    Container(
                                      height: 30,
                                      width: 2,
                                      color: Colors.cyan,
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10.0, vertical: 8.0),
                                      child: Text(
                                        beneficGemsMetal,
                                        // Assuming you want to display this string.
                                        style: const TextStyle(
                                          fontSize: 18,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                  Column(
                    children: [
                      const SizedBox(
                        height: 10,
                      ),
                      SizedBox(
                        height: 100,
                        width: 100,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8.0),
                          child: CachedNetworkImage(
                            imageUrl:
                                'https://img1.exportersindia.com/product_images/bc-full/2021/7/8764740/green-diamond-1625890677-5814848.jpeg',
                            fit: BoxFit.fill,
                            errorWidget: (context, url, error) => const Icon(
                              Icons.broken_image,
                              color: Colors.grey,
                              size: 40,
                            ),
                          ),
                        ),
                      ),
                      const Text(
                        'Diamond',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 10.0),
                        decoration: BoxDecoration(
                          border:
                              Border.all(color: Colors.grey.shade400, width: 1),
                          borderRadius: BorderRadius.circular(8.0),
                          color: Colors.transparent,
                        ),
                        child: Table(
                          border: const TableBorder(
                            horizontalInside: BorderSide(color: Colors.cyan),
                          ),
                          defaultVerticalAlignment:
                              TableCellVerticalAlignment.middle,
                          columnWidths: const {
                            0: FlexColumnWidth(),
                            1: FlexColumnWidth(),
                          },
                          children: [
                            TableRow(
                              decoration: BoxDecoration(
                                  color: Colors.green.shade50,
                                  borderRadius: const BorderRadius.only(
                                      topRight: Radius.circular(7.0),
                                      topLeft: Radius.circular(7.0))),
                              children: [
                                const Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 10.0, vertical: 8.0),
                                  child: Text(
                                    'Substitude',
                                    style: TextStyle(
                                      fontSize: 18,
                                    ),
                                  ),
                                ),
                                Row(
                                  children: [
                                    Container(
                                      height: 30,
                                      width: 2,
                                      color: Colors.cyan,
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10.0, vertical: 8.0),
                                      child: Text(
                                        luckyGemsName,
                                        // Assuming you want to display this string.
                                        style: const TextStyle(
                                          fontSize: 18,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            TableRow(
                              decoration: const BoxDecoration(
                                color: Colors.white,
                              ),
                              children: [
                                const Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 10.0, vertical: 8.0),
                                  child: Text(
                                    'Finger',
                                    style: TextStyle(
                                      fontSize: 18,
                                    ),
                                  ),
                                ),
                                Row(
                                  children: [
                                    Container(
                                      height: 30,
                                      width: 2,
                                      color: Colors.cyan,
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10.0, vertical: 8.0),
                                      child: Text(
                                        luckyGemsFinger,
                                        // Assuming you want to display this string.
                                        style: const TextStyle(
                                          fontSize: 18,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            TableRow(
                              decoration: BoxDecoration(
                                color: Colors.green.shade50,
                              ),
                              children: [
                                const Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 10.0, vertical: 8.0),
                                  child: Text(
                                    'Weight',
                                    style: TextStyle(
                                      fontSize: 18,
                                    ),
                                  ),
                                ),
                                Row(
                                  children: [
                                    Container(
                                      height: 30,
                                      width: 2,
                                      color: Colors.cyan,
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10.0, vertical: 8.0),
                                      child: Text(
                                        luckyGemsWeight,
                                        // Assuming you want to display this string.
                                        style: const TextStyle(
                                          fontSize: 18,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            TableRow(
                              decoration: const BoxDecoration(
                                color: Colors.white,
                              ),
                              children: [
                                const Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 10.0, vertical: 8.0),
                                  child: Text(
                                    'Day',
                                    style: TextStyle(
                                      fontSize: 18,
                                    ),
                                  ),
                                ),
                                Row(
                                  children: [
                                    Container(
                                      height: 30,
                                      width: 2,
                                      color: Colors.cyan,
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10.0, vertical: 8.0),
                                      child: Text(
                                        luckyGemsDay,
                                        // Assuming you want to display this string.
                                        style: const TextStyle(
                                          fontSize: 18,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            TableRow(
                              decoration: BoxDecoration(
                                color: Colors.green.shade50,
                              ),
                              children: [
                                const Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 10.0, vertical: 8.0),
                                  child: Text(
                                    'Deity',
                                    style: TextStyle(
                                      fontSize: 18,
                                    ),
                                  ),
                                ),
                                Row(
                                  children: [
                                    Container(
                                      height: 30,
                                      width: 2,
                                      color: Colors.cyan,
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10.0, vertical: 8.0),
                                      child: Text(
                                        luckyGemsDeity,
                                        // Assuming you want to display this string.
                                        style: const TextStyle(
                                          fontSize: 18,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            TableRow(
                              decoration: const BoxDecoration(
                                borderRadius: BorderRadius.only(
                                    bottomRight: Radius.circular(7.0),
                                    bottomLeft: Radius.circular(7.0)),
                                color: Colors.white,
                              ),
                              children: [
                                const Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 10.0, vertical: 8.0),
                                  child: Text(
                                    'Metal',
                                    style: TextStyle(
                                      fontSize: 18,
                                    ),
                                  ),
                                ),
                                Row(
                                  children: [
                                    Container(
                                      height: 30,
                                      width: 2,
                                      color: Colors.cyan,
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10.0, vertical: 8.0),
                                      child: Text(
                                        luckyGemsMetal,
                                        // Assuming you want to display this string.
                                        style: const TextStyle(
                                          fontSize: 18,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      )
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

  void showPooja() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // 🔥 Full height enable
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.transparent, // for rounded corners visibility
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 1.0, // 🔥 Full height
          minChildSize: 1.0,
          maxChildSize: 1.0,
          expand: true,
          builder: (context, scrollController) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(20),
                  topLeft: Radius.circular(20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey,
                    blurRadius: 4.0,
                    spreadRadius: 2,
                  ),
                ],
              ),

              // 🔥 Full height scroll
              child: SingleChildScrollView(
                controller: scrollController,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        const Spacer(),
                        IconButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          icon: const Icon(Icons.close),
                        ),
                      ],
                    ),
                    const Text(
                      'Pooja Suggestion',
                      style: TextStyle(
                          color: Colors.orange,
                          fontSize: 20,
                          fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Container(
                      height: 80,
                      width: 80,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Center(
                          child: Image.asset(
                              'assets/images/calculator/puja_suzhav.gif')),
                    ),
                    const SizedBox(
                      height: 10.0,
                    ),
                    const Text('Pooja Suggestion'),
                    Container(
                      margin: const EdgeInsets.only(top: 10),
                      padding: const EdgeInsets.all(10.0),
                      decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(8.0)),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            margin: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 8.0),
                            height: 40,
                            width: double.infinity,
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(4.0)),
                            child: Center(
                                child: Text(
                              '${_nameController.text}  Pooja Suggestions',
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            )),
                          ),
                          Text(
                            poojasuggestion,
                            textAlign: TextAlign.center,
                          ),
                          ListView.builder(
                            shrinkWrap: true,
                            itemCount: poojaSuggestionList.length,
                            itemBuilder: (context, index) {
                              final item = poojaSuggestionList[index];

                              return Container(
                                margin: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 10),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(14),
                                  color: Colors.white,
                                  boxShadow: [
                                    const BoxShadow(
                                      color: Colors.black12,
                                      blurRadius: 8,
                                      offset: Offset(0, 4),
                                    )
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // 🔥 Header Strip
                                    Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 12, horizontal: 14),
                                      decoration: BoxDecoration(
                                        borderRadius:
                                            const BorderRadius.vertical(
                                                top: Radius.circular(14)),
                                        gradient: LinearGradient(
                                          colors: [
                                            Colors.deepOrange,
                                            Colors.orange.shade400
                                          ],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          const Icon(Icons.auto_awesome,
                                              color: Colors.white, size: 22),
                                          const SizedBox(width: 10),
                                          Expanded(
                                            child: Text(
                                              '${item.title}',
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w700,
                                                fontSize: 16,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                    // 🟡 Summary
                                    Padding(
                                      padding: const EdgeInsets.all(14),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            '${item.summary}',
                                            style: TextStyle(
                                              color: Colors.grey.shade800,
                                              fontSize: 14,
                                              height: 1.4,
                                            ),
                                          ),

                                          const SizedBox(height: 12),

                                          // 🔥 One Line Suggestion Box
                                          Container(
                                            padding: const EdgeInsets.all(12),
                                            decoration: BoxDecoration(
                                              color: Colors.orange.shade50,
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              border: Border.all(
                                                  color:
                                                      Colors.orange.shade200),
                                            ),
                                            child: Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                const Icon(Icons.lightbulb,
                                                    color: Colors.deepOrange,
                                                    size: 20),
                                                const SizedBox(width: 10),
                                                Expanded(
                                                  child: Text(
                                                    '${item.oneLine}',
                                                    style: TextStyle(
                                                      color: Colors
                                                          .deepOrange.shade800,
                                                      fontSize: 14,
                                                      height: 1.3,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),

                                          const SizedBox(height: 14),

                                          // 🔥 CTA Button (Optional)
                                          Align(
                                            alignment: Alignment.centerRight,
                                            child: ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor:
                                                    Colors.deepOrange,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 18,
                                                        vertical: 10),
                                              ),
                                              onPressed: () {
                                                print(
                                                    'Puja ID Selected: ${item.pujaId}');
                                              },
                                              child: const Text(
                                                'View Details',
                                                style: TextStyle(
                                                    color: Colors.white),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          )
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  //Janm Jankari Widget's
  void anukulMantra() {
    showModalBottomSheet(
        isDismissible: false,
        enableDrag: false,
        context: context,
        builder: (context) => StatefulBuilder(
                builder: (BuildContext context, StateSetter modalSetter) {
              return Container(
                height: 500, // Adjust height as needed
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                        topRight: Radius.circular(20),
                        topLeft: Radius.circular(20)),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.grey, blurRadius: 4.0, spreadRadius: 2)
                    ]),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Spacer(),
                          IconButton(
                            onPressed: () {
                              _nameController.clear();
                              _dateController.clear();
                              _timeController.clear();
                              countryController.clear();
                              selectedGender = 'Gender';
                              Navigator.pop(context);
                            },
                            icon: const Icon(Icons.close),
                          ),
                          BouncingWidgetInOut(
                            onPressed: () {
                              modalSetter(() {
                                isTranslate = !isTranslate;
                                getAnukulMantra(modalSetter);
                              });
                            },
                            child: Container(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 7),
                              height: 30,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8.0),
                                  color: isTranslate
                                      ? Colors.orange
                                      : Colors.transparent,
                                  border: Border.all(
                                      color: isTranslate
                                          ? Colors.transparent
                                          : Colors.orange,
                                      width: 2)),
                              child: Icon(
                                Icons.translate,
                                color:
                                    isTranslate ? Colors.white : Colors.orange,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const Text(
                        'Janm Jankari Se Janiye',
                        style: TextStyle(
                            color: Colors.orange,
                            fontSize: 20,
                            fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Container(
                        height: 80,
                        width: 80,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: Center(
                            child: Image.asset(
                                'assets/images/allcategories/anukul_mantra_icon_animation.gif')),
                      ),
                      const SizedBox(
                        height: 10.0,
                      ),
                      const Text('Anukul Mantra'),
                      Container(
                        margin: const EdgeInsets.only(top: 10),
                        padding: const EdgeInsets.all(10.0),
                        decoration: BoxDecoration(
                            color: Colors.green.shade50,
                            borderRadius: BorderRadius.circular(8.0)),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(15),
                              width: double.infinity,
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(4.0)),
                              child: Center(
                                  child: Text(
                                anukulMantraVar,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              )),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                    ],
                  ),
                ),
              );
            }));
  }

  void anukulTime() {
    showModalBottomSheet(
        isDismissible: false,
        enableDrag: false,
        context: context,
        builder: (context) => StatefulBuilder(
                builder: (BuildContext context, StateSetter modalSetter) {
              return Container(
                height: 500, // Adjust height as needed
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                        topRight: Radius.circular(20),
                        topLeft: Radius.circular(20)),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.grey, blurRadius: 4.0, spreadRadius: 2)
                    ]),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Spacer(),
                          IconButton(
                            onPressed: () {
                              _nameController.clear();
                              _dateController.clear();
                              _timeController.clear();
                              countryController.clear();
                              selectedGender = 'Gender';
                              Navigator.pop(context);
                            },
                            icon: const Icon(Icons.close),
                          ),
                          BouncingWidgetInOut(
                            onPressed: () {
                              modalSetter(() {
                                isTranslate = !isTranslate;
                                getAnukulTime(modalSetter);
                              });
                            },
                            child: Container(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 7),
                              height: 30,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8.0),
                                  color: isTranslate
                                      ? Colors.orange
                                      : Colors.transparent,
                                  border: Border.all(
                                      color: isTranslate
                                          ? Colors.transparent
                                          : Colors.orange,
                                      width: 2)),
                              child: Icon(
                                Icons.translate,
                                color:
                                    isTranslate ? Colors.white : Colors.orange,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const Text(
                        'Janm Jankari Se Janiye',
                        style: TextStyle(
                            color: Colors.orange,
                            fontSize: 20,
                            fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Container(
                        height: 80,
                        width: 80,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: Center(
                            child: Image.asset(
                                'assets/images/allcategories/anukul_time icon_animation.gif')),
                      ),
                      const SizedBox(
                        height: 10.0,
                      ),
                      const Text('Anukul Time'),
                      Container(
                        margin: const EdgeInsets.only(top: 10),
                        padding: const EdgeInsets.all(10.0),
                        decoration: BoxDecoration(
                            color: Colors.green.shade50,
                            borderRadius: BorderRadius.circular(8.0)),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(15),
                              width: double.infinity,
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(4.0)),
                              child: Center(
                                  child: Text(
                                anukulTimeVar,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              )),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                    ],
                  ),
                ),
              );
            }));
  }

  void shubhVrat() {
    showModalBottomSheet(
        isDismissible: false,
        enableDrag: false,
        context: context,
        builder: (context) => StatefulBuilder(
                builder: (BuildContext context, StateSetter modalSetter) {
              return Container(
                height: 500, // Adjust height as needed
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                        topRight: Radius.circular(20),
                        topLeft: Radius.circular(20)),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.grey, blurRadius: 4.0, spreadRadius: 2)
                    ]),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Spacer(),
                          IconButton(
                            onPressed: () {
                              _nameController.clear();
                              _dateController.clear();
                              _timeController.clear();
                              countryController.clear();
                              selectedGender = 'Gender';
                              Navigator.pop(context);
                            },
                            icon: const Icon(Icons.close),
                          ),
                          BouncingWidgetInOut(
                            onPressed: () {
                              modalSetter(() {
                                isTranslate = !isTranslate;
                                getShubhVrat(modalSetter);
                              });
                            },
                            child: Container(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 7),
                              height: 30,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8.0),
                                  color: isTranslate
                                      ? Colors.orange
                                      : Colors.transparent,
                                  border: Border.all(
                                      color: isTranslate
                                          ? Colors.transparent
                                          : Colors.orange,
                                      width: 2)),
                              child: Icon(
                                Icons.translate,
                                color:
                                    isTranslate ? Colors.white : Colors.orange,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const Text(
                        'Janm Jankari Se Janiye',
                        style: TextStyle(
                            color: Colors.orange,
                            fontSize: 20,
                            fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Container(
                        height: 80,
                        width: 80,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: Center(
                            child: Image.asset(
                                'assets/images/allcategories/vrat and thoyahar icon.png')),
                      ),
                      const SizedBox(
                        height: 10.0,
                      ),
                      const Text('Shubh Vrat'),
                      Container(
                        margin: const EdgeInsets.only(top: 10),
                        padding: const EdgeInsets.all(10.0),
                        decoration: BoxDecoration(
                            color: Colors.green.shade50,
                            borderRadius: BorderRadius.circular(8.0)),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(15),
                              width: double.infinity,
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(4.0)),
                              child: Center(
                                  child: Text(
                                subhVratVar,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              )),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                    ],
                  ),
                ),
              );
            }));
  }

  void anukulDevWidget() {
    showModalBottomSheet(
        isDismissible: false,
        enableDrag: false,
        context: context,
        builder: (context) => StatefulBuilder(
                builder: (BuildContext context, StateSetter modalSetter) {
              return Container(
                height: 500, // Adjust height as needed
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                        topRight: Radius.circular(20),
                        topLeft: Radius.circular(20)),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.grey, blurRadius: 4.0, spreadRadius: 2)
                    ]),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Spacer(),
                          IconButton(
                            onPressed: () {
                              _nameController.clear();
                              _dateController.clear();
                              _timeController.clear();
                              countryController.clear();
                              selectedGender = 'Gender';
                              Navigator.pop(context);
                            },
                            icon: const Icon(Icons.close),
                          ),
                          BouncingWidgetInOut(
                            onPressed: () {
                              modalSetter(() {
                                isTranslate = !isTranslate;
                                getAnukulDev(modalSetter);
                              });
                            },
                            child: Container(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 7),
                              height: 30,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8.0),
                                  color: isTranslate
                                      ? Colors.orange
                                      : Colors.transparent,
                                  border: Border.all(
                                      color: isTranslate
                                          ? Colors.transparent
                                          : Colors.orange,
                                      width: 2)),
                              child: Icon(
                                Icons.translate,
                                color:
                                    isTranslate ? Colors.white : Colors.orange,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const Text(
                        'Janm Jankari Se Janiye',
                        style: TextStyle(
                            color: Colors.orange,
                            fontSize: 20,
                            fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Container(
                        height: 80,
                        width: 80,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: Center(
                            child: Image.asset(
                                'assets/images/allcategories/Anukul dev icon.png')),
                      ),
                      const SizedBox(
                        height: 10.0,
                      ),
                      const Text('Anukul Dev'),
                      Container(
                        margin: const EdgeInsets.only(top: 10),
                        padding: const EdgeInsets.all(10.0),
                        decoration: BoxDecoration(
                            color: Colors.green.shade50,
                            borderRadius: BorderRadius.circular(8.0)),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(15),
                              width: double.infinity,
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(4.0)),
                              child: Center(
                                  child: Text(
                                anukulDev,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              )),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                    ],
                  ),
                ),
              );
            }));
  }

  //rashi namak
  void getRashiNamak(StateSetter modalSetter) async {
    modalSetter(() => isLoading = true);
    var res = await HttpService().postApi(AppConstants.rashiNamakUrl, {
      'date': _dateController.text,
      'time': '$birthHour:$birthMinute',
      'latitude': calculatorLong,
      'longitude': calculatorLat,
      'timezone': '5.5',
      'language': isTranslate ? 'en' : 'hi'
    });

    modalSetter(() {
      if (res['status'] == 200) {
        rashinamakRashi = res['rashiNamakshar']['sign'].toString();
        rashinamakAlphabet = res['rashiNamakshar']['name_alphabet'].toString();
        _nameController.clear();
        Navigator.pop(context);
        _dateController.clear();
        countryController.clear();
        _timeController.clear();
        showRashi();
        modalSetter(() => isLoading = false);
      } else {
        modalSetter(() => isLoading = false);
        print('error msg');
      }
    });
  }

  //original number API
  void calculateMulank(StateSetter modalSetter, String dob) {
    // Extract digits from the DOB and sum them
    int sum = dob
        .replaceAll(RegExp(r'[^0-9]'), '') // Remove non-numeric characters
        .split('')
        .map(int.parse)
        .reduce((a, b) => a + b);

    // Reduce to a single digit
    while (sum > 9) {
      sum = sum.toString().split('').map(int.parse).reduce((a, b) => a + b);
    }
    Navigator.pop(context);
    modalSetter(() => isLoading = false);
    _nameController.clear();
    _dateController.clear();
    countryController.clear();
    _timeController.clear();
    showOriginalNo();
    setState(() {
      orignalNo = sum.toString();
    });
    // return sum;
  }

  void getOrignalNumber(StateSetter modalSetter) async {
    modalSetter(() => isLoading = true);
    var res = await HttpService().postApi(AppConstants.orignalNumberUrl, {
      'date': _dateController.text,
      'time': '$birthHour:$birthMinute',
      'latitude': calculatorLat,
      'longitude': calculatorLong,
      'timezone': '5.5',
      'language': isTranslate ? 'en' : 'hi'
    });

    setState(() {
      if (res['status'] == 200) {
        orignalNo = res['moolAnk']['name_number'].toString();
        Navigator.pop(context);
        modalSetter(() => isLoading = false);
        _nameController.clear();
        _dateController.clear();
        countryController.clear();
        _timeController.clear();
        showOriginalNo();
      } else {
        print('error msg');
      }
    });
  }

  // Pooja get Api
  List<Suggestion> poojaSuggestionList = <Suggestion>[];
  void getPooja(StateSetter modalSetter) async {
    modalSetter(() => isLoading = true);
    var res = await HttpService().postApi(AppConstants.prayerSugestionUrl, {
      'date': _dateController.text,
      'time': '$birthHour:$birthMinute',
      'latitude': calculatorLong,
      'longitude': calculatorLat,
      'timezone': '5.5',
      'language': isTranslate ? 'en' : 'hi'
    });

    setState(() {
      if (res['status'] == 200) {
        poojasuggestion = res['prayerSuggestion']['summary'].toString();
        List pooja = res['prayerSuggestion']['suggestions'];
        poojaSuggestionList.addAll(pooja.map((e) => Suggestion.fromJson(e)));
        Navigator.pop(context);
        modalSetter(() => isLoading = false);
        _nameController.clear();
        _dateController.clear();
        countryController.clear();
        _timeController.clear();
        showPooja();
      } else {
        print('error msg');
      }
    });
  }

  //Kaalsarp dosh
  void getKaalsarp(StateSetter modalSetter) async {
    modalSetter(() => isLoading = true);
    var res = await HttpService().postApi(AppConstants.kaalSarpUrl, {
      'date': _dateController.text,
      'time': '$birthHour:$birthMinute',
      'latitude': calculatorLong,
      'longitude': calculatorLat,
      'timezone': '5.5',
      'language': isTranslate ? 'en' : 'hi'
    });

    setState(() {
      if (res['status'] == 200) {
        kaalSarpDoshline = res['kalsarpDosha']['one_line'].toString();
        Navigator.pop(context);
        modalSetter(() => isLoading = false);
        showKaalsarp();
      } else {
        print('error msg');
      }
    });
  }

  //PitrDosh dosh
  void getPitrDosh(StateSetter modalSetter) async {
    modalSetter(() => isLoading = true);
    var res = await HttpService().postApi(AppConstants.pitrDoshUrl, {
      'date': _dateController.text,
      'time': '$birthHour:$birthMinute',
      'latitude': calculatorLong,
      'longitude': calculatorLat,
      'timezone': '5.5',
      'language': isTranslate ? 'en' : 'hi'
    });

    setState(() {
      if (res['status'] == 200) {
        pitrConclusion = res['pitraDosha']['conclusion'].toString();
        pitrmessage = res['pitraDosha']['what_is_pitri_dosha'].toString();
        pitrTrueFalse = res['pitraDosha']['is_pitri_dosha_present'].toString();
        print(pitrTrueFalse);
        Navigator.pop(context);
        modalSetter(() => isLoading = false);
        _nameController.clear();
        _dateController.clear();
        _timeController.clear();
        countryController.clear();
        showPitrdosh();
      } else {
        print('error msg');
      }
    });
  }

  // Gems Suggestion
  void getGemsSuggestion(StateSetter modalSetter) async {
    modalSetter(() => isLoading = true);
    var res = await HttpService().postApi(AppConstants.gemSuggestionUrl, {
      'date': _dateController.text,
      'time': '$birthHour:$birthMinute',
      'latitude': calculatorLong,
      'longitude': calculatorLat,
      'timezone': '5.5',
      'language': isTranslate ? 'en' : 'hi'
    });

    setState(() {
      if (res['status'] == 200) {
        // life data
        lifeGemsName = res['gemSuggestion']['LIFE']['name'].toString();
        lifeGemsFinger = res['gemSuggestion']['LIFE']['wear_finger'].toString();
        lifeGemsWeight =
            res['gemSuggestion']['LIFE']['weight_caret'].toString();
        lifeGemsDay = res['gemSuggestion']['LIFE']['wear_day'].toString();
        lifeGemsDeity = res['gemSuggestion']['LIFE']['gem_deity'].toString();
        lifeGemsMetal = res['gemSuggestion']['LIFE']['wear_metal'].toString();
        // benefic data
        beneficGemsName = res['gemSuggestion']['BENEFIC']['name'].toString();
        beneficGemsFinger =
            res['gemSuggestion']['BENEFIC']['wear_finger'].toString();
        beneficGemsWeight =
            res['gemSuggestion']['BENEFIC']['weight_caret'].toString();
        beneficGemsDay = res['gemSuggestion']['BENEFIC']['wear_day'].toString();
        beneficGemsDeity =
            res['gemSuggestion']['BENEFIC']['gem_deity'].toString();
        beneficGemsMetal =
            res['gemSuggestion']['BENEFIC']['wear_metal'].toString();
        // lucky data
        luckyGemsName = res['gemSuggestion']['LUCKY']['name'].toString();
        luckyGemsFinger =
            res['gemSuggestion']['LUCKY']['wear_finger'].toString();
        luckyGemsWeight =
            res['gemSuggestion']['LUCKY']['weight_caret'].toString();
        luckyGemsDay = res['gemSuggestion']['LUCKY']['wear_day'].toString();
        luckyGemsDeity = res['gemSuggestion']['LUCKY']['gem_deity'].toString();
        luckyGemsMetal = res['gemSuggestion']['LUCKY']['wear_metal'].toString();
        Navigator.pop(context);
        modalSetter(() => isLoading = false);
        _nameController.clear();
        _dateController.clear();
        _timeController.clear();
        countryController.clear();
        print(pitrTrueFalse);
        showRatna();
      } else {
        print('error msg');
      }
    });
  }

  //Rudraksh dosh
  void getRudraksh(StateSetter modalSetter) async {
    modalSetter(() => isLoading = true);
    var res = await HttpService().postApi(AppConstants.rudrakshSugestionUrl, {
      'date': _dateController.text,
      'time': '$birthHour:$birthMinute',
      'latitude': calculatorLong,
      'longitude': calculatorLat,
      'timezone': '5.5',
      'language': isTranslate ? 'en' : 'hi'
    });

    setState(() {
      if (res['status'] == 200) {
        rudrakshaImage = res['rudrakshaSuggestion']['img_url'].toString();
        rudrakshaName = res['rudrakshaSuggestion']['name'].toString();
        rudrakshaRecommend = res['rudrakshaSuggestion']['recommend'].toString();
        rudrakshaDetail = res['rudrakshaSuggestion']['detail'].toString();
        Navigator.pop(context);
        modalSetter(() => isLoading = false);
        _nameController.clear();
        countryController.clear();
        _dateController.clear();
        _timeController.clear();
        showRudraksha();
      } else {
        print('error msg');
      }
    });
  }

  //Rudraksh dosh
  void getVimshottari(StateSetter modalSetter) async {
    modalSetter(() => isLoading = true);
    var res = await HttpService().postApi(AppConstants.vimshottariUrl, {
      'date': _dateController.text,
      'time': '$birthHour:$birthMinute',
      'latitude': calculatorLong,
      'longitude': calculatorLat,
      'timezone': '5.5',
      'language': isTranslate ? 'en' : 'hi'
    });

    setState(() {
      if (res['status'] == 200) {
        // Planet data
        vimshottariPlanet1 =
            res['vimshottariDasha']['major']['planet'].toString();
        vimshottariPlanet2 =
            res['vimshottariDasha']['minor']['planet'].toString();
        vimshottariPlanet3 =
            res['vimshottariDasha']['sub_minor']['planet'].toString();
        vimshottariPlanet4 =
            res['vimshottariDasha']['sub_sub_minor']['planet'].toString();
        vimshottariPlanet5 =
            res['vimshottariDasha']['sub_sub_sub_minor']['planet'].toString();

        // start time data
        vimshottariStart1 =
            res['vimshottariDasha']['major']['start'].toString();
        vimshottariStart2 =
            res['vimshottariDasha']['minor']['start'].toString();
        vimshottariStart3 =
            res['vimshottariDasha']['sub_minor']['start'].toString();
        vimshottariStart4 =
            res['vimshottariDasha']['sub_sub_minor']['start'].toString();
        vimshottariStart5 =
            res['vimshottariDasha']['sub_sub_sub_minor']['start'].toString();

        // start time data
        vimshottariEnd1 = res['vimshottariDasha']['major']['end'].toString();
        vimshottariEnd2 = res['vimshottariDasha']['minor']['end'].toString();
        vimshottariEnd3 =
            res['vimshottariDasha']['sub_minor']['end'].toString();
        vimshottariEnd4 =
            res['vimshottariDasha']['sub_sub_minor']['end'].toString();
        vimshottariEnd5 =
            res['vimshottariDasha']['sub_sub_sub_minor']['end'].toString();
        Navigator.pop(context);
        modalSetter(() => isLoading = false);
        _nameController.clear();
        countryController.clear();
        _dateController.clear();
        _timeController.clear();
        showVimshottri();
      } else {
        print('error msg');
      }
    });
  }

  //Manglik dosh
  void getManglikDosh(StateSetter modalSetter) async {
    modalSetter(() => isLoading = true);
    var res = await HttpService().postApi(AppConstants.manglikDoshUrl, {
      'date': _dateController.text,
      'time': '$birthHour:$birthMinute',
      'latitude': calculatorLong,
      'longitude': calculatorLat,
      'timezone': '5.5',
      'language': isTranslate ? 'en' : 'hi'
    });

    setState(() {
      if (res['status'] == 200) {
        manglikBased_on_aspect =
            res['manglikDosh']['manglik_present_rule']['based_on_aspect'];
        manglikBased_on_house =
            res['manglikDosh']['manglik_present_rule']['based_on_house'];
        manglikStatus = res['manglikDosh']['manglik_status'].toString();
        manglikPercent =
            res['manglikDosh']['percentage_manglik_present'].toString();
        manglikReport = res['manglikDosh']['manglik_report'].toString();
        print(manglikBased_on_aspect);
        Navigator.pop(context);
        modalSetter(() => isLoading = false);
        _nameController.clear();
        _dateController.clear();
        _timeController.clear();
        countryController.clear();
        showManglikdosh();
      } else {
        print('error msg');
      }
    });
  }

  //Anukul Mantra API
  void getAnukulMantra(StateSetter modalSetter) async {
    print('Anukul Mantra');
    modalSetter(() => isLoading = true);
    var res = await HttpService().postApi(AppConstants.anukulMantra, {
      'date': _dateController.text,
      'time': '$birthHour:$birthMinute',
      'latitude': calculatorLong,
      'longitude': calculatorLat,
      'timezone': '5.5',
      'language': isTranslate ? 'en' : 'hi'
    });

    modalSetter(() {
      if (res['status'] == 200) {
        anukulMantraVar = res['favMantra']['description'].toString();
        Navigator.pop(context);
        modalSetter(() => isLoading = false);
        anukulMantra();
      } else {
        print('error msg');
      }
    });
  }

  //Anukul Time API
  void getAnukulTime(StateSetter modalSetter) async {
    print('Anukul Mantra');
    modalSetter(() => isLoading = true);
    var res = await HttpService().postApi(AppConstants.anukulTime, {
      'date': _dateController.text,
      'time': '$birthHour:$birthMinute',
      'latitude': calculatorLong,
      'longitude': calculatorLat,
      'timezone': '5.5',
      'language': isTranslate ? 'en' : 'hi'
    });

    modalSetter(() {
      if (res['status'] == 200) {
        anukulTimeVar = res['favTime']['description'].toString();
        Navigator.pop(context);
        modalSetter(() => isLoading = false);
        anukulTime();
      } else {
        print('error msg');
      }
    });
  }

  //Shubh Vrat API
  void getShubhVrat(StateSetter modalSetter) async {
    print('Shubh Vrat');
    modalSetter(() => isLoading = true);
    var res = await HttpService().postApi(AppConstants.shubhVrat, {
      'date': _dateController.text,
      'time': '$birthHour:$birthMinute',
      'latitude': calculatorLong,
      'longitude': calculatorLat,
      'timezone': '5.5',
      'language': isTranslate ? 'en' : 'hi'
    });

    modalSetter(() {
      if (res['status'] == 200) {
        subhVratVar = res['fasts']['description'].toString();
        Navigator.pop(context);
        modalSetter(() => isLoading = false);
        shubhVrat();
      } else {
        print('error msg');
      }
    });
  }

  //Shubh Vrat API API
  void getAnukulDev(StateSetter modalSetter) async {
    print('AnukulDev');
    modalSetter(() => isLoading = true);
    var res = await HttpService().postApi(AppConstants.anukulDev, {
      'date': _dateController.text,
      'time': '$birthHour:$birthMinute',
      'latitude': calculatorLong,
      'longitude': calculatorLat,
      'timezone': '5.5',
      'language': isTranslate ? 'en' : 'hi'
    });

    modalSetter(() {
      if (res['status'] == 200) {
        anukulDev = res['favLord']['description'].toString();
        Navigator.pop(context);
        modalSetter(() => isLoading = false);
        anukulDevWidget();
      } else {
        print('error msg');
      }
    });
  }

  Future panchangData() async {
    print('Translate Value-$isTranslate');
    print("Date:${DateFormat('dd/MM/yyyy').format(now)}");
    print("Time:${DateFormat('HH:mm').format(now)}");

    final panchangRequestBody = {
      'date': DateFormat('dd/MM/yyyy').format(now),
      'time': DateFormat('HH:mm').format(now),
      'latitude': Provider.of<AuthController>(context, listen: false).latitude,
      'longitude':
          Provider.of<AuthController>(context, listen: false).longitude,
      'timezone': '5.5',
      'language': isTranslate ? 'en' : 'hi',
    };

    // Make API calls concurrently
    final response = await HttpService()
        .postApi(AppConstants.panchangUrl, panchangRequestBody);

    //Panchang Data
    tithiName = response['panchang']['tithi']['details']['tithi_name'];
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _initializeUserId();
    Provider.of<CallServiceProvider>(Get.context!, listen: false).getSIPData();

    Future.microtask(()async{
      await context.read<HotelUserController>().initHotelUser(context);
    });
    seactionSwitch();
    _initAsyncOperations();
    _scrollController.addListener(() {
      _scrollPosition = _scrollController.offset;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startAutoScroll();
    });
    // widget.scrollController.addListener(_scrollListener);
  }

  // void _scrollListener() {
  //   // Yahan check karenge ke user scroll kar raha hai ya nahi
  //   final double offset = widget.scrollController.offset;
  //   final double maxScroll = widget.scrollController.position.maxScrollExtent;
  //
  //   // Jab scroll top se neeche ho (300 ke baad button dikhao)
  //   if (offset > 600 && offset < maxScroll - 50) {
  //     if (!isScrolling) {
  //       setState(() => isScrolling = true);
  //     }
  //   } else {
  //     // Jab top ya bottom pe ho, button hide karo
  //     if (isScrolling) {
  //       setState(() => isScrolling = false);
  //     }
  //   }
  // }

  Future<void> _initAsyncOperations() async {
    try {
      final authController =
          Provider.of<AuthController>(context, listen: false);
      await authController.fetchCurrentLocation(context);

      await Future.wait<void>([
        _loadData(false),
        loadAllHomeData(),
        panchangData(),
        _fetchData(),
        getSubcategoryData(48, 46, 43),
        getEventSubCategory(),
        getAdvertiseMent(),
      ]);
      setState(() {});
    } catch (e) {
      debugPrint('Error in _initAsyncOperations: $e');
    }
  }

  Future<void> _loadData(bool reload) async {
    try {
      // final context = Get.context!;
      Provider.of<BannerController>(context, listen: false)
          .getBannerList(reload);
      final authController =
          Provider.of<AuthController>(context, listen: false);
      final isLoggedIn = authController.isLoggedIn();

      // Group operations by their return types
      Provider.of<ProductController>(context, listen: false)
          .getLProductList('1', reload: reload);
      Provider.of<ProductController>(context, listen: false)
          .getFeaturedProductList('1', reload: reload);
      Provider.of<ProductController>(Get.context!, listen: false)
          .getLatestProductList(1, reload: reload);

      getConsultaionData();
      getmuhuratData();

      // Individual operations
      Provider.of<NotificationController>(context, listen: false)
          .getNotificationList(1);

      // Conditional user operations
      if (isLoggedIn) {
        [
          Provider.of<ProfileController>(context, listen: false)
              .getUserInfo(context),
          Provider.of<WishListController>(context, listen: false).getWishList(),
        ];
      }

      Provider.of<CartController>(context, listen: false).getCartData(context);
    } catch (e) {
      debugPrint('Error in _loadData: $e');
    }
  }

  /// Darshan Category, Chadhava, Sangeet, Pooja, Latest Tours, Sahitya, Youtube Category, Blogs SubCategory
  Future<void> loadAllHomeData() async {
    try {
      final responses = await Future.wait([
        HttpService().getApi(AppConstants.darshanCategoryUrl),
        HttpService().getApi(AppConstants.chadhavaHomeUrl),
        HttpService().getApi(AppConstants.sangeetCategoryUrl),
        HttpService().getApi(AppConstants.poojaCategoryUrl),
        HttpService().getApi(AppConstants.sahityaGridUrl),
        HttpService().getApi(AppConstants.youtubeCategoryUrl),
        HttpService().getApi(AppConstants.newTourDataUrl),
        HttpService().getApi('${AppConstants.blogsSubCategoryUrl}2'),
        HttpService().getApi(AppConstants.offlineCategoryUrl),
      ]);

      // Assign parsed data
      final darshanList = (responses[0]['data'] as List?)
          ?.map((e) => DarshanData.fromJson(e))
          .toList();
      if (darshanList != null) darshanCategoryModelList = darshanList;

      final chadhavaList = (responses[1]['data'] as List?)
          ?.map((e) => Chadhavadetail.fromJson(e))
          .toList();
      if (chadhavaList != null) chadhavaModelList = chadhavaList;

      final sangeetList = (responses[2]['data'] as List?)
          ?.map((e) => SangeetCategory.fromJson(e))
          .toList();
      if (sangeetList != null) sangeetModelList = sangeetList;

      final poojaList = (responses[3]['data'] as List?)
          ?.map((e) => GetPoojaCategory.fromJson(e))
          .toList();
      if (poojaList != null) categoryPoojaModelList = poojaList;

      // Parse Sahitya
      final sahitya = SahityaCategoryModel.fromJson(responses[4]);
      sahityaList = sahitya.data ?? [];
      print('Sahitya ${sahityaList.length}');

      // Parse Video Category
      List cdata = responses[5]['videoCategory'];
      category = categoriesModelFromJson(jsonEncode(cdata));
      print('Video Category ${category.length}');

      // Parse New Tours
      final newTours = NewToursModel.fromJson(responses[6]);
      _newToursList = newTours.data ?? [];
      print('Latest Tours${_newToursList.length}');

      // Parse Blog SubCategory
      final blogSubCategory = BlogSubCategoryModel.fromJson(responses[7]);
      latestBlogs = blogSubCategory.data ?? [];
      print('Latest Blogs ${latestBlogs.length}');

      // Parse Book Pandit
      final offlineData = CategoryModel.fromJson(responses[8]);
      offlineCategoryList = offlineData.categoryList ?? [];
      print('OfflINE Category${offlineCategoryList.length}');
    } catch (e) {
      debugPrint('Error loading home data: $e');
    }
  }

  /// Load the user ID before fetching data
  Future<void> _initializeUserId() async {
    await loadUserId(); // Load user ID from SharedPreferences
    if (userId == '-1') {
      userId =
          Provider.of<ProfileController>(Get.context!, listen: false).userID;
      await saveUserId(userId!);
    }
    // await checkJyotiStatus(); // Fetch data after userId is initialized
  }

  Future<void> saveUserId(String id) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_Id', id);
  }

  Future<void> loadUserId() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userId = prefs.getString('user_Id') ?? '-1';
    });
  }

  Future<void> checkJyotiStatus() async {
    setState(() => _isLoading = true);
    try {
      final res = await ApiService().getData(
          '${AppConstants.baseUrl}/api/v1/akhand/jyoti/get/status?customer_id=$userId');

      if (res != null) {
        setState(() {
          runningJyotiData = RunningJyotiModel.fromJson(res);
        });

        // Check diya status and show Sankalp dialog if false
        if (runningJyotiData?.akhandJyoti == false) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            //showSankalpDialog(context);
          });
        }
      }
    } catch (e) {
      print('Error fetching diya status: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void handleAction(String value) {
    switch (value) {
      case 'Bhagavad Gita':
        Navigator.push(
            context,
            CupertinoPageRoute(
              builder: (context) => const SahityaChapters(),
            ));
        break;
      case 'Hanuman Chalisa':
        Navigator.push(
            context,
            CupertinoPageRoute(
              builder: (context) => const HanumanChalisaScreen(),
            ));
        break;
      case 'Chhath puja Katha':
        Navigator.push(
            context,
            CupertinoPageRoute(
              builder: (context) => const ChhathPuja(),
            ));
        break;
      case 'Janmashtami Vrat Katha':
        Navigator.push(
            context,
            CupertinoPageRoute(
              builder: (context) => const Janmashtami(),
            ));
        break;
      case 'Dasha Mata Vrat Katha':
        Navigator.push(
            context,
            CupertinoPageRoute(
              builder: (context) => const Dasha_mata(),
            ));
        break;
      case 'Hariyali Teej Vrat Katha':
        Navigator.push(
            context,
            CupertinoPageRoute(
              builder: (context) => const HariyaliTeej(),
            ));
        break;
      case 'Hartalika Teej Vrat Katha':
        Navigator.push(
            context,
            CupertinoPageRoute(
              builder: (context) => const HartalikaTeej(),
            ));
        break;
      case 'Karwa Chauth Vrat Katha':
        Navigator.push(
            context,
            CupertinoPageRoute(
              builder: (context) => const KarwaChauth(),
            ));
        break;
      case 'Sheetala Saptami Vrat Katha':
        Navigator.push(
            context,
            CupertinoPageRoute(
              builder: (context) => const SheetlaSaptmi(),
            ));
        break;
      case 'Shravan (sawan) Somvar Vrat Katha':
        Navigator.push(
            context,
            CupertinoPageRoute(
              builder: (context) => const Shravan(),
            ));
        break;
      case 'Gangaur Katha':
        Navigator.push(
            context,
            CupertinoPageRoute(
              builder: (context) => const GangaurKatha(),
            ));
        break;
      case 'Vat Savitri Vrat Katha':
        Navigator.push(
            context,
            CupertinoPageRoute(
              builder: (context) => const VatSavitriVrat(),
            ));
        break;
      case 'Govardhan Puja Vrat Katha':
        Navigator.push(
            context,
            CupertinoPageRoute(
              builder: (context) => const GovardhanPuja(),
            ));
        break;
      // case "":
      //   Navigator.push(
      //       context,
      //       CupertinoPageRoute(
      //         builder: (context) =>  GuruvarVrat(),));
      //    break;
      case 'Vaibhav Laxmi Vrat Katha':
        Navigator.push(
            context,
            CupertinoPageRoute(
              builder: (context) => const VaibhavLaxmi(),
            ));
        break;
      case 'Sri Suktam Paath':
        Navigator.push(
            context,
            CupertinoPageRoute(
              builder: (context) => const ShriSuktam(),
            ));
        break;
      case 'Sharad Purnima Vrat Katha':
        Navigator.push(
            context,
            CupertinoPageRoute(
              builder: (context) => const SharadPurnima(),
            ));
        break;
      case 'Shanivar (Saturday) Vrat Katha':
        Navigator.push(
            context,
            CupertinoPageRoute(
              builder: (context) => const ShanivaarVrat(),
            ));
        break;
      case 'Rishi Panchami Vrat Katha':
        Navigator.push(
            context,
            CupertinoPageRoute(
              builder: (context) => const RishiPanchmi(),
            ));
        break;
      case 'Pashupatinath Vrat Katha':
        Navigator.push(
            context,
            CupertinoPageRoute(
              builder: (context) => const PashupatiVrat(),
            ));
        break;
      case 'Narsingh Jayanti Vrat Katha':
        Navigator.push(
            context,
            CupertinoPageRoute(
              builder: (context) => const Narasimha(),
            ));
        break;
      case 'Nag Panchami katha':
        Navigator.push(
            context,
            CupertinoPageRoute(
              builder: (context) => const NagPanchmi(),
            ));
        break;
      case 'Mangalvar Vrat Katha':
        Navigator.push(
            context,
            CupertinoPageRoute(
              builder: (context) => const MangalvarVrat(),
            ));
        break;
      case 'Kartik Purnima Vrat Katha':
        Navigator.push(
            context,
            CupertinoPageRoute(
              builder: (context) => const KartikPurnima(),
            ));
        break;
      case 'Holi Vrat Katha':
        Navigator.push(
            context,
            CupertinoPageRoute(
              builder: (context) => const HoliVrat(),
            ));
        break;
      case 'Bhai dooj Vrat Katha':
        Navigator.push(
            context,
            CupertinoPageRoute(
              builder: (context) => const BhaiDooj(),
            ));
      case 'Coming Soon':
        print('Navigating to Settings');
        break;
      // default:
      //   showComingSoonDialog(context);
      //  Navigator.push(context, CupertinoPageRoute(builder: (context) =>  ComingSoon(),));
    }
  }

  void _startAutoScroll() async {
    const scrollSpeed = 1.2; // Adjust speed (lower = slower)
    const frameDuration = Duration(milliseconds: 30);

    while (mounted) {
      await Future.delayed(frameDuration);

      if (!_autoScrollActive ||
          _userInteracting ||
          !_scrollController.hasClients) {
        continue;
      }

      final maxScroll = _scrollController.position.maxScrollExtent;
      final currentPos = _scrollController.position.pixels;
      final newPos = currentPos + scrollSpeed;

      if (newPos >= maxScroll) {
        // Instead of jumping, smoothly reset to the start
        _scrollController.jumpTo(0);
      } else {
        _scrollController.jumpTo(newPos);
      }
    }
  }

  void showComingSoonDialog(BuildContext context, String imagePath) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Top Icon or Image
              Image.asset(
                imagePath,
                height: 100, // Adjust the height as needed
                width: 100, // Adjust the width as needed
              ),
              const SizedBox(height: 20.0),
              // Main Message
              const Text(
                'Coming Soon',
                style: TextStyle(
                  fontSize: 22.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.brown,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10.0),
              // Description (Optional)
              Text(
                "Stay tuned! We're working on something divine for you.",
                style: TextStyle(
                  fontSize: 16.0,
                  color: Colors.grey[700],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20.0),
              // Close Button
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text(
                  'Close',
                  style: TextStyle(
                    fontSize: 16.0,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ScrollController
  //final scrollController = ScrollController();

  // Function to scroll to widget
  void scrollTo(String title) {
    final Map<String, GlobalKey> sectionKeys = {
      'start_jap': oneKey,
      'free_rashifal': twoKey,
      'free_kundli': threeKey,
      'free_sangeet': fourKey,
      'free_blogs': fiveKey,
      'free_serial': sixKey,
      'free_bhakti': sevenKey,
      'free_birth': eightKey,
      'free_calculater': nineKey,
      'free_youtube': tenKey,
      'free_livedarshan': elevenKey,
      'free_katha': tweleveKey,
      // 'free_lalkitab': thirteenKey,
    };

    final GlobalKey? key = sectionKeys[title];

    if (key == null || key.currentContext == null) {
      debugPrint('No matching key found for $title');
      return;
    }

    setState(() => isScrolling = true);

    Scrollable.ensureVisible(
      key.currentContext!,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }


  void onItemTap(BuildContext context, String title) {
    switch (title) {
      case 'start_jap':
        Navigator.push(context,
            MaterialPageRoute(builder: (_) => JaapView()));
        break;

      case 'free_rashifal':
        scrollTo(title);
        break;

      case 'free_kundli':
        Navigator.push(context,
            MaterialPageRoute(builder: (_) => const KundliForm()));
        break;

      case 'free_sangeet':
        Navigator.push(context,
            MaterialPageRoute(builder: (_) => const SangitHome(tabiIndex: 1,)));
        break;

      case 'free_blogs':
        Navigator.push(context,
            MaterialPageRoute(builder: (_) => const BlogHomePage()));
        break;

      case 'free_serial':
        Navigator.push(context,
            MaterialPageRoute(builder: (_) => const YoutubeHomePage(tabIndex: 0)));
        break;

      case 'free_birth':
       scrollTo(title);
        break;

      case 'free_calculater':
       scrollTo(title);
        break;

      case 'free_youtube':
        Navigator.push(context,
            MaterialPageRoute(builder: (_) => PlaylistTabScreen(
              subCategoryId:
              subcategorySerials[0].id,
              categoryName: 'Serials',
            )));
        break;

      case 'free_bhakti':
        Navigator.push(context,
            MaterialPageRoute(builder: (_) => JaapView()));
        break;

      case 'free_livedarshan':
        Navigator.push(context,
            MaterialPageRoute(builder: (_) => const PlaylistTabScreen(
              subCategoryId: 178, categoryName: 'Live',)));
        break;

      case 'free_katha':
        Navigator.push(context,
            MaterialPageRoute(builder: (_) => PlaylistTabScreen(
              subCategoryId: subcategory[0].id,
              categoryName: 'Spritual Guru',
            )));
        break;

      default:
        debugPrint('No route found for $title');
    }
  }

  final List<Map<String, String>> items = [
    {
      'title': 'start_jap',
      'image': 'assets/images/allcategories/animate/jaap_animation.gif',
      'color': '0xFFFF4757' // Vibrant Red
    },
    {
      'title': 'free_kundli',
      'image': 'assets/images/allcategories/animate/Kundli_milan_icon animation.gif',
      'color': '0xFFFF9F43' // Orange
    },
    {
      'title': 'free_sangeet',
      'image': 'assets/testImage/categories/sangeet_Icon.png',
      'color': '0xFF5F27CD' // Royal Purple
    },
    {
      'title': 'free_blogs',
      'image': 'assets/testImage/categories/blogs_icon.png',
      'color': '0xFFFF6B9D' // Hot Pink
    },
    {
      'title': 'free_serial',
      'image': 'assets/images/allcategories/Youtube_video icon.png',
      'color': '0xFF10AC84' // Forest Green
    },
    {
      'title': 'free_youtube',
      'image': 'assets/images/allcategories/Youtube_video icon.png',
      'color': '0xFFEE5253' // Coral
    },
    {
      'title': 'free_bhakti',
      'image': 'assets/images/allcategories/animate/jaap_animation.gif',
      'color': '0xFF00D2D3' // Cyan
    },
    {
      'title': 'free_livedarshan',
      'image': 'assets/testImage/pooja/mandirDarshan.png',
      'color': '0xFFFECA57' // Golden Yellow
    },
    {
      'title': 'free_katha',
      'image': 'assets/images/allcategories/Youtube_video icon.png',
      'color': '0xFF576574' // Slate Blue
    },
    {
      'title': 'free_rashifal',
      'image': 'assets/testImage/rashifall/taurus.png',
      'color': '0xFF1DD1A1' // Emerald Green
    },
    {
      'title': 'free_birth',
      'image': 'assets/images/allcategories/Janam_kundli.png',
      'color': '0xFF2E86DE' // Ocean Blue
    },
    {
      'title': 'free_calculater',
      'image': 'assets/images/calculator/mulk_ank.png',
      'color': '0xFF341F97' // Deep Purple
    },
  ];


  @override
  void dispose() {
    // widget.scrollController.removeListener(_scrollListener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    // final ScrollController scrollContze;roller = ScrollController();
    double h = MediaQuery.of(context).size.height;
    final size = MediaQuery.of(context).size;

    var screenWidth = MediaQuery.of(context).size.width;
    var screenHeight = MediaQuery.of(context).size.height;

    // 2. Create the category list
    final List<CategoryItem> categories = [
      // Panchang
      CategoryItem(
        image: 'assets/testImage/categories/panchang.png',
        name: 'panchang',
        page: const MahaBhandar(tab: 1),
      ),
      // Astrology
      CategoryItem(
        image: 'assets/animated/astrology.gif',
        name: 'astrology',
        page: const AstrologyView(),
      ),
      // Pooja
      CategoryItem(
        image: 'assets/animated/pooja.gif',
        name: 'pooja',
        page: PoojaHomeView(
            tabIndex: 0, scrollController: widget.scrollController),
      ),
      // Offline Pooja
      CategoryItem(
        image: 'assets/images/allcategories/upcoming_live icon.png',
        name: 'offline_pooja',
        page: OfflinePoojaHome(
          tabIndex: 0,
        ),
      ),
      // Prasad
      CategoryItem(
        image: 'assets/animated/prasad_icon_animation.gif',
        name: 'prasad',
        page: TopSellerProductScreen(
          scrollController : _scrollController,
          sellerId: 14,
          temporaryClose: Provider.of<ShopController>(context, listen: false)
              .sellerModel
              ?.sellers?[1]
              .shop
              ?.temporaryClose,
          vacationStatus: Provider.of<ShopController>(context, listen: false)
              .sellerModel
              ?.sellers?[1]
              .shop
              ?.vacationStatus,
          vacationEndDate: Provider.of<ShopController>(context, listen: false)
              .sellerModel
              ?.sellers?[1]
              .shop
              ?.vacationEndDate,
          vacationStartDate: Provider.of<ShopController>(context, listen: false)
              .sellerModel
              ?.sellers?[1]
              .shop
              ?.vacationStartDate,
          name: Provider.of<ShopController>(context, listen: false)
              .sellerModel
              ?.sellers?[1]
              .shop
              ?.name,
          banner: Provider.of<ShopController>(context, listen: false)
              .sellerModel
              ?.sellers?[1]
              .shop
              ?.banner,
          image: Provider.of<ShopController>(context, listen: false)
              .sellerModel
              ?.sellers?[1]
              .shop
              ?.image,
        ),
      ),
      // Scripture
      CategoryItem(
        image: 'assets/testImage/categories/shaitya_icon.png',
        name: 'sahitya',
        page: const SahityaHome(),
      ),
      // Donation
      CategoryItem(
        image: 'assets/images/allcategories/animate/Daanicon animation.gif',
        name: 'donation',
        page: const DonationHomeView(),
      ),
      // Sangeet
      CategoryItem(
        image: 'assets/testImage/categories/sangeet_Icon.png',
        name: 'sangeet',
        page: const SangitHome(tabiIndex: 1),
      ),
      // YouTube
      CategoryItem(
        image: 'assets/images/allcategories/Youtube_video icon.png',
        name: 'you_tube',
        page: const YoutubeHomePage(tabIndex: 0),
      ),
      // Travel
      CategoryItem(
        name: 'tourBooking',
        page: const TourHomePage(),
        isLottie: true,
        lottiePath: 'assets/lottie/Travel.json',
        lottieSize: 37,
        image: '',
      ),
      // Jaap
      CategoryItem(
        image: 'assets/images/allcategories/animate/jaap_animation.gif',
        name: 'jaap',
        page: JaapView(),
      ),
      // Mandir
      CategoryItem(
        image: 'assets/testImage/pooja/mandirDarshan.png',
        name: 'mandir',
        page: const MandirDarshan(tabIndex: 0),
      ),
      // Ram Shalkha
      CategoryItem(
        image: 'assets/testImage/categories/ram_shalakha.png',
        name: 'ram_shalakha',
        page: const RamShalaka(),
      ),
      // Event Booking
      CategoryItem(
        image: 'assets/testImage/categories/event_booking.png',
        name: 'events_booking',
        page: const EventHome(),
      ),
      // Blogs
      CategoryItem(
        image: 'assets/testImage/categories/blogs_icon.png',
        name: 'blogs',
        page: const BlogHomePage(),
      ),
      // Meditation (Coming Soon)
      CategoryItem(
        image: 'assets/testImage/categories/meditetion_icon.png',
        name: 'meditation',
        page: Container(),
        isComingSoon: true,
        comingSoonImage: 'assets/testImage/categories/meditetion_icon.png',
      ),
      // News (Coming Soon)
      CategoryItem(
        image: 'assets/testImage/categories/news_icon.png',
        name: 'News',
        page: Container(),
        isComingSoon: true,
        comingSoonImage: 'assets/testImage/categories/news_icon.png',
      ),
      // Yoga (Coming Soon)
      CategoryItem(
        image: 'assets/testImage/categories/yoga_icon.png',
        name: 'yoga',
        page: Container(),
        isComingSoon: true,
        comingSoonImage: 'assets/testImage/categories/yoga_icon.png',
      ),
    ];

    final List<Rashi> poojaBookingImages = [
      Rashi(
          image: 'assets/testImage/poojabooking/Samsya_nivaran_puja.png',
          name: getTranslated('samsya_pooja', context) ?? 'samsya_pooja'),
      Rashi(
          image: 'assets/testImage/poojabooking/dosh_cettegary banner.gif',
          name: getTranslated('dosh_pooja', context) ?? 'dosh_pooja'),
      Rashi(
          image: 'assets/testImage/poojabooking/jaap_cettegary banner.gif',
          name: getTranslated('japp_pooja', context) ?? 'japp_pooja'),
      Rashi(
          image: 'assets/testImage/poojabooking/special_cettegary banner.gif',
          name: getTranslated('special_pooja', context) ?? 'special_pooja'),
      Rashi(
          image: 'assets/testImage/poojabooking/vip_cettegary banner.gif',
          name: getTranslated('vip_ppoja', context) ?? 'vip_ppoja'),
      Rashi(
          image:
              'assets/testImage/poojabooking/anushthan_cettegary banner  (6).gif',
          name: getTranslated('anushthan_pooja', context) ?? 'anushthan_pooja'),
      Rashi(
          image: 'assets/testImage/poojabooking/chadhava_cettegary banner .gif',
          name: getTranslated('chadhava_pooja', context) ?? 'chadhava_pooja'),
    ];

    final List<String> posterImages = [
      'https://res.klook.com/image/upload/fl_lossy.progressive,w_320,h_440,c_fill,q_85/v1698830260/banner/yrch1gimixpwx1cag4ni.webp',
      'https://res.klook.com/image/upload/fl_lossy.progressive,w_320,h_440,c_fill,q_85/v1705922879/banner/dbdstphqhnqewhfbzeyt.webp'
    ];

    final List<String> astroImage = [
      'https://i.pinimg.com/originals/17/99/04/179904fbf38563c5a738a0913533487d.jpg',
      'https://i.pinimg.com/originals/d0/87/b4/d087b43b7582ff7a94259e3ed8febcbc.jpg'
    ];

    final List<String> rashiListName = [
      'Aries',
      'Taurus',
      'Gemini',
      'Cancer',
      'Leo',
      'Virgo',
      'Libra',
      'Scorpio',
      'Sagittarius',
      'Capricorn',
      'Aquarius',
      'Pisces'
    ];

    final List<Rashi> rashiList = [
      Rashi(
          image: 'assets/testImage/rashifall/aries.jpg',
          name: getTranslated('mesh', context) ?? 'Mesh'),
      Rashi(
          image: 'assets/testImage/rashifall/taurus.jpg',
          name: getTranslated('vrashab', context) ?? 'Vrashab'),
      Rashi(
          image: 'assets/testImage/rashifall/gemini.jpg',
          name: getTranslated('mithun', context) ?? 'Mithun'),
      Rashi(
          image: 'assets/testImage/rashifall/cancer.jpg',
          name: getTranslated('kark', context) ?? 'Kark'),
      Rashi(
          image: 'assets/testImage/rashifall/leo.jpg',
          name: getTranslated('singh', context) ?? 'Singh'),
      Rashi(
          image: 'assets/testImage/rashifall/vergo.jpg',
          name: getTranslated('kanya', context) ?? 'Kanya'),
      Rashi(
          image: 'assets/testImage/rashifall/tula.gif',
          name: getTranslated('tula', context) ?? 'Tula'),
      Rashi(
          image: 'assets/testImage/rashifall/scorpio.gif',
          name: getTranslated('vrashik', context) ?? 'Vrashik'),
      Rashi(
          image: 'assets/testImage/rashifall/sagittarius.gif',
          name: getTranslated('dhanu', context) ?? 'Dhanu'),
      Rashi(
          image: 'assets/testImage/rashifall/capricorn.jpg',
          name: getTranslated('makar', context) ?? 'Makar'),
      Rashi(
          image: 'assets/testImage/rashifall/Aquarius.jpg',
          name: getTranslated('kumbh', context) ?? 'Kumbh'),
      Rashi(
          image: 'assets/testImage/rashifall/min.gif',
          name: getTranslated('meen', context) ?? 'Meen'),
    ];

    final List<Rashi> calculatorList = [
      Rashi(
          image: 'assets/images/calculator/mulk_ank.png',
          name: getTranslated('mul_ank', context) ?? 'Mul-Ank'),
      Rashi(
          image: 'assets/images/calculator/Rashi_namaakshar.gif',
          name: getTranslated('rashi_namakshar', context) ?? 'Rashi Namakshar'),
      Rashi(
          image: 'assets/images/calculator/kaal_sarp_dosh.png',
          name: getTranslated('kalsarp_dosh', context) ?? 'Kalsarp Dosh'),
      Rashi(
          image: 'assets/images/calculator/mandlik_dosh.gif',
          name: getTranslated('manglik_dosh', context) ?? 'Manglik Dosh'),
      Rashi(
          image: 'assets/images/calculator/pitra_dosh.png',
          name: getTranslated('pitra_dosh', context) ?? 'Pitra Dosh'),
      Rashi(
          image: 'assets/images/calculator/vishmottri_dasa.gif',
          name: getTranslated('vimshotri_dasha', context) ?? 'Vimshotri Dasha'),
      Rashi(
          image: 'assets/images/calculator/ratna_suzhav.gif',
          name: getTranslated('ratna_sujhaw', context) ?? 'Ratna Sujhaw'),
      Rashi(
          image: 'assets/images/calculator/rudraksha_suzhav.png',
          name: getTranslated('rudraksh_sujhaw', context) ?? 'Rudraksh Sujhaw'),
      Rashi(
          image: 'assets/images/calculator/puja_suzhav.gif',
          name: getTranslated('pooja_sujhaw', context) ?? 'Pooja Sujhaw')
    ];

    List<CategoryListModel> panchangCategoryList = [
      CategoryListModel(
          name: 'panchang',
          route:
              CupertinoPageRoute(builder: (context) => const PanchangScreen()),
          images:
              'assets/images/allcategories/animate/Panchang_icon_animated_1.gif'),
      CategoryListModel(
          name: 'choghadiya',
          route:
              CupertinoPageRoute(builder: (context) => const PanchangScreen()),
          images: 'assets/images/allcategories/Choghadiya icon.png'),
      CategoryListModel(
          name: 'hora',
          route:
              CupertinoPageRoute(builder: (context) => const PanchangScreen()),
          images:
              'assets/images/allcategories/animate/Hora icon animation.gif'),
      CategoryListModel(
          name: 'graho_ki_isthiti',
          route:
              CupertinoPageRoute(builder: (context) => const PanchangScreen()),
          images: 'assets/images/allcategories/graho_ki_sthiti.png'),
      CategoryListModel(
          name: 'shubh_muhrat',
          route: CupertinoPageRoute(builder: (context) => const MahaBhandar()),
          images: 'assets/images/allcategories/Subh muhurat.png'),
      CategoryListModel(
          name: 'fast',
          route:
              CupertinoPageRoute(builder: (context) => const PanchangScreen()),
          images: 'assets/images/allcategories/Vrat Icon.png'),
      CategoryListModel(
          name: 'festival',
          route:
              CupertinoPageRoute(builder: (context) => const PanchangScreen()),
          images: 'assets/images/allcategories/Festival icon.png'),
    ];

    List<CategoryListModel> astrologyCategoryList = [
      CategoryListModel(
          name: 'janm_kundli_li',
          route: CupertinoPageRoute(builder: (context) => const KundliForm()),
          images: 'assets/images/allcategories/Janam_kundli.png'),
      CategoryListModel(
          name: 'kundli_milan_li',
          route: CupertinoPageRoute(
              builder: (context) => const KundaliMatchingView()),
          images:
              'assets/images/allcategories/animate/Kundli_milan_icon animation.gif'),
      CategoryListModel(
          name: 'numerology',
          route:
              CupertinoPageRoute(builder: (context) => const NumeroFormView()),
          images: 'assets/images/allcategories/Newmrology.png'),
      CategoryListModel(
          name: 'lal_kitab',
          route: CupertinoPageRoute(builder: (context) => const LalKitabForm()),
          images: 'assets/images/allcategories/LalKitab_icon.png'),
      CategoryListModel(
          name: 'pdf25',
          route: CupertinoPageRoute(builder: (context) => const PdfDataView()),
          images: 'assets/images/allcategories/Pdf_25_Icon.png'),
      CategoryListModel(
          name: 'pdf50',
          route: CupertinoPageRoute(builder: (context) => const PdfDataView()),
          images: 'assets/images/allcategories/Pdf_50_pages.png'),
      CategoryListModel(
          name: 'rashifal',
          route: CupertinoPageRoute(
              builder: (context) => RashiFallView(
                    rashiNameList: rashiList,
                    rashiName: rashiList[0].name,
                    index: 0,
                    context: context,
                  )),
          images: 'assets/images/allcategories/rashifal_icon.png'),
      CategoryListModel(
          name: 'calculator',
          route:
              CupertinoPageRoute(builder: (context) => const PanchangScreen()),
          images: 'assets/images/allcategories/Calculater_icon.png'),
      CategoryListModel(
          name: 'janm_jankari_se',
          route:
              CupertinoPageRoute(builder: (context) => const PanchangScreen()),
          images: 'assets/images/allcategories/Janm_janmasri_se_jane icon.png'),
      CategoryListModel(
          name: 'shubh_muhrat',
          route: CupertinoPageRoute(
              builder: (context) => const ShubhMuhuratView()),
          images: 'assets/images/allcategories/Subh_muhurt_b.png'),
      CategoryListModel(
          name: 'yog_consultation',
          route: CupertinoPageRoute(
              builder: (context) => const AstroConsultationView()),
          images: 'assets/images/allcategories/Yog_conclustion.png'),
    ];

    // List<CategoryListModel> shopCategoryList = [
    //   CategoryListModel(
    //       name: 'rudraksh',
    //       route: CupertinoPageRoute(
    //           builder: (context) => Consumer<CategoryController>(builder:
    //                   (BuildContext context, categoryProvider, Widget? child) {
    //                 return BrandAndCategoryProductScreen(
    //                     isBrand: false,
    //                     id: categoryProvider.categoryList[1].id.toString(),
    //                     name: categoryProvider.categoryList[1].name);
    //               })),
    //       images: 'assets/images/allcategories/Rudraksha_icon.png'),
    //   CategoryListModel(
    //       name: 'gemstone',
    //       route: CupertinoPageRoute(
    //           builder: (context) => Consumer<CategoryController>(builder:
    //                   (BuildContext context, categoryProvider, Widget? child) {
    //                 return BrandAndCategoryProductScreen(
    //                     isBrand: false,
    //                     id: categoryProvider.categoryList[0].id.toString(),
    //                     name: categoryProvider.categoryList[0].name);
    //               })),
    //       images:
    //           'assets/images/allcategories/animate/gems_stone_animation_traspairant.gif'),
    //   CategoryListModel(
    //       name: 'bracelet',
    //       route: CupertinoPageRoute(
    //           builder: (context) => Consumer<CategoryController>(builder:
    //                   (BuildContext context, categoryProvider, Widget? child) {
    //                 return BrandAndCategoryProductScreen(
    //                     isBrand: false,
    //                     id: categoryProvider.categoryList[4].id.toString(),
    //                     name: categoryProvider.categoryList[4].name);
    //               })),
    //       images: 'assets/images/allcategories/bracelet_icon.png'),
    //   CategoryListModel(
    //       name: 'pendal',
    //       route: CupertinoPageRoute(
    //           builder: (context) => Consumer<CategoryController>(builder:
    //                   (BuildContext context, categoryProvider, Widget? child) {
    //                 return BrandAndCategoryProductScreen(
    //                     isBrand: false,
    //                     id: categoryProvider.categoryList[4].id.toString(),
    //                     name: categoryProvider.categoryList[4].name);
    //               })),
    //       images: 'assets/images/allcategories/pendle_icon.png'),
    //   CategoryListModel(
    //       name: 'mala',
    //       route: CupertinoPageRoute(
    //           builder: (context) => Consumer<CategoryController>(builder:
    //                   (BuildContext context, categoryProvider, Widget? child) {
    //                 return BrandAndCategoryProductScreen(
    //                     isBrand: false,
    //                     id: categoryProvider.categoryList[4].id.toString(),
    //                     name: categoryProvider.categoryList[4].name);
    //               })),
    //       images: 'assets/images/allcategories/mala_icon.png'),
    //   CategoryListModel(
    //       name: 'pooja_samagri',
    //       route: CupertinoPageRoute(
    //           builder: (context) => Consumer<CategoryController>(builder:
    //                   (BuildContext context, categoryProvider, Widget? child) {
    //                 return BrandAndCategoryProductScreen(
    //                     isBrand: false,
    //                     id: categoryProvider.categoryList[3].id.toString(),
    //                     name: categoryProvider.categoryList[3].name);
    //               })),
    //       images: 'assets/images/allcategories/Pujan_samagri.png'),
    //   CategoryListModel(
    //       name: 'yantra',
    //       route: CupertinoPageRoute(
    //           builder: (context) => Consumer<CategoryController>(builder:
    //                   (BuildContext context, categoryProvider, Widget? child) {
    //                 return BrandAndCategoryProductScreen(
    //                     isBrand: false,
    //                     id: categoryProvider.categoryList[2].id.toString(),
    //                     name: categoryProvider.categoryList[2].name);
    //               })),
    //       images: 'assets/images/allcategories/Yantra_icon.png'),
    //   CategoryListModel(
    //       name: 'fengshui',
    //       route: CupertinoPageRoute(
    //           builder: (context) => Consumer<CategoryController>(builder:
    //                   (BuildContext context, categoryProvider, Widget? child) {
    //                 return BrandAndCategoryProductScreen(
    //                     isBrand: false,
    //                     id: categoryProvider.categoryList[1].id.toString(),
    //                     name: categoryProvider.categoryList[1].name);
    //               })),
    //       images: 'assets/images/allcategories/Fengsui_icon 2.png'),
    //   CategoryListModel(
    //       name: 'itr',
    //       route: CupertinoPageRoute(
    //           builder: (context) => Consumer<CategoryController>(builder:
    //                   (BuildContext context, categoryProvider, Widget? child) {
    //                 return BrandAndCategoryProductScreen(
    //                     isBrand: false,
    //                     id: categoryProvider.categoryList[3].id.toString(),
    //                     name: categoryProvider.categoryList[3].name);
    //               })),
    //       images: 'assets/images/allcategories/Itra icon.png'),
    // ];

    List<String> poojaCategoryList = [
      'assets/testImage/pooja/Samasya nivaran pooja icon.png',
      'assets/testImage/pooja/Dosh nivaran puja icon.png',
      'assets/testImage/pooja/Mantra icon.png',
      'assets/testImage/pooja/Special puja.png',
      'assets/testImage/pooja/Vip puja icon.png',
      'assets/testImage/pooja/Aanusthan icon.png',
      'assets/testImage/pooja/Chadava icon.png',
    ];

    List<String> mandirCategoryList = [
      'assets/images/allcategories/animate/Shiv_animation.gif',
      'assets/images/allcategories/51_shakti_peeth icon.png',
      'assets/images/allcategories/animate/4 dham icon animation.gif',
      'assets/images/allcategories/Iskcon_icon.png',
      'assets/images/allcategories/other_dev_dham icon.png',
      'assets/images/allcategories/other_dev_dham icon.png',
    ];

    List<CategoryListModel> astrotalkCategoryList = [
      CategoryListModel(
          name: 'cahts',
          route:
              CupertinoPageRoute(builder: (context) => const PanchangScreen()),
          images: 'assets/images/allcategories/Chat_astrologer icon.png'),
      CategoryListModel(
          name: 'voice_call',
          route:
              CupertinoPageRoute(builder: (context) => const PanchangScreen()),
          images: 'assets/images/allcategories/Call_astrologer icon.png'),
      CategoryListModel(
          name: 'vedio_call',
          route:
              CupertinoPageRoute(builder: (context) => const PanchangScreen()),
          images: 'assets/images/allcategories/Video_call_astrologer icon.png'),
      CategoryListModel(
          name: 'live_astrologers',
          route:
              CupertinoPageRoute(builder: (context) => const PanchangScreen()),
          images: 'assets/images/allcategories/Live_astrologer icon.png'),
      CategoryListModel(
          name: 'upcoming_astrologers',
          route:
              CupertinoPageRoute(builder: (context) => const PanchangScreen()),
          images: 'assets/images/allcategories/upcoming_live icon.png'),
    ];

    List<CategoryListModel> sahityaCategoryList = [
      CategoryListModel(
          name: 'geeta_book',
          route:
              CupertinoPageRoute(builder: (context) => const SahityaChapters()),
          images: 'assets/images/allcategories/Bhagvat_git icon.png'),
      CategoryListModel(
          name: 'upnishad_book',
          route:
              CupertinoPageRoute(builder: (context) => const PanchangScreen()),
          images: 'assets/images/allcategories/Upnishad_icon.png'),
      CategoryListModel(
          name: 'mahabharat_book',
          route:
              CupertinoPageRoute(builder: (context) => const PanchangScreen()),
          images: 'assets/images/allcategories/Mahabharat icon.png'),
      CategoryListModel(
          name: 'shiv_puran_book',
          route:
              CupertinoPageRoute(builder: (context) => const PanchangScreen()),
          images: 'assets/images/allcategories/Shiv_puran_icon.png'),
      CategoryListModel(
          name: 'ramayan_book',
          route:
              CupertinoPageRoute(builder: (context) => const PanchangScreen()),
          images: 'assets/images/allcategories/Ramayan icon.png'),
    ];

    List<CategoryListModel> paidCategoryList = [
      /// Pooja Book
      CategoryListModel(
          name: 'geeta_book',
          route: CupertinoPageRoute(
            builder: (context) => PoojaHomeView(
              tabIndex: 0,
              scrollController: widget.scrollController,
            ),
          ),
          images: 'assets/images/allcategories/paid_pooja.png'),

      /// Chadhava
      CategoryListModel(
          name: 'offer_chadhava',
          route: CupertinoPageRoute(
            builder: (context) => PoojaHomeView(
              tabIndex: 7,
              scrollController: widget.scrollController,
            ),
          ),
          images: 'assets/images/allcategories/paid_chadhava.png'),

      /// Tour Book
      CategoryListModel(
          name: 'tour_book',
          route: CupertinoPageRoute(builder: (context) => const TourHomePage()),
          images: 'assets/mandir_images/sangrah_tour.png'),

      /// Prasad
      CategoryListModel(
          name: 'prasad',
          route: CupertinoPageRoute(
              builder: (context) => TopSellerProductScreen(
                scrollController : _scrollController,
                    sellerId: 14,
                    temporaryClose:
                        Provider.of<ShopController>(context, listen: false)
                            .sellerModel
                            ?.sellers?[1]
                            .shop
                            ?.temporaryClose,
                    vacationStatus:
                        Provider.of<ShopController>(context, listen: false)
                            .sellerModel
                            ?.sellers?[1]
                            .shop
                            ?.vacationStatus,
                    vacationEndDate:
                        Provider.of<ShopController>(context, listen: false)
                            .sellerModel
                            ?.sellers?[1]
                            .shop
                            ?.vacationEndDate,
                    vacationStartDate:
                        Provider.of<ShopController>(context, listen: false)
                            .sellerModel
                            ?.sellers?[1]
                            .shop
                            ?.vacationStartDate,
                    name: Provider.of<ShopController>(context, listen: false)
                        .sellerModel
                        ?.sellers?[1]
                        .shop
                        ?.name,
                    banner: Provider.of<ShopController>(context, listen: false)
                        .sellerModel
                        ?.sellers?[1]
                        .shop
                        ?.banner,
                    image: Provider.of<ShopController>(context, listen: false)
                        .sellerModel
                        ?.sellers?[1]
                        .shop
                        ?.image,
                  )),
          images: 'assets/images/allcategories/paid_prasad.png'),

      /// Pandit Book
      CategoryListModel(
          name: 'offline_pooja',
          route: CupertinoPageRoute(
              builder: (context) => OfflinePoojaHome(
                    tabIndex: 0,
                  )),
          images: 'assets/images/allcategories/paid_pandit.png'),

      /// Event Book
      CategoryListModel(
          name: 'events_booking',
          route: CupertinoPageRoute(builder: (context) => const EventHome()),
          images: 'assets/images/allcategories/paid_event.png'),

      /// Mandir Darshan
      CategoryListModel(
          name: 'mandir',
          route: CupertinoPageRoute(
            builder: (context) => const MandirDarshan(tabIndex: 0),
          ),
          images: 'assets/images/allcategories/paid_darshan.png'),

      /// Donation
      CategoryListModel(
          name: 'donation',
          route: CupertinoPageRoute(
              builder: (context) => const DonationHomeView()),
          images: 'assets/mandir_images/sangrah_donation.png'),
    ];

    List<String> vedioCategoryList = [
      'assets/images/allcategories/Series_icon.png',
      'assets/images/allcategories/Bhajan.png',
      'assets/images/allcategories/Youtube_video icon.png',
      'assets/images/allcategories/Katha_icon.png',
      'assets/images/allcategories/Spritual_guru.png',
    ];

    List<CategoryListModel> musicCategoryList = [
      CategoryListModel(
          name: 'hanuman_ji',
          route:
              CupertinoPageRoute(builder: (context) => const PanchangScreen()),
          images: 'assets/images/allcategories/Hanuman_jii.png'),
      CategoryListModel(
          name: 'ram_ji',
          route:
              CupertinoPageRoute(builder: (context) => const PanchangScreen()),
          images: 'assets/images/allcategories/Ram_jii.png'),
      CategoryListModel(
          name: 'durga_ma',
          route:
              CupertinoPageRoute(builder: (context) => const PanchangScreen()),
          images: 'assets/images/allcategories/Durga_maa.png'),
      CategoryListModel(
          name: 'shiv_ji',
          route:
              CupertinoPageRoute(builder: (context) => const PanchangScreen()),
          images: 'assets/images/allcategories/Shiv_jii.png'),
      CategoryListModel(
          name: 'ganesh_ji',
          route:
              CupertinoPageRoute(builder: (context) => const PanchangScreen()),
          images: 'assets/images/allcategories/Ganesh_jii.png'),
    ];

    //All category list Widget
    Widget allCategoryListWidget(
        {required String image, required String name, required Color color}) {
      return SizedBox(
        height: 50,
        child: Row(
          children: [
            Expanded(
              flex: 0,
              child: Image.asset(
                image,
                height: 35,
                width: 35,
              ),
            ),
            const SizedBox(
              width: 10,
            ),
            Expanded(
              flex: 1,
              child: Text(
                name,
                textAlign: TextAlign.start,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: titleHeader.copyWith(
                    color: color,
                    fontSize: 16,
                    letterSpacing: 0.5,
                    fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      );
    }

    List<CategoriesModel> filteredCategories =
        category.where((cat) => cat.status != 0).toList();
    return Scaffold(
      backgroundColor: Colors.white,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: isScrolling
          ? Padding(
              padding: const EdgeInsets.only(bottom: 80.0),
              child: SizedBox(
                width: 60,
                child: Hidable(
                  controller: widget.scrollController,
                  child: FloatingActionButton(
                    onPressed: () {
                      widget.scrollController.animateTo(0.0,
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.ease);
                      setState(() {
                        isScrolling = false;
                      });
                    },
                    backgroundColor: Theme.of(context).primaryColor,
                    child: const Icon(
                      Icons.arrow_circle_up_outlined,
                      color: Colors.white,
                      size: 40,
                    ),
                  ),
                ),
              ),
            )
          : const SizedBox(),
      body: SafeArea(
        child: RefreshIndicator(
          color: Colors.orange,
          onRefresh: () async {
            await seactionSwitch();
            await _initAsyncOperations();
          },
          child: CustomScrollView(
            controller: widget.scrollController,
            slivers: [
              //Appbar
              SliverAppBar(
                floating: true,
                elevation: 0,
                centerTitle: true,
                automaticallyImplyLeading: false,
                backgroundColor: Theme.of(context).highlightColor,
                flexibleSpace: Padding(
                  padding: const EdgeInsets.only(top: 10, left: 10),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                          context,
                          PageAnimationTransition(
                              page:
                              MoreScreen(scrollController: _scrollController),
                              pageAnimationType: LeftToRightTransition()));
                    },
                    child: Row(
                      children: [
                        Stack(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(100),
                                border: Border.all(color: Colors.deepOrange, width: 1.5),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(100),
                                child: CustomImageWidget(
                                  image:
                                  '${Provider.of<SplashController>(context, listen: false).baseUrls!.customerImageUrl}/'
                                      '${Provider.of<ProfileController>(context, listen: false).userInfoModel?.image}',
                                  width: 40,
                                  height: 40,
                                  fit: BoxFit.fill,
                                  placeholder: Images.guestProfile,
                                ),
                              ),
                            ),
                            // Badge Icon
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                padding: const EdgeInsets.all(1),
                                decoration: BoxDecoration(
                                  color: Colors.white, // Badge color
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.grey, width: 1.0),
                                ),
                                child: const Icon(Icons.menu,size: 10,color: Colors.black,)
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                title: Image.asset(Images.logoNameImage, height: 70),
                actions: [
                  Consumer<NotificationController>(builder: (context, notificationProvider, _) {
                    return IconButton(
                        onPressed: () => Navigator.push(
                            context,
                            CupertinoPageRoute(
                                builder: (_) => const NotificationScreen())),
                        icon: Stack(clipBehavior: Clip.none, children: [
                          Image.asset(Images.notification,
                              height: Dimensions.iconSizeDefault,
                              width: Dimensions.iconSizeDefault,
                              color: ColorResources.getPrimary(context)),
                          Positioned(
                              top: -4,
                              right: -4,
                              child: CircleAvatar(
                                  radius:
                                      ResponsiveHelper.isTab(context) ? 10 : 7,
                                  backgroundColor: ColorResources.red,
                                  child: Text(
                                      notificationProvider.notificationModel
                                              ?.newNotificationItem
                                              .toString() ??
                                          '0',
                                      style: titilliumSemiBold.copyWith(
                                          color: ColorResources.white,
                                          fontSize:
                                              Dimensions.fontSizeExtraSmall))))
                        ]));
                  }),
                  const SizedBox(width: 10,),
                  Padding(
                    padding:
                        const EdgeInsets.only(left: 5, right: 5, bottom: 10),
                    child: Lottie.asset('assets/lottie/jyoti2.json'),
                  )
                ],
              ),

              SliverToBoxAdapter(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 10),
                      Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                flex: 1,
                                child: SizedBox(
                                  width: screenWidth / 1.32,
                                  height: 80,
                                  child:
                                      NotificationListener<ScrollNotification>(
                                    onNotification: (notification) {
                                      if (notification
                                          is UserScrollNotification) {
                                        _userInteracting =
                                            notification.direction !=
                                                ScrollDirection.idle;
                                        if (_userInteracting) {
                                          _autoScrollActive = false;
                                          Future.delayed(
                                              const Duration(seconds: 5), () {
                                            if (mounted && !_userInteracting) {
                                              _autoScrollActive = true;
                                            }
                                          });
                                        }
                                      }
                                      return false;
                                    },
                                    child: ListView.builder(
                                        controller: _scrollController,
                                        scrollDirection: Axis.horizontal,
                                        itemCount: categories.length,
                                        physics: const ScrollPhysics(
                                            parent: BouncingScrollPhysics()),
                                        itemBuilder: (context, index) {
                                          final item = categories[index];
                                          return Padding(
                                              padding: EdgeInsets.only(
                                                left: index == 0 ? 20 : 10,
                                                right: index ==
                                                        categories.length - 1
                                                    ? 20
                                                    : 10,
                                              ),
                                              child: item.isLottie
                                                  ? InkWell(
                                                      onTap: () {
                                                        Navigator.push(
                                                          context,
                                                          PageAnimationTransition(
                                                            page: item.page,
                                                            pageAnimationType:
                                                                RightToLeftTransition(),
                                                          ),
                                                        );
                                                      },
                                                      child: Column(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: [
                                                          Container(
                                                            height: 40,
                                                            width: 40,
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(4),
                                                            decoration:
                                                                BoxDecoration(
                                                              gradient:
                                                                  const LinearGradient(
                                                                colors: [
                                                                  Colors.white,
                                                                  Colors.white
                                                                ],
                                                                begin: Alignment
                                                                    .topLeft,
                                                                end: Alignment
                                                                    .bottomRight,
                                                              ),
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          6),
                                                            ),
                                                            child: Lottie.asset(
                                                              item.lottiePath!,
                                                              height: item
                                                                  .lottieSize,
                                                              width: item
                                                                  .lottieSize,
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                              height: 3),
                                                          Text(
                                                            '${getTranslated(item.name, context)}',
                                                            style: titleHeader
                                                                .copyWith(
                                                              color:
                                                                  Colors.black,
                                                              fontSize: Dimensions
                                                                  .fontSizeSmall,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                            ),
                                                            maxLines: 1,
                                                          ),
                                                        ],
                                                      ),
                                                    )
                                                  : InkWell(
                                                      onTap: () {
                                                        if (item.isComingSoon) {
                                                          showComingSoonDialog(
                                                              context,
                                                              item.comingSoonImage!);
                                                        } else {
                                                          Navigator.push(
                                                            context,
                                                            PageAnimationTransition(
                                                              page: item.page,
                                                              pageAnimationType:
                                                                  RightToLeftTransition(),
                                                            ),
                                                          );
                                                        }
                                                      },
                                                      child: Column(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: [
                                                          Container(
                                                            height: 40,
                                                            width: 40,
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(4),
                                                            decoration:
                                                                BoxDecoration(
                                                              gradient:
                                                                  const LinearGradient(
                                                                colors: [
                                                                  Colors.white,
                                                                  Colors.white
                                                                ],
                                                                begin: Alignment
                                                                    .topLeft,
                                                                end: Alignment
                                                                    .bottomRight,
                                                              ),
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          6),
                                                            ),
                                                            child: Image.asset(
                                                              item.image,
                                                              height: 40,
                                                              width: 40,
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                              height: 3),
                                                          Center(
                                                              child: Text(
                                                            '${getTranslated(item.name, context)}',
                                                            textAlign: TextAlign
                                                                .center,
                                                            maxLines: 1,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            style: titleHeader.copyWith(
                                                                color: Colors
                                                                    .black,
                                                                fontSize: 12,
                                                                letterSpacing:
                                                                    0.5,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600),
                                                          )),
                                                        ],
                                                      ),
                                                    )
                                              // CategroyWidgetExplore(
                                              //     image: item.image,
                                              //     name: getTranslated(
                                              //         item.name,
                                              //         context) ??
                                              //         item.name,
                                              //     color: Colors.black,
                                              //     onTap: () {
                                              //       if (item
                                              //           .isComingSoon) {
                                              //         showComingSoonDialog(
                                              //             context,
                                              //             item.comingSoonImage!);
                                              //       } else {
                                              //         Navigator.push(
                                              //           context,
                                              //           PageAnimationTransition(
                                              //             page:
                                              //             item.page,
                                              //             pageAnimationType:
                                              //             RightToLeftTransition(),
                                              //           ),
                                              //         );
                                              //       }
                                              //     },
                                              //   )
                                              );
                                        }),
                                  ),
                                ),
                              ),

                              //All category
                              Expanded(
                                flex: 0,
                                child: Container(
                                  margin: const EdgeInsets.symmetric(
                                      horizontal: 10),
                                  decoration: const BoxDecoration(),
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(8),
                                    onTap: () {
                                      showModalBottomSheet(
                                          context: context,
                                          isScrollControlled: true,
                                          builder: (context) {
                                            return StatefulBuilder(builder:
                                                (BuildContext context,
                                                    StateSetter modalSetter) {
                                              return SingleChildScrollView(
                                                child: Container(
                                                  height: 650,
                                                  padding:
                                                      const EdgeInsets.all(10),
                                                  child: Padding(
                                                      padding: EdgeInsets.only(
                                                          bottom: MediaQuery.of(
                                                                  context)
                                                              .viewInsets
                                                              .bottom),
                                                      child: Stack(
                                                        children: [
                                                          !gridList
                                                              ? DelayedDisplay(
                                                                  slidingBeginOffset:
                                                                      const Offset(
                                                                          0,
                                                                          0.4),
                                                                  delay: const Duration(
                                                                      milliseconds:
                                                                          300),
                                                                  child:
                                                                      SingleChildScrollView(
                                                                    child: Column(
                                                                        children: [
                                                                          const SizedBox(
                                                                            height:
                                                                                60,
                                                                          ),
                                                                          // Paid Services
                                                                          PaidServicesGrid(
                                                                            servicesList:
                                                                                paidCategoryList,
                                                                          ),

                                                                          const SizedBox(
                                                                            height:
                                                                                10,
                                                                          ),
                                                                          //panchang grid
                                                                          ExplorePanchangGrid(
                                                                              panchangCategoryList: panchangCategoryList,
                                                                              address2: address2,
                                                                              address1: address1,
                                                                              lat: lat,
                                                                              long: long),

                                                                          // Astrology grid
                                                                          const SizedBox(
                                                                            height:
                                                                                10,
                                                                          ),
                                                                          ExploreAstrologyGrid(
                                                                              astrologyCategoryList: astrologyCategoryList),

                                                                          // Shop grid
                                                                          const SizedBox(
                                                                            height:
                                                                                10,
                                                                          ),
                                                                          const ExploreShopCategroyGrid(),

                                                                          // Pooja grid
                                                                          const SizedBox(
                                                                            height:
                                                                                10,
                                                                          ),
                                                                          ExplorePoojaGrid(
                                                                              categoryPoojaModelList: categoryPoojaModelList,
                                                                              widget: widget,
                                                                              poojaCategoryList: poojaCategoryList),

                                                                          // Mandir grid
                                                                          const SizedBox(
                                                                            height:
                                                                                10,
                                                                          ),
                                                                          ExploreMandirGrid(
                                                                              darshanCategoryModelList: darshanCategoryModelList,
                                                                              mandirCategoryList: mandirCategoryList),

                                                                          // Astrotalk grid
                                                                          const SizedBox(
                                                                            height:
                                                                                10,
                                                                          ),
                                                                          ExploreAstroTalkGrid(
                                                                              astrotalkCategoryList: astrotalkCategoryList),

                                                                          // Sahitya grid
                                                                          const SizedBox(
                                                                            height:
                                                                                10,
                                                                          ),
                                                                          ExploreSahityaGrid(
                                                                              sahityaCategoryList: sahityaCategoryList,
                                                                              address2: address2,
                                                                              address1: address1,
                                                                              lat: lat,
                                                                              long: long),

                                                                          // Video grid
                                                                          const SizedBox(
                                                                            height:
                                                                                10,
                                                                          ),
                                                                          ExploreVideoGrid(
                                                                              filteredCategories: filteredCategories,
                                                                              vedioCategoryList: vedioCategoryList),

                                                                          // Music grid
                                                                          const SizedBox(
                                                                            height:
                                                                                10,
                                                                          ),
                                                                          ExploreMusicGrid(
                                                                              sangeetModelList: sangeetModelList),
                                                                        ]),
                                                                  ),
                                                                )

//                                                                     )
// >>>>>>> main
                                                              : DelayedDisplay(
                                                                  slidingBeginOffset:
                                                                      const Offset(
                                                                          0,
                                                                          0.4),
                                                                  delay: const Duration(
                                                                      milliseconds:
                                                                          300),
                                                                  child:
                                                                      SingleChildScrollView(
                                                                    child: Column(
                                                                        crossAxisAlignment:
                                                                            CrossAxisAlignment.start,
                                                                        children: [
                                                                          //panchang list
                                                                          const SizedBox(
                                                                            height:
                                                                                60,
                                                                          ),
                                                                          Container(
                                                                            padding:
                                                                                const EdgeInsets.all(10),
                                                                            margin:
                                                                                const EdgeInsets.all(4),
                                                                            width:
                                                                                double.infinity,
                                                                            decoration:
                                                                                BoxDecoration(
                                                                              boxShadow: [
                                                                                BoxShadow(color: Colors.orange.shade50, blurRadius: 10.0, spreadRadius: 2),
                                                                              ],
                                                                              color: Colors.white,
                                                                              borderRadius: BorderRadius.circular(15),
                                                                            ),
                                                                            child:
                                                                                Column(
                                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                                              children: [
                                                                                const Padding(
                                                                                  padding: EdgeInsets.only(left: 10.0),
                                                                                  child: Text(
                                                                                    'Panchang',
                                                                                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                                                                                  ),
                                                                                ),
// <<<<<<< pravin_mspl
// =======

//                                                                               // Astrology list
// >>>>>>> main
                                                                                const SizedBox(
                                                                                  height: 10,
                                                                                ),
                                                                                ListView.builder(
                                                                                  physics: const NeverScrollableScrollPhysics(),
                                                                                  shrinkWrap: true,
                                                                                  itemCount: panchangCategoryList.length,
                                                                                  itemBuilder: (context, index) {
                                                                                    return InkWell(
                                                                                        onTap: () {
                                                                                          Navigator.push(context, PageAnimationTransition(page: const MahaBhandar(tab: 1), pageAnimationType: RightToLeftTransition()));
                                                                                        },
                                                                                        child: allCategoryListWidget(image: panchangCategoryList[index].images, name: getTranslated(panchangCategoryList[index].name, context) ?? 'Panchang', color: Colors.black));
                                                                                  },
                                                                                ),
                                                                              ],
                                                                            ),
                                                                          ),

                                                                          // Astrology list
                                                                          const SizedBox(
                                                                            height:
                                                                                10,
                                                                          ),
                                                                          Container(
                                                                            padding:
                                                                                const EdgeInsets.all(10),
                                                                            margin:
                                                                                const EdgeInsets.all(4),
                                                                            width:
                                                                                double.infinity,
                                                                            decoration:
                                                                                BoxDecoration(
                                                                              boxShadow: [
                                                                                BoxShadow(color: Colors.orange.shade50, blurRadius: 10.0, spreadRadius: 2),
                                                                              ],
                                                                              color: Colors.white,
                                                                              borderRadius: BorderRadius.circular(15),
                                                                            ),
                                                                            child:
                                                                                Column(
                                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                                              children: [
                                                                                const Padding(
                                                                                  padding: EdgeInsets.only(left: 10.0),
                                                                                  child: Text(
                                                                                    'Astrology',
                                                                                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                                                                                  ),
                                                                                ),
// <<<<<<< pravin_mspl
// =======

//                                                                               // Shop list
// >>>>>>> main
                                                                                const SizedBox(
                                                                                  height: 10,
                                                                                ),
                                                                                ListView.builder(
                                                                                  physics: const NeverScrollableScrollPhysics(),
                                                                                  shrinkWrap: true,
                                                                                  itemCount: astrologyCategoryList.length,
                                                                                  itemBuilder: (context, index) {
                                                                                    return InkWell(
                                                                                        onTap: () {
                                                                                          Navigator.push(context, astrologyCategoryList[index].route);
                                                                                        },
                                                                                        child: allCategoryListWidget(image: astrologyCategoryList[index].images, name: getTranslated(astrologyCategoryList[index].name, context) ?? 'Panchang', color: Colors.black));
                                                                                  },
                                                                                ),
// <<<<<<< pravin_mspl
                                                                              ],
                                                                            ),
                                                                          ),

                                                                          // Shop list
                                                                          const SizedBox(
                                                                            height:
                                                                                10,
                                                                          ),
                                                                          Consumer<
                                                                              CategoryController>(
                                                                            builder: (context,
                                                                                categoryProvider,
                                                                                child) {
                                                                              return categoryProvider.categoryAllList.isNotEmpty
                                                                                  ? Container(
                                                                                      padding: const EdgeInsets.all(10),
                                                                                      margin: const EdgeInsets.all(4),
                                                                                      width: double.infinity,
                                                                                      decoration: BoxDecoration(
                                                                                        boxShadow: [
                                                                                          BoxShadow(color: Colors.orange.shade50, blurRadius: 10.0, spreadRadius: 2),
                                                                                        ],
                                                                                        color: Colors.white,
                                                                                        borderRadius: BorderRadius.circular(15),
// =======
//                                                                               // Container(
//                                                                               //   padding: const EdgeInsets
//                                                                               //       .all(
//                                                                               //       10),
//                                                                               //   margin: const EdgeInsets
//                                                                               //       .all(
//                                                                               //       4),
//                                                                               //   width: double
//                                                                               //       .infinity,
//                                                                               //   decoration:
//                                                                               //       BoxDecoration(
//                                                                               //     boxShadow: [
//                                                                               //       BoxShadow(
//                                                                               //           color: Colors.orange.shade50,
//                                                                               //           blurRadius: 10.0,
//                                                                               //           spreadRadius: 2),
//                                                                               //     ],
//                                                                               //     color:
//                                                                               //         Colors.white,
//                                                                               //     borderRadius:
//                                                                               //         BorderRadius.circular(15),
//                                                                               //   ),
//                                                                               //   child:
//                                                                               //       Column(
//                                                                               //     crossAxisAlignment:
//                                                                               //         CrossAxisAlignment.start,
//                                                                               //     children: [
//                                                                               //       const Padding(
//                                                                               //         padding: EdgeInsets.only(left: 10.0),
//                                                                               //         child: Text(
//                                                                               //           "Shop",
//                                                                               //           style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//                                                                               //         ),
//                                                                               //       ),
//                                                                               //       const SizedBox(
//                                                                               //         height: 10,
//                                                                               //       ),
//                                                                               //       ListView.builder(
//                                                                               //         physics: const NeverScrollableScrollPhysics(),
//                                                                               //         shrinkWrap: true,
//                                                                               //         itemCount: shopCategoryList.length,
//                                                                               //         itemBuilder: (context, index) {
//                                                                               //           return InkWell(
//                                                                               //               onTap: () {
//                                                                               //                 Navigator.push(
//                                                                               //                     context, shopCategoryList[index].route);
//                                                                               //               },
//                                                                               //               child: allCategoryListWidget(image: shopCategoryList[index].images, name: getTranslated(shopCategoryList[index].name, context) ?? 'Panchang', color: Colors.black));
//                                                                               //         },
//                                                                               //       ),
//                                                                               //     ],
//                                                                               //   ),
//                                                                               // ),

//                                                                               // Pooja list
//                                                                               const SizedBox(
//                                                                                 height: 10,
// >>>>>>> main
                                                                                      ),
                                                                                      child: Column(
                                                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                                                        children: [
                                                                                          const Padding(
                                                                                            padding: EdgeInsets.only(left: 10.0),
                                                                                            child: Text(
                                                                                              'Shop',
                                                                                              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                                                                                            ),
                                                                                          ),
                                                                                          const SizedBox(
                                                                                            height: 10,
                                                                                          ),
                                                                                          ListView.builder(
                                                                                            physics: const NeverScrollableScrollPhysics(),
                                                                                            shrinkWrap: true,
                                                                                            itemCount: categoryProvider.categoryAllList.length,
                                                                                            itemBuilder: (context, index) {
                                                                                              var baseController = Provider.of<SplashController>(context, listen: false);
                                                                                              return InkWell(
                                                                                                  onTap: () {
                                                                                                    Navigator.push(context, CupertinoPageRoute(builder: (_) => BrandAndCategoryProductScreen(isBrand: false, id: categoryProvider.categoryAllList[index].id.toString(), name: categoryProvider.categoryAllList[index].name)));
                                                                                                  },
                                                                                                  child: SizedBox(
                                                                                                    height: 50,
                                                                                                    child: Row(
                                                                                                      children: [
                                                                                                        Expanded(
                                                                                                          flex: 0,
                                                                                                          child: CachedNetworkImage(
                                                                                                            imageUrl: '${baseController.baseUrls?.categoryImageUrl}/${categoryProvider.categoryAllList[index].icon}',
                                                                                                            height: 35,
                                                                                                            width: 35,
                                                                                                            errorWidget: (context, url, error) => const Icon(
                                                                                                              Icons.broken_image,
                                                                                                              color: Colors.grey,
                                                                                                              size: 24,
                                                                                                            ),
                                                                                                          ),
                                                                                                        ),
                                                                                                        const SizedBox(
                                                                                                          width: 10,
                                                                                                        ),
                                                                                                        Expanded(
                                                                                                          flex: 1,
                                                                                                          child: Text(
                                                                                                            '${categoryProvider.categoryAllList[index].name}',
                                                                                                            textAlign: TextAlign.start,
                                                                                                            maxLines: 2,
                                                                                                            overflow: TextOverflow.ellipsis,
                                                                                                            style: titleHeader.copyWith(color: Colors.black, fontSize: 16, letterSpacing: 0.5, fontWeight: FontWeight.w600),
                                                                                                          ),
                                                                                                        ),
                                                                                                      ],
                                                                                                    ),
                                                                                                  ));
                                                                                            },
                                                                                          ),
                                                                                        ],
                                                                                      ),
                                                                                    )
                                                                                  : const CategoryShimmerWidget();
                                                                            },
                                                                          ),
                                                                          // Container(
                                                                          //   padding: const EdgeInsets
                                                                          //       .all(
                                                                          //       10),
                                                                          //   margin: const EdgeInsets
                                                                          //       .all(
                                                                          //       4),
                                                                          //   width: double
                                                                          //       .infinity,
                                                                          //   decoration:
                                                                          //       BoxDecoration(
                                                                          //     boxShadow: [
                                                                          //       BoxShadow(
                                                                          //           color: Colors.orange.shade50,
                                                                          //           blurRadius: 10.0,
                                                                          //           spreadRadius: 2),
                                                                          //     ],
                                                                          //     color:
                                                                          //         Colors.white,
                                                                          //     borderRadius:
                                                                          //         BorderRadius.circular(15),
                                                                          //   ),
                                                                          //   child:
                                                                          //       Column(
                                                                          //     crossAxisAlignment:
                                                                          //         CrossAxisAlignment.start,
                                                                          //     children: [
                                                                          //       const Padding(
                                                                          //         padding: EdgeInsets.only(left: 10.0),
                                                                          //         child: Text(
                                                                          //           "Shop",
                                                                          //           style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                                                                          //         ),
                                                                          //       ),
                                                                          //       const SizedBox(
                                                                          //         height: 10,
                                                                          //       ),
                                                                          //       ListView.builder(
                                                                          //         physics: const NeverScrollableScrollPhysics(),
                                                                          //         shrinkWrap: true,
                                                                          //         itemCount: shopCategoryList.length,
                                                                          //         itemBuilder: (context, index) {
                                                                          //           return InkWell(
                                                                          //               onTap: () {
                                                                          //                 Navigator.push(
                                                                          //                     context, shopCategoryList[index].route);
                                                                          //               },
                                                                          //               child: allCategoryListWidget(image: shopCategoryList[index].images, name: getTranslated(shopCategoryList[index].name, context) ?? 'Panchang', color: Colors.black));
                                                                          //         },
                                                                          //       ),
                                                                          //     ],
                                                                          //   ),
                                                                          // ),

                                                                          // Pooja list
                                                                          const SizedBox(
                                                                            height:
                                                                                10,
                                                                          ),
                                                                          Container(
                                                                            padding:
                                                                                const EdgeInsets.all(10),
                                                                            margin:
                                                                                const EdgeInsets.all(4),
                                                                            width:
                                                                                double.infinity,
                                                                            decoration:
                                                                                BoxDecoration(
                                                                              boxShadow: [
                                                                                BoxShadow(color: Colors.orange.shade50, blurRadius: 10.0, spreadRadius: 2),
                                                                              ],
                                                                              color: Colors.white,
                                                                              borderRadius: BorderRadius.circular(15),
                                                                            ),
                                                                            child:
                                                                                Column(
                                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                                              children: [
                                                                                const Padding(
                                                                                  padding: EdgeInsets.only(left: 10.0),
                                                                                  child: Text(
                                                                                    'Pooja Booking',
                                                                                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                                                                                  ),
                                                                                ),
// <<<<<<< pravin_mspl
// =======

//                                                                               // Mandir list
// >>>>>>> main
                                                                                const SizedBox(
                                                                                  height: 10,
                                                                                ),
                                                                                ListView.builder(
                                                                                  physics: const NeverScrollableScrollPhysics(),
                                                                                  shrinkWrap: true,
                                                                                  itemCount: categoryPoojaModelList.length,
                                                                                  itemBuilder: (context, index) {
                                                                                    return InkWell(
                                                                                        onTap: () {
                                                                                          Navigator.push(
                                                                                            context,
                                                                                            CupertinoPageRoute(
                                                                                              builder: (context) => PoojaHomeView(
                                                                                                tabIndex: index + 1,
                                                                                                scrollController: widget.scrollController,
                                                                                              ),
                                                                                            ),
                                                                                          );
                                                                                        },
                                                                                        child: allCategoryListWidget(image: poojaCategoryList[index], name: categoryPoojaModelList[index].enName, color: Colors.black));
                                                                                  },
                                                                                ),
                                                                              ],
                                                                            ),
                                                                          ),

                                                                          // Mandir list
                                                                          const SizedBox(
                                                                            height:
                                                                                10,
                                                                          ),
                                                                          Container(
                                                                            padding:
                                                                                const EdgeInsets.all(10),
                                                                            margin:
                                                                                const EdgeInsets.all(4),
                                                                            width:
                                                                                double.infinity,
                                                                            decoration:
                                                                                BoxDecoration(
                                                                              boxShadow: [
                                                                                BoxShadow(color: Colors.orange.shade50, blurRadius: 10.0, spreadRadius: 2),
                                                                              ],
                                                                              color: Colors.white,
                                                                              borderRadius: BorderRadius.circular(15),
                                                                            ),
                                                                            child:
                                                                                Column(
                                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                                              children: [
                                                                                const Padding(
                                                                                  padding: EdgeInsets.only(left: 10.0),
                                                                                  child: Text(
                                                                                    'Mandir Darshan',
                                                                                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                                                                                  ),
                                                                                ),
// <<<<<<< pravin_mspl
// =======

//                                                                               // Astrotalk list
// >>>>>>> main
                                                                                const SizedBox(
                                                                                  height: 10,
                                                                                ),
                                                                                ListView.builder(
                                                                                  physics: const NeverScrollableScrollPhysics(),
                                                                                  shrinkWrap: true,
                                                                                  itemCount: darshanCategoryModelList.length,
                                                                                  itemBuilder: (context, index) {
                                                                                    return InkWell(
                                                                                        onTap: () {
                                                                                          Navigator.push(
                                                                                              context,
                                                                                              PageAnimationTransition(
                                                                                                  page: MandirDarshan(
                                                                                                    tabIndex: index,
                                                                                                  ),
                                                                                                  pageAnimationType: RightToLeftTransition()));
                                                                                        },
                                                                                        child: SizedBox(
                                                                                          height: 50,
                                                                                          child: Row(
                                                                                            children: [
                                                                                              Expanded(
                                                                                                flex: 0,
                                                                                                child: Image.network(
                                                                                                  darshanCategoryModelList[index].image ?? '',
                                                                                                  height: 35,
                                                                                                  width: 35,
                                                                                                ),
                                                                                              ),
                                                                                              const SizedBox(
                                                                                                width: 10,
                                                                                              ),
                                                                                              Expanded(
                                                                                                flex: 1,
                                                                                                child: Text(
                                                                                                  darshanCategoryModelList[index].enName ?? '',
                                                                                                  textAlign: TextAlign.start,
                                                                                                  maxLines: 2,
                                                                                                  overflow: TextOverflow.ellipsis,
                                                                                                  style: titleHeader.copyWith(color: Colors.black, fontSize: 16, letterSpacing: 0.5, fontWeight: FontWeight.w600),
                                                                                                ),
                                                                                              ),
                                                                                            ],
                                                                                          ),
                                                                                        ));
                                                                                  },
                                                                                ),
                                                                              ],
                                                                            ),
                                                                          ),

                                                                          // Astrotalk list
                                                                          const SizedBox(
                                                                            height:
                                                                                10,
                                                                          ),
                                                                          Stack(
                                                                            children: [
                                                                              Container(
                                                                                padding: const EdgeInsets.all(10),
                                                                                margin: const EdgeInsets.all(4),
                                                                                width: double.infinity,
                                                                                decoration: BoxDecoration(
                                                                                  boxShadow: [
                                                                                    BoxShadow(color: Colors.orange.shade50, blurRadius: 10.0, spreadRadius: 2),
                                                                                  ],
                                                                                  color: Colors.white,
                                                                                  borderRadius: BorderRadius.circular(15),
                                                                                ),
                                                                                child: Column(
                                                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                                                  children: [
                                                                                    const Padding(
                                                                                      padding: EdgeInsets.only(left: 10.0),
                                                                                      child: Text(
                                                                                        'Astrologers Talk',
                                                                                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                                                                                      ),
                                                                                    ),
                                                                                    const SizedBox(
                                                                                      height: 10,
                                                                                    ),
                                                                                    ListView.builder(
                                                                                      physics: const NeverScrollableScrollPhysics(),
                                                                                      shrinkWrap: true,
                                                                                      itemCount: astrotalkCategoryList.length,
                                                                                      itemBuilder: (context, index) {
                                                                                        return InkWell(
                                                                                            onTap: () {
                                                                                              Navigator.push(context, PageAnimationTransition(page: const MahaBhandar(tab: 1), pageAnimationType: RightToLeftTransition()));
                                                                                            },
                                                                                            child: allCategoryListWidget(image: astrotalkCategoryList[index].images, name: getTranslated(astrotalkCategoryList[index].name, context) ?? 'Panchang', color: Colors.black));
                                                                                      },
                                                                                    ),
                                                                                  ],
                                                                                ),
                                                                              ),
                                                                              // Sahitya list
                                                                              const SizedBox(
                                                                                height: 10,
                                                                              ),
                                                                              Container(
                                                                                  padding: const EdgeInsets.all(10),
                                                                                  margin: const EdgeInsets.all(4),
                                                                                  width: double.infinity,
                                                                                  decoration: BoxDecoration(
                                                                                    color: Colors.black38,
                                                                                    borderRadius: BorderRadius.circular(15),
                                                                                  ),
                                                                                  child: const Center(
                                                                                      child: Text(
                                                                                    'Coming Soon...',
                                                                                    style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold, color: Colors.white),
                                                                                  ))),
                                                                            ],
                                                                          ),

                                                                          // Sahitya list
                                                                          const SizedBox(
                                                                            height:
                                                                                10,
                                                                          ),
                                                                          Container(
                                                                            padding:
                                                                                const EdgeInsets.all(10),
                                                                            margin:
                                                                                const EdgeInsets.all(4),
                                                                            width:
                                                                                double.infinity,
                                                                            decoration:
                                                                                BoxDecoration(
                                                                              boxShadow: [
                                                                                BoxShadow(color: Colors.orange.shade50, blurRadius: 10.0, spreadRadius: 2),
                                                                              ],
                                                                              color: Colors.white,
                                                                              borderRadius: BorderRadius.circular(15),
                                                                            ),
                                                                            child:
                                                                                Column(
                                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                                              children: [
                                                                                const Padding(
                                                                                  padding: EdgeInsets.only(left: 10.0),
                                                                                  child: Text(
                                                                                    'Sahitya',
                                                                                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                                                                                  ),
                                                                                ),
// <<<<<<< pravin_mspl
// =======
// >>>>>>> main
                                                                                const SizedBox(
                                                                                  height: 10,
                                                                                ),
                                                                                ListView.builder(
                                                                                  physics: const NeverScrollableScrollPhysics(),
                                                                                  shrinkWrap: true,
                                                                                  itemCount: sahityaCategoryList.length,
                                                                                  itemBuilder: (context, index) {
                                                                                    String bookType = bookNameList[index];
                                                                                    return InkWell(
                                                                                        onTap: () {
                                                                                          handleNavActions(bookType, context);
                                                                                          // Navigator.push(
                                                                                          //     context,
                                                                                          //     PageAnimationTransition(
                                                                                          //         page: MahaBhandar(
                                                                                          //           tab: 1,
                                                                                          //           cityName: address2,
                                                                                          //           stateName: address1,
                                                                                          //           default_lat: lat,
                                                                                          //           default_long: long,
                                                                                          //         ),
                                                                                          //         pageAnimationType: RightToLeftTransition()));
                                                                                        },
                                                                                        child: allCategoryListWidget(image: sahityaCategoryList[index].images, name: getTranslated(sahityaCategoryList[index].name, context) ?? 'Panchang', color: Colors.black));
                                                                                  },
                                                                                ),
                                                                              ],
                                                                            ),
                                                                          ),

                                                                          // Video list
                                                                          const SizedBox(
                                                                            height:
                                                                                10,
                                                                          ),
                                                                          Container(
                                                                            padding:
                                                                                const EdgeInsets.all(10),
                                                                            margin:
                                                                                const EdgeInsets.all(4),
                                                                            width:
                                                                                double.infinity,
                                                                            decoration:
                                                                                BoxDecoration(
                                                                              boxShadow: [
                                                                                BoxShadow(color: Colors.orange.shade50, blurRadius: 10.0, spreadRadius: 2),
                                                                              ],
                                                                              color: Colors.white,
                                                                              borderRadius: BorderRadius.circular(15),
                                                                            ),
                                                                            child:
                                                                                Column(
                                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                                              children: [
                                                                                const Padding(
                                                                                  padding: EdgeInsets.only(left: 10.0),
                                                                                  child: Text(
                                                                                    'Video',
                                                                                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                                                                                  ),
                                                                                ),
                                                                                const SizedBox(
                                                                                  height: 10,
                                                                                ),
                                                                                ListView.builder(
                                                                                  physics: const NeverScrollableScrollPhysics(),
                                                                                  shrinkWrap: true,
                                                                                  itemCount: filteredCategories.isNotEmpty ? 5 : 5,
                                                                                  itemBuilder: (context, index) {
                                                                                    return InkWell(
                                                                                        onTap: () {
                                                                                          Navigator.push(
                                                                                              context,
                                                                                              PageAnimationTransition(
                                                                                                  page: YoutubeHomePage(
                                                                                                    tabIndex: index,
                                                                                                  ),
                                                                                                  pageAnimationType: RightToLeftTransition()));
                                                                                        },
                                                                                        child: SizedBox(
                                                                                          height: 50,
                                                                                          child: Row(
                                                                                            children: [
                                                                                              Expanded(
                                                                                                flex: 0,
                                                                                                child: Image.asset(
                                                                                                  vedioCategoryList[index],
                                                                                                  height: 35,
                                                                                                  width: 35,
                                                                                                ),
                                                                                              ),
                                                                                              const SizedBox(
                                                                                                width: 10,
                                                                                              ),
                                                                                              Expanded(
                                                                                                flex: 1,
                                                                                                child: Text(
                                                                                                  filteredCategories[index].name,
                                                                                                  textAlign: TextAlign.start,
                                                                                                  maxLines: 2,
                                                                                                  overflow: TextOverflow.ellipsis,
                                                                                                  style: titleHeader.copyWith(color: Colors.black, fontSize: 16, letterSpacing: 0.5, fontWeight: FontWeight.w600),
                                                                                                ),
                                                                                              ),
                                                                                            ],
                                                                                          ),
                                                                                        ));
                                                                                  },
                                                                                ),
                                                                              ],
                                                                            ),
                                                                          ),

                                                                          // music list
                                                                          const SizedBox(
                                                                            height:
                                                                                10,
                                                                          ),
                                                                          Container(
                                                                            padding:
                                                                                const EdgeInsets.all(10),
                                                                            margin:
                                                                                const EdgeInsets.all(4),
                                                                            width:
                                                                                double.infinity,
                                                                            decoration:
                                                                                BoxDecoration(
                                                                              boxShadow: [
                                                                                BoxShadow(color: Colors.orange.shade50, blurRadius: 10.0, spreadRadius: 2),
                                                                              ],
                                                                              color: Colors.white,
                                                                              borderRadius: BorderRadius.circular(15),
                                                                            ),
                                                                            child:
                                                                                Column(
                                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                                              children: [
                                                                                const Padding(
                                                                                  padding: EdgeInsets.only(left: 10.0),
                                                                                  child: Text(
                                                                                    'Music',
                                                                                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                                                                                  ),
                                                                                ),
                                                                                const SizedBox(
                                                                                  height: 10,
                                                                                ),
                                                                                ListView.builder(
                                                                                  physics: const NeverScrollableScrollPhysics(),
                                                                                  shrinkWrap: true,
                                                                                  itemCount: sangeetModelList.length,
                                                                                  itemBuilder: (context, index) {
                                                                                    return InkWell(
                                                                                        onTap: () {
                                                                                          Navigator.push(
                                                                                              context,
                                                                                              PageAnimationTransition(
                                                                                                  page: SangitHome(
                                                                                                    tabiIndex: index + 1,
                                                                                                  ),
                                                                                                  pageAnimationType: RightToLeftTransition()));
                                                                                        },
                                                                                        child: SizedBox(
                                                                                          height: 50,
                                                                                          child: Row(
                                                                                            children: [
                                                                                              Expanded(
                                                                                                flex: 0,
                                                                                                child: CachedNetworkImage(
                                                                                                  imageUrl: sangeetModelList[index].image,
                                                                                                  height: 35,
                                                                                                  width: 35,
                                                                                                  errorWidget: (context, url, error) => const Icon(
                                                                                                    Icons.broken_image,
                                                                                                    color: Colors.grey,
                                                                                                    size: 24,
                                                                                                  ),
                                                                                                ),
                                                                                              ),
                                                                                              const SizedBox(
                                                                                                width: 10,
                                                                                              ),
                                                                                              Expanded(
                                                                                                flex: 1,
                                                                                                child: Text(
                                                                                                  sangeetModelList[index].enName,
                                                                                                  textAlign: TextAlign.start,
                                                                                                  maxLines: 2,
                                                                                                  overflow: TextOverflow.ellipsis,
                                                                                                  style: titleHeader.copyWith(color: Colors.black, fontSize: 16, letterSpacing: 0.5, fontWeight: FontWeight.w600),
                                                                                                ),
                                                                                              ),
                                                                                            ],
                                                                                          ),
                                                                                        ));
                                                                                  },
                                                                                ),
                                                                              ],
                                                                            ),
                                                                          ),
                                                                        ]),
                                                                  ),
                                                                ),
                                                          Container(
                                                            padding:
                                                                const EdgeInsets
                                                                    .symmetric(
                                                                    horizontal:
                                                                        10,
                                                                    vertical:
                                                                        5),
                                                            height: 50,
                                                            width:
                                                                double.infinity,
                                                            decoration: BoxDecoration(
                                                                color: Colors
                                                                    .white,
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            10.0),
                                                                border: Border.all(
                                                                    color: Colors
                                                                        .orange
                                                                        .shade50)),
                                                            child: Row(
                                                              children: [
                                                                const Text(
                                                                  'All Categories',
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                          22,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold),
                                                                ),
                                                                const Spacer(),
                                                                BouncingWidgetInOut(
                                                                  onPressed:
                                                                      () {
                                                                    modalSetter(
                                                                        () {
                                                                      gridList =
                                                                          !gridList;
                                                                    });
                                                                  },
                                                                  bouncingType:
                                                                      BouncingType
                                                                          .bounceInAndOut,
                                                                  child:
                                                                      Container(
                                                                    height: 30,
                                                                    width: 30,
                                                                    decoration: BoxDecoration(
                                                                        borderRadius:
                                                                            BorderRadius.circular(
                                                                                4.0),
                                                                        color: gridList
                                                                            ? Colors
                                                                                .orange
                                                                            : Colors
                                                                                .white,
                                                                        border: Border.all(
                                                                            color:
                                                                                Colors.orange,
                                                                            width: 2)),
                                                                    child:
                                                                        Center(
                                                                      child:
                                                                          Icon(
                                                                        gridList
                                                                            ? Icons.list
                                                                            : Icons.grid_view,
                                                                        color: gridList
                                                                            ? Colors.white
                                                                            : Colors.orange,
                                                                        size:
                                                                            20,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          )
                                                        ],
                                                      )),
                                                ),
                                              );
                                            });
                                          });
                                    },
                                    splashColor: Colors.amber.withOpacity(0.3),
                                    highlightColor:
                                        Colors.deepOrange.withOpacity(0.1),
                                    child: Container(
                                      padding: const EdgeInsets.all(5),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(5),
                                      ),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Container(
                                            height: 40,
                                            width: 40,
                                            padding: const EdgeInsets.all(3),
                                            child: const Icon(
                                              Icons.grid_view_rounded,
                                              color: Colors.orange,
                                              size: 30,
                                            ),
                                          ),
                                          const SizedBox(height: 3),
                                          Center(
                                            child: Text(
                                              getTranslated('all_category',
                                                      context) ??
                                                  'All Category',
                                              textAlign: TextAlign.center,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                color: Colors.black,
                                                fontSize:
                                                    Dimensions.fontSizeSmall,
                                                fontWeight: FontWeight.w600,
                                                letterSpacing: 0.5,
                                                shadows: const [
                                                  Shadow(
                                                    color: Colors.black12,
                                                    blurRadius: 2,
                                                    offset: Offset(1, 1),
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
                              ),
                            ],
                          ),
                          Divider(color: Colors.grey.shade100),
                          // Mahakal Banners
                          ExploreMahakalBanners(
                            sectionModelList: sectionModelList,
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 15,
                      ),

                      //Sections
                      sectionModelList.isEmpty
                          ? Shimmer.fromColors(
                              baseColor: Colors.grey.shade200,
                              highlightColor: Colors.grey.shade400,
                              child: Column(
                                children: [
                                  Container(
                                    height: size.width * 0.07,
                                    width: double.infinity,
                                    padding: const EdgeInsets.all(7),
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: 10),
                                    decoration: BoxDecoration(
                                        color: Colors.grey,
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                  ),
                                  Container(
                                    margin: const EdgeInsets.all(7),
                                    padding: const EdgeInsets.all(7),
                                    height: size.width * 0.5,
                                    width: double.infinity,
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Container(
                                              decoration: BoxDecoration(
                                                  color: Colors.grey,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10))),
                                        ),
                                        const SizedBox(
                                          width: 5,
                                        ),
                                        Expanded(
                                          child: Container(
                                              decoration: BoxDecoration(
                                                  color: Colors.grey,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10))),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 5,
                                  ),
                                  Container(
                                    height: size.width * 0.07,
                                    width: double.infinity,
                                    padding: const EdgeInsets.all(7),
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: 10),
                                    decoration: BoxDecoration(
                                        color: Colors.grey,
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                  ),
                                  Container(
                                    margin: const EdgeInsets.all(7),
                                    padding: const EdgeInsets.all(7),
                                    height: size.width * 0.5,
                                    width: double.infinity,
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Container(
                                              decoration: BoxDecoration(
                                                  color: Colors.grey,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10))),
                                        ),
                                        const SizedBox(
                                          width: 5,
                                        ),
                                        Expanded(
                                          child: Container(
                                              decoration: BoxDecoration(
                                                  color: Colors.grey,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10))),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 5,
                                  ),
                                ],
                              ))
                          : Column(
                              children: [
                                // Panchang
                                SectionPanchang(
                                    sectionModelList: sectionModelList,
                                    tithiName: tithiName,
                                    size: size,
                                    address2: address2,
                                    address1: address1,
                                    lat: lat,
                                    long: long),

                                // Free Service
                                Column(
                                  children: [
                                    Container(
                                        width: double.infinity,
                                        padding: const EdgeInsets.all(7),
                                        margin: const EdgeInsets.symmetric(
                                            horizontal: 10),
                                        decoration: BoxDecoration(
                                          color: Theme.of(context)
                                              .primaryColor
                                              .withOpacity(0.15),
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        child: Row(
                                          children: [
                                            Container(
                                              height: 15,
                                              width: 4,
                                              decoration: BoxDecoration(
                                                  color: Colors.orange,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          20)),
                                            ),
                                            const SizedBox(
                                              width: 5,
                                            ),
                                            Text(
                                              getTranslated('free_service',
                                                      context) ??
                                                  'Free Service',
                                              style: TextStyle(
                                                  fontSize:
                                                      Dimensions.fontSizeLarge,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ],
                                        )),
                                    Container(
                                      height: 180,
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 10,horizontal: 6),
                                      child: ListView.builder(
                                        scrollDirection: Axis.horizontal,
                                        itemCount: items.length,
                                        itemBuilder: (context, index) {
                                          return GestureDetector(
                                            onTap: () => onItemTap(context,items[index]['title']!),
                                            child: Container(
                                              width: 110, // Slightly wider for better text display
                                              margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 3),
                                              decoration: BoxDecoration(
                                                gradient: items[index]['color'] != null
                                                    ? LinearGradient(
                                                  begin: Alignment.topLeft,
                                                  end: Alignment.bottomRight,
                                                  colors: [
                                                    Color(int.parse(items[index]['color']!))
                                                        .withOpacity(0.25), // Increased opacity
                                                    Color(int.parse(items[index]['color']!))
                                                        .withOpacity(0.05), // Subtle fade
                                                    Colors.white.withOpacity(0.8),
                                                  ],
                                                  stops: const [0.0, 0.4, 1.0], // Smooth gradient control
                                                )
                                                    : LinearGradient(
                                                  begin: Alignment.topCenter,
                                                  end: Alignment.bottomCenter,
                                                  colors: [
                                                    Colors.white,
                                                    Colors.grey.shade50,
                                                  ],
                                                ),
                                                borderRadius: BorderRadius.circular(12), // More rounded corners
                                                border: Border.all(
                                                  color: Colors.grey.withOpacity(0.15),
                                                  width: 0.8,
                                                ),
                                              ),
                                              child: Stack(
                                                children: [
                                                  /// Content
                                                  Padding(
                                                    padding: const EdgeInsets.fromLTRB(14, 16, 14, 65),
                                                    child: Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [

                                                        /// Title
                                                        Text(
                                                          getTranslated(items[index]['title']!, context) ??
                                                              'Free Service',
                                                          style: const TextStyle(
                                                            fontSize: 14,
                                                            fontWeight: FontWeight.w700, // Bolder weight
                                                            color: Colors.black87,
                                                            height: 1.25,
                                                            letterSpacing: -0.2,
                                                          ),
                                                          maxLines: 2,
                                                          overflow: TextOverflow.ellipsis,
                                                        ),

                                                        /// Optional Subtitle/Description
                                                        if (items[index]['subtitle'] != null) ...[
                                                          const SizedBox(height: 4),
                                                          Text(
                                                            items[index]['subtitle']!,
                                                            style: TextStyle(
                                                              fontSize: 11,
                                                              fontWeight: FontWeight.w400,
                                                              color: Colors.grey.shade600,
                                                              height: 1.2,
                                                            ),
                                                            maxLines: 1,
                                                            overflow: TextOverflow.ellipsis,
                                                          ),
                                                        ],
                                                      ],
                                                    ),
                                                  ),

                                                  /// Image with enhanced styling
                                                  Positioned(
                                                    bottom: 8,
                                                    right: 8,
                                                    child: Container(
                                                      padding: const EdgeInsets.all(4),
                                                      decoration: BoxDecoration(
                                                        shape: BoxShape.circle,
                                                        color: Colors.white.withOpacity(0.9),
                                                        boxShadow: [
                                                          BoxShadow(
                                                            color: Colors.black.withOpacity(0.1),
                                                            blurRadius: 8,
                                                            offset: const Offset(0, 3),
                                                          ),
                                                        ],
                                                      ),
                                                      child: Container(
                                                        decoration: BoxDecoration(
                                                          shape: BoxShape.circle,
                                                          color: items[index]['color'] != null
                                                              ? Color(int.parse(items[index]['color']!))
                                                              .withOpacity(0.1)
                                                              : Colors.grey.shade100,
                                                        ),
                                                        child: Padding(
                                                          padding: const EdgeInsets.all(6),
                                                          child: Image.asset(
                                                            items[index]['image']!,
                                                            height: 50, // Slightly smaller but with padding
                                                            width: 50,
                                                            fit: BoxFit.contain,
                                                            errorBuilder: (_, __, ___) {
                                                              return const Icon(
                                                                Icons.error_outline,
                                                                size: 45,
                                                                color: Colors.grey,
                                                              );
                                                            },
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),

                                                  /// Optional Badge/Corner Tag
                                                  if (items[index]['tag'] != null)
                                                    Positioned(
                                                      top: 10,
                                                      right: 10,
                                                      child: Container(
                                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                        decoration: BoxDecoration(
                                                          borderRadius: BorderRadius.circular(10),
                                                          color: Colors.white.withOpacity(0.95),
                                                          boxShadow: [
                                                            BoxShadow(
                                                              color: Colors.black.withOpacity(0.05),
                                                              blurRadius: 4,
                                                            ),
                                                          ],
                                                        ),
                                                        child: Text(
                                                          items[index]['tag']!,
                                                          style: const TextStyle(
                                                            fontSize: 9,
                                                            fontWeight: FontWeight.w600,
                                                            color: Colors.black54,
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
                                    ),
                                  ],
                                ),

                                // hotel & travels
                                Container(
                                    margin: const EdgeInsets.symmetric(vertical: 12),
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(0),
                                      topRight: Radius.circular(0),
                                    ),
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        Colors.deepOrange.shade100, // soft deep purple
                                        Colors.deepOrange.shade50, // medium lavender
                                        const Color(0xFFD1C4E9), // light lavender
                                        const Color(0xFFFFFFFF), // white fade
                                      ],

                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [

                                      /// 🔥 HEADER
                                      Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [

                                                /// Title Row
                                                Row(
                                                  children: [
                                                    Container(
                                                      padding: const EdgeInsets.all(6),
                                                      decoration: BoxDecoration(
                                                        gradient: LinearGradient(
                                                          colors: [
                                                            Colors.white.withOpacity(0.28),
                                                            Colors.white.withOpacity(0.12),
                                                          ],
                                                        ),
                                                        borderRadius: BorderRadius.circular(14),
                                                      ),
                                                      child: const Icon(
                                                        Icons.local_fire_department_rounded,
                                                        color: Colors.black,
                                                        size: 22,
                                                      ),
                                                    ),
                                                    const SizedBox(width: 12),
                                                    const Text(
                                                      'Hotel & Travels',
                                                      style: TextStyle(
                                                        color: Colors.black,
                                                        fontSize: 22,
                                                        fontWeight: FontWeight.w800,
                                                        letterSpacing: -0.3,
                                                      ),
                                                    ),
                                                  ],
                                                ),

                                                const SizedBox(height: 5),

                                                const Text(
                                                  'Limited time travel deals just for you',
                                                  style: TextStyle(
                                                    color: Colors.black,
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.w500,
                                                    height: 1.4,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),

                                      const SizedBox(height: 20),

                                      /// 🛍 GRID SECTION
                                      SizedBox(
                                        height: 140,
                                        child: ListView.separated(
                                          scrollDirection: Axis.horizontal,
                                          itemCount: 4,
                                          separatorBuilder: (_, __) => const SizedBox(width: 8),
                                          itemBuilder: (context, index) {
                                          void navigateByType(int type) {
                                              switch (type) {
                                                case 0:
                                                  Navigator.push(context,
                                                    CupertinoPageRoute(
                                                      builder: (context) => HotelBottomBar(pageIndex: 0,),
                                                    ),
                                                  );
                                                  break;

                                                case 1:
                                                Navigator.push(
                                                  context,
                                                  CupertinoPageRoute(
                                                    builder: (context) => const TickitBookingHome()
                                                  ),
                                                );
                                                  break;

                                                  case 2:
                                                    Navigator.push(
                                                      context,
                                                      CupertinoPageRoute(
                                                        builder: (context) => const TripBookingPage(type: 'one-way',),
                                                      ),
                                                    );
                                                  break;

                                                case 3:
                                                  Navigator.push(
                                                    context,
                                                    CupertinoPageRoute(
                                                      builder: (context) => const TripBookingPage(type: 'self',),
                                                    ),
                                                  );
                                                  break;

                                                default:
                                                  print("No route found");
                                              }
                                            }

                                            final items = [
                                              {
                                                'name': 'Hotels',
                                                'desc': 'Comfort Within Budget',
                                                'discount': 'UPTO 55% OFF',
                                                'image': 'assets/image/Hotels.png',
                                                'color': Colors.purple,
                                              },
                                              {
                                                'name': 'Activities',
                                                'desc': 'Thrilling Experiences',
                                                'discount': '₹4000 OFF',
                                                'image': 'assets/image/Activities.png',
                                                'color': Colors.blue,
                                              },
                                              {
                                                'name': 'Cabs',
                                                'desc': 'Ride Anytime, Anywhere',
                                                'discount': 'UPTO 30% OFF',
                                                'image': 'assets/image/Cabs.png',
                                                'color': Colors.deepOrange,
                                              },
                                              {
                                                'name': 'Rentals',
                                                'desc': 'Drive Without Limits',
                                                'discount': 'No Extra Charge',
                                                'image': 'assets/image/Vehicle Rental.png',
                                                'color': Colors.green,
                                              },
                                            ];

                                            final item = items[index];

                                            return lowestWidget(
                                              name: item['name'] as String,
                                              description: item['desc'] as String,
                                              discount: item['discount'] as String,
                                              ht: 140,
                                              image: item['image'] as String,
                                              color: item['color'] as Color,
                                              imageHt: 60,
                                              onTap: () {
                                                navigateByType(index);
                                              },
                                            );
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                // Pooja Booking
                                SectionPoojaBooking(
                                    sectionModelList: sectionModelList,
                                    widget: widget,
                                    size: size,
                                    categoryPoojaModelList: categoryPoojaModelList,
                                    poojaBookingImages: poojaBookingImages,
                                    shimmer: shimmerScreenChadhava(),
                                ),

                                // Container(
                                //   decoration: const BoxDecoration(
                                //     borderRadius: BorderRadius.only(
                                //       topLeft: Radius.circular(22),
                                //       topRight: Radius.circular(22),
                                //     ),
                                //     gradient: LinearGradient(
                                //       begin: Alignment.topCenter,
                                //       end: Alignment.bottomCenter,
                                //       colors: [
                                //         Color(0xFFF57C00), // softer deep orange
                                //         Color(0xFFFFA726), // warm soft orange
                                //         Color(0xFFFFF3E0), // light peach fade
                                //         Color(0xFFFFFFFF), // light peach fade
                                //       ],
                                //
                                //     ),
                                //   ),
                                //   child: Padding(
                                //     padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
                                //     child: Column(
                                //       crossAxisAlignment: CrossAxisAlignment.start,
                                //       children: [
                                //
                                //         /// 🔥 HEADER
                                //         Row(
                                //           crossAxisAlignment: CrossAxisAlignment.start,
                                //           children: [
                                //             Expanded(
                                //               child: Column(
                                //                 crossAxisAlignment: CrossAxisAlignment.start,
                                //                 children: [
                                //
                                //                   /// Title Row
                                //                   Row(
                                //                     children: [
                                //                       Container(
                                //                         padding: const EdgeInsets.all(10),
                                //                         decoration: BoxDecoration(
                                //                           gradient: LinearGradient(
                                //                             colors: [
                                //                               Colors.white.withOpacity(0.28),
                                //                               Colors.white.withOpacity(0.12),
                                //                             ],
                                //                           ),
                                //                           borderRadius: BorderRadius.circular(14),
                                //                         ),
                                //                         child: const Icon(
                                //                           Icons.local_fire_department_rounded,
                                //                           color: Colors.white,
                                //                           size: 22,
                                //                         ),
                                //                       ),
                                //                       const SizedBox(width: 12),
                                //                       const Text(
                                //                         'LOWEST FARES',
                                //                         style: TextStyle(
                                //                           color: Colors.white,
                                //                           fontSize: 22,
                                //                           fontWeight: FontWeight.w800,
                                //                           letterSpacing: -0.3,
                                //                         ),
                                //                       ),
                                //                     ],
                                //                   ),
                                //
                                //                   const SizedBox(height: 8),
                                //
                                //                   Text(
                                //                     'Limited time travel deals just for you',
                                //                     style: TextStyle(
                                //                       color: Colors.white.withOpacity(0.95),
                                //                       fontSize: 13,
                                //                       fontWeight: FontWeight.w500,
                                //                       height: 1.4,
                                //                     ),
                                //                   ),
                                //                 ],
                                //               ),
                                //             ),
                                //           ],
                                //         ),
                                //
                                //         const SizedBox(height: 20),
                                //
                                //         /// 🛍 GRID SECTION
                                //         Row(
                                //           crossAxisAlignment: CrossAxisAlignment.start,
                                //           children: [
                                //
                                //             /// LEFT COLUMN
                                //             Expanded(
                                //               child: Column(
                                //                 children: [
                                //                   lowestWidget(
                                //                     name: 'Hotels',
                                //                     description: 'Comfort Within Budget',
                                //                     discount: 'UPTO 55% OFF',
                                //                     ht: 170,
                                //                     image: 'assets/image/Hotels.png',
                                //                     color: const Color(0xFF00695C), // Deep Teal
                                //                     imageHt: 100,
                                //                   ),
                                //                   const SizedBox(height: 10),
                                //                   lowestWidget(
                                //                     name: 'Activities',
                                //                     description: 'Thrilling Experiences',
                                //                     discount: '₹4000 OFF',
                                //                     ht: 130,
                                //                     image: 'assets/image/Activities.png',
                                //                     color: const Color(0xFF283593), // Royal Blue
                                //                     imageHt: 60,
                                //                   ),
                                //                 ],
                                //               ),
                                //             ),
                                //
                                //             const SizedBox(width: 10),
                                //
                                //             /// RIGHT COLUMN
                                //             Expanded(
                                //               child: Column(
                                //                 children: [
                                //                   lowestWidget(
                                //                     name: 'Cabs',
                                //                     description: 'Ride Anytime, Anywhere',
                                //                     discount: 'UPTO 30% OFF',
                                //                     ht: 130,
                                //                     image: 'assets/image/Cabs.png',
                                //                     color: const Color(0xFF1B5E20), // Forest Green
                                //                     imageHt: 70,
                                //                   ),
                                //                   const SizedBox(height: 10),
                                //                   lowestWidget(
                                //                     name: 'Vehicle Rentals',
                                //                     description: 'Drive Without Limits',
                                //                     discount: 'No Extra Charge',
                                //                     ht: 170,
                                //                     image: 'assets/image/Vehicle Rental.png',
                                //                     color: const Color(0xFF8E2430), // Burgundy
                                //                     imageHt: 80,
                                //                   ),
                                //                 ],
                                //               ),
                                //             ),
                                //
                                //           ],
                                //         ),
                                //       ],
                                //     ),
                                //   ),
                                // ),

                                // Chadhava pooja
                                Column(
                                  children: [
                                    sectionModelList[8].section.status == 'true'
                                        ? Column(children: [
                                            Container(
                                              color: Colors.purple.shade50,
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Padding(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 10.0,
                                                        vertical: 6.0),
                                                    child: Row(
                                                      children: [
                                                        Container(
                                                          height: 15,
                                                          width: 4,
                                                          decoration: BoxDecoration(
                                                              color:
                                                                  Colors.purple,
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          20)),
                                                        ),
                                                        const SizedBox(
                                                            width: 10),
                                                        InkWell(
                                                          onTap: () {
                                                            // Navigator.push(
                                                            //   context,
                                                            //   MaterialPageRoute(
                                                            //     builder: (_) =>
                                                            //         const TempleBookingScreen(
                                                            //       id: '19',
                                                            //     ),
                                                            //   ),
                                                            // );
                                                          },
                                                          child: Text(
                                                            getTranslated(
                                                                    'offer_chadhava',
                                                                    context) ??
                                                                'Chadhava',
                                                            style: TextStyle(
                                                                fontSize: Dimensions
                                                                    .fontSizeLarge,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold),
                                                          ),
                                                        ),
                                                        const Spacer(),
                                                        InkWell(
                                                          onTap: () {
                                                            Navigator.push(
                                                              context,
                                                              CupertinoPageRoute(
                                                                builder:
                                                                    (context) =>
                                                                        PoojaHomeView(
                                                                  tabIndex: 7,
                                                                  scrollController:
                                                                      widget
                                                                          .scrollController,
                                                                ),
                                                              ),
                                                            );
                                                          },
                                                          child: Text(
                                                            getTranslated(
                                                                    'VIEW_ALL',
                                                                    context) ??
                                                                'View All',
                                                            style: TextStyle(
                                                                fontSize: Dimensions
                                                                    .fontSizeLarge,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                color: Colors
                                                                    .purple),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  SingleChildScrollView(
                                                    scrollDirection:
                                                        Axis.horizontal,
                                                    child: Row(
                                                      children: [
                                                        const SizedBox(
                                                          width: 10,
                                                        ),
                                                        Container(
                                                          height: 190,
                                                          width: 140,
                                                          decoration: const BoxDecoration(
                                                              image: DecorationImage(
                                                                  image: AssetImage(
                                                                      'assets/images/allcategories/animate/chadhava_animation.gif'),
                                                                  fit: BoxFit
                                                                      .fill)),
                                                        ),
                                                        const SizedBox(
                                                          width: 6,
                                                        ),
                                                        chadhavaModelList
                                                                .isEmpty
                                                            ? shimmerScreenChadhava()
                                                            : SizedBox(
                                                                height: 210,
                                                                child: ListView
                                                                    .builder(
                                                                  physics:
                                                                      const BouncingScrollPhysics(),
                                                                  itemCount:
                                                                      chadhavaModelList
                                                                          .length,
                                                                  shrinkWrap:
                                                                      true,
                                                                  scrollDirection:
                                                                      Axis.horizontal,
                                                                  itemBuilder:
                                                                      (context,
                                                                          index) {
                                                                    return InkWell(
                                                                      onTap:
                                                                          () {
                                                                        Navigator.push(
                                                                            context,
                                                                            CupertinoPageRoute(
                                                                              builder: (context) => ChadhavaDetailView(
                                                                                idNumber: '${chadhavaModelList[index].id}',
                                                                                // nextDatePooja: '${chadhavaModelList[index].nextChadhavaDate}',
                                                                              ),
                                                                            ));
                                                                      },
                                                                      child:
                                                                          Container(
                                                                        margin: const EdgeInsets
                                                                            .only(
                                                                            right:
                                                                                5,
                                                                            bottom:
                                                                                10),
                                                                        width:
                                                                            150,
                                                                        decoration: BoxDecoration(
                                                                            color:
                                                                                Colors.white,
                                                                            border: Border.all(color: Colors.grey.shade300, width: 1.5),
                                                                            borderRadius: BorderRadius.circular(8.0)),
                                                                        child:
                                                                            Padding(
                                                                          padding: const EdgeInsets
                                                                              .all(
                                                                              4.0),
                                                                          child:
                                                                              Column(
                                                                            crossAxisAlignment:
                                                                                CrossAxisAlignment.start,
                                                                            children: [
                                                                              Expanded(
                                                                                flex: 0,
                                                                                child: Container(
                                                                                  height: 100,
                                                                                  width: double.infinity,
                                                                                  decoration: BoxDecoration(
                                                                                    borderRadius: BorderRadius.circular(8),
                                                                                    color: Colors.grey.shade300,
                                                                                  ),
                                                                                  child: ClipRRect(
                                                                                    borderRadius: BorderRadius.circular(6),
                                                                                    child: CachedNetworkImage(
                                                                                      imageUrl: '${chadhavaModelList[index].thumbnail}',
                                                                                      fit: BoxFit.fill,
                                                                                      errorWidget: (context, url, error) => const Icon(Icons.error),
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                              const SizedBox(
                                                                                height: 5,
                                                                              ),
                                                                              Expanded(
                                                                                  flex: 1,
                                                                                  child: Text(
                                                                                    '${chadhavaModelList[index].hiName}',
                                                                                    style: const TextStyle(fontSize: 13, color: Colors.black),
                                                                                    maxLines: 2,
                                                                                  )),
                                                                              Container(
                                                                                margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 4),
                                                                                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 4),
                                                                                decoration: BoxDecoration(borderRadius: BorderRadius.circular(5), color: CustomColors.clrorange),
                                                                                child: const Row(
                                                                                  children: [
                                                                                    Text(
                                                                                      'चढावा',
                                                                                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                                                                                    ),
                                                                                    Spacer(),
                                                                                    Icon(
                                                                                      CupertinoIcons.arrow_right_circle,
                                                                                      color: Colors.white,
                                                                                    )
                                                                                  ],
                                                                                ),
                                                                              ),
                                                                              // Text.rich(
                                                                              //     TextSpan(
                                                                              //         children: [
                                                                              //           TextSpan(
                                                                              //               text:'₹${muhuratModelList[index].counsellingSellingPrice} ',style: const TextStyle(fontSize: 14,fontWeight: FontWeight.bold,color:Colors.blue)
                                                                              //           ),
                                                                              //           TextSpan(
                                                                              //               text:'₹${muhuratModelList[index].counsellingMainPrice}',style: const TextStyle(fontSize: 14,fontWeight: FontWeight.bold,color: Colors.black,decoration: TextDecoration.lineThrough)
                                                                              //           ),
                                                                              //         ]
                                                                              //     )
                                                                              // )
                                                                            ],
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    );
                                                                  },
                                                                ),
                                                              ),
                                                        const SizedBox(
                                                          width: 10,
                                                        )
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            const SizedBox(height: 15),
                                          ])
                                        : const SizedBox.shrink(),
                                  ],
                                ),

                                // Prasadam section
                                Column(
                                  children: [
                                    // Header
                                    Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.all(7),
                                      margin: const EdgeInsets.symmetric(
                                          horizontal: 10),
                                      decoration: BoxDecoration(
                                        color: Colors.orange.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Row(
                                        children: [
                                          Container(
                                            height: 15,
                                            width: 4,
                                            decoration: BoxDecoration(
                                              color: Colors.deepOrange,
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                            ),
                                          ),
                                          const SizedBox(width: 5),
                                          Text(
                                            getTranslated(
                                                    'paid_prasad', context) ??
                                                'Prasaadam',
                                            style: TextStyle(
                                              fontSize:
                                                  Dimensions.fontSizeLarge,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 12),

                                    // Prasaadam Card
                                    InkWell(
                                      onTap: () {
                                        // Navigation to TopSellerProductScreen
                                        Navigator.push(
                                          context,
                                          CupertinoPageRoute(
                                            builder: (context) =>
                                                TopSellerProductScreen(
                                                  scrollController : _scrollController,
                                              sellerId: 14,
                                              temporaryClose:
                                                  Provider.of<ShopController>(
                                                          context,
                                                          listen: false)
                                                      .sellerModel
                                                      ?.sellers?[1]
                                                      .shop
                                                      ?.temporaryClose,
                                              vacationStatus:
                                                  Provider.of<ShopController>(
                                                          context,
                                                          listen: false)
                                                      .sellerModel
                                                      ?.sellers?[1]
                                                      .shop
                                                      ?.vacationStatus,
                                              vacationEndDate:
                                                  Provider.of<ShopController>(
                                                          context,
                                                          listen: false)
                                                      .sellerModel
                                                      ?.sellers?[1]
                                                      .shop
                                                      ?.vacationEndDate,
                                              vacationStartDate:
                                                  Provider.of<ShopController>(
                                                          context,
                                                          listen: false)
                                                      .sellerModel
                                                      ?.sellers?[1]
                                                      .shop
                                                      ?.vacationStartDate,
                                              name: Provider.of<ShopController>(
                                                      context,
                                                      listen: false)
                                                  .sellerModel
                                                  ?.sellers?[1]
                                                  .shop
                                                  ?.name,
                                              banner:
                                                  Provider.of<ShopController>(
                                                          context,
                                                          listen: false)
                                                      .sellerModel
                                                      ?.sellers?[1]
                                                      .shop
                                                      ?.banner,
                                              image:
                                                  Provider.of<ShopController>(
                                                          context,
                                                          listen: false)
                                                      .sellerModel
                                                      ?.sellers?[1]
                                                      .shop
                                                      ?.image,
                                            ),
                                          ),
                                        );
                                      },
                                      borderRadius: BorderRadius.circular(16),
                                      child: Container(
                                        width: double.infinity,
                                        margin: const EdgeInsets.symmetric(
                                            horizontal: 10),
                                        padding: const EdgeInsets.all(16),
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [
                                              Colors.white,
                                              Colors.orange.shade50,
                                              Colors.orange.shade100,
                                            ],
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(15),
                                          boxShadow: [
                                            BoxShadow(
                                              color:
                                                  Colors.grey.withOpacity(0.2),
                                              blurRadius: 8,
                                              offset: const Offset(0, 4),
                                            ),
                                          ],
                                          border: Border.all(
                                            color: Colors.orange.shade200,
                                            width: 1,
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            // Animated Prasaadam icon
                                            Container(
                                              height: 60,
                                              width: 60,
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.orange
                                                        .withOpacity(0.2),
                                                    blurRadius: 4,
                                                    offset: const Offset(0, 2),
                                                  ),
                                                ],
                                              ),
                                              child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                                child: Image.asset(
                                                  'assets/animated/prasad_icon_animation.gif',
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                            ),

                                            const SizedBox(width: 16),

                                            // Text content
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    'मंदिर प्रसाद बुक करें',
                                                    style: TextStyle(
                                                      fontSize: Dimensions
                                                              .fontSizeLarge +
                                                          4,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors
                                                          .deepOrange.shade800,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Text(
                                                    'भक्ति का सुख पाएँ, अभी प्रसाद बुक करें!',
                                                    style: TextStyle(
                                                      fontSize: Dimensions
                                                          .fontSizeSmall,
                                                      color:
                                                          Colors.brown.shade600,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),

                                            // Arrow icon with decorative circle
                                            Container(
                                              padding: const EdgeInsets.all(6),
                                              decoration: BoxDecoration(
                                                color: Colors.orange.shade200,
                                                shape: BoxShape.circle,
                                              ),
                                              child: Icon(
                                                Icons.arrow_forward_ios_rounded,
                                                color:
                                                    Colors.deepOrange.shade700,
                                                size: 16,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                  ],
                                ),

                                // Tour
                                Column(
                                  children: [
                                    sectionModelList[8].section.status == 'true'
                                        ? Container(
                                            color: Colors.purple.shade50,
                                            child: Column(
                                              children: [
                                                Padding(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 10.0,
                                                      vertical: 6.0),
                                                  child: Row(
                                                    children: [
                                                      Container(
                                                        height: 15,
                                                        width: 4,
                                                        decoration: BoxDecoration(
                                                            color:
                                                                Colors.purple,
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        20)),
                                                      ),
                                                      const SizedBox(width: 10),
                                                      Text(
                                                        getTranslated(
                                                                'tour_book',
                                                                context) ??
                                                            'Tour',
                                                        style: TextStyle(
                                                            fontSize: Dimensions
                                                                .fontSizeLarge,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                      ),
                                                      const Spacer(),
                                                      InkWell(
                                                        onTap: () {
                                                          Navigator.push(
                                                            context,
                                                            CupertinoPageRoute(
                                                              builder: (context) =>
                                                                  const TourHomePage(),
                                                            ),
                                                          );
                                                        },
                                                        child: Text(
                                                          getTranslated(
                                                                  'VIEW_ALL',
                                                                  context) ??
                                                              'View All',
                                                          style: TextStyle(
                                                              fontSize: Dimensions
                                                                  .fontSizeLarge,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              color: Colors
                                                                  .purple),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          left: 10, top: 10),
                                                  child: SizedBox(
                                                    height: screenWidth * 0.90,
                                                    child: _newToursList.isEmpty
                                                        ? shimmerScreenChadhava()
                                                        : ListView.builder(
                                                            scrollDirection:
                                                                Axis.horizontal,
                                                            itemCount:
                                                                _newToursList
                                                                    .length,
                                                            itemBuilder:
                                                                (context,
                                                                    index) {
                                                              final tour =
                                                                  _newToursList[
                                                                      index];

                                                              return InkWell(
                                                                onTap: () {
                                                                  Navigator
                                                                      .push(
                                                                    context,
                                                                    CupertinoPageRoute(
                                                                      builder:
                                                                          (context) =>
                                                                              TourDetails(
                                                                        productId: tour
                                                                            .id
                                                                            .toString(),
                                                                      ),
                                                                    ),
                                                                  );
                                                                },
                                                                child:
                                                                    Container(
                                                                  width: 280,
                                                                  margin:
                                                                      const EdgeInsets
                                                                          .only(
                                                                          right:
                                                                              16,
                                                                          top:
                                                                              8,
                                                                          bottom:
                                                                              8),
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    color: Colors
                                                                        .white,
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            20),
                                                                    boxShadow: [
                                                                      BoxShadow(
                                                                        color: Colors
                                                                            .grey
                                                                            .withOpacity(0.15),
                                                                        blurRadius:
                                                                            12,
                                                                        offset: const Offset(
                                                                            0,
                                                                            6),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                  child: Column(
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .start,
                                                                    children: [
                                                                      /// IMAGE
                                                                      ClipRRect(
                                                                        borderRadius:
                                                                            const BorderRadius.only(
                                                                          topLeft:
                                                                              Radius.circular(20),
                                                                          topRight:
                                                                              Radius.circular(20),
                                                                        ),
                                                                        child:
                                                                            CachedNetworkImage(
                                                                          imageUrl:
                                                                              tour.image ?? '',
                                                                          height:
                                                                              150,
                                                                          width:
                                                                              double.infinity,
                                                                          fit: BoxFit
                                                                              .cover,
                                                                        ),
                                                                      ),

                                                                      Expanded(
                                                                        child:
                                                                            Padding(
                                                                          padding: const EdgeInsets
                                                                              .all(
                                                                              12.0),
                                                                          child:
                                                                              Column(
                                                                            crossAxisAlignment:
                                                                                CrossAxisAlignment.start,
                                                                            children: [
                                                                              /// TITLE
                                                                              Text(
                                                                                tour.enTourName ?? '',
                                                                                style: TextStyle(
                                                                                  fontSize: screenWidth * 0.037,
                                                                                  fontWeight: FontWeight.bold,
                                                                                  color: Colors.black87,
                                                                                ),
                                                                                maxLines: 2,
                                                                                overflow: TextOverflow.ellipsis,
                                                                              ),

                                                                              const SizedBox(height: 6),

                                                                              /// PLAN TYPE + OFFER
                                                                              Row(
                                                                                children: [
                                                                                  Expanded(
                                                                                    child: Text(
                                                                                      '${tour.planTypeName} • ${tour.enNumberOfDay}',
                                                                                      style: TextStyle(
                                                                                        fontSize: screenWidth * 0.035,
                                                                                        fontWeight: FontWeight.w500,
                                                                                        color: Colors.grey[700],
                                                                                      ),
                                                                                      maxLines: 1,
                                                                                      overflow: TextOverflow.ellipsis,
                                                                                    ),
                                                                                  ),
                                                                                  if (tour.percentageOff != null && tour.percentageOff != '0')
                                                                                    Container(
                                                                                      padding: const EdgeInsets.symmetric(
                                                                                        horizontal: 8,
                                                                                        vertical: 4,
                                                                                      ),
                                                                                      decoration: BoxDecoration(
                                                                                        color: Colors.orange.shade100,
                                                                                        borderRadius: BorderRadius.circular(6),
                                                                                      ),
                                                                                      child: Text(
                                                                                        '${tour.percentageOff}% OFF',
                                                                                        style: TextStyle(
                                                                                          fontSize: screenWidth * 0.033,
                                                                                          fontWeight: FontWeight.bold,
                                                                                          color: Colors.orange.shade800,
                                                                                        ),
                                                                                      ),
                                                                                    ),
                                                                                ],
                                                                              ),

                                                                              const SizedBox(height: 6),

                                                                              /// PRICE
                                                                              Row(
                                                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                                children: [
                                                                                  Text(
                                                                                    tour.isPersonUse == 1 ? 'PER PERSON' : 'CAB',
                                                                                    style: TextStyle(
                                                                                      fontSize: screenWidth * 0.035,
                                                                                      fontWeight: FontWeight.w500,
                                                                                      color: Colors.grey[700],
                                                                                    ),
                                                                                  ),
                                                                                  Text(
                                                                                    NumberFormat.currency(
                                                                                      locale: 'en_IN',
                                                                                      symbol: '₹',
                                                                                      decimalDigits: 0,
                                                                                    ).format(double.tryParse(tour.minAmount ?? '0') ?? 0),
                                                                                    style: TextStyle(
                                                                                      fontSize: screenWidth * 0.052,
                                                                                      fontWeight: FontWeight.w700,
                                                                                      color: Colors.green[700],
                                                                                    ),
                                                                                  ),
                                                                                ],
                                                                              ),
                                                                              const SizedBox(height: 6),

                                                                              /// RATING
                                                                              (double.tryParse(tour.reviewAvgStar ?? '0') ?? 0.0) > 0 ?
                                                                              Row(
                                                                                children: [
                                                                                  ...List.generate(5, (i) {
                                                                                    double rating = double.tryParse(tour.reviewAvgStar ?? '0') ?? 0.0;

                                                                                    if (rating >= i + 1) {
                                                                                      return const Icon(Icons.star, color: Colors.orange, size: 18);
                                                                                    } else if (rating > i && rating < i + 1) {
                                                                                      return const Icon(Icons.star_half, color: Colors.orange, size: 18);
                                                                                    } else {
                                                                                      return const Icon(Icons.star_border, color: Colors.orange, size: 18);
                                                                                    }
                                                                                  }),
                                                                                  const SizedBox(width: 6),
                                                                                  Text(
                                                                                    "(${(double.tryParse(tour.reviewAvgStar ?? '0') ?? 0.0).toStringAsFixed(1)})",
                                                                                    style: const TextStyle(
                                                                                      fontSize: 13,
                                                                                      fontWeight: FontWeight.bold,
                                                                                      color: Colors.black87,
                                                                                    ),
                                                                                  ),
                                                                                ],
                                                                              ) : const SizedBox.shrink(),

                                                                              const Spacer(),

                                                                              /// BOOK NOW
                                                                              SizedBox(
                                                                                width: double.infinity,
                                                                                height: 35,
                                                                                child: ElevatedButton(
                                                                                  style: ElevatedButton.styleFrom(
                                                                                    backgroundColor: Colors.deepOrange,
                                                                                    shape: RoundedRectangleBorder(
                                                                                      borderRadius: BorderRadius.circular(10),
                                                                                    ),
                                                                                  ),
                                                                                  onPressed: () {
                                                                                    Navigator.push(
                                                                                      context,
                                                                                      CupertinoPageRoute(
                                                                                        builder: (context) => TourDetails(
                                                                                          productId: tour.id.toString(),
                                                                                        ),
                                                                                      ),
                                                                                    );
                                                                                  },
                                                                                  child: Text(
                                                                                    'Book Now',
                                                                                    style: TextStyle(
                                                                                      fontSize: screenWidth * 0.035,
                                                                                      fontWeight: FontWeight.bold,
                                                                                      color: Colors.white,
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
                                                ),
                                                const SizedBox(height: 15),
                                              ],
                                            ),
                                          )
                                        : const SizedBox.shrink(),
                                  ],
                                ),

                                // Shop
                                Column(
                                  children: [
                                    sectionModelList[1].section.status == 'true'
                                        ? Column(children: [
                                            Container(
                                                width: double.infinity,
                                                padding:
                                                    const EdgeInsets.all(7),
                                                margin:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 10),
                                                decoration: BoxDecoration(
                                                    color: Theme.of(context)
                                                        .primaryColor
                                                        .withOpacity(0.15),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10)),
                                                child: Row(
                                                  children: [
                                                    Container(
                                                      height: 15,
                                                      width: 4,
                                                      decoration: BoxDecoration(
                                                          color: Colors.orange,
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      20)),
                                                    ),
                                                    const SizedBox(
                                                      width: 5,
                                                    ),
                                                    Text(
                                                      getTranslated('shop',
                                                              context) ??
                                                          'Shop',
                                                      style: TextStyle(
                                                          fontSize: Dimensions
                                                              .fontSizeLarge,
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    ),
                                                  ],
                                                )),
                                            Container(
                                              margin: const EdgeInsets.all(7),
                                              padding: const EdgeInsets.all(7),
                                              height: size.width * 0.56,
                                              width: double.infinity,
                                              child: SingleChildScrollView(
                                                scrollDirection:
                                                    Axis.horizontal,
                                                child: Row(
                                                  children: [
                                                    Consumer<CategoryController>(
                                                      builder: (context,
                                                          categoryProvider,
                                                          child) {
                                                        if (categoryProvider
                                                                .categoryAllList
                                                                .length <
                                                            5) {
                                                          return const SizedBox();
                                                        }
                                                        var baseController =
                                                            Provider.of<
                                                                    SplashController>(
                                                                context,
                                                                listen: false);
                                                        return SizedBox(
                                                          width:
                                                              size.width * 0.8,
                                                          child: Card(
                                                            surfaceTintColor:
                                                                Colors.white,
                                                            // elevation: 10,
                                                            child: Column(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .center,
                                                              children: [
                                                                Row(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .spaceEvenly,
                                                                  // crossAxisAlignment: CrossAxisAlignment.start,
                                                                  children: [
                                                                    InkWell(
                                                                      splashColor:
                                                                          Colors
                                                                              .transparent,
                                                                      highlightColor:
                                                                          Colors
                                                                              .transparent,
                                                                      onTap:
                                                                          () {
                                                                        Navigator.push(
                                                                            context,
                                                                            CupertinoPageRoute(builder: (_) => BrandAndCategoryProductScreen(isBrand: false, id: categoryProvider.categoryAllList[0].id.toString(), name: categoryProvider.categoryAllList[0].name)));
                                                                      },
                                                                      child:
                                                                          Column(
                                                                        mainAxisAlignment:
                                                                            MainAxisAlignment.center,
                                                                        children: [
                                                                          CachedNetworkImage(
                                                                            imageUrl:
                                                                                '${baseController.baseUrls?.categoryImageUrl}/${categoryProvider.categoryAllList[0].icon}',
                                                                            height:
                                                                                40,
                                                                            width:
                                                                                40,
                                                                            fit:
                                                                                BoxFit.cover,
                                                                            errorWidget: (context, url, error) =>
                                                                                const Icon(Icons.broken_image),
                                                                          ),
                                                                          const SizedBox(
                                                                              height: 3),
                                                                          Center(
                                                                              child: SizedBox(
                                                                            width:
                                                                                50,
                                                                            child: Text('${categoryProvider.categoryAllList[0].name}',
                                                                                textAlign: TextAlign.center,
                                                                                maxLines: 2,
                                                                                overflow: TextOverflow.ellipsis,
                                                                                style: TextStyle(
                                                                                  color: Colors.black,
                                                                                  fontSize: Dimensions.fontSizeSmall,
                                                                                  letterSpacing: 0.5,
                                                                                  fontWeight: FontWeight.w600,
                                                                                )),
                                                                          )),
                                                                        ],
                                                                      ),
                                                                    ),
                                                                    Container(
                                                                      height: size
                                                                              .width *
                                                                          0.25,
                                                                      width:
                                                                          0.7,
                                                                      color: Colors
                                                                          .grey,
                                                                    ),
                                                                    InkWell(
                                                                      splashColor:
                                                                          Colors
                                                                              .transparent,
                                                                      highlightColor:
                                                                          Colors
                                                                              .transparent,
                                                                      onTap:
                                                                          () {
                                                                        Navigator.push(
                                                                            context,
                                                                            CupertinoPageRoute(builder: (_) => BrandAndCategoryProductScreen(isBrand: false, id: categoryProvider.categoryAllList[1].id.toString(), name: categoryProvider.categoryAllList[1].name)));
                                                                      },
                                                                      child:
                                                                          Column(
                                                                        mainAxisAlignment:
                                                                            MainAxisAlignment.center,
                                                                        children: [
                                                                          CachedNetworkImage(
                                                                            imageUrl:
                                                                                '${baseController.baseUrls?.categoryImageUrl}/${categoryProvider.categoryAllList[1].icon}',
                                                                            height:
                                                                                40,
                                                                            width:
                                                                                40,
                                                                            errorWidget: (context, url, error) =>
                                                                                const Icon(
                                                                              Icons.broken_image,
                                                                              color: Colors.grey,
                                                                              size: 24,
                                                                            ),
                                                                          ),
                                                                          const SizedBox(
                                                                              height: 3),
                                                                          Center(
                                                                              child: SizedBox(
                                                                            width:
                                                                                50,
                                                                            child: Text('${categoryProvider.categoryAllList[1].name}',
                                                                                textAlign: TextAlign.center,
                                                                                maxLines: 2,
                                                                                overflow: TextOverflow.ellipsis,
                                                                                style: TextStyle(
                                                                                  color: Colors.black,
                                                                                  fontSize: Dimensions.fontSizeSmall,
                                                                                  letterSpacing: 0.5,
                                                                                  fontWeight: FontWeight.w600,
                                                                                )),
                                                                          )),
                                                                        ],
                                                                      ),
                                                                    ),
                                                                    Container(
                                                                      height: size
                                                                              .width *
                                                                          0.25,
                                                                      width:
                                                                          0.7,
                                                                      color: Colors
                                                                          .grey,
                                                                    ),
                                                                    InkWell(
                                                                      splashColor:
                                                                          Colors
                                                                              .transparent,
                                                                      highlightColor:
                                                                          Colors
                                                                              .transparent,
                                                                      onTap:
                                                                          () {
                                                                        Navigator.push(
                                                                            context,
                                                                            CupertinoPageRoute(builder: (_) => BrandAndCategoryProductScreen(isBrand: false, id: categoryProvider.categoryAllList[2].id.toString(), name: categoryProvider.categoryAllList[2].name)));
                                                                      },
                                                                      child:
                                                                          Column(
                                                                        mainAxisAlignment:
                                                                            MainAxisAlignment.center,
                                                                        children: [
                                                                          CachedNetworkImage(
                                                                            imageUrl:
                                                                                '${baseController.baseUrls?.categoryImageUrl}/${categoryProvider.categoryAllList[2].icon}',
                                                                            height:
                                                                                40,
                                                                            width:
                                                                                40,
                                                                            errorWidget: (context, url, error) =>
                                                                                const Icon(
                                                                              Icons.broken_image,
                                                                              color: Colors.grey,
                                                                              size: 24,
                                                                            ),
                                                                          ),
                                                                          const SizedBox(
                                                                              height: 3),
                                                                          Center(
                                                                              child: SizedBox(
                                                                            width:
                                                                                50,
                                                                            child: Text('${categoryProvider.categoryAllList[2].name}',
                                                                                textAlign: TextAlign.center,
                                                                                maxLines: 2,
                                                                                overflow: TextOverflow.ellipsis,
                                                                                style: TextStyle(
                                                                                  color: Colors.black,
                                                                                  fontSize: Dimensions.fontSizeSmall,
                                                                                  letterSpacing: 0.5,
                                                                                  fontWeight: FontWeight.w600,
                                                                                )),
                                                                          )),
                                                                        ],
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                                const Divider(
                                                                  height: 0,
                                                                  color:
                                                                      ColorResources
                                                                          .grey,
                                                                  thickness: 3,
                                                                ),
                                                                Row(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .spaceEvenly,
                                                                  // crossAxisAlignment: CrossAxisAlignment.start,
                                                                  children: [
                                                                    InkWell(
                                                                      splashColor:
                                                                          Colors
                                                                              .transparent,
                                                                      highlightColor:
                                                                          Colors
                                                                              .transparent,
                                                                      onTap:
                                                                          () {
                                                                        Navigator.push(
                                                                            context,
                                                                            CupertinoPageRoute(builder: (_) => BrandAndCategoryProductScreen(isBrand: false, id: categoryProvider.categoryAllList[3].id.toString(), name: categoryProvider.categoryAllList[3].name)));
                                                                      },
                                                                      child:
                                                                          Column(
                                                                        mainAxisAlignment:
                                                                            MainAxisAlignment.center,
                                                                        children: [
                                                                          CachedNetworkImage(
                                                                            imageUrl:
                                                                                '${baseController.baseUrls?.categoryImageUrl}/${categoryProvider.categoryAllList[3].icon}',
                                                                            height:
                                                                                40,
                                                                            width:
                                                                                40,
                                                                            errorWidget: (context, url, error) =>
                                                                                const Icon(
                                                                              Icons.broken_image,
                                                                              color: Colors.grey,
                                                                              size: 24,
                                                                            ),
                                                                          ),
                                                                          const SizedBox(
                                                                              height: 3),
                                                                          Center(
                                                                              child: SizedBox(
                                                                            width:
                                                                                50,
                                                                            child: Text('${categoryProvider.categoryAllList[3].name}',
                                                                                textAlign: TextAlign.center,
                                                                                maxLines: 2,
                                                                                overflow: TextOverflow.ellipsis,
                                                                                style: TextStyle(
                                                                                  color: Colors.black,
                                                                                  fontSize: Dimensions.fontSizeSmall,
                                                                                  letterSpacing: 0.5,
                                                                                  fontWeight: FontWeight.w600,
                                                                                )),
                                                                          )),
                                                                        ],
                                                                      ),
                                                                    ),
                                                                    Container(
                                                                      height: size
                                                                              .width *
                                                                          0.25,
                                                                      width:
                                                                          0.7,
                                                                      color: Colors
                                                                          .grey,
                                                                    ),
                                                                    InkWell(
                                                                      splashColor:
                                                                          Colors
                                                                              .transparent,
                                                                      highlightColor:
                                                                          Colors
                                                                              .transparent,
                                                                      onTap:
                                                                          () {
                                                                        Navigator.push(
                                                                            context,
                                                                            CupertinoPageRoute(builder: (_) => BrandAndCategoryProductScreen(isBrand: false, id: categoryProvider.categoryAllList[4].id.toString(), name: categoryProvider.categoryAllList[4].name)));
                                                                      },
                                                                      child:
                                                                          Column(
                                                                        mainAxisAlignment:
                                                                            MainAxisAlignment.center,
                                                                        children: [
                                                                          CachedNetworkImage(
                                                                            imageUrl:
                                                                                '${baseController.baseUrls?.categoryImageUrl}/${categoryProvider.categoryAllList[4].icon}',
                                                                            height:
                                                                                40,
                                                                            width:
                                                                                40,
                                                                            errorWidget: (context, url, error) =>
                                                                                const Icon(
                                                                              Icons.broken_image,
                                                                              color: Colors.grey,
                                                                              size: 24,
                                                                            ),
                                                                          ),
                                                                          const SizedBox(
                                                                              height: 3),
                                                                          Center(
                                                                              child: SizedBox(
                                                                            width:
                                                                                50,
                                                                            child: Text('${categoryProvider.categoryAllList[4].name}',
                                                                                textAlign: TextAlign.center,
                                                                                maxLines: 2,
                                                                                overflow: TextOverflow.ellipsis,
                                                                                style: TextStyle(
                                                                                  color: Colors.black,
                                                                                  fontSize: Dimensions.fontSizeSmall,
                                                                                  letterSpacing: 0.5,
                                                                                  fontWeight: FontWeight.w600,
                                                                                )),
                                                                          )),
                                                                        ],
                                                                      ),
                                                                    ),
                                                                    Container(
                                                                      height: size
                                                                              .width *
                                                                          0.25,
                                                                      width:
                                                                          0.7,
                                                                      color: Colors
                                                                          .grey,
                                                                    ),
                                                                    InkWell(
                                                                      onTap:
                                                                          () {
                                                                        Navigator.push(
                                                                            context,
                                                                            CupertinoPageRoute(builder: (_) => const CategoryScreen()));
                                                                      },
                                                                      child:
                                                                          Column(
                                                                        mainAxisAlignment:
                                                                            MainAxisAlignment.center,
                                                                        children: [
                                                                          Icon(
                                                                            Icons.arrow_circle_right_outlined,
                                                                            size:
                                                                                45,
                                                                            color:
                                                                                Theme.of(context).primaryColor,
                                                                          ),
                                                                          const SizedBox(
                                                                              height: 3),
                                                                          Center(
                                                                              child: Text(
                                                                            getTranslated('see_more', context) ??
                                                                                'See\nMore',
                                                                            textAlign:
                                                                                TextAlign.center,
                                                                            maxLines:
                                                                                2,
                                                                            overflow:
                                                                                TextOverflow.ellipsis,
                                                                            style: titleHeader.copyWith(
                                                                                color: Colors.black,
                                                                                fontSize: Dimensions.fontSizeSmall,
                                                                                letterSpacing: 0.5,
                                                                                fontWeight: FontWeight.bold),
                                                                          )),
                                                                        ],
                                                                      ),
                                                                    ),
                                                                    // categoryWidget(image: 'assets/images/mahakal_logo_circle.png', name: 'See\nMore',color: Colors.black),
                                                                  ],
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        );
                                                      },
                                                    ),
                                                    const SizedBox(width: 10),

                                                    // SizedBox(
                                                    //     width: size.width * 0.57,
                                                    //     height: size.width * 0.57,
                                                    //   child: Card(
                                                    //     child: ClipRRect(
                                                    //         borderRadius: BorderRadius.circular(10),
                                                    //         child: Image.network(sectionModelList[1].banners[1].photo,fit: BoxFit.cover,)),
                                                    //   ),
                                                    // ),

                                                    Consumer<BannerController>(
                                                      builder: (context,
                                                          bannerProvider,
                                                          child) {
                                                        double width =
                                                            MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width;
                                                        return Container(
                                                          width:
                                                              size.width * 0.50,
                                                          height:
                                                              size.width * 0.50,
                                                          decoration:
                                                              BoxDecoration(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        10),
                                                            color: Colors.white,
                                                          ),
                                                          child: CarouselSlider(
                                                            options:
                                                                CarouselOptions(
                                                              viewportFraction:
                                                                  1.0,
                                                              enlargeCenterPage:
                                                                  false,
                                                              autoPlay: true,
                                                              autoPlayInterval:
                                                                  const Duration(
                                                                      seconds:
                                                                          3),
                                                              enableInfiniteScroll:
                                                                  true,
                                                            ),
                                                            items: List.generate(
                                                                sectionModelList[
                                                                        1]
                                                                    .banners
                                                                    .length,
                                                                (index) {
                                                              return InkWell(
                                                                onTap: () {
                                                                  if (sectionModelList[
                                                                              1]
                                                                          .banners[
                                                                              index]
                                                                          .appSectionResourceType ==
                                                                      'product') {
                                                                    if (sectionModelList[1]
                                                                            .banners[1]
                                                                            .product !=
                                                                        null) {
                                                                      Navigator.push(
                                                                          context,
                                                                          CupertinoPageRoute(
                                                                              builder: (_) => ProductDetails(
                                                                                    productId: sectionModelList[1].banners[1].product!.id,
                                                                                    slug: sectionModelList[1].banners[1].product!.slug,
                                                                                  )));
                                                                    }
                                                                  } else {
                                                                    Navigator.push(
                                                                        context,
                                                                        CupertinoPageRoute(
                                                                            builder: (_) => BrandAndCategoryProductScreen(
                                                                                isBrand: false,
                                                                                id: sectionModelList[1].banners[0].category!.id.toString(),
                                                                                name: sectionModelList[1].banners[0].category!.name)));
                                                                  }
                                                                  // if(sectionModelList[1].banners[index].resourceId != null){
                                                                  //   bannerProvider.clickBannerRedirect(context,
                                                                  //       sectionModelList[1].banners[index].resourceId,
                                                                  //       sectionModelList[1].banners[index].appSectionResourceType == 'product' ? sectionModelList[1].banners[1].product : null,
                                                                  //       sectionModelList[1].banners[index].resourceType);
                                                                  // }
                                                                },
                                                                child:
                                                                    ClipRRect(
                                                                        borderRadius:
                                                                            BorderRadius.circular(
                                                                                10),
                                                                        child:
                                                                            CachedNetworkImage(
                                                                          fit: BoxFit
                                                                              .cover,
                                                                          imageUrl: sectionModelList[1]
                                                                              .banners[index]
                                                                              .photo,
                                                                          placeholder: (context, url) =>
                                                                              Image.asset(
                                                                            'assets/images/mahakal_logo_circle.png',
                                                                            width:
                                                                                size.width,
                                                                            fit:
                                                                                BoxFit.cover,
                                                                          ),
                                                                        )),
                                                              );
                                                            }),
                                                          ),
                                                        );
                                                      },
                                                    ),

                                                    const SizedBox(width: 10),
                                                    Padding(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          vertical: 3),
                                                      child: Column(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: [
                                                          Expanded(
                                                            flex: 1,
                                                            child: InkWell(
                                                              onTap: () {
                                                                if (sectionModelList[
                                                                            1]
                                                                        .rightTop
                                                                        ?.appSectionResourceType ==
                                                                    'product') {
                                                                  if (sectionModelList[
                                                                              1]
                                                                          .rightTop
                                                                          ?.product !=
                                                                      null) {
                                                                    Navigator.push(
                                                                        context,
                                                                        CupertinoPageRoute(
                                                                            builder: (_) => ProductDetails(
                                                                                  productId: sectionModelList[1].rightTop?.product!.id,
                                                                                  slug: sectionModelList[1].rightTop?.product!.slug,
                                                                                )));
                                                                  }
                                                                } else {
                                                                  Navigator.push(
                                                                      context,
                                                                      CupertinoPageRoute(
                                                                          builder: (_) => BrandAndCategoryProductScreen(
                                                                              isBrand: false,
                                                                              id: '${sectionModelList[1].rightTop?.category?.id}',
                                                                              name: sectionModelList[1].rightTop?.category?.name)));
                                                                }
                                                              },
                                                              child: ClipRRect(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            10),
                                                                child:
                                                                    CachedNetworkImage(
                                                                  imageUrl:
                                                                      '${sectionModelList[1].rightTop?.photo}',
                                                                  height: 60,
                                                                  width: 200,
                                                                  fit: BoxFit
                                                                      .cover,
                                                                  errorWidget: (context,
                                                                          url,
                                                                          error) =>
                                                                      const Icon(
                                                                    Icons
                                                                        .broken_image,
                                                                    color: Colors
                                                                        .grey,
                                                                    size: 24,
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                            height: 6,
                                                          ),
                                                          Expanded(
                                                            flex: 1,
                                                            child: InkWell(
                                                              onTap: () {
                                                                if (sectionModelList[
                                                                            1]
                                                                        .rightBottom
                                                                        ?.appSectionResourceType ==
                                                                    'product') {
                                                                  if (sectionModelList[
                                                                              1]
                                                                          .rightBottom
                                                                          ?.product !=
                                                                      null) {
                                                                    Navigator.push(
                                                                        context,
                                                                        CupertinoPageRoute(
                                                                            builder: (_) => ProductDetails(
                                                                                  productId: sectionModelList[1].rightBottom?.product!.id,
                                                                                  slug: sectionModelList[1].rightBottom?.product!.slug,
                                                                                )));
                                                                  }
                                                                } else {
                                                                  Navigator.push(
                                                                      context,
                                                                      CupertinoPageRoute(
                                                                          builder: (_) => BrandAndCategoryProductScreen(
                                                                              isBrand: false,
                                                                              id: '${sectionModelList[1].rightBottom?.category!.id}',
                                                                              name: sectionModelList[1].rightBottom?.category!.name)));
                                                                }
                                                              },
                                                              child: ClipRRect(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            10),
                                                                child:
                                                                    CachedNetworkImage(
                                                                  imageUrl:
                                                                      '${sectionModelList[1].rightBottom?.photo}',
                                                                  height: 60,
                                                                  width: 200,
                                                                  fit: BoxFit
                                                                      .cover,
                                                                  errorWidget: (context,
                                                                          url,
                                                                          error) =>
                                                                      const Icon(
                                                                    Icons
                                                                        .broken_image,
                                                                    color: Colors
                                                                        .grey,
                                                                    size: 24,
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ])
                                        : const SizedBox(),
                                  ],
                                ),

                                // Book Pandit
                                SectionPanditBooking(
                                    sectionModelList: sectionModelList,
                                    widget: widget,
                                    size: size,
                                    categoryPanditModelList:
                                        offlineCategoryList,
                                    shimmer: shimmerScreenChadhava()),

                                // UpComing Events Title
                                SectionUpComingEvent(
                                    sectionModelList: sectionModelList,
                                    h: h,
                                    screenHeight: screenHeight,
                                    nearbyEvents: nearbyEvents,
                                    screenWidth: screenWidth),

                                // Donation Screen
                                SectionDonation(
                                    sectionModelList: sectionModelList,
                                    getAds: getAds,
                                    screenWidth: screenWidth),

                                // Mandir darshan
                                SectionMandirDarshan(
                                    sectionModelList: sectionModelList,
                                    h: h,
                                    darshanCategoryModelList:
                                        darshanCategoryModelList),

                                ////// Free Services ///////

                                // Jap Start
                                Column(
                                  key: oneKey,
                                  children: [
                                    Container(
                                        width: double.infinity,
                                        padding: const EdgeInsets.all(7),
                                        margin: const EdgeInsets.symmetric(
                                            horizontal: 10),
                                        decoration: BoxDecoration(
                                            color: Theme.of(context)
                                                .primaryColor
                                                .withOpacity(0.15),
                                            borderRadius:
                                                BorderRadius.circular(10)),
                                        child: Row(
                                          children: [
                                            Container(
                                              height: 15,
                                              width: 4,
                                              decoration: BoxDecoration(
                                                  color: Colors.orange,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          20)),
                                            ),
                                            const SizedBox(
                                              width: 5,
                                            ),
                                            Text(
                                              getTranslated(
                                                      'start_jap', context) ??
                                                  'Start Jap',
                                              style: TextStyle(
                                                  fontSize:
                                                      Dimensions.fontSizeLarge,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ],
                                        )),

                                    const SizedBox(
                                        height:
                                            12), // spacing from above section

                                    InkWell(
                                      onTap: () {
                                        // TODO: Navigate to Jap screen or show dialog
                                        Navigator.push(
                                          context,
                                          CupertinoPageRoute(
                                            builder: (context) =>
                                                JaapView(), // replace with actual screen
                                          ),
                                        );
                                      },
                                      borderRadius: BorderRadius.circular(16),
                                      child: Container(
                                        width: double.infinity,
                                        margin: const EdgeInsets.symmetric(
                                            horizontal: 10),
                                        padding: const EdgeInsets.all(16),
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [
                                              Colors.deepOrange.shade300,
                                              Colors.orangeAccent
                                            ],
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(15),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.deepOrange
                                                  .withOpacity(0.3),
                                              blurRadius: 8,
                                              offset: const Offset(0, 4),
                                            ),
                                          ],
                                        ),
                                        child: Row(
                                          children: [
                                            // Jap icon or animation
                                            Container(
                                              height: 60,
                                              width: 60,
                                              decoration: BoxDecoration(
                                                image: const DecorationImage(
                                                  image: AssetImage(
                                                      'assets/images/allcategories/animate/jaap_animation.gif'),
                                                  fit: BoxFit.cover,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                            ),
                                            const SizedBox(width: 16),
                                            // Text part
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    'अपना जाप शुरू करें',
                                                    style: TextStyle(
                                                      fontSize: Dimensions
                                                              .fontSizeLarge +
                                                          1,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Text(
                                                    'मंत्रों का जाप करें और मन की शांति पाएं',
                                                    style: TextStyle(
                                                      fontSize: Dimensions
                                                          .fontSizeSmall,
                                                      color: Colors.white
                                                          .withOpacity(0.9),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            const Icon(
                                                Icons.arrow_forward_ios_rounded,
                                                color: Colors.white,
                                                size: 20),
                                          ],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(
                                        height:
                                            12), // spacing from above section
                                  ],
                                ),

                                // Sahitya
                                Column(
                                  key: twoKey,
                                  children: [
                                    sectionModelList[11].section.status ==
                                            'true'
                                        ? Column(children: [
                                            Container(
                                              color: Colors.purple.shade50,
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Padding(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 10.0,
                                                        vertical: 6.0),
                                                    child: Row(
                                                      children: [
                                                        Container(
                                                          height: 15,
                                                          width: 4,
                                                          decoration: BoxDecoration(
                                                              color:
                                                                  Colors.purple,
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          20)),
                                                        ),
                                                        const SizedBox(
                                                            width: 10),
                                                        Text(
                                                          getTranslated(
                                                                  'sahitya_sansaar',
                                                                  context) ??
                                                              'Sahitya',
                                                          style: TextStyle(
                                                              fontSize: Dimensions
                                                                  .fontSizeLarge,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                        ),
                                                        const Spacer(),
                                                        InkWell(
                                                          onTap: () {
                                                            Navigator.push(
                                                                context,
                                                                PageAnimationTransition(
                                                                    page:
                                                                        const SahityaHome(),
                                                                    pageAnimationType:
                                                                        RightToLeftTransition()));
                                                          },
                                                          child: Text(
                                                            getTranslated(
                                                                    'VIEW_ALL',
                                                                    context) ??
                                                                'view All',
                                                            style: TextStyle(
                                                                fontSize: Dimensions
                                                                    .fontSizeLarge,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                color: Colors
                                                                    .purple),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  SingleChildScrollView(
                                                    scrollDirection:
                                                        Axis.horizontal,
                                                    child: Row(
                                                      children: [
                                                        const SizedBox(
                                                          width: 10,
                                                        ),
                                                        Container(
                                                          height: 200,
                                                          width: 140,
                                                          decoration: const BoxDecoration(
                                                              image: DecorationImage(
                                                                  image: AssetImage(
                                                                      'assets/images/sahitya_books.gif'),
                                                                  fit: BoxFit
                                                                      .fill)),
                                                        ),
                                                        const SizedBox(
                                                          width: 6,
                                                        ),
                                                        SizedBox(
                                                          height: 210,
                                                          child:
                                                              ListView.builder(
                                                            physics:
                                                                const BouncingScrollPhysics(),
                                                            itemCount:
                                                                sahityaList
                                                                    .length,
                                                            shrinkWrap: true,
                                                            scrollDirection:
                                                                Axis.horizontal,
                                                            itemBuilder:
                                                                (context,
                                                                    index) {
                                                              return InkWell(
                                                                  onTap: () {
                                                                    handleAction(
                                                                        sahityaList[index]
                                                                            .enName);
                                                                  },
                                                                  child:
                                                                      Container(
                                                                    margin: const EdgeInsets
                                                                        .only(
                                                                        right:
                                                                            8,
                                                                        bottom:
                                                                            12),
                                                                    padding:
                                                                        const EdgeInsets
                                                                            .all(
                                                                            5),
                                                                    width: 150,
                                                                    decoration:
                                                                        BoxDecoration(
                                                                      color: Colors
                                                                          .white,
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              8),
                                                                    ),
                                                                    child:
                                                                        Container(
                                                                      height:
                                                                          140,
                                                                      width: double
                                                                          .infinity,
                                                                      decoration:
                                                                          BoxDecoration(
                                                                        borderRadius:
                                                                            BorderRadius.circular(8),
                                                                      ),
                                                                      child:
                                                                          ClipRRect(
                                                                        borderRadius:
                                                                            BorderRadius.circular(8),
                                                                        child:
                                                                            CachedNetworkImage(
                                                                          imageUrl:
                                                                              sahityaList[index].image,
                                                                          fit: BoxFit
                                                                              .fill,
                                                                          width:
                                                                              double.infinity,
                                                                          height:
                                                                              double.infinity,
                                                                          errorWidget: (context, url, error) =>
                                                                              const NoImageWidget(),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  )

                                                                  //     Container(
                                                                  //   margin:
                                                                  //       const EdgeInsets
                                                                  //           .only(
                                                                  //           right:
                                                                  //               5,
                                                                  //           bottom:
                                                                  //               10),
                                                                  //   width: 140,
                                                                  //   decoration: BoxDecoration(
                                                                  //       color: Colors
                                                                  //           .white,
                                                                  //       border: Border.all(
                                                                  //           color: Colors
                                                                  //               .grey
                                                                  //               .shade300,
                                                                  //           width:
                                                                  //               1.5),
                                                                  //       borderRadius:
                                                                  //           BorderRadius.circular(
                                                                  //               8.0)),
                                                                  //   child:
                                                                  //       Padding(
                                                                  //     padding:
                                                                  //         const EdgeInsets
                                                                  //             .all(
                                                                  //             4.0),
                                                                  //     child:
                                                                  //         Column(
                                                                  //       crossAxisAlignment:
                                                                  //           CrossAxisAlignment
                                                                  //               .start,
                                                                  //       children: [
                                                                  //         Expanded(
                                                                  //           flex:
                                                                  //               1,
                                                                  //           child:
                                                                  //               Container(
                                                                  //             height:
                                                                  //                 130,
                                                                  //             width:
                                                                  //                 130,
                                                                  //             decoration:
                                                                  //                 BoxDecoration(
                                                                  //               borderRadius: BorderRadius.circular(8),
                                                                  //               color: Colors.grey.shade300,
                                                                  //             ),
                                                                  //             child:
                                                                  //                 ClipRRect(
                                                                  //               borderRadius: BorderRadius.circular(6),
                                                                  //               child: CachedNetworkImage(
                                                                  //                 imageUrl: sahityaList[index].image,
                                                                  //                 fit: BoxFit.cover,
                                                                  //                 errorWidget: (context, url, error) => const Icon(Icons.error),
                                                                  //               ),
                                                                  //             ),
                                                                  //           ),
                                                                  //         ),
                                                                  //
                                                                  //         Expanded(
                                                                  //             flex:
                                                                  //                 0,
                                                                  //             child:
                                                                  //                 Text(
                                                                  //               sahityaList[index].enName,
                                                                  //               style: const TextStyle(fontSize: 14, color: Colors.black, fontWeight: FontWeight.w400, overflow: TextOverflow.ellipsis),
                                                                  //               maxLines: 1,
                                                                  //             )),
                                                                  //
                                                                  //         // Text.rich(
                                                                  //         //     TextSpan(
                                                                  //         //         children: [
                                                                  //         //           TextSpan(
                                                                  //         //               text:'₹${muhuratModelList[index].counsellingSellingPrice} ',style: const TextStyle(fontSize: 14,fontWeight: FontWeight.bold,color:Colors.blue)
                                                                  //         //           ),
                                                                  //         //           TextSpan(
                                                                  //         //               text:'₹${muhuratModelList[index].counsellingMainPrice}',style: const TextStyle(fontSize: 14,fontWeight: FontWeight.bold,color: Colors.black,decoration: TextDecoration.lineThrough)
                                                                  //         //           ),
                                                                  //         //         ]
                                                                  //         //     )
                                                                  //         // )
                                                                  //       ],
                                                                  //     ),
                                                                  //   ),
                                                                  // ),
                                                                  );
                                                            },
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                          width: 10,
                                                        )
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            const SizedBox(height: 15),
                                          ])
                                        : const SizedBox.shrink(),
                                  ],
                                ),

                                // Rashifal
                                SectionRashifal(
                                    key: threeKey,
                                    sectionModelList: sectionModelList,
                                    size: size,
                                    rashiList: rashiList,
                                    rashiListName: rashiListName),

                                // Vaidik-Astrology
                                SectionAstrology(
                                    key: fourKey,
                                    sectionModelList: sectionModelList,
                                    size: size),

                                // Calculator
                                CalculatorSection(
                                  key: nineKey,
                                  calculatorList: calculatorList,
                                  sectionModelList: sectionModelList,
                                  calculatorForm: calculatorForm,
                                  dialogIndex: dialogIndex,
                                  size: size,
                                ),

                                // Jyotish-Paramarsh astrology-consultation
                                Column(
                                  children: [
                                    sectionModelList[5].section.status == 'true'
                                        ? Column(children: [
                                            Container(
                                                width: double.infinity,
                                                padding:
                                                    const EdgeInsets.all(7),
                                                margin:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 10),
                                                decoration: BoxDecoration(
                                                    color: Theme.of(context)
                                                        .primaryColor
                                                        .withOpacity(0.15),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10)),
                                                child: Row(
                                                  children: [
                                                    Container(
                                                      height: 15,
                                                      width: 4,
                                                      decoration: BoxDecoration(
                                                          color: Colors.orange,
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      20)),
                                                    ),
                                                    const SizedBox(
                                                      width: 5,
                                                    ),
                                                    Text(
                                                      getTranslated(
                                                              'jyotish_paramarsh',
                                                              context) ??
                                                          'Jyotish Paramarsh',
                                                      style: TextStyle(
                                                          fontSize: Dimensions
                                                              .fontSizeLarge,
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    ),
                                                  ],
                                                )),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.all(10.0),
                                              child: SizedBox(
                                                width: 1000,
                                                child: SingleChildScrollView(
                                                  scrollDirection:
                                                      Axis.horizontal,
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      SizedBox(
                                                        width: size.width * 0.5,
                                                        child: Card(
                                                          surfaceTintColor:
                                                              Colors.white,
                                                          elevation: 2,
                                                          child: Column(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .center,
                                                            children: [
                                                              Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .spaceEvenly,
                                                                // crossAxisAlignment: CrossAxisAlignment.start,
                                                                children: [
                                                                  CategroyWidgetExplore(
                                                                    image:
                                                                        'assets/images/allcategories/vivahicon.png',
                                                                    name: getTranslated(
                                                                            'vivah_yog',
                                                                            context) ??
                                                                        'Vivah\nYog',
                                                                    color: Colors
                                                                        .black,
                                                                    onTap: () {
                                                                      int itemId =
                                                                          getIdByName(
                                                                              'Marriage Prospects')!;
                                                                      print(
                                                                          '>>>>>> item id $itemId');
                                                                      Navigator.push(
                                                                          context,
                                                                          PageAnimationTransition(
                                                                              page: AstroDetailsView(productId: itemId, isProduct: false),
                                                                              pageAnimationType: RightToLeftTransition()));
                                                                    },
                                                                  ),
                                                                  Container(
                                                                    height: size
                                                                            .width *
                                                                        0.235,
                                                                    width: 0.7,
                                                                    color: Colors
                                                                        .grey,
                                                                  ),
                                                                  CategroyWidgetExplore(
                                                                    image:
                                                                        'assets/images/allcategories/vyapar yog.png',
                                                                    name: getTranslated(
                                                                            'vyapar_yog',
                                                                            context) ??
                                                                        'Vivah\nYog',
                                                                    color: Colors
                                                                        .black,
                                                                    onTap: () {
                                                                      int itemId =
                                                                          getIdByName(
                                                                              'Business/Career Prospects')!;
                                                                      print(
                                                                          '>>>>>> item id $itemId');
                                                                      Navigator.push(
                                                                          context,
                                                                          PageAnimationTransition(
                                                                              page: AstroDetailsView(productId: itemId, isProduct: false),
                                                                              pageAnimationType: RightToLeftTransition()));
                                                                    },
                                                                  ),
                                                                ],
                                                              ),
                                                              const Divider(
                                                                height: 0,
                                                                color:
                                                                    ColorResources
                                                                        .grey,
                                                                thickness: 3,
                                                              ),
                                                              Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .spaceEvenly,
                                                                // crossAxisAlignment: CrossAxisAlignment.start,
                                                                children: [
                                                                  SizedBox(
                                                                      width: size
                                                                              .width *
                                                                          0.115,
                                                                      child:
                                                                          CategroyWidgetExplore(
                                                                        image:
                                                                            'assets/images/allcategories/Santan yog ion.png',
                                                                        name: getTranslated('santam_yog',
                                                                                context) ??
                                                                            'Santan\nYog',
                                                                        color: Colors
                                                                            .black,
                                                                        onTap:
                                                                            () {
                                                                          int itemId =
                                                                              getIdByName('Childbirth Prospects')!;
                                                                          print(
                                                                              '>>>>>> item id $itemId');
                                                                          Navigator.push(
                                                                              context,
                                                                              PageAnimationTransition(page: AstroDetailsView(productId: itemId, isProduct: false), pageAnimationType: RightToLeftTransition()));
                                                                        },
                                                                      )),
                                                                  Container(
                                                                    height: size
                                                                            .width *
                                                                        0.22,
                                                                    width: 0.7,
                                                                    color: Colors
                                                                        .grey,
                                                                  ),
                                                                  InkWell(
                                                                    onTap: () {
                                                                      Navigator.push(
                                                                          context,
                                                                          PageAnimationTransition(
                                                                              page: const AstroConsultationView(),
                                                                              pageAnimationType: RightToLeftTransition()));
                                                                    },
                                                                    child:
                                                                        Column(
                                                                      mainAxisAlignment:
                                                                          MainAxisAlignment
                                                                              .center,
                                                                      children: [
                                                                        Padding(
                                                                          padding: const EdgeInsets
                                                                              .all(
                                                                              2.5),
                                                                          child:
                                                                              Icon(
                                                                            Icons.arrow_circle_right_outlined,
                                                                            size:
                                                                                40,
                                                                            color:
                                                                                Theme.of(context).primaryColor,
                                                                          ),
                                                                        ),

                                                                        // Padding(
                                                                        //   padding: const EdgeInsets.all(2.5),
                                                                        //   child: Image.asset(
                                                                        //     'assets/testImage/categories/seeMore.png',
                                                                        //     height: 37,
                                                                        //     width: 37,
                                                                        //     color: Theme.of(context).primaryColor,
                                                                        //   ),
                                                                        // ),
                                                                        const SizedBox(
                                                                            height:
                                                                                3),
                                                                        Center(
                                                                            child:
                                                                                Text(
                                                                          getTranslated('see_more', context) ??
                                                                              'See More',
                                                                          textAlign:
                                                                              TextAlign.center,
                                                                          maxLines:
                                                                              2,
                                                                          overflow:
                                                                              TextOverflow.ellipsis,
                                                                          style: titleHeader.copyWith(
                                                                              color: Colors.black,
                                                                              fontSize: Dimensions.fontSizeSmall,
                                                                              letterSpacing: 0.5,
                                                                              fontWeight: FontWeight.bold),
                                                                        )),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                      const SizedBox(
                                                        width: 10,
                                                      ),
                                                      Container(
                                                        width:
                                                            size.width * 0.45,
                                                        height:
                                                            size.width * 0.45,
                                                        decoration:
                                                            BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(10),
                                                          color: Colors.white,
                                                        ),
                                                        child: CarouselSlider(
                                                          options:
                                                              CarouselOptions(
                                                            viewportFraction:
                                                                1.0,
                                                            enlargeCenterPage:
                                                                false,
                                                            autoPlay: true,
                                                            autoPlayInterval:
                                                                const Duration(
                                                                    seconds: 3),
                                                            enableInfiniteScroll:
                                                                true,
                                                          ),
                                                          items: List.generate(
                                                              sectionModelList[
                                                                      5]
                                                                  .banners
                                                                  .length,
                                                              (index) {
                                                            return ClipRRect(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            10),
                                                                child:
                                                                    CachedNetworkImage(
                                                                  fit: BoxFit
                                                                      .cover,
                                                                  imageUrl: sectionModelList[
                                                                          5]
                                                                      .banners[
                                                                          index]
                                                                      .photo,
                                                                  placeholder: (context,
                                                                          url) =>
                                                                      Image
                                                                          .asset(
                                                                    'assets/images/mahakal_logo_circle.png',
                                                                    width: size
                                                                        .width,
                                                                    fit: BoxFit
                                                                        .cover,
                                                                  ),
                                                                ));
                                                          }),
                                                        ),
                                                      ),
                                                      const SizedBox(
                                                        width: 10,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ])
                                        : const SizedBox.shrink(),
                                  ],
                                ),

                                // JanmJankari se janiye
                                Column(
                                  key: eightKey,
                                  children: [
                                    sectionModelList[6].section.status == 'true'
                                        ? Column(children: [
                                            Container(
                                                width: double.infinity,
                                                padding:
                                                    const EdgeInsets.all(7),
                                                margin:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 10),
                                                decoration: BoxDecoration(
                                                    color: Theme.of(context)
                                                        .primaryColor
                                                        .withOpacity(0.15),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10)),
                                                child: Row(
                                                  children: [
                                                    Container(
                                                      height: 15,
                                                      width: 4,
                                                      decoration: BoxDecoration(
                                                          color: Colors.orange,
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      20)),
                                                    ),
                                                    const SizedBox(
                                                      width: 5,
                                                    ),
                                                    Text(
                                                      getTranslated(
                                                              'janm_jankari',
                                                              context) ??
                                                          'Janm Jankari Se Janiye',
                                                      style: TextStyle(
                                                          fontSize: Dimensions
                                                              .fontSizeLarge,
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    ),
                                                  ],
                                                )),
                                            const SizedBox(
                                              height: 10,
                                            ),
                                            Container(
                                              margin: const EdgeInsets.all(7),
                                              width: double.infinity,
                                              child: Card(
                                                surfaceTintColor: Colors.white,
                                                elevation: 3,
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceEvenly,
                                                  // crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    CategroyWidgetExplore(
                                                      image:
                                                          'assets/images/allcategories/anukul_mantra_icon_animation.gif',
                                                      name: getTranslated(
                                                              'anukul_mantra',
                                                              context) ??
                                                          'Anukul\nMantra',
                                                      color: Colors.black,
                                                      onTap: () =>
                                                          janmJankariForm(
                                                              context, 0),
                                                    ),
                                                    Container(
                                                      height: 95,
                                                      width: 0.7,
                                                      color: Colors.grey,
                                                    ),
                                                    CategroyWidgetExplore(
                                                      image:
                                                          'assets/images/allcategories/vrat and thoyahar icon.png',
                                                      name: getTranslated(
                                                              'shubh_vrat',
                                                              context) ??
                                                          'Shubh\nVrat',
                                                      color: Colors.black,
                                                      onTap: () =>
                                                          janmJankariForm(
                                                              context, 1),
                                                    ),
                                                    Container(
                                                      height: 95,
                                                      width: 0.7,
                                                      color: Colors.grey,
                                                    ),
                                                    CategroyWidgetExplore(
                                                      image:
                                                          'assets/images/allcategories/anukul_time icon_animation.gif',
                                                      name: getTranslated(
                                                              'gayatri_mantra',
                                                              context) ??
                                                          'Anukul\nMantra',
                                                      color: Colors.black,
                                                      onTap: () {
                                                        janmJankariForm(
                                                            context, 2);
                                                      },
                                                    ),
                                                    Container(
                                                      height: 95,
                                                      width: 0.7,
                                                      color: Colors.grey,
                                                    ),
                                                    CategroyWidgetExplore(
                                                      image:
                                                          'assets/images/allcategories/Anukul dev icon.png',
                                                      name: getTranslated(
                                                              'anukul_dev',
                                                              context) ??
                                                          'Gayatri\nMantra',
                                                      color: Colors.black,
                                                      onTap: () =>
                                                          janmJankariForm(
                                                              context, 3),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            const SizedBox(
                                              height: 5,
                                            ),
                                          ])
                                        : const SizedBox.shrink(),
                                  ],
                                ),

                                // Shubh Muhrat
                                Column(
                                  children: [
                                    sectionModelList[7].section.status == 'true'
                                        ? Column(children: [
                                            Container(
                                                width: double.infinity,
                                                padding:
                                                    const EdgeInsets.all(7),
                                                margin:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 10),
                                                decoration: BoxDecoration(
                                                    color: Theme.of(context)
                                                        .primaryColor
                                                        .withOpacity(0.15),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10)),
                                                child: Row(
                                                  children: [
                                                    Container(
                                                      height: 15,
                                                      width: 4,
                                                      decoration: BoxDecoration(
                                                          color: Colors.orange,
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      20)),
                                                    ),
                                                    const SizedBox(
                                                      width: 5,
                                                    ),
                                                    Text(
                                                      getTranslated(
                                                              'shubh_muhrat',
                                                              context) ??
                                                          'Shubh Muhoort',
                                                      style: TextStyle(
                                                          fontSize: Dimensions
                                                              .fontSizeLarge,
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    ),
                                                  ],
                                                )),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.all(10.0),
                                              child: SizedBox(
                                                width: 1000,
                                                child: SingleChildScrollView(
                                                  scrollDirection:
                                                      Axis.horizontal,
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Container(
                                                        width:
                                                            size.width * 0.45,
                                                        height:
                                                            size.width * 0.45,
                                                        decoration:
                                                            BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(10),
                                                          color: Colors.white,
                                                        ),
                                                        child: CarouselSlider(
                                                          options:
                                                              CarouselOptions(
                                                            viewportFraction:
                                                                1.0,
                                                            enlargeCenterPage:
                                                                false,
                                                            autoPlay: true,
                                                            autoPlayInterval:
                                                                const Duration(
                                                                    seconds: 3),
                                                            enableInfiniteScroll:
                                                                true,
                                                          ),
                                                          items: List.generate(
                                                              sectionModelList[
                                                                      7]
                                                                  .banners
                                                                  .length,
                                                              (index) {
                                                            return ClipRRect(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            10),
                                                                child:
                                                                    CachedNetworkImage(
                                                                  fit: BoxFit
                                                                      .cover,
                                                                  imageUrl: sectionModelList[
                                                                          7]
                                                                      .banners[
                                                                          index]
                                                                      .photo,
                                                                  placeholder: (context,
                                                                          url) =>
                                                                      Image
                                                                          .asset(
                                                                    'assets/images/mahakal_logo_circle.png',
                                                                    width: size
                                                                        .width,
                                                                    fit: BoxFit
                                                                        .cover,
                                                                  ),
                                                                ));
                                                          }),
                                                        ),
                                                      ),
                                                      const SizedBox(width: 5),
                                                      SizedBox(
                                                        height:
                                                            size.width * 0.5,
                                                        width: size.width * 0.5,
                                                        child: Card(
                                                          surfaceTintColor:
                                                              Colors.white,
                                                          elevation: 2,
                                                          child: Column(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .center,
                                                            children: [
                                                              Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .spaceEvenly,
                                                                // crossAxisAlignment: CrossAxisAlignment.start,
                                                                children: [
                                                                  CategroyWidgetExplore(
                                                                    image:
                                                                        'assets/images/allcategories/Grah pravesh iconn.png',
                                                                    name: getTranslated(
                                                                            'grah_pravesh',
                                                                            context) ??
                                                                        'Grah\nPravesh',
                                                                    color: Colors
                                                                        .black,
                                                                    onTap: () {
                                                                      int itemId =
                                                                          getIdByNamMuhurat(
                                                                              'Housewarming Muhurat')!;
                                                                      print(
                                                                          '>>>>>> item id $itemId');
                                                                      Navigator.push(
                                                                          context,
                                                                          PageAnimationTransition(
                                                                              page: AstroDetailsView(productId: itemId, isProduct: false),
                                                                              pageAnimationType: RightToLeftTransition()));
                                                                    },
                                                                  ),
                                                                  Container(
                                                                    height: size
                                                                            .width *
                                                                        0.235,
                                                                    width: 0.7,
                                                                    color: Colors
                                                                        .grey,
                                                                  ),
                                                                  CategroyWidgetExplore(
                                                                    image:
                                                                        'assets/images/allcategories/Vivah muhurt icon 3.png',
                                                                    name: getTranslated(
                                                                            'vivah_muhrat',
                                                                            context) ??
                                                                        'Vivah\nMuhoort',
                                                                    color: Colors
                                                                        .black,
                                                                    onTap: () {
                                                                      int itemId =
                                                                          getIdByNamMuhurat(
                                                                              'Marriage Muhurat')!;
                                                                      print(
                                                                          '>>>>>> item id $itemId');
                                                                      Navigator.push(
                                                                          context,
                                                                          PageAnimationTransition(
                                                                              page: AstroDetailsView(productId: itemId, isProduct: false),
                                                                              pageAnimationType: RightToLeftTransition()));
                                                                    },
                                                                  ),
                                                                ],
                                                              ),
                                                              const Divider(
                                                                height: 0,
                                                                color:
                                                                    ColorResources
                                                                        .grey,
                                                                thickness: 3,
                                                              ),
                                                              Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .spaceEvenly,
                                                                // crossAxisAlignment: CrossAxisAlignment.start,
                                                                children: [
                                                                  SizedBox(
                                                                      width: size
                                                                              .width *
                                                                          0.115,
                                                                      child: InkWell(
                                                                          child: CategroyWidgetExplore(
                                                                        image:
                                                                            'assets/images/allcategories/Mundan muhurt icon 2.png',
                                                                        name: getTranslated('mundan_muhrat',
                                                                                context) ??
                                                                            'Mundan\nMuhoort',
                                                                        color: Colors
                                                                            .black,
                                                                        onTap:
                                                                            () {
                                                                          int itemId =
                                                                              getIdByNamMuhurat('Mundan Muhurat')!;
                                                                          print(
                                                                              '>>>>>> item id $itemId');
                                                                          Navigator.push(
                                                                              context,
                                                                              PageAnimationTransition(page: AstroDetailsView(productId: itemId, isProduct: false), pageAnimationType: RightToLeftTransition()));
                                                                        },
                                                                      ))),
                                                                  Container(
                                                                    height: size
                                                                            .width *
                                                                        0.22,
                                                                    width: 0.7,
                                                                    color: Colors
                                                                        .grey,
                                                                  ),
                                                                  InkWell(
                                                                    onTap: () {
                                                                      Navigator.push(
                                                                          context,
                                                                          PageAnimationTransition(
                                                                              page: const ShubhMuhuratView(),
                                                                              pageAnimationType: RightToLeftTransition()));
                                                                    },
                                                                    child:
                                                                        Column(
                                                                      mainAxisAlignment:
                                                                          MainAxisAlignment
                                                                              .center,
                                                                      children: [
                                                                        Padding(
                                                                          padding: const EdgeInsets
                                                                              .all(
                                                                              2.5),
                                                                          child:
                                                                              Icon(
                                                                            Icons.arrow_circle_right_outlined,
                                                                            size:
                                                                                40,
                                                                            color:
                                                                                Theme.of(context).primaryColor,
                                                                          ),
                                                                        ),

                                                                        // Padding(
                                                                        //   padding: const EdgeInsets.all(2.5),
                                                                        //   child: Image.asset(
                                                                        //     'assets/testImage/categories/seeMore.png',
                                                                        //     height: 37,
                                                                        //     width: 37,
                                                                        //     color: Theme.of(context).primaryColor,
                                                                        //   ),
                                                                        // ),
                                                                        const SizedBox(
                                                                            height:
                                                                                3),
                                                                        Center(
                                                                            child:
                                                                                Text(
                                                                          getTranslated('see_more', context) ??
                                                                              'See More',
                                                                          textAlign:
                                                                              TextAlign.center,
                                                                          maxLines:
                                                                              2,
                                                                          overflow:
                                                                              TextOverflow.ellipsis,
                                                                          style: titleHeader.copyWith(
                                                                              color: Colors.black,
                                                                              fontSize: Dimensions.fontSizeSmall,
                                                                              letterSpacing: 0.5,
                                                                              fontWeight: FontWeight.bold),
                                                                        )),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                      const SizedBox(width: 5),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(height: 15),
                                          ])
                                        : const SizedBox.shrink(),
                                  ],
                                ),

                                // Sangeet Title
                                SectionSangeet(
                                    key: fiveKey,
                                    sectionModelList: sectionModelList,
                                    sangeetModelList: sangeetModelList),

                                // Read Blogs
                                SectionReadBlogs(
                                    key: sixKey,
                                    sectionModelList: sectionModelList,
                                    h: h,
                                    screenHeight: screenHeight,
                                    subCategoryList: latestBlogs,
                                    screenWidth: screenWidth),

                                // Devotional Serial Title 9
                                SectionVideoSerials(
                                    key: tenKey,
                                    sectionModelList: sectionModelList,
                                    subcategorySerials: subcategorySerials),

                                // Categories
                                SectionCategories(
                                    sectionModelList: sectionModelList),

                                // Live Darshan Title//Live Darshan widget
                                SectionLiveDarshan(
                                    sectionModelList: sectionModelList,
                                    key: tweleveKey,
                                    size: size,
                                    dynamicTabs: dynamicTabs,
                                    allVideos: allVideos),

                                // Spiritual Guru Title
                                SectionSpiritual(
                                    key: thirteenKey,
                                    sectionModelList: sectionModelList,
                                    size: size,
                                    subcategory: subcategory),

                                // Devotional Movies 6
                                SectionDevotionalMovies(
                                    key: sevenKey,
                                    sectionModelList: sectionModelList,
                                    subcategoryMovies: subcategoryMovies),

                                // Path Of Bhakti
                                Column(key: elevenKey, children: [
                                  Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.all(7),
                                      margin: const EdgeInsets.symmetric(
                                          horizontal: 10),
                                      decoration: BoxDecoration(
                                          color: Theme.of(context)
                                              .primaryColor
                                              .withOpacity(0.15),
                                          borderRadius:
                                              BorderRadius.circular(10)),
                                      child: Row(
                                        children: [
                                          Container(
                                            height: 15,
                                            width: 4,
                                            decoration: BoxDecoration(
                                                color: Colors.orange,
                                                borderRadius:
                                                    BorderRadius.circular(20)),
                                          ),
                                          const SizedBox(
                                            width: 5,
                                          ),
                                          Text(
                                            getTranslated(
                                                    'top_category', context) ??
                                                'Top Categories',
                                            style: TextStyle(
                                                fontSize:
                                                    Dimensions.fontSizeLarge,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ],
                                      )),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  Container(
                                    margin: const EdgeInsets.all(7),
                                    width: double.infinity,
                                    child: Card(
                                      surfaceTintColor: Colors.white,
                                      elevation: 3,
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        // crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          // Sahitya
                                          Expanded(
                                            child: InkWell(
                                                child: CategroyWidgetExplore(
                                              image:
                                                  'assets/testImage/categories/shaitya_icon.png',
                                              name: getTranslated(
                                                      'sahitya', context) ??
                                                  'Sahitya',
                                              color: Colors.black,
                                              onTap: () {
                                                Navigator.push(
                                                    context,
                                                    PageAnimationTransition(
                                                        page:
                                                            const SahityaHome(),
                                                        pageAnimationType:
                                                            RightToLeftTransition()));
                                              },
                                            )),
                                          ),
                                          Container(
                                            height: 95,
                                            width: 0.7,
                                            color: Colors.grey,
                                          ),

                                          // Jap
                                          Expanded(
                                            child: CategroyWidgetExplore(
                                              image:
                                                  'assets/images/allcategories/animate/jaap_animation.gif',
                                              name: getTranslated(
                                                      'jaap', context) ??
                                                  'Jaap',
                                              color: Colors.black,
                                              onTap: () {
                                                Navigator.push(
                                                    context,
                                                    PageAnimationTransition(
                                                        page: JaapView(
                                                          initialIndex: 0,
                                                        ),
                                                        pageAnimationType:
                                                            RightToLeftTransition()));
                                              },
                                            ),
                                          ),
                                          Container(
                                            height: 95,
                                            width: 0.7,
                                            color: Colors.grey,
                                          ),

                                          // Ram Shalakha
                                          Expanded(
                                            child: CategroyWidgetExplore(
                                              image:
                                                  'assets/testImage/categories/ram_shalakha.png',
                                              name: getTranslated(
                                                      'ram_shalakha',
                                                      context) ??
                                                  'News',
                                              color: Colors.black,
                                              onTap: () {
                                                Navigator.push(
                                                    context,
                                                    PageAnimationTransition(
                                                        page:
                                                            const RamShalaka(),
                                                        pageAnimationType:
                                                            RightToLeftTransition()));
                                              },
                                            ),
                                          ),
                                          Container(
                                            height: 95,
                                            width: 0.7,
                                            color: Colors.grey,
                                          ),

                                          // Ram Lekhan
                                          Expanded(
                                            child: CategroyWidgetExplore(
                                              image:
                                                  'assets/animated/ramlekhan_image.gif',
                                              name: getTranslated(
                                                      'ram_lekhan', context) ??
                                                  'Ram Lekhan',
                                              color: Colors.black,
                                              onTap: () {
                                                Navigator.push(
                                                    context,
                                                    PageAnimationTransition(
                                                        page: JaapView(
                                                          initialIndex: 1,
                                                        ),
                                                        pageAnimationType:
                                                            RightToLeftTransition()));
                                              },
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 5,
                                  ),
                                ]),

                                // New Arrivals Title
                                Column(
                                  children: [
                                    sectionModelList[20].section.status ==
                                            'true'
                                        ? Column(children: [
                                            Container(
                                                width: double.infinity,
                                                padding:
                                                    const EdgeInsets.all(7),
                                                margin:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 10,
                                                        vertical: 6.0),
                                                decoration: BoxDecoration(
                                                    color: Theme.of(context)
                                                        .primaryColor
                                                        .withOpacity(0.15),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10)),
                                                child: Row(
                                                  children: [
                                                    Container(
                                                      height: 15,
                                                      width: 4,
                                                      decoration: BoxDecoration(
                                                          color: Colors.orange,
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      20)),
                                                    ),
                                                    const SizedBox(
                                                      width: 5,
                                                    ),
                                                    Text(
                                                      getTranslated(
                                                              'new_arrivels',
                                                              context) ??
                                                          'new',
                                                      style: TextStyle(
                                                          fontSize: Dimensions
                                                              .fontSizeLarge,
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    ),
                                                    const Spacer(),
                                                    InkWell(
                                                      onTap: () => Navigator.push(
                                                          context,
                                                          CupertinoPageRoute(
                                                              builder: (_) =>
                                                                  AllProductScreen(
                                                                      productType:
                                                                          ProductType
                                                                              .latestProduct))),
                                                      child: Text(
                                                        getTranslated(
                                                                'VIEW_ALL',
                                                                context) ??
                                                            'view All',
                                                        style: TextStyle(
                                                            color:
                                                                Colors.orange,
                                                            fontSize: Dimensions
                                                                .fontSizeLarge,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                      ),
                                                    ),
                                                  ],
                                                )),
                                            Consumer<ProductController>(
                                              builder: (context, prodProvider,
                                                  child) {
                                                List<Product>? productList =
                                                    prodProvider.lProductList;
                                                var splashController = Provider
                                                    .of<SplashController>(
                                                        context,
                                                        listen: false);
                                                return productList != null
                                                    ? productList.isNotEmpty
                                                        ? Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .only(
                                                                    left: 10,
                                                                    top: 3),
                                                            child: SizedBox(
                                                              height:
                                                                  size.width *
                                                                      0.8,
                                                              width: size.width,
                                                              child: ListView
                                                                  .builder(
                                                                scrollDirection:
                                                                    Axis.horizontal,
                                                                itemCount:
                                                                    productList
                                                                        .length,
                                                                itemBuilder:
                                                                    (BuildContext
                                                                            ctx,
                                                                        i) {
                                                                  String ratting = productList[i].rating !=
                                                                              null &&
                                                                          productList[i]
                                                                              .rating!
                                                                              .isNotEmpty
                                                                      ? productList[
                                                                              i]
                                                                          .rating![
                                                                              0]
                                                                          .average!
                                                                      : '0';
                                                                  return InkWell(
                                                                    onTap: () {
                                                                      Navigator.push(
                                                                          context,
                                                                          PageRouteBuilder(
                                                                            transitionDuration:
                                                                                const Duration(milliseconds: 1000),
                                                                            pageBuilder: (context, anim1, anim2) =>
                                                                                ProductDetails(productId: productList[i].id, slug: productList[i].slug),
                                                                          ));
                                                                    },
                                                                    child:
                                                                        Container(
                                                                      height:
                                                                          size.width *
                                                                              0.8,
                                                                      width: size
                                                                              .width *
                                                                          0.50,
                                                                      margin: const EdgeInsets
                                                                          .only(
                                                                          right:
                                                                              10),
                                                                      decoration:
                                                                          BoxDecoration(
                                                                        border: Border.all(
                                                                            color:
                                                                                Colors.grey.shade300),
                                                                        borderRadius:
                                                                            BorderRadius.circular(10),
                                                                      ),
                                                                      child:
                                                                          Column(
                                                                        mainAxisAlignment:
                                                                            MainAxisAlignment.start,
                                                                        crossAxisAlignment:
                                                                            CrossAxisAlignment.start,
                                                                        children: [
                                                                          Expanded(
                                                                              flex: 2,
                                                                              child: Stack(
                                                                                children: [
                                                                                  ClipRRect(
                                                                                    borderRadius: const BorderRadius.only(
                                                                                      topRight: Radius.circular(10),
                                                                                      topLeft: Radius.circular(10),
                                                                                    ),
                                                                                    child: CachedNetworkImage(
                                                                                      imageUrl: '${splashController.baseUrls!.productThumbnailUrl}/${productList[i].thumbnail}',
                                                                                      fit: BoxFit.cover,
                                                                                      width: double.infinity,
                                                                                      errorWidget: (context, url, error) => const SizedBox(), // no image shown on error
                                                                                    ),
                                                                                  ),
                                                                                  // ClipRRect(
                                                                                  //     borderRadius:
                                                                                  //     const BorderRadius
                                                                                  //         .only(
                                                                                  //       topRight:
                                                                                  //       Radius.circular(
                                                                                  //           10),
                                                                                  //       topLeft: Radius
                                                                                  //           .circular(
                                                                                  //           10),
                                                                                  //     ),
                                                                                  //     child: FadeInImage
                                                                                  //         .assetNetwork(
                                                                                  //       width : double.infinity,
                                                                                  //       fadeInDuration:
                                                                                  //       const Duration(
                                                                                  //           milliseconds: 100),
                                                                                  //       placeholder:
                                                                                  //       'assets/images/mahakal_logo_circle.png',
                                                                                  //       image: '${splashController.baseUrls!.productThumbnailUrl}/${productList[i].thumbnail}',
                                                                                  //       // 'https://astrorobo.com/storage/app/public/product/2023-09-28-6515bca9e9356.png',
                                                                                  //       fit: BoxFit
                                                                                  //           .cover,
                                                                                  //     )),
                                                                                  Positioned(
                                                                                    top: Dimensions.paddingSizeExtraSmall,
                                                                                    right: Dimensions.paddingSizeExtraSmall,
                                                                                    child: Container(
                                                                                      padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
                                                                                      decoration: BoxDecoration(
                                                                                        color: Theme.of(context).cardColor,
                                                                                        borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                                                                                      ),
                                                                                      child: Icon(
                                                                                        Icons.favorite,
                                                                                        size: 15,
                                                                                        color: Theme.of(context).primaryColor,
                                                                                      ),
                                                                                    ),
                                                                                  ),
                                                                                ],
                                                                              )),
                                                                          Expanded(
                                                                            flex:
                                                                                1,
                                                                            child:
                                                                                Padding(
                                                                              padding: const EdgeInsets.only(left: 10),
                                                                              child: Column(
                                                                                mainAxisAlignment: MainAxisAlignment.start,
                                                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                                                children: [
                                                                                  Text(
                                                                                    '${productList[i].name}',
                                                                                    // '7 मुखी रुद्राक्ष',
                                                                                    style: TextStyle(
                                                                                      fontSize: Dimensions.fontSizeSmall,
                                                                                      fontWeight: FontWeight.bold,
                                                                                      overflow: TextOverflow.ellipsis,
                                                                                    ),
                                                                                    maxLines: 3,
                                                                                  ),
                                                                                  // const SizedBox(
                                                                                  //     height: 3),
                                                                                  // SizedBox(
                                                                                  //   width:
                                                                                  //   size.width *
                                                                                  //       0.4,
                                                                                  //   child: Text(
                                                                                  //     'सात मुखी रुद्राक्ष को कामदेव का रूप माना गया है',
                                                                                  //     style: TextStyle(
                                                                                  //         fontSize:
                                                                                  //         Dimensions
                                                                                  //             .fontSizeSmall,
                                                                                  //         fontWeight:
                                                                                  //         FontWeight.w500),
                                                                                  //   ),
                                                                                  // ),
                                                                                  // const SizedBox(
                                                                                  //     height: Dimensions
                                                                                  //         .paddingSizeExtraSmall),
                                                                                  const Spacer(),
                                                                                  Row(
                                                                                    mainAxisAlignment: MainAxisAlignment.start,
                                                                                    children: [
                                                                                      productList[i].discount != null && productList[i].discount! > 0 ? Text(PriceConverter.convertPrice(context, productList[i].unitPrice), style: titleRegular.copyWith(color: ColorResources.hintTextColor, decoration: TextDecoration.lineThrough, fontSize: Dimensions.fontSizeExtraSmall)) : const SizedBox.shrink(),
                                                                                      const SizedBox(
                                                                                        width: 2,
                                                                                      ),
                                                                                      Text(
                                                                                        PriceConverter.convertPrice(context, productList[i].unitPrice, discountType: productList[i].discountType, discount: productList[i].discount),
                                                                                        style: titilliumSemiBold.copyWith(color: ColorResources.getPrimary(context), fontSize: Dimensions.fontSizeDefault, fontWeight: FontWeight.w700),
                                                                                      ),
                                                                                    ],
                                                                                  ),
                                                                                  const SizedBox(height: 3),
                                                                                  Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                                                                                    RatingBar(rating: double.parse(ratting), size: 18),
                                                                                    Text('(${productList[i].reviewCount.toString()})', style: textRegular.copyWith(fontSize: Dimensions.fontSizeSmall))
                                                                                  ]),
                                                                                  const SizedBox(height: Dimensions.paddingSizeExtraSmall),
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
                                                            ))
                                                        : const SizedBox
                                                            .shrink()
                                                    : const LatestProductShimmer();
                                              },
                                            ),

                                            // const SizedBox(height: 120),
                                          ])
                                        : const SizedBox.shrink(),
                                  ],
                                ),

                                // Feature product
                                SectionFeatureProduct(
                                    sectionModelList: sectionModelList,
                                    widget: widget),
                                const SizedBox(
                                  height: 20,
                                ),
                              ],
                            ),
                    ]),
              )
            ],
          ),
        ),
      ),
    );
  }

  void calculatorForm(BuildContext context, int bottomSheetIndex) {
    //Country Picker
    Country selectedCountry = Country(
      phoneCode: '91',
      countryCode: 'IN',
      e164Sc: 0,
      geographic: true,
      level: 1,
      name: 'India',
      example: '9123456789',
      displayName: 'India',
      displayNameNoCountryCode: 'India',
      e164Key: '91-IN-0',
    );

    final List calculatorTitleList = [
      getTranslated('mul_ank', context) ?? 'Mul-Ank',
      getTranslated('rashi_namakshar', context) ?? 'Rashi Namakshar',
      getTranslated('kalsarp_dosh', context) ?? 'Kalsarp Dosh',
      getTranslated('manglik_dosh', context) ?? 'Manglik Dosh',
      getTranslated('pitra_dosh', context) ?? 'Pitra Dosh',
      getTranslated('vimshotri_dasha', context) ?? 'Vimshotri Dasha',
      getTranslated('ratna_sujhaw', context) ?? 'Ratna Sujhaw',
      getTranslated('rudraksh_sujhaw', context) ?? 'Rudraksh Sujhaw',
      getTranslated('pooja_sujhaw', context) ?? 'Pooja Sujhaw'
    ];

    //Serach box
    bool searchbox = false;

    void searchBox(StateSetter modalSetter) {
      if (countryController.text.length > 1) {
        modalSetter(() {
          searchbox = true;
        });
      } else if (countryController.text.isEmpty) {
        modalSetter(() {
          searchbox = false;
        });
      }
      print('serchbox $searchbox');
    }

    // country picker api
    void getCityPick(StateSetter modalSetter) async {
      print('object');
      cityListModel.clear();
      var response = await http.post(
        Uri.parse('https://geo.vedicrishi.in/places/'),
        body: {
          'country': selectedCountry.name,
          'name': countryController.text,
        },
      );
      if (response.statusCode == 200) {
        modalSetter(() {
          var result = json.decode(response.body);
          print('Api response $result');
          List listLocation = result;
          cityListModel
              .addAll(listLocation.map((e) => CityPickerModel.fromJson(e)));
        });
      } else {
        print('Failed Api Rresponse');
      }
    }

    // button functionality
    void submitForm(StateSetter modalSetter) {
      if (bottomSheetIndex == 1) {
        getRashiNamak(modalSetter);
      } else if (bottomSheetIndex == 2) {
        getKaalsarp(modalSetter);
      } else if (bottomSheetIndex == 3) {
        getManglikDosh(modalSetter);
      } else if (bottomSheetIndex == 4) {
        getPitrDosh(modalSetter);
      } else if (bottomSheetIndex == 5) {
        getVimshottari(modalSetter);
      } else if (bottomSheetIndex == 0) {
        calculateMulank(modalSetter, _dateController.text);
      } else if (bottomSheetIndex == 6) {
        getGemsSuggestion(modalSetter);
      } else if (bottomSheetIndex == 7) {
        getRudraksh(modalSetter);
      } else if (bottomSheetIndex == 8) {
        getPooja(modalSetter);
      }
    }

    final List<String> genderOptions = ['Gender', 'Male', 'Female', 'Others'];

    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (context) {
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter modalSetter) {
            return Container(
              padding: const EdgeInsets.all(10),
              margin: const EdgeInsets.all(10),
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.only(
                      bottom: MediaQuery.of(context).viewInsets.bottom),
                  child: isLoading
                      ? Center(
                          child: CircularProgressIndicator(
                            color: Theme.of(context).primaryColor,
                            strokeWidth: 3,
                          ),
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.document_scanner_outlined,
                                  color: Colors.orange,
                                ),
                                const SizedBox(
                                  width: 8.0,
                                ),
                                Text(
                                  '${calculatorTitleList[bottomSheetIndex]}',
                                  style: const TextStyle(
                                      fontSize: 20,
                                      color: Colors.orange,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.5),
                                ),
                              ],
                            ),
                            const SizedBox(
                              height: 10.0,
                            ),
                            // name
                            TextField(
                              cursorColor: Theme.of(context).primaryColor,
                              controller: _nameController,
                              style:
                                  const TextStyle(fontFamily: 'Roboto-Regular'),
                              decoration: InputDecoration(
                                hintText: 'Name',
                                contentPadding: const EdgeInsets.symmetric(
                                    vertical: 10.0, horizontal: 10.0),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(
                                      color: Theme.of(context).primaryColor,
                                      width: 1),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(
                                      color: Theme.of(context).primaryColor,
                                      width: 1),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(
                                      color: Theme.of(context).primaryColor,
                                      width: 1),
                                ),
                                suffixIcon: const Icon(Icons.person_outline,
                                    color: Colors.grey, size: 25),
                              ),
                            ),
                            const SizedBox(height: 8.0),
                            //Gender
                            const Text(
                              'Gender',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Radio(
                                  materialTapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                  activeColor: Colors.orange,
                                  value: 1,
                                  groupValue: _maleValue,
                                  onChanged: (value) {
                                    modalSetter(() {
                                      _maleValue = value as int;
                                    });
                                  },
                                ),
                                const Row(
                                  children: [
                                    Text('Male'),
                                    Icon(
                                      Icons.male,
                                      size: 15,
                                    )
                                  ],
                                ),
                                Radio(
                                  materialTapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                  value: 2,
                                  activeColor: Colors.orange,
                                  groupValue: _maleValue,
                                  onChanged: (value) {
                                    modalSetter(() {
                                      _maleValue = value as int;
                                    });
                                  },
                                ),
                                const Row(
                                  children: [
                                    Text('Female'),
                                    Icon(
                                      Icons.female,
                                      size: 15,
                                    )
                                  ],
                                ),
                                Radio(
                                  materialTapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                  value: 3,
                                  activeColor: Colors.orange,
                                  groupValue: _maleValue,
                                  onChanged: (value) {
                                    modalSetter(() {
                                      _maleValue = value as int;
                                    });
                                  },
                                ),
                                const Row(
                                  children: [
                                    Text('Others'),
                                    Icon(
                                      Icons.person_2_outlined,
                                      size: 15,
                                    )
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(
                              height: 8,
                            ),

                            Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                    color: Theme.of(context).primaryColor),
                              ),
                              child: TextButton(
                                onPressed: () async {
                                  DateTime? pickedDate = await showDatePicker(
                                    context: context,
                                    initialDate: DateTime.now(),
                                    firstDate: DateTime(1901),
                                    lastDate: DateTime.now(),
                                    builder:
                                        (BuildContext context, Widget? child) {
                                      return Theme(
                                        data: ThemeData.light().copyWith(
                                          colorScheme: ColorScheme.light(
                                            primary: Colors.white,
                                            onPrimary:
                                                Theme.of(context).primaryColor,
                                            surface: const Color(0xFFFFF7EC),
                                            onSurface:
                                                Theme.of(context).primaryColor,
                                          ),
                                          textButtonTheme: TextButtonThemeData(
                                            style: TextButton.styleFrom(
                                              foregroundColor: Theme.of(context)
                                                  .primaryColor,
                                              backgroundColor: Colors.white,
                                            ),
                                          ),
                                          dialogTheme: const DialogThemeData(
                                              backgroundColor:
                                                  Color(0xFFFFF7EC)),
                                        ),
                                        child: child!,
                                      );
                                    },
                                  );
                                  if (pickedDate != null) {
                                    modalSetter(() {
                                      _dateController.text =
                                          DateFormat('dd/MM/yyyy')
                                              .format(pickedDate);
                                    });
                                  }
                                },
                                style: TextButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10.0),
                                  alignment: Alignment.centerLeft,
                                  backgroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    _dateController.text.isEmpty
                                        ? const Text(
                                            'Select DOB',
                                            style: TextStyle(
                                              fontSize: 16,
                                              color: Colors.grey,
                                            ),
                                          )
                                        : Text(
                                            _dateController.text,
                                            style: const TextStyle(
                                              fontSize: 16,
                                              color: Colors.black,
                                            ),
                                          ),
                                    const Icon(Icons.calendar_month_outlined,
                                        color: Colors.grey, size: 25),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 8.0),

                            // Birth Timing
                            Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                    color: Theme.of(context).primaryColor),
                              ),
                              child: TextButton(
                                onPressed: () async {
                                  TimeOfDay? pickedTime = await showTimePicker(
                                    initialTime: TimeOfDay.now(),
                                    context: context,
                                    builder:
                                        (BuildContext context, Widget? child) {
                                      return Theme(
                                        data: ThemeData.light().copyWith(
                                          timePickerTheme: TimePickerThemeData(
                                            dialHandColor: Colors.black12,
                                            dialTextStyle: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                            dialTextColor:
                                                Theme.of(context).primaryColor,
                                            dialBackgroundColor: Colors.white,
                                            dayPeriodColor: Colors.white,
                                            dayPeriodTextColor:
                                                Theme.of(context).primaryColor,
                                            backgroundColor:
                                                const Color(0xFFFFF7EC),
                                            hourMinuteTextColor:
                                                Theme.of(context).primaryColor,
                                            hourMinuteColor: Colors.white,
                                            inputDecorationTheme:
                                                InputDecorationTheme(
                                              border: InputBorder.none,
                                              filled: true,
                                              fillColor: Colors.white,
                                              hintStyle: TextStyle(
                                                  color: Theme.of(context)
                                                      .primaryColor),
                                              labelStyle: TextStyle(
                                                  color: Theme.of(context)
                                                      .primaryColor),
                                            ),
                                          ),
                                          textButtonTheme: TextButtonThemeData(
                                            style: TextButton.styleFrom(
                                              foregroundColor: Theme.of(context)
                                                  .primaryColor,
                                              backgroundColor: Colors.white,
                                              shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10)),
                                            ),
                                          ),
                                          dialogTheme: const DialogThemeData(
                                              backgroundColor: Colors.white),
                                        ),
                                        child: child!,
                                      );
                                    },
                                  );
                                  if (pickedTime != null) {
                                    modalSetter(() {
                                      birthHour = pickedTime.hour.toString();
                                      birthMinute =
                                          pickedTime.minute.toString();
                                      _timeController.text =
                                          pickedTime.format(context);
                                    });
                                  }
                                },
                                style: TextButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10.0),
                                  alignment: Alignment.centerLeft,
                                  backgroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    _timeController.text.isEmpty
                                        ? const Text(
                                            'Select Time',
                                            style: TextStyle(
                                              fontSize: 16,
                                              color: Colors.grey,
                                            ),
                                          )
                                        : Text(
                                            _timeController.text,
                                            style: const TextStyle(
                                              fontSize: 16,
                                              color: Colors.black,
                                            ),
                                          ),
                                    const Icon(Icons.timelapse_outlined,
                                        color: Colors.grey, size: 25),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 8.0),

                            Row(
                              children: [
                                // location
                                Expanded(
                                  flex: 1,
                                  child: InkWell(
                                    onTap: () {
                                      showCountryPicker(
                                        context: context,
                                        showPhoneCode: false,
                                        onSelect: (Country country) {
                                          modalSetter(() {
                                            selectedCountry = country;
                                          });
                                        },
                                      );
                                    },
                                    child: Container(
                                      height: 50,
                                      margin: const EdgeInsets.only(top: 2),
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                            color:
                                                Theme.of(context).primaryColor),
                                      ),
                                      child: Center(
                                        child: Text(
                                          selectedCountry.flagEmoji,
                                          style: const TextStyle(fontSize: 20),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),

                                const SizedBox(
                                  width: 6.0,
                                ),
                                // country
                                Expanded(
                                  flex: 3,
                                  child: TextFormField(
                                    controller: countryController,
                                    onChanged: (value) {
                                      getCityPick(modalSetter);
                                      searchBox(modalSetter);
                                    },
                                    decoration: InputDecoration(
                                      hintText: 'Search City',
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              vertical: 10.0, horizontal: 10.0),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: BorderSide(
                                            color:
                                                Theme.of(context).primaryColor,
                                            width: 1),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: BorderSide(
                                            color:
                                                Theme.of(context).primaryColor,
                                            width: 1),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: BorderSide(
                                            color:
                                                Theme.of(context).primaryColor,
                                            width: 1),
                                      ),
                                      suffixIcon: const Icon(Icons.location_pin,
                                          color: Colors.grey, size: 25),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(
                              height: 3,
                            ),
                            //location box
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 600),
                              curve: Curves.easeInCirc,
                              padding: const EdgeInsets.all(8.0),
                              height: searchbox == false ? 0 : 160,
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  border: Border.all(
                                      color: Theme.of(context).primaryColor),
                                  borderRadius: BorderRadius.circular(6.0)),
                              child: ListView.builder(
                                shrinkWrap: true,
                                physics: const BouncingScrollPhysics(),
                                itemCount: cityListModel.length,
                                itemBuilder: (BuildContext context, int index) {
                                  return SingleChildScrollView(
                                    child: InkWell(
                                      onTap: () {
                                        modalSetter(() {
                                          countryController.text =
                                              cityListModel[index]
                                                  .place
                                                  .toString();
                                          searchbox = false;
                                        });
                                      },
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              const Icon(Icons.location_pin,
                                                  size: 20,
                                                  color: Colors.black54),
                                              const SizedBox(
                                                width: 5,
                                              ),
                                              SizedBox(
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width /
                                                    1.3,
                                                child: Text(
                                                  cityListModel[index].place,
                                                  style: const TextStyle(
                                                      color: Colors.black,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      fontSize: 16),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const Divider(
                                            color: Colors.grey,
                                          )
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            // button
                            ElevatedButton(
                              onPressed: () {
                                if (_nameController.text.isEmpty ||
                                    _dateController.text.isEmpty ||
                                    countryController.text.isEmpty ||
                                    _timeController.text.isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: const Text(
                                          'Incorrect Form Details',
                                          style: TextStyle(fontSize: 20)),
                                      backgroundColor: Colors.red,
                                      dismissDirection: DismissDirection.up,
                                      behavior: SnackBarBehavior.floating,
                                      margin: EdgeInsets.only(
                                          bottom: MediaQuery.of(context)
                                                  .size
                                                  .height -
                                              150,
                                          left: 10,
                                          right: 10),
                                    ),
                                  );
                                } else {
                                  submitForm(modalSetter);
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                foregroundColor: Colors.white,
                                backgroundColor: Colors.black,
                                minimumSize: const Size(double.infinity, 50),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: const Text(
                                'Continue',
                                style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.28),
                              ),
                            ),
                            const SizedBox(
                              height: 20.0,
                            ),
                          ],
                        ),
                ),
              ),
            );
          });
        });
  }

  void janmJankariForm(BuildContext context, int bottomSheetIndex) {
    //Country Picker
    Country selectedCountry = Country(
      phoneCode: '91',
      countryCode: 'IN',
      e164Sc: 0,
      geographic: true,
      level: 1,
      name: 'India',
      example: '9123456789',
      displayName: 'India',
      displayNameNoCountryCode: 'India',
      e164Key: '91-IN-0',
    );

    final List calculatorTitleList = [
      'Anukul Mantra',
      'Shubh Vrat',
      'Anukul Time',
      'Anukul Dev',
    ];

    //Serach box
    bool searchbox = false;

    void searchBox(StateSetter modalSetter) {
      if (countryController.text.length > 1) {
        modalSetter(() {
          searchbox = true;
        });
      } else if (countryController.text.isEmpty) {
        modalSetter(() {
          searchbox = false;
        });
      }
      print('serchbox $searchbox');
    }

    // country picker api
    void getCityPick(StateSetter modalSetter) async {
      print('object');
      cityListModel.clear();
      var response = await http.post(
        Uri.parse('https://geo.vedicrishi.in/places/'),
        body: {
          'country': selectedCountry.name,
          'name': countryController.text,
        },
      );
      if (response.statusCode == 200) {
        modalSetter(() {
          var result = json.decode(response.body);
          print('Api response $result');
          List listLocation = result;
          cityListModel
              .addAll(listLocation.map((e) => CityPickerModel.fromJson(e)));
        });
      } else {
        print('Failed Api Rresponse');
      }
    }

    void submitForm(StateSetter modalSetter) {
      switch (bottomSheetIndex) {
        case 0:
          getAnukulMantra(modalSetter);
          break;
        case 1:
          getShubhVrat(modalSetter);
          break;
        case 2:
          getAnukulTime(modalSetter);
          break;
        case 3:
          getAnukulDev(modalSetter);
          break;
      }
    }

    final List<String> genderOptions = ['Male', 'Female', 'Others'];

    // button functionality
    // void submitForm(StateSetter modalSetter) {
    //   if (dialogIndex == 0) {
    //     getAnukulMantra(modalSetter);
    //   } else if (dialogIndex == 1) {
    //     print("shubhVrat");
    //     shubhVrat();
    //   } else if (dialogIndex == 2) {
    //     shubhVrat();
    //   } else if (dialogIndex == 3) {
    //     getAnukulDev(modalSetter);
    //   }
    // }

    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (context) {
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter modalSetter) {
            return Container(
              padding: const EdgeInsets.all(10),
              margin: const EdgeInsets.all(10),
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.only(
                      bottom: MediaQuery.of(context).viewInsets.bottom),
                  child: isLoading
                      ? Center(
                          child: CircularProgressIndicator(
                            color: Theme.of(context).primaryColor,
                            strokeWidth: 3,
                          ),
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.document_scanner_outlined,
                                  color: Colors.orange,
                                ),
                                const SizedBox(
                                  width: 8.0,
                                ),
                                Text(
                                  '${calculatorTitleList[bottomSheetIndex]}',
                                  style: const TextStyle(
                                      fontSize: 20,
                                      color: Colors.orange,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.5),
                                ),
                              ],
                            ),
                            const SizedBox(
                              height: 10.0,
                            ),
                            // name
                            TextField(
                              cursorColor: Theme.of(context).primaryColor,
                              controller: _nameController,
                              style:
                                  const TextStyle(fontFamily: 'Roboto-Regular'),
                              decoration: InputDecoration(
                                hintText: 'Name',
                                contentPadding: const EdgeInsets.symmetric(
                                    vertical: 10.0, horizontal: 10.0),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(
                                      color: Theme.of(context).primaryColor,
                                      width: 1),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(
                                      color: Theme.of(context).primaryColor,
                                      width: 1),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(
                                      color: Theme.of(context).primaryColor,
                                      width: 1),
                                ),
                                suffixIcon: const Icon(Icons.person_outline,
                                    color: Colors.grey, size: 25),
                              ),
                            ),
                            const SizedBox(height: 8.0),
                            //Gender
                            // Container(
                            //   padding:
                            //   const EdgeInsets.symmetric(horizontal: 10.0),
                            //   margin: const EdgeInsets.only(top: 2, bottom: 10),
                            //   width: double.infinity,
                            //   decoration: BoxDecoration(
                            //     color: Colors.white,
                            //     borderRadius: BorderRadius.circular(8),
                            //     border: Border.all(
                            //         color: Theme.of(context).primaryColor),
                            //   ),
                            //   child: DropdownButtonHideUnderline(
                            //     child: DropdownButton<String>(
                            //       value: selectedGender,
                            //       hint: Text('Select Gender'),
                            //       items: genderOptions.map((String value) {
                            //         return DropdownMenuItem<String>(
                            //           value: value,
                            //           child: Text(value),
                            //         );
                            //       }).toList(),
                            //       onChanged: (String? newValue) {
                            //         modalSetter(() {
                            //           selectedGender = newValue!;
                            //         });
                            //       },
                            //     ),
                            //   ),
                            // ),
                            const Text(
                              'Gender',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Radio(
                                  materialTapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                  activeColor: Colors.orange,
                                  value: 1,
                                  // Value assigned to "Male"
                                  groupValue: _maleValue,
                                  onChanged: (value) {
                                    modalSetter(() {
                                      _maleValue = value
                                          as int; // Cast as int for safety
                                    });
                                  },
                                ),
                                const Row(
                                  children: [
                                    Text('Male'),
                                    Icon(
                                      Icons.male,
                                      size: 15,
                                    )
                                  ],
                                ),
                                Radio(
                                  materialTapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                  value: 2,
                                  // Value assigned to "Female"
                                  activeColor: Colors.orange,
                                  groupValue: _maleValue,
                                  onChanged: (value) {
                                    modalSetter(() {
                                      _maleValue = value
                                          as int; // Cast as int for safety
                                    });
                                  },
                                ),
                                const Row(
                                  children: [
                                    Text('Female'),
                                    Icon(
                                      Icons.female,
                                      size: 15,
                                    )
                                  ],
                                ),
                                Radio(
                                  materialTapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                  value: 3,
                                  // Value assigned to "Female"
                                  activeColor: Colors.orange,
                                  groupValue: _maleValue,
                                  onChanged: (value) {
                                    modalSetter(() {
                                      _maleValue = value
                                          as int; // Cast as int for safety
                                    });
                                  },
                                ),
                                const Row(
                                  children: [
                                    Text('Others'),
                                    Icon(
                                      Icons.person_2_outlined,
                                      size: 15,
                                    )
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(
                              height: 8,
                            ),

                            // Birth Date
                            Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                    color: Theme.of(context).primaryColor),
                              ),
                              child: TextButton(
                                onPressed: () async {
                                  DateTime? pickedDate = await showDatePicker(
                                    context: context,
                                    initialDate: DateTime.now(),
                                    firstDate: DateTime(1901),
                                    lastDate: DateTime(2101),
                                    builder:
                                        (BuildContext context, Widget? child) {
                                      return Theme(
                                        data: ThemeData.light().copyWith(
                                          colorScheme: ColorScheme.light(
                                            primary: Colors.white,
                                            onPrimary:
                                                Theme.of(context).primaryColor,
                                            surface: const Color(0xFFFFF7EC),
                                            onSurface:
                                                Theme.of(context).primaryColor,
                                          ),
                                          textButtonTheme: TextButtonThemeData(
                                            style: TextButton.styleFrom(
                                              foregroundColor: Theme.of(context)
                                                  .primaryColor,
                                              backgroundColor: Colors.white,
                                            ),
                                          ),
                                          dialogTheme: const DialogThemeData(
                                              backgroundColor:
                                                  Color(0xFFFFF7EC)),
                                        ),
                                        child: child!,
                                      );
                                    },
                                  );
                                  if (pickedDate != null) {
                                    modalSetter(() {
                                      _dateController.text =
                                          DateFormat('dd/MM/yyyy')
                                              .format(pickedDate);
                                    });
                                  }
                                },
                                style: TextButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10.0),
                                  alignment: Alignment.centerLeft,
                                  backgroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    _dateController.text.isEmpty
                                        ? const Text(
                                            'Select Date',
                                            style: TextStyle(
                                              fontSize: 16,
                                              color: Colors.grey,
                                            ),
                                          )
                                        : Text(
                                            _dateController.text,
                                            style: const TextStyle(
                                              fontSize: 16,
                                              color: Colors.black,
                                            ),
                                          ),
                                    const Icon(Icons.calendar_month_outlined,
                                        color: Colors.grey, size: 25),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 8.0),

                            // Birth Timing
                            Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                    color: Theme.of(context).primaryColor),
                              ),
                              child: TextButton(
                                onPressed: () async {
                                  TimeOfDay? pickedTime = await showTimePicker(
                                    initialTime: TimeOfDay.now(),
                                    context: context,
                                    builder:
                                        (BuildContext context, Widget? child) {
                                      return Theme(
                                        data: ThemeData.light().copyWith(
                                          timePickerTheme: TimePickerThemeData(
                                            dialHandColor: Colors.black12,
                                            dialTextStyle: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                            dialTextColor:
                                                Theme.of(context).primaryColor,
                                            dialBackgroundColor: Colors.white,
                                            dayPeriodColor: Colors.white,
                                            dayPeriodTextColor:
                                                Theme.of(context).primaryColor,
                                            backgroundColor:
                                                const Color(0xFFFFF7EC),
                                            hourMinuteTextColor:
                                                Theme.of(context).primaryColor,
                                            hourMinuteColor: Colors.white,
                                            inputDecorationTheme:
                                                InputDecorationTheme(
                                              border: InputBorder.none,
                                              filled: true,
                                              fillColor: Colors.white,
                                              hintStyle: TextStyle(
                                                  color: Theme.of(context)
                                                      .primaryColor),
                                              labelStyle: TextStyle(
                                                  color: Theme.of(context)
                                                      .primaryColor),
                                            ),
                                          ),
                                          textButtonTheme: TextButtonThemeData(
                                            style: TextButton.styleFrom(
                                              foregroundColor: Theme.of(context)
                                                  .primaryColor,
                                              backgroundColor: Colors.white,
                                              shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10)),
                                            ),
                                          ),
                                          dialogTheme: const DialogThemeData(
                                              backgroundColor: Colors.white),
                                        ),
                                        child: child!,
                                      );
                                    },
                                  );
                                  if (pickedTime != null) {
                                    modalSetter(() {
                                      print(pickedTime);
                                      birthHour = pickedTime.hour.toString();
                                      birthMinute =
                                          pickedTime.minute.toString();
                                      _timeController.text =
                                          pickedTime.format(context);
                                    });
                                  }
                                },
                                style: TextButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10.0),
                                  alignment: Alignment.centerLeft,
                                  backgroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    _timeController.text.isEmpty
                                        ? const Text(
                                            'Select Time',
                                            style: TextStyle(
                                              fontSize: 16,
                                              color: Colors.grey,
                                            ),
                                          )
                                        : Text(
                                            _timeController.text,
                                            style: const TextStyle(
                                              fontSize: 16,
                                              color: Colors.black,
                                            ),
                                          ),
                                    const Icon(Icons.timelapse_outlined,
                                        color: Colors.grey, size: 25),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 8.0),

                            // country city
                            Row(
                              children: [
                                // location
                                Expanded(
                                  flex: 1,
                                  child: InkWell(
                                    onTap: () {
                                      showCountryPicker(
                                        context: context,
                                        showPhoneCode: false,
                                        // optional. Shows phone code before the country name.
                                        onSelect: (Country country) {
                                          modalSetter(() {
                                            selectedCountry = country;
                                          });
                                        },
                                      );
                                    },
                                    child: Container(
                                      height: 50,
                                      margin: const EdgeInsets.only(top: 2),
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                            color:
                                                Theme.of(context).primaryColor),
                                      ),
                                      child: Center(
                                        child: Text(
                                          selectedCountry.flagEmoji,
                                          style: const TextStyle(fontSize: 20),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),

                                const SizedBox(
                                  width: 6.0,
                                ),
                                // country
                                Expanded(
                                  flex: 3,
                                  child: TextFormField(
                                    controller: countryController,
                                    onChanged: (value) {
                                      getCityPick(modalSetter);
                                      searchBox(modalSetter);
                                    },
                                    decoration: InputDecoration(
                                      hintText: 'Search City',
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              vertical: 10.0, horizontal: 10.0),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: BorderSide(
                                            color:
                                                Theme.of(context).primaryColor,
                                            width: 1),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: BorderSide(
                                            color:
                                                Theme.of(context).primaryColor,
                                            width: 1),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: BorderSide(
                                            color:
                                                Theme.of(context).primaryColor,
                                            width: 1),
                                      ),
                                      suffixIcon: const Icon(Icons.location_pin,
                                          color: Colors.grey, size: 25),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(
                              height: 3,
                            ),
                            //location box
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 600),
                              // Adjust animation duration for smooth transition
                              curve: Curves.easeInCirc,
                              // Customize animation curve if needed
                              padding: const EdgeInsets.all(8.0),
                              height: searchbox == false ? 0 : 160,
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  border: Border.all(
                                      color: Theme.of(context).primaryColor),
                                  borderRadius: BorderRadius.circular(6.0)),
                              child: ListView.builder(
                                shrinkWrap: true,
                                physics: const BouncingScrollPhysics(),
                                itemCount: cityListModel
                                    .length, // Number of items in the list
                                itemBuilder: (BuildContext context, int index) {
                                  // itemBuilder function returns a widget for each item in the list
                                  return SingleChildScrollView(
                                    child: InkWell(
                                      onTap: () {
                                        modalSetter(() {
                                          calculatorLong = cityListModel[index]
                                              .latitude
                                              .toString();
                                          calculatorLat = cityListModel[index]
                                              .longitude
                                              .toString();
                                          countryController.text =
                                              cityListModel[index]
                                                  .place
                                                  .toString();
                                          searchbox = false;
                                        });
                                      },
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              const Icon(Icons.location_pin,
                                                  size: 20,
                                                  color: Colors.black54),
                                              const SizedBox(
                                                width: 5,
                                              ),
                                              SizedBox(
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width /
                                                    1.3,
                                                child: Text(
                                                  cityListModel[index].place,
                                                  style: const TextStyle(
                                                      color: Colors.black,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      fontSize: 16),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const Divider(
                                            color: Colors.grey,
                                          )
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            // button
                            ElevatedButton(
                              onPressed: () {
                                if (_nameController.text.isEmpty ||
                                    _dateController.text.isEmpty ||
                                    countryController.text.isEmpty ||
                                    _timeController.text.isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: const Text(
                                          'Incorrect Form Details',
                                          style: TextStyle(fontSize: 20)),
                                      // Text
                                      backgroundColor: Colors.red,
                                      dismissDirection: DismissDirection.up,
                                      behavior: SnackBarBehavior.floating,
                                      margin: EdgeInsets.only(
                                          bottom: MediaQuery.of(context)
                                                  .size
                                                  .height -
                                              150,
                                          left: 10,
                                          right: 10), // EdgeInsets.only
                                    ),
                                  );
                                } else {
                                  submitForm(modalSetter);
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                foregroundColor: Colors.white,
                                backgroundColor: Colors.black,
                                minimumSize: const Size(double.infinity, 50),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: const Text(
                                'Continue',
                                style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.28),
                              ),
                            ),
                            const SizedBox(
                              height: 20.0,
                            ),
                          ],
                        ),
                ),
              ),
            );
          });
        });
  }

  Widget shimmerScreenChadhava() {
    return SizedBox(
      height: 205,
      child: ListView.builder(
        padding: const EdgeInsets.only(left: 10),
        physics: const BouncingScrollPhysics(),
        itemCount: 5,
        shrinkWrap: true,
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) {
          return Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            enabled: true,
            child: Container(
              margin: const EdgeInsets.only(right: 10, bottom: 10),
              width: 140,
              decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.grey, width: 1.5),
                  borderRadius: BorderRadius.circular(8.0)),
              child: const Padding(
                padding: EdgeInsets.all(4.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class CategroyWidgetExplore extends StatelessWidget {
  const CategroyWidgetExplore(
      {super.key,
      required this.image,
      required this.name,
      required this.color,
      required this.onTap});

  final String image;
  final String name;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            image,
            height: 38,
            width: 38,
          ),
          const SizedBox(height: 3),
          Center(
              child: Text(
            name,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: titleHeader.copyWith(
                color: color,
                fontSize: 12,
                letterSpacing: 0.5,
                fontWeight: FontWeight.w600),
          )),
        ],
      ),
    );
  }
}

class AllCategroyWidgetExplore extends StatelessWidget {
  const AllCategroyWidgetExplore({
    super.key,
    required this.image,
    required this.name,
    required this.color,
  });

  final String image;
  final String name;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Expanded(
            child: Image.asset(
              image,
              height: 35,
              width: 35,
            ),
          ),
          const SizedBox(height: 5),
          Expanded(
            child: Text(
              name,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: titleHeader.copyWith(
                  color: color,
                  fontSize: Dimensions.fontSizeSmall,
                  letterSpacing: 0.5,
                  fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

class CalculatorSection extends StatelessWidget {
  final List<Rashi> calculatorList;
  final List<Sectionlist> sectionModelList;
  final Function(BuildContext context, int index) calculatorForm;
  final int dialogIndex;
  final Size size;

  const CalculatorSection({
    super.key,
    required this.calculatorList,
    required this.sectionModelList,
    required this.calculatorForm,
    required this.dialogIndex,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        sectionModelList[4].section.status == 'true'
            ? Column(
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(7),
                    margin: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        Container(
                          height: 15,
                          width: 4,
                          decoration: BoxDecoration(
                            color: Colors.orange,
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          getTranslated('calculator', context) ?? 'Calculator',
                          style: TextStyle(
                            fontSize: Dimensions.fontSizeLarge,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 15),
                  SizedBox(
                    height: size.width * 0.3,
                    child: ListView.builder(
                      padding: EdgeInsets.zero,
                      scrollDirection: Axis.horizontal,
                      itemCount: calculatorList.length,
                      shrinkWrap: true,
                      itemBuilder: (BuildContext context, int index) {
                        return InkWell(
                          splashColor: Colors.transparent,
                          highlightColor: Colors.transparent,
                          onTap: () {
                            calculatorForm(context, index);
                          },
                          child: Column(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(3),
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 8),
                                height: size.width / 5.9,
                                width: size.width / 5.9,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Theme.of(context).primaryColor,
                                  ),
                                  borderRadius: BorderRadius.circular(7),
                                ),
                                child: Image.asset(calculatorList[index].image),
                              ),
                              const SizedBox(
                                height: Dimensions.paddingSizeExtraExtraSmall,
                              ),
                              Center(
                                child: SizedBox(
                                  width: size.width / 6.5,
                                  child: Text(
                                    calculatorList[index].name,
                                    textAlign: TextAlign.center,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: textRegular.copyWith(
                                      letterSpacing: 0.7,
                                      fontSize: Dimensions.fontSizeSmall,
                                      color:
                                          ColorResources.getTextTitle(context),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              )
            : const SizedBox.shrink(),
      ],
    );
  }
}

class CategoryItem {
  final String image;
  final String name;
  final Widget page;
  final bool isLottie;
  final String? lottiePath;
  final double? lottieSize;
  final bool isComingSoon;
  final String? comingSoonImage;

  CategoryItem({
    required this.image,
    required this.name,
    required this.page,
    this.isLottie = false,
    this.lottiePath,
    this.lottieSize,
    this.isComingSoon = false,
    this.comingSoonImage,
  });
}
