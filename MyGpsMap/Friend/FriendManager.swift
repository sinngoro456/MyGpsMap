import Foundation

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

            // 非同期関数をawaitで呼び出す
            let tempPins = PinManager.shared.pins // 現在のピンを保持
            let isUpdate = await PinManager.shared.loadFriendsPinsDynamoDB() // ピンの更新を待機

            if isUpdate {
                // 新しいピンを計算
                let newPins = PinManager.shared.pins.filter { pin in
                    !tempPins.contains { $0.pin_id == pin.pin_id } // pin_idで比較
                }
                
                PinManager.shared.addPins(newPins) // 新しいピンを追加
                MapManager.shared.addPins(with: newPins) // マップに新しいピンを追加
            }
            
            print(self.friends)
            print(self.friendsILike)
            print(self.friendsLikeMe)
        } catch {
            print("DynamoDBからの友達データの読み込み中にエラーが発生しました: \(error.localizedDescription)")
        }
    }

    // 友達を追加するメソッド
    func addFriends(_ newFriends: [Data_Friend]) {
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

    // ユーザーIDのリストを取得するメソッド
    func getFriendUserIds() -> [String] {
        return friends.compactMap { $0.user_id } // user_idがnilでないものだけを返す
    }
    
    // 追加したメソッド：ユーザーIDのみのリストを取得するメソッド
    func getFriendUserIdList() -> [String] {
        return friends.map { $0.user_id } // user_idのリストを返す
    }
}
