import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:just_audio_background/just_audio_background.dart'; // Import
import 'package:provider/provider.dart';
import 'package:zenflector/firebase_options.dart';
import 'package:zenflector/screens/auth_screen.dart';
import 'package:zenflector/api/firebase_service.dart';
import 'package:zenflector/providers/audio_player_provider.dart';
import 'package:zenflector/providers/auth_provider.dart';
import 'package:zenflector/providers/favorites_provider.dart';
import 'package:zenflector/providers/genre_provider.dart';
import 'package:zenflector/providers/playlist_provider.dart';
import 'package:zenflector/themes/app_theme.dart';
import 'package:zenflector/providers/app_settings_provider.dart';
import 'package:zenflector/screens/root_screen.dart'; // Import RootScreen

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // Add this line for just_audio_background:
  await JustAudioBackground.init(
    androidNotificationChannelId:
        'zenflector.app', //REPLACE with your package name
    androidNotificationChannelName: 'Audio playback',
    androidNotificationOngoing: true,
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => GenreProvider()),
        ChangeNotifierProvider(
            create: (context) => AudioPlayerProvider()), //Removed dependency
        ChangeNotifierProvider(create: (_) => PlaylistProvider()),
        ChangeNotifierProvider(create: (_) => FavoritesProvider()),
        Provider<FirebaseService>(create: (_) => FirebaseService()),
        ChangeNotifierProvider(create: (_) => AppSettingsProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

// Rest of the code remains same.

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final appSettingsProvider = Provider.of<AppSettingsProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Zenflector',
      theme: appSettingsProvider.isDarkMode
          ? AppTheme.darkTheme
          : AppTheme.lightTheme,
      home: authProvider.isInitialized
          ? (authProvider.currentUser != null
              ? const RootScreen()
              : const AuthScreen())
          : const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            ),
    );
  }
}
