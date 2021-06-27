//
//  Hangout.swift
//  EntaFeenYasta
//
//  Created by Omar Elmofty on 2021-05-23.
//

import Foundation

// Struct holding various info about a hangout, loadable from json
struct HangoutInfo : Codable
{
    var name : String
    var location : [Double]
    var image_name : String
    var user_names : Set<String>
}

// Class representing hangout
class Hangout : MapMarker
{
    // User info
    private var hangout_info_ : HangoutInfo
    private var user_eta_ : [String : TimeInterval] = [:]

    init(hangout_info : HangoutInfo)
    {
        try! checkLocation(hangout_info.location)
        hangout_info_ = hangout_info
        super.init(marker_name: hangout_info_.name, marker_type: "hangout", image_name: hangout_info_.image_name, location: (lattitude: hangout_info_.location[0], longtitude: hangout_info_.location[1]))
    }

    func getUsers() -> Set<String> {
        return hangout_info_.user_names
    }

    func getName() -> String {
        return hangout_info_.name
    }

    func addUser(_ user_name : String) {
        hangout_info_.user_names.insert(user_name)
    }

    func removeUser(_ user_name : String) {
        if let index = hangout_info_.user_names.firstIndex(of: user_name) {
            hangout_info_.user_names.remove(at: index)
        }
    }
    func addUserETA(user_name : String, eta : TimeInterval)
    {
        user_eta_[user_name] = eta
        print("Hangout name \(hangout_info_.name)")
        print("User name \(user_name)")
        print("ETA \(eta)")
    }
    
    func getUserETA(_ user_name : String) -> TimeInterval
    {
        if let eta = user_eta_[user_name] {
            return eta
        }
        return 0.0
    }
    func getLocation() -> [Double]
    {
        return hangout_info_.location
    }
}
