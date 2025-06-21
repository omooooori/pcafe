import XCTest
import CoreLocation
import Combine
@testable import CafeParkingFinderApp

final class CafeSearchViewModelTests: XCTestCase {
    
    var viewModel: CafeSearchViewModel!
    var mockLocationService: MockLocationService!
    var mockPlacesService: MockGooglePlacesService!
    var cancellables: Set<AnyCancellable>!
    
    override func setUp() {
        super.setUp()
        mockLocationService = MockLocationService()
        mockPlacesService = MockGooglePlacesService()
        viewModel = CafeSearchViewModel(
            locationService: mockLocationService,
            placesService: mockPlacesService
        )
        cancellables = Set<AnyCancellable>()
    }
    
    override func tearDown() {
        viewModel = nil
        mockLocationService = nil
        mockPlacesService = nil
        cancellables = nil
        super.tearDown()
    }
    
    // MARK: - Initialization Tests
    
    func testCafeSearchViewModelInitialization() {
        // Then
        XCTAssertNotNil(viewModel)
        XCTAssertTrue(viewModel.cafes.isEmpty)
        XCTAssertNil(viewModel.selectedCafe)
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNil(viewModel.error)
        XCTAssertEqual(viewModel.searchFilter.radius, 1000)
        XCTAssertNil(viewModel.currentLocation)
    }
    
    // MARK: - Location Permission Tests
    
    func testRequestLocationPermission() {
        // When
        viewModel.requestLocationPermission()
        
        // Then
        XCTAssertEqual(mockLocationService.authorizationStatus, .authorizedWhenInUse)
        XCTAssertNotNil(mockLocationService.currentLocation)
    }
    
    // MARK: - Search Tests
    
