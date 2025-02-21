//
//  MapViewWrapper.swift
//  MyGpsMap
//
//  Created by 川渕悟郎 on 2025/02/22.
//

import SwiftUI
import MapKit
import CoreLocation
// vieにpindataを受け取ってaddする関数を作成するよ
struct MapViewWrapper: UIewからバインドでもViewRepresentable {
    // 親Viらう
    @Binding var trackingMode: MKUserTrackingMode
    @Binding var editingPin: Data_Pin?
    
    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView(frame: .zero)
        
        // ユーザ位置やコンパスなど、いままでの設定はお好みで
        mapView.showsUserLocation = true
        mapView.showsCompass = false
        mapView.layoutMargins = UIEdgeInsets(top: 0, left: 0, bottom: -30, right: 0)
        mapView.setUserTrackingMode(trackingMode, animated: true)
        
        // カスタムコンパスの追加（省略可）
        let compassButton = MKCompassButton(mapView: mapView)
        compassButton.compassVisibility = .visible
        mapView.addSubview(compassButton)
        compassButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            compassButton.topAnchor.constraint(
                equalTo: mapView.safeAreaLayoutGuide.topAnchor,
                constant: 70
            ),
            compassButton.trailingAnchor.constraint(
                equalTo: mapView.safeAreaLayoutGuide.trailingAnchor,
                constant: -16
            )
        ])
        
        // ロングプレスの設定
        let longPressGesture = UILongPressGestureRecognizer(
            target: context.coordinator,
            action: #selector(Coordinator.handleLongPress(_:))
        )
        mapView.addGestureRecognizer(longPressGesture)
        
        mapView.delegate = context.coordinator
        
        return mapView
    }
    
    // View更新のたびに呼ばれる
    func updateUIView(_ uiView: MKMapView, context: Context) {
        // 既存の注釈を消して、最新の注釈だけ追加
        uiView.removeAnnotations(uiView.annotations)
        
        // newPinData があれば反映
        for pin in PinManager.shared.pins{
            let annotation = MKPointAnnotation()
            annotation.coordinate = pin.coordinate
            uiView.addAnnotation(annotation)
        }
        
        // SwiftUIのトラッキングモードを実際のMKMapViewへ反映
        uiView.setUserTrackingMode(trackingMode, animated: true)
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    // MARK: - Coordinator
    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: MapViewWrapper
        @State private var tempTrackingMode: MKUserTrackingMode = .follow
        init(_ parent: MapViewWrapper) {
            self.parent = parent
        }
        
        // MARK: - Handle Long Press
        @objc func handleLongPress(_ gesture: UILongPressGestureRecognizer) {
            guard gesture.state == .began else { return }
            
            // タップしたスクリーン座標を地図座標に変換
            let mapView = gesture.view as! MKMapView
            let point = gesture.location(in: mapView)
            let coordinate = mapView.convert(point, toCoordinateFrom: mapView)

            parent.editingPin = Data_Pin(
                pin_id: 0,
                coordinate: coordinate,
                title: "",
                description: "",
                color: .purple,
                images: [],
                date: Date(),
                category: "",
                tags: [],
                visibility: "private"
            )
        }
        
        // MARK: - MKMapViewDelegate
        func mapView(_ mapView: MKMapView, didChange mode: MKUserTrackingMode, animated: Bool) {
            tempTrackingMode = mode
        }

        // MARK: - ピンをタップしたとき
        func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
            guard let annotation = view.annotation else { return }
            
            // 例: annotation -> Data_Pin を取り出す（何らかの仕組みが必要）
            // ここではサンプルとしてダミーを生成
            let dummyPin = Data_Pin(
                pin_id: 0,
                coordinate: annotation.coordinate,
                title: "",
                description: "",
                color: .purple,
                images: [],
                date: Date(),
                category: "",
                tags: [],
                visibility: "private"
            )
            
            // SwiftUI の State を更新して、シートを呼び出す
            parent.editingPin = dummyPin
        }
    }
}
