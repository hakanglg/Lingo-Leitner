import UIKit

final class ProfileViewController: UIViewController {
    
    // MARK: - Properties
    private let signOutButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Çıkış Yap", for: .normal)
        button.setTitleColor(.systemRed, for: .normal)
        button.backgroundColor = .systemBackground
        button.layer.cornerRadius = Theme.cornerRadius
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.systemRed.cgColor
        button.heightAnchor.constraint(equalToConstant: 56).isActive = true
        return button
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupActions()
    }
    
    // MARK: - Setup
    private func setupUI() {
        view.backgroundColor = Theme.primary
        title = "Profil"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        view.addSubview(signOutButton)
        signOutButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            signOutButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Theme.spacing(2)),
            signOutButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Theme.spacing(2)),
            signOutButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -Theme.spacing(2))
        ])
    }
    
    private func setupActions() {
        signOutButton.addTarget(self, action: #selector(handleSignOutTap), for: .touchUpInside)
    }
    
    // MARK: - Actions
    @objc private func handleSignOutTap() {
        let alert = UIAlertController(
            title: "Çıkış Yap",
            message: "Çıkış yapmak istediğinize emin misiniz?",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "İptal", style: .cancel))
        alert.addAction(UIAlertAction(title: "Çıkış Yap", style: .destructive) { [weak self] _ in
            do {
                try AuthManager.shared.signOut()
                self?.navigateToAuth()
            } catch {
                self?.showError(error)
            }
        })
        
        present(alert, animated: true)
    }
    
    private func navigateToAuth() {
        let authVC = AuthViewController()
        let nav = UINavigationController(rootViewController: authVC)
        nav.modalPresentationStyle = .fullScreen
        present(nav, animated: true)
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
} 
