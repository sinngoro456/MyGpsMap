//
//  PinManager.swift
//  MyGpsMap
//
//  Created by 川渕悟郎 on 2024/12/19.
//

import CoreLocation  // Core Locationフレームワークをインポート
import MapKit
import Alamofire
import AWSS3

class PinManager {
    var cognitoUserId: String? // 外部から読み書き可能なcognitoUserIdプロパティ
    var cognitoToken: String? // 外部から読み書き可能なcognitoIdTokenプロパティ
    static let shared = PinManager() // シングルトンインスタンス
    private(set) var pins: [Data_Pin] = [] // 外部からは読み取り専用
    
    private init() {
        loadPins() // 初期化時にピンをロード
    }
    
    func addPin(_ pin: Data_Pin) {
        if pin.pin_id == 0{
            pin.pin_id = generateUniqueId()
        }
        pins.append(pin)
        removeSameIdPins()
    }
    
    // 指定された座標のピンを削除するメソッド
    func removePinsAtCoordinate(_ coordinate: CLLocationCoordinate2D) {
        // 座標が一致するピンを削除
        pins.removeAll { pin in
            let latDiff = abs(pin.coordinate.latitude - coordinate.latitude)
            let lonDiff = abs(pin.coordinate.longitude - coordinate.longitude)
            return latDiff < 0.000001 && lonDiff < 0.000001
        }
        removeSameIdPins()
    }
    
    // ユニークなIDを生成する関数
    private func generateUniqueId() -> Int {
        var availableIds: [Int]  // 利用可能なIDの配列
        var currentIndex: Int = 0
        availableIds = Array(1...Constants_Main.Nmax_pin)
        availableIds.shuffle()  // 配列をシャッフルしてランダム性を持たせる
        while currentIndex < availableIds.count {
            let newId = availableIds[currentIndex]  // 現在のインデックスからIDを取得
            currentIndex += 1  // インデックスを進める
            
            // pins内に同じIDが存在しないか確認
            if !pins.contains(where: { $0.pin_id == newId }) {
                return newId  // ユニークなIDが見つかった場合、返す
            }
        }
        return 0
    }
    
    // アノテーションとピンデータを比較する関数
    func findMatchingPin(for annotation: MKAnnotation) -> Data_Pin? {
        let tolerance = 0.000004  // 許容誤差 0.000004
        
        for pin in pins {
            let Difference = abs(pin.coordinate.latitude - annotation.coordinate.latitude)+abs(pin.coordinate.longitude - annotation.coordinate.longitude)
            
            // 緯度・経度の差が許容誤差内であり、タイトルが一致する場合
            if Difference < tolerance,
               pin.title == annotation.title {
                return pin  // 一致したpinDataを返す
            }
        }
        
        return nil  // 一致するpinDataがない場合はnilを返す
    }
    
    // pinsから重複するIDを持つピンを削除するメソッド
    func removeSameIdPins() {
        var seenIds: Set<Int> = [] // 見たIDの集合
        var uniquePins: [Data_Pin] = [] // 重複を除いたピンの配列
        
        // pins配列を逆順でループ（最後尾から先頭へ）
        for pin in pins.reversed() {
            if !seenIds.contains(pin.pin_id!) {
                seenIds.insert(pin.pin_id!) // IDを集合に追加
                uniquePins.append(pin) // ユニークなピンを追加
            }
        }
        // uniquePinsは逆順で追加されているので、元の順序に戻す
        pins = uniquePins.reversed()
    }
    
    // マップ上のannotationと対応しない余計なpinをpinsから削除
    func removeRedundantPins(from annotations: [MKAnnotation]) {
        let tolerance = 0.000004  // 許容誤差 0.000004
        
        // アノテーションの座標とタイトルが一致するピンを保持するセット
        var matchingPins: Set<String> = []
        
        for annotation in annotations {
            for pin in pins {
                let latitudeDifference = abs(pin.coordinate.latitude - annotation.coordinate.latitude)
                let longitudeDifference = abs(pin.coordinate.longitude - annotation.coordinate.longitude)
                let totalDifference = latitudeDifference + longitudeDifference
                
                // 緯度・経度の差が許容誤差内であり、タイトルが一致する場合
                if totalDifference < tolerance, pin.title == annotation.title {
                    let key = "\(pin.coordinate.latitude),\(pin.coordinate.longitude),\(pin.title ?? "")"
                    matchingPins.insert(key)  // 一意なキーをセットに追加
                }
            }
        }
        
        // pins配列から一致しないピンを削除
        pins.removeAll { pin in
            let pinKey = "\(pin.coordinate.latitude),\(pin.coordinate.longitude),\(pin.title ?? "")"
            return !matchingPins.contains(pinKey)  // 一致しない場合は削除
        }
    }
    
    // ピンのローカル保存
    func savePinstoLocal() {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601 // 日付フォーマット設定
        do {
            let data = try encoder.encode(pins)
            let url = getDocumentsDirectory().appendingPathComponent("pins.json")
            try data.write(to: url)
            print("ピンがローカルに保存されました:", url)
        } catch {
            print("ピンの保存エラー:", error)
        }
    }
    
