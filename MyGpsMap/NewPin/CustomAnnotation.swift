//
//  CustomAnnotation.swift
//  MyGpsMap
//
//  Created by 川渕悟郎 on 2024/10/07.
//

import MapKit

class CustomAnnotation: NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    var title: String?
    var subtitle: String?
    var image: UIImage
    
    init(coordinate: CLLocationCoordinate2D, title: String, subtitle: String, image: UIImage) {
        self.coordinate = coordinate
        self.title = title
        self.subtitle = subtitle
        self.image = image
    }
}
