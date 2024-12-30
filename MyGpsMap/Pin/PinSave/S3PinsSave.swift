//
//  S3PinsSave.swift
//  MyGpsMap
//
//  Created by 川渕悟郎 on 2024/12/31.
//

import Foundation
import AWSS3

class S3PinsSave {
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
                let pinId = pin.pin_id
                // UIImage を PNG データに変換
                guard let pngData = image.pngData() else {
                    print("UIImage を PNG データに変換できませんでした (Pin ID \(String(describing: pinId)), Image Index \(index))")
                    continue
                }
                
                // S3 アップロード処理
                let key = "\(PinManager.shared.cognitoUserId ?? "None")/\(String(describing: pinId))_\(index + 1).png" // 1から始まる連番を付加
                
                transferUtility.uploadData(
                    pngData,
                    bucket: "mygpsmapdb",
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
    
    // 指定された user_id のディレクトリ内のオブジェクトを削除する関数
    func clearDirectoryForUser(userId: String) {
        let s3 = AWSS3.default()
        let bucketName = "mygpsmapdb"
        let prefix = "\(userId)/" // ユーザーIDに基づくプレフィックス
        
        let listRequest = AWSS3ListObjectsV2Request()!
        listRequest.bucket = bucketName
        listRequest.prefix = prefix
        
        s3.listObjectsV2(listRequest).continueWith { task -> Any? in
            if let error = task.error as NSError? {
                print("オブジェクトリスト取得エラー: \(error.localizedDescription)")
                return nil
            }
            
            guard let result = task.result else {
                print("結果が取得できませんでした")
                return nil
            }

            guard let objects = result.contents else {
                print("削除するオブジェクトが見つかりませんでした")
                return nil
            }

            // 削除リクエストの作成
            let deleteRequest = AWSS3DeleteObjectsRequest()!
            deleteRequest.bucket = bucketName
            
            var deleteKeys: [AWSS3ObjectIdentifier] = []
            for object in objects {
                if let key = object.key {
                    deleteKeys.append(AWSS3ObjectIdentifier(key: key))
                }
            }
            
            deleteRequest.deleteObjects = AWSS3DeleteObjectsInput(objects: deleteKeys)
            
            // オブジェクト削除処理
            s3.deleteObjects(deleteRequest).continueWith { deleteTask -> Any? in
                if let deleteError = deleteTask.error as NSError? {
                    print("オブジェクト削除エラー: \(deleteError.localizedDescription)")
                } else {
                    print("\(deleteKeys.count) 個のオブジェクトが削除されました")
                }
                return nil
            }

            return nil
        }
    }
}
