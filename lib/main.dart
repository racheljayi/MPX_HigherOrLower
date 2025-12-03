import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'services/spotify_service.dart';
import 'services/local_storage_service.dart';
import 'viewmodels/game_viewmodel.dart';
import 'views/game_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  try {
    await dotenv.load(fileName: '.env');
  } catch (e) {
    debugPrint('Error loading .env file: $e');
    debugPrint('Make sure to create a .env file with your Spotify credentials');
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Services
        Provider<SpotifyService>(
          create: (_) => SpotifyService(),
        ),
        Provider<LocalStorageService>(
          create: (_) => LocalStorageService(),
        ),

        // ViewModels
        ChangeNotifierProvider<GameViewModel>(
          create: (context) => GameViewModel(
            context.read<SpotifyService>(),
            context.read<LocalStorageService>(),
          ),
        ),
      ],
      child: MaterialApp(
        title: 'Spotify Higher or Lower',
        debugShowCheckedModeBanner: false,

        // Theme configuration
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF1DB954), // Spotify green
            brightness: Brightness.light,
          ),
          cardTheme: CardThemeData(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          appBarTheme: const AppBarTheme(
            centerTitle: true,
            elevation: 2,
          ),
        ),

        darkTheme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF1DB954), // Spotify green
            brightness: Brightness.dark,
          ),
          cardTheme: CardThemeData(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          appBarTheme: const AppBarTheme(
            centerTitle: true,
            elevation: 2,
          ),
        ),

        themeMode: ThemeMode.system,

        // Routes
        home: const GameScreen(),

        // Accessibility
        builder: (context, child) {
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(
              // Ensure text scaling is supported
              textScaler: MediaQuery.of(context).textScaler.clamp(
                    minScaleFactor: 0.8,
                    maxScaleFactor: 2.0,
                  ),
            ),
            child: child!,
          );
        },
      ),
    );
  }
}
