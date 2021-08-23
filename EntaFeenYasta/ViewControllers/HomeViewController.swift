//
//  HomeViewController.swift
//  EntaFeenYasta
//
//  Created by Omar Elmofty on 2021-07-04.
//

import UIKit
import FirebaseAuth
import Mapbox
import MapKit

class HomeViewController: UIViewController, MKMapViewDelegate {
//    private var mapView: MGLMapView?
    private var location_updated: Bool = false
    private var mapView: MKMapView!
    @IBOutlet weak var friends_button: UIButton!
    
    	
    override func viewDidLoad() {
        super.viewDidLoad()
        let app_delegate =  UIApplication.shared.delegate as! AppDelegate
        if app_delegate.current_user == nil {
            app_delegate.current_user = User()
        }
        let mapView = MKMapView(frame: view.bounds)
        

        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        mapView.delegate = self
        mapView.showsUserLocation = false
        mapView.setUserTrackingMode(.follow, animated: false)
        mapView.isPitchEnabled = false
        mapView.isRotateEnabled = false

        self.mapView = mapView
        view.addSubview(mapView)
        view.sendSubviewToBack(mapView)
        
        Utilities.styleFilledButton(friends_button)
    }
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
//        self.mapView?.updateUserLocationAnnotationView()

        let user_loc = userLocation.coordinate

        if (!location_updated)
        {
            self.mapView?.setCenter(user_loc, animated: false)
            location_updated = true
        }
        // Update user location on firebase
        let app_delegate =  UIApplication.shared.delegate as! AppDelegate
        app_delegate.current_user!.setLocation(user_loc.latitude, user_loc.longitude)
        try! app_delegate.current_user!.pushToFirebase()
        try! app_delegate.current_user!.populateFriends()
    }
    
}

