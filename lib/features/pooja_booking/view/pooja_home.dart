import 'dart:convert';
import 'package:delayed_display/delayed_display.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mahakal/data/datasource/remote/http/httpClient.dart';
import 'package:mahakal/features/pooja_booking/model/categorymodel.dart';
import 'package:mahakal/features/pooja_booking/view/silvertabbar.dart';
import 'package:mahakal/utill/app_constants.dart';
import 'package:intl/intl.dart';
import 'package:page_animation_transition/animations/right_to_left_transition.dart';
import 'package:page_animation_transition/page_animation_transition.dart';
import 'package:http/http.dart' as http;
import 'package:shimmer/shimmer.dart';
import 'package:tdk_bouncingwidget/tdk_bouncingwidget.dart';
import '../../../utill/loading_datawidget.dart';
import '../model/all_pooja_model.dart';
import '../model/chadhavadetail_model.dart';
import '../model/homepage_model.dart';
import 'anushthandetail.dart';
import 'chadhavadetails.dart';
import 'component/anushthanview.dart';
import 'component/chadhavaview.dart';
import 'component/poojasearch_screen.dart';
import 'component/vippooja.dart';
import 'vipdetails.dart';

class PoojaHomeView extends StatefulWidget {
  int tabIndex;
  final ScrollController scrollController;
  PoojaHomeView(
      {super.key, required this.tabIndex, required this.scrollController});

  @override
  State<PoojaHomeView> createState() => _HomePageState();
}

class _HomePageState extends State<PoojaHomeView> {
  bool isGridView = true;
  List<GetPoojaCategory> categoryModelList = <GetPoojaCategory>[];
  // List<Subcategory> allNivaranModelList = <Subcategory>[];
  List<Subcategory> vipPoojaModelList = <Subcategory>[];
  List<Subcategory> anushthanModelList = <Subcategory>[];
  List<Chadhavadetail> chadhavaModelList = <Chadhavadetail>[];
  List<Pooja> poojaModelList = <Pooja>[];
  List<Anushthan> allAnushthanModelList = <Anushthan>[];
  List<Anushthan> allvipModelList = <Anushthan>[];
  List<Chadhava> allChadhavaModelList = <Chadhava>[];
  List<Map<String, dynamic>> combinedList = [];

  // List<Service> allSubcategoryData = <Service>[];

  // late TabController _tabController;
  bool gridList = false;
  String translateEn = 'hi';

  final List<String> tabsImage = [
    "assets/testImage/pooja/Samasya nivaran pooja icon.png",
    "assets/testImage/pooja/Dosh nivaran puja icon.png",
    "assets/testImage/pooja/Mantra icon.png",
    "assets/testImage/pooja/Special puja.png",
  ];

  Future<void> getCategoryTab() async {
    try {
      final response =
          await HttpService().getApi(AppConstants.poojaCategoryUrl);

      if (response["status"] == 200 && response["data"] is List) {
        final excludedIds = {50, 51, 52};
        final filteredCategories = (response["data"] as List)
            .map((e) => GetPoojaCategory.fromJson(e))
            .where((category) => !excludedIds.contains(category.id))
            .toList();

        categoryModelList
          ..clear()
          ..addAll(filteredCategories);

        if (mounted) setState(() {});
      } else {
        debugPrint("Invalid response format or status: ${response["status"]}");
      }
    } catch (e) {
      debugPrint("Error fetching category tab: $e");
    }
  }

  Future<void> getAllNivaran() async {
    print("Fetching all Nivaran data...");
    try {
      final res = await HttpService().getApi(AppConstants.poojaAllUrl);

      if (res["status"] == 200) {
        poojaModelList.clear();
        allAnushthanModelList.clear();
        allvipModelList.clear();
        allChadhavaModelList.clear();
        combinedList.clear();

        final List<dynamic> allNivaranRaw = res["pooja"] ?? [];
        final List<dynamic> vipRaw = res["vip_pooja"] ?? [];
        final List<dynamic> anushthanRaw = res["anushthan"] ?? [];
        final List<dynamic> chadhavaRaw = res["chadhava"] ?? [];

        poojaModelList
            .addAll(allNivaranRaw.map((e) => Pooja.fromJson(e)).toList());
        allAnushthanModelList
            .addAll(anushthanRaw.map((e) => Anushthan.fromJson(e)).toList());
        allvipModelList
            .addAll(vipRaw.map((e) => Anushthan.fromJson(e)).toList());
        allChadhavaModelList
            .addAll(chadhavaRaw.map((e) => Chadhava.fromJson(e)).toList());

        combinedList.addAll([
          ...poojaModelList.map((e) => {
                "enName": e.enName,
                "hiName": e.hiName,
                "enHeadline": e.enPoojaHeading,
                "hiHeadline": e.hiPoojaHeading,
                "enDetails": e.enShortBenifits,
                "hiDetails": e.hiShortBenifits,
                "enVenue": e.enPoojaVenue,
                "hiVenue": e.hiPoojaVenue,
                "thumbnail": e.thumbnail,
                "slug": e.slug,
                "id": e.id,
                "type": "pooja",
                "date": e.nextPoojaDate,
              }),
          ...allAnushthanModelList.map((e) => {
                "enName": e.enName,
                "hiName": e.hiName,
                "enHeadline": e.enPoojaHeading,
                "hiHeadline": e.hiPoojaHeading,
                "enDetails": e.enShortBenifits,
                "hiDetails": e.hiShortBenifits,
                "enVenue": "Updated soon",
                "hiVenue": "जल्द ही अपडेट किया जाएगा",
                "thumbnail": e.thumbnail,
                "slug": e.slug,
                "id": e.id,
                "type": "anushthan",
                "date": null,
              }),
          ...allvipModelList.map((e) => {
                "enName": e.enName,
                "hiName": e.hiName,
                "enHeadline": e.enPoojaHeading,
                "hiHeadline": e.hiPoojaHeading,
                "enDetails": e.enShortBenifits,
                "hiDetails": e.hiShortBenifits,
                "enVenue": "Updated soon",
                "hiVenue": "जल्द ही अपडेट किया जाएगा",
                "thumbnail": e.thumbnail,
                "slug": e.slug,
                "id": e.id,
                "type": "vip",
                "date": null,
              }),
          ...allChadhavaModelList.map((e) => {
                "enName": e.enName,
                "hiName": e.hiName,
                "enHeadline": e.enPoojaHeading,
                "hiHeadline": e.hiPoojaHeading,
                "enDetails": e.enShortDetails,
                "hiDetails": e.hiShortDetails,
                "enVenue": e.enChadhavaVenue,
                "hiVenue": e.hiChadhavaVenue,
                "thumbnail": e.thumbnail,
                "slug": e.slug,
                "id": e.id,
                "type": "chadhava",
                "date": e.nextChadhavaDate,
              }),
        ]);

        print("Pooja data loaded. Combined list size: ${combinedList.length}");
        if (!mounted) return;
        setState(() {});
      } else {
        print("API request failed with status: ${res["status"]}");
      }
    } catch (e) {
      print("Error fetching all Nivaran data: $e");
    }
  }

