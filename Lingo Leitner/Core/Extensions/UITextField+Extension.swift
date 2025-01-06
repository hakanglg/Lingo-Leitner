import UIKit

extension UITextField {
    func setLeftPadding(_ amount: CGFloat) {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: frame.height))
        leftView = paddingView
        leftViewMode = .always
    }
    
    func setRightPadding(_ amount: CGFloat) {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: frame.height))
        rightView = paddingView
        rightViewMode = .always
    }
    
    func style() {
        setLeftPadding(16)
        setRightPadding(16)
        backgroundColor = Theme.secondary
        layer.cornerRadius = Theme.cornerRadius
        font = Theme.font(.body)
        tintColor = Theme.gradient[0]
    }
} 