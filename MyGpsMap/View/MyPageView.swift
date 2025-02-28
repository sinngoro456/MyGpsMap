import SwiftUI

struct MyPageView: View {
    
    /// AuthService（認証系）と UserSessionManager（ログイン状態など）
    /// フレンド一覧
    @State private var friendsList: [String] = []
    @StateObject var authService = AuthService()
    
    /// 新しいフレンドを追加するための入力
    @State private var newFriendId: String = ""
    
    /// 到達スポットの一覧
    @State private var visitedSpots: [VisitedSpot] = [
        VisitedSpot(imageName: "spot1", description: "東京タワー"),
        VisitedSpot(imageName: "spot2", description: "富士山"),
        VisitedSpot(imageName: "spot3", description: "浅草寺")
    ]
    
    /// ログアウト/ログインボタンの表示状態
    @State private var showLogoutButton = false
    
    /// フレンド画面への遷移状態
    @State private var showFriendView = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 0) {
                    // 1) グラデーション背景とユーザー情報
                    ZStack(alignment: .bottomLeading) {
                        // グラデーション背景
                        LinearGradient(gradient: Gradient(colors: [Color.blue, Color.purple]), startPoint: .top, endPoint: .bottom)
                            .frame(height: 200)
                        
                        // バナーを横に並べる
                        HStack(spacing: 20) {
                            BannerButton(iconName: "star.fill", title: "都人") {
                                print("お気に入りがタップされました")
                            }.frame(width: 70, height: 200)
                            BannerButton(iconName: "trophy.fill", title: "10000kmUser") {
                                print("実績がタップされました")
                            }.frame(width: 70, height: 200)
                            BannerButton(iconName: "gear", title: "メカニック") {
                                print("設定がタップされました")
                            }.frame(width: 70, height: 200)
                        }
                        .padding(.trailing, 16)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                        
                        // ユーザー画像とID
                        VStack(alignment: .leading, spacing: 8) {
                            ProfileSection(isSignedIn: authService.isSignedIn)
                            
                            Text("UserID: \(UserSessionManager.shared.user_id ?? "未設定")")
                                .font(.callout)
                                .foregroundColor(.white)
                        }
                        .padding(.leading, 16)
                        .padding(.bottom, 16)
                    }
                    
                    // 2) フレンド関連のUI
                    HStack {
                        // 左上のアイコン
                        Button(action: {
                            print("左上のアイコンがタップされました")
                        }) {
                            Image(systemName: "gear")
                                .font(.title)
                                .foregroundColor(.gray)
                        }
                        .padding(.leading, 16)
                        
                        Spacer()
                        
                        // フレンドボタン
                        Button(action: {
                            showFriendView = true
                        }) {
                            Text("フレンド")
                                .font(.headline)
                                .foregroundColor(.blue)
                        }
                        .padding(.trailing, 16)
                    }
                    .padding(.vertical, 8)
                    
                    // 3) 到達スポット、走行距離、愛車の情報
                    HStack(spacing: 20) {
                        VStack {
                            Text("到達スポット")
                                .font(.subheadline)
                            Text("\(visitedSpots.count)")
                                .font(.title)
                        }
                        
                        VStack {
                            Text("走行距離")
                                .font(.subheadline)
                            Text("100 km")
                                .font(.title)
                        }
                        
                        VStack {
                            Text("愛車")
                                .font(.subheadline)
                            Image(systemName: "bicycle")
                                .font(.title)
                        }
                    }
                    .padding(.vertical, 16)
                    
                    // 4) 到達スポットの一覧
                    VStack(alignment: .leading, spacing: 8) {
                        Text("到達スポット一覧")
                            .font(.headline)
                            .padding(.horizontal, 16)
                        
                        ForEach(visitedSpots) { spot in
                            HStack {
                                Image(spot.imageName)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 80, height: 80)
                                    .cornerRadius(8)
                                
                                Text(spot.description)
                                    .font(.subheadline)
                                
                                Spacer()
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(Color(.systemBackground))
                            .cornerRadius(8)
                            .shadow(radius: 2)
                        }
                    }
                    .padding(.bottom, 16)
                }
            }
            .navigationTitle(Text(authService.isSignedIn ? "\(UserSessionManager.shared.user_id ?? "ユーザー名")" : "未ログイン"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                // タイトルをタップ可能にする
                ToolbarItem(placement: .principal) {
                    Button(action: {
                        showLogoutButton.toggle()
                    }) {
                        Text(authService.isSignedIn ? "\(UserSessionManager.shared.user_id ?? "ユーザー名")" : "未ログイン")
                            .font(.headline)
                            .foregroundColor(.primary)
                    }
                }
                
                // ベルボタンをナビゲーションバー右上に置く例
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        print("Bell tapped")
                    }) {
                        Image(systemName: "bell")
                    }
                }
            }
            .onAppear {
                // ビュー読み込み時にログイン状態を反映
                if authService.isSignedIn {
                    print("ログイン状態です")
                } else {
                    print("ログアウト状態です")
                }
            }
            .actionSheet(isPresented: $showLogoutButton) {
                ActionSheet(
                    title: Text("アカウント"),
                    buttons: [
                        .default(Text(authService.isSignedIn ? "ログアウト" : "ログイン")) {
                            Task {
                                await toggleSignInOut()
                            }
                        },
                        .cancel()
                    ]
                )
            }
            .sheet(isPresented: $showFriendView) {
                FriendView()
            }
        }
    }
    
    // MARK: - Actions
    
    /// ログイン状態をトグル
    private func toggleSignInOut() async {
        if UserSessionManager.shared.user_id == nil {
            // 未ログイン → ログイン
            Task {
                await authService.signIn()
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
    var isSignedIn: Bool
    
    var body: some View {
        ZStack {
            // 大きい丸いアイコン
            Image(systemName: isSignedIn ? "person.circle.fill" : "person.circle")
                .resizable()
                .scaledToFit()
                .frame(width: 80, height: 80)
                .foregroundColor(.white)
            
            // オンラインステータス: 小さい丸を右下に重ねる
            if isSignedIn {
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

struct VisitedSpot: Identifiable {
    let id = UUID()
    let imageName: String
    let description: String
}

// バナーのコンポーネント
struct BannerButton: View {
    let iconName: String
    let title: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: iconName)
                    .font(.title2)
                    .foregroundColor(.white)
                Text(title)
                    .font(.caption)
                    .foregroundColor(.white)
            }
            .padding(12)
            .background(Color.white.opacity(0.2))
            .cornerRadius(8)
        }
    }
}

// フレンド画面
struct FriendView: View {
    @State private var searchText: String = ""
    @State private var isShowAlert: Bool = false
    @State private var alertMessage: String = ""
    
    @ObservedObject private var friendManager = FriendManager.shared
    
    var body: some View {
        NavigationView {
            VStack(spacing: 16) {
                // テキストフィールドと検索ボタン
                HStack {
                    TextField("フレンドのUser IDを入力", text: $searchText)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .autocapitalization(.none)
                        .keyboardType(.asciiCapable)
                    
                    Button(action: {
                        addFriends([searchText])
                    }) {
                        Text("追加")
                            .font(.headline)
                            .padding(.horizontal, 8)
                    }
                }
                .padding()
                
                // 検索結果の表示
                if friendManager.friends.isEmpty {
                    Spacer()
                    Text("フレンドがいません。")
                        .font(.headline)
                        .foregroundColor(.gray)
                    Spacer()
                } else {
                    List(friendManager.friends, id: \.user_id) { friend in
                        Text(friend.user_id)
                            .onAppear {
                                print("フレンド: \(friend.user_id)")
                            }
                    }
                    .frame(height: 200)
                }
                
                Spacer()
            }
            .navigationTitle("フレンド")
            .navigationBarTitleDisplayMode(.inline)
            .alert(isPresented: $isShowAlert) {
                Alert(
                    title: Text("結果"),
                    message: Text(alertMessage),
                    dismissButton: .default(Text("OK"))
                )
            }
        }
    }
    
    // フレンドを追加するメソッド
    private func addFriends(_ friendIds: [String]) {
        Task {
            let message = await friendManager.addFriends(friendIds)
            DispatchQueue.main.async {
                alertMessage = message
                isShowAlert = true
            }
        }
    }
}