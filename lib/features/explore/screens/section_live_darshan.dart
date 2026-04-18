import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mahakal/features/youtube_vedios/model/newtabs_model.dart';
import 'package:mahakal/features/youtube_vedios/view/tabsscreenviews/all_videos/all_videos.dart';
import 'package:mahakal/features/youtube_vedios/view/tabsscreenviews/Playlist_Tab_Screen.dart';
import 'package:mahakal/localization/language_constrants.dart';
import 'package:mahakal/utill/dimensions.dart';
import '../model/sectionmodel.dart';

class SectionLiveDarshan extends StatelessWidget {
  const SectionLiveDarshan({
    super.key,
    required this.sectionModelList,
    required this.size,
    required this.dynamicTabs,
    required this.allVideos,
  });

  final List<Sectionlist> sectionModelList;
  final Size size;
  final DynamicTabs? dynamicTabs;
  final List<Video> allVideos;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        sectionModelList[12].section.status == "true"
            ? Column(children: [
                Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(7),
                    margin: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 6.0),
                    decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(10)),
                    child: Row(
                      children: [
                        Container(
                          height: 15,
                          width: 4,
                          decoration: BoxDecoration(
                              color: Colors.orange,
                              borderRadius: BorderRadius.circular(20)),
                        ),
                        const SizedBox(
                          width: 5,
                        ),
                        Text(
                          getTranslated('live_darshan', context) ??
                              "live_darshan",
                          style: TextStyle(
                              fontSize: Dimensions.fontSizeLarge,
                              fontWeight: FontWeight.bold),
                        ),
                        const Spacer(),
                        InkWell(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  CupertinoPageRoute(
                                      builder: (context) =>
                                          const PlaylistTabScreen(
                                            subCategoryId: 178,
                                            categoryName: "Live",
                                          )));
                            },
                            child: Text(
                              getTranslated('VIEW_ALL', context) ?? "View",
                              style: TextStyle(
                                  color: Colors.orange,
                                  fontSize: Dimensions.fontSizeLarge,
                                  fontWeight: FontWeight.bold),
                            )),
                      ],
                    )),
                const SizedBox(height: 5),
                Padding(
                  padding: const EdgeInsets.only(left: 10, top: 3),
                  child: SizedBox(
                    height: size.width * 0.6,
                    width: size.width,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: allVideos.length,
                      itemBuilder: (BuildContext ctx, index) {
                        return InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              CupertinoPageRoute(
                                builder: (context) => SingleVideoPlayer(
                                  playlist: dynamicTabs!.data[0],
                                  allVideos: allVideos,
                                  video: allVideos[index].url,
                                  isNamePassed: true,
                                  videoTitle: allVideos[index].title,
                                ),
                              ),
                            );
                          },
                          child: Container(
                            margin: const EdgeInsets.only(right: 10),
                            width: 280,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade300),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  flex: 2,
                                  child: ClipRRect(
                                    borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(10),
                                      topRight: Radius.circular(10),
                                    ),
                                    child: CachedNetworkImage(
                                      imageUrl: allVideos[index].image,
                                      fit: BoxFit.fill,
                                      width: 280,
                                      errorWidget: (context, url, error) =>
                                          const Icon(Icons.error),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: Padding(
                                    padding:
                                        const EdgeInsets.only(left: 10, top: 5),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            allVideos[index].title,
                                            style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.w400,
                                            ),
                                            maxLines: 2,
                                          ),
                                        ),
                                        const SizedBox(height: 5.0),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 15),
              ])
            : const SizedBox.shrink(),
      ],
    );
  }
}
