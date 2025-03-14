//
//  AnnotationView.swift
//  MyGpsMap
//
//  Created by 川渕悟郎 on 2025/03/14.
//

import Foundation
import MapKit

class Annotation: MKPointAnnotation {
    var pin: Data_Pin?

    init(pin: Data_Pin) {
        self.pin = pin
        super.init()
        self.coordinate = pin.coordinate
        self.title = pin.title
    }
}
