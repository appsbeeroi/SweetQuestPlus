import Foundation
import SwiftUI

extension Font {
    static func balooThambi(_ size: CGFloat, weight: Font.Weight = .bold) -> Font {
        switch weight {
        case .regular: custom("BalooThambi2-Regular", size: size)
        case .medium: custom("BalooThambi2-Medium", size: size)
        case .bold: custom("BalooThambi2-Bold", size: size)
        default: custom("BalooThambi2-Bold", size: size)
        }
    }
}
