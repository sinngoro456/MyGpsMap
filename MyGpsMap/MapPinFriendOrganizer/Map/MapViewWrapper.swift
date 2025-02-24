//
//  MapViewWrapper.swift
//  MyGpsMap
//
//  Created by 川渕悟郎 on 2025/02/22.
//

import SwiftUI
import MapKit
import CoreLocation

struct MapViewWrapper: UIViewRepresentable {
    @Binding var trackingMode: MKUserTrackingMode
    @Binding var editingPin: Data_Pin?

    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView(frame: .zero)

        mapView.showsUserLocation = true
        mapView.showsCompass = false
        mapView.layoutMargins = UIEdgeInsets(top: 0, left: 0, bottom: -30, right: 0)
        mapView.setUserTrackingMode(trackingMode, animated: true)

        let compassButton = MKCompassButton(mapView: mapView)
        compassButton.compassVisibility = .visible
        mapView.addSubview(compassButton)
        compassButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            compassButton.topAnchor.constraint(equalTo: mapView.safeAreaLayoutGuide.topAnchor, constant: 70),
            compassButton.trailingAnchor.constraint(equalTo: mapView.safeAreaLayoutGuide.trailingAnchor, constant: -16)
        ])

        let longPressGesture = UILongPressGestureRecognizer(
            target: context.coordinator,
            action: #selector(Coordinator.handleLongPress(_:))
        )
        mapView.addGestureRecognizer(longPressGesture)

        mapView.delegate = context.coordinator
        context.coordinator.mapView = mapView

        return mapView
    }

    func updateUIView(_ uiView: MKMapView, context: Context) {
        uiView.removeAnnotations(uiView.annotations)
        addPins(pins: PinManager.shared.pins, to: uiView)
        uiView.setUserTrackingMode(.follow, animated: true)
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func addPins(pins: [Data_Pin], to mapView: MKMapView) {
        for pin in pins {
            let annotation = MKPointAnnotation()
            annotation.coordinate = pin.coordinate
            annotation.title = pin.title

            mapView.addAnnotation(annotation)
        }
    }

    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: MapViewWrapper
        var mapView: MKMapView?

        init(_ parent: MapViewWrapper) {
            self.parent = parent
            super.init()
            NotificationCenter.default.addObserver(self, selector: #selector(handlePinUpdate), name: .pinDataUpdated, object: nil)
        }

        deinit {
            NotificationCenter.default.removeObserver(self)
        }

        @objc func handlePinUpdate() {
            DispatchQueue.main.async {
                guard let mapView = self.mapView else { return }
                mapView.removeAnnotations(mapView.annotations)
                self.parent.addPins(pins: PinManager.shared.pins, to: mapView)
            }
        }

        @objc func handleLongPress(_ gesture: UILongPressGestureRecognizer) {
            guard gesture.state == .began else { return }

            let mapView = gesture.view as! MKMapView
            let point = gesture.location(in: mapView)
            let coordinate = mapView.convert(point, toCoordinateFrom: mapView)

            parent.editingPin = Data_Pin(
                pin_id: "",
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

        func mapView(_ mapView: MKMapView, didChange mode: MKUserTrackingMode, animated: Bool) {
        }

        func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
            guard let customAnnotationView = view as? CustomAnnotationView else { return }

            // 隠し情報を取得
            if let user_id = customAnnotationView.user_id, let pin_id = customAnnotationView.pin_id {
                print("Selected Pin - User ID: \(user_id), Pin ID: \(pin_id)")

                // PinManagerからピンを取得
                if let pin = PinManager.shared.getPin(pinID: pin_id) {
                    self.parent.editingPin = pin
                } else {
                    print("Failed to get pin: Pin not found")
                }
            }
        }

        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            // ユーザーの現在地を示すアノテーションはデフォルトのままにする
            if annotation is MKUserLocation {
                return nil
            }

            // カスタムAnnotationViewを再利用
            let reuseIdentifier = "customAnnotation"
            var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseIdentifier) as? CustomAnnotationView

            if annotationView == nil {
                annotationView = CustomAnnotationView(annotation: annotation, reuseIdentifier: reuseIdentifier)
                annotationView?.canShowCallout = false // カスタムビューを使うため、デフォルトの吹き出しは非表示
            } else {
                annotationView?.annotation = annotation
            }

            // ピンのデータをカスタムAnnotationViewに反映
            if let pinAnnotation = annotation as? MKPointAnnotation,
            let pin = PinManager.shared.pins.first(where: { $0.coordinate.latitude == pinAnnotation.coordinate.latitude && $0.coordinate.longitude == pinAnnotation.coordinate.longitude }) {
                annotationView?.configure(with: pin)

                // 画像がない場合はデフォルトのピンを使用
                if pin.images.isEmpty {
                    let defaultAnnotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: "defaultAnnotation")
                    return defaultAnnotationView
                }
            }

            return annotationView
        }
    }
}

extension Notification.Name {
    static let pinDataUpdated = Notification.Name("pinDataUpdated")
}
