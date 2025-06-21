import SwiftUI
import MapKit

struct MapView: View {
    @ObservedObject var viewModel: CafeSearchViewModel
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 35.6762, longitude: 139.6503), // 東京
        span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
    )
    @State private var selectedLocation: CLLocationCoordinate2D?
    @State private var showingFilter = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Map(coordinateRegion: $region, annotationItems: viewModel.cafes) { cafe in
                    MapAnnotation(coordinate: cafe.location) {
                        CafeAnnotationView(cafe: cafe) {
                            viewModel.selectCafe(cafe)
                        }
                    }
                }
                .ignoresSafeArea(edges: .bottom)
                .onTapGesture { location in
                    // マップの長押しで地点選択
                }
                .onLongPressGesture {
                    // 長押しで地点選択
                }
                
                VStack {
                    Spacer()
                    
                    HStack {
                        Spacer()
                        
                        VStack(spacing: 10) {
                            Button(action: {
                                viewModel.searchCafes()
                            }) {
                                Image(systemName: "magnifyingglass")
                                    .font(.title2)
                                    .foregroundColor(.white)
                                    .frame(width: 50, height: 50)
                                    .background(Color.brown)
                                    .clipShape(Circle())
                                    .shadow(radius: 3)
                            }
                            
                            Button(action: {
                                showingFilter = true
                            }) {
                                Image(systemName: "slider.horizontal.3")
                                    .font(.title2)
                                    .foregroundColor(.white)
                                    .frame(width: 50, height: 50)
                                    .background(Color.brown)
                                    .clipShape(Circle())
                                    .shadow(radius: 3)
                            }
                        }
                        .padding(.trailing, 20)
                        .padding(.bottom, 100)
                    }
                }
                
                if viewModel.isLoading {
                    LoadingView()
                }
            }
            .navigationTitle("マップ")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showingFilter) {
                FilterView(filter: $viewModel.searchFilter) { filter in
                    viewModel.updateFilter(filter)
                }
            }
            .sheet(item: $viewModel.selectedCafe) { cafe in
                CafeDetailView(cafe: cafe, viewModel: viewModel)
            }
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
        .onReceive(viewModel.$currentLocation) { location in
            if let location = location {
                withAnimation {
                    region.center = location.coordinate
                }
            }
        }
    }
}

struct CafeAnnotationView: View {
    let cafe: Cafe
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 0) {
                Image(systemName: "cup.and.saucer.fill")
                    .font(.title2)
                    .foregroundColor(.white)
                    .frame(width: 30, height: 30)
                    .background(Color.brown)
                    .clipShape(Circle())
                
                Image(systemName: "triangle.fill")
                    .font(.caption)
                    .foregroundColor(.brown)
                    .offset(y: -2)
            }
        }
    }
}

struct LoadingView: View {
    var body: some View {
        ZStack {
            Color.black.opacity(0.3)
                .ignoresSafeArea()
            
            VStack(spacing: 15) {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .scaleEffect(1.5)
                
                Text("検索中...")
                    .foregroundColor(.white)
                    .font(.headline)
            }
            .padding(30)
            .background(Color.black.opacity(0.7))
            .cornerRadius(15)
        }
    }
}

#Preview {
    MapView(viewModel: CafeSearchViewModel(
        locationService: LocationService(),
        placesService: GooglePlacesService(apiKey: "test")
    ))
} 