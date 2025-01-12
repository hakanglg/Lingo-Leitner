import UIKit
final class LoadingButton: UIButton {
    enum Style {
        case primary
        case secondary
    }
    
    private let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.hidesWhenStopped = true
        indicator.color = .white
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()
    
    init(style: Style) {
        super.init(frame: .zero)
        setupUI(style: style)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI(style: Style) {
        layer.cornerRadius = 12
        titleLabel?.font = Theme.font(.headline)
        
        switch style {
        case .primary:
            backgroundColor = Theme.accent
            setTitleColor(.white, for: .normal)
        case .secondary:
            backgroundColor = .secondarySystemBackground
            setTitleColor(Theme.accent, for: .normal)
        }
        
        addSubview(activityIndicator)
        
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
    
    func startLoading() {
        isEnabled = false
        setTitle("", for: .normal)
        activityIndicator.startAnimating()
    }
    
    func stopLoading(withTitle title: String) {
        isEnabled = true
        setTitle(title, for: .normal)
        activityIndicator.stopAnimating()
    }
} 
