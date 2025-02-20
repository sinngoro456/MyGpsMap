//
//  ContentView.swift
//  MyGpsMap
//
//  Created by 川渕悟郎 on 2025/02/20.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            // ホームタブ
            HomeView()
                .tabItem {
                    // systemImage: "house" が家のアイコン
                    Label("ホーム", systemImage: "house")
                }

            // マップタブ
            MapView()
                .tabItem {
                    // systemImage: "map" が地図アイコン
                    Label("マップ", systemImage: "map")
                }

            // ライドタブ
            RideView()
                .tabItem {
                    // "bicycle" が自転車のアイコン
                    Label("ライド", systemImage: "bicycle")
                }

            // 掲示板タブ
            BoardView()
                .tabItem {
                    // "text.bubble" が吹き出しアイコン
                    Label("掲示板", systemImage: "text.bubble")
                }

            // マイページタブ
            MyPageView()
                .tabItem {
                    // "person" が人物アイコン
                    Label("マイページ", systemImage: "person")
                }
        }
        .accentColor(.blue) // タブアイコンの選択色を設定
        .background(Color.white) // TabView全体の背景を白に設定
    }
}

// 以下、各タブとして表示するViewを最小構成で用意
struct HomeView: View {
    var body: some View {
        Text("ホーム画面です")
            .font(.title)
            .padding()
    }
}

struct RideView: View {
    var body: some View {
        Text("ライド画面です")
            .font(.title)
            .padding()
    }
}

struct BoardView: View {
    var body: some View {
        Text("掲示板画面です")
            .font(.title)
            .padding()
    }
}

struct MyPageView: View {
    var body: some View {
        Text("マイページ画面です")
            .font(.title)
            .padding()
    }
}

