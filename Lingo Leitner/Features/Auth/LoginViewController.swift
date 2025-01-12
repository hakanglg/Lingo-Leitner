import UIKit
import FirebaseAuth

final class LoginViewController: UIViewController {
    
    // MARK: - Properties
    private let scrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.showsVerticalScrollIndicator = false
        return sv
    }()
    
    private let containerView: UIView = {
        let view = UIView()
        return view
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
        label.text = "welcome_back".localized
        label.font = Theme.font(.title1, .bold)
        label.textAlignment = .center
        return label
    }()
    
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "continue_flashcards".localized
        label.font = Theme.font(.body)
        label.textAlignment = .center
        label.textColor = .secondaryLabel
        return label
    }()
    
    private let emailTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "email".localized
        tf.borderStyle = .roundedRect
        tf.backgroundColor = Theme.secondary
        return tf
    }()
    
    private let passwordTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "password".localized
        tf.isSecureTextEntry = true
        tf.borderStyle = .roundedRect
        tf.backgroundColor = Theme.secondary
        return tf
    }()
    
    private let loginButton: GradientButton = {
        let button = GradientButton(title: "login".localized)
        return button
    }()
    
    private let forgotPasswordButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("forgot_password".localized, for: .normal)
        button.setTitleColor(Theme.gradient[0], for: .normal)
        button.titleLabel?.font = Theme.font(.footnote)
        return button
    }()
    
    private let stackView: UIStackView = {
        let sv = UIStackView()
        sv.axis = .vertical
        sv.spacing = Theme.spacing(2)
        sv.distribution = .fillEqually
        return sv
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
        setupNavigationBar()
        setupActions()
        setupGestures()
        setupTextFields()
    }
    
    // MARK: - Setup
    private func setupUI() {
        view.backgroundColor = Theme.primary
        
        view.addSubview(scrollView)
        scrollView.addSubview(containerView)
        
        [scrollView, containerView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        [backButton, logoImageView, titleLabel, subtitleLabel, stackView, loginButton, forgotPasswordButton].forEach {
            containerView.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        [emailTextField, passwordTextField].forEach {
            $0.style()
            $0.heightAnchor.constraint(equalToConstant: Theme.buttonHeight).isActive = true
            stackView.addArrangedSubview($0)
        }
        
        loginButton.heightAnchor.constraint(equalToConstant: Theme.buttonHeight).isActive = true
        
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
            
            backButton.topAnchor.constraint(equalTo: containerView.safeAreaLayoutGuide.topAnchor, constant: Theme.spacing(2)),
            backButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: Theme.spacing(2)),
            backButton.widthAnchor.constraint(equalToConstant: 44),
            backButton.heightAnchor.constraint(equalToConstant: 44),
            
            logoImageView.topAnchor.constraint(equalTo: backButton.bottomAnchor, constant: Theme.spacing(4)),
            logoImageView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            logoImageView.widthAnchor.constraint(equalToConstant: 80),
            logoImageView.heightAnchor.constraint(equalToConstant: 80),
            
            titleLabel.topAnchor.constraint(equalTo: logoImageView.bottomAnchor, constant: Theme.spacing(2)),
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: Theme.spacing(2)),
            titleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -Theme.spacing(2)),
            
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: Theme.spacing(1)),
            subtitleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: Theme.spacing(2)),
            subtitleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -Theme.spacing(2)),
            
            stackView.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: Theme.spacing(4)),
            stackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: Theme.spacing(2)),
            stackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -Theme.spacing(2)),
            
            loginButton.topAnchor.constraint(equalTo: stackView.bottomAnchor, constant: Theme.spacing(2)),
            loginButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: Theme.spacing(2)),
            loginButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -Theme.spacing(2)),
            
            forgotPasswordButton.topAnchor.constraint(equalTo: loginButton.bottomAnchor, constant: Theme.spacing(2)),
            forgotPasswordButton.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            forgotPasswordButton.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -Theme.spacing(4))
        ])
    }
    
    private func setupTextFields() {
        emailTextField.delegate = self
        passwordTextField.delegate = self
        
        emailTextField.returnKeyType = .next
        passwordTextField.returnKeyType = .done
        
        emailTextField.keyboardType = .emailAddress
        emailTextField.autocapitalizationType = .none
        emailTextField.autocorrectionType = .no
    }
    
    private func setupActions() {
        backButton.addTarget(self, action: #selector(handleBackTap), for: .touchUpInside)
        loginButton.addTarget(self, action: #selector(handleLoginTap), for: .touchUpInside)
        forgotPasswordButton.addTarget(self, action: #selector(handleForgotPasswordTap), for: .touchUpInside)
    }
    
    // MARK: - Actions
    @objc private func handleLoginTap() {
        guard let email = emailTextField.text, !email.isEmpty,
              let password = passwordTextField.text, !password.isEmpty else {
            showError(AuthError.invalidEmail)
            return
        }
        
        Task {
            do {
                LoadingView.shared.show(in: view)
                try await AuthManager.shared.signIn(email: email, password: password)
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
            title: "error".localized,
            message: (error as? AuthError)?.message ?? error.localizedDescription,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "ok".localized, style: .default))
        present(alert, animated: true)
    }
    
    private func setupGestures() {
        let swipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(handleBackTap))
        swipeGesture.direction = .right
        view.addGestureRecognizer(swipeGesture)
    }
    
    @objc private func handleBackTap() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func handleForgotPasswordTap() {
        let alert = UIAlertController(
            title: "reset_password".localized,
            message: "reset_password_message".localized,
            preferredStyle: .alert
        )
        
        alert.addTextField { textField in
            textField.placeholder = "enter_email".localized
            textField.keyboardType = .emailAddress
            textField.autocapitalizationType = .none
        }
        
        let sendAction = UIAlertAction(title: "send".localized, style: .default) { [weak self] _ in
            guard let email = alert.textFields?.first?.text, !email.isEmpty else {
                self?.showError(AuthError.invalidEmail)
                return
            }
            
            Task {
                do {
                    LoadingView.shared.show(in: self?.view ?? UIView())
                    try await Auth.auth().sendPasswordReset(withEmail: email)
                    LoadingView.shared.hide()
                    
                    let successAlert = UIAlertController(
                        title: "reset_success".localized,
                        message: "reset_success_message".localized,
                        preferredStyle: .alert
                    )
                    successAlert.addAction(UIAlertAction(title: "ok".localized, style: .default))
                    self?.present(successAlert, animated: true)
                } catch {
                    LoadingView.shared.hide()
                    self?.showError(error)
                }
            }
        }
        
        let cancelAction = UIAlertAction(title: "cancel".localized, style: .cancel)
        
        alert.addAction(sendAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true)
    }
    
    private func setupNavigationBar() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "chevron.left"),
            style: .plain,
            target: self,
            action: #selector(handleBackTap)
        )
        navigationItem.leftBarButtonItem?.tintColor = .label
    }
}

// MARK: - UITextFieldDelegate
extension LoginViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == emailTextField {
            passwordTextField.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
            handleLoginTap()
        }
        return true
    }
} 
