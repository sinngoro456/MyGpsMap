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
    @Binding var searchCoordinate: CLLocationCoordinate2D?

    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView(frame: .zero)

        mapView.showsUserLocation = true
        mapView.showsCompass = false
        mapView.pointOfInterestFilter = .includingAll
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

        // タップジェスチャーを追加
        let tapGesture = UITapGestureRecognizer(
            target: context.coordinator,
            action: #selector(Coordinator.handleTap(_:)))
        mapView.addGestureRecognizer(tapGesture)

        mapView.delegate = context.coordinator
        context.coordinator.mapView = mapView

        return mapView
    }

    func updateUIView(_ uiView: MKMapView, context: Context) {
        uiView.removeAnnotations(uiView.annotations)
        addPins(pins: PinManager.shared.pins, to: uiView)
        uiView.setUserTrackingMode(.follow, animated: true)

        if let coordinate = searchCoordinate {
            let region = MKCoordinateRegion(center: coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
            uiView.setRegion(region, animated: true)
        }
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

        // 選択中のPOIを示すカスタムアノテーション
        var selectedPOIAnnotation: MKPointAnnotation?

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

        // タップジェスチャーのハンドラ
                @objc func handleTap(_ gesture: UITapGestureRecognizer) {
                    guard let mapView = mapView else { return }

                    let point = gesture.location(in: mapView)
                    let coordinate = mapView.convert(point, toCoordinateFrom: mapView)

                    // 既存の選択中アノテーションを削除
                    if let selectedAnnotation = selectedPOIAnnotation {
                        mapView.removeAnnotation(selectedAnnotation)
                        selectedPOIAnnotation = nil
                    }

                    // 最寄りのPOIを検索
                    findNearestPOI(coordinate: coordinate) { poi in
                        guard let poi = poi else {
                            print("No POI found nearby.")
                            return
                        }

                        // 新しいカスタムアノテーションを追加
                        let annotation = MKPointAnnotation()
                        annotation.coordinate = poi.placemark.coordinate
                        annotation.title = poi.placemark.name ?? "Selected POI"
                        mapView.addAnnotation(annotation)
                        self.selectedPOIAnnotation = annotation

                        // マップをタップされた座標に移動
                        let region = MKCoordinateRegion(center: poi.placemark.coordinate, latitudinalMeters: 500, longitudinalMeters: 500)
                        mapView.setRegion(region, animated: true)
                    }
                }
                
                // 最寄りのPOIを検索する関数
                func findNearestPOI(coordinate: CLLocationCoordinate2D, completion: @escaping (MKMapItem?) -> Void) {
                    let request = MKLocalSearch.Request()
                    request.naturalLanguageQuery = "Point of Interest" // POIを検索
                    request.region = MKCoordinateRegion(center: coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)

                    let search = MKLocalSearch(request: request)
                    search.start { response, error in
                        guard let response = response else {
                            print("Error searching for POI: \(error?.localizedDescription ?? "Unknown error")")
                            completion(nil)
                            return
                        }

                        // 最も近いPOIを検索
                        let nearestPOI = response.mapItems.min { item1, item2 in
                            let distance1 = CLLocation(latitude: item1.placemark.coordinate.latitude, longitude: item1.placemark.coordinate.longitude).distance(from: CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude))
                            let distance2 = CLLocation(latitude: item2.placemark.coordinate.latitude, longitude: item2.placemark.coordinate.longitude).distance(from: CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude))
                            return distance1 < distance2
                        }

                        completion(nearestPOI)
                    }
                }

        func mapView(_ mapView: MKMapView, didChange mode: MKUserTrackingMode, animated: Bool) {
        }

        func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
            print("hi")
            guard let customAnnotationView = view as? CustomAnnotationView else { return }

            if let user_id = customAnnotationView.user_id, let pin_id = customAnnotationView.pin_id {
                print("Selected Pin - User ID: \(user_id), Pin ID: \(pin_id)")

                if let pin = PinManager.shared.getPin(pinID: pin_id) {
                    self.parent.editingPin = pin
                } else {
                    print("Failed to get pin: Pin not found")
                }
            }
        }

        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            if annotation is MKUserLocation {
                return nil
            }

            let reuseIdentifier = "customAnnotation"
            var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseIdentifier) as? CustomAnnotationView

            if annotationView == nil {
                annotationView = CustomAnnotationView(annotation: annotation, reuseIdentifier: reuseIdentifier)
                annotationView?.canShowCallout = false
            } else {
                annotationView?.annotation = annotation
            }

            if let pinAnnotation = annotation as? MKPointAnnotation,
            let pin = PinManager.shared.pins.first(where: { $0.coordinate.latitude == pinAnnotation.coordinate.latitude && $0.coordinate.longitude == pinAnnotation.coordinate.longitude }) {
                annotationView?.configure(with: pin)

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
