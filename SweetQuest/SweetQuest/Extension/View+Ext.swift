import SwiftUI

extension View {
    var isSmallScreen: Bool {
        UIScreen.main.bounds.height < 700
    }
    
    @ViewBuilder
    func hSpacing(_ alignment: Alignment) -> some View {
        self
            .frame(maxWidth: .infinity, alignment: alignment)
    }
    
    @ViewBuilder
    func vSpacing(_ alignment: Alignment) -> some View {
        self
            .frame(maxHeight: .infinity, alignment: alignment)
    }
    
    func cellStyle(color: Color = .white, radius: CGFloat = 32) -> some View {
        self
            .background(color)
            .clipShape(.rect(cornerRadius: radius))
            .overlay(RoundedRectangle(cornerRadius: radius).stroke(.accent, lineWidth: 4))
    }
    
    func columns(_ count: Int) -> [GridItem] {
        Array(repeating: GridItem(),count: count)
    }
    
    func detailScreenStyle() -> some View {
        self
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("Close") {
                        UIApplication.shared.endEditing()
                    }
                }
            }
            .toolbar(.hidden, for: .navigationBar)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .background(BackgroundImageView(imageName: "mainBG"))
    }
}
