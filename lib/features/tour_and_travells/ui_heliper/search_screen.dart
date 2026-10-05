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
  bool isLoading = false;
  List<String> _recentSearches = [];
  List<TourSearchData> tourSearchModel = <TourSearchData>[];
  List<Map<String, dynamic>> filteredList = [];

  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadRecentSearches();
    if (widget.recentName.isNotEmpty) {
      searchController.text = widget.recentName;
      getSearchData(widget.recentName);
    }
  }

  // Fetch search data from API
  void getSearchData(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        filteredList.clear();
      });
      return;
    }

    setState(() => isLoading = true);
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
    } catch (e) {
      debugPrint("Error fetching search data: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  // Load recent searches from SharedPreferences
  Future<void> _loadRecentSearches() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? savedSearches = prefs.getStringList('recentSearches');
    setState(() {
      _recentSearches = savedSearches ?? [];
    });
  }

  // Save a search term
  Future<void> _saveSearch(String term) async {
    if (term.trim().isEmpty) return;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _recentSearches.removeWhere((item) => item.toLowerCase() == term.toLowerCase());
    _recentSearches.insert(0, term);
    if (_recentSearches.length > 10) {
      _recentSearches = _recentSearches.sublist(0, 10);
    }
    await prefs.setStringList('recentSearches', _recentSearches);
    setState(() {});
  }

  // Clear all recent searches
  Future<void> _clearAllRecents() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('recentSearches');
    setState(() {
      _recentSearches.clear();
    });
  }

  void _onSearchItemSelected(String name, String id) {
    _saveSearch(name);
    Navigator.push(
      context,
      CupertinoPageRoute(builder: (context) => TourDetails(productId: id)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildSearchHeader(),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_recentSearches.isNotEmpty && searchController.text.isEmpty)
                      _buildRecentSection(),
                    
                    if (searchController.text.isNotEmpty)
                      _buildResultsSection(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 15, 20, 15),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black87),
          ),
          Expanded(
            child: Container(
              height: 50,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: TextField(
                controller: searchController,
                autofocus: widget.recentName.isEmpty,
                onChanged: (value) => getSearchData(value),
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                decoration: InputDecoration(
                  hintText: 'Search destinations...',
                  hintStyle: TextStyle(color: Colors.grey.shade500),
                  border: InputBorder.none,
                  prefixIcon: const Icon(Icons.search, color: Colors.blueAccent),
                  suffixIcon: searchController.text.isNotEmpty
                      ? IconButton(
                          icon: Icon(Icons.cancel, color: Colors.grey.shade400, size: 20),
                          onPressed: () {
                            setState(() {
                              searchController.clear();
                              filteredList.clear();
                            });
                          },
                        )
                      : null,
                  contentPadding: const EdgeInsets.symmetric(vertical: 13),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Recent Searches",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
              TextButton(
                onPressed: _clearAllRecents,
                child: const Text("Clear All", style: TextStyle(color: Colors.redAccent, fontSize: 13)),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 40,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 15),
            itemCount: _recentSearches.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5),
                child: ActionChip(
                  label: Text(_recentSearches[index]),
                  labelStyle: const TextStyle(fontSize: 13, color: Colors.blueAccent),
                  backgroundColor: Colors.blue.withOpacity(0.05),
                  side: BorderSide(color: Colors.blue.withOpacity(0.1)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  onPressed: () {
                    searchController.text = _recentSearches[index];
                    getSearchData(_recentSearches[index]);
                  },
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildResultsSection() {
    if (isLoading) {
      return const Padding(
        padding: EdgeInsets.only(top: 100),
        child: Center(child: CupertinoActivityIndicator(radius: 15)),
      );
    }

    if (filteredList.isEmpty && searchController.text.isNotEmpty) {
      return Padding(
        padding: const EdgeInsets.only(top: 80),
        child: Center(
          child: Column(
            children: [
              Icon(Icons.search_off_rounded, size: 80, color: Colors.grey.shade300),
              const SizedBox(height: 15),
              Text(
                "No results found for \"${searchController.text}\"",
                style: TextStyle(color: Colors.grey.shade500, fontSize: 16),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Text(
            "Search Results",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
          ),
        ),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: filteredList.length,
          separatorBuilder: (context, index) => Divider(height: 1, indent: 65, color: Colors.grey.shade100),
          itemBuilder: (context, index) {
            final item = filteredList[index];
            return ListTile(
              onTap: () => _onSearchItemSelected(item['name'], "${item['id']}"),
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.location_on_rounded, color: Colors.blueAccent, size: 22),
              ),
              title: Text(
                "${item['name']}",
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.black87),
              ),
              subtitle: Text(
                "Explore destinations in ${item['name']}",
                style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
              ),
              trailing: Icon(Icons.chevron_right_rounded, color: Colors.grey.shade400),
            );
          },
        ),
      ],
    );
  }
}
