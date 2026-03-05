import Foundation
import UIKit


struct GameLevel: Identifiable {
    var id: Int = 1
    var rows: Int = 2
    var columns: Int = 2
    var cardSize: CGSize = CGSize(width: 150, height: 210)
    var smallCardSize: CGSize = CGSize(width: 120, height: 168)
    var cards: [GameCard] = []
    var isSmallScreen: Bool {
        UIScreen.main.bounds.height < 700
    }
    var currentCardSize: CGSize {
        isSmallScreen ? smallCardSize : cardSize
    }
}

extension GameLevel {
    static func makeLevel(
        id: Int,
        rows: Int,
        columns: Int,
        cardSize: CGSize,
        smallCardSize: CGSize
    ) -> GameLevel {
        let pairsCount = (rows * columns) / 2
        let items = Array(CollectionItem.allCases.shuffled().prefix(pairsCount))
        var cards: [GameCard] = []
        for item in items {
            cards.append(GameCard(item: item))
            cards.append(GameCard(item: item))
        }
        cards.shuffle()
        return GameLevel(
            id: id,
            rows: rows,
            columns: columns,
            cardSize: cardSize,
            smallCardSize: smallCardSize,
            cards: cards
        )
    }
}

enum GameLevels {
    
    static let all: [GameLevel] = [
        
        .makeLevel(
            id: 1,
            rows: 2,
            columns: 2,
            cardSize: CGSize(width: 150, height: 210),
            smallCardSize: CGSize(width: 120, height: 168)
        ),
        
        .makeLevel(
            id: 2,
            rows: 3,
            columns: 2,
            cardSize: CGSize(width: 132, height: 186),
            smallCardSize: CGSize(width: 105, height: 148)
        ),
        
        .makeLevel(
            id: 3,
            rows: 3,
            columns: 3,
            cardSize: CGSize(width: 93, height: 132),
            smallCardSize: CGSize(width: 74, height: 105)
        ),
        
        .makeLevel(
            id: 4,
            rows: 3,
            columns: 4,
            cardSize: CGSize(width: 80, height: 120),
            smallCardSize: CGSize(width: 64, height: 96)
        ),
        
        .makeLevel(
            id: 5,
            rows: 4,
            columns: 4,
            cardSize: CGSize(width: 75, height: 100),
            smallCardSize: CGSize(width: 60, height: 80)
        ),
        
        .makeLevel(
            id: 6,
            rows: 4,
            columns: 5,
            cardSize: CGSize(width: 70, height: 98),
            smallCardSize: CGSize(width: 50, height: 70)
        ),
        
        .makeLevel(
            id: 7,
            rows: 5,
            columns: 5,
            cardSize: CGSize(width: 61, height: 86),
            smallCardSize: CGSize(width: 49, height: 69)
        ),
        
        .makeLevel(
            id: 8,
            rows: 5,
            columns: 6,
            cardSize: CGSize(width: 55, height: 78),
            smallCardSize: CGSize(width: 44, height: 62)
        ),
        
        .makeLevel(
            id: 9,
            rows: 6,
            columns: 6,
            cardSize: CGSize(width: 55, height: 78),
            smallCardSize: CGSize(width: 44, height: 62)
        ),
        
        .makeLevel(
            id: 10,
            rows: 8,
            columns: 6,
            cardSize: CGSize(width: 55, height: 78),
            smallCardSize: CGSize(width: 44, height: 62)
        ),
        
        .makeLevel(
            id: 11,
            rows: 9,
            columns: 6,
            cardSize: CGSize(width: 55, height: 78),
            smallCardSize: CGSize(width: 44, height: 62)
        ),
        
        .makeLevel(
            id: 12,
            rows: 9,
            columns: 6,
            cardSize: CGSize(width: 55, height: 78),
            smallCardSize: CGSize(width: 44, height: 62)
        )
    ]
}

extension GameLevels {
    
    static var firstRow: [GameLevel] {
        Array(all.prefix(6))
    }
    
    static var secondRow: [GameLevel] {
        Array(all.suffix(6))
    }
}
