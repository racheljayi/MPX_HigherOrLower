import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/song.dart';

/// Service for interacting with the Spotify Web API
class SpotifyService {
  // Read credentials from environment variables
  static String get clientId => dotenv.env['SPOTIFY_CLIENT_ID'] ?? '';
  static String get clientSecret => dotenv.env['SPOTIFY_CLIENT_SECRET'] ?? '';

  String? _accessToken;
  DateTime? _tokenExpiry;

  // Popular search queries to get songs
  static const List<String> popularGenres = [
    'pop',
    'rock',
    'hip hop',
    'electronic',
    'indie',
  ];

  /// Get access token using client credentials flow
  Future<String> _getAccessToken() async {
    // Check if token is still valid
    if (_accessToken != null &&
        _tokenExpiry != null &&
        DateTime.now().isBefore(_tokenExpiry!)) {
      return _accessToken!;
    }

    final credentials = base64Encode(utf8.encode('$clientId:$clientSecret'));

    final response = await http.post(
      Uri.parse('https://accounts.spotify.com/api/token'),
      headers: {
        'Authorization': 'Basic $credentials',
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: {'grant_type': 'client_credentials'},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      _accessToken = data['access_token'];
      final expiresIn = data['expires_in'] ?? 3600;
      _tokenExpiry = DateTime.now().add(Duration(seconds: expiresIn));
      return _accessToken!;
    } else {
      throw Exception('Failed to get access token: ${response.statusCode}');
    }
  }

  /// Search for popular songs using Spotify search API
  Future<List<Song>> searchPopularSongs({int limit = 50}) async {
    final token = await _getAccessToken();

    // Pick a random search term for variety
    final searchTerms = ['a', 'the', 'love', 'you', 'me', 'we'];
    final searchTerm = searchTerms[Random().nextInt(searchTerms.length)];

    // Search for popular songs
    final response = await http.get(
      Uri.parse(
        'https://api.spotify.com/v1/search?q=$searchTerm&type=track&limit=$limit'
      ),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final items = data['tracks']['items'] as List;

      // Filter out null items and return songs
      return items
          .where((item) => item != null)
          .map((item) => Song.fromJson(item))
          .toList();
    } else {
      throw Exception('Failed to search songs: ${response.statusCode}');
    }
  }

  /// Get random songs from search
  Future<List<Song>> getRandomSongs({int count = 10}) async {
    try {
      final songs = await searchPopularSongs(limit: 50);

      if (songs.isEmpty) {
        throw Exception('No songs found');
      }

      // Shuffle and return requested count
      songs.shuffle();
      return songs.take(count).toList();
    } catch (e) {
      throw Exception('Failed to get random songs: $e');
    }
  }

  /// Get two different random songs for the game
  Future<Map<String, Song>> getTwoRandomSongs() async {
    final songs = await getRandomSongs(count: 50);

    if (songs.length < 2) {
      throw Exception('Not enough songs available');
    }

    // Ensure we get two different songs
    songs.shuffle();
    return {
      'left': songs[0],
      'right': songs[1],
    };
  }

  /// Get a single random song (for replacing after correct guess)
  Future<Song> getNextSong(List<String> excludeIds) async {
    final songs = await getRandomSongs(count: 50);

    // Filter out already used songs
    final availableSongs = songs.where((song) => !excludeIds.contains(song.id)).toList();

    if (availableSongs.isEmpty) {
      // If all songs are used, just pick a random one
      return songs[Random().nextInt(songs.length)];
    }

    return availableSongs[Random().nextInt(availableSongs.length)];
  }
}
