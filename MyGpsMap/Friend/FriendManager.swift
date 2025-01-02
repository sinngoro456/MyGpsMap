//
//  FriendManager.swift
//  MyGpsMap
//
//  Created by 川渕悟郎 on 2025/01/03.
//

import Foundation

class FriendManager {
    static let shared = FriendManager() // シングルトンインスタンス
    private(set) var friends: [Friend] = [] // 外部からは読み取り専用

    private init() {
        loadFriendsFromLocal() // ローカルから友達データを読み込む
    }

    // ローカルから友達データを読み込むメソッド
    private func loadFriendsFromLocal() {
        // ここでローカルデータを読み込み、friends配列に設定する処理を書く
        print("ローカルから友達データを読み込みました。")
    }

    // 友達を追加するメソッド
    func addFriends(_ newFriends: [Friend]) {
        for friend in newFriends {
            if !friends.contains(where: { $0.user_id == friend.user_id }) {
                friends.append(friend)
            }
        }
        print("友達が追加されました。合計数: \(friends.count)")
    }

    // すべての友達をクリアするメソッド
    func clearFriends() {
        friends.removeAll() // friends配列を空にする
        print("すべての友達がクリアされました。")
    }
}
