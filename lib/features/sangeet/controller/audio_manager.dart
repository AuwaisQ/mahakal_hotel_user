import 'package:flutter/material.dart';
// import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:just_audio/just_audio.dart';
import '../model/sangeet_model.dart';
import 'all_audiocontroller.dart';

enum ShuffleModeSangeet {
  playNext,
  playOnceAndClose,
  playOnLoop,
}

class AudioPlayerManager extends ChangeNotifier with WidgetsBindingObserver {
  final AudioPlayer _audioPlayer = AudioPlayer();

  List<Sangeet> _playlist = [];
  List<Sangeet> _playlistAll = [];
  int _currentIndex = -1;
  bool _isPlaying = false;
  Sangeet? _currentMusic;
  Duration _duration = Duration.zero;
  Duration _currentPosition = Duration.zero;
  bool _isMusicBarVisible = false;
  bool _fixedTabMusic = false;
  ShuffleModeSangeet _shuffleMode = ShuffleModeSangeet.playNext;

  // Getters
  bool get isPlaying => _isPlaying;
  bool get fixedTabMusic => _fixedTabMusic;
  int get currentIndex => _currentIndex;
  Sangeet? get currentMusic => _currentMusic;
  Duration get duration => _duration;
  Duration get currentPosition => _currentPosition;
  ShuffleModeSangeet get shuffleMode => _shuffleMode;
  bool get isMusicBarVisible => _isMusicBarVisible;

  // Setters
  void resetMusicBarVisibility() {
    _isMusicBarVisible = false;
  }

  void toggleMusicBarVisibility() {
    _isMusicBarVisible = !_isMusicBarVisible;
    notifyListeners();
  }

  void fixedTabMusicCliked(bool isTabCliked) {
    _fixedTabMusic = isTabCliked;
    notifyListeners();
  }

  void setShuffleMode(ShuffleModeSangeet mode) {
    _shuffleMode = mode;
    notifyListeners();
  }

  void setPlaylist(List<Sangeet> playlist) {
    _playlist = playlist;
    _currentIndex = -1;
    notifyListeners();
  }

  void setPlaylistAll(List<Sangeet> playlistAll) {
    _playlistAll = playlistAll;
    _currentIndex = -1;
    notifyListeners();
  }

  Future<void> playMusic(Sangeet music, bool? isFix) async {
    try {
      await _audioPlayer.setUrl(music.audio);
      _audioPlayer.play();
      _currentMusic = music;
      _currentIndex =
          isFix! ? _playlistAll.indexOf(music) : _playlist.indexOf(music);
      _isPlaying = true;
      _isMusicBarVisible = true;
      notifyListeners();

      _audioPlayer.durationStream.listen((duration) {
        _duration = duration ?? Duration.zero;
        notifyListeners();
      });

      _audioPlayer.positionStream.listen((position) {
        _currentPosition = position;
        notifyListeners();
      });

      _audioPlayer.playerStateStream.listen((state) {
        if (state.processingState == ProcessingState.completed) {
          switch (_shuffleMode) {
            case ShuffleModeSangeet.playNext:
              skipNext(isFix);
              break;
            case ShuffleModeSangeet.playOnceAndClose:
              pauseMusic();
              break;
            case ShuffleModeSangeet.playOnLoop:
              _audioPlayer.seek(Duration.zero);
              _audioPlayer.play();
              break;
          }
        }
      });

      notifyListeners();
    } catch (error) {
      print('Error playing music: $error');
    }
  }

  void pauseMusic() async {
    _audioPlayer.pause();
    _isPlaying = false;
    notifyListeners();
  }

  void togglePlayPause() async {
    if (_isPlaying) {
      pauseMusic();
    } else {
      if (_currentMusic != null) {
        _audioPlayer.play();
        _isPlaying = true;
        notifyListeners();
      }
    }
  }

  void skipNext(bool? isFix) {
    if (_currentMusic != null) {
      int currentIndexInPlaylist = isFix!
          ? _playlistAll.indexOf(_currentMusic!)
          : _playlist.indexOf(_currentMusic!);
      if (currentIndexInPlaylist <
          (isFix ? _playlistAll.length - 1 : _playlist.length - 1)) {
        _currentIndex = currentIndexInPlaylist + 1;
      } else {
        _currentIndex = 0;
      }

      playMusic(isFix ? _playlistAll[_currentIndex] : _playlist[_currentIndex],
          isFix);
    }
  }

  void stopMusic() {
    _audioPlayer.stop();
    _isPlaying = false;
    AllAudioController().clearCurrentPlayer();
    notifyListeners();
  }

  void skipPrevious({List<Sangeet>? fixedTabMusicList, bool? isFix}) {
    List<Sangeet> playlist =
        fixedTabMusicList ?? (isFix! ? _playlistAll : _playlist);

    if (_currentMusic != null) {
      int currentIndexInPlaylist = playlist.indexOf(_currentMusic!);

      if (currentIndexInPlaylist > 0) {
        _currentIndex = currentIndexInPlaylist - 1;
      } else {
        _currentIndex = playlist.length - 1;
      }

      playMusic(playlist[_currentIndex], isFix);
    }
  }

  void seekTo(Duration position) {
    _audioPlayer.seek(position);
    _currentPosition = position;
    notifyListeners();
  }

  @override
  void dispose() {
    super.dispose();
    _audioPlayer.dispose();
  }
}
