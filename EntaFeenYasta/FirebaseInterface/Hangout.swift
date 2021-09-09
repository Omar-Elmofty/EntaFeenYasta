//
//  Hangout.swift
//  EntaFeenYasta
//
//  Created by Omar Elmofty on 2021-05-23.
//

import Foundation
import Firebase
import FirebaseFirestoreSwift
	
/**
 *@brief Class for holding various hangout information, this information will be pushed/pulled to firebase.
 */
struct HangoutInfo : Codable
{
    // Document id, if empty string then a randomly generated id is created
    var name : String
    var type : String
    var location : [Double]
    var image_name : String
    var date : String
    var time : String
    var location_address: String
    
//    enum CodingKeys: String, CodingKey {
//      // Add alternative key name here
//      case id  // = "document_id" example document_id is an alternative key name to id
//      case name
//    }
}

struct HangoutUsers : Codable
{
    var user_id: String
    var privilege: String // admin, observer
    var acceptance_status: String // accepted, tentative, declined, request_sent
    var share_location: Bool
    var share_location_start_time: String
    var share_location_end_time: String
    var hangout_id: String
}

/**
 *@brief Class for managing a hangout.
 */
class Hangout : MapMarker
{
    // User info
    private var hangout_info_ : HangoutInfo
    private var hangout_users_: [String : HangoutUsers] = [:]
    private var hangout_id_: String = ""

    private var pull_successful_: Bool = true
    private var push_counter_: size_t = 0
    
    private var hangout_pull_push = FirebasePullPush<HangoutInfo>()
    private var hangout_users_pull_push = FirebasePullPush<HangoutUsers>()

    /**
     * @brief Contructor.
     * @param hangout_info Struct holding various hangout info used for initializing hangout.
     */
    init(hangout_info : HangoutInfo) throws
    {
        try! Utilities.checkLocation(hangout_info.location)
        hangout_info_ = hangout_info
        super.init()
        setMarkerData(marker_name: hangout_info_.name, marker_type: "hangout", image_name: hangout_info_.image_name, location: (lattitude: hangout_info_.location[0], longtitude: hangout_info_.location[1]))
        setupFireBasePushPull()
    }
    
    /**
     * @brief Contructor.
     */
    init(hangout_id: String)
    {
        hangout_id_ = hangout_id
        // Initalize an empty struct
        hangout_info_ = HangoutInfo(name: "", type: "", location: [], image_name: "", date: "", time: "", location_address: "")
        super.init()
        setupFireBasePushPull()
    }
    
    func setupFireBasePushPull()
    {
        hangout_pull_push.collection_name = Constants.Firebase.hangouts_collection_name
        hangout_users_pull_push.collection_name = Constants.Firebase.hangouts_collection_name
        hangout_users_pull_push.sub_collection_name = Constants.Firebase.hangout_users_collection_name
    }
    
    /**
     * @brief Push to firebase.
     */
    func pushToFirebase()
    {
        push_counter_ = 1 + hangout_users_.count
        pushHangoutInfoToFirebase()
        pushAllUsersToFirebase()
    }
    
    func pushSuccessful() -> Bool
    {
        return push_counter_ == 0
    }
    
    private func pushHangoutInfoToFirebase()
    {
        hangout_pull_push.pushToFirebase(hangout_info_, document_id: hangout_id_, sub_document_id: nil) {
            self.push_counter_ -= 1
        }
    }
    
    private func pushAllUsersToFirebase()
    {
        for (user_id, user_info) in hangout_users_
        {
            hangout_users_pull_push.pushToFirebase(user_info, document_id: hangout_id_, sub_document_id: user_id) {
                self.push_counter_ -= 1
            }
        }
    }
    
    func pushUserToFirebase(_ user_id: String)
    {
        if (hangout_users_[user_id] != nil)
        {
            hangout_users_pull_push.pushToFirebase(hangout_users_[user_id]!, document_id: hangout_id_, sub_document_id: user_id, completion: nil)
        }
    }
    
    func pullFromFirebase()
    {
        pullHangoutInfoFromFirebase()
        
        pullAllUsersFromFirebase()
    }
    
    func pullHangoutInfoFromFirebase()
    {
        hangout_pull_push.pullFromFirebase(document_id: hangout_id_, sub_document_id: nil) { hangout_info in
            self.hangout_info_ = hangout_info
        }
    }
    
    func pullAllUsersFromFirebase()
    {
        hangout_users_pull_push.pullAllDocuments(document_id: hangout_id_) { hangout_users in
            self.hangout_users_ = hangout_users
        }
    }
    func pullUserFromFirebase(_ user_id: String)
    {
        hangout_users_pull_push.pullFromFirebase(document_id: hangout_id_, sub_document_id: user_id) { user_info in
            self.hangout_users_[user_id] = user_info
        }
    }

    /**
     * @brief Get hangout session name.
     * @return User names.
     */
    func getName() -> String {
        return hangout_info_.name
    }

    /**
     * @brief Add a user to the hangout session.
     * @param user_id  the user id.
     * @param user_privilege The user privilige.
     */
    func addUser(_ user_id : String, _ user_privilege : String, acceptance_status: String) {
        if (hangout_users_[user_id] == nil)
        {
            hangout_users_[user_id] = HangoutUsers(user_id: user_id, privilege: user_privilege, acceptance_status: acceptance_status, share_location: false, share_location_start_time: "", share_location_end_time: "", hangout_id: hangout_id_)
        }
    }

    /**
     * @brief Remove user from the hangout session.
     * @param The user id.
     */
    func removeUser(_ user_id : String) {
        hangout_users_.removeValue(forKey: user_id)
        hangout_users_pull_push.deleteDocument(document_id: hangout_id_, sub_document_id: user_id)
    }

    /**
     * @brief  Get the hangout location.
     * @return Location of the hangout session [latitude, longtitude]
     */
    func getLocation() -> [Double]
    {
        return hangout_info_.location
    }
    
    func setPrivateStatus(_ is_private: Bool)
    {
        if (is_private)
        {
            hangout_info_.type = "private"
        }
        else
        {
            hangout_info_.type = "public"
        }
    }
    func setName(_ name: String)
    {
        hangout_info_.name = name
    }
    func setDate(_ date: String)
    {
        hangout_info_.date = date
    }
    func setTime(_ time: String)
    {
        hangout_info_.time = time
    }
    func isUserInHangout(_ user_id: String) -> Bool {
        return hangout_users_[user_id] != nil
    }
    func getNumUsers() -> size_t {
        return hangout_users_.count
    }
    func setLocationAddress(_ location_address: String) {
        hangout_info_.location_address = location_address
    }
    func getType() -> String {
        return hangout_info_.type
    }
    func getTime() -> String {
        return hangout_info_.time
    }
    func addUserLocationSharingOptions(_ user_id: String, _ share_location: Bool, _ start_time: String, _ end_time: String)
    {
        // First retrieve the user
        if (hangout_users_[user_id] != nil)
        {
            var user_info = hangout_users_[user_id]!
            user_info.share_location = share_location
            user_info.share_location_start_time = start_time
            user_info.share_location_end_time = end_time
            hangout_users_[user_id] = user_info
        }
    }
    
    func setHangoutID(_ id: String)
    {
        hangout_id_ = id
    }
    
    func getID() -> String
    {
        return hangout_id_
    }
}
