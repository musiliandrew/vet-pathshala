import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class DifficultyFilterWidget extends StatelessWidget {
  final String selectedDifficulty;
  final Function(String) onDifficultySelected;

  const DifficultyFilterWidget({
    super.key,
    required this.selectedDifficulty,
    required this.onDifficultySelected,
  });

  static const List<Map<String, dynamic>> difficulties = [
    {'value': 'beginner', 'label': 'Beginner', 'color': AppColors.success},
    {'value': 'intermediate', 'label': 'Intermediate', 'color': AppColors.warning},
    {'value': 'advanced', 'label': 'Advanced', 'color': AppColors.error},
    {'value': 'expert', 'label': 'Expert', 'color': AppColors.primary},
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        shrinkWrap: true,
        itemCount: difficulties.length,
        itemBuilder: (context, index) {
          final difficulty = difficulties[index];
          final isSelected = selectedDifficulty == difficulty['value'];

          return Padding(
            padding: EdgeInsets.only(right: index < difficulties.length - 1 ? 8 : 0),
            child: FilterChip(
              label: Text(
                difficulty['label'],
                style: TextStyle(
                  color: isSelected ? Colors.white : AppColors.textPrimary,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
              selected: isSelected,
              onSelected: (selected) {
                onDifficultySelected(selected ? difficulty['value'] : '');
              },
              backgroundColor: AppColors.surface,
              selectedColor: difficulty['color'],
              checkmarkColor: Colors.white,
              side: BorderSide(
                color: isSelected ? difficulty['color'] : AppColors.border,
              ),
            ),
          );
        },
      ),
    );
  }
}