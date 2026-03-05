import SwiftUI

struct LevelsView: View {
    @StateObject private var viewModel: LevelsViewModel = .init()
    
    var body: some View {
        contentView
            .detailScreenStyle()
    }
    
    private var contentView: some View {
        VStack {
            MainHeaderView(title: "Levels")
            
            ScrollView {
                VStack(spacing: 16) {
                    VStack {
                        Image(.statHead)
                            .resizable()
                            .scaledToFit()
                            .overlay {
                                BalooThambiText("Easy Levels", size: 32)
                                    .foregroundStyle(.accent)
                            }
                        LazyVGrid(columns: columns(3)) {
                            ForEach(GameLevels.firstRow) { level in
                                levelCell(level)
                            }
                        }
                    }
                    
                    VStack {
                        Image(.statHead)
                            .resizable()
                            .scaledToFit()
                            .overlay {
                                BalooThambiText("Hard Levels", size: 32)
                                    .foregroundStyle(.accent)
                            }
                        LazyVGrid(columns: columns(3)) {
                            ForEach(GameLevels.secondRow) { level in
                                levelCell(level)
                            }
                        }
                    }
                }
                .padding(.bottom, 120)
            }
            .scrollIndicators(.hidden)
        }
        .padding(.horizontal)
    }
    
    @ViewBuilder
    private func levelCell(_ level: GameLevel) -> some View {
        NavigationLink {
            GameView(level: level)
                .environmentObject(viewModel)
        } label: {
            
            Image(.levelCell)
                .resizable()
                .scaledToFit()
                .frame(
                    width: isSmallScreen ? 80 : 100,
                    height: isSmallScreen ? 80 : 100
                )
                .overlay {
                    BalooThambiText("\(level.id)", size: 54)
                        .foregroundStyle(.levelText)
                }
        }
    }
}

#Preview {
    LevelsView()
}
