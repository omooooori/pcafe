import XCTest
import CoreLocation
import Combine
@testable import CafeParkingFinderApp

final class GooglePlacesServiceTests: XCTestCase {
    
    var placesService: GooglePlacesService!
    var cancellables: Set<AnyCancellable>!
    
    override func setUp() {
        super.setUp()
        placesService = GooglePlacesService(apiKey: "test-api-key")
        cancellables = Set<AnyCancellable>()
    }
    
    override func tearDown() {
        placesService = nil
        cancellables = nil
        super.tearDown()
    }
    
    // MARK: - Initialization Tests
    
    func testGooglePlacesServiceInitialization() {
        // Then
        XCTAssertNotNil(placesService)
        XCTAssertFalse(placesService.isLoading)
        XCTAssertNil(placesService.error)
    }
    
    // MARK: - Error Handling Tests
    
    func testPlacesErrorDescriptions() {
        // Then
        XCTAssertEqual(GooglePlacesService.PlacesError.invalidAPIKey.errorDescription, "APIキーが無効です。")
        XCTAssertEqual(GooglePlacesService.PlacesError.quotaExceeded.errorDescription, "API利用制限に達しました。")
        XCTAssertEqual(GooglePlacesService.PlacesError.requestDenied.errorDescription, "リクエストが拒否されました。")
        XCTAssertEqual(GooglePlacesService.PlacesError.invalidResponse.errorDescription, "サーバーからの応答が無効です。")
    }
    
    func testPlacesErrorWithNetworkError() {
        // Given
        let networkError = NSError(domain: "test", code: 1, userInfo: nil)
        let placesError = GooglePlacesService.PlacesError.networkError(networkError)
        
        // Then
        XCTAssertEqual(placesError.errorDescription, "ネットワークエラー: The operation couldn't be completed. (test error 1.)")
    }
    
    // MARK: - URL Construction Tests
    
