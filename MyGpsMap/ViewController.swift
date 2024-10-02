import UIKit
import CoreLocation
import MapKit

class ViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate, UIGestureRecognizerDelegate, UITextFieldDelegate {
    @IBOutlet var mapView: MKMapView!
    private var locationManager: CLLocationManager!
    private var isInitialLocationSet = false
    private var compassButton: MKCompassButton!
    private var userTrackingButton: UIButton!
    private var spotifyButton: UIButton!
    private var profileButton: UIButton!
    private var radikoButton: UIButton!
    private var destinationTextField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupLocationManager()
        setupMapView()
        setupCompassButton()
        setupUserTrackingButton()
        setupSpotifyButton()
        setupProfileButton()
        setupRadikoButton()
        setupDestinationTextField()
        
        
        mapView.delegate = self
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handleMapPan(_:)))
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(handleMapPinch(_:)))
        
        panGesture.delegate = self
        pinchGesture.delegate = self
    
        
        mapView.addGestureRecognizer(panGesture)
        mapView.addGestureRecognizer(pinchGesture)
        let coordinate = CLLocationCoordinate2D(latitude: 35.6895, longitude: 139.6917) // 東京の座標
addPin(at: coordinate, title: "東京", subtitle: "日本の首都")
    }
    
    private func setupLocationManager() {
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        locationManager.startUpdatingHeading()
    }
    
    private func setupMapView() {
        mapView.delegate = self
        mapView.showsUserLocation = true
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

    private func setupProfileButton() {
        profileButton = UIButton(type: .system)
        profileButton.setImage(UIImage(systemName: "person.circle"), for: .normal)
        profileButton.backgroundColor = .white
        profileButton.tintColor = .systemBlue
        profileButton.layer.cornerRadius = 8
        profileButton.addTarget(self, action: #selector(profileButtonTapped), for: .touchUpInside)
        
        view.addSubview(profileButton)
        profileButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            profileButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 600),
            profileButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -11),
            profileButton.widthAnchor.constraint(equalToConstant: 40),
            profileButton.heightAnchor.constraint(equalToConstant: 40)
        ])
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last, !isInitialLocationSet else { return }
        
        let region = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
        mapView.setRegion(region, animated: true)
        isInitialLocationSet = true
        
        mapView.setUserTrackingMode(.follow, animated: true)
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        print("Gesture recognizer called for: \(type(of: gestureRecognizer))")
        return true
    }

    @objc func handleMapPan(_ gesture: UIPanGestureRecognizer) {
        print("pan")
        updateUserTrackingButtonIcon()
   }
   
   @objc func handleMapPinch(_ gesture: UIPinchGestureRecognizer) {
       print("pinch")
       updateUserTrackingButtonIcon()
   }

   @objc private func spotifyButtonTapped() {
        // Spotify起動処理をここに追加
        print("Spotifyボタンがタップされました")
    }

    @objc private func profileButtonTapped() {
    // プロフィール情報を表示する処理をここに追加
    print("プロフィールボタンがタップされました")
}

func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    textField.resignFirstResponder()
    if let destination = textField.text {
        print("目的地: \(destination)")
        // ここで目的地に関する処理を行う
    }
    return true
}

@objc private func radikoButtonTapped() {
    // Radiko起動処理をここに追加
    print("Radikoボタンがタップされました")
}
    private func updateUserTrackingButtonIcon() {
        DispatchQueue.main.async {
            switch self.mapView.userTrackingMode {
            case .none:
                self.userTrackingButton.setImage(UIImage(systemName: "location.slash"), for: .normal)
            case .follow:
                self.userTrackingButton.setImage(UIImage(systemName: "location"), for: .normal)
            case .followWithHeading:
                self.userTrackingButton.setImage(UIImage(systemName: "location.fill"), for: .normal)
            @unknown default:
                break
            }
        }
    }

    private func setupSpotifyButton() {
    spotifyButton = UIButton(type: .system)
    spotifyButton.setImage(UIImage(systemName: "play.circle"), for: .normal)
    spotifyButton.backgroundColor = .white
    spotifyButton.tintColor = .systemGreen
    spotifyButton.layer.cornerRadius = 8
    spotifyButton.addTarget(self, action: #selector(spotifyButtonTapped), for: .touchUpInside)
    
    view.addSubview(spotifyButton)
    spotifyButton.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
        spotifyButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
        spotifyButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -60),
        spotifyButton.widthAnchor.constraint(equalToConstant: 40),
        spotifyButton.heightAnchor.constraint(equalToConstant: 40)
        ])
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

    private func setupRadikoButton() {
        radikoButton = UIButton(type: .system)
        radikoButton.setImage(UIImage(systemName: "radio"), for: .normal)
        radikoButton.backgroundColor = .white
        radikoButton.tintColor = .systemRed
        radikoButton.layer.cornerRadius = 8
        radikoButton.addTarget(self, action: #selector(radikoButtonTapped), for: .touchUpInside)
        
        view.addSubview(radikoButton)
        radikoButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            radikoButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            radikoButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 10),
            radikoButton.widthAnchor.constraint(equalToConstant: 40),
            radikoButton.heightAnchor.constraint(equalToConstant: 40)
        ])
    }

    private func addPin(at coordinate: CLLocationCoordinate2D, title: String?, subtitle: String?) {
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        annotation.title = title
        annotation.subtitle = subtitle
        mapView.addAnnotation(annotation)
    }
}
