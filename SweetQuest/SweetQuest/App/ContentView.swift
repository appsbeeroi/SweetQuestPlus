import SwiftUI

struct ContentView: View {
    @StateObject var launchScreenState = LaunchScreenStateManager()
    @State var appState: AppState = .onboarding
    @AppStorage("FIRST_LAUNCH") var firstLaunch = true
    
    
    var body: some View {
        Group {
            switch launchScreenState.state {
            case .start: LaunchScreen()
            case.finished: mainContent
            }
        }
        .environmentObject(launchScreenState)
        .preferredColorScheme(.light)
        .onAppear {
            appState = firstLaunch ? .onboarding : .home
        }
        .onChange(of: firstLaunch) { newValue in
            appState = newValue ? .onboarding : .home
        }
    }
    
    
    private var mainContent: some View {
        Group {
            switch appState {
            case .onboarding:
                OnboardingView()
            case .home:
                TabBarView()
            }
        }
    }
    
    enum AppState {
        case onboarding
        case home
    }
}

#Preview {
    ContentView()
}
