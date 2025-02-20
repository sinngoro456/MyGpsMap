//
//  PinViewManager.swift
//  MyGpsMap
//
//  Created by 川渕悟郎 on 2025/02/20.
//

import UIKit
import CoreLocation

class PinViewManager {
    static let shared = PinViewManager()
    
    private var pinViews: [Int: Viw_Pin] = [:]
    weak var containerView: UIView?
    
    private init() {}
    
    func setContainerView(_ view: UIView) {
        self.containerView = view
    }
    
    func addPinViews(for pins: [Data_Pin]) {
        guard let containerView = containerView else {
            print("コンテナビューが設定されていません。")
            return
        }
        
        for pin in pins {
            let pinView = Viw_Pin(frame: CGRect(x: 0, y: 0, width: 30, height: 30), color: .red)
            pinView.center = convertCoordinateToPoint(pin.coordinate)
            containerView.addSubview(pinView)
            pinViews[pin.pin_id!] = pinView
        }
    }
    
    func removePinViews(for pinIds: [Int]) {
        for pinId in pinIds {
            if let pinView = pinViews[pinId] {
                pinView.removeFromSuperview()
                pinViews.removeValue(forKey: pinId)
            }
        }
    }
    
    func updatePinViews(for pins: [Data_Pin]) {
        removePinViews(for: pinViews.keys.map { $0 })
        addPinViews(for: pins)
    }
    
    func clearAllPinViews() {
        for (_, pinView) in pinViews {
            pinView.removeFromSuperview()
        }
        pinViews.removeAll()
    }
    
    private func convertCoordinateToPoint(_ coordinate: CLLocationCoordinate2D) -> CGPoint {
        // 座標変換のロジックを実装する必要があります
        // この例では仮の実装を示しています
        return CGPoint(x: CGFloat(coordinate.longitude), y: CGFloat(coordinate.latitude))
    }
}

