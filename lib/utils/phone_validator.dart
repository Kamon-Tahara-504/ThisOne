import 'package:flutter/services.dart';

/// 電話番号バリデーションユーティリティ
class PhoneValidator {
  /// 電話番号を正規化（数字のみに変換）
  ///
  /// ハイフン、スペース、括弧などを除去して数字のみにする
  /// 例: "090-1234-5678" → "09012345678"
  static String normalize(String phone) {
    return phone.replaceAll(RegExp(r'[^\d]'), '');
  }

  /// 電話番号のバリデーション
  ///
  /// 日本の電話番号形式をチェック（10-11桁の数字）
  /// 空文字列は有効（任意入力のため）
  static ValidationResult validate(String phone) {
    // 空文字列は有効（任意入力）
    if (phone.isEmpty) {
      return ValidationResult.valid();
    }

    // 正規化
    final normalized = normalize(phone);

    // 数字のみかチェック
    if (normalized.isEmpty) {
      return ValidationResult.invalid('数字を入力してください');
    }

    // 桁数チェック（日本の電話番号: 10-11桁）
    if (normalized.length < 10) {
      return ValidationResult.invalid('電話番号は10桁以上で入力してください');
    }

    if (normalized.length > 11) {
      return ValidationResult.invalid('電話番号は11桁以下で入力してください');
    }

    // 先頭が0で始まるかチェック（日本の電話番号）
    if (!normalized.startsWith('0')) {
      return ValidationResult.invalid('電話番号は0から始まる必要があります');
    }

    return ValidationResult.valid(normalizedValue: normalized);
  }

  /// 表示用にフォーマット
  ///
  /// 例: "09012345678" → "090-1234-5678"
  static String format(String phone) {
    final normalized = normalize(phone);

    if (normalized.length == 11) {
      // 携帯電話番号: 090-1234-5678
      return '${normalized.substring(0, 3)}-${normalized.substring(3, 7)}-${normalized.substring(7)}';
    } else if (normalized.length == 10) {
      // 固定電話番号: 03-1234-5678
      return '${normalized.substring(0, 2)}-${normalized.substring(2, 6)}-${normalized.substring(6)}';
    }

    return phone;
  }
}

/// バリデーション結果
class ValidationResult {
  final bool isValid;
  final String? errorMessage;
  final String? normalizedValue;

  ValidationResult._({
    required this.isValid,
    this.errorMessage,
    this.normalizedValue,
  });

  factory ValidationResult.valid({String? normalizedValue}) {
    return ValidationResult._(
      isValid: true,
      normalizedValue: normalizedValue,
    );
  }

  factory ValidationResult.invalid(String message) {
    return ValidationResult._(
      isValid: false,
      errorMessage: message,
    );
  }
}

/// 電話番号入力用のTextInputFormatter
///
/// 数字とハイフンのみを許可
class PhoneInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // 数字とハイフンのみを許可
    final filtered = newValue.text.replaceAll(RegExp(r'[^\d\-]'), '');

    return TextEditingValue(
      text: filtered,
      selection: TextSelection.collapsed(
        offset: filtered.length.clamp(0, filtered.length),
      ),
    );
  }
}
