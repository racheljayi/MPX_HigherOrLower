# MPX Higher or Lower

A Flutter web game where players guess which song has a higher Spotify popularity score.

<!-- TODO: Add app screenshots/GIFs here -->

## App Pitch

Like the "The Higher Lower Game," Spotify Higher or Lower challenges players to compare two songs and guess which one has a higher popularity score on Spotify. Test your modern music knowledge and win bragging rights!

## API Used

### Spotify Web API

<!-- TODO: Might want to double check this -->
- **Authentication**: Client Credentials OAuth 2.0 flow
- **Endpoint**: `https://api.spotify.com/v1/search`
- **Data Retrieved**:
  - Song name and ID
  - Artist name
  - Album name and artwork
  - Popularity score (0-100)

**Note**: The app uses Spotify's "popularity" metric (0-100) as a proxy for stream counts, since actual stream counts are not exposed via the public API.

## MVVM Architecture

<!-- TODO: Add an excalidraw -->

## Advanced Features

### 1. Animations

- Card Flip Animation
  - Animates from front (question mark) to back (popularity score)
- Slide Transition
  - Right song slides to become left song after correct guess
  - New song enters from right side
- Scale Animation
  - Game over screen elements scale in with elastic bounce

### 2. Gestures (Required Feature)

- Tap to Guess
  - Tap left or right card to guess
- Long Press for Details
  - Long-press reveals song details without spoiling the answer
  - Shows SnackBar with: song name, artist, album

## Build Instructions

### Prerequisites
1. **Flutter SDK**: Version 3.9.2 or higher
2. **Spotify Developer Account**: Required for API credentials
3. **Code Editor**: VS Code or Android Studio recommended

### Dependencies

Main dependencies (from `pubspec.yaml`):
```yaml
dependencies:
  flutter:
    sdk: flutter
  provider: ^6.1.1              # State management
  http: ^1.1.2                  # API calls
  shared_preferences: ^2.2.2    # Local storage
  cached_network_image: ^3.3.1  # Image caching
  intl: ^0.19.0                 # Formatting utilities
  flutter_dotenv: ^5.1.0        # Environment variables

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^5.0.0
  mockito: ^5.4.4               # Mocking for tests
  build_runner: ^2.4.7          # Code generation
```

### Setup Steps

1. **Clone the repository**
   ```bash
   cd MPX_HigherOrLower
   ```

2. **Create Spotify API credentials**
   - Go to [Spotify Developer Dashboard](https://developer.spotify.com/dashboard)
   - Create a new app
   - Copy your Client ID and Client Secret

3. **Configure environment variables**
   - Make an `.env` and add your Spotify credentials:
     ```
     SPOTIFY_CLIENT_ID=your_client_id_here
     SPOTIFY_CLIENT_SECRET=your_client_secret_here
     ```

4. **Install dependencies**
   ```bash
   flutter pub get
   ```

5. **Run the app**
   ```bash
   # Development mode
   flutter run
   ```
