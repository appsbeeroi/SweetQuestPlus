import SwiftUI

struct BalooThambiField: View {
    var title: String
    @Binding var text: String
    let isFocused: FocusState<Bool>.Binding
    
    var body: some View {
        VStack(spacing: 0) {
            BalooThambiText(title, size: 18)
                .foregroundStyle(.accent)
                .hSpacing(.leading)
            
            HStack {
                TextField("", text: $text,)
                .focused(isFocused)
                .font(.balooThambi(isSmallScreen ? 18 : 24))
                .frame(maxWidth: .infinity)
            }
            .foregroundStyle(.accent)
            .padding(8)
            .background(.white)
            .clipShape(.capsule)
            .overlay {
                Capsule()
                    .stroke(.accent, lineWidth: 4)
            }
        }
    }
}

#Preview {
    struct PreviewWrapper: View {
        @FocusState private var isFocused: Bool
        @State private var text = ""
        
        var body: some View {
            VStack {
                BalooThambiField(
                    title: "What I Ate",
                    text: $text,
                    isFocused: $isFocused
                )
            }
            .detailScreenStyle()
        }
    }
    
    return PreviewWrapper()
}
