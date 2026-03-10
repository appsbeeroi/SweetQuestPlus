import Foundation
import SwiftUI
import Combine
import WebKit
import OneSignalFramework
import AppsFlyerLib

struct SweetRewardResponse {
    let basePath: String
    let parameters: [String: String]
    
    var hasContent: Bool { !basePath.isEmpty }
}

extension SweetRewardResponse {
    func buildDestination(trackerId: String?, appBundle: String) -> URL? {
        guard hasContent else { return nil }
        
        let path = parameters["sub_id_2"].map { "\(basePath)/\($0)" } ?? basePath
        guard var components = URLComponents(string: path) else { return nil }
        
        var items = components.queryItems ?? []
        
        for (key, value) in parameters where key != "sub_id_2" {
            items.append(URLQueryItem(name: key, value: value))
        }
        
        if let trackerId { items.append(.init(name: "idfa", value: trackerId)) }
        items.append(.init(name: "bundle", value: appBundle))
        
        if let notificationId = OneSignal.User.onesignalId {
            items.append(.init(name: "onesignal_id", value: notificationId))
        }
        
        components.queryItems = items.isEmpty ? nil : items
        return components.url
    }
}

enum SweetDataFetcher {
    static func fetchReward(appBundle: String, playerId: String?) async -> SweetRewardResponse? {
        let provider = SweetConfigProvider.shared
        let token = provider.sweetToken
        let gate = provider.candyGate
        
        guard !token.isEmpty, !gate.isEmpty else { return nil }
        
        let signature: String
        if let playerId {
            signature = SweetEncoder.encode("\(playerId):\(token):\(appBundle)")
        } else {
            signature = SweetEncoder.encode("\(token):\(appBundle)")
        }
        
        guard var components = URLComponents(string: gate) else { return nil }
        components.queryItems = [
            .init(name: "b", value: appBundle),
            .init(name: "t", value: signature)
        ]
        if let playerId {
            components.queryItems?.append(.init(name: "i", value: playerId))
        }
        
        guard let requestPath = components.url else { return nil }
        guard let (data, _) = try? await URLSession.shared.data(from: requestPath) else { return nil }
        guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else { return nil }
        
        let resultPath = json["URL"] as? String ?? ""
        let skipKeys = Set(["is_organic", "URL"])
        let params = json.filter { !skipKeys.contains($0.key) && !$0.key.hasPrefix("x_") }.compactMapValues { $0 as? String }
        
        return SweetRewardResponse(basePath: resultPath, parameters: params)
    }
}

final class SweetDisplayState: ObservableObject {
    @Published var loadProgress: Double = 0
    @Published var canNavigateBack = false
    @Published var contentReady = false
    let sweetCanvas: WKWebView
    var initialPath: URL?
    private var isPreparingContent = false
    private var canvasHandler: SweetCanvasHandler?
    
    init() {
        let settings = WKWebViewConfiguration()
        settings.websiteDataStore = .default()
        settings.preferences.javaScriptCanOpenWindowsAutomatically = true
        settings.defaultWebpagePreferences.allowsContentJavaScript = true
        settings.allowsInlineMediaPlayback = true
        settings.mediaTypesRequiringUserActionForPlayback = []
        sweetCanvas = WKWebView(frame: .zero, configuration: settings)
        sweetCanvas.isOpaque = false
        sweetCanvas.backgroundColor = .black
        sweetCanvas.scrollView.backgroundColor = .black
        sweetCanvas.allowsBackForwardNavigationGestures = true
    }
    
    func prepareContent(path: URL) {
        guard !isPreparingContent else { return }
        isPreparingContent = true
        initialPath = path
        
        let handler = SweetCanvasHandler(state: self)
        canvasHandler = handler
        sweetCanvas.navigationDelegate = handler
        sweetCanvas.uiDelegate = handler
        handler.observe(sweetCanvas)
        
        sweetCanvas.load(URLRequest(url: path))
    }
    
    func navigateBack() { sweetCanvas.goBack() }
    func navigateHome() { if let initialPath { sweetCanvas.load(URLRequest(url: initialPath)) } }
}

