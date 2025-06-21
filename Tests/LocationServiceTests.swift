import XCTest
import CoreLocation
import Combine
@testable import CafeParkingFinderApp

final class LocationServiceTests: XCTestCase {
    
    var locationService: LocationService!
    var cancellables: Set<AnyCancellable>!
    
    override func setUp() {
        super.setUp()
        locationService = LocationService()
        cancellables = Set<AnyCancellable>()
    }
    
    override func tearDown() {
        locationService = nil
        cancellables = nil
        super.tearDown()
    }
    
    // MARK: - Initialization Tests
    
    func testLocationServiceInitialization() {
        // Then
        XCTAssertNotNil(locationService)
        XCTAssertNil(locationService.currentLocation)
        XCTAssertEqual(locationService.authorizationStatus, .notDetermined)
        XCTAssertNil(locationService.locationError)
    }
    
    // MARK: - Location Permission Tests
    
    func testRequestLocationPermissionWhenNotDetermined() {
        // Given
        locationService.authorizationStatus = .notDetermined
        
        // When
        locationService.requestLocationPermission()
        
        // Then
        // 実際の許可要求はテスト環境では動作しないため、状態の確認のみ
        XCTAssertEqual(locationService.authorizationStatus, .notDetermined)
    }
    
    func testRequestLocationPermissionWhenDenied() {
        // Given
        locationService.authorizationStatus = .denied
        
        // When
        locationService.requestLocationPermission()
        
        // Then
        XCTAssertEqual(locationService.locationError, .denied)
    }
    
    func testRequestLocationPermissionWhenRestricted() {
        // Given
        locationService.authorizationStatus = .restricted
        
        // When
        locationService.requestLocationPermission()
        
        // Then
        XCTAssertEqual(locationService.locationError, .denied)
    }
    
    func testRequestLocationPermissionWhenAuthorized() {
        // Given
        locationService.authorizationStatus = .authorizedWhenInUse
        
        // When
        locationService.requestLocationPermission()
        
        // Then
        // 許可済みの場合は位置更新が開始される（実際の動作はテスト環境では制限される）
        XCTAssertEqual(locationService.authorizationStatus, .authorizedWhenInUse)
    }
    
    // MARK: - Location Updates Tests
    
    func testStartLocationUpdatesWhenAuthorized() {
        // Given
        locationService.authorizationStatus = .authorizedWhenInUse
        
        // When
        locationService.startLocationUpdates()
        
        // Then
        // 実際の位置更新はテスト環境では動作しないため、エラーが設定されないことを確認
        XCTAssertNotEqual(locationService.locationError, .denied)
    }
    
    func testStartLocationUpdatesWhenNotAuthorized() {
        // Given
        locationService.authorizationStatus = .denied
        
        // When
        locationService.startLocationUpdates()
        
        // Then
        XCTAssertEqual(locationService.locationError, .denied)
    }
    
    func testStopLocationUpdates() {
        // Given
        locationService.authorizationStatus = .authorizedWhenInUse
        
        // When
        locationService.stopLocationUpdates()
        
        // Then
        // 停止処理はエラーを発生させない
        XCTAssertNotEqual(locationService.locationError, .denied)
    }
    
    // MARK: - Get Current Location Tests
    
