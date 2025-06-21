# Cafe Parking Finder App

## 概要

Cafe Parking Finder Appは、駐車場付きのカフェを簡単に見つけることができるiOSアプリケーションです。ユーザーの現在位置を基に、近隣のカフェを検索し、駐車場の有無や評価、価格帯などの情報を提供します。

## 主な機能

- 📍 **位置情報ベースの検索**: 現在位置から半径1km以内のカフェを検索
- 🚗 **駐車場情報**: 駐車場付きのカフェのみを表示
- ⭐ **評価・レビュー**: Google Places APIから取得した評価情報を表示
- 💰 **価格帯表示**: 価格レベル（¥〜¥¥¥¥）を表示
- 🗺️ **地図表示**: カフェの位置を地図上で確認
- 🔍 **フィルタリング**: 評価、価格帯、営業時間で絞り込み
- 📱 **詳細情報**: カフェの詳細情報、写真、営業時間を表示
- 🗺️ **経路案内**: Apple Mapsで経路案内を開始

## 技術スタック

### フレームワーク・ライブラリ
- **SwiftUI**: モダンなUIフレームワーク
- **Combine**: リアクティブプログラミング
- **CoreLocation**: 位置情報サービス
- **MapKit**: 地図表示機能

### 外部API
- **Google Places API**: カフェ情報の取得
- **Google Maps API**: 地図・位置情報サービス

### アーキテクチャ
- **MVVM (Model-View-ViewModel)**: アーキテクチャパターン
- **Combine**: データバインディング
- **Protocol-Oriented Programming**: Swiftの設計原則

## セットアップ方法

### 前提条件
- Xcode 14.0以上
- iOS 16.0以上
- Google Places APIキー

### 1. リポジトリのクローン
```bash
git clone [repository-url]
cd pcafe
```

### 2. Google Places APIキーの設定
1. [Google Cloud Console](https://console.cloud.google.com/)でプロジェクトを作成
2. Places APIを有効化
3. APIキーを生成
4. `Utils/Constants.swift`または環境変数でAPIキーを設定

### 3. 依存関係のインストール
```bash
# このプロジェクトは外部依存関係なし（標準ライブラリのみ使用）
```

### 4. ビルド・実行
```bash
# Xcodeでプロジェクトを開く
open CafeParkingFinderApp.xcodeproj

# または
xcodebuild -scheme CafeParkingFinderApp -destination 'platform=iOS Simulator,name=iPhone 15'
```

## プロジェクト構造

```
CafeParkingFinderApp/
├── CafeParkingFinderAppApp.swift    # アプリケーションのエントリーポイント
├── Models/                          # データモデル
│   ├── Cafe.swift                   # カフェ情報モデル
│   └── SearchFilter.swift           # 検索フィルターモデル
├── Views/                           # SwiftUIビュー
│   ├── MainTabView.swift            # メインタブビュー
│   ├── CafeListView.swift           # カフェ一覧表示
│   ├── CafeDetailView.swift         # カフェ詳細表示
│   ├── MapView.swift                # 地図表示
│   ├── FilterView.swift             # フィルター設定
│   └── SplashView.swift             # スプラッシュ画面
├── ViewModels/                      # ビューモデル
│   └── CafeSearchViewModel.swift    # カフェ検索ビューモデル
├── Services/                        # サービス層
│   ├── GooglePlacesService.swift    # Google Places APIサービス
│   └── LocationService.swift        # 位置情報サービス
├── Utils/                           # ユーティリティ
│   ├── Constants.swift              # 定数定義
│   └── Utilities.swift              # 汎用ユーティリティ
├── Extensions/                      # Swift拡張
├── Mock/                            # モックデータ
│   ├── MockData.swift               # モックデータ
│   └── MockServices.swift           # モックサービス
└── Resources/                       # リソースファイル
```

## 簡単な使い方

### 1. アプリ起動
- アプリを起動すると、位置情報の許可を求められます
- 許可後、現在位置周辺のカフェが自動的に検索されます

### 2. カフェ検索
- 地図上でピンをタップしてカフェを選択
- リスト表示でカフェ一覧を確認
- フィルターボタンで検索条件を調整

### 3. 詳細確認
- カフェをタップして詳細情報を表示
- 写真、営業時間、評価を確認
- 「経路案内」ボタンでApple Mapsを起動

### 4. フィルタリング
- 最小評価、最大価格レベル、営業中のみ表示を設定
- 距離、評価、価格でソート

## API設定

### Google Places API
```swift
// Utils/Constants.swiftで設定
struct API {
    static let googlePlacesBaseURL = "https://maps.googleapis.com/maps/api/place"
    static let defaultLanguage = "ja"
    static let defaultRadius = 1000.0
}
```

### 必要なAPI権限
- Places API (Nearby Search)
- Places API (Place Details)
- Maps JavaScript API (オプション)

## 開発ガイドライン

### コーディング規約
- SwiftUIのベストプラクティスに従う
- Combineを使用したリアクティブプログラミング
- MVVMアーキテクチャの遵守
- SwiftDocスタイルのコメント

### テスト
```bash
# ユニットテストの実行
xcodebuild test -scheme CafeParkingFinderApp -destination 'platform=iOS Simulator,name=iPhone 15'
```

### デバッグ
- Xcodeのデバッガーを使用
- コンソールログでAPI応答を確認
- 位置情報シミュレーターでテスト

## トラブルシューティング

### よくある問題

1. **位置情報が取得できない**
   - 設定 > プライバシー > 位置情報サービスを確認
   - アプリの位置情報許可を確認

2. **カフェが表示されない**
   - ネットワーク接続を確認
   - Google Places APIキーが正しく設定されているか確認
   - API利用制限に達していないか確認

3. **地図が表示されない**
   - インターネット接続を確認
   - MapKitの設定を確認

## ライセンス

このプロジェクトはMITライセンスの下で公開されています。

## 貢献

プルリクエストやイシューの報告を歓迎します。貢献する前に、以下の点を確認してください：

1. コーディング規約に従う
2. テストを追加する
3. ドキュメントを更新する

## 更新履歴

### v1.0.0
- 初回リリース
- 基本的なカフェ検索機能
- 地図表示機能
- フィルタリング機能

---

**注意**: このアプリを使用するには、有効なGoogle Places APIキーが必要です。

## 開発状況

🚧 **現在開発中** 🚧

このプロジェクトは現在活発に開発中です。新機能や改善点を随時追加予定です。 