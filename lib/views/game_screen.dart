import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/game_viewmodel.dart';
import '../models/game_state.dart';
import 'widgets/song_card.dart';
import 'game_over_screen.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _slideController;
  late Animation<Offset> _leftSlideAnimation;
  late Animation<Offset> _rightSlideAnimation;

  @override
  void initState() {
    super.initState();
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _leftSlideAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: Offset.zero, 
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeInOut,
    ));

    _rightSlideAnimation = Tween<Offset>(
      begin: Offset.zero, 
      end: Offset.zero,   
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeInOut,
    ));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<GameViewModel>().startGame();
    });
  }

  @override
  void dispose() {
    _slideController.dispose();
    super.dispose();
  }

  void _handleGuess(bool guessLeft, GameViewModel viewModel) async {
    await viewModel.makeGuess(guessLeft);

    if (viewModel.state.status == GameStatus.playing) {
      await _slideController.forward();
      _slideController.reset();
    } else if (viewModel.state.status == GameStatus.gameOver) {
      if (!mounted) return;
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => const GameOverScreen(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Higher or Lower'),
        centerTitle: true,
      ),
      body: Consumer<GameViewModel>(
        builder: (context, viewModel, child) {
          final state = viewModel.state;

          if (state.status == GameStatus.loading) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Loading songs...'),
                ],
              ),
            );
          }

          if (state.status == GameStatus.error) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    state.errorMessage ?? 'An error occurred',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: viewModel.retry,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (state.status == GameStatus.initial) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Spotify Higher or Lower',
                    style: Theme.of(context).textTheme.headlineMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Guess which song has a higher popularity score!',
                    style: Theme.of(context).textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: viewModel.startGame,
                    child: const Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                      child: Text('Start Game', style: TextStyle(fontSize: 18)),
                    ),
                  ),
                ],
              ),
            );
          }

          if (!state.isReady) {
            return const Center(child: CircularProgressIndicator());
          }

          return Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                color: Theme.of(context).colorScheme.primaryContainer,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.star, color: Colors.amber),
                    const SizedBox(width: 8),
                    Text(
                      'Score: ${state.currentScore}',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                  ],
                ),
              ),

              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: SlideTransition(
                          position: _leftSlideAnimation,
                          child: SongCard(
                            song: state.leftSong!,
                            isRevealed: state.isRevealed,
                            onTap: state.isRevealed
                                ? () {}
                                : () => _handleGuess(true, viewModel),
                            onLongPress: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    '🎵 ${state.leftSong!.name}\n'
                                    '🎤 Artist: ${state.leftSong!.artistName}\n'
                                    '💿 Album: ${state.leftSong!.albumName}',
                                  ),
                                  duration: const Duration(seconds: 3),
                                ),
                              );
                            },
                            isLeft: true,
                          ),
                        ),
                      ),

                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'VS',
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineLarge
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context).colorScheme.primary,
                                  ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Which has\na higher\npopularity score?',
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),

                      Expanded(
                        child: SlideTransition(
                          position: _rightSlideAnimation,
                          child: SongCard(
                            song: state.rightSong!,
                            isRevealed: state.isRevealed,
                            onTap: state.isRevealed
                                ? () {}
                                : () => _handleGuess(false, viewModel),
                            onLongPress: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    '🎵 ${state.rightSong!.name}\n'
                                    '🎤 Artist: ${state.rightSong!.artistName}\n'
                                    '💿 Album: ${state.rightSong!.albumName}',
                                  ),
                                  duration: const Duration(seconds: 3),
                                ),
                              );
                            },
                            isLeft: false,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  state.isRevealed
                      ? 'Wait for next song...'
                      : 'Tap a card to guess',
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
