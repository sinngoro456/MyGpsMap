//
//  SignInView.swift
//  MyGpsMap
//
//  Created by 川渕悟郎 on 2024/12/12.
//

import UIKit

class SignInView: UIViewController {
    var auth: AuthService?
    
    private var authButton: UIButton!
    private var profileImageView: UIImageView!
    private var onlineStatusView: UIView!
    private var onlineStatusBorderView: UIView!
    private var friendsTableView: UITableView!
    private var addFriendLabel: UILabel!
    private var addFriendTextField: UITextField!
    private var addFriendButton: UIButton!
    private var bellButton: UIButton!
    private var pinCountLabel: UILabel!
    
    // ユーザーID表示用ラベルを追加
    private var userIdLabel: UILabel!

    private var friendsList = FriendManager.shared.getFriendUserIdList()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        updateAuthButtonState()
        updatePinCount()
        
        // ユーザーIDを表示
        userIdLabel.text = UserSessionManager.shared.user_id ?? "未設定" // ユーザーIDを設定

        // タップジェスチャーを追加
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        
        // プロフィール画像
        profileImageView = UIImageView()
        profileImageView.contentMode = .scaleAspectFit
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        
        // ユーザーID表示ラベル
        userIdLabel = UILabel()
        userIdLabel.font = UIFont.systemFont(ofSize: 14)
        userIdLabel.textAlignment = .center
        userIdLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // オンラインステータス表示
        onlineStatusBorderView = UIView()
        onlineStatusBorderView.layer.cornerRadius = 6
        onlineStatusBorderView.backgroundColor = .white
        onlineStatusBorderView.translatesAutoresizingMaskIntoConstraints = false

        onlineStatusView = UIView()
        onlineStatusView.layer.cornerRadius = 5
        onlineStatusView.translatesAutoresizingMaskIntoConstraints = false
        
