//
//  LocalSave.swift
//  MyGpsMap
//
//  Created by 川渕悟郎 on 2024/12/31.
//

import Foundation

class LocalPinsSave {
    // ピンのローカル保存
    func savePinstoLocal() {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601 // 日付フォーマット設定
        do {
            let data = try encoder.encode(PinManager.shared.pins)
            let url = getDocumentsDirectory().appendingPathComponent("pins.json")
            try data.write(to: url)
            print("ピンがローカルに保存されました:", url)
        } catch {
            print("ピンの保存エラー:", error)
        }
    }
    
    // ピンのローカル読み込み
    func loadPins() -> [Data_Pin]? { // 戻り値の型を [Data_Pin]? に変更
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601 // 日付フォーマット設定
        do {
            let url = getDocumentsDirectory().appendingPathComponent("pins.json")
            let data = try Data(contentsOf: url)
            let loadedPins = try decoder.decode([Data_Pin].self, from: data)
            print("ピンがローカルから読み込まれました:", loadedPins)
            return loadedPins // 成功時に読み込んだピンを返す
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
