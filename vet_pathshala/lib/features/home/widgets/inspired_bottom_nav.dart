import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class InspiredBottomNav extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const InspiredBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1C2526),
        border: Border(
          top: BorderSide(
            color: const Color(0xFF4B5E4A).withOpacity(0.3),
            width: 2,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4B5E4A).withOpacity(0.2),
            blurRadius: 32,
            offset: const Offset(0, -8),
          ),
        ],
      ),
      child: SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                context,
                0,
                Icons.home_outlined,
                Icons.home,
                'Home',
              ),
              _buildNavItem(
                context,
                1,
                Icons.menu_book_outlined,
                Icons.menu_book,
                'Ebooks',
              ),
              _buildNavItem(
                context,
                2,
                Icons.medication_outlined,
                Icons.medication,
                'Drugs',
              ),
              _buildNavItem(
                context,
                3,
                Icons.shield_outlined,
                Icons.shield,
                'Battle',
              ),
              _buildNavItem(
                context,
                4,
                Icons.person_outline,
                Icons.person,
                'Profile',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context,
    int index,
    IconData outlineIcon,
    IconData filledIcon,
    String label,
  ) {
    final isActive = currentIndex == index;
    
    return GestureDetector(
      onTap: () => onTap(index),
      behavior: HitTestBehavior.translucent,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        transform: isActive 
            ? Matrix4.translationValues(0, -4, 0)
            : Matrix4.identity(),
        decoration: BoxDecoration(
          color: isActive 
              ? const Color(0xFF4B5E4A).withOpacity(0.1) 
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: isActive 
              ? Border.all(
                  color: const Color(0xFF4B5E4A).withOpacity(0.3),
                  width: 1,
                )
              : null,
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: const Color(0xFF4B5E4A).withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Icon(
                isActive ? filledIcon : outlineIcon,
                key: ValueKey(isActive),
                color: isActive ? const Color(0xFF4B5E4A) : const Color(0x99D4D4D4),
                size: 24,
              ),
            ),
            const SizedBox(height: 6),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: TextStyle(
                fontSize: 11,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                color: isActive ? const Color(0xFF4B5E4A) : const Color(0x99D4D4D4),
              ),
              child: Text(label),
            ),
          ],
        ),
      ),
    );
  }
}