  void routeScreeen(String id, String slug, String name, String date) {
    switch (name) {
      case "pooja":
        Navigator.push(
            context,
            CupertinoDialogRoute(
                builder: (context) => SliversExample(
                      slugName: slug,
                      // nextDatePooja: date,
                    ),
                context: context));
        break;
      case "anushthan":
        Navigator.push(
            context,
            CupertinoDialogRoute(
                builder: (context) => AnushthanDetails(
                      idNumber: slug,
                      typePooja: 'anushthan',
                    ),
                context: context));
        break;
      case "vip":
        Navigator.push(
            context,
            CupertinoDialogRoute(
                builder: (context) => VipDetails(
                      idNumber: slug,
                      typePooja: 'vip',
                    ),
                context: context));
        break;
      case "chadhava":
        Navigator.push(
            context,
            CupertinoDialogRoute(
                builder: (context) => ChadhavaDetailView(
                      idNumber: id,
                      // nextDatePooja: date,
                    ),
                context: context));
        break;
      default:
        print("check pooja type");
        break;
    }
  }

  Future<void> getVipPooja() async {
    print("start function");
    var res = await HttpService().getApi(AppConstants.vipHomeUrl);
    print("print response for pooja $res");
    if (res["status"] == 200) {
      if (!mounted) return;
      setState(() {
        List vipList = res["data"];
        vipPoojaModelList.addAll(vipList.map((e) => Subcategory.fromJson(e)));
      });
    }
  }

  Future<void> getAnushthan() async {
    print("start function");
    var res = await HttpService().getApi(AppConstants.anushthanHomeUrl);
    print("print response for pooja $res");
    if (res["status"] == 200) {
      if (!mounted) return; // Add this line
      setState(() {
        List anushthanList = res["data"];
        anushthanModelList
            .addAll(anushthanList.map((e) => Subcategory.fromJson(e)));
      });
    }
  }

  Future<void> getChadhava() async {
    print("start function");
    var res = await HttpService().getApi(AppConstants.chadhavaHomeUrl);
    print("print response for pooja $res");
    if (res["status"] == 200) {
      if (!mounted) return;
      setState(() {
        List chadhavaList = res["data"];
        chadhavaModelList
            .addAll(chadhavaList.map((e) => Chadhavadetail.fromJson(e)));
      });
    }
  }

