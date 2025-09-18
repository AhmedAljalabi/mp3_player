import 'package:flutter/material.dart';
import 'package:mp3_player/screens/playerscreen.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:async';  



class SongListScreen extends StatefulWidget {
  const SongListScreen({super.key});

  @override
  State<SongListScreen> createState() => _SongListScreenState();
}

class _SongListScreenState extends State<SongListScreen> {
  final OnAudioQuery _audioQuery = OnAudioQuery();
  List<SongModel> _songs = [];
  bool _hasPermission = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkAndRequestPermissions();
  }

  Future<void> _checkAndRequestPermissions() async {
    // Check and request permission
    PermissionStatus status = await Permission.storage.request();
    if (status != PermissionStatus.granted) {
      status = await Permission.mediaLibrary.request();
    }
    
    setState(() {
      _hasPermission = status == PermissionStatus.granted;
    });
    
    if (_hasPermission) {
      _fetchSongs();
    } else {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _fetchSongs() async {
    try {
      List<SongModel> songs = await _audioQuery.querySongs(
        sortType: SongSortType.DISPLAY_NAME,
        orderType: OrderType.ASC_OR_SMALLER,
        ignoreCase: true,
      );
      
      // Filter only audio files
      songs = songs.where((song) => song.fileExtension == 'mp3' || 
                                  song.fileExtension == 'm4a' || 
                                  song.fileExtension == 'aac').toList();
      
      setState(() {
        _songs = songs;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
         leading: const Padding(
          padding: EdgeInsets.only(left: 16.0),
          child: CircleAvatar(
            backgroundImage: AssetImage('assets/A (6).jpg'),
          ),
        ),
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Good Morning!", style: TextStyle(fontSize: 12, color: Colors.green)),
            Text("Ahmed Aljalabi", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blue)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchSongs,
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (!_hasPermission) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Permission needed to access music files'),
            ElevatedButton(
              onPressed: _checkAndRequestPermissions,
              child: const Text('Grant Permission'),
            ),
          ],
        ),
      );
    }
    
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    
    if (_songs.isEmpty) {
      return const Center(child: Text('No songs found'));
    }
    
    return ListView.builder(
      itemCount: _songs.length,
      itemBuilder: (context, index) {
        final song = _songs[index];
        return ListTile(
          leading: QueryArtworkWidget(
            id: song.id,
            type: ArtworkType.AUDIO,
            nullArtworkWidget: const Icon(Icons.music_note, size: 48),
          ),
          title: Text(
            song.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Text(
            song.artist ?? 'Unknown Artist',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          trailing: Text(
            '${(song.duration ?? 0) ~/ 60000}:${((song.duration ?? 0) % 60000 ~/ 1000).toString().padLeft(2, '0')}',
          ),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PlayerScreen(
                  songs: _songs,
                  initialIndex: index,
                ),
              ),
            );
          },
        );
      },
    );
  }
}