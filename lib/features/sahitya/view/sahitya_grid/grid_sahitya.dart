import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:mahakal/features/blogs_module/no_image_widget.dart';
import '../../../youtube_vedios/view/dynamic_tabview/grid_view/YoutubeGridView.dart';
import '../../model/sahitya_category_model.dart';
import '../widgets/navigationUtils.dart';

class GridSahitya extends StatelessWidget {
  final bool isEnglish;
  final List<SahityaData> sahityaData;
  final bool isLoading;

  const GridSahitya({
    super.key,
    required this.isEnglish,
    required this.sahityaData,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? const Center(child: CircularProgressIndicator(color: Colors.orange))
        : sahityaData.isEmpty
            ? const Center(child: Text("No Data Found"))
            : Padding(
                padding: const EdgeInsets.all(8.0),
                child: GridView.builder(
                  physics: const BouncingScrollPhysics(),
                  itemCount: sahityaData.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 13,
                    mainAxisSpacing: 13,
                    childAspectRatio: 0.81,
                  ),
                  itemBuilder: (context, index) {
                    final item = sahityaData[index];
                    return TweenAnimationBuilder(
                      duration: const Duration(milliseconds: 400),
                      tween: Tween<double>(begin: 0, end: 1),
                      curve: Curves.easeOutBack,
                      builder: (context, value, child) {
                        return Transform.scale(
                          scale: value,
                          child: Transform(
                            transform: Matrix4.identity()
                              ..setEntry(3, 2, 0.001)
                              ..rotateY(0.15),
                            alignment: Alignment.center,
                            child: Book3DCard(
                              index: index,
                              bookData: item,
                              isEnglish: isEnglish,
                              onTap: () => handleSahityaAction(
                                  item.enName ?? '', context),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              );
  }
}

class Book3DCard extends StatelessWidget {
  final int index;
  final dynamic bookData;
  final bool isEnglish;
  final VoidCallback onTap;

  const Book3DCard({
    super.key,
    required this.index,
    required this.bookData,
    required this.isEnglish,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        /// 1. BOOK SPINE (RIGHT SIDE NOW)
        Positioned(
          right: 0, // Changed to right
          top: 8,
          bottom: 8,
          width: 15,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.brown.shade100,
              borderRadius: const BorderRadius.horizontal(
                right: Radius.circular(4), // Flipped to right
              ),
            ),
          ),
        ),

        /// 2. MAIN BOOK COVER (FLIPPED)
        Positioned.fill(
          right: 8, // Changed to right
          child: Card(
            elevation: 12,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.horizontal(
                left: Radius.circular(12), // Flipped curvature
                right: Radius.circular(4),
              ),
            ),
            //shadowColor: Colors.amber.withOpacity(0.4),
            child: InkWell(
              borderRadius: const BorderRadius.horizontal(
                left: Radius.circular(12),
                right: Radius.circular(4),
              ),
              onTap: onTap,
              splashColor: Colors.amber.withOpacity(0.3),
              highlightColor: Colors.orange.withOpacity(0.15),
              child: ClipRRect(
                borderRadius: const BorderRadius.horizontal(
                  left: Radius.circular(12),
                  right: Radius.circular(4),
                ),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Hero(
                      tag: 'book_${bookData.image}',
                      child: CachedNetworkImage(
                          imageUrl: bookData.image,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => placeholderImage(),
                          errorWidget: (context, url, error) =>
                              const NoImageWidget()),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
