import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/unified_theme.dart';
import '../models/pyp_model.dart';
import '../providers/pyp_provider.dart';
import '../../coins/providers/coin_provider.dart';

class PYPPaperDetailScreen extends StatefulWidget {
  final PYPPaper paper;

  const PYPPaperDetailScreen({super.key, required this.paper});

  @override
  State<PYPPaperDetailScreen> createState() => _PYPPaperDetailScreenState();
}

class _PYPPaperDetailScreenState extends State<PYPPaperDetailScreen> {
  double _userRating = 0;
  bool _isDownloading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: UnifiedTheme.backgroundColor,
      body: CustomScrollView(
        slivers: [
          // App Bar
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: UnifiedTheme.primaryGreen,
            foregroundColor: Colors.white,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                widget.paper.year.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      UnifiedTheme.primaryGreen,
                      UnifiedTheme.primaryGreen.withOpacity(0.8),
                    ],
                  ),
                ),
                child: Stack(
                  children: [
                    // Background pattern
                    Positioned(
                      top: -50,
                      right: -50,
                      child: Container(
                        width: 200,
                        height: 200,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.1),
                        ),
                      ),
                    ),
                    
                    // Content
                    const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.description,
                            size: 64,
                            color: Colors.white,
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Previous Year Paper',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          // Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Paper title and premium badge
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          widget.paper.title,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: UnifiedTheme.primaryText,
                          ),
                        ),
                      ),
                      if (widget.paper.isPremium)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [UnifiedTheme.goldAccent, UnifiedTheme.goldAccent.withOpacity(0.8)],
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.diamond, color: Colors.white, size: 16),
                              const SizedBox(width: 4),
                              Text(
                                '${widget.paper.coinCost} Coins',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Stats cards
                  Row(
                    children: [
                      _buildStatCard(
                        Icons.star,
                        '${widget.paper.rating}',
                        'Rating',
                        Colors.amber,
                      ),
                      const SizedBox(width: 12),
                      _buildStatCard(
                        Icons.download,
                        widget.paper.downloads.toString(),
                        'Downloads',
                        UnifiedTheme.blueAccent,
                      ),
                      const SizedBox(width: 12),
                      _buildStatCard(
                        Icons.quiz,
                        '${widget.paper.questions}',
                        'Questions',
                        UnifiedTheme.primaryGreen,
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Paper details
                  _buildDetailsCard(),
                  
                  const SizedBox(height: 16),
                  
                  // Tags
                  _buildTagsSection(),
                  
                  const SizedBox(height: 16),
                  
                  // Rating section
                  _buildRatingSection(),
                  
                  const SizedBox(height: 100), // Space for FAB
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: _buildDownloadFAB(),
    );
  }

  Widget _buildStatCard(IconData icon, String value, String label, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.2)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: UnifiedTheme.secondaryText,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailsCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Paper Details',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: UnifiedTheme.primaryText,
            ),
          ),
          const SizedBox(height: 16),
          
          _buildDetailRow('Subject', widget.paper.subject, Icons.book),
          _buildDetailRow('Topic', widget.paper.topic, Icons.topic),
          _buildDetailRow('Year', widget.paper.year.toString(), Icons.calendar_today),
          _buildDetailRow('Exam Type', _formatExamType(widget.paper.examType), Icons.school),
          _buildDetailRow('Difficulty', _formatDifficulty(widget.paper.difficulty), Icons.trending_up),
          _buildDetailRow('Duration', '${widget.paper.duration} minutes', Icons.timer),
          _buildDetailRow('Max Marks', widget.paper.maxMarks.toString(), Icons.grade),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: UnifiedTheme.primaryGreen.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              size: 16,
              color: UnifiedTheme.primaryGreen,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            '$label: ',
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              color: UnifiedTheme.secondaryText,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: UnifiedTheme.primaryText,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTagsSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Tags',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: UnifiedTheme.primaryText,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: widget.paper.tags.map((tag) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: UnifiedTheme.primaryGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: UnifiedTheme.primaryGreen.withOpacity(0.3)),
                ),
                child: Text(
                  tag,
                  style: TextStyle(
                    color: UnifiedTheme.primaryGreen,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Rate this Paper',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: UnifiedTheme.primaryText,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              ...List.generate(5, (index) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _userRating = index + 1.0;
                    });
                  },
                  child: Icon(
                    index < _userRating ? Icons.star : Icons.star_border,
                    color: Colors.amber,
                    size: 32,
                  ),
                );
              }),
              const SizedBox(width: 16),
              if (_userRating > 0)
                ElevatedButton(
                  onPressed: _submitRating,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: UnifiedTheme.primaryGreen,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Submit'),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDownloadFAB() {
    return Consumer2<PYPProvider, CoinProvider>(
      builder: (context, pypProvider, coinProvider, child) {
        final canDownload = !widget.paper.isPremium || 
            coinProvider.currentBalance >= widget.paper.coinCost;
        
        return FloatingActionButton.extended(
          onPressed: canDownload ? _downloadPaper : _showInsufficientCoinsDialog,
          backgroundColor: canDownload ? UnifiedTheme.primaryGreen : Colors.grey,
          foregroundColor: Colors.white,
          icon: _isDownloading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Icon(Icons.download),
          label: _isDownloading
            ? const Text('Downloading...')
            : Text(
                widget.paper.isPremium
                  ? 'Download (${widget.paper.coinCost} 🪙)'
                  : 'Download Free'
              ),
        );
      },
    );
  }

  Future<void> _downloadPaper() async {
    setState(() {
      _isDownloading = true;
    });

    try {
      final success = await context.read<PYPProvider>().downloadPaper(widget.paper.id);
      
      if (success) {
        // Deduct coins if premium
        if (widget.paper.isPremium) {
          context.read<CoinProvider>().deductCoins(
            widget.paper.coinCost,
            'PYP Paper Download: ${widget.paper.title}',
          );
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Downloaded: ${widget.paper.title}'),
              backgroundColor: UnifiedTheme.primaryGreen,
              action: SnackBarAction(
                label: 'Open',
                textColor: Colors.white,
                onPressed: () {
                  // TODO: Open PDF viewer
                },
              ),
            ),
          );
        }
      } else {
        throw Exception('Download failed');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Download failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isDownloading = false;
        });
      }
    }
  }

  void _showInsufficientCoinsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Insufficient Coins'),
        content: Text(
          'You need ${widget.paper.coinCost} coins to download this paper. '
          'You currently have ${context.read<CoinProvider>().currentBalance} coins.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Navigate to coin store
              // TODO: Implement navigation to coin store
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: UnifiedTheme.goldAccent,
              foregroundColor: Colors.white,
            ),
            child: const Text('Buy Coins'),
          ),
        ],
      ),
    );
  }

  Future<void> _submitRating() async {
    try {
      await context.read<PYPProvider>().ratePaper(widget.paper.id, _userRating);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Thank you for your rating!'),
            backgroundColor: UnifiedTheme.primaryGreen,
          ),
        );
        
        setState(() {
          _userRating = 0;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to submit rating: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String _formatExamType(String type) {
    switch (type) {
      case 'university':
        return 'University Exam';
      case 'competitive':
        return 'Competitive Exam';
      case 'mock':
        return 'Mock Test';
      default:
        return type.toUpperCase();
    }
  }

  String _formatDifficulty(String difficulty) {
    return '${difficulty[0].toUpperCase()}${difficulty.substring(1)}';
  }
}