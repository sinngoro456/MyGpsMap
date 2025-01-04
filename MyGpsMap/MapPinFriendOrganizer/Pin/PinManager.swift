//
//  PinManager.swift
//  MyGpsMap
//
//  Created by 川渕悟郎 on 2024/12/19.
//

import CoreLocation  // Core Locationフレームワークをインポート
import MapKit

class PinManager {
    var cognitoToken: String? // 外部から読み書き可能なcognitoIdTokenプロパティ
    var writtenDateTime: Date? // 外部から読み書き可能な更新日時プロパティ
    static let shared = PinManager() // シングルトンインスタンス
    private(set) var pins: [Data_Pin] = [] // 外部からは読み取り専用
    private var dynamoDBSave = DynamoDBSave()
    private var s3Save = S3Save()
    private var localSave = LocalSave()
    
    private init() {
        let localPinSaver = LocalSave() // LocalSave のインスタンスを作成
        if let (loadedPins, writtenDateTime_Local) = localPinSaver.loadPins() { // タプルからピンの配列を取得
            pins = loadedPins // 読み込んだピンを設定
            writtenDateTime = writtenDateTime_Local
        }
        printPins()
    }
    
    // 指定されたピンをpinsに追加するメソッド
    func addPins(_ newPins: [Data_Pin]) {
        for pin in newPins {
            if pin.pin_id == 0 {
                pin.pin_id = generateUniqueId()
            }
            deletePins([pin.coordinate])
            pins.append(pin)
        }
        removeSameIdPins() // 重複IDの削除
    }
    
    // 指定されたピンをpinsに追加するメソッド
    func clearFriendPins() {
        for pin in pins {
            // ユーザーIDが一致する場合にピンを削除
            if (UserSessionManager.shared.user_id != nil && pin.user_id != UserSessionManager.shared.user_id) {
                deletePins([pin.coordinate])
            }
        }
        removeSameIdPins() // 重複IDの削除
    }
    
    // 指定された座標のピンをpinsから削除するメソッド
    func deletePins(_ coordinates: [CLLocationCoordinate2D]) {
        for coordinate in coordinates {
            // 座標が一致するピンを削除
            pins.removeAll { pin in
                let latDiff = abs(pin.coordinate.latitude - coordinate.latitude)
                let lonDiff = abs(pin.coordinate.longitude - coordinate.longitude)
                return latDiff < 0.000001 && lonDiff < 0.000001
            }
        }
        removeSameIdPins()
    }
    
    // すべてのピンを削除するメソッド
    func clearPins() {
        pins.removeAll() // pins配列を空にする
        print("All pins have been cleared.") // デバッグ用メッセージ
    }
    
    // pinsを各種DB,Localに保存するメソッド(S3(画像)をclearする)
    func saveAllPins() {
        print("saveAllPins")
        let currentDateTime = ISO8601DateFormatter().string(from: Date())
        localSave.savePinstoLocal(writtenDateTime: currentDateTime)
        s3Save.s3Clear()
        s3Save.uploadImagesForPinToS3(pins: PinManager.shared.filteredPinsForCurrentUser(from: PinManager.shared.pins))
        dynamoDBSave.savePinstoDynamoDB(pins: PinManager.shared.filteredPinsForCurrentUser(from: PinManager.shared.pins),writtenDateTime: currentDateTime)
    }
    
