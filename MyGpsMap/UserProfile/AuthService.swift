//
//  AuthService.swift
//  MyGpsMap
//
//  Created by 川渕悟郎 on 2024/12/12.
//

import UIKit
import Amplify
import AWSCognitoAuthPlugin

protocol AuthServiceDelegate: AnyObject {
    func signIn()
}

class AuthService: ObservableObject {
    @Published var isSignedIn = false
    
    func checkSessionStatus() {
        Task {
            do {
                let session = try await Amplify.Auth.fetchAuthSession()
                DispatchQueue.main.async { [weak self] in
                    self?.isSignedIn = session.isSignedIn
                }
                print("セッションの取得完了")
            } catch {
                print("セッションの取得に失敗しました: \(error)")
            }
        }
    }
    
    private var window: UIWindow {
        guard
            let scene = UIApplication.shared.connectedScenes.first,
            let windowSceneDelegate = scene.delegate as? UIWindowSceneDelegate,
            let window = windowSceneDelegate.window as? UIWindow
        else { return UIWindow() }
        
        return window
    }
    
    func signIn() {
        Task {
            do {
                let signInResult = try await Amplify.Auth.signInWithWebUI(for: .google, presentationAnchor: window)
                if signInResult.isSignedIn {
                    print("ログイン成功")
                }
            } catch {
                print("ログイン失敗: \(error)")
            }
        }
    }
    
    func observeAuthEvents() {
        _ = Amplify.Hub.listen(to: .auth) { [weak self] result in
            switch result.eventName {
            case HubPayload.EventName.Auth.signedIn:
                DispatchQueue.main.async {
                    self?.isSignedIn = true
                }
                
            case HubPayload.EventName.Auth.signedOut,
                 HubPayload.EventName.Auth.sessionExpired:
                DispatchQueue.main.async {
                    self?.isSignedIn = false
                }
                
            default:
                break
            }
        }
    }
}
