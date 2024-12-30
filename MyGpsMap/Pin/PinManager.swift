//
//  PinManager.swift
//  MyGpsMap
//
//  Created by 川渕悟郎 on 2024/12/19.
//

import CoreLocation  // Core Locationフレームワークをインポート
import MapKit

class PinManager {
    var cognitoUserId: String? // 外部から読み書き可能なcognitoUserIdプロパティ
    var cognitoToken: String? // 外部から読み書き可能なcognitoIdTokenプロパティ
    static let shared = PinManager() // シングルトンインスタンス
    private(set) var pins: [Data_Pin] = [] // 外部からは読み取り専用
    
    private init() {
        let localPinSaver = LocalPinsSave() // LocalPinsSave のインスタンスを作成
        if let loadedPins = localPinSaver.loadPins() { // インスタンスメソッドを呼び出す
            pins = loadedPins // 読み込んだピンを設定
        }
    }
    
    // 指定されたピンをpinsに追加するメソッド
    func addPins(_ newPins: [Data_Pin]) {
        for pin in newPins {
            if pin.pin_id == 0 {
                pin.pin_id = generateUniqueId()
            }
            pins.append(pin)
        }
        removeSameIdPins() // 重複IDの削除
    }
    
    // 指定された座標のピンをpinsから削除するメソッド
    func deletePins(_ coordinate: CLLocationCoordinate2D) {
        // 座標が一致するピンを削除
        pins.removeAll { pin in
            let latDiff = abs(pin.coordinate.latitude - coordinate.latitude)
            let lonDiff = abs(pin.coordinate.longitude - coordinate.longitude)
            return latDiff < 0.000001 && lonDiff < 0.000001
        }
        removeSameIdPins()
    }
    
    // pinsを各種DB,Localに保存するメソッド
    func saveAllPins() {
        LocalPinsSave().savePinstoLocal()
        S3PinsSave().uploadImagesForPinToS3(pins: PinManager.shared.pins)
        DynamoDBPinsSave().savePinstoDynamoDB(pins: PinManager.shared.pins)
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
}
extension PinManager {
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
    
    // デバッグ用
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
