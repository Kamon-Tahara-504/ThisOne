import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../gradients.dart';

/// ヘルプ画面
///
/// 機能:
/// - よくある質問（FAQ）- アコーディオン形式
/// - フィードバック送信フォーム
/// - お問い合わせ（メール起動）
///
/// 画面構成:
/// - FAQセクション（ExpansionTileで表示）
/// - フィードバックセクション（テキスト入力+送信ボタン）
/// - お問い合わせセクション（メール起動ボタン）
class HelpScreen extends StatefulWidget {
  const HelpScreen({super.key});

  @override
  State<HelpScreen> createState() => _HelpScreenState();
}

class _HelpScreenState extends State<HelpScreen> {
  final TextEditingController _feedbackController = TextEditingController();
  bool _isSendingFeedback = false;

  // FAQ項目
  final List<Map<String, String>> _faqItems = [
    {
      'question': 'メモの作成方法は？',
      'answer':
          'メモ画面の右下にある「+」ボタンをタップすると、新しいメモを作成できます。テキストモードとチェックリストモードの2種類があります。',
    },
    {
      'question': 'スケジュールとタスクの違いは？',
      'answer':
          'スケジュールは特定の日時に行う予定（会議、イベントなど）を管理します。タスクは完了すべき作業を管理し、優先度や期限を設定できます。',
    },
    {
      'question': 'データはどこに保存されますか？',
      'answer':
          'データはSupabaseのクラウドサーバーに安全に保存されます。ログインすることで、複数のデバイス間でデータを同期できます。',
    },
    {
      'question': 'オフラインでも使えますか？',
      'answer': 'はい。オフラインでもメモ、スケジュール、タスクの閲覧と編集が可能です。インターネット接続が回復すると自動的に同期されます。',
    },
    {
      'question': '削除したデータは復元できますか？',
      'answer': '現在、削除したデータの復元機能はありません。重要なデータは削除前にバックアップを取ることをお勧めします。',
    },
    {
      'question': 'パスワードを忘れた場合は？',
      'answer':
          'ログイン画面の「パスワードを忘れた場合」リンクから、登録したメールアドレスを入力してください。パスワードリセット用のメールが送信されます。',
    },
    {
      'question': 'アカウントを削除したい',
      'answer': '設定画面 → プライバシー → 「アカウントを削除」から削除できます。削除したデータは復元できませんのでご注意ください。',
    },
    {
      'question': '通知が届きません',
      'answer':
          '設定画面 → 通知 で通知が有効になっているか確認してください。また、端末の設定でアプリの通知許可が有効になっているか確認してください。',
    },
  ];

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }

  /// フィードバックを送信
  Future<void> _sendFeedback() async {
    if (_feedbackController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('フィードバック内容を入力してください'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isSendingFeedback = true;
    });

    try {
      // TODO: 実際のフィードバック送信処理を実装
      await Future.delayed(const Duration(seconds: 2));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('フィードバックを送信しました。ありがとうございます！'),
            backgroundColor: Color(0xFFE85A3B),
          ),
        );
        _feedbackController.clear();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('送信に失敗しました: $e'),
            backgroundColor: Colors.red[700],
          ),
        );
      }
    } finally {
      setState(() {
        _isSendingFeedback = false;
      });
    }
  }

  /// お問い合わせメールを起動
  Future<void> _launchEmail() async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: 'support@example.com',
      query: 'subject=ThisOneアプリについてのお問い合わせ',
    );

    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('メールアプリを起動できませんでした'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

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
                    'ヘルプ',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),

            // メインコンテンツ
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // FAQセクション
                    _buildSectionHeader('よくある質問'),
                    const SizedBox(height: 12),

                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF3A3A3A),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[700]!),
                      ),
                      child: Column(
                        children:
                            _faqItems.asMap().entries.map((entry) {
                              final index = entry.key;
                              final item = entry.value;
                              final isLast = index == _faqItems.length - 1;

                              return Column(
                                children: [
                                  Theme(
                                    data: Theme.of(context).copyWith(
                                      dividerColor: Colors.transparent,
                                    ),
                                    child: ExpansionTile(
                                      tilePadding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 4,
                                      ),
                                      leading: Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          gradient:
                                              createOrangeYellowGradient(),
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: const Icon(
                                          Icons.help_outline,
                                          color: Colors.white,
                                          size: 20,
                                        ),
                                      ),
                                      title: Text(
                                        item['question']!,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      iconColor: const Color(0xFFE85A3B),
                                      collapsedIconColor: Colors.grey[500],
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.fromLTRB(
                                            56,
                                            0,
                                            16,
                                            16,
                                          ),
                                          child: Text(
                                            item['answer']!,
                                            style: TextStyle(
                                              color: Colors.grey[300],
                                              fontSize: 14,
                                              height: 1.5,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (!isLast)
                                    Divider(
                                      height: 1,
                                      color: Colors.grey[700],
                                      indent: 16,
                                      endIndent: 16,
                                    ),
                                ],
                              );
                            }).toList(),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // フィードバックセクション
                    _buildSectionHeader('フィードバック'),
                    const SizedBox(height: 12),

                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF3A3A3A),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[700]!),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  gradient: createOrangeYellowGradient(),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  Icons.feedback,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Text(
                                'ご意見・ご要望',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'アプリの改善に役立てるため、ご意見やご要望をお聞かせください。',
                            style: TextStyle(
                              color: Colors.grey[400],
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller: _feedbackController,
                            maxLines: 5,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                            decoration: InputDecoration(
                              hintText: 'ご意見・ご要望をご記入ください...',
                              hintStyle: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                              filled: true,
                              fillColor: const Color(0xFF2B2B2B),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(
                                  color: Colors.grey[700]!,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(
                                  color: Colors.grey[700]!,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(
                                  color: Color(0xFFE85A3B),
                                  width: 2,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed:
                                  _isSendingFeedback ? null : _sendFeedback,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFE85A3B),
                                disabledBackgroundColor: Colors.grey[700],
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child:
                                  _isSendingFeedback
                                      ? const SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                Colors.white,
                                              ),
                                        ),
                                      )
                                      : const Text(
                                        '送信',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // お問い合わせセクション
                    _buildSectionHeader('お問い合わせ'),
                    const SizedBox(height: 12),

                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF3A3A3A),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[700]!),
                      ),
                      child: ListTile(
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            gradient: createOrangeYellowGradient(),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.email,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                        title: const Text(
                          'メールでお問い合わせ',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        subtitle: Text(
                          'support@example.com',
                          style: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 14,
                          ),
                        ),
                        trailing: Icon(
                          Icons.arrow_forward_ios,
                          color: Colors.grey[500],
                          size: 16,
                        ),
                        onTap: _launchEmail,
                      ),
                    ),

                    const SizedBox(height: 16),

                    // 注意事項
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.blue.withOpacity(0.3)),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: Colors.blue[300],
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'お問い合わせへの返信には、数日お時間をいただく場合があります。',
                              style: TextStyle(
                                color: Colors.blue[200],
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// セクションヘッダーを構築する
  ///
  /// [title] セクションのタイトル
  Widget _buildSectionHeader(String title) {
    return Row(
      children: [
        ShaderMask(
          shaderCallback:
              (bounds) => createOrangeYellowGradient().createShader(bounds),
          child: const Icon(Icons.help, color: Colors.white, size: 20),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}
