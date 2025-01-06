import UIKit

final class OnboardingViewController: UIViewController {
    
    // MARK: - Properties
    private let viewModel: OnboardingViewModel
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .clear
        cv.isPagingEnabled = true
        cv.showsHorizontalScrollIndicator = false
        cv.delegate = self
        cv.dataSource = self
        return cv
    }()
    
    private lazy var pageControl: UIPageControl = {
        let pc = UIPageControl()
        pc.numberOfPages = viewModel.slides.count
        pc.currentPage = 0
        
        if #available(iOS 14.0, *) {
            pc.backgroundStyle = .prominent
            pc.preferredIndicatorImage = UIImage(systemName: "circle.fill")
        }
        
        return pc
    }()
    
    private lazy var nextButton: GradientButton = {
        let button = GradientButton(title: "İleri")
        return button
    }()
    
    private var currentPage = 0 {
        didSet {
            pageControl.currentPage = currentPage
            if currentPage == viewModel.slides.count - 1 {
                nextButton.updateTitle("Başla")
            } else {
                nextButton.updateTitle("İleri")
            }
        }
    }
    
    // MARK: - Lifecycle
    init(viewModel: OnboardingViewModel = OnboardingViewModel()) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Theme.primary
        setupUI()
        configureCollectionView()
        setupActions()
    }
    
    // MARK: - Setup
    private func setupUI() {
        [collectionView, pageControl, nextButton].forEach {
            view.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: pageControl.topAnchor, constant: -Theme.spacing(4)),
            
            pageControl.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            pageControl.bottomAnchor.constraint(equalTo: nextButton.topAnchor, constant: -Theme.spacing(4)),
            
            nextButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Theme.spacing(4)),
            nextButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Theme.spacing(4)),
            nextButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -Theme.spacing(4)),
            nextButton.heightAnchor.constraint(equalToConstant: 56)
        ])
    }
    
    private func configureCollectionView() {
        collectionView.register(OnboardingCell.self, forCellWithReuseIdentifier: OnboardingCell.identifier)
    }
    
    private func setupActions() {
        nextButton.addTarget(self, action: #selector(handleNextButtonTap), for: .touchUpInside)
    }
    
    // MARK: - Actions
    @objc private func handleNextButtonTap() {
        if currentPage == viewModel.slides.count - 1 {
            // Son sayfadayız, ana uygulamaya geçiş yapalım
            UserDefaults.standard.set(true, forKey: "hasSeenOnboarding")
            navigateToAuth()
        } else {
            // Sonraki sayfaya geçelim
            currentPage += 1
            let indexPath = IndexPath(item: currentPage, section: 0)
            collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        }
    }
    
    private func navigateToAuth() {
        let authVC = AuthViewController()
        let nav = UINavigationController(rootViewController: authVC)
        nav.modalPresentationStyle = .fullScreen
        present(nav, animated: true)
    }
}

// MARK: - UICollectionViewDataSource
extension OnboardingViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.slides.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: OnboardingCell.identifier, for: indexPath) as? OnboardingCell else {
            return UICollectionViewCell()
        }
        
        let slide = viewModel.slides[indexPath.item]
        cell.configure(with: slide)
        return cell
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension OnboardingViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return collectionView.bounds.size
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let width = scrollView.bounds.width
        currentPage = Int(scrollView.contentOffset.x / width)
    }
} 
