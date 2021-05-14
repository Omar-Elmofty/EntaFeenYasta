//
//  ViewController.swift
//  EntaFeenYasta
//
//  Created by Omar Elmofty on 2021-05-13.
//
// This is a comment by Meligi
// This is a comment by Omar


import UIKit
import Mapbox


class ViewController: UIViewController {
    // Map Delegate
    let map_delegate_ = MapDelegate()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        let url = URL(string: "mapbox://styles/mapbox/streets-v11")
        let mapView = MGLMapView(frame: view.bounds, styleURL: url)
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        mapView.setCenter(CLLocationCoordinate2D(latitude: 40.77014, longitude: -73.97480), zoomLevel: 9, animated: false)
        // Can use other default styles check documentation
//        mapView.styleURL = MGLStyle.satelliteStyleURL
        
        let annotation = MGLPointAnnotation()
        annotation.coordinate = CLLocationCoordinate2D(latitude: 40.77014, longitude: -73.97480)
        annotation.title = "Central Park"
        annotation.subtitle = "The biggest park in New York City!"
        mapView.addAnnotation(annotation)
        mapView.delegate = map_delegate_
        
        // Allow the map view to display the user's location
        mapView.showsUserLocation = true

        view.addSubview(mapView)
        view.sendSubviewToBack(mapView)
    }


}

