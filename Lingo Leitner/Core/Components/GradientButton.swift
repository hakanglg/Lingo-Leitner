import UIKit

final class GradientButton: UIButton {
    
    // MARK: - Properties
    private let gradientLayer: CAGradientLayer = {
        let layer = CAGradientLayer()
        layer.colors = Theme.gradient.map { $0.cgColor }
        layer.startPoint = CGPoint(x: 0, y: 0)
        layer.endPoint = CGPoint(x: 1, y: 1)
        return layer
    }()
    
    // MARK: - Initialization
    init(title: String) {
        super.init(frame: .zero)
        configure(with: title)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = bounds
        
        // Animasyonu sadece bir kez ekleyelim
        if gradientLayer.animation(forKey: "gradientAnimation") == nil {
            let animation = CABasicAnimation(keyPath: "colors")
            animation.fromValue = Theme.gradient.map { $0.cgColor }
            animation.toValue = Theme.gradient.reversed().map { $0.cgColor }
            animation.duration = 3.0
            animation.autoreverses = true
            animation.repeatCount = .infinity
            gradientLayer.add(animation, forKey: "gradientAnimation")
        }
    }
    
    // MARK: - Configuration
    private func configure(with title: String) {
        setTitle(title, for: .normal)
        titleLabel?.font = Theme.font(.button, .semibold)
        setTitleColor(.white, for: .normal)
        
        layer.cornerRadius = 25
        layer.masksToBounds = true
        
        layer.insertSublayer(gradientLayer, at: 0)
        
        // Gölge efekti
        layer.shadowColor = Theme.gradient[0].cgColor
        layer.shadowOffset = CGSize(width: 0, height: 4)
        layer.shadowRadius = 8
        layer.shadowOpacity = 0.3
        
        // Dokunma efektleri için hedefler ekleyelim
        addTarget(self, action: #selector(touchDown), for: .touchDown)
        addTarget(self, action: #selector(touchUp), for: [.touchUpInside, .touchUpOutside, .touchCancel])
    }
    
    // MARK: - Touch Handlers
    @objc private func touchDown() {
        UIView.animate(withDuration: 0.2, delay: 0, options: [.curveEaseOut], animations: {
            self.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
            self.layer.shadowOpacity = 0.2
        })
    }
    
    @objc private func touchUp() {
        UIView.animate(withDuration: 0.2, delay: 0, options: [.curveEaseOut], animations: {
            self.transform = .identity
            self.layer.shadowOpacity = 0.3
        })
    }
    
    // MARK: - Public Methods
    func updateTitle(_ title: String) {
        setTitle(title, for: .normal)
    }
} 