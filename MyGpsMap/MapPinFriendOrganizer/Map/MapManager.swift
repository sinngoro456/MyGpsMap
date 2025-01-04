import UIKit
import MapKit

protocol MapManagerDelegate: AnyObject {
    func mapManager(_ manager: MapManager, didTapPin pinData: Data_Pin)
}

class MapManager: NSObject, CLLocationManagerDelegate, MKMapViewDelegate {
    static let shared = MapManager() // シングルトンインスタンス
    
    weak var delegate: MapManagerDelegate?
    
    let tolerance: Double = 0.000004
    private var mapView: MKMapView?
    private var locationManager: CLLocationManager
    private var isInitialLocationSet = false
    private var pincolor: UIColor
    private(set) var pins_display: [Data_Pin] = [] // 実際のannotationと完全に対応するpins, 外部からは読み取り専用
    var isNewPin: Bool = true

    private override init() {
        self.locationManager = CLLocationManager()
        self.pincolor = UIColor.white
        super.init()
        setupLocationManager()
    }

    func configure(with mapView: MKMapView) {
        self.mapView = mapView
        setupMapView()
    }

    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        locationManager.startUpdatingHeading()
    }

    private func setupMapView() {
        guard let mapView = mapView else { return }
        mapView.delegate = self
        mapView.showsUserLocation = true
        mapView.selectableMapFeatures = [.pointsOfInterest, .physicalFeatures]
    }

    func addNewPin(at coordinate: CLLocationCoordinate2D) {
        print("新しいピンが追加されました")
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        annotation.title = "新しいピン"
        self.pincolor = UIColor.white
        removeAllNewPins()
        mapView?.addAnnotation(annotation)
    }
    
    func addPins(with newPins: [Data_Pin]) {
        print("マップにpinを追加します")
        PinManager.shared.printPins()
        guard let mapView = mapView else { return }
        
        for pin in newPins {
            // 指定された座標の既存のピンを削除
            removePinsAtCoordinate(pin.coordinate)
            self.pincolor = UIColor.orange
            
            // 画像が存在する場合はカスタムアノテーションを作成
            if let image = pin.images.first {
                let annotation = CustomAnnotation(coordinate: pin.coordinate,
                                                  title: pin.title ?? "",
                                                  subtitle: pin.description ?? "",
                                                  image: image,
                                                  category: pin.category ?? "",
                                                  tags: pin.tags ?? [])
                mapView.addAnnotation(annotation)
            } else {
                // 画像が存在しない場合は通常のMKPointAnnotationを作成
                let annotation = MKPointAnnotation()
                annotation.coordinate = pin.coordinate
                annotation.title = pin.title ?? ""
                mapView.addAnnotation(annotation)
            }
        }
        addPinsDisplay(newPins)
    }
    
    func removePinsAtCoordinate(_ coordinate: CLLocationCoordinate2D) {
        guard let mapView = mapView else { return }
        
        // 既存のアノテーションをフィルタリングして削除対象を見つける
        let annotationsToRemove = mapView.annotations.filter { annotation in
            let diffLatitude = abs(annotation.coordinate.latitude - coordinate.latitude)
            let diffLongitude = abs(annotation.coordinate.longitude - coordinate.longitude)
            return (diffLatitude < tolerance && diffLongitude < tolerance)
        }
        
        // 見つかったアノテーションを削除
        mapView.removeAnnotations(annotationsToRemove)
        removePinsDisplayAtCoordinate(coordinate)
    }
    
    func removeAllNewPins() {
        guard let mapView = mapView else { return }
        
        // PinManager に管理されているピンの情報を取得
        let managedPins = PinManager.shared.pins
        
        // 管理されていないアノテーションをフィルタリング
        let newPinsToRemove = mapView.annotations.filter { annotation in
            if let pointAnnotation = annotation as? MKPointAnnotation {
                // 管理されているピンと比較
                for managedPin in managedPins {
                    let diffLatitude = abs(pointAnnotation.coordinate.latitude - managedPin.coordinate.latitude)
                    let diffLongitude = abs(pointAnnotation.coordinate.longitude - managedPin.coordinate.longitude)
                    
                    // 誤差内でかつタイトルが一致する場合は管理されているピンとみなす
                    if diffLatitude < tolerance && diffLongitude < tolerance && pointAnnotation.title == managedPin.title {
                        return false // 管理されているピンなので削除しない
                    }
                }
                return true // 管理されていないピンなので削除
            }
            return false // MKPointAnnotation でない場合は削除しない
        }
        
        // フィルタリングしたアノテーションを削除
        mapView.removeAnnotations(newPinsToRemove)
        removeAllNewPinsDisplay(managedPins)
    }
    
    func clearPins() {
        print("マップ上のpinを全て削除します")
        guard let mapView = mapView else { return }
        let allAnnotations = mapView.annotations
        let annotationsToRemove = allAnnotations.filter { !($0 is MKUserLocation) }
        mapView.removeAnnotations(annotationsToRemove)
        pins_display=[]
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last, !isInitialLocationSet else { return }
        
        let region = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
        mapView?.setRegion(region, animated: true)
        isInitialLocationSet = true
        
        mapView?.setUserTrackingMode(.follow, animated: true)
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
        let pinData = PinManager.shared.findMatchingPin(for: annotation) ?? Data_Pin(coordinate: annotation.coordinate, title: "新しいピン")
        
        delegate?.mapManager(self, didTapPin: pinData)
    }
}
// MARK: - pins_displayを操作するメソッド
extension MapManager {
    func removePinsDisplayAtCoordinate(_ coordinate: CLLocationCoordinate2D) {
        let tolerance: Double = 0.000004 // 適切な値に調整してください
        
        pins_display.removeAll { pin in
            let diffLatitude = abs(pin.coordinate.latitude - coordinate.latitude)
            let diffLongitude = abs(pin.coordinate.longitude - coordinate.longitude)
            return diffLatitude < tolerance && diffLongitude < tolerance
        }
    }
    
    func addPinsDisplay(_ newPins: [Data_Pin]) {
        for pin in newPins {
            // pins_displayに追加
            if !pins_display.contains(where: { pins_display in
                return pins_display.coordinate.latitude == pin.coordinate.latitude &&
                    pins_display.coordinate.longitude == pin.coordinate.longitude
            }) {
                pins_display.append(pin)
            }
        }
    }
    
    func removeAllNewPinsDisplay(_ managedPins: [Data_Pin]) {
        // 管理されていないピンをフィルタリング
        pins_display = pins_display.filter { displayPin in
            // 管理されているピンと比較
            for managedPin in managedPins {
                let diffLatitude = abs(displayPin.coordinate.latitude - managedPin.coordinate.latitude)
                let diffLongitude = abs(displayPin.coordinate.longitude - managedPin.coordinate.longitude)
                
                // 誤差内でかつタイトルが一致する場合は管理されているピンとみなす
                if diffLatitude < tolerance && diffLongitude < tolerance && displayPin.title == managedPin.title {
                    return true // 管理されているピンなので保持する
                }
            }
            return false // 管理されていないピンなので削除
        }
    }
}
