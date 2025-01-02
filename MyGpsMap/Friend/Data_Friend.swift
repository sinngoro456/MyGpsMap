//
//  Friend_Data.swift
//  MyGpsMap
//
//  Created by 川渕悟郎 on 2025/01/03.
//

import Foundation

// Friendデータモデル
struct Friend {
    var user_id: String?
    var name: String?
    var isActive: Bool // オンラインまたはオフライン状態
    
    init(user_id: String?, name: String?, isActive: Bool) {
        self.user_id = user_id
        self.name = name
        self.isActive = isActive
    }
}
