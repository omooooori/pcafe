import Foundation
import CoreLocation
import Combine

/**
 Google Places APIを使用してカフェ情報を取得するサービス
 
 このクラスは、Google Places APIとの通信を担当し、駐車場付きカフェの検索と
 詳細情報の取得を行います。Combineフレームワークを使用して非同期処理を実現し、
 エラーハンドリングとローディング状態の管理を提供します。
 
 ## 主な機能
 - 現在位置周辺のカフェ検索
 - 駐車場情報の含まれた検索
 - カフェの詳細情報取得
 - エラーハンドリング
 - ローディング状態管理
 
 ## API使用量
 - Nearby Search API: カフェ検索
 - Place Details API: 詳細情報取得
 
 ## 使用例
 ```swift
 let service = GooglePlacesService(apiKey: "your-api-key")
 service.searchCafesWithParking(near: location, radius: 1000, filter: filter)
     .sink(
         receiveCompletion: { completion in
             // エラーハンドリング
         },
         receiveValue: { cafes in
             // 検索結果の処理
         }
     )
     .store(in: &cancellables)
 ```
 
 - Author: Cafe Parking Finder Team
 - Version: 1.0.0
 - Since: 2024
 */
class GooglePlacesService: ObservableObject {
    // MARK: - Properties
    
    /// Google Places APIキー
    private let apiKey: String
    
    /// Google Places APIのベースURL
    private let baseURL = "https://maps.googleapis.com/maps/api/place"
    
    /// API呼び出し中のローディング状態
    @Published var isLoading = false
    
    /// 発生したエラー
    @Published var error: PlacesError?
    
    // MARK: - Error Types
    
    /**
     Google Places API関連のエラー型
     
     API呼び出し時に発生する可能性のあるエラーを定義します。
     LocalizedErrorプロトコルに準拠し、ユーザーフレンドリーなエラーメッセージを提供します。
     */
    enum PlacesError: Error, LocalizedError {
        /// APIキーが無効
        case invalidAPIKey
        
        /// ネットワークエラー
        case networkError(Error)
        
        /// 無効なレスポンス
        case invalidResponse
        
        /// API利用制限超過
        case quotaExceeded
        
        /// リクエスト拒否
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
    
    // MARK: - Initialization
    
    /**
     サービスの初期化
     
     - Parameter apiKey: Google Places APIキー
     */
    init(apiKey: String) {
        self.apiKey = apiKey
    }
    
    // MARK: - Public Methods
    
    /**
     駐車場付きカフェを検索
     
     指定された位置周辺で駐車場付きのカフェを検索します。
     検索結果はフィルター条件に基づいてフィルタリングされ、Combine Publisherとして返されます。
     
     - Parameters:
        - location: 検索の中心となる位置
        - radius: 検索半径（メートル、デフォルト: 1000）
        - filter: 検索フィルター条件
     - Returns: カフェ配列を発行するPublisher
     */
    func searchCafesWithParking(
        near location: CLLocation,
        radius: Double = 1000,
        filter: SearchFilter
    ) -> AnyPublisher<[Cafe], PlacesError> {
        isLoading = true
        error = nil
        
        var components = URLComponents(string: "\(baseURL)/nearbysearch/json")!
        components.queryItems = [
            URLQueryItem(name: "location", value: "\(location.coordinate.latitude),\(location.coordinate.longitude)"),
            URLQueryItem(name: "radius", value: "\(Int(radius))"),
            URLQueryItem(name: "keyword", value: "カフェ 駐車場"),
            URLQueryItem(name: "type", value: "cafe"),
            URLQueryItem(name: "key", value: apiKey),
            URLQueryItem(name: "language", value: "ja")
        ]
        
        if filter.openNow {
            components.queryItems?.append(URLQueryItem(name: "opennow", value: "true"))
        }
        
        guard let url = components.url else {
            return Fail(error: PlacesError.invalidResponse)
                .eraseToAnyPublisher()
        }
        
        return URLSession.shared.dataTaskPublisher(for: url)
            .map(\.data)
            .decode(type: PlacesResponse.self, decoder: JSONDecoder())
            .map { response in
                self.processPlacesResponse(response, filter: filter)
            }
            .handleEvents(
                receiveCompletion: { completion in
                    self.isLoading = false
                    if case .failure(let error) = completion {
                        self.error = error
                    }
                }
            )
            .mapError { error in
                if let placesError = error as? PlacesError {
                    return placesError
                } else {
                    return PlacesError.networkError(error)
                }
            }
            .eraseToAnyPublisher()
    }
    
    // MARK: - Private Methods
    
