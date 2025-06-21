import Foundation
import CoreLocation

/**
 アプリケーション全体で使用される定数を定義する構造体
 
 この構造体は、API設定、UI設定、検索設定、エラーメッセージなど、
 アプリケーション全体で使用される定数をカテゴリ別に整理して提供します。
 
 ## カテゴリ
 - **API**: Google Places API関連の設定
 - **Location**: 位置情報関連の設定
 - **UI**: ユーザーインターフェース関連の設定
 - **Search**: 検索機能関連の設定
 - **ErrorMessages**: エラーメッセージ
 - **UserDefaultsKeys**: UserDefaultsのキー
 - **FileNames**: ファイル名
 - **NotificationNames**: 通知名
 
 ## 使用例
 ```swift
 // API設定の使用
 let baseURL = Constants.API.googlePlacesBaseURL
 let defaultRadius = Constants.API.defaultRadius

 // UI設定の使用
 let cornerRadius = Constants.UI.cornerRadius
 let primaryColor = Constants.UI.Colors.primary

 // エラーメッセージの使用
 let errorMessage = Constants.ErrorMessages.locationPermissionDenied
 ```
 
 - Author: Cafe Parking Finder Team
 - Version: 1.0.0
 - Since: 2024
 */
struct Constants {
    // MARK: - API Configuration
    
    /**
     Google Places API関連の設定定数
     
     APIのベースURL、デフォルト言語、検索半径などの設定を定義します。
     */
    struct API {
        /// Google Places APIのベースURL
        static let googlePlacesBaseURL = "https://maps.googleapis.com/maps/api/place"
        
        /// Google Maps APIのベースURL
        static let googleMapsBaseURL = "https://maps.googleapis.com/maps/api"
        
        /// デフォルト言語設定（日本語）
        static let defaultLanguage = "ja"
        
        /// デフォルト検索半径（メートル）
        static let defaultRadius = 1000.0
        
        /// 最大検索半径（メートル）
        static let maxRadius = 5000.0
        
        /// 最小検索半径（メートル）
        static let minRadius = 500.0
    }
    
    // MARK: - Location Configuration
    
    /**
     位置情報関連の設定定数
     
     位置情報の精度、フィルター、デフォルト位置などの設定を定義します。
     */
    struct Location {
        /// 位置情報の精度設定
        static let defaultAccuracy = kCLLocationAccuracyBest
        
        /// 位置情報更新の距離フィルター（メートル）
        static let distanceFilter = 10.0
        
        /// 東京のデフォルト位置（渋谷）
        static let tokyoLocation = CLLocationCoordinate2D(latitude: 35.6762, longitude: 139.6503)
        
        /// デフォルトの地図表示領域
        static let defaultRegion = MKCoordinateRegion(
            center: tokyoLocation,
            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        )
    }
    
    // MARK: - UI Configuration
    
    /**
     ユーザーインターフェース関連の設定定数
     
     UIのサイズ、色、アニメーションなどの設定を定義します。
     */
    struct UI {
        /// 角丸の半径
        static let cornerRadius: CGFloat = 12
        
        /// ボタンの高さ
        static let buttonHeight: CGFloat = 44
        
        /// 標準的な間隔
        static let spacing: CGFloat = 16
        
        /// 小さな間隔
        static let smallSpacing: CGFloat = 8
        
        /// 大きな間隔
        static let largeSpacing: CGFloat = 24
        
        /**
         UIで使用する色の定義
         
         アプリケーション全体で統一された色を使用するための定数です。
         */
        struct Colors {
            /// プライマリカラー（ブラウン）
            static let primary = "Brown"
            
            /// セカンダリカラー（グレー）
            static let secondary = "Gray"
            
            /// 背景色
            static let background = "BackgroundColor"
            
            /// アクセントカラー
            static let accent = "AccentColor"
        }
        
        /**
         アニメーション関連の設定
         
         アニメーションの持続時間を定義します。
         */
        struct Animation {
            /// デフォルトのアニメーション時間
            static let defaultDuration: Double = 0.3
            
            /// 遅いアニメーション時間
            static let slowDuration: Double = 0.5
            
            /// 速いアニメーション時間
            static let fastDuration: Double = 0.15
        }
    }
    
    // MARK: - Search Configuration
    
    /**
     検索機能関連の設定定数
     
     検索キーワード、タイプ、結果数制限などの設定を定義します。
     */
    struct Search {
        /// デフォルトの検索キーワード（駐車場付きカフェ）
        static let defaultKeyword = "カフェ 駐車場"
        
