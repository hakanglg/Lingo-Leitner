import UIKit

final class SignUpViewController: UIViewController {
    
    // MARK: - Properties
    private let emailTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "E-posta"
        tf.borderStyle = .roundedRect
        tf.backgroundColor = Theme.secondary
        return tf
    }()
    
    private let passwordTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Şifre"
        tf.isSecureTextEntry = true
        tf.borderStyle = .roundedRect
        tf.backgroundColor = Theme.secondary
        return tf
    }()
    
    private let signUpButton: GradientButton = {
        let button = GradientButton(title: "Üye Ol")
        return button
    }()
    
    private let termsLabel: UILabel = {
        let label = UILabel()
        let text = "Üye olarak Kullanım Koşulları'nı kabul etmiş olursunuz"
        label.text = text
        label.textColor = .secondaryLabel
        label.font = Theme.font(.caption1)
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    private let stackView: UIStackView = {
        let sv = UIStackView()
        sv.axis = .vertical
        sv.spacing = Theme.spacing(2)
        sv.distribution = .fillEqually
        return sv
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
        label.text = "Yeni Hesap Oluştur"
        label.font = Theme.font(.title1, .bold)
        label.textAlignment = .center
        return label
    }()
    
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Kelime öğrenmeye hemen başlayın"
        label.font = Theme.font(.body)
        label.textAlignment = .center
        label.textColor = .secondaryLabel
        return label
    }()
    
    private let backButton: UIButton = {
        let button = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: 20, weight: .medium)
        let image = UIImage(systemName: "chevron.left", withConfiguration: config)
        button.setImage(image, for: .normal)
        button.tintColor = .label
        return button
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupActions()
        setupGestures()
    }
    
    // MARK: - Setup
    private func setupUI() {
        title = "Üye Ol"
        view.backgroundColor = Theme.primary
        
        [backButton, logoImageView, titleLabel, subtitleLabel, stackView, signUpButton, termsLabel].forEach {
            view.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        [emailTextField, passwordTextField].forEach {
            $0.heightAnchor.constraint(equalToConstant: 56).isActive = true
            $0.layer.cornerRadius = Theme.cornerRadius
            $0.font = Theme.font(.body)
            stackView.addArrangedSubview($0)
        }
        
        signUpButton.heightAnchor.constraint(equalToConstant: 56).isActive = true
        
        NSLayoutConstraint.activate([
            backButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: Theme.spacing(2)),
            backButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Theme.spacing(2)),
            backButton.widthAnchor.constraint(equalToConstant: 44),
            backButton.heightAnchor.constraint(equalToConstant: 44),
            
            logoImageView.topAnchor.constraint(equalTo: backButton.bottomAnchor, constant: Theme.spacing(4)),
            logoImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            logoImageView.widthAnchor.constraint(equalToConstant: 80),
            logoImageView.heightAnchor.constraint(equalToConstant: 80),
            
            titleLabel.topAnchor.constraint(equalTo: logoImageView.bottomAnchor, constant: Theme.spacing(2)),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Theme.spacing(2)),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Theme.spacing(2)),
            
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: Theme.spacing(1)),
            subtitleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Theme.spacing(2)),
            subtitleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Theme.spacing(2)),
            
            stackView.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: Theme.spacing(4)),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Theme.spacing(2)),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Theme.spacing(2)),
            
            signUpButton.topAnchor.constraint(equalTo: stackView.bottomAnchor, constant: Theme.spacing(2)),
            signUpButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Theme.spacing(2)),
            signUpButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Theme.spacing(2)),
            
            termsLabel.topAnchor.constraint(equalTo: signUpButton.bottomAnchor, constant: Theme.spacing(2)),
            termsLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Theme.spacing(2)),
            termsLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Theme.spacing(2))
        ])
    }
    
    private func setupActions() {
        backButton.addTarget(self, action: #selector(handleBackTap), for: .touchUpInside)
        signUpButton.addTarget(self, action: #selector(handleSignUpTap), for: .touchUpInside)
    }
    
    // MARK: - Actions
    @objc private func handleSignUpTap() {
        guard let email = emailTextField.text, !email.isEmpty,
              let password = passwordTextField.text, !password.isEmpty else {
            showError(AuthError.invalidEmail)
            return
        }
        
        Task {
            do {
                LoadingView.shared.show(in: view)
                try await AuthManager.shared.signUp(email: email, password: password)
                LoadingView.shared.hide()
                navigateToMainApp()
            } catch {
                LoadingView.shared.hide()
                showError(error)
            }
        }
    }
    
    private func navigateToMainApp() {
        let mainVC = MainTabBarController()
        mainVC.modalPresentationStyle = .fullScreen
        present(mainVC, animated: true)
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
    
    private func setupGestures() {
        let swipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(handleBackTap))
        swipeGesture.direction = .right
        view.addGestureRecognizer(swipeGesture)
    }
    
    @objc private func handleBackTap() {
        dismiss(animated: true)
    }
} 