import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mahakal/features/donation/controller/lanaguage_provider.dart';
import 'package:provider/provider.dart';
import '../view/home_page/dynamic_view/dynamic_details/Detailspage.dart';
import '../view/home_page/static_view/all_home_page/static_details/Donationpage.dart';

Widget donationListView(BuildContext context, String id, String image,
    String title, bool isStatic) {
  var screenHeight = MediaQuery.of(context).size.height;
  var screenWidth = MediaQuery.of(context).size.width;

  return Container(
    margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    padding: const EdgeInsets.all(10),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(8),
      color: Colors.white,
      border: Border.all(color: Colors.grey),
    ),
    child: GestureDetector(
      onTap: () => isStatic
          ? Navigator.push(
              context,
              CupertinoPageRoute(
                  builder: (_) => Donationpage(
                        myId: int.parse(id),
                      )))
          : Navigator.push(
              context,
              CupertinoPageRoute(
                builder: (context) => DetailsPage(
                  myId: int.parse(id),
                  image: image,
                ),
              )),
      child: Row(
        children: [
          Container(
            height: screenHeight * 0.11,
            width: screenHeight * 0.17,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: CachedNetworkImage(
                imageUrl: image ?? "",
                fit: BoxFit.fill,
                placeholder: (context, url) => Container(
                  color: Colors.grey[300],
                  child: const Center(child: CircularProgressIndicator()),
                ),
                errorWidget: (context, url, error) => Container(
                  color: Colors.grey[300],
                  child: const Center(
                      child: Icon(Icons.broken_image, color: Colors.grey)),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title ?? "N/A",
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: screenWidth * 0.04,
                    color: Colors.black,
                    fontFamily: 'Roboto',
                    overflow: TextOverflow.ellipsis,
                  ),
                  maxLines: 2,
                ),
                SizedBox(height: screenWidth * 0.02),
                Container(
                  height: 40,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.deepOrange,
                  ),
                  child: Consumer<LanguageProvider>(
                    builder: (context, languageProvider, child) {
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            languageProvider.language == "english"
                                ? "Donate Now"
                                : "अभी दान करें",
                            style: TextStyle(
                              fontSize: screenWidth * 0.04,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Roboto',
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(width: screenWidth * 0.02),
                          Image.asset(
                            "assets/donation/heart1.png",
                            height: 25,
                            color: Colors.white,
                          ),
                        ],
                      );
                    },
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
