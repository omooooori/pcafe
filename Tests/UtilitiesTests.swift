import XCTest
import CoreLocation
@testable import CafeParkingFinderApp

final class UtilitiesTests: XCTestCase {
    
    // MARK: - Constants Tests
    
    func testConstantsValues() {
        // Then
        XCTAssertNotNil(Constants.googlePlacesAPIKey)
        XCTAssertFalse(Constants.googlePlacesAPIKey.isEmpty)
        XCTAssertEqual(Constants.defaultSearchRadius, 1000)
        XCTAssertEqual(Constants.maxSearchRadius, 50000)
        XCTAssertEqual(Constants.minRating, 0.0)
        XCTAssertEqual(Constants.maxRating, 5.0)
        XCTAssertEqual(Constants.minPriceLevel, 0)
        XCTAssertEqual(Constants.maxPriceLevel, 4)
    }
    
    // MARK: - Distance Formatting Tests
    
    func testFormatDistanceInMeters() {
        // Given
        let distance: Double = 500
        
        // When
        let formattedDistance = Utilities.formatDistance(distance)
        
        // Then
        XCTAssertEqual(formattedDistance, "500m")
    }
    
    func testFormatDistanceInKilometers() {
        // Given
        let distance: Double = 1500
        
        // When
        let formattedDistance = Utilities.formatDistance(distance)
        
        // Then
        XCTAssertEqual(formattedDistance, "1.5km")
    }
    
    func testFormatDistanceWithDecimal() {
        // Given
        let distance: Double = 1250
        
        // When
        let formattedDistance = Utilities.formatDistance(distance)
        
        // Then
        XCTAssertEqual(formattedDistance, "1.3km")
    }
    
    func testFormatDistanceZero() {
        // Given
        let distance: Double = 0
        
        // When
        let formattedDistance = Utilities.formatDistance(distance)
        
        // Then
        XCTAssertEqual(formattedDistance, "0m")
    }
    
    func testFormatDistanceNegative() {
        // Given
        let distance: Double = -100
        
        // When
        let formattedDistance = Utilities.formatDistance(distance)
        
        // Then
        XCTAssertEqual(formattedDistance, "0m")
    }
    
    // MARK: - Rating Formatting Tests
    
    func testFormatRatingWithValidRating() {
        // Given
        let rating: Double = 4.2
        
        // When
        let formattedRating = Utilities.formatRating(rating)
        
        // Then
        XCTAssertEqual(formattedRating, "4.2")
    }
    
    func testFormatRatingWithNil() {
        // Given
        let rating: Double? = nil
        
        // When
        let formattedRating = Utilities.formatRating(rating)
        
        // Then
        XCTAssertEqual(formattedRating, "評価なし")
    }
    
    func testFormatRatingWithZero() {
        // Given
        let rating: Double = 0.0
        
        // When
        let formattedRating = Utilities.formatRating(rating)
        
        // Then
        XCTAssertEqual(formattedRating, "0.0")
    }
    
    func testFormatRatingWithHighValue() {
        // Given
        let rating: Double = 5.0
        
        // When
        let formattedRating = Utilities.formatRating(rating)
        
        // Then
        XCTAssertEqual(formattedRating, "5.0")
    }
    
    // MARK: - Price Level Formatting Tests
    
    func testFormatPriceLevelWithValidLevel() {
        // Given
        let priceLevel: Int = 2
        
        // When
        let formattedPrice = Utilities.formatPriceLevel(priceLevel)
        
        // Then
        XCTAssertEqual(formattedPrice, "¥¥")
    }
    
    func testFormatPriceLevelWithNil() {
        // Given
        let priceLevel: Int? = nil
        
        // When
        let formattedPrice = Utilities.formatPriceLevel(priceLevel)
        
        // Then
        XCTAssertEqual(formattedPrice, "価格不明")
    }
    
    func testFormatPriceLevelWithZero() {
        // Given
        let priceLevel: Int = 0
        
        // When
        let formattedPrice = Utilities.formatPriceLevel(priceLevel)
        
        // Then
        XCTAssertEqual(formattedPrice, "¥")
    }
    
