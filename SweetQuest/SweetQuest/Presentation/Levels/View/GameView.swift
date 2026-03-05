import SwiftUI

struct GameView: View {
    var level: GameLevel
    @EnvironmentObject var viewModel: LevelsViewModel
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        contentView
            .onAppear {
                viewModel.level = level
            }
            .detailScreenStyle()
            .onAppear {
                viewModel.remainingTime = 90
                viewModel.startTimer()
            }
            .onDisappear {
                viewModel.stopTimer()
            }
            .alert("You Win!", isPresented: $viewModel.isWin) {
                
                Button("OK") {
                    viewModel.win()
                    dismiss.callAsFunction()
                }
            }
            .alert("You Lose!", isPresented: $viewModel.isLose) {
                
                Button("Ok") {
                    viewModel.lose()
                    dismiss.callAsFunction()
                }
            }
    }
    
    private var contentView: some View {
        VStack {
            DetailHeaderView(title: "Level \(level.id)") {
                dismiss.callAsFunction()
            }
            
            LazyVGrid(
                columns: Array(
                    repeating: GridItem(.fixed(viewModel.level.cardSize.width)),
                    count: viewModel.level.columns
                )
            ) {
                ForEach(viewModel.level.cards) { card in
                    CardView(card: card, size: level.currentCardSize)
                        .onTapGesture {
                            viewModel.flipCard(card)
                        }
                }
            }
            
            GameTimerView(time: viewModel.remainingTime)
                .vSpacing(.bottom)
        }
    }
}

#Preview {
    GameView(level: GameLevels.all[8])
        .environmentObject(LevelsViewModel())
}
