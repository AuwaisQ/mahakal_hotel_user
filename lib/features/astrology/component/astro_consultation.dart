import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mahakal/utill/app_constants.dart';
import 'package:tdk_bouncingwidget/tdk_bouncingwidget.dart';

import '../../../data/datasource/remote/http/httpClient.dart';
import '../model/astro_banner_model.dart';
import '../model/consultation_model.dart';
import 'astrodetailspage.dart';

class AstroConsultationView extends StatefulWidget {
  const AstroConsultationView({super.key});

  @override
  State<AstroConsultationView> createState() => _AstroConsultationViewState();
}

class _AstroConsultationViewState extends State<AstroConsultationView> {
  @override
  void initState() {
    super.initState();
    getConsultaionData();
    getBannerdata();
  }

  List<Astroconsultant> consultaionModelList = <Astroconsultant>[];
  List<AstroBannerModel> bannerModelList = <AstroBannerModel>[];

  bool translateBtn = true;
  bool gridList = true;
  String firstImageUrl = '';

  void getConsultaionData() async {
    var res = await HttpService().getApi(AppConstants.consultaionUrl);
    if (res["status"] == 200) {
      setState(() {
        consultaionModelList.clear();
        List consultationList = res['data'];
        consultaionModelList
            .addAll(consultationList.map((e) => Astroconsultant.fromJson((e))));
      });
      print(res);
    } else {
      print("Failed Api Response");
    }
    setState(() {});
  }

