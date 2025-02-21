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
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    func showSignInView() {
        let signInView = SignInView()
        
        addChild(signInView)
        view.addSubview(signInView.view)
        
        signInView.view.frame = view.bounds
        signInView.didMove(toParent: self)
    }
}
