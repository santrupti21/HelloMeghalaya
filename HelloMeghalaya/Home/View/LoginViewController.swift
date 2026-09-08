
import UIKit

final class LoginViewController: UIViewController {

    enum AuthMode {
        case login
        case register
        case forgotPassword
    }

    private var authMode: AuthMode = .login //current mode

    private let mainStackView = UIStackView()

    private let headerStackView = UIStackView()
    private let titleStackView = UIStackView()

    private let welcomeLabel = UILabel()
    private let loginLabel = UILabel()
    private let closeButton = UIButton(type: .system)

    private let loginTypeControl = UISegmentedControl(items: ["Mobile Number", "Email Id"])

    private let mobileStackView = UIStackView()
    private let mobileInputStackView = UIStackView()

    private let mobileTitleLabel = UILabel()
    private let countryCodeLabel = UILabel()
    private let mobileNumberTextField = UITextField()
    private let mobileUnderlineView = UIView()

    private let passwordStackView = UIStackView()
    private let passwordInputStackView = UIStackView()
    private let passwordTitleLabel = UILabel()
    private let passwordTextField = UITextField()
    private let passwordButton = UIButton(type: .system)
    private let forgotPasswordButton = UIButton(type: .system)
    private let passwordUnderlineView = UIView()
    
    private let confirmPasswordStackView = UIStackView()
    private let confirmPasswordInputStackView = UIStackView()
    
    private let confirmPasswordTitleLabel = UILabel()
    private let confirmPasswordTextField = UITextField()
    private let confirmPasswordButton = UIButton(type: .system)
    private let confirmPasswordUnderlineView = UIView()

    private let actionStackView = UIStackView()
    private let loginButton = UIButton(type: .system)

    private let registerStackView = UIStackView()
    private let newUserLabel = UILabel()
    private let registerButton = UIButton(type: .system)

    private let noteLabel = UILabel()

    private let googleLoginButton = UIButton(type: .system)
    private let googleButtonStackView = UIStackView()

    private let passwordErrorLabel = UILabel()
    
    private let termsStackView = UIStackView()
    private let termsCheckboxButton = UIButton(type: .system)
    private let termsLabel = UITextView()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor(
            white: 0.10,
            alpha: 1.0
        )

        setupTitleStackView()
        setupHeaderStackView()
        setupLoginTypeControl()
        setupMobileViews()
        setupMobileInputStack()
        setupMobileStack()
        setupPasswordViews()
        setupPasswordInputStack()
        setupPasswordStack()
        setupConfirmPasswordViews()
        setupConfirmPasswordInputStack()
        setupConfirmPasswordStack()
        setupTermsStackView()
        setupForgotPasswordButton()
        setupLoginButton()
        setupRegisterStack()
        setupActionStack()
        setupNoteLabel()
        setupGoogleLoginButton()
        setupGoogleButtonStack()
        setupMainStackView()

        let tapGesture = UITapGestureRecognizer(
            target: self,
            action: #selector(dismissKeyboard)
        )

        view.addGestureRecognizer(tapGesture)

