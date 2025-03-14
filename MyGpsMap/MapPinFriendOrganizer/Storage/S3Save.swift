//
//  S3Save.swift
//  MyGpsMap
//
//  Created by 川渕悟郎 on 2024/12/31.
//

//{
//	"Version": "2012-10-17",
//	"Statement": [
//		{
//			"Sid": "AllowListBucket",
//			"Effect": "Allow",
//			"Principal": {
//				"AWS": [
//					"arn:aws:iam::975050242324:role/amplify-mygpsmap-dev-e361e-authRole",
//					"arn:aws:iam::975050242324:role/amplify-mygpsmap-dev-e361e-unauthRole"
//				]
//			},
//			"Action": "s3:ListBucket",
//			"Resource": "arn:aws:s3:::mygpsmapdb",
//			"Condition": {
//				"StringLike": {
//					"s3:prefix": "*"
//				}
//			}
//		},
//		{
//			"Sid": "AllowUserSpecificActions",
//			"Effect": "Allow",
//			"Principal": {
//				"AWS": [
//					"arn:aws:iam::975050242324:role/amplify-mygpsmap-dev-e361e-authRole",
//					"arn:aws:iam::975050242324:role/amplify-mygpsmap-dev-e361e-unauthRole"
//				]
//			},
//			"Action": [
//				"s3:PutObject",
//				"s3:GetObject",
//				"s3:DeleteObject"
//			],
//			"Resource": "arn:aws:s3:::mygpsmapdb/*"
//		}
//	]
//}

import Foundation
import AWSS3
import UIKit

class S3Save {
    static let shared = S3Save() // シングルトンインスタンス
    var presigned_url: String?

    let bucket = "mygpsmapdb"
    // 指定された pin_id のリストの画像を S3 にアップロードする関数
    func saveImagesForPinToS3(pins: [Data_Pin]) {
        guard let identityId = UserSessionManager.shared.identity_id else {
            return // identity_id が nil の場合、関数を終了
        }
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
                    // let key = "\(UserSessionManager.shared.user_id ?? "None")/\(pinId)_\(index + 1).png" // ここでunwrappedPinIdを使用
                    let key = "\(UserSessionManager.shared.identity_id ?? "None")/\(pinId)_\(index + 1).png"
                    print(key)
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
                            print("key")
                            print(key)
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
        guard let identityId = UserSessionManager.shared.identity_id else {
            return // identity_id が nil の場合、関数を終了
        }
        print("Clear S3 Image")
        listS3Items(user_id: UserSessionManager.shared.identity_id) { result in
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
}
extension S3Save{
    private func deleteObject(key: String) {
        guard let identityId = UserSessionManager.shared.identity_id else {
            return // identity_id が nil の場合、関数を終了
        }
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
        var updatedPins = pins
        
        for userId in user_ids {
            // S3アイテムリストを非同期で取得
            let s3Items = await listS3ItemsAsync(user_id: userId)
            let keys = s3Items["list_key"] as? [String] ?? []
            
            for (index, pin) in updatedPins.enumerated() {
                // プリサインURLが存在する場合
                if let presignedURL = pin.images_presigned_url, presignedURL.hasPrefix("http") {
                    if let data = await downloadImageFromPresignedURL(presignedURL: presignedURL), 
                    let image = UIImage(data: data) {
                        updatedPins[index].images.append(image)
                    }
                } 
                // プリサインURLが存在しない場合、S3から画像を取得
                else {
                    for key in keys {
                        if key.contains("\(userId)/\(pin.pin_id ?? "")") {
                            if let data = await downloadImageDataAsync(transferUtility: AWSS3TransferUtility.default(), key: key), 
                            let image = UIImage(data: data) {
                                updatedPins[index].images.append(image)
                            }
                        }
                    }
                }
            }
        }
        
        return updatedPins
    }

    func downloadImageFromPresignedURL(presignedURL: String) async -> Data? {
        await withCheckedContinuation { continuation in
            guard let url = URL(string: presignedURL) else {
                print("Error: Invalid URL")
                continuation.resume(returning: nil)
                return
            }
            
            URLSession.shared.dataTask(with: url) { data, response, error in
                if let error = error {
                    print("Error: Network request failed - \(error.localizedDescription)")
                    continuation.resume(returning: nil)
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    print("Error: Invalid response")
                    continuation.resume(returning: nil)
                    return
                }
                
                if httpResponse.statusCode == 200 {
                    continuation.resume(returning: data)
                } else {
                    print("Error: Invalid status code - \(httpResponse.statusCode)")
                    continuation.resume(returning: nil)
                }
            }.resume()
        }
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

    // S3バケット内のオブジェクトのキーをリストする関数
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
        print("\(userId)/")

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
