//
//  ViewController_NewPin.swift
//  MyGpsMap
//
//  Created by 川渕悟郎 on 2024/10/06.
//
// MapManagerDelegate メソッド

import UIKit
import MapKit


class NewPinViewController: UIViewController {
    var coordinate: CLLocationCoordinate2D?

    override func viewDidLoad() {
        super.viewDidLoad()
        // ここでビューの設定や座標を使った処理を行う
    }

    // 閉じるボタンなどの処理
    @IBAction func closeButtonTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}
