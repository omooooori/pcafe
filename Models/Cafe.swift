import Foundation
import CoreLocation

/**
 カフェ情報を表現するデータモデル
 
 この構造体は、Google Places APIから取得したカフェの詳細情報を格納します。
 駐車場付きカフェの検索結果として使用され、アプリケーション全体でカフェ情報の標準的な表現として機能します。
 
 ## プロパティ
 - `id`: カフェの一意識別子
 - `name`: カフェ名
 - `address`: 住所
 - `phoneNumber`: 電話番号（オプション）
 - `rating`: Google評価（0.0-5.0、オプション）
 - `userRatingsTotal`: 評価総数（オプション）
 - `priceLevel`: 価格レベル（1-4、オプション）
 - `placeId`: Google Places APIのplace_id
 - `location`: 緯度・経度座標
 - `types`: カフェの種類タグ配列
 - `openingHours`: 営業時間情報（オプション）
 - `photos`: 写真情報配列（オプション）
 - `website`: WebサイトURL（オプション）
 - `isFavorite`: お気に入りフラグ
 
 ## 使用例
 ```swift
 let cafe = Cafe(
     id: "cafe_123",
     name: "スターバックス 渋谷店",
     address: "東京都渋谷区...",
     rating: 4.2,
     location: CLLocationCoordinate2D(latitude: 35.6580, longitude: 139.7016)
 )
 ```
 
 - Author: Cafe Parking Finder Team
 - Version: 1.0.0
 - Since: 2024
 */
struct Cafe: Identifiable, Codable {
    let id: String
    let name: String
    let address: String
    let phoneNumber: String?
    let rating: Double?
    let userRatingsTotal: Int?
    let priceLevel: Int?
    let placeId: String
    let location: CLLocationCoordinate2D
    let types: [String]
    let openingHours: OpeningHours?
    let photos: [Photo]?
    let website: String?
    let isFavorite: Bool
    
    /**
     営業時間情報を表現する構造体
     
     カフェの営業時間に関する詳細情報を格納します。
     
     ## プロパティ
     - `openNow`: 現在営業中かどうか
     - `periods`: 営業時間の詳細期間配列（オプション）
     - `weekdayText`: 曜日別営業時間テキスト配列（オプション）
     */
    struct OpeningHours: Codable {
        let openNow: Bool
        let periods: [Period]?
        let weekdayText: [String]?
        
        /**
         営業時間の期間を表現する構造体
         
         特定の曜日の営業時間を表現します。
         
         ## プロパティ
         - `open`: 開店時間
         - `close`: 閉店時間
         */
        struct Period: Codable {
            let open: DayTime
            let close: DayTime
            
            /**
             曜日と時間を表現する構造体
             
             ## プロパティ
             - `day`: 曜日（0=日曜日、1=月曜日、...、6=土曜日）
             - `time`: 時間（HHMM形式、例："0900"）
             */
            struct DayTime: Codable {
                let day: Int
                let time: String
            }
        }
    }
    
    /**
     カフェの写真情報を表現する構造体
     
     Google Places APIから取得した写真のメタデータを格納します。
     
     ## プロパティ
     - `photoReference`: Google Places APIの写真参照ID
     - `height`: 写真の高さ（ピクセル）
     - `width`: 写真の幅（ピクセル）
     */
    struct Photo: Codable {
        let photoReference: String
        let height: Int
        let width: Int
    }
}

// MARK: - CLLocationCoordinate2D Codable Extension

/**
 CLLocationCoordinate2DのCodable準拠拡張
 
 CoreLocationのCLLocationCoordinate2DをJSONエンコード/デコード可能にするための拡張です。
 
 ## 使用例
 ```swift
 let coordinate = CLLocationCoordinate2D(latitude: 35.6580, longitude: 139.7016)
 let jsonData = try JSONEncoder().encode(coordinate)
 let decodedCoordinate = try JSONDecoder().decode(CLLocationCoordinate2D.self, from: jsonData)
 ```
 */
extension CLLocationCoordinate2D: Codable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let latitude = try container.decode(Double.self, forKey: .latitude)
        let longitude = try container.decode(Double.self, forKey: .longitude)
        self.init(latitude: latitude, longitude: longitude)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(latitude, forKey: .latitude)
        try container.encode(longitude, forKey: .longitude)
    }
    
    private enum CodingKeys: String, CodingKey {
        case latitude, longitude
    }
} 