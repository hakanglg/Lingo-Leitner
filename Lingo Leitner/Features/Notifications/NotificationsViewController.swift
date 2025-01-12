import UIKit

final class NotificationsViewController: UIViewController {
    // MARK: - Properties
    private let viewModel = NotificationsViewModel()
    

    
    private let tableView: UITableView = {
        let table = UITableView()
        table.backgroundColor = .clear
        table.separatorStyle = .none
        table.register(NotificationCell.self, forCellReuseIdentifier: NotificationCell.reuseIdentifier)
        table.translatesAutoresizingMaskIntoConstraints = false
        return table
    }()
    
    private let loadingView: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView(style: .medium)
        view.hidesWhenStopped = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let emptyStateView: EmptyStateView = {
        let view = EmptyStateView(
            image: UIImage(systemName: "bell.slash"),
            title: "no_notifications".localized,
            message: "no_notifications_message".localized
        )
        view.isHidden = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupNavigation()
        setupTableView()
        setupViewModel()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        Task {
            await viewModel.fetchNotifications()
        }
    }
    

    // MARK: - Setup
    private func setupUI() {
    
        title = "notifications".localized
        view.backgroundColor = Theme.primary
        
        view.addSubview(tableView)
        view.addSubview(loadingView)
        view.addSubview(emptyStateView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            loadingView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            emptyStateView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyStateView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            emptyStateView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8)
        ])
    }
    
    private func setupNavigation() {
        title = "notifications".localized
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    private func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    private func setupViewModel() {
        viewModel.delegate = self
    }
} 

// MARK: - UITableViewDataSource
extension NotificationsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.dueWords.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: NotificationCell.reuseIdentifier,
            for: indexPath
        ) as? NotificationCell else {
            return UITableViewCell()
        }
        
        let word = viewModel.dueWords[indexPath.row]
        cell.configure(with: word)
        return cell
    }
}

// MARK: - UITableViewDelegate
extension NotificationsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // TODO: Kelimeyi göster veya tekrar et
    }
}

// MARK: - NotificationsViewModelDelegate
extension NotificationsViewController: NotificationsViewModelDelegate {
    func didStartLoading() {
        loadingView.startAnimating()
        emptyStateView.isHidden = true
    }
    
    func didFinishLoading() {
        loadingView.stopAnimating()
        emptyStateView.isHidden = !viewModel.dueWords.isEmpty
        tableView.isHidden = viewModel.dueWords.isEmpty
        tableView.reloadData()
    }
    
    func didReceiveError(_ error: Error) {
        let alert = UIAlertController(
            title: "error".localized,
            message: error.localizedDescription,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "ok".localized, style: .default))
        present(alert, animated: true)
    }
} 
