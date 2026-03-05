import SwiftUI

struct CardView: View {
    var card: GameCard
    var size: CGSize = CGSize(width: 100, height: 100)
    
    private var innerImageSize: CGSize {
        CGSize(
            width: size.width * 0.6,
            height: size.width * 0.6
        )
    }
    
    var body: some View {
        VStack {
            if card.isFlipped || card.isMatched {
                Image(.openCard)
                    .resizable()
                    .overlay {
                        Image(card.item.rawValue)
                            .resizable()
                            .frame(width: innerImageSize.width, height: innerImageSize.height)
                    }
                    .frame(width: size.width, height: size.height)
            } else {
                Image(.closeCard)
                    .resizable()
                    .frame(width: size.width, height: size.height)
            }
        }
    }
}

#Preview {
    CardView(card: GameCard(item: .berryStripes))
}
