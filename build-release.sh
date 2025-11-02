#!/bin/bash

# ThisOne - Android リリースAPKビルドスクリプト
# 使い方: ./build-release.sh

echo "ThisOne リリースAPKをビルドしています..."
echo ""

# プロジェクトディレクトリに移動
cd "$(dirname "$0")"

# Supabase環境変数
SUPABASE_URL="https://gpbyfivahcqkebvvpuuo.supabase.co"
SUPABASE_ANON_KEY="eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImdwYnlmaXZhaGNxa2VidnZwdXVvIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDgzMzAwNTUsImV4cCI6MjA2MzkwNjA1NX0.T-NC0Q6ogfDg3-XsAl9zNdx6ShJwoYJyyjQ1wiOrcdA"

# クリーンビルド（オプション - 問題がある場合のみ実行）
# flutter clean
# flutter pub get

# Gradleで直接ビルド（Flutterツールの問題を回避）
echo "Gradleでリリースビルドを実行中..."
cd android
./gradlew assembleRelease \
  --quiet \
  -Pdart-defines="SUPABASE_URL=${SUPABASE_URL},SUPABASE_ANON_KEY=${SUPABASE_ANON_KEY}"
cd ..

# APKファイルを標準的な場所にコピー
mkdir -p build/app/outputs/flutter-apk
cp android/app/build/outputs/apk/release/app-release.apk build/app/outputs/flutter-apk/app-release.apk

# バージョン情報を取得（pubspec.yamlから）
VERSION=$(grep '^version:' pubspec.yaml | awk '{print $2}')

# デスクトップにコピー
OUTPUT_FILE="$HOME/Desktop/ThisOne-release-${VERSION}.apk"
cp build/app/outputs/flutter-apk/app-release.apk "$OUTPUT_FILE"

echo ""
echo "ビルド完了！"
echo ""
echo "APKファイル:"
echo "   $(ls -lh "$OUTPUT_FILE" | awk '{print $9, "(" $5 ")"}')"
echo ""
echo "場所: $OUTPUT_FILE"
echo ""
echo "このAPKは以下の設定で署名されています:"
echo "   - キーストア: ~/thisone-release-key.jks"
echo "   - エイリアス: thisone"
echo ""
echo "次のステップ:"
echo "   1. Google Play Console にアップロード"
echo "   2. または、このAPKを直接配布"
echo ""

