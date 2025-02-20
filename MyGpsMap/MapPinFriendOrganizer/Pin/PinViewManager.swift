//
//  PinViewManager.swift
//  MyGpsMap
//
//  Created by 川渕悟郎 on 2025/02/20.
//

import UIKit
import MapKit

class PinViewManager: NSObject {
    
    static let shared = PinViewManager()
    
    /// 管理下に置いているすべてのピン (Key: ピンIDなど, Value: CustomPinView)
    private var pinViews: [Int: CustomPinView] = [:]
    
    /// どの MKMapView 上に配置するか（ラベルやボタンと同様にサブビューとして追加）
    private weak var mapView: MKMapView?
    
    /// ピンを載せるコンテナビュー。
    /// ※ 通常は mapView 自身、もしくは mapView 上に重ねたサブビュー(同サイズ)を指定。
    private weak var containerView: UIView?
    
    /// マップの変化にあわせて座標更新するため、MKMapViewDelegateを扱う
    /// （regionDidChangeAnimated などをフックする）
    private var mapDelegateProxy: MapDelegateProxy?
    
    private override init() {
        super.init()
    }
    
    /// 初期設定
    /// - Parameters:
    ///   - mapView: ピンを表示する対象の MKMapView
    ///   - containerView: ピンを置くためのコンテナ。mapView と同一でも可。
    func configure(mapView: MKMapView, containerView: UIView) {
        self.mapView = mapView
        self.containerView = containerView
        
        // mapView.delegate を乗っ取らないように、委譲先をプロキシする
        self.mapDelegateProxy = MapDelegateProxy(realDelegate: mapView.delegate, pinManager: self)
        mapView.delegate = mapDelegateProxy
    }
    
    /// 新しいピンを追加表示
    func addPinView(id: Int, coordinate: CLLocationCoordinate2D) {
        guard let containerView = containerView, let mapView = mapView else { return }
        
        // すでに表示中のピンがあればいったん削除しておく
        removePinViews(for: [id])
        
        // 独自ビューを生成
        let pinView = CustomPinView(coordinate: coordinate)
        
        // 地理座標 → 画面座標 に変換し、center にセット
        let point = mapView.convert(coordinate, toPointTo: mapView)
        pinView.center = point
        
        // 表示階層に追加
        containerView.addSubview(pinView)
        
        // 管理用のディクショナリに登録
        pinViews[id] = pinView
    }
    
    func addNewPinView(coordinate: CLLocationCoordinate2D) {
        guard let containerView = containerView, let mapView = mapView else { return }
        let pinView = CustomPinView(coordinate: coordinate)
        let point = mapView.convert(coordinate, toPointTo: mapView)
        pinView.center = point
        containerView.addSubview(pinView)
    }
    
    /// 複数のピンをまとめて追加したい場合
    func addPinViews(for pins: [Data_Pin]) {
        for pin in pins {
            guard let pinId = pin.pin_id else { continue }
            addPinView(id: pinId, coordinate: pin.coordinate)
        }
    }
    
    /// ピンを削除
    func removePinViews(for pinIds: [Int]) {
        for pinId in pinIds {
            if let pinView = pinViews[pinId] {
                pinView.removeFromSuperview()
                pinViews.removeValue(forKey: pinId)
            }
        }
    }
    
    /// 全ピンを消去
    func removeAllPinViews() {
        for (_, pinView) in pinViews {
            pinView.removeFromSuperview()
        }
        pinViews.removeAll()
    }
    
    /// マップが動いたり拡大縮小されたタイミングで全ピンの座標を更新
    func updateAllPinsPosition() {
        guard let mapView = mapView else { return }
        
        for (_, pinView) in pinViews {
            let newCenter = mapView.convert(pinView.coordinate, toPointTo: mapView)
            pinView.center = newCenter
        }
    }
}

/// 内部で MKMapViewDelegate をプロキシして、regionDidChangeAnimated をフック
private class MapDelegateProxy: NSObject, MKMapViewDelegate {
    
    /// 元々の delegate (他でも MKMapViewDelegate が使われている場合)
    weak var realDelegate: MKMapViewDelegate?
    
    /// ピン管理クラスを参照
    weak var pinManager: PinViewManager?
    
    init(realDelegate: MKMapViewDelegate?, pinManager: PinViewManager) {
        self.realDelegate = realDelegate
        self.pinManager = pinManager
    }
    
    /// regionDidChangeAnimated で呼ばれる → ピンの位置をアップデート
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        pinManager?.updateAllPinsPosition()
        
        // 元々の delegate にも通知
        realDelegate?.mapView?(mapView, regionDidChangeAnimated: animated)
    }
    
    // MARK: - 他の delegate メソッドを必要に応じて転送
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        return realDelegate?.mapView?(mapView, viewFor: annotation)
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        realDelegate?.mapView?(mapView, didSelect: view)
    }
    
    // ... 必要があれば随時追加
}
