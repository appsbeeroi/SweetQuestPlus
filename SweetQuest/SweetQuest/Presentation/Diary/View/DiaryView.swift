import SwiftUI

struct DiaryView: View {
    @StateObject private var viewModel = DiaryViewModel()
    
    var body: some View {
        contentView
            .onAppear {
                viewModel.fetchData()
            }
            .detailScreenStyle()
    }
    
    private var contentView: some View {
        VStack {
            MainHeaderView(title: "Diary")
            
            if viewModel.notes.isEmpty {
                BalooThambiText("Diary is Empty", size: 32)
                    .foregroundStyle(.accent)
                    .vSpacing(.center)
            } else {
                ScrollView {
                    LazyVStack {
                        ForEach(viewModel.notes) { note in
                            NoteCellView(note: note)
                        }
                    }
                }
                .scrollIndicators(.hidden)
            }
            
            NavigationLink {
                AddNewNoteView()
                    .environmentObject(viewModel)
            } label: {
                BalooThambiText("Add Note", size: isSmallScreen ? 26 : 32)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(8)
                    .background(.accent)
                    .clipShape(.capsule)
            }
            .padding(.bottom, 110)
        }
        .padding(.horizontal)
    }
}

#Preview {
    DiaryView()
}
