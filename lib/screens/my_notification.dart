import 'package:flutter/material.dart';
import 'home.dart';
import 'favorites.dart';
import 'equalizer.dart';
import 'package:mp3_player/screens/playerscreen.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:async';

class My_Notification extends StatefulWidget {
  const My_Notification({super.key});

  @override
  State<My_Notification> createState() => _My_NotificationState();
}

class _My_NotificationState extends State<My_Notification> {
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

        title: const Text('Notifications'),
        backgroundColor:
            Colors.black, // Themed color similar to your inspirations
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Text(
          'NO Notification Found!',
          style: TextStyle(fontSize: 18, color: Colors.grey),
        ),
      ),
    );
  }
}
