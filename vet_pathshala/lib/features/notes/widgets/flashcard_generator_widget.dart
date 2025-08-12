import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/unified_theme.dart';
import '../../../core/services/flashcard_generator_service.dart';
import '../../../shared/models/note_model.dart';
import '../../../shared/models/flashcard_model.dart';
import '../../auth/providers/auth_provider.dart';

class FlashcardGeneratorWidget extends StatefulWidget {
  final NoteModel note;
  final VoidCallback? onFlashcardsGenerated;

  const FlashcardGeneratorWidget({
    super.key,
    required this.note,
    this.onFlashcardsGenerated,
  });

  @override
  State<FlashcardGeneratorWidget> createState() => _FlashcardGeneratorWidgetState();
}

class _FlashcardGeneratorWidgetState extends State<FlashcardGeneratorWidget> with TickerProviderStateMixin {
  final FlashcardGeneratorService _generatorService = FlashcardGeneratorService();
  
  bool _isGenerating = false;
  bool _hasGenerated = false;
  List<FlashcardModel> _generatedFlashcards = [];
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _loadExistingFlashcards();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _loadExistingFlashcards() async {
    final authProvider = context.read<AuthProvider>();
    if (authProvider.currentUser != null) {
      final flashcards = await _generatorService.getFlashcardsForNote(
        authProvider.currentUser!.id,
        widget.note.id,
      );
      if (flashcards.isNotEmpty) {
        setState(() {
          _generatedFlashcards = flashcards;
          _hasGenerated = true;
        });
      }
    }
  }

  Future<void> _generateFlashcards() async {
    final authProvider = context.read<AuthProvider>();
    if (authProvider.currentUser == null) return;

    setState(() {
      _isGenerating = true;
    });

    _pulseController.repeat(reverse: true);

    try {
      final flashcards = await _generatorService.generateFlashcardsFromNote(
        userId: authProvider.currentUser!.id,
        note: widget.note,
        maxCards: 8,
      );

      if (flashcards.isNotEmpty) {
        final success = await _generatorService.saveFlashcardsToFirestore(flashcards);
        
        if (success) {
          setState(() {
            _generatedFlashcards = flashcards;
            _hasGenerated = true;
          });
          widget.onFlashcardsGenerated?.call();
          
          // Show success message
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Generated ${flashcards.length} flashcards!'),
                backgroundColor: UnifiedTheme.primaryGreen,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Could not generate flashcards from this content. Try notes with more definitions or lists.'),
              backgroundColor: Colors.orange,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error generating flashcards: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      _pulseController.stop();
      setState(() {
        _isGenerating = false;
      });
    }
  }

  void _showFlashcardPreview(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => FlashcardPreviewSheet(
        flashcards: _generatedFlashcards,
        onClose: () => Navigator.pop(context),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_hasGenerated && _generatedFlashcards.isNotEmpty) {
      return _buildGeneratedState();
    }

    return _buildGenerateState();
  }

  Widget _buildGenerateState() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: UnifiedTheme.primaryGreen.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.auto_awesome,
                color: UnifiedTheme.primaryGreen,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Auto-Generate Flashcards',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: UnifiedTheme.primaryText,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Automatically create study flashcards from this note\'s content including definitions, key concepts, and lists.',
            style: TextStyle(
              fontSize: 14,
              color: UnifiedTheme.secondaryText,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _isGenerating ? _pulseAnimation.value : 1.0,
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _isGenerating ? null : _generateFlashcards,
                    icon: _isGenerating
                        ? SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                UnifiedTheme.primaryGreen.withOpacity(0.7),
                              ),
                            ),
                          )
                        : Icon(
                            Icons.psychology,
                            color: Colors.white,
                            size: 18,
                          ),
                    label: Text(
                      _isGenerating ? 'Generating...' : 'Generate Flashcards',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: UnifiedTheme.primaryGreen,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 0,
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildGeneratedState() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: UnifiedTheme.primaryGreen.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: UnifiedTheme.primaryGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.check_circle,
                  color: UnifiedTheme.primaryGreen,
                  size: 16,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Flashcards Generated',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: UnifiedTheme.primaryText,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${_generatedFlashcards.length} flashcards created from this note',
            style: TextStyle(
              fontSize: 14,
              color: UnifiedTheme.secondaryText,
            ),
          ),
          const SizedBox(height: 12),
          
