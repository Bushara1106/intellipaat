import UIKit

final class CourseDashboardViewController: UIViewController {
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet private weak var statusLabel: UILabel!
    @IBOutlet private weak var offlineBannerLabel: UILabel!
    @IBOutlet private weak var retryButton: UIButton!

    private let viewModel = CourseDashboardViewModel()
    private var selectedCourse: Course?
    private let emptyIcon = UIImageView()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "My Courses"
        navigationItem.largeTitleDisplayMode = .never
        navigationItem.hidesBackButton = true
        navigationItem.titleView = makeCenteredTitleLabel("My Courses")
        view.backgroundColor = AppTheme.pageBackground

        configureTable()
        configureEmptyState()
        configureOfflineBanner()
        configureRetry()

        viewModel.onStateChange = { [weak self] in
            self?.render()
        }

        let refresh = UIRefreshControl()
        refresh.addTarget(self, action: #selector(pullToRefresh), for: .valueChanged)
        tableView.refreshControl = refresh

        viewModel.load()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
        if let selected = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: selected, animated: animated)
        }
    }

    private func makeCenteredTitleLabel(_ text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.textAlignment = .center
        label.textColor = .label
        label.font = .systemFont(ofSize: 17, weight: .semibold)
        label.sizeToFit()
        return label
    }

    private func configureTable() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.backgroundColor = AppTheme.pageBackground
        tableView.separatorStyle = .none
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 180
        tableView.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 24, right: 0)
        tableView.keyboardDismissMode = .onDrag
        tableView.showsVerticalScrollIndicator = false
    }

    private func configureEmptyState() {
        activityIndicator.hidesWhenStopped = true
        activityIndicator.color = AppTheme.brand

        statusLabel.isHidden = true
        statusLabel.textColor = .secondaryLabel
        statusLabel.enableDynamicType(style: .body)
        statusLabel.textAlignment = .center

        emptyIcon.translatesAutoresizingMaskIntoConstraints = false
        emptyIcon.image = UIImage(systemName: "books.vertical.fill")
        emptyIcon.tintColor = AppTheme.brand.withAlphaComponent(0.45)
        emptyIcon.contentMode = .scaleAspectFit
        emptyIcon.isHidden = true
        view.addSubview(emptyIcon)

        NSLayoutConstraint.activate([
            emptyIcon.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyIcon.bottomAnchor.constraint(equalTo: statusLabel.topAnchor, constant: -12),
            emptyIcon.widthAnchor.constraint(equalToConstant: 48),
            emptyIcon.heightAnchor.constraint(equalToConstant: 48)
        ])
    }

    private func configureOfflineBanner() {
        offlineBannerLabel.isHidden = true
        offlineBannerLabel.textAlignment = .center
        offlineBannerLabel.enableDynamicType(style: .footnote, weight: .medium)
        offlineBannerLabel.textColor = UIColor { traits in
            traits.userInterfaceStyle == .dark ? .systemYellow : UIColor(red: 0.45, green: 0.30, blue: 0.0, alpha: 1)
        }
        offlineBannerLabel.backgroundColor = AppTheme.warning.withAlphaComponent(0.18)
        offlineBannerLabel.layer.cornerRadius = 10
        offlineBannerLabel.layer.cornerCurve = .continuous
        offlineBannerLabel.clipsToBounds = true
    }

    private func configureRetry() {
        retryButton.isHidden = true
        retryButton.applyPrimaryStyle(title: "Try Again")
    }

    @IBAction private func retryTapped(_ sender: UIButton) {
        AppHaptics.light()
        viewModel.load()
    }

    @objc private func pullToRefresh() {
        Task {
            await viewModel.refresh()
            tableView.refreshControl?.endRefreshing()
        }
    }

    private func render() {
        offlineBannerLabel.isHidden = !viewModel.isOfflineBannerVisible
        offlineBannerLabel.text = viewModel.isOfflineBannerVisible
            ? "  Offline — showing cached courses  "
            : nil

        switch viewModel.loadState {
        case .idle:
            break
        case .loading:
            activityIndicator.startAnimating()
            tableView.isHidden = true
            statusLabel.isHidden = true
            emptyIcon.isHidden = true
            retryButton.isHidden = true
        case .success:
            activityIndicator.stopAnimating()
            tableView.isHidden = false
            statusLabel.isHidden = true
            emptyIcon.isHidden = true
            retryButton.isHidden = true
            tableView.reloadData()
        case .empty:
            activityIndicator.stopAnimating()
            tableView.isHidden = true
            statusLabel.isHidden = false
            emptyIcon.isHidden = false
            statusLabel.text = "No courses available yet."
            retryButton.isHidden = false
        case .failure(let message):
            activityIndicator.stopAnimating()
            tableView.isHidden = true
            statusLabel.isHidden = false
            emptyIcon.isHidden = false
            emptyIcon.image = UIImage(systemName: "wifi.exclamationmark")
            statusLabel.text = message
            retryButton.isHidden = false
            UIAccessibility.post(notification: .announcement, argument: message)
        }
    }

    private func openDetails(for course: Course) {
        selectedCourse = course
        performSegue(withIdentifier: "showCourseDetails", sender: course)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard segue.identifier == "showCourseDetails",
              let detailsVC = segue.destination as? CourseDetailsViewController,
              let course = sender as? Course ?? selectedCourse else { return }
        detailsVC.configure(course: course)
    }
}

extension CourseDashboardViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.courses.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: CourseTableViewCell.reuseIdentifier,
            for: indexPath
        ) as? CourseTableViewCell,
              let course = viewModel.course(at: indexPath.row) else {
            return UITableViewCell()
        }

        cell.configure(with: course)
        cell.onContinue = { [weak self] in
            self?.openDetails(for: course)
        }
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let course = viewModel.course(at: indexPath.row) else { return }
        AppHaptics.light()
        openDetails(for: course)
    }
}
