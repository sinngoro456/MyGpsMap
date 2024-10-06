import UIKit
import Amplify

class ViewController_Config: UIViewController {

    private var usernameTextField: UITextField!
    private var passwordTextField: UITextField!
    private var messageLabel: UILabel!
    private var loginButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    private func setupUI() {
        view.backgroundColor = .white

        usernameTextField = LoginSetUpManager.createTextField(placeholder: "Username")
        passwordTextField = LoginSetUpManager.createTextField(placeholder: "Password", isSecure: true)
        messageLabel = LoginSetUpManager.createLabel(text: "ログインしてください")
        loginButton = LoginSetUpManager.createButton(title: "LOGIN", target: self, action: #selector(loginButtonTapped))

        [usernameTextField, passwordTextField, messageLabel, loginButton].forEach { view.addSubview($0) }

        LoginSetUpManager.setupConstraints(view: view, usernameTextField: usernameTextField, passwordTextField: passwordTextField, loginButton: loginButton, messageLabel: messageLabel)
    }

    @objc private func loginButtonTapped() {
        guard let username = usernameTextField.text, !username.isEmpty,
              let password = passwordTextField.text, !password.isEmpty else {
            changeMessage(message: "ユーザー名とパスワードを入力してください")
            return
        }
        signIn(username: username, password: password)
    }

    private func signIn(username: String, password: String) {
        Amplify.Auth.signIn(username: username, password: password) { result in
            switch result {
            case .success:
                self.changeMessage(message: "ログイン成功！")
                print("Sign in succeeded")
            case .failure(let error):
                self.changeMessage(message: "ログイン失敗…")
                print("Sign in failed \(error)")
            }
        }
    }

    private func changeMessage(message: String) {
        DispatchQueue.main.async {
            self.messageLabel.text = message
        }
    }
}
