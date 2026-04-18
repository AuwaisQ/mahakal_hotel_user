import 'dart:convert';
import 'package:avatar_stack/avatar_stack.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'app_constants.dart';

class DevoteesCountWidget extends StatefulWidget {
  const DevoteesCountWidget({super.key});

  @override
  State<DevoteesCountWidget> createState() => _DevoteesCountWidgetState();
}

class _DevoteesCountWidgetState extends State<DevoteesCountWidget> {
  /// ---- CONFIG (change once, works everywhere) ----
  static const String apiUrl = AppConstants.baseUrl + '/api/v1/pooja/puja-devotee';
  static const String responseKey = 'images';

  final double width = 300;
  final double height = 30;
  final int maxAvatars = 10;

  /// ---- STATE ----
  List<String> images = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadImages();
  }

  /// ---- API CALL ----
  Future<void> _loadImages() async {
    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        images = List<String>.from(data[responseKey] ?? []);
      }
    } catch (e) {
      debugPrint('DevoteesCountWidget error: $e');
    }

    isLoading = false;
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading || images.isEmpty) {
      return const SizedBox.shrink();
    }

    return AvatarStack(
      width: width,
      height: height,
      borderWidth: 1.5,
      borderColor: Colors.black,
      avatars: images.take(maxAvatars).map((url) => NetworkImage(url)).toList(),
      infoWidgetBuilder: (remaining) => Container(
        width: height,
        height: height,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.orange.shade600,
          boxShadow: [
            BoxShadow(
              color: Colors.orange.withOpacity(0.3),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),

            ),
      
    );
      
  }
}
