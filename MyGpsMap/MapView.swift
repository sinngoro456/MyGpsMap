//
//  MapView.swift
//  MyGpsMap
//
//  Created by 川渕悟郎 on 2025/02/20.
//

import SwiftUI
import MapKit
import CoreLocation

struct MapViewWrapper: UIViewRepresentable {
    // 親Viewからバインドでもらう
    @Binding var trackingMode: MKUserTrackingMode
    @Binding var editingPin: Data_Pin?
    
    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView(frame: .zero)
        
        // ユーザ位置やコンパスなど、いままでの設定はお好みで
        mapView.showsUserLocation = true
        mapView.showsCompass = false
        mapView.layoutMargins = UIEdgeInsets(top: 0, left: 0, bottom: -30, right: 0)
        mapView.setUserTrackingMode(trackingMode, animated: true)
        
        // カスタムコンパスの追加（省略可）
        let compassButton = MKCompassButton(mapView: mapView)
        compassButton.compassVisibility = .visible
        mapView.addSubview(compassButton)
        compassButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            compassButton.topAnchor.constraint(
                equalTo: mapView.safeAreaLayoutGuide.topAnchor,
                constant: 70
            ),
            compassButton.trailingAnchor.constraint(
                equalTo: mapView.safeAreaLayoutGuide.trailingAnchor,
                constant: -16
            )
        ])
        
        // ロングプレスの設定
        let longPressGesture = UILongPressGestureRecognizer(
            target: context.coordinator,
            action: #selector(Coordinator.handleLongPress(_:))
        )
        mapView.addGestureRecognizer(longPressGesture)
        
        mapView.delegate = context.coordinator
        
        return mapView
    }
    
    // View更新のたびに呼ばれる
    func updateUIView(_ uiView: MKMapView, context: Context) {
        // 既存の注釈を消して、最新の注釈だけ追加
        uiView.removeAnnotations(uiView.annotations)
        
        // newPinData があれば反映
        for pin in PinManager.shared.pins{
            let annotation = MKPointAnnotation()
            annotation.coordinate = pin.coordinate
            uiView.addAnnotation(annotation)
        }
        
        // SwiftUIのトラッキングモードを実際のMKMapViewへ反映
        uiView.setUserTrackingMode(trackingMode, animated: true)
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    // MARK: - Coordinator
    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: MapViewWrapper
        @State private var tempTrackingMode: MKUserTrackingMode = .follow
        init(_ parent: MapViewWrapper) {
            self.parent = parent
        }
        
        // MARK: - Handle Long Press
        @objc func handleLongPress(_ gesture: UILongPressGestureRecognizer) {
            guard gesture.state == .began else { return }
            
            // タップしたスクリーン座標を地図座標に変換
            let mapView = gesture.view as! MKMapView
            let point = gesture.location(in: mapView)
            let coordinate = mapView.convert(point, toCoordinateFrom: mapView)

            parent.editingPin = Data_Pin(
                pin_id: 0,
                coordinate: coordinate,
                title: "",
                description: "",
                color: .purple,
                images: [],
                date: Date(),
                category: "",
                tags: [],
                visibility: "private"
            )
        }
        
        // MARK: - MKMapViewDelegate
        func mapView(_ mapView: MKMapView, didChange mode: MKUserTrackingMode, animated: Bool) {
            tempTrackingMode = mode
        }

        // MARK: - ピンをタップしたとき
        func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
            guard let annotation = view.annotation else { return }
            
            // 例: annotation -> Data_Pin を取り出す（何らかの仕組みが必要）
            // ここではサンプルとしてダミーを生成
            let dummyPin = Data_Pin(
                pin_id: 0,
                coordinate: annotation.coordinate,
                title: "",
                description: "",
                color: .purple,
                images: [],
                date: Date(),
                category: "",
                tags: [],
                visibility: "private"
            )
            
            // SwiftUI の State を更新して、シートを呼び出す
            parent.editingPin = dummyPin
        }
    }
}


struct MapView: View {
    
    @State private var destinationText: String = ""
    @State private var trackingMode = MKUserTrackingMode.follow
    @State private var selectedPinData: Data_Pin? = nil
    @State private var editingPin: Data_Pin? = nil
    
    var body: some View {
        ZStack {
            // トラッキングモードをBindingで渡す
            MapViewWrapper(trackingMode: $trackingMode, editingPin: $editingPin)
            
            VStack {
                // 上部ボタン類
                VStack(spacing: 20) {
                    // 検索テキストフィールド
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                        TextField("目的地を入力", text: $destinationText)
                            .textFieldStyle(PlainTextFieldStyle())
                    }
                    .padding(.vertical, 8)
                    .padding(.horizontal, 12)
                    .background(Color.white.opacity(0.8))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .shadow(radius: 2)
                    
                    HStack {
                        // 左側: 音楽・ラジオボタン
                        HStack {
                            VStack{
                                Button {
                                    print("Spotify tapped")
                                } label: {
                                    Image(systemName: "music.note")
                                        .frame(width: 42, height: 42)
                                        .background(Color.white)
                                        .clipShape(Circle())
                                        .shadow(radius: 2)
                                }
                                Button {
                                    print("Radiko tapped")
                                } label: {
                                    Image(systemName: "radio")
                                        .frame(width: 42, height: 42)
                                        .background(Color.white)
                                        .clipShape(Circle())
                                        .shadow(radius: 2)
                                }
                            }
                            Spacer()
                            VStack{
                                Spacer()
                                    .frame(height: 40)
                                Button {
                                    // トラッキングモードを切り替え
                                    switch trackingMode {
                                    case .none:
                                        trackingMode = .follow
                                    case .follow:
                                        trackingMode = .followWithHeading
                                    case .followWithHeading:
                                        trackingMode = .none
                                    @unknown default:
                                        trackingMode = .follow
                                    }
                                } label: {
                                    Image(systemName: {
                                        switch trackingMode {
                                        case .none: return "location"
                                        case .follow: return "location.fill"
                                        case .followWithHeading: return "location.north.line.fill"
                                        @unknown default: return "location"
                                        }
                                    }())
                                    .frame(width: 42, height: 42)
                                    .background(Color.white)
                                    .clipShape(Circle())
                                    .shadow(radius: 2)
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.top, 20)
                
                Spacer()
            }
        }
        // sheetを定義：selectedPinDataに値がある場合だけ表示
        .sheet(item: $editingPin) { pinData in
            PinEditView(pinData: pinData)
        }
    }
}
