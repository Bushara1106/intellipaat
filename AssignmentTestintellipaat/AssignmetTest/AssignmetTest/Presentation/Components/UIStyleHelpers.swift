import UIKit

extension UITextField {
    func applyAppFieldStyle(placeholder: String) {
        borderStyle = .none
        backgroundColor = AppTheme.cardBackground
        textColor = .label
        tintColor = AppTheme.brand
        font = .preferredFont(forTextStyle: .body)
        adjustsFontForContentSizeCategory = true
        layer.cornerRadius = AppTheme.cornerRadius
        layer.cornerCurve = .continuous
        layer.borderWidth = 1
        layer.borderColor = UIColor.separator.cgColor
        clipsToBounds = true
        clearButtonMode = .whileEditing

        let padding = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 1))
        leftView = padding
        leftViewMode = .always

        attributedPlaceholder = NSAttributedString(
            string: placeholder,
            attributes: [
                .foregroundColor: UIColor.placeholderText,
                .font: UIFont.preferredFont(forTextStyle: .body)
            ]
        )

        setContentHuggingPriority(.required, for: .vertical)
        setContentCompressionResistancePriority(.required, for: .vertical)
        constraints
            .filter { $0.firstAttribute == .height && $0.firstItem as? UITextField === self }
            .forEach { $0.isActive = false }
        heightAnchor.constraint(equalToConstant: AppTheme.fieldHeight).isActive = true
    }

    func setFieldFocused(_ focused: Bool) {
        layer.borderWidth = focused ? 1.5 : 1
        layer.borderColor = focused
            ? AppTheme.brand.cgColor
            : UIColor.separator.cgColor
    }
}

extension UIButton {
    func applyPrimaryStyle(title: String) {
        var config = UIButton.Configuration.filled()
        config.title = title
        config.baseBackgroundColor = AppTheme.brand
        config.baseForegroundColor = .white
        config.cornerStyle = .medium
        config.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20)
        config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var outgoing = incoming
            outgoing.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
            return outgoing
        }
        configuration = config

        setContentHuggingPriority(.required, for: .vertical)
        setContentCompressionResistancePriority(.required, for: .vertical)
        constraints
            .filter { $0.firstAttribute == .height && $0.firstItem as? UIButton === self }
            .forEach { $0.isActive = false }
        heightAnchor.constraint(equalToConstant: AppTheme.buttonHeight).isActive = true
    }

    func applySecondaryStyle(title: String) {
        var config = UIButton.Configuration.tinted()
        config.title = title
        config.baseBackgroundColor = AppTheme.brand
        config.baseForegroundColor = AppTheme.brand
        config.cornerStyle = .large
        config.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 16, bottom: 10, trailing: 16)
        configuration = config
    }
}

extension UIView {
    func applyCardChrome() {
        backgroundColor = AppTheme.cardBackground
        layer.cornerRadius = AppTheme.cardCornerRadius
        layer.cornerCurve = .continuous
        layer.borderWidth = 1
        layer.borderColor = UIColor.separator.withAlphaComponent(0.35).cgColor
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = traitCollection.userInterfaceStyle == .dark ? 0.25 : 0.08
        layer.shadowOffset = CGSize(width: 0, height: 4)
        layer.shadowRadius = 10
    }

    func addBrandGradientBackground() {
        let existing = layer.sublayers?.first(where: { $0.name == "app.brand.gradient" })
        existing?.removeFromSuperlayer()

        let gradient = CAGradientLayer()
        gradient.name = "app.brand.gradient"
        gradient.frame = bounds
        gradient.colors = [
            AppTheme.brand.withAlphaComponent(0.18).cgColor,
            AppTheme.pageBackground.cgColor,
            AppTheme.pageBackground.cgColor
        ]
        gradient.locations = [0, 0.45, 1]
        gradient.startPoint = CGPoint(x: 0.5, y: 0)
        gradient.endPoint = CGPoint(x: 0.5, y: 1)
        layer.insertSublayer(gradient, at: 0)
    }

    func updateBrandGradientFrame() {
        layer.sublayers?.first(where: { $0.name == "app.brand.gradient" })?.frame = bounds
    }
}

extension UILabel {
    func enableDynamicType(style: UIFont.TextStyle, weight: UIFont.Weight? = nil) {
        if let weight {
            font = UIFontMetrics(forTextStyle: style).scaledFont(
                for: UIFont.systemFont(ofSize: UIFont.preferredFont(forTextStyle: style).pointSize, weight: weight)
            )
        } else {
            font = .preferredFont(forTextStyle: style)
        }
        adjustsFontForContentSizeCategory = true
        numberOfLines = 0
    }
}
