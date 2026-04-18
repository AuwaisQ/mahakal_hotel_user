import 'dart:convert';
import 'dart:math' as math;
import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart' show ImagePicker, ImageSource;
import 'package:mahakal/features/mandir/model/mandir_model.dart';
import 'package:share_plus/share_plus.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import '../../../data/datasource/remote/http/httpClient.dart';
import 'package:flutter/cupertino.dart';
import '../../../utill/app_constants.dart';
import 'package:image_picker/image_picker.dart';

import 'package:flutter/rendering.dart';

import 'edit_image_screen.dart';
// import 'edit_video_screen.dart';

// Wallpaper model
class Wallpaper {
  int? status;
  List<Data>? data;

  Wallpaper({this.status, this.data});

  Wallpaper.fromJson(Map<String, dynamic> json) {
    status = json['status'];

    if (json['data'] != null) {
      data = <Data>[];

      var rawData = json['data'];

      // If data is String (JSON string), decode it first
      if (rawData is String) {
        rawData = jsonDecode(rawData);
      }

      if (rawData is List) {
        for (var v in rawData) {
          data!.add(Data.fromJson(v));
        }
      }
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Data {
  int? id;
  String? enName;
  String? hiName;
  String? thumbnail;
  List<String>? wallpapers;
  String? week;
  dynamic date;

  Data({
    this.id,
    this.enName,
    this.hiName,
    this.thumbnail,
    this.wallpapers,
    this.week,
    this.date,
  });

  Data.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    enName = json['en_name'];
    hiName = json['hi_name'];
    thumbnail = json['thumbnail'];

    print(
        "🟢 Parsing ${json['en_name']} → wallpapers raw: ${json['wallpapers']}"); // 👈 add this

    wallpapers = [];
    if (json['wallpapers'] != null && json['wallpapers'] is List) {
      for (var w in json['wallpapers']) {
        if (w is String && w.isNotEmpty) {
          wallpapers!.add(w);
        } else if (w is Map && w['image'] != null) {
          wallpapers!.add(w['image'].toString());
        }
      }
    }

    week = json['week'];
    date = json['date'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['en_name'] = enName;
    data['hi_name'] = hiName;
    data['thumbnail'] = thumbnail;
    data['wallpapers'] = wallpapers;
    data['week'] = week;
    data['date'] = date;
    return data;
  }
}

class WallpaperScreen extends StatefulWidget {
  const WallpaperScreen({Key? key}) : super(key: key);

  @override
  State<WallpaperScreen> createState() => _WallpaperScreenState();
}

class _WallpaperScreenState extends State<WallpaperScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool isLoading = false;
  List<Data> wallpaperTabs = [];

  // Sample video data - you can move this to your API response later
  final List<Map<String, dynamic>> _videos = [
    {
      'title': 'Mahakal Trail',
      'thumbnail': 'assets/image/trial_thumb.jpg', // You'll need to create this thumbnail
      'videoPath': 'assets/trial.mp4',
      'isLocal': true,
    },
    // Add more videos as needed
  ];

  @override
  void initState() {
    super.initState();
    fetchWallpapers();
  }

  Future<void> fetchWallpapers() async {
    setState(() => isLoading = true);

    try {
      final res = await HttpService().getApi(AppConstants.wallpaperData);
      print('RAW API RESPONSE: $res');
      print(
          "RAW data type: ${res['data'].runtimeType}"); // Check if String or List

      if (res != null) {
        print('🔴 RAW API RESPONSE: $res'); // 👈 add this
        final wallpaperModel = Wallpaper.fromJson(res);

        if (wallpaperModel.data != null && wallpaperModel.data!.isNotEmpty) {
          // 🔥 Debug print for enName
          for (var tab in wallpaperModel.data!) {
            print(
                '📌 ${tab.enName} wallpapers count → ${tab.wallpapers?.length ?? 0}');
            print('🖼 Raw wallpapers for ${tab.enName}: ${tab.wallpapers}');
          }

          setState(() {
            wallpaperTabs = wallpaperModel.data!;
            _tabController =
                TabController(length: wallpaperTabs.length, vsync: this);
          });
        }
      }
    } catch (e) {
      print('❌ Error fetching wallpapers: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  void dispose() {
    if (wallpaperTabs.isNotEmpty) {
      _tabController.dispose();
    }
    super.dispose();
  }

  Future<String> downloadImage(String url) async {
    final response = await http.get(Uri.parse(url));

    if (response.statusCode != 200) {
      throw Exception('Failed to download image (status: ${response.statusCode})');
    }

    final directory = Platform.isIOS
        ? await getApplicationDocumentsDirectory()
        : await getTemporaryDirectory();
    final filePath =
        '${directory.path}/wallpaper_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final file = File(filePath);
    await file.writeAsBytes(response.bodyBytes);
    return filePath;
  }

  Future<void> shareImage(String imageUrl) async {
    try {
      final filePath = await downloadImage(imageUrl);
      final RenderBox? box = context.findRenderObject() as RenderBox?;
      final Rect sharePositionOrigin = box != null && box.hasSize
          ? box.localToGlobal(Offset.zero) & box.size
          : Rect.fromLTWH(0, 0, 1, 1);

      await Share.shareXFiles(
        [XFile(filePath, mimeType: 'image/jpeg')],
        text: 'Check out this beautiful wallpaper!',
        sharePositionOrigin: sharePositionOrigin,
      );
    } catch (e) {
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to share image: $e')),
      );
    }
  }

  void showDownloadSuccesss(String fileName) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$fileName downloaded successfully!'),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void openEditor(String imgUrl) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ImageEditorScreen(imageUrl: imgUrl),
      ),
    );
  }

