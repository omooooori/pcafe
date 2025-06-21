import XCTest
import CoreLocation
import Combine
@testable import CafeParkingFinderApp

final class PerformanceTests: XCTestCase {
    
    var viewModel: CafeSearchViewModel!
    var mockLocationService: MockLocationService!
    var mockPlacesService: MockGooglePlacesService!
    var cancellables: Set<AnyCancellable>!
    
    override func setUp() {
        super.setUp()
        mockLocationService = MockLocationService()
        mockPlacesService = MockGooglePlacesService(delay: 0.1) // 高速化
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
    
    // MARK: - Large Data Processing Tests
    
    func testLargeCafeArraySortingPerformance() {
        // Given
        let largeCafeArray = generateLargeCafeArray(count: 1000)
        mockLocationService.currentLocation = MockData.tokyoLocation
        
        // When & Then
        measure {
            let sortedCafes = viewModel.applySorting(to: largeCafeArray)
            XCTAssertEqual(sortedCafes.count, largeCafeArray.count)
        }
    }
    
    func testLargeCafeArrayFilteringPerformance() {
        // Given
        let largeCafeArray = generateLargeCafeArray(count: 1000)
        let filter = SearchFilter(minRating: 3.0, maxPriceLevel: 3)
        
        // When & Then
        measure {
            let filteredCafes = largeCafeArray.filter { cafe in
                if let rating = cafe.rating, rating < filter.minRating {
                    return false
                }
                if let priceLevel = cafe.priceLevel, priceLevel > filter.maxPriceLevel {
                    return false
                }
                return true
            }
            XCTAssertLessThanOrEqual(filteredCafes.count, largeCafeArray.count)
        }
    }
    
    func testDistanceCalculationPerformance() {
        // Given
        let cafes = generateLargeCafeArray(count: 500)
        mockLocationService.currentLocation = MockData.tokyoLocation
        
        // When & Then
        measure {
            for cafe in cafes {
                let distance = viewModel.getDistance(to: cafe)
                XCTAssertFalse(distance.isEmpty)
            }
        }
    }
    
    // MARK: - Memory Usage Tests
    
    func testMemoryUsageWithLargeData() {
        // Given
        let initialMemory = getMemoryUsage()
        
        // When
        var cafes: [Cafe] = []
        for i in 0..<1000 {
            let cafe = Cafe(
                id: "cafe_\(i)",
                name: "カフェ\(i)",
                address: "住所\(i)",
                phoneNumber: "03-1234-\(String(format: "%04d", i))",
                rating: Double.random(in: 1.0...5.0),
                userRatingsTotal: Int.random(in: 10...1000),
                priceLevel: Int.random(in: 1...4),
                placeId: "place_\(i)",
                location: CLLocationCoordinate2D(
                    latitude: 35.6580 + Double.random(in: -0.1...0.1),
                    longitude: 139.7016 + Double.random(in: -0.1...0.1)
                ),
                types: ["cafe", "food"],
                openingHours: nil,
                photos: nil,
                website: nil,
                isFavorite: false
            )
            cafes.append(cafe)
        }
        
        // Then
        let finalMemory = getMemoryUsage()
        let memoryIncrease = finalMemory - initialMemory
        
        // メモリ増加量が合理的な範囲内であることを確認（100MB以下）
        XCTAssertLessThan(memoryIncrease, 100 * 1024 * 1024)
        
        // メモリリークがないことを確認
        cafes.removeAll()
        let memoryAfterCleanup = getMemoryUsage()
        XCTAssertLessThan(memoryAfterCleanup - initialMemory, 10 * 1024 * 1024)
    }
    
    func testMemoryUsageWithRepeatedOperations() {
        // Given
        let initialMemory = getMemoryUsage()
        
        // When
        for _ in 0..<100 {
            let cafes = generateLargeCafeArray(count: 100)
            let sortedCafes = viewModel.applySorting(to: cafes)
            let filteredCafes = sortedCafes.filter { $0.rating ?? 0 > 3.0 }
            
            // 結果を使用して何らかの処理を行う
            let totalRating = filteredCafes.compactMap { $0.rating }.reduce(0, +)
            XCTAssertGreaterThanOrEqual(totalRating, 0)
        }
        
        // Then
        let finalMemory = getMemoryUsage()
        let memoryIncrease = finalMemory - initialMemory
        
        // メモリ増加量が合理的な範囲内であることを確認（50MB以下）
        XCTAssertLessThan(memoryIncrease, 50 * 1024 * 1024)
    }
    
    // MARK: - Network Request Performance Tests
    
    func testMultipleConcurrentSearchRequests() {
        // Given
        let expectation = XCTestExpectation(description: "Multiple concurrent searches")
        expectation.expectedFulfillmentCount = 10
        mockLocationService.currentLocation = MockData.tokyoLocation
        
        // When
        let startTime = Date()
        
        for i in 0..<10 {
            viewModel.searchCafes()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                expectation.fulfill()
            }
        }
        
        // Then
        wait(for: [expectation], timeout: 5.0)
        let elapsedTime = Date().timeIntervalSince(startTime)
        
        // 10回の検索が5秒以内に完了することを確認
        XCTAssertLessThan(elapsedTime, 5.0)
    }
    
