import SwiftUI

struct OnboardingView: View {
    @State var selection: OnboardingItemModel = .first
    
    @AppStorage("FIRST_LAUNCH") var firstLaunch = true
    
    var body: some View {
        NavigationStack {
            switch selection {
            case .first:
                OnboardingItemView(item: .first) {
                    selection = .second
                }
            case .second:
                OnboardingItemView(item: .second) {
                    firstLaunch = false
                }
            }
        }
    }
}

#Preview {
    OnboardingView()
}
