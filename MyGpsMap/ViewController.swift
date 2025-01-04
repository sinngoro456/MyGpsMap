// ViewController.swift

import UIKit
import MapKit


protocol ViewControllerDelegate: AnyObject {
    var isNewPin: Bool { get }
}

class ViewController: UIViewController {
    
    // MARK: - Properties
    @IBOutlet var mapView: MKMapView!
    
    private var mapManager: MapManager!
    private var uiSetupManager: UISetupManager!
    private var timer1: Timer? // Timerプロパティを追加
    private var timer2: Timer? // Timerプロパティを追加
    
    // UI要素のプロパティ
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
        startTimer()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        // Timerを停止
        stopTimer()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // PinManagerのインスタンスを起動
        let _ = PinManager.shared
        Task {
            await setupManagers()
            setupUI()
            setupMapView()
            setupGestures()
            do {
                _ = await PinManager.shared.loadPins()
                _ = await FriendManager.shared.loadFriendsFromDynamoDB()
            }
        }
    }
    

    
    // MARK: - Setup Methods
    private func setupManagers() async {
        mapManager = MapManager.shared // シングルトンインスタンスを取得
        mapManager.configure(with: mapView) // マップビューを設定
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

        // 既存のUIPanGestureRecognizerを見つけて、カスタムのものと区別する
        if let existingPanGesture = mapView.gestureRecognizers?.first(where: { $0 is UIPanGestureRecognizer && $0 != customPanGesture }) {
            existingPanGesture.require(toFail: customPanGesture)
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
        navigationController?.pushViewController(viewControllerLogin, animated: true)
    }
    
    @objc private func spotifyButtonTapped() {
        print("Spotifyボタンがタップされました")
    }
    
    @objc private func radikoButtonTapped() {
        print("Radikoボタンがタップされました")
    }
    
    private func confirmOverwritePins(completion: @escaping (Bool) -> Void) {
        let alert = UIAlertController(title: "上書き確認", message: "ローカルのデータが最新です。データベースのデータで上書きしますか？", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "はい", style: .default, handler: { _ in
            completion(true) // ユーザーが「はい」を選択した場合
        }))
        
        alert.addAction(UIAlertAction(title: "いいえ", style: .cancel, handler: { _ in
            completion(false) // ユーザーが「いいえ」を選択した場合
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    // MARK:- Timer Methods
    private func startTimer() {
        timer1 = Timer.scheduledTimer(timeInterval: 5.0, target: self, selector: #selector(timerFired1), userInfo: nil, repeats: true)
        timer2 = Timer.scheduledTimer(timeInterval: 0.2, target: self, selector: #selector(timerFired2), userInfo: nil, repeats: true)
    }

    private func stopTimer() {
        timer1?.invalidate()
        timer2?.invalidate()
        timer1 = nil
        timer2 = nil
    }
    
    @objc private func timerFired1() {
        print("定期処理1が実行されました")
        // 定期的に実行したい処理をここに記述します。
        MapPinFriendOrganizer.shared.Refresh1()
   }
    
    @objc private func timerFired2() {
        // 定期的に実行したい処理をここに記述します。
        MapPinFriendOrganizer.shared.Refresh2()
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
        userTrackingButton.setImage(UIImage(systemName: Constants_Design.userTrackingButtonNone), for: .normal)
    }
    
    @objc private func handlePan(_ gestureRecognizer: UIPanGestureRecognizer) {
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
}

// MARK: - UIGestureRecognizerDelegate
extension ViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

// MARK: - MKMapViewDelegate
extension ViewController : MKMapViewDelegate {
}

// MARK: - MapManagerDelegate
extension ViewController : MapManagerDelegate {
    
    func mapManager(_ manager : MapManager , didTapPin pinData : Data_Pin) {
        print("モーダル遷移に入った")
        
        let viewController_PinEdit = ViewController_PinEdit(pinData : pinData)
        
        viewController_PinEdit.delegate = self
        viewController_PinEdit.modalPresentationStyle = .pageSheet
        
        viewController_PinEdit.tappedCoordinate = pinData.coordinate
        
        present(viewController_PinEdit , animated : true , completion : nil)
    }
}

// MARK:- UIAdaptivePresentationControllerDelegate
extension ViewController : UIAdaptivePresentationControllerDelegate {
    
    func presentationControllerDidDismiss(_ presentationController : UIPresentationController) {
        
         print("モーダルが閉じられました")
         view.endEditing(true)
         deselectAllAnnotations()
     }
}

// MARK:- NewPinManagerDelegate
extension ViewController : ViewController_PinEdit_Delegate {

     func newPinManagerDidTapPlus(_ controller : ViewController_PinEdit , pinData : Data_Pin) {
         print("Plus button tapped with title : \(pinData.title ?? "") and description : \(pinData.description ?? "")")
         PinManager.shared.addPins([pinData])
         PinManager.shared.saveAllPins()
         PinManager.shared.printPins()
     }

     func newPinManagerDidTapClose(_ controller : ViewController_PinEdit , pinData : Data_Pin) {
         print("Close button tapped")
         PinManager.shared.deletePins([pinData.coordinate])
         PinManager.shared.saveAllPins()
         PinManager.shared.printPins()
     }
}
