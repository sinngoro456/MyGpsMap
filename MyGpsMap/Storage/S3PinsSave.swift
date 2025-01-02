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
                print("アップロード進捗: \(progress.fractionCompleted)")
            }
        }
        
        for pin in pins {
            // 各画像をループ処理してアップロード
            for (index, image) in pin.images.enumerated() {
                
                if let pinId = pin.pin_id {
                    let key = "\(PinManager.shared.cognitoUserId ?? "None")/\(pinId)_\(index + 1).png" // ここでunwrappedPinIdを使用
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
            request?.prefix = "\(userId)/\(pin_id)/" // pin_idが指定されている場合
        } else {
            request?.prefix = "\(userId)/" // pin_idが指定されていない場合
        }

        s3.listObjectsV2(request!) { (response, error) in
            if let error = error {
                print("エラー: \(error.localizedDescription)")
                completion(result) // エラー時も空の辞書を返す
                return
            }
            print("hi1")
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
            print("hi2")
        }
    }

    func S3Clear() {
        print("Clear S3 Image")
        listS3Items(user_id: PinManager.shared.cognitoUserId, pin_id: 0) { result in
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
}
