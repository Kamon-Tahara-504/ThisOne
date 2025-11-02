import 'package:flutter/material.dart';
import '../../widgets/app_bars/static_header_guideline.dart';

/// 利用規約（アプリ内表示）
class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

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
                    '利用規約',
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
                        'ThisOne 利用規約',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFE85A3B),
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        '最終更新日: 2025年1月',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      SizedBox(height: 24),
                      Text(
                        '第1条（適用）',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        '本規約は、本アプリケーション「ThisOne」（以下「本アプリ」といいます）の利用に関する条件を定めるものです。ユーザーは、本アプリをダウンロードまたは利用することにより、本規約に同意したものとみなされます。',
                      ),
                      SizedBox(height: 16),
                      Text(
                        '第2条（サービスの内容）',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text('本アプリは、以下の機能を提供します：'),
                      SizedBox(height: 8),
                      Text('1. タスク管理機能'),
                      Text('2. スケジュール管理機能'),
                      Text('3. メモ作成・管理機能'),
                      Text('4. データのローカル保存およびエクスポート機能'),
                      SizedBox(height: 16),
                      Text(
                        '第3条（アカウント）',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'ユーザーは、アカウント登録を行うことで、より多くの機能を利用できます。アカウント情報の管理はユーザー自身の責任で行うものとします。',
                      ),
                      SizedBox(height: 16),
                      Text(
                        '第4条（禁止事項）',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text('本アプリの利用にあたり、以下の行為を禁止します：'),
                      SizedBox(height: 8),
                      Text('1. 法令または公序良俗に違反する行為'),
                      Text('2. 犯罪行為に関連する行為'),
                      Text('3. 本アプリの運営を妨害する行為'),
                      Text('4. 他のユーザーに対する迷惑行為'),
                      Text('5. 不正アクセスまたはこれを試みる行為'),
                      Text('6. 本アプリを逆コンパイル、逆アセンブル、リバースエンジニアリングする行為'),
                      Text('7. その他、運営が不適切と判断する行為'),
                      SizedBox(height: 16),
                      Text(
                        '第5条（免責事項）',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        '1. 本アプリは現状有姿で提供され、運営は本アプリの完全性、正確性、確実性、有用性等について、いかなる保証も行いません。',
                      ),
                      SizedBox(height: 8),
                      Text(
                        '2. 運営は、本アプリの利用により生じたいかなる損害（データの消失、端末の故障等を含みますがこれらに限りません）についても、一切の責任を負いません。',
                      ),
                      SizedBox(height: 8),
                      Text('3. ユーザーは、定期的にデータのバックアップを行うことを推奨します。'),
                      SizedBox(height: 16),
                      Text(
                        '第6条（サービスの変更・停止）',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        '運営は、事前の通知なく本アプリの内容を変更、または提供を停止することがあります。これによりユーザーに生じた損害について、運営は一切の責任を負いません。',
                      ),
                      SizedBox(height: 16),
                      Text(
                        '第7条（知的財産権）',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        '本アプリに関する知的財産権は、すべて運営または正当な権利者に帰属します。ユーザーは、本アプリの利用許諾を受けるものであり、所有権を取得するものではありません。',
                      ),
                      SizedBox(height: 16),
                      Text(
                        '第8条（規約の変更）',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        '運営は、必要に応じて本規約を変更することができます。変更後の規約は、本アプリ内での掲示により効力を生じるものとします。',
                      ),
                      SizedBox(height: 16),
                      Text(
                        '第9条（準拠法および管轄裁判所）',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        '本規約の解釈にあたっては、日本法を準拠法とします。本アプリに関して紛争が生じた場合には、運営の所在地を管轄する裁判所を専属的合意管轄とします。',
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
