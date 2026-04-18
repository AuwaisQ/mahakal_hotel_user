import 'package:flutter/material.dart';
import 'package:mahakal/features/sahitya/view/sahitya_grid/grid_sahitya.dart';
import 'package:tdk_bouncingwidget/tdk_bouncingwidget.dart';
import '../../../../data/datasource/remote/http/httpClient.dart';
import '../../../../utill/app_constants.dart';
import '../../model/sahitya_category_model.dart';
import '../sahiya_list/sahitya_list.dart';

class SahityaHome extends StatefulWidget {
  const SahityaHome({super.key});

  @override
  State<SahityaHome> createState() => _SahityaHomeState();
}

class _SahityaHomeState extends State<SahityaHome> {

  bool _isGridView = false;
  bool _isEnglish = false;
  bool _isSearchActive = false;
  bool isLoading = false;

  List<SahityaData> sahityaList = [];
  List<SahityaData> filteredList = [];
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    getSahityaData();
  }

  Future<void> getSahityaData() async {
    setState(() {
      isLoading = true;
    });
    try {
      final Map<String, dynamic> res =
          await HttpService().getApi(AppConstants.sahityaGridUrl);
      if (res.containsKey('status') &&
          res.containsKey('data') &&
          res['data'] != null) {
        final sahitya = SahityaCategoryModel.fromJson(res);
        setState(() {
          sahityaList = sahitya.data;
          filteredList = sahityaList;
        });
      }
    } catch (e) {
      print("Error fetching sahitya: $e");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void filterSearch(String query) {
    final lowerQuery = query.toLowerCase();
    List<SahityaData> results = sahityaList.where((item) {
      return item.enName.toLowerCase().contains(lowerQuery) ?? false;
    }).toList();

    setState(() {
      filteredList = query.isEmpty ? sahityaList : results;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepOrange,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
        ),
        title: _isSearchActive
            ? Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white70),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const Icon(Icons.search, color: Colors.white70),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        focusNode: _focusNode,
                        onChanged: filterSearch,
                        style: const TextStyle(color: Colors.white),
                        cursorColor: Colors.white,
                        decoration: InputDecoration(
                          hintText: _isEnglish ? 'Search...' : 'खोजें...',
                          hintStyle: const TextStyle(color: Colors.white60),
                          border: InputBorder.none,
                          isCollapsed: true,
                        ),
                        autofocus: true,
                      ),
                    ),
                  ],
                ),
              )
            : Text(
                _isEnglish ? "Sahitya" : "साहित्य",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: screenWidth * 0.06,
                  fontWeight: FontWeight.bold,
                ),
              ),
        actions: [
          // Search Icon Toggle
          IconButton(
            icon: Icon(_isSearchActive ? Icons.close : Icons.search,
                color: Colors.white),
            onPressed: () {
              setState(() {
                _isSearchActive = !_isSearchActive;
                if (!_isSearchActive) {
                  _searchController.clear();
                  filterSearch('');
                } else {
                  _focusNode.requestFocus();
                }
              });
            },
          ),
          // Language Toggle
          IconButton(
            icon: const Icon(Icons.translate, color: Colors.white),
            onPressed: () {
              setState(() {
                _isEnglish = !_isEnglish;
                filterSearch(_searchController.text);
              });
            },
          ),
          // Grid/List Toggle
          BouncingWidgetInOut(
            onPressed: () {
              setState(() {
                _isGridView = !_isGridView;
              });
            },
            child: Container(
              padding: const EdgeInsets.all(2.0),
              height: 30,
              width: 30,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6.0),
                color: _isGridView ? Colors.white : Colors.transparent,
                border: Border.all(
                  color: _isGridView ? Colors.black : Colors.white,
                  width: 2,
                ),
              ),
              child: Center(
                child: Icon(
                  _isGridView ? Icons.grid_view : Icons.list,
                  color: _isGridView ? Colors.black : Colors.white,
                  size: 20,
                ),
              ),
            ),
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.orange))
          : filteredList.isEmpty
              ? const Center(child: Text("No Data Found"))
              : _isGridView
                  ? SahityaList(
                      isEnglish: _isEnglish,
                      sahityaData: filteredList,
                      isLoading: isLoading,
                    )
                  : GridSahitya(
                      isEnglish: _isEnglish,
                      sahityaData: filteredList,
                      isLoading: isLoading,
                    ),
    );
  }
}