  // In your WallpaperScreen navigation:
  void openVideoEditor(String videoPath, {required isLocal}) {
    // Navigator.push(
    //   context,
    //   MaterialPageRoute(
    //     builder: (context) => VideoEditorScreen(
    //       videoUrl: videoPath, // Just pass 'assets/trial.mp4'
    //       isLocal: true, // Set to true for local assets
    //     ),
    //   ),
    // );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.white,
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 20,
              color: Colors.black,
            ),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text( 'Divine Wallpapers', style: TextStyle( fontSize: 22, fontWeight: FontWeight.w800, foreground: Paint() ..shader = LinearGradient( colors: [ Color(0xFF12C2E9), Color(0xFFC471ED), Color(0xFFF64F59), ], ).createShader( Rect.fromLTWH(0.0, 0.0, 200.0, 70.0), ), ), ),
        ),
        body: const Center(child: CircularProgressIndicator(color: Colors.deepOrange,)),
      );
    }

    if (wallpaperTabs.isEmpty) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          elevation: 1,
          backgroundColor: Colors.white,
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 20,
              color: Colors.black,
            ),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            'Divine Wallpapers',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              foreground: Paint()
                ..shader = LinearGradient(
                  colors: [
                    Color(0xFF12C2E9),
                    Color(0xFFC471ED),
                    Color(0xFFF64F59),
                  ],
                ).createShader(
                  const Rect.fromLTWH(0.0, 0.0, 200.0, 70.0),
                ),
            ),
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              /// Empty state illustration
              Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/images/empty_wallpaper.png'),
                    fit: BoxFit.contain,
                  ),
                ),
              ),

              const SizedBox(height: 24),

              /// Main message
              const Text(
                'No Wallpapers Found',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),

              const SizedBox(height: 8),

              /// Subtext
              const Text(
                'Check back later or explore our collection',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.grey,
                ),
              ),

              const SizedBox(height: 24),

              /// Optional button (refresh / explore)
              ElevatedButton.icon(
                onPressed: () {
                  // Call your refresh or explore logic here
                },
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Try Again'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF12C2E9),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return DefaultTabController(
      length: wallpaperTabs.length, // Add 1 for Videos tab
      child: Scaffold(
        backgroundColor: Colors.grey[100],
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFFE65100), // deep orange (rich)
                  Color(0xFFFF6A3D), // warm orange
                  Color(0xFFFFE16A), // soft deep orange
                ],
              ),
            ),
          ),
          title: const Text(
            'Divine Wallpapers',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 20,
              color: Colors.white,
            ),
            onPressed: () => Navigator.pop(context),
          ),
          iconTheme: const IconThemeData(color: Colors.white),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(80),
            child: Padding(
              padding: const EdgeInsets.only(bottom: 5, top: 15),
              child: _tabBar(),
            ),
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            // Videos Tab (First tab)
            // _buildVideosTab(),

            // Wallpaper Tabs
            ...wallpaperTabs.map((tab) {
              final images = tab.wallpapers ?? [];

              // 🔥 Case 1: No images
              if (images.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Enhanced Gradient Container with Shadow
                        Container(
                          height: 130,
                          width: 130,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [
                                Color(0xFFFFE0D6).withOpacity(0.9),
                                Color(0xFFFFCCBC),
                                Color(0xFFFFAB91),
                              ],
                              stops: [0.0, 0.5, 1.0],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Color(0xFFFF7043).withOpacity(0.2),
                                blurRadius: 20,
                                spreadRadius: 2,
                                offset: Offset(0, 8),
                              ),
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 10,
                                spreadRadius: 1,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Stack(
                            children: [
                              // Background Pattern
                              Center(
                                child: Container(
                                  width: 60,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.white.withOpacity(0.2),
                                  ),
                                ),
                              ),
                              // Main Icon
                              Center(
                                child: Icon(
                                  Icons.wallpaper_rounded,
                                  size: 52,
                                  color: Color(0xFFFF5722),
                                ),
                              ),
                              // Decorative Dots
                              Positioned(
                                top: 20,
                                right: 20,
                                child: Container(
                                  width: 12,
                                  height: 12,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.white.withOpacity(0.3),
                                  ),
                                ),
                              ),
                              Positioned(
                                bottom: 25,
                                left: 25,
                                child: Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.white.withOpacity(0.3),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 28),

                        // Title with better typography
                        const Text(
                          "No Wallpapers Available",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: Colors.black87,
                            letterSpacing: -0.2,
                          ),
                        ),

                        const SizedBox(height: 12),

                        // Description with improved styling
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: const Text(
                            "New wallpapers are being crafted with care. "
                                "We're adding fresh designs that you'll love!\n\n"
                                "Check back soon for exciting updates.",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.black54,
                              height: 1.5,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Optional: Add a progress indicator or refresh button
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 40),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              // Progress Dots
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Color(0xFFFF7043),
                                ),
                              ),
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Color(0xFFFF7043).withOpacity(0.3),
                                ),
                              ),
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Color(0xFFFF7043).withOpacity(0.3),
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

              // ✅ Case 2: Images available
              return GridView.builder(
                padding: const EdgeInsets.all(12),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 14,
                  childAspectRatio: 0.68,
                ),
                itemCount: images.length,
                itemBuilder: (context, imgIndex) {
                  final imgUrl = images[imgIndex];

                  return InkWell(
                    onTap: () => openEditor(imgUrl),
                    borderRadius: BorderRadius.circular(16),
                    child: Stack(
                      children: [
                        /// IMAGE
                        Hero(
                          tag: imgUrl,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(18),
                            child: Image.network(
                              imgUrl,
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: double.infinity,
                              errorBuilder: (_, __, ___) => Container(
                                color: Colors.grey.shade300,
                                child: const Icon(Icons.broken_image,
                                    size: 50, color: Colors.grey),
                              ),
                              loadingBuilder: (context, child, progress) {
                                if (progress == null) return child;
                                return Container(
                                  color: Colors.grey.shade200,
                                  child: const Center(
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),

                        /// GRADIENT OVERLAY (for better icon visibility)
                        Positioned.fill(
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(18),
                              gradient: LinearGradient(
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                                colors: [
                                  Colors.black.withOpacity(0.45),
                                  Colors.transparent,
                                ],
                              ),
                            ),
                          ),
                        ),

                        /// ACTION BAR
                        Positioned(
                          bottom: 12,
                          left: 6,
                          right: 6,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(30),
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(30),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.25),
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    _actionButton(
                                        icon: Icons.download,
                                        onTap: Platform.isIOS ? () {
                                          shareImage(imgUrl);
                                        } : () async {
                                          final fileName = '${tab.enName}${imgIndex + 1}.jpg';
                                          await downloadImage(imgUrl);
                                          showDownloadSuccesss(fileName);
                                        },
                                        color: Colors.white
                                    ),
                                    _actionButton(
                                        icon: Icons.share,
                                        onTap: () => shareImage(imgUrl),
                                        color: Colors.white
                                    ),
                                    _actionButton(
                                        icon: Icons.edit,
                                        onTap: () => openEditor(imgUrl),
                                        color: Colors.green
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  // New method to build Videos Tab
  Widget _buildVideosTab() {
    if (_videos.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                height: 130,
                width: 130,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.grey.shade200,
                ),
                child: Icon(
                  Icons.videocam_off,
                  size: 52,
                  color: Colors.grey.shade400,
                ),
              ),
              const SizedBox(height: 28),
              const Text(
                "No Videos Available",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                "New videos are being prepared.\nCheck back soon!",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.black54,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
        childAspectRatio: 0.68,
      ),
      itemCount: _videos.length,
      itemBuilder: (context, index) {
        final video = _videos[index];

        return InkWell(
          onTap: () => openVideoEditor(video['videoPath'], isLocal: video['isLocal'] ?? true),
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            children: [
              /// Video Thumbnail
              ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: video['isLocal'] == true
                    ? Image.asset(
                  video['thumbnail'] ?? 'assets/image/trial_thumb.jpg',
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                  errorBuilder: (_, __, ___) => Container(
                    color: Colors.grey.shade300,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.video_library, size: 40, color: Colors.grey.shade600),
                        const SizedBox(height: 8),
                        Text(
                          'Video',
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  ),
                )
                    : Image.network(
                  video['thumbnail']!,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                  errorBuilder: (_, __, ___) => Container(
                    color: Colors.grey.shade300,
                    child: Icon(Icons.video_library, size: 50, color: Colors.grey),
                  ),
                ),
              ),

              /// Play Button Overlay
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Colors.black.withOpacity(0.45),
                        Colors.transparent,
                        Colors.black.withOpacity(0.2),
                      ],
                    ),
                  ),
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.3),
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: const Icon(
                        Icons.play_arrow,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                  ),
                ),
              ),

              /// Video Title
              Positioned(
                bottom: 12,
                left: 12,
                right: 12,
                child: Text(
                  video['title'] ?? 'Divine Video',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    shadows: [
                      Shadow(
                        blurRadius: 10,
                        color: Colors.black,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),

              /// Edit Button
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.9),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 1.5),
                  ),
                  child: const Icon(
                    Icons.edit,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _actionButton({
    required IconData icon,
    required VoidCallback onTap,
    required Color color,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(50),
      splashColor: Colors.white24,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Icon(
          icon,
          color: color,
          size: 20,
        ),
      ),
    );
  }

  Widget _tabBar() {
    // Create list of tabs with Videos tab first
    List<Widget> tabs = [
      // Videos Tab
      // const Column(
      //   mainAxisSize: MainAxisSize.min,
      //   children: [
      //     CircleAvatar(
      //       radius: 20,
      //       backgroundImage: AssetImage('assets/image/playstore.png'), // You can change this icon
      //       backgroundColor: Colors.orange,
      //       child: Icon(Icons.video_library, color: Colors.white, size: 20),
      //     ),
      //     SizedBox(height: 6),
      //     Text(
      //       'Videos',
      //       maxLines: 1,
      //       overflow: TextOverflow.ellipsis,
      //       style: TextStyle(
      //         fontSize: 13,
      //         fontWeight: FontWeight.w600,
      //       ),
      //     ),
      //   ],
      // ),
    ];

    // Add wallpaper tabs
    tabs.addAll(wallpaperTabs.map((tab) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 20,
            backgroundImage: NetworkImage(tab.thumbnail ?? ""),
            backgroundColor: Colors.grey.shade300,
            onBackgroundImageError: (_, __) {},
            child: tab.thumbnail == null
                ? const Icon(Icons.image, size: 20)
                : null,
          ),
          const SizedBox(height: 6),
          Text(
            tab.enName ?? '',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      );
    }).toList());

    return TabBar(
      controller: _tabController,
      isScrollable: true,
      tabAlignment: TabAlignment.start,
      dividerColor: Colors.transparent,
      splashFactory: NoSplash.splashFactory,
      overlayColor: MaterialStateProperty.all(Colors.transparent),
      indicatorSize: TabBarIndicatorSize.tab,
      indicator: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: const LinearGradient(
          colors: [
            Color(0xFFFF9A76),
            Color(0xFFFF7043),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0x30FF7043),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      labelColor: Colors.white,
      unselectedLabelColor: Colors.black87,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      labelPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      tabs: tabs,
    );
  }
}

// class ImageEditorScreen extends StatefulWidget {
//   final String imageUrl;
//
//   ImageEditorScreen({Key? key, required this.imageUrl}) : super(key: key);
//
//   @override
//   State<ImageEditorScreen> createState() => _ImageEditorScreenState();
// }
//
// class _ImageEditorScreenState extends State<ImageEditorScreen> with SingleTickerProviderStateMixin {
//   final ScreenshotController _screenshotController = ScreenshotController();
//   final GlobalKey _imageContainerKey = GlobalKey();
//   AnimationController? _scaleController;
//   double _animationScale = 1.0;
//
//   @override
//   void initState() {
//     super.initState();
//     _scaleController = AnimationController(
//       vsync: this,
//       duration: Duration(milliseconds: 100),
//     )..addListener(() {
//       setState(() {});
//     });
//   }
//
//   @override
//   void dispose() {
//     _scaleController?.dispose();
//     super.dispose();
//   }
//
//   // ====== TEXTS ======
//   final List<_OverlayTextData> _overlayTexts = [];
//
//   // Text style options
//   final List<Color> _textColors = [
//     Colors.white,
//     Colors.black,
//     Colors.red,
//     Colors.blue,
//     Colors.green,
//     Colors.yellow,
//     Colors.purple,
//     Colors.orange,
//   ];
//
//   final List<Color> _backgroundColors = [
//     Colors.transparent,
//     Colors.black54,
//     Colors.white,
//     Colors.yellowAccent,
//     Colors.blue.withOpacity(0.5),
//     Colors.red.withOpacity(0.5),
//     Colors.green.withOpacity(0.5),
//     Colors.purple.withOpacity(0.5),
//   ];
//
//   // Font style options
//   final List<Map<String, dynamic>> _fontStyles = [
//     {'name': 'Normal', 'style': FontStyle.normal, 'weight': FontWeight.normal, 'icon': Icons.text_format},
//     {'name': 'Bold', 'style': FontStyle.normal, 'weight': FontWeight.bold, 'icon': Icons.format_bold},
//     {'name': 'Italic', 'style': FontStyle.italic, 'weight': FontWeight.normal, 'icon': Icons.format_italic},
//     {'name': 'Bold Italic', 'style': FontStyle.italic, 'weight': FontWeight.bold, 'icon': Icons.format_italic},
//     {'name': 'Light', 'style': FontStyle.normal, 'weight': FontWeight.w300, 'icon': Icons.format_size},
//   ];
//
//   // ====== LOGOS ======
//   List<_OverlayImageData> _overlayImages = [];
//
//   // ====== DRAWING ======
//   bool _isDrawing = false;
//   List<DrawnLine> _lines = [];
//   List<DrawnLine> _undoneLines = [];
//
//   // ====== DELETE ZONE ======
//   bool _showDeleteZone = false;
//   final GlobalKey _deleteZoneKey = GlobalKey();
//
//   // ====== HISTORY (Undo/Redo for texts & logos) ======
//   final List<EditorAction> _actionsHistory = [];
//   final List<EditorAction> _redoStack = [];
//
//   // Default text style for new text elements
//   Color _defaultTextColor = Colors.white;
//   Color _defaultBackgroundColor = Colors.black54;
//   FontStyle _defaultFontStyle = FontStyle.normal;
//   FontWeight _defaultFontWeight = FontWeight.normal;
//
//   Future<File> _saveEditedImage() async {
//     final Uint8List? imageBytes = await _screenshotController.capture();
//     if (imageBytes == null) throw Exception("Failed to capture image");
//
//     final dir = await getTemporaryDirectory();
//     final file = File('${dir.path}/edited_${DateTime.now().millisecondsSinceEpoch}.png');
//     await file.writeAsBytes(imageBytes);
//     return file;
//   }
//
//   void _shareEditedImage() async {
//     final file = await _saveEditedImage();
//     await Share.shareXFiles([XFile(file.path)], text: "Check out my edited image!");
//   }
//
//   void _downloadEditedImage() async {
//     final file = await _saveEditedImage();
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text("Saved to ${file.path}")),
//     );
//   }
//
//   Future<void> _pickLogo() async {
//     final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
//     if (picked != null) {
//       final logo = _OverlayImageData(
//         file: File(picked.path),
//         position: Offset(70, 70),
//         size: 100, // Set initial size to at least 180
//       );
//       setState(() {
//         _overlayImages.add(logo);
//         _actionsHistory.add(EditorAction.addLogo(logo));
//         _redoStack.clear();
//       });
//     }
//   }
//
//   void _undo() {
//     if (_actionsHistory.isEmpty) return;
//     final last = _actionsHistory.removeLast();
//     _redoStack.add(last);
//
//     setState(() {
//       if (last.type == ActionType.addText) {
//         _overlayTexts.remove(last.textData);
//       } else if (last.type == ActionType.addLogo) {
//         _overlayImages.remove(last.imageData);
//       } else if (last.type == ActionType.draw) {
//         if (_lines.isNotEmpty) _undoneLines.add(_lines.removeLast());
//       }
//     });
//   }
//
//   void _redo() {
//     if (_redoStack.isEmpty) return;
//     final action = _redoStack.removeLast();
//     _actionsHistory.add(action);
//
//     setState(() {
//       if (action.type == ActionType.addText && action.textData != null) {
//         _overlayTexts.add(action.textData!);
//       } else if (action.type == ActionType.addLogo && action.imageData != null) {
//         _overlayImages.add(action.imageData!);
//       } else if (action.type == ActionType.draw && action.line != null) {
//         _lines.add(action.line!);
//       }
//     });
//   }
//
//   // Check if an element is in the delete zone with rectangular bounds
//   bool _isInDeleteZone(Offset globalPosition) {
//     final RenderBox? deleteZoneBox = _deleteZoneKey.currentContext?.findRenderObject() as RenderBox?;
//     if (deleteZoneBox == null) return false;
//
//     final deleteZonePosition = deleteZoneBox.localToGlobal(Offset.zero);
//     final deleteZoneSize = deleteZoneBox.size;
//
//     // Create expanded rectangular bounds with 200px margin on all sides
//     final expandedBounds = Rect.fromLTRB(
//       deleteZonePosition.dx - 100.0, // Left: 200px from left edge
//       deleteZonePosition.dy - 100.0, // Top: 200px from top edge
//       deleteZonePosition.dx + deleteZoneSize.width + 90.0, // Right: 200px from right edge
//       deleteZonePosition.dy + deleteZoneSize.height + 200.0, // Bottom: 200px from bottom edge
//     );
//
//     // Return true if the global position is within the expanded bounds
//     return expandedBounds.contains(globalPosition);
//   }
//
//   // Show popup for adding/editing text with styling options
//   void _showAddTextPopup({_OverlayTextData? editingTextData, int? editingIndex}) {
//     TextEditingController textController = TextEditingController(
//       text: editingTextData?.text ?? '',
//     );
//     Color selectedTextColor = editingTextData?.textColor ?? _defaultTextColor;
//     Color selectedBackgroundColor = editingTextData?.backgroundColor ?? _defaultBackgroundColor;
//     FontStyle selectedFontStyle = editingTextData?.fontStyle ?? _defaultFontStyle;
//     FontWeight selectedFontWeight = editingTextData?.fontWeight ?? _defaultFontWeight;
//     double selectedFontSize = editingTextData?.fontSize ?? 22.0;
//
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return StatefulBuilder(
//           builder: (context, setState) {
//             return Dialog(
//               insetPadding: EdgeInsets.all(20),
//               child: Container(
//                 padding: EdgeInsets.all(20),
//                 width: MediaQuery.of(context).size.width * 0.9,
//                 constraints: BoxConstraints(
//                   maxHeight: MediaQuery.of(context).size.height * 0.7,
//                 ),
//                 child: SingleChildScrollView(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         editingTextData != null ? "Edit Text" : "Add Text",
//                         style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//                       ),
//                       SizedBox(height: 16),
//                       TextField(
//                         controller: textController,
//                         decoration: InputDecoration(
//                           hintText: "Write something...",
//                           border: OutlineInputBorder(),
//                         ),
//                         maxLines: 3,
//                         onChanged: (value) {
//                           setState(() {}); // Update preview when text changes
//                         },
//                       ),
//                       SizedBox(height: 16),
//                       // Preview of the text with selected styles
//                       Container(
//                         padding: EdgeInsets.all(10),
//                         decoration: BoxDecoration(
//                           color: selectedBackgroundColor,
//                           borderRadius: BorderRadius.circular(6),
//                         ),
//                         child: Text(
//                           textController.text.isEmpty ? "Preview" : textController.text,
//                           style: TextStyle(
//                             color: selectedTextColor,
//                             fontSize: selectedFontSize,
//                             fontStyle: selectedFontStyle,
//                             fontWeight: selectedFontWeight,
//                           ),
//                         ),
//                       ),
//                       SizedBox(height: 16),
//                       // Font size selection
//                       Row(
//                         children: [
//                           Text("Font Size: "),
//                           SizedBox(width: 10),
//                           Expanded(
//                             child: Slider(
//                               value: selectedFontSize,
//                               min: 12,
//                               max: 100,
//                               divisions: 22,
//                               label: selectedFontSize.round().toString(),
//                               onChanged: (value) {
//                                 setState(() {
//                                   selectedFontSize = value;
//                                 });
//                               },
//                             ),
//                           ),
//                           Text("${selectedFontSize.round()}"),
//                         ],
//                       ),
//                       SizedBox(height: 10),
//                       // Text color selection
//                       Row(
//                         children: [
//                           Text("Text Color: "),
//                           SizedBox(width: 10),
//                           GestureDetector(
//                             onTap: () {
//                               _showColorPicker(
//                                 context,
//                                 _textColors,
//                                 "Select Text Color",
//                                     (color) {
//                                   setState(() {
//                                     selectedTextColor = color;
//                                   });
//                                 },
//                               );
//                             },
//                             child: Container(
//                               width: 30,
//                               height: 30,
//                               decoration: BoxDecoration(
//                                 color: selectedTextColor,
//                                 shape: BoxShape.circle,
//                                 border: Border.all(color: Colors.grey),
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                       SizedBox(height: 10),
//                       // Background color selection
//                       Row(
//                         children: [
//                           Text("BG Color: "),
//                           SizedBox(width: 10),
//                           GestureDetector(
//                             onTap: () {
//                               _showColorPicker(
//                                 context,
//                                 _backgroundColors,
//                                 "Select Background Color",
//                                     (color) {
//                                   setState(() {
//                                     selectedBackgroundColor = color;
//                                   });
//                                 },
//                               );
//                             },
//                             child: Container(
//                               width: 30,
//                               height: 30,
//                               decoration: BoxDecoration(
//                                 color: selectedBackgroundColor,
//                                 shape: BoxShape.circle,
//                                 border: Border.all(color: Colors.grey),
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                       SizedBox(height: 10),
//                       // Font style selection
//                       Row(
//                         children: [
//                           Text("Font Style: "),
//                           SizedBox(width: 10),
//                           DropdownButton<Map<String, dynamic>>(
//                             value: _fontStyles.firstWhere(
//                                   (style) =>
//                               style['style'] == selectedFontStyle &&
//                                   style['weight'] == selectedFontWeight,
//                               orElse: () => _fontStyles.first,
//                             ),
//                             items: _fontStyles.map((style) {
//                               return DropdownMenuItem<Map<String, dynamic>>(
//                                 value: style,
//                                 child: Text(
//                                   style['name'],
//                                   style: TextStyle(
//                                     fontStyle: style['style'],
//                                     fontWeight: style['weight'],
//                                   ),
//                                 ),
//                               );
//                             }).toList(),
//                             onChanged: (value) {
//                               if (value != null) {
//                                 setState(() {
//                                   selectedFontStyle = value['style'];
//                                   selectedFontWeight = value['weight'];
//                                 });
//                               }
//                             },
//                           ),
//                         ],
//                       ),
//                       SizedBox(height: 20),
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.end,
//                         children: [
//
//                           // if (editingTextData != null && editingIndex != null)
//                           //   TextButton(
//                           //     onPressed: () {
//                           //       Navigator.pop(context); // Close dialog first
//                           //       setState(() {
//                           //         _actionsHistory.add(EditorAction.removeText(editingTextData));
//                           //         _overlayTexts.removeAt(editingIndex);
//                           //         _redoStack.clear();
//                           //       });
//                           //     },
//                           //     child: Text(
//                           //       "Clear",
//                           //       style: TextStyle(color: Colors.red),
//                           //     ),
//                           //   ),
//                           TextButton(
//                             onPressed: () => Navigator.pop(context),
//                             child: Text("Cancel"),
//                           ),
//                           SizedBox(width: 10),
//                           ElevatedButton(
//                             onPressed: () {
//                               if (textController.text.isNotEmpty) {
//                                 if (editingTextData != null && editingIndex != null) {
//                                   // Update existing text
//                                   setState(() {
//                                     editingTextData.text = textController.text;
//                                     editingTextData.textColor = selectedTextColor;
//                                     editingTextData.backgroundColor = selectedBackgroundColor;
//                                     editingTextData.fontStyle = selectedFontStyle;
//                                     editingTextData.fontWeight = selectedFontWeight;
//                                     editingTextData.fontSize = selectedFontSize;
//                                   });
//                                 } else {
//                                   // Add new text
//                                   final textData = _OverlayTextData(
//                                     text: textController.text,
//                                     position: Offset(100, 300),
//                                     textColor: selectedTextColor,
//                                     backgroundColor: selectedBackgroundColor,
//                                     fontStyle: selectedFontStyle,
//                                     fontWeight: selectedFontWeight,
//                                     fontSize: selectedFontSize,
//                                   );
//                                   setState(() {
//                                     _overlayTexts.add(textData);
//                                     _actionsHistory.add(EditorAction.addText(textData));
//                                     _redoStack.clear();
//                                   });
//                                 }
//
//                                 // Update default values for next text
//                                 _defaultTextColor = selectedTextColor;
//                                 _defaultBackgroundColor = selectedBackgroundColor;
//                                 _defaultFontStyle = selectedFontStyle;
//                                 _defaultFontWeight = selectedFontWeight;
//
//                                 Navigator.pop(context);
//                               }
//                             },
//                             child: Text(editingTextData != null ? "Update" : "Add"),
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             );
//           },
//         );
//       },
//     );
//   }
//
//   // Helper method to show color picker
//   void _showColorPicker(BuildContext context, List<Color> colors, String title, Function(Color) onColorSelected) {
//     showModalBottomSheet(
//       context: context,
//       builder: (BuildContext context) {
//         return Container(
//           padding: EdgeInsets.all(16),
//           height: 300,
//           child: Column(
//             children: [
//               Text(
//                 title,
//                 style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//               ),
//               SizedBox(height: 16),
//               Expanded(
//                 child: GridView.builder(
//                   gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//                     crossAxisCount: 4,
//                     crossAxisSpacing: 10,
//                     mainAxisSpacing: 10,
//                   ),
//                   itemCount: colors.length,
//                   itemBuilder: (context, index) {
//                     return GestureDetector(
//                       onTap: () {
//                         onColorSelected(colors[index]);
//                         Navigator.pop(context);
//                       },
//                       child: Container(
//                         decoration: BoxDecoration(
//                           color: colors[index],
//                           shape: BoxShape.circle,
//                           border: Border.all(
//                             color: Colors.grey,
//                             width: 2,
//                           ),
//                         ),
//                       ),
//                     );
//                   },
//                 ),
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text("Edit Image"),
//         actions: [
//           IconButton(icon: Icon(Icons.undo), onPressed: _undo),
//           IconButton(icon: Icon(Icons.redo), onPressed: _redo),
//           IconButton(icon: Icon(Icons.save), onPressed: _downloadEditedImage),
//           IconButton(icon: Icon(Icons.share), onPressed: _shareEditedImage),
//         ],
//       ),
//       body: Stack(
//         alignment: Alignment.center,
//         children: [
//           Screenshot(
//             controller: _screenshotController,
//             child: GestureDetector(
//               onPanStart: _isDrawing
//                   ? (details) {
//                 setState(() {
//                   _lines.add(DrawnLine([details.localPosition]));
//                   _actionsHistory.add(EditorAction.draw(_lines.last));
//                   _redoStack.clear();
//                 });
//               }
//                   : null,
//               onPanUpdate: _isDrawing
//                   ? (details) {
//                 setState(() {
//                   _lines.last.pathPoints.add(details.localPosition);
//                 });
//               } : null,
//               child: Container(
//                 width: MediaQuery.of(context).size.width,
//                 height: MediaQuery.of(context).size.height,
//                 color: Colors.black,
//                 child: Stack(
//                   key: _imageContainerKey,
//                   children: [
//                     Image.network(
//                       widget.imageUrl,
//                       fit: BoxFit.cover,
//                       width: double.infinity,
//                       height: double.infinity,
//                     ),
//                     CustomPaint(
//                       painter: Sketcher(lines: _lines),
//                       size: Size.infinite,
//                     ),
//
//                     // Texts
//                     for (int i = 0; i < _overlayTexts.length; i++)
//                       _buildMovableText(_overlayTexts[i], i),
//
//                     // Logos
//                     for (int i = 0; i < _overlayImages.length; i++)
//                       _buildMovableLogo(_overlayImages[i], i),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//
//           // Delete zone with visual indicator of the detection area
//           if (_showDeleteZone)
//             Positioned(
//               bottom: 20,
//               child: Stack(
//                 alignment: Alignment.center,
//                 children: [
//                   // Visual representation of the detection area (for debugging)
//                   Container(
//                     width: 90, // Increased detection area
//                     height: 90,
//                     decoration: BoxDecoration(
//                       color: Colors.red.withOpacity(0.3),
//                       shape: BoxShape.circle,
//                     ),
//                   ),
//                   // Actual delete icon
//                   Container(
//                     key: _deleteZoneKey,
//                     padding: EdgeInsets.all(10),
//                     decoration: BoxDecoration(
//                       color: Colors.red.withOpacity(0.7),
//                       shape: BoxShape.circle,
//                     ),
//                     child: Icon(Icons.delete, size: 50, color: Colors.white),
//                   ),
//                 ],
//               ),
//             ),
//         ],
//       ),
//       bottomNavigationBar: Container(
//         padding: EdgeInsets.symmetric(horizontal: 10, vertical: 12),
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.only(
//             // topLeft: Radius.circular(20),
//             // topRight: Radius.circular(20),
//           ),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black26,
//               blurRadius: 10,
//               offset: Offset(0, -3),
//             ),
//           ],
//         ),
//         child: SingleChildScrollView(
//           scrollDirection: Axis.horizontal,
//           child: Container(
//             width: MediaQuery.of(context).size.width,
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//               children: [
//                 Expanded(
//                   child: _buildToolbarButton(
//                     icon: Icons.text_fields,
//                     label: "Text",
//                     onTap: _showAddTextPopup,
//                   ),
//                 ),
//                 Expanded(
//                   child: _buildToolbarButton(
//                     icon: Icons.image,
//                     label: "Logo",
//                     onTap: _pickLogo,
//                   ),
//                 ),
//                 Expanded(
//                   child: _buildToolbarButton(
//                     icon: Icons.brush,
//                     label: _isDrawing ? "Stop" : "Draw",
//                     color: _isDrawing ? Colors.red : Colors.blue,
//                     onTap: () {
//                       setState(() {
//                         _isDrawing = !_isDrawing;
//                       });
//                     },
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildMovableText(_OverlayTextData textData, int index) {
//     double initialFontSize = textData.fontSize;
//     Offset initialPosition = textData.position;
//
//     return Positioned(
//       left: textData.position.dx,
//       top: textData.position.dy,
//       child: GestureDetector(
//         onTap: () {
//           // Open text editing popup when text is tapped
//           _showAddTextPopup(editingTextData: textData, editingIndex: index);
//         },
//         onScaleStart: (details) {
//           setState(() {
//             _showDeleteZone = true;
//             initialFontSize = textData.fontSize;
//             initialPosition = textData.position;
//           });
//         },
//         onScaleUpdate: (details) {
//           setState(() {
//             if (details.pointerCount == 2) {
//               textData.fontSize = (initialFontSize * details.scale).clamp(12, 100);
//             } else if (details.pointerCount == 1) {
//               textData.position = initialPosition + details.focalPointDelta;
//             }
//           });
//         },
//         onScaleEnd: (_) {
//           final RenderBox? imageBox = _imageContainerKey.currentContext?.findRenderObject() as RenderBox?;
//           if (imageBox != null) {
//             // Calculate the center of the text element
//             final containerPosition = imageBox.localToGlobal(Offset.zero);
//             final textCenterX = containerPosition.dx + textData.position.dx;
//             final textCenterY = containerPosition.dy + textData.position.dy;
//
//             if (_isInDeleteZone(Offset(textCenterX, textCenterY))) {
//               setState(() {
//                 _overlayTexts.removeAt(index);
//                 _actionsHistory.add(EditorAction.removeText(textData));
//               });
//             }
//           }
//           setState(() => _showDeleteZone = false);
//         },
//         child: Container(
//           decoration: BoxDecoration(
//             color: Colors.transparent,
//             borderRadius: BorderRadius.circular(6),
//           ),
//           child: Padding(
//             padding: EdgeInsets.only(right: 80,left: 80,top: 80,bottom: 80),
//             child: Container(
//               padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//               decoration: BoxDecoration(
//                   color: textData.backgroundColor,
//                   borderRadius: BorderRadius.circular(6)
//               ),
//               child: Text(
//                 textData.text,
//                 style: TextStyle(
//                   color: textData.textColor,
//                   fontSize: textData.fontSize,
//                   fontStyle: textData.fontStyle,
//                   fontWeight: textData.fontWeight,
//                   shadows: [Shadow(blurRadius: 4, color: Colors.black45)],
//                 ),
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildMovableLogo(_OverlayImageData data, int index) {
//     double initialSize = data.size;
//     Offset initialPosition = data.position;
//     double _scaleFactor = 1.0;
//
//     return Positioned(
//       left: data.position.dx,
//       top: data.position.dy,
//       child: GestureDetector(
//         onTap: () {
//           setState(() {
//             // Cycle shape on tap
//             switch (data.shape) {
//               case ImageShape.square:
//                 data.shape = ImageShape.roundedRectangle;
//                 break;
//               case ImageShape.roundedRectangle:
//                 data.shape = ImageShape.circle;
//                 break;
//               case ImageShape.circle:
//                 data.shape = ImageShape.square;
//                 break;
//             }
//           });
//         },
//         onScaleStart: (details) {
//           setState(() {
//             _showDeleteZone = true;
//             initialSize = data.size;
//             initialPosition = data.position;
//             _scaleFactor = 1.0;
//           });
//         },
//         onScaleUpdate: (details) {
//           setState(() {
//             if (details.pointerCount == 2) {
//               double scaleChange = (details.scale - 1.0) * 0.3;
//               _scaleFactor = 1.0 + scaleChange;
//               data.size = (initialSize * _scaleFactor).clamp(80, 400);
//             } else if (details.pointerCount == 1) {
//               data.position = initialPosition + details.focalPointDelta;
//             }
//           });
//         },
//         onScaleEnd: (_) {
//           final RenderBox? imageBox = _imageContainerKey.currentContext?.findRenderObject() as RenderBox?;
//           if (imageBox != null) {
//             final containerPosition = imageBox.localToGlobal(Offset.zero);
//             final center = containerPosition + data.position + Offset(data.size / 2, data.size / 2);
//
//             if (_isInDeleteZone(center)) {
//               setState(() {
//                 _overlayImages.removeAt(index);
//                 _actionsHistory.add(EditorAction.removeLogo(data));
//               });
//             }
//           }
//           setState(() => _showDeleteZone = false);
//         },
//         child: Container(
//           decoration: BoxDecoration(
//             color: Colors.transparent,
//             shape: data.shape == ImageShape.circle ? BoxShape.circle : BoxShape.rectangle,
//             borderRadius: data.shape == ImageShape.circle
//                 ? null
//                 : (data.shape == ImageShape.roundedRectangle
//                 ? BorderRadius.circular(20)
//                 : BorderRadius.zero),
//           ),
//           child: ClipRRect(
//             borderRadius: data.shape == ImageShape.circle
//                 ? BorderRadius.circular(data.size / 2)
//                 : (data.shape == ImageShape.roundedRectangle
//                 ? BorderRadius.circular(20)
//                 : BorderRadius.zero),
//             child: Image.file(
//               data.file,
//               width: data.size,
//               height: data.size,
//               fit: BoxFit.cover,
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   // 🔹 Helper for styled buttons
//   Widget _buildToolbarButton({
//     required IconData icon,
//     required String label,
//     Color color = Colors.black87,
//     required VoidCallback onTap,
//   }) {
//     return Container(
//       margin: EdgeInsets.symmetric(horizontal: 4),
//       child: GestureDetector(
//         onTap: onTap,
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Container(
//               padding: EdgeInsets.all(10),
//               decoration: BoxDecoration(
//                 color: color.withOpacity(0.1),
//                 shape: BoxShape.circle,
//               ),
//               child: Icon(icon, color: color, size: 24),
//             ),
//             SizedBox(height: 4),
//             Text(
//               label,
//               style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.w500),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
// enum ImageShape { square, roundedRectangle, circle }
// // ===== Helper Classes =====
// class _OverlayImageData {
//   File file;
//   Offset position;
//   double size;
//   ImageShape shape;
//
//   _OverlayImageData({
//     required this.file,
//     required this.position,
//     required this.size,
//     this.shape = ImageShape.square,  // default value
//   });
// }
//
// class _OverlayTextData {
//   String text;
//   Offset position;
//   Color textColor;
//   Color backgroundColor;
//   FontStyle fontStyle;
//   FontWeight fontWeight;
//   double fontSize; // Add fontSize property for scaling
//
//   _OverlayTextData({
//     required this.text,
//     required this.position,
//     this.textColor = Colors.white,
//     this.backgroundColor = Colors.black54,
//     this.fontStyle = FontStyle.normal,
//     this.fontWeight = FontWeight.normal,
//     this.fontSize = 22, // Default font size
//   });
// }
//
// // ===== Drawing =====
// class DrawnLine {
//   List<Offset> pathPoints;
//   DrawnLine(this.pathPoints);
// }
//
// class Sketcher extends CustomPainter {
//   final List<DrawnLine> lines;
//   Sketcher({required this.lines});
//
//   @override
//   void paint(Canvas canvas, Size size) {
//     final paint = Paint()
//       ..color = Colors.black
//       ..strokeWidth = 4.0
//       ..strokeCap = StrokeCap.round
//       ..style = PaintingStyle.stroke;
//
//     for (var line in lines) {
//       for (int i = 0; i < line.pathPoints.length - 1; i++) {
//         canvas.drawLine(line.pathPoints[i], line.pathPoints[i + 1], paint);
//       }
//     }
//   }
//
//   @override
//   bool shouldRepaint(Sketcher oldDelegate) => true;
// }
//
// // ===== Undo/Redo Actions =====
// enum ActionType { addText, addLogo, draw, removeText, removeLogo }
//
// class EditorAction {
//   final ActionType type;
//   final _OverlayTextData? textData;
//   final _OverlayImageData? imageData;
//   final DrawnLine? line;
//
//   EditorAction.addText(this.textData)
//       : type = ActionType.addText,
//         imageData = null,
//         line = null;
//
//   EditorAction.addLogo(this.imageData)
//       : type = ActionType.addLogo,
//         textData = null,
//         line = null;
//
//   EditorAction.removeText(this.textData)
//       : type = ActionType.removeText,
//         imageData = null,
//         line = null;
//
//   EditorAction.removeLogo(this.imageData)
//       : type = ActionType.removeLogo,
//         textData = null,
//         line = null;
//
//   EditorAction.draw(this.line)
//       : type = ActionType.draw,
//         textData = null,
//         imageData = null;
// }

// lll

// import 'package:flutter/material.dart';
// import 'package:mahakal/features/mandir/model/mandir_model.dart';
// import 'package:share_plus/share_plus.dart';
// import 'package:http/http.dart' as http;
// import 'dart:io';
// import 'package:path_provider/path_provider.dart';
// import '../../../data/datasource/remote/http/httpClient.dart';
// import '../../youtube_vedios/utils/api_service.dart';
// import 'package:flutter/cupertino.dart';
// import '../../../utill/app_constants.dart';
//
//
// class WallpaperScreen extends StatefulWidget {
//   const WallpaperScreen({Key? key}) : super(key: key);
//
//   @override
//   _WallpaperScreenState createState() => _WallpaperScreenState();
// }
//
// class _WallpaperScreenState extends State<WallpaperScreen>
//     with SingleTickerProviderStateMixin {
//   late TabController _tabController;
//   bool isLoading = false;
//   List<MandirData> mandirTabs = [];
//
//
//   Future<void> setWallpaper(String imageUrl) async {
//     // try {
//       // Download image first
//       // final filePath = await downloadImage(imageUrl);
//
//       // Ask for location (Home, Lock, Both)
//       // int location = WallpaperManager.HOME_SCREEN;
//       // you can also use WallpaperManager.LOCK_SCREEN or BOTH_SCREEN
//
//       // bool result = await WallpaperManager.setWallpaperFromFile(filePath, location);
//
//     //   if (result) {
//     //     ScaffoldMessenger.of(context).showSnackBar(
//     //       const SnackBar(content: Text("Wallpaper set successfully!")),
//     //     );
//     //   } else {
//     //     ScaffoldMessenger.of(context).showSnackBar(
//     //       const SnackBar(content: Text("Failed to set wallpaper.")),
//     //     );
//     //   }
//     // } catch (e) {
//     //   ScaffoldMessenger.of(context).showSnackBar(
//     //     SnackBar(content: Text("Error: $e")),
//     //   );
//     // }
//   }

// List of gods with their respective images
// final List<Map<String, dynamic>> gods = [
//   {
//     'name': 'Lord Ganesha',
//     'images': [
//       "https://images.unsplash.com/photo-1506744038136-46273834b3fb?w=600&h=900&fit=crop",
//       "https://images.unsplash.com/photo-1500530855697-b586d89ba3ee?w=600&h=900&fit=crop",
//       "https://images.unsplash.com/photo-1507525428034-b723cf961d3e?w=600&h=900&fit=crop",
//     ],
//     'icon': 'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?w=600&h=900&fit=crop'
//   },
//   {
//     'name': 'Lord Shiva',
//     'images': [
//       "https://images.unsplash.com/photo-1470770841072-f978cf4d019e?w=600&h=900&fit=crop",
//       "https://images.unsplash.com/photo-1501785888041-af3ef285b470?w=600&h=900&fit=crop",
//       "https://images.unsplash.com/photo-1493244040629-496f6d136cc3?w=600&h=900&fit=crop",
//     ],
//     'icon': 'https://images.unsplash.com/photo-1506744038136-46273834b3fb?w=600&h=900&fit=crop'
//   },
//   {
//     'name': 'Lord Vishnu',
//     'images': [
//       "https://images.unsplash.com/photo-1506744038136-46273834b3fb?w=600&h=900&fit=crop",
//       "https://images.unsplash.com/photo-1500530855697-b586d89ba3ee?w=600&h=900&fit=crop",
//       "https://images.unsplash.com/photo-1507525428034-b723cf961d3e?w=600&h=900&fit=crop",
//     ],
//     'icon': 'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?w=600&h=900&fit=crop'
//   },
//   {
//     'name': 'Goddess Lakshmi',
//     'images': [
//       "https://images.unsplash.com/photo-1470770841072-f978cf4d019e?w=600&h=900&fit=crop",
//       "https://images.unsplash.com/photo-1501785888041-af3ef285b470?w=600&h=900&fit=crop",
//       "https://images.unsplash.com/photo-1493244040629-496f6d136cc3?w=600&h=900&fit=crop",
//     ],
//     'icon': 'https://images.unsplash.com/photo-1506744038136-46273834b3fb?w=600&h=900&fit=crop'
//   },
//   {
//     'name': 'Lord Krishna',
//     'images': [
//       "https://images.unsplash.com/photo-1501785888041-af3ef285b470?w=600&h=900&fit=crop",
//       "https://images.unsplash.com/photo-1500530855697-b586d89ba3ee?w=600&h=900&fit=crop",
//       "https://images.unsplash.com/photo-1507525428034-b723cf961d3e?w=600&h=900&fit=crop",
//     ],
//     'icon': 'https://images.unsplash.com/photo-1506744038136-46273834b3fb?w=600&h=900&fit=crop'
//   },
//   {
//     'name': 'Goddess Durga',
//     'images': [
//       "https://images.unsplash.com/photo-1500530855697-b586d89ba3ee?w=600&h=900&fit=crop",
//       "https://images.unsplash.com/photo-1507525428034-b723cf961d3e?w=600&h=900&fit=crop",
//       "https://images.unsplash.com/photo-1470770841072-f978cf4d019e?w=600&h=900&fit=crop",
//     ],
//     'icon': 'https://images.unsplash.com/photo-1506744038136-46273834b3fb?w=600&h=900&fit=crop'
//   },
//   {
//     'name': 'Lord Rama',
//     'images': [
//   "https://images.unsplash.com/photo-1470770841072-f978cf4d019e?w=600&h=900&fit=crop",
//   "https://images.unsplash.com/photo-1501785888041-af3ef285b470?w=600&h=900&fit=crop",
//   "https://images.unsplash.com/photo-1493244040629-496f6d136cc3?w=600&h=900&fit=crop",
//     ],
//     'icon': 'https://images.unsplash.com/photo-1506744038136-46273834b3fb?w=600&h=900&fit=crop'
//   },
//   // {
//   //   'name': 'Lord Hanuman',
//   //   'images': [
//   //     'https://example.com/hanuman1.jpg',
//   //     'https://example.com/hanuman2.jpg',
//   //     'https://example.com/hanuman3.jpg',
//   //   ],
//   //   'icon': 'https://images.unsplash.com/photo-1506744038136-46273834b3fb?w=600&h=900&fit=crop'
//   // },
//   // {
//   //   'name': 'Goddess Saraswati',
//   //   'images': [
//   //     'https://example.com/saraswati1.jpg',
//   //     'https://example.com/saraswati2.jpg',
//   //     'https://example.com/saraswati3.jpg',
//   //   ],
//   //   'icon': 'https://example.com/saraswati_icon.jpg'
//   // },
// ];

// @override
// void initState() {
//   super.initState();
//   _tabController = TabController(length: gods.length, vsync: this);
//   getTabs();
// }
//
// Future<void> getTabs() async {
//   setState(() => isLoading = true);
//
//   try {
//     // final res = await("${AppConstants.mandirTabsUrl}");
//     final res = await HttpService().getApi(AppConstants.mandirTabsUrl);
//
//     if (res != null) {
//       final tabsCategory = MandirModel.fromJson(res);
//
//       if (tabsCategory.data != null) {
//         setState(() {
//           mandirTabs = tabsCategory.data!;
//           _tabController =
//               TabController(length: mandirTabs.length, vsync: this);
//         });
//       }
//     }
//   } catch (e) {
//     print("Error fetching tabs: $e");
//   } finally {
//     setState(() => isLoading = false);
//   }
// }
//
// @override
// void dispose() {
//   _tabController.dispose();
//   super.dispose();
// }
//
// Future<String> downloadImage(String url) async {
//   final response = await http.get(Uri.parse(url));
//   final directory = await getApplicationDocumentsDirectory();
//   final filePath = '${directory.path}/${DateTime.now().millisecondsSinceEpoch}.jpg';
//   final file = File(filePath);
//   await file.writeAsBytes(response.bodyBytes);
//   return filePath;
// }
//
//
// void shareImage(String imageUrl) async {
//   try {
//     final filePath = await downloadImage(imageUrl);
//     await Share.shareXFiles(
//       [XFile(filePath)],  // Use XFile instead of just file path
//       text: 'Check out this beautiful wallpaper!',
//     );
//   } catch (e) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text('Failed to share image: $e')),
//     );
//   }
// }
//
// void showDownloadSuccess(String fileName) {
//   ScaffoldMessenger.of(context).showSnackBar(
//     SnackBar(
//       content: Text('Downloaded $fileName successfully!'),
//       duration: const Duration(seconds: 2),
//     ),
//   );
// }
//
// void showDownloadSuccesss(String fileName) {
//   ScaffoldMessenger.of(context).showSnackBar(
//     SnackBar(
//       content: Text('$fileName downloaded successfully!'),
//       backgroundColor: Colors.green,
//       behavior: SnackBarBehavior.floating,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//     ),
//   );
// }
//
// @override
// Widget build(BuildContext context) {
//   return Scaffold(
//     backgroundColor: Colors.grey[100],
//     appBar: AppBar(
//       elevation: 6,
//       title: const Text(
//         'Divine Wallpapers',
//         style: TextStyle(fontWeight: FontWeight.bold),
//       ),
//       centerTitle: true,
//       flexibleSpace: Container(
//         decoration: const BoxDecoration(
//           gradient: LinearGradient(
//             colors: [Colors.deepOrange, Colors.orangeAccent],
//             begin: Alignment.topLeft,
//             end: Alignment.bottomRight,
//           ),
//         ),
//       ),
//       bottom: mandirTabs.isEmpty || _tabController == null
//           ? null
//           : PreferredSize(
//         preferredSize: const Size.fromHeight(70),
//         child: TabBar(
//           controller: _tabController,
//           isScrollable: true,
//           indicator: BoxDecoration(
//             borderRadius: BorderRadius.circular(40),
//             // color: Colors.white.withOpacity(0.2),
//           ),
//           labelColor: Colors.white,
//           unselectedLabelColor: Colors.white70,
//           tabs: mandirTabs.map((tab) {
//             return Column(
//               children: [
//                 CircleAvatar(
//                   radius: 22,
//                   backgroundImage: NetworkImage(tab.thumbnail ?? ""),
//                   backgroundColor: Colors.deepPurple[100],
//                 ),
//                 const SizedBox(height: 4),
//                 Text(
//                   tab.enName ?? "",
//                   style: const TextStyle(fontSize: 12),
//                 ),
//               ],
//             );
//           }).toList(),
//         ),
//       ),
//     ),
//     body: TabBarView(
//       controller: _tabController,
//       children: List.generate(
//         gods.length,
//             (index) => GridView.builder(
//           padding: const EdgeInsets.all(12),
//           gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//             crossAxisCount: 2,
//             crossAxisSpacing: 14,
//             mainAxisSpacing: 14,
//             childAspectRatio: 0.68,
//           ),
//           itemCount: gods[index]['images'].length,
//           itemBuilder: (context, imgIndex) {
//             final imgUrl = gods[index]['images'][imgIndex];
//
//             return InkWell(
//               onTap: () {
//                 // Optional: Open fullscreen image viewer with Hero animation
//               },
//               borderRadius: BorderRadius.circular(16),
//               child: Stack(
//                 children: [
//                   Hero(
//                     tag: imgUrl,
//                     child: ClipRRect(
//                       borderRadius: BorderRadius.circular(16),
//                       child: Image.network(
//                         imgUrl,
//                         fit: BoxFit.cover,
//                         width: double.infinity,
//                         height: double.infinity,
//                         errorBuilder: (context, error, stackTrace) => Container(
//                           color: Colors.grey[300],
//                           child: const Icon(Icons.broken_image,
//                               size: 50, color: Colors.grey),
//                         ),
//                         loadingBuilder: (context, child, loadingProgress) {
//                           if (loadingProgress == null) return child;
//                           return Container(
//                             color: Colors.grey[200],
//                             child: const Center(
//                               child: CircularProgressIndicator(strokeWidth: 2),
//                             ),
//                           );
//                         },
//                       ),
//                     ),
//                   ),
//                   Positioned(
//                     bottom: 8,
//                     left: 8,
//                     right: 8,
//                     child: Container(
//                       padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
//                       decoration: BoxDecoration(
//                         borderRadius: BorderRadius.circular(14),
//                         gradient: LinearGradient(
//                           colors: [
//                             Colors.black.withOpacity(0.6),
//                             Colors.black.withOpacity(0.2)
//                           ],
//                           begin: Alignment.bottomCenter,
//                           end: Alignment.topCenter,
//                         ),
//                         boxShadow: [
//                           BoxShadow(
//                             color: Colors.black.withOpacity(0.3),
//                             blurRadius: 6,
//                             offset: const Offset(0, 3),
//                           ),
//                         ],
//                       ),
//                       child: Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceAround,
//                         children: [
//                           IconButton(
//                             icon: const Icon(Icons.download, color: Colors.white),
//                             onPressed: () async {
//                               final fileName =
//                                   '${gods[index]['name']}${imgIndex + 1}.jpg';
//                               await downloadImage(imgUrl);
//                               showDownloadSuccesss(fileName);
//                             },
//                           ),
//                           IconButton(
//                             icon: const Icon(Icons.share, color: Colors.white),
//                             onPressed: () => shareImage(imgUrl),
//                           ),
//                           IconButton(
//                             icon: const Icon(Icons.wallpaper, color: Colors.white),
//                             onPressed: () => setWallpaper(imgUrl),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             );
//           },
//         ),
//       ),
//     ),
//   );
// }

// @override
// Widget build(BuildContext context) {
//   return Scaffold(
//     appBar: AppBar(
//       title: const Text('Divine Wallpapers'),
//       centerTitle: true,
//       backgroundColor: Colors.orange,
//       bottom: PreferredSize(
//         preferredSize: const Size.fromHeight(50),
//         child: Padding(
//           padding: const EdgeInsets.symmetric(vertical: 8.0),
//           child: TabBar(
//             controller: _tabController,
//             isScrollable: true,
//
//             indicatorColor: Colors.white,
//             labelColor: Colors.white,
//             unselectedLabelColor: Colors.white,
//             tabs: List.generate(
//               gods.length,
//                   (index) => Tab(
//                 child: Column(
//                   children: [
//                     CircleAvatar(
//                       radius: 20,
//                       backgroundImage: NetworkImage(gods[index]['icon']),
//                       backgroundColor: Colors.deepPurple[100],
//                     ),
//                     // const SizedBox(height: 4),
//                     // Text(
//                     //   gods[index]['name'],
//                     //   style: const TextStyle(fontSize: 1),
//                     // ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         ),
//       ),
//     ),
//     body: TabBarView(
//       controller: _tabController,
//       children: List.generate(
//         gods.length,
//             (index) => GridView.builder(
//           padding: const EdgeInsets.all(8),
//           gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//             crossAxisCount: 2,
//             crossAxisSpacing: 8,
//             mainAxisSpacing: 8,
//             childAspectRatio: 0.7,
//           ),
//           itemCount: gods[index]['images'].length,
//           itemBuilder: (context, imgIndex) {
//             // Define a list of colors for demonstration
//             // final List<Color> colors = [
//             //   Colors.red,
//             //   Colors.green,
//             //   Colors.blue,
//             //   Colors.yellow,
//             //   Colors.orange,
//             //   Colors.purple,
//             //   Colors.teal,
//             //   Colors.pink,
//             // ];
//
//             return Stack(
//               children: [
//                 ClipRRect(
//                   borderRadius: BorderRadius.circular(12),
//                   child: Image.network(
//                     gods[index]['images'][imgIndex],
//                     fit: BoxFit.cover,
//                     width: double.infinity,
//                     height: double.infinity,
//                     errorBuilder: (context, error, stackTrace) => Container(
//                       color: Colors.grey[300],
//                       child: const Icon(Icons.broken_image, size: 50, color: Colors.grey),
//                     ),
//                     loadingBuilder: (context, child, loadingProgress) {
//                       if (loadingProgress == null) return child;
//                       return Container(
//                         color: Colors.grey[200],
//                         child: const Center(
//                           child: CircularProgressIndicator(),
//                         ),
//                       );
//                     },
//                   ),
//                 ),
//                 Positioned(
//                   bottom: 0,
//                   left: 0,
//                   right: 0,
//                   child: Container(
//                     padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                     decoration: BoxDecoration(
//                       color: Colors.black.withOpacity(0.4),
//                       borderRadius: const BorderRadius.only(
//                         bottomLeft: Radius.circular(12),
//                         bottomRight: Radius.circular(12),
//                       ),
//                     ),
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                       children: [
//                         IconButton(
//                           icon: const Icon(Icons.download, color: Colors.white),
//                           onPressed: () async {
//                             final fileName = '${gods[index]['name']}${imgIndex + 1}.jpg';
//                             await downloadImage(gods[index]['images'][imgIndex]);
//                             showDownloadSuccess(fileName);
//                           },
//                         ),
//                         IconButton(
//                           icon: const Icon(Icons.share, color: Colors.white),
//                           onPressed: () => shareImage(gods[index]['images'][imgIndex]),
//                         ),
//                         IconButton(
//                           icon: const Icon(Icons.wallpaper, color: Colors.white),
//                           onPressed: () {
//                             setWallpaper(gods[index]['images'][imgIndex]);
//                           },
//                         ),
//
//                       ],
//                     ),
//                   ),
//                 ),
//               ],
//             );
//
//           },
//         ),
//       ),
//     ),
//   );
// }

/////////////----/////



// import 'dart:convert';
// import 'dart:math' as math;
// import 'dart:ui';
//
// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:flutter/gestures.dart';
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart' show ImagePicker, ImageSource;
// import 'package:mahakal/features/mandir/model/mandir_model.dart';
// import 'package:share_plus/share_plus.dart';
// import 'package:http/http.dart' as http;
// import 'dart:io';
// import 'dart:typed_data';
// import 'package:path_provider/path_provider.dart';
// import 'package:screenshot/screenshot.dart';
// import '../../../data/datasource/remote/http/httpClient.dart';
// import 'package:flutter/cupertino.dart';
// import '../../../utill/app_constants.dart';
// import 'package:image_picker/image_picker.dart';
//
// import 'package:flutter/rendering.dart';
//
// import 'edit_image_screen.dart';
//
// // Wallpaper model
// class Wallpaper {
//   int? status;
//   List<Data>? data;
//
//   Wallpaper({this.status, this.data});
//
//   Wallpaper.fromJson(Map<String, dynamic> json) {
//     status = json['status'];
//
//     if (json['data'] != null) {
//       data = <Data>[];
//
//       var rawData = json['data'];
//
//       // If data is String (JSON string), decode it first
//       if (rawData is String) {
//         rawData = jsonDecode(rawData);
//       }
//
//       if (rawData is List) {
//         for (var v in rawData) {
//           data!.add(Data.fromJson(v));
//         }
//       }
//     }
//   }
//
//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = <String, dynamic>{};
//     data['status'] = status;
//     if (this.data != null) {
//       data['data'] = this.data!.map((v) => v.toJson()).toList();
//     }
//     return data;
//   }
// }
//
// class Data {
//   int? id;
//   String? enName;
//   String? hiName;
//   String? thumbnail;
//   List<String>? wallpapers;
//   String? week;
//   dynamic date;
//
//   Data({
//     this.id,
//     this.enName,
//     this.hiName,
//     this.thumbnail,
//     this.wallpapers,
//     this.week,
//     this.date,
//   });
//
//   Data.fromJson(Map<String, dynamic> json) {
//     id = json['id'];
//     enName = json['en_name'];
//     hiName = json['hi_name'];
//     thumbnail = json['thumbnail'];
//
//     print(
//         "🟢 Parsing ${json['en_name']} → wallpapers raw: ${json['wallpapers']}"); // 👈 add this
//
//     wallpapers = [];
//     if (json['wallpapers'] != null && json['wallpapers'] is List) {
//       for (var w in json['wallpapers']) {
//         if (w is String && w.isNotEmpty) {
//           wallpapers!.add(w);
//         } else if (w is Map && w['image'] != null) {
//           wallpapers!.add(w['image'].toString());
//         }
//       }
//     }
//
//     week = json['week'];
//     date = json['date'];
//   }
//
//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = <String, dynamic>{};
//     data['id'] = id;
//     data['en_name'] = enName;
//     data['hi_name'] = hiName;
//     data['thumbnail'] = thumbnail;
//     data['wallpapers'] = wallpapers;
//     data['week'] = week;
//     data['date'] = date;
//     return data;
//   }
// }
//
// class WallpaperScreen extends StatefulWidget {
//   const WallpaperScreen({Key? key}) : super(key: key);
//
//   @override
//   State<WallpaperScreen> createState() => _WallpaperScreenState();
// }
//
// class _WallpaperScreenState extends State<WallpaperScreen>
//     with SingleTickerProviderStateMixin {
//   late TabController _tabController;
//   bool isLoading = false;
//   List<Data> wallpaperTabs = [];
//
//   @override
//   void initState() {
//     super.initState();
//
//     fetchWallpapers();
//   }
//
//   Future<void> fetchWallpapers() async {
//     setState(() => isLoading = true);
//
//     try {
//       final res = await HttpService().getApi(AppConstants.wallpaperData);
//       print('RAW API RESPONSE: $res');
//       print(
//           "RAW data type: ${res['data'].runtimeType}"); // Check if String or List
//
//       if (res != null) {
//         print('🔴 RAW API RESPONSE: $res'); // 👈 add this
//         final wallpaperModel = Wallpaper.fromJson(res);
//
//         if (wallpaperModel.data != null && wallpaperModel.data!.isNotEmpty) {
//           // 🔥 Debug print for enName
//           for (var tab in wallpaperModel.data!) {
//             print(
//                 '📌 ${tab.enName} wallpapers count → ${tab.wallpapers?.length ?? 0}');
//             print('🖼 Raw wallpapers for ${tab.enName}: ${tab.wallpapers}');
//           }
//
//           setState(() {
//             wallpaperTabs = wallpaperModel.data!;
//             _tabController =
//                 TabController(length: wallpaperTabs.length, vsync: this);
//           });
//         }
//       }
//     } catch (e) {
//       print('❌ Error fetching wallpapers: $e');
//     } finally {
//       setState(() => isLoading = false);
//     }
//   }
//
//   @override
//   void dispose() {
//     if (wallpaperTabs.isNotEmpty) {
//       _tabController.dispose();
//     }
//     super.dispose();
//   }
//
//   Future<String> downloadImage(String url) async {
//     final response = await http.get(Uri.parse(url));
//     final directory = await getApplicationDocumentsDirectory();
//     final filePath =
//         '${directory.path}/${DateTime.now().millisecondsSinceEpoch}.jpg';
//     final file = File(filePath);
//     await file.writeAsBytes(response.bodyBytes);
//     return filePath;
//   }
//
//   void shareImage(String imageUrl) async {
//     try {
//       final filePath = await downloadImage(imageUrl);
//       await Share.shareXFiles(
//         [XFile(filePath)],
//         text: 'Check out this beautiful wallpaper!',
//       );
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Failed to share image: $e')),
//       );
//     }
//   }
//
//   void showDownloadSuccesss(String fileName) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text('$fileName downloaded successfully!'),
//         backgroundColor: Colors.green,
//         behavior: SnackBarBehavior.floating,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       ),
//     );
//   }
//
//   void openEditor(String imgUrl) {
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (_) => ImageEditorScreen(imageUrl: imgUrl),
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     if (isLoading) {
//       return Scaffold(
//         appBar: AppBar(
//           elevation: 0,
//           backgroundColor: Colors.white,
//           centerTitle: true,
//           leading: IconButton(
//             icon: const Icon(
//               Icons.arrow_back_ios_new_rounded,
//               size: 20,
//               color: Colors.black,
//             ),
//             onPressed: () => Navigator.pop(context),
//           ),
//           title: Text( 'Divine Wallpapers', style: TextStyle( fontSize: 22, fontWeight: FontWeight.w800, foreground: Paint() ..shader = LinearGradient( colors: [ Color(0xFF12C2E9), Color(0xFFC471ED), Color(0xFFF64F59), ], ).createShader( Rect.fromLTWH(0.0, 0.0, 200.0, 70.0), ), ), ),
//         ),
//         body: const Center(child: CircularProgressIndicator(color: Colors.deepOrange,)),
//       );
//     }
//
//     if (wallpaperTabs.isEmpty) {
//       return Scaffold(
//         backgroundColor: Colors.white,
//         appBar: AppBar(
//           elevation: 1,
//           backgroundColor: Colors.white,
//           centerTitle: true,
//           leading: IconButton(
//             icon: const Icon(
//               Icons.arrow_back_ios_new_rounded,
//               size: 20,
//               color: Colors.black,
//             ),
//             onPressed: () => Navigator.pop(context),
//           ),
//           title: Text(
//             'Divine Wallpapers',
//             style: TextStyle(
//               fontSize: 22,
//               fontWeight: FontWeight.w800,
//               foreground: Paint()
//                 ..shader = LinearGradient(
//                   colors: [
//                     Color(0xFF12C2E9),
//                     Color(0xFFC471ED),
//                     Color(0xFFF64F59),
//                   ],
//                 ).createShader(
//                   const Rect.fromLTWH(0.0, 0.0, 200.0, 70.0),
//                 ),
//             ),
//           ),
//         ),
//         body: Center(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               /// Empty state illustration
//               Container(
//                 width: 150,
//                 height: 150,
//                 decoration: BoxDecoration(
//                   image: DecorationImage(
//                     image: AssetImage('assets/images/empty_wallpaper.png'),
//                     fit: BoxFit.contain,
//                   ),
//                 ),
//               ),
//
//               const SizedBox(height: 24),
//
//               /// Main message
//               const Text(
//                 'No Wallpapers Found',
//                 style: TextStyle(
//                   fontSize: 20,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.black87,
//                 ),
//               ),
//
//               const SizedBox(height: 8),
//
//               /// Subtext
//               const Text(
//                 'Check back later or explore our collection',
//                 textAlign: TextAlign.center,
//                 style: TextStyle(
//                   fontSize: 15,
//                   color: Colors.grey,
//                 ),
//               ),
//
//               const SizedBox(height: 24),
//
//               /// Optional button (refresh / explore)
//               ElevatedButton.icon(
//                 onPressed: () {
//                   // Call your refresh or explore logic here
//                 },
//                 icon: const Icon(Icons.refresh_rounded),
//                 label: const Text('Try Again'),
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: const Color(0xFF12C2E9),
//                   padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(30),
//                   ),
//                   textStyle: const TextStyle(
//                     fontSize: 16,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       );
//     }
//
//     return Scaffold(
//       backgroundColor: Colors.grey[100],
//       appBar:  AppBar(
//         elevation: 0,
//         backgroundColor: Colors.transparent,
//         flexibleSpace: Container(
//           decoration: const BoxDecoration(
//             gradient: LinearGradient(
//               begin: Alignment.topLeft,
//               end: Alignment.bottomRight,
//               colors: [
//                 Color(0xFFE65100), // deep orange (rich)
//                 Color(0xFFFF6A3D), // warm orange
//                 Color(0xFFFFE16A), // soft deep orange
//               ],
//
//             ),
//           ),
//         ),
//         title: const Text(
//           'Divine Wallpapers',
//           style: TextStyle(
//             color: Colors.white,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//         centerTitle: true,
//         leading: IconButton(
//           icon: const Icon(
//             Icons.arrow_back_ios_new_rounded,
//             size: 20,
//             color: Colors.white,
//           ),
//           onPressed: () => Navigator.pop(context),
//         ),
//         iconTheme: const IconThemeData(color: Colors.white), bottom: PreferredSize(
//         preferredSize: const Size.fromHeight(80),
//         child: Padding(
//           padding: const EdgeInsets.only(bottom: 5,top: 15),
//           child: _tabBar(),
//         ),
//       ),
//       ),
//       body: TabBarView(
//         controller: _tabController,
//         children: wallpaperTabs.map((tab) {
//           final images = tab.wallpapers ?? [];
//
//           // 🔥 Case 1: No images
//           if (images.isEmpty) {
//             return Center(
//               child: Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 32),
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   crossAxisAlignment: CrossAxisAlignment.center,
//                   children: [
//                     // Enhanced Gradient Container with Shadow
//                     Container(
//                       height: 130,
//                       width: 130,
//                       decoration: BoxDecoration(
//                         shape: BoxShape.circle,
//                         gradient: LinearGradient(
//                           colors: [
//                             Color(0xFFFFE0D6).withOpacity(0.9),
//                             Color(0xFFFFCCBC),
//                             Color(0xFFFFAB91),
//                           ],
//                           stops: [0.0, 0.5, 1.0],
//                           begin: Alignment.topLeft,
//                           end: Alignment.bottomRight,
//                         ),
//                         boxShadow: [
//                           BoxShadow(
//                             color: Color(0xFFFF7043).withOpacity(0.2),
//                             blurRadius: 20,
//                             spreadRadius: 2,
//                             offset: Offset(0, 8),
//                           ),
//                           BoxShadow(
//                             color: Colors.black.withOpacity(0.05),
//                             blurRadius: 10,
//                             spreadRadius: 1,
//                             offset: Offset(0, 4),
//                           ),
//                         ],
//                       ),
//                       child: Stack(
//                         children: [
//                           // Background Pattern
//                           Center(
//                             child: Container(
//                               width: 60,
//                               height: 60,
//                               decoration: BoxDecoration(
//                                 shape: BoxShape.circle,
//                                 color: Colors.white.withOpacity(0.2),
//                               ),
//                             ),
//                           ),
//                           // Main Icon
//                           Center(
//                             child: Icon(
//                               Icons.wallpaper_rounded, // Changed to filled version
//                               size: 52,
//                               color: Color(0xFFFF5722),
//                             ),
//                           ),
//                           // Decorative Dots
//                           Positioned(
//                             top: 20,
//                             right: 20,
//                             child: Container(
//                               width: 12,
//                               height: 12,
//                               decoration: BoxDecoration(
//                                 shape: BoxShape.circle,
//                                 color: Colors.white.withOpacity(0.3),
//                               ),
//                             ),
//                           ),
//                           Positioned(
//                             bottom: 25,
//                             left: 25,
//                             child: Container(
//                               width: 8,
//                               height: 8,
//                               decoration: BoxDecoration(
//                                 shape: BoxShape.circle,
//                                 color: Colors.white.withOpacity(0.3),
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//
//                     const SizedBox(height: 28),
//
//                     // Title with better typography
//                     const Text(
//                       "No Wallpapers Available",
//                       textAlign: TextAlign.center,
//                       style: TextStyle(
//                         fontSize: 20,
//                         fontWeight: FontWeight.w700,
//                         color: Colors.black87,
//                         letterSpacing: -0.2,
//                       ),
//                     ),
//
//                     const SizedBox(height: 12),
//
//                     // Description with improved styling
//                     Container(
//                       padding: const EdgeInsets.symmetric(horizontal: 16),
//                       child: const Text(
//                         "New wallpapers are being crafted with care. "
//                             "We're adding fresh designs that you'll love!\n\n"
//                             "Check back soon for exciting updates.",
//                         textAlign: TextAlign.center,
//                         style: TextStyle(
//                           fontSize: 15,
//                           color: Colors.black54,
//                           height: 1.5,
//                           fontWeight: FontWeight.w400,
//                         ),
//                       ),
//                     ),
//
//                     const SizedBox(height: 24),
//
//                     // Optional: Add a progress indicator or refresh button
//                     Container(
//                       padding: const EdgeInsets.symmetric(horizontal: 40),
//                       child: Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                         children: [
//                           // Progress Dots
//                           Container(
//                             width: 8,
//                             height: 8,
//                             decoration: BoxDecoration(
//                               shape: BoxShape.circle,
//                               color: Color(0xFFFF7043),
//                             ),
//                           ),
//                           Container(
//                             width: 8,
//                             height: 8,
//                             decoration: BoxDecoration(
//                               shape: BoxShape.circle,
//                               color: Color(0xFFFF7043).withOpacity(0.3),
//                             ),
//                           ),
//                           Container(
//                             width: 8,
//                             height: 8,
//                             decoration: BoxDecoration(
//                               shape: BoxShape.circle,
//                               color: Color(0xFFFF7043).withOpacity(0.3),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//
//                     const SizedBox(height: 16),
//
//                     // Optional: Add a refresh button
//                     // TextButton(
//                     //   onPressed: () {},
//                     //   style: TextButton.styleFrom(
//                     //     foregroundColor: Color(0xFFFF7043),
//                     //     padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
//                     //     shape: RoundedRectangleBorder(
//                     //       borderRadius: BorderRadius.circular(20),
//                     //     ),
//                     //   ),
//                     //   child: Row(
//                     //     mainAxisSize: MainAxisSize.min,
//                     //     children: [
//                     //       Icon(Icons.refresh_rounded, size: 18),
//                     //       SizedBox(width: 8),
//                     //       Text(
//                     //         "Refresh",
//                     //         style: TextStyle(fontWeight: FontWeight.w500),
//                     //       ),
//                     //     ],
//                     //   ),
//                     // ),
//                   ],
//                 ),
//               ),
//             );
//           }
//
//           // ✅ Case 2: Images available
//           return GridView.builder(
//             padding: const EdgeInsets.all(12),
//             gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//               crossAxisCount: 2,
//               crossAxisSpacing: 14,
//               mainAxisSpacing: 14,
//               childAspectRatio: 0.68,
//             ),
//             itemCount: images.length,
//             itemBuilder: (context, imgIndex) {
//               final imgUrl = images[imgIndex];
//
//               return InkWell(
//                 onTap: () => openEditor(imgUrl),
//                 borderRadius: BorderRadius.circular(16),
//                 child: Stack(
//                   children: [
//                     /// IMAGE
//                     Hero(
//                       tag: imgUrl,
//                       child: ClipRRect(
//                         borderRadius: BorderRadius.circular(18),
//                         child: Image.network(
//                           imgUrl,
//                           fit: BoxFit.cover,
//                           width: double.infinity,
//                           height: double.infinity,
//                           errorBuilder: (_, __, ___) => Container(
//                             color: Colors.grey.shade300,
//                             child: const Icon(Icons.broken_image,
//                                 size: 50, color: Colors.grey),
//                           ),
//                           loadingBuilder: (context, child, progress) {
//                             if (progress == null) return child;
//                             return Container(
//                               color: Colors.grey.shade200,
//                               child: const Center(
//                                 child: CircularProgressIndicator(strokeWidth: 2),
//                               ),
//                             );
//                           },
//                         ),
//                       ),
//                     ),
//
//                     /// GRADIENT OVERLAY (for better icon visibility)
//                     Positioned.fill(
//                       child: Container(
//                         decoration: BoxDecoration(
//                           borderRadius: BorderRadius.circular(18),
//                           gradient: LinearGradient(
//                             begin: Alignment.bottomCenter,
//                             end: Alignment.topCenter,
//                             colors: [
//                               Colors.black.withOpacity(0.45),
//                               Colors.transparent,
//                             ],
//                           ),
//                         ),
//                       ),
//                     ),
//
//                     /// ACTION BAR
//                     Positioned(
//                       bottom: 12,
//                       left: 6,
//                       right: 6,
//                       child: ClipRRect(
//                         borderRadius: BorderRadius.circular(30),
//                         child: BackdropFilter(
//                           filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
//                           child: Container(
//                             padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
//                             decoration: BoxDecoration(
//                               color: Colors.white.withOpacity(0.15),
//                               borderRadius: BorderRadius.circular(30),
//                               border: Border.all(
//                                 color: Colors.white.withOpacity(0.25),
//                               ),
//                             ),
//                             child: Row(
//                               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                               children: [
//                                 _actionButton(
//                                     icon: Icons.download,
//                                     onTap: () async {
//                                       final fileName =
//                                           '${tab.enName}${imgIndex + 1}.jpg';
//                                       await downloadImage(imgUrl);
//                                       showDownloadSuccesss(fileName);
//                                     },
//                                     color: Colors.white
//                                 ),
//                                 _actionButton(
//                                     icon: Icons.share,
//                                     onTap: () => shareImage(imgUrl),
//                                     color: Colors.white
//                                 ),
//                                 _actionButton(
//                                     icon: Icons.edit,
//                                     onTap: () => openEditor(imgUrl),
//                                     color: Colors.green
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               );
//             },
//           );
//         }).toList(),
//       ),
//     );
//   }
//
//   Widget _actionButton({
//     required IconData icon,
//     required VoidCallback onTap,
//     required Color color,
//   }) {
//     return InkWell(
//       onTap: onTap,
//       borderRadius: BorderRadius.circular(50),
//       splashColor: Colors.white24,
//       child: Padding(
//         padding: const EdgeInsets.all(10),
//         child: Icon(
//           icon,
//           color: color,
//           size: 20,
//         ),
//       ),
//     );
//   }
//
//   Widget _tabBar() {
//     return TabBar(
//       controller: _tabController,
//       isScrollable: true,
//       tabAlignment: TabAlignment.start,
//
//       dividerColor: Colors.transparent,
//       splashFactory: NoSplash.splashFactory,
//       overlayColor: MaterialStateProperty.all(Colors.transparent),
//
//       indicatorSize: TabBarIndicatorSize.tab,
//       indicator: BoxDecoration(
//         borderRadius: BorderRadius.circular(12),
//         gradient: const LinearGradient(
//           colors: [
//             Color(0xFFFF9A76),
//             Color(0xFFFF7043),
//           ],
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//         ),
//         boxShadow: [
//           BoxShadow(
//             color: Color(0x30FF7043),
//             blurRadius: 6,
//             offset: Offset(0, 3),
//           ),
//         ],
//       ),
//
//       labelColor: Colors.white,
//       unselectedLabelColor: Colors.black87,
//
//       padding: const EdgeInsets.symmetric(horizontal: 12),
//       labelPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
//
//       tabs: wallpaperTabs.map((tab) {
//         return Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             CircleAvatar(
//               radius: 20,
//               backgroundImage: NetworkImage(tab.thumbnail ?? ""),
//               backgroundColor: Colors.grey.shade300,
//             ),
//             const SizedBox(height: 6),
//             Text(
//               tab.enName ?? '',
//               maxLines: 1,
//               overflow: TextOverflow.ellipsis,
//               style: const TextStyle(
//                 fontSize: 13,
//                 fontWeight: FontWeight.w600,
//               ),
//             ),
//           ],
//         );
//       }).toList(),
//     );
//   }
//
//
// }
