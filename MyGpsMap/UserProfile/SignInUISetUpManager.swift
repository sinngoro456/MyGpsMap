//
//  SignInView.swift
//  MyGpsMap
//
//  Created by 川渕悟郎 on 2024/12/12.
//

// サインインURI : https://mygpsmapdomain/auth/callback/
// サインインURI : https://mygpsmapdomain/auth/sighout/
//Hosted UI Endpoint: https://mygpsmapdomain-kawa.auth.ap-northeast-3.amazoncognito.com/
//Test Your Hosted UI Endpoint: https://mygpsmapdomain-kawa.auth.ap-northeast-3.amazoncognito.com/login?response_type=code&client_id=7memoka5fbgdd3oum0uca3t8ch&redirect_uri=https://example.com/cb/

import UIKit

class SignInView: UIViewController {
    var auth: AuthService?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 背景色の設定
        view.backgroundColor = .white
        
        // ログインボタンの作成
        let signInButton = UIButton(type: .system)
        signInButton.setTitle("ログイン", for: .normal)
        signInButton.addTarget(self, action: #selector(signInTapped), for: .touchUpInside)
        
        // ボタンのレイアウト
        signInButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(signInButton)
        
        NSLayoutConstraint.activate([
            signInButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            signInButton.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    @objc private func signInTapped() {
        Task {
            await auth?.signIn()
        }
    }
}
