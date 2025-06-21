import Foundation

struct SearchFilter: Codable {
    var radius: Double = 1000 // メートル単位
    var minRating: Double = 0.0
    var maxPriceLevel: Int = 4
    var openNow: Bool = false
    var parkingTypes: Set<ParkingType> = Set(ParkingType.allCases)
    var sortBy: SortOption = .distance
    
    enum ParkingType: String, CaseIterable, Codable {
        case free = "free"
        case paid = "paid"
        case street = "street"
        case garage = "garage"
        
        var displayName: String {
            switch self {
            case .free: return "無料駐車場"
            case .paid: return "有料駐車場"
            case .street: return "路上駐車"
            case .garage: return "立体駐車場"
            }
        }
    }
    
    enum SortOption: String, CaseIterable, Codable {
        case distance = "distance"
        case rating = "rating"
        case price = "price"
        
        var displayName: String {
            switch self {
            case .distance: return "距離順"
            case .rating: return "評価順"
            case .price: return "価格順"
            }
        }
    }
} 