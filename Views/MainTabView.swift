import SwiftUI

struct MainTabView: View {
    @StateObject private var searchViewModel = CafeSearchViewModel()
    
    var body: some View {
        TabView {
            CafeListView()
                .environmentObject(searchViewModel)
                .tabItem {
                    Image(systemName: "cup.and.saucer.fill")
                    Text("カフェ検索")
                }
            
            FilterView()
                .environmentObject(searchViewModel)
                .tabItem {
                    Image(systemName: "slider.horizontal.3")
                    Text("フィルター")
                }
        }
        .onAppear {
            searchViewModel.requestLocationPermission()
        }
    }
}

#Preview {
    MainTabView()
} 