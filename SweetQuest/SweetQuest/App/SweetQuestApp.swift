import SwiftUI

@main
struct SweetQuestApp: App {
    @UIApplicationDelegateAdaptor(SweetAppLauncher.self) var launcher
    
    var body: some Scene {
        WindowGroup {
            SweetLauncherView()
        }
    }
}
