import Foundation
import SwiftUI

enum TabModel: String, CaseIterable, Identifiable {
    var id: Self { self }
    
    case levels, collection, diary, statistics

    @ViewBuilder
    var view: some View {
        switch self {
        case .levels: LevelsView()
        case .collection: CollectionView()
        case .diary: DiaryView()
        case .statistics: StatisticsView()
        }
    }
}
