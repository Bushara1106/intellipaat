import UIKit

final class LessonTableViewCell: UITableViewCell {
    static let reuseIdentifier = "LessonCell"

    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var statusLabel: UILabel!
    @IBOutlet private weak var completeButton: UIButton!

    private let cardView = UIView()
    private var didSetupChrome = false

    var onComplete: (() -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        completeButton?.addTarget(self, action: #selector(completeTapped), for: .touchUpInside)
        setupCardChromeIfNeeded()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        cardView.frame = contentView.bounds.insetBy(dx: 16, dy: 6)
        cardView.layer.shadowPath = UIBezierPath(
            roundedRect: cardView.bounds,
            cornerRadius: AppTheme.cardCornerRadius
        ).cgPath
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        cardView.layer.borderColor = UIColor.separator.withAlphaComponent(0.35).cgColor
        cardView.layer.shadowOpacity = traitCollection.userInterfaceStyle == .dark ? 0.25 : 0.08
    }

    private func setupCardChromeIfNeeded() {
        guard !didSetupChrome else { return }
        didSetupChrome = true

        cardView.isUserInteractionEnabled = false
        cardView.applyCardChrome()
        contentView.insertSubview(cardView, at: 0)

        titleLabel?.enableDynamicType(style: .body, weight: .semibold)
        statusLabel?.enableDynamicType(style: .caption1)

        contentView.constraints.forEach { constraint in
            guard constraint.firstItem is UIStackView || constraint.secondItem is UIStackView else { return }
            if constraint.firstAttribute == .leading || constraint.secondAttribute == .leading
                || constraint.firstAttribute == .trailing || constraint.secondAttribute == .trailing {
                if abs(constraint.constant) <= 16 {
                    constraint.constant = 32
                }
            }
            if constraint.firstAttribute == .top || constraint.secondAttribute == .top
                || constraint.firstAttribute == .bottom || constraint.secondAttribute == .bottom {
                constraint.constant = max(abs(constraint.constant), 16)
            }
        }
    }

    func configure(with lesson: Lesson) {
        titleLabel.text = lesson.title
        if lesson.isCompleted {
            statusLabel.text = "Completed"
            statusLabel.textColor = AppTheme.success
            completeButton.isHidden = true
            accessibilityLabel = "\(lesson.title), completed"
        } else {
            statusLabel.text = "Pending"
            statusLabel.textColor = .secondaryLabel
            completeButton.isHidden = false
            completeButton.applySecondaryStyle(title: "Mark Completed")
            accessibilityLabel = "\(lesson.title), pending"
            completeButton.accessibilityLabel = "Mark \(lesson.title) as completed"
        }
    }

    @objc private func completeTapped() {
        AppHaptics.success()
        onComplete?()
    }
}
