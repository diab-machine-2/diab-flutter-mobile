//
//  App Extension
//
//  Created by David on 2019/05/18.
//

import UIKit

extension UIColor {
    open class func colorFromHex(_ hex: Int) -> UIColor {
        return UIColor(red: CGFloat((hex & 0xFF0000) >> 16) / 255, green: CGFloat((hex & 0x00FF00) >> 8) / 255, blue: CGFloat(hex & 0x0000FF) / 255, alpha: 1)
    }
}
