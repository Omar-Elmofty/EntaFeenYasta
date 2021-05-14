//
//  MapDelegate.swift
//  EntaFeenYasta
//
//  Created by Omar Elmofty on 2021-05-14.
//

import Foundation
import Mapbox

class MapDelegate: NSObject, MGLMapViewDelegate {
    @objc func mapView(_ mapView: MGLMapView, annotationCanShowCallout annotation: MGLAnnotation) -> Bool {
        // Always allow callouts to popup when annotations are tapped.
        return true
    }

    func mapView(_ mapView: MGLMapView, didSelect annotation: MGLAnnotation) {
    let camera = MGLMapCamera(lookingAtCenter: annotation.coordinate, fromDistance: 4500, pitch: 15, heading: 180)
    mapView.fly(to: camera, withDuration: 4,
    peakAltitude: 3000, completionHandler: nil)
    }
}
