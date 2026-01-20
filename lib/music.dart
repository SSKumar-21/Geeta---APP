import 'package:audioplayers/audioplayers.dart';

class MusicService {
  static final MusicService _instance = MusicService._internal();
  factory MusicService() => _instance;

  MusicService._internal();

  final AudioPlayer _player = AudioPlayer();
  bool _isPlaying = false;

  Future<void> play() async {
    if (_isPlaying) return;

    _isPlaying = true;

    await _player.setPlayerMode(PlayerMode.mediaPlayer); // 👈 REQUIRED
    await _player.setReleaseMode(ReleaseMode.loop);

    await _player.play(
      AssetSource('media/flute.mp3'),
      volume: 1.0,
    );
  }

}
