import UIKit

extension UIButton {
    func configure(_ block: (UIButton) -> Void) -> UIButton {
        block(self)
        return self
    }
} 