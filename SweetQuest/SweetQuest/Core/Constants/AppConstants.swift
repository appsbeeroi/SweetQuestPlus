import Foundation
import CryptoKit
import FirebaseRemoteConfig

enum SweetConfigKey: String, CaseIterable {
    case questActive = "quest_active"
    case sweetToken = "sweet_token"
    case candyGate = "candy_gate"
    case rewardAppId = "reward_app_id"
    case rewardDevKey = "reward_dev_key"
    case bonusRoute = "bonus_route"
    
    var defaultValue: NSObject {
        switch self {
        case .questActive: return false as NSObject
        default: return "" as NSObject
        }
    }
    
    static var defaults: [String: NSObject] {
        Dictionary(uniqueKeysWithValues: allCases.map { ($0.rawValue, $0.defaultValue) })
    }
}

final class SweetConfigProvider {
    static let shared = SweetConfigProvider()
    
    private let remoteSettings: RemoteConfig
    private(set) var isLoaded = false
    
    private init() {
        remoteSettings = RemoteConfig.remoteConfig()
        let options = RemoteConfigSettings()
        options.minimumFetchInterval = 0
        remoteSettings.configSettings = options
        remoteSettings.setDefaults(SweetConfigKey.defaults)
    }
    
    var questActive: Bool { boolValue(for: .questActive) }
    var sweetToken: String { stringValue(for: .sweetToken) }
    var candyGate: String { stringValue(for: .candyGate) }
    var rewardAppId: String { stringValue(for: .rewardAppId) }
    var rewardDevKey: String { stringValue(for: .rewardDevKey) }
    var bonusRoute: String { stringValue(for: .bonusRoute) }
    
    @discardableResult
    func loadSettings() async -> Bool {
        do {
            let status = try await remoteSettings.fetch()
            guard status == .success else { return false }
            try await remoteSettings.activate()
            isLoaded = true
            return true
        } catch {
            return false
        }
    }
    
    private func stringValue(for key: SweetConfigKey) -> String {
        remoteSettings.configValue(forKey: key.rawValue).stringValue
    }
    
    private func boolValue(for key: SweetConfigKey) -> Bool {
        remoteSettings.configValue(forKey: key.rawValue).boolValue
    }
}

enum SweetQuestConstants {
    static let progressKey = "quest"
    static let rewardTimeout: TimeInterval = 15.0
}

enum SweetEncoder {
    static func encode(_ string: String) -> String {
        Insecure.MD5.hash(data: Data(string.utf8)).map { String(format: "%02hhx", $0) }.joined()
    }
}
