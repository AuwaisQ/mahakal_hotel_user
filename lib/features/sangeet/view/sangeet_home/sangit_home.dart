import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:mahakal/data/datasource/remote/http/httpClient.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../utill/app_constants.dart';
import '../../../../utill/loading_datawidget.dart';
import '../../../donation/ui_helper/custom_colors.dart';
import '../../controller/language_manager.dart';
import '../../model/category_model.dart';
import '../bhajantab_view/bhajan_tabs.dart';
import '../bhajantab_view/my_favourite/favourita_screen.dart';

class SangitHome extends StatefulWidget {
  final int tabiIndex;
  const SangitHome({super.key, required this.tabiIndex});

  @override
  State<SangitHome> createState() => _SangitHomeState();
}

class _SangitHomeState extends State<SangitHome> {
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchDataAndSetState();
    final languageManager = Provider.of<LanguageManager>(context, listen: false);
    languageManager.getLanguageData();
  }

  List<SangeetCategory> categorymodel = <SangeetCategory>[];

  Future<void> _fetchDataAndSetState() async {
    isLoading = true;
    try {
      final jsonResponse = await HttpService().getApi(AppConstants.sangeetCategoryUrl);
      print(jsonResponse);
      if (jsonResponse.containsKey('status') &&
          jsonResponse.containsKey('data') &&
          jsonResponse['data'] != null) {
        setState(() {
          final List categoryList = jsonResponse['data'];
          categorymodel.addAll(categoryList.map((e) => SangeetCategory.fromJson(e)));
        });
        print("Category data: $categorymodel");
      } else {
        print("Error: 'status' or 'data' key is missing or null in response.");
      }
    } catch (error) {
      print('Error fetching category data: $error');
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> refresh() async {
    await _fetchDataAndSetState();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    final List<Widget> tabs = [
      Tab(
        height: screenWidth / 6.5,
        child: Column(
          children: [
            Container(
              height: screenWidth * 0.1,
              width: screenWidth * 0.1,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Icon(
                Icons.favorite,
                size: 35,
                color: Colors.red,
              ),
            ),
            SizedBox(height: screenWidth * 0.005),
            SizedBox(
              width: screenHeight * 0.08,
              child: Center(
                child: Consumer<LanguageManager>(
                  builder: (BuildContext context, languageManager, Widget? child) {
                    return Text(
                      languageManager.selectedLanguage == 'English' ? 'Favourite' : 'पसंदीदा',
                      style: const TextStyle(
                        fontSize: 13,
                        color: CustomColors.clrblack,
                        overflow: TextOverflow.ellipsis,
                      ),
                      maxLines: 1,
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
      ...categorymodel.map((cat) => Tab(
            height: screenWidth / 6.5,
            child: Column(
              children: [
                Container(
                  height: screenWidth * 0.1,
                  width: screenWidth * 0.1,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6),
                    image: DecorationImage(
                      image: CachedNetworkImageProvider(cat.image),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                SizedBox(
                  width: screenHeight * 0.08,
                  child: Center(
                    child: Consumer<LanguageManager>(
                      builder: (BuildContext context, languageManager, Widget? child) {
                        return Text(
                          languageManager.selectedLanguage == 'English' ? cat.enName : cat.hiName,
                          style: const TextStyle(
                            fontSize: 13,
                            color: CustomColors.clrblack,
                            overflow: TextOverflow.ellipsis,
                          ),
                          maxLines: 1,
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          )),
    ];

    final List<Widget> tabViews = [
      const FavouriteScreen(),
      ...categorymodel.map((cat) => BhajanTabs(cat.banner, cat.id, cat.enName, cat.hiName, false)),
    ];

    return categorymodel.isEmpty
        ? Scaffold(
            backgroundColor: CustomColors.clrwhite,
            body: isLoading
                ? MahakalLoadingData(onReload: _fetchDataAndSetState)
                : Column(
                    children: [
                      SizedBox(height: screenWidth * 0.6),
                      Center(
                        child: SizedBox(
                          width: 300,
                          height: 330,
                          child: Card(
                            shadowColor: Colors.black,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(
                                  height: 100,
                                  width: 100,
                                  decoration: const BoxDecoration(
                                    image: DecorationImage(
                                      image: AssetImage('assets/image/connection.png'),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                Text(
                                  'No Data Found!',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: screenWidth * 0.04,
                                    color: Colors.black.withValues(alpha: 0.5),
                                  ),
                                ),
                                Text(
                                  'Please try again later...',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: screenWidth * 0.04,
                                    color: Colors.black.withValues(alpha: 0.5),
                                  ),
                                ),
                                SizedBox(height: screenWidth * 0.05),
                                GestureDetector(
                                  onTap: _fetchDataAndSetState,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(5),
                                      color: Colors.red.withValues(alpha: 0.7),
                                    ),
                                    child: Padding(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: screenWidth * 0.2,
                                        vertical: screenWidth * 0.03,
                                      ),
                                      child: Text(
                                        'Try Again',
                                        style: TextStyle(
                                          fontSize: screenWidth * 0.04,
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
          )
        : RefreshIndicator(
            onRefresh: refresh,
            color: CustomColors.clrblack,
            backgroundColor: CustomColors.clrwhite,
            child: DefaultTabController(
              length: categorymodel.length + 1,
              initialIndex: widget.tabiIndex,
              child: CustomScrollView(
                physics: const NeverScrollableScrollPhysics(),
                slivers: [
                  SliverAppBar(
                    automaticallyImplyLeading: true,
                    toolbarHeight: screenHeight * 0.08,
                    backgroundColor: CustomColors.clrwhite,
                    title: Consumer<LanguageManager>(
                      builder: (BuildContext context, languageManager, child) {
                        return Text(
                          languageManager.selectedLanguage == 'English' ? 'Sangeet' : 'संगीत',
                          style: TextStyle(
                            fontSize: screenWidth * 0.06,
                            color: CustomColors.clrorange,
                            fontWeight: FontWeight.w500,
                          ),
                        );
                      },
                    ),
                    centerTitle: true,
                    actions: [
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
                        child: GestureDetector(
                          onTap: () => _showLanguageSelectionBottomSheet(context),
                          child: Icon(
                            Icons.translate,
                            size: screenWidth * 0.06,
                            color: CustomColors.clrorange,
                          ),
                        ),
                      ),
                    ],
                    bottom: PreferredSize(
                      preferredSize: Size.fromHeight(screenHeight * 0.08),
                      child: TabBar(
                        isScrollable: true,
                        splashFactory: NoSplash.splashFactory,
                        dividerColor: Colors.transparent,
                        tabAlignment: TabAlignment.start,
                        indicatorPadding: EdgeInsets.symmetric(horizontal: screenWidth * 0.03),
                        indicatorColor: CustomColors.clrorange,
                        padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.01),
                        tabs: tabs,
                      ),
                    ),
                  ),
                  SliverFillRemaining(
                    child: TabBarView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: tabViews,
                    ),
                  ),
                ],
              ),
            ),
          );
  }

  void _showLanguageSelectionBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Center(
                child: Text(
                  'Select language for Audio / Video',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: Consumer<LanguageManager>(
                  builder: (BuildContext context, languageManager, Widget? child) {
                    Future<void> refreshData() async {
                      try {
                        await languageManager.getLanguageData();
                      } catch (error) {
                        print('Error refreshing languages: $error');
                      }
                    }

                    if (languageManager.languagemodel.isEmpty) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: Colors.orange,
                          backgroundColor: Colors.white,
                        ),
                      );
                    }

                    final filteredLanguages = languageManager.languagemodel
                        .where((language) => language.status == 1)
                        .toList();

                    return RefreshIndicator(
                      onRefresh: refreshData,
                      color: Colors.black,
                      child: filteredLanguages.isEmpty
                          ? const Center(child: Text('No languages available'))
                          : GridView.builder(
                              shrinkWrap: true,
                              scrollDirection: Axis.vertical,
                              itemCount: filteredLanguages.length,
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                crossAxisSpacing: 16.0,
                                mainAxisSpacing: 16.0,
                              ),
                              itemBuilder: (context, index) {
                                return GestureDetector(
                                  onTap: () async {
                                    Provider.of<LanguageManager>(context, listen: false)
                                        .setLanguage(filteredLanguages[index].enName);
                                    
                                    final prefs = await SharedPreferences.getInstance();
                                    await prefs.setString('selectedLanguage', filteredLanguages[index].enName);
                                    
                                    print('Language selected: ${filteredLanguages[index].enName}');
                                    Navigator.pop(context);
                                  },
                                  child: LanguageContainer(
                                    color: Colors.red.shade700,
                                    language: filteredLanguages[index].name,
                                    nameIt: filteredLanguages[index].enName,
                                    isSelected: languageManager.selectedLanguage == filteredLanguages[index].enName,
                                    isRefresh: refresh,
                                  ),
                                );
                              },
                            ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class LanguageContainer extends StatelessWidget {
  final Color color;
  final String language;
  final String nameIt;
  final bool isSelected;
  final VoidCallback isRefresh;

  const LanguageContainer({
    super.key,
    required this.color,
    required this.language,
    required this.nameIt,
    this.isSelected = false,
    required this.isRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return GestureDetector(
      onTap: () {
        Provider.of<LanguageManager>(context, listen: false).setLanguage(nameIt);
        isRefresh();
        print('Language selected: $nameIt');
        Navigator.pop(context);
      },
      child: Container(
        decoration: BoxDecoration(
          color: color,
          borderRadius: isSelected ? BorderRadius.circular(10) : null,
          border: isSelected ? Border.all(color: Colors.orange, width: 8) : null,
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: Opacity(
                opacity: 0.3,
                child: Image(
                  image: const CachedNetworkImageProvider(
                    'https://www.shutterstock.com/image-vector/shri-mahakaleshwar-jyotirlinga-temple-vector-600nw-2447027639.jpg',
                  ),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: screenWidth * 0.8,
                    child: Text(
                      language,
                      style: const TextStyle(
                        fontSize: 20,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        overflow: TextOverflow.ellipsis,
                      ),
                      maxLines: 1,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    nameIt,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

