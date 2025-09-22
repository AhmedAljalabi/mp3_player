import 'package:flutter/material.dart';
import 'screens/home.dart';
import 'screens/favorites.dart';
import 'screens/equalizer.dart';
import 'screens/my_notification.dart';

void main() {
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
          
        },
    );
  }
}