  Future<List<Subcategory>> getPoojaData(int categoryId) async {
    final url = Uri.parse(
        '${AppConstants.baseUrl}${AppConstants.poojaSubCategoryUrl}$categoryId');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final res = json.decode(response.body);
        final List<dynamic>? dataList = res["data"]; // Use nullable list

        if (dataList != null && dataList.isNotEmpty) {
          // Check for null and emptiness
          return dataList.map((e) => Subcategory.fromJson(e)).toList();
        }
      }
      // If status is not 200 or data is null/empty, return empty list
      return [];
    } catch (e) {
      // Log the error more effectively for debugging
      print('Error fetching Pooja data: $e');
      return [];
    }
  }

  String convertDateFormat(String date) {
    try {
      // Parse the input date string with the specified input format
      final dateTime = DateFormat('dd:MMMM:yyy').parse(date);

      // Format the DateTime object to the desired output format
      final formattedDate = DateFormat('dd MMMM yyyy').format(dateTime);

      return formattedDate;
    } catch (e) {
      print('Error parsing date: $e');
      return '';
    }
  }

  @override
  void initState() {
    super.initState();
    loadAllData();
  }

  Future<void> loadAllData() async {
    await Future.wait([
      getCategoryTab(),
      getVipPooja(),
      getAnushthan(),
      getChadhava(),
      getAllNivaran(),
    ]);
    if (!mounted) return; // <-- Add this line
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: categoryModelList.length + 4,
      initialIndex: widget.tabIndex,
      child: categoryModelList.isEmpty
          ? MahakalLoadingData(onReload: () {})
          : Scaffold(
              backgroundColor: Colors.white,
              appBar: AppBar(
                backgroundColor: Colors.white,
                actions: [
                  BouncingWidgetInOut(
                    onPressed: () {
                      if (!mounted) return;
                      setState(() {
                        gridList = !gridList;
                        translateEn = gridList ? 'en' : 'hi';
                      });
                      // getCategoryTab();
                    },
                    bouncingType: BouncingType.bounceInAndOut,
                    child: Container(
                      height: 30,
                      width: 30,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4.0),
                          color: gridList ? Colors.orange : Colors.white,
                          border: Border.all(color: Colors.orange, width: 2)),
                      child: Center(
                        child: Icon(Icons.translate,
                            color: gridList ? Colors.white : Colors.orange),
                      ),
                    ),
                  ),
                  BouncingWidgetInOut(
                    onPressed: () {
                      if (!mounted) return;
                      setState(() {
                        isGridView = !isGridView;
                      });
                    },
                    bouncingType: BouncingType.bounceInAndOut,
                    child: Container(
                      height: 30,
                      width: 30,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4.0),
                          color: isGridView ? Colors.orange : Colors.white,
                          border: Border.all(color: Colors.orange, width: 2)),
                      child: Center(
                        child: Icon(isGridView ? Icons.list : Icons.grid_view,
                            color: isGridView ? Colors.white : Colors.orange),
                      ),
                    ),
                  ),
                  InkWell(
                      onTap: () {
                        Navigator.push(
                            context,
                            PageAnimationTransition(
                                page: const PoojaSearchScreen(),
                                pageAnimationType: RightToLeftTransition()));
                      },
                      child: const Icon(
                        Icons.search,
                        size: 30,
                      )),
                  const SizedBox(
                    width: 10,
                  )
                ],
                title: const Text(
                  "Pooja Booking",
                  style: TextStyle(color: Colors.orange),
                ),
                centerTitle: true,
              ),
              body: Column(
                children: [
                  TabBar(
                      dividerColor: Colors.transparent,
                      isScrollable: true,
                      tabAlignment: TabAlignment.start,
                      unselectedLabelColor: Colors.black,
                      indicatorColor: Colors.red,
                      indicatorWeight: 1.0,
                      labelColor: Colors.orange,
                      unselectedLabelStyle: const TextStyle(fontSize: 18),
                      labelStyle: const TextStyle(fontSize: 20),
                      tabs: categoryModelList.isEmpty
                          ? [
                              Tab(
                                text: "All",
                                icon: Image.asset(
                                  "assets/images/gif/temple.gif",
                                  height: 30,
                                ),
                              ),
                              ...List.generate(
                                  4,
                                  (index) => Tab(
                                        text: translateEn == 'en'
                                            ? "pooja"
                                            : "पूजा",
                                        icon: Image.asset(
                                          tabsImage[index],
                                          height: 30,
                                        ),
                                      )),
                              Tab(
                                text: translateEn == "en"
                                    ? "Vip Pooja"
                                    : "वीआईपी पूजा",
                                icon: Image.asset(
                                  "assets/testImage/pooja/Vip puja icon.png",
                                  height: 30,
                                ),
                              ),
                              Tab(
                                text: translateEn == "en"
                                    ? "Anushthan"
                                    : "अनुष्ठान",
                                icon: Image.asset(
                                  "assets/testImage/pooja/Aanusthan icon.png",
                                  height: 30,
                                ),
                              ),
                              Tab(
                                text:
                                    translateEn == "en" ? "Chadhava" : "चढावा",
                                icon: Image.asset(
                                  "assets/testImage/pooja/Chadava icon.png",
                                  height: 30,
                                ),
                              ),
                            ]
                          : [
                              Tab(
                                text: "All",
                                icon: Image.asset(
                                  "assets/images/gif/temple.gif",
                                  height: 30,
                                ),
                              ),
                              ...List.generate(
                                  categoryModelList.length,
                                  (index) => Tab(
                                        text: translateEn == 'en'
                                            ? categoryModelList[index].enName
                                            : categoryModelList[index].hiName,
                                        icon: Image.asset(
                                          tabsImage[index],
                                          height: 30,
                                        ),
                                      )),
                              Tab(
                                text: translateEn == "en"
                                    ? "Vip Pooja"
                                    : "वीआईपी पूजा",
                                icon: Image.asset(
                                  "assets/testImage/pooja/Vip puja icon.png",
                                  height: 30,
                                ),
                              ),
                              Tab(
                                text: translateEn == "en"
                                    ? "Anushthan"
                                    : "अनुष्ठान",
                                icon: Image.asset(
                                  "assets/testImage/pooja/Aanusthan icon.png",
                                  height: 30,
                                ),
                              ),
                              Tab(
                                text:
                                    translateEn == "en" ? "Chadhava" : "चढावा",
                                icon: Image.asset(
                                  "assets/testImage/pooja/Chadava icon.png",
                                  height: 30,
                                ),
                              ),
                            ]),
                  Expanded(
                    child: TabBarView(children: [
                      if (combinedList.isEmpty)
                        Container(
                          child: const Center(
                              child: CircularProgressIndicator(
                            color: Colors.orange,
                          )),
                        )
                      else
                        DelayedDisplay(
                          delay: const Duration(microseconds: 300),
                          child: SingleChildScrollView(
                            controller: widget.scrollController,
                            child: Column(
                              children: [
                                const SizedBox(
                                  height: 10,
                                ),
                                if (isGridView)
                                  ListView.builder(
                                    itemCount: combinedList.length,
                                    physics: const BouncingScrollPhysics(),
                                    shrinkWrap: true,
                                    itemBuilder: (context, index) {
                                      final item = combinedList[index];
                                      return GestureDetector(
                                          onTap: () {
                                            routeScreeen(
                                                "${item['id']}",
                                                "${item['slug']}",
                                                "${item['type']}",
                                                "${item['date']}");
                                          },
                                          child: Container(
                                            height: 500,
                                            margin: const EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                boxShadow: const [
                                                  BoxShadow(
                                                      color: Colors.grey,
                                                      spreadRadius: 0.5,
                                                      blurRadius: 1.5,
                                                      offset: Offset(0, 0.5))
                                                ]),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Stack(
                                                  children: [
                                                    Shimmer.fromColors(
                                                      baseColor:
                                                          Colors.grey[300]!,
                                                      highlightColor:
                                                          Colors.grey[100]!,
                                                      child: Container(
                                                        width: double.infinity,
                                                        height:
                                                            230.0, // Set appropriate height
                                                        decoration:
                                                            const BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius.only(
                                                                  topLeft: Radius
                                                                      .circular(
                                                                          8.0),
                                                                  topRight: Radius
                                                                      .circular(
                                                                          8.0)),
                                                          color: Colors.white,
                                                        ),
                                                      ),
                                                    ),
                                                    ClipRRect(
                                                      borderRadius:
                                                          const BorderRadius
                                                              .only(
                                                              topLeft: Radius
                                                                  .circular(
                                                                      8.0),
                                                              topRight: Radius
                                                                  .circular(
                                                                      8.0)),
                                                      child: Image.network(
                                                        "${item['thumbnail']}",
                                                        fit: BoxFit.fill,
                                                        width: double.infinity,
                                                        height:
                                                            230.0, // Set appropriate height
                                                        loadingBuilder:
                                                            (BuildContext
                                                                    context,
                                                                Widget child,
                                                                ImageChunkEvent?
                                                                    loadingProgress) {
                                                          if (loadingProgress ==
                                                              null) {
                                                            // Once the image is fully loaded, stop the shimmer effect
                                                            return child;
                                                          } else {
                                                            // Continue showing shimmer while loading
                                                            return Stack(
                                                              children: [
                                                                Shimmer
                                                                    .fromColors(
                                                                  baseColor:
                                                                      Colors.grey[
                                                                          300]!,
                                                                  highlightColor:
                                                                      Colors.grey[
                                                                          100]!,
                                                                  child:
                                                                      Container(
                                                                    width: double
                                                                        .infinity,
                                                                    height:
                                                                        230.0,
                                                                    decoration:
                                                                        BoxDecoration(
                                                                      color: Colors
                                                                          .white,
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              10),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ],
                                                            );
                                                          }
                                                        },
                                                        errorBuilder: (context,
                                                            error, stackTrace) {
                                                          // Show an error widget in case the image fails to load
                                                          return const Center(
                                                            child: Icon(
                                                                Icons.error,
                                                                color:
                                                                    Colors.red),
                                                          );
                                                        },
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                Padding(
                                                  padding: const EdgeInsets.all(
                                                      10.0),
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Center(
                                                          child: Text(
                                                        "${translateEn == "en" ? item['enHeadline'] : item['hiHeadline']}",
                                                        style: const TextStyle(
                                                            fontSize: 20,
                                                            fontFamily:
                                                                'Roboto',
                                                            color:
                                                                Colors.orange,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis),
                                                        maxLines: 1,
                                                      )),
                                                      Container(
                                                        margin: const EdgeInsets
                                                            .symmetric(
                                                            vertical: 4),
                                                        height: 2,
                                                        width: double.infinity,
                                                        decoration:
                                                            const BoxDecoration(
                                                          gradient:
                                                              LinearGradient(
                                                            colors: [
                                                              Colors
                                                                  .yellow, // Start color
                                                              Colors
                                                                  .red, // Start color
                                                              Colors
                                                                  .yellow, // End color
                                                            ],
                                                            begin: Alignment
                                                                .topLeft, // Starting point of the gradient
                                                            end: Alignment
                                                                .bottomRight, // Ending point of the gradient
                                                          ),
                                                        ),
                                                      ),
                                                      Text(
                                                        " ✤ ${translateEn == "en" ? item['enName'] : item['hiName']}",
                                                        style: const TextStyle(
                                                            fontSize: 22,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontFamily:
                                                                'Roboto',
                                                            color: Colors.black,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis),
                                                        maxLines: 1,
                                                      ),
                                                      const SizedBox(
                                                        height: 6,
                                                      ),
                                                      Text(
                                                        "${translateEn == "en" ? item['enDetails'] : item['hiDetails']}",
                                                        style: const TextStyle(
                                                            fontSize: 16,
                                                            fontFamily:
                                                                'Roboto',
                                                            color:
                                                                Colors.black87,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis),
                                                        maxLines: 2,
                                                      ),

                                                      const SizedBox(
                                                        height: 6,
                                                      ),
                                                      Row(
                                                        children: [
                                                          const Expanded(
                                                              flex: 0,
                                                              child: Icon(
                                                                Icons
                                                                    .location_pin,
                                                                size: 18,
                                                                color: Colors
                                                                    .orange,
                                                              )),
                                                          const SizedBox(
                                                            width: 6,
                                                          ),
                                                          Expanded(
                                                            child: Text(
                                                              "${translateEn == "en" ? item['enVenue'] : item['hiVenue']}",
                                                              style: const TextStyle(
                                                                  fontSize: 17,
                                                                  fontFamily:
                                                                      'Roboto',
                                                                  color: Colors
                                                                      .black),
                                                              maxLines: 1,
                                                            ),
                                                          ),
                                                        ],
                                                      ),

                                                      const SizedBox(
                                                        height: 3,
                                                      ),
                                                      // Row(
                                                      //   children: [
                                                      //     const Icon(Icons.calendar_month,size: 18,color: Colors.orange,),
                                                      //     const SizedBox(width: 6,),
                                                      //     Text( item['date'] != null && item['date'].isNotEmpty
                                                      //         ? DateFormat('dd-MMMM-yyyy').format(DateFormat('yyyy-MM-dd').parse(item['date']))
                                                      //         : 'आप पूजा की तिथि चुन सकते हैं',
                                                      //       style: const TextStyle(
                                                      //           fontSize: 17,
                                                      //           fontFamily: 'Roboto',
                                                      //           color: Colors.black),
                                                      //     ),
                                                      //   ],
                                                      // ),

                                                      Row(
                                                        children: [
                                                          const Icon(
                                                              Icons
                                                                  .calendar_month,
                                                              size: 18,
                                                              color: Colors
                                                                  .orange),
                                                          const SizedBox(
                                                              width: 6),
                                                          Text(
                                                            item['date'] != null
                                                                ? DateFormat('dd-MMMM-yyyy').format(item[
                                                                            'date']
                                                                        is DateTime
                                                                    ? item[
                                                                        'date']
                                                                    : DateFormat(
                                                                            'yyyy-MM-dd')
                                                                        .parse(item[
                                                                            'date']))
                                                                : 'आप पूजा की तिथि चुन सकते हैं',
                                                            style:
                                                                const TextStyle(
                                                              fontSize: 17,
                                                              fontFamily:
                                                                  'Roboto',
                                                              color:
                                                                  Colors.black,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                const Spacer(),
                                                Container(
                                                  height: 45,
                                                  decoration:
                                                      const BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.only(
                                                            bottomLeft:
                                                                Radius.circular(
                                                                    8.0),
                                                            bottomRight: Radius
                                                                .circular(8.0)),
                                                    // color: Colors.green,
                                                    gradient: LinearGradient(
                                                      colors: [
                                                        Colors
                                                            .orange, // Start color
                                                        Colors
                                                            .red, // Start color
                                                        Colors
                                                            .orange, // End color
                                                      ],
                                                      begin: Alignment
                                                          .topLeft, // Starting point of the gradient
                                                      end: Alignment
                                                          .bottomRight, // Ending point of the gradient
                                                    ),
                                                  ),
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      Text(
                                                        translateEn == "en"
                                                            ? "Book now"
                                                            : "बुक करें",
                                                        style: const TextStyle(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color: Colors.white,
                                                            letterSpacing: 1,
                                                            fontSize: 16),
                                                      ),
                                                      const SizedBox(
                                                        width: 6,
                                                      ),
                                                      const Icon(
                                                        Icons
                                                            .arrow_circle_right,
                                                        color: Colors.white,
                                                      ),
                                                    ],
                                                  ),
                                                )
                                              ],
                                            ),
                                          ));
                                    },
                                  )
                                else
                                  ListView.builder(
                                    itemCount: combinedList.length,
                                    physics: const BouncingScrollPhysics(),
                                    shrinkWrap: true,
                                    itemBuilder: (context, index) {
                                      final item = combinedList[index];
                                      // DateTime now = DateTime.now();
                                      // DateTime nextDate = findNextDate(now, "${allNivaranModelList[index].weekDays}");
                                      // String formattedDate = formatDate(nextDate);
                                      return GestureDetector(
                                          onTap: () {
                                            routeScreeen(
                                                "${item['id']}",
                                                "${item['slug']}",
                                                "${item['type']}",
                                                "${item['date']}");
                                          },
                                          child: Container(
                                            padding: const EdgeInsets.all(5),
                                            margin: const EdgeInsets.symmetric(
                                                horizontal: 10, vertical: 5),
                                            decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                border: Border.all(
                                                    color: Colors.grey.shade300,
                                                    width: 1.5)),
                                            child: Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Expanded(
                                                  flex: 0,
                                                  child: Container(
                                                    height: 80,
                                                    width: 120,
                                                    decoration: BoxDecoration(
                                                        color: Colors
                                                            .grey.shade300,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(6),
                                                        image: DecorationImage(
                                                            image: NetworkImage(
                                                                "${item['thumbnail']}"),
                                                            fit: BoxFit.fill)),
                                                  ),
                                                ),
                                                const SizedBox(
                                                  width: 10,
                                                ),
                                                Expanded(
                                                  flex: 1,
                                                  child: Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        "${translateEn == "en" ? item['enName'] : item['hiName']}",
                                                        style: const TextStyle(
                                                            fontSize: 20,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontFamily:
                                                                'Roboto',
                                                            color: Colors.black,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis),
                                                        maxLines: 1,
                                                      ),
                                                      Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .start,
                                                        children: [
                                                          const Expanded(
                                                              flex: 0,
                                                              child: Icon(
                                                                Icons
                                                                    .temple_buddhist,
                                                                size: 18,
                                                                color: Colors
                                                                    .orange,
                                                              )),
                                                          const SizedBox(
                                                            width: 6,
                                                          ),
                                                          Expanded(
                                                            child: Text(
                                                              "${translateEn == "en" ? item['enVenue'] : item['hiVenue']}",
                                                              style: const TextStyle(
                                                                  fontSize: 16,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500,
                                                                  fontFamily:
                                                                      'Roboto',
                                                                  color: Colors
                                                                      .black),
                                                              maxLines: 1,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      Row(
                                                        children: [
                                                          const Icon(
                                                            Icons
                                                                .calendar_month,
                                                            size: 18,
                                                            color:
                                                                Colors.orange,
                                                          ),
                                                          const SizedBox(
                                                            width: 6,
                                                          ),
                                                          Text(
                                                            item['date'] !=
                                                                        null &&
                                                                    (item['date']
                                                                            is String
                                                                        ? (item['date']
                                                                                as String)
                                                                            .isNotEmpty
                                                                        : true) // Assuming DateTime is never empty in this context
                                                                ? DateFormat('dd-MMMM-yyyy').format(item[
                                                                            'date']
                                                                        is DateTime
                                                                    ? item[
                                                                        'date']
                                                                    : DateFormat(
                                                                            'yyyy-MM-dd')
                                                                        .parse(item[
                                                                            'date']!))
                                                                : 'आप पूजा की तिथि चुन सकते हैं', // Updated this line
                                                            style: const TextStyle(
                                                                fontSize: 18,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                fontFamily:
                                                                    'Roboto',
                                                                color: Colors
                                                                    .black),
                                                          ),
                                                          const Spacer(),
                                                          Container(
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(1),
                                                            decoration:
                                                                const BoxDecoration(
                                                              shape: BoxShape
                                                                  .circle,
                                                              color: Colors
                                                                  .deepOrange,
                                                            ),
                                                            child: const Icon(
                                                              Icons
                                                                  .arrow_circle_right,
                                                              color:
                                                                  Colors.white,
                                                              size: 20,
                                                            ),
                                                          )
                                                        ],
                                                      ),
                                                    ],
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
                        ),
                      ...categoryModelList.map((category) {
                        return FutureBuilder<List<Subcategory>>(
                          future: getPoojaData(category.id),
                          builder: (context, snapshot) {
                            // ERROR STATE
                            if (snapshot.hasError) {
                              return const Center(
                                child: Text(
                                  'Data Not Available',
                                  style: TextStyle(fontSize: 16, color: Colors.red),
                                ),
                              );
                            }

                            // LOADING STATE (jab tak response nahi aata)
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return const Center(
                                child: CircularProgressIndicator(color: Colors.orange),
                              );
                            }

                            // NO DATA AVAILABLE
                            if (!snapshot.hasData || snapshot.data == null || snapshot.data!.isEmpty) {
                              return Center(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
                                  margin: const EdgeInsets.symmetric(horizontal: 20),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black12,
                                        blurRadius: 12,
                                        spreadRadius: 2,
                                        offset: Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.hourglass_empty_rounded,
                                        size: 60,
                                        color: Colors.orange,
                                      ),
                                      SizedBox(height: 15),
                                      Text(
                                        'Coming Soon',
                                        style: TextStyle(
                                          fontSize: 22,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.orange,
                                        ),
                                      ),
                                      SizedBox(height: 6),
                                      Text(
                                        'Pooja details will be available soon.',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.black54,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }

                            List<Subcategory> subcategory = snapshot.data!;
                            return SingleChildScrollView(
                              controller: widget.scrollController,
                              child: Column(
                                children: [
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  if (isGridView)
                                    ListView.builder(
                                      itemCount: subcategory.length,
                                      physics: const BouncingScrollPhysics(),
                                      shrinkWrap: true,
                                      itemBuilder: (context, index) {
                                        // DateTime now = DateTime.now();
                                        // DateTime nextDate = findNextDate(now, "${itemweekDays}");
                                        // String formattedDate = formatDate(nextDate);
                                        return GestureDetector(
                                            onTap: () {
                                              Navigator.push(
                                                  context,
                                                  CupertinoPageRoute(
                                                    builder: (context) =>
                                                        SliversExample(
                                                      slugName:
                                                          subcategory[index]
                                                              .slug
                                                              .toString(),
                                                      // nextDatePooja:
                                                      //     "${subcategory[index].nextPoojaDate}",
                                                    ),
                                                  ));
                                            },
                                            child: Container(
                                              height: 500,
                                              margin: const EdgeInsets.all(8),
                                              decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                  boxShadow: const [
                                                    BoxShadow(
                                                        color: Colors.grey,
                                                        spreadRadius: 0.5,
                                                        blurRadius: 1.5,
                                                        offset: Offset(0, 0.5))
                                                  ]),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Stack(
                                                    children: [
                                                      Shimmer.fromColors(
                                                        baseColor:
                                                            Colors.grey[300]!,
                                                        highlightColor:
                                                            Colors.grey[100]!,
                                                        child: Container(
                                                          width:
                                                              double.infinity,
                                                          height:
                                                              230.0, // Set appropriate height
                                                          decoration:
                                                              const BoxDecoration(
                                                            borderRadius: BorderRadius.only(
                                                                topLeft: Radius
                                                                    .circular(
                                                                        8.0),
                                                                topRight: Radius
                                                                    .circular(
                                                                        8.0)),
                                                            color: Colors.white,
                                                          ),
                                                        ),
                                                      ),
                                                      ClipRRect(
                                                        borderRadius:
                                                            const BorderRadius
                                                                .only(
                                                                topLeft: Radius
                                                                    .circular(
                                                                        8.0),
                                                                topRight: Radius
                                                                    .circular(
                                                                        8.0)),
                                                        child: Image.network(
                                                          subcategory[index]
                                                              .thumbnail,
                                                          fit: BoxFit.fill,
                                                          width:
                                                              double.infinity,
                                                          height:
                                                              230.0, // Set appropriate height
                                                          loadingBuilder:
                                                              (BuildContext
                                                                      context,
                                                                  Widget child,
                                                                  ImageChunkEvent?
                                                                      loadingProgress) {
                                                            if (loadingProgress ==
                                                                null) {
                                                              // Once the image is fully loaded, stop the shimmer effect
                                                              return child;
                                                            } else {
                                                              // Continue showing shimmer while loading
                                                              return Stack(
                                                                children: [
                                                                  Shimmer
                                                                      .fromColors(
                                                                    baseColor:
                                                                        Colors.grey[
                                                                            300]!,
                                                                    highlightColor:
                                                                        Colors.grey[
                                                                            100]!,
                                                                    child:
                                                                        Container(
                                                                      width: double
                                                                          .infinity,
                                                                      height:
                                                                          230.0,
                                                                      decoration:
                                                                          BoxDecoration(
                                                                        color: Colors
                                                                            .white,
                                                                        borderRadius:
                                                                            BorderRadius.circular(10),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ],
                                                              );
                                                            }
                                                          },
                                                          errorBuilder:
                                                              (context, error,
                                                                  stackTrace) {
                                                            // Show an error widget in case the image fails to load
                                                            return const Center(
                                                              child: Icon(
                                                                  Icons.error,
                                                                  color: Colors
                                                                      .red),
                                                            );
                                                          },
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            10.0),
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Center(
                                                            child: Text(
                                                          translateEn == "en"
                                                              ? subcategory[
                                                                      index]
                                                                  .enPoojaHeading
                                                              : subcategory[
                                                                      index]
                                                                  .hiPoojaHeading,
                                                          style: const TextStyle(
                                                              fontSize: 20,
                                                              fontFamily:
                                                                  'Roboto',
                                                              color:
                                                                  Colors.orange,
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis),
                                                          maxLines: 1,
                                                        )),
                                                        Container(
                                                          margin:
                                                              const EdgeInsets
                                                                  .symmetric(
                                                                  vertical: 4),
                                                          height: 2,
                                                          width:
                                                              double.infinity,
                                                          decoration:
                                                              const BoxDecoration(
                                                            gradient:
                                                                LinearGradient(
                                                              colors: [
                                                                Colors
                                                                    .yellow, // Start color
                                                                Colors
                                                                    .red, // Start color
                                                                Colors
                                                                    .yellow, // End color
                                                              ],
                                                              begin: Alignment
                                                                  .topLeft, // Starting point of the gradient
                                                              end: Alignment
                                                                  .bottomRight, // Ending point of the gradient
                                                            ),
                                                          ),
                                                        ),
                                                        Text(
                                                          " ✤ ${translateEn == "en" ? subcategory[index].enName : subcategory[index].hiName}",
                                                          style: const TextStyle(
                                                              fontSize: 22,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              fontFamily:
                                                                  'Roboto',
                                                              color:
                                                                  Colors.black,
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis),
                                                          maxLines: 1,
                                                        ),
                                                        const SizedBox(
                                                          height: 6,
                                                        ),
                                                        Text(
                                                          translateEn == "en"
                                                              ? subcategory[
                                                                      index]
                                                                  .enShortBenifits
                                                              : subcategory[
                                                                      index]
                                                                  .hiShortBenifits,
                                                          style: const TextStyle(
                                                              fontSize: 16,
                                                              fontFamily:
                                                                  'Roboto',
                                                              color: Colors
                                                                  .black87,
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis),
                                                          maxLines: 2,
                                                        ),
                                                        const SizedBox(
                                                          height: 6,
                                                        ),
                                                        Row(
                                                          children: [
                                                            const Expanded(
                                                                flex: 0,
                                                                child: Icon(
                                                                  Icons
                                                                      .location_pin,
                                                                  size: 18,
                                                                  color: Colors
                                                                      .orange,
                                                                )),
                                                            const SizedBox(
                                                              width: 6,
                                                            ),
                                                            Expanded(
                                                              child: Text(
                                                                translateEn ==
                                                                        "en"
                                                                    ? subcategory[
                                                                            index]
                                                                        .enPoojaVenue
                                                                    : subcategory[
                                                                            index]
                                                                        .hiPoojaVenue,
                                                                style: const TextStyle(
                                                                    fontSize:
                                                                        17,
                                                                    fontFamily:
                                                                        'Roboto',
                                                                    color: Colors
                                                                        .black),
                                                                maxLines: 1,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        const SizedBox(
                                                          height: 3,
                                                        ),
                                                        Row(
                                                          children: [
                                                            const Icon(
                                                              Icons
                                                                  .calendar_month,
                                                              size: 18,
                                                              color:
                                                                  Colors.orange,
                                                            ),
                                                            const SizedBox(
                                                              width: 6,
                                                            ),
                                                            Text(
                                                              subcategory[index]
                                                                          .nextPoojaDate !=
                                                                      null
                                                                  ? DateFormat(
                                                                          'dd-MMMM-yyyy')
                                                                      .format(DateFormat(
                                                                              'yyyy-MM-dd')
                                                                          .parse(
                                                                              "${subcategory[index].nextPoojaDate}"))
                                                                  : 'Date not available',
                                                              style: const TextStyle(
                                                                  fontSize: 17,
                                                                  fontFamily:
                                                                      'Roboto',
                                                                  color: Colors
                                                                      .black),
                                                            ),
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  const Spacer(),
                                                  Container(
                                                    height: 45,
                                                    decoration:
                                                        const BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.only(
                                                              bottomLeft: Radius
                                                                  .circular(
                                                                      8.0),
                                                              bottomRight:
                                                                  Radius
                                                                      .circular(
                                                                          8.0)),
                                                      gradient: LinearGradient(
                                                        colors: [
                                                          Colors
                                                              .orange, // Start color
                                                          Colors
                                                              .red, // Start color
                                                          Colors
                                                              .orange, // End color
                                                        ],
                                                        begin: Alignment
                                                            .topLeft, // Starting point of the gradient
                                                        end: Alignment
                                                            .bottomRight, // Ending point of the gradient
                                                      ),
                                                    ),
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        Text(
                                                          translateEn == "en"
                                                              ? "Book now"
                                                              : "बुक करें",
                                                          style:
                                                              const TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  color: Colors
                                                                      .white,
                                                                  letterSpacing:
                                                                      1,
                                                                  fontSize: 16),
                                                        ),
                                                        const SizedBox(
                                                          width: 6,
                                                        ),
                                                        const Icon(
                                                          Icons
                                                              .arrow_circle_right,
                                                          color: Colors.white,
                                                        ),
                                                      ],
                                                    ),
                                                  )
                                                ],
                                              ),
                                            ));
                                      },
                                    )
                                  else
                                    ListView.builder(
                                      itemCount: subcategory.length,
                                      physics: const BouncingScrollPhysics(),
                                      shrinkWrap: true,
                                      itemBuilder: (context, index) {
                                        DateTime now = DateTime.now();
                                        // DateTime nextDate = findNextDate(now, "${subcategory[index].weekDays}");
                                        // String formattedDate = formatDate(nextDate);
                                        return GestureDetector(
                                            onTap: () {
                                              Navigator.push(
                                                  context,
                                                  CupertinoPageRoute(
                                                    builder: (context) =>
                                                        SliversExample(
                                                      slugName:
                                                          subcategory[index]
                                                              .slug
                                                              .toString(),
                                                      // nextDatePooja:
                                                      //     '${subcategory[index].nextPoojaDate}',
                                                    ),
                                                  ));
                                              print(
                                                  "Slug Name- ${subcategory[index].slug}");
                                              print(
                                                  "Date- ${subcategory[index].nextPoojaDate}");
                                            },
                                            child: Container(
                                              padding: const EdgeInsets.all(5),
                                              margin:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 10,
                                                      vertical: 5),
                                              decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                  border: Border.all(
                                                      color:
                                                          Colors.grey.shade300,
                                                      width: 1.5)),
                                              child: Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Expanded(
                                                    flex: 0,
                                                    child: Container(
                                                      height: 80,
                                                      width: 120,
                                                      decoration: BoxDecoration(
                                                          color: Colors
                                                              .grey.shade300,
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(6),
                                                          image: DecorationImage(
                                                              image: NetworkImage(
                                                                  subcategory[
                                                                          index]
                                                                      .thumbnail),
                                                              fit:
                                                                  BoxFit.fill)),
                                                    ),
                                                  ),
                                                  const SizedBox(
                                                    width: 10,
                                                  ),
                                                  Expanded(
                                                    flex: 1,
                                                    child: Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .start,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          translateEn == "en"
                                                              ? subcategory[
                                                                      index]
                                                                  .enName
                                                              : subcategory[
                                                                      index]
                                                                  .hiName,
                                                          style: const TextStyle(
                                                              fontSize: 20,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              fontFamily:
                                                                  'Roboto',
                                                              color:
                                                                  Colors.black,
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis),
                                                          maxLines: 1,
                                                        ),
                                                        Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .start,
                                                          children: [
                                                            const Expanded(
                                                                flex: 0,
                                                                child: Icon(
                                                                  Icons
                                                                      .temple_buddhist,
                                                                  size: 18,
                                                                  color: Colors
                                                                      .orange,
                                                                )),
                                                            const SizedBox(
                                                              width: 6,
                                                            ),
                                                            Expanded(
                                                              child: Text(
                                                                translateEn ==
                                                                        "en"
                                                                    ? subcategory[
                                                                            index]
                                                                        .enPoojaVenue
                                                                    : subcategory[
                                                                            index]
                                                                        .hiPoojaVenue,
                                                                style: const TextStyle(
                                                                    fontSize:
                                                                        16,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w500,
                                                                    fontFamily:
                                                                        'Roboto',
                                                                    color: Colors
                                                                        .black),
                                                                maxLines: 1,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        Row(
                                                          children: [
                                                            const Icon(
                                                              Icons
                                                                  .calendar_month,
                                                              size: 18,
                                                              color:
                                                                  Colors.orange,
                                                            ),
                                                            const SizedBox(
                                                              width: 6,
                                                            ),
                                                            Text(
                                                              subcategory[index]
                                                                          .nextPoojaDate !=
                                                                      null
                                                                  ? DateFormat(
                                                                          'dd-MMMM-yyyy')
                                                                      .format(DateFormat(
                                                                              'yyyy-MM-dd')
                                                                          .parse(
                                                                              "${subcategory[index].nextPoojaDate}"))
                                                                  : 'Date not available',
                                                              style: const TextStyle(
                                                                  fontSize: 18,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  fontFamily:
                                                                      'Roboto',
                                                                  color: Colors
                                                                      .black),
                                                            ),
                                                            const Spacer(),
                                                            Container(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .all(1),
                                                              decoration:
                                                                  const BoxDecoration(
                                                                shape: BoxShape
                                                                    .circle,
                                                                color: Colors
                                                                    .deepOrange,
                                                              ),
                                                              child: const Icon(
                                                                Icons
                                                                    .arrow_circle_right,
                                                                color: Colors
                                                                    .white,
                                                                size: 20,
                                                              ),
                                                            )
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ));
                                      },
                                    ),
                                ],
                              ),
                            );
                          },
                        );
                      }),
                      VipPoojaView(
                          isGridList: isGridView,
                          translate: translateEn,
                          vipModelList: vipPoojaModelList,
                          scrollController: widget.scrollController),
                      AnushthanView(
                          isGridList: isGridView,
                          translate: translateEn,
                          anushthanList: anushthanModelList,
                          scrollController: widget.scrollController),
                      ChadhavaView(
                          isGridList: isGridView,
                          translate: translateEn,
                          chadhavaList: chadhavaModelList,
                          scrollController: widget.scrollController),
                    ]),
                    // [
                    //   AllPageView(isGridList: isGridView , ),
                    //   SamsyaNivaranView(isGridList: isGridView, data: allSubcategoryData,),
                    //   DoshNivaranView(isGridList: isGridView, data: allSubcategoryData,),
                    //   JaapPoojaView(isGridList: isGridView, data: allSubcategoryData,),
                    //   // EventPageView(isGridList: isGridView,),
                    //   SpecialPageView(isGridList: isGridView, data: allSubcategoryData,)
                    // ],
                  ),
                ],
              ),
            ),
    );
  }
}