  void getBannerdata() async {
    var res = await HttpService().getApi(AppConstants.eventBannersUrl);
    setState(() {
      bannerModelList.clear();
      List bannerList = res;
      List<AstroBannerModel> filteredList = bannerList
          .where((e) => e["resource_type"] == "astrology")
          .map((e) => AstroBannerModel.fromJson(e))
          .toList();

      // Add filtered banners to the list
      bannerModelList.addAll(filteredList);
      print(bannerModelList.length);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          BouncingWidgetInOut(
            onPressed: () {
              setState(() {
                translateBtn = !translateBtn;
              });
            },
            bouncingType: BouncingType.bounceInAndOut,
            child: Container(
              height: 30,
              width: 30,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4.0),
                  color: translateBtn ? Colors.white : Colors.orange,
                  border: Border.all(color: Colors.orange, width: 2)),
              child: Center(
                child: Icon(Icons.translate,
                    color: translateBtn ? Colors.orange : Colors.white),
              ),
            ),
          ),
          BouncingWidgetInOut(
            onPressed: () {
              setState(() {
                gridList = !gridList;
              });
            },
            bouncingType: BouncingType.bounceInAndOut,
            child: Container(
              height: 30,
              width: 30,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4.0),
                  color: gridList ? Colors.white : Colors.orange,
                  border: Border.all(color: Colors.orange, width: 2)),
              child: Center(
                child: Icon(Icons.grid_view,
                    color: gridList ? Colors.orange : Colors.white),
              ),
            ),
          ),
        ],
        title: const Text(
          "Astrology Consultation",
          style: TextStyle(color: Colors.orange),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(
                height: 10,
              ),
              CarouselSlider(
                options: CarouselOptions(
                    height: 180.0,
                    enableInfiniteScroll: true,
                    animateToClosest: true,
                    autoPlay: true,
                    autoPlayAnimationDuration:
                        const Duration(milliseconds: 600)),
                items: bannerModelList.map((i) {
                  return Builder(
                    builder: (BuildContext context) {
                      return Container(
                        margin: const EdgeInsets.all(4),
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade400,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.orange),
                          image: DecorationImage(
                              image: NetworkImage(
                                  "${AppConstants.imagesUrl}${i.photo}"),
                              fit: BoxFit.cover),
                        ),
                      );
                    },
                  );
                }).toList(),
              ),
              const SizedBox(
                height: 10,
              ),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 10),
                padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 6),
                decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(4.0)),
                child: Row(
                  children: [
                    Container(
                      height: 20,
                      width: 3,
                      color: Colors.orange,
                    ),
                    const SizedBox(
                      width: 5,
                    ),
                    const Text(
                      "Astrology Consultation",
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black),
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              gridList
                  ? GridView.builder(
                      shrinkWrap: true,
                      physics: const BouncingScrollPhysics(),
                      itemCount: consultaionModelList.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 4.0,
                          mainAxisSpacing: 4.0,
                          childAspectRatio:
                              MediaQuery.of(context).size.aspectRatio * 1.70),
                      itemBuilder: (BuildContext context, int index) {
                        firstImageUrl = consultaionModelList[index].images![0];
                        return InkWell(
                          onTap: () {
                            Navigator.push(
                                context,
                                CupertinoPageRoute(
                                    builder: (context) => AstroDetailsView(
                                        productId:
                                            consultaionModelList[index].id!,
                                        isProduct: true)));
                          },
                          child: Container(
                            margin: const EdgeInsets.all(5),
                            width: 120,
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8.0),
                                boxShadow: [
                                  BoxShadow(
                                      color: Colors.black.withOpacity(0.4),
                                      blurRadius: 7,
                                      offset: const Offset(0, 6))
                                ]),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Expanded(
                                  flex: 1,
                                  child: Container(
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(8),
                                        color: Colors.grey.shade300),
                                    child: ClipRRect(
                                        borderRadius: const BorderRadius.only(
                                            topRight: Radius.circular(8),
                                            topLeft: Radius.circular(8)),
                                        child: Image.network(
                                          firstImageUrl,
                                          fit: BoxFit.cover,
                                        )),
                                  ),
                                ),
                                Expanded(
                                  flex: 0,
                                  child: Container(
                                    width: double.infinity,
                                    decoration: const BoxDecoration(
                                        color: Colors.orange),
                                    child: Center(
                                        child: Text(
                                      " - ${consultaionModelList[index].counsellingMainPrice! - consultaionModelList[index].counsellingSellingPrice!} ₹",
                                      style: const TextStyle(
                                          color: Colors.white, fontSize: 18),
                                    )),
                                  ),
                                ),

                                Expanded(
                                  flex: 1,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 5.0),
                                    child: Column(
                                      children: [
                                        const SizedBox(
                                          height: 10,
                                        ),
                                        Expanded(
                                            child: Text(
                                          '${translateBtn ? consultaionModelList[index].hiName : consultaionModelList[index].enName} ',
                                          style: const TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          textAlign: TextAlign.center,
                                        )),
                                        Text(
                                          '${consultaionModelList[index].counsellingMainPrice} ₹',
                                          style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.grey,
                                              decoration:
                                                  TextDecoration.lineThrough),
                                        ),
                                        Text(
                                            '${consultaionModelList[index].counsellingSellingPrice} ₹',
                                            style: const TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.orange))
                                      ],
                                    ),
                                  ),
                                ),
                                // Text.rich(
                                //     TextSpan(
                                //         children: [
                                //           TextSpan(
                                //               text:'₹1500 ',style: TextStyle(fontSize: 14,fontWeight: FontWeight.bold,color:Colors.blue)
                                //           ),
                                //           TextSpan(
                                //               text:'₹2999',style: TextStyle(fontSize: 14,fontWeight: FontWeight.bold,color: Colors.grey,decoration: TextDecoration.lineThrough)
                                //           ),
                                //         ]
                                //     )
                                // )
                              ],
                            ),
                          ),
                        );
                      },
                    )
                  : ListView.builder(
                      itemCount: consultaionModelList.length,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemBuilder: (context, index) {
                        firstImageUrl = consultaionModelList[index].images![0];
                        return InkWell(
                          onTap: () {
                            Navigator.push(
                                context,
                                CupertinoPageRoute(
                                    builder: (context) => AstroDetailsView(
                                        productId:
                                            consultaionModelList[index].id!,
                                        isProduct: true)));
                          },
                          child: Container(
                            margin: const EdgeInsets.all(5),
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8.0),
                                border: Border.all(
                                    color: Colors.grey.shade300, width: 2)),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Expanded(
                                  flex: 1,
                                  child: Container(
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(8),
                                        color: Colors.grey.shade300),
                                    child: ClipRRect(
                                        borderRadius: const BorderRadius.only(
                                            topLeft: Radius.circular(8),
                                            bottomLeft: Radius.circular(8)),
                                        child: Image.network(
                                          firstImageUrl,
                                          fit: BoxFit.cover,
                                        )),
                                  ),
                                ),

                                Expanded(
                                  flex: 1,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 5.0),
                                    child: Column(
                                      children: [
                                        Text(
                                          '${translateBtn ? consultaionModelList[index].hiName : consultaionModelList[index].enName} ',
                                          style: const TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          textAlign: TextAlign.center,
                                        ),
                                        Text(
                                          '${consultaionModelList[index].counsellingMainPrice} ₹',
                                          style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.grey,
                                              decoration:
                                                  TextDecoration.lineThrough),
                                        ),
                                        Text(
                                            '${consultaionModelList[index].counsellingSellingPrice} ₹',
                                            style: const TextStyle(
                                                fontSize: 22,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.orange))
                                      ],
                                    ),
                                  ),
                                ),
                                Container(
                                  margin: const EdgeInsets.only(
                                      right: 5.0, top: 60.0),
                                  padding: const EdgeInsets.all(1),
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.orange,
                                  ),
                                  child: const Icon(
                                    Icons.arrow_circle_right,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                                // Text.rich(
                                //     TextSpan(
                                //         children: [
                                //           TextSpan(
                                //               text:'₹1500 ',style: TextStyle(fontSize: 14,fontWeight: FontWeight.bold,color:Colors.blue)
                                //           ),
                                //           TextSpan(
                                //               text:'₹2999',style: TextStyle(fontSize: 14,fontWeight: FontWeight.bold,color: Colors.grey,decoration: TextDecoration.lineThrough)
                                //           ),
                                //         ]
                                //     )
                                // )
                              ],
                            ),
                          ),
                        );
                      }),
            ],
          ),
        ),
      ),
    );
  }
}
