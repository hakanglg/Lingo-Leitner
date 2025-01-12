import UIKit
import SnapKit

final class AddWordViewController: UIViewController {
    // MARK: - Properties
    private let viewModel = AddWordViewModel()
    
    // MARK: - UI Components
    private let scrollView: UIScrollView = {
        let scroll = UIScrollView()
        scroll.backgroundColor = .systemBackground
        scroll.showsVerticalScrollIndicator = false
        scroll.alwaysBounceVertical = true
        return scroll
    }()
    
    private let contentView: UIView = {
        let view = UIView()
        return view
    }()
    
    private let headerView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
        return view
    }()
    
    private let iconImageView: UIImageView = {
        let iv = UIImageView()
        let config = UIImage.SymbolConfiguration(pointSize: 40, weight: .medium)
        iv.image = UIImage(systemName: "plus.circle.fill", withConfiguration: config)
        iv.tintColor = Theme.accent
        iv.contentMode = .scaleAspectFit
        return iv
    }()
    
    private let headerLabel: UILabel = {
        let label = UILabel()
        label.text = "add_word_title".localized
        label.font = .systemFont(ofSize: 28, weight: .bold)
        label.textColor = .label
        return label
    }()
    
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "add_word_subtitle".localized
        label.font = .systemFont(ofSize: 17, weight: .regular)
        label.textColor = .secondaryLabel
        return label
    }()
    
    private let formStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.backgroundColor = .systemBackground
        stack.spacing = 24
        stack.layoutMargins = UIEdgeInsets(top: 32, left: 24, bottom: 32, right: 24)
        stack.isLayoutMarginsRelativeArrangement = true
        return stack
    }()
    
    private let wordTextField: CustomTextField = {
        let field = CustomTextField()
        field.configure(
            icon: "textformat.alt",
            placeholder: "word".localized,
            keyboardType: .default,
            returnKeyType: .next
        )
        return field
    }()
    
    private let meaningTextField: CustomTextField = {
        let field = CustomTextField()
        field.configure(
            icon: "text.book.closed",
            placeholder: "meaning".localized,
            keyboardType: .default,
            returnKeyType: .next
        )
        return field
    }()
    
    private let exampleTextField: CustomTextField = {
        let field = CustomTextField()
        field.configure(
            icon: "text.quote",
            placeholder: "example".localized,
            keyboardType: .default,
            returnKeyType: .done
        )
        return field
    }()
    
    private let saveButton: LoadingButton = {
        let button = LoadingButton(style: .primary)
        button.setTitle("Kelimeyi Kaydet", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
        button.layer.cornerRadius = 16
        button.heightAnchor.constraint(equalToConstant: 56).isActive = true // Apple's minimum touch target
        
        // Add shadow for depth
        button.layer.shadowColor = Theme.accent.cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 4)
        button.layer.shadowRadius = 8
        button.layer.shadowOpacity = 0.25
        return button
    }()
    
    private let gradientLayer: CAGradientLayer = {
        let layer = CAGradientLayer()
        layer.colors = [
            UIColor.systemBackground.cgColor,
            Theme.accent.withAlphaComponent(0.1).cgColor,
            UIColor.systemBackground.cgColor
        ]
        layer.locations = [0, 0.5, 1]
        return layer
    }()
    
    private let characterCountLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .regular)
        label.textColor = .secondaryLabel
        label.text = "0/50"
        return label
    }()
    
    private let tipView: UIView = {
        let view = UIView()
        view.backgroundColor = Theme.accent.withAlphaComponent(0.1)
        view.layer.cornerRadius = 12
        return view
    }()
    
    private let tipImageView: UIImageView = {
        let iv = UIImageView()
        let config = UIImage.SymbolConfiguration(pointSize: 20, weight: .medium)
        iv.image = UIImage(systemName: "lightbulb.fill", withConfiguration: config)
        iv.tintColor = Theme.accent
        return iv
    }()
    
    private let tipLabel: UILabel = {
        let label = UILabel()
        label.text = "add_word_tip".localized
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = .secondaryLabel
        label.numberOfLines = 0
        return label
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupDelegates()
        setupKeyboardHandling()
        setupActions()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        gradientLayer.frame = view.bounds
    }
    
    // MARK: - Setup
    private func setupUI() {
        view.backgroundColor = .systemBackground
        navigationItem.largeTitleDisplayMode = .never
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        contentView.addSubview(headerView)
        headerView.addSubview(iconImageView)
        headerView.addSubview(headerLabel)
        headerView.addSubview(subtitleLabel)
        
        contentView.addSubview(formStackView)
        [wordTextField, meaningTextField, exampleTextField, saveButton].forEach {
            formStackView.addArrangedSubview($0)
        }
        
        // Tip view setup
        formStackView.addArrangedSubview(tipView)
        tipView.addSubview(tipImageView)
        tipView.addSubview(tipLabel)
        
        // Character count setup
        wordTextField.addSubview(characterCountLabel)
        
        view.layer.insertSublayer(gradientLayer, at: 0)
        
        setupConstraints()
        setupTextFieldEffects()
    }
    
    private func setupConstraints() {
        scrollView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
        
        contentView.snp.makeConstraints { make in
            make.edges.equalTo(scrollView)
            make.width.equalTo(scrollView)
        }
        
        headerView.snp.makeConstraints { make in
            make.top.leading.trailing.equalTo(contentView)
        }
        
        iconImageView.snp.makeConstraints { make in
            make.top.equalTo(headerView).offset(32)
            make.centerX.equalTo(headerView)
            make.size.equalTo(60)
        }
        
        headerLabel.snp.makeConstraints { make in
            make.top.equalTo(iconImageView.snp.bottom).offset(16)
            make.centerX.equalTo(headerView)
        }
        
        subtitleLabel.snp.makeConstraints { make in
            make.top.equalTo(headerLabel.snp.bottom).offset(8)
            make.centerX.equalTo(headerView)
            make.bottom.equalTo(headerView).offset(-32)
        }
        
        formStackView.snp.makeConstraints { make in
            make.top.equalTo(headerView.snp.bottom)
            make.leading.trailing.bottom.equalTo(contentView)
        }
        
        tipImageView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
            make.size.equalTo(24)
        }
        
        tipLabel.snp.makeConstraints { make in
            make.leading.equalTo(tipImageView.snp.trailing).offset(12)
            make.trailing.equalToSuperview().offset(-16)
            make.top.bottom.equalToSuperview().inset(16)
        }
        
        characterCountLabel.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-16)
            make.centerY.equalToSuperview()
        }
    }
    
    private func setupDelegates() {
        viewModel.delegate = self
    }
    
    private func setupKeyboardHandling() {
        // Implement keyboard handling if needed
    }
    
    private func setupActions() {
        saveButton.addTarget(self, action: #selector(handleSaveButtonTap), for: .touchUpInside)
    }
    
    private func setupTextFieldEffects() {
        [wordTextField, meaningTextField, exampleTextField].forEach { field in
            // Animasyonlu focus efekti
            field.addTarget(self, action: #selector(textFieldDidBeginEditing(_:)), for: .editingDidBegin)
            field.addTarget(self, action: #selector(textFieldDidEndEditing(_:)), for: .editingDidEnd)
            // Karakter sayısı kontrolü
            field.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        }
    }
    
    @objc private func textFieldDidBeginEditing(_ textField: CustomTextField) {
        UIView.animate(withDuration: 0.3) {
            textField.transform = CGAffineTransform(scaleX: 1.02, y: 1.02)
            textField.layer.shadowOpacity = 0.2
        }
    }
    
    @objc private func textFieldDidEndEditing(_ textField: CustomTextField) {
        UIView.animate(withDuration: 0.3) {
            textField.transform = .identity
            textField.layer.shadowOpacity = 0
        }
    }
    
    @objc private func textFieldDidChange(_ textField: CustomTextField) {
        guard let text = textField.text else { return }
        
        // Kelime için maksimum karakter sınırı
        if textField == wordTextField {
            let maxLength = 50
            if text.count > maxLength {
                textField.text = String(text.prefix(maxLength))
            }
            characterCountLabel.text = "\(text.count)/\(maxLength)"
            
            // Karakter limiti yaklaşırken uyarı rengi
            if text.count > maxLength - 10 {
                characterCountLabel.textColor = .systemOrange
            } else {
                characterCountLabel.textColor = .secondaryLabel
            }
        }
    }
    
    // MARK: - Actions
    @objc private func handleSaveButtonTap() {
        guard let word = wordTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
              let meaning = meaningTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) else {
            // Hata mesajı göster
            return
        }
        
        let example = exampleTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        
        Task {
            await viewModel.saveWord(
                word: word,
                meaning: meaning,
                example: example
            )
        }
    }
}

// MARK: - AddWordViewModelDelegate
extension AddWordViewController: AddWordViewModelDelegate {
    func didStartLoading() {
        DispatchQueue.main.async { [weak self] in
            LoadingView.shared.show(in: self?.view ?? UIView())
        }
    }
    
    func didFinishLoading() {
        DispatchQueue.main.async { [weak self] in
            LoadingView.shared.hide()
        }
    }
    
    func didReceiveError(_ error: Error) {
        DispatchQueue.main.async { [weak self] in
            LoadingView.shared.hide()
            
            let message = (error as? FirestoreError)?.message ?? error.localizedDescription
            let alert = UIAlertController(
                title: "error".localized,
                message: message,
                preferredStyle: .alert
            )
            
            if error as? FirestoreError == .limitExceeded {
                alert.addAction(UIAlertAction(title: "upgrade_to_premium".localized, style: .default) { [weak self] _ in
                    let premiumVC = PremiumViewController()
                    premiumVC.modalPresentationStyle = .fullScreen
                    self?.present(premiumVC, animated: true)
                })
            }
            
            alert.addAction(UIAlertAction(title: "ok".localized, style: .cancel))
            self?.present(alert, animated: true)
        }
    }
    
    func didSaveWordSuccessfully() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            // Önce LoadingView'ı gizle
            LoadingView.shared.hide()
            
            // Bildirim yayınla
            NotificationCenter.default.post(name: .wordAdded, object: nil)
            
            // Haptic feedback
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
            
            // Animasyonlu başarı göstergesi
            let successView = SuccessView()
            self.view.addSubview(successView)
            successView.translatesAutoresizingMaskIntoConstraints = false
            
            NSLayoutConstraint.activate([
                successView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
                successView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor),
                successView.widthAnchor.constraint(equalToConstant: 200),
                successView.heightAnchor.constraint(equalToConstant: 200)
            ])
            
            successView.animate {
                // Animasyon bittikten sonra
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    // Input alanlarını temizle
                    self.wordTextField.text = nil
                    self.meaningTextField.text = nil
                    self.exampleTextField.text = nil
                    
                    // Klavyeyi kapat
                    self.view.endEditing(true)
                    
                    // Success view'ı kaldır
                    UIView.animate(withDuration: 0.3) {
                        successView.alpha = 0
                    } completion: { _ in
                        successView.removeFromSuperview()
                        
                        // Word TextField'a odaklan
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            self.wordTextField.becomeFirstResponder()
                        }
                    }
                }
            }
        }
    }
}
