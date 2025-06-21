import Foundation
import CoreLocation

class GooglePlacesService: ObservableObject {
    private let apiKey = APIConfig.googleMapsAPIKey
    private let baseURL = "https://maps.googleapis.com/maps/api/place"
    
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    func searchCafes(near location: CLLocation, radius: Int = 1500) async throws -> [Cafe] {
        guard APIConfig.validateAPIKey() else {
            throw PlacesError.invalidAPIKey
        }
        
        isLoading = true
        errorMessage = nil
        
        defer { isLoading = false }
        
        let urlString = "\(baseURL)/nearbysearch/json?location=\(location.coordinate.latitude),\(location.coordinate.longitude)&radius=\(radius)&type=cafe&key=\(apiKey)"
        
        guard let url = URL(string: urlString) else {
            throw PlacesError.invalidURL
        }
        
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw PlacesError.invalidResponse
            }
            
            guard httpResponse.statusCode == 200 else {
                throw PlacesError.httpError(statusCode: httpResponse.statusCode)
            }
            
            let placesResponse = try JSONDecoder().decode(PlacesResponse.self, from: data)
            
            if placesResponse.status != "OK" {
                throw PlacesError.apiError(status: placesResponse.status)
            }
            
            return placesResponse.results.map { place in
                Cafe(
                    id: place.place_id,
                    name: place.name,
                    address: place.vicinity,
                    rating: place.rating,
                    userRatingsTotal: place.user_ratings_total,
                    priceLevel: place.price_level,
                    types: place.types,
                    geometry: place.geometry,
                    photos: place.photos,
                    openingHours: place.opening_hours,
                    hasParking: false // デフォルト値、後で詳細検索で更新
                )
            }
        } catch {
            self.errorMessage = error.localizedDescription
            throw error
        }
    }
    
    func getPlaceDetails(placeId: String) async throws -> CafeDetails? {
        guard APIConfig.validateAPIKey() else {
            throw PlacesError.invalidAPIKey
        }
        
        let urlString = "\(baseURL)/details/json?place_id=\(placeId)&fields=name,formatted_address,rating,user_ratings_total,price_level,types,geometry,photos,opening_hours,website,formatted_phone_number&key=\(apiKey)"
        
        guard let url = URL(string: urlString) else {
            throw PlacesError.invalidURL
        }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let detailsResponse = try JSONDecoder().decode(PlaceDetailsResponse.self, from: data)
            
            if detailsResponse.status != "OK" {
                throw PlacesError.apiError(status: detailsResponse.status)
            }
            
            return detailsResponse.result
        } catch {
            throw error
        }
    }
}

// MARK: - Response Models
struct PlacesResponse: Codable {
    let status: String
    let results: [Place]
}

struct Place: Codable {
    let place_id: String
    let name: String
    let vicinity: String
    let rating: Double?
    let user_ratings_total: Int?
    let price_level: Int?
    let types: [String]
    let geometry: Cafe.Geometry
    let photos: [Cafe.Photo]?
    let opening_hours: Cafe.OpeningHours?
}

struct PlaceDetailsResponse: Codable {
    let status: String
    let result: CafeDetails?
}

struct CafeDetails: Codable {
    let name: String
    let formatted_address: String?
    let rating: Double?
    let user_ratings_total: Int?
    let price_level: Int?
    let types: [String]?
    let geometry: Cafe.Geometry?
    let photos: [Cafe.Photo]?
    let opening_hours: Cafe.OpeningHours?
    let website: String?
    let formatted_phone_number: String?
}

// MARK: - Errors
enum PlacesError: Error, LocalizedError {
    case invalidAPIKey
    case invalidURL
    case invalidResponse
    case httpError(statusCode: Int)
    case apiError(status: String)
    
    var errorDescription: String? {
        switch self {
        case .invalidAPIKey:
            return "Google Maps APIキーが設定されていません"
        case .invalidURL:
            return "無効なURLです"
        case .invalidResponse:
            return "無効なレスポンスです"
        case .httpError(let statusCode):
            return "HTTPエラー: \(statusCode)"
        case .apiError(let status):
            return "APIエラー: \(status)"
        }
    }
} 