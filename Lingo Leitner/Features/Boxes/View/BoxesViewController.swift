import UIKit

final class BoxesViewController: UIViewController {
    // MARK: - Properties
    private let viewModel = BoxesViewModel()
    private var isLoading = false
    
    // MARK: - UI Components
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 16
        layout.minimumInteritemSpacing = 16
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.register(BoxCell.self, forCellWithReuseIdentifier: BoxCell.reuseIdentifier)
        collectionView.contentInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    
    private let emptyStateView: EmptyStateView = {
        let view = EmptyStateView(
            image: UIImage(systemName: "square.stack.3d.up"),
            title: "empty_boxes".localized,
            message: "empty_boxes_message".localized
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
        setupCollectionView()
        setupViewModel()
        setupNotifications()
        
        // CollectionView'ı başlangıçta gizle
        collectionView.isHidden = true
        
        // İlk yüklemeyi yap
        refreshBoxes()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Sadece loading durumunda değilse yenile
        refreshBoxes()
    }
    
    // MARK: - Setup
    private func setupUI() {
        view.backgroundColor = Theme.primary
        
        view.addSubview(collectionView)
        view.addSubview(emptyStateView)
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            emptyStateView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyStateView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            emptyStateView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8)
        ])
    }
    
    private func setupNavigation() {
        title = "boxes".localized
//        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    private func setupCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    private func setupViewModel() {
        viewModel.delegate = self
    }
    
    private func setupNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleWordAdded),
            name: .wordAdded,
            object: nil
        )
    }
    
    private func refreshBoxes() {
        guard !isLoading else { return }
        
        Task { @MainActor in
            await viewModel.fetchBoxes()
        }
    }
    
    @objc private func handleWordAdded() {
        refreshBoxes()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: - UICollectionViewDataSource
extension BoxesViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 5 // Sabit 5 kutu
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: BoxCell.reuseIdentifier,
            for: indexPath
        ) as? BoxCell else {
            return UICollectionViewCell()
        }
        
        let boxNumber = indexPath.item + 1
        let wordCount = viewModel.wordCount(forBox: boxNumber)
        let reviewCount = viewModel.reviewCount(forBox: boxNumber)
        
        cell.configure(
            boxNumber: boxNumber,
            wordCount: wordCount,
            reviewCount: reviewCount
        )
        return cell
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension BoxesViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (collectionView.bounds.width - 48) / 2 // 16 left + 16 right + 16 spacing
        return CGSize(width: width, height: width * 1.2)
    }
}

// MARK: - UICollectionViewDelegate
extension BoxesViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let boxNumber = indexPath.item + 1
        let viewModel = BoxDetailViewModel(boxNumber: boxNumber)
        let detailVC = BoxDetailViewController(viewModel: viewModel)
        navigationController?.pushViewController(detailVC, animated: true)
    }
}

// MARK: - BoxesViewModelDelegate
extension BoxesViewController: BoxesViewModelDelegate {
    func didStartLoading() {
        guard Thread.isMainThread else {
            DispatchQueue.main.async { [weak self] in
                self?.didStartLoading()
            }
            return
        }
        
        isLoading = true
        LoadingView.shared.show(in: view)
        emptyStateView.isHidden = true
        collectionView.isHidden = true
    }
    
    func didFinishLoading() {
        guard Thread.isMainThread else {
            DispatchQueue.main.async { [weak self] in
                self?.didFinishLoading()
            }
            return
        }
        
        isLoading = false
        LoadingView.shared.hide()
        
        let totalWords = (1...5).reduce(0) { $0 + viewModel.wordCount(forBox: $1) }
        
        if totalWords > 0 {
            emptyStateView.isHidden = true
            collectionView.isHidden = false
        } else {
            emptyStateView.isHidden = false
            collectionView.isHidden = true
        }
        
        collectionView.reloadData()
    }
    
    func didReceiveError(_ error: Error) {
        guard Thread.isMainThread else {
            DispatchQueue.main.async { [weak self] in
                self?.didReceiveError(error)
            }
            return
        }
        
        isLoading = false
        LoadingView.shared.hide()
        
        let alert = UIAlertController(
            title: "error".localized,
            message: error.localizedDescription,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "ok".localized, style: .default))
        present(alert, animated: true)
    }
} 
