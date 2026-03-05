import SwiftUI

struct SettingsView: View {
    @State private var isShowWeb = false
    @Environment(\.dismiss) var dismiss
    let url = "https://www.freeprivacypolicy.com/live/233df1a5-6d96-471d-88e3-7dbfae527d85"
    let title = "About the app"
    
    var body: some View {
        contentView
            .fullScreenCover(isPresented: $isShowWeb) {
                WebViewScreen(url: url)
                    .safeAreaInset(edge: .top) {
                        HStack {
                            Text(title)
                                .font(.headline)
                                .foregroundStyle(.black)
                            
                            Button(action: {isShowWeb.toggle()}) {
                                Image(systemName: "xmark.circle.fill")
                                    .imageScale(.large)
                                    .foregroundStyle(.black)
                            }
                            .hSpacing(.trailing)
                        }
                        .padding(.horizontal)
                    }
            }
            .detailScreenStyle()
    }
    
    private var contentView: some View {
        VStack {
            DetailHeaderView(title: "Settings") {
                dismiss.callAsFunction()
            }

            VStack(spacing: 10) {
                HStack(alignment: .center) {
                    BalooThambiText("Notification", size: 32)
                        .foregroundStyle(.black)
                        .hSpacing(.leading)
                    MyToggle()
                }
                
                BigButtonView(title: "Clear Data") {
                    ManagerService.shared.deleteAll()
                }
                
                BigButtonView(title: "About app") {
                    isShowWeb.toggle()
                }
            }
            .padding()
        }
    }
}

#Preview {
    SettingsView()
        .environmentObject(NotificationService.shared)
        .background(BackgroundImageView(imageName: "mainBG"))
}
