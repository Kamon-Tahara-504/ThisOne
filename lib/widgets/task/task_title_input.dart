import 'package:flutter/material.dart';
import '../../utils/text_selection_menu_builder.dart';

class TaskTitleInput extends StatelessWidget {
  final TextEditingController titleController;
  final FocusNode titleFocusNode;
  final VoidCallback? onTemplateSelect;

  const TaskTitleInput({
    super.key,
    required this.titleController,
    required this.titleFocusNode,
    this.onTemplateSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'タイトル',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF3A3A3A),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[600]!),
          ),
          child: TextField(
            controller: titleController,
            focusNode: titleFocusNode,
            style: const TextStyle(color: Colors.white, fontSize: 16),
            decoration: InputDecoration(
              hintText: 'タスクのタイトルを入力...',
              hintStyle: const TextStyle(color: Colors.grey),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(16),
              suffixIcon:
                  onTemplateSelect != null
                      ? InkWell(
                        onTap: onTemplateSelect,
                        borderRadius: BorderRadius.circular(24),
                        child: const Padding(
                          padding: EdgeInsets.all(8),
                          child: Icon(
                            Icons.checklist,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                      )
                      : null,
            ),
            contextMenuBuilder: nativeTextSelectionMenuBuilder,
          ),
        ),
      ],
    );
  }
}
