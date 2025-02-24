//
//  S3Save.swift
//  MyGpsMap
//
//  Created by 川渕悟郎 on 2024/12/31.
//

import Foundation
import AWSS3

class S3Save {
    let bucket = "mygpsmapdb"
    
    // 指定された pin_id のリストの画像を S3 にアップロードする関数
    func saveImagesForPinToS3(pins: [Data_Pin]) {
        let transferUtility = AWSS3TransferUtility.default()
        let expression = AWSS3TransferUtilityUploadExpression()
        expression.progressBlock = { (task, progress) in
            DispatchQueue.main.async {
                // UIの更新やプログレスの表示など
//                print("アップロード進捗: \(progress.fractionCompleted)")
            }
        }
        
        for pin in pins {
            // 各画像をループ処理してアップロード
            for (index, image) in pin.images.enumerated() {
                
                if let pinId = pin.pin_id {
                    let key = "\(UserSessionManager.shared.user_id ?? "None")/\(pinId)_\(index + 1).png" // ここでunwrappedPinIdを使用
                    // UIImage を PNG データに変換
                    guard let pngData = image.pngData() else {
                        print("UIImage を PNG データに変換できませんでした (Pin ID \(String(describing: pinId)), Image Index \(index))")
                        continue
                    }
                    
                    // S3 アップロード処理
                    transferUtility.uploadData(
                        pngData,
                        bucket: bucket,
                        key: key,
                        contentType: "image/png",
                        expression: expression // PNG形式なのでcontentTypeはimage/png
                    ) { task, error in
                        if let error = error as! NSError? {
                            print("アップロードエラー (Pin ID \(String(describing: pinId)), Image Index \(index + 1)): \(error.localizedDescription)")
                            
                            // 詳細なエラー情報を出力
                            print("Error UserInfo:")
                            for (key, value) in error.userInfo {
                                print("  \(key): \(value)")
                            }
                            return
                        }
                        print("アップロード成功 (Pin ID \(String(describing: pinId)), Image Index \(index + 1))")
                    }.continueWith { task -> Any? in
                        if let error = task.error as NSError? {
                            print("タスクエラー (Pin ID \(String(describing: pinId)), Image Index \(index + 1)): \(error.localizedDescription)")
                            
                            // 詳細なエラー情報を出力
                            print("Error UserInfo:")
                            for (key, value) in error.userInfo {
                                print("  \(key): \(value)")
                            }
                        } else {
                            print("タスク完了 (Pin ID \(String(describing: pinId)), Image Index \(index + 1))")
                        }
                        return nil // クロージャから nil を返す
                    }
                }
            }
        }
    }

    func s3Clear() {
        print("Clear S3 Image")
        listS3Items(user_id: UserSessionManager.shared.user_id) { result in
            if let listKey = result["list_key"] {
                print("取得したキー:", listKey)

                // 各キーに対して削除処理を行う
                for key in listKey {
                    self.deleteObject(key: key)
                }
            } else {
                print("キーの取得に失敗しました。")
            }
        }
    }
    
//    func s3UnnecessaryClear(donotClearPins: [Data_Pin]) {
//        print("Clear unnecessary S3 Images")
//        guard let userId = UserSessionManager.shared.user_id else {
//            print("ユーザーIDが取得できません")
//            return
//        }
//
//        listS3Items(user_id: userId) { result in
//            if let listKey = result["list_key"] {
//                print("取得したキー:", listKey)
//
//                // 管理されているpin_idのリストを作成
//                let managedPinIds = Set(donotClearPins.compactMap { $0.pin_id }.map { String($0) })
//
//                // S3のキーをフィルタリング
//                let unnecessaryKeys = listKey.filter { key in
//                    let components = key.components(separatedBy: "/")
//                    guard components.count >= 2 else { return false }
//                    let pinIdString = components[1].split(separator: "_").first.map(String.init) ?? ""
//                    return !managedPinIds.contains(pinIdString)
//                }
//
//                // 不要なキーを削除
//                for key in unnecessaryKeys {
//                    self.deleteObject(key: key)
//                }
//            } else {
//                print("キーの取得に失敗しました。")
//            }
//        }
//    }
}
extension S3Save{
    private func deleteObject(key: String) {
        let s3 = AWSS3.default()
        let deleteObjectRequest = AWSS3DeleteObjectRequest()!
        
        deleteObjectRequest.bucket = bucket
        deleteObjectRequest.key = key
        
        s3.deleteObject(deleteObjectRequest).continueWith { task -> AnyObject? in
            if let error = task.error {
                print("削除エラー: \(error.localizedDescription)")
            } else {
                print("削除成功: \(key)")
            }
            return nil // nilを明示的に返す
        }
    }
    
