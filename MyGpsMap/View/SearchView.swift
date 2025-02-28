//
//  SearchView.swift
//  MyGpsMap
//
//  Created by 川渕悟郎 on 2025/02/25.
//

import SwiftUI
import MapKit

struct SearchView: View {
    @State private var searchText = ""
    @State private var searchResults: [MKMapItem] = []
    @Binding var searchCoordinate: CLLocationCoordinate2D?
    @Environment(\.presentationMode) var presentationMode
    @FocusState private var isTextFieldFocused: Bool  // フォーカス状態を管理

    var body: some View {
        VStack {
            TextField("Search", text: $searchText, onCommit: {
                performSearch()
            })
            .textFieldStyle(RoundedBorderTextFieldStyle())
            .padding()
            .focused($isTextFieldFocused)  // フォーカス制御
            .onAppear {
                isTextFieldFocused = true  // 画面表示時にフォーカス
            }

            List(searchResults, id: \.self) { item in
                HStack {
                    // アイコンを表示
                    Image(systemName: IconForMapItem.iconForMapItem(item))
                        .frame(width: 24, height: 24)
                        .foregroundColor(.blue)
                    
                    VStack(alignment: .leading) {
                        Text(item.name ?? "Unknown")
                        Text(item.placemark.title ?? "")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                }
                .onTapGesture {
                    // 選択された場所にマップを移動
                    searchCoordinate = item.placemark.coordinate
                    presentationMode.wrappedValue.dismiss()
                }
            }
        }
        .onChange(of: searchText) { newValue in
            performSearch()
        }
    }

    private func performSearch() {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = searchText

        let search = MKLocalSearch(request: request)
        search.start { response, error in
            guard let response = response else {
                print("Error: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            searchResults = response.mapItems
        }
    }
}
