# 今の状況

1. レイアウト作成 (済)
    - エリア選択フォーム作成
    - グラフ用のグリッド表示作成
    - エリア選択とグラフ用のグリッドを上下に配置, グリッド部分のみ必要に応じてスクロールさせる
2. jsonファイルからグラフ作成
    1. ローカルのjsonを読み込んでグラフ描画 (作業中)
        - ローカルにjsonを配置 (json/sample.json) (済)
        - ローカルからjsonを読み込む設定を pubspec.yaml に追加 (済)
        - jsonをパース
        - jsonからグラフを描く
        - 各grid内でグラフ描画用classを呼び出す
    2. サーバーのjsonを読み込んでグラフ描画

# my_app

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://flutter.dev/docs/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://flutter.dev/docs/cookbook)

For help getting started with Flutter, view our
[online documentation](https://flutter.dev/docs), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
