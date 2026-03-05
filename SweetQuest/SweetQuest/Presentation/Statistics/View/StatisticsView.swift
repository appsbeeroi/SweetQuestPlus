import SwiftUI

struct StatisticsView: View {
    @StateObject private var viewModel = StatisticViewModel()
    
    var body: some View {
        contentView
            .onAppear {
                viewModel.load()
            }
            .detailScreenStyle()
    }
    
    private var contentView: some View {
        VStack {
            MainHeaderView(title: "Statistics")
            
            ScrollView {
                VStack(spacing: 80) {
                    gameStatisticsView
                    collectedSweetsView
                    notesCountView
                }
                .padding(.top, 60)
                .padding(.bottom, 120)
            }
            .scrollIndicators(.hidden)
        }
        .padding(.horizontal)
    }
    
    private var gameStatisticsView: some View {
        VStack(alignment: .leading) {
            HStack {
                BalooThambiText("Games Played:", size: 24, weight: .medium)
                    .hSpacing(.leading)
                BalooThambiText("\(viewModel.statistic.gamesPlayed)", size: 24)
                    .foregroundStyle(.accent)
            }
            
            HStack {
                BalooThambiText("Wins:", size: 24, weight: .medium)
                    .hSpacing(.leading)
                BalooThambiText("\(viewModel.statistic.wins)", size: 24)
                    .foregroundStyle(.accent)
            }
            
            HStack {
                BalooThambiText("Loses:", size: 24, weight: .medium)
                    .hSpacing(.leading)
                BalooThambiText("\(viewModel.statistic.losses)", size: 24)
                    .foregroundStyle(.accent)
            }
        }
        .padding(.top)
        .padding()
        .frame(maxWidth: .infinity)
        .cellStyle()
        .overlay(alignment: .top) {
            Image(.statHead)
                .resizable()
                .scaledToFit()
                .overlay {
                    BalooThambiText("Games Stats", size: 32)
                        .foregroundStyle(.accent)
                }
                .offset(y: -70)
        }
    }
    
    private var collectedSweetsView: some View {
        VStack(alignment: .leading) {
            LazyVGrid(columns: columns(3)) {
                ForEach(viewModel.statistic.openedCollection.prefix(6)) { item in
                    Image(item.rawValue)
                        .resizable()
                        .scaledToFit()
                        .frame(width: isSmallScreen ? 70 : 80, height: isSmallScreen ? 70 : 80)
                }
            }
            
        }
        .padding(.top)
        .padding()
        .frame(maxWidth: .infinity)
        .frame(height: 200)
        .cellStyle()
        .overlay(alignment: .top) {
            Image(.statHead)
                .resizable()
                .scaledToFit()
                .overlay {
                    BalooThambiText("Collected Sweets", size: 32)
                        .foregroundStyle(.accent)
                }
                .offset(y: -70)
        }
    }
    
    
    private var notesCountView: some View {
        VStack(alignment: .leading) {
            HStack {
                BalooThambiText("Notes count:", size: 24, weight: .medium)
                    .hSpacing(.leading)
                BalooThambiText("\(viewModel.notes.count)", size: 24)
                    .foregroundStyle(.accent)
            }
            
            HStack {
                BalooThambiText("Average mood:", size: 24, weight: .medium)
                    .hSpacing(.leading)
                BalooThambiText(viewModel.mostFrequentMood()?.iconName ?? "", size: 24)
                    .foregroundStyle(.accent)
            }
        }
        .padding(.top)
        .padding()
        .frame(maxWidth: .infinity)
        .cellStyle()
        .overlay(alignment: .top) {
            Image(.statHead)
                .resizable()
                .scaledToFit()
                .overlay {
                    BalooThambiText("Diary", size: 32)
                        .foregroundStyle(.accent)
                }
                .offset(y: -70)
        }
    }
}

#Preview {
    StatisticsView()
}
