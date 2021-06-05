//
//  ETAEstimator.swift
//  EntaFeenYasta
//
//  Created by Omar Elmofty on 2021-05-22.
//

import Foundation
import MapboxDirections
import MapboxCoreNavigation
import MapboxNavigation

class ETAEstimator {
    // Example of waypoint creation
    //    let origin = Waypoint(coordinate: CLLocationCoordinate2D(latitude: 38.9131752, longitude: -77.0324047), name: "Mapbox")
    //    let destination = Waypoint(coordinate: CLLocationCoordinate2D(latitude: 38.8977, longitude: -77.0365), name: "White House")
    
    func estimateETA(origin : Waypoint, destination : Waypoint, completion: @escaping (TimeInterval) -> Void)
    {
        // Set options
        let routeOptions = NavigationRouteOptions(waypoints: [origin, destination])
	
        Directions.shared.calculate(routeOptions) { [] (session, result) in
            switch result {
                case .failure(let error):
                    print(error.localizedDescription)
                    print("FAILED")
                case .success(let response):
                    guard let route = response.routes?.first else {
                                        return
                                        }
                    print(Thread.current)
                    completion(route.expectedTravelTime)
            }
        }
    }
}
	
