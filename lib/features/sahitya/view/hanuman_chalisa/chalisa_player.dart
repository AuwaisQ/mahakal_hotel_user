import 'package:mahakal/features/sahitya/model/hanuman_chalisa_model.dart';
import 'package:just_audio/just_audio.dart';
import 'package:flutter/material.dart';

enum ShuffleMode {
  playNext,
  playOnceAndClose,
  playOnLoop,
}

class ChalisaPlayer extends ChangeNotifier {
  final AudioPlayer _audioPlayer = AudioPlayer();

  int _currentIndex = 0;
  bool _isPlaying = false;
  final bool _isFullChalisa = false;
  bool _isChalisaAudioBarVisible = false;

  String fullChalisaAudio =
      "assets/hanuman_chalisa_audio/full_hanuman_chalisa.mp3";

  HanumanChalisaModel? _currentChalisaAudio;
  List<HanumanChalisaModel> _playlist = [];

  Duration _duration = Duration.zero;
  Duration _currentPosition = Duration.zero;
  ShuffleMode _shuffleMode = ShuffleMode.playNext;

  // Getters
  bool get isPlaying => _isPlaying;
  bool get isFullChalisa => _isFullChalisa;
  int get currentIndex => _currentIndex;
  HanumanChalisaModel? get currentChalisaAudio => _currentChalisaAudio;
  bool get isChalisaAudioBarVisible => _isChalisaAudioBarVisible;
  Duration get duration => _duration;
  Duration get currentPosition => _currentPosition;
  ShuffleMode get shuffleMode => _shuffleMode;

  ChalisaPlayer() {
    // Listen for duration changes
    _audioPlayer.durationStream.listen((duration) {
      _duration = duration ?? Duration.zero;
      notifyListeners();
    });

    // Listen for position changes
    _audioPlayer.positionStream.listen((position) {
      _currentPosition = position;
      notifyListeners();
    });

    // Listen for player state changes
    _audioPlayer.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed) {
        _handlePlaybackCompletion();
      }
    });
  }

  void setShuffleMode(ShuffleMode mode) {
    _shuffleMode = mode;
    notifyListeners();
  }

  void toggleChalisaAudioBarVisibility() {
    _isChalisaAudioBarVisible = !_isChalisaAudioBarVisible;
    notifyListeners();
  }

  void setPlaylist(List<HanumanChalisaModel> playlist) {
    _playlist = playlist;
    _currentIndex = 0;
    notifyListeners();
  }

  Future<void> playChalisaAudio(HanumanChalisaModel chalisaAudio) async {
    if (chalisaAudio.audioUrl == null || chalisaAudio.audioUrl!.isEmpty) {
      print("Invalid audio URL");
      return;
    }

    try {
      _currentChalisaAudio = chalisaAudio;
      _currentIndex = _playlist.indexOf(chalisaAudio);
      _isPlaying = true;
      _isChalisaAudioBarVisible = true;
      notifyListeners();

      await _audioPlayer.setAsset(chalisaAudio.audioUrl!);
      await _audioPlayer.play();
      await _updateNotification();
    } catch (error) {
      print('Error playing chalisaAudio: $error');
    }
  }

  void stopChalisaAudio() {
    _audioPlayer.stop();
    _isPlaying = false;
    _isChalisaAudioBarVisible = false;
    notifyListeners();
  }

  void togglePlayPause() async {
    if (_isPlaying) {
      pauseChalisaAudio();
    } else {
      if (_currentChalisaAudio != null) {
        await _audioPlayer.play();
        _isPlaying = true;
        await _updateNotification();
        notifyListeners();
      }
    }
  }

  void pauseChalisaAudio() async {
    await _audioPlayer.pause();
    _isPlaying = false;
    await _updateNotification();
    notifyListeners();
  }

  void skipNext() {
    if (_playlist.isEmpty) {
      print("Playlist is empty, cannot skip to next.");
      return;
    }

    _currentIndex = (_currentIndex + 1) % _playlist.length;
    playChalisaAudio(_playlist[_currentIndex]);
  }

  void skipPrevious() {
    if (_playlist.isEmpty || _currentChalisaAudio == null) {
      print("Playlist is empty or no current chalisaAudio to skip from.");
      return;
    }

    _currentIndex = (_currentIndex - 1 + _playlist.length) % _playlist.length;
    playChalisaAudio(_playlist[_currentIndex]);
  }

  void seekTo(Duration position) {
    _audioPlayer.seek(position);
    _currentPosition = position;
    notifyListeners();
  }

  Future<void> _updateNotification() async {
    // Add code for updating the notification with current chalisaAudio info
  }

  void _handlePlaybackCompletion() {
    switch (_shuffleMode) {
      case ShuffleMode.playNext:
        skipNext();
        break;
      case ShuffleMode.playOnceAndClose:
        stopChalisaAudio();
        break;
      case ShuffleMode.playOnLoop:
        _audioPlayer.seek(Duration.zero);
        _audioPlayer.play();
        break;
    }
  }

//   Future<void> playFullChalisa() async {
//   if (fullChalisaAudio != null) {
//     try {
//       // Check if the audio is currently playing
//       if (_isFullChalisa) {
//         // If it's already playing, pause it
//         await _audioPlayer.pause();
//         _isFullChalisa = false; // Update the state to indicate it's paused
//         notifyListeners();
//         print("Paused full audio");
//       } else {
//         // If it's not playing, play the full audio
//         print("Playing full audio");
//         await _audioPlayer.setAsset(fullChalisaAudio!);
//         _isFullChalisa = true; // Update the state to indicate it's playing
//         await _audioPlayer.play();
//         notifyListeners();
//
//         // Listen for when the audio finishes
//         _audioPlayer.playerStateStream.listen((state) {
//           if (state.processingState == ProcessingState.completed) {
//             // After the audio finishes, set the state to false
//             _isFullChalisa = false;
//             notifyListeners();
//             print("Full audio completed");
//           }
//         });
//       }
//     } catch (error) {
//       print('Error playing full audio: $error');
//     }
//   } else {
//     // If no audio is available
//     print("No audio available");
//   }
// }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }
}
