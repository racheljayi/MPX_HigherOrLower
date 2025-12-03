import 'package:flutter/foundation.dart';
import '../models/game_state.dart';
import '../models/song.dart';
import '../services/spotify_service.dart';
import '../services/local_storage_service.dart';

/// ViewModel for managing game logic and state
class GameViewModel extends ChangeNotifier {
  final SpotifyService _spotifyService;
  final LocalStorageService _localStorageService;
  GameState _state = GameState();

  // Track used song IDs to avoid repetition
  final List<String> _usedSongIds = [];

  GameViewModel(this._spotifyService, this._localStorageService) {
    _loadLocalHighScore();
  }

  /// Load local high score on init
  Future<void> _loadLocalHighScore() async {
    final highScore = await _localStorageService.getLocalHighScore();
    _updateState(_state.copyWith(highScore: highScore));
  }

  GameState get state => _state;

  /// Start a new game
  Future<void> startGame() async {
    _updateState(_state.copyWith(
      status: GameStatus.loading,
      currentScore: 0,
      isRevealed: false,
    ));

    _usedSongIds.clear();

    try {
      final songs = await _spotifyService.getTwoRandomSongs();
      _usedSongIds.add(songs['left']!.id);
      _usedSongIds.add(songs['right']!.id);

      _updateState(_state.copyWith(
        status: GameStatus.playing,
        leftSong: songs['left'],
        rightSong: songs['right'],
        isRevealed: false,
      ));
    } catch (e) {
      _updateState(_state.copyWith(
        status: GameStatus.error,
        errorMessage: 'Failed to load songs: $e',
      ));
    }
  }

  /// User makes a guess (true = left has more, false = right has more)
  Future<void> makeGuess(bool guessLeft) async {
    if (_state.status != GameStatus.playing || _state.isRevealed) {
      return;
    }

    final leftSong = _state.leftSong!;
    final rightSong = _state.rightSong!;

    final leftHasMore = leftSong.streamCount >= rightSong.streamCount;
    final isCorrect = guessLeft == leftHasMore;

    // Reveal the answer
    _updateState(_state.copyWith(isRevealed: true));

    // Wait a bit to show the reveal animation
    await Future.delayed(const Duration(milliseconds: 1500));

    if (isCorrect) {
      // Correct guess - increment score and load next song
      await _loadNextRound();
    } else {
      // Wrong guess - game over
      await _handleGameOver();
    }
  }

  /// Handle game over and save high score
  Future<void> _handleGameOver() async {
    final currentScore = _state.currentScore;

    // Update local high score if needed
    await _localStorageService.updateLocalHighScore(currentScore);

    // Get updated high score
    final highScore = await _localStorageService.getLocalHighScore();

    _updateState(_state.copyWith(
      status: GameStatus.gameOver,
      highScore: highScore,
    ));
  }

  /// Load the next round after a correct guess
  /// ALWAYS moves right song to left, new song comes in from right
  Future<void> _loadNextRound() async {
    try {
      // Right song ALWAYS becomes the new left song
      final newLeftSong = _state.rightSong!;

      // Get a new song for the right side
      final nextSong = await _spotifyService.getNextSong(_usedSongIds);
      _usedSongIds.add(nextSong.id);

      // Right becomes left, new song on right
      _updateState(_state.copyWith(
        leftSong: newLeftSong,
        rightSong: nextSong,
        currentScore: _state.currentScore + 1,
        isRevealed: false,
      ));
    } catch (e) {
      _updateState(_state.copyWith(
        status: GameStatus.error,
        errorMessage: 'Failed to load next song: $e',
      ));
    }
  }

  /// Reset game to initial state
  void resetGame() {
    _updateState(GameState(highScore: _state.highScore));
    _usedSongIds.clear();
  }

  /// Update state and notify listeners
  void _updateState(GameState newState) {
    _state = newState;
    notifyListeners();
  }

  /// Retry after error
  Future<void> retry() async {
    await startGame();
  }
}
