import 'package:flutter/material.dart';
import 'package:tdk_bouncingwidget/tdk_bouncingwidget.dart';
import '../../../data/datasource/remote/http/httpClient.dart';
import '../../../localization/language_constrants.dart';
import '../../../utill/app_constants.dart';
import '../../../utill/loading_datawidget.dart';
import '../../blogs_module/Controller/language_provider.dart';
import '../model/category_model.dart';
import 'package:provider/provider.dart';
import 'OfflineAllScreen.dart';
import 'OfflineViewScreen.dart';

class OfflinePoojaHome extends StatefulWidget {
  int tabIndex = 0;
  OfflinePoojaHome({super.key, required this.tabIndex});

  @override
  State<OfflinePoojaHome> createState() => _OfflinePoojaHomeState();
}

class _OfflinePoojaHomeState extends State<OfflinePoojaHome> {
  final bool _isSaved = true;
  bool _isTranslate = true;
  bool _isLoading = true;
  List<OfflineCategory> categoryList = [];

  @override
  void initState() {
    super.initState();
    getCategoryData();
  }

  Future<void> refresh() async {
    await getCategoryData();
  }

  Future<void> getCategoryData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final res = await HttpService()
          .getApi(AppConstants.offlineCategoryUrl); // 🔄 Replaced here
      print(res);

      if (res != null) {
        final offlineData = CategoryModel.fromJson(res);
        setState(() {
          categoryList = offlineData.categoryList;
        });
      }
    } catch (error) {
      print("Error fetching categories: $error");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var screenWidth = MediaQuery.of(context).size.width;

    return Consumer<BlogLanguageProvider>(
      builder: (context, languageProvider, child) {
        return _isLoading
            ? MahakalLoadingData(onReload: () {})
            : categoryList.isEmpty
                ? MahakalLoadingData(onReload: () {})
                : DefaultTabController(
                    length: categoryList.length + 1,
                    initialIndex: widget.tabIndex,
                    child: Scaffold(
                      backgroundColor: Colors.white,
                      appBar: AppBar(
                        elevation: 0,
                        toolbarHeight: screenWidth * 0.13,
                        backgroundColor: Colors.white,
                        title: Text(
                          "${getTranslated('offline_pooja', context)}",
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Colors.orange,
                            fontSize: screenWidth * 0.06,
                            fontFamily: 'Roboto',
                          ),
                        ),
                        centerTitle: true,
                        automaticallyImplyLeading: true,
                        // leading: IconButton(onPressed: ()=> Navigator.pop(context), icon:  Icon(Icons.arrow_back, color: Colors.black, size: screenWidth * 0.06)),
                        actions: [
                          BouncingWidgetInOut(
                            onPressed: () {
                              setState(() {
                                _isTranslate = !_isTranslate;
                                languageProvider.toggleLanguage();
                              });
                            },
                            child: Container(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 7),
                              height: 40,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8.0),
                                  color: _isTranslate
                                      ? Colors.orange
                                      : Colors.transparent,
                                  border: Border.all(
                                      color: _isTranslate
                                          ? Colors.transparent
                                          : Colors.orange,
                                      width: 2)),
                              child: Icon(
                                Icons.translate,
                                color:
                                    _isTranslate ? Colors.white : Colors.orange,
                              ),
                            ),
                          ),
                        ],

                        bottom: TabBar(
                          unselectedLabelColor: Colors.grey,
                          labelColor: Colors.black,
                          indicatorColor: Colors.orangeAccent,
                          dividerColor: Colors.transparent,
                          splashFactory: NoSplash.splashFactory,
                          indicatorSize: TabBarIndicatorSize.tab,
                          tabAlignment: TabAlignment.start,
                          isScrollable: true,
                          labelStyle: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 18),
                          tabs: [
                            Tab(
                              icon: const Icon(Icons.category),
                              child: Text(
                                  languageProvider.isEnglish ? "All" : "सभी"),
                            ),
                            // Text(languageProvider.isEnglish ? "All" : "सभी"),
                            ...categoryList.map(
                              (cat) => Tab(
                                icon: ClipRRect(
                                  borderRadius: BorderRadius.circular(4),
                                  child: Image.network(
                                    cat.image,
                                    height: 40,
                                  ),
                                ),
                                child: Text(languageProvider.isEnglish
                                    ? cat.enName
                                    : cat.hiName),
                              ),
                            ),
                          ],
                        ),
                      ),
                      body: _isLoading
                          ? const Center(
                              child: CircularProgressIndicator(
                              color: Colors.orange,
                            ))
                          : TabBarView(
                              children: [
                                const OfflineAllScreen(
                                  type: "all",
                                ),
                                ...categoryList.map((cat) => OfflineViewScreen(
                                      categoryId: "${cat.id}",
                                    )),
                              ],
                            ),
                    ),
                  );
      },
    );
  }
}
