#!/bin/bash

# ThisOne - Android App Bundle (AAB) ビルドスクリプト
# Google Play Store用
# 使い方: ./build-aab.sh

echo "ThisOne AABをビルドしています（Google Play用）..."
echo ""

# プロジェクトディレクトリに移動
cd "$(dirname "$0")"

# Supabase環境変数
SUPABASE_URL="https://gpbyfivahcqkebvvpuuo.supabase.co"
SUPABASE_ANON_KEY="eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImdwYnlmaXZhaGNxa2VidnZwdXVvIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDgzMzAwNTUsImV4cCI6MjA2MzkwNjA1NX0.T-NC0Q6ogfDg3-XsAl9zNdx6ShJwoYJyyjQ1wiOrcdA"

# Gradleでビルド
echo "Gradleでリリースビルドを実行中..."
cd android
./gradlew bundleRelease \
  --quiet \
  -Pdart-defines="SUPABASE_URL=${SUPABASE_URL},SUPABASE_ANON_KEY=${SUPABASE_ANON_KEY}"
cd ..

# バージョン情報を取得（pubspec.yamlから）
VERSION=$(grep '^version:' pubspec.yaml | awk '{print $2}')

# デスクトップにコピー
OUTPUT_FILE="$HOME/Desktop/ThisOne-release-${VERSION}.aab"
cp android/app/build/outputs/bundle/release/app-release.aab "$OUTPUT_FILE"

echo ""
echo "ビルド完了！"
echo ""
echo "AABファイル:"
echo "   $(ls -lh "$OUTPUT_FILE" | awk '{print $9, "(" $5 ")"}')"
echo ""
echo "場所: $OUTPUT_FILE"
echo ""
echo "このAABは以下の設定で署名されています:"
echo "   - キーストア: ~/thisone-release-key.jks"
echo "   - エイリアス: thisone"
echo ""
echo "次のステップ:"
echo "   1. Google Play Console (https://play.google.com/console) にアクセス"
echo "   2. アプリを作成または選択"
echo "   3. リリース > 本番環境 または 内部テスト"
echo "   4. このAABファイルをアップロード"
echo ""
echo "詳細な手順は GOOGLE_PLAY_RELEASE_GUIDE.md を参照してください"
echo ""

