//
//  ViewController_login.swift
//  MyGpsMap
//
//  Created by 川渕悟郎 on 2024/10/04.
//

import Amplify

class ViewController_Config: UIViewController {

    // 各々のオブジェクトとコードを紐付け
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var messageLabel: UILabel!

    // 画面がロードされた際の初期化
    override func viewDidLoad() {
        super.viewDidLoad()
        messageLabel.text = "ログインしてください"
    }

    // LOGINボタン押下時の挙動
    @IBAction func logIn(_ sender: Any) {
        let username = usernameTextField.text!
        let password = passwordTextField.text!
        signIn(username: username, password: password)
    }

    // ユーザーログイン機能
    func signIn(username: String, password: String) {
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

    // messageLabelのテキストを変更
    func changeMessage(message: String) {
        DispatchQueue.main.async {
            self.messageLabel.text = message
        }
    }
}

