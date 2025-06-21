import XCTest
@testable import CafeParkingFinderApp

final class SearchFilterTests: XCTestCase {
    
    // MARK: - SearchFilter Initialization Tests
    
    func testSearchFilterDefaultValues() {
        // When
        let filter = SearchFilter()
        
        // Then
        XCTAssertEqual(filter.radius, 1000)
        XCTAssertEqual(filter.minRating, 0.0)
        XCTAssertEqual(filter.maxPriceLevel, 4)
        XCTAssertFalse(filter.openNow)
        XCTAssertEqual(filter.parkingTypes, Set(SearchFilter.ParkingType.allCases))
        XCTAssertEqual(filter.sortBy, .distance)
    }
    
    func testSearchFilterCustomValues() {
        // Given
        let radius: Double = 2000
        let minRating: Double = 4.0
        let maxPriceLevel: Int = 2
        let openNow: Bool = true
        let parkingTypes: Set<SearchFilter.ParkingType> = [.free, .paid]
        let sortBy: SearchFilter.SortOption = .rating
        
        // When
        let filter = SearchFilter(
            radius: radius,
            minRating: minRating,
            maxPriceLevel: maxPriceLevel,
            openNow: openNow,
            parkingTypes: parkingTypes,
            sortBy: sortBy
        )
        
        // Then
        XCTAssertEqual(filter.radius, radius)
        XCTAssertEqual(filter.minRating, minRating)
        XCTAssertEqual(filter.maxPriceLevel, maxPriceLevel)
        XCTAssertEqual(filter.openNow, openNow)
        XCTAssertEqual(filter.parkingTypes, parkingTypes)
        XCTAssertEqual(filter.sortBy, sortBy)
    }
    
    // MARK: - ParkingType Tests
    
    func testParkingTypeAllCases() {
        // When
        let allCases = SearchFilter.ParkingType.allCases
        
        // Then
        XCTAssertEqual(allCases.count, 4)
        XCTAssertTrue(allCases.contains(.free))
        XCTAssertTrue(allCases.contains(.paid))
        XCTAssertTrue(allCases.contains(.street))
        XCTAssertTrue(allCases.contains(.garage))
    }
    
    func testParkingTypeDisplayNames() {
        // Then
        XCTAssertEqual(SearchFilter.ParkingType.free.displayName, "無料駐車場")
        XCTAssertEqual(SearchFilter.ParkingType.paid.displayName, "有料駐車場")
        XCTAssertEqual(SearchFilter.ParkingType.street.displayName, "路上駐車")
        XCTAssertEqual(SearchFilter.ParkingType.garage.displayName, "立体駐車場")
    }
    
    func testParkingTypeRawValues() {
        // Then
        XCTAssertEqual(SearchFilter.ParkingType.free.rawValue, "free")
        XCTAssertEqual(SearchFilter.ParkingType.paid.rawValue, "paid")
        XCTAssertEqual(SearchFilter.ParkingType.street.rawValue, "street")
        XCTAssertEqual(SearchFilter.ParkingType.garage.rawValue, "garage")
    }
    
    // MARK: - SortOption Tests
    
    func testSortOptionAllCases() {
        // When
        let allCases = SearchFilter.SortOption.allCases
        
        // Then
        XCTAssertEqual(allCases.count, 3)
        XCTAssertTrue(allCases.contains(.distance))
        XCTAssertTrue(allCases.contains(.rating))
        XCTAssertTrue(allCases.contains(.price))
    }
    
    func testSortOptionDisplayNames() {
        // Then
        XCTAssertEqual(SearchFilter.SortOption.distance.displayName, "距離順")
        XCTAssertEqual(SearchFilter.SortOption.rating.displayName, "評価順")
        XCTAssertEqual(SearchFilter.SortOption.price.displayName, "価格順")
    }
    
    func testSortOptionRawValues() {
        // Then
        XCTAssertEqual(SearchFilter.SortOption.distance.rawValue, "distance")
        XCTAssertEqual(SearchFilter.SortOption.rating.rawValue, "rating")
        XCTAssertEqual(SearchFilter.SortOption.price.rawValue, "price")
    }
    
    // MARK: - Codable Tests
    
