import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../gradients.dart';
import '../../utils/text_selection_menu_builder.dart';

class AccountInfoItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? value;
  final Color? valueColor;
  final bool isEditable;
  final bool isEditing;
  final TextEditingController? controller;
  final String? hintText;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final String? errorText;

  const AccountInfoItem({
    super.key,
    required this.icon,
    required this.title,
    this.value,
    this.valueColor,
    this.isEditable = false,
    this.isEditing = false,
    this.controller,
    this.hintText,
    this.keyboardType,
    this.inputFormatters,
    this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF3A3A3A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[700]!),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: createOrangeYellowGradient(),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(color: Colors.grey[400], fontSize: 14),
                ),
                const SizedBox(height: 4),
                if (isEditing && isEditable && controller != null)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextField(
                        controller: controller,
                        style: const TextStyle(color: Colors.white),
                        keyboardType: keyboardType,
                        inputFormatters: inputFormatters,
                        decoration: InputDecoration(
                          hintText: hintText ?? '入力してください',
                          hintStyle: TextStyle(color: Colors.grey[500]),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                              color: errorText != null
                                  ? Colors.red
                                  : Colors.grey[600]!,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                              color: errorText != null
                                  ? Colors.red
                                  : const Color(0xFFE85A3B),
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                        ),
                        contextMenuBuilder: nativeTextSelectionMenuBuilder,
                      ),
                      if (errorText != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          errorText!,
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ],
                  )
                else
                  Text(
                    value ?? '未設定',
                    style: TextStyle(
                      color:
                          valueColor ??
                          (value != null && value != '未設定'
                              ? Colors.white
                              : Colors.grey[500]),
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