    func loadPinImagesFromS3(user_ids: [String], pins: [Data_Pin]) async -> [Data_Pin] {
        // keysを並べ替える関数
        func sortKeysForPins(s3Keys: [String], pins: [Data_Pin]) -> [[String]] {
            var sortedKeys: [[String]] = Array(repeating: [], count: pins.count)
            
            for key in s3Keys {
                if let userId = key.split(separator: "/").first,
                   let pinIdStr = key.split(separator: "/").dropFirst().first?.split(separator: "_").first,
                   let pinId = Int(pinIdStr),
                   let index = pins.firstIndex(where: { $0.user_id == String(userId) && $0.pin_id == String(pinId) }) {
                    sortedKeys[index].append(key)
                }
            }
            
            return sortedKeys
        }
        
        let transferUtility = AWSS3TransferUtility.default()
        let updatedPins = pins // updatedPinsの初期化

        // 非同期forループでユーザーIDを処理
        for userId in user_ids {
            print("Fetching S3 items for user ID: \(userId)")

            // 非同期でS3アイテムリストを取得
            let s3Items = await listS3ItemsAsync(user_id: userId)

            // keysを並べ替え
            let sortedKeys = sortKeysForPins(s3Keys: s3Items["list_key"] as? [String] ?? [], pins: pins)

            // pin_idのループ
            for (index, _) in pins.enumerated() {
                print("Processing pin with ID: \(String(describing: pins[index].pin_id))")

                let keys = sortedKeys[index]
                if !keys.isEmpty {
                    print("Found \(keys.count) keys for user ID: \(userId) and pin ID: \(String(describing: pins[index].pin_id))")

                    for key in keys {
                        print("Starting download for key: \(key)")

                        // 非同期で画像をダウンロード
                        if let data = await downloadImageDataAsync(transferUtility: transferUtility, key: key),
                           let image = UIImage(data: data) {
                            updatedPins[index].images.append(image)
                            print("Successfully downloaded image for key: \(key)")
                        } else {
                            print("Failed to download or convert image for key: \(key)")
                        }
                    }
                } else {
                    print("No matching keys found for user ID: \(userId) and pin ID: \(String(describing: pins[index].pin_id))")
                }
            }
        }

        return updatedPins
    }

    // 非同期関数でS3アイテムリストを取得
    func listS3ItemsAsync(user_id: String) async -> [String: Any] {
        await withCheckedContinuation { continuation in
            listS3Items(user_id: user_id) { result in
                continuation.resume(returning: result)
            }
        }
    }

    // 非同期関数で画像データをダウンロード
    func downloadImageDataAsync(transferUtility: AWSS3TransferUtility, key: String) async -> Data? {
        await withCheckedContinuation { continuation in
            transferUtility.downloadData(fromBucket: self.bucket, key: key, expression: nil) { _, _, data, error in
                if let error = error {
                    print("ダウンロードエラー (key: \(key)): \(error.localizedDescription)")
                    continuation.resume(returning: nil)
                } else {
                    continuation.resume(returning: data)
                }
            }
        }
    }


    
    func listS3Items(user_id: String?, completion: @escaping ([String: [String]]) -> Void) {
        var result: [String: [String]] = [:]

        // user_idがnilまたは空の場合のエラーハンドリング
        guard let userId = user_id, !userId.isEmpty else {
            print("エラー: user_idがnilまたは空です。")
            completion(result) // 空の辞書を返す
            return
        }

        let s3 = AWSS3.default()
        let request = AWSS3ListObjectsV2Request()
        request?.bucket = bucket
        request?.prefix = "\(userId)/" // pin_idが指定されていない場合

        s3.listObjectsV2(request!) { (response, error) in
            if let error = error {
                print("エラー: \(error.localizedDescription)")
                completion(result) // エラー時も空の辞書を返す
                return
            }
            guard let contents = response?.contents, !contents.isEmpty else {
                print("オブジェクトが見つかりませんでした。")
                completion(result) // 空の辞書を返す
                return
            }

            // キーを収集して辞書に追加
            let keys = contents.compactMap { $0.key }
            result["list_key"] = keys
            
            // 結果をクロージャで返す
            completion(result)
        }
    }
}