    func testSearchCafesWithParkingURLConstruction() {
        // Given
        let location = CLLocation(latitude: 35.6580, longitude: 139.7016)
        let radius: Double = 1500
        let filter = SearchFilter(
            radius: radius,
            minRating: 3.5,
            maxPriceLevel: 3,
            openNow: true,
            parkingTypes: [.free, .paid],
            sortBy: .distance
        )
        
        // When
        let expectation = XCTestExpectation(description: "Search cafes")
        
        placesService.searchCafesWithParking(near: location, radius: radius, filter: filter)
            .sink(
                receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        // 実際のAPI呼び出しは失敗するが、URL構築は成功する
                        XCTAssertTrue(error == .networkError(NSError()) || error == .invalidResponse)
                    }
                    expectation.fulfill()
                },
                receiveValue: { cafes in
                    // 成功した場合は空配列が返される
                    XCTAssertTrue(cafes.isEmpty)
                    expectation.fulfill()
                }
            )
            .store(in: &cancellables)
        
        // Then
        wait(for: [expectation], timeout: 5.0)
    }
    
    // MARK: - Response Processing Tests
    
    func testProcessPlacesResponseWithValidData() {
        // Given
        let response = PlacesResponse(
            status: "OK",
            results: [
                Place(
                    placeId: "place_1",
                    name: "テストカフェ1",
                    vicinity: "東京都渋谷区テスト1-1-1",
                    rating: 4.2,
                    userRatingsTotal: 100,
                    priceLevel: 2,
                    geometry: Geometry(location: Location(lat: 35.6580, lng: 139.7016)),
                    types: ["cafe", "food"],
                    photos: [
                        PlacePhoto(photoReference: "photo_ref_1", height: 400, width: 600)
                    ]
                ),
                Place(
                    placeId: "place_2",
                    name: "テストカフェ2",
                    vicinity: "東京都新宿区テスト2-2-2",
                    rating: 3.8,
                    userRatingsTotal: 50,
                    priceLevel: 1,
                    geometry: Geometry(location: Location(lat: 35.6909, lng: 139.7003)),
                    types: ["cafe"],
                    photos: nil
                )
            ]
        )
        
        let filter = SearchFilter(minRating: 3.0, maxPriceLevel: 3)
        
        // When
        let cafes = placesService.processPlacesResponse(response, filter: filter)
        
        // Then
        XCTAssertEqual(cafes.count, 2)
        XCTAssertEqual(cafes[0].name, "テストカフェ1")
        XCTAssertEqual(cafes[0].rating, 4.2)
        XCTAssertEqual(cafes[0].priceLevel, 2)
        XCTAssertEqual(cafes[1].name, "テストカフェ2")
        XCTAssertEqual(cafes[1].rating, 3.8)
        XCTAssertEqual(cafes[1].priceLevel, 1)
    }
    
    func testProcessPlacesResponseWithFilteredData() {
        // Given
        let response = PlacesResponse(
            status: "OK",
            results: [
                Place(
                    placeId: "place_1",
                    name: "高評価カフェ",
                    vicinity: "東京都渋谷区テスト1-1-1",
                    rating: 4.5,
                    userRatingsTotal: 100,
                    priceLevel: 1,
                    geometry: Geometry(location: Location(lat: 35.6580, lng: 139.7016)),
                    types: ["cafe"],
                    photos: nil
                ),
                Place(
                    placeId: "place_2",
                    name: "低評価カフェ",
                    vicinity: "東京都新宿区テスト2-2-2",
                    rating: 2.5,
                    userRatingsTotal: 50,
                    priceLevel: 4,
                    geometry: Geometry(location: Location(lat: 35.6909, lng: 139.7003)),
                    types: ["cafe"],
                    photos: nil
                )
            ]
        )
        
        let filter = SearchFilter(minRating: 4.0, maxPriceLevel: 2)
        
        // When
        let cafes = placesService.processPlacesResponse(response, filter: filter)
        
        // Then
        XCTAssertEqual(cafes.count, 1)
        XCTAssertEqual(cafes[0].name, "高評価カフェ")
        XCTAssertEqual(cafes[0].rating, 4.5)
        XCTAssertEqual(cafes[0].priceLevel, 1)
    }
    
    func testProcessPlacesResponseWithInvalidStatus() {
        // Given
        let response = PlacesResponse(status: "OVER_QUERY_LIMIT", results: [])
        let filter = SearchFilter()
        
        // When
        let cafes = placesService.processPlacesResponse(response, filter: filter)
        
        // Then
        XCTAssertTrue(cafes.isEmpty)
        XCTAssertEqual(placesService.error, .quotaExceeded)
    }
    
    func testProcessPlacesResponseWithRequestDenied() {
        // Given
        let response = PlacesResponse(status: "REQUEST_DENIED", results: [])
        let filter = SearchFilter()
        
        // When
        let cafes = placesService.processPlacesResponse(response, filter: filter)
        
        // Then
        XCTAssertTrue(cafes.isEmpty)
        XCTAssertEqual(placesService.error, .requestDenied)
    }
    
    func testProcessPlacesResponseWithUnknownStatus() {
        // Given
        let response = PlacesResponse(status: "UNKNOWN_STATUS", results: [])
        let filter = SearchFilter()
        
        // When
        let cafes = placesService.processPlacesResponse(response, filter: filter)
        
        // Then
        XCTAssertTrue(cafes.isEmpty)
        XCTAssertEqual(placesService.error, .invalidResponse)
    }
    
    func testProcessPlacesResponseWithMissingGeometry() {
        // Given
        let response = PlacesResponse(
            status: "OK",
            results: [
                Place(
                    placeId: "place_1",
                    name: "テストカフェ",
                    vicinity: "東京都渋谷区テスト1-1-1",
                    rating: 4.2,
                    userRatingsTotal: 100,
                    priceLevel: 2,
                    geometry: nil,
                    types: ["cafe"],
                    photos: nil
                )
            ]
        )
        
        let filter = SearchFilter()
        
        // When
        let cafes = placesService.processPlacesResponse(response, filter: filter)
        
        // Then
        XCTAssertTrue(cafes.isEmpty)
    }
    
    // MARK: - Place Details Tests
    
    func testGetPlaceDetailsURLConstruction() {
        // Given
        let placeId = "test_place_id"
        
        // When
        let expectation = XCTestExpectation(description: "Get place details")
        
        placesService.getPlaceDetails(placeId: placeId)
            .sink(
                receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        // 実際のAPI呼び出しは失敗するが、URL構築は成功する
                        XCTAssertTrue(error == .networkError(NSError()) || error == .invalidResponse)
                    }
                    expectation.fulfill()
                },
                receiveValue: { cafe in
                    // 成功した場合はCafeオブジェクトが返される
                    XCTAssertEqual(cafe.placeId, placeId)
                    expectation.fulfill()
                }
            )
            .store(in: &cancellables)
        
        // Then
        wait(for: [expectation], timeout: 5.0)
    }
    
    // MARK: - Published Properties Tests
    
    func testPublishedPropertiesUpdates() {
        // Given
        let expectation = XCTestExpectation(description: "Published properties updated")
        expectation.expectedFulfillmentCount = 2
        
        var loadingUpdates = 0
        var errorUpdates = 0
        
        // When
        placesService.$isLoading
            .sink { _ in
                loadingUpdates += 1
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        placesService.$error
            .sink { _ in
                errorUpdates += 1
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        // プロパティを更新
        placesService.isLoading = true
        placesService.error = .invalidAPIKey
        
        // Then
        wait(for: [expectation], timeout: 1.0)
        XCTAssertGreaterThan(loadingUpdates, 0)
        XCTAssertGreaterThan(errorUpdates, 0)
    }
    
    // MARK: - Response Models Tests
    
    func testPlacesResponseCodable() throws {
        // Given
        let jsonString = """
        {
            "status": "OK",
            "results": [
                {
                    "place_id": "test_place",
                    "name": "テストカフェ",
                    "vicinity": "東京都テスト区テスト1-1-1",
                    "rating": 4.2,
                    "user_ratings_total": 100,
                    "price_level": 2,
                    "geometry": {
                        "location": {
                            "lat": 35.6580,
                            "lng": 139.7016
                        }
                    },
                    "types": ["cafe", "food"],
                    "photos": [
                        {
                            "photo_reference": "photo_ref",
                            "height": 400,
                            "width": 600
                        }
                    ]
                }
            ]
        }
        """
        
        let jsonData = jsonString.data(using: .utf8)!
        
        // When
        let response = try JSONDecoder().decode(PlacesResponse.self, from: jsonData)
        
        // Then
        XCTAssertEqual(response.status, "OK")
        XCTAssertEqual(response.results.count, 1)
        XCTAssertEqual(response.results[0].placeId, "test_place")
        XCTAssertEqual(response.results[0].name, "テストカフェ")
        XCTAssertEqual(response.results[0].rating, 4.2)
        XCTAssertEqual(response.results[0].userRatingsTotal, 100)
        XCTAssertEqual(response.results[0].priceLevel, 2)
        XCTAssertEqual(response.results[0].geometry?.location.lat, 35.6580, accuracy: 0.0001)
        XCTAssertEqual(response.results[0].geometry?.location.lng, 139.7016, accuracy: 0.0001)
        XCTAssertEqual(response.results[0].types, ["cafe", "food"])
        XCTAssertEqual(response.results[0].photos?.count, 1)
        XCTAssertEqual(response.results[0].photos?.first?.photoReference, "photo_ref")
    }
    
    func testPlaceDetailResponseCodable() throws {
        // Given
        let jsonString = """
        {
            "status": "OK",
            "result": {
                "place_id": "test_place_detail",
                "name": "詳細カフェ",
                "formatted_address": "東京都詳細区詳細1-1-1",
                "formatted_phone_number": "03-1234-5678",
                "rating": 4.5,
                "user_ratings_total": 150,
                "price_level": 3,
                "geometry": {
                    "location": {
                        "lat": 35.6762,
                        "lng": 139.6503
                    }
                },
                "website": "https://detail-cafe.com"
            }
        }
        """
        
        let jsonData = jsonString.data(using: .utf8)!
        
        // When
        let response = try JSONDecoder().decode(PlaceDetailResponse.self, from: jsonData)
        
        // Then
        XCTAssertEqual(response.status, "OK")
        XCTAssertEqual(response.result.placeId, "test_place_detail")
        XCTAssertEqual(response.result.name, "詳細カフェ")
        XCTAssertEqual(response.result.formattedAddress, "東京都詳細区詳細1-1-1")
        XCTAssertEqual(response.result.formattedPhoneNumber, "03-1234-5678")
        XCTAssertEqual(response.result.rating, 4.5)
        XCTAssertEqual(response.result.userRatingsTotal, 150)
        XCTAssertEqual(response.result.priceLevel, 3)
        XCTAssertEqual(response.result.geometry.location.lat, 35.6762, accuracy: 0.0001)
        XCTAssertEqual(response.result.geometry.location.lng, 139.6503, accuracy: 0.0001)
        XCTAssertEqual(response.result.website, "https://detail-cafe.com")
    }
} 