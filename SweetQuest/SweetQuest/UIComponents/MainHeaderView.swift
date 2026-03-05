import SwiftUI

struct MainHeaderView: View {
    var title: String
    
    var body: some View {
        HStack {
            BalooThambiText(title, size: 32)
                .foregroundStyle(.white)
                .padding(.horizontal)
                .background(.accent)
                .clipShape(.capsule)
                .hSpacing(.leading)
            
            NavigationLink {
                SettingsView()
            } label: {
                Image(systemName: "gearshape.fill")
                    .foregroundStyle(.white)
                    .imageScale(.large)
                    .padding(12)
                    .background(.accent)
                    .clipShape(.circle)
            }
        }
        .frame(maxHeight: 50)
    }
}

#Preview {
    LevelsView()
}

