import SwiftUI

struct TabBarView: View {
    @State private var selectedTab: TabModel = .levels
    
    var body: some View {
        NavigationStack {
            TabView(selection: $selectedTab) {
                ForEach(TabModel.allCases) { tab in
                    tab.view.tag(tab)
                        .background(BackgroundImageView(imageName: "mainBG"))
                }
                .toolbar(.hidden, for: .tabBar)
            }
            .overlay(alignment: .bottom) {
                tabbar
            }
            .ignoresSafeArea(.keyboard, edges: .bottom)
        }
    }
    
    private var tabbar: some View {
        HStack(spacing: 6) {
            ForEach(TabModel.allCases) { tab in
                Button(action: {selectedTab = tab}) {
                    itemView(tab)
                }
            }
        }
        .padding(.bottom)
        .frame(maxWidth: .infinity)
    }
    
    @ViewBuilder
    private func itemView(_ tab: TabModel) -> some View {
        let isSelected = selectedTab == tab
        VStack {
            Image(tab.rawValue)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: isSmallScreen ? 70 : 80, height: isSmallScreen ? 70 : 80)
                .background(
                    Circle()
                        .fill(isSelected ? .accent : .clear)
                        .blur(radius: 6)
                )
        }
    }
}

#Preview {
    TabBarView()
        .environmentObject(NotificationService.shared)
}

