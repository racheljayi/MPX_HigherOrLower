import 'package:flutter_test/flutter_test.dart';
import 'package:spotify_higher_lower/models/song.dart';
import 'package:spotify_higher_lower/models/game_state.dart';
import 'package:spotify_higher_lower/viewmodels/game_viewmodel.dart';
import 'package:spotify_higher_lower/services/spotify_service.dart';
import 'package:spotify_higher_lower/services/local_storage_service.dart';

class MockSpotifyService extends SpotifyService {
  @override
  Future<Map<String, Song>> getTwoRandomSongs() async {
    return {
      'left': Song(
        id: '1',
        name: 'Popular Song',
        artistName: 'Artist 1',
        albumName: 'Album 1',
        albumImageUrl: 'https://example.com/1.jpg',
        streamCount: 100,
      ),
      'right': Song(
        id: '2',
        name: 'Less Popular Song',
        artistName: 'Artist 2',
        albumName: 'Album 2',
        albumImageUrl: 'https://example.com/2.jpg',
        streamCount: 50,
      ),
    };
  }

  @override
  Future<Song> getNextSong(List<String> excludeIds) async {
    return Song(
      id: '3',
      name: 'Next Song',
      artistName: 'Artist 3',
      albumName: 'Album 3',
      albumImageUrl: 'https://example.com/3.jpg',
      streamCount: 75,
    );
  }
}

class MockLocalStorageService extends LocalStorageService {
  @override
  Future<int> getLocalHighScore() async => 0;

  @override
  Future<void> updateLocalHighScore(int score) async {}
}

void main() {
  group('GameViewModel Tests', () {
    late GameViewModel viewModel;
    late MockSpotifyService mockService;
    late MockLocalStorageService mockStorage;

    setUp(() {
      mockService = MockSpotifyService();
      mockStorage = MockLocalStorageService();
      viewModel = GameViewModel(mockService, mockStorage);
    });

    test('Initial state is correct', () {
      expect(viewModel.state.status, GameStatus.initial);
      expect(viewModel.state.currentScore, 0);
      expect(viewModel.state.isRevealed, false);
    });

    test('startGame loads songs and updates state', () async {
      await viewModel.startGame();

      expect(viewModel.state.status, GameStatus.playing);
      expect(viewModel.state.leftSong, isNotNull);
      expect(viewModel.state.rightSong, isNotNull);
      expect(viewModel.state.leftSong!.name, 'Popular Song');
      expect(viewModel.state.rightSong!.name, 'Less Popular Song');
    });

    test('resetGame returns to initial state', () async {
      await viewModel.startGame();
      viewModel.resetGame();

      expect(viewModel.state.status, GameStatus.initial);
      expect(viewModel.state.currentScore, 0);
    });

    test('GameState copyWith works correctly', () {
      final state = GameState();
      final newState = state.copyWith(
        status: GameStatus.playing,
        currentScore: 5,
      );

      expect(newState.status, GameStatus.playing);
      expect(newState.currentScore, 5);
      expect(newState.isRevealed, false); 
    });

    test('Song model equality works', () {
      final song1 = Song(
        id: '1',
        name: 'Song',
        artistName: 'Artist',
        albumName: 'Album',
        albumImageUrl: 'url',
        streamCount: 100,
      );

      final song2 = Song(
        id: '1',
        name: 'Different Name',
        artistName: 'Different Artist',
        albumName: 'Different Album',
        albumImageUrl: 'url',
        streamCount: 200,
      );

      final song3 = Song(
        id: '2',
        name: 'Song',
        artistName: 'Artist',
        albumName: 'Album',
        albumImageUrl: 'url',
        streamCount: 100,
      );

      expect(song1, equals(song2)); 
      expect(song1, isNot(equals(song3))); 
    });
  });
}
