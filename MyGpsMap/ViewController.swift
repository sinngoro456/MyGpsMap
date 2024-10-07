import UIKit
import MapKit
import Amplify
import AmplifyPlugins

class ViewController: UIViewController {
    
    // MARK: - Properties
    @IBOutlet var mapView: MKMapView!
    
    private var mapManager: MapManager!
    private var uiSetupManager: UISetupManager!
    private var compassButton: MKCompassButton!
    private var userTrackingButton: UIButton!
    private var spotifyButton: UIButton!
    private var profileButton: UIButton!
    private var radikoButton: UIButton!
    private var destinationTextField: UITextField!
    
    private var customPanGesture: UIPanGestureRecognizer!
    private var customPinchGesture: UIPinchGestureRecognizer!
    
    // MARK: - Lifecycle Methods
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupManagers()
        setupUI()
        setupMapView()
        setupGestures()
    }
    
    // MARK: - Setup Methods
    private func setupManagers() {
        mapManager = MapManager(mapView: mapView)
        mapManager.delegate = self
        uiSetupManager = UISetupManager()
    }
    
    private func setupMapView() {
        mapView.register(MKMarkerAnnotationView.self, forAnnotationViewWithReuseIdentifier: "featureAnnotation")
        mapView.delegate = mapManager
    }
    
    private func setupUI() {
        compassButton = uiSetupManager.setupCompassButton(in: view, mapView: mapView)
        userTrackingButton = uiSetupManager.setupUserTrackingButton(in: view, target: self, action: #selector(userTrackingButtonTapped))
        spotifyButton = uiSetupManager.setupSpotifyButton(in: view, target: self, action: #selector(spotifyButtonTapped))
        profileButton = uiSetupManager.setupProfileButton(in: view, target: self, action: #selector(profileButtonTapped))
        radikoButton = uiSetupManager.setupRadikoButton(in: view, target: self, action: #selector(radikoButtonTapped))
        destinationTextField = uiSetupManager.setupDestinationTextField(in: view, delegate: self)
    }
    
    private func setupGestures() {
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
        longPressGesture.minimumPressDuration = 0.5
        mapView.addGestureRecognizer(longPressGesture)
        
        customPinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(handlePinch(_:)))
        mapView.addGestureRecognizer(customPinchGesture)
        
        customPanGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        mapView.addGestureRecognizer(customPanGesture)
        
        if let panGesture = mapView.gestureRecognizers?.first(where: { $0 is UIPanGestureRecognizer }) {
            panGesture.require(toFail: customPanGesture)
        }
        
        longPressGesture.delegate = self
        customPinchGesture.delegate = self
        customPanGesture.delegate = self
    }
    
    // MARK: - Button Actions
    @objc private func userTrackingButtonTapped() {
        print("ユーザートラッキングボタンがタップされました")
        switch mapView.userTrackingMode {
        case .none:
            mapView.setUserTrackingMode(.follow, animated: true)
            userTrackingButton.setImage(UIImage(systemName: Constants_Design.userTrackingButtonFollow), for: .normal)
        case .follow:
            mapView.setUserTrackingMode(.followWithHeading, animated: true)
            userTrackingButton.setImage(UIImage(systemName: Constants_Design.userTrackingButtonFollowWithHeading), for: .normal)
        case .followWithHeading:
            mapView.setUserTrackingMode(.none, animated: true)
            userTrackingButton.setImage(UIImage(systemName: Constants_Design.userTrackingButtonNone), for: .normal)
        @unknown default:
            break
        }
    }
    
    @objc private func profileButtonTapped() {
        print("プロフィールボタンがタップされました")
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewControllerLogin = storyboard.instantiateViewController(withIdentifier: "Login")
        navigationController?.setNavigationBarHidden(false, animated: true)
        self.navigationController?.pushViewController(viewControllerLogin, animated: true)
    }
    
    @objc private func spotifyButtonTapped() {
        print("Spotifyボタンがタップされました")
    }
    
    @objc private func radikoButtonTapped() {
        print("Radikoボタンがタップされました")
    }
    
    // MARK: - Gesture Handlers
    @objc private func handleLongPress(_ gestureRecognizer: UILongPressGestureRecognizer) {
        if gestureRecognizer.state == .began {
            let touchPoint = gestureRecognizer.location(in: mapView)
            let coordinate = mapView.convert(touchPoint, toCoordinateFrom: mapView)
            mapManager.addNewPin(at: coordinate)
        }
    }
    
    @objc private func handlePinch(_ gestureRecognizer: UIPinchGestureRecognizer) {
        print("ピンチが検出されました: スケール = \(gestureRecognizer.scale)")
        userTrackingButton.setImage(UIImage(systemName: Constants_Design.userTrackingButtonNone), for: .normal)
    }
    
    @objc private func handlePan(_ gestureRecognizer: UIPanGestureRecognizer) {
        let translation = gestureRecognizer.translation(in: mapView)
        print("パン（スライド）が検出されました: x=\(translation.x), y=\(translation.y)")
        userTrackingButton.setImage(UIImage(systemName: Constants_Design.userTrackingButtonNone), for: .normal)
    }
    
    // MARK: - Helper Methods
    private func deselectAllAnnotations() {
        for annotation in mapView.annotations {
            mapView.deselectAnnotation(annotation, animated: false)
        }
    }
}

// MARK: - UITextFieldDelegate
extension ViewController: UITextFieldDelegate {
    // Implement UITextFieldDelegate methods here
}

// MARK: - UIGestureRecognizerDelegate
extension ViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

// MARK: - MKMapViewDelegate
extension ViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if let annotation = annotation as? MKMapFeatureAnnotation {
            let markerAnnotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "featureAnnotation", for: annotation) as? MKMarkerAnnotationView
            markerAnnotationView?.animatesWhenAdded = true
            markerAnnotationView?.canShowCallout = true
            
            let infoButton = UIButton(type: .detailDisclosure)
            markerAnnotationView?.rightCalloutAccessoryView = infoButton
            
            if let tappedFeatureColor = annotation.iconStyle?.backgroundColor,
               let image = annotation.iconStyle?.image {
                let imageView = UIImageView(image: image.withTintColor(tappedFeatureColor, renderingMode: .alwaysOriginal))
                imageView.bounds = CGRect(origin: .zero, size: CGSize(width: 50, height: 50))
                markerAnnotationView?.leftCalloutAccessoryView = imageView
            }
            return markerAnnotationView
        } else {
            return nil
        }
    }
}

