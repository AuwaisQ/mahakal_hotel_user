// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:shimmer/shimmer.dart';
// import 'package:tdk_bouncingwidget/tdk_bouncingwidget.dart';
//
// import '../../../utill/app_constants.dart';
// import '../../pooja_booking/view/chadhavadetails.dart';
// import '../api_service/api_service.dart';
// import '../model/chadhawa_model.dart';
//
// class MandirChadhawa extends StatefulWidget {
//
//   final String id;
//   const MandirChadhawa({super.key, required this.id});
//
//   @override
//   State<MandirChadhawa> createState() => _MandirChadhawaState();
// }
//
// class _MandirChadhawaState extends State<MandirChadhawa> {
//
//
//   @override
//   void initState() {
//     super.initState();
//     getMandirChadhava();
//   }
//
//   bool isGridView = true;
//   bool gridList = false;
//   String translateEn = 'hi';
//
//   List<Chadhava> productModelList = <Chadhava>[];
//
//   Future<void> getMandirChadhava() async {
//     try {
//       // Fetch data from the API
//       var res = await ApiService().getData("${AppConstants.baseUrl}${AppConstants.mandirChadhavaUrl}${widget.id}");
//
//       print(res);
//
//       // Check if the response is not null
//       if (res != null) {
//         // Access "data" from the response
//         // var data = jsonEncode( res["data"]);
//         setState(() {
//           var data =  res["data"];
//
//           List productList = data["chadhava"];
//
//           productModelList.addAll(productList.map((e) => Chadhava.fromJson(e),));
//         });
//
//       } else {
//         print("API response is null.");
//       }
//     } catch (e) {
//       print("Error fetching data: $e");
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//
//       appBar: AppBar(
//         actions: [
//           BouncingWidgetInOut(
//             onPressed: () {
//               setState(() {
//                 gridList = !gridList;
//                 translateEn = gridList ? 'en' : 'hi';
//               });
//             },
//             bouncingType: BouncingType.bounceInAndOut,
//             child: Container(
//               height: 30,
//               width: 30,
//               decoration: BoxDecoration(
//                   borderRadius: BorderRadius.circular(4.0),
//                   color: gridList ? Colors.orange : Colors.white,
//                   border: Border.all(color: Colors.orange, width: 2)),
//               child: Center(
//                 child: Icon(Icons.translate,
//                     color: gridList ? Colors.white : Colors.orange),
//               ),
//             ),
//           ),
//
//           BouncingWidgetInOut(
//             onPressed: () {
//               setState(() {
//                 isGridView = !isGridView;
//               });
//             },
//             bouncingType: BouncingType.bounceInAndOut,
//             child: Container(
//               height: 30,
//               width: 30,
//               decoration: BoxDecoration(
//                   borderRadius: BorderRadius.circular(4.0),
//                   color: isGridView ? Colors.orange : Colors.white,
//                   border: Border.all(color: Colors.orange, width: 2)),
//               child: Center(
//                 child: Icon(isGridView ? Icons.list : Icons.grid_view,
//                     color: isGridView ? Colors.white : Colors.orange),
//               ),
//             ),
//           ),
//           const SizedBox(width: 10,)
//         ],
//         title: const Text("Mandir Chadhava",style: TextStyle(color: Colors.orange),),
//         centerTitle: true,
//       ),
//
//       body: SafeArea(child:
//
//           SingleChildScrollView(
//             child: Padding(
//               padding: const EdgeInsets.all(10),
//               child: Column(
//                 children: [
//
//                   if (isGridView) ListView.builder(
//                     itemCount: productModelList.length,
//                     physics: const BouncingScrollPhysics(),
//                     shrinkWrap: true,
//                     itemBuilder: (context, index) {
//                       // DateTime now = DateTime.now();
//                       // DateTime nextDate = findNextDate(now, "${allNivaranModelList[index].weekDays}");
//                       // String formattedDate = formatDate(nextDate);
//                       return GestureDetector(
//                           onTap: () {
//                             //Navigator.push(context, CupertinoPageRoute(builder: (context) => SliversExample(slugName:productModelList[index].slug.toString(), nextDatePooja: '${productModelList[index].nextPoojaDate}',),));
//                             Navigator.push(context, CupertinoPageRoute(builder: (context) => ChadhavaDetailView(idNumber:"${productModelList[index].id}", nextDatePooja: "${productModelList[index].nextChadhavaDate}",),));
//
//                           },
//                           child: Container(
//                             height: 430,
//                             margin: const EdgeInsets.all(8),
//                             decoration: BoxDecoration(
//                                 color: Colors.white,
//                                 borderRadius: BorderRadius.circular(10),
//                                 boxShadow: const [
//                                   BoxShadow(color: Colors.grey,
//                                       spreadRadius: 0.5,
//                                       blurRadius: 1.5,
//                                       offset: Offset(0, 0.5))
//                                 ]
//                             ),
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children:[
//                                 Stack(
//                                   children: [
//                                     Shimmer.fromColors(
//                                       baseColor: Colors.grey[300]!,
//                                       highlightColor: Colors.grey[100]!,
//                                       child: Container(
//                                         width: double.infinity,
//                                         height: 230.0, // Set appropriate height
//                                         decoration: const BoxDecoration(
//                                           borderRadius: BorderRadius.only(topLeft: Radius.circular(8.0),topRight: Radius.circular(8.0)),
//                                           color: Colors.white,
//                                         ),
//                                       ),
//                                     ),
//                                     ClipRRect(
//                                       borderRadius:const BorderRadius.only(topLeft: Radius.circular(8.0),topRight: Radius.circular(8.0)),
//                                       child: Image.network("${productModelList[index].thumbnail}",
//                                         fit: BoxFit.fill,
//                                         width: double.infinity,
//                                         height: 230.0, // Set appropriate height
//                                         loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
//                                           if (loadingProgress == null) {
//                                             // Once the image is fully loaded, stop the shimmer effect
//                                             return child;
//                                           } else {
//                                             // Continue showing shimmer while loading
//                                             return Stack(
//                                               children: [
//                                                 Shimmer.fromColors(
//                                                   baseColor: Colors.grey[300]!,
//                                                   highlightColor: Colors.grey[100]!,
//                                                   child: Container(
//                                                     width: double.infinity,
//                                                     height: 230.0,
//                                                     decoration: BoxDecoration(
//                                                       color: Colors.white,
//                                                       borderRadius: BorderRadius.circular(10),),
//                                                   ),
//                                                 ),
//                                               ],
//                                             );
//                                           }
//                                         },
//                                         errorBuilder: (context, error, stackTrace) {
//                                           // Show an error widget in case the image fails to load
//                                           return const Center(
//                                             child: Icon(Icons.error, color: Colors.red),
//                                           );
//                                         },
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//
//                                 Padding(
//                                   padding: const EdgeInsets.all(10.0),
//                                   child: Column(
//                                     crossAxisAlignment: CrossAxisAlignment.start,
//                                     children: [
//                                       Text(" ✤ ${translateEn == "en" ? productModelList[index].enName : productModelList[index].hiName}",style: const TextStyle(fontSize: 22,fontWeight: FontWeight.bold,fontFamily: 'Roboto',color: Colors.black,overflow: TextOverflow.ellipsis),maxLines: 1,),
//                                       Container(
//                                         margin: const EdgeInsets.symmetric(vertical: 4),
//                                         height: 2,
//                                         width: double.infinity,
//                                         decoration: const BoxDecoration(
//                                           gradient: LinearGradient(
//                                             colors: [
//                                               Colors.yellow, // Start color
//                                               Colors.red, // Start color
//                                               Colors.yellow, // End color
//                                             ],
//                                             begin: Alignment.topLeft, // Starting point of the gradient
//                                             end: Alignment.bottomRight, // Ending point of the gradient
//                                           ),
//                                         ),
//                                       ),
//                                       const SizedBox(height: 6,),
//                                       Text("${translateEn == "en" ? productModelList[index].enShortDetails : productModelList[index].hiShortDetails}",style: const TextStyle(fontSize: 16,fontFamily: 'Roboto',color: Colors.black87,overflow: TextOverflow.ellipsis),maxLines: 2,),
//
//                                       const SizedBox(height: 3,),
//                                       Row(
//                                         children: [
//                                           Icon(Icons.calendar_month,size: 18,color: Colors.orange,),
//                                           SizedBox(width: 6,),
//                                           Text( productModelList[index].nextChadhavaDate != null
//                                               ? DateFormat('dd-MMMM-yyyy').format(DateFormat('yyyy-MM-dd').parse("${productModelList[index].nextChadhavaDate}"))
//                                               : 'Date not available',
//                                             style: TextStyle(
//                                                 fontSize: 17,
//                                                 fontFamily: 'Roboto',
//                                                 color: Colors.black),
//                                           ),
//                                         ],
//                                       ),
//
//
//                                     ],
//                                   ),
//                                 ),
//                                 const Spacer(),
//                                 Container(
//                                   height: 45,
//                                   decoration: const BoxDecoration(
//                                       borderRadius: BorderRadius.only(bottomLeft: Radius.circular(8.0),bottomRight: Radius.circular(8.0)),
//                                       color: Colors.green
//                                   ),
//                                   child: const Row(
//                                     mainAxisAlignment: MainAxisAlignment.center,
//                                     children: [
//                                       Text("Book now",style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white,letterSpacing: 1,fontSize: 16),),
//                                       SizedBox(width: 6,),
//                                       Icon(Icons.arrow_circle_right,color: Colors.white,),
//                                     ],
//                                   ),
//                                 )
//                               ],
//                             ),
//                           )
//                       );
//                     },)
//                   else ListView.builder(
//                     itemCount: productModelList.length,
//                     physics: const BouncingScrollPhysics(),
//                     shrinkWrap: true,
//                     itemBuilder: (context, index) {
//                       DateTime now = DateTime.now();
//                       // DateTime nextDate = findNextDate(now, "${productModelList[index].weekDays}");
//                       // String formattedDate = formatDate(nextDate);
//                       return GestureDetector(
//                           onTap: () {
//                           //  Navigator.push(context, CupertinoPageRoute(builder: (context) => SliversExample(slugName:productModelList[index].slug.toString(), nextDatePooja: '${productModelList[index].nextPoojaDate}',),));
//                             Navigator.push(context, CupertinoPageRoute(builder: (context) => ChadhavaDetailView(idNumber:"${productModelList[index].id}", nextDatePooja: '${productModelList[index].nextChadhavaDate}',),));
//
//                           },
//                           child: Container(
//                             padding: const EdgeInsets.all(5),
//                             margin: const EdgeInsets.symmetric(horizontal: 10,vertical: 5),
//                             decoration:  BoxDecoration(
//                                 borderRadius: BorderRadius.circular(10),
//                                 border: Border.all(color:Colors.grey.shade300,width: 1.5)
//                             ),
//                             child: Row(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Expanded(
//                                   flex: 0,
//                                   child: Container(
//                                     height:80,
//                                     width: 120,
//                                     decoration: BoxDecoration(
//                                         color: Colors.grey.shade300,
//                                         borderRadius: BorderRadius.circular(6),
//                                         image: DecorationImage(image: NetworkImage("${productModelList[index].thumbnail}"),fit: BoxFit.fill)
//                                     ),
//                                   ),
//                                 ),
//                                 const SizedBox(width: 10,),
//                                 Expanded(
//                                   flex: 1,
//                                   child: Column(
//                                     mainAxisAlignment: MainAxisAlignment.start,
//                                     crossAxisAlignment: CrossAxisAlignment.start,
//                                     children: [
//                                       Text("${translateEn == "en" ? productModelList[index].enName : productModelList[index].hiName}",style: const TextStyle(fontSize: 20,fontWeight: FontWeight.bold,fontFamily: 'Roboto',color: Colors.black,overflow: TextOverflow.ellipsis),maxLines: 1,),
//
//                                       Row(
//                                         mainAxisAlignment: MainAxisAlignment.start,
//                                         children: [
//                                           const Expanded(
//                                               flex:0,
//                                               child: Icon(Icons.temple_buddhist,size: 18,color: Colors.orange,)),
//                                           const SizedBox(width: 6,),
//                                           Expanded(
//                                             child: Text("${translateEn == "en" ? productModelList[index].enShortDetails : productModelList[index].hiShortDetails}",style: const TextStyle(fontSize: 16,fontWeight: FontWeight.w500,fontFamily: 'Roboto',color: Colors.black),maxLines: 1,),
//                                           ),
//                                         ],
//                                       ),
//
//                                       Row(
//                                         children: [
//                                           Icon(Icons.calendar_month,size: 18,color: Colors.orange,),
//                                           SizedBox(width: 6,),
//                                           Text( productModelList[index].nextChadhavaDate != null
//                                               ? DateFormat('dd-MMMM-yyyy').format(DateFormat('yyyy-MM-dd').parse("${productModelList[index].nextChadhavaDate}"))
//                                               : 'Date not available',
//                                             style: TextStyle(
//                                                 fontSize: 17,
//                                                 fontFamily: 'Roboto',
//                                                 color: Colors.black),
//                                           ),
//                                         ],
//                                       ),
//
//                                     ],
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           )
//                       );
//                     },),
//
//                 ],
//               ),
//             ),
//           )
//       ),
//     );
//   }
// }
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import 'package:tdk_bouncingwidget/tdk_bouncingwidget.dart';
import '../../../utill/app_constants.dart';
import '../../pooja_booking/view/chadhavadetails.dart';
import '../api_service/api_service.dart';
import '../model/chadhawa_model.dart';

