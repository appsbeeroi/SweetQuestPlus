import Foundation
import Combine

@MainActor
final class LaunchScreenStateManager: ObservableObject {
    
    @Published private(set) var state: LaunchScreenStep = .start
    
    func dismiss() {
        Task {
            try? await Task.sleep(nanoseconds: 200_000_000)
            
            self.state = .finished
        }
    }
    
    enum LaunchScreenStep {
        case start
        case finished
    }
}
