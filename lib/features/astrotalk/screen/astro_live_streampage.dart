import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:mahakal/utill/app_constants.dart';
import 'package:mahakal/features/astrotalk/model/live_stream_model.dart';
import 'package:provider/provider.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'dart:async';
import 'dart:convert';

import '../components/video_live_player.dart';
import '../controller/astrotalk_controller.dart';

class ShortsFeedScreen extends StatefulWidget {
  const ShortsFeedScreen({super.key});

  @override
  State<ShortsFeedScreen> createState() => _ShortsFeedScreenState();
}

class _ShortsFeedScreenState extends State<ShortsFeedScreen> {
  final PageController _pageController = PageController();
  final List<LiveStreamModel> _videoUrls = [];
  
  bool _isLoading = true;
  bool _isDisposed = false;
  bool _socketInitialized = false;
  
  // Debounce timers to prevent rapid state changes
  Timer? _streamStartDebounce;
  Timer? _streamEndDebounce;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    // Enable wake lock to keep screen on during live streams
    await WakelockPlus.enable();
    
    // Set preferred orientations for video viewing
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    
    _fetchVideoUrls();
    _setupSocketListeners();
  }

  void _setupSocketListeners() {
    if (_socketInitialized) return;
    _socketInitialized = true;

    final socketController = context.read<SocketController>();
    
    socketController.socketService.onStreamStart(_handleStreamStart);
    socketController.socketService.onStreamEnd(_handleStreamEnd);
  }

  void _handleStreamStart(dynamic data) {
    if (_isDisposed || data is! Map || !data.containsKey('streamId')) return;

    // Debounce to prevent duplicate processing
    _streamStartDebounce?.cancel();
    _streamStartDebounce = Timer(const Duration(milliseconds: 500), () {
      if (_isDisposed) return;
      
      final streamId = data['streamId']?.toString();
      if (streamId == null || _isStreamAlreadyAdded(streamId)) return;

      final newStream = LiveStreamModel(
        astrologerId: data['astrologerId'],
        url: '${AppConstants.astrologerLiveStreamURL}$streamId.m3u8',
        stream: true,
        startedAt: data['startedAt'],
        streamId: streamId,
        astrologerName: data['astrologerName'] ?? 'N/A',
        astrologerImage: data['astrologerImage'] ?? '',
      );

      setState(() => _videoUrls.add(newStream));
    });
  }

  void _handleStreamEnd(dynamic data) {
    if (_isDisposed || data == null) return;

    final streamId = data is Map ? data['streamId']?.toString() : data.toString();
    if (streamId == null) return;

    final streamUrl = '${AppConstants.astrologerLiveStreamURL}$streamId.m3u8';

    _streamEndDebounce?.cancel();
    _streamEndDebounce = Timer(const Duration(seconds: 5), () {
      if (_isDisposed) return;

      final index = _videoUrls.indexWhere((item) => item.url == streamUrl);
      if (index == -1) return;

      // Mark as ended but keep for 15s before removing
      setState(() => _videoUrls[index].stream = false);

      Timer(const Duration(seconds: 15), () {
        if (_isDisposed) return;
        
        _removeStreamAndAdjustPage(streamUrl);
      });
    });
  }

  bool _isStreamAlreadyAdded(String streamId) {
    final streamUrl = '${AppConstants.astrologerLiveStreamURL}$streamId.m3u8';
    return _videoUrls.any((item) => item.url == streamUrl);
  }

  void _removeStreamAndAdjustPage(String streamUrl) {
    final index = _videoUrls.indexWhere((item) => item.url == streamUrl);
    if (index == -1) return;

    setState(() => _videoUrls.removeAt(index));

    // Adjust page if needed
    if (_videoUrls.isEmpty || !_pageController.hasClients) return;

    final currentPage = _pageController.page?.round() ?? 0;
    if (currentPage >= _videoUrls.length) {
      _pageController.animateToPage(
        _videoUrls.length - 1,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _fetchVideoUrls() async {
    try {
      final response = await http.get(Uri.parse(AppConstants.liveAstrologers));
      
      if (!_isDisposed && response.statusCode == 200) {
        final data = json.decode(response.body);
        final streams = (data['activeStreams'] as List<dynamic>?) ?? [];

        final fetchedStreams = streams.map((streamData) {
          final streamId = streamData['streamId']?.toString();
          return LiveStreamModel(
            url: '${AppConstants.astrologerLiveStreamURL}$streamId.m3u8',
            stream: true,
            astrologerId: streamData['astrologerId'],
            startedAt: streamData['startedAt'],
            streamId: streamId.toString(),
            astrologerName: streamData['astrologerName'] ?? 'N/A',
            astrologerImage: streamData['astrologerImage'] ?? '',
          );
        }).toList();

        setState(() {
          _videoUrls
            ..clear()
            ..addAll(fetchedStreams);
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to load streams: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error fetching video URLs: $e');
      if (!_isDisposed) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _refreshStreams() async {
    setState(() => _isLoading = true);
    await _fetchVideoUrls();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: _isLoading ? _buildLoading() : _buildBody(),
    );
  }

  Widget _buildLoading() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: Colors.white),
          SizedBox(height: 16),
          Text(
            'Loading live streams...',
            style: TextStyle(color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_videoUrls.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: _refreshStreams,
      color: Colors.white,
      backgroundColor: Colors.grey[900],
      child: PageView.builder(
        padEnds: false,
        controller: _pageController,
        scrollDirection: Axis.vertical,
        itemCount: _videoUrls.length,
        onPageChanged: _handlePageChange,
        itemBuilder: (context, index) {
          final video = _videoUrls[index];
          return ShortVideoPlayer(
            key: ValueKey(video.url),
            url: video.url!,
            isStarted: video.stream ?? false,
            astrologerName: video.astrologerName,
            astrologerImageUrl: video.astrologerImage,
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return SafeArea(
      child: Column(
        children: [
          AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          const Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.videocam_off, size: 64, color: Colors.white54),
                  SizedBox(height: 16),
                  Text(
                    'No Astrologers are Live',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Pull down to refresh',
                    style: TextStyle(color: Colors.white54, fontSize: 14),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handlePageChange(int index) {
    // Pause previous/next videos for performance
    // Implement in ShortVideoPlayer via VisibilityDetector or similar
    debugPrint('Switched to page: $index');
  }

  @override
  void dispose() {
    _isDisposed = true;
    _streamStartDebounce?.cancel();
    _streamEndDebounce?.cancel();
    
    // Remove socket listeners
    // try {
    //   final socketController = context.read<SocketController>();
    //   socketController.socketService.offStreamStart(_handleStreamStart);
    //   socketController.socketService.offStreamEnd(_handleStreamEnd);
    // } catch (e) {
    //   debugPrint('Error removing socket listeners: $e');
    // }
    
    _pageController.dispose();
    
    // Disable wake lock when leaving screen
    WakelockPlus.disable();
    
    // Reset orientations
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    
    super.dispose();
  }
}
