import 'package:flutter/material.dart';
import 'home.dart';
import 'favorites.dart';
import 'equalizer.dart';
import 'package:mp3_player/screens/playerscreen.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:async';

class Favorites extends StatefulWidget {
  const Favorites({super.key});

  @override
  State<Favorites> createState() => _FavoritesState();
}

class _FavoritesState extends State<Favorites> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
   appBar: AppBar(
        title: const Text('Favorites'),
        backgroundColor: Colors.black, // Themed color similar to your inspirations
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Text(
          'Favorites Management Coming Soon!',
          style: TextStyle(fontSize: 18, color: Colors.grey),
        ),
      ),


    );
  }
}