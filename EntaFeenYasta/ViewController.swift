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

class ViewController: UIViewController, MGLMapViewDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let mapView = MGLMapView(frame: view.bounds)
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        mapView.delegate = self
         
        // Set the map’s center coordinate and zoom level.
        mapView.setCenter(CLLocationCoordinate2D(latitude: 41.8864, longitude: -87.7135), zoomLevel: 13, animated: false)
        view.addSubview(mapView)
        
    }


    func mapView(_ mapView: MGLMapView, didFinishLoading style: MGLStyle) {

        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        for n in 0...2
        {
            let map_marker = appDelegate.map_markers_[n]
            do {
                let (shapeSource, shapeLayer) = try map_marker.createMapMarker()
                
                var image_name : String = ""
                if (!map_marker.get("image_name", &image_name))
                {
                    throw AppError.runtimeError("Image name doesn't exist")
                }
                // Add the image to the style's sprite
                if let image = UIImage(named: image_name) {
                    style.setImage(image, forName: image_name)
                }
                
                // Add the source and style layer to the map
                style.addSource(shapeSource)
                style.addLayer(shapeLayer)
            }
            catch
            {
                print("Error encountered")
            }
        }
        
    }
}


