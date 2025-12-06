import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:spotify_higher_lower/models/song.dart';
import 'package:spotify_higher_lower/models/game_state.dart';
import 'package:spotify_higher_lower/viewmodels/game_viewmodel.dart';
import 'package:spotify_higher_lower/services/spotify_service.dart';
import 'package:spotify_higher_lower/views/widgets/song_card.dart';

void main() {
  group('Widget Tests', () {
    testWidgets('SongCard displays song information', (WidgetTester tester) async {
      final testSong = Song(
        id: '1',
        name: 'Test Song',
        artistName: 'Test Artist',
        albumName: 'Test Album',
        albumImageUrl: 'https://example.com/image.jpg',
        streamCount: 1000,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SongCard(
              song: testSong,
              isRevealed: false,
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.text('Test Song'), findsOneWidget);
      expect(find.text('Hold for more info'), findsOneWidget);
    });

    testWidgets('SongCard shows help icon when not revealed', (WidgetTester tester) async {
      final testSong = Song(
        id: '1',
        name: 'Test Song',
        artistName: 'Test Artist',
        albumName: 'Test Album',
        albumImageUrl: 'https://example.com/image.jpg',
        streamCount: 1000,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SongCard(
              song: testSong,
              isRevealed: false,
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.text('Hold for more info'), findsOneWidget);
    });

    testWidgets('GameState initial state is correct', (WidgetTester tester) async {
      final gameState = GameState();

      expect(gameState.status, GameStatus.initial);
      expect(gameState.currentScore, 0);
      expect(gameState.isRevealed, false);
      expect(gameState.isReady, false);
    });
  });
}
