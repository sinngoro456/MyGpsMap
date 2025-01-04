//
//  UserSessionManager.swift
//  MyGpsMap
//
//  Created by 川渕悟郎 on 2025/01/03.
//

import Foundation
import Combine

class UserSessionManager {
    static let shared = UserSessionManager()
    
    @Published private(set) var isLoggedIn: Bool = false
    @Published private(set) var user_id: String?
    @Published private(set) var cognitoToken: String?
    
    private var cancellables = Set<AnyCancellable>()
    
    private init() {
        setupUserIdObserver()
    }
    
    func login(userId: String?,token: String?) async {
        isLoggedIn = true
        user_id = userId
        UserSessionManager.shared.cognitoToken = token
        await FriendManager.shared.loadFriendsFromDynamoDB()
    }
    
    func logout() {
        isLoggedIn = false
        user_id = nil
        UserSessionManager.shared.cognitoToken = nil
    }
    
    private func setupUserIdObserver() {
        $user_id
            .dropFirst() // 初期値の変更を無視
            .compactMap { $0 } // nilの値をフィルタリング
            .removeDuplicates() // 重複する値（変更がない場合）を除外
            .sink { [weak self] newUserId in
                Task { [weak self] in
                    guard let self = self else { return }
                    await self.userIdChanged(newUserId)
                }
            }
            .store(in: &cancellables)
    }
    
    private func userIdChanged(_ newUserId: String?) async {
        PinManager.shared.updatePinsWithNewUserId()
        _ = await PinManager.shared.loadPins()
    }
}

