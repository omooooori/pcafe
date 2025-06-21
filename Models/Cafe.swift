import Foundation
import CoreLocation

struct Cafe: Identifiable, Codable {
    let id: String
    let name: String
    let address: String
    let rating: Double?
    let userRatingsTotal: Int?
    let priceLevel: Int?
    let types: [String]
    let geometry: Geometry
    let photos: [Photo]?
    let openingHours: OpeningHours?
    let hasParking: Bool
    
    struct Geometry: Codable {
        let location: Location
    }
    
    struct Location: Codable {
        let lat: Double
        let lng: Double
    }
    
    struct OpeningHours: Codable {
        let open_now: Bool?
        let weekday_text: [String]?
    }
    
    struct Photo: Codable {
        let photo_reference: String
        let height: Int
        let width: Int
    }
}

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