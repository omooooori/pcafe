import SwiftUI

struct CafeListView: View {
    @EnvironmentObject var searchViewModel: CafeSearchViewModel
    
    var body: some View {
        NavigationView {
            Group {
                if searchViewModel.isLoading {
                    ProgressView("カフェを検索中...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if let errorMessage = searchViewModel.errorMessage {
                    VStack {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.largeTitle)
                            .foregroundColor(.orange)
                        Text(errorMessage)
                            .multilineTextAlignment(.center)
                            .padding()
                        Button("再試行") {
                            searchViewModel.refreshSearch()
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if searchViewModel.cafes.isEmpty {
                    VStack {
                        Image(systemName: "cup.and.saucer")
                            .font(.largeTitle)
                            .foregroundColor(.gray)
                        Text("カフェが見つかりませんでした")
                            .foregroundColor(.gray)
                        Text("フィルター設定を変更してみてください")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List(searchViewModel.cafes) { cafe in
                        NavigationLink(destination: CafeDetailView(cafe: cafe)) {
                            CafeRowView(cafe: cafe)
                        }
                    }
                }
            }
            .navigationTitle("カフェ検索")
            .refreshable {
                searchViewModel.refreshSearch()
            }
        }
    }
}

struct CafeRowView: View {
    let cafe: Cafe
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(cafe.name)
                    .font(.headline)
                Spacer()
                if let rating = cafe.rating {
                    HStack(spacing: 4) {
                        Image(systemName: "star.fill")
                            .foregroundColor(.yellow)
                        Text(String(format: "%.1f", rating))
                            .font(.caption)
                    }
                }
            }
            
            Text(cafe.address)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            HStack {
                if let priceLevel = cafe.priceLevel {
                    Text(String(repeating: "¥", count: priceLevel))
                        .font(.caption)
                        .foregroundColor(.green)
                }
                
                Spacer()
                
                if cafe.hasParking {
                    HStack(spacing: 4) {
                        Image(systemName: "car.fill")
                            .foregroundColor(.blue)
                        Text("駐車場あり")
                            .font(.caption)
                    }
                }
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    CafeListView()
        .environmentObject(CafeSearchViewModel())
} 