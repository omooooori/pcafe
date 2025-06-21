import Foundation
import CoreLocation
import UIKit
import SwiftUI

// MARK: - Distance Utilities
struct DistanceUtils {
    static func calculateDistance(from location1: CLLocation, to location2: CLLocation) -> Double {
        return location1.distance(from: location2)
    }
    
    static func formatDistance(_ distance: Double) -> String {
        if distance < 1000 {
            return "\(Int(distance))m"
        } else {
            return String(format: "%.1fkm", distance / 1000)
        }
    }
    
    static func isWithinRadius(_ distance: Double, radius: Double) -> Bool {
        return distance <= radius
    }
}

// MARK: - String Utilities
struct StringUtils {
    static func truncate(_ string: String, to length: Int) -> String {
        if string.count <= length {
            return string
        }
        return String(string.prefix(length)) + "..."
    }
    
    static func formatPhoneNumber(_ phoneNumber: String) -> String {
        // 電話番号のフォーマット（例: 03-1234-5678）
        let cleaned = phoneNumber.replacingOccurrences(of: "[^0-9]", with: "", options: .regularExpression)
        
        if cleaned.count == 10 {
            return String(cleaned.prefix(2)) + "-" + String(cleaned.dropFirst(2).prefix(4)) + "-" + String(cleaned.suffix(4))
        } else if cleaned.count == 11 {
            return String(cleaned.prefix(3)) + "-" + String(cleaned.dropFirst(3).prefix(4)) + "-" + String(cleaned.suffix(4))
        }
        
        return phoneNumber
    }
    
    static func isValidURL(_ string: String) -> Bool {
        guard let url = URL(string: string) else { return false }
        return UIApplication.shared.canOpenURL(url)
    }
}

// MARK: - Date Utilities
struct DateUtils {
    static func isOpenNow(_ openingHours: Cafe.OpeningHours?) -> Bool {
        guard let openingHours = openingHours else { return false }
        return openingHours.openNow
    }
    
    static func formatOpeningHours(_ openingHours: Cafe.OpeningHours?) -> String {
        guard let openingHours = openingHours else { return "営業時間不明" }
        
        if let weekdayText = openingHours.weekdayText {
            let today = Calendar.current.component(.weekday, from: Date()) - 1
            if today < weekdayText.count {
                return weekdayText[today]
            }
        }
        
        return openingHours.openNow ? "営業中" : "営業時間外"
    }
    
    static func getCurrentWeekday() -> Int {
        return Calendar.current.component(.weekday, from: Date()) - 1
    }
}

// MARK: - Rating Utilities
struct RatingUtils {
    static func formatRating(_ rating: Double?) -> String {
        guard let rating = rating else { return "評価なし" }
        return String(format: "%.1f", rating)
    }
    
    static func getRatingColor(_ rating: Double?) -> Color {
        guard let rating = rating else { return .gray }
        
        switch rating {
        case 4.5...:
            return .green
        case 4.0..<4.5:
            return .blue
        case 3.5..<4.0:
            return .orange
        case 3.0..<3.5:
            return .yellow
        default:
            return .red
        }
    }
    
    static func getRatingStars(_ rating: Double?) -> String {
        guard let rating = rating else { return "☆☆☆☆☆" }
        
        let fullStars = Int(rating)
        let hasHalfStar = rating.truncatingRemainder(dividingBy: 1) >= 0.5
        
        var stars = String(repeating: "★", count: fullStars)
        if hasHalfStar {
            stars += "☆"
        }
        stars += String(repeating: "☆", count: 5 - fullStars - (hasHalfStar ? 1 : 0))
        
        return stars
    }
}

// MARK: - Price Utilities
struct PriceUtils {
    static func formatPriceLevel(_ priceLevel: Int?) -> String {
        guard let priceLevel = priceLevel else { return "価格不明" }
        return String(repeating: "¥", count: priceLevel)
    }
    
    static func getPriceLevelDescription(_ priceLevel: Int?) -> String {
        guard let priceLevel = priceLevel else { return "価格不明" }
        
        switch priceLevel {
        case 1:
            return "安価"
        case 2:
            return "普通"
        case 3:
            return "高価"
        case 4:
            return "超高価"
        default:
            return "価格不明"
        }
    }
}

// MARK: - Validation Utilities
struct ValidationUtils {
    static func isValidCoordinate(_ coordinate: CLLocationCoordinate2D) -> Bool {
        return coordinate.latitude >= -90 && coordinate.latitude <= 90 &&
               coordinate.longitude >= -180 && coordinate.longitude <= 180
    }
    
    static func isValidRadius(_ radius: Double) -> Bool {
        return radius >= Constants.API.minRadius && radius <= Constants.API.maxRadius
    }
    
    static func isValidRating(_ rating: Double) -> Bool {
        return rating >= 0 && rating <= 5
    }
    
    static func isValidPriceLevel(_ priceLevel: Int) -> Bool {
        return priceLevel >= 1 && priceLevel <= 4
    }
}

// MARK: - Share Utilities
struct ShareUtils {
    static func createShareText(for cafe: Cafe) -> String {
        var text = "\(cafe.name)\n"
        text += "住所: \(cafe.address)\n"
        
        if let rating = cafe.rating {
            text += "評価: \(RatingUtils.formatRating(rating))\n"
        }
        
        if let priceLevel = cafe.priceLevel {
            text += "価格: \(PriceUtils.formatPriceLevel(priceLevel))\n"
        }
        
        text += "\nCafeParkingFinderで見つけました！"
        
        return text
    }
    
    static func createShareURL(for cafe: Cafe) -> URL? {
        let urlString = "http://maps.apple.com/?daddr=\(cafe.location.latitude),\(cafe.location.longitude)&q=\(cafe.name.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")"
        return URL(string: urlString)
    }
}

// MARK: - Cache Utilities
struct CacheUtils {
    static func getDocumentsDirectory() -> URL {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
    
    static func saveToDocuments<T: Codable>(_ object: T, filename: String) throws {
        let url = getDocumentsDirectory().appendingPathComponent(filename)
        let data = try JSONEncoder().encode(object)
        try data.write(to: url)
    }
    
    static func loadFromDocuments<T: Codable>(_ type: T.Type, filename: String) throws -> T {
        let url = getDocumentsDirectory().appendingPathComponent(filename)
        let data = try Data(contentsOf: url)
        return try JSONDecoder().decode(type, from: data)
    }
    
    static func fileExists(filename: String) -> Bool {
        let url = getDocumentsDirectory().appendingPathComponent(filename)
        return FileManager.default.fileExists(atPath: url.path)
    }
    
    static func deleteFile(filename: String) throws {
        let url = getDocumentsDirectory().appendingPathComponent(filename)
        try FileManager.default.removeItem(at: url)
    }
}

// MARK: - Debug Utilities
struct DebugUtils {
    static func log(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        #if DEBUG
        let fileName = URL(fileURLWithPath: file).lastPathComponent
        print("[\(fileName):\(line)] \(function): \(message)")
        #endif
    }
    
    static func logError(_ error: Error, file: String = #file, function: String = #function, line: Int = #line) {
        #if DEBUG
        let fileName = URL(fileURLWithPath: file).lastPathComponent
        print("[\(fileName):\(line)] \(function): ERROR - \(error.localizedDescription)")
        #endif
    }
} 