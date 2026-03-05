import SwiftUI

struct BigButtonView: View {
    var title: String
    var action: () -> Void
    
    
    var body: some View {
        Button(action: action) {
            BalooThambiText(title, size: isSmallScreen ? 26 : 32)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(8)
                .background(.accent)
                .clipShape(.capsule)
        }
    }
}

#Preview {
    BigButtonView(title: "Continue") {
        
    }
}
