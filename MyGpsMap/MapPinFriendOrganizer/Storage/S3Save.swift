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
    func uploadImagesForPinToS3(pins: [Data_Pin]) {
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
                        if let error = error as NSError? {
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
    
    func listS3Items(user_id: String?, pin_id: Int, completion: @escaping ([String: [String]]) -> Void) {
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
        
        // pin_idが0の場合、プレフィックスにはuserIdのみを設定
        if pin_id != 0 {
            request?.prefix = "\(userId)/\(pin_id)" // pin_idが指定されている場合
        } else {
            request?.prefix = "\(userId)/" // pin_idが指定されていない場合
        }

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

    func s3Clear() {
        print("Clear S3 Image")
        listS3Items(user_id: UserSessionManager.shared.user_id, pin_id: 0) { result in
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
    
    func s3UnnecessaryClear() {
        print("Clear unnecessary S3 Images")
        guard let userId = UserSessionManager.shared.user_id else {
            print("ユーザーIDが取得できません")
            return
        }

        listS3Items(user_id: userId, pin_id: 0) { result in
            if let listKey = result["list_key"] {
                print("取得したキー:", listKey)

                // PinManagerで管理されているpin_idのリストを作成
                let managedPinIds = Set(PinManager.shared.pins.compactMap { $0.pin_id }.map { String($0) })

                // S3のキーをフィルタリング
                let unnecessaryKeys = listKey.filter { key in
                    let components = key.components(separatedBy: "/")
                    guard components.count >= 2 else { return false }
                    let pinIdString = components[1].split(separator: "_").first.map(String.init) ?? ""
                    return !managedPinIds.contains(pinIdString)
                }

                // 不要なキーを削除
                for key in unnecessaryKeys {
                    self.deleteObject(key: key)
                }
            } else {
                print("キーの取得に失敗しました。")
            }
        }
    }

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
    
    func downloadImagesFromS3(pins: [Data_Pin]) async -> [Data_Pin] {
        let transferUtility = AWSS3TransferUtility.default()
        let updatedPins = pins

        for (index, pin) in pins.enumerated() {
            guard let pinId = pin.pin_id, let userId = UserSessionManager.shared.user_id else {
                continue
            }

            var downloadedImages: [UIImage] = []
            let semaphore = DispatchSemaphore(value: 0)

            listS3Items(user_id: userId, pin_id: pinId) { result in
                if let keys = result["list_key"] {
                    let dispatchGroup = DispatchGroup()

                    for key in keys {
                        dispatchGroup.enter()
                        transferUtility.downloadData(
                            fromBucket: self.bucket,
                            key: key,
                            expression: nil
                        ) { task, url, data, error in
                            defer { dispatchGroup.leave() }
                            if let error = error {
                                print("ダウンロードエラー: \(error.localizedDescription)")
                            } else if let data = data, let image = UIImage(data: data) {
                                downloadedImages.append(image)
                            }
                        }
                    }

                    dispatchGroup.notify(queue: .main) {
                        updatedPins[index].images = downloadedImages
                        semaphore.signal()
                    }
                } else {
                    semaphore.signal()
                }
            }
        }
        return updatedPins
    }
}
