//
//  LocationManager.swift
//  MyGpsMap
//
//  Created by 川渕悟郎 on 2025/02/25.
//

import CoreLocation
import Combine

import CoreLocation
import Combine

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    static let shared = LocationManager() // シングルトンインスタンス
    
    private let locationManager = CLLocationManager()
    
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined
    @Published var currentCoordinate: CLLocationCoordinate2D?
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest // 最高精度で位置情報を取得
    }
    
    // 位置情報の許可をリクエスト
    func requestLocationPermission() {
        locationManager.requestWhenInUseAuthorization() // アプリ使用中の許可をリクエスト
        // locationManager.requestAlwaysAuthorization() // 常に許可をリクエスト
    }
    
    // 位置情報の更新を開始
    func startUpdatingLocation() {
        locationManager.startUpdatingLocation()
    }
    
    // 許可状態が変更されたときに呼ばれる
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationStatus = manager.authorizationStatus
        
        // 許可が与えられた場合、位置情報の更新を開始
        if authorizationStatus == .authorizedWhenInUse || authorizationStatus == .authorizedAlways {
            startUpdatingLocation()
        }
    }
    
    // 位置情報が更新されたときに呼ばれる
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        currentCoordinate = location.coordinate
    }
    
    // 位置情報の取得に失敗したときに呼ばれる
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("位置情報の取得に失敗しました: \(error.localizedDescription)")
    }
}
