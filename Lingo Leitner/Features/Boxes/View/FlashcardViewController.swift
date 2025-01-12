import UIKit

final class FlashcardViewController: UIViewController {
    // MARK: - Properties
    private let viewModel: FlashcardViewModel
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
    
    private lazy var rememberButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Hatırladım", for: .normal)
        button.titleLabel?.font = Theme.font(.headline, .medium)
        button.backgroundColor = .systemGreen
        button.tintColor = .white
        button.layer.cornerRadius = 12
        button.addTarget(self, action: #selector(handleRememberTap), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var forgotButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Hatırlamadım", for: .normal)
        button.titleLabel?.font = Theme.font(.headline, .medium)
        button.backgroundColor = .systemRed
        button.tintColor = .white
        button.layer.cornerRadius = 12
        button.addTarget(self, action: #selector(handleForgotTap), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // MARK: - Init
    init(viewModel: FlashcardViewModel) {
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
        updateCard()
    }
    
    // MARK: - Setup
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        view.addSubview(cardView)
        cardView.addSubview(wordLabel)
        cardView.addSubview(exampleLabel)
        view.addSubview(rememberButton)
        view.addSubview(forgotButton)
        
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
            forgotButton.heightAnchor.constraint(equalToConstant: 56)
        ])
    }
    
    private func setupGestures() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleCardTap))
        cardView.addGestureRecognizer(tapGesture)
        cardView.isUserInteractionEnabled = true
    }
    
    // MARK: - Actions
    @objc private func handleCardTap() {
        UIView.transition(with: cardView, duration: 0.3, options: .transitionFlipFromRight) {
            self.isShowingMeaning.toggle()
            self.updateCard()
        }
    }
    
    @objc private func handleRememberTap() {
        Task {
            do {
                try await viewModel.moveWordToNextBox()
                dismiss(animated: true)
            } catch {
                showError(error)
            }
        }
    }
    
    @objc private func handleForgotTap() {
        Task {
            do {
                try await viewModel.moveWordToPreviousBox()
                dismiss(animated: true)
            } catch {
                showError(error)
            }
        }
    }
    
    private func updateCard() {
        if isShowingMeaning {
            wordLabel.text = viewModel.currentWord.meaning
            exampleLabel.text = nil
        } else {
            wordLabel.text = viewModel.currentWord.word
            exampleLabel.text = viewModel.currentWord.example
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