    func testSearchFilterCodable() throws {
        // Given
        let originalFilter = SearchFilter(
            radius: 1500,
            minRating: 3.5,
            maxPriceLevel: 3,
            openNow: true,
            parkingTypes: [.free, .paid, .garage],
            sortBy: .rating
        )
        
        // When
        let encoder = JSONEncoder()
        let decoder = JSONDecoder()
        let data = try encoder.encode(originalFilter)
        let decodedFilter = try decoder.decode(SearchFilter.self, from: data)
        
        // Then
        XCTAssertEqual(decodedFilter.radius, originalFilter.radius)
        XCTAssertEqual(decodedFilter.minRating, originalFilter.minRating)
        XCTAssertEqual(decodedFilter.maxPriceLevel, originalFilter.maxPriceLevel)
        XCTAssertEqual(decodedFilter.openNow, originalFilter.openNow)
        XCTAssertEqual(decodedFilter.parkingTypes, originalFilter.parkingTypes)
        XCTAssertEqual(decodedFilter.sortBy, originalFilter.sortBy)
    }
    
    func testSearchFilterWithAllParkingTypes() throws {
        // Given
        let filter = SearchFilter(
            radius: 1000,
            minRating: 0.0,
            maxPriceLevel: 4,
            openNow: false,
            parkingTypes: Set(SearchFilter.ParkingType.allCases),
            sortBy: .distance
        )
        
        // When
        let encoder = JSONEncoder()
        let decoder = JSONDecoder()
        let data = try encoder.encode(filter)
        let decodedFilter = try decoder.decode(SearchFilter.self, from: data)
        
        // Then
        XCTAssertEqual(decodedFilter.parkingTypes.count, 4)
        XCTAssertTrue(decodedFilter.parkingTypes.contains(.free))
        XCTAssertTrue(decodedFilter.parkingTypes.contains(.paid))
        XCTAssertTrue(decodedFilter.parkingTypes.contains(.street))
        XCTAssertTrue(decodedFilter.parkingTypes.contains(.garage))
    }
    
    // MARK: - Edge Cases
    
    func testSearchFilterWithZeroRadius() {
        // When
        let filter = SearchFilter(radius: 0)
        
        // Then
        XCTAssertEqual(filter.radius, 0)
    }
    
    func testSearchFilterWithNegativeRating() {
        // When
        let filter = SearchFilter(minRating: -1.0)
        
        // Then
        XCTAssertEqual(filter.minRating, -1.0)
    }
    
    func testSearchFilterWithHighRating() {
        // When
        let filter = SearchFilter(minRating: 5.0)
        
        // Then
        XCTAssertEqual(filter.minRating, 5.0)
    }
    
    func testSearchFilterWithZeroPriceLevel() {
        // When
        let filter = SearchFilter(maxPriceLevel: 0)
        
        // Then
        XCTAssertEqual(filter.maxPriceLevel, 0)
    }
    
    func testSearchFilterWithHighPriceLevel() {
        // When
        let filter = SearchFilter(maxPriceLevel: 4)
        
        // Then
        XCTAssertEqual(filter.maxPriceLevel, 4)
    }
    
    func testSearchFilterWithEmptyParkingTypes() {
        // When
        let filter = SearchFilter(parkingTypes: [])
        
        // Then
        XCTAssertTrue(filter.parkingTypes.isEmpty)
    }
    
    func testSearchFilterWithSingleParkingType() {
        // When
        let filter = SearchFilter(parkingTypes: [.free])
        
        // Then
        XCTAssertEqual(filter.parkingTypes.count, 1)
        XCTAssertTrue(filter.parkingTypes.contains(.free))
        XCTAssertFalse(filter.parkingTypes.contains(.paid))
    }
    
    // MARK: - Mutability Tests
    
    func testSearchFilterMutability() {
        // Given
        var filter = SearchFilter()
        
        // When
        filter.radius = 2500
        filter.minRating = 4.5
        filter.maxPriceLevel = 1
        filter.openNow = true
        filter.parkingTypes = [.free]
        filter.sortBy = .price
        
        // Then
        XCTAssertEqual(filter.radius, 2500)
        XCTAssertEqual(filter.minRating, 4.5)
        XCTAssertEqual(filter.maxPriceLevel, 1)
        XCTAssertTrue(filter.openNow)
        XCTAssertEqual(filter.parkingTypes, [.free])
        XCTAssertEqual(filter.sortBy, .price)
    }
} 