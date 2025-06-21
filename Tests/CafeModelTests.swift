import XCTest
import CoreLocation
@testable import CafeParkingFinderApp

final class CafeModelTests: XCTestCase {
    
    // MARK: - Cafe Model Tests
    
    func testCafeInitialization() {
        // Given
        let id = "test_cafe_1"
        let name = "テストカフェ"
        let address = "東京都渋谷区テスト1-1-1"
        let phoneNumber = "03-1234-5678"
        let rating = 4.5
        let userRatingsTotal = 100
        let priceLevel = 2
        let placeId = "place_123"
        let location = CLLocationCoordinate2D(latitude: 35.6580, longitude: 139.7016)
        let types = ["cafe", "food", "establishment"]
        let website = "https://test-cafe.com"
        
        // When
        let cafe = Cafe(
            id: id,
            name: name,
            address: address,
            phoneNumber: phoneNumber,
            rating: rating,
            userRatingsTotal: userRatingsTotal,
            priceLevel: priceLevel,
            placeId: placeId,
            location: location,
            types: types,
            openingHours: nil,
            photos: nil,
            website: website,
            isFavorite: false
        )
        
        // Then
        XCTAssertEqual(cafe.id, id)
        XCTAssertEqual(cafe.name, name)
        XCTAssertEqual(cafe.address, address)
        XCTAssertEqual(cafe.phoneNumber, phoneNumber)
        XCTAssertEqual(cafe.rating, rating)
        XCTAssertEqual(cafe.userRatingsTotal, userRatingsTotal)
        XCTAssertEqual(cafe.priceLevel, priceLevel)
        XCTAssertEqual(cafe.placeId, placeId)
        XCTAssertEqual(cafe.location.latitude, location.latitude, accuracy: 0.0001)
        XCTAssertEqual(cafe.location.longitude, location.longitude, accuracy: 0.0001)
        XCTAssertEqual(cafe.types, types)
        XCTAssertEqual(cafe.website, website)
        XCTAssertFalse(cafe.isFavorite)
    }
    
    func testCafeWithOptionalProperties() {
        // Given
        let cafe = Cafe(
            id: "test_cafe_2",
            name: "オプションカフェ",
            address: "東京都新宿区テスト2-2-2",
            phoneNumber: nil,
            rating: nil,
            userRatingsTotal: nil,
            priceLevel: nil,
            placeId: "place_456",
            location: CLLocationCoordinate2D(latitude: 35.6909, longitude: 139.7003),
            types: ["cafe"],
            openingHours: nil,
            photos: nil,
            website: nil,
            isFavorite: true
        )
        
        // Then
        XCTAssertNil(cafe.phoneNumber)
        XCTAssertNil(cafe.rating)
        XCTAssertNil(cafe.userRatingsTotal)
        XCTAssertNil(cafe.priceLevel)
        XCTAssertNil(cafe.openingHours)
        XCTAssertNil(cafe.photos)
        XCTAssertNil(cafe.website)
        XCTAssertTrue(cafe.isFavorite)
    }
    
    func testCafeWithOpeningHours() {
        // Given
        let openingHours = Cafe.OpeningHours(
            openNow: true,
            periods: [
                Cafe.OpeningHours.Period(
                    open: Cafe.OpeningHours.Period.DayTime(day: 1, time: "0900"),
                    close: Cafe.OpeningHours.Period.DayTime(day: 1, time: "2200")
                )
            ],
            weekdayText: ["月曜日: 9:00–22:00"]
        )
        
        let cafe = Cafe(
            id: "test_cafe_3",
            name: "営業時間カフェ",
            address: "東京都池袋区テスト3-3-3",
            phoneNumber: nil,
            rating: nil,
            userRatingsTotal: nil,
            priceLevel: nil,
            placeId: "place_789",
            location: CLLocationCoordinate2D(latitude: 35.7295, longitude: 139.7104),
            types: ["cafe"],
            openingHours: openingHours,
            photos: nil,
            website: nil,
            isFavorite: false
        )
        
        // Then
        XCTAssertNotNil(cafe.openingHours)
        XCTAssertTrue(cafe.openingHours?.openNow == true)
        XCTAssertEqual(cafe.openingHours?.periods?.count, 1)
        XCTAssertEqual(cafe.openingHours?.weekdayText?.count, 1)
        XCTAssertEqual(cafe.openingHours?.weekdayText?.first, "月曜日: 9:00–22:00")
    }
    
    func testCafeWithPhotos() {
        // Given
        let photos = [
            Cafe.Photo(photoReference: "photo_ref_1", height: 400, width: 600),
            Cafe.Photo(photoReference: "photo_ref_2", height: 300, width: 450)
        ]
        
        let cafe = Cafe(
            id: "test_cafe_4",
            name: "写真カフェ",
            address: "東京都銀座区テスト4-4-4",
            phoneNumber: nil,
            rating: nil,
            userRatingsTotal: nil,
            priceLevel: nil,
            placeId: "place_101",
            location: CLLocationCoordinate2D(latitude: 35.6719, longitude: 139.7639),
            types: ["cafe"],
            openingHours: nil,
            photos: photos,
            website: nil,
            isFavorite: false
        )
        
        // Then
        XCTAssertNotNil(cafe.photos)
        XCTAssertEqual(cafe.photos?.count, 2)
        XCTAssertEqual(cafe.photos?.first?.photoReference, "photo_ref_1")
        XCTAssertEqual(cafe.photos?.first?.height, 400)
        XCTAssertEqual(cafe.photos?.first?.width, 600)
    }
    
