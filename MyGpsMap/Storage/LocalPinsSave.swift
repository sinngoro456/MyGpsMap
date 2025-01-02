//
//  LocalSave.swift
//  MyGpsMap
//
//  Created by 川渕悟郎 on 2024/12/31.
//

import Foundation

import Foundation

struct PinsData: Codable {
    var pins: [Data_Pin]
    var savedAt: Date
}

class LocalPinsSave {
    // ピンのローカル保存
    func savePinstoLocal() {
        let a = PinManager.shared.pins
        let pins = PinManager.shared.filteredPinsForCurrentUser(from: PinManager.shared.pins)
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601 // 日付フォーマット設定
        do {
            let pinsData = PinsData(pins: pins, savedAt: Date())
            let data = try encoder.encode(pinsData)
            let url = getDocumentsDirectory().appendingPathComponent("pins.json")
            try data.write(to: url)
            print("ピンがローカルに保存されました:", url)
        } catch {
            print("ピンの保存エラー:", error)
        }
    }
    
    // ピンのローカル読み込み
    func loadPins() -> ([Data_Pin], Date)? {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601 // 日付フォーマット設定
        do {
            let url = getDocumentsDirectory().appendingPathComponent("pins.json")
            let data = try Data(contentsOf: url)
            let loadedData = try decoder.decode(PinsData.self, from: data) // PinsData型としてデコード
            
            print("ピンがローカルから読み込まれました:", loadedData.pins, "保存日時:", loadedData.savedAt)
            return (loadedData.pins, loadedData.savedAt) // 成功時に読み込んだピンと保存日時を返す
        } catch {
            print("ピンの読み込みエラー:", error)
            return nil // 失敗時には nil を返す
        }
    }
    
    // ドキュメントディレクトリの取得
    private func getDocumentsDirectory() -> URL {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    }
}
