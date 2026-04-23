// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:mahakal/data/datasource/remote/http/httpClient.dart';
// import 'package:mahakal/features/tour_and_travells/view/TourDetails.dart';
// import 'package:mahakal/utill/app_constants.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import '../model/tour_search_model.dart';
//
//
// class TourSearchScreen extends StatefulWidget {
//
//   final String recentName;
//   const TourSearchScreen({super.key, required this.recentName});
//
//   @override
//   State<TourSearchScreen> createState() => _TourSearchScreenState();
// }
//
// class _TourSearchScreenState extends State<TourSearchScreen> {
//
//   @override
//   void initState() {
//     super.initState();
//     searchController.text = widget.recentName;
//     getSearchData(widget.recentName);
//     _loadRecentSearches();
//   }
//
//   bool isTranslate = true;
//   List<String> _recentSearches = ["Ujjain","Indore","Omkareshwar","Mahakaleshwar"];
//   List<TourSearchData> tourSearchModel = <TourSearchData>[];
//   List<Map<String, dynamic>> filteredList = [];
//
//   TextEditingController searchController = TextEditingController();
//   void getSearchData(String query) async {
//     try {
//       var res = await HttpService().postApi(
//         AppConstants.tourSearchUrl,
//         {
//           "name": query, // Use the controller value directly
//         },
//       );
//
//       // Clear previous data
//       //tourSearchModel.clear();
//
//       // Parse API response with null checks
//       List tourList = res["data"] ?? [];
//
//       // Populate model lists
//       tourSearchModel.addAll(tourList.map((e) => TourSearchData.fromJson(e)));
//
//       // Combine all into a single list
//       filteredList.clear();
//       filteredList.addAll(tourSearchModel.map((e) => {
//         "name": e.name,
//         "id": e.id,
//       }));
//
//       print("API response: $filteredList");
//
//       // Update UI
//       // filterList(query);
//       setState(() {});
//     } catch (e) {
//       // Handle any exceptions
//       print("Error fetching search data: $e");
//     }
//   }
//
//   // Load recent searches from SharedPreferences
//   Future<void> _loadRecentSearches() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     setState(() {
//       _recentSearches = prefs.getStringList('recentSearches') ?? [];
//     });
//   }
//
//   // Save a search term to SharedPreferences
//   Future<void> _saveSearch(String term) async {
//     if (term.isEmpty) return;
//
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     _recentSearches.add(term);
//
//     // Remove duplicates and limit the number of saved searches
//     _recentSearches = _recentSearches.toSet().toList();
//     if (_recentSearches.length > 10) {
//       _recentSearches = _recentSearches.sublist(0, 10);
//     }
//
//     await prefs.setStringList('recentSearches', _recentSearches);
//     setState(() {});
//   }
//
//   // Remove a search term from the list and SharedPreferences
//   Future<void> _removeSearch(int index) async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     _recentSearches.removeAt(index);
//     await prefs.setStringList('recentSearches', _recentSearches);
//     setState(() {});
//   }
//
//   // Perform the search and save the term
//   void _performSearch(String term) {
//     _saveSearch(term);
//     searchController.clear();
//     print('Performing search for: $term');
//   }
//
//   void routeScreeen(String id){
//       Navigator.push(context, CupertinoPageRoute(builder: (context) => TourDetails(productId: id,)));
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     var screenHeight = MediaQuery.of(context).size.height;
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Tour Search",style: TextStyle(color: Colors.blue),),
//         centerTitle: true,
//       ),
//       body: SafeArea(
//         child: SingleChildScrollView(
//           child: Padding(
//             padding: const EdgeInsets.all(10.0),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 TextFormField(
//                   controller: searchController,
//                   onChanged: (value) => getSearchData(value),
//                   decoration: InputDecoration(
//                       hintText: 'Search',
//                       hintStyle: TextStyle(color: Colors.grey),
//                       suffixIcon: InkWell(
//                           onTap: () {
//                             setState(() {
//                               searchController.clear();
//                               filteredList.clear();
//                             });
//                           },
//                           child: Icon(Icons.close)),
//                       prefixIcon: Icon(Icons.search),
//                       border: OutlineInputBorder(
//                         borderSide: BorderSide(color: Colors.black, width: 2.0),
//                         borderRadius: BorderRadius.circular(30.0),
//                       ),
//                       enabledBorder: OutlineInputBorder(
//                         borderSide: BorderSide(color: Colors.black, width: 2.0),
//                         borderRadius: BorderRadius.circular(30.0),
//                       )),
//                 ),
//                 SizedBox(
//                   height: 10,
//                 ),
//                 Padding(
//                   padding: const EdgeInsets.all(8.0),
//                   child: Row(
//                     children: [
//                       Container(
//                         color: Colors.blue,
//                         height: 18,
//                         width: 3,
//                       ),
//                       SizedBox(
//                         width: 8,
//                       ),
//                       Text(
//                         "Recent's",
//                         style: TextStyle(
//                             fontSize: 18, fontWeight: FontWeight.bold),
//                       )
//                     ],
//                   ),
//                 ),
//                 ListView.builder(
//                     physics: NeverScrollableScrollPhysics(),
//                     shrinkWrap: true,
//                     itemCount: _recentSearches.length > 3 ? 3 : _recentSearches.length,
//                     itemBuilder: (context, index) {
//                       final reversedIndex = _recentSearches.length - 1 - index;
//                       return Column(
//                         children: [
//                           InkWell(
//                             onTap : (){
//                               setState(() {
//                                 searchController.clear();
//                                 searchController.text = _recentSearches[reversedIndex];
//                               });
//                               getSearchData(_recentSearches[reversedIndex]);
//                               // _performSearch(_recentSearches[reversedIndex]);
//                             },
//                             child: Padding(
//                               padding: const EdgeInsets.all(8.0),
//                               child: Row(
//                                 children: [
//                                   Expanded(
//                                     flex: 0,
//                                     child: Icon(
//                                       Icons.history,
//                                       color: Colors.black,
//                                       size: 24,
//                                     ),
//                                   ),
//                                   SizedBox(
//                                     width: 10,
//                                   ),
//                                   Expanded(
//                                     flex: 1,
//                                     child: Text(_recentSearches[reversedIndex],
//                                       style: const TextStyle(
//                                         fontSize: 18,
//                                         color: Colors.black,
//                                       ),
//                                     ),
//                                   ),
//                                   Spacer(),
//                                   InkWell(
//                                     onTap:(){
//                                       _removeSearch(reversedIndex);
//                                     },
//                                     child: Icon(
//                                       Icons.close,
//                                       color: Colors.black,
//                                       size: 24,
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           ),
//                           Divider(
//                             color: Colors.grey.shade400,
//                           ),
//                         ],
//                       );
//                     }),
//
//                 SizedBox(height: 10,),
//                 Padding(
//                   padding: const EdgeInsets.all(8.0),
//                   child: Row(
//                     children: [
//                       Container(
//                         color: Colors.blue,
//                         height: 18,
//                         width: 3,
//                       ),
//                       SizedBox(
//                         width: 8,
//                       ),
//                       Text(
//                         "Search Result's",
//                         style: TextStyle(
//                             fontSize: 18, fontWeight: FontWeight.bold),
//                       )
//                     ],
//                   ),
//                 ),
//                 ListView.builder(
//                     physics: NeverScrollableScrollPhysics(),
//                     shrinkWrap: true,
//                     itemCount: filteredList.length,
//                     itemBuilder: (context, index) {
//                       final item = filteredList[index];
//                       return Column(
//                         children: [
//                           InkWell(
//                             onTap: () {
//                               print(item['id']);
//                               print(item['type']);
//                               routeScreeen("${item['id']}",);
//                               _performSearch(searchController.text.trim());
//                               _performSearch;
//                               filteredList.clear();
//                               searchController.clear();
//                             },
//                             child: Padding(
//                               padding: const EdgeInsets.all(8.0),
//                               child: Row(
//                                 children: [
//                                   Expanded(
//                                     flex: 0,
//                                     child: Icon(
//                                       Icons.location_pin,
//                                       color: Colors.black,
//                                       size: 24,
//                                     ),
//                                   ),
//                                   SizedBox(
//                                     width: 10,
//                                   ),
//                                   Expanded(
//                                     flex: 1,
//                                     child: Text("${item['name']}",
//                                       style: const TextStyle(
//                                         fontSize: 18,
//                                         color: Colors.black,
//                                       ),
//                                     ),
//                                   )
//                                 ],
//                               ),
//                             ),
//                           ),
//                           Divider(
//                             color: Colors.grey.shade400,
//                           ),
//                         ],
//                       );
//                     }),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mahakal/data/datasource/remote/http/httpClient.dart';
import 'package:mahakal/features/tour_and_travells/view/TourDetails.dart';
import 'package:mahakal/utill/app_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../model/tour_search_model.dart';