    func loadPins() async -> Bool {
        do {
            let (loadedPins, writtenDateTimeDB) = try await DynamoDBSave().loadPinsfromDynamoDB()
            
            // 新しいwrittenDateTimeが現在のものより新しい場合のみ更新
            if writtenDateTimeDB <= self.writtenDateTime! {
                print("ローカルのデータが最新です。")
                self.saveAllPins()
                self.printPins()
                print("ピンが更新されました。合計ピン数: \(self.pins.count)")
                return true // 更新が発生した場合はtrueを返す
            } else {
                print("データベースのデータが最新です。")
                // ローカルデータが最新の場合、ポップアップで確認
                return await withCheckedContinuation { continuation in
                    DispatchQueue.main.async {
                        // UIWindowSceneを取得
                        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                              let topViewController = windowScene.windows.first?.rootViewController else {
                            continuation.resume(returning: false)
                            return
                        }
                        
                        let alert = UIAlertController(title: "上書き確認", message: "データベースのデータが最新です。データベースのデータで上書きしますか？", preferredStyle: .alert)
                        
                        alert.addAction(UIAlertAction(title: "はい", style: .default, handler: { _ in
                            Task {
                                // データベースから新しいピンを追加する処理を書く
                                self.clearPins() // 既存のピンをクリア
                                self.addPins(loadedPins) // データベースから取得したピンで上書き
                                await self.loadPinsImages()
                                self.saveAllPins()
                                print("データベースのデータで上書きしました。")
                                continuation.resume(returning: true)
                            }
                        }))
                        
                        alert.addAction(UIAlertAction(title: "いいえ", style: .cancel, handler: { _ in
                            Task {
                                self.saveAllPins()
                                continuation.resume(returning: false)
                            }
                        }))
                        
                        topViewController.present(alert, animated: true, completion: nil)
                    }
                }
            }
        } catch {
            print("ピンのロード中にエラーが発生しました: \(error.localizedDescription)")
            return false // エラーが発生した場合もfalseを返す
        }
    }

    
    func loadFriendsPinsDynamoDB() async -> Bool {
        do {
            let loadedPins = try await DynamoDBSave().loadFriendsPinsfromDynamoDB()
            
            self.clearFriendPins()
            self.addPins(loadedPins) // 新しいピンを追加
            await self.loadPinsImages()
            print("ピンが更新されました。合計ピン数: \(self.pins.count)")
            return true // 更新が発生した場合はtrueを返す
        }catch {
            print("ピンのロード中にエラーが発生しました: \(error.localizedDescription)")
            return false // エラーが発生した場合もfalseを返す
        }
    }
}
extension PinManager {
    // pinsを各種DB,Localに保存するメソッド
    private func loadPinsImages() async {
        pins = await s3Save.downloadImagesFromS3(pins: PinManager.shared.filteredPinsForCurrentUser(from: PinManager.shared.pins))
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
    
    // ユーザーIDに基づいてフィルタリングされたピンを取得するメソッド
    func filteredPinsForCurrentUser(from pins: [Data_Pin]) -> [Data_Pin] {
        guard let userId = UserSessionManager.shared.user_id else { return pins }  // cognitoUserIdがnilの場合は空の配列を返す
        return pins.filter { $0.user_id == userId || $0.user_id == nil}  // userIdが一致するピンのみを返す
    }
    
    // 新しいユーザーIDでピンのuser_idを更新するメソッド
    func updatePinsWithNewUserId() {
        if UserSessionManager.shared.user_id != nil{
            for index in pins.indices {
                pins[index].user_id = UserSessionManager.shared.user_id // 各ピンのuser_idを更新
            }
            print("すべてのピンのuser_idが更新されました:", UserSessionManager.shared.user_id!)
        }
    }
    
    // デバッグ用
    func printPins() {
        print("---------------pin-----------------")
        for pin in pins {
            print("user_id: \(pin.user_id ?? "No user_id")")
            print("pin_id: \(pin.pin_id != 0 ? String(pin.pin_id!) : "pin_id")")
            print("Title: \(pin.title ?? "No Title")")
            print("Description: \(pin.description ?? "No Description")")
            print("Coordinate: \(pin.coordinate.latitude), \(pin.coordinate.longitude)")
            print("Category: \(pin.category ?? "No Category")")
            print("Date: \(pin.date ?? Date())")
            print("Tags: \(pin.tags?.joined(separator: ", ") ?? "No Tags")")
            print("Images Count: \(pin.images.count)")
            print("Visibility: \(pin.visibility ?? "No Visibility")\n\n")
        }
        print("----------------------------------")
    }
}
