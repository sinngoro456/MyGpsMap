//
//  MapView.swift
//  MyGpsMap
//
//  Created by 川渕悟郎 on 2025/02/20.
//

import SwiftUI
import MapKit

struct MapView: View {
    @StateObject private var locationManager = LocationManager()
    @State private var trackingMode = MKUserTrackingMode.none
    @State private var selectedPinData: Data_Pin? = nil
    @State private var editingPin: Data_Pin? = nil
    @State private var isSearchViewPresented = false // 検索画面の表示状態を管理
    @State private var searchCoordinate: CLLocationCoordinate2D? = nil // 検索結果の座標を管理
    
    var body: some View {
        ZStack {
            // トラッキングモードをBindingで渡す
            MapViewWrapper(trackingMode: $trackingMode, editingPin: $editingPin, searchCoordinate: $searchCoordinate)
            
            VStack {
                // 上部ボタン類
                VStack(spacing: 20) {
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
                                Spacer()
                                    .frame(height: 40)
                            }
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.top, 20)
                
                Spacer()
                                
                // 右下に検索ボタンを追加
                HStack {
                    Spacer()
                    Button(action: {
                        isSearchViewPresented = true
                    }) {
                        Image(systemName: "magnifyingglass")
                            .frame(width: 42, height: 42)
                            .background(Color.white)
                            .clipShape(Circle())
                            .shadow(radius: 2)
                    }
                    .padding(.trailing, 20)
                    .padding(.bottom, 20)
                }
            }
        }
        .onAppear {
            locationManager.requestLocationPermission() // 位置情報の許可をリクエスト
        }
        // sheetを定義：editingPinに値がある場合だけ表示
        .sheet(item: $editingPin) { pinData in
            PinEditView(pinData: pinData)
        }
        // 検索画面をモーダル表示
        .sheet(isPresented: $isSearchViewPresented) {
            SearchView(searchCoordinate: $searchCoordinate)
        }
    }
}