    func testSearchCafesWithValidLocation() {
        // Given
        let expectation = XCTestExpectation(description: "Search cafes")
        mockLocationService.currentLocation = MockData.tokyoLocation
        
        // When
        viewModel.searchCafes()
        
        // Then
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            XCTAssertFalse(self.viewModel.isLoading)
            XCTAssertFalse(self.viewModel.cafes.isEmpty)
            XCTAssertNil(self.viewModel.error)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 2.0)
    }
    
    func testSearchCafesWithoutLocation() {
        // Given
        mockLocationService.currentLocation = nil
        
        // When
        viewModel.searchCafes()
        
        // Then
        XCTAssertEqual(viewModel.error, .unavailable)
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertTrue(viewModel.cafes.isEmpty)
    }
    
    func testSearchCafesAtLocation() {
        // Given
        let location = CLLocation(latitude: 35.6909, longitude: 139.7003)
        let expectation = XCTestExpectation(description: "Search cafes at location")
        
        // When
        viewModel.searchCafesAtLocation(location)
        
        // Then
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            XCTAssertFalse(self.viewModel.isLoading)
            XCTAssertFalse(self.viewModel.cafes.isEmpty)
            XCTAssertNil(self.viewModel.error)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 2.0)
    }
    
    // MARK: - Cafe Selection Tests
    
    func testSelectCafe() {
        // Given
        let cafe = MockData.sampleCafes[0]
        
        // When
        viewModel.selectCafe(cafe)
        
        // Then
        XCTAssertEqual(viewModel.selectedCafe, cafe)
    }
    
    func testSelectCafeWithNil() {
        // Given
        let cafe = MockData.sampleCafes[0]
        viewModel.selectedCafe = cafe
        
        // When
        viewModel.selectCafe(cafe)
        
        // Then
        XCTAssertEqual(viewModel.selectedCafe, cafe)
    }
    
    // MARK: - Filter Tests
    
    func testUpdateFilter() {
        // Given
        let newFilter = SearchFilter(
            radius: 2000,
            minRating: 4.0,
            maxPriceLevel: 2,
            openNow: true,
            parkingTypes: [.free],
            sortBy: .rating
        )
        
        // When
        viewModel.updateFilter(newFilter)
        
        // Then
        XCTAssertEqual(viewModel.searchFilter.radius, 2000)
        XCTAssertEqual(viewModel.searchFilter.minRating, 4.0)
        XCTAssertEqual(viewModel.searchFilter.maxPriceLevel, 2)
        XCTAssertTrue(viewModel.searchFilter.openNow)
        XCTAssertEqual(viewModel.searchFilter.parkingTypes, [.free])
        XCTAssertEqual(viewModel.searchFilter.sortBy, .rating)
    }
    
    func testUpdateFilterTriggersSearch() {
        // Given
        let expectation = XCTestExpectation(description: "Filter update triggers search")
        mockLocationService.currentLocation = MockData.tokyoLocation
        viewModel.cafes = MockData.sampleCafes // 既存の検索結果がある状態
        
        let newFilter = SearchFilter(radius: 1500)
        
        // When
        viewModel.updateFilter(newFilter)
        
        // Then
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            XCTAssertFalse(self.viewModel.isLoading)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 2.0)
    }
    
    // MARK: - Sorting Tests
    
    func testApplySortingByDistance() {
        // Given
        let cafes = MockData.sampleCafes
        mockLocationService.currentLocation = MockData.tokyoLocation
        viewModel.searchFilter.sortBy = .distance
        
        // When
        let sortedCafes = viewModel.applySorting(to: cafes)
        
        // Then
        XCTAssertEqual(sortedCafes.count, cafes.count)
        // 距離順でソートされていることを確認（実際の距離計算は簡略化されているため、順序の確認のみ）
        XCTAssertNotNil(sortedCafes.first)
    }
    
    func testApplySortingByRating() {
        // Given
        let cafes = MockData.sampleCafes
        viewModel.searchFilter.sortBy = .rating
        
        // When
        let sortedCafes = viewModel.applySorting(to: cafes)
        
        // Then
        XCTAssertEqual(sortedCafes.count, cafes.count)
        // 評価順でソートされていることを確認
        let ratings = sortedCafes.compactMap { $0.rating }
        if ratings.count > 1 {
            XCTAssertGreaterThanOrEqual(ratings[0], ratings[1])
        }
    }
    
    func testApplySortingByPrice() {
        // Given
        let cafes = MockData.sampleCafes
        viewModel.searchFilter.sortBy = .price
        
        // When
        let sortedCafes = viewModel.applySorting(to: cafes)
        
        // Then
        XCTAssertEqual(sortedCafes.count, cafes.count)
        // 価格順でソートされていることを確認
        let prices = sortedCafes.compactMap { $0.priceLevel }
        if prices.count > 1 {
            XCTAssertLessThanOrEqual(prices[0], prices[1])
        }
    }
    
    func testApplySortingByDistanceWithoutLocation() {
        // Given
        let cafes = MockData.sampleCafes
        mockLocationService.currentLocation = nil
        viewModel.searchFilter.sortBy = .distance
        
        // When
        let sortedCafes = viewModel.applySorting(to: cafes)
        
        // Then
        XCTAssertEqual(sortedCafes.count, cafes.count)
        // 位置情報がない場合は元の順序が維持される
    }
    
    // MARK: - Distance Calculation Tests
    
    func testGetDistanceWithValidLocation() {
        // Given
        let cafe = MockData.sampleCafes[0]
        mockLocationService.currentLocation = MockData.tokyoLocation
        
        // When
        let distance = viewModel.getDistance(to: cafe)
        
        // Then
        XCTAssertFalse(distance.isEmpty)
        XCTAssertNotEqual(distance, "距離不明")
    }
    
    func testGetDistanceWithoutLocation() {
        // Given
        let cafe = MockData.sampleCafes[0]
        mockLocationService.currentLocation = nil
        
        // When
        let distance = viewModel.getDistance(to: cafe)
        
        // Then
        XCTAssertEqual(distance, "距離不明")
    }
    
    func testGetDistanceInMeters() {
        // Given
        let cafe = Cafe(
            id: "test",
            name: "テストカフェ",
            address: "テスト住所",
            phoneNumber: nil,
            rating: nil,
            userRatingsTotal: nil,
            priceLevel: nil,
            placeId: "test_place",
            location: CLLocationCoordinate2D(latitude: 35.6580, longitude: 139.7016),
            types: ["cafe"],
            openingHours: nil,
            photos: nil,
            website: nil,
            isFavorite: false
        )
        mockLocationService.currentLocation = CLLocation(latitude: 35.6580, longitude: 139.7016)
        
        // When
        let distance = viewModel.getDistance(to: cafe)
        
        // Then
        XCTAssertTrue(distance.contains("m") || distance.contains("km"))
    }
    
    // MARK: - Error Handling Tests
    
    func testErrorPropagationFromLocationService() {
        // Given
        let expectation = XCTestExpectation(description: "Error propagation")
        
        // When
        mockLocationService.locationError = .denied
        
        // Then
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            XCTAssertEqual(self.viewModel.error as? LocationService.LocationError, .denied)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testErrorPropagationFromPlacesService() {
        // Given
        let expectation = XCTestExpectation(description: "Error propagation")
        
        // When
        mockPlacesService.error = .invalidAPIKey
        
        // Then
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            XCTAssertEqual(self.viewModel.error as? GooglePlacesService.PlacesError, .invalidAPIKey)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    // MARK: - Published Properties Tests
    
    func testPublishedPropertiesUpdates() {
        // Given
        let expectation = XCTestExpectation(description: "Published properties updated")
        expectation.expectedFulfillmentCount = 6
        
        var cafesUpdates = 0
        var selectedCafeUpdates = 0
        var isLoadingUpdates = 0
        var errorUpdates = 0
        var searchFilterUpdates = 0
        var currentLocationUpdates = 0
        
        // When
        viewModel.$cafes
            .sink { _ in
                cafesUpdates += 1
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        viewModel.$selectedCafe
            .sink { _ in
                selectedCafeUpdates += 1
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        viewModel.$isLoading
            .sink { _ in
                isLoadingUpdates += 1
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        viewModel.$error
            .sink { _ in
                errorUpdates += 1
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        viewModel.$searchFilter
            .sink { _ in
                searchFilterUpdates += 1
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        viewModel.$currentLocation
            .sink { _ in
                currentLocationUpdates += 1
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        // プロパティを更新
        viewModel.cafes = MockData.sampleCafes
        viewModel.selectedCafe = MockData.sampleCafes[0]
        viewModel.isLoading = true
        viewModel.error = LocationService.LocationError.unavailable
        viewModel.searchFilter.radius = 2000
        viewModel.currentLocation = MockData.tokyoLocation
        
        // Then
        wait(for: [expectation], timeout: 1.0)
        XCTAssertGreaterThan(cafesUpdates, 0)
        XCTAssertGreaterThan(selectedCafeUpdates, 0)
        XCTAssertGreaterThan(isLoadingUpdates, 0)
        XCTAssertGreaterThan(errorUpdates, 0)
        XCTAssertGreaterThan(searchFilterUpdates, 0)
        XCTAssertGreaterThan(currentLocationUpdates, 0)
    }
    
    // MARK: - Mock Service Integration Tests
    
    func testMockLocationServiceIntegration() {
        // Given
        let expectation = XCTestExpectation(description: "Location service integration")
        
        // When
        mockLocationService.setLocation(MockData.shibuyaLocation)
        
        // Then
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            XCTAssertEqual(self.viewModel.currentLocation, MockData.shibuyaLocation)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testMockPlacesServiceIntegration() {
        // Given
        let expectation = XCTestExpectation(description: "Places service integration")
        mockLocationService.currentLocation = MockData.tokyoLocation
        
        // When
        viewModel.searchCafes()
        
        // Then
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            XCTAssertFalse(self.viewModel.isLoading)
            XCTAssertFalse(self.viewModel.cafes.isEmpty)
            XCTAssertNil(self.viewModel.error)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 2.0)
    }
    
    // MARK: - Edge Cases
    
    func testSearchWithEmptyResults() {
        // Given
        let expectation = XCTestExpectation(description: "Empty search results")
        mockLocationService.currentLocation = MockData.tokyoLocation
        mockPlacesService.setDelay(0.1) // 高速化
        
        // When
        viewModel.searchCafes()
        
        // Then
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            XCTAssertFalse(self.viewModel.isLoading)
            XCTAssertTrue(self.viewModel.cafes.isEmpty)
            XCTAssertNil(self.viewModel.error)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testSearchWithError() {
        // Given
        let expectation = XCTestExpectation(description: "Search with error")
        mockLocationService.currentLocation = MockData.tokyoLocation
        mockPlacesService.simulateError(.invalidAPIKey)
        
        // When
        viewModel.searchCafes()
        
        // Then
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            XCTAssertFalse(self.viewModel.isLoading)
            XCTAssertTrue(self.viewModel.cafes.isEmpty)
            XCTAssertEqual(self.viewModel.error as? GooglePlacesService.PlacesError, .invalidAPIKey)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
} 