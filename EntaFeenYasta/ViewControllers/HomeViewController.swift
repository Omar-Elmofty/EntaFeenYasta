//
//  HomeViewController.swift
//  EntaFeenYasta
//
//  Created by Omar Elmofty on 2021-07-04.
//

import UIKit
import FirebaseAuth
import CoreLocation
import Mapbox

class HomeViewController: UIViewController, CLLocationManagerDelegate, MGLMapViewDelegate {
    private var mapView: MGLMapView?
    private let locationManager = CLLocationManager()
    private var current_location : CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0)
    private var location_updated : Bool = false
    @IBOutlet weak var test_label: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let app_delegate =  UIApplication.shared.delegate as! AppDelegate
        if app_delegate.current_user == nil {
            app_delegate.current_user = User()
        }
        test_label.text = app_delegate.current_user!.getName()

        // Ask for Authorisation from the User.
        self.locationManager.requestAlwaysAuthorization()

        // For use in foreground
        self.locationManager.requestWhenInUseAuthorization()

        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
        
        let mapView = MGLMapView(frame: view.bounds)
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        mapView.delegate = self
        mapView.showsUserLocation = false
        mapView.setCenter(current_location, animated: true)
        mapView.setUserTrackingMode(.follow, animated: false) {
        }
        mapView.zoomLevel = 13
        
        self.mapView = mapView
        view.addSubview(mapView)
    }
    func mapView(_ mapView: MGLMapView, didUpdate userLocation: MGLUserLocation?) {
        self.mapView?.updateUserLocationAnnotationView()
        if (!location_updated)
        {
            self.mapView?.setCenter(userLocation?.coordinate ?? current_location, animated: false)
            location_updated = true
        }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else { return }
        current_location = locValue
        print("locations = \(locValue.latitude) \(locValue.longitude)")
    }

}
