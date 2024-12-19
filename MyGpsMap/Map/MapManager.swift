import UIKit
import MapKit

protocol MapManagerDelegate: AnyObject {
    func mapManager(_ manager: MapManager, didTapPin pinData: Data_Pin)
}

class MapManager: NSObject, CLLocationManagerDelegate, MKMapViewDelegate,ViewControllerDelegate {
    weak var delegate: MapManagerDelegate?
    
    private var mapView: MKMapView
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
        removePinsAtCoordinate(coordinate)
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        annotation.title = "新しいピン"
        self.pincolor = UIColor.white
        
        mapView.addAnnotation(annotation)
    }
    
    func addPin(with pinData: Data_Pin) {
        // 指定された座標の既存のピンを削除
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
            let annotation = MKPointAnnotation()
            annotation.coordinate = pinData.coordinate
            annotation.title = pinData.title ?? ""
            mapView.addAnnotation(annotation)
        }
        PinManager.shared.addPin(pinData)  // pins 配列に追加
    }
    
    func removePinsAtCoordinate(_ coordinate: CLLocationCoordinate2D) {
        removeAllNewPins()
        removeArrayPins()
        // 既存のアノテーションをフィルタリングして削除対象を見つける
        let annotationsToRemove = mapView.annotations.filter { annotation in
                // 座標が一致するかチェック（浮動小数点の比較なので、小さな誤差を許容）
                let Diff = abs(annotation.coordinate.latitude - coordinate.latitude)+abs(annotation.coordinate.longitude - coordinate.longitude)
                return Diff < 0.000004
            }
        
        // 見つかったアノテーションを削除
        mapView.removeAnnotations(annotationsToRemove)
        // PinManagerのメソッドを使ってpins配列からも削除
        PinManager.shared.removePinsAtCoordinate(coordinate)
    }
    
    func removeAllNewPins() {
        // PinManager に管理されているピンの情報を取得
        let managedPins = PinManager.shared.pins
        
        // 管理されていないアノテーションをフィルタリング
        let newPinsToRemove = mapView.annotations.filter { annotation in
            if let pointAnnotation = annotation as? MKPointAnnotation {
                // 座標の誤差を許容するための閾値
                let tolerance: Double = 0.000004
                
                // 管理されているピンと比較
                for managedPin in managedPins {
                    let diff = abs(pointAnnotation.coordinate.latitude - managedPin.coordinate.latitude)+abs(pointAnnotation.coordinate.longitude - managedPin.coordinate.longitude)
                    
                    // 誤差内でかつタイトルが一致する場合は管理されているピンとみなす
                    if diff < tolerance && pointAnnotation.title == managedPin.title {
                        return false // 管理されているピンなので削除しない
                    }
                }
                return true // 管理されていないピンなので削除
            }
            return false // MKPointAnnotation でない場合は削除しない
        }
        
        // フィルタリングしたアノテーションを削除
        mapView.removeAnnotations(newPinsToRemove)
    }
    
    func removeArrayPins() {
        PinManager.shared.removeRedundantPins(from: mapView.annotations)
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
            let identifier = "defaultPin"
            let annotationView = MKMarkerAnnotationView(annotation: pointAnnotation, reuseIdentifier: identifier)
            annotationView.markerTintColor = pincolor
            return annotationView
        } else if annotation is CustomAnnotation {
            let identifier = "CustomAnnotationView"
            let annotationView = CustomAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            return annotationView
        }
        return nil
    }


    // アノテーションが選択されたとき
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        guard let annotation = view.annotation else { return }
        // pinを取得または新しいピンを作成
        let pin = PinManager.shared.findMatchingPin(for: annotation) ?? Data_Pin(coordinate: annotation.coordinate, title: "新しいピン")
        delegate?.mapManager(self, didTapPin: pin)
    }
}
