//
//  PinData.swift
//  MyGpsMap
//
//  Created by 川渕悟郎 on 2024/10/07.
//

import Foundation
import CoreLocation
import UIKit

class PinData {
    var coordinate: CLLocationCoordinate2D
    var title: String?
    var description: String?
    var images: [UIImage]

    init(coordinate: CLLocationCoordinate2D, title: String?, description: String?, images: [UIImage] = []) {
        self.coordinate = coordinate
        self.title = title
        self.description = description
        self.images = images
    }
}
