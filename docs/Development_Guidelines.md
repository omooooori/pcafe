# Development Guidelines

## 概要

このドキュメントは、Cafe Parking Finder Appの開発に参加する開発者向けのガイドラインです。
コードの品質、一貫性、保守性を保つためのルールとベストプラクティスを定義しています。

## アーキテクチャ

### MVVM (Model-View-ViewModel)

このアプリケーションはMVVMアーキテクチャパターンに従っています。

#### 各レイヤーの役割

**Model**
- データ構造の定義
- ビジネスロジックの実装
- 外部APIとの通信

**View**
- ユーザーインターフェースの表示
- ユーザー入力の処理
- ViewModelとのデータバインディング

**ViewModel**
- ViewとModelの橋渡し
- ビジネスロジックの実行
- 状態管理

#### ディレクトリ構造

```
CafeParkingFinderApp/
├── Models/          # データモデル
├── Views/           # SwiftUIビュー
├── ViewModels/      # ビューモデル
├── Services/        # 外部サービス
├── Utils/           # ユーティリティ
├── Extensions/      # Swift拡張
├── Mock/            # モックデータ
└── Resources/       # リソースファイル
```

## コーディング規約

### Swift言語規約

#### 1. 命名規則

**クラス・構造体・列挙型**
```swift
// ✅ 正しい例
class CafeSearchViewModel
struct SearchFilter
enum SortOption

// ❌ 間違った例
class cafeSearchViewModel
struct searchFilter
enum sortOption
```

**変数・プロパティ**
```swift
// ✅ 正しい例
let cafeName: String
var isLoading: Bool
private let apiKey: String

// ❌ 間違った例
let cafe_name: String
var is_loading: Bool
private let API_KEY: String
```

**関数・メソッド**
```swift
// ✅ 正しい例
func searchCafes()
func getDistance(to cafe: Cafe) -> String
private func setupBindings()

// ❌ 間違った例
func SearchCafes()
func get_distance(to cafe: Cafe) -> String
private func SetupBindings()
```

#### 2. アクセス制御

```swift
// ✅ 適切なアクセス制御
class CafeSearchViewModel: ObservableObject {
    @Published var cafes: [Cafe] = []        // internal
    private let locationService: LocationService
    fileprivate var cancellables = Set<AnyCancellable>()
}
```

#### 3. オプショナル型の使用

```swift
// ✅ 適切なオプショナル型の使用
let rating: Double? = cafe.rating
guard let location = currentLocation else { return }

// ❌ 強制アンラップの乱用
let rating: Double = cafe.rating!  // 危険
```

### SwiftUI規約

#### 1. ビューの構造

```swift
// ✅ 適切なビュー構造
struct CafeListView: View {
    @ObservedObject var viewModel: CafeSearchViewModel
    
    var body: some View {
        NavigationView {
            List(viewModel.cafes) { cafe in
                CafeRowView(cafe: cafe)
            }
            .navigationTitle("カフェ一覧")
        }
    }
}
```

#### 2. プロパティラッパーの使用

```swift
// ✅ 適切なプロパティラッパー
@StateObject var viewModel = CafeSearchViewModel()
@ObservedObject var viewModel: CafeSearchViewModel
@State private var searchText = ""
@Binding var isPresented: Bool
```

#### 3. モディファイアの順序

```swift
// ✅ 適切なモディファイアの順序
Text("カフェ名")
    .font(.headline)
    .foregroundColor(.primary)
    .padding()
    .background(Color.secondary.opacity(0.1))
    .cornerRadius(8)
```

### Combine規約

#### 1. Publisherの使用

```swift
// ✅ 適切なPublisherの使用
locationService.$currentLocation
    .compactMap { $0 }
    .sink { location in
        // 位置情報の処理
    }
    .store(in: &cancellables)
```

#### 2. エラーハンドリング

```swift
// ✅ 適切なエラーハンドリング
placesService.searchCafesWithParking(near: location, filter: filter)
    .receive(on: DispatchQueue.main)
    .sink(
        receiveCompletion: { completion in
            if case .failure(let error) = completion {
                self.error = error
            }
        },
        receiveValue: { cafes in
            self.cafes = cafes
        }
    )
    .store(in: &cancellables)
```

## ドキュメント規約

### SwiftDocコメント

