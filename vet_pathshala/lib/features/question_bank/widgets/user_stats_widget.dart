import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class UserStatsWidget extends StatelessWidget {
  final Map<String, dynamic> userStats;

  const UserStatsWidget({
    super.key,
    required this.userStats,
  });

  @override
  Widget build(BuildContext context) {
    if (userStats.isEmpty) {
      return const SizedBox.shrink();
    }

    final totalQuestions = userStats['totalQuestions'] ?? 0;
    final correctAnswers = userStats['correctAnswers'] ?? 0;
    final accuracy = userStats['accuracy'] ?? 0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildStatItem(
              context,
              'Questions',
              totalQuestions.toString(),
              Icons.quiz_outlined,
              AppColors.primary,
            ),
          ),
          Container(
            height: 40,
            width: 1,
            color: AppColors.border,
          ),
          Expanded(
            child: _buildStatItem(
              context,
              'Correct',
              correctAnswers.toString(),
              Icons.check_circle_outline,
              AppColors.success,
            ),
          ),
          Container(
            height: 40,
            width: 1,
            color: AppColors.border,
          ),
          Expanded(
            child: _buildStatItem(
              context,
              'Accuracy',
              '$accuracy%',
              Icons.track_changes_outlined,
              _getAccuracyColor(accuracy),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 16,
              color: color,
            ),
            const SizedBox(width: 4),
            Text(
              value,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Color _getAccuracyColor(int accuracy) {
    if (accuracy >= 80) return AppColors.success;
    if (accuracy >= 60) return AppColors.warning;
    return AppColors.error;
  }
}