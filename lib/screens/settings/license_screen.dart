import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../../widgets/app_bars/static_header_guideline.dart';

/// ライセンス情報画面（カスタム）
///
/// Flutterの標準ライセンスページをカスタマイズした画面
/// 他の設定画面と同じヘッダースタイルを適用
class LicenseScreen extends StatefulWidget {
  const LicenseScreen({super.key});

  @override
  State<LicenseScreen> createState() => _LicenseScreenState();
}

class _LicenseScreenState extends State<LicenseScreen> {
  List<LicenseEntry> _licenses = [];
  Map<String, int> _packageLicenseCounts = {};
  PackageInfo? _packageInfo;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadLicenses();
    _loadPackageInfo();
  }

  /// パッケージ情報を読み込む
  Future<void> _loadPackageInfo() async {
    try {
      final info = await PackageInfo.fromPlatform();
      if (mounted) {
        setState(() {
          _packageInfo = info;
        });
      }
    } catch (e) {
      // エラーは無視（バージョン情報が取得できないだけ）
    }
  }

  /// ライセンス情報を読み込む
  Future<void> _loadLicenses() async {
    final licenses = <LicenseEntry>[];
    final packageCounts = <String, int>{};

    await LicenseRegistry.licenses.forEach((license) {
      licenses.add(license);
      if (license.packages.isNotEmpty) {
        final package = license.packages.first;
        packageCounts[package] = (packageCounts[package] ?? 0) + 1;
      }
    });

    if (mounted) {
      setState(() {
        _licenses = licenses;
        _packageLicenseCounts = packageCounts;
        _isLoading = false;
      });
    }
  }

  /// パッケージのライセンス詳細を表示
  void _showLicenseDetail(String packageName) {
    final packageLicenses =
        _licenses
            .where((license) => license.packages.contains(packageName))
            .toList();

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: const Color(0xFF3A3A3A),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Text(
              packageName,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            content: SizedBox(
              width: double.maxFinite,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children:
                      packageLicenses.expand((license) {
                        return license.paragraphs.map((paragraph) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12.0),
                            child: Text(
                              paragraph.text,
                              style: TextStyle(
                                color: Colors.grey[300],
                                fontSize: 14,
                                height: 1.5,
                              ),
                            ),
                          );
                        });
                      }).toList(),
                ),
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
                    'ライセンス',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),

            // オレンジグラデーションライン
            const StaticHeaderGuideline(),

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
                            // アプリ情報セクション
                            Center(
                              child: Column(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(16),
                                    child: Image.asset(
                                      'assets/icons/app_icon.png',
                                      width: 64,
                                      height: 64,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  const Text(
                                    'ThisOne',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    _packageInfo?.version ?? '不明',
                                    style: TextStyle(
                                      color: Colors.grey[400],
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'Powered by Flutter',
                                    style: TextStyle(
                                      color: Colors.grey[500],
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 32),

                            // ライセンス一覧
                            ...(_packageLicenseCounts.entries.toList()
                                  ..sort((a, b) => a.key.compareTo(b.key)))
                                .map((entry) {
                                  return Container(
                                    margin: const EdgeInsets.only(bottom: 8),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF3A3A3A),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: Colors.grey[700]!,
                                      ),
                                    ),
                                    child: ListTile(
                                      title: Text(
                                        entry.key,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      trailing: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            'ライセンス: ${entry.value}件',
                                            style: TextStyle(
                                              color: Colors.grey[400],
                                              fontSize: 14,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Icon(
                                            Icons.arrow_forward_ios,
                                            color: Colors.grey[500],
                                            size: 16,
                                          ),
                                        ],
                                      ),
                                      onTap:
                                          () => _showLicenseDetail(entry.key),
                                    ),
                                  );
                                }),
                          ],
                        ),
                      ),
            ),
          ],
        ),
      ),
    );
  }
}
