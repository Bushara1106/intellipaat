import UIKit

extension UIViewController {
    /// Tap outside fields dismisses keyboard. Does not block button taps.
    func enableKeyboardDismissOnTap() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(app_dismissKeyboard))
        tap.cancelsTouchesInView = false
        tap.delegate = KeyboardDismissTapDelegate.shared
        view.addGestureRecognizer(tap)
    }

    @objc func app_dismissKeyboard() {
        view.endEditing(true)
    }
}

/// Allows taps on controls (buttons, etc.) while still dismissing on empty space.
private final class KeyboardDismissTapDelegate: NSObject, UIGestureRecognizerDelegate {
    static let shared = KeyboardDismissTapDelegate()

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        !(touch.view is UIControl)
    }
}

/// Observes keyboard frame and adjusts a scroll view's content/indicator insets.
final class KeyboardAvoidanceController {
    private weak var scrollView: UIScrollView?
    private weak var viewController: UIViewController?
    private var observers: [NSObjectProtocol] = []

    init(scrollView: UIScrollView, viewController: UIViewController) {
        self.scrollView = scrollView
        self.viewController = viewController
    }

    func start() {
        stop()
        let center = NotificationCenter.default
        observers = [
            center.addObserver(
                forName: UIResponder.keyboardWillChangeFrameNotification,
                object: nil,
                queue: .main
            ) { [weak self] note in
                self?.handleKeyboard(notification: note)
            },
            center.addObserver(
                forName: UIResponder.keyboardWillHideNotification,
                object: nil,
                queue: .main
            ) { [weak self] note in
                self?.handleKeyboard(notification: note, hiding: true)
            }
        ]
    }

    func stop() {
        observers.forEach { NotificationCenter.default.removeObserver($0) }
        observers.removeAll()
    }

    deinit {
        stop()
    }

    private func handleKeyboard(notification: Notification, hiding: Bool = false) {
        guard
            let scrollView,
            let view = viewController?.view,
            let userInfo = notification.userInfo,
            let frameEnd = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
            let duration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double
        else { return }

        let curveRaw = (userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? UInt) ?? 0
        let options = UIView.AnimationOptions(rawValue: curveRaw << 16)

        let keyboardFrameInView = view.convert(frameEnd, from: nil)
        let overlap = hiding ? 0 : max(0, view.bounds.maxY - keyboardFrameInView.minY)
        let bottomInset = max(0, overlap - view.safeAreaInsets.bottom) + 16

        let animations = {
            scrollView.contentInset.bottom = bottomInset
            scrollView.verticalScrollIndicatorInsets.bottom = bottomInset
            if let field = view.currentFirstResponder() as? UIView {
                let rect = field.convert(field.bounds, to: scrollView)
                scrollView.scrollRectToVisible(rect.insetBy(dx: 0, dy: -24), animated: false)
            }
        }

        if UIAccessibility.isReduceMotionEnabled {
            animations()
        } else {
            UIView.animate(withDuration: duration, delay: 0, options: options, animations: animations)
        }
    }
}

extension UIView {
    func currentFirstResponder() -> UIResponder? {
        if isFirstResponder { return self }
        for subview in subviews {
            if let responder = subview.currentFirstResponder() {
                return responder
            }
        }
        return nil
    }
}
