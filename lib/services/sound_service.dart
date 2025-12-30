import 'package:audioplayers/audioplayers.dart';

/// Sound effects service for game feedback
/// Premium principle: Subtle, satisfying audio cues
class SoundService {
  static final AudioPlayer _player = AudioPlayer();
  static bool _soundEnabled = true;
  static bool _initialized = false;

  /// Initialize the sound service
  static Future<void> init() async {
    if (_initialized) return;

    // Set volume to moderate level
    await _player.setVolume(0.5);
    await _player.setReleaseMode(ReleaseMode.stop);
    _initialized = true;
  }

  /// Toggle sound on/off
  static void toggleSound(bool enabled) {
    _soundEnabled = enabled;
  }

  /// Play correct answer sound
  static Future<void> correct() async {
    if (!_soundEnabled) return;
    try {
      await _player.play(AssetSource('sounds/correct.mp3'));
    } catch (e) {
      // Silently fail if sound file not found
    }
  }

  /// Play incorrect answer sound
  static Future<void> incorrect() async {
    if (!_soundEnabled) return;
    try {
      await _player.play(AssetSource('sounds/incorrect.mp3'));
    } catch (e) {
      // Silently fail if sound file not found
    }
  }

  /// Play tap/select sound
  static Future<void> tap() async {
    if (!_soundEnabled) return;
    try {
      await _player.play(AssetSource('sounds/tap.mp3'));
    } catch (e) {
      // Silently fail if sound file not found
    }
  }

  /// Play level up / achievement sound
  static Future<void> levelUp() async {
    if (!_soundEnabled) return;
    try {
      await _player.play(AssetSource('sounds/level_up.mp3'));
    } catch (e) {
      // Silently fail if sound file not found
    }
  }

  /// Play countdown tick sound
  static Future<void> tick() async {
    if (!_soundEnabled) return;
    try {
      await _player.play(AssetSource('sounds/tick.mp3'));
    } catch (e) {
      // Silently fail if sound file not found
    }
  }

  /// Play game over / whistle sound
  static Future<void> whistle() async {
    if (!_soundEnabled) return;
    try {
      await _player.play(AssetSource('sounds/whistle.mp3'));
    } catch (e) {
      // Silently fail if sound file not found
    }
  }

  /// Dispose resources
  static Future<void> dispose() async {
    await _player.dispose();
  }
}
