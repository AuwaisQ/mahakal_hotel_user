import 'package:flutter/material.dart';
import 'package:mahakal/features/astrotalk/controller/astrotalk_controller.dart';
import 'package:mahakal/features/profile/controllers/profile_contrroller.dart';
import 'package:mahakal/features/splash/controllers/splash_controller.dart';
import 'package:mahakal/utill/app_constants.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:flutter/services.dart';
import 'dart:async';

class ShortVideoPlayer extends StatefulWidget {
  final String url;
  final bool isStarted;
  final String astrologerName;
  final String astrologerImageUrl;

  const ShortVideoPlayer({
    super.key,
    required this.url,
    required this.isStarted,
    required this.astrologerName,
    required this.astrologerImageUrl,
  });

  @override
  State<ShortVideoPlayer> createState() => _ShortVideoPlayerState();
}

class _ChatMessage {
  final String userName;
  final String userImageUrl;
  final String text;
  final String messageId;

  _ChatMessage({
    required this.userName,
    required this.userImageUrl,
    required this.text,
    required this.messageId,
  });
}

class _ShortVideoPlayerState extends State<ShortVideoPlayer> {
  VideoPlayerController? _videoPlayerController;
  ChewieController? _chewieController;
  
  final TextEditingController _messageController = TextEditingController();
  final FocusNode _messageFocusNode = FocusNode();
  final ScrollController _messageScrollController = ScrollController();
  
  final List<_ChatMessage> _messages = [];
  final Set<String> _processedMessageIds = {};
  bool _isVisible = false;
  bool _isInitialized = false;
  bool _isDisposed = false;
  
  late final SocketController _socketController;
  late final String _userName;
  late final String _userImage;
  late final String _userId;
  late final String _streamId;
  late final String _baseImageUrl;

  @override
  void initState() {
    super.initState();
    _initializeData();
    _initializePlayer();
    _setupSocketListeners();
    _sendJoinMessage();
  }

  void _initializeData() {
    final profileController = context.read<ProfileController>();
    final splashController = context.read<SplashController>();
    
    // ✅ TRIM all user data to remove whitespace
    _userName = profileController.userNAME?.trim() ?? 'User';
    _userImage = profileController.userIMAGE?.trim() ?? '';
    _userId = profileController.userID?.trim() ?? '';
    _baseImageUrl = splashController.baseUrls?.customerImageUrl?.trim() ?? '';
    
    // ✅ Extract stream ID and trim it
    final urlParts = widget.url.split('/').last.split('.');
    _streamId = urlParts.first.trim();
    
    _socketController = context.read<SocketController>();
    
    if (!_socketController.isConnected) {
      _socketController.initSocket(_userId);
    }
  }

  Future<void> _initializePlayer() async {
    try {
      // ✅ TRIM the URL before passing to player
      final trimmedUrl = widget.url.trim();
      debugPrint('Initializing player with URL: $trimmedUrl');
      
      _videoPlayerController = VideoPlayerController.networkUrl(
        Uri.parse(trimmedUrl),
      );
      
      await _videoPlayerController!.initialize();
      
      if (_isDisposed) return;

      _chewieController = ChewieController(
        videoPlayerController: _videoPlayerController!,
        autoPlay: true,
        draggableProgressBar: false,
        showControlsOnInitialize: false,
        isLive: true,
        looping: true,
        aspectRatio: MediaQuery.of(context).size.aspectRatio,
        errorBuilder: (_, __) => _buildErrorWidget('Live has ended'),
      );

      if (mounted) setState(() => _isInitialized = true);
    } catch (e) {
      debugPrint('Player initialization error: $e');
    }
  }

  void _setupSocketListeners() {
    _socketController.socketService.onLiveStreamMessage(_handleIncomingMessage);
  }

  void _handleIncomingMessage(dynamic data) {
    if (_isDisposed || data is! Map) return;
    
    debugPrint('Raw socket data: $data');
    
    final messageId = data['messageId']?.toString() ?? 
                     '${data['username']}_${data['message']}_${DateTime.now().millisecondsSinceEpoch}';
    
    // ✅ TRIM all string values
    final userName = data['username']?.toString().trim();
    final userImage = data['userimage']?.toString().trim();
    final message = data['message']?.toString().trim();

    if (userName == null || message == null) {
      debugPrint('Invalid message data: missing username or message');
      return;
    }

    if (_processedMessageIds.contains(messageId)) {
      debugPrint('Duplicate message ignored: $messageId');
      return;
    }
    _processedMessageIds.add(messageId);

    if (_processedMessageIds.length > 100) {
      _processedMessageIds.remove(_processedMessageIds.first);
    }

    // ✅ Properly construct image URL with trim
    final imageUrl = userImage!.isNotEmpty 
        ? '$_baseImageUrl/$userImage'.trim() 
        : 'https://via.placeholder.com/150';

    debugPrint('Message from: $userName, Image: $imageUrl, Text: $message');

    final newMessage = _ChatMessage(
      userName: userName,
      userImageUrl: imageUrl,
      text: message,
      messageId: messageId,
    );

    if (mounted) {
      setState(() => _messages.add(newMessage));
      _scrollToBottom();
    }
  }

