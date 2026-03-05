import Foundation
import Combine

final class LevelsViewModel: ObservableObject {
    @Published var level: GameLevel = .init()
    @Published var flippedCards: [GameCard] = []
    @Published var isWin = false
    @Published var isLose = false
    @Published var remainingTime: TimeInterval = 90
    
    private let manager = ManagerService.shared
    
    private var timer: Timer?
    
    func win() {
        manager.recordGame(isWin: true)
    }
    
    func lose() {
        manager.recordGame(isWin: false)
    }
}

extension LevelsViewModel {
    
    func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            self.remainingTime -= 1
            if self.remainingTime <= 0 {
                self.timer?.invalidate()
                self.isLose = true
            }
        }
    }
    
    func stopTimer() {
        timer?.invalidate()
    }
}

extension LevelsViewModel {
    
    func flipCard(_ card: GameCard) {
        
        guard let index = level.cards.firstIndex(where: { $0.id == card.id }) else { return }
        
        guard !level.cards[index].isFlipped else { return }
        guard !level.cards[index].isMatched else { return }
        
        level.cards[index].isFlipped = true
        
        flippedCards.append(level.cards[index])
        
        if flippedCards.count == 2 {
            
            checkMatch()
        }
    }
}

private extension LevelsViewModel {
    
    func checkMatch() {
        
        let first = flippedCards[0]
        let second = flippedCards[1]
        
        if first.item == second.item {
            
            markMatched(first, second)
            
            checkWin()
            
        } else {
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                self.unflip(first, second)
            }
        }
        
        flippedCards.removeAll()
    }
    
    func markMatched(_ first: GameCard, _ second: GameCard) {
        
        level.cards = level.cards.map {
            
            var card = $0
            
            if card.id == first.id || card.id == second.id {
                card.isMatched = true
            }
            
            return card
        }
    }
    
    func unflip(_ first: GameCard, _ second: GameCard) {
        
        level.cards = level.cards.map {
            
            var card = $0
            
            if card.id == first.id || card.id == second.id {
                card.isFlipped = false
            }
            
            return card
        }
    }
}

private extension LevelsViewModel {
    
    func checkWin() {
        
        if level.cards.allSatisfy({ $0.isMatched }) {
            
            stopTimer()
            
            isWin = true
        }
    }
}
