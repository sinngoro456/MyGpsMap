//VieCOntroller_Login.swift

import UIKit
import Amplify

class ViewController_Config: UIViewController {
    var auth = AuthService()
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        Task {
            await auth.checkSessionStatus()
            auth.observeAuthEvents()
            showSignInView()
        }
        print("hi1")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    func showSignInView() {
        let signInView = SignInView()
        signInView.auth = auth
        
        addChild(signInView)
        view.addSubview(signInView.view)
        
        signInView.view.frame = view.bounds
        signInView.didMove(toParent: self)
        print("hi4")
    }
}
