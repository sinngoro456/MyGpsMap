import UIKit
import MapKit
import Amplify
import AmplifyPlugins

class ViewController: UIViewController, UITextFieldDelegate, UIGestureRecognizerDelegate, MKMapViewDelegate, MapManagerDelegate {
    // MapManagerDelegate メソッド
    func mapManager(_ manager: MapManager, didTapNewPinAt coordinate: CLLocationCoordinate2D) {
        print("モーダル遷移に入った")
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewControllerNewPin = storyboard.instantiateViewController(withIdentifier: "NewPin")
            print("viewcontroller")
        viewControllerNewPin.modalPresentationStyle = .fullScreen // または .overFullScreen
        present(viewControllerNewPin, animated: true, completion: nil)
    }

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
        addInitialPin()
    }
    
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
        
        // MKMapViewのジェスチャー認識器の設定
        if let panGesture = mapView.gestureRecognizers?.first(where: { $0 is UIPanGestureRecognizer }) {
            panGesture.require(toFail: customPanGesture)
        }
        
        // ジェスチャー認識器のデリゲートを設定
        longPressGesture.delegate = self
        customPinchGesture.delegate = self
        customPanGesture.delegate = self
    }

    private func addInitialPin() {
        let coordinate = CLLocationCoordinate2D(latitude: 35.6895, longitude: 139.6917) // 東京の座標
        mapManager.addPin(at: coordinate, title: "東京", subtitle: "日本の首都")
    }

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
    
    // UIGestureRecognizerDelegate メソッド
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    // MKMapViewDelegate メソッド
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
