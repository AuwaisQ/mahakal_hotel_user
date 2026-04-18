import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mahakal/data/datasource/remote/http/httpClient.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../model/poojasearch_model.dart';
import '../anushthandetail.dart';
import '../chadhavadetails.dart';
import '../silvertabbar.dart';
import '../vipdetails.dart';

class PoojaSearchScreen extends StatefulWidget {
  const PoojaSearchScreen({super.key});

  @override
  State<PoojaSearchScreen> createState() => _PoojaSearchScreenState();
}

class _PoojaSearchScreenState extends State<PoojaSearchScreen> {
  @override
  void initState() {
    super.initState();
    getSearchData("");
    _loadRecentSearches();
  }

  bool isTranslate = true;
  List<String> _recentSearches = [];
  List<PoojaServices> poojaSearchModel = <PoojaServices>[];
  List<Anushthan> anushthanSearchModel = <Anushthan>[];
  List<Vippooja> vipSearchModel = <Vippooja>[];
  List<Chadhava> chadhavaSearchModel = <Chadhava>[];
  List<Map<String, dynamic>> combinedList = [];
  List<Map<String, dynamic>> filteredList = [];

  final TextEditingController searchController = TextEditingController();
  void getSearchData(String query) async {
    try {
      // Ensure the base URL and endpoint are properly concatenated
      String url = "/api/v1/pooja/search-pooja";
      var res = await HttpService().postApi(
        url,
        {
          "search": query, // Use the controller value directly
        },
      );

      // Clear previous data
      poojaSearchModel.clear();
      anushthanSearchModel.clear();
      vipSearchModel.clear();
      chadhavaSearchModel.clear();

      // Parse API response with null checks
      List poojaList = res["pooja_services"] ?? [];
      List anushthanList = res["anushthan"] ?? [];
      List vipList = res["vip_pooja"] ?? [];
      List chadhavaList = res["chadhava"] ?? [];

      // Populate model lists
      poojaSearchModel.addAll(poojaList.map((e) => PoojaServices.fromJson(e)));
      anushthanSearchModel
          .addAll(anushthanList.map((e) => Anushthan.fromJson(e)));
      vipSearchModel.addAll(vipList.map((e) => Vippooja.fromJson(e)));
      chadhavaSearchModel.addAll(chadhavaList.map((e) => Chadhava.fromJson(e)));

      // Combine all into a single list
      combinedList.clear();
      combinedList.addAll(poojaSearchModel.map((e) => {
            "name": e.enName,
            "slug": e.slug,
            "id": e.id,
            "type": "pooja",
            "date": e.nextPoojaDate
          }));
      combinedList.addAll(anushthanSearchModel.map((e) => {
            "name": e.enName,
            "slug": e.slug,
            "id": e.id,
            "type": "anushthan",
            "date": ""
          }));
      combinedList.addAll(vipSearchModel.map((e) => {
            "name": e.enName,
            "slug": e.slug,
            "id": e.id,
            "type": "vip",
            "date": ""
          }));
      combinedList.addAll(chadhavaSearchModel.map((e) => {
            "name": e.enName,
            "slug": e.slug,
            "id": e.id,
            "type": "chadhava",
            "date": e.nextPoojaDate
          }));

      print("API response: $combinedList");

      // Update UI
      // filterList(query);
      setState(() {});
    } catch (e) {
      // Handle any exceptions
      print("Error fetching search data: $e");
    }
  }

  // Filter the combined list based on query
  // void filterList(String query) {
  //   print('Entered value: $query');
  //   // Check the query and filter accordingly
  //   if (query.isEmpty) {
  //     // If query is empty, show the entire list
  //     filteredList = List.from(combinedList);
  //     print("Filtered List (Query Empty): $filteredList");
  //   } else {
  //     // Filter based on the query
  //     filteredList = combinedList
  //         .where((item) =>
  //     item['name'] != null && // Ensure 'name' exists
  //         item['name'].toLowerCase().contains(query.toLowerCase()))
  //         .toList();
  //     print("Filtered List (Query Non-Empty): $filteredList");
  //   }
  //
  //   // Update the UI
  //   setState(() {});
  // }

