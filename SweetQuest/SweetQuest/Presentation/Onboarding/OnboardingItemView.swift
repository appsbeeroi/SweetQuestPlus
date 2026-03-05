import SwiftUI

struct OnboardingItemView: View {
    var item: OnboardingItemModel
    var action: () -> Void
    
    var body: some View {
        VStack(spacing: 24) {
            VStack(spacing: 0) {
                onboardTittle
                onboardingDescription
            }
            .padding()
            .cellStyle()
            
            navigationButton
        }
        .padding(.horizontal)
        .frame(maxHeight: .infinity, alignment: .bottom)
        .background(BackgroundImageView(imageName: item.image))
    }
    
    private var onboardTittle: some View {
        BalooThambiText(item.title.uppercased(), size: isSmallScreen ? 26 : 32)
            .foregroundStyle(.accent)
            .multilineTextAlignment(.center)
            .hSpacing(.leading)
    }
    
    private var onboardingDescription: some View {
        BalooThambiText(item.description, size: isSmallScreen ? 16 : 20, weight: .medium)
            .multilineTextAlignment(.leading)
            .hSpacing(.leading)
            .foregroundStyle(.black)
    }
    
    private var navigationButton: some View {
        BigButtonView(title: item.navigationTittle, action: action)
    }
}


#Preview {
    OnboardingItemView(item: .second, action: {})
}
