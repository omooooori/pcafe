# Google Maps API 設定ガイド

このドキュメントでは、Cafe Parking FinderアプリでGoogle Maps APIを使用するための設定手順を説明します。

## 前提条件

- Googleアカウント
- Google Cloud Consoleへのアクセス権限
- 有効なクレジットカード（Google Cloud Platformの課金設定用）

## 手順1: Google Cloud Consoleでプロジェクトを作成

1. [Google Cloud Console](https://console.cloud.google.com/)にアクセス
2. Googleアカウントでログイン
3. 新しいプロジェクトを作成：
   - 「プロジェクトの選択」→「新しいプロジェクト」
   - プロジェクト名を入力（例: "Cafe Parking Finder"）
   - 「作成」をクリック

## 手順2: 必要なAPIを有効化

以下のAPIを有効化してください：

### Places API
1. 左側のメニューから「APIとサービス」→「ライブラリ」を選択
2. 検索ボックスで「Places API」を検索
3. 「Places API」を選択して「有効にする」をクリック

### Maps SDK for iOS
1. 同様に「Maps SDK for iOS」を検索
2. 「Maps SDK for iOS」を選択して「有効にする」をクリック

### Geocoding API（オプション）
1. 「Geocoding API」を検索
2. 「Geocoding API」を選択して「有効にする」をクリック

## 手順3: APIキーを作成

1. 左側のメニューから「APIとサービス」→「認証情報」を選択
2. 「認証情報を作成」→「APIキー」をクリック
3. 作成されたAPIキーをコピー（後で使用します）

## 手順4: APIキーに制限を設定（推奨）

セキュリティを向上させるために、APIキーに制限を設定することを強く推奨します：

### iOSアプリの制限
1. 作成したAPIキーをクリック
2. 「アプリケーションの制限」で「iOSアプリ」を選択
3. 「+ iOSアプリを追加」をクリック
4. バンドルIDを入力（例: `com.yourcompany.cafeparkingfinder`）

### APIの制限
1. 「APIの制限」で「APIを制限」を選択
2. 以下のAPIのみを選択：
   - Places API
   - Maps SDK for iOS
   - Geocoding API（使用する場合）
3. 「保存」をクリック

## 手順5: アプリにAPIキーを設定

### APIConfig.swiftファイルの編集

1. プロジェクト内の`Utils/APIConfig.swift`ファイルを開く
2. `googleMapsAPIKey`の値を実際のAPIキーに置き換える：

```swift
static let googleMapsAPIKey = "YOUR_ACTUAL_API_KEY_HERE"
```

例：
```swift
static let googleMapsAPIKey = "AIzaSyBxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
```

### Info.plistファイルの確認

`Info.plist`ファイルに以下の設定が含まれていることを確認：

```xml
<key>GMSApiKey</key>
<string>YOUR_GOOGLE_MAPS_API_KEY_HERE</string>
```

## 手順6: 課金の設定

Google Maps Platformは使用量に応じて課金されます：

1. 左側のメニューから「お支払い」を選択
2. 「お支払いアカウントをリンク」をクリック
3. クレジットカード情報を入力
4. 無料枠の設定を確認：
   - Places API: 月間1000リクエスト（無料）
   - Maps SDK for iOS: 月間28,500マップ読み込み（無料）

## 手順7: アプリのテスト

1. Xcodeでプロジェクトをビルド
2. シミュレーターまたは実機でアプリを実行
3. 位置情報の使用許可を許可
4. カフェ検索機能をテスト

## トラブルシューティング

### よくある問題と解決方法

#### 1. "APIキーが無効です"エラー
- APIキーが正しくコピーされているか確認
- APIキーに適切な制限が設定されているか確認
- 必要なAPIが有効化されているか確認

#### 2. "リクエストが拒否されました"エラー
- APIキーの制限設定を確認
- バンドルIDが正しく設定されているか確認
- 課金が有効になっているか確認

#### 3. "API利用制限に達しました"エラー
- 使用量制限を確認
- 無料枠を超えている場合は課金設定を確認

#### 4. 位置情報が取得できない
- Info.plistの位置情報設定を確認
- シミュレーターで位置情報が設定されているか確認

### デバッグ方法

アプリ内でAPI設定の状態を確認できます：

```swift
// デバッグ情報を出力
DebugUtilities.logAPIConfiguration()

// API設定の状態を取得
let status = APIConfigValidation.getAPIConfigurationStatus()
print(status)
```

## セキュリティのベストプラクティス

1. **APIキーの保護**
   - APIキーを公開リポジトリにコミットしない
   - 適切な制限を設定する
   - 定期的にAPIキーをローテーションする

2. **使用量の監視**
   - Google Cloud Consoleで使用量を定期的に確認
   - 予期しない使用量の増加に注意

3. **エラーハンドリング**
   - 適切なエラーメッセージを表示
   - ユーザーフレンドリーなフォールバック機能を実装

## 料金について

### 無料枠
- Places API: 月間1000リクエスト
- Maps SDK for iOS: 月間28,500マップ読み込み
- Geocoding API: 月間1000リクエスト

### 有料プラン
無料枠を超えた場合の料金（2024年時点）：
- Places API: $17 per 1000 requests
- Maps SDK for iOS: $7 per 1000 map loads
- Geocoding API: $5 per 1000 requests

詳細は[Google Maps Platform Pricing](https://cloud.google.com/maps-platform/pricing)を参照してください。

## サポート

問題が解決しない場合は、以下を確認してください：

1. [Google Maps Platform Documentation](https://developers.google.com/maps/documentation)
2. [Google Cloud Console Help](https://cloud.google.com/docs)
3. [Stack Overflow](https://stackoverflow.com/questions/tagged/google-maps-api)

## 更新履歴

- 2024-01-XX: 初版作成
- 設定手順の詳細化
- トラブルシューティングの追加 