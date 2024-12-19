//
//  PinData.swift
//  MyGpsMap
//
//  Created by 川渕悟郎 on 2024/10/07.
//

import CoreLocation
import UIKit

class Data_Pin {
    var coordinate: CLLocationCoordinate2D
    var title: String?
    var description: String?
    var images: [UIImage]
    var date: Date?  // 日付を格納するプロパティを追加
    var category: String?
    var tags: [String]?

    init(coordinate: CLLocationCoordinate2D, title: String?, description: String?, images: [UIImage] = [], date: Date? = nil, category: String?, tags: [String]?) {
        self.coordinate = coordinate
        self.title = title
        self.description = description
        self.images = images
        self.date = date  // 初期化時に日付を設定
        self.category = category
        self.tags = tags
    }
}
