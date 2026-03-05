import SwiftUI

struct AddNewNoteView: View {
    @State private var note = NoteValue()
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var viewModel: DiaryViewModel
    
    @FocusState var isAteFocused
    @FocusState var isMuchFocused
    @FocusState var isWhenFocused
    
    var body: some View {
        contentView
            .overlay(alignment: .bottom) {
                Button(action: addAction) {
                    BalooThambiText("Add Note", size: 32)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(8)
                        .background(.accent)
                        .opacity(isDisabled() ? 0.4 : 1)
                        .clipShape(.capsule)
                }
                .disabled(isDisabled())
                .padding(.horizontal, 32)
                .frame(maxHeight: .infinity, alignment: .bottom)
                .ignoresSafeArea(.keyboard)
            }
            .detailScreenStyle()
    }
    
    private var contentView: some View {
        VStack {
            DetailHeaderView(title: "Add Note") {
                dismiss.callAsFunction()
            }
            
            ScrollView {
                formView
            }
            .scrollIndicators(.hidden)
            .scrollDismissesKeyboard(.immediately)
        }
    }
    
    private var formView: some View {
        VStack(spacing: 16) {
            BalooThambiField(title: "What I Ate", text: $note.whatIAte, isFocused: $isAteFocused)
            BalooThambiField(title: "How Much", text: $note.howMuch, isFocused: $isMuchFocused)
            BalooThambiField(title: "When", text: $note.when, isFocused: $isWhenFocused)
            
            VStack(spacing: 0) {
                BalooThambiText("Mood", size: 18)
                    .foregroundStyle(.accent)
                    .hSpacing(.leading)
                
                HStack(spacing: 20) {
                    ForEach(NoteMood.allCases) { mood in
                        let isSelect = note.mood == mood
                        Button {
                            withAnimation {
                                note.mood = mood
                            }
                        } label: {
                            Text(mood.iconName)
                                .font(.system(size: 32))
                                .padding()
                                .background(isSelect ? .accent : .white, in: .circle)
                                .overlay {
                                    Circle()
                                        .stroke(.accent, lineWidth: 4)
                                }
                        }
                    }
                }
            }
        }
        .padding(.horizontal, 32)
    }
    
    private func addAction() {
        viewModel.addNew(note)
        dismiss.callAsFunction()
    }
    
    private func isDisabled() -> Bool {
        note.howMuch.isEmpty
        || note.whatIAte.isEmpty
        || note.when.isEmpty
    }
}

#Preview {
    AddNewNoteView()
        .environmentObject(DiaryViewModel())
}
