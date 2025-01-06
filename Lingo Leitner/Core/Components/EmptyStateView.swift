import UIKit

final class EmptyStateView: UIView {
    
    // MARK: - Properties
    private let imageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.tintColor = Theme.accent
        return iv
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = Theme.font(.title)
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    private let messageLabel: UILabel = {
        let label = UILabel()
        label.font = Theme.font(.body)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.textColor = .secondaryLabel
        return label
    }()
    
    // MARK: - Initialization
    init(image: UIImage?, title: String, message: String) {
        super.init(frame: .zero)
        
        imageView.image = image
        titleLabel.text = title
        messageLabel.text = message
        
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    private func setupUI() {
        [imageView, titleLabel, messageLabel].forEach {
            addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -40),
            imageView.widthAnchor.constraint(equalToConstant: 80),
            imageView.heightAnchor.constraint(equalToConstant: 80),
            
            titleLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: Theme.spacing(2)),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Theme.spacing(2)),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Theme.spacing(2)),
            
            messageLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: Theme.spacing()),
            messageLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Theme.spacing(2)),
            messageLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Theme.spacing(2))
        ])
    }
} 