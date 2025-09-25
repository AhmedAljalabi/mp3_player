import 'package:flutter/material.dart';
import 'package:mp3_player/screens/playerscreen.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:async';
import 'package:mp3_player/main.dart'; // Import main.dart to get audioHandler
import 'package:audio_service/audio_service.dart';



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

      songs = songs
          .where((song) =>
              song.fileExtension == 'mp3' ||
              song.fileExtension == 'm4a' ||
              song.fileExtension == 'aac')
          .toList();

      setState(() {
        _songs = songs;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  void _playSong(int index) {
    // Create a list of MediaItem from your songs
    final playlist = _songs.map((song) => MediaItem(
      id: song.id.toString(),
      title: song.title,
      artist: song.artist ?? 'Unknown Artist',
      duration: Duration(milliseconds: song.duration ?? 0),
      extras: {'url': song.uri!},
    )).toList();

    // Update the queue and start playback
    audioHandler.updateQueue(playlist);
    audioHandler.skipToQueueItem(index);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PlayerScreen(
          songs: _songs,
          initialIndex: index,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: 
        const Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

           CircleAvatar(
            backgroundImage: AssetImage('assets/A (3).jpg'),
            ),

            Column(
            crossAxisAlignment: CrossAxisAlignment.start,
             children: [
            Text("Welcome!",
                style: TextStyle(fontSize: 18, color: Colors.green)
                ),
            Text("Ahmed Aljalabi",
                style: TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold)
                ),
             ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none, color: Color.fromRGBO(255, 183, 77, 1)),
            onPressed: () {
                Navigator.pop(context); // This closes the drawer
                Navigator.pushNamed(context, '/my_notification');

            },
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.black,
                image: DecorationImage(
                  image: AssetImage('assets/A (6).jpg'),
                  fit: BoxFit.cover,
                ),
              ),
              child: Center(
                child: Text('',
                    style: TextStyle(color: Colors.black, fontSize: 24)),
              ),
            ),

            ListTile(
              leading: const Icon(Icons.favorite, color: Colors.red),
              title: Text('Favorite Songs'),
              onTap: () {
                Navigator.pop(context); // This closes the drawer
                Navigator.pushNamed(context, '/manage_favorites');
              },
            ),

            ListTile(
              leading: Icon(Icons.equalizer, color: Colors.black),
              title: Text('Equalizer'),
              onTap: () {
                Navigator.pop(context); // This closes the drawer
                Navigator.pushNamed(context, '/equalizer');
              },
            ),

            ListTile(
              leading: Icon(Icons.notifications, color: Colors.orange[300]),
              title: Text('Notifications'),
              onTap: () {
                Navigator.pop(context); // This closes the drawer
                Navigator.pushNamed(context, '/my_notification');
              },
            ),
            ListTile(
              leading: Icon(Icons.person, color: Colors.blue),
              title: Text('Information'),
              onTap: () {
                Navigator.pop(context); // This closes the drawer
                Navigator.pushNamed(context, '/my_info');
              },
            ),
          ],
        ),
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
              onPressed: () {
                Navigator.pushNamed(context, '/'); 
              },
            ),
            IconButton(
              icon: const Icon(Icons.search, color: Colors.white70),
              onPressed: () {
              Navigator.pushNamed(context, '/my_search');

              },
            ),
            IconButton(
              icon: const Icon(Icons.favorite_border, color: Colors.white70),
              onPressed: () {
                Navigator.pushNamed(context, '/manage_favorites'); 
              },
            ),
            IconButton(
              icon: const Icon(Icons.person_outline, color: Colors.white70),
              onPressed: () {
                Navigator.pushNamed(context, '/my_info');
              },
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
        child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.blue)),
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
          onTap: () => _playSong(index),
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
                  ),
                  child: QueryArtworkWidget(
                    id: song.id,
                    type: ArtworkType.AUDIO,
                    artworkBorder: BorderRadius.circular(12),
                    nullArtworkWidget: Image.asset(
                      'placeholder.jpg',
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
                  icon: const Icon(Icons.favorite_border,
                      color: Colors.white70, size: 20),
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
