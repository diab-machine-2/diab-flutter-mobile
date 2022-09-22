//
//  App Extension
//
//  Created by David on 2019/05/18.
//

import Foundation
import UIKit

public let DF_ANIMATE_DURATION: TimeInterval = 0.3     // base animation TimeInterval

extension UIApplication {
    static var topMostViewController: UIViewController? {
        let keyWindow = UIApplication.shared.windows.first{ $0.isKeyWindow }
        return keyWindow?.rootViewController?.visibleController
    }
}

extension UIViewController {
    // The visible view controller from a given view controller
    var visibleController: UIViewController? {
        if let navigationController = self as? UINavigationController {
            return navigationController.topViewController?.visibleController
        } else if let tabBarController = self as? UITabBarController {
            return tabBarController.selectedViewController?.visibleController
        } else if let presentedViewController = presentedViewController {
            return presentedViewController.visibleController
        } else {
            return self
        }
    }
    
    var allTopViewController : UIViewController? {
        let keyWindow = UIApplication.shared.windows.first{ $0.isKeyWindow }
        if var viewController = keyWindow!.rootViewController {
            while viewController.presentedViewController != nil {
                viewController = viewController.presentedViewController!
            }
            
            return viewController
        }
    
        return nil
    }

    func visibleClassName() -> String? {
        let root = UIApplication.shared.windows.first{ $0.isKeyWindow }?.rootViewController
        if let present = root?.visibleController {
            return String(describing: present.classForCoder)
        }

        return nil
    }
    
    open func getController(strName: String, strID: String) -> UIViewController {
        let storyboard = UIStoryboard(name: strName, bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: strID)
        controller.modalPresentationStyle = .overCurrentContext
        return controller
    }

    open func pushVC(strName: String, strID: String, bAni: Bool = true, bFromBottom: Bool = false) {
        let storyboard = UIStoryboard(name: strName, bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: strID)

        if (bFromBottom == true) {
            let transition = CATransition()
            transition.duration = 0.3
            transition.type = .moveIn
            transition.subtype = .fromTop
            transition.timingFunction = CAMediaTimingFunction(name:CAMediaTimingFunctionName.easeInEaseOut)

            self.navigationController?.view.layer.add(transition, forKey: kCATransition)
            self.navigationController?.pushViewController(controller, animated: false)
            return
        }

        self.navigationController?.pushViewController(controller, animated: bAni)
    }

    open func popVC(bFromBottom: Bool = false) {
        if (bFromBottom == true) {
            let transition = CATransition()
            transition.subtype = .fromBottom
            self.navigationController?.view.layer.add(transition, forKey: "popViewController")
            self.navigationController?.popViewController(animated: false)
        }

        self.navigationController?.popViewController(animated: false)
    }
    
    open func presentVC(strName: String, strID: String, bAni: Bool = false) {
        let storyboard = UIStoryboard(name: strName, bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: strID)
        controller.modalPresentationStyle = .overCurrentContext

        let transition = CATransition()
        transition.duration = DF_ANIMATE_DURATION
        transition.type = .fade
        transition.timingFunction = CAMediaTimingFunction(name:CAMediaTimingFunctionName.easeInEaseOut)
        let keyWindow = UIApplication.shared.windows.first{ $0.isKeyWindow }
        keyWindow?.layer.add(transition, forKey: kCATransition)
        self.present(controller, animated: bAni, completion: nil)
    }
    
    
    func hideKeyboardWhenTappedAround() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
        
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}
