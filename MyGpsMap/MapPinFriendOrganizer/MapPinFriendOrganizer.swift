//
//  MapPinFriendOrganizer.swift
//  MyGpsMap
//
//  Created by 川渕悟郎 on 2025/01/05.
//

import Foundation
import CoreLocation  // Core Locationフレームワークをインポート
import MapKit

class MapPinFriendOrganizer{
    static let shared = MapPinFriendOrganizer() // シングルトンインスタンス

    private init() {
    }
    
    func Refresh1() {
        // 定期的に実行したい処理1をここに記述します。
        Task {
            await FriendManager.shared.loadFriendsFromDynamoDB()
            _ = await PinManager.shared.loadFriendsPinsDynamoDB() // ピンの更新を待機
        }
    }

    func Refresh2() {
        if PinManager.shared.pins != MapManager.shared.pins_display{
            print("pins_displayが一致しません")
            MapManager.shared.clearPins()
            MapManager.shared.addPins(with: PinManager.shared.pins) // マップに新しいピンを追加
            let bool = (PinManager.shared.pins == MapManager.shared.pins_display)
            print(bool)
        }
    }
}