        reloadUI()
    }

    private func reloadUI() {

        switch authMode {

        case .login:

            welcomeLabel.text = "Welcome back"
            loginLabel.text = "Let's Login!"

            passwordStackView.isHidden = false
            confirmPasswordStackView.isHidden = true
            termsStackView.isHidden = true
            forgotPasswordButton.isHidden = false
            registerStackView.isHidden = false
            noteLabel.isHidden = false
            googleButtonStackView.isHidden = false

            loginButton.setTitle("Login", for: .normal)

            newUserLabel.text = "New to Hello Meghalaya?"
            registerButton.setTitle(
                "Register now",
                for: .normal
            )

        case .register:

            welcomeLabel.text = "Welcome to Hello Meghalaya"
            loginLabel.text = "Let's Register!"

            passwordStackView.isHidden = false
            confirmPasswordStackView.isHidden = false
            termsStackView.isHidden = false
            forgotPasswordButton.isHidden = true
            registerStackView.isHidden = false
            noteLabel.isHidden = false
            googleButtonStackView.isHidden = false

            loginButton.setTitle("Next", for: .normal)

            newUserLabel.text = "Already a member?"
            registerButton.setTitle(
                "Login here",
                for: .normal
            )

        case .forgotPassword:

            welcomeLabel.text = "Don't worry"
            loginLabel.text = "Let's set a new password"

            passwordStackView.isHidden = true
            confirmPasswordStackView.isHidden = true
            termsStackView.isHidden = true
            forgotPasswordButton.isHidden = true
            registerStackView.isHidden = true
            noteLabel.isHidden = true
            googleButtonStackView.isHidden = true

            loginButton.setTitle("Next", for: .normal)
        }
    }

    private func setupMainStackView() {

        mainStackView.axis = .vertical
        mainStackView.spacing = 20
        mainStackView.alignment = .fill
        mainStackView.distribution = .fill

        view.addSubview(mainStackView)

        mainStackView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([

            mainStackView.topAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.topAnchor,
                constant: 25
            ),

            mainStackView.leadingAnchor.constraint(
                equalTo: view.leadingAnchor,
                constant: 20
            ),

            mainStackView.trailingAnchor.constraint(
                equalTo: view.trailingAnchor,
                constant: -20
            )
        ])

        mainStackView.addArrangedSubview(headerStackView)
        mainStackView.addArrangedSubview(loginTypeControl)
        mainStackView.addArrangedSubview(mobileStackView)
        mainStackView.addArrangedSubview(passwordStackView)
        mainStackView.addArrangedSubview(confirmPasswordStackView)
        mainStackView.addArrangedSubview(termsStackView)
        mainStackView.addArrangedSubview(forgotPasswordButton)
        mainStackView.addArrangedSubview(actionStackView)
        mainStackView.addArrangedSubview(noteLabel)
        mainStackView.addArrangedSubview(googleButtonStackView)
    }

    private func setupTitleStackView() {

        titleStackView.axis = .vertical
        titleStackView.spacing = 8
        titleStackView.alignment = .leading
        titleStackView.distribution = .fill

        welcomeLabel.text = "Welcome back"
        welcomeLabel.textColor = .gray
        welcomeLabel.font = .systemFont(ofSize: 20)

        loginLabel.text = "Let's Login!"
        loginLabel.textColor = .white
        loginLabel.font = .systemFont(ofSize: 25)

        titleStackView.addArrangedSubview(welcomeLabel)
        titleStackView.addArrangedSubview(loginLabel)
    }

    private func setupHeaderStackView() {

        headerStackView.axis = .horizontal
        headerStackView.alignment = .top
        headerStackView.distribution = .fill
        headerStackView.spacing = 10

        closeButton.setImage(
            UIImage(systemName: "xmark"),
            for: .normal
        )

        closeButton.tintColor = .white

        closeButton.addTarget(
            self,
            action: #selector(closeButtonTapped),
            for: .touchUpInside
        )

        headerStackView.addArrangedSubview(titleStackView)
        headerStackView.addArrangedSubview(closeButton)

        titleStackView.setContentHuggingPriority(
            .defaultLow,
            for: .horizontal
        )

        closeButton.setContentHuggingPriority(
            .required,
            for: .horizontal
        )
    }

    private func setupLoginTypeControl() {

        loginTypeControl.selectedSegmentIndex = 0

        loginTypeControl.selectedSegmentTintColor = UIColor(
            white: 0.15,
            alpha: 1.0
        )

        loginTypeControl.backgroundColor = UIColor(
            white: 0.08,
            alpha: 1.0
        )

        loginTypeControl.layer.borderWidth = 1
        loginTypeControl.layer.borderColor = UIColor.gray.cgColor
        loginTypeControl.layer.cornerRadius = 12
        loginTypeControl.layer.masksToBounds = true

        loginTypeControl.setTitleTextAttributes(
            [
                .foregroundColor: UIColor.white
            ],
            for: .normal
        )

        loginTypeControl.setTitleTextAttributes(
            [
                .foregroundColor: UIColor.systemGreen
            ],
            for: .selected
        )

        loginTypeControl.addTarget(
            self,
            action: #selector(loginTypeChanged),
            for: .valueChanged
        )
    }

    private func setupMobileViews() {

        mobileTitleLabel.text = "Mobile Number *"
        mobileTitleLabel.textColor = .gray
        mobileTitleLabel.font = .systemFont(ofSize: 18)

        mobileNumberTextField.placeholder = "eg: 9876543210"

        mobileNumberTextField.attributedPlaceholder =
            NSAttributedString(
                string: "eg: 9876543210",
                attributes: [
                    .foregroundColor: UIColor.gray
                ]
            )

        mobileNumberTextField.delegate = self
        mobileNumberTextField.textColor = .white
        mobileNumberTextField.font = .systemFont(ofSize: 18)
        mobileNumberTextField.keyboardType = .phonePad
        mobileNumberTextField.textAlignment = .right

        mobileUnderlineView.backgroundColor = .gray
    }

    private func setupMobileInputStack() {

        mobileInputStackView.axis = .horizontal
        mobileInputStackView.alignment = .center
        mobileInputStackView.distribution = .fill
        mobileInputStackView.spacing = 30

        mobileInputStackView.addArrangedSubview(
            mobileTitleLabel
        )

        mobileInputStackView.addArrangedSubview(
            mobileNumberTextField
        )

        mobileTitleLabel.setContentHuggingPriority(
            .required,
            for: .horizontal
        )

        mobileNumberTextField.setContentHuggingPriority(
            .defaultLow,
            for: .horizontal
        )
    }

    private func setupMobileStack() {

        mobileStackView.axis = .vertical
        mobileStackView.spacing = 10
        mobileStackView.alignment = .fill
        mobileStackView.distribution = .fill

        mobileStackView.addArrangedSubview(
            mobileInputStackView
        )

        mobileStackView.addArrangedSubview(
            mobileUnderlineView
        )

        mobileUnderlineView.heightAnchor.constraint(
            equalToConstant: 1
        ).isActive = true
    }

    private func setupPasswordViews() {

        passwordTitleLabel.text = "Password *"
        passwordTitleLabel.textColor = .gray
        passwordTitleLabel.font = .systemFont(ofSize: 18)

        passwordTextField.textColor = .white
        passwordTextField.font = .systemFont(ofSize: 18)
        passwordTextField.isSecureTextEntry = true
        passwordTextField.textAlignment = .right
        passwordTextField.placeholder = "********"

        passwordTextField.attributedPlaceholder =
            NSAttributedString(
                string: "********",
                attributes: [
                    .foregroundColor: UIColor.gray
                ]
            )

        passwordTextField.delegate = self

        passwordTextField.addTarget(
            self,
            action: #selector(passwordTextChanged),
            for: .editingChanged
        )

        passwordButton.setImage(
            UIImage(systemName: "eye.slash"),
            for: .normal
        )

        passwordButton.tintColor = .gray

        passwordButton.addTarget(
            self,
            action: #selector(passwordButtonTapped),
            for: .touchUpInside
        )

        passwordUnderlineView.backgroundColor = .gray

        passwordErrorLabel.textColor = .red
        passwordErrorLabel.font = .systemFont(ofSize: 13)
        passwordErrorLabel.numberOfLines = 0
        passwordErrorLabel.isHidden = true
    }

    private func setupPasswordInputStack() {

        passwordInputStackView.axis = .horizontal
        passwordInputStackView.alignment = .center
        passwordInputStackView.distribution = .fill
        passwordInputStackView.spacing = 10

        passwordInputStackView.addArrangedSubview(
            passwordTitleLabel
        )

        passwordInputStackView.addArrangedSubview(
            passwordTextField
        )

        passwordInputStackView.addArrangedSubview(
            passwordButton
        )

        passwordTitleLabel.setContentHuggingPriority(
            .required,
            for: .horizontal
        )

        passwordButton.setContentHuggingPriority(
            .required,
            for: .horizontal
        )

        passwordTextField.setContentHuggingPriority(
            .defaultLow,
            for: .horizontal
        )
    }

    private func setupPasswordStack() {

        passwordStackView.axis = .vertical
        passwordStackView.spacing = 10
        passwordStackView.alignment = .fill
        passwordStackView.distribution = .fill

        passwordStackView.addArrangedSubview(
            passwordErrorLabel
        )

        passwordStackView.addArrangedSubview(
            passwordInputStackView
        )

        passwordStackView.addArrangedSubview(
            passwordUnderlineView
        )

        passwordUnderlineView.heightAnchor.constraint(
            equalToConstant: 1
        ).isActive = true
    }

    private func setupForgotPasswordButton() {

        forgotPasswordButton.setTitle(
            "Forgot Password",
            for: .normal
        )

        forgotPasswordButton.setTitleColor(
            .systemGreen,
            for: .normal
        )

        forgotPasswordButton.titleLabel?.font =
            .systemFont(
                ofSize: 18,
                weight: .semibold
            )

        forgotPasswordButton.contentHorizontalAlignment =
            .right

        forgotPasswordButton.addTarget(
            self,
            action: #selector(forgotPasswordButtonTapped),
            for: .touchUpInside
        )
    }

    private func setupLoginButton() {

        loginButton.setTitle(
            "Login",
            for: .normal
        )

        loginButton.setTitleColor(
            .black,
            for: .normal
        )

        loginButton.backgroundColor = .systemGreen

        loginButton.titleLabel?.font =
            .systemFont(
                ofSize: 18,
                weight: .semibold
            )

        loginButton.addTarget(
            self,
            action: #selector(loginButtonTapped),
            for: .touchUpInside
        )

        loginButton.layer.cornerRadius = 12

        loginButton.heightAnchor.constraint(
            equalToConstant: 55
        ).isActive = true

        loginButton.widthAnchor.constraint(
            equalToConstant: 90
        ).isActive = true
    }

    private func setupRegisterStack() {

        registerStackView.axis = .horizontal
        registerStackView.spacing = 2
        registerStackView.alignment = .center
        registerStackView.distribution = .fill

        newUserLabel.text =
            "New to Hello Meghalaya?"

        newUserLabel.textColor = .white
        newUserLabel.font = .systemFont(ofSize: 13)
        newUserLabel.numberOfLines = 1

        registerButton.setTitle(
            "Register now",
            for: .normal
        )

        registerButton.setTitleColor(
            .systemGreen,
            for: .normal
        )

        registerButton.titleLabel?.font =
            .systemFont(ofSize: 13)

        registerButton.addTarget(
            self,
            action: #selector(registerButtonTapped),
            for: .touchUpInside
        )

        registerStackView.addArrangedSubview(
            newUserLabel
        )

        registerStackView.addArrangedSubview(
            registerButton
        )

        newUserLabel.setContentCompressionResistancePriority(
            .defaultLow,
            for: .horizontal
        )

        registerButton.setContentCompressionResistancePriority(
            .required,
            for: .horizontal
        )
    }

    private func setupActionStack() {

        actionStackView.axis = .horizontal
        actionStackView.spacing = 8
        actionStackView.alignment = .center
        actionStackView.distribution = .fill

        actionStackView.addArrangedSubview(
            loginButton
        )

        actionStackView.addArrangedSubview(
            registerStackView
        )

        loginButton.setContentHuggingPriority(
            .required,
            for: .horizontal
        )

        registerStackView.setContentHuggingPriority(
            .defaultLow,
            for: .horizontal
        )

        registerStackView.setContentCompressionResistancePriority(
            .defaultLow,
            for: .horizontal
        )
    }

    private func setupNoteLabel() {
        noteLabel.text = """
        Note: Users who have not set a password can use the Forgot Password option to create one for future logins!
        """

        noteLabel.textColor = .gray
        noteLabel.font = .systemFont(ofSize: 16)
        noteLabel.textAlignment = .center
        noteLabel.numberOfLines = 0
    }

    private func setupGoogleLoginButton() {
        var configuration = UIButton.Configuration.filled()

        configuration.title = "Login with Google"
        configuration.image = UIImage(named: "GoogleLogo")?.resized(
            to: CGSize(
                width: 24,
                height: 24
            )
        )

        configuration.imagePlacement = .leading
        configuration.imagePadding = 12
        configuration.baseBackgroundColor = .systemGreen
        configuration.baseForegroundColor = .black
        configuration.cornerStyle = .medium

        configuration.contentInsets = NSDirectionalEdgeInsets(
            top: 0,
            leading: 20,
            bottom: 0,
            trailing: 20
        )

        googleLoginButton.configuration = configuration

        googleLoginButton.heightAnchor.constraint(
            equalToConstant: 55
        ).isActive = true

        googleLoginButton.addTarget(
            self,
            action: #selector(googleLoginButtonTapped),
            for: .touchUpInside
        )
    }
    private func setupGoogleButtonStack() {

        googleButtonStackView.axis = .horizontal
        googleButtonStackView.alignment = .center
        googleButtonStackView.distribution = .equalCentering
        googleButtonStackView.spacing = 0

        googleButtonStackView.addArrangedSubview(
            googleLoginButton
        )

        googleButtonStackView.distribution =
            .equalCentering

        googleButtonStackView.alignment =
            .center
    }

    @objc private func closeButtonTapped() {
        dismiss(animated: true)
    }

    @objc private func passwordButtonTapped() {

        passwordTextField.isSecureTextEntry.toggle()

        let imageName =
            passwordTextField.isSecureTextEntry
            ? "eye.slash"
            : "eye"

        passwordButton.setImage(
            UIImage(systemName: imageName),
            for: .normal
        )
    }

    @objc private func loginButtonTapped() {

        switch authMode {
        case .login:
            login()

        case .register:
            register()

        case .forgotPassword:
            resetPassword()
        }
    }

    private func login() {

        let loginId =
            mobileNumberTextField.text ?? ""

        let password =
            passwordTextField.text ?? ""

        if loginId.isEmpty {
            print("Please enter mobile Number")
            return
        }

        if loginId.count != 10 {
            print("Mobile Number must be 10 digits")
            return
        }

        if password.isEmpty {
            print("Please enter password")
            return
        }

        print("Login Validation successful")
    }

    private func register() {
        print("Register")
    }

    private func resetPassword() {
        print("Reset Password")
    }
    
    private func setupConfirmPasswordViews() {
        
        confirmPasswordTitleLabel.text = "Re-enter Password *"
        confirmPasswordTitleLabel.textColor = .gray
        confirmPasswordTitleLabel.font = .systemFont(ofSize: 18)
        
        confirmPasswordTextField.textColor = .white
        confirmPasswordTextField.font = .systemFont(ofSize: 18)
        confirmPasswordTextField.isSecureTextEntry = true
        confirmPasswordTextField.textAlignment = .right
        confirmPasswordTextField.placeholder = "*******"
        
        confirmPasswordTextField.attributedPlaceholder = NSAttributedString(string: "*******", attributes: [.foregroundColor: UIColor.gray])
        
        confirmPasswordButton.setImage(UIImage(systemName: "eye.slash"), for: .normal)
        
        
        confirmPasswordButton.tintColor = .gray

        confirmPasswordButton.addTarget(
            self,
            action: #selector(confirmPasswordButtonTapped),
            for: .touchUpInside
        )

        confirmPasswordUnderlineView.backgroundColor = .gray
        
    }
    private func setupConfirmPasswordInputStack() {

        confirmPasswordInputStackView.axis = .horizontal
        confirmPasswordInputStackView.alignment = .center
        confirmPasswordInputStackView.distribution = .fill
        confirmPasswordInputStackView.spacing = 10

        confirmPasswordInputStackView.addArrangedSubview(
            confirmPasswordTitleLabel
        )

        confirmPasswordInputStackView.addArrangedSubview(
            confirmPasswordTextField
        )

        confirmPasswordInputStackView.addArrangedSubview(
            confirmPasswordButton
        )

        confirmPasswordTitleLabel.setContentHuggingPriority(
            .required,
            for: .horizontal
        )

        confirmPasswordButton.setContentHuggingPriority(
            .required,
            for: .horizontal
        )

        confirmPasswordTextField.setContentHuggingPriority(
            .defaultLow,
            for: .horizontal
        )
    }
    
    private func setupConfirmPasswordStack() {

        confirmPasswordStackView.axis = .vertical
        confirmPasswordStackView.spacing = 10
        confirmPasswordStackView.alignment = .fill
        confirmPasswordStackView.distribution = .fill

        confirmPasswordStackView.addArrangedSubview(
            confirmPasswordInputStackView
        )

        confirmPasswordStackView.addArrangedSubview(
            confirmPasswordUnderlineView
        )

        confirmPasswordUnderlineView.heightAnchor.constraint(
            equalToConstant: 1
        ).isActive = true
    }
    
    private func setupTermsStackView() {
        termsStackView.axis = .horizontal
        termsStackView.spacing = 12
        termsStackView.alignment = .top
        termsStackView.distribution = .fill

        termsCheckboxButton.setImage(
            UIImage(systemName: "square"),
            for: .normal
        )

        termsCheckboxButton.tintColor = .gray

        termsCheckboxButton.addTarget(
            self,
            action: #selector(termsCheckboxTapped),
            for: .touchUpInside
        )

        let text = """
        By creating account you agree to our
        Terms of Use & Privacy Policy
        """

        let attributedText = NSMutableAttributedString(string: text)

        let termsRange = (text as NSString).range(of: "Terms of Use")

        let privacyRange = (text as NSString).range(of: "Privacy Policy")

        // Actual URLs
        attributedText.addAttribute(
            .link,
            value: "https://preprodweb.hellomeghalaya.in/terms_and_conditions",
            range: termsRange
        )

        attributedText.addAttribute(
            .link,
            value: "https://preprodweb.hellomeghalaya.in/privacy_policy",
            range: privacyRange
        )

        attributedText.addAttributes(
            [
                .foregroundColor: UIColor.white,
                .font: UIFont.systemFont(ofSize: 14)
            ],
            range: NSRange(
                location: 0,
                length: attributedText.length
            )
        )

        termsLabel.attributedText = attributedText

        termsLabel.backgroundColor = .clear
        termsLabel.isEditable = false
        termsLabel.isScrollEnabled = false
        termsLabel.isSelectable = true
        termsLabel.delegate = self

        termsStackView.addArrangedSubview(
            termsCheckboxButton
        )

        termsStackView.addArrangedSubview(
            termsLabel
        )

        termsCheckboxButton.setContentHuggingPriority(
            .required,
            for: .horizontal
        )
    }
    private func passwordValidationErrors() -> [String] {

        let password = passwordTextField.text ?? ""

        var errors: [String] = []

        if password.count < 8 {
            errors.append("Minimum 8 characters")
        }

        if password.rangeOfCharacter(from: .uppercaseLetters) == nil {
            errors.append("1 Uppercase Letter")
        }

        if password.rangeOfCharacter(from: .lowercaseLetters) == nil {
            errors.append("1 Lowercase Letter")
        }

        if password.rangeOfCharacter(from: .decimalDigits) == nil {
            errors.append("1 Number")
        }

        if password.rangeOfCharacter(
            from: CharacterSet.alphanumerics.inverted
        ) == nil {
            errors.append("1 Special Character")
        }

        return errors
    }
    
    private func openWebPage(title: String, urlString: String) {
        guard let url = URL(string: urlString) else {
            return
        }

        let controller = webViewController(pageTitle: title, pageURL: url)

        navigationController?.pushViewController(controller, animated:true)
    }

    @objc private func registerButtonTapped() {

        switch authMode {
        case .login:
            authMode = .register

        case .register:
            authMode = .login

        case .forgotPassword:
            authMode = .login
        }

        reloadUI()
    }

    @objc private func forgotPasswordButtonTapped() {

        authMode = .forgotPassword

        reloadUI()
    }

    @objc private func googleLoginButtonTapped() {
        print("Google Login Button Tapped")
    }

    @objc private func loginTypeChanged() {

        mobileNumberTextField.text = ""
        mobileNumberTextField.resignFirstResponder()

        if loginTypeControl.selectedSegmentIndex == 0 {

            mobileTitleLabel.text = "Mobile Number *"
            mobileNumberTextField.placeholder = "eg: 9876543210"
            mobileNumberTextField.keyboardType = .phonePad

        } else {

            mobileTitleLabel.text = "Email ID *"
            mobileNumberTextField.placeholder = "johndoe@gmail.com"
            mobileNumberTextField.keyboardType = .emailAddress
        }
    }

    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }

    @objc private func passwordTextChanged() {

        let password = passwordTextField.text ?? ""

        if password.isEmpty {
            passwordErrorLabel.isHidden = true
            return
        }

        let errors = passwordValidationErrors()

        if errors.isEmpty {
            passwordErrorLabel.isHidden = true
        } else {
            passwordErrorLabel.text = errors.joined(separator: ", ")
            passwordErrorLabel.isHidden = false
        }
    }
    @objc private func confirmPasswordButtonTapped() {

        confirmPasswordTextField.isSecureTextEntry.toggle()

        let imageName =
            confirmPasswordTextField.isSecureTextEntry
            ? "eye.slash"
            : "eye"

        confirmPasswordButton.setImage(
            UIImage(systemName: imageName),
            for: .normal
        )
    }
    @objc private func termsCheckboxTapped() {

        let isChecked =
            termsCheckboxButton.currentImage ==
            UIImage(systemName: "checkmark.square")

        let imageName = isChecked
            ? "square"
            : "checkmark.square"

        termsCheckboxButton.setImage(
            UIImage(systemName: imageName),
            for: .normal
        )
    }
}

