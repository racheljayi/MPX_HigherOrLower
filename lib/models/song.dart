/// Model representing a Spotify song with stream count data
class Song {
  final String id;
  final String name;
  final String artistName;
  final String albumName;
  final String albumImageUrl;
  final int streamCount;
  final String previewUrl;

  Song({
    required this.id,
    required this.name,
    required this.artistName,
    required this.albumName,
    required this.albumImageUrl,
    required this.streamCount,
    this.previewUrl = '',
  });

  /// Factory constructor to create Song from Spotify API JSON
  factory Song.fromJson(Map<String, dynamic> json) {
    return Song(
      id: json['id'] ?? '',
      name: json['name'] ?? 'Unknown',
      artistName: json['artists'] != null && (json['artists'] as List).isNotEmpty
          ? json['artists'][0]['name'] ?? 'Unknown Artist'
          : 'Unknown Artist',
      albumName: json['album']?['name'] ?? 'Unknown Album',
      albumImageUrl: json['album']?['images'] != null &&
              (json['album']['images'] as List).isNotEmpty
          ? json['album']['images'][0]['url'] ?? ''
          : '',
      streamCount: json['popularity'] ?? 0, // We'll use popularity as a proxy
      previewUrl: json['preview_url'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'artistName': artistName,
      'albumName': albumName,
      'albumImageUrl': albumImageUrl,
      'streamCount': streamCount,
      'previewUrl': previewUrl,
    };
  }

  @override
  String toString() {
    return 'Song(id: $id, name: $name, artist: $artistName, streams: $streamCount)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Song && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