  void _sendJoinMessage() {
    final joinMessage = 'joined the live stream!';
    
    _socketController.socketService.sendChatMessageLivestream(
      _streamId,
      _userName,
      '$_baseImageUrl/$_userImage'.trim(), // ✅ TRIM
      joinMessage,
    );
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    _messageController.clear();
    _messageFocusNode.unfocus();
    SystemChannels.textInput.invokeMethod('TextInput.hide');

    _socketController.socketService.sendChatMessageLivestream(
      _streamId,
      _userName,
      '$_baseImageUrl/$_userImage'.trim(), // ✅ TRIM
      text,
    );
  }

  void _scrollToBottom() {
    if (!_messageScrollController.hasClients) return;
    
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_messageScrollController.hasClients) {
        _messageScrollController.animateTo(
          _messageScrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _handleVisibility(bool visible) {
    if (_videoPlayerController?.value.isInitialized != true) return;
    
    if (visible) {
      _videoPlayerController!.play();
    } else {
      _videoPlayerController!.pause();
    }
  }

  @override
  void didUpdateWidget(ShortVideoPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isStarted && !widget.isStarted) {
      _videoPlayerController?.pause();
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    _chewieController?.dispose();
    _videoPlayerController?.dispose();
    _messageController.dispose();
    _messageFocusNode.dispose();
    _messageScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: Key(widget.url),
      onVisibilityChanged: (info) {
        final visible = info.visibleFraction > 0.5;
        if (_isVisible != visible) {
          _isVisible = visible;
          _handleVisibility(visible);
        }
      },
      child: Container(
        color: Colors.black,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Video Player
            if (_isInitialized && _chewieController != null)
              Chewie(controller: _chewieController!)
            else
              const Center(child: CircularProgressIndicator()),

            // Top Bar
            _buildTopBar(),

            // Right Actions
            _buildRightActions(),

            // Chat Messages
            _buildChatOverlay(),

            // Input Field
            _buildInputField(),

            // Ended Stream Overlay
            if (!widget.isStarted) _buildEndedOverlay(),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: EdgeInsets.only(
          top: MediaQuery.of(context).padding.top + 10,
          left: 16,
          right: 16,
          bottom: 20,
        ),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.black87, Colors.transparent],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Row(
          children: [
            // ✅ TRIM image URL
            CircleAvatar(
              radius: 20,
              backgroundImage: NetworkImage(
                widget.astrologerImageUrl.trim().isNotEmpty
                    ? '${AppConstants.astrologersImages}${widget.astrologerImageUrl.trim()}'
                    : 'https://via.placeholder.com/150',
              ),
              onBackgroundImageError: (e, _) => debugPrint('Astrologer image error: $e'),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.astrologerName.trim().isNotEmpty
                      ? widget.astrologerName.trim()
                      : 'Astrologer',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Row(
                  children: [
                    Icon(Icons.circle, color: Colors.red, size: 8),
                    SizedBox(width: 4),
                    Text(
                      'LIVE',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const Spacer(),
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: Colors.black45,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close, color: Colors.white, size: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRightActions() {
    return Positioned(
      right: 16,
      bottom: 100,
      child: Column(
        children: [
          // _actionButton(Icons.favorite, 'Like'),
          // const SizedBox(height: 16),
          _actionButton(Icons.card_giftcard, 'Gift'),
          // const SizedBox(height: 16),
          // _actionButton(Icons.share, 'Share'),
        ],
      ),
    );
  }

  Widget _actionButton(IconData icon, String label) {
    return Column(
      children: [
        CircleAvatar(
          backgroundColor: Colors.black45,
          radius: 24,
          child: Icon(icon, color: Colors.white),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(color: Colors.white, fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildChatOverlay() {
    return Positioned(
      left: 16,
      right: 100,
      bottom: 80,
      height: 200,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [
              Colors.black.withOpacity(0.7),
              Colors.transparent,
            ],
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: ListView.builder(
          controller: _messageScrollController,
          reverse: true,
          padding: const EdgeInsets.all(8),
          itemCount: _messages.length,
          itemBuilder: (context, index) {
            final msg = _messages[_messages.length - 1 - index];
            return _buildMessageBubble(msg);
          },
        ),
      ),
    );
  }

  Widget _buildMessageBubble(_ChatMessage msg) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ✅ Handle image errors gracefully
          ClipOval(
            child: Image.network(
              msg.userImageUrl,
              width: 28,
              height: 28,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                debugPrint('Failed to load image: ${msg.userImageUrl}, Error: $error');
                return Container(
                  width: 28,
                  height: 28,
                  color: Colors.grey,
                  child: const Icon(Icons.person, size: 16, color: Colors.white),
                );
              },
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    msg.userName,
                    style: const TextStyle(
                      color: Colors.yellow,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    msg.text,
                    style: const TextStyle(color: Colors.white, fontSize: 13),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField() {
    return Positioned(
      bottom: 20,
      left: 16,
      right: 16,
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      focusNode: _messageFocusNode,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _sendMessage(),
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        hintText: 'Send a message...',
                        hintStyle: TextStyle(color: Colors.white70),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: _sendMessage,
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: Colors.blue,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.send,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEndedOverlay() {
    return Positioned.fill(
      child: Container(
        color: Colors.black87,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.videocam_off, size: 64, color: Colors.white54),
              const SizedBox(height: 16),
              const Text(
                'Live has ended',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${widget.astrologerName} was live',
                style: const TextStyle(color: Colors.white70),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorWidget(String message) {
    return Container(
      color: Colors.black87,
      child: Center(
        child: Text(
          message,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}