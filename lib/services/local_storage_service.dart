import 'package:shared_preferences/shared_preferences.dart';

/// Service for managing local high score storage
class LocalStorageService {
  static const String _localHighScoreKey = 'local_high_score';

  /// Get local high score
  Future<int> getLocalHighScore() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_localHighScoreKey) ?? 0;
  }

  /// Update local high score if new score is higher
  Future<void> updateLocalHighScore(int score) async {
    final prefs = await SharedPreferences.getInstance();
    final currentHigh = await getLocalHighScore();

    if (score > currentHigh) {
      await prefs.setInt(_localHighScoreKey, score);
    }
  }

  /// Clear high score (for testing)
  Future<void> clearHighScore() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_localHighScoreKey);
  }
}
