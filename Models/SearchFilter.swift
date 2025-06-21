import Foundation

struct SearchFilter {
    var radius: Int = 1500
    var minRating: Double?
    var maxPriceLevel: Int?
    var requiresParking: Bool = false
    var sortBy: SortBy = .rating
    
    enum SortBy {
        case rating
        case distance
        case name
    }
} 