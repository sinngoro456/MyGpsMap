//
//  DynamoDBSave.swift
//  MyGpsMap
//
//  Created by 川渕悟郎 on 2024/12/31.
//

import Foundation
import Alamofire
import CoreLocation

class DynamoDBSave {
    func savePinstoDynamoDB(pins:[Data_Pin], writtenDateTime: String) {
        let url = "https://wz4q6hl5oa.execute-api.ap-northeast-1.amazonaws.com/dev"
        guard let cognitoToken = UserSessionManager.shared.cognitoToken, let userId = UserSessionManager.shared.user_id else {
            print("エラー: cognitoIdTokenまたはcognitoUserIdがnilです。")
            return
        }
        let defaultHeader: HTTPHeaders = [
            "Authorization": "\(cognitoToken)",
        ]
        
        // pinsを辞書の配列に変換
        let pinsDict = pins.map { $0.toDictionary() }
        
        // パラメータを作成し、user_idとwrittenDateTimeを追加
        let parameters: [String: Any] = [
            "user_id": userId,
            "writtenDateTime": writtenDateTime,
            "command": "set",
            "pins": pinsDict
        ]
        
        // AWSのAPIをAlamofireで叩く
        AF.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: defaultHeader)
            .uploadProgress { progress in
                print("アップロード進捗: \(progress.fractionCompleted)")
            }
            .responseData { response in
                switch response.result {
                case .success(let value):
                    if let jsonResponse = try? JSONSerialization.jsonObject(with: value, options: []) as? [String: Any] {
                        print("成功: \(jsonResponse)")
                    } else {
                        print("エラー: レスポンスの解析に失敗しました")
                    }
                case .failure(let error):
                    print("エラー: \(error)")
                }
            }
    }
    
    func loadPinsfromDynamoDB() async throws -> ([Data_Pin], Date) {
        let url = "https://wz4q6hl5oa.execute-api.ap-northeast-1.amazonaws.com/dev"
        guard let cognitoToken = UserSessionManager.shared.cognitoToken, let userId = UserSessionManager.shared.user_id else {
            throw NSError(domain: "PinManager", code: 1, userInfo: [NSLocalizedDescriptionKey: "cognitoIdTokenまたはcognitoUserIdがnilです。"])
        }
        let defaultHeader: HTTPHeaders = [
            "Authorization": "\(cognitoToken)",
        ]
        
        let parameters: [String: Any] = [
            "user_id": userId,
            "command": "get"
        ]
        
        return try await withCheckedThrowingContinuation { continuation in
            AF.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: defaultHeader)
                .responseData { response in
                    switch response.result {
                    case .success(let value):
                        if let jsonResponse = try? JSONSerialization.jsonObject(with: value, options: []) as? [String: Any],
                           let bodyString = jsonResponse["body"] as? String,
                           let bodyData = bodyString.data(using: .utf8),
                           let body = try? JSONSerialization.jsonObject(with: bodyData, options: []) as? [String: Any],
                           let currentWrittenDateTimeString = body["current_writtenDateTime"] as? String,
                           let currentWrittenDateTime = ISO8601DateFormatter().date(from: currentWrittenDateTimeString),
                           let pinsData = body["pins"] as? [[String: Any]] {
                            
                            let newPins = pinsData.compactMap { pinData -> Data_Pin? in
                                guard let pinId = pinData["pin_id"] as? String,
                                      let userId = pinData["user_id"] as? String,
                                      let latitudeInt = pinData["latitude"] as? Int,
                                      let longitudeInt = pinData["longitude"] as? Int,
                                      let dateString = pinData["date"] as? String,
                                      let date = ISO8601DateFormatter().date(from: dateString) else {
                                    return nil
                                }
                                
                                let latitude = Double(latitudeInt) / 1e13
                                let longitude = Double(longitudeInt) / 1e13
                                
                                let pin = Data_Pin(coordinate: CLLocationCoordinate2D(latitude: latitude, longitude: longitude))
                                pin.pin_id = pinId
                                pin.user_id = userId
                                pin.title = pinData["title"] as? String
                                pin.description = pinData["description"] as? String
                                pin.category = pinData["category"] as? String
                                pin.date = date
                                pin.tags = pinData["tags"] as? [String] ?? []
                                pin.visibility = pinData["visibility"] as? String
                                
                                // 色情報の処理
                                if let colorString = pinData["color"] as? String,
                                   let colorData = colorString.data(using: .utf8),
                                   let colorDict = try? JSONSerialization.jsonObject(with: colorData, options: []) as? [String: CGFloat] {
                                    pin.color = UIColor(red: colorDict["red"] ?? 0,
                                                        green: colorDict["green"] ?? 0,
                                                        blue: colorDict["blue"] ?? 0,
                                                        alpha: colorDict["alpha"] ?? 1)
                                }
                                return pin  // この行を追加
                            }
                            continuation.resume(returning: (newPins, currentWrittenDateTime))
                        } else {
                            continuation.resume(throwing: NSError(domain: "PinManager", code: 2, userInfo: [NSLocalizedDescriptionKey: "ピンデータの解析に失敗しました"]))
                        }
                    case .failure(let error):
                        continuation.resume(throwing: error)
                    }
                }
        }
    }
    
    func loadFriendsPinsfromDynamoDB() async throws -> [Data_Pin] {
        let url = "https://wz4q6hl5oa.execute-api.ap-northeast-1.amazonaws.com/dev"
        guard let cognitoToken = UserSessionManager.shared.cognitoToken, let userId = UserSessionManager.shared.user_id else {
            throw NSError(domain: "PinManager", code: 1, userInfo: [NSLocalizedDescriptionKey: "cognitoIdTokenまたはcognitoUserIdがnilです。"])
        }
        let defaultHeader: HTTPHeaders = [
            "Authorization": "\(cognitoToken)",
        ]
        
        let parameters: [String: Any] = [
            "user_id": userId,
            "command": "get",
            "target_id": FriendManager.shared.getFriendUserIdList()
        ]
        print(parameters)
        return try await withCheckedThrowingContinuation { continuation in
            AF.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: defaultHeader)
                .responseData { response in
                    switch response.result {
                    case .success(let value):
                        if let jsonResponse = try? JSONSerialization.jsonObject(with: value, options: []) as? [String: Any],
                           let bodyString = jsonResponse["body"] as? String,
                           let bodyData = bodyString.data(using: .utf8),
                           let body = try? JSONSerialization.jsonObject(with: bodyData, options: []) as? [String: Any],
                           let pinsData = body["pins"] as? [[String: Any]] {
                            
                            let newPins = pinsData.compactMap { pinData -> Data_Pin? in
                                guard let pinId = pinData["pin_id"] as? String,
                                      let userId = pinData["user_id"] as? String,
                                      let latitudeInt = pinData["latitude"] as? Int,
                                      let longitudeInt = pinData["longitude"] as? Int,
                                      let dateString = pinData["date"] as? String,
                                      let date = ISO8601DateFormatter().date(from: dateString) else {
                                    return nil
                                }
                                
                                let latitude = Double(latitudeInt) / 1e13
                                let longitude = Double(longitudeInt) / 1e13
                                
                                let pin = Data_Pin(coordinate: CLLocationCoordinate2D(latitude: latitude, longitude: longitude))
                                pin.pin_id = pinId
                                pin.user_id = userId
                                pin.title = pinData["title"] as? String
                                pin.description = pinData["description"] as? String
                                pin.category = pinData["category"] as? String
                                pin.date = date
                                pin.tags = pinData["tags"] as? [String] ?? []
                                pin.visibility = pinData["visibility"] as? String
                                
                                // 色情報の処理
                                if let colorString = pinData["color"] as? String,
                                   let colorData = colorString.data(using: .utf8),
                                   let colorDict = try? JSONSerialization.jsonObject(with: colorData, options: []) as? [String: CGFloat] {
                                    pin.color = UIColor(red: colorDict["red"] ?? 0,
                                                        green: colorDict["green"] ?? 0,
                                                        blue: colorDict["blue"] ?? 0,
                                                        alpha: colorDict["alpha"] ?? 1)
                                }
                                return pin  // この行を追加
                            }
                            continuation.resume(returning: newPins)
                        } else {
                            continuation.resume(throwing: NSError(domain: "PinManager", code: 2, userInfo: [NSLocalizedDescriptionKey: "ピンデータの解析に失敗しました"]))
                        }
                    case .failure(let error):
                        continuation.resume(throwing: error)
                    }
                }
        }
    }
    
    func loadFriendsfromDynamoDB() async throws -> [[Data_Friend]] {
        let url = "https://wz4q6hl5oa.execute-api.ap-northeast-1.amazonaws.com/dev"
        guard let cognitoToken = UserSessionManager.shared.cognitoToken, let userId = UserSessionManager.shared.user_id else {
            throw NSError(domain: "PinManager", code: 1, userInfo: [NSLocalizedDescriptionKey: "cognitoIdTokenまたはcognitoUserIdがnilです。"])
        }
        
        let defaultHeader: HTTPHeaders = [
            "Authorization": "\(cognitoToken)",
        ]
        
        let parameters: [String: Any] = [
            "user_id": userId,
            "command": "get_friends"
        ]
        
        return try await withCheckedThrowingContinuation { continuation in
            AF.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: defaultHeader)
                .responseData { response in
                    switch response.result {
                    case .success(let value):
                        do {
                            guard let jsonResponse = try JSONSerialization.jsonObject(with: value, options: []) as? [String: Any],
                                  let bodyString = jsonResponse["body"] as? String,
                                  let bodyData = bodyString.data(using: .utf8),
                                  let body = try JSONSerialization.jsonObject(with: bodyData, options: []) as? [String: Any] else {
                                throw NSError(domain: "PinManager", code: 2, userInfo: [NSLocalizedDescriptionKey: "ピンデータの解析に失敗しました"])
                            }
                            
                            // 友達リストの取得とマッピング
                            let friendsList = try self.mapToFriends(body["friends"])
                            let friendsILikeList = try self.mapToFriends(body["friendsILike"])
                            let friendsLikeMeList = try self.mapToFriends(body["friendsLikeMe"])

                            continuation.resume(returning: [friendsList, friendsILikeList, friendsLikeMeList])
                            
                        } catch {
                            continuation.resume(throwing: NSError(domain: "PinManager", code: 3, userInfo: [NSLocalizedDescriptionKey: "JSON解析中にエラーが発生しました"]))
                        }
                        
                    case .failure(let error):
                        continuation.resume(throwing: error)
                    }
                }
        }
    }

    func addFriendsfromDynamoDB(friend_ids: [String], writtenDateTime: String) async throws -> ([Data_Friend], [Data_Friend], [Data_Friend], [Data_Friend], [Data_Friend]) {
        let url = "https://wz4q6hl5oa.execute-api.ap-northeast-1.amazonaws.com/dev"
        guard let cognitoToken = UserSessionManager.shared.cognitoToken, let userId = UserSessionManager.shared.user_id else {
            throw NSError(domain: "PinManager", code: 1, userInfo: [NSLocalizedDescriptionKey: "cognitoIdTokenまたはcognitoUserIdがnilです。"])
        }

        let defaultHeader: HTTPHeaders = [
            "Authorization": "\(cognitoToken)",
        ]

        let parameters: [String: Any] = [
            "user_id": userId,
            "writtenDateTime": writtenDateTime,
            "command": "add_friends",
            "target_id": friend_ids
        ]

        return try await withCheckedThrowingContinuation { continuation in
            AF.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: defaultHeader)
                .responseData { response in
                    switch response.result {
                    case .success(let value):
                        do {
                            guard let jsonResponse = try JSONSerialization.jsonObject(with: value, options: []) as? [String: Any],
                                  let bodyString = jsonResponse["body"] as? String,
                                  let bodyData = bodyString.data(using: .utf8),
                                  let body = try JSONSerialization.jsonObject(with: bodyData, options: []) as? [String: Any] else {
                                throw NSError(domain: "PinManager", code: 2, userInfo: [NSLocalizedDescriptionKey: "ピンデータの解析に失敗しました"])
                            }

                            // friendsリストを取得
                            guard let newFriendsData = body["new_friends"] as? [[String: Any]] else {
                                throw NSError(domain: "PinManager", code: 4, userInfo: [NSLocalizedDescriptionKey: "new_friendsが見つかりません"])
                            }
                            guard let newFriendsILikeData = body["new_friends_I_like"] as? [[String: Any]] else {
                                throw NSError(domain: "PinManager", code: 4, userInfo: [NSLocalizedDescriptionKey: "new_friends_I_likeが見つかりません"])
                            }
                            guard let alreadyFriendsData = body["already_friends"] as? [[String: Any]] else {
                                throw NSError(domain: "PinManager", code: 4, userInfo: [NSLocalizedDescriptionKey: "already_friendsが見つかりません"])
                            }
                            guard let alreadyFriendsILikeData = body["already_friends_I_like"] as? [[String: Any]] else {
                                throw NSError(domain: "PinManager", code: 4, userInfo: [NSLocalizedDescriptionKey: "already_friends_I_likeが見つかりません"])
                            }
                            guard let nonExistentUsers = body["non_existent_users"] as? [String] else {
                                throw NSError(domain: "PinManager", code: 4, userInfo: [NSLocalizedDescriptionKey: "usersが見つかりません"])
                            }

                            // Data_Friend型の配列を作成
                            let newFriendsList = newFriendsData.compactMap { dict -> Data_Friend? in
                                guard let userId = dict["user_id"] as? String,
                                      let name = dict["name"] as? String?,
                                      let isActive = dict["isActive"] as? Bool else { return nil }
                                return Data_Friend(user_id: userId, name: name, isActive: isActive)
                            }

                            let newFriendsILikeList = newFriendsILikeData.compactMap { dict -> Data_Friend? in
                                guard let userId = dict["user_id"] as? String,
                                      let name = dict["name"] as? String?,
                                      let isActive = dict["isActive"] as? Bool else { return nil }
                                return Data_Friend(user_id: userId, name: name, isActive: isActive)
                            }

                            let alreadyFriendsList = alreadyFriendsData.compactMap { dict -> Data_Friend? in
                                guard let userId = dict["user_id"] as? String,
                                      let name = dict["name"] as? String?,
                                      let isActive = dict["isActive"] as? Bool else { return nil }
                                return Data_Friend(user_id: userId, name: name, isActive: isActive)
                            }

                            let alreadyFriendsILikeList = alreadyFriendsILikeData.compactMap { dict -> Data_Friend? in
                                guard let userId = dict["user_id"] as? String,
                                      let name = dict["name"] as? String?,
                                      let isActive = dict["isActive"] as? Bool else { return nil }
                                return Data_Friend(user_id: userId, name: name, isActive: isActive)
                            }

                            let nonExistentUsersList = nonExistentUsers.compactMap { userId -> Data_Friend? in
                                // userIdからData_Friendを作成
                                return Data_Friend(user_id: userId, name: nil, isActive: false)
                            }
                            
                            continuation.resume(returning:
                                (newFriendsList, newFriendsILikeList, alreadyFriendsList, alreadyFriendsILikeList, nonExistentUsersList)
                            )

                        } catch {
                            continuation.resume(throwing:
                                NSError(domain: "PinManager", code: 3, userInfo:
                                    [NSLocalizedDescriptionKey:
                                        "JSON解析中にエラーが発生しました"]))
                        }

                    case .failure(let error):
                        continuation.resume(throwing:error)
                    }
                }
        }
    }



    // Data_Friend型へのマッピングを行うヘルパー関数
    private func mapToFriends(_ data: Any?) throws -> [Data_Friend] {
        // データが辞書型の配列の場合
        if let friendsData = data as? [[String: Any]] {
            return friendsData.compactMap { friendDict -> Data_Friend? in
                guard let id = friendDict["id"] as? String,
                      let name = friendDict["name"] as? String else {
                    return nil
                }
                return Data_Friend(user_id: id, name: name, isActive: false)
            }
        }
        
        // データがユーザーIDのリストの場合
        if let userIds = data as? [String] {
            return userIds.map { userId in
                Data_Friend(user_id: userId, name: "", isActive: false) // 名前は空に設定
            }
        }
        
        // どちらでもない場合はエラーをスロー
        throw NSError(domain: "PinManager", code: 4, userInfo: [NSLocalizedDescriptionKey: "友達データの形式が不正です"])
    }

}