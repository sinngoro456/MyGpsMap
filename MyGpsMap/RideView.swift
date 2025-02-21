//
//  RideView.swift
//  MyGpsMap
//
//  Created by 川渕悟郎 on 2025/02/21.
//

import SwiftUI
import MapKit

struct RideView: View {
    @State private var timerCount: Int = 0
    @State private var isTimerRunning: Bool = false
    @State private var carAnnotationData: Data_NewPin? = nil
    @State private var trackingMode = MKUserTrackingMode.follow
    @State private var averageSpeed = 0.0
    @State private var distance = 0.0
    @State private var lapTimes: [Int] = []
    
    private let timer = Timer.publish(every: 1.0, on: .main, in: .common).autoconnect()
    
    private var formattedTime: String {
        formatTime(timerCount)
    }
    
    private func formatTime(_ time: Int) -> String {
        let hours = time / 3600
        let minutes = (time % 3600) / 60
        let seconds = time % 60
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }

    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                // タイマー表示
                VStack(spacing: 0) {
                    Text("タイム")
                        .font(.system(size: 15))
                    Text(formattedTime)
                        .font(.system(size: 70, weight: .regular))
                }
                .frame(height: geometry.size.height * 0.2)
                
                // ラップタイム表示
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(Array(lapTimes.enumerated()), id: \.offset) { index, lapTime in
                            Text("ラップ\(index + 1): \(formatTime(lapTime))")
                                .font(.system(size: 15))
                        }
                    }
                    .padding(.horizontal)
                }
                .frame(height: 30)
                
                // 平均速度、距離
                HStack(spacing: 20) {
                    VStack(alignment: .center, spacing: 0) {
                        Text("平均速度")
                            .font(.system(size: 15))
                        HStack(alignment: .lastTextBaseline, spacing: 2) {
                            Text("\(String(format: "%.1f", averageSpeed))")
                                .font(.system(size: 50, weight: .regular))
                            Text("km/h")
                                .font(.system(size: 20))
                                .offset(y: 5)
                        }
                    }
                    Spacer().frame(width: 10)
                    VStack(alignment: .center, spacing: 0) {
                        Text("距離")
                            .font(.system(size: 15))
                        HStack(alignment: .lastTextBaseline, spacing: 2) {
                            Text("\(String(format: "%.1f", distance))")
                                .font(.system(size: 50, weight: .regular))
                            Text("km")
                                .font(.system(size: 20))
                                .offset(y: 5)
                        }
                    }
                }
                .frame(height: geometry.size.height * 0.15)
                
                // 地図表示
                ZStack {
                    MapViewWrapper(carAnnotationData: $carAnnotationData,
                                   trackingMode: $trackingMode)
                }
                .frame(height: geometry.size.height * 0.5)
                
                Spacer()
                
                // ボタン
                HStack(spacing: 20) {
                    Button(action: {
                        if isTimerRunning {
                            // ラップ
                            lapTimes.append(timerCount)
                        } else {
                            // リセット
                            timerCount = 0
                            lapTimes.removeAll()
                        }
                    }) {
                        Text(isTimerRunning ? "ラップ" : "リセット")
                            .font(.system(size: 18, weight: .medium))
                            .padding()
                            .frame(width: 100)
                            .background(Color.gray.opacity(0.7))
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                    
                    Button(action: {
                        isTimerRunning.toggle()
                    }) {
                        Text(isTimerRunning ? "停止" : "開始")
                            .font(.system(size: 18, weight: .medium))
                            .padding()
                            .frame(width: 100)
                            .background(isTimerRunning ? Color.red.opacity(0.7) : Color.green.opacity(0.7))
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                }
                .padding(.bottom, 20)
            }
            .onReceive(timer) { _ in
                if isTimerRunning {
                    timerCount += 1
                }
            }
        }
    }
}

