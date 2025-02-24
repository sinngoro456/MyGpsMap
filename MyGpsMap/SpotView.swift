//
//  SpotView.swift
//  MyGpsMap
//
//  Created by 川渕悟郎 on 2025/02/25.
//

import CoreLocation
import SwiftUI

// スポット画面
struct SpotView: View {
    @State private var searchText: String = ""
    @State private var selectedDistance: DistanceFilter = .all
    @State private var selectedCategory: CategoryFilter = .all
    @State var userLocation: CLLocationCoordinate2D? = nil

    // スポットのサンプルデータ
    @State private var spots: [Spot] = [
        Spot(name: "東京タワー", description: "有名な観光地です", coordinate: .init(latitude: 35.6586, longitude: 139.7454), category: .landmark),
        Spot(name: "浅草寺", description: "歴史的な寺院", coordinate: .init(latitude: 35.7148, longitude: 139.7967), category: .landmark),
        Spot(name: "渋谷スクランブル交差点", description: "賑やかな交差点", coordinate: .init(latitude: 35.6595, longitude: 139.7006), category: .landmark),
        Spot(name: "ローソン 渋谷店", description: "コンビニ", coordinate: .init(latitude: 35.6615, longitude: 139.6985), category: .convenienceStore),
        Spot(name: "スターバックス 新宿店", description: "カフェ", coordinate: .init(latitude: 35.6895, longitude: 139.7007), category: .food)
    ]

    var body: some View {
        NavigationView { // NavigationViewでラップ
            VStack {
                // 検索バー
                TextField("スポットを検索", text: $searchText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()

                // フィルター選択
                HStack {
                    Picker("距離", selection: $selectedDistance) {
                        ForEach(DistanceFilter.allCases, id: \.self) { distance in
                            Text(distance.rawValue).tag(distance)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())

                    Picker("カテゴリー", selection: $selectedCategory) {
                        ForEach(CategoryFilter.allCases, id: \.self) { category in
                            Text(category.rawValue).tag(category)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                }
                .padding(.horizontal)

                // スポットリスト
                List {
                    ForEach(filteredSpots) { spot in
                        VStack(alignment: .leading) {
                            Text(spot.name)
                                .font(.headline)
                            Text(spot.description)
                                .font(.subheadline)
                                .foregroundColor(.gray)
                            Text("カテゴリー: \(spot.category.rawValue)")
                                .font(.caption)
                                .foregroundColor(.blue)
                            if let distance = spot.distanceFromUser {
                                Text("距離: \(String(format: "%.2f", distance)) km")
                                    .font(.caption)
                                    .foregroundColor(.green)
                            }
                        }
                    }
                }
            }
            .navigationTitle("スポット")
        }
        .onAppear {
            // ユーザーの現在地を取得（シミュレーション）
            userLocation = CLLocationCoordinate2D(latitude: 35.6895, longitude: 139.6917) // 東京駅付近
        }
    }

    // フィルタリングされたスポット
    var filteredSpots: [Spot] {
        spots.filter { spot in
            // 検索テキストでフィルタリング
            let matchesSearchText = searchText.isEmpty || spot.name.localizedCaseInsensitiveContains(searchText)

            // 距離でフィルタリング
            let matchesDistance: Bool
            if let userLocation = userLocation {
                let spotLocation = CLLocation(latitude: spot.coordinate.latitude, longitude: spot.coordinate.longitude)
                let userCLLocation = CLLocation(latitude: userLocation.latitude, longitude: userLocation.longitude)
                let distance = spotLocation.distance(from: userCLLocation) / 1000 // km単位に変換

                switch selectedDistance {
                case .all:
                    matchesDistance = true
                case .near:
                    matchesDistance = distance <= 1
                case .medium:
                    matchesDistance = distance > 1 && distance <= 10
                case .far:
                    matchesDistance = distance > 10 && distance <= 50
                case .veryFar:
                    matchesDistance = distance > 50 && distance <= 100
                }
            } else {
                matchesDistance = true
            }

            // カテゴリーでフィルタリング
            let matchesCategory = selectedCategory == .all || spot.category == selectedCategory

            return matchesSearchText && matchesDistance && matchesCategory
        }
    }
}

// スポットのデータモデル
struct Spot: Identifiable {
    let id = UUID()
    let name: String
    let description: String
    let coordinate: CLLocationCoordinate2D
    let category: CategoryFilter

    // ユーザーからの距離を計算
    var distanceFromUser: Double? {
        guard let userLocation = SpotView().userLocation else { return nil }
        let spotLocation = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        let userCLLocation = CLLocation(latitude: userLocation.latitude, longitude: userLocation.longitude)
        return spotLocation.distance(from: userCLLocation) / 1000 // km単位
    }
}

// 距離フィルター
enum DistanceFilter: String, CaseIterable {
    case all = "すべて"
    case near = "~1km"
    case medium = "~10km"
    case far = "~50km"
    case veryFar = "~100km"
}

// カテゴリーフィルター
enum CategoryFilter: String, CaseIterable {
    case all = "すべて"
    case landmark = "観光名所"
    case food = "フード"
    case convenienceStore = "コンビニ"
}
