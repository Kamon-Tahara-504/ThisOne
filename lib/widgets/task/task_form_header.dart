import 'package:flutter/material.dart';
import '../../gradients.dart';

class TaskFormHeader extends StatelessWidget {
  final VoidCallback onClose;

  const TaskFormHeader({super.key, required this.onClose});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          ShaderMask(
            shaderCallback:
                (bounds) => createOrangeYellowGradient().createShader(bounds),
            child: const Icon(Icons.task_alt, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 12),
          const Text(
            'タスク作成',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          IconButton(
            onPressed: onClose,
            icon: const Icon(Icons.close, color: Colors.white),
          ),
        ],
      ),
    );
  }
}
