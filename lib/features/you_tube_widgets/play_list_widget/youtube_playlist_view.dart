import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import '../../../data/datasource/remote/http/httpClient.dart';
import '../youtube_model/playlist_model.dart';

class YoutubePlaylistPage extends StatefulWidget {
  final String playlistId;

  const YoutubePlaylistPage({super.key, required this.playlistId});

  @override
  _YoutubePlaylistPageState createState() => _YoutubePlaylistPageState();
}

class _YoutubePlaylistPageState extends State<YoutubePlaylistPage> {
  late YoutubeService _youtubeService;
  late Future<List<Video>> _playlistFuture;
  YoutubePlayerController? _playerController;

  @override
  void initState() {
    super.initState();
    _youtubeService = YoutubeService();
    _playlistFuture = _youtubeService.fetchPlaylist(widget.playlistId);
  }

  @override
  void dispose() {
    _playerController?.dispose();
    super.dispose();
  }

  void _playVideo(String videoId) {
    if (_playerController == null) {
      _playerController = YoutubePlayerController(
        initialVideoId: videoId,
        flags: const YoutubePlayerFlags(
          autoPlay: true,
        ),
      );
    } else {
      _playerController!.load(videoId);
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('YouTube Playlist'),
      ),
      body: FutureBuilder<List<Video>>(
        future: _playlistFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No videos found'));
          } else {
            final videos = snapshot.data!;
            return Column(
              children: [
                if (_playerController != null)
                  YoutubePlayer(
                    controller: _playerController!,
                    showVideoProgressIndicator: true,
                  ),
                Expanded(
                  child: ListView.builder(
                    itemCount: videos.length,
                    itemBuilder: (context, index) {
                      final video = videos[index];
                      return ListTile(
                        leading: Image.network(video.thumbnailUrl),
                        title: Text(video.title),
                        onTap: () => _playVideo(video.videoId),
                      );
                    },
                  ),
                ),
              ],
            );
          }
        },
      ),
    );
  }
}
