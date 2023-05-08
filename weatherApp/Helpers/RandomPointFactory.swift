//
//  RandomPointFactory.swift
//  weatherApp
//
//  Created by Shamil Ashurilov on 07.05.2023.
//

import UIKit
import MapKit

protocol RandomPoint {
    static func createRandomPoint() -> MKPointAnnotation
}

final class RandomPointFactory: RandomPoint {
    static func createRandomPoint() -> MKPointAnnotation {
        let point = MKPointAnnotation()
        let randomLat = Double.random(in: -90...90)
        let randomLon = Double.random(in: -180...180)
        point.coordinate.latitude = randomLat
        point.coordinate.longitude = randomLon
        return point
    }
}
