import SwiftUI

struct CafeListView: View {
    @ObservedObject var viewModel: CafeSearchViewModel
    @State private var showingFilter = false
    @State private var searchText = ""
    
    var filteredCafes: [Cafe] {
        if searchText.isEmpty {
            return viewModel.cafes
        } else {
            return viewModel.cafes.filter { cafe in
                cafe.name.localizedCaseInsensitiveContains(searchText) ||
                cafe.address.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    var body: some View {
        NavigationView {
            VStack {
                if viewModel.cafes.isEmpty && !viewModel.isLoading {
                    EmptyStateView {
                        viewModel.searchCafes()
                    }
                } else {
                    List(filteredCafes) { cafe in
                        CafeRowView(cafe: cafe, viewModel: viewModel)
                            .onTapGesture {
                                viewModel.selectCafe(cafe)
                            }
                    }
                    .refreshable {
                        viewModel.searchCafes()
                    }
                }
            }
            .searchable(text: $searchText, prompt: "カフェ名や住所で検索")
            .navigationTitle("カフェ一覧")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingFilter = true
                    }) {
                        Image(systemName: "slider.horizontal.3")
                    }
                }
                
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        viewModel.searchCafes()
                    }) {
                        Image(systemName: "magnifyingglass")
                    }
                }
            }
            .sheet(isPresented: $showingFilter) {
                FilterView(filter: $viewModel.searchFilter) { filter in
                    viewModel.updateFilter(filter)
                }
            }
            .sheet(item: $viewModel.selectedCafe) { cafe in
                CafeDetailView(cafe: cafe, viewModel: viewModel)
            }
            .overlay(
                Group {
                    if viewModel.isLoading {
                        LoadingView()
                    }
                }
            )
            .alert("エラー", isPresented: .constant(viewModel.error != nil)) {
                Button("OK") {
                    viewModel.error = nil
                }
            } message: {
                if let error = viewModel.error {
                    Text(error.localizedDescription)
                }
            }
        }
    }
}

struct CafeRowView: View {
    let cafe: Cafe
    @ObservedObject var viewModel: CafeSearchViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(cafe.name)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text(cafe.address)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text(viewModel.getDistance(to: cafe))
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    if let rating = cafe.rating {
                        HStack(spacing: 2) {
                            Image(systemName: "star.fill")
                                .font(.caption)
                                .foregroundColor(.yellow)
                            Text(String(format: "%.1f", rating))
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
            
            HStack {
                if let priceLevel = cafe.priceLevel {
                    HStack(spacing: 2) {
                        ForEach(0..<priceLevel, id: \.self) { _ in
                            Image(systemName: "yensign.circle.fill")
                                .font(.caption)
                                .foregroundColor(.green)
                        }
                    }
                }
                
                Spacer()
                
                Button(action: {
                    viewModel.toggleFavorite(for: cafe)
                }) {
                    Image(systemName: cafe.isFavorite ? "heart.fill" : "heart")
                        .foregroundColor(cafe.isFavorite ? .red : .gray)
                }
            }
        }
        .padding(.vertical, 4)
    }
}

struct EmptyStateView: View {
    let onSearch: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "cup.and.saucer")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            VStack(spacing: 8) {
                Text("カフェが見つかりません")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                Text("現在地周辺のカフェを検索してみましょう")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            Button(action: onSearch) {
                Text("検索する")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding(.horizontal, 30)
                    .padding(.vertical, 12)
                    .background(Color.brown)
                    .cornerRadius(25)
            }
        }
        .padding()
    }
}

#Preview {
    CafeListView(viewModel: CafeSearchViewModel(
        locationService: LocationService(),
        placesService: GooglePlacesService(apiKey: "test")
    ))
} 