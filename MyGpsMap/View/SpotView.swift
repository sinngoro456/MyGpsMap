//
//  SpotView.swift
//  MyGpsMap
//
//  Created by 川渕悟郎 on 2025/02/25.
// 

import SwiftUI
import CoreLocation

// 場所の情報を表すモデル
struct FoursquarePlace: Identifiable, Decodable {
    let fsq_id: String
    let name: String
    let location: FoursquareLocation
    let categories: [FoursquareCategory]
    
    // Identifiableに準拠するためにidをfsq_idにマッピング
    var id: String { fsq_id }
    
    var primaryCategory: String {
        return categories.first?.name ?? "Unknown"
    }
}

struct FoursquareLocation: Decodable {
    let formatted_address: String?
    let locality: String?
    let region: String?
}

struct FoursquareCategory: Decodable {
    let name: String
}

struct FoursquareIcon: Decodable {
    let prefix: String
    let suffix: String
}


// APIレスポンスのモデル
struct FoursquareNearbyResponse: Decodable {
    let results: [FoursquarePlace]
}

// 写真の情報を表すモデル
struct FoursquarePhoto: Identifiable, Decodable {
    let id: String
    let prefix: String
    let suffix: String
    let width: Int
    let height: Int
    
    var imageUrl: String {
        return "\(prefix)original\(suffix)"
    }
}

struct FoursquarePhotoResponse: Decodable {
    let photos: [FoursquarePhoto]
}

class FoursquareService {
    private let apiKey = ""
    
    // 現在地近くの場所を取得
    func fetchNearbyPlaces(location: CLLocationCoordinate2D, completion: @escaping ([FoursquarePlace]?) -> Void) {
            let urlString = "https://api.foursquare.com/v3/places/nearby?ll=\(location.latitude),\(location.longitude)"
            guard let url = URL(string: urlString) else {
                completion(nil)
                return
            }
            
            var request = URLRequest(url: url)
            request.setValue(apiKey, forHTTPHeaderField: "Authorization")
            request.setValue("application/json", forHTTPHeaderField: "accept")
            
            URLSession.shared.dataTask(with: request) { data, response, error in
                guard let data = data, error == nil else {
                    completion(nil)
                    return
                }
                
                // // デバッグ用: APIレスポンスを出力
                // if let jsonString = String(data: data, encoding: .utf8) {
                //     print("APIレスポンス: \(jsonString)")
                // }
                
                // FoursquareNearbyResponseをデコード
                do {
                    let decodedResponse = try JSONDecoder().decode(FoursquareNearbyResponse.self, from: data)
                    completion(decodedResponse.results)
                } catch {
                    print("デコードに失敗しました: \(error)")
                    completion(nil)
                }
            }.resume()
        }
    
    func fetchPhotos(fsqId: String, completion: @escaping ([FoursquarePhoto]?) -> Void) {
        let urlString = "https://api.foursquare.com/v3/places/\(fsqId)/photos"
        guard let url = URL(string: urlString) else {
            completion(nil)
            return
        }
        
        var request = URLRequest(url: url)
        request.setValue(apiKey, forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "accept")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                completion(nil)
                return
            }
            
            // // デバッグ用: APIレスポンスを出力
            // if let jsonString = String(data: data, encoding: .utf8) {
            //     print("APIレスポンス: \(jsonString)")
            // }
            
            // 直接 [FoursquarePhoto] としてデコード
            do {
                let decodedResponse = try JSONDecoder().decode([FoursquarePhoto].self, from: data)
                completion(decodedResponse)
            } catch {
                print("デコードに失敗しました: \(error)")
                completion(nil)
            }
        }.resume()
    }
}

struct SpotView: View {
    @State private var searchText: String = ""
    @State private var userLocation: CLLocationCoordinate2D? = nil
    @State private var places: [FoursquarePlace] = []
    @State private var photos: [String: [FoursquarePhoto]] = [:] // Key: fsq_id, Value: 写真の配列
    
    private let foursquareService = FoursquareService()
    
    var body: some View {
        VStack {
            // 検索バー
            TextField("スポットを検索", text: $searchText)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            // スクロールビューで場所と写真を表示
            ScrollView {
                VStack(spacing: 20) {
                    ForEach(places) { place in
                        VStack(alignment: .leading, spacing: 10) {
                            Text(place.name)
                                .font(.headline)
                            Text(place.primaryCategory)
                                .font(.subheadline)
                            Text(place.location.formatted_address ?? "住所不明")
                                .font(.caption)
                            
                            // 写真を表示
                            if let placePhotos = photos[place.id] {
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack {
                                        ForEach(placePhotos) { photo in
                                            AsyncImage(url: URL(string: photo.imageUrl)) { image in
                                                image.resizable()
                                                    .aspectRatio(contentMode: .fit)
                                                    .frame(height: 150)
                                                    .cornerRadius(10)
                                            } placeholder: {
                                                ProgressView()
                                            }
                                        }
                                    }
                                }
                            } else {
                                ProgressView()
                            }
                        }
                        .padding()
                        .background(Color(.systemBackground))
                        .cornerRadius(10)
                        .shadow(radius: 5)
                    }
                }
                .padding()
            }
        }
        .navigationTitle("スポット")
        .onAppear {
            // ユーザーの現在地を取得（シミュレーション）
            userLocation = CLLocationCoordinate2D(latitude: LocationManager.shared.currentCoordinate?.latitude ?? 35.681236, longitude: LocationManager.shared.currentCoordinate?.longitude ?? 139.767125)
            
            // 現在地近くの場所を取得
            if let location = userLocation {
                fetchNearbyPlaces(location: location)
            }
        }
    }
    
    private func fetchNearbyPlaces(location: CLLocationCoordinate2D) {
        foursquareService.fetchNearbyPlaces(location: location) { fetchedPlaces in
            if let fetchedPlaces = fetchedPlaces {
                places = fetchedPlaces
                
                // 各場所の写真を取得
                for place in fetchedPlaces {
                    foursquareService.fetchPhotos(fsqId: place.id) { fetchedPhotos in
                        if let fetchedPhotos = fetchedPhotos {
                            photos[place.id] = fetchedPhotos
                        }
                    }
                }
            }
        }
    }
}
