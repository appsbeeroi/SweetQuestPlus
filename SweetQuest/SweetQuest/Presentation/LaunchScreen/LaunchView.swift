import SwiftUI
import Combine

struct LaunchScreen: View {
    @State private var progress: Double = 0
    @EnvironmentObject private var launchScreenState: LaunchScreenStateManager
    let timer = Timer.publish(every: 0.2, on: .main, in: .common).autoconnect()
    
    var body: some View {
        VStack {
            ProgressView(value: progress, total: 10)
                .progressViewStyle(RoundedRectProgressViewStyle())
                .frame(maxWidth: .infinity, alignment: .bottom)
                .onReceive(timer) { _ in
                    withAnimation(.linear(duration: 0.2)) {
                        if progress < 10 {
                            progress += 1
                        } else {
                            launchScreenState.dismiss()
                        }
                    }
                }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
        .background(BackgroundImageView(imageName: "launchBG"))
    }
}
            

struct RoundedRectProgressViewStyle: ProgressViewStyle {
    func makeBody(configuration: Configuration) -> some View {
        ZStack(alignment: .leading) {
            Capsule()
                .frame(width: 300, height: 47)
                .foregroundColor(.white)
            
            Capsule()
                .frame(width: CGFloat(configuration.fractionCompleted ?? 0) * 300, height: 47)
                .foregroundColor(.accent)
        }
        .padding()
    }
}

#Preview {
    LaunchScreen()
        .environmentObject(LaunchScreenStateManager())
}
