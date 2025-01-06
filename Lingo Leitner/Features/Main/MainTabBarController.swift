import UIKit

final class MainTabBarController: UITabBarController {
    
    // MARK: - Properties
    private let customTabBar = CustomTabBar()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabs()
        setupCustomTabBar()
    }
    
    // MARK: - Setup
    private func setupTabs() {
        let cardsVC = createNavigationController(
            rootViewController: CardsViewController(),
            title: "Ana Sayfa",
            image: "house",
            selectedImage: "house.fill"
        )
        
        let boxesVC = createNavigationController(
            rootViewController: BoxesViewController(),
            title: "Favoriler",
            image: "heart",
            selectedImage: "heart.fill"
        )
        
        let statsVC = createNavigationController(
            rootViewController: StatsViewController(),
            title: "Ekle",
            image: "plus",
            selectedImage: "plus.circle.fill"
        )
        
        let profileVC = createNavigationController(
            rootViewController: ProfileViewController(),
            title: "Profil",
            image: "person",
            selectedImage: "person.fill"
        )
        
        let notificationsVC = createNavigationController(
            rootViewController: NotificationsViewController(),
            title: "Bildirimler",
            image: "bell",
            selectedImage: "bell.fill"
        )
        
        viewControllers = [cardsVC, boxesVC, statsVC, profileVC, notificationsVC]
        tabBar.isHidden = true
    }
    
    private func setupCustomTabBar() {
        view.addSubview(customTabBar)
        customTabBar.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            customTabBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            customTabBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            customTabBar.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -8),
            customTabBar.heightAnchor.constraint(equalToConstant: 64)
        ])
        
        customTabBar.items = viewControllers?.map { vc in
            TabBarItem(
                title: vc.tabBarItem.title ?? "",
                image: vc.tabBarItem.image,
                selectedImage: vc.tabBarItem.selectedImage
            )
        } ?? []
        
        customTabBar.selectedIndex = 0
        customTabBar.delegate = self
    }
    
    private func createNavigationController(
        rootViewController: UIViewController,
        title: String,
        image: String,
        selectedImage: String
    ) -> UINavigationController {
        let nav = UINavigationController(rootViewController: rootViewController)
        nav.tabBarItem.title = title
        nav.tabBarItem.image = UIImage(systemName: image)
        nav.tabBarItem.selectedImage = UIImage(systemName: selectedImage)
        return nav
    }
}

// MARK: - CustomTabBarDelegate
extension MainTabBarController: CustomTabBarDelegate {
    func customTabBar(_ tabBar: CustomTabBar, didSelectItemAt index: Int) {
        selectedIndex = index
    }
}

// MARK: - CustomTabBar
final class CustomTabBar: UIView {
    
    // MARK: - Properties
    weak var delegate: CustomTabBarDelegate?
    
    var items: [TabBarItem] = [] {
        didSet { setupItems() }
    }
    
    var selectedIndex: Int = 0 {
        didSet { updateSelection() }
    }
    
    private let stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .equalSpacing
        stack.alignment = .center
        return stack
    }()
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    private func setupView() {
        backgroundColor = .systemBackground
        layer.cornerRadius = 32
        
        // Gölge efekti
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 4)
        layer.shadowRadius = 16
        layer.shadowOpacity = 0.1
        
        addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 24),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -24),
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    private func setupItems() {
        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        items.enumerated().forEach { index, item in
            let button = createTabButton(with: item, at: index)
            stackView.addArrangedSubview(button)
        }
        
        updateSelection()
    }
    
    private func createTabButton(with item: TabBarItem, at index: Int) -> UIButton {
        let button = UIButton()
        button.tag = index
        button.tintColor = .secondaryLabel
        button.setImage(item.image, for: .normal)
        button.addTarget(self, action: #selector(handleTabTap(_:)), for: .touchUpInside)
        
        NSLayoutConstraint.activate([
            button.widthAnchor.constraint(equalToConstant: 44),
            button.heightAnchor.constraint(equalToConstant: 44)
        ])
        
        return button
    }
    
    private func updateSelection() {
        stackView.arrangedSubviews.enumerated().forEach { index, view in
            guard let button = view as? UIButton else { return }
            
            if index == selectedIndex {
                button.tintColor = Theme.gradient[0]
                animateSelection(for: button)
            } else {
                button.tintColor = .secondaryLabel
                button.transform = .identity
            }
        }
    }
    
    private func animateSelection(for button: UIButton) {
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5) {
            button.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
        }
    }
    
    // MARK: - Actions
    @objc private func handleTabTap(_ sender: UIButton) {
        selectedIndex = sender.tag
        delegate?.customTabBar(self, didSelectItemAt: sender.tag)
    }
}

// MARK: - Protocols & Models
protocol CustomTabBarDelegate: AnyObject {
    func customTabBar(_ tabBar: CustomTabBar, didSelectItemAt index: Int)
}

struct TabBarItem {
    let title: String
    let image: UIImage?
    let selectedImage: UIImage?
}

// MARK: - NotificationsViewController (Placeholder)
class NotificationsViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Theme.primary
        title = "Bildirimler"
    }
} 