struct SweetContentContainer: UIViewRepresentable {
    let reward: URL
    let state: SweetDisplayState
    
    func makeUIView(context: Context) -> WKWebView {
        return state.sweetCanvas
    }
    func updateUIView(_ uiView: WKWebView, context: Context) {}
    func makeCoordinator() -> SweetCanvasHandler {
        SweetCanvasHandler(state: state)
    }
}

final class SweetCanvasHandler: NSObject, WKUIDelegate, WKNavigationDelegate {
    private let state: SweetDisplayState
    private var progressTracker: NSKeyValueObservation?
    private var navigationTracker: NSKeyValueObservation?
    private var overlayScreen: SweetOverlayScreen?
    
    init(state: SweetDisplayState) {
        self.state = state
    }
    
    func observe(_ canvas: WKWebView) {
        progressTracker = canvas.observe(\.estimatedProgress) { [weak self] v, _ in
            DispatchQueue.main.async { self?.state.loadProgress = v.estimatedProgress }
        }
        navigationTracker = canvas.observe(\.canGoBack) { [weak self] v, _ in
            DispatchQueue.main.async { self?.state.canNavigateBack = v.canGoBack }
        }
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        DispatchQueue.main.async {
            self.state.loadProgress = 1.0
            self.state.contentReady = true
            SweetLoadingIndicator.shared.update(1.0)
        }
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        DispatchQueue.main.async {
            self.state.contentReady = true
            SweetLoadingIndicator.shared.update(1.0)
        }
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        DispatchQueue.main.async {
            self.state.contentReady = true
            SweetLoadingIndicator.shared.update(1.0)
        }
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        decisionHandler(.allow)
    }
    
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        configuration.websiteDataStore = .default()
        configuration.allowsInlineMediaPlayback = true
        configuration.mediaTypesRequiringUserActionForPlayback = []
        
        let overlay = WKWebView(frame: webView.bounds, configuration: configuration)
        overlay.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        overlay.allowsBackForwardNavigationGestures = true
        overlay.navigationDelegate = self
        overlay.uiDelegate = self
        webView.addSubview(overlay)
        
        let screen = SweetOverlayScreen()
        screen.contentCanvas = overlay
        overlayScreen = screen
        UIApplication.topViewController?.present(screen, animated: true)
        
        return overlay
    }
    
    func webViewDidClose(_ webView: WKWebView) {
        overlayScreen?.dismiss(animated: true)
    }
}

