import Foundation
import CoreLocation
import Combine

// MARK: - Mock Location Service
class MockLocationService: ObservableObject {
    @Published var currentLocation: CLLocation?
    @Published var authorizationStatus: CLAuthorizationStatus = .authorizedWhenInUse
    @Published var locationError: LocationService.LocationError?
    
    init() {
        // デフォルトで東京の位置を設定
        currentLocation = MockData.tokyoLocation
    }
    
    func requestLocationPermission() {
        // モックでは即座に許可される
        authorizationStatus = .authorizedWhenInUse
        currentLocation = MockData.tokyoLocation
    }
    
    func startLocationUpdates() {
        // モックでは何もしない
    }
    
    func stopLocationUpdates() {
        // モックでは何もしない
    }
    
    func getCurrentLocation() -> AnyPublisher<CLLocation, LocationService.LocationError> {
        guard let location = currentLocation else {
            return Fail(error: LocationService.LocationError.unavailable)
                .eraseToAnyPublisher()
        }
        return Just(location)
            .setFailureType(to: LocationService.LocationError.self)
            .eraseToAnyPublisher()
    }
    
    // テスト用の位置変更メソッド
    func setLocation(_ location: CLLocation) {
        currentLocation = location
    }
}

// MARK: - Mock Google Places Service
class MockGooglePlacesService: ObservableObject {
    @Published var isLoading = false
    @Published var error: GooglePlacesService.PlacesError?
    
    private var delay: TimeInterval = 1.0 // モック用の遅延時間
    
    init(delay: TimeInterval = 1.0) {
        self.delay = delay
    }
    
    func searchCafesWithParking(
        near location: CLLocation,
        radius: Double = 1000,
        filter: SearchFilter
    ) -> AnyPublisher<[Cafe], GooglePlacesService.PlacesError> {
        isLoading = true
        error = nil
        
        return Future { [weak self] promise in
            DispatchQueue.main.asyncAfter(deadline: .now() + (self?.delay ?? 1.0)) {
                self?.isLoading = false
                
                // フィルターに基づいてモックデータをフィルタリング
                var filteredCafes = MockData.sampleCafes
                
                // 評価フィルター
                if filter.minRating > 0 {
                    filteredCafes = filteredCafes.filter { cafe in
                        guard let rating = cafe.rating else { return false }
                        return rating >= filter.minRating
                    }
                }
                
                // 価格フィルター
                filteredCafes = filteredCafes.filter { cafe in
                    guard let priceLevel = cafe.priceLevel else { return true }
                    return priceLevel <= filter.maxPriceLevel
                }
                
                // 営業中フィルター
                if filter.openNow {
                    filteredCafes = filteredCafes.filter { cafe in
                        return cafe.openingHours?.openNow == true
                    }
                }
                
                // 距離に基づいてソート（実際の距離計算は簡略化）
                filteredCafes.sort { cafe1, cafe2 in
                    let distance1 = abs(cafe1.location.latitude - location.coordinate.latitude) +
                                   abs(cafe1.location.longitude - location.coordinate.longitude)
                    let distance2 = abs(cafe2.location.latitude - location.coordinate.latitude) +
                                   abs(cafe2.location.longitude - location.coordinate.longitude)
                    return distance1 < distance2
                }
                
                promise(.success(filteredCafes))
            }
        }
        .eraseToAnyPublisher()
    }
    
    func getPlaceDetails(placeId: String) -> AnyPublisher<Cafe, GooglePlacesService.PlacesError> {
        return Future { [weak self] promise in
            DispatchQueue.main.asyncAfter(deadline: .now() + (self?.delay ?? 0.5)) {
                if let cafe = MockData.sampleCafes.first(where: { $0.placeId == placeId }) {
                    promise(.success(cafe))
                } else {
                    promise(.failure(.invalidResponse))
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    // エラーをシミュレートするメソッド
    func simulateError(_ error: GooglePlacesService.PlacesError) {
        self.error = error
    }
    
    // 遅延時間を設定するメソッド
    func setDelay(_ delay: TimeInterval) {
        self.delay = delay
    }
}

// MARK: - Mock ViewModel
class MockCafeSearchViewModel: ObservableObject {
    @Published var cafes: [Cafe] = []
    @Published var selectedCafe: Cafe?
    @Published var isLoading = false
    @Published var error: Error?
    @Published var searchFilter = SearchFilter()
    @Published var currentLocation: CLLocation?
    
    private let mockLocationService: MockLocationService
    private let mockPlacesService: MockGooglePlacesService
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        self.mockLocationService = MockLocationService()
        self.mockPlacesService = MockGooglePlacesService()
        
        setupBindings()
    }
    
    private func setupBindings() {
        mockLocationService.$currentLocation
            .assign(to: \.currentLocation, on: self)
            .store(in: &cancellables)
        
        mockLocationService.$locationError
            .compactMap { $0 }
            .assign(to: \.error, on: self)
            .store(in: &cancellables)
        
        mockPlacesService.$error
            .compactMap { $0 }
            .assign(to: \.error, on: self)
            .store(in: &cancellables)
    }
    
    func requestLocationPermission() {
        mockLocationService.requestLocationPermission()
    }
    
    func searchCafes() {
        guard let location = currentLocation else {
            error = LocationService.LocationError.unavailable
            return
        }
        
        isLoading = true
        error = nil
        
        mockPlacesService.searchCafesWithParking(
            near: location,
            radius: searchFilter.radius,
            filter: searchFilter
        )
        .receive(on: DispatchQueue.main)
        .sink(
            receiveCompletion: { [weak self] completion in
                self?.isLoading = false
                if case .failure(let error) = completion {
                    self?.error = error
                }
            },
            receiveValue: { [weak self] cafes in
                self?.cafes = cafes
            }
        )
        .store(in: &cancellables)
    }
    
    func selectCafe(_ cafe: Cafe) {
        selectedCafe = cafe
    }
    
    func updateFilter(_ filter: SearchFilter) {
        searchFilter = filter
        if !cafes.isEmpty {
            searchCafes()
        }
    }
    
    func toggleFavorite(for cafe: Cafe) {
        if let index = cafes.firstIndex(where: { $0.id == cafe.id }) {
            // お気に入り状態を切り替える（実際の実装ではCoreDataを使用）
            print("Toggle favorite for: \(cafe.name)")
        }
    }
    
    func shareCafe(_ cafe: Cafe) {
        print("Share cafe: \(cafe.name)")
    }
    
    func getDirections(to cafe: Cafe) {
        print("Get directions to: \(cafe.name)")
    }
    
    func getDistance(to cafe: Cafe) -> String {
        guard let location = currentLocation else { return "距離不明" }
        
        let distance = location.distance(from: CLLocation(latitude: cafe.location.latitude, longitude: cafe.location.longitude))
        
        if distance < 1000 {
            return "\(Int(distance))m"
        } else {
            return String(format: "%.1fkm", distance / 1000)
        }
    }
    
    // テスト用のメソッド
    func loadMockData() {
        cafes = MockData.sampleCafes
    }
    
    func simulateError(_ error: Error) {
        self.error = error
    }
} 