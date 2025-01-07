import UIKit

final class BoxCell: UICollectionViewCell {
    static let reuseIdentifier = "BoxCell"
    
    // MARK: - UI Components
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
        view.layer.cornerRadius = 20
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 6)
        view.layer.shadowRadius = 12
        view.layer.shadowOpacity = 0.1
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 12
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private let boxIconView: UIImageView = {
        let config = UIImage.SymbolConfiguration(pointSize: 36, weight: .medium)
        let image = UIImage(systemName: "square.stack.3d.up.fill", withConfiguration: config)
        let imageView = UIImageView(image: image)
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let boxLabel: UILabel = {
        let label = UILabel()
        label.font = Theme.font(.title2, .bold)
        label.textAlignment = .center
        return label
    }()
    
    private let countLabel: UILabel = {
        let label = UILabel()
        label.font = Theme.font(.headline)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        return label
    }()
    
    private let reviewTimeLabel: UILabel = {
        let label = UILabel()
        label.font = Theme.font(.subheadline)
        label.textColor = .tertiaryLabel
        label.textAlignment = .center
        return label
    }()
    
    private let gradientLayer = CAGradientLayer()
    
    private let reviewBadge: UIView = {
        let view = UIView()
        view.backgroundColor = .systemRed
        view.layer.cornerRadius = 10
        view.isHidden = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let reviewCountLabel: UILabel = {
        let label = UILabel()
        label.font = Theme.font(.caption1, .bold)
        label.textColor = .white
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // MARK: - Properties
    private let reviewTimes = [
        "Her gün",
        "2 günde bir",
        "4 günde bir",
        "1 haftada bir",
        "2 haftada bir"
    ]
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupGradient()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = containerView.bounds
    }
    
    // MARK: - Setup
    private func setupUI() {
        contentView.addSubview(containerView)
        containerView.addSubview(stackView)
        
        stackView.addArrangedSubview(boxIconView)
        stackView.addArrangedSubview(boxLabel)
        stackView.addArrangedSubview(countLabel)
        stackView.addArrangedSubview(reviewTimeLabel)
        
        containerView.addSubview(reviewBadge)
        reviewBadge.addSubview(reviewCountLabel)
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            stackView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 20),
            stackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            stackView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -20),
            
            boxIconView.heightAnchor.constraint(equalToConstant: 40),
            
            reviewBadge.topAnchor.constraint(equalTo: containerView.topAnchor, constant: -8),
            reviewBadge.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: 8),
            reviewBadge.widthAnchor.constraint(equalToConstant: 20),
            reviewBadge.heightAnchor.constraint(equalToConstant: 20),
            
            reviewCountLabel.centerXAnchor.constraint(equalTo: reviewBadge.centerXAnchor),
            reviewCountLabel.centerYAnchor.constraint(equalTo: reviewBadge.centerYAnchor)
        ])
    }
    
    private func setupGradient() {
        gradientLayer.cornerRadius = 20
        containerView.layer.insertSublayer(gradientLayer, at: 0)
    }
    
    func configure(boxNumber: Int, wordCount: Int, reviewCount: Int) {
        boxLabel.text = "Kutu \(boxNumber)"
        countLabel.text = "\(wordCount) Kelime"
        reviewTimeLabel.text = reviewTimes[boxNumber - 1]
        
        let colors: [UIColor] = [
            .systemGreen,
            .systemBlue,
            .systemIndigo,
            .systemPurple,
            .systemPink
        ]
        let color = colors[boxNumber - 1]
        
        boxIconView.tintColor = color
        boxLabel.textColor = color
        
        gradientLayer.colors = [
            color.withAlphaComponent(0.1).cgColor,
            color.withAlphaComponent(0.05).cgColor
        ]
        gradientLayer.locations = [0.0, 1.0]
        
        containerView.layer.borderColor = color.withAlphaComponent(0.3).cgColor
        containerView.layer.borderWidth = 2
        
        reviewBadge.isHidden = reviewCount == 0
        reviewCountLabel.text = "\(reviewCount)"
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        UIView.animate(withDuration: 0.2) {
            self.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        UIView.animate(withDuration: 0.2) {
            self.transform = .identity
        }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        UIView.animate(withDuration: 0.2) {
            self.transform = .identity
        }
    }
} 
