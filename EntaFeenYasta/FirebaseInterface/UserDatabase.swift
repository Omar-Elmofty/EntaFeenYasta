//
//  UserDatabase.swift
//  EntaFeenYasta
//
//  Created by Omar Elmofty on 2021-05-23.
//

import Foundation
import Mapbox
import MapboxDirections
import MapboxCoreNavigation
import MapboxNavigation

struct UsersInfo : Codable
{
    var users_info : [UserInfo]
    var hangouts : [HangoutInfo]
}

class UserDataBase : AttributeHandler
{
    private var user_names_ : Set<String> = []
    private var users_map_ : [String : User] = [:]
    private var hangouts_names_ : Set<String> = []
    private var hangouts_map_ : [String : Hangout] = [:]
    private var eta_estimator_ = ETAEstimator()
    
    init(json_dir : String) throws
    {
        let json_data = try! Data(contentsOf: URL(fileURLWithPath: json_dir), options: .mappedIfSafe)
        let raw_users_info = try! JSONDecoder().decode(UsersInfo.self, from: json_data)

        // Create user objects
        for info in raw_users_info.users_info {
            users_map_[info.name] = User(user_info : info)
            user_names_.insert(info.name)
        }

        // Validate friends of user objects are correct
        for (_, user) in users_map_ {
            let friends = user.getFriends()
            for friend in friends {
                if !user_names_.contains(friend) {
                    throw AppError.runtimeError("Friend does not exist")
                }
            }
        }

        for hangout_info in raw_users_info.hangouts {
            // First check that all the users are valid
            for user_name in hangout_info.users.keys {
                if !user_names_.contains(user_name) {
                    throw AppError.runtimeError("User name does not exist")
                }
            }
            hangouts_names_.insert(hangout_info.name)
            hangouts_map_[hangout_info.name] = try! Hangout(hangout_info : hangout_info)
        }

        // Add users to hangout
        for (_, hangout) in hangouts_map_ {
            let active_users = hangout.getUsers()
            for usr in active_users.keys {
                if let user = users_map_[usr] {
                    user.addHangout(hangout.getName())
                }
            }
        }
        super.init()
    }
    
    func createHangoutMapMarkers(_ hangout_name : String) -> ([MGLShapeSource], [MGLSymbolStyleLayer], [String]){
        var shape_sources : [MGLShapeSource] = []
        var shape_layers : [MGLSymbolStyleLayer] = []
        var image_names : [String] = []
        
        // First grab hangout
        if let hangout = hangouts_map_[hangout_name] {
            // First create hangout marker
            let (hangout_source, hangout_layer) = hangout.createMapMarker()
            shape_sources.append(hangout_source)
            shape_layers.append(hangout_layer)
            image_names.append(hangout.getImageName())
            
            let hangout_users = hangout.getUsers()
            // Create markers for all the users
            for usr_name in hangout_users.keys {
                // First grab the user
                if let usr = users_map_[usr_name] {
                    let (usr_source, usr_layer) = usr.createMapMarker()
                    shape_sources.append(usr_source)
                    shape_layers.append(usr_layer)
                    image_names.append(usr.getImageName())
                }
            }
        }
        return (shape_sources, shape_layers, image_names)
    }
    
    func createHangoutAnnotations(_ hangout_name : String) -> [MGLAnnotation] {
        var annotations = [MGLAnnotation]()
        
        // First grab hangout
        if let hangout = hangouts_map_[hangout_name] {
            // First create hangout marker
            annotations.append(hangout.createMapAnnotation())
            
            let hangout_users = hangout.getUsers()
            // Create markers for all the users
            for usr_name in hangout_users.keys {
                // First grab the user
                if let usr = users_map_[usr_name] {
                    annotations.append(usr.createMapAnnotation())
                }
            }
        }
        return annotations
    }
    
    func getUserImageName(_ user_name : String) -> String {
        var image_name : String = ""
        if let usr = users_map_[user_name] {
            image_name = usr.getImageName()
        }
        return image_name
    }
    func getHangoutImageName(_ hangout_name : String) -> String {
        var image_name : String = ""
        if let hangout = hangouts_map_[hangout_name] {
            image_name = hangout.getImageName()
        }
        return image_name
    }
    func getHangout(_ hangout_name : String) -> Hangout? {
        var hangout : Hangout?
        if let hg = hangouts_map_[hangout_name] {
            hangout = hg
        }
        return hangout
    }
    
    func estimateHangoutETA(_ hangout_name : String) {
        if let hangout = hangouts_map_[hangout_name] {
            let dest_location = hangout.getLocation()
            let destination = Waypoint(coordinate: CLLocationCoordinate2D(latitude: dest_location[0], longitude: dest_location[1]), name: hangout.getName())
            let hangout_users = hangout.getUsers()
            // Create markers for all the users
            for usr_name in hangout_users.keys {
                // First grab the user
                if let usr = users_map_[usr_name] {
                    let origin_location = usr.getLocation()
                    let origin = Waypoint(coordinate: CLLocationCoordinate2D(latitude: origin_location[0], longitude: origin_location[1]), name: usr.getName())
                    eta_estimator_.estimateETA(origin: origin, destination: destination, completion:{ (eta : TimeInterval) in
                        hangout.addUserETA(user_id: usr.getName(), eta: eta)
                    })
                }
            }
            
        }
        
    }
}
