import UIKit

final class BoxDetailViewController: UIViewController {
    // MARK: - Properties
    private let boxNumber: Int
    private let viewModel: BoxDetailViewModel
    
    private let tableView: UITableView = {
        let table = UITableView()
        table.backgroundColor = .clear
        table.separatorStyle = .none
        table.register(WordCell.self, forCellReuseIdentifier: WordCell.reuseIdentifier)
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
            image: UIImage(systemName: "tray"),
            title: "Bu Kutu Boş",
            message: "Bu kutuda henüz kelime bulunmuyor"
        )
        view.isHidden = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // MARK: - Init
    init(boxNumber: Int) {
        self.boxNumber = boxNumber
        self.viewModel = BoxDetailViewModel(boxNumber: boxNumber)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
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
            await viewModel.fetchWords()
        }
    }
    
    // MARK: - Setup
    private func setupUI() {
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
            emptyStateView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Theme.spacing(2)),
            emptyStateView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Theme.spacing(2))
        ])
    }
    
    private func setupNavigation() {
        title = "Kutu \(boxNumber)"
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
extension BoxDetailViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.words.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: WordCell.reuseIdentifier,
            for: indexPath
        ) as? WordCell else {
            return UITableViewCell()
        }
        
        let word = viewModel.words[indexPath.row]
        cell.configure(with: word)
        return cell
    }
}

// MARK: - UITableViewDelegate
extension BoxDetailViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
}

// MARK: - BoxDetailViewModelDelegate
extension BoxDetailViewController: BoxDetailViewModelDelegate {
    func didStartLoading() {
        loadingView.startAnimating()
        emptyStateView.isHidden = true
    }
    
    func didFinishLoading() {
        loadingView.stopAnimating()
        emptyStateView.isHidden = !viewModel.words.isEmpty
        tableView.isHidden = viewModel.words.isEmpty
        tableView.reloadData()
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
} 