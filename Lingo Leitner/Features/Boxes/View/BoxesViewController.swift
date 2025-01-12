import UIKit

final class BoxesViewController: UIViewController {
    // MARK: - Properties
    private let viewModel = BoxesViewModel()
    
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
        
        // CollectionView'ı başlangıçta gizle
        collectionView.isHidden = true
        
        // Verileri yükle
        Task {
            await viewModel.fetchBoxes()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Eğer collectionView görünürse (yani kelime varsa) verileri yenile
        if !collectionView.isHidden {
            Task {
                await viewModel.fetchBoxes()
            }
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
            emptyStateView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8)
        ])
    }
    
    private func setupNavigation() {
        title = "Kutular"
//        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    private func setupCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    private func setupViewModel() {
        viewModel.delegate = self
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
        DispatchQueue.main.async { [weak self] in
            self?.loadingView.startAnimating()
            self?.emptyStateView.isHidden = true
            self?.collectionView.isHidden = true
        }
    }
    
    func didFinishLoading() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            self.loadingView.stopAnimating()
            
            // Tüm kutulardaki toplam kelime sayısını kontrol et
            let totalWords = (1...5).reduce(0) { $0 + self.viewModel.wordCount(forBox: $1) }
            
            if totalWords > 0 {
                self.emptyStateView.isHidden = true
                self.collectionView.isHidden = false
            } else {
                self.emptyStateView.isHidden = false
                self.collectionView.isHidden = true
            }
            
            self.collectionView.reloadData()
        }
    }
    
    func didReceiveError(_ error: Error) {
        DispatchQueue.main.async { [weak self] in
            let alert = UIAlertController(
                title: "Hata",
                message: error.localizedDescription,
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "Tamam", style: .default))
            self?.present(alert, animated: true)
        }
    }
} 
