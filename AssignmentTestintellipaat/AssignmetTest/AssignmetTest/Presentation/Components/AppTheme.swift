import UIKit

enum AppTheme {
    static let brand = UIColor { traits in
        traits.userInterfaceStyle == .dark
            ? UIColor(red: 0.35, green: 0.72, blue: 0.82, alpha: 1)
            : UIColor(red: 0.05, green: 0.45, blue: 0.55, alpha: 1)
    }

    static let brandSecondary = UIColor { traits in
        traits.userInterfaceStyle == .dark
            ? UIColor(red: 0.18, green: 0.28, blue: 0.36, alpha: 1)
            : UIColor(red: 0.93, green: 0.97, blue: 0.98, alpha: 1)
    }

    static let cardBackground = UIColor { traits in
        traits.userInterfaceStyle == .dark
            ? UIColor(red: 0.14, green: 0.16, blue: 0.19, alpha: 1)
            : UIColor.white
    }

    static let pageBackground = UIColor { traits in
        traits.userInterfaceStyle == .dark
            ? UIColor.systemBackground
            : UIColor(red: 0.95, green: 0.97, blue: 0.98, alpha: 1)
    }

    static let success = UIColor.systemGreen
    static let warning = UIColor.systemOrange
    static let danger = UIColor.systemRed

    static let cornerRadius: CGFloat = 14
    static let cardCornerRadius: CGFloat = 16
    static let fieldHeight: CGFloat = 52
    static let buttonHeight: CGFloat = 52
    static let horizontalPadding: CGFloat = 20
    static let maxReadableWidth: CGFloat = 440

    static func applyGlobalAppearance() {
        let navAppearance = UINavigationBarAppearance()
        navAppearance.configureWithOpaqueBackground()
        navAppearance.backgroundColor = pageBackground
        navAppearance.titleTextAttributes = [
            .foregroundColor: UIColor.label,
            .font: UIFont.systemFont(ofSize: 17, weight: .semibold)
        ]
        navAppearance.largeTitleTextAttributes = [
            .foregroundColor: UIColor.label,
            .font: UIFont.systemFont(ofSize: 32, weight: .bold)
        ]
        navAppearance.shadowColor = .clear

        UINavigationBar.appearance().standardAppearance = navAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = navAppearance
        UINavigationBar.appearance().compactAppearance = navAppearance
        UINavigationBar.appearance().tintColor = brand
        UINavigationBar.appearance().prefersLargeTitles = true

        UITableView.appearance().backgroundColor = pageBackground
        UITableView.appearance().separatorStyle = .none
        UIRefreshControl.appearance().tintColor = brand
        UIProgressView.appearance().progressTintColor = brand
        UIProgressView.appearance().trackTintColor = brand.withAlphaComponent(0.15)
        UIActivityIndicatorView.appearance().color = brand
    }
}

enum AppHaptics {
    static func light() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }

    static func success() {
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }

    static func error() {
        UINotificationFeedbackGenerator().notificationOccurred(.error)
    }
}
