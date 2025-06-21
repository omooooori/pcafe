import SwiftUI
import MapKit

struct CafeDetailView: View {
    let cafe: Cafe
    @EnvironmentObject var searchViewModel: CafeSearchViewModel
    @State private var cafeDetails: CafeDetails?
    @State private var isLoadingDetails = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // ヘッダー
                VStack(alignment: .leading, spacing: 8) {
                    Text(cafe.name)
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text(cafe.address)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    HStack {
                        if let rating = cafe.rating {
                            HStack(spacing: 4) {
                                Image(systemName: "star.fill")
                                    .foregroundColor(.yellow)
                                Text(String(format: "%.1f", rating))
                                if let totalRatings = cafe.userRatingsTotal {
                                    Text("(\(totalRatings)件)")
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                        
                        Spacer()
                        
                        if let priceLevel = cafe.priceLevel {
                            Text(String(repeating: "¥", count: priceLevel))
                                .font(.headline)
                                .foregroundColor(.green)
                        }
                    }
                }
                .padding(.horizontal)
                
                // 駐車場情報
                if cafe.hasParking {
                    HStack {
                        Image(systemName: "car.fill")
                            .foregroundColor(.blue)
                        Text("駐車場あり")
                            .fontWeight(.medium)
                        Spacer()
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(8)
                    .padding(.horizontal)
                }
                
                // 営業時間
                if let openingHours = cafe.openingHours {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("営業時間")
                            .font(.headline)
                        
                        if let openNow = openingHours.open_now {
                            HStack {
                                Image(systemName: openNow ? "checkmark.circle.fill" : "xmark.circle.fill")
                                    .foregroundColor(openNow ? .green : .red)
                                Text(openNow ? "営業中" : "閉店中")
                                    .fontWeight(.medium)
                            }
                        }
                        
                        if let weekdayText = openingHours.weekday_text {
                            ForEach(weekdayText, id: \.self) { day in
                                Text(day)
                                    .font(.subheadline)
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                
                // 詳細情報
                if let details = cafeDetails {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("詳細情報")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        if let website = details.website {
                            Link(destination: URL(string: website)!) {
                                HStack {
                                    Image(systemName: "globe")
                                    Text("ウェブサイト")
                                    Spacer()
                                    Image(systemName: "arrow.up.right")
                                }
                                .foregroundColor(.blue)
                            }
                            .padding(.horizontal)
                        }
                        
                        if let phone = details.formatted_phone_number {
                            HStack {
                                Image(systemName: "phone")
                                Text(phone)
                                Spacer()
                            }
                            .padding(.horizontal)
                        }
                    }
                }
                
                // 地図
                Map(coordinateRegion: .constant(MKCoordinateRegion(
                    center: CLLocationCoordinate2D(
                        latitude: cafe.geometry.location.lat,
                        longitude: cafe.geometry.location.lng
                    ),
                    span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                )), annotationItems: [cafe]) { cafe in
                    MapMarker(coordinate: CLLocationCoordinate2D(
                        latitude: cafe.geometry.location.lat,
                        longitude: cafe.geometry.location.lng
                    ))
                }
                .frame(height: 200)
                .cornerRadius(12)
                .padding(.horizontal)
            }
        }
        .navigationTitle("カフェ詳細")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            loadCafeDetails()
        }
    }
    
    private func loadCafeDetails() {
        isLoadingDetails = true
        
        Task {
            cafeDetails = await searchViewModel.getCafeDetails(for: cafe)
            isLoadingDetails = false
        }
    }
}

#Preview {
    NavigationView {
        CafeDetailView(cafe: Cafe(
            id: "test",
            name: "テストカフェ",
            address: "東京都渋谷区",
            rating: 4.5,
            userRatingsTotal: 100,
            priceLevel: 2,
            types: ["cafe"],
            geometry: Cafe.Geometry(location: Cafe.Location(lat: 35.6581, lng: 139.7016)),
            photos: nil,
            openingHours: nil,
            hasParking: true
        ))
        .environmentObject(CafeSearchViewModel())
    }
} 