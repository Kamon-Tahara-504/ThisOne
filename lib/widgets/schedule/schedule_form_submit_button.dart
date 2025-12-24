import 'package:flutter/material.dart';
import '../../gradients.dart';

class ScheduleFormSubmitButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String label;

  const ScheduleFormSubmitButton({
    super.key,
    required this.onPressed,
    this.label = 'スケジュールを作成',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        gradient: createHorizontalOrangeYellowGradient(),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
