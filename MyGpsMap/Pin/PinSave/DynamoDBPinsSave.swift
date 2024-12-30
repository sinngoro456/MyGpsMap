//
//  DynamoDBPinsSave.swift
//  MyGpsMap
//
//  Created by 川渕悟郎 on 2024/12/31.
//

import Foundation
import Alamofire

class DynamoDBPinsSave {
    func savePinstoDynamoDB(pins:[Data_Pin]) {
        let url = "https://wz4q6hl5oa.execute-api.ap-northeast-1.amazonaws.com/dev"
        guard let cognitoToken = PinManager.shared.cognitoToken, let userId = PinManager.shared.cognitoUserId else {
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
            "writtenDateTime": ISO8601DateFormatter().string(from: Date()),
            "command": "set",
            "pins": pinsDict
        ]
        
        // pinの"image"にはS3にアクセスするためRoleを付与したlambdaがS3 Presigned URLを発行して返す
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
}
