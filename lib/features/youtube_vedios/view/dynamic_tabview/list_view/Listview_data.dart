import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../../../utill/app_constants.dart';
import '../../../model/subcategory_model.dart';
import '../../../ui_helper/custom_colors.dart';
import '../../../utils/api_service.dart';
import '../../tabsscreenviews/Playlist_Tab_Screen.dart';

class ListviewData extends StatefulWidget {
  const ListviewData({
    super.key,
    required this.categoryName,
    required this.categoryId,
  });

  final String categoryName;
  final int categoryId;

  @override
  State<ListviewData> createState() => _ListviewDataState();
}

class _ListviewDataState extends State<ListviewData> {
  bool _isLoading = false;
  List<KathaModel> subcategory = [];

  @override
  void initState() {
    super.initState();
    _loadSubcategoryData();
  }

  Future<void> _loadSubcategoryData() async {
    if (mounted) setState(() => _isLoading = true);

    try {
      final url =
          '${AppConstants.baseUrl}${AppConstants.youtubeSubCategoryUrl}${widget.categoryId}';
      final response = await ApiService().getSubcategory(url);
      final subCategoryData = kathaModelFromJson(jsonEncode(response));

      if (mounted) {
        setState(() => subcategory = subCategoryData);
      }
    } catch (e) {
      debugPrint('Error loading youtube subcategory data: $e');
      // Consider showing an error to the user
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
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
  }

  @override
  Widget build(BuildContext context) {
    final filteredCategories =
        subcategory.where((cat) => cat.status != 0).toList();

    return SafeArea(
      child: _isLoading
          ? const _LoadingIndicator()
          : filteredCategories.isEmpty
              ? const _EmptyState()
              : _ContentList(
                  categories: filteredCategories,
                  onItemTap: _navigateToTabsScreen,
                ),
    );
  }
}

class _LoadingIndicator extends StatelessWidget {
  const _LoadingIndicator();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: CustomColors.clrwhite,
      body: Center(
        child: CircularProgressIndicator(color: Colors.orange),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text("No Data Available!")),
    );
  }
}

class _ContentList extends StatelessWidget {
  final List<KathaModel> categories;
  final Function(KathaModel) onItemTap;

  const _ContentList({
    required this.categories,
    required this.onItemTap,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CustomColors.clrwhite,
      body: ListView.builder(
        itemCount: categories.length,
        shrinkWrap: true,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(vertical: 10),
        itemBuilder: (context, index) {
          return _ListItem(
            category: categories[index],
            onTap: () => onItemTap(categories[index]),
          );
        },
      ),
    );
  }
}

class _ListItem extends StatelessWidget {
  final KathaModel category;
  final VoidCallback onTap;

  const _ListItem({
    required this.category,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.all(10),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: Colors.white,
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 3,
              blurRadius: 2,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Row(
          children: [
            _CategoryImage(category: category),
            const Spacer(),
            _CategoryName(category: category),
            const Spacer(),
            const _ArrowIcon(),
          ],
        ),
      ),
    );
  }
}

class _CategoryImage extends StatelessWidget {
  final KathaModel category;

  const _CategoryImage({required this.category});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 10),
      height: 80,
      width: 80,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        image: DecorationImage(
          image: CachedNetworkImageProvider(
            "${AppConstants.baseUrl}/storage/app/public/video-subcategory-img/${category.image}",
          ),
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}

class _CategoryName extends StatelessWidget {
  final KathaModel category;

  const _CategoryName({required this.category});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: 2,
      child: Text(
        category.name,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 20,
          color: Colors.black,
          letterSpacing: 1,
          overflow: TextOverflow.ellipsis,
        ),
        maxLines: 1,
      ),
    );
  }
}

class _ArrowIcon extends StatelessWidget {
  const _ArrowIcon();

  @override
  Widget build(BuildContext context) {
    return const Icon(
      Icons.arrow_circle_right_outlined,
      color: Colors.orange,
      size: 30,
    );
  }
}
