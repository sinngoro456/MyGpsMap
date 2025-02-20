//
//  MapViewController.swift
//  MyGpsMap
//
//  Created by 川渕悟郎 on 2025/02/20.
//

import UIKit
import MapKit

/// 以前の "ViewController" の役割を持つ、Storyboardを使わない版
class MapViewController: UIViewController {

    // MARK: - Properties
    // Storyboardでの @IBOutlet は削除し、代わりにコード上で生成
    private var mapView: MKMapView!
    
    private var mapManager: MapManager!
    private var uiSetupManager: UISetupManager!
    private var timer1: Timer?
    private var timer1_duration = 600

    // UI要素
    private var compassButton: MKCompassButton!
    private var userTrackingButton: UIButton!
    private var spotifyButton: UIButton!
    private var profileButton: UIButton!
    private var radikoButton: UIButton!
    private var destinationTextField: UITextField!

    // カスタムジェスチャ
    private var customPanGesture: UIPanGestureRecognizer!
    private var customPinchGesture: UIPinchGestureRecognizer!
    
    // MARK: - Lifecycle
    /// Viewの生成をStoryboardに頼らずに行う
    override func loadView() {
        // スーパークラスで空のUIViewが生成されるので、その上にmapViewなどを追加
        super.loadView()
        
        // マップビューをプログラム生成
        mapView = MKMapView(frame: .zero)
        mapView.translatesAutoresizingMaskIntoConstraints = false
        
        // ルートビューに追加
        view.addSubview(mapView)
        
        // AutoLayout でフルスクリーンに
        NSLayoutConstraint.activate([
            mapView.topAnchor.constraint(equalTo: view.topAnchor),
            mapView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // PinManager起動
        _ = PinManager.shared
        
        // マネージャ類セットアップ
        setupManagers()
        
        // マップビューやUIのセットアップ
        setupUI()
        setupMapView()
        setupGestures()
        
        // ピンのロードなど非同期処理
        Task {
            do {
                _ = await PinManager.shared.loadPins()
                _ = await FriendManager.shared.loadFriendsFromDynamoDB()
            }
            
            // カスタムのPinViewManagerを使う場合の設定
            PinViewManager.shared.configure(mapView: mapView, containerView: mapView)
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // NavigationBarを隠すなどの処理
        navigationController?.setNavigationBarHidden(true, animated: animated)
        
        // タイマー開始
        startTimer()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        // タイマー停止
        stopTimer()
    }

    // MARK: - Setup Methods
    private func setupManagers() {
        mapManager = MapManager.shared
        mapManager.configure(with: mapView)
        mapManager.delegate = self

        uiSetupManager = UISetupManager()
    }

    private func setupMapView() {
        // アノテーションなどの登録
        mapView.register(MKMarkerAnnotationView.self,
                         forAnnotationViewWithReuseIdentifier: "featureAnnotation")
    }

    private func setupUI() {
        // コンパスボタン
        compassButton = uiSetupManager.setupCompassButton(in: view, mapView: mapView)
        
        // ユーザートラッキングボタン
        userTrackingButton = uiSetupManager.setupUserTrackingButton(in: view,
            target: self, action: #selector(userTrackingButtonTapped))
        
        // Spotifyボタン
        spotifyButton = uiSetupManager.setupSpotifyButton(in: view,
            target: self, action: #selector(spotifyButtonTapped))
        
        // Profileボタン
        profileButton = uiSetupManager.setupProfileButton(in: view,
            target: self, action: #selector(profileButtonTapped))
        
        // Radikoボタン
        radikoButton = uiSetupManager.setupRadikoButton(in: view,
            target: self, action: #selector(radikoButtonTapped))
        
        // テキストフィールド
        destinationTextField = uiSetupManager.setupDestinationTextField(in: view, delegate: self)
    }

    private func setupGestures() {
        // 長押し
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
        longPressGesture.minimumPressDuration = 0.5
        mapView.addGestureRecognizer(longPressGesture)
        
        // ピンチ
        customPinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(handlePinch(_:)))
        mapView.addGestureRecognizer(customPinchGesture)
        
        // パン
        customPanGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        mapView.addGestureRecognizer(customPanGesture)
        
        // 既存のPanGestureがあるならそれを待機させる(衝突回避)
        if let existingPan = mapView.gestureRecognizers?.first(where: {
            $0 is UIPanGestureRecognizer && $0 != customPanGesture
        }) {
            existingPan.require(toFail: customPanGesture)
        }
        
        longPressGesture.delegate = self
        customPinchGesture.delegate = self
        customPanGesture.delegate = self
    }

    // MARK: - Timer
    private func startTimer() {
        timer1 = Timer.scheduledTimer(
            timeInterval: TimeInterval(timer1_duration),
            target: self,
            selector: #selector(timerFired1),
            userInfo: nil,
            repeats: true
        )
    }
    private func stopTimer() {
        timer1?.invalidate()
        timer1 = nil
    }
    @objc private func timerFired1() {
        print("定期処理1が実行されました")
        // 例: Friendのピン同期など
        MapPinFriendOrganizer.shared.Refresh1()
    }

    // MARK: - Actions
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
        
        // ストーリーボードがない場合、別画面を出すなら新たにUIViewController or SwiftUIで書き換えが必要
        // 例としてダミーのアラートを出す
        let alert = UIAlertController(title: "プロフィール",
                                      message: "Storyboardを使わず画面遷移するには新たにコードを書く必要があります。",
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        self.present(alert, animated: true)
    }

    @objc private func spotifyButtonTapped() {
        print("Spotifyボタンがタップされました")
    }

    @objc private func radikoButtonTapped() {
        print("Radikoボタンがタップされました")
    }

    // MARK: - Gesture Handlers
    @objc private func handleLongPress(_ gesture: UILongPressGestureRecognizer) {
        if gesture.state == .began {
            let touchPoint = gesture.location(in: mapView)
            let coord = mapView.convert(touchPoint, toCoordinateFrom: mapView)
            print("長押し座標: \(coord)")
            // 必要に応じて PinManager 呼び出しなど
        }
    }

    @objc private func handlePinch(_ gesture: UIPinchGestureRecognizer) {
        // ピンチの際にユーザートラッキングボタンの表示などを更新
        userTrackingButton.setImage(UIImage(systemName: Constants_Design.userTrackingButtonNone), for: .normal)
    }

    @objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
        // パンの際にユーザートラッキングをオフに
        userTrackingButton.setImage(UIImage(systemName: Constants_Design.userTrackingButtonNone), for: .normal)
    }
}

// MARK: - デリゲート等
extension MapViewController: UITextFieldDelegate {
}

extension MapViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gesture: UIGestureRecognizer,
                           shouldRecognizeSimultaneouslyWith other: UIGestureRecognizer) -> Bool {
        return true
    }
}

/// MapManagerDelegate実装例
extension MapViewController: MapManagerDelegate {
    func mapManager(_ manager: MapManager, didLongPressAt coordinate: CLLocationCoordinate2D?) {
        print("MapManagerDelegate: 長押し地点: \(String(describing: coordinate))")
        if let coord = coordinate {
            PinViewManager.shared.addNewPinView(coordinate: coord)
        }
    }
}

/// UIAdaptivePresentationControllerDelegate 等も必要に応じて
extension MapViewController: UIAdaptivePresentationControllerDelegate {
    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        print("モーダル閉じ")
        view.endEditing(true)
    }
}

/// 新しいピン登録用デリゲート
extension MapViewController: ViewController_PinEdit_Delegate {
    func newPinManagerDidTapPlus(_ controller: ViewController_PinEdit, pinData: Data_Pin) {
        print("Plus button tapped with title : \(pinData.title ?? "") and description : \(pinData.description ?? "")")
        PinManager.shared.addPins([pinData])
        PinManager.shared.saveAllPins()
        PinManager.shared.printPins()
    }
    func newPinManagerDidTapClose(_ controller: ViewController_PinEdit, pinData: Data_Pin) {
        print("Close button tapped")
        PinManager.shared.deletePins([pinData.coordinate])
        PinManager.shared.saveAllPins()
        PinManager.shared.printPins()
    }
}
