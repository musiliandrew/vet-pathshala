import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/unified_theme.dart';
import '../../../shared/models/video_models.dart';
import '../../../shared/models/user_model.dart';
import '../widgets/video_player_widget.dart';
import '../widgets/video_chapters_widget.dart';
import '../widgets/video_bookmarks_widget.dart';

class VideoLectureScreen extends StatefulWidget {
  final VideoLectureModel video;
  final UserModel user;
  final UserVideoProgressModel? userProgress;

  const VideoLectureScreen({
    super.key,
    required this.video,
    required this.user,
    this.userProgress,
  });

  @override
  State<VideoLectureScreen> createState() => _VideoLectureScreenState();
}

class _VideoLectureScreenState extends State<VideoLectureScreen>
    with TickerProviderStateMixin {
  
  bool _isFullscreen = false;
  int _currentPosition = 0;
  double _watchedPercentage = 0.0;
  VideoQuality _selectedQuality = VideoQuality.auto;
  SubtitleLanguage? _selectedSubtitle;
  double _playbackSpeed = 1.0;
  
  List<VideoBookmarkModel> _bookmarks = [];
  List<VideoNoteModel> _notes = [];
  
  Timer? _progressSaveTimer;

  @override
  void initState() {
    super.initState();
    _initializeProgress();
    _startProgressSaving();
  }

  void _initializeProgress() {
    if (widget.userProgress != null) {
      _currentPosition = widget.userProgress!.currentPosition;
      _watchedPercentage = widget.userProgress!.watchedPercentage;
      _selectedQuality = widget.userProgress!.selectedQuality;
      _selectedSubtitle = widget.userProgress!.selectedSubtitleLanguage;
      _playbackSpeed = widget.userProgress!.playbackSpeed;
      _bookmarks = widget.userProgress!.bookmarks;
      _notes = widget.userProgress!.notes;
    }
  }

  void _startProgressSaving() {
    _progressSaveTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      _saveProgress();
    });
  }

  void _saveProgress() {
    // In a real implementation, this would call the video service
    print('Saving progress: Position $_currentPosition, Percentage $_watchedPercentage');
  }

  void _onPositionChanged(int position) {
    setState(() {
      _currentPosition = position;
      _watchedPercentage = position / widget.video.duration;
    });
  }

  void _onProgressChanged(double percentage) {
    setState(() {
      _watchedPercentage = percentage;
    });
  }

  void _onQualityChanged(VideoQuality quality) {
    setState(() {
      _selectedQuality = quality;
    });
  }

  void _onSubtitleChanged(SubtitleLanguage? language) {
    setState(() {
      _selectedSubtitle = language;
    });
  }

  void _onSpeedChanged(double speed) {
    setState(() {
      _playbackSpeed = speed;
    });
  }

  void _onBookmarkAdded(VideoBookmarkModel bookmark) {
    setState(() {
      _bookmarks.add(bookmark);
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Bookmark added successfully'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _onBookmarkDeleted(String bookmarkId) {
    setState(() {
      _bookmarks.removeWhere((bookmark) => bookmark.id == bookmarkId);
    });
  }

  void _onNoteAdded(VideoNoteModel note) {
    setState(() {
      _notes.add(note);
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Note added successfully'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _onNoteUpdated(String noteId, String content) {
    setState(() {
      final noteIndex = _notes.indexWhere((note) => note.id == noteId);
      if (noteIndex != -1) {
        _notes[noteIndex] = VideoNoteModel(
          id: _notes[noteIndex].id,
          timestamp: _notes[noteIndex].timestamp,
          content: content,
          createdAt: _notes[noteIndex].createdAt,
          updatedAt: DateTime.now(),
        );
      }
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Note updated successfully'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _onNoteDeleted(String noteId) {
    setState(() {
      _notes.removeWhere((note) => note.id == noteId);
    });
  }

  void _onFullscreenToggle() {
    setState(() {
      _isFullscreen = !_isFullscreen;
    });
  }

  void _showChapters() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => VideoChaptersWidget(
        video: widget.video,
        currentPosition: _currentPosition,
        onChapterTap: (timestamp) {
          setState(() {
            _currentPosition = timestamp;
          });
          Navigator.pop(context);
        },
        onClose: () => Navigator.pop(context),
      ),
    );
  }

  void _showBookmarks() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => VideoBookmarksWidget(
        video: widget.video,
        bookmarks: _bookmarks,
        notes: _notes,
        currentPosition: _currentPosition,
        onBookmarkTap: (timestamp) {
          setState(() {
            _currentPosition = timestamp;
          });
          Navigator.pop(context);
        },
        onBookmarkAdded: _onBookmarkAdded,
        onBookmarkDeleted: _onBookmarkDeleted,
        onNoteAdded: _onNoteAdded,
        onNoteUpdated: _onNoteUpdated,
        onNoteDeleted: _onNoteDeleted,
        onClose: () => Navigator.pop(context),
      ),
    );
  }

  void _showVideoInfo() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _VideoInfoBottomSheet(
        video: widget.video,
        userProgress: UserVideoProgressModel(
          id: '',
          userId: widget.user.id,
          videoId: widget.video.id,
          currentPosition: _currentPosition,
          watchedPercentage: _watchedPercentage,
          isCompleted: _watchedPercentage >= 0.9,
          bookmarks: _bookmarks,
          notes: _notes,
          selectedQuality: _selectedQuality,
          selectedSubtitleLanguage: _selectedSubtitle,
          playbackSpeed: _playbackSpeed,
          totalWatchTime: 0,
          watchCount: 1,
          lastWatchedAt: DateTime.now(),
          createdAt: DateTime.now(),
          watchData: {},
        ),
      ),
    );
  }

  @override
  void dispose() {
    _progressSaveTimer?.cancel();
    _saveProgress(); // Save final progress
    
    // Reset system UI if in fullscreen
    if (_isFullscreen) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);
    }
    
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isFullscreen) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: VideoPlayerWidget(
          video: widget.video,
          userProgress: widget.userProgress,
          onPositionChanged: _onPositionChanged,
          onProgressChanged: _onProgressChanged,
          onQualityChanged: _onQualityChanged,
          onSubtitleChanged: _onSubtitleChanged,
          onSpeedChanged: _onSpeedChanged,
          onBookmarkAdded: _onBookmarkAdded,
          onFullscreenToggle: _onFullscreenToggle,
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        children: [
          // Video player
          AspectRatio(
            aspectRatio: 16 / 9,
            child: VideoPlayerWidget(
              video: widget.video,
              userProgress: widget.userProgress,
              onPositionChanged: _onPositionChanged,
              onProgressChanged: _onProgressChanged,
              onQualityChanged: _onQualityChanged,
              onSubtitleChanged: _onSubtitleChanged,
              onSpeedChanged: _onSpeedChanged,
              onBookmarkAdded: _onBookmarkAdded,
              onFullscreenToggle: _onFullscreenToggle,
            ),
          ),
          
          // Video details and controls
          Expanded(
            child: Container(
              color: Colors.white,
              child: Column(
                children: [
                  // Video info header
                  _buildVideoInfoHeader(),
                  
                  // Action buttons
                  _buildActionButtons(),
                  
                  // Video description and details
                  Expanded(
                    child: _buildVideoDetails(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoInfoHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Progress indicator
          Row(
            children: [
              Expanded(
                child: LinearProgressIndicator(
                  value: _watchedPercentage,
                  backgroundColor: Colors.grey.shade300,
                  valueColor: AlwaysStoppedAnimation<Color>(UnifiedTheme.primaryColor),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '${(_watchedPercentage * 100).toInt()}%',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Title and instructor
          Text(
            widget.video.title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          
          const SizedBox(height: 8),
          
          Row(
            children: [
              CircleAvatar(
                radius: 12,
                backgroundColor: UnifiedTheme.primaryColor,
                child: Text(
                  widget.video.instructor.substring(0, 1).toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              
              const SizedBox(width: 8),
              
              Expanded(
                child: Text(
                  widget.video.instructor,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
              ),
              
              // Video stats
              Row(
                children: [
                  Icon(Icons.visibility, size: 14, color: Colors.grey.shade500),
                  const SizedBox(width: 4),
                  Text(
                    '${widget.video.viewCount}',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                  ),
                  
                  const SizedBox(width: 12),
                  
                  Icon(Icons.star, size: 14, color: Colors.amber),
                  const SizedBox(width: 4),
                  Text(
                    widget.video.rating.toStringAsFixed(1),
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: _showChapters,
              icon: const Icon(Icons.list, size: 18),
              label: Text('Chapters (${widget.video.chapters.length})'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey.shade100,
                foregroundColor: Colors.grey.shade700,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
          
          const SizedBox(width: 8),
          
          Expanded(
            child: ElevatedButton.icon(
              onPressed: _showBookmarks,
              icon: const Icon(Icons.bookmark, size: 18),
              label: Text('Notes (${_bookmarks.length + _notes.length})'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey.shade100,
                foregroundColor: Colors.grey.shade700,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
          
          const SizedBox(width: 8),
          
          ElevatedButton(
            onPressed: _showVideoInfo,
            style: ElevatedButton.styleFrom(
              backgroundColor: UnifiedTheme.primaryColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            child: const Icon(Icons.info, size: 18),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoDetails() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Description
          if (widget.video.description.isNotEmpty) ...[
            const Text(
              'Description',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.video.description,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade700,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
          ],
          
          // Instructor bio
          if (widget.video.instructorBio.isNotEmpty) ...[
            const Text(
              'About the Instructor',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: UnifiedTheme.primaryColor,
                  child: Text(
                    widget.video.instructor.substring(0, 1).toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                
                const SizedBox(width: 12),
                
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.video.instructor,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.video.instructorBio,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade700,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
          ],
          
          // Tags
          if (widget.video.tags.isNotEmpty) ...[
            const Text(
              'Tags',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: widget.video.tags.map((tag) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: UnifiedTheme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    tag,
                    style: TextStyle(
                      fontSize: 12,
                      color: UnifiedTheme.primaryColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
          ],
          
          // Video details
          _buildVideoMetadata(),
        ],
      ),
    );
  }

  Widget _buildVideoMetadata() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Video Details',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          
          _buildMetadataRow('Duration', widget.video.formattedDuration),
          _buildMetadataRow('Category', widget.video.category.name.toUpperCase()),
          _buildMetadataRow('Quality', _selectedQuality.displayName),
          _buildMetadataRow('Subtitles', _selectedSubtitle?.displayName ?? 'Off'),
          _buildMetadataRow('Speed', '${_playbackSpeed}x'),
          _buildMetadataRow('Views', '${widget.video.viewCount}'),
          _buildMetadataRow('Downloads', '${widget.video.downloadCount}'),
          _buildMetadataRow('Published', _formatDate(widget.video.publishedAt)),
        ],
      ),
    );
  }

  Widget _buildMetadataRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'N/A';
    
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays > 30) {
      return '${date.day}/${date.month}/${date.year}';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else {
      return 'Today';
    }
  }
}

class _VideoInfoBottomSheet extends StatelessWidget {
  final VideoLectureModel video;
  final UserVideoProgressModel userProgress;

  const _VideoInfoBottomSheet({
    required this.video,
    required this.userProgress,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.6,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: UnifiedTheme.primaryColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                const Expanded(
                  child: Text(
                    'Video Information',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, color: Colors.white),
                ),
              ],
            ),
          ),
          
          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Progress statistics
                  _buildStatisticsCard(),
                  
                  const SizedBox(height: 20),
                  
                  // Download option
                  if (video.isDownloadable)
                    _buildDownloadCard(),
                  
                  const SizedBox(height: 20),
                  
                  // Share option
                  _buildShareCard(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticsCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.analytics, color: Colors.blue.shade600),
              const SizedBox(width: 8),
              Text(
                'Your Progress',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade600,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  'Watched',
                  '${(userProgress.watchedPercentage * 100).toInt()}%',
                  Icons.play_circle,
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  'Bookmarks',
                  '${userProgress.bookmarks.length}',
                  Icons.bookmark,
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  'Notes',
                  '${userProgress.notes.length}',
                  Icons.note,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 24, color: Colors.blue.shade600),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.blue.shade600,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.blue.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildDownloadCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.download, color: Colors.green.shade600, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Download for Offline',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.green.shade600,
                  ),
                ),
                Text(
                  'Watch this video without internet connection',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.green.shade600,
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {
              // Handle download
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green.shade600,
              foregroundColor: Colors.white,
            ),
            child: const Text('Download'),
          ),
        ],
      ),
    );
  }

  Widget _buildShareCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.share, color: Colors.orange.shade600, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Share Progress',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange.shade600,
                  ),
                ),
                Text(
                  'Share your learning progress with friends',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.orange.shade600,
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {
              // Handle share
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange.shade600,
              foregroundColor: Colors.white,
            ),
            child: const Text('Share'),
          ),
        ],
      ),
    );
  }
}