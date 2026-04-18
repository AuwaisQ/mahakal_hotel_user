import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mahakal/features/youtube_vedios/view/dynamic_tabview/grid_view/YoutubeGridView.dart';
import '../../../data/datasource/remote/http/httpClient.dart';
import '../../../utill/app_constants.dart';
import '../../utill/images.dart';
import '../blogs_module/no_image_widget.dart';
import 'Model/all_pandit_model.dart';
import 'Pandit_Bottom_bar.dart';

class AllPanditPage extends StatefulWidget {
  bool isEngView;
  bool isHome;
  ScrollController scrollController;
  AllPanditPage(
      {super.key, required this.isEngView, required this.scrollController,required this.isHome});

  @override
  State<AllPanditPage> createState() => _AllPanditPageState();
}

class _AllPanditPageState extends State<AllPanditPage> {
  bool isGridView = false;
  bool isLoading = true;
  bool isLanguage = true;
  TextEditingController searchController = TextEditingController();

  String city = '';

  @override
  void initState() {
    super.initState();
    fetchAllPandit();
    //initCity();
  }

  List<AllPanditData> allPanditList = [];
  List<AllPanditData> filteredPanditList = [];

  Future<void> fetchAllPandit() async {
    setState(() {
      isLoading = true;
    });
    try {
      //String  url = "${AppConstants.allPanditUrl + city}";
      String url = AppConstants.allPanditUrl;
      final res = await HttpService().getApi(url);
      print('All Pandit List: $res');

      if (res != null) {
        final allPandit = AllPanditModel.fromJson(res);

        setState(() {
          allPanditList = allPandit.allPanditData ?? [];
          filteredPanditList = allPanditList;
          isLoading = false;
        });

        print('${allPanditList.length}');
      } else {
        print('Response is null');
        setState(() {
          allPanditList = [];
          filteredPanditList = [];
          isLoading = false;
        });
      }
    } catch (e) {
      print('fetching new vendor $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  void filterPandit(String query) {
    if (query.isEmpty) {
      setState(() {
        filteredPanditList = allPanditList;
      });
    } else {
      setState(() {
        filteredPanditList = allPanditList
            .where((pandit) =>
                pandit.enName!.toLowerCase().contains(query.toLowerCase()))
            .toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(
              color: Colors.orange,
            ))
          : CustomScrollView(
              controller: widget.scrollController,
              slivers: [
                // Header Sliver (fixed at top)
                SliverAppBar(
                  backgroundColor: Colors.deepOrange.shade50,
                  expandedHeight: 160,
                  pinned: false,
                  floating: false,
                  automaticallyImplyLeading: false,
                  flexibleSpace: FlexibleSpaceBar(
                    background: Container(
                      padding: const EdgeInsets.fromLTRB(20, 46, 20, 16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.deepOrange.shade50,
                            Colors.orange.shade50,
                          ],
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              if(widget.isHome)
                              InkWell(
                                  onTap: ()=> Navigator.pop(context),
                                  child: Icon(Icons.arrow_back_ios_new_rounded,color: Colors.deepOrange.shade700,)),
                              const SizedBox(width: 10,),
                              Text(
                                isLanguage ? "ALL GURUJI'S" : 'सभी गुरुजी',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.deepOrange.shade700,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              Spacer(),
                              InkWell(
                                onTap: () {
                                  setState(() {
                                    isLanguage = !isLanguage;
                                  });
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                        color: isLanguage
                                            ? Colors.white
                                            : Colors.deepOrange),
                                    color: isLanguage
                                        ? Colors.deepOrange
                                        : Colors.white,
                                    boxShadow: [
                                      BoxShadow(
                                        color:
                                        Colors.deepOrange.withOpacity(0.15),
                                        blurRadius: 10,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Icon(
                                    isLanguage
                                        ? Icons.translate_rounded
                                        : Icons.translate,
                                    size: 26,
                                    color:
                                    isLanguage ? Colors.white : Colors.black,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            isLanguage
                                ? 'Find your desired Guruji and book your favourite session.'
                                : 'मनपसंद गुरुजी खोजें और उनसे मार्गदर्शन पाएं।',
                            style: const TextStyle(
                              fontSize: 13,
                              color: Colors.black54,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  /// 🔍 Search Bar
                  bottom: PreferredSize(
                    preferredSize: const Size.fromHeight(80),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 1,
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(14),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.deepOrange.withOpacity(0.15),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: TextField(
                                controller: searchController,
                                cursorColor: Colors.deepOrange,
                                onChanged: filterPandit,
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: Colors.white,
                                  hintText: isLanguage
                                      ? 'Search Guruji...'
                                      : 'गुरुजी खोजें...',
                                  hintStyle: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey.shade500,
                                  ),
                                  prefixIcon: Icon(
                                    Icons.search_rounded,
                                    color: Colors.deepOrange.shade400,
                                  ),

                                  /// ❌ Clear + 🔍 Search Button inside
                                  suffixIcon: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      if (searchController.text.isNotEmpty)
                                        IconButton(
                                          icon: Icon(
                                            Icons.close_rounded,
                                            color: Colors.grey.shade500,
                                          ),
                                          onPressed: () {
                                            searchController.clear();
                                            filterPandit('');
                                          },
                                        ),
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(right: 6),
                                        child: ElevatedButton(
                                          onPressed: () {
                                            filterPandit(searchController.text);
                                            HapticFeedback.lightImpact();
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.deepOrange,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 14,
                                              vertical: 10,
                                            ),
                                            elevation: 0,
                                          ),
                                          child: Row(
                                            children: [
                                              const Icon(Icons.search,
                                                  size: 16,
                                                  color: Colors.white),
                                              const SizedBox(width: 4),
                                              Text(
                                                isLanguage
                                                    ? 'Search'
                                                    : 'खोजें',
                                                style: const TextStyle(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w600,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                      vertical: 16, horizontal: 16),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(14),
                                    borderSide: BorderSide.none,
                                  ),
                                ),
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Expanded(
                            flex: 0,
                            child: InkWell(
                              onTap: () {
                                setState(() {
                                  isGridView = !isGridView;
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                      color: isGridView
                                          ? Colors.white
                                          : Colors.deepOrange),
                                  color: isGridView
                                      ? Colors.deepOrange
                                      : Colors.white,
                                  boxShadow: [
                                    BoxShadow(
                                      color:
                                          Colors.deepOrange.withOpacity(0.15),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  isGridView
                                      ? Icons.list
                                      : Icons.grid_view_rounded,
                                  size: 26,
                                  color:
                                      isGridView ? Colors.white : Colors.black,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Pandit List Grid
                if (filteredPanditList.isEmpty)
                  SliverFillRemaining(
                    child: Center(
                      child: Text(
                        isLanguage
                            ? 'No Guruji Found'
                            : 'कोई गुरुजी नहीं मिले',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ),
                  )
                else
                  isGridView
                      ? SliverGrid(
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: 2,
                            crossAxisSpacing: 2,
                            childAspectRatio: 0.75,
                          ),
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final pandit = filteredPanditList[index];
                              return _buildCleanGridCard(pandit, context);
                            },
                            childCount: filteredPanditList.length,
                          ),
                        )
                      : SliverGrid(
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 1,
                            mainAxisSpacing: 12,
                            childAspectRatio: 1.5,
                          ),
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final pandit = filteredPanditList[index];
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 6),
                                child: InkWell(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => PanditBottomBar(
                                          panditId: pandit.id,
                                          pageIndex: 0,
                                          sellerId: pandit.sellerId,
                                          astroImage: '${pandit.image}', isLang: isLanguage,
                                        ),
                                      ),
                                    );
                                  },
                                  child: _buildStoreCard(pandit),
                                ),
                              );
                            },
                            childCount: filteredPanditList.length,
                          ),
                        ),

                const SliverToBoxAdapter(
                  child: SizedBox(
                    height: 50,
                  ),
                )
              ],
            ),
    );
  }

  Widget _buildStoreCard(AllPanditData panditData) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: const Border(
          bottom: BorderSide(
            color: Colors.deepOrange,
            width: 1.0,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // TOP IMAGE WITH STACK
          Stack(
            clipBehavior: Clip.none,
            children: [
              // Background image
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
                child: CachedNetworkImage(
                  imageUrl: '${panditData.banner}',
                  height: 100,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => placeholderImage(),
                  errorWidget: (c, o, s) => Image.asset(Images.placeholder, fit: BoxFit.fill,),
                ),
              ),

              // Circle icon overlapping (positioned)
              Positioned(
                bottom: -63,
                left: 12,
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: Colors.deepOrange.shade50,
                      child: ClipOval(
                        child: CachedNetworkImage(
                          imageUrl: '${panditData.image}',
                          fit: BoxFit.cover,
                          width: 80,
                          height: 80,
                          placeholder: (context, url) => placeholderImage(),
                          errorWidget: (context, url, error) => const NoImageWidget(),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(height: 8),
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.5,
                            child: Text(
                              isLanguage ? '${panditData.enName}' :'${panditData.hiName}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              ...List.generate(5, (index) {
                                double rating =
                                    double.tryParse('5.0' ?? '0') ?? 0.0;

                                if (rating >= index + 1) {
                                  return const Icon(Icons.star,
                                      color: Colors.orange, size: 20);
                                } else if (rating > index &&
                                    rating < index + 1) {
                                  return const Icon(Icons.star_half,
                                      color: Colors.orange, size: 20);
                                } else {
                                  return const Icon(Icons.star_border,
                                      color: Colors.orange, size: 20);
                                }
                              }),
                              const SizedBox(width: 6),
                              Text(
                                "(${(double.tryParse("5.0" ?? "0") ?? 0.0).toStringAsFixed(1)})",
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 65),

          // Bottom info row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _infoBox('${5}', isLanguage ? 'Review' :'रिव्यु'),
                _infoBox('${panditData.isPanditPoojaCategory?.length}', isLanguage?'Services':'सेवाएँ'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoBox(String value, String label) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: value == '0' ? Colors.orange : Colors.deepOrange,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              label,
              style: const TextStyle(
                  fontSize: 15,
                  color: Colors.black87,
                  fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

// Modern Grid Card Design
  Widget _buildCleanGridCard(AllPanditData pandit, BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PanditBottomBar(
                panditId: pandit.id,
                pageIndex: 0,
                sellerId: pandit.sellerId,
                astroImage: '${pandit.image}',
                isLang: isLanguage,
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(18),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.08),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              // TOP BANNER SECTION
              Stack(
                children: [
                  // Banner Image
                  Container(
                    height: 80,
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(18),
                        topRight: Radius.circular(18),
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(18),
                        topRight: Radius.circular(18),
                      ),
                      child: CachedNetworkImage(
                        imageUrl: pandit.image!,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: 80,
                        placeholder: (context, url) => placeholderImage(),
                        errorWidget: (context, url, error) => const NoImageWidget()
                      ),
                    ),
                  ),

                  // // Circle Profile Image positioned at bottom center of banner
                  // Positioned(
                  //   bottom: 0,
                  //   left: 0,
                  //   right: 0,
                  //   child: Center(
                  //     child: Container(
                  //       width: 60,
                  //       height: 60,
                  //       decoration: BoxDecoration(
                  //         shape: BoxShape.circle,
                  //         border: Border.all(
                  //           color: Colors.white,
                  //           width: 3,
                  //         ),
                  //         boxShadow: [
                  //           BoxShadow(
                  //             color: Colors.black.withOpacity(0.1),
                  //             blurRadius: 8,
                  //             offset: Offset(0, 2),
                  //           ),
                  //         ],
                  //       ),
                  //       child: ClipOval(
                  //         child: pandit.image != null && pandit.image!.isNotEmpty
                  //             ? Image.network(
                  //           pandit.image!,
                  //           fit: BoxFit.cover,
                  //         )
                  //             : Container(
                  //           color: Colors.deepOrange.shade200,
                  //           child: Icon(
                  //             Icons.person,
                  //             size: 28,
                  //             color: Colors.white,
                  //           ),
                  //         ),
                  //       ),
                  //     ),
                  //   ),
                  // ),
                ],
              ),

              // CONTENT SECTION (Starts right after circle image)
              const SizedBox(height: 20), // Space for the circle image

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Column(
                  children: [
                    // Name
                    Text(isLanguage ? '${pandit.enName}' :'${pandit.hiName}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 6),

                    // Rating
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.amber.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.star,
                            size: 14,
                            color: Colors.amber,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '4.8/5',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Colors.amber.shade800,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '(120)',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Services Count
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.deepOrange.withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Colors.deepOrange,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.work_outline,
                              size: 12,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            "${pandit.isPanditPoojaCategory?.length} ${isLanguage ? 'Services' : 'सेवाएँ'}",
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Colors.deepOrange.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),

              // BOTTOM ACCENT LINE
              Container(
                height: 2,
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(18),
                    bottomRight: Radius.circular(18),
                  ),
                  gradient: LinearGradient(
                    colors: [
                      Colors.deepOrange,
                      Colors.orange,
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
