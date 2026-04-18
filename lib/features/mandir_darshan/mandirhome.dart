import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mahakal/features/mandir_darshan/searchscreen.dart';
// import 'package:mahakal/features/mandir_darshan/tabtest.dart';
// import 'package:mahakal/features/mandir_darshan/test.dart';
import 'package:intl/intl.dart';
import 'package:mahakal/utill/loading_datawidget.dart';
import 'package:tdk_bouncingwidget/tdk_bouncingwidget.dart';
import '../../data/datasource/remote/http/httpClient.dart';
import '../../utill/app_constants.dart';
import 'mandirdetails_mandir.dart';
import 'model/darshan_category_model.dart';
import 'model/templeModel.dart';

class MandirDarshan extends StatefulWidget {
  final int tabIndex;
  const MandirDarshan({super.key, required this.tabIndex});

  @override
  State<MandirDarshan> createState() => _MandirDarshanState();
}

class _MandirDarshanState extends State<MandirDarshan>
    with SingleTickerProviderStateMixin {
  TabController? _tabController;
  bool gridList = false;
  String translateEn = 'hi';

  List<DarshanData> darshanCategoryModelList = <DarshanData>[];
  List<Datum> darshanTempleModelList = <Datum>[];
  List<Datum> allMandirDarshan = <Datum>[];

  String convertTimeToAmPm(String time) {
    final dateTime = DateFormat('HH:mm:ss').parse(time);
    final formattedTime = DateFormat.jm().format(dateTime);
    return formattedTime;
  }

  void getCategoryTab() async {
    var res = await HttpService().getApi(AppConstants.darshanCategoryUrl);
    print(res);
    setState(() {
      darshanCategoryModelList.clear();
      List categoryList = res["data"];
      darshanCategoryModelList
          .addAll(categoryList.map((e) => DarshanData.fromJson(e)));
      _tabController = TabController(
          length: darshanCategoryModelList.length + 1,
          vsync: this,
          initialIndex: widget.tabIndex);
    });
  }

  void getAllMandir() async {
    var res = await HttpService().getApi(AppConstants.allMandirDarshan);
    print(res);
    setState(() {
      allMandirDarshan.clear();
      List categoryList = res["data"];
      allMandirDarshan.addAll(categoryList.map((e) => Datum.fromJson(e)));
    });
  }

  Future<List<Datum>> getTempleData(int categoryId) async {
    var res = await HttpService()
        .postApi(AppConstants.getTempleUrl, {"category_id": "$categoryId"});
    List<dynamic> templeList = res["data"];
    return templeList.map((e) => Datum.fromJson(e)).toList();
  }

  List<String> mandirCategoryList = [
    "assets/images/allcategories/animate/Shiv_animation.gif",
    "assets/images/allcategories/51_shakti_peeth icon.png",
    "assets/images/allcategories/animate/4 dham icon animation.gif",
    "assets/images/allcategories/Iskcon_icon.png",
    "assets/images/allcategories/other_dev_dham icon.png",
  ];

  // void getTemple() async {
  //   var res = await HttpService().postApi("/api/v1/temple/gettemple",
  //       {
  //         "category_id": "${1}"
  //       }
  //   );
  //   print("Api response $res");
  //   print("Api response ${darshanTempleModelList.length}");
  //   darshanTempleModelList.clear();
  //   List<dynamic> templeList = res['data'];
  //   darshanTempleModelList.addAll(templeList.map((e) => Datum.fromJson(e)));
  // }

  // void getTemple() async {
  //   var res = await HttpService().postApi("/api/v1/temple/gettemple",
  //       {
  //     "category_id": 1,
  //       }
  //   );
  //   print(res);
  //   setState(() {
  //     darshanTempleModelList.clear();
  //     List templeList = res["data"];
  //     darshanTempleModelList.addAll(templeList.map((e) => Datum.fromJson(e)));
  //   });
  // }

  // void _handleTabSelection() {
  //   if (_tabController.indexIsChanging) {
  //     final selectedCategoryId = darshanCategoryModelList[_tabController.index].id;
  //     // getTempleData(selectedCategoryId!);
  //   }
  // }

  @override
  void initState() {
    super.initState();
    // getTemple();
    getAllMandir();
    getCategoryTab();
    // _tabController.addListener(_handleTabSelection);
    // getTempleData(darshanCategoryModelList[0].id!);
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return DefaultTabController(
      length: darshanCategoryModelList.length + 1,
      initialIndex: widget.tabIndex,
      child: darshanCategoryModelList.isEmpty
          ? MahakalLoadingData(onReload: () {})
          : Scaffold(
              appBar: AppBar(
                title: const Text(
                  'Mandir Darshan',
                  style: TextStyle(
                    color: Colors.orange,
                  ),
                ),
                centerTitle: true,
                actions: [
                  BouncingWidgetInOut(
                    onPressed: () {
                      setState(() {
                        gridList = !gridList;
                        translateEn = gridList ? 'en' : 'hi';
                      });
                      getCategoryTab();
                    },
                    bouncingType: BouncingType.bounceInAndOut,
                    child: Container(
                      height: 25,
                      width: 25,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4.0),
                          color: gridList ? Colors.orange : Colors.white,
                          border: Border.all(color: Colors.orange, width: 2)),
                      child: Center(
                        child: Icon(
                          Icons.translate,
                          color: gridList ? Colors.white : Colors.orange,
                          size: 18,
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        CupertinoPageRoute(
                          builder: (context) => const SearchScreen(),
                        ),
                      );
                    },
                    icon: const Icon(
                      Icons.search,
                      color: Colors.black,
                      size: 30,
                    ),
                  ),
                ],
                bottom: TabBar(
                  tabAlignment: TabAlignment.start,
                  controller: _tabController,
                  indicatorSize: TabBarIndicatorSize.tab,
                  labelColor: Colors.orange,
                  indicatorColor: Colors.orange,
                  isScrollable: true,
                  tabs: [
                    Tab(
                      icon: Image.network(
                        "https://cdn.iconscout.com/icon/premium/png-256-thumb/mandir-3595180-3048821.png",
                        height: 30,
                      ),
                      text: translateEn == "en" ? 'All' : 'All',
                    ),
                    ...List.generate(
                        darshanCategoryModelList.length,
                        (index) => Tab(
                              icon: Image.network(
                                darshanCategoryModelList[index].image ?? '',
                                height: 30,
                              ),
                              text:
                                  "${translateEn == "en" ? darshanCategoryModelList[index].enName : darshanCategoryModelList[index].hiName}",
                            )),
                  ],
                  dividerColor: Colors.white,
                ),
              ),
              body: TabBarView(
                controller: _tabController,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(
                        top: 10.0, right: 10.0, left: 10.0),
                    child: GridView.builder(
                      shrinkWrap: true,
                      physics: const BouncingScrollPhysics(),
                      itemCount: allMandirDarshan.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 4.0,
                          mainAxisSpacing: 4.0,
                          childAspectRatio:
                              MediaQuery.of(context).size.aspectRatio * 1.6),
                      itemBuilder: (BuildContext context, int index) {
                        final subcategory = allMandirDarshan;
                        return InkWell(
                          onTap: () {
                            print("object");
                            Navigator.push(
                                context,
                                CupertinoPageRoute(
                                    builder: (context) => MandirDetailView(
                                          detailId: "${subcategory[index].id}",
                                        )));
                            // Navigator.push(context, CupertinoPageRoute(builder: (context) => TabTestView()));
                          },
                          child: Container(
                            margin: const EdgeInsets.all(4),
                            width: 140,
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12.0),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.2),
                                    spreadRadius: 2,
                                    blurRadius: 5,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                                border: Border.all(
                                    color: Colors.grey.shade200, width: 1.0)),
                            child: Stack(
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Image Section
                                    Expanded(
                                      flex: 3,
                                      child: SizedBox(
                                        width: double.infinity,
                                        child: ClipRRect(
                                          borderRadius:
                                              const BorderRadius.vertical(
                                                  top: Radius.circular(12)),
                                          child: Image.network(
                                            "${subcategory[index].image}",
                                            fit: BoxFit.fill,
                                            loadingBuilder: (context, child,
                                                loadingProgress) {
                                              if (loadingProgress == null) {
                                                return child;
                                              }
                                              return Image.asset(
                                                'assets/images/mahakal.jpeg',
                                                fit: BoxFit.cover,
                                                width: double.infinity,
                                                height: double.infinity,
                                              );
                                            },
                                            errorBuilder:
                                                (context, error, stackTrace) =>
                                                    Image.asset(
                                              'assets/error_placeholder.png',
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),

                                    // Text Section
                                    Expanded(
                                      flex: 1,
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8.0, vertical: 6),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          children: [
                                            Text(
                                              '${translateEn == 'en' ? subcategory[index].enName : subcategory[index].hiName}',
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.orange.shade800,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            Row(
                                              children: [
                                                Icon(Icons.access_time,
                                                    size: 14,
                                                    color:
                                                        Colors.grey.shade600),
                                                const SizedBox(width: 4),
                                                Flexible(
                                                  child: Text(
                                                    '${convertTimeToAmPm("${subcategory[index].openingTime}")} - ${convertTimeToAmPm("${subcategory[index].closeingTime}")}',
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      color:
                                                          Colors.grey.shade700,
                                                    ),
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),

                                // VIP Badge - Only shown when vipDarshanStatus is 1
                                if (subcategory[index].vipDarshanStatus == 1)
                                  Positioned(
                                    top: 8,
                                    right: 8,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: Colors.amber[700],
                                        borderRadius: BorderRadius.circular(10),
                                        boxShadow: [
                                          BoxShadow(
                                            color:
                                                Colors.black.withOpacity(0.1),
                                            blurRadius: 3,
                                            offset: const Offset(0, 1),
                                          )
                                        ],
                                      ),
                                      child: const Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(Icons.star,
                                              color: Colors.white, size: 12),
                                          SizedBox(width: 2),
                                          Text(
                                            'VIP BOOKING',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                              letterSpacing: 0.5,
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
                  ...darshanCategoryModelList.map((category) {
                    return FutureBuilder<List<Datum>>(
                      future: getTempleData(category.id!),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                              child: CircularProgressIndicator(
                                  color: Colors.orange));
                        }

                        if (snapshot.hasError) {
                          return Center(
                              child: Text('Error: ${snapshot.error}'));
                        }

                        if (!snapshot.hasData || snapshot.data == null) {
                          return const Center(child: Text('No data available'));
                        }

                        List<Datum> subcategory = snapshot.data!;
                        return Padding(
                          padding: const EdgeInsets.only(
                              top: 10.0, right: 10.0, left: 10.0),
                          child: GridView.builder(
                            shrinkWrap: true,
                            physics: const BouncingScrollPhysics(),
                            itemCount: subcategory.length,
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    crossAxisSpacing: 4.0,
                                    mainAxisSpacing: 4.0,
                                    childAspectRatio: MediaQuery.of(context)
                                            .size
                                            .aspectRatio *
                                        1.6),
                            itemBuilder: (BuildContext context, int index) {
                              return InkWell(
                                onTap: () {
                                  print("object");
                                  Navigator.push(
                                      context,
                                      CupertinoPageRoute(
                                          builder: (context) =>
                                              MandirDetailView(
                                                detailId:
                                                    "${subcategory[index].id}",
                                              )));
                                  // Navigator.push(context, CupertinoPageRoute(builder: (context) => TabTestView()));
                                },
                                child: Container(
                                  margin: const EdgeInsets.all(4),
                                  width: 140,
                                  decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(12.0),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.grey.withOpacity(0.2),
                                          spreadRadius: 2,
                                          blurRadius: 5,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                      border: Border.all(
                                          color: Colors.grey.shade200,
                                          width: 1.0)),
                                  child: Stack(
                                    children: [
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          // Image Section
                                          Expanded(
                                            flex: 3,
                                            child: SizedBox(
                                              width: double.infinity,
                                              child: ClipRRect(
                                                borderRadius: const BorderRadius
                                                    .vertical(
                                                    top: Radius.circular(12)),
                                                child: Image.network(
                                                  "${subcategory[index].image}",
                                                  fit: BoxFit.fill,
                                                  loadingBuilder: (context,
                                                      child, loadingProgress) {
                                                    if (loadingProgress ==
                                                        null) {
                                                      return child;
                                                    }
                                                    return Image.asset(
                                                      'assets/images/mahakal.jpeg',
                                                      fit: BoxFit.cover,
                                                      width: double.infinity,
                                                      height: double.infinity,
                                                    );
                                                  },
                                                  errorBuilder: (context, error,
                                                          stackTrace) =>
                                                      Image.asset(
                                                    'assets/error_placeholder.png',
                                                    fit: BoxFit.cover,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),

                                          // Text Section
                                          Expanded(
                                            flex: 1,
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 8.0,
                                                      vertical: 6),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceEvenly,
                                                children: [
                                                  Text(
                                                    '${translateEn == 'en' ? subcategory[index].enName : subcategory[index].hiName}',
                                                    style: TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color: Colors
                                                          .orange.shade800,
                                                    ),
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                  Row(
                                                    children: [
                                                      Icon(Icons.access_time,
                                                          size: 14,
                                                          color: Colors
                                                              .grey.shade600),
                                                      const SizedBox(width: 4),
                                                      Flexible(
                                                        child: Text(
                                                          '${convertTimeToAmPm("${subcategory[index].openingTime}")} - ${convertTimeToAmPm("${subcategory[index].closeingTime}")}',
                                                          style: TextStyle(
                                                            fontSize: 12,
                                                            color: Colors
                                                                .grey.shade700,
                                                          ),
                                                          maxLines: 1,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),

                                      // VIP Badge - Only shown when vipDarshanStatus is 1
                                      if (subcategory[index].vipDarshanStatus ==
                                          1)
                                        Positioned(
                                          top: 8,
                                          right: 8,
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 6, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: Colors.amber[700],
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black
                                                      .withOpacity(0.1),
                                                  blurRadius: 3,
                                                  offset: const Offset(0, 1),
                                                )
                                              ],
                                            ),
                                            child: const Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(Icons.star,
                                                    color: Colors.white,
                                                    size: 12),
                                                SizedBox(width: 2),
                                                Text(
                                                  'VIP BOOKING',
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.bold,
                                                    letterSpacing: 0.5,
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
                        );
                      },
                    );
                  })
                ],
              ),
            ),
    );
  }
}
