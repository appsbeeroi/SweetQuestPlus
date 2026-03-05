import Foundation

struct GameCard: Identifiable, Equatable {
    
    let id: UUID
    let item: CollectionItem
    
    var isFlipped: Bool = false
    var isMatched: Bool = false
    
    init(item: CollectionItem) {
        self.id = UUID()
        self.item = item
    }
}
