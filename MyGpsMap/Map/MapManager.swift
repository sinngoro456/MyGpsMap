import UIKit
import MapKit

protocol MapManagerDelegate: AnyObject {
    func mapManager(_ manager: MapManager, didTapNewPinAt pinData: Data_Pin)
    func mapManager(_ manager: MapManager, didTapExistingPin pinData: Data_Pin)
}

class MapManager: NSObject, CLLocationManagerDelegate, MKMapViewDelegate,ViewControllerDelegate {
    weak var delegate: MapManagerDelegate?
    
    private var mapView: MKMapView
    private var pins: [Data_Pin] = []  // Data_Pin オブジェクトの配列
    private var locationManager: CLLocationManager
    private var isInitialLocationSet = false
    var isNewPin: Bool = true
    private var pincolor : UIColor

    init(mapView: MKMapView) {
        self.mapView = mapView
        self.locationManager = CLLocationManager()
        self.pincolor = UIColor.white
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
        self.pincolor = UIColor.white
        
        mapView.addAnnotation(annotation)
    }
    
    func addPin(with pinData: Data_Pin) {
        // 指定された座標に既存のピンを削除
        removePinsAtCoordinate(pinData.coordinate)
        self.pincolor = UIColor.orange
        // 画像が存在する場合はカスタムアノテーションを作成
        if let image = pinData.images.first {
            let annotation = CustomAnnotation(coordinate: pinData.coordinate,
                                              title: pinData.title ?? "",
                                              subtitle: pinData.description ?? "",
                                              image: image,
                                              category: pinData.category ?? "",
                                              tags: pinData.tags ?? [])
            mapView.addAnnotation(annotation)
        } else {
            // 画像が存在しない場合は通常のMKPointAnnotationを作成
            print("NoImage")
            let annotation = MKPointAnnotation()
            annotation.coordinate = pinData.coordinate
            annotation.title = pinData.title ?? ""
            mapView.addAnnotation(annotation)
        }
        pins.append(pinData)  // pins 配列に追加
        printPins()
    }
    
    func removePinsAtCoordinate(_ coordinate: CLLocationCoordinate2D) {
        // 既存のアノテーションをフィルタリングして削除対象を見つける
        let annotationsToRemove = mapView.annotations.filter { annotation in
                // 座標が一致するかチェック（浮動小数点の比較なので、小さな誤差を許容）
                let latDiff = abs(annotation.coordinate.latitude - coordinate.latitude)
                let lonDiff = abs(annotation.coordinate.longitude - coordinate.longitude)
                return latDiff < 0.000001 && lonDiff < 0.000001
            }
        
        // 見つかったアノテーションを削除
        mapView.removeAnnotations(annotationsToRemove)
        pins.removeAll { pin in pin.coordinate.latitude == coordinate.latitude
            && pin.coordinate.longitude == coordinate.longitude
        }
        printPins()
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
    // アノテーションが追加されたとき
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if let pointAnnotation = annotation as? MKPointAnnotation {
            print("hi")
            print(pointAnnotation.title ?? "")
            print(pointAnnotation.subtitle ?? "")
            
            let identifier = "defaultPin"
            var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKMarkerAnnotationView
            annotationView = MKMarkerAnnotationView(annotation: pointAnnotation, reuseIdentifier: identifier)
            annotationView?.markerTintColor = pincolor
            return annotationView
        } else if let customAnnotation = annotation as? CustomAnnotation {
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


    // アノテーションが選択されたとき
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        if let annotation = view.annotation {
            print("coordinate",annotation.coordinate)
            isNewPin=false
            if let customAnnotation = annotation as? CustomAnnotation {
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
                let pinData = Data_Pin(coordinate: pointAnnotation.coordinate,
                                       title: "新しいピン",
                                       description: "",
                                       images: [],
                                       category: "",
                                       tags: [])
                delegate?.mapManager(self, didTapNewPinAt: pinData)
                isNewPin=true
            }else if let pointAnnotation = annotation as? MKPointAnnotation{
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
    
//    デバッグ用
    func printPins() {
        for pin in pins {
            print("Title: \(pin.title ?? "No Title")")
            print("Description: \(pin.description ?? "No Description")")
            print("Coordinate: \(pin.coordinate.latitude), \(pin.coordinate.longitude)")
            print("Category: \(pin.category ?? "No Category")")
            print("Tags: \(pin.tags?.joined(separator: ", ") ?? "No Tags")")
            print("Images Count: \(pin.images.count)\n")
        }
    }
}
