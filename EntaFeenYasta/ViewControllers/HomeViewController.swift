//
//  HomeViewController.swift
//  EntaFeenYasta
//
//  Created by Omar Elmofty on 2021-07-04.
//

import UIKit
import FirebaseAuth
import Mapbox

class HomeViewController: UIViewController, MGLMapViewDelegate {
    private var mapView: MGLMapView?
    private var location_updated: Bool = false
    override func viewDidLoad() {
        super.viewDidLoad()
        let app_delegate =  UIApplication.shared.delegate as! AppDelegate
        if app_delegate.current_user == nil {
            app_delegate.current_user = User()
        }

        let mapView = MGLMapView(frame: view.bounds)
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        mapView.delegate = self
        mapView.showsUserLocation = false
        mapView.setUserTrackingMode(.follow, animated: false) {
        }
        mapView.zoomLevel = 13
        mapView.isPitchEnabled = false
        mapView.isRotateEnabled = false
        
        self.mapView = mapView
        view.addSubview(mapView)
        view.sendSubviewToBack(mapView)
    }
    func mapView(_ mapView: MGLMapView, didUpdate userLocation: MGLUserLocation?) {
        self.mapView?.updateUserLocationAnnotationView()
        
        let user_loc = userLocation?.coordinate ?? CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0)
        
        if (!location_updated)
        {
            self.mapView?.setCenter(user_loc, animated: false)
            location_updated = true
        }
        // Update user location on firebase
        let app_delegate =  UIApplication.shared.delegate as! AppDelegate
        app_delegate.current_user!.setLocation(user_loc.latitude, user_loc.longitude)
        try! app_delegate.current_user!.pushToFirebase()
    }
}
