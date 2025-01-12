import UIKit

final class BoxDetailViewController: UIViewController {
    // MARK: - Properties
    private let viewModel: BoxDetailViewModel
    private var currentWordIndex = 0
    private var isShowingMeaning = false
    
    // MARK: - UI Components
    private let cardView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
        view.layer.cornerRadius = 16
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 4)
        view.layer.shadowRadius = 8
        view.layer.shadowOpacity = 0.1
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let wordLabel: UILabel = {
        let label = UILabel()
        label.font = Theme.font(.title1, .bold)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let exampleLabel: UILabel = {
        let label = UILabel()
        label.font = Theme.font(.body)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var rememberButton: GradientButton = {
        let button = GradientButton(title: "remember".localized)
        button.addTarget(self, action: #selector(handleRememberTap), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var forgotButton: GradientButton = {
        let button = GradientButton(title: "forgot".localized)
        button.addTarget(self, action: #selector(handleForgotTap), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let loadingView: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView(style: .medium)
        view.hidesWhenStopped = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let emptyStateView: EmptyStateView = {
        let view = EmptyStateView(
            image: UIImage(systemName: "tray"),
            title: "Kutu Boş",
            message: "Bu kutuda henüz kelime bulunmuyor"
        )
        view.isHidden = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // MARK: - Init
    init(viewModel: BoxDetailViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupGestures()
        setupNavigation()
        setupViewModel()
        Task {
            await viewModel.fetchWords()
        }
    }
    
    // MARK: - Setup
    private func setupUI() {
        view.backgroundColor = Theme.primary
        
        view.addSubview(cardView)
        cardView.addSubview(wordLabel)
        cardView.addSubview(exampleLabel)
        view.addSubview(rememberButton)
        view.addSubview(forgotButton)
        view.addSubview(loadingView)
        view.addSubview(emptyStateView)
        
        NSLayoutConstraint.activate([
            cardView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            cardView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            cardView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            cardView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32),
            cardView.heightAnchor.constraint(equalTo: cardView.widthAnchor, multiplier: 1.4),
            
            wordLabel.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 32),
            wordLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
            wordLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16),
            
            exampleLabel.topAnchor.constraint(equalTo: wordLabel.bottomAnchor, constant: 16),
            exampleLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
            exampleLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16),
            
            rememberButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            rememberButton.trailingAnchor.constraint(equalTo: view.centerXAnchor, constant: -8),
            rememberButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -32),
            rememberButton.heightAnchor.constraint(equalToConstant: 56),
            
            forgotButton.leadingAnchor.constraint(equalTo: view.centerXAnchor, constant: 8),
            forgotButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32),
            forgotButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -32),
            forgotButton.heightAnchor.constraint(equalToConstant: 56),
            
            loadingView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            emptyStateView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyStateView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            emptyStateView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8)
        ])
    }
    
    private func setupNavigation() {
        title = "Kutu \(viewModel.boxNumber)"
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "xmark"),
            style: .plain,
            target: self,
            action: #selector(handleCloseTap)
        )
    }
    
    private func setupGestures() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleCardTap))
        cardView.addGestureRecognizer(tapGesture)
        cardView.isUserInteractionEnabled = true
    }
    
    private func setupViewModel() {
        viewModel.delegate = self
    }
    
    // MARK: - Actions
    @objc private func handleCloseTap() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func handleCardTap() {
        UIView.transition(with: cardView, duration: 0.3, options: .transitionFlipFromRight) {
            self.isShowingMeaning.toggle()
            self.updateCard()
        }
    }
    
    @objc private func handleRememberTap() {
        Task {
            do {
                try await viewModel.moveWordToNextBox(at: currentWordIndex)
                moveToNextWord()
            } catch {
                showError(error)
            }
        }
    }
    
    @objc private func handleForgotTap() {
        Task {
            do {
                try await viewModel.moveWordToPreviousBox(at: currentWordIndex)
                moveToNextWord()
            } catch {
                showError(error)
            }
        }
    }
    
    private func moveToNextWord() {
        currentWordIndex += 1
        if currentWordIndex >= viewModel.words.count {
            // Tüm kelimeler bitti, geri dön
            navigationController?.popViewController(animated: true)
        } else {
            isShowingMeaning = false
            updateCard()
        }
    }
    
    private func updateCard() {
        guard currentWordIndex < viewModel.words.count else { return }
        
        let currentWord = viewModel.words[currentWordIndex]
        if isShowingMeaning {
            wordLabel.text = currentWord.meaning
            exampleLabel.text = nil
        } else {
            wordLabel.text = currentWord.word
            exampleLabel.text = currentWord.example
        }
    }
    
    private func showError(_ error: Error) {
        let alert = UIAlertController(
            title: "error".localized,
            message: error.localizedDescription,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "ok".localized, style: .default))
        present(alert, animated: true)
    }
}

// MARK: - BoxDetailViewModelDelegate
extension BoxDetailViewController: BoxDetailViewModelDelegate {
    func didStartLoading() {
        loadingView.startAnimating()
        cardView.isHidden = true
        rememberButton.isHidden = true
        forgotButton.isHidden = true
        emptyStateView.isHidden = true
    }
    
    func didFinishLoading() {
        loadingView.stopAnimating()
        
        if viewModel.words.isEmpty {
            emptyStateView.isHidden = false
            cardView.isHidden = true
            rememberButton.isHidden = true
            forgotButton.isHidden = true
        } else {
            emptyStateView.isHidden = true
            cardView.isHidden = false
            rememberButton.isHidden = false
            forgotButton.isHidden = false
            updateCard()
        }
    }
    
    func didReceiveError(_ error: Error) {
        showError(error)
    }
} 