//
//  RideView.swift
//  MyGpsMap
//
//  Created by 川渕悟郎 on 2025/02/21.
//

import SwiftUI
import MapKit

struct RideView: View {
    /// タイマー表示用
    @State private var timerCount: Int = 0
    /// タイマーが動いているかどうか
    @State private var isTimerRunning: Bool = false
    
    /// SwiftUIのTimer publisher
    private let timer = Timer.publish(every: 1.0, on: .main, in: .common).autoconnect()

    var body: some View {
        VStack(spacing: 0) {
            
            // --- 1) 上: 地図 (UIViewRepresentable) ---
            ZStack {
                // MapViewWrapper: MKMapView をラップしたビュー
                MapViewWrapper()
                
                // ここに、もし上部にテキストフィールドやボタンを重ねたい場合は
                // ZStack内でさらにVStackなどを置いてOK
            }
            .frame(height: 300) // 上半分の高さを固定or可変
            
            // --- 2) 下: タイマーUI ---
            VStack {
                Text("Timer: \(timerCount)秒")
                    .font(.largeTitle)
                    .padding(.top, 20)
                
                HStack {
                    Button(action: {
                        isTimerRunning = true
                    }) {
                        Text("Start")
                            .padding()
                            .background(Color.blue.opacity(0.7))
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                    
                    Button(action: {
                        isTimerRunning = false
                    }) {
                        Text("Stop")
                            .padding()
                            .background(Color.red.opacity(0.7))
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                    
                    Button(action: {
                        timerCount = 0
                    }) {
                        Text("Reset")
                            .padding()
                            .background(Color.gray.opacity(0.7))
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                }
                .padding(.bottom, 20)
            }
            .frame(maxWidth: .infinity)
            .background(Color(UIColor.systemBackground))
        }
        // --- 3) タイマーを受け取り、カウントを進める ---
        .onReceive(timer) { _ in
            if isTimerRunning {
                timerCount += 1
            }
        }
    }
}

