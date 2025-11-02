import 'package:flutter/material.dart';
import '../../widgets/app_bars/static_header_guideline.dart';

/// プライバシーポリシー（アプリ内表示）
class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2B2B2B),
      body: SafeArea(
        child: Column(
          children: [
            // ヘッダー
            Container(
              height: 52,
              margin: const EdgeInsets.only(top: 4.0),
              padding: const EdgeInsets.symmetric(
                horizontal: 14.0,
                vertical: 1.0,
              ),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    padding: const EdgeInsets.all(4),
                    constraints: const BoxConstraints(
                      minWidth: 32,
                      minHeight: 32,
                    ),
                    icon: const Icon(
                      Icons.arrow_back_ios,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'プライバシーポリシー',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),

            const StaticHeaderGuideline(),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: DefaultTextStyle(
                  style: const TextStyle(
                    color: Colors.white,
                    height: 1.6,
                    fontSize: 14,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'ThisOneプライバシーポリシー',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFE85A3B),
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        '最終更新日: 2025年11月',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      SizedBox(height: 24),
                      Text(
                        '1. 収集する情報',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text('本アプリ「ThisOne」は、ユーザーのプライバシーを尊重し、以下の情報のみを収集します：'),
                      SizedBox(height: 8),
                      Text('• アカウント情報：メールアドレス、表示名（任意）、電話番号（任意）'),
                      Text('• アプリ内で作成されたデータ：メモ、タスク、スケジュール'),
                      Text('• 認証情報：Supabaseを通じた認証トークン'),
                      SizedBox(height: 8),
                      Text(
                        '本アプリはローカルファースト設計を採用しており、すべてのデータは端末内のローカルデータベース（SQLite）に保存されます。',
                      ),
                      SizedBox(height: 16),
                      Text(
                        '2. データの保存場所',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text('• ローカルストレージ：メモ、タスク、スケジュールはすべて端末内に保存されます'),
                      Text('• クラウド同期：認証情報のみSupabaseサーバーに保存されます'),
                      Text('• データエクスポート：ユーザーは任意のタイミングでデータをエクスポートできます'),
                      SizedBox(height: 16),
                      Text(
                        '3. データの利用目的',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text('収集した情報は以下の目的でのみ利用します：'),
                      SizedBox(height: 8),
                      Text('• アプリ機能の提供（タスク管理、メモ作成、スケジュール管理）'),
                      Text('• ユーザー認証とアカウント管理'),
                      Text('• アプリの品質向上とバグ修正'),
                      Text('• ユーザーサポート'),
                      SizedBox(height: 16),
                      Text(
                        '4. 第三者提供',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text('ユーザーの個人情報を、以下の場合を除き第三者へ提供することはありません：'),
                      SizedBox(height: 8),
                      Text('• ユーザーの同意がある場合'),
                      Text('• 法令に基づく場合'),
                      Text('• 人の生命、身体または財産の保護のために必要がある場合'),
                      SizedBox(height: 16),
                      Text(
                        '5. 使用している第三者サービス',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text('• Supabase：ユーザー認証とアカウント管理'),
                      SizedBox(height: 16),
                      Text(
                        '6. データの削除',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text('ユーザーはいつでも以下の方法でデータを削除できます：'),
                      SizedBox(height: 8),
                      Text('• アプリ内の設定から「全データを削除」を実行'),
                      Text('• アカウントを削除することで、すべての関連データを削除'),
                      SizedBox(height: 16),
                      Text(
                        '7. セキュリティ',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'ユーザーデータの保護のため、適切なセキュリティ対策を講じています。ただし、インターネット通信の完全な安全性を保証することはできません。',
                      ),
                      SizedBox(height: 16),
                      Text(
                        '8. プライバシーポリシーの変更',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        '本プライバシーポリシーは、必要に応じて変更されることがあります。重要な変更がある場合は、アプリ内でお知らせします。',
                      ),
                      SizedBox(height: 16),
                      Text(
                        '9. お問い合わせ',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text('プライバシーポリシーに関するご質問は、アプリ内の「ヘルプ」→「お問い合わせ」からお願いします。'),
                      SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
