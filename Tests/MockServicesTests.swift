import XCTest
import CoreLocation
import Combine
@testable import CafeParkingFinderApp

final class MockServicesTests: XCTestCase {
    
    var mockLocationService: MockLocationService!
    var mockPlacesService: MockGooglePlacesService!
    var mockViewModel: MockCafeSearchViewModel!
    var cancellables: Set<AnyCancellable>!
    
    override func setUp() {
        super.setUp()
        mockLocationService = MockLocationService()
        mockPlacesService = MockGooglePlacesService()
        mockViewModel = MockCafeSearchViewModel()
        cancellables = Set<AnyCancellable>()
    }
    
    override func tearDown() {
        mockLocationService = nil
        mockPlacesService = nil
        mockViewModel = nil
        cancellables = nil
        super.tearDown()
    }
    
    // MARK: - MockLocationService Tests
    
    func testMockLocationServiceInitialization() {
        // Then
        XCTAssertNotNil(mockLocationService)
        XCTAssertEqual(mockLocationService.authorizationStatus, .authorizedWhenInUse)
        XCTAssertNotNil(mockLocationService.currentLocation)
        XCTAssertNil(mockLocationService.locationError)
    }
    
    func testMockLocationServiceRequestLocationPermission() {
        // When
        mockLocationService.requestLocationPermission()
        
        // Then
        XCTAssertEqual(mockLocationService.authorizationStatus, .authorizedWhenInUse)
        XCTAssertNotNil(mockLocationService.currentLocation)
        XCTAssertEqual(mockLocationService.currentLocation, MockData.tokyoLocation)
    }
    
    func testMockLocationServiceSetLocation() {
        // Given
        let newLocation = CLLocation(latitude: 35.6909, longitude: 139.7003)
        
        // When
        mockLocationService.setLocation(newLocation)
        
        // Then
        XCTAssertEqual(mockLocationService.currentLocation, newLocation)
    }
    
