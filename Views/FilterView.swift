import SwiftUI

struct FilterView: View {
    @EnvironmentObject var searchViewModel: CafeSearchViewModel
    
    var body: some View {
        NavigationView {
            Form {
                Section("検索範囲") {
                    VStack(alignment: .leading) {
                        Text("検索半径: \(searchViewModel.searchFilter.radius)m")
                            .font(.headline)
                        
                        Slider(
                            value: Binding(
                                get: { Double(searchViewModel.searchFilter.radius) },
                                set: { searchViewModel.searchFilter.radius = Int($0) }
                            ),
                            in: 500...5000,
                            step: 100
                        )
                        
                        HStack {
                            Text("500m")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Spacer()
                            Text("5km")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                Section("評価") {
                    VStack(alignment: .leading) {
                        HStack {
                            Text("最小評価")
                            Spacer()
                            if let minRating = searchViewModel.searchFilter.minRating {
                                Text(String(format: "%.1f", minRating))
                                    .foregroundColor(.blue)
                            } else {
                                Text("なし")
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        Slider(
                            value: Binding(
                                get: { searchViewModel.searchFilter.minRating ?? 0.0 },
                                set: { searchViewModel.searchFilter.minRating = $0 > 0 ? $0 : nil }
                            ),
                            in: 0...5,
                            step: 0.5
                        )
                        
                        HStack {
                            Text("0.0")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Spacer()
                            Text("5.0")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                Section("価格") {
                    VStack(alignment: .leading) {
                        HStack {
                            Text("最大価格レベル")
                            Spacer()
                            if let maxPrice = searchViewModel.searchFilter.maxPriceLevel {
                                Text(String(repeating: "¥", count: maxPrice))
                                    .foregroundColor(.green)
                            } else {
                                Text("制限なし")
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        Slider(
                            value: Binding(
                                get: { Double(searchViewModel.searchFilter.maxPriceLevel ?? 4) },
                                set: { searchViewModel.searchFilter.maxPriceLevel = $0 < 4 ? Int($0) : nil }
                            ),
                            in: 1...4,
                            step: 1
                        )
                        
                        HStack {
                            Text("¥")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Spacer()
                            Text("¥¥¥¥")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                Section("その他") {
                    Toggle("駐車場必須", isOn: $searchViewModel.searchFilter.requiresParking)
                }
                
                Section("並び順") {
                    Picker("並び順", selection: $searchViewModel.searchFilter.sortBy) {
                        Text("評価順").tag(SearchFilter.SortBy.rating)
                        Text("距離順").tag(SearchFilter.SortBy.distance)
                        Text("名前順").tag(SearchFilter.SortBy.name)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
                
                Section {
                    Button("フィルターをリセット") {
                        searchViewModel.searchFilter = SearchFilter()
                    }
                    .foregroundColor(.red)
                }
            }
            .navigationTitle("フィルター")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    FilterView()
        .environmentObject(CafeSearchViewModel())
} 