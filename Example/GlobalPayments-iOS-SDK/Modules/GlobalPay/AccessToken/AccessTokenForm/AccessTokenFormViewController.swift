import UIKit
import GlobalPayments_iOS_SDK

protocol AccessTokenFormDelegate: class {
    func onComletedForm(form: AccessTokenForm)
}

final class AccessTokenFormViewController: UIViewController, StoryboardInstantiable {

    static let storyboardName = "AccessToken"

    weak var delegate: AccessTokenFormDelegate?

    @IBOutlet private weak var submitButton: UIButton!
    @IBOutlet private weak var navigationBar: UINavigationBar!
    @IBOutlet private weak var appIdLabel: UILabel!
    @IBOutlet private weak var appIdTextField: UITextField!
    @IBOutlet private weak var appKeyLabel: UILabel!
    @IBOutlet private weak var appKeyTextField: UITextField!
    @IBOutlet private weak var secondsLabel: UILabel!
    @IBOutlet private weak var secondsTextField: UITextField!
    @IBOutlet private weak var environmentLabel: UILabel!
    @IBOutlet private weak var environmentTextField: UITextField!
    @IBOutlet private weak var intervalLabel: UILabel!
    @IBOutlet private weak var intervalTextField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
    }

    private func setupUI() {
        hideKeyboardWhenTappedAround()

        navigationBar.topItem?.title = "access.token.form.title".localized()

        submitButton.apply(style: .globalPayStyle)
        submitButton.setTitle("access.token.form.submit".localized(), for: .normal)

        appIdLabel.text = "access.token.form.app.id".localized()
        appIdTextField.text = Constants.gpApiAppID

        appKeyLabel.text = "access.token.form.app.key".localized()
        appKeyTextField.text = Constants.gpApiAppKey

        secondsLabel.text = "access.token.form.seconds".localized()

        environmentLabel.text = "access.token.form.environment".localized()
        environmentTextField.loadDropDownData(Environment.allCases.map { "\($0)".uppercased() })

        intervalLabel.text = "access.token.form.interval".localized()
        intervalTextField.loadDropDownData(IntervalToExpire.allCases.map { $0.rawValue.uppercased() })
    }

    // MARK: - Actions

    @IBAction private func onCloseAction() {
        dismiss(animated: true, completion: nil)
    }

    @IBAction private func onSubmitAction() {
        let interval: IntervalToExpire = IntervalToExpire(rawValue: intervalTextField.text ?? .empty) ?? .week
        let environment: Environment = environmentTextField.text?.lowercased() == "test" ? .test : .production

        let form = AccessTokenForm(
            appId: appIdTextField.text ?? .empty,
            appKey: appKeyTextField.text ?? .empty,
            secondsToExpire: Int(secondsTextField.text ?? .empty),
            environment: environment,
            interval: interval
        )

        delegate?.onComletedForm(form: form)
        dismiss(animated: true, completion: nil)
    }
}