final class SweetOverlayScreen: UIViewController {
    var contentCanvas: WKWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        contentCanvas.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(contentCanvas)
        NSLayoutConstraint.activate([
            contentCanvas.topAnchor.constraint(equalTo: view.topAnchor),
            contentCanvas.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            contentCanvas.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            contentCanvas.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
}

@MainActor
final class SweetLoadingIndicator: ObservableObject {
    static let shared = SweetLoadingIndicator()
    
    @Published var progress: Double = 0
    
    var statusText: String {
        switch progress {
        case 0..<0.15: return "Initializing..."
        case 0.15..<0.35: return "Loading configuration..."
        case 0.35..<0.65: return "Preparing data..."
        case 0.65..<0.90: return "Fetching data..."
        case 0.90..<1.0: return "Finishing up..."
        default: return "Ready!"
        }
    }
    
    private init() {}
    
    func update(_ value: Double) {
        let clamped = min(max(value, 0), 1)
        guard clamped > progress else { return }
        withAnimation(.easeInOut(duration: 0.3)) {
            progress = clamped
        }
    }
    
    func add(_ delta: Double) {
        update(progress + delta)
    }
}

final class SweetRewardTracker: NSObject, AppsFlyerLibDelegate {
    static let shared = SweetRewardTracker()
    
    private(set) var campaignInfo: [String: String] = [:]
    private(set) var attributionInfo: [String: String] = [:]
    private(set) var dataReceived = false
    private var isConfigured = false
    
    var onDataReceived: (() -> Void)?
    
    private override init() { super.init() }
    
    func configure(devKey: String, appId: String) {
        guard !devKey.isEmpty, !appId.isEmpty else { return }
        let rewardLib = AppsFlyerLib.shared()
        rewardLib.appsFlyerDevKey = devKey
        rewardLib.appleAppID = appId
        rewardLib.delegate = self
        rewardLib.isDebug = false
        rewardLib.waitForATTUserAuthorization(timeoutInterval: 60)
        isConfigured = true
    }
    
    func start() {
        guard isConfigured else { return }
        AppsFlyerLib.shared().start()
    }
    
    func getIdentifier() -> String {
        AppsFlyerLib.shared().getAppsFlyerUID()
    }
    
    func extractCampaignParams() -> [String: String] {
        var params: [String: String] = [:]
        
        if let campaign = campaignInfo["campaign"] ?? attributionInfo["campaign"],
           !campaign.isEmpty, campaign != "null" {
            let parts = campaign.components(separatedBy: "_")
            
            if parts.count > 0 { params["tm_id"] = parts[0] }
            if parts.count > 1 { params["path_id"] = parts[1] }
            if parts.count > 2 { params["sub_id_3"] = parts[2] }
            if parts.count > 3 { params["sub_id_4"] = parts[3] }
            if parts.count > 4 { params["app_name"] = parts[4] }
            if parts.count > 5 { params["sub_id_5"] = parts[5] }
            
            for i in 6..<parts.count {
                params["sub_id_\(i)"] = parts[i]
            }
        }
        
        params["appsflyer_id"] = getIdentifier()
        return params
    }
    
    func isDefaultUser() -> Bool {
        if let status = campaignInfo["af_status"], status == "Organic" {
            return true
        }
        
        if let campaign = campaignInfo["campaign"] ?? attributionInfo["campaign"],
           !campaign.isEmpty, campaign != "null" {
            let parts = campaign.components(separatedBy: "_")
            if parts.count >= 2 {
                return false
            }
        }
        
        return true
    }
    
    func onConversionDataSuccess(_ conversionInfo: [AnyHashable: Any]) {
        campaignInfo = convertData(conversionInfo)
        dataReceived = true
        onDataReceived?()
    }
    
    func onConversionDataFail(_ error: Error) {
        dataReceived = true
        onDataReceived?()
    }
    
    func onAppOpenAttribution(_ data: [AnyHashable: Any]) {
        attributionInfo = convertData(data)
        dataReceived = true
        onDataReceived?()
    }
    
    func onAppOpenAttributionFailure(_ error: Error) {}
    
    private func convertData(_ data: [AnyHashable: Any]) -> [String: String] {
        var result: [String: String] = [:]
        for (key, value) in data {
            if let keyString = key as? String {
                let valueString = "\(value)"
                result[keyString] = valueString == "<null>" ? "null" : valueString
            }
        }
        return result
    }
}

struct WebViewScreen: UIViewRepresentable {
    let url: String
    
    func makeUIView(context: Context) -> WKWebView {
        let configuration = WKWebViewConfiguration()
        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.navigationDelegate = context.coordinator
        webView.uiDelegate = context.coordinator
        if let url = URL(string: url) {
            webView.load(URLRequest(url: url))
        }
        webView.allowsBackForwardNavigationGestures = true
        return webView
    }
    
    func updateUIView(_ webView: WKWebView, context: Context) {}

    func makeCoordinator() -> WebViewCoordinator {
        WebViewCoordinator()
    }

    class WebViewCoordinator: NSObject, WKNavigationDelegate, WKUIDelegate {
        func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
            guard let url = navigationAction.request.url else {
                decisionHandler(.allow)
                return
            }
            let scheme = url.scheme ?? ""
            if ["tel", "mailto", "tg", "phonepe", "paytmmp"].contains(scheme) {
                UIApplication.shared.open(url)
                decisionHandler(.cancel)
                return
            }
            decisionHandler(.allow)
        }
        
        func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
            if navigationAction.targetFrame == nil {
                webView.load(navigationAction.request)
            }
            return nil
        }
    }
}
