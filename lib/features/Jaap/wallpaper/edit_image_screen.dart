import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mahakal/features/Jaap/wallpaper/user_detail.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';

// Frame model class
class FrameData {
  final String name;
  final String imageUrl;
  final bool isSelected;
  final FrameStyle style;

  FrameData({
    required this.name,
    required this.imageUrl,
    this.isSelected = false,
    required this.style,
  });
}

// Frame style with user information
enum FrameStyle {
  // Existing frame
  bottomCenter,
  bottomRight,

  // New image-based frames
  imageWithPolaroid,
  imageWithCircleFrame,

  // Name-only frames
  bottomNameOnlySimple,
  bottomNameOnlyMinimal,
}

// Image aspect ratio options
enum ImageAspectRatio {
  ratio9_16, // 9:16 - portrait/vertical format (DEFAULT)
  ratio4_5,  // 4:5 - social media format
}

class ImageEditorScreen extends StatefulWidget {
  String imageUrl;
  final Map<String, dynamic>? userData;

  ImageEditorScreen({Key? key, required this.imageUrl, this.userData}) : super(key: key);

  @override
  State<ImageEditorScreen> createState() => _ImageEditorScreenState();
}

class _ImageEditorScreenState extends State<ImageEditorScreen> with SingleTickerProviderStateMixin {
  final ScreenshotController _screenshotController = ScreenshotController();
  final GlobalKey _imageContainerKey = GlobalKey();
  AnimationController? _scaleController;
  ColorFilter? _selectedFilter;
  bool _showControls = true;

  bool _showWatermark = false;
  List<FrameData> _availableFrames = [];
  FrameData? _selectedFrame;
  bool _isLoadingFrames = false;

  // Current frame index for swipe navigation
  int _currentFrameIndex = -1; // -1 means no frame

  // Image aspect ratio - default 9:16
  ImageAspectRatio _currentAspectRatio = ImageAspectRatio.ratio9_16;

