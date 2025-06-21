import Foundation
import CoreLocation
import Combine

/**
 カフェ検索機能を管理するビューモデル
 
 このクラスは、カフェ検索のビジネスロジックを担当し、SwiftUIビューとデータソースの間の橋渡しをします。
 Combineフレームワークを使用してリアクティブなデータバインディングを実現し、
 位置情報サービスとGoogle Places APIサービスを統合します。
 
 ## 主な機能
 - 現在位置の取得と監視
 - カフェ検索の実行
 - 検索結果のフィルタリングとソート
 - エラーハンドリング
 - お気に入り機能（予定）
 - 共有機能（予定）
 
 ## 依存関係
 - `LocationService`: 位置情報の取得
 - `GooglePlacesService`: カフェ情報の取得
 - `SearchFilter`: 検索条件の管理
 
 ## 使用例
 ```swift
 let viewModel = CafeSearchViewModel(
     locationService: LocationService(),
     placesService: GooglePlacesService(apiKey: "your-api-key")
 )
 viewModel.requestLocationPermission()
 viewModel.searchCafes()
 ```
 
 - Author: Cafe Parking Finder Team
 - Version: 1.0.0
 - Since: 2024
 */
class CafeSearchViewModel: ObservableObject {
    // MARK: - Published Properties
    
    /// 検索結果のカフェ配列
    @Published var cafes: [Cafe] = []
    
    /// 現在選択されているカフェ
    @Published var selectedCafe: Cafe?
    
    /// 検索中のローディング状態
    @Published var isLoading = false
    
    /// エラー情報
    @Published var error: Error?
    
    /// 現在の検索フィルター設定
    @Published var searchFilter = SearchFilter()
    
    /// 現在の位置情報
    @Published var currentLocation: CLLocation?
    
    // MARK: - Private Properties
    
    private let locationService: LocationService
    private let placesService: GooglePlacesService
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    
    /**
     ビューモデルの初期化
     
     - Parameters:
        - locationService: 位置情報サービス
        - placesService: Google Places APIサービス
     */
    init(locationService: LocationService, placesService: GooglePlacesService) {
        self.locationService = locationService
        self.placesService = placesService
        
        setupBindings()
    }
    
    // MARK: - Private Methods
    
    /**
     データバインディングの設定
     
     位置情報サービスとPlaces APIサービスの状態変化を監視し、
     ビューモデルの状態を更新します。
     */
    private func setupBindings() {
        // 位置情報の監視
        locationService.$currentLocation
            .assign(to: \.currentLocation, on: self)
            .store(in: &cancellables)
        
        // エラーの監視
        locationService.$locationError
            .compactMap { $0 }
            .assign(to: \.error, on: self)
            .store(in: &cancellables)
        
        placesService.$error
            .compactMap { $0 }
            .assign(to: \.error, on: self)
            .store(in: &cancellables)
    }
    
    // MARK: - Public Methods
    
    /**
     位置情報の許可を要求
     
     ユーザーに位置情報の使用許可を求め、許可された場合は現在位置を取得します。
     */
    func requestLocationPermission() {
        locationService.requestLocationPermission()
    }
    
