import SwiftUI

struct BalooThambiText: View {
    var text: String
    var size: CGFloat
    var weight: Font.Weight
    
    init(_ text: String, size: CGFloat, weight: Font.Weight = .bold) {
        self.text = text
        self.size = size
        self.weight = weight
    }
    
    var body: some View {
        Text(text).font(.balooThambi(size, weight: weight))
    }
}
