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
import Firebase

class ViewController: UIViewController, MGLMapViewDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()

        let mapView = MGLMapView(frame: view.bounds)
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        mapView.delegate = self
	
        // Set the map’s center coordinate and zoom level.
        mapView.setCenter(CLLocationCoordinate2D(latitude: 30.039403395357347, longitude: 31.32954873627664), zoomLevel: 13, animated: false)
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        var annotations = [MGLAnnotation]()
        if let user_database = appDelegate.getUserDatabase() {
            annotations = user_database.createHangoutAnnotations("cairo_festival")
            user_database.estimateHangoutETA("cairo_festival")
        }
        mapView.addAnnotations(annotations)
        view.sendSubviewToBack(mapView)
//        view.addSubview(mapView)

    }
    
    func mapView( _ mapView: MGLMapView, imageFor annotation: MGLAnnotation ) -> MGLAnnotationImage? {
        var image_name : String = ""
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        if let user_database = appDelegate.getUserDatabase() {
            if annotation.subtitle == "user" {
                if let title = annotation.title {
                    image_name = user_database.getUserImageName(title ?? "")
                }
            }
            else if annotation.subtitle == "hangout" {
                return nil
            }
        }
        
        var annotationImage : MGLAnnotationImage? = nil
        if let img = UIImage( named: image_name) {
            annotationImage = MGLAnnotationImage( image: img, reuseIdentifier: image_name )
        }
        return annotationImage
    }
	
    func mapView(_ mapView: MGLMapView, didSelect annotation: MGLAnnotation) {
        // Hide the callout view.
        mapView.deselectAnnotation(annotation, animated: false)
        var eta : TimeInterval = 0.0
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        if let user_database = appDelegate.getUserDatabase() {
            if let hangout = user_database.getHangout("cairo_festival") {
                if let user_name = annotation.title {
                    eta = hangout.getUserETA(user_name ?? "")
                }
            }
        }

        // Show an alert containing the annotation's details
        let alert = UIAlertController(title: annotation.title!, message: "Your ETA is \(eta / 60.0) mins", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
// This the old way of creating the map images, found it hard to support clicking etc.
//    func mapView(_ mapView: MGLMapView, didFinishLoading style: MGLStyle) {
//
//        let appDelegate = UIApplication.shared.delegate as! AppDelegate
//
//        if let user_database = appDelegate.getUserDatabase() {
//            let (sources, layers, image_names) = user_database.createHangoutMapMarkers("cairo_festival")
//
//            for i in 0...(sources.count - 1) {
//                if let image = UIImage(named: image_names[i]) {
//                    style.setImage(image, forName: image_names[i])
//                    style.addSource(sources[i])
//                    style.addLayer(layers[i])
//                }
//
//            }
//        }
//        else {
//            print("ERROR USER DATABASE IS NIL")
//        }
//    }
}