        /// デフォルトの場所タイプ（カフェ）
        static let defaultType = "cafe"
        
        /// 最大検索結果数
        static let maxResults = 20
        
        /// デフォルトの最小評価
        static let defaultMinRating: Double = 0.0
        
        /// デフォルトの最大価格レベル
        static let defaultMaxPriceLevel = 4
    }
    
    // MARK: - Error Messages
    
    /**
     エラーメッセージの定義
     
     アプリケーション全体で使用される統一されたエラーメッセージを定義します。
     ユーザーフレンドリーで分かりやすいメッセージを提供します。
     */
    struct ErrorMessages {
        /// 位置情報許可拒否時のメッセージ
        static let locationPermissionDenied = "位置情報の使用が拒否されました。設定から許可してください。"
        
        /// 位置情報利用不可時のメッセージ
        static let locationUnavailable = "位置情報が利用できません。"
        
        /// ネットワークエラー時のメッセージ
        static let networkError = "ネットワークエラーが発生しました。"
        
        /// API利用制限超過時のメッセージ
        static let apiQuotaExceeded = "API利用制限に達しました。しばらく時間をおいてから再試行してください。"
        
        /// 無効なレスポンス時のメッセージ
        static let invalidResponse = "サーバーからの応答が無効です。"
        
        /// 不明なエラー時のメッセージ
        static let unknownError = "予期しないエラーが発生しました。"
    }
    
    // MARK: - User Defaults Keys
    
    /**
     UserDefaultsで使用するキーの定義
     
     アプリケーション設定やユーザーデータの永続化に使用するキーを定義します。
     */
    struct UserDefaultsKeys {
        /// 最後に検索した位置
        static let lastSearchLocation = "lastSearchLocation"
        
        /// 検索フィルター設定
        static let searchFilter = "searchFilter"
        
        /// お気に入りカフェ
        static let favoriteCafes = "favoriteCafes"
        
        /// オンボーディング表示済みフラグ
        static let hasSeenOnboarding = "hasSeenOnboarding"
        
        /// アプリ起動回数
        static let appLaunchCount = "appLaunchCount"
    }
    
    // MARK: - File Names
    
    /**
     ファイル名の定義
     
     アプリケーションで使用するファイルの名前を定義します。
     */
    struct FileNames {
        /// お気に入りデータファイル
        static let favorites = "favorites.json"
        
        /// 検索履歴ファイル
        static let searchHistory = "searchHistory.json"
        
        /// ユーザー設定ファイル
        static let userSettings = "userSettings.json"
    }
    
    // MARK: - Notification Names
    
    /**
     通知名の定義
     
     NotificationCenterで使用する通知の名前を定義します。
     */
    struct NotificationNames {
        /// 位置情報更新通知
        static let locationUpdated = "locationUpdated"
        
        /// カフェ読み込み完了通知
        static let cafesLoaded = "cafesLoaded"
        
        /// お気に入り変更通知
        static let favoritesChanged = "favoritesChanged"
        
        /// 検索完了通知
        static let searchCompleted = "searchCompleted"
    }
}

// MARK: - Extensions for Constants

/**
 Constants構造体の拡張
 
 便利なユーティリティ関数を提供します。
 */
extension Constants {
    /**
     距離をフォーマットされた文字列に変換
     
     - Parameter distance: 距離（メートル）
     - Returns: フォーマットされた距離文字列（例: "500m"、"1.2km"）
     */
    static func formatDistance(_ distance: Double) -> String {
        if distance < 1000 {
            return "\(Int(distance))m"
        } else {
            return String(format: "%.1fkm", distance / 1000)
        }
    }
    
    /**
     評価をフォーマットされた文字列に変換
     
     - Parameter rating: 評価（0.0-5.0）
     - Returns: フォーマットされた評価文字列（例: "4.2"）
     */
    static func formatRating(_ rating: Double) -> String {
        return String(format: "%.1f", rating)
    }
    
    /**
     価格レベルをフォーマットされた文字列に変換
     
     - Parameter priceLevel: 価格レベル（1-4）
     - Returns: フォーマットされた価格文字列（例: "¥¥"）
     */
    static func formatPriceLevel(_ priceLevel: Int) -> String {
        return String(repeating: "¥", count: priceLevel)
    }
} 