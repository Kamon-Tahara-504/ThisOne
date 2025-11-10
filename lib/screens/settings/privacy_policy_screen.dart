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
                      Text('本アプリ「ThisOne」は、ユーザーのプライバシーを尊重し、以下の情報のみを取り扱います。'),
                      SizedBox(height: 8),
                      Text('• アカウント情報：メールアドレス（必須）、表示名・電話番号（任意）'),
                      Text('• アプリ内データ：タスク、スケジュール、メモ等、ユーザーが本アプリで作成・保存する情報'),
                      Text('• 認証情報：利用しているクラウド認証基盤を通じたログインに必要なトークン等'),
                      Text('• お問い合わせ対応に必要となる情報（ユーザーから提供された場合）'),
                      SizedBox(height: 16),
                      Text(
                        '2. データの保存場所',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        '• ローカルストレージ：タスク・スケジュール・メモ・プロフィール情報（表示名・電話番号）は、ユーザーの端末内で管理されます。',
                      ),
                      Text(
                        '• クラウドサービス：メールアドレスとパスワード等、認証に必要な最低限の情報のみを信頼できるクラウド認証基盤で保管します。',
                      ),
                      Text(
                        '• データエクスポート：ユーザーはアプリ内の機能を利用して、ローカルデータをファイルとしてエクスポートできます。',
                      ),
                      SizedBox(height: 16),
                      Text(
                        '3. データの利用目的',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text('収集・保持した情報は以下の目的で利用します。'),
                      Text('• 本アプリの提供および各機能の実行'),
                      Text('• ユーザー認証およびアカウント管理'),
                      Text('• 不具合対応や品質向上のための調査'),
                      Text('• ユーザーからのお問い合わせへの対応'),
                      SizedBox(height: 16),
                      Text(
                        '4. 第三者提供',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text('運営は、以下の場合を除き、ユーザーの個人情報を第三者に提供しません。'),
                      Text('• ユーザー本人の同意がある場合'),
                      Text('• 法令に基づく場合'),
                      Text('• 人の生命、身体または財産の保護のために必要であり、本人の同意を得ることが困難な場合'),
                      Text('• 国の機関もしくは地方公共団体等が法令に基づき協力を要請した場合'),
                      SizedBox(height: 16),
                      Text(
                        '5. 利用している第三者サービス',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text('• クラウド認証基盤：ログイン機能の提供。認証に必要なメールアドレス等が安全に保存・処理されます。'),
                      SizedBox(height: 16),
                      Text(
                        '6. データの管理と削除',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text('• ユーザーは、アプリ内の機能を通じてローカルデータを編集・削除できます。'),
                      Text('• アカウントを削除すると、クラウド認証基盤に保存されている認証情報も削除されます。'),
                      Text('• ローカルデータの削除やバックアップはユーザー自身の責任において実施してください。'),
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
                        '運営は、合理的な範囲で情報セキュリティ対策を講じますが、全てのリスクを完全に排除できるものではありません。端末の管理やOSアップデートなど、ユーザーによるセキュリティ対策もお願い致します。',
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
                        '本ポリシーの内容は、必要に応じて変更されることがあります。重要な変更がある場合は、本アプリ内での表示等により通知します。',
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
                      Text(
                        '本プライバシーポリシーに関するお問い合わせは、アプリ内の「ヘルプ」→「お問い合わせ」、または taharacomeon.0504@gmail.com（担当：田原果門）までご連絡ください。',
                      ),
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
