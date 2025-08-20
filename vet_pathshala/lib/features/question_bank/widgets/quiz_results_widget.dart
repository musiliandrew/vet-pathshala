import 'package:flutter/material.dart';
import '../../../core/theme/unified_theme.dart';
import '../../../shared/models/quiz_models.dart';

class QuizResultsWidget extends StatelessWidget {
  final QuizAttemptModel attempt;
  final QuizModel quiz;
  final VoidCallback onRetakeQuiz;
  final VoidCallback onExit;

  const QuizResultsWidget({
    super.key,
    required this.attempt,
    required this.quiz,
    required this.onRetakeQuiz,
    required this.onExit,
  });

  @override
  Widget build(BuildContext context) {
    final correctAnswers = attempt.answers.where((a) => a.isCorrect).length;
    final totalQuestions = attempt.totalQuestions;
    final accuracy = totalQuestions > 0 ? (correctAnswers / totalQuestions) : 0.0;
    final timeSpent = attempt.timeSpent;
    
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const SizedBox(height: 40),
          
          // Result header
          _buildResultHeader(accuracy),
          
          const SizedBox(height: 32),
          
          // Stats cards
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildStatsGrid(correctAnswers, totalQuestions, timeSpent),
                  
                  const SizedBox(height: 24),
                  
                  _buildPerformanceChart(accuracy),
                  
                  const SizedBox(height: 24),
                  
                  _buildQuizInfo(),
                  
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
          
          // Action buttons
          _buildActionButtons(context),
        ],
      ),
    );
  }
  
  Widget _buildResultHeader(double accuracy) {
    String resultText;
    Color resultColor;
    IconData resultIcon;
    
    if (accuracy >= 0.9) {
      resultText = 'Excellent!';
      resultColor = Colors.green;
      resultIcon = Icons.emoji_events;
    } else if (accuracy >= 0.7) {
      resultText = 'Good Job!';
      resultColor = Colors.blue;
      resultIcon = Icons.thumb_up;
    } else if (accuracy >= 0.5) {
      resultText = 'Keep Trying!';
      resultColor = Colors.orange;
      resultIcon = Icons.trending_up;
    } else {
      resultText = 'Need Practice';
      resultColor = Colors.red;
      resultIcon = Icons.school;
    }
    
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: resultColor.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            resultIcon,
            size: 40,
            color: resultColor,
          ),
        ),
        
        const SizedBox(height: 16),
        
        Text(
          resultText,
          style: UnifiedTheme.headingStyle.copyWith(
            fontSize: 24,
            color: resultColor,
          ),
        ),
        
        const SizedBox(height: 8),
        
        Text(
          'You scored ${attempt.score}%',
          style: UnifiedTheme.bodyStyle.copyWith(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
  
  Widget _buildStatsGrid(int correct, int total, int timeSpent) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Score',
            '${attempt.score}%',
            Icons.grade,
            UnifiedTheme.primaryColor,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'Correct',
            '$correct/$total',
            Icons.check_circle,
            Colors.green,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'Time',
            _formatTime(timeSpent),
            Icons.timer,
            Colors.orange,
          ),
        ),
      ],
    );
  }
  
  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
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
            style: UnifiedTheme.headingStyle.copyWith(
              fontSize: 18,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: UnifiedTheme.captionStyle,
          ),
        ],
      ),
    );
  }
  
  Widget _buildPerformanceChart(double accuracy) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Performance Breakdown',
            style: UnifiedTheme.bodyStyle.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Accuracy bar
          _buildProgressBar('Accuracy', accuracy, Colors.blue),
          const SizedBox(height: 12),
          
          // Speed rating (based on average time per question)
          final avgTimePerQuestion = attempt.timeSpent / attempt.totalQuestions;
          final speedRating = _calculateSpeedRating(avgTimePerQuestion);
          _buildProgressBar('Speed', speedRating, Colors.green),
          const SizedBox(height: 12),
          
          // Overall performance
          final overallRating = (accuracy + speedRating) / 2;
          _buildProgressBar('Overall', overallRating, UnifiedTheme.primaryColor),
        ],
      ),
    );
  }
  
  Widget _buildProgressBar(String label, double value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: UnifiedTheme.bodyStyle),
            Text(
              '${(value * 100).toInt()}%',
              style: UnifiedTheme.bodyStyle.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: value,
            backgroundColor: Colors.grey.shade200,
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 8,
          ),
        ),
      ],
    );
  }
  
  Widget _buildQuizInfo() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quiz Information',
            style: UnifiedTheme.bodyStyle.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          
          const SizedBox(height: 16),
          
          _buildInfoRow('Quiz', quiz.title),
          _buildInfoRow('Category', quiz.category),
          _buildInfoRow('Difficulty', quiz.difficulty.name.toUpperCase()),
          _buildInfoRow('Type', quiz.type.name.toUpperCase()),
          if (quiz.timeLimit > 0)
            _buildInfoRow('Time Limit', _formatTime(quiz.timeLimit)),
        ],
      ),
    );
  }
  
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: UnifiedTheme.bodyStyle.copyWith(
                color: Colors.grey.shade600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: UnifiedTheme.bodyStyle.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: onRetakeQuiz,
            style: ElevatedButton.styleFrom(
              backgroundColor: UnifiedTheme.primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Retake Quiz',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        
        const SizedBox(height: 12),
        
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: onExit,
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Back to Quiz List',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }
  
  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    if (minutes > 0) {
      return '${minutes}m ${remainingSeconds}s';
    } else {
      return '${remainingSeconds}s';
    }
  }
  
  double _calculateSpeedRating(double avgTimePerQuestion) {
    // Optimal time is 30 seconds per question
    const optimalTime = 30.0;
    
    if (avgTimePerQuestion <= optimalTime) {
      return 1.0;
    } else if (avgTimePerQuestion <= optimalTime * 2) {
      return 1.0 - ((avgTimePerQuestion - optimalTime) / optimalTime) * 0.5;
    } else {
      return 0.5;
    }
  }
}