    func testMockLocationServiceGetCurrentLocation() {
        // Given
        let expectation = XCTestExpectation(description: "Get current location")
        
        // When
        mockLocationService.getCurrentLocation()
            .sink(
                receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        XCTFail("Should not fail: \(error)")
                    }
                    expectation.fulfill()
                },
                receiveValue: { location in
                    XCTAssertEqual(location, MockData.tokyoLocation)
                    expectation.fulfill()
                }
            )
            .store(in: &cancellables)
        
        // Then
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testMockLocationServiceGetCurrentLocationWithoutLocation() {
        // Given
        let expectation = XCTestExpectation(description: "Get current location without location")
        mockLocationService.currentLocation = nil
        
        // When
        mockLocationService.getCurrentLocation()
            .sink(
                receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        XCTAssertEqual(error, .unavailable)
                        expectation.fulfill()
                    }
                },
                receiveValue: { _ in
                    XCTFail("Should not receive value")
                }
            )
            .store(in: &cancellables)
        
        // Then
        wait(for: [expectation], timeout: 1.0)
    }
    
    // MARK: - MockGooglePlacesService Tests
    
    func testMockGooglePlacesServiceInitialization() {
        // Then
        XCTAssertNotNil(mockPlacesService)
        XCTAssertFalse(mockPlacesService.isLoading)
        XCTAssertNil(mockPlacesService.error)
    }
    
    func testMockGooglePlacesServiceSearchCafesWithParking() {
        // Given
        let location = CLLocation(latitude: 35.6580, longitude: 139.7016)
        let filter = SearchFilter()
        let expectation = XCTestExpectation(description: "Search cafes with parking")
        
        // When
        mockPlacesService.searchCafesWithParking(near: location, radius: 1000, filter: filter)
            .sink(
                receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        XCTFail("Should not fail: \(error)")
                    }
                    expectation.fulfill()
                },
                receiveValue: { cafes in
                    XCTAssertFalse(cafes.isEmpty)
                    XCTAssertEqual(cafes.count, MockData.sampleCafes.count)
                    expectation.fulfill()
                }
            )
            .store(in: &cancellables)
        
        // Then
        wait(for: [expectation], timeout: 2.0)
    }
    
    func testMockGooglePlacesServiceSearchWithRatingFilter() {
        // Given
        let location = CLLocation(latitude: 35.6580, longitude: 139.7016)
        let filter = SearchFilter(minRating: 4.0)
        let expectation = XCTestExpectation(description: "Search with rating filter")
        
        // When
        mockPlacesService.searchCafesWithParking(near: location, radius: 1000, filter: filter)
            .sink(
                receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        XCTFail("Should not fail: \(error)")
                    }
                    expectation.fulfill()
                },
                receiveValue: { cafes in
                    // 評価4.0以上のカフェのみが返される
                    for cafe in cafes {
                        if let rating = cafe.rating {
                            XCTAssertGreaterThanOrEqual(rating, 4.0)
                        }
                    }
                    expectation.fulfill()
                }
            )
            .store(in: &cancellables)
        
        // Then
        wait(for: [expectation], timeout: 2.0)
    }
    
    func testMockGooglePlacesServiceSearchWithPriceFilter() {
        // Given
        let location = CLLocation(latitude: 35.6580, longitude: 139.7016)
        let filter = SearchFilter(maxPriceLevel: 2)
        let expectation = XCTestExpectation(description: "Search with price filter")
        
        // When
        mockPlacesService.searchCafesWithParking(near: location, radius: 1000, filter: filter)
            .sink(
                receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        XCTFail("Should not fail: \(error)")
                    }
                    expectation.fulfill()
                },
                receiveValue: { cafes in
                    // 価格レベル2以下のカフェのみが返される
                    for cafe in cafes {
                        if let priceLevel = cafe.priceLevel {
                            XCTAssertLessThanOrEqual(priceLevel, 2)
                        }
                    }
                    expectation.fulfill()
                }
            )
            .store(in: &cancellables)
        
        // Then
        wait(for: [expectation], timeout: 2.0)
    }
    
    func testMockGooglePlacesServiceSearchWithOpenNowFilter() {
        // Given
        let location = CLLocation(latitude: 35.6580, longitude: 139.7016)
        let filter = SearchFilter(openNow: true)
        let expectation = XCTestExpectation(description: "Search with open now filter")
        
        // When
        mockPlacesService.searchCafesWithParking(near: location, radius: 1000, filter: filter)
            .sink(
                receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        XCTFail("Should not fail: \(error)")
                    }
                    expectation.fulfill()
                },
                receiveValue: { cafes in
                    // 営業中のカフェのみが返される
                    for cafe in cafes {
                        XCTAssertTrue(cafe.openingHours?.openNow == true)
                    }
                    expectation.fulfill()
                }
            )
            .store(in: &cancellables)
        
        // Then
        wait(for: [expectation], timeout: 2.0)
    }
    
    func testMockGooglePlacesServiceGetPlaceDetails() {
        // Given
        let placeId = "mock_place_1"
        let expectation = XCTestExpectation(description: "Get place details")
        
        // When
        mockPlacesService.getPlaceDetails(placeId: placeId)
            .sink(
                receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        XCTFail("Should not fail: \(error)")
                    }
                    expectation.fulfill()
                },
                receiveValue: { cafe in
                    XCTAssertEqual(cafe.placeId, placeId)
                    XCTAssertEqual(cafe.name, "スターバックス 渋谷店")
                    expectation.fulfill()
                }
            )
            .store(in: &cancellables)
        
        // Then
        wait(for: [expectation], timeout: 2.0)
    }
    
    func testMockGooglePlacesServiceGetPlaceDetailsWithInvalidId() {
        // Given
        let placeId = "invalid_place_id"
        let expectation = XCTestExpectation(description: "Get place details with invalid ID")
        
        // When
        mockPlacesService.getPlaceDetails(placeId: placeId)
            .sink(
                receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        XCTAssertEqual(error, .invalidResponse)
                        expectation.fulfill()
                    }
                },
                receiveValue: { _ in
                    XCTFail("Should not receive value")
                }
            )
            .store(in: &cancellables)
        
        // Then
        wait(for: [expectation], timeout: 2.0)
    }
    
    func testMockGooglePlacesServiceSimulateError() {
        // Given
        let error = GooglePlacesService.PlacesError.invalidAPIKey
        
        // When
        mockPlacesService.simulateError(error)
        
        // Then
        XCTAssertEqual(mockPlacesService.error, error)
    }
    
    func testMockGooglePlacesServiceSetDelay() {
        // Given
        let newDelay: TimeInterval = 0.5
        
        // When
        mockPlacesService.setDelay(newDelay)
        
        // Then
        // 遅延時間が設定されていることを確認（内部実装に依存）
        let location = CLLocation(latitude: 35.6580, longitude: 139.7016)
        let filter = SearchFilter()
        let expectation = XCTestExpectation(description: "Search with custom delay")
        
        let startTime = Date()
        mockPlacesService.searchCafesWithParking(near: location, radius: 1000, filter: filter)
            .sink(
                receiveCompletion: { _ in
                    expectation.fulfill()
                },
                receiveValue: { _ in
                    expectation.fulfill()
                }
            )
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 2.0)
        let elapsedTime = Date().timeIntervalSince(startTime)
        XCTAssertGreaterThanOrEqual(elapsedTime, newDelay)
    }
    
    // MARK: - MockCafeSearchViewModel Tests
    
    func testMockCafeSearchViewModelInitialization() {
        // Then
        XCTAssertNotNil(mockViewModel)
        XCTAssertTrue(mockViewModel.cafes.isEmpty)
        XCTAssertNil(mockViewModel.selectedCafe)
        XCTAssertFalse(mockViewModel.isLoading)
        XCTAssertNil(mockViewModel.error)
        XCTAssertEqual(mockViewModel.searchFilter.radius, 1000)
        XCTAssertNotNil(mockViewModel.currentLocation)
    }
    
    func testMockCafeSearchViewModelRequestLocationPermission() {
        // When
        mockViewModel.requestLocationPermission()
        
        // Then
        XCTAssertEqual(mockViewModel.currentLocation, MockData.tokyoLocation)
    }
    
    func testMockCafeSearchViewModelSearchCafes() {
        // Given
        let expectation = XCTestExpectation(description: "Search cafes")
        
        // When
        mockViewModel.searchCafes()
        
        // Then
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            XCTAssertFalse(self.mockViewModel.isLoading)
            XCTAssertFalse(self.mockViewModel.cafes.isEmpty)
            XCTAssertNil(self.mockViewModel.error)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 2.0)
    }
    
    func testMockCafeSearchViewModelSelectCafe() {
        // Given
        let cafe = MockData.sampleCafes[0]
        
        // When
        mockViewModel.selectCafe(cafe)
        
        // Then
        XCTAssertEqual(mockViewModel.selectedCafe, cafe)
    }
    
    func testMockCafeSearchViewModelUpdateFilter() {
        // Given
        let newFilter = SearchFilter(radius: 2000, minRating: 4.0)
        
        // When
        mockViewModel.updateFilter(newFilter)
        
        // Then
        XCTAssertEqual(mockViewModel.searchFilter.radius, 2000)
        XCTAssertEqual(mockViewModel.searchFilter.minRating, 4.0)
    }
    
    func testMockCafeSearchViewModelToggleFavorite() {
        // Given
        let cafe = MockData.sampleCafes[0]
        
        // When
        mockViewModel.toggleFavorite(for: cafe)
        
        // Then
        // モックでは何も起こらないが、エラーが発生しないことを確認
        XCTAssertNotNil(mockViewModel)
    }
    
    func testMockCafeSearchViewModelShareCafe() {
        // Given
        let cafe = MockData.sampleCafes[0]
        
        // When
        mockViewModel.shareCafe(cafe)
        
        // Then
        // モックでは何も起こらないが、エラーが発生しないことを確認
        XCTAssertNotNil(mockViewModel)
    }
    
    func testMockCafeSearchViewModelGetDirections() {
        // Given
        let cafe = MockData.sampleCafes[0]
        
        // When
        mockViewModel.getDirections(to: cafe)
        
        // Then
        // モックでは何も起こらないが、エラーが発生しないことを確認
        XCTAssertNotNil(mockViewModel)
    }
    
    func testMockCafeSearchViewModelGetDistance() {
        // Given
        let cafe = MockData.sampleCafes[0]
        
        // When
        let distance = mockViewModel.getDistance(to: cafe)
        
        // Then
        XCTAssertFalse(distance.isEmpty)
        XCTAssertNotEqual(distance, "距離不明")
    }
    
    func testMockCafeSearchViewModelLoadMockData() {
        // When
        mockViewModel.loadMockData()
        
        // Then
        XCTAssertEqual(mockViewModel.cafes.count, MockData.sampleCafes.count)
        XCTAssertEqual(mockViewModel.cafes, MockData.sampleCafes)
    }
    
    func testMockCafeSearchViewModelSimulateError() {
        // Given
        let error = LocationService.LocationError.denied
        
        // When
        mockViewModel.simulateError(error)
        
        // Then
        XCTAssertEqual(mockViewModel.error as? LocationService.LocationError, error)
    }
    
    // MARK: - Integration Tests
    
    func testMockServicesIntegration() {
        // Given
        let expectation = XCTestExpectation(description: "Mock services integration")
        
        // When
        mockViewModel.requestLocationPermission()
        mockViewModel.searchCafes()
        
        // Then
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            XCTAssertNotNil(self.mockViewModel.currentLocation)
            XCTAssertFalse(self.mockViewModel.cafes.isEmpty)
            XCTAssertFalse(self.mockViewModel.isLoading)
            XCTAssertNil(self.mockViewModel.error)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 3.0)
    }
    
    func testMockServicesErrorHandling() {
        // Given
        let expectation = XCTestExpectation(description: "Mock services error handling")
        
        // When
        mockPlacesService.simulateError(.invalidAPIKey)
        
        // Then
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            XCTAssertEqual(self.mockViewModel.error as? GooglePlacesService.PlacesError, .invalidAPIKey)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
} 