class TourSearchScreen extends StatefulWidget {
  final String recentName;
  const TourSearchScreen({super.key, required this.recentName});

  @override
  State<TourSearchScreen> createState() => _TourSearchScreenState();
}

class _TourSearchScreenState extends State<TourSearchScreen> {
  bool isTranslate = true;
  List<String> _recentSearches = [
    "Ujjain",
    "Indore",
    "Omkareshwar",
    "Mahakaleshwar"
  ];
  List<TourSearchData> tourSearchModel = <TourSearchData>[];
  List<Map<String, dynamic>> filteredList = [];

  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    searchController.text = widget.recentName;
    getSearchData(widget.recentName);
    _loadRecentSearches();
  }

  // Fetch search data from API
  void getSearchData(String query) async {
    try {
      var res = await HttpService().postApi(
        AppConstants.tourSearchUrl,
        {
          "name": query,
        },
      );

      List tourList = res["data"] ?? [];
      tourSearchModel =
          tourList.map((e) => TourSearchData.fromJson(e)).toList();

      filteredList.clear();
      filteredList.addAll(tourSearchModel.map((e) => {
            "name": e.name,
            "id": e.id,
          }));

      setState(() {});
    } catch (e) {
      print("Error fetching search data: $e");
    }
  }

  // Load recent searches from SharedPreferences
  Future<void> _loadRecentSearches() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? savedSearches = prefs.getStringList('recentSearches');

    setState(() {
      if (savedSearches != null && savedSearches.isNotEmpty) {
        _recentSearches = savedSearches;
      }
    });
  }

  // Save a search term to SharedPreferences
  Future<void> _saveSearch(String term) async {
    if (term.trim().isEmpty) return;

    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Remove duplicate if exists
    _recentSearches.remove(term);

    // Add at the top
    _recentSearches.insert(0, term);

    // Limit max recent searches to 10
    if (_recentSearches.length > 10) {
      _recentSearches = _recentSearches.sublist(0, 10);
    }

    await prefs.setStringList('recentSearches', _recentSearches);
    setState(() {});
  }

  // Remove a search term from recent list
  Future<void> _removeSearch(int index) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _recentSearches.removeAt(index);
    await prefs.setStringList('recentSearches', _recentSearches);
    setState(() {});
  }

  // Perform search and save term
  void _performSearch(String term) {
    _saveSearch(term);
    getSearchData(term);
  }

  void routeScreen(String id) {
    Navigator.push(
      context,
      CupertinoPageRoute(builder: (context) => TourDetails(productId: id)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            const Text("Tour Search", style: TextStyle(color: Colors.blue)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 🔍 Search Box
                TextFormField(
                  controller: searchController,
                  onChanged: (value) => getSearchData(value),
                  decoration: InputDecoration(
                    hintText: 'Search',
                    hintStyle: const TextStyle(color: Colors.grey),
                    suffixIcon: InkWell(
                      onTap: () {
                        setState(() {
                          searchController.clear();
                          filteredList.clear();
                        });
                      },
                      child: const Icon(Icons.close),
                    ),
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderSide:
                          const BorderSide(color: Colors.black, width: 2.0),
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide:
                          const BorderSide(color: Colors.black, width: 2.0),
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                  ),
                ),
                const SizedBox(height: 15),

                // 🕑 Recent Searches Header
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Container(color: Colors.blue, height: 18, width: 3),
                      const SizedBox(width: 8),
                      const Text(
                        "Recent Searches",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),

                // 🕑 Recent Searches List
                ListView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount:
                      _recentSearches.length > 3 ? 3 : _recentSearches.length,
                  itemBuilder: (context, index) {
                    return Column(
                      children: [
                        InkWell(
                          onTap: () {
                            searchController.text = _recentSearches[index];
                            _performSearch(_recentSearches[index]);
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              children: [
                                const Icon(Icons.history,
                                    color: Colors.black, size: 24),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    _recentSearches[index],
                                    style: const TextStyle(
                                        fontSize: 18, color: Colors.black),
                                  ),
                                ),
                                InkWell(
                                  onTap: () => _removeSearch(index),
                                  child: const Icon(Icons.close,
                                      color: Colors.black, size: 24),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Divider(color: Colors.grey.shade400),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 10),

                // 🔎 Search Results Header
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Container(color: Colors.blue, height: 18, width: 3),
                      const SizedBox(width: 8),
                      const Text(
                        "Search Results",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),

                // 🔎 Search Results List
                ListView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: filteredList.length,
                  itemBuilder: (context, index) {
                    final item = filteredList[index];
                    return Column(
                      children: [
                        InkWell(
                          onTap: () {
                            routeScreen("${item['id']}");
                            _performSearch(searchController.text.trim());
                            searchController.clear();
                            filteredList.clear();
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              children: [
                                const Icon(Icons.location_pin,
                                    color: Colors.black, size: 24),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    "${item['name']}",
                                    style: const TextStyle(
                                        fontSize: 18, color: Colors.black),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Divider(color: Colors.grey.shade400),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
