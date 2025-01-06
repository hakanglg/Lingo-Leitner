import UIKit

final class OnboardingCell: UICollectionViewCell {
    static let identifier = "OnboardingCell"
    
    // MARK: - Properties
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = Theme.secondary
        view.layer.cornerRadius = 20
        return view
    }()
    
    private let imageContainer: UIView = {
        let view = UIView()
        view.backgroundColor = Theme.accent.withAlphaComponent(0.1)
        view.layer.cornerRadius = 40
        return view
    }()
    
    private let imageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.tintColor = Theme.accent
        return iv
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = Theme.font(.largeTitle)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.textColor = .label
        return label
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = Theme.font(.body)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.textColor = .secondaryLabel
        return label
    }()
    
    // MARK: - Lifecycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Helpers
    private func setupUI() {
        backgroundColor = .clear
        
        // Container view'a gölge ve blur efekti ekleyelim
        containerView.layer.cornerRadius = 24
        containerView.layer.shadowColor = UIColor.black.cgColor
        containerView.layer.shadowOffset = CGSize(width: 0, height: 8)
        containerView.layer.shadowRadius = 16
        containerView.layer.shadowOpacity = 0.1
        
        if !UIAccessibility.isReduceTransparencyEnabled {
            let blurEffect = UIBlurEffect(style: .systemThinMaterial)
            let blurView = UIVisualEffectView(effect: blurEffect)
            blurView.frame = containerView.bounds
            blurView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            containerView.addSubview(blurView)
        }
        
        addSubview(containerView)
        containerView.addSubview(imageContainer)
        imageContainer.addSubview(imageView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(descriptionLabel)
        
        containerView.translatesAutoresizingMaskIntoConstraints = false
        imageContainer.translatesAutoresizingMaskIntoConstraints = false
        imageView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            containerView.centerYAnchor.constraint(equalTo: centerYAnchor),
            containerView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Theme.spacing(2)),
            containerView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Theme.spacing(2)),
            
            imageContainer.topAnchor.constraint(equalTo: containerView.topAnchor, constant: Theme.spacing(4)),
            imageContainer.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            imageContainer.widthAnchor.constraint(equalToConstant: 160),
            imageContainer.heightAnchor.constraint(equalToConstant: 160),
            
            imageView.centerXAnchor.constraint(equalTo: imageContainer.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: imageContainer.centerYAnchor),
            imageView.widthAnchor.constraint(equalToConstant: 80),
            imageView.heightAnchor.constraint(equalToConstant: 80),
            
            titleLabel.topAnchor.constraint(equalTo: imageContainer.bottomAnchor, constant: Theme.spacing(3)),
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: Theme.spacing(2)),
            titleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -Theme.spacing(2)),
            
            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: Theme.spacing(2)),
            descriptionLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: Theme.spacing(2)),
            descriptionLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -Theme.spacing(2)),
            descriptionLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -Theme.spacing(4))
        ])
    }
    
    func configure(with slide: OnboardingSlide) {
        imageView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        titleLabel.transform = CGAffineTransform(translationX: 0, y: 20)
        titleLabel.alpha = 0
        descriptionLabel.transform = CGAffineTransform(translationX: 0, y: 20)
        descriptionLabel.alpha = 0
        
        imageView.image = slide.image
        titleLabel.text = slide.title
        descriptionLabel.text = slide.description
        
        UIView.animate(withDuration: 0.4, delay: 0, options: .curveEaseOut) {
            self.imageView.transform = .identity
            self.titleLabel.transform = .identity
            self.titleLabel.alpha = 1
            self.descriptionLabel.transform = .identity
            self.descriptionLabel.alpha = 1
        }
    }
} 