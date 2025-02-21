//
//  MapView.swift
//  MyGpsMap
//
//  Created by 川渕悟郎 on 2025/02/20.
//

import SwiftUI
import MapKit

struct MapViewWrapper: UIViewRepresentable {
    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView(frame: .zero)
        mapView.showsUserLocation = true
        mapView.register(MKMarkerAnnotationView.self, forAnnotationViewWithReuseIdentifier: "featureAnnotation")
        mapView.layoutMargins = UIEdgeInsets(top: 0, left: 0, bottom: -30, right: 0)
        let longPressGesture = UILongPressGestureRecognizer(
            target: context.coordinator,
            action: #selector(Coordinator.handleLongPress(_:))
        )
        mapView.addGestureRecognizer(longPressGesture)
        
        mapView.delegate = context.coordinator
        // 1) デフォルトコンパス非表示
        mapView.showsCompass = false
        
        // 2) カスタムコンパスボタン作成
        let compassButton = MKCompassButton(mapView: mapView)
        compassButton.compassVisibility = .visible
        
        // 3) mapView のサブビューとして追加
        mapView.addSubview(compassButton)
        
        // 4) Auto Layout constraints で位置指定（例: 右上）
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
        return mapView
    }
    
    func updateUIView(_ uiView: MKMapView, context: Context) {
        // 更新処理はここに
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: MapViewWrapper  // ★ここをMapViewWrapperに
        
        var isInitialLoad = true
        
        init(_ parent: MapViewWrapper) {
            self.parent = parent
        }
        
        @objc func handleLongPress(_ gesture: UILongPressGestureRecognizer) {
            if gesture.state == .began {
                print("Long Press Detected")
            }
        }
        
        func mapViewDidFinishLoadingMap(_ mapView: MKMapView) {
            if isInitialLoad {
                centerMapOnUserLocation(mapView)
                isInitialLoad = false
            }
        }
        
        private func centerMapOnUserLocation(_ mapView: MKMapView) {
            if let userLocation = mapView.userLocation.location {
                let region = MKCoordinateRegion(
                    center: userLocation.coordinate,
                    latitudinalMeters: 1000,
                    longitudinalMeters: 1000
                )
                mapView.setRegion(region, animated: true)
            }
        }
    }
}


struct MapView: View {
    
    @State private var destinationText: String = ""
    @State private var trackingMode = MKUserTrackingMode.none
    
    var body: some View {
        ZStack {
            MapViewWrapper()  // ← 先ほど作った UIViewRepresentable
            
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
                        // 左側: コンパス/トラッキング
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
                                    switch trackingMode {
                                    case .none:
                                        trackingMode = .follow
                                    case .follow:
                                        trackingMode = .followWithHeading
                                    case .followWithHeading:
                                        trackingMode = .none
                                    @unknown default:
                                        trackingMode = .none
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
    }
}
