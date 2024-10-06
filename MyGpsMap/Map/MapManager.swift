import UIKit
import MapKit

class MapManager: NSObject, CLLocationManagerDelegate {
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
        removeAllNewPins()
        addPin(at: coordinate, title: "新しいピン", subtitle: nil)
    }
}
