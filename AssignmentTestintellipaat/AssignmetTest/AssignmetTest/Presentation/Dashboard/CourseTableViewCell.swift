import UIKit

final class CourseTableViewCell: UITableViewCell {
    static let reuseIdentifier = "CourseCell"

    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var instructorLabel: UILabel!
    @IBOutlet private weak var progressLabel: UILabel!
    @IBOutlet private weak var lessonsLabel: UILabel!
    @IBOutlet private weak var progressView: UIProgressView!
    @IBOutlet private weak var continueButton: UIButton!

    private let cardView = UIView()
    private var didSetupChrome = false

    var onContinue: (() -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        continueButton?.addTarget(self, action: #selector(continueTapped), for: .touchUpInside)
        setupCardChromeIfNeeded()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        cardView.frame = contentView.bounds.insetBy(dx: 16, dy: 8)
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

        titleLabel?.enableDynamicType(style: .headline, weight: .bold)
        instructorLabel?.enableDynamicType(style: .subheadline)
        instructorLabel?.textColor = .secondaryLabel
        progressLabel?.enableDynamicType(style: .footnote, weight: .medium)
        lessonsLabel?.enableDynamicType(style: .footnote)
        lessonsLabel?.textColor = .secondaryLabel

        progressView?.trackTintColor = AppTheme.brand.withAlphaComponent(0.15)
        progressView?.progressTintColor = AppTheme.brand
        progressView?.layer.cornerRadius = 3
        progressView?.clipsToBounds = true
        progressView?.transform = CGAffineTransform(scaleX: 1, y: 1.6)

        continueButton?.applySecondaryStyle(title: "Continue Learning")

        // Expand storyboard insets so content sits inside the floating card.
        contentView.constraints.forEach { constraint in
            guard
                let stack = constraint.firstItem as? UIStackView
                    ?? constraint.secondItem as? UIStackView
            else { return }
            if stack.axis == .vertical {
                if constraint.firstAttribute == .leading || constraint.secondAttribute == .leading
                    || constraint.firstAttribute == .trailing || constraint.secondAttribute == .trailing {
                    constraint.constant = constraint.constant < 20 ? 32 : constraint.constant
                }
                if constraint.firstAttribute == .top || constraint.secondAttribute == .top
                    || constraint.firstAttribute == .bottom || constraint.secondAttribute == .bottom {
                    constraint.constant = max(constraint.constant, 20)
                }
            }
        }

        if let stack = contentView.subviews.compactMap({ $0 as? UIStackView }).first {
            stack.spacing = 8
        }
    }

    func configure(with course: Course) {
        titleLabel.text = course.title
        instructorLabel.text = course.instructor
        progressLabel.text = "\(course.progress)% complete"
        lessonsLabel.text = "\(course.lessons) lessons"
        progressView.setProgress(Float(course.progress) / 100.0, animated: false)

        accessibilityLabel = "\(course.title), \(course.progress) percent complete, instructor \(course.instructor)"
        continueButton.accessibilityLabel = "Continue \(course.title)"
    }

    @objc private func continueTapped() {
        AppHaptics.light()
        onContinue?()
    }

    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        let scale: CGFloat = highlighted ? 0.98 : 1
        let animations = {
            self.cardView.transform = CGAffineTransform(scaleX: scale, y: scale)
            self.cardView.alpha = highlighted ? 0.92 : 1
        }
        if UIAccessibility.isReduceMotionEnabled {
            animations()
        } else if animated {
            UIView.animate(withDuration: 0.18, delay: 0, options: [.curveEaseOut, .allowUserInteraction], animations: animations)
        } else {
            animations()
        }
    }
}
