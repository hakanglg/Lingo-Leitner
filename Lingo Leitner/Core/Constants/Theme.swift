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
    
    // MARK: - Shadows
    static func applyShadow(to view: UIView, opacity: Float = 0.15, radius: CGFloat = 10) {
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 4)
        view.layer.shadowRadius = radius
        view.layer.shadowOpacity = opacity
    }
    
    // MARK: - Fonts
    enum FontStyle {
        case largeTitle
        case title
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
            case .title: return 24
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
    
    static func font(_ style: FontStyle, _ weight: UIFont.Weight = .regular) -> UIFont {
        return .systemFont(ofSize: style.size, weight: weight)
    }
    
    // MARK: - Spacing
    static func spacing(_ multiplier: CGFloat = 1) -> CGFloat {
        return UIScreen.main.bounds.width * 0.024 * multiplier
    }
    
    // MARK: - Corner Radius
    static let cornerRadius: CGFloat = 12
    static let buttonHeight: CGFloat = 56
} 
