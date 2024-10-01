//
//  ViewController.swift
//  MyGpsMap
//
//  Created by 川渕悟郎 on 2024/10/01.
//

import UIKit
import CoreLocation
import MapKit

class ViewController: UIViewController, CLLocationManagerDelegate {
    @IBOutlet var mapView: MKMapView!
    var locationManager: CLLocationManager!
    var isInitialLocationSet = false  // 初回位置設定のフラグ

    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager = CLLocationManager()  // 変数を初期化
        locationManager.delegate = self  // delegateとしてself(自インスタンス)を設定

        locationManager.requestWhenInUseAuthorization()  // 位置情報取得の許可を得る
        locationManager.startUpdatingLocation()  // 位置情報更新を指示
        locationManager.startUpdatingHeading()  // 方位情報の更新を指示
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let lastLocation = locations.last else { return }  // 最新の位置情報を取得

        let longitude = lastLocation.coordinate.longitude // Double型で取得
        let latitude = lastLocation.coordinate.latitude // Double型で取得
        
        print("[DBG]longitude : \(longitude)")
        print("[DBG]latitude : \(latitude)")
        
        // 初回のみ画面の中心を最新の位置情報に設定
        if !isInitialLocationSet {
            let centerCoordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            let region = MKCoordinateRegion(center: centerCoordinate, latitudinalMeters: 1000, longitudinalMeters: 1000) // ズームレベルを設定（必要に応じて調整）
            mapView.setRegion(region, animated: true) // マップの中心を更新
            isInitialLocationSet = true  // 初回設定済みフラグを立てる
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        // マップのユーザー位置マークを更新して向きを示す
        if let userLocation = mapView.userLocation.location {
            let annotationView = mapView.view(for: mapView.userLocation)
            annotationView?.transform = CGAffineTransform(rotationAngle: CGFloat(newHeading.trueHeading * .pi / 180))
        }
    }
}

