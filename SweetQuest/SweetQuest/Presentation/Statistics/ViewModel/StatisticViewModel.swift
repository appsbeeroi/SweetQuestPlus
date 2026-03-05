import Combine
import Foundation

@MainActor
final class StatisticViewModel: ObservableObject {
    @Published var statistic: StatisticValue = .init()
    @Published var notes: [NoteValue] = []
    private let manager = ManagerService.shared
    
    
    func load() {
        statistic = manager.getStatistic()
        notes = manager.getAllNotes()
    }
    
    func mostFrequentMood() -> NoteMood? {
        guard !notes.isEmpty else { return nil }
        let grouped = Dictionary(grouping: notes, by: { $0.mood })
        let mostFrequent = grouped.max { lhs, rhs in
            lhs.value.count < rhs.value.count
        }
        return mostFrequent?.key
    }
}
