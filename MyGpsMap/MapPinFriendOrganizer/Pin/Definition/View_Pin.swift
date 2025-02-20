//
//  View_Pin.swift
//  MyGpsMap
//
//  Created by 川渕悟郎 on 2025/02/20.
//

import UIKit
import CoreLocation

/// 画面上に置く「ピンビュー」のサンプル
class CustomPinView: UIView {
    
    /// このピンが示す座標
    let coordinate: CLLocationCoordinate2D
    
    /// 初期化時に座標を受け取る
    init(coordinate: CLLocationCoordinate2D) {
        self.coordinate = coordinate
        super.init(frame: .zero)
        
        // ピンの大きさや見た目を適当に指定
        self.frame.size = CGSize(width: 30, height: 30)
        self.layer.cornerRadius = 15
        self.backgroundColor = .red
        
        // タップやドラッグしたい場合はユーザ操作を有効化
        self.isUserInteractionEnabled = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

