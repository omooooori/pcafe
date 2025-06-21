import Foundation
import CoreLocation

struct MockData {
    static let sampleCafes: [Cafe] = [
        Cafe(
            id: "1",
            name: "スターバックス 渋谷店",
            address: "東京都渋谷区渋谷2-21-1",
            phoneNumber: "03-1234-5678",
            rating: 4.2,
            userRatingsTotal: 150,
            priceLevel: 2,
            placeId: "mock_place_1",
            location: CLLocationCoordinate2D(latitude: 35.6580, longitude: 139.7016),
            types: ["cafe", "food", "establishment"],
            openingHours: Cafe.OpeningHours(
                openNow: true,
                periods: nil,
                weekdayText: [
                    "月曜日: 7:00–22:00",
                    "火曜日: 7:00–22:00",
                    "水曜日: 7:00–22:00",
                    "木曜日: 7:00–22:00",
                    "金曜日: 7:00–22:00",
                    "土曜日: 7:00–22:00",
                    "日曜日: 7:00–22:00"
                ]
            ),
            photos: [
                Cafe.Photo(photoReference: "mock_photo_1", height: 400, width: 600)
            ],
            website: "https://www.starbucks.co.jp",
            isFavorite: false
        ),
        Cafe(
            id: "2",
            name: "ドトールコーヒー 原宿店",
            address: "東京都渋谷区神宮前1-1-1",
            phoneNumber: "03-2345-6789",
            rating: 3.8,
            userRatingsTotal: 89,
            priceLevel: 1,
            placeId: "mock_place_2",
            location: CLLocationCoordinate2D(latitude: 35.6702, longitude: 139.7016),
            types: ["cafe", "food", "establishment"],
            openingHours: Cafe.OpeningHours(
                openNow: true,
                periods: nil,
                weekdayText: [
                    "月曜日: 8:00–21:00",
                    "火曜日: 8:00–21:00",
                    "水曜日: 8:00–21:00",
                    "木曜日: 8:00–21:00",
                    "金曜日: 8:00–21:00",
                    "土曜日: 8:00–21:00",
                    "日曜日: 8:00–21:00"
                ]
            ),
            photos: [
                Cafe.Photo(photoReference: "mock_photo_2", height: 400, width: 600)
            ],
            website: "https://www.doutor.co.jp",
            isFavorite: true
        ),
        Cafe(
            id: "3",
            name: "タリーズコーヒー 新宿店",
            address: "東京都新宿区新宿3-1-1",
            phoneNumber: "03-3456-7890",
            rating: 4.5,
            userRatingsTotal: 234,
            priceLevel: 2,
            placeId: "mock_place_3",
            location: CLLocationCoordinate2D(latitude: 35.6909, longitude: 139.7003),
            types: ["cafe", "food", "establishment"],
            openingHours: Cafe.OpeningHours(
                openNow: false,
                periods: nil,
                weekdayText: [
                    "月曜日: 7:30–21:30",
                    "火曜日: 7:30–21:30",
                    "水曜日: 7:30–21:30",
                    "木曜日: 7:30–21:30",
                    "金曜日: 7:30–21:30",
                    "土曜日: 7:30–21:30",
                    "日曜日: 7:30–21:30"
                ]
            ),
            photos: [
                Cafe.Photo(photoReference: "mock_photo_3", height: 400, width: 600)
            ],
            website: "https://www.tullys.co.jp",
            isFavorite: false
        ),
        Cafe(
            id: "4",
            name: "コメダ珈琲 池袋店",
            address: "東京都豊島区池袋1-1-1",
            phoneNumber: "03-4567-8901",
            rating: 4.0,
            userRatingsTotal: 167,
            priceLevel: 1,
            placeId: "mock_place_4",
            location: CLLocationCoordinate2D(latitude: 35.7295, longitude: 139.7104),
            types: ["cafe", "food", "establishment"],
            openingHours: Cafe.OpeningHours(
                openNow: true,
                periods: nil,
                weekdayText: [
                    "月曜日: 7:00–22:00",
                    "火曜日: 7:00–22:00",
                    "水曜日: 7:00–22:00",
                    "木曜日: 7:00–22:00",
                    "金曜日: 7:00–22:00",
                    "土曜日: 7:00–22:00",
                    "日曜日: 7:00–22:00"
                ]
            ),
            photos: [
                Cafe.Photo(photoReference: "mock_photo_4", height: 400, width: 600)
            ],
            website: "https://www.komeda.co.jp",
            isFavorite: false
        ),
        Cafe(
            id: "5",
            name: "プロント 銀座店",
            address: "東京都中央区銀座4-1-1",
            phoneNumber: "03-5678-9012",
            rating: 3.9,
            userRatingsTotal: 123,
            priceLevel: 3,
            placeId: "mock_place_5",
            location: CLLocationCoordinate2D(latitude: 35.6719, longitude: 139.7639),
            types: ["cafe", "food", "establishment"],
            openingHours: Cafe.OpeningHours(
                openNow: true,
                periods: nil,
                weekdayText: [
                    "月曜日: 8:00–23:00",
                    "火曜日: 8:00–23:00",
                    "水曜日: 8:00–23:00",
                    "木曜日: 8:00–23:00",
                    "金曜日: 8:00–23:00",
                    "土曜日: 8:00–23:00",
                    "日曜日: 8:00–23:00"
                ]
            ),
            photos: [
                Cafe.Photo(photoReference: "mock_photo_5", height: 400, width: 600)
            ],
            website: "https://www.pronto.co.jp",
            isFavorite: true
        )
    ]
    
    static let sampleFilter = SearchFilter(
        radius: 1500,
        minRating: 3.5,
        maxPriceLevel: 3,
        openNow: true,
        parkingTypes: [.free, .paid],
        sortBy: .distance
    )
    
    static let tokyoLocation = CLLocation(latitude: 35.6762, longitude: 139.6503)
    static let shibuyaLocation = CLLocation(latitude: 35.6580, longitude: 139.7016)
    static let shinjukuLocation = CLLocation(latitude: 35.6909, longitude: 139.7003)
} 