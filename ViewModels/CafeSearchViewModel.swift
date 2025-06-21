import Foundation
import CoreLocation
import Combine

@MainActor
class CafeSearchViewModel: ObservableObject {
    @Published var cafes: [Cafe] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var searchFilter = SearchFilter()
    
    private let placesService = GooglePlacesService()
    private let locationService = LocationService()
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        setupLocationService()
    }
    
    private func setupLocationService() {
        locationService.$currentLocation
            .compactMap { $0 }
            .sink { [weak self] location in
                Task {
                    await self?.searchCafes(near: location)
                }
            }
            .store(in: &cancellables)
        
        locationService.$errorMessage
            .assign(to: \.errorMessage, on: self)
            .store(in: &cancellables)
    }
    
    func requestLocationPermission() {
        locationService.requestLocationPermission()
    }
    
    func searchCafes(near location: CLLocation) async {
        isLoading = true
        errorMessage = nil
        
        do {
            let searchRadius = searchFilter.radius
            let foundCafes = try await placesService.searchCafes(near: location, radius: searchRadius)
            
            // フィルターを適用
            cafes = foundCafes.filter { cafe in
                var shouldInclude = true
                
                // 最小評価フィルター
                if let minRating = searchFilter.minRating,
                   let cafeRating = cafe.rating,
                   cafeRating < minRating {
                    shouldInclude = false
                }
                
                // 価格レベルフィルター
                if let maxPriceLevel = searchFilter.maxPriceLevel,
                   let cafePriceLevel = cafe.priceLevel,
                   cafePriceLevel > maxPriceLevel {
                    shouldInclude = false
                }
                
                // 駐車場フィルター
                if searchFilter.requiresParking && !cafe.hasParking {
                    shouldInclude = false
                }
                
                return shouldInclude
            }
            
            // ソート
            cafes.sort { cafe1, cafe2 in
                switch searchFilter.sortBy {
                case .rating:
                    return (cafe1.rating ?? 0) > (cafe2.rating ?? 0)
                case .distance:
                    let distance1 = location.distance(from: CLLocation(latitude: cafe1.geometry.location.lat, longitude: cafe1.geometry.location.lng))
                    let distance2 = location.distance(from: CLLocation(latitude: cafe2.geometry.location.lat, longitude: cafe2.geometry.location.lng))
                    return distance1 < distance2
                case .name:
                    return cafe1.name < cafe2.name
                }
            }
            
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    func refreshSearch() {
        guard let location = locationService.currentLocation else {
            errorMessage = "位置情報が取得できません"
            return
        }
        
        Task {
            await searchCafes(near: location)
        }
    }
    
    func getCafeDetails(for cafe: Cafe) async -> CafeDetails? {
        do {
            return try await placesService.getPlaceDetails(placeId: cafe.id)
        } catch {
            errorMessage = error.localizedDescription
            return nil
        }
    }
} 