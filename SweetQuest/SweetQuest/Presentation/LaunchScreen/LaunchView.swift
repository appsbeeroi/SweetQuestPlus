import SwiftUI
import Combine

struct SplashView: View {
    @ObservedObject private var sweetIndicator = SweetLoadingIndicator.shared
    
    var body: some View {
        ZStack {
            BackgroundImageView(imageName: "launchBG")
            
            VStack {
                Spacer()
                
                VStack(spacing: 12) {
                    SweetProgressBar(progress: sweetIndicator.progress)
                    
                    HStack {
                        Text(sweetIndicator.statusText)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.white)
                        
                        Spacer()
                        
                        Text("\(Int(sweetIndicator.progress * 100))%")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.white)
                    }
                }
                .padding(.horizontal, 32)
                .padding(.vertical, 20)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.black.opacity(0.5))
                )
                .padding(.horizontal, 24)
                .padding(.bottom, 60)
            }
        }
    }
}

struct SweetProgressBar: View {
    let progress: Double
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.white.opacity(0.3))
                    .frame(height: 16)
                
                RoundedRectangle(cornerRadius: 8)
                    .fill(
                        LinearGradient(
                            colors: [Color.orange, Color.yellow],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: max(geometry.size.width * progress, 0), height: 16)
                    .animation(.easeInOut(duration: 0.3), value: progress)
                    .shadow(color: Color.orange.opacity(0.5), radius: 4, x: 0, y: 0)
            }
        }
        .frame(height: 16)
    }
}

#Preview {
    SplashView()
}
