import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/unified_theme.dart';
import '../../../shared/models/video_models.dart';

class VideoPlayerWidget extends StatefulWidget {
  final VideoLectureModel video;
  final UserVideoProgressModel? userProgress;
  final Function(int position) onPositionChanged;
  final Function(double percentage) onProgressChanged;
  final Function(VideoQuality quality) onQualityChanged;
  final Function(SubtitleLanguage? language) onSubtitleChanged;
  final Function(double speed) onSpeedChanged;
  final Function(VideoBookmarkModel bookmark) onBookmarkAdded;
  final VoidCallback onFullscreenToggle;

  const VideoPlayerWidget({
    super.key,
    required this.video,
    this.userProgress,
    required this.onPositionChanged,
    required this.onProgressChanged,
    required this.onQualityChanged,
    required this.onSubtitleChanged,
    required this.onSpeedChanged,
    required this.onBookmarkAdded,
    required this.onFullscreenToggle,
  });

  @override
  State<VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> 
    with TickerProviderStateMixin {
  
  // Video control state
  bool _isPlaying = false;
  bool _isBuffering = false;
  bool _isControlsVisible = true;
  bool _isFullscreen = false;
  
  // Playback state
  int _currentPosition = 0; // in seconds
  int _duration = 0;
  double _playbackSpeed = 1.0;
  VideoQuality _selectedQuality = VideoQuality.auto;
  SubtitleLanguage? _selectedSubtitle;
  
  // UI state
  bool _isDragging = false;
  Timer? _hideControlsTimer;
  Timer? _progressTimer;
  late AnimationController _controlsAnimationController;
  late Animation<double> _controlsAnimation;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
    _setupAnimations();
    _startProgressTracking();
  }

  void _initializePlayer() {
    _duration = widget.video.duration;
    _currentPosition = widget.userProgress?.currentPosition ?? 0;
    _playbackSpeed = widget.userProgress?.playbackSpeed ?? 1.0;
    _selectedQuality = widget.userProgress?.selectedQuality ?? VideoQuality.auto;
    _selectedSubtitle = widget.userProgress?.selectedSubtitleLanguage;
  }

