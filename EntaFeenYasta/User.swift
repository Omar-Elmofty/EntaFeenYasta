//
//  User.swift
//  EntaFeenYasta
//
//  Created by Omar Elmofty on 2021-05-23.
//

import Foundation
import Mapbox

// Struct holding various user info, loadable from Json
struct UserInfo : Codable
{
    var name : String
    var location : [Double]
    var image_name : String
    var friends : Set<String>
}

// Class representing user.
class User : MapMarker
{
    // User info
    private var user_info_ : UserInfo
    private var active_hangouts_ : Set<String> = []

    init(user_info : UserInfo)
    {
        try! checkLocation(user_info.location)
        user_info_ = user_info
        super.init(marker_name: user_info_.name, marker_type: "user", image_name: user_info_.image_name, location: (lattitude: user_info.location[0], longtitude: user_info.location[1]))
    }

    func addHangout(_ hangout_name : String)
    {
        active_hangouts_.insert(hangout_name)
    }

    func removeHangout(_ hangout_name : String)
    {
        if let index = active_hangouts_.firstIndex(of: hangout_name) {
            active_hangouts_.remove(at: index)
        }
    }

    func getName() -> String {
        return user_info_.name
    }

    func getActiveHangouts() -> Set<String> {
        return active_hangouts_
    }

    func getFriends() -> Set<String> {
        return user_info_.friends
    }
    func getLocation() -> [Double]
    {
        return user_info_.location
    }
}
