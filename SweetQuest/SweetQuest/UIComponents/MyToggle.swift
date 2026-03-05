import SwiftUI
import UserNotifications

struct MyToggle: View {
    @EnvironmentObject var notificationService: NotificationService
    @State private var showSettingsAlert = false

    var body: some View {
        Toggle("", isOn: Binding(
            get: { notificationService.isEnabled },
            set: { newValue in handleToggleChange(newValue) }
        ))
        .labelsHidden()
        .toggleStyle(SymbolToggleStyle())
        .alert("Notifications Disabled",
               isPresented: $showSettingsAlert) {
            Button("Open Settings") {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Please enable notifications in your iPhone Settings.")
        }
    }

    private func handleToggleChange(_ newValue: Bool) {
        if newValue {
            UNUserNotificationCenter.current().getNotificationSettings { settings in
                DispatchQueue.main.async {
                    switch settings.authorizationStatus {
                    case .notDetermined:
                        notificationService.requestAuthorization { granted in
                            if !granted {
                                notificationService.isEnabled = false
                            }
                        }
                    case .denied:
                        showSettingsAlert = true
                        notificationService.isEnabled = false
                    case .authorized:
                        notificationService.isEnabled = true
                    default:
                        notificationService.isEnabled = false
                    }
                }
            }
        } else {
            notificationService.isEnabled = false
        }
    }
}

struct SymbolToggleStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        VStack(spacing: 10) {
            Capsule()
                .fill(configuration.isOn ? .accent : .gray)
                .overlay {
                    BalooThambiText(configuration.isOn ? "On" : "Off", size: 32)
                        .foregroundStyle(.white)
                }
                .frame(width: 74, height: 42)
                .onTapGesture {
                    withAnimation(.spring()) {
                        configuration.isOn.toggle()
                    }
                }
        }
    }
}

#Preview {
    VStack {
        MyToggle()
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .environmentObject(NotificationService.shared)
}
            
