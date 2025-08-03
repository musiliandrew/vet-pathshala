import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import 'dart:async';

class QuestionSearchWidget extends StatefulWidget {
  final Function(String) onSearch;

  const QuestionSearchWidget({
    super.key,
    required this.onSearch,
  });

  @override
  State<QuestionSearchWidget> createState() => _QuestionSearchWidgetState();
}

class _QuestionSearchWidgetState extends State<QuestionSearchWidget> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounceTimer;

  @override
  void dispose() {
    _searchController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      widget.onSearch(query);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: TextField(
        controller: _searchController,
        onChanged: _onSearchChanged,
        decoration: InputDecoration(
          hintText: 'Search questions...',
          prefixIcon: const Icon(
            Icons.search,
            color: AppColors.textTertiary,
          ),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  onPressed: () {
                    _searchController.clear();
                    widget.onSearch('');
                  },
                  icon: const Icon(
                    Icons.clear,
                    color: AppColors.textTertiary,
                  ),
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
          hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: AppColors.textTertiary,
          ),
        ),
      ),
    );
  }
}