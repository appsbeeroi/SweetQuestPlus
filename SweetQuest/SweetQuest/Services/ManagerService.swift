import Foundation
import SwiftUI
import AdSupport
import AppTrackingTransparency
import OneSignalFramework

final class SweetProgressKeeper {
    static let shared = SweetProgressKeeper()
    private init() {}
    
    var savedReward: URL? {
        UserDefaults.standard.string(forKey: SweetQuestConstants.progressKey).flatMap { URL(string: $0) }
    }
    
    func saveReward(_ reward: URL) {
        UserDefaults.standard.set(reward.absoluteString, forKey: SweetQuestConstants.progressKey)
    }
    
    func clearReward() {
        UserDefaults.standard.removeObject(forKey: SweetQuestConstants.progressKey)
    }
}

final class SweetAccessGate {
    static let shared = SweetAccessGate()
    private init() {}
    
    @MainActor
    func requestPlayerTracking() async -> String? {
        await waitForActiveState()
        guard #available(iOS 14, *) else {
            return ASIdentifierManager.shared().advertisingIdentifier.uuidString
        }
        let status = await ATTrackingManager.requestTrackingAuthorization()
        return status == .authorized ? ASIdentifierManager.shared().advertisingIdentifier.uuidString : nil
    }
    
    @MainActor
    private func waitForActiveState() async {
        guard UIApplication.shared.applicationState != .active else { return }
        await withCheckedContinuation { (continuation: CheckedContinuation<Void, Never>) in
            let holder = SweetHolder<NSObjectProtocol?>(nil)
            holder.value = NotificationCenter.default.addObserver(
                forName: UIApplication.didBecomeActiveNotification,
                object: nil,
                queue: .main
            ) { _ in
                if let obs = holder.value {
                    NotificationCenter.default.removeObserver(obs)
                }
                continuation.resume()
            }
        }
    }
    
    func requestNotificationAccess() async -> Bool {
        await withCheckedContinuation { continuation in
            OneSignal.Notifications.requestPermission({ accepted in
                continuation.resume(returning: accepted)
            }, fallbackToSettings: false)
        }
    }
}

final class SweetHolder<T>: @unchecked Sendable {
    var value: T
    init(_ value: T) { self.value = value }
}

struct ManagerService {
    private let statisticKey = "statistic"
    private let noteKey = "note"
    
    static let shared: ManagerService = .init()
    private init() {}
    
    
    func deleteAll() {
        saveNotes([])
        resetStatistic()
    }
}

extension ManagerService {
    private func loadNotes() -> [NoteValue] {
        guard let data = UserDefaults.standard.data(forKey: noteKey),
              let decoded = try? JSONDecoder().decode([NoteValue].self, from: data) else {
            return []
        }
        return decoded
    }
    
    
    private func saveNotes(_ note: [NoteValue]) {
        if let encoded = try? JSONEncoder().encode(note) {
            UserDefaults.standard.set(encoded, forKey: noteKey)
        }
    }
    
    func getAllNotes() -> [NoteValue] {
        loadNotes()
    }

    func addNewNote(_ note: NoteValue) {
        var notes = loadNotes()
        notes.append(note)
        saveNotes(notes)
    }
    
    func deleteParking(_ id: UUID) {
        var notes = loadNotes()
        notes.removeAll { $0.id == id }
        saveNotes(notes)
    }
    
    
    func update(_ note: NoteValue) {
        var notes = loadNotes()
        if let index = notes.firstIndex(where: { $0.id == note.id }) {
            notes[index] = note
            saveNotes(notes)
        }
    }
}

extension ManagerService {
    private func loadStatistic() -> StatisticValue {
        guard let data = UserDefaults.standard.data(forKey: statisticKey),
              let decoded = try? JSONDecoder().decode(StatisticValue.self, from: data) else {
            return StatisticValue()
        }
        return decoded
    }
    
    private func saveStatistic(_ statistic: StatisticValue) {
        if let encoded = try? JSONEncoder().encode(statistic) {
            UserDefaults.standard.set(encoded, forKey: statisticKey)
        }
    }
    
    func getStatistic() -> StatisticValue {
        loadStatistic()
    }
}

extension ManagerService {
    
    func recordGame(isWin: Bool) {
        var statistic = loadStatistic()
        statistic.gamesPlayed += 1
        if isWin {
            statistic.wins += 1
            unlockRandomCollectionItemIfNeeded(statistic: &statistic)
        } else {
            statistic.losses += 1
        }
        saveStatistic(statistic)
    }
}

extension ManagerService {
    
    func isCollectionItemUnlocked(_ item: CollectionItem) -> Bool {
        let statistic = loadStatistic()
        return statistic.openedCollection.contains(item)
    }
    
    func getUnlockedCollection() -> [CollectionItem] {
        loadStatistic().openedCollection
    }
    
    func resetStatistic() {
        saveStatistic(StatisticValue())
    }
}

extension ManagerService {
    private func unlockRandomCollectionItemIfNeeded(statistic: inout StatisticValue) {
        let lockedItems = CollectionItem.allCases
            .filter { !statistic.openedCollection.contains($0) }
        guard let randomItem = lockedItems.randomElement() else { return }
        statistic.openedCollection.append(randomItem)
    }
}
