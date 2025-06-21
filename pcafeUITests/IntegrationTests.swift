import XCTest
import CoreLocation
import Combine
@testable import CafeParkingFinderApp

final class IntegrationTests: XCTestCase {
    
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
    
    // MARK: - End-to-End Search Flow Tests
    
    func testCompleteSearchFlow() {
        // Given
        let expectation = XCTestExpectation(description: "Complete search flow")
        
        // When
        // 1. 位置情報の許可を要求
        viewModel.requestLocationPermission()
        
        // 2. カフェを検索
        viewModel.searchCafes()
        
        // 3. 結果を確認
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            XCTAssertNotNil(self.viewModel.currentLocation)
            XCTAssertFalse(self.viewModel.cafes.isEmpty)
            XCTAssertFalse(self.viewModel.isLoading)
            XCTAssertNil(self.viewModel.error)
            expectation.fulfill()
        }
        
        // Then
        wait(for: [expectation], timeout: 3.0)
    }
    
    func testSearchFlowWithFiltering() {
        // Given
        let expectation = XCTestExpectation(description: "Search flow with filtering")
        
        // When
        // 1. 位置情報の許可を要求
        viewModel.requestLocationPermission()
        
        // 2. フィルターを設定
        let filter = SearchFilter(
            radius: 1500,
            minRating: 4.0,
            maxPriceLevel: 2,
            openNow: true,
            parkingTypes: [.free, .paid],
            sortBy: .rating
        )
        viewModel.updateFilter(filter)
        
        // 3. 検索を実行
        viewModel.searchCafes()
        
        // 4. 結果を確認
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            XCTAssertNotNil(self.viewModel.currentLocation)
            XCTAssertFalse(self.viewModel.cafes.isEmpty)
            XCTAssertFalse(self.viewModel.isLoading)
            XCTAssertNil(self.viewModel.error)
            
            // フィルターが適用されていることを確認
            for cafe in self.viewModel.cafes {
                if let rating = cafe.rating {
                    XCTAssertGreaterThanOrEqual(rating, 4.0)
                }
                if let priceLevel = cafe.priceLevel {
                    XCTAssertLessThanOrEqual(priceLevel, 2)
                }
                XCTAssertTrue(cafe.openingHours?.openNow == true)
            }
            
            expectation.fulfill()
        }
        
        // Then
        wait(for: [expectation], timeout: 3.0)
    }
    
    func testSearchFlowWithLocationChange() {
        // Given
        let expectation = XCTestExpectation(description: "Search flow with location change")
        
        // When
        // 1. 初期位置で検索
        viewModel.requestLocationPermission()
        viewModel.searchCafes()
        
        // 2. 位置を変更して再検索
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.mockLocationService.setLocation(MockData.shinjukuLocation)
            self.viewModel.searchCafes()
        }
        
        // 3. 結果を確認
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            XCTAssertNotNil(self.viewModel.currentLocation)
            XCTAssertEqual(self.viewModel.currentLocation, MockData.shinjukuLocation)
            XCTAssertFalse(self.viewModel.cafes.isEmpty)
            XCTAssertFalse(self.viewModel.isLoading)
            XCTAssertNil(self.viewModel.error)
            expectation.fulfill()
        }
        
        // Then
        wait(for: [expectation], timeout: 4.0)
    }
    
    // MARK: - Error Handling Integration Tests
    
    func testErrorHandlingFlow() {
        // Given
        let expectation = XCTestExpectation(description: "Error handling flow")
        
        // When
        // 1. 位置情報エラーをシミュレート
        mockLocationService.locationError = .denied
        
        // 2. 検索を試行
        viewModel.searchCafes()
        
        // 3. エラーが伝播されることを確認
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            XCTAssertEqual(self.viewModel.error as? LocationService.LocationError, .denied)
            XCTAssertTrue(self.viewModel.cafes.isEmpty)
            XCTAssertFalse(self.viewModel.isLoading)
            expectation.fulfill()
        }
        
        // Then
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testErrorRecoveryFlow() {
        // Given
        let expectation = XCTestExpectation(description: "Error recovery flow")
        
        // When
        // 1. エラーをシミュレート
        mockPlacesService.simulateError(.invalidAPIKey)
        
        // 2. エラーが伝播されることを確認
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            XCTAssertEqual(self.viewModel.error as? GooglePlacesService.PlacesError, .invalidAPIKey)
            
            // 3. エラーをクリアして再試行
            self.mockPlacesService.error = nil
            self.viewModel.searchCafes()
        }
        
        // 4. 正常に動作することを確認
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            XCTAssertNil(self.viewModel.error)
            XCTAssertFalse(self.viewModel.cafes.isEmpty)
            XCTAssertFalse(self.viewModel.isLoading)
            expectation.fulfill()
        }
        
        // Then
        wait(for: [expectation], timeout: 3.0)
    }
    
    // MARK: - Data Flow Integration Tests
    
    func testDataFlowFromLocationToSearch() {
        // Given
        let expectation = XCTestExpectation(description: "Data flow from location to search")
        
        // When
        // 1. 位置情報の変更を監視
        var locationUpdates = 0
        viewModel.$currentLocation
            .sink { location in
                if location != nil {
                    locationUpdates += 1
                }
            }
            .store(in: &cancellables)
        
        // 2. 検索結果の変更を監視
        var searchUpdates = 0
        viewModel.$cafes
            .sink { cafes in
                if !cafes.isEmpty {
                    searchUpdates += 1
                }
            }
            .store(in: &cancellables)
        
        // 3. 位置情報を設定して検索
        mockLocationService.setLocation(MockData.shibuyaLocation)
        viewModel.searchCafes()
        
        // 4. データフローを確認
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            XCTAssertGreaterThan(locationUpdates, 0)
            XCTAssertGreaterThan(searchUpdates, 0)
            XCTAssertEqual(self.viewModel.currentLocation, MockData.shibuyaLocation)
            XCTAssertFalse(self.viewModel.cafes.isEmpty)
            expectation.fulfill()
        }
        
        // Then
        wait(for: [expectation], timeout: 3.0)
    }
    
    func testFilterUpdateTriggersSearch() {
        // Given
        let expectation = XCTestExpectation(description: "Filter update triggers search")
        
        // When
        // 1. 初期検索を実行
        mockLocationService.currentLocation = MockData.tokyoLocation
        viewModel.searchCafes()
        
        // 2. フィルター更新を監視
        var filterUpdates = 0
        viewModel.$searchFilter
            .sink { _ in
                filterUpdates += 1
            }
            .store(in: &cancellables)
        
        // 3. フィルターを更新
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            let newFilter = SearchFilter(radius: 2000, minRating: 4.0)
            self.viewModel.updateFilter(newFilter)
        }
        
        // 4. 再検索が実行されることを確認
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            XCTAssertGreaterThan(filterUpdates, 0)
            XCTAssertEqual(self.viewModel.searchFilter.radius, 2000)
            XCTAssertEqual(self.viewModel.searchFilter.minRating, 4.0)
            XCTAssertFalse(self.viewModel.cafes.isEmpty)
            expectation.fulfill()
        }
        
        // Then
        wait(for: [expectation], timeout: 4.0)
    }
    
    // MARK: - User Interaction Integration Tests
    
    func testCafeSelectionFlow() {
        // Given
        let expectation = XCTestExpectation(description: "Cafe selection flow")
        
        // When
        // 1. 検索を実行
        mockLocationService.currentLocation = MockData.tokyoLocation
        viewModel.searchCafes()
        
        // 2. カフェを選択
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            let cafe = self.viewModel.cafes[0]
            self.viewModel.selectCafe(cafe)
            
            // 3. 選択状態を確認
            XCTAssertEqual(self.viewModel.selectedCafe, cafe)
            XCTAssertEqual(self.viewModel.selectedCafe?.id, cafe.id)
            XCTAssertEqual(self.viewModel.selectedCafe?.name, cafe.name)
            expectation.fulfill()
        }
        
        // Then
        wait(for: [expectation], timeout: 2.5)
    }
    
    func testDistanceCalculationIntegration() {
        // Given
        let expectation = XCTestExpectation(description: "Distance calculation integration")
        
        // When
        // 1. 位置情報を設定
        mockLocationService.currentLocation = MockData.tokyoLocation
        
        // 2. 検索を実行
        viewModel.searchCafes()
        
        // 3. 距離計算をテスト
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            for cafe in self.viewModel.cafes {
                let distance = self.viewModel.getDistance(to: cafe)
                XCTAssertFalse(distance.isEmpty)
                XCTAssertNotEqual(distance, "距離不明")
                
                // 距離が数値であることを確認
                if distance.contains("m") {
                    XCTAssertTrue(distance.hasSuffix("m"))
                } else if distance.contains("km") {
                    XCTAssertTrue(distance.hasSuffix("km"))
                }
            }
            expectation.fulfill()
        }
        
        // Then
        wait(for: [expectation], timeout: 2.5)
    }
    
    // MARK: - State Management Integration Tests
    
    func testLoadingStateManagement() {
        // Given
        let expectation = XCTestExpectation(description: "Loading state management")
        
        // When
        // 1. ローディング状態を監視
        var loadingStates: [Bool] = []
        viewModel.$isLoading
            .sink { isLoading in
                loadingStates.append(isLoading)
            }
            .store(in: &cancellables)
        
        // 2. 検索を実行
        mockLocationService.currentLocation = MockData.tokyoLocation
        viewModel.searchCafes()
        
        // 3. ローディング状態の変化を確認
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            XCTAssertGreaterThan(loadingStates.count, 1)
            XCTAssertTrue(loadingStates.contains(true)) // ローディング中
            XCTAssertTrue(loadingStates.contains(false)) // ローディング完了
            XCTAssertFalse(self.viewModel.isLoading) // 最終的にローディング完了
            expectation.fulfill()
        }
        
        // Then
        wait(for: [expectation], timeout: 3.0)
    }
    
    func testErrorStateManagement() {
        // Given
        let expectation = XCTestExpectation(description: "Error state management")
        
        // When
        // 1. エラー状態を監視
        var errorStates: [Error?] = []
        viewModel.$error
            .sink { error in
                errorStates.append(error)
            }
            .store(in: &cancellables)
        
        // 2. エラーをシミュレート
        mockLocationService.locationError = .unavailable
        viewModel.searchCafes()
        
        // 3. エラー状態の変化を確認
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            XCTAssertGreaterThan(errorStates.count, 0)
            XCTAssertNotNil(errorStates.last)
            XCTAssertEqual(self.viewModel.error as? LocationService.LocationError, .unavailable)
            expectation.fulfill()
        }
        
        // Then
        wait(for: [expectation], timeout: 1.0)
    }
    
    // MARK: - Concurrent Operations Tests
    
    func testConcurrentSearchOperations() {
        // Given
        let expectation = XCTestExpectation(description: "Concurrent search operations")
        expectation.expectedFulfillmentCount = 3
        
        // When
        // 1. 複数の検索を同時実行
        mockLocationService.currentLocation = MockData.tokyoLocation
        
        // 検索1
        viewModel.searchCafes()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            expectation.fulfill()
        }
        
        // 検索2（異なる位置）
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.viewModel.searchCafesAtLocation(MockData.shibuyaLocation)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            expectation.fulfill()
        }
        
        // 検索3（フィルター変更後）
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            let newFilter = SearchFilter(radius: 2000)
            self.viewModel.updateFilter(newFilter)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
            expectation.fulfill()
        }
        
        // Then
        wait(for: [expectation], timeout: 2.0)
        // 最後の検索結果が正しく設定されていることを確認
        XCTAssertFalse(viewModel.cafes.isEmpty)
        XCTAssertFalse(viewModel.isLoading)
    }
    
    // MARK: - Data Consistency Tests
    
    func testDataConsistencyAcrossOperations() {
        // Given
        let expectation = XCTestExpectation(description: "Data consistency across operations")
        
        // When
        // 1. 初期検索を実行
        mockLocationService.currentLocation = MockData.tokyoLocation
        viewModel.searchCafes()
        
        // 2. 検索結果を保存
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            let initialCafes = self.viewModel.cafes
            let initialCount = initialCafes.count
            
            // 3. フィルターを変更して再検索
            let newFilter = SearchFilter(minRating: 4.0)
            self.viewModel.updateFilter(newFilter)
            
            // 4. データの一貫性を確認
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                let updatedCafes = self.viewModel.cafes
                
                // フィルターが適用されていることを確認
                for cafe in updatedCafes {
                    if let rating = cafe.rating {
                        XCTAssertGreaterThanOrEqual(rating, 4.0)
                    }
                }
                
                // 元のデータが保持されていることを確認（ID、名前など）
                XCTAssertLessThanOrEqual(updatedCafes.count, initialCount)
                
                expectation.fulfill()
            }
        }
        
        // Then
        wait(for: [expectation], timeout: 4.0)
    }
    
    // MARK: - Memory Management Integration Tests
    
    func testMemoryManagementWithRepeatedOperations() {
        // Given
        let expectation = XCTestExpectation(description: "Memory management with repeated operations")
        
        // When
        // 1. 複数回の検索とフィルター変更を実行
        mockLocationService.currentLocation = MockData.tokyoLocation
        
        for i in 0..<10 {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.2) {
                let filter = SearchFilter(
                    radius: Double(1000 + i * 100),
                    minRating: Double(i % 5),
                    maxPriceLevel: i % 5
                )
                self.viewModel.updateFilter(filter)
            }
        }
        
        // 2. 最終的な状態を確認
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            XCTAssertNotNil(self.viewModel)
            XCTAssertFalse(self.viewModel.isLoading)
            XCTAssertNotNil(self.viewModel.currentLocation)
            expectation.fulfill()
        }
        
        // Then
        wait(for: [expectation], timeout: 4.0)
    }
} 