import UIKit
import MapKit

protocol MapManagerDelegate: AnyObject {
    func mapManager(_ manager: MapManager, didLongPressAt coordinate: CLLocationCoordinate2D?)
}

class MapManager: NSObject, CLLocationManagerDelegate, MKMapViewDelegate {
    static let shared = MapManager() // シングルトンインスタンス
    
    weak var delegate: MapManagerDelegate?
    
    private var mapView: MKMapView?
    private var locationManager: CLLocationManager
    private var isInitialLocationSet = false
    
    private override init() {
        self.locationManager = CLLocationManager()
        super.init()
        setupLocationManager()
    }
    
    func configure(with mapView: MKMapView) {
        self.mapView = mapView
        setupMapView()
        setupLongPressGesture()
    }
    
    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        locationManager.startUpdatingHeading()
    }
    
    private func setupMapView() {
        print("fi")
        guard let mapView = mapView else { return }
        mapView.delegate = self
        mapView.showsUserLocation = true
        mapView.selectableMapFeatures = [.pointsOfInterest, .physicalFeatures]
    }
    
    func setupLongPressGesture() {
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
        longPressGesture.minimumPressDuration = 0.5 // 長押しの認識に必要な時間
        mapView?.addGestureRecognizer(longPressGesture)
    }

    @objc func handleLongPress(_ gestureRecognizer: UILongPressGestureRecognizer) {
        if gestureRecognizer.state == .began {
            print("hi")
            let location = gestureRecognizer.location(in: mapView)
            let coordinate = mapView?.convert(location, toCoordinateFrom: mapView)
            delegate?.mapManager(self, didLongPressAt: coordinate)
        }
    }
}
