import UIKit
import MapKit
import Amplify
import AmplifyPlugins

class ViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet var mapView: MKMapView!
    
    private var mapManager: MapManager!
    private var uiSetupManager: UISetupManager!
    private var compassButton: MKCompassButton!
    private var userTrackingButton: UIButton!
    private var spotifyButton: UIButton!
    private var profileButton: UIButton!
    private var radikoButton: UIButton!
    private var destinationTextField: UITextField!
    
    // 最初はナビゲーションバー(戻るボタンがつく上部のバー)を非表示に
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = true
      }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapManager = MapManager(mapView: mapView)
        uiSetupManager = UISetupManager()
        
        compassButton = uiSetupManager.setupCompassButton(in: view, mapView: mapView)
        userTrackingButton = uiSetupManager.setupUserTrackingButton(in: view, target: self, action: #selector(userTrackingButtonTapped))
        spotifyButton = uiSetupManager.setupSpotifyButton(in: view, target: self, action: #selector(spotifyButtonTapped))
        profileButton = uiSetupManager.setupProfileButton(in: view, target: self, action: #selector(profileButtonTapped))
        radikoButton = uiSetupManager.setupRadikoButton(in: view, target: self, action: #selector(radikoButtonTapped))
        destinationTextField = uiSetupManager.setupDestinationTextField(in: view, delegate: self)
        
        let coordinate = CLLocationCoordinate2D(latitude: 35.6895, longitude: 139.6917) // 東京の座標
        mapManager.addPin(at: coordinate, title: "東京", subtitle: "日本の首都")
    }

    @objc private func userTrackingButtonTapped() {
        print("ユーザートラッキングボタンがタップされました")
        switch mapView.userTrackingMode {
        case .none:
            mapView.setUserTrackingMode(.follow, animated: true)
            userTrackingButton.setImage(UIImage(systemName: Constants_Design.userTrackingButtonNone), for: .normal)
        case .follow:
            mapView.setUserTrackingMode(.followWithHeading, animated: true)
            userTrackingButton.setImage(UIImage(systemName: Constants_Design.userTrackingButtonFollow), for: .normal)
        case .followWithHeading:
            mapView.setUserTrackingMode(.none, animated: true)
            userTrackingButton.setImage(UIImage(systemName: Constants_Design.userTrackingButtonFollowWithHeading), for: .normal)
        @unknown default:
            break
        }
    }
    
    @objc private func profileButtonTapped() {
        print("プロフィールボタンがタップされました")
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewControllerLogin = storyboard.instantiateViewController(withIdentifier: "Login")
        self.navigationController?.pushViewController(viewControllerLogin, animated: true)
        print("プロフィールボタンがタップされました")
    }
    
    @objc private func spotifyButtonTapped() {
        print("Spotifyボタンがタップされました")
    }
    
    @objc private func radikoButtonTapped() {
        print("Radikoボタンがタップされました")
    }
}
