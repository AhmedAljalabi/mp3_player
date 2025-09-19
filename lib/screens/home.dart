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
            Text("Ahmed Aljalabi", style: TextStyle(fontSize: 16,color: Colors.blue, fontWeight: FontWeight.bold)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none, color: Colors.white70),
            onPressed: () {},
          ),
        ],
      ),
      body: _buildBody(),
      bottomNavigationBar: Container(
        margin: const EdgeInsets.fromLTRB(30, 0, 30, 20),
        height: 55,
        decoration: BoxDecoration(
          color: Colors.grey.shade800.withOpacity(.6),
          borderRadius: BorderRadius.circular(50),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              icon: const Icon(Icons.home_filled, color: Colors.white),
              onPressed: () {},
            ),
            IconButton(
              icon: const Icon(Icons.search, color: Colors.white70),
              onPressed: () {},
            ),
            IconButton(
              icon: const Icon(Icons.favorite_border, color: Colors.white70),
              onPressed: () {},
            ),
            IconButton(
              icon: const Icon(Icons.person_outline, color: Colors.white70),
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (!_hasPermission) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Permission needed to access music files', 
                style: TextStyle(color: Colors.white70)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _checkAndRequestPermissions,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade700,
                foregroundColor: Colors.white,
              ),
              child: const Text('Grant Permission'),
            ),
          ],
        ),
      );
    }
    
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.blue)),
      );
    }
    
    if (_songs.isEmpty) {
      return const Center(
        child: Text('No songs found', style: TextStyle(color: Colors.white70)),
      );
    }
    
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 0.8,
      ),
      itemCount: _songs.length,
      itemBuilder: (context, index) {
        final song = _songs[index];
        return GestureDetector(
           onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => PlayerScreen(
                            songs: _songs,
                             initialIndex: index,
                
                ),
           
              ),
            );
          },


           child: Container(

          decoration: BoxDecoration(
            color: Colors.grey.shade800.withOpacity(.6),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.all(12),
                height: 120,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  image: DecorationImage(
                    image: const AssetImage('assets/A (3).jpg'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Text(
                  song.title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Text(
                  song.artist ?? 'Unknown Artist',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade400,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.favorite_border, color: Colors.white70, size: 20),
                onPressed: () {},
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