    /**
     Places APIレスポンスを処理
     
     APIレスポンスをCafeオブジェクトの配列に変換し、フィルター条件を適用します。
     
     - Parameters:
        - response: Places APIからのレスポンス
        - filter: 適用するフィルター条件
     - Returns: フィルタリング済みのカフェ配列
     */
    private func processPlacesResponse(_ response: PlacesResponse, filter: SearchFilter) -> [Cafe] {
        guard response.status == "OK" else {
            switch response.status {
            case "OVER_QUERY_LIMIT":
                error = .quotaExceeded
            case "REQUEST_DENIED":
                error = .requestDenied
            default:
                error = .invalidResponse
            }
            return []
        }
        
        return response.results.compactMap { place in
            guard let location = place.geometry?.location else { return nil }
            
            // フィルター適用
            if let rating = place.rating, rating < filter.minRating {
                return nil
            }
            
            if let priceLevel = place.priceLevel, priceLevel > filter.maxPriceLevel {
                return nil
            }
            
            return Cafe(
                id: place.placeId,
                name: place.name,
                address: place.vicinity,
                phoneNumber: nil, // 詳細取得で取得
                rating: place.rating,
                userRatingsTotal: place.userRatingsTotal,
                priceLevel: place.priceLevel,
                placeId: place.placeId,
                location: CLLocationCoordinate2D(
                    latitude: location.lat,
                    longitude: location.lng
                ),
                types: place.types,
                openingHours: nil, // 詳細取得で取得
                photos: place.photos?.map { photo in
                    Cafe.Photo(
                        photoReference: photo.photoReference,
                        height: photo.height,
                        width: photo.width
                    )
                },
                website: nil, // 詳細取得で取得
                isFavorite: false
            )
        }
    }
    
    /**
     カフェの詳細情報を取得
     
     指定されたplace_idを使用してカフェの詳細情報を取得します。
     
     - Parameter placeId: Google Places APIのplace_id
     - Returns: 詳細情報を含むCafeオブジェクトを発行するPublisher
     */
    func getPlaceDetails(placeId: String) -> AnyPublisher<Cafe, PlacesError> {
        var components = URLComponents(string: "\(baseURL)/details/json")!
        components.queryItems = [
            URLQueryItem(name: "place_id", value: placeId),
            URLQueryItem(name: "fields", value: "name,formatted_address,formatted_phone_number,rating,user_ratings_total,price_level,geometry,opening_hours,photos,website"),
            URLQueryItem(name: "key", value: apiKey),
            URLQueryItem(name: "language", value: "ja")
        ]
        
        guard let url = components.url else {
            return Fail(error: PlacesError.invalidResponse)
                .eraseToAnyPublisher()
        }
        
        return URLSession.shared.dataTaskPublisher(for: url)
            .map(\.data)
            .decode(type: PlaceDetailResponse.self, decoder: JSONDecoder())
            .map { response in
                // 詳細情報をCafeオブジェクトに変換
                // 実装は省略（必要に応じて追加）
                Cafe(
                    id: response.result.placeId,
                    name: response.result.name,
                    address: response.result.formattedAddress,
                    phoneNumber: response.result.formattedPhoneNumber,
                    rating: response.result.rating,
                    userRatingsTotal: response.result.userRatingsTotal,
                    priceLevel: response.result.priceLevel,
                    placeId: response.result.placeId,
                    location: CLLocationCoordinate2D(
                        latitude: response.result.geometry.location.lat,
                        longitude: response.result.geometry.location.lng
                    ),
                    types: [],
                    openingHours: nil,
                    photos: nil,
                    website: response.result.website,
                    isFavorite: false
                )
            }
            .mapError { error in
                if let placesError = error as? PlacesError {
                    return placesError
                } else {
                    return PlacesError.networkError(error)
                }
            }
            .eraseToAnyPublisher()
    }
}

// MARK: - Response Models

/**
 Google Places API Nearby Search レスポンスモデル
 
 APIレスポンスの構造を定義します。
 */
struct PlacesResponse: Codable {
    /// APIレスポンスのステータス
    let status: String
    
    /// 検索結果の配列
    let results: [Place]
}

/**
 Google Places API の場所情報モデル
 
 個々の場所（カフェ）の情報を表現します。
 */
struct Place: Codable {
    let placeId: String
    let name: String
    let vicinity: String
    let rating: Double?
    let userRatingsTotal: Int?
    let priceLevel: Int?
    let geometry: Geometry?
    let types: [String]
    let photos: [PlacePhoto]?
    
    enum CodingKeys: String, CodingKey {
        case placeId = "place_id"
        case name, vicinity, rating, geometry, types, photos
        case userRatingsTotal = "user_ratings_total"
        case priceLevel = "price_level"
    }
}

struct Geometry: Codable {
    let location: Location
}

struct Location: Codable {
    let lat: Double
    let lng: Double
}

struct PlacePhoto: Codable {
    let photoReference: String
    let height: Int
    let width: Int
    
    enum CodingKeys: String, CodingKey {
        case photoReference = "photo_reference"
        case height, width
    }
}

struct PlaceDetailResponse: Codable {
    let status: String
    let result: PlaceDetail
}

struct PlaceDetail: Codable {
    let placeId: String
    let name: String
    let formattedAddress: String
    let formattedPhoneNumber: String?
    let rating: Double?
    let userRatingsTotal: Int?
    let priceLevel: Int?
    let geometry: Geometry
    let website: String?
    
    enum CodingKeys: String, CodingKey {
        case placeId = "place_id"
        case name
        case formattedAddress = "formatted_address"
        case formattedPhoneNumber = "formatted_phone_number"
        case rating
        case userRatingsTotal = "user_ratings_total"
        case priceLevel = "price_level"
        case geometry, website
    }
} 