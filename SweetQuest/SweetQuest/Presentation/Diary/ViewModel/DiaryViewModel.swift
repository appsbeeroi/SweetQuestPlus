import Foundation
import Combine

@MainActor
final class DiaryViewModel: ObservableObject {
    @Published var notes: [NoteValue] = []
    
    private let manager: ManagerService
    
    init() {
        self.manager = .shared
    }
    
    func fetchData() {
        notes = manager.getAllNotes()
    }
    
    
    func addNew(_ note: NoteValue) {
        manager.addNewNote(note)
        fetchData()
    }
}