extension UIImage {

    func resized(to size: CGSize) -> UIImage? {

        let renderer =
            UIGraphicsImageRenderer(size: size)

        return renderer.image { _ in

            self.draw(in: CGRect(
                    origin: .zero,
                    size: size
                )
            )
        }
    }
}

extension LoginViewController: UITextFieldDelegate {

    func textField(
        _ textField: UITextField,
        shouldChangeCharactersIn range: NSRange,
        replacementString string: String
    ) -> Bool {

        guard textField == mobileNumberTextField else {
            return true
        }

        if loginTypeControl.selectedSegmentIndex == 0 {

            let currentText =
                textField.text ?? ""

            let updatedText =
                (currentText as NSString).replacingCharacters(
                    in: range,
                    with: string
                )

            return updatedText.count <= 10 &&
                   updatedText.allSatisfy {
                       $0.isNumber
                   }
        }

        return true
    }

    func textFieldShouldReturn(
        _ textField: UITextField
    ) -> Bool {

        textField.resignFirstResponder()

        return true
    }

}
extension LoginViewController: UITextViewDelegate {

    func textView(
        _ textView: UITextView,
        shouldInteractWith URL: URL,
        in characterRange: NSRange,
        interaction: UITextItemInteraction
    ) -> Bool {

        let title: String

        if URL.absoluteString.contains("terms_and_conditions") {
            title = "Terms Of Use"
        } else if URL.absoluteString.contains("privacy_policy") {
            title = "Privacy Policy"
        } else {
            return true
        }

        let controller = webViewController(
            pageTitle: title,
            pageURL: URL
        )

        if let navigationController = navigationController {
            navigationController.pushViewController(
                controller,
                animated: true
            )
        } else {
            let navController = UINavigationController(
                rootViewController: controller)

            present(navController,animated: true)
        }

        return false
    }
}
