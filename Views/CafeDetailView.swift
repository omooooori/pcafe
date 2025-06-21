import SwiftUI
import MapKit

struct CafeDetailView: View {
    let cafe: Cafe
    @ObservedObject var viewModel: CafeSearchViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var region: MKCoordinateRegion
    
    init(cafe: Cafe, viewModel: CafeSearchViewModel) {
        self.cafe = cafe
        self.viewModel = viewModel
        self._region = State(initialValue: MKCoordinateRegion(
            center: cafe.location,
            span: MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
        ))
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // ヘッダー部分
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(cafe.name)
                                    .font(.title)
                                    .fontWeight(.bold)
                                    .foregroundColor(.primary)
                                
                                Text(cafe.address)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            Button(action: {
                                viewModel.toggleFavorite(for: cafe)
                            }) {
                                Image(systemName: cafe.isFavorite ? "heart.fill" : "heart")
                                    .font(.title2)
                                    .foregroundColor(cafe.isFavorite ? .red : .gray)
                            }
                        }
                        
                        // 評価と価格
                        HStack(spacing: 20) {
                            if let rating = cafe.rating {
                                HStack(spacing: 4) {
                                    Image(systemName: "star.fill")
                                        .foregroundColor(.yellow)
                                    Text(String(format: "%.1f", rating))
                                        .fontWeight(.semibold)
                                    
                                    if let total = cafe.userRatingsTotal {
                                        Text("(\(total))")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                }
                            }
                            
                            if let priceLevel = cafe.priceLevel {
                                HStack(spacing: 2) {
                                    ForEach(0..<priceLevel, id: \.self) { _ in
                                        Image(systemName: "yensign.circle.fill")
                                            .foregroundColor(.green)
                                    }
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                    
                    // 距離情報
                    HStack {
                        Image(systemName: "location.fill")
                            .foregroundColor(.brown)
                        Text(viewModel.getDistance(to: cafe))
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal)
                    
                    // マップ
                    Map(coordinateRegion: .constant(region), annotationItems: [cafe]) { cafe in
                        MapAnnotation(coordinate: cafe.location) {
                            Image(systemName: "cup.and.saucer.fill")
                                .font(.title2)
                                .foregroundColor(.white)
                                .frame(width: 30, height: 30)
                                .background(Color.brown)
                                .clipShape(Circle())
                        }
                    }
                    .frame(height: 200)
                    .cornerRadius(12)
                    .padding(.horizontal)
                    
                    // アクションボタン
                    HStack(spacing: 15) {
                        Button(action: {
                            viewModel.getDirections(to: cafe)
                        }) {
                            HStack {
                                Image(systemName: "map")
                                Text("経路案内")
                            }
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(Color.brown)
                            .cornerRadius(8)
                        }
                        
                        Button(action: {
                            viewModel.shareCafe(cafe)
                        }) {
                            HStack {
                                Image(systemName: "square.and.arrow.up")
                                Text("共有")
                            }
                            .font(.headline)
                            .foregroundColor(.brown)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(Color.brown.opacity(0.1))
                            .cornerRadius(8)
                        }
                    }
                    .padding(.horizontal)
                    
                    // 詳細情報
                    VStack(alignment: .leading, spacing: 15) {
                        Text("詳細情報")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        if let phoneNumber = cafe.phoneNumber {
                            DetailRow(icon: "phone", title: "電話番号", value: phoneNumber)
                        }
                        
                        if let website = cafe.website {
                            DetailRow(icon: "globe", title: "ウェブサイト", value: website, isLink: true)
                        }
                        
                        DetailRow(icon: "clock", title: "営業時間", value: "詳細は店舗にお問い合わせください")
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical)
            }
            .navigationTitle("詳細")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("閉じる") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct DetailRow: View {
    let icon: String
    let title: String
    let value: String
    var isLink: Bool = false
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(.brown)
                .frame(width: 20)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                if isLink {
                    Link(value, destination: URL(string: value) ?? URL(string: "https://example.com")!)
                        .font(.subheadline)
                        .foregroundColor(.blue)
                } else {
                    Text(value)
                        .font(.subheadline)
                        .foregroundColor(.primary)
                }
            }
            
            Spacer()
        }
    }
}

#Preview {
    let sampleCafe = Cafe(
        id: "1",
        name: "サンプルカフェ",
        address: "東京都渋谷区1-1-1",
        phoneNumber: "03-1234-5678",
        rating: 4.5,
        userRatingsTotal: 100,
        priceLevel: 2,
        placeId: "sample_place_id",
        location: CLLocationCoordinate2D(latitude: 35.6762, longitude: 139.6503),
        types: ["cafe", "food"],
        openingHours: nil,
        photos: nil,
        website: "https://example.com",
        isFavorite: false
    )
    
    CafeDetailView(
        cafe: sampleCafe,
        viewModel: CafeSearchViewModel(
            locationService: LocationService(),
            placesService: GooglePlacesService(apiKey: "test")
        )
    )
} 