    func testFormatPriceLevelWithMaxValue() {
        // Given
        let priceLevel: Int = 4
        
        // When
        let formattedPrice = Utilities.formatPriceLevel(priceLevel)
        
        // Then
        XCTAssertEqual(formattedPrice, "¥¥¥¥")
    }
    
    func testFormatPriceLevelWithInvalidValue() {
        // Given
        let priceLevel: Int = 5
        
        // When
        let formattedPrice = Utilities.formatPriceLevel(priceLevel)
        
        // Then
        XCTAssertEqual(formattedPrice, "価格不明")
    }
    
    // MARK: - Phone Number Formatting Tests
    
    func testFormatPhoneNumberWithValidNumber() {
        // Given
        let phoneNumber = "0312345678"
        
        // When
        let formattedNumber = Utilities.formatPhoneNumber(phoneNumber)
        
        // Then
        XCTAssertEqual(formattedNumber, "03-1234-5678")
    }
    
    func testFormatPhoneNumberWithNil() {
        // Given
        let phoneNumber: String? = nil
        
        // When
        let formattedNumber = Utilities.formatPhoneNumber(phoneNumber)
        
        // Then
        XCTAssertEqual(formattedNumber, "電話番号なし")
    }
    
    func testFormatPhoneNumberWithEmptyString() {
        // Given
        let phoneNumber = ""
        
        // When
        let formattedNumber = Utilities.formatPhoneNumber(phoneNumber)
        
        // Then
        XCTAssertEqual(formattedNumber, "電話番号なし")
    }
    
    func testFormatPhoneNumberWithShortNumber() {
        // Given
        let phoneNumber = "123456"
        
        // When
        let formattedNumber = Utilities.formatPhoneNumber(phoneNumber)
        
        // Then
        XCTAssertEqual(formattedNumber, phoneNumber)
    }
    
    func testFormatPhoneNumberWithLongNumber() {
        // Given
        let phoneNumber = "031234567890"
        
        // When
        let formattedNumber = Utilities.formatPhoneNumber(phoneNumber)
        
        // Then
        XCTAssertEqual(formattedNumber, "03-1234-5678")
    }
    
    // MARK: - URL Validation Tests
    
    func testIsValidURLWithValidURL() {
        // Given
        let urlString = "https://www.example.com"
        
        // When
        let isValid = Utilities.isValidURL(urlString)
        
        // Then
        XCTAssertTrue(isValid)
    }
    
    func testIsValidURLWithInvalidURL() {
        // Given
        let urlString = "invalid-url"
        
        // When
        let isValid = Utilities.isValidURL(urlString)
        
        // Then
        XCTAssertFalse(isValid)
    }
    
    func testIsValidURLWithNil() {
        // Given
        let urlString: String? = nil
        
        // When
        let isValid = Utilities.isValidURL(urlString)
        
        // Then
        XCTAssertFalse(isValid)
    }
    
    func testIsValidURLWithEmptyString() {
        // Given
        let urlString = ""
        
        // When
        let isValid = Utilities.isValidURL(urlString)
        
        // Then
        XCTAssertFalse(isValid)
    }
    
    func testIsValidURLWithHTTPURL() {
        // Given
        let urlString = "http://example.com"
        
        // When
        let isValid = Utilities.isValidURL(urlString)
        
        // Then
        XCTAssertTrue(isValid)
    }
    
    // MARK: - Date Formatting Tests
    
    func testFormatDateWithValidDate() {
        // Given
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let dateString = "2024-01-15 14:30:00"
        let testDate = formatter.date(from: dateString)!
        
        // When
        let formattedDate = Utilities.formatDate(testDate)
        
        // Then
        XCTAssertFalse(formattedDate.isEmpty)
        XCTAssertTrue(formattedDate.contains("2024"))
    }
    
