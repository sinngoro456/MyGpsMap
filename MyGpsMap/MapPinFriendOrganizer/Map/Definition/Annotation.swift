//
//  Annotation.swift
//  MyGpsMap
//
//  Created by 川渕悟郎 on 2025/03/15.
//

import Foundation
import MapKit

class Annotation: NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    var title: String?
    var subtitle: String?
    var pin: Data_Pin?

    init(pin: Data_Pin) {
        self.coordinate = pin.coordinate
        self.title = pin.title
        self.subtitle = pin.description
        self.pin = pin
    }
}
