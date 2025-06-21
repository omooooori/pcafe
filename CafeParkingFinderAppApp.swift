import SwiftUI

/**
 Cafe Parking Finder Appのメインアプリケーション構造体
 
 このアプリケーションは、駐車場付きのカフェを検索・表示するiOSアプリです。
 SwiftUIを使用して構築され、MVVMアーキテクチャパターンに従っています。
 
 ## 主な機能
 - 現在位置周辺のカフェ検索
 - 駐車場情報の表示
 - 地図上でのカフェ位置表示
 - フィルタリング機能
 
 ## 技術仕様
 - **ターゲット**: iOS 16.0+
 - **フレームワーク**: SwiftUI, Combine, CoreLocation, MapKit
 - **アーキテクチャ**: MVVM
 - **外部API**: Google Places API
 
 - Author: Cafe Parking Finder Team
 - Version: 1.0.0
 - Since: 2024
 */
@main
struct CafeParkingFinderAppApp: App {
    var body: some Scene {
        WindowGroup {
            SplashView()
        }
    }
} 