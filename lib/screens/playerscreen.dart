import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:just_audio/just_audio.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'dart:async';

class PlayerScreen extends StatefulWidget {
  final List<SongModel> songs;
  final int initialIndex;

  const PlayerScreen({
    super.key,
    required this.songs,
    required this.initialIndex,
  });

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  int _currentIndex = 0;
  bool _isPlaying = false;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  StreamSubscription? _positionSubscription;
  StreamSubscription? _stateSubscription;
  Uint8List? _albumArt;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _initPlayer();
  }

  Future<void> _initPlayer() async {
    _positionSubscription = _audioPlayer.positionStream.listen((position) {
      setState(() => _position = position);
    });
    
    _stateSubscription = _audioPlayer.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed) {
        _playNext();
      }
      setState(() {
        _isPlaying = state.playing;
      });
    });

    await _loadSong(widget.songs[_currentIndex]);
  }

  Future<void> _loadSong(SongModel song) async {
    try {
      if (song.uri != null) {
        final audioSource = AudioSource.uri(Uri.parse(song.uri!));
        await _audioPlayer.setAudioSource(audioSource);
        _duration = _audioPlayer.duration ?? Duration.zero;
        await _audioPlayer.play();
        _fetchAlbumArt(song.id);
        setState(() {});
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Song URI is null')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading song: $e')),
      );
    }
  }

  void _playNext() {
    setState(() {
      _currentIndex = (_currentIndex + 1) % widget.songs.length;
    });
    _loadSong(widget.songs[_currentIndex]);
  }

  void _playPrevious() {
    setState(() {
      _currentIndex = (_currentIndex - 1 + widget.songs.length) % widget.songs.length;
    });
    _loadSong(widget.songs[_currentIndex]);
  }

  Future<void> _fetchAlbumArt(int songId) async {
    try {
      final OnAudioQuery audioQuery = OnAudioQuery();
      final art = await audioQuery.queryArtwork(songId, ArtworkType.AUDIO, size: 300);
      setState(() {
        _albumArt = art;
      });
    } catch (e) {
      setState(() {
        _albumArt = null;
      });
    }
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    return '${twoDigits(minutes)}:${twoDigits(seconds)}';
  }

  @override
  void dispose() {
    _positionSubscription?.cancel();
    _stateSubscription?.cancel();
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final song = widget.songs[_currentIndex];
    
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Now Playing', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite_border, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: Container(
                  width: 300,
                  height: 300,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    image: DecorationImage(
                      image: _albumArt != null
                          ? MemoryImage(_albumArt!)
                          : const AssetImage('assets/A (3).jpg') as ImageProvider,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),
            Text(
              song.title,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Text(
              song.artist ?? 'Unknown Artist',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade400,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 30),
            Slider(
              value: _position.inSeconds.toDouble(),
              min: 0,
              max: _duration.inSeconds.toDouble(),
              onChanged: (value) {
                _audioPlayer.seek(Duration(seconds: value.toInt()));
              },
              activeColor: Colors.white,
              inactiveColor: Colors.grey.shade700,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _formatDuration(_position),
                    style: TextStyle(color: Colors.grey.shade400),
                  ),
                  Text(
                    _formatDuration(_duration),
                    style: TextStyle(color: Colors.grey.shade400),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                IconButton(
                  icon: const Icon(Icons.shuffle, color: Colors.white70, size: 28),
                  onPressed: () {},
                ),
                IconButton(
                  icon: const Icon(Icons.skip_previous, color: Colors.white, size: 36),
                  onPressed: _playPrevious,
                ),
                Container(
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                  ),
                  child: IconButton(
                    icon: Icon(
                      _isPlaying ? Icons.pause : Icons.play_arrow,
                      color: Colors.black,
                      size: 36,
                    ),
                    onPressed: () async {
                      if (_isPlaying) {
                        await _audioPlayer.pause();
                      } else {
                        await _audioPlayer.play();
                      }
                    },
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.skip_next, color: Colors.white, size: 36),
                  onPressed: _playNext,
                ),
                IconButton(
                  icon: const Icon(Icons.repeat, color: Colors.white70, size: 28),
                  onPressed: () {},
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}