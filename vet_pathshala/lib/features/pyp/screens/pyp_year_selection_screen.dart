import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/unified_theme.dart';
import '../providers/pyp_provider.dart';
import '../../../shared/models/test_series_models.dart';
import '../widgets/pyp_paper_card.dart';
import 'pyp_paper_detail_screen.dart';

class PYPYearSelectionScreen extends StatefulWidget {
  final int year;

  const PYPYearSelectionScreen({
    super.key,
    required this.year,
  });

  @override
  State<PYPYearSelectionScreen> createState() => _PYPYearSelectionScreenState();
}

class _PYPYearSelectionScreenState extends State<PYPYearSelectionScreen> {
  bool _isLoading = true;
  List<PYPModel> _papers = [];

  @override
  void initState() {
    super.initState();
    _loadPapersForYear();
  }

  Future<void> _loadPapersForYear() async {
    try {
      final provider = context.read<PYPProvider>();
      final papers = await provider.getPYPsForYear(widget.year);
      
      if (mounted) {
        setState(() {
          _papers = papers;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading papers: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: UnifiedTheme.backgroundColor,
      appBar: AppBar(
        title: Text(
          '${widget.year} Question Papers',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: UnifiedTheme.goldAccent,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _papers.isEmpty
              ? _buildEmptyState()
              : _buildPapersList(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: UnifiedTheme.goldAccent.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.history_edu,
              size: 50,
              color: UnifiedTheme.goldAccent.withOpacity(0.5),
            ),
          ),
          
          const SizedBox(height: 24),
          
          Text(
            'No Papers Available',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: UnifiedTheme.primaryText,
            ),
          ),
          
          const SizedBox(height: 8),
          
          Text(
            'Papers for ${widget.year} will be available soon',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 32),
          
          ElevatedButton.icon(
            onPressed: _loadPapersForYear,
            icon: const Icon(Icons.refresh),
            label: const Text('Refresh'),
            style: ElevatedButton.styleFrom(
              backgroundColor: UnifiedTheme.goldAccent,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPapersList() {
    return RefreshIndicator(
      onRefresh: _loadPapersForYear,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section
            _buildHeader(),
            
            const SizedBox(height: 20),
            
            // Papers List
            Expanded(
              child: ListView.builder(
                itemCount: _papers.length,
                itemBuilder: (context, index) {
                  final paper = _papers[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: PYPPaperCard(
                      paper: paper,
                      onTap: () => _navigateToPaperDetail(paper),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            UnifiedTheme.goldAccent.withOpacity(0.1),
            Colors.white,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: UnifiedTheme.goldAccent.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  UnifiedTheme.goldAccent,
                  UnifiedTheme.goldAccent.withOpacity(0.7),
                ],
              ),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '${widget.year}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          
          const SizedBox(width: 16),
          
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Previous Year Papers ${widget.year}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: UnifiedTheme.primaryText,
                  ),
                ),
                
                const SizedBox(height: 4),
                
                Text(
                  '${_papers.length} paper${_papers.length != 1 ? 's' : ''} available',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                
                const SizedBox(height: 8),
                
                Row(
                  children: [
                    _buildInfoChip(
                      icon: Icons.quiz,
                      label: 'Questions Available',
                      color: UnifiedTheme.primary,
                    ),
                    
                    const SizedBox(width: 8),
                    
                    _buildInfoChip(
                      icon: Icons.access_time,
                      label: 'Timed Practice',
                      color: UnifiedTheme.goldAccent,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 12,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToPaperDetail(PYPModel paper) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PYPPaperDetailScreen(
          paper: paper,
        ),
      ),
    );
  }
}