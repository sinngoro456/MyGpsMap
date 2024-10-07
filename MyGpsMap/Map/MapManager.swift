import UIKit
import MapKit

protocol MapManagerDelegate: AnyObject {
    func mapManager(_ manager: MapManager, didTapNewPinAt pinData: Data_Pin)
    func mapManager(_ manager: MapManager, didTapExistingPin pinData: Data_Pin)
}

class MapManager: NSObject, CLLocationManagerDelegate, MKMapViewDelegate,ViewControllerDelegate {
    weak var delegate: MapManagerDelegate?
    
    private var mapView: MKMapView
    private var locationManager: CLLocationManager
    private var isInitialLocationSet = false
    var isNewPin: Bool = true

    init(mapView: MKMapView) {
        self.mapView = mapView
        self.locationManager = CLLocationManager()
        super.init()
        setupLocationManager()
        setupMapView()
    }

    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        locationManager.startUpdatingHeading()
    }

    private func setupMapView() {
        mapView.delegate = self
        mapView.showsUserLocation = true
        mapView.selectableMapFeatures = [.pointsOfInterest, .physicalFeatures]
    }

    func addNewPin(at coordinate: CLLocationCoordinate2D) {
        print("新しいピンが追加されました")
        removeAllNewPins()
        removePinsAtCoordinate(coordinate)
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        annotation.title = "新しいピン"
        
        mapView.addAnnotation(annotation)
    }
    
    func addPin(with pinData: Data_Pin) {
        removePinsAtCoordinate(pinData.coordinate)
        let annotation = CustomAnnotation(coordinate: pinData.coordinate,
                                          title: pinData.title ?? "",
                                          subtitle: pinData.description ?? "",
                                          image: pinData.images.first ?? UIImage(),
                                          category: pinData.category ?? "",
                                          tags: pinData.tags ?? [])
        mapView.addAnnotation(annotation)
    }
    
    func addPin_NoImage(with pinData: Data_Pin) {
        print("NoImage")
        removePinsAtCoordinate(pinData.coordinate)
        let annotation = MKPointAnnotation()
        annotation.coordinate = pinData.coordinate
        annotation.title = pinData.title
        mapView.addAnnotation(annotation)
    }
    
    func removePinsAtCoordinate(_ coordinate: CLLocationCoordinate2D) {
        // 既存のアノテーションをフィルタリングして削除対象を見つける
        let annotationsToRemove = mapView.annotations.filter { annotation in
            if let customAnnotation = annotation as? CustomAnnotation {
                // 座標が一致するかチェック（浮動小数点の比較なので、小さな誤差を許容）
                let latDiff = abs(customAnnotation.coordinate.latitude - coordinate.latitude)
                let lonDiff = abs(customAnnotation.coordinate.longitude - coordinate.longitude)
                return latDiff < 0.000001 && lonDiff < 0.000001
            }
            return false
        }
        // 見つかったアノテーションを削除
        mapView.removeAnnotations(annotationsToRemove)
    }
    
    func removeAllNewPins() {
        let newPinsToRemove = mapView.annotations.filter { annotation in
            if let pointAnnotation = annotation as? MKPointAnnotation,
               pointAnnotation.title == "新しいピン",pointAnnotation.subtitle == nil {
                print("こいつ捨てます")
                return true
            }
            return false
        }
        mapView.removeAnnotations(newPinsToRemove)
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last, !isInitialLocationSet else { return }
        
        let region = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
        mapView.setRegion(region, animated: true)
        isInitialLocationSet = true
        
        mapView.setUserTrackingMode(.follow, animated: true)
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        print("mapView, ViewFor")
        print(annotation)
        
        if let pointAnnotation = annotation as? MKPointAnnotation {
            print(pointAnnotation.title ?? "")
            print(pointAnnotation.subtitle ?? "")
            let identifier = "defaultPin"
            var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKMarkerAnnotationView
            
            if annotationView == nil {
                annotationView = MKMarkerAnnotationView(annotation: pointAnnotation, reuseIdentifier: identifier)
                annotationView?.markerTintColor = .orange
                annotationView?.glyphText = nil
            } else {
                annotationView?.annotation = pointAnnotation
            }
            
            return annotationView
        } else if let customAnnotation = annotation as? CustomAnnotation {
            print(customAnnotation.title ?? "")
            print(customAnnotation.subtitle ?? "")
            print(customAnnotation.image != nil ? 1 : 0) // 画像の数を表示
            print(customAnnotation.category ?? "")
            print(customAnnotation.tags ?? [])
            
            let identifier = "CustomAnnotationView"
            var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? CustomAnnotationView
            
            if annotationView == nil {
                annotationView = CustomAnnotationView(annotation: customAnnotation, reuseIdentifier: identifier)
            } else {
                annotationView?.annotation = customAnnotation
            }
            
            return annotationView
        }
        
        return nil
    }

    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        if let annotation = view.annotation {
            print("coordinate",annotation.coordinate)
            isNewPin=false
            if let customAnnotation = annotation as? CustomAnnotation {
                // CustomAnnotationの場合
                print("title",customAnnotation.title ?? "")
                print("subtitle",customAnnotation.subtitle ?? "")
                print("image",customAnnotation.image != nil ? 1 : 0) // 画像の数を表示
                print("category",customAnnotation.category ?? "")
                print("tags",customAnnotation.tags ?? [])
                
                let images: [UIImage] = {
                    if let image = customAnnotation.image {
                        return [image]
                    } else {
                        return []
                    }
                }()

                let pinData = Data_Pin(coordinate: customAnnotation.coordinate,
                                       title: customAnnotation.title,
                                       description: customAnnotation.subtitle,
                                       images: images,
                                       category: customAnnotation.category,
                                       tags: customAnnotation.tags)
                delegate?.mapManager(self, didTapExistingPin: pinData)
            } else if let pointAnnotation = annotation as? MKPointAnnotation, pointAnnotation.title == "新しいピン", pointAnnotation.subtitle == nil {
                // annotationの場合
                print("title",pointAnnotation.title ?? "")
                print("subtitle",pointAnnotation.subtitle ?? "")
                let pinData = Data_Pin(coordinate: pointAnnotation.coordinate,
                                       title: "新しいピン",
                                       description: "",
                                       images: [],
                                       category: "",
                                       tags: [])
                delegate?.mapManager(self, didTapNewPinAt: pinData)
                isNewPin=true
            }else if let pointAnnotation = annotation as? MKPointAnnotation{
                // annotationの場合
                print("title2",pointAnnotation.title ?? "")
                print("subtitle2",pointAnnotation.subtitle ?? "")
                let pinData = Data_Pin(coordinate: pointAnnotation.coordinate,
                                       title: pointAnnotation.title,
                                       description: pointAnnotation.subtitle,
                                       images: [],
                                       category: "",
                                       tags: [])
                delegate?.mapManager(self, didTapNewPinAt: pinData)
                isNewPin=true
            }else{
                print("未知のピン")
            }
        }
    }
}
