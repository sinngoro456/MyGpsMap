//
//  CustomAnnotation.swift
//  MyGpsMap
//
//  Created by 川渕悟郎 on 2024/10/02.
//

import Foundation
import MapKit

class CustomAnnotation: NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    var title: String?
    var subtitle: String?
    var imageUrl: String?

    init(coordinate: CLLocationCoordinate2D, title: String?, subtitle: String?, imageUrl: String?) {
        self.coordinate = coordinate
        self.title = title
        self.subtitle = subtitle
        self.imageUrl = imageUrl
    }
}
