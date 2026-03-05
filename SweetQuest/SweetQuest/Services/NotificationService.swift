import Foundation
import SwiftUI
import UserNotifications
import Combine

final class NotificationService: ObservableObject {

    @AppStorage("notificationsEnabled") private var storedEnabled = false
    @Published var isEnabled: Bool = false

    static let shared = NotificationService()

    private init() {
        self.isEnabled = storedEnabled
    }

    func requestAuthorization(completion: @escaping (Bool) -> Void) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, _ in

            UNUserNotificationCenter.current().getNotificationSettings { settings in
                let finalGranted = (settings.authorizationStatus == .authorized)

                DispatchQueue.main.async {
                    self.storedEnabled = finalGranted
                    self.isEnabled = finalGranted
                    completion(finalGranted)
                }
            }
        }
    }

    func refreshStatus() {
        UNUserNotificationCenter.current().getNotificationSettings { [weak self] settings in
            DispatchQueue.main.async {
                let granted = (settings.authorizationStatus == .authorized)
                self?.storedEnabled = granted
                self?.isEnabled = granted
            }
        }
    }
}
