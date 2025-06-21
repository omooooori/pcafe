import Foundation
import CoreLocation

struct MockData {
    static let sampleCafes: [Cafe] = [
        Cafe(
            id: "1",
            name: "スターバックス 渋谷店",
            address: "東京都渋谷区渋谷2-21-1",
            rating: 4.2,
            userRatingsTotal: 150,
            priceLevel: 2,
            types: ["cafe", "food", "establishment"],
            geometry: Cafe.Geometry(
                location: Cafe.Location(lat: 35.6580, lng: 139.7016)
            ),
            photos: [
                Cafe.Photo(photo_reference: "mock_photo_1", height: 400, width: 600)
            ],
            openingHours: Cafe.OpeningHours(
                open_now: true,
                weekday_text: [
                    "月曜日: 7:00–22:00",
                    "火曜日: 7:00–22:00",
                    "水曜日: 7:00–22:00",
                    "木曜日: 7:00–22:00",
                    "金曜日: 7:00–22:00",
                    "土曜日: 7:00–22:00",
                    "日曜日: 7:00–22:00"
                ]
            ),
            hasParking: true
        ),
        Cafe(
            id: "2",
            name: "ドトールコーヒー 原宿店",
            address: "東京都渋谷区神宮前1-1-1",
            rating: 3.8,
            userRatingsTotal: 89,
            priceLevel: 1,
            types: ["cafe", "food", "establishment"],
            geometry: Cafe.Geometry(
                location: Cafe.Location(lat: 35.6702, lng: 139.7016)
            ),
            photos: [
                Cafe.Photo(photo_reference: "mock_photo_2", height: 400, width: 600)
            ],
            openingHours: Cafe.OpeningHours(
                open_now: true,
                weekday_text: [
                    "月曜日: 8:00–21:00",
                    "火曜日: 8:00–21:00",
                    "水曜日: 8:00–21:00",
                    "木曜日: 8:00–21:00",
                    "金曜日: 8:00–21:00",
                    "土曜日: 8:00–21:00",
                    "日曜日: 8:00–21:00"
                ]
            ),
            hasParking: false
        ),
        Cafe(
            id: "3",
            name: "タリーズコーヒー 新宿店",
            address: "東京都新宿区新宿3-1-1",
            rating: 4.5,
            userRatingsTotal: 234,
            priceLevel: 2,
            types: ["cafe", "food", "establishment"],
            geometry: Cafe.Geometry(
                location: Cafe.Location(lat: 35.6909, lng: 139.7003)
            ),
            photos: [
                Cafe.Photo(photo_reference: "mock_photo_3", height: 400, width: 600)
            ],
            openingHours: Cafe.OpeningHours(
                open_now: false,
                weekday_text: [
                    "月曜日: 7:30–21:30",
                    "火曜日: 7:30–21:30",
                    "水曜日: 7:30–21:30",
                    "木曜日: 7:30–21:30",
                    "金曜日: 7:30–21:30",
                    "土曜日: 7:30–21:30",
                    "日曜日: 7:30–21:30"
                ]
            ),
            hasParking: true
        ),
        Cafe(
            id: "4",
            name: "コメダ珈琲 池袋店",
            address: "東京都豊島区池袋1-1-1",
            rating: 4.0,
            userRatingsTotal: 167,
            priceLevel: 1,
            types: ["cafe", "food", "establishment"],
            geometry: Cafe.Geometry(
                location: Cafe.Location(lat: 35.7295, lng: 139.7104)
            ),
            photos: [
                Cafe.Photo(photo_reference: "mock_photo_4", height: 400, width: 600)
            ],
            openingHours: Cafe.OpeningHours(
                open_now: true,
                weekday_text: [
                    "月曜日: 7:00–22:00",
                    "火曜日: 7:00–22:00",
                    "水曜日: 7:00–22:00",
                    "木曜日: 7:00–22:00",
                    "金曜日: 7:00–22:00",
                    "土曜日: 7:00–22:00",
                    "日曜日: 7:00–22:00"
                ]
            ),
            hasParking: false
        ),
        Cafe(
            id: "5",
            name: "プロント 銀座店",
            address: "東京都中央区銀座4-1-1",
            rating: 3.9,
            userRatingsTotal: 123,
            priceLevel: 3,
            types: ["cafe", "food", "establishment"],
            geometry: Cafe.Geometry(
                location: Cafe.Location(lat: 35.6719, lng: 139.7639)
            ),
            photos: [
                Cafe.Photo(photo_reference: "mock_photo_5", height: 400, width: 600)
            ],
            openingHours: Cafe.OpeningHours(
                open_now: true,
                weekday_text: [
                    "月曜日: 8:00–23:00",
                    "火曜日: 8:00–23:00",
                    "水曜日: 8:00–23:00",
                    "木曜日: 8:00–23:00",
                    "金曜日: 8:00–23:00",
                    "土曜日: 8:00–23:00",
                    "日曜日: 8:00–23:00"
                ]
            ),
            hasParking: true
        )
    ]
    
    static let sampleFilter = SearchFilter(
        radius: 1500,
        minRating: 3.5,
        maxPriceLevel: 3,
        requiresParking: false,
        sortBy: .rating
    )
    
    static let tokyoLocation = CLLocation(latitude: 35.6762, longitude: 139.6503)
    static let shibuyaLocation = CLLocation(latitude: 35.6580, longitude: 139.7016)
    static let shinjukuLocation = CLLocation(latitude: 35.6909, longitude: 139.7003)
} 