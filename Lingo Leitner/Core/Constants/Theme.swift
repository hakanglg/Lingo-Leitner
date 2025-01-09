import UIKit

enum Theme {
    // MARK: - Colors
    static let primary = UIColor.systemBackground
    static let secondary = UIColor.secondarySystemBackground
    static let accent = UIColor(red: 0.23, green: 0.49, blue: 0.98, alpha: 1.0)
    
    static let gradient = [
        UIColor(red: 0.23, green: 0.49, blue: 0.98, alpha: 1.0),
        UIColor(red: 0.42, green: 0.36, blue: 0.91, alpha: 1.0)
    ]
    
    // MARK: - Layout
    static let buttonHeight: CGFloat = 56
    static let cornerRadius: CGFloat = 12
    
    // MARK: - Font Styles
    enum FontStyle {
        case largeTitle
        case title1
        case title2
        case title3
        case headline
        case body
        case callout
        case subheadline
        case footnote
        case caption1
        case caption2
        case button
        
        var size: CGFloat {
            switch self {
            case .largeTitle: return 34
            case .title1: return 28
            case .title2: return 22
            case .title3: return 20
            case .headline: return 17
            case .body: return 17
            case .callout: return 16
            case .subheadline: return 15
            case .footnote: return 13
            case .caption1: return 12
            case .caption2: return 11
            case .button: return 16
            }
        }
    }
    
    // MARK: - Font Weights
    enum FontWeight {
        case regular
        case medium
        case semibold
        case bold
        
        var weight: UIFont.Weight {
            switch self {
            case .regular: return .regular
            case .medium: return .medium
            case .semibold: return .semibold
            case .bold: return .bold
            }
        }
    }
    
    // MARK: - Font Helper
    static func font(_ style: FontStyle, _ weight: FontWeight = .regular) -> UIFont {
        return .systemFont(ofSize: style.size, weight: weight.weight)
    }
    
    // MARK: - Spacing
    static func spacing(_ multiplier: CGFloat = 1) -> CGFloat {
        return UIScreen.main.bounds.width * 0.024 * multiplier
    }
    
    // MARK: - Shadows
    static func applyShadow(to view: UIView, opacity: Float = 0.1, radius: CGFloat = 8, offset: CGSize = CGSize(width: 0, height: 4)) {
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = offset
        view.layer.shadowRadius = radius
        view.layer.shadowOpacity = opacity
    }
    
    // MARK: - Animations
    static func springAnimation(duration: TimeInterval = 0.5, delay: TimeInterval = 0, damping: CGFloat = 0.8, velocity: CGFloat = 0.5, animations: @escaping () -> Void, completion: (() -> Void)? = nil) {
        UIView.animate(
            withDuration: duration,
            delay: delay,
            usingSpringWithDamping: damping,
            initialSpringVelocity: velocity,
            options: .curveEaseInOut,
            animations: animations,
            completion: { _ in completion?() }
        )
    }
    
    // MARK: - Button Styles
    static func styleFilledButton(_ button: UIButton) {
        button.backgroundColor = accent
        button.tintColor = .white
        button.layer.cornerRadius = cornerRadius
        button.titleLabel?.font = font(.button, .medium)
    }
    
    static func styleOutlinedButton(_ button: UIButton) {
        button.backgroundColor = .clear
        button.tintColor = accent
        button.layer.cornerRadius = cornerRadius
        button.layer.borderWidth = 1
        button.layer.borderColor = accent.cgColor
        button.titleLabel?.font = font(.button, .medium)
    }
    
    // MARK: - TextField Styles
    static func styleTextField(_ textField: UITextField) {
        textField.backgroundColor = secondary
        textField.layer.cornerRadius = cornerRadius
        textField.font = font(.body)
        textField.borderStyle = .none
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: textField.frame.height))
        textField.leftView = paddingView
        textField.leftViewMode = .always
    }
} 