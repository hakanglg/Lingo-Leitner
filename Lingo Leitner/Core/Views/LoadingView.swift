import UIKit

final class LoadingView {
    static let shared = LoadingView()
    private var isShowing = false
    private var currentView: UIView?
    private var containerView: UIView?
    
    private init() {}
    
    func show(in view: UIView) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            // Eğer aynı view'da zaten gösteriliyorsa, tekrar gösterme
            if self.isShowing && self.currentView == view {
                return
            }
            
            // Farklı bir view'da gösteriliyorsa, önce onu kaldır
            if self.isShowing {
                self.hide()
            }
            
            self.isShowing = true
            self.currentView = view
            
            // Container view
            let container = UIView()
            container.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(container)
            self.containerView = container
            
            // Activity indicator
            let indicator = UIActivityIndicatorView(style: .medium)
            indicator.hidesWhenStopped = true
            indicator.translatesAutoresizingMaskIntoConstraints = false
            container.addSubview(indicator)
            
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
        }
    }
    
    func hide() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self, self.isShowing else { return }
            
            self.containerView?.removeFromSuperview()
            self.containerView = nil
            self.isShowing = false
            self.currentView = nil
        }
    }
} 
