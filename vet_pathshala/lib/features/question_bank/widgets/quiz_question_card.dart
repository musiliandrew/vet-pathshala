import 'package:flutter/material.dart';
import '../../../core/theme/unified_theme.dart';
import '../../../shared/models/user_model.dart';

class QuizQuestionCard extends StatelessWidget {
  final QuestionModel question;
  final int? selectedAnswer;
  final Function(int) onAnswerSelected;
  final int questionNumber;
  final bool showCorrectAnswer;

  const QuizQuestionCard({
    super.key,
    required this.question,
    this.selectedAnswer,
    required this.onAnswerSelected,
    required this.questionNumber,
    this.showCorrectAnswer = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Question header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: UnifiedTheme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'Question $questionNumber',
                style: UnifiedTheme.captionStyle.copyWith(
                  color: UnifiedTheme.primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Question text
            Text(
              question.questionText,
              style: UnifiedTheme.bodyStyle.copyWith(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                height: 1.4,
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Answer options
            ...question.options.asMap().entries.map((entry) {
              final index = entry.key;
              final option = entry.value;
              final isSelected = selectedAnswer == index;
              final isCorrect = showCorrectAnswer && question.correctAnswer == index;
              final isWrong = showCorrectAnswer && 
                  selectedAnswer == index && 
                  question.correctAnswer != index;
              
              Color? backgroundColor;
              Color? borderColor;
              Color? textColor;
              
              if (showCorrectAnswer) {
                if (isCorrect) {
                  backgroundColor = Colors.green.withOpacity(0.1);
                  borderColor = Colors.green;
                  textColor = Colors.green.shade700;
                } else if (isWrong) {
                  backgroundColor = Colors.red.withOpacity(0.1);
                  borderColor = Colors.red;
                  textColor = Colors.red.shade700;
                }
              } else if (isSelected) {
                backgroundColor = UnifiedTheme.primaryColor.withOpacity(0.1);
                borderColor = UnifiedTheme.primaryColor;
                textColor = UnifiedTheme.primaryColor;
              }
              
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: InkWell(
                  onTap: showCorrectAnswer ? null : () => onAnswerSelected(index),
                  borderRadius: BorderRadius.circular(12),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: backgroundColor ?? Colors.grey.shade50,
                      border: Border.all(
                        color: borderColor ?? Colors.grey.shade300,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        // Option letter
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: textColor?.withOpacity(0.2) ?? 
                                Colors.grey.shade200,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              String.fromCharCode(65 + index), // A, B, C, D
                              style: TextStyle(
                                color: textColor ?? Colors.grey.shade600,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                        
                        const SizedBox(width: 16),
                        
                        // Option text
                        Expanded(
                          child: Text(
                            option,
                            style: UnifiedTheme.bodyStyle.copyWith(
                              color: textColor ?? Colors.black87,
                              fontWeight: isSelected || showCorrectAnswer 
                                  ? FontWeight.w600 
                                  : FontWeight.normal,
                            ),
                          ),
                        ),
                        
                        // Selection indicator
                        if (isSelected && !showCorrectAnswer)
                          Icon(
                            Icons.check_circle,
                            color: UnifiedTheme.primaryColor,
                            size: 24,
                          ),
                        
                        if (showCorrectAnswer && isCorrect)
                          const Icon(
                            Icons.check_circle,
                            color: Colors.green,
                            size: 24,
                          ),
                        
                        if (showCorrectAnswer && isWrong)
                          const Icon(
                            Icons.cancel,
                            color: Colors.red,
                            size: 24,
                          ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
            
            const SizedBox(height: 16),
            
            // Question metadata
            Wrap(
              spacing: 8,
              children: [
                _buildMetadataChip('Category', question.category),
                _buildMetadataChip('Difficulty', question.difficulty),
                _buildMetadataChip('Type', question.questionType),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildMetadataChip(String label, String value) {
    return Chip(
      label: Text(
        '$label: $value',
        style: const TextStyle(fontSize: 12),
      ),
      backgroundColor: Colors.grey.shade100,
      side: BorderSide.none,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
    );
  }
}