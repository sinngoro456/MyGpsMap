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

    func addPin_NoImage(with pinData: Data_Pin) {
        let annotation = MKPointAnnotation()
        annotation.coordinate = pinData.coordinate
        annotation.title = pinData.title
        annotation.subtitle = pinData.description
        
        mapView.addAnnotation(annotation)
    }
    
    func addPin(with pinData: Data_Pin) {
        let annotation = CustomAnnotation(coordinate: pinData.coordinate, title: pinData.title ?? "", subtitle: pinData.description ?? "", image: pinData.images.first ?? UIImage())
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
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        annotation.title = "新しいピン"
        
        mapView.addAnnotation(annotation)
    }

    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if let pointAnnotation = annotation as? MKPointAnnotation {
            let identifier = "defaultPin"
            var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKMarkerAnnotationView
            
            if annotationView == nil {
                annotationView = MKMarkerAnnotationView(annotation: pointAnnotation, reuseIdentifier: identifier)
                annotationView?.markerTintColor = .orange
                annotationView?.glyphText = nil // 星のマークを削除
            } else {
                annotationView?.annotation = pointAnnotation
            }
            
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

    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        if let annotation = view.annotation as? MKPointAnnotation, annotation.title == "新しいピン" {
            delegate?.mapManager(self, didTapNewPinAt: annotation.coordinate)
        }
    }
}
