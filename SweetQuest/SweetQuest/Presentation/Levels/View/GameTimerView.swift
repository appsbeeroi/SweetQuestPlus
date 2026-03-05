import SwiftUI

struct GameTimerView: View {
    
    let time: TimeInterval
    
    var body: some View {
        HStack {
            Image(systemName: "clock.fill")
                .imageScale(.large)
                .foregroundStyle(.accent)
            
            BalooThambiText(timeString, size: 32)
                .foregroundColor(.accent)
        }
    }
    
    private var timeString: String {
        
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

#Preview {
    GameTimerView(time: 90)
}
