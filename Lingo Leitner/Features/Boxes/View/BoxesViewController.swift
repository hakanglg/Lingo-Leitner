import UIKit

final class BoxesViewController: UIViewController {
    // MARK: - Properties
    private let viewModel = BoxesViewModel()
    
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 16
        layout.minimumLineSpacing = 16
        layout.sectionInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.register(BoxCell.self, forCellWithReuseIdentifier: BoxCell.reuseIdentifier)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    
    private let loadingView: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView(style: .medium)
        view.hidesWhenStopped = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let emptyStateView: EmptyStateView = {
        let view = EmptyStateView(
            image: UIImage(systemName: "square.stack.3d.up"),
            title: "Kutularınız Boş",
            message: "Kelimeleriniz kutuları doldurmayı bekliyor"
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
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        Task {
            await viewModel.fetchBoxes()
        }
    }
    
    // MARK: - Setup
    private func setupUI() {
        view.backgroundColor = Theme.primary
        
        view.addSubview(collectionView)
        view.addSubview(loadingView)
        view.addSubview(emptyStateView)
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            loadingView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            emptyStateView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyStateView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            emptyStateView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Theme.spacing(2)),
            emptyStateView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Theme.spacing(2))
        ])
    }
    
    private func setupNavigation() {
        title = "Kelime Kutuları"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        let addButton = UIBarButtonItem(
            image: UIImage(systemName: "plus.circle.fill"),
            style: .plain,
            target: self,
            action: #selector(handleAddTap)
        )
        navigationItem.rightBarButtonItem = addButton
    }
    
    private func setupCollectionView() {
        let layout = UICollectionViewFlowLayout()
        let spacing: CGFloat = 16
        let width = (view.bounds.width - spacing * 3) / 2
        layout.itemSize = CGSize(width: width, height: width * 1.2)
        layout.minimumInteritemSpacing = spacing
        layout.minimumLineSpacing = spacing
        layout.sectionInset = UIEdgeInsets(top: spacing, left: spacing, bottom: spacing, right: spacing)
        
        collectionView.collectionViewLayout = layout
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    private func setupViewModel() {
        viewModel.delegate = self
    }
    
    // MARK: - Actions
    @objc private func handleAddTap() {
        let addWordVC = AddWordViewController()
        navigationController?.pushViewController(addWordVC, animated: true)
    }
}

// MARK: - UICollectionViewDataSource
extension BoxesViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 5 // 5 kutu
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
        cell.configure(boxNumber: boxNumber, wordCount: wordCount, reviewCount: reviewCount)
        return cell
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension BoxesViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (collectionView.bounds.width - 48) / 2 // 2 sütun
        return CGSize(width: width, height: width)
    }
}

// MARK: - UICollectionViewDelegate
extension BoxesViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let boxNumber = indexPath.item + 1
        let boxDetailVC = BoxDetailViewController(boxNumber: boxNumber)
        navigationController?.pushViewController(boxDetailVC, animated: true)
    }
}

// MARK: - BoxesViewModelDelegate
extension BoxesViewController: BoxesViewModelDelegate {
    func didStartLoading() {
        loadingView.startAnimating()
        emptyStateView.isHidden = true
    }
    
    func didFinishLoading() {
        loadingView.stopAnimating()
        
        // Tüm kutulardaki toplam kelime sayısını kontrol et
        let totalWords = (1...5).reduce(0) { $0 + viewModel.wordCount(forBox: $1) }
        emptyStateView.isHidden = totalWords > 0
        collectionView.isHidden = totalWords == 0
        
        collectionView.reloadData()
    }
    
    func didReceiveError(_ error: Error) {
        showError(error)
    }
    
    private func showError(_ error: Error) {
        let alert = UIAlertController(
            title: "Hata",
            message: error.localizedDescription,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Tamam", style: .default))
        present(alert, animated: true)
    }
} 
