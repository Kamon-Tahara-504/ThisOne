import 'package:flutter/material.dart';
import '../../gradients.dart';

class EmptyScheduleState extends StatelessWidget {
  const EmptyScheduleState({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ShaderMask(
              shaderCallback:
                  (bounds) => createOrangeYellowGradient().createShader(bounds),
              child: const Icon(
                Icons.event_note,
                size: 48,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'この日にスケジュールはありません',
              style: TextStyle(color: Colors.grey[400], fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}
