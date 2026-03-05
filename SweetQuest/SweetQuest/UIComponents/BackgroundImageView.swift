import Foundation
import SwiftUI

struct BackgroundImageView: View {
    var imageName: String
    
    var body: some View {
        GeometryReader { geometry in
            Image(imageName)
                .resizable()
                .scaledToFill()
                .frame(width: geometry.size.width, height: geometry.size.height)
                .clipped()
                .ignoresSafeArea(.all, edges: .all)
        }
        .ignoresSafeArea(.all, edges: .all)
    }
}
