import UIKit

final class NotificationCell: UITableViewCell {
    static let reuseIdentifier = "NotificationCell"
    
    // MARK: - UI Components
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
        view.layer.cornerRadius = 12
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 6
        view.layer.shadowOpacity = 0.1
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let wordLabel: UILabel = {
        let label = UILabel()
        label.font = Theme.font(.headline, .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let meaningLabel: UILabel = {
        let label = UILabel()
        label.font = Theme.font(.subheadline)
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let statusLabel: UILabel = {
        let label = UILabel()
        label.font = Theme.font(.caption1, .medium)
        label.textAlignment = .center
        label.layer.cornerRadius = 8
        label.clipsToBounds = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // MARK: - Setup
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        backgroundColor = .clear
        selectionStyle = .none
        
        contentView.addSubview(containerView)
        containerView.addSubview(wordLabel)
        containerView.addSubview(meaningLabel)
        containerView.addSubview(statusLabel)
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            
            wordLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 16),
            wordLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            
            statusLabel.centerYAnchor.constraint(equalTo: wordLabel.centerYAnchor),
            statusLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            statusLabel.widthAnchor.constraint(greaterThanOrEqualToConstant: 80),
            statusLabel.heightAnchor.constraint(equalToConstant: 24),
            
            meaningLabel.topAnchor.constraint(equalTo: wordLabel.bottomAnchor, constant: 8),
            meaningLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            meaningLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            meaningLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -16)
        ])
    }
    
    func configure(with word: Word) {
        wordLabel.text = word.word
        meaningLabel.text = word.meaning
        
        statusLabel.text = word.reviewStatus.displayText
        statusLabel.textColor = word.reviewStatus.color
        statusLabel.backgroundColor = word.reviewStatus.color.withAlphaComponent(0.1)
    }
} 