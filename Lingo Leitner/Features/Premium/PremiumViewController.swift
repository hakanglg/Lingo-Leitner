import UIKit
import SnapKit

final class PremiumViewController: UIViewController {
    
    // MARK: - Properties
    private let backgroundImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.alpha = 0.3
        iv.image = UIImage(named: "premium_bg")
        return iv
    }()
    
    private let closeButton: UIButton = {
        let button = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: 24, weight: .medium)
        let image = UIImage(systemName: "xmark.circle.fill", withConfiguration: config)
        button.setImage(image, for: .normal)
        button.tintColor = .white
        return button
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "premium_upgrade".localized
        label.font = .systemFont(ofSize: 32, weight: .bold)
        label.textColor = .white
        label.textAlignment = .center
        return label
    }()
    
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "premium_subtitle_unlimited".localized
        label.font = .systemFont(ofSize: 24, weight: .semibold)
        label.textColor = UIColor(red: 255/255, green: 149/255, blue: 0/255, alpha: 1)
        label.textAlignment = .center
        return label
    }()
    
    private let subtitleLabel2: UILabel = {
        let label = UILabel()
        label.text = "premium_subtitle_ads".localized
        label.font = .systemFont(ofSize: 24, weight: .semibold)
        label.textColor = UIColor(red: 255/255, green: 149/255, blue: 0/255, alpha: 1)
        label.textAlignment = .center
        return label
    }()
    
    private let featuresStackView: UIStackView = {
        let sv = UIStackView()
        sv.axis = .vertical
        sv.spacing = 24
        sv.alignment = .leading
        return sv
    }()
    
    private let purchaseButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .systemOrange
        button.setTitle("premium_trial_button".localized, for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 20, weight: .bold)
        button.layer.cornerRadius = 25
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 4)
        button.layer.shadowRadius = 6
        button.layer.shadowOpacity = 0.3
        button.clipsToBounds = false
        
        // Add premium icon
        let config = UIImage.SymbolConfiguration(pointSize: 24, weight: .medium)
//        let premiumImage = UIImage(systemName: "star.fill", withConfiguration: config)?.withRenderingMode(.alwaysTemplate)
//        button.setImage(premiumImagse, for: .normal)
        button.tintColor = .white
