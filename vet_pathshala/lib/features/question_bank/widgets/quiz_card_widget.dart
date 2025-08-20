import 'package:flutter/material.dart';
import '../../../core/theme/unified_theme.dart';
import '../../../shared/models/quiz_models.dart';
import '../../../shared/models/user_model.dart';

class QuizCardWidget extends StatelessWidget {
  final QuizModel quiz;
  final UserModel user;
  final VoidCallback onTap;

  const QuizCardWidget({
    super.key,
    required this.quiz,
    required this.user,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final canAfford = !quiz.isPremium || user.coins >= quiz.coinCost;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 4,
      child: InkWell(
        onTap: canAfford ? onTap : null,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row
              Row(
                children: [
                  // Quiz type icon
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _getQuizTypeColor().withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _getQuizTypeIcon(),
                      color: _getQuizTypeColor(),
                      size: 20,
                    ),
                  ),
                  
                  const SizedBox(width: 12),
                  
                  // Quiz title
                  Expanded(
                    child: Text(
                      quiz.title,
                      style: UnifiedTheme.bodyStyle.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  
                  // Premium indicator
                  if (quiz.isPremium)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.amber.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.amber, width: 1),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.stars,
                            color: Colors.amber,
                            size: 12,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${quiz.coinCost}',
                            style: const TextStyle(
                              color: Colors.amber,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Description
              if (quiz.description.isNotEmpty)
                Text(
                  quiz.description,
                  style: UnifiedTheme.bodyStyle.copyWith(
                    color: Colors.grey[600],
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              
              const SizedBox(height: 16),
              
              // Quiz details row
              Row(
                children: [
                  _buildDetailChip(
                    Icons.category,
                    quiz.category,
                    Colors.blue,
                  ),
                  const SizedBox(width: 8),
                  _buildDetailChip(
                    Icons.signal_cellular_alt,
                    quiz.difficulty.name.toUpperCase(),
                    _getDifficultyColor(),
                  ),
                  const SizedBox(width: 8),
                  _buildDetailChip(
                    Icons.quiz,
                    '${quiz.questionCount} Q',
                    Colors.green,
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Time limit (if applicable)
              if (quiz.timeLimit > 0)
                Row(
                  children: [
                    Icon(
                      Icons.timer,
                      size: 16,
                      color: Colors.orange,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _formatDuration(quiz.timeLimit),
                      style: UnifiedTheme.captionStyle.copyWith(
                        color: Colors.orange,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              
              const SizedBox(height: 16),
              
              // Action button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: canAfford ? onTap : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: canAfford 
                        ? _getQuizTypeColor() 
                        : Colors.grey,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: Text(
                    canAfford 
                        ? _getActionText()
                        : 'Insufficient Coins',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildDetailChip(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
  
  Color _getQuizTypeColor() {
    switch (quiz.type) {
      case QuizType.practice:
        return Colors.blue;
      case QuizType.timed:
        return Colors.orange;
      case QuizType.battle:
        return Colors.red;
      case QuizType.challenge:
        return Colors.purple;
      case QuizType.mock_exam:
        return Colors.green;
    }
  }
  
  IconData _getQuizTypeIcon() {
    switch (quiz.type) {
      case QuizType.practice:
        return Icons.quiz;
      case QuizType.timed:
        return Icons.timer;
      case QuizType.battle:
        return Icons.sports_martial_arts;
      case QuizType.challenge:
        return Icons.emoji_events;
      case QuizType.mock_exam:
        return Icons.school;
    }
  }
  
  Color _getDifficultyColor() {
    switch (quiz.difficulty) {
      case DifficultyLevel.novice:
        return Colors.green;
      case DifficultyLevel.beginner:
        return Colors.lightGreen;
      case DifficultyLevel.intermediate:
        return Colors.orange;
      case DifficultyLevel.advanced:
        return Colors.deepOrange;
      case DifficultyLevel.expert:
        return Colors.red;
    }
  }
  
  String _getActionText() {
    switch (quiz.type) {
      case QuizType.practice:
        return 'Start Practice';
      case QuizType.timed:
        return 'Begin Timed Quiz';
      case QuizType.battle:
        return 'Join Battle';
      case QuizType.challenge:
        return 'Take Challenge';
      case QuizType.mock_exam:
        return 'Start Exam';
    }
  }
  
  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    if (minutes < 60) {
      return '${minutes}m';
    } else {
      final hours = minutes ~/ 60;
      final remainingMinutes = minutes % 60;
      return '${hours}h ${remainingMinutes}m';
    }
  }
}