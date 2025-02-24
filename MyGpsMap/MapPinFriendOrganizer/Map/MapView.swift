//
//  MapView.swift
//  MyGpsMap
//
//  Created by 川渕悟郎 on 2025/02/20.
//

import SwiftUI
import MapKit

struct MapView: View {
    
    @State private var destinationText: String = ""
    @State private var trackingMode = MKUserTrackingMode.none
    @State private var selectedPinData: Data_Pin? = nil
    @State private var editingPin: Data_Pin? = nil
    
    var body: some View {
        ZStack {
            // トラッキングモードをBindingで渡す
            MapViewWrapper(trackingMode: $trackingMode, editingPin: $editingPin)
            
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