          // Preview of first few flashcards
          ..._generatedFlashcards.take(2).map((flashcard) => 
            _buildFlashcardPreview(flashcard)
          ).toList(),
          
          if (_generatedFlashcards.length > 2) ...[
            const SizedBox(height: 8),
            Text(
              '+ ${_generatedFlashcards.length - 2} more cards',
              style: TextStyle(
                fontSize: 12,
                color: UnifiedTheme.tertiaryText,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
          
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _showFlashcardPreview(context),
                  icon: Icon(
                    Icons.visibility_outlined,
                    size: 16,
                    color: UnifiedTheme.primaryGreen,
                  ),
                  label: Text(
                    'View All',
                    style: TextStyle(
                      color: UnifiedTheme.primaryGreen,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: UnifiedTheme.primaryGreen),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _generateFlashcards,
                  icon: const Icon(
                    Icons.refresh,
                    size: 16,
                    color: Colors.white,
                  ),
                  label: const Text(
                    'Regenerate',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: UnifiedTheme.primaryGreen,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFlashcardPreview(FlashcardModel flashcard) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                flashcard.difficultyIcon,
                style: const TextStyle(fontSize: 12),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  flashcard.question,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: UnifiedTheme.primaryText,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            flashcard.answer,
            style: TextStyle(
              fontSize: 12,
              color: UnifiedTheme.secondaryText,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class FlashcardPreviewSheet extends StatefulWidget {
  final List<FlashcardModel> flashcards;
  final VoidCallback onClose;

  const FlashcardPreviewSheet({
    super.key,
    required this.flashcards,
    required this.onClose,
  });

  @override
  State<FlashcardPreviewSheet> createState() => _FlashcardPreviewSheetState();
}

class _FlashcardPreviewSheetState extends State<FlashcardPreviewSheet> {
  int _currentIndex = 0;
  bool _showAnswer = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.symmetric(vertical: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Text(
                  'Generated Flashcards',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: UnifiedTheme.primaryText,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: widget.onClose,
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
          ),
          
          // Card counter
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              '${_currentIndex + 1} of ${widget.flashcards.length}',
              style: TextStyle(
                color: UnifiedTheme.secondaryText,
                fontSize: 14,
              ),
            ),
          ),
          
          // Flashcard
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(16),
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _showAnswer = !_showAnswer;
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: _showAnswer 
                        ? UnifiedTheme.primaryGreen.withOpacity(0.1)
                        : UnifiedTheme.cardBackground,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: _showAnswer 
                          ? UnifiedTheme.primaryGreen.withOpacity(0.3)
                          : Colors.grey.shade200,
                    ),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _showAnswer ? 'Answer' : 'Question',
                          style: TextStyle(
                            fontSize: 12,
                            color: UnifiedTheme.tertiaryText,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _showAnswer 
                              ? widget.flashcards[_currentIndex].answer
                              : widget.flashcards[_currentIndex].question,
                          style: TextStyle(
                            fontSize: 18,
                            color: UnifiedTheme.primaryText,
                            height: 1.4,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        if (!_showAnswer) ...[
                          const SizedBox(height: 20),
                          Text(
                            'Tap to reveal answer',
                            style: TextStyle(
                              fontSize: 12,
                              color: UnifiedTheme.tertiaryText,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          
          // Navigation
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton.icon(
                  onPressed: _currentIndex > 0 ? () {
                    setState(() {
                      _currentIndex--;
                      _showAnswer = false;
                    });
                  } : null,
                  icon: const Icon(Icons.arrow_back, size: 16),
                  label: const Text('Previous'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey.shade100,
                    foregroundColor: Colors.black87,
                    elevation: 0,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _currentIndex < widget.flashcards.length - 1 ? () {
                    setState(() {
                      _currentIndex++;
                      _showAnswer = false;
                    });
                  } : null,
                  icon: const Icon(Icons.arrow_forward, size: 16),
                  label: const Text('Next'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: UnifiedTheme.primaryGreen,
                    foregroundColor: Colors.white,
                    elevation: 0,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}