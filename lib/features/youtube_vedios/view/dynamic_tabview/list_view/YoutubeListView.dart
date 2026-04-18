import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../../../utill/app_constants.dart';
import '../../../../blogs_module/no_image_widget.dart' show NoImageWidget;
import '../../../model/subcategory_model.dart';
import '../../../ui_helper/custom_colors.dart';
import '../../../utils/api_service.dart';
import '../../tabsscreenviews/Playlist_Tab_Screen.dart';
import '../grid_view/YoutubeGridView.dart';

class YoutubeListView extends StatefulWidget {
  final String categoryName;
  final int categoryId;

  const YoutubeListView({
    super.key,
    required this.categoryName,
    required this.categoryId,
  });

  @override
  State<YoutubeListView> createState() => _YoutubeListViewState();
}

class _YoutubeListViewState extends State<YoutubeListView> {
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
        setState(() => subcategory =
            subCategoryData.where((cat) => cat.status != 0).toList());
      }
    } catch (e) {
      debugPrint('Error loading youtube subcategory data: $e');
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
    return SafeArea(
      child: Scaffold(
        backgroundColor: CustomColors.clrwhite,
        body: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: Colors.orange))
            : subcategory.isEmpty
                ? const Center(child: Text("No Data Available!"))
                : ListView.builder(
                    itemCount: subcategory.length,
                    shrinkWrap: true,
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    itemBuilder: (context, index) {
                      final category = subcategory[index];
                      return GestureDetector(
                        onTap: () => _navigateToTabsScreen(category),
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
                              )
                            ],
                          ),
                          child: Row(
                            children: [
                              // Image
                              Container(
                                margin: const EdgeInsets.only(left: 10),
                                height: 80,
                                width: 80,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  color: Colors.grey[
                                      200], // Background color for loading/error states
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: CachedNetworkImage(
                                    imageUrl:
                                        "${AppConstants.baseUrl}/storage/app/public/video-subcategory-img/${category.image}",
                                    fit: BoxFit.cover,
                                    width: 80,
                                    height: 80,
                                    placeholder: (c, _) => placeholderImage(),
                                    errorWidget: (_, __, ___) =>
                                        const NoImageWidget(),
                                  ),
                                ),
                              ),

                              const Spacer(),

                              // Category Name
                              Expanded(
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
                              ),

                              const Spacer(),

                              // Arrow Icon
                              const Icon(
                                Icons.arrow_circle_right_outlined,
                                color: Colors.orange,
                                size: 30,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}
