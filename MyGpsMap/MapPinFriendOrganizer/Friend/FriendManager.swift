//
//  FriendManager.swift
//  MyGpsMap
//
//  Created by 川渕悟郎 on 2025/01/03.
//

import Foundation
import UIKit

class FriendManager {
    static let shared = FriendManager() // シングルトンインスタンス
    private(set) var friends: [Data_Friend] = [] // 外部からは読み取り専用
    private(set) var friendsILike: [Data_Friend] = [] // 外部からは読み取り専用
    private(set) var friendsLikeMe: [Data_Friend] = [] // 外部からは読み取り専用

    // DynamoDBから友達データを非同期に読み込むメソッド
    func loadFriendsFromDynamoDB() async {
        do {
            let friendsData = try await DynamoDBSave().loadFriendsfromDynamoDB()
            self.friends = friendsData[0]
            self.friendsILike = friendsData[1]
            self.friendsLikeMe = friendsData[2]
            print("DynamoDBから友達データを読み込みました。")
            print(self.friends)
            print(self.friendsILike)
            print(self.friendsLikeMe)
        } catch {
            print("DynamoDBからの友達データの読み込み中にエラーが発生しました: \(error.localizedDescription)")
        }
    }

    // 友達を追加するメソッド
    func addFriends(_ friendIds: [String]) async {
        do {
            let (newFriendsList, newFriendsILikeList, alreadyFriendsList, alreadyFriendsILikeList, nonExistentUsersList) = try await DynamoDBSave().addFriendsfromDynamoDB(friend_ids: friendIds)
            
            // 新しい友達と「いいね」した友達を追加
            self.friends.append(contentsOf: newFriendsList)
            self.friendsILike.append(contentsOf: newFriendsILikeList)

            // ポップアップメッセージの作成
            var message = "友達が追加されました。\n"
            
            if !alreadyFriendsList.isEmpty {
                message += "既に友達に追加されています: \(alreadyFriendsList.map { $0.user_id }.joined(separator: ", "))\n"
            }
            
            if !alreadyFriendsILikeList.isEmpty {
                message += "既に「いいね」した友達に追加されています: \(alreadyFriendsILikeList.map { $0.user_id }.joined(separator: ", "))\n"
            }
            
            if !nonExistentUsersList.isEmpty {
                // nonExistentUsersListからuser_idを抽出し、文字列として結合する
                let nonExistentUserIds = nonExistentUsersList.map { $0.user_id }
                message += "存在しないユーザーが含まれています: \(nonExistentUserIds.joined(separator: ", "))"
            }

            // ポップアップを表示
            await showAlert(title: "友達追加結果", message: message)

            print("友達が追加されました。合計数: \(friends.count)")
        } catch {
            print("友達の追加中にエラーが発生しました: \(error.localizedDescription)")
        }
    }

    // ポップアップを表示するヘルパーメソッド
    private func showAlert(title: String, message: String) async {
        await MainActor.run {
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let topController = windowScene.windows.first?.rootViewController {
                topController.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    // すべての友達をクリアするメソッド
    func clearFriends() {
        friends.removeAll() // friends配列を空にする
        print("すべての友達がクリアされました。")
    }
    
    // ユーザーIDのリストを取得するメソッド
    func getFriendUserIds(friends_input:[Data_Friend]) -> [String] {
        return friends_input.compactMap { $0.user_id } // user_idがnilでないものだけを返す
    }
    
    // 追加したメソッド：ユーザーIDのみのリストを取得するメソッド
    func getFriendUserIdList() -> [String] {
        return friends.map { $0.user_id } // user_idのリストを返す
    }
}
