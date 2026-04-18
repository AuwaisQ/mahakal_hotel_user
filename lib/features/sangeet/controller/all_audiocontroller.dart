import 'package:just_audio/just_audio.dart';

class AllAudioController {
  static final AllAudioController _instance = AllAudioController._internal();
  factory AllAudioController() => _instance;

  AllAudioController._internal();

  AudioPlayer? _currentPlayer;

  void registerPlayer(AudioPlayer newPlayer) {
    if (_currentPlayer != null && _currentPlayer != newPlayer) {
      _currentPlayer!.stop(); // Stop the currently playing audio
    }
    _currentPlayer = newPlayer; // Register the new active player
  }

  void clearCurrentPlayer() {
    _currentPlayer = null;
  }
}
