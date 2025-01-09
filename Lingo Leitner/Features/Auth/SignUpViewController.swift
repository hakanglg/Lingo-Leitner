import UIKit
import FirebaseAuth

final class SignUpViewController: UIViewController {
    
    // MARK: - Properties
    private let scrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.showsVerticalScrollIndicator = false
        return sv
    }()
    
    private let containerView = UIView()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Hesap Oluştur"
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
    
    private let formStackView: UIStackView = {
        let sv = UIStackView()
        sv.axis = .vertical
        sv.spacing = Theme.spacing(2)
        sv.distribution = .fillEqually
        return sv
    }()
    
    private let nameTextField: FloatingTextField = {
        let tf = FloatingTextField()
        tf.placeholder = "Ad Soyad"
        tf.backgroundColor = Theme.secondary
        tf.autocapitalizationType = .words
        tf.returnKeyType = .next
        tf.cornerRadius = 12
        return tf
    }()
    
    private let emailTextField: FloatingTextField = {
        let tf = FloatingTextField()
        tf.placeholder = "E-posta"
        tf.backgroundColor = Theme.secondary
        tf.keyboardType = .emailAddress
        tf.autocapitalizationType = .none
        tf.autocorrectionType = .no
        tf.returnKeyType = .next
        tf.cornerRadius = 12
        return tf
    }()
    
    private let passwordTextField: FloatingTextField = {
        let tf = FloatingTextField()
        tf.placeholder = "Şifre"
        tf.isSecureTextEntry = true
        tf.backgroundColor = Theme.secondary
        tf.returnKeyType = .next
        tf.cornerRadius = 12
        
        let button = UIButton(type: .custom)
        button.setImage(UIImage(systemName: "eye.slash.fill"), for: .normal)
        button.tintColor = .secondaryLabel
        button.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        button.addTarget(nil, action: #selector(SignUpViewController.togglePasswordVisibility(_:)), for: .touchUpInside)
        
        tf.rightView = button
        tf.rightViewMode = .always
        return tf
    }()
    
    private let confirmPasswordTextField: FloatingTextField = {
        let tf = FloatingTextField()
        tf.placeholder = "Şifre (Tekrar)"
        tf.isSecureTextEntry = true
        tf.backgroundColor = Theme.secondary
        tf.returnKeyType = .done
        tf.cornerRadius = 12
        
        let button = UIButton(type: .custom)
        button.setImage(UIImage(systemName: "eye.slash.fill"), for: .normal)
        button.tintColor = .secondaryLabel
        button.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        button.addTarget(nil, action: #selector(SignUpViewController.togglePasswordVisibility(_:)), for: .touchUpInside)
        
        tf.rightView = button
        tf.rightViewMode = .always
        return tf
    }()
    
    private let signUpButton: GradientButton = {
        let button = GradientButton(title: "Üye Ol")
        button.alpha = 0.5
        button.isEnabled = false
        return button
    }()
    
    private let termsStackView: UIStackView = {
        let sv = UIStackView()
        sv.axis = .horizontal
        sv.spacing = 8
        sv.alignment = .center
        sv.distribution = .fill
        return sv
    }()
    
    private let termsCheckbox: UIButton = {
        let button = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: 22, weight: .medium)
        button.setImage(UIImage(systemName: "square", withConfiguration: config), for: .normal)
        button.tintColor = Theme.gradient[0]
        
        let size: CGFloat = 32
        button.frame = CGRect(x: 0, y: 0, width: size, height: size)
        
        NSLayoutConstraint.activate([
            button.widthAnchor.constraint(equalToConstant: size),
            button.heightAnchor.constraint(equalToConstant: size)
        ])
        
        button.contentVerticalAlignment = .center
        button.contentHorizontalAlignment = .center
        
        return button
    }()
    
    private let termsLabel: UILabel = {
        let label = UILabel()
        let text = "Kullanım Koşulları'nı kabul ediyorum"
        label.text = text
        label.textColor = .secondaryLabel
        label.font = Theme.font(.subheadline)
        label.numberOfLines = 0
        return label
    }()
    
    private var isTermsAccepted = false {
        didSet {
            validateForm()
        }
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupNavigationBar()
        setupActions()
        setupTextFields()
        setupNotifications()
    }
    
    // MARK: - Setup
    private func setupTextFields() {
        [nameTextField, emailTextField, passwordTextField, confirmPasswordTextField].forEach {
            $0.delegate = self
            $0.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        }
    }
    
    private func setupActions() {
        termsCheckbox.addTarget(self, action: #selector(handleTermsCheckboxTap), for: .touchUpInside)
        signUpButton.addTarget(self, action: #selector(handleSignUpTap), for: .touchUpInside)
    }
    
    @objc private func handleTermsCheckboxTap() {
        isTermsAccepted.toggle()
        let imageName = isTermsAccepted ? "checkmark.square.fill" : "square"
        let config = UIImage.SymbolConfiguration(pointSize: 22, weight: .medium)
        termsCheckbox.setImage(UIImage(systemName: imageName, withConfiguration: config), for: .normal)
    }
    
    @objc private func textFieldDidChange(_ textField: UITextField) {
        validateForm()
    }
    
    private func validateForm() {
        let isNameValid = !(nameTextField.text?.isEmpty ?? true)
        let isEmailValid = isValidEmail(emailTextField.text ?? "")
        let isPasswordValid = (passwordTextField.text?.count ?? 0) >= 6
        let doPasswordsMatch = passwordTextField.text == confirmPasswordTextField.text
        
        let isFormValid = isNameValid && isEmailValid && isPasswordValid && doPasswordsMatch && isTermsAccepted
        
        UIView.animate(withDuration: 0.3) {
            self.signUpButton.alpha = isFormValid ? 1.0 : 0.5
        }
        signUpButton.isEnabled = isFormValid
    }
    
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
    
    @objc private func handleSignUpTap() {
        guard let name = nameTextField.text,
              let email = emailTextField.text,
              let password = passwordTextField.text else { return }
        
        Task {
            do {
                LoadingView.shared.show(in: view)
                try await AuthManager.shared.signUp(email: email, password: password, displayName: name)
                LoadingView.shared.hide()
                navigateToMainApp()
            } catch {
                LoadingView.shared.hide()
                showError(error)
            }
        }
    }
    
    private func setupUI() {
        view.backgroundColor = Theme.primary
        
        view.addSubview(scrollView)
        scrollView.addSubview(containerView)
        
        [scrollView, containerView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        [titleLabel, subtitleLabel, formStackView, signUpButton, termsStackView].forEach {
            containerView.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        [nameTextField, emailTextField, passwordTextField, confirmPasswordTextField].forEach {
            $0.heightAnchor.constraint(equalToConstant: 56).isActive = true
            formStackView.addArrangedSubview($0)
        }
        
        // Terms Stack View'ı hazırla
        termsStackView.addArrangedSubview(termsCheckbox)
        termsStackView.addArrangedSubview(termsLabel)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            containerView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            containerView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            containerView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: Theme.spacing(4)),
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: Theme.spacing(2)),
            titleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -Theme.spacing(2)),
            
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: Theme.spacing()),
            subtitleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: Theme.spacing(2)),
            subtitleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -Theme.spacing(2)),
            
            formStackView.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: Theme.spacing(4)),
            formStackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: Theme.spacing(2)),
            formStackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -Theme.spacing(2)),
            
            termsStackView.topAnchor.constraint(equalTo: formStackView.bottomAnchor, constant: Theme.spacing(2)),
            termsStackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: Theme.spacing(2)),
            termsStackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -Theme.spacing(2)),
            
            termsCheckbox.leadingAnchor.constraint(equalTo: termsStackView.leadingAnchor),
            
            signUpButton.topAnchor.constraint(equalTo: termsStackView.bottomAnchor, constant: Theme.spacing(3)),
            signUpButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: Theme.spacing(2)),
            signUpButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -Theme.spacing(2)),
            signUpButton.heightAnchor.constraint(equalToConstant: 56),
            signUpButton.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -Theme.spacing(4))
        ])
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
    
    private func setupNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }
    
    @objc private func keyboardWillShow(notification: NSNotification) {
        guard let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else { return }
        let contentInsets = UIEdgeInsets(top: 0, left: 0, bottom: keyboardSize.height, right: 0)
        scrollView.contentInset = contentInsets
        scrollView.scrollIndicatorInsets = contentInsets
    }
    
    @objc private func keyboardWillHide(notification: NSNotification) {
        scrollView.contentInset = .zero
        scrollView.scrollIndicatorInsets = .zero
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
    
    @objc private func handleBackTap() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func togglePasswordVisibility(_ sender: UIButton) {
        let isSecure = !passwordTextField.isSecureTextEntry
        passwordTextField.isSecureTextEntry = isSecure
        confirmPasswordTextField.isSecureTextEntry = isSecure
        
        let imageName = isSecure ? "eye.slash.fill" : "eye.fill"
        sender.setImage(UIImage(systemName: imageName), for: .normal)
        
        if let otherButton = (sender == passwordTextField.rightView ? confirmPasswordTextField.rightView : passwordTextField.rightView) as? UIButton {
            otherButton.setImage(UIImage(systemName: imageName), for: .normal)
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: - UITextFieldDelegate
extension SignUpViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case nameTextField:
            emailTextField.becomeFirstResponder()
        case emailTextField:
            passwordTextField.becomeFirstResponder()
        case passwordTextField:
            confirmPasswordTextField.becomeFirstResponder()
        default:
            textField.resignFirstResponder()
            if signUpButton.isEnabled {
                handleSignUpTap()
            }
        }
        return true
    }
} 
