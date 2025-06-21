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
    
    // MARK: - Properties
    
    /// カフェ検索ビューモデル
    @StateObject private var cafeSearchViewModel = CafeSearchViewModel()
    
    // MARK: - Initialization
    
    init() {
        // APIキーの設定確認
        if !APIConfig.isAPIKeyConfigured {
            print("⚠️ 警告: Google Maps APIキーが設定されていません。")
            print("APIConfig.swiftファイルでAPIキーを設定してください。")
        }
    }
    
    var body: some Scene {
        WindowGroup {
            if APIConfig.isAPIKeyConfigured {
                MainTabView()
                    .environmentObject(cafeSearchViewModel)
            } else {
                APIKeySetupView()
            }
        }
    }
}

// MARK: - API Key Setup View

/**
 APIキーが設定されていない場合に表示されるビュー
 */
struct APIKeySetupView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 60))
                .foregroundColor(.orange)
            
            Text("APIキーの設定が必要です")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("このアプリを動作させるには、Google Maps APIキーを設定する必要があります。")
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
            
            VStack(alignment: .leading, spacing: 10) {
                Text("設定手順:")
                    .fontWeight(.semibold)
                
                Text("1. Google Cloud ConsoleでAPIキーを取得")
                Text("2. APIConfig.swiftファイルを開く")
                Text("3. googleMapsAPIKeyに実際のAPIキーを設定")
                Text("4. アプリを再起動")
            }
            .font(.caption)
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(10)
            
            Button("APIConfig.swiftを開く") {
                // ファイルを開く処理（実装は省略）
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }
} 