  void _setupAnimations() {
    _controlsAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _controlsAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controlsAnimationController,
      curve: Curves.easeInOut,
    ));

    _controlsAnimationController.forward();
    _startHideControlsTimer();
  }

  void _startProgressTracking() {
    _progressTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_isPlaying && !_isDragging) {
        setState(() {
          _currentPosition += 1;
        });
        
        widget.onPositionChanged(_currentPosition);
        widget.onProgressChanged(_currentPosition / _duration);
      }
    });
  }

  void _startHideControlsTimer() {
    _hideControlsTimer?.cancel();
    _hideControlsTimer = Timer(const Duration(seconds: 3), () {
      if (_isPlaying && mounted) {
        _hideControls();
      }
    });
  }

  void _showControls() {
    if (!_isControlsVisible) {
      setState(() {
        _isControlsVisible = true;
      });
      _controlsAnimationController.forward();
    }
    _startHideControlsTimer();
  }

  void _hideControls() {
    if (_isControlsVisible) {
      setState(() {
        _isControlsVisible = false;
      });
      _controlsAnimationController.reverse();
    }
  }

  void _togglePlayPause() {
    setState(() {
      _isPlaying = !_isPlaying;
    });
    
    if (_isPlaying) {
      _startHideControlsTimer();
    } else {
      _hideControlsTimer?.cancel();
    }
    
    // In a real implementation, this would control actual video playback
    print('Video ${_isPlaying ? 'playing' : 'paused'} at position $_currentPosition');
  }

  void _seekTo(int seconds) {
    setState(() {
      _currentPosition = seconds.clamp(0, _duration);
    });
    
    widget.onPositionChanged(_currentPosition);
    widget.onProgressChanged(_currentPosition / _duration);
    
    // In a real implementation, this would seek the actual video
    print('Seeking to $seconds seconds');
  }

  void _changePlaybackSpeed(double speed) {
    setState(() {
      _playbackSpeed = speed;
    });
    
    widget.onSpeedChanged(speed);
    print('Playback speed changed to ${speed}x');
  }

  void _changeQuality(VideoQuality quality) {
    setState(() {
      _selectedQuality = quality;
      _isBuffering = true;
    });
    
    widget.onQualityChanged(quality);
    
    // Simulate buffering
    Timer(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _isBuffering = false;
        });
      }
    });
    
    print('Quality changed to ${quality.displayName}');
  }

  void _toggleSubtitles(SubtitleLanguage? language) {
    setState(() {
      _selectedSubtitle = language;
    });
    
    widget.onSubtitleChanged(language);
    print('Subtitles ${language != null ? 'enabled' : 'disabled'}: ${language?.displayName ?? 'none'}');
  }

  void _addBookmark() {
    showDialog(
      context: context,
      builder: (context) => _BookmarkDialog(
        currentPosition: _currentPosition,
        onBookmarkAdded: (bookmark) {
          widget.onBookmarkAdded(bookmark);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Bookmark added successfully'),
              backgroundColor: Colors.green,
            ),
          );
        },
      ),
    );
  }

  void _toggleFullscreen() {
    setState(() {
      _isFullscreen = !_isFullscreen;
    });
    
    if (_isFullscreen) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
    } else {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);
    }
    
    widget.onFullscreenToggle();
  }

  String _formatTime(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    final secs = seconds % 60;
    
    if (hours > 0) {
      return '$hours:${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
    } else {
      return '$minutes:${secs.toString().padLeft(2, '0')}';
    }
  }

  @override
  void dispose() {
    _controlsAnimationController.dispose();
    _hideControlsTimer?.cancel();
    _progressTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      child: Stack(
        children: [
          // Video display area (simulated)
          _buildVideoDisplay(),
          
          // Loading indicator
          if (_isBuffering)
            const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
          
          // Gesture detector for showing controls
          GestureDetector(
            onTap: _showControls,
            child: Container(
              width: double.infinity,
              height: double.infinity,
              color: Colors.transparent,
            ),
          ),
          
          // Video controls overlay
          AnimatedBuilder(
            animation: _controlsAnimation,
            builder: (context, child) {
              return Opacity(
                opacity: _controlsAnimation.value,
                child: _isControlsVisible ? _buildControls() : const SizedBox.shrink(),
              );
            },
          ),
          
          // Subtitle display
          if (_selectedSubtitle != null)
            _buildSubtitleDisplay(),
        ],
      ),
    );
  }

  Widget _buildVideoDisplay() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.blue.shade900,
            Colors.purple.shade900,
            Colors.indigo.shade900,
          ],
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _isPlaying ? Icons.play_arrow : Icons.pause,
            size: 100,
            color: Colors.white.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            widget.video.title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Quality: ${_selectedQuality.displayName}',
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 14,
            ),
          ),
          if (_selectedSubtitle != null)
            Text(
              'Subtitles: ${_selectedSubtitle!.displayName}',
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 14,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildControls() {
    return Column(
      children: [
        // Top controls
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withOpacity(0.7),
                Colors.transparent,
              ],
            ),
          ),
          child: Row(
            children: [
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back, color: Colors.white),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.video.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      'by ${widget.video.instructor}',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: _addBookmark,
                icon: const Icon(Icons.bookmark_add, color: Colors.white),
              ),
              IconButton(
                onPressed: _toggleFullscreen,
                icon: Icon(
                  _isFullscreen ? Icons.fullscreen_exit : Icons.fullscreen,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
        
        const Spacer(),
        
        // Center play/pause button
        GestureDetector(
          onTap: _togglePlayPause,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.5),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _isPlaying ? Icons.pause : Icons.play_arrow,
              size: 50,
              color: Colors.white,
            ),
          ),
        ),
        
        const Spacer(),
        
        // Bottom controls
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: [
                Colors.black.withOpacity(0.8),
                Colors.transparent,
              ],
            ),
          ),
          child: Column(
            children: [
              // Progress bar
              Row(
                children: [
                  Text(
                    _formatTime(_currentPosition),
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                  Expanded(
                    child: Slider(
                      value: _currentPosition.toDouble(),
                      min: 0.0,
                      max: _duration.toDouble(),
                      activeColor: UnifiedTheme.primaryColor,
                      inactiveColor: Colors.white.withOpacity(0.3),
                      onChanged: (value) {
                        setState(() {
                          _isDragging = true;
                          _currentPosition = value.toInt();
                        });
                      },
                      onChangeEnd: (value) {
                        setState(() {
                          _isDragging = false;
                        });
                        _seekTo(value.toInt());
                      },
                    ),
                  ),
                  Text(
                    _formatTime(_duration),
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ],
              ),
              
              const SizedBox(height: 8),
              
              // Control buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Rewind 10 seconds
                  IconButton(
                    onPressed: () => _seekTo(_currentPosition - 10),
                    icon: const Icon(Icons.replay_10, color: Colors.white),
                  ),
                  
                  // Play/Pause
                  IconButton(
                    onPressed: _togglePlayPause,
                    icon: Icon(
                      _isPlaying ? Icons.pause : Icons.play_arrow,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                  
                  // Forward 10 seconds
                  IconButton(
                    onPressed: () => _seekTo(_currentPosition + 10),
                    icon: const Icon(Icons.forward_10, color: Colors.white),
                  ),
                  
                  // Speed control
                  PopupMenuButton<double>(
                    icon: const Icon(Icons.speed, color: Colors.white),
                    onSelected: _changePlaybackSpeed,
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 0.5,
                        child: Text('0.5x', style: TextStyle(
                          fontWeight: _playbackSpeed == 0.5 ? FontWeight.bold : FontWeight.normal,
                        )),
                      ),
                      PopupMenuItem(
                        value: 0.75,
                        child: Text('0.75x', style: TextStyle(
                          fontWeight: _playbackSpeed == 0.75 ? FontWeight.bold : FontWeight.normal,
                        )),
                      ),
                      PopupMenuItem(
                        value: 1.0,
                        child: Text('1.0x', style: TextStyle(
                          fontWeight: _playbackSpeed == 1.0 ? FontWeight.bold : FontWeight.normal,
                        )),
                      ),
                      PopupMenuItem(
                        value: 1.25,
                        child: Text('1.25x', style: TextStyle(
                          fontWeight: _playbackSpeed == 1.25 ? FontWeight.bold : FontWeight.normal,
                        )),
                      ),
                      PopupMenuItem(
                        value: 1.5,
                        child: Text('1.5x', style: TextStyle(
                          fontWeight: _playbackSpeed == 1.5 ? FontWeight.bold : FontWeight.normal,
                        )),
                      ),
                      PopupMenuItem(
                        value: 2.0,
                        child: Text('2.0x', style: TextStyle(
                          fontWeight: _playbackSpeed == 2.0 ? FontWeight.bold : FontWeight.normal,
                        )),
                      ),
                    ],
                  ),
                  
                  // Quality selection
                  PopupMenuButton<VideoQuality>(
                    icon: const Icon(Icons.hd, color: Colors.white),
                    onSelected: _changeQuality,
                    itemBuilder: (context) => VideoQuality.values.map((quality) {
                      return PopupMenuItem(
                        value: quality,
                        child: Row(
                          children: [
                            if (_selectedQuality == quality)
                              const Icon(Icons.check, size: 16),
                            const SizedBox(width: 8),
                            Text(quality.displayName),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                  
                  // Subtitle selection
                  PopupMenuButton<SubtitleLanguage?>(
                    icon: const Icon(Icons.subtitles, color: Colors.white),
                    onSelected: _toggleSubtitles,
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: null,
                        child: Row(
                          children: [
                            if (_selectedSubtitle == null)
                              const Icon(Icons.check, size: 16),
                            const SizedBox(width: 8),
                            const Text('Off'),
                          ],
                        ),
                      ),
                      ...widget.video.subtitles.map((subtitle) {
                        return PopupMenuItem(
                          value: subtitle.language,
                          child: Row(
                            children: [
                              if (_selectedSubtitle == subtitle.language)
                                const Icon(Icons.check, size: 16),
                              const SizedBox(width: 8),
                              Text(subtitle.language.displayName),
                            ],
                          ),
                        );
                      }),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSubtitleDisplay() {
    return Positioned(
      bottom: 120,
      left: 16,
      right: 16,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.8),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          'Sample subtitle text at ${_formatTime(_currentPosition)}',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

class _BookmarkDialog extends StatefulWidget {
  final int currentPosition;
  final Function(VideoBookmarkModel) onBookmarkAdded;

  const _BookmarkDialog({
    required this.currentPosition,
    required this.onBookmarkAdded,
  });

  @override
  State<_BookmarkDialog> createState() => _BookmarkDialogState();
}

class _BookmarkDialogState extends State<_BookmarkDialog> {
  final _titleController = TextEditingController();
  final _noteController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final minutes = widget.currentPosition ~/ 60;
    final seconds = widget.currentPosition % 60;
    _titleController.text = 'Bookmark at $minutes:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Bookmark'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _titleController,
            decoration: const InputDecoration(
              labelText: 'Bookmark Title',
              border: OutlineInputBorder(),
            ),
            maxLength: 100,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _noteController,
            decoration: const InputDecoration(
              labelText: 'Note (optional)',
              border: OutlineInputBorder(),
              hintText: 'Add a note about this moment...',
            ),
            maxLines: 3,
            maxLength: 500,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_titleController.text.isNotEmpty) {
              final bookmark = VideoBookmarkModel(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                timestamp: widget.currentPosition,
                title: _titleController.text,
                note: _noteController.text,
                createdAt: DateTime.now(),
              );
              
              widget.onBookmarkAdded(bookmark);
              Navigator.pop(context);
            }
          },
          child: const Text('Add Bookmark'),
        ),
      ],
    );
  }
}