  // Load recent searches from SharedPreferences
  Future<void> _loadRecentSearches() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _recentSearches = prefs.getStringList('recentSearches') ?? [];
    });
  }

  // Save a search term to SharedPreferences
  Future<void> _saveSearch(String term) async {
    if (term.isEmpty) return;

    SharedPreferences prefs = await SharedPreferences.getInstance();
    _recentSearches.add(term);

    // Remove duplicates and limit the number of saved searches
    _recentSearches = _recentSearches.toSet().toList();
    if (_recentSearches.length > 10) {
      _recentSearches = _recentSearches.sublist(0, 10);
    }

    await prefs.setStringList('recentSearches', _recentSearches);
    setState(() {});
  }

  // Remove a search term from the list and SharedPreferences
  Future<void> _removeSearch(int index) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _recentSearches.removeAt(index);
    await prefs.setStringList('recentSearches', _recentSearches);
    setState(() {});
  }

  // Perform the search and save the term
  void _performSearch(String term) {
    _saveSearch(term);
    searchController.clear();
    print('Performing search for: $term');
  }

  void routeScreeen(String id, String slug, String name, String date) {
    if (name == "pooja") {
      Navigator.push(
          context,
          CupertinoPageRoute(
              builder: (context) => SliversExample(
                    slugName: slug,
                    // nextDatePooja: date,
                  )));
    } else if (name == "anushthan") {
      Navigator.push(
          context,
          CupertinoPageRoute(
              builder: (context) => AnushthanDetails(
                    idNumber: slug,
                    typePooja: 'anushthan',
                  )));
    } else if (name == "vip") {
      Navigator.push(
          context,
          CupertinoPageRoute(
              builder: (context) => VipDetails(
                    idNumber: slug,
                    typePooja: 'vip',
                  )));
    } else if (name == "chadhava") {
      Navigator.push(
          context,
          CupertinoPageRoute(
              builder: (context) => ChadhavaDetailView(
                    idNumber: id,
                    // nextDatePooja: date,
                  )));
    } else {
      print("faled routing");
    }
  }

  @override
  Widget build(BuildContext context) {
    var screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Pooja Search",
          style: TextStyle(color: Colors.orange),
        ),
        centerTitle: true,
        // actions: [
        //   BouncingWidgetInOut(
        //     onPressed: () {
        //       setState(() {
        //         isTranslate = !isTranslate;
        //       });
        //     },
        //     bouncingType: BouncingType.bounceInAndOut,
        //     child: Container(
        //       height: 25,
        //       width: 25,
        //       decoration: BoxDecoration(
        //           borderRadius:
        //           BorderRadius.circular(4.0),
        //           color: isTranslate
        //               ? Colors.orange
        //               : Colors.white,
        //           border: Border.all(
        //               color: Colors.orange,
        //               width: 2)),
        //       child: Center(
        //         child: Icon(
        //           Icons.translate,
        //           color: isTranslate
        //               ? Colors.white
        //               : Colors.orange,
        //           size: 18,
        //         ),
        //       ),
        //     ),
        //   ),
        //   SizedBox(width: 10,),
        // ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                              combinedList.clear();
                            });
                          },
                          child: const Icon(Icons.close)),
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
                      )),
                ),
                const SizedBox(
                  height: 10,
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Container(
                        color: Colors.orange,
                        height: 18,
                        width: 3,
                      ),
                      const SizedBox(
                        width: 8,
                      ),
                      const Text(
                        "Recent's",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      )
                    ],
                  ),
                ),
                ListView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount:
                        _recentSearches.length > 3 ? 3 : _recentSearches.length,
                    itemBuilder: (context, index) {
                      final reversedIndex = _recentSearches.length - 1 - index;
                      return Column(
                        children: [
                          InkWell(
                            onTap: () {
                              setState(() {
                                searchController.clear();
                                searchController.text =
                                    _recentSearches[reversedIndex];
                              });
                              getSearchData(_recentSearches[reversedIndex]);
                              // _performSearch(_recentSearches[reversedIndex]);
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                children: [
                                  const Expanded(
                                    flex: 0,
                                    child: Icon(
                                      Icons.history,
                                      color: Colors.black,
                                      size: 24,
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  Expanded(
                                    flex: 1,
                                    child: Text(
                                      _recentSearches[reversedIndex],
                                      style: const TextStyle(
                                        fontSize: 18,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),
                                  const Spacer(),
                                  InkWell(
                                    onTap: () {
                                      _removeSearch(reversedIndex);
                                    },
                                    child: const Icon(
                                      Icons.close,
                                      color: Colors.black,
                                      size: 24,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Divider(
                            color: Colors.grey.shade400,
                          ),
                        ],
                      );
                    }),
                const SizedBox(
                  height: 10,
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Container(
                        color: Colors.orange,
                        height: 18,
                        width: 3,
                      ),
                      const SizedBox(
                        width: 8,
                      ),
                      const Text(
                        "Search Result's",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      )
                    ],
                  ),
                ),
                ListView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: combinedList.length,
                    itemBuilder: (context, index) {
                      final item = combinedList[index];
                      return Column(
                        children: [
                          InkWell(
                            onTap: () {
                              print(item['id']);
                              print(item['type']);
                              routeScreeen("${item['id']}", "${item['slug']}",
                                  "${item['type']}", "${item['date']}");
                              _performSearch(searchController.text.trim());
                              _performSearch;
                              combinedList.clear();
                              searchController.clear();
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                children: [
                                  const Expanded(
                                    flex: 0,
                                    child: Icon(
                                      Icons.location_pin,
                                      color: Colors.black,
                                      size: 24,
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  Expanded(
                                    flex: 1,
                                    child: Text(
                                      "${item['name']}",
                                      style: const TextStyle(
                                        fontSize: 18,
                                        color: Colors.black,
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                          Divider(
                            color: Colors.grey.shade400,
                          ),
                        ],
                      );
                    }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