#### 1. クラス・構造体のドキュメント

```swift
/**
 カフェ検索機能を管理するビューモデル
 
 このクラスは、カフェ検索のビジネスロジックを担当し、SwiftUIビューとデータソースの間の橋渡しをします。
 Combineフレームワークを使用してリアクティブなデータバインディングを実現し、
 位置情報サービスとGoogle Places APIサービスを統合します。
 
 ## 主な機能
 - 現在位置の取得と監視
 - カフェ検索の実行
 - 検索結果のフィルタリングとソート
 - エラーハンドリング
 
 ## 使用例
 ```swift
 let viewModel = CafeSearchViewModel(
     locationService: LocationService(),
     placesService: GooglePlacesService(apiKey: "your-api-key")
 )
 ```
 
 - Author: Cafe Parking Finder Team
 - Version: 1.0.0
 - Since: 2024
 */
```

#### 2. メソッドのドキュメント

```swift
/**
 現在位置周辺のカフェを検索
 
 現在位置を基に、設定されたフィルター条件でカフェを検索します。
 位置情報が利用できない場合はエラーを設定します。
 
 - Parameter location: 検索の中心となる位置
 - Returns: 検索結果のカフェ配列
 - Throws: `LocationError` 位置情報が利用できない場合
 */
func searchCafes(at location: CLLocation) throws -> [Cafe]
```

#### 3. プロパティのドキュメント

```swift
/// 検索結果のカフェ配列
@Published var cafes: [Cafe] = []

/// 現在の検索フィルター設定
@Published var searchFilter = SearchFilter()
```

## テスト規約

### ユニットテスト

#### 1. テストファイルの命名

```
CafeSearchViewModelTests.swift
GooglePlacesServiceTests.swift
CafeModelTests.swift
```

#### 2. テストメソッドの命名

```swift
// ✅ 適切なテストメソッド名
func testSearchCafes_WithValidLocation_ReturnsCafes()
func testSearchCafes_WithInvalidLocation_ThrowsError()
func testFilterCafes_WithRatingFilter_FiltersCorrectly()
```

#### 3. テストの構造

```swift
class CafeSearchViewModelTests: XCTestCase {
    var viewModel: CafeSearchViewModel!
    var mockLocationService: MockLocationService!
    var mockPlacesService: MockGooglePlacesService!
    
    override func setUp() {
        super.setUp()
        mockLocationService = MockLocationService()
        mockPlacesService = MockGooglePlacesService()
        viewModel = CafeSearchViewModel(
            locationService: mockLocationService,
            placesService: mockPlacesService
        )
    }
    
    override func tearDown() {
        viewModel = nil
        mockLocationService = nil
        mockPlacesService = nil
        super.tearDown()
    }
    
    func testSearchCafes_WithValidLocation_ReturnsCafes() {
        // Given
        let expectedCafes = [MockData.sampleCafe]
        mockPlacesService.mockCafes = expectedCafes
        
        // When
        viewModel.searchCafes()
        
        // Then
        XCTAssertEqual(viewModel.cafes.count, 1)
        XCTAssertEqual(viewModel.cafes.first?.name, expectedCafes.first?.name)
    }
}
```

### UIテスト

#### 1. UIテストの構造

```swift
class CafeParkingFinderAppUITests: XCTestCase {
    var app: XCUIApplication!
    
    override func setUp() {
        super.setUp()
        app = XCUIApplication()
        app.launch()
    }
    
    func testCafeSearchFlow() {
        // 位置情報許可をタップ
        let locationButton = app.buttons["位置情報を許可"]
        locationButton.tap()
        
        // 検索結果の確認
        let cafeList = app.collectionViews["CafeList"]
        XCTAssertTrue(cafeList.waitForExistence(timeout: 5))
        
        // カフェをタップ
        let firstCafe = cafeList.cells.element(boundBy: 0)
        firstCafe.tap()
        
        // 詳細画面の確認
        let detailView = app.otherElements["CafeDetailView"]
        XCTAssertTrue(detailView.exists)
    }
}
```

## エラーハンドリング

### エラー型の定義

