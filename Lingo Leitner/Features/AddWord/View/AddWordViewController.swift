import UIKit

final class AddWordViewController: UIViewController {
    // MARK: - Properties
    private let viewModel = AddWordViewModel()
    
    // MARK: - UI Components
    private let scrollView: UIScrollView = {
        let scroll = UIScrollView()
        scroll.translatesAutoresizingMaskIntoConstraints = false
        scroll.showsVerticalScrollIndicator = false
        return scroll
    }()
    
    private let containerStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 32
        stack.layoutMargins = UIEdgeInsets(top: 24, left: 24, bottom: 24, right: 24)
        stack.isLayoutMarginsRelativeArrangement = true
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private let headerLabel: UILabel = {
        let label = UILabel()
        label.text = "Yeni Kelime Ekle"
        label.font = Theme.font(.title1, .bold)
        label.textAlignment = .center
        return label
    }()
    
    private let wordTextField: CustomTextField = {
        let textField = CustomTextField()
        textField.configure(
            icon: "textformat",
            placeholder: "Kelime",
            keyboardType: .default,
            returnKeyType: .next
        )
        return textField
    }()
    
    private let meaningTextField: CustomTextField = {
        let textField = CustomTextField()
        textField.configure(
            icon: "text.book.closed",
            placeholder: "Anlamı",
            keyboardType: .default,
            returnKeyType: .next
        )
        return textField
    }()
    
    private let exampleTextField: CustomTextField = {
        let textField = CustomTextField()
        textField.configure(
            icon: "text.quote",
            placeholder: "Örnek Cümle (Opsiyonel)",
            keyboardType: .default,
            returnKeyType: .done
        )
        return textField
    }()
    
    private let difficultyControl: UISegmentedControl = {
        let control = UISegmentedControl(items: ["Kolay", "Orta", "Zor"])
        control.selectedSegmentIndex = 0
        control.backgroundColor = .systemBackground
        control.selectedSegmentTintColor = Theme.accent
        let titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.label]
        let selectedTitleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        control.setTitleTextAttributes(titleTextAttributes, for: .normal)
        control.setTitleTextAttributes(selectedTitleTextAttributes, for: .selected)
        control.heightAnchor.constraint(equalToConstant: 44).isActive = true
        return control
    }()
    
    private let saveButton: LoadingButton = {
        let button = LoadingButton(style: .primary)
        button.setTitle("Kaydet", for: .normal)
        button.heightAnchor.constraint(equalToConstant: 54).isActive = true
        return button
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupDelegates()
        setupKeyboardHandling()
        setupActions()
    }
    
    // MARK: - Setup
    private func setupUI() {
        view.backgroundColor = .systemBackground
        navigationItem.largeTitleDisplayMode = .never
        
        view.addSubview(scrollView)
        scrollView.addSubview(containerStackView)
        
        [headerLabel, wordTextField, meaningTextField, exampleTextField, 
         difficultyControl, saveButton].forEach {
            containerStackView.addArrangedSubview($0)
        }
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            containerStackView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            containerStackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            containerStackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            containerStackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            containerStackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
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
    
    // MARK: - Actions
    @objc private func handleSaveButtonTap() {
        guard let word = wordTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
              let meaning = meaningTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) else {
            return
        }
        
        let example = exampleTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        let difficulty = Difficulty.allCases[difficultyControl.selectedSegmentIndex]
        
        Task {
            await viewModel.saveWord(
                word: word,
                meaning: meaning,
                example: example,
                difficulty: difficulty
            )
        }
    }
}

// MARK: - AddWordViewModelDelegate
extension AddWordViewController: AddWordViewModelDelegate {
    func didStartLoading() {
        // Implement loading indicator if needed
    }
    
    func didFinishLoading() {
        // Implement loading indicator if needed
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
    
    func didSaveWordSuccessfully() {
        // Haptic feedback
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
        
        // Animasyonlu başarı göstergesi
        let successView = SuccessView()
        view.addSubview(successView)
        successView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            successView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            successView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
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
                self.difficultyControl.selectedSegmentIndex = 0
                
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
