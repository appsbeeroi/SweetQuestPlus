import SwiftUI

struct EmptyScreenView: View {
    var emptyText: EmptyText = .parking
    
    var body: some View {
        VStack(spacing: 10) {
            BalooThambiText(emptyText.title, size: 25)
                .foregroundStyle(.accent)
            
            VStack(spacing: 0) {
                BalooThambiText(emptyText.firstSubLine, size: 20)
                BalooThambiText(emptyText.secondSubLine, size: 20)
                BalooThambiText(emptyText.thirdSubLine, size: 20)
            }
            .foregroundStyle(.accent)
            .opacity(0.5)
            
        }
    }
}

#Preview {
    EmptyScreenView()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(BackgroundImageView(imageName: "mainBG"))
}


enum EmptyText {
    case parking, plan, routes, reminders
    
    var title: String {
        switch self {
        case .parking: "No parking records yet"
        case .plan: "No planned parking yet"
        case .routes: "No trips recorded yet"
        case .reminders: "No reminders set"
        }
    }
    
    var firstSubLine: String {
        switch self {
        case .parking: "Add your first parking spot to"
        case .plan: "Create a future parking entry to"
        case .routes: "Record key points of your routes"
        case .reminders: "Set reminders for parking or"
        }
    }
    
    var secondSubLine: String {
        switch self {
        case .parking: "keep track of where and when"
        case .plan: "organize your upcoming trips"
        case .routes: "and track your journeys here"
        case .reminders: "trips so you never forget"
        }
    }
    
    var thirdSubLine: String {
        switch self {
        case .parking: "you parked"
        default: ""
        }
    }
}