// MARK: - MapManagerDelegate
extension ViewController: MapManagerDelegate {
    func mapManager(_ manager: MapManager, didTapNewPinAt coordinate: CLLocationCoordinate2D) {
        print("モーダル遷移に入った")
        let newPinManager = NewPinManager()
        newPinManager.delegate = self
        newPinManager.modalPresentationStyle = .pageSheet
        
        newPinManager.tappedCoordinate = coordinate
        
        present(newPinManager, animated: true, completion: nil)
    }
}

// MARK: - UIAdaptivePresentationControllerDelegate
extension ViewController: UIAdaptivePresentationControllerDelegate {
    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        print("モーダルが閉じられました")
        view.endEditing(true)
        deselectAllAnnotations()
    }
}

// MARK: - NewPinManagerDelegate
extension ViewController: NewPinManagerDelegate {
    func newPinManagerDidTapPlus(_ controller: NewPinManager, pinData: Data_Pin) {
        print("Plus button tapped with title: \(pinData.title ?? "") and description: \(pinData.description ?? "")")
        if pinData.images.isEmpty {
            mapManager.addPin_NoImage(with: pinData)
        } else {
            mapManager.addPin(with: pinData) // Data_Pinを使用してアノテーションを追加
        }
        print("アノテーションが追加されました")
         mapManager.removeAllNewPins()
    }
    
    func newPinManagerDidTapClose(_ controller: NewPinManager) {
        print("Close button tapped")
        mapManager.removeAllNewPins()
    }
}
