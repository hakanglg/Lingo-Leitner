import UIKit

final class MainTabBarController: UITabBarController {
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabs()
        setupAppearance()
    }
    
    // MARK: - Setup
    private func setupTabs() {
        let boxesVC = createNavigationController(
            rootViewController: BoxesViewController(),
            title: "Kutular",
            image: UIImage(systemName: "square.stack.3d.up"),
            selectedImage: UIImage(systemName: "square.stack.3d.up.fill")
        )
        
        let addWordVC = createNavigationController(
            rootViewController: AddWordViewController(),
            title: "Kelime Ekle",
            image: UIImage(systemName: "plus.circle"),
            selectedImage: UIImage(systemName: "plus.circle.fill")
        )
        
        let notificationsVC = createNavigationController(
            rootViewController: NotificationsViewController(),
            title: "Tekrarlar",
            image: UIImage(systemName: "bell"),
            selectedImage: UIImage(systemName: "bell.fill")
        )
        
        let profileVC = createNavigationController(
            rootViewController: ProfileViewController(),
            title: "Profil",
            image: UIImage(systemName: "person"),
            selectedImage: UIImage(systemName: "person.fill")
        )
        
        viewControllers = [boxesVC, addWordVC, notificationsVC, profileVC]
    }
    
    private func setupAppearance() {
        // Tab Bar Görünümü
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .systemBackground
        
        // Normal Durum
        appearance.stackedLayoutAppearance.normal.iconColor = .secondaryLabel
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [
            .foregroundColor: UIColor.secondaryLabel,
            .font: Theme.font(.caption2)
        ]
        
        // Seçili Durum
        appearance.stackedLayoutAppearance.selected.iconColor = Theme.accent
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [
            .foregroundColor: Theme.accent,
            .font: Theme.font(.caption2, .medium)
        ]
        
        // Gölge Efekti
        appearance.shadowColor = .black.withAlphaComponent(0.1)
        
        tabBar.standardAppearance = appearance
        if #available(iOS 15.0, *) {
            tabBar.scrollEdgeAppearance = appearance
        }
    }
    
    private func createNavigationController(
        rootViewController: UIViewController,
        title: String,
        image: UIImage?,
        selectedImage: UIImage?
    ) -> UINavigationController {
        let navigationController = UINavigationController(rootViewController: rootViewController)
        
        // Tab Bar Item
        navigationController.tabBarItem.title = title
        navigationController.tabBarItem.image = image
        navigationController.tabBarItem.selectedImage = selectedImage
        
        // Navigation Bar Görünümü
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .systemBackground
        appearance.titleTextAttributes = [
            .foregroundColor: UIColor.label,
            .font: Theme.font(.headline, .medium)
        ]
        appearance.largeTitleTextAttributes = [
            .foregroundColor: UIColor.label,
            .font: Theme.font(.largeTitle, .bold)
        ]
        
        navigationController.navigationBar.standardAppearance = appearance
        navigationController.navigationBar.scrollEdgeAppearance = appearance
        navigationController.navigationBar.compactAppearance = appearance
        
        return navigationController
    }
}
