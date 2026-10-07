import UIKit

final class CourseDetailsViewController: UIViewController {
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var progressLabel: UILabel!
    @IBOutlet private weak var progressView: UIProgressView!
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var errorLabel: UILabel!

    private var viewModel: CourseDetailsViewModel!

    func configure(course: Course) {
        viewModel = CourseDetailsViewModel(course: course)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Course"
        navigationItem.largeTitleDisplayMode = .never
        view.backgroundColor = AppTheme.pageBackground

        errorLabel.isHidden = true
        errorLabel.textColor = AppTheme.danger
        errorLabel.enableDynamicType(style: .footnote)

        styleHeader()
        configureTable()

        guard viewModel != nil else {
            assertionFailure("CourseDetailsViewController must be configured with a course before presentation.")
            return
        }

        viewModel.onUpdate = { [weak self] in
            self?.render()
        }
        render()
    }

    private func styleHeader() {
        titleLabel.enableDynamicType(style: .title2, weight: .bold)
        progressLabel.enableDynamicType(style: .subheadline)
        progressLabel.textColor = .secondaryLabel

        progressView.trackTintColor = AppTheme.brand.withAlphaComponent(0.15)
        progressView.progressTintColor = AppTheme.brand
        progressView.layer.cornerRadius = 4
        progressView.clipsToBounds = true
        progressView.transform = CGAffineTransform(scaleX: 1, y: 2)

        if let headerStack = titleLabel.superview {
            headerStack.backgroundColor = AppTheme.cardBackground
            headerStack.layer.cornerRadius = AppTheme.cardCornerRadius
            headerStack.layer.cornerCurve = .continuous
            headerStack.layer.borderWidth = 1
            headerStack.layer.borderColor = UIColor.separator.withAlphaComponent(0.35).cgColor
            headerStack.clipsToBounds = true
            headerStack.layoutMargins = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
            if let stack = headerStack as? UIStackView {
                stack.isLayoutMarginsRelativeArrangement = true
                stack.spacing = 10
            }
        }
    }

    private func configureTable() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.backgroundColor = AppTheme.pageBackground
        tableView.separatorStyle = .none
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 88
        tableView.contentInset = UIEdgeInsets(top: 4, left: 0, bottom: 24, right: 0)
        tableView.keyboardDismissMode = .onDrag
        tableView.showsVerticalScrollIndicator = false
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        titleLabel.superview?.layer.borderColor = UIColor.separator.withAlphaComponent(0.35).cgColor
        titleLabel.superview?.backgroundColor = AppTheme.cardBackground
    }

    private func render() {
        let course = viewModel.course
        let completed = course.lessonItems.filter(\.isCompleted).count
        titleLabel.text = course.title
        progressLabel.text = "\(course.progress)% complete · \(completed)/\(course.lessonItems.count) lessons"
        progressView.setProgress(Float(course.progress) / 100.0, animated: !UIAccessibility.isReduceMotionEnabled)

        if let error = viewModel.errorMessage {
            errorLabel.isHidden = false
            errorLabel.text = error
            UIAccessibility.post(notification: .announcement, argument: error)
        } else {
            errorLabel.isHidden = true
            errorLabel.text = nil
        }
        tableView.reloadData()
    }
}

extension CourseDetailsViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel?.course.lessonItems.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: LessonTableViewCell.reuseIdentifier,
            for: indexPath
        ) as? LessonTableViewCell,
              let lesson = viewModel?.course.lessonItems[indexPath.row] else {
            return UITableViewCell()
        }

        cell.configure(with: lesson)
        cell.onComplete = { [weak self] in
            self?.viewModel.markCompleted(lessonID: lesson.id)
        }
        return cell
    }
}
