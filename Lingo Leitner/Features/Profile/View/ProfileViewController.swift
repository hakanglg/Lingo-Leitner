import UIKit

final class ProfileViewController: UIViewController {
    // MARK: - Properties
    private let viewModel = ProfileViewModel()
    
    // MARK: - UI Components
    private let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.backgroundColor = .systemGray6
        imageView.image = UIImage(systemName: "person.circle.fill")
        imageView.tintColor = .systemGray3
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = Theme.font(.title2, .semibold)
        label.textAlignment = .center
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let emailLabel: UILabel = {
        let label = UILabel()
        label.font = Theme.font(.subheadline)
        label.textAlignment = .center
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let statsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 16
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private lazy var signOutButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Çıkış Yap", for: .normal)
        button.setImage(UIImage(systemName: "rectangle.portrait.and.arrow.right"), for: .normal)
        button.titleLabel?.font = Theme.font(.headline)
        button.tintColor = .systemRed
        button.backgroundColor = .systemRed.withAlphaComponent(0.1)
        button.layer.cornerRadius = 12
        button.contentEdgeInsets = UIEdgeInsets(top: 12, left: 16, bottom: 12, right: 16)
        button.addTarget(self, action: #selector(handleSignOutTap), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        viewModel.delegate = self
        
        // Çıkış yapıldığında bildirim dinle
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleSignOut),
            name: .userDidSignOut,
            object: nil
        )
    }
    
    // MARK: - Setup
    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = "Profil"
        
        // Profile Image View
        profileImageView.layer.cornerRadius = 50
        view.addSubview(profileImageView)
        
        // Name Label
        view.addSubview(nameLabel)
        
        // Email Label
        view.addSubview(emailLabel)
        
        // Stats Stack View
        view.addSubview(statsStackView)
        
        // Stats Views
        let totalWordsView = createStatView(title: "Toplam", value: "0")
        let masteredWordsView = createStatView(title: "Öğrenilen", value: "0")
        let reviewDueView = createStatView(title: "Tekrar", value: "0")
        
        statsStackView.addArrangedSubview(totalWordsView)
        statsStackView.addArrangedSubview(masteredWordsView)
        statsStackView.addArrangedSubview(reviewDueView)
        
        // Sign Out Button
        view.addSubview(signOutButton)
        
        // NotificationCenter observer'ını ekle
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleSignOut),
            name: .userDidSignOut,
            object: nil
        )
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Profile Image View
            profileImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32),
            profileImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            profileImageView.widthAnchor.constraint(equalToConstant: 100),
            profileImageView.heightAnchor.constraint(equalToConstant: 100),
            
            // Name Label
            nameLabel.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 16),
            nameLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            nameLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            // Email Label
            emailLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8),
            emailLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            emailLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            // Stats Stack View
            statsStackView.topAnchor.constraint(equalTo: emailLabel.bottomAnchor, constant: 32),
            statsStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            statsStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            // Sign Out Button
            signOutButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -32),
            signOutButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    private func createStatView(title: String, value: String) -> UIView {
        let containerView = UIView()
        containerView.backgroundColor = .systemGray6
        containerView.layer.cornerRadius = 12
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 4
        stackView.alignment = .center
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        let valueLabel = UILabel()
        valueLabel.font = Theme.font(.title2, .bold)
        valueLabel.textColor = Theme.accent
        valueLabel.text = value
        
        let titleLabel = UILabel()
        titleLabel.font = Theme.font(.caption1)
        titleLabel.textColor = .secondaryLabel
        titleLabel.text = title
        
        stackView.addArrangedSubview(valueLabel)
        stackView.addArrangedSubview(titleLabel)
        
        containerView.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            containerView.heightAnchor.constraint(equalToConstant: 80),
            
            stackView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor)
        ])
        
        return containerView
    }
    
    private func setupViewModel() {
        viewModel.delegate = self
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
            Task {
                await self?.viewModel.signOut()
            }
        })
        
        present(alert, animated: true)
    }
    
    @objc private func handleSignOut() {
        // Ana thread'de UI güncellemesi yap
        DispatchQueue.main.async {
            // Root view controller'ı AuthViewController ile değiştir
            let authVC = AuthViewController()
            let navController = UINavigationController(rootViewController: authVC)
            navController.modalPresentationStyle = .fullScreen
            
            // SceneDelegate'deki window'un root view controller'ını değiştir
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let window = windowScene.windows.first {
                UIView.transition(with: window,
                                duration: 0.3,
                                options: .transitionCrossDissolve,
                                animations: {
                                    window.rootViewController = navController
                                })
            }
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: - ProfileViewModelDelegate
extension ProfileViewController: ProfileViewModelDelegate {
    func didUpdateProfile(_ user: User) {
        nameLabel.text = user.displayName ?? user.email.components(separatedBy: "@").first
        emailLabel.text = user.email
        
        if let photoURL = user.photoURL {
            // TODO: Profil fotoğrafını yükle ve göster
            // URLSession veya SDWebImage gibi bir kütüphane kullanılabilir
        } else {
            profileImageView.image = UIImage(systemName: "person.circle.fill")
            profileImageView.tintColor = .systemGray3
        }
    }
    
    func didUpdateStats(_ stats: UserStats) {
        // İstatistikleri güncelle
        if let totalWords = statsStackView.arrangedSubviews.first?.subviews.first?.subviews.first as? UILabel {
            totalWords.text = "\(stats.totalWords)"
        }
        
        if let masteredWords = statsStackView.arrangedSubviews[1].subviews.first?.subviews.first as? UILabel {
            masteredWords.text = "\(stats.masteredWords)"
        }
        
        if let reviewDue = statsStackView.arrangedSubviews.last?.subviews.first?.subviews.first as? UILabel {
            reviewDue.text = "\(stats.reviewDueWords)"
        }
    }
    
    func didReceiveError(_ error: Error) {
        let alert = UIAlertController(
            title: "Hata",
            message: error.localizedDescription,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Tamam", style: .default))
        present(alert, animated: true)
    }
} 