    func testFormatDateWithNil() {
        // Given
        let date: Date? = nil
        
        // When
        let formattedDate = Utilities.formatDate(date)
        
        // Then
        XCTAssertEqual(formattedDate, "日付なし")
    }
    
    // MARK: - String Extension Tests
    
    func testStringTruncatedToLength() {
        // Given
        let longString = "This is a very long string that needs to be truncated"
        
        // When
        let truncated = longString.truncated(to: 20)
        
        // Then
        XCTAssertEqual(truncated.count, 20)
        XCTAssertTrue(truncated.hasSuffix("..."))
    }
    
    func testStringTruncatedToLengthShorterThanOriginal() {
        // Given
        let shortString = "Short"
        
        // When
        let truncated = shortString.truncated(to: 20)
        
        // Then
        XCTAssertEqual(truncated, shortString)
    }
    
    func testStringTruncatedToLengthEqualToOriginal() {
        // Given
        let string = "Exactly twenty chars"
        
        // When
        let truncated = string.truncated(to: 20)
        
        // Then
        XCTAssertEqual(truncated, string)
    }
    
    func testStringTruncatedToZero() {
        // Given
        let string = "Test string"
        
        // When
        let truncated = string.truncated(to: 0)
        
        // Then
        XCTAssertEqual(truncated, "...")
    }
    
    // MARK: - Array Extension Tests
    
    func testArraySafeSubscriptWithValidIndex() {
        // Given
        let array = [1, 2, 3, 4, 5]
        
        // When
        let element = array[safe: 2]
        
        // Then
        XCTAssertEqual(element, 3)
    }
    
    func testArraySafeSubscriptWithInvalidIndex() {
        // Given
        let array = [1, 2, 3, 4, 5]
        
        // When
        let element = array[safe: 10]
        
        // Then
        XCTAssertNil(element)
    }
    
    func testArraySafeSubscriptWithNegativeIndex() {
        // Given
        let array = [1, 2, 3, 4, 5]
        
        // When
        let element = array[safe: -1]
        
        // Then
        XCTAssertNil(element)
    }
    
    func testArraySafeSubscriptWithEmptyArray() {
        // Given
        let array: [Int] = []
        
        // When
        let element = array[safe: 0]
        
        // Then
        XCTAssertNil(element)
    }
    
    // MARK: - CLLocationCoordinate2D Extension Tests
    
    func testCLLocationCoordinate2DDistanceTo() {
        // Given
        let coordinate1 = CLLocationCoordinate2D(latitude: 35.6580, longitude: 139.7016)
        let coordinate2 = CLLocationCoordinate2D(latitude: 35.6909, longitude: 139.7003)
        
        // When
        let distance = coordinate1.distance(to: coordinate2)
        
        // Then
        XCTAssertGreaterThan(distance, 0)
        XCTAssertLessThan(distance, 10000) // 10km以内
    }
    
    func testCLLocationCoordinate2DDistanceToSameLocation() {
        // Given
        let coordinate = CLLocationCoordinate2D(latitude: 35.6580, longitude: 139.7016)
        
        // When
        let distance = coordinate.distance(to: coordinate)
        
        // Then
        XCTAssertEqual(distance, 0, accuracy: 0.1)
    }
    
    func testCLLocationCoordinate2DIsValid() {
        // Given
        let validCoordinate = CLLocationCoordinate2D(latitude: 35.6580, longitude: 139.7016)
        let invalidLatitude = CLLocationCoordinate2D(latitude: 91.0, longitude: 139.7016)
        let invalidLongitude = CLLocationCoordinate2D(latitude: 35.6580, longitude: 181.0)
        
        // When & Then
        XCTAssertTrue(validCoordinate.isValid)
        XCTAssertFalse(invalidLatitude.isValid)
        XCTAssertFalse(invalidLongitude.isValid)
    }
    
    // MARK: - Color Extension Tests
    
    func testColorHexInitialization() {
        // Given
        let hexString = "#FF0000"
        
        // When
        let color = Color(hex: hexString)
        
        // Then
        XCTAssertNotNil(color)
    }
    
