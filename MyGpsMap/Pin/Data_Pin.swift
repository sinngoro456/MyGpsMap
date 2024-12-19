//
//  PinData.swift
//  MyGpsMap
//
//  Created by 川渕悟郎 on 2024/10/07.
//

import CoreLocation
import UIKit

class Data_Pin {
    var id: Int?
    var coordinate: CLLocationCoordinate2D
    var title: String?
    var description: String?
    var color: UIColor?
    var images: [UIImage]
    var date: Date?  // 日付を格納するプロパティを追加
    var category: String?
    var tags: [String]?

    init(id: Int? = nil, coordinate: CLLocationCoordinate2D, title: String? = "新しいピン", description: String? = nil, color: UIColor? = .orange, images: [UIImage] = [], date: Date? = nil, category: String? = nil, tags: [String]? = nil) {
        self.id = id ?? 0  // idがnilの場合は0を設定
        self.coordinate = coordinate
        self.title = title
        self.description = description
        self.color = color ?? .orange  // colorがnilの場合はデフォルトのオレンジを設定
        self.images = images
        self.date = date  // 初期化時に日付を設定
        self.category = category
        self.tags = tags
    }
}
