import UIKit

final class LoadingView {
    static let shared = LoadingView()
    private var activityIndicator: UIActivityIndicatorView?
    private var containerView: UIView?
    private init() {}
    
    func show(in view: UIView, message: String? = nil) {
        DispatchQueue.main.async { [weak self] in
            // Container view
            let container = UIView()
            container.backgroundColor = .clear
            container.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(container)
            
            // Activity indicator
            let indicator = UIActivityIndicatorView(style: .medium)
            indicator.hidesWhenStopped = true
            indicator.translatesAutoresizingMaskIntoConstraints = false
            container.addSubview(indicator)
            
            
            // Message label (if provided)
            if let message = message {
                let label = UILabel()
                label.text = message
                label.textColor = Theme.accent
                label.font = .systemFont(ofSize: 16, weight: .medium)
                label.translatesAutoresizingMaskIntoConstraints = false
                container.addSubview(label)
                
                NSLayoutConstraint.activate([
                    label.centerXAnchor.constraint(equalTo: container.centerXAnchor),
                    label.topAnchor.constraint(equalTo: indicator.bottomAnchor, constant: 16)
                ])
            }
            
            // Constraints
            NSLayoutConstraint.activate([
                container.topAnchor.constraint(equalTo: view.topAnchor),
                container.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                container.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                container.bottomAnchor.constraint(equalTo: view.bottomAnchor),
                
                indicator.centerXAnchor.constraint(equalTo: container.centerXAnchor),
                indicator.centerYAnchor.constraint(equalTo: container.centerYAnchor)
            ])
            
            indicator.startAnimating()
            
            self?.activityIndicator = indicator
            self?.containerView = container
        }
    }
    
    func hide() {
        DispatchQueue.main.async { [weak self] in
            self?.activityIndicator?.stopAnimating()
            self?.containerView?.removeFromSuperview()
            self?.activityIndicator = nil
            self?.containerView = nil
        }
    }
} 
