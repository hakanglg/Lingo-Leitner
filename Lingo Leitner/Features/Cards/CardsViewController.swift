import UIKit

final class CardsViewController: UIViewController {
    
    // MARK: - Properties
    private let emptyStateView: EmptyStateView = {
        let view = EmptyStateView(
            image: UIImage(systemName: "rectangle.stack.badge.plus")?.withConfiguration(
                UIImage.SymbolConfiguration(pointSize: 48, weight: .medium)
            ),
            title: "Kelime Kartı Ekle",
            message: "Öğrenmek istediğiniz kelimeleri ekleyerek başlayın"
        )
        return view
    }()
    
    private let addButton: GradientButton = {
        let button = GradientButton(title: "Yeni Kelime Ekle")
        button.heightAnchor.constraint(equalToConstant: 56).isActive = true // Apple'ın minimum 44pt önerisi
        return button
    }()
    
    private let floatingAddButton: UIButton = {
        let button = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: 24, weight: .medium)
        let image = UIImage(systemName: "plus.circle.fill", withConfiguration: config)
        button.setImage(image, for: .normal)
        button.tintColor = Theme.gradient[0]
        
        // Apple'ın minimum dokunma alanı önerisi (44x44)
        button.contentEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 4)
        button.layer.shadowRadius = 8
        button.layer.shadowOpacity = 0.15
        return button
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
        
        [emptyStateView, addButton, floatingAddButton].forEach {
            view.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        // TabBar yüksekliğini hesaplayalım
        let window = UIApplication.shared.windows.first
        let bottomPadding = window?.safeAreaInsets.bottom ?? 0
        let tabBarHeight: CGFloat = 64 + 8 + bottomPadding
        
        NSLayoutConstraint.activate([
            emptyStateView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyStateView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -tabBarHeight/2),
            emptyStateView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Theme.spacing(2)),
            emptyStateView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Theme.spacing(2)),
            
            addButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -(tabBarHeight + Theme.spacing(2))),
            addButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Theme.spacing(2)),
            addButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Theme.spacing(2)),
            
            floatingAddButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Theme.spacing(2)),
            floatingAddButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -(tabBarHeight + Theme.spacing(2))),
            floatingAddButton.widthAnchor.constraint(equalToConstant: 56),
            floatingAddButton.heightAnchor.constraint(equalToConstant: 56)
        ])
        
        setupActions()
    }
    
    private func setupNavigation() {
        title = "Kelimeler"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        let addBarButton = UIBarButtonItem(
            image: UIImage(systemName: "plus.circle.fill")?.withConfiguration(
                UIImage.SymbolConfiguration(pointSize: 24, weight: .medium)
            ),
            style: .done,
            target: self,
            action: #selector(handleAddTap)
        )
        navigationItem.rightBarButtonItem = addBarButton
    }
    
    private func setupActions() {
        [addButton, floatingAddButton].forEach {
            $0.addTarget(self, action: #selector(handleAddTap), for: .touchUpInside)
        }
    }
    
    // MARK: - Actions
    @objc private func handleAddTap() {
        // Haptic feedback ekleyelim
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
        
        // TODO: Yeni kelime ekleme ekranına geçiş yapılacak
        print("Yeni kelime ekleme ekranı açılacak")
    }
} 
