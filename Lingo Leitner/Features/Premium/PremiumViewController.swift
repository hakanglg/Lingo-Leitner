import UIKit

final class PremiumViewController: UIViewController {
    
    // MARK: - Properties
    private let scrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.showsVerticalScrollIndicator = false
        return sv
    }()
    
    private let containerView = UIView()
    
    private let closeButton: UIButton = {
        let button = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: 28, weight: .medium)
        let image = UIImage(systemName: "xmark.circle.fill", withConfiguration: config)
        button.setImage(image, for: .normal)
        button.tintColor = .secondaryLabel
        
        button.contentEdgeInsets = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
        return button
    }()
    
    private let headerImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.image = UIImage(systemName: "crown.fill")
        iv.tintColor = Theme.gradient[0]
        return iv
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Premium'a Yükseltin"
        label.font = Theme.font(.largeTitle)
        label.textAlignment = .center
        return label
    }()
    
    private let featuresStackView: UIStackView = {
        let sv = UIStackView()
        sv.axis = .vertical
        sv.spacing = Theme.spacing(2)
        return sv
    }()
    
    private let trialLabel: UILabel = {
        let label = UILabel()
        label.text = "1 Hafta Ücretsiz Deneyin"
        label.font = Theme.font(.title1)
        label.textAlignment = .center
        label.textColor = Theme.gradient[0]
        return label
    }()
    
    private let subscribeButton: GradientButton = {
        let button = GradientButton(title: "Şimdi Başla")
        return button
    }()
    
    private let priceLabel: UILabel = {
        let label = UILabel()
        label.text = "Daha sonra ayda sadece ₺29.99"
        label.font = Theme.font(.body)
        label.textAlignment = .center
        label.textColor = .secondaryLabel
        return label
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupActions()
        addFeatures()
    }
    
    // MARK: - Setup
    private func setupUI() {
        view.backgroundColor = Theme.primary
        modalPresentationStyle = .fullScreen
        
        [scrollView].forEach {
            view.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        scrollView.addSubview(containerView)
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        [closeButton, headerImageView, titleLabel, featuresStackView,
         trialLabel, subscribeButton, priceLabel].forEach {
            containerView.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            containerView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            containerView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            containerView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            closeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: Theme.spacing(1)),
            closeButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Theme.spacing(1)),
            closeButton.widthAnchor.constraint(equalToConstant: 52),
            closeButton.heightAnchor.constraint(equalToConstant: 52),
            
            headerImageView.topAnchor.constraint(equalTo: closeButton.bottomAnchor, constant: Theme.spacing(2)),
            headerImageView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            headerImageView.widthAnchor.constraint(equalToConstant: 80),
            headerImageView.heightAnchor.constraint(equalToConstant: 80),
            
            titleLabel.topAnchor.constraint(equalTo: headerImageView.bottomAnchor, constant: Theme.spacing(2)),
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: Theme.spacing(2)),
            titleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -Theme.spacing(2)),
            
            featuresStackView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: Theme.spacing(4)),
            featuresStackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: Theme.spacing(2)),
            featuresStackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -Theme.spacing(2)),
            
            trialLabel.topAnchor.constraint(equalTo: featuresStackView.bottomAnchor, constant: Theme.spacing(4)),
            trialLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: Theme.spacing(2)),
            trialLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -Theme.spacing(2)),
            
            subscribeButton.topAnchor.constraint(equalTo: trialLabel.bottomAnchor, constant: Theme.spacing(2)),
            subscribeButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: Theme.spacing(2)),
            subscribeButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -Theme.spacing(2)),
            subscribeButton.heightAnchor.constraint(equalToConstant: 56),
            
            priceLabel.topAnchor.constraint(equalTo: subscribeButton.bottomAnchor, constant: Theme.spacing(2)),
            priceLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: Theme.spacing(2)),
            priceLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -Theme.spacing(2)),
            priceLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -Theme.spacing(4))
        ])
        
        closeButton.addTarget(self, action: #selector(handleCloseTouchDown), for: .touchDown)
        closeButton.addTarget(self, action: #selector(handleCloseTouchUp), for: [.touchUpInside, .touchUpOutside, .touchCancel])
    }
    
    private func addFeatures() {
        let features = [
            ("infinity.circle.fill", "Sınırsız Kelime Kartı", "İstediğiniz kadar kelime ekleyin"),
            ("wand.and.stars", "Reklamsız Deneyim", "Kesintisiz öğrenme deneyimi"),
            ("camera.viewfinder", "OCR ile Kelime Tarama", "Fotoğraftan kelime aktarın"),
            ("chart.bar.fill", "Gelişmiş İstatistikler", "Detaylı öğrenme analizi"),
            ("paintbrush.fill", "Özel Temalar", "Kişiselleştirilmiş görünüm")
        ]
        
        features.forEach { feature in
            let view = createFeatureView(
                icon: feature.0,
                title: feature.1,
                description: feature.2
            )
            featuresStackView.addArrangedSubview(view)
        }
    }
    
    private func createFeatureView(icon: String, title: String, description: String) -> UIView {
        let container = UIView()
        
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = Theme.gradient[0]
        
        let config = UIImage.SymbolConfiguration(pointSize: 24, weight: .medium)
        imageView.image = UIImage(systemName: icon, withConfiguration: config)
        
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = Theme.font(.title3)
        
        let descriptionLabel = UILabel()
        descriptionLabel.text = description
        descriptionLabel.font = Theme.font(.body)
        descriptionLabel.textColor = .secondaryLabel
        
        [imageView, titleLabel, descriptionLabel].forEach {
            container.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: Theme.spacing(2)),
            imageView.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            imageView.widthAnchor.constraint(equalToConstant: 32),
            imageView.heightAnchor.constraint(equalToConstant: 32),
            
            titleLabel.leadingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: Theme.spacing(2)),
            titleLabel.topAnchor.constraint(equalTo: container.topAnchor, constant: Theme.spacing(2)),
            titleLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            
            descriptionLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            descriptionLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            descriptionLabel.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -Theme.spacing(1))
        ])
        
        return container
    }
    
    private func setupActions() {
        closeButton.addTarget(self, action: #selector(handleCloseTap), for: .touchUpInside)
        subscribeButton.addTarget(self, action: #selector(handleSubscribeTap), for: .touchUpInside)
    }
    
    // MARK: - Actions
    @objc private func handleCloseTap() {
        print("Kapat butonuna basıldı")
        dismiss(animated: true) {
            // Ana tab bar'a geçiş yap
            if let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate {
                sceneDelegate.window?.rootViewController = MainTabBarController()
            }
        }
    }
    
    @objc private func handleSubscribeTap() {
        // TODO: In-App Purchase işlemleri
        print("Premium satın alma başlatılacak")
    }
    
    @objc private func handleCloseTouchDown() {
        UIView.animate(withDuration: 0.2) {
            self.closeButton.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
            self.closeButton.alpha = 0.8
        }
    }
    
    @objc private func handleCloseTouchUp() {
        UIView.animate(withDuration: 0.2) {
            self.closeButton.transform = .identity
            self.closeButton.alpha = 1.0
        }
    }
} 
