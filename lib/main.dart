import 'package:flutter/material.dart';
import 'package:audio_service/audio_service.dart';
import 'audio_handler.dart';
import 'screens/home.dart';
import 'screens/favorites.dart';
import 'screens/equalizer.dart';
import 'screens/my_notification.dart';
import 'screens/myinfo.dart';
import 'screens/mysearch.dart';

late final AudioHandler audioHandler;
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  audioHandler = await AudioService.init(
    builder: () => MyAudioHandler(),
    config: const AudioServiceConfig(
      androidNotificationChannelId: 'com.mycompany.myapp.channel.audio',
      androidNotificationChannelName: 'Audio playback',
      androidNotificationOngoing: true,
    ),
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AJ Player',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Colors.black,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.black,
          elevation: 0,
          iconTheme: IconThemeData(color: Colors.white),
        ),
      ),
       initialRoute: '/',
        routes: {
          '/': (context) => SongListScreen(),
          '/manage_favorites': (context) => Favorites(),
          '/equalizer': (context) => Equalizer(),
          '/my_notification': (context) => My_Notification(),
          '/my_search': (context) => My_Search(),
          '/my_info': (context) => My_Info(),
          
        },
    );
  }
}