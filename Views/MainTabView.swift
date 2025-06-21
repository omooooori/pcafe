import SwiftUI

struct MainTabView: View {
    @StateObject private var locationService = LocationService()
    @StateObject private var placesService = GooglePlacesService(apiKey: "YOUR_API_KEY")
    @StateObject private var viewModel: CafeSearchViewModel
    
    init() {
        let locationService = LocationService()
        let placesService = GooglePlacesService(apiKey: "YOUR_API_KEY")
        self._viewModel = StateObject(wrappedValue: CafeSearchViewModel(
            locationService: locationService,
            placesService: placesService
        ))
    }
    
    var body: some View {
        TabView {
            MapView(viewModel: viewModel)
                .tabItem {
                    Image(systemName: "map")
                    Text("マップ")
                }
            
            CafeListView(viewModel: viewModel)
                .tabItem {
                    Image(systemName: "list.bullet")
                    Text("リスト")
                }
            
            FavoritesView()
                .tabItem {
                    Image(systemName: "heart")
                    Text("お気に入り")
                }
            
            SettingsView()
                .tabItem {
                    Image(systemName: "gear")
                    Text("設定")
                }
        }
        .accentColor(.brown)
        .onAppear {
            viewModel.requestLocationPermission()
        }
    }
}

#Preview {
    MainTabView()
} 