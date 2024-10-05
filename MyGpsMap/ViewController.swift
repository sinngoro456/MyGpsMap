import UIKit
import MapKit
import Amplify
import AmplifyPlugins

class ViewController: UIViewController, UITextFieldDelegate, UserProfileManagerDelegate {
    @IBOutlet var mapView: MKMapView!
    
    
    private var mapManager: MapManager!
    private var spotifyManager: SpotifyManager!
    private var userProfileManager: UserProfileManager!
    private var radikoManager: RadikoManager!
    private var compassButton: MKCompassButton!
    private var userTrackingButton: UIButton!
    private var spotifyButton: UIButton!
    private var profileButton: UIButton!
    private var radikoButton: UIButton!
    private var destinationTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapManager = MapManager(mapView: mapView)
        spotifyManager = SpotifyManager()
        userProfileManager = UserProfileManager()
        radikoManager = RadikoManager()
        
        setupCompassButton()
        setupUserTrackingButton()
        setupSpotifyButton()
        setupProfileButton()
        setupRadikoButton()
        setupDestinationTextField()
        
        userProfileManager.delegate = self
        let _ = userProfileManager.setupProfileButton(in: view)
        
        let coordinate = CLLocationCoordinate2D(latitude: 35.6895, longitude: 139.6917) // 東京の座標
        mapManager.addPin(at: coordinate, title: "東京", subtitle: "日本の首都")
    }

    private func setupSpotifyButton() {
        spotifyButton = spotifyManager.setupSpotifyButton(in: view)
    }

    private func setupProfileButton() {
        profileButton = userProfileManager.setupProfileButton(in: view)
    }

    private func setupRadikoButton() {
        radikoButton = radikoManager.setupRadikoButton(in: view)
    }

    private func setupCompassButton() {
        compassButton = MKCompassButton(mapView: mapView)
        compassButton.compassVisibility = .visible
        
        view.addSubview(compassButton)
        compassButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            compassButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 60),
            compassButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -10)
        ])
    }

    private func setupUserTrackingButton() {
        userTrackingButton = UIButton(type: .system)
        userTrackingButton.setImage(UIImage(systemName: "location"), for: .normal)
        userTrackingButton.backgroundColor = .white
        userTrackingButton.tintColor = .systemBlue
        userTrackingButton.layer.cornerRadius = 8
        userTrackingButton.addTarget(self, action: #selector(userTrackingButtonTapped), for: .touchUpInside)
        
        view.addSubview(userTrackingButton)
        userTrackingButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            userTrackingButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            userTrackingButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -11),
            userTrackingButton.widthAnchor.constraint(equalToConstant: 40),
            userTrackingButton.heightAnchor.constraint(equalToConstant: 40)
        ])
    }

    @objc private func userTrackingButtonTapped() {
        switch mapView.userTrackingMode {
        case .none:
            mapView.setUserTrackingMode(.follow, animated: true)
            userTrackingButton.setImage(UIImage(systemName: "location"), for: .normal)
        case .follow:
            mapView.setUserTrackingMode(.followWithHeading, animated: true)
            userTrackingButton.setImage(UIImage(systemName: "location.fill"), for: .normal)
        case .followWithHeading:
            mapView.setUserTrackingMode(.none, animated: true)
            userTrackingButton.setImage(UIImage(systemName: "location.slash"), for: .normal)
        @unknown default:
            break
        }
    }

    private func setupDestinationTextField() {
        destinationTextField = UITextField()
        destinationTextField.placeholder = "目的地を入力"
        destinationTextField.borderStyle = .roundedRect
        destinationTextField.backgroundColor = .white
        destinationTextField.delegate = self
        
        view.addSubview(destinationTextField)
        destinationTextField.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            destinationTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            destinationTextField.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            destinationTextField.widthAnchor.constraint(equalToConstant: 250),
            destinationTextField.heightAnchor.constraint(equalToConstant: 40)
        ])
    }
    
    func didTapProfileButton() {
        let profileVC = ViewController_Config()
        navigationController?.pushViewController(profileVC, animated: true)
    }
}
