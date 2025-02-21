//
//  MyPageView.swift
//  MyGpsMap
//
//  Created by 川渕悟郎 on 2025/02/21.
//

import SwiftUI

struct MyPageView: View {
    
    /// AuthService（認証系）と UserSessionManager（ログイン状態など）
    /// フレンド一覧
    @State private var friendsList: [String] = []
    @StateObject var authService = AuthService()
    
    /// 新しいフレンドを追加するための入力
    @State private var newFriendId: String = ""
    
    /// Viewが登場した時に呼ばれるフレンド一覧更新など
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 16) {
                    
                    // 1) プロフィール画像 & オンラインステータス
                    ProfileSection(isLoggedIn: UserSessionManager.shared.isLoggedIn)
                    
                    // 2) ユーザーID表示
                    Text("UserID: \(UserSessionManager.shared.user_id ?? "未設定")")
                        .font(.callout)
                        .foregroundColor(.gray)
                    
                    // 3) サインイン/アウトボタン
                    Button(action: {
                        Task {
                            await toggleSignInOut()
                        }
                    }) {
                        Text(UserSessionManager.shared.isLoggedIn ? "ログアウト🐻" : "ログイン🦔")
                            .font(.headline)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(UserSessionManager.shared.isLoggedIn ? Color.red : Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                    
                    // 4) 立てたピンの総数
                    Text("立てたピンの総数: \(PinManager.shared.pins.count)")
                        .font(.subheadline)
                    
                    // 5) フレンド登録
                    VStack(alignment: .leading, spacing: 4) {
                        Text("フレンドを登録+")
                            .font(.headline)
                        
                        HStack {
                            TextField("フレンドのUser IDを入力", text: $newFriendId)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .autocapitalization(.none)
                                .keyboardType(.asciiCapable)
                            Button("追加") {
                                Task {
                                    await addFriend()
                                }
                            }
                            .font(.headline)
                            .padding(.horizontal, 8)
                        }
                    }
                    
                    // 6) フレンド一覧の表示 (List)
                    VStack(alignment: .leading, spacing: 4) {
                        Text("フレンド一覧")
                            .font(.headline)
                        
                        // SwiftUIのList
                        List(friendsList, id: \.self) { friendId in
                            Text(friendId)
                        }
                        .frame(height: 200) // 適宜高さ調整
                    }
                }
                .padding()
                .onAppear {
                    // 画面が表示されるタイミングで friendsList を更新
                    friendsList = FriendManager.shared.getFriendUserIdList()
                }
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    // ベルボタンをナビゲーションバー右上に置く例
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: {
                            print("Bell tapped")
                        }) {
                            Image(systemName: "bell")
                        }
                    }
                }
            }
            .navigationTitle("My Page")
        }
    }
    
    // MARK: - Actions
    
    /// ログイン状態をトグル
    private func toggleSignInOut() async {
        if UserSessionManager.shared.user_id == nil {
            // 未ログイン → ログイン
            Task {
                                        // ★ signInに必要なpresentationAnchorを渡す
                                        if let scene = UIApplication.shared.connectedScenes
                                            .first as? UIWindowScene,
                                           let window = scene.windows.first {
                                            await authService.signIn(anchor: window)
                                        }
                                    }
            if let userId = UserSessionManager.shared.user_id {
                await UserSessionManager.shared.login(userId: userId, token: nil)
            }
        } else {
            // ログイン済み → ログアウト
            await authService.signOut()
            UserSessionManager.shared.logout()
        }
        // friendsList更新
        friendsList = FriendManager.shared.getFriendUserIdList()
    }
    
    /// フレンド追加
    private func addFriend() async {
        guard !newFriendId.isEmpty else { return }
        do {
            await FriendManager.shared.addFriends([newFriendId])
            print("フレンドが追加されました：\(newFriendId)")
            // リスト更新
            friendsList = FriendManager.shared.getFriendUserIdList()
            newFriendId = ""
        }
    }
}
struct ProfileSection: View {
    var isLoggedIn: Bool
    
    var body: some View {
        ZStack {
            // 大きい丸いアイコン
            Image(systemName: isLoggedIn ? "person.circle.fill" : "person.circle")
                .resizable()
                .scaledToFit()
                .frame(width: 80, height: 80)
                .foregroundColor(.gray)
            
            // オンラインステータス: 小さい丸を右下に重ねる
            if isLoggedIn {
                Circle()
                    .fill(Color.white)
                    .frame(width: 12, height: 12)
                    .offset(x: 24, y: 24) // 画像の右下あたり
                
                Circle()
                    .fill(Color.green)
                    .frame(width: 10, height: 10)
                    .offset(x: 24, y: 24)
            } else {
                Circle()
                    .fill(Color.white)
                    .frame(width: 12, height: 12)
                    .offset(x: 24, y: 24)
                
                Circle()
                    .fill(Color.gray)
                    .frame(width: 10, height: 10)
                    .offset(x: 24, y: 24)
            }
        }
        .frame(width: 100, height: 100)
        .padding(.vertical, 8)
    }
}

