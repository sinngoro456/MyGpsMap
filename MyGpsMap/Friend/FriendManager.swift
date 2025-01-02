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

//    // DynamoDBから友達データをロードするメソッド
//    func loadFriendsDynamoDB() async -> Bool {
//        do {
//            let loadedFriends = try await dynamoDBFriendSave.loadFriendsFromDynamoDB()
//            
//            self.clearFriends() // 既存の友達をクリア
//            self.addFriends(loadedFriends) // 新しい友達を追加
//            
//            print("友達が更新されました。合計数: \(self.friends.count)")
//            return true // 更新が発生した場合はtrueを返す
//        } catch {
//            print("友達のロード中にエラーが発生しました: \(error.localizedDescription)")
//            return false // エラーが発生した場合もfalseを返す
//        }
//    }

    // すべての友達をクリアするメソッド
    func clearFriends() {
        friends.removeAll() // friends配列を空にする
        print("すべての友達がクリアされました。")
    }
}