    /**
     現在位置周辺のカフェを検索
     
     現在位置を基に、設定されたフィルター条件でカフェを検索します。
     位置情報が利用できない場合はエラーを設定します。
     */
    func searchCafes() {
        guard let location = currentLocation else {
            error = LocationService.LocationError.unavailable
            return
        }
        
        isLoading = true
        error = nil
        
        placesService.searchCafesWithParking(
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
                self?.cafes = self?.applySorting(to: cafes) ?? []
            }
        )
        .store(in: &cancellables)
    }
    
    /**
     指定された位置周辺のカフェを検索
     
     - Parameter location: 検索の中心となる位置
     */
    func searchCafesAtLocation(_ location: CLLocation) {
        isLoading = true
        error = nil
        
        placesService.searchCafesWithParking(
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
                self?.cafes = self?.applySorting(to: cafes) ?? []
            }
        )
        .store(in: &cancellables)
    }
    
    /**
     カフェを選択
     
     - Parameter cafe: 選択するカフェ
     */
    func selectCafe(_ cafe: Cafe) {
        selectedCafe = cafe
    }
    
    /**
     検索フィルターを更新
     
     フィルターが変更された場合、既存の検索結果がある場合は再検索を実行します。
     
     - Parameter filter: 新しい検索フィルター
     */
    func updateFilter(_ filter: SearchFilter) {
        searchFilter = filter
        if !cafes.isEmpty {
            searchCafes()
        }
    }
    
    /**
     カフェのお気に入り状態を切り替え
     
     **注意**: この機能は現在実装中です。CoreDataを使用した永続化が予定されています。
     
     - Parameter cafe: お気に入りを切り替えるカフェ
     */
    func toggleFavorite(for cafe: Cafe) {
        // TODO: CoreDataを使用してお気に入り機能を実装
        if let index = cafes.firstIndex(where: { $0.id == cafe.id }) {
            // お気に入り状態を切り替える処理
        }
    }
    
    /**
     カフェ情報を共有
     
     **注意**: この機能は現在実装中です。
     
     - Parameter cafe: 共有するカフェ
     */
    func shareCafe(_ cafe: Cafe) {
        // TODO: 共有機能を実装
        let shareText = """
        \(cafe.name)
        住所: \(cafe.address)
        評価: \(cafe.rating?.description ?? "なし")
        """
        
        // UIActivityViewControllerを使用して共有
    }
    
    /**
     カフェへの経路案内を開始
     
     Apple Mapsを起動して、指定されたカフェへの経路案内を開始します。
     
     - Parameter cafe: 経路案内の目的地となるカフェ
     */
    func getDirections(to cafe: Cafe) {
        // TODO: Apple MapsまたはGoogle Mapsで経路案内を開く
        let urlString = "http://maps.apple.com/?daddr=\(cafe.location.latitude),\(cafe.location.longitude)"
        if let url = URL(string: urlString) {
            UIApplication.shared.open(url)
        }
    }
    
    // MARK: - Private Helper Methods
    
    /**
     検索結果にソートを適用
     
     - Parameter cafes: ソート対象のカフェ配列
     - Returns: ソート済みのカフェ配列
     */
    private func applySorting(to cafes: [Cafe]) -> [Cafe] {
        switch searchFilter.sortBy {
        case .distance:
            return cafes.sorted { cafe1, cafe2 in
                guard let location = currentLocation else { return false }
                let distance1 = location.distance(from: CLLocation(latitude: cafe1.location.latitude, longitude: cafe1.location.longitude))
                let distance2 = location.distance(from: CLLocation(latitude: cafe2.location.latitude, longitude: cafe2.location.longitude))
                return distance1 < distance2
            }
        case .rating:
            return cafes.sorted { cafe1, cafe2 in
                let rating1 = cafe1.rating ?? 0
                let rating2 = cafe2.rating ?? 0
                return rating1 > rating2
            }
        case .price:
            return cafes.sorted { cafe1, cafe2 in
                let price1 = cafe1.priceLevel ?? 4
                let price2 = cafe2.priceLevel ?? 4
                return price1 < price2
            }
        }
    }
    
    /**
     カフェまでの距離を取得
     
     - Parameter cafe: 距離を計算するカフェ
     - Returns: フォーマットされた距離文字列（例: "500m"、"1.2km"）
     */
    func getDistance(to cafe: Cafe) -> String {
        guard let location = currentLocation else { return "距離不明" }
        
        let distance = location.distance(from: CLLocation(latitude: cafe.location.latitude, longitude: cafe.location.longitude))
        
        if distance < 1000 {
            return "\(Int(distance))m"
        } else {
            return String(format: "%.1fkm", distance / 1000)
        }
    }
} 