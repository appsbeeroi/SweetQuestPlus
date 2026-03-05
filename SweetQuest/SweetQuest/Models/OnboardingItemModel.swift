import Foundation
import UIKit

enum OnboardingItemModel: String, CaseIterable, Identifiable {
    var id: Self { self }
    case first
    case second
}

extension OnboardingItemModel {
    
    var indicator: Int {
            return switch self {
            case .first:
                1
            case .second:
                2
            }
        }
    
    var image: String {
        switch self {
        case .first:
            "onboarding1"
        case .second:
            "onboarding2"
        }
    }
    

    var title: String {
        switch self {
        case .first:
            "Match Sweet Pairs"
        case .second:
            "Collect & Remember"
        }
    }
    
    var description: String {
        switch self {
        case .first:
            "Train your attention in a fun candy puzzle game. Flip the tiles, find matching sweets, and complete tasty challenges to unlock new levels."
        case .second:
            "Earn unique treats for every victory and build your personal candy collection. Keep a diary of your sweet moments and track your journey."
        }
    }
    
    var navigationTittle: String {
        switch self {
        case .first: "Next (1/2)"
        case .second: "Next (2/2)"
        }
    }
}

