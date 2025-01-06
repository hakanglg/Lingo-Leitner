import UIKit

final class BoxesViewController: UIViewController {
    
    // MARK: - Properties
    private let emptyStateView: EmptyStateView = {
        let view = EmptyStateView(
            image: UIImage(systemName: "square.stack.3d.up"),
            title: "Kutularınız Boş",
            message: "Kelimeleriniz kutuları doldurmayı bekliyor"
        )
        return view
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupNavigation()
    }
    
    // MARK: - Setup
    private func setupUI() {
        view.backgroundColor = Theme.primary
        
        view.addSubview(emptyStateView)
        emptyStateView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            emptyStateView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyStateView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            emptyStateView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Theme.spacing(2)),
            emptyStateView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Theme.spacing(2))
        ])
    }
    
    private func setupNavigation() {
        title = "Kutular"
        navigationController?.navigationBar.prefersLargeTitles = true
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