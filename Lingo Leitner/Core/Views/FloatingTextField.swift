import UIKit

final class FloatingTextField: UITextField {
    
    // MARK: - Properties
    private let padding = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
    private let placeholderLabel = UILabel()
    
    var cornerRadius: CGFloat = 0 {
        didSet {
            layer.cornerRadius = cornerRadius
            layer.masksToBounds = cornerRadius > 0
        }
    }
    
    override var placeholder: String? {
        didSet {
            placeholderLabel.text = placeholder
            super.placeholder = nil
        }
    }
    
    override var text: String? {
        didSet {
            updatePlaceholderPosition()
        }
    }
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    // MARK: - Setup
    private func setupUI() {
        borderStyle = .none
        backgroundColor = Theme.secondary
        
        placeholderLabel.font = Theme.font(.subheadline)
        placeholderLabel.textColor = .placeholderText
        placeholderLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(placeholderLabel)
        
        NSLayoutConstraint.activate([
            placeholderLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            placeholderLabel.topAnchor.constraint(equalTo: topAnchor, constant: 8)
        ])
        
        addTarget(self, action: #selector(textFieldDidBeginEditing), for: .editingDidBegin)
        addTarget(self, action: #selector(textFieldDidEndEditing), for: .editingDidEnd)
    }
    
    // MARK: - Layout
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        bounds.inset(by: padding)
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        bounds.inset(by: padding)
    }
    
    override func rightViewRect(forBounds bounds: CGRect) -> CGRect {
        var rect = super.rightViewRect(forBounds: bounds)
        rect.origin.x -= 8
        return rect
    }
    
    // MARK: - Animations
    @objc private func textFieldDidBeginEditing() {
        if text?.isEmpty ?? true {
            animatePlaceholder(isUp: true)
        }
    }
    
    @objc private func textFieldDidEndEditing() {
        if text?.isEmpty ?? true {
            animatePlaceholder(isUp: false)
        }
    }
    
    private func updatePlaceholderPosition() {
        if !(text?.isEmpty ?? true) {
            placeholderLabel.transform = CGAffineTransform(translationX: 0, y: -8)
            placeholderLabel.font = Theme.font(.caption2)
            placeholderLabel.textColor = Theme.gradient[0]
        } else {
            placeholderLabel.transform = .identity
            placeholderLabel.font = Theme.font(.subheadline)
            placeholderLabel.textColor = .placeholderText
        }
    }
    
    private func animatePlaceholder(isUp: Bool) {
        let transform = isUp ? CGAffineTransform(translationX: 0, y: -8) : .identity
        let font = isUp ? Theme.font(.caption2) : Theme.font(.subheadline)
        let color: UIColor = isUp ? Theme.gradient[0] : .placeholderText
        
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseOut) {
            self.placeholderLabel.transform = transform
            self.placeholderLabel.font = font
            self.placeholderLabel.textColor = color
        }
    }
} 