  // User information from UserDetailScreen
  String _userName = "";
  String _email = "";
  String _phoneNumber = "";
  String _website = "";
  File? _userImage;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 100),
    )..addListener(() {
      setState(() {});
    });

    // Load user data if available
    if (widget.userData != null) {
      _loadUserData(widget.userData!);
    }

    _refreshFrames();
  }

  void _loadUserData(Map<String, dynamic> userData) {
    setState(() {
      if (userData['name'] != null && userData['name'].toString().isNotEmpty) {
        _userName = userData['name'].toString().toUpperCase();
      }
      if (userData['email'] != null && userData['email'].toString().isNotEmpty) {
        _email = userData['email'].toString();
      }
      if (userData['phone'] != null && userData['phone'].toString().isNotEmpty) {
        _phoneNumber = userData['phone'].toString();
      }
      if (userData['website'] != null && userData['website'].toString().isNotEmpty) {
        _website = userData['website'].toString();
      }
      if (userData['image'] != null && userData['image'] is File) {
        _userImage = userData['image'] as File;
      }
    });
  }

  @override
  void dispose() {
    _scaleController?.dispose();
    super.dispose();
  }

  // Get image height based on selected aspect ratio
  double _getImageHeight(double screenWidth) {
    switch (_currentAspectRatio) {
      case ImageAspectRatio.ratio9_16:
        return screenWidth * 16 / 9; // 9:16 ratio (taller, portrait mode)
      case ImageAspectRatio.ratio4_5:
        return screenWidth * 5 / 4; // 4:5 ratio (shorter for social media)
    }
  }

  // Toggle aspect ratio
  void _toggleAspectRatio() {
    setState(() {
      if (_currentAspectRatio == ImageAspectRatio.ratio9_16) {
        _currentAspectRatio = ImageAspectRatio.ratio4_5;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Switched to 4:5 ratio (Social Media)'),
            duration: Duration(seconds: 1),
          ),
        );
      } else {
        _currentAspectRatio = ImageAspectRatio.ratio9_16;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Switched to 9:16 ratio (Portrait)'),
            duration: Duration(seconds: 1),
          ),
        );
      }
    });
  }

  // Swipe to change frame
  void _handleHorizontalSwipe(DragEndDetails details) {
    if (_availableFrames.isEmpty) return;

    // Check if swipe is horizontal and significant
    if (details.primaryVelocity == null) return;

    if (details.primaryVelocity! > 500) {
      // Swipe Right - Previous frame
      setState(() {
        if (_currentFrameIndex == -1) {
          // If no frame selected, go to last frame
          _currentFrameIndex = _availableFrames.length - 1;
        } else if (_currentFrameIndex > 0) {
          _currentFrameIndex--;
        } else {
          // If at first frame, go to no frame
          _currentFrameIndex = -1;
        }

        _selectedFrame = _currentFrameIndex == -1 ? null : _availableFrames[_currentFrameIndex];
      });

      // Haptic feedback
      HapticFeedback.heavyImpact();

    } else if (details.primaryVelocity! < -500) {
      // Swipe Left - Next frame
      setState(() {
        if (_currentFrameIndex == -1) {
          // If no frame selected, go to first frame
          _currentFrameIndex = 0;
        } else if (_currentFrameIndex < _availableFrames.length - 1) {
          _currentFrameIndex++;
        } else {
          // If at last frame, go to no frame
          _currentFrameIndex = -1;
        }

        _selectedFrame = _currentFrameIndex == -1 ? null : _availableFrames[_currentFrameIndex];
      });

      // Haptic feedback
      HapticFeedback.lightImpact();
    }
  }

  Future<void> _loadSampleFrames() async {
    setState(() {
      _isLoadingFrames = true;
    });

    // Create frames with only the active styles
    final List<Map<String, dynamic>> frameSources = [
      // Existing frames
      {
        'name': 'Classic Center',
        'url': 'https://picsum.photos/id/1043/400/400?grayscale',
        'style': FrameStyle.bottomCenter,
      },
      {
        'name': 'Modern Right',
        'url': 'https://picsum.photos/id/108/400/400',
        'style': FrameStyle.bottomRight,
      },

      // Image-based frames
      {
        'name': 'Polaroid',
        'url': 'https://picsum.photos/id/25/400/400',
        'style': FrameStyle.imageWithPolaroid,
      },
      {
        'name': 'Circle Frame',
        'url': 'https://picsum.photos/id/26/400/400',
        'style': FrameStyle.imageWithCircleFrame,
      },

      // Name-only frames
      {
        'name': 'Name Only Simple',
        'url': 'https://picsum.photos/id/1043/400/400?grayscale',
        'style': FrameStyle.bottomNameOnlySimple,
      },
      {
        'name': 'Name Only Minimal',
        'url': 'https://picsum.photos/id/108/400/400',
        'style': FrameStyle.bottomNameOnlyMinimal,
      },
    ];

    setState(() {
      _availableFrames = frameSources.map((frame) =>
          FrameData(
            name: frame['name']!,
            imageUrl: frame['url']!,
            style: frame['style'],
          )
      ).toList();
      _isLoadingFrames = false;
    });
  }

  void _showFrameSelector() {
    if (_availableFrames.isEmpty) {
      _loadSampleFrames();
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            child: Container(
              color: Colors.white,
              height: MediaQuery.of(context).size.height * 0.7,
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade400,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  const SizedBox(height: 12),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Choose Frame',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 8),

                  Expanded(
                    child: _isLoadingFrames
                        ? const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.deepOrange),
                      ),
                    )
                        : GridView.builder(
                      padding: const EdgeInsets.all(16),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: 0.9,
                      ),
                      itemCount: _availableFrames.length + 1,
                      itemBuilder: (context, index) {
                        if (index == 0) {
                          return _buildFrameTile(
                            name: 'No Frame',
                            imageUrl: null,
                            isSelected: _selectedFrame == null,
                            onTap: () {
                              setState(() {
                                _selectedFrame = null;
                                _currentFrameIndex = -1;
                              });
                              Navigator.pop(context);
                            },
                          );
                        }

                        final frameIndex = index - 1;
                        final frame = _availableFrames[frameIndex];

                        return _buildFrameTile(
                          name: frame.name,
                          imageUrl: frame.imageUrl,
                          isSelected: _selectedFrame?.name == frame.name,
                          onTap: () {
                            setState(() {
                              _selectedFrame = frame;
                              _currentFrameIndex = frameIndex;
                            });
                            Navigator.pop(context);
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _refreshFrames() {
    _loadSampleFrames();
  }

  Widget _buildFrameTile({
    required String name,
    String? imageUrl,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? Colors.deepOrange : Colors.grey.shade300,
            width: isSelected ? 3 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              flex: 3,
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(14),
                ),
                child: imageUrl != null
                    ? Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey.shade200,
                      child: const Center(
                        child: Icon(
                          Icons.broken_image,
                          size: 40,
                          color: Colors.grey,
                        ),
                      ),
                    );
                  },
                )
                    : Container(
                  color: Colors.grey.shade200,
                  child: const Center(
                    child: Icon(
                      Icons.no_photography,
                      size: 40,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: isSelected ? Colors.deepOrange.withOpacity(0.1) : Colors.transparent,
                  borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(14),
                  ),
                ),
                child: Center(
                  child: Text(
                    name,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      color: isSelected ? Colors.deepOrange : Colors.black87,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showFilterOptions() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            child: Container(
              color: Colors.white,
              child: SafeArea(
                top: false,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 10),
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade400,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    const SizedBox(height: 12),

                    const Text(
                      'Choose Filter',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 16),

                    Flexible(
                      child: ListView(
                        shrinkWrap: true,
                        children: [
                          _filterTile(
                            title: 'Normal',
                            isSelected: _selectedFilter == null,
                            onTap: () {
                              setState(() => _selectedFilter = null);
                              Navigator.pop(context);
                            },
                          ),
                          _filterTile(
                            title: 'Sepia',
                            onTap: () {
                              setState(() {
                                _selectedFilter = ColorFilter.mode(
                                  Colors.brown.withOpacity(0.4),
                                  BlendMode.modulate,
                                );
                              });
                              Navigator.pop(context);
                            },
                          ),
                          _filterTile(
                            title: 'Blue Tint',
                            onTap: () {
                              setState(() {
                                _selectedFilter = ColorFilter.mode(
                                  Colors.blue.withOpacity(0.3),
                                  BlendMode.overlay,
                                );
                              });
                              Navigator.pop(context);
                            },
                          ),
                          _filterTile(
                            title: 'High Contrast',
                            onTap: () {
                              setState(() {
                                _selectedFilter = const ColorFilter.matrix(<double>[
                                  1.5, 0, 0, 0, 0,
                                  0, 1.5, 0, 0, 0,
                                  0, 0, 1.5, 0, 0,
                                  0, 0, 0, 1, 0,
                                ]);
                              });
                              Navigator.pop(context);
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildWatermark(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Positioned(
      bottom: 20,
      left: 0,
      right: 0,
      child: Opacity(
        opacity: _showWatermark ? 1.0 : 0.0,
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.2),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(
                horizontal: screenWidth * 0.04,
                vertical: screenWidth * 0.01),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () {},
                  child: Container(
                    height: screenWidth * 0.13,
                    width: screenWidth * 0.18,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Padding(
                      padding: EdgeInsets.only(
                          left: screenWidth * 0.02),
                      child: const Image(
                        image: AssetImage(
                            "assets/image/playstore.png"),
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 5),
                GestureDetector(
                  onTap: () {},
                  child: Container(
                    height: screenWidth * 0.12,
                    width: screenWidth * 0.18,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Padding(
                      padding: EdgeInsets.only(
                          right: screenWidth * 0.02),
                      child: const Image(
                        image: AssetImage(
                            "assets/image/appstore.png"),
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {},
                  child: Container(
                    height: screenWidth * 0.13,
                    width: screenWidth * 0.45,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Padding(
                      padding: EdgeInsets.only(
                          left: screenWidth * 0.02,
                          right: screenWidth * 0.02),
                      child: const Image(
                        image: AssetImage("assets/image/mahakal_logo.png"),
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _filterTile({
    required String title,
    required VoidCallback onTap,
    bool isSelected = false,
  }) {
    return ListTile(
      onTap: onTap,
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: isSelected ? Colors.deepOrange : Colors.black87,
        ),
      ),
      trailing: isSelected
          ? const Icon(Icons.check_circle, color: Colors.deepOrange)
          : null,
    );
  }

  // ====== TEXTS ======
  final List<_OverlayTextData> _overlayTexts = [];

  final List<Color> _textColors = [
    Colors.white,
    Colors.black,
    Colors.red,
    Colors.blue,
    Colors.green,
    Colors.yellow,
    Colors.purple,
    Colors.orange,
  ];

  final List<Color> _backgroundColors = [
    Colors.transparent,
    Colors.black54,
    Colors.white,
    Colors.yellowAccent,
    Colors.blue.withOpacity(0.5),
    Colors.red.withOpacity(0.5),
    Colors.green.withOpacity(0.5),
    Colors.purple.withOpacity(0.5),
  ];

  final List<Map<String, dynamic>> _fontStyles = [
    {
      'name': 'Normal',
      'style': FontStyle.normal,
      'weight': FontWeight.normal,
      'icon': Icons.text_format
    },
    {
      'name': 'Bold',
      'style': FontStyle.normal,
      'weight': FontWeight.bold,
      'icon': Icons.format_bold
    },
    {
      'name': 'Italic',
      'style': FontStyle.italic,
      'weight': FontWeight.normal,
      'icon': Icons.format_italic
    },
  ];

  // ====== LOGOS ======
  List<_OverlayImageData> _overlayImages = [];

  // ====== DRAWING ======
  bool _isDrawing = false;
  List<DrawnLine> _lines = [];
  List<DrawnLine> _undoneLines = [];

  // ====== DELETE ZONE ======
  bool _showDeleteZone = false;
  final GlobalKey _deleteZoneKey = GlobalKey();

  // ====== HISTORY ======
  final List<EditorAction> _actionsHistory = [];
  final List<EditorAction> _redoStack = [];

  Future<File> _saveEditedImage() async {
    final Uint8List? imageBytes = await _screenshotController.capture();
    if (imageBytes == null) throw Exception('Failed to capture image');

    final dir = await getTemporaryDirectory();
    final file =
    File('${dir.path}/edited_${DateTime.now().millisecondsSinceEpoch}.png');
    await file.writeAsBytes(imageBytes);
    return file;
  }

  void _shareEditedImage() async {
    setState(() {
      _showControls = false;
      _showWatermark = false;
    });

    await Future.delayed(const Duration(milliseconds: 200));

    try {
      final file = await _saveEditedImage();
      await Future.delayed(const Duration(milliseconds: 100));

      final RenderBox? box = context.findRenderObject() as RenderBox?;
      final Rect sharePositionOrigin = box != null && box.hasSize
          ? box.localToGlobal(Offset.zero) & box.size
          : const Rect.fromLTWH(0, 0, 1, 1);

      final result = await Share.shareXFiles([XFile(file.path)],
          text: '🌸 Jai Shree Mahakal 🌸\n'
              'Feel the divine energy of Baba Mahakal every time you unlock your phone 🔱\n\n'
              '🕉 Download exclusive Spiritual Wallpapers, Pujas, Live Darshan & more on:\n'
              '🌐 https://mahakal.com/downloads',
          sharePositionOrigin: sharePositionOrigin);

      if (mounted) {
        setState(() {
          _showWatermark = false;
          _showControls = true;
        });
      }
    } catch (e) {
      print('Error sharing image: $e');
      if (mounted) {
        setState(() {
          _showWatermark = false;
          _showControls = true;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to share image. Please try again.'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  Future<void> _pickLogo() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      final logo = _OverlayImageData(
        file: File(picked.path),
        position: Offset(70, 70),
        size: 150,
      );
      setState(() {
        _overlayImages.add(logo);
        _actionsHistory.add(EditorAction.addLogo(logo));
        _redoStack.clear();
      });
    }
  }

  void _undo() {
    if (_actionsHistory.isEmpty) return;
    final last = _actionsHistory.removeLast();
    _redoStack.add(last);

    setState(() {
      if (last.type == ActionType.addText) {
        _overlayTexts.remove(last.textData);
      } else if (last.type == ActionType.addLogo) {
        _overlayImages.remove(last.imageData);
      } else if (last.type == ActionType.draw) {
        if (_lines.isNotEmpty) _undoneLines.add(_lines.removeLast());
      }
    });
  }

  void _redo() {
    if (_redoStack.isEmpty) return;
    final action = _redoStack.removeLast();
    _actionsHistory.add(action);

    setState(() {
      if (action.type == ActionType.addText && action.textData != null) {
        _overlayTexts.add(action.textData!);
      } else if (action.type == ActionType.addLogo &&
          action.imageData != null) {
        _overlayImages.add(action.imageData!);
      } else if (action.type == ActionType.draw && action.line != null) {
        _lines.add(action.line!);
      }
    });
  }

  bool _isInDeleteZone(Offset globalPosition) {
    final RenderBox? deleteZoneBox =
    _deleteZoneKey.currentContext?.findRenderObject() as RenderBox?;
    if (deleteZoneBox == null) return false;

    final deleteZonePosition = deleteZoneBox.localToGlobal(Offset.zero);
    final deleteZoneSize = deleteZoneBox.size;

    final expandedBounds = Rect.fromLTRB(
      deleteZonePosition.dx - 100.0,
      deleteZonePosition.dy - 40.0,
      deleteZonePosition.dx + deleteZoneSize.width + 90.0,
      deleteZonePosition.dy + deleteZoneSize.height + 200.0,
    );

    return expandedBounds.contains(globalPosition);
  }

  Widget _buildUserInfoFrame(FrameStyle style) {
    switch (style) {
    // Existing frames
      case FrameStyle.bottomCenter:
        return _buildClassicFrame();
      case FrameStyle.bottomRight:
        return _buildModernFrame();

    // Image-based frames
      case FrameStyle.imageWithPolaroid:
        return _buildImageWithPolaroidFrame();
      case FrameStyle.imageWithCircleFrame:
        return _buildImageWithCircleFrame();

    // Name-only frames
      case FrameStyle.bottomNameOnlySimple:
        return _buildNameOnlySimpleFrame();
      case FrameStyle.bottomNameOnlyMinimal:
        return _buildNameOnlyMinimalFrame();
        // Return a default frame instead of throwing error
        return _buildDefaultFrame();
    }
  }

// Add this default frame method
  Widget _buildDefaultFrame() {
    return Positioned(
      bottom: 15,
      left: 15,
      right: 15,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.7),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _userName,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              _phoneNumber,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ========== EXISTING FRAME METHODS ==========
  Widget _buildClassicFrame() {
    return Positioned(
      bottom: 15,
      left: 15,
      right: 15,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.3), width: 1.5),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 8),
                color: const Color(0xFFFF8C00),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (_userImage != null)
                      Container(
                        width: 24,
                        height: 24,
                        margin: const EdgeInsets.only(right: 8),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 1),
                        ),
                        child: ClipOval(
                          child: Image.file(
                            _userImage!,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    Text(
                      _userName.toUpperCase(),
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontWeight: FontWeight.w900, color: Colors.white, fontSize: 18),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Row(children: [
                      const Icon(Icons.phone, size: 14, color: Colors.white),
                      const SizedBox(width: 5),
                      Text(_phoneNumber, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ]),
                    Container(width: 1, height: 15, color: Colors.white30),
                    Row(children: [
                      const Icon(Icons.language, size: 14, color: Colors.white),
                      const SizedBox(width: 5),
                      Text(_website, style: const TextStyle(color: Colors.white, fontSize: 12)),
                    ]),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModernFrame() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [Colors.transparent, Color(0xFFFF8C00)],
                stops: [0.2, 1.0],
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (_userImage != null)
                  Container(
                    width: 28,
                    height: 28,
                    margin: const EdgeInsets.only(right: 8),
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.fromBorderSide(BorderSide(color: Colors.white, width: 1)),
                    ),
                    child: ClipOval(
                      child: Image.file(
                        _userImage!,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                Text(
                  _userName.toUpperCase(),
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: 1.2,
                    shadows: [Shadow(blurRadius: 2, color: Colors.black26, offset: Offset(1, 1))],
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(right: 20, bottom: 10, top: 5),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(_phoneNumber, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.black87)),
                    const SizedBox(width: 10),
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(color: Colors.black, shape: BoxShape.circle),
                      child: const Icon(Icons.phone_android, size: 14, color: Colors.white),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(_email, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.black87)),
                    const SizedBox(width: 10),
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(color: Colors.black, shape: BoxShape.circle),
                      child: const Icon(Icons.email, size: 14, color: Colors.white),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: const BoxDecoration(
              color: Color(0xFF006064),
            ),
            child: Text(
              _website,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

// ========== IMAGE-BASED FRAME METHODS ==========
  Widget _buildImageWithPolaroidFrame() {
    return Positioned(
      bottom: 20,
      left: 15,
      right: 15,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Polaroid style image
            if (_userImage != null)
              Container(
                height: 120,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  image: DecorationImage(
                    image: FileImage(_userImage!),
                    fit: BoxFit.cover,
                  ),
                  border: Border.all(color: Colors.grey.shade300, width: 2),
                ),
              ),
            const SizedBox(height: 10),
            // Caption area
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Text(
                    _userName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _email,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
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

  Widget _buildImageWithCircleFrame() {
    return Positioned(
      bottom: 20,
      left: 0,
      right: 0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.6),
              borderRadius: BorderRadius.circular(50),
              border: Border.all(color: Colors.amber, width: 2),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_userImage != null)
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 3),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.amber.withOpacity(0.5),
                          blurRadius: 10,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: Image.file(
                        _userImage!,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                const SizedBox(width: 15),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _userName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    Text(
                      _phoneNumber,
                      style: TextStyle(
                        color: Colors.amber.shade200,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

// ========== NAME-ONLY FRAME METHODS ==========
  Widget _buildNameOnlySimpleFrame() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(25),
          topRight: Radius.circular(25),
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withOpacity(0.2),
                  Colors.white.withOpacity(0.1),
                  Colors.white.withOpacity(0.05),
                ],
              ),
              border: Border(
                top: BorderSide(
                  color: Colors.white.withOpacity(0.5),
                  width: 1.5,
                ),
              ),
            ),
            child: Center(
              child: Text(
                _userName,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                  shadows: [
                    Shadow(
                      color: Colors.black26,
                      blurRadius: 8,
                      offset: Offset(1, 1),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNameOnlyMinimalFrame() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.red,
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [
              Colors.red.shade800,
              Colors.red.shade600,
              Colors.red.shade800,
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Center(
          child: Text(
            _userName.toUpperCase(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
              shadows: [
                Shadow(
                  color: Colors.black26,
                  blurRadius: 2,
                  offset: Offset(1, 1),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }


  void _showInstagramStyleTextEditor({
    _OverlayTextData? editingTextData,
    int? editingIndex,
  }) {
    final TextEditingController textController =
    TextEditingController(text: editingTextData?.text ?? '');

    Color selectedTextColor =
        editingTextData?.textColor ?? Colors.white;
    Color selectedBackgroundColor =
        editingTextData?.backgroundColor ?? Colors.transparent;
    FontWeight selectedFontWeight =
        editingTextData?.fontWeight ?? FontWeight.bold;
    FontStyle selectedFontStyle =
        editingTextData?.fontStyle ?? FontStyle.normal;
    double selectedFontSize =
        editingTextData?.fontSize ?? 38.0;

    bool isTextColorActive = true;

    double getBackgroundPadding() {
      return 6 + (selectedFontSize / 72 * 14);
    }

    Navigator.push(
      context,
      PageRouteBuilder(
        opaque: false,
        barrierColor: Colors.black.withOpacity(0.85),
        pageBuilder: (_, __, ___) {
          return StatefulBuilder(
            builder: (context, setState) {
              return Scaffold(
                backgroundColor: Colors.transparent,
                body: SafeArea(
                  child: Column(
                    children: [
                      Container(
                        margin: const EdgeInsets.all(8),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.35),
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(color: Colors.white24),
                        ),
                        child: Row(
                          mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                          children: [
                            GestureDetector(
                              onTap: () => Navigator.pop(context),
                              child: const Text(
                                'Cancel',
                                style: TextStyle(
                                    color: Colors.white70, fontSize: 13),
                              ),
                            ),
                            const Text(
                              'Text',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                if (textController.text.trim().isNotEmpty) {
                                  _handleTextSave(
                                    context,
                                    textController.text,
                                    selectedTextColor,
                                    selectedBackgroundColor,
                                    selectedFontStyle,
                                    selectedFontWeight,
                                    selectedFontSize,
                                    editingTextData: editingTextData,
                                    editingIndex: editingIndex,
                                  );
                                } else {
                                  Navigator.pop(context);
                                }
                              },
                              child: const Text(
                                'Done',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      Expanded(
                        child: Center(
                          child: Container(
                            padding: EdgeInsets.all(
                              selectedBackgroundColor != Colors.transparent
                                  ? getBackgroundPadding()
                                  : 0,
                            ),
                            decoration: BoxDecoration(
                              color: selectedBackgroundColor,
                              borderRadius: BorderRadius.circular(
                                selectedBackgroundColor != Colors.transparent
                                    ? 10
                                    : 0,
                              ),
                            ),
                            child: TextField(
                              controller: textController,
                              autofocus: true,
                              maxLines: null,
                              textAlign: TextAlign.center,
                              cursorColor: Colors.white,
                              style: TextStyle(
                                color: selectedTextColor,
                                fontSize: selectedFontSize,
                                fontWeight: selectedFontWeight,
                                fontStyle: selectedFontStyle,
                                height: 1.15,
                              ),
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                hintText: 'Type something...',
                                hintStyle: TextStyle(
                                  color: Colors.white38,
                                  fontSize: 22,
                                ),
                                isCollapsed: true,
                              ),
                            ),
                          ),
                        ),
                      ),

                      Container(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 4),
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.35),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.white24),
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                GestureDetector(
                                  onTap: () => setState(() {
                                    isTextColorActive = true;
                                  }),
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      color: isTextColorActive
                                          ? Colors.white.withOpacity(0.15)
                                          : Colors.transparent,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Icon(
                                      Icons.format_color_text,
                                      color: isTextColorActive
                                          ? Colors.white
                                          : Colors.white38,
                                      size: 22,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                GestureDetector(
                                  onTap: () => setState(() {
                                    isTextColorActive = false;
                                  }),
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      color: !isTextColorActive
                                          ? Colors.white.withOpacity(0.15)
                                          : Colors.transparent,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Icon(
                                      Icons.format_color_fill,
                                      color: !isTextColorActive
                                          ? Colors.white
                                          : Colors.white38,
                                      size: 22,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 8),

                            SizedBox(
                              height: 40,
                              child: ListView(
                                scrollDirection: Axis.horizontal,
                                children: [
                                  if (!isTextColorActive)
                                    _colorDotSmall(
                                      icon: Icons.clear,
                                      selected: selectedBackgroundColor ==
                                          Colors.transparent,
                                      onTap: () => setState(() {
                                        selectedBackgroundColor =
                                            Colors.transparent;
                                      }),
                                    ),
                                  ...[
                                    Colors.white,
                                    Colors.black,
                                    Colors.red,
                                    Colors.orange,
                                    Colors.yellow,
                                    Colors.green,
                                    Colors.blue,
                                    Colors.purple,
                                    Colors.pink,
                                    Colors.teal,
                                  ].map(
                                        (color) => _colorDotSmall(
                                      color: color,
                                      selected: isTextColorActive
                                          ? selectedTextColor == color
                                          : selectedBackgroundColor == color,
                                      onTap: () => setState(() {
                                        if (isTextColorActive) {
                                          selectedTextColor = color;
                                        } else {
                                          selectedBackgroundColor = color;
                                        }
                                      }),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          children: [
                            _fontBtnSmall(
                              'Normal',
                              selectedFontWeight == FontWeight.normal &&
                                  selectedFontStyle == FontStyle.normal,
                                  () => setState(() {
                                selectedFontWeight = FontWeight.normal;
                                selectedFontStyle = FontStyle.normal;
                              }),
                            ),
                            _fontBtnSmall(
                              'Bold',
                              selectedFontWeight == FontWeight.bold,
                                  () => setState(() {
                                selectedFontWeight = FontWeight.bold;
                                selectedFontStyle = FontStyle.normal;
                              }),
                            ),
                            _fontBtnSmall(
                              'Italic',
                              selectedFontStyle == FontStyle.italic,
                                  () => setState(() {
                                selectedFontStyle = FontStyle.italic;
                                selectedFontWeight = FontWeight.normal;
                              }),
                            ),
                          ],
                        ),
                      ),

                      Container(
                        margin: const EdgeInsets.all(12),
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.35),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.white24),
                        ),
                        child: Slider(
                          value: selectedFontSize,
                          min: 12,
                          max: 72,
                          divisions: 60,
                          onChanged: (v) =>
                              setState(() => selectedFontSize = v),
                          activeColor: Colors.white,
                          inactiveColor: Colors.white30,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _colorDotSmall({
    Color? color,
    IconData? icon,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
          border: Border.all(
            color: selected ? Colors.white : Colors.white38,
            width: selected ? 2.5 : 1.5,
          ),
        ),
        child: icon != null
            ? Icon(icon, color: Colors.white38, size: 16)
            : null,
      ),
    );
  }

  Widget _fontBtnSmall(String label, bool isSelected, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 3),
          padding: EdgeInsets.symmetric(vertical: 6),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? Colors.white : Colors.white24,
              width: 1,
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? Colors.black : Colors.white70,
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  void _handleTextSave(
      BuildContext context,
      String text,
      Color textColor,
      Color bgColor,
      FontStyle fontStyle,
      FontWeight fontWeight,
      double fontSize,
      {
        _OverlayTextData? editingTextData,
        int? editingIndex,
      }) {
    if (text.isEmpty) {
      Navigator.pop(context);
      return;
    }

    setState(() {
      if (editingTextData != null && editingIndex != null) {
        editingTextData.text = text;
        editingTextData.textColor = textColor;
        editingTextData.backgroundColor = bgColor;
        editingTextData.fontStyle = fontStyle;
        editingTextData.fontWeight = fontWeight;
        editingTextData.fontSize = fontSize;

        _actionsHistory.add(EditorAction.updateText(
          editingTextData,
          editingIndex,
        ));
      } else {
        final textData = _OverlayTextData(
          text: text,
          position: Offset(
            MediaQuery.of(context).size.width / 2 - 80,
            MediaQuery.of(context).size.height / 2 - 40,
          ),
          rotation: 0,
          fontSize: fontSize,
          textColor: textColor,
          backgroundColor: bgColor,
          fontStyle: fontStyle,
          fontWeight: fontWeight,
        );

        _overlayTexts.add(textData);
        _actionsHistory.add(EditorAction.addText(textData));
        _redoStack.clear();
      }
    });

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    // Calculate heights properly
    final double appBarHeight = 50.0;
    final double toolBarHeight = 100.0;
    final double verticalMargin = 16.0; // 8px top + 8px bottom for toolbar

    // Available height for image = total height - appBar - toolbar - margins
    final double availableHeight = screenHeight - appBarHeight - toolBarHeight - verticalMargin - 20; // 20px extra padding

    // Get image height based on selected aspect ratio, but limit to available height
    double imageHeight = _getImageHeight(screenWidth);

    // If image height is more than available height, reduce it to fit
    if (imageHeight > availableHeight) {
      imageHeight = availableHeight;
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        toolbarHeight: appBarHeight,
        elevation: 0,
        backgroundColor: Colors.transparent,
        centerTitle: true,
        title: const Text(
          'Edit',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87),
        ),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, size: 22, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          _editorAction(icon: Icons.undo_rounded, tooltip: 'Undo', onTap: _undo),
          _editorAction(icon: Icons.redo_rounded, tooltip: 'Redo', onTap: _redo),
          _editorAction(icon: Icons.share_rounded, tooltip: 'Share', onTap: () {
            setState(() => _showControls = false);
            _shareEditedImage();
          }),
          IconButton(
            constraints: const BoxConstraints(maxWidth: 40),
            icon: const CircleAvatar(
              radius: 12,
              backgroundColor: Colors.grey,
              child: Icon(Icons.person, size: 16, color: Colors.white),
            ),
            onPressed: () async {
              // Navigate to UserDetailScreen and wait for result
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => UserDetailScreen(
                    onSave: (userData) {
                      // This will be called when user saves data
                      _loadUserData(userData);
                    },
                  ),
                ),
              );

              // If user returned with data
              if (result != null && result is Map<String, dynamic>) {
                _loadUserData(result);
              }
            },
          ),
          const SizedBox(width: 8),
        ],
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(
              bottom: BorderSide(color: Colors.grey, width: 0.5),
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Image container with dynamic aspect ratio and swipe detection
            Expanded(
              child: Center(
                child: Container(
                  width: screenWidth,
                  height: imageHeight,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Add GestureDetector for swipe
                      GestureDetector(
                        onHorizontalDragEnd: _handleHorizontalSwipe,
                        child: Screenshot(
                          controller: _screenshotController,
                          child: GestureDetector(
                            onPanStart: _isDrawing
                                ? (details) {
                              setState(() {
                                _lines.add(DrawnLine([details.localPosition]));
                                _actionsHistory.add(EditorAction.draw(_lines.last));
                                _redoStack.clear();
                              });
                            }
                                : null,
                            onPanUpdate: _isDrawing
                                ? (details) {
                              setState(() {
                                _lines.last.pathPoints.add(details.localPosition);
                              });
                            }
                                : null,
                            onPanEnd: _isDrawing
                                ? (details) {
                              setState(() {
                                _isDrawing = false;
                              });
                            }
                                : null,
                            onPanCancel: _isDrawing
                                ? () {
                              setState(() {
                                _isDrawing = false;
                              });
                            }
                                : null,
                            child: Hero(
                              tag: widget.imageUrl,
                              child: Container(
                                width: screenWidth,
                                height: imageHeight,
                                color: Colors.transparent,
                                child: Stack(
                                  key: _imageContainerKey,
                                  children: [
                                    _selectedFilter == null
                                        ? Image.network(
                                      widget.imageUrl,
                                      fit: BoxFit.cover,
                                      width: screenWidth,
                                      height: imageHeight,
                                    )
                                        : _buildFilteredImage(),

                                    CustomPaint(
                                      painter: Sketcher(lines: _lines),
                                      size: Size.infinite,
                                    ),

                                    for (int i = 0; i < _overlayTexts.length; i++)
                                      _buildMovableText(_overlayTexts[i], i),

                                    for (int i = 0; i < _overlayImages.length; i++)
                                      _buildMovableLogo(_overlayImages[i], i),

                                    _buildWatermark(context),

                                    if (_selectedFrame != null)
                                      _buildUserInfoFrame(_selectedFrame!.style),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                      if (_showDeleteZone)
                        Positioned(
                          bottom: 70,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Container(
                                width: 90,
                                height: 90,
                                decoration: BoxDecoration(
                                  color: Colors.red.withOpacity(0.3),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              Container(
                                key: _deleteZoneKey,
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.red.withOpacity(0.7),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.delete, size: 50, color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),

            // Bottom editing tools - fixed height
            Container(
              height: toolBarHeight,
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.95),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.grey.withOpacity(0.3),
                      ),
                    ),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          const SizedBox(width: 8), // Left padding
                          _buildBigToolButton(
                            icon: Icons.text_fields_rounded,
                            label: 'Text',
                            onTap: _showInstagramStyleTextEditor,
                          ),
                          _buildBigToolButton(
                            icon: Icons.layers_rounded,
                            label: 'Overlay',
                            onTap: _pickLogo,
                          ),
                          _buildBigToolButton(
                            icon: Icons.brush_rounded,
                            label: _isDrawing ? 'Drawing' : 'Draw',
                            isActive: _isDrawing,
                            onTap: () {
                              setState(() {
                                _isDrawing = !_isDrawing;
                              });
                            },
                          ),
                          _buildBigToolButton(
                            icon: Icons.photo,
                            label: 'Frame',
                            onTap: _showFrameSelector,
                          ),
                          // Aspect Ratio Toggle Button
                          _buildBigToolButton(
                            icon: _currentAspectRatio == ImageAspectRatio.ratio9_16
                                ? Icons.crop_portrait
                                : Icons.crop_7_5,
                            label: _currentAspectRatio == ImageAspectRatio.ratio9_16 ? '9:16' : '4:5',
                            onTap: _toggleAspectRatio,
                            isActive: _currentAspectRatio == ImageAspectRatio.ratio4_5,
                          ),
                          const SizedBox(width: 8), // Right padding
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Swipe hint text
            if (_availableFrames.isNotEmpty && _showControls)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.swipe_left, size: 16, color: Colors.grey.shade400),
                    const SizedBox(width: 4),
                    Text(
                      'Swipe left/right to change frames',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade500,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(Icons.swipe_right, size: 16, color: Colors.grey.shade400),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  // Simple version of _buildBigToolButton - no changes needed in this
  Widget _buildBigToolButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isActive = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: isActive
                    ? const LinearGradient(
                  colors: [
                    Color(0xFFFF9A6A),
                    Color(0xFFE65100),
                  ],
                )
                    : null,
                color: isActive ? null : Colors.grey.shade200,
              ),
              child: Icon(
                icon,
                size: 26,
                color: isActive ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isActive ? Colors.deepOrange : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget _editorAction({
    required IconData icon,
    required String tooltip,
    required VoidCallback onTap,
  }) {
    return IconButton(
      onPressed: onTap,
      tooltip: tooltip,
      splashRadius: 22,
      icon: Icon(icon, color: Colors.black87),
    );
  }

  Widget _buildFilteredImage() {
    return ColorFiltered(
      colorFilter: _selectedFilter ??
          ColorFilter.mode(Colors.transparent, BlendMode.multiply),
      child: Image.network(
        widget.imageUrl,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
      ),
    );
  }

  Widget _buildMovableText(_OverlayTextData textData, int index) {
    double initialFontSize = textData.fontSize;
    Offset initialPosition = textData.position;

    return Positioned(
      left: textData.position.dx,
      top: textData.position.dy,
      child: GestureDetector(
        onTap: () {
          setState(() {
            final List<double> rotationAngles = [0,60, 90, 120,150, 180,200, 240,280, 300,320, 360];
            final double currentDeg = (textData.rotation * 180 /
                math.pi) % 360;

            int currentIndex = rotationAngles.indexWhere(
                    (angle) => (currentDeg - angle).abs() < 10
            );

            int nextIndex = currentIndex == -1 ? 0 : (currentIndex + 1) % rotationAngles.length;
            textData.rotation = rotationAngles[nextIndex] * math.pi / 180;
          });
        },
        onScaleStart: (details) {
          setState(() {
            _showDeleteZone = true;
            initialFontSize = textData.fontSize;
            initialPosition = textData.position;
          });
        },
        onScaleUpdate: (details) {
          setState(() {
            final double movementSensitivity = 1.0;

            if (details.pointerCount == 2) {
              textData.fontSize = (initialFontSize * details.scale).clamp(20, 100);
              textData.position = initialPosition + (details.focalPointDelta * movementSensitivity);
            } else if (details.pointerCount == 1) {
              textData.position = initialPosition + (details.focalPointDelta * movementSensitivity);
            }

            final RenderBox? imageBox = _imageContainerKey.currentContext?.findRenderObject() as RenderBox?;
            if (imageBox != null) {
              final containerPosition = imageBox.localToGlobal(Offset.zero);
              final textCenter = containerPosition + textData.position + Offset(0, textData.fontSize / 2);

              if (_isInDeleteZone(textCenter)) {
                textData.fontSize = 10;
              }
            }
          });
        },
        onScaleEnd: (_) {
          final RenderBox? imageBox = _imageContainerKey.currentContext?.findRenderObject() as RenderBox?;
          if (imageBox != null) {
            final containerPosition = imageBox.localToGlobal(Offset.zero);
            final textCenter = containerPosition + textData.position + Offset(0, textData.fontSize / 2);

            if (_isInDeleteZone(textCenter)) {
              setState(() {
                _overlayTexts.removeAt(index);
                _actionsHistory.add(EditorAction.removeText(textData));
              });
            }
          }
          setState(() => _showDeleteZone = false);
        },
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Transform.rotate(
              angle: textData.rotation,
              alignment: Alignment.center,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    padding: const EdgeInsets.all(40),
                    decoration: const BoxDecoration(
                      color: Colors.transparent,
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        color: textData.backgroundColor,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(8, 8, 20, 4),
                            child: Text(
                              textData.text,
                              style: TextStyle(
                                color: textData.textColor,
                                fontSize: textData.fontSize,
                                fontStyle: textData.fontStyle,
                                fontWeight: textData.fontWeight,
                                shadows: const [Shadow(blurRadius: 4, color: Colors.black45)],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  if (_showControls) ...[
                    Positioned(
                      top: 25,
                      left: 32,
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            final List<double> rotationAngles = [10, 50, 90, 120, 160, 210, 250, 300, 360];
                            final double currentDeg = (textData.rotation * 180 / math.pi) % 360;

                            int currentIndex = rotationAngles.indexWhere(
                                    (angle) => (currentDeg - angle).abs() < 10
                            );

                            int nextIndex = currentIndex == -1 ? 0 : (currentIndex + 1) % rotationAngles.length;
                            textData.rotation = rotationAngles[nextIndex] * math.pi / 180;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.rotate_right,
                            color: Colors.black,
                            size: 18,
                          ),
                        ),
                      ),
                    ),

                    Positioned(
                      top: 25,
                      right: 32,
                      child: GestureDetector(
                        onTap: () {
                          _showInstagramStyleTextEditor(
                            editingTextData: textData,
                            editingIndex: index,
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.blue,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.edit,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMovableLogo(_OverlayImageData data, int index) {
    double initialSize = data.size;
    Offset initialPosition = data.position;
    double _scaleFactor = 1.0;
    return Positioned(
      left: data.position.dx,
      top: data.position.dy,
      child: GestureDetector(
        onTap: () {
          setState(() {
            switch (data.shape) {
              case ImageShape.square:
                data.shape = ImageShape.roundedRectangle;
                break;
              case ImageShape.roundedRectangle:
                data.shape = ImageShape.circle;
                break;
              case ImageShape.circle:
                data.shape = ImageShape.square;
                break;
            }
          });
        },
        onScaleStart: (details) {
          setState(() {
            _showDeleteZone = true;
            initialSize = data.size;
            initialPosition = data.position;
            _scaleFactor = 1.0;
          });
        },
        onScaleUpdate: (details) {
          setState(() {
            if (details.pointerCount == 2) {
              double scaleChange = (details.scale - 1.0) * 0.3;
              _scaleFactor = 1.0 + scaleChange;
              data.size = (initialSize * _scaleFactor).clamp(50, 350);
            } else if (details.pointerCount == 1) {
              data.position +=
                  details.focalPointDelta;
            }
          });
        },
        onScaleEnd: (_) {
          final RenderBox? imageBox = _imageContainerKey.currentContext
              ?.findRenderObject() as RenderBox?;
          if (imageBox != null) {
            final containerPosition = imageBox.localToGlobal(Offset.zero);
            final center = containerPosition +
                data.position +
                Offset(data.size / 2, data.size / 2);

            if (_isInDeleteZone(center)) {
              setState(() {
                _overlayImages.removeAt(index);
                _actionsHistory.add(EditorAction.removeLogo(data));
              });
            }
          }
          setState(() => _showDeleteZone = false);
        },
        child: Container(
          padding: const EdgeInsets.all(30),
          decoration: BoxDecoration(
            color: Colors.transparent,
            shape: data.shape == ImageShape.circle
                ? BoxShape.circle
                : BoxShape.rectangle,
            borderRadius: data.shape == ImageShape.circle
                ? null
                : (data.shape == ImageShape.roundedRectangle
                ? BorderRadius.circular(20)
                : BorderRadius.zero),
          ),
          child: ClipRRect(
            borderRadius: data.shape == ImageShape.circle
                ? BorderRadius.circular(data.size / 2)
                : (data.shape == ImageShape.roundedRectangle
                ? BorderRadius.circular(20)
                : BorderRadius.zero),
            child: Image.file(
              data.file,
              width: data.size,
              height: data.size,
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
    );
  }
}

enum ImageShape { square, roundedRectangle, circle }

class _OverlayImageData {
  File file;
  Offset position;
  double size;
  ImageShape shape;

  _OverlayImageData({
    required this.file,
    required this.position,
    required this.size,
    this.shape = ImageShape.square,
  });
}

class _OverlayTextData {
  String text;
  Offset position;
  double fontSize;
  Color textColor;
  Color backgroundColor;
  FontStyle fontStyle;
  FontWeight fontWeight;
  double rotation;

  _OverlayTextData({
    required this.text,
    required this.position,
    required this.fontSize,
    required this.textColor,
    required this.backgroundColor,
    this.fontStyle = FontStyle.normal,
    this.fontWeight = FontWeight.normal,
    this.rotation = 0.0,
  });
}

class DrawnLine {
  List<Offset> pathPoints;
  DrawnLine(this.pathPoints);
}

class Sketcher extends CustomPainter {
  final List<DrawnLine> lines;
  Sketcher({required this.lines});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..strokeWidth = 4.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    for (var line in lines) {
      for (int i = 0; i < line.pathPoints.length - 1; i++) {
        canvas.drawLine(line.pathPoints[i], line.pathPoints[i + 1], paint);
      }
    }
  }

  @override
  bool shouldRepaint(Sketcher oldDelegate) => true;
}

enum ActionType { addText, addLogo, draw, removeText, removeLogo, updateText, updateLogo }

class EditorAction {
  final ActionType type;
  final _OverlayTextData? textData;
  final _OverlayImageData? imageData;
  final DrawnLine? line;
  final int? index;

  EditorAction.addText(this.textData)
      : type = ActionType.addText,
        imageData = null,
        line = null,
        index = null;

  EditorAction.removeText(this.textData)
      : type = ActionType.removeText,
        imageData = null,
        line = null,
        index = null;

  EditorAction.updateText(this.textData, this.index)
      : type = ActionType.updateText,
        imageData = null,
        line = null;

  EditorAction.addLogo(this.imageData)
      : type = ActionType.addLogo,
        textData = null,
        line = null,
        index = null;

  EditorAction.removeLogo(this.imageData)
      : type = ActionType.removeLogo,
        textData = null,
        line = null,
        index = null;

  EditorAction.updateLogo(this.imageData, this.index)
      : type = ActionType.updateLogo,
        textData = null,
        line = null;

  EditorAction.draw(this.line)
      : type = ActionType.draw,
        textData = null,
        imageData = null,
        index = null;
}

// Custom clippers for shapes
class HexagonClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    final width = size.width;
    final height = size.height;

    path.moveTo(width * 0.25, 0);
    path.lineTo(width * 0.75, 0);
    path.lineTo(width, height * 0.4);
    path.lineTo(width * 0.75, height);
    path.lineTo(width * 0.25, height);
    path.lineTo(0, height * 0.4);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class DiamondClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    final width = size.width;
    final height = size.height;

    path.moveTo(width / 2, 0);
    path.lineTo(width, height / 2);
    path.lineTo(width / 2, height);
    path.lineTo(0, height / 2);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class HeartClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    final width = size.width;
    final height = size.height;

    path.moveTo(width / 2, height * 0.25);
    path.cubicTo(
      width * 0.3, 0,
      0, height * 0.3,
      width / 2, height,
    );
    path.cubicTo(
      width, height * 0.3,
      width * 0.7, 0,
      width / 2, height * 0.25,
    );
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class StarClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    final width = size.width;
    final height = size.height;

    final points = 5;
    final outerRadius = width / 2;
    final innerRadius = width / 4;
    final angle = (math.pi * 2) / points;

    for (int i = 0; i < points; i++) {
      final outerX = width / 2 + outerRadius * math.cos(angle * i - math.pi / 2);
      final outerY = height / 2 + outerRadius * math.sin(angle * i - math.pi / 2);

      if (i == 0) {
        path.moveTo(outerX, outerY);
      } else {
        path.lineTo(outerX, outerY);
      }

      final innerX = width / 2 + innerRadius * math.cos(angle * (i + 0.5) - math.pi / 2);
      final innerY = height / 2 + innerRadius * math.sin(angle * (i + 0.5) - math.pi / 2);
      path.lineTo(innerX, innerY);
    }

    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}



// -------------------------
// DRAWING ACTION
// -------------------------

//import 'dart:async';
//   import 'dart:convert';
//
//   import 'package:flutter/cupertino.dart';
//   import 'package:flutter/material.dart';
//   import 'package:flutter/services.dart';
//   import 'package:mahakal/features/Jaap/screen/history.dart';
//   import 'package:geocoding/geocoding.dart';
// // import 'package:flutter_vibrate/flutter_vibrate.dart';
// // import 'package:just_audio/just_audio.dart';
//   import 'package:http/http.dart' as http;
//   import 'package:intl/intl.dart';
//   import 'package:mahakal/features/Jaap/screen/wallpaper.dart';
//   import 'package:provider/provider.dart';
//   import 'package:signature/signature.dart';
//   import 'package:tdk_bouncingwidget/tdk_bouncingwidget.dart';
//
//   import '../../../main.dart';
//   import '../../../utill/app_constants.dart';
//   import '../../auth/controllers/auth_controller.dart';
//   import '../jap_database.dart';
//
//   class JaapView extends StatefulWidget {
//   int initialIndex;
//   JaapView({super.key, this.initialIndex = 0});
//
//   @override
//   State<JaapView> createState() => _JaapViewState();
//   }
//
//   class Person {
//   String id;
//   String name;
//   Person({required this.id, required this.name});
//   }
//
//   class _JaapViewState extends State<JaapView> with TickerProviderStateMixin {
//   //----------------------JAAP TAB STARTS----------------------------
//
//   // Custom mantra variables
//   TextEditingController _customMantraController = TextEditingController();
//   TextEditingController _customMantraNameController = TextEditingController();
//
//   // Sankalp variables
//   bool _showSankalpDialog = false;
//   DateTime? _startDate;
//   DateTime? _endDate;
//   TimeOfDay? _selectedTime;
//   int _targetCount = 108;
//   Duration? _duration;
//   bool _hasSankalp = false;
//
//
//   final Iterable<Duration> pauses = [
//   const Duration(milliseconds: 500),
//   const Duration(milliseconds: 1000),
//   const Duration(milliseconds: 500),
//   ];
//
//   // our jaap app tab controller
//   late TabController _tabController;
//   int tabIndex = 0;
//
//   List<dynamic> myList = [];
//
//   // jaap app background image
//   final String _selectedImage = 'assets/images/jaap/ram_3.png';
//
//   bool _vibrationEnabled = true; // Default vibration state is on
//
//   // setting bottom sheet 3 circle in row
//   int itemColorIndex = 0;
//   void _showsettingsheet() {
//   showModalBottomSheet(
//   context: context,
//   builder: (BuildContext context) {
//   return SizedBox(
//   height: 185,
//   child: ListView(
//   children: [
//   ListTile(
//   title: Row(
//   mainAxisAlignment: MainAxisAlignment.start,
//   children: [
//   Switch(
//   value: _vibrationEnabled,
//   onChanged: (value) {
//   setState(() {
//   Navigator.pop(context);
//   _vibrationEnabled = value;
//   });
//   },
//   activeColor: Colors.orangeAccent,
//   inactiveTrackColor: Colors.white30,
//   ),
//   const SizedBox(width: 7),
//   Text(
//   _vibrationEnabled ? 'Vibration On' : 'Vibration Off',
//   style: const TextStyle(
//   color: Colors.orange, fontWeight: FontWeight.bold),
//   ),
//   ],
//   ),
//   ),
//   // ListTile(
//   //   title: Row(
//   //     mainAxisAlignment: MainAxisAlignment.start,
//   //     children: [
//   //       Switch(
//   //         value: _vibrationEnabled,
//   //         onChanged: (value) {
//   //           setState(() {
//   //             Navigator.pop(context);
//   //             _vibrationEnabled = value;
//   //           });
//   //         },
//   //       ),
//   //       SizedBox(width: 7),
//   //       Text(_vibrationEnabled ? 'Sound On' : 'Sound Off',style: TextStyle(color: Colors.deepPurple),),
//   //     ],
//   //   ),
//   // ),
//   ListTile(
//   title: Padding(
//   padding: const EdgeInsets.only(top: 6),
//   child: Row(
//   children: [
//   Container(
//   width: 50,
//   height: 50,
//   decoration: BoxDecoration(
//   border: Border.all(color: Colors.orange, width: 1.5),
//   color: Colors.white.withOpacity(0.2),
//   borderRadius: BorderRadius.circular(300),
//   ),
//   child: const Center(
//   child: Icon(
//   Icons.edit,
//   size: 30,
//   ),
//   ),
//   ),
//   const SizedBox(width: 15),
//   const Text(
//   "Background",
//   style: TextStyle(
//   fontSize: 20, fontWeight: FontWeight.w500),
//   ),
//   const SizedBox(width: 20),
//   Container(
//   width: 50,
//   height: 50,
//   decoration: BoxDecoration(
//   border: Border.all(color: Colors.orange, width: 1.5),
//   color: Colors.white.withOpacity(0.2),
//   borderRadius: BorderRadius.circular(300),
//   ),
//   child: const Center(
//   child: Icon(
//   Icons.history,
//   size: 30,
//   ),
//   ),
//   ),
//   const SizedBox(width: 15),
//   TextButton(
//   onPressed: () {
//   setState(() {
//   _tabController.animateTo(2);
//   });
//   Navigator.pop(context);
//   },
//   child: const Text(
//   "History",
//   style: TextStyle(
//   fontSize: 20,
//   fontWeight: FontWeight.w500,
//   color: Colors.black),
//   ),
//   ),
//   ],
//   ),
//   ),
//   onTap: () {
//   Navigator.pop(context);
//   },
//   ),
//   Padding(
//   padding: const EdgeInsets.only(
//   left: 20,
//   ),
//   child: Row(
//   children: [
//   InkWell(
//   onTap: () {
//   setState(() {
//   itemColorIndex = 0;
//   Navigator.pop(context);
//   });
//   },
//   child: ClipOval(
//   child: Image.asset(
//   'assets/images/jaap/ram_3.png',
//   width: 45, // Set the desired width
//   height: 45, // Set the desired height
//   fit: BoxFit
//       .cover, // Ensures the image fits within the circle
//   ),
//   ),
//   ),
//   const SizedBox(width: 10),
//   InkWell(
//   onTap: () {
//   setState(() {
//   itemColorIndex = 1;
//   Navigator.pop(context);
//   });
//   },
//   child: ClipOval(
//   child: Image.asset(
//   'assets/images/jaap/ram_4.png',
//   width: 45, // Set the desired width
//   height: 45, // Set the desired height
//   fit: BoxFit
//       .cover, // Ensures the image fits within the circle
//   ),
//   ),
//   ),
//   const SizedBox(width: 10),
//   InkWell(
//   onTap: () {
//   setState(() {
//   itemColorIndex = 2;
//   Navigator.pop(context);
//   });
//   },
//   child: ClipOval(
//   child: Image.asset(
//   'assets/images/jaap/ram_5.png',
//   width: 45, // Set the desired width
//   height: 45, // Set the desired height
//   fit: BoxFit
//       .cover, // Ensures the image fits within the circle
//   ),
//   ),
//   ),
//   ],
//   ),
//   ),
//   // SizedBox(height: 10),
//   // ListTile(
//   //   title: Row(
//   //     children: [
//   //       Container(
//   //         child: Center(
//   //           child: Icon(
//   //             Icons.history,
//   //             size: 30,
//   //           ),
//   //         ),
//   //         width: 50,
//   //         height: 50,
//   //         decoration: BoxDecoration(
//   //           border: Border.all(color: Colors.orange, width: 1.5),
//   //           color: Colors.white.withOpacity(0.2),
//   //           borderRadius: BorderRadius.circular(300),
//   //         ),
//   //       ),
//   //       SizedBox(width: 15),
//   //       Text(
//   //         "History",
//   //         style:
//   //             TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
//   //       ),
//   //     ],
//   //   ),
//   //   onTap: () {
//   //     setState(() {
//   //       _tabController.animateTo(2);
//   //     });
//   //     Navigator.pop(context);
//   //   },
//   // ),
//   ],
//   ),
//   );
//   },
//   );
//   }
//
//   // jaap page mantra list
//   String _selectedItem = '';
//   List<Person> people = [
//   Person(id: 'राम! राम! राम! राम', name: 'Ram Naam Jaap(राम नाम जाप)'),
//   Person(id: 'ॐ नमः शिवाय', name: 'Shiv Jaap(शिव जाप)'),
//   Person(
//   id: 'हरे कृष्ण हरे कृष्ण, कृष्ण कृष्ण हरे हरे। हरे राम हरे रामा, राम रामा हरे हरे॥',
//   name: 'Krishna Jaap(कृष्ण जाप)'),
//   Person(id: '!!ॐ गं गणपतये नमः!!', name: 'Ganesh Jaap(गणेश जाप)'),
//   Person(
//   id: 'ॐ भूर्भुवः स्वः तत्सवितुर्वरेण्यं भर्गो दैवस्य धीमहि। धियो यो नः प्रचोदयात्॥',
//   name: 'Gayatri Mantra Jaap(गायत्री मंत्र जाप)'),
//   Person(
//   id: '!!ओम नमः भगवते वासुदेवाय नमः!!',
//   name: 'Vishnu Mantra Jaap(विष्णु मंत्र जाप)'),
//   Person(id: '!!श्री राम जय राम जय जय राम!!', name: 'Ram Jaap(राम जाप)'),
//   Person(
//   id: 'ॐ सर्वमङ्गलमाङ्गल्ये शिवे सर्वार्थसाधिके। शरण्ये त्र्यंबके गौरी नारायणि नमोऽस्तुते॥',
//   name: 'Durga Jaap(दुर्गा जाप)'),
//   Person(id: 'ॐ नमो नारायणाय!!', name: 'Vishnu Jaap(विष्णु जाप)'),
//   Person(
//   id: 'ॐ श्रीं महा लक्ष्मीयै नमः!!',
//   name: 'Laxmi Mantra Jaap(लक्ष्मी मंत्र जाप)'),
//   Person(
//   id: 'ॐ हौं जूं सः ॐ भूर्भुवः स्वः ॐ त्र्यम्बकं यजामहे सुगन्धिं पुष्टिवर्धनम् उर्वारुकमिव बन्धनान्मृ त्योर्मुक्षीय मामृतात् ॐ स्वः भुवः भूः ॐ सः जूं हौं ॐ।',
//   name: 'Mahamrityunjay Jaap(महामृत्युंजय जाप)'),
//   ];
//   double getFontSize(String name, num screenwidth) {
//   double fontSizeRatio;
//
//   switch (name) {
//   case 'Ram Naam Jaap(राम नाम जाप)':
//   fontSizeRatio = 0.10;
//   break;
//   case 'Shiv Jaap(शिव जाप)':
//   fontSizeRatio = 0.12;
//   break;
//   case 'Krishna Jaap(कृष्ण जाप)':
//   fontSizeRatio = 0.07;
//   break;
//   case 'Ganesh Jaap(गणेश जाप)':
//   fontSizeRatio = 0.1;
//   break;
//   case 'Gayatri Mantra Jaap(गायत्री मंत्र जाप)':
//   fontSizeRatio = 0.05;
//   break;
//   case 'Vishnu Mantra Jaap(विष्णु मंत्र जाप)':
//   fontSizeRatio = 0.07;
//   break;
//   case 'Ram Jaap(राम जाप)':
//   fontSizeRatio = 0.07;
//   break;
//   case 'Durga Jaap(दुर्गा जाप)':
//   fontSizeRatio = 0.05;
//   break;
//   case 'Vishnu Jaap(विष्णु जाप)':
//   fontSizeRatio = 0.09;
//   break;
//   case 'Laxmi Mantra Jaap(लक्ष्मी मंत्र जाप)':
//   fontSizeRatio = 0.08;
//   break;
//   case 'Mahamrityunjay Jaap(महामृत्युंजय जाप)':
//   fontSizeRatio = 0.05;
//   break;
//   default:
//   fontSizeRatio = 0.08;
//   }
//   return fontSizeRatio * screenwidth;
//   }
//
//   // jaap count animation
//   late AnimationController _animationController;
//   late Animation<double> _animation;
//
//   // jaap page loop count
//   int _loopCounter = 0;
//   // jaap page main big circle count
//   int _tapCounter = 0;
//   // jaap page score count
//   int product = 0;
//   // jaap page loop count from list 11,20,30
//   int _tapsPerLoop = 11;
//   // Track previous loop counter to detect completion
//   int _previousLoopCounter = 0;
//
//
//   void _onButtonTap() {
//   setState(() {
//   _tapCounter++;
//
//   // Check if a loop is completed
//   if (_tapCounter > _tapsPerLoop) {
//   _loopCounter++;
//   _tapCounter = 1;
//
//   // Trigger vibration when a mala is completed
//   _triggerMalaCompletionVibration();
//   }
//
//   product++;
//   });
//   _animationController.forward(from: 0.0);
//   Future.delayed(const Duration(milliseconds: 200), () {
//   _animationController.reverse();
//   });
//   }
//
//   // Method to trigger vibration on mala completion
//   void _triggerMalaCompletionVibration() {
//   if (_vibrationEnabled) {
//   // You can customize the vibration pattern here
//   // For a more distinct vibration pattern for mala completion
//   HapticFeedback.heavyImpact();
//
//   // Optional: Add a longer vibration pattern for mala completion
//   Future.delayed(const Duration(milliseconds: 100), () {
//   HapticFeedback.mediumImpact();
//   });
//
//   // Optional: Show a subtle visual feedback or snackbar
//   _showMalaCompletionMessage();
//   }
//   }
//
//   // Optional: Show a message when mala is completed
//   void _showMalaCompletionMessage() {
//   ScaffoldMessenger.of(context).showSnackBar(
//   SnackBar(
//   content: Text(
//   '🙏 माला ${_loopCounter} पूर्ण! 🙏',
//   textAlign: TextAlign.center,
//   style: const TextStyle(
//   fontWeight: FontWeight.bold,
//   fontSize: 16,
//   ),
//   ),
//   backgroundColor: Colors.green,
//   duration: const Duration(seconds: 2),
//   behavior: SnackBarBehavior.floating,
//   margin: const EdgeInsets.all(10),
//   ),
//   );
//   }
//
//   void _showBottomSheets() {
//   showModalBottomSheet(
//   context: context,
//   builder: (BuildContext context) {
//   return SizedBox(
//   height: 220,
//   child: ListView(
//   children: [
//   ListTile(
//   title: const Text('11', textAlign: TextAlign.center),
//   onTap: () {
//   setState(() {
//   _tapsPerLoop = 11;
//   });
//   Navigator.pop(context);
//   },
//   ),
//   ListTile(
//   title: const Text('21', textAlign: TextAlign.center),
//   onTap: () {
//   setState(() {
//   _tapsPerLoop = 21;
//   });
//   Navigator.pop(context);
//   },
//   ),
//   ListTile(
//   title: const Text('51', textAlign: TextAlign.center),
//   onTap: () {
//   setState(() {
//   _tapsPerLoop = 51;
//   });
//   Navigator.pop(context);
//   },
//   ),
//   ListTile(
//   title: const Text('101', textAlign: TextAlign.center),
//   onTap: () {
//   setState(() {
//   _tapsPerLoop = 101;
//   });
//   Navigator.pop(context);
//   },
//   ),
//   ListTile(
//   title: const Text('108', textAlign: TextAlign.center),
//   onTap: () {
//   setState(() {
//   _tapsPerLoop = 108;
//   });
//   Navigator.pop(context);
//   },
//   ),
//   ListTile(
//   title: const Text('1008', textAlign: TextAlign.center),
//   onTap: () {
//   setState(() {
//   _tapsPerLoop = 1008;
//   });
//   Navigator.pop(context);
//   },
//   ),
//   const SizedBox(height: 10),
//   ],
//   ),
//   );
//   },
//   );
//   }
//
//   // jaap total count saved and pass to score page
//   final List<int> _savedCounts = [];
//
//   void _submitCount() {
//   setState(() {
//   _selectedItem;
//   _savedCounts.add(product);
//   });
//   }
//
//   int _counter = 0;
//   void _incrementCounter() {
//   setState(() {
//   _counter++;
//   });
//   }
//   //----------------------JAAP TAB ENDS----------------------------
//
//   //----------------------RAM LEKHAN TAB STARTS----------------------------
//
//   final ScrollController _scrollController = ScrollController();
//
//   // ram lekhan signature pen decoration
//   final controllers = SignatureController(
//   penColor: Colors.orange,
//   penStrokeWidth: 3,
//   exportPenColor: Colors.orange,
//   exportBackgroundColor: Colors.white,
//   );
//
//   // ram lekhan signature saved here
//   List<Uint8List> signatures = [];
//
//   // ram lekhan ram word saved here
//   final List<Widget> _texts = [];
//   void _addText() {
//   setState(() {
//   _texts.add(Container(
//   decoration: BoxDecoration(
//   border: Border(
//   right: BorderSide(
//   color: Colors.amber.shade200,
//   width: 1.0,
//   ),
//   left: BorderSide(
//   color: Colors.amber.shade200,
//   width: 1.0,
//   ),
//   bottom: BorderSide(
//   color: Colors.amber.shade200,
//   width: 1.0,
//   ),
//   ),
//   ),
//   child: const Padding(
//   padding: EdgeInsets.only(right: 11, left: 11, top: 15, bottom: 15),
//   child: Text(
//   'राम',
//   style: TextStyle(fontSize: 23.7, color: Colors.orange, height: 1),
//   ),
//   ),
//   ));
//   });
//   }
//
//   // ram lekhan keyboard word saved here
//   final List<String> _textstype = [];
//
//   // // ram lekhan Variable to toggle keyboard visibility
//   // bool _showKeyboard = true;
//   // void _toggleKeyboard() {
//   //   setState(() {
//   //     _showKeyboard = !_showKeyboard; // Toggle the keyboard visibility
//   //   });
//   // }
//
//   // ram lekhan Controller for the text field keyboard TextEditingController
//   final TextEditingController _textController = TextEditingController();
//   // String _inputText = ''; // Variable to store the text input
//   // void _updateText(String text) {
//   //   setState(() {
//   //     _inputText = text; // Update the displayed text
//   //     _textstype.add(_textController.text);
//   //   });
//   // }
//
//   // ram lekhan Variable to toggle signature pad visibility
//   bool _isSignatureVisible = false;
//
//   // ram lekhan total count start
//   int _buttonPressCount = 0;
//   int _buttonPressCounts = 0;
//   int _totalPressCount = 0;
//   final int _currentIndex = 0;
//
//   void _incrementButtonPressCount() {
//   setState(() {
//   _buttonPressCount++;
//   _totalPressCount = _buttonPressCount + _buttonPressCounts;
//   });
//   }
//
//   void _incrementButtonPressCounts() {
//   setState(() {
//   _buttonPressCounts++;
//   _totalPressCount = _buttonPressCount + _buttonPressCounts;
//   });
//   }
//   // ram lekhan total count End
//
//   //----------------------RAM LEKHAN TAB STARTS----------------------------
//
//   final List<dynamic> _pressCounts = [];
//
//   String _currentTime = '';
//   String userToken = '';
//   String totalDuration = '';
//   String totalDurationRam = '';
//   Timer? _timer;
//   DateTime? _startTime;
//   Duration _elapsedTime = Duration.zero;
//   double latiTude = 0.0;
//   double longiTude = 0.0;
//   String _venueAddressController = '';
//
//   List<Map<String, dynamic>> savedData = [];
//
//   void _startTimer() {
//   // Check if the timer is already running
//   if (_timer != null && _timer!.isActive) {
//   return; // Do nothing if the timer is already running
//   }
//
//   // Set the start time and reset the elapsed time
//   setState(() {
//   _startTime = DateTime.now();
//   _elapsedTime = Duration.zero;
//   });
//
//   // Start a new timer
//   _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
//   setState(() {
//   _elapsedTime = DateTime.now().difference(_startTime!);
//   });
//   });
//   }
//
//   // Stop timer and calculate total duration
//   void _stopTimer() {
//   if (_timer != null) {
//   // _elapsedTime = _elapsedTime.toString();
//   _timer!.cancel();
//   setState(() {
//   _timer = null;
//   totalDuration = "${_elapsedTime.inSeconds}s";
//   totalDurationRam = "${_elapsedTime.inSeconds}s";
//   _elapsedTime = Duration.zero;
//   });
//   print("Total Duration: $_elapsedTime $totalDuration");
//   }
//   }
//
//   void _incrementNumber() {
//   setState(() {
//   itemColorIndex =
//   (itemColorIndex + 1) % 3; // Increment and reset to 0 after 3
//   });
//   }
//
//   void _showCurrentTime() {
//   final now = DateTime.now();
//   String hour;
//   if (now.hour > 12) {
//   hour = (now.hour - 12).toString();
//   } else if (now.hour == 0) {
//   hour = '12';
//   } else {
//   hour = now.hour.toString();
//   }
//   // String ampm = now.hour > 11 ? 'PM' : 'AM'
//   // $ampm
//   final formattedTime =
//   '$hour:${now.minute.toString().padLeft(2, '0')} , ${now.day} ${_getMonth(now.month)} ${now.year.toString().substring(2)} ';
//   setState(() {
//   _currentTime = formattedTime;
//   });
//   }
//
//   String _getMonth(int month) {
//   switch (month) {
//   case 1:
//   return 'Jan';
//   case 2:
//   return 'Feb';
//   case 3:
//   return 'Mar';
//   case 4:
//   return 'Apr';
//   case 5:
//   return 'May';
//   case 6:
//   return 'Jun';
//   case 7:
//   return 'Jul';
//   case 8:
//   return 'Aug';
//   case 9:
//   return 'Sep';
//   case 10:
//   return 'Oct';
//   case 11:
//   return 'Nov';
//   case 12:
//   return 'Dec';
//   default:
//   return '';
//   }
//   }
//
//   String extractEnglishName(String input) {
//   // Use regex to match the first part before the opening bracket.
//   RegExp exp = RegExp(r'^[^(]+');
//   Match? match = exp.firstMatch(input);
//
//   if (match != null) {
//   // Trim the result to remove any extra whitespace.
//   return match.group(0)!.trim();
//   } else {
//   // Return the original input if no match is found (in case there is no bracket).
//   return input;
//   }
//   }
//
//   void getLocation(double lat, long) async {
//   List<Placemark> placemarks = await placemarkFromCoordinates(
//   lat,
//   long!,
//   );
//
//   if (placemarks.isNotEmpty) {
//   Placemark place = placemarks.first;
//   // _pincodeController.text = place.postalCode!;
//   // _stateController.text = place.administrativeArea!;
//   // _landMarkController.text = place.street!;
//   _venueAddressController = place.locality!;
//   print("venue store $_venueAddressController ${place.locality}");
//   }
//   }
//
//   Future<void> countSave(String totalCount) async {
//   String name = extractEnglishName(_selectedItem);
//   DateTime now = DateTime.now();
//   String formattedTime = DateFormat('hh:mm:ss').format(now);
//   String formattedDate = DateFormat('dd/MM/yyy').format(now);
//   final response = await http.post(
//   Uri.parse(AppConstants.baseUrl + AppConstants.saveJapCountUrl),
//   headers: {
//   'Authorization': 'Bearer $userToken',
//   'Content-Type': 'application/json',
//   },
//   body: jsonEncode({
//   "type": "mantra",
//   "name": name,
//   "location": _venueAddressController,
//   "count": totalCount,
//   "duration": totalDuration,
//   "date": formattedDate,
//   "time": formattedTime
//   }),
//   );
//   print("jaap post api: ${response.body}");
//   var data = jsonDecode(response.body);
//   if (data["status"] == 200) {
//   _submitCount();
//   setState(() {
//   tabIndex = 0;
//   _tapCounter = 0;
//   _loopCounter = 0;
//   product = 0;
//   _tabController.animateTo(2);
//   _tabController.index = 2;
//   });
//   } else {
//   print("failed api status 400");
//   }
//   }
//
//   Future<void> ramLekhanSave(String totalCountRam) async {
//   DateTime now = DateTime.now();
//   String formattedTime = DateFormat('hh:mm:ss').format(now);
//   String formattedDate = DateFormat('dd/MM/yyy').format(now);
//   final response = await http.post(
//   Uri.parse(AppConstants.baseUrl + AppConstants.saveRamLekhanUrl),
//   headers: {
//   'Authorization': 'Bearer $userToken',
//   'Content-Type': 'application/json',
//   },
//   body: jsonEncode({
//   "type": "ram_lekhan",
//   "name": "ram",
//   "location": _venueAddressController,
//   "count": totalCountRam,
//   "duration": totalDurationRam,
//   "date": formattedDate,
//   "time": formattedTime
//   }),
//   );
//   print("ram lekhan post api: ${response.body}");
//   var data = jsonDecode(response.body);
//   if (data["status"] == 200) {
//   setState(() {
//   tabIndex = 1;
//   _pressCounts.add(_totalPressCount);
//   _totalPressCount = 0;
//   _texts.clear();
//   signatures.clear();
//   _buttonPressCount = 0;
//   _buttonPressCounts = 0;
//   _totalPressCount = 0;
//   _textController.clear();
//   _textstype.clear();
//   _tabController.animateTo(2);
//   _tabController.index = 2;
//   });
//   } else {
//   print("failed api status 400");
//   }
//   }
//
//   @override
//   void initState() {
//   super.initState();
//   _checkPreviousData();
//   userToken =
//   Provider.of<AuthController>(Get.context!, listen: false).getUserToken();
//   latiTude =
//   Provider.of<AuthController>(Get.context!, listen: false).latitude;
//   longiTude =
//   Provider.of<AuthController>(Get.context!, listen: false).longitude;
//   _tabController = TabController(
//   length: 3, vsync: this, initialIndex: widget.initialIndex);
//   _isSignatureVisible = false; // Initialize with true
//   _animationController = AnimationController(
//   duration: const Duration(milliseconds: 500),
//   vsync: this,
//   );
//   _animation = Tween<double>(begin: 1, end: 1.2).animate(_animationController)
//   ..addListener(() {
//   setState(() {});
//   })
//   ..addStatusListener((status) {
//   if (status == AnimationStatus.completed) {
//   _animationController.reverse();
//   }
//   });
//   getLocation(latiTude, longiTude);
//   }
//
//   Future<void> _checkPreviousData() async {
//   savedData = await DBHelper.instance.getData();
//   if (savedData.isNotEmpty) {
//   WidgetsBinding.instance.addPostFrameCallback((_) {
//   _showResumeDialog();
//   });
//   }
//   }
//
//   void _showResumeDialog() {
//   showDialog(
//   context: context,
//   barrierDismissible: false,
//   builder: (_) {
//   return Dialog(
//   backgroundColor: Colors.transparent,
//   insetAnimationDuration: const Duration(milliseconds: 300),
//   insetAnimationCurve: Curves.easeOutQuart,
//   child: Container(
//   padding: const EdgeInsets.all(24),
//   decoration: BoxDecoration(
//   color: Theme.of(context).colorScheme.surface,
//   borderRadius: BorderRadius.circular(20),
//   boxShadow: [
//   BoxShadow(
//   color: Colors.black.withOpacity(0.2),
//   blurRadius: 20,
//   spreadRadius: 2,
//   )
//   ],
//   ),
//   child: Column(
//   mainAxisSize: MainAxisSize.min,
//   children: [
//   Icon(
//   Icons.history_rounded,
//   size: 48,
//   color: Theme.of(context).colorScheme.primary,
//   ),
//   const SizedBox(height: 16),
//   Text(
//   "Resume or Restart?",
//   style: Theme.of(context).textTheme.headlineSmall?.copyWith(
//   fontWeight: FontWeight.bold,
//   color: Theme.of(context).colorScheme.onSurface,
//   ),
//   ),
//   const SizedBox(height: 12),
//   Text(
//   "You have saved data. Do you want to continue or reset?",
//   textAlign: TextAlign.center,
//   style: Theme.of(context).textTheme.bodyMedium?.copyWith(
//   color: Theme.of(context)
//       .colorScheme
//       .onSurface
//       .withOpacity(0.8),
//   ),
//   ),
//   const SizedBox(height: 24),
//   Row(
//   mainAxisAlignment: MainAxisAlignment.spaceAround,
//   children: [
//   Expanded(
//   child: OutlinedButton(
//   onPressed: () async {
//   await DBHelper.instance.updateData(
//   savedData[0]['id'],
//   savedData[0]['str1'],
//   savedData[0]['str2'],
//   savedData[0]['str3'],
//   savedData[0]['str4'],
//   );
//   Navigator.pop(context);
//   setState(() {
//   _selectedItem = savedData[0]['str1'];
//   _tapsPerLoop = int.parse(savedData[0]['str2']);
//   _loopCounter = int.parse(savedData[0]['str3']);
//   _tapCounter = int.parse(savedData[0]['str4']);
//   });
//   },
//   style: OutlinedButton.styleFrom(
//   padding: const EdgeInsets.symmetric(vertical: 16),
//   shape: RoundedRectangleBorder(
//   borderRadius: BorderRadius.circular(12),
//   ),
//   side: BorderSide(
//   color: Theme.of(context).colorScheme.primary,
//   ),
//   ),
//   child: Text(
//   "Continue",
//   style: TextStyle(
//   color: Theme.of(context).colorScheme.primary,
//   fontWeight: FontWeight.bold,
//   ),
//   ),
//   ),
//   ),
//   const SizedBox(width: 16),
//   Expanded(
//   child: ElevatedButton(
//   onPressed: () async {
//   await DBHelper.instance
//       .deleteData(savedData[0]['id']);
//   Navigator.pop(context);
//   setState(() {
//   savedData = [];
//   _selectedItem = '';
//   _tapsPerLoop = 11;
//   _loopCounter = 0;
//   _tapCounter = 0;
//   });
//   },
//   style: ElevatedButton.styleFrom(
//   backgroundColor: Colors.deepOrange,
//   padding: const EdgeInsets.symmetric(vertical: 16),
//   shape: RoundedRectangleBorder(
//   borderRadius: BorderRadius.circular(12),
//   ),
//   elevation: 0,
//   ),
//   child: Text(
//   "Reset",
//   style: TextStyle(
//   color:
//   Theme.of(context).colorScheme.onErrorContainer,
//   fontWeight: FontWeight.bold,
//   ),
//   ),
//   ),
//   ),
//   ],
//   ),
//   ],
//   ),
//   ),
//   );
//   },
//   );
//   }
//
//   Future<void> _saveData() async {
//   if (savedData.isEmpty) {
//   await DBHelper.instance.insertData(
//   _selectedItem,
//   "$_tapsPerLoop",
//   "$_loopCounter",
//   "$_tapCounter",
//   );
//   } else {
//   await DBHelper.instance.updateData(
//   savedData[0]['id'],
//   _selectedItem,
//   "$_tapsPerLoop",
//   "$_loopCounter",
//   "$_tapCounter",
//   );
//   }
//   savedData = await DBHelper.instance.getData();
//   setState(() {});
//   }
//
//   // Add this variable to your state class
//   int _selectedTimeFilter = 3; // Default to "All Time"
//
//   // Sample data for different time periods
//   Map<String, List<Map<String, dynamic>>> _leaderboardData = {
//   'daily': [
//   {'rank': 1, 'name': 'Hanuman Dev', 'count': '1,250', 'emoji': '🥇', 'avatar': '🙏'},
//   {'rank': 2, 'name': 'Radha Krishna', 'count': '980', 'emoji': '🥈', 'avatar': '🌺'},
//   {'rank': 3, 'name': 'Shiva Shakti', 'count': '850', 'emoji': '🥉', 'avatar': '🕉️'},
//   {'rank': 4, 'name': 'Ram Bhakt', 'count': '720', 'emoji': '🙏', 'avatar': '📿'},
//   {'rank': 5, 'name': 'Ganga Devi', 'count': '680', 'emoji': '🌊', 'avatar': '💧'},
//   {'rank': 6, 'name': 'Krishna Prem', 'count': '550', 'emoji': '🕉️', 'avatar': '🌟'},
//   {'rank': 7, 'name': 'Yoga Nidra', 'count': '480', 'emoji': '🧘', 'avatar': '☮️'},
//   {'rank': 8, 'name': 'Dharma Raj', 'count': '420', 'emoji': '📿', 'avatar': '👑'},
//   {'rank': 9, 'name': 'Moksha Path', 'count': '380', 'emoji': '✨', 'avatar': '🕊️'},
//   {'rank': 10, 'name': 'Shanti Om', 'count': '320', 'emoji': '☮️', 'avatar': '🎵'},
//   ],
//   'weekly': [
//   {'rank': 1, 'name': 'Shiva Shakti', 'count': '8,750', 'emoji': '🥇', 'avatar': '🕉️'},
//   {'rank': 2, 'name': 'Hanuman Dev', 'count': '8,250', 'emoji': '🥈', 'avatar': '🙏'},
//   {'rank': 3, 'name': 'Radha Krishna', 'count': '7,980', 'emoji': '🥉', 'avatar': '🌺'},
//   {'rank': 4, 'name': 'Ganga Devi', 'count': '6,540', 'emoji': '🌊', 'avatar': '💧'},
//   {'rank': 5, 'name': 'Ram Bhakt', 'count': '5,870', 'emoji': '🙏', 'avatar': '📿'},
//   {'rank': 6, 'name': 'Krishna Prem', 'count': '5,450', 'emoji': '🕉️', 'avatar': '🌟'},
//   {'rank': 7, 'name': 'Dharma Raj', 'count': '4,920', 'emoji': '📿', 'avatar': '👑'},
//   {'rank': 8, 'name': 'Yoga Nidra', 'count': '4,380', 'emoji': '🧘', 'avatar': '☮️'},
//   {'rank': 9, 'name': 'Moksha Path', 'count': '3,950', 'emoji': '✨', 'avatar': '🕊️'},
//   {'rank': 10, 'name': 'Shanti Om', 'count': '3,520', 'emoji': '☮️', 'avatar': '🎵'},
//   ],
//   'monthly': [
//   {'rank': 1, 'name': 'Radha Krishna', 'count': '35,870', 'emoji': '🥇', 'avatar': '🌺'},
//   {'rank': 2, 'name': 'Hanuman Dev', 'count': '34,250', 'emoji': '🥈', 'avatar': '🙏'},
//   {'rank': 3, 'name': 'Shiva Shakti', 'count': '32,980', 'emoji': '🥉', 'avatar': '🕉️'},
//   {'rank': 4, 'name': 'Krishna Prem', 'count': '28,450', 'emoji': '🕉️', 'avatar': '🌟'},
//   {'rank': 5, 'name': 'Ram Bhakt', 'count': '25,870', 'emoji': '🙏', 'avatar': '📿'},
//   {'rank': 6, 'name': 'Ganga Devi', 'count': '24,540', 'emoji': '🌊', 'avatar': '💧'},
//   {'rank': 7, 'name': 'Dharma Raj', 'count': '22,920', 'emoji': '📿', 'avatar': '👑'},
//   {'rank': 8, 'name': 'Yoga Nidra', 'count': '20,380', 'emoji': '🧘', 'avatar': '☮️'},
//   {'rank': 9, 'name': 'Moksha Path', 'count': '18,950', 'emoji': '✨', 'avatar': '🕊️'},
//   {'rank': 10, 'name': 'Shanti Om', 'count': '16,520', 'emoji': '☮️', 'avatar': '🎵'},
//   ],
//   'allTime': [
//   {'rank': 1, 'name': 'Hanuman Dev', 'count': '156,870', 'emoji': '🥇', 'avatar': '🙏'},
//   {'rank': 2, 'name': 'Radha Krishna', 'count': '142,540', 'emoji': '🥈', 'avatar': '🌺'},
//   {'rank': 3, 'name': 'Shiva Shakti', 'count': '130,230', 'emoji': '🥉', 'avatar': '🕉️'},
//   {'rank': 4, 'name': 'Ram Bhakt', 'count': '119,870', 'emoji': '🙏', 'avatar': '📿'},
//   {'rank': 5, 'name': 'Krishna Prem', 'count': '108,450', 'emoji': '🕉️', 'avatar': '🌟'},
//   {'rank': 6, 'name': 'Ganga Devi', 'count': '97,890', 'emoji': '🌊', 'avatar': '💧'},
//   {'rank': 7, 'name': 'Yoga Nidra', 'count': '86,540', 'emoji': '🧘', 'avatar': '☮️'},
//   {'rank': 8, 'name': 'Dharma Raj', 'count': '75,670', 'emoji': '📿', 'avatar': '👑'},
//   {'rank': 9, 'name': 'Moksha Path', 'count': '64,320', 'emoji': '✨', 'avatar': '🕊️'},
//   {'rank': 10, 'name': 'Shanti Om', 'count': '53,150', 'emoji': '☮️', 'avatar': '🎵'},
//   ],
//   };
//
//   Map<String, Map<String, dynamic>> _userStats = {
//   'daily': {'rank': 15, 'count': '450', 'progress': '+25%'},
//   'weekly': {'rank': 18, 'count': '3,240', 'progress': '+15%'},
//   'monthly': {'rank': 22, 'count': '12,450', 'progress': '+8%'},
//   'allTime': {'rank': 25, 'count': '124,240', 'progress': '+5%'},
//   };
//
//   Map<String, String> _motivationalQuotes = {
//   'daily': "Start your day with divine chants for inner peace!",
//   'weekly': "Consistent practice leads to spiritual growth. Well done!",
//   'monthly': "A month of devotion brings you closer to enlightenment!",
//   'allTime': "Your spiritual journey inspires others. Keep chanting!",
//   };
//
//   String _getCurrentTimeFilter() {
//   switch (_selectedTimeFilter) {
//   case 0: return 'daily';
//   case 1: return 'weekly';
//   case 2: return 'monthly';
//   case 3: return 'allTime';
//   default: return 'allTime';
//   }
//   }
//
//   String _getTimeFilterSubtitle() {
//   switch (_selectedTimeFilter) {
//   case 0: return "Today's Top Spiritual Performers";
//   case 1: return "This Week's Top Spiritual Performers";
//   case 2: return "This Month's Top Spiritual Performers";
//   case 3: return "All Time Top Spiritual Performers";
//   default: return "Top Spiritual Performers";
//   }
//   }
//
//   Map<String, dynamic> _getUserStats() {
//   return _userStats[_getCurrentTimeFilter()]!;
//   }
//
//   String _getMotivationalQuote() {
//   return _motivationalQuotes[_getCurrentTimeFilter()]!;
//   }
//
//   List<Widget> _buildTopThreeWinners() {
//   final currentData = _leaderboardData[_getCurrentTimeFilter()]!;
//   final topThree = currentData.take(3).toList();
//
//   return [
//   _buildWinnerCard(
//   rank: topThree[1]['rank'],
//   name: topThree[1]['name'],
//   count: topThree[1]['count'],
//   avatar: topThree[1]['emoji'],
//   color: Colors.grey.shade300,
//   ),
//   _buildWinnerCard(
//   rank: topThree[0]['rank'],
//   name: topThree[0]['name'],
//   count: topThree[0]['count'],
//   avatar: topThree[0]['emoji'],
//   color: Colors.amber.shade200,
//   isFirst: true,
//   ),
//   _buildWinnerCard(
//   rank: topThree[2]['rank'],
//   name: topThree[2]['name'],
//   count: topThree[2]['count'],
//   avatar: topThree[2]['emoji'],
//   color: Colors.orange.shade200,
//   ),
//   ];
//   }
//
//   List<Widget> _buildLeaderboardList() {
//   final currentData = _leaderboardData[_getCurrentTimeFilter()]!;
//   // Skip first 3 since they're shown as winners
//   final remainingData = currentData.skip(3).toList();
//
//   return remainingData.map((user) => _buildLeaderboardItem(
//   user['rank'],
//   user['name'],
//   user['count'],
//   user['avatar'],
//   )).toList();
//   }
//
//   Widget _buildTimeTab(String text, int index) {
//   bool isSelected = _selectedTimeFilter == index;
//   return Expanded(
//   child: GestureDetector(
//   onTap: () {
//   setState(() {
//   _selectedTimeFilter = index;
//   });
//   },
//   child: Container(
//   padding: EdgeInsets.symmetric(vertical: 12, horizontal: 8),
//   decoration: BoxDecoration(
//   color: isSelected ? Colors.orange.shade500 : Colors.transparent,
//   borderRadius: BorderRadius.circular(8),
//   ),
//   child: Text(
//   text,
//   textAlign: TextAlign.center,
//   style: TextStyle(
//   color: isSelected ? Colors.white : Colors.grey.shade700,
//   fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
//   fontSize: 12,
//   ),
//   ),
//   ),
//   ),
//   );
//   }
//
//   Widget _buildWinnerCard({
//   required int rank,
//   required String name,
//   required String count,
//   required String avatar,
//   required Color color,
//   bool isFirst = false,
//   }) {
//   return Column(
//   children: [
//   Container(
//   padding: EdgeInsets.all(isFirst ? 20 : 15),
//   decoration: BoxDecoration(
//   color: color,
//   shape: BoxShape.circle,
//   border: Border.all(
//   color: Colors.orange.shade300,
//   width: isFirst ? 3 : 2,
//   ),
//   ),
//   child: Column(
//   children: [
//   Text(
//   avatar,
//   style: TextStyle(fontSize: isFirst ? 24 : 20),
//   ),
//   SizedBox(height: 5),
//   Text(
//   "#$rank",
//   style: TextStyle(
//   fontWeight: FontWeight.bold,
//   color: Colors.orange.shade800,
//   fontSize: isFirst ? 16 : 14,
//   ),
//   ),
//   ],
//   ),
//   ),
//   SizedBox(height: 10),
//   Text(
//   name,
//   style: TextStyle(
//   fontWeight: FontWeight.bold,
//   fontSize: isFirst ? 14 : 12,
//   ),
//   textAlign: TextAlign.center,
//   ),
//   Text(
//   count,
//   style: TextStyle(
//   color: Colors.orange.shade700,
//   fontSize: isFirst ? 12 : 10,
//   ),
//   ),
//   ],
//   );
//   }
//
//   Widget _buildLeaderboardItem(int rank, String name, String count, String emoji) {
//   return Container(
//   padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//   decoration: BoxDecoration(
//   border: Border(
//   bottom: BorderSide(
//   color: Colors.grey.shade100,
//   width: 1,
//   ),
//   ),
//   ),
//   child: Row(
//   children: [
//   Container(
//   padding: EdgeInsets.all(8),
//   decoration: BoxDecoration(
//   color: _getRankColor(rank),
//   shape: BoxShape.circle,
//   ),
//   child: Text(
//   rank.toString(),
//   style: TextStyle(
//   fontWeight: FontWeight.bold,
//   color: Colors.white,
//   fontSize: 12,
//   ),
//   ),
//   ),
//   SizedBox(width: 15),
//   Text(emoji, style: TextStyle(fontSize: 16)),
//   SizedBox(width: 10),
//   Expanded(
//   child: Text(
//   name,
//   style: TextStyle(
//   fontWeight: FontWeight.w500,
//   ),
//   ),
//   ),
//   Text(
//   count,
//   style: TextStyle(
//   fontWeight: FontWeight.bold,
//   color: Colors.orange.shade700,
//   ),
//   ),
//   ],
//   ),
//   );
//   }
//
//   Color _getRankColor(int rank) {
//   switch (rank) {
//   case 1:
//   return Colors.amber.shade600;
//   case 2:
//   return Colors.grey.shade600;
//   case 3:
//   return Colors.orange.shade600;
//   default:
//   return Colors.orange.shade400;
//   }
//   }
//
//   @override
//   void dispose() {
//   controllers.dispose();
//   _scrollController.dispose();
//   _tabController.dispose();
//   _customMantraController.dispose();
//   _customMantraNameController.dispose();
//   _tabController.dispose();
//   _animationController.dispose();
//   super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//   double screenwidth = MediaQuery.sizeOf(context).width;
//   double screenHeight = MediaQuery.of(context).size.height;
//
//   return DefaultTabController(
//   length: 4,
//   child: Scaffold(
//   backgroundColor: Colors.white30,
//   extendBodyBehindAppBar: true,
//   appBar: AppBar(
//   automaticallyImplyLeading: false,
//   elevation: 0,
//   backgroundColor: Colors.transparent,
//   centerTitle: true,
//   title: const Text(
//   'Jaap',
//   style: TextStyle(
//   color: Colors.orange,
//   fontSize: 25,
//   fontWeight: FontWeight.bold
//   ),
//   ),
//   flexibleSpace: SafeArea(
//   child: Padding(
//   padding: const EdgeInsets.only(left: 8.0, top: 8.0),
//   child: Row(
//   children: [
//   IconButton(
//   onPressed: () {
//   Navigator.pop(context);
//   },
//   icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
//   ),
//   IconButton(
//   onPressed: () {
//   Navigator.push(
//   context,
//   MaterialPageRoute(
//   builder: (context) => WallpaperScreen(),
//   ),
//   );
//   },
//   icon: const Icon(Icons.settings, color: Colors.white),
//   ),
//   ],
//   ),
//   ),
//   ),
//   // leading: IconButton(
//   //   onPressed: () {
//   //     Navigator.push(
//   //       context,
//   //       MaterialPageRoute(
//   //         builder: (context) => WallpaperScreen(),
//   //       ),
//   //     );
//   //   },
//   //   icon: Icon(
//   //     Icons.settings,
//   //     size: 18,
//   //     color: Colors.white,
//   //   ),
//   // ),
//   actions: [
//   // GestureDetector(
//   //   onTap: _showsettingsheet,
//   //   child: Icon(Icons.settings, color: Colors.white),
//   // ),
//   // SizedBox(width: 15),
//   BouncingWidgetInOut(
//   onPressed: () {
//   setState(() {
//   _vibrationEnabled = !_vibrationEnabled;
//   });
//   },
//   child: Container(
//   padding: const EdgeInsets.symmetric(horizontal: 7),
//   height: 40,
//   decoration: BoxDecoration(
//   borderRadius: BorderRadius.circular(8.0),
//   color: _vibrationEnabled
//   ? Colors.orange.withOpacity(0.4)
//       : Colors.transparent,
//   border: Border.all(color: Colors.white, width: 2)),
//   child: const Icon(
//   Icons.vibration,
//   color: Colors.white,
//   ),
//   ),
//   ),
//   const SizedBox(
//   width: 5,
//   ),
//   BouncingWidgetInOut(
//   onPressed: () {
//   _incrementNumber();
//   },
//   child: Container(
//   padding: const EdgeInsets.symmetric(horizontal: 7),
//   height: 40,
//   decoration: BoxDecoration(
//   borderRadius: BorderRadius.circular(8.0),
//   color: Colors.orange.withOpacity(0.4),
//   border: Border.all(color: Colors.white, width: 2)),
//   child: const Icon(
//   Icons.palette,
//   color: Colors.white,
//   ),
//   ),
//   ),
//   const SizedBox(
//   width: 10,
//   ),
//   ],
//   ),
//   body: Container(
//   decoration: BoxDecoration(
//   image: DecorationImage(
//   image: itemColorIndex == 0
//   ? const AssetImage('assets/images/jaap/ram_3.png')
//       : itemColorIndex == 1
//   ? const AssetImage('assets/images/jaap/ram_4.png')
//       : itemColorIndex == 2
//   ? const AssetImage('assets/images/jaap/ram_5.png')
//       : AssetImage('assets/images/jaap/$_selectedImage'),
//   fit: BoxFit.cover,
//   ),
//   ),
//   child: Column(
//   children: [
//   SizedBox(height: screenHeight * 0.11),
//   Padding(
//   padding: const EdgeInsets.only(left: 18, right: 18),
//   child: TabBar(
//   controller: _tabController,
//   isScrollable: false,
//   indicatorSize: TabBarIndicatorSize.tab,
//   dividerColor: Colors.transparent,
//   labelColor: Colors.white,
//   unselectedLabelColor: Colors.white,
//   indicatorWeight: 1,
//   indicatorColor: Colors.orange,
//   onTap: (index) {
//   setState(() {
//   _tabController.index = index;
//   });
//   },
//   tabs: [
//   Tab(
//   child: Container(
//   child: Center(
//   child: Text(
//   "Jaap",
//   style: TextStyle(fontSize: screenwidth * 0.04),
//   )),
//   ),
//   ),
//   Tab(
//   child: Container(
//   child: Center(
//   child: Text(
//   "Ram Lekhan",
//   style: TextStyle(fontSize: 10),
//   )),
//   ),
//   ),
//   Tab(
//   child: Container(
//   child: Center(
//   child: Text(
//   "Leaderboard",
//   style: TextStyle(fontSize: 9),
//   ),
//   ),
//   ),
//   ),
//   Tab(
//   child: Container(
//   child: Center(
//   child: Text(
//   "Score",
//   style: TextStyle(fontSize: screenwidth * 0.036),
//   )),
//   ),
//   ),
//
//   ],
//   ),
//   ),
//   Expanded(
//   child: TabBarView(
//   controller: _tabController,
//   physics: const NeverScrollableScrollPhysics(),
//   children: [
//   // --------------------------------JAAP TAB STARTS------------------------------
//   SingleChildScrollView(
//   child: Container(
//   decoration: const BoxDecoration(
//   image: DecorationImage(image: AssetImage("assets/images/jaap/animation_1.gif"))),
//   child: Padding(
//   padding: const EdgeInsets.all(10.0),
//   child: Column(
//   children: [
//   const SizedBox(
//   height: 10,
//   ),
//   Container(
//   padding: const EdgeInsets.all(30.0),
//   decoration: BoxDecoration(
//   color: Colors.white,
//   borderRadius: BorderRadius.circular(10),
//   border: Border.all(color: Colors.orange)),
//   height: screenHeight * 0.18,
//   width: double.infinity,
//   child: Center(
//   child: DropdownButton<String>(
//   iconEnabledColor: Colors.orange,
//   iconDisabledColor: Colors.black,
//   alignment: Alignment.center,
//   itemHeight: screenHeight * 0.10,
//   isExpanded: true,
//   underline: const SizedBox.shrink(),
//   hint: Text(
//   _selectedItem.isEmpty
//   ? 'मंत्र चुनें'
//       : people
//       .firstWhere((person) => person.name == _selectedItem)
//       .id,
//   style: TextStyle(
//   color: Colors.orange,
//   fontSize: getFontSize(
//   _selectedItem.isEmpty
//   ? ''
//       : people
//       .firstWhere((person) => person.name == _selectedItem)
//       .name,
//   screenwidth),
//   fontWeight: FontWeight.w600),
//   textAlign: TextAlign.center,
//   ),
//   icon: const Icon(Icons.arrow_drop_down_circle_outlined),
//   iconSize: 25,
//   onChanged: (value) {
//   setState(() {
//   _selectedItem = people
//       .firstWhere((person) => person.id == value)
//       .name;
//   });
//   },
//   items: [
//   ...people.map((person) {
//   return DropdownMenuItem<String>(
//   value: person.id,
//   child: Container(
//   padding: const EdgeInsets.all(8.0),
//   child: Text(
//   person.name,
//   style: const TextStyle(
//   fontSize: 16,
//   fontWeight: FontWeight.w500,
//   ),
//   overflow: TextOverflow.ellipsis,
//   ),
//   ),
//   );
//   }).toList(),
//   ],
//   // Add these properties to customize the dropdown menu
//   dropdownColor: Colors.white,
//   borderRadius: BorderRadius.circular(12),
//   elevation: 8,
//   menuMaxHeight: screenHeight * 0.5, // Limit maximum height
//   ),
//   ),
//   ),
//
//   // Add Custom Mantra Button
//   const SizedBox(height: 10),
//   Container(
//   width: double.infinity,
//   height: 50,
//   decoration: BoxDecoration(
//   color: Colors.orange.withOpacity(0.3),
//   borderRadius: BorderRadius.circular(10),
//   border: Border.all(color: Colors.orange),
//   ),
//   child: TextButton.icon(
//   icon: const Icon(Icons.add, color: Colors.white),
//   label: const Text(
//   "Add Your Own Mantra",
//   style: TextStyle(
//   color: Colors.white,
//   fontSize: 18,
//   fontWeight: FontWeight.bold,
//   ),
//   ),
//   onPressed: _showAddCustomMantraDialog,
//   ),
//   ),
//
//   Container(
//   color:
//   Colors.white, // optional, for visualization
//   child: Scrollbar(
//   child: SingleChildScrollView(
//   controller: _scrollController,
//   physics:
//   const ClampingScrollPhysics(), // or ClampingScrollPhysics()
//   child: Column(
//   mainAxisAlignment: MainAxisAlignment.start,
//   crossAxisAlignment:
//   CrossAxisAlignment.start,
//   children: [
//   Wrap(
//   spacing:
//   0, // Spacing between items in the same row
//   runSpacing: 0, // Spacing between rows
//   children: [
//   // Display the signatures
//   for (int i = 0;
//   i < signatures.length;
//   i++)
//   Container(
//   decoration: BoxDecoration(
//   border: Border(
//   right: BorderSide(
//   color: Colors.amber.shade200,
//   width: 1.0,
//   ),
//   left: BorderSide(
//   color: Colors.amber.shade200,
//   width: 1.0,
//   ),
//   bottom: BorderSide(
//   color: Colors.amber.shade200,
//   width: 1.0,
//   ),
//   )),
//   child: Padding(
//   padding: const EdgeInsets.only(
//   right: 8, left: 8),
//   child: Image.memory(
//   signatures[i],
//   width: screenwidth * 0.0959,
//   height: screenHeight * 0.063,
//   ),
//   ),
//   ),
//
//   // for (int i = 0; i < _textstype.length; i++)
//   //   Padding(
//   //     padding: const EdgeInsets.all(8.0),
//   //     child: Text(
//   //       _textstype[i],
//   //       style: TextStyle(
//   //           fontSize: screenwidth * 0.034, color: Colors.red),
//   //     ),
//   //   ),
//
//   for (var text in _texts) text,
//   ],
//   ),
//   const SizedBox(height: 20),
//   ],
//   ),
//   ),
//   ),
//   ),
//
//   // ----------------------------------0 loop-0  reset---------------------
//   const SizedBox(
//   height: 15,
//   ),
//   Row(
//   children: [
//   GestureDetector(
//   onTap: _selectedItem.isEmpty
//   ? null
//       : _showBottomSheets,
//   child: Column(
//   children: [
//   Container(
//   width: screenwidth * 0.17,
//   height: screenHeight * 0.08,
//   decoration: BoxDecoration(
//   border: Border.all(
//   color: Colors.white, width: 1),
//   color: Colors.orange.withOpacity(
//   0.4), // highlight color
//   borderRadius:
//   BorderRadius.circular(300),
//   ),
//   child: Center(
//   child: Text(
//   "$_tapsPerLoop",
//   style: TextStyle(
//   fontSize: _tapsPerLoop == 1008
//   ? 24
//       : 30,
//   fontWeight: FontWeight.bold,
//   color: Colors.white),
//   ),
//   ),
//   ),
//   const SizedBox(
//   height: 8,
//   ),
//   Container(
//   padding: const EdgeInsets.symmetric(
//   vertical: 2, horizontal: 5),
//   decoration: BoxDecoration(
//   border: Border.all(
//   color: Colors.white,
//   width: 1),
//   color: Colors.orange.withOpacity(
//   0.4), // highlight color
//   borderRadius:
//   BorderRadius.circular(8),
//   ),
//   child: const Center(
//   child: Text("संख्या चुनें",
//   style: TextStyle(
//   color: Colors.white,
//   fontSize: 18)))),
//   ],
//   ),
//   ),
//   const Spacer(),
//   Text(
//   'माला : $_loopCounter',
//   style: TextStyle(
//   fontSize: screenwidth * 0.08,
//   fontWeight: FontWeight.bold,
//   color: Colors.white),
//   ),
//   const Spacer(),
//   GestureDetector(
//   onTap: _selectedItem.isEmpty
//   ? null
//       : () async {
//   // make it async so await works
//   setState(() {
//   _tapCounter = 0;
//   _tapsPerLoop = 11;
//   _loopCounter = 0;
//   product = 0;
//   });
//
//   await DBHelper.instance.deleteData(
//   1); // deletes row with id=1
//   print(
//   "Data with id=1 deleted from DB");
//   },
//   child: Column(
//   children: [
//   Container(
//   width: screenwidth * 0.17,
//   height: screenHeight * 0.08,
//   decoration: BoxDecoration(
//   border: Border.all(
//   color: Colors.white, width: 1),
//   color:
//   Colors.orange.withOpacity(0.4),
//   borderRadius:
//   BorderRadius.circular(300),
//   ),
//   child: const Center(
//   child: Icon(Icons.restart_alt,
//   color: Colors.white, size: 35),
//   ),
//   ),
//   const SizedBox(height: 8),
//   Container(
//   padding: const EdgeInsets.symmetric(
//   vertical: 2, horizontal: 5),
//   decoration: BoxDecoration(
//   border: Border.all(
//   color: Colors.white, width: 1),
//   color:
//   Colors.orange.withOpacity(0.4),
//   borderRadius:
//   BorderRadius.circular(8),
//   ),
//   child: const Center(
//   child: Text(
//   "रीसेट करें",
//   style: TextStyle(
//   color: Colors.white,
//   fontSize: 18),
//   ),
//   ),
//   ),
//   ],
//   ),
//   )
//   ],
//   ),
//
//   GestureDetector(
//   onTap: () {
//   if (_selectedItem.isEmpty) {
//   // Show alert message
//   showCupertinoDialog(
//   context: context,
//   builder: (context) =>
//   CupertinoAlertDialog(
//   title: const Text(
//   'Please select the Jaap'),
//   //content: Text('You must select a Jaap before tapping'),
//   actions: [
//   CupertinoDialogAction(
//   child: const Text(
//   'OK',
//   style: TextStyle(
//   color: Colors.blueAccent),
//   ),
//   onPressed: () {
//   Navigator.of(context).pop();
//   },
//   ),
//   ],
//   ),
//   );
//   } else {
//   setState(() {
//   if (_vibrationEnabled) {
//   HapticFeedback.heavyImpact();
//   // Vibrate.feedback(FeedbackType
//   //     .warning); // Enable vibration
//   }
//   //play();
//   _animationController.forward();
//   _onButtonTap();
//   _incrementCounter();
//   product == 1 ? _startTimer() : null;
//   });
//   print("Save Data Clicked");
//   _saveData();
//   }
//   },
//   child: Transform.scale(
//   scale: _animation.value,
//   child: Stack(children: [
//   Container(
//   width: screenwidth * 0.8,
//   height: screenHeight * 0.37,
//   decoration: BoxDecoration(
//   image: const DecorationImage(
//   image: AssetImage(
//   "assets/images/jaap/flower.png")),
//   border: Border.all(
//   color: Colors.transparent,
//   width: 3),
//   color: Colors.transparent
//       .withOpacity(0.01),
//   borderRadius:
//   BorderRadius.circular(300),
//   ),
//   child: Center(
//   child: Text(
//   _tapCounter
//       .toString()
//       .padLeft(2, '0'),
//   style: TextStyle(
//   color: Colors.white,
//   fontSize: screenwidth * 0.23,
//   fontWeight: FontWeight.bold,
//   ),
//   ),
//   ),
//   ),
//   ]),
//   ),
//   ),
//   // ----------------------------------0 loop-0  reset---------------------
//
//   Row(
//   mainAxisAlignment: MainAxisAlignment.end,
//   children: [
//   Container(
//   width: screenwidth * 0.17,
//   height: screenHeight * 0.08,
//   decoration: BoxDecoration(
//   border: Border.all(
//   color: Colors.white, width: 3),
//   color: Colors.orange
//       .withOpacity(0.5), // highlight color
//   borderRadius: BorderRadius.circular(300),
//   ),
//   child: Center(
//   child: TextButton(
//   child: Text(
//   "Save",
//   style: TextStyle(
//   fontSize: screenwidth * 0.035,
//   fontWeight: FontWeight.bold,
//   color: Colors.white),
//   ),
//   onPressed: () {
//   if (_selectedItem.isEmpty) {
//   // Show alert message
//   showCupertinoDialog(
//   context: context,
//   builder: (context) =>
//   CupertinoAlertDialog(
//   title: const Text(
//   'Please select the Jaap'),
//   actions: [
//   CupertinoDialogAction(
//   child: const Text(
//   'OK',
//   style: TextStyle(
//   color: Colors
//       .blueAccent),
//   ),
//   onPressed: () {
//   Navigator.of(context)
//       .pop();
//   },
//   ),
//   ],
//   ),
//   );
//   } else {
//   _stopTimer();
//   countSave("$product");
//   }
//   },
//   ),
//   ),
//   ),
//   ],
//   ),
//   ],
//   ),
//   ),
//   ),
//   ),
//
//   // --------------------------------RAM LEKHAN TAB STARTS------------------------------
//   SingleChildScrollView(
//   controller: _scrollController,
//   physics: const ClampingScrollPhysics(), // or ClampingScrollPhysics()
//   child: Container(
//   height: screenHeight * 0.835,
//   color: Colors.white,
//   child: Stack(
//   children: [
//   _isSignatureVisible
//   ? Positioned(
//   top: screenHeight * 0.57,
//   child: Column(
//   children: [
//   // Conditionally show the Signature Container
//   Container(
//   height: screenHeight * 0.26,
//   width: screenwidth * 0.999,
//   decoration: BoxDecoration(
//   color: Colors.red,
//   border: Border.all(
//   color: Colors.red, width: 2),
//   ),
//   child: Signature(
//   controller: controllers,
//   //height: 270,
//   width: double.infinity,
//   backgroundColor: Colors.white,
//   ),
//   )
//   ],
//   ),
//   )
//       : const SizedBox(),
//
//   // Positioned(
//   //   top: screenHeight * 0.68,
//   //   child: Column(
//   //     children: [
//   //       if (_showKeyboard)
//   //         Padding(
//   //           padding: const EdgeInsets.symmetric(horizontal: 12,),
//   //           child: SizedBox(
//   //             // Add a SizedBox with a specific width
//   //             width: screenwidth * 0.560, //// or any other width you want
//   //             height: screenHeight * 0.06,
//   //             child: TextFormField(
//   //               controller: _textController,
//   //               decoration: InputDecoration(
//   //                 suffixIcon: IconButton(
//   //                   icon: Icon(Icons.send),
//   //                   onPressed: () {
//   //                     _updateText(_textController.text);
//   //                     _textController.clear(); // Clear text field after updating
//   //                     _toggleKeyboard(); // Hide keyboard after input
//   //                   },
//   //                 ),
//   //                 hintText: 'Type here...',
//   //                 border: OutlineInputBorder(
//   //                     borderRadius: BorderRadius.circular(100)),
//   //               ),
//   //             ),
//   //           ),
//   //         ),
//   //     ],
//   //   ),
//   // ),
//   ],
//   ),
//   ),
//   ),
//
//   // Inside your TabBarView, add this for the Leaderboard tab:
//   SingleChildScrollView(
//   child: Container(
//   padding: EdgeInsets.all(16),
//   child: Column(
//   children: [
//   // Header Section
//   Container(
//   padding: EdgeInsets.all(20),
//   decoration: BoxDecoration(
//   gradient: LinearGradient(
//   colors: [Colors.orange.shade700, Colors.orange.shade400],
//   begin: Alignment.topLeft,
//   end: Alignment.bottomRight,
//   ),
//   borderRadius: BorderRadius.circular(20),
//   boxShadow: [
//   BoxShadow(
//   color: Colors.orange.withOpacity(0.3),
//   blurRadius: 10,
//   offset: Offset(0, 4),
//   ),
//   ],
//   ),
//   child: Row(
//   children: [
//   Icon(Icons.leaderboard, color: Colors.white, size: 30),
//   SizedBox(width: 10),
//   Expanded(
//   child: Column(
//   crossAxisAlignment: CrossAxisAlignment.start,
//   children: [
//   Text(
//   "Jaap Leaderboard",
//   style: TextStyle(
//   color: Colors.white,
//   fontSize: 20,
//   fontWeight: FontWeight.bold,
//   ),
//   ),
//   SizedBox(height: 5),
//   Text(
//   _getTimeFilterSubtitle(),
//   style: TextStyle(
//   color: Colors.white.withOpacity(0.9),
//   fontSize: 14,
//   ),
//   ),
//   ],
//   ),
//   ),
//   ],
//   ),
//   ),
//
//   SizedBox(height: 20),
//
//   // Time Filter Tabs
//   Container(
//   decoration: BoxDecoration(
//   color: Colors.grey.shade50,
//   borderRadius: BorderRadius.circular(12),
//   border: Border.all(color: Colors.grey.shade200),
//   ),
//   child: Row(
//   children: [
//   _buildTimeTab("Daily", 0),
//   _buildTimeTab("Weekly", 1),
//   _buildTimeTab("Monthly", 2),
//   _buildTimeTab("All Time", 3),
//   ],
//   ),
//   ),
//
//   SizedBox(height: 25),
//
//   // Top 3 Winners
//   Text(
//   "Top Performers",
//   style: TextStyle(
//   fontSize: 18,
//   fontWeight: FontWeight.bold,
//   color: Colors.orange.shade800,
//   ),
//   ),
//   SizedBox(height: 15),
//   Row(
//   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//   children: _buildTopThreeWinners(),
//   ),
//
//   SizedBox(height: 30),
//
//   // Leaderboard List
//   Container(
//   decoration: BoxDecoration(
//   color: Colors.white,
//   borderRadius: BorderRadius.circular(15),
//   boxShadow: [
//   BoxShadow(
//   color: Colors.grey.withOpacity(0.1),
//   blurRadius: 10,
//   offset: Offset(0, 2),
//   ),
//   ],
//   ),
//   child: Column(
//   children: [
//   // List Header
//   Container(
//   padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//   decoration: BoxDecoration(
//   color: Colors.orange.shade50,
//   borderRadius: BorderRadius.only(
//   topLeft: Radius.circular(15),
//   topRight: Radius.circular(15),
//   ),
//   ),
//   child: Row(
//   children: [
//   Text("Rank", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange.shade800)),
//   SizedBox(width: 20),
//   Expanded(child: Text("Devotee", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange.shade800))),
//   Text("Jaap Count", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange.shade800)),
//   ],
//   ),
//   ),
//
//   // Leaderboard Items
//   ..._buildLeaderboardList(),
//   ],
//   ),
//   ),
//
//   SizedBox(height: 20),
//
//   // Current User Stats
//   Container(
//   padding: EdgeInsets.all(16),
//   decoration: BoxDecoration(
//   gradient: LinearGradient(
//   colors: [Colors.deepOrange.shade50, Colors.orange.shade50],
//   begin: Alignment.topLeft,
//   end: Alignment.bottomRight,
//   ),
//   borderRadius: BorderRadius.circular(15),
//   border: Border.all(color: Colors.orange.shade200),
//   ),
//   child: Row(
//   children: [
//   Container(
//   padding: EdgeInsets.all(10),
//   decoration: BoxDecoration(
//   color: Colors.orange.shade100,
//   shape: BoxShape.circle,
//   ),
//   child: Icon(Icons.person, color: Colors.orange.shade700),
//   ),
//   SizedBox(width: 15),
//   Expanded(
//   child: Column(
//   crossAxisAlignment: CrossAxisAlignment.start,
//   children: [
//   Text(
//   "Your Position",
//   style: TextStyle(
//   color: Colors.orange.shade800,
//   fontWeight: FontWeight.bold,
//   ),
//   ),
//   Text(
//   "Rank #${_getUserStats()['rank']} • ${_getUserStats()['count']} Jaaps",
//   style: TextStyle(
//   color: Colors.orange.shade600,
//   fontSize: 16,
//   ),
//   ),
//   ],
//   ),
//   ),
//   Container(
//   padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//   decoration: BoxDecoration(
//   color: Colors.orange.shade100,
//   borderRadius: BorderRadius.circular(20),
//   ),
//   child: Text(
//   _getUserStats()['progress'],
//   style: TextStyle(
//   color: Colors.orange.shade700,
//   fontWeight: FontWeight.bold,
//   fontSize: 12,
//   ),
//   ),
//   ),
//   ],
//   ),
//   ),
//
//   SizedBox(height: 20),
//
//   // Motivational Quote
//   Container(
//   padding: EdgeInsets.all(16),
//   decoration: BoxDecoration(
//   color: Colors.orange.shade50,
//   borderRadius: BorderRadius.circular(12),
//   border: Border.all(color: Colors.orange.shade100),
//   ),
//   child: Row(
//   children: [
//   Icon(Icons.lightbulb_outline, color: Colors.orange.shade600),
//   SizedBox(width: 10),
//   Expanded(
//   child: Text(
//   _getMotivationalQuote(),
//   style: TextStyle(
//   color: Colors.orange.shade700,
//   fontStyle: FontStyle.italic,
//   ),
//   ),
//   ),
//   ],
//   ),
//   ),
//   ],
//   ),
//   ),
//   ),
//
//   // Score History
//   Center(
//   child: History(
//   product: product,
//   data: _savedCounts,
//   index: tabIndex,
//   counter: _counter,
//   pressCounts: _pressCounts,
//   selectedItem: _selectedItem,
//   currentTime: _currentTime,
//   ),
//   ),
//   ],
//   ),
//   ),
//   ],
//   ),
//   ),
//   floatingActionButton: _tabController.index == 1
//   ? Stack(
//   children: [
//   _isSignatureVisible
//   ? Positioned(
//   bottom: 10,
//   right: 10,
//   child: Column(
//   mainAxisAlignment: MainAxisAlignment.end,
//   children: [
//   IconButton(
//   onPressed: () {
//   setState(() {
//   _isSignatureVisible =
//   false; // Toggle the visibility
//   });
//   },
//   icon: Icon(
//   _isSignatureVisible
//   ? Icons.cancel
//       : Icons.edit,
//   size: 30,
//   ),
//   ),
//   const SizedBox(height: 5),
//   IconButton(
//   onPressed: () async {
//   controllers.clear();
//   setState(() {});
//   },
//   icon: const Icon(Icons.undo),
//   ),
//   const SizedBox(height: 5),
//   IconButton(
//   onPressed: () async {
//   Uint8List? newSignature =
//   await controllers.toPngBytes();
//   if (newSignature != null) {
//   signatures.add(newSignature);
//   setState(() {});
//   }
//   _incrementButtonPressCounts();
//   // Clear the signature pad after saving
//   controllers.clear();
//   },
//   icon: const Icon(Icons.done),
//   ),
//   ],
//   ),
//   )
//       : Positioned(
//   right: 10,
//   bottom: 10,
//   child: Row(
//   mainAxisAlignment: MainAxisAlignment.end,
//   crossAxisAlignment: CrossAxisAlignment.end,
//   children: [
//   Row(
//   mainAxisAlignment: MainAxisAlignment.start,
//   children: [
//   IconButton(
//   onPressed: () async {
//   showCupertinoDialog(
//   context: context,
//   builder: (BuildContext context) {
//   return CupertinoAlertDialog(
//   title: const Text('Clear All'),
//   actions: [
//   CupertinoDialogAction(
//   child: const Text(
//   'Cancel',
//   style: TextStyle(
//   color: Colors.blue),
//   ),
//   onPressed: () {
//   Navigator.of(context).pop();
//   },
//   ),
//   CupertinoDialogAction(
//   child: const Text(
//   'Clear',
//   style: TextStyle(
//   color: Colors.red,
//   ),
//   ),
//   onPressed: () {
//   _texts.clear();
//   signatures.clear();
//   _buttonPressCount = 0;
//   _buttonPressCounts = 0;
//   _totalPressCount = 0;
//   _textController.clear();
//   _textstype.clear();
//   setState(() {});
//   Navigator.of(context).pop();
//   },
//   ),
//   ],
//   );
//   },
//   );
//   },
//   icon: Image.network(
//   'https://w7.pngwing.com/pngs/892/810/png-transparent-computer-icons-eraser-icon-design-graphic-design-eraser-angle-logo-black-thumbnail.png',
//   width:
//   24, // adjust the width and height to your liking
//   height: 24,
//   ),
//   ),
//   const SizedBox(
//   width: 10.0,
//   ),
//   IconButton(
//   onPressed: () {
//   setState(() {
//   _isSignatureVisible =
//   true; // Toggle the visibility
//   });
//   },
//   icon: Icon(
//   _isSignatureVisible
//   ? Icons.done
//       : Icons.edit,
//   ),
//   ),
//   ],
//   ),
//
//   // Score btn Ram btn Count
//   Column(
//   children: [
//   Container(
//   width: screenwidth * 0.17,
//   height: screenHeight * 0.08,
//   decoration: BoxDecoration(
//   border: Border.all(
//   color: Colors.purple.shade300,
//   width: 1),
//   color: Colors.grey.withOpacity(0.1),
//   borderRadius: BorderRadius.circular(300),
//   ),
//   child: Center(
//   child: Text(
//   _totalPressCount
//       .toString()
//       .padLeft(2, '0'),
//   style: TextStyle(
//   fontSize: screenwidth * 0.070,
//   fontWeight: FontWeight.bold,
//   color: Colors.purple.shade300),
//   ),
//   ),
//   ),
//   const SizedBox(
//   height: 10,
//   ),
//   Container(
//   width: screenwidth * 0.17,
//   height: screenHeight * 0.08,
//   decoration: BoxDecoration(
//   border: Border.all(
//   color: Colors.purple.shade300,
//   width: 1),
//   color: Colors.grey.withOpacity(0.1),
//   borderRadius: BorderRadius.circular(300),
//   ),
//   child: Center(
//   child: TextButton(
//   child: Text(
//   "Score",
//   style: TextStyle(
//   fontSize: screenwidth * 0.034,
//   fontWeight: FontWeight.bold,
//   color: Colors.purple.shade300),
//   ),
//   onPressed: () {
//   if (_totalPressCount == 0 &&
//   _texts.isEmpty &&
//   signatures.isEmpty &&
//   _textstype.isEmpty) {
//   // Show alert message
//   showCupertinoDialog(
//   context: context,
//   builder: (context) =>
//   CupertinoAlertDialog(
//   title: const Text(
//   'Please perform some action'),
//   actions: [
//   CupertinoDialogAction(
//   child: const Text(
//   'OK',
//   style: TextStyle(
//   color: Colors
//       .blueAccent),
//   ),
//   onPressed: () {
//   Navigator.of(context)
//       .pop();
//   },
//   ),
//   ],
//   ),
//   );
//   } else {
//   // Navigate to ResultPage and pass the product
//   // Use DefaultTabController.of(context) to access TabController
//   _stopTimer();
//   ramLekhanSave("$_totalPressCount");
//   }
//   },
//   ),
//   ),
//   ),
//   Row(
//   children: [
//   SizedBox(height: screenHeight * 0.10),
//   InkWell(
//   onTap: () {
//   setState(() {
//   if (_vibrationEnabled) {
//   HapticFeedback.heavyImpact();
//
//   // Vibrate.feedback(FeedbackType
//   //     .warning); // Enable vibration
//   }
//   _addText();
//   _incrementButtonPressCount();
//   _scrollToLastSignature();
//   _startTimer();
//   });
//   },
//   child: Container(
//   width: screenwidth * 0.17,
//   height: screenHeight * 0.08,
//   decoration: BoxDecoration(
//   border: Border.all(
//   color: Colors.purple.shade300,
//   width: 1),
//   color: Colors.grey.withOpacity(0.1),
//   borderRadius:
//   BorderRadius.circular(300),
//   ),
//   child: Center(
//   child: Text(
//   "Ram",
//   style: TextStyle(
//   fontSize: screenwidth * 0.034,
//   fontWeight: FontWeight.bold,
//   color:
//   Colors.purple.shade300),
//   ),
//   ),
//   ),
//   ),
//   ],
//   ),
//   ],
//   ),
//   ],
//   ),
//   )
//   ],
//   )
//       : const SizedBox(),
//   ),
//   );
//   }
//
//   void _showAddCustomMantraDialog() {
//   _customMantraController.clear();
//   _customMantraNameController.clear();
//
//   showDialog(
//   context: context,
//   builder: (BuildContext context) {
//   return AlertDialog(
//   title: const Text("Add Your Mantra"),
//   content: SingleChildScrollView(
//   child: Column(
//   mainAxisSize: MainAxisSize.min,
//   children: [
//   TextField(
//   controller: _customMantraNameController,
//   decoration: const InputDecoration(
//   labelText: "Mantra Name",
//   hintText: "Example : Shiv Jaap",
//   hintStyle: TextStyle(color: Colors.grey),
//   border: OutlineInputBorder(),
//   ),
//   ),
//   const SizedBox(height: 15),
//   TextField(
//   controller: _customMantraController,
//   maxLines: 3,
//   decoration: const InputDecoration(
//   labelText: "Mantra Text",
//   hintText: "Enter your mantra here...",
//   border: OutlineInputBorder(),
//   ),
//   ),
//   ],
//   ),
//   ),
//   actions: [
//   TextButton(
//   onPressed: () => Navigator.pop(context),
//   child: const Text("Cancel"),
//   ),
//   ElevatedButton(
//   onPressed: () {
//   if (_customMantraController.text.isNotEmpty &&
//   _customMantraNameController.text.isNotEmpty) {
//   Navigator.pop(context);
//   _showSankalpOptionDialog();
//   } else {
//   ScaffoldMessenger.of(context).showSnackBar(
//   const SnackBar(
//   content: Text("Please enter both mantra name and text"),
//   ),
//   );
//   }
//   },
//   child: const Text("OK"),
//   ),
//   ],
//   );
//   },
//   );
//   }
//
//   void _showSankalpOptionDialog() {
//   showDialog(
//   context: context,
//   builder: (BuildContext context) {
//   return AlertDialog(
//   title: const Text("Take Sankalp?"),
//   content: const Text("Would you like to set a Sankalp for this mantra?"),
//   actions: [
//   TextButton(
//   onPressed: () {
//   Navigator.pop(context);
//   _addCustomMantra(hasSankalp: false);
//   },
//   child: const Text("No"),
//   ),
//   ElevatedButton(
//   onPressed: () {
//   Navigator.pop(context);
//   _showSankalpDetailsDialog();
//   },
//   child: const Text("Yes"),
//   ),
//   ],
//   );
//   },
//   );
//   }
//
//   void _showSankalpDetailsDialog() {
//   _startDate = DateTime.now();
//   _endDate = DateTime.now().add(const Duration(days: 30));
//   _selectedTime = TimeOfDay.now();
//   _targetCount = 108;
//
//   showDialog(
//   context: context,
//   builder: (BuildContext context) {
//   return StatefulBuilder(
//   builder: (context, setState) {
//   return AlertDialog(
//   title: const Text("Set Your Sankalp"),
//   content: SingleChildScrollView(
//   child: Column(
//   mainAxisSize: MainAxisSize.min,
//   children: [
//   // Start Date
//   ListTile(
//   leading: const Icon(Icons.calendar_today),
//   title: const Text("Start Date"),
//   subtitle: Text(_startDate != null
//   ? "${_startDate!.day}/${_startDate!.month}/${_startDate!.year}"
//       : "Not set"),
//   onTap: () async {
//   final DateTime? picked = await showDatePicker(
//   context: context,
//   initialDate: _startDate ?? DateTime.now(),
//   firstDate: DateTime.now(),
//   lastDate: DateTime(2100),
//   );
//   if (picked != null) {
//   setState(() => _startDate = picked);
//   }
//   },
//   ),
//
//   // End Date
//   ListTile(
//   leading: const Icon(Icons.event_available),
//   title: const Text("End Date"),
//   subtitle: Text(_endDate != null
//   ? "${_endDate!.day}/${_endDate!.month}/${_endDate!.year}"
//       : "Not set"),
//   onTap: () async {
//   final DateTime? picked = await showDatePicker(
//   context: context,
//   initialDate: _endDate ?? DateTime.now().add(const Duration(days: 30)),
//   firstDate: DateTime.now(),
//   lastDate: DateTime(2100),
//   );
//   if (picked != null) {
//   setState(() => _endDate = picked);
//   }
//   },
//   ),
//
//   // Preferred Time
//   // ListTile(
//   //   leading: const Icon(Icons.access_time),
//   //   title: const Text("Preferred Time"),
//   //   subtitle: Text(_selectedTime != null
//   //       ? _selectedTime!.format(context)
//   //       : "Not set"),
//   //   onTap: () async {
//   //     final TimeOfDay? picked = await showTimePicker(
//   //       context: context,
//   //       initialTime: _selectedTime ?? TimeOfDay.now(),
//   //     );
//   //     if (picked != null) {
//   //       setState(() => _selectedTime = picked);
//   //     }
//   //   },
//   // ),
//
//   // Target Count
//   ListTile(
//   leading: const Icon(Icons.format_list_numbered),
//   title: const Text("Target Count"),
//   subtitle: Text("$_targetCount"),
//   trailing: Row(
//   mainAxisSize: MainAxisSize.min,
//   children: [
//   IconButton(
//   icon: const Icon(Icons.remove),
//   onPressed: () {
//   if (_targetCount > 1) {
//   setState(() => _targetCount--);
//   }
//   },
//   ),
//   IconButton(
//   icon: const Icon(Icons.add),
//   onPressed: () {
//   setState(() => _targetCount++);
//   },
//   ),
//   ],
//   ),
//   ),
//
//   // Duration
//   // ListTile(
//   //   leading: const Icon(Icons.timer),
//   //   title: const Text("Duration (optional)"),
//   //   subtitle: Text(_duration != null
//   //       ? "${_duration!.inMinutes} minutes"
//   //       : "Not set"),
//   //   onTap: () async {
//   //     showDialog(
//   //       context: context,
//   //       builder: (context) => AlertDialog(
//   //         title: const Text("Select Duration"),
//   //         content: Column(
//   //           mainAxisSize: MainAxisSize.min,
//   //           children: [5, 10, 15, 20, 30, 45, 60]
//   //               .map((minutes) => ListTile(
//   //             title: Text("$minutes minutes"),
//   //             onTap: () {
//   //               Navigator.pop(context);
//   //               setState(() => _duration = Duration(minutes: minutes));
//   //             },
//   //           ))
//   //               .toList(),
//   //         ),
//   //       ),
//   //     );
//   //   },
//   // ),
//   ],
//   ),
//   ),
//   actions: [
//   TextButton(
//   onPressed: () => Navigator.pop(context),
//   child: const Text("Cancel"),
//   ),
//   ElevatedButton(
//   onPressed: () {
//   if (_startDate != null && _endDate != null && _selectedTime != null) {
//   Navigator.pop(context);
//   _addCustomMantra(hasSankalp: true);
//   } else {
//   ScaffoldMessenger.of(context).showSnackBar(
//   const SnackBar(
//   content: Text("Please fill all required fields"),
//   ),
//   );
//   }
//   },
//   child: const Text("Set Sankalp"),
//   ),
//   ],
//   );
//   },
//   );
//   },
//   );
//   }
//
//   void _addCustomMantra({required bool hasSankalp}) {
//   final newMantra = Person(
//   id: _customMantraController.text,
//   name: _customMantraNameController.text,
//   );
//
//   setState(() {
//   people.add(newMantra);
//   _selectedItem = newMantra.name;
//   _hasSankalp = hasSankalp;
//
//   if (hasSankalp) {
//   // You can store the sankalp details in shared preferences or database
//   _storeSankalpDetails();
//   }
//   });
//
//   // Show success message
//   ScaffoldMessenger.of(context).showSnackBar(
//   SnackBar(
//   content: Text(hasSankalp
//   ? "Mantra added with Sankalp! 🙏"
//       : "Mantra added successfully!"),
//   backgroundColor: Colors.green,
//   ),
//   );
//   }
//
//   void _storeSankalpDetails() {
//   // Store sankalp details in SharedPreferences or database
//   // This is where you would save the commitment details
//   print('''
//     Sankalp Details:
//     Mantra: ${_customMantraNameController.text}
//     Start Date: $_startDate
//     End Date: $_endDate
//     Time: $_selectedTime
//     Target Count: $_targetCount
//     Duration: $_duration
//   ''');
//
//   // You can use SharedPreferences or your database to store this
//   // For example:
//   // SharedPreferences prefs = await SharedPreferences.getInstance();
//   // prefs.setString('sankalp_mantra', _customMantraNameController.text);
//   // etc...
//   }
//
//   void _scrollToLastSignature() {
//   if (signatures.isNotEmpty) {
//   _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
//   }
//   }
//   }