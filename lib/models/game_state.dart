import 'song.dart';

/// Enum representing the current state of the game
enum GameStatus {
  initial,
  loading,
  playing,
  gameOver,
  error,
}

/// Model representing the current state of the game
class GameState {
  final GameStatus status;
  final Song? leftSong;
  final Song? rightSong;
  final int currentScore;
  final int highScore;
  final String? errorMessage;
  final bool isRevealed; // Whether the stream count is revealed

  GameState({
    this.status = GameStatus.initial,
    this.leftSong,
    this.rightSong,
    this.currentScore = 0,
    this.highScore = 0,
    this.errorMessage,
    this.isRevealed = false,
  });

  /// Create a copy of the current state with optional modifications
  GameState copyWith({
    GameStatus? status,
    Song? leftSong,
    Song? rightSong,
    int? currentScore,
    int? highScore,
    String? errorMessage,
    bool? isRevealed,
  }) {
    return GameState(
      status: status ?? this.status,
      leftSong: leftSong ?? this.leftSong,
      rightSong: rightSong ?? this.rightSong,
      currentScore: currentScore ?? this.currentScore,
      highScore: highScore ?? this.highScore,
      errorMessage: errorMessage ?? this.errorMessage,
      isRevealed: isRevealed ?? this.isRevealed,
    );
  }

  /// Check if both songs are loaded and ready to play
  bool get isReady => leftSong != null && rightSong != null;

  @override
  String toString() {
    return 'GameState(status: $status, score: $currentScore, isRevealed: $isRevealed)';
  }
}
