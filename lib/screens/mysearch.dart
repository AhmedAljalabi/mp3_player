import 'package:flutter/material.dart';
import 'home.dart';
import 'favorites.dart';
import 'equalizer.dart';
import 'package:mp3_player/screens/playerscreen.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:async';

class My_Search extends StatefulWidget {
  const My_Search({super.key});

  @override
  State<My_Search> createState() => _My_SearchState();
}

class _My_SearchState extends State<My_Search> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
          Navigator.pushNamed(context, '/');         
           },
        ),

        title: const Text('Search'),
        backgroundColor:
            Colors.black, // Themed color similar to your inspirations
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Text(
          'Search Feature is Coming Soon!',
          style: TextStyle(fontSize: 18, color: Colors.grey),
        ),
      ),
    );
  }
}