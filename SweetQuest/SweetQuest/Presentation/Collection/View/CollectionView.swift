import SwiftUI

struct CollectionView: View {
    var body: some View {
        contentView
            .detailScreenStyle()
    }
    
    private var contentView: some View {
        VStack {
            MainHeaderView(title: "Collection")
            ScrollView {
                LazyVStack {
                    ForEach(CollectionItem.allCases) { item in
                        CollectionCellView(item: item)
                    }
                }
                .padding(.bottom, 120)
            }
            .scrollIndicators(.hidden)
        }
        .padding(.horizontal)
    }
}

#Preview {
    CollectionView()
}

struct CollectionCellView: View {
    var item: CollectionItem
    
    var body: some View {
        Image(.collectionCell)
            .resizable()
            .scaledToFit()
            .overlay {
                if ManagerService.shared.isCollectionItemUnlocked(item) {
                    HStack {
                        Image(item.rawValue)
                            .resizable()
                            .scaledToFit()
                            .frame(height: isSmallScreen ? 60 : 80)
                        
                        VStack(alignment: .leading) {
                            BalooThambiText(item.title, size: isSmallScreen ? 14 : 17)
                                .foregroundStyle(.accent)
                            BalooThambiText(item.description, size: isSmallScreen ? 12 : 14)
                                .multilineTextAlignment(.leading)
                        }
                    }
                    .frame(width: 240)
                } else {
                    Image(.lockCell)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 90)
                }
            }
    }
}
