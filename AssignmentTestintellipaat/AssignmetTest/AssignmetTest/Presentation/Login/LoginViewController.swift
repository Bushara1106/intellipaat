import UIKit

final class LoginViewController: UIViewController {
    @IBOutlet private weak var emailTextField: UITextField!
    @IBOutlet private weak var passwordTextField: UITextField!
    @IBOutlet private weak var loginButton: UIButton!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet private weak var errorLabel: UILabel!

    private let viewModel = LoginViewModel()
    private let scrollView = UIScrollView()
    private let contentStack = UIStackView()
    private let brandIconView = UIImageView()
    private let brandTitleLabel = UILabel()
    private let brandSubtitleLabel = UILabel()
    private let cardView = UIView()
    private let formStack = UIStackView()
    private let passwordToggleButton = UIButton(type: .system)
    private var keyboardAvoidance: KeyboardAvoidanceController?
    private var cardWidthConstraint: NSLayoutConstraint?
    private var didNavigateAfterLogin = false

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.largeTitleDisplayMode = .never
        title = nil
        navigationController?.setNavigationBarHidden(true, animated: false)

        rebuildLayout()
        configureFields()
        configureActions()
        bindViewModel()
        enableKeyboardDismissOnTap()

        keyboardAvoidance = KeyboardAvoidanceController(scrollView: scrollView, viewController: self)
        keyboardAvoidance?.start()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
        app_dismissKeyboard()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        view.updateBrandGradientFrame()
        let maxWidth = min(view.bounds.width - (AppTheme.horizontalPadding * 2), AppTheme.maxReadableWidth)
        cardWidthConstraint?.constant = maxWidth
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            view.addBrandGradientBackground()
            cardView.layer.borderColor = UIColor.separator.withAlphaComponent(0.35).cgColor
            emailTextField.setFieldFocused(emailTextField.isFirstResponder)
            passwordTextField.setFieldFocused(passwordTextField.isFirstResponder)
        }
    }

    deinit {
        keyboardAvoidance?.stop()
    }

    // MARK: - Layout

    private func rebuildLayout() {
        view.backgroundColor = AppTheme.pageBackground
        view.addBrandGradientBackground()

        // Hide storyboard stack by moving controls into our polished layout.
        emailTextField.removeFromSuperview()
        passwordTextField.removeFromSuperview()
        loginButton.removeFromSuperview()
        activityIndicator.removeFromSuperview()
        errorLabel.removeFromSuperview()
        view.subviews.forEach { $0.removeFromSuperview() }
        view.addBrandGradientBackground()

        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.alwaysBounceVertical = true
        scrollView.keyboardDismissMode = .interactive
        scrollView.contentInsetAdjustmentBehavior = .always
        view.addSubview(scrollView)

        contentStack.axis = .vertical
        contentStack.alignment = .center
        contentStack.spacing = 28
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentStack)

        brandIconView.image = UIImage(systemName: "graduationcap.fill")
        brandIconView.tintColor = AppTheme.brand
        brandIconView.contentMode = .scaleAspectFit
        brandIconView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            brandIconView.widthAnchor.constraint(equalToConstant: 56),
            brandIconView.heightAnchor.constraint(equalToConstant: 56)
        ])

        brandTitleLabel.text = "IntelliLearn"
        brandTitleLabel.textAlignment = .center
        brandTitleLabel.textColor = .label
        brandTitleLabel.enableDynamicType(style: .largeTitle, weight: .bold)

        brandSubtitleLabel.text = "Sign in to continue your learning journey"
        brandSubtitleLabel.textAlignment = .center
        brandSubtitleLabel.textColor = .secondaryLabel
        brandSubtitleLabel.enableDynamicType(style: .subheadline)

        let brandStack = UIStackView(arrangedSubviews: [brandIconView, brandTitleLabel, brandSubtitleLabel])
        brandStack.axis = .vertical
        brandStack.alignment = .center
        brandStack.spacing = 10

        cardView.translatesAutoresizingMaskIntoConstraints = false
        cardView.applyCardChrome()

        formStack.axis = .vertical
        formStack.spacing = 14
        formStack.translatesAutoresizingMaskIntoConstraints = false
        cardView.addSubview(formStack)

        let emailCaption = makeCaption("Email")
        let passwordCaption = makeCaption("Password")
        let hintLabel = UILabel()
        hintLabel.text = "Demo: learner@intellipaat.com / learn123"
        hintLabel.textAlignment = .center
        hintLabel.textColor = .tertiaryLabel
        hintLabel.enableDynamicType(style: .caption1)

        errorLabel.textAlignment = .center
        errorLabel.textColor = AppTheme.danger
        errorLabel.enableDynamicType(style: .footnote)
        errorLabel.isHidden = true

        activityIndicator.hidesWhenStopped = true
        activityIndicator.color = AppTheme.brand

        formStack.addArrangedSubview(emailCaption)
        formStack.addArrangedSubview(emailTextField)
        formStack.addArrangedSubview(passwordCaption)
        formStack.addArrangedSubview(passwordTextField)
        formStack.setCustomSpacing(20, after: passwordTextField)
        formStack.addArrangedSubview(loginButton)
        formStack.addArrangedSubview(activityIndicator)
        formStack.addArrangedSubview(errorLabel)
        formStack.addArrangedSubview(hintLabel)

        brandStack.setContentHuggingPriority(.required, for: .vertical)
        cardView.setContentHuggingPriority(.required, for: .vertical)

        // Flexible spacers center the form without stretching the Sign In button.
        let topSpacer = UIView()
        let bottomSpacer = UIView()
        topSpacer.setContentHuggingPriority(.defaultLow, for: .vertical)
        bottomSpacer.setContentHuggingPriority(.defaultLow, for: .vertical)
        contentStack.addArrangedSubview(topSpacer)
        contentStack.addArrangedSubview(brandStack)
        contentStack.addArrangedSubview(cardView)
        contentStack.addArrangedSubview(bottomSpacer)

        let widthConstraint = cardView.widthAnchor.constraint(equalToConstant: AppTheme.maxReadableWidth)
        cardWidthConstraint = widthConstraint

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            contentStack.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            contentStack.leadingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.leadingAnchor, constant: AppTheme.horizontalPadding),
            contentStack.trailingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.trailingAnchor, constant: -AppTheme.horizontalPadding),
            contentStack.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            contentStack.centerXAnchor.constraint(equalTo: scrollView.frameLayoutGuide.centerXAnchor),
            contentStack.heightAnchor.constraint(
                greaterThanOrEqualTo: scrollView.frameLayoutGuide.heightAnchor
            ),
            topSpacer.heightAnchor.constraint(equalTo: bottomSpacer.heightAnchor),

            widthConstraint,
            formStack.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 22),
            formStack.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 20),
            formStack.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -20),
            formStack.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -22)
        ])
    }

    private func makeCaption(_ text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.textColor = .secondaryLabel
        label.enableDynamicType(style: .caption1, weight: .semibold)
        return label
    }

    private func configureFields() {
        [emailTextField, passwordTextField, loginButton].forEach { control in
            control?.constraints
                .filter { $0.firstAttribute == .height }
                .forEach { $0.isActive = false }
        }

        emailTextField.applyAppFieldStyle(placeholder: "you@example.com")
        emailTextField.keyboardType = .emailAddress
        emailTextField.textContentType = .username
        emailTextField.autocapitalizationType = .none
        emailTextField.autocorrectionType = .no
        emailTextField.spellCheckingType = .no
        emailTextField.returnKeyType = .next
        emailTextField.enablesReturnKeyAutomatically = true
        emailTextField.delegate = self
        emailTextField.accessibilityLabel = "Email address"

        passwordTextField.applyAppFieldStyle(placeholder: "Password")
        passwordTextField.isSecureTextEntry = true
        passwordTextField.textContentType = .password
        passwordTextField.clearButtonMode = .never
        passwordTextField.returnKeyType = .go
        passwordTextField.enablesReturnKeyAutomatically = true
        passwordTextField.delegate = self
        passwordTextField.accessibilityLabel = "Password"
        configurePasswordToggle()

        loginButton.applyPrimaryStyle(title: "Sign In")
        loginButton.accessibilityHint = "Signs in with the entered email and password"
    }

    private func configurePasswordToggle() {
        passwordToggleButton.frame = CGRect(x: 0, y: 0, width: 44, height: AppTheme.fieldHeight)
        passwordToggleButton.tintColor = .secondaryLabel
        passwordToggleButton.setImage(UIImage(systemName: "eye"), for: .normal)
        passwordToggleButton.addTarget(self, action: #selector(togglePasswordVisibility), for: .touchUpInside)
        passwordToggleButton.accessibilityLabel = "Show password"
        passwordToggleButton.isHidden = true

        let container = UIView(frame: CGRect(x: 0, y: 0, width: 44, height: AppTheme.fieldHeight))
        container.addSubview(passwordToggleButton)
        passwordTextField.rightView = container
        passwordTextField.rightViewMode = .always
        updatePasswordToggleVisibility()
    }

    private func configureActions() {
        // Storyboard already wires loginTapped:; do not add another touch target.
        emailTextField.addTarget(self, action: #selector(editingChanged), for: .editingChanged)
        passwordTextField.addTarget(self, action: #selector(editingChanged), for: .editingChanged)
    }

    private func bindViewModel() {
        viewModel.onStateChange = { [weak self] state in
            self?.render(state: state)
        }
        viewModel.onLoginSuccess = { [weak self] in
            AppHaptics.success()
            self?.navigateToDashboard()
        }
    }

    // MARK: - Actions

    @IBAction private func loginTapped(_ sender: UIButton) {
        submitLogin()
    }

    @objc private func togglePasswordVisibility() {
        let wasFirstResponder = passwordTextField.isFirstResponder
        passwordTextField.isSecureTextEntry.toggle()
        if wasFirstResponder {
            passwordTextField.becomeFirstResponder()
        }
        let visible = !passwordTextField.isSecureTextEntry
        let iconName = visible ? "eye.slash" : "eye"
        passwordToggleButton.setImage(UIImage(systemName: iconName), for: .normal)
        passwordToggleButton.accessibilityLabel = visible ? "Hide password" : "Show password"
    }

    @objc private func editingChanged() {
        updatePasswordToggleVisibility()
        if !errorLabel.isHidden {
            errorLabel.isHidden = true
            errorLabel.text = nil
        }
    }

    private func updatePasswordToggleVisibility() {
        let hasPassword = !(passwordTextField.text ?? "").isEmpty
        passwordToggleButton.isHidden = !hasPassword
    }

    private func submitLogin() {
        app_dismissKeyboard()
        AppHaptics.light()
        viewModel.email = emailTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        viewModel.password = passwordTextField.text ?? ""
        viewModel.login()
    }

    private func render(state: LoginViewModel.ViewState) {
        switch state {
        case .idle:
            setLoading(false)
            errorLabel.isHidden = true
            errorLabel.text = nil
        case .loading:
            setLoading(true)
            errorLabel.isHidden = true
        case .error(let message):
            setLoading(false)
            errorLabel.isHidden = false
            errorLabel.text = message
            AppHaptics.error()
            UIAccessibility.post(notification: .announcement, argument: message)
        }
    }

    private func setLoading(_ loading: Bool) {
        loginButton.isEnabled = !loading
        emailTextField.isEnabled = !loading
        passwordTextField.isEnabled = !loading
        passwordToggleButton.isEnabled = !loading
        loginButton.alpha = loading ? 0.7 : 1
        if loading {
            activityIndicator.startAnimating()
        } else {
            activityIndicator.stopAnimating()
        }
    }

    private func navigateToDashboard() {
        guard !didNavigateAfterLogin else { return }
        didNavigateAfterLogin = true

        guard let dashboard = storyboard?.instantiateViewController(
            withIdentifier: "CourseDashboardViewController"
        ) as? CourseDashboardViewController else {
            didNavigateAfterLogin = false
            return
        }

        navigationController?.setViewControllers([dashboard], animated: true)
    }
}

extension LoginViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.setFieldFocused(true)
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.setFieldFocused(false)
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField === emailTextField {
            passwordTextField.becomeFirstResponder()
        } else if textField === passwordTextField {
            textField.resignFirstResponder()
            submitLogin()
        } else {
            textField.resignFirstResponder()
        }
        return true
    }
}