    // ピンのローカル読み込み
    private func loadPins() {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601 // 日付フォーマット設定
        do {
            let url = getDocumentsDirectory().appendingPathComponent("pins.json")
            let data = try Data(contentsOf: url)
            pins = try decoder.decode([Data_Pin].self, from: data)
            print("ピンがローカルから読み込まれました:", pins)
        } catch {
            print("ピンの読み込みエラー:", error)
        }
    }
    
    // ドキュメントディレクトリの取得
    private func getDocumentsDirectory() -> URL {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    }
    
    func savePinstoDB() {
        let url = "https://wz4q6hl5oa.execute-api.ap-northeast-1.amazonaws.com/dev"
        guard let cognitoToken = cognitoToken, let userId = cognitoUserId else {
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
                        self.uploadImagesToS3(pins: self.pins, response: jsonResponse)
                    } else {
                        print("エラー: レスポンスの解析に失敗しました")
                    }
                case .failure(let error):
                    print("エラー: \(error)")
                }
            }
    }
    
    private func uploadImagesToS3(pins: [Data_Pin], response: [String: Any]) {
        print("start")
        
        // response から pin_id を抽出
        guard let updatedPins = extractPinIdsFromResponse(response) else {
            print("レスポンスの解析に失敗しました")
            return
        }
        
        // 各 pin_id に対して画像をアップロード
        let pinIds = updatedPins.compactMap { $0["pin_id"] as? Int } // pin_id のリストを作成
        uploadImagesForPinToS3(pins: pins, pinIds: pinIds)
        
        print("終了")
    }

    // response から pin_id を抽出する関数
    private func extractPinIdsFromResponse(_ response: [String: Any]) -> [[String: Any]]? {
        guard let body = response["body"] as? String,
              let jsonData = body.data(using: .utf8),
              let jsonBody = try? JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any],
              let updatedPins = jsonBody["updated_pins"] as? [[String: Any]] else {
            return nil
        }
        return updatedPins
    }

    // 指定された pin_id のリストの画像を S3 にアップロードする関数
    private func uploadImagesForPinToS3(pins: [Data_Pin], pinIds: [Int]) {
        let transferUtility = AWSS3TransferUtility.default()
        
        for pinId in pinIds {
            // pin_id に一致するピンを検索
            guard let pin = pins.first(where: { $0.pin_id == pinId }) else {
                print("指定された pin_id (\(pinId)) に一致するピンが見つかりません")
                continue
            }
            
            // 各画像をループ処理してアップロード
            for (index, image) in pin.images.enumerated() {
                // UIImage を PNG データに変換
                guard let pngData = image.pngData() else {
                    print("UIImage を PNG データに変換できませんでした (Pin ID \(pinId), Image Index \(index))")
                    continue
                }
                
                // S3 アップロード処理
                let key = "\(cognitoUserId ?? "None")/\(pinId)_\(index + 1).png" // 1から始まる連番を付加
                
                transferUtility.uploadData(
                    pngData,
                    bucket: "mygpsmapdb",
                    key: key,
                    contentType: "image/png", // PNG形式なのでcontentTypeはimage/png
                    expression: nil
                ) { task, error in
                    if let error = error as NSError? {
                        print("アップロードエラー (Pin ID \(pinId), Image Index \(index + 1)): \(error.localizedDescription)")
                        
                        // 詳細なエラー情報を出力
                        print("Error UserInfo:")
                        for (key, value) in error.userInfo {
                            print("  \(key): \(value)")
                        }
                        return
                    }
                    
                    print("アップロード成功 (Pin ID \(pinId), Image Index \(index + 1))")
                }.continueWith { task in
                    if let error = task.error as NSError? {
                        print("タスクエラー (Pin ID \(pinId), Image Index \(index + 1)): \(error.localizedDescription)")
                        
                        // 詳細なエラー情報を出力
                        print("Error UserInfo:")
                        for (key, value) in error.userInfo {
                            print("  \(key): \(value)")
                        }
                    } else {
                        print("タスク完了 (Pin ID \(pinId), Image Index \(index + 1))")
                    }
                    return nil
                }
            }
        }
    }



    //    デバッグ用
    func printPins() {
        print("---------------pin-----------------")
        for pin in pins {
            
            print("Id: \(pin.pin_id != nil ? String(pin.pin_id!) : "No Id")")
            print("Title: \(pin.title ?? "No Title")")
            print("Description: \(pin.description ?? "No Description")")
            print("Coordinate: \(pin.coordinate.latitude), \(pin.coordinate.longitude)")
            print("Category: \(pin.category ?? "No Category")")
            print("Date: \(pin.date ?? Date())")
            print("Tags: \(pin.tags?.joined(separator: ", ") ?? "No Tags")")
            print("Images Count: \(pin.images.count)\n\n")
        }
        print("----------------------------------")
    }
}
