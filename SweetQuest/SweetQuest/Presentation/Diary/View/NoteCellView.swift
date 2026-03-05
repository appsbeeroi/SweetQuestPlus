import SwiftUI

struct NoteCellView: View {
    var note: NoteValue
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            BalooThambiText(note.whatIAte, size: 32)
                .foregroundStyle(.accent)
            BalooThambiText(note.howMuch, size: 20,weight: .medium)
                .multilineTextAlignment(.leading)
            
            HStack {
                HStack(spacing: 6) {
                    BalooThambiText("Date:", size: 20)
                        .foregroundStyle(.accent)
                    BalooThambiText(note.when, size: 20)
                }
                
                HStack(spacing: 6) {
                    BalooThambiText("Mood:", size: 20)
                        .foregroundStyle(.accent)
                    BalooThambiText(note.mood.iconName, size: 20)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .cellStyle()
    }
}

#Preview {
    NoteCellView(note: NoteValue(whatIAte: "Chocolate", howMuch: "FGhdsgafgasf", when: "March 12"))
        .detailScreenStyle()
}