    func testGetCurrentLocationWithValidLocation() {
        // Given
        let expectedLocation = CLLocation(latitude: 35.6580, longitude: 139.7016)
        locationService.currentLocation = expectedLocation
        
        // When
        var receivedLocation: CLLocation?
        var receivedError: LocationService.LocationError?
        
        locationService.getCurrentLocation()
            .sink(
                receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        receivedError = error
                    }
                },
                receiveValue: { location in
                    receivedLocation = location
                }
            )
            .store(in: &cancellables)
        
        // Then
        XCTAssertNotNil(receivedLocation)
        XCTAssertEqual(receivedLocation?.coordinate.latitude, expectedLocation.coordinate.latitude, accuracy: 0.0001)
        XCTAssertEqual(receivedLocation?.coordinate.longitude, expectedLocation.coordinate.longitude, accuracy: 0.0001)
        XCTAssertNil(receivedError)
    }
    
    func testGetCurrentLocationWithoutLocation() {
        // Given
        locationService.currentLocation = nil
        
        // When
        var receivedLocation: CLLocation?
        var receivedError: LocationService.LocationError?
        
        locationService.getCurrentLocation()
            .sink(
                receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        receivedError = error
                    }
                },
                receiveValue: { location in
                    receivedLocation = location
                }
            )
            .store(in: &cancellables)
        
        // Then
        XCTAssertNil(receivedLocation)
        XCTAssertEqual(receivedError, .unavailable)
    }
    
    // MARK: - Error Handling Tests
    
    func testLocationErrorDescriptions() {
        // Then
        XCTAssertEqual(LocationService.LocationError.denied.errorDescription, "位置情報の使用が拒否されました。設定から許可してください。")
        XCTAssertEqual(LocationService.LocationError.restricted.errorDescription, "位置情報の使用が制限されています。")
        XCTAssertEqual(LocationService.LocationError.unavailable.errorDescription, "位置情報が利用できません。")
        XCTAssertEqual(LocationService.LocationError.unknown.errorDescription, "位置情報の取得中にエラーが発生しました。")
    }
    
    // MARK: - Published Properties Tests
    
    func testPublishedPropertiesUpdates() {
        // Given
        let expectation = XCTestExpectation(description: "Published properties updated")
        expectation.expectedFulfillmentCount = 3
        
        var locationUpdates = 0
        var statusUpdates = 0
        var errorUpdates = 0
        
        // When
        locationService.$currentLocation
            .sink { _ in
                locationUpdates += 1
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        locationService.$authorizationStatus
            .sink { _ in
                statusUpdates += 1
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        locationService.$locationError
            .sink { _ in
                errorUpdates += 1
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        // プロパティを更新
        locationService.currentLocation = CLLocation(latitude: 35.6580, longitude: 139.7016)
        locationService.authorizationStatus = .authorizedWhenInUse
        locationService.locationError = .unavailable
        
        // Then
        wait(for: [expectation], timeout: 1.0)
        XCTAssertGreaterThan(locationUpdates, 0)
        XCTAssertGreaterThan(statusUpdates, 0)
        XCTAssertGreaterThan(errorUpdates, 0)
    }
    
    // MARK: - CLLocationManagerDelegate Tests
    
    func testLocationManagerDidUpdateLocations() {
        // Given
        let testLocation = CLLocation(latitude: 35.6580, longitude: 139.7016)
        let locations = [testLocation]
        
        // When
        locationService.locationManager(CLLocationManager(), didUpdateLocations: locations)
        
        // Then
        XCTAssertNotNil(locationService.currentLocation)
        XCTAssertEqual(locationService.currentLocation?.coordinate.latitude, testLocation.coordinate.latitude, accuracy: 0.0001)
        XCTAssertEqual(locationService.currentLocation?.coordinate.longitude, testLocation.coordinate.longitude, accuracy: 0.0001)
        XCTAssertNil(locationService.locationError)
    }
    
    func testLocationManagerDidUpdateLocationsWithEmptyArray() {
        // Given
        let locations: [CLLocation] = []
        
        // When
        locationService.locationManager(CLLocationManager(), didUpdateLocations: locations)
        
        // Then
        // 空の配列の場合は位置情報が更新されない
        XCTAssertNil(locationService.currentLocation)
    }
    
    func testLocationManagerDidFailWithError() {
        // Given
        let error = NSError(domain: "test", code: 1, userInfo: nil)
        
        // When
        locationService.locationManager(CLLocationManager(), didFailWithError: error)
        
        // Then
        XCTAssertEqual(locationService.locationError, .unknown)
    }
    
    func testLocationManagerDidFailWithCLErrorDenied() {
        // Given
        let error = CLError(.denied)
        
        // When
        locationService.locationManager(CLLocationManager(), didFailWithError: error)
        
        // Then
        XCTAssertEqual(locationService.locationError, .denied)
    }
    
    func testLocationManagerDidFailWithCLErrorLocationUnknown() {
        // Given
        let error = CLError(.locationUnknown)
        
        // When
        locationService.locationManager(CLLocationManager(), didFailWithError: error)
        
        // Then
        XCTAssertEqual(locationService.locationError, .unavailable)
    }
    
    func testLocationManagerDidChangeAuthorizationStatus() {
        // Given
        let newStatus: CLAuthorizationStatus = .authorizedWhenInUse
        
        // When
        locationService.locationManager(CLLocationManager(), didChangeAuthorization: newStatus)
        
        // Then
        XCTAssertEqual(locationService.authorizationStatus, newStatus)
    }
    
    func testLocationManagerDidChangeAuthorizationStatusToDenied() {
        // Given
        let newStatus: CLAuthorizationStatus = .denied
        
        // When
        locationService.locationManager(CLLocationManager(), didChangeAuthorization: newStatus)
        
        // Then
        XCTAssertEqual(locationService.authorizationStatus, newStatus)
        XCTAssertEqual(locationService.locationError, .denied)
    }
    
    func testLocationManagerDidChangeAuthorizationStatusToRestricted() {
        // Given
        let newStatus: CLAuthorizationStatus = .restricted
        
        // When
        locationService.locationManager(CLLocationManager(), didChangeAuthorization: newStatus)
        
        // Then
        XCTAssertEqual(locationService.authorizationStatus, newStatus)
        XCTAssertEqual(locationService.locationError, .denied)
    }
    
    func testLocationManagerDidChangeAuthorizationStatusToNotDetermined() {
        // Given
        let newStatus: CLAuthorizationStatus = .notDetermined
        
        // When
        locationService.locationManager(CLLocationManager(), didChangeAuthorization: newStatus)
        
        // Then
        XCTAssertEqual(locationService.authorizationStatus, newStatus)
        XCTAssertNil(locationService.locationError)
    }
} 