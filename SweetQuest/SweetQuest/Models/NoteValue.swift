import Foundation

struct NoteValue: Identifiable, Codable {
    var id = UUID()
    var whatIAte = ""
    var howMuch = ""
    var when = ""
    var mood: NoteMood = .good
}


enum NoteMood: Identifiable, Codable, Equatable, CaseIterable {
    var id: Self { self }
    
    case sad, neutral, good, happy
    
    var iconName: String {
        switch self {
        case .sad: "😢"
        case .neutral: "😐"
        case .good: "🙂"
        case .happy: "😁"
        }
    }
}
