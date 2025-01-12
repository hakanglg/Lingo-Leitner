import UIKit
import SnapKit

final class ProfileViewController: UIViewController, ProfileViewModelDelegate {
    
    // MARK: - Properties
    private let viewModel = ProfileViewModel()
    
    // MARK: - UI Components
    private let scrollView: UIScrollView = {
        let scroll = UIScrollView()
        scroll.showsVerticalScrollIndicator = false
        scroll.alwaysBounceVertical = true
        return scroll
    }()
    
    private let contentView: UIView = {
        let view = UIView()
        return view
    }()
    
    private let headerView: UIView = {
        let view = UIView()
        view.backgroundColor = Theme.accent.withAlphaComponent(0.1)
        view.layer.cornerRadius = 24
        return view
    }()
    
    private let profileImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.layer.cornerRadius = 50
        iv.backgroundColor = .secondarySystemBackground
        iv.layer.borderWidth = 3
        iv.layer.borderColor = Theme.accent.cgColor
        
        // Default profile image
        let config = UIImage.SymbolConfiguration(pointSize: 40, weight: .medium)
        iv.image = UIImage(systemName: "person.circle.fill", withConfiguration: config)?.withTintColor(.systemGray, renderingMode: .alwaysOriginal)
        return iv
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 24, weight: .bold)
        label.textColor = .label
        label.textAlignment = .center
        return label
    }()
    
    private let emailLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .regular)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        return label
    }()
    
    private let statsView: UIView = {
        let view = UIView()
        view.backgroundColor = .secondarySystemBackground
        view.layer.cornerRadius = 16
        return view
    }()
    
    private let wordsCountView = StatItemView(title: "Toplam Kelime", icon: "textformat.alt")
    private let streakCountView = StatItemView(title: "Günlük Seri", icon: "flame.fill")
    private let masteredWordsView = StatItemView(title: "Öğrenilen", icon: "checkmark.circle.fill")
    
    private let premiumButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Premium'a Geç", for: .normal)
        button.setTitleColor(Theme.accent, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
        button.backgroundColor = Theme.accent.withAlphaComponent(0.1)
        button.layer.cornerRadius = 16
        button.heightAnchor.constraint(equalToConstant: 56).isActive = true
        return button
    }()
    
    private let logoutButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Çıkış Yap", for: .normal)
        button.setTitleColor(.systemRed, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
        button.backgroundColor = .systemRed.withAlphaComponent(0.1)
        button.layer.cornerRadius = 16
        button.heightAnchor.constraint(equalToConstant: 56).isActive = true
        return button
    }()
    
    private let deleteAccountButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Hesabı Sil", for: .normal)
        button.setTitleColor(.systemRed, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 15, weight: .regular)
        button.backgroundColor = .clear
        return button
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.delegate = self
        setupUI()
        setupActions()
        loadUserData()
    }
    
    // MARK: - Setup
    private func setupUI() {
        view.backgroundColor = .systemBackground
        navigationItem.largeTitleDisplayMode = .never
        title = "Profil"
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        contentView.addSubview(headerView)
        headerView.addSubview(profileImageView)
        headerView.addSubview(nameLabel)
        headerView.addSubview(emailLabel)
        
        contentView.addSubview(statsView)
        statsView.addSubview(wordsCountView)
        statsView.addSubview(streakCountView)
        statsView.addSubview(masteredWordsView)
        
        contentView.addSubview(premiumButton)
        contentView.addSubview(logoutButton)
        contentView.addSubview(deleteAccountButton)
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        scrollView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
        
        contentView.snp.makeConstraints { make in
            make.edges.equalTo(scrollView)
            make.width.equalTo(scrollView)
        }
        
        headerView.snp.makeConstraints { make in
            make.top.equalTo(contentView).offset(16)
            make.leading.trailing.equalTo(contentView).inset(16)
        }
        
        profileImageView.snp.makeConstraints { make in
            make.top.equalTo(headerView).offset(32)
            make.centerX.equalTo(headerView)
            make.size.equalTo(100)
        }
        
        nameLabel.snp.makeConstraints { make in
            make.top.equalTo(profileImageView.snp.bottom).offset(16)
            make.leading.trailing.equalTo(headerView).inset(16)
        }
        
        emailLabel.snp.makeConstraints { make in
            make.top.equalTo(nameLabel.snp.bottom).offset(8)
            make.leading.trailing.equalTo(headerView).inset(16)
            make.bottom.equalTo(headerView).offset(-32)
        }
        
        statsView.snp.makeConstraints { make in
            make.top.equalTo(headerView.snp.bottom).offset(24)
            make.leading.trailing.equalTo(contentView).inset(16)
            make.height.equalTo(100)
        }
        
        // Stats items layout
        wordsCountView.snp.makeConstraints { make in
            make.leading.equalTo(statsView).offset(16)
            make.centerY.equalTo(statsView)
            make.width.equalTo(statsView).multipliedBy(0.3)
        }
        
        streakCountView.snp.makeConstraints { make in
            make.center.equalTo(statsView)
            make.width.equalTo(statsView).multipliedBy(0.3)
        }
        
        masteredWordsView.snp.makeConstraints { make in
            make.trailing.equalTo(statsView).offset(-16)
            make.centerY.equalTo(statsView)
            make.width.equalTo(statsView).multipliedBy(0.3)
        }
        
        // Premium button constraints
        premiumButton.snp.makeConstraints { make in
            make.top.equalTo(statsView.snp.bottom).offset(32)
            make.leading.trailing.equalTo(contentView).inset(16)
        }
        
        // Logout button constraints'i güncelle
        logoutButton.snp.makeConstraints { make in
            make.top.equalTo(premiumButton.snp.bottom).offset(16)
            make.leading.trailing.equalTo(contentView).inset(16)
        }
        
        // Delete account button constraints
        deleteAccountButton.snp.makeConstraints { make in
            make.top.equalTo(logoutButton.snp.bottom).offset(24)
            make.centerX.equalTo(contentView)
            make.bottom.equalTo(contentView).offset(-32)
        }
    }
    
    private func setupActions() {
        logoutButton.addTarget(self, action: #selector(handleLogoutTap), for: .touchUpInside)
        premiumButton.addTarget(self, action: #selector(handlePremiumTap), for: .touchUpInside)
        deleteAccountButton.addTarget(self, action: #selector(handleDeleteAccountTap), for: .touchUpInside)
    }
    
    private func loadUserData() {
        Task {
            await viewModel.fetchUserData()
        }
    }
    
    // MARK: - Actions
    @objc private func handleLogoutTap() {
        let alert = UIAlertController(
            title: "Çıkış Yap",
            message: "Hesabınızdan çıkış yapmak istediğinize emin misiniz?",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "İptal", style: .cancel))
        alert.addAction(UIAlertAction(title: "Çıkış Yap", style: .destructive) { [weak self] _ in
            Task {
                await self?.viewModel.logout()
            }
        })
        
        present(alert, animated: true)
    }
    
    @objc private func handlePremiumTap() {
        let premiumVC = PremiumViewController()
        premiumVC.modalPresentationStyle = .fullScreen
        present(premiumVC, animated: true)
    }
    
    @objc private func handleDeleteAccountTap() {
        let alert = UIAlertController(
            title: "Hesabı Sil",
            message: "Hesabınızı silmek istediğinize emin misiniz? Bu işlem geri alınamaz ve tüm verileriniz silinecektir.",
            preferredStyle: .alert
        )
        
        // İptal butonu
        alert.addAction(UIAlertAction(title: "İptal", style: .cancel))
        
        // Silme butonu
        let deleteAction = UIAlertAction(title: "Hesabı Sil", style: .destructive) { [weak self] _ in
            // Tekrar onay al
            self?.showFinalDeleteConfirmation()
        }
        alert.addAction(deleteAction)
        
        present(alert, animated: true)
    }
    
    private func showFinalDeleteConfirmation() {
        let alert = UIAlertController(
            title: "Son Onay",
            message: "Hesabınızı silmek için 'SİL' yazın.",
            preferredStyle: .alert
        )
        
        alert.addTextField { textField in
            textField.placeholder = "SİL yazın"
        }
        
        alert.addAction(UIAlertAction(title: "İptal", style: .cancel))
        
        let confirmAction = UIAlertAction(title: "Onayla", style: .destructive) { [weak self] _ in
            guard let text = alert.textFields?.first?.text,
                  text.uppercased() == "SİL" else {
                // Yanlış yazıldıysa uyarı göster
                self?.showError("Lütfen 'SİL' yazarak onaylayın")
                return
            }
            
            // Hesabı sil
            Task {
                await self?.viewModel.deleteAccount()
            }
        }
        
        alert.addAction(confirmAction)
        present(alert, animated: true)
    }
    
    private func showError(_ message: String) {
        let alert = UIAlertController(
            title: "Hata",
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Tamam", style: .default))
        present(alert, animated: true)
    }
    
    // MARK: - ProfileViewModelDelegate
    func didUpdateUserData(_ user: User, stats: UserStats) {
        nameLabel.text = user.displayName ?? "Kullanıcı"
        emailLabel.text = user.email
        
        // İstatistikleri güncelle
        wordsCountView.setValue(stats.totalWords)
        streakCountView.setValue(stats.currentStreak)
        masteredWordsView.setValue(stats.masteredWords)
        
        // Premium durumuna göre butonu güncelle
        updatePremiumButton(isPremium: user.isPremium)
        
        // Profil fotoğrafını yükle
        if let photoURL = user.photoURL {
            // SDWebImage veya Kingfisher kullanarak yükle
        }
    }
    
    private func updatePremiumButton(isPremium: Bool) {
        if isPremium {
            premiumButton.setTitle("Premium Üye", for: .normal)
            premiumButton.isEnabled = false
            premiumButton.backgroundColor = .systemGray5
            premiumButton.setTitleColor(.systemGray, for: .normal)
        } else {
            premiumButton.setTitle("Premium'a Geç", for: .normal)
            premiumButton.isEnabled = true
            premiumButton.backgroundColor = Theme.accent.withAlphaComponent(0.1)
            premiumButton.setTitleColor(Theme.accent, for: .normal)
        }
    }
    
    func didLogout() {
        // Kullanıcıyı login ekranına yönlendir
        let authVC = AuthViewController()
        let nav = UINavigationController(rootViewController: authVC)
        nav.modalPresentationStyle = .fullScreen
        present(nav, animated: true)
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

// MARK: - StatItemView
final class StatItemView: UIView {
    private let iconImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.tintColor = Theme.accent
        return iv
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        return label
    }()
    
    private let valueLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 24, weight: .bold)
        label.textColor = .label
        label.textAlignment = .center
        label.text = "0"
        return label
    }()
    
    init(title: String, icon: String) {
        super.init(frame: .zero)
        
        titleLabel.text = title
        let config = UIImage.SymbolConfiguration(pointSize: 24, weight: .medium)
        iconImageView.image = UIImage(systemName: icon, withConfiguration: config)
        
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        addSubview(iconImageView)
        addSubview(titleLabel)
        addSubview(valueLabel)
        
        iconImageView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.centerX.equalToSuperview()
            make.size.equalTo(32)
        }
        
        valueLabel.snp.makeConstraints { make in
            make.top.equalTo(iconImageView.snp.bottom).offset(8)
            make.centerX.equalToSuperview()
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(valueLabel.snp.bottom).offset(4)
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview()
        }
    }
    
    func setValue(_ value: Int) {
        valueLabel.text = "\(value)"
    }
} 
