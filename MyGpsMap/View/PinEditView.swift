//
//  PinEditView.swift
//  MyGpsMap
//
//  Created by 川渕悟郎 on 2025/02/22.
//

import SwiftUI

struct PinEditView: View {
    let pinData: Data_Pin
    
    @State private var localTitle: String = ""
    @State private var localDescription: String = ""
    @State private var localDate: Date = Date()
    @State private var localIsPublic: Bool = false
    @State private var localImages: [UIImage] = []
    
    // 追加：ImagePicker 用の状態変数
    @State private var showingImagePicker = false
    @State private var inputImage: UIImage?
    
    @Environment(\.dismiss) private var dismiss
    
    init(pinData: Data_Pin) {
        self.pinData = pinData
        _localTitle = State(initialValue: pinData.title ?? "")
        _localDescription = State(initialValue: pinData.description ?? "")
        _localDate = State(initialValue: pinData.date ?? Date())
        _localIsPublic = State(initialValue: (pinData.visibility == "public"))
        _localImages = State(initialValue: pinData.images)
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("基本情報")) {
                    TextField("タイトル", text: $localTitle)
                    TextField("コメント", text: $localDescription)
                    
                    DatePicker("日付", selection: $localDate, displayedComponents: .date)
                    
                    Toggle(isOn: $localIsPublic) {
                        Text(localIsPublic ? "公開" : "非公開")
                    }
                }
                
                Section(header: Text("画像")) {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            // 既存の画像プレビュー
                            ForEach(Array(localImages.enumerated()), id: \.offset) { index, image in
                                Image(uiImage: image)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 80, height: 80)
                                    .clipped()
                                    .onTapGesture {
                                        // 画像をタップで削除する例
                                        localImages.remove(at: index)
                                    }
                            }
                            // 画像追加ボタン
                            Button {
                                showingImagePicker = true
                            } label: {
                                Image(systemName: "plus")
                                    .foregroundColor(.blue)
                                    .frame(width: 80, height: 80)
                                    .background(Color.gray.opacity(0.2))
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                            }
                        }
                    }
                }
            }
            .navigationBarTitle("ピンを編集", displayMode: .inline)
            .navigationBarItems(
                leading: Button("削除") {
                    deleteToPinData()
                    dismiss()
                },
                trailing: Button("保存") {
                    saveToPinData()
                    dismiss()
                }
            )
            // 画像ピッカーをシート表示
            .sheet(isPresented: $showingImagePicker) {
                ImagePicker(image: $inputImage)
            }
            // 画像が更新されたら配列に追加
            .onChange(of: inputImage) { newValue in
                guard let newValue = newValue else { return }
                localImages.append(newValue)
            }
        }
    }
    
    private func saveToPinData() {
        pinData.title = localTitle
        pinData.description = localDescription
        pinData.date = localDate
        pinData.visibility = localIsPublic ? "public" : "private"
        pinData.images = localImages
        PinManager.shared.addPins([pinData])
        PinManager.shared.saveAllPins()
    }
    
    private func deleteToPinData() {
        PinManager.shared.deletePins([pinData])
        PinManager.shared.saveAllPins()
    }
}
