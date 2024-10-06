import UIKit
import MapKit

protocol MapManagerDelegate: AnyObject {
    func mapManager(_ manager: MapManager, didTapNewPinAt coordinate: CLLocationCoordinate2D)
}

class MapManager: NSObject, CLLocationManagerDelegate, MKMapViewDelegate {
    weak var delegate: MapManagerDelegate?
    
    private var mapView: MKMapView
    private var locationManager: CLLocationManager
    private var isInitialLocationSet = false

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

    func addPin(at coordinate: CLLocationCoordinate2D, title: String?, subtitle: String?) {
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        annotation.title = title
        annotation.subtitle = subtitle
        mapView.addAnnotation(annotation)
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last, !isInitialLocationSet else { return }
        
        let region = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
        mapView.setRegion(region, animated: true)
        isInitialLocationSet = true
        
        mapView.setUserTrackingMode(.follow, animated: true)
    }
    
    func removeAllNewPins() {
        let newPinsToRemove = mapView.annotations.filter { annotation in
            if let pointAnnotation = annotation as? MKPointAnnotation,
               pointAnnotation.title == "新しいピン" {
                return true
            }
            return false
        }
        mapView.removeAnnotations(newPinsToRemove)
    }

    func addNewPin(at coordinate: CLLocationCoordinate2D) {
        print("新しいピンが追加されました")
        removeAllNewPins()
        addPin(at: coordinate, title: "新しいピン", subtitle: nil)
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        print("annotationがタップされました")
        if let annotation = view.annotation as? MKPointAnnotation,
           annotation.title == "新しいピン" {
            print("新しいピンがタップされました")
            delegate?.mapManager(self, didTapNewPinAt: annotation.coordinate)
        }
    }
}
