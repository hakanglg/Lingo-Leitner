import UIKit
import SnapKit
import SDWebImage

final class ProfileViewController: UIViewController {
    
    // MARK: - Properties
    private let viewModel = ProfileViewModel()
    
    private let scrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.showsVerticalScrollIndicator = false
        return sv
    }()
    
    private let containerView = UIView()
    
    private let profileImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.backgroundColor = Theme.secondary
        iv.tintColor = .systemGray3
        iv.image = UIImage(systemName: "person.circle.fill")
        
        // Yükleme animasyonu için
        iv.layer.allowsEdgeAntialiasing = true
        iv.layer.minificationFilter = .trilinear
        
        return iv
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = Theme.font(.title2, .semibold)
        label.textAlignment = .center
        return label
    }()
    
    private let emailLabel: UILabel = {
        let label = UILabel()
        label.font = Theme.font(.subheadline)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        return label
    }()
    
    private let statsStackView: UIStackView = {
        let sv = UIStackView()
        sv.axis = .horizontal
        sv.distribution = .fillEqually
        sv.spacing = Theme.spacing(2)
        sv.backgroundColor = Theme.secondary
        sv.layer.cornerRadius = 12
        sv.layoutMargins = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        sv.isLayoutMarginsRelativeArrangement = true
        return sv
    }()
    
    private let settingsButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Ayarlar", for: .normal)
        button.titleLabel?.font = Theme.font(.body, .medium)
        button.backgroundColor = Theme.secondary
        button.layer.cornerRadius = 12
        button.tintColor = .label
        button.contentHorizontalAlignment = .leading
        button.contentEdgeInsets = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        return button
    }()
    
    private let premiumButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Premium'a Yükselt", for: .normal)
        button.titleLabel?.font = Theme.font(.body, .medium)
        button.backgroundColor = Theme.secondary
        button.layer.cornerRadius = 12
        button.tintColor = Theme.gradient[0]
        button.contentHorizontalAlignment = .leading
        button.contentEdgeInsets = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        return button
    }()
    
    private let signOutButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Çıkış Yap", for: .normal)
        button.titleLabel?.font = Theme.font(.body, .medium)
        button.backgroundColor = Theme.secondary
        button.layer.cornerRadius = 12
        button.tintColor = .systemRed
        button.contentHorizontalAlignment = .leading
        button.contentEdgeInsets = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        return button
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupActions()
        viewModel.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        Task {
            await viewModel.fetchUserProfile()
        }
    }
    
    // MARK: - Setup
    private func setupUI() {
        title = "Profil"
        view.backgroundColor = Theme.primary
        
        view.addSubview(scrollView)
        scrollView.addSubview(containerView)
        
        [profileImageView, nameLabel, emailLabel, statsStackView, 
         settingsButton, premiumButton, signOutButton].forEach {
            containerView.addSubview($0)
        }
        
        // Stats için 3 kutu oluştur
        ["Toplam Kelime", "Öğrenilen", "Tekrar Bekleyen"].enumerated().forEach { index, title in
            statsStackView.addArrangedSubview(createStatsView(title: title, value: "0"))
        }
        
        profileImageView.layer.cornerRadius = 50
        
        // SnapKit Constraints
        scrollView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
        
        containerView.snp.makeConstraints { make in
            make.edges.equalTo(scrollView)
            make.width.equalTo(scrollView)
        }
        
        profileImageView.snp.makeConstraints { make in
            make.top.equalTo(containerView).offset(Theme.spacing(4))
            make.centerX.equalTo(containerView)
            make.size.equalTo(100)
        }
        
        nameLabel.snp.makeConstraints { make in
            make.top.equalTo(profileImageView.snp.bottom).offset(Theme.spacing(2))
            make.leading.trailing.equalTo(containerView).inset(Theme.spacing(2))
        }
        
        emailLabel.snp.makeConstraints { make in
            make.top.equalTo(nameLabel.snp.bottom).offset(Theme.spacing(0.5))
            make.leading.trailing.equalTo(containerView).inset(Theme.spacing(2))
        }
        
        statsStackView.snp.makeConstraints { make in
            make.top.equalTo(emailLabel.snp.bottom).offset(Theme.spacing(4))
            make.leading.trailing.equalTo(containerView).inset(Theme.spacing(2))
            make.height.equalTo(120)
        }
        
        settingsButton.snp.makeConstraints { make in
            make.top.equalTo(statsStackView.snp.bottom).offset(Theme.spacing(4))
            make.leading.trailing.equalTo(containerView).inset(Theme.spacing(2))
            make.height.equalTo(56)
        }
        
        premiumButton.snp.makeConstraints { make in
            make.top.equalTo(settingsButton.snp.bottom).offset(Theme.spacing(2))
            make.leading.trailing.equalTo(containerView).inset(Theme.spacing(2))
            make.height.equalTo(56)
        }
        
        signOutButton.snp.makeConstraints { make in
            make.top.equalTo(premiumButton.snp.bottom).offset(Theme.spacing(2))
            make.leading.trailing.equalTo(containerView).inset(Theme.spacing(2))
            make.height.equalTo(56)
            make.bottom.equalTo(containerView).offset(-Theme.spacing(4))
        }
    }
    
    private func setupActions() {
        signOutButton.addTarget(self, action: #selector(handleSignOutTap), for: .touchUpInside)
        settingsButton.addTarget(self, action: #selector(handleSettingsTap), for: .touchUpInside)
        premiumButton.addTarget(self, action: #selector(handlePremiumTap), for: .touchUpInside)
    }
    
    private func createStatsView(title: String, value: String) -> UIView {
        let containerView = UIView()
        containerView.backgroundColor = .clear
        
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 8
        stackView.alignment = .center
        
        let valueLabel = UILabel()
        valueLabel.font = Theme.font(.title2, .bold)
        valueLabel.textColor = Theme.gradient[0]
        valueLabel.text = value
        
        let titleLabel = UILabel()
        titleLabel.font = Theme.font(.caption1)
        titleLabel.textColor = .secondaryLabel
        titleLabel.text = title
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 0
        
        stackView.addArrangedSubview(valueLabel)
        stackView.addArrangedSubview(titleLabel)
        
        containerView.addSubview(stackView)
        
        stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        return containerView
    }
    
    // MARK: - Actions
    @objc private func handleSignOutTap() {
        let alert = UIAlertController(
            title: "Çıkış Yap",
            message: "Hesabınızdan çıkış yapmak istediğinize emin misiniz?",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "İptal", style: .cancel))
        alert.addAction(UIAlertAction(title: "Çıkış Yap", style: .destructive) { [weak self] _ in
            Task { @MainActor in
                LoadingView.shared.show(in: self?.view ?? UIView())
                await self?.viewModel.signOut()
                LoadingView.shared.hide()
            }
        })
        
        present(alert, animated: true)
    }
    
    @objc private func handleSettingsTap() {
        // TODO: Ayarlar ekranına git
    }
    
    @objc private func handlePremiumTap() {
        let premiumVC = PremiumViewController()
        navigationController?.pushViewController(premiumVC, animated: true)
    }
}

// MARK: - ProfileViewModelDelegate
extension ProfileViewController: ProfileViewModelDelegate {
    func didUpdateProfile(_ user: User) {
        DispatchQueue.main.async { [weak self] in
            self?.nameLabel.text = user.displayName ?? user.email.components(separatedBy: "@").first
            self?.emailLabel.text = user.email
            
            if let photoURL = user.photoURL, let url = URL(string: photoURL) {
                self?.profileImageView.sd_setImage(
                    with: url,
                    placeholderImage: UIImage(systemName: "person.circle.fill"),
                    options: [.transformAnimatedImage],
                    completed: { image, error, _, _ in
                        if let error = error {
                            print("Profil fotoğrafı yüklenirken hata: \(error.localizedDescription)")
                        }
                    }
                )
            } else {
                self?.profileImageView.image = UIImage(systemName: "person.circle.fill")
            }
        }
    }
    
    func didUpdateStats(_ stats: UserStats) {
        // UI güncellemelerini main thread'de yap
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            if let totalWords = self.statsStackView.arrangedSubviews[0].subviews.first?.subviews.first as? UILabel {
                totalWords.text = "\(stats.totalWords)"
            }
            
            if let masteredWords = self.statsStackView.arrangedSubviews[1].subviews.first?.subviews.first as? UILabel {
                masteredWords.text = "\(stats.masteredWords)"
            }
            
            if let reviewDue = self.statsStackView.arrangedSubviews[2].subviews.first?.subviews.first as? UILabel {
                reviewDue.text = "\(stats.reviewDueWords)"
            }
        }
    }
    
    func didReceiveError(_ error: Error) {
        // UI güncellemelerini main thread'de yap
        DispatchQueue.main.async { [weak self] in
            let alert = UIAlertController(
                title: "Hata",
                message: error.localizedDescription,
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "Tamam", style: .default))
            self?.present(alert, animated: true)
        }
    }
} 
