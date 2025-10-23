import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../gradients.dart';

/// アプリ情報画面
///
/// 機能:
/// - アプリ名とバージョン情報の表示
/// - ビルド番号の表示
/// - 更新履歴の表示
/// - ライセンス情報の表示
/// - 利用規約へのリンク
/// - プライバシーポリシーへのリンク
/// - 開発者情報の表示
///
/// 画面構成:
/// - アプリアイコンとバージョン情報セクション
/// - 情報セクション（更新履歴、ライセンス）
/// - リンクセクション（利用規約、プライバシーポリシー）
/// - 開発者情報セクション
class AppInfoScreen extends StatefulWidget {
  const AppInfoScreen({super.key});

  @override
  State<AppInfoScreen> createState() => _AppInfoScreenState();
}

class _AppInfoScreenState extends State<AppInfoScreen> {
  PackageInfo? _packageInfo;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPackageInfo();
  }

  /// パッケージ情報を読み込む
  Future<void> _loadPackageInfo() async {
    try {
      final info = await PackageInfo.fromPlatform();
      setState(() {
        _packageInfo = info;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('アプリ情報の読み込みに失敗しました: $e'),
            backgroundColor: Colors.red[700],
          ),
        );
      }
    }
  }

  /// ライセンス情報を表示
  void _showLicenses() {
    showLicensePage(
      context: context,
      applicationName: 'ThisOne',
      applicationVersion: _packageInfo?.version ?? '不明',
      applicationIcon: Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          gradient: createOrangeYellowGradient(),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.apps, color: Colors.white, size: 32),
      ),
    );
  }

  /// 更新履歴を表示
  void _showChangelog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: const Color(0xFF3A3A3A),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Text(
              '更新履歴',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildChangelogItem(
                    version: '1.0.0',
                    date: '2025年1月',
                    changes: [
                      'メモ機能の実装',
                      'スケジュール機能の実装',
                      'タスク管理機能の実装',
                      '設定画面の実装',
                    ],
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  '閉じる',
                  style: TextStyle(color: Color(0xFFE85A3B), fontSize: 16),
                ),
              ),
            ],
          ),
    );
  }

  /// 更新履歴項目を構築
  Widget _buildChangelogItem({
    required String version,
    required String date,
    required List<String> changes,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'v$version ($date)',
          style: const TextStyle(
            color: Color(0xFFE85A3B),
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        ...changes.map(
          (change) => Padding(
            padding: const EdgeInsets.only(left: 8, bottom: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '• ',
                  style: TextStyle(color: Colors.grey[400], fontSize: 14),
                ),
                Expanded(
                  child: Text(
                    change,
                    style: TextStyle(color: Colors.grey[300], fontSize: 14),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  /// URLを開く
  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('リンクを開けませんでした'),
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
                    'アプリについて',
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
              child:
                  _isLoading
                      ? const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFFE85A3B),
                        ),
                      )
                      : SingleChildScrollView(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // アプリアイコンとバージョン情報
                            Center(
                              child: Column(
                                children: [
                                  Container(
                                    width: 100,
                                    height: 100,
                                    decoration: BoxDecoration(
                                      gradient: createOrangeYellowGradient(),
                                      borderRadius: BorderRadius.circular(24),
                                      boxShadow: [
                                        BoxShadow(
                                          color: const Color(
                                            0xFFE85A3B,
                                          ).withOpacity(0.3),
                                          blurRadius: 20,
                                          spreadRadius: 2,
                                        ),
                                      ],
                                    ),
                                    child: const Icon(
                                      Icons.apps,
                                      color: Colors.white,
                                      size: 50,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  const Text(
                                    'ThisOne',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'バージョン ${_packageInfo?.version ?? "不明"}',
                                    style: TextStyle(
                                      color: Colors.grey[400],
                                      fontSize: 16,
                                    ),
                                  ),
                                  Text(
                                    'ビルド ${_packageInfo?.buildNumber ?? "不明"}',
                                    style: TextStyle(
                                      color: Colors.grey[500],
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 32),

                            // 情報セクション
                            _buildSectionHeader('情報'),
                            const SizedBox(height: 12),

                            _buildInfoCard(
                              icon: Icons.history,
                              title: '更新履歴',
                              subtitle: '最新の変更内容を確認',
                              onTap: _showChangelog,
                            ),

                            _buildInfoCard(
                              icon: Icons.description,
                              title: 'ライセンス',
                              subtitle: 'オープンソースライセンス',
                              onTap: _showLicenses,
                            ),

                            const SizedBox(height: 24),

                            // リンクセクション
                            _buildSectionHeader('リンク'),
                            const SizedBox(height: 12),

                            _buildInfoCard(
                              icon: Icons.article,
                              title: '利用規約',
                              subtitle: 'サービス利用規約',
                              onTap:
                                  () => _launchUrl('https://example.com/terms'),
                            ),

                            _buildInfoCard(
                              icon: Icons.privacy_tip,
                              title: 'プライバシーポリシー',
                              subtitle: '個人情報の取り扱い',
                              onTap:
                                  () =>
                                      _launchUrl('https://example.com/privacy'),
                            ),

                            const SizedBox(height: 24),

                            // 開発者情報セクション
                            _buildSectionHeader('開発者情報'),
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
                                          gradient:
                                              createOrangeYellowGradient(),
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: const Icon(
                                          Icons.person,
                                          color: Colors.white,
                                          size: 20,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      const Text(
                                        '開発者',
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
                                    'このアプリは個人開発プロジェクトとして開発されています。',
                                    style: TextStyle(
                                      color: Colors.grey[400],
                                      fontSize: 14,
                                      height: 1.5,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'メモ、スケジュール、タスク管理を一つのアプリで実現し、日々の生活をより便利にすることを目指しています。',
                                    style: TextStyle(
                                      color: Colors.grey[400],
                                      fontSize: 14,
                                      height: 1.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 32),

                            // コピーライト
                            Center(
                              child: Text(
                                '© 2025 ThisOne. All rights reserved.',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 12,
                                ),
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
          child: const Icon(Icons.info, color: Colors.white, size: 20),
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

  /// 情報カードを構築
  ///
  /// [icon] アイコン
  /// [title] タイトル
  /// [subtitle] 説明文
  /// [onTap] タップ時の処理
  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
          child: Icon(icon, color: Colors.white, size: 20),
        ),
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(color: Colors.grey[400], fontSize: 14),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          color: Colors.grey[500],
          size: 16,
        ),
        onTap: onTap,
      ),
    );
  }
}