//        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: -12, bottom: 0, right: 0)
        button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 0)
        
        // Add animation for tap effect
        button.addTarget(self, action: #selector(handlePurchaseTap), for: .touchUpInside)
        
        return button
    }()
    
    private let watchAdButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .systemBrown
        button.setTitle("watch_ad_button".localized, for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 18, weight: .bold)
        button.layer.cornerRadius = 25
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 4)
        button.layer.shadowRadius = 6
        button.layer.shadowOpacity = 0.3
        button.clipsToBounds = false
        
        // Add animation for tap effect
        button.addTarget(self, action: #selector(handleWatchAdTap), for: .touchUpInside)
        
        return button
    }()
    
    private let footerLabel: UILabel = {
        let label = UILabel()
        let text = "premium_footer_text".localized
        let attributedString = NSMutableAttributedString(string: text)
        let range = (text as NSString).range(of: "$4.99")
        attributedString.addAttribute(.foregroundColor, value: UIColor.systemYellow, range: range)
        label.attributedText = attributedString
        label.font = .systemFont(ofSize: 16)
        label.textColor = .white
        label.numberOfLines = 2
        label.textAlignment = .center
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
        view.backgroundColor = .black
        modalPresentationStyle = .fullScreen
        
        view.addSubview(backgroundImageView)
        view.addSubview(closeButton)
        view.addSubview(titleLabel)
        view.addSubview(subtitleLabel)
        view.addSubview(subtitleLabel2)
        view.addSubview(featuresStackView)
        view.addSubview(purchaseButton)
        view.addSubview(watchAdButton)
        view.addSubview(footerLabel)
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        backgroundImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        closeButton.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(16)
            make.trailing.equalToSuperview().offset(-16)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(closeButton.snp.bottom).offset(32)
            make.leading.trailing.equalToSuperview().inset(16)
        }
        
        subtitleLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(16)
        }
        
        subtitleLabel2.snp.makeConstraints { make in
            make.top.equalTo(subtitleLabel.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(16)
        }
        
        featuresStackView.snp.makeConstraints { make in
            make.top.equalTo(subtitleLabel.snp.bottom).offset(40)
            make.leading.trailing.equalToSuperview().inset(40)
        }
        
        purchaseButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(watchAdButton.snp.top).offset(-16)
            make.width.equalTo(350)
            make.height.equalTo(50)
        }
        
        watchAdButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(footerLabel.snp.top).offset(-24)
            make.width.equalTo(350)
            make.height.equalTo(50)
        }
        
        footerLabel.snp.makeConstraints { make in
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-24)
            make.leading.trailing.equalToSuperview().inset(20)
        }
    }
    
    private func addFeatures() {
        let features = [
            ("nosign", "premium_feature_unlimited".localized, ""),
            ("clock", "premium_feature_no_ads".localized, ""),
            ("4k", "premium_feature_exclusive".localized, "")
        ]
        
        features.forEach { feature in
            let featureView = createFeatureView(
                icon: feature.0,
                title: feature.1,
                description: feature.2
            )
            featuresStackView.addArrangedSubview(featureView)
        }
    }
    
    private func createFeatureView(icon: String, title: String, description: String) -> UIView {
        let container = UIView()
        container.layer.cornerRadius = 12
        container.backgroundColor = UIColor.black.withAlphaComponent(0.1)
        container.layer.shadowColor = UIColor.black.cgColor
        container.layer.shadowOffset = CGSize(width: 0, height: 3)
        container.layer.shadowRadius = 5
        container.layer.shadowOpacity = 0.2
        container.clipsToBounds = true
        
        let iconContainer = UIView()
        iconContainer.backgroundColor = .clear
        iconContainer.layer.cornerRadius = 12
        
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .systemYellow
        let config = UIImage.SymbolConfiguration(pointSize: 28, weight: .medium)
        imageView.image = UIImage(systemName: icon, withConfiguration: config)
        
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = .systemFont(ofSize: 20, weight: .semibold)
        titleLabel.textColor = .white
        
        container.addSubview(iconContainer)
        iconContainer.addSubview(imageView)
        container.addSubview(titleLabel)
        
        iconContainer.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.centerY.equalToSuperview()
            make.size.equalTo(40)
        }
        
        imageView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.size.equalTo(28)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.leading.equalTo(iconContainer.snp.trailing).offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.centerY.equalToSuperview()
        }
        
        return container
    }
    
    private func setupActions() {
        closeButton.addTarget(self, action: #selector(handleCloseTap), for: .touchUpInside)
        purchaseButton.addTarget(self, action: #selector(handlePurchaseTap), for: .touchUpInside)
    }
    
    // MARK: - Actions
    @objc private func handleCloseTap() {
        dismiss(animated: true)
    }
    
    @objc private func handlePurchaseTap() {
        print("premium_purchase_started".localized)
        // In-app purchase işlemleri burada başlatılabilir
        
        // Animation effect for button tap
        UIView.animate(withDuration: 0.1, animations: {
            self.purchaseButton.transform = CGAffineTransform(scaleX: 0.98, y: 0.98)
        }) { _ in
            UIView.animate(withDuration: 0.1) {
                self.purchaseButton.transform = CGAffineTransform.identity
            }
        }
    }
    
    @objc private func handleWatchAdTap() {
        print("watch_ad_started".localized)
        // Reklam izleme işlemleri burada başlatılabilir
        
        // Günlük kelime limitini azalt
        reduceDailyWordCount(by: 5)
    }
    
    private func reduceDailyWordCount(by amount: Int) {
        print("daily_word_limit_reduced".localized + " \(amount)")
        // Kullanıcının günlük kelime limitini azaltma işlemi
        // Bu işlemi gerçekleştirmek için Firestore veya başka bir veri kaynağı kullanılabilir
        print("Günlük kelime limiti \(amount) azaltıldı")
    }
}
