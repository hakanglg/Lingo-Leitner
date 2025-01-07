import UIKit

final class SuccessView: UIView {
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
        view.layer.cornerRadius = 20
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 4)
        view.layer.shadowRadius = 12
        view.layer.shadowOpacity = 0.1
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let checkmarkView: UIImageView = {
        let config = UIImage.SymbolConfiguration(pointSize: 60, weight: .bold)
        let image = UIImage(systemName: "checkmark.circle.fill", withConfiguration: config)
        let imageView = UIImageView(image: image)
        imageView.tintColor = Theme.accent
        imageView.alpha = 0
        imageView.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Başarılı!"
        label.font = Theme.font(.title2, .bold)
        label.textAlignment = .center
        label.alpha = 0
        label.transform = CGAffineTransform(rotationAngle: 20)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let messageLabel: UILabel = {
        let label = UILabel()
        label.text = "Kelime başarıyla eklendi"
        label.font = Theme.font(.body)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        label.alpha = 0
        label.transform = CGAffineTransform(rotationAngle: 20)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        backgroundColor = .clear
        
        addSubview(containerView)
        containerView.addSubview(checkmarkView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(messageLabel)
        
        NSLayoutConstraint.activate([
            containerView.centerXAnchor.constraint(equalTo: centerXAnchor),
            containerView.centerYAnchor.constraint(equalTo: centerYAnchor),
            containerView.widthAnchor.constraint(equalToConstant: 280),
            containerView.heightAnchor.constraint(equalToConstant: 200),
            
            checkmarkView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            checkmarkView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 24),
            
            titleLabel.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            titleLabel.topAnchor.constraint(equalTo: checkmarkView.bottomAnchor, constant: 16),
            
            messageLabel.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            messageLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            messageLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            messageLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16)
        ])
    }
    
    func animate(completion: (() -> Void)? = nil) {
        // Container view başlangıç durumu
        containerView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        containerView.alpha = 0
        
        // Animasyonlar
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.5) {
            self.containerView.transform = .identity
            self.containerView.alpha = 1
        }
        
        UIView.animate(withDuration: 0.6, delay: 0.2, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.5) {
            self.checkmarkView.transform = .identity
            self.checkmarkView.alpha = 1
        }
        
        UIView.animate(withDuration: 0.5, delay: 0.4) {
            self.titleLabel.transform = .identity
            self.titleLabel.alpha = 1
        }
        
        UIView.animate(withDuration: 0.5, delay: 0.5) {
            self.messageLabel.transform = .identity
            self.messageLabel.alpha = 1
        } completion: { _ in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                completion?()
            }
        }
    }
} 
