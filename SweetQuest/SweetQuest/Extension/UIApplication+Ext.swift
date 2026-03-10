import Foundation
import UIKit

extension UIApplication {
    func endEditing() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    
    static var topViewController: UIViewController? {
        guard let scene = shared.connectedScenes.first as? UIWindowScene,
              let root = scene.keyWindow?.rootViewController else { return nil }
        return findTop(from: root)
    }
    
    private static func findTop(from vc: UIViewController) -> UIViewController {
        if let nav = vc as? UINavigationController, let visible = nav.visibleViewController {
            return findTop(from: visible)
        }
        if let tab = vc as? UITabBarController, let selected = tab.selectedViewController {
            return findTop(from: selected)
        }
        if let presented = vc.presentedViewController {
            return findTop(from: presented)
        }
        return vc
    }
}