    func testColorHexInitializationWithInvalidHex() {
        // Given
        let invalidHex = "invalid"
        
        // When
        let color = Color(hex: invalidHex)
        
        // Then
        XCTAssertNotNil(color) // デフォルトカラーが返される
    }
    
    func testColorHexInitializationWithNil() {
        // Given
        let hexString: String? = nil
        
        // When
        let color = Color(hex: hexString)
        
        // Then
        XCTAssertNotNil(color) // デフォルトカラーが返される
    }
    
    // MARK: - View Extension Tests
    
    func testViewCornerRadius() {
        // Given
        let cornerRadius: CGFloat = 10.0
        
        // When
        let modifiedView = Text("Test").cornerRadius(cornerRadius)
        
        // Then
        XCTAssertNotNil(modifiedView)
    }
    
    func testViewShadow() {
        // Given
        let radius: CGFloat = 5.0
        let x: CGFloat = 2.0
        let y: CGFloat = 2.0
        let color = Color.black
        
        // When
        let modifiedView = Text("Test").shadow(radius: radius, x: x, y: y, color: color)
        
        // Then
        XCTAssertNotNil(modifiedView)
    }
    
    // MARK: - Error Handling Tests
    
    func testHandleErrorWithNetworkError() {
        // Given
        let error = NSError(domain: "Network", code: 1001, userInfo: nil)
        
        // When
        let errorMessage = Utilities.handleError(error)
        
        // Then
        XCTAssertFalse(errorMessage.isEmpty)
        XCTAssertTrue(errorMessage.contains("ネットワーク"))
    }
    
    func testHandleErrorWithLocationError() {
        // Given
        let error = LocationService.LocationError.denied
        
        // When
        let errorMessage = Utilities.handleError(error)
        
        // Then
        XCTAssertFalse(errorMessage.isEmpty)
        XCTAssertTrue(errorMessage.contains("位置情報"))
    }
    
    func testHandleErrorWithPlacesError() {
        // Given
        let error = GooglePlacesService.PlacesError.invalidAPIKey
        
        // When
        let errorMessage = Utilities.handleError(error)
        
        // Then
        XCTAssertFalse(errorMessage.isEmpty)
        XCTAssertTrue(errorMessage.contains("API"))
    }
    
    func testHandleErrorWithUnknownError() {
        // Given
        let error = NSError(domain: "Unknown", code: 9999, userInfo: nil)
        
        // When
        let errorMessage = Utilities.handleError(error)
        
        // Then
        XCTAssertFalse(errorMessage.isEmpty)
        XCTAssertTrue(errorMessage.contains("エラー"))
    }
    
    // MARK: - Validation Tests
    
    func testValidateSearchRadius() {
        // Given
        let validRadius: Double = 1000
        let tooSmallRadius: Double = -100
        let tooLargeRadius: Double = 100000
        
        // When & Then
        XCTAssertTrue(Utilities.validateSearchRadius(validRadius))
        XCTAssertFalse(Utilities.validateSearchRadius(tooSmallRadius))
        XCTAssertFalse(Utilities.validateSearchRadius(tooLargeRadius))
    }
    
    func testValidateRating() {
        // Given
        let validRating: Double = 4.5
        let tooSmallRating: Double = -1.0
        let tooLargeRating: Double = 6.0
        
        // When & Then
        XCTAssertTrue(Utilities.validateRating(validRating))
        XCTAssertFalse(Utilities.validateRating(tooSmallRating))
        XCTAssertFalse(Utilities.validateRating(tooLargeRating))
    }
    
    func testValidatePriceLevel() {
        // Given
        let validPriceLevel: Int = 2
        let tooSmallPriceLevel: Int = -1
        let tooLargePriceLevel: Int = 5
        
        // When & Then
        XCTAssertTrue(Utilities.validatePriceLevel(validPriceLevel))
        XCTAssertFalse(Utilities.validatePriceLevel(tooSmallPriceLevel))
        XCTAssertFalse(Utilities.validatePriceLevel(tooLargePriceLevel))
    }
} 