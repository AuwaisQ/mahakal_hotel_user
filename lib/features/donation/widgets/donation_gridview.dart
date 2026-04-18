import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../blogs_module/no_image_widget.dart';
import '../../mandir/view/custom_colors.dart';
import '../../youtube_vedios/view/dynamic_tabview/grid_view/YoutubeGridView.dart';
import '../controller/lanaguage_provider.dart';
import '../view/home_page/dynamic_view/dynamic_details/Detailspage.dart';
import '../view/home_page/static_view/all_home_page/static_details/Donationpage.dart';

/// Reusable donation card widget.
/// Just call `donationGridView(context, id, image, title, isStatic, receivedAmount, goalAmount)`
// Widget donationGridView(
//     BuildContext context,
//     String id,
//     String image,
//     String title,
//     bool isStatic, {
//       String? receivedAmount, // e.g. "2531.00"
//       String? goalAmount,     // e.g. "100000.00"
//       dynamic? amountProgress,     // e.g. "100000.00"
//     }) {
//   final screenWidth = MediaQuery.of(context).size.width;
//
//   // Parse progress safely
//   final double received = double.tryParse(receivedAmount ?? '0') ?? 0;
//   final double goal = double.tryParse(goalAmount ?? '0') ?? 0;
//  // final double progress = (goal > 0) ? (received / goal).clamp(0.0, 1.0) : 0.0;
//   final double progress = double.tryParse(amountProgress ?? '0') ?? 0.0;
//
//   return LayoutBuilder(
//     builder: (ctx, constraints) => GestureDetector(
//       onTap: () => isStatic
//           ? Navigator.push(
//         ctx,
//         CupertinoPageRoute(
//           builder: (_) => Donationpage(myId: int.parse(id)),
//         ),
//       )
//           : Navigator.push(
//         context,
//         CupertinoPageRoute(
//           builder: (context) => DetailsPage(
//             myId: int.parse(id),
//             image: image,
//           ),
//         ),
//       ),
//       child: Container(
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(12),
//           border: Border.all(color: Colors.orange.shade50),
//         ),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // ---------- Image ----------
//             Padding(
//               padding: const EdgeInsets.all(8.0),
//               child: ClipRRect(
//                 borderRadius:
//                 const BorderRadius.vertical(top: Radius.circular(12)),
//                 child: CachedNetworkImage(
//                   imageUrl: image ?? '',
//                   height: constraints.maxHeight * 0.40,
//                   width: double.infinity,
//                   fit: BoxFit.fill,
//                   placeholder: (context, url) => placeholderImage(),
//                   errorWidget: (context, url, error) => const NoImageWidget(),
//                 ),
//               ),
//             ),
//
//             // ---------- Title ----------
//             Padding(
//               padding: EdgeInsets.symmetric(
//                 horizontal: screenWidth * 0.03,
//               ),
//               child: Text(
//                 title,
//                 style: const TextStyle(
//                   fontSize: 18,
//                   color: CustomColors.clrblack,
//                   fontFamily: 'Roboto',
//                 ),
//                 maxLines: 1,
//                 overflow: TextOverflow.ellipsis,
//               ),
//             ),
//
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 5),
//               child: Divider(color: Colors.grey.shade300),
//             ),
//
//             // ---------- Progress Bar ----------
//             if (goal > 0) ...[
//               Padding(
//                 padding:
//                 const EdgeInsets.symmetric(horizontal: 15, vertical: 6),
//                 child: ClipRRect(
//                   borderRadius: BorderRadius.circular(10),
//                   child: LinearProgressIndicator(
//                     value: progress,
//                     minHeight: 8,
//                     backgroundColor: Colors.grey.shade300,
//                     valueColor:
//                     AlwaysStoppedAnimation<Color>(Colors.deepOrange),
//                   ),
//                 ),
//               ),
//
//               // ---------- Progress Text ----------
//               Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 15.0),
//                 child: Text(
//                   "₹${receivedAmount ?? '0'} Received $progress Out Of ₹${goalAmount ?? '0'}",
//                   style: TextStyle(
//                     fontSize: screenWidth * 0.035,
//                     fontWeight: FontWeight.w500,
//                     color: Colors.grey.shade800,
//                     fontFamily: 'Roboto',
//                   ),
//                 ),
//               ),
//             ],
//
//             const SizedBox(height: 6),
//
//             // ---------- Donate Button ----------
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 10),
//               child: Container(
//                 decoration: BoxDecoration(
//                   borderRadius: BorderRadius.circular(6),
//                   color: Colors.deepOrange,
//                 ),
//                 child: Padding(
//                   padding:
//                   const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
//                   child: Consumer<LanguageProvider>(
//                     builder: (_, lang, __) {
//                       final btnText = lang.language == 'english'
//                           ? 'Donate Now'
//                           : 'अभी दान करें';
//                       return Row(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           Text(
//                             btnText,
//                             style: TextStyle(
//                               fontSize: screenWidth * 0.037,
//                               fontWeight: FontWeight.bold,
//                               color: Colors.white,
//                               fontFamily: 'Roboto',
//                             ),
//                           ),
//                           SizedBox(width: screenWidth * 0.02),
//                           Image.asset(
//                             'assets/donation/heart1.png',
//                             height: screenWidth * 0.055,
//                             width: screenWidth * 0.055,
//                             color: Colors.white,
//                           ),
//                         ],
//                       );
//                     },
//                   ),
//                 ),
//               ),
//             ),
//
//             SizedBox(height: screenWidth * 0.02),
//           ],
//         ),
//       ),
//     ),
//   );
// }