class MandirChadhawa extends StatefulWidget {
  final String id;
  const MandirChadhawa({super.key, required this.id});

  @override
  State<MandirChadhawa> createState() => _MandirChadhawaState();
}

class _MandirChadhawaState extends State<MandirChadhawa> {
  @override
  void initState() {
    super.initState();
    getMandirChadhava();
  }

  bool isGridView = true;
  bool gridList = false;
  String translateEn = 'hi';

  List<Chadhava> productModelList = <Chadhava>[];

  Future<void> getMandirChadhava() async {
    try {
      var res = await ApiService().getData(
          "${AppConstants.baseUrl}${AppConstants.mandirChadhavaUrl}${widget.id}");

      print(res);

      if (res != null) {
        setState(() {
          var data = res["data"];
          List productList = data["chadhava"];
          productModelList.addAll(productList.map((e) => Chadhava.fromJson(e)));
        });
      } else {
        print("API response is null.");
      }
    } catch (e) {
      print("Error fetching data: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          BouncingWidgetInOut(
            onPressed: () {
              setState(() {
                gridList = !gridList;
                translateEn = gridList ? 'en' : 'hi';
              });
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
          const SizedBox(
            width: 10,
          )
        ],
        title: const Text(
          "Mandir Chadhava",
          style: TextStyle(color: Colors.orange),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: isGridView
              ? GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 1,
                    childAspectRatio: 0.8,
                    mainAxisSpacing: 10,
                  ),
                  itemCount: productModelList.length,
                  shrinkWrap: true,
                  physics: const BouncingScrollPhysics(),
                  itemBuilder: (context, index) {
                    return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            CupertinoPageRoute(
                              builder: (context) => ChadhavaDetailView(
                                idNumber: "${productModelList[index].id}",
                                // nextDatePooja:
                                //     "${productModelList[index].nextChadhavaDate}",
                              ),
                            ),
                          );
                        },
                        child: Container(
                          height: 430,
                          margin: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: const [
                                BoxShadow(
                                    color: Colors.grey,
                                    spreadRadius: 0.5,
                                    blurRadius: 1.5,
                                    offset: Offset(0, 0.5))
                              ]),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Stack(
                                children: [
                                  Shimmer.fromColors(
                                    baseColor: Colors.grey[300]!,
                                    highlightColor: Colors.grey[100]!,
                                    child: Container(
                                      width: double.infinity,
                                      height: 230.0,
                                      decoration: const BoxDecoration(
                                        borderRadius: BorderRadius.only(
                                            topLeft: Radius.circular(8.0),
                                            topRight: Radius.circular(8.0)),
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                  ClipRRect(
                                    borderRadius: const BorderRadius.only(
                                        topLeft: Radius.circular(8.0),
                                        topRight: Radius.circular(8.0)),
                                    child: Image.network(
                                      productModelList[index].thumbnail,
                                      fit: BoxFit.fill,
                                      width: double.infinity,
                                      height: 230.0,
                                      loadingBuilder: (BuildContext context,
                                          Widget child,
                                          ImageChunkEvent? loadingProgress) {
                                        if (loadingProgress == null) {
                                          return child;
                                        } else {
                                          return Stack(
                                            children: [
                                              Shimmer.fromColors(
                                                baseColor: Colors.grey[300]!,
                                                highlightColor:
                                                    Colors.grey[100]!,
                                                child: Container(
                                                  width: double.infinity,
                                                  height: 230.0,
                                                  decoration: BoxDecoration(
                                                    color: Colors.white,
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
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                        return const Center(
                                          child: Icon(Icons.error,
                                              color: Colors.red),
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                              Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      " ✤ ${translateEn == "en" ? productModelList[index].enName : productModelList[index].hiName}",
                                      style: const TextStyle(
                                          fontSize: 22,
                                          fontWeight: FontWeight.bold,
                                          fontFamily: 'Roboto',
                                          color: Colors.black,
                                          overflow: TextOverflow.ellipsis),
                                      maxLines: 1,
                                    ),
                                    Container(
                                      margin: const EdgeInsets.symmetric(
                                          vertical: 4),
                                      height: 2,
                                      width: double.infinity,
                                      decoration: const BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            Colors.yellow,
                                            Colors.red,
                                            Colors.yellow,
                                          ],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 6,
                                    ),
                                    Text(
                                      translateEn == "en"
                                          ? productModelList[index]
                                              .enShortDetails
                                          : productModelList[index]
                                              .hiShortDetails,
                                      style: const TextStyle(
                                          fontSize: 16,
                                          fontFamily: 'Roboto',
                                          color: Colors.black87,
                                          overflow: TextOverflow.ellipsis),
                                      maxLines: 2,
                                    ),
                                    const SizedBox(
                                      height: 3,
                                    ),
                                    Row(
                                      children: [
                                        const Icon(Icons.calendar_month,
                                            size: 18, color: Colors.orange),
                                        const SizedBox(
                                          width: 6,
                                        ),
                                        Text(
                                          productModelList[index]
                                                      .nextChadhavaDate !=
                                                  null
                                              ? DateFormat('dd-MMMM-yyyy').format(
                                                  DateFormat('yyyy-MM-dd').parse(
                                                      "${productModelList[index].nextChadhavaDate}"))
                                              : 'Date not available',
                                          style: const TextStyle(
                                              fontSize: 17,
                                              fontFamily: 'Roboto',
                                              color: Colors.black),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              const Spacer(),
                              Container(
                                height: 45,
                                decoration: const BoxDecoration(
                                  borderRadius: BorderRadius.only(
                                      bottomLeft: Radius.circular(8.0),
                                      bottomRight: Radius.circular(8.0)),
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.orange, // Start color
                                      Colors.red, // Start color
                                      Colors.orange, // End color
                                    ],
                                    begin: Alignment
                                        .topLeft, // Starting point of the gradient
                                    end: Alignment
                                        .bottomRight, // Ending point of the gradient
                                  ),
                                ),
                                child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      "Book now",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                          letterSpacing: 1,
                                          fontSize: 16),
                                    ),
                                    SizedBox(
                                      width: 6,
                                    ),
                                    Icon(Icons.arrow_circle_right,
                                        color: Colors.white),
                                  ],
                                ),
                              )
                            ],
                          ),
                        ));
                  },
                )
              : ListView.builder(
                  itemCount: productModelList.length,
                  physics: const BouncingScrollPhysics(),
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            CupertinoPageRoute(
                              builder: (context) => ChadhavaDetailView(
                                idNumber: "${productModelList[index].id}",
                                // nextDatePooja:
                                //     '${productModelList[index].nextChadhavaDate}',
                              ),
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.all(5),
                          margin: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                  color: Colors.grey.shade300, width: 1.5)),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                flex: 0,
                                child: Container(
                                  height: 80,
                                  width: 120,
                                  decoration: BoxDecoration(
                                      color: Colors.grey.shade300,
                                      borderRadius: BorderRadius.circular(6),
                                      image: DecorationImage(
                                          image: NetworkImage(
                                              productModelList[index]
                                                  .thumbnail),
                                          fit: BoxFit.fill)),
                                ),
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              Expanded(
                                flex: 1,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      translateEn == "en"
                                          ? productModelList[index].enName
                                          : productModelList[index].hiName,
                                      style: const TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          fontFamily: 'Roboto',
                                          color: Colors.black,
                                          overflow: TextOverflow.ellipsis),
                                      maxLines: 1,
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        const Expanded(
                                          flex: 0,
                                          child: Icon(Icons.temple_buddhist,
                                              size: 18, color: Colors.orange),
                                        ),
                                        const SizedBox(
                                          width: 6,
                                        ),
                                        Expanded(
                                          child: Text(
                                            translateEn == "en"
                                                ? productModelList[index]
                                                    .enShortDetails
                                                : productModelList[index]
                                                    .hiShortDetails,
                                            style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w500,
                                                fontFamily: 'Roboto',
                                                color: Colors.black),
                                            maxLines: 1,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        const Icon(Icons.calendar_month,
                                            size: 18, color: Colors.orange),
                                        const SizedBox(
                                          width: 6,
                                        ),
                                        Text(
                                          productModelList[index]
                                                      .nextChadhavaDate !=
                                                  null
                                              ? DateFormat('dd-MMMM-yyyy').format(
                                                  DateFormat('yyyy-MM-dd').parse(
                                                      "${productModelList[index].nextChadhavaDate}"))
                                              : 'Date not available',
                                          style: const TextStyle(
                                              fontSize: 17,
                                              fontFamily: 'Roboto',
                                              color: Colors.black),
                                        ),
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
        ),
      ),
    );
  }
}
