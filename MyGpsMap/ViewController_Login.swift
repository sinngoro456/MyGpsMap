import UIKit
import Amplify
import AWSCognitoAuthPlugin

class ViewController_Config: UIViewController {
    var auth = AuthService()
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        print("hi1")
        configureAmplify()
        
        // 非同期メソッドを呼び出すためにTaskを使用します。
        Task {
            await auth.checkSessionStatus()
            auth.observeAuthEvents()
            showSignInView() // サインインビューを表示
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // UIの設定や初期化処理をここで行うことができます。
    }

    // SwiftUIビューを表示するためのメソッド（必要に応じて実装）
    func showSignInView() {
        let signInView = SignInView()
        signInView.auth = auth // AuthServiceを渡す
        
        self.addChild(signInView)
        self.view.addSubview(signInView.view)
        
        signInView.view.frame = self.view.bounds
        signInView.didMove(toParent: self)
    }
}

func configureAmplify() {
    do {
        try Amplify.add(plugin: AWSCognitoAuthPlugin())
        try Amplify.configure()
    } catch {
        print("Could not initialize Amplify -", error)
    }
}
