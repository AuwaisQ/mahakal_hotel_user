import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tdk_bouncingwidget/tdk_bouncingwidget.dart';
import '../../../../utill/app_constants.dart';
import '../../../../utill/loading_datawidget.dart';
import '../../../donation/controller/lanaguage_provider.dart';
import '../../model/categories_model.dart';
import '../../model/subcategory_model.dart';
import '../../ui_helper/custom_colors.dart';
import '../../utils/api_service.dart';
import 'grid_view/YoutubeGridView.dart';
import 'list_view/YoutubeListView.dart';

class YoutubeHomePage extends StatefulWidget {
  final int? tabIndex;
  const YoutubeHomePage({super.key, this.tabIndex});

  @override
  State<YoutubeHomePage> createState() => _YoutubeHomePageState();
}

class _YoutubeHomePageState extends State<YoutubeHomePage> {
  List<CategoriesModel> category = [];
  List<KathaModel> subcategory = [];
  bool _isGridView = false;
  bool _isTranslate = true;
  bool isLoading = false;
  bool _isSearchClicked = false;

  @override
  void initState() {
    super.initState();
    getCategoryData();
  }

  Future<void> refresh() async {
    setState(() {
      getCategoryData();
    });
  }

  // Category API
  Future<void> getCategoryData() async {
    setState(() {
      isLoading = true;
    });

    try {
      final res = await ApiService().getCategory(
          '${AppConstants.baseUrl}${AppConstants.youtubeCategoryUrl}');
      List cdata = res['videoCategory'];
      setState(() {
        category = categoriesModelFromJson(jsonEncode(cdata));
      });
    } catch (e) {
      print(e);
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var screenHeight = MediaQuery.of(context).size.height;
    var screenWidth = MediaQuery.of(context).size.width;

    List<CategoriesModel> filteredCategories =
        category.where((cat) => cat.status != 0).toList();

    return DefaultTabController(
      length: filteredCategories.length,
      initialIndex: widget.tabIndex!,
      child: isLoading
          ? MahakalLoadingData(onReload: () => getCategoryData())
          : filteredCategories.isEmpty
              ? const Scaffold(body: Center(child: Text("No Data Available !")))
              : Scaffold(
                  appBar: AppBar(
                      elevation: 0,
                      shadowColor: Colors.transparent,
                      leading: IconButton(
                          onPressed: () {
                            Navigator.pop(
                                context); // Make sure you have the correct context
                          },
                          icon: const Icon(
                            Icons.arrow_back_ios,
                            color: Colors.white,
                          )),
                      backgroundColor: Colors.deepOrange,
                      title: Consumer<LanguageProvider>(
                        builder:
                            (BuildContext context, languageProvider, child) {
                          return Text(
                            languageProvider.language == "english"
                                ? "Videos"
                                : "वीडियो",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: screenWidth * 0.06,
                            ),
                          );
                        },
                      ),
                      centerTitle: true,
                      actions: [
                        IconButton(
                          icon: const Icon(Icons.search, color: Colors.white),
                          onPressed: () {
                            setState(() {
                              _isSearchClicked =
                                  !_isSearchClicked; // Toggle language
                            });
                          },
                        ),
                        BouncingWidgetInOut(
                          onPressed: () {
                            setState(() {
                              _isGridView = !_isGridView;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.all(2.0),
                            height: 35,
                            width: 35,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(6.0),
                                color: _isGridView
                                    ? Colors.white
                                    : Colors.transparent,
                                border: Border.all(
                                    color: _isGridView
                                        ? Colors.transparent
                                        : Colors.white,
                                    width: 2)),
                            child: Center(
                                child: Icon(
                              _isGridView ? Icons.grid_view : Icons.list,
                              color: _isGridView ? Colors.black : Colors.white,
                              size: 20,
                            )),
                          ),
                        ),
                        Consumer<LanguageProvider>(
                          builder: (BuildContext context, languageProvider,
                              Widget? child) {
                            return BouncingWidgetInOut(
                              onPressed: () {
                                setState(() {
                                  _isTranslate = !_isTranslate;
                                  languageProvider.toggleLanguage();
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.all(2.0),
                                height: 35,
                                width: 35,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8.0),
                                    color: _isTranslate
                                        ? Colors.white
                                        : Colors.transparent,
                                    border: Border.all(
                                        color: _isTranslate
                                            ? Colors.transparent
                                            : Colors.white,
                                        width: 2)),
                                child: Icon(
                                  Icons.translate,
                                  color: _isTranslate
                                      ? Colors.black
                                      : Colors.white,
                                ),
                              ),
                            );
                          },
                        ),
                      ]),
                  body: SafeArea(
                    child: Column(
                      children: [
                        TabBar(
                          dividerColor: Colors.transparent,
                          unselectedLabelColor: Colors.grey,
                          labelColor: Colors.black,
                          physics: const AlwaysScrollableScrollPhysics(),
                          tabAlignment: TabAlignment.start,
                          indicatorColor: Colors.orange,
                          padding: const EdgeInsets.symmetric(horizontal: 15),
                          labelPadding:
                              const EdgeInsets.symmetric(horizontal: 18),
                          labelStyle: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                              fontFamily: 'Roboto'),
                          indicatorSize: TabBarIndicatorSize.tab,
                          isScrollable: true,
                          tabs: List.generate(
                              filteredCategories.length,
                              (int index) => Consumer<LanguageProvider>(
                                    builder: (BuildContext context,
                                        languageProvider, Widget? child) {
                                      return Tab(
                                        text: languageProvider.language ==
                                                "english"
                                            ? filteredCategories[index].name
                                            : filteredCategories[index].hiName,
                                      );
                                    },
                                  )),
                        ),
                        Expanded(
                          child: TabBarView(
                            children: filteredCategories.map((category) {
                              return RefreshIndicator(
                                  onRefresh: () async {
                                    await refresh();
                                  },
                                  color: CustomColors.clrblack,
                                  backgroundColor: CustomColors.clrwhite,
                                  child: _isGridView
                                      ? YoutubeListView(
                                          categoryName: category.name,
                                          categoryId: category.id,
                                        )
                                      : YoutubeGridView(
                                          categoryName: category.name,
                                          categoryId: category.id,
                                          isSearchClicked: _isSearchClicked,
                                        ));
                            }).toList(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
    );
  }
}
