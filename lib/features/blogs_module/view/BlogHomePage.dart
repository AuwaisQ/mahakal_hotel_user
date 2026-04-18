import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mahakal/features/blogs_module/Controller/language_provider.dart';
import 'package:provider/provider.dart';
import 'package:tdk_bouncingwidget/tdk_bouncingwidget.dart';
import '../../../../data/datasource/remote/http/httpClient.dart';
import '../../../../utill/app_constants.dart';
import '../model/blog_category_model.dart';
import 'AllBlogScreen.dart';
import 'BlogBookmarkScreen.dart';
import 'BlogSubCategoryScreen.dart';

class BlogHomePage extends StatefulWidget {
  const BlogHomePage({super.key});

  @override
  State<BlogHomePage> createState() => _BlogHomePageState();
}

class _BlogHomePageState extends State<BlogHomePage> {
  bool _isSaved = true;
  bool _isTranslate = true;
  bool _isLoading = true;
  List<BlogCategory> categoryList = [];
  late BlogLanguageProvider languageProvider;

  @override
  void initState() {
    super.initState();
    languageProvider =
        Provider.of<BlogLanguageProvider>(context, listen: false);
    fetchCategoryData();

    // Re-fetch categories whenever language changes
    languageProvider.addListener(() {
      fetchCategoryData();
    });
  }

  @override
  void dispose() {
    languageProvider.removeListener(() {
      fetchCategoryData();
    });
    super.dispose();
  }

  Future<void> fetchCategoryData() async {
    setState(() => _isLoading = true);

    try {
      final languageProvider =
          Provider.of<BlogLanguageProvider>(context, listen: false);
      final String url =
          "${AppConstants.blogsCategoryUrl}${languageProvider.isEnglish ? 1 : 2}";
      final response = await HttpService().getApi(url);

      // Parse response according to your BlogCategoryModel
      if (response != null && response is Map<String, dynamic>) {
        if (response.containsKey('status') &&
            response.containsKey('categories') &&
            response['categories'] != null) {
          final categoryData = BlogCategoryModel.fromJson(response);
          setState(() {
            categoryList = categoryData.categories;
          });
        } else {
          setState(() {
            categoryList = [];
          });
        }
      }
    } catch (e) {
      print("Error fetching categories: $e");
      setState(() {
        categoryList = [];
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    var screenWidth = MediaQuery.of(context).size.width;

    return Consumer<BlogLanguageProvider>(
      builder: (context, languageProvider, child) {
        if (_isLoading) {
          return const Scaffold(
            backgroundColor: Colors.white,
            body: Center(
              child: CircularProgressIndicator(color: Colors.orange),
            ),
          );
        }

        if (categoryList.isEmpty) {
          return Scaffold(
            backgroundColor: Colors.white,
            body: Center(
              child: SizedBox(
                width: 300,
                height: 330,
                child: Card(
                  shadowColor: Colors.black,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.hourglass_empty,
                          size: 50, color: Colors.black45),
                      const SizedBox(height: 10),
                      Text(
                        "No Data Found !",
                        style: TextStyle(
                            fontSize: screenWidth * 0.04,
                            color: Colors.black54),
                      ),
                      Text(
                        "Please try again later...",
                        style: TextStyle(
                            fontSize: screenWidth * 0.04,
                            color: Colors.black54),
                      ),
                      SizedBox(height: screenWidth * 0.05),
                      ElevatedButton(
                        onPressed: fetchCategoryData,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red.withOpacity(0.7),
                        ),
                        child: Text(
                          "Try Again",
                          style: TextStyle(
                            fontSize: screenWidth * 0.04,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          );
        }

        return DefaultTabController(
          length: categoryList.length + 1,
          child: Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              elevation: 0,
              toolbarHeight: screenWidth * 0.13,
              backgroundColor: Colors.deepOrange,
              centerTitle: true,
              automaticallyImplyLeading: true,
              leading: IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
              ),
              title: Text(
                languageProvider.isEnglish ? "Blogs" : "ब्लॉग",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontSize: screenWidth * 0.06,
                  fontFamily: 'Roboto',
                ),
              ),
              actions: [
                BouncingWidgetInOut(
                  onPressed: () {
                    setState(() {
                      _isTranslate = !_isTranslate;
                      languageProvider.toggleLanguage();
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    height: 35,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8.0),
                      color: _isTranslate ? Colors.white : Colors.transparent,
                      border: Border.all(
                        color: _isTranslate ? Colors.transparent : Colors.white,
                        width: 2,
                      ),
                    ),
                    child: Icon(
                      Icons.translate,
                      color: _isTranslate ? Colors.black : Colors.white,
                    ),
                  ),
                ),
                BouncingWidgetInOut(
                  onPressed: () {
                    setState(() {
                      _isSaved = !_isSaved;
                      Navigator.push(
                        context,
                        CupertinoPageRoute(
                            builder: (context) => const BlogBookmarkScreen()),
                      );
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    height: 35,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8.0),
                      color: _isSaved ? Colors.white : Colors.transparent,
                      border: Border.all(
                        color: _isSaved ? Colors.transparent : Colors.white,
                        width: 2,
                      ),
                    ),
                    child: Icon(
                      Icons.bookmark,
                      color: _isSaved ? Colors.black : Colors.white,
                    ),
                  ),
                ),
              ],
              bottom: TabBar(
                isScrollable: true,
                indicatorColor: Colors.orangeAccent,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.black,
                dividerColor: Colors.transparent,
                indicatorSize: TabBarIndicatorSize.tab,
                tabAlignment: TabAlignment.start,
                padding: EdgeInsets.symmetric(
                    horizontal: 10, vertical: screenWidth * 0.03),
                splashFactory: NoSplash.splashFactory,
                labelStyle:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                tabs: [
                  Text(languageProvider.isEnglish ? "All" : "सभी"),
                  ...categoryList.map((cat) => Text(cat.name)),
                ],
              ),
            ),
            body: TabBarView(
              children: [
                const AllBlogScreen(),
                ...categoryList
                    .map((cat) => BlogSubCategoryScreen(myId: cat.id)),
              ],
            ),
          ),
        );
      },
    );
  }
}