Widget donationGridView(
  BuildContext context,
  String id,
  String image,
  String title,
  bool isStatic, {
  String? receivedAmount, // e.g. "10915"
  String? goalAmount, // e.g. "25000"
  dynamic? amountProgress, // e.g. "44"
}) {
  final screenWidth = MediaQuery.of(context).size.width;

  // Parse safe double values
  final double received = double.tryParse(receivedAmount ?? '0') ?? 0;
  final double goal = double.tryParse(goalAmount ?? '0') ?? 0;
  final double backendProgress =
      double.tryParse(amountProgress?.toString() ?? '0') ?? 0;

  // Compute percentage for display and progress bar value
  final double percent = goal > 0
      ? (backendProgress > 0 ? backendProgress : (received / goal) * 100)
      : 0;
  final double progressValue = (percent / 100).clamp(0.0, 1.0);

  return LayoutBuilder(
    builder: (ctx, constraints) => GestureDetector(
      onTap: () => isStatic
          ? Navigator.push(
              ctx,
              CupertinoPageRoute(
                builder: (_) => Donationpage(myId: int.parse(id)),
              ),
            )
          : Navigator.push(
              context,
              CupertinoPageRoute(
                builder: (context) => DetailsPage(
                  myId: int.parse(id),
                  image: image,
                ),
              ),
            ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.orange.shade50),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ---------- Image ----------
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(12)),
                child: CachedNetworkImage(
                  imageUrl: image,
                  height: constraints.maxHeight * 0.40,
                  width: double.infinity,
                  fit: BoxFit.fill,
                  placeholder: (context, url) => placeholderImage(),
                  errorWidget: (context, url, error) => const NoImageWidget(),
                ),
              ),
            ),

            // ---------- Title ----------
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: screenWidth * 0.03,
              ),
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  color: CustomColors.clrblack,
                  fontFamily: 'Roboto',
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5),
              child: Divider(color: Colors.grey.shade300),
            ),

            if (goal > 0) ...[
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 15, vertical: 6),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // --- Background progress bar ---
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: progressValue,
                        minHeight: 25,
                        backgroundColor: Colors.grey.shade300,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Colors.orange.shade600,
                        ),
                      ),
                    ),

                    // --- Percent text overlay ---
                    Positioned.fill(
                      child: Center(
                        child: Text(
                          "${percent.toStringAsFixed(0)}%",
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w500,
                            fontSize: screenWidth * 0.035,
                            fontFamily: 'Roboto',
                            shadows: [
                              Shadow(
                                color: Colors.black26,
                                offset: Offset(0.5, 0.5),
                                blurRadius: 2,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

               // --- Amount text below the bar ---
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 2),
                child: Text(
                  "₹${receivedAmount ?? '0'} Raised of ₹${goalAmount ?? '0'}",
                  style: TextStyle(
                    fontSize: screenWidth * 0.030,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade800,
                    fontFamily: 'Roboto',
                  ),
                ),
               ),
            ],

            // ---------- Progress Bar + Text ----------
            // if (goal > 0) ...[
            //   Padding(
            //     padding:
            //     const EdgeInsets.symmetric(horizontal: 15, vertical: 6),
            //     child: ClipRRect(
            //       borderRadius: BorderRadius.circular(10),
            //       child: LinearProgressIndicator(
            //         value: progressValue,
            //         minHeight: 14,
            //         backgroundColor: Colors.grey.shade300,
            //         valueColor:
            //         AlwaysStoppedAnimation<Color>(Colors.orange),
            //       ),
            //     ),
            //   ),
            //   // Padding(
            //   //   padding: const EdgeInsets.symmetric(horizontal: 15.0),
            //   //   child: Text(
            //   //     "₹${receivedAmount ?? '0'} Received (${percent.toStringAsFixed(0)}%) of ₹${goalAmount ?? '0'}",
            //   //     style: TextStyle(
            //   //       fontSize: screenWidth * 0.035,
            //   //       fontWeight: FontWeight.w500,
            //   //       color: Colors.grey.shade800,
            //   //       fontFamily: 'Roboto',
            //   //     ),
            //   //   ),
            //   // ),
            // ],

            //const SizedBox(height: 6),

            // ---------- Donate Button ----------
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                  color: Colors.deepOrange,
                ),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                  child: Consumer<LanguageProvider>(
                    builder: (_, lang, __) {
                      final btnText = lang.language == 'english'
                          ? 'Donate Now'
                          : 'अभी दान करें';
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            btnText,
                            style: TextStyle(
                              fontSize: screenWidth * 0.037,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontFamily: 'Roboto',
                            ),
                          ),
                          SizedBox(width: screenWidth * 0.02),
                          Image.asset(
                            'assets/donation/heart1.png',
                            height: screenWidth * 0.055,
                            width: screenWidth * 0.055,
                            color: Colors.white,
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),

            SizedBox(height: screenWidth * 0.02),
          ],
        ),
      ),
    ),
  );
}
