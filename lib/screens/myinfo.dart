import 'package:flutter/material.dart';
import 'home.dart';
import 'favorites.dart';
import 'equalizer.dart';
import 'package:mp3_player/screens/playerscreen.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:async';

class My_Info extends StatefulWidget {
  const My_Info({super.key});

  @override
  State<My_Info> createState() => _My_InfoState();
}

class _My_InfoState extends State<My_Info> {
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

        title: const Text('My Info'),
        backgroundColor:
            Colors.black, // Themed color similar to your inspirations
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Text(
          'My Information are Coming Soon!',
          style: TextStyle(fontSize: 18, color: Colors.grey),
        ),
      ),
    );
  }
}