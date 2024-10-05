import UIKit
import MapKit
import Amplify
import AmplifyPlugins

class ViewController: UIViewController, UITextFieldDelegate, UIGestureRecognizerDelegate {
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
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupManagers()
        setupUI()
        setupGestureRecognizers()
        addInitialPin()
    }
    
    private func setupManagers() {
        mapManager = MapManager(mapView: mapView)
        uiSetupManager = UISetupManager()
    }
    
    private func setupUI() {
        compassButton = uiSetupManager.setupCompassButton(in: view, mapView: mapView)
        userTrackingButton = uiSetupManager.setupUserTrackingButton(in: view, target: self, action: #selector(userTrackingButtonTapped))
        spotifyButton = uiSetupManager.setupSpotifyButton(in: view, target: self, action: #selector(spotifyButtonTapped))
        profileButton = uiSetupManager.setupProfileButton(in: view, target: self, action: #selector(profileButtonTapped))
        radikoButton = uiSetupManager.setupRadikoButton(in: view, target: self, action: #selector(radikoButtonTapped))
        destinationTextField = uiSetupManager.setupDestinationTextField(in: view, delegate: self)
    }
    
    private func setupGestureRecognizers() {
        let swipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
        swipeGesture.delegate = self
        view.addGestureRecognizer(swipeGesture)
        
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(handlePinch(_:)))
        pinchGesture.delegate = self
        view.addGestureRecognizer(pinchGesture)
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
        navigationController?.setNavigationBarHidden(false, animated: true)
        navigationController?.setNavigationBarHidden(false, animated: true)
        self.navigationController?.pushViewController(viewControllerLogin, animated: true)
    }
    
    @objc private func spotifyButtonTapped() {
        print("Spotifyボタンがタップされました")
    }
    
    @objc private func radikoButtonTapped() {
        print("Radikoボタンがタップされました")
    }
    
    @objc private func handleSwipe(_ gesture: UISwipeGestureRecognizer) {
        if gesture.state == .ended {
            print("スワイプが検出されました")
            // ここにスワイプ時の処理を追加
        }
    }
    
    @objc private func handlePinch(_ gesture: UIPinchGestureRecognizer) {
        if gesture.state == .changed || gesture.state == .ended {
            print("ピンチが検出されました。スケール: \(gesture.scale)")
            // ここにピンチ時の処理を追加
        }
    }
    
    // UIGestureRecognizerDelegate メソッド
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        // タッチがボタンやテキストフィールド上でない場合のみジェスチャーを認識
        return !(touch.view is UIButton) && !(touch.view is UITextField)
    }
}
