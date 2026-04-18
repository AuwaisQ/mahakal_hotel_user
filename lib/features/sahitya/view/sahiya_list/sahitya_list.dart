import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:mahakal/features/sahitya/model/sahitya_category_model.dart';
import '../../ui_helpers/custom_colors.dart';
import '../widgets/navigationUtils.dart';

class SahityaList extends StatelessWidget {
  final bool isEnglish;
  final List<SahityaData> sahityaData;
  final bool isLoading;

  const SahityaList(
      {super.key,
      required this.isEnglish,
      required this.sahityaData,
      required this.isLoading});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CustomColors.clrwhite,
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.orange))
          : sahityaData.isEmpty
              ? const Center(child: Text("No data found."))
              : ListView.builder(
                  itemCount: sahityaData.length,
                  itemBuilder: (context, index) {
                    final item = sahityaData[index];
                    final title =
                        isEnglish ? item.enName ?? '' : item.hiName ?? '';

                    return GestureDetector(
                      onTap: () =>
                          handleSahityaAction(item.enName ?? '', context),
                      child: Container(
                        margin: const EdgeInsets.all(10),
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey.shade200),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.2),
                              blurRadius: 2,
                              offset: const Offset(0, 1),
                            )
                          ],
                        ),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: CachedNetworkImage(
                                imageUrl: item.image ?? '',
                                height: 80,
                                width: 80,
                                fit: BoxFit.cover,
                                errorWidget: (_, __, ___) =>
                                    const Icon(Icons.broken_image),
                              ),
                            ),
                            const SizedBox(width: 20),
                            Expanded(
                              child: Text(
                                title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                  color: Colors.black,
                                  letterSpacing: 1,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Icon(Icons.arrow_circle_right_outlined,
                                color: Colors.orange, size: 30),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
