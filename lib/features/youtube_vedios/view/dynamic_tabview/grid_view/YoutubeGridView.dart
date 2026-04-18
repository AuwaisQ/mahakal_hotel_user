import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mahakal/features/blogs_module/no_image_widget.dart';
import 'package:mahakal/features/youtube_vedios/view/tabsscreenviews/Playlist_Tab_Screen.dart';
import 'package:mahakal/utill/app_constants.dart';
import 'package:provider/provider.dart';
import '../../../../donation/controller/lanaguage_provider.dart';
import '../../../model/subcategory_model.dart';
import '../../../ui_helper/custom_colors.dart';
import '../../../utils/api_service.dart';

class YoutubeGridView extends StatefulWidget {
  const YoutubeGridView({
    super.key,
    required this.categoryName,
    required this.categoryId,
    required this.isSearchClicked,
  });

  final String categoryName;
  final int categoryId;
  final bool isSearchClicked;

  @override
  State<YoutubeGridView> createState() => _YoutubeGridViewState();
}

class _YoutubeGridViewState extends State<YoutubeGridView> {
  late final TextEditingController _searchController;
  bool _isLoading = false;
  List<KathaModel> subcategory = [];
  List<KathaModel> filteredCategories = [];

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _loadSubcategoryData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadSubcategoryData() async {
    if (mounted) setState(() => _isLoading = true);

    try {
      final url =
          '${AppConstants.baseUrl}${AppConstants.youtubeSubCategoryUrl}${widget.categoryId}';
      final response = await ApiService().getSubcategory(url);
      final subCategoryData = kathaModelFromJson(jsonEncode(response));

      if (mounted) {
        setState(() {
          subcategory = subCategoryData;
          filteredCategories =
              subCategoryData.where((cat) => cat.status != 0).toList();
        });
      }
    } catch (e) {
      debugPrint('Error loading subcategory data: $e');
      // Consider showing an error to the user
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _filterSearch(String query) {
    setState(() {
      filteredCategories = subcategory
          .where(
              (item) => item.name.toLowerCase().contains(query.toLowerCase()))
          .where((cat) => cat.status != 0)
          .toList();
    });
  }

  void _clearSearch() {
    _searchController.clear();
    _filterSearch('');
  }

  void _navigateToTabsScreen(KathaModel category) {
    Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (context) => PlaylistTabScreen(
          subCategoryId: category.id,
          categoryName: widget.categoryName,
        ),
      ),
    );
    _clearSearch();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: CustomColors.clrwhite,
        body: Center(
          child: CircularProgressIndicator(color: Colors.orange),
        ),
      );
    }

    return SafeArea(
      child: Scaffold(
        backgroundColor: CustomColors.clrwhite,
        body: Column(
          children: [
            if (widget.isSearchClicked) _buildSearchField(),
            _buildCategoryGrid(),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchField() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SizedBox(
        height: 45,
        child: TextField(
          controller: _searchController,
          onChanged: _filterSearch,
          decoration: InputDecoration(
            hintText: 'Search by name...',
            hintStyle: const TextStyle(color: Colors.grey),
            suffixIcon: IconButton(
              icon: const Icon(Icons.close),
              onPressed: _clearSearch,
            ),
            prefixIcon: const Icon(Icons.search),
            border: _buildInputBorder(Colors.grey),
            enabledBorder: _buildInputBorder(Colors.grey),
            focusedBorder: _buildInputBorder(Colors.orange),
          ),
        ),
      ),
    );
  }

  InputBorder _buildInputBorder(Color color) {
    return OutlineInputBorder(
      borderSide: BorderSide(color: color, width: 2.0),
      borderRadius: BorderRadius.circular(10),
    );
  }

  Widget _buildCategoryGrid() {
    if (filteredCategories.isEmpty) {
      return const Expanded(
        child: Center(child: Text("No Data Available!")),
      );
    }

    final screenSize = MediaQuery.of(context).size;
    final crossAxisCount = screenSize.width < 600 ? 2 : 3;

    return Expanded(
      child: GridView.builder(
        shrinkWrap: true,
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.symmetric(
          horizontal: screenSize.width * 0.02,
          vertical: screenSize.width * 0.04,
        ),
        itemCount: filteredCategories.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
          childAspectRatio: 0.77, // Better for 3D cards
        ),
        itemBuilder: (context, index) {
          return SpiritualMediaCard(
            category: filteredCategories[index],
            onTap: () => _navigateToTabsScreen(filteredCategories[index]),
          );
        },
      ),
    );
  }
}

/// interactions, and Material‑you aesthetics.
class SpiritualMediaCard extends StatelessWidget {
  const SpiritualMediaCard({
    super.key,
    required this.category,
    required this.onTap,
  });

  final KathaModel category;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>().language;
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Card(
        elevation: 6,
        shadowColor: theme.colorScheme.primary.withOpacity(.25),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// IMAGE + OVERLAYS
            Stack(
              children: [
                AspectRatio(
                  aspectRatio: 1,
                  child: CachedNetworkImage(
                    imageUrl:
                        "${AppConstants.baseUrl}/storage/app/public/video-subcategory-img/${category.image}",
                    fit: BoxFit.fill,
                    placeholder: (c, _) => placeholderImage(),
                    errorWidget: (_, __, ___) => const NoImageWidget(),
                  ),
                ),

                // PLAY ICON (bottom‑right)
                const Positioned(
                  right: 12,
                  bottom: 12,
                  child: _PlayButton(),
                ),
              ],
            ),

            /// TITLE
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Text(
                lang == 'english' ? category.name : (category.hiName ?? ''),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  color: Colors.deepOrange,
                  fontSize: 17,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Widget placeholderImage() {
  return Container(
    child: Image.asset(
      'assets/images/mahakal.jpeg',
      fit: BoxFit.cover,
    ),
  );
}

class _PlayButton extends StatelessWidget {
  const _PlayButton();
  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withOpacity(.15),
      shape: const CircleBorder(),
      child: const Padding(
        padding: EdgeInsets.all(8.0),
        child: Icon(Icons.play_arrow_rounded, color: Colors.white, size: 28),
      ),
    );
  }
}
