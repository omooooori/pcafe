import SwiftUI

struct FilterView: View {
    @Binding var filter: SearchFilter
    let onApply: (SearchFilter) -> Void
    @Environment(\.dismiss) private var dismiss
    
    @State private var tempFilter: SearchFilter
    
    init(filter: Binding<SearchFilter>, onApply: @escaping (SearchFilter) -> Void) {
        self._filter = filter
        self.onApply = onApply
        self._tempFilter = State(initialValue: filter.wrappedValue)
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section("検索範囲") {
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Text("半径")
                            Spacer()
                            Text("\(Int(tempFilter.radius))m")
                                .foregroundColor(.secondary)
                        }
                        
                        Slider(
                            value: $tempFilter.radius,
                            in: 500...5000,
                            step: 100
                        )
                    }
                }
                
                Section("評価") {
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Text("最低評価")
                            Spacer()
                            Text(String(format: "%.1f", tempFilter.minRating))
                                .foregroundColor(.secondary)
                        }
                        
                        Slider(
                            value: $tempFilter.minRating,
                            in: 0...5,
                            step: 0.5
                        )
                    }
                }
                
                Section("価格") {
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Text("最高価格レベル")
                            Spacer()
                            Text("\(tempFilter.maxPriceLevel)")
                                .foregroundColor(.secondary)
                        }
                        
                        Slider(
                            value: Binding(
                                get: { Double(tempFilter.maxPriceLevel) },
                                set: { tempFilter.maxPriceLevel = Int($0) }
                            ),
                            in: 1...4,
                            step: 1
                        )
                        
                        HStack {
                            ForEach(1...4, id: \.self) { level in
                                VStack(spacing: 4) {
                                    HStack(spacing: 2) {
                                        ForEach(0..<level, id: \.self) { _ in
                                            Image(systemName: "yensign.circle.fill")
                                                .font(.caption)
                                                .foregroundColor(.green)
                                        }
                                    }
                                    Text("\(level)")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                    }
                }
                
                Section("営業時間") {
                    Toggle("営業中の店舗のみ", isOn: $tempFilter.openNow)
                }
                
                Section("駐車場の種類") {
                    ForEach(SearchFilter.ParkingType.allCases, id: \.self) { type in
                        Toggle(type.displayName, isOn: Binding(
                            get: { tempFilter.parkingTypes.contains(type) },
                            set: { isOn in
                                if isOn {
                                    tempFilter.parkingTypes.insert(type)
                                } else {
                                    tempFilter.parkingTypes.remove(type)
                                }
                            }
                        ))
                    }
                }
                
                Section("並び順") {
                    Picker("並び順", selection: $tempFilter.sortBy) {
                        ForEach(SearchFilter.SortOption.allCases, id: \.self) { option in
                            Text(option.displayName).tag(option)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
            }
            .navigationTitle("フィルター")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("キャンセル") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("適用") {
                        filter = tempFilter
                        onApply(tempFilter)
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    FilterView(
        filter: .constant(SearchFilter())
    ) { _ in }
} 