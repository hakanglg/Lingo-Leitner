import UIKit
import SnapKit

final class CustomTextField: UITextField {
    // MARK: - Properties
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .secondarySystemBackground
        view.layer.cornerRadius = 12
        return view
    }()
    
    private let iconView: UIImageView = {
        let imageView = UIImageView()
        imageView.tintColor = .secondaryLabel
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let wrapperView = UIView()
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    private func setupUI() {
        backgroundColor = .clear
        font = Theme.font(.body)
        
        // View hiyerarşisi
        addSubview(wrapperView)
        wrapperView.addSubview(containerView)
        containerView.addSubview(iconView)
        
        // Constraints
        wrapperView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        containerView.snp.makeConstraints { make in
            make.edges.equalTo(wrapperView)
            make.height.equalTo(56)
        }
        
        iconView.snp.makeConstraints { make in
            make.leading.equalTo(containerView).offset(16)
            make.centerY.equalTo(containerView)
            make.size.equalTo(24)
        }
        
        // Text inset ayarları
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 52, height: frame.height))
        leftView = paddingView
        leftViewMode = .always
    }
    
    func configure(icon: String, placeholder: String, keyboardType: UIKeyboardType, returnKeyType: UIReturnKeyType) {
        let config = UIImage.SymbolConfiguration(pointSize: 16, weight: .medium)
        iconView.image = UIImage(systemName: icon, withConfiguration: config)
        self.placeholder = placeholder
        self.keyboardType = keyboardType
        self.returnKeyType = returnKeyType
    }
    
    // MARK: - Override methods for proper text positioning
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: UIEdgeInsets(top: 0, left: 52, bottom: 0, right: 16))
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: UIEdgeInsets(top: 0, left: 52, bottom: 0, right: 16))
    }
    
    override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: UIEdgeInsets(top: 0, left: 52, bottom: 0, right: 16))
    }
} 
