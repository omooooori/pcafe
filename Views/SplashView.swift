import SwiftUI

struct SplashView: View {
    @State private var isActive = false
    @State private var opacity = 0.0
    
    var body: some View {
        if isActive {
            MainTabView()
        } else {
            ZStack {
                Color("BackgroundColor")
                    .ignoresSafeArea()
                
                VStack(spacing: 30) {
                    Image(systemName: "cup.and.saucer.fill")
                        .font(.system(size: 80))
                        .foregroundColor(.brown)
                    
                    VStack(spacing: 10) {
                        Text("CafeParkingFinder")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                        
                        Text("駐車場のあるカフェを見つけよう")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .brown))
                        .scaleEffect(1.2)
                }
                .opacity(opacity)
            }
            .onAppear {
                withAnimation(.easeIn(duration: 1.0)) {
                    opacity = 1.0
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    withAnimation(.easeOut(duration: 0.5)) {
                        isActive = true
                    }
                }
            }
        }
    }
}

#Preview {
    SplashView()
} 