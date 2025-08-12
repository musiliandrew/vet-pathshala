import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../../../core/theme/unified_theme.dart';
import '../../../core/services/ai_explanation_service.dart';
import '../../../shared/models/user_model.dart';
import '../../auth/providers/auth_provider.dart';

class AIExplanationWidget extends StatefulWidget {
  final String questionId;
  final String questionText;
  final String correctAnswer;
  final List<String> allOptions;
  final String category;
  final String difficulty;
  final bool isExpanded;
  final VoidCallback? onToggle;

  const AIExplanationWidget({
    super.key,
    required this.questionId,
    required this.questionText,
    required this.correctAnswer,
    required this.allOptions,
    required this.category,
    required this.difficulty,
    this.isExpanded = false,
    this.onToggle,
  });

  @override
  State<AIExplanationWidget> createState() => _AIExplanationWidgetState();
}

class _AIExplanationWidgetState extends State<AIExplanationWidget> with TickerProviderStateMixin {
  final AIExplanationService _aiService = AIExplanationService();
  
  bool _isLoading = false;
  String? _explanation;
  String? _error;
  late AnimationController _slideController;
  late AnimationController _pulseController;
  late Animation<double> _slideAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _slideAnimation = CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeInOut,
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    if (widget.isExpanded) {
      _slideController.forward();
    }
  }

  @override
  void dispose() {
    _slideController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(AIExplanationWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isExpanded != oldWidget.isExpanded) {
      if (widget.isExpanded) {
        _slideController.forward();
        if (_explanation == null && !_isLoading) {
          _generateExplanation();
        }
      } else {
        _slideController.reverse();
      }
    }
  }

  Future<void> _generateExplanation() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    _pulseController.repeat(reverse: true);

    try {
      final authProvider = context.read<AuthProvider>();
      final userRole = authProvider.currentUser?.userRole;

      final explanation = await _aiService.generateExplanation(
        questionText: widget.questionText,
        correctAnswer: widget.correctAnswer,
        allOptions: widget.allOptions,
        category: widget.category,
        difficulty: widget.difficulty,
        userRole: userRole,
      );

      if (mounted) {
        setState(() {
          _explanation = explanation;
          _isLoading = false;
        });
        
        // Cache the explanation
        await _aiService.cacheExplanation(widget.questionId, explanation);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Failed to generate explanation. Please try again.';
          _isLoading = false;
        });
      }
    } finally {
      _pulseController.stop();
    }
  }

  void _toggleExpansion() {
    if (widget.onToggle != null) {
      widget.onToggle!();
    } else {
      // Handle internal toggle if no external callback
      if (_slideController.isCompleted) {
        _slideController.reverse();
      } else {
        _slideController.forward();
        if (_explanation == null && !_isLoading) {
          _generateExplanation();
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: UnifiedTheme.primaryGreen.withOpacity(0.2),
        ),
      ),
      child: Column(
        children: [
          // Header Button
          InkWell(
            onTap: _toggleExpansion,
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: UnifiedTheme.primaryGreen.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: AnimatedBuilder(
                      animation: _pulseAnimation,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _isLoading ? _pulseAnimation.value : 1.0,
                          child: Icon(
                            Icons.psychology_outlined,
                            color: UnifiedTheme.primaryGreen,
                            size: 20,
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'AI Explanation',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: UnifiedTheme.primaryText,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _isLoading 
                              ? 'Generating explanation...'
                              : _explanation != null
                                  ? 'Tap to ${widget.isExpanded ? 'hide' : 'show'} detailed explanation'
                                  : 'Tap to get AI-powered explanation',
                          style: TextStyle(
                            fontSize: 12,
                            color: UnifiedTheme.secondaryText,
                          ),
                        ),
                      ],
                    ),
                  ),
                  AnimatedRotation(
                    turns: widget.isExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 300),
                    child: Icon(
                      Icons.expand_more,
                      color: UnifiedTheme.tertiaryText,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Expandable Content
          SizeTransition(
            sizeFactor: _slideAnimation,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: _buildContent(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return _buildLoadingState();
    } else if (_error != null) {
      return _buildErrorState();
    } else if (_explanation != null) {
      return _buildExplanationState();
    } else {
      return _buildInitialState();
    }
  }

  Widget _buildLoadingState() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(UnifiedTheme.primaryGreen),
          ),
          const SizedBox(height: 16),
          Text(
            'Our AI is analyzing the question and generating a personalized explanation...',
            style: TextStyle(
              fontSize: 14,
              color: UnifiedTheme.secondaryText,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Column(
        children: [
          Icon(
            Icons.error_outline,
            color: Colors.red.shade600,
            size: 24,
          ),
          const SizedBox(height: 8),
          Text(
            _error!,
            style: TextStyle(
              fontSize: 14,
              color: Colors.red.shade700,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: () {
              setState(() {
                _error = null;
              });
              _generateExplanation();
            },
            icon: const Icon(Icons.refresh, size: 16),
            label: const Text('Try Again'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExplanationState() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Content
          MarkdownBody(
            data: _explanation!,
            styleSheet: MarkdownStyleSheet(
              p: TextStyle(
                fontSize: 14,
                color: UnifiedTheme.primaryText,
                height: 1.5,
              ),
              h1: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: UnifiedTheme.primaryText,
              ),
              h2: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: UnifiedTheme.primaryText,
              ),
              strong: TextStyle(
                fontWeight: FontWeight.w600,
                color: UnifiedTheme.primaryGreen,
              ),
              code: TextStyle(
                backgroundColor: UnifiedTheme.primaryGreen.withOpacity(0.1),
                color: UnifiedTheme.primaryGreen,
                fontSize: 13,
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Action Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _generateExplanation,
                  icon: Icon(
                    Icons.refresh,
                    size: 16,
                    color: UnifiedTheme.primaryGreen,
                  ),
                  label: Text(
                    'Generate New',
                    style: TextStyle(
                      color: UnifiedTheme.primaryGreen,
                      fontSize: 12,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: UnifiedTheme.primaryGreen),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    // Copy to clipboard or share functionality
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Explanation copied!'),
                        backgroundColor: UnifiedTheme.primaryGreen,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  icon: const Icon(Icons.copy, size: 16, color: Colors.white),
                  label: const Text(
                    'Copy',
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: UnifiedTheme.primaryGreen,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInitialState() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Icon(
            Icons.lightbulb_outline,
            color: UnifiedTheme.primaryGreen,
            size: 32,
          ),
          const SizedBox(height: 12),
          Text(
            'Get AI-Powered Explanation',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: UnifiedTheme.primaryText,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Our AI will analyze this question and provide a detailed explanation tailored to your learning needs.',
            style: TextStyle(
              fontSize: 14,
              color: UnifiedTheme.secondaryText,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _generateExplanation,
            icon: const Icon(Icons.auto_awesome, size: 18, color: Colors.white),
            label: const Text(
              'Generate Explanation',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: UnifiedTheme.primaryGreen,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }
}