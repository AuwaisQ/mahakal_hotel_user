import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mahakal/features/blogs_module/Controller/language_provider.dart';
import 'package:provider/provider.dart';
import '../../../data/datasource/remote/http/httpClient.dart';
import '../../../utill/app_constants.dart';
import '../model/offline_subcategory.dart';
import 'offline_details.dart';

class OfflineViewScreen extends StatefulWidget {
  final String categoryId;

  const OfflineViewScreen({super.key, required this.categoryId});

  @override
  State<OfflineViewScreen> createState() => _OfflineViewScreenState();
}

class _OfflineViewScreenState extends State<OfflineViewScreen> {
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    getSubCategory();
  }

  List<OfflinePoojaList> subCategoryList = [];

  Future<void> getSubCategory() async {
    setState(() {
      isLoading = true;
    });

    try {
      final url = "${AppConstants.panditSubCategoryUrl}${widget.categoryId}";

      final res = await HttpService().getApi(url); // ✅ Replaced here

      print(res);

      if (res != null) {
        final offlineSubData = OfflineSubCategoryModel.fromJson(res);
        setState(() {
          subCategoryList = offlineSubData.poojaList;
        });
      }
    } catch (e) {
      print("Error in offline subcategory: $e");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(
              color: Colors.orange,
            ))
          : Padding(
              padding: const EdgeInsets.all(8.0),
              child: Consumer<BlogLanguageProvider>(
                builder:
                    (BuildContext context, languageProvider, Widget? child) {
                  return subCategoryList.isNotEmpty
                      ? GridView.builder(
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                            childAspectRatio: 0.8,
                          ),
                          itemCount: subCategoryList.length,
                          itemBuilder: (context, index) {
                            return InkWell(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    CupertinoPageRoute(
                                      builder: (context) => OfflinePoojaDetails(
                                        slugName: subCategoryList[index].slug,
                                      ),
                                    ));
                              },
                              child: Card(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                elevation: 5,
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        flex: 1,
                                        child: SizedBox(
                                          height: 105,
                                          width: double.infinity,
                                          child: ClipRRect(
                                              borderRadius:
                                                  const BorderRadius.only(
                                                      topLeft:
                                                          Radius.circular(4),
                                                      topRight:
                                                          Radius.circular(4)),
                                              child: Image.network(
                                                subCategoryList[index]
                                                    .thumbnail,
                                                fit: BoxFit.fill,
                                              )),
                                        ),
                                      ),

                                      // ClipRRect(
                                      //   borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                                      //   child: Image.network(
                                      //     subCategoryList[0].thumbnail ?? '',
                                      //     height: 120,
                                      //     width: double.infinity,
                                      //     fit: BoxFit.cover,
                                      //   ),
                                      // ),
                                      Expanded(
                                        flex: 0,
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const SizedBox(height: 4),
                                            Text(
                                              languageProvider.isEnglish
                                                  ? subCategoryList[index]
                                                          .enName ??
                                                      ''
                                                  : subCategoryList[index]
                                                          .hiName ??
                                                      '',
                                              style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.orange,
                                                  overflow:
                                                      TextOverflow.ellipsis),
                                              maxLines: 1,
                                            ),
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    languageProvider.isEnglish
                                                        ? subCategoryList[index]
                                                                .enShortBenifits ??
                                                            ''
                                                        : subCategoryList[index]
                                                                .hiShortBenifits ??
                                                            '',
                                                    style: TextStyle(
                                                        fontSize: 12,
                                                        color: Colors.grey[800],
                                                        fontWeight:
                                                            FontWeight.w500),
                                                    maxLines: 2,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ),
                                                const Icon(
                                                  CupertinoIcons
                                                      .arrow_right_circle,
                                                  color: Colors.orange,
                                                )
                                              ],
                                            ),
                                            // InkWell(
                                            //   onTap: (){
                                            //     Navigator.push(context, CupertinoPageRoute(builder: (context) => OfflinePoojaDetails(slugName: '${subCategoryList[index].slug}',),));
                                            //   },
                                            //   child: Container(
                                            //     padding: EdgeInsets.all(5),
                                            //     decoration: BoxDecoration(
                                            //         borderRadius: BorderRadius.circular(5),
                                            //         color: Colors.deepOrange
                                            //     ),
                                            //     child: Center(
                                            //       child: Row(
                                            //         children: [
                                            //           Text("Book Now",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 16,color: Colors.white),),
                                            //           Spacer(),
                                            //           Icon(Icons.arrow_circle_right,color: Colors.white,)
                                            //         ],
                                            //       ),
                                            //     ),
                                            //   ),
                                            // )
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        )
                      : const Center(child: Text("No Data"));
                },
              ),
            ),
    );
  }
}
