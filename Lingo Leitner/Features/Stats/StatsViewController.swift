import UIKit

final class StatsViewController: UIViewController {
    
    // MARK: - Properties
    private let emptyStateView: EmptyStateView = {
        let view = EmptyStateView(
            image: UIImage(systemName: "chart.bar"),
            title: "Henüz İstatistik Yok",
            message: "Kelime öğrenmeye başladığınızda istatistikleriniz burada görünecek"
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
        title = "İstatistik"
        navigationController?.navigationBar.prefersLargeTitles = true
    }
} 