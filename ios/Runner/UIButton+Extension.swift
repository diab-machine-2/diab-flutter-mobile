//
//  App Extension
//
//  Created by David on 2019/05/18.
//
import Foundation
import UIKit

extension UIButton {
    @IBInspectable var localizedKey: String? {
        get {
            return nil
        }
        set {
            setTitle(newValue?.localized, for: .normal)
        }
    }
    
    open func setTitleColors(_ colors: [UIColor], for states: [UIControl.State]) {
        guard colors.count == states.count else { return }
        
        for i in 0 ..< colors.count {
            self.setTitleColor(colors[i], for: states[i])
        }
    }
    
    open func setImages(_ images: [UIImage?], for states: [UIControl.State]) {
        guard images.count == states.count else { return }
        
        for i in 0 ..< images.count {
            self.setImage(images[i], for: states[i])
        }
    }

    open func setBackgroundColor(_ color: UIColor, for state: UIControl.State) {
        UIGraphicsBeginImageContext(CGSize(width: 1.0, height: 1.0))
        guard let context = UIGraphicsGetCurrentContext() else { return }
        context.setFillColor(color.cgColor)
        context.fill(CGRect(x: 0.0, y: 0.0, width: 1.0, height: 1.0))

        let backgroundImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        self.setBackgroundImage(backgroundImage, for: state)
    }
}
