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
                        '最終更新日: 2025年11月',
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
                        '本規約は、本アプリケーション「ThisOne」（以下「本アプリ」といいます）の利用条件を定めるものです。ユーザーは、本アプリをダウンロードまたは利用することにより、本規約に同意したものとみなされます。',
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
                      Text(
                        '本アプリは、タスク管理・スケジュール管理・メモ作成等の機能を提供し、これらのデータを端末内のローカルデータベースに保存します。認証にはSupabaseを利用し、認証に必要な情報のみをクラウドで取り扱います。',
                      ),
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
                        'ユーザーは、メールアドレス等を登録することで本アプリのアカウントを作成できます。アカウント管理および認証情報の保護はユーザー自身の責任で行うものとします。',
                      ),
                      SizedBox(height: 16),
                      Text(
                        '第4条（データの取り扱い）',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        '1. 本アプリで作成・保存されたタスク、スケジュール、メモ等のデータはユーザーの端末内に保存されます。',
                      ),
                      Text(
                        '2. ユーザーはデータのバックアップやエクスポートを自己の責任で行うものとし、端末紛失・故障等によるデータ消失について、運営は責任を負いません。',
                      ),
                      SizedBox(height: 16),
                      Text(
                        '第5条（禁止事項）',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text('ユーザーは、本アプリの利用にあたり、以下の行為を行ってはなりません。'),
                      Text('1. 法令または公序良俗に反する行為'),
                      Text('2. 犯罪行為に関連する行為'),
                      Text('3. 本アプリの運営を妨害する行為'),
                      Text('4. 他のユーザーに対する迷惑行為'),
                      Text('5. 不正アクセスまたはそれを試みる行為'),
                      Text('6. 本アプリを逆コンパイル、逆アセンブル、リバースエンジニアリングする行為'),
                      Text('7. その他、運営が不適切と判断する行為'),
                      SizedBox(height: 16),
                      Text(
                        '第6条（免責事項）',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text('1. 運営は、本アプリを現状有姿で提供し、その完全性・正確性・有用性等について保証しません。'),
                      Text(
                        '2. ユーザーの端末環境、通信環境、バックアップ状況等に起因して生じた損害（データ消失、端末故障等を含む）について、運営は責任を負いません。',
                      ),
                      Text(
                        '3. 運営の故意または重過失による場合を除き、運営は本アプリの利用によりユーザーに生じた損害について責任を負いません。',
                      ),
                      SizedBox(height: 16),
                      Text(
                        '第7条（サービスの変更・停止）',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        '運営は、ユーザーへ事前に通知することなく、本アプリの内容の全部または一部を変更、停止または終了することができます。これによりユーザーに生じた損害について、運営は責任を負いません。',
                      ),
                      SizedBox(height: 16),
                      Text(
                        '第8条（知的財産権）',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        '本アプリに関する知的財産権は、運営または正当な権利者に帰属します。ユーザーは、本アプリに関し許諾された範囲内で利用することができます。',
                      ),
                      SizedBox(height: 16),
                      Text(
                        '第9条（規約の変更）',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        '運営は、必要と判断した場合、本規約を変更することができます。変更後の規約は、本アプリ内への掲示その他運営が適切と判断する方法で通知した時点から効力を生じます。',
                      ),
                      SizedBox(height: 16),
                      Text(
                        '第10条（準拠法および管轄）',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        '本規約の解釈には日本法を準拠法とします。本アプリに関してユーザーと運営の間で紛争が生じた場合、運営所在地を管轄する裁判所を第一審の専属的合意管轄裁判所とします。',
                      ),
                      SizedBox(height: 16),
                      Text(
                        '第11条（お問い合わせ先）',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        '本アプリおよび本規約に関するお問い合わせは、taharacomeon.0504@gmail.com までご連絡ください（担当：田原果門）。',
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
