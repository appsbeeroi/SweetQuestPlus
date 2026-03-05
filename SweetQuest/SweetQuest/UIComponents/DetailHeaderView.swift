import SwiftUI

struct DetailHeaderView: View {
    let title: String
    let backAction: () -> Void
    
    var body: some View {
        HStack(spacing: 40) {
            Button(action: backAction) {
                Image(systemName: "arrow.left")
                    .imageScale(.large)
                    .bold()
                    .foregroundStyle(.white)
                    .padding()
                    .background(.accent)
                    .clipShape(.circle)
            }
            
            BalooThambiText(title, size: 32)
                .foregroundStyle(.white)
                .padding(.horizontal)
                .background(.accent)
                .clipShape(.capsule)
                .hSpacing(.leading)
        }
        .padding(.horizontal)
        .frame(maxWidth: .infinity)
    }
}


#Preview {
    DetailHeaderView(title: "Settings") {
        
    }
    .vSpacing(.top)
}