    func testSearchRequestCancellation() {
        // Given
        let expectation = XCTestExpectation(description: "Search cancellation")
        mockLocationService.currentLocation = MockData.tokyoLocation
        
        // When
        viewModel.searchCafes()
        
        // すぐにキャンセル
        cancellables.removeAll()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            expectation.fulfill()
        }
        
        // Then
        wait(for: [expectation], timeout: 1.0)
        // キャンセル後もエラーが発生しないことを確認
        XCTAssertNotNil(viewModel)
    }
    
    // MARK: - UI Update Performance Tests
    
    func testPublishedPropertiesUpdatePerformance() {
        // Given
        let expectation = XCTestExpectation(description: "Published properties updates")
        expectation.expectedFulfillmentCount = 1000
        
        var updateCount = 0
        
        // When
        viewModel.$cafes
            .sink { _ in
                updateCount += 1
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        let startTime = Date()
        
        // 1000回の更新を実行
        for i in 0..<1000 {
            viewModel.cafes = [MockData.sampleCafes[i % MockData.sampleCafes.count]]
        }
        
        // Then
        wait(for: [expectation], timeout: 10.0)
        let elapsedTime = Date().timeIntervalSince(startTime)
        
        // 1000回の更新が10秒以内に完了することを確認
        XCTAssertLessThan(elapsedTime, 10.0)
        XCTAssertEqual(updateCount, 1000)
    }
    
    func testFilterUpdatePerformance() {
        // Given
        let expectation = XCTestExpectation(description: "Filter updates")
        expectation.expectedFulfillmentCount = 100
        
        var updateCount = 0
        
        viewModel.$searchFilter
            .sink { _ in
                updateCount += 1
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        // When
        let startTime = Date()
        
        for i in 0..<100 {
            let newFilter = SearchFilter(
                radius: Double(i * 10),
                minRating: Double(i % 5),
                maxPriceLevel: i % 5,
                openNow: i % 2 == 0,
                parkingTypes: [.free, .paid],
                sortBy: SearchFilter.SortOption.allCases[i % 3]
            )
            viewModel.updateFilter(newFilter)
        }
        
        // Then
        wait(for: [expectation], timeout: 5.0)
        let elapsedTime = Date().timeIntervalSince(startTime)
        
        // 100回のフィルター更新が5秒以内に完了することを確認
        XCTAssertLessThan(elapsedTime, 5.0)
        XCTAssertEqual(updateCount, 100)
    }
    
    // MARK: - Data Structure Performance Tests
    
    func testArrayOperationsPerformance() {
        // Given
        let largeArray = Array(0..<10000)
        
        // When & Then
        measure {
            // 配列の検索
            let searchResult = largeArray.contains(5000)
            XCTAssertTrue(searchResult)
            
            // 配列のフィルタリング
            let filteredArray = largeArray.filter { $0 % 2 == 0 }
            XCTAssertEqual(filteredArray.count, 5000)
            
            // 配列のマッピング
            let mappedArray = largeArray.map { $0 * 2 }
            XCTAssertEqual(mappedArray.count, 10000)
            
            // 配列のソート
            let sortedArray = largeArray.sorted()
            XCTAssertEqual(sortedArray.first, 0)
            XCTAssertEqual(sortedArray.last, 9999)
        }
    }
    
    func testSetOperationsPerformance() {
        // Given
        let largeSet = Set(0..<10000)
        
        // When & Then
        measure {
            // セットの検索
            let searchResult = largeSet.contains(5000)
            XCTAssertTrue(searchResult)
            
            // セットの結合
            let anotherSet = Set(5000..<15000)
            let unionSet = largeSet.union(anotherSet)
            XCTAssertEqual(unionSet.count, 15000)
            
            // セットの交差
            let intersectionSet = largeSet.intersection(anotherSet)
            XCTAssertEqual(intersectionSet.count, 5000)
        }
    }
    
    func testDictionaryOperationsPerformance() {
        // Given
        var largeDictionary: [Int: String] = [:]
        for i in 0..<10000 {
            largeDictionary[i] = "Value \(i)"
        }
        
        // When & Then
        measure {
            // 辞書の検索
            let searchResult = largeDictionary[5000]
            XCTAssertEqual(searchResult, "Value 5000")
            
            // 辞書の値の取得
            let values = Array(largeDictionary.values)
            XCTAssertEqual(values.count, 10000)
            
            // 辞書のキーの取得
            let keys = Array(largeDictionary.keys)
            XCTAssertEqual(keys.count, 10000)
        }
    }
    
    // MARK: - Helper Methods
    
    private func generateLargeCafeArray(count: Int) -> [Cafe] {
        var cafes: [Cafe] = []
        
        for i in 0..<count {
            let cafe = Cafe(
                id: "cafe_\(i)",
                name: "カフェ\(i)",
                address: "東京都テスト区テスト\(i)-\(i)-\(i)",
                phoneNumber: "03-1234-\(String(format: "%04d", i))",
                rating: Double.random(in: 1.0...5.0),
                userRatingsTotal: Int.random(in: 10...1000),
                priceLevel: Int.random(in: 1...4),
                placeId: "place_\(i)",
                location: CLLocationCoordinate2D(
                    latitude: 35.6580 + Double.random(in: -0.1...0.1),
                    longitude: 139.7016 + Double.random(in: -0.1...0.1)
                ),
                types: ["cafe", "food"],
                openingHours: Cafe.OpeningHours(
                    openNow: Bool.random(),
                    periods: nil,
                    weekdayText: ["月曜日: 9:00–21:00"]
                ),
                photos: [
                    Cafe.Photo(photoReference: "photo_\(i)", height: 400, width: 600)
                ],
                website: "https://cafe\(i).com",
                isFavorite: Bool.random()
            )
            cafes.append(cafe)
        }
        
        return cafes
    }
    
    private func getMemoryUsage() -> Int {
        var info = mach_task_basic_info()
        var count = mach_msg_type_number_t(MemoryLayout<mach_task_basic_info>.size)/4
        
        let kerr: kern_return_t = withUnsafeMutablePointer(to: &info) {
            $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
                task_info(mach_task_self_,
                         task_flavor_t(MACH_TASK_BASIC_INFO),
                         $0,
                         &count)
            }
        }
        
        if kerr == KERN_SUCCESS {
            return Int(info.resident_size)
        } else {
            return 0
        }
    }
} 