        // 認証ボタン
        authButton = UIButton(type: .system)
        authButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        authButton.addTarget(self, action: #selector(authButtonTapped), for: .touchUpInside)
        authButton.translatesAutoresizingMaskIntoConstraints = false
        
        // ピン数表示ラベル
        pinCountLabel = UILabel()
        pinCountLabel.font = UIFont.systemFont(ofSize: 14)
        pinCountLabel.textAlignment = .center
        pinCountLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // フレンド登録ラベル
        addFriendLabel = UILabel()
        addFriendLabel.text = "フレンドを登録+"
        addFriendLabel.font = UIFont.boldSystemFont(ofSize: 16)
        addFriendLabel.isUserInteractionEnabled = true
        addFriendLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(addFriendLabelTapped)))
        addFriendLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // 新しいフレンド追加用テキストフィールド
        addFriendTextField = UITextField()
        addFriendTextField.placeholder = "フレンドのUser IDを入力"
        
        // キーボード設定：最初の一文字が大文字にならない、記号も入力可能にする
        addFriendTextField.autocapitalizationType = .none // 自動大文字化を無効化
        addFriendTextField.keyboardType = .asciiCapable // 日本語入力を無効化
        addFriendTextField.borderStyle = .roundedRect
        addFriendTextField.translatesAutoresizingMaskIntoConstraints = false
        
        // フレンド追加ボタン
        addFriendButton = UIButton(type: .system)
        addFriendButton.setTitle("追加", for: .normal)
        addFriendButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        addFriendButton.addTarget(self, action: #selector(addFriendTapped), for: .touchUpInside)
        addFriendButton.translatesAutoresizingMaskIntoConstraints = false
        
        // フレンド一覧 (UITableView)
        friendsTableView = UITableView()
        friendsTableView.delegate = self
        friendsTableView.dataSource = self
        friendsTableView.register(UITableViewCell.self, forCellReuseIdentifier: "FriendCell")
        friendsTableView.translatesAutoresizingMaskIntoConstraints = false
        
        // ベルボタン
        bellButton = UIButton(type: .system)
        bellButton.setImage(UIImage(systemName: "bell"), for: .normal)
        bellButton.translatesAutoresizingMaskIntoConstraints = false
        
        
       let profileContainer = UIView()
       profileContainer.addSubview(profileImageView)
       profileContainer.addSubview(onlineStatusBorderView)
       profileContainer.addSubview(onlineStatusView)
       profileContainer.translatesAutoresizingMaskIntoConstraints = false
        
       let addFriendContainer = UIStackView(arrangedSubviews: [addFriendTextField, addFriendButton])
       addFriendContainer.axis = .horizontal
       addFriendContainer.spacing = 8
       addFriendContainer.translatesAutoresizingMaskIntoConstraints = false
        
       let stackView = UIStackView(arrangedSubviews: [
           profileContainer,
           userIdLabel, // ユーザーIDラベルをスタックビューに追加
           authButton,
           pinCountLabel,
           addFriendLabel,
           addFriendContainer,
           friendsTableView,
       ])
        
       stackView.axis = .vertical
       stackView.spacing = 16
       stackView.alignment = .fill
       stackView.distribution = .fill
       stackView.translatesAutoresizingMaskIntoConstraints = false
        
       view.addSubview(stackView)
       view.addSubview(bellButton)

       NSLayoutConstraint.activate([
           stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
           stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
           stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
           stackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            
           profileContainer.heightAnchor.constraint(equalToConstant: 100),
           profileImageView.centerXAnchor.constraint(equalTo: profileContainer.centerXAnchor),
           profileImageView.centerYAnchor.constraint(equalTo: profileContainer.centerYAnchor),
           profileImageView.widthAnchor.constraint(equalToConstant: 80),
           profileImageView.heightAnchor.constraint(equalToConstant: 80),
            
           onlineStatusBorderView.widthAnchor.constraint(equalToConstant: 12),
           onlineStatusBorderView.heightAnchor.constraint(equalToConstant: 12),
           onlineStatusBorderView.trailingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: -5),
           onlineStatusBorderView.bottomAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: -5),

           onlineStatusView.widthAnchor.constraint(equalToConstant: 10),
           onlineStatusView.heightAnchor.constraint(equalToConstant: 10),
           onlineStatusView.centerXAnchor.constraint(equalTo: onlineStatusBorderView.centerXAnchor),
           onlineStatusView.centerYAnchor.constraint(equalTo: onlineStatusBorderView.centerYAnchor),
            
           userIdLabel.heightAnchor.constraint(equalToConstant: 20), // ユーザーIDラベルの高さ制約
            
           addFriendTextField.heightAnchor.constraint(equalToConstant: 40),
           addFriendButton.widthAnchor.constraint(equalToConstant: 60),
            
           bellButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
           bellButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
           bellButton.widthAnchor.constraint(equalToConstant: 30),
           bellButton.heightAnchor.constraint(equalToConstant: 30)
      ])
   }

   @objc private func dismissKeyboard() {
      view.endEditing(true) // キーボードを閉じる処理
   }
   
   @objc private func authButtonTapped() {
      Task {
         if UserSessionManager.shared.user_id == nil {
            await auth?.signIn()
            if let userId = UserSessionManager.shared.user_id {
               await UserSessionManager.shared.login(userId: userId, token: nil)
            }
         } else {
            await auth?.signOut()
            UserSessionManager.shared.logout()
         }
         updateAuthButtonState()
         updatePinCount()
         friendsTableView.reloadData()
      }
   }

   @objc private func addFriendLabelTapped() {
      addFriendTextField.becomeFirstResponder()
   }

   @objc private func addFriendTapped() {
      print("addFriendTapped")
      guard let newFriendId = addFriendTextField.text, !newFriendId.isEmpty else { return }
      
      Task {
         do {
            await FriendManager.shared.addFriends([newFriendId])
            print("フレンドが追加されました：\(newFriendId)")
         }
      }
   }
    
    private func updateAuthButtonState() {
        if UserSessionManager.shared.isLoggedIn {
            profileImageView.image = UIImage(systemName: "person.circle.fill")
            authButton.setTitle("ログアウト🐻", for: .normal)
            onlineStatusView.backgroundColor = UIColor(red: 0, green: 0.8, blue: 0, alpha: 1.0)
        } else {
            profileImageView.image = UIImage(systemName: "person.circle")
            authButton.setTitle("ログイン🦔", for: .normal)
            onlineStatusView.backgroundColor = .lightGray
        }
    }
    
    private func updatePinCount() {
        let pinCount = PinManager.shared.pins.count
        pinCountLabel.text = "立てたピンの総数: \(pinCount)"
    }
}

// MARK:- UITableViewDelegate & UITableViewDataSource
extension SignInView : UITableViewDelegate , UITableViewDataSource {
   func tableView(_ tableView : UITableView , numberOfRowsInSection section : Int) -> Int {
      return friendsList.count
   }

   func tableView(_ tableView : UITableView , cellForRowAt indexPath : IndexPath) -> UITableViewCell {
      let cell = tableView.dequeueReusableCell(withIdentifier : "FriendCell", for : indexPath)
      cell.textLabel?.text = friendsList[indexPath.row]
      return cell
   }
}
