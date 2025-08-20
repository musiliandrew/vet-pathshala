import 'package:flutter/material.dart';

class QuizTimerWidget extends StatelessWidget {
  final int remainingTime; // in seconds
  final Color color;
  final double size;

  const QuizTimerWidget({
    super.key,
    required this.remainingTime,
    this.color = Colors.blue,
    this.size = 40.0,
  });

  @override
  Widget build(BuildContext context) {
    final minutes = remainingTime ~/ 60;
    final seconds = remainingTime % 60;
    final timeString = '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color, width: 2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.timer_outlined,
            color: color,
            size: 16,
          ),
          const SizedBox(width: 4),
          Text(
            timeString,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}