```swift
enum AppError: Error, LocalizedError {
    case networkError(Error)
    case locationError(LocationError)
    case apiError(PlacesError)
    case validationError(String)
    
    var errorDescription: String? {
        switch self {
        case .networkError(let error):
            return "ネットワークエラー: \(error.localizedDescription)"
        case .locationError(let error):
            return error.localizedDescription
        case .apiError(let error):
            return error.localizedDescription
        case .validationError(let message):
            return message
        }
    }
}
```

### エラーハンドリングの実装

```swift
// ✅ 適切なエラーハンドリング
do {
    let cafes = try await searchCafes()
    self.cafes = cafes
} catch {
    self.error = AppError.apiError(error as? PlacesError ?? .invalidResponse)
}
```

## パフォーマンス最適化

### 1. メモリ管理

```swift
// ✅ 適切なメモリ管理
private var cancellables = Set<AnyCancellable>()

deinit {
    cancellables.removeAll()
}
```

### 2. 画像の最適化

```swift
// ✅ 画像の最適化
AsyncImage(url: cafe.photoURL) { image in
    image
        .resizable()
        .aspectRatio(contentMode: .fill)
} placeholder: {
    ProgressView()
}
.frame(width: 60, height: 60)
.clipped()
```

### 3. リストの最適化

```swift
// ✅ リストの最適化
List(cafes, id: \.id) { cafe in
    CafeRowView(cafe: cafe)
        .id(cafe.id)  // 明示的なID指定
}
```

## セキュリティ

### 1. APIキーの管理

```swift
// ✅ 安全なAPIキー管理
enum APIKeys {
    static let googlePlaces: String = {
        guard let path = Bundle.main.path(forResource: "APIKeys", ofType: "plist"),
              let dict = NSDictionary(contentsOfFile: path),
              let key = dict["GooglePlacesAPIKey"] as? String else {
            fatalError("Google Places APIキーが見つかりません")
        }
        return key
    }()
}
```

### 2. データ検証

```swift
// ✅ データ検証
func validateCafe(_ cafe: Cafe) -> Bool {
    guard !cafe.name.isEmpty,
          cafe.location.latitude != 0,
          cafe.location.longitude != 0 else {
        return false
    }
    return true
}
```

## デバッグ

### 1. ログ出力

```swift
// ✅ 適切なログ出力
import os.log

private let logger = Logger(subsystem: "com.cafeparkingfinder.app", category: "CafeSearch")

func searchCafes() {
    logger.info("カフェ検索を開始: \(location)")
    // 検索処理
    logger.info("カフェ検索完了: \(cafes.count)件")
}
```

### 2. デバッグ用の設定

```swift
#if DEBUG
    static let apiBaseURL = "https://maps.googleapis.com/maps/api/place"
    static let enableLogging = true
#else
    static let apiBaseURL = "https://maps.googleapis.com/maps/api/place"
    static let enableLogging = false
#endif
```

## リファクタリング

### 1. コードの分割

```swift
// ✅ 適切なコード分割
extension CafeSearchViewModel {
    func handleSearchSuccess(_ cafes: [Cafe]) {
        self.cafes = applySorting(to: cafes)
        self.isLoading = false
    }
    
    func handleSearchError(_ error: Error) {
        self.error = error
        self.isLoading = false
    }
}
```

### 2. 共通処理の抽出

```swift
// ✅ 共通処理の抽出
extension Array where Element == Cafe {
    func sorted(by sortOption: SortOption, from location: CLLocation?) -> [Cafe] {
        switch sortOption {
        case .distance:
            return sorted { cafe1, cafe2 in
                guard let location = location else { return false }
                let distance1 = location.distance(from: CLLocation(latitude: cafe1.location.latitude, longitude: cafe1.location.longitude))
                let distance2 = location.distance(from: CLLocation(latitude: cafe2.location.latitude, longitude: cafe2.location.longitude))
                return distance1 < distance2
            }
        case .rating:
            return sorted { $0.rating ?? 0 > $1.rating ?? 0 }
        case .price:
            return sorted { ($0.priceLevel ?? 4) < ($1.priceLevel ?? 4) }
        }
    }
}
```

## 参考資料

- [Swift API Design Guidelines](https://swift.org/documentation/api-design-guidelines/)
- [SwiftUI Documentation](https://developer.apple.com/documentation/swiftui)
- [Combine Documentation](https://developer.apple.com/documentation/combine)
- [Google Places API Documentation](https://developers.google.com/maps/documentation/places/web-service) 