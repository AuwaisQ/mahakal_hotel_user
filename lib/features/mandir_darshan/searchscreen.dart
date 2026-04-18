import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mahakal/data/datasource/remote/http/httpClient.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'city_details.dart';
import 'hotel_details.dart';
import 'mandirdetails_mandir.dart';
import 'model/searchmodel.dart';
import 'restaurant_details.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  @override
  void initState() {
    super.initState();
    getSearchData("");
    _loadRecentSearches();
  }

  bool isTranslate = true;
  List<String> _recentSearches = [];
  List<Temple> templeModelList = [];
  List<Restaurant> restaurantModelList = [];
  List<Hotel> hotelModelList = [];
  List<City> cityModelList = [];
  List<Map<String, dynamic>> combinedList = [];
  List<Map<String, dynamic>> filteredList = [];
  final TextEditingController searchController = TextEditingController();

  void getSearchData(String query) async {
    try {
      // Ensure the base URL and endpoint are properly concatenated
      String url = "/api/v1/temple/search-temple";
      var res = await HttpService().postApi(
        url,
        {
          "search": query, // Use the controller value directly
        },
      );
      // Clear previous data
      templeModelList.clear();
      restaurantModelList.clear();
      hotelModelList.clear();
      cityModelList.clear();

      // Parse API response
      List templeList = res["data"]["temples"];
      List restaurantList = res["data"]["restaurants"];
      List hotelList = res["data"]["hotels"];
      List cityList = res["data"]["cities"];

      // Populate model lists
      templeModelList.addAll(templeList.map((e) => Temple.fromJson(e)));
      restaurantModelList
          .addAll(restaurantList.map((e) => Restaurant.fromJson(e)));
      hotelModelList.addAll(hotelList.map((e) => Hotel.fromJson(e)));
      cityModelList.addAll(cityList.map((e) => City.fromJson(e)));

      // Combine all into a single list
      combinedList.clear();
      combinedList.addAll(templeModelList
          .map((e) => {"name": e.enName, "id": e.id, "type": "Temple"}));
      combinedList.addAll(restaurantModelList.map((e) =>
          {"name": e.enRestaurantName, "id": e.id, "type": "Restaurant"}));
      combinedList.addAll(hotelModelList
          .map((e) => {"name": e.enHotelName, "id": e.id, "type": "Hotel"}));
      combinedList.addAll(cityModelList
          .map((e) => {"name": e.enCity, "id": e.id, "type": "City"}));

      print("API response: $res");
      // Update UI
      filterList(query);
      setState(() {});
    } catch (e) {
      // Handle any exceptions
      print("Error fetching search data: $e");
    }
  }

  // Filter the combined list based on query
  void filterList(String query) {
    print('Entered value: $query');
    setState(() {
      if (query.isEmpty) {
        filteredList = List.from(combinedList);
      } else {
        filteredList.clear();
        filteredList = combinedList
            .where((item) =>
                item['name'].toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

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

  void routeScreeen(String id, String name) {
    if (name == "Temple") {
      Navigator.push(
          context,
          CupertinoPageRoute(
              builder: (context) => MandirDetailView(
                    detailId: id,
                  )));
    } else if (name == "City") {
      Navigator.push(
          context,
          CupertinoPageRoute(
              builder: (context) => CitydarshanView(
                    detailId: id,
                  )));
    } else if (name == "Restaurant") {
      Navigator.push(
          context,
          CupertinoPageRoute(
              builder: (context) => RestaurantDetailView(
                    detailId: id,
                  )));
    } else if (name == "Hotel") {
      Navigator.push(
          context,
          CupertinoPageRoute(
              builder: (context) => HotelDetailView(
                    detailId: id,
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
          "Mandir Search",
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
                              filteredList.clear();
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
                    itemCount: filteredList.length,
                    itemBuilder: (context, index) {
                      final item = filteredList[index];
                      return Column(
                        children: [
                          InkWell(
                            onTap: () {
                              print(item['id']);
                              print(item['type']);
                              routeScreeen("${item['id']}", "${item['type']}");
                              _performSearch(searchController.text.trim());
                              _performSearch;
                              searchController.clear();
                              filteredList.clear();
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
                                      item['name'],
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
