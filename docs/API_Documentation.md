# API Documentation

## Google Places API

### 概要

Cafe Parking Finder Appは、Google Places APIを使用して駐車場付きのカフェ情報を取得します。

### 必要なAPI

1. **Places API (Nearby Search)**
   - 現在位置周辺のカフェ検索
   - 駐車場情報の含まれた検索

2. **Places API (Place Details)**
   - カフェの詳細情報取得
   - 営業時間、電話番号、Webサイト情報

### API設定手順

#### 1. Google Cloud Consoleでの設定

1. [Google Cloud Console](https://console.cloud.google.com/)にアクセス
2. 新しいプロジェクトを作成または既存プロジェクトを選択
3. 以下のAPIを有効化：
   - Places API
   - Maps JavaScript API（オプション）

#### 2. APIキーの生成

1. 「認証情報」ページに移動
2. 「認証情報を作成」→「APIキー」を選択
3. 生成されたAPIキーをコピー

#### 3. APIキーの制限設定（推奨）

セキュリティのため、APIキーに制限を設定することを推奨します：

- **アプリケーション制限**: iOSアプリ
- **API制限**: Places APIのみ

### API使用量と制限

#### 無料枠
- **Nearby Search**: 1,000リクエスト/日
- **Place Details**: 1,000リクエスト/日

#### 有料枠
- **Nearby Search**: $17/1,000リクエスト
- **Place Details**: $17/1,000リクエスト

### 実装例

#### Nearby Search API

```swift
// 検索パラメータ
let parameters = [
    "location": "35.6580,139.7016",  // 緯度,経度
    "radius": "1000",                // 検索半径（メートル）
    "keyword": "カフェ 駐車場",        // 検索キーワード
    "type": "cafe",                  // 場所タイプ
    "key": "YOUR_API_KEY",           // APIキー
    "language": "ja"                 // 言語設定
]

// URL構築
var components = URLComponents(string: "https://maps.googleapis.com/maps/api/place/nearbysearch/json")!
components.queryItems = parameters.map { URLQueryItem(name: $0.key, value: $0.value) }
```

#### Place Details API

```swift
// 詳細取得パラメータ
let parameters = [
    "place_id": "ChIJN1t_tDeuEmsRUsoyG83frY4",  // 場所ID
    "fields": "name,formatted_address,formatted_phone_number,rating,user_ratings_total,price_level,geometry,opening_hours,photos,website",
    "key": "YOUR_API_KEY",
    "language": "ja"
]
```

### レスポンス例

#### Nearby Search Response

```json
{
  "status": "OK",
  "results": [
    {
      "place_id": "ChIJN1t_tDeuEmsRUsoyG83frY4",
      "name": "スターバックス 渋谷店",
      "vicinity": "東京都渋谷区渋谷2-24-12",
      "geometry": {
        "location": {
          "lat": 35.6580,
          "lng": 139.7016
        }
      },
      "rating": 4.2,
      "user_ratings_total": 1250,
      "price_level": 2,
      "types": ["cafe", "food", "establishment"],
      "photos": [
        {
          "photo_reference": "CmRaAAAA...",
          "height": 400,
          "width": 600
        }
      ]
    }
  ]
}
```

#### Place Details Response

```json
{
  "status": "OK",
  "result": {
    "place_id": "ChIJN1t_tDeuEmsRUsoyG83frY4",
    "name": "スターバックス 渋谷店",
    "formatted_address": "東京都渋谷区渋谷2-24-12",
    "formatted_phone_number": "03-1234-5678",
    "rating": 4.2,
    "user_ratings_total": 1250,
    "price_level": 2,
    "website": "https://www.starbucks.co.jp/",
    "opening_hours": {
      "open_now": true,
      "weekday_text": [
        "月曜日: 7:00–22:00",
        "火曜日: 7:00–22:00",
        "水曜日: 7:00–22:00",
        "木曜日: 7:00–22:00",
        "金曜日: 7:00–22:00",
        "土曜日: 7:00–22:00",
        "日曜日: 7:00–22:00"
      ]
    }
  }
}
```

### エラーハンドリング

#### 主要なエラーコード

- **OK**: リクエスト成功
- **ZERO_RESULTS**: 検索結果なし
- **OVER_QUERY_LIMIT**: API利用制限超過
- **REQUEST_DENIED**: リクエスト拒否（APIキー無効など）
- **INVALID_REQUEST**: 無効なリクエスト
- **UNKNOWN_ERROR**: 不明なエラー

#### エラーハンドリング実装例

```swift
enum PlacesError: Error, LocalizedError {
    case invalidAPIKey
    case networkError(Error)
    case invalidResponse
    case quotaExceeded
    case requestDenied
    
    var errorDescription: String? {
        switch self {
        case .invalidAPIKey:
            return "APIキーが無効です。"
        case .networkError(let error):
            return "ネットワークエラー: \(error.localizedDescription)"
        case .invalidResponse:
            return "サーバーからの応答が無効です。"
        case .quotaExceeded:
            return "API利用制限に達しました。"
        case .requestDenied:
            return "リクエストが拒否されました。"
        }
    }
}
```

### ベストプラクティス

#### 1. キャッシュの活用
- 同じ場所の検索結果をキャッシュ
- 不要なAPI呼び出しを削減

#### 2. エラーハンドリング
- ネットワークエラーの適切な処理
- ユーザーフレンドリーなエラーメッセージ

#### 3. レート制限の考慮
- API利用制限の監視
- 適切なリトライロジック

#### 4. セキュリティ
- APIキーの適切な管理
- クライアントサイドでの制限設定

### トラブルシューティング

#### よくある問題

1. **APIキーが無効**
   - APIキーの設定を確認
   - 制限設定を確認

2. **利用制限超過**
   - 使用量を確認
   - 有料枠への移行を検討

3. **検索結果が少ない**
   - 検索半径の調整
   - キーワードの見直し

4. **レスポンスが遅い**
   - ネットワーク接続を確認
   - キャッシュの活用

### 参考リンク

- [Google Places API Documentation](https://developers.google.com/maps/documentation/places/web-service)
- [Places API Pricing](https://cloud.google.com/maps-platform/pricing)
- [API Key Best Practices](https://developers.google.com/maps/api-security-best-practices) 