    // MARK: - Codable Tests
    
    func testCafeCodable() throws {
        // Given
        let originalCafe = Cafe(
            id: "codable_test",
            name: "コーダブルカフェ",
            address: "東京都テスト区テスト5-5-5",
            phoneNumber: "03-5555-5555",
            rating: 4.2,
            userRatingsTotal: 150,
            priceLevel: 2,
            placeId: "place_codable",
            location: CLLocationCoordinate2D(latitude: 35.6762, longitude: 139.6503),
            types: ["cafe", "food"],
            openingHours: Cafe.OpeningHours(
                openNow: true,
                periods: nil,
                weekdayText: ["月曜日: 8:00–21:00"]
            ),
            photos: [Cafe.Photo(photoReference: "photo_codable", height: 500, width: 700)],
            website: "https://codable-cafe.com",
            isFavorite: true
        )
        
        // When
        let encoder = JSONEncoder()
        let decoder = JSONDecoder()
        let data = try encoder.encode(originalCafe)
        let decodedCafe = try decoder.decode(Cafe.self, from: data)
        
        // Then
        XCTAssertEqual(decodedCafe.id, originalCafe.id)
        XCTAssertEqual(decodedCafe.name, originalCafe.name)
        XCTAssertEqual(decodedCafe.address, originalCafe.address)
        XCTAssertEqual(decodedCafe.phoneNumber, originalCafe.phoneNumber)
        XCTAssertEqual(decodedCafe.rating, originalCafe.rating)
        XCTAssertEqual(decodedCafe.userRatingsTotal, originalCafe.userRatingsTotal)
        XCTAssertEqual(decodedCafe.priceLevel, originalCafe.priceLevel)
        XCTAssertEqual(decodedCafe.placeId, originalCafe.placeId)
        XCTAssertEqual(decodedCafe.location.latitude, originalCafe.location.latitude, accuracy: 0.0001)
        XCTAssertEqual(decodedCafe.location.longitude, originalCafe.location.longitude, accuracy: 0.0001)
        XCTAssertEqual(decodedCafe.types, originalCafe.types)
        XCTAssertEqual(decodedCafe.website, originalCafe.website)
        XCTAssertEqual(decodedCafe.isFavorite, originalCafe.isFavorite)
    }
    
    // MARK: - CLLocationCoordinate2D Codable Tests
    
    func testCLLocationCoordinate2DCodable() throws {
        // Given
        let originalCoordinate = CLLocationCoordinate2D(latitude: 35.6580, longitude: 139.7016)
        
        // When
        let encoder = JSONEncoder()
        let decoder = JSONDecoder()
        let data = try encoder.encode(originalCoordinate)
        let decodedCoordinate = try decoder.decode(CLLocationCoordinate2D.self, from: data)
        
        // Then
        XCTAssertEqual(decodedCoordinate.latitude, originalCoordinate.latitude, accuracy: 0.0001)
        XCTAssertEqual(decodedCoordinate.longitude, originalCoordinate.longitude, accuracy: 0.0001)
    }
    
    func testCLLocationCoordinate2DInvalidData() {
        // Given
        let invalidJSON = """
        {
            "invalid_key": 35.6580,
            "longitude": 139.7016
        }
        """.data(using: .utf8)!
        
        // When & Then
        XCTAssertThrowsError(try JSONDecoder().decode(CLLocationCoordinate2D.self, from: invalidJSON))
    }
    
    // MARK: - Identifiable Tests
    
    func testCafeIdentifiable() {
        // Given
        let cafe1 = Cafe(
            id: "unique_id_1",
            name: "カフェ1",
            address: "住所1",
            phoneNumber: nil,
            rating: nil,
            userRatingsTotal: nil,
            priceLevel: nil,
            placeId: "place_1",
            location: CLLocationCoordinate2D(latitude: 35.6580, longitude: 139.7016),
            types: ["cafe"],
            openingHours: nil,
            photos: nil,
            website: nil,
            isFavorite: false
        )
        
        let cafe2 = Cafe(
            id: "unique_id_2",
            name: "カフェ2",
            address: "住所2",
            phoneNumber: nil,
            rating: nil,
            userRatingsTotal: nil,
            priceLevel: nil,
            placeId: "place_2",
            location: CLLocationCoordinate2D(latitude: 35.6909, longitude: 139.7003),
            types: ["cafe"],
            openingHours: nil,
            photos: nil,
            website: nil,
            isFavorite: false
        )
        
        // Then
        XCTAssertNotEqual(cafe1.id, cafe2.id)
        XCTAssertNotEqual(cafe1, cafe2)
    }
} 