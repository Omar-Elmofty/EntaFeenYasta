//
//  HangoutPickLocationViewController.swift
//  EntaFeenYasta
//
//  Created by Omar Elmofty on 2021-08-16.
//

import UIKit
import MapKit
protocol HandleMapSearch {
    func dropPinZoomIn(placemark:MKPlacemark, center_view: Bool)
}

class HangoutPickLocationViewController: UIViewController, MKMapViewDelegate, UIGestureRecognizerDelegate {

    @IBOutlet weak var accept_button: UIButton!
    @IBOutlet weak var secondary_address_label: UILabel!
    @IBOutlet weak var location_result_view: UIView!
    @IBOutlet weak var primary_address_label: UILabel!
    private var selected_location: String = ""
    let locationManager = CLLocationManager()
    var mapView: MKMapView!
    var resultSearchController:UISearchController? = nil
    var selectedPin:MKPlacemark? = nil
    var current_location: CLLocation?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()

        let locationSearchTable = storyboard!.instantiateViewController(identifier: Constants.Storyboard.location_search_view_controller) as! LocationSearchTableViewController
        resultSearchController = UISearchController(searchResultsController: locationSearchTable)
        resultSearchController?.searchResultsUpdater = locationSearchTable 
        
        let mapView = MKMapView(frame: view.bounds)
        

        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        mapView.delegate = self
        mapView.showsUserLocation = true
        mapView.setUserTrackingMode(.follow, animated: false)
        mapView.isPitchEnabled = false
        mapView.isRotateEnabled = false

        self.mapView = mapView
        view.addSubview(mapView)
        view.sendSubviewToBack(mapView)
        locationSearchTable.mapView = mapView
        locationSearchTable.handleMapSearchDelegate = self
        
        let searchBar = resultSearchController!.searchBar
        searchBar.sizeToFit()
        searchBar.placeholder = "Search for places"
        navigationItem.searchController = resultSearchController
        navigationItem.hidesSearchBarWhenScrolling = false
        
        resultSearchController?.hidesNavigationBarDuringPresentation = false
        definesPresentationContext = true
        
        // Hide the view for now, will enable when needed
        location_result_view.isHidden = true
        locationSearchTable.location_result_view = location_result_view
//        view.isUserInteractionEnabled = true
//        mapView.isUserInteractionEnabled = true
//        location_result_view.isUserInteractionEnabled = true
        
        let gestureRecognizer = UITapGestureRecognizer(target: self,action: #selector(dismissLocationResultView))
        gestureRecognizer.cancelsTouchesInView = false
        gestureRecognizer.delegate = self
        view.addGestureRecognizer(gestureRecognizer)
        
        Utilities.styleFilledButton(accept_button)
    }
    func mapView(_: MKMapView, didSelect: MKAnnotationView)
    {
        let annotation = didSelect.annotation
        primary_address_label.text = annotation?.title ?? nil
        secondary_address_label.text = annotation?.subtitle ?? nil

        if let first = primary_address_label.text {
            selected_location = first
            if let second = secondary_address_label.text {
                selected_location += ", " + second
            }
        }
        location_result_view.isHidden = false
    }
    

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                           shouldReceive touch: UITouch) -> Bool {
      return (touch.view != location_result_view)
    }
    @objc func dismissLocationResultView() {
        if (!location_result_view.isHidden)
        {
            location_result_view.isHidden = true
        }
    }
    @IBAction func acceptButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
        // Update the label of the parent view controller
        let nc = presentingViewController as! UINavigationController
        let vc = nc.viewControllers[0] as! HangoutFirstPageViewController
        vc.updateLocationLabel(selected_location)
    }
}

extension HangoutPickLocationViewController : CLLocationManagerDelegate {
    private func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            locationManager.requestLocation()
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            current_location = location
        }
    }
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("error:: \(error)")
    }
}

extension HangoutPickLocationViewController: HandleMapSearch {
    
    func dropPinZoomIn(placemark:MKPlacemark, center_view: Bool){
        // cache the pin
        selectedPin = placemark
        // clear existing pins
        let annotation = MKPointAnnotation()
        annotation.coordinate = placemark.coordinate
        annotation.title = placemark.name
        
        if let city = placemark.locality, let state = placemark.administrativeArea {
            annotation.subtitle = "\(city) \(state)"
        }
        mapView.addAnnotation(annotation)
        if (center_view)
        {
            let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
            let region = MKCoordinateRegion(center: placemark.coordinate, span: span)
            mapView.setRegion(region, animated: true)
            self.primary_address_label.text = annotation.title
            self.secondary_address_label.text = annotation.subtitle
            if let first = self.primary_address_label.text {
                selected_location = first
                if let second = self.secondary_address_label.text {
                    selected_location += ", " + second
                }
            }
            
            self.location_result_view!.isHidden = false
        }
        else
        {
            if let current_location = current_location
            {
                print("Setting current Location")
                let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                let region = MKCoordinateRegion(center: current_location.coordinate, span: span)
                mapView.setRegion(region, animated: true)
            }
        }
    }
}
