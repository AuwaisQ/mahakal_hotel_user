// import 'package:flutter/material.dart';
// import 'package:mahakal/features/explore/model/categorylist_model.dart';
// import 'package:mahakal/localization/language_constrants.dart';
//
// class PaidServicesGrid extends StatelessWidget {
//   const PaidServicesGrid({
//     super.key,
//     required this.servicesList,
//   });
//
//   final List<CategoryListModel> servicesList;
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       margin: const EdgeInsets.all(8),
//       padding: const EdgeInsets.all(12),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(16),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.orange.shade50,
//             blurRadius: 10,
//             spreadRadius: 2,
//             offset: const Offset(0, 6),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const Text(
//             "✨ Paid Services",
//             style: TextStyle(
//               fontSize: 20,
//               fontWeight: FontWeight.bold,
//               color: Colors.deepOrange,
//             ),
//           ),
//           const SizedBox(height: 12),
//
//           /// Row wise design
//           ListView.separated(
//             itemCount: servicesList.length,
//             shrinkWrap: true,
//             physics: const NeverScrollableScrollPhysics(),
//             separatorBuilder: (_, __) => const SizedBox(height: 12),
//             itemBuilder: (context, index) {
//               final item = servicesList[index];
//
//               return InkWell(
//                 onTap: () {
//                   debugPrint("Tapped on: ${item.name}");
//                 },
//                 child: Container(
//                   padding: const EdgeInsets.all(12),
//                   decoration: BoxDecoration(
//                     borderRadius: BorderRadius.circular(14),
//                     gradient: LinearGradient(
//                       colors: [
//                         Colors.orange.shade50,
//                         Colors.white,
//                       ],
//                       begin: Alignment.topLeft,
//                       end: Alignment.bottomRight,
//                     ),
//                     boxShadow: [
//                       BoxShadow(
//                         color: Colors.grey.withOpacity(0.15),
//                         blurRadius: 8,
//                         spreadRadius: 2,
//                         offset: const Offset(0, 4),
//                       ),
//                     ],
//                     border: Border.all(
//                       color: Colors.orange.shade100,
//                       width: 1,
//                     ),
//                   ),
//                   child: Row(
//                     children: [
//                       /// Image / Icon
//                       ClipRRect(
//                         borderRadius: BorderRadius.circular(10),
//                         child: Image.network(
//                           item.images,
//                           height: 55,
//                           width: 55,
//                           fit: BoxFit.cover,
//                           errorBuilder: (_, __, ___) => Container(
//                             height: 55,
//                             width: 55,
//                             decoration: BoxDecoration(
//                               color: Colors.orange.shade100,
//                               borderRadius: BorderRadius.circular(10),
//                             ),
//                             child: const Icon(Icons.star,
//                                 color: Colors.deepOrange, size: 28),
//                           ),
//                         ),
//                       ),
//                       const SizedBox(width: 14),
//
//                       /// Title
//                       Expanded(
//                         child: Text(
//                           getTranslated(item.name, context) ?? "Service",
//                           style: const TextStyle(
//                             fontSize: 16,
//                             fontWeight: FontWeight.w600,
//                             color: Colors.black87,
//                           ),
//                         ),
//                       ),
//
//                       const Icon(Icons.arrow_forward_ios,
//                           size: 16, color: Colors.deepOrange),
//                     ],
//                   ),
//                 ),
//               );
//             },
//           ),
//         ],
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:mahakal/features/explore/model/categorylist_model.dart';
import 'package:mahakal/localization/language_constrants.dart';

class PaidServicesGrid extends StatelessWidget {
  const PaidServicesGrid({
    super.key,
    required this.servicesList,
  });

  final List<CategoryListModel> servicesList;

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "✨ Premium Services",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 12),
        GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, // 2 items in a row
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.9, // Wide cards look
          ),
          itemCount: servicesList.length,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.02,
            vertical: 2,
          ),
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () {
                Navigator.push(context, servicesList[index].route);
              },
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Image.asset(
                  servicesList[index].images,
                  fit: BoxFit.fill,
                ),
              ),
            );
          },
        )
      ],
    );
  }
}
