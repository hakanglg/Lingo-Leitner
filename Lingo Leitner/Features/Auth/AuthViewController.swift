import UIKit

final class AuthViewController: UIViewController {
    
    // MARK: - Properties
    private let scrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.showsVerticalScrollIndicator = false
        return sv
    }()
    
    private let containerView = UIView()
    
    // Sosyal login butonlarını property olarak tanımlayalım
    private lazy var googleButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .white
        button.layer.cornerRadius = Theme.cornerRadius
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.systemGray5.cgColor
        button.isUserInteractionEnabled = true
        
        // Test için geçici olarak ekleyelim
        button.addAction(UIAction { _ in
            print("Google butonu tıklandı (UIAction)")
        }, for: .touchUpInside)
        
        // Google logosu için imageView
        let imageView = UIImageView(image: UIImage(named: "google-logo"))
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        button.addSubview(imageView)
        
        // "Google ile devam et" yazısı için label
        let label = UILabel()
        label.text = "Google ile devam et"
        label.font = Theme.font(.body, .medium)
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        button.addSubview(label)
        
        // Constraints
        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: button.leadingAnchor, constant: 16),
            imageView.centerYAnchor.constraint(equalTo: button.centerYAnchor),
            imageView.widthAnchor.constraint(equalToConstant: 24),
            imageView.heightAnchor.constraint(equalToConstant: 24),
            
            label.centerXAnchor.constraint(equalTo: button.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: button.centerYAnchor)
        ])
        
        button.heightAnchor.constraint(equalToConstant: 56).isActive = true
        
        // Gölge ekle
        Theme.applyShadow(to: button)
        
        // Action ekle
        button.addTarget(self, action: #selector(handleGoogleSignInTap), for: .touchUpInside)
        print("Google butonu oluşturuldu ve action eklendi")
        
        return button
    }()
    
    private lazy var appleButton: UIButton = {
        return createSocialButton(
            title: "Apple ile devam et",
            image: UIImage(systemName: "apple.logo"),
            backgroundColor: .black,
            titleColor: .white
        )
    }()
    
    private let logoImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.image = UIImage(named: "auth-logo")?.withRenderingMode(.alwaysTemplate)
        iv.tintColor = Theme.gradient[0]
        return iv
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Lingo Leitner'a\nHoş Geldiniz"
        label.font = Theme.font(.largeTitle, .bold)
        label.textAlignment = .center
        label.numberOfLines = 2
        return label
    }()
    
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Kelimelerinizi senkronize edin,\narkadaşlarınızla paylaşın"
        label.font = Theme.font(.title3)
        label.textAlignment = .center
        label.textColor = .secondaryLabel
        label.numberOfLines = 2
        return label
    }()
    
    private let authButtonsStackView: UIStackView = {
        let sv = UIStackView()
        sv.axis = .vertical
        sv.spacing = Theme.spacing(2)
        return sv
    }()
    
    private let signUpButton: GradientButton = {
        let button = GradientButton(title: "Ücretsiz Üye Ol")
        button.heightAnchor.constraint(equalToConstant: 56).isActive = true
        return button
    }()
    
    private let loginButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Zaten üye misiniz? Giriş yapın", for: .normal)
        button.titleLabel?.font = Theme.font(.body, .medium)
        button.setTitleColor(Theme.accent, for: .normal)
        button.heightAnchor.constraint(equalToConstant: 44).isActive = true
        return button
    }()
    
    private let socialLoginStackView: UIStackView = {
        let sv = UIStackView()
        sv.axis = .vertical
        sv.spacing = Theme.spacing(2)
        return sv
    }()
    
    private let dividerView: UIView = {
        let view = UIView()
        view.backgroundColor = .separator
        view.heightAnchor.constraint(equalToConstant: 1).isActive = true
        return view
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        print("AuthViewController: viewDidLoad")
        print("Google butonu frame: \(googleButton.frame)")
        print("Google butonu superview: \(googleButton.superview?.description ?? "nil")")
        setupUI()
        setupActions()
    }
    
    // MARK: - Setup
    private func setupUI() {
        view.backgroundColor = Theme.primary
        navigationController?.setNavigationBarHidden(true, animated: false)
        
        // Gradient background
        let backgroundGradient = CAGradientLayer()
        backgroundGradient.colors = [
            UIColor.systemBackground.cgColor,
            Theme.gradient[0].withAlphaComponent(0.1).cgColor
        ]
        backgroundGradient.locations = [0.0, 1.0]
        backgroundGradient.frame = view.bounds
        view.layer.insertSublayer(backgroundGradient, at: 0)
        
        // Social butonlar için gölge ve stil
        [googleButton, appleButton].forEach { button in
            button.layer.cornerRadius = Theme.cornerRadius
            Theme.applyShadow(to: button)
        }
        
        // Container view için blur effect
        let blurEffect = UIBlurEffect(style: .systemMaterial)
        let blurView = UIVisualEffectView(effect: blurEffect)
        containerView.addSubview(blurView)
        blurView.translatesAutoresizingMaskIntoConstraints = false
        
        // Blur view constraints
        NSLayoutConstraint.activate([
            blurView.topAnchor.constraint(equalTo: containerView.topAnchor),
            blurView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            blurView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            blurView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
        ])
        
        view.addSubview(scrollView)
        scrollView.addSubview(containerView)
        
        [scrollView, containerView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        // Social login butonlarını ekleyelim
        [logoImageView, titleLabel, subtitleLabel, authButtonsStackView, 
         dividerView, socialLoginStackView].forEach {
            containerView.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        authButtonsStackView.addArrangedSubview(signUpButton)
        authButtonsStackView.addArrangedSubview(loginButton)
        
        socialLoginStackView.addArrangedSubview(googleButton)
        socialLoginStackView.addArrangedSubview(appleButton)
        
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
            
            logoImageView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 60),
            logoImageView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            logoImageView.widthAnchor.constraint(equalToConstant: 120),
            logoImageView.heightAnchor.constraint(equalToConstant: 120),
            
            titleLabel.topAnchor.constraint(equalTo: logoImageView.bottomAnchor, constant: Theme.spacing(3)),
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: Theme.spacing(2)),
            titleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -Theme.spacing(2)),
            
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: Theme.spacing(2)),
            subtitleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: Theme.spacing(2)),
            subtitleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -Theme.spacing(2)),
            
            authButtonsStackView.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: Theme.spacing(6)),
            authButtonsStackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: Theme.spacing(2)),
            authButtonsStackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -Theme.spacing(2)),
            
            dividerView.topAnchor.constraint(equalTo: authButtonsStackView.bottomAnchor, constant: Theme.spacing(4)),
            dividerView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: Theme.spacing(2)),
            dividerView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -Theme.spacing(2)),
            
            socialLoginStackView.topAnchor.constraint(equalTo: dividerView.bottomAnchor, constant: Theme.spacing(4)),
            socialLoginStackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: Theme.spacing(2)),
            socialLoginStackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -Theme.spacing(2)),
            socialLoginStackView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -Theme.spacing(4))
        ])
    }
    
    private func createSocialButton(title: String, image: UIImage?, backgroundColor: UIColor, titleColor: UIColor? = nil) -> UIButton {
        let button = UIButton(type: .system)
        
        var config = UIButton.Configuration.filled()
        config.baseBackgroundColor = backgroundColor
        config.baseForegroundColor = titleColor ?? .label
        config.cornerStyle = .medium
        
        config.title = title
        config.image = image
        config.imagePadding = 8
        config.contentInsets = NSDirectionalEdgeInsets(top: 12, leading: 16, bottom: 12, trailing: 16)
        
        button.configuration = config
        button.heightAnchor.constraint(equalToConstant: Theme.buttonHeight).isActive = true
        
        return button
    }
    
    private func setupActions() {
        signUpButton.addTarget(self, action: #selector(handleSignUpTap), for: .touchUpInside)
        loginButton.addTarget(self, action: #selector(handleLoginTap), for: .touchUpInside)
        googleButton.addTarget(self, action: #selector(handleGoogleSignInTap), for: .touchUpInside)
        appleButton.addTarget(self, action: #selector(handleAppleSignInTap), for: .touchUpInside)
    }
    
    // MARK: - Actions
    @objc private func handleSignUpTap() {
        let signUpVC = SignUpViewController()
        navigationController?.pushViewController(signUpVC, animated: true)
    }
    
    @objc private func handleLoginTap() {
        let loginVC = LoginViewController()
        navigationController?.pushViewController(loginVC, animated: true)
    }
    
    @objc private func handleGoogleSignInTap() {
        print("AuthViewController: Google butonu tıklandı")
        Task { @MainActor in
            do {
                print("AuthViewController: Google Sign In işlemi başlatılıyor...")
                LoadingView.shared.show(in: view)
                try await AuthManager.shared.signInWithGoogle(presenting: self)
                LoadingView.shared.hide()
                print("AuthViewController: Google Sign In başarılı, ana ekrana yönlendiriliyor...")
                navigateToMainApp()
            } catch {
                LoadingView.shared.hide()
                print("AuthViewController: Google Sign In hatası: \(error.localizedDescription)")
                showError(error)
            }
        }
    }
    
    @objc private func handleAppleSignInTap() {
        Task {
            do {
                LoadingView.shared.show(in: view)
                try await AuthManager.shared.signInWithApple()
                LoadingView.shared.hide()
                navigateToMainApp()
            } catch {
                LoadingView.shared.hide()
                showError(error)
            }
        }
    }
    
    private func showError(_ error: Error) {
        let alert = UIAlertController(
            title: "Hata",
            message: (error as? AuthError)?.message ?? error.localizedDescription,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Tamam", style: .default))
        present(alert, animated: true)
    }
    
    private func navigateToMainApp() {
        DispatchQueue.main.async {
            let mainVC = MainTabBarController()
            let nav = UINavigationController(rootViewController: mainVC)
            nav.modalPresentationStyle = .fullScreen
            self.present(nav, animated: true)
        }
    }
} 
