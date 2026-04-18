// import 'package:flutter/material.dart';
// import 'package:mahakal/features/sahitya/view/hanuman_chalisa/chalisa_musiclist_model.dart';
// import 'package:just_audio/just_audio.dart';
//
// class ListChalisaPlayer with ChangeNotifier{
//
//   final AudioPlayer _audioPlayer = AudioPlayer();
//
//   bool _isPlaying = false;
//   ChalisaMusiclistModel? _currentTrack;
//   List<ChalisaMusiclistModel> _musicUrlList = [];
//
//   bool get isPlaying => _isPlaying;
//   ChalisaMusiclistModel? get currentTrack => _currentTrack;
//
//   void setChalisaList(List<ChalisaMusiclistModel> musicList){
//     _musicUrlList = musicList;
//     print("method called");
//     notifyListeners();
//   }
//
//   void playListChalisa(int index) async{
//
//     if(_isPlaying && _currentTrack == _musicUrlList[index]){
//       _audioPlayer.pause();
//       _isPlaying = false;
//      // togglePlayPause(index);
//       notifyListeners();
//       //_currentTrack = ;
//
//     } else {
//       _isPlaying = true;
//       await _audioPlayer.setAsset(_musicUrlList[index].musicUrl ?? '');
//       await _audioPlayer.play();
//       _currentTrack = _musicUrlList[index];
//       notifyListeners();
//     }
//     notifyListeners();
//   }
//
//   // void togglePlayPause(int index) async{
//   //   if(_isPlaying){
//   //     _isPlaying = false;
//   //     await _audioPlayer.pause();
//   //     notifyListeners();
//   //   } else{
//   //     if(_currentTrack !=null){
//   //       _isPlaying = true;
//   //       await _audioPlayer.setAsset(_musicUrlList[index].musicUrl ?? '');
//   //       await _audioPlayer.play();
//   //       notifyListeners();
//   //
//   //     }
//   //   }
//   // }
//
// }

import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'chalisa_musiclist_model.dart'; // Ensure this model file is correctly implemented

class ListChalisaPlayer with ChangeNotifier {
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;
  ChalisaMusiclistModel? _currentTrack;
  List<ChalisaMusiclistModel> _musicUrlList = [];
  Duration _currentDuration = Duration.zero;
  Duration _totalDuration = Duration.zero;

  bool get isPlaying => _isPlaying;
  ChalisaMusiclistModel? get currentTrack => _currentTrack;
  Duration get currentDuration => _currentDuration;
  Duration get totalDuration => _totalDuration;

  // Set the list of music tracks
  void setChalisaList(List<ChalisaMusiclistModel> musicList) {
    _musicUrlList = musicList;
    notifyListeners();
  }

  // Play a specific track
  void playTrack(int index) async {
    if (_isPlaying && _currentTrack == _musicUrlList[index]) {
      pause();
    } else {
      stop(); // Stop any currently playing track
      _currentTrack = _musicUrlList[index];
      _isPlaying = true;
      notifyListeners();

      // Load and play the selected track
      await _audioPlayer.setAsset(_currentTrack!.musicUrl ?? '');
      _audioPlayer.play();
      _listenToPositionUpdates();
    }
  }

  // Pause the current track
  void pause() async {
    if (_isPlaying) {
      await _audioPlayer.pause();
      _isPlaying = false;
      notifyListeners();
    }
  }

  // Stop playback
  void stop() async {
    if (_isPlaying || _currentTrack != null) {
      await _audioPlayer.stop();
      _isPlaying = false;
      _currentTrack = null;
      _currentDuration = Duration.zero;
      _totalDuration = Duration.zero;
      notifyListeners();
    }
  }

  // Toggle play/pause for the current track
  void togglePlayPause() async {
    if (_isPlaying) {
      pause();
    } else if (_currentTrack != null) {
      _isPlaying = true;
      await _audioPlayer.play();
      notifyListeners();
    }
  }

  //Listen to position updates
  void _listenToPositionUpdates() {
    _audioPlayer.positionStream.listen((position) {
      _currentDuration = position;
      notifyListeners();
    });

    _audioPlayer.durationStream.listen((duration) {
      _totalDuration = duration ?? Duration.zero;
      notifyListeners();
    });
  }

  void seekTo(Duration position) {
    _audioPlayer.seek(position);
    _currentDuration = position;
    notifyListeners();
  }

  // Dispose the audio player when not in use
  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }
}
