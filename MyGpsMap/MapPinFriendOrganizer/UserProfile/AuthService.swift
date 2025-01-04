//
//  AuthService.swift
//  MyGpsMap
//
//  Created by 川渕悟郎 on 2024/12/12.
//

import Foundation
import Amplify
import AWSCognitoAuthPlugin
import UIKit

class AuthService: ObservableObject {
    @Published var isSignedIn = false
    
    func checkSessionStatus() async {
        do {
            let session = try await Amplify.Auth.fetchAuthSession()
            DispatchQueue.main.async {
                self.isSignedIn = session.isSignedIn
            }
            if let cognitoSession = session as? AWSAuthCognitoSession {
                // userPoolTokensResultからトークンを取得
                switch cognitoSession.userPoolTokensResult {
                    case .success(let tokens):
                        // idTokenを取得
                        let idToken = tokens.idToken
                        let accessToken = tokens.idToken
                        
                        // JWTをデコードしてcognito:usernameを取得
                        if let username = getCognitoUsername(from: idToken) {
                            print("Cognito Username: \(username)")
                            await UserSessionManager.shared.login(userId: username,token: accessToken)
                        } else {
                            print("cognito:usernameが見つかりませんでした。")
                        }
                        
                    case .failure(let error):
                        print("トークンの取得に失敗しました: \(error)")
                    }
            }
        } catch {
            print("セッション取得失敗: \(error)")
        }
    }
    
    @MainActor
    private var window: UIWindow {
        guard
            let scene = UIApplication.shared.connectedScenes.first,
            let windowSceneDelegate = scene.delegate as? UIWindowSceneDelegate,
            let window = windowSceneDelegate.window as? UIWindow
        else { return UIWindow() }
        
        return window
    }
    
    @MainActor
    func signIn() async {
        do {
            let signInResult = try await Amplify.Auth.signInWithWebUI(presentationAnchor: window)
            if signInResult.isSignedIn {
                await UserSessionManager.shared.login(userId: nil,token: nil)
                print("ログイン成功")
                isSignedIn = true
                Task {
                    await checkSessionStatus() // セッション状態を確認
                }
            }
        } catch {
            print("ログイン失敗: \(error)")
        }
    }
    
    @MainActor
    func signOut() async {
        do {
            _ = await Amplify.Auth.signOut()
            UserSessionManager.shared.logout()
            print("サインアウト成功")
            isSignedIn = false
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
    
    // JWTからcognito:usernameを取得する関数
    private func getCognitoUsername(from idToken: String) -> String? {
        // idTokenをドットで分割
        let components = idToken.components(separatedBy: ".")
        
        guard components.count == 3,
              let payloadData = Data(base64UrlEncoded: components[1]),
              let json = try? JSONSerialization.jsonObject(with: payloadData, options: []) as? [String: Any],
              let username = json["cognito:username"] as? String else {
            return nil
        }
        
        return username
    }
}

// Base64Urlデコードの拡張機能
extension Data {
    init?(base64UrlEncoded string: String) {
        var base64 = string.replacingOccurrences(of: "-", with: "+")
                         .replacingOccurrences(of: "_", with: "/")
        switch base64.count % 4 {
        case 2:
            base64 += "=="
        case 3:
            base64 += "="
        default:
            break
        }
        self.init(base64Encoded: base64)
    }
}
